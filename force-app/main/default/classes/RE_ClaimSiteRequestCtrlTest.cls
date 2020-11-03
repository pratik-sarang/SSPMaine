/**
 * Class Name    : RE_ClaimSiteRequestTest{
 * Owner         : DELOITTE
 * Created Date  : 05/27/2019
 * Description   : Claim my site request record insertion test class
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
 *  05/27/2019  Arun       Initial Version
 *  Test checkin
 **/
@IsTest
public class RE_ClaimSiteRequestCtrlTest {
    @testSetup static void testClaimRequestData()  {
        //RecordType claimRecordType=GeneralUtility.fetchRecordType(RE_GlobalConstants.strClaimRecordTypeDeveloperName, RE_GlobalConstants.strClaimObjectName);
        RecordType objRecordType = GeneralUtility.fetchRecordType(System.Label.ClaimRecordTypeStaff, 'ClaimMySiteRequest__c');
        ClaimMySiteRequest__c claimReq=new ClaimMySiteRequest__c();
        claimReq.FirstName__c=RE_GlobalConstants.strClaimReqFirstName; 
        claimReq.Status__c = 'Approved';
        insert claimReq;
       
        ClaimMySiteRequest__c newclaimReq=new ClaimMySiteRequest__c();
        newclaimReq.FirstName__c=RE_GlobalConstants.strClaimReqFirstName; 
        newclaimReq.Status__c = 'New';
        newclaimReq.Email__c = 'test@test.com';
        newclaimReq.Status__c = 'New';
        newclaimReq.RecordTypeId = objRecordType.Id;
        insert newclaimReq;
        EmailSetting__c EMailSetting= new EmailSetting__c();
        EMailSetting.Name='Claim Site request submission mail';
        EMailSetting.Is_on__c = true;
        insert EMailSetting;
        EmailSetting__c EMailSettingTwo= new EmailSetting__c();
        EMailSettingTwo.Name='Claim Site Denial mail';
        EMailSettingTwo.Is_on__c = true;
        insert EMailSettingTwo;
        EmailSetting__c EMailSettingThree= new EmailSetting__c();
        EMailSettingThree.Name='Claim Site Approval mail';
        EMailSettingThree.Is_on__c = true;
        insert EMailSettingThree;
        
        TestDataFactory.testDataSetup();
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.STANDARD_USER_PROFILE_TEST];
        insert new Email_Text_Communication_Settings__c(SetupOwnerId=objProfile.Id, Email_Communication__c=true,Text_Communication__c=true);
        Id sContactId = [Select Id FROM Contact  Where Email =: RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1].Id;
        User objREUser = TestDataFactory.createSpecificCommunityUser('reusr',null, 'REUser',RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, objProfile.Id, true);
       
    }
    @isTest static void testGetClaimRequestDetails(){
        insert new Email_Text_Communication_Settings__c(Email_Communication__c=true,Text_Communication__c=true);
        Test.startTest();
        ClaimMySiteRequest__c objClaimRequest = new ClaimMySiteRequest__c();
        objClaimRequest.FirstName__c = RE_GlobalConstants.strClaimReqFirstName;
        objClaimRequest.Email__c = 'test@test.com';
        objClaimRequest.Status__c = 'Approved';
        RE_CreateLightningServerResponse response = RE_ClaimSiteRequestCtrl.saveClaimSiteRequest(objClaimRequest);
        RE_CreateLightningServerResponse roleResponse = RE_ClaimSiteRequestCtrl.fetchOrgRolePickValues();
        System.assertEquals(response.isSuccessful, true,'Success');
        Test.stopTest();
    }
    
    
    
    @isTest static void testGetClaimRequest(){
        User objUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RecordType objRecordType = GeneralUtility.fetchRecordType(System.Label.ClaimRecordTypeStaff, 'ClaimMySiteRequest__c');
        System.runAs(objUser) {
            Test.startTest();
            ClaimMySiteRequest__c objClaimRequest = new ClaimMySiteRequest__c();
            objClaimRequest.FirstName__c = RE_GlobalConstants.strClaimReqFirstName;
            objClaimRequest.Email__c = 'test@test.com';
            objClaimRequest.Status__c = 'New';
            objClaimRequest.RecordTypeId = objRecordType.Id;
            objClaimRequest.DateOfRequest__c = System.today();
            insert objClaimRequest;
            RE_CreateLightningServerResponse response = RE_ClaimSiteRequestCtrl.saveClaimSiteRequest(objClaimRequest);
            RE_CreateLightningServerResponse roleResponse = RE_ClaimSiteRequestCtrl.fetchOrgRolePickValues();
            System.assertEquals(response.isSuccessful, false,'Success');
            Test.stopTest();
        }        
    }
        
    @isTest static void testcreateCommunicationNubecord(){
        User objUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        insert new Email_Text_Communication_Settings__c(Email_Communication__c=true,Text_Communication__c=true);
        System.runAs(objUser) {
            Test.startTest();
            
            ClaimMySiteRequest__c objClaimRequest = new ClaimMySiteRequest__c();
            objClaimRequest.FirstName__c = RE_GlobalConstants.strClaimReqFirstName;
            objClaimRequest.Email__c = 'test@test.com';
            objClaimRequest.Status__c = 'Approved';
            insert objClaimRequest;
            List<Id> lstId = new List<Id>();
            lstId.add(objClaimRequest.Id);
            RE_ClaimSiteRequestCtrl.createCommunicationNubecord(lstId);
            RE_CreateLightningServerResponse response  = RE_ClaimSiteRequestCtrl.saveClaimSiteRequest(objClaimRequest);
            System.assertEquals(response.isSuccessful, false,'Success');
            Test.stopTest();
        }        
    }
    @isTest static void testcreateCommunication(){
        User objUser = [SELECT Id, ContactId FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        insert new Email_Text_Communication_Settings__c(Email_Communication__c=true,Text_Communication__c=true);
        System.runAs(objUser) {
            Test.startTest();
            
            
            ClaimMySiteRequest__c objClaimRequest = new ClaimMySiteRequest__c();
            objClaimRequest.FirstName__c = RE_GlobalConstants.strClaimReqFirstName;
            objClaimRequest.Email__c = 'test123@test.com';
            objClaimRequest.Status__c = 'Denied';
            objClaimRequest.ReasonForDenial__c = 'Test Denial';
            insert objClaimRequest;
            List<Id> lstId = new List<Id>();
            lstId.add(objClaimRequest.Id);
            RE_ClaimSiteRequestCtrl.createCommunicationNubecord(lstId);
            RE_CreateLightningServerResponse response = RE_ClaimSiteRequestCtrl.saveClaimSiteRequest(null);
            System.assertEquals(response.isSuccessful, false,'Success');
            Test.stopTest();
        }        
    }
    
}