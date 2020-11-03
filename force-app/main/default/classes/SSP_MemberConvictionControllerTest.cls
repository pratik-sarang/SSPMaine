/***************************************************************************************************
*   Type        :   Controller Test Class
*   Name        :   SSP_MemberConvictionControllerTest
*   Create By   :   Samridh Manucha
*   Create Date :   JAN-21-2020
*   Description :   Test class for SSP_MemberConvictionController.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Samridh Manucha           JAN-21-2020             Initial Version
*
*****************************************************************************************************/
@isTest(seeAllData=false)
public class SSP_MemberConvictionControllerTest {
    @testSetup
    public static void dataSetup() {
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
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
     
    @isTest
    public static void unitTest1() {   
        User citizen  = getCitizenUser();
        System.runAs(citizen){ 
        List<SSP_Application__c> lstApps = getApplications();
        List<SSP_ApplicationIndividual__c> individual = getApplicationIndividuals(lstApps[0].Id) ;     
        Test.startTest();
        SSP_LightningResponse response = SSP_MemberConvictionController.fetchConvictionInformation(individual[0].SSP_Member__c, individual[0].SSP_Application__c);
        System.assert(response.bIsSuccess);
        Test.stopTest();
        }       
    }
    
     @isTest
    public static void unitTest2() {       
        List<SSP_Application__c> lstApps = getApplications();
        List<SSP_ApplicationIndividual__c> individual = getApplicationIndividuals(lstApps[0].Id) ;
        Test.startTest();
        SSP_LightningResponse response = SSP_MemberConvictionController.fetchConvictionInformation(individual[0].SSP_Member__c, '1234%$#5');
        System.assertequals(response.bIsSuccess,false);
        Test.stopTest();        
    }
    
    private static List<SSP_Application__c> getApplications(){
        return ([SELECT Id  FROM SSP_Application__c LIMIT 1]);
    }
    
    private static User getCitizenUser(){
        return ([SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]);
    }
    
    private static List<SSP_ApplicationIndividual__c> getApplicationIndividuals(String appsId){
        return ([SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: appsId]);
    }
    
}