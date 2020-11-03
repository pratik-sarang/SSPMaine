@isTest(seeAllData=false)
public with sharing class SSP_ChildcareEnrollSummaryCtrlTest {
 @testSetup
  static void setupTestData() {
      	//User Creation
      	UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
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
                Email = System.now().millisecond() + 'test@test.com',
                IndividualId__c = '1250002321'
                
            );
            Database.insert(contactForPortalUser);
            //contact mapping 
            Contact_Mapping__c conmapping= new Contact_Mapping__c(
            IEES_Id__c=1250002321,
            Contact__c=contactForPortalUser.Id);
            Database.insert(conmapping);
            
            //Create SSP Member
            SSP_Member__c objMem = new SSP_Member__c(
            	Contact__c = contactForPortalUser.Id,
            	FirstName__c='Test',
            	LastName__c = 'McTesty'
            	
        );
            Database.insert(objMem);
 //Create SSP Application 
            SSP_Application__c SSPApp = new SSP_Application__c(
                Contact__c = contactForPortalUser.Id,
                Account__c = portalUserAccount.Id,
                Status__c = 'P',
                ProgramsApplied__c ='MA;KT;CC;SN;SS;KP'
            );
            Database.insert(SSPApp);
            
                SSP_Application__c SSPAppUn = new SSP_Application__c(
                Contact__c = contactForPortalUser.Id,
                Account__c = portalUserAccount.Id,
                Status__c = 'UN',
                RecordTypeId=SSP_Utility.getRecrodTypeIdBySobjectAndDevName('SSP_Application__c','Case'),
        		LocalDCBSOffice__c = 'Kentucky',
        		ProgramsApplied__c ='MA;KT;CC;SN;SS;KP',
        		//DCCaseNumber__c = 890,
        		RAC_Selections__c='CIS_CareTaker',
        		ApplicationCreationInSSP__c = system.today()
            );
            Database.insert(SSPAppUn);
            
            SSP_Application__c SSPAppNcase = new SSP_Application__c(
                Contact__c = contactForPortalUser.Id,
                Account__c = portalUserAccount.Id,
                Status__c = 'UN'
            );
            Database.insert(SSPAppNcase);
            
                SSP_Application__c SSPAppNull = new SSP_Application__c(
                Contact__c = contactForPortalUser.Id,
                Account__c = portalUserAccount.Id
            );
            Database.insert(SSPAppNull);
            
            SSP_ApplicationIndividual__c SSPAppInd = new SSP_ApplicationIndividual__c(
                SSP_Application__c = SSPApp.Id,
                SSP_Member__c= ObjMem.Id,
                IsHeadOfHousehold__c = false
            );
            Database.insert(SSPAppInd);
                       
            SSP_ApplicationIndividual__c SSPAppIndUn = new SSP_ApplicationIndividual__c(
            SSP_Application__c = SSPAppUn.Id,
            SSP_Member__c= ObjMem.Id,
            IsHeadOfHousehold__c = true
            );
            Database.insert(SSPAppIndUn);
           
            SSP_ApplicationIndividual__c SSPAppNcaseIn = new SSP_ApplicationIndividual__c(
            SSP_Application__c = SSPAppNcase.Id,
            SSP_Member__c= ObjMem.Id,
            IsHeadOfHousehold__c = true
            );
            Database.insert(SSPAppNcaseIn);

            
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

   		SSP_DashboardCaseInformation dashboardInfo =  new SSP_DashboardCaseInformation();
        RSSP_DC_Wrapper response = new RSSP_DC_Wrapper();
        Map<String,String> mapCaseVsStatus = new Map<String,String>();         
        List<Object> serviceResponses =  new List<Object>();
        List<SSP_ApplicationIndividual__c> lstAppIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_IndividualInfoWrapper> lstIndividualData = new List<SSP_IndividualInfoWrapper>();
        List<SSP_DashboardCaseInformation.CaseInfo> lstIndividuals = new  List<SSP_DashboardCaseInformation.CaseInfo>();
        List<SSP_DashboardCaseInformation.TimeStampDetailsWrapper> lstTimeStampDetails = new  List<SSP_DashboardCaseInformation.TimeStampDetailsWrapper>();
        List<SSP_DashboardCaseInformation.Renewal> listRenewal = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.Renewal> listAllRenewals = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.Renewal> listMedicaidRenewal = new  List<SSP_DashboardCaseInformation.Renewal>();
        List<SSP_DashboardCaseInformation.AgentAssisterAuthRep> listAgentAssisterAuthRep = new  List<SSP_DashboardCaseInformation.AgentAssisterAuthRep>();
        //List<AboutToExpireWrapper> lstUnsubmittedApplication = new List<AboutToExpireWrapper>();
        //List<AboutToExpireWrapper> lstPendingInterviewApplications = new List<AboutToExpireWrapper>();
        //List<NotificationWrapper> lstNotificationWrapper = new List<NotificationWrapper>();
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<Account> lstAccount = new List<Account>();           
        List<AccountContactRelation> lstACR = new  List<AccountContactRelation>();    
        List<String> lstRACCases = new List<String>();
        Set<Id> lstAccountIds = new Set<Id>(); 
        Map<String, Object> mapParams = new Map<String, Object>();
        Map<String, List<string>> mapApplicationVsPrograms = new Map<String, List<string>>();
        Map<String, Boolean> mapCaseVsHOH = new Map<String, Boolean>();
        Map<String, Boolean> mapCaseVsRenewal = new Map<String, Boolean>();
        Map<String, String> mapRoleVsList = new Map<String, String>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        Contact conToBeUpdated;///WIP
        /*	message center changes */
        map<String,Set<String>> authRepAccessForNotices = new map<String,Set<String>>();
        
            
        RSSP_DC_Wrapper wrapperResponse =  new RSSP_DC_Wrapper();
        //DashboardCacheWrapper cacheWrap; 
        String currentUserIndividualIds;
        }
        User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
      
		////Separation 
		//System.debug(fetchedPortalUser);
        
    }
