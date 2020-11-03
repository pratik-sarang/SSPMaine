/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_AssessmentQuestionsCtrlTest
*   Created By   :   Deloitte
*   Created Date :   09/24/2019
*   Description :   This class acts as a test class for RE_AssessmentResultsCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Prashant                    09/24/2019       Initial Version
*****************************************************************************************************************************/

@isTest
public class RE_AssessmentQuestionsCtrlTest {
/********************************************************************************************
    * @author       Prashant Singh
    * @date         09/24/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
     @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='43521';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
         Profile guestProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strGuestProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
       User guestUser = TestDataFactory.createSpecificCommunityUser('reGusr', null, 'REGuestUser', 'Testguestuser','testguestuser@testguestuser.com' , 'testguestuser@testguestuser.com', guestProfile.Id, true);
         // List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(1,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
       // List<RE_Goal__c> lstGoals = TestDataFactory.createGoalRecords(1,true,lstArchetype);
        List<Resource__c> lstResources = [SELECT Id, Name, Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c FROM Resource__c LIMIT 1];
        List<Location__c> lstLocations = [SELECT Id, Name FROM Location__c LIMIT 1];
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(1,true,null,lstLocations,lstResources);
     //   List<RE_Taxonomy__c> lstTaxRecords = TestDataFactory.createTaxonomyRecords(1, true);
     //   TestDataFactory.createResourceTaxonomyRecords(1, true, lstResources, lstTaxRecords);
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        List<Assessment__c> lstAssessment = TestDataFactory.createAssessmentTemplateRecords(1,true,parentAssessRecTypeId);
        List<Question__c> lstQuestions = TestDataFactory.createQuestionsRecords(1,true,lstAssessment);
         lstQuestions.addAll(TestDataFactory.createQuestionsFreeTextRecords(1,true,lstAssessment));
        List<AnswerChoice__c> lstAnsChoice = TestDataFactory.createAnswerChoiceRecords(1,true,lstQuestions);
         TestDataFactory.createAESEncryptionSettings();
     //   List<GoalAnswer__c> lstGoalAns = TestDataFactory.createGoalAnsRecords(1,true,lstAnsChoice,lstGoals);
     //   List<RE_Config__c> lstConfig = TestDataFactory.createDomainConfigRecords(1,true,lstGoals,lstTaxRecords,'Goal_Config');
    }
    
    @isTest static void testgetAssessmentQuestions() {  
      User citizenUser ;
        User cpUser;
        Contact citizenContact = [Select id,name from contact limit 1];    
        for(User u :[SELECT Id, ContactId,Contact.AccountId,Email, Profile.Name FROM User 
                            WHERE Email=: RE_GlobalConstants.strCitizenEmail OR Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST]){
                                if(u.Email==RE_GlobalConstants.strCitizenEmail){
                                    citizenUser=u;
                                }else{
                                    cpUser=u;
                                } 

            
         }
       
        RE_CreateLightningServerResponse assessmentQuestionRes;
        RE_CreateLightningServerResponse assessmentQuestionResUserAssessment;
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        Assessment__c assessTempRec = [SELECT Id,Name FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId];
        
        Test.startTest();
          assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,citizenContact.id);
          
        String quesWrapper = (String)assessmentQuestionRes.objectData.get('records');
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(quesWrapper, List<RE_AssessmentQuestionsWrapper.Question>.class);
            retVal[0].sResponse = retVal[0].lstOptions[0].value;
            retVal[1].sResponse = '52726';
        System.runAs(cpUser){
              
            
           //   assessmentQuestionResUserAssessment= RE_AssessmentQuestionsCtrl.createAssessment((String)assessmentQuestionRes.objectData.get('records'), citizenContact.id, assessTempRec.Id, assessTempRec.Name);
           assessmentQuestionResUserAssessment = RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal), citizenContact.id, assessTempRec.Id, assessTempRec.Name, '');
             String uAssessmentId = (String)assessmentQuestionResUserAssessment.objectData.get('records');
            Map<String,String> sUserTypeMap = RE_AssessmentQuestionsCtrl.checkLoggedinUserRole(uAssessmentId);
        }
        
         System.runAs(citizenUser){
              String uAssessmentId = (String)assessmentQuestionResUserAssessment.objectData.get('records');
              
            Map<String,String> sUserTypeMap = RE_AssessmentQuestionsCtrl.checkLoggedinUserRole(uAssessmentId);
            RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal),'','','','');
        }
        Test.stopTest();
         System.assert(assessmentQuestionRes.isSuccessful == true,'Success');
        
    }
    
    //Guest User
    @isTest static void testgetGuestAssessmentQuestions(){
        User guestUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User 
                            WHERE Email='testguestuser@testguestuser.com'];
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        Assessment__c assessTempRec = [SELECT Id,Name FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId];
        String strEmail = 'testUser@gmail.com'; 
        
        Test.startTest();
            RE_CreateLightningServerResponse assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,null);
        System.runAs(guestUser){
        RE_CreateLightningServerResponse assessmentQuestionRes1 = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,null);
            String quesWrapper = (String)assessmentQuestionRes.objectData.get('records');
            List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(quesWrapper, List<RE_AssessmentQuestionsWrapper.Question>.class);
            retVal[0].sResponse = retVal[0].lstOptions[0].value;
            retVal[1].sResponse = '52726';
            RE_CreateLightningServerResponse assessmentQuestionResUserAssessment = RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal),'' , assessTempRec.Id, assessTempRec.Name, strEmail);
             String uAssessmentId = (String)assessmentQuestionResUserAssessment.objectData.get('records');
            
            string encryptedId = RE_AssessmentQuestionsCtrl.encryptParameter(uAssessmentId);
            Map<String,String> sUserTypeMap = RE_AssessmentQuestionsCtrl.checkLoggedinUserRole(encryptedId);
            
            System.assert(assessmentQuestionRes.isSuccessful == true,'Success');
        }
        Test.stopTest();
    }
    
    //Guest User
    @isTest static void testgetGuestAssessmentQuestions1(){
     Account acc = [select id from Account limit 1];
     Contact cnt = new Contact(LastName ='test', AccountId = acc.Id, FirstName='uue');
     insert cnt;
     User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = :RE_GlobalConstants.strNonCitizenProfileName].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     ContactId =cnt.Id
    );
     RE_CreateLightningServerResponse assessmentQuestionRes;
    Contact citizenContact = [Select id,name from contact limit 1]; 
    Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
    Assessment__c assessTempRec = [SELECT Id,Name FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId];
      assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,citizenContact.id);
          
    String quesWrapper = (String)assessmentQuestionRes.objectData.get('records');
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(quesWrapper, List<RE_AssessmentQuestionsWrapper.Question>.class);
            retVal[0].sResponse = retVal[0].lstOptions[0].value;
            retVal[1].sResponse = '52726';
        Test.startTest();
      
        System.runAs(u){
        RE_CreateLightningServerResponse assessmentQuestionRes1 = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,null);
            RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal),'','','','');
            RE_CreateLightningServerResponse assessmentQuestionRes2 =  RE_AssessmentQuestionsCtrl.getAssessmentQuestions('','');
            System.assert(assessmentQuestionRes1.isSuccessful == false,'success');
        }
        Test.stopTest();
    }
    
}