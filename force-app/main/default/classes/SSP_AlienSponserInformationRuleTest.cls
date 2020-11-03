/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_AlienSponserInformationRuleTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   02/18/2020
*   Description  :   Test class for SSP_AlienSponserInformationRule
*/


@isTest
public class SSP_AlienSponserInformationRuleTest {

/********************************************************************************************
    * @author       Prathamesh Thorave
    * @date         03/27/2020
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
        SSP_Member__c mem = memList.get(0);
        mem.Contact__c = cont.Id;
        mem.HasAlienSponsorToggle__c='Y';
        insert mem;
        
        List<SSP_Application__c> appList = SSP_TestDataFactory.createSSPApplications(1, false);
        SSP_Application__c app = appList.get(0);
        app.Account__c = accApp.Id;
        insert app;
        Id appId = app.Id;
        
        List<SSP_ApplicationIndividual__c> appIndvList = SSP_TestDataFactory.createApplicationIndividuals(2, false);
        SSP_ApplicationIndividual__c appIndv = appIndvList.get(0);
		appIndv.SSP_Member__c = mem.Id;
        appIndv.SSP_Application__c = appId;
        appIndv.ProgramsApplied__c = 'MA;KT;KP;CC';
        insert appIndv;
    }
    
        /********************************************************************************************
    * @author       Prathamesh Thorave
    * @date         03/27/2020
    * @methodname   isRequiredTest
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    
	 @isTest
    public static void isRequiredTest(){
        SSP_Member__c mem = getMember();
        SSP_Application__c app = getApplication();
        SSP_ApplicationIndividual__c appIndv = queryApplicationIndividual(app.Id, mem.Id);
        
        Map<String,SSP_ApplicationIndividual__c> memberAppIndMap = new Map<String,SSP_ApplicationIndividual__c>();
        memberAppIndMap.put(mem.Id, appIndv);
        
        QueuingWrapper qwrap = new QueuingWrapper ();
        qwrap.memberAppIndividualMap = memberAppIndMap;
        
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = mem.Id;
        ctxData.ApplicationId = app.Id;
        ctxData.queueObject = qwrap;
        
        SSP_AlienSponsorInformationRule cls = new SSP_AlienSponsorInformationRule();
        Test.startTest();
        boolean result = cls.isRequired(ctx, ctxData);
        Test.stopTest();
        System.assertEquals(result, true);
    }
    /********************************************************************************************
    * @author       Prathamesh Thorave
    * @date         03/27/2020
    * @methodname   isRequiredTest1
    * @description  Test method for isRequired
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void isRequiredTest1(){        
        SSP_AlienSponsorInformationRule cls = new SSP_AlienSponsorInformationRule();
        Test.startTest();
        boolean result2 = cls.isRequired(null, null);
        Test.stopTest();
        System.assertEquals(result2, false);
    }
    
    
    
    /********************************************************************************************
    * @author       Prathamesh Thorave
    * @date         03/27/2020
    * @methodname   getMember
    * @description  retrieves Member
    * @param        void
    * @return       SSP_Member__c
    ********************************************************************************************/
        private static SSP_Member__c getMember(){
        return [Select Id FROM SSP_Member__c limit 1 ];
    }
    
    
    
    /********************************************************************************************
    * @author       Prathamesh Thorave
    * @date         03/27/2020
    * @methodname   getApplication
    * @description  retrieves Application
    * @param        void
    * @return       SSP_Application__c
    ********************************************************************************************/
    private static SSP_Application__c getApplication(){
        return [SELECT Id FROM SSP_Application__c limit 1];
    }
        
    private static SSP_ApplicationIndividual__c queryApplicationIndividual(String applicationId, String memberId){
        return ([SELECT Id, ProgramsApplied__c, SSP_Member__c, SSP_Member__r.HasAlienSponsorToggle__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :applicationId AND SSP_Member__c = :memberId LIMIT 1]);
    }  
}