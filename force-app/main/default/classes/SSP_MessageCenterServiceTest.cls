@isTest
public class SSP_MessageCenterServiceTest {
    @testSetup static void userData(){
        //  SSP_TestDataFactory.setupTestData();
        List<Account> accList = SSP_TestDataFactory.createAccounts(1, false);
        Account acc = accList.get(0);
        insert acc;
        
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('Citizen', 'User', 'citizen@abc.xyz1', contactRecordTypeId, false);
        objCitizenContact.accountId = acc.Id;
        insert objCitizenContact;
        User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen@abc.xyz1', 'RE Citizen Profile', true);
        
        AppConfig__c timerValue = new AppConfig__c();
        List <AppConfig__c> delaytimer = new List<AppConfig__c>();
        timerValue.Name = 'AssisterTimerConfig';
        timerValue.Value__c = '3';
        delaytimer.add(timerValue);
        insert delaytimer;
        
    }
    @isTest static void processNotificationMessageTest(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz1' LIMIT 1][0]; 
        system.runAs(citizen){
            map<string,object> mapInputData = new map<string,object>();
            String identifier = SSP_GlobalConstants.SF_TOD_002;
            String NOT002_003 = SSP_GlobalConstants.SF_NOT_002;
            String TOD_003 = SSP_GlobalConstants.SF_TOD_003;
            mapInputData.put('recipientId', '919221392');
            mapInputData.put('recipientType', 'Citizen_Individual');
            //  mapInputData.put('acrId', '07kr000000BdPqk');
            mapInputData.put('preferredCommunication', 'ES');
            mapInputData.put('preferredWrittenLanguageCode', '1');
            mapInputData.put('phone', '(444) 444-1111');
            mapInputData.put('email', 'test@gmail.com');
            mapInputData.put('citizenFirstName', 'fake');
            mapInputData.put('nameCitizen', 'account'); 
            mapInputData.put('nameNonCitizen', 'fake account');
            mapInputData.put('programs', 'Medicaid/KCHIP');
            mapInputData.put('permissions', 'Apply , Report Changes , Recertify');
            mapInputData.put('sourceTodoCode',SSP_GlobalConstants.SF_TOD_002);
            test.startTest();
            SSP_MessageCenterService.processNotificationMessage(identifier , mapInputData);
            SSP_MessageCenterService.processNotificationMessage(NOT002_003 , mapInputData);
            SSP_MessageCenterService.processNotificationMessage(TOD_003 , mapInputData);
            test.stopTest();
        }
        
    }
    
        @isTest static void processNotificationMessageTest_otherRole(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz1' LIMIT 1][0]; 
        system.runAs(citizen){
            map<string,object> mapInputData = new map<string,object>();
            String identifier = SSP_GlobalConstants.SF_TOD_002;
            String NOT002_003 = SSP_GlobalConstants.SF_NOT_002;
            String TOD_003 = SSP_GlobalConstants.SF_TOD_003;
            mapInputData.put('recipientId', '919221392');
            mapInputData.put('recipientType', SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING);
            //  mapInputData.put('acrId', '07kr000000BdPqk');
            mapInputData.put('preferredCommunication', 'EE');
            mapInputData.put('preferredWrittenLanguageCode', '1');
            mapInputData.put('phone', '(444) 444-1111');
            mapInputData.put('email', 'test@gmail.com');
            mapInputData.put('citizenFirstName', 'fake');
            mapInputData.put('nameCitizen', 'account'); 
            mapInputData.put('nameNonCitizen', 'fake account');
            mapInputData.put('programs', 'Medicaid/KCHIP');
            mapInputData.put('permissions', 'Apply , Report Changes , Recertify');
            mapInputData.put('sourceTodoCode',SSP_GlobalConstants.SF_TOD_002);
            test.startTest();
            SSP_MessageCenterService.processNotificationMessage(identifier , mapInputData);
            SSP_MessageCenterService.processNotificationMessage(NOT002_003 , mapInputData);
             mapInputData.put('preferredWrittenLanguageCode', '4');
            SSP_MessageCenterService.processNotificationMessage(TOD_003 , mapInputData);
            test.stopTest();
        }
        
    }
    
}