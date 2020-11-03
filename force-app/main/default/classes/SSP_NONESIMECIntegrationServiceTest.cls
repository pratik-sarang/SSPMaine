/**
* Class Name    : SSP_NONESIMECIntegrationServiceTest
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Test class for SSP_NONESIMECIntegrationService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_NONESIMECIntegrationServiceTest {
     static testMethod void validScenarioForBothCaseandApplicationNumber() {
        Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(200,true)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        objReq.CaseNumber= 34334; 
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};     
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();         
    }
    static testMethod void validScenarioForCaseNumber() {
        SSP_Transaction__c sp = new SSP_Transaction__c (InterfaceName__c = SSP_InterfaceConstants.SSPNONESIMEC_METADATANAME,
                                                       CaseNumber__c = '34334');
        insert sp;
        Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(200,true)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.CaseNumber= 34334; 
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};     
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();         
    }
    
    static testMethod void validScenarioForApplicationNumber() {
        Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(200,true)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};     
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();         
    }
     
    static testMethod void validExceptioninSuccessScenario() {
        Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(200,false)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};     
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();         
    }
    
    static testmethod void SFExceptionScenario(){
    Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(500,true)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();     
    }
    
    static testmethod void exceptionScenario(){
    Test.setMock(HttpCalloutMock.class, new SSP_NONESIMECServiceMock(400,true)); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();     
    }
    static testmethod void sfCalloutExceptionScenario(){
    Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(300,false));
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         Test.stopTest();     
    }
    
     static testMethod void validprocessException() {
       Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Full Match')); 
         Test.startTest();
        SSP_NONESIMECRequestWrapper objReq = new SSP_NONESIMECRequestWrapper();
        objReq.ApplicationNumber= 34334;
        String str = JSON.serialize(objReq);
        Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>str};     
        List<object> lstReturnedData = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
         System.assertEquals(1,lstReturnedData.size());    
         Test.stopTest();         
    }

}
