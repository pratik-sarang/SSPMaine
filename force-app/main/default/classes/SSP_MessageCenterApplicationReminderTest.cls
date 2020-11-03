@isTest
public class SSP_MessageCenterApplicationReminderTest {
    @isTest
    private static void testMessageCenterApplicationReminder(){
        
        Test.enableChangeDataCapture();

        List<SSP_Notifications__c> notificationList = new List<SSP_Notifications__c>();
        Id recordTypeIdNotification = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
        
        List<Account> accList = SSP_TestDataFactory.createAccounts(5,true);
        List<Contact> conList = SSP_TestDataFactory.createContacts(5,false);
        
        Id sAppAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
        List<Account> appAccount = SSP_TestDataFactory.createAccounts(1,true,sAppAccRecTypeId);
        
        Account accRecord = new account();
        accRecord.Name = 'Test Acc1114';
        insert accRecord;
        conList[0].AccountId = accRecord.Id;
        
        Account accRecord2 = new account();
        accRecord2.Name = 'Test Acc1115';
        insert accRecord2;
        conList[1].AccountId = accRecord2.Id;
        
        Account accRecord3 = new account();
        accRecord3.Name = 'Test Acc1116';
        insert accRecord3;
        conList[2].AccountId = accRecord3.Id;
        
        Account accRecord4 = new account();
        accRecord4.Name = 'Test Acc1117';
        insert accRecord4;
        conList[3].AccountId = accRecord4.Id;
        
        Account accRecord5 = new account();
        accRecord5.Name = 'Test Acc1118';
        insert accRecord5;
        conList[4].AccountId = accRecord5.Id;
        
        insert conList;
        AccountContactRelation conAccList = SSP_TestDataFactory.createAccountContactRelationshipRecord(conList[0].Id,accList[0].Id,true);
        conAccList.RequestAccessPermission__c='{   "PermissionLevel_CCAP__c": "PY",   "PermissionLevel_KTAP__c": "ET",   "PermissionLevel_SNAP__c": "SE",   "PermissionLevel_KIHIPP__c": "ST",   "PermissionLevel_Medicaid__c": "NT" }';
        Update conAccList;
        AccountContactRelation conAccList2 = SSP_TestDataFactory.createAccountContactRelationshipRecord(conList[1].Id,accList[1].Id,true);
        conAccList2.RequestAccessPermission__c='{   "PermissionLevel_CCAP__c": "PY",   "PermissionLevel_KTAP__c": "ET",   "PermissionLevel_SNAP__c": "SE",   "PermissionLevel_KIHIPP__c": "ST",   "PermissionLevel_Medicaid__c": "NT" }';
        Update conAccList2;
        
        List<SSP_Application__c> sspApplication = SSP_TestDataFactory.createSSPApplications(1,false);
        sspApplication[0].Account__c = appAccount[0].Id;
        insert sspApplication;
        
        DocumentDetail__c docDetailRec = new DocumentDetail__c();
        docDetailRec.Name = 'download.png';
        insert docDetailRec;
        
        SSP_Notifications__c notifRec = new SSP_Notifications__c();
        notifRec.recordtypeid = recordTypeIdNotification;
        notifRec.recipientType__c = 'citizen';
        notifRec.recipientId__c = '999036538';
        notifRec.Status__c = 'Active';
        notifRec.Linked_Record_Id__c = String.valueOf(sspApplication[0].Id);
        notifRec.notificationCode__c = 'SF-TOD-001';
        notifRec.Reminder_Date__c = Date.today();
        notifRec.Expiry_Date__c = Date.today()+5;
        notificationList.add(notifRec);
        
        SSP_Notifications__c notifRec2 = new SSP_Notifications__c();
        notifRec2.recordtypeid = recordTypeIdNotification;
        notifRec2.recipientType__c = 'citizen';
        notifRec2.recipientId__c = '999036539';
        notifRec2.Status__c = 'Active';
        notifRec2.Linked_Record_Id__c = String.valueOf(conAccList.Id);
        notifRec2.notificationCode__c = 'SF-TOD-002';
        notifRec2.Reminder_Date__c = Date.today();
        notifRec2.Expiry_Date__c = Date.today()+5;
        notificationList.add(notifRec2);
        
        SSP_Notifications__c notifRec3 = new SSP_Notifications__c();
        notifRec3.recordtypeid = recordTypeIdNotification;
        notifRec3.recipientType__c = 'citizen';
        notifRec3.recipientId__c = '999036540';
        notifRec3.Status__c = 'Active';
        notifRec3.Linked_Record_Id__c = String.valueOf(conAccList2.Id);
        notifRec3.notificationCode__c = 'SF-TOD-003';
        notifRec3.Reminder_Date__c = Date.today();
        notifRec3.Expiry_Date__c = Date.today()+5;
        notificationList.add(notifRec3);
        
        SSP_Notifications__c notifRec4 = new SSP_Notifications__c();
        notifRec4.recordtypeid = recordTypeIdNotification;
        notifRec4.recipientType__c = 'citizen';
        notifRec4.recipientId__c = '999036541';
        notifRec4.Status__c = 'Active';
        notifRec4.Linked_Record_Id__c = String.valueOf(docDetailRec.Id);
        notifRec4.notificationCode__c = 'SF-TOD-004-DocCenter';
        notifRec4.Reminder_Date__c = Date.today();
        notifRec4.Expiry_Date__c = Date.today()+5;
        notificationList.add(notifRec4);
        
        SSP_Notifications__c notifRec5 = new SSP_Notifications__c();
        notifRec5.recordtypeid = recordTypeIdNotification;
        notifRec5.recipientType__c = 'citizen';
        notifRec5.recipientId__c = '999036542';
        notifRec5.Status__c = 'Active';
        notifRec5.Linked_Record_Id__c = String.valueOf(docDetailRec.Id);
        notifRec5.notificationCode__c = 'SF-TOD-005-Hearing';
        notifRec5.Reminder_Date__c = Date.today();
        notifRec5.Expiry_Date__c = Date.today()+5;
        notificationList.add(notifRec5);
        
        insert notificationList;
        
        CommunicationLog__c commRecords= new CommunicationLog__c();
        commRecords.Send_SMS__c=true;
        commRecords.SendMail__c=true;
        commRecords.TemplateBody__c='';
        commRecords.Status__c ='In Progress';
        commRecords.Recipient_Phone_Number__c='6667676787';
        commRecords.TriggeredRecordId__c=notifRec3.id;
        commRecords.ToEmail__c='test@test.com';
        commRecords.EmailSubject__c='asfkjasfkjasdnfkc';
        commRecords.processed_reminder_batch__c =true;
        insert commRecords;
        
        List<SSP_Member__c> sspMemberList = SSP_TestDataFactory.createSSPMembers(4,false);
        sspMemberList[0].IndividualId__c = '999036538';
        sspMemberList[0].PreferredWrittenLanguageCode__c = '1';
        sspMemberList[0].PreferredNotificationMethodCode__c = 'EE';
        sspMemberList[0].PrimaryPhoneNumber__c = '1112223334';
        sspMemberList[0].Email__c = '999036538fake@fake.com';
        sspMemberList[0].Contact__c = conList[0].Id;
        
        sspMemberList[1].IndividualId__c = '999036539';
        sspMemberList[1].PreferredWrittenLanguageCode__c = '4';
        sspMemberList[1].PreferredNotificationMethodCode__c = 'ES';
        sspMemberList[1].PrimaryPhoneNumber__c = '2222223334';
        sspMemberList[1].Email__c = '999036539fake@fake.com';
        sspMemberList[1].Contact__c = conList[1].Id;
        
        sspMemberList[2].IndividualId__c = '999036540';
        sspMemberList[2].PreferredWrittenLanguageCode__c = '1';
        sspMemberList[2].PreferredNotificationMethodCode__c = 'P';
        sspMemberList[2].PrimaryPhoneNumber__c = '3332223334';
        sspMemberList[2].Email__c = '999036540fake@fake.com';
        sspMemberList[2].Contact__c = conList[2].Id;
        
        sspMemberList[3].IndividualId__c = '999036541';
        sspMemberList[3].PreferredWrittenLanguageCode__c = '4';
        sspMemberList[3].PreferredNotificationMethodCode__c = 'EE';
        sspMemberList[3].PrimaryPhoneNumber__c = '4442223334';
        sspMemberList[3].Email__c = '999036541fake@fake.com';
        sspMemberList[3].Contact__c = conList[3].Id;
        
        sspMemberList[3].IndividualId__c = '999036542';
        sspMemberList[3].PreferredWrittenLanguageCode__c = '4';
        sspMemberList[3].PreferredNotificationMethodCode__c = 'EE';
        sspMemberList[3].PrimaryPhoneNumber__c = '4442223334';
        sspMemberList[3].Email__c = '999036542fake@fake.com';
        sspMemberList[3].Contact__c = conList[4].Id;
        
        insert sspMemberList;       
        
        AppConfig__c timerValue = new AppConfig__c();
        List <AppConfig__c> delaytimer = new List<AppConfig__c>();
        timerValue.Name = 'AssisterTimerConfig';
        timerValue.Value__c = '3';
        delaytimer.add(timerValue);
        insert delaytimer;
        
        Test.startTest();
        SSP_MessageCenterApplicationReminder msgCenterAppReminder = new SSP_MessageCenterApplicationReminder();
		Database.executeBatch(msgCenterAppReminder, 20);
        Test.stopTest();
       
    }
}