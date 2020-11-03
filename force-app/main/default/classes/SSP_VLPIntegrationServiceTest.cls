/*
* Classname         :  SSP_VLPIntegrationServiceTest
* @description  :  This class is the test class of SSP_VLPIntegrationService
* @author       :  Rijia Khatun
* @date         :  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_VLPIntegrationServiceTest {
    @isTest 
    static void testVLP() { 
        
        Test.setMock(HttpCalloutMock.class, new SSP_VLPMockClass()); 
        Test.startTest();
        SSP_VLPRequestWrapper req = new SSP_VLPRequestWrapper();
        req.SourceSystem ='SSP';
        SSP_VLPRequestWrapper.VLPLawfulPresenceRequest objSub = new SSP_VLPRequestWrapper.VLPLawfulPresenceRequest();
        objSub.CaseNumber ='0';
        objSub.ApplicationNumber= '400141957';
        SSP_VLPRequestWrapper.cls_LawfulPresenceRequestList objSub2  = new SSP_VLPRequestWrapper.cls_LawfulPresenceRequestList();
        SSP_VLPRequestWrapper.cls_LawfulPresenceRequest objSub3 = new SSP_VLPRequestWrapper.cls_LawfulPresenceRequest();
        objSub3.RequestGrantDateIndicator = true;
        objSub3.PersonSurName = 'A';
        objSub3.PersonMiddleName = 'B';
        objSub3.PersonGivenName ='C';
        objSub3.IndividualId = '999034248';
        objSub3.FiveYearBarApplicabilityIndicator = true;
        SSP_VLPRequestWrapper.cls_DHSId obj3 = new SSP_VLPRequestWrapper.cls_DHSId();
        SSP_VLPRequestWrapper.I94DocumentId obj4 = new SSP_VLPRequestWrapper.I94DocumentId();
        obj4.I94Number = '12345678948';
        obj3.I94DocumentId = obj4;
        objSub3.DHSId =  obj3;
        objSub2.LawfulPresenceRequest = new List<SSP_VLPRequestWrapper.cls_LawfulPresenceRequest>{objSub3};
        objSub.LawfulPresenceRequestList = objSub2;
        req.vLPLawfulPresenceRequest = objSub;
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(req)};
        objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
            objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
        List<Object> lstReturnedData = SSP_VLPIntegrationService.invokeCallout(SSP_InterfaceConstants.SSPVLP_METADATANAME,objResponse);  
        System.assertEquals(1,lstReturnedData.size(),'Wrong Output');  
        Test.stopTest();         
    }  
    @isTest 
    static void testVLPNegative() { 
        SSP_VLPIntegrationService.boolNegative = true;
        Test.setMock(HttpCalloutMock.class, new SSP_VLPIntegrationServiceErrorMock()); 
        Test.startTest();
        SSP_VLPRequestWrapper objReq = new SSP_VLPRequestWrapper();
        objReq.SourceSystem= '34334';
        objReq.vLPLawfulPresenceRequest = new SSP_VLPRequestWrapper.vLPLawfulPresenceRequest();
        objReq.vLPLawfulPresenceRequest.CaseNumber = 'CaseNumber';
        objReq.vLPLawfulPresenceRequest.ApplicationNumber = 'ApplicationNumber';
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objReq)};
        objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,'AppId');
        objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,'CaseNumber');
        List<Object> lstReturnedData = SSP_VLPIntegrationService.invokeCallout(SSP_InterfaceConstants.SSPVLP_METADATANAME,objResponse);  
        System.assertEquals(1,lstReturnedData.size(),'Wrong Output');   
        Test.stopTest();         
    }    
    
    public class SSP_VLPIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}