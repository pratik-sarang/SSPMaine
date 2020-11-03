@isTest
public class SSP_FraudSubmission_IntegrationTest {
    @isTest
    static void shouldGetResponse() {
        Test.setMock(HttpCalloutMock.class, new SSP_FraudSubmission_IntegrationServiceMock());
        SSP_ReportFraudRequestWrapper request = new SSP_ReportFraudRequestWrapper();
        request.WhoCommittedFraud = 'B0';
        request.WhatHappened = 'sdfjsdfyu';
        
        SSP_FraudSubmission_ResponseWrapper expectedResponse = new SSP_FraudSubmission_ResponseWrapper();
        SSP_FraudSubmission_ResponseWrapper.AckResponse ack = new SSP_FraudSubmission_ResponseWrapper.AckResponse();
        ack.AckResponseCode			= '0';
        ack.AckResponseDescription	= 'No Desc';
        SSP_FraudSubmission_ResponseWrapper.SubmitFraudResult fraudResult = new SSP_FraudSubmission_ResponseWrapper.SubmitFraudResult();
        fraudResult.FraudReportId = '10';
        fraudResult.ExceptionId   = 'TETS';
        fraudResult.showVerbiage  = true;
        
        expectedResponse.AckResponse = ack;
        expectedResponse.SubmitFraudResult = fraudResult;

        
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_FRAUD_SUBMISSION, mapParams);
        SSP_FraudSubmission_ResponseWrapper response = (SSP_FraudSubmission_ResponseWrapper) objList[0];
        System.assertEquals('10', response.SubmitFraudResult.FraudReportId, 'Success Response');
    }
    
    @isTest
    static void shouldNotGetResponse() {
        Test.setMock(HttpCalloutMock.class, new SSP_FraudSubmission_IntegrationServiceErrorMock());
        SSP_ReportFraudRequestWrapper request = new SSP_ReportFraudRequestWrapper();
        request.WhoCommittedFraud = 'B0';
        request.WhatHappened = 'sdfjsdfyu';
        
        Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_FRAUD_SUBMISSION, mapParams);
        SSP_FraudSubmission_ResponseWrapper response = (SSP_FraudSubmission_ResponseWrapper) objList[0];
        System.assertEquals(null, response.logName, 'Error Response');
    }

    public class SSP_FraudSubmission_IntegrationServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =    '   {  '  + 
                                 '      "SubmitFraudResult": {  '  + 
                                 '         "FraudReportId": "10",  '  + 
                                 '         "ExceptionId": "ExceptionId_0"  '  + 
                                 '      },  '  + 
                                 '      "AckResponse": {  '  + 
                                 '         "AckResponseCode": "AckResponseCode_0",  '  + 
                                 '         "AckResponseDescription": "AckResponseDescription_0"  '  + 
                                 '      }  '  + 
                                 '  }  ' ; 
    }
    
    public class SSP_FraudSubmission_IntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}