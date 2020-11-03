/*
* Classname     :  SSP_RIDP_CheckResumeMockClass
* @description  :  This class is to mock the response for SSP_RIDP_CheckResumeIntegrationService
* @author       :  Ragunathan
* @date         :  30/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          05/30/2020            Initial Creation
**/
public class SSP_RIDP_CheckResumeMockClass implements WebServiceMock {

    public static final String MESSAGE_DESC = 'Please enter valid values which are pending resume stage.';
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse messageResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse();
            messageResponse.MessageCode = 1234;
            messageResponse.MessageDescription = MESSAGE_DESC;

            List<SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse> messageResponses = new List<SSP_RIDP_DatacontractOrg200407KeupsB.MessageResponse>();
            messageResponses.add(messageResponse);
            SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse arrResponse = new SSP_RIDP_DatacontractOrg200407KeupsB.ArrayOfMessageResponse();
            arrResponse.MessageResponse = messageResponses;
            SSP_RIDP_tempuriOrg.CheckResumeResponse_element chkResumeResponse = new SSP_RIDP_tempuriOrg.CheckResumeResponse_element();
            chkResumeResponse.CheckResumeResult = arrResponse;
            response.put('response_x', chkResumeResponse);
        }
}