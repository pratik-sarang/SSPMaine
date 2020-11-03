/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_ShareEmailCtrlTest
*   Created By   :   Deloitte
*   Created Date :   06/17/2019
*   Description :   This class acts as a test class for RE_ShareEmailCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    06/17/2019        Initial Version
*     Lagan Kankane              06/17/2019        Added Test method for ShareResourceDetailsViaPhone method on RE_ShareEmailCtrl
*****************************************************************************************************************************/
@isTest
private class RE_ShareEmailCtrlTest {
    static Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setupTestData(){        
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.ContactGeoLocation__Latitude__s = RE_GlobalConstants.dContactLocLatitude;
        citizenContact.ContactGeoLocation__Longitude__s = RE_GlobalConstants.dContactLocLongitude; 
        citizenContact.MailingPostalCode='35271';
        citizenContact.Phone='+919666709343';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
       /* List<Account> accountList = TestDataFactory.createAccounts(1,true,assisterAccountRecordTypeId);
        // Venkat: Assister account and contact creation
        List<Account> lstAssisterAccounts = [SELECT Id FROM Account WHERE recordTypeId=:assisterAccountRecordTypeId LIMIT 1];
        Contact assisterContact = TestDataFactory.createContactRecord(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME,RE_GlobalConstants.CONTACT_LASTNAME,RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST,assisterContactRecordTypeId,false);
        assisterContact.AccountId=lstAssisterAccounts[0].Id;
        assisterContact.ContactGeoLocation__Latitude__s = RE_GlobalConstants.dContactLocLatitude;
        assisterContact.ContactGeoLocation__Longitude__s = RE_GlobalConstants.dContactLocLongitude; 
        assisterContact.MailingPostalCode='35271';
        assisterContact.Phone='+919666709343';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert assisterContact;
        }
        
        // Venkat: Assister profile and user creation
        Profile assisterProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.RE_ASSISTER_PROFILE];
        User assisterUser = TestDataFactory.createUser('assUsr', assisterProfile.Id, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, RE_GlobalConstants.SAMPLE_USER_EMAIL_TEST, false); 
        assisterUser.ContactId = assisterContact.Id;
        assisterUser.Phone = '(999) 909-8909';
        insert assisterUser;
        */
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, false); 
        citizenUser.Phone = '(898) 909-8909';
        insert citizenUser;
        insert new Email_Text_Communication_Settings__c(SetupOwnerId=citizenProfile.Id, Email_Communication__c=true,Text_Communication__c=true);
        EmailSetting__c emailSetting= new EmailSetting__c();
        emailSetting.Name='Share Resource Information';
        emailSetting.Is_on__c = true;
        insert emailSetting;
        
        Communication_Hub_Settings__c commSetting= new Communication_Hub_Settings__c();
        commSetting.InterfaceImplementingClassName__c='RE_SendSMSClass';
        insert commSetting;
        
        
        
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='SMSThroughTwilio';
        setting.Account_API_Key__c='AC713dcee58bc77111cc0d6fdae01abc74';
        setting.Endpoint_URI__c='https://api.twilio.com/2010-04-01/Accounts/';
        setting.Content_Type__c='application/x-www-form-urlencoded';
        setting.Http_Method_Type__c='POST';
        setting.Password__c='test123';
        setting.FromPhone__c='123456789';
        insert setting;
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   testCheckIfCitizenUser
    * @description  This method is used to test the functionality of method - checkIfCitizenUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testCheckIfCitizenUser() {   
        User citizenUser = [SELECT Id, ContactId,Contact.OwnerId FROM User WHERE RE_Selected_Role__c=: RE_GlobalConstants.strCitizenAppRole 
                            and IsActive = true LIMIT 1];
        //Venkat: Added Username condition
        User RE_ASSISTER_PROFILE = [SELECT Id, ContactId,Contact.OwnerId FROM User WHERE RE_Selected_Role__c=: RE_GlobalConstants.ASSISTER 
                            and IsActive = true LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result = RE_ShareEmailCtrl.checkIfCitizenUser();
        }
        System.runAs(RE_ASSISTER_PROFILE){
            result = RE_ShareEmailCtrl.checkIfCitizenUser();
        }
        Test.stopTest();
        System.assert(result.objectData.get('isCitizenProfileUser') == 'true','Success');
    }      
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   testCheckIfCitizenUserNameHasNull
    * @description  This method is used to test the functionality of method - checkIfCitizenUser.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testCheckIfCitizenUserNameHasNull() {   
        User citizenUser = [SELECT Id, ContactId,FirstName,LastName FROM User WHERE RE_Selected_Role__c=: RE_GlobalConstants.strCitizenAppRole AND IsActive = true AND Phone!='' LIMIT 1];
        citizenUser.FirstName = null;
        update citizenUser;
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result = RE_ShareEmailCtrl.checkIfCitizenUser();
        }
        Test.stopTest();
        System.assert(result.objectData.get('isCitizenProfileUser') == 'true','Success');
    }   
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   testShareResourceDetailsViaEmail
    * @description  This method is used to test the functionality of method - shareResourceDetailsViaEmail.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testShareResourceDetailsViaEmail() {   
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Contact.RecordTypeId =: contactCitizenRecordTypeId LIMIT 1];
        Map<String,Object> resourceDetailsWrapper = new Map<String,Object>();
        resourceDetailsWrapper.put('sResourceName','testResource123');
        resourceDetailsWrapper.put('resourceId','36eehdckdch');
        resourceDetailsWrapper.put('sLocationCity','TestCity');
        resourceDetailsWrapper.put('sLocationState','TestState');
        resourceDetailsWrapper.put('sLocationZip','TestCity');
        resourceDetailsWrapper.put('sLocationZipExt','null');
        resourceDetailsWrapper.put('sLocationAddress1','sLocationAddress1');
        resourceDetailsWrapper.put('sLocationAddress2','sLocationAddress2');
        resourceDetailsWrapper.put('sPOCPhone','2231332e');
        resourceDetailsWrapper.put('sReferralOrgUrl','www.test.com');
        resourceDetailsWrapper.put('sEmail','test@dummy.com');
        resourceDetailsWrapper.put('sResourceDescription','TestDescription');
        resourceDetailsWrapper.put('HoursOfOperationHeader','Test');
        resourceDetailsWrapper.put('sReferralOrgAddress1','TestAddr');
        resourceDetailsWrapper.put('sReferralOrgName','TestOrg');
        
        Map<String,String> mapInputWrapper = new Map<String,String>();
        mapInputWrapper.put('yourName','TestUser');
        mapInputWrapper.put('yourEmail','test@test.com');
        mapInputWrapper.put('toEmail','test@testEmail.com');
        Test.startTest();
        System.runAs(citizenUser){
            System.assertEquals(true, RE_ShareEmailCtrl.shareResourceDetailsViaEmail(resourceDetailsWrapper,mapInputWrapper).isSuccessful,'Success') ;
        }
        Test.stopTest();        
    } 
