/*
* classname     :  SSP_GetInterpreterModalCtrlTest
* @description  :  Test Class for SSP_GetInterpreterModalCtrl
* @author       :  Varun Kochar   
* @date         :  28/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_GetInterpreterModalCtrlTest {
    @testSetup
    static void setupTestData() {
        SSP_TestDataFactory.setupTestData();  
    }
    
    @isTest
    public static void testGetInterpreterModalDetail(){
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        system.runAs(citizen){
            Test.startTest();
            SSP_GetInterpreterModalCtrl.SSP_GetInterpreterModalWrapper wrapper =(SSP_GetInterpreterModalCtrl.SSP_GetInterpreterModalWrapper) SSP_GetInterpreterModalCtrl.getGetInterpreterModalDetail('es').mapResponse.get('wrapper');
            system.assert(wrapper.interpreterModalContentInLocalLanguage != null);
            SSP_GetInterpreterModalCtrl.getGetInterpreterModalDetail('es111');
            Test.stopTest();
        }
    }
}