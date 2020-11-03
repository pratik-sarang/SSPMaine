@isTest(seeAllData=false)
public class SSP_ReportFraudServiceTest  {
    
     @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();    
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'IncomeController';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
         lstMem[0].contact__c=lstCon[0].Id;  
         lstMem[0].IsHeadOfHousehold__c= true; 
         lstMem[0].IndividualId__c = '123456';
         lstMem[0].MailingAddressLine1__c = 'test';
         lstMem[0].MailingAddressLine2__c ='test';
         lstMem[0].MailingCity__c = 'test';
         lstMem[0].MailingStateCode__c = 'AL';
         lstMem[0].MailingCountyCode__c = '076';
         lstMem[0].MailingZipCode5__c = '6567';
         lstMem[0].PrimaryPhoneNumber__c ='6767776769';
         lstMem[0].PrimaryPhoneExtension__c = '123';
         lstMem[0].Email__c = 'abc@gmail.com';
         lstMem[0].MailingAddrValidated__c = true;
         insert lstMem;        
         
         contact_Mapping__c conMap = new contact_Mapping__c();
         conMap.IEES_Id__c = 123456;
         conMap.Contact__c=lstCon[0].Id;
         insert conMap;
       
    }
  
     @isTest
    static void submitFraudReportTest() {
        String jsonData = '{"canOIGContactYou":"N","individualFraudEmployerName":"employer","fraudCaseNumber":"7878787877","fraudPhoneNumber":"787-878-7888","individualFraudDOB":"2006-07-05","individualFraudSSN":"787878788","individualFraudGender":"M","individualFraudSuffix":"JR","individualFraudMiddleName":"Middle Name","individualFraudLastName":"Last Name","individualFraudFirstName":"First Name","whatHappened":"Test Happened","whoCommittedFraud":"IN","fraudReportDate":"2020-07-31","fraudAddressLine1":"8373, Maineville Road, Hamilton Township","fraudAddressLine2":null,"fraudCity":"Maineville","fraudCounty":"114","fraudState":"OH","fraudZipCode":"45039","individualFraudEmployerAddressLine1":"9140, East Independence Boulevard, Township 13 Morning Star","individualFraudEmployerAddressLine2":null,"individualFraudEmployerCity":"Matthews","individualFraudEmployerCounty":"200","individualFraudEmployerState":"NC","individualFraudEmployerZipCode":"28105"';
		Test.setMock(HttpCalloutMock.class, new SSP_FraudSubmission_IntegrationServiceMock());
        Test.startTest();
        SSP_ReportFraudService.submitFraudReport(jsonData,false);
        Test.stopTest();
        }
    
    @isTest
    static void getMemberDetailsForUserTest (){
        SSP_ReportFraudService.getUserContactInfo();
    }
    
public class SSP_FraudSubmission_IntegrationServiceMock implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
        
        String responseBody =    ' {"Payload" :  {  '  + 
                                 '      "SubmitFraudResult": {  '  + 
                                 '         "FraudReportId": "10",  '  + 
                                 '         "ExceptionId": "ExceptionId_0"  '  + 
                                 '      },  '  + 
                                 '      "AckResponse": {  '  + 
                                 '         "AckResponseCode": "AckResponseCode_0",  '  + 
                                 '         "AckResponseDescription": "AckResponseDescription_0"  '  + 
                                 '      }  '  + 
            '  }  }' ; 
    }
    
    public class SSP_FraudSubmission_IntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }
    
}