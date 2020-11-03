/**
* Class Name    : RE_ClientDetailsCtrlTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_ClientDetailsCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/06/2019  Payal       Initial Version
**/
@isTest
public class RE_ClientDetailsCtrlTest {
    
    static Id contactCitizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Account> accList = [SELECT Id FROM Account LIMIT 3];
        List<Contact> conList=new List<Contact>();    
        List<Account> citizenAccounts= TestDataFactory.createAccounts(1,false,contactCitizenRecordTypeIdAccount);
        citizenAccounts[0].HasOptedOutOfAccount__c=false;
        insert citizenAccounts;
        
        conList = TestDataFactory.createContacts(1,false,contactCitizenRecordTypeId,new List<Id>{citizenAccounts[0].Id},true);
        conList[0].RecordtypeId=contactCitizenRecordTypeId;
        conList[0].MailingPostalCode='44454';
        conList[0].Email='citizenDummy@test.com';
        insert conList;  
        List<Contact_Mapping__c> listConMap = TestDataFactory.createContactMappingRecords(1,true,conList);
        REIntegrationEndpoints__c endpointsetting= new REIntegrationEndpoints__c();
        endpointsetting.Name='IEESClientDetails';
        endpointsetting.Content_Type__c='application/JSON';
        endpointsetting.Http_Method_Type__c='GET';
        endpointsetting.Endpoint_URI__c='http://www.testendpointIEES.com';
        endpointsetting.Is_Mock_Response_Enabled__c=false;
        endpointsetting.Is_Cert_Required__c=false;
        endpointsetting.Certificate_Name__c='test'; 
        insert endpointsetting;

