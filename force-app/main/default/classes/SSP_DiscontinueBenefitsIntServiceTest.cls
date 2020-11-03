/**
 * Class Name    : SSP_DiscontinueBenefitsIntServiceTest
 * Owner         : DELOITTE
 * Created Date  : 05/30/2020
 * Description   : Test Class for SSP_DiscontinueBenefitsIntService
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/30/2020  Rajeev Kumar    Initial Version
 */
@isTest
public class SSP_DiscontinueBenefitsIntServiceTest {
    @isTest 
    static void handlePositiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(true, SSP_InterfaceConstants.DISCONTINUE_BENEFITS));
        Test.startTest();
        SSP_DatacontractOrg.DiscontinueRequestModel objRequest = new SSP_DatacontractOrg.DiscontinueRequestModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.Address = new SSP_DatacontractOrg.AddressToUpdate();
        objRequest.Address.AddressLine1 = 'test address';
        objRequest.Address.AdderssLine2 ='test address';
        objRequest.Address.AddressTypeCode = '';
        objRequest.Address.CertifiedNoStatIndicator = '';
        objRequest.Address.City = '';
        objRequest.Address.CountyCode = '';
        objRequest.Address.MailDeliveryCode = '';
        objRequest.Address.ResidentialDeliveryIndicator = '';
        objRequest.Address.StateCode = '';
        objRequest.Address.VacancyIndicator = '';
        objRequest.Address.ZipCode4 = '';
        objRequest.Address.ZipCode5 = '';
        objRequest.Address.isValidated = '';
        objRequest.CaseNumber = 100010578;
        objRequest.Reason = 'No Reason';
        objRequest.isSFTransaction = true;
        objRequest.IndividualsToDiscontinue = new SSP_DatacontractOrg.ArrayOfDetailsOfIndividualToDiscontinue();
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue =  new List<SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue>();
        SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue objBenfit1 = new SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue();
        obJBenfit1.IndividualId = 1250000215;
        SSP_SerializationArray.ArrayOfstring objArray1 = new SSP_SerializationArray.ArrayOfstring();
        objArray1.string_x = new List<String>{'MA','SN'};
        obJBenfit1.ProgramCodes = objArray1;
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue.add(obJBenfit1);
        SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue objBenfit2 = new SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue();
        obJBenfit2.IndividualId = 1250000214;
        SSP_SerializationArray.ArrayOfstring objArray2 = new SSP_SerializationArray.ArrayOfstring();
        objArray2.string_x = new List<String>{'MA','SN'};
        obJBenfit2.ProgramCodes = objArray2;
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue.add(obJBenfit2);
        
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.DISCONTINUE_BENEFITS, mapParams); 
        SSP_DatacontractOrg.AdhocServiceResponse response = (SSP_DatacontractOrg.AdhocServiceResponse)serviceResponses[0];
        System.assertEquals('P', response.Result,'Correct Output');
        Test.stopTest();
    }
    @isTest 
    static void testNegetiveScenario() {
        Test.setMock(WebServiceMock.class, new SSP_SOAPIntegrationServiceMock(false, SSP_InterfaceConstants.DISCONTINUE_BENEFITS));
        Test.startTest();
        SSP_DatacontractOrg.DiscontinueRequestModel objRequest = new SSP_DatacontractOrg.DiscontinueRequestModel();
        Map<String, Object> mapParams = new Map<String, Object>();
        objRequest.Address = new SSP_DatacontractOrg.AddressToUpdate();
        objRequest.Address.AddressLine1 = 'test address';
        objRequest.Address.AdderssLine2 ='test address';
        objRequest.Address.AddressTypeCode = '';
        objRequest.Address.CertifiedNoStatIndicator = '';
        objRequest.Address.City = '';
        objRequest.Address.CountyCode = '';
        objRequest.Address.MailDeliveryCode = '';
        objRequest.Address.ResidentialDeliveryIndicator = '';
        objRequest.Address.StateCode = '';
        objRequest.Address.VacancyIndicator = '';
        objRequest.Address.ZipCode4 = '';
        objRequest.Address.ZipCode5 = '';
        objRequest.Address.isValidated = '';
        objRequest.CaseNumber = 100010578;
        objRequest.Reason = 'No Reason';
        objRequest.isSFTransaction = true;
        objRequest.IndividualsToDiscontinue = new SSP_DatacontractOrg.ArrayOfDetailsOfIndividualToDiscontinue();
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue =  new List<SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue>();
        SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue objBenfit1 = new SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue();
        obJBenfit1.IndividualId = 1250000215;
        SSP_SerializationArray.ArrayOfstring objArray1 = new SSP_SerializationArray.ArrayOfstring();
        objArray1.string_x = new List<String>{'MA','SN'};
        obJBenfit1.ProgramCodes = objArray1;
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue.add(obJBenfit1);
        SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue objBenfit2 = new SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue();
        obJBenfit2.IndividualId = 1250000214;
        SSP_SerializationArray.ArrayOfstring objArray2 = new SSP_SerializationArray.ArrayOfstring();
        objArray2.string_x = new List<String>{'MA','SN'};
        obJBenfit2.ProgramCodes = objArray2;
        objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue.add(obJBenfit2);
        
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.DISCONTINUE_BENEFITS, mapParams); 
        SSP_DatacontractOrg.AdhocServiceResponse response = (SSP_DatacontractOrg.AdhocServiceResponse)serviceResponses[0];
        System.assertEquals(null, response.Result,'Error Result');
        Test.stopTest();
    }
    
}