/*
* classname     : SSP_ConvictionQueueingRuleTest
* @description  : A test class for SSP_ConvictionQueueingRule class.
* @author       : Samridh Manucha
* @date         : JAN-21-2020
* MODIFICATION LOG:
* DEVELOPER             DATE                DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Samridh Manucha      JAN-21-2020         Initial Version
*/
@isTest
public class SSP_ConvictionQueueingRuleTest {
    
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
        lstAppln[0].HasConvictedCrimeToggle__c = SSP_GlobalConstants.YES; 
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].ProgramsApplied__c = SSP_GlobalConstants.SNAP;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);        
        for(SSP_Member__c member : lstMem) {
            member.Contact__c = lstCon[0].Id;
        }
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].IsHeadOfHousehold__c = false;
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].ProgramsApplied__c = SSP_GlobalConstants.SNAP;
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;       
        insert lstAppInd;
    }
   
    public static string sspMemberDetails()
    {
      ContextData ctxData = new ContextData();
      ctxData.memberId = [SELECT Id FROM SSP_Member__c LIMIT 1].Id;   
      return ctxData.memberId;
    } 
    
    @isTest
    public static void unitTest2() {
        User citizen  = getCitizenUser();
        System.runAs(citizen){ 
        List<SSP_Application__c> lstApps = getApplications();
        List<SSP_ApplicationIndividual__C> appIndList = getApplicationIndividuals(lstApps[0].Id);
        ContextData ctxData = SSP_TestDataFactory.createContextData(appIndList);
        ctxData.memberId = !appIndList.isEmpty() ? appIndList[0].SSP_Member__c : null;
        ctxData.applicationId = !appIndList.isEmpty() ? appIndList[0].SSP_Application__c : null;
        Test.startTest();
        Boolean result = new SSP_ConvictionQueueingRule().isRequired(null, ctxData);
        System.assert(!result);
        Test.stopTest();
        }
    }
    
    @isTest
    public static void unitTest3() {
        List<SSP_Application__c> lstApps = getApplications();
        if(!lstApps.isEmpty()){
            lstApps[0].HasConvictedCrimeToggle__c = SSP_GlobalConstants.YES;
            update lstApps;
        }        
        List<SSP_ApplicationIndividual__C> appIndList =[SELECT Id, SSP_Member__c, SSP_Application__c,ProgramsApplied__c,SSP_Application__r.HasConvictedCrimeToggle__c FROM SSP_ApplicationIndividual__c LIMiT 1];
        ContextData ctxData = SSP_TestDataFactory.createContextData(appIndList);
        ctxData.memberId = !appIndList.isEmpty() ? appIndList[0].SSP_Member__c : null;
        ctxData.applicationId = lstApps[0].id;
        Test.startTest();
        Boolean result = new SSP_ConvictionQueueingRule().isRequired(null, ctxData);
        System.assert(!result);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest4() {
        List<SSP_Application__c> lstApps = getApplications();
        if(!lstApps.isEmpty()){
            lstApps[0].HasConvictedCrimeToggle__c = SSP_GlobalConstants.YES;
            update lstApps;
        }        
        List<SSP_ApplicationIndividual__C> appIndList = getApplicationIndividuals(lstApps[0].Id);
        if(!appIndList.isEmpty()){
            appIndList[0].IsHeadOfHousehold__c = true;
            update appIndList;
        }
        ContextData ctxData = SSP_TestDataFactory.createContextData(appIndList);
        ctxData.memberId = !appIndList.isEmpty() ? appIndList[0].SSP_Member__c : null;
        ctxData.applicationId = lstApps[0].id;
        Test.startTest();
        Boolean result = new SSP_ConvictionQueueingRule().isRequired(null, ctxData);
        System.assert(result);
        Test.stopTest();
    }
    
    private static List<SSP_Application__c> getApplications(){
        return ([SELECT Id,ProgramsApplied__c,HasConvictedCrimeToggle__c FROM SSP_Application__c LIMIT 1]);
    }
    
    private static User getCitizenUser(){
        return ([SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]);
    }
    
    private static List<SSP_ApplicationIndividual__c> getApplicationIndividuals(String appsId){
        return ([SELECT Id, SSP_Member__c, SSP_Application__c,ProgramsApplied__c,SSP_Application__r.HasConvictedCrimeToggle__c,IsHeadOfHousehold__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: appsId]);
    }

}