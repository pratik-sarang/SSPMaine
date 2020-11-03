/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_ContactInformationControllerTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   11/26/2019
*   Description  :   Test class for SSP_ContactInformationController
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 11/26/2019     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_ContactInformationControllerTest {
	
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   saveSspMemberContactInformationTest
    * @description  Test method for saveSspMemberContactInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveSspMemberContactInformationTest(){
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
        mem.PreferredNotificationMethodCode__c = 'EE';
        mem.PrimaryPhoneTypeCode__c = 'LND';
        Id memId = mem.Id;
        
        String memString = JSON.serialize(mem);
        SSP_ContactInformationController.saveSspMemberContactInformation(memId, memString);
        SSP_Member__c retrievedMem;
        if(memId != Null){
            retrievedMem = getMember(memId);
            SSP_Member__c queriedMem = [SELECT Id, FirstName__c, PreferredNotificationMethodCode__c, Email__c FROM SSP_Member__c WHERE Id =: memId];
        }
        System.assertEquals(retrievedMem.PreferredNotificationMethodCode__c , mem.PreferredNotificationMethodCode__c);
        
        mem.Email__c = 'test456user11@deloitte.com';
        memString = JSON.serialize(mem);
        SSP_ContactInformationController.saveSspMemberContactInformation(cont.Id, memString);
        if(memId != Null){
            retrievedMem = getMember(memId);
        }
        System.assertEquals(retrievedMem.Email__c , null);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   fetchBasicSspMemberInformationTest
    * @description  Test method for fetchBasicSspMemberInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void fetchBasicSspMemberInformationTest(){
        User u1 = SSP_TestDataFactory.createPortalUser();
        
        System.runAs(u1){
            List<SSP_Member__c> memList = SSP_TestDataFactory.createSSPMembers(1, false);
            SSP_Member__c mem = memList.get(0);
            mem.Contact__c = u1.ContactId;
            mem.Email__c = 'test478user11@deloitte.com';
            mem.PreferredSpokenLanguageCode__c = '1';
            insert mem;
            Id memId = mem.Id;
            
            SSP_LightningResponse lr = SSP_ContactInformationController.fetchBasicSspMemberInformation(memId);
            SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('record'); 
            
            System.assertEquals(retrievedMem.Email__c, mem.Email__c);
            
            mem.PreferredSpokenLanguageCode__c = null;
            mem.PreferredWrittenLanguageCode__c = null;
            update mem;
            memId = mem.Id;
            
            SSP_LightningResponse lr1 = SSP_ContactInformationController.fetchBasicSspMemberInformation(memId);
            SSP_Member__c retrievedMem1 = (SSP_Member__c)lr1.mapResponse.get('record'); 
            
            System.assertEquals(retrievedMem1.PreferredSpokenLanguageCode__c, 'English');  
        }
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   fetchHohContactInformationTest
    * @description  Test method for fetchHohContactInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void fetchHohContactInformationTest(){
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
        mem.Email__c = 'test495user11@deloitte.com';
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
        appIndv.IsHeadOfHousehold__c = true;
        insert appIndv;
        
        SSP_LightningResponse lr = SSP_ContactInformationController.fetchHohContactInformation(appId);
        SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('record'); 
        
        System.assertEquals(retrievedMem.Email__c, mem.Email__c);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         11/26/2019
    * @methodname   fetchBasicNonPrimaryMemberInformationTest
    * @description  Test method for fetchBasicNonPrimaryMemberInformation
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void fetchBasicNonPrimaryMemberInformationTest(){
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
        mem.Email__c = 'test456user56@deloitte.com';
        insert mem;
        Id memId = mem.Id;
        
        SSP_LightningResponse lr = SSP_ContactInformationController.fetchBasicNonPrimaryMemberInformation(memId);
        SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('record'); 
        
        System.assertEquals(retrievedMem.Email__c, mem.Email__c);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         12/03/2019
    * @methodname   fetchHohName
    * @description  Test method for fetchHohName
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void fetchHohNameTest(){
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
        mem.FirstName__c = 'Test';
        mem.LastName__c = 'User';
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
        appIndv.IsHeadOfHousehold__c = true;
        insert appIndv;
        
        SSP_LightningResponse lr = SSP_ContactInformationController.fetchHohName(appId);
        SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('record'); 
        
        System.assertEquals(retrievedMem.FirstName__c, mem.FirstName__c);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         02/19/2020
    * @methodname   getMember
    * @description  retrieves Relationship
    * @param        Id
    * @return       SSP_Member__c
    ********************************************************************************************/
    private static SSP_Member__c getMember (Id memberId){
        return [SELECT Id, FirstName__c, PreferredNotificationMethodCode__c, Email__c FROM SSP_Member__c WHERE Id =: memberId];
    }
}