/*
* classname 	: SSP_HouseHoldMealRuleTest
* @description 	: Test class for SSP_HouseHoldMealRule class.
* @author 		: Suyash Singhal
* @date 		: DEC-2-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Suyash Singhal 		DEC-2-2019			Initial Version
*/


@isTest(seeAllData=false)
public with sharing class SSP_HouseHoldMealRuleTest {

     /**
    @author : Suyash Singhal
    Method to setup test data*/

    @testSetup
    public static void testDataSetup() {

        SSP_TestDataFactory.setupTestData();
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];
       
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(2, false);
        lstAcc[0].Name = 'RuleController';
         lstAcc[1].Name = 'RuleController2';
        insert lstAcc;
        
       List<Contact> contList = SSP_TestDataFactory.createContacts(1, false);
        Contact cont = contList.get(0);
        cont.accountId =  lstAcc[1].Id;
        insert cont;           
   
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
       AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = lstAcc[1].Id;
        acr1.Contactid = lstCon[0].Id;
        acr1.IsActive = true;
        insert acr1;

        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'SN';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].contact__c=lstCon[0].Id;
        lstMem[1].contact__c=contList[0].Id;  
        lstMem[0].IsHeadOfHousehold__c= true; 
        insert lstMem;
        
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[1].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[1].SSP_Member__c=lstMem[1].Id;
        lstAppInd[1].IsHeadOfHousehold__c = true;
        insert lstAppInd;
               
    }
    
     private static List<SSP_ApplicationIndividual__c> queryApplicationIndividual(String applicationId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__c, IsHeadOfHousehold__c , SSP_Application__r.ProgramsApplied__c 
                 FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId]);
    }

    /* @author : Suyash Singhal
    Test Method to test isRequiredTest method*/
    @isTest
    public static void isRequiredTest (){

        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
           
            ContextData ctxData = new ContextData();
          
            List<SSP_Application__c> lstApps = [SELECT Id,ProgramsApplied__c  FROM SSP_Application__c LIMIT 1];
            
            List<SSP_ApplicationIndividual__c> appIndList = queryApplicationIndividual(lstApps[0].Id);
		           
            QueuingWrapper qwrap = new QueuingWrapper ();
            qwrap.applicationIndividualList = appIndList;           
            ctxData.recordId = lstApps[0].Id;
            ctxData.queueObject = qwrap;
            ctxData.ApplicationId= lstApps[0].Id;
           for(SSP_ApplicationIndividual__c appMem :appIndList){
                if(appMem.IsHeadOfHousehold__c){
                    ctxData.memberId = appMem.SSP_Member__c;
                }
            }

            Test.Starttest();                
            Boolean bresult = new SSP_HouseHoldMealRule().isRequired(null,ctxData);
            system.assertNotEquals(false, bresult);
            Boolean bresult2 = new SSP_HouseHoldMealRule().isRequired(null,null);
            system.assertNotEquals(true, bresult2);
            Test.StopTest();

        }

    }
    
}