/**
 * Class Name    : SSP_HearingDetailsIntegrationServiceTest
 * Owner         : DELOITTE
 * Created Date  : 05/30/2020
 * Description   : Test Class for SSP_HearingDetailsIntegrationService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/30/2020  Rajeev Kumar    Initial Version
 */
@isTest
public class SSP_HearingDetailsIntegrationServiceTest {
    @isTest 
    static void handlePositiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS));
        Test.startTest();
        String objReq = '12342342';
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objReq);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS, mapParams); 
        SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse response = (SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse)serviceResponses[0];
        //System.assertEquals('P', response.Result,'Correct Output');
        Test.stopTest();
    }
    @isTest 
    static void testNegetiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(false, SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS));
        Test.startTest();
        String objRequest = '1234234';
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.CITIZEN_HEARING_VIEW_DETAILS, mapParams); 
        SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse response = (SSP_HearingDataContractOrg.CitizenHearingViewDetailsResponse)serviceResponses[0];
        //System.assertEquals(null, response.Result,'Error Result');
        Test.stopTest();
    }
    
}