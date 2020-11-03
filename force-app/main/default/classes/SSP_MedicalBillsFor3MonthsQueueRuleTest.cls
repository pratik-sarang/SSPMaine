/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_MedicalBillsFor3MonthsQueueRuleTest
*   Created By   :   Naveena Malapati
*   Created Date :   03/12/2020
*   Description  :   Test class for SSP_MedicalBillsFor3MonthsQueueRule
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Naveena                 03/12/2020     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_MedicalBillsFor3MonthsQueueRuleTest {
/********************************************************************************************
    * @author       Naveena Malapati
    * @date         03/12/2020
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
        mem.HasMedicalBillsToggle__c='Y';
        mem.BirthDate__c=Date.newInstance(2008, 1, 30);
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
        insert appIndv;
        
        QueuingWrapper qWrap = new QueuingWrapper();
        qWrap.applicationIndividualList = [SELECT Id, SSP_Application__c, SSP_Member__c, SSP_Member__r.ReceivesEntitledIncomeToggle__c, SSP_Application__r.ProgramsApplied__c, ProgramsApplied__c, SSP_Member__r.IsReceivingCaretakerServicesToggle__c FROM SSP_ApplicationIndividual__c LIMIT 1];             
        qWrap.memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>{qWrap.applicationIndividualList[0].SSP_Member__c => qWrap.applicationIndividualList[0]};
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = mem.Id;
        ctxData.ApplicationId = appId;
        ctxData.queueObject = qWrap;
        
        SSP_MedicalBillsFor3MonthsQueueRule cls = new SSP_MedicalBillsFor3MonthsQueueRule();
        boolean result = cls.isRequired(ctx, ctxData);
        System.assertEquals(result, false);
        
        boolean result1 = cls.isRequired(null, null);
        System.assertEquals(result1, false);
    }
}