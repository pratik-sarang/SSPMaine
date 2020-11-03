/*
* Classname     :  SSP_SOAPIntegrationServiceMock
* @description  :  This class is to mock the response for SSP_SaveWaiverScreeningResults
* @author       :  Rajeev Kumar
* @date         :  21/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName             MM/DD/YYYY          A Brief Description about the Change
* Rajeev Kumar          05/21/2020      Initial creation
**/
@isTest
public class SSP_SOAPIntegrationServiceMock implements WebServiceMock {
    public Boolean boolIsMockResponseSuccessful;
    public String sInterfaceName;
    
    public SSP_SOAPIntegrationServiceMock(Boolean boolIsMockResponseSuccessful, String sInterfaceName) {
        this.boolIsMockResponseSuccessful  = boolIsMockResponseSuccessful;
        this.sInterfaceName = sInterfaceName;
    }
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
                            String soapAction,String requestName,String responseNS,String responseName,
                            String responseType) {
        if(!boolIsMockResponseSuccessful) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }
        if(sInterfaceName == SSP_InterfaceConstants.DISCONTINUE_BENEFITS) {
            SSP_tempuriOrg.RequestToDiscontinueProgramResponse_element objRes = new SSP_tempuriOrg.RequestToDiscontinueProgramResponse_element();
            SSP_DataContractOrg.AdhocServiceResponse objResp = new SSP_DataContractOrg.AdhocServiceResponse();
            objResp.Result= 'P';
            objRes.RequestToDiscontinueProgramResult = objResp;
            response.put('response_x',objRes);
        } else if(sInterfaceName == SSP_InterfaceConstants.EBT_CARD_REQUEST) {
            SSP_tempuriOrg.SFSubmitEBTRequestResponse_element objRes = new SSP_tempuriOrg.SFSubmitEBTRequestResponse_element();
            SSP_DataContractOrg.AdhocSFServiceResponse objResp = new SSP_DataContractOrg.AdhocSFServiceResponse();
            objResp.status= true;
            objRes.SFSubmitEBTRequestResult = objResp;
            response.put('response_x',objRes);
        } else if(sInterfaceName == SSP_InterfaceConstants.MEDICAID_CARD_REQUEST) {
            SSP_tempuriOrg.SFSubmitMedicaidCardRequestResponse_element objRes = new SSP_tempuriOrg.SFSubmitMedicaidCardRequestResponse_element();
            SSP_DataContractOrg.AdhocSFServiceResponse objResp = new SSP_DataContractOrg.AdhocSFServiceResponse();
            objResp.status= true;
            objRes.SFSubmitMedicaidCardRequestResult = objResp;
            response.put('response_x',objRes);
        } else if(sInterfaceName == SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS) {
            SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse objResp = new SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse();
        } else if(sInterfaceName == SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME) {
            SSP_tempuriOrg.SavePreferredPaymentDetailsResponse_element objRes = new SSP_tempuriOrg.SavePreferredPaymentDetailsResponse_element();
            SSP_DataContractOrg.AdhocSFServiceResponse objResp = new SSP_DataContractOrg.AdhocSFServiceResponse();
            objResp.status= true;
            objRes.SavePreferredPaymentDetailsResult = objResp;
            response.put('response_x',objRes);
        }
    }
}