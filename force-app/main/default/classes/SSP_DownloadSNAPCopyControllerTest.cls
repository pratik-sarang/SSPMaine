/*
* classname 	: SSP_DownloadSNAPCopyControllerTest
* @description 	: Test class for SSP_DownloadSNAPCopyController class.
* @author 		: Shivam Tiwari
* @date 		: APR-21-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 				DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Prashant Pandey		APR-21-2020			Initial Version
*/
@isTest
public class SSP_DownloadSNAPCopyControllerTest {
    
    //Test method for Pass scenario
    static testmethod void validScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        Test.startTest();
        string applicationNumber = '1234';
        SSP_DownloadSNAPCopyController.downloadCopy(applicationNumber);
        Test.stopTest();
    }
    
    //Test method for if null is passed as Application Number
    static testmethod void exceptionScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,false));
        Test.startTest();
        string applicationNumber = '1234';
        SSP_DownloadSNAPCopyController.downloadCopy(applicationNumber);
        Test.stopTest();
    }
    
    //Test method for exception scenario
    static testmethod void nullApplicationScenario(){
        Test.setMock(HttpCalloutMock.class, new SSP_CorrespondenceUtilityServiceMock(200,true));
        Test.startTest();
        string applicationNumber = '';
        SSP_DownloadSNAPCopyController.downloadCopy(applicationNumber);
        Test.stopTest();
    }
}