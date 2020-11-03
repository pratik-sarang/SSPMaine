/**
 * Class Name    : SSP_SendComToMC_GenerateTokenTest
 * Owner         : DELOITTE
 * Created Date  : 24/04/2020
 * Description   : This is unit test class for SSP_SendComToMC_GenerateTokenService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  24/04/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_SendComToMC_GenerateTokenTest {
    @isTest
    static void shouldInvokeCallout() {        
        Map<String, Object> mapParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_GenerateTokenServiceMock());
		Test.startTest();		
		List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_GENERATE_TKN, mapParams);
        Test.stopTest();
        SSP_SendComToMC_ResponseWrapper expectedResponse = new SSP_SendComToMC_ResponseWrapper();
        expectedResponse.access_token = 'token123';
        expectedResponse.error = '';
        expectedResponse.error_uri = '';
        expectedResponse.logName = '';
        expectedResponse.error_description = '';
        SSP_SendComToMC_ResponseWrapper response = (SSP_SendComToMC_ResponseWrapper) slist[0];
        System.assertEquals(response.access_token, expectedResponse.access_token, 'Check success response');
    }
    @isTest
    static void shouldThrownExceptionWhileInvokeCallout() {
        Map<String, Object> mapInputParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_GenerateTokenServiceErrorMock());

        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_GENERATE_TKN, mapInputParams);
        Test.stopTest();
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSP_SENDCOMTOMC_GENERATE_TKN, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }

    private static Map<String, Object> createTestData() {
        SSP_SendComToMC_RequestWrapper request = new SSP_SendComToMC_RequestWrapper();
		request.grant_type = 'client_credentials';
		request.client_id = '4x7cnasa2gg7orzn14ocaqyg';
		request.client_secret = 'zvguWtJYNd6XFgiZ2Vq5u7U1';
		request.account_id = '100026637';

		Map<String,object> mapInputParams = new Map<String,object>();
		mapInputParams.put('body',JSON.serialize(request));

        return mapInputParams;
    }
    public class SSP_SendComToMC_GenerateTokenServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =    '   {  '  + 
								 '     "access_token": "token123"  ' +
								 '  }  ' ;  
    }

    public class SSP_SendComToMC_GenerateTokenServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}