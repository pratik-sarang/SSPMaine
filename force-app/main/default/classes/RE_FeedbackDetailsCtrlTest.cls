/**
* Class Name    : RE_FeedbackDetailsCtrlTest
* Owner         : DELOITTE
* Created Date  : 17/06/2019
* Description   : Test Class for RE_FeedbackDetailsCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  17/06/2019  Akash       Initial Version
**/
@isTest
public class RE_FeedbackDetailsCtrlTest{
    
     static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
     static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    
    @testSetup static void setup() {
    
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        TriggerSettings__c conSettings = new TriggerSettings__c(Name=RE_GlobalConstants.CONTACT_TRIGGER_CUSTOM_SETTING,IsActive__c=True);
        Insert conSettings;
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = RE_GlobalConstants.dContactLocLatitude;
        citizenContact.ContactGeoLocation__Longitude__s = RE_GlobalConstants.dContactLocLongitude; 
        citizenContact.MailingPostalCode='43527';
        insert citizenContact;
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(2, false, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        for(Location__c loc : lstLocation){
            loc.Geolocation__Latitude__s = 50.328832;
            loc.Geolocation__Longitude__s = 12.764771;
        }
        insert lstLocation;
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(2, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(1,false,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        lstRreferral[0].Status__c = RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
        lstRreferral[0].Location__c=lstLocation[0].Id;
        insert lstRreferral;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser(RE_GlobalConstants.USER_ALIAS, citizenContact.Id, RE_GlobalConstants.USER_FIRSTNAME, RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<Feedback__c> feedbackList = TestDataFactory.createFeedback(1,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strPartnerFeedbackRecTypeDevName,RE_GlobalConstants.strFeedbackObjectName).Id,lstCitizenAccounts,lstRreferral);
        
        
    }
    
    /******************************************************************************************
    * @author       Akash Sharma
    * @date         17/06/2019
    * @methodname   createFeedbackUpdateReferralTest
    * @description  This method is used to test the functionality of method - createFeedbackUpdateReferral.
    * @param        none
    * @return       none
    ********************************************************************************************/
     
     @isTest public static void createFeedbackUpdateReferralTest(){
        
        User citizenUser = [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        Referral__c refRecord = [SELECT ID,Outcome__c FROM Referral__c LIMIT 1];
        Map<Object,Object> feedBackDataMap = new Map<Object,Object>{'referralId' => refRecord.Id, 'sReferralOrgId' => accRecord.Id, 'sReferralStatus' => RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM,'bOrgIsClaimed' => false };
        RE_CreateLightningServerResponse result;
        Feedback__c feedBackObj ;
        System.runAs(citizenUser){
            Test.StartTest();
            feedBackObj = new Feedback__c(Rating__c = 1, RatingDescription__c = RE_GlobalConstants.RATING_DESC, AccountID__c = accRecord.Id, Referral__c = refRecord.Id);
            result = RE_FeedbackDetailsCtrl.createFeedbackUpdateReferral(feedBackDataMap,feedBackObj,true);
            System.assert(result.isSuccessful==true,'Success');
            Test.stopTest();
            RE_FeedbackDetailsCtrl.createFeedbackUpdateReferral(feedBackDataMap,feedBackObj,false);
        }
        RE_FeedbackDetailsCtrl.createFeedbackUpdateReferral(feedBackDataMap,feedBackObj,true);// to cover catch block
    }
}