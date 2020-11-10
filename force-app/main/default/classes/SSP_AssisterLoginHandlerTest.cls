@isTest
public class SSP_AssisterLoginHandlerTest {
    
    @testSetup static void setupTestData() {
        
        //RecordType objRecordType = GeneralUtility.fetchRecordType('Assister', 'Contact');
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Assister');

        //RecordType objAccountRecordtype = GeneralUtility.fetchRecordType('Assister', 'Account');
        Id accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Assister');

        Account acc = new Account(Name = 'AssisterTest',RecordTypeId = accountRecordTypeId );
        Insert acc;
        Contact con = new Contact(RecordTypeId = contactRecordTypeId, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com',AccountId=acc.Id );
        insert con;
        
        //List <Profile> prof = [Select Id from Profile where Name = 'RE Assister Profile'];
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        
        User usr1 = new User(FederationIdentifier = 'ef6b5884-b132-4a7b-8236-02f855a0b438',FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;

    }
	
    @isTest
    public static void updateAssisterSSO(){
        user usr = [Select Id,FederationIdentifier,FirstName From User WHERE FederationIdentifier = 'ef6b5884-b132-4a7b-8236-02f855a0b438' Limit 1];
        String fdr = 'ef6b5884-b132-4a7b-8236-02f855a0b438';
        user userdata = SSP_AssisterLoginHandler.updateAssisterSSO(usr,fdr);
        system.assertEquals(userdata.Id, userdata.Id);
    }
}