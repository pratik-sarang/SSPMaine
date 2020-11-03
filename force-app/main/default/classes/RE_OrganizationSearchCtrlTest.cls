/**
 * Class Name    : RE_OrganizationSearchCtrlTest{
 * Owner         : DELOITTE
 * Created Date  : 05/27/2019
 * Description   : Organization search test class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
*  Date        		Developer       Description                                                         
*  ----------  		-----------     -------------------------------------------------------------------
*  05/27/2019  		Arun       		Initial Version
*  08/26/2020  		Venkat Korra    RE Security Changes (Increase code coverage)
**/
@IsTest
public class RE_OrganizationSearchCtrlTest {
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        Id sREAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
        List<Account> listAccounts = TestDataFactory.createAccounts(5,true,sREAccRecTypeId);
        for(Account acc:listAccounts){
            // acc.OrganizationUniqueId__c=RE_GlobalConstants.strOrgUniqueId;
            acc.BillingCity=RE_GlobalConstants.strAccShipCity;
        }
        listAccounts[0].Name='Test';
        listAccounts[0].OrganizationUniqueId__c='2400';
        listAccounts[0].IsClaimed__c=true;
        listAccounts[0].Is_CP_Organization__c=true;
        listAccounts[0].Status__c=RE_GlobalConstants.sAccountStatus;
        listAccounts[1].OrganizationUniqueId__c='4200';
        listAccounts[2].OrganizationUniqueId__c='4002';
        listAccounts[3].OrganizationUniqueId__c='4020';
        listAccounts[4].OrganizationUniqueId__c='2040';
        
        if(!listAccounts.isEmpty() && RE_DataAccessChecker.isAllowedToUpdate(Account.getSObjectType())){
            update listAccounts;
        }
        
        RecordType claimRecordType=GeneralUtility.fetchRecordType(RE_GlobalConstants.strClaimRecordTypeDeveloperName, RE_GlobalConstants.strClaimObjectName);
        List<ClaimMySiteRequest__c> lstClaimRequest = TestDataFactory.createClaimRequest(2,false,claimRecordType.Id);
        lstClaimRequest[1].Status__c = RE_GlobalConstants.STATUS_NEW;
        /*ClaimMySiteRequest__c claimReq=new ClaimMySiteRequest__c();
        claimReq.FirstName__c=RE_GlobalConstants.strClaimReqFirstName;
        claimReq.UniqueIdentificationNo__c=RE_GlobalConstants.strClaimUinNo;
        claimReq.Status__c = RE_GlobalConstants.CLAIM_STATUS_APPROVED;
        claimReq.RecordTypeId=claimRecordType.Id;
        claimReq.Email__c = RE_GlobalConstants.strClaimEmail;*/
        if(lstClaimRequest!=null && RE_DataAccessChecker.isAllowedToCreate(ClaimMySiteRequest__c.getSObjectType())){
            insert lstClaimRequest;
        }
    }
    @isTest static void testOrgnizationSearchData(){
        Test.startTest();
            Account acc = [SELECT Id, Name, Is_CP_Organization__c, IsClaimed__c FROM Account WHERE Name = 'Test' LIMIT 1];
            RE_CreateLightningServerResponse response=RE_OrganizationSearchCtrl.fetchOrganizations('Test','TestCity');
        Test.stopTest();
        System.assertNotEquals(null, response,'Success');
    }
    @isTest static void testOrgnizationSearchDataWithoutCity(){
        Test.startTest();
            RE_CreateLightningServerResponse response2=RE_OrganizationSearchCtrl.fetchOrganizations('Test',null);
        Test.stopTest();
        System.assertNotEquals(null, response2,'Success');
    }
    @isTest static void testOrgnizationSearchDataWithoutOrg(){
        Test.startTest();
        	RE_CreateLightningServerResponse response3=RE_OrganizationSearchCtrl.fetchOrganizations(null,'TestCity');
        Test.stopTest();
        System.assertNotEquals(null, response3,'Success');
    }
    @isTest static void testGetUnclaimedOrgDetail(){
        Test.startTest();
            List<Account> listAccounts=[SELECT Id,OrganizationUniqueId__c FROM Account WHERE RecordTypeId=:Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId()];
            RE_CreateLightningServerResponse response=RE_OrganizationSearchCtrl.getUnclaimedOrgDetail(listAccounts[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, response,'Success');
    }
    @isTest static void testGetUnclaimedOrgDetailCatchBlock(){
        Test.startTest();
            RE_CreateLightningServerResponse response=RE_OrganizationSearchCtrl.getUnclaimedOrgDetail('');
        Test.stopTest();
        System.assertNotEquals(null, response,'Success');
    }
}