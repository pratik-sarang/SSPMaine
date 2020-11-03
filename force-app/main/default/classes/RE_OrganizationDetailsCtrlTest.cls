/**
 * Class Name    : RE_OrganizationDetailsCtrlTest{
 * Owner         : DELOITTE
 * Created Date  : 05/27/2019
 * Description   : Organization detail test class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
 *  05/27/2019  Arun       Initial Version
 **/
@IsTest
private class RE_OrganizationDetailsCtrlTest {
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Location__c> listLoc=[SELECT Id FROM Location__c LIMIT 1]; 
        listLoc[0].LocationType__c='Headquarters';
        update listLoc;
    }
    @isTest static void testGetOrgdetails() {
        Account account = [Select Id FROM Account WHERE RecordTypeId=: Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId() LIMIT 1];
        Location__c[] locationRecs   = [Select Id, Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,LocationType__c,Account__c , LocationWebsite__c, Phone__c FROM Location__c WHERE Id=: account.Id];
        User u=[SELECT Id, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        System.runAs(u){
            RE_CreateLightningServerResponse response1=RE_OrganizationDetailsCtrl.fetchOrganizationDetails(); 
            System.assertNotEquals(null, response1,'Success');
        }
        Test.startTest();
        if (locationRecs.size() > 0){
            RE_LocationCtrl.locationWrapper objLocationWrapper = new RE_LocationCtrl.locationWrapper(locationRecs[0]);
            RE_OrganizationDetailsCtrl.updateOrganizationDetail(account,objLocationWrapper);
        }
        List<Location__c> listLocations=RE_OrganizationDetailsCtrl.fetchLocations(account.Id);
        System.assertEquals(2, listLocations.size(),'Success');
        RE_OrganizationDetailsCtrl.fetchLocationHeadQuarter(account.Id);
        Test.stopTest();
    }
    @isTest static void testGetOrgdetailsWithStaffUsr() {
        Account account = [Select Id,LastModifiedById FROM Account WHERE RecordTypeId=: Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId() LIMIT 1];
        User u=[SELECT Id, ContactId FROM User WHERE Email='communitystaffusr@deloitte.com' LIMIT 1];
        Location__c[] locationRecs = [Select Id, Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,LocationType__c,Account__c FROM Location__c WHERE Id=: account.Id];
        System.runAs(u){
            RE_CreateLightningServerResponse response1=RE_OrganizationDetailsCtrl.fetchOrganizationDetails(); 
            System.assertNotEquals(null, response1,'Success');
        }
        Test.startTest();
        if (locationRecs.size() > 0){
            RE_LocationCtrl.locationWrapper objLocationWrapper = new RE_LocationCtrl.locationWrapper(locationRecs[0]);
            RE_OrganizationDetailsCtrl.updateOrganizationDetail(account,objLocationWrapper);
        }
        List<Location__c> listLocations=RE_OrganizationDetailsCtrl.fetchLocations(account.Id);
        List<Location__c> listLocations2=RE_OrganizationDetailsCtrl.fetchLocations(account.LastModifiedById);
        System.assertEquals(2, listLocations.size(),'Success');
        RE_OrganizationDetailsCtrl.fetchLocationHeadQuarter(account.Id);
        Test.stopTest();
    }
    
    @isTest static void testGetOrgdetailsException() {
        Account account = [Select Id FROM Account WHERE RecordTypeId=: Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId() LIMIT 1];
        User u=[Select Id from User where Email='communityusr@deloitte.com' LIMIT 1];
        Location__c[] locationRecs = [Select Id, Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,LocationType__c,Account__c, LocationWebsite__c, Phone__c FROM Location__c WHERE Id=: account.Id];
        Test.startTest();
        System.runAs(u){
            RE_CreateLightningServerResponse response1=RE_OrganizationDetailsCtrl.fetchOrganizationDetails(); 
            System.assertNotEquals(null, response1,'Success');
        }
        if (locationRecs.size() > 0){
            RE_LocationCtrl.locationWrapper objLocationWrapper = new RE_LocationCtrl.locationWrapper(locationRecs[1]);
            RE_OrganizationDetailsCtrl.updateOrganizationDetail(account,objLocationWrapper);
        }
        List<Location__c> listLoc=RE_OrganizationDetailsCtrl.fetchLocations(account.Id);
        System.assertEquals(2, listLoc.size(),'Success');
        RE_OrganizationDetailsCtrl.fetchLocationHeadQuarter(account.Id);
        Test.stopTest();
    }
    @isTest static void testUpdateOrganizationDetail() {
        Account OrgRec= [Select Id,Name FROM Account LIMIT 1];
        Account OrgRecFail = [Select Name,LastModifiedById FROM Account LIMIT 1];
        List<Location__c> locationList = [SELECT  id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,
        PointofContactPhone__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,
        SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,
        ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,
        WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,
        ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,
        City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,POCPhoneExt__c,Notes__c,
        Language__c,LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c, LocationWebsite__c, Phone__c FROM Location__c LIMIT 1];
        OrgRec.Name='Test Account';
        OrgRecFail.Name='Test Account2';
        RE_LocationCtrl.locationWrapper locwrap=new RE_LocationCtrl.locationWrapper(locationList[0]);
        RE_CreateLightningServerResponse result =RE_OrganizationDetailsCtrl.updateOrganizationDetail(OrgRec,locwrap);
        RE_CreateLightningServerResponse result2 =RE_OrganizationDetailsCtrl.updateOrganizationDetail(OrgRecFail,locwrap);
        System.assert(result.isSuccessful == true,'Success');
        System.assert(result2.isSuccessful == false,'Success'); 
    }
    @isTest static void testUserPermissionAccess() {
        User u=[SELECT Id, ContactId FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST LIMIT 1];
        System.runAs(u){
            Boolean result = RE_OrganizationDetailsCtrl.userPermissionAccess();
            System.assert(result == true,'Success'); 
        }
    }
}