/**
 * Classname                    :  SSP_TaxFormsCorrespondenceIntServiceTest
 * @description                 :  This class is the test class of SSP_TaxFormsCorrespondenceIntService
 * @author                      :  Rajeev Kumar
 * @date                        :  07/17/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName          MM/DD/YYYY          A Brief Description about the Change
 */

@isTest
 public class SSP_TaxFormsCorrespondenceIntServiceTest {
    /**
     * method       : testContactInfo
     * @description     : To test Contact Info
     * @author      : Rajeev Kumar
     */
     
     @isTest
    static void testPositiveUseCase() {
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true, SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE));        
        Test.startTest(); 
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_TaxFormsCorrespondenceReqWrapper objRequest = new SSP_TaxFormsCorrespondenceReqWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters = new SSP_TaxFormsCorrespondenceReqWrapper.TaxFormsCorrespondenceRequestParametersWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters.EnrollmentId = '1000018434';
        objRequest.TaxFormsCorrespondenceRequestParameters.ApplicableYear = '2016';
        objRequest.TaxFormsCorrespondenceRequestParameters.SourceApplication = 'SSP';
        objRequest.TaxFormsCorrespondenceRequestParameters.UserInfo = 'tax.test@externalide.idecit.ide';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(objRequest));
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE,mapParams);   
        System.assertEquals(1,lstReturnedData.size(),'Expected Output');  
        Test.stopTest();         
    }

    /**
     * method                   : testNegetiveUseCase
     * @description             : To test contact info negetive scenario
     * @author                  : Rajeev Kumar
     */
     
     @isTest
    static void testNegetiveUseCase() {
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(false, SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE));        
        Test.startTest();
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_TaxFormsCorrespondenceReqWrapper objRequest = new SSP_TaxFormsCorrespondenceReqWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters = new SSP_TaxFormsCorrespondenceReqWrapper.TaxFormsCorrespondenceRequestParametersWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters.EnrollmentId = '1000018434';
        objRequest.TaxFormsCorrespondenceRequestParameters.ApplicableYear = '2016';
        objRequest.TaxFormsCorrespondenceRequestParameters.SourceApplication = 'SSP';
        objRequest.TaxFormsCorrespondenceRequestParameters.UserInfo = 'tax.test@externalide.idecit.ide';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(objRequest));
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE,mapParams);   
        System.assertEquals(1,lstReturnedData.size(),'Expected Output'); 
        Test.stopTest();         
    }

    /**
     * method                   : testCalloutException
     * @description             : To test contact info callout exception scenario
     * @author                  : Rajeev Kumar
     */
     
     @isTest
    static void testCalloutException() {
        Test.setMock(HttpCalloutMock.class, new SSP_IntegrationServiceMock(true));        
        Test.startTest(); 
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_TaxFormsCorrespondenceReqWrapper objRequest = new SSP_TaxFormsCorrespondenceReqWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters = new SSP_TaxFormsCorrespondenceReqWrapper.TaxFormsCorrespondenceRequestParametersWrapper();
        objRequest.TaxFormsCorrespondenceRequestParameters.EnrollmentId = '1000018434';
        objRequest.TaxFormsCorrespondenceRequestParameters.ApplicableYear = '2016';
        objRequest.TaxFormsCorrespondenceRequestParameters.SourceApplication = 'SSP';
        objRequest.TaxFormsCorrespondenceRequestParameters.UserInfo = 'tax.test@externalide.idecit.ide';
        mapParams.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(objRequest));
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.TAX_FORMS_CORRESPONDENCE,mapParams);  
        System.assertEquals(1,lstReturnedData.size(),'Expected Output'); 
        Test.stopTest();         
    }
}