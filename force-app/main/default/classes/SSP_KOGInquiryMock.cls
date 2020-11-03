/**
* Name : KOGInquiryMock
* Description: Mock class to cover the code coverage of class tempuriOrg
* @author 
* @date 
*/
@isTest
global class SSP_KOGInquiryMock implements WebServiceMock {
    
    public boolean isErrorScenario=false;
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
            el.UserEnrollCheckResult=1;
            tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element el1= new tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element();
            el1.RoleRequestShortcutResult='contextId132423535';
            if(requestName=='UserEnrollCheck' || isErrorScenario){
                response.put('response_x', el); 
            }else{
                response.put('response_x', el1); 
            }
            
        }
}