/**
 * Class Name    : SSP_MessageCenterDocumentBatch
 * Author        : Aniket Shinde
 * Created Date  : 15-June-2020
 * Description   : This batch class creates message center notifications for uploaded documents.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 */
global class SSP_MessageCenterDocumentBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date currentDate=SSP_Utility.today();
        DateTime startDT=DateTime.newInstanceGmt(currentDate.year(), currentDate.month() , currentDate.day(), 0, 00, 0);
        DateTime endDT=DateTime.newInstanceGmt(currentDate.year(), currentDate.month() , currentDate.day(), 23, 59, 0);
		string query = 'select Id, Due_Date__c, UniqueIdentifier__c, name, IndividualId__c, CreatedById,Hearing_Id__c, Hearing_Request_Number__c, FailureReason__c, Notification_Recipient_Id__c from DocumentDetail__c where (UniqueIdentifier__c != null OR Hearing_Id__c!=null) AND LastModifiedDate >= :startDT AND LastModifiedDate <= :endDT AND (FailureReason__c = \''+SSP_GlobalConstants.VIRUS_AFFECTED+'\' OR FailureReason__c = \''+SSP_GlobalConstants.PASSWORD_PROTECTED+'\')'; 
        return Database.getQueryLocator(query);
    }
	
    global void execute(Database.BatchableContext bc, List<DocumentDetail__c> scopeDocumentList){
        map<string,SSP_Message_Center_Configuration__mdt> notifMetatdataMap = new map<string,SSP_Message_Center_Configuration__mdt>();
        map<string,SSP_Message_Center_Configuration__mdt> notifMetatdataHearingMap = new map<string,SSP_Message_Center_Configuration__mdt>();
        List<SSP_Notifications__c> notificationList = new List<SSP_Notifications__c>();
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Set<Id> allUserIdSet = new Set<Id>();
        map<string,map<string,object>> demographicMap = new map<string,map<string,object>>();
        map<String,List<DocumentDetail__c>> userToDocDetailMap = new map<String,List<DocumentDetail__c>>();
        List<DocumentDetail__c> citizenUploadedDocList = new List<DocumentDetail__c>();
        Map<String,Id> citizenIndIdtoUsrIdMap = new Map<String,Id>();
        Map<Id,DocumentDetail__c> idToObjDocDetailMap = new Map<Id,DocumentDetail__c>();
        try{
            // QUERY Metadata
            for(SSP_Message_Center_Configuration__mdt mdtRec : [select Id, DeveloperName, Code__c, Body__c, Body_Spanish__c, Title__c, 
                        Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
                        Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c
                        from SSP_Message_Center_Configuration__mdt 
                        where DeveloperName = :SSP_GlobalConstants.SF_TOD_004_DOCCENTER OR DeveloperName = :SSP_GlobalConstants.SF_TOD_005_DOCCENTER OR DeveloperName = :'SF_TOD_005_Hearing' OR DeveloperName = :'SF_TOD_004_Hearing'])
            {                
                if(mdtRec.DeveloperName==SSP_GlobalConstants.SF_TOD_004_DOCCENTER)
                    notifMetatdataMap.put(SSP_GlobalConstants.VIRUS_AFFECTED,mdtRec);
                if(mdtRec.DeveloperName==SSP_GlobalConstants.SF_TOD_005_DOCCENTER)
                    notifMetatdataMap.put(SSP_GlobalConstants.PASSWORD_PROTECTED,mdtRec);
                 if(mdtRec.DeveloperName=='SF_TOD_004_Hearing')
                    notifMetatdataHearingMap.put(SSP_GlobalConstants.VIRUS_AFFECTED,mdtRec);
                if(mdtRec.DeveloperName=='SF_TOD_005_Hearing')
                    notifMetatdataHearingMap.put(SSP_GlobalConstants.PASSWORD_PROTECTED,mdtRec);
            }


            /*  Below snippet dinstinguish and parse demographic data for Citizen, Non Citizen.
                Data is categorized from contact, ssp member & user based upon user type in bulkified way. 
                demographicMap : is prepared with below attributes 
                    name, locale, recipientId, recipientType, phone, email, preferredCommunication(Email,Mobile Phone,EE,ES,P)
            */
            for(DocumentDetail__c docObj: scopeDocumentList){
                allUserIdSet.add(docObj.CreatedById);
                if(userToDocDetailMap.get(docObj.id) != null) 
                    (userToDocDetailMap.get(docObj.CreatedById)).add(docObj);
                else
                    userToDocDetailMap.put(docObj.CreatedById, new list<DocumentDetail__c>{docObj});
            }
            for(User usr: [select id, profile.name, LanguageLocaleKey, contact.Salutation, contact.name, contact.PreferredCommunicationMethod__c, contact.Email, contact.Phone, contact.DCDataId__c from user where Id in :allUserIdSet]){
                //non-citizen build up for demographic
                if(usr.profile.name == SSP_GlobalConstants.NON_CITIZEN_PROFILE){
                    //demographicMap.put(usr.Id,new map<string,object>{'name'=>usr.contact.Salutation+' '+usr.contact.name,'locale'=>usr.LanguageLocaleKey, 'recipientId'=>usr.contact.DCDataId__c, 'recipientType'=>SSP_GlobalConstants.NON_CITIZEN_PROFILE,
                    //                                    'phone'=>usr.contact.Phone,'email'=>usr.contact.Email,'preferredCommunication'=>usr.contact.PreferredCommunicationMethod__c});
                    demographicMap.put(usr.Id,new map<string,object>{'name'=>usr.contact.Salutation+' '+usr.contact.name,'locale'=>usr.LanguageLocaleKey, 'recipientType'=>SSP_GlobalConstants.NON_CITIZEN_PROFILE,
                                                        'phone'=>usr.contact.Phone,'email'=>usr.contact.Email,'preferredCommunication'=>usr.contact.PreferredCommunicationMethod__c});
                }
                if(usr.profile.name == SSP_GlobalConstants.RE_CITIZEN_PROFILE && userToDocDetailMap.get(usr.Id) != null){
                    citizenUploadedDocList.addAll(userToDocDetailMap.get(usr.Id));
                    // Fix for 388475
                    demographicMap.put(usr.Id,new map<string,object>{'name'=>usr.contact.name});
                }
            }
            //citizen build up for demographic
            for(DocumentDetail__c citizenDoc : citizenUploadedDocList){
                citizenIndIdtoUsrIdMap.put(citizenDoc.IndividualId__c,citizenDoc.CreatedById);
            }
            if(!citizenIndIdtoUsrIdMap.isEmpty()){
                for(SSP_Member__c curMem : [select id, IndividualId__c, PreferredWrittenLanguageCode__c, PreferredNotificationMethodCode__c, PrimaryPhoneNumber__c, Email__c from SSP_Member__c where IndividualId__c IN :citizenIndIdtoUsrIdMap.keySet()]){
                    map<string,object> mapLocalCopy = demographicMap.get(citizenIndIdtoUsrIdMap.get(curMem.IndividualId__c));
                    //mapLocalCopy.put('recipientId',curMem.IndividualId__c);
                    mapLocalCopy.put('recipientType',SSP_GlobalConstants.NOTIFICATION_CITIZEN);
                    mapLocalCopy.put('phone',curMem.PrimaryPhoneNumber__c);
                    mapLocalCopy.put('email',curMem.Email__c);
                    mapLocalCopy.put('preferredCommunication',curMem.PreferredNotificationMethodCode__c);
                    if(curMem.PreferredWrittenLanguageCode__c=='4')
                        mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH);
                    else
                        mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_ENGLISH);
                    demographicMap.put(citizenIndIdtoUsrIdMap.get(curMem.IndividualId__c),mapLocalCopy);
                }
            }

            

            /*
            *   prepare Notification, using document detail, metadata and demographicMap prepaared
            *   Recepient Id should be populated
            */
            Map<String,Id> hearingIdToDocuIdMap= new Map<String,Id>();            
            for(DocumentDetail__c docObj: scopeDocumentList){
                //if((demographicMap.get(docObj.CreatedById)).get('recipientId') != null)
                SSP_Message_Center_Configuration__mdt metadataForCurDoc= new SSP_Message_Center_Configuration__mdt();
                SSP_Notifications__c msgRecord = new SSP_Notifications__c();
                msgRecord.RecordTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
                if(String.isNotBlank(docObj.Hearing_Id__c)){
                  metadataForCurDoc = notifMetatdataHearingMap.get(docObj.FailureReason__c);
                  msgRecord.Linked_Record_Id__c = docObj.Hearing_Id__c+'-'+docObj.Hearing_Request_Number__c;
                  // fix 387429 
                  hearingIdToDocuIdMap.put(docObj.Hearing_Id__c+'-'+docObj.Hearing_Request_Number__c, docObj.Id);
                }else{
                  metadataForCurDoc = notifMetatdataMap.get(docObj.FailureReason__c);
                  msgRecord.Linked_Record_Id__c = docObj.Id;
                }                
                //msgRecord.Linked_Record_Id__c = docObj.Id;
                msgRecord.dmsDocumentId__c = docObj.UniqueIdentifier__c;
                msgRecord.dueDate__c = docObj.Due_Date__c;
                msgRecord.messageSubject__c = metadataForCurDoc.Title__c;
                msgRecord.messageSubjectES__c = metadataForCurDoc.Title_Spanish__c;
                msgRecord.notificationCode__c = metadataForCurDoc.Code__c;
                msgRecord.MessageCreateDate__c = SSP_Utility.today();
                msgRecord.Severity__c = metadataForCurDoc.Severity__c;
                msgRecord.Status__c = SSP_GlobalConstants.NOTIFICATION_ACTIVE;
                msgRecord.Notification_Body__c = String.format(metadataForCurDoc.Body__c,new list<string>{docObj.name});
                msgRecord.Notification_Body_Es__c = String.format(metadataForCurDoc.Body_Spanish__c,new list<string>{docObj.name});
                // Fix for 388475
                msgRecord.Reminder_Date__c = docObj.Due_Date__c != null ? ((docObj.Due_Date__c).addDays(Integer.valueOf(metadataForCurDoc.Send_Reminder_Criteria__c))).dateGMT() : null;
                //msgRecord.recipientId__c = (Integer.valueOf((String)(demographicMap.get(docObj.CreatedById)).get('recipientId')));
                //msgRecord.recipientId__c = (String)(demographicMap.get(docObj.CreatedById)).get('recipientId'); 
                msgRecord.recipientId__c = docObj.Notification_Recipient_Id__c;              
                msgRecord.recipientType__c = (String)(demographicMap.get(docObj.CreatedById)).get('recipientType');
                notificationList.add(msgRecord);
                idToObjDocDetailMap.put(docObj.id,docObj);
            }
            Database.insert(notificationList,false);

            /*
            *   prepare SMS and/or Email, using document detail, metadata, demographicMap prepaared & updated notification
            */
            for(SSP_Notifications__c notificationRec: notificationList){
                //defect 385642
                DocumentDetail__c docObj= new DocumentDetail__c();
                SSP_Message_Center_Configuration__mdt metadataForCurDoc= new SSP_Message_Center_Configuration__mdt();
                 // fix 387429 
                if(hearingIdToDocuIdMap!=null && notificationRec.Linked_Record_Id__c != null && hearingIdToDocuIdMap.get(notificationRec.Linked_Record_Id__c) != null)
                {
                    docObj=idToObjDocDetailMap.get(hearingIdToDocuIdMap.get(notificationRec.Linked_Record_Id__c));
                    metadataForCurDoc = notifMetatdataHearingMap.get(docObj.FailureReason__c);
                }else{
                    docObj = idToObjDocDetailMap.get(notificationRec.Linked_Record_Id__c);
                    metadataForCurDoc = notifMetatdataMap.get(docObj.FailureReason__c);
                }
                //defect 385642		
		        String bodyLocal;
                String titleLocal;
                Boolean isSendSMS = false;
                Boolean isSendEmail = false;
                if((String)(demographicMap.get(docObj.CreatedById)).get('locale') == SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH){
                    bodyLocal = metadataForCurDoc.Communication_Body_Spanish__c;
                    titleLocal = metadataForCurDoc.Title_Spanish__c;
                }else{
                    bodyLocal = metadataForCurDoc.Communication_Body__c;
                    titleLocal = metadataForCurDoc.Title__c;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_EE){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_ES){
                    isSendSMS = true;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_P){
                    isSendSMS = false;
                    isSendEmail = false;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_EE){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == 'Email'){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(docObj.CreatedById)).get('preferredCommunication') == 'Mobile Phone'){
                    isSendSMS = true;
                    isSendEmail = false;
                }
                if(isSendSMS){
                    CommunicationLog__c commRec = new CommunicationLog__c();
                    commRec.Send_SMS__c = true;
                    commRec.SendMail__c = false;
                    commRec.TemplateBody__c = bodyLocal;
                    commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    commRec.Recipient_Phone_Number__c = (String)(demographicMap.get(docObj.CreatedById)).get('phone');
                    commRec.TriggeredRecordId__c = notificationRec.Id;
                    commList.add(commRec);
                }
                if(isSendEmail){
                    CommunicationLog__c commRec = new CommunicationLog__c();
                    commRec.EmailSubject__c = String.format(SSP_GlobalConstants.MESSAGE_SUBJECT,new list<string>{titleLocal});
                    commRec.Send_SMS__c = false;
                    commRec.SendMail__c = true;
                    bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(docObj.CreatedById)).get('name')}) + bodyLocal +SSP_GlobalConstants.MESSAGE_FOOTER;
                    commRec.TemplateBody__c = bodyLocal;
                    commRec.ToEmail__c = (String)(demographicMap.get(docObj.CreatedById)).get('email');
                    commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    commRec.TriggeredRecordId__c = notificationRec.Id;
                    commList.add(commRec);
                }
            }
            Database.insert(commList,false);
            
            
        //try{                
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterDocumentBatch', 'execute', ex.getMessage() , true);
        }  
    }   
	
    global void finish(Database.BatchableContext bc){
        
    }    
    
    global void execute(SchedulableContext sc) {
        SSP_MessageCenterDocumentBatch batchObj = new SSP_MessageCenterDocumentBatch();
        database.executebatch(batchObj);
    }
	
}