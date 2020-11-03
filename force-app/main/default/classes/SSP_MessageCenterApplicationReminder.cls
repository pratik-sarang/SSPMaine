global class SSP_MessageCenterApplicationReminder implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date reminderDate=SSP_Utility.today();
        // Fix 382061 - added status should be active condition
        String activeState = SSP_GlobalConstants.NOTIFICATION_ACTIVE;
        List<String> notificCodes = new List<String>{'SF-TOD-001','SF-TOD-002','SF-TOD-003','SF-TOD-004-DocCenter','SF-TOD-005-DocCenter','SF-TOD-004-Hearing','SF-TOD-005-Hearing'}; 
            string query = 'select Id,dueDate__c,Expiry_Date__c,Linked_Record_Id__c,'+
            'messageSubject__c,messageSubjectES__c,Notification_Body__c,Notification_Body_Es__c,Program_Code__c,recipientId__c,'+
            'recipientType__c,MessageCreateDate__c,Status__c,notificationCode__c,Reminder_Date__c,dmsDocumentId__c'+
            ' from SSP_Notifications__c '+
            'where Reminder_Date__c= :reminderDate and notificationCode__c IN :notificCodes and Status__c = :activeState';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SSP_Notifications__c> notificRecords){
        List<SSP_Message_Center_Configuration__mdt> notifMetatdataList = new List<SSP_Message_Center_Configuration__mdt>();
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        List<CommunicationLog__c> commStatusList = new List<CommunicationLog__c>();
        Map<String,SSP_Application__c> userToAppDetailMap = new Map<String,SSP_Application__c>();
        Map<string,map<string,object>> demographicMap = new Map<string,map<string,object>>();
        Map<string,SSP_Notifications__c> notificationDetails = new Map<string,SSP_Notifications__c>();
        Set<String> recepientIds = new Set<String>();
        Set<String> notificIds = new Set<String>();
        Set<String> linkedRecIds = new Set<String>();
        Set<String> docDetailRecIds = new Set<String>();
        Set<String> docDetails_Hearing = new Set<String>();//defect 393075
        Set<String> Hearing_Ids = new Set<String>();//defect 393075
        Set<String> ACRRecIds = new Set<String>();
        Map<String ,SSP_Message_Center_Configuration__mdt> metaDataRec = new Map<String ,SSP_Message_Center_Configuration__mdt>();
        try{
            
            notifMetatdataList= [select Id, DeveloperName, Code__c, Body__c, Body_Spanish__c, Title__c, 
                                 Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
                                 Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c
                                 from SSP_Message_Center_Configuration__mdt 
                                 where (DeveloperName = :SSP_GlobalConstants.SF_TOD_001)
                                 OR
                                 (DeveloperName = :SSP_GlobalConstants.SF_TOD_002)
                                 OR
                                 (DeveloperName = :SSP_GlobalConstants.SF_TOD_003)
                                 OR
                                 (DeveloperName = :SSP_GlobalConstants.SF_TOD_004_DOCCENTER)
                                 OR
                                 (DeveloperName = :SSP_GlobalConstants.SF_TOD_005_DOCCENTER)
                                 OR
                                 (DeveloperName = 'SF_TOD_004_Hearing')
                                 OR
                                 (DeveloperName = 'SF_TOD_005_Hearing')];
            for(SSP_Message_Center_Configuration__mdt metadataValues : notifMetatdataList){
                metaDataRec.put(metadataValues.Code__c,metadataValues);
            }
            //to get the primary individual against an application from notification
            for(SSP_Notifications__c linkRecIds :notificRecords){
                if(linkRecIds.notificationCode__c == 'SF-TOD-001'){
                    linkedRecIds.add(linkRecIds.Linked_Record_Id__c);
                    
                }else if(linkRecIds.notificationCode__c == 'SF-TOD-003'){
                    ACRRecIds.add(linkRecIds.Linked_Record_Id__c);
                    notificIds.add(linkRecIds.id);
                }
                else if(linkRecIds.notificationCode__c == 'SF-TOD-002'){
                    ACRRecIds.add(linkRecIds.Linked_Record_Id__c);
                }
                else if((linkRecIds.notificationCode__c == 'SF-TOD-004-DocCenter') ||
                        (linkRecIds.notificationCode__c == 'SF-TOD-005-DocCenter')){
                            docDetailRecIds.add(linkRecIds.Linked_Record_Id__c);
                        }
                // for defect fix 393075 -- start
                else if((linkRecIds.notificationCode__c == 'SF-TOD-004-Hearing') || (linkRecIds.notificationCode__c == 'SF-TOD-005-Hearing')){
                    docDetails_Hearing.add(linkRecIds.Linked_Record_Id__c);
                }
            }
            if(docDetails_Hearing.size()>0){
            for(String requestno : docDetails_Hearing){
                List<String> hearing_id_number = new List<String>();
                hearing_id_number = requestno.split('-');
                Hearing_Ids.add(hearing_id_number[0]);
            }
        }
        // for defect fix 393075 -- end
            Map<Id,SSP_Application__c> applicationData = new Map<ID,SSP_Application__c>([select Id,ToLabel(ProgramsApplied__c) from SSP_Application__c where id IN:linkedRecIds]);
            Map<Id,AccountContactRelation> acrDetails = new Map<Id,AccountContactRelation>([SELECT Id, RequestAccessPermission__c, ToLabel(ProgramsApplied__c),ToLabel(PermissionLevel_Medicaid__c), ToLabel(PermissionLevel_SNAP__c), ToLabel(PermissionLevel_StateSupp__c),ToLabel(PermissionLevel_KIHIPP__c), ToLabel(PermissionLevel_KTAP__c),ToLabel(PermissionLevel_CCAP__c),contact.name FROM AccountContactRelation where Id IN:ACRRecIds]);
            Map<Id,DocumentDetail__c> docDetails = new Map<Id,DocumentDetail__c>([select id , name from DocumentDetail__c where Id IN:docDetailRecIds]);
            Map<String,DocumentDetail__c> Hearing_Doc_Details = new Map<String,DocumentDetail__c>(); // for defect fix 393075 -- start
            for(DocumentDetail__c hearing_details : [select Hearing_Id__c , name from DocumentDetail__c where Hearing_Id__c IN:Hearing_Ids]){
                Hearing_Doc_Details.put(hearing_details.Hearing_Id__c,hearing_details);
            }
            // for defect fix 393075 -- end
            List<SurveyInvitation> updateTime = new List<SurveyInvitation>();
            List<SObject> surveyCommRec = new list<SObject>();
            map<string,CommunicationLog__c> notificationToCommMap = new map<string,CommunicationLog__c>();
            // fix 390713
            map<string,CommunicationLog__c> notificationToCommMapSMS = new map<string,CommunicationLog__c>();

            // for fix 385344
            // For SF-TOD-003 fetch original nub records
            if(notificIds != null && !notificIds.isEmpty())
            {
                for(CommunicationLog__c commRecords : [select id , Send_SMS__c,SendMail__c,TemplateBody__c,Status__c ,Recipient_Phone_Number__c, TriggeredRecordId__c,ToEmail__c,EmailSubject__c,processed_reminder_batch__c from CommunicationLog__c where TriggeredRecordId__c IN:notificIds]){
                    // fix 390713
                    if(commRecords.TriggeredRecordId__c != null && commRecords.SendMail__c)
                    {
                        notificationToCommMap.put(commRecords.TriggeredRecordId__c,commRecords);
                    }
                    // fix 390713 - start
                    if(commRecords.TriggeredRecordId__c != null && commRecords.Send_SMS__c)
                    {
                        notificationToCommMapSMS.put(commRecords.TriggeredRecordId__c,commRecords);
                    }
                    // fix 390713 - end
                }

                for(SurveyInvitation resendSurvey : [select id , name , InviteExpiryDateTime from surveyinvitation where ssp_notifications__c IN:notificIds]){
                    AppConfig__c delaytimer = AppConfig__c.getValues('AssisterTimerConfig');
                    // Integer delayTime=Integer.valueof(System.Label.SurveyExpirationTime);
                    Integer delayTime=Integer.valueof(delaytimer.Value__c);
                    resendSurvey.InviteExpiryDateTime=Datetime.now().addMinutes(delayTime);
                    updateTime.add(resendSurvey);
                    surveyCommRec.add((Sobject)resendSurvey);
                }
            }

            for(SSP_Notifications__c notifyRecs : notificRecords){
                if(notifyRecs.notificationCode__c == 'SF-TOD-001'){ // for defect fix 393075
                if(applicationData != null && applicationData.containsKey(notifyRecs.Linked_Record_Id__c)){
                    userToAppDetailMap.put(notifyRecs.recipientId__c,applicationData.get(notifyRecs.Linked_Record_Id__c));
                }
            }
                recepientIds.add(notifyRecs.recipientId__c);
            }

            //get the communication details and language for the individual
            if(recepientIds.size()>0){
                for(SSP_Member__c curMem : [select id, IndividualId__c, PreferredWrittenLanguageCode__c, PreferredNotificationMethodCode__c, PrimaryPhoneNumber__c, Email__c,contact__r.name
                                            from SSP_Member__c 
                                            where IndividualId__c IN :recepientIds]){
                                                
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
            }
            //prepare communication data to be sent via sms/email
            for(SSP_Notifications__c notificationRec: notificRecords){
                SSP_Application__c appliDetails = userToAppDetailMap.get(notificationRec.recipientid__c);
                //385343
                Date expiryDate = notificationRec.Expiry_Date__c;
                SSP_Message_Center_Configuration__mdt metadataForCurDoc = metaDataRec.get(notificationRec.notificationCode__c);

                if(notificationRec.notificationCode__c == 'SF-TOD-003' 
                    && notificationToCommMap != null
                    // fix 390713
                    &&    notificationToCommMap.get(notificationRec.Id) != null)
                {
                    // fix 390713
                    CommunicationLog__c commRecords=   notificationToCommMap.get(notificationRec.Id);
                    CommunicationLog__c newCommRec = new CommunicationLog__c();
                    newCommRec.Send_SMS__c = commRecords.Send_SMS__c;
                    newCommRec.SendMail__c = commRecords.SendMail__c;
                    newCommRec.TemplateBody__c = commRecords.TemplateBody__c;
                    newCommRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    newCommRec.Recipient_Phone_Number__c = commRecords.Recipient_Phone_Number__c;
                    newCommRec.TriggeredRecordId__c = commRecords.TriggeredRecordId__c;
                    newCommRec.ToEmail__c = commRecords.ToEmail__c;
                    newCommRec.EmailSubject__c = commRecords.EmailSubject__c;
                    commList.add(newCommRec);
                }
                // fix 390713 - start
                if(notificationRec.notificationCode__c == 'SF-TOD-003' 
                    && notificationToCommMapSMS != null
                    &&    notificationToCommMapSMS.get(notificationRec.Id) != null)
                {
                    CommunicationLog__c commRecords=   notificationToCommMapSMS.get(notificationRec.Id);
                    CommunicationLog__c newCommRec = new CommunicationLog__c();
                    newCommRec.Send_SMS__c = commRecords.Send_SMS__c;
                    newCommRec.SendMail__c = commRecords.SendMail__c;
                    newCommRec.TemplateBody__c = commRecords.TemplateBody__c;
                    newCommRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                    newCommRec.Recipient_Phone_Number__c = commRecords.Recipient_Phone_Number__c;
                    newCommRec.TriggeredRecordId__c = commRecords.TriggeredRecordId__c;
                    newCommRec.ToEmail__c = commRecords.ToEmail__c;
                    newCommRec.EmailSubject__c = commRecords.EmailSubject__c;
                    commList.add(newCommRec);
                }
                // fix 390713 - end

                // Fix 382061 - null check for recipient demographic details
                if(metadataForCurDoc!=null && demographicMap.get(notificationRec.recipientId__c) != null){
                    String bodyLocal;
                    String mobilebody;
                    String titleLocal;
                    Boolean isSendSMS = false;
                    Boolean isSendEmail = false;

                    // Fix 382061 - null for locale
                    if((demographicMap.get(notificationRec.recipientId__c)).get('locale') != null && 
                        (String)(demographicMap.get(notificationRec.recipientId__c)).get('locale') == SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH)
                    {
                        bodyLocal = metadataForCurDoc.Communication_Body_Spanish__c;
                        mobilebody = metadataForCurDoc.Communication_Body_Spanish__c;
                        titleLocal = metadataForCurDoc.Title_Spanish__c;
                    }else{
                        bodyLocal = metadataForCurDoc.Communication_Body__c;
                        mobilebody = metadataForCurDoc.Communication_Body__c;
                        titleLocal = metadataForCurDoc.Title__c;
                    }
                    
                    // Fix 382061 - null check for demographic name
                    if((demographicMap.get(notificationRec.recipientId__c)).get('name') != null)
                    {
                        //different communication body for different nnotifications
                        if((notificationRec.notificationCode__c == 'SF-TOD-004-DocCenter' )|| 
                        (notificationRec.notificationCode__c == 'SF-TOD-005-DocCenter' )){
                            
                            DocumentDetail__c docname =  docDetails.get(notificationRec.Linked_Record_Id__c);   
                            bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + string.format(bodyLocal,new list<string>{docname.name})+SSP_GlobalConstants.MESSAGE_FOOTER;
                            mobilebody = string.format(mobilebody,new list<string>{docname.name});
                        }
                        // defect 393075 -- start
                        else if(notificationRec.notificationCode__c == 'SF-TOD-004-Hearing'  || notificationRec.notificationCode__c == 'SF-TOD-005-Hearing' ){
                            if(notificationRec.Linked_Record_Id__c!=null && Hearing_Doc_Details.size()>0){
                            List<String> hearing_request_no = (notificationRec.Linked_Record_Id__c).split('-');
                            String hearing_details_key = hearing_request_no[0];
                            DocumentDetail__c docname =  Hearing_Doc_Details.get(hearing_details_key);   
                            bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + string.format(bodyLocal,new list<string>{docname.name})+SSP_GlobalConstants.MESSAGE_FOOTER;
                            mobilebody = string.format(mobilebody,new list<string>{docname.name});
                            } // defect 393075 -- end
                        }else if(notificationRec.notificationCode__c == 'SF-TOD-001'){
                            
                                // Fix 382061 - null check for appliDetails
                            if(appliDetails != null && appliDetails.id == notificationRec.Linked_Record_Id__c){
                                bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + string.format(bodyLocal,new list<string>{appliDetails.ProgramsApplied__c,String.valueOf(expiryDate.month() + '/'+ expiryDate.day() + '/' + expiryDate.year())})+SSP_GlobalConstants.MESSAGE_FOOTER;
                                mobilebody = string.format(mobilebody,new list<string>{appliDetails.ProgramsApplied__c,String.valueOf(expiryDate.month() + '/'+ expiryDate.day() + '/' + expiryDate.year())}); // for defect fix Defect18
                            }
                            
                        }
                        else if(notificationRec.notificationCode__c == 'SF-TOD-002'  && acrDetails != null){
                            String sProgramVsPermision = '';
                            String sReqPrgm = '';
                            Map<String, String> mapProgramCode = new Map<String, String>{'PermissionLevel_CCAP__c' => SSP_GlobalConstants.CC_Label,
                                'PermissionLevel_KTAP__c' => SSP_GlobalConstants.KT_Label,
                                'PermissionLevel_SNAP__c' => SSP_GlobalConstants.SN_Label,
                                'PermissionLevel_KIHIPP__c' => SSP_GlobalConstants.KP_Label,
                                'PermissionLevel_Medicaid__c' =>SSP_GlobalConstants.MA_Label };
                         
                             List<String> msgBody  = new List<String>(); 
                            
                            Map<String,String> permissionMap = SSP_Utility.getPickListValues('AccountContactRelation','PermissionLevel_CCAP__c',null);
                            
                            AccountContactRelation ACR = acrDetails.get(notificationRec.Linked_Record_Id__c);
                            // Fix 382061
                            if(ACR!=null && ACR.RequestAccessPermission__c!=null)
                            {   
                                Map<String, Object> mapProgramPermission = (Map<String, Object>)JSON.deserializeUntyped(ACR.RequestAccessPermission__c);                               
                                map<string,string> permissionAPIToLabelMap = new map<string,string>{'ST'=>'Apply, Report Changes, Recertify','NT'=>'Apply, Report Changes, Recertify and receive copy of Notices','SE'=>'Apply, Report Changes, Recertify and use EBT Card','CC'=>'Apply, Report Change, Recertify and receive checks made out to client','CA'=>'Apply, Report Change, Recertify and receive checks','ET'=>'Use EBT Card','PY'=>'Statutory Benefit Payee'};
                                    sProgramVsPermision = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ? SSP_GlobalConstants.MA_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_Medicaid__c'))+'<br/>' : '';
                                sProgramVsPermision += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SN_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_SNAP__c'))+'<br/>' : '';
                                sProgramVsPermision += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.SS_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_StateSupp__c'))+'<br/>' : '';
                                sProgramVsPermision += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KP_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_KIHIPP__c'))+'<br/>' : '';
                                sProgramVsPermision += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KT_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_KTAP__c'))+'<br/>' : '';
                                sProgramVsPermision += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CC_Label+'-'+permissionAPIToLabelMap.get((string)mapProgramPermission.get('PermissionLevel_CCAP__c'))+'<br/>' : '';
                            
                                sReqPrgm = mapProgramPermission.get('PermissionLevel_Medicaid__c') != null ? SSP_GlobalConstants.MA_Label+',' : '';
                                sReqPrgm += mapProgramPermission.get('PermissionLevel_SNAP__c') != null ? SSP_GlobalConstants.SN_Label+',' : '';
                                sReqPrgm += mapProgramPermission.get('PermissionLevel_StateSupp__c') != null ? SSP_GlobalConstants.SS_Label+',' : '';
                                sReqPrgm += mapProgramPermission.get('PermissionLevel_KIHIPP__c') != null ? SSP_GlobalConstants.KP_Label+',' : '';
                                sReqPrgm += mapProgramPermission.get('PermissionLevel_KTAP__c') != null ? SSP_GlobalConstants.KT_Label+',' : '';
                                sReqPrgm += mapProgramPermission.get('PermissionLevel_CCAP__c') != null ? SSP_GlobalConstants.CC_Label+',' : ''; 
                                sReqPrgm = sReqPrgm.removeEnd(',');
                                msgBody.add(ACR.contact.name);                                
                                msgBody.add(sReqPrgm);
                                msgBody.add(sProgramVsPermision);
                                String navigateToBenefind = 'https://'+System.label.SSP_MessageCenter_CommunicationURL;
                                String benefindURL = ' <a href ='+ navigateToBenefind + '>'+ System.label.SSP_MessageCenter_CommunicationURL+ '</a>';
                                msgBody.add(benefindURL);                                                               
                    
                                bodyLocal = String.format(SSP_GlobalConstants.MESSAGE_HEADER,new list<string>{(String)(demographicMap.get(notificationRec.recipientId__c)).get('name')}) + string.format(bodyLocal,msgBody)+SSP_GlobalConstants.MESSAGE_FOOTER;
                                mobilebody = string.format(bodyLocal,msgBody);
                            } 
                        }
                    }  

                    // Fix 382061 - null check for preferredCommunication demographic
                    if((demographicMap.get(notificationRec.recipientId__c)).get('preferredCommunication') != null)
                    {
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
                    }
                    
                    if(notificationRec.notificationCode__c!='SF-TOD-003'){
                        // Fix 382061 - null check for phone
                        if(isSendSMS && (demographicMap.get(notificationRec.recipientId__c)).get('phone') != null){
                            CommunicationLog__c commRec = new CommunicationLog__c();
                            commRec.Send_SMS__c = true;
                            commRec.SendMail__c = false;
                            commRec.TemplateBody__c = mobilebody;
                            commRec.Status__c = SSP_GlobalConstants.IN_PROGRESS_STATUS;
                            commRec.Recipient_Phone_Number__c = (String)(demographicMap.get(notificationRec.recipientId__c)).get('phone');
                            commRec.TriggeredRecordId__c = notificationRec.Id;
                            commList.add(commRec);
                           
                        }
                        // Fix 382061 - null check for email
                        if(isSendEmail && (demographicMap.get(notificationRec.recipientId__c)).get('email') != null){
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
                }
                
            }
            // Fix 382061
            if(commList != null && commList.size() > 0)
            {
                Database.insert(commList,false);            
               
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterApplicationReminder', 'execute', ex.getMessage() , true);
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext sc) {
        SSP_MessageCenterApplicationReminder batchObj = new SSP_MessageCenterApplicationReminder();
        database.executebatch(batchObj);
    }
}