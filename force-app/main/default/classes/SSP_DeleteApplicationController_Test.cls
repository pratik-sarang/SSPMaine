@isTest
public with sharing class SSP_DeleteApplicationController_Test {
    @TestSetup
    static void setup(){
        SSP_TestDataFactory.setupTestData();
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'Delete Application';
        insert lstAcc;
    }

    @isTest
    public static void testSendNotificationAndDeleteApplication() {
        User citizen  = [SELECT Id, contactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];

        Account acc = [select id from account limit 1];

        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = acc.Id;
        acr.Contactid = citizen.contactId;
        acr.IsActive = true;
        insert acr;

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=acc.Id;
        lstAppln[0].Contact__c = citizen.contactId;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=citizen.contactId;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        insert lstMem;

        SSP_ApplicationIndividual__c ai = new SSP_ApplicationIndividual__c();
        ai.IsHeadOfHousehold__c = true;
        ai.SSP_Application__c = lstAppln[0].id;
        ai.SSP_Member__c = lstMem[0].id;
        insert ai;

        contact con = new contact(id = citizen.contactId, IndividualId__c = '1234');
        update con;

        System.runAs(citizen){
            SSP_DeleteApplicationController.sendNotificationAndDeleteApplication(lstAppln[0].id);
        }
    }
}