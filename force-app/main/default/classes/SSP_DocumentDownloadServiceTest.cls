/**
* Class Name    : SSP_DocumentDownloadServiceTest
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Test class for SSP_DocumentDownloadService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_DocumentDownloadServiceTest {
    
    static testmethod void successScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_MCIMergedServiceMock('DocDownloadService',200,false,'')); 
        Map<String,object> obj = new Map<string,object>();
        obj.put('MappingId','');
        obj.put('DocumentId','2DB1FDBC-117B-3672-F519-39EC7F4ABB98');
        List<object> slist = IntegrationFactory.invokeCallout('SSP_DocumentDownload',obj);
    }
    static testmethod void ExceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(300,false));
        Map<String,object> obj = new Map<string,object>();
        obj.put('MappingId','');
        obj.put('DocumentId','2DB1FDBC-117B-3672-F519-39EC7F4ABB98');
        obj.put('AsyncMode',true);
        List<object> slist = IntegrationFactory.invokeCallout('SSP_DocumentDownload',obj);
    }
}