/*
* Classname     :  SSP_SSPDCIntegrationServiceBatchTest
* @description  :  This class is the test class of SSP_SSPDCIntegrationServiceBatch
* @author       :  Ragunathan
* @date         :  08/04/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          01/08/2020            Initial Creation
**/
@isTest
public class SSP_SSPDCIntegrationServiceBatchTest {
    @TestSetup static void setup() { 
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
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'SN;KT;CC';
        lstAppln[0].SSPDCMessage__c = 'HBE1000';
        lstAppln[0].IsApplicationSubmittedEarly__c = 'Y';
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        Map<String, Object> objResponse = new Map<String, Object>();
        objResponse.put(SSP_InterfaceConstants.SUBMIT_TYPE,'Intake');
        List<String> APPLICABLE_SCREEN_LIST = new List<String>{'SSP_APP_Primary_Address'};
        objResponse.put(SSP_InterfaceConstants.SCREEN_LIST,APPLICABLE_SCREEN_LIST);
        objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
        objResponse.put(SSP_InterfaceConstants.APPLICATION_ID,[Select id from SSP_Application__c limit 1].Id);
       
         //SSP_Transaction__c
        SSP_Transaction__c transactionDetail = new SSP_Transaction__c (
            InterfaceName__c    = SSP_InterfaceConstants.SSP_DC,
            ApplicationId__c    = (String) objResponse.get(SSP_InterfaceConstants.APPLICATION_ID),
            Status__c           = SSP_InterfaceConstants.PENDING,
            Unique_Id__c        = SSP_InterfaceConstants.SSP_DC+'-'+objResponse.get(SSP_InterfaceConstants.SUBMIT_TYPE)+'-'+objResponse.get(SSP_InterfaceConstants.APPLICATION_ID),
            MapOfInputParams__c = JSON.serialize(objResponse),
            No_of_Retry__c = 0
        );
 		insert transactionDetail;
    }
    @isTest 
    static void shouldExecuteBatch() { 
        SSP_SSPDCIntegrationServiceBatch.boolMakeCallout = false;
        Database.executeBatch(new SSP_SSPDCIntegrationServiceBatch(), 10);
        String sAppMsg = [Select SSPDCMessage__c from SSP_Application__c limit 1].SSPDCMessage__c;
        System.assertEquals(sAppMsg,'HBE1000','Correct Output');
    }
    @isTest 
    static void shouldThrowExceptionWhileInvokingCallout() { 
        Database.executeBatch(new SSP_SSPDCIntegrationServiceBatch(), 10);
        String sAppMsg = [Select SSPDCMessage__c from SSP_Application__c limit 1].SSPDCMessage__c;
        System.assertEquals(sAppMsg,'HBE1000','Correct Output');

    }
    @isTest
    private static void shouldScheduleBatch() { 
        Test.StartTest();
        SSP_SSPDCIntegrationServiceBatch testsche = new SSP_SSPDCIntegrationServiceBatch();
        String sch = '0 0 23 * * ?';
        ID idJob = system.schedule('Test status Check', sch, testsche );
        System.assertNotEquals(idJob,null,'Correct Output');
        Test.stopTest();
    }
}