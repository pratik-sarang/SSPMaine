/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_LocationCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/27/2019
*   Description :   This class acts as a test class for RE_LocationCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    05/27/2019        Initial Version
******************************************************************************************************************************/
@isTest
private class RE_LocationCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   setupTestData
* @description  This method is used to create test records for all test methods
* @param        none
* @return       none
********************************************************************************************/
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
        Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);                
    }
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testGetLocationDetails
* @description  This method is used to test the functionality of method - getLocationDetails.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testGetLocationDetails() {        
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            result = RE_LocationCtrl.getLocationDetails(String.valueOf(locationList[0].Id));
        }
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
    }
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testGetLocationDetailsExcptn
* @description  This method is used to test the functionality of catch block of method - getLocationDetails.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testGetLocationDetailsExcptn() {
        User communityUser = [SELECT Id, ContactId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            result = RE_LocationCtrl.getLocationDetails('null');
        }
        Test.stopTest();
        //String expectedPartialJson = '{"attributes":{"Address1__c":"test Addr1","City__c":"test City","Email__c":"dummy@test.com"}}';
        System.assert(result.isSuccessful == false,'Success');
    }
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testIsReadOnly
* @description  This method is used to test the functionality of method - isReadOnly.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testIsReadOnly() {
        User communityUser = [SELECT Id, ContactId FROM USER WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(communityUser) {
            result = RE_LocationCtrl.isReadOnly();
        }
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
    }
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testSaveLocation
* @description  This method is used to test the functionality of method - saveLocation.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testSaveLocation() {
        User communityUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,
        PointofContactPhone__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,
        SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,
        ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,
        WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,
        ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,POCPhoneExt__c,Language__c,Notes__c,
        City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,
        LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c ,Phone__c, LocationWebsite__c  FROM Location__c LIMIT 1];
        RE_LocationCtrl.locationWrapper objLocation = new RE_LocationCtrl.locationWrapper(locationList[0]);
        RE_LocationCtrl.locationWrapper objLocationForOtherWrap = new RE_LocationCtrl.locationWrapper(locationList[0],true);
        objLocation.sCity ='Test city';
        String jsonString = JSON.Serialize(objLocation);
        Test.startTest();
        System.runAs(communityUser) {
            RE_LocationCtrl.saveLocation(jsonString, true);
        }
        Test.stopTest();
        List<Location__c> updatedLocationList = [SELECT Id FROM Location__c WHERE City__c = 'Test city' Limit 1];
        System.assert(updatedLocationList.size() == 1,'Success');
}
    
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testSaveLocationExcptn
* @description  This method is used to test the functionality of catch block of method- saveLocation.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testSaveLocationExcptn() {
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Location__c objLocation = new Location__c();
        objLocation.Email__c = RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST;
        String jsonString = JSON.Serialize(objLocation);
        Test.startTest();
        System.runAs(communityUser) {
            RE_LocationCtrl.saveLocation(jsonString, true);
        }
        Test.stopTest();
        List<Location__c> lstLocations = [SELECT Id FROM Location__c WHERE Email__c=: RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST LIMIT 1];
        System.assert(lstLocations.size() == 0,'Success');
    }
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/27/2019
    * @methodname   testGetFiles
    * @description  This method is used to test the functionality of method - getFiles.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testGetFiles() {
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        RE_FileUploadCtrl.saveChunk(locationList[0].Id,'testFIle','testString','.jpg','','Policy');
        RE_CreateLightningServerResponse objResponse;
        Test.startTest();
        System.runAs(communityUser) {
            objResponse = RE_LocationCtrl.getFiles(String.valueOf(locationList[0].id));
        }
        Test.stopTest();
        System.assert(objResponse.isSuccessful == true,'Success');
    }

       /********************************************************************************************
	* @author       Deeksha Gupta
	* @date         05/27/2019
	* @methodname   testGetFilesExcptn
	* @description  This method is used to test the functionality of catch block of method- getFiles.
	* @param        none
	* @return       none
	********************************************************************************************/
    @isTest static void testGetFilesExcptn() {
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<ContentDocument> lstConDocs;
        RE_CreateLightningServerResponse objResponse;
        Test.startTest();
        System.runAs(communityUser) {
            objResponse = RE_LocationCtrl.getFiles('');
        }
        Test.stopTest();
        System.assert(objResponse.isSuccessful == true,'Error');
    }
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/27/2019
    * @methodname   testDeleteFiles
    * @description  This method is used to test the functionality of method - deleteFiles.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testDeleteFiles() {        
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        List<ContentVersion> contentVersionList = TestDataFactory.createContentVersion(1,true);
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionList[0].Id];
        List<ContentDocumentLink> contentlinkList = TestDataFactory.createContentDocLink(1,true,locationList[0].id,testcontent.ContentDocumentId);
        Test.startTest();
        RE_LocationCtrl.deleteFiles(String.valueOf(testcontent.ContentDocumentId));
        Test.stopTest();
        List<DocumentDetail__c> lstDocuments = [SELECT Id, FileId__c FROM DocumentDetail__c];
        System.assert(lstDocuments.size() == 0,'Success');        
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/27/2019
    * @methodname   testDeleteFilesExcep
    * @description  This method is used to test the functionality of method - deleteFiles.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testDeleteFilesExcep() {        
        List<Location__c> locationList = [SELECT Id FROM Location__c LIMIT 1];
        List<ContentVersion> contentVersionList = TestDataFactory.createContentVersion(1,true);
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionList[0].Id];
        List<ContentDocumentLink> contentlinkList = TestDataFactory.createContentDocLink(1,true,locationList[0].id,testcontent.ContentDocumentId);
        //ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion LIMIT 1]; 
                Test.startTest();
        RE_CreateLightningServerResponse result = RE_LocationCtrl.deleteFiles('12323');
        System.assert(result.isSuccessful == false,'Success');
        Test.stopTest();      
    }  
    
    /********************************************************************************************
    * @author       Lagan Kankane
    * @date         07/25/2019
    * @methodname   testfetchInitData
    * @description  This method is used to test the functionality of method - fetchInitData.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest 
    static void testfetchInitData() {        
        List<Location__c> locationList = [SELECT Account__c FROM Location__c LIMIT 1];
        String AccountId = String.valueOf(locationList[0].Account__c);
        Test.startTest();
        RE_CreateLightningServerResponse result = RE_LocationCtrl.fetchInitData(AccountId);
        System.assert(result.isSuccessful == true,'Success');
        RE_LocationCtrl.fetchInitData('null');
        Test.stopTest();
    }
    /********************************************************************************************
* @author       Lagan Kankane
* @date         07/25/2019
* @methodname   testlocationwrapper
* @description  This method is used to test the functionality of method - locationwrapper.
* @param        none
* @return       none
********************************************************************************************/    
       @isTest 
    static void testlocationwrapper() {        
        List<Location__c> locationList = [SELECT id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,
        PointofContactPhone__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,
        SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,
        ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,
        WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,
        ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,POCPhoneExt__c,Notes__c,
        City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,
        Language__c,LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c,Phone__c, LocationWebsite__c FROM Location__c LIMIT 1];
        Test.startTest();
        RE_LocationCtrl.locationWrapper wrap = new RE_LocationCtrl.locationWrapper(locationList[0]);
        System.assertEquals(wrap.sAddress1,locationList[0].Address1__c);
        Test.stopTest();
    }

