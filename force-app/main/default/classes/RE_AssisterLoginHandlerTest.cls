@isTest
public class RE_AssisterLoginHandlerTest {
    
    @testSetup static void setupTestData() {
        /*
        RecordType objRecordType = GeneralUtility.fetchRecordType('Assister', 'Contact');
        RecordType objAccountRecordtype = GeneralUtility.fetchRecordType('Assister', 'Account');
        Account acc = new Account(Name = 'AssisterTest',RecordTypeId = objAccountRecordtype.Id );
        Insert acc;
        Contact con = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName', LastName = 'LastName',Email = 'test@email.com',AccountId=acc.Id );
        insert con;
        
        List <Profile> prof = [Select Id from Profile where Name = 'RE Assister Profile'];
        
        User usr1 = new User(FederationIdentifier = 'ef6b5884-b132-4a7b-8236-02f855a0b438',FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Username = con.Email+'.idetest',ContactId=con.Id,TimeZoneSidKey = 'America/New_York',EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id);
        insert usr1;
		*/
    }
	
    @isTest
    public static void updateAssisterSSO(){
        user usr = new user();//[Select Id,FederationIdentifier,FirstName From User WHERE FederationIdentifier = 'ef6b5884-b132-4a7b-8236-02f855a0b438' Limit 1];
        String fdr = 'ef6b5884-b132-4a7b-8236-02f855a0b438';
        user userdata = RE_AssisterLoginHandler.updateAssisterSSO(usr,fdr);
        //system.assertEquals(userdata.Id, userdata.Id);
    }
}