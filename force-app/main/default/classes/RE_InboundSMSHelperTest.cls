/**
* Class Name    : RE_InboundSMSHelperTest
* Owner         : Abhijeet Vaishnab 
* Created Date  : 09/25/2019
* Description   : 
 
**/
@IsTest
public class RE_InboundSMSHelperTest{
     @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount AND recordTypeId != null LIMIT 1];
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(lstCitizenAccounts[0].Id);
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.Phone='8297661639';
        citizenContact.MailingPostalCode='35321';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
         List<Consent__c> consentList=TestDataFactory.createConsent(1,true,new List<Contact>{citizenContact},lstCitizenAccounts);
     }
   
    @isTest
    static void TestRE_InboundSMS(){
        String cnsName = [Select Id,Name from Consent__c LIMIT 1].Name;
        Test.startTest();
        String responseBody = cnsName+' '+'Yes';
        RE_InboundSMSHelper.consumeResponse(responseBody,'+18297661639');
        Consent__c con=[SELECT Id,status__c from Consent__c LIMIT 1];
        System.assertEquals(con.Status__c,'Active','Positive Scenario');
        responseBody = cnsName+' '+'No';
        RE_InboundSMSHelper.consumeResponse(responseBody,'+18297661639');
        RE_InboundSMSHelper.consumeResponse(responseBody,'+18299861639');
        Test.stopTest();
    }
    
}