/*
* classname     :  SSP_ExpenseScreenQueueRuleTest
* @description  :  Test class for SSP_ExpenseScreenQueueRule
* @author       :  Shrikant Raut   
* @date         :  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_ExpenseScreenQueueRuleTest {
    /** 
    @author : Shrikant Raut
    Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'ExpenseController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        
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
        
        List<SSP_Asset__c> lstAsset = SSP_TestDataFactory.createAssets(1, 'Expense',false);
        lstAsset[0].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Expense');
        lstAsset[0].SSP_Member__c = lstMem[0].Id;
        lstAsset[0].DCId__c = 123;
        insert lstAsset;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
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
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c LIMIT 1];
            Map<ID, SSP_Asset__c> assetsToUpdate = new Map<Id, SSP_Asset__c>();    
            Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String,List<SSP_Asset__c>>();
            for(SSP_Asset__c expense : [SELECT Id, RecordTypeId, EndDate__c, SSP_Member__c, IsDeleted__c, IsExistingData__c FROM SSP_Asset__c WHERE SSP_Member__c = :memberList[0].Id LIMIT 100]){
                expense.EndDate__c = null;
                assetsToUpdate.put(expense.Id, expense);
                if(!mapMemberAsset.containsKey(expense.SSP_Member__c)){
                    mapMemberAsset.put(expense.SSP_Member__c, new List<SSP_Asset__c>());
                }
                mapMemberAsset.get(expense.SSP_Member__c).add(expense);
            }
            update assetsToUpdate.values();

            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Application__r.ProgramsApplied__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            qWrap.mapMemberAsset = mapMemberAsset;
			
            ContextData ctxData = new ContextData();
            ctxData.MemberId = memberList[0].Id;
            ctxData.queueObject = qWrap;
            test.startTest();
            Boolean result = new SSP_ExpenseScreenQueueRule().isRequired(null, ctxData);
            Boolean result_New = new SSP_ExpenseDetailsQueueRule().isRequired(null, ctxData);
            system.assert(!result_New);
                        
            test.stopTest();
        }
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - positive*/
    @isTest
    public static void test_isRequired_exception(){       
        System.runAs(fetchCitizenUser()){            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c LIMIT 1];  
            Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String,List<SSP_Asset__c>>();
            for(SSP_Asset__c expense : [SELECT Id, SSP_Member__c FROM SSP_Asset__c WHERE SSP_Member__c = :memberList[0].Id LIMIT 100]){                
                if(!mapMemberAsset.containsKey(expense.SSP_Member__c)){
                    mapMemberAsset.put(expense.SSP_Member__c, new List<SSP_Asset__c>());
                }
                mapMemberAsset.get(expense.SSP_Member__c).add(expense);
            }

            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Application__r.ProgramsApplied__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            qWrap.mapMemberAsset = mapMemberAsset;
			
            ContextData ctxData = new ContextData();
            ctxData.MemberId = memberList[0].Id;
            ctxData.queueObject = qWrap;
            test.startTest();
            Boolean result = new SSP_ExpenseScreenQueueRule().isRequired(null, ctxData);
            system.assert(!result);
            
            Boolean result_New = new SSP_ExpenseDetailsQueueRule().isRequired(null, ctxData);
            system.assert(!result_New);
            test.stopTest();
        } 
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - negative*/
    @isTest
    public static void test_isRequired_negative(){
        System.runAs(fetchCitizenUser()){
            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c LIMIT 1];
            Map<ID, SSP_Asset__c> assetsToUpdate = new Map<Id, SSP_Asset__c>();            
            for(SSP_Asset__c expense : [SELECT Id, EndDate__c FROM SSP_Asset__c WHERE SSP_Member__c = :memberList[0].Id LIMIT 100]){
                expense.EndDate__c = System.today();
                assetsToUpdate.put(expense.Id, expense);
            }
            update assetsToUpdate.values();

            ContextData ctxData = new ContextData();
            ctxData.MemberId = memberList[0].Id;
            
            test.startTest();
            Boolean result = new SSP_ExpenseScreenQueueRule().isRequired(null, ctxData);
            system.assert(!result);
            
            Boolean result_New = new SSP_ExpenseScreenQueueRule().isRequired(null, ctxData);
            system.assert(!result_New);
            
            test.stopTest();
        }
        
    }
}