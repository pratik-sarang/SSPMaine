/*
* Classname 	:  SSP_MCIForBenefitIntegrationServiceTest
* @description 	:  This class is the test class of SSP_MCIForBenefitIntegrationService
* @author 		:  Ragunathan
* @date 		:  26/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
* Ragunathan          26/06/2020            Initial Creation
**/
@isTest
public class SSP_MCIForBenefitIntegrationServiceTest {
    @isTest
    static void shouldGetResponse() {
        Test.setMock(WebServiceMock.class, new SSP_MCIForBenefitMockClass()); 
        //Contact test data
        Contact con = new Contact(
            firstName = 'Test',
            lastName = 'User',
            birthdate = Date.newInstance(1992, 12, 12),
            ssn__c = '12345678',
            Gender__c = 'Male'
        );

        SSP_MCIForBenefitRequestWrapper mciRequest = new SSP_MCIForBenefitRequestWrapper();
        mciRequest.con = con;
        
        Map<String, Object> mapInputParams = new Map<String, Object>();
        mapInputParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(mciRequest));
        Test.startTest();
        List<object> slist = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_MCI_SERVICE_FOR_BENEFIT, mapInputParams);
        Test.stopTest();
        AsyncKyHbeMci asyncMCI = new AsyncKyHbeMci();
        AsyncKyHbeMci.EntityMciSearchResponse_elementFuture eleFuture = new AsyncKyHbeMci.EntityMciSearchResponse_elementFuture();
        //eleFuture.getValue();
        Continuation cont = new Continuation(40);
        kyHbeMciDatacontracts.MciEntitySearchRequest req = new kyHbeMciDatacontracts.MciEntitySearchRequest();
        req.SourceSystemName    = 'HBE';
        req.FirstName           = 'Test Name';
        req.LastName            = 'Last one';
        req.Dob                 = Date.newInstance(1999, 12, 1);
        req.Gender              = 'M';
        AsyncKyHbeMci.AsyncMciHttpsDefaultEndpoint syncEndpoint = new AsyncKyHbeMci.AsyncMciHttpsDefaultEndpoint();
        syncEndpoint.beginEntityMciSearch(cont, req);
        kyHbeMciDatacontracts.MciEntitySearchResponse entityRes = (kyHbeMciDatacontracts.MciEntitySearchResponse) slist[0];
        System.assertEquals(true, entityRes.IsRecordFound);
    }
}