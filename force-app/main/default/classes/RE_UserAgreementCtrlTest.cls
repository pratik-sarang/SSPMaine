/***************************************************************************************************************************
*   Type             :   Test Class
*   Name             :   RE_UserAgreementCtrlTest
*   Created By       :   CHFS
*   Created Date     :   11/19/2019
*   Description      :   This class acts as a test class for RE_UserAgreementCtrl
*   Modification Log :
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------
*   * Siri Putta                11/08/2019      
*****************************************************************************************************************************/
@isTest
public class RE_UserAgreementCtrlTest {
	static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
     @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='44322';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
    }
       @isTest static void testFetchLoginInUserCommunity() {   
        User cpAdminUser = [SELECT Id,UserAgreementConsentDate__c,LanguageLocaleKey, profile.name FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(cpAdminUser){
			result =  RE_GlobalThemeCtrl.fetchLoginInUser();
            result =  RE_UserAgreementCtrl.fetchLoginInUser();
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
}