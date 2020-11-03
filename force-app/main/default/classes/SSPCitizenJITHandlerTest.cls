@isTest
public class SSPCitizenJITHandlerTest {
     @testSetup static void setup() { 
       List<KOG_SAML_Attributes__c> samlattributes= new List<KOG_SAML_Attributes__c>();
       KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'needkogvisit',User_Field__c = '',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit',Data_Type__c = 'Text');
       samlattributes.add(kogsaml1);
       KOG_SAML_Attributes__c kogSaml2 = new KOG_SAML_Attributes__c(Name = 'firstname',User_Field__c = 'FirstName',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname',Data_Type__c = 'Text');
       samlattributes.add(kogsaml2);
       KOG_SAML_Attributes__c kogSaml3 = new KOG_SAML_Attributes__c(Name = 'Lastname',User_Field__c = 'lastname',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname',Data_Type__c = 'Text');
       samlattributes.add(kogsaml3);
       KOG_SAML_Attributes__c kogSaml4 = new KOG_SAML_Attributes__c(Name = 'LanguageLocaleKey',User_Field__c = 'LanguageLocaleKey',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference',Data_Type__c = 'Text');
       samlattributes.add(kogsaml4);
       KOG_SAML_Attributes__c kogSaml5 = new KOG_SAML_Attributes__c(Name = 'Username',User_Field__c = 'Username',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/username',Data_Type__c = 'Text');
       samlattributes.add(kogsaml5);
       KOG_SAML_Attributes__c kogSamlEmail = new KOG_SAML_Attributes__c(Name = 'Email',User_Field__c = 'Email',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/email',Data_Type__c = 'Text');
       samlattributes.add(kogSamlEmail);
       KOG_SAML_Attributes__c kogSaml6 = new KOG_SAML_Attributes__c(Name = 'csrole',User_Field__c = '',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',Data_Type__c = 'Text');
       samlattributes.add(kogSaml6);
       KOG_SAML_Attributes__c kogSaml7 = new KOG_SAML_Attributes__c(Name = 'FederationIdentifier',User_Field__c = 'federationidentifier',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/uniqueid',Data_Type__c = 'Text');
       samlattributes.add(kogSaml7);
       KOG_SAML_Attributes__c kogSaml18 = new KOG_SAML_Attributes__c(Name = 'isActive',User_Field__c = 'isActive',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/uniqueid',Data_Type__c = 'Boolean');
       samlattributes.add(kogSaml18);
       //KOG_SAML_Attributes__c kogSamAgent = new KOG_SAML_Attributes__c(Name = 'AgentId',User_Field__c = '',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/credential',Data_Type__c = 'Text');
       //samlattributes.add(kogSamAgent);
       insert samlattributes;
       WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name='MCI Entity Search',Certificate_Name__c='backyardnonprodmulecert',Source_System__c='Kog',Target_URL__c='https://ms-nonprod-lb.ky.gov/ky-re-mci-services-xapi-devlopment/MCI_WCFService/MciService.svc?wsdl',Time_Out__c=12000);
       insert mciConfig;
    }
   @isTest
   public static void createUserWithRole(){       
       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogSaml;
       User ur;
       User usr = [Select id from User where Id = :UserInfo.getUserId()];
       System.RunAs(usr) {
       Network networkRecord=RE_SharingByPassCtrl.getCommunityId('Benefind');
       PublicGroupAssignments__c setting = new PublicGroupAssignments__c();
       setting.Name = 'Citizen';
       setting.ProfileName__c = 'Citizen';
       insert setting;
       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Citizen');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Citizen');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Citizen');
       test.startTest();
           SSPCitizenJITHandler cpjit = new SSPCitizenJITHandler();
           ur=cpjit.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
           attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/uniqueid','12312'); 
           try{
               SSPCitizenJITHandler.JITException ex = new SSPCitizenJITHandler.JITException();
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
               ur.KOG_Role__c = 'Non Citizen';
               update ur;
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               //System.assertEquals(e.getMessage(),'ERR014');
           }
           attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','yes');
           try{
               cpjit.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               //System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
           try{
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               //System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
            
       test.stopTest();
       }
   }
   
   @isTest
   public static void createUserWithDifferentRole(){       
       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogSaml;
       User ur;
       Network networkRecord=RE_SharingByPassCtrl.getCommunityId('Benefind');
       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','DCBS - View Only');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'DCBS - View Only');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','DCBS - View Only,Eligibility & Benefit Inquiry User,Waiver Direct Service Provider Supervisor');
       User usr = [Select id from User where Id = :UserInfo.getUserId()];
       System.RunAs(usr) {
       test.startTest();
           SSPCitizenJITHandler cpjit = new SSPCitizenJITHandler();
           ur=cpjit.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
           //cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','yes');
           try{
               cpjit.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
           try{
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
       test.stopTest();
       }
   }
    @isTest
   public static void createUserWithAgent(){
       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogSaml;
       KOG_SAML_Attributes__c kogSamAgent = new KOG_SAML_Attributes__c(Name = 'AgentId',User_Field__c = '',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/credential',Data_Type__c = 'Text');
       insert kogSamAgent;
       User ur;
       Network networkRecord=RE_SharingByPassCtrl.getCommunityId('Benefind');
       Map<String, String> attributes = new Map<String, String>();
       String agentCreds=' <soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><Attribute>Value</Attribute><value>345</value></soap:Body> </soap:Envelope>';
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Agent');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/credential',agentCreds);
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Agent');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Agent');
       User usr = [Select id from User where Id = :UserInfo.getUserId()];
       System.RunAs(usr) {
       test.startTest();
           SSPCitizenJITHandler cpjit = new SSPCitizenJITHandler();
           ur=cpjit.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
           //cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','yes');
           try{
               cpjit.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
           try{
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
           }catch(Exception e){
               System.assert(e.getMessage().contains('MFARequiredCP'),true);
           }
       test.stopTest();
       }
   }
   @isTest
   public static void createUserWithRoleAdmin(){
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        // CP User Contact record type
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strContactRecordTypeName).getRecordTypeId();
        Contact objREAdminContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, 'test123456@test.com',RE_GlobalConstants.ADMIN_ROLE , contactRecordTypeId, true);
       User ur;
       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Community Partner Admin',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogsaml;
	   PublicGroupAssignments__c setting = new PublicGroupAssignments__c();
       setting.Name = 'Community Partner Admin';
       setting.ProfileName__c = 'Community Partner Admin';
       insert setting;
       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Community Partner Admin');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test123456@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCPadmin3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Community Partner Admin');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Admin');
       test.startTest();
           SSPCitizenJITHandler cpjit = new SSPCitizenJITHandler();
           try{
               
               
               Map<String,String> attrib = new Map<String,String>();
               attrib.put('isActive','true');
               JitHelper.parseSamlAttribute(attrib);
               cpjit.createUser(networkRecord.Id, networkRecord.Id,networkRecord.Id, '12312', attributes, null);
           }catch(Exception e){
               //System.assert(e.getMessage().contains('ERR011'),true);
           }
       
           
       test.stopTest();
   }
    
  @isTest
   public static void createUserWithInvalidRole(){       
       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Assister',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogSaml;
       User ur;
       User usr = [Select id from User where Id = :UserInfo.getUserId()];
       System.RunAs(usr) {
       Network networkRecord=RE_SharingByPassCtrl.getCommunityId('Benefind');
       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Assister');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen34234');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','17867534');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail76854@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername1244@test.com');
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Assister');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Assister');
       test.startTest();
           SSPCitizenJITHandler cpjit = new SSPCitizenJITHandler();  
           PublicGroupAssignments__c setting = new PublicGroupAssignments__c();
		   setting.Name = 'Assister';
		   setting.ProfileName__c = 'Assister';
		   insert setting;
           try{
               ur=cpjit.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'123125', attributes, null);
               attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/uniqueid','123125');           
               //cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123125', attributes, null);
               attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','');
               attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','');
               cpjit.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123125', attributes, null);
           }catch(Exception e){
               System.assert(true,e.getMessage());
           }
       test.stopTest();
       }
   }
   
}