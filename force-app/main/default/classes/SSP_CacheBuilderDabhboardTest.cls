/*
* classname     :  SSP_CacheBuilderDabhboardTest
* @description  :  Test class for SSP_CacheBuilderImplementationDabhboard
* @author       :  Kireeti Gora  
* @date         :  08/24/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_CacheBuilderDabhboardTest {
@testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();  
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'CacheBuilderDabhboard';
        insert lstAcc;
        
        List<Contact> lstCon = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'Citizen' AND LastName = 'User' LIMIT 1]; 
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenOne', 'User', 'citizenone@abc.xyz', contactRecordTypeId, false));
   		 lstContacts[0].id = lstCon[0].id;
        lstContacts[0].CaseOwnership__c ='test';
        lstContacts[0].individualId__c ='999034362';
    	lstContacts[0].CacheDashboardData__c = '{"mapCaseVsStatus":{"100060269":"AP"},"mapCaseVsIndividualId":{"100060269":"999034362"},"mapCaseVsHOH":{"100060269":true},"lstRAC":["100072976"],"hasRACEnabled":true,"authRepAccessForNotices":{"100060269":["KT"]}}';
     	lstContacts[0].CacheBenefitProgramData__c =
            
    '            [ '+
    '            {   '+
    '              "CaseNumber": "100060269",    '+
    '              "IndividualId": "999034362",  '+
    '              "IndividualName": "WEWRT GFG",    '+
    '              "ProgramCode": "KT",  '+
    '              "ProgramStatusCode": "AP",    '+
    '              "BenefitBeginDate": null, '+
    '              "BenefitEndDate": null,   '+
    '              "RenewalDueDate": null,   '+
    '              "ReviewDate": null,   '+
    '              "DocumentDueDate": "2020-02-21",  '+
    '              "ApplicationSubmissionDate": "2020-02-11",    '+
    '              "DenialEffectiveDate": null,  '+
    '              "DenialReason": null, '+
    '              "CurrentMonthPatientLiabilityAmount": null,   '+
    '              "UpcomingMonthPatientLiabilityAmount": null,  '+
    '              "IsWaiverLinkEnabled": null,  '+
    '              "HasActiveSuspension": "N",   '+
    '              "HasActivePenalty": "N",  '+
    '              "PenaltyBeginDate": null, '+
    '              "PenaltyEndDate": null,   '+
    '              "ReferredToFFM": null,    '+
    '              "PolicyHolderName": null, '+
    '              "InsuranceComanyName": null,  '+
    '              "InsurancePlanName": null,    '+
    '              "PolicyId": null, '+
    '              "IsPreferredPaymentAccessed": null,   '+
    '              "AllotmentMonth1": null,  '+
    '              "AllotmentAmountMonth1": null,    '+
    '              "AllotmentMonth2": null,  '+
    '              "AllotmentAmountMonth2": null,    '+
    '              "AllotmentMonth3": null,  '+
    '              "AllotmentAmountMonth3": null,    '+
    '              "EBTCardFundLoadDate": null,  '+
    '              "SNAPClaimAmount": null,  '+
    '              "EdgNumber": null,    '+
    '              "CopayMonth1": null,  '+
    '              "CopayAmountMonth1": null,    '+
    '              "CopayMonth2": null,  '+
    '              "CopayAmountMonth2": null,    '+
    '              "CopayMonth3": null,  '+
    '              "CopayAmountMonth3": null,    '+
    '              "CopayEffectiveDate": null,   '+
    '              "ActiveEnrollmentCount": null,    '+
    '              "PendingEnrollmentCount": null,   '+
    '              "WaiverApplicationNumber": null,  '+
    '              "WaiverProgramCode": null '+
    '            },  '+
     '            {  '+
                   '    "CaseNumber": "100060269",    '+
                   '    "IndividualId": "999034362",    '+
                   '    "IndividualName": "WEWRT GFG",    '+
                   '    "ProgramCode": "MA",    '+
                   '    "ProgramStatusCode": "PE",    '+
                   '    "BenefitBeginDate": null, '+
                   '    "BenefitEndDate": null,    '+
                   '    "RenewalDueDate": null,    '+
                   '    "ReviewDate": null,    '+
                   '    "DocumentDueDate": "2020-03-12",    '+
                   '    "ApplicationSubmissionDate": "2020-02-11",    '+
                   '    "DenialEffectiveDate": null,    '+
                   '    "DenialReason": null,    '+
                   '    "CurrentMonthPatientLiabilityAmount": null,    '+
                   '    "UpcomingMonthPatientLiabilityAmount": null,    '+
                   '    "IsWaiverLinkEnabled": null,    '+
                   '    "HasActiveSuspension": "N",    '+
                   '    "HasActivePenalty": "N",    '+
                   '    "PenaltyBeginDate": null,    '+
                   '    "PenaltyEndDate": null,    '+
                   '    "ReferredToFFM": "N",    '+
                   '    "PolicyHolderName": null,    '+
                   '    "InsuranceComanyName": null,    '+
                   '    "InsurancePlanName": null,    '+
                   '    "PolicyId": null,    '+
                   '    "IsPreferredPaymentAccessed": null,    '+
                   '    "AllotmentMonth1": null,    '+
                   '    "AllotmentAmountMonth1": null,    '+
                   '    "AllotmentMonth2": null,    '+
                   '    "AllotmentAmountMonth2": null,    '+
                   '    "AllotmentMonth3": null,    '+
                   '    "AllotmentAmountMonth3": null,    '+
                   '    "EBTCardFundLoadDate": null,    '+
                   '    "SNAPClaimAmount": null,    '+
                   '    "EdgNumber": null,    '+
                   '    "CopayMonth1": null,    '+
                   '    "CopayAmountMonth1": null,    '+
                   '    "CopayMonth2": null,    '+
                   '    "CopayAmountMonth2": null,    '+
                   '    "CopayMonth3": null,    '+
                   '    "CopayAmountMonth3": null,    '+
                   '    "CopayEffectiveDate": null,    '+
                   '    "ActiveEnrollmentCount": null,    '+
                   '    "PendingEnrollmentCount": null,    '+
                   '    "WaiverApplicationNumber": null,    '+
                   '    "WaiverProgramCode": null    '+
           '      }, '+
           '      {  '+
                   '    "CaseNumber": "100060269",    '+
                   '    "IndividualId": "999034362",    '+
                   '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                   '    "ProgramCode": "CC",    '+
                   '    "ProgramStatusCode": "PI",    '+
                   '    "BenefitBeginDate": null,    '+
                   '    "BenefitEndDate": null,    '+
                   '    "RenewalDueDate": null,    '+
                   '    "ReviewDate": null,    '+
                   '    "DocumentDueDate": "2020-05-11",    '+
                   '    "ApplicationSubmissionDate": "2020-02-11",    '+
                   '    "DenialEffectiveDate": null,    '+
                   '    "DenialReason": null,    '+
                   '    "CurrentMonthPatientLiabilityAmount": null,    '+
                   '    "UpcomingMonthPatientLiabilityAmount": null,    '+
                   '    "IsWaiverLinkEnabled": null,    '+
                   '    "HasActiveSuspension": "N",    '+
                   '    "HasActivePenalty": "N",    '+
                   '    "PenaltyBeginDate": null,    '+
                   '    "PenaltyEndDate": null,    '+
                   '    "ReferredToFFM": "N",    '+
                   '    "PolicyHolderName": null,    '+
                   '    "InsuranceComanyName": null,    '+
                   '    "InsurancePlanName": null,    '+
                   '    "PolicyId": null,    '+
                   '    "IsPreferredPaymentAccessed": null,    '+
                   '    "AllotmentMonth1": null,    '+
                   '    "AllotmentAmountMonth1": null,    '+
                   '    "AllotmentMonth2": null,    '+
                   '    "AllotmentAmountMonth2": null,    '+
                   '    "AllotmentMonth3": null,    '+
                   '    "AllotmentAmountMonth3": null,    '+
                   '    "EBTCardFundLoadDate": null,    '+
                   '    "SNAPClaimAmount": null,    '+
                   '    "EdgNumber": null,    '+
                   '    "CopayMonth1": null,    '+
                   '    "CopayAmountMonth1": null,    '+
                   '    "CopayMonth2": null,    '+
                   '    "CopayAmountMonth2": null,    '+
                   '    "CopayMonth3": null,    '+
                   '    "CopayAmountMonth3": null,    '+
                   '    "CopayEffectiveDate": null,    '+
                   '    "ActiveEnrollmentCount": null,    '+
                   '    "PendingEnrollmentCount": null,    '+
                   '    "WaiverApplicationNumber": null,    '+
                   '    "WaiverProgramCode": null    '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "123456",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "SS",    '+
                 '    "ProgramStatusCode": "PI"   '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "100060269",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "KP",    '+
                 '    "PolicyHolderId": "123456"    '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "100060200",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "SN",    '+
                 '    "PolicyHolderId": "123456"    '+
                 ' } ,'+
                 '  {  '+
                 '    "CaseNumber": "100060269",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "KI-HIPP",    '+
                 '    "PolicyHolderId": "123456",    '+
                 '    "ProgramStatusCode": "PI"   '+
                 ' } '+
               ' ],   '+
               '     "MedicardEBT"  : [      '+
               '    {  '+
                     '     "IndividualName" : "test indi",      '+
                     '     "IndividualId" : "123456",      '+
                     '     "CaseNumber" : "1002345",      '+
                     '     "ShowEBT" : true,      '+
                     '     "ShowMedicard" : true   '+
               '   }     '+
               '      ]      ';
            
        upsert lstContacts;
        
        
               
    }
    
     @isTest
    public static void test_doLoad(){        
       User citizen  = [SELECT Id FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        System.runAs(citizen){
            test.startTest();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        	sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'999034362');
           	String response = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            String responseActive = sessionpart.get('ActiveBenefits') != null ? String.valueOf(sessionpart.get('ActiveBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'));
            String responsePendingInterviewBenefits = sessionpart.get('PendingInterviewBenefits') != null ? String.valueOf(sessionpart.get('PendingInterviewBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits'));
            String responsePendingVerificationBenefits = sessionpart.get('PendingVerificationBenefits') != null ? String.valueOf(sessionpart.get('PendingVerificationBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits'));
            String responsecaseVsHOH =sessionpart.get('caseVsHOH') != null ? String.valueOf(sessionpart.get('caseVsHOH')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'));
            String responsecaseVsStatus = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            String responsecaseVsIndividualId = sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
            String responseauthRepAccessForNotices = sessionpart.get('authRepAccessForNotices') != null ? String.valueOf(sessionpart.get('authRepAccessForNotices')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'));
            String responseracEnabledFlag = sessionpart.get('racEnabledFlag') != null ? String.valueOf(sessionpart.get('racEnabledFlag')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'racEnabledFlag'));
           	 String responseonlyKihippHoh = sessionpart.get('onlyKihippHoh') != null ? String.valueOf(sessionpart.get('onlyKihippHoh')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'));
            
            
            test.stopTest();
        
        
    } 
    }
     @isTest
    public static void test_doLoad_1(){        
       User citizen  = [SELECT Id,contactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objcitizen = [SELECT Id,CacheDashboardData__c FROM contact WHERE id = :citizen.contactId LIMIT 1][0];
        
    	objcitizen.CacheDashboardData__c = '{"mapCaseVsStatus":{"100060269":"AP"},"mapCaseVsIndividualId":{"100060269":"999034362"},"mapCaseVsHOH":{"100060269":false},"lstRAC":["100072976"],"hasRACEnabled":false,"authRepAccessForNotices":{"100060269":["KT"]}}';
		update objcitizen;
        System.runAs(citizen){
            test.startTest();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        	sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'999034362');
           	String response = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            String responseActive = sessionpart.get('ActiveBenefits') != null ? String.valueOf(sessionpart.get('ActiveBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'));
            String responsePendingInterviewBenefits = sessionpart.get('PendingInterviewBenefits') != null ? String.valueOf(sessionpart.get('PendingInterviewBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits'));
            String responsePendingVerificationBenefits = sessionpart.get('PendingVerificationBenefits') != null ? String.valueOf(sessionpart.get('PendingVerificationBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits'));
            String responsecaseVsHOH =sessionpart.get('caseVsHOH') != null ? String.valueOf(sessionpart.get('caseVsHOH')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'));
            String responsecaseVsStatus = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            String responsecaseVsIndividualId = sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
            String responseauthRepAccessForNotices = sessionpart.get('authRepAccessForNotices') != null ? String.valueOf(sessionpart.get('authRepAccessForNotices')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'));
            String responseracEnabledFlag = sessionpart.get('racEnabledFlag') != null ? String.valueOf(sessionpart.get('racEnabledFlag')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'racEnabledFlag'));
           	 String responseonlyKihippHoh = sessionpart.get('onlyKihippHoh') != null ? String.valueOf(sessionpart.get('onlyKihippHoh')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'));
            
            
            test.stopTest();
        
        
    } 
    }
     @isTest
    public static void test_doLoad_Approved(){        
       User citizen  = [SELECT Id,contactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objcitizen = [SELECT Id,CacheDashboardData__c FROM contact WHERE id = :citizen.contactId LIMIT 1][0];
        
    	objcitizen.CacheBenefitProgramData__c  =
            
    '            [ '+
    '            {   '+
    '              "CaseNumber": "100060269",    '+
    '              "IndividualId": "999034362",  '+
    '              "IndividualName": "WEWRT GFG",    '+
    '              "ProgramCode": "KP",  '+
    '              "ProgramStatusCode": "AP",    '+
    '              "BenefitBeginDate": null, '+
    '              "BenefitEndDate": null,   '+
    '              "RenewalDueDate": null,   '+
    '              "ReviewDate": null,   '+
    '              "DocumentDueDate": "2020-02-21",  '+
    '              "ApplicationSubmissionDate": "2020-02-11",    '+
    '              "DenialEffectiveDate": null,  '+
    '              "DenialReason": null, '+
    '              "CurrentMonthPatientLiabilityAmount": null,   '+
    '              "UpcomingMonthPatientLiabilityAmount": null,  '+
    '              "IsWaiverLinkEnabled": null,  '+
    '              "HasActiveSuspension": "N",   '+
    '              "HasActivePenalty": "N",  '+
    '              "PenaltyBeginDate": null, '+
    '              "PenaltyEndDate": null,   '+
    '              "ReferredToFFM": null,    '+
    '              "PolicyHolderName": null, '+
    '              "InsuranceComanyName": null,  '+
    '              "InsurancePlanName": null,    '+
    '              "PolicyId": null, '+
    '              "IsPreferredPaymentAccessed": null,   '+
    '              "AllotmentMonth1": null,  '+
    '              "AllotmentAmountMonth1": null,    '+
    '              "AllotmentMonth2": null,  '+
    '              "AllotmentAmountMonth2": null,    '+
    '              "AllotmentMonth3": null,  '+
    '              "AllotmentAmountMonth3": null,    '+
    '              "EBTCardFundLoadDate": null,  '+
    '              "SNAPClaimAmount": null,  '+
    '              "EdgNumber": null,    '+
    '              "CopayMonth1": null,  '+
    '              "CopayAmountMonth1": null,    '+
    '              "CopayMonth2": null,  '+
    '              "CopayAmountMonth2": null,    '+
    '              "CopayMonth3": null,  '+
    '              "CopayAmountMonth3": null,    '+
    '              "CopayEffectiveDate": null,   '+
    '              "ActiveEnrollmentCount": null,    '+
    '              "PendingEnrollmentCount": null,   '+
    '              "WaiverApplicationNumber": null,  '+
    '              "WaiverProgramCode": null '+
    '            },  '+
     '            {  '+
                   '    "CaseNumber": "100060269",    '+
                   '    "IndividualId": "999034362",    '+
                   '    "IndividualName": "WEWRT GFG",    '+
                   '    "ProgramCode": "MA",    '+
                   '    "ProgramStatusCode": "AP",    '+
                   '    "BenefitBeginDate": null, '+
                   '    "BenefitEndDate": null,    '+
                   '    "RenewalDueDate": null,    '+
                   '    "ReviewDate": null,    '+
                   '    "DocumentDueDate": "2020-03-12",    '+
                   '    "ApplicationSubmissionDate": "2020-02-11",    '+
                   '    "DenialEffectiveDate": null,    '+
                   '    "DenialReason": null,    '+
                   '    "CurrentMonthPatientLiabilityAmount": null,    '+
                   '    "UpcomingMonthPatientLiabilityAmount": null,    '+
                   '    "IsWaiverLinkEnabled": null,    '+
                   '    "HasActiveSuspension": "N",    '+
                   '    "HasActivePenalty": "N",    '+
                   '    "PenaltyBeginDate": null,    '+
                   '    "PenaltyEndDate": null,    '+
                   '    "ReferredToFFM": "N",    '+
                   '    "PolicyHolderName": null,    '+
                   '    "InsuranceComanyName": null,    '+
                   '    "InsurancePlanName": null,    '+
                   '    "PolicyId": null,    '+
                   '    "IsPreferredPaymentAccessed": null,    '+
                   '    "AllotmentMonth1": null,    '+
                   '    "AllotmentAmountMonth1": null,    '+
                   '    "AllotmentMonth2": null,    '+
                   '    "AllotmentAmountMonth2": null,    '+
                   '    "AllotmentMonth3": null,    '+
                   '    "AllotmentAmountMonth3": null,    '+
                   '    "EBTCardFundLoadDate": null,    '+
                   '    "SNAPClaimAmount": null,    '+
                   '    "EdgNumber": null,    '+
                   '    "CopayMonth1": null,    '+
                   '    "CopayAmountMonth1": null,    '+
                   '    "CopayMonth2": null,    '+
                   '    "CopayAmountMonth2": null,    '+
                   '    "CopayMonth3": null,    '+
                   '    "CopayAmountMonth3": null,    '+
                   '    "CopayEffectiveDate": null,    '+
                   '    "ActiveEnrollmentCount": null,    '+
                   '    "PendingEnrollmentCount": null,    '+
                   '    "WaiverApplicationNumber": null,    '+
                   '    "WaiverProgramCode": null    '+
           '      }, '+
           '      {  '+
                   '    "CaseNumber": "100060269",    '+
                   '    "IndividualId": "999034362",    '+
                   '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                   '    "ProgramCode": "CC",    '+
                   '    "ProgramStatusCode": "AP",    '+
                   '    "BenefitBeginDate": null,    '+
                   '    "BenefitEndDate": null,    '+
                   '    "RenewalDueDate": null,    '+
                   '    "ReviewDate": null,    '+
                   '    "DocumentDueDate": "2020-05-11",    '+
                   '    "ApplicationSubmissionDate": "2020-02-11",    '+
                   '    "DenialEffectiveDate": null,    '+
                   '    "DenialReason": null,    '+
                   '    "CurrentMonthPatientLiabilityAmount": null,    '+
                   '    "UpcomingMonthPatientLiabilityAmount": null,    '+
                   '    "IsWaiverLinkEnabled": null,    '+
                   '    "HasActiveSuspension": "N",    '+
                   '    "HasActivePenalty": "N",    '+
                   '    "PenaltyBeginDate": null,    '+
                   '    "PenaltyEndDate": null,    '+
                   '    "ReferredToFFM": "N",    '+
                   '    "PolicyHolderName": null,    '+
                   '    "InsuranceComanyName": null,    '+
                   '    "InsurancePlanName": null,    '+
                   '    "PolicyId": null,    '+
                   '    "IsPreferredPaymentAccessed": null,    '+
                   '    "AllotmentMonth1": null,    '+
                   '    "AllotmentAmountMonth1": null,    '+
                   '    "AllotmentMonth2": null,    '+
                   '    "AllotmentAmountMonth2": null,    '+
                   '    "AllotmentMonth3": null,    '+
                   '    "AllotmentAmountMonth3": null,    '+
                   '    "EBTCardFundLoadDate": null,    '+
                   '    "SNAPClaimAmount": null,    '+
                   '    "EdgNumber": null,    '+
                   '    "CopayMonth1": null,    '+
                   '    "CopayAmountMonth1": null,    '+
                   '    "CopayMonth2": null,    '+
                   '    "CopayAmountMonth2": null,    '+
                   '    "CopayMonth3": null,    '+
                   '    "CopayAmountMonth3": null,    '+
                   '    "CopayEffectiveDate": null,    '+
                   '    "ActiveEnrollmentCount": null,    '+
                   '    "PendingEnrollmentCount": null,    '+
                   '    "WaiverApplicationNumber": null,    '+
                   '    "WaiverProgramCode": null    '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "123456",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "SS",    '+
                 '    "ProgramStatusCode": "AP"   '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "100060269",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "KP",    '+
             	 '    "ProgramStatusCode": "AP",    '+
                 '    "PolicyHolderId": "123456"    '+
                 ' }, '+
                 '  {  '+
                 '    "CaseNumber": "100060200",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "SN",    '+
                 '    "PolicyHolderId": "123456"    '+
                 ' } ,'+
                 '  {  '+
                 '    "CaseNumber": "100060269",    '+
                 '    "IndividualId": "999034363",    '+
                 '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                 '    "ProgramCode": "KI-HIPP",    '+
                 '    "PolicyHolderId": "123456",    '+
                 '    "ProgramStatusCode": "AP"   '+
                 ' } '+
               ' ],   '+
               '     "MedicardEBT"  : [      '+
               '    {  '+
                     '     "IndividualName" : "test indi",      '+
                     '     "IndividualId" : "123456",      '+
                     '     "CaseNumber" : "1002345",      '+
                     '     "ShowEBT" : true,      '+
                     '     "ShowMedicard" : true   '+
               '   }     '+
               '      ]      ';
            
		update objcitizen;
        System.runAs(citizen){
            test.startTest();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        	sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'999034362');
           	String response = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            String responseActive = sessionpart.get('ActiveBenefits') != null ? String.valueOf(sessionpart.get('ActiveBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'));
            String responsePendingInterviewBenefits = sessionpart.get('PendingInterviewBenefits') != null ? String.valueOf(sessionpart.get('PendingInterviewBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits'));
            String responsePendingVerificationBenefits = sessionpart.get('PendingVerificationBenefits') != null ? String.valueOf(sessionpart.get('PendingVerificationBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits'));
            String responsecaseVsHOH =sessionpart.get('caseVsHOH') != null ? String.valueOf(sessionpart.get('caseVsHOH')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'));
            String responsecaseVsStatus = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            String responsecaseVsIndividualId = sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
            String responseauthRepAccessForNotices = sessionpart.get('authRepAccessForNotices') != null ? String.valueOf(sessionpart.get('authRepAccessForNotices')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'));
            String responseracEnabledFlag = sessionpart.get('racEnabledFlag') != null ? String.valueOf(sessionpart.get('racEnabledFlag')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'racEnabledFlag'));
           	 String responseonlyKihippHoh = sessionpart.get('onlyKihippHoh') != null ? String.valueOf(sessionpart.get('onlyKihippHoh')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'));
             String responsemapCaseVsEligibilityRunDate = sessionpart.get('onlyKihippHoh') != null ? String.valueOf(sessionpart.get('mapCaseVsEligibilityRunDate')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'mapCaseVsEligibilityRunDate'));
             String responsehasKihippProgram = sessionpart.get('hasKihippProgram') != null ? String.valueOf(sessionpart.get('hasKihippProgram')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'));
            
            
            test.stopTest();
        
        
    } 
    }
       @isTest
    public static void test_doLoad_Negative(){        
       User citizen  = [SELECT Id,contactId FROM User WHERE UserName = 'citizen@abc.xyz' LIMIT 1][0];
        contact objcitizen = [SELECT Id,CacheDashboardData__c FROM contact WHERE id = :citizen.contactId LIMIT 1][0];
        
        objcitizen.CacheDashboardData__c = '{urirfhurieheiho}';
		update objcitizen;
        System.runAs(citizen){
            test.startTest();
             Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        	sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID,'999034362');
           	String response = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            String responseActive = sessionpart.get('ActiveBenefits') != null ? String.valueOf(sessionpart.get('ActiveBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'));
            String responsePendingInterviewBenefits = sessionpart.get('PendingInterviewBenefits') != null ? String.valueOf(sessionpart.get('PendingInterviewBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingInterviewBenefits'));
            String responsePendingVerificationBenefits = sessionpart.get('PendingVerificationBenefits') != null ? String.valueOf(sessionpart.get('PendingVerificationBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'PendingVerificationBenefits'));
            String responsecaseVsHOH =sessionpart.get('caseVsHOH') != null ? String.valueOf(sessionpart.get('caseVsHOH')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsHOH'));
            String responsecaseVsStatus = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            String responsecaseVsIndividualId = sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
            String responseauthRepAccessForNotices = sessionpart.get('authRepAccessForNotices') != null ? String.valueOf(sessionpart.get('authRepAccessForNotices')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'));
            String responseracEnabledFlag = sessionpart.get('racEnabledFlag') != null ? String.valueOf(sessionpart.get('racEnabledFlag')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'racEnabledFlag'));
           	 String responseonlyKihippHoh = sessionpart.get('onlyKihippHoh') != null ? String.valueOf(sessionpart.get('onlyKihippHoh')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'onlyKihippHoh'));
            
            
            test.stopTest();
        
        
    } 
    }
    
}