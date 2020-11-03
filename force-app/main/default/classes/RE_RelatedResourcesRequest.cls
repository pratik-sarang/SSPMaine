/**
* Class Name    : RE_RelatedResourcesRequest
* Owner         : DELOITTE
* Created Date  : 04/20/2020
* Description   : 
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     --------------------------------------------------------------------
*  04/20/2020  Payal       Initial Version
*  
**/
public with sharing class RE_RelatedResourcesRequest implements RE_ServiceInterface{
    public static Map<String, Object> execute(Map<String, Object> mapInputData) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_ResourceResponseWrapper wrapper;

        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('RelatedResources');
        String sJSONRequestBody = JSON.serialize(mapInputData.get('request'), true);
        //String sJSONRequestBody='{"user_id":"99999999999","LATITUDE":"37.9886892","LONGITUDE":"-84.4777153","taxonomy_id":"a0Q350000017dRbEAI","resource_id":"a0Q350000017ct5EAA"}';
        String sEndpoint = oIntEndpoints.Endpoint_URI__c	;
        String sContentType = oIntEndpoints.Content_Type__c;
        String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
        Map<HttpRequest, HttpResponse> mapResult = new  Map<HttpRequest, HttpResponse>();
        Long startTime= DateTime.now().getTime();
        mapResult = RE_CalloutUtility.sendRequest(sJSONRequestBody, sEndpoint, sContentType, sHttpMethod, null,oIntEndpoints); 
        String sJSONResponse;
        HttpResponse oHttpResponse = mapResult.values()[0];
        Long EndTime= DateTime.now().getTime();
        Long secondsTaken = (startTime - EndTime)/1000;
        if(secondsTaken > (Long.valueOf(oIntEndpoints.TimeOut__c) == null ? 20 : Long.valueOf(oIntEndpoints.TimeOut__c)) ){
			LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'RE_RelatedResourcesRequest','execute','Long running interface',sHttpMethod,
             '','ERR-999',oHttpResponse.getBody(),EndTime,false);
       }
       if(oHttpResponse != null && oHttpResponse.getStatusCode() == 200){
          //String mocresponse='{"user_id":["999999999999999999"],"complementary_resource":{"resource_location_id":["a0F35000000cMg5","a0F35000000cMg4","a0F35000000cMg3","a0F35000000cMg2","a0F35000000cMg1","a0F35000000cMg0","a0F35000000dRIK","a0F35000000dR7G","a0F35000000dQpY"]},"similar_resource":{"resource_location_id":["a0F35000000dF81","a0F35000000dF7w","a0F35000000d5El","a0F35000000d5EL","a0F35000000d5Ek","a0F35000000d5EK"]},"E_message":[""],"status":[200],"model_version":["1.0"]}';  
          wrapper = (RE_ResourceResponseWrapper) JSON.deserialize(oHttpResponse.getBody(), RE_ResourceResponseWrapper.class);
          mapResponse.put('response',wrapper);
          mapResponse.put('jsonresponse',oHttpResponse.getBody());
          mapResponse.put('httpstatus',oHttpResponse.getStatusCode());
        }else{
            //String mockresponse='{"user_id": ["00535000001PntP"],"complementary_resource": {"resource_location_id": ["a0F35000000cMg5","a0F35000000cMg4","a0F35000000cMg3","a0F35000000cMg2","a0F35000000cMg1","a0F35000000cMg0","a0F35000000dRIK","a0F35000000dR7G","a0F35000000dQpY"]},"similar_resource": {"resource_location_id": ["a0F35000000dF81","a0F35000000dF7w","a0F35000000d5El","a0F35000000d5EL","a0F35000000d5Ek","a0F35000000d5EK"]},"status": [200],"E_message":[""],"model_version": ["1.0"]}';
            //Test Status not 200 
            // String mockresponse='{"user_id": ["0033500000G8sw9AA"],"complementary_resource": {"resource_location_id":[]},"similar_resource": [""],"E_message": ["user_id must have 18 characters"],"status": [400],"model_version": ["1.0"]}';
            //wrapper = (RE_ResourceResponseWrapper) JSON.deserialize(mockresponse, RE_ResourceResponseWrapper.class);
            //Test http connection failure
            mapResponse.put('error',oHttpResponse.getBody()); 
            mapResponse.put('status',oHttpResponse.getStatusCode());
        }
    return mapResponse; 
    }

}