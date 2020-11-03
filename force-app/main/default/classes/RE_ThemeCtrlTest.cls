/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_ThemeCtrlTest
*   Created By   :  Deloitte
*   Created Date :  07/25/2019 
*   Description :   This class acts as a test class for RE_ThemeCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    07/25/2019        Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_ThemeCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
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
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        lstCitizenAccounts[0].IsClaimed__c = false;
        update lstCitizenAccounts;
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='33222';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(2, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(2,false,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        lstRreferral[0].Status__c = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
        insert lstRreferral;

    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/25/2019
    * @methodname   testFetchLoginInUserCitizen
    * @description  This method is used to test the functionality of method - fetchLoginInUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testFetchLoginInUserCitizen() {   
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_CITIZEN_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result =  RE_ThemeCtrl.fetchLoginInUser();
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/25/2019
    * @methodname   testFetchLoginInUserCommunity
    * @description  This method is used to test the functionality of method - fetchLoginInUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testFetchLoginInUserCommunity() {   
        User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(cpAdminUser){
			result =  RE_ThemeCtrl.fetchLoginInUser();
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/25/2019
    * @methodname   testFetchLoginInUserGuest
    * @description  This method is used to test the functionality of method - fetchLoginInUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testFetchLoginInUserGuest() {   
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(guestUser){
            result =  RE_ThemeCtrl.fetchLoginInUser();
            System.assert(result.isSuccessful == true,'Success'); //Commented for Test Class failures due to my cart changes
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/25/2019
    * @methodname   testFetchLoginInUserGuest
    * @description  This method is used to test the functionality of method - fetchLoginInUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
     @isTest static void fetchKogURLTest() {
        // Insert KOG custom setting
        KOGWebservice__c objKOG = new KOGWebservice__c();
        objKOG.Name = 'KOG Citizen';
        objKOG.ApplicationName__c = 'DEV3 KHBE Self Service Portal';
        objKOG.Role__c = 'Citizen';
        objKOG.Certificate__c = 'backyardnonprodmulecert';
        objKOG.EndURL__c = 'http://abc.com';
        objKOG.KOG_Login_URL__c = 'http://abc.com';
        objKOG.KOG_Registration_URL__c = 'http://abc.com';
        objKOG.KOG_URL__c = 'http://abc.com';
        insert objKOG;
        Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result =  RE_ThemeCtrl.fetchKogURL(); 
            System.assert(result.isSuccessful ==false,'Success');
        }
        Test.stopTest();
     }
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         12/10/2019
    * @methodname   fetchKogURLTest1
    * @description  This method is used to test the functionality of method - fetchKogURL.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void fetchKogURLTest1() {
        Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result =  RE_ThemeCtrl.fetchKogURL(); 
            System.assert(result.isSuccessful == false,'Success');
        }
        Test.stopTest();   
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         12/17/2019
    * @methodname   testGetGuestHelpVideos
    * @description  This method is used to test the functionality of method - getGuestHelpVideos.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testGetGuestHelpVideos() {   
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        scormanywhere__Course__c media = new scormanywhere__Course__c();
        media.Name = 'Add a User';
        media.Audience__c = 'Guest';
        media.scormanywhere__Status__c = 'Active';
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(guestUser){
            insert media;
            try{
            result =  RE_ThemeCtrl.getGuestHelpVideos(media.Audience__c);
            RE_ThemeCtrl.kogLogout();
            System.assert(result.isSuccessful == true,'Success');
            }catch(Exception ex){
        }
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         08/26/2020
    * @methodname   roleChange
    * @description  This method is used to test the functionality of method - roleChange.
    * @param        none
    * @return       none 
    ********************************************************************************************/
    @isTest static void testRoleChange() {
        Test.startTest();
        	String sRole = RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
            User u = [SELECT Id, RE_Selected_Role__c FROM User WHERE Email = :RE_GlobalConstants.COMMUNITY_CITIZEN_EMAIL_TEST LIMIT 1];
            System.debug('u-->'+u);	
            RE_ThemeCtrl.roleChange(sRole);
        Test.stopTest();
        System.assertNotEquals(u.RE_Selected_Role__c, null, 'Success');
    }
}