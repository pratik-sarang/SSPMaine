/**
 * @File Name          : REAgencyLoginTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/15/2020, 2:28:38 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/26/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class REAgencyLoginTest {
    Static Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
    Static Id sREAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
    
     /********************************************************************************************
    * @author       Ram Konduri
    * @date         03/26/2020
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void testDataSetup(){
        TestDataFactory.testDataSetup();
         
    }
    //RE_Release 1.3 – ForceReviewer - Payal Dubela
    @isTest public static void testAsyncKog(){ 
        List<Contact> listContact=[Select Id,AccountId,PermissionsLevel__c,Email,Account.Name from Contact ];
        Account acc = new Account();
        acc.Id=listContact[0].AccountId;
        acc.Name=System.Label.RE_AgencyUserAccountName;
        update acc;
        User usr2 = new User(FirstName = 'testAgencyUser2', LastName = 'testAgencyUser2', UserName = 'testAgencyUser2@test.com', KOG_Role__c = 'Case Worker',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        User usr3 = new User(FirstName = 'testAgencyUser3', LastName = 'testAgencyUser3', UserName = 'testAgencyUser3@test.com', KOG_Role__c = 'Case Worker Supervisor',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        REAgencyLogin agencyLogin=new REAgencyLogin();
        REAgencyLogin.agencyUserExceptionCapture userExcep =REAgencyLogin.agencyLogin(usr2,'12345');
        REAgencyLogin.agencyUserExceptionCapture userExcep2 =REAgencyLogin.agencyLogin(usr3,'12345');
        System.assertEquals(userExcep.isExceptionFound, false,'Success');
        System.assertEquals(userExcep2.isExceptionFound, true,'Success');
    }
    //RE_Release 1.3 – ForceReviewer - Payal Dubela
    @isTest public static void testAsyncKog1(){ 
        List<Contact> listContact=[Select Id,PermissionsLevel__c,Email,Account.Name from Contact ];
        Account acc = new Account();
        acc.Id=listContact[0].AccountId;
        acc.Name=System.Label.RE_AgencyUserAccountName;
        update acc;
        User usr2 = new User(FirstName = 'testAgencyUser2', LastName = 'testAgencyUser2', UserName = 'testAgencyUser2@test.com', KOG_Role__c = 'Case Worker',LanguageLocaleKey = 'es-US',Email=listContact[0].Email);
        User usr3 = new User(FirstName = 'testAgencyUser3', LastName = 'testAgencyUser3', UserName = 'testAgencyUser3@test.com', KOG_Role__c = 'Case Worker Supervisor',LanguageLocaleKey = 'es-US',Email=listContact[0].Email);
        REAgencyLogin agencyLogin=new REAgencyLogin();
        REAgencyLogin.agencyUserExceptionCapture userExcep =REAgencyLogin.agencyLogin(usr3,'12345');
        REAgencyLogin.agencyUserExceptionCapture userExcep2 =REAgencyLogin.agencyLogin(usr2,'12345');
       
        System.assertEquals(userExcep.isExceptionFound, false,'Success');
        System.assertEquals(userExcep2.isExceptionFound, true,'Success');
        REAgencyLogin.updateAgencySSO(userExcep.usr,'12345');
    }
    @isTest public static void testcreateUserinSF(){ 
        String sRole = RE_GlobalConstants.CASE_WORKER_SUPERVISOR;
        List<String> csRoles = new List<String>();
        csRoles.add(sRole);
        Test.startTest();
        	Account acc = new Account();
            acc.Name= System.Label.RE_AgencyUserAccountName;
            acc.Applicable_Roles__c = sRole;
        	acc.recordTypeId = sREAccRecTypeId;
            insert acc;
            Contact con = new Contact();
        	con.FirstName = 'Test101';
            con.LastName = 'TestLastName';
            con.Email = 'Test101.TestLastName@test.com';
            con.recordTypeId = contactRecordTypeId;
        	con.MailingPostalCode = String.valueOf(RE_GlobalConstants.dZipCode_TEST);
        	con.PermissionsLevel__c = 'Admin';
        	con.Status__c = RE_GlobalConstants.STATUS_ACTIVE;
        	con.AccountId = acc.Id;
        	insert con;
        	AccountContactRelation acr = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE ContactId = :con.Id AND AccountId = :acc.Id];
        	User u;	
        	u = [SELECT Id, federationIdentifier, ContactId FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_AGENCY_USER_EMAIL_TEST LIMIT 1];
            User usr1 = REAgencyLogin.createUserinSF(u, '120982', sRole, csRoles);
        Test.stopTest();
        System.assertNotEquals(usr1, null, 'Success');
    }
}