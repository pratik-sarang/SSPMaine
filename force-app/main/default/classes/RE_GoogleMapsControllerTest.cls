@isTest
public class RE_GoogleMapsControllerTest {
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'test';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockFail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'test';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'XXXXX');
            res.setBody(fullJson);
            res.setStatusCode(400);
            return res;
        }
    }
    
    @isTest
    public static void testMethod1(){
        //RE_GoogleMapsController testGoogleMaps = new RE_GoogleMapsController();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        String addressInput = RE_GoogleMapsController.getAddressAutoComplete('234');
        RE_GoogleMapsController.getGoogleMapsAPIKey();
        RE_GoogleMapsController.getHttp('www.google.com');
        test.stopTest();
        system.assertEquals(String.isBlank(addressInput), False);
    }
    @isTest
    public static void testMethodfail(){
        //RE_GoogleMapsController testGoogleMaps = new RE_GoogleMapsController();
        Test.setMock(HttpCalloutMock.class, new RestMockFail());
        test.startTest();
        String addressInput = RE_GoogleMapsController.getAddressAutoComplete('');
        RE_GoogleMapsController.getGoogleMapsAPIKey();
        RE_GoogleMapsController.getHttp('');
        test.stopTest();
        system.assertEquals(String.isBlank(addressInput), False);
    }
}