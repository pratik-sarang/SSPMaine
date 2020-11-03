/*
* classname     : SSP_LivingArrangementQueueingRuleTest
* @description  : A test class for SSP_LivingArrangementQueueingRule class.
* @author       : Samridh Manucha
* @date         : JAN-29-2020
* MODIFICATION LOG:
* DEVELOPER             DATE                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Samridh Manucha      JAN-29-2020         Initial Version
*/
@isTest(seeAllData=false)
public class SSP_LivingArrangementQueueingRuleTest {
    
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
        lstAppln[0].ProgramsApplied__c = 'MA;SN';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].TemporarilyLivesElsewhereToggle__c = SSP_GlobalConstants.NO;
        lstMem[1].TemporarilyLivesElsewhereToggle__c = SSP_GlobalConstants.YES;
        for(SSP_Member__c member : lstMem) {
            member.Contact__c = lstCon[0].Id;
        }
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
    
    public static string sspMemberDetails(string temporarilyLivesElsewhere)
    {
      ContextData ctxData = new ContextData();
      ctxData.memberId = [SELECT Id FROM SSP_Member__c WHERE TemporarilyLivesElsewhereToggle__c =: temporarilyLivesElsewhere LIMIT 1].Id;   
      return ctxData.memberId;
    }
    
    @isTest
    public static void unitTest1() {
        ContextData ctxData = new ContextData();
        ctxData.memberId = sspMemberDetails(SSP_GlobalConstants.YES);
        Test.startTest();
        Boolean result = new SSP_LivingArrangementQueueingRule().isRequired(null, ctxData);
        System.assertequals(result, false);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest2() {
        ContextData ctxData = new ContextData();
        ctxData.memberId = sspMemberDetails(SSP_GlobalConstants.NO);
        Test.startTest();
        Boolean result = new SSP_LivingArrangementQueueingRule().isRequired(null, ctxData);
        System.assert(!result);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest3() {
        List<SSP_ApplicationIndividual__c> lstAppInd = [SELECT Id, ProgramsApplied__c,SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c];
        ContextData ctxData = SSP_TestDataFactory.createContextData(lstAppInd);
        ctxData.memberId = lstAppInd[0].SSP_Member__c;
        ctxData.ApplicationId = lstAppInd[0].SSP_Application__c;
        Test.startTest();
        Boolean result = new SSP_LivingArrangementQueueingRule().isRequired(null, ctxData);
         Boolean resultNegative = new SSP_LivingArrangementQueueingRule().isRequired(null, null);
        
        System.assert(result);
        Test.stopTest();
    }
        
    @isTest
    public static void unitTest4() {
        User citizen  = getCitizenUser();
        System.runAs(citizen){
        List<SSP_Application__c> lstApps = getApplications();
        List<SSP_ApplicationIndividual__c> individual = getApplicationIndividuals(lstApps[0].Id) ;
        Test.startTest();
        Boolean response = SSP_LivingArrangementQueueingRule.isProgramApplied(individual[0].SSP_Member__c, individual[0].SSP_Application__c);
        System.assertequals(response , true);
        Test.stopTest();
        }
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