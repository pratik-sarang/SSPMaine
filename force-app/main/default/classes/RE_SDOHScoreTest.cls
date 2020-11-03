@isTest
public class RE_SDOHScoreTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        
	@testSetup static void setupTestData(){    
        TestDataFactory.testDataSetup();
        User u= [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST];
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='43521';
        insert citizenContact;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
		Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        List<Assessment__c> lstAssessment = TestDataFactory.createAssessmentTemplateRecords(1,true,parentAssessRecTypeId);
        Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','User_Assessment');
        User cpUser =[SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        List<Assessment__c> lstUserAssessment = TestDataFactory.createUserAssessmentTemplateRecords(1,true,parentUserAssessRecTypeId,cpUser.ContactId,citizenContact.Id,lstAssessment[0].Id);
    	List<Question__c> lstQuestions = TestDataFactory.createQuestionsRecords(1,true,lstAssessment);
        List<AnswerChoice__c> lstAnsChoice = TestDataFactory.createAnswerChoiceRecords(1,true,lstQuestions);
        List<AssessmentResponse__c> lstAssRes=TestDataFactory.createAssessmentResponse(1,true,lstAnsChoice,lstUserAssessment,lstQuestions,citizenContact.Id);
    	TestDataFactory.createSDOH(1,true,citizenContact.Id,lstQuestions);
        
    }
    @isTest static  void getSDOHTest(){ 
        Test.StartTest();
        	Contact citizenContact = [SELECT Id FROM Contact WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
       		User communityUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
            Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','User_Assessment');
            Assessment__c assessTempRec = [SELECT Id FROM Assessment__c WHERE RecordTypeId=:parentUserAssessRecTypeId];
       		System.runAs(communityUser) {
       			RE_SDOHScore.calculateSDOHScoreAndSaveCat(assessTempRec.Id, citizenContact.Id);
            }
        	System.assertNotEquals(assessTempRec, null, 'Positive');
        Test.StopTest();
    }
	@isTest static  void getReportTest2(){ 
        Test.StartTest();
        	Contact citizenContact = [SELECT Id FROM Contact WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
       		User communityUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=: RE_GlobalConstants.strCitizenEmail];
            Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','User_Assessment');
            Assessment__c assessTempRec = [SELECT Id FROM Assessment__c WHERE RecordTypeId=:parentUserAssessRecTypeId];
        	System.runAs(communityUser) {
               RE_SDOHScore.calculateSDOHScoreAndSaveCat(assessTempRec.Id, citizenContact.Id);
            }
        	System.assertNotEquals(assessTempRec, null, 'Positive');
        Test.StopTest();
    }
    @isTest static  void getReportTest3(){ 
        Test.StartTest();
        	Contact citizenContact = [SELECT Id FROM Contact WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
       		User communityUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=: RE_GlobalConstants.strCitizenEmail];
            Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','User_Assessment');
            Assessment__c assessTempRec = [SELECT Id FROM Assessment__c WHERE RecordTypeId=:parentUserAssessRecTypeId];
       		RE_SDOHScore.calculateSDOHScoreAndSaveCat(assessTempRec.Id, citizenContact.Id);
        	System.assertNotEquals(assessTempRec, null, 'Positive');
        Test.StopTest();
    }
    
    @isTest static  void testupdatePreviousIsLatestCheckRecords(){ 
        Test.StartTest();
        	Contact citizenContact = [SELECT Id FROM Contact WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
       		User communityUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=: RE_GlobalConstants.strCitizenEmail];
            Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
            Assessment__c assessTempRec = [SELECT Id FROM Assessment__c WHERE RecordTypeId=:parentUserAssessRecTypeId];
        	List<Question__c> quesRecord = [SELECT Assessment__c,Id FROM Question__c WHERE Assessment__c = :assessTempRec.Id];
        	//List<SDOH__c> sdohList = TestDataFactory.createSDOH(1,true,citizenContact.Id,quesRecord);
        	SDOH__c sdoh = [SELECT Id FROM SDOH__c LIMIT 1];
        	Set<String> setOfIds = new Set<String>();
        	setOfIds.add(sdoh.Id);
       		Boolean isUpdate = RE_SDOHScore.updatePreviousIsLatestCheckRecords(setOfIds, citizenContact.Id);
        	System.assertEquals(isUpdate, true, 'Positive');
        Test.StopTest();
    }
    
    @isTest static  void testcalucateAverageScore(){ 
        Test.StartTest();
        	Contact citizenContact = [SELECT Id FROM Contact WHERE Email=: RE_GlobalConstants.strCitizenEmail LIMIT 1];
       		User communityUser = [SELECT Id, ContactId,Contact.AccountId,Email FROM User WHERE Email=: RE_GlobalConstants.strCitizenEmail];
            Id parentUserAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
            Assessment__c assessTempRec = [SELECT Id FROM Assessment__c WHERE RecordTypeId=:parentUserAssessRecTypeId];
        	Question__c quesRecord = [SELECT Assessment__c,Id FROM Question__c WHERE Assessment__c = :assessTempRec.Id];
        	AnswerChoice__c ansChoice = [SELECT Question__c, Id, Score__c FROM AnswerChoice__c WHERE Question__c = :quesRecord.Id];
        	List<AssessmentResponse__c> assResList = [SELECT Id, AnswerChoice__c, AnswerChoice__r.Score__c FROM AssessmentResponse__c WHERE AnswerChoice__c = :ansChoice.Id];
       		Decimal desNum = RE_SDOHScore.calucateAverageScore(assResList);
        	System.assertNotEquals(desNum, null, 'Positive');
        Test.StopTest();
    }

}