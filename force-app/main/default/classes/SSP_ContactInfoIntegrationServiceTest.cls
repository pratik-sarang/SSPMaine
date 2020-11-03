/**
 * Classname 			:  SSP_ContactInfoIntegrationServiceTest
 * @description 		:  This class is the test class of SSP_VCIIntegrationService
 * @author 			:  Rajeev Kumar
 * @date 			:  03/06/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName	      MM/DD/YYYY	      A Brief Description about the Change
 */

@isTest
 public class SSP_ContactInfoIntegrationServiceTest {
    /**
     * method 			: testContactInfo
     * @description 		: To test Contact Info
     * @author 			: Rajeev Kumar
     */
     
     @isTest //SSP_Interface_Security Fixes
    static void testContactInfo() { //removed testmethod , SSP_Interface_Security Fixes
        createMember('999034247');
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true, 'contactInfoUpdate'));        
        Test.startTest(); 
        Map<String, Object> objRequest = new Map<String, Object>{SSP_InterfaceConstants.IndividualId=> '999034247',
                                                                SSP_InterfaceConstants.IS_DEBUG=> true};
        List<Object> lstReturnedData = SSP_ContactInfoIntegrationService.invokeCallout(SSP_InterfaceConstants.UPDATE_CONTACT_INFO,objRequest);  
        System.assertEquals(1,lstReturnedData.size(),'Expected Output');  
        Test.stopTest();         
    }

    /**
     * method       		: testContactInfoNegetive
     * @description     	: To test contact info negetive scenario
     * @author      		: Rajeev Kumar
     */
     
     @isTest //SSP_Interface_Security Fixes
    static void testContactInfoNegetive() { //removed testmethod , SSP_Interface_Security Fixes
        createMember('999034247');
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(false, 'contactInfoUpdate'));        
        Test.startTest(); 
        Map<String, Object> objRequest = new Map<String, Object>{SSP_InterfaceConstants.IndividualId=> '999034247',
                                                                    SSP_InterfaceConstants.IS_DEBUG=> true};
        List<Object> lstReturnedData = SSP_ContactInfoIntegrationService.invokeCallout(SSP_InterfaceConstants.UPDATE_CONTACT_INFO,objRequest);  
        System.assertEquals(0,lstReturnedData.size(),'Expected Output'); 
        Test.stopTest();         
    }

    /**
     * method       		: testContactInfoCalloutException
     * @description     	: To test contact info callout exception scenario
     * @author      		: Rajeev Kumar
     */
     
     @isTest //SSP_Interface_Security Fixes
    static void testContactInfoCalloutException() { //removed testmethod , SSP_Interface_Security Fixes
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true));        
        Test.startTest(); 
        Map<String, Object> objRequest = new Map<String, Object>{SSP_InterfaceConstants.IndividualId=> '999034247',
                                                                    SSP_InterfaceConstants.IS_DEBUG=> true};
        List<Object> lstReturnedData = SSP_ContactInfoIntegrationService.invokeCallout(SSP_InterfaceConstants.UPDATE_CONTACT_INFO,objRequest);  
        System.assertEquals(0,lstReturnedData.size(),'Expected Output'); 
        Test.stopTest();         
    }

    /**
     * method       		: createMember
     * @description     	: Constructor to set values
     * @author      		: Rajeev Kumar
     * @param sIndividualId 	: Individual Id of the member
     * @return SSP_Member__c 	: member record
     */
    private static SSP_Member__c createMember(String individualId) {
        Contact con = new Contact(FirstName='FirstName', LastName='Test Name', IndividualId__c= individualId);
        insert con;
        SSP_Member__c member = new SSP_Member__c(
            Name = 'TestMember',
            FirstName__c = 'FirstName',
            Contact__c = con.Id,
            IndividualId__c = individualId);
        insert member;
        return member;
    }
}