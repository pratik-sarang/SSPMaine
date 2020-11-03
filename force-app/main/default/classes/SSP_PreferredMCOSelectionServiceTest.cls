/*
* Classname     :  SSP_PreferredMCOSelectionServiceTest
* @description  :  This is a Test class for SSP_PreferredMCOSelectionIntegService
* @author       :  Ragunathan
* @date         :  08/11/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  08/11/2020			Initial creation
**/
@isTest
public class SSP_PreferredMCOSelectionServiceTest {
    @isTest 
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_PreferredMCOSelectionMockClass());
        Test.startTest();
        //Request Details
        SSP_DataContractOrg.RequestMcoAddres requestAddress = new SSP_DataContractOrg.RequestMcoAddres();
		requestAddress.AddressLine1 = 'ydkf';
		requestAddress.AddressLine2 = 'dlkj';
		requestAddress.City = 'frankfort';
		requestAddress.StateCode = 'KY';
		requestAddress.ZipCode4 = '3745';
		requestAddress.CountyCode = '001';
		requestAddress.ZipCode5 = '57464';
		SSP_DataContractOrg.PreferredMcoRequest request = new SSP_DataContractOrg.PreferredMcoRequest();
		request.IndividualId = 919222242;
		request.MCOSelectionRequestDate = System.now();
		request.Address = requestAddress;

		Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => request};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_PREFERRED_MCO_SELECTION, mapParams);
        SSP_DataContractOrg.PreferredMcoResponse response = (SSP_DataContractOrg.PreferredMcoResponse)objList[0];
        System.assertEquals(12234555, response.IndividualId,'Correct Output');
        Test.stopTest();
	}
	
	@isTest 
    static void shouldThrowException() {
        Test.startTest();
        //Request Details
        SSP_DataContractOrg.RequestMcoAddres requestAddress = new SSP_DataContractOrg.RequestMcoAddres();
		requestAddress.AddressLine1 = 'ydkf';
		requestAddress.AddressLine2 = 'dlkj';
		requestAddress.City = 'frankfort';
		requestAddress.StateCode = 'KY';
		requestAddress.ZipCode4 = '3745';
		requestAddress.CountyCode = '001';
		requestAddress.ZipCode5 = '57464';
		SSP_DataContractOrg.PreferredMcoRequest request = new SSP_DataContractOrg.PreferredMcoRequest();
		request.IndividualId = 919222242;
		request.MCOSelectionRequestDate = System.now();
		request.Address = requestAddress;

		Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => request};
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_PREFERRED_MCO_SELECTION, mapParams);
        SSP_DataContractOrg.PreferredMcoResponse response = (SSP_DataContractOrg.PreferredMcoResponse)objList[0];
        System.assertEquals(false, response.Status,'Correct Output');
        Test.stopTest();
    }
}