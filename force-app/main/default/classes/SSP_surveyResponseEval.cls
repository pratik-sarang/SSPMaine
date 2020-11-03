public class SSP_surveyResponseEval {
	@InvocableMethod
    public static void recordResponse(List<Id> inviteID){
       // Set<Id> notificId = new Set<ID>();
       
        boolean citizenConsent;
        Map<Id,String> notificationUpdate = new Map<Id,String>();
       // List<SurveyQuestionResponse> surveyResponse = new List<SurveyQuestionResponse>([select ChoiceValue from SurveyQuestionResponse where InvitationId IN:inviteID]);
        for(SurveyInvitation notificationIDs : [select id,SSP_Notifications__c from SurveyInvitation where id IN:inviteID]){
        //    notificId.add(notificationIDs.SSP_Notifications__c);
            notificationUpdate.put(notificationIDs.id,notificationIDs.SSP_Notifications__c);
        }
		for(SurveyQuestionResponse choiceValue : [select ChoiceValue ,InvitationId from SurveyQuestionResponse where InvitationId IN:inviteID]){
            if(choiceValue.ChoiceValue == 'Accept'){
                citizenConsent = true;
            }else if(choiceValue.ChoiceValue == 'Reject'){
                citizenConsent = false;
            }
            if(notificationUpdate.containsKey(choiceValue.InvitationId)){
                updateNotificationACR(notificationUpdate.get(choiceValue.InvitationId),citizenConsent);
            }
        }
    }
    
    @future(callout=true)
    public static void updateNotificationACR(String notificationID , boolean consent){
        String notificID = notificationID;
        boolean consentVal = consent;
        SSP_AssisAuthRepConsentNotSignedService.updateAccountContactRelation(notificID,consentVal);
    }
}