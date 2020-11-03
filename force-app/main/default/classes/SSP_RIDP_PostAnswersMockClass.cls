/*
* Classname 	:  SSP_RIDP_PostAnswersMockClass
* @description 	:  This is mock class for SSP_RIDP_PostAnswersIntegrationService
* @author 		:  Ragunathan
* @date 		:  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
public class SSP_RIDP_PostAnswersMockClass implements WebServiceMock {

    public static final String MESSAGE_DESC = 'Identity proofing request Successful.';
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse messageResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse();
            messageResponse.MessageCode = 0;
            messageResponse.MessageDescription = MESSAGE_DESC + 'reference number';

            List<SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse> messageResponses = new List<SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse>();
            messageResponses.add(messageResponse);
            SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse arrResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse();
            arrResponse.MessageResponse = messageResponses;
            SSP_RIDP_tempuriOrg.PostAnswersResponse_element postAnwsersResponse = new SSP_RIDP_tempuriOrg.PostAnswersResponse_element();
            postAnwsersResponse.PostAnswersResult = arrResponse;
            response.put('response_x', postAnwsersResponse);
        }
}