/**
* Class Name    : RE_MyCartServiceMock
* Owner         : DELOITTE
* Created Date  : 04/24/2020
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/29/2020                 Initial Version
*  
**/
@isTest
global class RE_MyCartServiceMock implements HttpCalloutMock {
	   String locResourceIDs;
       String status;
       String emsg;
        public RE_MyCartServiceMock(String locResourceIDs,String Status,String emsg){
            this.locResourceIDs=locResourceIDs;
            this.status=Status;
            this.emsg=emsg;
        }
    
        global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String sbody='{"user_id": ["00535000001WEnb"],"resourceLocationID": {"resource_location_id":'+locResourceIDs+'},"status": '+status+',"E_message":'+emsg+',"model_version": ["1.0"]}';
        
        res.setBody(sbody);
        res.setStatusCode(200);
        return res;
}
}