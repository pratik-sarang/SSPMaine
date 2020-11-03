/*
* classname     :  SSP_IncomeControllerTest
* @description  :  Test class for SSP_IncomeController
* @author       :  Shrikant Raut   
* @date         :  11/19/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_IncomeControllerTest {
    /**
@author : Shrikant Raut
Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
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
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        insert lstMem;
        
              List<SSP_Asset__c> lstAsset = SSP_TestDataFactory.createAssets(8, 'Income',false);
        lstAsset[0].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income'); 
        lstAsset[0].SSP_Member__c = lstMem[0].Id;
        lstAsset[0].IncomeTypeCode__c ='DIR';
        lstAsset[1].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[1].SSP_Member__c = lstMem[0].Id;
        lstAsset[1].IncomeTypeCode__c ='UI';
        lstAsset[2].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[2].SSP_Member__c = lstMem[0].Id;
        lstAsset[2].IncomeTypeCode__c ='EA';
        lstAsset[3].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[3].SSP_Member__c = lstMem[0].Id;
        lstAsset[3].IncomeTypeCode__c ='SE';
        lstAsset[4].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[4].SSP_Member__c = lstMem[0].Id;
        lstAsset[4].IncomeTypeCode__c ='SRP';
        lstAsset[5].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[5].SSP_Member__c = lstMem[0].Id;
        lstAsset[5].IncomeTypeCode__c ='SM';
        lstAsset[6].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[6].SSP_Member__c = lstMem[0].Id;
        lstAsset[6].IncomeTypeCode__c ='IS';
        lstAsset[7].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[7].SSP_Member__c = lstMem[0].Id;
        lstAsset[7].IncomeTypeCode__c ='OUI';
        insert lstAsset;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;   
        
    }
    
    /**
@author : Shrikant Raut
Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_fetchExistingIncomeDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'IncomeController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, IsExistingData__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            
            test.startTest();
            
            String jsonResponse = SSP_IncomeController.fetchExistingIncomeDetails(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, null);
            String jsonResponseRemoveIncome = SSP_IncomeController.fetchExistingIncomeDetails(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, 'sspRemoveExistingIncome');
            Map<String, Object> detailMap =  (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            
            system.assertEquals(true, detailMap.containsKey('incomeRecords'));
            system.assertEquals(true, detailMap.containsKey('applicationIndividual'));
            test.stopTest();
        }
        
    }
    
    /**
@author : Shrikant Raut
Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateExistingIncomeRecords(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = [SELECT Id, TotalGrossAmount__c FROM SSP_Asset__c];
            Integer oldValue = (Integer)assetList[0].TotalGrossAmount__c;
            String assetId = assetList[0].Id;
            test.startTest();
            assetList[0].TotalGrossAmount__c = 1111;
            SSP_IncomeController.updateExistingIncomeRecords(JSON.serialize(assetList));
            Integer newValue = (Integer)[SELECT Id, TotalGrossAmount__c FROM SSP_Asset__c WHERE Id = :assetId LIMIT 1][0].TotalGrossAmount__c;
            system.assertNotEquals(oldValue, newValue);
            system.assertEquals(1111, newValue);
            test.stopTest();
        }
    }
    
    
    /**
@author : Shrikant Raut
Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateExistingIncomeRecords_False(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = new List<SSP_Asset__c>();
            SSP_Asset__c assetTmp = new SSP_Asset__c();
            assetList.add(assetTmp);
            test.startTest();
            Boolean result = SSP_IncomeController.updateExistingIncomeRecords(JSON.serialize('test'));
            
            
            system.assertEquals(false, result);
            test.stopTest();
        }
    }
    
    
    
    /**
@author : Shrikant Raut
Test Method to test deleteIncomeRecord method*/
    @isTest
    public static void test_deleteIncomeRecord(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = [SELECT Id FROM SSP_Asset__c];
            test.startTest();
            SSP_IncomeController.deleteIncomeRecord(assetList[0].Id);
            system.assertEquals(assetList.size()-1, [SELECT COUNT() FROM SSP_Asset__c]);
            test.stopTest();
        }
    }
    
    /**
@author : Shrikant Raut
Test Method to test deleteIncomeRecord method*/
    @isTest
    public static void test_deleteIncomeRecord_False(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Asset__c> assetList = [SELECT Id FROM SSP_Asset__c];
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
            test.startTest();
            SSP_IncomeController.deleteIncomeRecord(memberList[0].Id);
            system.assertEquals(assetList.size(), [SELECT COUNT() FROM SSP_Asset__c]);
            test.stopTest();
        }
    }
 /**@author : Kireeti Gora
Test Method to test getIncomeDetailsWithId method*/
    @isTest
    public static void test_getIncomeDetailsWithId(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
             List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'IncomeController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, IsExistingData__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            
            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
            test.startTest();
            SSP_LightningResponse sIncomeObj = SSP_IncomeController.getIncomeDetailsWithId(assetList[0].id,appIndvList[0].SSP_Application__c,appIndvList[0].SSP_Member__c);      
            system.assertNotEquals(null,sIncomeObj);
            test.stopTest();
        }
    }
