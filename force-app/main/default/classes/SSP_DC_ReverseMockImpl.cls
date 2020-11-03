/*
 * Classname                        :  SSP_ContactInfoUpdateRequestWrapper
 * @description                     :  Mock Response method for Reverse SSPDC and test class
 * @author                          :  Rajeev Kumar
 * @date                            :  12/09/2019
 * MODIFICATION LOG                 :
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public  with sharing class SSP_DC_ReverseMockImpl implements HttpCalloutMock {
    /**
     * method       : respond
     * @description     : Mock method to generate response
     * @author      : Rajeev Kumar
     * @param req : HttpRequest for hitting the service
     */    
    public HTTPResponse respond(HTTPRequest req) {
        if(boolIsCalloutException) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }  
      httpResponse response = new HttpResponse();
        response.setStatusCode(200);
        Map<String, Object> reqBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        String sViewName = String.valueOf(reqBody.get(SSP_InterfaceConstants.VIEW_NAME));
        Map<String, String> viewResponse = new Map<String, String> {
                SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL             => sQualifiedIndividual,
                SSP_InterfaceConstants.MEMBER_INFORMATION               => sMemberInformation,
                SSP_InterfaceConstants.ABSENT_PARENT_INFORMATION        => sAbsentParentInformation,
                SSP_InterfaceConstants.EXPENSE_INFORMATION              => sExpenseInformation,
                SSP_InterfaceConstants.HEALTH_COVERAGE_INFORMATION      => sHealthCoverageInformation,
                SSP_InterfaceConstants.HEALTH_INFORMATION               => sHealthInformation,
                SSP_InterfaceConstants.HOUSEHOLD_OTHER_INFORMATION      => sHouseHoldOtherInformation,
                SSP_InterfaceConstants.RELATIONSHIP_INFORMATION         => sRelationshipInformation,
                SSP_InterfaceConstants.RESOURCE_INFORMATION             => sResourceInformation,
                SSP_InterfaceConstants.INCOME_INFORMATION               => sIncomeInformation,
                SSP_InterfaceConstants.MY_INFORMATION                   => sMyInformation,
                SSP_InterfaceConstants.ELIGIBILITY_SUMMARY              => sEligibilitySummary,
                SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY            => sKHIPPPaymentSummary,
                SSP_InterfaceConstants.BENEFIT_INFORMATION              => sBenfitInformation,
                SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION         => sMedicaidMCOInformation,
                SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION       => sDashboardCaseInformation,
                SSP_InterfaceConstants.SSP_RAC_SELECTION                => sRACSelectionDetails,
                SSP_InterfaceConstants.RFI_DETAILS                      => sRFIInformation,
                SSP_InterfaceConstants.NON_CITIZEN_CLIENT_INFORMATION   => sNonCitizenClientInfo,
                SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE          => sNonCitizenSearchCase,
                SSP_InterfaceConstants.NON_CITIZEN_SEARCH_EXPORT        => sNonCitizenSearchExport,
                SSP_InterfaceConstants.NOTIFICATION_INFORMATION         => sNotificationInformation,
                SSP_InterfaceConstants.ASSISTER_AUTHREP_CLIENT_DETAILS  => sAssisterAuthRepClientDetails,
                SSP_InterfaceConstants.WAIVER_DETAILS       		        => sWaiverDetails,
                SSP_InterfaceConstants.CLAIMS_OVERVIEW       		        => sClaimsOverview,
                SSP_InterfaceConstants.RAC_SELECTION_DETAILS            => sRACSelectionDetails,
                SSP_InterfaceConstants.TAX_FORMS_1095A_INFORMATION      => sTaxForms1095AInformation,
                SSP_InterfaceConstants.PAST_APPLICATIONS                => sPastApplications,
                SSP_InterfaceConstants.KIHIPP_PREFERRED_PAYMENT         => sKIHIPPpreferredPayment,
                SSP_InterfaceConstants.HEARINGS_SUMMARY_INFORMATION     => sHearingSummaryInformation,
                SSP_InterfaceConstants.ONBOARD_INDV_AUTHREP             => sOnboardIndvAuthRep
                };
        response.setBody( viewResponse.get(sViewName) );
        return Response;
    }

    public Boolean boolIsCalloutException = false;
    public SSP_DC_ReverseMockImpl(Boolean boolIsCalloutException) {
      this.boolIsCalloutException = boolIsCalloutException;
    }
    public SSP_DC_ReverseMockImpl() {
      // Default Constructor
    }
    // SObject Structure
    public static final String sQualifiedIndividual =         '   {  '  + 
                                        '     "viewName": "QualifiedIndividual",  '  + 
                                        '     "caseNumber": "0",  '  + 
                                        '     "primaryApplicantIndividualId": 999034247,  '  + 
                                        '     "individualIds": "",  '  + 
                                        '     "programCode": "MA;KT;SN",  '  + 
                                        '     "mode": "Intake",  '  + 
                                        '     "applicationID": "a0Xr00000010rli",  '  + 
                                        '     "miscelleanousParameter": "",  '  + 
                                        '     "Payload": {  '  + 
                                        '       "SSP_Application__c": null,  '  + 
                                        '       "SSP_ApplicationIndividual__c": [  '  + 
                                        '         {  '  + 
                                        '           "IsActiveIEESCasePresent__c": 1,  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "BlockedCaseNumber__c": "100061299",  '  + 
                                        '           "isApplicationBlocked__c": 1,  '  + 
                                        '           "IsHeadOfHousehold__c": 1  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IsActiveIEESCasePresent__c": 1,  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "BlockedCaseNumber__c": "100061299",  '  + 
                                        '           "isApplicationBlocked__c": 1,  '  + 
                                        '           "IsHeadOfHousehold__c": 0  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IsActiveIEESCasePresent__c": 1,  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "BlockedCaseNumber__c": "100061299",  '  + 
                                        '           "isApplicationBlocked__c": 1,  '  + 
                                        '           "IsHeadOfHousehold__c": 0  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IsActiveIEESCasePresent__c": 1,  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034250"  '  + 
                                        '           },  '  + 
                                        '           "BlockedCaseNumber__c": "100061299",  '  + 
                                        '           "isApplicationBlocked__c": 1,  '  + 
                                        '           "IsHeadOfHousehold__c": 0  '  + 
                                        '         }  '  + 
                                        '       ],  '  + 
                                        '       "SSP_Member__c": [  '  + 
                                        '         {  '  + 
                                        '           "FirstName__c": "CHILDLKDFJ",  '  + 
                                        '           "LastName__c": "LKDFK",  '  + 
                                        '           "BirthDate__c": "2019-01-10",  '  + 
                                        '           "MiddleInitial__c": null,  '  + 
                                        '           "SuffixCode__c": null,  '  + 
                                        '           "EthnicityCode__c": null,  '  + 
                                        '           "SSN__c": null,  '  + 
                                        '           "DeathDate__c": null,  '  + 
                                        '           "GenderCode__c": "F",  '  + 
                                        '           "NoReasonSSNCode__c": "AP",  '  + 
                                        '           "IndividualId__c": "999034250",  '  + 
                                        '           "MCIId__c": "9831606",  '  + 
                                        '           "SSNVerified__c": 0,  '  + 
                                        '           "NationalityCode__c": null,  '  + 
                                        '           "IsDateOfBirthValidated__c": 0,  '  + 
                                        '           "IsDateOfDeathValidated__c": 0,  '  + 
                                        '           "PseudoSSN__c": "908883978",  '  + 
                                        '           "IsUSCitizenValidated__c": 0,  '  + 
                                        '           "RaceCode__c": null,  '  + 
                                        '           "IsUSCitizenToggle__c": "N",  '  + 
                                        '           "IsFileCleared__c": 1  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "FirstName__c": "SDONELDKJ",  '  + 
                                        '           "LastName__c": "ISECODLKFJK",  '  + 
                                        '           "BirthDate__c": "1987-01-17",  '  + 
                                        '           "MiddleInitial__c": null,  '  + 
                                        '           "SuffixCode__c": null,  '  + 
                                        '           "EthnicityCode__c": null,  '  + 
                                        '           "SSN__c": null,  '  + 
                                        '           "DeathDate__c": null,  '  + 
                                        '           "GenderCode__c": "M",  '  + 
                                        '           "NoReasonSSNCode__c": "AL",  '  + 
                                        '           "IndividualId__c": "999034248",  '  + 
                                        '           "MCIId__c": "9831596",  '  + 
                                        '           "SSNVerified__c": 0,  '  + 
                                        '           "NationalityCode__c": "AI",  '  + 
                                        '           "IsDateOfBirthValidated__c": 0,  '  + 
                                        '           "IsDateOfDeathValidated__c": 0,  '  + 
                                        '           "PseudoSSN__c": "908813352",  '  + 
                                        '           "IsUSCitizenValidated__c": 0,  '  + 
                                        '           "RaceCode__c": "AS",  '  + 
                                        '           "IsUSCitizenToggle__c": "N",  '  + 
                                        '           "IsFileCleared__c": 1  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "FirstName__c": "SFTESTUSER",  '  + 
                                        '           "LastName__c": "ALLSCENLFH",  '  + 
                                        '           "BirthDate__c": "1984-12-09",  '  + 
                                        '           "MiddleInitial__c": null,  '  + 
                                        '           "SuffixCode__c": null,  '  + 
                                        '           "EthnicityCode__c": null,  '  + 
                                        '           "SSN__c": null,  '  + 
                                        '           "DeathDate__c": null,  '  + 
                                        '           "GenderCode__c": "M",  '  + 
                                        '           "NoReasonSSNCode__c": "AP",  '  + 
                                        '           "IndividualId__c": "999034247",  '  + 
                                        '           "MCIId__c": "9831594",  '  + 
                                        '           "SSNVerified__c": 0,  '  + 
                                        '           "NationalityCode__c": null,  '  + 
                                        '           "IsDateOfBirthValidated__c": 0,  '  + 
                                        '           "IsDateOfDeathValidated__c": 0,  '  + 
                                        '           "PseudoSSN__c": "908475128",  '  + 
                                        '           "IsUSCitizenValidated__c": 0,  '  + 
                                        '           "RaceCode__c": "IN",  '  + 
                                        '           "IsUSCitizenToggle__c": "N",  '  + 
                                        '           "IsFileCleared__c": 1  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "FirstName__c": "TLIYDFKJ",  '  + 
                                        '           "LastName__c": "LKDHFNVGTR",  '  + 
                                        '           "BirthDate__c": "1987-12-02",  '  + 
                                        '           "MiddleInitial__c": null,  '  + 
                                        '           "SuffixCode__c": null,  '  + 
                                        '           "EthnicityCode__c": "CU",  '  + 
                                        '           "SSN__c": null,  '  + 
                                        '           "DeathDate__c": null,  '  + 
                                        '           "GenderCode__c": "F",  '  + 
                                        '           "NoReasonSSNCode__c": "AP",  '  + 
                                        '           "IndividualId__c": "999034249",  '  + 
                                        '           "MCIId__c": "9831598",  '  + 
                                        '           "SSNVerified__c": 0,  '  + 
                                        '           "NationalityCode__c": "GU",  '  + 
                                        '           "IsDateOfBirthValidated__c": 0,  '  + 
                                        '           "IsDateOfDeathValidated__c": 0,  '  + 
                                        '           "PseudoSSN__c": "908308845",  '  + 
                                        '           "IsUSCitizenValidated__c": 0,  '  + 
                                        '           "RaceCode__c": "HPI",  '  + 
                                        '           "IsUSCitizenToggle__c": "Y",  '  + 
                                        '           "IsFileCleared__c": 1  '  + 
                                        '         }  '  + 
                                        '       ]  '  + 
                                        '     },  '  + 
                                        '     "AckResponse": null  '  + 
                                        '  }  ' ; 
    public static final String sIncomeInformation =           '   {  '  +
                                    '            "viewName": "IncomeInformation",      '+
                                    '            "caseNumber": "0",      '+
                                    '            "primaryApplicantIndividualId": "999034247",      '+
                                    '            "individualIds": "999034247;999034248;999034249;999034250",      '+
                                    '            "programCode": "MA;KT;SN",      '+
                                    '            "mode": "Intake",      '+
                                    '            "applicationID": "a0Xr00000010rli",      '+
                                    '            "miscelleanousParameter": null,      '+
                                    '            "Payload": {      '+
                                    '              "SSP_Member__c": [      '+
                                    '                {      '+
                                    '                  "IndividualId__c": "999034247",      '+
                                    '                  "HasEarnedIncomeFromEmploymentToggle__c": "Y",      '+
                                    '                  "HasSelfEmploymentIncomeToggle__c": "N",      '+
                                    '                  "HasDividendsRoyaltiesToggle__c": "Y",      '+
                                    '                  "HasServicesorPaymentsToggle__c": "N",      '+
                                    '                  "HasInsuranceSettlementBenefitToggle__c": "N",      '+
                                    '                  "HasMaintenanceIncomeToggle__c": "N",      '+
                                    '                  "HasUnearnedIncomeToggle__c": "N",      '+
                                    '                  "HasUnpaidEmploymentToggle__c": "N",      '+
                                    '                  "HasReceivedBenefitsFromOtherStateToggle__c": "Y"      '+
                                    '                }      '+
                                    '              ],      '+
                                    '              "SSP_Asset__c": [      '+
                                    '                {      '+
                                    '                  "RecordType": {      '+
                                    '        Name : "Income"      '+
                                    '          },      '+
                                    '          "SSP_Member__r": {      '+
                                    '          "IndividualId__c" : "999034247"      '+
                                    '          },      '+
                                    '                  "DCEmploymentDetailId__c": "29306",      '+
                                    '                  "DCId__c": "212558",      '+
                                    '                  "DCSelfEmploymentIncomeDetailId__c": 568587,      '+
                                    '                  "DCUnearnedIncomeDetailId__c": 5647334,      '+
                                    '                  "IncomeTypeCode__c": "DIR",      '+
                                    '                  "IncomeSubtypeCode__c": "IN",      '+
                                    '                  "EmployerName__c": "delook",      '+
                                    '                  "EIN__c": 76556,      '+
                                    '                  "EmployerAddress__c": "KLDFD",      '+
                                    '                  "EmployerAddressLine2__c": "DLFKJ",      '+
                                    '                  "PrimaryPhoneNumber__c": 987654321,      '+
                                    '                  "PrimaryPhoneExtension__c": "91",      '+
                                    '                  "BusinessTypeCode__c": "SF",      '+
                                    '                  "BusinessTitle__c": "Consultant",      '+
                                    '                  "ActivityType__c": "ST",      '+
                                    '                  "ActivityStartDate__c": "2019-10-01",      '+
                                    '                  "IsSchoolDegreeRequiredToggle__c": "N",      '+
                                    '                  "IsUnempBenefitsRequiredToggle__c": "Y",      '+
                                    '                  "IncomePayFrequency__c": "MO",      '+
                                    '                  "TotalGrossAmount__c": "844.00",      '+
                                    '                  "Tips__c": "4.00",      '+
                                    '                  "IncomePayDetailHoursPerWeek__c": "40",      '+
                                    '                  "ExpenseAmount__c": 789.45,      '+
                                    '                  "EndDate__c": "2020-10-01",      '+
                                    '                  "DCAssetId__c": "Income,212558"      '+
                                    '                }      '+
                                    '              ],      '+
                                    '              "SSP_Benefits__c": [      '+
                                    '                {      '+
                                    '                  "RecordType": {      '+
                                    '        Name : "OutOfStateBenefit"      '+
                                    '        },      '+
                                    '                  "SSP_Member__r": {      '+
                                    '          "IndividualId__c" : "999034247"      '+
                                    '          },      '+
                                    '                  "DCOutOfStateBenefitId__c": "772",      '+
                                    '                  "State__c": "HI",      '+
                                    '                  "BenefitInfoCounty__c": "Canada",      '+
                                    '                  "BenefitPrograms__c": "SN",      '+
                                    '                  "BeginDate__c": "2019-10-01",      '+
                                    '                  "EndDate__c": "2020-10-01"      '+
                                    '                }      '+
                                    '              ],      '+
                                    '          "SSP_Application__c": [ {      '+
                                    '                "RecordType": {      '+
                                    '        Name: "Case"       '+
                                    '        },      '+
                                    '                "DCCaseNumber__c": "100059260",      '+
                                    '                "IsReceivingHousingAssistanceToggle__c": "Y"      '+
                                    '              }   ]   '+
                                    '            }      '+
                                    '        }      ' ; 
    public static final String sExpenseInformation =          '   {  '  +
                                    '            "viewName": "ExpenseInformation",      '+
                                    '            "caseNumber": "0",      '+
                                    '            "primaryApplicantIndividualId": "999034247",      '+
                                    '            "individualIds": "999034247;999034248;999034249;999034250",      '+
                                    '            "programCode": "MA;KT;SN",      '+
                                    '            "mode": "Intake",      '+
                                    '            "applicationID": "a0Xr00000010rli",      '+
                                    '            "miscelleanousParameter": null,      '+
                                    '            "Payload": {      '+
                                    '              "SSP_Asset__c": [      '+
                                    '                {      '+
                                    '                  "RecordType": {      '+
                                    '        Name : "Expense"      '+
                                    '          },      '+
                                    '          "SSP_Member__r": {      '+
                                    '          "IndividualId__c" : "999034249"      '+
                                    '          },      '+
                                    '                  "DCId__c": "14693",      '+
                                    '                  "ExpenseTypeCode__c": "SE",      '+
                                    '                  "ExpenseSubType__c": "RNT",      '+
                                    '                  "ExpenseFrequencyCode__c": "SM",      '+
                                    '                  "ExpenseAmount__c": "4",      '+
                                    '                  "IsNonHouseHoldMemberPayingExpenseToggle__c": "Y",      '+
                                    '                  "IsPaidToVendorToggle__c": "N",      '+
                                    '                  "StartDate__c": "2019-01-02",      '+
                                    '                  "EndDate__c": "2019-01-02",      '+
                                    '                  "TuitionAmount__c": 56.56,      '+
                                    '                  "BooksAmount__c": 456.89,      '+
                                    '                  "FeesAmount__c": 678.67,      '+
                                    '                  "MiscellaneousAmount__c": 788.87,      '+
                                    '                  "ChildName__c": "Some cute Name",      '+
                                    '                  "DependentCareProvider__r": {      '+
                                    '        IndividualId__c : "999034247"      '+
                                    '          },      '+
                                    '                  "DependentIndividual__r": {      '+
                                    '        IndividualId__c : "999034247"      '+
                                    '          },      '+
                                    '                  "DCAssetId__c": "Expense,14693"      '+
                                    '                }      '+
                                    '              ],      '+
                                    '              "SSP_Member__c": [      '+
                                    '                {      '+
                                    '                  "IndividualId__c": "999034247",      '+
                                    '                  "HasMedicalBillsToggle__c": "Y",      '+
                                    '                  "HasShelterExpenseToggle__c": "N",      '+
                                    '                  "HasUtilityExpenseToggle__c": "N",      '+
                                    '                  "HaveHigherEducationExpenseToggle__c": "N",      '+
                                    '                  "HasTaxDeductionsExpenseToggle__c": "Y",      '+
                                    '                  "HasAlimonyExpenseToggle__c": "N",      '+
                                    '                  "HasMedicalExpensePartDToggle__c": "Y",      '+
                                    '                  "HasDisabledExpensesToggle__c": "Y",      '+
                                    '                  "HasHouseholdPaidChildSupportToggle__c": "Y",      '+
                                    '                  "HasDependentCareExpenseToggle__c": "N",      '+
                                    '                  "IsCoverageMonth1__c": 0,      '+
                                    '                  "IsCoverageMonth2__c": 0,      '+
                                    '                  "IsCoverageMonth3__c": 0      '+
                                    '                },      '+
                                    '                {      '+
                                    '                  "IndividualId__c": "999034248",      '+
                                    '                  "HasMedicalBillsToggle__c": "N",      '+
                                    '                  "HasShelterExpenseToggle__c": "N",      '+
                                    '                  "HasUtilityExpenseToggle__c": "N",      '+
                                    '                  "HaveHigherEducationExpenseToggle__c": "N",      '+
                                    '                  "HasTaxDeductionsExpenseToggle__c": "N",      '+
                                    '                  "HasAlimonyExpenseToggle__c": "N",      '+
                                    '                  "HasMedicalExpensePartDToggle__c": "Y",      '+
                                    '                  "HasDisabledExpensesToggle__c": "Y",      '+
                                    '                  "HasHouseholdPaidChildSupportToggle__c": "Y",      '+
                                    '                  "HasDependentCareExpenseToggle__c": "Y",      '+
                                    '                  "IsCoverageMonth1__c": 0,      '+
                                    '                  "IsCoverageMonth2__c": 0,      '+
                                    '                  "IsCoverageMonth3__c": 0      '+
                                    '                }      '+
                                    '              ]      '+
                                    '            }      '+
                                    '        }      '; 
    public static final String sAbsentParentInformation =     '   {  '  + 
                                        '       "viewName": "AbsentParentInformation",  '  + 
                                        '       "primaryApplicantIndividualId": "999033790",  '  + 
                                        '       "individualIds": "999033790;999033791",  '  + 
                                        '       "programCode": "MA",  '  + 
                                        '       "mode": "Intake",  '  + 
                                        '       "Payload": {  '  + 
                                        '         "SSP_NonCustodialRelationship__c": [  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '        "IndividualId__c": "999033790",  '+
                                        '           }   '  + 
                                        '             "SSP_NonCustodialParent__r": {    '+
                                        '           "DCNonCustodialParentId__c" : "14489",      '+
                                        '           }'  + 
                                        '             "DCNonCustodialRelationshipId__c": "5605"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033790",  '+
                                        '               }   '  + 
                                        '             "SSP_NonCustodialParent__r": {    '+
                                        '               "DCNonCustodialParentId__c" : "14488",      '+
                                        '               }'  + 
                                        '             "DCNonCustodialRelationshipId__c": "5606"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "SSP_NonCustodialParent__r": {    '+
                                        '               "DCNonCustodialParentId__c" : "14491",      '+
                                        '               }'  + 
                                        '             "DCNonCustodialRelationshipId__c": "5622"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "SSP_NonCustodialParent__r": {    '+
                                        '               "DCNonCustodialParentId__c" : "14490",      '+
                                        '               }'  + 
                                        '             "DCNonCustodialRelationshipId__c": "5623"  '  + 
                                        '           }  '  + 
                                        '         ],  '  + 
                                        '         "SSP_NonCustodialParent__c": [  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033790",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "TFKN",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "DYFHN",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": null,  '  + 
                                        '             "GenderCode__c": "M",  '  + 
                                        '             "SSN__c": " ",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14489",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033790",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "JPLWSA",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "BUECYF",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": null,  '  + 
                                        '             "GenderCode__c": "F",  '  + 
                                        '             "SSN__c": " ",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14488",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "KRFNNNR",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "RYCTS",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": "1983-11-03",  '  + 
                                        '             "GenderCode__c": "M",  '  + 
                                        '             "SSN__c": "075405691",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14491",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "KRFNNNR",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "RYCTS",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": "1983-11-03",  '  + 
                                        '             "GenderCode__c": "M",  '  + 
                                        '             "SSN__c": "075405691",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14491",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "JPLWSA",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "BUECYF",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": "1987-01-15",  '  + 
                                        '             "GenderCode__c": "F",  '  + 
                                        '             "SSN__c": "074485835",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14490",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "SSP_Member__c":{  '+
                                        '               "IndividualId__c": "999033791",  '+
                                        '               }   '  + 
                                        '             "FirstName__c": "JPLWSA",  '  + 
                                        '             "MiddleInitial__c": " ",  '  + 
                                        '             "LastName__c": "BUECYF",  '  + 
                                        '             "SuffixCode__c": null,  '  + 
                                        '             "DateOfBirth__c": "1987-01-15",  '  + 
                                        '             "GenderCode__c": "F",  '  + 
                                        '             "SSN__c": "074485835",  '  + 
                                        '             "IsParentUnknown__c": "N",  '  + 
                                        '             "HasChildSupport__c": "Y",  '  + 
                                        '             "GoodCauseCode__c": null,  '  + 
                                        '             "DCNonCustodialParentId__c": "14490",  '  + 
                                        '             "AbsentParentVerificationCode__c": "0"  '  + 
                                        '           }  '  + 
                                        '         ]  '  + 
                                        '       }  '  + 
                                        '  }  ' ; 
    public static final String sHealthCoverageInformation =   '   {  '  + 
                                            '     "viewName": "HealthCoverageInformation",  '  + 
                                            '     "caseNumber": "0",  '  + 
                                            '     "primaryApplicantIndividualId": 999034247,  '  + 
                                            '     "individualIds": "999034247;999034248;999034249;999034250",  '  + 
                                            '     "programCode": "MA;KT;SN",  '  + 
                                            '     "mode": "Intake",  '  + 
                                            '     "applicationID": "a0Xr00000010rli",  '  + 
                                            '     "miscelleanousParameter": "",  '  + 
                                            '     "Payload": {  '  + 
                                            '       "SSP_InsurancePolicy__c": [  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "5662",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "29309",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "5663",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "EM",  '  + 
                                            '           "InsuranceCompanyName__c": "HIP",  '  + 
                                            '           "PhysicalAddressLine1__c": "DLKFJDFKL",  '  + 
                                            '           "PhysicalCity__c": "KDFJ",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "45454",  '  + 
                                            '           "PhysicalAddressLine2__c": "DFKJLDF",  '  + 
                                            '           "PlanName__c": "extIPNdlfjk",  '  + 
                                            '           "InsurancePolicyNumber__c": "EPIDi4tt          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "EXTGID4i          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-16",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMOD",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "29308",  '  + 
                                            '           "EmployerName__c": "yahoo"  '  + 
                                            '         }  '  + 
                                            '       ],  '  + 
                                            '       "SSP_InsuranceCoveredIndiv__c": [  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": null,  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5663"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": null,  '  + 
                                            '           "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '           "DCId__c": 114,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": null,  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": null,  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance External Policy Holder"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5663,114,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": null,  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5613"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": {  '  + 
                                            '             "IndividualId__c": "999034247"  '  + 
                                            '           },  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": "34567",  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "Y",  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": "4",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5663,999034247,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": null,  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5663"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": {  '  + 
                                            '             "IndividualId__c": "999034248"  '  + 
                                            '           },  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": "8754",  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "N",  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": "3",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5663,999034248,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": "999034247",  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5662"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": null,  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": 8,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "Y",  '  + 
                                            '           "Gender__c": "F",  '  + 
                                            '           "DateOfBirth__c": "1987-12-12",  '  + 
                                            '           "FirstName__c": "SECOND",  '  + 
                                            '           "LastName__c": "MEMBER",  '  + 
                                            '           "MedicaidId__c": "5676767676",  '  + 
                                            '           "RelationshipCode__c": "5",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance External Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5662,0,8"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": "999034247",  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5612"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": null,  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": 9,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "Y",  '  + 
                                            '           "Gender__c": "M",  '  + 
                                            '           "DateOfBirth__c": "2014-01-01",  '  + 
                                            '           "FirstName__c": "FIRSTNAME",  '  + 
                                            '           "LastName__c": "FDKLFJ",  '  + 
                                            '           "MedicaidId__c": "3453454545",  '  + 
                                            '           "RelationshipCode__c": "5",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance External Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5662,0,9"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": "999034247",  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5332"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": {  '  + 
                                            '             "IndividualId__c": "999034247"  '  + 
                                            '           },  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": null,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "Y",  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": "1",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5662,999034247,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": "999034247",  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "7890"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": {  '  + 
                                            '             "IndividualId__c": "999034248"  '  + 
                                            '           },  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": null,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "N",  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": "2",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5662,999034248,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": "999034247",  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "4569"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": {  '  + 
                                            '             "IndividualId__c": "999034249"  '  + 
                                            '           },  '  + 
                                            '           "ExtPolicyHolderFirstName__c": null,  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": null,  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": null,  '  + 
                                            '           "DCId__c": null,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": "N",  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": "6",  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5662,999034249,0"  '  + 
                                            '         }  '  + 
                                            '       ],  '  + 
                                            '       "SSP_Member__c": null,  '  + 
                                            '       "SSP_HealthInsuranceFacilityType__c": [  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "8",  '  + 
                                            '           "FacilityType__c": "VA",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "9",  '  + 
                                            '           "FacilityType__c": "NH",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-03",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "10",  '  + 
                                            '           "FacilityType__c": "UK",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7014",  '  + 
                                            '           "FacilityType__c": "MS",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7015",  '  + 
                                            '           "FacilityType__c": "MD",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-04",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7016",  '  + 
                                            '           "FacilityType__c": "VS",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7017",  '  + 
                                            '           "FacilityType__c": "MD",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7018",  '  + 
                                            '           "FacilityType__c": "VS",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7019",  '  + 
                                            '           "FacilityType__c": "NH",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "7020",  '  + 
                                            '           "FacilityType__c": "MD",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5662,999034249,0"}  '  + 
                                            '         }  '  + 
                                            '       ]  '  + 
                                            '     },  '  + 
                                            '     "AckResponse": null  '  + 
                                            '  }  ' ;  
    public static final String sHealthInformation =           '   {  '  + 
                                            '     "viewName": "HealthInformation",  '  + 
                                            '     "caseNumber": "0",  '  + 
                                            '     "primaryApplicantIndividualId": 999034247,  '  + 
                                            '     "individualIds": "999034247;999034248;999034249;999034250",  '  + 
                                            '     "programCode": "MA;KT;SN",  '  + 
                                            '     "mode": "Intake",  '  + 
                                            '     "applicationID": "a0Xr00000010rli",  '  + 
                                            '     "miscelleanousParameter": "",  '  + 
                                            '     "Payload": {  '  + 
                                            '       "SSP_Member__c": [  '  + 
                                            '         {  '  + 
                                            '           "IndividualId__c": "999034247",  '  + 
                                            '           "FirstName__c": "firstName",  '  + 
                                            '           "LastName__c": "lastname",  '  + 
                                            '           "HasEmergencyMedicalConditionToggle__c": "N",  '  + 
                                            '           "IsDisabledToggle__c": "Y",  '  + 
                                            '           "IsBlindToggle__c": "N",  '  + 
                                            '           "IsRecoveryFromIllnessOrInjuryToggle__c": "Y",  '  + 
                                            '           "HasPendingAccidentSettlementToggle__c": "U",  '  + 
                                            '           "IsReceivingMedicareBenefitToggle__c": "N",  '  + 
                                            '           "IsPregnantInLastThreeMonthsToggle__c": null,  '  + 
                                            '           "DCPregnancyId__c": null,  '  + 
                                            '           "IsPregnantToggle__c": "N",  '  + 
                                            '           "NumberOfBirthsExpected__c": null,  '  + 
                                            '           "PregnancyDueDate__c": null,  '  + 
                                            '           "PregnancyTerminationDate__c": null,  '  + 
                                            '           "IsToBeReferredToWicToggle__c": null,  '  + 
                                            '           "BenefitTypeCode__c": null,  '  + 
                                            '           "HasEndStageRenalDiseaseToggle__c": null,  '  + 
                                            '           "ParentUnableToCareForChildToggle__c": null,  '  + 
                                            '           "DisabilityStatus__c": null,  '  + 
                                            '           "BlindnessHasEndStageRenalDisease__c": null,  '  + 
                                            '           "BlindnessParentUnableToCareForChild__c": null,  '  + 
                                            '           "BlindnessBenefitTypeCode__c": null,  '  + 
                                            '           "BlindnessStatus__c": null,  '  + 
                                            '           "EmergencyBeginDate__c": null,  '  + 
                                            '           "EmergencyEndDate__c": null,  '  + 
                                            '           "RecoveryDate__c": null,  '  + 
                                            '           "IsOnSickLeaveToggle__c": "U",  '  + 
                                            '           "ReturnToWorkDate__c": null,  '  + 
                                            '           "DCMemberWorkReqExemptionId__c": null,  '  + 
                                            '           "TBQIndividualVerificationCode__c": 0,  '  + 
                                            '           "DisabilityVerificationCode__c": 0,  '  + 
                                            '           "UnableToBuyCookForSelfToggle__c": null,  '  + 
                                            '           "BlindnessVerificationCode__c": 0  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "IndividualId__c": "999034247",  '  + 
                                            '           "HasEmergencyMedicalConditionToggle__c": "Y",  '  + 
                                            '           "IsDisabledToggle__c": "Y",  '  + 
                                            '           "FirstName__c": "firstName",  '  + 
                                            '           "LastName__c": "lastname",  '  + 
                                            '           "IsBlindToggle__c": "N",  '  + 
                                            '           "IsRecoveryFromIllnessOrInjuryToggle__c": "Y",  '  + 
                                            '           "HasPendingAccidentSettlementToggle__c": "U",  '  + 
                                            '           "IsReceivingMedicareBenefitToggle__c": "N",  '  + 
                                            '           "IsPregnantInLastThreeMonthsToggle__c": null,  '  + 
                                            '           "DCPregnancyId__c": null,  '  + 
                                            '           "IsPregnantToggle__c": "N",  '  + 
                                            '           "NumberOfBirthsExpected__c": null,  '  + 
                                            '           "PregnancyDueDate__c": null,  '  + 
                                            '           "PregnancyTerminationDate__c": null,  '  + 
                                            '           "IsToBeReferredToWicToggle__c": null,  '  + 
                                            '           "BenefitTypeCode__c": null,  '  + 
                                            '           "HasEndStageRenalDiseaseToggle__c": null,  '  + 
                                            '           "ParentUnableToCareForChildToggle__c": null,  '  + 
                                            '           "DisabilityStatus__c": null,  '  + 
                                            '           "BlindnessHasEndStageRenalDisease__c": null,  '  + 
                                            '           "BlindnessParentUnableToCareForChild__c": null,  '  + 
                                            '           "BlindnessBenefitTypeCode__c": null,  '  + 
                                            '           "BlindnessStatus__c": null,  '  + 
                                            '           "EmergencyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EmergencyEndDate__c": "2023-10-05",  '  + 
                                            '           "RecoveryDate__c": null,  '  + 
                                            '           "IsOnSickLeaveToggle__c": "U",  '  + 
                                            '           "ReturnToWorkDate__c": null,  '  + 
                                            '           "DCMemberWorkReqExemptionId__c": null,  '  + 
                                            '           "TBQIndividualVerificationCode__c": 0,  '  + 
                                            '           "DisabilityVerificationCode__c": 0,  '  + 
                                            '           "UnableToBuyCookForSelfToggle__c": null,  '  + 
                                            '           "BlindnessVerificationCode__c": 0  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "IndividualId__c": "999034249",  '  + 
                                            '           "HasEmergencyMedicalConditionToggle__c": "N",  '  + 
                                            '           "IsDisabledToggle__c": "Y",  '  + 
                                            '           "IsBlindToggle__c": "N",  '  + 
                                            '           "IsRecoveryFromIllnessOrInjuryToggle__c": "N",  '  + 
                                            '           "HasPendingAccidentSettlementToggle__c": "U",  '  + 
                                            '           "IsReceivingMedicareBenefitToggle__c": "N",  '  + 
                                            '           "IsPregnantInLastThreeMonthsToggle__c": "Y",  '  + 
                                            '           "DCPregnancyId__c": 3882,  '  + 
                                            '           "IsPregnantToggle__c": "Y",  '  + 
                                            '           "NumberOfBirthsExpected__c": "1",  '  + 
                                            '           "PregnancyDueDate__c": "2020-10-29",  '  + 
                                            '           "PregnancyTerminationDate__c": null,  '  + 
                                            '           "IsToBeReferredToWicToggle__c": "Y",  '  + 
                                            '           "BenefitTypeCode__c": null,  '  + 
                                            '           "HasEndStageRenalDiseaseToggle__c": null,  '  + 
                                            '           "ParentUnableToCareForChildToggle__c": null,  '  + 
                                            '           "DisabilityStatus__c": null,  '  + 
                                            '           "BlindnessHasEndStageRenalDisease__c": null,  '  + 
                                            '           "BlindnessParentUnableToCareForChild__c": null,  '  + 
                                            '           "BlindnessBenefitTypeCode__c": null,  '  + 
                                            '           "BlindnessStatus__c": null,  '  + 
                                            '           "EmergencyBeginDate__c": null,  '  + 
                                            '           "EmergencyEndDate__c": null,  '  + 
                                            '           "RecoveryDate__c": null,  '  + 
                                            '           "IsOnSickLeaveToggle__c": null,  '  + 
                                            '           "ReturnToWorkDate__c": null,  '  + 
                                            '           "DCMemberWorkReqExemptionId__c": null,  '  + 
                                            '           "TBQIndividualVerificationCode__c": 0,  '  + 
                                            '           "DisabilityVerificationCode__c": 0,  '  + 
                                            '           "UnableToBuyCookForSelfToggle__c": null,  '  + 
                                            '           "BlindnessVerificationCode__c": 0  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "IndividualId__c": "999034250",  '  + 
                                            '           "HasEmergencyMedicalConditionToggle__c": "N",  '  + 
                                            '           "IsDisabledToggle__c": "Y",  '  + 
                                            '           "FirstName__c": "firstName",  '  + 
                                            '           "LastName__c": "lastname",  '  + 
                                            '           "IsBlindToggle__c": "N",  '  + 
                                            '           "IsRecoveryFromIllnessOrInjuryToggle__c": "Y",  '  + 
                                            '           "HasPendingAccidentSettlementToggle__c": "U",  '  + 
                                            '           "IsReceivingMedicareBenefitToggle__c": "N",  '  + 
                                            '           "IsPregnantInLastThreeMonthsToggle__c": null,  '  + 
                                            '           "DCPregnancyId__c": null,  '  + 
                                            '           "IsPregnantToggle__c": "N",  '  + 
                                            '           "NumberOfBirthsExpected__c": null,  '  + 
                                            '           "PregnancyDueDate__c": null,  '  + 
                                            '           "PregnancyTerminationDate__c": null,  '  + 
                                            '           "IsToBeReferredToWicToggle__c": "Y",  '  + 
                                            '           "BenefitTypeCode__c": null,  '  + 
                                            '           "HasEndStageRenalDiseaseToggle__c": null,  '  + 
                                            '           "ParentUnableToCareForChildToggle__c": null,  '  + 
                                            '           "DisabilityStatus__c": null,  '  + 
                                            '           "BlindnessHasEndStageRenalDisease__c": null,  '  + 
                                            '           "BlindnessParentUnableToCareForChild__c": null,  '  + 
                                            '           "BlindnessBenefitTypeCode__c": null,  '  + 
                                            '           "BlindnessStatus__c": null,  '  + 
                                            '           "EmergencyBeginDate__c": null,  '  + 
                                            '           "EmergencyEndDate__c": null,  '  + 
                                            '           "RecoveryDate__c": null,  '  + 
                                            '           "IsOnSickLeaveToggle__c": "U",  '  + 
                                            '           "ReturnToWorkDate__c": null,  '  + 
                                            '           "DCMemberWorkReqExemptionId__c": null,  '  + 
                                            '           "TBQIndividualVerificationCode__c": 0,  '  + 
                                            '           "DisabilityVerificationCode__c": 0,  '  + 
                                            '           "UnableToBuyCookForSelfToggle__c": null,  '  + 
                                            '           "BlindnessVerificationCode__c": 0  '  + 
                                            '         }  '  + 
                                            '       ],  '  + 
                                            '       "SSP_Benefits__c": null  '  + 
                                            '     },  '  + 
                                            '     "AckResponse": null  '  + 
                                            '  }  ' ; 
    public static final String sHouseHoldOtherInformation =   '   {  '  +
                                        '            "viewName": "HouseHoldOtherInformation",      '+
                                        '            "caseNumber": "0",      '+
                                        '            "primaryApplicantIndividualId": "999034247",      '+
                                        '            "individualIds": "999034247;999034248;999034249;999034250",      '+
                                        '            "programCode": "MA;KT;SN",      '+
                                        '            "mode": "Intake",      '+
                                        '            "applicationID": "a0Xr00000010rli",      '+
                                        '            "miscelleanousParameter": null,      '+
                                        '            "Payload": {      '+
                                        '              "SSP_Member__c": [      '+
                                        '                {      '+
                                        '                  "IndividualId__c": "999034247",      '+
                                        '                  "DCMemberLivingArrangementId__c": "71998",      '+
                                        '                   "FirstName__c": "firstName",  '  + 
                                        '                   "LastName__c": "lastname",  '  + 
                                        '                  "LaTypeCode__c": "IH",      '+
                                        '                  "HasRecievedHalfMealsFrmInstToggle__c": "N",      '+
                                        '                  "IncarcerationBeginDate__c": "2019-10-01",      '+
                                        '                  "IsWaitingForDecisionToggle__c": "Y",      '+
                                        '                  "ExpectedReturnDate__c": "2020-10-01",      '+
                                        '                  "OrganizationName__r": {      '+
                                        '        DCDataId__c: "999034250"      '+
                                        '        },      '+
                                        '                  "InHomeCareType__c": "W",      '+
                                        '                  "ReceiveInHouseAssistanceToggle__c": "Y",      '+
                                        '                  "HasShelterExpenseToggle__c": "N",      '+
                                        '                  "TemporarilyLivesElsewhereToggle__c": "N",      '+
                                        '                  "IsCurrentlyEnrolledInSchoolToggle__c": "Y",      '+
                                        '                  "IsMigrantOrSeasonalFarmWorkerToggle__c": "Y",      '+
                                        '                  "ReceivesSSIBenefitsToggle__c": "Y",      '+
                                        '                  "ReceivesEntitledIncomeToggle__c": "Y",      '+
                                        '                  "FosterStateCode__c": "AL",      '+
                                        '                  "IsStateMedicaidprogramCode__c": "N",      '+
                                        '                  "AgeAtFosterCare__c": 15,      '+
                                        '                  "IsFosterCareToggle__c": "N"      '+
                                        '                }      '+
                                        '              ],      '+
                                        '              "SSP_Benefits__c": [      '+
                                        '                {      '+
                                        '                  "RecordType": {      '+
                                        '        Name :"SSIBenefits"      '+
                                        '          },      '+
                                        '                  "SSP_Member__r": {      '+
                                        '          "IndividualId__c" : "999034247"      '+
                                        '          },      '+
                                        '                  "DCId__c": "1044",      '+
                                        '                  "BenefitApplicationDate__c": "2020-01-01",      '+
                                        '                  "StatusofApplication__c": "AI",      '+
                                        '                  "BenefitDenialReason__c": "OIL",      '+
                                        '                  "BenefitDenialDate__c": "2020-01-05",      '+
                                        '                  "BenefitTypeCode__c": "BL"      '+
                                        '                }      '+
                                        '              ],      '+
                                        '              "SSP_Attendance__c": [      '+
                                        '                {      '+
                                        '                  "SSP_Member__r": {      '+
                                        '          "IndividualId__c" : "999034247"      '+
                                        '          },      '+
                                        '                  "DCId__c": "4518",      '+
                                        '                  "InstitutionSchoolTypeCode__c": "GED",      '+
                                        '                  "ExpectedGraduationDate__c": "2023-01-04T00:00:00",      '+
                                        '                   "InstitutionSchoolName__r": {      '+
                                        '        DCDataId__c : "1407"      '+
                                        '        },          '+
                                        '                  "EnrollmentTypeCode__c": "HT",      '+
                                        '                  "IsParticipatingInWorkStudyProgramToggle__c": "N",      '+
                                        '                  "IsAssignedToInstitutionProgramToggle__c": "Y",      '+
                                        '                  "PlacedThroughProgramCode__c": "WIA"      '+
                                        '                }      '+
                                        '              ],      '+
                                        '              "SSP_Application__c": {      '+
                                        '                "IsFleeingFelonToggle__c": "Y",      '+
                                        '                "IsConvictedOfDrugFelonyToggle__c": "Y",      '+
                                        '                "IsConvictedChemicallyDependentToggle__c": "Y",      '+
                                        '                "IsParticipatingCompltdTreatmentToggle__c": "Y",      '+
                                        '                "HasGivenWrongInformationToggle__c": "Y",      '+
                                        '                "HasConvictedOfBuyingSellingToggle__c": "Y",      '+
                                        '                "HasConvictedOfTradingFirearm__c": "Y",      '+
                                        '                "HasConvictedOfTradingDrugsToggle__c": "Y",      '+
                                        '                "HasConvictedCrimeToggle__c": "Y",      '+
                                        '                "ConvictionVerification__c": true      '+
                                        '              }      '+
                                        '            }      '+
                                        '        }      '+
                                        '              ' ; 
    public static final String sMemberInformation =           '   {  '  + 
                                        '       "viewName": "MemberInformation",  '  + 
                                        '       "primaryApplicantIndividualId": "0",  '  + 
                                        '       "individualIds": "999018553",  '  + 
                                        '       "programCode": "MA",  '  + 
                                        '       "mode": "Intake",  '  + 
                                        '       "Payload": {  '  + 
                                        '         "SSP_Member__c": [  '  + 
                                        '           {  '  + 
                                        '             "RecordType": {       '+
                                        '               "Name":"Individual",    '+
                                        '               }'  + 
                                        '             "IndividualId__c": "999018553",  '  + 
                                        '                   "FirstName__c": "firstName",  '  + 
                                        '                   "LastName__c": "lastname",  '  + 
                                        '             "HasAlienSponsor__c": "1",  '  + 
                                        '             "HasLegalImmigrationStatus__c": null,  '  + 
                                        '             "ServedInUSMilitary__c": null,  '  + 
                                        '             "HasLivedInUs__c": null,  '  + 
                                        '             "AlienTypeCode__c": null,  '  + 
                                        '             "ImmigrationDocumentTypeCode__c": null,  '  + 
                                        '             "SevisId__c": null,  '  + 
                                        '             "ReceiptNumber__c": null,  '  + 
                                        '             "AlienNumber__c": null,  '  + 
                                        '             "CitizenshipNumber__c": null,  '  + 
                                        '             "CountryOfIssuanceCode__c": null,  '  + 
                                        '             "DocumentExpiryDate__c": null,  '  + 
                                        '             "DocumentOtherDescription__c": null,  '  + 
                                        '             "I94Number__c": null,  '  + 
                                        '             "NaturalizationNumber__c": null,  '  + 
                                        '             "PassportNumber__c": null,  '  + 
                                        '             "IsImmigrationDetailsMatch__c": null,  '  + 
                                        '             "ImmigrationFirstName__c": null,  '  + 
                                        '             "ImmigrationMiddleName__c": null,  '  + 
                                        '             "ImmigrationLastName__c": null,  '  + 
                                        '             "ImmigrationSuffix__c": null,  '  + 
                                        '             "ImmigrationDateOfBirth__c": null,  '  + 
                                        '             "DCMemberHighestEducationLevelDetailsId__c": "16403",  '  + 
                                        '             "HighestEducationLevelCode__c": "10G",  '  + 
                                        '             "HighestEducationGraduatedDate__c": null,  '  + 
                                        '             "IsFederalRecognizedIndianTribe__c": null,  '  + 
                                        '             "IndianTribeCode__c": null,  '  + 
                                        '             "IndianTribeState__c": null,  '  + 
                                        '             "IsEligibleForIHFlag__c": null,  '  + 
                                        '             "IsEligibleForIndianHealthServices__c": null,  '  + 
                                        '             "DCContactId__c": "81563",  '  + 
                                        '             "PrimaryPhoneNumber__c": null,  '  + 
                                        '             "PrimaryPhoneExtension__c": null,  '  + 
                                        '             "PrimaryPhoneTypeCode__c": null,  '  + 
                                        '             "IsPrimaryTextPreferred__c": "N",  '  + 
                                        '             "SecondaryPhoneNumber__c": null,  '  + 
                                        '             "SecondaryPhoneExtension__c": null,  '  + 
                                        '             "IsSecondaryTextPreferred__c": "0",  '  + 
                                        '             "PreferredNotificationMethodCode__c": "P",  '  + 
                                        '             "PreferredSpokenLanguageCode__c": "1",  '  + 
                                        '             "PreferredWrittenLanguageCode__c": "1",  '  + 
                                        '             "DCAddressId__c": "167622",  '  + 
                                        '             "IsFixedAddress__c": "1",  '  + 
                                        '             "PhysicalAddressLine1__c": "123 LEXINGTON",  '  + 
                                        '             "PhysicalCity__c": "FRANKFORT",  '  + 
                                        '             "PhysicalCountyCode__c": "003",  '  + 
                                        '             "PhysicalStateCode__c": "KY",  '  + 
                                        '             "PhysicalZipCode4__c": null,  '  + 
                                        '             "PhysicalZipCode5__c": "12345",  '  + 
                                        '             "HasDifferentMailingAddress__c": "0",  '  + 
                                        '             "DCMailingAddressId__c": "167623",  '  + 
                                        '             "MailingAddressLine1__c": "123 LEXINGTON",  '  + 
                                        '             "MailingCity__c": "FRANKFORT",  '  + 
                                        '             "MailingCountyCode__c": "003",  '  + 
                                        '             "MailingStateCode__c": "KY",  '  + 
                                        '             "MailingZipCode4__c": null,  '  + 
                                        '             "MailingZipCode5__c": "12345",  '  + 
                                        '             "TaxFilerStatusCurrentYear__c": null,  '  + 
                                        '             "TaxFilerMemberCurrent__c": null,  '  + 
                                        '             "TaxFilerStatusNextYear__c": null,  '  + 
                                        '             "TaxFilerMemberNext__c": null,  '  + 
                                        //'             "DCMemberId__c": "174",  '  + 
                                        '             "DCIndividualAlienSponsorRelationshipId__c": null,  '  + 
                                        '             "IsSponsoredByOrganization__c": null,  '  + 
                                        '             "SponsoredIndividual__c": null,  '  + 
                                        '             "SponsoredIndividualOther__c": null,  '  + 
                                        '             "AlienSponsorVerification__c": null,  '  + 
                                        '             "CanBuyCookWithHOH__c": "0"  '  + 
                                        '           },  '  + 
                                        '           {  '  + 
                                        '             "RecordType": {       '+
                                        '               "Name":"AlienSponsor",      '+
                                        '               }'  + 
                                        '             "IndividualId__c": 999018554,  '  + 
                                        '             "HasAlienSponsor__c": null,  '  + 
                                        '             "HasLegalImmigrationStatus__c": null,  '  + 
                                        '             "ServedInUSMilitary__c": null,  '  + 
                                        '             "HasLivedInUs__c": null,  '  + 
                                        '             "AlienTypeCode__c": null,  '  + 
                                        '             "ImmigrationDocumentTypeCode__c": null,  '  + 
                                        '             "SevisId__c": null,  '  + 
                                        '             "ReceiptNumber__c": null,  '  + 
                                        '             "AlienNumber__c": null,  '  + 
                                        '             "CitizenshipNumber__c": null,  '  + 
                                        '             "CountryOfIssuanceCode__c": null,  '  + 
                                        '             "DocumentExpiryDate__c": null,  '  + 
                                        '             "DocumentOtherDescription__c": null,  '  + 
                                        '             "I94Number__c": null,  '  + 
                                        '             "NaturalizationNumber__c": null,  '  + 
                                        '             "PassportNumber__c": null,  '  + 
                                        '             "IsImmigrationDetailsMatch__c": null,  '  + 
                                        '             "ImmigrationFirstName__c": null,  '  + 
                                        '             "ImmigrationMiddleName__c": null,  '  + 
                                        '             "ImmigrationLastName__c": null,  '  + 
                                        '             "ImmigrationSuffix__c": null,  '  + 
                                        '             "ImmigrationDateOfBirth__c": null,  '  + 
                                        '             "DCMemberHighestEducationLevelDetailsId__c": null,  '  + 
                                        '             "HighestEducationLevelCode__c": null,  '  + 
                                        '             "HighestEducationGraduatedDate__c": null,  '  + 
                                        '             "IsFederalRecognizedIndianTribe__c": null,  '  + 
                                        '             "IndianTribeCode__c": null,  '  + 
                                        '             "IndianTribeState__c": null,  '  + 
                                        '             "IsEligibleForIHFlag__c": null,  '  + 
                                        '             "IsEligibleForIndianHealthServices__c": null,  '  + 
                                        '             "DCContactId__c": null,  '  + 
                                        '             "Email__c": null,  '  + 
                                        '             "PrimaryPhoneNumber__c": null,  '  + 
                                        '             "PrimaryPhoneExtension__c": null,  '  + 
                                        '             "PrimaryPhoneTypeCode__c": null,  '  + 
                                        '             "IsPrimaryTextPreferred__c": null,  '  + 
                                        '             "SecondaryPhoneNumber__c": null,  '  + 
                                        '             "SecondaryPhoneExtension__c": null,  '  + 
                                        '             "IsSecondaryTextPreferred__c": null,  '  + 
                                        '             "PreferredNotificationMethodCode__c": null,  '  + 
                                        '             "PreferredSpokenLanguageCode__c": null,  '  + 
                                        '             "PreferredWrittenLanguageCode__c": null,  '  + 
                                        '             "DCAddressId__c": null,  '  + 
                                        '             "IsFixedAddress__c": null,  '  + 
                                        '             "PhysicalAddressLine1__c": null,  '  + 
                                        '             "PhysicalCity__c": null,  '  + 
                                        '             "PhysicalCountyCode__c": null,  '  + 
                                        '             "PhysicalStateCode__c": null,  '  + 
                                        '             "PhysicalZipCode4__c": null,  '  + 
                                        '             "PhysicalZipCode5__c": null,  '  + 
                                        '             "PhysicalAddressLine2__c": null,  '  + 
                                        '             "HasDifferentMailingAddress__c": null,  '  + 
                                        '             "DCMailingAddressId__c": null,  '  + 
                                        '             "MailingAddressLine1__c": null,  '  + 
                                        '             "MailingCity__c": null,  '  + 
                                        '             "MailingCountyCode__c": null,  '  + 
                                        '             "MailingStateCode__c": null,  '  + 
                                        '             "MailingZipCode4__c": null,  '  + 
                                        '             "MailingZipCode5__c": null,  '  + 
                                        '             "MailingAddressLine2__c": null,  '  + 
                                        '             "TaxFilerStatusCurrentYear__c": null,  '  + 
                                        '             "TaxFilerMemberCurrent__c": null,  '  + 
                                        '             "TaxFilerStatusNextYear__c": null,  '  + 
                                        '             "TaxFilerMemberNext__c": null,  '  + 
                                        //'             "DCMemberId__c": "174",  '  + 
                                        '             "DCIndividualAlienSponsorRelationshipId__c": null,  '  + 
                                        '             "IsSponsoredByOrganization__c": "0",  '  + 
                                        '             "SponsoredIndividual__c": "999018553",  '  + 
                                        '             "SponsoredIndividualOther__c": null,  '  + 
                                        '             "AlienSponsorVerification__c": "1",  '  + 
                                        '             "CanBuyCookWithHOH__c": null  '  + 
                                        '           }  '  + 
                                        '         ]  '  + 
                                        '       }  '  + 
                                        '     }  '  + 
                                        '  }  ' ; 
    public static final String sRelationshipInformation =     '   {  '  +
                                        '          "ReverseSSPDCResponse": {      '+
                                        '            "viewName": "RelationshipInformation",      '+
                                        '            "caseNumber": "0",      '+
                                        '            "primaryApplicantIndividualId": "999034247",      '+
                                        '            "individualIds": "999034247;999034248;999034249;999034250",      '+
                                        '            "programCode": "MA;KT;SN",      '+
                                        '            "mode": "Intake",      '+
                                        '            "applicationID": "a0Xr00000010rli",      '+
                                        '            "miscelleanousParameter": null,      '+
                                        '            "Payload": {      '+
                                        '              "SSP_Relationship__c": [      '+
                                        '                {      '+
                                        '                  "SSP_Member__r": {      '+
                                        '        IndividualId__c : "999034250"      '+
                                        '          },      '+
                                        '          "SSP_MemberRelatedTo__r": {      '+
                                        '        IndividualId__c : "999034247"      '+
                                        '          },      '+
                                        '                  "DCId__c": "57107",      '+
                                        '                  "RelationshipType__c": "UR",      '+
                                        '                  "IsCareTakerToggle__c": "N",      '+
                                        '                  "IsActingParentToggle__c": "N",      '+
                                        '                  "IntendToPursueLegalCustodyToggle__c": "N"      '+
                                        '                },      '+
                                        '        {      '+
                                        '                  "SSP_Member__r": {      '+
                                        '        IndividualId__c : "999034249"      '+
                                        '          },      '+
                                        '          "SSP_MemberRelatedTo__r": {      '+
                                        '        IndividualId__c : "999034247"      '+
                                        '          },      '+
                                        '                  "DCId__c": "57107",      '+
                                        '                  "RelationshipType__c": "UR",      '+
                                        '                  "IsCareTakerToggle__c": "N",      '+
                                        '                  "IsActingParentToggle__c": "N",      '+
                                        '                  "IntendToPursueLegalCustodyToggle__c": "NULL"      '+
                                        '                }      '+
                                        '              ]      '+
                                        '            }      '+
                                        '        }      ' ; 
    public static final String sResourceInformation =         '   {  '  + 
                                        '     "viewName": "ResourceInformation",  '  + 
                                        '     "caseNumber": "0",  '  + 
                                        '     "primaryApplicantIndividualId": 999034247,  '  + 
                                        '     "individualIds": "999034247;999034248;999034249;999034250",  '  + 
                                        '     "programCode": "MA;KT;SN",  '  + 
                                        '     "mode": "Intake",  '  + 
                                        '     "applicationID": "a0Xr00000010pWv",  '  + 
                                        '     "miscelleanousParameter": "",  '  + 
                                        '     "Payload": {  '  + 
                                        '       "SSP_Member__c": [  '  + 
                                        '         {  '  + 
                                        '           "IndividualId__c": "999034247",  '  + 
                                        '           "HasOwnBankAccountToggle__c": "Y",  '  + 
                                        '           "HasInvestmentsToggle__c": "Y",  '  + 
                                        '           "HasCashReloadableMoneyCardToggle__c": "N",  '  + 
                                        '           "HasVehicleToggle__c": "Y",  '  + 
                                        '           "HasRealEstatePropertyToggle__c": "Y",  '  + 
                                        '           "HasLifeInsuranceToggle__c": "Y",  '  + 
                                        '           "HasPreArrangedFuneralContractToggle__c": "N"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IndividualId__c": "999034247",  '  + 
                                        '           "HasOwnBankAccountToggle__c": "N",  '  + 
                                        '           "HasInvestmentsToggle__c": "N",  '  + 
                                        '           "HasCashReloadableMoneyCardToggle__c": "Y",  '  + 
                                        '           "HasVehicleToggle__c": "Y",  '  + 
                                        '           "HasRealEstatePropertyToggle__c": "Y",  '  + 
                                        '           "HasLifeInsuranceToggle__c": "Y",  '  + 
                                        '           "HasPreArrangedFuneralContractToggle__c": "Y"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IndividualId__c": "999034247",  '  + 
                                        '           "HasOwnBankAccountToggle__c": "N",  '  + 
                                        '           "HasInvestmentsToggle__c": "Y",  '  + 
                                        '           "HasCashReloadableMoneyCardToggle__c": "N",  '  + 
                                        '           "HasVehicleToggle__c": "N",  '  + 
                                        '           "HasRealEstatePropertyToggle__c": "Y",  '  + 
                                        '           "HasLifeInsuranceToggle__c": "Y",  '  + 
                                        '           "HasPreArrangedFuneralContractToggle__c": "Y"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "IndividualId__c": "999034247",  '  + 
                                        '           "HasOwnBankAccountToggle__c": "N",  '  + 
                                        '           "HasInvestmentsToggle__c": "N",  '  + 
                                        '           "HasCashReloadableMoneyCardToggle__c": "N",  '  + 
                                        '           "HasVehicleToggle__c": "N",  '  + 
                                        '           "HasRealEstatePropertyToggle__c": "N",  '  + 
                                        '           "HasLifeInsuranceToggle__c": "N",  '  + 
                                        '           "HasPreArrangedFuneralContractToggle__c": "N"  '  + 
                                        '         }  '  + 
                                        '       ],  '  + 
                                        '       "SSP_Asset__c": [  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8861",  '  + 
                                        '           "DCResourceValueDetailId__c": "8164",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "RP",  '  + 
                                        '           "ResourceSubTypeCode__c": "BU",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": "Y",  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": "Y",  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": "Y",  '  + 
                                        '           "Location__c": "DESCRIPTION",  '  + 
                                        '           "RealEstateFairMarketValue__c": "443.00",  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8861"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8862",  '  + 
                                        '           "DCResourceValueDetailId__c": "8165",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2646,  '  + 
                                        '           "ResourceTypeCode__c": "LI",  '  + 
                                        '           "ResourceSubTypeCode__c": "TM",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": "bajaj",  '  + 
                                        '           "PolicyNumber__c": "pnumber123",  '  + 
                                        '           "StartDate__c": "2020-01-01",  '  + 
                                        '           "FaceValueAmount__c": 348,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": "hyd",  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": 44,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": "Y",  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": "Y",  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8862"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8863",  '  + 
                                        '           "DCResourceValueDetailId__c": "8166",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2647,  '  + 
                                        '           "ResourceTypeCode__c": "VI",  '  + 
                                        '           "ResourceSubTypeCode__c": "CAR",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": "2019-01-02",  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": "N",  '  + 
                                        '           "NoAccessReason__c": "JTO",  '  + 
                                        '           "Make__c": "2016",  '  + 
                                        '           "Model__c": "test",  '  + 
                                        '           "ModelYear__c": "2018",  '  + 
                                        '           "VehicleCategoryCode__c": "TRANS",  '  + 
                                        '           "VehicleUseReason__c": "OWNEQP",  '  + 
                                        '           "VehicleFairMarketValue__c": 55,  '  + 
                                        '           "VehicleDebt__c": 32,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8863"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8864",  '  + 
                                        '           "DCResourceValueDetailId__c": "8167",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "IN",  '  + 
                                        '           "ResourceSubTypeCode__c": "ST",  '  + 
                                        '           "AccountBalance__c": 30,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8864"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8865",  '  + 
                                        '           "DCResourceValueDetailId__c": "8168",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "AC",  '  + 
                                        '           "ResourceSubTypeCode__c": "SA",  '  + 
                                        '           "AccountBalance__c": 22,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8865"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8855",  '  + 
                                        '           "DCResourceValueDetailId__c": "8158",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2643,  '  + 
                                        '           "ResourceTypeCode__c": "FA",  '  + 
                                        '           "ResourceSubTypeCode__c": "LI",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": "kendkghg",  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": 44,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": "Y",  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8857"  '  + 
                                        '           },  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8855"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8856",  '  + 
                                        '           "DCResourceValueDetailId__c": "8159",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "RP",  '  + 
                                        '           "ResourceSubTypeCode__c": "RN",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": "Y",  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": "Y",  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": "Y",  '  + 
                                        '           "Location__c": "RENTLAL DISC",  '  + 
                                        '           "RealEstateFairMarketValue__c": "454.00",  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8856"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8857",  '  + 
                                        '           "DCResourceValueDetailId__c": "8160",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2644,  '  + 
                                        '           "ResourceTypeCode__c": "LI",  '  + 
                                        '           "ResourceSubTypeCode__c": "MD",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": "bajaj",  '  + 
                                        '           "PolicyNumber__c": "pnumber444",  '  + 
                                        '           "StartDate__c": "2020-01-09",  '  + 
                                        '           "FaceValueAmount__c": 455,  '  + 
                                        '           "CashSurrenderValue__c": 5,  '  + 
                                        '           "InsuranceCompanyAddress__c": "ICA",  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": 0,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": "Y",  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": "Y",  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8857"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8858",  '  + 
                                        '           "DCResourceValueDetailId__c": "8161",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2645,  '  + 
                                        '           "ResourceTypeCode__c": "VI",  '  + 
                                        '           "ResourceSubTypeCode__c": "BOAT",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": "2020-01-15",  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": "Y",  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": "2020",  '  + 
                                        '           "Model__c": "model20",  '  + 
                                        '           "ModelYear__c": "2020",  '  + 
                                        '           "VehicleCategoryCode__c": "RECR",  '  + 
                                        '           "VehicleUseReason__c": "DISEQP",  '  + 
                                        '           "VehicleFairMarketValue__c": 443,  '  + 
                                        '           "VehicleDebt__c": 4,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8858"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8859",  '  + 
                                        '           "DCResourceValueDetailId__c": "8162",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "OR",  '  + 
                                        '           "ResourceSubTypeCode__c": "DEC",  '  + 
                                        '           "AccountBalance__c": 44,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8859"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8849",  '  + 
                                        '           "DCResourceValueDetailId__c": "8152",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2641,  '  + 
                                        '           "ResourceTypeCode__c": "FA",  '  + 
                                        '           "ResourceSubTypeCode__c": "CA",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": "gachiklhfgjkl",  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": 455,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": "N",  '  + 
                                        '           "FuneralFundCode__c": "CA",  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8849"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8850",  '  + 
                                        '           "DCResourceValueDetailId__c": "8153",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "RP",  '  + 
                                        '           "ResourceSubTypeCode__c": "BU",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": "N",  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": "N",  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": "N",  '  + 
                                        '           "Location__c": "TESTLJK LOCATION",  '  + 
                                        '           "RealEstateFairMarketValue__c": "48.00",  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8850"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8851",  '  + 
                                        '           "DCResourceValueDetailId__c": "8154",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": 2642,  '  + 
                                        '           "ResourceTypeCode__c": "LI",  '  + 
                                        '           "ResourceSubTypeCode__c": "BR",  '  + 
                                        '           "AccountBalance__c": null,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": "icici",  '  + 
                                        '           "PolicyNumber__c": "4uytkgdk444",  '  + 
                                        '           "StartDate__c": "2019-01-10",  '  + 
                                        '           "FaceValueAmount__c": 484,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": 74,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": "N",  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": "Y",  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8851"  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "RecordType": {  '  + 
                                        '             "Name": "SSPResource"  '  + 
                                        '           },  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "DCId__c": "8852",  '  + 
                                        '           "DCResourceValueDetailId__c": "8155",  '  + 
                                        '           "DCResourceMiscellaneousDetailId__c": null,  '  + 
                                        '           "ResourceTypeCode__c": "IN",  '  + 
                                        '           "ResourceSubTypeCode__c": "MF",  '  + 
                                        '           "AccountBalance__c": 22,  '  + 
                                        '           "IsHomeHomesteadPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeProducingPropertyToggle__c": null,  '  + 
                                        '           "IsIncomeEssentialToSelfSupportToggle__c": null,  '  + 
                                        '           "Location__c": null,  '  + 
                                        '           "RealEstateFairMarketValue__c": null,  '  + 
                                        '           "InsuranceCompanyName__c": null,  '  + 
                                        '           "PolicyNumber__c": null,  '  + 
                                        '           "StartDate__c": null,  '  + 
                                        '           "FaceValueAmount__c": null,  '  + 
                                        '           "CashSurrenderValue__c": null,  '  + 
                                        '           "InsuranceCompanyAddress__c": null,  '  + 
                                        '           "InsuranceCompanyPhoneNumber__c": null,  '  + 
                                        '           "LoanBalance__c": null,  '  + 
                                        '           "IsPolicyDesignatedToPayBurialToggle__c": null,  '  + 
                                        '           "IsPolicyUsedForPrearrangedFuneralToggle__c": null,  '  + 
                                        '           "FuneralLocation__c": null,  '  + 
                                        '           "PreFuneralAgmtGoodsAndServicesCost__c": null,  '  + 
                                        '           "HasItemizedStmtOfGoodsSignByClientToggle__c": null,  '  + 
                                        '           "FuneralFundCode__c": null,  '  + 
                                        '           "InsurancePolicyAsset__r": null,  '  + 
                                        '           "HasPolicyAssignedToFuneralHomeToggle__c": null,  '  + 
                                        '           "IsIndividualAbleToRideToggle__c": null,  '  + 
                                        '           "HasAccessToVehicleToggle__c": null,  '  + 
                                        '           "NoAccessReason__c": null,  '  + 
                                        '           "Make__c": null,  '  + 
                                        '           "Model__c": null,  '  + 
                                        '           "ModelYear__c": null,  '  + 
                                        '           "VehicleCategoryCode__c": null,  '  + 
                                        '           "VehicleUseReason__c": null,  '  + 
                                        '           "VehicleFairMarketValue__c": null,  '  + 
                                        '           "VehicleDebt__c": null,  '  + 
                                        '           "PrimaryUserIndividual__r": null,  '  + 
                                        '           "DCAssetId__c": "Resource,8852"  '  + 
                                        '         }  '  + 
                                        '       ],  '  + 
                                        '       "SSP_ResourceOwnership__c": [  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1344",  '  + 
                                        '           "DCId__c": "2986",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8858"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1344",  '  + 
                                        '           "DCId__c": "2987",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8858"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1345",  '  + 
                                        '           "DCId__c": "2988",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8861"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1345",  '  + 
                                        '           "DCId__c": "2989",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8861"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1345",  '  + 
                                        '           "DCId__c": "2990",  '  + 
                                        '           "SSP_Member__r": null,  '  + 
                                        '           "JointOwnerName__c": "digkjyfkgo",  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8861"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1346",  '  + 
                                        '           "DCId__c": "2991",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8863"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1346",  '  + 
                                        '           "DCId__c": "2992",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8863"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1346",  '  + 
                                        '           "DCId__c": "2993",  '  + 
                                        '           "SSP_Member__r": null,  '  + 
                                        '           "JointOwnerName__c": "external owner",  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8863"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1347",  '  + 
                                        '           "DCId__c": "2994",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034249"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8864"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1347",  '  + 
                                        '           "DCId__c": "2995",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8864"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1347",  '  + 
                                        '           "DCId__c": "2996",  '  + 
                                        '           "SSP_Member__r": null,  '  + 
                                        '           "JointOwnerName__c": "full name",  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8864"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1348",  '  + 
                                        '           "DCId__c": "2997",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034248"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8865"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1348",  '  + 
                                        '           "DCId__c": "2998",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999034247"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8865"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1348",  '  + 
                                        '           "DCId__c": "2999",  '  + 
                                        '           "SSP_Member__r": null,  '  + 
                                        '           "JointOwnerName__c": "gmail",  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8865"  '  + 
                                        '           }  '  + 
                                        '         },  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1348",  '  + 
                                        '           "DCId__c": "3000",  '  + 
                                        '           "SSP_Member__r": null,  '  + 
                                        '           "JointOwnerName__c": "yahoo",  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,8865"  '  + 
                                        '           }  '  + 
                                        '         }  '  + 
                                        '       ],  '  + 
                                        '       "SSP_Application__c": null  '  + 
                                        '     },  '  + 
                                        '     "AckResponse": null  '  + 
                                        '  }  ' ; 
    
                                        // Wrapper Structure
    public static final String sOnboardIndvAuthRep =          '   {  '  + 
                                                              '     "viewName": "OnboardIndivAuthRep",  '  + 
                                                              '     "caseNumber": 0,  '  + 
                                                              '     "primaryApplicantIndividualId": "",  '  + 
                                                              '     "individualIds": "",  '  + 
                                                              '     "programCode": "",  '  + 
                                                              '     "mode": "",  '  + 
                                                              '     "applicationID": "",  '  + 
                                                              '     "miscelleanousParameter": "",  '  + 
                                                              '     "role": "Individual_Auth_Rep",  '  + 
                                                              '     "KeyValueParameters": null,  '  + 
                                                              '     "Payload": {  '  + 
                                                              '       "AccountContactRelation": [  '  + 
                                                              '         {  '  + 
                                                              '           "Roles": "Individual_Auth_Rep",  '  + 
                                                              '           "DCACRID__c": "INDIVIDUAL AUTHORIZED REPRESENTATIVE,129348,0",  '  + 
                                                              '           "DCContactId__c": "129348"  '  + 
                                                              '         }  '  + 
                                                              '       ]  '  + 
                                                              '     }  '  +
                                                              //'     "AckResponse": {"AckResponseCode":"1234"}  '  + 
                                                              '   }  '  + 
                                                              '    ' ; 
    public static final String sRFIInformation =              '   {  '  + 
                                                              '     "individualIds": "999015978",  '  + 
                                                              '     "applicationID": "a0Xr00000011S6hEAE",  '  + 
                                                              '     "miscelleanousParameter": "",  '  + 
                                                              '     "viewName": "RFIDetails",  '  + 
                                                              '     "caseNumber": 100049980,  '  + 
                                                              '     "primaryApplicantIndividualId": 999015976,  '  + 
                                                              '     "programCode": "MA",  '  + 
                                                              '     "mode": "RAC",  '  + 
                                                              '     "Payload": {  '  + 
                                                              '       "RFIInformation": [  '  + 
                                                              '         {  '  + 
                                                              '           "IndividualId": 999015976,  '  + 
                                                              '           "FullName": "ROSSS GELLERS",  '  + 
                                                              '           "TypeOfProof": "KI-HIPP Preferred Payment Method",  '  + 
                                                              '           "DueDate": "2019-07-01",  '  + 
                                                              '           "CaseNumber": 100049980,  '  + 
                                                              '           "ProgramCode": "KP",  '  + 
                                                              '           "TypeOfProofRefCode": "KHIPP_OOP_EXP",  '  + 
                                                              '           "UniqueIdentifier": "KP-1115997687"  '  + 
                                                              '         }  '  + 
                                                              '       ],  '  + 
                                                              '       "DocumentMetaData": [  '  + 
                                                              '         {  '  + 
                                                              '           "IndividualId": 999015976,  '  + 
                                                              '           "IndividualName": "ROSSS GELLERS",  '  + 
                                                              '           "CaseNumber": 100049980,  '  + 
                                                              '           "DocumentMetaDataId": "B61AE0E0-F5CA-D6E3-7B1B-39F02DA172AB",  '  + 
                                                              '           "DocumentName": "test",  '  + 
                                                              '           "Extension": "tif",  '  + 
                                                              '           "MimeType": "image/tiff",  '  + 
                                                              '           "DocumentType": "29",  '  + 
                                                              '           "SubmittedDate": "2019-09-10",  '  + 
                                                              '           "Statuscode": "test"  '  + 
                                                              '         }  '  + 
                                                              '       ],  '  + 
                                                              '       "CaseInformation": [  '  + 
                                                              '         {  '  + 
                                                              '           "IndividualId": 999015976,  '  + 
                                                              '           "CaseNumber": 100049980,  '  + 
                                                              '           "ProgramCode": "KP;MA",  '  + 
                                                              '           "FullName": "ROSSS GELLERS",  '  + 
                                                              '           "IsEligibleforRenewal": "N"  '  + 
                                                              '         }  '  + 
                                                              '       ]  '  + 
                                                              '     }  '  + 
                                                              '   }  '  + 
                                                              '    ' ; 
    public static final String sMyInformation       =         '   {  '  + 
                                                            '     "primaryApplicantIndividualId": 999034365,  '  + 
                                                            '     "caseNumber": 0,  '  + 
                                                            '     "viewName": "MyInformation",  '  + 
                                                            '     "role": "",  '  + 
                                                            '     "KeyValueParameters": null,  '  + 
                                                            '     "miscelleanousParameter": "",  '  + 
                                                            '     "applicationID": "",  '  + 
                                                            '     "mode": "",  '  + 
                                                            '     "programCode": "",  '  + 
                                                            '     "individualIds": "",  '  + 
                                                            '     "Payload": {  '  + 
                                                            '       "SSP_Member__c": [  '  + 
                                                            '         {  '  + 
                                                            '           "DCId__c": 88774,  '  + 
                                                            '           "PreferredDCBSOffice__c": "AAAA Test 2 Office",  '  + 
                                                            '           "PreferredWrittenLanguageCode__c": "1",  '  + 
                                                            '           "PreferredSpokenLanguageCode__c": "1",  '  + 
                                                            '           "MailingCountyCode__c": "001",  '  + 
                                                            '           "MailingZipCode4__c": "1234",  '  + 
                                                            '           "MailingZipCode5__c": "23453",  '  + 
                                                            '           "MailingStateCode__c": "KY",  '  + 
                                                            '           "MailingCity__c": "GGGG",  '  + 
                                                            '           "MailingAddressLine2__c": "GGGG",  '  + 
                                                            '           "MailingAddressLine1__c": "GGG",  '  + 
                                                            '           "PhysicalCountyCode__c": "105",  '  + 
                                                            '           "PhysicalZipCode4__c": "1234",  '  + 
                                                            '           "PhysicalZipCode5__c": "23453",  '  + 
                                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                                            '           "PhysicalCity__c": "GGGG",  '  + 
                                                            '           "PhysicalAddressLine2__c": "GGG",  '  + 
                                                            '           "PhysicalAddressLine1__c": "GGG",  '  + 
                                                            '           "PreferredNotificationMethodCode__c": "P",  '  + 
                                                            '           "PreferredNotificationMethodForTaxCode__c": "EE",  '  + 
                                                            '           "Send_Text_messages_to_Secondary__c": "N",  '  + 
                                                            '           "SecondaryPhoneTypeCode__c": "LND",  '  + 
                                                            '           "SecondaryPhoneExtension__c": "18",  '  + 
                                                            '           "SecondaryPhoneNumber__c": "1231231",  '  + 
                                                            '           "IsPrimaryTextPreferred__c": "N",  '  + 
                                                            '           "PrimaryPhoneTypeCode__c": "LND",  '  + 
                                                            '           "PrimaryPhoneExtension__c": "123",  '  + 
                                                            '           "PrimaryPhoneNumber__c": "1234456789",  '  + 
                                                            '           "Email__c": "Test@test.com",  '  + 
                                                            '           "LastName__c": "SXTGHNIJN",  '  + 
                                                            '           "FirstName__c": "TRQSDCVIUH",  '  + 
                                                            '           "IndividualId__c": "999034365",  '  + 
                                                            '           "DCBS_OfficeId__c": "1181",  '  + 
                                                            '           "SuffixCode__c": "SR",  '  + 
                                                            '           "MiddleInitial__c": "A"  '  + 
                                                            '         }  '  + 
                                                            '       ]  '  + 
                                                            '     },  '  + 
                                                            '     "AckResponse": null  '  + 
                                                            '   }  '  + 
                                                            '    ' ; 
    public static final String sEligibilitySummary =          '   {  '  + 
                                        '               "viewName": "EligibilitySummary",   '+
                                        '               "caseNumber": "100060268",  '+
                                        '               "primaryApplicantIndividualId": "0",    '+
                                        '               "individualIds": null,  '+
                                        '               "programCode": null,    '+
                                        '               "mode": null,   '+
                                        '               "applicationID": null,  '+
                                        '               "miscelleanousParameter": null, '+
                                        '               "Payload": {    '+
                                        '                   "SSP_EligibilitySummary__c": [  '+
                                        '                       {   '+
                                        '                           "IndividualId": "999034358",    '+
                                        '                           "ProgramCode": "SN",    '+
                                        '                           "BenefitStatusCode": "X",   '+
                                        '                           "BenefitBeginDate": null,   '+
                                        '                           "BenefitEndDate": null, '+
                                        '                           "EligibleForExpeditedSNAP": "1",    '+
                                        '                           "EligibleForKIHIPP": null   '+
                                        '                           },  '+  
                                        '                       {   '+
                                        '                           "IndividualId": "999034358",    '+
                                        '                           "ProgramCode": "MA",    '+
                                        '                           "BenefitStatusCode": "P",   '+
                                        '                           "BenefitBeginDate": null,   '+
                                        '                           "BenefitEndDate": null, '+
                                        '                           "EligibleForExpeditedSNAP": null,   '+
                                        '                           "EligibleForKIHIPP": "0"    '+
                                        '                           },  '+
                                        '                       {   '+
                                        '                           "IndividualId": "999034359",    '+
                                        '                           "ProgramCode": "MA",    '+
                                        '                           "BenefitStatusCode": "X",   '+
                                        '                           "BenefitBeginDate": null,   '+
                                        '                           "BenefitEndDate": null, '+
                                        '                           "EligibleForExpeditedSNAP": null,   '+
                                        '                           "EligibleForKIHIPP": "0"    '+
                                        '                           }   '+
                                        '                       ]   '+
                                        '                   }   '+
                                        '   }   ';
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
                                               '              "ProgramStatusCode": "PI",    '+
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
                                                              '    "IndividualId": "999034363",    '+
                                                              '    "IndividualName": "CXZCZXCAS ASZCZXC",    '+
                                                              '    "ProgramCode": "MA",    '+
                                                              '    "ProgramStatusCode": "PE",    '+
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
                                                            ' } '+
                                                          ' ]   '+
                                                        ' }     '+
                                                   '   }    ';  
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
                                                          '     "IsEnrolledInPlan" : "N",      '+
                                                          '     "IsEligibleToEnroll" : null,      '+
                                                          '     "InEligibleDueToLTC" : null,      '+
                                                          '     "InEligibleDueToIncarceration" : null,      '+
                                                          '     "InEligibleDueToKIHIPP" : null,      '+
                                                          '     "MCOBeginDate" : null      '+
                                                    '   },      '+
                                                    '   {      '+
                                                          '     "CaseNumber" : "100060269",      '+
                                                          '     "IndividualId" : "999034363",      '+
                                                          '     "IndividualName" : "CXZCZXCAS ASZCZXC",      '+
                                                          '     "IsEnrolledInPlan" : "N",      '+
                                                          '     "IsEligibleToEnroll" : null,      '+
                                                          '     "InEligibleDueToLTC" : null,      '+
                                                          '     "InEligibleDueToIncarceration" : null,      '+
                                                          '     "InEligibleDueToKIHIPP" : null,      '+
                                                          '     "MCOBeginDate" : null      '+
                                                    '    }      '+
                                                '      ]      '+
                                                '    }      '+
                                                ' }      ';
    public static final String sNonCitizenClientInfo =        '   {  '  + 
                                                            '     "viewName": "NonCitizenSearchCase",  '  + 
                                                            '     "caseNumber": 0,  '  + 
                                                            '     "primaryApplicantIndividualId": 0,  '  + 
                                                            '     "individualIds": "",  '  + 
                                                            '     "programCode": "",  '  + 
                                                            '     "mode": "",  '  + 
                                                            '     "applicationID": "",  '  + 
                                                            '     "miscelleanousParameter": "",  '  + 
                                                            '     "role": "",  '  + 
                                                            '     "Payload": {  '  + 
                                                            '       "CaseInfo": {  '  + 
                                                            '         "CaseNumber": "100061579",  '  + 
                                                            '         "IndividualId": "999038084",  '  + 
                                                            '         "FirstName": "BOMKBNDK",  '  + 
                                                            '         "MiddleInitial": "A",  '  + 
                                                            '         "LastName": "DLKGHOSH",  '  + 
                                                            '         "Suffix": "SR",  '  + 
                                                            '         "GenderCode": "M",  '  + 
                                                            '         "BirthDate": "1986-04-26",  '  + 
                                                            '         "AddressLine1": "SDFSDF",  '  + 
                                                            '         "ZipCode": "12342",  '  + 
                                                            '         "EmailAddress": "test@test.com",  '  + 
                                                            '         "PhoneNumber": "0102030223",  '  + 
                                                            '         "AssistedbyAuthRep": "aSDFS ASDF",  '  + 
                                                            '         "AssistedbyAsister": "ASDFASDF SDF",  '  + 
                                                            '         "AssisterName": "ASDFASDF ASDF",  '  + 
                                                            '         "AssignmentStartDate": "2020-08-09",  '  + 
                                                            '         "ClientRole": "HeadOfHousehold,HeadOfHousehold,HeadOfHousehold",  '  + 
                                                            '         "RFIDueDate": "2020-07-24",  '  + 
                                                            '         "NumberofRFI": "2",  '  + 
                                                            '         "RenewalDueDate": "2021-03-31",  '  + 
                                                            '         "ProgramDueRenewal": "MA",  '  + 
                                                            '         "MCOEnrollmentStatus": "PE",  '  + 
                                                            '         "CaseStatus": "AP,PE,PE",  '  + 
                                                            '         "SubmittedDate": "2020-04-25",  '  + 
                                                            '         "LastupdatedDate": "2020-04-25",  '  + 
                                                            '         "MaidCardNumber": "1000134546",  '  + 
                                                            '         "SSN": "12323",  '  + 
                                                            '         "AddressLine2": "Part Street",  '  + 
                                                            '         "MiddleInitial": "A",  '  + 
                                                            '         "Suffix": "Mr.",  '  + 
                                                            '         "CaseStatusSpanish": "Aprobado"  '  + 
                                                            '       }  '  + 
                                                            '     },  '  + 
                                                            '     "AckResponse": null  '  + 
                                                            '   }  '  + 
                                                            '    ' ; 
    public static final String sNonCitizenSearchCase =        '   {  '  + 
                                                '     "viewName": "NonCitizenSearchCase",  '  + 
                                                '     "caseNumber": "0",  '  + 
                                                '     "primaryApplicantIndividualId": 0,  '  + 
                                                '     "individualIds": "",  '  + 
                                                '     "programCode": "",  '  + 
                                                '     "mode": "",  '  + 
                                                '     "applicationID": "",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "role": "",  '  + 
                                                '     "Payload": {  '  + 
                                                '       "CaseInfo": [  '  + 
                                                '         {  '  + 
                                                '           "CaseNumber": "100048368",  '  + 
                                                '           "IndividualId": "999014548",  '  + 
                                                '           "FirstName": "ADLT",  '  + 
                                                '           "LastName": "WANKHEDE",  '  + 
                                                '           "GenderCode": "M",  '  + 
                                                '           "BirthDate": "1993-01-01",  '  + 
                                                '           "AddressLine1": "SDSDSXX JSJD",  '  + 
                                                '           "Zipcode": null,  '  + 
                                                '           "EmailAddress": "",  '  + 
                                                '           "PhoneNumber": null,  '  + 
                                                '           "AssistedbyAuthRep": null,  '  + 
                                                '           "AssistedbyAsister": null,  '  + 
                                                '           "AssisterName": null,  '  + 
                                                '           "AssignmentStartDate": null,  '  + 
                                                '           "ClientRole": "HeadOfHousehold",  '  + 
                                                '           "RFIDueDate": null,  '  + 
                                                '           "NumberofRFI": "0",  '  + 
                                                '           "RenewalDueDate": null,  '  + 
                                                '           "ProgamDueRenewal": null,  '  + 
                                                '           "MCOEnrollmentStatus": null,  '  + 
                                                '           "CaseStatus": "DN",  '  + 
                                                '           "SubmittedDate": "2018-12-08",  '  + 
                                                '           "LastupdatedDate": "2019-05-01",  '  + 
                                                '           "MaidCardNumber": null  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "CaseNumber": "100048369",  '  + 
                                                '           "IndividualId": "999014550",  '  + 
                                                '           "FirstName": "ADLT",  '  + 
                                                '           "LastName": "WANKHEDE",  '  + 
                                                '           "GenderCode": "M",  '  + 
                                                '           "BirthDate": "1993-01-01",  '  + 
                                                '           "AddressLine1": "SDSDSXX JSJD",  '  + 
                                                '           "Zipcode": null,  '  + 
                                                '           "EmailAddress": null,  '  + 
                                                '           "PhoneNumber": null,  '  + 
                                                '           "AssistedbyAuthRep": null,  '  + 
                                                '           "AssistedbyAsister": null,  '  + 
                                                '           "AssisterName": null,  '  + 
                                                '           "AssignmentStartDate": null,  '  + 
                                                '           "ClientRole": "HeadOfHousehold",  '  + 
                                                '           "RFIDueDate": null,  '  + 
                                                '           "NumberofRFI": "0",  '  + 
                                                '           "RenewalDueDate": "2019-11-25",  '  + 
                                                '           "ProgamDueRenewal": null,  '  + 
                                                '           "MCOEnrollmentStatus": "TERM",  '  + 
                                                '           "CaseStatus": "AP",  '  + 
                                                '           "SubmittedDate": "2018-12-08",  '  + 
                                                '           "LastupdatedDate": "2019-02-02",  '  + 
                                                '           "MaidCardNumber": "1000118216"  '  + 
                                                '         }  '  + 
                                                '       ]  '  + 
                                                '     },  '  + 
                                                '     "AckResponse": null  '  + 
                                                '  }  ' ; 
    public static final String sAssisterAuthRepClientDetails ='   {  '  + 
                                                '     "viewName": "AssisterAuthRepClientDetails",  '  + 
                                                '     "caseNumber": 0,  '  + 
                                                '     "primaryApplicantIndividualId": "890010089",  '  + 
                                                '     "programCode": "MA",  '  + 
                                                '     "mode": "RAC",  '  + 
                                                '     "role": "assister",  '  + 
                                                '     "Payload": {  '  + 
                                                '       "AuthrepandAssiterClientInfo": {  '  + 
                                                '         "RoleType": "ASSISTER",  '  + 
                                                '         "UserId": "366",  '  + 
                                                '         "OrganizationId": "4",  '  + 
                                                '         "FirstName": "SASFAS",  '  + 
                                                '         "LastName": "SFASF",  '  + 
                                                '         "MiddleName": "ASDF",  '  + 
                                                '         "Suffix": "Mr.",  '  + 
                                                '         "SSN": "1234",  '  + 
                                                '         "Gender": "M",  '  + 
                                                '         "Birthdate": "2020-02-05",  '  + 
                                                '         "OrganizationName": "XDF DFDS",  '  + 
                                                '         "OrgranizationIdentificationNumber": "123424",  '  + 
                                                '         "Phone": "34521242434",  '  + 
                                                '         "Email": "test@test.com",  '  + 
                                                '         "Street": "Norway street",  '  + 
                                                '         "AddressLine2": "SAF ASF ASDF",  '  + 
                                                '         "SSP_State": "Mizoram",  '  + 
                                                '         "CountyCode": "IN",  '  + 
                                                '         "Zipcode5": "12342",  '  + 
                                                '         "PreferredLanguageCode": "EN",  '  + 
                                                '         "PrimaryPhoneExtension": "1234",  '  + 
                                                '         "DCRepresentativeId": "1234",  '  + 
                                                '         "RepresentativeRelationshipCode": "123",  '  + 
                                                '         "ProgramsApplied": "MA",  '  + 
                                                '         "isAuthRepVerified": "Y",  '  + 
                                                '         "CaseNumber": "100044211",  '  + 
                                                '         "PermissionLevelMedicaid": "Y",  '  + 
                                                '         "PermissionLevelSNAP": "Y",  '  + 
                                                '         "PermissionLevelStateSupp": "Y",  '  + 
                                                '         "PermissionLevelKIHIPP": "Y",  '  + 
                                                '         "PermissionLevelCCAP": "Y",  '  + 
                                                '         "PermissionLevelKTAP": "Y"  '  + 
                                                '       },  '  + 
                                                '       "CaseInfo": {  '  + 
                                                '         "CaseNumber": "100044211",  '  + 
                                                '         "ProgramCode": "KT",  '  + 
                                                '         "LastUpdatedDate": "2018-11-02",  '  + 
                                                '         "FirstName": "HARRY",  '  + 
                                                '         "LastName": "POTTER",  '  + 
                                                '         "Email": "harry@gmail.coo",  '  + 
                                                '         "PrimaryPhoneNumber": "4538564850",  '  + 
                                                '         "PrimaryPhoneExetnsion": "12",  '  + 
                                                '         "PrimaryPhoneTypeCode": "CE",  '  + 
                                                '         "SecondaryPhoneNumber": "040",  '  + 
                                                '         "SecondaryPhoneExtension": "123",  '  + 
                                                '         "SecondaryPhoneTypeCode": "CE",  '  + 
                                                '         "PreferredNotificationMethodCode": "P",  '  + 
                                                '         "PreferredWrittenLanguageCode": "1",  '  + 
                                                '         "PreferredSpokenLanguageCode": "1"  '  + 
                                                '       }  '  + 
                                                '     }  '  + 
                                                '   }  '  + 
                                                '    ' ; 
    public static final String sNonCitizenSearchExport =      '   {  '  + 
                                                '     "viewName": "NonCitizenSearchExport",  '  + 
                                                '     "caseNumber": 0,  '  + 
                                                '     "primaryApplicantIndividualId": 0,  '  + 
                                                '     "individualIds": "",  '  + 
                                                '     "programCode": "",  '  + 
                                                '     "mode": "",  '  + 
                                                '     "applicationID": "",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "role": "",  '  + 
                                                '     "Payload": {  '  + 
                                                '       "CaseInfo": [  '  + 
                                                '         {  '  + 
                                                '           "CaseNumber": "100061579,100061581,100061582",  '  + 
                                                '           "IndividualId": "100375482",  '  + 
                                                '           "FirstName": "BOMKBNDK",  '  + 
                                                '           "MiddleInitial": "A",  '  + 
                                                '           "LastName": "DLKGHOSH",  '  + 
                                                '           "Suffix": "SR",  '  + 
                                                '           "GenderCode": "M",  '  + 
                                                '           "BirthDate": "1986-04-26",  '  + 
                                                '           "AddressLine1": "SDFSDF",  '  + 
                                                '           "AddressLine2": "SDFSDF",  '  + 
                                                '           "ZipCode": "12342",  '  + 
                                                '           "SSN": "12342",  '  + 
                                                '           "EmailAddress": "test@test.com",  '  + 
                                                '           "PhoneNumber": "0102030223",  '  + 
                                                '           "AssistedbyAuthRep": "aSDFS ASDF",  '  + 
                                                '           "AssistedbyAsister": "ASDFASDF SDF",  '  + 
                                                '           "AssisterName": "ASDFASDF ASDF",  '  + 
                                                '           "AssignmentStartDate": "2020-08-09",  '  + 
                                                '           "ClientRole": "HeadOfHousehold,HeadOfHousehold,HeadOfHousehold",  '  + 
                                                '           "RFIDueDate": "2020-07-24",  '  + 
                                                '           "NumberofRFI": "2",  '  + 
                                                '           "RenewalDueDate": "2021-03-31",  '  + 
                                                '           "ProgramDueRenewal": "MA",  '  + 
                                                '           "MCOEnrollmentStatus": "PE",  '  + 
                                                '           "CaseStatus": "AP,PE,PE",  '  + 
                                                '           "SubmittedDate": "2020-04-25",  '  + 
                                                '           "LastupdatedDate": "2020-04-25",  '  + 
                                                '           "MaidCardNumber": "1000134546"  '  + 
                                                '         }  '  + 
                                                '       ]  '  + 
                                                '     },  '  + 
                                                '     "AckResponse": null  '  + 
                                                '   }  '  + 
                                                '    ' ;
    public static final String sWaiverDetails =  		          '   {  '  + 
                                                '     "viewName": "WaiverDetails",  '  + 
                                                '     "caseNumber": 0,  '  + 
                                                '     "primaryApplicantIndividualId": "999037103",  '  + 
                                                '     "individualIds": "999037103",  '  + 
                                                '     "programCode": "",  '  + 
                                                '     "mode": "",  '  + 
                                                '     "applicationID": "",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "KeyValueParameters": null,  '  + 
                                                '     "role": "",  '  + 
                                                '     "Payload": {  '  + 
                                                '       "WaiverDetails": [  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999038009",  '  + 
                                                '           "WaiverScreeningId": "12926",  '  + 
                                                '           "IndividualName": "BKLFHKUCHBIHI KARLOGEHKYB",  '  + 
                                                '           "HasBrainInjury": "N",  '  + 
                                                '           "IsVentilatorDependent": "N",  '  + 
                                                '           "RequireAssistance": "N",  '  + 
                                                '           "HasDevelopmentalDisability": "N",  '  + 
                                                '           "WillContinueServices": "N"  '  + 
                                                '         }  '  + 
                                                '       ],  '  + 
                                                '       "WaiverStatuses": [  '  + 
                                                '         {  '  + 
                                                '           "WavierCaseNumber": "100013749",  '  + 
                                                '           "WaiverCaseStatus": "ACT",  '  + 
                                                '           "ProgramStatusCode": "CLDIS",  '  + 
                                                '           "ProgramCode": "ABI",  '  + 
                                                '           "IndividualId": "1250001832",  '  + 
                                                '           "ApplicationNumber": "200009399",  '  + 
                                                '           "ApplicationStatus": "SAV",  '  + 
                                                '           "IndividualName": "XXASF ASFA"  '  + 
                                                '         }  '  + 
                                                '       ]  '  + 
                                                '     }  '  + 
                                                '   }  '  + 
                                                '    ' ;
    public static final String sClaimsOverview =              '   {  '  + 
                                                '     "viewName": "ClaimsOverview",  '  + 
                                                '     "caseNumber": 0,  '  + 
                                                '     "primaryApplicantIndividualId": 999034376,  '  + 
                                                '     "individualIds": "",  '  + 
                                                '     "programCode": "",  '  + 
                                                '     "mode": "",  '  + 
                                                '     "applicationID": "",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "role": "",  '  + 
                                                '     "KeyValueParameters": null,  '  + 
                                                '     "Payload": {  '  + 
                                                '       "ClaimsOverview": {  '  + 
                                                '         "IndividualId": "830008781",  '  + 
                                                '         "IndividualName": "STEPHEN ALLEN",  '  + 
                                                '         "ClaimNumber": "1000004512",  '  + 
                                                '         "DueDate": "2018-02-21",  '  + 
                                                '         "CurrentAmountOwed": "170",  '  + 
                                                '         "RepaymentAmount": "400",  '  + 
                                                '         "ClaimStatus": "UN",  '  + 
                                                '         "ProgramCode": "MA"  '  + 
                                                '       }  '  + 
                                                '     }  '  + 
                                                '   }  '  + 
                                                '    ' ; 
    public static final String sNotificationInformation =     '   {  '  + 
                                                '     "viewName": "NotificationInformation",  '  + 
                                                '     "caseNumber": 0,  '  + 
                                                '     "primaryApplicantIndividualId": "999037103",  '  + 
                                                '     "individualIds": "",  '  + 
                                                '     "programCode": "",  '  + 
                                                '     "mode": "",  '  + 
                                                '     "applicationID": "",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "KeyValueParameters": null,  '  + 
                                                '     "Payload": {  '  + 
                                                '       "SSP_Notifications__c": [  '  + 
                                                '         {  '  + 
                                                '           "Benefind_Id__c": "System Notification,652",  '  + 
                                                '           "messageSubject__c": "Authorized Representative Association",  '  + 
                                                '           "messageSubjectES__c": "test",  '  + 
                                                '           "notificationCode__c": "NOT-016",  '  + 
                                                '           "Notification_Body__c": "test test has been added as your Authorized Representative. You may remove this association by visiting the Reps, Assisters, &amp; Agents section from your Benefind dashboard or by calling DCBS at 1-855-306-8959.",  '  + 
                                                '           "Notification_Body_Es__c": "test test ha sido agregado como su representante autorizado. Usted puede eliminar esta asociaciÃƒÂ³n visitando la secciÃƒÂ³n Representantes, asistentes y agentes en su panel de Benefind o llamando a DCBS al 1-855-306-8959.",  '  + 
                                                '           "DueDate__c": "",  '  + 
                                                '           "Expiry_Date__c": "2020-06-23",  '  + 
                                                '           "RecordType": {  '  + 
                                                '             "Name": "System Notification"  '  + 
                                                '           },  '  + 
                                                '           "recipientId__c": "999037103",  '  + 
                                                '           "recipientType__c": "Citizen",  '  + 
                                                '           "dmsDocumentId__c": "12323",  '  + 
                                                '           "MessageCreateDate__c": "2020-06-13T00:12:23",  '  + 
                                                '           "Severity__c": "Normal",  '  + 
                                                '           "Status__c": "Active",  '  + 
                                                '           "Case_Number__c": "",  '  + 
                                                '           "Program_Code__c": "KT"  '  + 
                                                '         }  '  + 
                                                '       ]  '  + 
                                                '     }  '  + 
                                                '  }  ' ; 
    public static final String sKHIPPPaymentSummary =         '   {  '  + 
                               '              '+
                               '        "viewName": "KHIPPPaymentSummary",      '+
                               '        "caseNumber": 0,      '+
                               '        "primaryApplicantIndividualId": "920051584",      '+
                               '        "individualIds": "",      '+
                               '        "programCode": "",      '+
                               '        "mode": "",      '+
                               '        "applicationID": "",      '+
                               '        "miscelleanousParameter": "",      '+
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
                               '        "TotalPremium": null,      '+
                               '        "Adjustment": "100"      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "ReimbursedMonth_Year": "Oct 2019",      '+
                               '        "TotalAmount": "97",      '+
                               '        "TotalPremium": "147",      '+
                               '        "Adjustment": "-50"      '+
                               '        }      '+
                               '        ],      '+
                               '        "PremiumDetails": [      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Nov 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "ApprovedPremium": "50",      '+
                               '        "ElectiveAbortion": "-1"      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Oct 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "ApprovedPremium": "50",      '+
                               '        "ElectiveAbortion": "-1"      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Sep 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "ApprovedPremium": "50",      '+
                               '        "ElectiveAbortion": "-1"      '+
                               '        }      '+
                               '        ],      '+
                               '        "AdjustmentDetails": [      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101797",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Aug 2019",      '+
                               '        "ReimbursedDate": "2019-06-06",      '+
                               '        "AdjustmentAmount": "50",      '+
                               '        "Reason": null      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101797",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Jul 2019",      '+
                               '        "ReimbursedDate": "2019-06-06",      '+
                               '        "AdjustmentAmount": "50",      '+
                               '        "Reason": null      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Nov 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "AdjustmentAmount": "-2",      '+
                               '        "Reason": "Benefit Recovery Claim"      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Oct 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "AdjustmentAmount": "50",      '+
                               '        "Reason": null      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Oct 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "AdjustmentAmount": "-49",      '+
                               '        "Reason": "Benefit Recovery Claim"      '+
                               '        },      '+
                               '        {      '+
                               '        "CaseNumber": "100062418",      '+
                               '        "IndividualId": "920051584",      '+
                               '        "KHIPPFinalPaymentId": "1000101799",      '+
                               '        "IndividualName": "ABCONE",      '+
                               '        "BenefitMonth_Year": "Sep 2019",      '+
                               '        "ReimbursedDate": "2019-10-01",      '+
                               '        "AdjustmentAmount": "-49",      '+
                               '        "Reason": "Benefit Recovery Claim"      '+
                               '        }      '+
                               '        ]      '+
                               '        }      '+
                               '        }      ';
    public static final String sRACSelectionDetails =         '   {  '  + 
                               '       "viewName": "RACSelectionDetails",  '  + 
                               '       "caseNumber": "100163899",  '  + 
                               '       "primaryApplicantIndividualId": "1250002361",  '  + 
                               '       "individualIds": "1250002361;1250002362",  '  + 
                               '       "programCode": "",  '  + 
                               '       "mode": "RAC",  '  + 
                               '       "applicationID": "a2Ur0000000GjYaEAK",  '  + 
                               '       "miscelleanousParameter": "",  '  + 
                               '       "role": "",  '  + 
                               '       "Payload": {  '  + 
                               '           "SSPMember": [  '  + 
                               '               {  '  + 
                               '                   "IndividualId": "810188876",  '  + 
                               '                   "FullName": "PNIXOKIXNKJZBLY WQPEVAQEINCHSEEFKAIQ",  '  + 
                               '                   "BirthDate": "2008-11-23",  '  + 
                               '                   "IsReceivingMedicareBenefitToggle": "N",  '  + 
                               '                   "IsUSCitizenToggle": "N",  '  + 
                               '                   "HasEmergencyMedicalConditionToggle": "N",  '  + 
                               '                   "IsRecoveryFromIllnessOrInjuryToggle": "N",  '  + 
                               '                   "IsDisabledToggle": "N",  '  + 
                               '                   "IsBlindToggle": "N",  '  + 
                               '                   "IsPregnantInLastThreeMonthsToggle": null,  '  + 
                               '                   "GenderCode": "M",  '  + 
                               '                   "TemporarilyLivesElsewhereToggle": "Y",  '  + 
                               '                   "InHomeCareType": "NA",  '  + 
                               '                   "IsEnrolledInSchool": null  '  + 
                               '               }  '  + 
                               '           ],  '  + 
                               '           "Income": [  '  + 
                               '               {  '  + 
                               '                   "IncomeTypeCode": "SRP",  '  + 
                               '                   "IncomeSubtypeCode": "SI",  '  + 
                               '                   "IncomePayFrequency": "MO",  '  + 
                               '                   "TotalGrossAmount": "440.00",  '  + 
                               '                   "EmployerName": null,  '  + 
                               '                   "BusinessTypeCode": null,  '  + 
                               '                   "IncomePayDetailHoursPerWeek": null,  '  + 
                               '                   "IndividualId": "810188876",  '  + 
                               '                   "FullName": "PNIXOKIXNKJZBLY WQPEVAQEINCHSEEFKAIQ"  '  + 
                               '               }  '  + 
                               '           ],  '  + 
                               '           "Healthcare": null  '  + 
                               '       },  '  + 
                               '       "AckResponse": null  '  + 
                               '  }  ' ; 
    public static final String sDashboardCaseInformation =    '   {  '  + 
                                   '            "viewName": "DashboardCaseInformation",      '+
                                   '            "caseNumber": "100059260",      '+
                                   '            "primaryApplicantIndividualId": "999034247",      '+
                                   '            "individualIds": "999033177;999034248;999034249;999034250",      '+
                                   '            "programCode": "MA;KT;SN",      '+
                                   '            "mode": "RAC",      '+
                                   '            "applicationID": null,      '+
                                   '            "miscelleanousParameter": null,      '+
                                   '            "Payload": {      '+
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
                                   '                  "SNAPClaimAmount": null      '+
                                   '                },      '+
                                   '                {      '+
                                   '                  "CaseNumber": "100061299",      '+
                                   '                  "IsHeadOfHousehold": "Y",      '+
                                   '                  "RFICount": null,      '+
                                   '                  "IsInRenewalPeriod": "N",      '+
                                   '                  "IsRACEnabled": "Y",      '+
                                   '                  "SNAPClaimAmount": null      '+
                                   '                }      '+
                                   '              ]      '+
                                   '            }      '+
                                   '        }      ';     
    public static final String sTaxForms1095AInformation =    '   {  '  + 
                                                        '     "viewName": "1095ATaxFormsinformation",  '  + 
                                                        '     "caseNumber": 100073537,  '  + 
                                                        '     "primaryApplicantIndividualId": "",  '  + 
                                                        '     "individualIds": "",  '  + 
                                                        '     "programCode": "",  '  + 
                                                        '     "mode": "",  '  + 
                                                        '     "applicationID": "",  '  + 
                                                        '     "miscelleanousParameter": "",  '  + 
                                                        '     "role": "",  '  + 
                                                        '     "KeyValueParameters": null,  '  + 
                                                        '     "Payload": {  '  + 
                                                        '       "ReqTaxFormsYears": [  '  + 
                                                        '         {  '  + 
                                                        '           "Year": "2017"  '  + 
                                                        '         }  '  + 
                                                        '       ],  '  + 
                                                        '       "ReqTaxFormsEnrollmentDetail": [  '  + 
                                                        '         {  '  + 
                                                        '           "CaseNumber": "100073537",  '  + 
                                                        '           "PlanEnrollmentId": "1000018433",  '  + 
                                                        '           "PlanName": "Catastrophic Compass 6850",  '  + 
                                                        '           "Year": "2016"  '  + 
                                                        '         }  '  + 
                                                        '       ]  '  + 
                                                        '     }  '  + 
                                                        '  }  ' ; 
    public static final String sPastApplications =            '   {  '  + 
                                                        '     "viewName": "PastApplications",  '  + 
                                                        '     "caseNumber": 0,  '  + 
                                                        '     "primaryApplicantIndividualId": "999034376",  '  + 
                                                        '     "individualIds": "",  '  + 
                                                        '     "programCode": "",  '  + 
                                                        '     "mode": "",  '  + 
                                                        '     "applicationID": "",  '  + 
                                                        '     "miscelleanousParameter": "",  '  + 
                                                        '     "KeyValueParameters": null,  '  + 
                                                        '     "Payload": {  '  + 
                                                        '       "PastApplications": [  '  + 
                                                        '         {  '  + 
                                                        '           "IndividualId": 999034376,  '  + 
                                                        '           "CaseNumber": 100060277,  '  + 
                                                        '           "CaseStatusCode": "PE",  '  + 
                                                        '           "ApplicationNumber": 400142046,  '  + 
                                                        '           "ApplicationReceivedDate": "2020-02-12",  '  + 
                                                        '           "ProgramAppliedFor": "MA;SN",  '  + 
                                                        '           "DMSId": "D9243347-7AB0-0835-F05E-39F34DBA6A34",  '  + 
                                                        '           "IsAgreeingToMedicaidPenalty": "Y",  '  + 
                                                        '           "IsAgreeingToLTCResourceTransferConsent": "Y",  '  + 
                                                        '           "IsRenewalConsent": "Y",  '  + 
                                                        '           "IsApplicantAgreeToWorkRegister": "Y",  '  + 
                                                        '           "IsRegisteredToVote": "N",  '  + 
                                                        '           "DeclrtnfAnnuitiesAcceptanceCode": "Y",  '  + 
                                                        '           "IsDMSAnnuitiesBeneficiary": "Y"  '  + 
                                                        '         }  '  + 
                                                        '       ]  '  + 
                                                        '     }  '  + 
                                                        '   }  '  + 
                                                        '    ' ; 
    public static final String sKIHIPPpreferredPayment =      '   {  '  + 
                                                        '     "viewName": "KIHIPPPreferredPayment",  '  + 
                                                        '     "caseNumber": 0,  '  + 
                                                        '     "individualIds": "919219816",  '  + 
                                                        '     "primaryApplicantIndividualId": "",  '  + 
                                                        '     "programCode": "",  '  + 
                                                        '     "mode": "",  '  + 
                                                        '     "applicationID": "",  '  + 
                                                        '     "miscelleanousParameter": "",  '  + 
                                                        '     "KeyValueParameters": null,  '  + 
                                                        '     "Payload": {  '  + 
                                                        '       "KIHIPPPreferredPayment": {  '  + 
                                                        '         "IndividualId": "919219816",  '  + 
                                                        '         "FirstName": "ONE",  '  + 
                                                        '         "LastName": "KHIPPTEST",  '  + 
                                                        '         "MiddleInitial": "X",  '  + 
                                                        '         "SuffixCode": "Jr.",  '  + 
                                                        '         "PreferredIssuanceMethod": "EFT",  '  + 
                                                        '         "RoutingNumber": "011001331",  '  + 
                                                        '         "CheckingAccountNumber": "123456789",  '  + 
                                                        '         "MailingAddressLine1": "ADD1",  '  + 
                                                        '         "MailingAddressLine2": "SADFASDF SDF",  '  + 
                                                        '         "MailingCity": "KY",  '  + 
                                                        '         "MailingCountyCode": "002",  '  + 
                                                        '         "MailingStateCode": "KY",  '  + 
                                                        '         "MailingZipCode5": "92318"  '  + 
                                                        '       }  '  + 
                                                        '     }  '  + 
                                                        '   }  '  + 
                                                        '    ' ; 
    public static final String sHearingSummaryInformation =   '   {  '  + 
                                                        '     "viewName": "HearingsSummaryInformation",  '  + 
                                                        '     "caseNumber": "0",  '  + 
                                                        '     "primaryApplicantIndividualId": "919219536;919218728",  '  + 
                                                        '     "programCode": "MA",  '  + 
                                                        '     "mode": "RAC",  '  + 
                                                        '     "Payload": {  '  + 
                                                        '       "HearingSummary": [  '  + 
                                                        '         {  '  + 
                                                        '           "CaseNumber": "100373492",  '  + 
                                                        '           "HearingId": "FC1003808",  '  + 
                                                        '           "RequestId": "1003808",  '  + 
                                                        '           "HearingReason": "INCR",  '  + 
                                                        '           "HearingType": "SDF",  '  + 
                                                        '           "HearingProgram": "MEDCD",  '  + 
                                                        '           "HearingDate": "2020-01-14",  '  + 
                                                        '           "HearingStatus": "HO",  '  + 
                                                        '           "IndividualId": "919218728"  '  + 
                                                        '         }  '  + 
                                                        '       ],  '  + 
                                                        '       "PreferredDetails": [  '  + 
                                                        '         {  '  + 
                                                        '           "FirstName": "kiieyjhe",  '  + 
                                                        '           "LastName": "evdhev",  '  + 
                                                        '           "MiddleInitial": "M",  '  + 
                                                        '           "City": "Louisville",  '  + 
                                                        '           "StateCode": "KY",  '  + 
                                                        '           "AddressLine1": "937, Phillips Lane, Highland Park",  '  + 
                                                        '           "CountyCode": "056",  '  + 
                                                        '           "Email": "Test@test.com",  '  + 
                                                        '           "GenderCode": "M",  '  + 
                                                        '           "PrimaryPhoneExtension": "01",  '  + 
                                                        '           "PrimaryPhoneNumber": "7373783883",  '  + 
                                                        '           "PrimaryPhoneTypeCode": "012",  '  + 
                                                        '           "ZipCode4": "2432",  '  + 
                                                        '           "ZipCode5": "40209"  '  + 
                                                        '         }  '  + 
                                                        '       ]  '  + 
                                                        '     }  '  + 
                                                        '   }  '  + 
                                                        '    ' ; 
}