/********************************************************************************************
* @author       Lagan Kankane
* @date         07/16/2019
* @methodname   testShareResourceDetailsViaPhone
* @description  This method is used to test the functionality of method - ShareResourceDetailsViaPhone.
* @param        none
* @return       none
********************************************************************************************/
    @isTest 
    static void testShareResourceDetailsViaPhone() {   
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Contact.RecordTypeId =: contactCitizenRecordTypeId LIMIT 1];
        Map<String,Object> resourceDetailsWrapper = new Map<String,Object>();
        resourceDetailsWrapper.put('sResourceName','testResource123');
        resourceDetailsWrapper.put('resourceId','36eehdckdch');
        resourceDetailsWrapper.put('sReferralOrgCity','TestCity');
        resourceDetailsWrapper.put('sReferralOrgState','TestState');
        
        Map<String,Object> resourceDetailsWrapper2 = new Map<String,Object>();
        resourceDetailsWrapper2.put('sResourceName','');
        resourceDetailsWrapper2.put('resourceId','');
        resourceDetailsWrapper2.put('sReferralOrgCity','');
        resourceDetailsWrapper2.put('sReferralOrgState','');
        
        Map<String,String> mapInputWrapper = new Map<String,String>();
        mapInputWrapper.put('yourName','TestUser');
        mapInputWrapper.put('yourPhone','1234567654');
        mapInputWrapper.put('recourceDetailUrl','www.abc.com');
        mapInputWrapper.put('toEmail','test@testEmail.com');
        mapInputWrapper.put('toPhone','+919666709343');
        
        Map<String,String> mapInputWrapper2 = new Map<String,String>();
        mapInputWrapper2.put('yourName','TestUser null');
        mapInputWrapper2.put('yourPhone','1234567654');
        mapInputWrapper2.put('recourceDetailUrl','www.abc.com');
        mapInputWrapper2.put('toEmail','test@testEmail.com');
        mapInputWrapper2.put('toPhone','+919666709343');
        
        Map<String,String> mapInputWrapper3 = new Map<String,String>();
        mapInputWrapper3.put('yourName',null);
        mapInputWrapper3.put('yourPhone','1234567654');
        mapInputWrapper3.put('recourceDetailUrl','www.abc.com');
        mapInputWrapper3.put('toEmail','test@testEmail.com');
        mapInputWrapper3.put('toPhone','+919666709343');
        
        
        Test.startTest();
        System.runAs(citizenUser){
            RE_ShareEmailCtrl.shareResourceDetailsViaPhone(resourceDetailsWrapper,mapInputWrapper);
            RE_ShareEmailCtrl.shareResourceDetailsViaPhone(resourceDetailsWrapper,mapInputWrapper2);
            List<CommunicationLog__c> objCentralHub = [SELECT Id,Recipient_Phone_Number__c FROM CommunicationLog__c WHERE Recipient_Phone_Number__c ='+919666709343' LIMIT 1];
           
            if(objCentralHub.size()>0)
             System.assertEquals(objCentralHub[0].Recipient_Phone_Number__c, '+919666709343');
        }
        Test.stopTest();
        RE_ShareEmailCtrl.shareResourceDetailsViaPhone(resourceDetailsWrapper,mapInputWrapper3);
               
    }
}