/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_LocationCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/27/2019
*   Description :   This class acts as a test class for RE_LocationCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Prashant                    05/27/2019        Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_CustomLookUpCtrlTest {

    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         05/27/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(idAccount);
      //  Id sContactId = [SELECT Id FROM Contact WHERE Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objReUser = TestDataFactory.createSpecificCommunityUser('reusr', null, 'REUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);                
       
    }
    
    
     
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         05/27/2019
* @methodname   testGetLocationDetails
* @description  This method is used to test the functionality of method - getLocationDetails.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testfetchLookUpValues() {        
       
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        RE_CreateLightningServerResponse result1;
        RE_CreateLightningServerResponse result2;
        Test.startTest();
        System.runAs(communityUser) {
            result = RE_CustomLookUpCtrl.fetchLookUpValues('Account','Account',false);
            result1 = RE_CustomLookUpCtrl.fetchLookUpValues('Contact','Contact',false);
            result2 = RE_CustomLookUpCtrl.fetchLookUpValues('Location','Location__c',false);
        }
        Test.stopTest();
        System.assert(result.isSuccessful==true,'Success');
    }
    
    @isTest static void getObjectRecord() {        
       
        User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        RE_CreateLightningServerResponse result1;
        Test.startTest();
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        System.runAs(communityUser) {
            result = RE_CustomLookUpCtrl.getObjectRecord(idAccount,'Account');
            result1 = RE_CustomLookUpCtrl.fetchLookUpValues('12','123',false);
        }
        Test.stopTest();
        System.assert(result.isSuccessful==true,'Success');
    }
    
    @isTest static void getCustomLookupExptn(){
         
        RE_CreateLightningServerResponse result1;
        Id idAccount = [SELECT id FROM Account LIMIT 1].id;
        try{
            Test.startTest();
            result1 = RE_CustomLookUpCtrl.getObjectRecord(idAccount, null);
            Test.stopTest();
        }catch(Exception e){
            System.assert(result1.isSuccessful==false,'Exception'); 
        }
        
    }
    
}