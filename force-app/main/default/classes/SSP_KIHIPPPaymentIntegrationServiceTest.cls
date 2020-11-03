/**
 * Class Name    : SSP_KIHIPPPaymentIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 08/01/2020
 * Description   : Test Class for SSP_KIHIPPPaymentIntegrationService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  08/01/2020  Rajeev Kumar    Initial Version
 */
@isTest
public class SSP_KIHIPPPaymentIntegrationServiceTest  {
    @isTest 
    static void handlePositiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME));
        Test.startTest();
        SSP_DataContractOrg.PreferredPaymentIssuanceRequest req = new SSP_DataContractOrg.PreferredPaymentIssuanceRequest();
        req.AccountNumber='1234';
        req.IssuanceMethodCode= 'methodcode';
        req.RoutingNumber= '1234234';
        req.CaseNumber= 1234567; 
        req.PolicyHolderId = 123234; 
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, 1234567);
        objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
        List<Object> lstData = SSP_KIHIPPPaymentIntegrationService.invokeCallout(SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME, objResponse);
        SSP_DataContractOrg.AdhocSFServiceResponse response = (SSP_DataContractOrg.AdhocSFServiceResponse) lstData.get(0);
        System.assertEquals(1,lstData.size(),'Wrong Output'); 
        Test.stopTest();
    }
    @isTest 
    static void testNegetiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(false, SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME));
        Test.startTest();
        SSP_DataContractOrg.PreferredPaymentIssuanceRequest req = new SSP_DataContractOrg.PreferredPaymentIssuanceRequest();
        req.AccountNumber='1234';
        req.IssuanceMethodCode= 'methodcode';
        req.RoutingNumber= '1234234';
        req.CaseNumber= 1234567; 
        req.PolicyHolderId = 123234;       
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER, 1234567);
        List<Object> lstData = SSP_KIHIPPPaymentIntegrationService.invokeCallout(SSP_InterfaceConstants.SSP_KIHIPPPayment_METADATANAME, objResponse);
        SSP_DataContractOrg.AdhocSFServiceResponse response = (SSP_DataContractOrg.AdhocSFServiceResponse) lstData.get(0);
        System.assertEquals(null, response.status,'exception Result');
        Test.stopTest();
    }
    
}