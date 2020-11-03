public with sharing class SSP_messageUtility {
@future(callout = true)
    public static void sendCommunnication(String surveyLink , String preferredComm, String locale, String phone, String email, String body, String bodyES, String title, String titleSpanish, Id triggeringId, String citizenFirstName){
       String surveyURL = surveyLink;
        boolean isSuccess = false;
        try{
        String shortenedUrl = RE_URLShortener.getShortenedURL(surveyURL , 'SSP Survey' /*'RebrandlyShortURL'*/);
        
        List<CommunicationLog__c> commList= new List<CommunicationLog__c>();
        String bodyLocal;
        String titleLocal;
        Boolean isSendSMS = false;
        Boolean isSendEmail = false;

        // Locale
        if(locale == SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH){
            bodyLocal = bodyES;
            titleLocal = titleSpanish;
        }else{
            bodyLocal = body;
            titleLocal = title;
        }
        
        // Preferred Communication
        if(preferredComm == SSP_GlobalConstants.MESSAGE_EE){
            isSendSMS = false;
            isSendEmail = true;
        }
        if(preferredComm == SSP_GlobalConstants.MESSAGE_ES){
            isSendSMS = true;
            isSendEmail = true;
        }
        if(preferredComm == SSP_GlobalConstants.MESSAGE_P){
            isSendSMS = false;
            isSendEmail = false;
        }

        // Build Communication Nubs
        if(isSendSMS){
            CommunicationLog__c commRec = new CommunicationLog__c();
            commRec.Send_SMS__c = true;
            commRec.SendMail__c = false;
            commRec.TemplateBody__c = bodyLocal + ' <a href ='+ surveyURL + '>'+ shortenedUrl+ '</a>';
            commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
            commRec.Recipient_Phone_Number__c = phone;
            commRec.TriggeredRecordId__c = triggeringId;
            commList.add(commRec);
        }
        if(isSendEmail){
            CommunicationLog__c commRec = new CommunicationLog__c();
            commRec.EmailSubject__c = String.format(SSP_GlobalConstants.MESSAGE_SUBJECT,new list<string>{titleLocal});
            commRec.Send_SMS__c = false;
            commRec.SendMail__c = true;
            bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{citizenFirstName}) + bodyLocal + ' <a href ='+ surveyURL + '>'+ shortenedUrl+ '</a>' + SSP_GlobalConstants.MESSAGE_FOOTER;
            commRec.TemplateBody__c = bodyLocal;
            commRec.ToEmail__c = email;
            commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
            commRec.TriggeredRecordId__c = triggeringId;
            commList.add(commRec);
        }
        
        if(!commList.isEmpty()){
            insert commList;
            isSuccess = true;
        }
        
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_messageUtility', 'sendCommunnication', ex.getMessage() , true);
            isSuccess = false;
        }
    }
}