/*
* classname     :  SSP_RSSPDC_IntegrationHandlerTest
* @description  :  Test class for SSP_RSSPDC_IntegrationHandler
* @author       :  Ragunathan
* @date         :  06/04/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Ragunathan                  06/04/2020                         Initial Creation
**/
@isTest
public class SSP_RSSPDC_IntegrationHandlerTest {

    @isTest
    private static void shouldPrepareRequestParams() {
        SSP_RSSPDC_RequestWrapper requestWrapper = new SSP_RSSPDC_RequestWrapper();
        requestWrapper.caseNumber                     = 123456;
        requestWrapper.mode                           = SSP_InterfaceConstants.MODE_RAC;
        requestWrapper.miscelleanousParameter         = '';
        requestWrapper.primaryApplicationIndividualId = '1234567';
        requestWrapper.individualIds                  = '999018553;1234567;2345678;3456789';
        
        Map<String, Object> mapParams = new Map<String, Object> {
            SSP_InterfaceConstants.JSON_BODY => requestWrapper,
                SSP_InterfaceConstants.SSP_SCREEN_NAMES => 'TestScreen'
        };
        SSP_RSSPDC_IntegrationHandler utility = new SSP_RSSPDC_IntegrationHandler();
        SSP_RSSPDCWrapper wrapper = utility.prepareRequestParams('TestInterface', mapParams);
        System.assertEquals('TestInterface', wrapper.sInterfaceName);
    }

    @isTest
    private static void shouldPerformOperationsOnResposne() {
        SSP_RSSPDCWrapper wrapper = new SSP_RSSPDCWrapper();
        SSP_RSSPDC_IntegrationHandler utility = new SSP_RSSPDC_IntegrationHandler();
        
        for(String view: responseForView.keySet()) {

            wrapper.objRequest.viewName = view;

            List<Object> testResponse = new List<Object>();
            RSSP_DC_Wrapper dcWrapper = new RSSP_DC_Wrapper();
            dcWrapper.viewName = view; 
            dcWrapper.Payload = responseForView;
            
            testResponse.add( dcWrapper );
            RSSP_DC_Wrapper  response = utility.performOperationsOnResposne(wrapper, testResponse);
            System.assertEquals('KHIPPPaymentSummary', response.viewName, 'Check for return response');
        }
    }
    
