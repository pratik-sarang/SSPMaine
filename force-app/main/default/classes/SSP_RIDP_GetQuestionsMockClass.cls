/*
* Classname     :  SSP_RIDP_GetQuestionsMockClass
* @description  :  This class is to mock the response for SSP_RIDP_GetQuestionsIntegrationService
* @author       :  Ragunathan
* @date         :  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
public class SSP_RIDP_GetQuestionsMockClass implements WebServiceMock {

    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse serviceResponse = new SSP_RIDP_DatacontractOrg200407Kogserv.RIDPServiceResponse();
			serviceResponse.SessionID = 'AXBYCZD-EFGHIJ-KLM-NOP';
            SSP_RIDP_tempuriOrg.GetQuestionsResponse_element getQuestionResponse = new SSP_RIDP_tempuriOrg.GetQuestionsResponse_element();
            getQuestionResponse.GetQuestionsResult = serviceResponse;
            response.put('response_x', getQuestionResponse);
        }
}