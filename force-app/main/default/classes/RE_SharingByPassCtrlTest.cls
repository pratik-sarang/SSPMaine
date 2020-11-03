/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_SharingByPassCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/28/2019
*   Description :   This class acts as a test class for RE_SharingByPassCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          	Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                   05/28/2019        	Initial Version
* 	  Venkat Korra				08/27/2020			Increasing code coverage for RE Security Changes(21 -> 80)
*****************************************************************************************************************************/
@isTest
public class RE_SharingByPassCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id referralRecTypeId = Schema.SObjectType.Referral__c.getRecordTypeInfosByDeveloperName().get(RE_GlobalConstants.strReferralRecordTypeDeveloperName).getRecordTypeId();
    static Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
    static Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
                 
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='33222';
        citizenContact.PermissionsLevel__c = 'Admin';
        insert citizenContact;
        
        Contact citizenContact1 = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,'test@test.com',contactCitizenRecordTypeId,false);
        citizenContact1.AccountId=lstCitizenAccounts[0].Id;
        citizenContact1.MailingPostalCode='33222';
        citizenContact1.PermissionsLevel__c = 'Admin';
        insert citizenContact1;
        
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
        
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        List<Referral__c> refRec = TestDataFactory.createReferral(2, true,referralRecTypeId,citizenContact.Id, lstCitizenAccounts, resourceList);
        List<Feedback__c> feedbackList = TestDataFactory.createFeedback(1,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strPartnerFeedbackRecTypeDevName,RE_GlobalConstants.strFeedbackObjectName).Id,lstCitizenAccounts,refRec);
        
        List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(2,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
        List<RE_Goal__c> lstGoals = TestDataFactory.createGoalRecords(2,true,lstArchetype);
        List<RE_Taxonomy__c> lstTaxRecords = TestDataFactory.createTaxonomyRecords(2, true);
        List<RE_Config__c> domainConfigLst = TestDataFactory.createDomainConfigRecords(2, true, lstGoals, lstTaxRecords,'DomainConfig');
    }
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/28/2019
* @methodname   testMethod1
* @description  This method is used to 
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testMethod1() {
        List <User> lstUsers = new List<User>();
        Test.startTest();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity,Contact.PermissionsLevel__c 
                    FROM User 
                    WHERE Email=:RE_GlobalConstants.strCitizenEmail];
        List<Resource__c> resourceLst = [SELECT Id FROM Resource__c LIMIT 2];
        Set<String> setResourceIds = new Set<String>();
        setResourceIds.add(resourceLst[0].id);
        //Survey srv = [SELECT Name from Survey limit 1];
        Contact cnt = [SELECT Id from Contact where Email='test@test.com'];
        Profile Prof = [SELECT Id, Name FROM Profile WHERE Name =: RE_GlobalConstants.strNonCitizenProfileName];
        User usr = new User(ContactId = cnt.Id, FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = 'test@test.idetest',TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543', ProfileId = Prof.Id);
        
        System.runAs(lstUsers[0]){
            RE_SharingByPassCtrl.fetchLocationResources(setResourceIds);
            RE_SharingByPassCtrl.fetchResourceTaxnomies(resourceLst[0].id);
            RE_SharingByPassCtrl.mostReferralsReferredToOrg();
            User u = RE_SharingByPassCtrl.getLoggedinUserAccount();
            RE_SharingByPassCtrl.fetchResourceData(setResourceIds);
            //RE_SharingByPassCtrl.getSurveyRecords(srv.Name);
            //RE_SharingByPassCtrl.getSurveyQuestionResponse('Id123');
            RE_SharingByPassCtrl.getContact(new List<Id>{lstUsers[0].ContactId});
            RE_SharingByPassCtrl.insertUser(usr, usr.ProfileId);
            system.assertEquals(lstUsers[0].Id, u.Id);
        }
        Test.stopTest();
    }
    
    @isTest static void testMethod2(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Test.startTest(); 
        System.runAs(communityUser){
            RE_SharingByPassCtrl.getTotalReferralSent(communityUser.Id);
            RE_SharingByPassCtrl.getReferralsMade(communityUser.Id);
            RE_SharingByPassCtrl.getMostReferredByOrg(communityUser.Id);
            List<Group> getGroup = RE_SharingByPassCtrl.getGroup();
            system.assert(getGroup.size() >0, 'Success');
        }
        Test.stopTest();
    }
    @isTest static void fetchRelatedTaxnomiesGroup(){
        RE_SharingByPassCtrl.fetchRelatedTaxnomiesGroup(new Set<String>());
        RE_SharingByPassCtrl.fetchTaxnomiesGroupMembers(new Set<String>());
        RE_SharingByPassCtrl.fetchFinalResourceTaxnomies(new Set<String>());
        RE_SharingByPassCtrl.getMyFavorite(new Set<Id>(), new Set<Id>());
        RE_SharingByPassCtrl.deleteFavoriteClients(new List<Favorite__c>());
        RE_SharingByPassCtrl.getSurveyQuestionResponse('');
        RE_SharingByPassCtrl.deleteRecommendations(new List<ReferralRecommendation__c>());
        Survey srv = RE_SharingByPassCtrl.getSurveyRecords('');
        System.assertEquals(srv, new Survey());
    }
    // Venkat: RE Security Changes
    @isTest static void testCatchExceptions(){
        Test.startTest();
        User u;
        Id profileId;
        String sId;
        try{
            RE_SharingByPassCtrl.insertUser(u, profileId);
            RE_SharingByPassCtrl.updateUser(null, null);
        }catch(Exception e){
            System.debug('exception-'+e.getMessage());
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
        }
        try{
            RE_SharingByPassCtrl.fetchLocationResources(sId);
        }catch(Exception e){
            System.debug('exception-'+e.getMessage());
            System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
        }
        try{
            RE_SharingByPassCtrl.getRecord(u.Id, 'User');
        }catch(Exception e){
            System.debug('exception-'+e.getMessage());
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
        }
        Test.stopTest();
    }
    @isTest static void testUpdateUserStatusToActive(){
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Boolean b = RE_SharingByPassCtrl.updateUserStatusToActive(u);
        Test.stopTest();
        System.assertEquals(true, b, 'Success');
    }
    @isTest static void testFetchOrganizationResults(){
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Email = :RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Account acc = new Account();
        acc.Name = System.Label.RE_AgencyUserAccountName;
        acc.Applicable_Roles__c = RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        acc.BillingCity = 'Frankfort';
        acc.OwnerId = u.Id;
        insert acc;
        List<Account> accList = RE_SharingByPassCtrl.fetchOrganizationResults(acc.Name, acc.BillingCity);
        Id accOwnerId = RE_SharingByPassCtrl.getAccountOwnerId(acc.Id);
        Id accId = RE_SharingByPassCtrl.getAccountId(acc.Id);
        Test.stopTest();
        System.assertNotEquals(null, accList, 'Success');
        System.assertNotEquals(null, accOwnerId, 'Success');
        System.assertNotEquals(null, accId, 'Success');
    }
    @isTest static void testGetCitizenContactDetails(){
        String sRole = RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        Test.startTest();
        Contact con = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Contact c = RE_SharingByPassCtrl.getCitizenContactDetails(con.Id, sRole);
        sObject sObj = RE_SharingByPassCtrl.getRecord(con.Id, 'Contact');
        Test.stopTest();
        System.assertNotEquals(null, c, 'Success');
        System.assertNotEquals(null, sObj, 'Success');
    }
    @isTest static void testGetReferralDetails(){
        Test.startTest();
        Contact con = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE Contacts__c =: con.Id LIMIT 1];
        List<Location__c> lstLocations = [SELECT Id FROM Location__c WHERE RecordTypeId =: locationRecordTypeId LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE RecordTypeId =: citizenRecordTypeIdAccount LIMIT 1];
        List<Resource__c> resourceList=[SELECT Id FROM Resource__c WHERE RecordTypeId =: resourceRecordTypeId LIMIT 1];
        RE_CreateReferralCtrl.RE_RefWrapper objWrapper = new RE_CreateReferralCtrl.RE_RefWrapper();
        objWrapper.Contact = con.id;
        objWrapper.Email='abc@xyz.com';
        objWrapper.Location = lstLocations[0].id;
        objWrapper.Notes='test';
        objWrapper.isIEESData=true;
        objWrapper.Name='test';
        objWrapper.Organization=accList[0].id;
        objWrapper.Resource=resourceList[0].id;
        objWrapper.Phone='(671) 289-1256';
        List<Referral__c> refList = RE_SharingByPassCtrl.getReferralDetails(con.Id);
        List<Referral__c> refList1 = RE_SharingByPassCtrl.getReferralRecords(objWrapper);
        List<Referral__c> refList2 = RE_SharingByPassCtrl.getReferralDetails(con.Id, 'MyResources', 1, 1);
        List<Referral__c> refList3 = RE_SharingByPassCtrl.getReferralDetails(con.Id, 'Completed', 1, 1);
        List<Referral__c> refList4 = RE_SharingByPassCtrl.getReferralDetails(con.Id, 'Suggested', 1, 1);
        List<Referral__c> refList5 = RE_SharingByPassCtrl.getReferralcountforPlan(con.Id);
        Test.stopTest();
        System.assertNotEquals(null, refList, 'Success');
    }
    @isTest static void testGetLocationOperatingHours(){
        Test.startTest();
        List<Location__c> lstLocations = [SELECT Id FROM Location__c WHERE RecordTypeId =: locationRecordTypeId LIMIT 1];
        Set<Id> locIds = new Set<Id>();
        locIds.add(lstLocations[0].Id);
        List<Location__c> locList = RE_SharingByPassCtrl.getLocationOperatingHours(locIds);
        Test.stopTest();
        System.assertNotEquals(null, locList, 'Success');
    }
    @isTest static void testRequestRecommendations(){
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        List<LocationResource__c> lstLocRes = [SELECT Id, Location__c FROM LocationResource__c LIMIT 1];
        ReferralRecommendation__c refRec = new ReferralRecommendation__c();
        refRec.LocationResource__c = lstLocRes[0].Id;
        refRec.User__c = u.Id;
        insert refRec;
        List<ReferralRecommendation__c> lstOfRefRecmd = RE_SharingByPassCtrl.RequestRecommendations(u.Id);
        Test.stopTest();
        System.assertNotEquals(null, lstOfRefRecmd, 'Success');
    }
    @isTest static void testGetLocationResourceRecmds(){
        Test.startTest();
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 2];
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE Contacts__c IN: conList LIMIT 1];
        Set<Id> setOfResIds = new Set<Id>();
        setOfResIds.add(refRec[0].Resource__c);
        List<LocationResource__c> lstLocRes = [SELECT Id, Location__c, Resource__c FROM LocationResource__c WHERE Resource__c IN: setOfResIds LIMIT 1];
        set<String> setOfLocRes = RE_SharingByPassCtrl.getLocationResourceRecmds(refRec[0].Contacts__c);
        integer i = RE_SharingByPassCtrl.getCountValue(refRec[0].Contacts__c);
        Test.stopTest();
        System.assertNotEquals(null, setOfLocRes, 'Success');
    }
    @isTest static void testFetchLookUpValues(){
        Map<String, String> mapInputs = new Map<String, String>();
        mapInputs.put('searchKeyWord', 'Food');
        mapInputs.put('objectName', 'Contact');
        mapInputs.put('rectypeID', contactCitizenRecordTypeId);
        mapInputs.put('bfilter', 'true');
        Test.startTest();
        List<sObject> sObjList = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        mapInputs.put('bfilter', 'false');
        List<sObject> sObjList1 = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        mapInputs.put('objectName', 'Account');
        mapInputs.put('rectypeID', citizenRecordTypeIdAccount);
        List<sObject> sObjList2 = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        mapInputs.put('objectName', 'Location__c');
        mapInputs.put('rectypeID', locationRecordTypeId);
        List<sObject> sObjList3 = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        mapInputs.put('objectName', 'RE_Taxonomy__c');
        List<sObject> sObjList4 = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        mapInputs.put('objectName', 'Consent__c');
        List<sObject> sObjList5 = RE_SharingByPassCtrl.fetchLookUpValues(mapInputs);
        Test.stopTest();
        System.assertNotEquals(null, sObjList, 'Success');
        System.assertNotEquals(null, sObjList1, 'Success');
        System.assertNotEquals(null, sObjList2, 'Success');
        System.assertNotEquals(null, sObjList3, 'Success');
        System.assertNotEquals(null, sObjList4, 'Success');
        System.assertNotEquals(null, sObjList5, 'Success');
    }
    @isTest static void testGetReferralFeedback(){
        Test.startTest();
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE RecordTypeId =: referralRecTypeId LIMIT 1];
        Set<Id> refIds = new Set<Id>();
        refIds.add(refRec[0].Id);
        List<Feedback__c> fbList = [SELECT Id, Referral__c 
                                    FROM Feedback__c 
                                    WHERE Referral__c IN: refRec LIMIT 1];
        List<Feedback__c> feedbackList = RE_SharingByPassCtrl.getReferralFeedback(refIds);
        List<Feedback__c> feedbackList1 = RE_SharingByPassCtrl.getFeedback(String.valueOf(refRec[0].Id), fbList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, feedbackList, 'Success');
        System.assertNotEquals(null, feedbackList1, 'Success');
    }
    @isTest static void testInsertSobject(){
        List<Contact> conList = new List<Contact>();
        Test.startTest();
        Contact con = new Contact();
        con.FirstName = 'TestFN';
        con.LastName = 'TestLN';
        con.Email = 'testFN.testLN@test.com';
        con.recordTypeId = contactCitizenRecordTypeId;
        Boolean b = RE_SharingByPassCtrl.insertSobject(Contact.getSobjectType(), con);
        Contact con1 = new Contact();
        con1.FirstName = 'TestFN1';
        con1.LastName = 'TestLN1';
        con1.Email = 'testFN1.testLN1@test.com';
        con1.recordTypeId = contactCitizenRecordTypeId;
        conList.add(con1);
        Boolean b1 = RE_SharingByPassCtrl.insertSobjects(Contact.getSobjectType(), conList);
        Boolean b2 = RE_SharingByPassCtrl.updateSobjects(Contact.getSobjectType(), conList);
        Test.stopTest();
        System.assertEquals(true, b, 'Success');
        System.assertEquals(true, b1, 'Success');
        System.assertEquals(true, b2, 'Success');
    }
    @isTest static void testFetchLocations(){
        Set<Id> setOfLocResIds = new Set<Id>();
        Test.startTest();
        List<Account> accList = [SELECT Id FROM Account WHERE recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        List<Location__c> locList = [SELECT Id FROM Location__c WHERE RecordTypeId =: locationRecordTypeId LIMIT 1];
        List<LocationResource__c> lstLocRes = [SELECT Id, Location__c FROM LocationResource__c WHERE Location__c IN: locList LIMIT 1];
        setOfLocResIds.add(lstLocRes[0].Id);
        RE_CreateLightningServerResponse resp = RE_SharingByPassCtrl.fetchLocations(accList[0].Id);
        RE_CreateLightningServerResponse resp1 = RE_SharingByPassCtrl.fetchLocationResources(String.valueOf(locList[0].Id));
        List<LocationResource__c> lstOfLocRes = RE_SharingByPassCtrl.getResourcesRecommendations(setOfLocResIds);
        List<LocationResource__c> lstOfLocRes1 = RE_SharingByPassCtrl.lstLocationResource(setOfLocResIds);
        Test.stopTest();
        System.assert(resp.isSuccessful == true,'Success');
        System.assert(resp1.isSuccessful == true,'Success');
        System.assertNotEquals(null, lstOfLocRes, 'Success');
    }
    @isTest static void testForFetchingRecords(){
        String sQuery;
        Test.startTest();
        // Referral
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE RecordTypeId =: referralRecTypeId LIMIT 1];
        // Consent
        User u= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST LIMIT 1];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Id =: u.Contact.AccountId];
        List<Consent__c> consentList = TestDataFactory.createConsent(1, true, conList, accList);
        // Location
        List<Location__c> lstLocations = [SELECT Id FROM Location__c WHERE RecordTypeId =: locationRecordTypeId LIMIT 1];
        // Location Resource
        List<LocationResource__c> lstLocRes = [SELECT Id, Location__c FROM LocationResource__c WHERE Location__c IN: lstLocations LIMIT 1];
        
        sQuery = 'SELECT Id,Name,Archetype__c,Resource__c, Contacts__c FROM Referral__c LIMIT 1';
        Referral__c ref = RE_SharingByPassCtrl.getReferralRecords(sQuery, String.valueOf(refRec[0].Id));
        List<Referral__c> refList = RE_SharingByPassCtrl.fetchReferralCount(sQuery, String.valueOf(refRec[0].Id));
        List<Referral__c> refList1 = RE_SharingByPassCtrl.getRferralRecords(sQuery, null, null);
        List<Referral__c> refList2 = RE_SharingByPassCtrl.getReferralRecords(sQuery, null, null);
        sQuery = 'SELECT Id FROM Consent__c LIMIT 1';
        List<Consent__c> lstOfConsent = RE_SharingByPassCtrl.fetchConsentRecord(sQuery, String.valueOf(consentList[0].Id));
        List<Consent__c> lstOfConsent1 = RE_SharingByPassCtrl.getActiveConsents(sQuery, null);
        List<Consent__c> lstOfConsent2 = RE_SharingByPassCtrl.getPendingConsents(sQuery, null, null);
        List<Consent__c> lstOfConsent3 = RE_SharingByPassCtrl.getConsentsToRemove(sQuery, null, null, null);
        Map<String, String> mapInputs = new Map<String, String>();
        mapInputs.put('sQuery', sQuery);
        mapInputs.put('contactId', conList[0].Id);
        Set<Id> setContactIds = new Set<Id>();
        setContactIds.add(conList[0].Id);
        List<Object> lstOfConsent4 = RE_SharingByPassCtrl.getConsentRecords(mapInputs, setContactIds);
        sQuery = 'SELECT Id FROM Location__c LIMIT 1';
        List<Location__c> lstOfLoc = RE_SharingByPassCtrl.fetchLocationsData(sQuery, null);
        List<Location__c> lstOfLoc1 = RE_SharingByPassCtrl.fetchLocationAddressFields(sQuery, null);
        List<Location__c> lstOfLoc2 = RE_SharingByPassCtrl.getLocationList(sQuery, null);
        sQuery = 'SELECT Id FROM LocationResource__c LIMIT 1';
        List<LocationResource__c> lstOfLocRes = RE_SharingByPassCtrl.fetchLocResource(sQuery, null, null);
        List<LocationResource__c> lstOfLocRes1 = RE_SharingByPassCtrl.fetchAllLocationDataOnLR(sQuery, null);
        List<LocationResource__c> lstOfLocRes2 = RE_SharingByPassCtrl.getLocationResources(sQuery, null, null);
        List<LocationResource__c> lstOfLocRes3 = RE_SharingByPassCtrl.getResourceIdsFromResourceLocation(null, sQuery);
        List<LocationResource__c> lstOfLocRes4 = RE_SharingByPassCtrl.checkLocationRes(sQuery, null, null);
        List<LocationResource__c> lstOfLocRes5 = RE_SharingByPassCtrl.getLocationResourceRecords(null, sQuery, null, null);
        sQuery = 'SELECT Id FROM Account LIMIT 1';
        List<Account> lstOfAcc = RE_SharingByPassCtrl.getAccountRecords(sQuery, null);
        List<Account> lstOfAcc1 = RE_SharingByPassCtrl.getAccountList(sQuery, null);
        List<Account> lstOfAcc2 = RE_SharingByPassCtrl.getOrganizationDetails(sQuery, null);
        sQuery = 'SELECT Id FROM Contact LIMIT 1';
        Contact conObj = RE_SharingByPassCtrl.getContactDetails(sQuery, conList[0].Id);
        Contact conObj1 = RE_SharingByPassCtrl.getContactDetails(sQuery, String.valueOf(conList[0].Id));
        List<Contact> lstOfCon = RE_SharingByPassCtrl.getContacts(conList);
        List<Contact> lstOfCon1 = RE_SharingByPassCtrl.getClients(sQuery, null, null, mapInputs);
        List<Object> lstOfCon2 = RE_SharingByPassCtrl.getContactRecords(sQuery, mapInputs);
        Contact conObj2 = RE_SharingByPassCtrl.getContactWrapper(sQuery, mapInputs);
        sQuery = 'SELECT Id FROM User LIMIT 1';
        List<User> lstOfUser = RE_SharingByPassCtrl.getUserRecords(sQuery, null);
        sQuery = 'SELECT Id FROM AssessmentResponse__c LIMIT 1';
        List<AssessmentResponse__c> lstOfAssRes = RE_SharingByPassCtrl.fetchAssesmentResp(sQuery, null, null);
        List<AssessmentResponse__c> lstOfAssRes1 = RE_SharingByPassCtrl.fetchAssesmentResponseRecords(sQuery,null,null,null);
        sQuery = 'SELECT Id FROM RE_Config__c LIMIT 1';
        List<RE_Config__c> lstOfConfig = RE_SharingByPassCtrl.fetchGoalConfigRecords(sQuery, null, null);
        Test.stopTest();
        System.assertNotEquals(null, ref, 'Success');
        System.assertNotEquals(null, refList, 'Success');
        System.assertNotEquals(null, refList1, 'Success');
        System.assertNotEquals(null, refList2, 'Success');
        System.assertNotEquals(null, lstOfConsent, 'Success');
        System.assertNotEquals(null, lstOfConsent1, 'Success');
        System.assertNotEquals(null, lstOfConsent2, 'Success');
        System.assertNotEquals(null, lstOfConsent3, 'Success');
        System.assertNotEquals(null, lstOfLoc, 'Success');
        System.assertNotEquals(null, lstOfLoc1, 'Success');
        System.assertNotEquals(null, lstOfLoc2, 'Success');
        System.assertNotEquals(null, lstOfLocRes, 'Success');
        System.assertNotEquals(null, lstOfLocRes1, 'Success');
        System.assertNotEquals(null, lstOfLocRes2, 'Success');
        System.assertNotEquals(null, lstOfLocRes3, 'Success');
        System.assertNotEquals(null, lstOfLocRes4, 'Success');
        System.assertNotEquals(null, lstOfLocRes5, 'Success');
        System.assertNotEquals(null, lstOfAcc, 'Success');
        System.assertNotEquals(null, lstOfAcc1, 'Success');
        System.assertNotEquals(null, lstOfAcc2, 'Success');
        System.assertNotEquals(null, conObj, 'Success');
        System.assertNotEquals(null, conObj1, 'Success');
        System.assertNotEquals(null, conObj2, 'Success');
        System.assertNotEquals(null, lstOfUser, 'Success');
        System.assertNotEquals(null, lstOfCon, 'Success');
        System.assertNotEquals(null, lstOfCon1, 'Success');
        System.assertNotEquals(null, lstOfCon2, 'Success');
    }
    @isTest static void testCreateNote(){
        Map<String, String> mapInputs = new Map<String, String>();
        Test.startTest();
        ContentNote cv = new ContentNote(
            Title = 'Test'
        );
        insert cv;
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE RecordTypeId =: referralRecTypeId LIMIT 1];
        mapInputs.put('title', 'TestRec');
        mapInputs.put('description', 'used for testing');
        mapInputs.put('isPublic', 'true');
        mapInputs.put('recid', refRec[0].Id);
        RE_CreateLightningServerResponse resp = RE_SharingByPassCtrl.createNote(mapInputs);
        RE_CreateLightningServerResponse resp1 = RE_SharingByPassCtrl.updateNote(cv.Id, 'Test123', 'Used for testing');
        Test.stopTest();
        System.assert(resp.isSuccessful == true,'Success');
        System.assert(resp1.isSuccessful == true,'Success');
    }
    @isTest static void testFetchResourceData(){
        Map<String, String> mapInputs = new Map<String, String>();
        Map<String, Object> mapInputs1 = new Map<String, Object>();
        Test.startTest();
        List<Contact> conList = [SELECT Id,AccountId FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        List<Referral__c> refRec = [SELECT Id,Name,Archetype__c,Resource__c, Contacts__c 
                                    FROM Referral__c 
                                    WHERE RecordTypeId =: referralRecTypeId LIMIT 1];
        mapInputs1.put('sResourceQuery', 'SELECT Id FROM Resource__c LIMIT 1');
        List<Resource__c> lstOfRes = RE_SharingByPassCtrl.fetchResourceData(mapInputs1);
        mapInputs1.put('sQuery', 'SELECT Id FROM LocationResource__c LIMIT 1');
        List<LocationResource__c> lstOfLocRes = RE_SharingByPassCtrl.getLocationResources(mapInputs1);
        mapInputs.put('sLocResQuery', 'SELECT Id FROM LocationResource__c LIMIT 1');
        List<LocationResource__c> lstOfLocRes1 = RE_SharingByPassCtrl.getLocationResource(mapInputs, null);
        mapInputs.put('sQuery', 'SELECT Id FROM Referral__c LIMIT 1');
        mapInputs.put('daysopen', '1');
        List<Object> lstOfRef = RE_SharingByPassCtrl.getReferralOrganizationDetails(mapInputs, null, null);
        List<Referral__c> lstOfRef1 = RE_SharingByPassCtrl.getBulkReferralRecords(mapInputs, null);
        Test.stopTest();
        System.assertNotEquals(null, lstOfRes, 'Success');
        System.assertNotEquals(null, lstOfLocRes, 'Success');
        System.assertNotEquals(null, lstOfLocRes1, 'Success');
        System.assertNotEquals(null, lstOfRef, 'Success');
        System.assertNotEquals(null, lstOfRef1, 'Success');
    }
    @isTest static void testGetResourceIdsFromAccounts(){
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setResIds = new Set<String>();
        Map<String, String> mapInputs = new Map<String, String>();
        Test.startTest();
        List<Account> accList = [SELECT Id FROM Account WHERE recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        setAccountIds.add(accList[0].Id);
        List<Resource__c> resourceList=[SELECT Id FROM Resource__c WHERE RecordTypeId =: resourceRecordTypeId LIMIT 1];
        setResIds.add(resourceList[0].Id);
        Set<Id> setOfResIds = RE_SharingByPassCtrl.getResourceIdsFromAccounts(setAccountIds);
        List<Resource__c> lstOfRes = RE_SharingByPassCtrl.fetchResourceDataSearch(setResIds);
        List<RE_Config__c> configRec = [SELECT Id FROM RE_Config__c LIMIT 1];
        List<RE_Config__c> config = RE_SharingByPassCtrl.getSearchConfigResults(mapInputs);
        Test.stopTest();
        System.assertNotEquals(null, lstOfRes, 'Success');
    }
    @isTest static void testGetCommunityId(){
        String communityName = 'Resource Engine';
        String surveyName = 'RE_Consent_Survey';
        Test.startTest();
        Network networkRec = RE_SharingByPassCtrl.getCommunityId(communityName);
        Survey_Setting__mdt surveyRec = RE_SharingByPassCtrl.getSurveySetting(surveyName);
        Test.stopTest();
        System.assertNotEquals(null, networkRec, 'Success');
        System.assertNotEquals(null, surveyRec, 'Success');
    }
    @isTest public static void testdeleteObjects(){
        List<Location__c> locList= [Select Id,Name FROM Location__c LIMIT 1];
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accountList = TestDataFactory.createAccounts(5,false,sREAccRecTypeId);
        Test.startTest();
        Database.DeleteResult[] lstdeleteResults=RE_sharingByPassCtrl.deleteObjects(Location__c.getSObjectType(),locList);
        Database.SaveResult[] lstSaveResults=RE_sharingByPassCtrl.insertObjects(Account.getSObjectType(),accountList);
        Test.stopTest();
        System.assertEquals(lstdeleteResults.size()>0,true, 'Success');
    }
    @isTest public static void testgetInactiveACRRecord(){
        Map<String,String> mapInputs= new Map<String,String>();
        Contact con = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        ID nonCitizenRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RE_GlobalConstants.strNonCitizenContactDevName).getRecordTypeId();
        String cpAdminRole=RE_GlobalConstants.sStartStringPercent+RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN+RE_GlobalConstants.sEndStringPercent;
        String cpStaffRole=RE_GlobalConstants.sStartStringPercent+RE_GlobalConstants.COMMUNITY_PARTNER_STAFF+RE_GlobalConstants.sEndStringPercent;
        String squery=RE_DataBaseQueryFields.sQueryDuplicateUser+cpAdminRole +RE_DataBaseQueryFields.sQueryDuplicateUser1+ cpStaffRole+RE_DataBaseQueryFields.sQueryDuplicateUser2;
        mapInputs.put('nonCitizenRectypeId',nonCitizenRectypeId);
        mapInputs.put('cpAdminRole',cpAdminRole);
        mapInputs.put('cpStaffRole',cpStaffRole);
        Test.startTest();
        AccountContactRelation acr=RE_SharingByPassCtrl.getInactiveACRRecord(con.Id,RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN); 
        RE_SharingByPassCtrl.getDuplicateUser(squery,mapInputs,new List<String>{RE_GlobalConstants.strCitizenEmail});      
        Test.stopTest();
        System.assertNotEquals(acr!=null,true, 'Success');
    }
    @isTest public static void testMethod5(){
        Test.startTest();
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accList= [Select Id,Name FROM Account WHERE RecordtypeId=:sREAccRecTypeId LIMIT 1];
        RE_SharingByPassCtrl.getACR(conList,accList[0].Id);
        RE_SharingByPassCtrl.getUserDetails('Select Id,Name FROM USER WHERE IsActive = true AND ContactId IN (SELECT ContactId from AccountContactRelation where AccountId=:referredAccountID AND (Roles includes (:communityAdminRolename) OR Roles includes (:communityStaffRolename) OR Roles includes (:agencyAdminRoleName) OR Roles includes (:agencyStaffRoleName))) AND (ApplicableRoles__c includes (:communityAdminRolename) OR ApplicableRoles__c includes (:agencyAdminRoleName) OR ApplicableRoles__c includes (:communityStaffRolename) OR ApplicableRoles__c includes (:agencyStaffRoleName))',accList[0].Id);
        Test.stopTest();
    }
    @isTest public static void testMethod6(){
        Test.startTest();
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email = :RE_GlobalConstants.strCitizenEmail LIMIT 1];
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accList= [Select Id,Name FROM Account WHERE RecordtypeId=:sREAccRecTypeId LIMIT 1];
        AccountContactRelation acr = new AccountContactRelation(ContactId=conList[0].Id,AccountId=accList[0].Id,Roles='Community Partner Admin',isActive=true);
        insert acr;
        RE_SharingByPassCtrl.getACRRecord(conList[0].Id,'Community Partner Admin',true);
        RE_SharingByPassCtrl.deleteACRRecord(new Set<Id>{acr.Id});
        Test.stopTest();
    }
}