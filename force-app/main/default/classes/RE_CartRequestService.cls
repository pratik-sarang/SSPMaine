/**
* Class Name    : RE_CartRequestService
* Owner         : DELOITTE
* Created Date  : 04/23/2020
* Description   : 
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     --------------------------------------------------------------------
*  04/23/2020  Srikanth        Initial Version
*  
**/
public with sharing class RE_CartRequestService implements RE_ServiceInterface {
	public static Map<String, Object> execute(Map<String, Object> mapInputData) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_CartResponseWrapper wrapper;
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('Cart_SuggestedForMe');
        
        String sJSONRequestBody = JSON.serialize(mapInputData.get('request'), true);
        String sEndpoint = oIntEndpoints.Endpoint_URI__c	;
        String sContentType = oIntEndpoints.Content_Type__c;
        String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
        Map<HttpRequest, HttpResponse> mapResult = new  Map<HttpRequest, HttpResponse>();
        Long startTime= DateTime.now().getTime();
        mapResult = RE_CalloutUtility.sendRequest(sJSONRequestBody, sEndpoint, sContentType, sHttpMethod, null,oIntEndpoints); 
        String sJSONResponse;
        HttpResponse oHttpResponse = mapResult.values()[0];
        Long EndTime= DateTime.now().getTime();
        Long secondsTaken = (EndTime - startTime)/1000;
        if(secondsTaken > (oIntEndpoints.TimeOut__c == null ? 20 : Long.valueOf(oIntEndpoints.TimeOut__c)) ){
			LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Warning,sEndpoint,'RE_CartRequestService','execute','Long running interface',sHttpMethod,
            sJSONRequestBody,'ERR-999',oHttpResponse.getBody(),secondsTaken*1000,false);
	   }
       if(oHttpResponse != null && oHttpResponse.getStatusCode() == 200){
           wrapper = (RE_CartResponseWrapper) JSON.deserialize(oHttpResponse.getBody(), RE_CartResponseWrapper.class);
           mapResponse.put('response',wrapper);
           mapResponse.put('jsonresponse',oHttpResponse.getBody());
           mapResponse.put('httpstatus',oHttpResponse.getStatusCode());
        }else{ 
            //String mockresponse='{"user_id": ["0033500000DKSKfAAP"],"resourceLocationID": {"resource_location_id": ["a0F35000000cMg5", "a0F35000000cMg4", "a0F35000000cMg3"]},"status": [200],"error_message": [],"model_version": ["1.0"]}}';
            String mockresponse;
            if(oIntEndpoints.Is_Mock_Response_Enabled__c){
                mockresponse = oIntEndpoints.Mock_Response_JSON__c;
                wrapper = (RE_CartResponseWrapper) JSON.deserialize(mockresponse, RE_CartResponseWrapper.class);
                mapResponse.put('response',wrapper);
            }
            //String mockresponse='{"status": ["400"],"emessage":["Invalid Error codes"],"model_version": ["1.0"]}';
            mapResponse.put('error',oHttpResponse.getBody()); 
            mapResponse.put('status',oHttpResponse.getStatusCode());
        }
        return mapResponse;
    }
}