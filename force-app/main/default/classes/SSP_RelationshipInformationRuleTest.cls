/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_RelationshipInformationRuleTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   02/03/2019
*   Description  :   Test class for SSP_RelationshipInformationRuleTest
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 02/03/2020     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_RelationshipInformationRuleTest {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/06/2020
    * @methodname   setup
    * @description  Data creation for test class
    * @param        none
    * @return       none
    ********************************************************************************************/
    @TestSetup 
    public static void setup(){
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
        
        List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(2, false);
        SSP_Member__c mem1 = memList.get(0);
        mem1.Contact__c = cont.Id;
        insert mem1;
        
        SSP_Member__c mem2 = memList.get(1);
        mem2.Contact__c = cont.Id;
        insert mem2;
        
        List<SSP_Application__c> appList = SSP_TestDataFactory.createSSPApplications(1, false);
        SSP_Application__c app = appList.get(0);
        app.Account__c = accApp.Id;
        insert app;
        Id appId = app.Id;
        
        List<SSP_ApplicationIndividual__c> appIndvList = SSP_TestDataFactory.createApplicationIndividuals(2, false);
        SSP_ApplicationIndividual__c appIndv1 = appIndvList.get(0);
		appIndv1.SSP_Member__c = mem1.Id;
        appIndv1.SSP_Application__c = appId;
        appIndv1.ProgramsApplied__c = 'MA;DS;KP;CC';
        insert appIndv1;
        
        SSP_ApplicationIndividual__c appIndv2 = appIndvList.get(1);
		appIndv2.SSP_Member__c = mem2.Id;
        appIndv2.SSP_Application__c = appId;
        appIndv2.ProgramsApplied__c = 'MA;DS;KP;CC';
        insert appIndv2;
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/03/2020
    * @methodname   isRequiredTest
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest(){
        SSP_Member__c mem = getMember();
        SSP_Application__c app = getApplication();
        List<SSP_ApplicationIndividual__c> appIndList = queryApplicationIndividual(app.Id);
        
        QueuingWrapper qwrap = new QueuingWrapper ();
        qwrap.applicationIndividualList = appIndList;
        
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = mem.Id;
        ctxData.ApplicationId = app.Id;
        ctxData.queueObject = qwrap;
        
        SSP_RelationshipInformationRule cls = new SSP_RelationshipInformationRule();
        Test.startTest();
        boolean result = cls.isRequired(ctx, ctxData);
        Test.stopTest();
        System.assertEquals(result, true);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/03/2020
    * @methodname   isRequiredTest1
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest1(){        
        SSP_RelationshipInformationRule cls = new SSP_RelationshipInformationRule();
        Test.startTest();
        boolean result2 = cls.isRequired(null, null);
        Test.stopTest();
        System.assertEquals(result2, false);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getMember
    * @description  retrieves Member
    * @param        void
    * @return       SSP_Member__c
    ********************************************************************************************/
    private static SSP_Member__c getMember(){
        return [Select Id FROM SSP_Member__c LIMIT 1];
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/05/2020
    * @methodname   getApplication
    * @description  retrieves Application
    * @param        void
    * @return       SSP_Application__c
    ********************************************************************************************/
    private static SSP_Application__c getApplication(){
        return [SELECT Id FROM SSP_Application__c LIMIT 1];
    }
    
    private static List<SSP_ApplicationIndividual__c> queryApplicationIndividual(String applicationId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId]);
    }
}