/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_HearingSummaryControllerTest
*   Created By   :   Chandra Shekhar
*   Created Date :   07/29/2020
*   Description  :   Test Class for SSP_HearingSummaryController
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Chandra Shekhar            07/29/2020     Initial Version
*****************************************************************************************************************************/
@isTest(seeAllData=false)
public with sharing class SSP_HearingSummaryControllerTest {
    @testSetup static void setup() {
        SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'NonCitizenUser';
        lstAcc[0].caseNumber__c = '100373492';
        insert lstAcc;
        User cUser = fetchCitizenUser();
        
        List<Contact> lstCon =  SSP_TestDataFactory.createContacts(1,false);
        lstCon[0].accountId = lstAcc[0].Id;
        lstCon[0].IndividualId__c='999033797';
        lstCon[0].DoesCaseExistForIndividual__c=true;
        insert lstCon;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].status__c = 'P';
        lstAppln[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstAppln[0].LocalDCBSOffice__c = 'Kentucky';
        lstAppln[0].ProgramsApplied__c ='MA;KT;CC';
        lstAppln[0].DCCaseNumber__c = 100373492;
        lstAppln[0].RAC_Selections__c='CIS_CareTaker';
        lstAppln[0].ApplicationCreationInSSP__c = system.today();
        insert lstAppln;
        
        List<SSP_Member__c> lstMem2 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem2[0].contact__c=lstCon[0].Id; 
        lstMem2[0].IndividualId__c = '999033797';
        lstMem2[0].FirstName__C ='Test';
        lstMem2[0].LastName__C='Last';
        insert lstMem2;
        
        List<SSP_ApplicationIndividual__c> lstAppInd1 = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd1[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd1[0].SSP_Member__c=lstMem2[0].Id;
        lstAppInd1[0].ProgramsApplied__c = 'MA;KT;CC';
        lstAppInd1[0].isHeadOfHousehold__c = true;
        insert lstAppInd1[0];
        
        DocumentDetail__c dd= new DocumentDetail__c();
        dd.Document_Type_Description__c='Hearing Doc';
        dd.Hearing_Id__c='12342342';
        dd.Hearing_Request_Number__c='12342342';
        dd.Name='Test.pdf';
        dd.UserId__c='9998288232';
        dd.ContentDocumentId__c='0011assassjd';
        dd.StatusCode__c='Fail';
        insert dd;
        
        
        //String hearingCompare=String.escapeSingleQuotes(hearingId+'-'+hearingRequestNumber);
        SSP_Notifications__c noti= new SSP_Notifications__c();
        noti.Linked_Record_Id__c='12342342-12342342';
        noti.Status__c='Active';
        noti.MessageCreateDate__c=System.today();
        noti.Benefind_Id__c='Notice,220655';
        noti.Case_Number__c='100373492';
        noti.Program_Code__c='MA';
        noti.recipientId__c='999033797';
        noti.recipientType__c='Citizen';
        noti.messageSubject__c='notice';
        noti.messageSubjectES__c='notice';
        noti.RecordTypeId=SSP_Utility.fetchRecordType('Notice','SSP_Notifications__c').id;
        noti.notificationCode__c='EDB-104';
        noti.dmsDocumentId__c='4C666EF2-C792-18F4-F1DB-39ED6635C975';
        insert noti;
        
    }
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    @isTest
    public static void getRequestHearingPicklist(){
        
        List<Account> lstAcc1 = [SELECT Id, Name, CaseNumber__c FROM Account WHERE Name = 'NonCitizenUser' LIMIT 1];
        
        List<Contact> lstCon1 = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];
        
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = lstAcc1[0].Id;
        acr1.Contactid = lstCon1[0].Id;
        acr1.IsActive = true;
        acr1.DCContactId__c=232;
        acr1.Roles='Organization_Auth_Rep';
        acr1.Street__c='Testlast';
        acr1.AddressLine2__c='Testlast';
        acr1.City__c='Testlast';
        acr1.CountyCode__c='059';
        acr1.SSP_State__c='KY';
        acr1.Zipcode4__c='4312';
        acr1.Zipcode5__c='40602';
        insert acr1;
        
        List<SSP_Application__c> lstAppln1 = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln1[0].Account__c=lstAcc1[0].Id;        
        lstAppln1[0].Contact__c = lstCon1[0].Id;
        lstAppln1[0].ProgramsApplied__c = 'SS';
        insert lstAppln1;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon1[0].Id;  
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln1[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'MA;KT;CC';
        lstAppInd[0].isHeadOfHousehold__c = true;
        insert lstAppInd;
        
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('caseVsStatus','{"100373492":"AP"}');
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,'Organization_Auth_Rep');
        
        SSP_HearingSummaryController.getRequestHearingPicklist('919218728');
        SSP_HearingSummaryController.getAuthRepWrap(new list<AccountContactRelation>{acr1});
        SSP_HearingSummaryController.getNegativeNoticeForHearing('100373492');
        SSP_HearingSummaryController.changeNotificationStatus('12342342','12342342');
        User cUser = fetchCitizenUser();
        SSP_LightningResponse tosend=SSP_HearingSummaryController.getScreenPermission('SSP_APP_HearingDocuments',cUser.Id);    
    }  
    @isTest
    public static void getRequestHearingPicklist1(){
        
        List<Account> lstAcc1 = [SELECT Id, Name, CaseNumber__c FROM Account WHERE Name = 'NonCitizenUser' LIMIT 1];
        
        List<Contact> lstCon1 = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];
        
        AccountContactRelation acr1 = new AccountContactRelation(); 
        acr1.Accountid = lstAcc1[0].Id;
        acr1.Contactid = lstCon1[0].Id;
        acr1.IsActive = true;
        acr1.DCContactId__c=232;
        acr1.Roles='Assister';
        acr1.Street__c='Testlast';
        acr1.AddressLine2__c='Testlast';
        acr1.City__c='Testlast';
        acr1.CountyCode__c='059';
        acr1.SSP_State__c='KY';
        acr1.Zipcode4__c='4312';
        acr1.Zipcode5__c='40602';
        insert acr1;
        
        List<SSP_Application__c> lstAppln1 = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln1[0].Account__c=lstAcc1[0].Id;        
        lstAppln1[0].Contact__c = lstCon1[0].Id;
        lstAppln1[0].ProgramsApplied__c = 'SS';
        insert lstAppln1;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon1[0].Id;  
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln1[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'MA;KT;CC';
        lstAppInd[0].isHeadOfHousehold__c = true;
        insert lstAppInd;
        
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('caseVsStatus','{"100373492":"AP"}');
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,'Assister');
        
        SSP_HearingSummaryController.getRequestHearingPicklist('919218728');
        SSP_HearingSummaryController.getAuthRepWrap(new list<AccountContactRelation>{acr1});
        SSP_HearingSummaryController.getNegativeNoticeForHearing('100373492');
    } 
    
    @isTest
    public static void withdrawHearingRequest(){
        SSP_LightningResponse tosend=SSP_HearingSummaryController.getScreenPermission('SSP_APP_hearing','123');
        SSP_HearingSummaryController.changeNotificationStatus('12342342','122342');
        Test.setMock(WebServiceMock.class, new SSP_WithdrawHearingIntegrationSeviceMock());
        Test.startTest();
        String objReq = '12342342';
        SSP_HearingSummaryController.withdrawHearingRequest('qw434');
        Test.stopTest();
    }
    @isTest
    public static void withdrawHearingRequestNegative(){        
        Test.setMock(WebServiceMock.class, new SSP_WithdrawHearingIntegrationSeviceMock());
        Test.startTest();
        String objReq = '12342342';
        SSP_HearingSummaryController.withdrawHearingRequest('qw1111434');
        Test.stopTest();
    }
    @isTest
    public static void viewHearingDetails(){
        Test.setMock(WebServiceMock.class, new SSP_HearingSummary_WebMockTest('Positive'));
        Test.startTest();        
        SSP_HearingSummaryController.showHearingSummaryDetail('12342342');
        Test.stopTest();
    }
    @isTest
    public static void viewHearingDetailsNegative(){
        Test.setMock(WebServiceMock.class, new SSP_HearingSummary_WebMockTest('Negative'));
        Test.startTest();        
        SSP_HearingSummaryController.showHearingSummaryDetail('12342342');
        Test.stopTest();
    }
    @isTest
    public static void getHearingSummaryPositive(){        
        Test.setMock(HttpCalloutMock.class, new SSP_HearingSummary_HttpMockTest('Positive'));
        Test.startTest();
        SSP_HearingSummaryController.getHearingSummary('920056103');
        Test.stopTest();
    }
    @isTest
    public static void getHearingSummaryNegative(){
        Test.setMock(HttpCalloutMock.class, new SSP_HearingSummary_HttpMockTest('Negative'));
        Test.startTest();
        SSP_HearingSummaryController.getHearingSummary('920056103');
        Test.stopTest();
    }
    @isTest
    public static void sendHearingRequest(){
        String  newHearingData='{"DCContactId":"100373492","AccommodationList":"IN,DI","RequireAccommodation":"Y","Comments":"Test","ContinueBenefits":"Y","HealthInDanger":"Y","HearingReason":"INCR","HearingProgram":"MEDCD","DCCaseNumber":100373492,"DMSDocumentId":"4C666EF2-C792-18F4-F1DB-39ED6635C975"}';               
        String  representativeData='{"MailingAddressLine2__c":"78","MailingAddressLine1__c":"1775, Darby Creek Drive, Galloway, Pleasant Township, FRANKLIN COUNTY, OHIO, United States, 43119, 9171","RepresentativeEmail":"test@test.com","RepresentativePhoneNo":"534-564-5633","RepresentativeOrganisationName":"KY","RepresentativeLastName":"TestlASTNAME","RepresentativeFirstName":"TestName","AddressLine1__c":"1775, Darby Creek Drive, Pleasant Township","AddressLine2__c":"78","City__c":"Galloway","CountyCode__c":"037","StateCode__c":"OH","CountryCode__c":"USA","ZipCode5__c":"43119"}';        
        String  addressData='[{"ZipCode5":"40602","ZipCode4":"4312","StateCode":"KY","PrimaryPhoneTypeCode":null,"PrimaryPhoneNumber":null,"PrimaryPhoneExtension":null,"MiddleInitial":null,"LastName":"UMNBVC","GenderCode":"M","FirstName":"KKSMSAM","Email":null,"CountyCode":"100","City":"KALISPELL","AddressLine2":"MAIN STREET","AddressLine1":"GLACIER PINES RV"}]';
        
        Test.setMock(WebServiceMock.class, new SSP_CreateHearingIntegrationServiceMock());
        Test.startTest();        
        SSP_HearingSummaryController.sendHearingRequest(newHearingData,representativeData,addressData);
        Test.stopTest();
    }
    @isTest
    public static void sendHearingRequest2(){
        String  newHearingData='{"DCContactId":"100373492","AccommodationList":"IN,DI","RequireAccommodation":"Y","Comments":"Test","ContinueBenefits":"Y","HealthInDanger":"Y","HearingReason":"INCR","HearingProgram":"MEDCD","DCCaseNumber":100373492,"DMSDocumentId":"4C666EF2-C792-18F4-F1DB-39ED6635C975"}';              
        String  representativeData=null;
        String  addressData='[{"ZipCode5":"40602","ZipCode4":"4312","StateCode":"KY","PrimaryPhoneTypeCode":null,"PrimaryPhoneNumber":null,"PrimaryPhoneExtension":null,"MiddleInitial":null,"LastName":"UMNBVC","GenderCode":"M","FirstName":"KKSMSAM","Email":null,"CountyCode":"100","City":"KALISPELL","AddressLine2":"MAIN STREET","AddressLine1":"GLACIER PINES RV"}]';
        
        Test.setMock(WebServiceMock.class, new SSP_CreateHearingIntegrationServiceMock());
        Test.startTest();        
        SSP_HearingSummaryController.sendHearingRequest(newHearingData,representativeData,addressData);
        Test.stopTest();
    }
    @isTest
    public static void sendHearingRequest3(){
        String  newHearingData='{"DCContactId":"100373492","AccommodationList":"IN,DI","RequireAccommodation":"Y","Comments":"Test","ContinueBenefits":"Y","HealthInDanger":"Y","HearingReason":"INCR","HearingProgram":"MEDCD","DCCaseNumber":100373492,"DMSDocumentId":"4C666EF2-C792-18F4-F1DB-39ED6635C975"}';               
        String  representativeData=null;
        String  addressData=null;
        Test.setMock(WebServiceMock.class, new SSP_CreateHearingIntegrationServiceMock());
        Test.startTest();        
        SSP_HearingSummaryController.sendHearingRequest(newHearingData,representativeData,addressData);
        Test.stopTest();
    }
}