/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_GlobalThemeCtrlTest
*   Created By   :  Deloitte
*   Created Date :  07/25/2019 
*   Description :   This class acts as a test class for RE_GlobalThemeCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    07/25/2019        Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_GlobalThemeCtrlTest {
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
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='44322';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName AND Name != null];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
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
        User citizenUser = [SELECT Id,ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_CITIZEN_EMAIL_TEST AND Email != null LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result =  RE_GlobalThemeCtrl.fetchLoginInUser();
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
        User cpAdminUser = [SELECT Id, Name, Email, RE_Selected_Role__c FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(cpAdminUser){
            result =  RE_GlobalThemeCtrl.fetchLoginInUser();
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
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' AND Name != null LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',true);
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(guestUser){
            result =  RE_GlobalThemeCtrl.fetchLoginInUser();
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         11/08/2019
    * @methodname   testFetchCPUserTrainingStatus
    * @description  This method is used to test the functionality of method - fetchCPUserTrainingStatus.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testFetchCPUserTrainingStatus() {   
        //Profile cPUserProfile = [SELECT Id FROM Profile WHERE Name='RE Community Partner User Profile' LIMIT 1];
        //User cPUser = TestDataFactory.createUser('cpUser',cPUserProfile.Id,'testCP@test.com1','test@cp.com',false);
        User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(cpAdminUser){
            result =  RE_GlobalThemeCtrl.fetchCPUserTrainingStatus();
            System.assert(result.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         03/11/2020
    * @methodname   testKogLogOut
    * @description  This method is used to test the functionality of method - kogLogout.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testKogLogOut() {   
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        try{
            System.runAs(guestUser){
                RE_GlobalThemeCtrl.kogLogout();
                
            }
            KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG CP Admin');
            Delete objKog;
            RE_GlobalThemeCtrl.kogLogout();
        }catch(Exception e){
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
            RE_GlobalThemeCtrl.roleChange(sRole);
            String sRole1 = 'Citizen';
            RE_GlobalThemeCtrl.roleChange(sRole1);
            String sRole2 = 'kynector';
            RE_GlobalThemeCtrl.roleChange(sRole2);
        Test.stopTest();
        System.assertNotEquals(u.RE_Selected_Role__c, null, 'Success');
    }
    /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         03/11/2020
    * @methodname   testKogLogOut
    * @description  This method is used to test the functionality of method - kogLogout.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testfetchCPUserTraining() {   
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        try{
            System.runAs(guestUser){
                
                result =  RE_GlobalThemeCtrl.fetchCPUserTrainingStatus();
                
            }
        }catch(Exception e){
        }
        Test.stopTest();
    }
}