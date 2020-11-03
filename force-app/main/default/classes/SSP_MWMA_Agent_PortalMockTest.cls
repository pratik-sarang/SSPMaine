@isTest
global class SSP_MWMA_Agent_PortalMockTest implements WebServiceMock {
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
        SSP_MWMA_Agent_Portal.responseWrapper response_x = new SSP_MWMA_Agent_Portal.responseWrapper();
        response.put('response_x', response_x); 
   }
}