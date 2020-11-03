@isTest
public class RECommunityPartnerLoginTest {
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         07/1/2019
* @methodname   setupTestData
* @description  This method is used to create test records for all test methods
* @param        none
* @return       none
********************************************************************************************/
    @testSetup static void testDataSetup(){
        TestDataFactory.testDataSetup();
        
    }
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest public static void testAsyncKog(){ 
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c from Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c from Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        User usr2 = new User( FirstName = 'testUser2', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'en-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User( FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com',  KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'en-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        Test.startTest();
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();        
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock3());
        communityLogin.sendEmailtoCommunityPartner(listContact);
        RECommunityPartnerLogin.cpUserExceptionCapture userExcep =RECommunityPartnerLogin.communityPartnerLogin(usr2,'12345', 'Community Partner Staff');
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest public static void testAsyncKog1(){ 
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c,IsClaim__c FROM Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        User usr2 = new User(FirstName = 'testUser2', FederationIdentifier='test', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        Test.startTest();
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock2());        
        communityLogin.sendEmailtoCommunityPartner(listContact);
        RECommunityPartnerLogin.cpUserExceptionCapture userExcep =RECommunityPartnerLogin.communityPartnerLogin(usr2,'12345', 'Community Partner Staff');
        RECommunityPartnerLogin.cpUserExceptionCapture userEx = new RECommunityPartnerLogin.cpUserExceptionCapture();
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
    // Venkat: RE Security Changes
    @isTest public static void testSendEmailtoCommunityPartner(){
        Test.startTest();
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        STring accId;
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
            accId = cnt.AccountId;
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        
        List<Contact> lstContact = new List<Contact>();
        Contact cnt = new Contact();
        cnt.FirstName = 'testUser2';
        cnt.LastName = 'testUser2';
        cnt.Phone = '9303838908';
        cnt.PermissionsLevel__c = 'Admin';
        cnt.Email = 'test@test.com';
        cnt.AccountId =accId;
        insert cnt;
        lstContact.add(cnt);
        
        User usr2 = new User( FirstName = 'testUser2', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff Test',LanguageLocaleKey = 'en-US',Email=lstContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User( FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com',  KOG_Role__c = 'Community Partner Admin Test',LanguageLocaleKey = 'en-US',Email=lstContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        
        
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();        
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock());
        communityLogin.sendEmailtoCommunityPartner(lstContact);
        
        Test.stopTest();
    }
    @isTest public static void testAsyncKog2(){ 
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c,IsClaim__c FROM Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        User usr2 = new User(FirstName = 'testUser2', FederationIdentifier='test', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        Test.startTest();
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock());        
        communityLogin.sendEmailtoCommunityPartner(listContact);
        RECommunityPartnerLogin.cpUserExceptionCapture userExcep =RECommunityPartnerLogin.communityPartnerLogin(usr2,'12345', 'Community Partner Staff');
        RECommunityPartnerLogin.cpUserExceptionCapture userEx = new RECommunityPartnerLogin.cpUserExceptionCapture();
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
   @isTest public static void testAsyncKog3(){ 
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        User usr2 = new User(FirstName = 'testUser2', FederationIdentifier='test', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        Test.startTest();
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();
        SSP_KOGInquiryMock mockClass= new SSP_KOGInquiryMock();
        mockClass.isErrorScenario=true;
        Test.setMock(WebServiceMock.class,mockClass);        
        communityLogin.sendEmailtoCommunityPartner(listContact);
        RECommunityPartnerLogin.cpUserExceptionCapture userExcep =RECommunityPartnerLogin.communityPartnerLogin(usr2,'12345', 'Community Partner Staff');
        RECommunityPartnerLogin.cpUserExceptionCapture userEx = new RECommunityPartnerLogin.cpUserExceptionCapture();
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
    @isTest public static void testAsyncKog4(){ 
        Map<Id, Account> lstAccnts = new Map<Id, Account>();
        List<Contact> listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        for(Contact cnt : listContact){
            Account acc = new Account(Id = cnt.AccountId, Applicable_Roles__c ='Community Partner Staff');
            lstAccnts.put(cnt.AccountId, acc);
        }
        update lstAccnts.values();
        listContact=[Select Id,Name,FirstName,LastName,Phone,PermissionsLevel__c,Email,Account.Name,AccountId, Account.Applicable_Roles__c FROM Contact LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Applicable_Roles__c FROM Account WHERE Id IN: lstAccnts.keySet()];
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles 
                                                FROM AccountContactRelation 
                                                WHERE AccountId IN: lstAcc AND ContactId IN: listContact];
        acrList[0].Roles = 'Community Partner Admin';
        acrList[1].Roles = 'Community Partner Staff';
        update acrList;
        User usr2 = new User(FirstName = 'testUser2', FederationIdentifier='test', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Staff');
        User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'es-US',Email=listContact[0].Email, ApplicableRoles__c ='Community Partner Admin');
        Test.startTest();
        RECommunityPartnerLogin communityLogin=new RECommunityPartnerLogin();
        SSP_KOGInquiryMock2 mockClass= new SSP_KOGInquiryMock2();
        mockClass.isErrorScenario=true;
        Test.setMock(WebServiceMock.class, mockClass);        
        communityLogin.sendEmailtoCommunityPartner(listContact);
        RECommunityPartnerLogin.cpUserExceptionCapture userExcep =RECommunityPartnerLogin.communityPartnerLogin(usr2,'12345', 'Community Partner Staff');
        RECommunityPartnerLogin.cpUserExceptionCapture userEx = new RECommunityPartnerLogin.cpUserExceptionCapture();
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
}