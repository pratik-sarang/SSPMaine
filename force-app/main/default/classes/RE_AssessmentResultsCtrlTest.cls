/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_AssessmentResultsCtrlTest
*   Created By   :   Deloitte
*   Created Date :   09/24/2019
*   Description :   This class acts as a test class for RE_AssessmentResultsCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    09/24/2019       Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_AssessmentResultsCtrlTest {
    /********************************************************************************************
    * @author       Deeksha Gupta
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
        List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(1,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
        List<RE_Goal__c> lstGoals = TestDataFactory.createGoalRecords(1,true,lstArchetype);
        List<Resource__c> lstResources = [SELECT Id, Name, Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c FROM Resource__c];
        List<Location__c> lstLocations = [SELECT Id, Name FROM Location__c];
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(1,true,null,lstLocations,lstResources);
        List<RE_Taxonomy__c> lstTaxRecords = TestDataFactory.createTaxonomyRecords(1, true);
        TestDataFactory.createResourceTaxonomyRecords(1, true, lstResources, lstTaxRecords);
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        List<Assessment__c> lstAssessment = TestDataFactory.createAssessmentTemplateRecords(1,true,parentAssessRecTypeId);
        List<Question__c> lstQuestions = TestDataFactory.createQuestionsRecords(1,true,lstAssessment);
        lstQuestions.addAll(TestDataFactory.createQuestionsFreeTextRecords(1,true,lstAssessment));
        List<AnswerChoice__c> lstAnsChoice = TestDataFactory.createAnswerChoiceRecords(1,true,lstQuestions);
        List<GoalAnswer__c> lstGoalAns = TestDataFactory.createGoalAnsRecords(1,true,lstAnsChoice,lstGoals);
        List<RE_Config__c> lstConfig = TestDataFactory.createDomainConfigRecords(1,true,lstGoals,lstTaxRecords,'Goal_Config');
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         09/24/2019
    * @methodname   testGetAssessmentResourcesResults
    * @description  This method is used to test the functionality of method - getAssessmentResourcesResults.
    * @param        none
    * @return       none
    ********************************************************************************************/
    // Commented due to the deployment errors for the mock sandbox
    @isTest static void testGetAssessmentResourcesResults() {   
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
        RE_CreateLightningServerResponse result;
        RE_CreateLightningServerResponse result1;
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        Assessment__c assessTempRec = [SELECT Id,AssessmentTitle__c,Name,Resident__c,Resident__r.Name,Partner__c,Partner__r.Name,CreatedDate FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId LIMIT 1];
        Test.startTest();
        RE_CreateLightningServerResponse assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,citizenUser.ContactId);
        String quesWrapper = (String)assessmentQuestionRes.objectData.get('records');
        
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(quesWrapper, List<RE_AssessmentQuestionsWrapper.Question>.class);
        retVal[0].sResponse = retVal[0].lstOptions[0].value;
        retVal[1].sResponse = '52726';
        
        RE_CreateLightningServerResponse assessmentResponse = RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal),citizenUser.ContactId,assessTempRec.Id,assessTempRec.AssessmentTitle__c,RE_GlobalConstants.strCitizenEmail);
        String uAssessmentId = (String)assessmentResponse.objectData.get('records');  
        result = RE_AssessmentResultsCtrl.getAssessmentResourcesResults(uAssessmentId,'[]');
        result1 = RE_AssessmentResultsCtrl.getAssessmentResourcesResults(uAssessmentId,JSON.serialize(retVal));
        RE_AssessmentResultsWrapper resultWrapper = new RE_AssessmentResultsWrapper();
        resultWrapper.sAssessmentTemplateId = assessTempRec.Id;
        resultWrapper.sAssessTemplateName = assessTempRec.AssessmentTitle__c;
        resultWrapper.sResidentName = assessTempRec.Resident__r.Name;
        resultWrapper.sResidentId = assessTempRec.Resident__c;
        resultWrapper.sPartnerName = assessTempRec.Partner__r.Name;
        resultWrapper.sDateTaken =  String.valueOf(assessTempRec.CreatedDate);
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
       
    }
     /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         09/24/2019
    * @methodname   testGetAssessmentResourcesResultsExptn
    * @description  This method is used to test the functionality of method - getAssessmentResourcesResults.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testGetAssessmentResourcesResultsExptn() {   
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
        Account acc = [SELECT Id from Account LIMIT 1];        
        Test.startTest();
        String assessmentId = 'D.@_+?"AB0';
        RE_CreateLightningServerResponse result = RE_AssessmentResultsCtrl.getAssessmentResourcesResults(assessmentId,'[]');
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
    }
    
    
     @isTest static void createRefferal() {   
         List<account> lstAccount=[Select id, name from Account];
        List<ID> accidset= new List<ID>();
        accidset.add(lstAccount[0].id);
        List<Location__c> lstlocation=[Select id,name from Location__c];
        List<Resource__c> lstresource = [Select id,name from Resource__c];
        LocationResource__c objlocationresource= new LocationResource__c(Name='locationres',Resource__c=lstresource[0].id,Location__c=lstlocation[0].id,Status__c='Active');
        insert objlocationresource;
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Contact> citizencontacts=[Select id,RecordtypeId,name ,PreferredCommunicationMethod__c from contact];
        

        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset);
        locationList.addAll(TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset));
        
        String request = '{"accountIsClaimed": true, "accountStatus":"Active - Allow referrals", "resourceId":"'+lstresource[0].id+'","accountId":"'+lstAccount[0].id+'"}';
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Test.startTest(); 
         System.runAs(communityUser){
            RE_CreateLightningServerResponse response=RE_AssessmentResultsHelper.insertReferralForResident(request, locationList[0].Id, true);
            RE_CreateLightningServerResponse response1 = RE_AssessmentResultsHelper.getOptOutInfoSharingDetails();
            List<Referral__c> lstRfrI = [SELECT Id from Referral__c limit 1];
            RE_CreateLightningServerResponse response2 = RE_AssessmentResultsHelper.connectDraftReferralsFromArcheTypeResults(lstRfrI[0].Id, true);
             System.assertEquals(response.isSuccessful, true,'Success');
         }
        Test.stopTest();
     
     }
     
     @isTest static void createRefferal2() {   
         List<account> lstAccount=[Select id, name from Account];
        List<ID> accidset= new List<ID>();
        accidset.add(lstAccount[0].id);
        List<Location__c> lstlocation=[Select id,name from Location__c];
        List<Resource__c> lstresource = [Select id,name from Resource__c];
        LocationResource__c objlocationresource= new LocationResource__c(Name='locationres',Resource__c=lstresource[0].id,Location__c=lstlocation[0].id,Status__c='Active');
        insert objlocationresource;
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Contact> citizencontacts=[Select id,RecordtypeId,name ,PreferredCommunicationMethod__c from contact];
        

        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset);
        locationList.addAll(TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset));
        
        String request = '{"accountIsClaimed": false, "accountStatus":"Active - Allow referrals", "resourceId":"'+lstresource[0].id+'","accountId":"'+lstAccount[0].id+'"}';
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Test.startTest(); 
         System.runAs(communityUser){
            RE_CreateLightningServerResponse response=RE_AssessmentResultsHelper.insertReferralForResident(request, locationList[0].Id, true);
            RE_CreateLightningServerResponse response1 = RE_AssessmentResultsHelper.getOptOutInfoSharingDetails();
            RE_CreateLightningServerResponse response2 = RE_AssessmentResultsCtrl.insertReferralForResident(request, locationList[0].Id, true);
            RE_CreateLightningServerResponse response3 = RE_AssessmentResultsCtrl.connectDraftReferralsFromArcheTypeResults(request, true);
            System.assertEquals(response.isSuccessful, true,'Success');
         }
        Test.stopTest();
     
     }
     
      @isTest static void createRefferalException() {   
         List<account> lstAccount=[Select id, name from Account];
        List<ID> accidset= new List<ID>();
        accidset.add(lstAccount[0].id);
        List<Location__c> lstlocation=[Select id,name from Location__c];
        List<Resource__c> lstresource = [Select id,name from Resource__c];
        LocationResource__c objlocationresource= new LocationResource__c(Name='locationres',Resource__c=lstresource[0].id,Location__c=lstlocation[0].id,Status__c='Active');
        insert objlocationresource;
        Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        List<Contact> citizencontacts=[Select id,RecordtypeId,name ,PreferredCommunicationMethod__c from contact];
        

        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset);
        locationList.addAll(TestDataFactory.createLocations(1, true, locationRecordTypeId, accidset));
        
        String request = '{"accountIsClaimed": false, "accountStatus":"Active - Allow referrals", "resourceId":"'+null+'","accountId":"'+lstAccount[0].id+'"}';
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        Test.startTest(); 
         System.runAs(communityUser){
            RE_CreateLightningServerResponse response=RE_AssessmentResultsHelper.insertReferralForResident(request, locationList[0].Id, true);
            
            RE_CreateLightningServerResponse response1 = RE_AssessmentResultsCtrl.insertReferralForResident(request, locationList[0].Id, true);
 
            RE_CreateLightningServerResponse response2 = RE_AssessmentResultsHelper.getOptOutInfoSharingDetails();
            
             System.assertEquals(response.isSuccessful, false,'Success');
         }
        Test.stopTest();
     
     }
    
    @isTest static void testgetOptOutInfoSharingDetails(){
        test.startTest();
        RE_CreateLightningServerResponse response = RE_AssessmentResultsCtrl.getOptOutInfoSharingDetails();
        test.stopTest();
        system.assert(response.isSuccessful,true);
    }

