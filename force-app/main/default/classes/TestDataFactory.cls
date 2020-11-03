/***************************************************************************************************************************
*   Type        :   Test Data Utility Class
*   Name        :   TestDataFactory
*   Create By   :   Suyash Singhal
*   Create Date :   04/24/2019
*   Description :   This class is used to create common test data.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer             Date            Description
*   * ------------------------------------------------------------------------------------                 
*   Tommaso                 07/29/2020      Added methods for SSP_KnowledgeArticleCtrlrTest
*   Venkat Korra            8/15/2020       Refactoring TestDataFactory for RE Security Changes                    
*****************************************************************************************************************************/
@isTest
public class TestDataFactory {
    
    public static String testSurveyLink='www.testsurvey.com';
    /*
        @author       : Deeksha Gupta
        @date         : 05/28/2019
        @method       : testDataSetup()
        @description  : static method to create test data
        @params       : 
        @return       : 
    */
    // code added by Pankaj
    public static void testDataSetup(){
        createCrudAndAccessibilitySettings(); // Do not remove as this enforces CRUD and field accessibility settings
        createLogMsgSettings();
        createMapLatLogSettings();
		createSDOHcustomSettings();
		createREPropertiesCustomSettings();
		 
        Community_URL_Settings__c cs_URL=new Community_URL_Settings__c();
        cs_URL.URL__c='https://benefind--r1dev.my.salesforce.com/';
        insert cs_URL;
        Id sCitizenAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
        Id sREAccRecTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine');
        
        List<Account> accountList = TestDataFactory.createAccounts(5,true,sREAccRecTypeId);
        List<Account> citizenAccountList = TestDataFactory.createAccounts(5,true,sCitizenAccRecTypeId);
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(accountList[0].Id);
        // CP User Contact record type
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strNonCitizenRecordTypeName).getRecordTypeId();
        Contact objREAdminContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, RE_GlobalConstants.CPADMIN_USER1_EMAIL_TEST,RE_GlobalConstants.ADMIN_ROLE, contactRecordTypeId, true);
        Contact objREStaffContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_STAFF_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, RE_GlobalConstants.CONTACT_EMAIL_TEST , RE_GlobalConstants.STAFF_ROLE, contactRecordTypeId, true);
        
        Contact objREAgencyAdminContact = TestDataFactory.createAgencyContact(RE_GlobalConstants.CONTACT_AGENCY_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, RE_GlobalConstants.AGENCY_ADMIN_USER1_EMAIL_TEST,RE_GlobalConstants.AGENCY_ADMIN_ROLE , contactRecordTypeId, true);
        Contact objREAgencyStaffContact = TestDataFactory.createAgencyContact(RE_GlobalConstants.CONTACT_AGENCY_STAFF_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, RE_GlobalConstants.AGENCY_ADMIN_USER1_EMAIL_TEST, RE_GlobalConstants.AGENCY_STAFF_ROLE , contactRecordTypeId, true);
		Id citizenContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.CITIZEN).getRecordTypeId();
        Contact objCitizenContact = TestDataFactory.createCitizenContact(RE_GlobalConstants.CONTACT_CITIZEN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME, RE_GlobalConstants.strCitizenEmail,RE_GlobalConstants.strCitizenEmail , citizenContactRecordTypeId, true);
        
        //Kojashrri
     	Contact objREAssisterContact = TestDataFactory.createCPContact(RE_GlobalConstants.CONTACT_ADMIN_FIRSTNAME, RE_GlobalConstants.CONTACT_LASTNAME,  RE_GlobalConstants.ASSISTER_USER_EMAIL_TEST, RE_GlobalConstants.ADMIN_ROLE, contactRecordTypeId, true);
      
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> resourceList = TestDataFactory.createResources(2, true, resourceRecordTypeId, lstAccountIds);
        
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> locationList = TestDataFactory.createLocations(2, true, locationRecordTypeId, lstAccountIds);
        List<LocationResource__c> locationRsrcList = TestDataFactory.createLocationResource(2,true,null,locationList,resourceList);
        
		String applicableRoles = 'Citizen; Community Partner Admin; Community Partner Staff; Case Worker; Case Worker Supervisor; Assister';
        
        User objAdminUser = TestDataFactory.createCommunityUser(RE_GlobalConstants.ADMIN_USER_ALIAS, objREAdminContact.Id, RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_USER_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN,true);
        assignPermissionId(new Set<Id>{objAdminUser.Id});
        User objStaffUser = TestDataFactory.createCommunityUser(RE_GlobalConstants.STAFF_USER_ALIAS, objREStaffContact.Id, RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_USER_STAFF_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_PARTNER_STAFF,true);
        assignPermissionId(new Set<Id>{objStaffUser.Id});
        User objAgencyAdminUser = TestDataFactory.createCommunityUser(RE_GlobalConstants.AGENCY_ADMIN_USER_ALIAS, objREAgencyAdminContact.Id, RE_GlobalConstants.COMMUNITY_AGENCY_USER_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_AGENCY_USER_EMAIL_TEST,RE_GlobalConstants.CASE_WORKER_SUPERVISOR,true);
        assignPermissionId(new Set<Id>{objAgencyAdminUser.Id});
        User objAgencyStaffUser = TestDataFactory.createCommunityUser(RE_GlobalConstants.AGENCY_STAFF_USER_ALIAS, objREAgencyStaffContact.Id, RE_GlobalConstants.COMMUNITY_AGENCY_USER_STAFF_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_AGENCY_USER_STAFF_EMAIL_TEST,RE_GlobalConstants.CASE_WORKER,true);
        assignPermissionId(new Set<Id>{objAgencyStaffUser.Id});
        //Kojashrri
		User objAssisterUser = TestDataFactory.createAssisterUser(RE_GlobalConstants.ASSISTER_USER_ALIAS, objREAssisterContact.Id, RE_GlobalConstants.ASSISTER_USER_EMAIL_TEST, RE_GlobalConstants.ASSISTER_USER_EMAIL_TEST, true);
        assignPermissionId(new Set<Id>{objAssisterUser.Id});
        // Venkat
        User objCitizenUser = TestDataFactory.createCitizenUser(RE_GlobalConstants.CITIZEN_USER_ALIAS, objCitizenContact.Id, RE_GlobalConstants.COMMUNITY_CITIZEN_EMAIL_TEST,RE_GlobalConstants.COMMUNITY_CITIZEN_EMAIL_TEST,true);
		//
        insert new KOGWebservice__c(name = 'KOG Inquiry Service', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG CP Admin', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG CP Staff', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG Agency Admin', KOG_Login_URL__c = 'abc');
        insert new KOGWebservice__c(name = 'KOG Agency Staff', KOG_Login_URL__c = 'abc');
        // public group assignments custom settings
        insert new PublicGroupAssignments__c(name = 'Assister Assignment', ProfileName__c = 'RE Assister Profile', PublicGroupName__c='RE_Assister_Users',Executeforallchanges__c=true);
        insert new PublicGroupAssignments__c(name = 'CP User Assignment', ProfileName__c = 'RE Community Partner User Profile', PublicGroupName__c='RE_Community_Partner_Users',Executeforallchanges__c=true);
        insert new PublicGroupAssignments__c(name = 'State User Assignment', ProfileName__c = 'RE State User', PublicGroupName__c='RE_StateUsers',Executeforallchanges__c=true);
        insert new PublicGroupAssignments__c(name = 'UW Staff User', ProfileName__c = 'RE United Way Staff', PublicGroupName__c='RE_StateUsers',QueueName__c='ClaimSiteQueue',Executeforallchanges__c=true);
        insert new PublicGroupAssignments__c(name = 'Agency User Assignment', ProfileName__c = 'RE Agency User Profile', PublicGroupName__c='RE_Agency_Users',Executeforallchanges__c=true);
    }
    
    public static void assignPermissionId(Set<Id> setIds){
        //RE_UserCreationHelper.assignPermissionSetOnCreate(setIds);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'RE_Permission_Set_For_Test_Classes'];
       // Assign the above inserted user for the above Permission Set.
        List<PermissionSetAssignment> lstPrmsts = new List<PermissionSetAssignment>();
        for(Id userId : setIds){
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
           lstPrmsts.add(psa);
        }
        System.runAs(new User(Id= UserInfo.getUserId())){
           insert lstPrmsts;
        }
    }
    /**
    @author       : Deeksha Gupta
    @date         : 06/19/2019
    @description  : static method to create "createCrudAndAccessibilitySettings" custom settings record
    @params       : none 
    @return       : none
    */  
    
    public static void createCrudAndAccessibilitySettings(){
        CrudAndAccessibilitySettings__c cs = new CrudAndAccessibilitySettings__c();
        cs.CRUD__c = true;
        cs.FieldAccessibilityCheck__c = true;
        insert cs;
    }
    /**
    @author       : Deeksha Gupta
    @date         : 07/03/2019
    @description  : static method to create "LOG_LogMessageSettings__c" custom settings record
    @params       : none 
    @return       : none
    */  
    
    public static void createLogMsgSettings(){
        LOG_LogMessageSettings__c logMsg = new LOG_LogMessageSettings__c();
        logMsg.Name='TestLogCustomSettings';
        logMsg.LOG_Error__c=true;
        logMsg.LOG_Debug__c=true;
        logMsg.LOG_Info__c=true;
        logMsg.LOG_Warning__c=true;
        logMsg.LOG_Log_Purge__c=365;
        insert logMsg;
    }
    
    /**
    @author       : Suyash Singhal
    @date         : 04/24/2019
    @description  : static method to create Accounts
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Account Record Type to be inserted 
    @return       : list of Account records
    */  
    
    public static List<Account> createAccounts(Integer intCount, Boolean doInsert, Id recordTypeId)
    {
        List<Account> lstAccounts = new List<Account>();
        for(integer i=1 ; i<=intCount; i++ ){
            Account objAccount = new Account(Name = 'Account' +i,
                                                RecordTypeId = recordTypeId,
                                                Status__c=RE_GlobalConstants.sAccountStatus 
                                            );
            lstAccounts.add(objAccount);
        }
        if(!lstAccounts.isEmpty() && doInsert){
            insert lstAccounts;
        }
        return lstAccounts;
    }
     /**
    @author       : Pankaj Mohanta
    @date         : 06/19/2019
    @description  : generic method to create Contact record
    @params       : String sFirstName, String sLastName, String email, String sRecordTypeId, Boolean bInsert

    @return       : Contact object
    */  
    public static Contact createContactRecord(String sFirstName, String sLastName, String email, String sRecordTypeId, Boolean bInsert){
        Contact objContact = new Contact();
        objContact.FirstName = sFirstName;
        objContact.LastName = sLastName;
        objContact.Email = email;
        objContact.recordTypeId = sRecordTypeId;
        objContact.MailingPostalCode=String.valueOf(RE_GlobalConstants.dZipCode_TEST);
        if(bInsert){
            insert objContact;
        }
        return objContact;
    }
    public static Contact createCPContact(String sFirstName, String sLastName, String email, String sRole, String sRecordTypeId, Boolean bInsert){
        Contact objContact = createContactRecord(sFirstName, sLastName, email, sRecordTypeId, false);
        objContact.PermissionsLevel__c = sRole;
        objContact.Status__c = RE_GlobalConstants.STATUS_ACTIVE;
        Account objAccount  = [SELECT Name, Owner.Name, Owner.UserRole.Name, Owner.Profile.Name FROM Account LIMIT 1];//[Select Id, ownerId From Account Where Name = 'Account1' LIMIT 1];
        objContact.AccountId = objAccount.Id;
        /*objContact.MailingStreet ='33 3rd Avenue';
        objContact.MailingState='New York';
        objContact.MailingCountry='USA';
        objContact.MailingPostalCode='52725';
        objContact.MailingCity='New York City';*/
        Id accOwnerId =  objAccount.ownerId;
        objContact.ownerId = accOwnerId;
        if(bInsert){
            insert objContact;
        }
        return objContact;
    }
    public static Contact createAgencyContact(String sFirstName, String sLastName, String email, String sRole, String sRecordTypeId, Boolean bInsert){
        Contact objContact = createContactRecord(sFirstName, sLastName, email, sRecordTypeId, false);
        objContact.PermissionsLevel__c = sRole;
        objContact.Status__c = RE_GlobalConstants.STATUS_ACTIVE;
        Account objAccount  = [SELECT Name, Owner.Name, Owner.UserRole.Name, Owner.Profile.Name FROM Account LIMIT 1];
        objContact.AccountId = objAccount.Id;
        Id accOwnerId =  objAccount.ownerId;
        objContact.ownerId = accOwnerId;
        if(bInsert){
            insert objContact;
        }
        return objContact;
    }
    public static Contact createCitizenContact(String sFirstName, String sLastName, String sUserName, String sEmail, String sRecordTypeId, Boolean bInsert){
        Contact objContact = createContactRecord(sFirstName, sLastName, sEmail, sRecordTypeId, false);
        objContact.Status__c = RE_GlobalConstants.STATUS_ACTIVE;
        Account objAccount  = [SELECT Name, Owner.Name, Owner.UserRole.Name, Owner.Profile.Name FROM Account LIMIT 1];
        objContact.AccountId = objAccount.Id;
        Id accOwnerId =  objAccount.ownerId;
        objContact.ownerId = accOwnerId;
        if(bInsert){
            insert objContact;
        }
        return objContact;
    }
    
    /**
    @author       : Suyash Singhal
    @date         : 04/24/2019
    @description  : static method to create Contacts
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Contact Record Type to be inserted 
                    List<String> lstParentAccountIds - Holds the Contacts Accounts
                    bSameAccOnAllCons -  Boolean to use single account on all Contacts. By this it will take the first account
                                        from the List of ParentAccountIds   
                    
    @return       : list of contact records
    */  
    
    public static List<Contact> createContacts(Integer intCount, 
                                               Boolean doInsert, 
                                               Id recordTypeId, 
                                               List<Id> lstParentAccountIds,
                                               Boolean bSameAccOnAllCons
                                              )
    {
        Account objAccount  = [Select Id, ownerId From Account where Id IN: lstParentAccountIds LIMIT 1];
        Id accOwnerId =  objAccount.ownerId;
        List<Contact> lstContacts = new List<Contact>();                                          
        if(lstParentAccountIds !=null && !lstParentAccountIds.isEmpty()){
            for(integer i=0 ; i< intCount; i++ ){
                 Contact objContact = new Contact(FirstName = 'sample'+i,
                                                     LastName = Integer.valueof((Math.random() * 100))+'Individual',
                                                     Birthdate = (Date.today()).addYears(-23),
                                                     AccountId = lstParentAccountIds[0],
                                                     Email = 'cpadmin'+i+Integer.valueof((Math.random() * 100))+'@deloitte'+i+'.com',
                                                     PermissionsLevel__c=RE_GlobalConstants.ADMIN_ROLE,
                                                     Status__c=RE_GlobalConstants.STATUS_ACTIVE,
                                                     ownerId = accOwnerId,
                                                     TrainingLevel__c='Complete'
                                                     //RecordTypeId = recordTypeId 
                                                    );
                lstContacts.add(objContact);
                
            }
            if(!lstContacts.isEmpty() && doInsert){
                insert lstContacts;
            }
        }
        return lstContacts;
    }
    
    public static List<Contact> createStaffContacts(Integer intCount, 
                                               Boolean doInsert, 
                                               Id recordTypeId, 
                                               List<Id> lstParentAccountIds,
                                               Boolean bSameAccOnAllCons
                                              )
    {
        List<Contact> lstContacts = new List<Contact>();        
        Account objAccount  = [Select Id, ownerId From Account where Id IN: lstParentAccountIds LIMIT 1];
        Id accOwnerId =  objAccount.ownerId;
        if(lstParentAccountIds !=null && !lstParentAccountIds.isEmpty()){
            for(integer i=1 ; i<intCount; i++ ){
                 Contact objContact = new Contact(FirstName = 'sample staff',
                                                     LastName = 'Individual',
                                                     AccountId = lstParentAccountIds[0],
                                                     Email = 'cpstaffuser'+i+'@deloitte.com',
                                                     PermissionsLevel__c=RE_GlobalConstants.STAFF_ROLE,
                                                     Status__c=RE_GlobalConstants.STATUS_ACTIVE,
                                                     TrainingLevel__c='Complete',
                                                     ownerId = accOwnerId,
                                                     RecordTypeId = recordTypeId 
                                                    );
                lstContacts.add(objContact);
                
            }
            if(!lstContacts.isEmpty() && doInsert){
                insert lstContacts;
            }
        }
        return lstContacts;
    }
    
    /**
    @author       : Suyash Singhal
    @date         : 04/25/2019
    @description  : static method to create Location records
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Location Record Type to be inserted 
                    List<String> lstParentAccountIds - Holds the Parent Record Ids
                    
                    
    @return       : list of Location records
    */  
    
    public static List<Location__c> createLocations(Integer intCount, 
                                                Boolean doInsert, 
                                                Id recordTypeId, 
                                                List<Id> lstParentAccountIds
                                                
                                               )
    {
        List<Location__c> lstLocations = new List<Location__c>();
        
        for(integer i=1 ; i<=intCount; i++ ){
            
            Location__c objLocation = new Location__c();
            objLocation.Account__c=lstParentAccountIds[0];
            objLocation.Address1__c='test Addr1';
            objLocation.Address2__c='test Addr2';
            objLocation.City__c='test City';
            objLocation.Email__c='dummy@test.com';
            objLocation.LocationType__c='Headquarters'; 
            objLocation.Phone__c='9898789900'; 
            objLocation.PointOfContactName__c='Test Contact Name'; 
            objLocation.PointofContactEmail__c='testCon@dummy.com'; 
            objLocation.PointofContactPhone__c='988668800';
            objLocation.SaturdayClose__c=Time.newInstance(16, 30, 2, 20);
            objLocation.SaturdayOpen__c=Time.newInstance(8, 30, 2, 20);
            objLocation.State__c='Ohio';
            objLocation.Zip__c=12346;
            objLocation.Geolocation__Latitude__s = Decimal.valueOf('41.4986961');
            objLocation.Geolocation__Longitude__s = Decimal.valueOf('-90.7722974');
            objLocation.SundayClose__c=Time.newInstance(17, 30, 2, 20);
            objLocation.SundayOpen__c=Time.newInstance(10, 30, 2, 20); 
            objLocation.MondayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocation.MondayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocation.TuesdayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocation.TuesdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocation.WednesdayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocation.WednesdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocation.ThursdayClose__c=Time.newInstance(18, 00, 2, 20);
            objLocation.ThursdayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocation.FridayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocation.FridayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocation.SaturdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocation.SaturdayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocation.Status__c='Active';
            lstLocations.add(objLocation);
            
        }
        if(!lstLocations.isEmpty() && doInsert){
            insert lstLocations;
        }
        
        return lstLocations;
        
    }
    
    
    /**
    @author       : Suyash Singhal
    @date         : 04/25/2019
    @description  : static method to create Resources records
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Resource Record Type to be inserted 
                    List<String> lstParentAccountIds - Holds the Parent Record Ids
                    
                    
    @return       : list of Resource records
    */  
    
    public static List<Resource__c> createResources(Integer intCount, 
                                                    Boolean doInsert, 
                                                    Id recordTypeId, 
                                                    List<Id> lstParentAccountIds
                                                    )
    {
        List<Resource__c> lstResources = new List<Resource__c>();
        
        for(integer i=1 ; i<=intCount; i++ ){
            
            Resource__c objResource = new Resource__c();
            objResource.ResourceType__c='Services';
            objResource.Organization__c=lstParentAccountIds[0];
            objREsource.SdohDomain__c='Employment';
            lstResources.add(objResource);
            
        }
        if(!lstResources.isEmpty() && doInsert){
            insert lstResources;
        }
        
        return lstResources;
        
    }
    /**
    @author       : 
    @date         : 05/24/2019
    @description  : static method to create Location Resource records
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Location Record Type to be inserted 
                    List<String> lstParentAccountIds - Holds the Parent Record Ids
                    
                    
    @return       : list of Location Resource records
    */  
    
    public static List<LocationResource__c> createLocationResource(Integer intCount, 
                                                Boolean doInsert, 
                                                Id recordTypeId, 
                                                List<Location__c> lstLocations,
                                                List<Resource__c> lstResource
                                                
                                               )
    {
        List<LocationResource__c> lstLocationResource = new List<LocationResource__c>();
        
        for(integer i=0 ; i<intCount; i++ ){
            
            LocationResource__c objLocationResource = new LocationResource__c();
            objLocationResource.Resource__c = lstResource[i].Id;
            objLocationResource.Location__c = lstLocations[i].Id;
            objLocationResource.Status__c='Active';
            objLocationResource.Notes__c = ' test Loc Res Notes';
            objLocationResource.ResourceDescription__c = 'Test Description';
            objLocationResource.FirstPointofContactEmail__c = 'test1poc@test.com';
            objLocationResource.FirstPointOfContactName__c = 'Test First POC';
            objLocationResource.FirstPointofContactPhone__c = '988668800';
            objLocationResource.FirstPointOfContactTitle__c = 'Mr';
            objLocationResource.SecondPointofContactEmail__c = 'test2poc@test.com';
            objLocationResource.SecondPointOfContactName__c = 'Test Second POC';
            objLocationResource.SecondPointofContactPhone__c = '988668800';
            objLocationResource.SecondPointOfContactTitle__c = 'Mrs'; 
            objLocationResource.Phone__c='1232343456';
            objLocationResource.TollFree__c='1232343456';
            objLocationResource.SundayClose__c=Time.newInstance(17, 30, 2, 20);
            objLocationResource.SundayOpen__c=Time.newInstance(10, 30, 2, 20); 
            objLocationResource.MondayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocationResource.MondayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocationResource.TuesdayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocationResource.TuesdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocationResource.WednesdayOpen__c=Time.newInstance(1, 30, 2, 20);
            objLocationResource.WednesdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocationResource.ThursdayClose__c=Time.newInstance(18, 00, 2, 20);
            objLocationResource.ThursdayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocationResource.FridayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocationResource.FridayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocationResource.SaturdayClose__c=Time.newInstance(18, 30, 2, 20);
            objLocationResource.SaturdayOpen__c=Time.newInstance(9, 30, 2, 20);
            objLocationResource.EligibilityDescription__c = 'test';
            objLocationResource.EligibilityCCAP__c = true;
            objLocationResource.EligibilityMedicaid__c = false;
            objLocationResource.EligibilitySNAP__c = true;
            objLocationResource.EligibilityTANF__c = false;
            lstLocationResource.add(objLocationResource);
            
        }
        if(!lstLocationResource.isEmpty() && doInsert){
            insert lstLocationResource;
        }
        
        return lstLocationResource;
        
    }
    
    /**
    @author       : Deeksha
    @date         : 05/24/2019
    @description  : static method to create user records
    @params       : alias - stores alias of user
                    profileId - Holds profileid of user
                    userName - Holds username of user
                    userEmail - Holds email of user
                    doInsert (Boolean) - To perform DML for the record or not
                    
    @return       : user object
    */
    public static User createUser(String alias,Id profileId,String userName,String userEmail,Boolean doInsert)
    {
        User user = new User(Alias = alias, IsActive=true,Email=userEmail, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        if(user!=null && doInsert){
            insert user;
        }
        return user;

    }
     public static User createAssisterUser(String alias,Id contactId,String userName,String userEmail, Boolean doInsert)
    {
        Profile nonCitizenUserProfile = [Select Id from Profile where name=:RE_GlobalConstants.strNonCitizenProfileName limit 1];
        User user = new User(Alias = alias, Email=userEmail, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = nonCitizenUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                            IsActive = true,ContactId=contactId,RE_Selected_Role__c=RE_GlobalConstants.ASSISTER,ApplicableRoles__c=RE_GlobalConstants.ASSISTER,FederationIdentifier=(String.valueOf(Math.random() * 10000)+DateTime.now()));
        if(user!=null && doInsert){
            insert user;
        }
        return user;

    }
    /**
    @author       : Deeksha
    @date         : 05/24/2019
    @description  : static method to create community user
    @params       : alias - stores alias of user
                    contactId - holds related contact Id
                    userName - holds username of user
                    userEmail - Holds email of user
                    doInsert (Boolean) - To perform DML for the record or not
    @return       : user object
    */
    public static User createCommunityUser(String alias,Id contactId,String userName,String userEmail,String selectedRole, Boolean doInsert)
    {
        Profile commUserProfile = [Select Id from Profile where name=:RE_GlobalConstants.strNonCitizenProfileName limit 1];
        User user = new User(Alias = alias, Email=userEmail, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                            IsActive = true,ContactId=contactId,RE_Selected_Role__c=selectedRole,ApplicableRoles__c =selectedRole);
        if(user!=null && doInsert){
            insert user;
        }
        return user;
    }
    public static User createCitizenUser(String alias,Id contactId,String userName,String userEmail,Boolean doInsert)
    {
        Profile commUserProfile = [Select Id from Profile where name=:RE_GlobalConstants.strCitizenProfileName limit 1];
        User user = new User(Alias = alias, Email=userEmail, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                            IsActive = true,ContactId=contactId, RE_Selected_Role__c = RE_GlobalConstants.CITIZEN_INDIVIDUAL);
        if(user!=null && doInsert){
            insert user;
        }
        return user;
    }
    
    public static User createSpecificCommunityUser(String alias,
                                                   Id contactId, 
                                                   String sFirstName, 
                                                   String sLastName, 
                                                   String sUserName,
                                                   String sUserEmail, 
                                                   String sProfileId, 
                                                   Boolean doInsert){
        User user = new User(Alias = alias,KOG_Role__c='Community Partner Admin', Email=sUserEmail, FirstName = sFirstName, LastName= sLastName, EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = sProfileId, TimeZoneSidKey='America/Los_Angeles', UserName=sUserName,
                            IsActive = true,ContactId=contactId,ApplicableRoles__c='Citizen_Individual',RE_Selected_Role__c='Citizen_Individual');
        if(user!=null && doInsert){
            insert user;
        }
        return user;

    }
    
    /**
    @author       : Deeksha
    @date         : 05/24/2019
    @description  : static method to create content version records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : ContentVersion object
    */
    public static List<ContentVersion> createContentVersion(Integer intCount,Boolean doInsert){
        List<ContentVersion> contentVersionInsertList = new List<ContentVersion>();
        for(integer i=1 ; i<=intCount; i++ ){
            ContentVersion contentVersionObj = new ContentVersion(
                                Title = 'Test'+i,
                                PathOnClient = 'Test.jpg',
                                VersionData = blob.valueof('Test Content Data'),
                                IsMajorVersion = true); 
            contentVersionInsertList.add(contentVersionObj);
        }
        if(!contentVersionInsertList.isEmpty() && doInsert){
            insert contentVersionInsertList;
        }
        return contentVersionInsertList;
    }
    /**
    @author       : Deeksha
    @date         : 05/24/2019
    @description  : static method to create content version records
    @params       : doInsert (Boolean) - To perform DML for the record or not
                    linkedParentId - holds parent Id to which document is associated
                    contentDocId - holds related contentdocumentId
    @return       : ContentDocumentLink object
    */
    public static List<ContentDocumentLink> createContentDocLink(Integer intCount,Boolean doInsert, Id linkedParentId, Id contentDocId){
        List<ContentDocumentLink> contentDocInsertList = new List<ContentDocumentLink>();
        for(integer i=1 ; i<=intCount; i++ ){
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=linkedParentId;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId=contentDocId;
            contentlink.Visibility = 'AllUsers'; 
            contentDocInsertList.add(contentlink);
        }
        if(!contentDocInsertList.isEmpty() && doInsert){
            insert contentDocInsertList ;
        }
        return contentDocInsertList;
    }
    
   /* @author       : Payal Dubela
    @date         : 05/24/2019
    @description  : static method to create Referral records
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    RecordTypeId - Referral Record Type to be inserted 
                    List<Contact> lstContact - Holds the Parent Record Ids
                    List<Account> lstReferralAccount - Holds the Parent Accounts
                    List<Resouce> lstResource - holds the parent resource
                    
    @return       : list of Referral  records
    */  
    
    public static List<Referral__c> createReferral(Integer intCount, 
                                                Boolean doInsert, 
                                                Id recordTypeId, 
                                                Id contactId,
                                                List<Account> lstReferralAccount,
                                                List<Resource__c> lstResource){
        List<Referral__c> lstReferral = new List<Referral__c>();
        
        for(integer i=0 ; i<intCount; i++ ){
            
            Referral__c objReferral = new Referral__c();
            objReferral.Resource__c = lstResource[i].Id;
            objReferral.ReferredAccountID__c =lstReferralAccount[0].Id;
            objReferral.Contacts__c=contactId;
            objReferral.Status__c='New';
            lstReferral.add(objReferral);
            
        }
        if(!lstReferral.isEmpty() && doInsert){
            insert lstReferral;
        }
        
        return lstReferral;
        
    }
    
    /* @author       : Payal Dubela
    @date         : 06/17/2019
    @description  : static method to create Consent records
    @params       : intCount - numbers of records to create,
                    doInsert (Boolean) - To perform DML for the record or not
                    List<Account> lstOrganization- Holds the Parent Record Ids
                    List<Contact> lstClients- Holds the Parent Record Ids
                    
    @return       : list of Consent  records
    */  
    
    public static List<Consent__c> createConsent(Integer intCount, 
                                                Boolean doInsert, 
                                                List<Contact> lstClients,
                                                List<Account> lstOrganization){
        List<Consent__c> lstConsent = new List<Consent__c>();
        
        for(integer i=0 ; i<intCount; i++ ){
            
            Consent__c consent = new Consent__c();
            consent.Organization__c=lstOrganization[i].Id;
            consent.Client__c=lstClients[i].Id;
            consent.EndDate__c=Date.today()+2;
            consent.StartDate__c=Date.today()-2;
            consent.Status__c=RE_GlobalConstants.CONSENT_STATUS_ACTIVE;
            consent.ConsentLevel__c=RE_GlobalConstants.ORGANIZATION;
            consent.ClientEmailProvided__c='test@test.com';
            lstConsent.add(consent);
            
        }
        if(!lstConsent.isEmpty() && doInsert){
            insert lstConsent;
        }
        
        return lstConsent;
        
    }
    /**
    @author       : Deeksha
    @date         : 06/18/2019
    @description  : static method to create feedback records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<Feedback__c>
    */
    public static List<Feedback__c> createFeedback(Integer intCount,Boolean doInsert, Id recordTypeId,
                                          List<Account> lstOrganization, List<Referral__c> lstReferral){
        List<Feedback__c> lstFeedback = new List<Feedback__c>();
        for(integer i=0 ; i<intCount; i++ ){
            Feedback__c objfeedback = new Feedback__c();
            objfeedback.AccountID__c=lstOrganization[i].Id;
            objfeedback.Referral__c=lstReferral[i].Id;
            objfeedback.Rating__c = 1;
            objfeedback.RecordTypeId = recordTypeId;
            lstFeedback.add(objfeedback);
        }
        if(!lstFeedback.isEmpty() && doInsert){
            insert lstFeedback;
        }
        return lstFeedback;
    }
    /**
    @author       : Deeksha
    @date         : 06/28/2019
    @description  : static method to create Claim records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<ClaimMySiteRequest__c>
    */
    public static List<ClaimMySiteRequest__c> createClaimRequest(Integer intCount,Boolean doInsert, Id recordTypeId ){
        List<ClaimMySiteRequest__c> lstClaimRecords = new List<ClaimMySiteRequest__c>();    
        for(integer i=0 ; i<intCount; i++ ){
            ClaimMySiteRequest__c claimReq=new ClaimMySiteRequest__c();
            claimReq.FirstName__c=RE_GlobalConstants.strClaimReqFirstName+i;
            claimReq.UniqueIdentificationNo__c=RE_GlobalConstants.strClaimUinNo;
            claimReq.Status__c = RE_GlobalConstants.CLAIM_STATUS_APPROVED;
            claimReq.RecordTypeId=recordTypeId;
            claimReq.Email__c = RE_GlobalConstants.strClaimEmail;
            lstClaimRecords.add(claimReq);
        }
        if(!lstClaimRecords.isEmpty() && doInsert){
            insert lstClaimRecords;
        }
        return lstClaimRecords;
    }
    /**
    @author       : Deeksha
    @date         : 07/10/2019
    @description  : static method to create Archetype records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Archetype__c>
    */
    public static List<RE_Archetype__c> createArchetypeRecords(Integer intCount,Boolean doInsert, Id recordTypeId ){
        Id parentArcRecTypeId = Schema.SObjectType.RE_Archetype__c.getRecordTypeInfosByName().get('Archetype').getRecordTypeId();
        List<RE_Archetype__c> lstArchetypeRec = new List<RE_Archetype__c>();
        RE_Archetype__c parentArchRec = new RE_Archetype__c(RecordTypeId = parentArcRecTypeId,Title__c='Parent Archetype',Status__c='Active');
        insert parentArchRec;
        for(integer j=0 ; j<intCount; j++ ){
            RE_Archetype__c objArch =new RE_Archetype__c();
            objArch.RecordtypeId = recordTypeId;
            objArch.Title__c = 'Arch'+j;
            objArch.Status__c='Active';
            objArch.language__c='en_US';
            objArch.ParentArchetype__c=parentArchRec.Id;
            lstArchetypeRec.add(objArch);
        }
        if(!lstArchetypeRec.isEmpty() && doInsert){
            insert lstArchetypeRec;
        }
        return lstArchetypeRec;
    }
    /**
    @author       : Deeksha
    @date         : 07/12/2019
    @description  : static method to create Goal records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Goal__c>
    */
    public static List<RE_Goal__c> createGoalRecords(Integer intCount,Boolean doInsert, List<RE_Archetype__c> lsAtArch ){
        List<RE_Goal__c> lstGoalRec = new List<RE_Goal__c>();
        for(integer j=0 ; j<intCount; j++ ){
            RE_Goal__c objGoal =new RE_Goal__c();
            objGoal.Archetype__c = lsAtArch[j].Id;
            objGoal.Domain__c ='Food';
            objGoal.Title__c ='Title'+j;
            objGoal.Language__c ='en_US';
            lstGoalRec.add(objGoal);
        }
        if(!lstGoalRec.isEmpty() && doInsert){
            insert lstGoalRec;
        }
        return lstGoalRec;
    }
    /**
    @author       : Karthik
    @date         : 07/12/2019
    @description  : static method to create DomainConfig records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Config__c>
    */
    public static List<RE_Config__c> createDomainConfigRecords(Integer intCount, Boolean doInsert, List<RE_Goal__c> lstGoals, List<RE_Taxonomy__c> lstTaxonomyRecords,String recTypeDevName){
            Id domConfigRecTypeId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        List<RE_Config__c> lstDomConfigtypeRec = new List<RE_Config__c>();
        RE_Config__c domConfigRec = new RE_Config__c(RecordTypeId = domConfigRecTypeId,IsMaster__c = true, DomainOrder__c = 10,Category__c='Emergencies & Disasters',Domain__c='Food',DomainCategory__c='Basic Resources',Subcategory__c='Fertility');
        insert domConfigRec;
        for(integer j=0 ; j<intCount; j++ ){
            RE_Config__c objConfig =new RE_Config__c();
            objConfig.Category__c='Emergencies & Disasters';
            objConfig.Domain__c='Food';
            objConfig.Subcategory__c='Advocacy and Referrals';
            objConfig.DomainCategory__c='Basic Resources';
            objConfig.RecordTypeId=domConfigRecTypeId;
            objConfig.DomainOrder__c = j;
            objConfig.IsMaster__c = true;
            if(lstTaxonomyRecords != null && !lstTaxonomyRecords.isEmpty())
                objConfig.Taxonomy__c = lstTaxonomyRecords[j].Id;
            if(lstGoals != null && !lstGoals.isEmpty())
                objConfig.Goal__c = lstGoals[j].Id;
            lstDomConfigtypeRec.add(objConfig);
        }
        if(!lstDomConfigtypeRec.isEmpty() && doInsert){
            insert lstDomConfigtypeRec;
        }
        return lstDomConfigtypeRec;
    }

    /**
    @author       : Karthik
    @date         : 07/15/2019
    @description  : static method to create Taxonomy records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Taxonomy__c>
    */
    public static List<RE_Taxonomy__c> createTaxonomyRecords(Integer intCount, Boolean doInsert){
        List<RE_Taxonomy__c> lstTaxonomyRecords = new List<RE_Taxonomy__c>();
        for(integer j=0 ; j<intCount; j++ ){
            RE_Taxonomy__c reTaxonomy =new RE_Taxonomy__c();
            reTaxonomy.Name='Hand Packers/Packagers'+j;
            reTaxonomy.Name__c='YO-8500.4900-350'+j;
            reTaxonomy.Description__c='Taxonomy Description'+j;
            lstTaxonomyRecords.add(reTaxonomy);
        }
        
        if(!lstTaxonomyRecords.isEmpty() && doInsert){
            insert lstTaxonomyRecords;
        }
        return lstTaxonomyRecords;
    }

    /**
    @author       : Karthik
    @date         : 07/15/2019
    @description  : static method to create Resource Taxonomy records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Resource_Taxonomy__c>
    */
    public static List<RE_Resource_Taxonomy__c> createResourceTaxonomyRecords(Integer intCount, Boolean doInsert, List<Resource__c> lstResources, List<RE_Taxonomy__c> lstTaxRecords){
        List<RE_Resource_Taxonomy__c> lstResTaxonomyRecords = new List<RE_Resource_Taxonomy__c>();
        for(integer j=0 ; j<intCount; j++ ){
            RE_Resource_Taxonomy__c reTaxonomy =new RE_Resource_Taxonomy__c();
            reTaxonomy.Resource__c = lstResources[j].Id;
            reTaxonomy.Taxonomy__c = lstTaxRecords[j].Id;
            lstResTaxonomyRecords.add(reTaxonomy);
        }
        if(!lstResTaxonomyRecords.isEmpty() && doInsert){
            insert lstResTaxonomyRecords;
        }
        return lstResTaxonomyRecords;
    }
    
    /**
    @author       : Suyash Singhal
    @date         : 07/12/2019
    @description  : static method to create Config records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Config__c>
    */
    public static List<RE_Config__c> createRelResourcesConfigRecords(Integer intCount, Boolean doInsert, List<RE_Taxonomy__c> lstTaxonomyRecords,String recTypeDevName){
        
        Id recTypeId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        List<RE_Config__c> lstConfigRecs = new List<RE_Config__c>();
        List<RE_Config__c> lstAllConfigRecs = new List<RE_Config__c>();
        
        if(recTypeDevName == 'TaxonomyGroup'){
          RE_Config__c objConfig =new RE_Config__c();
          objConfig.TaxonomyGroupName__c ='Testing Group';
          objConfig.RecordTypeId = recTypeId;
          lstConfigRecs.add(objConfig);
            
        }
        else if(recTypeDevName == 'SuggestedResourceMapping'){
            
            List<RE_Taxonomy__c> lstEmptyTaxonomy = new List<RE_Taxonomy__c>();
            List<RE_Config__c> lstTaxGrp = TestDataFactory.createRelResourcesConfigRecords(1,true,lstEmptyTaxonomy,'TaxonomyGroup');
            
            lstAllConfigRecs.addAll(lstTaxGrp);
            
            RE_Config__c objConfig =new RE_Config__c();
            objConfig.ParentConfig__c =lstTaxGrp[0].Id;  
            objConfig.Taxonomy__c = lstTaxonomyRecords[0].Id;
            objConfig.RecordTypeId = recTypeId;
            lstConfigRecs.add(objConfig);
            
        }
        else if(recTypeDevName == 'TaxonomyGroupMember'){
            
            List<RE_Config__c> lstResourceMappings = TestDataFactory.createRelResourcesConfigRecords(1,true,lstTaxonomyRecords,'SuggestedResourceMapping');
            
            lstAllConfigRecs.addAll(lstResourceMappings);
            for(integer j=1 ; j<intCount; j++ ){
                
                RE_Config__c objConfig =new RE_Config__c();
                objConfig.ParentConfig__c=lstResourceMappings[1].ParentConfig__c;
                objConfig.Taxonomy__c=lstTaxonomyRecords[j].Id; 
                objConfig.RecordTypeId = recTypeId;
                lstConfigRecs.add(objConfig);
                
            }    
        }
        
        
        
        if(!lstConfigRecs.isEmpty() && doInsert){
            insert lstConfigRecs;
        }
        lstAllConfigRecs.addAll(lstConfigRecs);
        return lstAllConfigRecs;
    }
    
    /**
    @author       : Suyash Singhal
    @date         : 07/15/2019
    @description  : static method to create Favorites  records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<RE_Resource_Taxonomy__c>
    */
    public static List<Favorite__c> createFavoritesRecords(Integer intCount, Boolean doInsert, List<LocationResource__c> lstLocResources){
        List<Favorite__c> lstFavs = new List<Favorite__c>();
        Id sFavRecordTypeId=Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
        for(integer j=0 ; j<intCount; j++ ){
            Favorite__c objFavorite =new Favorite__c();
            objFavorite.Contact__c = GeneralUtility.getLoggedInUserContactId();
            objFavorite.LocationResource__c = lstLocResources[j].Id;
            objFavorite.recordTypeId = sFavRecordTypeId;
            lstFavs.add(objFavorite);
        }
        if(!lstFavs.isEmpty() && doInsert){
            insert lstFavs;
        }
        return lstFavs;
    }
     /**
    @author       : Payal Dubela
    @date         : 09/19/2019
    @description  : static method to create "REIntegrationEndpoints__c" custom settings record
    @params       : none 
    @return       : none
    */  
    
    public static void createMapLatLogSettings(){
        REIntegrationEndpoints__c setting = new REIntegrationEndpoints__c();
        setting.Name='RE_GoogleMapAPI';
        setting.Account_API_Key__c='AIzaSyBwQAy5ZMxTXt-Wrc64WsdYtxyYs5N1WYs';
        setting.Endpoint_URI__c='https://maps.googleapis.com/maps/api/geocode/json?';
        insert setting;
    }
	/**
    @author       : Deeksha
    @date         : 09/24/2019
    @description  : static method to create Assessment template records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<Assessment__c>
    */
    public static List<Assessment__c> createAssessmentTemplateRecords(Integer intCount,Boolean doInsert, Id recordTypeId ){
    	List<Assessment__c> lstAssessmentRec = new List<Assessment__c>();
        for(integer j=0 ; j<intCount; j++ ){
            Assessment__c objAssessment =new Assessment__c();
            objAssessment.RecordtypeId = recordTypeId;
            objAssessment.AssessmentTitle__c = 'Assessment_Template'+j;
            lstAssessmentRec.add(objAssessment);
        }
        if(!lstAssessmentRec.isEmpty() && doInsert){
            insert lstAssessmentRec;
        }
        return lstAssessmentRec;
    }
    /**
    @author       : Deeksha
    @date         : 09/24/2019
    @description  : static method to create Questions records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<Question__c>
    */
    public static List<Question__c> createQuestionsRecords(Integer intCount,Boolean doInsert, List<Assessment__c> lstAssessment ){
        List<Question__c> lstQuestionsRec = new List<Question__c>();
        Id sQuesRecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('Resource Engine Assessment Question').getRecordTypeId();
        for(integer j=0 ; j<intCount; j++ ){
            Question__c objQues =new Question__c();
            objQues.AnswerType__c = 'Radio Button';
            objQues.Assessment__c = lstAssessment[j].Id;
            objQues.Question__c = 'Test Question '+j;
            objQues.SDOH__c = 'Childcare';
            objQues.QuestionOrder__c = 1.0;
            objQues.recordTypeId =sQuesRecordTypeId;
            lstQuestionsRec.add(objQues);
        }
        if(!lstQuestionsRec.isEmpty() && doInsert){
            insert lstQuestionsRec;
        }
        return lstQuestionsRec;
    }
    /**
    @author       : Nandita
    @date         : 20/02/2020
    @description  : static method to create Free Text Questions
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<Question__c>
    */
     public static List<Question__c> createQuestionsFreeTextRecords(Integer intCount,Boolean doInsert, List<Assessment__c> lstAssessment ){
        List<Question__c> lstQuestionsRec = new List<Question__c>();
        Id sQuesRecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('Resource Engine Assessment Question').getRecordTypeId();
        for(integer j=0 ; j<intCount; j++ ){
            Question__c objQues =new Question__c();
            objQues.AnswerType__c = 'Free Text';
            objQues.Assessment__c = lstAssessment[j].Id;
            objQues.Question__c = 'Test Question Text '+j;
            objQues.SDOH__c = 'Childcare';
            objQues.QuestionOrder__c = 1.0;
            objQues.recordTypeId =sQuesRecordTypeId;
            lstQuestionsRec.add(objQues);
        }
        if(!lstQuestionsRec.isEmpty() && doInsert){
            insert lstQuestionsRec;
        }
        return lstQuestionsRec;
    }
    /**
    @author       : Deeksha
    @date         : 09/24/2019
    @description  : static method to create AnswerChoice records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<AnswerChoice__c>
    */
    public static List<AnswerChoice__c> createAnswerChoiceRecords(Integer intCount,Boolean doInsert, List<Question__c> lstQuestions ){
    	List<AnswerChoice__c> lstAnsChoiceRec = new List<AnswerChoice__c>();
        for(integer j=0 ; j<intCount; j++ ){
            AnswerChoice__c objAnswerChoice =new AnswerChoice__c();
            objAnswerChoice.Answer__c = 'test Answer'+j;
            objAnswerChoice.Question__c = lstQuestions[j].Id;
            objAnswerChoice.Score__c = 5.0;
            lstAnsChoiceRec.add(objAnswerChoice);
        }
        if(!lstAnsChoiceRec.isEmpty() && doInsert){
            insert lstAnsChoiceRec;
        }
        return lstAnsChoiceRec;
    }
    /**
    @author       : Deeksha
    @date         : 09/24/2019
    @description  : static method to create GoalAnswer__c records
    @params       : doInsert (Boolean) - To perform DML for the record or not
    @return       : List<GoalAnswer__c>
    */
    public static List<GoalAnswer__c> createGoalAnsRecords(Integer intCount,Boolean doInsert, List<AnswerChoice__c> lstAnsChoice, List<RE_Goal__c> lstGoal ){
    	List<GoalAnswer__c> lstGoalAnsRec = new List<GoalAnswer__c>();
        for(integer j=0 ; j<intCount; j++ ){
            GoalAnswer__c objGoalAns =new GoalAnswer__c();
            objGoalAns.AnswerChoice__c = lstAnsChoice[j].Id;
            objGoalAns.Goal__c = lstGoal[j].Id;
            lstGoalAnsRec.add(objGoalAns);
        }
        if(!lstGoalAnsRec.isEmpty() && doInsert){
            insert lstGoalAnsRec;
        }
        return lstGoalAnsRec;
    }
    /**
    @author       : Deeksha Gupta
    @date         : 09/26/2019
    @description  : static method to create "createSDOHcustomSettings" custom settings record
    @params       : none 
    @return       : none
    */  
    
    public static void createSDOHcustomSettings(){
        List<RE_SDOHScores__c> listSDOH=new List<RE_SDOHScores__c>();
        RE_SDOHScores__c sdoh1=new RE_SDOHScores__c();
        sdoh1.name='1';
        sdoh1.ScoreColor__c='Red';
        sdoh1.ScoreStatus__c='In-Crisis';
        listSDOH.add(sdoh1);
        RE_SDOHScores__c sdoh2=new RE_SDOHScores__c();
        sdoh2.name='2';
        sdoh2.ScoreColor__c='Red';
        sdoh2.ScoreStatus__c='In-Crisis';
        listSDOH.add(sdoh2);
        RE_SDOHScores__c sdoh3=new RE_SDOHScores__c();
        sdoh3.name='3';
        sdoh3.ScoreColor__c='Yellow';
        sdoh3.ScoreStatus__c='Vulnerable';
        listSDOH.add(sdoh3);
        RE_SDOHScores__c sdoh4=new RE_SDOHScores__c();
        sdoh4.name='4';
        sdoh4.ScoreColor__c='Green';
        sdoh4.ScoreStatus__c='Stable';
        listSDOH.add(sdoh4);
        RE_SDOHScores__c sdoh5=new RE_SDOHScores__c();
        sdoh5.name='5';
        sdoh5.ScoreColor__c='Green';
        sdoh5.ScoreStatus__c='Stable';
        listSDOH.add(sdoh5);
        insert listSDOH; 
    }
	
	 public static void createREPropertiesCustomSettings(){
        List<RE_Properties__c> props =new List<RE_Properties__c>();
        RE_Properties__c prop1=new RE_Properties__c();
        prop1.name = 'CP User Onboarding Training Plan';
        prop1.PropertyName__c='CP User Onboarding Training Plan';
        prop1.PropertyType__c='Text';
        prop1.PropertyValue__c='Required Training for BacKYard Partners';
        props.add(prop1);
		RE_Properties__c prop2=new RE_Properties__c();
        prop2.name = 'Resource Engine';
        prop2.PropertyName__c='Resource Engine';
        prop2.PropertyType__c='Text';
        prop2.PropertyValue__c='Resource Engine';
        props.add(prop2);
       insert props; 
    }
	
    /**
    @author       : Deeksha Gupta
    @date         : 09/26/2019
    @description  : static method to create "createSDOHcustomSettings" custom settings record
    @params       : none 
    @return       : none
    */  
    
    /*public static void createSDOHDescriptioncustomSettings(){
        List<SDOHDescription__c> listSDOH = new List<SDOHDescription__c>();
        SDOHDescription__c sdoh1=new SDOHDescription__c();
        sdoh1.name='1';
        sdoh1.Assessment_Template__c='Assessment_Template0';
        sdoh1.Description__c='test Desc';
        sdoh1.Score__c=5;
        sdoh1.SDOH__c='Childcare';
        listSDOH.add(sdoh1);
        SDOHDescription__c sdoh2=new SDOHDescription__c();
        sdoh2.name='2';
        sdoh2.Assessment_Template__c='Assessment_Template1';
        sdoh2.Description__c='test Desc';
        sdoh2.SDOH__c='Housing';
        sdoh2.Score__c=2;
        listSDOH.add(sdoh2);
        insert listSDOH; 
    }*/
    /**
    @author       : Arun
    @date         : 09/24/2019
    @description  : static method to create User Assessment template records
    @params       : 
    @return       : Assessment__c
    */
    public static List<Assessment__c> createUserAssessmentTemplateRecords(Integer intCount,Boolean doInsert, Id recordTypeId,Id partnerId,Id residentId,Id assTempId ){
    	List<Assessment__c> listUserAsess=new List<Assessment__c>();
        for(integer j=0 ; j<intCount; j++ ){
            Assessment__c objAssessment =new Assessment__c();
            objAssessment.RecordtypeId = recordTypeId;
            objAssessment.Partner__c=partnerId;
            objAssessment.Resident__c=residentId;
            objAssessment.AssessmentTemplate__c=assTempId;
            listUserAsess.add(objAssessment);
        }
        
        if(listUserAsess!=null && doInsert){
            insert listUserAsess;
        }
        return listUserAsess;
    }
    /**
    @author       : Arun
    @date         : 09/24/2019
    @description  : static method to create User Assessment template records
    @params       : 
    @return       : List<AssessmentResponse__c>
    */
    public static List<AssessmentResponse__c> createAssessmentResponse(Integer intCount,Boolean doInsert, List<AnswerChoice__c> listAnsChoice,List<Assessment__c> lstAssessment,List<Question__c> lstQuestions,Id residentId ){
        List<AssessmentResponse__c> listAssRes=new List<AssessmentResponse__c>();
        Id sAssessmentRespRecTypeId = Schema.SObjectType.AssessmentResponse__c.getRecordTypeInfosByName().get('Resource Engine Assessment Response').getRecordTypeId();//Nandita: Added cod eto get Assessment Response Record Type Id
        for(integer j=0 ; j<intCount; j++ ){
            AssessmentResponse__c objAssessmentRes =new AssessmentResponse__c();
            objAssessmentRes.AnswerChoice__c=listAnsChoice[j].Id;
            objAssessmentRes.Assessment__c=lstAssessment[j].Id;
            objAssessmentRes.Question__c=lstQuestions[j].Id;
            objAssessmentRes.Resident__c=residentId;
            objAssessmentRes.recordTypeId=sAssessmentRespRecTypeId;
            listAssRes.add(objAssessmentRes);
        }
        
        if(listAssRes!=null && doInsert){
            insert listAssRes;
        }
        return listAssRes;
    }
    /**
    @author       : Arun
    @date         : 09/24/2019
    @description  : static method to create SDOH record
    @params       : 
    @return       : List<SDOH__c>
    */
    public static List<SDOH__c> createSDOH(Integer intCount,Boolean doInsert,Id residentId,List<Question__c> listQuestion){
        List<SDOH__c > listSDOH=new List<SDOH__c>();
        for(integer j=0 ; j<intCount; j++ ){
            SDOH__c objSDOH =new SDOH__c();
            objSDOH.Category__c=listQuestion[j].SDOH__c;
            objSDOH.IsLatest__c =true;
            objSDOH.Resident__c=residentId;
            listSDOH.add(objSDOH);
        }
        
        if(listSDOH!=null && doInsert){
            insert listSDOH;
        }
        return listSDOH;
    }
	/**
    @author       : Deeksha
    @date         : 11/19/2019
    @description  : static method to create Contact Mapping Records
    @return       : List<Contact_Mapping__c>
    */
    public static List<Contact_Mapping__c> createContactMappingRecords(Integer intCount,Boolean doInsert,List<Contact> listContact){
        List<Contact_Mapping__c> listConMapping =new List<Contact_Mapping__c>();
        for(integer j=0 ; j<intCount; j++ ){
            Contact_Mapping__c objConMap =new Contact_Mapping__c();
            objConMap.Contact__c=listContact[j].Id;
            objConMap.Group_Id__c ='Grp4567143';
            objConMap.IEES_Id__c=4567;
            listConMapping.add(objConMap);
        }
        
        if(listConMapping!=null && doInsert){
            insert listConMapping;
        }
        return listConMapping;
    }

    Public static void createAESEncryptionSettings (){
         Blob cryptoKey = Crypto.generateAesKey(256); 
 	    RE_AES_Encryption_Key__c objAESKey = RE_AES_Encryption_Key__c.getOrgDefaults();
	    objAESKey.AES_Key__c = EncodingUtil.base64Encode(cryptoKey);
	    insert objAESKey;   
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         05/19/2020
    * @methodname   testDataForAESKeys
    * @description  This method is used to create EncryptionDecryptionSettings__c record.
    * @param        none
    * @return       none
    ********************************************************************************************/
    Public static void testDataForAESKeys() 
    {
        Blob cryptoKey = Crypto.generateAesKey(256); 
        Blob exampleIv = Blob.valueOf('TestIvValue');
        EncryptionDecryptionSettings__c objKeyIV = new EncryptionDecryptionSettings__c();
        objKeyIV.Name = 'DecryptionKeyValues';
        objKeyIV.Key__c = EncodingUtil.base64Encode(cryptoKey);
        objKeyIV.InitializationVector__c = EncodingUtil.base64Encode(exampleIv);
        insert objKeyIV;
    }
	 /*****************************************************************************
    @author       : Tommaso
    @date         : 24 Jul 2020
    @description  : static method to create FAQ records
    @return       : List<FAQ__kav>
    ****************************************************************************/
    public static List<FAQ__kav> createFAQ(){

        List<FAQ__kav> articles = new List<FAQ__kav>();

        for(Integer i=0; i<10; i++) {
            FAQ__kav article = new FAQ__kav();
            article.Question__c = 'questionTest' + i;
            article.Answer__c = 'answerTest' +i;
            article.Help_Category__c = 'BA_General kynect benefits Information';
            article.Language = 'en_US';
            article.Title = 'titleTest' +i;
            article.UrlName = 'testURL' +i;

            articles.add(article);
        }

        for(Integer i=0; i<10; i++) {
            FAQ__kav article = new FAQ__kav();
            article.Question__c = 'questionTestEs' + i;
            article.Answer__c = 'answerTestEs' +i;
            article.Help_Category__c = 'BA_General kynect benefits Information';
            article.Language = 'es_US';
            article.Title = 'titleTestEs' +i;
            article.UrlName = 'testURLEs' +i;

            articles.add(article);
        }

        insert articles;

        return articles;
    }
}