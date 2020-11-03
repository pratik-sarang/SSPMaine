/**
* Class Name    : RE_FeedbackDetailsCtrl
* Owner         : DELOITTE
* Created Date  : 06/04/2019
* Description   : Controller class for RE_FeedbackModal
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/04/2019  Akash       Initial Version
**/

public with sharing class RE_FeedbackDetailsCtrl{
    

    
    /********************************************************************************************
* @author       Akash Sharma
* @date         06/10/2019
* @methodname   createFeedbackUpdateReferral()
* @description  This methods is used to create Feedback and Update Referral
* @param        Id accid, Id referralId, Feedback__c feedbackRec, Boolean isResourceProvided
* @return       void 
**********************************************************************************************/ 
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFeedbackUpdateReferral(Object feedbackModalData,Feedback__c feedbackRec, Boolean isResourceProvided){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Referral__c objreferral = new Referral__c(); 
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Object,Object> feedBackDataMap = (map<Object,Object>)feedbackModalData;
        String refId = String.escapeSingleQuotes((String)feedBackDataMap.get('referralId'));
        try{
            updateFeedback(feedBackDataMap, feedbackRec);
            String sFieldsApiNameForReferral = RE_DataBaseQueryFields.sFieldsApiNameForReferral;
            String sWhereClauseForReferral = RE_DataBaseQueryFields.sWhereClauseIdInRecordId;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForReferral);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsApiNameForReferral,mapQueryParameters);
            if(mapResponseReferral.get(true) != null){
                sQuery =  mapResponseReferral.get(true);
                objreferral = RE_SharingByPassCtrl.getReferralRecords(sQuery, refId);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'Re_ReferralDetailsCTrl','getReferralDetails','***FLS Violation***'+mapResponseReferral.get(false),true);
            } 
            if(isResourceProvided!=NULL){
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (isResourceProvided==true) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchCaseKey) {
                    when SWITCH_SUCCESS {
                        objreferral.Outcome__c = Label.feedbackoutcomeresourceprovided;
                    }
                    when SWITCH_FAILURE {
                        objreferral.Outcome__c = Label.feedbackoutcomeresourcenotprovided;  
                    }
                }
            }
            if(feedBackDataMap.get('bOrgIsClaimed')==false){
                objreferral.Status__c = RE_GlobalConstants.STATUS_CLOSING_REFERRAL;
            }
            objreferral.UserComplete__c= true;
            RE_SharingByPassCtrl.updateReferralRecords(objReferral);
            bSuccess = true;
        }
        catch(Exception e){
            errorMap.put('error', e.getMessage());
            
            bSuccess = false;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    public static void updateFeedback(Map<Object,Object> feedBackDataMap, Feedback__c feedbackRec){
        GeneralUtility.isAuthenticatedUser();
        Id partnerfeedbackRecTypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Resource Rating').getRecordTypeId();
        List<Feedback__c> feedbacklst=RE_SharingByPassCtrl.getFeedback(String.escapeSingleQuotes((String)feedBackDataMap.get('referralId')),partnerfeedbackRecTypeId);
        if(!feedbacklst.isEmpty()){
            feedbacklst[0].Rating__c=feedbackRec.Rating__c;
            feedbacklst[0].RatingDescription__c=feedbackRec.RatingDescription__c;
            // RE_DataAccessChecker.updateObject(Feedback__c.getSObjectType(), feedbacklst[0]);
        	RE_SharingByPassCtrl.updateSobject(Feedback__c.getSObjectType(), feedbacklst[0]);
        }else{
            Feedback__c objFeedback = new Feedback__c();
            objFeedback.recordtypeid = partnerfeedbackRecTypeId;
            objFeedback.Referral__c = (String)feedBackDataMap.get('referralId');  
            objFeedback.Rating__c = feedbackRec.Rating__c;
            objFeedback.RatingDescription__c = feedbackRec.RatingDescription__c;
            objFeedback.AccountID__c = (String)feedBackDataMap.get('sReferralOrgId');  
             // RE_DataAccessChecker.insertObject(Feedback__c.getSObjectType(), objFeedback);
            RE_SharingByPassCtrl.insertSobject(Feedback__c.getSObjectType(), objFeedback);
        }
        try{
            List<SurveyInvitation> lstSurveyInvites=RE_SharingByPassCtrl.fetchSurveyInvites((String)feedBackDataMap.get('referralId'));
            if(lstSurveyInvites!=null && lstSurveyInvites.size()>0){
                for(SurveyInvitation s: lstSurveyInvites){
                    s.InviteExpiryDateTime=datetime.now();
                }
                RE_SharingByPassCtrl.updateSobjects(SurveyInvitation.getSObjectType(),lstSurveyInvites);
            }
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_FeedbackDetailsCtrl','updateFeedback','Error Occured:: '+ e.getMessage(), true);
        }
    }
}