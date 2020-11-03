/*
* classname     :  SSP_CareTakerServicesQueueRuleTest
* @description  :  Test class for SSP_CareTakerServicesQueueRule
* @author       :  Shrikant Raut   
* @date         :  04/16/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_CISCareTakerControllerTest {
    /**
	@author : Shrikant Raut
	Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'CareTakerController';
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
        lstAppln[0].ProgramsApplied__c = 'SS';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;   
        
    }
    
    /**
    @author : Shrikant Raut
	Test Method to test fetchRequiredData method*/
    @isTest
    public static void test_fetchRequiredData(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]; 
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'CareTakerController'];                        
            
            
            test.startTest();
            //For Caretaker 
            SSP_LightningResponse resposne = SSP_CISCareTakerController.fetchRequiredData(appIndvList[0].SSP_Application__c, appIndvList[0].SSP_Member__c, SSP_GlobalConstants.CARE_TAKER_SERVICES);            
            Map<String, Object> detailMap =  resposne.mapResponse;
            
            system.assertEquals(true, detailMap.containsKey(SSP_GlobalConstants.KEY_APP_INDVS));
            system.assertEquals(true, detailMap.containsKey(SSP_GlobalConstants.KEY_ACCESS_DETAILS));

            //For CIS
            resposne = SSP_CISCareTakerController.fetchRequiredData(appIndvList[0].SSP_Application__c, appIndvList[0].SSP_Member__c, SSP_GlobalConstants.CIS);            
            detailMap =  resposne.mapResponse;
            
            system.assertEquals(true, detailMap.containsKey(SSP_GlobalConstants.KEY_APP_INDVS));
            system.assertEquals(true, detailMap.containsKey(SSP_GlobalConstants.KEY_ACCESS_DETAILS));

            //Negative
            resposne = SSP_CISCareTakerController.fetchRequiredData(appIndvList[0].SSP_Application__c, 'ABC', null);            
            system.assert(!resposne.bIsSuccess);
            test.stopTest();
        }
        
    }
    
        /**
	@author : Shrikant Raut
	Test Method to test updateApplicationIndividuals method*/
    @isTest
    public static void test_updateApplicationIndividuals(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'CareTakerController'];                        
            SSP_ApplicationIndividual__c appIndv = new SSP_ApplicationIndividual__c();
            appIndv.Id = appIndvList[0].Id;
            appIndv.IsServiceProvidedSafelyToggle__c = 'Y';
            test.startTest();
            //Positive
            SSP_CISCareTakerController.updateApplicationIndividuals(JSON.serialize(new List<SSP_ApplicationIndividual__c>{appIndv}));
            
            appIndvList = [SELECT Id, SSP_Member__c, IsServiceProvidedSafelyToggle__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'CareTakerController'];                        
            system.assertEquals('Y', appIndvList[0].IsServiceProvidedSafelyToggle__c);
            
            //Negative
            SSP_LightningResponse response = SSP_CISCareTakerController.updateApplicationIndividuals('test');
            system.assert(!response.bIsSuccess);
            test.stopTest();
        }
    }
    
}