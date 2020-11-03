/*
* classname     :  SSP_EntitledBenefitsControllerTest
* @description  :  Test class for SSP_EntitledBenefitsController
* @author       :  Shrikant Raut   
* @date         :  12/17/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/

@isTest(seeAllData=false)
public class SSP_EntitledBenefitsControllerTest {
 /**
@author : Shrikant Raut
Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'BenefitsController';
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
        
        List<SSP_Benefits__c> lstbenefits = SSP_TestDataFactory.createBenefitRecords(4, 'EntitledBenefit',false);
        lstbenefits[0].SSP_Member__c = lstMem[0].Id;
        lstbenefits[1].SSP_Member__c = lstMem[0].Id;
        lstbenefits[2].SSP_Member__c = lstMem[0].Id;
        lstbenefits[3].SSP_Member__c = lstMem[0].Id;
        insert lstbenefits;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;   
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_fetchBenefitDetails(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'BenefitsController'];
            List<SSP_Benefits__c> benefitList = [SELECT Id, StatusofApplication__c, BenefitTypeCode__c FROM SSP_Benefits__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
                        
            test.startTest();            
            SSP_LightningResponse response = SSP_EntitledBenefitsController.fetchBenefitDetails(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c, 'sspEntitledBenefits');
            system.assertNotEquals(null, response.mapResponse);
            system.assert(response.mapResponse.containsKey('applicationIndividual'));  
            system.assert(response.mapResponse.containsKey('benefitsRecords'));            
            test.stopTest();	
        }
        
    }
    
        /**
@author : Shrikant Raut
Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateBenefits(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'BenefitsController'];
            List<SSP_Benefits__c> benefitList = [SELECT Id, SSP_Member__c, StatusofApplication__c, BenefitTypeCode__c FROM SSP_Benefits__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c];
            Map<String, String>  detailMap = new Map<String, String>{
                'toUpsert'=> JSON.serialize(new List<SSP_Benefits__c>{new SSP_Benefits__c(SSP_Member__c = benefitList[0].SSP_Member__c)}),
                    'toDelete'=> JSON.serialize(benefitList)
            };
            test.startTest();
            system.assertEquals([SELECT COUNT() FROM SSP_Benefits__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c], benefitList.size());
            SSP_EntitledBenefitsController.updateBenefits(detailMap);            
            system.assertEquals([SELECT COUNT() FROM SSP_Benefits__c WHERE SSP_Member__c = :appIndvList[0].SSP_Member__c], 1);
            test.stopTest();
        }
    }
    
    
            /**
@author : Shrikant Raut
Test Method to test fetchExistingIncomeDetails method*/
    @isTest
    public static void test_updateBenefits_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){            
            Map<String, String>  detailMap = new Map<String, String>{
                'toUpsert'=> 'abc',
                    'toDelete'=> null
            };
            test.startTest();            
            SSP_LightningResponse res = SSP_EntitledBenefitsController.updateBenefits(detailMap);    
            system.assertEquals(res.bIsSuccess, false);
            test.stopTest();
        }
    }
}