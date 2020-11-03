/**
* Class Name    : RE_PopulateLatAndLongTest
* Owner         : DELOITTE
* Created Date  : 06/18/2019
* Description   : Poplating lat and long of loaction record using zipcode through google map api test class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/18/2019  Arun       Initial Version
*  
**/
@isTest
public class RE_PopulateLatAndLongTest {
    @testSetup static void setup(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Id> lstParentAccountIds=new List<Id>();
        List<Account> listAccount=TestDataFactory.createAccounts(1,true,accountRecordTypeId);
        lstParentAccountIds.add(listAccount[0].Id);
        // Insert Contact record
        RecordType clontactRecordType=GeneralUtility.fetchRecordType(RE_GlobalConstants.strRecordTypeDeveloperName, RE_GlobalConstants.strSobjectName);
        List<Contact> listContact=TestDataFactory.createContacts(50, false, clontactRecordType.Id, lstParentAccountIds,false);
        listContact[0].MailingPostalCode=String.valueOf(RE_GlobalConstants.dZipCode_TEST);
        listContact[0].MailingStreet ='33 3rd Avenue';
        listContact[0].MailingState='New York';
        listContact[0].MailingCountry='USA';
        listContact[0].MailingCity='New York City';
        insert listContact;
        // Insert Location record
        RecordType claimRecordType=GeneralUtility.fetchRecordType(RE_GlobalConstants.LOCATION, RE_GlobalConstants.strLocationObjectName);
        List<Location__c> listLocation=TestDataFactory.createLocations(50, false, claimRecordType.Id, lstParentAccountIds);
        listLocation[0].Zip__c=RE_GlobalConstants.dZipCode_TEST;
        insert listLocation;
        // insert custom setting
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='RE_GoogleMapAPI';
        setting.Account_API_Key__c='AIzaSyBwQAy5ZMxTXt-Wrc64WsdYtxyYs5N1WYs';
        setting.Endpoint_URI__c='https://maps.googleapis.com/maps/api/geocode/json?';
        insert setting;
    }
    @isTest static void testConatctlatAndLong(){
        String sJSONResponse ='{ "results": [ { "address_components": [ { "long_name": "52726", "short_name": "52726", "types": [ "postal_code" ] }, { "long_name": "Blue Grass", "short_name": "Blue Grass", "types": [ "locality", "political" ] }, { "long_name": "Iowa", "short_name": "IA", "types": [ "administrative_area_level_1", "political" ] }, { "long_name": "United States", "short_name": "US", "types": [ "country", "political" ] } ], "formatted_address": "Blue Grass, IA 52726, USA", "geometry": { "bounds": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } }, "location": { "lat": 41.4986961, "lng": -90.7722974 }, "location_type": "APPROXIMATE", "viewport": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } } }, "place_id": "ChIJ93fcNsbF44cR6AyPC07TrQI", "types": [ "postal_code" ] } ], "status": "OK" }';        Re_ClientViewWrapper.parse(sJSONResponse);
        RE_GoogleMapGeoLocationResponseWrapper.parse(sJSONResponse);
        List<Contact> listContact=[Select Id,MailingPostalCode,ContactGeoLocation__Latitude__s,ContactGeoLocation__Longitude__s from Contact];
        List<Id> lstParam=new List<Id>();
        RE_GoogleMapGeoLocationResponseWrapper wrapper=(RE_GoogleMapGeoLocationResponseWrapper )JSON.deserialize(sJSONResponse, RE_GoogleMapGeoLocationResponseWrapper.class);
        Schema.SObjectType objectType = listContact[0].getSObjectType();
        Test.startTest();
        for(Contact objContact : listContact){
            lstParam.add(objContact.Id);
        }
        RE_PopulateLatAndLong.populate(lstParam);
        RE_PopulateLatAndLong.getWrapperData(wrapper, objectType, listContact[0]);
        RE_PopulateLatAndLong.updateGeoLocationField(listContact[0]);
        //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
        system.assertNotEquals(listContact[0].ContactGeoLocation__Latitude__s,[SELECT ContactGeoLocation__Latitude__s FROM Contact LIMIT 1].ContactGeoLocation__Latitude__s); //commented due to mock deployment errors
        Test.stopTest();
    }
    @isTest static void testLocationlatAndLong(){
        String sJSONResponse ='{ "results": [ { "address_components": [ { "long_name": "52726", "short_name": "52726", "types": [ "postal_code" ] }, { "long_name": "Blue Grass", "short_name": "Blue Grass", "types": [ "locality", "political" ] }, { "long_name": "Iowa", "short_name": "IA", "types": [ "administrative_area_level_1", "political" ] }, { "long_name": "United States", "short_name": "US", "types": [ "country", "political" ] } ], "formatted_address": "Blue Grass, IA 52726, USA", "geometry": { "bounds": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } }, "location": { "lat": 41.4986961, "lng": -90.7722974 }, "location_type": "APPROXIMATE", "viewport": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } } }, "place_id": "ChIJ93fcNsbF44cR6AyPC07TrQI", "types": [ "postal_code" ] } ], "status": "OK" }';        Re_ClientViewWrapper.parse(sJSONResponse);
        List<Location__c> listLocation=[Select Id,Zip__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s from Location__c];
        List<Id> lstParam=new List<Id>();
        RE_GoogleMapGeoLocationResponseWrapper wrapper=(RE_GoogleMapGeoLocationResponseWrapper )JSON.deserialize(sJSONResponse, RE_GoogleMapGeoLocationResponseWrapper.class);
        Schema.SObjectType objectType = listLocation[0].getSObjectType();
        Test.startTest();
        for(Location__c loc : listLocation){
            lstParam.add(loc.Id);
        }
        RE_PopulateLatAndLong.populate(lstParam);
        RE_PopulateLatAndLong.getWrapperData(wrapper, objectType, listLocation[0]);
        RE_PopulateLatAndLong.updateGeoLocationField(listLocation[0]);
        system.assertNotEquals(listLocation[0].GeoLocation__Latitude__s,[SELECT GeoLocation__Latitude__s FROM Location__c LIMIT 1].GeoLocation__Latitude__s);
        Test.stopTest();
    }
}