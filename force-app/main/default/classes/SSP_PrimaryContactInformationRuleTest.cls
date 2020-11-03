/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_PrimaryContactInformationRuleTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   02/03/2019
*   Description  :   Test class for SSP_PrimaryContactInformationRule
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 02/03/2019     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_PrimaryContactInformationRuleTest {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/03/2019
    * @methodname   isRequiredTest
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest(){
        List<Account> accList = SSP_TestDataFactory.createAccounts(1, false);
        Account acc = accList.get(0);
        insert acc;
        
        List<Contact> contList = SSP_TestDataFactory.createContacts(1, false);
        Contact cont = contList.get(0);
        cont.accountId = acc.Id;
        insert cont;
        
        List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(1, false);
        SSP_Member__c mem = memList.get(0);
        mem.Contact__c = cont.Id;
        insert mem;
        
        List<SSP_Application__c> appList = SSP_TestDataFactory.createSSPApplications(1, false);
        SSP_Application__c app = appList.get(0);
        app.Account__c = acc.Id;
        insert app;
        Id appId = app.Id;
        
        List<SSP_ApplicationIndividual__c> appIndvList = SSP_TestDataFactory.createApplicationIndividuals(1, false);
        SSP_ApplicationIndividual__c appIndv = appIndvList.get(0);
		appIndv.SSP_Member__c = mem.Id;
        appIndv.SSP_Application__c = appId;
        appIndv.ProgramsApplied__c = 'MA;DS;KP;CC';
        insert appIndv;
        
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = mem.Id;
        ctxData.ApplicationId = appId;
        
        SSP_PrimaryContactInformationRule cls = new SSP_PrimaryContactInformationRule();
        boolean result = cls.isRequired(ctx, ctxData);
        System.assertEquals(result, true);
        
        mem.IsHeadOfHousehold__c = true;
        update mem;
        
        boolean result1 = cls.isRequired(ctx, ctxData);
        System.assertEquals(result, true);
        
        boolean result2 = cls.isRequired(null, null);
        System.assertEquals(result2, false);
    }
}