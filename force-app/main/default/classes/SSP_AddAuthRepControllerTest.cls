/*
* classname     :  SSP_AddAuthRepControllerTest
* @description  :  Test class for SSP_AddAuthRepController
* @author       :  Shrikant Raut   
* @date         :  01/22/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/

@isTest(seeAllData=false)
public class SSP_AddAuthRepControllerTest {
    /**
    @author : Shrikant Raut 
    Method to setup test data
	*/ 
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'AuthrepController';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;  
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_Asset__c> lstAsset = SSP_TestDataFactory.createAssets(8, 'Income',false);
        lstAsset[0].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income'); 
        lstAsset[0].SSP_Member__c = lstMem[0].Id;
        lstAsset[0].IncomeTypeCode__c ='DIR';
        lstAsset[1].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[1].SSP_Member__c = lstMem[0].Id;
        lstAsset[1].IncomeTypeCode__c ='UI';
        lstAsset[2].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[2].SSP_Member__c = lstMem[0].Id;
        lstAsset[2].IncomeTypeCode__c ='EA';
        lstAsset[3].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[3].SSP_Member__c = lstMem[0].Id;
        lstAsset[3].IncomeTypeCode__c ='SE';
        lstAsset[4].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[4].SSP_Member__c = lstMem[0].Id;
        lstAsset[4].IncomeTypeCode__c ='SRP';
        lstAsset[5].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[5].SSP_Member__c = lstMem[0].Id;
        lstAsset[5].IncomeTypeCode__c ='SM';
        lstAsset[6].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[6].SSP_Member__c = lstMem[0].Id;
        lstAsset[6].IncomeTypeCode__c ='IS';
        lstAsset[7].RecordTypeId = SSP_TestDataFactory.getRecordTypeMapping('SSP_Asset__c').get('Income');
        lstAsset[7].SSP_Member__c = lstMem[0].Id;
        lstAsset[7].IncomeTypeCode__c ='OUI';
        lstAsset = ESAPI.accessController().insertAsUser(lstAsset, SSP_Utility.getFieldsNamesList (lstAsset)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();
        createAuthRepData();
        
                
        AppConfig__c app = new AppConfig__c();
        app.Name='SSPCertificate';
        app.Value__c = 'SSP_SelfSignedSandbox';
        insert app;
        
        SSPIntegrationEndpoints__c endpoint = new SSPIntegrationEndpoints__c();
        endpoint.Name = 'CreateAccountService';
        endpoint.URL__c = 'https://sspdev-benefind-reci.cs32.force.com/benefind/services/apexrest/CreateAccount/';
        insert endpoint;
    }
    
    /**
    @author : Shrikant Raut 
    Method to setup up AuthRep related test data
	*/ 
    private static void createAuthRepData(){
        Account act = new Account();
        act.Name = 'Test AuthRep';
        act = (Account)ESAPI.accessController().insertAsUser(new List<Account>{act}, SSP_Utility.getFieldsNamesList (new List<Account>{act})).getInsertedObjects()[0];       
        
        List<Contact> contactList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'AuthRep';
        con.Email = 'AuthRep@test.com';
        con.AccountId = act.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'AuthRepTest';       
        con1.AccountId = act.Id;
        insert con1;
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = ((List<Account>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Account'}, new Set<String>{'Id'}, new Map<String, String>{'Name'=>'AuthrepController','limit'=>'1'}))[0].Id; 
        acr.Contactid = con.Id;
        acr.IsActive = true;
        acrList.add(acr);
        //acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];        
        
        User citizenUser = ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];
		          
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = act.Id; 
        acr1.Contactid = citizenUser.ContactId;
        acr1.IsActive = true;
        acrList.add(acr1);    
		
        insert acrList;
        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchContactInformation method
	*/
    @isTest
    public static void test_fetchContactInformation(){
        System.runAs(fetchCitizenUser()){
            Contact authRep = [SELECT Id FROM Contact WHERE Lastname = 'AuthRep' LIMIT 1];
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'AuthrepController'];
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.fetchContactInformation(authRep.Id, appIndvList[0].SSP_Application__c, 'sspAddAuthRep');
            system.assertNotEquals(null, response.mapResponse, 'failed in fetching mapResponse');
            system.assertNotEquals(null, response.mapResponse.containsKey('contactRecord'), 'failed in fetching mapResponse');
            system.assertNotEquals(null, response.mapResponse.containsKey('accountContactRelationRecord'), 'failed in fetching mapResponse');
            system.assertNotEquals(null, response.mapResponse.containsKey('relationshipCodes'), 'failed in fetching mapResponse');            
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method
	*/
    @isTest
    public static void test_fetchContactInformation_Negative(){    
        User citizen = fetchCitizenUser();
        System.runAs(citizen){
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.fetchContactInformation(citizen.Id, citizen.Id,  'sspAddAuthRep');
            system.assertNotEquals(null, response.mapResponse, 'failed in fetching mapResponse');
            system.assertNotEquals(null, response.mapResponse.containsKey('ERROR'), 'failed in fetching mapResponse');
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchExistingIncomeDetails method
	*/
    @isTest
    public static void test_upsertContactInformation(){
        User citizenUser = fetchCitizenUser();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = testAccount.Id;
        acr.ContactId= citizenUser.ContactId;
        insert acr;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        
        System.runAs(citizenUser){     
            
            
            test.startTest();            
            Contact con = new Contact();
            con.FirstName = 'New';
            con.LastName = 'AuthRep';
            con.AccountId = testAccount.Id;
            Contact authRep = [SELECT Id FROM Contact WHERE Lastname = 'AuthRep' LIMIT 1];
            
            SSP_Application__c sspApplication = [SELECT Id, Account__c FROM SSP_Application__c WHERE Contact__r.FirstName = 'Citizen' AND Contact__r.LastName = 'User' LIMIT 1];
            SSP_LightningResponse response = new SSP_LightningResponse();
            //response = SSP_AddAuthRepController.upsertContactInformation(JSON.serialize(new List<Contact>{con}), JSON.serialize(new List<AccountContactRelation>{new AccountContactRelation()}),JSON.serialize(new Map<String, String>{'sspApplicationId' => sspApplication.Id, 'sspApplicationAccount'=>sspApplication.Account__c}));
            response = SSP_AddAuthRepController.upsertContactInformation(JSON.serialize(new List<Contact>{con}), null ,JSON.serialize(new Map<String, String>{'sspApplicationId' => sspApplication.Id, 'sspApplicationAccount'=>sspApplication.Account__c, 'flowName' => 'addAuthRep', 'isSelectedViaSearch' => 'false'}));
            insert con;
            List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation WHERE ContactId = :authRep.Id AND AccountId != :testAccount.Id LIMIT 1];
            acrList[0].RepresentativeRelationshipCode__c = 'FM';
            SSP_LightningResponse responseWhenEdited = SSP_AddAuthRepController.upsertContactInformation(JSON.serialize(new List<Contact>{con}), JSON.serialize(acrList),JSON.serialize(new Map<String, String>{'sspApplicationId' => sspApplication.Id, 'sspApplicationAccount'=>sspApplication.Account__c, 'flowName' => 'updateAuthRep'}));
            system.assert(responseWhenEdited.bIsSuccess, 'Failed in updating auth rep');
            
            SSP_LightningResponse responseViaSearch = SSP_AddAuthRepController.upsertContactInformation(JSON.serialize(new List<Contact>{con}), JSON.serialize(new List<AccountContactRelation>{new AccountContactRelation(ContactId = con.Id)}),JSON.serialize(new Map<String, String>{'sspApplicationId' => sspApplication.Id, 'sspApplicationAccount'=>sspApplication.Account__c,'flowName' => 'addAuthRep','isSelectedViaSearch'=>'true'}));
             system.assert(responseViaSearch.mapResponse.containsKey('contactId'), 'Failed in adding auth rep');
            
            SSP_LightningResponse responseException = SSP_AddAuthRepController.upsertContactInformation('testException', 'testException', 'testException');
            system.assert(responseException.mapResponse.containsKey('ERROR'), 'Failed in adding auth rep');
            test.stopTest();
        }
    }
    
    private static User fetchCitizenUser(){
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchDetailsForConsent method
	*/
    @isTest
    public static void test_fetchDetailsForConsent(){
        System.runAs(fetchCitizenUser()){
            Contact authRep = [SELECT Id FROM Contact WHERE Lastname = 'AuthRep' LIMIT 1];
            List<SSP_ApplicationIndividual__c> appIndvList = [SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Account__r.Name = 'AuthrepController'];
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.fetchDetailsForConsent(appIndvList[0].SSP_Application__c, 'sspAddAuthRepConsent');

            system.assertNotEquals(null, response.mapResponse, 'appIndividualRecord');
            system.assertNotEquals(null, response.mapResponse, 'suffixCodeValues');
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test fetchDetailsForConsent method
	*/
    @isTest
    public static void test_fetchDetailsForConsent_Negative(){    
        User citizen = fetchCitizenUser();
        System.runAs(citizen){
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.fetchDetailsForConsent('00Nr0000002NzPe',  'sspAddAuthRepConsent');
            system.assertNotEquals(null, response.mapResponse, 'failed in fetching mapResponse');
            system.assertNotEquals(null, response.mapResponse.containsKey('contactRecord'), 'failed in fetching mapResponse');
            test.stopTest();
        }
    }
    
   
    
    
    
       /**
@author : Kireeti Gora
Test Method to test fetchContactInformation method*/
    @isTest
    public static void test_checkForDupicateAuthRep(){
        System.runAs(fetchCitizenUser()){
            Contact authRep = [SELECT Id,Lastname,FirstName,Email FROM Contact WHERE Lastname = 'AuthRep' LIMIT 1];
            
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.checkForDupicateAuthRep(JSON.serialize(authRep));          
            system.assertNotEquals(null, response.mapResponse.containsKey('ERROR'), 'failed in fetching mapResponse');
            
            response = SSP_AddAuthRepController.checkForDupicateAuthRep('testException');          
            system.assert(response.mapResponse.containsKey('EXCEPTION'), 'failed in fetching mapResponse');
            test.stopTest();
        }
    }
     /**
@author : Kireeti Gora
Test Method to test fetchContactInformation method*/
    @isTest
    public static void test_checkForDupicateAuthRep_Negative(){
        System.runAs(fetchCitizenUser()){
            Contact authRep = [SELECT Id,Lastname,FirstName,Email FROM Contact WHERE Lastname = 'AuthRepTest' LIMIT 1];
            
            test.startTest();
            SSP_LightningResponse response = new SSP_LightningResponse();
            response = SSP_AddAuthRepController.checkForDupicateAuthRep(JSON.serialize(authRep));          
            system.assertNotEquals(null, response.mapResponse.containsKey('ERROR'), 'failed in fetching mapResponse');
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test getCountyCode method*/
    @isTest
    public static void test_getCountyCode(){
        System.runAs(fetchCitizenUser()){
            test.startTest();
            String response = SSP_AddAuthRepController.getCountyCode('Breckinridge');          
            system.assertNotEquals(null, response, 'failed in getCountyCode');
            
            response = SSP_AddAuthRepController.getCountyCode('1234');          
            system.assertEquals('200', response, 'failed in getCountyCode');
            test.stopTest();
        }
    }
    
    /**
    @author : Shrikant Raut
    Test Method to test validateAddress method*/
    @isTest
    public static void test_validateAddress(){
        System.runAs(fetchCitizenUser()){
            Contact authRep = [SELECT Id,Lastname,FirstName,Email,Street__c, AddressLine2__c, City__c, SSP_State__c, Zipcode5__c FROM Contact WHERE Lastname = 'AuthRepTest' LIMIT 1];
            
            test.startTest();
            Test.setMock(WebServiceMock.class, new SSP_AddressVerificationMock());
            SSP_AddAuthRepController.validateAddress(authRep);          
            authRep = [SELECT Id, IsAddressValidated__c, Lastname,FirstName,Email,Street__c, AddressLine2__c, City__c, SSP_State__c, Zipcode5__c FROM Contact WHERE Lastname = 'AuthRepTest' LIMIT 1];
            
            test.stopTest();
        }
    }
}