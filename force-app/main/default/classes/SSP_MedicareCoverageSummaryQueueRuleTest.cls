/*
* classname     :  SSP_MedicareCoverageSummaryQueueRuleTest
* @description  :  Test class for SSP_MedicareCoverageSummaryQueueRule
* @author       :  Varun Kochar 
* @date         :  17/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_MedicareCoverageSummaryQueueRuleTest {
    @testSetup
    static void setupTestData() {
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
        lstAppln[0].ProgramsApplied__c = SSP_GlobalConstants.STATE+';'+SSP_GlobalConstants.MEDICAID;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].Name='TestMember';
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].IsReceivingMedicareBenefitToggle__c = 'Y';
        insert lstMem;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c  = SSP_GlobalConstants.STATE+';'+SSP_GlobalConstants.MEDICAID;
        insert lstAppInd;        
    }
    
    @isTest
    public static void test_isRequired_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Member__c> memberList = [Select Id,IsReceivingMedicareBenefitToggle__c from SSP_Member__c];
            if(!memberList.isEmpty()){
                memberList[0].IsReceivingMedicareBenefitToggle__c = SSP_GlobalConstants.NO;
            }
            update memberList;
            //List<SSP_Application__c> applicationList = [Select Id from SSP_Application__c];
            List<SSP_ApplicationIndividual__c> appIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, IsHeadOfHousehold__c, SSP_Member__r.IsReceivingMedicareBenefitToggle__c, ProgramsApplied__c FROM SSP_ApplicationIndividual__c];
            ContextData ctxData = SSP_TestDataFactory.createContextData(appIndividualList);            
            ctxData.MemberId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Member__c : null;
            ctxData.ApplicationId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Application__c : null;            
            Test.startTest();
            Boolean result = new SSP_MedicareCoverageSummaryQueueRule().isRequired(new Context(), ctxData);
            system.assert(!result);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void test_isRequired_positive(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Member__c> memberList = [Select Id,IsReceivingMedicareBenefitToggle__c from SSP_Member__c];
            if(!memberList.isEmpty()){
                memberList[0].IsReceivingMedicareBenefitToggle__c = SSP_GlobalConstants.YES;
            }
            update memberList;
            //List<SSP_Application__c> applicationList = [Select Id from SSP_Application__c];
            List<SSP_ApplicationIndividual__c> appIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, IsHeadOfHousehold__c, SSP_Member__r.IsReceivingMedicareBenefitToggle__c, ProgramsApplied__c FROM SSP_ApplicationIndividual__c];
            ContextData ctxData = SSP_TestDataFactory.createContextData(appIndividualList);            
            ctxData.MemberId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Member__c : null;
            ctxData.ApplicationId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Application__c : null;            
            Test.startTest();
            Boolean result = new SSP_MedicareCoverageSummaryQueueRule().isRequired(new Context(), ctxData);
            system.assert(result);
            Test.stopTest();
        }
        
    }
     
    @isTest
    public static void test_isRequired_exception(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            List<SSP_Member__c> memberList = [Select Id,IsReceivingMedicareBenefitToggle__c from SSP_Member__c];
            if(!memberList.isEmpty()){
                memberList[0].IsReceivingMedicareBenefitToggle__c = SSP_GlobalConstants.YES;
            }
            update memberList;
            List<SSP_ApplicationIndividual__c> appIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c FROM SSP_ApplicationIndividual__c];
            ContextData ctxData = SSP_TestDataFactory.createContextData(appIndividualList);
            
            ctxData.MemberId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Member__c : null;
            ctxData.ApplicationId = !appIndividualList.isEmpty() ? appIndividualList[0].SSP_Application__c : null;
            Test.startTest();
            Boolean result = new SSP_MedicareCoverageSummaryQueueRule().isRequired(new Context(), ctxData);
            system.assert(result != null);
            Test.stopTest();
        }
        
    }
}