@istest
static void testGetEnrollmentDetails()
{
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String activeBenefits='{"100011699":[{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"TypeOfAssistanceCode":"Child Care Assistance","SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"Child Care Assistance","PolicyId":null,"PolicyHolderName":null,"PolicyHolderId":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"GLOT TEST","IndividualId":"1250002321","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"39025","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":"53CDDC1A-6AE9-9467-2666-39D24D819338","DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100011699","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2015-04-20","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null}]}';
            sessionPart.put('ActiveBenefits',activeBenefits);
    User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       Test.setMock(HttpCalloutMock.class, new SSP_ChildCareProviderSearchIntegServTest.SSP_ChildCareProviderSearchIntegServiceMock('ChildCareEnrollmentSummary'));
      

Test.startTest();
SSP_LightningResponse objResponse=SSP_ChildcareEnrollSummaryCtrl.getEnrollmentDetails('1250002321');
Test.stopTest();
System.assert(objResponse.bIsSuccess);

}
    
    @istest
static void testGetEnrollmentDetailswithPI()
{
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
    String pendingInterviewBenefits='{"100011699":[{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"TypeOfAssistanceCode":"Child Care Assistance","SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"Child Care Assistance","PolicyId":null,"PolicyHolderName":null,"PolicyHolderId":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"GLOT TEST","IndividualId":"1250002321","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"39025","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":"53CDDC1A-6AE9-9467-2666-39D24D819338","DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100011699","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2015-04-20","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null}]}';
            sessionPart.put('PendingInterviewBenefits',pendingInterviewBenefits);
    User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       Test.setMock(HttpCalloutMock.class, new SSP_ChildCareProviderSearchIntegServTest.SSP_ChildCareProviderSearchIntegServiceMock('ChildCareEnrollmentSummary'));
      

Test.startTest();
SSP_LightningResponse objResponse=SSP_ChildcareEnrollSummaryCtrl.getEnrollmentDetails('1250002321');
Test.stopTest();
System.assert(objResponse.bIsSuccess);
}
      @istest
static void testGetEnrollmentDetailswithPE()
{
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
    String pendingVerificationBenefits='{"100011699":[{"WaiverProgramCode":null,"WaiverApplicationNumber":null,"UpcomingMonthPatientLiabilityAmount":null,"TypeOfAssistanceCode":"Child Care Assistance","SNAPClaimAmount":null,"ReviewDate":null,"RenewalDueDate":null,"ReferredToFFM":null,"ProgramStatusCode":"PE","ProgramCode":"Child Care Assistance","PolicyId":null,"PolicyHolderName":null,"PolicyHolderId":null,"PendingEnrollmentCount":null,"PenaltyEndDate":null,"PenaltyBeginDate":null,"PatientLiabilityUpcomingMonth":null,"PatientLiabilityCurrentMonth":null,"IsWaiverLinkEnabled":null,"IsPreferredPaymentAccessed":null,"InsurancePlanName":null,"InsuranceComanyName":null,"IndividualName":"GLOT TEST","IndividualId":"1250002321","HasActiveSuspension":"N","HasActivePenalty":"N","EdgNumber":"39025","EBTCardFundLoadDate":null,"DocumentDueDate":null,"DMSDocumentId":"53CDDC1A-6AE9-9467-2666-39D24D819338","DenialReason":null,"DenialEffectiveDate":null,"CurrentMonthPatientLiabilityAmount":null,"CopayMonth3":null,"CopayMonth2":null,"CopayMonth1":null,"CopayEffectiveDate":null,"CopayAmountMonth3":null,"CopayAmountMonth2":null,"CopayAmountMonth1":null,"CaseNumber":"100011699","BenefitEndDate":null,"BenefitBeginDate":null,"ApplicationSubmissionDate":"2015-04-20","AllotmentMonth3":null,"AllotmentMonth2":null,"AllotmentMonth1":null,"AllotmentAmountMonth3":null,"AllotmentAmountMonth2":null,"AllotmentAmountMonth1":null,"ActiveEnrollmentCount":null}]}';
            sessionPart.put('PendingVerificationBenefits',pendingVerificationBenefits);
    User fetchedPortalUser = [SELECT id ,ContactId FROM User WHERE LastName=:'McTesty'];
       Test.setMock(HttpCalloutMock.class, new SSP_ChildCareProviderSearchIntegServTest.SSP_ChildCareProviderSearchIntegServiceMock('ChildCareEnrollmentSummary'));
      

Test.startTest();
SSP_LightningResponse objResponse=SSP_ChildcareEnrollSummaryCtrl.getEnrollmentDetails('1250002321');
Test.stopTest();
System.assert(objResponse.bIsSuccess);

}


}