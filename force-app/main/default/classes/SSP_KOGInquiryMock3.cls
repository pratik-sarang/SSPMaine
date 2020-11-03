/**
* Name : KOGInquiryMock
* Description: Mock class to cover the code coverage of class tempuriOrg
* @author 
* @date 
*/
@isTest
global class SSP_KOGInquiryMock3 implements WebServiceMock {
   
      
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
          
         
        tempuriOrg.UserEnrollCheckResponse_element el = new tempuriOrg.UserEnrollCheckResponse_element();
        el.UserEnrollCheckResult=3;
       response.put('response_x', el); 
   }
}