public abstract class RestIntegrationService implements IIntegrationService{

     /*
    * Method Name    : sendRequest
    * Description    : This framework method is used to create http request using custim metadata
    * Return Type    : Map<HttpRequest, HttpResponse> 
    * Parameter      : HttpRequest
    */
    public static HttpRequest generateRequest(String interfaceName, Map<String, object> mapInputParams){
        HttpRequest request = new HttpRequest();
        //Instantiate the class with the interface name
        Map<String, SObject> mdtMap = new SSP_CustomMetadataAccessor().getAllRecordsMap(SSP_InterfaceConstants.SSP_INTERFACE_DETAIL_MD);
        SSP_InterfaceDetail__mdt interfaceDetail;
        if(!mdtMap.isEmpty() && mdtMap.get(interfaceName)!=null){
            interfaceDetail = (SSP_InterfaceDetail__mdt)mdtMap.get(interfaceName);
        }
        request.setEndpoint(SSP_InterfaceConstants.SSP_CallOut+interfaceDetail.SSP_NamedCredential__c);
        // Set Method.
        if(interfaceDetail.SSP_Method__c != null) {
            request.setMethod(interfaceDetail.SSP_Method__c);
        }
        //set Headers.
        if(interfaceDetail.header__c != null){
            Map<String, Object> mapHeaders = (Map<String, Object>) JSON.deserializeUntyped(interfaceDetail.header__c);
            for(String skey : mapHeaders.keyset()) {
                request.setHeader(sKey,(String) mapHeaders.get(sKey));
            }
        }
        // Set Body
        if (mapInputParams.containsKey(SSP_InterfaceConstants.JSON_BODY)){
            request.setBody((String)mapInputParams.get(SSP_InterfaceConstants.JSON_BODY));
        }
        // Timeout
        if(interfaceDetail.Timeout_Miliseconds__c != null) {
            request.setTimeout(Integer.valueOf(interfaceDetail.Timeout_Miliseconds__c));
        }
        return request;
    }
    
     /*
    * Method Name    : sendRequest
    * Description    : This method is used to send Http request
    * Return Type    : Map<HttpRequest, HttpResponse> 
    * Parameter      : HttpRequest
    */
    public static HttpResponse sendRequest(HttpRequest request){ 
        // initiate call over HTTP.
        HttpResponse oHttpResponse = new HttpResponse();
        Http oHttp = new Http();
        // Send the request to get the response
        oHttpResponse = oHttp.Send(request);
        return oHttpResponse;   
    }
}