/***************************************************************************************************************************
*   Type         :   Test Class
*   Name         :   RE_ResourceCategoryCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/11/2019
*   Description  :   This class acts as a test class for RE_ResourceCategoryCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer             Date          Description
*   * ------------------------------------------------------------------------------------                 
* 
*****************************************************************************************************************************/
@isTest
private class RE_ResourceCategoryCtrlTest {
    /*
     * Method Name : setupTestData
     * Description : method to create test records for all test methods.
     * Returns : none
    */    
    @testSetup static void setupTestData(){
        TestDataFactory.testDataSetup();        
        TestDataFactory.createDomainConfigRecords(1, true, NULL, NULL, 'DomainConfig');
    }

    /*
     * Method Name : testResourceCategories
     * Description : Method to cover functionality of method - getResourceCategories.
     * Returns : none
    */
    @isTest static void testResourceCategories() {
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse responseResult;
        Test.startTest();
        System.runAs(citizenUser){
            responseResult = RE_ResourceCategoryCtrl.getResourceCategories(true);
        }
        Test.stopTest();
        System.assertEquals(responseResult.isSuccessful, true,'Success');
    }
}