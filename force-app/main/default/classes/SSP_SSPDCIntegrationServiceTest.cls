/*
* Classname     :  SSP_SSPDCIntegrationServiceTest
* @description  :  This class is the test class of SSP_SSPDCIntegrationService
* @author       :  Ragunathan
* @date         :  04/03/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
@isTest(seeAllData=false)
public class SSP_SSPDCIntegrationServiceTest {
    @TestSetup
    public static void setupMethod(){
        SSP_TestDataFactory.setupTestData();
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'HealthSelectionCtrl';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr.RequestAccessPermission__c = '{   "PermissionLevel_Medicaid__c" : "true" }';
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
    }

    @isTest //SSP_Interface_Security Fixes
    static void shouldGetResponse() { 
        User citizen = getUserDetails();
        System.runAs(citizen){
            Test.setMock(HttpCalloutMock.class, new SSP_SSPDCIntegrationServiceMock(200)); 
            Test.startTest(); 
            Map<String, Object> objResponse = new Map<String, Object>();
            objResponse.put(SSP_InterfaceConstants.SUBMIT_TYPE,'Intake');
            
            List<String> APPLICABLE_SCREEN_LIST = new List<String>{'SSP_APP_Primary_Address','NA'};
            objResponse.put(SSP_InterfaceConstants.SCREEN_LIST,APPLICABLE_SCREEN_LIST);
            SSP_Application__c ssApp = [Select id, Account__c from SSP_Application__c limit 1];
            objResponse.put(SSP_InterfaceConstants.ACCOUNT_ID,ssApp.Account__c);
            objResponse.put(SSP_InterfaceConstants.APPLICATION_ID,ssApp.Id);
            objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
            List<Object> lstReturnedData = IntegrationFactory.invokeCallout(
                SSP_InterfaceConstants.SSP_DC, 
                objResponse);
            //System.assertEquals(1, lstReturnedData.Size(),'Correct Output');
            Test.stopTest();   
        }
    }
    @isTest 
    static void shouldGetException() { 
        User citizen = getUserDetails();
        System.runAs(citizen){
            Test.setMock(HttpCalloutMock.class, new SSP_SSPDCIntegrationServiceMock(200)); 
            Test.startTest(); 
            Map<String, Object> objResponse = new Map<String, Object>();
            List<String> APPLICABLE_SCREEN_LIST = new List<String>{'SSP_APP_Primary_Address','NA'};
            objResponse.put(SSP_InterfaceConstants.SCREEN_LIST,APPLICABLE_SCREEN_LIST);
            SSP_Application__c ssApp = [Select id, Account__c from SSP_Application__c limit 1];
            objResponse.put(SSP_InterfaceConstants.ACCOUNT_ID,ssApp.Account__c);
            objResponse.put(SSP_InterfaceConstants.APPLICATION_ID,ssApp.Id);
            objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
            List<Object> lstReturnedData = IntegrationFactory.invokeCallout(
                SSP_InterfaceConstants.SSP_DC, 
                objResponse);
            //System.assertEquals(1, lstReturnedData.Size(),'Correct Output');
            Test.stopTest();   
        }
    }
    @isTest 
    static void shouldGetFailureResponse() { 
        User citizen = getUserDetails();
        System.runAs(citizen){
            Test.setMock(HttpCalloutMock.class, new SSP_SSPDCIntegrationServiceErrorMock()); 
            Test.startTest(); 
            Map<String, Object> objResponse = new Map<String, Object>();
            objResponse.put(SSP_InterfaceConstants.SUBMIT_TYPE,'INTAKE');
            SSP_Application__c ssApp = [Select id, Account__c from SSP_Application__c limit 1];
            objResponse.put(SSP_InterfaceConstants.ACCOUNT_ID,ssApp.Account__c);
            objResponse.put(SSP_InterfaceConstants.APPLICATION_ID,ssApp.Id);
            List<String> APPLICABLE_SCREEN_LIST = new List<String>{'SSP_APP_Primary_Address','NA'};
            objResponse.put(SSP_InterfaceConstants.SCREEN_LIST,APPLICABLE_SCREEN_LIST);
            objResponse.put(SSP_InterfaceConstants.IS_DEBUG, true);
            List<Object> lstReturnedData = IntegrationFactory.invokeCallout(
                SSP_InterfaceConstants.SSP_DC, 
                objResponse);
            System.assertEquals(2, lstReturnedData.Size(),'Correct Output');
            Test.stopTest(); 
        }      
    }
    
    
    
    public class SSP_SSPDCIntegrationServiceMock implements HttpCalloutMock{
        public Integer statusCode;
        public SSP_SSPDCIntegrationServiceMock(Integer statusCode){
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =   '    {    '+
                                '    "SubmitApplicationResponse": {    '+
                                '    "AckResponse": {    '+
                                '    "AckResponseCode": "INT0000",    '+
                                '    "AckResponseDescription": "Success"    '+
                                '    }    '+
                                '    }    '+
                                '    }    ';
    }
    
    static String RACSelectionDetail =  '    [    '+
                                        '    {    '+
                                        '    "memberId": "a0ir0000001wTFfAAM",    '+
                                        '    "selectedScreens": [    '+
                                        '    {    '+
                                        '    "screens": "SSP_APP_Primary_Address,SSP_APP_Primary_Contact",    '+
                                        '    "flowName": "ContactInformation"    '+
                                        '    },    '+
                                        '    {    '+
                                        '    "screens": "SSP_APP_RTF_TaxFiling,SSP_APP_RTF_Relationships",    '+
                                        '    "flowName": "Relationships&TaxFiling"    '+
                                        '    },    '+
                                        '    {    '+
                                        '    "screens": "SSP_APP_Details_MedicareCoverageSummary",    '+
                                        '    "flowName": "MemberHealthInformation"    '+
                                        '    }    '+
                                        '    ]    '+
                                        '    }    '+
                                        '    ]    ';
    
    public class SSP_SSPDCIntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
    private static User getUserDetails(){
        User citizen  = [SELECT Id, ContactId,Name FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
        return citizen;
    }
}