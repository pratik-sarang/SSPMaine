@isTest
public class SSP_RSSPDC_CalloutHelperTest {
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
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);        
        lstAppln[0].Account__c=lstAcc[1].Id;        
        lstAppln[0].Contact__c = nonCitizenUser.ContactId;
        lstAppln[0].ProgramsApplied__c = 'SS';
        insert lstAppln;
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].FirstName__c = 'Shrikant';
        lstMem[0].LastName__c = 'Raut';
        lstMem[0].contact__c=nonCitizenUser.ContactId;
        insert lstMem;
        
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].IsHeadOfHousehold__c = true;
        lstAppInd[0].MemberStatus__c = 'New';
        insert lstAppInd;   

    }
    
    @isTest
    public static void updateContactDetailsTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        SSP_ApplicationIndividual__c appIndv = [SELECT Id, SSP_Application__c, MemberStatus__c, IsHeadOfHousehold__c,  SSP_Member__r.Contact__c FROM SSP_ApplicationIndividual__c LIMIT 1];
        Contact con = new Contact(Id = appIndv.SSP_Member__r.Contact__c);
        con.FirstName = SSP_GlobalConstants.DUMMY_KEY;
        con.LastName = SSP_GlobalConstants.DUMMY_KEY;
        update con;
        
        
        
        Test.startTest();      
            Boolean result = SSP_RSSPDC_CalloutHelper.updateContactDetails(appIndv.SSP_Application__c);
            System.assert(result);
        
        Test.stopTest();
    }
    
        @isTest
    public static void classTest(){ 
        User nonCitizen  = [SELECT Id FROM User WHERE UserName = 'noncitizen@abc.xyz' LIMIT 1][0]; 
        SSP_ApplicationIndividual__c appIndv = [SELECT Id, SSP_Application__c, MemberStatus__c, IsHeadOfHousehold__c,  SSP_Member__r.Contact__c FROM SSP_ApplicationIndividual__c LIMIT 1];
        Contact con = new Contact(Id = appIndv.SSP_Member__r.Contact__c);
        con.FirstName = SSP_GlobalConstants.DUMMY_KEY;
        con.LastName = SSP_GlobalConstants.DUMMY_KEY;
        update con;
        
        SSP_Member__c member = [SELECT Id, Alias_First_Name__c, Alias_Last_Name__c, Identify_verification_method__c, Reference_Number__c, FirstName__c, LastName__c, DeathDate__c, SSN__c, NoReasonSSNCode__c, IsIntendToResideToggle__c, IsMilitaryMemberToggle__c, RaceCode__c, NationalityCode__c, IsHispanicLatinoSpanishToggle__c, SpecialNeedIndicatorToggle__c, EthnicityCode__c, IsUSCitizenToggle__c, BirthDate__c, IsDateOfDeathValidated__c, IsDateOfBirthValidated__c, IsUSCitizenValidated__c FROM SSP_Member__c WHERE Contact__c = :con.Id LIMIT 1];
        
        
        
        Test.startTest();   
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.ALL_VIEWS;
        reqWrapper.programCode = 'MA;KT';
        reqWrapper.applicationID = appIndv.SSP_Application__c;
        reqWrapper.mode =SSP_InterfaceConstants.MODE_INTAKE;
        
        SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper = new SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper();
        detailsWrapper.isCitizenUser = false;
        detailsWrapper.responseMemberData = member;
        detailsWrapper.member = member;
        
        SSP_RSSPDC_CalloutHelper helper = new SSP_RSSPDC_CalloutHelper(SSP_InterfaceConstants.REVERSE_SSP_DC, reqWrapper);
        helper = new SSP_RSSPDC_CalloutHelper(SSP_InterfaceConstants.REVERSE_SSP_DC, reqWrapper, detailsWrapper);
        
        helper.execute(null);
        Contact updatedContact = [Select Id, FirstName FROM Contact WHERE Id = :appIndv.SSP_Member__r.Contact__c LIMIT 1];
        
        System.assert(updatedContact.FirstName == 'Shrikant');
        //Boolean result = SSP_RSSPDC_CalloutHelper.updateContactDetails(appIndv.SSP_Application__c);
        //System.assert(result);
        
        Test.stopTest();
    }
    
    
}