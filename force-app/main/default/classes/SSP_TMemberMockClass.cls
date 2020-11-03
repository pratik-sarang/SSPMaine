/*
* Classname         :  SSP_TMemberMockClass
* @description  :  This class is to mock the response for TMember
* @author       :  Rijia Khatun
* @date         :  19/2/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
public class SSP_TMemberMockClass implements WebServiceMock {
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element res = new SSP_TMemberCalloutClass.SSPDetermineMemberResponse_element();
            SSP_TMemberDataContract.ArrayOfSSPMemberStatus objArrayOfSSP = new SSP_TMemberDataContract.ArrayOfSSPMemberStatus();
            SSP_TMemberDataContract.SSPCaseResponse objRes = new SSP_TMemberDataContract.SSPCaseResponse();
            objRes.CaseNumber = 1;
            objRes.IsSuccess = true;
            objRes.Message = 'Success';
            response.put('response_x',res);
        }
}