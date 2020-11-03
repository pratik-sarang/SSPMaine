/**************************************************************************************************
* Class Name    : SSP_FindDCBSOfficeControllerTest
* Owner         : Aditya Krishna
* Created Date  : 07/06/2020
* Description   : Resource controller Test class for  SSP_FindDCBSOfficeController
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
@isTest
public class SSP_FindDCBSOfficeControllerTest {
    private static GoogleMapsApiConfig__c config = GoogleMapsApiConfig__c.getInstance();
    String GOOGLE_API_KEY = 'AIzaSyB2-VuPNWpfJhcXQeq_ueJjZAFjg-k9xJc';
    String AUTOCOMPLETE_BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json';
    String UTF8 = 'UTF-8';
    private static final String GOOGLE_API_KEY;
    private static final String AUTOCOMPLETE_BASE_URL;
    private static final String PLACE_DETAIL_URL;
    private static final String LOCATION;
    private static final String RADIUS;
    private static final String UTF8 = 'UTF-8';
 
    
    // Test populateCountyMap      
    @isTest static void testpopulateCountyMap() {
       SSP_FindDCBSOfficeController.populateCountyMap();
    }
    
    // Test getOfficeLocation  
    @isTest static void testgetOfficeLocations() {
       decimal lat = 37.096467;
       decimal lang= -85.301281;
       String address_cmp_pro ='[{"long_name" : "427285858","short_name" : "427283525","types" : [ "postal_code" ]}]';
       String address_cmp_cont ='[{"long_name" : "United States","short_name" : "US","types" : [ "country", "political"]}]';
       String address_cmp_AL1 ='[{"long_name" : "Kentucky","short_name" : "KY","types" : [ "administrative_area_level_1", "political"]}]';
       String address_cmp_AL2 ='[{"long_name" : "Adair County","short_name" : "AC","types" : ["administrative_area_level_2", "political"]}]';
       String address_cmp_loc ='[{"long_name" : "Columbia","short_name" : "Columbia","types" : ["locality", "political"]}]';
       String address_cmp_all= '[{"long_name" : "Columbia","short_name" : "Columbia","types" : [ "locality", "political" ]},{"long_name" : "Adair County","short_name" : "Adair County",                "types" : [ "administrative_area_level_2", "political" ]             },             {                "long_name" : "Kentucky",                "short_name" : "KY",                "types" : [ "administrative_area_level_1", "political" ]             },             { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] },  { "long_name" : "42728", "short_name" : "42728", "types" : [ "postal_code" ] } ]';
       List<SSP_Office__c> sspOfficelist= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_pro);
       List<SSP_Office__c> sspOfficelistcon= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_cont);
       List<SSP_Office__c> sspOfficelistAL1= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_AL1);
       List<SSP_Office__c> sspOfficelistAL2= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_AL2);
       List<SSP_Office__c> sspOfficelistloc= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_loc);
       List<SSP_Office__c> sspOfficelistall= SSP_FindDCBSOfficeController.getOfficeLocations(lat,lang,address_cmp_all);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelist);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelistcon);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelistAL1);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelistAL2);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelistloc);
       System.assertEquals('Adair County DCBS Family Support', 'Adair County DCBS Family Support', sspOfficelistall);
    }
      
    // Test getCurrentAddress and callout               
  class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[{"long_name" : "Columbia","short_name" : "Columbia","types" : [ "locality", "political" ]},{"long_name" : "Adair County","short_name" : "Adair County",                "types" : [ "administrative_area_level_2", "political" ]             },             {                "long_name" : "Kentucky",                "short_name" : "KY",                "types" : [ "administrative_area_level_1", "political" ]             },             { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] },  { "long_name" : "42728", "short_name" : "42728", "types" : [ "postal_code" ] } ]';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
static testMethod void service_call() {
		decimal lat = 37.096467;
        decimal lng= -85.301281;         
        SSP_LightningResponse getAddress = SSP_FindDCBSOfficeController.getCurrentAddress(37.096467,-85.301281);
        String autoCompleteUrl = 'https://maps.googleapis.com/maps/api/geocode/json'; 
        String GOOGLE_API_KEY = 'AIzaSyB2-VuPNWpfJhcXQeq_ueJjZAFjg-k9xJc';
        autoCompleteUrl += '?latlng=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(String.valueOf(37.096467)), 'UTF-8')+','
                                      + EncodingUtil.urlEncode(String.escapeSingleQuotes(String.valueOf(-85.301281)),'UTF-8')
            + '&key=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(GOOGLE_API_KEY), 'UTF-8');
    //'https://maps.googleapis.com/maps/api/geocode/json?latlng=37.096467,-85.301281&%27Key=AIzaSyB2-VuPNWpfJhcXQeq_ueJjZAFjg-k9xJc'
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();

		String response = SSP_SharingBypassFetcher.sendHTTPRequest(autoCompleteUrl);
		system.debug('## response: '+response);
        Test.StopTest();
    	system.debug('## getAddress: '+getAddress);
    }        
    }