    static Map<String, Object> responseForView = new Map<String, Object> {
        'KHIPPPaymentSummary' =>    '    {      '+
                                    '        "Summary": [      '+
                                    '        {      '+
                                    '        "CaseNumber": "100062418",      '+
                                    '        "IndividualId": "920051584",      '+
                                    '        "KHIPPFinalPaymentId": "1000101797",      '+
                                    '        "IndividualName": "ABCONE",      '+
                                    '        "ReimbursedDate": "2019-06-06",      '+
                                    '        "ReimbursedMonth_Year": "Jun 2019",      '+
                                    '        "TotalAmount": "-100",      '+
                                    '        "TotalPremium": "341",      '+
                                    '        "Adjustment": "100"      '+
                                    '        }      '+
                                    '        ]      '+
                                    '        }      '/*
                                    //  '               }   '/*,
                                        
            'KHIPPPaymentSummary' =>    '       {      '+
                                        '        "Payload": {      '+
                                        '        "Summary": [      '+
                                        '        {      '+
                                        '        "CaseNumber": "100062418",      '+
                                        '        "IndividualId": "920051584",      '+
                                        '        "KHIPPFinalPaymentId": "1000101797",      '+
                                        '        "IndividualName": "ABCONE",      '+
                                        '        "ReimbursedDate": "2019-06-06",      '+
                                        '        "ReimbursedMonth_Year": "Jun 2019",      '+
                                        '        "TotalAmount": "-100",      '+
                                        '        "TotalPremium": "",      '+
                                        '        "Adjustment": "100"      '+
                                        '        }  '+
                                        '        ]  '+
                                        '        }  '+
                                        '        }  ',
            'BenefitInformation'  =>    '         "Payload": {   '+
                                               '           "Benefit": [ '+
                                               '            {   '+
                                               '              "CaseNumber": "100060269",    '+
                                               '              "IndividualId": "999034362",  '+
                                               '              "IndividualName": "WEWRT GFG",    '+
                                               '              "ProgramCode": "KT",  '+
                                               '              "ProgramStatusCode": "PI",    '+
                                               '              "BenefitBeginDate": "", '+
                                               '              "BenefitEndDate": "",   '+
                                               '              "RenewalDueDate": "",   '+
                                               '              "ReviewDate": "",   '+
                                               '              "DocumentDueDate": "2020-02-21",  '+
                                               '              "ApplicationSubmissionDate": "2020-02-11",    '+
                                               '              "DenialEffectiveDate": "",  '+
                                               '              "DenialReason": "", '+
                                               '              "CurrentMonthPatientLiabilityAmount": "",   '+
                                               '              "UpcomingMonthPatientLiabilityAmount": "",  '+
                                               '              "IsWaiverLinkEnabled": "",  '+
                                               '              "HasActiveSuspension": "N",   '+
                                               '              "HasActivePenalty": "N",  '+
                                               '              "PenaltyBeginDate": "", '+
                                               '              "PenaltyEndDate": "",   '+
                                               '              "ReferredToFFM": "",    '+
                                               '              "PolicyHolderName": "", '+
                                               '              "InsuranceComanyName": "",  '+
                                               '              "InsurancePlanName": "",    '+
                                               '              "PolicyId": "", '+
                                               '              "IsPreferredPaymentAccessed": "",   '+
                                               '              "AllotmentMonth1": "",  '+
                                               '              "AllotmentAmountMonth1": "",    '+
                                               '              "AllotmentMonth2": "",  '+
                                               '              "AllotmentAmountMonth2": "",    '+
                                               '              "AllotmentMonth3": "",  '+
                                               '              "AllotmentAmountMonth3": "",    '+
                                               '              "EBTCardFundLoadDate": "",  '+
                                               '              "SNAPClaimAmount": "",  '+
                                               '              "EdgNumber": "",    '+
                                               '              "CopayMonth1": "",  '+
                                               '              "CopayAmountMonth1": "",    '+
                                               '              "CopayMonth2": "",  '+
                                               '              "CopayAmountMonth2": "",    '+
                                               '              "CopayMonth3": "",  '+
                                               '              "CopayAmountMonth3": "",    '+
                                               '              "CopayEffectiveDate": "",   '+
                                               '              "ActiveEnrollmentCount": "",    '+
                                               '              "PendingEnrollmentCount": "",   '+
                                               '              "WaiverApplicationNumber": "",  '+
                                               '              "WaiverProgramCode": "" '+
                                               '            } ]  '+
                                               '            }   ',
                                               
            'MedicaidMCOInformation' =>        ' {    "Payload"     : {      '+
                                                      '     "Individual"  : [      '+
                                                    '    {  '+
                                                          '     "CaseNumber" : "100060269",      '+
                                                          '     "IndividualId" : "999034362",      '+
                                                          '     "IndividualName" : "WEWRT GFG",      '+
                                                          '     "IsEnrolledInPlan" : "N",      '+
                                                          '     "IsEligibleToEnroll" : "",      '+
                                                          '     "InEligibleDueToLTC" : "",      '+
                                                          '     "InEligibleDueToIncarceration" : "",      '+
                                                          '     "InEligibleDueToKIHIPP" : "",      '+
                                                          '     "MCOBeginDate" : ""      '+
                                                   '   } ] }     ',
            
            'DashboardCaseInformation'  =>      '        {   "Payload": {      '+
                                                '              "TimeStampDetails": {      '+
                                                '                "TimeStamp": "2020-01-23T07:12:51.957"      '+
                                                '              },      '+
                                                '              "Case": [      '+
                                                '                {      '+
                                                '                  "CaseNumber": "100059260",      '+
                                                '                  "IsHeadOfHousehold": "Y",      '+
                                                '                  "RFICount": "13",      '+
                                                '                  "IsInRenewalPeriod": "N",      '+
                                                '                  "IsRACEnabled": "Y",      '+
                                                '                  "SNAPClaimAmount": ""      '+
                                                '                }] } } ',
                                                
            'RACSelectionDetails'           =>  ' {   "Payload": {   '+
                                                '              "SSPMember": [      '+
                                                '                 {      '+
                                                '                    "IndividualId": "999034247",      '+
                                                '                    "FullName": "SFTESTUSER ALLSCENLFH",      '+
                                                '                    "BirthDate": "1984-12-09T00:00:00",      '+
                                                '                    "IsReceivingMedicareBenefitToggle": "N",      '+
                                                '                    "IsUSCitizenToggle": "N",      '+
                                                '                    "HasEmergencyMedicalConditionToggle": "N",      '+
                                                '                    "IsRecoveryFromIllnessOrInjuryToggle": "Y",      '+
                                                '                    "IsDisabledToggle": "N",      '+
                                                '                    "IsBlindToggle": "N",      '+
                                                '                    "IsPregnantInLastThreeMonthsToggle": "",      '+
                                                '                    "GenderCode": "M",      '+
                                                '                    "TemporarilyLivesElsewhereToggle": "N",      '+
                                                '                    "InHomeCareType": "MFP",      '+
                                                '                    "IsEnrolledInSchool": "Y"      '+
                                                '                 } ] } }',
                                                
            SSP_InterfaceConstants.RFI_DETAILS  =>          ' {   "Payload": {   '+
                                                '              "SampleResponse": [      '+
                                                '                 {      '+
                                                '                 } ] } }',
                                                
            SSP_InterfaceConstants.DISQUALIFICATION_DETAILS =>              ' {   "Payload": {  
                                            } }',
                                                
            SSP_InterfaceConstants.PAST_APPLICATIONS =>             ' {   "Payload": {   '+
                                                '              "SampleResponse": [      '+
                                                '                 {      ' +
                                                '                 } ] } }'  */                              
                                                
            
        };
                                        
}