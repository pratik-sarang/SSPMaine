/*
* Classname     :  SSP_SaveWaiverScreeningResultsMockClass
* @description  :  This class is to mock the response for SSP_SaveWaiverScreeningResults
* @author       :  Ragunathan
* @date         :  21/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       			MM/DD/YYYY          A Brief Description about the Change
* Ragunathan					05/21/2020			Initial creation
**/
public class SSP_SaveWaiverScreeningResultsMockClass implements WebServiceMock {
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_tempuriOrg.InsertWaiverScreeningResponse_element res = new SSP_tempuriOrg.InsertWaiverScreeningResponse_element();
            SSP_DataContractOrg.WaiverResponse wResp = new SSP_DataContractOrg.WaiverResponse();
			wResp.Status = true;
			res.InsertWaiverScreeningResult = wResp;
            response.put('response_x',res);
        }
}