/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_LanguagePillSelectorCtrlTest
*   Created By   :   Deloitte
*   Created Date :   05/27/2019
*   Description :   This class acts as a test class for RE_LanguagePillSelectorCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                   05/27/2019        Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_LanguagePillSelectorCtrlTest {
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         05/27/2019
    * @methodname   testGetAllLanguageOptions
    * @description  This method is used to test the functionality of method - getAllLanguageOptions
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testGetAllLanguageOptions() {
        Test.startTest();
        RE_CreateLightningServerResponse response = RE_LanguagePillSelectorCtrl.getAllLanguageOptions();
        Test.stopTest();
        System.assert(response.isSuccessful==false,'Success');
    }
}