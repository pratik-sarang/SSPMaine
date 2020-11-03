/*
* Component Name    : RE_ReferralDashboardCtrlTest
* Owner             : Sai Kiran Velpula
* Created Date      : 09/24/2019
* Description       : Referral Dashboard Controller Test Class
*/
@isTest
public class RE_ReferralDashboardCtrlTest {   
    /*
    *Method Name: getStatisticsDataTest
    *Description: Method to cover functionality of method - getStatisticsData.
    *Returns: none
    */
    @isTest static void getStatisticsDataTest() {
        TestDataFactory.testDataSetup();
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<Account> accountList = [SELECT id,Rating_Sum__c,Rating_Count__c FROM Account LIMIT 1];
        accountList[0].Rating_Sum__c = 8;
        accountList[0].Rating_Count__c = 2;
        update accountList;
        RecordType objRecordType = [SELECT ID from RecordType where DeveloperName = 'CPUserContact' AND sObjectType = 'Contact'];
        Contact objContact = TestDataFactory.createContactRecord('FirstName', 'LastName', 'test@email.com', objRecordType.Id, true);
        User cpUser = [SELECT Id,Name, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        List<Referral__c> lstReferrals = TestDataFactory.createReferral(1, false, objRecordType.Id , cpUser.ContactId, accountList, resourceList);
        lstReferrals[0].Status__c = 'Closed';
        lstReferrals[0].DateOfReferral__c = System.today();
        lstReferrals[0].DateClosed__c = System.today();
        insert lstReferrals;
        Test.startTest();
        RE_CreateLightningServerResponse result1;
        RE_CreateLightningServerResponse result2;
        System.runAs(cpUser){
            result1 = RE_ReferralDashboardCtrl.getStatisticsData();
            
        }
        System.assert(result1.isSuccessful == true,'Success');
        Test.stopTest(); 
    }
    
    /*
    *Method Name: getStatisticsDataTest
    *Description: Method to cover functionality of method - getStatisticsData.
    *Returns: none
    */
    @isTest static void getStatisticsDataUpdateTest() {
        TestDataFactory.testDataSetup();
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<Account> accountList = [SELECT id,Rating_Sum__c,Rating_Count__c FROM Account LIMIT 1];
        accountList[0].Rating_Sum__c = 8;
        accountList[0].Rating_Count__c = 2;
        update accountList;
        RecordType objRecordType = [SELECT ID from RecordType where DeveloperName = 'CPUserContact' AND sObjectType = 'Contact'];
        Contact objContact = TestDataFactory.createContactRecord('FirstName', 'LastName', 'test@email.com', objRecordType.Id, true);
        User cpUser = [SELECT Id,Name, ContactId FROM User WHERE Email='communityusr@deloitte.com' LIMIT 1];
        List<Referral__c> lstReferrals = TestDataFactory.createReferral(1, false, objRecordType.Id , cpUser.ContactId, accountList, resourceList);
        lstReferrals[0].Status__c = 'Closed';
        lstReferrals[0].DateOfReferral__c = System.today();
        lstReferrals[0].DateClosed__c = System.today();
        insert lstReferrals;
        Test.startTest();
        RE_CreateLightningServerResponse result1;
        RE_CreateLightningServerResponse result2;
       
        accountList[0].Rating_Count__c = 0;
        update accountList;
        System.runAs(cpUser){
            result2 = RE_ReferralDashboardCtrl.getStatisticsData();
            
        }
        System.assert(result2.isSuccessful == true,'Success');
        Test.stopTest(); 
    }
}