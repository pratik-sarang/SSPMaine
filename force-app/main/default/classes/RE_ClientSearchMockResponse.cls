/**
* Class Name    : RE_ClientSearchMockResponse
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/19/2019  Payal Dubela       Initial Version
*  
**/
global class RE_ClientSearchMockResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"indSearchResponse": {"matchResult": "1","memberData": [{"individualId": 920052997,"mciId": 9820373,"firstName": "ashap","lastName": "Ryan","gender": "M","dob": "1957-02-02","PreferredNotificationMethodCode": "Email","Email": "ryan@yahoo.com","phoneNumber": "5555551212"}],"errorData": {"errorCode": "SDH0000","errorDescription": ""}}}');
        res.setStatusCode(200);
        return res;
    }

}