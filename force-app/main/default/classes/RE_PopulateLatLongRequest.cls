public class RE_PopulateLatLongRequest implements RE_ServiceInterface{
    public static Map<String, Object> execute(Map<String, Object> mapInputData) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_OAuthCalloutUtility oToken=new RE_OAuthCalloutUtility();
        REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('RE_GoogleMapAPI');
        String sJSONRequestBody =oIntEndpoints.Mock_Response_JSON__c;
        String sEndpoint = oIntEndpoints.Endpoint_URI__c	;
        if(mapInputData.get('address')!=null){
            sEndpoint+='address='+mapInputData.get('address')+',&';
        }
        if(mapInputData.get('key')!= null){
            sEndpoint+='key='+mapInputData.get('key');
        }
        String sContentType = oIntEndpoints.Content_Type__c;
        String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
        Map<HttpRequest, HttpResponse> mapResult; 
        String sJSONResponse;
        HttpResponse oHttpResponse; 
        if(!Test.isRunningTest()){
            mapResult = RE_CalloutUtility.sendRequest(sJSONRequestBody, sEndpoint, sContentType, sHttpMethod, oToken);
            oHttpResponse= mapResult.values()[0];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=Kentucky+103Hancock+CountyLewisport42351,&key=AIzaSyBwQAy5ZMxTXt-Wrc64WsdYtxyYs5N1WYs');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
        }else{
            oHttpResponse=RE_GoogleMapAPIMockResponse.respond(new HTTPRequest());
        }
        
        if(oHttpResponse != null && oHttpResponse.getStatusCode() != 200){
            sJSONResponse = RE_GlobalConstants.CLIENT_DETAILS_MOCK_RESPONSE;
        }
        
        
        RE_GoogleMapGeoLocationResponseWrapper wrapper = (RE_GoogleMapGeoLocationResponseWrapper) JSON.deserialize(oHttpResponse.getBody(), RE_GoogleMapGeoLocationResponseWrapper.class);
        RE_GoogleMapGeoLocationResponseWrapper.Results objResponse;
        
        // Force Reviewer Changes - Payal Dubela - 08/27
        if(wrapper != null && wrapper.status == 'OK' && wrapper.status != 'ZERO_RESULTS'){
                
                mapResponse.put(RE_GlobalConstants.RESP_CLIENT_DATA, wrapper);
            }
        return mapResponse; 
        
    }
}