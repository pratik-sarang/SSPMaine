/**
* Name : gatewayKOGServiceMock 
* Description: Mock class to cover the code coverage of class tempuriOrg
* @author 
* @date 
*/
@isTest
global class gatewayKOGServiceMock implements WebServiceMock {
   
      
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
          
         
        tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element  el = new tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element();
        el.RoleRequestShortcutResult='contextID';
       response.put('response_x', el); 
   }
}