@isTest
public class SSP_CommunityPartnerLoginTest {
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
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock());
        
        List<Contact> listContact1=[Select Id,PermissionsLevel__c,Email,Account.Name,Name,FirstName,LastName,IsClaim__c from Contact LIMIT 1];
        Set<Contact> setCon = new Set<Contact>(listContact1);
        List<Contact> listContact = new List<Contact>(setCon);
        User usr2 = new User(FirstName = 'testUser4', LastName = 'testUser4', UserName = 'testUser4@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        //User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        SSP_CommunityPartnerLogin communityLogin=new SSP_CommunityPartnerLogin();
        communityLogin.sendEmailtoCommunityPartner(listContact);
        SSP_CommunityPartnerLogin.cpUserExceptionCapture userExcep =SSP_CommunityPartnerLogin.communityPartnerLogin(usr2,'12345');
        //SSP_CommunityPartnerLogin.cpUserExceptionCapture userExcep2 =SSP_CommunityPartnerLogin.communityPartnerLogin(usr3,'12346');
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
    @isTest public static void testAsyncKog1(){ 
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SSP_KOGInquiryMock3());
        
        List<Contact> listContact=[Select Id,PermissionsLevel__c,Email,Account.Name,Name,FirstName,LastName,IsClaim__c from Contact ];
        
        User usr2 = new User(FirstName = 'testUser2', LastName = 'testUser2', UserName = 'testUser2@test.com', KOG_Role__c = 'Community Partner Staff',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        User usr3 = new User(FirstName = 'testUser3', LastName = 'testUser3', UserName = 'testUser3@test.com', KOG_Role__c = 'Community Partner Admin',LanguageLocaleKey = 'en-US',Email=listContact[0].Email);
        SSP_CommunityPartnerLogin communityLogin=new SSP_CommunityPartnerLogin();
        communityLogin.sendEmailtoCommunityPartner(listContact);
        SSP_CommunityPartnerLogin.cpUserExceptionCapture userExcep =SSP_CommunityPartnerLogin.communityPartnerLogin(usr2,'12345');
        SSP_CommunityPartnerLogin.cpUserExceptionCapture userExcep2 =SSP_CommunityPartnerLogin.communityPartnerLogin(usr3,'12345');
        Test.stopTest();
        System.assertEquals(userExcep.isExceptionFound, true,'Success');
    }
}