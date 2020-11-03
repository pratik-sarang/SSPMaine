/*
* classname         : SSP_MessageCenterService
* @description      : This class provides service methods for message Ceter.
* @author           : Aniket Shinde
* @date             : 03/06/2019
* MODIFICATION LOG  :
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public with sharing class SSP_MessageCenterService {

    /*
    * method        : processNotificationMessage
    * @description  : This method is use to store notification in SF
    * @author       : Aniket Shinde
    * @param        : identifier : identifierr for message center notification 
    *                              Values : SF_TOD_002 ( authorized representative completes Add Authorized Representative  )
    *                                       SF_TOD_003 ( assister completes the Assister Access Request  screen )
    *                                       SF_NOT_002 ( Association record for Authorized Representative updated to "Verified" (i.e. citizen accepts association request) )
    *                                       SF_NOT_003 ( Association record for Authorized Representative has not been updated to "Verified" (i.e. user rejects association request) )
    * @param        : inputData:
    *                   recipientId - String // IndividualId__c (for citizen), DCDataId__c (for other users)
    *                   recipientType - String // Citizen_Individual, Individual_Auth_Rep, Organization_Auth_Rep
    *                   acrId - String // associted ACR record
    *                   //Citizen ( SF_TOD_002, SF_TOD_003 )
    *                       preferredCommunication - String // SSP member > PreferredNotificationMethodCode__c > 'EE', 'ES', 'P'
    *                       preferredWrittenLanguageCode - String // '1'..
    *                       phone - String  // SSP member > PrimaryPhoneNumber__c
    *                       email - String // SSP member >  Email__c
    *                       citizenFirstName - String // First Name of >> citizen
    *                       nameCitizen - String // Salutation. FName MName LName >> citizen
    *                       nameNonCitizen - String // Salutation. FName MName LName >> non-citizen
    *                       programs - String // comma separated programs
    *                       permissions - String // MA-NT;SN-NT
    *                   //Non Citizen ( SF_NOT_002 , SF_NOT_003 ) - no sms / email here
    *                       notificationId - String // SF id of source notification via which user request notice was generated
    *                       sourceTodoCode - String // SF_TOD_002, SF_TOD_003
    * @return       : List<String, Object> | isSuccess, notificationId
    * */
    public static Map<String, Object> processNotificationMessage(String identifier, map<string,object> inputData) {       
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean isSuccess;
        SSP_Notifications__c msgRecord = new SSP_Notifications__c();
        List<CommunicationLog__c> commRecLst = new List<CommunicationLog__c>();
        List<SSP_Notifications__c> expireMsgRecords = new List<SSP_Notifications__c>();
        String smsBodyPerLang;
        Boolean isTriggerSMS=false;
        String surveyUrl;
        try{ 
            List<SSP_Message_Center_Configuration__mdt> msgCenterMdt = new list<SSP_Message_Center_Configuration__mdt>();
            String locale;
            if(identifier != null)
                msgCenterMdt = [select Id, Code__c, Body__c, Body_Spanish__c, Title__c, 
                        Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
                        Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c
                        from SSP_Message_Center_Configuration__mdt 
                        where DeveloperName = :identifier];
            if(msgCenterMdt.size() > 0 && inputData != null && inputData.get('recipientId') != null )
            {
                msgRecord.recipientId__c = (String)inputData.get('recipientId');
                msgRecord.Linked_Record_Id__c = ((String)inputData.get('acrId'));
                msgRecord.messageSubject__c = msgCenterMdt[0].Title__c;
                msgRecord.messageSubjectES__c = msgCenterMdt[0].Title_Spanish__c;
                msgRecord.notificationCode__c = msgCenterMdt[0].Code__c;
               // for fix 382061
                msgRecord.MessageCreateDate__c = SSP_Utility.today();
                msgRecord.Severity__c = msgCenterMdt[0].Severity__c;
                msgRecord.Status__c = SSP_GlobalConstants.NOTIFICATION_ACTIVE;

                //SF_TOD_002, SF_TOD_003 - create message notification
                if(identifier == SSP_GlobalConstants.SF_TOD_002 || identifier == SSP_GlobalConstants.SF_TOD_003)
                {
                    msgRecord.Notification_Body__c = String.format(msgCenterMdt[0].Body__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs')});
                    msgRecord.Notification_Body_Es__c = String.format(msgCenterMdt[0].Body_Spanish__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs')});
                    msgRecord.RecordTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
                    msgRecord.recipientType__c = SSP_GlobalConstants.NOTIFICATION_CITIZEN;
                    // for fix 382061
                    msgRecord.dueDate__c = msgRecord.MessageCreateDate__c.addDays(Integer.valueOf(msgCenterMdt[0].Due_Date_criterion__c));
                    // for fix 382061
                    msgRecord.Reminder_Date__c = (Date.valueOf(msgRecord.dueDate__c)).addDays(Integer.valueOf(msgCenterMdt[0].Send_Reminder_Criteria__c));
                    //Start - Tracker Defect-56
                    if(identifier == SSP_GlobalConstants.SF_TOD_002 && inputData.get('requestPermission')!=null) {
                        msgRecord.RequestAccessPermission__c = (String)inputData.get('requestPermission');
                    }
                    //End - Tracker Defect-56
                    // Fix for 382061-MY_INFORMATION
                    SSP_MessageCenterService.refreshMemberInformation((String)inputData.get('recipientId'));
                }

                //SF_NOT_002 , SF_NOT_003 - create message notification if access requeset is for Authorized Representative
                if( (identifier == SSP_GlobalConstants.SF_NOT_002 || identifier == SSP_GlobalConstants.SF_NOT_003) // fix 396655
                    && (String)inputData.get('sourceTodoCode') == SSP_GlobalConstants.SF_TOD_002){
                    msgRecord.Notification_Body__c = String.format(msgCenterMdt[0].Body__c,new list<string>{(String)inputData.get('citizenFirstName')});
                    msgRecord.Notification_Body_Es__c = String.format(msgCenterMdt[0].Body_Spanish__c,new list<string>{(String)inputData.get('citizenFirstName')});
                    msgRecord.RecordTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('System Notification').getRecordTypeId();
                    msgRecord.recipientType__c = getOtherRoleString((String)inputData.get('recipientType'));
                    //Fix - 386265
                    msgRecord.Expiry_Date__c =  (SSP_Utility.today()).addDays(Integer.valueOf(msgCenterMdt[0].Expiry_Date_Criterion__c));
                }
                //SF_NOT_002 , SF_NOT_003 - expire source todo notification
                if((identifier == SSP_GlobalConstants.SF_NOT_002 || identifier == SSP_GlobalConstants.SF_NOT_003) 
                    && inputData.get('notificationId') != null){
                        expireMsgRecords.add(new SSP_Notifications__c(Id=(String)inputData.get('notificationId'),Status__c = SSP_GlobalConstants.NOTIFICATION_EXPIRED));
                    }

                // new message notification
                List<SSP_Notifications__c> msgRecordList = new List<SSP_Notifications__c>{msgRecord};
                if((String)inputData.get('sourceTodoCode') != SSP_GlobalConstants.SF_TOD_003) // fix 396655
                {
                    insert msgRecordList;
                    responseMap.put('notificationId',msgRecordList[0].id);
                }

                //expire message notification
                if(!expireMsgRecords.isEmpty()){
                  expireMsgRecords = SSP_MessageCenterWithoutSharingService.updateExpiredRecords(expireMsgRecords);
                   // update expireMsgRecords;
                }

                //SF_TOD_002, SF_TOD_003 -sms/email
                if(identifier == SSP_GlobalConstants.SF_TOD_002){
				//for Bug 382121
                    String navigateToBenefind = 'https://'+System.label.SSP_MessageCenter_CommunicationURL;
                    String benefindURL = ' <a href ='+ navigateToBenefind + '>'+ System.label.SSP_MessageCenter_CommunicationURL+ '</a>';
                    // fix 380489
                  /*  msgCenterMdt[0].Communication_Body__c = String.format(msgCenterMdt[0].Communication_Body__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs'),'<br/>'+(String)inputData.get('permissions'),System.label.SSP_MessageCenter_CommunicationURL});
                    msgCenterMdt[0].Communication_Body_Spanish__c = String.format(msgCenterMdt[0].Communication_Body_Spanish__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs'),'<br/>'+(String)inputData.get('permissions'),System.label.SSP_MessageCenter_CommunicationURL});*/
					//for Bug 382121
                    msgCenterMdt[0].Communication_Body__c = String.format(msgCenterMdt[0].Communication_Body__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs'),'<br/>'+(String)inputData.get('permissions'),benefindURL});
                    msgCenterMdt[0].Communication_Body_Spanish__c = String.format(msgCenterMdt[0].Communication_Body_Spanish__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs'),'<br/>'+(String)inputData.get('permissions'),benefindURL});
                }
                if(identifier == SSP_GlobalConstants.SF_TOD_003){
		    String sCommunityName = AppConfig__c.getInstance('BenefindPrefix') != null ? AppConfig__c.getInstance('BenefindPrefix').value__c : '';
                    surveyUrl = SSP_InsertSurveyInvitationCtrl.saveSurveyInvitation('Kynector Access Request', msgRecordList[0].id,'SSP_Notifications__c',true, false,sCommunityName);
                    msgCenterMdt[0].Communication_Body__c = String.format(msgCenterMdt[0].Communication_Body__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs')});
                    msgCenterMdt[0].Communication_Body_Spanish__c = String.format(msgCenterMdt[0].Communication_Body_Spanish__c,new list<string>{(String)inputData.get('nameNonCitizen'),(String)inputData.get('programs')});
                  // SSP_messageUtility.callShortenURL(surveyUrl , msgCenterMdt[0].Communication_Body__c , msgCenterMdt[0].Communication_Body_Spanish__c);
                }
                if(identifier == SSP_GlobalConstants.SF_TOD_002 || identifier == SSP_GlobalConstants.SF_TOD_003)
                {
                    //map<string,string> userDataFetched = getUserInfo((String)inputData.get('recipientId'),(String)inputData.get('recipientType'));
                    map<string,string> mapLocalCopy = new map<string,string>();
                    if((String)inputData.get('preferredWrittenLanguageCode')=='4')
                        mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH);
                    else
                        mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_ENGLISH);
                    if(identifier == SSP_GlobalConstants.SF_TOD_003){
                        SSP_messageUtility.sendCommunnication(surveyUrl , (String)inputData.get('preferredCommunication'),mapLocalCopy.get('locale'),
                        (String)inputData.get('phone'),(String)inputData.get('email'), 
                        msgCenterMdt[0].Communication_Body__c,msgCenterMdt[0].Communication_Body_Spanish__c, msgCenterMdt[0].Title__c,msgCenterMdt[0].Title_Spanish__c,
                        msgRecordList[0].id,(String)inputData.get('citizenFirstName'));
                    }else{
                    commRecLst = getCommList( (String)inputData.get('preferredCommunication'),mapLocalCopy.get('locale'),
                        (String)inputData.get('phone'),(String)inputData.get('email'), 
                        msgCenterMdt[0].Communication_Body__c,msgCenterMdt[0].Communication_Body_Spanish__c, msgCenterMdt[0].Title__c,msgCenterMdt[0].Title_Spanish__c,
                        msgRecordList[0].id,(String)inputData.get('citizenFirstName'));
                }
                }
                if(!commRecLst.isEmpty()){
                    insert commRecLst;
                }
                
                isSuccess=true;
            }
            else{
                responseMap.put('error', 'Invalid Parameters'); 
                isSuccess=false;
            }
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterService', 'processNotificationMessage', ex.getMessage() , true);
            responseMap.put('ERROR',lstLogMessages);
            isSuccess = false;
        }  
        responseMap.put('isSuccess', isSuccess);  
        return responseMap;

    }

    /*
    * method        : getOtherRoleString
    * @description  : This method return text representation of code for role.
    * @author       : Aniket Shinde
    * @param        : String - User Role
    * @return       : String
    * */    
    public static String getOtherRoleString(String input) {
        string roleStr = '';

        if(input == '' || input == null)
            return roleStr;

        if(input == SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING)
            roleStr = SSP_GlobalConstants.NOTIFICATION_IND_AUTH_REP;    
        else if(input == SSP_GlobalConstants.ORGANISATION_AUTH_REP)
            roleStr = SSP_GlobalConstants.NOTIFICATION_ORG_AUTH_REP;
        else if(input == SSP_GlobalConstants.ROLE_ASSISTER)
            roleStr = SSP_GlobalConstants.NOTIFICATION_ASSISTER;
        else if(input == SSP_GlobalConstants.AGENCY_ADMIN_ROLE)
            roleStr = SSP_GlobalConstants.NOTIFICATION_AGENCY_ADMIN;
        else if(input == SSP_GlobalConstants.CITIZEN_ROLE)
            roleStr = SSP_GlobalConstants.NOTIFICATION_CITIZEN;
        else   
            roleStr = input;
        return roleStr;
    }

    /*
    * method        : getCommList
    * @description  : Get list of SMS / EMAIL nub records.
    * @author       : Aniket Shinde
    * @param        : String preferredComm, String locale, String phone, String email, String body, String bodyES
    * @return       : map<string,string>
    * */
    public static List<CommunicationLog__c> getCommList(String preferredComm, String locale, String phone, String email, String body, String bodyES, String title, String titleSpanish, String triggeringId, String citizenFirstName) {
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
            commRec.TemplateBody__c = bodyLocal;
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
            bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{citizenFirstName}) + bodyLocal +SSP_GlobalConstants.MESSAGE_FOOTER;
            commRec.TemplateBody__c = bodyLocal;
            commRec.ToEmail__c = email;
            commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
            commRec.TriggeredRecordId__c = triggeringId;
            commList.add(commRec);
        }
        return commList;
    }
    /***************************************************************************************************
    * @date         7 Aug 2020
    * @methodname   refreshMemberInformation
    * @description  This methods is used to pull member data using RSSPDC service and update respective member object
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @future(callout=true)
    public static void refreshMemberInformation(String individualId){
        try{         
            
            //String individualId = SSP_Utility.getIndividualId();
            if(individualId!=null && String.isNotBlank(individualId)){ 
                Map<String,Object> mapParams=new Map<String,Object>();
                SSP_RSSPDC_RequestWrapper reqWrapper=new SSP_RSSPDC_RequestWrapper();
                reqWrapper.viewName = SSP_InterfaceConstants.MY_INFORMATION;
                reqWrapper.primaryApplicationIndividualId = individualId;
                //reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();
                mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                mapParams.put(SSP_InterfaceConstants.SKIP_TRANSACTION_RECORD,false);
                mapParams.put(SSP_InterfaceConstants.SKIP_DML_OPERATIONS,false);
                List<Object> objList=IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC,mapParams);
                RSSP_DC_Wrapper responseWrapper=(RSSP_DC_Wrapper)objList.get(0);  
               
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterService', 'refreshMemberInformation', ex.getMessage() , true);            
        }
    }
}