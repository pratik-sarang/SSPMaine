/*
* Classname 		:  SSP_UpdateAgentAssisterMock
* @description 	:  This class is to mock the response for Update agent assister
* @author 		:  Rijia Khatun
* @date 		:  06/24/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/
public class SSP_UpdateAgentAssisterMock implements HttpCalloutMock {
      public Boolean isFailure=true;    
     // Implement this interface method    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.                             
        HttpResponse res = new HttpResponse();
        String body =   '   {  '  + 
             '     "AckResponse": {  '  + 
             '       "Success": false,  '  + 
             '           "Error":   '  + 
             '         {  '  + 
             '           "ErrorCode": "HBE4888",  '  + 
             '           "ErrorDecsription": "SSPDC Failure",  '  + 
             '           "CHFSExceptionId": "CHFS12345678"  '  + 
             '         }  '  + 
             '         '  + 
             '     }  '  + 
             '   }  '  + 
             '    ' ; 
         String body1 =   '   {  '  + 
             '     "AckResponse": {  '  + 
             '       "Success": true,  '  + 
             '           "Error":   '  + 
             '         {  '  + 
             '           "ErrorCode": "HBE4888",  '  + 
             '           "ErrorDecsription": "SSPDC Failure",  '  + 
             '           "CHFSExceptionId": "CHFS12345678"  '  + 
             '         }  '  + 
             '         '  + 
             '     }  '  + 
             '   }  '  + 
             '    ' ; 
        // Create a fake response            
        res.setHeader('Content-Type', 'Text');
        if(isFailure){
            res.setBody(body);
        }else{
              res.setBody(body1);
        }      
        res.setStatusCode(200);
        return res;
    }
}