/*
* classname     :  SSP_NonCitizenRACTest
* @description  :  Test class for SSP_NonCitizenRAC
* @author       :  Chandra Shekhar  
* @date         :  05/11/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_NonCitizenRACTest {
   @testSetup static void setup() {         
        SSP_TestDataFactory.setupTestData();    
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'NonCitizenUser';
        lstAcc[0].caseNumber__c = '890';
        insert lstAcc;
        
        List<Contact> lstCon =  SSP_TestDataFactory.createContacts(1,false);
        lstCon[0].accountId = lstAcc[0].Id;
        lstCon[0].IndividualId__c='360799621';
        lstCon[0].DoesCaseExistForIndividual__c=true;
        insert lstCon;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln[0].status__c = 'P';
        lstAppln[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstAppln[0].LocalDCBSOffice__c = 'Kentucky';
        lstAppln[0].ProgramsApplied__c ='MA;KT;CC';
        lstAppln[0].DCCaseNumber__c = 890;
        lstAppln[0].RAC_Selections__c='CIS_CareTaker';
        lstAppln[0].ApplicationCreationInSSP__c = system.today();
        insert lstAppln;
       
        List<SSP_Member__c> lstMem2 = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem2[0].contact__c=lstCon[0].Id; 
        lstMem2[0].IndividualId__c = '360799621';
        lstMem2[0].FirstName__C ='Test';
        lstMem2[0].LastName__C='Last';
        insert lstMem2;
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem2[0].Id;
        lstAppInd[0].ProgramsApplied__c = 'MA;KT;CC';
        lstAppInd[0].isHeadOfHousehold__c = true;
        
        
        
    }
    @isTest
    public static void triggerBenefitsServiceCall() {
        List<SSP_Member__c> lstMem2= [Select Id,IndividualId__c from SSP_Member__c  where IndividualId__c = '360799621'];  
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenRAC_HttpMockTest());
        Test.startTest();
        Map<String,List<String>> response = SSP_NonCitizenRAC.triggerBenefitsServiceCall('360799621',lstMem2[0].id); 
        system.assertNotEquals(null, response);        
       Test.stopTest();
               
    }
    @isTest
    public static void getCISData() {       
        SSP_Application__c appli=[Select Id,DCCaseNumber__c from SSP_Application__c limit 1];       
        SSP_NonCitizenRAC.getCISData(appli.id,SSP_GlobalConstants.SSP_INTAKE_FLOW);        
        SSP_NonCitizenRAC.getCISData(appli.id,SSP_GlobalConstants.SSP_RAC_FLOW);
    }
    public static SSP_RSSPDC_RequestWrapper prepareRequestWrapper(String viewName, Id applicationId, String primAppIndivId) {
        SSP_RSSPDC_RequestWrapper requestWrapper = new SSP_RSSPDC_RequestWrapper();
        requestWrapper.caseNumber                     = 890;
        requestWrapper.mode                           = 'Intake';
        requestWrapper.miscelleanousParameter         = '';
        requestWrapper.primaryApplicationIndividualId = primAppIndivId;
        requestWrapper.individualIds                  = '360799621';
        requestWrapper.viewName                       = viewName;
        requestWrapper.applicationID                  = applicationId;
        
        return requestWrapper;
    }
        public HTTPResponse respond(HTTPRequest req) {
        // Create a test response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{  "viewName" : "BenefitInformation",  "role" : "Citizen_Individual",  "programCode" : "",  "primaryApplicationIndividualId" : "360799621",  "mode" : "",  "miscelleanousParameter" : "",  "KeyValueParameters" : null,  "individualIds" : "",  "caseNumber" : 0,  "applicationID" : ""}');
        res.setStatusCode(200);
        system.debug('## mock getting called');
        return res;
    }
    
}