/********************************************************************************************
* @author       Lagan Kankane
* @date         07/25/2019
* @methodname   testcreateLocation
* @description  This method is used to test the functionality of method - createLocation.
* @param        none
* @return       none
********************************************************************************************/
       @isTest 
    static void testcreateLocation() {        
        List<Location__c> locationList = [SELECT Account__c FROM Location__c LIMIT 1];
        String AccountId = String.valueOf(locationList[0].Account__c);
        RE_LocationCtrl.locationWrapper objLocationWrapper= new RE_LocationCtrl.locationWrapper(AccountId);
        objLocationWrapper.sName = 'Testing';
        objLocationWrapper.sLanguage = 'Spanish';
        objLocationWrapper.sAddress1 = 'Test Address';
        objLocationWrapper.sAddress2 = 'Test Address2';
        objLocationWrapper.sCity = 'Ballard';  
        objLocationWrapper.tSaturdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSaturdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSundayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSundayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tThursdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tThursdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tWednesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tFridayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tFridayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tWednesdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.sPointofContactPhone = '1234567890';
        objLocationWrapper.bIsPrimary=true;
        
        
        String sJSONwrapper = JSON.serialize(objLocationWrapper);
        Test.startTest();
        RE_CreateLightningServerResponse result = RE_LocationCtrl.createLocation(sJSONwrapper);
        System.assert(result.isSuccessful == true,'Success');
        objLocationWrapper.bIsPrimary=false;
        result = RE_LocationCtrl.createLocation(JSON.serialize(objLocationWrapper));
        System.assert(result.isSuccessful == true,'Success');
        Test.stopTest();
    }
    
    /********************************************************************************************
* @author       Shubham Kumar
* @date         1/9/2020
* @methodname   testSaveLocationElse
* @description  This method is used to test the Else functionality of method - saveLocation.
********************************************************************************************/
    @isTest static void testSaveLocation1() {
        User communityUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,
        PointofContactPhone__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,
        SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,
        ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,
        WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,
        ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,POCPhoneExt__c,Language__c,Notes__c,
        City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,
        LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c, Phone__c, LocationWebsite__c  FROM Location__c LIMIT 1];
        locationList[0].MondayClose__c = system.Time.newInstance(11, 11, 11, 11);
        RE_LocationCtrl.locationWrapper objLocationWrapper= new RE_LocationCtrl.locationWrapper(locationList[0]);
        objLocationWrapper.sName = 'Testing';
        objLocationWrapper.sLanguage = 'Spanish';
        objLocationWrapper.sAddress1 = 'Test Address';
        objLocationWrapper.sAddress2 = 'Test Address2';
        objLocationWrapper.sCity = 'Ballard';  
        objLocationWrapper.tSaturdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSaturdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSundayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tSundayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tThursdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tThursdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tTuesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tWednesdayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tFridayOpen =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tMondayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tFridayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.tWednesdayClose =  String.valueOf(system.Time.newInstance(12, 12, 12, 12));
        objLocationWrapper.sPointofContactPhone = '1234567890';
        objLocationWrapper.bIsPrimary=true;
        objLocationWrapper.sCity ='Test city';
        String jsonString = JSON.Serialize(objLocationWrapper);
        Test.startTest();
        System.runAs(communityUser) {
            RE_LocationCtrl.saveLocation(jsonString, true);
        }
        Test.stopTest();
        List<Location__c> updatedLocationList = [SELECT Id FROM Location__c WHERE City__c =: 'Test city' Limit 1];
        System.assert(updatedLocationList.size() == 1,'Success');
    }
    
    @isTest static void testSaveLocation_nullvalues() {
        User communityUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Location__c> locationList = [SELECT id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,
        PointofContactPhone__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,
        SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,
        ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,
        WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,
        ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,POCPhoneExt__c,Language__c,Notes__c,
        City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,
        LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c, Phone__c, LocationWebsite__c  FROM Location__c LIMIT 1];
        locationList[0].MondayClose__c = system.Time.newInstance(11, 11, 11, 11);
        RE_LocationCtrl.locationWrapper objLocationWrapper= new RE_LocationCtrl.locationWrapper(locationList[0]);
        objLocationWrapper.sName = 'Testing';
        objLocationWrapper.sLanguage = 'Spanish';
        objLocationWrapper.sAddress1 = 'Test Address';
        objLocationWrapper.sAddress2 = 'Test Address2';
        objLocationWrapper.sCity = 'Ballard';  
        objLocationWrapper.tSaturdayClose = null;
        objLocationWrapper.tSaturdayOpen =  null;
        objLocationWrapper.tSundayClose =  null;
        objLocationWrapper.tSundayOpen = null;
        objLocationWrapper.tThursdayClose =  null;
        objLocationWrapper.tThursdayOpen =  null;
        objLocationWrapper.tTuesdayClose =  null;
        objLocationWrapper.tTuesdayOpen =  null;
        objLocationWrapper.tTuesdayOpen =  null;
        objLocationWrapper.tWednesdayOpen =  null;
        objLocationWrapper.tMondayOpen =  null;
        objLocationWrapper.tMondayOpen =  null;
        objLocationWrapper.tFridayOpen =  null;
        objLocationWrapper.tMondayClose =  null;
        objLocationWrapper.tFridayClose =  null;
        objLocationWrapper.tWednesdayClose =  null;
        objLocationWrapper.sPointofContactPhone = '1234567890';
        objLocationWrapper.bIsPrimary=false;
        objLocationWrapper.sCity ='Test city';
        String jsonString = JSON.Serialize(objLocationWrapper);
        Test.startTest();
        System.runAs(communityUser) {
            RE_LocationCtrl.saveLocation(jsonString, true);
        }
        Test.stopTest();
        List<Location__c> updatedLocationList = [SELECT Id,City__c FROM Location__c WHERE City__c =: objLocationWrapper.sCity Limit 1];
        System.assert(updatedLocationList.size() == 1,'Success');
    }
}