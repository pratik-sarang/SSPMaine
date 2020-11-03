/*
* classname 	: SSP_MedicalBillsFor3MonthsControllerTest
* @description 	: A test class for SSP_MedicalBillsFor3MonthsController.
* @author 		: Naveena Malapati
* @date 		: FEB-29-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Naveena Malapati		FEB-29-2020		Initial Version
*/
@isTest(seeAllData=false)
public with sharing class SSP_MedicalBillsFor3MonthsControllerTest {
    @testSetup
    public static void dataSetup() {
        Integer n = 1;
        List<Account> accounts = SSP_TestDataFactory.createAccounts(n, true);
        List<Contact> contacts = SSP_TestDataFactory.createContacts(n, true);
        List<SSP_Application__c> applications = SSP_TestDataFactory.createSSPApplications(n, false); 
            contacts[0].AccountId = accounts[0].Id;
            applications[0].Account__c = accounts[0].Id;
            applications[0].ApplicationReceivedDateTime__c = Datetime.newInstance(1960, 1, 17);
        insert contacts;
		insert applications; 
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=contacts[0].Id;
        lstMem[0].BirthDate__c = System.today().addYears(-10);
        insert lstMem;
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=applications[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
    
    @isTest
    public static void unitTest1() {
        Test.startTest();
        SSP_Application__c individual = [SELECT Id FROM SSP_Application__c LIMIT 1];
        SSP_LightningResponse response = SSP_MedicalBillsFor3MonthsController.fetchApplicationDate(individual.Id,null);
        System.assert(!response.bIsSuccess);
        Test.stopTest();
    }
    @isTest
    public static void unitTest2() {
        Test.startTest();
        SSP_ApplicationIndividual__c appInd = [SELECT Id,SSP_Member__c,SSP_Member__r.Age__c,SSP_Member__r.BirthDate__c,SSP_Application__c FROM SSP_ApplicationIndividual__c LIMIT 1];
        SSP_LightningResponse response = SSP_MedicalBillsFor3MonthsController.fetchApplicationDate(appInd.SSP_Application__c,appInd.SSP_Member__c);
        System.assert(response.bIsSuccess);
        Test.stopTest();
    }

}