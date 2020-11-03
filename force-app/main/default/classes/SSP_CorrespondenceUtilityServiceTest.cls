/**
* Class Name    : SSP_CorrespondenceUtilityServiceTest
* Owner         : DELOITTE
* Created Date  : 01/07/2020
* Description   : Test class for SSP_CorrespondenceUtilityService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  01/07/2020  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_CorrespondenceUtilityServiceTest {
    static testmethod void validscenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest(); 
    }
    
    static testmethod void validHBEscenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('HBE-016');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest(); 
    }
    
     static testmethod void validscenariowithException(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,false));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest(); 
    }
    
    static testmethod void SFExceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(500,false));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest();
    }
    
    static testmethod void SFCalloutExceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(300,false));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest();
    }
    
     static testmethod void ExceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(400,false));
        Test.startTest();
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('SSP-001');
        crw.ApplicationNumber = 1232123;
        crw.CorrespondenceCode = 'SSP-001';
        Map<String,object> obj = new Map<string,object>();
        obj.put('jsonbody', JSON.serialize(crw));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
        Test.stopTest();
    }
    @isTest
    static void wrapperTest(){
        SSP_CorrespondenceRequestWrapper crw = new SSP_CorrespondenceRequestWrapper('HBE-017');
        SSP_CorrespondenceRequestWrapper crw1 = new SSP_CorrespondenceRequestWrapper('HBE-055');
        
    }
}