/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   SSP_PreferredMCOSelectionControllerTest
*   Created By   :   Sanchita Tibrewala
*   Created Date :   08/17/2020
*   Description  :   Test class for SSP_PreferredMCOSelectionController
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 08/17/2020     Initial Version
*****************************************************************************************************************************/
@isTest
public class SSP_PreferredMCOSelectionControllerTest {
	
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
        mem.RaceCode__c = 'IN';
        mem.PreferredMCOName__c = 'HUMANA';
        mem.MailingAddressLine1__c = 'ydkf';
        mem.MailingAddressLine2__c = 'dlkj';
        mem.MailingCity__c = 'frankfort';
        mem.MailingCountyCode__c = '001';
        mem.MailingStateCode__c = 'KY';
        mem.MailingZipCode4__c = '3745';
        mem.MailingZipCode5__c = '57464';
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
        appIndv.ProgramsApplied__c = 'MA';
		appIndv.MemberProgramsApplied__c = 'MA';
        appIndv.MemberStatus__c = 'New';
        insert appIndv;
    }

	/********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/17/2020
    * @methodname   getMCODetailsTest
    * @description  Test method for getMCODetails
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void getMCODetailsTest(){
        Test.setMock(WebServiceMock.class, new SSP_PreferredMCOSelectionMockClass());
        SSP_Member__c member = queryMember('IN');
        SSP_PreferredMCOSelectionController.getMCODetails(member.Id);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId','919222242');
        Test.startTest();
        SSP_LightningResponse lr = SSP_PreferredMCOSelectionController.getMCODetails(member.Id);
        Test.stopTest();
        SSP_Member__c retrievedMem = (SSP_Member__c)lr.mapResponse.get('memberObject');
        System.assertEquals(retrievedMem.PreferredMCOName__c , member.PreferredMCOName__c);
    }
    
    /********************************************************************************************
    * @author       Sanchita Tibrewala
    * @date         08/17/2020
    * @methodname   saveMCODetailsTest
    * @description  Test method for saveMCODetails
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest
    public static void saveMCODetailsTest(){
        SSP_Member__c member = queryMember('IN');
        String memString = JSON.serialize(member);
        SSP_PreferredMCOSelectionController.saveMCODetails(member.Id, memString);
        SSP_Member__c retrievedMem;
        Test.startTest();
        SSP_PreferredMCOSelectionController.saveMCODetails(memString, memString);
        Test.stopTest();
        if(member.Id != Null){
            retrievedMem = [SELECT Id, FirstName__c, PreferredMCOName__c, PreferredMCOId__c FROM SSP_Member__c WHERE Id =: member.Id];
        }
        System.assertEquals(retrievedMem.PreferredMCOName__c , member.PreferredMCOName__c);
    }
    
    private static SSP_Member__c queryMember(String raceCode){
        return [SELECT Id, RaceCode__c, PreferredMCOName__c, PreferredMCOId__c, MailingAddressLine1__c, MailingAddressLine2__c, MailingCity__c, MailingCountyCode__c, MailingStateCode__c, MailingZipCode4__c, MailingZipCode5__c FROM SSP_Member__c WHERE RaceCode__c=: raceCode LIMIT 1];
    }
}