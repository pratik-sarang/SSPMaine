/***************************************************************************************************************************
*   Type        :   Test Class 
*   Name        :   RE_GeneralUtilityTest
*   Created By   :   Deloitte
*   Created Date :   09/27/2019
*   Description :   This class acts as a test class for GeneralUtility
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Payal                    09/27/2019        Initial Version
*     Venkat Korra             08/24/2020        Added new test methods for RE Security Changes
*****************************************************************************************************************************/
@isTest
public class RE_GeneralUtilityTest {
    static Id contactCitizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> accList = [SELECT Id FROM Account LIMIT 3];
        List<Contact> conList=new List<Contact>();    
        List<Account> citizenAccounts= TestDataFactory.createAccounts(1,false,contactCitizenRecordTypeIdAccount);
        citizenAccounts[0].HasOptedOutOfAccount__c=true;
        insert citizenAccounts;
        
        conList = TestDataFactory.createContacts(1,false,contactCitizenRecordTypeId,new List<Id>{citizenAccounts[0].Id},true);
        conList[0].RecordtypeId=contactCitizenRecordTypeId;
        conList[0].MailingPostalCode='44454';
        insert conList;
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName AND Name != null];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', conList[0].Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<Resource__c> resourceList = [SELECT Id FROM Resource__c WHERE Organization__c=:accList[0].Id AND Organization__c != null LIMIT 3];
        List<Referral__c> referralList=TestDataFactory.createReferral(1,true,GeneralUtility.fetchRecordType(RE_GlobalConstants.strReferralRecordTypeDeveloperName,RE_GlobalConstants.strReferralObjectName).Id,conList[0].Id,accList,resourceList);
        EmailSetting__c emailSetting= new EmailSetting__c();
        emailSetting.Name='New User to Organization';
        emailSetting.Is_on__c = true;
        insert emailSetting; 
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strNonCitizenProfileName AND Name != null];
        insert new Email_Text_Communication_Settings__c(SetupOwnerId=objProfile.Id, Email_Communication__c=true,Text_Communication__c=true);
    }
    
    
    @isTest static void testMethod1() {
        Test.startTest();
        User staffUser = [SELECT Id,Profile.Name, ContactId,Contact.Email,Contact.Name,
                          Contact.AccountId,Contact.PermissionsLevel__c FROM User 
                          WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST AND Email != null LIMIT 1];
        Account acc=[SELECT id,NAme,ownerId FROM Account LIMIT 1];
        Referral__c ref=[Select Id FROM Referral__c LIMIT 1];
        Contact con=[Select id FROM Contact Limit 1];
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        System.runAs(staffUser){
            Profile testProf = GeneralUtility.getLoggedInUserProfile();
            String dateVal = GeneralUtility.getFormatedDate('2013-08-01 12:00:00');
            DateTime dt = System.today();
            Time myTime = Time.newInstance(1, 2, 3, 4);
            String timeVal = GeneralUtility.getOperatingHours(myTime);
            String phoneValFormat = GeneralUtility.formatphonenumber('2352525252');
            RE_CreateLightningServerResponse response = GeneralUtility.getLoggedInUserRole();
            System.assertEquals(response.isSuccessful,true,'Success');
            List<PermissionSetAssignment> lstPermission = GeneralUtility.geLoggedInUserPermissionSets();
            GeneralUtility.getUserLocale();
            GeneralUtility.getLatLong('352525');
            GeneralUtility.getFieldsFromFieldSet('Contact','Contact_MyAccountFieldset');
            GeneralUtility.getOptOutInfoSharingDetails();
            Set<Id> resIdSet = new Set<Id>();
            resIdSet.add(resourceList[0].Id);
            Set<Id> locIdSet = new Set<Id>();
            locIdSet.add(locationList[0].Id);
            GeneralUtility.getFavorites(resIdSet, locIdSet);
            GeneralUtility.getQueue('ClaimSiteQueue');
            RE_CreateLightningServerResponse optionresponse = GeneralUtility.getAllOptions('Account','Rating');
            set<Id> setFavoriteIds= GeneralUtility.getFavoriteClientIds(); 
            string Id = GeneralUtility.getContactNameFromId(staffUser.Contact.Id);
        }
        String userId=GeneralUtility.getRecordOwner('Referral__c',String.valueOf(ref.Id)); 
        GeneralUtility.AddUserWrapper test1=new GeneralUtility.AddUserWrapper();
        test1.contactId= con.Id;
        test1.systemName='test';
        test1.accountName='test';
        test1.regLink='www.test.com';
        test1.contactNumber='564863';
        test1.toemail='megmittal@deloitte.com';
        List<GeneralUtility.AddUserWrapper> list1=new List<GeneralUtility.AddUserWrapper>();
        list1.add(test1);
        RE_CreateLightningServerResponse result;    
        
        result = GeneralUtility.getAllOptions('Location__c', 'Status__c');
        result = GeneralUtility.getAllOptions('Location__c', 'Name');
        System.runAs(cpUser){
            result=GeneralUtility.addNewUserToOrg(list1); 
            GeneralUtility genClass = new GeneralUtility();
            genClass.fetchRecordTypeOfRecord(acc.Id);
        }
        test1.emailChange=true;
        List<GeneralUtility.AddUserWrapper> list2=new List<GeneralUtility.AddUserWrapper>();
        list2.add(test1);
        System.runAs(cpUser){
            result=GeneralUtility.addNewUserToOrg(list2); 
        }
        System.assertEquals(result.isSuccessful, true,'Success');
        Test.StopTest();
        
    }
    
    @isTest static void TestHoursofOperation() {
        set<Id> setLocationIds = new set<Id>();
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        setLocationIds.add(locationList[0].Id);
        list<locationResource__c> lstLocRes = [Select id,MondayOpen__c,MondayClose__c,Notes__c,Location__c from LocationResource__c where Location__c=:locationList[0].Id LIMIT 1];
        Map<Id,map<String, List<String>>> mapHoursofoperation = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(mapHoursofoperation.containsKey(lstLocRes[0].Id), true,'Success');
    }
    @isTest static void testgetLoggedInAccount()
    {
        Test.startTest();
            User communityUser = [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            Account acc = GeneralUtility.getLoggedInAccount();
        Test.stopTest();
        System.assertNotEquals(acc, null,'Success');
    }
    @isTest static void testgetUserRecord()
    {
        Test.startTest();
            User communityUser = [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            User u = GeneralUtility.getUserRecord(communityUser.Id);
        Test.stopTest();
        System.assertNotEquals(u, null,'Success');
    }
    @isTest static void testgetLoggedInUserAvailableAndSelectedRole()
    {
        Test.startTest();
            User communityUser = [SELECT Id FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            String loggedInUserAvailableRoles;
            String loggedInUserSelectedRole;
            System.runAs(communityUser){
                loggedInUserAvailableRoles = GeneralUtility.getLoggedInUserAvailableRole();
                loggedInUserSelectedRole = GeneralUtility.getLoggedInUserSelectedRole();
            }
        Test.stopTest();
        System.assertEquals(loggedInUserAvailableRoles, RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN,'Success');
        System.assertEquals(loggedInUserSelectedRole, RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN,'Success');
    }
    
    // Venkat: 8/24/2020: RE Security Changes
    /*@isTest static void testGetLoggedInAccountId()
    {
        Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = :RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST LIMIT 1];
            User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Email=: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST LIMIT 1];
            //communityUser.AccountId = acc.Id;
            communityUser.ContactId = con.Id;
            update communityUser;
            System.runAs(communityUser){
                GeneralUtility.getLoggedInAccountId();
            }
        Test.stopTest();
        System.assertEquals(communityUser.AccountId, acc.Id,'Success');
    }*/
    @isTest static void testMethod2() {
        User staffUser = [SELECT Id,Profile.Name, ContactId,Contact.Email,Contact.Name,
                          Contact.AccountId,Contact.PermissionsLevel__c FROM User 
                          WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST AND Email != null LIMIT 1];
        Account acc=[SELECT id,NAme,ownerId FROM Account LIMIT 1];
        Referral__c ref=[Select Id FROM Referral__c LIMIT 1];
        Contact con=[Select id FROM Contact Limit 1];
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
        System.runAs(staffUser){
            GeneralUtility.fetchFieldsPicklistValueAPIName('Location__c', 'Status__c');
            String conId = GeneralUtility.getLoggedInUserContactId();
            System.assertEquals(conId, staffUser.ContactId,'Success');
            String conEmail=GeneralUtility.getLoggedInUserContactEmail();
            System.assertEquals(conEmail, staffUser.Contact.Email,'Test Case 1');
            String conName=GeneralUtility.getLoggedInUserContactName();
            System.assertEquals(conName, staffUser.Contact.Name,'Test Case 2');
            String accId=GeneralUtility.getLoggedInUserAccountId();
            System.assertEquals(accId,staffUser.Contact.AccountId,'Test Case 3');
            String profileName=GeneralUtility.getLoggedInUserProfileName();
            System.assertEquals(profileName,staffUser.Profile.Name,'Test Case 4');
            List<String> picklistValues=GeneralUtility.getPicklistValues('Account','Rating');
            System.assertEquals(picklistValues.size()>0,true,'Test Case 5');
            GeneralUtility.fetchPicklistLabel('Location__c','LocationType','Headquarters');
            String conRole=GeneralUtility.getLoggedInUserContactRole();
            System.assertEquals(conRole,staffUser.Contact.PermissionsLevel__c,'Test Case 6');
            Id accOwnerId=GeneralUtility.getAccountOwnerId(acc.Id);
            System.assertEquals(accOwnerId,acc.ownerId,'Test Case 7');            
        }
        Test.stopTest();
    }
     @isTest static void testMethod3() {
        User staffUser = [SELECT Id,Profile.Name, ContactId,Contact.Email,Contact.Name,
                          Contact.AccountId,Contact.PermissionsLevel__c FROM User 
                          WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST AND Email != null LIMIT 1];
        Account acc=[SELECT id,Name,ownerId FROM Account LIMIT 1];
        Referral__c ref=[Select Id FROM Referral__c LIMIT 1];
        Contact con=[Select id FROM Contact Limit 1];
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
         System.runAs(staffUser){
             String appRole=GeneralUtility.getUserApplicableRoles(staffUser.ContactId);
             System.assertEquals(appRole!=null,true,'Positive');
             Account acc1=GeneralUtility.getLoggedInAccount();
             System.assertEquals(acc1!=null,true,'Positive');
         }
         Test.stopTest();
     }
    @isTest static void testMethod4() {
        User staffUser = [SELECT Id,Profile.Name, ContactId,Contact.Email,Contact.Name,
                          Contact.AccountId,Contact.PermissionsLevel__c FROM User 
                          WHERE Email=:RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST AND Email != null LIMIT 1];
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        List<Account> accountList = TestDataFactory.createAccounts(1,true,sREAccRecTypeId);
        Account acc=[SELECT id,Name,ownerId FROM Account LIMIT 1];
        Referral__c ref=[Select Id FROM Referral__c LIMIT 1];
        Contact con=[Select id FROM Contact Limit 1];
        List<Location__c> locationList = [SELECT id FROM Location__c LIMIT 2];
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        User cpUser = [SELECT Id FROM User WHERE Email =: RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST AND Email != null LIMIT 1];
        Test.startTest();
         System.runAs(staffUser){
              GeneralUtility.SelectedRole ='Community Partner Admin';
             GeneralUtility.assignPS(new List<String>{'Community Partner Admin'});
             GeneralUtility.getUserRolesforHeaderCmp();
             GeneralUtility.createACR(accountList[0].Id,staffUser.ContactId,'Community Partner Admin');
             GeneralUtility.getLoggedInUserAccount();
             String encryptedString=GeneralUtility.EncryptionProcess('p2s5v8y/B?E(H+MbQeThVmYq3t6w9z$C',')J@NcRfUjXn2r5u8','testdata');
             GeneralUtility.DecryptionProcess('p2s5v8y/B?E(H+MbQeThVmYq3t6w9z$C',')J@NcRfUjXn2r5u8',encryptedString);
         }
         Test.stopTest();
     }
    
    // Venkat: 8/24/2020: RE Security Changes
    @isTest static void testFailureSwitchCase()
    {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
        Test.startTest();
            Profile commUserProfile = [Select Id from Profile where name=:RE_GlobalConstants.strNonCitizenProfileName limit 1];
            Account acc=[SELECT id,NAme,ownerId FROM Account LIMIT 1];  
            Contact con = new Contact();
            con.FirstName = 'TestSwitch';
            con.LastName = 'LastNameSwitch';
            con.Email = 'FailureSwitchCase@test.com';
            con.RecordTypeId = contactRecordTypeId;
            con.AccountId = acc.Id;
            insert con;
        
            User communityUser = new User();
            communityUser.ProfileId = commUserProfile.Id;
            communityUser.Email = 'FailureSwitchCase@test.com';
            communityUser.LastName = 'LastNameUsr';
            communityUser.RE_Selected_Role__c = 'Community Partner Admin';
            communityUser.ApplicableRoles__c = 'Community Partner Admin';
            communityUser.ContactId = con.Id;
            communityUser.Alias = 'AlisTe';
            communityUser.EmailEncodingKey = 'UTF-8';
            communityUser.LanguageLocaleKey = 'en_US';
            communityUser.UserName = 'UsernameCase@test.com';
            communityUser.IsActive = true;
            communityUser.LocaleSidKey = 'en_US';
            communityUser.TimeZoneSidKey='America/Los_Angeles';
            insert communityUser;
        Set<Id> setUserIds = new Set<Id>();
        string permSetId = [SELECT Id FROM PermissionSet WHERE Label = 'RE Permission Set For Test Classes' LIMIT 1].Id;     
        User communityUser1 = new User();
        String accId;
            System.runAs(communityUser){
                accId = GeneralUtility.getLoggedInUserAccountId();
            }
        Test.stopTest();
        System.assertNotEquals(accId, null,'Success');
    }
    @isTest static void testExceptions()
    {
        String objectName;
        String lstFields;
        Id accId;
        Test.startTest();
            try{
                GeneralUtility.fetchFieldsPicklistValueAPIName(objectName, lstFields);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            try{
                GeneralUtility.getAccountOwnerId(accId);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            try{
                GeneralUtility.getAllOptions(objectName, lstFields);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            Set<Id> setResourceIds;
            Set<Id> setLocationIds;
            try{
                GeneralUtility.getFavorites(setResourceIds, setLocationIds);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            Set<Id> sLocationIds;
            List<LocationResource__c> sLocationResourceList;
            try{
                GeneralUtility.getLocationOperationHoursList(sLocationIds, sLocationResourceList);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            String clientId;
            try{
                GeneralUtility.checkConsentForClient(clientId);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
            List<String> assignedRole;
            try{
                GeneralUtility.getPermssionNamesForRole(assignedRole);
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'Success');
            }
           
            GeneralUtility.getUserApplicableRoles(null);
            
        Test.stopTest();
    }
    // Venkat: 8/24/2020: RE Security Changes
    @isTest static void testGetCommunityUsersSetting()
    {
        Test.startTest();
        RECommunityUsersConfiguration__mdt userConfig = [SELECT Label, AllowIntegrationforUserCreation__c, PermissionSets__c, ProfileName__c, Role__c 
                                                         FROM RECommunityUsersConfiguration__mdt
                                                         WHERE Label = 'RE Community Partner User Profile Admin' LIMIT 1];
        
        String sRole = 'Admin';
        List<RECommunityUsersConfiguration__mdt> lstUserConfig = GeneralUtility.getCommunityUsersSetting(sRole);
        Test.stopTest();
        System.assertNotEquals(lstUserConfig, null, 'Success');
    }
    // Venkat: 8/24/2020: RE Security Changes
    @isTest static void testCheckDuplicateUser()
    {
        List<String> lstEmails = new List<String>{'testEmail123@test.com','testEmail123@test.com'};
        Test.startTest();
        Map<String, Integer> mapConDupeEmail = GeneralUtility.checkDuplicateUser(lstEmails);
        Test.stopTest();
        System.assertNotEquals(mapConDupeEmail, null, 'Success');
    }
    
    @isTest static void testMethod5(){
        List<Location__c> locationList = [SELECT id,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
                                                   ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,DaysLocationClosed__c FROM Location__c LIMIT 2];
        locationList[0].DaysLocationClosed__c='Sunday;Monday';
        List<Resource__c> resourceList = [SELECT id FROM Resource__c LIMIT 2];
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        List<LocationResource__c> locResList=[Select Id,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
                                                   ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,DaysClosed__c
                                              FROM LocationResource__c WHERE Id=:locationRsrcList[0].Id];
        locResList[0].DaysClosed__c='Sunday';
        locResList[0].SaturdayOpen__c=null;
        locResList[0].SaturdayClose__c=null;
        locResList[0].MondayOpen__c=null;
        locResList[0].MondayClose__c=null;
        GeneralUtility.getLocationOperationHours(locationList[0],locResList[0]);
        
    }
}