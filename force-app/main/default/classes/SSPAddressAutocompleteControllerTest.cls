@isTest(seeAllData=false)
public class SSPAddressAutocompleteControllerTest {

    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public Boolean isAutoCompleteLWC=false;
        public Boolean isErrorScenario=false;
        public HTTPResponse respond(HTTPRequest req) 
        {   
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(isAutoCompleteLWC){
                res.setBody('{"predictions" : [{"description" : "Deloitte, Off Old Airport Road, Yemlur, Yemlur Post, Bangalore, Karnataka, India","matched_substrings" : [{"length" : 8,"offset" : 0},{"length" : 9,"offset" : 53}],"place_id" : "ChIJF9VSwLcTrjsRCBekedHaAKs","reference" : "ChIJF9VSwLcTrjsRCBekedHaAKs","structured_formatting" : {"main_text" : "Deloitte","main_text_matched_substrings" : [{"length" : 8,"offset" : 0}],"secondary_text" : "Off Old Airport Road, Yemlur, Yemlur Post, Bangalore, Karnataka, India","secondary_text_matched_substrings" : [{"length" : 9,"offset" : 43}]},"terms" : [{"offset" : 0,"value" : "Deloitte"},{"offset" : 10,"value" : "Off Old Airport Road"},{ "offset" : 32, "value" : "Yemlur"},{"offset" : 40,"value" : "Yemlur Post"},{"offset" : 53,"value" : "Bangalore"},{"offset" : 64,"value" : "Karnataka"},{"offset" : 75,"value" : "India"}],"types" : [ "point_of_interest", "establishment" ]}],"status" : "OK"}');
            }else if(isErrorScenario){
                res.setBody('{"predictions" : [{"description" : "Deloitte, Off Old Airport Road, Yemlur, Yemlur Post, Bangalore, Karnataka, India","matched_substrings" : [{"length" : 8,"offset" : 0},{"length" : 9,"offset" : 53}],"place_id" : "ChIJF9VSwLcTrjsRCBekedHaAKs","reference" : "ChIJF9VSwLcTrjsRCBekedHaAKs","structured_formatting" : {"main_text" : "Deloitte","main_text_matched_substrings" : [{"length" : 8,"offset" : 0}],"secondary_text" : "Off Old Airport Road, Yemlur, Yemlur Post, Bangalore, Karnataka, India","secondary_text_matched_substrings" : [{"length" : 9,"offset" : 43}]},"terms" : [{"offset" : 0,"value" : "Deloitte"},{"offset" : 10,"value" : "Off Old Airport Road"},{ "offset" : 32, "value" : "Yemlur"},{"offset" : 40,"value" : "Yemlur Post"},{"offset" : 53,"value" : "Bangalore"},{"offset" : 64,"value" : "Karnataka"},{"offset" : 75,"value" : "India"}],"types" : [ "point_of_interest", "establishment" ]},"status" : "OK"}');
            }
            else{
                res.setBody('{ "results" : [{ "geometry" : { "location" : {"lat" : 37.7787937,"lng" : -122.4216864} } }], "result" :  { "address_components" : [ { "long_name" : "404", "short_name" : "404", "types" : [ "street_number" ] }, { "long_name" : "Frankfort Avenue", "short_name" : "Frankfort Ave", "types" : [ "route" ] }, { "long_name" : "Butchertown", "short_name" : "Butchertown", "types" : [ "neighborhood", "political" ] }, { "long_name" : "Louisville", "short_name" : "Louisville", "types" : [ "locality", "political" ] }, { "long_name" : "Jefferson County", "short_name" : "Jefferson County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Kentucky", "short_name" : "KY", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "40206", "short_name" : "40206", "types" : [ "postal_code" ] } ], "formatted_address" : "404 Frankfort Ave, Louisville, KY 40206, USA", "geometry" : { "location" : { "lat" : 38.2644825, "lng" : -85.72534570000001 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : 38.2658314802915, "lng" : -85.72399671970851 }, "southwest" : { "lat" : 38.2631335197085, "lng" : -85.72669468029152 } } }, "partial_match" : true, "place_id" : "", "types" : [ "street_address" ] } , "status" : "OK" }');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void detaSetup() {
        insert new GoogleMapsApiConfig__c(
            AutoCompleteUrl__c = 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
            PlaceDetailUrl__c = 'https://maps.googleapis.com/maps/api/place/details/json',
            Location__c = '0,0',
            Radius__c = 1000.0,
            Key__c = 'XXXX',
            API_Key_DCBS__c='12dfjhhbghdkbx44345'
        );
    }

    @isTest
    public static void unitTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String suggestionString = SSPAddressAutocompleteController.getAddressAutoComplete('Deloitte, Bangalore');
        System.assert(suggestionString != null);
        try{
            suggestionString = SSPAddressAutocompleteController.getAddressAutoComplete('');
        }catch(Exception e){

        }
        System.assert(suggestionString != null);
        Test.stopTest();
    }

    @isTest
    public static void unitTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String placeDetailString = SSPAddressAutocompleteController.getPlaceDetail('some-place-id');
        String placeDetailDCBsStr = SSPAddressAutocompleteController.getPlaceDetailDCBS('some-place-id');
     	SSPAddressAutocompleteController.predictionWrapper pred = new SSPAddressAutocompleteController.predictionWrapper();
        pred.description = 'testing';
        pred.place_id = 'somethign';
     //   SSPAddressAutocompleteController.placeObjectWrapper placObj = new SSPAddressAutocompleteController.placeObjectWrapper(Map<String, Object> res );
        
       /* SSPAddressAutocompleteController.responseWrapper();
            SSPAddressAutocompleteController.placeObjectWrapper();
            SSPAddressAutocompleteController.placeWrapper();
            SSPAddressAutocompleteController.placeResultWrapper();
            SSPAddressAutocompleteController.address_componentsWrapper(); */
        System.assert(placeDetailString != null);
        
        placeDetailString = SSPAddressAutocompleteController.getPlaceDetail(null);
        System.assert(placeDetailString != null);
        Test.stopTest();
    }
    @isTest
    public static void unitTest3() {
        Test.startTest();
        MockHttpResponseGenerator mockClass= new MockHttpResponseGenerator();
        mockClass.isAutoCompleteLWC=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
        String suggestionString = SSPAddressAutocompleteController.getAddressAutoCompleteLWC('Deloitte, Bangalore');
        System.assert(suggestionString != null);
        try{
            suggestionString = SSPAddressAutocompleteController.getAddressAutoCompleteLWC('');
        }catch(Exception e){

        }
        System.assert(suggestionString != null);
        SSPAddressAutocompleteController.getAddressAutoComplete('Deloitte, Bangalore');
        Test.stopTest();
    }
    @isTest
    public static void unitTest4() {
        Test.startTest();
        MockHttpResponseGenerator mockClass= new MockHttpResponseGenerator();
        mockClass.isErrorScenario=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
        String suggestionString = SSPAddressAutocompleteController.getAddressAutoCompleteLWC('Deloitte, Bangalore');
        Test.stopTest();
    }


    
}