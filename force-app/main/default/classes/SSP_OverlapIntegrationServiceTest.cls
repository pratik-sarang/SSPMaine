/*
* Classname     :  SSP_OverlapIntegrationServiceTest
* @description  :  This class is the test class of SSP_OverlapIntegrationService
* @author       :  Ragunathan
* @date         :  04/02/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_OverlapIntegrationServiceTest {
    @isTest 
    static void shouldGetResponse() { 
        Test.setMock(HttpCalloutMock.class, new SSP_OverlapIntegrationServiceMock()); 
        Test.startTest(); 
         Map<String, Object> objResponse = new Map<String, Object>{
                     'DcId'=> 123,
                     'Identifier'=> 'PREG',
                     'startDate'=> '2020-03-03',
                     'EndDate'=> '2020-09-19',
                     'IndividualId'=> 999017155
                     };
         List<Object> lstReturnedData = IntegrationFactory.invokeCallout(
                                                                SSP_InterfaceConstants.SSPOverlap_METADATANAME, 
                                                                objResponse);
        SSP_OverlapResponseWrapper response = (SSP_OverlapResponseWrapper)lstReturnedData[0];
         System.assertEquals(false, response.IsDateOverLapping,'Correct Output');
         Test.stopTest();         
    }
    
    @isTest 
    static void shouldGetException() { 
        Test.setMock(HttpCalloutMock.class, new SSP_OverlapIntegrationServiceErrorMock());
        Test.startTest(); 
         Map<String, Object> objResponse = new Map<String, Object>{
                     'DcId'=> 123,
                     'Identifier'=> 'PREG',
                     'startDate'=> '2020-03-03',
                     'EndDate'=> '2020-09-19',
                     'IndividualId'=> 999017155
                     };
         List<Object> lstReturnedData = IntegrationFactory.invokeCallout(
                                                                SSP_InterfaceConstants.SSPOverlap_METADATANAME, 
                                                                objResponse);
         LOG_LogMessage__c log = [Select LOG_Source__c from LOG_LogMessage__c where InterfaceName__c =:SSP_InterfaceConstants.SSPOverlap_METADATANAME ];
         System.assertEquals('SSP_OverlapIntegrationService', log.LOG_Source__c,'Correct Output');   
         Test.stopTest();         
    }
    
    public class SSP_OverlapIntegrationServiceMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody  =  '    {   '+
                                '        "IsDateOverLapping": false,   '+
                                '        "IndividualId": 0,   '+
                                '        "EndDate": null,   '+
                                '        "Identifier": null,   '+
                                '        "AckResponse": {   '+
                                '            "AckResponseCode": "HBE9000",   '+
                                '            "AckResponseDescription": "System Exception"   '+
                                '        }   '+
                                '    }   ';
    }
    
    public class SSP_OverlapIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }

}