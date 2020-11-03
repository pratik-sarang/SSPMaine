/*
* Classname         :  SSP_VCIIntegrationServiceTest
* @description  :  This class is the test class of SSP_VCIIntegrationService
* @author       :  Rijia Khatun
* @date         :  12/10/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest
public class SSP_VCIIntegrationServiceTest {
    @isTest 
    static void testVCI() { 
        Test.setMock(HttpCalloutMock.class, new SSP_VCIMockClass()); 
        Test.startTest(); 
        String stBody =   '   {  '  + 
            '     '  + 
            '               "CaseNumber": "0",  '  + 
            '               "ApplicationNumber": "456736474",  '  + 
            '     '  + 
            '           "VerifyCurrentIncomeIndividuals": [  '  + 
            '            {  '  + 
            '                   "IndividualId": "0",  '  + 
            '                   "PersonBirthDate": "1991-11-11T00:00:00",  '  + 
            '                   "PersonGivenName": "sartaj",  '  + 
            '                   "PersonMiddleName":"xyz",  '  + 
            '                   "PersonSSNIdentification": "563457676",  '  + 
            '                   "PersonSurName": "singh"  '  + 
            '               }  '  + 
            '           ]  '  + 
            '         '  + 
            '   }  '  + 
            '    ' ;  
         Set<String> setOfSSNs = new Set<String>{'768836915'};
         Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> stBody,
         SSP_InterfaceConstants.SSPAHI_APPLICATIONID=>'VCITest1',
         SSP_InterfaceConstants.SSPAHI_CASENUMBER=>'CaseNumber',
         SSP_InterfaceConstants.SSPVCI_SETOFSSNs=>setOfSSNs};
         List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPVCI_METADATANAME,objResponse);  
         System.assertEquals(2,lstReturnedData.size(),'Correct Output');   
         Test.stopTest();         
    }  
    @isTest 
    static void testVCInNegative() { 
        Test.setMock(HttpCalloutMock.class, new SSP_VCIErrorMock()); 
        SSP_VCIIntegrationService.boolNegative = true;
        Test.startTest(); 
        String stBody =   '   {  '  + 
            '     '  + 
            '               "CaseNumber": "0",  '  + 
            '               "ApplicationNumber": "456736474",  '  + 
            '     '  + 
            '           "VerifyCurrentIncomeIndividuals": [  '  + 
            '            {  '  + 
            '                   "IndividualId": "0",  '  + 
            '                   "PersonBirthDate": "1991-11-11T00:00:00",  '  + 
            '                   "PersonGivenName": "sartaj",  '  + 
            '                   "PersonMiddleName":"xyz",  '  + 
            '                   "PersonSSNIdentification": "563457676",  '  + 
            '                   "PersonSurName": "singh"  '  + 
            '               }  '  + 
            '           ]  '  + 
            '         '  + 
            '   }  '  + 
            '    ' ;  

        
         Set<String> setOfSSNs = new Set<String>{'768836915'};
         Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> stBody,
         SSP_InterfaceConstants.SSPAHI_APPLICATIONID=>'VCITest1',
         SSP_InterfaceConstants.SSPAHI_CASENUMBER=>'CaseNumber',
         SSP_InterfaceConstants.SSPVCI_SETOFSSNs=>setOfSSNs};
         List<Object> lstReturnedData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPVCI_METADATANAME,objResponse);  
         System.assertEquals(2,lstReturnedData.size(),'Correct Output'); 
         Test.stopTest();         
    }          
    
    public class SSP_VCIErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
}