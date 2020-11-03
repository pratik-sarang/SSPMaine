/**
* Class Name    : RE_UserCreationHelperTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_UserCreationHelper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        	Developer       Description                                                         
*  ----------  	-----------     -------------------------------------------------------------------
*  24/05/2019  	Akash       	Initial Version
*  08/25/2020	Venkat Korra	Added methods for uncovered ctrl methods
**/

@isTest
public class RE_UserCreationHelperTest{
    /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to set up test data
    */
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
       /* Profile objProfile = [SELECT Id from Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id sContactId = [Select Id FROM Contact  Where Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST  LIMIT 1].Id;
        User ObjREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',  RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
		*/
        Id sREAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
        List<Account> accountList = TestDataFactory.createAccounts(1,false,sREAccRecTypeId);
        accountList[0].OrganizationUniqueId__c = '82324253';
        if(Schema.sObjectType.Account.fields.OrganizationUniqueId__c.isCreateable()){
        	insert accountList;
        }
}        
   
   /* @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to assignPermissionSet method
    */
   /* static testMethod void assignPermissionSetTest(){
        User objUser = [SELECT Id,ContactId FROM USER WHERE Email = 'cpadminuser@deloitte.com' LIMIT 1];
        system.runAs(objUser){
            RE_UserCreationHelper.removePermissionSet(new Set<Id>{objUser.Id});
        }
    }*/
    /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to createContactUser method
    */
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void createContactUserTest(){
        Account acc;
        if(Schema.sObjectType.Account.fields.Id.isAccessible()){
        	acc = [SELECT Id FROM Account LIMIT 1];
        }
        List<String> lstContact = new List<String>();
        String sContactData = 'Darren;Lehmann;darrengcredev@mailinator.com;(898) 956-5677;'+acc.Id;
        lstContact.add(sContactData);
		RE_UserCreationHelper.createContactUser(lstContact);
        Contact objContactInserted;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.FirstName.isAccessible()
          && Schema.sObjectType.Contact.fields.Email.isAccessible()){
        	objContactInserted = [SELECT Id,FirstName FROM Contact WHERE Email='darrengcredev@mailinator.com' LIMIT 1];
        }
        System.assert(objContactInserted.FirstName == 'Darren','Success');
    }
    @isTest static void testAssignPermissionSet(){
        Test.startTest();
        	User objUser = [SELECT Id, ContactId FROM USER WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            system.runAs(objUser){
            	RE_UserCreationHelper.assignPermissionSetOnCreate(new Set<Id>{objUser.Id});
            }
        List<PermissionSetAssignment> pSAList = [SELECT AssigneeId,Id,PermissionSetGroupId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :objUser.Id];
        Test.stopTest();
        System.assertNotEquals(pSAList, null, 'Success');
    }
    @isTest static void testRemovePermissionSet(){
        Test.startTest();
        	User objUser = [SELECT Id, ContactId FROM USER WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            system.runAs(objUser){
            	RE_UserCreationHelper.removePermissionSet(new Set<Id>{objUser.Id});
            }
        List<PermissionSetAssignment> pSAList = [SELECT AssigneeId,Id,PermissionSetGroupId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :objUser.Id];
        Test.stopTest();
    }
    @isTest static void testUpdateUserStatusToActive(){
        Test.startTest();
        	Contact con = [SELECT Id, Email FROM Contact WHERE Email =:RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1];
        	User objUser = [SELECT Id, ContactId FROM USER WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            RE_CreateLightningServerResponse result;
        	system.runAs(objUser){
            	result = RE_UserCreationHelper.updateUserStatusToActive(con.Id);
            }
        Test.stopTest();
        System.assertEquals(result.isSuccessful, true, 'Success');
    }
    @isTest static void testUpdateUser(){
        Test.startTest();
        	Contact con = [SELECT Id, Email, PermissionsLevel__c FROM Contact WHERE Email =:RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1];
        	User objUser = [SELECT Id, ContactId FROM USER WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            Boolean result;
        	Map<User, String> mapUserRole = new Map<User, String>();
        	mapUserRole.put(objUser, con.PermissionsLevel__c);
        	system.runAs(objUser){
            	result = RE_UserCreationHelper.updateUser(mapUserRole);
            }
        Test.stopTest();
        System.assertEquals(result, true, 'Success');
    }
}