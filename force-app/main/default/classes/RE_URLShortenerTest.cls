@isTest
public class RE_URLShortenerTest {
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"shortUrl": "rebrand.ly/wk5b683"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            res.setStatus('OK');
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
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        REIntegrationEndpoints__c urlIntEndpoints = new REIntegrationEndpoints__c();
        urlIntEndpoints.name='RebrandlyShortURL';
        urlIntEndpoints.Endpoint_URI__c='https://api.rebrandly.com/v1/links';
        urlIntEndpoints.Content_Type__c='application/json';
        urlIntEndpoints.Http_Method_Type__c='POST';
        urlIntEndpoints.Account_API_Key__c='774f8afd8abf4db8879d33b7b8c83855';
        urlIntEndpoints.Domain_Name__c='testdomain/link';
        urlIntEndpoints.Workspace_Id__c='76576vjjbcx6fvbxnbmdnb6tchbc6';
        
        insert urlIntEndpoints;
        test.startTest();
        String shorturl = RE_URLShortener.getShortenedURL('https://www.google.com/','RebrandlyShortURL');
        
        test.stopTest();
        system.assertEquals(String.isBlank(shorturl), False);
    }
    
    @isTest
    public static void testMethod2(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        String shorturl = RE_URLShortener.getShortenedURL('https://www.google.com/','RebrandlyShortURL');
        test.stopTest();
        system.assertEquals(String.isBlank(shorturl), true);
    }
    
    @isTest
    public static void testMethod3(){        
        Test.setMock(HttpCalloutMock.class, new RestMockFail());
        REIntegrationEndpoints__c urlIntEndpoints = new REIntegrationEndpoints__c();
        urlIntEndpoints.name='RebrandlyShortURL';
        urlIntEndpoints.Endpoint_URI__c='https://api.rebrandly.com/v1/links';
        urlIntEndpoints.Content_Type__c='application/json';
        urlIntEndpoints.Http_Method_Type__c='POST';
        urlIntEndpoints.Account_API_Key__c='774f8afd8abf4db8879d33b7b8c83855';
        urlIntEndpoints.Domain_Name__c='testdomain/link';
        urlIntEndpoints.Workspace_Id__c='76576vjjbcx6fvbxnbmdnb6tchbc6';
        insert urlIntEndpoints;
        test.startTest();
        String shorturl = RE_URLShortener.getShortenedURL('https://www.google.com/','RebrandlyShortURL');
        test.stopTest();
        system.assertEquals(String.isBlank(shorturl), true);
    }
    
}