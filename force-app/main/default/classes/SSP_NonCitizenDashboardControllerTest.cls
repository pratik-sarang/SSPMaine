/*
* classname     :  SSP_NonCitizenDashboardControllerTest
* @description  :  Test class for SSP_NonCitizenDashboardController and SSP_NonCitizenDashboardService
* @author       :  Chandra Shekhar   
* @date         :  06/17/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_NonCitizenDashboardControllerTest {
    @testSetup
    public static void createTestData(){ 
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);        
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, 'Assister',7200);
        //Added part of 20.10 release
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
        User objAdminUser = SSP_TestDataFactory.createCommunityUser('sspA', null, 'admin@abc.xyz', 'System Administrator',true);

        //Create non citizen contact/account/user
        Contact nonCitizenContact1 = SSP_TestDataFactory.createContactRecord('Allison', 'Gibbs', 'aliison@gibb.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Assister').getRecordTypeId(), true);
        nonCitizenContact1.DCDataId__c=344.0;        
        Update nonCitizenContact1;        
        System.assertNotEquals(null, nonCitizenContact1.Id, 'Assister Contact created successfully');
        
        Contact nonCitizenContact2 = SSP_TestDataFactory.createContactRecord('Allison1', 'Gibbs1', 'aliison1@gibb.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Assister').getRecordTypeId(), true);
        nonCitizenContact2.KOGSourceId__c='qidsdiqu83728jkdh';
        nonCitizenContact2.AssociatedCountyCode__c='536;7363';
        Update nonCitizenContact2;
        
        Contact nonCitizenContact3 = SSP_TestDataFactory.createContactRecord('Allison2', 'Gibbs', 'aliison2@gibb.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Auth Rep').getRecordTypeId(), true);
        nonCitizenContact3.DCDataId__c=2222.0;
        Update nonCitizenContact3;
        
        Contact nonCitizenContact4 = SSP_TestDataFactory.createContactRecord('Allison3', 'Gibbs3', 'aliison3@gibb.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Assister').getRecordTypeId(), true);
        nonCitizenContact4.DCDataId__c=2221.0;
        Update nonCitizenContact4;
        
        //Create Non citizen user
        // User assisterUser = SSP_TestDataFactory.createCommunityUser('assis', nonCitizenContact1.Id, nonCitizenContact1.Email, 'SSP Non Citizen Profile', true); 
        String profileName='SSP Non Citizen Profile';
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile commUserProfile = [Select Id from Profile where name= :profileName limit 1];
        User assisterUser = new User(Alias = 'assis', Email=nonCitizenContact1.Email, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=nonCitizenContact1.Email,
                                     IsActive = true );
        
        if(nonCitizenContact1.Id != null){
            assisterUser.ContactId = nonCitizenContact1.Id;
        }
        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            assisterUser.ApplicableRoles__c = 'Assister';  
            assisterUser.SelectedRole__c='Assister';
        }
        insert assisterUser;
        
        
        User dailWorker = new User(Alias = 'dail', Email=nonCitizenContact2.Email, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=nonCitizenContact2.Email,
                                   IsActive = true);
        if(nonCitizenContact2.Id != null){
            dailWorker.ContactId = nonCitizenContact2.Id;
        }
        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            dailWorker.ApplicableRoles__c = 'DAIL_Worker';  
            dailWorker.SelectedRole__c='DAIL_Worker';
        }  
        insert dailWorker;
        
        User dcbs = new User(Alias = 'dcbs', Email=nonCitizenContact3.Email, LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=nonCitizenContact3.Email,
                             IsActive = true);
        if(nonCitizenContact3.Id != null){
            dcbs.ContactId = nonCitizenContact3.Id;
        }
        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            dcbs.ApplicableRoles__c = 'DCBS_Central_Office_View_and_Edit';  
            dcbs.SelectedRole__c='DCBS_Central_Office_View_and_Edit';
        }  
        insert dcbs;
        User der = new User(Alias = 'der', Email=nonCitizenContact4.Email, LastName='Testing3', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName=nonCitizenContact4.Email,
                            IsActive = true);
        if(nonCitizenContact4.Id != null){
            der.ContactId = nonCitizenContact4.Id;
        }
        if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
            der.ApplicableRoles__c = 'Department_Of_Education_Representative';  
            der.SelectedRole__c='Department_Of_Education_Representative';
        }  
        insert der;
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            List<permissionsetassignment> pSetAssignmentList = new List<permissionsetassignment>();        
            if(profileName.equalsIgnoreCase('SSP Non Citizen Profile')){
                for(PermissionSet pSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('DAIL_Worker','Assister','DCBS_Central_Office_View_and_Edit','Department_Of_Education_Representative')]){
                    permissionsetassignment pSetAssignment = new permissionsetassignment();
                    pSetAssignment.PermissionSetId = pSet.Id;
                    if(pSet.Name=='Assister'){
                        pSetAssignment.AssigneeId  = assisterUser.Id; 
                    }
                    if(pSet.Name=='DAIL_Worker'){
                        pSetAssignment.AssigneeId  = dailWorker.Id; 
                    }
                    if(pSet.Name=='DCBS_Central_Office_View_and_Edit'){
                        pSetAssignment.AssigneeId  = dcbs.Id; 
                    }
                    if(pSet.Name=='Department_Of_Education_Representative'){
                        pSetAssignment.AssigneeId  = der.Id; 
                    }
                    pSetAssignmentList.add(pSetAssignment);
                }
            }
            insert pSetAssignmentList;
        }
        
        //Create citizen contact/account
        Contact citizenContact1 = SSP_TestDataFactory.createContactRecord('Andrews', 'Nelsonj', 'andrew@nelson.com', Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Citizen').getRecordTypeId(), true);
        System.assertNotEquals(null, citizenContact1.Id, 'Citizen Contact created successfully');
        
        //Create organization account
        List<Account> listOrgAccount = SSP_TestDataFactory.createAccounts(1, true, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId());
        listOrgAccount[0].DCDataId__c=4.0;
        update listOrgAccount;
        System.assertNotEquals(null, listOrgAccount[0].Id, 'Org Account created successfully');
        
        //Application Account
        List<Account> listAppAccount = SSP_TestDataFactory.createAccounts(1, true, Schema.SObjectType.Account.getRecordTypeInfosByName().get('Application').getRecordTypeId());
        
        System.assertNotEquals(null, listOrgAccount[0].Id, 'App Account created successfully');
        
        //Create ACR 
        List<AccountContactRelation> listACR = new List<AccountContactRelation>();
        AccountContactRelation orgACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(nonCitizenContact2.Id, listOrgAccount[0].Id, false);
        orgACR.Roles = 'Assister';
        listACR.add(orgACR);
        AccountContactRelation appACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(citizenContact1.Id, listAppAccount[0].Id, false);
        appACR.DCContactId__c=747238.0;
        listACR.add(appACR);
        AccountContactRelation assisterACR = SSP_TestDataFactory.createAccountContactRelationshipRecord(nonCitizenContact1.Id, listAppAccount[0].Id, false);
        assisterACR.Roles = 'Assister';
        listACR.add(assisterACR);
        insert listACR;
        
        //Create member 
        List<SSP_Member__c> listMembers = SSP_TestDataFactory.createSSPMembers(1, false);
        listMembers[0].FirstName__c='Andrews';
        listMembers[0].LastName__c='Nelsonj';
        listMembers[0].GenderCode__c='M';
        listMembers[0].Contact__c = citizenContact1.Id;
        insert listMembers;
        System.assertNotEquals(null, listMembers[0].Id, 'SSP Member created successfully');
        
        // application record for citizen
        List<SSP_Application__c> listApplication = SSP_TestDataFactory.createSSPApplications(1, false);
        listApplication[0].Account__c = listACR[1].AccountId;
        insert listApplication;
        
        List<SSP_ApplicationIndividual__c> listAppIndiv = SSP_TestDataFactory.createApplicationIndividuals(1, false);
        listAppIndiv[0].SSP_Member__c = listMembers[0].Id;
        listAppIndiv[0].SSP_Application__c = listApplication[0].Id;
        listAppIndiv[0].IsHeadOfHousehold__c = true;
        insert listAppIndiv;
        
    }
    }
    @isTest
    public static void dashboardLoadIndividual() {         
        String userId=[Select Id from User where Alias='assis'].id;  
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnLoad'));
        Test.startTest();
        SSP_NonCitizenDashboardController.getNonCitizenUserInfo(userId,true);
        SSP_NonCitizenDashboardController.getPicklistForSearch();
        SSP_NonCitizenDashboardController.resetCache();
        Test.stopTest();
        
    }
    @isTest
    public static void dashboardLoadIndividual1() {
         String userId=[Select Id from User where Alias='der'].id;  

        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnLoad'));
        Test.startTest();
        SSP_NonCitizenDashboardController.getNonCitizenUserInfo(userId,true);
        SSP_NonCitizenDashboardController.getPicklistForSearch();
        SSP_NonCitizenDashboardController.resetCache();
        Test.stopTest();
        
    }
    @isTest
    public static void dashboardLoadIndividual2() {
        List<User> userList=[Select Id,contactID from User where Alias='dcbs' LIMIT 1];  
        List<Contact> contactList = [Select Id,AssociatedCountyCode__c from Contact where Id=:userList[0].ContactId limit 1];  
        contactList[0].AssociatedCountyCode__c ='001';
        update contactList;
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnLoad'));
        Test.startTest();
        SSP_NonCitizenDashboardController.getNonCitizenUserInfo(userList[0].Id,true);
        SSP_NonCitizenDashboardController.getPicklistForSearch();
        SSP_NonCitizenDashboardController.resetCache();
        Test.stopTest();
        
    }    
    @isTest
    public static void dashboardLoadOrganisation() {        
        String userId=[Select Id from User where Alias='dail'].id;
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnLoad'));
        Test.startTest();
        SSP_NonCitizenDashboardController.getNonCitizenUserInfo(userId,true);
        Test.stopTest();
    }
    @isTest
    public static void dashboardLoadALLLevel() {        
        String userId=[Select Id from User where Alias='dcbs'].id;        
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnLoad'));
        Test.startTest();
        SSP_NonCitizenDashboardController.getNonCitizenUserInfo(userId,true);
        SSP_NonCitizenDashboardService.getWantToDashboardLinkVisibility(userId);
        SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole(userId);
        Test.stopTest();
    }    
    @isTest
    public static void searchOnIndividual() { 
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseStatus='AP';
        csr.submittedDate='LM'; 
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseApplication='11123231';
        csr.ssn='44443432';
        csr.dob='2020-02-02';        
        csr.addressLine1='32423rdaf';        
        csr.county='sdsa';
        csr.applicationStatus='UN';        
        csr.caseStatus='AP';        
        csr.renewalDueDate='LP';
        csr.rfiDueDate='LP'; 
        csr.submittedDate='2020-02-02'; 
        csr.assistedBy='Josh Paul';
        csr.phone='1123232323';
        csr.email='test@test.com';
        csr.maidNumber='123233';
        csr.applicationSubmittedToggle='false'; 
        
        String userId=[Select Id from User where Alias='assis'].id;  
        String searchQuery=JSON.serialize(csr); 
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        Test.stopTest();
    }
    @isTest
    public static void searchOnIndividual1() { 
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        
        String userId=[Select Id from User where Alias='assis'].id;  
        String searchQuery=JSON.serialize(csr);         
        Test.startTest();
        SSP_NonCitizenDashboardController.searchApplications(userId,'Assister',searchQuery);
        Test.stopTest();
    }
    @isTest
    public static void searchOnIndividualTest1() { 
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        
        String userId=[Select Id from User where Alias='assis'].id;  
        String searchQuery=JSON.serialize(csr);         
        Test.startTest();
        SSP_NonCitizenDashboardController.searchApplications(userId,'Agency_Admin',searchQuery);
        Test.stopTest();
    }
    @isTest
    public static void searchOnIndividualTest2() { 
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        
        String userId=[Select Id from User where Alias='assis'].id;  
        String searchQuery=JSON.serialize(csr);         
        Test.startTest();
        SSP_NonCitizenDashboardController.searchApplications(userId,'CHFS_Prod_Support',searchQuery);
        Test.stopTest();
    }
    
    @isTest
    public static void searchOnIndividual2() { 
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='';
        csr.lastName='';
        csr.caseApplication='';
        csr.ssn='';
        csr.dob='';
        csr.gender='';
        csr.addressLine1='';        
        csr.county='';
        csr.applicationStatus='';        
        csr.caseStatus='';        
        csr.renewalDueDate='';
        csr.rfiDueDate=''; 
        csr.submittedDate=''; 
        csr.assistedBy='';
        csr.phone='';
        csr.email='';
        csr.maidNumber='';
        csr.applicationSubmittedToggle='';
        String userId=[Select Id from User where Alias='assis'].id;
        String searchQuery=JSON.serialize(csr);
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        Test.stopTest();
    }
    @isTest
    public static void searchOnOrganisation() {
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseStatus='AP';
        csr.submittedDate='LM'; 
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseApplication='12313213';
        csr.ssn='44443432';
        csr.dob='2020-02-02';        
        csr.addressLine1='32423rdaf';        
        csr.county='sdsa';
        csr.applicationStatus='UN';        
        csr.caseStatus='AP';        
        csr.renewalDueDate='LP';
        csr.rfiDueDate='LP'; 
        csr.submittedDate='2020-02-02'; 
        csr.assistedBy='Josh Paul';
        csr.phone='1123232323';
        csr.email='test@test.com';
        csr.maidNumber='123233';
        csr.applicationSubmittedToggle='true';      
        //Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);        
        //sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, 'DAIL_Worker',7200);
        String userId=[Select Id from User where Alias='dail'].id;
        String searchQuery=JSON.serialize(csr);            
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        Test.stopTest();
    }
    @isTest
    public static void searchOnALLLevel() {
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseStatus='AP';
        csr.submittedDate='LM'; 
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseApplication='12313122';
        csr.ssn='44443432';
        csr.dob='2020-02-02';        
        csr.addressLine1='32423rdaf';        
        csr.county='sdsa';
        csr.applicationStatus='UN';        
        csr.caseStatus='AP';        
        csr.renewalDueDate='LP';
        csr.rfiDueDate='LP'; 
        csr.submittedDate='2020-02-02'; 
        csr.assistedBy='Josh Paul';
        csr.phone='1123232323';
        csr.email='test@test.com';
        csr.maidNumber='123233';
        String userId=[Select Id from User where Alias='dcbs'].id;
        String searchQuery=JSON.serialize(csr);
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        SSP_NonCitizenDashboardService.getWantToDashboardLinkVisibility(userId);
        SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole(userId);
        Test.stopTest();
    } 
    @isTest
    public static void searchOnALLLevel1() {
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseStatus='AP';
        csr.submittedDate='LM'; 
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseApplication='12313122';
        csr.ssn='44443432';
        csr.dob='2020-02-02';        
        csr.addressLine1='32423rdaf';        
        csr.county='sdsa';
        csr.applicationStatus='UN';        
        csr.caseStatus='AP';        
        csr.renewalDueDate='LP';
        csr.rfiDueDate='LP'; 
        csr.submittedDate='2020-02-02'; 
        csr.assistedBy='Josh Paul';
        csr.phone='1123232323';
        csr.email='test@test.com';
        csr.maidNumber='123233';         
        
        String userId=[Select Id from User where Alias='dcbs'].id;
        String searchQuery=JSON.serialize(csr);
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        //SSP_NonCitizenDashboardService.getWantToDashboardLinkVisibility(userId);
        //SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole(userId);
        Test.stopTest();
    }
        public static void searchOnALLLevel2() {
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='';
        csr.lastName='';
        csr.caseApplication='';
        csr.ssn='';
        csr.dob='';
        csr.gender='';
        csr.addressLine1='';        
        csr.county='';
        csr.applicationStatus='';        
        csr.caseStatus='';        
        csr.renewalDueDate='';
        csr.rfiDueDate=''; 
        csr.submittedDate=''; 
        csr.assistedBy='';
        csr.phone='';
        csr.email='';
        csr.maidNumber='';
        csr.applicationSubmittedToggle='';
        
        String userId=[Select Id from User where Alias='dcbs'].id;
        String searchQuery=JSON.serialize(csr);
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnQuery'));
        Test.startTest();
        SSP_NonCitizenDashboardController.searchNonCitizenClients(userId,searchQuery);
        //SSP_NonCitizenDashboardService.getWantToDashboardLinkVisibility(userId);
        //SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole(userId);
        Test.stopTest();
    } 
    @isTest
    public static void getContactFromWrapper(){
        SSP_NonCitizenDashboardController.ClientSearchResult wrapperData= new SSP_NonCitizenDashboardController.ClientSearchResult();
        wrapperData.firstName='Yash';
        wrapperData.lastName='Johar';
        wrapperData.gender='M';
        wrapperData.individualId='999037608';
        String conData=JSON.serialize(wrapperData);
        SSP_NonCitizenDashboardController.getContactFromWrapper(conData);
    }
    @isTest
    public static void exportToExcel(){
        String userId=[Select Id from User where Alias='dcbs'].id;
        SSP_NonCitizenDashboardController.ClientSearchResult csr= new SSP_NonCitizenDashboardController.ClientSearchResult();
        csr.recordId='1';
        csr.caseNumber='100071952';
        csr.applicationNumber='6002323212';
        csr.individualId='920066494';
        csr.firstName='sjdjjd';
        csr.lastName='jshdks';
        csr.gender='M';
        csr.birthDate='2000-08-12';
        csr.age=20;
        csr.addressLine1='test';
        csr.addressLine2='test12';
        csr.zipcode='1223';
        csr.phoneNumber='8374932';
        csr.email='test@test.com';        
        csr.ssn9='123234333';
        csr.assistedByAuthRep='235429454';
        csr.assistedByAssister='384289122';
        csr.clientRole='DAIL_Worker';
        csr.rfiDueDate='LR';
        csr.numberOfRFI='1';
        csr.renewalDueDate='2020-11-04';
        csr.programDueRenewal='MA';
        csr.mcoEnrollmentStatus='AP';
        csr.caseApplicationStatus='AP';
        csr.submittedDate='2020-11-11';
        csr.lastUpdatedDate='LR';
        csr.maidCardNumber='1112211211';
        csr.isApplication=false; 
        csr.isCase=true;   
        csr.suffix='JR.'; 
        csr.middleInitial='M'; 
        
        SSP_NonCitizenDashboardController.ClientSearchResult csr1= new SSP_NonCitizenDashboardController.ClientSearchResult();
        csr1.recordId='1';
        csr1.caseNumber='100079952';
        csr1.applicationNumber='6002313212';
        csr1.individualId='920066494';
        csr1.firstName='sjdjjd';
        csr1.lastName='jshdks';
        csr1.gender='M';
        csr1.birthDate='2000-08-12';
        csr1.age=20;
        csr1.addressLine1='test';
        csr1.addressLine2='test12';
        csr1.zipcode='1223';
        csr1.phoneNumber='8374932';
        csr1.email='test@test.com';        
        csr1.ssn9='123234333';
        csr1.assistedByAuthRep='235429454';
        csr1.assistedByAssister='384289122';
        csr1.clientRole='DAIL_Worker';
        csr1.rfiDueDate='LR';
        csr1.numberOfRFI='1';
        csr1.renewalDueDate='2020-11-04';
        csr1.programDueRenewal='MA';
        csr1.mcoEnrollmentStatus='AP';
        csr1.caseApplicationStatus='AP';
        csr1.submittedDate='2020-11-11';
        csr1.lastUpdatedDate='LR';
        csr1.maidCardNumber='1112211211';
        csr1.isApplication=true; 
        csr1.isCase=false;   
        csr1.suffix='JR.'; 
        csr1.middleInitial='M'; 
        list<SSP_NonCitizenDashboardController.ClientSearchResult> csrlist= new list<SSP_NonCitizenDashboardController.ClientSearchResult>();
        csrlist.add(csr);
        csrlist.add(csr1);
        
        String listClientSearchResult=JSON.serialize(csrlist);
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnExport'));
        Test.startTest();
        SSP_NonCitizenDashboardController.exportToExcel(listClientSearchResult ,userId , 'sspMyInformationCard');
        Test.stopTest();
    }
    @isTest
    public static void exportToExcel1(){
        String userId=[Select Id from User where Alias='dcbs'].id;
        SSP_NonCitizenDashboardController.ClientSearchResult csr= new SSP_NonCitizenDashboardController.ClientSearchResult();
        csr.recordId='1';
        csr.caseNumber='100071952,100074457';
        csr.applicationNumber='6002323212';
        csr.individualId='920066494';
        csr.firstName='sjdjjd';
        csr.lastName='jshdks';
        csr.gender='M';
        csr.birthDate='2000-08-12';
        csr.age=20;
        csr.addressLine1='test';
        csr.addressLine2='test12';
        csr.zipcode='1223';
        csr.phoneNumber='8374932';
        csr.email='test@test.com';        
        csr.ssn9='123234333';
        csr.assistedByAuthRep='235429454';
        csr.assistedByAssister='384289122';
        csr.clientRole='DAIL_Worker';
        csr.rfiDueDate='LR';
        csr.numberOfRFI='1';
        csr.renewalDueDate='2020-11-04';
        csr.programDueRenewal='MA';
        csr.mcoEnrollmentStatus='AP';
        csr.caseApplicationStatus='AP';
        csr.submittedDate='2020-11-11';
        csr.lastUpdatedDate='LR';
        csr.maidCardNumber='1112211211';
        csr.isApplication=false; 
        csr.isCase=true;   
        csr.suffix='JR.'; 
        csr.middleInitial='M'; 
        
        
        list<SSP_NonCitizenDashboardController.ClientSearchResult> csrlist= new list<SSP_NonCitizenDashboardController.ClientSearchResult>();
        csrlist.add(csr);
        
        
        String listClientSearchResult=JSON.serialize(csrlist);
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('searchOnExport'));
        Test.startTest();
        SSP_NonCitizenDashboardController.exportToExcel(listClientSearchResult ,userId , 'sspMyInformationCard');
        Test.stopTest();
    }    
    @isTest
    public static void redirectionPortal(){
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('redirectionPortal'));
        Test.startTest();
        //Added part of 20.10 release
        User adminUser =[Select id from User where Profile.Name=:'System Administrator' AND isActive = TRUE Limit 1];
        System.runAs(adminUser){
            SSP_NonCitizenDashboardService.redirectToIndividualDashboard('31416eb6-d3e6-44bd-a63c-d2d296a754e1');
        }
        Test.stopTest();
    }
    @isTest
    public static void redirectionPortal1(){
        Test.setMock(HttpCalloutMock.class, new SSP_NonCitizenSearch_HttpMockTest('redirectionPortal'));
        Test.startTest();
        //Added part of 20.10 release
        User adminUser =[Select id from User where Profile.Name=:'System Administrator' AND isActive = TRUE Limit 1];
        System.runAs(adminUser){
        SSP_NonCitizenDashboardService.updateRoleAndPermissionForWaiver('31416eb6-d3e6-44bd-a63c-d2d296a754e1');
        }
        Test.stopTest();
    }
    @isTest
    public static void screenPermisonBasedonRole(){
        SSP_LightningResponse dataToSend = new SSP_LightningResponse();
        try{
            SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole(null);            
        }catch(Exception ex) {
            dataToSend.put('Error','Error');
        }
    }
    @isTest
    public static void filterCasesBasedOnStatusTest(){
        SSP_NonCitizenDashboardController.ClientSearchResult csr= new SSP_NonCitizenDashboardController.ClientSearchResult();
        csr=new SSP_NonCitizenDashboardController.ClientSearchResult('','100012342,100034567','','9000945678','FirstName','LastName','M','02-02-2001',
                                                                     SSP_NonCitizenDashboardController.getAgeOfClient('02-02-2001'),'38982398432','caseInfo.AddressLine2','34323','5644564323','test@test.com','756374758','',
                                                                     'usiuhfksj',null,'DAIL_Worker','','','','','','Discontinued,Approved','','','',false,true);                
        
        SSP_NonCitizenDashboardController.filterCasesBasedOnStatus(csr);            
        
    }
    @isTest
    public static void buildWhereClauseTest(){
        SSP_NonCitizenDashboardController.ClientSearchQuery csr= new SSP_NonCitizenDashboardController.ClientSearchQuery();
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseStatus='AP';
        csr.submittedDate='LM'; 
        csr.firstName='s';
        csr.lastName='j';
        csr.gender='M';
        csr.caseApplication='11123231';
        csr.ssn='44443432';
        csr.dob='2020-02-02';        
        csr.addressLine1='32423rdaf';        
        csr.county='sdsa';
        csr.applicationStatus='UN';        
        csr.caseStatus='AP';        
        csr.renewalDueDate='LP';
        csr.rfiDueDate='LP'; 
        csr.submittedDate='2020-02-02';         
        csr.phone='1123232323';
        csr.email='test@test.com';
        csr.maidNumber='123233';
        csr.applicationSubmittedToggle='false'; 
        String searchQuery=JSON.serialize(csr);
        SSP_NonCitizenDashboardController.buildWhereClause(searchQuery,'DAIL_Worker'); 
        String userId=[Select Id from User where Alias='dail'].id;
        SSP_NonCitizenDashboardController.searchClientOrganisationWide(userId,'DAIL_Worker',searchQuery);  
        SSP_NonCitizenDashboardController.searchClientRelatedToUserOrganisation(userId,'DAIL_Worker',searchQuery);
        
    }
    @isTest
    public static void orgWideserchTest(){        
        String userId=[Select Id from User where Alias='dail'].id;
        SSP_NonCitizenDashboardController.searchClientOrganisationWide(userId,'DAIL_Worker',''); 
        SSP_NonCitizenDashboardController.searchClientRelatedToUserOrganisation(userId,'DAIL_Worker','');
        Contact cnt =[SELECT Id, FirstName, LastName, KOGSourceId__c, email From Contact Limit 1];
        SSP_NonCitizenDashboardController.onBoardIndvidualAuthRepCallout(cnt);
        //SSP_NonCitizenDashboardController.isActive(System.today());
        
    }
    
    @isTest
    public static void isActiveTest(){
        Date dtMyDateTime = System.today();
        SSP_NonCitizenDashboardController.isActive(dtMyDateTime);
    }
}