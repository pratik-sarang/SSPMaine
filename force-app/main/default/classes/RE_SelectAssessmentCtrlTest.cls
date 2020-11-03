/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_SelectAssessmentCtrlTest
*   Created By   :   Deloitte
*   Created Date :   03/11/2020
*   Description :   This class acts as a test class for RE_SelectAssessmentCtrlTest
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Nandita                   03/11/2020      Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_SelectAssessmentCtrlTest {

    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        TestDataFactory.createSDOHcustomSettings();
        
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = 41.4986961;
        citizenContact.ContactGeoLocation__Longitude__s = -90.7722974; 
        citizenContact.MailingPostalCode='52726';
        insert citizenContact;
        
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
        /*List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(1,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
        List<RE_Goal__c> lstGoals = TestDataFactory.createGoalRecords(1,true,lstArchetype);
        List<Resource__c> lstResources = [SELECT Id, Name, Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c FROM Resource__c];
        List<Location__c> lstLocations = [SELECT Id, Name FROM Location__c];
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(1,true,null,lstLocations,lstResources);
        List<RE_Taxonomy__c> lstTaxRecords = TestDataFactory.createTaxonomyRecords(1, true);
        TestDataFactory.createResourceTaxonomyRecords(1, true, lstResources, lstTaxRecords);*/
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        List<Assessment__c> lstAssessment = TestDataFactory.createAssessmentTemplateRecords(1,true,parentAssessRecTypeId);
       /* List<Question__c> lstQuestions = TestDataFactory.createQuestionsRecords(1,true,lstAssessment);
        lstQuestions.addAll(TestDataFactory.createQuestionsFreeTextRecords(1,true,lstAssessment));
        List<AnswerChoice__c> lstAnsChoice = TestDataFactory.createAnswerChoiceRecords(1,true,lstQuestions);
        List<GoalAnswer__c> lstGoalAns = TestDataFactory.createGoalAnsRecords(1,true,lstAnsChoice,lstGoals);
        List<RE_Config__c> lstConfig = TestDataFactory.createDomainConfigRecords(1,true,lstGoals,lstTaxRecords,'Goal_Config');*/
    }
    
     @isTest static void testfetchrec() {   
         User citizenUser ;
        User cpUser;   
        for(User u :[SELECT Id, ContactId,Contact.AccountId,Email FROM User 
                            WHERE Email=: RE_GlobalConstants.strCitizenEmail OR Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST]){
                                if(u.Email==RE_GlobalConstants.strCitizenEmail){
                                    citizenUser=u;
                                }else{
                                    cpUser=u;
                                }           
         }
         Test.startTest();
         System.runAs(cpUser){
         	RE_CreateLightningServerResponse assessmentResponse = RE_SelectAssessmentCtrl.fetchrec();
            System.assert(assessmentResponse.isSuccessful == true,'Success');
         }
         Test.stopTest();
     }

}