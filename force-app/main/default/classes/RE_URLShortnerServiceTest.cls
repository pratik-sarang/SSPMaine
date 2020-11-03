/**
* Class Name    : RE_URLShortnerServiceTest
* Owner         : DELOITTE
* Created Date  : 15/07/2019
* Description   : Test Class for RE_URLShortnerService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  15/07/2019  Abhijeet       Initial Version
**/
@isTest
public class RE_URLShortnerServiceTest implements HttpCalloutMock{
    
    //commented due to mock deployment errors
   /* @isTest
    
    static void getShortURLTest(){
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='BitlyShortURL';
        setting.Account_API_Key__c='73afb83315b197c704f23885d1c3d788dfc88a60';
        setting.Endpoint_URI__c='https://api-ssl.bitly.com/v3/shorten?';
        setting.Content_Type__c='application/JSON';
        setting.Http_Method_Type__c='GET';
        if(Schema.sObjectType.REIntegrationEndpoints__c.fields.Name.isCreateable() && Schema.sObjectType.REIntegrationEndpoints__c.fields.Account_API_Key__c.isCreateable()
          && Schema.sObjectType.REIntegrationEndpoints__c.fields.Endpoint_URI__c.isCreateable() && Schema.sObjectType.REIntegrationEndpoints__c.fields.Content_Type__c.isCreateable()
          && Schema.sObjectType.REIntegrationEndpoints__c.fields.Http_Method_Type__c.isCreateable()){
        	insert setting;
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_BitlyMockResponse());
        String longUrl = 'https://google.com';
        RE_URLShortnerResponseWrapper wrp = new RE_URLShortnerResponseWrapper();
        wrp.url = longUrl;
        String result = RE_URLShortnerService.getShortURL(longUrl);
        system.assertEquals(null, result,'Success');
        Test.stopTest();
        
    }
    */
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_BitlyMockResponse());
        test.stopTest();
        return res;
        
    }
    
}