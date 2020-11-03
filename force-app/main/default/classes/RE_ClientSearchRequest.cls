/**
* Class Name    : RE_ClientSearchRequest
* Owner         : DELOITTE
* Created Date  : 10/22/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  10/22/2019  Payal Dubela       Initial Version
*  04/29/2020  Srikanth     Long Run Interface Log Message Creation
**/
public with sharing class RE_ClientSearchRequest implements RE_ServiceInterface{
    
    public static Map<String, Object> execute(Map<String, Object> mapInputData) {
        
        Map<String, Object> mapResponse = new Map<String, Object>();
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('ClientSearch');
        String sJSONRequestBody = JSON.serialize(mapInputData.get('request'), true);
        String sEndpoint = oIntEndpoints.Endpoint_URI__c	;
        String sContentType = oIntEndpoints.Content_Type__c;
        String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
        
        Map<HttpRequest, HttpResponse> mapResult = new  Map<HttpRequest, HttpResponse>();
        Long startTime= DateTime.now().getTime();
        mapResult = RE_CalloutUtility.sendRequest(sJSONRequestBody, sEndpoint, sContentType, sHttpMethod, null,oIntEndpoints); 
        Long EndTime= DateTime.now().getTime();
        Long secondsTaken = (EndTime - startTime)/1000;
        String sJSONResponse;
        HttpResponse oHttpResponse = mapResult.values()[0];
        if(secondsTaken > (oIntEndpoints.TimeOut__c == null ? 20 : Long.valueOf(oIntEndpoints.TimeOut__c)) ){
			LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Warning,sEndpoint,'RE_ClientSearchRequest','execute','Long running interface',sHttpMethod,
            sJSONRequestBody,'ERR-999',oHttpResponse.getBody(),secondsTaken*1000,false);
	   }
        if(oHttpResponse != null && oHttpResponse.getStatusCode() == 200){
            sJSONResponse=oHttpResponse.getBody();
            RE_ClientSearchResponse wrapper = (RE_ClientSearchResponse) JSON.deserialize(sJSONResponse, RE_ClientSearchResponse.class);
            if(wrapper.indSearchResponse != null ){
                mapResponse.put('ClientSearch', wrapper);
            }
            
        }else{
            mapResponse.put('Error',oHttpResponse.getBody()); 
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'RE_ClientSearchRequest','execute','Callout to Client Search Failed',sHttpMethod,sJSONRequestBody,String.valueof(oHttpResponse.getStatusCode()),oHttpResponse.getBody(),DateTime.now().getTime()-startTime,true);
        }
        return mapResponse; 
        
        
    }
}