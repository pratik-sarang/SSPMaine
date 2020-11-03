/**
 * Class Name    : SSP_MessageCenterApplicationNotify
 * Author        : Payal Dubela
 * Created Date  : 17-June-2020
 * Description   : This batch class creates message center notifications for Application close.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 */
global class SSP_MessageCenterApplicationNotify implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
	// for defect fix 382868
        List<String> lstStatus=new List<String>{'UN'};
        //380574 fix
        String applicationRecTypeId = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Date notifiyDate=SSP_Utility.today().addDays(-Integer.valueOf(System.Label.Notify_Day_For_Application_Expire));
        DateTime startDT=DateTime.newInstanceGmt(notifiyDate.year(), notifiyDate.month() , notifiyDate.day(), 0, 00, 0);
        DateTime endDT=DateTime.newInstanceGmt(notifiyDate.year(), notifiyDate.month() , notifiyDate.day(), 23, 59, 0);
        //380574 fix
        string query = 'select Id, Is_Batch_Processed__c, Contact__c,Contact__r.IndividualId__c,CreatedDate,ToLabel(ProgramsApplied__c)'+
                        ' from SSP_Application__c '+
                        'where Status__c=:lstStatus AND CreatedDate>= :startDT AND CreatedDate<= :endDT AND recordTypeId = :applicationRecTypeId';
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext bc, List<SSP_Application__c> scopeAppList){
        List<SSP_Message_Center_Configuration__mdt> notifMetatdataList = new List<SSP_Message_Center_Configuration__mdt>();
        List<SSP_Notifications__c> notificationList = new List<SSP_Notifications__c>();
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<string,map<string,object>> demographicMap = new Map<string,map<string,object>>();
    	List<String> individualIdList = new List<String>();
        Map<Id,SSP_Application__c> idToObjAppMap = new Map<Id,SSP_Application__c>();
        //380574 fix
        List<SSP_Application__c> updateApplicationsList = new List<SSP_Application__c>();
        try{
            notifMetatdataList= [select Id, DeveloperName, Code__c, Body__c, Body_Spanish__c, Title__c, 
                        Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
                        Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c
                        from SSP_Message_Center_Configuration__mdt 
                        where DeveloperName = :SSP_GlobalConstants.SF_TOD_001];
			List<Id> scopeAppIdLst = new List<Id>();
			for(SSP_Application__c appObj: scopeAppList){
                //380574 fix
                if(!appObj.Is_Batch_Processed__c){
                    scopeAppIdLst.add(appObj.Id);
                    idToObjAppMap.put(appObj.id,appObj);
                    updateApplicationsList.add(new SSP_Application__c(Id=appObj.Id,Is_Batch_Processed__c=true));
                }
			}
			for(SSP_ApplicationIndividual__c primaryIndividualId: [SELECT Id, SSP_Application__c, ssp_member__r.contact__c,ssp_member__r.individualid__c ,IsHeadOfHousehold__c FROM SSP_ApplicationIndividual__c where SSP_Application__c IN :scopeAppIdLst and IsHeadOfHousehold__c =true]){
				if(primaryIndividualId.ssp_member__r != null)
				{
					individualIdList.add(primaryIndividualId.ssp_member__r.individualid__c);
				}
			}
		  
            //Populate Demographic map
			for(SSP_Member__c curMem : [select id, IndividualId__c, PreferredWrittenLanguageCode__c, PreferredNotificationMethodCode__c, PrimaryPhoneNumber__c, Email__c,contact__r.name 
										from SSP_Member__c 
										where IndividualId__c IN :individualIdList]){
			  //  map<string,object> mapLocalCopy = demographicMap.get(curMem.IndividualId__c);
			   map<string,object> mapLocalCopy = new map<string,object>();
				mapLocalCopy.put('name',curMem.contact__r.name);
				mapLocalCopy.put('recipientId',curMem.IndividualId__c);
				mapLocalCopy.put('recipientType',SSP_GlobalConstants.NOTIFICATION_CITIZEN);
				mapLocalCopy.put('phone',curMem.PrimaryPhoneNumber__c);
				mapLocalCopy.put('email',curMem.Email__c);
				mapLocalCopy.put('preferredCommunication',curMem.PreferredNotificationMethodCode__c);
				if(curMem.PreferredWrittenLanguageCode__c=='4')
					mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH);
				else
					mapLocalCopy.put('locale',SSP_GlobalConstants.LANGUAGE_CODE_US_ENGLISH);
				demographicMap.put(curMem.IndividualId__c,mapLocalCopy);
			}

            /*
            *   prepare Notification, using document detail, metadata and demographicMap prepared
            *   Recepient Id should be populated
            */
			for(SSP_ApplicationIndividual__c primaryIndividualId:[SELECT Id, SSP_Application__c, ssp_member__r.contact__c,ssp_member__r.individualid__c ,IsHeadOfHousehold__c FROM SSP_ApplicationIndividual__c where SSP_Application__c In :scopeAppIdLst and IsHeadOfHousehold__c =true]){
				SSP_Application__c appObj = idToObjAppMap.get(primaryIndividualId.SSP_Application__c);
                if((demographicMap.get(primaryIndividualId.ssp_member__r.individualid__c)).get('recipientId') != null 
				&& appObj != null)
                {
					
                    SSP_Message_Center_Configuration__mdt metadataForCurApp = notifMetatdataList[0];
                    SSP_Notifications__c msgRecord = new SSP_Notifications__c();
                    msgRecord.RecordTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
                    msgRecord.Linked_Record_Id__c = appObj.Id;
                    msgRecord.dueDate__c = appObj.CreatedDate.addDays(Integer.valueOf(metadataForCurApp.Due_Date_criterion__c));
                    if(msgRecord.dueDate__c != null){
                    msgRecord.Expiry_Date__c=(msgRecord.dueDate__c).Date();//384762
                    }
                    msgRecord.messageSubject__c = metadataForCurApp.Title__c;
                    msgRecord.messageSubjectES__c = metadataForCurApp.Title_Spanish__c;
                    msgRecord.notificationCode__c = metadataForCurApp.Code__c;
                    //msgRecord.MessageCreateDate__c = System.today();
                    msgRecord.MessageCreateDate__c = SSP_Utility.today();
                    msgRecord.Severity__c = metadataForCurApp.Severity__c;
                    msgRecord.Status__c = SSP_GlobalConstants.NOTIFICATION_ACTIVE;
                    //385343 385345
                    msgRecord.Notification_Body__c = String.format(metadataForCurApp.Body__c,new list<string>{String.valueof(appObj.get('ProgramsApplied__c')),String.valueof(msgRecord.Expiry_Date__c.month() + '/' + msgRecord.Expiry_Date__c.day() + '/' + msgRecord.Expiry_Date__c.year())});
                    msgRecord.Notification_Body_Es__c = String.format(metadataForCurApp.Body_Spanish__c,new list<string>{String.valueof(appObj.get('ProgramsApplied__c')),String.valueof(msgRecord.Expiry_Date__c.month() + '/' + msgRecord.Expiry_Date__c.day() + '/' + msgRecord.Expiry_Date__c.year())});
                    
                    msgRecord.Reminder_Date__c = (msgRecord.dueDate__c.addDays(Integer.valueOf(metadataForCurApp.Send_Reminder_Criteria__c))).Date();
                    //msgRecord.recipientId__c = (Integer.valueOf((String)(demographicMap.get(docObj.CreatedById)).get('recipientId')));
                    msgRecord.recipientId__c = (String)(demographicMap.get(primaryIndividualId.ssp_member__r.individualid__c)).get('recipientId');                    
                    msgRecord.recipientType__c = (String)(demographicMap.get(primaryIndividualId.ssp_member__r.individualid__c)).get('recipientType');
                    notificationList.add(msgRecord);
                }
			}
			
            Database.insert(notificationList,false); 
            /*
            *   prepare SMS and/or Email, using document detail, metadata, demographicMap prepaared & updated notification
            */
            for(SSP_Notifications__c notificationRec: notificationList){
                SSP_Application__c appObj = idToObjAppMap.get(notificationRec.Linked_Record_Id__c);
                SSP_Message_Center_Configuration__mdt metadataForCurDoc = notifMetatdataList[0];
                Date expiryDate = (notificationRec.dueDate__c).date();
                String bodyLocal;
                String mobilebody;
                String titleLocal;
                Boolean isSendSMS = false;
                Boolean isSendEmail = false;
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('locale') == SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH){
                    bodyLocal = metadataForCurDoc.Communication_Body_Spanish__c;
                    mobilebody = metadataForCurDoc.Communication_Body_Spanish__c;
                    titleLocal = metadataForCurDoc.Title_Spanish__c;
                }else{
                    bodyLocal = metadataForCurDoc.Communication_Body__c;
                    mobilebody = metadataForCurDoc.Communication_Body__c;
                    titleLocal = metadataForCurDoc.Title__c;
                }
               // bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + bodyLocal +SSP_GlobalConstants.MESSAGE_FOOTER;
               bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + string.format(bodyLocal,new list<string>{appObj.ProgramsApplied__c,String.valueOf(expiryDate.month() + '/'+ expiryDate.day() + '/' + expiryDate.year())})+SSP_GlobalConstants.MESSAGE_FOOTER; 
               mobilebody = string.format(mobilebody,new list<string>{appObj.ProgramsApplied__c,String.valueOf(expiryDate.month() + '/'+ expiryDate.day() + '/' + expiryDate.year())}); 
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_EE){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_ES){
                    isSendSMS = true;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_P){
                    isSendSMS = false;
                    isSendEmail = false;
                }
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == SSP_GlobalConstants.MESSAGE_EE){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == 'Email'){
                    isSendSMS = false;
                    isSendEmail = true;
                }
                if((String)(demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') == 'Mobile Phone'){
                    isSendSMS = true;
                    isSendEmail = false;
                }
                if(isSendSMS){
                    CommunicationLog__c commRec = new CommunicationLog__c();
                    commRec.Send_SMS__c = true;
                    commRec.SendMail__c = false;
                    commRec.TemplateBody__c = mobilebody;
                    commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    commRec.Recipient_Phone_Number__c = (String)(demographicMap.get(notificationRec.recipientId__c)).get('phone');
                    commRec.TriggeredRecordId__c = notificationRec.Id;
                    commList.add(commRec);
                }
                if(isSendEmail){
                    CommunicationLog__c commRec = new CommunicationLog__c();
                    commRec.EmailSubject__c = String.format(SSP_GlobalConstants.MESSAGE_SUBJECT,new list<string>{titleLocal});
                    commRec.Send_SMS__c = false;
                    commRec.SendMail__c = true;
                    commRec.TemplateBody__c = bodyLocal;
                    commRec.ToEmail__c = (String)(demographicMap.get(notificationRec.recipientId__c)).get('email');
                    commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    commRec.TriggeredRecordId__c = notificationRec.Id;
                    commList.add(commRec);
                }
            }
            Database.insert(commList,false);               
            //380574 fix
            if(updateApplicationsList != null && !updateApplicationsList.isEmpty()){
                Database.update(updateApplicationsList, false); 
           }     
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterApplicationNotify', 'execute', ex.getMessage() , true);
        } 
    }   
  
    global void finish(Database.BatchableContext bc){
        
    }    
    
    global void execute(SchedulableContext sc) {
        SSP_MessageCenterApplicationNotify batchObj = new SSP_MessageCenterApplicationNotify();
        database.executebatch(batchObj);
    }

}