/**
* Class        :  SSP_KOGServiceCreateACRService
* Description  :  SSP_KOGServiceCreateACRServiceTest
* @author      :  Deloitte
* @date        :  
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* -----------------------------------------------------------------------------------------------------------   
* Priyamvada                     08/18/2020                              Initial version
**/
@isTest
public class SSP_KOGServiceCreateACRServiceTest {
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
        con.AgentId__c = '12345678';
        insert con;
        AccountContactRelation acr = new AccountContactRelation(AccountId = acc1.Id, ContactId = con.Id, DCContactId__c = 123456, Roles = 'Insurance_Agent');
        insert acr;
        test.stopTest();
        }
    }
    
    @isTest static void testCallout() {   
        Test.setMock(WebServiceMock.class, new SSP_KOGServiceCreateACRServiceMockTest());
		SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRRequest request = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRRequest();
        RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Application', 'Account');
        Account acc = new Account(Name = 'testAcc');
        acc.RecordTypeId = objAccountRecordType.Id;
        insert acc;
        Account acc1 = new Account(Name = 'testAcc1');
        acc1.RecordTypeId = objAccountRecordType.Id;
        acc1.DCDataId__c = 123456;
        acc1.OrganizationUniqueId__c = '123456';
        Account acc2 = new Account(Name = 'testAcc2');
        acc2.RecordTypeId = objAccountRecordType.Id;
        acc2.DCDataId__c = 1234567;
		insert acc2;
        Account acc3 = new Account(Name = 'testAcc3');
        acc3.RecordTypeId = objAccountRecordType.Id;
        acc3.DCDataId__c = 1234567;
		insert acc3;
        
        Contact con = new Contact(FirstName =  'Sam', Lastname = 'Potts'); 
        RecordType objContactRecordType = GeneralUtility.fetchRecordType('Non_Citizen', 'Contact');
        con.RecordTypeId = objContactRecordType.Id;
        con.AccountId = acc.Id;
        con.AgentId__c = '12345678';
        insert con;
        Contact con1 = new Contact(FirstName =  'Sam1', Lastname = 'Potts1'); 
        con1.RecordTypeId = objContactRecordType.Id;
        con1.AccountId = acc.Id;
        con1.AgentId__c = con.Id;
        insert con1;
        Contact con2 = new Contact(FirstName =  'Sam2', Lastname = 'Potts2'); 
        con2.RecordTypeId = objContactRecordType.Id;
        con2.AccountId = acc2.Id;
        con2.KOGSourceId__c = con.Id;
        insert con2;
        AccountContactRelation acr = new AccountContactRelation(AccountId = acc2.Id, ContactId = con.Id, DCContactId__c = 123456, Roles = 'Insurance_Agent');
		acr.DCACRId__c = acc.Id;
        insert acr;
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = acc3.Id, ContactId = con.Id, DCContactId__c = 123456, Roles = 'Insurance_Agent');
		acr1.isDeleted__c = true;
        insert acr1;
        List<Account> accountList = new List<Account>();
        accountList.add(acc1);
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        contactList.add(con1);
        contactList.add(con2);
        List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
        accountContactList.add(acr);
        accountContactList.add(acr1);
        List<String> contactStringList = new List<String>();
        contactStringList.add(con.Id);
        request.accounts = accountList;
        request.contacts = contactList;
        request.accountContactRelations = accountContactList;
        SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse response = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse();
        response = SSP_KOGServiceCreateACRService.createACRRecord(request);
        SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse response1 = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse();
        response1 = SSP_KOGServiceCreateACRService.deleteACRFromContactIds(contactStringList);
        SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse response2 = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse();
        response2 = SSP_KOGServiceCreateACRService.deleteACRFromContactIds(null);
        SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse response3 = new SSP_KOGServiceCreateACRService.SSP_KOGServiceCreateACRResponse();
        response3 = SSP_KOGServiceCreateACRService.createACRRecord(null);
    }
}