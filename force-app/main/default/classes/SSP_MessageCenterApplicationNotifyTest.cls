@isTest
public class SSP_MessageCenterApplicationNotifyTest {

    @testSetup
    static void testDataSetup(){
        SSP_TestDataFactory.setupTestData();
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'EnrollmentDetail';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        Date notifiyDate=Date.today().addDays(-Integer.valueOf(System.Label.Notify_Day_For_Application_Expire));
        DateTime createdDateTest=DateTime.newInstance(notifiyDate.year(), notifiyDate.month() , notifiyDate.day(), 10, 10, 0);
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id; 
        lstAppln[0].recordtypeid= Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'SN;KT;CC';
        lstAppln[0].SSPDCMessage__c = 'HBE1000';
        lstAppln[0].IsApplicationSubmittedEarly__c = 'Y';
        lstAppln[0].Status__c='UN';
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        Test.setCreatedDate(lstAppln[0].Id, createdDateTest);
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].contact__c=lstCon[0].Id;
        lstMem[0].IndividualId__c='1234';
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].PreferredWrittenLanguageCode__c='4';
        lstMem[0].PreferredNotificationMethodCode__c = SSP_GlobalConstants.MESSAGE_ES;
        
        lstMem[1].contact__c=lstCon[0].Id;
        lstMem[1].IndividualId__c='123454';
        lstMem[1].PrimaryPhoneExtension__c ='7348789790';
        lstMem[1].PrimaryPhoneNumber__c ='8983838290';
        lstMem[1].PreferredWrittenLanguageCode__c='1';
        lstMem[1].PreferredNotificationMethodCode__c = SSP_GlobalConstants.MESSAGE_EE;
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c=true;
        
        lstAppInd[1].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[1].SSP_Member__c=lstMem[1].Id;
        lstAppInd[1].IsHeadOfHousehold__c=true;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();        
     
    }
    
    @isTest
    static void messageCenterApplicationNotifyBatchTest(){
        test.startTest();
        SSP_MessageCenterApplicationNotify msgCenterObject = new SSP_MessageCenterApplicationNotify(); 
        Id batchId = Database.executeBatch(msgCenterObject);
        test.stopTest();
    }
    
    @isTest
    static void shouldScheduleBatchtest() { 
        test.startTest();
        SSP_MessageCenterApplicationNotify msgCenterObject = new SSP_MessageCenterApplicationNotify();
        String sch = '0 0 23 * * ?';
        ID idJob = System.Schedule('test status Check', sch, msgCenterObject);
        System.assertNotEquals(idJob,null,'Correct Output');
        test.stopTest();
    }
}