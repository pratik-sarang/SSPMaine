/**
 * Class Name    : SSP_WDT_ConsumeIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 21/04/2020
 * Description   : This class is the unit test for SSP_WDT_ConsumeIntegrationService class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  21/04/2020  Ragunathan          Initial Version
 */
@isTest
public class SSP_WDT_ConsumeIntegrationServiceTest {

    public static testmethod void shouldInvokeCallout() {
        Test.setMock(HttpCalloutMock.class, new SSP_WDT_ConsumeIntegrationServiceMock());

        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => prepareRequest()};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Consume, mapParams);
        SSP_WDT_ConsumeResponseWrapper response = (SSP_WDT_ConsumeResponseWrapper) objList[0];
        System.assertEquals('Waiver', response.SourceApplication, 'Verify Source application from Response');
    }

    public static testmethod void shouldThrownExceptionWhileInvokeCallout() {
        Test.setMock(HttpCalloutMock.class, new SSP_WDT_ConsumeIntegrationServiceErrorMock());
        
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => prepareRequest()};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_WDT_Consume, mapParams);
        LOG_LogMessage__c logMessage = [Select InterfaceName__c, LOG_Debug_Level__c from LOG_LogMessage__c];
        System.assertEquals(SSP_InterfaceConstants.SSP_WDT_Consume, logMessage.InterfaceName__c, 'Verify the error log created for the Interface');
        System.assertEquals('Error', logMessage.LOG_Debug_Level__c, 'Verify the error log created');
    }

    private static String prepareRequest() {
        SSP_WDT_ConsumeRequestWrapper consumeRequest = new SSP_WDT_ConsumeRequestWrapper();
        consumeRequest.tokenId                  = 'abcd1234';
        consumeRequest.requestType              = 'ConsumeToken';
        consumeRequest.currentApplicationName   = 'SSP';

        return JSON.serialize(consumeRequest);
    }
    public class SSP_WDT_ConsumeIntegrationServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =    '   {  '  + 
								 '     "TokenId": "abcd1234",  '  + 
								 '     "KogId": "a790788a-734a-4157-b850-c9a96828c3b5",  '  + 
								 '     "TokenAttributes": {  '  + 
								 '       "TokenParams": [  '  + 
								 '         {  '  + 
								 '           "KeyName": "CaseNumber",  '  + 
								 '           "KeyValue": "1234"  '  + 
								 '         },  '  + 
								 '         {  '  + 
								 '           "KeyName": "IndividualId",  '  + 
								 '           "KeyValue": "4321123412"  '  + 
								 '         },  '  + 
								 '         {  '  + 
								 '           "KeyName": "FirstName",  '  + 
								 '           "KeyValue": "FirstName"  '  + 
								 '         },  '  + 
								 '         {  '  + 
								 '           "KeyName": "MiddleName",  '  + 
								 '           "KeyValue": "MiddleName"  '  + 
								 '         },  '  + 
								 '         {  '  + 
								 '           "KeyName": "LastName",  '  + 
								 '           "KeyValue": "Last Name"  '  + 
								 '         }  '  + 
								 '       ]  '  + 
								 '     },  '  + 
								 '     "SourceApplication": "Waiver",  '  + 
								 '     "TargetApplication": "SSP"  '  + 
								 '  }  ' ;
    }

    public class SSP_WDT_ConsumeIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}