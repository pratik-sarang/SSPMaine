/*
* classname     :  SSP_IndividualEnrollmentDetailsTest
* @description  :  This is test class for SSP_IndividualEnrollmentDetails
* @author       :  Varun Kochar   
* @date         :  03/01/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_IndividualEnrollmentDetailsTest {
    
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_InsurancePolicy__c> lstInsurncePolicy = SSP_TestDataFactory.createInsurancePolicy(1,true);        
            List<SSP_InsuranceCoveredIndiv__c> lstInsCovInd = SSP_TestDataFactory.createInsuranceCovIndPolicy(3, false);
            lstInsCovInd[0].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
            lstInsCovInd[0].recordTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getrecordTypeInfosByDeveloperName().get('InsuranceCoveredIndividual').getRecordTypeId();
            lstInsCovInd[1].recordTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getrecordTypeInfosByDeveloperName().get('InsuranceExternalPolicyHolder').getRecordTypeId();
            lstInsCovInd[1].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
            lstInsCovInd[2].recordTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getrecordTypeInfosByDeveloperName().get('InsuranceExternalCoveredIndividual').getRecordTypeId();
            lstInsCovInd[2].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
            insert lstInsCovInd;
            SSP_HealthInsuranceFacilityType__c facility = new SSP_HealthInsuranceFacilityType__c(FacilityType__c = 'MD',SSP_InsuranceCoveredIndiv__c = lstInsCovInd[0].Id);
            insert facility;
            
        }
    }
    @isTest
    public static void fetchMemberDetailsMethod(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_InsurancePolicy__c> lstInsurncePolicy =[Select Id from SSP_InsurancePolicy__c];        
            List<SSP_InsuranceCoveredIndiv__c> lstInsCovInd = [Select Id,ExtAddressLine1__c,ExtAddressLine2__c,ExtCity__c,
                                                               ExtStateCode__c,ExtZipCode5__c from SSP_InsuranceCoveredIndiv__c];
            List<SSP_HealthInsuranceFacilityType__c> lstFacility = [Select Id from SSP_HealthInsuranceFacilityType__c];
            //SSP_AddressVerification_IntUtilityTest.validSuccessScenarioForAddressVerification();
            Test.startTest();
            SSP_IndividualEnrollmentDetails.fetchMemberDetails(lstInsCovInd[0].Id);
            SSP_IndividualEnrollmentDetails.fetchMemberDetails(lstInsCovInd[1].Id);
            SSP_LightningResponse objResponse = SSP_IndividualEnrollmentDetails.fetchMemberDetails(lstInsCovInd[2].Id);
            SSP_IndividualEnrollmentDetails.InsuranceCoveredIndividualWrapper wrapper = (SSP_IndividualEnrollmentDetails.InsuranceCoveredIndividualWrapper) objResponse.mapResponse.get('wrapper');
            SSP_IndividualEnrollmentDetails.fetchMemberDetails(null);
            wrapper.insurancePolicy = lstInsurncePolicy[0];
            wrapper.otherEmployerName = null;
            wrapper.selectedEmployer = null;
            wrapper.policyListWrapperList[0].policy.CoverageEndDate__c = System.Today();
            wrapper.policyListWrapperList[0].selected = true;
            SSP_IndividualEnrollmentDetails.saveIndividualDetails(JSON.serialize(wrapper));
            SSP_IndividualEnrollmentDetails.saveIndividualDetails(null);
            String tempId ='123';
            SSP_HealthEnrollmentSummaryService.getHealthInsuranceFacilityType(new Set<String>{tempId});
            SSP_HealthEnrollmentSummaryService.getAssets(new Set<String>{tempId});
            SSP_HealthEnrollmentSummaryService.getCoveredIndividualPolicyHolder(new Set<String>{tempId});
            SSP_HealthEnrollmentSummaryService.getCoveredIndividual(new Set<String>{tempId});
            string countryname = 'USA';
            Test.stopTest();
        }
    }
}