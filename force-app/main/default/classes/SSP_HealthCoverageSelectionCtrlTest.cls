/*
* classname 	: SSP_HealthCoverageSelectionCtrlTest
* @description 	: This class is use to cover class of Health Coverage Selection screen
* @author 		: Ashwin Kasture
* @date 		: 22/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_HealthCoverageSelectionCtrlTest {
    /*
	* method        : setup()
	* @description  : This method is use to set up the Test Data.
	* @author       : Ashwin Kasture	
	* @return       : Void
	* */
    @TestSetup static void setup() {
    	SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'HealthSelectionCtrl';
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
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();        
        
        System.runAs(fetchCitizenUser()) {
        	List<SSP_InsurancePolicy__c> lstInsurancePolicy = SSP_TestDataFactory.createInsurancePolicyRecords(1, false);            
            String insurancePolicyDetailRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsurancePolicy__c').get('InsurancePolicyDetail');
            lstInsurancePolicy[0].InsuranceCompanyName__c='Company Name';
            lstInsurancePolicy[0].RecordTypeId = insurancePolicyDetailRecTypeId; 
            lstInsurancePolicy[0].IsEnrolledInInsurance__c = true;
            lstInsurancePolicy[0].DCId__c = Decimal.valueOf(123);
            lstInsurancePolicy = ESAPI.accessController().insertAsUser(lstInsurancePolicy, SSP_Utility.getFieldsNamesList (lstInsurancePolicy)).getInsertedObjects();
            
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);            
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = true;
            lstInsuranceCovInd[0].SSP_Member__c = lstMem[0].Id;
            lstInsuranceCovInd = ESAPI.accessController().insertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList (lstInsuranceCovInd)).getInsertedObjects();
        }
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    /*
	* method 		: healthCoverageSelectionMethod
	* @description  : This method is use to cover "getHealthCoverageData",assignHealthWrapperData & "storeHealthCoverageData" method
	* @author 		: Ashwin Kasture	
	* @return 		: void
	* */
    @isTest
    public static void healthCoverageSelectionMethod() {                
        System.runAs(fetchCitizenUser()) {
            List<SSP_Application__c> lstApp = [Select Id from SSP_Application__c];
        	List<SSP_Member__c> lstMember = [Select Id from SSP_Member__c];
        	Test.startTest();
            SSP_LightningResponse objGetHealthResponse = new SSP_LightningResponse();
            //Enrollment
            objGetHealthResponse = SSP_HealthCoverageSelectionCtrl.getHealthCoverageData(String.valueOf(lstApp[0].Id));
            system.assert(objGetHealthResponse.bIsSuccess);            
            //Access
            List<SSP_InsurancePolicy__c> lstInsurancePolicy = [Select Id From SSP_InsurancePolicy__c];
            lstInsurancePolicy[0].IsEnrolledInInsurance__c = false;
            update lstInsurancePolicy;
            objGetHealthResponse = SSP_HealthCoverageSelectionCtrl.getHealthCoverageData(String.valueOf(lstApp[0].Id));
            system.assert(objGetHealthResponse.bIsSuccess);            
            
            SSP_LightningResponse objStoreHealthResponse = new SSP_LightningResponse();
            String sMemberHealhSelectionData='{"sEnrolledInHealthCareCoverage":"Y","sNotEnrolledInHealthCareCoverage":"Y","sApplId":"'+lstApp[0].Id+'"}';
            objStoreHealthResponse = SSP_HealthCoverageSelectionCtrl.storeHealthCoverageData(sMemberHealhSelectionData);
            system.assert(objStoreHealthResponse.bIsSuccess);                        
            SSP_LightningResponse objGetHealthExceptionResponse = new SSP_LightningResponse();
            objGetHealthExceptionResponse = SSP_HealthCoverageSelectionCtrl.getHealthCoverageData(null);
        	system.assertEquals(false, objGetHealthExceptionResponse.bIsSuccess);
            SSP_LightningResponse objStoreHealthExceptionResponse = new SSP_LightningResponse();
            objStoreHealthExceptionResponse = SSP_HealthCoverageSelectionCtrl.storeHealthCoverageData(null);
        	system.assertEquals(false, objStoreHealthExceptionResponse.bIsSuccess);
            Test.stopTest();
        }
    }    
}