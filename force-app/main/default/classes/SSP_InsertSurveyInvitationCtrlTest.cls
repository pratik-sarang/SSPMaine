@isTest
public class SSP_InsertSurveyInvitationCtrlTest {
    @testSetup static void testData(){
        
        map<string,object> mapInputData = new map<string,object>();
        String identifier = SSP_GlobalConstants.SF_TOD_003;
        mapInputData.put('recipientId', '919221392');
        mapInputData.put('recipientType', 'Citizen_Individual');
        //  mapInputData.put('acrId', '07kr000000BdPqk');
        mapInputData.put('preferredCommunication', 'ES');
        mapInputData.put('preferredWrittenLanguageCode', '1');
        mapInputData.put('phone', '(272) 207-2369');
        mapInputData.put('email', 'test@gmail.com');
        mapInputData.put('citizenFirstName', 'Harry');
        mapInputData.put('nameCitizen', 'Potter'); 
        mapInputData.put('nameNonCitizen', 'Harry Potter');
        mapInputData.put('programs', 'Medicaid/KCHIP');
        mapInputData.put('permissions', 'Apply , Report Changes , Recertify');
        
        SSP_Notifications__c msgRecord = new SSP_Notifications__c();
        //  List<SSP_Message_Center_Configuration__mdt> msgCenterMdt = new list<SSP_Message_Center_Configuration__mdt>();
        String locale;
        SSP_Message_Center_Configuration__mdt msgCenterMdt = [select Id, Code__c, Body__c, Body_Spanish__c, Title__c, 
                                                              Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
                                                              Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c
                                                              from SSP_Message_Center_Configuration__mdt 
                                                              where DeveloperName =:identifier];
        
        msgRecord.recipientId__c = (String)mapInputData.get('recipientId');
        // msgRecord.Linked_Record_Id__c = ((String)inputData.get('acrId'));
        msgRecord.messageSubject__c = msgCenterMdt.Title__c;
        msgRecord.messageSubjectES__c = msgCenterMdt.Title_Spanish__c;
        msgRecord.notificationCode__c = msgCenterMdt.Code__c;
        msgRecord.MessageCreateDate__c = SSP_Utility.today();
        msgRecord.Severity__c = msgCenterMdt.Severity__c;
        msgRecord.Status__c = SSP_GlobalConstants.NOTIFICATION_ACTIVE;
        msgRecord.Notification_Body__c = String.format(msgCenterMdt.Body__c,new list<string>{(String)mapInputData.get('nameNonCitizen'),(String)mapInputData.get('programs')});
        msgRecord.Notification_Body_Es__c = String.format(msgCenterMdt.Body_Spanish__c,new list<string>{(String)mapInputData.get('nameNonCitizen'),(String)mapInputData.get('programs')});
        msgRecord.RecordTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
        msgRecord.recipientType__c = SSP_GlobalConstants.NOTIFICATION_CITIZEN;
        msgRecord.dueDate__c = msgRecord.MessageCreateDate__c.addDays(Integer.valueOf(msgCenterMdt.Due_Date_criterion__c));
        msgRecord.Reminder_Date__c = (Date.valueOf(msgRecord.dueDate__c)).addDays(Integer.valueOf(msgCenterMdt.Send_Reminder_Criteria__c));
        insert msgRecord;
        
        AppConfig__c timerValue = new AppConfig__c();
        List <AppConfig__c> delaytimer = new List<AppConfig__c>();
        timerValue.Name = 'AssisterTimerConfig';
        timerValue.Value__c = '3';
        delaytimer.add(timerValue);
        insert delaytimer;
        
        List<Account> accList = SSP_TestDataFactory.createAccounts(1, false);
        Account acc = accList.get(0);
        insert acc;
        
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('Citizen', 'User', 'citizen@abc.xyz1', contactRecordTypeId, false);
        objCitizenContact.accountId = acc.Id;
        insert objCitizenContact;
        User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen@abc.xyz1', 'RE Citizen Profile', true);
        
    }
    @isTest static void saveSurveyInvitationTest(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz1' LIMIT 1][0]; 
        Map<String , object>mapInputData = new Map<String , Object>();
        mapInputData.put('preferredCommunication','ES');
        ID notificID = [select id from ssp_notifications__c where recipientId__c = '919221392' LIMIT 1].id;
        ssp_notifications__c notificRec = [select Id , recipientId__c , messageSubject__c , messageSubjectES__c ,  Notification_Body__c , Notification_Body_Es__c from ssp_notifications__c where id=:notificID LIMIT 1];
        system.runAs(citizen){   
            test.startTest();
            SSP_InsertSurveyInvitationCtrl.saveSurveyInvitation('Kynector Access Request', notificID,'SSP_Notifications__c',true, false,'Benefind');
            string surveyLink = SSP_InsertSurveyInvitationCtrl.saveSurveyInvitation('Kynector Access Request', notificID,'SSP_Notifications__c',true, false,'Benefind');
            SSP_messageUtility.sendCommunnication(surveyLink , (String)mapInputData.get('preferredCommunication') , null,(String)mapInputData.get('phone') , (String)mapInputData.get('email'),notificRec.Notification_Body__c,
                                                  notificRec.Notification_Body_Es__c,null,null,notificID,(String)mapInputData.get('citizenFirstName'));/*String title, String titleSpanish*/
            test.stopTest();
        }
    }
}