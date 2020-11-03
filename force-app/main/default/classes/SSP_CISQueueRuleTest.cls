/*
* classname     :  SSP_CISQueueRuleTest
* @description  :  Test class for SSP_CISQueueRule
* @author       :  Chandra Shekhar 
* @date         :  05/11/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_CISQueueRuleTest {
   
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'CiSController';
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
    
    @isTest
    public static void test_isRequired_positive(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]; 
        System.runAs(citizen){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            sessionPart.put('SS',true);
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();
            List<SSP_ApplicationIndividual__c> appIndv = [SELECT Id, SSP_Application__c, SSP_Member__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            
            for(SSP_Member__c member : [SELECT Id FROM SSP_Member__c WHERE Id = :appIndv[0].SSP_Member__c LIMIT 1]){
                member.IsRequestingOrReceivingCISToggle__c = 'Y';
                memberList.add(member);
            }
            
            update memberList;

            QueuingWrapper qWrap = new QueuingWrapper();
            qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Application__r.ProgramsApplied__c, SSP_Member__r.IsRequestingOrReceivingCISToggle__c FROM SSP_ApplicationIndividual__c LIMIT 1];
            ContextData ctxData = new ContextData();
            ctxData.MemberId = appIndv[0].SSP_Member__c;
            ctxData.ApplicationId = appIndv[0].SSP_Application__c;
            ctxData.queueObject = qWrap;
            test.startTest();
            Boolean result = new SSP_CISQueueRule().isRequired(null, ctxData);
            system.assert(result);
            test.stopTest();
        }
        
    }   
    
    @isTest
    public static void test_isRequired_negative(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();
            
            for(SSP_Member__c member : [SELECT Id FROM SSP_Member__c LIMIT 1]){
                member.IsRequestingOrReceivingCISToggle__c = 'N';
                memberList.add(member);
            }
            
            update memberList;

            ContextData ctxData = new ContextData();
            ctxData.MemberId = 'memberList[0].Id';
            ctxData.ApplicationId = 'memberList[0].Id';
            
            test.startTest();
            Boolean result = new SSP_CISQueueRule().isRequired(null, ctxData);
            system.assert(!result);
            test.stopTest();
        }
        
    }
}