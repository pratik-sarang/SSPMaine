/*
* classname     :  SSP_KHIPPPreferredPaymentMethodQRuleTest
* @description  :  Test class for SSP_KHIPPPreferredPaymentMethodQueueRule
* @author       :  Varun Kochar 
* @date         :  17/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_KHIPPPreferredPaymentMethodQRuleTest {
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();
        Integer n = 1;
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(n , true);
        List<Contact> citizenCOntact = [Select Id from Contact where FirstName ='Citizen' ];
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = citizenCOntact[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = citizenCOntact[0].Id;
        lstAppln[0].ProgramsApplied__c = 'KP';
        lstAppln[0].EnrolledInHealthCareCoverageToggle__c = 'N';
        lstAppln[0].NotEnrolledInHealthCareCoverageToggle__c = 'Y';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].Name='TestMember';
        lstMem[0].contact__c=citizenCOntact[0].Id;  
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'KP';  
        lstAppInd[0].IsHeadOfHousehold__c = true;
        insert lstAppInd;
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = SSP_TestDataFactory.createInsurancePolicyRecords(1, false);
        String insurancePolicyDetailRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsurancePolicy__c').get('InsurancePolicyDetail');
        lstInsurancePolicy[0].InsuranceCompanyName__c='Company Name';
        lstInsurancePolicy[0].RecordTypeId = insurancePolicyDetailRecTypeId;  
        lstInsurancePolicy[0].IsEnrolledInInsurance__c = true;
        lstInsurancePolicy[0].IsDeleted__c = false;
        lstInsurancePolicy[0].IsKIHIPPSourceOfCoverage__c = true;
        insert lstInsurancePolicy;
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCovInd = SSP_TestDataFactory.createInsuranceCoveredIndividuals(1, false);        
        String insuranceCovedIndRecTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_InsuranceCoveredIndiv__c').get('InsuranceCoveredIndividual');
        lstInsuranceCovInd[0].SSP_InsurancePolicy__c = lstInsurancePolicy[0].Id;
        lstInsuranceCovInd[0].RecordTypeId = insuranceCovedIndRecTypeId;
        lstInsuranceCovInd[0].IsPolicyHolder__c = true;
        lstInsuranceCovInd[0].IsDeleted__c = false;
        lstInsuranceCovInd[0].IsEnrolled__c = true;
        lstInsuranceCovInd[0].SSP_Member__c = lstMem[0].Id;  
        insert lstInsuranceCovInd;
    }
    @isTest
    public static void test_isRequired_postive(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> memberList = [Select Id from SSP_Member__c];
        List<SSP_Application__c> appList = [Select Id,NotEnrolledInHealthCareCoverageToggle__c from SSP_Application__c];
        ContextData ctxData = new ContextData();
        ctxData.MemberId = memberList[0].Id;
        ctxData.ApplicationId = appList[0].Id;
        Context ctx = new Context();            
        QueuingWrapper queWrap = new QueuingWrapper();
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Application__r.EnrolledInHealthCareCoverageToggle__c,SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c From SSP_ApplicationIndividual__c LIMIT 1];
        SSP_InsuranceCoveredIndiv__c objInsCovInd = [SELECT ID,SSP_InsurancePolicy__r.IsKIHIPPSourceOfCoverage__c,IsPolicyHolder__c,IsEnrolled__c FROM SSP_InsuranceCoveredIndiv__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        lstAppInd.add(objAppInd);
        queWrap.applicationIndividualList = lstAppInd;
        ctxData.queueObject = queWrap;
        Test.startTest();
        System.runAs(citizen){
            Boolean result = new SSP_KHIPPPreferredPaymentMethodQueueRule().isRequired(new Context(), ctxData);
            system.assert(result);            
        }
        Test.stopTest();
    }
    @isTest
    public static void test_isRequired_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> memberList = [Select Id from SSP_Member__c];
        List<SSP_Application__c> appList = [Select Id,NotEnrolledInHealthCareCoverageToggle__c from SSP_Application__c];
        appList[0].NotEnrolledInHealthCareCoverageToggle__c = 'N';
        update appList;
        ContextData ctxData = new ContextData();
        ctxData.MemberId = memberList[0].Id;
        ctxData.ApplicationId = appList[0].Id;
        Context ctx = new Context();            
        QueuingWrapper queWrap = new QueuingWrapper();
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Application__r.EnrolledInHealthCareCoverageToggle__c,SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c From SSP_ApplicationIndividual__c LIMIT 1];
        SSP_InsuranceCoveredIndiv__c objInsCovInd = [SELECT ID,SSP_InsurancePolicy__r.IsKIHIPPSourceOfCoverage__c,IsPolicyHolder__c,IsEnrolled__c FROM SSP_InsuranceCoveredIndiv__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        lstAppInd.add(objAppInd);
        queWrap.applicationIndividualList = lstAppInd;
        ctxData.queueObject = queWrap;
        Test.startTest();
        System.runAs(citizen){
            Boolean result = new SSP_KHIPPPreferredPaymentMethodQueueRule().isRequired(new Context(), ctxData);
            system.assert(!result);
        }        
        Test.stopTest();
    }
}