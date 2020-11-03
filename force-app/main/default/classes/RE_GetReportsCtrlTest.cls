@isTest
public class RE_GetReportsCtrlTest {
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
    }
    @isTest static  void getReportTest(){
        RE_CreateLightningServerResponse result;
        Test.StartTest();
            User communityUser = [SELECT Id,ContactId FROM USER WHERE Email =:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
            System.runAs(communityUser) {
                result=RE_GetReportsCtrl.getReports();
            }
        Test.StopTest();  
        System.assert(result.isSuccessful==false,'Success');
    }
    @isTest static void getReportTest2(){
        Test.StartTest();
            RE_CreateLightningServerResponse result=RE_GetReportsCtrl.getReports();
            System.assert(result.isSuccessful==true,'Success');
        Test.StopTest();
    }
}