/*
* classname     :  SSP_RSSPDC_IntegrationServiceTest
* @description  :  Test class for SSP_RSSPDC_IntegrationService
* @author       :  Ragunathan 
* @date         :  14/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
    Ragunathan                  14/02/2020                      Initial Creation
**/

@isTest(seeAllData=false)
public with sharing class SSP_RSSPDC_IntegrationServiceTest {

    @isTest
    public static void RFIDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.RFI_DETAILS);
        SSP_RFIInformationPayloadWrapper objWrapper = new SSP_RFIInformationPayloadWrapper();
        objWrapper = objResponse.RFIInformationPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.RFIInformationPayload);
    }
    
    @isTest
    public static void NonCitizenSearchCase() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE);
        NonCitizenSearchCasePayloadWrapper objWrapper = new NonCitizenSearchCasePayloadWrapper();
        objWrapper = objResponse.nonCitizenSearchCasePayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.nonCitizenSearchCasePayload);
    }

    @isTest
    public static void WaiverDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.WAIVER_DETAILS);
        SSP_WaiverDetailsPayloadWrapper objWrapper = new SSP_WaiverDetailsPayloadWrapper();
        objWrapper = objResponse.waiverDetailsPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.waiverDetailsPayload);
    }

    @isTest
    public static void NotificationInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.NOTIFICATION_INFORMATION);
        //SSP_WaiverDetailsPayloadWrapper objWrapper = new SSP_WaiverDetailsPayloadWrapper();
        //objWrapper = objResponse.waiverDetailsPayload;
        Test.stopTest();
        //System.assertNotEquals(null, objResponse.waiverDetailsPayload);
    }

    @isTest
    public static void DashboardCaseInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION);
        SSP_DashboardCaseInformation objWrapper = new SSP_DashboardCaseInformation();
        objWrapper = objResponse.dashboardCaseInfo;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.dashboardCaseInfo);
    }

    @isTest
    public static void TaxForms1095AInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.TAX_FORMS_1095A_INFORMATION);
        SSP_TaxForms1095AInfoPayloadWrapper objWrapper = new SSP_TaxForms1095AInfoPayloadWrapper();
        objWrapper = objResponse.taxForms1095AInfoPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.taxForms1095AInfoPayload);
    }

    @isTest
    public static void RACSelectionDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.RAC_SELECTION_DETAILS);
        SSP_RACSelectionDetailsWrapper objWrapper = new SSP_RACSelectionDetailsWrapper();
        objWrapper = objResponse.racSelectionWrapper;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.racSelectionWrapper);
    }

    @isTest
    public static void DisqualificationDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.RAC_SELECTION_DETAILS);
        SSP_RACSelectionDetailsWrapper objWrapper = new SSP_RACSelectionDetailsWrapper();
        objWrapper = objResponse.racSelectionWrapper;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.racSelectionWrapper);
    }

    @isTest
    public static void BenefitInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.BENEFIT_INFORMATION);
        SSP_BenefitInformationPayloadWrapper objWrapper = new SSP_BenefitInformationPayloadWrapper();
        objWrapper = objResponse.benefitInformations;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.benefitInformations);
    }

    @isTest
    public static void MyInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.MY_INFORMATION);
        //SSP_BenefitInformationPayloadWrapper objWrapper = new SSP_BenefitInformationPayloadWrapper();
        //objWrapper = objResponse.benefitInformations;
        Test.stopTest();
        //System.assertNotEquals(null, objResponse.benefitInformations);
    }

    @isTest
    public static void MedicaidMCOInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION);
        SSP_MedicaidMCOInformationWrapper objWrapper = new SSP_MedicaidMCOInformationWrapper();
        objWrapper = objResponse.medicaidMCOInformation;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.medicaidMCOInformation);
    }

    @isTest
    public static void HearingsSummaryInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.HEARINGS_SUMMARY_INFORMATION);
        SSP_HearingsSummaryInfoPayloadWrapper objWrapper = new SSP_HearingsSummaryInfoPayloadWrapper();
        objWrapper = objResponse.hearingsSummaryInfoPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.hearingsSummaryInfoPayload);
    }

    @isTest
    public static void AssisterAuthRepClientDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS);
        SSP_AssisterAuthRepDetailsPayloadWrapper objWrapper = new SSP_AssisterAuthRepDetailsPayloadWrapper();
        objWrapper = objResponse.assisterAuthRepDetailsPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.assisterAuthRepDetailsPayload);
    }

    @isTest
    public static void AgentAssistAuthRepDetails() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.AUTHREPS_ASSISTERS);
        //SSP_AssisterAuthRepDetailsPayloadWrapper objWrapper = new SSP_AssisterAuthRepDetailsPayloadWrapper();
        //objWrapper = objResponse.assisterAuthRepDetailsPayload;
        Test.stopTest();
        //System.assertNotEquals(null, objResponse.assisterAuthRepDetailsPayload);
    }

    @isTest
    public static void KHIPPPaymentSummary() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY);
        SSP_KHIPPPaymentSummaryWrapper objWrapper = new SSP_KHIPPPaymentSummaryWrapper();
        objWrapper = objResponse.KHIPPPaymentSummaryPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.KHIPPPaymentSummaryPayload);
    }

    @isTest
    public static void KIHIPPPreferredPayment() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.KIHIPP_PREFERRED_PAYMENT);
        SSP_KIHIPPPreferredPaymentPayloadWrapper objWrapper = new SSP_KIHIPPPreferredPaymentPayloadWrapper();
        objWrapper = objResponse.KIHIPPPreferredPaymentPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.KIHIPPPreferredPaymentPayload);
    }

    @isTest
    public static void NonCitizenSearchExport() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.NON_CITIZEN_SEARCH_EXPORT);
        SSP_NonCitizenSearchExportPayloadWrapper objWrapper = new SSP_NonCitizenSearchExportPayloadWrapper();
        objWrapper = objResponse.nonCitizenSearchExportPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.nonCitizenSearchExportPayload);
    }

    @isTest
    public static void EligibilitySummary() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.ELIGIBILITY_SUMMARY);
        SSP_EligibilitySummaryPayloadWrapper objWrapper = new SSP_EligibilitySummaryPayloadWrapper();
        objWrapper = objResponse.EligibilitySummaryPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.EligibilitySummaryPayload);
    }

    @isTest
    public static void PastApplications() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.PAST_APPLICATIONS);
        SSP_PastApplicationsPayloadWrapper objWrapper = new SSP_PastApplicationsPayloadWrapper();
        objWrapper = objResponse.PastApplicationsPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.PastApplicationsPayload);
    }

    @isTest
    public static void NonCitizenClientInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.NON_CITIZEN_CLIENT_INFORMATION);
        SSP_NonCitizenClientInfoPayloadWrapper objWrapper = new SSP_NonCitizenClientInfoPayloadWrapper();
        objWrapper = objResponse.nonCitizenClientInfoPayload;
        Test.stopTest();
        System.assertNotEquals(null, objResponse.nonCitizenClientInfoPayload);
    }
    
    @isTest 
    public static void SSP_RSSPDCWrapper() {
        Test.startTest();
        SSP_RSSPDCWrapper objWrapper = new SSP_RSSPDCWrapper();
        objWrapper.boolIsDebug = true;
        objWrapper.sInterfaceName = '';
        objWrapper.sScreenNames = '';
        objWrapper.lstAllViews = null;
        objWrapper.log = null;
        objWrapper.mapsObjectList = null;
        objWrapper.retry = null;
        objWrapper.objRequest = null;
        objWrapper.sFlowType = '';
        objWrapper.objUser = null;
        Test.stopTest();
        System.assertNotEquals(false, objWrapper.boolIsDebug);
    }
    
    @isTest 
    public static void shouldGetResponseForPendingViews() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();         
        Test.setMock(HttpCalloutMock.class, mock);
        //Create Test Data
        Id applicationId = createApplication(700000043).Id;
        //Test data for SSP Member
        createMember('999034247');
        //Test data for Transaction
        createTransactionWithStatus('Pending_Views', applicationId, '999034247');
        Map<String, String> mapprograms = new Map<String, String>();
        Map<String, Object> mapParams = new Map<String, Object>{
            'jsonbody' => prepareRequestWrapper('Pending_Views', applicationId, '999034247')
        };

        //SSP_RSSPDC_IntegrationService.boolIsChainJob = false;
        
        Test.startTest();   
        //When
        //SSP_RSSPDC_IntegrationService sspdcreverse = new SSP_RSSPDC_IntegrationService();  
        List<Object> response = SSP_RSSPDC_IntegrationService.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        Test.stopTest();
        System.assertNotEquals(null, response);
    }
    
    @isTest 
    public static void shouldGetResponseForQualifiedIndividual() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        Id applicationId = createApplication(700000043).Id;
        Map<String, String> mapprograms = new Map<String, String>();
        Map<String, Object> mapParams = new Map<String, Object>{
            'jsonbody' => prepareRequestWrapper('ResourceInformation', applicationId, '999018553')
        };
        //SSP_RSSPDC_IntegrationService.boolIsChainJob = false;
        //Test data for Transaction
        createTransactionWithStatus('ResourceInformation', applicationId, '999018553');
        Test.startTest();    
        //When
        //SSP_RSSPDC_IntegrationService sspdcreverse = new SSP_RSSPDC_IntegrationService();  
        List<Object> response = SSP_RSSPDC_IntegrationService.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        Test.stopTest();
        System.assertNotEquals(null, response);
    }

    @isTest 
    public static void shouldGetResponseForIncomeInformation() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        Id applicationId = createApplication(700000043).Id;
        createMember('999034247');        
        
        Map<String, String> mapprograms = new Map<String, String>();
        Map<String, Object> mapParams = new Map<String, Object> {
            'jsonbody' => prepareRequestWrapper('All_Views', applicationId, '999034247')
        };
        createTransactionWithStatus('IncomeInformation', applicationId, '999034247');
        Test.startTest();
        //When
        //SSP_RSSPDC_IntegrationService response = new SSP_RSSPDC_IntegrationService();
        List<Object> responses = SSP_RSSPDC_IntegrationService.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        Test.stopTest();
        System.assertNotEquals(null, responses);
    }

    @isTest
    public static void getAllViews() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        Id applicationId = createApplication(700000043).Id;
        createMember('999034247');        
        Test.startTest();
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
        reqWrapper.mode = SSP_InterfaceConstants.MODE_INTAKE;
        reqWrapper.applicationID = applicationId;
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        mapParams.put(SSP_InterfaceConstants.IS_DEBUG,true);
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        Test.stopTest();

    }

    @isTest 
    public static void AllViews() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl();        
        Test.setMock(HttpCalloutMock.class, mock);
        Id applicationId = createApplication(700000043).Id;
        createMember('999034247');        
        
        Map<String, String> mapprograms = new Map<String, String>();
        
        //SSP_RSSPDC_IntegrationService.boolIsChainJob = false;
        //Test data for Transaction
        List<String> views = new List<String> {
                'QualifiedIndividual', 
                'MemberInformation', 
                'RelationshipInformation', 
                'HealthInformation',
                'HouseHoldOtherInformation',
                'ResourceInformation', 
                'IncomeInformation', 
                'ExpenseInformation', 
                'AbsentParentInformation',
                'HealthCoverageInformation'
                };
        for(String view: views){
           createTransactionWithStatus(view, applicationId, '999034247');
           Map<String, Object> mapParams = new Map<String, Object> {
            'jsonbody' => prepareRequestWrapper(view, applicationId, '999034247')
            };

            //SSP_RSSPDC_IntegrationService response = new SSP_RSSPDC_IntegrationService();
            List<Object> responses = SSP_RSSPDC_IntegrationService.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            System.assertNotEquals(null, responses);
        }
        
    }

    private static SSP_Transaction__c createTransactionWithStatus(String viewName, Id applicationId, String individualId) {
        
        SSP_Transaction__c transactionData = new SSP_Transaction__c(
            View_Name__c = viewName,
            IndividualId__c = individualId,
            ApplicationId__c = applicationId,
            CaseNumber__c = '123456',
            Mode__c = 'Intake',
            Status__c ='Failed'
        );
        
        insert transactionData;
        return transactionData;
    }
    
    private static SSP_Application__c createApplication(Integer caseNumber){
        
        Account acc = new Account(Name='TestName');
        insert acc;
        Id recordTypeId = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
        SSP_Application__c application = new SSP_Application__c(
                                                RecordTypeId = recordTypeId,
                                                DCCaseNumber__c =caseNumber,
                                                Account__c = acc.Id);
        
        insert application;
        return application;
    } 
    
    private static SSP_Member__c createMember(String individualId) {
        
        Contact con = new Contact(FirstName='FirstName', LastName='Test Name', IndividualId__c= individualId);
        insert con;
        SSP_Member__c member = new SSP_Member__c(
            Name = 'TestMember',
            FirstName__c = 'FirstName',
            LastName__c = 'FirstName',
            Contact__c = con.Id,
            IndividualId__c = individualId);
        
        insert member;
        
        return member;
    }
    
    private static SSP_RSSPDC_RequestWrapper prepareRequestWrapper(String viewName, Id applicationId, String primAppIndivId) {
        SSP_RSSPDC_RequestWrapper requestWrapper = new SSP_RSSPDC_RequestWrapper();
        requestWrapper.caseNumber                     = 123456;
        requestWrapper.mode                           = 'Intake';
        requestWrapper.miscelleanousParameter         = '';
        requestWrapper.primaryApplicationIndividualId = primAppIndivId;
        requestWrapper.individualIds                  = '999018553;1234567;2345678;3456789';
        requestWrapper.viewName                       = viewName;
        requestWrapper.applicationID                  = applicationId;
        
        return requestWrapper;
    }
    
    public class SSP_RSSPDC_IntegrationServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Read Time Out');
            throw e;
        }
    }

    public static void handleException() {
        SSP_DC_ReverseMockImpl mock = new SSP_DC_ReverseMockImpl(true);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        RSSP_DC_Wrapper objResponse = invokeRSSPDC(SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY);
        SSP_KHIPPPaymentSummaryWrapper objWrapper = new SSP_KHIPPPaymentSummaryWrapper();
        objWrapper = objResponse.KHIPPPaymentSummaryPayload;
        Test.stopTest();
        System.assertEquals(null, objResponse.KHIPPPaymentSummaryPayload);
    }

    public static RSSP_DC_Wrapper invokeRSSPDC(String sViewName) {
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = sViewName;
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        mapParams.put(SSP_InterfaceConstants.IS_DEBUG,true);
        List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
        return (RSSP_DC_Wrapper)objList[0];
    }
}