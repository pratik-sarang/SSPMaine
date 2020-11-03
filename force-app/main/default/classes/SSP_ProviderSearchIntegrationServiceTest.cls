/*
* Classname     :  SSP_ProviderSearchIntegrationServiceTest
* @description  :  This class is the test class of SSP_ProviderSearchIntegrationService
* @author       :  Ragunathan
* @date         :  02/10/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          02/10/2020            Initial Creation
**/
@isTest
public class SSP_ProviderSearchIntegrationServiceTest {
    
    /**
     * method 		: providerSearchTest
     * @description 	: To test provider search scenario
     * @author 		: Rajeev Kumar
     */
    static testMethod void providerSearchTest() {
        String jsonString = ''; 
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true, 'providerSearch'));
        Map<String, Object> objRequest = new Map<String, Object>{'organizationName' => 'organizationNameTest',
                                                                    'livingArrangementType'=>'Sharing',
                                                                    SSP_InterfaceConstants.IS_DEBUG=>true};
        Test.startTest();
        List<Object> serviceResponses = (new SSP_ProviderSearchIntegrationService()).invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, objRequest);
        SSP_ProviderSearchResponseWrapper providerResponse = (SSP_ProviderSearchResponseWrapper) serviceResponses[0];
        
        System.assertEquals(1, serviceResponses.size(), 'expected 1');
        Test.stopTest();
    }

    /**
     * method 		    : providerSearchNegetive
     * @description 	: To test provider search negetive scenario
     * @author 		    : Rajeev Kumar
     */
    static testmethod void providerSearchNegetive() {
        String jsonString = ''; 
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(false, 'providerSearch') );
        Map<String, Object> objRequest = new Map<String, Object>{'organizationName' => 'organizationNameTest',
                                                                    'livingArrangementType'=>'Sharing',
                                                                    SSP_InterfaceConstants.IS_DEBUG=> true};
        Test.startTest();
        List<Object> serviceResponses = (new SSP_ProviderSearchIntegrationService()).invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, objRequest);
        
        System.assertEquals(true, serviceResponses.isEmpty(), 'expected empty response for negative scenario');
        Test.stopTest();
    }

    /**
     * method 		    : providerSearchCalloutException
     * @description 	: To test contact info callout exception scenario
     * @author 		    : Rajeev Kumar
     */    
    static testmethod void providerSearchCalloutException() {
        String jsonString = ''; 
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true));
        Map<String, Object> objRequest = new Map<String, Object>{'organizationName' => 'organizationNameTest',
                                                                    'livingArrangementType'=>'Sharing',
                                                                    SSP_InterfaceConstants.IS_DEBUG=> true};
        Test.startTest();
        List<Object> serviceResponses = (new SSP_ProviderSearchIntegrationService()).invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, objRequest);
        System.assertEquals(true, serviceResponses.isEmpty(), 'expected empty response for negative scenario');
        Test.stopTest();
    }
}