/**
* Class Name    : RE_ProfileCtrlTest
* Owner         : DELOITTE
* Created Date  : 07/11/2019
* Description   : Test class for Resident Registration controller
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/08/2019  Payal           Initial Version
**/
@isTest
public class RE_ProfileCtrlTest {
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         07/11/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    @testSetup static void setup() {
        TestDataFactory.testDataSetup();
         List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
         Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
         citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='33223';
        if(RE_DataAccessChecker.isAllowedToCreate(Contact.getSObjectType())){
            insert citizenContact;
        }
        List<Consent__c> consentList=new List<Consent__c>();
        Consent__c consent1=(TestDataFactory.createConsent(1,false,new List<Contact>{citizenContact},lstCitizenAccounts))[0];
        Consent__c consent2=(TestDataFactory.createConsent(1,false,new List<Contact>{citizenContact},lstCitizenAccounts))[0];
        consent2.Status__c=RE_GlobalConstants.PENDING; 
        consentList.add(consent1);
        consentList.add(consent2);
        insert consentList;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
    }
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         07/11/2019
    * @methodname   getArchetypesTest
    * @description  This method is used to test the functionality of method - getArchetypes.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void getArchetypesTest() { 
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName AND isActive = true LIMIT 1];
        
        /*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        Boolean permissionsetFound=false;
        for(PermissionSetAssignment psa:[Select AssigneeId,PermissionSetId
                                         FROM PermissionSetAssignment WHERE AssigneeId=:citizenUser.Id
                                         AND PermissionSetId=:ps.Id]){
                                 permissionsetFound=true;            
         }
        if(!permissionsetFound){
            insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        }*/
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        System.runAs(citizenUser){
            result = RE_ProfileCtrl.getArchetypes();
            System.assertEquals(result.objectData.get('contactdetails') != null, true, 'Success');
            System.assertEquals(result.objectData.get('userdetails') != null, true, 'Success');
        }
        
        
        Test.stopTest();
    }
     /********************************************************************************************
    * @author       Payal Dubela
    * @date         07/11/2019
    * @methodname   getPicklistTest
    * @description  This method is used to test the functionality of method - getPicklistTest.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void getPickListValuesTest() { 
        User citizenUser = [SELECT Id, ContactId FROM User WHERE Profile.Name=: RE_GlobalConstants.strCitizenProfileName LIMIT 1];
        RE_CreateLightningServerResponse result;
        Test.startTest();
            //Positive Scenario
            result = RE_ProfileCtrl.getPickListValues('Contact','PreferredCommunicationMethod__c,Needs__c,State__c');  
            //Negative Scenario
            RE_CreateLightningServerResponse result1 = RE_ProfileCtrl.getPickListValues('TestObject','PreferredCommunicationMethod__c,Needs__c,State__c'); 
        Test.stopTest();
        System.assert(result.isSuccessful == true,'Success');
        System.assert(result1.isSuccessful == false,'Failure Scenario');
    }
     /********************************************************************************************
    * @author       Payal Dubela
    * @date         07/11/2019
    * @methodname   submitResidentInfoTest
    * @description  This method is used to test the functionality of method - submitResidentInfo.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void submitResidentInfoTest() { 
        User citizenUser ;
        User cpUser;
            
        for(User u :[SELECT Id, ContactId,Contact.AccountId,Email FROM User 
                            WHERE Email=: RE_GlobalConstants.strCitizenEmail OR Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST]){
                                if(u.Email==RE_GlobalConstants.strCitizenEmail){
                                    citizenUser=u;
                                }else{
                                    cpUser=u;
                                }           
         }
        /*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='RE_Resident'];
        Boolean permissionsetFound=false;
        for(PermissionSetAssignment psa:[Select AssigneeId,PermissionSetId
                                         FROM PermissionSetAssignment WHERE AssigneeId=:citizenUser.Id
                                         AND PermissionSetId=:ps.Id]){
             permissionsetFound=true;            
         }
        if(!permissionsetFound){
            insert new PermissionSetAssignment(AssigneeId = citizenUser.id, PermissionSetId = ps.Id);
        }*/
        Test.startTest();
        List<Account> accList=[Select Id from Account LIMIT 2];
        Contact citizenContact=new Contact();
        citizenContact.Id=citizenUser.ContactId;
        citizenContact.FirstName='Test update';
        
        System.runAs(citizenUser){
            RE_CreateLightningServerResponse result;
            RE_CreateLightningServerResponse result2;
                result = RE_ProfileCtrl.submitResidentInfo(citizenContact,true,true);
                System.assert(result.isSuccessful == true,'Success');
                result2=RE_ProfileCtrl.submitResidentInfo(null,true,true);
        }
         Test.stopTest();
    }
    
     /********************************************************************************************
    * @author       Payal Dubela
    * @date         07/22/2019
    * @methodname   updateCPUserInfoTest
    * @description  This method is used to test the functionality of method - updateCPUserInfo.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void updateCPUserInfoTest() {
        User usr= [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST];
        Contact staffContact=new Contact();
        staffContact.Id=usr.ContactId;
        staffContact.Phone='(123)53-3221';
        System.runAs(usr){
            RE_CreateLightningServerResponse result;
              result = RE_ProfileCtrl.getArchetypes();
            Test.startTest();
                result = RE_ProfileCtrl.updateCPUserInfo(staffContact);
                System.assert(result.isSuccessful == true,'Success');
                result = RE_ProfileCtrl.updateCPUserInfo(null);
            Test.stopTest();
        }
    }

}