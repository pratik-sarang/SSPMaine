@isTest
public class SSP_ProgramSelectionCtrlTest {
    @testSetup static void testSetUpData() {
        SSP_TestDataFactory.setupTestData();  
        User nonCitizenUser = SSP_TestDataFactory.setUpNonCitizenUser();  
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(2, false);
        lstAcc[0].Name = 'CitizenProgramSelection';
        lstAcc[1].Name = 'NonCitizenProgramSelection';
        insert lstAcc;
        
        List<Contact> lstCitizenCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1];//= SSP_TestDataFactory.createContacts(1, false); 
        lstCitizenCon[0].CacheBenefitProgramData__c = '[{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"KT","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"SFTESTUSER ALLSCENLFH","IndividualId":"999034247","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102976","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"DN","ProgramCode":"MA","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"SFTESTUSER ALLSCENLFH","IndividualId":"999034247","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102975","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":"Eligibility is denied,Individual is receiving benefits for this program in another state","DenialEffectiveDate":"2020-02-01","CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"SN","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"SFTESTUSER ALLSCENLFH","IndividualId":"999034247","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102980","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":"2020-02-22","RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"UR","ProgramCode":"KT","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"SDONELDKJ ISECODLKFJK","IndividualId":"999034248","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102976","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"SN","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"SDONELDKJ ISECODLKFJK","IndividualId":"999034248","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102980","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":"2020-02-22","RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"UR","ProgramCode":"KT","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"TLIYDFKJ LKDHFNVGTR","IndividualId":"999034249","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102976","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":"2020-02-22","RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"UR","ProgramCode":"SN","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"TLIYDFKJ LKDHFNVGTR","IndividualId":"999034249","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102980","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":"2020-02-22","RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"UR","ProgramCode":"KT","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"CHILDLKDFJ LKDFK","IndividualId":"999034250","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102976","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"DC","ProgramCode":"MA","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"CHILDLKDFJ LKDFK","IndividualId":"999034250","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102978","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":"Child is 1 &lt; Age &lt; 6,Eligibility is denied","DenialEffectiveDate":"2020-02-01","CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":"2020-01-01","ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null},{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"SN","PolicyId":null,"PolicyHolderName":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"CHILDLKDFJ LKDFK","IndividualId":"999034250","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"102980","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":null,"DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100059260","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2020-01-23","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null}]';
            lstCitizenCon[0].CacheDashboardData__c = '{"100059260":true}';
        update lstCitizenCon;
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCitizenCon[0].Id;
        acr.IsActive = true;
        acrList.add(acr);
        
        AccountContactRelation nonCitizenACR = new AccountContactRelation(); 
        nonCitizenACR.Accountid = lstAcc[1].Id;
        nonCitizenACR.Contactid = nonCitizenUser.ContactId;
        nonCitizenACR.IsActive = true;
        acrList.add(nonCitizenACR);        
        
        insert acrList;
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(2, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCitizenCon[0].Id;
        lstAppln[0].ProgramsApplied__c = 'SS;KT';
        
        lstAppln[1].Account__c=lstAcc[1].Id;        
        lstAppln[1].Contact__c = nonCitizenUser.ContactId;
        lstAppln[1].ProgramsApplied__c = 'SS';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(2, false);
        lstMem[0].contact__c=lstCitizenCon[0].Id; 
        lstMem[1].contact__c=nonCitizenUser.ContactId;
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(2, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[1].SSP_Application__c=lstAppln[1].Id;
        lstAppInd[1].SSP_Member__c=lstMem[1].Id;
        insert lstAppInd;   
        
        
        AppConfig__c app = new AppConfig__c();
        app.Name='SSPCertificate';
        app.Value__c = 'SSP_SelfSignedSandbox';
        insert app;
        
        SSPIntegrationEndpoints__c endpoint = new SSPIntegrationEndpoints__c();
        endpoint.Name = 'CreateAccountService';
        endpoint.URL__c = 'https://sspdev-benefind-reci.cs32.force.com/benefind/services/apexrest/CreateAccount/';
        insert endpoint;
        //Added part of 20.10 release
        AppConfig__c appConfig = new AppConfig__c();
        appConfig.Name='BenefindPrefix';
        appConfig.Value__c = 'benefits';
        insert appConfig;
        
    }
    
    @isTest
    public static void getProgramsTest(){ 
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]; 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        
        Test.startTest();
        System.runAs(citizen){
            SSP_LightningResponse getLighningResponse = new SSP_LightningResponse();                                   
            SSP_Application__c objSSPApplication = [SELECT ID FROM SSP_Application__c LIMIT 1];
            getLighningResponse = SSP_ProgramSelectionCtrl.getPrograms(null, objSSPApplication.Id, 'Intake');//sameasabove
            getLighningResponse = SSP_ProgramSelectionCtrl.getPrograms(null, null, 'Intake');
                                    
        }
        
        System.runAs(nonCitizen){
            SSP_LightningResponse getLighningResponse = new SSP_LightningResponse();
            SSP_Application__c objSSPApplication = [SELECT ID FROM SSP_Application__c LIMIT 1];
            getLighningResponse = SSP_ProgramSelectionCtrl.getPrograms(null, objSSPApplication.Id, 'Intake');//sameasabove
                                   
        }
        Test.stopTest();
    }
    
