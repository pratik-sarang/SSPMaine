/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_CitizenNonCitizenJITHandlerTest
*   Created By   :  CHFS
*   Created Date :  08/25/2020 
*   Description :   This class acts as a test class for RE_CitizenNonCitizenJITHandler
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date              Description
*   * ------------------------------------------------------------------------------------                 
*     Venkat Korra                08/25/2020        Initial Version
*****************************************************************************************************************************/
@isTest(SeeAllData=false)
public class RE_CitizenNonCitizenJITHandlerTest {
    
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
        List<KOGRoleMapping__mdt> kogRoleMapping = [SELECT Id, Role_Name__c, Related_Permission_Sets__c, MasterLabel FROM KOGRoleMapping__mdt WHERE Role_Name__c = 'Citizen'];
        
    }
    
    @isTest
    public static void createUserWithRole(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Citizen');
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Citizen');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Citizen');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Citizen');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','yes');
        try{
            jitHandler.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('MFARequiredCP'),true);
        }
        attributes.remove('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit');
        try{
            jitHandler.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
        }catch(Exception e){
        }
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','UW Staff');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        try{
            jitHandler.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'123123', attributes, null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR001'),true);
        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRole2(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Citizen');
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Citizen');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Citizen');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Citizen');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','yes');
        try{
            jitHandler.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('MFARequiredCP'),true);
        }
        try{
            jitHandler.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
        }catch(Exception e){
        }
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','UW Staff');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','UW Staff');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        try{
            jitHandler.createUser(networkRecord.Id,networkRecord.Id,networkRecord.Id,'123123', attributes, null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('ERR001'),true);
        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRoleAssiter(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Assister', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Assister',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Assister');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Assister');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Assister');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {
            
        }

        test.stopTest();
    }
    @isTest
    public static void createUserWithRoleCom(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Community Partner Admin', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Community Partner Admin',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Admin');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Community Partner Admin');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Community Partner Admin');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {

        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRolePartner(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Community Partner Staff', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Community Partner Staff',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Community Partner Staff');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Community Partner Staff');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Community Partner Staff');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {

        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRoleSupervisor(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = RE_GlobalConstants.CASE_WORKER_SUPERVISOR, PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = RE_GlobalConstants.CASE_WORKER_SUPERVISOR,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {

        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRoleCaseWorker(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Case Worker', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Case Worker',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Case Worker');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Case Worker');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Case Worker');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {

        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithRoleUnknown(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'DeloitteTest', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'DeloitteTest',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','DeloitteTest');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','DeloitteTest');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'DeloitteTest');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        try{
            ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        } catch(Exception e) {
        }
        test.stopTest();
    }
    @isTest
    public static void createUserWithoutRoleCitizen(){
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Citizen');
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Citizen');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','Test Citizen');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','test1234@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername123@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Citizen');
        test.startTest();
            RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
            try{
                jitHandler.createUser(networkRecord.Id, networkRecord.Id,networkRecord.Id,'12312',attributes,''); 
            }catch(Exception e){
                System.assert(e.getMessage().contains('ERR001'),true);  
            }
        test.stopTest();
    }

    @isTest
    public static void updateUserWith(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Citizen');
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        User ur;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',null);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role','Citizen');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),'Citizen');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(ur.Id,networkRecord.Id,networkRecord.Id,networkRecord.Id,'12312', attributes, null);
        }catch(Exception e){
        }
        
        test.stopTest();
    }
    @isTest
    public static void updateUserDataPartner(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN);
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/needkogvisit','No');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/firstname','TestCitizen3423');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/lastname','1786753');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/languagepreference','en-US');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/email','testemail7685@test.com');
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/username','testussername12@test.com');
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),SSP_GlobalConstants.COMMUNITY_PARTNER_ADMIN);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        
        test.stopTest();
    }
    @isTest
    public static void updateUserDataPartnerStaff(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF);
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),SSP_GlobalConstants.COMMUNITY_PARTNER_STAFF);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        test.stopTest();
    }
    @isTest
    public static void updateUserDataCaseSupervisor(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = RE_GlobalConstants.CASE_WORKER_SUPERVISOR,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),RE_GlobalConstants.CASE_WORKER_SUPERVISOR);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        test.stopTest();
    }
    @isTest
    public static void updateUserDataCaseWorker(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = RE_GlobalConstants.CASE_WORKER);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = RE_GlobalConstants.CASE_WORKER,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',RE_GlobalConstants.CASE_WORKER);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',RE_GlobalConstants.CASE_WORKER);
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),RE_GlobalConstants.CASE_WORKER);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        test.stopTest();
    }
    @isTest
    public static void updateUserDataAssister(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = RE_GlobalConstants.ASSISTER);
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = RE_GlobalConstants.ASSISTER,User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles',RE_GlobalConstants.ASSISTER);
        attributes.put('http://schemas.microsoft.com/ws/2008/06/identity/claims/role',RE_GlobalConstants.ASSISTER);
        System.assertEquals(attributes.get('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),RE_GlobalConstants.ASSISTER);
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        test.stopTest();
    }

    @isTest
    public static void updateUserDataAgent(){
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        insert new PublicGroupAssignments__c(name = 'Agent');
        List<KOG_SAML_Attributes__c> samlattributes1= new List<KOG_SAML_Attributes__c>();
        KOG_SAML_Attributes__c kogSaml1 = new KOG_SAML_Attributes__c(Name = 'Citizen',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml1);
        KOG_SAML_Attributes__c kogSaml2 = new KOG_SAML_Attributes__c(Name = 'AgentId',User_Field__c = 'KOG_Role__c',SAML_Attribute__c = '1',Data_Type__c = 'Text');
        samlattributes1.add(kogSaml2);
        insert samlattributes1;
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id, FirstName = 'FirstName12', LastName = 'LastName12',Email = 'test12@email.com' );
        insert con1;
        List <Profile> prof = [Select Id from Profile where Name = 'RE Citizen Profile'];
        User usr = new User(FirstName = 'FirstName',LastName = 'LastName',Email = 'test@test.com',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
        Username = con1.Email+'.idetest',ContactId=con1.Id,TimeZoneSidKey = 'America/New_York',
        EmailEncodingKey = 'UTF-8',Alias='test543',ProfileId=prof[0].Id,FederationIdentifier= '123');
        insert usr;
        Network networkRecord=RE_SharingByPassCtrl.getCommunityId(RE_GlobalConstants.CommunityName);
        
        Map<String, String> attributes = new Map<String, String>();
        String sbody =  '         '  + 
        '   <env:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">  '  + 
        '   <env:Body>  '  + 
        '   <env:Fault>  '  + 
        '   <faultcode>env:Server</faultcode>  '  + 
        '  <faultstring>Internal Error (from server)</faultstring></env:Fault></env:Body></env:Envelope>  ' ; 
        attributes.put('1',sbody);
        attributes.put('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles','Agent');
        System.assertEquals(attributes.get('http://schemas.chfs.ky.gov/kog/v1/identity/claims/csroles'), 'Agent');
        test.startTest();
        RE_CitizenNonCitizenJITHandler jitHandler = new RE_CitizenNonCitizenJITHandler();
        //ur=jitHandler.createUser(networkRecord.Id,networkRecord.Id, networkRecord.Id,'12312', attributes, null);
        try{
            jitHandler.updateUser(null,networkRecord.Id,networkRecord.Id,networkRecord.Id,'123', attributes, null);

        }catch(Exception e) {

        }
        
        test.stopTest();
    }
}