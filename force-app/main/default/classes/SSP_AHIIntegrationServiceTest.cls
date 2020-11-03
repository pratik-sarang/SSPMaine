/*
* Classname         :  SSP_AHIIntegrationServiceTest
* @description  :  This class is the test class of SSP_AHIIntegrationService
* @author       :  Rijia Khatun
* @date         :  2/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_AHIIntegrationServiceTest {
    @isTest 
    static void testAHI() {
        Test.setMock(HttpCalloutMock.class, new SSP_AHIMockClass()); 
        Test.startTest();
        SSP_AHIRequestWrapper objReq = new SSP_AHIRequestWrapper();
        objReq.RequestId = '100026229';
        objReq.KeyIdentifier = 'APPLICATION NUMBER';
        objReq.KeyValue = '113456700';
        List<SSP_AHIRequestWrapper.IndividualInformation> lstInfo = new List<SSP_AHIRequestWrapper.IndividualInformation>();
        SSP_AHIRequestWrapper.IndividualInformation objInd = new SSP_AHIRequestWrapper.IndividualInformation();
        objInd.IndividualId = '100027229';
        objInd.PersonGivenName = 'BUNTY';
        objInd.PersonMiddleName = 'A';
        objInd.PersonSSNIdentification = '910042830';
        objInd.PersonSurName = 'JACKSON';
        objInd.TypeOfTaxFiler = 'PRIMARY';
        lstInfo.add(objInd);
        SSP_AHIRequestWrapper.IndividualInformationListClass objListInd = new SSP_AHIRequestWrapper.IndividualInformationListClass();
        objListInd.IndividualInformation = lstInfo;
        objReq.IndividualInformationList = objListInd;
        
        String stBody = JSON.serialize(objReq);
        Map<String, Object> mapReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> stBody };
        mapReq.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        mapReq.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAHI_METADATANAME, mapReq);
        System.assertEquals(2,lstReturnedData.size(),'Wrong Output'); 
        Test.stopTest();         
    }
    @isTest 
    static void testNegetive() {
        Test.setMock(HttpCalloutMock.class, new SSP_AHIMockClass()); 
        Test.startTest();
        SSP_AHIRequestWrapper objReq = new SSP_AHIRequestWrapper();
        objReq.RequestId = '100026229';
        objReq.KeyIdentifier = 'APPLICATION NUMBER';
        objReq.KeyValue = '113456700';
        List<SSP_AHIRequestWrapper.IndividualInformation> lstInfo = new List<SSP_AHIRequestWrapper.IndividualInformation>();
        SSP_AHIRequestWrapper.IndividualInformation objInd = new SSP_AHIRequestWrapper.IndividualInformation();
        objInd.IndividualId = '100027229';
        objInd.PersonGivenName = 'BUNTY';
        objInd.PersonMiddleName = 'A';
        objInd.PersonSSNIdentification = '910042830';
        objInd.PersonSurName = 'JACKSON';
        objInd.TypeOfTaxFiler = 'PRIMARY';
        lstInfo.add(objInd);
        SSP_AHIRequestWrapper.IndividualInformationListClass objListInd = new SSP_AHIRequestWrapper.IndividualInformationListClass();
        objListInd.IndividualInformation = lstInfo;
        objReq.IndividualInformationList = objListInd;
        
        String stBody = JSON.serialize(objReq);
        SSP_AHIIntegrationService.throwExceptionForUnitTest = true;
        Map<String, Object> mapReq = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> stBody };
        mapReq.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        mapReq.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
        List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAHI_METADATANAME, mapReq);
        System.assertEquals(2,lstReturnedData.size(),'Wrong Output'); 
        Test.stopTest();         
    }
}