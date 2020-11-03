/**
* Class Name    : RE_DataAccessCheckerTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_DataAccessCheckerTest
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Pankaj       Initial Version
**/

@isTest
public class RE_DataAccessCheckerTest {
    /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to set up test data
    */
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id sContactId = [Select Id FROM Contact  Where Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
    }
    @isTest static void isAllowedToAccessTest(){
        System.assert(RE_DataAccessChecker.isAllowedToAccess(Contact.SObjectType) == true,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    @isTest static void isSafeFieldTest(){
        System.assert(RE_DataAccessChecker.isSafeField('Name', 'Contact') == true,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    @isTest  static void getFieldsAccessibilityTest(){
        Id locationRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.strLocationObjectName, RE_GlobalConstants.LOCATION);
        String sFieldsToQueryOnLocation = RE_DataBaseQueryFields.sFieldsToQueryOnLocation;
        String sWhereClauseOnLocation = RE_DataBaseQueryFields.sWhereClauseOnLocation;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocation);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, 
                                                                                                   sFieldsToQueryOnLocation, 
                                                                                                   mapLocationQueryParameters);
        System.assertEquals(mapLocationQueryResponse.get(true)!=null,true,'Success');
        Map<Boolean,String> mapLocationQueryResponse1 = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, mapLocationQueryParameters);
    }
    @isTest  static void insertObjectsTest(){
        List<Account> lstContact = new List<Account>();
        Account objAccount = new Account();
        objAccount.Name = RE_GlobalConstants.sAccountName;
        lstContact.add(objAccount);
        Database.SaveResult[] sr =RE_DataAccessChecker.insertObjects(Contact.sObjectType, lstContact);
        System.assert(sr[0].isSuccess()==true,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    @isTest  static void updateObjectsTest(){
        List<Account> lstContact = new List<Account>();
        Account objAccount = [Select Id FROM Account Where Name = 'Account1' LIMIT 1];
        objAccount.Name = RE_GlobalConstants.sAccountName;
        lstContact.add(objAccount);
        Database.SaveResult[] sr =RE_DataAccessChecker.updateObjects(Contact.sObjectType, lstContact);
        System.assert(sr[0].isSuccess()==true,RE_DataBaseQueryFields.SWITCH_SUCCESS);

    }
    @isTest  static void getChildFieldsAccessibilityTest(){
        String sFieldsApiNameForReferral = RE_DataBaseQueryFields.sFieldsApiNameForReferralTest;
        String sQuery;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
        Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strReferralObjectName,sFieldsApiNameForReferral,mapQueryParameters); 
        System.assert(mapResponse.get(true) != null,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    @isTest static void checkRelationshipFieldsTest(){
        List<String> lstRelatedFields = new List<String>();
        lstRelatedFields.add(RE_DataBaseQueryFields.sResourceRelationshipName);
        Map<Boolean,String> mapResponse = RE_DataAccessChecker.checkRelationshipFields(lstRelatedFields, Referral__c.sObjecttype);
        System.assert(mapResponse.get(true) != null,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    @isTest static void deleteObjectTest(){
        List<Sobject> lstContact = new List<Sobject>();
        Account objAccount = new Account();
        objAccount.Name = RE_GlobalConstants.sAccountName;
        insert objAccount;
       
        lstContact.add(objAccount);
        
        Database.DeleteResult[] dr =RE_DataAccessChecker.deleteObject(Account.sObjectType, objAccount);
        System.assert(dr[0].isSuccess()==true,RE_DataBaseQueryFields.SWITCH_SUCCESS);
    }
    
}