/**
* Class Name    : SSP_MCIMergedServiceUtiltiyTest
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Test class for SSP_MCIMergedServiceUtiltiy
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_MCIMergedServiceUtiltiyTest {
    public static testmethod void validFullMatchScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Full Match')); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        
        sp.SourceSystemName = 'HBE';
        sp.sourceIndividualId = 123123456;
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        SSP_MCIMergedServiceRequestWrapper swrapper = (SSP_MCIMergedServiceRequestWrapper) System.JSON.deserialize(JSON.serialize(sp), SSP_MCIMergedServiceRequestWrapper.class);
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
        
    }
    public static testmethod void validExceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',500,false,'Mule Exception')); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        sp.SourceSystemName = 'HBE';
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        obj.put('respvalue','Mule Exception');
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
    }
    public static testmethod void validApplicationBlockScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Application Block')); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        sp.SourceSystemName = 'HBE';
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
    }
    public static testmethod void validExceptionasScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Mule Exception')); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        sp.SourceSystemName = 'HBE';
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
    }
    
     public static testmethod void validProcessException(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('MCIMergedService',200,false,'Exception in Data')); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        sp.SourceSystemName = 'HBE';
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
    }
     public static testmethod void sfCalloutException(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(300,false)); 
        SSP_MCIMergedServiceRequestWrapper sp = new SSP_MCIMergedServiceRequestWrapper();
        sp.SourceSystemName = 'HBE';
        sp.DOB = string.valueof(system.today() - 200)+'T00:00:00';
        Map<String,object> obj = new Map<string,object>();
        obj.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(sp));
        List<object> slist = IntegrationFactory.invokeCallout('SSP_MergedMCIService',obj);
        SSP_MCIMergedServiceResponeWrapper resp = (SSP_MCIMergedServiceResponeWrapper) slist[0];
        system.assert(resp != null);
    }
    
}