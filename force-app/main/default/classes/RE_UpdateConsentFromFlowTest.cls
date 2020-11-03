@isTest
public class RE_UpdateConsentFromFlowTest {
    
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
  
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
         List<Account> lstCitizenAccounts =  TestDataFactory.createAccounts(5,true, citizenRecordTypeIdAccount);
        
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 38.328732;
        citizenContact.ContactGeoLocation__Longitude__s = 85.764771; 
        citizenContact.MailingPostalCode='35271';
        insert citizenContact;
        
        List<Contact> lstcontact=new list<Contact>();
        lstcontact.add(citizenContact);
        List<Consent__c> lstconsent=TestDataFactory.createConsent(1,false,lstcontact,lstCitizenAccounts);
        lstconsent[0].Status__c = 'Pending';
        insert lstconsent;
        
        
    }
    @isTest
    public static void testMethod1(){
   
        Consent__c consentRec = [Select Id,Name,Client__c,Status__c FROM Consent__c LIMIT 1];        
       
        Test.startTest();
        
        Survey surveyRecord=new Survey();
        String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
        surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
     
        List<RE_UpdateConsentFromFlow.FlowInputs> testWrapList = new List<RE_UpdateConsentFromFlow.FlowInputs>();
        RE_UpdateConsentFromFlow.FlowInputs testWrap = new RE_UpdateConsentFromFlow.FlowInputs();
        testWrap.invitationId = surveyRecord.Id;
        testWrap.consentId = consentRec.Id;
        testWrap.contactId = consentRec.Client__c;
        testWrap.ConsentToText = 'True';
        testWrap.I_Agree = 'True';
        testWrap.MobilePhone = '1234567890';
        testWrap.Communication_Preference = 'Mobile Phone';
        testWrap.ConsentProvidedBy = 'Email';
        
        testWrapList.add(testWrap);
       
        RE_UpdateConsentFromFlow.UpdateConsentRecordsEnglish(testWrapList);
        System.assert(testWrapList[0].ConsentProvidedBy == 'Email','Success');
        Test.stopTest();
        
    }
    
     @isTest
    public static void testMethodFail(){
   
        Consent__c consentRec = [Select Id,Name,Client__c,Status__c FROM Consent__c LIMIT 1];        
       
        Test.startTest();
        
        Survey surveyRecord=new Survey();
        String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
        surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
     
        List<RE_UpdateConsentFromFlow.FlowInputs> testWrapList = new List<RE_UpdateConsentFromFlow.FlowInputs>();
        RE_UpdateConsentFromFlow.FlowInputs testWrap = new RE_UpdateConsentFromFlow.FlowInputs();
        testWrap.invitationId = surveyRecord.Id;
        //testWrap.consentId = consentRec.Id;
        //testWrap.contactId = consentRec.Client__c;
        testWrap.ConsentToText = 'True';
        testWrap.I_Agree = 'True';
        testWrap.MobilePhone = '1234567890';
        testWrap.Communication_Preference = 'Mobile Phone';
        testWrap.ConsentProvidedBy = 'Email';
        
        testWrapList.add(testWrap);
       try{
        RE_UpdateConsentFromFlow.UpdateConsentRecordsEnglish(testWrapList);
       }catch(Exception e){
           
       }
        RE_ClientSearchReqWrapper.RequestData tet = new RE_ClientSearchReqWrapper.RequestData('','SSN');
        System.assert(tet.SSN == '','Success');
        Test.stopTest();
        
    }
	
	  @isTest
    public static void testMethodFail2(){
   
        Consent__c consentRec = [Select Id,Name,Client__c,Status__c FROM Consent__c LIMIT 1];        
       
        Test.startTest();
        
        Survey surveyRecord=new Survey();
        String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
        surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
     
        List<RE_UpdateConsentFromFlow.FlowInputs> testWrapList = new List<RE_UpdateConsentFromFlow.FlowInputs>();
        RE_UpdateConsentFromFlow.FlowInputs testWrap = new RE_UpdateConsentFromFlow.FlowInputs();
        testWrap.invitationId = surveyRecord.Id;
        testWrap.consentId = consentRec.Id;
        //testWrap.contactId = consentRec.Client__c;
        testWrap.ConsentToText = 'True';
        testWrap.I_Agree = 'True';
        testWrap.MobilePhone = '1234567890';
        testWrap.Communication_Preference = 'Mobile Phone';
        testWrap.ConsentProvidedBy = 'Email';
        
        testWrapList.add(testWrap);
       try{
        RE_UpdateConsentFromFlow.UpdateConsentRecordsEnglish(testWrapList);
       }catch(Exception e){
           
       }
	   RE_MessageUtility.referralClosureSMS('','','','','','');
	   RE_MessageUtility.consentSMS('','','','','','','');
	   RE_ClientSearchReqWrapper.RequestData tet = new RE_ClientSearchReqWrapper.RequestData('','');
       System.assert(tet.SearchType == '','Success');
        Test.stopTest();
        
    }
    
    @isTest
    public static void testMethod2(){
        Consent__c consentRec = [Select Id,Name,Client__c,Status__c FROM Consent__c LIMIT 1];        
        Test.startTest();
        Survey surveyRecord=new Survey();
        String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
        surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
        List<RE_UpdateConsentFromFlow.FlowInputs> testWrapList = new List<RE_UpdateConsentFromFlow.FlowInputs>();
        RE_UpdateConsentFromFlow.FlowInputs testWrap = new RE_UpdateConsentFromFlow.FlowInputs();
        testWrap.invitationId = surveyRecord.Id;
        testWrap.consentId = consentRec.Id;
        testWrap.contactId = consentRec.Client__c;
        testWrap.ConsentToText = '';
        testWrap.I_Agree = 'True';
        testWrap.MobilePhone = '';
        testWrap.Communication_Preference = 'Email';
        testWrap.ConsentProvidedBy = 'Email';
        testWrapList.add(testWrap);
        RE_UpdateConsentFromFlow.UpdateConsentRecordsEnglish(testWrapList);
		RE_ClientSearchReqWrapper.RequestData tet = new RE_ClientSearchReqWrapper.RequestData('','Individualid');
        System.assert(tet.Individualid == '','Success');
        Test.stopTest();
      
    }
    
    @isTest
    public static void testMethod3(){
        Consent__c consentRec = [Select Id,Name,Client__c,Status__c FROM Consent__c LIMIT 1];        
        Test.startTest();
        Survey surveyRecord=new Survey();
        String jsonstring='{"attributes":{"type":"Survey","url":"/services/data/v47.0/sobjects/Survey/0Kd35000000005kCAA"},"Id":"0Kd35000000005kCAA","Name":"RE_Consent_Survey_1"}';
        surveyRecord=(Survey)System.JSON.deserialize(jsonstring,Survey.class);
        List<RE_UpdateConsentFromFlow.FlowInputs> testWrapList = new List<RE_UpdateConsentFromFlow.FlowInputs>();
        RE_UpdateConsentFromFlow.FlowInputs testWrap = new RE_UpdateConsentFromFlow.FlowInputs();
        testWrap.invitationId = surveyRecord.Id;
        testWrap.consentId = consentRec.Id;
        testWrap.contactId = consentRec.Client__c;
        testWrap.ConsentToText = 'False';
        testWrap.I_Agree = 'False';
        testWrap.MobilePhone = 'test';
        testWrap.Communication_Preference = 'Mobile Phone';
        testWrap.ConsentProvidedBy = 'Text';
        testWrapList.add(testWrap);
       
        RE_UpdateConsentFromFlow.UpdateConsentRecordsEnglish(testWrapList);
		RE_ClientSearchReqWrapper.RequestData tet = new RE_ClientSearchReqWrapper.RequestData('','CaseNumber');
        System.assert(tet.CaseNumber == '','Success');
        Test.stopTest();

    }

}