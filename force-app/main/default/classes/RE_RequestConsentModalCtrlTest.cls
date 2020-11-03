/**
* Class Name    : RE_RequestConsentModalCtrlTest
* Owner         : DELOITTE
* Created Date  : 26/07/2019
* Description   : Test Class for RE_RequestConsentModalCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  26/07/2019  Abhijeet       Initial Version
*  26/09/2019  Payal          Added code for coverage update
**/
@isTest
public class RE_RequestConsentModalCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
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
        insert conList;  
        List<Consent__c> lstConsent = TestDataFactory.createConsent(1,true,conList,citizenAccounts);
    }
     @isTest
    public static  void fetchClientDetailsTest(){
        User u= [SELECT Id,Name FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        Test.startTest();
        List<Contact> conList1 = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        Account accnt = [SELECT Id, HasOptedOutOfAccount__c from Account Where Id=: conList1[0].AccountId];
        accnt.HasOptedOutOfAccount__c = false;
        Update accnt;
        List<Contact> conList = [SELECT Id,AccountId, OptOutInfoSharing__c FROM Contact where Id=:conList1[0].Id LIMIT 1];
        List<Consent__c> lstConsents = [SELECT Id from Consent__c limit 1];
        System.runAs(u){
            EmailSetting__c eml = new EmailSetting__c(Name='Consent Agreement Mail', Is_on__c = true);
            insert eml;
            RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.fetchClientDetails(conList[0].Id);
            List<String> lstCntId = new List<String>();
            lstCntId.add(lstConsents[0].Id);
            RE_RequestConsentModalCtrl.sendEmail(lstCntId);
            RE_RequestConsentModalCtrl.sendConsentForText(null, '');
            RE_RequestConsentModalCtrl.sendConsentForEmail(null, '');
            RE_RequestConsentModalCtrl.updateConsent(null, 'modeCommunication', null);
            RE_RequestConsentModalCtrl.updateConsentFromEmail('', false);
            RE_RequestConsentModalCtrl.fetchConsentRecord('');
            RE_RequestConsentModalCtrl.insertConsent('', null, '', '');
            RE_RequestConsentModalCtrl.getPickListValues('', '');
            RE_RequestConsentModalCtrl.getContactDetails('');
            RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest('', false, '', '', '', '', false);
            System.assertEquals(resp.isSuccessful, true,'Positive Scenario');
            
        }
        Test.stopTest();
        
    }
    @isTest
    public static  void sendConsentForTextTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST LIMIT 1];
        List<Contact> conList;
        List<Consent__c> lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        Contact con = TestDataFactory.createCitizenContact(RE_GlobalConstants.CONTACT_CITIZEN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, 'testCitizen123@test.com', 'testCitizen123@test.com' , contactCitizenRecordTypeId, true);
        Test.startTest();
        conList = [SELECT Id,Phone,Email,Name,PreferredCommunicationMethod__c FROM Contact WHERE Email = 'testCitizen123@test.com' LIMIT 1];
        System.runAs(u){
            RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.sendConsentForText(conList[0],lstConsent[0].Id);
            System.assertEquals(resp.isSuccessful, true,'Positive Scenario');
            resp = RE_RequestConsentModalCtrl.sendConsentForText(conList[0],null);
        }
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', conList[0].Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
        System.runAs(u){
           RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.sendConsentForText(conList[0],null);
        }
        lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        conList = [SELECT Id,Phone,Email,Name,PreferredCommunicationMethod__c FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        System.runAs(u){
            RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.sendConsentForText(conList[0],lstConsent[0].Id);
            System.assertEquals(resp.isSuccessful, true,'Positive Scenario');
            resp = RE_RequestConsentModalCtrl.sendConsentForText(conList[0],null);
            List<String> lstCntId = new List<String>();
            lstCntId.add(lstConsent[0].Id);
            RE_RequestConsentModalCtrl.sendEmail(lstCntId);
            
        }
        Test.stopTest();
        
    }
    @isTest
    public static  void sendConsentForEmailTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Consent__c> lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        List<Contact> conList = [SELECT Id,Phone,Email,Name,PreferredCommunicationMethod__c FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        Test.startTest();
            RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.sendConsentForEmail(conList[0],lstConsent[0].Id);
            System.assertEquals(resp.isSuccessful, true,'Positive Scenario');
            resp = RE_RequestConsentModalCtrl.sendConsentForEmail(conList[0],null);
        Test.stopTest();
        
    }
    
    @isTest
    public static  void sendConsentForEmailTest1(){
        
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Consent__c> lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        Test.startTest(); 
        lstConsent[0].ConsentLevel__c= '';
        update lstConsent;
        List<Contact> conList = [SELECT Id,Phone,Email,Name,PreferredCommunicationMethod__c FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.sendConsentForEmail(conList[0],lstConsent[0].Id);
        System.assertEquals(resp.isSuccessful, true,'Positive Scenario');
        resp = RE_RequestConsentModalCtrl.sendConsentForEmail(conList[0],null);
        Test.stopTest();
        
    }
    
    @isTest
    public static  void updateConsentFromEmailTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Consent__c> lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        Test.startTest();
        List<Contact> conList = [SELECT Id FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.updateConsentFromEmail(lstConsent[0].id,true);
        System.assertEquals(resp.isSuccessful, true);
        RE_RequestConsentModalCtrl.getContactDetails(conList[0].Id);
        System.runAs(u){
            List<Consent__c> lstConsentEmpty = new List<Consent__c>();
            String modeCommunication = 'Text';
            RE_RequestConsentModalCtrl.getConsents();
            RE_RequestConsentModalCtrl.getPickListValues('Consent__c','Status__c');
            
            RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest(lstConsent[0].id,true,conList[0].Id,'test@test.com','6383','Email',true);
            RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest('',true,conList[0].Id,'test@test.com','6383','Email',false);
        }
        Test.stopTest();
        
    }
    @isTest
    public static  void updateConsentFromVerbalTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Consent__c> lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        List<Contact> conList=new List<Contact>();
        Test.startTest();        
        conList = [SELECT Id FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        System.runAs(u){
            List<Consent__c> lstConsentEmpty = new List<Consent__c>();
            
            RE_RequestConsentModalCtrl.getConsents();
            RE_RequestConsentModalCtrl.getPickListValues('Consent__c','Status__c');
            RE_RequestConsentModalCtrl.getContactDetails(conList[0].Id);
            RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest(lstConsent[0].id,true,conList[0].Id,'test@test.com','6383','Email',true);     
        }
        RE_CreateLightningServerResponse resp1=RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest('',true,conList[0].Id,'test@test.com','6383','Email',false);            
        System.assertEquals(resp1.isSuccessful, true);
        lstConsent = [SELECT Id FROM Consent__c LIMIT 1];
        conList = [SELECT Id,Phone,Email,Name, FirstName, LastName, BirthDate, Gender__c, PreferredCommunicationMethod__c FROM Contact WHERE RecordTypeId=: contactCitizenRecordTypeId LIMIT 1];
        System.runAs(u){
            RE_ClientSearchResponse.ClientData cntDt = new RE_ClientSearchResponse.ClientData();
            cntDt.individualId = 1;
            cntDt.mciId = 2;
            cntDt.firstName ='Test67';
            cntDt.lastName = 'Test867';
            cntDt.gender ='M';
            cntDt.dob = System.Today();
            cntDt.email = 'test@test.com';
            cntDt.phoneNumber ='8888888888';
            cntDt.preferredContactMethodCode = 'Email';
            
            RE_ClientsHelper.DataTableWrapper dtd = new RE_ClientsHelper.DataTableWrapper(cntDt);
            WebServiceSettings__c wsc = new WebServiceSettings__c(Name='MCI Client Search', Source_System__c='test');
            insert wsc;
             WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name = 'MCI Entity Search');
             insert mciConfig;
            RE_RequestConsentModalCtrl.createContactForIEESData(Json.Serialize(dtd));
          }
            RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.updateConsentOnVerbalRequest(lstConsent[0].id,true,conList[0].Id,'test@test.com','6383','Email',true);
            System.assertEquals(resp.isSuccessful, true,'Positive Scenario'); 
                
       
        Test.stopTest();
        
    }
     @isTest
    public static  void fetchKogUrlTest(){
        KOGWebservice__c objKOG = new KOGWebservice__c();
        objKOG.Name = 'KOG Citizen';
        objKOG.ApplicationName__c = 'DEV3 KHBE Self Service Portal';
        objKOG.Role__c = 'Citizen';
        objKOG.Certificate__c = 'backyardnonprodmulecert';
        objKOG.EndURL__c = 'http://abc.com';
        objKOG.KOG_Login_URL__c = 'http://abc.com';
        objKOG.KOG_Registration_URL__c = 'http://abc.com';
        objKOG.KOG_URL__c = 'http://abc.com';
        insert objKOG;
        Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        Test.startTest(); 
        RE_CreateLightningServerResponse resp =RE_RequestConsentModalCtrl.fetchKogURL();
        System.assertEquals(resp.isSuccessful, false,'Positive Scenario'); 
        Test.stopTest();
        
    }
    /******************************************************************************************
    * @author       Venkat Korra
    * @date         08/31/2020
    * @methodname   testExceptions
    * @description  This method is used to test exceptions
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testExceptions()
    {
        User cpUser= [SELECT Id, ContactId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST LIMIT 1];
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Test.startTest();
        String strClientId;
        System.runAs(cpUser){
            try{
                RE_CreateLightningServerResponse resp = RE_RequestConsentModalCtrl.fetchClientDetails(strClientId);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
            try{
                RE_CreateLightningServerResponse resp1 = RE_RequestConsentModalCtrl.updateConsent(null, strClientId, null);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
        }
        Test.stopTest();
    }
}