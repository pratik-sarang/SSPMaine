/*
* classname     : SSP_EnrollmentDetailsCtrlTest
* @description  : This Test class is use to increase coverage of SSP_EnrollmentDetailsCtrl
* @author       : Ashwin Kasture
* @date         : 12/1/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        12/1/2020      Initial Version
*/
@isTest(seeAllData=false)
public class SSP_EnrollmentDetailsCtrlTest {
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
        lstAppln[0].EnrolledInHealthCareCoverageToggle__c = 'Y';
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
            lstInsurancePolicy = ESAPI.accessController().insertAsUser(lstInsurancePolicy, SSP_Utility.getFieldsNamesList (lstInsurancePolicy)).getInsertedObjects();
            
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);            
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = true;
            lstInsuranceCovInd = ESAPI.accessController().insertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList (lstInsuranceCovInd)).getInsertedObjects();
        }
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /*
    * method        : test_getEnrollmentDetails
    * @description  : This method is use to get cover getEnrollmentDetails() method of SSP_EnrollmentDetailsCtrl class
    * @author       : Ashwin Kasture    
    * @return       : void
    * */
    @isTest
    public static void test_getEnrollmentDetails() {
        System.runAs(fetchCitizenUser()) {
            List<SSP_Application__c> appIndvList = [Select Id From SSP_Application__c];
            List<SSP_InsurancePolicy__c> lstInsurancePolicy = [Select Id From SSP_InsurancePolicy__c];
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = [Select Id,RecordTypeId,IsPolicyHolder__c From SSP_InsuranceCoveredIndiv__c];
            Test.startTest();
            SSP_LightningResponse objResp = new SSP_LightningResponse();
            objResp = SSP_EnrollmentDetailsCtrl.getEnrollmentDetails(appIndvList[0].Id,lstInsurancePolicy[0].Id, true);
            system.assert(objResp.bIsSuccess, true);
            
            SSP_LightningResponse objResp2 = new SSP_LightningResponse();            
            String insuranceExtPolicyHolderRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceExternalPolicyHolder');
            lstInsuranceCovInd[0].RecordTypeId = insuranceExtPolicyHolderRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = true;            
            ESAPI.accessController().updateAsUser(new Map<Id, SSP_InsuranceCoveredIndiv__c>(lstInsuranceCovInd), SSP_Utility.getFieldsNamesList(lstInsuranceCovInd));
            objResp2 = SSP_EnrollmentDetailsCtrl.getEnrollmentDetails(appIndvList[0].Id,lstInsurancePolicy[0].Id, true);
                        
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = false;
            ESAPI.accessController().updateAsUser(new Map<Id, SSP_InsuranceCoveredIndiv__c>(lstInsuranceCovInd), SSP_Utility.getFieldsNamesList(lstInsuranceCovInd));
            objResp2 = SSP_EnrollmentDetailsCtrl.getEnrollmentDetails(appIndvList[0].Id,lstInsurancePolicy[0].Id, true);
            
            String insuranceExtCoveredIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceExternalCoveredIndividual');
            lstInsuranceCovInd[0].RecordTypeId = insuranceExtCoveredIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = false;
            ESAPI.accessController().updateAsUser(new Map<Id, SSP_InsuranceCoveredIndiv__c>(lstInsuranceCovInd), SSP_Utility.getFieldsNamesList(lstInsuranceCovInd));
            objResp2 = SSP_EnrollmentDetailsCtrl.getEnrollmentDetails(appIndvList[0].Id,lstInsurancePolicy[0].Id, true);
            system.assert(objResp2.bIsSuccess, true);
            
            SSP_LightningResponse objCatchResp = new SSP_LightningResponse();
            objCatchResp = SSP_EnrollmentDetailsCtrl.getEnrollmentDetails(null,null,null);
            system.assertEquals(objCatchResp.bIsSuccess, false);
            Test.stopTest();
        }
    }
    
    /*
    * method        : test_storeEnrollmentDetailsData
    * @description  : This method is use to get cover storeEnrollmentDetailsData() method of SSP_EnrollmentDetailsCtrl class
    * @author       : Ashwin Kasture    
    * @return       : void
    * */
    @isTest
    public static void test_storeEnrollmentDetailsData() {
        System.runAs(fetchCitizenUser()) {			
            {
                List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = [Select Id From SSP_InsuranceCoveredIndiv__c]; 
                List<SSP_Member__c> lstMem = [Select Id From SSP_Member__c];
                
                String strResp = '{'+
                    '"bDoNotHaveAllInformation" : false,'+
                    '"bIsEnrolledInInsurance" : true,'+
                    '"sPolicyHolderMemberIdDelete": '+'"'+String.valueOf(lstInsuranceCovInd[0].Id)+'",'+
                    '"objPolicyHolder" : {"sMemberId" : '+'"'+String.valueOf(lstMem[0].Id)+'"}'+
                    '}';
                Test.startTest();
                SSP_LightningResponse objResp = new SSP_LightningResponse();
                objResp = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp);
                system.assert(objResp.bIsSuccess, true);
                
                SSP_LightningResponse objResp1 = new SSP_LightningResponse();
            	String strResp1 = '{'+
                    '"bDoNotHaveAllInformation" : false,'+
                    '"bIsEnrolledInInsurance" : true,'+
                    '"objOutsidePolicyHolder": {"sCoveredIndFirstName":"Test"}'+
                    '}';
            	objResp1 = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp1);
                system.assert(objResp1.bIsSuccess, true);
                
                SSP_LightningResponse objResp2 = new SSP_LightningResponse();
            	String strResp2 = '{'+
                    '"bDoNotHaveAllInformation" : false,'+
                    '"bIsEnrolledInInsurance" : true'+
                    '}';
            	objResp2 = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp2);
                system.assert(objResp2.bIsSuccess, true);
                
                SSP_LightningResponse objResp3 = new SSP_LightningResponse();
            	String strResp3 = '{'+
                    '"bDoNotHaveAllInformation" : false,'+
                    '"bIsEnrolledInInsurance" : true,'+
                    '"lstCoveredInd" : [{"sMemberId" :'+'"'+String.valueOf(lstMem[0].Id)+'"}],'+
                    '"lstOutsideCoveredInd" : [{"sCoveredIndFirstName" : "Test"}]'+
                    '}';
            	objResp3 = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp3);
                system.assert(objResp3.bIsSuccess, true);
                
                SSP_LightningResponse objCatchResp = new SSP_LightningResponse();
                objCatchResp = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(null);
                system.assertEquals(objCatchResp.bIsSuccess, false);
                Test.stopTest();
            }
        }
    }
    
    /*
    * method        : test_storeEnrollmentDeleteCoverInd
    * @description  : This method is use to get cover storeEnrollmentDetailsData() method of SSP_EnrollmentDetailsCtrl class
    * @author       : Ashwin Kasture    
    * @return       : void
    * */
    @isTest
    public static void test_storeEnrollmentDeleteCoverInd() {
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = [Select Id From SSP_InsurancePolicy__c];
        List<SSP_Member__c> lstMem = [Select Id From SSP_Member__c];        
        System.runAs(fetchCitizenUser()) {
            List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);        
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
            lstInsuranceCovInd[0].SSP_Member__c = lstMem[0].Id;
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = false;             
            lstInsuranceCovInd = ESAPI.accessController().insertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList (lstInsuranceCovInd)).getInsertedObjects();        
            SSP_LightningResponse objResp = new SSP_LightningResponse();
            String strResp = '{'+
                '"bDoNotHaveAllInformation" : false,'+
                '"bIsEnrolledInInsurance" : true,'+
                '"sInsurancePolicyId" : "'+String.valueOf(lstInsurancePolicy[0].Id)+'",'+                    
                '"lstCoveredIndDelete" : ["'+String.valueOf(lstMem[0].Id)+'"]'+
                '}';
            Test.startTest();
            objResp = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp);
            system.assert(objResp.bIsSuccess, true); 
            Test.stopTest();
        }
    }
    
    /*
    * method        : test_storeEnrollmentDeleteOutsideCovInd
    * @description  : This method is use to get cover storeEnrollmentDetailsData() method of SSP_EnrollmentDetailsCtrl class
    * @author       : Ashwin Kasture    
    * @return       : void
    * */
    @isTest
    public static void test_storeEnrollmentDeleteOutsideCovInd() {
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = [Select Id From SSP_InsurancePolicy__c];
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);        
        System.runAs(fetchCitizenUser()) {
            String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
            lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;        
            lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
            lstInsuranceCovInd[0].IsPolicyHolder__c = false;             
            lstInsuranceCovInd = ESAPI.accessController().insertAsUser(lstInsuranceCovInd, SSP_Utility.getFieldsNamesList (lstInsuranceCovInd)).getInsertedObjects();
            
            SSP_LightningResponse objResp = new SSP_LightningResponse();
            String strResp = '{'+
                '"bDoNotHaveAllInformation" : false,'+
                '"bIsEnrolledInInsurance" : true,'+
                '"sInsurancePolicyId" : "'+String.valueOf(lstInsurancePolicy[0].Id)+'",'+
                '"lstOutsideCoveredIndDelete" : ["'+String.valueOf(lstInsuranceCovInd[0].Id)+'"]'+					
                '}';
            Test.startTest();
            objResp = SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData(strResp);
            system.assert(objResp.bIsSuccess, true); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void isRequiredTest(){
        SSP_EnrollmentScreenQueueRule queueRule = new SSP_EnrollmentScreenQueueRule();
        Boolean isRequired = false;
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        SSP_Member__c objMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Application__c objApp = [SELECT ID FROM SSP_Application__c Limit 1];
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        ctxData.MemberId = objMember.Id;
        ctxData.ApplicationId = objApp.Id;
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Application__r.EnrolledInHealthCareCoverageToggle__c From SSP_ApplicationIndividual__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        ctxData.queueObject = queWrap;
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
    }
}