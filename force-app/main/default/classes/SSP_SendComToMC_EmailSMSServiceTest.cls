/**
 * Class Name    : SSP_SendComToMC_EmailSMSServiceTest
 * Owner         : DELOITTE
 * Created Date  : 24/04/2020
 * Description   : This is unit test class for SSP_SendComToMC_EmailSMSService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  24/04/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_SendComToMC_EmailSMSServiceTest {
    @isTest
    static void shouldInvokeCallout() {        
        Map<String, Object> mapParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_EmailSMSServiceMock());
		Test.startTest();		
		List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_EMAIL, mapParams);
        Test.stopTest();
    }
    @isTest
    static void shouldThrownExceptionWhileInvokeCallout() {
        Map<String, Object> mapInputParams = createTestData();
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_EmailSMSServiceErrorMock());

        Test.startTest();
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_EMAIL, mapInputParams);
        Test.stopTest();
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSP_SENDCOMTOMC_EMAIL, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }

    private static Map<String, Object> createTestData() {
		Map<String,object> mapInputParams = new Map<String,object>();
		mapInputParams.put('body',JSON.serialize('request'));

        return mapInputParams;
    }
    public class SSP_SendComToMC_EmailSMSServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =    '   { } ';  
    }

    public class SSP_SendComToMC_EmailSMSServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}