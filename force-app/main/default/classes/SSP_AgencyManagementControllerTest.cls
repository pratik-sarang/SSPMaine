/*
* classname 	: SSP_AgencyManagementControllerTest
* @description 	: A test class for SSP_AgencyManagementController class.
* @author 		: Keshav Poduval
* @date 		: May-20-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Keshav Poduval 		May-20-2020			Initial Version
*/
@isTest(seeAllData = false)
public class SSP_AgencyManagementControllerTest {

    @testSetup
    public static void createTestData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    system.debug('portalRole is ' + portalRole);
    
    Profile profile = [Select Id from Profile where name = 'System Administrator'];
    User portalUserCreator = new User(
        UserRoleId 			=	portalRole.Id,
        ProfileId 			=	profile.Id,
        Username			=	System.now().millisecond() + Math.random() + 'test2@test.com',
        Alias 				=	'batman',
        Email				=	'ronald.stewart@mailinators.com',
        EmailEncodingKey	=	'UTF-8',
        Firstname			=	'Bruce',
        Lastname			=	'Wayne',
        LanguageLocaleKey	=	'en_US',
        LocaleSidKey		=	'en_US',
        TimeZoneSidKey		=	'America/Chicago'
    );
    Database.insert(portalUserCreator);
        system.runAs(portalUserCreator){
        //Create citizen contact/account
        Contact citizenContact1 = SSP_TestDataFactory.createContactRecord('Andrew', 'Nelson', 'andrew@nelson.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Citizen').getRecordTypeId(), true);
        System.assertNotEquals(null, citizenContact1.Id, 'Citizen Contact created successfully');
        
