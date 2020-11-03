/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_HouseHoldMealsTest
*   Created By   :   Suyash Singhal
*   Created Date :   11/13/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/13/2019        Initial Version
*****************************************************************************************************************************/


@isTest(seeAllData=false)
public with sharing class SSP_HouseHoldMealsTest {

    /**
    @author : Suyash Singhal
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
        lstAppln[0].ProgramsApplied__c = 'SN';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].IsHeadOfHousehold__c= true; 
        insert lstMem;
        
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;   
        
    }

    /**
    @author : Suyash Singhal
    Test Method to test fetchHouseHoldData method*/
    @isTest
    public static void fetchHouseHoldDataTest(){

        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            
            List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 1];
            if(!lstApps.isEmpty()){
                List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: lstApps[0].Id]  ;
                List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50];
                List<String> lstAppids = new List<String>();
                lstAppids.add(String.valueOf(lstApps[0].Id)); 
                
                test.startTest();
                SSP_LightningResponse response = SSP_HouseHoldMeals.fetchHouseHoldData(String.valueOf(lstAppids[0]) , 'Intake');
                system.assertNotEquals(null, response.mapResponse);
                
                test.stopTest();
            }
        }


    }

    /**
    @author : Suyash Singhal
    Test Method to test saveDataTest method*/
    @isTest
    public static void saveDataTest(){

        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];

        System.runAs(citizen){
            
            List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 1];
            if(!lstApps.isEmpty()){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c != null AND SSP_Application__c =: lstApps[0].Id] ;
            
            //List<SSP_Member__c> lstMembers =  [SELECT Id, HasEarnedIncomeFromEmployment__c, HasInsuranceSettlementBenefit__c, HasMaintenanceIncome__c, HasReceivedBenefitsFromOtherState__c, HasSelfEmploymentIncome__c, HasServicesorPayments__c, HasUnearnedIncome__c, HasUnpaidEmployment__c, HasDividendsRoyalties__c FROM SSP_Member__c LIMIT 50];
                String sMemberIds ='';

                for(SSP_Member__c objMem :[SELECT Id  FROM SSP_Member__c LIMIT 50]){
                
                    sMemberIds += objMem.id + ',';

                }
                sMemberIds = sMemberIds.removeEnd(',');
                
                test.startTest();
                SSP_LightningResponse response = SSP_HouseHoldMeals.saveData(sMemberIds,String.valueOf(lstApps[0].Id),'Intake');
                system.assertNotEquals(null, response.mapResponse);
                
                SSP_LightningResponse response2 = SSP_HouseHoldMeals.saveData(sMemberIds,String.valueOf(lstApps[0].Id),'addRemoveMember');
                system.assertNotEquals(null, response2.mapResponse);
                
                            
                test.stopTest();
            }
        }


    }

    /**
    @author : Suyash Singhal
    Test Method to Negative test ExceptionsTest method*/
    @isTest
    public static void exceptionsTest(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            
            List<SSP_Application__c> lstApps = [SELECT Id  FROM SSP_Application__c LIMIT 1];

            if(!lstApps.isEmpty()){
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c != null AND SSP_Application__c =: lstApps[0].Id] ;
                List<SSP_Member__c> lstMembers =  [SELECT Id FROM SSP_Member__c LIMIT 50];
                
                
                test.startTest();
                SSP_LightningResponse response = SSP_HouseHoldMeals.fetchHouseHoldData('123456789' , 'Intake');

                SSP_LightningResponse response2 = SSP_HouseHoldMeals.saveData('123456789' , '1234534' ,'Intake');
                
                system.assertNotEquals(null, response.mapResponse);
                system.assertNotEquals(null, response2.mapResponse); 
                            
                test.stopTest();
            }
        }   
    }
}