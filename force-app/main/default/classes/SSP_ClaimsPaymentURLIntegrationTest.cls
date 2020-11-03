/**
 * Class Name    : SSP_ClaimsPaymentURLIntegrationTest
 * Owner         : DELOITTE
 * Created Date  : 08/01/2020
 * Description   : This is unit test class for SSP_ClaimsPaymentURLIntegrationService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  08/01/2020  Ragunathan          Initial Version
 */
@isTest(seeAllData=false)
public class SSP_ClaimsPaymentURLIntegrationTest {
    @isTest
    static void shouldInvokeCallout() {
        Map<String, Object> mapInputParams = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsPaymentURLIntegrationMock());
        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPGETURL_METADATANAME, mapInputParams);
        Test.stopTest();
        System.assert(!objList.isEmpty(), 'Check success response');
    }
    @isTest
    static void shouldThrownExceptionWhileInvokeCallout() {
        Map<String, Object> mapInputParams = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsPaymentURLIntegrationErrorMock());
        
        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPGETURL_METADATANAME, mapInputParams);
        Test.stopTest();
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSPGETURL_METADATANAME, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }
    
    public class SSP_ClaimsPaymentURLIntegrationMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =   '   {  '  + 
            '     "AckResponse": {  '  + 
            '       "Success": true,  '  + 
            '       "Error": {} '  + 
            '     }  '  + 
            '  }  ' ; 
    }
    
    public class SSP_ClaimsPaymentURLIntegrationErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}