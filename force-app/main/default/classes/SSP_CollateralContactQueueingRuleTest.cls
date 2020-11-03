/*
* classname     :  SSP_CollateralContactQueueingRuleTest
* @description  :  Test class for SSP_CollateralContactQueueingRule
* @author       :  Rahul Kumar
* @date         :  16/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
 Rahul                          16/06/2020                         Queue rule for collateral contact screen
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_CollateralContactQueueingRuleTest {
	
       /**
    @author : Rahul
    Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'CollateralContactData';
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
        lstAppln[0].ProgramsApplied__c = 'MA;SN;KT;KP;CC';
        lstAppln[0].Contact_Name__c='Test';
        lstAppln[0].Contact_Phone_Number__c='897-686-8765'; 
        lstAppln[0].Relationship_To_You__c='Father';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].ReceivesEntitledIncomeToggle__c = 'Y';
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'MA;SN;KT;KP;CC';
        insert lstAppInd;   
        
    }
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    /**
    @author : Rahul
    Test Method to test isRequired method - positive*/
    @isTest
    public static void queueRuleTest(){
        SSP_CollateralContactQueueingRule queueRule = new SSP_CollateralContactQueueingRule();
        Boolean isRequired = false;
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> applicationIndividualList = new List<SSP_ApplicationIndividual__c>();
        SSP_Member__c objMember = [SELECT ID FROM SSP_Member__c Limit 1];
        SSP_Application__c objApp = [SELECT ID FROM SSP_Application__c Limit 1];
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        
        ctxData.MemberId = objMember.Id;
        ctxData.ApplicationId = objApp.Id;
        SSP_ApplicationIndividual__c objAppInd = [Select ID, SSP_Member__c, ProgramsApplied__c,SSP_Application__r.IsApplicationSubmittedEarly__c From SSP_ApplicationIndividual__c LIMIT 1];
        memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        applicationIndividualList.add(objAppInd);
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        queWrap.applicationIndividualList = applicationIndividualList;
        ctxData.queueObject = queWrap;
        System.runAs(fetchCitizenUser()) {
            isRequired = queueRule.isRequired(ctx, ctxData);
        }
    }
    
}