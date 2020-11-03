/*
* classname 	: SSP_KHIPPPreferredPaymentMethodTest
* @description 	: A test class for SSP_KHIPPPreferredPaymentMethod.
* @author 		: Varun Kochar
* @date 		: 19/02/2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* 
*/
@isTest
public class SSP_KHIPPPreferredPaymentMethodTest {
    
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        Integer n = 1, routingNumber=12345;
        List<Account> accounts = SSP_TestDataFactory.createAccounts(n , true);
        List<Contact> citizenCOntact = [Select Id from Contact where FirstName ='Citizen' ];
        
        List<SSP_Application__c> applications = SSP_TestDataFactory.createSSPApplications(n, false);
        applications[0].Account__c = accounts[0].Id;
        insert applications;
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = accounts[0].Id;
        acr.Contactid = citizenCOntact[0].Id;
        acr.IsActive = true;
        insert acr;
        n = 2;
        List<SSP_Member__c> members = SSP_TestDataFactory.createSSPMembers(n, false);
        List<SSP_Institution__c> lstInstitution = new List<SSP_Institution__c>();
        for(SSP_Member__c member : members) {
            routingNumber = routingNumber+1;
            member.Contact__c = citizenCOntact[0].Id;
            member.RoutingNumber__c = routingNumber;
            SSP_Institution__c bankDetailsRecord = new SSP_Institution__c(RoutingNumber__c = String.valueOf(routingNumber));
            lstInstitution.add(bankDetailsRecord);
        }
        insert members;
        List<SSP_ApplicationIndividual__c> individuals = SSP_TestDataFactory.createApplicationIndividuals(n, false);
        for(Integer i = 0; i < n; ++i) {
            individuals[i].SSP_Member__c = members[i].Id;
            individuals[i].SSP_Application__c = applications[0].Id;
        }
        insert individuals;
        List<SSP_InsurancePolicy__c> lstInsurncePolicy = SSP_TestDataFactory.createInsurancePolicy(1,true);        
        List<SSP_InsuranceCoveredIndiv__c> lstInsCovInd = SSP_TestDataFactory.createInsuranceCovIndPolicy(2, false);
        lstInsCovInd[0].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
        lstInsCovInd[0].recordTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getrecordTypeInfosByDeveloperName().get('InsuranceCoveredIndividual').getRecordTypeId();
        lstInsCovInd[0].SSP_Member__c = members[1].Id;
        lstInsCovInd[1].SSP_InsurancePolicy__c = lstInsurncePolicy[0].Id;
        lstInsCovInd[1].recordTypeId = Schema.SObjectType.SSP_InsuranceCoveredIndiv__c.getrecordTypeInfosByDeveloperName().get('InsuranceCoveredIndividual').getRecordTypeId();
        lstInsCovInd[1].SSP_Member__c = members[0].Id;
        lstInsCovInd[1].IsPolicyHolder__c = true;
        lstInsCovInd[1].IsEnrolled__c=true;
        insert lstInsCovInd;
        insert lstInstitution;
    }
    @isTest
    public static void testGetKHIPPDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            Test.startTest();
            List<SSP_Application__c> application = [Select Id from SSP_Application__c];
            SSP_LightningResponse objResponse = SSP_KHIPPPreferredPaymentMethod.getKHIPPDetails(application[0].Id);
            List<SSP_KHIPPPreferredPaymentMethod.SSP_KHIPPPreferredPaymentMethodWrapper> wrapper = (List<SSP_KHIPPPreferredPaymentMethod.SSP_KHIPPPreferredPaymentMethodWrapper>)objResponse.mapResponse.get('wrapper');
            SSP_KHIPPPreferredPaymentMethod.saveKHIPPPreferredPayment(JSON.serialize(wrapper));
            SSP_KHIPPPreferredPaymentMethod.saveKHIPPPreferredPayment(null);
            SSP_KHIPPPreferredPaymentMethod.getKHIPPDetails(null);
            List<SSP_KHIPPPreferredPaymentMethod.SSP_KHIPPPreferredPaymentMethodWrapper> wrapper2 = new List<SSP_KHIPPPreferredPaymentMethod.SSP_KHIPPPreferredPaymentMethodWrapper>();
            wrapper2.add(new SSP_KHIPPPreferredPaymentMethod.SSP_KHIPPPreferredPaymentMethodWrapper(null,null,null,null,null,null,null));
            String tempId ='123';
            SSP_KHIPPPreferredPaymentMethodService.getApplicationIndividual(new Set<String>{tempId});
            SSP_KHIPPPreferredPaymentMethodService.getCoveredIndividual(new Set<String>{tempId});
            SSP_KHIPPPreferredPaymentMethod.getBankDetails('123456');
            SSP_KHIPPPreferredPaymentMethod.getBankDetails('ertyu');
            SSP_KHIPPPreferredPaymentMethod.getBankDetails('1234567');
            SSP_KHIPPPreferredPaymentMethodService.getBankDetails(new Set<String>{'abc'});
            system.assert(wrapper.size()>0);
            Test.stopTest();
        }
    }
}