/**
* Class Name    : RE_CreateReferralCtrlTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_CreateReferralCtrlTest
*
*                            M O D I F I C A T I O N   L O G
*
*  Date        Developer       Description
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Prashant       Initial Version
**/
@isTest
public class RE_CreateReferralCtrlTest {
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        TriggerSettings__c locSettings = new TriggerSettings__c();
        locSettings.Name = RE_GlobalConstants.LOCATION_TRIGGER_CUSTOM_SETTING;
        locSettings.IsActive__c = True;
        Insert locSettings;
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);                
        EmailSetting__c emailSetting= new EmailSetting__c();
        emailSetting.Name='Referral created mail';
        emailSetting.Is_on__c = true;
        insert emailSetting;
        insert new Email_Text_Communication_Settings__c(Email_Communication__c=true,Text_Communication__c=true);
        
        WebServiceSettings__c obj = new WebServiceSettings__c();
        obj.Name = 'MCI Client Search';
        obj.Source_System__c = 'HBE';
        obj.Target_URL__c = 'https://www.test';
        obj.Certificate_Name__c = 'ABC';
        obj.Time_Out__c=6000;
        insert obj;
        
        WebServiceSettings__c obj1 = new WebServiceSettings__c();
        obj1.Name = 'MCI Entity Search';
        obj1.Source_System__c = 'HBE';
        obj1.Target_URL__c = 'https://www.test';
        obj1.Certificate_Name__c = 'ABC';
        obj1.Time_Out__c=6000;
        insert obj1;
        
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Contact cpusercontact =[Select id,phone,primarylocation__c from contact where id=:communityUser.contactid];
        
        Contact_Mapping__c mappingObj = new Contact_Mapping__c();
        mappingObj.Contact__c = cpusercontact.Id;
        mappingObj.IEES_Id__c = Double.valueOf('546789023');
        mappingObj.Group_Id__c = 'ABC';
        insert mappingObj;
        RE_CreateCitizenHelper.createContactMapping(cpusercontact.Id, 546789023);
        List<Contact_Mapping__c> lstContactMap1 = [SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c];
        
    }
    @isTest public static void fetchloggedInUserInfoTest(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        User usertest = [SELECT Id,ContactId FROM USER LIMIT 1];
        Contact cpusercontact =[Select id,phone,primarylocation__c from contact where id=:communityUser.contactid];
        Location__c loc=[Select id,name from location__c limit 1];
        cpusercontact.Phone='(423) 424-4444';
        cpusercontact.primarylocation__c=loc.id;
        update cpusercontact;
        Test.startTest();
        
        System.runAs(communityUser){
            RE_CreateLightningServerResponse response2=RE_CreateReferralCtrl.fetchloggedInUserInfo();
            System.assertEquals(response2.isSuccessful, true,'Success');
        }
        
        Test.stopTest();
        
    }
    
    @isTest public static void fetchLocationsTest(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Test.startTest();
        List<account> lstAccount=[Select id, name from Account LIMIT 1];
        System.runAs(communityUser){
            RE_CreateLightningServerResponse response2=RE_CreateReferralCtrl.fetchLocations(lstAccount[0].id);
            System.assertEquals(response2.isSuccessful, true,'Success');
       
            RE_CreateLightningServerResponse response3=RE_CreateReferralCtrl.fetchLocations('');
            System.assertEquals(response3.isSuccessful, true,'Success');
        }
        Test.stopTest();
        
    }
    
    @isTest public static void fetchLocationResourcesTest(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<account> lstAccount=[Select id, name from Account LIMIT 1];
        List<Location__c> lstlocation=[Select id,name from Location__c LIMIT 1];
        List<Resource__c> lstresource = [Select id,name from Resource__c];
        LocationResource__c objlocationresource= new LocationResource__c(Status__c='Active',Name='locationres',Resource__c=lstresource[0].id,Location__c=lstlocation[0].id);
        insert objlocationresource;
        Test.startTest(); 
        System.runAs(communityUser){
            RE_CreateLightningServerResponse response2=RE_CreateReferralCtrl.fetchLocationResources(objlocationresource.id);
            RE_CreateLightningServerResponse response3=RE_CreateReferralCtrl.fetchLocationResources('123');
            System.assertEquals(response2.isSuccessful, true,'Success');
            System.assertEquals(response3.isSuccessful, true,'Success');
        }
        
        Test.stopTest();
    }
    
    @isTest public static void insertReferralTest(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<account> lstAccount=[Select id, name from Account];
        List<ID> accidset= new List<ID>();
        accidset.add(lstAccount[0].id);
        List<Location__c> lstlocation=[Select id,name from Location__c];
        List<Resource__c> lstresource = [Select id,name from Resource__c];
        LocationResource__c objlocationresource= new LocationResource__c(Name='locationres',Resource__c=lstresource[0].id,Location__c=lstlocation[0].id,Status__c='Active',Phone__c='(671) 289-1256');
        insert objlocationresource;
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Contact> citizencontacts=[Select id,RecordtypeId,name ,PreferredCommunicationMethod__c from contact];
        citizencontacts[0].RecordtypeId=contactCitizenRecordTypeId;
        citizencontacts[0].MailingPostalCode='34322';
        citizencontacts[0].PreferredCommunicationMethod__c='Email';
        update citizencontacts[0];
        RE_CreateReferralCtrl.RE_RefWrapper objWrapper = new RE_CreateReferralCtrl.RE_RefWrapper();
        objWrapper.Contact=citizencontacts[0].id;
        objWrapper.Email='abc@xyz.com';
        objWrapper.Location=lstlocation[0].id;
        objWrapper.Notes='test';
        objWrapper.isIEESData=true;
        objWrapper.Name='test';
        objWrapper.Organization=lstAccount[0].id;
        objWrapper.Resource=lstresource[0].id;
        objWrapper.Phone='(671) 289-1256';

        RE_ClientsHelper.DataTableWrapper obj = new RE_ClientsHelper.DataTableWrapper();
        obj.IEESId = '1234';
        obj.FirstName = 'Sample';
        obj.LastName = 'Sam';
        obj.Email = 'sam@sample.com';
        obj.Phone = '(671) 289-1256';
        obj.Birthdate =  Date.newInstance(2016, 12, 9);
        objWrapper.clientData = JSON.serialize(obj);
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset);
        locationList.addAll(TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset));
        
        locationList[0].DaysLocationClosed__c='Tuesday';
        locationList[1].DaysLocationClosed__c='Thursday';
        RE_CreateReferralCtrl.RE_RefWrapper objWrapper1 = new RE_CreateReferralCtrl.RE_RefWrapper();
        objWrapper1.Contact=citizencontacts[0].id;
        objWrapper1.Email='abc@abc.com';
        objWrapper1.Location=locationList[0].id;
        objWrapper1.Notes='test';
        objWrapper1.Name='test';
        objWrapper1.isIEESData =false;
        objWrapper1.Organization=lstAccount[0].id;
        objWrapper1.Resource=lstresource[0].id;
        objWrapper1.Phone='(671) 289-1256';

        RE_ClientsHelper.DataTableWrapper obj2 = new RE_ClientsHelper.DataTableWrapper();
        obj2.IEESId = '1234';
        obj2.FirstName = 'Sample';
        obj2.LastName = 'Sam';
        obj2.Email = 'sam@sample.com';
        obj2.Phone = '(671) 289-1256';
        obj2.Birthdate =  Date.newInstance(2016, 12, 9);
        objWrapper1.clientData = JSON.serialize(obj2);
        
        RE_CreateReferralCtrl.RE_RefWrapper objWrapper2 = new RE_CreateReferralCtrl.RE_RefWrapper();
        objWrapper2.Contact=citizencontacts[0].id;
        objWrapper2.Email='abc@abc.com';
        objWrapper2.Location=locationList[1].id;
        objWrapper2.Notes='test';
        objWrapper2.Archetype ='test';
        objWrapper2.Name='test';
        objWrapper2.isIEESData =false;
        objWrapper2.Organization=lstAccount[0].id;
        objWrapper2.Resource=lstresource[1].id;
        objWrapper2.Phone='(671) 289-1256';

        RE_ClientsHelper.DataTableWrapper obj3 = new RE_ClientsHelper.DataTableWrapper();
        obj3.IEESId = '1234';
        obj3.FirstName = 'Sample';
        obj3.LastName = 'Sam';
        obj3.Email = 'sam@sample.com';
        obj3.Phone = '(671) 289-1256';
        obj3.Birthdate =  Date.newInstance(2016, 12, 9);
        objWrapper2.clientData = JSON.serialize(obj3);
        
        
        Test.startTest(); 
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RE_CreateLightningServerResponse response2=RE_CreateReferralCtrl.insertReferral(objWrapper);
        RE_CreateLightningServerResponse response3=RE_CreateReferralCtrl.insertReferral(objWrapper1);
        RE_CreateLightningServerResponse response4=RE_CreateReferralCtrl.insertReferral(objWrapper2);
        System.assertEquals(response2.isSuccessful, true,'Success');
        Test.stopTest();
    } 
    
    
    @isTest public static void testFetchFavResources(){
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        User usertest = [SELECT Id,ContactId FROM USER LIMIT 1];
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        List<LocationResource__c> lstLocResources = [SELECT id FROM LocationResource__c LIMIT 2];
        Test.startTest(); 
        System.runAs(communityUser){
            List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
            RE_CreateLightningServerResponse result = RE_CreateReferralCtrl.fetchFavResources();
            System.assertEquals(result.isSuccessful, true,'Success');
        }
        System.runAs(usertest){
            List<Favorite__c> lstFavs = TestDataFactory.createFavoritesRecords(2,true,lstLocResources);
            RE_CreateLightningServerResponse result = RE_CreateReferralCtrl.fetchFavResources();
            System.assertEquals(result.isSuccessful, true,'Success');
        }
        Test.stopTest();
    }
    
}