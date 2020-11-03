/*
* Classname     :  SSP_PreferredMCOSelectionMockClass
* @description  :  This class is to mock the response for SSP_PreferredMCOSelectionService
* @author       :  Ragunathan
* @date         :  08/11/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       			MM/DD/YYYY          A Brief Description about the Change
* Ragunathan					08/11/2020			Initial creation
**/
public class SSP_PreferredMCOSelectionMockClass implements WebServiceMock {
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            
            SSP_DataContractOrg.PreferredMcoResponse objResponse = new SSP_DataContractOrg.PreferredMcoResponse();
            objResponse.IndividualId = 12234555;
            SSP_TempuriOrg.GetPreferredMCOPlanListResponse_element res = new SSP_TempuriOrg.GetPreferredMCOPlanListResponse_element();
            res.GetPreferredMCOPlanListResult = objResponse;
            response.put('response_x',res);
        }
}