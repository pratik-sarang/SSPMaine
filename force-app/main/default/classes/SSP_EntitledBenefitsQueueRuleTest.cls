/*
* classname     :  SSP_EntitledBenefitsQueueRuleTest
* @description  :  Test class for SSP_EntitledBenefitsQueueRule
* @author       :  Shrikant Raut   
* @date         :  12/06/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_EntitledBenefitsQueueRuleTest {
    /**
    @author : Shrikant Raut
    Method to setup test data*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'EntitledBenefitsController';
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
    
        
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - positive*/
    @isTest
    public static void test_isRequired_positive(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();
            
            for(SSP_Member__c member : [SELECT Id FROM SSP_Member__c LIMIT 1]){
                member.ReceivesEntitledIncomeToggle__c = 'Y';
                memberList.add(member);
            }
            
            update memberList;

            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Member__r.ReceivesEntitledIncomeToggle__c, SSP_Application__r.ProgramsApplied__c, ProgramsApplied__c, SSP_Member__r.IsReceivingCaretakerServicesToggle__c FROM SSP_ApplicationIndividual__c LIMIT 1];            
            qWrap.memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>{qWrap.applicationIndividualList[0].SSP_Member__c => qWrap.applicationIndividualList[0]};
            ContextData ctxData = new ContextData();
            ctxData.MemberId = memberList[0].Id;
            ctxData.queueObject = qWrap;
            
            test.startTest();
            Boolean result = new SSP_EntitledBenefitsQueueRule().isRequired(null, ctxData);
            system.assert(result);
            test.stopTest(); 
        }
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test isRequired method - negative*/
    @isTest
    public static void test_isRequired_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){            
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();                       
            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Member__c FROM SSP_ApplicationIndividual__c LIMIT 1];            
            qWrap.memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>{qWrap.applicationIndividualList[0].SSP_Member__c => qWrap.applicationIndividualList[0]};
                
            ContextData ctxData = new ContextData();
            ctxData.MemberId = qWrap.applicationIndividualList[0].SSP_Member__c;
            ctxData.queueObject = qWrap;
            
            test.startTest();
            Boolean result = new SSP_EntitledBenefitsQueueRule().isRequired(null, ctxData);
            system.assert(!result);
            test.stopTest();
        }
        
    }
}