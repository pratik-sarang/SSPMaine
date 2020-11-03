/*
* classname 	: SSP_PregnancyScreenControllerTest
* @description 	: Test class for SSP_PregnancyScreenController class.
* @author 		: Shivam Tiwari
* @date 		: DEC-20-2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 				DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Shivam Tiwari 		DEC-20-2019			Initial Version
*/
@isTest
public class SSP_PregnancyScreenControllerTest {
    
    @testSetup
    public static void setup(){
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'TestAcc';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];		
        
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
        lstMem[0].Name='TestMember';
        lstMem[0].contact__c=lstCon[0].Id;
		lstMem[0].IndividualId__c='999015638';        
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
    
    @isTest
    public static void getPregnancyScreenDataTest(){
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            Test.startTest();
            SSP_PregnancyScreenController.getPregnancyScreenData(lstApps[0].Id, lstMem[0].Id);
            SSP_PregnancyScreenController.createTrackDeletion(lstApps[0].Id, lstMem[0].Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getPregnancyScreenDataTest2(){
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            Test.startTest();
            SSP_PregnancyScreenController.getPregnancyScreenData(null, null);
            SSP_PregnancyScreenController.createTrackDeletion(null, null);
            Test.stopTest();
        }
    }
    
    private static User getCitizenUser(){
        return ([SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]);
    }
    
    private static List<SSP_Application__c> getApplications(){
        return ([SELECT Id, Name FROM SSP_Application__c LIMIT 1]);
    }

}