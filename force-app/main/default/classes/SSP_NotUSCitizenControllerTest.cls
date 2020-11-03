/***************************************************************************************************
*   Type        :   Controller Test Class
*   Name        :   SSP_NotUSCitizenControllerTest
*   Create By   :   Shivam Tiwari
*   Create Date :   JAN-31-2020
*   Description :   Test class for SSP_NotUSCitizenController.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Shivam Tiwari           JAN-31-2020             Initial Version
*
*****************************************************************************************************/
@isTest(seeAllData=false)
public class SSP_NotUSCitizenControllerTest {
    
    public static String sMemberId=''; 
    @testSetup
    public static void setup(){
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'TestAcc';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];		
        List<Contact> lstCon2 = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];		
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        insert acr;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].Name='TestMember';
        lstMem[0].contact__c=lstCon[0].Id;
		lstMem[0].IndividualId__c='999015638';        
        insert lstMem;
        List<SSP_Member__c> lstMem2 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem2[0].Name='I2';
        lstMem2[0].contact__c=lstCon2[0].Id;
		lstMem2[0].IndividualId__c='999015634';        
        insert lstMem2;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].Name='TestInd';
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        insert lstAppInd;
    }
    
    public static SSP_ApplicationIndividual__c sspApplicationIndividual(){
      SSP_ApplicationIndividual__c applicationIndividual = new SSP_ApplicationIndividual__c();
      applicationIndividual = [SELECT Id, SSP_Application__c, SSP_Member__c FROM SSP_ApplicationIndividual__c LIMIT 1];  
      return applicationIndividual;
    }
    
    @isTest
    public static void internalAlienSponsorTest(){
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        List<SSP_Member__c> lstMem2=[SELECT Id from SSP_Member__c where Name='I2' Limit 1];
        lstMem[0].HasAlienSponsorToggle__c = 'N';
        lstMem[0].InternalAlienSponsor__c = lstMem2[0].id;
        update lstMem;
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            SSP_NotUSCitizenController.memberDataWrapper objWrapper = new SSP_NotUSCitizenController.memberDataWrapper();
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.handleAlienSponsor( lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    @isTest
    public static void internalAlienSponsorWithDCIdTest(){
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        List<SSP_Member__c> lstMem2=[SELECT Id from SSP_Member__c where Name='I2' Limit 1];
        lstMem[0].HasAlienSponsorToggle__c = 'N';
        lstMem[0].InternalAlienSponsor__c = lstMem2[0].id;
        lstMem[0].DCInternalAlienSponsorId__c = 213;
        update lstMem;
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.handleAlienSponsor( lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    @isTest
    public static void externalAienSponsorTest(){
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        SSP_AlienSponsor__c objAlien = new SSP_AlienSponsor__c(
            SSP_Member__c=lstMem[0].id
        );
        insert objAlien;
        lstMem[0].HasAlienSponsorToggle__c = 'N';
        lstMem[0].ExternalAlienSponsor__c = objAlien.id;
        update lstMem;
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.handleAlienSponsor( lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    @isTest
    public static void externalAienSponsorWithDCIDTest(){
        List<SSP_Member__c> lstMem=[SELECT Id,ExternalAlienSponsor__r.DCAlienSponsorId__c from SSP_Member__c where Name='TestMember' Limit 1];
        SSP_AlienSponsor__c objAlien = new SSP_AlienSponsor__c(
            SSP_Member__c=lstMem[0].id
        );
        insert objAlien;
        objAlien.DCAlienSponsorId__c = 1;
        update objAlien;
        lstMem[0].HasAlienSponsorToggle__c = 'N';
        lstMem[0].ExternalAlienSponsor__c = objAlien.id;
        update lstMem;
        List<SSP_Member__c> lstMem2=[SELECT Id,ExternalAlienSponsor__r.DCAlienSponsorId__c from SSP_Member__c where Name='TestMember' Limit 1];
        system.debug('===== external sponsor Tst '+lstMem2[0].ExternalAlienSponsor__r.DCAlienSponsorId__c);
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.handleAlienSponsor( lstApps[0].Id, lstMem2[0].Id);
            test.stopTest();
        }
    }


    @isTest
    public static void prepareRequestTest(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":null,"immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I9F","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest1(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"DS2","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest2(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"FP","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest3(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"CZ","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest4(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I20","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest5(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I3","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest6(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I57","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest7(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"AR","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest20(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I5","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest8(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I76","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest9(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"I9","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest10(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"MRV","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest11(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"NT","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest12(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"OT","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest13(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"AI","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest14(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"OREL","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest15(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"WR","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest16(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"DHS","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest17(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"Y","immigrationDateOfBirth":"2015-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"Y","alienTypeCode":"AMI","immigrationDocumentTypeCode":"HHS","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest18(){
        string jsonData = '{"memberFirstName":"Chris","memberLastName":"John","servedInUSMilitary":"N","immigrationDateOfBirth":"1915-10-10","immigrationSuffix":null,"immigrationFirstName":null,"immigrationMiddleName":null,"immigrationLastName":null,"hasLegalImmigrationStatus":"Y","immigrationDetailsMatch":false,"passportNumber":"1238875","naturalizationNumber":null,"i94Number":"000000000A1","documentDescription":null,"documentExpiryDate":"2020-01-01","issuanceCountryCode":"Myanmar","citizenshipNumber":null,"hasLivedInUS":"N","alienTypeCode":"CHP","immigrationDocumentTypeCode":"ORR","SEVISId":null,"receiptNumber":null,"alienNumber":null,"hasAlienSponsor":"Y"}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void prepareRequestTest19(){
        string jsonData = '{"immigrationSuffix":"FV","immigrationFirstName":null,"immigrationMiddleName":"M","immigrationLastName":null}';
        List<SSP_Member__c> lstMem=[SELECT Id from SSP_Member__c where Name='TestMember' Limit 1];
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            test.startTest();
            SSP_NotUSCitizenController.prepareRequest(jsonData, lstApps[0].Id, lstMem[0].Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void getProgramsAppliedTest(){
        User citizen  = getCitizenUser();
        System.runAs(citizen){
            List<SSP_Application__c> lstApps = getApplications();
            List<SSP_ApplicationIndividual__c> appIndvList = getApplicationIndividuals(lstApps[0].Id) ;
            test.startTest();
            SSP_NotUSCitizenController.getProgramsApplied(appIndvList[0].SSP_Member__c, appIndvList[0].SSP_Application__c);
            test.stopTest();
        }
    }
    
    private static List<SSP_Application__c> getApplications(){
        return ([SELECT Id, Name FROM SSP_Application__c LIMIT 1]);
    }
    
    private static List<SSP_ApplicationIndividual__c> getApplicationIndividuals(String appsId){
        return ([SELECT Id, SSP_Member__c, SSP_Application__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: appsId]);
    }
    
    private static User getCitizenUser(){
        return ([SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]);
    }

}