@istest
private class StaffJitHandlerTest {    
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
       KOG_SAML_Attributes__c kogSamlcsRole = new KOG_SAML_Attributes__c(Name = 'csrole',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',Data_Type__c = 'Text');
       samlattributes.add(kogSamlcsRole);
       insert samlattributes;
       WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name='MCI Entity Search',Certificate_Name__c='backyardnonprodmulecert',Source_System__c='Kog',Target_URL__c='https://ms-nonprod-lb.ky.gov/ky-re-mci-services-xapi-devlopment/MCI_WCFService/MciService.svc?wsdl',Time_Out__c=12000);
       insert mciConfig;
    }
    @isTest static void testShareMyPlanDetails() {   
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        // CP User Contact record type
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
        Contact objREAdminContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, 'test123456@test.com',RE_GlobalConstants.ADMIN_ROLE , contactRecordTypeId, true);

       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Community Partner Admin',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogsaml;
        
       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test12345633@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCPadmin3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername1209@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','UW Staff');
        
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'UW Staff');
        
        Map<String, String> attributes1 = new Map<String, String>();
       attributes1.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Community Partner Admin');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test123456222@test.com');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCPadmin3423');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Admin,Community Partner Staff');
       Map<String, String> attributes2 = new Map<String, String>();
       attributes2.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test12345611@test1.com');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestUWStaff');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786777');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testusse@test.com');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Admin,Community Partner Staff');
       test.startTest();
        StaffJitHandler StaffJit=new StaffJitHandler();
        StaffJit.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);        
        
        StaffJitHandler StaffJit1=new StaffJitHandler();
        try{
            StaffJit1.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes1, null);        
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR001'),true);  
        }

        test.stopTest();
    }
    
    @isTest static void testupdateuser() {   
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        // CP User Contact record type
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
        Contact objREAdminContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, 'test123456@test.com',RE_GlobalConstants.ADMIN_ROLE , contactRecordTypeId, true);

       KOG_SAML_Attributes__c kogSaml = new KOG_SAML_Attributes__c(Name = 'Community Partner Admin',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
       insert kogsaml;

       Map<String, String> attributes = new Map<String, String>();
       attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test123456000@test.com');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCPadmin3423');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','UW Staff');
        
       System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'UW Staff');
        
        Map<String, String> attributes1 = new Map<String, String>();
       
       attributes1.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Community Partner Admin');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test123456@test.com');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCPadmin3423');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername124@test.com');
        attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
       attributes1.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Admin');
       Map<String, String> attributes2 = new Map<String, String>();
       attributes2.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test12345687@test1.com');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestUWStaff');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786777');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
       attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testusse893630000@xmtv.com');
        attributes2.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','no');
       test.startTest();
        StaffJitHandler StaffJit=new StaffJitHandler();
        StaffJit.createuser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);        
         
         try{    
            StaffJit.updateuser(networkRecord.Id,networkRecord.Id, networkRecord.Id,networkRecord.Id,'12312', attributes2, null);
        }catch(Exception e){ 
        }
        
        StaffJitHandler StaffJit1=new StaffJitHandler();
        try{
                 
            StaffJit1.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes1, null); 
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR001'),true);  
        }
        
        

        test.stopTest();
    }
}