/**@author : Kireeti Gora
Test Method to test getIncomeDetailsWithId method*/
    @isTest
    public static void test_getIncomeDetailsWithId_False(){ 
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
            SSP_LightningResponse sIncomeObj = SSP_IncomeController.getIncomeDetailsWithId(null,null,null);      
            system.assertNotEquals(null,sIncomeObj);
            test.stopTest();
        }
    }
/**@author : Kireeti Gora
Test Method to test getDuplicateEmployerIncomeDetails method*/
    @isTest
    public static void test_getDuplicateEmployerIncomeDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
             List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'IncomeController'];
            
            List<SSP_Asset__c> assetList = [SELECT Id, Name, BusinessTypeCode__c, EmployerName__c, IsExistingData__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
           
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
            Test.startTest();
            SSP_LightningResponse sIncomeObj = SSP_IncomeController.getIncomeDetailsWithId(assetList[0].id,appIndvList[0].SSP_Application__c,appIndvList[0].SSP_Member__c);     
            String sRetrievedIncomeObj = SSP_IncomeController.getDuplicateEmployerIncomeDetails(JSON.serialize(assetList[0]));
            system.assertEquals('',sRetrievedIncomeObj);
            Test.stopTest();
        }
    }
/**@author : Kireeti Gora
Test Method to negative test getDuplicateEmployerIncomeDetails method*/
    @isTest
    public static void test_getDuplicateEmployerIncomeDetails_False(){      
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
            String sIncomeObj = SSP_IncomeController.getDuplicateEmployerIncomeDetails(null);      
            system.assertEquals('',sIncomeObj);
            test.stopTest();
        }
    }
/**@author : Kireeti Gora
Test Method to test setIncomeDetails method*/
    @isTest
    public static void test_setIncomeDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
 List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'IncomeController'];
            
            List<SSP_Member__c> memberList = [SELECT Id FROM SSP_Member__c];
               List<SSP_Asset__c> assetList = [SELECT Id, Name, SSP_Member__c,BusinessTypeCode__c, EmployerName__c, IsExistingData__c, Tips__c, IncomeTypeCode__c, IncomePayFrequency__c, TotalGrossAmount__c, IncomePayDetailHoursPerWeek__c FROM SSP_Asset__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
           
            Test.startTest();
                for(SSP_Asset__c asset:assetList){
            String sRetrievedIncomeObj = SSP_IncomeController.setIncomeDetails(JSON.serialize(asset),appIndvList[0].SSP_Application__c);
            String sRetrievedIncomeObj1 = SSP_IncomeController.setIncomeDetails(JSON.serialize(asset),appIndvList[0].SSP_Application__c);
            system.assertNotEquals('',sRetrievedIncomeObj);
            system.assertNotEquals('',sRetrievedIncomeObj1);
            
                }
            Test.stopTest();
        }
    }
/**@author : Kireeti Gora
Test Method to test setIncomeDetails method*/
    @isTest
    public static void test_setIncomeDetails_False(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            Test.startTest();
            
            String sRetrievedIncomeObj = SSP_IncomeController.setIncomeDetails('','');
            system.assertEquals('',sRetrievedIncomeObj);
            Test.stopTest();
        }
    }
}