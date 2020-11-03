/**************************************************************************************************
* Class Name    : RE_OurClientsCtrlTest
* Owner         : Sai Kiran
* Created Date  : 06/05/2019
* Description   : Our Clients controller Test class for RE_OurClientsCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
@isTest
public class RE_OurClientsCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/25/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='33222';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName AND Name != null];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);               
    }
    
    @isTest
    public static  void getContactMetadataTest(){
        Test.startTest();
        RE_CreateLightningServerResponse ourClientsTest = RE_OurClientsCtrl.getContactMetadata();
        Test.stopTest();
        System.assert(ourClientsTest.isSuccessful == true,'Success');
    }
     @isTest
    public static  void checkClientConsentTest(){
        List<Contact> clientList=[Select Id from Contact where RecordtypeId=:contactCitizenRecordTypeId AND RecordtypeId != null];
        Test.startTest();
         RE_CreateLightningServerResponse ourClientsTest = RE_OurClientsCtrl.checkClientConsent(clientList[0].Id);
        System.assert(ourClientsTest.isSuccessful == true,'Success');
        Test.stopTest();
        
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         05/19/2020
    * @methodname   testgetDecryptedMethod
    * @description  This method is used to test getDecryptedString method by passing encrypted data.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testgetDecryptedMethod() 
    {
        TestDataFactory.testDataForAESKeys();
        String cipherText = 'LGHR8/KzRZO9GF/XMxd8kw==';
        Test.startTest();
            RE_CreateLightningServerResponse response = RE_OurClientsCtrl.getDecryptedString(cipherText);
        Test.stopTest();
        System.assert(response.isSuccessful == true,'Success');
    }
}