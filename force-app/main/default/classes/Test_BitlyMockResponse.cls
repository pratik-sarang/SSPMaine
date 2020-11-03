/**
* Class Name    : Test_BitlyMockResponse
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : Mock response class for RE_URLShortnerService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/31/2019  Lagan Kankane       Initial Version
*  
**/
global class Test_BitlyMockResponse implements HttpCalloutMock{
    
        global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

}