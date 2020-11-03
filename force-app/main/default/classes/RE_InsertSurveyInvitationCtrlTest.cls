/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_InsertSurveyInvitationCtrlTest
*   Created By  :   Deloitte
*   Created Date:   10/24/2019
*   Description :   This class acts as a test class for RE_InsertSurveyInvitationCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------ 
*     Kojashree Kakariya         11/08/2019        Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_InsertSurveyInvitationCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    @isTest public static  void saveSurveyInvitationTest(){        
        //   List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Account> lstCitizenAccounts =  TestDataFactory.createAccounts(5,true, citizenRecordTypeIdAccount);
        
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 38.328732;
        citizenContact.ContactGeoLocation__Longitude__s = 85.764771; 
        citizenContact.MailingPostalCode='35271';
        insert citizenContact;
        
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(3, false, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        for(Location__c loc : lstLocation){
            loc.Geolocation__Latitude__s = 50.328832;
            loc.Geolocation__Longitude__s = 12.764771;
        }
        insert lstLocation;
        
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(3, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(3,false,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        lstRreferral[0].Location__c=lstLocation[0].Id;
        insert lstRreferral;
                
        List<Contact> lstcontact=new list<Contact>();
        lstcontact.add(citizenContact);
        List<Consent__c> lstconsent=TestDataFactory.createConsent(1,false,lstcontact,lstCitizenAccounts);        
        insert lstconsent;
        
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName AND Name != null];
        Test.startTest();
        
        Referral__c ref=[Select Id,Name,ReferredAccountID__c FROM Referral__c WHERE ReferredAccountID__c!=null LIMIT 1 ];        
        Consent__C con=[Select Id,Name FROM Consent__c LIMIT 1];        
        
        String surveyLink=RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Consent_Survey_1',ref.Id,'Referral',true,false);
        String surveyLink1=RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Consent_Survey_1',con.Id,'Consent',true,true);
        List<String> test11=new list<String>();
        test11.add('hh'+'-'+citizenContact.Id);
        RE_InsertSurveyInvitationCtrl.createFeedbackRecord(test11);
        //SurveyResponse sVal=[select id FROM SurveyResponse WHERE Invitation.Name like 'RE_Cancelled_Referral%' and Invitation.Referral__r.ReferredAccountID__c!=null and Status='Completed' Limit 1];
        
        System.assertEquals(surveyLink!='', true,'Success');
        Test.stopTest();
    }
}