/********************************************************************************************
    * @author       Nandita Bapaye
    * @date         04/10/2020
    * @methodname   testLoadMoreResources
    * @description  This method is used to test the functionality of method - LoadMoreResources.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testLoadMoreResources() {   
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
       
       // RE_CreateLightningServerResponse result;
        RE_CreateLightningServerResponse result1;
        Id parentAssessRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Assessment__c','Assessment_Template');
        Assessment__c assessTempRec = [SELECT Id,AssessmentTitle__c,Name,Resident__c,Resident__r.Name,Partner__c,Partner__r.Name,CreatedDate FROM Assessment__c WHERE RecordTypeId=:parentAssessRecTypeId LIMIT 1];
      
        Test.startTest();
        RE_CreateLightningServerResponse assessmentQuestionRes = RE_AssessmentQuestionsCtrl.getAssessmentQuestions(assessTempRec.Id,citizenUser.ContactId);
        String quesWrapper = (String)assessmentQuestionRes.objectData.get('records');
        
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question> ) JSON.deserialize(quesWrapper, List<RE_AssessmentQuestionsWrapper.Question>.class);
        retVal[0].sResponse = retVal[0].lstOptions[0].value;retVal[1].sResponse = '52726';
        RE_CreateLightningServerResponse assessmentResponse = RE_AssessmentQuestionsCtrl.createAssessment(JSON.serialize(retVal),citizenUser.ContactId,assessTempRec.Id,assessTempRec.AssessmentTitle__c,RE_GlobalConstants.strCitizenEmail);
        String uAssessmentId = (String)assessmentResponse.objectData.get('records');
        List<RE_Goal__c> lstGoals = [select Id from RE_Goal__c];
        RE_CreateLightningServerResponse result = RE_AssessmentResultsCtrl.loadMoreResources(uAssessmentId,lstGoals[0].Id,double.valueOf('38.2009055'), double.valueOf('-84.87328350000001'));
        Test.stopTest();
        
        System.assert(result.isSuccessful == true,'Success');
    
    } 
    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date         04/10/2020
    * @methodname   testLoadlessResources
    * @description  This method is used to test the functionality of method - LoadLessResources.
    * @param        none
    * @return       none
    ********************************************************************************************/

   @isTest static void testLoadLessResources() { 
       
       List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstObjTile = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
       Account objAcc = [Select Id,Status__c,IsClaimed__c from Account LIMIT 1];
       Resource__c objRes = [select id,name from resource__c LIMIT 1];
       LocationResource__c objLocRes= [Select id,ResourceDescription__c from locationresource__c LIMIT 1];
       Location__c ObjLoc = [select id,name from location__c Limit 1];
       RE_Goal__c objGoal = [select Id from RE_Goal__c Limit 1];
         Test.startTest();
         for(integer i=0;i<3;i++){
             RE_ArchetypeDetailWrapper.ResourceTileBlockCls objTileBlock = new RE_ArchetypeDetailWrapper.ResourceTileBlockCls();
             objTileBlock.accountId = objAcc.Id;
             objTileBlock.accountStatus = objAcc.Status__c;
             objTileBlock.accountIsClaimed = objAcc.IsClaimed__c;
             objTileBlock.resourceId = objRes.Id;
             objTileBlock.resourceName = objRes.Name;
             objTileBlock.resourceDescription= objLocRes.ResourceDescription__c;
             objTileBlock.locationId = ObjLoc.Id;
             objTileBlock.locationName=ObjLoc.Name;
             objTileBlock.locationResourceId = objLocRes.Id;
             lstObjTile.add(objTileBlock);
         }
         RE_CreateLightningServerResponse result = RE_AssessmentResultsCtrl.loadLessResources(objGoal.Id,lstObjTile);
         System.assert(result.isSuccessful == true,'Success');
         Test.stopTest();
   } 
     
}