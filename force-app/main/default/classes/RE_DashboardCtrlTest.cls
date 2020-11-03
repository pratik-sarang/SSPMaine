/**
* Class Name    : RE_UserCreationHelperTest
* Owner         : DELOITTE
* Created Date  : 24/05/2019
* Description   : Test Class for RE_UserCreationHelper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Akash       Initial Version
   26/06/2019  Arun       Modified version
**/

@isTest
public class RE_DashboardCtrlTest {

      /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method to set up test data
    */
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id sContactId = [Select Id FROM Contact  Where Email = 'cpadminuser@deloitte.com' LIMIT 1].Id;
        User ObjREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
    }
     /**
    @author       : Pankaj
    @date         : 06/02/2019
    @description  : static method getWrapperMethod method
    */
    @isTest static  void getWrapperMethodTest(){
        Id conId = [Select Id FROM Contact  Where Email = :RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        system.runAs(objUser){
            RE_CreateLightningServerResponse serverresponse=RE_DashboardCtrl.getLoggedInUserRole();
            System.assertNotEquals(null, serverresponse);
        }
            RE_CreateLightningServerResponse serverresponse1=RE_DashboardCtrl.getLoggedInUserRole();
        	System.assertNotEquals(null, serverresponse1);
    }
}