/**
 * Class Name    : SSP_WDT_GenerateIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 21/04/2020
 * Description   : This class is the unit test for SSP_WDT_GenerateIntegrationService class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  21/04/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_WDT_GenerateIntegrationServiceTest {

    public static testmethod void shouldInvokeCallout() {
        Test.setMock(HttpCalloutMock.class, new SSP_WDT_GenerateIntegrationServiceMock());
        SSP_WDT_ConsumeWrapper.TokenParams param = new SSP_WDT_ConsumeWrapper.TokenParams();
        param.KeyName = 'firstName';
        param.KeyValue = 'firstName';
        SSP_WDT_ConsumeWrapper.TokenAttributes tknAttributes = new SSP_WDT_ConsumeWrapper.TokenAttributes();
        tknAttributes.TokenParams = new List<SSP_WDT_ConsumeWrapper.TokenParams> {param}; 
        SSP_WDT_ConsumeWrapper consumeWrap = new SSP_WDT_ConsumeWrapper();
        consumeWrap.KogId = 'yhhsjsj-fcvbn-hgd';
        consumeWrap.TokenId = 'asdf-fcvbn-hgd';
        consumeWrap.SourceApplication = 'HBETEST';
        consumeWrap.TargetApplication = 'WP_TEST';
        consumeWrap.TokenAttributes = tknAttributes;
        
        SSP_WDT_GenerateResponseWrapper expectedResponse = new SSP_WDT_GenerateResponseWrapper();
        expectedResponse.tokenId = 'abcd1234';
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => prepareRequest()};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Generate, mapParams);
        SSP_WDT_GenerateResponseWrapper response = (SSP_WDT_GenerateResponseWrapper) objList[0];
        System.assertEquals(expectedResponse.tokenId, response.tokenId, 'Verify token id');
    }

    public static testmethod void shouldThrownExceptionWhileInvokeCallout() {
        Test.setMock(HttpCalloutMock.class, new SSP_WDT_GenerateIntegrationServiceErrorMock());
        
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => prepareRequest()};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Generate, mapParams);
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals('SSP_WaiverDataTransferGenerate', logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }

    private static String prepareRequest() {
        SSP_WDT_GenerateWrapper request = new SSP_WDT_GenerateWrapper();
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('CaseNumber', '1234');
        attributeMap.put('IndividualId', '4321123412');
        attributeMap.put('FirstName', 'Test first');
        attributeMap.put('MiddleName', 'T');
        attributeMap.put('LastName', 'Test last');
        
        request.targetApplication = 'SSP';
        request.sourceApplication = 'Waiver';
        request.requestType = 'GenerateToken';
        request.kogId = 'a790788a-734a-4157-b850-c9a96828c3b5';
        request.attributeMap = attributeMap;

        return JSON.serialize(request);
    }

    public class SSP_WDT_GenerateIntegrationServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =   '	{   '+
                                '       "TokenId": "abcd1234"  '+
                                '  } ';
    }

    public class SSP_WDT_GenerateIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}