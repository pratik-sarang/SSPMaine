/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_ArchetypeCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/09/2019
*   Description :   This class acts as a test class for RE_ArchetypeCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    07/09/2019        Initial Version
*****************************************************************************************************************************/
@isTest
public class RE_ArchetypeCtrlTest {
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         06/17/2019
    * @methodname   setupTestData
    * @description  This method is used to create test records for all test methods
    * @param        none
    * @return       none
    ********************************************************************************************/
    static Id citizenRecordTypeIdAccount = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account',RE_GlobalConstants.strCitizenRecordTypeName);
    static Id contactCitizenRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Contact',RE_GlobalConstants.strCitizenRecordTypeName);
    static Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);
    static Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
    static Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();

    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='43527';
        insert citizenContact;
        List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(2,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
        TestDataFactory.createGoalRecords(2,true,lstArchetype);
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(lstCitizenAccounts[0].Id);
        
        List<Location__c> lstLocations = [SELECT Id FROM Location__c WHERE recordTypeId =:locationRecordTypeId LIMIT 2];
        List<Resource__c> resourceList = TestDataFactory.createResources(2, true, resourceRecordTypeId, lstAccountIds);
  	    List<Referral__c> referralRec = TestDataFactory.createReferral(2, true, referralRecordTypeId, citizenContact.Id, lstCitizenAccounts, resourceList);
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2,true,resourceRecordTypeId, lstLocations, resourceList);
        
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);
    }
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/09/2019
    * @methodname   testProcessUserInfo
    * @description  This method is used to test the functionality of method - processUserInfo.
    * @param        none
    * @return       none
    ********************************************************************************************/
    @isTest static void testProcessUserInfo() { 
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      
        Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
        RE_CreateLightningServerResponse result;
        System.runAs(citizenUser){
            result = RE_ArchetypeCtrl.processUserInfo('');  
        }
        System.assert(result.isSuccessful==true,'Success');
      Test.stopTest();
        
    }
    
    @isTest static void testMethod2(){
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      
        Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
    
        List<RE_Archetype__c> lstArchRecords = [SELECT Id,ParentArchetype__c FROM RE_Archetype__c WHERE RecordTypeId=:GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype') LIMIT 2];
        User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
        RE_CreateLightningServerResponse result;
        System.runAs(cpAdminUser){
            result = RE_ArchetypeCtrl.processUserInfo(lstArchRecords[0].Id);
            System.assert(result.isSuccessful==true,'Success');
        
        }
       Test.stopTest();
    } 
     @isTest static void testMethod3(){
	    Test.startTest();
         List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      
        Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
    
        List<RE_Archetype__c> lstArchRecords = [SELECT Id,ParentArchetype__c FROM RE_Archetype__c WHERE RecordTypeId=:GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype') LIMIT 2];
        User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
       
        System.runAs(cpAdminUser){
   
            RE_ArchetypeCtrl.getRelatedDomains();
        }
        Test.stopTest();
    }
    
    @isTest static void testMethod4(){
      Test.startTest();
      List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
      Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
      List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
      List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
      Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
      String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
     System.runAs(cpAdminUser){
            RE_ArchetypeCtrl.connectDraftReferralsFromArcheTypeResults(citizenReferral.Id, True);
            RE_ArchetypeCtrl.createFavorite(lstLocRes[0].Id);
     }
     Test.stopTest();
    }
    @isTest static void testMethod5(){
      Test.startTest();
      List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
      Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
      List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
      List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
      Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
      String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
     System.runAs(cpAdminUser){
            RE_ArchetypeCtrl.insertReferralForResident(objResourceJson,lstLocRes[0].Location__c, true);
     }
     Test.stopTest();
    }
   @isTest static void testMethod6(){
	    Test.startTest();
         List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        Contact citizenContact1 = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
      
        Referral__c citizenReferral = [SELECT Id FROM Referral__c WHERE Contacts__c =: citizenContact1.Id LIMIT 1];
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c WHERE recordTypeId =:resourceRecordTypeId LIMIT 2];
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c From LocationResource__c LIMIT 2 ];
        User citizenUser = [SELECT Id, ContactId,Contact.Email FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 1];
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocRes[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
    
        List<RE_Archetype__c> lstArchRecords = [SELECT Id,ParentArchetype__c FROM RE_Archetype__c WHERE RecordTypeId=:GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype') LIMIT 2];
        User cpAdminUser = [SELECT Id FROM User WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
       
        System.runAs(cpAdminUser){
            RE_ArchetypeCtrl.getArchetypeResources('11570','testId','testId','testDomain','','see-all',new List<String>());
            RE_ArchetypeCtrl.getOptOutInfoSharingDetails();
            
        }
        Test.stopTest();
    }
}