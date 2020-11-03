/**
 * Class Name    : RE_ReferralDetailsCtrlTest
 * Owner         : DELOITTE
 * Created Date  : 24/05/2019
 * Description   : Test Class for RE_ReferralDetailsCtrl
 *
 *                            M O D I F I C A T I O N   L O G
 *
 *  Date        Developer       Description
 *  ----------  -----------     -------------------------------------------------------------------
 *  24/05/2019  Payal       Initial Version
 **/
@isTest
public class RE_ReferralDetailsCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
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
        EmailSetting__c setting = new EmailSetting__c();
        setting.Name='Follow up on cancelled resources';
        setting.Is_on__c= true;
        
        insert setting;
        
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = TestDataFactory.createResources(3, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<Referral__c> lstRreferral=TestDataFactory.createReferral(3,false,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,citizenContact.Id,lstCitizenAccounts,lstResource);
        lstRreferral[0].Location__c=lstLocation[0].Id;
        insert lstRreferral;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
    }

    @isTest public static  void getReferralDetailsTest(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Test.startTest();
        Referral__c ref=[Select Id,Name FROM Referral__c LIMIT 1];
        System.runAs(citizenUser){
            RE_CreateLightningServerResponse response2=RE_ReferralDetailsCtrl.getReferralDetails(ref.Id);
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            System.assertEquals(response2.isSuccessful, true,'Success');
        }
        Test.stopTest();

    }
    



    @isTest public static  void updateReferralDetailsTest(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        //insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        List<Referral__c> refList = [SELECT Id, OwnerId, ReferredAccountID__c FROM Referral__c LIMIT 5];
        Account acc = [SELECT Id from Account LIMIT 1];
        Contact con = [SELECT Id from Contact LIMIT 1];
        con.AccountId = acc.Id;
        
        update con;
        Resource__c res = [SELECT Id,Name FROM Resource__c LIMIT 1];
        
        EmailSetting__c testEmailSettings = new EmailSetting__c();
        testEmailSettings.Name = 'Follow up on cancelled resources';
        testEmailSettings.Is_on__c = true;
        insert testEmailSettings;
        
        EmailSetting__c testEmailSettingsCom = new EmailSetting__c();
        testEmailSettingsCom.Name = 'Follow up on provided resource';
        testEmailSettingsCom.Is_on__c = true;
        insert testEmailSettingsCom;
        
        Email_Text_Communication_Settings__c testEmailComm = new Email_Text_Communication_Settings__c();
        testEmailComm.Text_Communication__c = true;
        testEmailComm.Email_Communication__c = true;
        insert testEmailComm;
        
        Test.startTest();
        System.runAs(citizenUser) {
            RE_ReferralWrapper objWrapper = new RE_ReferralWrapper();
            objWrapper.Id = refList[0].Id;
            objWrapper.Status = RE_GlobalConstants.STATUS_OPEN;
            objWrapper.OwnerId = refList[0].OwnerId;
            objWrapper.OutcomeReason = RE_GlobalConstants.OUTCOME_REASON_SERVICE_PROVIDED;
            RE_CreateLightningServerResponse response = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper);

            RE_ReferralWrapper objWrapper1= new RE_ReferralWrapper();
            objWrapper1.Id = refList[1].Id;
            objWrapper1.Status = RE_GlobalConstants.STATUS_ACTIVE;
            objWrapper1.OwnerId = refList[1].OwnerId;
            RE_CreateLightningServerResponse response1 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper1);
            System.assertEquals(response1.isSuccessful, false,'Success');

            RE_ReferralWrapper objWrapper2 = new RE_ReferralWrapper();
            objWrapper2.Id = refList[2].Id;
            objWrapper2.Status = RE_GlobalConstants.STATUS_CLOSING_REFERRAL;
            objWrapper2.OwnerId = refList[2].OwnerId;
            objWrapper2.ReferredOrgID = refList[2].ReferredAccountID__c;
            objWrapper2.Rating = 1;
            objWrapper2.AdditionalComments = 'Test';
            objWrapper2.sContactPreferredCommMethod = 'Mobile Phone';
            objWrapper2.OutcomeReason = RE_GlobalConstants.REFERRAL_CANCELLED_BY_CLIENT;
            
            RE_CreateLightningServerResponse response2 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper2);
            RE_ReferralDetailsCtrl.sendEmailWhenReferralClosed(objWrapper2);
            
            RE_ReferralWrapper objWrapper3 = new RE_ReferralWrapper();
            objWrapper3.Id = refList[2].Id;
            objWrapper3.Status = RE_GlobalConstants.STATUS_CLOSING_REFERRAL;
            objWrapper3.OwnerId = refList[2].OwnerId;
            objWrapper3.ReferredOrgID = refList[2].ReferredAccountID__c;
            objWrapper3.Rating = 1;
            objWrapper3.AdditionalComments = 'Test';
            objWrapper3.sContactPreferredCommMethod = 'Mobile Phone';
            objWrapper3.sContactEmail = 'test@gmail.com';
            objWrapper3.sContactAccId = acc.Id;
            objWrapper3.Outcome = RE_GlobalConstants.CLAIM_ResourceProvided;
            objWrapper3.ResourceName = res.Name;
            objWrapper3.ReferredAccountID = acc.Id;
            
            RE_CreateLightningServerResponse response3 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper3);
            RE_ReferralDetailsCtrl.sendEmailWhenReferralClosed(objWrapper3);
            
            RE_ReferralWrapper objWrapper4 = new RE_ReferralWrapper();
            RE_CreateLightningServerResponse response4 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper4);
            System.assertEquals(response4.isSuccessful,false,'Success');
       }
        Test.stopTest();
    }

    @isTest public static  void getPickListValuesTest(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Test.startTest();
        System.runAs(citizenUser){
            RE_CreateLightningServerResponse response=RE_ReferralDetailsCtrl.getPickListValues('Referral__c','ClientRating__c,Outcome__c');
            System.assertEquals(response.isSuccessful,true,'Success');
            RE_CreateLightningServerResponse response1=RE_ReferralDetailsCtrl.getPickListValues('Referral','ClientRating__c,Outcome__c');
            System.assertEquals(response1.isSuccessful,false,'Success');
        }
        Test.stopTest();
    }
    
    @isTest public static  void getReferralDetailsTestExcpt(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        //insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
            // Account acc = [SELECT ID FROM ACCOUNT LIMIT 1];
        
        Test.startTest();
        
        System.runAs(citizenUser){
            RE_ReferralDetailsCtrl.getReferralDetails(RE_GlobalConstants.sEmptyString);
          //  RE_ReferralDetailsCtrl.getUserRecordDetails(testRef);
            RE_CreateLightningServerResponse response = RE_ReferralDetailsCtrl.updateReferralDetails(null);
            system.assertEquals(response.isSuccessful, false,'Success');
        }
        Test.stopTest();
        
    }
    
    @isTest public static  void updateReferralDetailsTestWithoutUser(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        //insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        List<Referral__c> refList = [SELECT Id, OwnerId, ReferredAccountID__c FROM Referral__c LIMIT 5];
        Account acc = [SELECT Id from Account LIMIT 1];
        Contact con = [SELECT Id from Contact LIMIT 1];
        con.AccountId = acc.Id;
        update con;
        Resource__c res = [SELECT Id,Name FROM Resource__c LIMIT 1];
        
        EmailSetting__c testEmailSettings = new EmailSetting__c();
        testEmailSettings.Name = 'Follow up on cancelled resources';
        testEmailSettings.Is_on__c = true;
        insert testEmailSettings;
        
        EmailSetting__c testEmailSettingsCom = new EmailSetting__c();
        testEmailSettingsCom.Name = 'Follow up on provided resource';
        testEmailSettingsCom.Is_on__c = true;
        insert testEmailSettingsCom;
        
        Email_Text_Communication_Settings__c testEmailComm = new Email_Text_Communication_Settings__c();
        testEmailComm.Text_Communication__c = true;
        testEmailComm.Email_Communication__c = true;
        insert testEmailComm;
        
        Test.startTest();
       
            RE_ReferralWrapper objWrapper = new RE_ReferralWrapper();
            objWrapper.Id = refList[0].Id;
            objWrapper.Status = RE_GlobalConstants.STATUS_OPEN;
            objWrapper.OwnerId = refList[0].OwnerId;
            objWrapper.OutcomeReason = RE_GlobalConstants.OUTCOME_REASON_SERVICE_PROVIDED;
            RE_CreateLightningServerResponse response = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper);

            RE_ReferralWrapper objWrapper1= new RE_ReferralWrapper();
            objWrapper1.Id = refList[1].Id;
            objWrapper1.Status = RE_GlobalConstants.STATUS_ACTIVE;
            objWrapper1.OwnerId = refList[1].OwnerId;
            RE_CreateLightningServerResponse response1 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper1);
            System.assertEquals(response1.isSuccessful, false,'Success');

            RE_ReferralWrapper objWrapper2 = new RE_ReferralWrapper();
            objWrapper2.Id = refList[2].Id;
            objWrapper2.Status = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            objWrapper2.OwnerId = refList[2].OwnerId;
            objWrapper2.ReferredOrgID = refList[2].ReferredAccountID__c;
            objWrapper2.Rating = 1;
            objWrapper2.AdditionalComments = 'Test';
            objWrapper2.sContactPreferredCommMethod = 'Email';
            objWrapper2.Outcome = RE_GlobalConstants.CLAIM_ConsentProvidedVerbal;
            objWrapper2.OutcomeReason = RE_GlobalConstants.REFERRAL_CANCELLED_BY_CLIENT;
            
            RE_CreateLightningServerResponse response2 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper2);
            RE_ReferralDetailsCtrl.sendEmailWhenReferralClosed(objWrapper2);
            
            RE_ReferralWrapper objWrapper3 = new RE_ReferralWrapper();
            objWrapper3.Id = refList[2].Id;
            objWrapper3.Status = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            objWrapper3.OwnerId = refList[2].OwnerId;
            objWrapper3.ReferredOrgID = refList[2].ReferredAccountID__c;
            objWrapper3.Rating = 1;
            objWrapper3.AdditionalComments = 'Test';
            objWrapper3.sContactPreferredCommMethod = 'Email';
            objWrapper3.sContactEmail = 'test@gmail.com';
            objWrapper3.sContactAccId = acc.Id;
            objWrapper3.Outcome = RE_GlobalConstants.CLAIM_ResourceProvided;
            objWrapper3.ResourceName = res.Name;
            objWrapper3.ReferredAccountID = acc.Id;
            
            RE_CreateLightningServerResponse response3 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper3);
            RE_ReferralDetailsCtrl.sendEmailWhenReferralClosed(objWrapper3);
            
            RE_ReferralWrapper objWrapper4 = new RE_ReferralWrapper();
            RE_CreateLightningServerResponse response4 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper4);
            System.assertEquals(response4.isSuccessful,false,'Success');
     
        Test.stopTest();
    }
    
    @isTest public static  void updateReferralDetailsTestWTHUser(){
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        //insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        List<Referral__c> refList = [SELECT Id, OwnerId, ReferredAccountID__c FROM Referral__c LIMIT 5];
        Account acc = [SELECT Id from Account LIMIT 1];
        Contact con = [SELECT Id from Contact LIMIT 1];
        con.AccountId = acc.Id;
        update con;
        Resource__c res = [SELECT Id,Name FROM Resource__c LIMIT 1];
        
        EmailSetting__c testEmailSettings = new EmailSetting__c();
        testEmailSettings.Name = 'Follow up on cancelled resources';
        testEmailSettings.Is_on__c = true;
        insert testEmailSettings;
        
        EmailSetting__c testEmailSettingsCom = new EmailSetting__c();
        testEmailSettingsCom.Name = 'Follow up on provided resource';
        testEmailSettingsCom.Is_on__c = true;
        insert testEmailSettingsCom;
        
        Email_Text_Communication_Settings__c testEmailComm = new Email_Text_Communication_Settings__c();
        testEmailComm.Text_Communication__c = true;
        testEmailComm.Email_Communication__c = true;
        insert testEmailComm;
        
        Test.startTest();
            RE_ReferralWrapper objWrapper3 = new RE_ReferralWrapper();
            objWrapper3.Id = refList[2].Id;
            objWrapper3.Status = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            objWrapper3.OwnerId = refList[2].OwnerId;
            objWrapper3.ReferredOrgID = refList[2].ReferredAccountID__c;
            objWrapper3.Rating = 1;
            objWrapper3.AdditionalComments = 'Test';
            objWrapper3.sContactPreferredCommMethod = RE_GlobalConstants.MobilePhone;
            objWrapper3.sContactEmail = 'test@gmail.com';
            objWrapper3.sContactAccId = acc.Id;
            objWrapper3.Outcome = RE_GlobalConstants.CLAIM_ResourceProvided;
            objWrapper3.ResourceName = res.Name;
            objWrapper3.ReferredAccountID = acc.Id;
            
            RE_CreateLightningServerResponse response3 = RE_ReferralDetailsCtrl.updateReferralDetails(objWrapper3);
         
            System.assertEquals(response3.isSuccessful,true,'Success');
     
        Test.stopTest();
    }


}