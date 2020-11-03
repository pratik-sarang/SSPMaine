/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   RE_ResourcePackagesCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/12/2019
*   Description  :   This class acts as a test class for RE_ResourcePackagesCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer             Date          Description
*   * ------------------------------------------------------------------------------------                 
* 
*****************************************************************************************************************************/
@isTest
private class RE_ResourcePackagesCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    /*
     * Method Name : setupTestData
     * Description : method to create test records for all test methods.
     * Returns : none
    */

    @testSetup static void setupTestData(){
        
        TestDataFactory.testDataSetup();
         List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 2];
         
        Contact citizenContact3 = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,'test12@test.com',contactCitizenRecordTypeId,false);
        citizenContact3.AccountId=lstCitizenAccounts[1].Id;
        citizenContact3.MailingPostalCode='53223';
        insert citizenContact3;

        List<RE_Archetype__c> lstArcheTypes = TestDataFactory.createArchetypeRecords(2,true,Schema.SObjectType.RE_Archetype__c.getRecordTypeInfosByDeveloperName().get('Archetype').getRecordTypeId());
        List<RE_Archetype__c> lstArchTypes = new List<RE_Archetype__c>();
        for(RE_Archetype__c rarch:lstArcheTypes){
            RE_Archetype__c objArch =new RE_Archetype__c();
            objArch.RecordtypeId = Schema.SObjectType.RE_Archetype__c.getRecordTypeInfosByDeveloperName().get('SubArchetype').getRecordTypeId();
            objArch.Title__c = 'Arch';
            objArch.Status__c='Active';
            objArch.language__c='en_US';
            objArch.ParentArchetype__c=rarch.Id;
            lstArchTypes.add(objArch);
        }
        insert lstArchTypes;
        TestDataFactory.createGoalRecords(1, true, lstArchTypes);
    }

    /*
     * Method Name : testResourcePackages
     * Description : Method to cover functionality of method - getResourcePackages.
     * Returns : none
    */
    @isTest static void testResourcePackages() {
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_ResourcePackagesCtrl.getResourcePackages();
        }
        System.assertEquals(responseResult.isSuccessful, true,'Success');
        Test.stopTest();
    }

    /*
     * Method Name : testCarouselPackages
     * Description : Method to cover functionality of method - getCarouselPackages.
     * Returns : none
    */
    @isTest static void testCarouselPackages() {
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){  
            responseResult = RE_ResourcePackagesCtrl.getCarouselPackages();
        }
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful, true,'Success');
    }
    
    /*
     * Method Name : testGuestAssessmentRecords
     * Description : Method to cover functionality of method - fetchGuestAssessmentRecords.
     * Returns : none
    */
    @isTest static void testGuestAssessmentRecords() {
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_ResourcePackagesCtrl.fetchGuestAssessmentRecords();
        }
        System.assertEquals(responseResult.isSuccessful, true,'Success');
        Test.stopTest();
    }
    
     /*
     * Method Name : testGuestAssessmentRecords
     * Description : Method to cover functionality of method - fetchGuestAssessmentRecords.
     * Returns : none
    */
    @isTest static void testGuestAssessmentRecordsException() {
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        
        Contact cnt = [SELECT Id, Email, AccountId from Contact Where Email = 'test12@test.com' limit 1];
        
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
         ApplicableRoles__c = 'Citizen_Individual',
         RE_Selected_Role__c = 'Citizen_Individual',
         //UserRoleId = r.Id,
         ContactId = cnt.Id
        );
        insert usr;
        
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(usr){
            responseResult = RE_ResourcePackagesCtrl.fetchGuestAssessmentRecords();
            RE_ResourcePackagesCtrl.getCarouselPackages();
            RE_ResourcePackagesCtrl.getResourcePackages();
        }
        //System.assertEquals(responseResult.isSuccessful, false,'Success');
        Test.stopTest();
    }
    
    
}