        List<Resource__c> resourceList = [SELECT Id FROM Resource__c WHERE Organization__c=:accList[0].Id LIMIT 3];
        List<Referral__c> referralList=TestDataFactory.createReferral(2,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,conList[0].Id,accList,resourceList);
        // Assessment records
         Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        List<Assessment__c> lstAssessment = TestDataFactory.createAssessmentTemplateRecords(1,true,parentAssessRecTypeId);
        List<Question__c> lstQuestions = TestDataFactory.createQuestionsRecords(1,true,lstAssessment);
        List<AnswerChoice__c> lstAnsChoice = TestDataFactory.createAnswerChoiceRecords(1,true,lstQuestions);
        WebServiceSettings__c mciConfig = new WebServiceSettings__c(Name= 'MCI Entity Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'abc');
        insert mciConfig;
        WebServiceSettings__c mciConfig1 = new WebServiceSettings__c(Name= 'MCI Client Search',Certificate_Name__c = 'cert',Target_URL__c='https://www.abc.com',Time_Out__c=90000, Source_System__c= 'HBE');
        insert mciConfig1; 
        REIntegrationCodes__c intCode=new REIntegrationCodes__c(Name='SuccessCode',Code__c='SDH0000');
        insert intCode;
    }
    
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/11/2019
    * @methodname   fetchClientDetailsTest
    * @description  This method is used to test the functionality of method - fetchClientDetails.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void fetchClientDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new RE_ClientDetailsMockResponse());
        List<Contact> conList = [SELECT Id,AccountId,Email,OptOutInfoSharing__c FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId AND Email='citizenDummy@test.com' LIMIT 1];
        conList[0].OptOutComm__c=true;
        update conList[0];
        Account acc= new account(ID=conList[0].AccountId,HasOptedOutOfAccount__c=false);
        update acc;
        List<Contact_Mapping__c> conMap = [SELECT Id,IEES_Id__c FROM Contact_Mapping__c WHERE Contact__c IN:conList];
        System.debug('conList-->'+conList);
        System.debug('acc-->'+acc);
        System.debug('conMap-->'+conMap);
        // added if condition for test class fix Mohan
        //if (conMap.size()>0){
        conMap[0].IEES_Id__c=1234567890;
        update conMap[0];   
        //}  
        Test.startTest();
        for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST OR Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 2])
        {
            if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response.isSuccessful, true,'Success');  
                }
            }else if(u.Email == RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response1= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response1.isSuccessful, true,'Negative Scenoario');   
                }
            }
        }
        RE_ClientDetailsCtrl.EnrolledProgramsWrapper enrollWrapper = new RE_ClientDetailsCtrl.EnrolledProgramsWrapper('abc','01/11/2050','02/12/2100');
        RE_ClientDetailsCtrl.HouseholdCompositionWrapper householdWrapper = new RE_ClientDetailsCtrl.HouseholdCompositionWrapper('abc','17','Father');
        RE_ClientDetailsCtrl.HouseholdCompositionWrapper householdWrapperb = new RE_ClientDetailsCtrl.HouseholdCompositionWrapper('abc','25','Father');
        Test.stopTest();
        
    }
     /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   fetchReferralCount
    * @description  This method is used to test the functionality of method - fetchReferralCount.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void fetchReferralCountTest(){
        Test.setMock(HttpCalloutMock.class, new RE_ClientDetailsMockResponse());
        User u= [SELECT Id,ProfileId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        List<User> newUserlst =new List<User>();
        newUserlst.add(u);
        Test.setMock(HttpCalloutMock.class, new RE_ClientDetailsMockResponse());
        List<Contact> conList1 = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Account accnt = [SELECT Id, HasOptedOutOfAccount__c from Account Where Id=: conList1[0].AccountId];
        accnt.HasOptedOutOfAccount__c = false;
        Update accnt;
        List<Contact> conList = [SELECT Id,AccountId, OptOutInfoSharing__c FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Account acc= new account(Id=conList[0].AccountId,HasOptedOutOfAccount__c=false);
        update acc;
        List<Referral__c> referralList=[Select Id,Status__c from Referral__c LIMIT 3];
        referralList[0].Status__c=RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
        referralList[0].Contacts__c=conList[0].Id;
        referralList[1].Status__c=RE_GlobalConstants.STATUS_CLOSED;
        referralList[1].Contacts__c=conList[0].Id;
        update referralList;
        System.runAs(u){
        RE_CreateLightningServerResponse response2= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
        System.assert(response2.isSuccessful==true,'Success');
           RE_CreateLightningServerResponse response1= RE_ClientDetailsCtrl.getSDOHValues();
           System.assert(response1.isSuccessful==true,'Success');
        }

        
    }
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   createNoteTest
    * @description  This method is used to test the functionality of method - createNote.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void createNoteTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Test.startTest();
           RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.createNote('Test Title','Test Description',conList[0].Id);
           System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        System.runAs(u){
           RE_CreateLightningServerResponse response1= RE_ClientDetailsCtrl.createNote('Test Title','Test Description',conList[0].Id);
           System.assertEquals(response1.isSuccessful, false,'Negative Scenario');            
        }
        Test.stopTest();
        
    }
     /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   refreshNotesTest
    * @description  This method is used to test the functionality of method - refreshNotes.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void refreshNotesTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Test.startTest();
           RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.refreshNotes(conList[0].Id);
           System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        Test.stopTest();
        
    }
     /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   checkNoteEditPermissionTest
    * @description  This method is used to test the functionality of method - checkNoteEditPermission.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void checkNoteEditPermissionTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
//Create Document
ContentVersion cv = new ContentVersion();
cv.Title = 'Test Document';
cv.PathOnClient = 'TestDocument.pdf';
cv.VersionData = Blob.valueOf('Test Content');
cv.IsMajorVersion = true;
Insert cv;
 
