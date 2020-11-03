/**
* Class Name    : SSP_AddressVerification_IntUtilityTest
* Owner         : DELOITTE
* Created Date  : 28/11/2019
* Description   : Test class for SSP_AddressVerification_IntUtility
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_AddressVerification_IntUtilityTest {
    
    public static testmethod void validSuccessScenarioForAddressVerification(){
        Test.setMock(WebServiceMock.class, new SSP_AddressVerificationMock());
        SSP_AddressVerificationWSDLService.COT_USAC_County_op1 request= new SSP_AddressVerificationWSDLService.COT_USAC_County_op1();
        request.record_id = '';
        request.line1 = '301 Versailles Rd';
        request.line2 = '';
        request.city = 'Frankfort';
        request.state = 'KY';
        request.zip = '40012';
        Map<String,object> mapParams = new Map<String,object>();
        mapParams.put('body',JSON.serialize(request));
        test.startTest();
        Test.setMock(WebServiceMock.class, new SSP_AddressVerificationMock());        
        List<object> slist = IntegrationFactory.invokeCallout('SSP_AddressVerification',mapParams);
        test.stopTest(); 
        system.assert(slist[0]!= null);
    }
     public static testmethod void validFailedScenarioForAddressVerification(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(300,false));
        SSP_AddressVerificationWSDLService.COT_USAC_County_op1 request= new SSP_AddressVerificationWSDLService.COT_USAC_County_op1();
        request.record_id = '';
        request.line1 = '301 Versailles Rd';
        request.line2 = '';
        request.city = 'Frankfort';
        request.state = 'KY';
        request.zip = '40012';
        Map<String,object> mapParams = new Map<String,object>();
        mapParams.put('body',JSON.serialize(request));
        test.startTest();      
        List<object> slist = IntegrationFactory.invokeCallout('SSP_AddressVerification',mapParams);
        test.stopTest(); 
        system.assert(slist[0]!= null);
    }
}