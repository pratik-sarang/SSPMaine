/*
* Classname  	:  SSP_SaveWaiverScreeningResultsTest
* @description 	:  This class is the test class of SSP_SaveWaiverScreeningResultsIntService
* @author 		:  Ragunathan
* @date 		:  21/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan		  05/21/2020			Initial Creation
**/
@isTest
public class SSP_SaveWaiverScreeningResultsTest {
    @isTest 
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_SaveWaiverScreeningResultsMockClass());
        Test.startTest();
        //Request Details
        SSP_DatacontractOrg.WaiverScreeningRequestModel request1 = new SSP_DatacontractOrg.WaiverScreeningRequestModel();
        request1.IndividualId = 999034247;
        request1.SelectedABICode = 'Y';
        request1.WaiverScreeningId = 12917;
        request1.RequiresAssistanceCode = 'N';
        request1.IsDependentOnVentilator = 'Y';
        request1.HasIntellectualDisabilityCode = 'N';
        request1.LikeToContinueReceivingServicesCode = 'N';
        
        SSP_DatacontractOrg.WaiverScreeningRequestModel request2 = new SSP_DatacontractOrg.WaiverScreeningRequestModel();
        request2.IndividualId = 999034248;
        request2.SelectedABICode = 'N';
        request2.WaiverScreeningId = 12918;
        request2.RequiresAssistanceCode = 'N';
        request2.IsDependentOnVentilator = 'N';
        request2.HasIntellectualDisabilityCode = 'N';
        request2.LikeToContinueReceivingServicesCode = 'N';
        
        List<SSP_DatacontractOrg.WaiverScreeningRequestModel> requests = new List<SSP_DatacontractOrg.WaiverScreeningRequestModel> {
            	request1,
                request2
                };
		SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel arrRequest = new SSP_DatacontractOrg.ArrayOfWaiverScreeningRequestModel();
        arrRequest.WaiverScreeningRequestModel = requests;
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,arrRequest);
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SAVE_WAIVER_SCREENING_RESULTS, mapParams);
        SSP_DatacontractOrg.WaiverResponse response = (SSP_DatacontractOrg.WaiverResponse)objList[0];
        System.assertEquals(true, response.Status,'Correct Output');
        Test.stopTest();
    }
}