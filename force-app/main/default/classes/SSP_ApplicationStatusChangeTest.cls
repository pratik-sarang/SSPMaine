@isTest
public with sharing class SSP_ApplicationStatusChangeTest {

     
    @TestSetup
    static void setup(){
        
        SSP_TestDataFactory.setupTestData();   
        SSP_TestDataFactory.setUpNonCitizenUser(); 
        Id recordTypeId = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName()
    .get('SSP_Application').getRecordTypeId();
        date d = system.today().addDays(-9);
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(2, false);
        lstAcc[0].Name = 'IncomeController';
        lstAcc[1].Name = 'NewAccountController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'NonCitizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(2, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'MA;KT;SN';
        lstAppln[0].ApplicationCreationInSSP__c=d;
        lstAppln[0].Status__c='UN';
        lstAppln[1].Account__c=lstAcc[1].Id;        
        lstAppln[1].Contact__c = lstCon[0].Id;
        lstAppln[1].ProgramsApplied__c = 'MA;KT;SN';
        lstAppln[1].ApplicationCreationInSSP__c=d;
        lstAppln[1].Status__c='UN';
        insert lstAppln;
            

        }
              
        
    @isTest
        public static void sspApplicationStatusChangeBatchTest()
        {
            
            Test.startTest();
            Database.executeBatch(new SSP_ApplicationStatusChange(), 2);
            Test.stopTest();
            List<SSP_Application__c> applist= [SELECT Id, Status__c from SSP_Application__c];
            system.assertEquals('Inactive', applist[0].Status__c);
        }
}