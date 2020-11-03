global class tempuriOrgGateWayRedirectMock implements WebServiceMock{
    public Boolean isRequestReq=false;
    global void doInvoke(Object stub,
                         Object request,
                         Map<String, Object> response,
                         String endpoint,
                         String soapAction,
                         String requestName,
                         String responseNS,
                         String responseName,
                         String responseType){
                             if(isRequestReq){
                                 tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element response_x= new tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element();
                                 response.put('response_x', response_x);
                             }else{
                             tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element response_x = new tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element();
                             response_x.SaveAddRoleParametersExResult = 'Test1234';
                             response.put('response_x', response_x);
                             }
                             
                         }
    
}