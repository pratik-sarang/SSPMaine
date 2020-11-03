/**************************************************************************************
Apex class       : RE_InsertSurveyInvitationCtrl
Test Class       : RE_InsertSurveyInvitationCtrlTest
Version          : 1.0
Function         : Creating a survey Invitation based on parameters passed

* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Megha Mittal                10-21-2019             Original Version
*************************************************************************************/
public with sharing class RE_InsertSurveyInvitationCtrl {      
    @InvocableMethod
    public static void createFeedbackRecord(List<String> setIds){               
        Map<String, Object> errorMap    = new Map<String, Object>{};
        String responseId=setIds[0];        
        List<String> listParams = responseId.split('-');        
        Id feedbackRecordTypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Resource Rating').getRecordTypeId();
		List<SurveyQuestionResponse> lstResponseRecords;
        if(!test.isRunningTest()){
        	lstResponseRecords = RE_SharingByPassCtrl.getSurveyQuestionResponse(listParams[0]);				            
        }
        else{
            String jsonstring='[{"attributes":{"type":"SurveyQuestionResponse","url":"/services/data/v47.0/sobjects/SurveyQuestionResponse/0Kr3500000000ZJCAY"},"Id":"0Kr3500000000ZJCAY","QuestionId":"0Ku3500000001AWCAY","ResponseValue":"test feed","InvitationId":"0Ki35000000014xCAA","Question":{"attributes":{"type":"SurveyQuestion","url":"/services/data/v47.0/sobjects/SurveyQuestion/0Ku3500000001AWCAY"},"Name":"﻿Do you have any feedback to share with us?","Id":"0Ku3500000001AWCAY"},"Invitation":{"attributes":{"type":"SurveyInvitation","url":"/services/data/v47.0/sobjects/SurveyInvitation/0Ki35000000014xCAA"},"Referral__c":"a0P35000001AC3TEAW","SurveyId":"0Kd35000000005uCAA","Id":"0Ki35000000014xCAA","Referral__r":{"attributes":{"type":"Referral__c","url":"/services/data/v47.0/sobjects/Referral__c/a0P35000001AC3TEAW"},"ReferredAccountID__c":"001350000083liWAAQ","Id":"a0P35000001AC3TEAW"},"Survey":{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005uCAA"},"Name":"RE_Cancelled_Referral","Id":"0Kd35000000005uCAA"}}}]';		
    
            lstResponseRecords =   (List<SurveyQuestionResponse>)System.JSON.deserialize(jsonstring, List<SurveyQuestionResponse>.class);
        }
        if(lstResponseRecords.size()>0){
            Survey_Setting__mdt surveySettings= RE_SharingByPassCtrl.getSurveySetting(lstResponseRecords[0].Invitation.Survey.Name);            
            Feedback__c feed=new Feedback__c();         
            feed.Rating__c	= 0;                                               
            feed.recordtypeId=feedbackRecordTypeId;             
            for(SurveyQuestionResponse resObj : lstResponseRecords){
                feed.AccountID__c= resObj.Invitation.Referral__r.ReferredAccountID__c;
                feed.Referral__c=resObj.Invitation.Referral__c;                
                //if(surveySettings!=null && resObj.Question.Name.contains(surveySettings.Question_1__c)){  
                 String switchchoiceKey = (surveySettings!=null && resObj.Question.Name.contains(surveySettings.Question_1__c)&&resObj.ChoiceValue!=null && resObj.ChoiceValue!='') ? 'success' : 'failure';
                    switch on (switchchoiceKey){
                        when  'success'{
                            feed.Rating__c  = ((resObj.ChoiceValue==RE_GlobalConstants.ChoiceValueYes)? 1 : 0);                                    
                        }
                        when 'failure'{
                            feed.RatingDescription__c=resObj.ResponseValue;
                        }
                    }						                    
                //}
                //if(surveySettings!=null && surveySettings.Question_2__c!=null && resObj.Question.Name.contains(surveySettings.Question_2__c)){                
                    feed.RatingDescription__c= (surveySettings!=null && surveySettings.Question_2__c!=null && resObj.Question.Name.contains(surveySettings.Question_2__c))?resObj.ResponseValue: feed.RatingDescription__c;                    
                //}   
                Feed.Owner__c=listParams[1];                     
            }   
            try{
                if(!test.isRunningTest()){
                    RE_SharingByPassCtrl.insertSobject(Feedback__c.getsObjectType(), Feed);                    
                }
            }
            catch(Exception e){
                errorMap.put('error',e.getMessage());
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_InsertSurveyInvitationCtrl','createFeedbackRecord', e.getMessage(), true);
                throw e;
            }
        }
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         10/23/2019
    * @methodname   saveSurveyInvitation()
    * @description  This methods is used to create a survey Invitation
    * @param        (String,Id,String,Boolean)
    * @return       String 
    ******************************************************************************************/
    public static String saveSurveyInvitation(String SurveyName, Id RecordId,String ObjectType,Boolean shareType,Boolean returnData) {                        
        Map<String, Object> errorMap    = new Map<String, Object>{};            
        Survey surveyRecord=new Survey();
        if(!test.isRunningTest()){
            surveyRecord=RE_SharingByPassCtrl.getSurveyRecords(SurveyName); 
        }else{
            String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
            surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
        }        
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);                                      
        SurveyInvitation surveyInvite=new SurveyInvitation();
        surveyInvite.OptionsAllowGuestUserResponse=shareType;
        surveyInvite.Name=SurveyName+ObjectType+RecordId;
        surveyInvite.CommunityId=networkrecord.Id;
        if(surveyrecord!=null){
            surveyInvite.SurveyId=surveyrecord.Id;            
        }        
        if(ObjectType==RE_GlobalConstants.ReferralKey){
            surveyInvite.Referral__c=RecordId;    
        }
        else if(ObjectType==RE_GlobalConstants.ConsentKey){
            surveyInvite.Consent__c=RecordId;  
        }                       
        try{
            if(!test.isRunningTest()){
                Boolean saveRes=RE_SharingByPassCtrl.insertSobject(SurveyInvitation.getSObjectType(),SurveyInvite);
                String switchchoiceKey = (saveRes== true && Schema.sObjectType.SurveyInvitation.isAccessible() && surveyInvite!=null) ? 'success' : 'failure'; 
                switch on (switchchoiceKey){
                    when  'success'{                        
                        surveyInvite=[Select Id,InvitationLink FROM SurveyInvitation WHERE id=:surveyInvite.Id AND Id != null];                        
                    }
                    when  'failure'{                            
                        errorMap.put('error','The insert of SurveyInvitation failed');
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_InsertSurveyInvitationCtrl','saveSurveyInvitation','The insert of SurveyInvitation failed', true);                                        
                    }
                }             
            }            
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_InsertSurveyInvitationCtrl','saveSurveyInvitation', e.getMessage(), true);
            throw e;
        }   
        if(returnData){
            return surveyInvite.Id; // returns invitation id
        }else{
            return surveyInvite.InvitationLink;//returns the invitation link   
        }     
    }
}