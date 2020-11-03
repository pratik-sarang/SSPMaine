@isTest
private class StaffHandlerTest {
    
    @isTest 
    static void testcreateUser() {   
        //TestDataFactory.testDataSetup();
        Profile profile;
        if(Schema.sObjectType.Profile.fields.ID.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
        profile = [Select Id, Name From Profile Where Name = 'RE United Way Staff' limit 1];
        }
        //User usr = TestDataFactory.createUser('tesal3', profile.Id,'wayStfuser@re.com','test@mail.com',false);
        User user1 = new User(Alias = 'alias1', IsActive=true,Email='userEmail1@test.com', FirstName='FirstName1', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en-US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='userName1@test.com', KOG_Role__c = 'UW Staff');
        User user2 = new User(Alias = 'alias2', IsActive=true,Email='userEmail2@test.com', FirstName='FirstName2', LastName='Testing2', EmailEncodingKey='UTF-8', LanguageLocaleKey='es-US', LocaleSidKey='es_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='userName2@test.com', KOG_Role__c = 'SF Production Support');
        Test.startTest();
        StaffHandler.staffExceptionCapture sec1 = StaffHandler.createUser(user1, '12345'); 
        StaffHandler.staffExceptionCapture sec2 = StaffHandler.createUser(user2, '123456'); 
        Test.stopTest();
        System.assertEquals(sec1.isExceptionFound,false);
        System.assertEquals(sec2.isExceptionFound,false);
    }
    
    @isTest 
    static void testUpdateUser() { 
        Profile profile;
        if(Schema.sObjectType.Profile.fields.ID.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
            profile = [Select Id, Name From Profile Where Name = 'RE United Way Staff' limit 1];
        }
        //User usr = TestDataFactory.createUser('tesal3', profile.Id,'wayStfuser@re.com','test@mail.com',false);
        User user1 = new User(Alias = 'alias1', IsActive=true,Email='userEmail1@test.com', FirstName='FirstName1', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles',FederationIdentifier = '12345xyzabc', UserName='userName1243@test123.com', KOG_Role__c = 'UW Staff');
        User user2 = new User(Alias = 'alias2', IsActive=true,Email='userEmail2@test.com', FirstName='FirstName2', LastName='Testing2', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='es_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles',FederationIdentifier = '123456abcxyz', UserName='userName2134@test123.com', KOG_Role__c = 'SF Production Support');
        List<User> usrList = new List<User>();
        usrList.add(user1);
        usrList.add(user2);
        if(Schema.sObjectType.User.fields.Alias.isCreateable() && Schema.sObjectType.User.fields.IsActive.isCreateable() && Schema.sObjectType.User.fields.Email.isCreateable()
          && Schema.sObjectType.User.fields.FirstName.isCreateable() && Schema.sObjectType.User.fields.LastName.isCreateable() && Schema.sObjectType.User.fields.EmailEncodingKey.isCreateable()
          && Schema.sObjectType.User.fields.LanguageLocaleKey.isCreateable() && Schema.sObjectType.User.fields.LocaleSidKey.isCreateable() && Schema.sObjectType.User.fields.ProfileId.isCreateable()
          && Schema.sObjectType.User.fields.TimeZoneSidKey.isCreateable() && Schema.sObjectType.User.fields.FederationIdentifier.isCreateable() && Schema.sObjectType.User.fields.UserName.isCreateable()){
            insert usrList;
        }
        Test.startTest();
        StaffHandler.updateUser(user1, '12345xyzabc'); 
        StaffHandler.updateUser(user2, '123456abcxyz'); 
        User tstusr = [SELECT ID from User where ID =: user1.id LIMIT 1];
        User tstusr2 = [SELECT ID from User where ID =: user2.id LIMIT 1];
        System.assertNotEquals(tstusr,null);
        System.assertNotEquals(tstusr2,null);
        Test.stopTest();
        
    }
    
}