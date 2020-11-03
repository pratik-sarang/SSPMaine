@isTest
public class RE_LineChartCtrlTest {

    @isTest
    public static void getLineChartMapTest(){
        TestDataFactory.testDataSetup();
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<Account> accountList = [SELECT id,Rating_Sum__c,Rating_Count__c FROM Account LIMIT 1];
        accountList[0].Rating_Sum__c = 8;
        accountList[0].Rating_Count__c = 2;
        update accountList;
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
        Contact objContact = [SELECT Id FROM Contact WHERE Email=:RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1];
        User cpUser = [SELECT Id,Name, ContactId FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        List<Referral__c> lstReferrals = TestDataFactory.createReferral(1, false, contactRecordTypeId, cpUser.ContactId, accountList, resourceList);
        lstReferrals[0].Status__c = 'Closed';
        lstReferrals[0].DateOfReferral__c = System.today();
        lstReferrals[0].DateClosed__c = System.today();
        insert lstReferrals;
        RE_CreateLightningServerResponse result;
        System.runAs(cpUser){
            result = RE_LineChartCtrl.getLineChartMap();
        }
        System.assert(result.isSuccessful == true,'Success');
    }
}