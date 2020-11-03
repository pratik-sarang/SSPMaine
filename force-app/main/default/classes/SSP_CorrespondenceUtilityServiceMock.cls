/**
* Class Name    : SSP_CorrespondenceUtilityServiceMock
* Owner         : DELOITTE
* Created Date  : 01/06/2020
* Description   : Mock class for SSP_CorrespondenceUtilityService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  01/06/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_CorrespondenceUtilityServiceMock implements HttpCalloutMock {
    
    public static final String successbody = '{'+
		'   "ProcessRequestTrigger": "10",'+
		'   "ImproperRequest": "ImproperRequest_0",'+
		'   "GenerateCorrName": "GenerateCorrName_0",'+
		'   "GenerateCorrByteString": "GenerateCorrByteString_0"'+
		'}';
    
    public static final string  successException = '{'+
		'  "AckResponse": {'+
		'    "AckResponseCode": "HBE9000",'+
		'    "AckResponseDescription": "System Exception"'+
		'  }'+
		'}';
    
     protected Integer code;
    protected boolean isscuess;
    public SSP_CorrespondenceUtilityServiceMock(Integer code,boolean isscuess){
        this.code = code;
        this.isscuess = isscuess;
    }
    public HTTPResponse respond(HTTPRequest req) {
        
        // Optionally, only send a mock response for a specific endpoint and method.                             
        HttpResponse res = new HttpResponse();        
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        string body = '';
        if(code == 200 && isscuess){
            body = successbody;
            res.setStatus('Success');
        }
        else if(code ==200 && !isscuess){
            body = successException;
            res.setStatus('Success');
        }
        else if(code ==300 && !isscuess){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Success');
            throw e;
        }
        else{
            body = 'Exception';
        }
        res.setBody(body);        
        res.setStatusCode(code);
        return res;
    }
}