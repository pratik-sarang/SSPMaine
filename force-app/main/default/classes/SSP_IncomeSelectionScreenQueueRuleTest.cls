/*
* classname     :  SSP_IncomeSelectionScreenQueueRuleTest
* @description  :  Test class for SSP_IncomeSelectionScreenQueueRule
* @author       :  Shrikant Raut   
* @date         :  03/09/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_IncomeSelectionScreenQueueRuleTest {
    /**
    @author : Shrikant Raut
    Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
        insert lstAcc;
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        insert lstAppln;

        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'MA;CC;KT;KP';
        insert lstAppInd;
        
    }

    private static User fetchCitizenUser(){
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
        
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - positive*/
    @isTest
    public static void test_isRequired_positive(){
        System.runAs(fetchCitizenUser()){                      
            SSP_Application__c app = new SSP_Application__c();
            app.Id = [SELECT Id FROM SSP_Application__c LIMIT 1][0].Id;
            app.ProgramsApplied__c = 'MA';
            update app;
                
            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Application__r.ProgramsApplied__c, ProgramsApplied__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            
            ContextData ctxData = new ContextData();
            ctxData.ApplicationId = app.Id;
            ctxData.queueObject = qWrap;
            
            test.startTest();
            Boolean result = new SSP_IncomeSelectionScreenQueueRule().isRequired(null, ctxData);
            system.assert(result);
            test.stopTest();
        }
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - negative*/
    @isTest
    public static void test_isRequired_negative(){
        System.runAs(fetchCitizenUser()){
           SSP_Application__c app = new SSP_Application__c();
            app.Id = [SELECT Id FROM SSP_Application__c LIMIT 1][0].Id;
            app.ProgramsApplied__c = 'KP';
            update app;
                
            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id FROM SSP_ApplicationIndividual__c LIMIT 1];
            
            ContextData ctxData = new ContextData();
            ctxData.ApplicationId = app.Id;
            ctxData.queueObject = qWrap;
            
            test.startTest();
            Boolean result = new SSP_IncomeSelectionScreenQueueRule().isRequired(null, ctxData);
            system.assert(!result);
            test.stopTest();
        }        
    }

}