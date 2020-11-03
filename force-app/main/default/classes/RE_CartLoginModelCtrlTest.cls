/**
* Class Name    : RE_CartLoginModelCtrlTest{
* Owner         : DELOITTE
* Created Date  : 12/02/2019
* Description   : Cart Login Model Controller test class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  12/02/2019  Kojashree       Initial Version
*  
**/

@isTest
public class RE_CartLoginModelCtrlTest {
    
    @testSetup static void testSetupKOGServiceData(){
       
        TestDataFactory.testDataSetup();
         Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
         Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
   
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='33222';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   

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
    }

    @isTest
    public static void fetchKogURLTestExcptn(){
        Test.startTest();
        RE_CreateLightningServerResponse response = RE_CartLoginModelCtrl.fetchKogURL();
        system.assert(response.isSuccessful == false, 'Success');
        Test.stopTest();
    }
    
    @isTest
    public static void fetchKogURLTest(){
        
        Test.setMock(WebServiceMock.class, new tempuriOrgGateWayRedirectMock());
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
			
            result = RE_CartLoginModelCtrl.fetchKogURL();
            System.assert(result.isSuccessful == false,'Success');
        }
        Test.stopTest();
     
         
    }
    
}