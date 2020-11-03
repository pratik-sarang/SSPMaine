/**************************************************************************************
Apex class       : SSP_InsertSurveyInvitationCtrl
Test Class       : SSP_InsertSurveyInvitationCtrlTest
Version          : 1.0
Function         : Creating a survey Invitation based on parameters passed

* Developer                   Date                   Description
* ----------------------------------------------------------------------------
*************************************************************************************/
public class SSP_InsertSurveyInvitationCtrl {
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         06/12/2020
    * @methodname   saveSurveyInvitation()
    * @description  This methods is used to create a survey Invitation
    * @param        (String,Id,String,Boolean)
    * @return       String 
    ******************************************************************************************/
    public static String saveSurveyInvitation(String SurveyName, Id RecordId,String ObjectType,Boolean shareType, Boolean returnData,String communityName) {                        
        Map<String, Object> errorMap    = new Map<String, Object>{}; 
        Survey surveyRecord=new Survey();
        if(!test.isRunningTest()){
            surveyRecord=RE_SharingByPassCtrl.getSurveyRecords(SurveyName); 
        }else{
            String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
            surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
        }        
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(communityName);    
        SurveyInvitation surveyInvite=new SurveyInvitation();
        surveyInvite.OptionsAllowGuestUserResponse=shareType;
        surveyInvite.Name=SurveyName+ObjectType+RecordId;
        surveyInvite.CommunityId=networkrecord.Id;
        if(surveyrecord!=null){
            surveyInvite.SurveyId=surveyrecord.Id;            
        }  
        //Replace Object Name with new object
        if(ObjectType=='SSP_Notifications__c'){
            //Replace Lookup Field with new field
            surveyInvite.SSP_Notifications__c=RecordId;
            AppConfig__c delaytimer = AppConfig__c.getValues('AssisterTimerConfig');
          // Integer delayTime=Integer.valueof(System.Label.SurveyExpirationTime);
          Integer delayTime=Integer.valueof(delaytimer.Value__c);
          
           surveyInvite.InviteExpiryDateTime=Datetime.now().addMinutes(delayTime);
        }            
        try{
            if(!test.isRunningTest()){
                Boolean saveRes=RE_SharingByPassCtrl.insertSobject(SurveyInvitation.getSObjectType(),SurveyInvite);
                String switchchoiceKey = (saveRes== true && Schema.sObjectType.SurveyInvitation.isAccessible() && surveyInvite!=null) ? 'success' : 'failure'; 
                switch on (switchchoiceKey){
                    when  'success'{                        
                        surveyInvite=[Select Id,InvitationLink FROM SurveyInvitation WHERE id=:surveyInvite.Id AND id != Null ];                        
                    }
                    when  'failure'{                            
                        errorMap.put('error','The insert of SurveyInvitation failed');
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_InsertSurveyInvitationCtrl','saveSurveyInvitation','The insert of SurveyInvitation failed', true);                                        
                    }
                }             
            }            
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_InsertSurveyInvitationCtrl','saveSurveyInvitation', e.getMessage(), true);
            throw e;
        }  
        if(returnData){
           return surveyInvite.Id; // returns invitation id
        }else{
          return surveyInvite.InvitationLink;//returns the invitation link   
        }
       
    }

}