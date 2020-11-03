/**************************************************************************************************
* Class Name    : RE_RDResidentViewCtrlTest
* Owner         : Sai Kiran Velpula
* Created Date  : 07/02/2019
* Description   : Resource controller Test class for RE_RDResidentViewCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/

@isTest
public class RE_RDResidentViewCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    /*
    *Method Name: setupTestData
    *Description: method to create test records for all test methods.
    *Returns: none
    *
    */
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        locationRsrcList = TestDataFactory.createLocationResource(1,true,null,new List<Location__c>{locationList[0]},new List<Resource__c>{resourceList[1]});
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 38.328732;
        citizenContact.ContactGeoLocation__Longitude__s = 85.764771; 
        citizenContact.MailingStreet = 'Deloitte Towers';
        citizenContact.MailingState = 'Telangana';
        citizenContact.MailingCity = 'Hyd';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<Referral__c> refList= TestDataFactory.createReferral(1,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenUser.ContactId,lstCitizenAccounts,resourceList);
        
    }
    
    /*
    *Method Name: getResourceDataTest
    *Description: Method to cover functionality of method - getResourceData.
    *Returns: none
    *
    */
    @isTest static void getResourceDataTest(){
        List<Resource__c> resourceLst = [SELECT Id,Organization__c FROM Resource__c LIMIT 1];
        String resourceRecId = resourceLst[0].Id;
        List<Account> accList=[Select Id from Account where Id=:resourceLst[0].Organization__c];
        List<Contact> conList = [SELECT Id,AccountId, Name, ContactGeoLocation__c, mailingpostalcode, mailingstreet, mailingstate, mailingcity, mailingcountry FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];

        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
        String locationIdNull = null;
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName AND ContactId=:conList[0].Id LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_RDResidentViewCtrl.getResourceData(resourceRecId, locationRecId, '11570');
            RE_RDResidentViewCtrl.getResourceData(resourceRecId, locationIdNull, '11570');
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(responseResult.isSuccessful,true,'Success');
        }
        Test.stopTest();
        
    }
    
    /*
    *Method Name: getResourceDataTestExcptn
    *Description: Method to cover functionality of method - getResourceData.
    *Returns: none
    *
    */
    @isTest static void getResourceDataTestExcptn(){
        List<Resource__c> resourceLst = [SELECT Id,Organization__c FROM Resource__c LIMIT 1];
        String resourceRecId = resourceLst[0].Id;
        List<Account> accList=[Select Id from Account where Id=:resourceLst[0].Organization__c];
        List<Contact> conList = [SELECT Id,AccountId, Name, ContactGeoLocation__c, mailingpostalcode, mailingstreet, mailingstate, mailingcity, mailingcountry FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        
        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName AND ContactId=:conList[0].Id LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_RDResidentViewCtrl.getResourceData(resourceRecId, '', '11570');  
            System.assertEquals(responseResult.isSuccessful,false,'Success');
            RE_RDResidentViewCtrl.getResourceData(resourceRecId, locationRecId, ' ');
        }
        Test.stopTest();
        
    }
    
     /*
    *Method Name: getLoggedInUserRoleTest
    *Description: Method to cover functionality of method - getLoggedInUserRole.
    *Returns: none
    *
    */
    @isTest static void getLoggedInUserRoleTest(){
        User cpUser = [SELECT Id, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(cpUser){
            responseResult = RE_RDResidentViewCtrl.getLoggedInUserRole();
        }
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,true,'Success');
    }
    
    
     /*
    *Method Name: insertReferralForResidentTest
    *Description: Method to cover functionality of method - insertReferralForResident.
    *Returns: none
    *
    */
    @isTest static void insertReferralForResidentTest(){
        Account CitizenAccount = [SELECT Id,HasOptedOutOfAccount__c FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Resource__c> resourceLst = [SELECT Id,Organization__c,Organization__r.HasOptedOutOfAccount__c,Organization__r.Status__c,Organization__r.IsClaimed__c FROM Resource__c LIMIT 1];
        Resource__c resourceRec = resourceLst[0];
        
        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
        String locationRecIdNull = null;
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName AND isActive=true LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_RDResidentViewCtrl.insertReferralForResident(resourceRec, locationRecId, false);
            RE_RDResidentViewCtrl.insertReferralForResident(resourceRec, locationRecId, true);
            RE_RDResidentViewCtrl.insertReferralForResident(resourceRec, locationRecIdNull, true);
            RE_RDResidentViewCtrl.getLoggedInUserRole();
            System.assertEquals(responseResult.isSuccessful,true,'Success');
        }
        Test.stopTest();
        
    }
    
   
     /*
    *Method Name: getAllLocationsTest
    *Description: Method to cover functionality of method - getAllLocations.
    *Returns: none
    *
    */
    @isTest static void getAllLocationsTest(){
        
        List<Resource__c> resourceLst = [SELECT Id FROM Resource__c LIMIT 1];
        String resourceRecId = resourceLst[0].Id;
        User cpUser = [SELECT Id, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(cpUser){
            responseResult = RE_RDResidentViewCtrl.getAllLocations(resourceRecId);
        }
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful,true,'Success');
        
    }
    
    /*
    *Method Name: getOptOutInfoSharingDetailsTest
    *Description: Method to cover functionality of method - getOptOutInfoSharingDetails.
    *Returns: none
    *
    */
    @isTest static void getOptOutInfoSharingDetailsTest(){
        
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
            responseResult = RE_RDResidentViewCtrl.getOptOutInfoSharingDetails();
        Test.stopTest();
          System.assertEquals(responseResult.isSuccessful,true,'Success');
    }
    
    /*
    *Method Name: createFavoriteTest
    *Description: Method to cover functionality of method - createFavorite.
    *Returns: none
    *
    */
    @isTest static void createFavoriteTest(){
        
        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
            responseResult = RE_RDResidentViewCtrl.createFavorite(locationRecId);
        Test.stopTest();
          System.assertEquals(responseResult.isSuccessful,false,'Success');
    }
    
    /*
    *Method Name: connectDraftReferralsFromResourceDetailsTest
    *Description: Method to cover functionality of method - connectDraftReferralsFromResourceDetails and milesCalculation.
    *Returns: none
    *
    */
    @isTest static void connectDraftReferralsFromResourceDetailsTest(){
        
        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
        Location geoLocationData;
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
            responseResult = RE_RDResidentViewCtrl.connectDraftReferralsFromResourceDetails('12345', true);
            RE_RDResidentViewCtrl.milesCalculation('12345', geoLocationData); 
        Test.stopTest();
          System.assertEquals(responseResult.isSuccessful,false,'Success');
    }
    /*
    *Method Name: testHoursofOperation
    *Description: Method to cover functionality of method - LocationTimeFields.
    *Returns: none
    *
    */
     @isTest static void testHoursofOperation(){
   		 List<Resource__c> resourceLst = [SELECT Id,Organization__c FROM Resource__c LIMIT 1];
        String resourceRecId = resourceLst[0].Id;
        List<Location__c> locationLst = [SELECT Id FROM Location__c LIMIT 1];
        String locationRecId = locationLst[0].Id;
         LocationResource__c objLocRes = [Select Id, notes__c from locationResource__c where resource__c =: resourceRecId and location__c = : locationRecId LIMIT 1];
       	objLocRes.Notes__c=null;
         update objLocRes;
         String locationIdNull = null;
       
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
            responseResult = RE_RDResidentViewCtrl.getResourceData(resourceRecId, locationRecId, '11570');
            RE_RDResidentViewCtrl.getResourceData(resourceRecId, locationIdNull, '11570');
            System.assertEquals(responseResult.isSuccessful,true,'Success');
        Test.stopTest();
    }
}