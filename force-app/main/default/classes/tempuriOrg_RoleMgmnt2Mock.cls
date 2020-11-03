@isTest
global class tempuriOrg_RoleMgmnt2Mock implements WebServiceMock {
    /*global Boolean isNoMatch=false;
    global Boolean isThrowException=false;*/
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
            List<schemasDatacontractOrg200407_Role.MessageResponse> lstData = new List<schemasDatacontractOrg200407_Role.MessageResponse>();
            schemasDatacontractOrg200407_Role.MessageResponse msgData = new schemasDatacontractOrg200407_Role.MessageResponse();
            msgData.MessageCode = 2;
            msgData.MessageDescription = '';
            lstData.add(msgData);
            schemasDatacontractOrg200407_Role.ArrayOfMessageResponse dataRole = new schemasDatacontractOrg200407_Role.ArrayOfMessageResponse();
            dataRole.MessageResponse = lstData;
            tempuriOrg_RoleMgmnt.RemoveRolesFromUserResponse_element resp = new tempuriOrg_RoleMgmnt.RemoveRolesFromUserResponse_element();
            resp.RemoveRolesFromUserResult = dataRole;
            response.put('response_x',resp); 
        }
}