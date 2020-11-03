/**
* Class Name    : RE_CalloutUtility
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Fetching the logged in community user associated accounts
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  SRIKANTH       Initial Version
*  
**/
public with sharing class RE_CalloutUtility {
    public static HttpResponse oHttpResponse;
    public static String sUniqueId;
    public static Integer iTimeout = 60000;
    public static Map<String,String> mapIntEndpointToDuration;
    public static boolean forMrPortal = False;    
    /********************************************************************************************
    METHOD NAME    : sendRequest
    DESCRIPTION    : This is the overloaded method
    RETURN TYPE    : Map<HttpRequest, HttpResponse>
    PARAMETER      : String, String, String, HttpMethodType
    *********************************************************************************************/
    public static Map<HttpRequest, HttpResponse> sendRequest(String sJsonString,
                        String sEndpoint, String sContentType, 
                        String sHttpMethod, RE_OAuthCalloutUtility oToken) {        
        return sendRequest(sJsonString, sEndpoint, sContentType, sHttpMethod, oToken, null);         
    }
    
    /********************************************************************************************
    METHOD NAME    : sendRequest
    DESCRIPTION    : This method will send HTTP Request to external systems
    RETURN TYPE    : Map<HttpRequest, HttpResponse>
    PARAMETER      : String, String, String, HttpMethodType, ISD_OAuthCalloutUtility, 
             Integration_Endpoints__c
    *********************************************************************************************/
    public static Map<HttpRequest, HttpResponse> sendRequest(String sJsonString,
        String sEndpoint, String sContentType, String sHttpMethod, 
        RE_OAuthCalloutUtility oToken, REIntegrationEndpoints__c oIntEndpoints) {
          
        String sBody = '';
        oHttpResponse = new HttpResponse();

        if (null == mapIntEndpointToDuration) {
            mapIntEndpointToDuration = new Map<String,String>();
        }            
        HttpRequest oHttpRequest = new HttpRequest();
        Map <HttpRequest, HttpResponse> mapToReturn = new Map <HttpRequest,HttpResponse>();
        /* Setting the HTTP method type based static boolean values set from the calling class */           
        oHttpRequest.setMethod(sHttpMethod);
            
        /* Setting the HUB endpoint, content type as JSON, specifying the timeout 
        & setting the Authorization error */ 
        if (!String.isEmpty(sContentType) /*&& !oIntEndpoints.Http_Method_Type__c.equals('GET')*/){
          oHttpRequest.setHeader('Content-Type', sContentType);
        }
        oHttpRequest.setEndpoint(sEndpoint);
        oHttpRequest.setTimeout(iTimeout);
        //resetting to default timeout for further callouts in the transaction
        iTimeout = 60000;
         
          
        /* Replacing null values with empty string based on a static boolean value */
        sBody = sJsonString;
        if (!String.isEmpty(sBody)) {
            oHttpRequest.setBody(sBody);
        }
        
        if(oIntEndpoints!=null && oIntEndpoints.Is_Cert_Required__c){
            oHttpRequest.setClientCertificateName(oIntEndpoints.Certificate_Name__c);
        }
                
        
        
            /* Creating the HTTP object record to make the callout request */       
            Http oHttp = new Http();
            try {
                oHttpResponse = oHttp.Send(oHttpRequest);
            } catch (Exception oEx) {
                
                oHttpResponse.setStatus(oEx.getMessage());
            }
           
        
        
        /*Returning a map of request & response back to the calling class */
        mapToReturn.put(oHttpRequest, oHttpResponse);
        return mapToReturn;        
    }
    
       
}