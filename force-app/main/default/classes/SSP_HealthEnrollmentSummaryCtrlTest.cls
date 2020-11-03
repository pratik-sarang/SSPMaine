/*
* classname 	: SSP_HealthEnrollmentSummaryCtrlTest
* @description 	: This class is use to cover class of Health Enrollment Summary Screen screen
* @author 		: Ashwin Kasture
* @date 		: 12/08/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_HealthEnrollmentSummaryCtrlTest {
    /*
	* method        : setup()
	* @description  : This method is use to set up the Test Data.
	* @author       : Ashwin Kasture	
	* @return       : Void
	* */
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
            lstInsurancePolicy[0].IsDeleted__c = false;
            lstInsurancePolicy[0].DCId__c = 1233;
            lstInsurancePolicy = ESAPI.accessController().insertAsUser(lstInsurancePolicy, SSP_Utility.getFieldsNamesList (lstInsurancePolicy)).getInsertedObjects();
            
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);        
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = true;
            lstInsuranceCovInd[0].IsDeleted__c = false;
            lstInsuranceCovInd[0].IsEnrolled__c = true;
            lstInsuranceCovInd[0].SSP_Member__c = lstMem[0].Id;
            lstInsuranceCovInd = ESAPI.accessController().insertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList (lstInsuranceCovInd)).getInsertedObjects();
            
            List<SSP_HealthInsuranceFacilityType__c> lstInsuranceFacility = SSP_TestDataFactory.createHealthInsuranceFacilityType(1, false);
            lstInsuranceFacility[0].SSP_InsuranceCoveredIndiv__c = lstInsuranceCovInd[0].Id;
            lstInsuranceFacility = ESAPI.accessController().insertAsUser(lstInsuranceFacility, SSP_Utility.getFieldsNamesList (lstInsuranceFacility)).getInsertedObjects();
    	}
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /*
	* method 		: healthEnrollmentSummaryMethod
	* @description  : This method is use to cover "getHealthEnrollmentSummary","removeInsuranceCovInd","removeInsurancePolicy" method
	* @author 		: Ashwin Kasture
	* @param 		: -
	* @return 		: void
	* */
	@isTest
    public static void healthEnrollmentSummaryMethod() {
        System.runAs(fetchCitizenUser()) {
            SSP_LightningResponse objGetEnrollmentResponse = new SSP_LightningResponse();
            List<SSP_Application__c> lstAppInd = [Select Id from SSP_Application__c];
            List<SSP_Member__c> lstMem = [Select Id from SSP_Member__c];
            List<SSP_InsurancePolicy__c> lstInsurancePolicy = [Select Id,DCId__c from SSP_InsurancePolicy__c];
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = [Select Id,DCId__c from SSP_InsuranceCoveredIndiv__c];
            Test.startTest();
			objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
            lstInsurancePolicy[0].DCId__c = 101;			
            update lstInsurancePolicy;
            lstInsuranceCovInd[0].SSP_Member__c=null;            
            update lstInsuranceCovInd;
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);            
            lstInsuranceCovInd[0].IsPolicyHolder__c=false;
            update lstInsuranceCovInd;
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
            lstInsuranceCovInd[0].DCId__c = 101;
            update lstInsuranceCovInd;
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
            lstInsuranceCovInd[0].SSP_Member__c=lstMem[0].Id;
            update lstInsuranceCovInd;
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
            lstInsuranceCovInd[0].DCId__c = null;
            update lstInsuranceCovInd;
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(String.valueOf(lstAppInd[0].Id),true);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
 			objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary(null,true);
            system.assertEquals(false, objGetEnrollmentResponse.bIsSuccess);            
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.removeInsurancePolicy(lstInsurancePolicy[0].Id, String.valueOf(lstAppInd[0].Id));
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
			objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.removeInsurancePolicy(null,null);
            system.assertEquals(false, objGetEnrollmentResponse.bIsSuccess);
			Test.stopTest();            
        }
	}
    
    /*
	* method 		: removeInsuraceCoveredInd
	* @description  : This method is use to remove removeInsuranceCovInd  method of SSP_HealthEnrollmentSummaryCtrl class
	* @author 		: Ashwin Kasture
	* @param 		: -
	* @return 		: void
	* */
	@isTest
    public static void removeInsuraceCoveredInd() {
        System.runAs(fetchCitizenUser()) {
            SSP_LightningResponse objGetEnrollmentResponse = new SSP_LightningResponse();
            List<SSP_InsurancePolicy__c> lstInsurancePolicy = SSP_TestDataFactory.createInsurancePolicyRecords(1, false);
            String insurancePolicyDetailRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsurancePolicy__c').get('InsurancePolicyDetail');
            lstInsurancePolicy[0].InsuranceCompanyName__c='Company Name';
            lstInsurancePolicy[0].RecordTypeId = insurancePolicyDetailRecTypeId;  
            lstInsurancePolicy[0].IsEnrolledInInsurance__c = true;
            lstInsurancePolicy[0].IsDeleted__c = false;
            lstInsurancePolicy = ESAPI.accessController().insertAsUser(lstInsurancePolicy, SSP_Utility.getFieldsNamesList (lstInsurancePolicy)).getInsertedObjects();
            List<SSP_InsuranceCoveredIndiv__c> lstCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);        
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
            lstCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstCovInd[0].IsPolicyHolder__c = true;
            lstCovInd[0].IsDeleted__c = false;
            lstCovInd[0].IsEnrolled__c = true;
            lstCovInd = ESAPI.accessController().insertAsUser(lstCovInd, SSP_Utility.getFieldsNamesList (lstCovInd)).getInsertedObjects();
            Test.startTest();
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.removeInsuranceCovInd(lstCovInd[0].Id, null);
            system.assert(objGetEnrollmentResponse.bIsSuccess, true);
            objGetEnrollmentResponse = SSP_HealthEnrollmentSummaryCtrl.removeInsuranceCovInd(null, null);
            system.assertEquals(false, objGetEnrollmentResponse.bIsSuccess);
            Test.stopTest();
        }
    }
    
    /*
	* method 		: updateTrackDeletionTest
	* @description  : This method is use to cover updateTrackDeletion Method.
	* @author 		: Sai Kiran
	* @param 		: -
	* @return 		: void
	* */
    @isTest
    public static void updateTrackDeletionTest() {
        SSP_LightningResponse objUpdateTrackResponse = new SSP_LightningResponse();
        List<SSP_Application__c> lstAppln = [Select Id from SSP_Application__c];
        List<SSP_InsurancePolicy__c> lstInsurncePolicy = [Select Id,DCId__c from SSP_InsurancePolicy__c];
        List<SSP_InsuranceCoveredIndiv__c> lstInsCovInd = [Select Id,DCId__c from SSP_InsuranceCoveredIndiv__c];
        System.runAs(fetchCitizenUser()) {            
            lstInsurncePolicy[0].DCId__c = 12345;
            update lstInsurncePolicy;            
            lstInsCovInd[0].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
            lstInsCovInd[0].DCId__c = 1234;
            update lstInsCovInd;
            SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper trackDeletionWrapper = new SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper();
            trackDeletionWrapper.sApplicationId = lstAppln[0].Id;
            trackDeletionWrapper.sSalesforceId = lstInsCovInd[0].Id;
            trackDeletionWrapper.sOtherReason = 'testing';
            trackDeletionWrapper.sEndReason = 'OT';
            trackDeletionWrapper.sSource = 'Test';
            trackDeletionWrapper.dEndDate = System.today();
            trackDeletionWrapper.sParentDCId = (lstInsurncePolicy[0].DCId__c).intValue();
            trackDeletionWrapper.sDCId = String.valueOf(lstInsCovInd[0].DCId__c);
            trackDeletionWrapper.bIsCoveredIndDeletion = true;
            Test.startTest();
            objUpdateTrackResponse = SSP_HealthEnrollmentSummaryCtrl.updateTrackDeletion(JSON.serialize(trackDeletionWrapper));
            system.assertEquals(true, objUpdateTrackResponse.bIsSuccess);
            objUpdateTrackResponse = SSP_HealthEnrollmentSummaryCtrl.updateTrackDeletion(null);
            system.assertEquals(false, objUpdateTrackResponse.bIsSuccess);
            Test.stopTest();
        }
    }
    
    /*
	* method 		: updateTrackDeletionTest1
	* @description  : This method is use to cover updateTrackDeletion Method.
	* @author 		: Sai Kiran
	* @param 		: -
	* @return 		: void
	* */
    @isTest
    public static void updateTrackDeletionTest1() {
        SSP_LightningResponse objUpdateTrackResponse = new SSP_LightningResponse();
        List<SSP_Application__c> lstAppln = [Select Id from SSP_Application__c];
        List<SSP_InsurancePolicy__c> lstInsurncePolicy = [Select Id,DCId__c from SSP_InsurancePolicy__c];
        List<SSP_InsuranceCoveredIndiv__c> lstInsCovInd = [Select Id,DCId__c from SSP_InsuranceCoveredIndiv__c];
        System.runAs(fetchCitizenUser()) {			
            lstInsurncePolicy[0].DCId__c = 12345;
            update lstInsurncePolicy;            
            lstInsCovInd[0].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
            lstInsCovInd[0].DCId__c = 1234;
            update lstInsCovInd;
            SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper trackDeletionWrap = new SSP_HealthEnrollmentWrapper.SSP_TrackDeletionWrapper();
            trackDeletionWrap.sApplicationId = lstAppln[0].Id;
            trackDeletionWrap.sSalesforceId = lstInsurncePolicy[0].Id;
            trackDeletionWrap.sOtherReason = 'testing';
            trackDeletionWrap.sEndReason = 'OT';
            trackDeletionWrap.sSource = 'Test';
            trackDeletionWrap.dEndDate = System.today();
            trackDeletionWrap.sParentDCId = null;
            trackDeletionWrap.sDCId = String.valueOf(lstInsurncePolicy[0].DCId__c);
            trackDeletionWrap.bIsCoveredIndDeletion = false;
            Test.startTest();
            objUpdateTrackResponse = SSP_HealthEnrollmentSummaryCtrl.updateTrackDeletion(JSON.serialize(trackDeletionWrap));        
            objUpdateTrackResponse = SSP_HealthEnrollmentSummaryCtrl.updateTrackDeletion(JSON.serialize(trackDeletionWrap));
            system.assertEquals(true, objUpdateTrackResponse.bIsSuccess);
            Test.stopTest();            
        }
    }
}