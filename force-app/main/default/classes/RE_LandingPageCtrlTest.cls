/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_LandingPageCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/16/2019
*   Description :   This class acts as a test class for RE_LandingPageCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    07/16/2019        Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_LandingPageCtrlTest {
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/16/2019 
    * @methodname   testFetchUserType
    * @description  This method is used to test the functionality of method - fetchUserType.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testFetchUserType() {   
        Test.startTest();
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        Test.stopTest();
        RE_CreateLightningServerResponse result;
        System.runAs(guestUser){
            result = RE_LandingPageCtrl.fetchUserType();
            System.assert(result.isSuccessful == true,'Success');
        }
        result = RE_LandingPageCtrl.fetchUserType();
        System.assert(result.isSuccessful == true,'Success');
    }  
}