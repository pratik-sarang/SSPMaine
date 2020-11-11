/*
* classname 	: SSP_TestDataFactory
* @description 	: This class is use to create the reusable method that will be used in Test Classes
* @author 		: Ashwin Kasture
* @date 		: 22/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		22/11/2019		Initial Version
*/
@isTest
public class SSP_TestDataFactory {
    /*
	* method 		: createUser
	* @description  : This method is use to create an List of Users
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
					  String sProfileName - use to set the Profile Name.
	* @return 		: List<User>
	* */
    public static List<User> createUser(Integer intCount, Boolean doInsert, String sProfileName){        
        List<User> lstUser = new List<User>();
        Id profId = [select Id from Profile where Name =:sProfileName limit 1].Id;
        for(Integer i=0;i<intCount;i++)
        {
            User staffUser = new User(
                Alias             = 'aprvr1'+i,
                Email             = 'staffUser'+ Math.round(Math.random() * 10000) +'@crm.com',
                EmailEncodingKey  = 'UTF-8',
                LastName          = 'User',
                FirstName         = 'Basic',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey      = 'en_US',
                ProfileId         = profId,
                UserPermissionsKnowledgeUser  = true,
                TimeZoneSidKey    = 'America/Chicago',
                Username          = System.now().millisecond() + 'citzen@crm' + Math.round(Math.random() * 10000)+ i + '.com',
                UserRoleId        = null);
            lstUser.add(staffUser);
        }
        if(doInsert){
            insert lstUser;
        }
        return lstUser;
    }
    /*
	* method 		: createPortalUser
	* @description  : This method is use to create an Portal Users
	* @author 		: Ashwin Kasture
	* @param 		: -
	* @return 		: User
	* */
    public static User createPortalUser(){   
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User portalUserCreator = new User(
            UserRoleId 			=	portalRole.Id,
            ProfileId 			=	profile.Id,
            Username			=	System.now().millisecond() + Math.random() + 'test2@test.com',
            Alias 				=	'batman',
            Email				=	'ronald.stewart@mailinators.com',
            EmailEncodingKey	=	'UTF-8',
            Firstname			=	'Bruce',
            Lastname			=	'Wayne',
            LanguageLocaleKey	=	'en_US',
            LocaleSidKey		=	'en_US',
            TimeZoneSidKey		=	'America/Chicago'
        );
        Database.insert(portalUserCreator);
        
        System.runAs ( portalUserCreator ) {
            //Create account
            Account portalUserAccount = new Account(
                Name = 'Portal Account',
                OwnerId = portalUserCreator.Id
            );
            Database.insert(portalUserAccount);
            
            //Create contact
            Contact contactForPortalUser = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalUserAccount.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contactForPortalUser);
            
            //Create Portal user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name=:'RE Citizen Profile' Limit 1];
            User portalUser = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contactForPortalUser.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'batman905',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(portalUser);
        }
        User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
        return fetchedPortalUser;        
    }
    
    /*
    * method        : createPortalUser
    * @description  : This method is use to create an Portal Users
    * @author       : Ashwin Kasture
    * @param        : -
    * @return       : User
    * */
    public static User createPortalUserOnContact(ID ContactID){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User portalUserCreator = new User(
            UserRoleId          =   portalRole.Id,
            ProfileId           =   profile.Id,
            Username            =   System.now().millisecond() + Math.random() + 'test2@test.com',
            Alias               =   'batman',
            Email               =   'ronald.stewart@mailinators.com',
            EmailEncodingKey    =   'UTF-8',
            Firstname           =   'Bruce',
            Lastname            =   'Wayne',
            LanguageLocaleKey   =   'en_US',
            LocaleSidKey        =   'en_US',
            TimeZoneSidKey      =   'America/Chicago'
        );
        Database.insert(portalUserCreator);
        User portalUser;
        System.runAs ( portalUserCreator ) {
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name=:'RE Citizen Profile' Limit 1];
                portalUser = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = ContactID,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test123456',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(portalUser);
        }
        return portalUser;
    }
    
	/*
	* method 		: createAccounts
	* @description  : This method is use to create an Account
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<Account>
	* */
    public static List<Account> createAccounts(Integer intCount,Boolean doInsert){
        List<Account> lstAccounts = new List<Account>();
        for(integer i=1 ; i<=intCount; i++ ){
            Account objAccount = new Account(Name = 'Account' +i);
            lstAccounts.add(objAccount);
        }
        if(!lstAccounts.isEmpty() && doInsert){
            insert lstAccounts;
        }
        return lstAccounts;
    } 

        /*
	* method 		: createAccounts
	* @description  : This method is use to create an Account
	* @author 		: Shrikant Raut
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
                      RecordType
	* @return 		: List<Account>
	* */
    public static List<Account> createAccounts(Integer intCount,Boolean doInsert, Id recordTypeId){
        List<Account> lstAccounts = createAccounts(intCount, false);
        for(Account a : lstAccounts){
            a.RecordTypeId = recordTypeId;
        }
        if(lstAccounts != null && !lstAccounts.isEmpty() && doInsert){
            insert lstAccounts;
        }
        return lstAccounts;
    } 
    /*
	* method 		: createContacts
	* @description  : This method is use to create an Contacts
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<Contact>
	* */
    public static List<Contact> createContacts(Integer intCount,Boolean doInsert){
        List<Contact> lstCon = new List<Contact>();
        for(integer i=1 ; i<=intCount; i++ ){
            Contact objCon = new Contact();
            objCon.FirstName = 'Ashwin';
            objCon.LastName = 'Kasture';
            lstCon.add(objCon);
        }
        return lstCon;
    }
    
    /*
	* method 		: createSSPApplications
	* @description  : This method is use to create an SSP Applications
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_Application__c>
	* */
    public static List<SSP_Application__c> createSSPApplications(Integer intCount,Boolean doInsert){
        List<SSP_Application__c> lstAppl = new List<SSP_Application__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.SSPDCMessage__c = SSP_GlobalConstants.SSPDC_LOG4_Message;
            //objAppl.HasEmergencyMedicalCondition__c=false;
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            lstAppl.add(objAppl);
        }        
        if(!lstAppl.isEmpty() && doInsert){
            insert lstAppl;
        }
        return lstAppl;        
    }
    
    /*
	* method 		: createSSPMembers
	* @description  : This method is use to create an SSP Members
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_Member__c>
	* */
    public static List<SSP_Member__c> createSSPMembers(Integer intCount, Boolean doInsert){
        List<SSP_Member__c> lstMem = new List<SSP_Member__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_Member__c objMem = new SSP_Member__c();
            objMem.FirstName__c='Ashwin';
            objMem.LastName__c='Kasture';
            objMem.IsDisabledToggle__c='N';
            objMem.IsBlindToggle__c='N';
            lstMem.add(objMem);
        }
        if(!lstMem.isEmpty() && doInsert){
            insert lstMem;
        }
        return lstMem;
    }
    /*
	* method 		: createApplicationIndividuals
	* @description  : This method is use to create an Application Individuals
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
    public static List<SSP_ApplicationIndividual__c> createApplicationIndividuals(Integer intCount, Boolean doInsert){
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_ApplicationIndividual__c objAppInd = new SSP_ApplicationIndividual__c();            
            objAppInd.ProgramsApplied__c='MA';
            objAppInd.MedicaidType__c='MAGI';
            lstAppInd.add(objAppInd);
        }
        if(!lstAppInd.isEmpty() && doInsert){
            insert lstAppInd;
        }
        return lstAppInd;
    }

        /*
	* method 		: createAssets
	* @description  : This method is use to create an SSP_Asset__c records
	* @author 		: Shrikant Raut
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_Asset__c>
	* */
    public static List<SSP_Asset__c> createAssets(Integer intCount, String strRecTypeDevName, Boolean doInsert){
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        Id recTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Asset__c',strRecTypeDevName);

        for(integer i=1 ; i<=intCount; i++ ){
            SSP_Asset__c tmpAsset = new SSP_Asset__c();
            tmpAsset.recordTypeId = recTypeId;
            if(strRecTypeDevName == 'Income'){
                tmpAsset.BusinessTypeCode__c ='SF';
                tmpAsset.EmployerName__c ='ABC Consulting Ltd';
                //tmpAsset.DCId__c= '1134';
                tmpAsset.Tips__c= 500;
                tmpAsset.IncomeTypeCode__c='EA';
                tmpAsset.IncomePayFrequency__c='BW';
                tmpAsset.TotalGrossAmount__c=2000;
                tmpAsset.ExpensesAmount__c=1000;
                tmpAsset.IncomePayDetailHoursPerWeek__c=60;
            }
            lstAssets.add(tmpAsset);
        }
        if(!lstAssets.isEmpty() && doInsert){
            insert lstAssets;
        }
        return lstAssets;
    }

     /*
    * method        : createResourceOwnerships
    * @description  : This method is use to create a Resource Ownership records
    * @author       : Karthik Gulla
    * @param        : Integer intCount - use to set the count of records to create
                      Boolean doInsert - use to allow insert of records.
                      List<SSP_Asset__c> - list of assets
                      List<SSP_Member__c> - list of members
    * @return       : List<SSP_ResourceOwnership__c>
    * */
    public static List<SSP_ResourceOwnership__c> createResourceOwnerships(Integer intCount, List<SSP_Asset__c> lstAssets, List<SSP_Member__c> lstMembers, Boolean doInsert){
        List<SSP_ResourceOwnership__c> lstResOwnerships = new List<SSP_ResourceOwnership__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_ResourceOwnership__c sspResOwnership = new SSP_ResourceOwnership__c();
            if(lstMembers != null && !lstMembers.isEmpty()){
                sspResOwnership.SSP_Member__c = lstMembers[0].Id;
            } else {
                sspResOwnership.JointOwnerName__c = 'JointOwner'+i;
            }
            sspResOwnership.SSP_Asset__c = lstAssets[0].Id;
            lstResOwnerships.add(sspResOwnership);
        }  
        if(!lstResOwnerships.isEmpty() && doInsert){
            insert lstResOwnerships;
        }
        return lstResOwnerships;
    }


        /*
	* method 		: getRecordTypeMapping
	* @description  : This method fetch recordType DeveloperName to Id mapping
	* @author 		: Shrikant Raut
	* @param 		: ObjectAPI - SF Object API Name
	* @return 		: Msp<DeveloperName, Id>
	* */
    public static Map<String, String> getRecordTypeMapping(String ObjectAPI){
        List<RecordType> rtypes = [Select Name, DeveloperName, Id From RecordType 
                  where sObjectType=:ObjectAPI and isActive=true];
     
        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> recordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes){
            recordTypes.put(rt.DeveloperName,rt.Id);
        }
        return recordTypes;
    }

   /*
	* method 		: createContactRecord
	* @description  : This method is used to create contact record based on given details
	* @author 		: Shrikant Raut
	* @param 		: sFirstName - firstName, sLastName - lastName, email - contactEmail, sRecordTypeId - contact record type id, bInsert - boolean<perfoem DML>
	* @return 		: Contact record
	* */ 
    public static Contact createContactRecord(String sFirstName, String sLastName, String email, String sRecordTypeId, Boolean bInsert){
        Id sCitizenAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');
        List<Account> accountList = SSP_TestDataFactory.createAccounts(1,true,sCitizenAccRecTypeId);       
        Contact objContact = new Contact();
        objContact.FirstName = sFirstName;
        objContact.LastName = sLastName;
        objContact.Email = email;
        objContact.recordTypeId = sRecordTypeId;
        objContact.AccountId =accountList[0].Id;
        objContact.MailingPostalCode=String.valueOf(RE_GlobalConstants.dZipCode_TEST);
        if(bInsert){
            insert objContact;
        }
        return objContact;
    }

    /**
    @author       : Shrikant Raut
    @description  : static method to create community user
    @params       : alias - stores alias of user
                    contactId - holds related contact Id
                    userName - holds username of user
                    userEmail - Holds email of user
                    doInsert (Boolean) - To perform DML for the record or not
    @return       : user object
    */
    public static User createCommunityUser(String alias,Id contactId,String userName, String profileName, Boolean doInsert)
    {
        Profile commUserProfile = [Select Id from Profile where name= :profileName limit 1];
        User user = new User(Alias = alias, Email=userName, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                            IsActive = true);
                            if(contactId != null){
                                user.ContactId = contactId;
                            }
        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            user.ApplicableRoles__c = 'DAIL_Worker;Citizen_Individual';            
        }                            
        if(user!=null && doInsert){
            insert user;
        }

        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            System.runAs(new User(Id = UserInfo.getUserId())){
                List<permissionsetassignment> pSetAssignmentList = new List<permissionsetassignment>();
                for(PermissionSet pSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('DAIL_Worker', 'Citizen_Individual')]){
                    permissionsetassignment pSetAssignment = new permissionsetassignment();
                    pSetAssignment.PermissionSetId = pSet.Id;
                    pSetAssignment.AssigneeId  = user.Id;
                    pSetAssignmentList.add(pSetAssignment);
                }
                insert pSetAssignmentList;
            }
        }
        return user;

    }

    /**
    @author       : Shrikant Raut
    @description  : method to setup base data like portal user account and contact
    */
    public static void setupTestData(){
        Id sCitizenAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');
        
        List<Account> accountList = SSP_TestDataFactory.createAccounts(5,true,sCitizenAccRecTypeId);
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(accountList[0].Id);
        
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact objAdminContact = SSP_TestDataFactory.createContactRecord('Admin', 'User', 'admin@abc.xyz' , contactRecordTypeId, true);
        Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('Citizen', 'User', 'citizen@abc.xyz', contactRecordTypeId, true);
        
        User objAdminUser = SSP_TestDataFactory.createCommunityUser('sspA', null, 'admin@abc.xyz', 'System Administrator',true);
        
        User objCitizenUser = SSP_TestDataFactory.createCommunityUser('sspC', objCitizenContact.Id,'citizen@abc.xyz', 'RE Citizen Profile', true);
        
    }

        /**
    @author       : Shrikant Raut
    @description  : method to setup base data like portal user account and contact
    */
    public static User setUpNonCitizenUser(){
        Id sCitizenAccRecTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');
        
        List<Account> accountList = SSP_TestDataFactory.createAccounts(5,true,sCitizenAccRecTypeId);
        List<Id> lstAccountIds = new List<Id>();
        lstAccountIds.add(accountList[0].Id);
        
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Contact objAdminContact = SSP_TestDataFactory.createContactRecord('Admin', 'User', 'admin1@abc.xyz' , contactRecordTypeId, true);
        Contact objCitizenContact = SSP_TestDataFactory.createContactRecord('NonCitizen', 'User', 'noncitizen@abc.xyz', contactRecordTypeId, true);
        
        User objAdminUser = SSP_TestDataFactory.createCommunityUser('sspNonCA', null, 'nonCAdmin@abc.xyz', 'System Administrator',true);
        
        User objNonCitizenUser = SSP_TestDataFactory.createCommunityUser('sspNonC', objCitizenContact.Id,'noncitizen@abc.xyz', 'SSP Non Citizen Profile', true);
        // objNonCitizenUser.ApplicableRoles__c = 'DAIL_Worker;Citizen_Individual';
        // update objNonCitizenUser;

        return objNonCitizenUser;
        
    }

    /*
	* method 		: createInsurancePolicy
	* @description  : This method is use to create an SSP Insurance Policy
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_InsurancePolicy__c>
	* */
    public static List<SSP_InsurancePolicy__c> createInsurancePolicy(Integer intCount, Boolean doInsert) {
        List<SSP_InsurancePolicy__c> lstMem = new List<SSP_InsurancePolicy__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_InsurancePolicy__c objMem = new SSP_InsurancePolicy__c();
            objMem.Name='test';
            objMem.InsuranceCompanyName__c='Life Insurance Company';
            objMem.PlanName__c= 'Life Insurance';
            objMem.InsurancePolicyNumber__c='001';
            lstMem.add(objMem);
        }
        if(!lstMem.isEmpty() && doInsert){
            insert lstMem;
        }
        return lstMem;
    }
    
    /*
	* method 		: createInsuranceCovIndPolicy
	* @description  : This method is use to create an SSP Insurance Covered Individual
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_InsuranceCoveredIndiv__c>
	* */
    public static List<SSP_InsuranceCoveredIndiv__c> createInsuranceCovIndPolicy(Integer intCount, Boolean doInsert) {
        List<SSP_InsuranceCoveredIndiv__c> lstMem = new List<SSP_InsuranceCoveredIndiv__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_InsuranceCoveredIndiv__c objMem = new SSP_InsuranceCoveredIndiv__c();            
            objMem.IsPolicyHolder__c = true;
            objMem.FirstName__c = 'ashwin';
            objMem.LastName__c = 'kasture';
            objMem.IsInsuranceCovered__c  = true;            
            lstMem.add(objMem);
        }
        if(!lstMem.isEmpty() && doInsert){
            insert lstMem;
        }
        return lstMem;
    }
    /*
    * method        : createAssets
    * @description  : This method is use to create an SSP_Benefits__c records
    * @author       : Shrikant Raut
    * @param        : Integer intCount - use to set the count of records to create
                      Boolean doInsert - use to allow insert of records.
    * @return       : List<SSP_Benefits__c>
    * */
    public static List<SSP_Benefits__c> createBenefitRecords(Integer intCount, String strRecTypeDevName, Boolean doInsert){
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        Id recTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Benefits__c',strRecTypeDevName);
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_Benefits__c tmpBenefit = new SSP_Benefits__c();
            tmpBenefit.recordTypeId = recTypeId;
            if(strRecTypeDevName == 'EntitledBenefit'){
                tmpBenefit.StatusofApplication__c ='A';
                tmpBenefit.BenefitTypeCode__c ='BL';              
            }
            lstBenefits.add(tmpBenefit);
        }
        if(!lstBenefits.isEmpty() && doInsert){
            insert lstBenefits;
        }
        return lstBenefits;
    }

    /*
    * method        : createAttendanceRecords
    * @description  : This method is use to create an SSP_Attendance__c records
    * @author       : Ajay Saini
    * @param        : Integer intCount - use to set the count of records to create
                      Boolean doInsert - use to allow insert of records.
                      Id memberId - Id of the member.
    * @return       : List<SSP_Attendance__c>
    * */
    public static List<SSP_Attendance__c> createAttendanceRecords(Integer intCount, Boolean doInsert, Id memberId) {
        List<SSP_Attendance__c> records = new List<SSP_Attendance__c>();
        for(integer j = 0; j < intCount; j++ ){
            SSP_Attendance__c record = new SSP_Attendance__c();
            record.SSP_Member__c = memberId;
            records.add(record);
        }
        
        if(doInsert && intCount > 0) {
            insert records;
        }
        return records;
    }
    
    /*
    * method        : createNoncustodialParentRecords
    * @description  : This method is use to create an SSP_NonCustodialParent__c records
    * @author       : Ajay Saini
    * @param        : Integer intCount - use to set the count of records to create
                      Boolean doInsert - use to allow insert of records.
                      Id memberId - Id of the member.
    * @return       : List<SSP_NonCustodialParent__c>
    * */
    public static List<SSP_NonCustodialParent__c> createNoncustodialParentRecords(Integer intCount, Boolean doInsert, Id memberId) {
        List<SSP_NonCustodialParent__c> records = new List<SSP_NonCustodialParent__c>();
        List<SSP_NoncustodialRelationship__c> junctions = new List<SSP_NoncustodialRelationship__c>();
        for(integer j = 0; j < intCount; j++) {
            SSP_NonCustodialParent__c record = new SSP_NonCustodialParent__c();
            record.FirstName__c =  'Test';
            records.add(record);
        }
        if(doInsert && intCount > 0) {
            insert records;
            for(SSP_NonCustodialParent__c parent : records) {
                SSP_NoncustodialRelationship__c junction = new SSP_NoncustodialRelationship__c(SSP_Member__c = memberId, SSP_NonCustodialParent__c = parent.Id );
                junctions.add(junction);
            }
            insert junctions;
        }
        return records;
    }
    
    /*
    * method        : createInsurancePolicyRecords
    * @description  : This method is use to create Insurance Policy records
    * @author       : Ashwin Kasture
    * @param        : Integer intCount, Boolean doInsert
    * @return       : List<SSP_InsurancePolicy__c>
    * */
    public static List<SSP_InsurancePolicy__c> createInsurancePolicyRecords(Integer intCount, Boolean doInsert) {
        List<SSP_InsurancePolicy__c> lstInsurancePolicy = new List<SSP_InsurancePolicy__c>();
        for(integer i=1 ; i<=intCount; i++ ) {
            SSP_InsurancePolicy__c  objInsurance = new SSP_InsurancePolicy__c (Name = 'Life Insurance' +i);
            lstInsurancePolicy.add(objInsurance);
        }
        if(!lstInsurancePolicy.isEmpty() && doInsert) {
            insert lstInsurancePolicy;
        }
        return lstInsurancePolicy;
    }
    
    /*
    * method        : createInsuranceCoveredIndividuals
    * @description  : This method is use to create Insurance Covered Individuals
    * @author       : Ashwin Kasture
    * @param        : Integer intCount, Boolean doInsert
    * @return       : List<SSP_InsuranceCoveredIndiv__c>
    * */
    public static List<SSP_InsuranceCoveredIndiv__c> createInsuranceCoveredIndividuals(Integer intCount, Boolean doInsert) {
        List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCov = new List<SSP_InsuranceCoveredIndiv__c>();
        for(integer i=1 ; i<=intCount; i++ ) {
            SSP_InsuranceCoveredIndiv__c objInsuranceCov = new SSP_InsuranceCoveredIndiv__c (Name = 'Ashwin' +i);
            lstInsuranceCov.add(objInsuranceCov);
        }
        if(!lstInsuranceCov.isEmpty() && doInsert) {
            insert lstInsuranceCov;
        }
        return lstInsuranceCov;
    }
    
    /*
    * method        : createHealthInsuranceFacilityType
    * @description  : This method is use to create Health Insurance Facility Type
    * @author       : Ashwin Kasture
    * @param        : Integer intCount, Boolean doInsert
    * @return       : List<SSP_HealthInsuranceFacilityType__c>
    * */
    public static List<SSP_HealthInsuranceFacilityType__c> createHealthInsuranceFacilityType(Integer intCount, Boolean doInsert) {
        List<SSP_HealthInsuranceFacilityType__c> lstFacilityType = new List<SSP_HealthInsuranceFacilityType__c>();
        for(integer i=1 ; i<=intCount; i++ ) {
            SSP_HealthInsuranceFacilityType__c objInsuranceCov = new SSP_HealthInsuranceFacilityType__c (OtherReason__c  = 'Other' +i);
            lstFacilityType.add(objInsuranceCov);
        }
        if(!lstFacilityType.isEmpty() && doInsert) {
            insert lstFacilityType;
        }
        return lstFacilityType;
    }
    /*
    * method        : createRelationshipRecords
    * @description  : This method is use to create Relationship Records
    * @author       : Ajay Saini
    * @param        : Integer intCount, Boolean doInsert
    * @return       : List<SSP_Relationship__c>
    * */
    public static List<SSP_Relationship__c> createRelationshipRecords(Integer intCount, Boolean doInsert, Id memberId) {
        List<SSP_Relationship__c> relationRecords = new List<SSP_Relationship__c>();
        for(Integer i = 1 ; i <= intCount; i++ ) {
            SSP_Relationship__c relation = new SSP_Relationship__c(SSP_Member__c = memberId);
            relationRecords.add(relation);
        }
        if(!relationRecords.isEmpty() && doInsert) {
            insert relationRecords;
        }
        return relationRecords;
    }
    
    /*
    * method        : createAccountContactRelationshipRecord
    * @description  : This method is use to create AccountContactRelationship Records
    * @author       : Keshav Poduval
    * @param        : Id conId, Id accId, Boolean doInsert
    * @return       : AccountContactRelation
    * */
    public static AccountContactRelation createAccountContactRelationshipRecord(Id conId, Id accId, Boolean doInsert){
        AccountContactRelation acrRecord = new AccountContactRelation(ContactId = conId, AccountId = accId);
        if(doInsert){
            insert acrRecord;
        }
        return acrRecord;
    }
    /*
    * method        : createContextData
    * @description  : This method is use to create Context Data
    * @author       : Sai Kiran Velpula
    * @param        : List SSP_ApplicationIndividual__c
    * @return       : ContextData
    * */
    public static ContextData createContextData(List<SSP_ApplicationIndividual__c> lstAppInd){
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_ApplicationIndividual__c> applicationIndividualList = new List<SSP_ApplicationIndividual__c>();
        ContextData ctxData = new ContextData();
        QueuingWrapper queWrap = new QueuingWrapper();
        for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
            memberAppIndividualMap.put(objAppInd.SSP_Member__c,objAppInd);
        }
        applicationIndividualList = lstAppInd;
        queWrap.memberAppIndividualMap = memberAppIndividualMap;
        queWrap.applicationIndividualList = applicationIndividualList;
        ctxData.queueObject = queWrap;                
        return ctxData;
    }
    
    /*
	* method 		: createApplicationIndividuals
	* @description  : This method is use to create an Application Individuals
	* @author 		: Ashwin Kasture
	* @param 		: Integer intCount - use to set the count of records to create
					  Boolean doInsert - use to allow insert of records.
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
    public static List<SSP_AlienSponsor__c> createAlienSponsor(Integer intCount, Boolean doInsert){
        List<SSP_AlienSponsor__c> lstAlienSponser = new List<SSP_AlienSponsor__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            SSP_AlienSponsor__c objAlienSponser = new SSP_AlienSponsor__c();            
            objAlienSponser.AddressLine1__c='Suit 101';
            //objAlienSponser.MedicaidType__c='MAGI';
            lstAlienSponser.add(objAlienSponser);
        }
        if(!lstAlienSponser.isEmpty() && doInsert){
            insert lstAlienSponser;
        }
        return lstAlienSponser;
    }
 /*
	* method 		: createFavoriteRecord
	* @description  : This method is use to create Favorite record
	* @author 		: ChangeMeIn@UserSettingsUnder.SFDoc
	* @return 		:  List<Favorite__c>
	* */
     /*public static List<Favorite__c> createFavoriteRecord(String contactId, Integer intCount, Boolean doInsert) {
        List<Favorite__c> lstMem = new List<Favorite__c>();
        for(integer i=1 ; i<=intCount; i++ ){
            Favorite__c objMem = new Favorite__c();            
            objMem.Contact__c = contactId;
            objMem.Provider_Id__c = '122';          
            lstMem.add(objMem);
        }
        if(!lstMem.isEmpty() && doInsert){
            insert lstMem;
        }
        return lstMem;
    }*/
        
}