    @isTest
    public static void updateProgramsTest_Intake(){ 
        User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]; 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        
        Test.startTest();
        System.runAs(citizen){                                   
            SSP_Application__c objSSPApplication = [SELECT ID, DCCaseNumber__c FROM SSP_Application__c LIMIT 1]; 
            Map<String,String> MapToPass=new Map<String,String>{'mode'=>'Intake'};            
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void updateProgramsTest_Renewal(){ 
        User citizen  = [SELECT Id, ContactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0]; 
  		Contact con = new Contact(Id = citizen.ContactId);
        con.DoesCaseExistForIndividual__c = true;
        con.IndividualId__c = '47365824';
        update con;
        
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        
        Test.startTest();
        System.runAs(citizen){
            SSP_Application__c objSSPApplication = [SELECT ID, DCCaseNumber__c FROM SSP_Application__c LIMIT 1]; 
            Map<String,String> MapToPass=new Map<String,String>{'mode'=>'Renewal','caseNo'=>'12323'};        
        }
        Test.stopTest();
    }
    
    
    public static testMethod void identifyOperationTypeTest(){
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.loggedInUser = nonCitizen;
        
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper = SSP_ProgramSelectionService.identifyOperationType(detailsWrapper, new SSP_LightningResponse());
            System.assertEquals(SSP_GlobalConstants.CITIZEN_RECORD_CREATION, detailsWrapper.operationType);            
            
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';            
            detailsWrapper.operationType = null;
            detailsWrapper = SSP_ProgramSelectionService.identifyOperationType(detailsWrapper, new SSP_LightningResponse());
            System.assertEquals(SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION, detailsWrapper.operationType);   
            
            detailsWrapper.loggedInUser.ImpersonatedIndividualId__c = '7348237378';
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';
            detailsWrapper.operationType = null;
            detailsWrapper = SSP_ProgramSelectionService.identifyOperationType(detailsWrapper, new SSP_LightningResponse());
            System.assertEquals(SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION, detailsWrapper.operationType);   
            
            detailsWrapper.loggedInUser.Profile.Name = 'ABC';
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';
            detailsWrapper.operationType = null;
            detailsWrapper = SSP_ProgramSelectionService.identifyOperationType(detailsWrapper, new SSP_LightningResponse());
            System.assertEquals(null, detailsWrapper.operationType);   
            
        }
    }
    
    
    public static testMethod void triggerProgramSelectionOpsTest_CitizenRecCreation(){
        SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = true;
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.mode = 'Intake';
        detailsWrapper.loggedInUser = nonCitizen;
        detailsWrapper.loggedInUser.ContactId = citizen.ContactId;
        detailsWrapper.individualContact = SSP_ProgramSelectionService.queryContactDetails(new Map<String, String>{'Id'=> citizen.ContactId})[0];
        SSP_LightningResponse response;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper.operationType = SSP_GlobalConstants.CITIZEN_RECORD_CREATION;
            response = SSP_ProgramSelectionService.triggerProgramSelectionOps(detailsWrapper, new SSP_LightningResponse());
            System.assert(response.bIsSuccess);
        }
        Test.stopTest();
    }
    
    public static testMethod void triggerProgramSelectionOpsTest_ImpersonateWOIndividualId(){
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.mode = 'Intake';
        detailsWrapper.loggedInUser = nonCitizen;
        detailsWrapper.loggedInUser.ContactId = citizen.ContactId;
        detailsWrapper.individualContact = SSP_ProgramSelectionService.queryContactDetails(new Map<String, String>{'Id'=> citizen.ContactId})[0];
        SSP_LightningResponse response;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';            
            detailsWrapper.operationType = SSP_GlobalConstants.IMPERSONATED_WO_INDVID_RECORD_CREATION;
            response = SSP_ProgramSelectionService.triggerProgramSelectionOps(detailsWrapper, new SSP_LightningResponse());
            System.assert(response.bIsSuccess);
        }
        Test.stopTest();
    }
    
    public static testMethod void triggerProgramSelectionOpsTest_ImpersonateWIndividualId(){
        SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = true;
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.mode = 'Intake';
        detailsWrapper.loggedInUser = nonCitizen;
        detailsWrapper.loggedInUser.ContactId = citizen.ContactId;
        detailsWrapper.individualContact = SSP_ProgramSelectionService.queryContactDetails(new Map<String, String>{'Id'=> citizen.ContactId})[0];
        SSP_LightningResponse response;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper.loggedInUser.ImpersonatedIndividualId__c = '7348237378';
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';
            detailsWrapper.operationType = SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION;
            response = SSP_ProgramSelectionService.triggerProgramSelectionOps(detailsWrapper, new SSP_LightningResponse());
            System.assert(response.bIsSuccess);
            
        }
        Test.stopTest();
    }
    
    public static testMethod void triggerProgramSelectionOpsTest_ImpersonateWIndividualId_WOContact(){
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.mode = 'Intake';
        detailsWrapper.loggedInUser = nonCitizen;
        detailsWrapper.loggedInUser.ContactId = citizen.ContactId;
        SSP_LightningResponse response;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper.loggedInUser.ImpersonatedIndividualId__c = '7348237378';
            detailsWrapper.loggedInUser.SelectedRole__c = 'DAIL_Worker';
            detailsWrapper.operationType = SSP_GlobalConstants.IMPERSONATED_W_INDVID_RECORD_CREATION;
            response = SSP_ProgramSelectionService.triggerProgramSelectionOps(detailsWrapper, new SSP_LightningResponse());
            System.assert(response.bIsSuccess);
            
        }
        Test.stopTest();
    }
    
    public static testMethod void triggerProgramSelectionOpsTest_QualifiedCall(){
        SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = true;
        User citizen  = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];  
        User nonCitizen  = [SELECT Id, Contact.AccountId, ContactId,Profile.Name,SelectedRole__c,ImpersonatedIndividualId__c,Contact.FirstName,Contact.LastName,Contact.IndividualId__c,Contact.DoesCaseExistForIndividual__c FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = nonCitizen.Contact.AccountId;
        acr.ContactId = citizen.ContactId;
        insert acr;
        
        SSP_ProgramSelectionService.DetailsWrapper detailsWrapper = new SSP_ProgramSelectionService.DetailsWrapper();
        detailsWrapper.mode = 'Intake';
        detailsWrapper.loggedInUser = nonCitizen;
        detailsWrapper.loggedInUser.ContactId = citizen.ContactId;        
        detailsWrapper.individualContact = SSP_ProgramSelectionService.queryContactDetails(new Map<String, String>{'Id'=> citizen.ContactId})[0];
        detailsWrapper.individualContact.IndividualId__c = '6473674';
        SSP_LightningResponse response;
        Test.setMock(HttpCalloutMock.class, new SSP_ProgramSelectionServiceMock());
        Test.startTest();
        System.runAs(citizen){
            detailsWrapper.loggedInUser.SelectedRole__c = SSP_GlobalConstants.CITIZEN_ROLE;
            detailsWrapper.operationType = SSP_GlobalConstants.QUALIFIED_INDV_CALL;
            response = SSP_ProgramSelectionService.triggerProgramSelectionOps(detailsWrapper, new SSP_LightningResponse());
            System.assert(response.bIsSuccess);   
            
        }
        Test.stopTest();
    }
        @isTest 
    public static void testAssign(){
        SSP_Member__c Member = [SELECT Id, Contact__c ,FirstName__c,LastName__c from SSP_Member__c limit 1];
        SSP_Application__c App = [SELECT Id,ProgramsApplied__c from SSP_Application__c limit 1];
        SSP_ProgramSelectionService.getMemberData(String.valueOf(Member.Id));
        SSP_ProgramSelectionService.getProgsAppIndividual(String.valueOf(Member.Id));
        SSP_ProgramSelectionService.constructProgramsString(String.valueOf(App.ProgramsApplied__c));
        
        
        }
    
    
}