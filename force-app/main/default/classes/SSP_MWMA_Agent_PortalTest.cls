/**
* Class        :  SSP_MWMA_Agent_PortalTest
* Description  :  SSP_MWMA_Agent_PortalTest
* @author      :  Deloitte
* @date        :  
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* -----------------------------------------------------------------------------------------------------------   
* Priyamvada                     07/28/2020                              Initial version
**/
@isTest
public class SSP_MWMA_Agent_PortalTest {
    
    @isTest static void testSetup() {
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        system.runAs(u) {
        test.startTest();
        RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Application', 'Account');
        Account acc = new Account(Name = 'testAcc');
        acc.RecordTypeId = objAccountRecordType.Id;
        insert acc;
        Account acc1 = new Account(Name = 'testAcc');
        acc1.RecordTypeId = objAccountRecordType.Id;
        acc1.DCDataId__c = 123456;
        insert acc1;
        Contact con = new Contact(FirstName =  'Sam', Lastname = 'Potts'); 
        RecordType objContactRecordType = GeneralUtility.fetchRecordType('Non_Citizen', 'Contact');
        con.RecordTypeId = objContactRecordType.Id;
        con.AccountId = acc.Id;
        insert con;
        AccountContactRelation acr = new AccountContactRelation(AccountId = acc1.Id, ContactId = con.Id, DCContactId__c = 123456, Roles = 'Insurance_Agent');
        insert acr;
       
        SSP_Application__c app = new SSP_Application__c(Account__c = acc.Id, Contact__c = con.Id);
        insert app;
        SSP_Member__c member = new SSP_Member__c(Contact__c = con.Id);
        insert member;
        SSP_ApplicationIndividual__c ind = new SSP_ApplicationIndividual__c(SSP_Application__c = app.Id, SSP_Member__c = member.Id);
        insert ind;
        test.stopTest();
        }
    }
    
    @isTest static void testCallout() {   
        testSetup();
        Test.setMock(WebServiceMock.class, new SSP_MWMA_Agent_PortalMockTest());
        Date dob = Date.newInstance(1990, 2, 11);
		SSP_MWMA_Agent_Portal.requestWrapper request = new SSP_MWMA_Agent_Portal.requestWrapper();
        request.FirstName = 'Sam';
        request.LastName = 'Potts';
        request.DOB = dob;
        request.CountyCode = '123';
        request.SuffixCode = 'test';
        request.MiddleInitial = 'Sr';
        request.IdentifierType = 'Case Number';
        request.IdentifierValue = '123456';
        request.LoggedinUserid = 123456;
        request.LoggedInUserIdsOrgId = 123;
        request.LoggedInUserRole = 'External';
        request.PortalSource = 'MWMA';
        SSP_MWMA_Agent_Portal.responseWrapper response = new SSP_MWMA_Agent_Portal.responseWrapper();
        SSP_MWMA_Agent_Portal.responseWrapper responseTest = new SSP_MWMA_Agent_Portal.responseWrapper();
        response = SSP_MWMA_Agent_Portal.getSearchResults(request); 
    }
    
        @isTest static void testCallout1() {   
            testSetup();
            Test.setMock(WebServiceMock.class, new SSP_MWMA_Agent_PortalMockTest());
            Date dob = Date.newInstance(1990, 2, 11);
            SSP_MWMA_Agent_Portal.requestWrapper request = new SSP_MWMA_Agent_Portal.requestWrapper();
            request.DOIAgentId = 123456;
            request.FirstName = 'Sam';
            request.LastName = 'Potts';
            request.DOB = dob;
            request.CountyCode = '123';
            request.SuffixCode = 'test';
            request.MiddleInitial = 'Sr';
            request.IdentifierType = 'SSN';
            request.IdentifierValue = '123456';
            request.LoggedinUserid = 123456;
            request.LoggedInUserIdsOrgId = 123;
            request.LoggedInUserRole = 'Internal';
            request.PortalSource = 'MWMA';
            SSP_MWMA_Agent_Portal.responseWrapper response = new SSP_MWMA_Agent_Portal.responseWrapper();
            SSP_MWMA_Agent_Portal.responseWrapper responseTest = new SSP_MWMA_Agent_Portal.responseWrapper();
            response = SSP_MWMA_Agent_Portal.getSearchResults(request); 
    	}
    
    @isTest static void testCallout2() {   
            testSetup();
            Test.setMock(WebServiceMock.class, new SSP_MWMA_Agent_PortalMockTest());
            Date dob = Date.newInstance(1990, 2, 11);
            SSP_MWMA_Agent_Portal.requestWrapper request = new SSP_MWMA_Agent_Portal.requestWrapper();
            request.DOIAgentId = 0;
            request.FirstName = 'Sam';
            request.LastName = 'Potts';
            request.DOB = dob;
            request.CountyCode = '123';
            request.SuffixCode = 'test';
            request.MiddleInitial = 'Sr';
            request.IdentifierType = 'MAID';
            request.IdentifierValue = '123456';
            request.LoggedinUserid = 123456;
            request.LoggedInUserIdsOrgId = 123;
            request.LoggedInUserRole = 'Internal';
            request.PortalSource = 'MWMA';
            SSP_MWMA_Agent_Portal.responseWrapper response = new SSP_MWMA_Agent_Portal.responseWrapper();
            SSP_MWMA_Agent_Portal.responseWrapper responseTest = new SSP_MWMA_Agent_Portal.responseWrapper();
            response = SSP_MWMA_Agent_Portal.getSearchResults(request); 
    	}


}