//Get Content Documents
Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
//Create ContentDocumentLink 
ContentDocumentLink cdl = New ContentDocumentLink();
cdl.LinkedEntityId = conList[0].Id;
cdl.ContentDocumentId = conDocId;
cdl.shareType = 'V';
Insert cdl;
        Test.startTest();
         RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.createNote('Test Title','Test Description',conList[0].Id);
        // ContentDocumentLink docLink=[Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:conList[0].Id];
         RE_CreateLightningServerResponse response1 =RE_ClientDetailsCtrl.checkNoteEditPermission(cdl.ContentDocumentId);
        System.assertEquals(response.isSuccessful,true,'Positive Scenario');
        System.runAs(u){
           response1= RE_ClientDetailsCtrl.checkNoteEditPermission(cdl.ContentDocumentId);
            System.assertEquals(response.isSuccessful,true,'Negative Scenario');
        }
        Test.stopTest();
        
    }
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   updateNoteTest
    * @description  This method is used to test the functionality of method - updateNote.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void updateNoteTest(){
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
 
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = conList[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        Test.startTest();
         RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.createNote('Test Title','Test Description',conList[0].Id);
         RE_CreateLightningServerResponse responsenote=RE_ClientDetailsCtrl.updateNote(cdl.ContentDocumentId,'Updated Title','Updated Description');
         System.assertEquals(responsenote.isSuccessful, true,'Positive Scenario');
        System.runAs(u){
            responsenote= RE_ClientDetailsCtrl.updateNote(cdl.ContentDocumentId,'Updated Title','Updated Description');
            System.assertEquals(responsenote.isSuccessful, false,'Negative Scenario');
        }
       
        Test.stopTest();
        
    }
    /******************************************************************************************
    * @author       Payal Dubela
    * @date         06/17/2019
    * @methodname   checkConsentTest
    * @description  This method is used to test the functionality of method - checkConsent.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void checkConsentTest(){
        User u= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        List<Account> accList=[Select Id from Account Where Id=:u.Contact.AccountId];
        List<Consent__c> consentList=TestDataFactory.createConsent(1,true,conList,accList);
        Test.startTest();
        System.runAs(u){
             RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.checkConsent(conList[0].Id);
            System.debug('response--'+response);
             System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        }
        Test.stopTest();
        
    }
    /******************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/31/2019
    * @methodname   testSendEmail
    * @description  This method is used to test the functionality of method - sendEmail.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testSendEmail(){
        User cpUser= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        Test.startTest();
        System.runAs(cpUser){
            Map<String,Object> sendEmailWrapper = new Map<String,Object>();    
            sendEmailWrapper.put('clientName','Test User');
            sendEmailWrapper.put('clientEmail','test@test.com');
            sendEmailWrapper.put('clientId','testId');
            sendEmailWrapper.put('message','Test Message for OneView');
            RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.sendEmail(sendEmailWrapper);
            System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        }
        Test.stopTest();
    }
    /******************************************************************************************
    * @author       Arun Garg
    * @date         09/24/2019
    * @methodname   testFetchAssessment
    * @description  This method is used to test the functionality of method - sendEmail.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static  void testFetchAssessmentRecords(){
        User cpUser= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        Test.startTest();
        System.runAs(cpUser){
            RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.fetchAssessmentRecords();
            System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        }
        Test.stopTest();
    }
    @isTest public static void testFetchAssessmentResponses(){
        User cpUser= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        Assessment__c assessTempRec = [SELECT Id,Name FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId];
        RE_CreateLightningServerResponse assessmentQuestionRes;
        RE_CreateLightningServerResponse assessmentQuestionResUserAssessment;
        assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,null);
        assessmentQuestionResUserAssessment= RE_AssessmentQuestionsCtrl.createAssessment((String)assessmentQuestionRes.objectData.get('records'), conList[0].id, assessTempRec.Id, assessTempRec.Name,'test@test.com');
        Test.startTest();
        System.runAs(cpUser){
            
            RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.fetchAssessmentResponses(conList[0].Id);
            RE_ClientDetailsCtrl.checkConsentWithStatus(conList[0].Id,'Active');
            System.assertEquals(response.isSuccessful, true,'Positive Scenario');
        }
        RE_ClientDetailsCtrl.fetchRiskFactors('');
        Test.stopTest();
    }
    @isTest public static void testcreateContactForIEESData(){
         User cpUser= [SELECT Id,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        Test.startTest(); 
        RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.createContactForIEESData('{"BirthDate":"1957-02-02","Email":"ryan@yahoo.com","FirstName":"ashap","Gender":"Male","IEESId":"920052997","LastName":"Ryan","Phone":"5555551212"}'); 
         System.runAs(cpUser){
             RE_CreateLightningServerResponse response1=RE_ClientDetailsCtrl.createContactForIEESData('{"BirthDate":"1980-02-02","Email":"tester@yahoo.com","FirstName":"","Gender":"Female","IEESId":"920052995","LastName":"","Phone":"5557851212"}'); 
         }
        System.assertEquals(response.isSuccessful, true);
        Test.stopTest();
        
    }
    @isTest public static void testcreateContactForIEESData1(){
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;
        
        Contact con1 = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'James',LastName = 'Cameron',Email = 'james@test.com');
        insert con1;
        
        
        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 234567788);
        insert cm1;
        
        Contact_Mapping__c cm2 = new Contact_Mapping__c(Contact__c = con1.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm2;
        
        
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
         Test.startTest(); 
         RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.createContactForIEESData('{"BirthDate":"1957-02-02","Email":"ryan@yahoo.com","FirstName":"ashap","Gender":"Male","IEESId":"920052997","LastName":"Ryan","Phone":"5555551212"}');
         System.assertEquals(response.isSuccessful, true,'Negative Scenario');  
        Test.stopTest();
        
    }
     @isTest public static  void testcreateContactForIEESData2(){
         Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;

        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546734567);
        insert cm1;
        
        Contact_Mapping__c cm2 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm2;
         
        Test.startTest(); 
         RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.createContactForIEESData('{"BirthDate":"1957-02-02","Email":"ryan@yahoo.com","FirstName":"ashap","Gender":"Male","IEESId":"920052997","LastName":"Ryan","Phone":"5555551212"}');
         System.assertEquals(response.isSuccessful, true,'Negative Scenario');  
        Test.stopTest();
        
    }
     @isTest public static void testcreateContactForIEESData3(){
         kyHbeMciDatacontractsMock mocktest=new kyHbeMciDatacontractsMock();
         mocktest.isNoMatch=true;
         Test.setMock(WebServiceMock.class, mocktest);
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        
        Contact con = new Contact(RecordTypeId = objRecordType.Id,FirstName = 'FirstName',LastName = 'LastName',Email = 'test@email.com');
        insert con;

        Contact_Mapping__c cm1 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546734567);
        insert cm1;
        
        Contact_Mapping__c cm2 = new Contact_Mapping__c(Contact__c = con.Id,Group_Id__c = 'Grp123',IEES_Id__c = 546789023);
        insert cm2;
         
        Test.startTest(); 
         RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.createContactForIEESData('{"BirthDate":"1957-02-02","Email":"ryan@yahoo.com","FirstName":"ashap","Gender":"Male","IEESId":"920052997","LastName":"Ryan","Phone":"5555551212"}');
        Test.stopTest();
        System.assertEquals(response.isSuccessful, true);
    }
    
      /******************************************************************************************
    * @author       Nandita Bapaye
    * @date         03/31/2020
    * @methodname   testClientFavorite
    * @description  This method is used to test the create,remove and query my Clients
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest public static void testClientFavorite(){
        User cpUser= [SELECT Id,ContactId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Contact> conList = [SELECT Id,AccountId FROM Contact where RecordTypeId=:contactCitizenRecordTypeId LIMIT 1];
       Test.startTest(); 
        RE_CreateLightningServerResponse response;
        RE_CreateLightningServerResponse response1;
        boolean isFavorite;
         System.runAs(cpUser){
             response=RE_ClientDetailsCtrl.createClientFavourite(conList[0].Id);
             isFavorite=RE_ClientDetailsCtrl.checkClientFavorite(conList[0].Id);
             response1=RE_ClientDetailsCtrl.removeFavoriteClient(conList[0].Id);
             isFavorite=RE_ClientDetailsCtrl.checkClientFavorite(conList[0].Id);
         }
        System.assertEquals(response.isSuccessful, true);
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
                RE_CreateLightningServerResponse resp = RE_ClientDetailsCtrl.refreshNotes(strClientId);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
            try{
                RE_CreateLightningServerResponse resp1 = RE_ClientDetailsCtrl.checkNoteEditPermission(strClientId);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
            try{
                RE_CreateLightningServerResponse resp2 = RE_ClientDetailsCtrl.updateNote(strClientId,'','');
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
            try{
                RE_CreateLightningServerResponse resp3 = RE_ClientDetailsCtrl.checkConsent(strClientId);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
            try{
                RE_CreateLightningServerResponse resp4 = RE_ClientDetailsCtrl.fetchAssessmentResponses(strClientId);
            }catch(Exception e){
                System.debug('exception-'+e.getMessage());
                System.assertEquals('Argument cannot be null.', e.getMessage(), 'Success');
            }
        }
        Test.stopTest();
    }
    @isTest public static  void fetchClientDetailsTest1(){
        RE_ClientDetailsMockResponse mockResponse= new RE_ClientDetailsMockResponse();
        mockResponse.scenario='resultzero';
        Test.setMock(HttpCalloutMock.class, mockResponse);
        List<Contact> conList = [SELECT Id,AccountId,Email,OptOutInfoSharing__c FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId AND Email='citizenDummy@test.com' LIMIT 1];
        conList[0].OptOutComm__c=true;
        update conList[0];
        Account acc= new account(ID=conList[0].AccountId,HasOptedOutOfAccount__c=false);
        update acc;
        List<Contact_Mapping__c> conMap = [SELECT Id,IEES_Id__c FROM Contact_Mapping__c WHERE Contact__c IN:conList];
        conMap[0].IEES_Id__c=1234567890;
        update conMap[0];
        Test.startTest();
        for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST OR Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 2])
        {
            if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response.isSuccessful, true,'Success');  
                }
            }else if(u.Email == RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response1= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response1.isSuccessful, true,'Negative Scenoario');   
                }
            }
        }
        Test.stopTest();
        
    }
    
    @isTest public static  void fetchClientDetailsTest2(){
        RE_ClientDetailsMockResponse mockResponse= new RE_ClientDetailsMockResponse();
        mockResponse.scenario='errorScenario';
        Test.setMock(HttpCalloutMock.class, mockResponse);
        List<Contact> conList = [SELECT Id,AccountId,Email,OptOutInfoSharing__c FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId AND Email='citizenDummy@test.com' LIMIT 1];
        conList[0].OptOutComm__c=true;
        update conList[0];
        Account acc= new account(ID=conList[0].AccountId,HasOptedOutOfAccount__c=false);
        update acc;
        List<Contact_Mapping__c> conMap = [SELECT Id,IEES_Id__c FROM Contact_Mapping__c WHERE Contact__c IN:conList];
        conMap[0].IEES_Id__c=1234567890;
        update conMap[0];
        Test.startTest();
        for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST OR Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 2])
        {
            if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response.isSuccessful, true,'Success');  
                }
            }else if(u.Email == RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response1= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response1.isSuccessful, true,'Negative Scenoario');   
                }
            }
        }
        Test.stopTest();
        
    }
    @isTest public static  void fetchClientDetailsException(){
        RE_ClientDetailsMockResponse mockResponse= new RE_ClientDetailsMockResponse();
        mockResponse.scenario='exception';
        Test.setMock(HttpCalloutMock.class, mockResponse);
        List<Contact> conList = [SELECT Id,AccountId,Email,OptOutInfoSharing__c FROM Contact WHERE RecordTypeId=:contactCitizenRecordTypeId AND Email='citizenDummy@test.com' LIMIT 1];
        conList[0].OptOutComm__c=true;
        update conList[0];
        Account acc= new account(ID=conList[0].AccountId,HasOptedOutOfAccount__c=false);
        update acc;
        List<Contact_Mapping__c> conMap = [SELECT Id,IEES_Id__c FROM Contact_Mapping__c WHERE Contact__c IN:conList];
        conMap[0].IEES_Id__c=1234567890;
        update conMap[0];
        Test.startTest();
        for(User u : [SELECT Id,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST LIMIT 2])
        {
            if(u.Email == RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST){
                System.runAs(u){
                    RE_CreateLightningServerResponse response= RE_ClientDetailsCtrl.fetchClientDetails(conList[0].Id);
                    System.assertEquals(response.isSuccessful, false,'Negative Scenoario');  
                }
            }
        }
        Test.stopTest();        
    }
}