        //Create non citizen contact/account/user
        Contact nonCitizenContact1 = SSP_TestDataFactory.createContactRecord('Allison', 'Gibbs', 'aliison@gibb.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Assister').getRecordTypeId(), true);
        System.assertNotEquals(null, nonCitizenContact1.Id, 'Assister Contact created successfully');
        
        //Create Non citizen user
        User assisterUser = SSP_TestDataFactory.createCommunityUser('assis', nonCitizenContact1.Id, nonCitizenContact1.Email, 'SSP Non Citizen Profile', true);
        
        //Create organization account
        List<Account> listOrgAccount = SSP_TestDataFactory.createAccounts(1, false, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId());
        listOrgAccount[0].DCDataId__c = 1213;
        insert listOrgAccount;
        System.assertNotEquals(null, listOrgAccount[0].Id, 'Org Account created successfully');
        
        //Application Account
        List<Account> listAppAccount = SSP_TestDataFactory.createAccounts(1, true, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Application').getRecordTypeId());
         System.assertNotEquals(null, listOrgAccount[0].Id, 'Org Account created successfully');
        
        //Create ACR 
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(nonCitizenContact1.Id, listOrgAccount[0].Id, false);
        orgACR.Roles = 'Assister';
        listACR.add(orgACR);
        AccountContactRelation appACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(citizenContact1.Id, listAppAccount[0].Id, false);
        listACR.add(appACR);
        AccountContactRelation assisterACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(nonCitizenContact1.Id, listAppAccount[0].Id, false);
        assisterACR.Roles = 'Assister';
        listACR.add(assisterACR);
        insert listACR;
        
        //Create member 
        List<SSP_Member__c> listMembers = SSP_TestDataFactory.createSSPMembers(1, false);
        listMembers[0].FirstName__c='Andrew';
        listMembers[0].LastName__c='Nelson';
        listMembers[0].Contact__c = citizenContact1.Id;
        insert listMembers;
        System.assertNotEquals(null, listMembers[0].Id, 'SSP Member created successfully');

        // application record for citizen
        List<SSP_Application__c> listApplication = SSP_TestDataFactory.createSSPApplications(1, false);
        listApplication[0].Account__c = listACR[1].AccountId;
        listApplication[0].Status__C ='UN';
        insert listApplication;
        
        List<SSP_ApplicationIndividual__c> listAppIndiv = SSP_TestDataFactory.createApplicationIndividuals(1, false);
        listAppIndiv[0].SSP_Member__c = listMembers[0].Id;
        listAppIndiv[0].SSP_Application__c = listApplication[0].Id;
        listAppIndiv[0].IsHeadOfHousehold__c = true;
        insert listAppIndiv;
            
            
            
          
        }
    }
    
    @isTest
    public static void testGetAssisters(){
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];
        List<Contact> listAssisters = SSP_AgencyManagementController.getAssisters(String.valueOf(assisterUser.Id));
        System.assertEquals(1, listAssisters.size(),'Assisters found');
    }
    
    @isTest 
    public static void testSearchFunction(){
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];
        List<SSP_Application__c> listApp = [Select Id, Name from SSP_Application__c LIMIT 1];
        System.runAs(assisterUser){
            List<SSP_AgencyManagementController.AgencySearchResultWrapper> lstResult = SSP_AgencyManagementController.getSearchResults(String.valueOf(assisterUser.ContactId), 'Andrew', 'Nelson', listApp[0].Name, null);
            System.assertEquals(1, lstResult.size(), 'Search Result found');
        }
    }
    
    @isTest 
    public static void testAssignToFunction(){
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];        
        List<SSP_Application__c> listApp = [Select Id, Name from SSP_Application__c LIMIT 1];
        
        System.runAs(assisterUser){
            Test.startTest();
            List<SSP_AgencyManagementController.AgencySearchResultWrapper> lstResult = SSP_AgencyManagementController.getSearchResults(String.valueOf(assisterUser.ContactId), 'Andrew', 'Nelson', listApp[0].Name, null);
            System.assertEquals(1, lstResult.size(), 'Search Result found');
            SSP_AgencyManagementController.assignNewAssisters(lstResult, String.valueOf(assisterUser.ContactId));
            Test.stopTest();                      
        }
    }
        
    @isTest 
    public static void testSearchFunctionCallout(){
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];
        List<SSP_Application__c> listApp = [Select Id, Name from SSP_Application__c LIMIT 1];
        System.runAs(assisterUser){
            Test.startTest();
            List<SSP_AgencyManagementController.AgencySearchResultWrapper> lstResult = SSP_AgencyManagementController.getSearchResults(null, null, null, null, '100071952');            
            Test.stopTest();
        }
    }
        @isTest 
    public static void testcaseAssign(){
        Test.setMock(HttpCalloutMock.class, new SSP_UpdateAgentAssisterMock()); 
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];
        List<SSP_Application__c> listApp = [Select Id, Name from SSP_Application__c LIMIT 1];
        Test.startTest();
        System.runAs(assisterUser){
            List<SSP_AgencyManagementController.AgencySearchResultWrapper> lstResult = SSP_AgencyManagementController.getSearchResults(String.valueOf(assisterUser.ContactId), 'Andrew', 'Nelson', listApp[0].Name, '100071952');
            System.assertEquals(0, lstResult.size(), 'Search Result found');
            SSP_AgencyManagementController.updateCaseAssignment(lstResult, String.valueOf(assisterUser.ContactId));
        }
        Test.stopTest();
    }
     
    @isTest 
    public static void testAssignToFunction_AuthRep(){
        User assisterUser = [SELECT Id, ContactId from user where username = 'aliison@gibb.com' LIMIT 1];
        Contact con = new Contact();
        con.Id = assisterUser.ContactId;
        con.RecordTypeId =  SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Auth_Rep');
        update con;
            
        List<SSP_Application__c> listApp = [Select Id, Account__c, Name from SSP_Application__c LIMIT 1];        
        AccountContactRelation acr = [SELECT Id, Roles FROM AccountContactRelation WHERE ContactId = :assisterUser.ContactId AND AccountId = :listApp[0].Account__c LIMIT 1];
        acr.Roles = 'Organization_Auth_Rep';
        update acr; 
        
        System.runAs(assisterUser){ 
            Test.startTest();
            String serializedWrap = '[{"recordId":0,"isSelected":false,"clientDetails":{"lastName":"Nelson","individualId":null,"gender":null,"firstName":"Andrew","clientAccountId":"001r000000M8CZMAA3","caseNumber":null,"appNumber":"600103860","age":null},"assignedTo":{"lastName":"Gibbs","firstName":"Allison","contactId":"003r000000Op34uAAB","assignmentStartDate":"09/21/2020"}}]';
			List<SSP_AgencyManagementController.AgencySearchResultWrapper> listSelectedAppRecords = (List<SSP_AgencyManagementController.AgencySearchResultWrapper>) JSON.deserialize(serializedWrap, List<SSP_AgencyManagementController.AgencySearchResultWrapper>.class);
            listSelectedAppRecords[0].clientDetails.clientAccountId =listApp[0].Account__c;
            listSelectedAppRecords[0].clientDetails.appNumber =listApp[0].Name;
            SSP_AgencyManagementController.sendApplicationCorrespondence(new Set<String>{listApp[0].Name}, JSON.serialize(listSelectedAppRecords), String.valueOf(assisterUser.ContactId));
            Test.stopTest();                      
        }
    }
    
    
    
    
}