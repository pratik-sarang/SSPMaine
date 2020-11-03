@isTest
global class SSP_KOGServiceCreateACRServiceMockTest implements WebServiceMock {
    global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
            SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse response_x = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse();
            response.put('response_x', response_x); 
       }
}