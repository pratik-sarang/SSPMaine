/***************************************************************************************************************************
*   Type             :   Test Class
*   Name             :   RE_LMSUtilityTest
*   Created By       :   CHFS
*   Created Date     :   11/04/2019
*   Description      :   This class acts as a test class for RE_LMSUtilityTest
*   Modification Log :
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------
*   * Venkat Korra				11/08/2019		
*****************************************************************************************************************************/
@isTest
public class RE_LMSUtilityTest 
{
    static Id contactCPRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
    static Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         11/08/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void testDataSetup()
    {
        TestDataFactory.createREPropertiesCustomSettings();
        
        List<Account> accountList = TestDataFactory.createAccounts(5,true,sREAccRecTypeId);
        
        Contact cpCon = TestDataFactory.createCPContact(RE_GlobalConstants.strCitizenFirstName, RE_GlobalConstants.strCitizenLastName, RE_GlobalConstants.strCitizenEmail, 'Staff', contactCPRecordTypeId, false);
        cpCon.AccountId = accountList[0].Id;
        upsert cpCon;
        
        User cpUser = TestDataFactory.createCommunityUser('cpCon', cpCon.Id, 're_sampleuser@test.com', RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN, true);
        
        String learningRecordTypeID = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        // Creating 'redwing__Learning__c' object record
        redwing__Learning__c learningObj = new redwing__Learning__c();
            learningObj.Name = 'Program Summary';
            learningObj.redwing__Published__c = True;
            learningObj.RecordTypeId = learningRecordTypeID;
        insert learningObj;
        // Creating 'redwing__Training_Plan__c' object record
        redwing__Training_Plan__c trainingPlan = new redwing__Training_Plan__c();
            trainingPlan.Name = 'Required Training for BacKYard Partners';
        insert trainingPlan;
        // Creating 'redwing__Training_Plan_Section__c' object record
        redwing__Training_Plan_Section__c trainingPlanSection = new redwing__Training_Plan_Section__c();
            trainingPlanSection.redwing__Training_Plan__c = trainingPlan.Id;
            trainingPlanSection.Name = 'Program Sumary';
        insert trainingPlanSection;
        // Creating 'redwing__Training_Plan_Section_Item__c' object record
        redwing__Training_Plan_Section_Item__c trainingPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
            trainingPlanSectionItem.redwing__Training_Plan_Section__c = trainingPlanSection.Id;
            trainingPlanSectionItem.redwing__Learning__c = learningObj.Id;
        insert trainingPlanSectionItem;
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         11/08/2019
    * @methodname   testAssignCPUserOnboardingTraining
    * @description  This method is used to test the functionality of method - assignCPUserOnboardingTraining.
    * @param        none
    * @return       none
    ********************************************************************************************/
   @isTest static void testAssignCPUserOnboardingTraining() 
    {
        List<Id> uIds = New List<Id>();
        for (User u : [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE userName = 're_sampleuser@test.com' LIMIT 1]) 
        {
            uIds.add(u.Id);
        }
        Test.startTest();
        	 RE_LMSUtility.assignCPUserOnboardingTraining(uIds);
        Test.stopTest();
        List<User> updatedUserList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE Id = :uIds LIMIT 1];
        system.assertEquals(updatedUserList[0].IsOnboardTrainingDone__c, false);
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         11/08/2019
    * @methodname   testCPUserWhoHasLearningPlanAssigned
    * @description  This method is used to test the CPUser who already has Learning Plan Assigned 
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testCPUserHasLearningPlanAssigned()
    {
        List<User> userList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE userName = 're_sampleuser@test.com' LIMIT 1];
        Id trainingPlanId = [SELECT Id, Name FROM redwing__Training_Plan__c WHERE Name = 'Required Training for BacKYard Partners'].Id;
        redwing__Training_Plan_Assignment__c trainingPlanAssigned = new redwing__Training_Plan_Assignment__c();
        trainingPlanAssigned.redwing__User__c = userList[0].Id;
        trainingPlanAssigned.redwing__Training_Plan__c = trainingPlanId;
        insert trainingPlanAssigned;
        List<Id> uIds = new List<Id>();
        for (User u : userList) 
        {
            uIds.add(u.Id);
        }
        Test.startTest();
        	RE_LMSUtility.assignCPUserOnboardingTraining(uIds);
        Test.stopTest();
        List<User> updatedUserList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE Id = :uIds LIMIT 1];
        system.assertEquals(trainingPlanAssigned.redwing__User__c, updatedUserList[0].Id);
        system.assertEquals(updatedUserList[0].IsOnboardTrainingDone__c, false);
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         11/08/2019
    * @methodname   testCompleteCPUserOnboardingTraining
    * @description  This method is used to test the functionality of method - completeCPUserOnboardingTraining.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testCompleteCPUserOnboardingTraining() 
    {
        List<User> userList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE userName = 're_sampleuser@test.com' LIMIT 1];
        
        List<Id> uIds = new List<Id>();
        for (User u : userList) 
        {
            uIds.add(u.Id);
        }
        Test.startTest();
        	RE_LMSUtility.completeCPUserOnboardingTraining(uIds);
        Test.stopTest();
        List<User> updatedUserList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE Id = :uIds LIMIT 1];
        system.assertEquals(updatedUserList[0].IsOnboardTrainingDone__c, true);
    }
    /********************************************************************************************
    * @author       Siri Putta
    * @date         12/04/2019
    * @methodname   testtrycatchforcompltedtraining
    * @description  This method is used to test the try catch block of the method - completeCPUserOnboardingTraining.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testtrycatchforcompltedtraining() 
    {
        //List<User> userList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE userName = 're_sampleuser@test.com' LIMIT 1];
        //
        List<Id> uIds = new List<Id>();
        //for (User u : userList) 
       // {
        //    uIds.add(u.Id);
        //}
        List<User> updatedUserList = new List<User>();
        Test.startTest();
        try{
        	RE_LMSUtility.completeCPUserOnboardingTraining(null);
            updatedUserList = [SELECT Id, Name, IsOnboardTrainingDone__c FROM User WHERE Id = :uIds LIMIT 1];
        }catch(Exception e) {     
        	//system.assert(e.getMessage()); 
        	system.assertEquals(updatedUserList.isEmpty(), true,'Error');
        } 
        Test.stopTest();
        
        //system.assertEquals(updatedUserList[0].IsOnboardTrainingDone__c, true);
    }
}