/*
* Classname     :  SSP_DashboardMockCalloutClass
* @description  :  This class is to mock the response for Dashboard
* @author       :  Karthik Gulla
* @date         :  08/03/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
public class SSP_DashboardMockCalloutClass implements HttpCalloutMock {   
    public String viewName;
    public static final String sMedicaidMCOInformation =      '   {  '  + 
    '   "viewName" : "MedicaidMCOInformation",      '+
    '     "caseNumber" : "100060269",      '+
    '     "primaryApplicantIndividualId" : "999034362",      '+
    '     "individualIds" : "999034362;999034363",      '+
    '     "programCode" : "MA;KT;SN",      '+
    '     "mode" : "Intake",      '+
    '     "applicationID" : "a0Xr0000000sp8T",      '+
    '     "miscelleanousParameter" : null,      '+
    '     "Payload"     : {      '+
      '     "Individual"  : [      '+
    '    {  '+
          '     "CaseNumber" : "100060269",      '+
          '     "IndividualId" : "999034362",      '+
          '     "IndividualName" : "WEWRT GFG",      '+
          '     "IsEnrolledInPlan" : "Y",      '+
          '     "IsEligibleToEnroll" : null,      '+
          '     "InEligibleDueToLTC" : null,      '+
          '     "InEligibleDueToIncarceration" : null,      '+
          '     "InEligibleDueToKIHIPP" : null,      '+
          '     "MCOBeginDate" : null      '+
    '   },      '+
    '   {      '+
          '     "CaseNumber" : "100060267",      '+
          '     "IndividualId" : "999034362",      '+
          '     "IndividualName" : "CXZCZXCAS ASZCZXC",      '+
          '     "IsEnrolledInPlan" : "N",      '+
          '     "IsEligibleToEnroll" : null,      '+
          '     "InEligibleDueToLTC" : null,      '+
          '     "InEligibleDueToIncarceration" : null,      '+
          '     "InEligibleDueToKIHIPP" : null,      '+
          '     "MCOBeginDate" : null      '+
    '    },      '+
    '   {      '+
    '     "CaseNumber" : "100060268",      '+
    '     "IndividualId" : "123456",      '+
    '     "IndividualName" : "CXZCZXCAS ASZCZXC",      '+
    '     "IsEnrolledInPlan" : "N",      '+
    '     "IsEligibleToEnroll" : null,      '+
    '     "InEligibleDueToLTC" : null,      '+
    '     "InEligibleDueToIncarceration" : null,      '+
    '     "InEligibleDueToKIHIPP" : null,      '+
    '     "MCOBeginDate" : null      '+
    '    },      '+
    '   {      '+
    '     "CaseNumber" : "100060266",      '+
    '     "IndividualId" : "123456",      '+
    '     "IndividualName" : "CXZCZXCAS ASZCZXC",      '+
    '     "IsEnrolledInPlan" : "Y",      '+
    '     "IsEligibleToEnroll" : null,      '+
    '     "InEligibleDueToLTC" : null,      '+
    '     "InEligibleDueToIncarceration" : null,      '+
    '     "InEligibleDueToKIHIPP" : null,      '+
    '     "MCOBeginDate" : null      '+
    '    }      '+
    '      ],      '+
    '     "MedicaidMCO"  : [      '+
    '    {  '+
          '     "CaseNumber" : "100060269",      '+
          '     "IndividualId" : "123456",      '+
          '     "IndividualName" : "WEWRT GFG",      '+
          '     "PlanId" : "123456",      '+
          '     "PlanName" : "ABCTEST",      '+
          '     "PlanStatus" : "Y",      '+
          '     "EnrollmentBeginDate" : null,      '+
          '     "EnrollmentEndDate" : null      '+
    '   },      '+
    '    {  '+
          '     "CaseNumber" : "100060269",      '+
          '     "IndividualId" : "999034362",      '+
          '     "IndividualName" : "WEWRT GFG",      '+
          '     "PlanId" : "123456",      '+
          '     "PlanName" : "ABCTEST",      '+
          '     "PlanStatus" : "Y",      '+
          '     "EnrollmentBeginDate" : null,      '+
          '     "EnrollmentEndDate" : null     '+
    '   }      '+
    '      ]      '+
    '    }      '+
    ' }      ';
    public static final String sBenfitInformation =           '   {  '  + 
    '         "viewName": "BenefitInformation",  '+
    '         "caseNumber": "100060269", '+
    '         "primaryApplicantIndividualId": "999034362",   '+
    '         "individualIds": "999034362;999034363",    '+
    '         "programCode": "MA;KT;SN", '+
    '         "mode": "Intake",  '+
    '         "applicationID": "a0Xr0000000sp8T",    '+
    '         "miscelleanousParameter": null,    '+
    '         "Payload": {   '+
    '           "Benefit": [ '+
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
                   '    "CaseNumber": "100060268",    '+
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
                   '    "CaseNumber": "100060267",    '+
                   '    "IndividualId": "999034363",    '+
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
               '      ]      '+
             ' }     '+
        '   }    ';  
   public HTTPResponse respond(HTTPRequest req) {
   		HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        String jsonData;
        
        if(String.isNotBlank(viewName) && viewName=='MedicaidMCOInformation'){
            jsonData=sMedicaidMCOInformation;
        }else if(String.isNotBlank(viewName) && viewName==SSP_InterfaceConstants.BENEFIT_INFORMATION){
            jsonData=sBenfitInformation;
        }
        else{
            jsonData='{"Payload":{"AgentAssisterAuthRep":[{"RoleType":"Assister","FullName":"Test Name","CaseNumber":"100375594"}],"Renewal":[{"CaseNumber":"100375594","RenewalProgramCode":"MA","RenewalDueDate":"2010-10-10"},{"CaseNumber":"100375596","RenewalProgramCode":"SN","RenewalDueDate":"2010-10-10"}],"DemographicDetails":[{"PreferredIndividual":"Y","IndividualId":"123456","BirthDate":"1992-12-02","GenderCode":"M","SuffixCode":null,"MiddleInitial":null,"LastName":"Kim","FirstName":"Katty"}],"CaseInfo":[{"MedicaidApplicationType":null,"ApplicationSourceType":"Test","IndividualId":"919221879","IsCaseInChangeMode":"N","CaseOwnership":"Test","IsTmember":"test","SNAPClaimAmount":null,"IsRACEnabled":"Y","IsInRenewalPeriod":"N","RFICount":0,"IsHeadOfHousehold":"Y","CaseStatusCode":"PE","CaseNumber":"100375594"},{"MedicaidApplicationType":null,"ApplicationSourceType":null,"IndividualId":"919221879","IsCaseInChangeMode":"N","CaseOwnership":null,"IsTmember":null,"SNAPClaimAmount":null,"IsRACEnabled":"N","IsInRenewalPeriod":"N","RFICount":1,"IsHeadOfHousehold":"N","CaseStatusCode":"PE","CaseNumber":"100375595"},{"MedicaidApplicationType":"Test","ApplicationSourceType":null,"IndividualId":"919221879","IsCaseInChangeMode":null,"CaseOwnership":null,"IsTmember":null,"SNAPClaimAmount":"1234","IsRACEnabled":"N","IsInRenewalPeriod":"Y","RFICount":0,"IsHeadOfHousehold":"Y","CaseStatusCode":"PE","CaseNumber":"100375596"}],"TimeStampDetails":[{"TimeStamp":"2020-07-01T15:01:53Z"}]},"role":"Citizen_Individual","miscelleanousParameter":"","applicationID":"","mode":"","programCode":"","individualIds":"","primaryApplicantIndividualId":"919221879","caseNumber":"0","viewName":"DashboardCaseInformation","dashboardCaseInfo":{"CaseInfo":[{"MedicaidApplicationType":null,"ApplicationSourceType":null,"IndividualId":"919221879","IsCaseInChangeMode":"N","CaseOwnership":null,"IsTmember":null,"SNAPClaimAmount":null,"IsRACEnabled":"Y","IsInRenewalPeriod":"N","RFICount":0,"IsHeadOfHousehold":"Y","CaseStatusCode":"PE","CaseNumber":"100375594"},{"MedicaidApplicationType":null,"ApplicationSourceType":null,"IndividualId":"919221879","IsCaseInChangeMode":"N","CaseOwnership":null,"IsTmember":null,"SNAPClaimAmount":null,"IsRACEnabled":"N","IsInRenewalPeriod":"N","RFICount":1,"IsHeadOfHousehold":"N","CaseStatusCode":"PE","CaseNumber":"100375594"},{"MedicaidApplicationType":null,"ApplicationSourceType":null,"IndividualId":"919221879","IsCaseInChangeMode":"N","CaseOwnership":null,"IsTmember":null,"SNAPClaimAmount":"1234","IsRACEnabled":"N","IsInRenewalPeriod":"Y","RFICount":0,"IsHeadOfHousehold":"Y","CaseStatusCode":"PE","CaseNumber":"100375594"}],"Renewal":[{"CaseNumber":"453423","RenewalProgramCode":"SS"}],"AgentAssisterAuthRep":null,"TimeStampDetails":[{"TimeStamp":"2020-07-01T15:01:53Z"}],"DemographicDetails":[{"FirstName":"Test FirstName","LastName":"Test LastName","MiddleInitial":"test","IndividualId":"12345"}]}}'; 
        }
       	response.setBody(jsonData);
        return response;
    }
}