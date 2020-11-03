@isTest
public class RE_MessagingEndUserHandlerTest{
	/*
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
     @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        EmailSetting__c emailSettings= new EmailSetting__c();
        emailSettings.Name='Request to access resident profile';
        emailSettings.Is_on__c = true;
        insert emailSettings;
        EmailSetting__c emailSettingsVerbal= new EmailSetting__c();
        emailSettingsVerbal.Name='Verbal Consent Mail';
        emailSettingsVerbal.Is_on__c = true;
        insert emailSettingsVerbal;
        //Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCommunityProfileName];
        insert new Email_Text_Communication_Settings__c(Email_Communication__c=true,Text_Communication__c=true); 
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];  
        List<Contact> conList=new List<Contact>();       
        List<Account> citizenAccounts= TestDataFactory.createAccounts(1,false,citizenRecordTypeIdAccount);
        citizenAccounts[0].HasOptedOutOfAccount__c=false;
        insert citizenAccounts;
        
        conList = TestDataFactory.createContacts(1,false,contactCitizenRecordTypeId,new List<Id>{citizenAccounts[0].Id},true);
        conList[0].RecordtypeId=contactCitizenRecordTypeId;
        conList[0].Phone='7878567689';
        conList[0].Email='test@test.com';
        conList[0].MailingPostalCode='43332';
        conList[0].PreferredCommunicationMethod__c='Email';
         conList[0].Phone_Number__c = '(787) 856-7689';
        insert conList;  
        
        
        insert new TriggerSettings__c(Name='MessagingEndUserTrigger', IsActive__c =true);
  
    }
    
    @isTest
     public static void fetchClientDetailsTest(){
     
     List<MessagingChannel> lstmsgChnl = new List<MessagingChannel>();
         lstmsgChnl = [SELECT Id FROM MessagingChannel limit 1];
         MessagingEndUser msg = new  MessagingEndUser();
         if(lstmsgChnl.size()>0){
             msg.Name = '+17878567689';
             msg.MessagingChannelId = lstmsgChnl[0].Id;
             msg.MessageType = 'Text';
             msg.MessagingPlatformKey='+12762630445';
             msg.IsOptedOut = true;
             Test.startTest();
             insert msg;
        
     List<MessagingChannel__e> publishEvents = new List<MessagingChannel__e>();
     Contact cnt = [SELECT Id From Contact limit 1];
     publishEvents.add(new MessagingChannel__e(Phone__c = '(787) 856-7689', ContactId__c = cnt.Id));
       EventBus.publish(publishEvents);
       Test.stopTest();
     System.assertEquals(msg.IsOptedOut, true,'Positive Scenario');
        }
     }
     
     @isTest
     public static void fetchClientDetailsTestMS(){
     
      List<MessagingChannel> lstmsgChnl = new List<MessagingChannel>();
      lstmsgChnl = [SELECT Id FROM MessagingChannel limit 1];
      MessagingEndUser msg = new  MessagingEndUser();
         if(lstmsgChnl.size()>0){
             msg.Name='+17878567689';
             msg.MessagingChannelId = lstmsgChnl[0].Id;
             msg.MessageType='Text';
             msg.MessagingPlatformKey='+12762630445' ;
             Test.startTest();
             insert msg;              
       
     msg.IsOptedOut = true;
     msg.MessagingConsentStatus ='OptedOut';
     update msg;
       Test.stopTest();
     System.assertEquals(msg.IsOptedOut, true,'Positive Scenario');
     }
    }
	*/
}