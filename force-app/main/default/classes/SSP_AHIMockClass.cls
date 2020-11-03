/*
* Classname 		:  SSP_VLPMockClass
* @description 	:  This class is to mock the response for AHI
* @author 		:  Rijia Khatun
* @date 		:  02/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_AHIMockClass implements HttpCalloutMock {
    
    // Implement this interface method    
    public HTTPResponse respond(HTTPRequest req) {    
        SSP_AHIRequestWrapper objReq = new SSP_AHIRequestWrapper();
        objReq.RequestId = '100026229';
        HttpResponse res = new HttpResponse();
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        res.setStatusCode(200);
        return res;
    }
}