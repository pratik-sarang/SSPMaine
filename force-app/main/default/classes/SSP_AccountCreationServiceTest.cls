/*
* classname     : SSP_AccountCreationServiceTest
* @description  : This class is use to cover class of SSP_AccountCreationService
* @author       : Payal Dubela
* @date         : 08/23/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_AccountCreationServiceTest {
    @testSetup static void setup() { 
         SSP_TestDataFactory.setupTestData();
        AppConfig__c app = new AppConfig__c();
        app.Name='SSPCertificate';
        app.Value__c = 'SSP_SelfSignedSandbox';
        insert app;
    }
    @isTest
    public static void testMethod1(){
        Account acc= new Account(Name ='Mickel James');
        Account acc1= new Account(Name ='Mickey James');
        Contact con= new Contact(FirstName ='Mickel',LastName='James');
        Contact con1= new Contact(FirstName ='Mickey',LastName='James');
        User citizen  = [SELECT Id,ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1];
         RestContext.request = new System.RestRequest();
         RestContext.response = new System.RestResponse();
        Blob data = Blob.valueOf('textinput'); 
        Blob signature= System.Crypto.signWithCertificate('RSA', data, AppConfig__c.getInstance('SSPCertificate').Value__c);
        RestContext.request.requestURI = 'https://test.salesforce.com/services/apexrest/CreateAccount/';
        RestContext.request.httpMethod = 'POST';
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json');
        RestContext.request.requestBody = Blob.valueOf('{}');
        Test.startTest();
         SSP_AccountCreationService.doPost('textinput',EncodingUtil.base64Encode(signature),JSON.serialize(new List<Account>{acc,acc1}),JSON.serialize(new List<Contact>{con,con1}),citizen.ContactId);
        System.runAs(citizen){
             SSP_AccountCreationService.doPost('textinput',EncodingUtil.base64Encode(signature),JSON.serialize(new List<Account>{acc,acc1}),JSON.serialize(new List<Contact>{con,con1}),citizen.ContactId);
        }
        Test.stopTest();
    }

}