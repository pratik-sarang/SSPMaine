/*
* classname 	: SSP_HealthConditionControllerTest
* @description 	: A test class for SSP_HealthConditionController.
* @author 		: Naveena Malapati
* @date 		: FEB-11-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Naveena Malapati		FEB-11-2020		Initial Version
*/
@isTest(seeAllData=false)
public with sharing class SSP_HealthConditionControllerTest {
    @testSetup
    public static void dataSetup() {
        Integer n = 1;
        List<Account> accounts = SSP_TestDataFactory.createAccounts(n, true);
        List<Contact> contacts = SSP_TestDataFactory.createContacts(n, false);
        List<SSP_Application__c> applications = SSP_TestDataFactory.createSSPApplications(n, false);
        for(Integer i = 0; i < n; ++i) {
            contacts[i].AccountId = accounts[i].Id;
            applications[i].Account__c = accounts[i].Id;
            applications[i].ApplicationReceivedDateTime__c = system.now();
		}
		insert applications;
        insert contacts;
        
        n = 1;
        List<SSP_Member__c> members = SSP_TestDataFactory.createSSPMembers(n, false);
        for(SSP_Member__c member : members) {
            member.Contact__c = contacts[0].Id;
        }
        insert members;
        List<SSP_ApplicationIndividual__c> individuals = SSP_TestDataFactory.createApplicationIndividuals(n, false);
        for(Integer i = 0; i < n; ++i) {
            individuals[i].SSP_Member__c = members[i].Id;
            individuals[i].SSP_Application__c = applications[0].Id;
        }
        insert individuals;
    }
    
    @isTest
    public static void unitTest1() {
        Test.startTest();
        SSP_ApplicationIndividual__c individual = [SELECT Id, SSP_Application__c, SSP_Member__c FROM SSP_ApplicationIndividual__c LIMIT 1];
        SSP_LightningResponse response = SSP_HealthConditionController.fetchProgramsApplied(individual.SSP_Application__c, individual.SSP_Member__c);
        System.assert(response.bIsSuccess);
        Test.stopTest();
    }

}