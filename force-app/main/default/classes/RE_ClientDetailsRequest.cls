/**
* Class Name    : RE_ClientDetailsRequest
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/06/2019  Suyash       Initial Version
*  04/29/2020  Srikanth     Long Run Interface Log Message Creation
**/

public with sharing class RE_ClientDetailsRequest implements RE_ServiceInterface{
    
   public static Map<String, Object> execute(Map<String, Object> mapInputData) {
   	
       Map<String, Object> mapResponse = new Map<String, Object>();
       
       REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('IEESClientDetails');
       String sJSONRequestBody ='';
       String sEndpoint = oIntEndpoints.Endpoint_URI__c	;
       Map<String,String> requestBody=new Map<String,String>();
       if(mapInputData.containsKey('individualId')){
          requestBody.put('individualId',String.valueof(mapInputData.get('individualId')));
          sJSONRequestBody=JSON.serialize(requestBody);
       }
       String sContentType = oIntEndpoints.Content_Type__c;
       String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
       Re_ClientViewWrapper wrapper ;
       Map<HttpRequest, HttpResponse> mapResult = new Map<HttpRequest, HttpResponse>();
       Long startTime= DateTime.now().getTime();
       mapResult = RE_CalloutUtility.sendRequest(sJSONRequestBody, sEndpoint, sContentType, sHttpMethod, null,oIntEndpoints); 
       Long EndTime= DateTime.now().getTime();
       Long secondsTaken = (EndTime - startTime)/1000;
       String sJSONResponse;
       HttpResponse oHttpResponse = mapResult.values()[0];
	   if(secondsTaken > (oIntEndpoints.TimeOut__c == null ? 20 : Long.valueOf(oIntEndpoints.TimeOut__c)) ){
      LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Warning,sEndpoint,'Re_ClientDetailsRequest','execute','Long running interface',sHttpMethod,
        sJSONRequestBody,'ERR-999',oHttpResponse.getBody(),secondsTaken*1000,false);
	   }
       

       if(oHttpResponse != null && oHttpResponse.getStatusCode() == 200){
           sJSONResponse = oHttpResponse.getBody(); 
           wrapper=(Re_ClientViewWrapper) JSON.deserialize(sJSONResponse, Re_ClientViewWrapper.class);
       }else{
              mapResponse.put('Error',oHttpResponse.getBody()); 
              LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'Re_ClientDetailsRequest','execute','Callout to Case Detail Failed',sHttpMethod,
             mapInputData.containsKey('individualId')?sJSONRequestBody:'Individual ID missing',String.valueof(oHttpResponse.getStatusCode()),oHttpResponse.getBody(),DateTime.now().getTime()-startTime,false);
       }
       if(wrapper != null ){
               mapResponse.put(RE_GlobalConstants.RESP_CLIENT_DATA, wrapper); 
       }

       return mapResponse; 
   
   }

}