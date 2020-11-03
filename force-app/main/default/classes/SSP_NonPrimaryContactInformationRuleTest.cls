/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_NonPrimaryContactInformationRuleTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   11/26/2019
*   Description  :   Test class for SSP_NonPrimaryContactInformationRule
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 11/26/2019     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_NonPrimaryContactInformationRuleTest {
    
    @testSetup
    public static void dataSetup() {
        List<Account> accList = SSP_TestDataFactory.createAccounts(2, false);
        Account acc = accList.get(0);
        insert acc;
        
        Account accApp = accList.get(1);
        insert accApp;
        
        List<Contact> contList = SSP_TestDataFactory.createContacts(1, false);
        Contact cont = contList.get(0);
        cont.accountId = acc.Id;
        insert cont;
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = accApp.Id;
        acr.Contactid = cont.Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(1, false);
        SSP_Member__c mem = memList.get(0);
        mem.Contact__c = cont.Id;
        mem.BirthDate__c = Date.newInstance(1998, 10, 02);
        insert mem;
        
        List<SSP_Application__c> appList = SSP_TestDataFactory.createSSPApplications(1, false);
        SSP_Application__c app = appList.get(0);
        app.Account__c = accApp.Id;
        insert app;
        Id appId = app.Id;
        
        List<SSP_ApplicationIndividual__c> appIndvList = SSP_TestDataFactory.createApplicationIndividuals(1, false);
        SSP_ApplicationIndividual__c appIndv = appIndvList.get(0);
		appIndv.SSP_Member__c = mem.Id;
        appIndv.SSP_Application__c = appId;
        appIndv.ProgramsApplied__c = 'MA;DS;KP;CC';
        appIndv.IsHeadOfHousehold__c = false;
        insert appIndv;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   isRequiredTest
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest(){  

		String memberId = queryMember();
        String applicationId = queryApplication();
        SSP_ApplicationIndividual__c appIndv = queryApplicationIndividual(applicationId, memberId);
        
        Map<String,SSP_ApplicationIndividual__c> memberAppIndMap = new Map<String,SSP_ApplicationIndividual__c>();
        memberAppIndMap.put(memberId, appIndv);
        
        QueuingWrapper qwrap = new QueuingWrapper ();
        qwrap.memberAppIndividualMap = memberAppIndMap;
        
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = memberId;
        ctxData.ApplicationId = applicationId;
        ctxData.queueObject = qwrap;
        
        SSP_NonPrimaryContactInformationRule cls = new SSP_NonPrimaryContactInformationRule();        
        Test.startTest();
        boolean result = cls.isRequired(ctx, ctxData);
        System.assertEquals(result, true);
        
        boolean result1 = cls.isRequired(null, null);
        System.assertEquals(result1, false);
        Test.stopTest();
    }
    
    private static Id queryMember(){
        return ([SELECT Id FROM SSP_Member__c LIMIT 1].Id);
    }
    
    private static Id queryApplication(){
        return ([SELECT Id FROM SSP_Application__c LIMIT 1].Id);
    }
    
    private static SSP_ApplicationIndividual__c queryApplicationIndividual(String applicationId, String memberId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__c, IsHeadOfHousehold__c, SSP_Member__r.Age__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId AND SSP_Member__c = :memberId LIMIT 1]);
    }
}