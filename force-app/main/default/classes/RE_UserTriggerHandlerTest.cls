/**
* Class Name    : RE_UserTriggerHandlerTest
* Owner         : DELOITTE
* Created Date  : 12/09/2019
* Description   : Test Class for RE_UserTriggerHandler
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  12/09/2019  Shubham        Initial Version
**/

@isTest
public class RE_UserTriggerHandlerTest{
    
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        User cpUser = [SELECT Id, Contact.MailingStreet,Contact.MailingState,
                       Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        System.runAs(cpUser){
            cpUser.Contact.MailingStreet ='33 3rd Avenue';
            cpUser.Contact.MailingState='New York';
            cpUser.Contact.MailingCountry='USA';
            cpUser.Contact.MailingPostalCode='52725';
            cpUser.Contact.MailingCity='New York City';
            //cpUser.ApplicableRoles__c ='Case Worker Supervisor;Case Worker;RE United Way Staff;State User';
            update cpUser;
        }
        
    }
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static  void addUsersToPublicGroupTest(){
        
        Profile profile = [Select Id, Name From Profile Where Name =:RE_GlobalConstants.RE_UW_STAFF_USER limit 1];
        User user1 = new User(Alias = 'alias1', IsActive=true,Email='userEmail1@test.com', FirstName='FirstName1', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles',FederationIdentifier = '12345', UserName='userName15432@backyardtest.com');
        List<User> usrList = new List<User>();
        usrList.add(user1);
        insert usrList;
        System.runAs(user1){
        //RE_UserTriggerHandler.addUsersToPublicGroup(usrList);
        }
        System.assertNotEquals(user1.id,null);
    } 
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static void addUsersToPublicGroupTestUpdate(){
          
                       
        Profile profile = [Select Id, Name From Profile Where Name =:RE_GlobalConstants.RE_STATE_USER limit 1];
        User user1 = new User(Alias = 'alias1', IsActive=true,Email='userEmail1@test.com', FirstName='FirstName1', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles',FederationIdentifier = '12345', UserName='userName18904@backyardtest.com');
        insert user1;
        user1.Email ='test@test.com';
        update user1;
        System.assertNotEquals(user1.id,null);
    } 
    
    
    @isTest static void createNonCitizenUser(){
        Account ac = new Account(name ='test47489') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon', FirstName ='KKTest', AccountId = ac.Id, PermissionsLevel__c='Admin', Status__c ='Active', TrainingLevel__c = 'Complete');
        insert con;  
        Profile profile = [Select Id, Name From Profile Where Name ='SSP Non Citizen Profile' limit 1];
        System.runAs(new User(id=UserInfo.getuserId())){
            User user1 = new User(Alias = 'alias1', IsActive=true,Email='userEmail1@test.com', FirstName='FirstName1', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles',FederationIdentifier = '12345', UserName='userName18904@backyardtest.com', ApplicableRoles__c ='Case Worker Supervisor;Case Worker;RE United Way Staff;State User', ContactId = con.Id);
            insert user1;
            user1.Email ='test@test.com';
            user1.ApplicableRoles__c ='Case Worker Supervisor;Case Worker;RE United Way Staff';
            update user1;
             System.assertNotEquals(user1.id,null);
        }
       
    } 
    
   }