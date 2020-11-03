/**
* Class Name    : RE_PrivacySettingCtrlTest
* Owner         : DELOITTE
* Created Date  : 01/07/2019
* Description   : Test Class for RE_PrivacySettingCtrl
*
*                            M O D I F I C A T I O N   L O G
*
*  Date        Developer       Description
*  ----------  -----------     -------------------------------------------------------------------
*  01/07/2019  Deeksha       Initial Version
**/
@isTest
public class RE_PrivacySettingCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
     /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/1/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 2];
        lstCitizenAccounts[0].HasOptedOutOfAccount__c = false;
        lstCitizenAccounts[1].HasOptedOutOfAccount__c = false;
        update lstCitizenAccounts;
        Contact citizenContact1 = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact1.AccountId=lstCitizenAccounts[0].Id;
        citizenContact1.MailingPostalCode='35353';
        Contact citizenContact2 = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,'citizen2@test.com',contactCitizenRecordTypeId,false);
        citizenContact2.AccountId=lstCitizenAccounts[1].Id;
        citizenContact2.MailingPostalCode='53223';
        Contact citizenContact3 = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,'test12@test.com',contactCitizenRecordTypeId,false);
        citizenContact3.AccountId=lstCitizenAccounts[1].Id;
        citizenContact3.MailingPostalCode='53223';
        insert citizenContact3;
        List<Contact> lstCitizenContact = new List<Contact>();
        lstCitizenContact.add(citizenContact1);
        lstCitizenContact.add(citizenContact2);
        insert lstCitizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName AND Name != null];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact1.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<Consent__c> lstConsent = TestDataFactory.createConsent(2,false,lstCitizenContact,lstCitizenAccounts);
        lstConsent[0].Status__c = 'Pending';
        lstConsent[0].ConsentLevel__c = RE_GlobalConstants.ORGANIZATION;
        lstConsent[0].StartDate__c = System.Today().AddDays(-4);
        lstConsent[1].Status__c = 'Pending';
        lstConsent[1].ConsentLevel__c = RE_GlobalConstants.ASSISTER;
        lstConsent[1].StartDate__c = System.Today().AddDays(-4);
        insert lstConsent;
        lstConsent[0].Status__c = 'Active';
        lstConsent[1].Status__c = 'Active';
        update lstConsent;
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         7/1/2019
    * @methodname   testFetchConsentDetail
    * @description  This method is used to test the functionality of method - fetchConsentDetail
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testFetchConsentDetail(){
        User citizenUser = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        List<Consent__c> lstConsent = [SELECT Id,Name,Client__r.OptOutInfoSharing__c,ConsentLevel__c,Status__c,Organization__r.Name,Assister__r.Name FROM Consent__c WHERE Status__c = 'Active' AND ConsentLevel__c =:RE_GlobalConstants.ORGANIZATION LIMIT 2];
        System.runAs(citizenUser){
            result = RE_PrivacySettingCtrl.fetchConsentDetails(); 
            System.assert(result.isSuccessful == true,'Success');



        }
        Test.stopTest();
    }
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         7/1/2019
    * @methodname   testUpdateConsentStatusActive
    * @description  This method is used to test the functionality of method - updateConsentStatus
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testUpdateConsentStatusActive(){
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
        List<Consent__c> lstConsent = [SELECT Id,Name,Status__c,ConsentLevel__c,Organization__r.Name,Assister__r.Name FROM Consent__c LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            result = RE_PrivacySettingCtrl.updateConsentStatus(lstConsent[0],RE_GlobalConstants.ACTIVE); 
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         7/1/2019
    * @methodname   testUpdateConsentStatusInactive
    * @description  This method is used to test the functionality of method - updateConsentStatus
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testUpdateConsentStatusInactive(){
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
       List<Consent__c> lstConsent = [SELECT Id,Name,Status__c,ConsentLevel__c,Organization__r.Name,Assister__r.Name FROM Consent__c LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            result = RE_PrivacySettingCtrl.updateConsentStatus(lstConsent[0],RE_GlobalConstants.INACTIVE); 
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    
    @isTest public static  void testUpdateConsentStatusDeny(){
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
        List<Consent__c> lstConsent = [SELECT Id,Name,Status__c,ConsentLevel__c,Organization__r.Name,Assister__r.Name FROM Consent__c LIMIT 1];
        Test.startTest();
        
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            result = RE_PrivacySettingCtrl.updateConsentStatus(lstConsent[0],RE_GlobalConstants.DENY); 
           
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         7/1/2019
    * @methodname   testUpdateAccountOpt
    * @description  This method is used to test the functionality of method - updateAccountOpt
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testUpdateAccountOpt(){
        User citizenUser = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            result = RE_PrivacySettingCtrl.updateAccountOpt(true,citizenUser.Contact.AccountId);
            RE_PrivacySettingCtrl.updateAccountOpt(false,citizenUser.Contact.AccountId);
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    
    @isTest public static  void testUpdateAccountOptStatusCheck(){
        User citizenUser = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null  LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            List<Consent__c> lstConsent = [SELECT Id,Name,Status__c,ConsentLevel__c,Organization__r.Name,Assister__r.Name FROM Consent__c LIMIT 1];
            lstConsent[0].Status__c = 'PENDING';
            lstConsent[0].ConsentLevel__c = RE_GlobalConstants.ORGANIZATION;
            update lstConsent[0];
            result = RE_PrivacySettingCtrl.updateConsentStatus(lstConsent[0],RE_GlobalConstants.PENDING);
            result = RE_PrivacySettingCtrl.updateAccountOpt(true,citizenUser.Contact.AccountId);
            RE_PrivacySettingCtrl.updateAccountOpt(false,citizenUser.Contact.AccountId);
            RE_PrivacySettingCtrl.fetchConsentDetails(); 
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    
    @isTest public static  void testUpdateAccountOptStatusCheckError(){
        User citizenUser = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail AND Email != null  LIMIT 1];
        
        //User citizenUser1 = [SELECT Id, ContactId,Contact.AccountId FROM User WHERE Id !=:citizenUser.Id  LIMIT 1];
        
        Contact cnt = [SELECT Id, Email, AccountId from Contact Where Email = 'test12@test.com' limit 1];
        //citizenUser1.ContactId = null;
        //update citizenUser1;
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User usr = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = :RE_GlobalConstants.strNonCitizenProfileName].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         //UserRoleId = r.Id,
         ContactId = cnt.Id
        );
        insert usr;
        User QryUsr = [Select Id, ContactId, Contact.AccountId from User Where Id=:usr.Id];
        Test.startTest();
        RE_CreateLightningServerResponse result;
        System.runAs(usr){
            Consent__c lstConsent = new Consent__c();
            
            result = RE_PrivacySettingCtrl.updateConsentStatus(lstConsent,RE_GlobalConstants.PENDING);
            result = RE_PrivacySettingCtrl.updateAccountOpt(true,QryUsr.Contact.AccountId);
            RE_PrivacySettingCtrl.updateAccountOpt(false,QryUsr.Contact.AccountId);
            RE_PrivacySettingCtrl.fetchConsentDetails(); 
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }

}