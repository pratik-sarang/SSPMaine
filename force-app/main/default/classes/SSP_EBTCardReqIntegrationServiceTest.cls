/**
 * Class Name    : SSP_EBTCardReqIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 05/30/2020
 * Description   : Test Class for SSP_EBTCardReqIntegrationService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/30/2020  Rajeev Kumar    Initial Version
 */
@isTest
public class SSP_EBTCardReqIntegrationServiceTest {
    @isTest 
    static void handlePositiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.EBT_CARD_REQUEST));
        Test.startTest();
        SSP_DatacontractOrg.CardDetailsModel objRequest = new SSP_DatacontractOrg.CardDetailsModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.CardStatus = 'RR';
        objRequest.CardStatusDate = null;
        objRequest.Comment = 'My New Ebt card request 10';
        objRequest.CountyCode = '001';
        objRequest.EBTCaseNumber = 100048302;
        objRequest.IndividualId = 100048302;
        objRequest.IsRequestedInOffice = 'N';
        objRequest.mode = 'New';
        objRequest.SelectedCardReason = 'CardReason';
        objRequest.WorkerIdRequest = 'test@dfke.de';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.EBT_CARD_REQUEST, mapParams);
        SSP_DatacontractOrg.AdhocSFServiceResponse response = (SSP_DatacontractOrg.AdhocSFServiceResponse)serviceResponses[0]; 
        System.assertEquals(true, response.status,'Correct Output');
        Test.stopTest();
    }
    @isTest 
    static void testNegetiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(false, SSP_InterfaceConstants.EBT_CARD_REQUEST));
        Test.startTest();
        SSP_DatacontractOrg.CardDetailsModel objRequest = new SSP_DatacontractOrg.CardDetailsModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.CardStatus = 'RR';
        objRequest.CardStatusDate = null;
        objRequest.Comment = 'My New Ebt card request 10';
        objRequest.CountyCode = '001';
        objRequest.EBTCaseNumber = 100048302;
        objRequest.IndividualId = 100048302;
        objRequest.IsRequestedInOffice = 'N';
        objRequest.mode = 'New';
        objRequest.SelectedCardReason = 'CardReason';
        objRequest.WorkerIdRequest = 'test@dfke.de';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.EBT_CARD_REQUEST, mapParams);
        SSP_DatacontractOrg.AdhocSFServiceResponse response = (SSP_DatacontractOrg.AdhocSFServiceResponse)serviceResponses[0]; 
        System.assertEquals(null, response.status,'Exception Status');
        Test.stopTest();
    }
    
}