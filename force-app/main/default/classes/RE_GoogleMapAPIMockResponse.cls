public  class RE_GoogleMapAPIMockResponse implements HttpCalloutMock{
	// Implement this interface method-
    public static HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"example":"test"}');
        res.setBody('{ "results": [ { "address_components": [ { "long_name": "52726", "short_name": "52726", "types": [ "postal_code" ] }, { "long_name": "Blue Grass", "short_name": "Blue Grass", "types": [ "locality", "political" ] }, { "long_name": "Iowa", "short_name": "IA", "types": [ "administrative_area_level_1", "political" ] }, { "long_name": "United States", "short_name": "US", "types": [ "country", "political" ] } ], "formatted_address": "Blue Grass, IA 52726, USA", "geometry": { "bounds": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } }, "location": { "lat": 41.4986961, "lng": -90.7722974 }, "location_type": "APPROXIMATE", "viewport": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } } }, "place_id": "ChIJ93fcNsbF44cR6AyPC07TrQI", "types": [ "postal_code" ] } ], "status": "OK" }');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}