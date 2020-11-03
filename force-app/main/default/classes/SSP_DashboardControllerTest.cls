/*
* classname     :  SSP_DashboardControllerTest
* @description  :  Test Class for SSP_DashboardControllerTest
* @author       :  Aditya Krishna  
* @date         :  24/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest
public class SSP_DashboardControllerTest {
    @testSetup static void setup() {
        SSP_TestDataFactory.setupTestData();
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Id accRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');
        
        User cUser = fetchCitizenUser();
        Contact userContact = [SELECT Id, IndividualId__c FROM Contact WHERE Id =:cUser.ContactId];
        userContact.IndividualId__c = '123456';
        userContact.IsDashboardRefreshNeeded__c = true;
        userContact.DoesCaseExistForIndividual__c=true;
        userContact.Is_Eligible_For_RSSPDC__c=true;
        update userContact;
        
        Contact_Mapping__c conMapping = new Contact_Mapping__c();
        conMapping.Contact__c = userContact.Id;
        conMapping.IEES_Id__c = Decimal.valueOf('123456');
        insert conMapping;
        
        List<Account> lstAccounts = SSP_TestDataFactory.createAccounts(3, false);
        lstAccounts[0].Name = 'TaxFilingTestAppAccount';
        lstAccounts[0].RecordTypeId = accRecordTypeId;
        lstAccounts[1].RecordTypeId = accRecordTypeId;
        lstAccounts[2].RecordTypeId = accRecordTypeId;
        lstAccounts = ESAPI.accessController().insertAsUser(lstAccounts, SSP_Utility.getFieldsNamesList (lstAccounts)).getInsertedObjects();
        
        //List<Contact> lstContacts = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenOne', 'User', 'citizenone@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTwo', 'User', 'citizentwo@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTww', 'User', 'citizentww@abc.xyz', contactRecordTypeId, false));
        insert lstContacts;

        AccountContactRelation acrObjectMemberOne = new AccountContactRelation(); 
        acrObjectMemberOne.Accountid = lstAccounts[0].Id;
        acrObjectMemberOne.Contactid = fetchCitizenUser().ContactId;
        acrObjectMemberOne.IsActive = true;
        acrObjectMemberOne.Roles=SSP_GlobalConstants.ASSISTER_ROLE;

        AccountContactRelation acrObjectMemberTwo = new AccountContactRelation(); 
        acrObjectMemberTwo.Accountid = lstAccounts[1].Id;
        acrObjectMemberTwo.Contactid = fetchCitizenUser().ContactId;
        acrObjectMemberTwo.IsActive = true;
        acrObjectMemberTwo.Roles=SSP_GlobalConstants.AUTHORIZED_REPRESENTATIVE_ROLE;

        AccountContactRelation acrObjectMemberThree = new AccountContactRelation(); 
        acrObjectMemberThree.Accountid = lstAccounts[2].Id;
        acrObjectMemberThree.Contactid = fetchCitizenUser().ContactId;
        acrObjectMemberThree.IsActive = true;
        acrObjectMemberThree.Roles=SSP_GlobalConstants.INSURANCE_AGENT_ROLE;

        List<AccountContactRelation> lstACRRecords = new List<AccountContactRelation>();
        lstACRRecords.add(acrObjectMemberOne);
        lstACRRecords.add(acrObjectMemberTwo);
        lstACRRecords.add(acrObjectMemberThree);

        ESAPI.accessController().insertAsUser(lstACRRecords, SSP_Utility.getFieldsNamesList (lstACRRecords));       
        
        List<SSP_Application__c> lstApplications = SSP_TestDataFactory.createSSPApplications(3, false);
        lstApplications[0].Account__c=lstAccounts[0].Id;
        lstApplications[0].ProgramsApplied__c = 'SN;KT;MA;SS';
        lstApplications[0].HasLifeEstateToggle__c = 'Y';
        lstApplications[0].Status__c = 'UN';
        lstApplications[0].ApplicationCreationInSSP__c = System.today().AddDays(8);
        lstApplications[0].ApplicationReceivedDateTime__c = System.now();

        lstApplications[1].Account__c=lstAccounts[1].Id;
        lstApplications[1].ProgramsApplied__c = 'SN;KT;MA;SS';
        lstApplications[1].HasLifeEstateToggle__c = 'Y';
        lstApplications[1].Status__c = 'P';
        lstApplications[1].ApplicationCreationInSSP__c = System.today();
        lstApplications[1].ApplicationReceivedDateTime__c = System.now();
        lstApplications[1].DCCaseNumber__c = null;

        lstApplications[2].Account__c=lstAccounts[2].Id;
        lstApplications[2].ProgramsApplied__c = 'SN;KT;MA;SS';
        lstApplications[2].HasLifeEstateToggle__c = 'Y';
        lstApplications[2].Status__c = 'UN';
        lstApplications[2].ApplicationCreationInSSP__c = System.today();
        lstApplications[2].ApplicationReceivedDateTime__c = System.now();
        lstApplications= ESAPI.accessController().insertAsUser(lstApplications, SSP_Utility.getFieldsNamesList (lstApplications)).getInsertedObjects();
        
        List<SSP_Member__c> lstMembers = SSP_TestDataFactory.createSSPMembers(3, false);
        lstMembers[0].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[0].FirstName__c=lstContacts[0].FirstName;
        lstMembers[0].LastName__c=lstContacts[0].LastName;     
        lstMembers[0].MiddleInitial__c = 'Y';
        lstMembers[0].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[0].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[0].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[0].HasInvestmentsToggle__c = 'Y';
        lstMembers[0].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[0].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[0].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers[0].IsBlindToggle__c = 'Y';
        lstMembers[1].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[1].FirstName__c=lstContacts[1].FirstName;
        lstMembers[1].LastName__c=lstContacts[1].LastName;     
        lstMembers[1].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[1].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[1].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[1].HasInvestmentsToggle__c = 'Y';
        lstMembers[1].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[1].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[1].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers[2].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[2].FirstName__c=lstContacts[2].FirstName;
        lstMembers[2].LastName__c=lstContacts[2].LastName;     
        lstMembers[2].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[2].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[2].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[2].HasInvestmentsToggle__c = 'Y';
        lstMembers[2].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[2].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[2].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers = ESAPI.accessController().insertAsUser(lstMembers, SSP_Utility.getFieldsNamesList (lstMembers)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_TestDataFactory.createApplicationIndividuals(3, false); 
        lstAppIndividuals[0].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[0].SSP_Member__c=lstMembers[0].Id;
        lstAppIndividuals[0].IsHeadOfHousehold__c=true;
        lstAppIndividuals[1].SSP_Application__c=lstApplications[1].Id;
        lstAppIndividuals[1].SSP_Member__c=lstMembers[0].Id;
        lstAppIndividuals[1].IsHeadOfHousehold__c=true;
        lstAppIndividuals[2].SSP_Application__c=lstApplications[2].Id;
        lstAppIndividuals[2].SSP_Member__c=lstMembers[0].Id;
        lstAppIndividuals[2].IsHeadOfHousehold__c=false;
        lstAppIndividuals = ESAPI.accessController().insertAsUser(lstAppIndividuals, SSP_Utility.getFieldsNamesList (lstAppIndividuals)).getInsertedObjects();
        
        System.runAs(cUser){
        SSP_Transaction__c transactionData = new SSP_Transaction__c(
            View_Name__c = 'QualifiedIndividual',
            IndividualId__c = '76459',
            ApplicationId__c = lstApplications[0].Id,
            CaseNumber__c = '123456',
            Mode__c = 'Intake',
            Status__c ='Success',
            Unique_Id__c=SSP_InterfaceConstants.NOTIFICATION_INFORMATION+';'+userContact.Id);
            insert transactionData;
        }
        
        
        insert new LOG_LogMessageSettings__c(
            Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED,
            LOG_Debug__c = true,
            LOG_Error__c= true,
            LOG_Info__c = true,
            LOG_Warning__c = true,
            LOG_Log_Purge__c = 365
        );
        AppConfig__c app= new AppConfig__c();
        app.Name='SSPNotificationCalloutSwitch';
        app.Value__c='ON';
        insert app;
    }

    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }

    @isTest
    public static void testTriggerDashboardServiceCallout(){
        Test.setMock(HttpCalloutMock.Class, new SSP_DashboardMockCalloutClass());
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put('isHeadOfHouseHold','true');
        sessionPart.put('hasActiveCase',JSON.serialize(new List<String>()));
        sessionPart.put('caseOptions',JSON.serialize(new List<String>()));
        sessionPart.put('hasMedicaidRenewals',JSON.serialize(new  List<SSP_DashboardCaseInformation.Renewal>()));
        sessionPart.put('hasOtherRenewals',JSON.serialize(new  List<SSP_DashboardCaseInformation.Renewal>()));
        sessionPart.put('notificationsList',JSON.serialize(new List<SSP_DashboardController.NotificationWrapper>()));
        sessionpart.put('isExistingUser',true,3600,Cache.Visibility.ALL, false);
        sessionpart.put('hasAuthRepAgents',JSON.serialize(new Map<String, String>()),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsStatus',JSON.serialize(new Map<String, String>()),3600,Cache.Visibility.ALL,false);
        sessionpart.put('isCaseInChangeMode', false, 3600, Cache.Visibility.ALL, false);
        sessionpart.put('caseOwnership', '', 3600, Cache.Visibility.ALL, false);
        sessionpart.put('isTeamMember', true, 3600, Cache.Visibility.ALL, false);
         SSP_DashboardController.triggerDashboardServiceCallOut('123456');
        Test.startTest();
        System.runAs(fetchCitizenUser()){
            SSP_DashboardController.triggerDashboardServiceCallOut('123456');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testTriggerDashboardServiceCallout1(){
        Test.setMock(HttpCalloutMock.Class, new SSP_DashboardMockCalloutClass());
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING);

        List<SSP_Application__c> lstApps = [SELECT Id FROM SSP_Application__c LIMIT 1];
        lstApps[0].Status__c = 'P';
        lstApps[0].DCCaseNumber__c = null;
        update lstApps;
        List<SSP_ApplicationIndividual__c> lstAppInd = [SELECT Id,IsHeadOfHousehold__c FROM SSP_ApplicationIndividual__c where IsHeadOfHousehold__c=true LIMIT 1];
        lstAppInd[0].IsHeadOfHousehold__c = false;
        update lstAppInd;
        Test.startTest();
        System.runAs(fetchCitizenUser()){
            SSP_DashboardController.triggerDashboardServiceCallOut('123456');
        }
        Test.stopTest();
        
    }

    @isTest
    public static void testTriggerMedicaidMCOServiceCall(){
        SSP_DashboardMockCalloutClass mockClass= new SSP_DashboardMockCalloutClass();
        mockClass.viewName='MedicaidMCOInformation'; 
        Test.setMock(HttpCalloutMock.Class, mockClass);
        Map<String,Boolean> caseMap=new Map<String,Boolean> ();
        caseMap.put('100060269',true);
        caseMap.put('100060267',true);
        caseMap.put('123456',false);
        caseMap.put('100060266',false);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId','123456');
        sessionPart.put('caseVsHOH',JSON.serialize(caseMap));
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_DashboardController.triggerMedicaidMCOServiceCall('123456', true);
            SSP_DashboardController.triggerMedicaidMCOServiceCall('100060267', true);
            Test.stopTest(); 
        }
    }
    @isTest
    public static void testTriggerBenefitsServiceCall(){
        SSP_DashboardMockCalloutClass mockClass= new SSP_DashboardMockCalloutClass();
        mockClass.viewName=SSP_InterfaceConstants.BENEFIT_INFORMATION; 
        Test.setMock(HttpCalloutMock.Class, mockClass);
        Map<String,Boolean> caseMap=new Map<String,Boolean> ();
        caseMap.put('100060267',true);
        caseMap.put('100060268',true);
        caseMap.put('100060269',true);
        caseMap.put('100060200',false);
        caseMap.put('123456',false);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('individualId','123456');
        sessionPart.put('caseVsHOH',JSON.serialize(caseMap));
        sessionPart.put('ActiveBenefits',JSON.serialize(new  Map<String,List<SSP_BenefitInformationWrapper>>()));
        sessionPart.put('PendingInterviewBenefits',JSON.serialize(new  Map<String,List<SSP_BenefitInformationWrapper>>()));
        sessionPart.put('PendingVerificationBenefits',JSON.serialize(new  Map<String,List<SSP_BenefitInformationWrapper>>()));
        sessionPart.put('hasKihippProgram',true,3600,Cache.Visibility.ALL,false);
        sessionPart.put('onlyKihippHoh',true,3600,Cache.Visibility.ALL,false);
        sessionPart.put('showKIHIPPSummary',true,3600,Cache.Visibility.ALL,false);
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_DashboardController.triggerBenefitsServiceCall('123456', true);
            SSP_DashboardController.triggerBenefitsServiceCall('', true);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testFetchMessageCenterData(){ 
        Test.setMock(HttpCalloutMock.Class, new SSP_DC_ReverseMockImpl());
        User u=fetchCitizenUser();
        User updateUser= new User();
        updateUser.Id=u.Id;
        updateUser.ImpersonatedIndividualId__c='123456';
        update updateUser;

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.ASSISTER_ROLE);
        SSP_LightningResponse response1 = SSP_DashboardController.fetchMessageCenterData();
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_LightningResponse response2 = SSP_DashboardController.fetchMessageCenterData();
            system.assertEquals(response2.bIsSuccess,true);
            Test.stopTest();
        }
    }

    @isTest
    public static void testFetchMessageCenterData1(){ 
        Test.setMock(HttpCalloutMock.Class, new SSP_DC_ReverseMockImpl());
        AppConfig__c transactionCheck = AppConfig__c.getInstance('SSPNotificationCalloutSwitch');
        transactionCheck.Value__c='OFF';
        update transactionCheck;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.ASSISTER_ROLE);
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_LightningResponse response2 = SSP_DashboardController.fetchMessageCenterData();
            system.assertEquals(response2.bIsSuccess,true);
            sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.CITIZEN_ROLE);
            SSP_LightningResponse response3 = SSP_DashboardController.fetchMessageCenterData();
            Test.stopTest();
        }
    }
    @isTest
    public static void testFetchMessageCenterData2(){ 
        Test.setMock(HttpCalloutMock.Class, new SSP_DC_ReverseMockImpl());
        String agencyRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        Contact objContact = SSP_TestDataFactory.createContactRecord('test','contact','test.contact@gmail.com',agencyRecordTypeId,true);
        User objUser = SSP_TestDataFactory.createCommunityUser('tste',objContact.Id,'test.contact@gmail.com','SSP Non Citizen Profile',true);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.AGENCY_ADMIN_ROLE);
        System.runAs(objUser){
            Test.startTest();
            SSP_LightningResponse response2 = SSP_DashboardController.fetchMessageCenterData();
            system.assertEquals(response2.bIsSuccess,true);
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void testCheckHasExistingApplication(){
        system.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_LightningResponse response1 = SSP_DashboardController.checkHasExistingApplication();            
            system.assertEquals(response1.bIsSuccess,null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testFetchRequiredData(){
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_LightningResponse response1 = SSP_DashboardController.fetchRequiredData();
            system.assertEquals(response1.bIsSuccess,true);    
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void testGetMemberTypeFlag(){
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_LightningResponse response1 = SSP_DashboardController.getMemberTypeFlag();
            system.assertEquals(response1.bIsSuccess,null); 
            Test.stopTest(); 
        }
    } 
    
    @isTest
    public static void getContactNameFirstTime(){
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_DashboardController.getContactNameFirstTime();
            Test.stopTest(); 
        }
    }
    
    
    /*@isTest
    public static void testFetchScreenNames(){
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            List<SSP_DashboardController.ScreenDetailWrapper> screenDetList = new List<SSP_DashboardController.ScreenDetailWrapper>();
            SSP_DashboardController.ScreenDetailWrapper wrappScreenObj =  new SSP_DashboardController.ScreenDetailWrapper();
            wrappScreenObj.flowName ='testFlow';
            wrappScreenObj.screens = 'firstScreen';
            screenDetList.add(wrappScreenObj);
            
            SSP_DashboardController.RACSelectionWrapper wrppObj = new SSP_DashboardController.RACSelectionWrapper();
            wrppObj.memberId ='testString';
            wrppObj.selectedScreens = screenDetList;
            SSP_DashboardController.fetchScreenNames(wrppObj);
            Test.stopTest(); 
        }
    }*/
    @isTest
    public static void testinvokeRAC(){
        /*List<SSP_DashboardController.ScreenDetailWrapper> screenDetList = new List<SSP_DashboardController.ScreenDetailWrapper>();
        SSP_DashboardController.ScreenDetailWrapper wrappScreenObj =  new SSP_DashboardController.ScreenDetailWrapper();
        wrappScreenObj.flowName ='testFlow';
        wrappScreenObj.screens = 'firstScreen';
        screenDetList.add(wrappScreenObj);
        
        SSP_DashboardController.RACSelectionWrapper wrppObj = new SSP_DashboardController.RACSelectionWrapper();
        wrppObj.memberId ='testString';
        wrppObj.selectedScreens = screenDetList;*/
        List<SSP_Application__c> lstApps = [SELECT Id FROM SSP_Application__c LIMIT 1];
        lstApps[0].RAC_Selections__c = '{"memberId":"123","selectedScreens":[{"flowName":"MemberHealthInformation","screens":"SSP_APP_Details_MedicareCoverageSummary"}]}';
        update lstApps; 

        SSP_LightningResponse response = SSP_DashboardController.invokeRAC(lstApps[0].Id);
        system.assert(response.mapResponse.containsKey('ERROR'));

        //lstApps[0].RAC_Selections__c=JSON.serialize(wrppObj);
        lstApps[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        update lstApps[0];

        response = SSP_DashboardController.invokeRAC(lstApps[0].Id);
        system.assert(!response.mapResponse.containsKey('ERROR'));
    }
    @isTest
    public static void testresumeApplication(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); //
        sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,SSP_GlobalConstants.CITIZEN_ROLE); //
         AppConfig__c app= new AppConfig__c();
        app.NAme='SSP_DriverNavigationUserLockTime';
        app.Value__c='30';
        insert app;
        Test.setMock(HttpCalloutMock.Class, new SSP_DashboardMockCalloutClass());
        Map<String, Object> newStatus= new Map<String, Object>();
        newStatus.put('Status',true);
        List<SSP_Application__c> lstApps = [SELECT Id FROM SSP_Application__c LIMIT 1];
        lstApps[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstApps[0].SectionStatus__c=JSON.serialize(newStatus);
        lstApps[0].Application_Change_Start_Timestamp__c=DateTime.now();
        update lstApps[0];
        Test.startTest();
        SSP_DashboardController.resumeApplication(lstApps[0].Id);
        Test.stopTest();

    }
    @isTest
    public static void testresumeApplication1(){
       
        Test.setMock(HttpCalloutMock.Class, new SSP_DashboardMockCalloutClass());
        Map<String, Object> newStatus= new Map<String, Object>();
        newStatus.put('Status',true);
        List<SSP_Application__c> lstApps = [SELECT Id FROM SSP_Application__c LIMIT 1];
        lstApps[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstApps[0].SectionStatus__c=null;
        update lstApps[0];
        Test.startTest();
        SSP_DashboardController.resumeApplication(lstApps[0].Id);
        SSP_DashboardController.getHOHContactForNextSteps(lstApps[0].Id);
        Test.stopTest();
        AppConfig__c app= new AppConfig__c();
        app.NAme='navigateToBackYard';
        app.Value__c='30';
        insert app;
        SSP_DashboardController.backYardNavigate();

    }

    @isTest
    public static void getOnlyDependentFlagTest(){
        SSP_DashboardController.getOnlyDependentFlag();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('onlyKihippHoh','true');
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            SSP_DashboardController.getOnlyDependentFlag();
            sessionPart.put('onlyKihippHoh','false');
            SSP_DashboardController.getOnlyDependentFlag();
            Test.stopTest(); 
        }
    }
    @isTest
    public static void driverNavigationDetailsForRACTest(){
        AppConfig__c app= new AppConfig__c();
        app.NAme='SSP_DriverNavigationUserLockTime';
        app.Value__c='30';
        insert app;
        List<String> lstRACCases = new List<String>();
        lstRACCases.add('123456');
        List<SSP_Application__c> lstApps = [SELECT Id FROM SSP_Application__c LIMIT 1];
        lstApps[0].DCCaseNumber__c=123456;
        lstApps[0].RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case');
        lstApps[0].Application_Change_Start_Timestamp__c=DateTime.now();
        update lstApps;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        sessionPart.put('hasActiveCase',JSON.serialize(lstRACCases));
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            //SSP_LightningResponse response1=SSP_DashboardController.driverNavigationDetailsForRAC('123456');
            SSP_LightningResponse response2=SSP_DashboardController.driverNavigationDetails('123456');
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void testRemoveFromList(){
        List<String> pList = new List<String>{'100837827','100738787'};
        System.runAs(fetchCitizenUser()){
            Test.startTest();
            pList = SSP_DashboardController.removeFromList(pList, '100738787');
            system.assert(!pList.contains('100738787'));
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void testresumeApplication_Negative(){
        Test.startTest();
        SSP_LightningResponse response = SSP_DashboardController.resumeApplication('exceptionStr');
        System.assert(!response.bIsSuccess);
        SSP_DashboardController.updateUserLanguage('en_US');
         SSP_DashboardController.updateUserLanguage('es_US');
        Test.stopTest(); 
    }
}