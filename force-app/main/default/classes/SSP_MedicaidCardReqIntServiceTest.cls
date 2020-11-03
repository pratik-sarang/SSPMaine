/**
 * Class Name    : SSP_MedicaidCardReqIntServiceTest
 * Owner         : DELOITTE
 * Created Date  : 05/30/2020
 * Description   : Test Class for SSP_MedicaidCardReqIntService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/30/2020  Rajeev Kumar    Initial Version
 */
@isTest
public class SSP_MedicaidCardReqIntServiceTest  {
    @isTest 
    static void handlePositiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.MEDICAID_CARD_REQUEST));
        Test.startTest();
        SSP_DatacontractOrg.MaidCardRequestModel objRequest = new SSP_DatacontractOrg.MaidCardRequestModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.CaseNumber = 100053289;
        objRequest.Comment = 'Replacing Card 8';
        objRequest.IndividualId = 999018951;
        objRequest.IsRequestedInOffice = 'Y';
        objRequest.SelectedCardReason = 'Requesting another one';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.MEDICAID_CARD_REQUEST, mapParams);
        SSP_DatacontractOrg.AdhocSFServiceResponse response = (SSP_DatacontractOrg.AdhocSFServiceResponse)serviceResponses[0];
        System.assertEquals(true, response.status,'Correct Output');
        Test.stopTest();
    }
    @isTest 
    static void testNegetiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(false, SSP_InterfaceConstants.MEDICAID_CARD_REQUEST));
        Test.startTest();
        SSP_DatacontractOrg.MaidCardRequestModel objRequest = new SSP_DatacontractOrg.MaidCardRequestModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.CaseNumber = 100053289;
        objRequest.Comment = 'Replacing Card 8';
        objRequest.IndividualId = 999018951;
        objRequest.IsRequestedInOffice = 'Y';
        objRequest.SelectedCardReason = 'Requesting another one';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.MEDICAID_CARD_REQUEST, mapParams);  
        SSP_DatacontractOrg.AdhocSFServiceResponse response = (SSP_DatacontractOrg.AdhocSFServiceResponse)serviceResponses[0];
        System.assertEquals(null, response.status,'exception Result');
        Test.stopTest();
    }
    
}