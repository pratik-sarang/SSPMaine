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
  public static final String sIncomeInformation =           
  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_Application__c" : null,  '  + 
  '       "SSP_Benefits__c" : null,  '  + 
  '       "SSP_Asset__c" : [ {  '  + 
  '         "Is_Interface_Inserted__c" : false,  '  + 
  '         "DCAssetId__c" : "Income,17911985",  '  + 
  '         "EndDate__c" : null,  '  + 
  '         "ExpenseAmount__c" : null,  '  + 
  '         "IncomePayDetailHoursPerWeek__c" : null,  '  + 
  '         "Tips__c" : null,  '  + 
  '         "TotalGrossAmount__c" : "150.00",  '  + 
  '         "IncomePayFrequency__c" : "MO",  '  + 
  '         "IsUnempBenefitsRequiredToggle__c" : null,  '  + 
  '         "IsSchoolDegreeRequiredToggle__c" : null,  '  + 
  '         "ActivityStartDate__c" : null,  '  + 
  '         "ActivityType__c" : null,  '  + 
  '         "BusinessTitle__c" : null,  '  + 
  '         "BusinessTypeCode__c" : null,  '  + 
  '         "PrimaryPhoneExtension__c" : null,  '  + 
  '         "PrimaryPhoneNumber__c" : null,  '  + 
  '         "CountyCode__c" : null,  '  + 
  '         "ZipCode5__c" : null,  '  + 
  '         "ZipCode4__c" : null,  '  + 
  '         "StateCode__c" : null,  '  + 
  '         "City__c" : null,  '  + 
  '         "AddressLine2__c" : null,  '  + 
  '         "AddressLine1__c" : null,  '  + 
  '         "EIN__c" : null,  '  + 
  '         "EmployerName__c" : null,  '  + 
  '         "IncomeSubtypeCode__c" : "CS",  '  + 
  '         "IncomeTypeCode__c" : "SM",  '  + 
  '         "DCUnearnedIncomeDetailId__c" : 1533265,  '  + 
  '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
  '         "DCId__c" : 17911985,  '  + 
  '         "DCEmploymentDetailId__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Income"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "Is_Interface_Inserted__c" : false,  '  + 
  '         "DCAssetId__c" : "Income,17912004",  '  + 
  '         "EndDate__c" : null,  '  + 
  '         "ExpenseAmount__c" : null,  '  + 
  '         "IncomePayDetailHoursPerWeek__c" : null,  '  + 
  '         "Tips__c" : null,  '  + 
  '         "TotalGrossAmount__c" : "150.00",  '  + 
  '         "IncomePayFrequency__c" : "MO",  '  + 
  '         "IsUnempBenefitsRequiredToggle__c" : null,  '  + 
  '         "IsSchoolDegreeRequiredToggle__c" : null,  '  + 
  '         "ActivityStartDate__c" : null,  '  + 
  '         "ActivityType__c" : null,  '  + 
  '         "BusinessTitle__c" : null,  '  + 
  '         "BusinessTypeCode__c" : null,  '  + 
  '         "PrimaryPhoneExtension__c" : null,  '  + 
  '         "PrimaryPhoneNumber__c" : null,  '  + 
  '         "CountyCode__c" : null,  '  + 
  '         "ZipCode5__c" : null,  '  + 
  '         "ZipCode4__c" : null,  '  + 
  '         "StateCode__c" : null,  '  + 
  '         "City__c" : null,  '  + 
  '         "AddressLine2__c" : null,  '  + 
  '         "AddressLine1__c" : null,  '  + 
  '         "EIN__c" : null,  '  + 
  '         "EmployerName__c" : null,  '  + 
  '         "IncomeSubtypeCode__c" : "CS",  '  + 
  '         "IncomeTypeCode__c" : "SM",  '  + 
  '         "DCUnearnedIncomeDetailId__c" : 1533271,  '  + 
  '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
  '         "DCId__c" : 17912004,  '  + 
  '         "DCEmploymentDetailId__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Income"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "Is_Interface_Inserted__c" : false,  '  + 
  '         "DCAssetId__c" : "Income,18648733",  '  + 
  '         "EndDate__c" : null,  '  + 
  '         "ExpenseAmount__c" : null,  '  + 
  '         "IncomePayDetailHoursPerWeek__c" : 40,  '  + 
  '         "Tips__c" : null,  '  + 
  '         "TotalGrossAmount__c" : "1180.40",  '  + 
  '         "IncomePayFrequency__c" : "WE",  '  + 
  '         "IsUnempBenefitsRequiredToggle__c" : null,  '  + 
  '         "IsSchoolDegreeRequiredToggle__c" : null,  '  + 
  '         "ActivityStartDate__c" : null,  '  + 
  '         "ActivityType__c" : null,  '  + 
  '         "BusinessTitle__c" : null,  '  + 
  '         "BusinessTypeCode__c" : null,  '  + 
  '         "PrimaryPhoneExtension__c" : "",  '  + 
  '         "PrimaryPhoneNumber__c" : "0113711289",  '  + 
  '         "CountyCode__c" : null,  '  + 
  '         "ZipCode5__c" : "02703",  '  + 
  '         "ZipCode4__c" : null,  '  + 
  '         "StateCode__c" : "KY",  '  + 
  '         "City__c" : "SNFCWYJGH",  '  + 
  '         "AddressLine2__c" : null,  '  + 
  '         "AddressLine1__c" : "3026 UTAMKYCL KZA EMB 632",  '  + 
  '         "EIN__c" : null,  '  + 
  '         "EmployerName__c" : "SQLN",  '  + 
  '         "IncomeSubtypeCode__c" : null,  '  + 
  '         "IncomeTypeCode__c" : "EA",  '  + 
  '         "DCUnearnedIncomeDetailId__c" : null,  '  + 
  '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
  '         "DCId__c" : 18648733,  '  + 
  '         "DCEmploymentDetailId__c" : "3029046",  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Income"  '  + 
  '         }  '  + 
  '       } ],  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "HasIncomefromGamblingorLotteryToggle__c" : null,  '  + 
  '         "HasReceivedBenefitsFromOtherStateToggle__c" : null,  '  + 
  '         "HasUnpaidEmploymentToggle__c" : null,  '  + 
  '         "HasUnearnedIncomeToggle__c" : null,  '  + 
  '         "HasMaintenanceIncomeToggle__c" : "Y",  '  + 
  '         "HasInsuranceSettlementBenefitToggle__c" : null,  '  + 
  '         "HasServicesorPaymentsToggle__c" : null,  '  + 
  '         "HasDividendsRoyaltiesToggle__c" : null,  '  + 
  '         "HasSelfEmploymentIncomeToggle__c" : null,  '  + 
  '         "HasEarnedIncomeFromEmploymentToggle__c" : null,  '  + 
  '         "IndividualId__c" : "101227474"  '  + 
  '       }, {  '  + 
  '         "HasIncomefromGamblingorLotteryToggle__c" : null,  '  + 
  '         "HasReceivedBenefitsFromOtherStateToggle__c" : null,  '  + 
  '         "HasUnpaidEmploymentToggle__c" : null,  '  + 
  '         "HasUnearnedIncomeToggle__c" : null,  '  + 
  '         "HasMaintenanceIncomeToggle__c" : "Y",  '  + 
  '         "HasInsuranceSettlementBenefitToggle__c" : null,  '  + 
  '         "HasServicesorPaymentsToggle__c" : null,  '  + 
  '         "HasDividendsRoyaltiesToggle__c" : null,  '  + 
  '         "HasSelfEmploymentIncomeToggle__c" : null,  '  + 
  '         "HasEarnedIncomeFromEmploymentToggle__c" : null,  '  + 
  '         "IndividualId__c" : "101227475"  '  + 
  '       }, {  '  + 
  '         "HasIncomefromGamblingorLotteryToggle__c" : null,  '  + 
  '         "HasReceivedBenefitsFromOtherStateToggle__c" : null,  '  + 
  '         "HasUnpaidEmploymentToggle__c" : null,  '  + 
  '         "HasUnearnedIncomeToggle__c" : null,  '  + 
  '         "HasMaintenanceIncomeToggle__c" : null,  '  + 
  '         "HasInsuranceSettlementBenefitToggle__c" : null,  '  + 
  '         "HasServicesorPaymentsToggle__c" : null,  '  + 
  '         "HasDividendsRoyaltiesToggle__c" : null,  '  + 
  '         "HasSelfEmploymentIncomeToggle__c" : null,  '  + 
  '         "HasEarnedIncomeFromEmploymentToggle__c" : "Y",  '  + 
  '         "IndividualId__c" : "101272217"  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "IncomeInformation"  '  + 
  '  }  ' ; 
  
  public static final String sExpenseInformation =         
  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "IsCoverageMonth3__c" : 0,  '  + 
  '         "IsCoverageMonth2__c" : 0,  '  + 
  '         "IsCoverageMonth1__c" : 0,  '  + 
  '         "HasDependentCareExpenseToggle__c" : null,  '  + 
  '         "HasHouseholdPaidChildSupportToggle__c" : null,  '  + 
  '         "HasDisabledExpensesToggle__c" : null,  '  + 
  '         "HasMedicalExpensePartDToggle__c" : null,  '  + 
  '         "HasAlimonyExpenseToggle__c" : null,  '  + 
  '         "HasTaxDeductionsExpenseToggle__c" : null,  '  + 
  '         "HaveHigherEducationExpenseToggle__c" : null,  '  + 
  '         "HasUtilityExpenseToggle__c" : null,  '  + 
  '         "HasShelterExpenseToggle__c" : null,  '  + 
  '         "HasMedicalBillsToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "IsCoverageMonth3__c" : 0,  '  + 
  '         "IsCoverageMonth2__c" : 0,  '  + 
  '         "IsCoverageMonth1__c" : 0,  '  + 
  '         "HasDependentCareExpenseToggle__c" : null,  '  + 
  '         "HasHouseholdPaidChildSupportToggle__c" : null,  '  + 
  '         "HasDisabledExpensesToggle__c" : null,  '  + 
  '         "HasMedicalExpensePartDToggle__c" : null,  '  + 
  '         "HasAlimonyExpenseToggle__c" : null,  '  + 
  '         "HasTaxDeductionsExpenseToggle__c" : null,  '  + 
  '         "HaveHigherEducationExpenseToggle__c" : null,  '  + 
  '         "HasUtilityExpenseToggle__c" : null,  '  + 
  '         "HasShelterExpenseToggle__c" : null,  '  + 
  '         "HasMedicalBillsToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "IsCoverageMonth3__c" : 0,  '  + 
  '         "IsCoverageMonth2__c" : 0,  '  + 
  '         "IsCoverageMonth1__c" : 0,  '  + 
  '         "HasDependentCareExpenseToggle__c" : null,  '  + 
  '         "HasHouseholdPaidChildSupportToggle__c" : null,  '  + 
  '         "HasDisabledExpensesToggle__c" : null,  '  + 
  '         "HasMedicalExpensePartDToggle__c" : null,  '  + 
  '         "HasAlimonyExpenseToggle__c" : null,  '  + 
  '         "HasTaxDeductionsExpenseToggle__c" : null,  '  + 
  '         "HaveHigherEducationExpenseToggle__c" : null,  '  + 
  '         "HasUtilityExpenseToggle__c" : null,  '  + 
  '         "HasShelterExpenseToggle__c" : "Y",  '  + 
  '         "HasMedicalBillsToggle__c" : "Y",  '  + 
  '         "IndividualId__c" : "101272217"  '  + 
  '       } ],  '  + 
  '       "SSP_Asset__c" : [ {  '  + 
  '         "DCAssetId__c" : "Expense,1291052",  '  + 
  '         "DependentIndividual__r" : null,  '  + 
  '         "DependentCareProvider__r" : null,  '  + 
  '         "ChildName__c" : null,  '  + 
  '         "MiscellaneousAmount__c" : null,  '  + 
  '         "FeesAmount__c" : null,  '  + 
  '         "BooksAmount__c" : null,  '  + 
  '         "TuitionAmount__c" : null,  '  + 
  '         "EndDate__c" : null,  '  + 
  '         "StartDate__c" : null,  '  + 
  '         "IsPaidToVendorToggle__c" : null,  '  + 
  '         "IsNonHouseHoldMemberPayingExpenseToggle__c" : null,  '  + 
  '         "ExpenseAmount__c" : 550.00,  '  + 
  '         "ExpenseFrequencyCode__c" : "MO",  '  + 
  '         "ExpenseSubType__c" : "RNT",  '  + 
  '         "ExpenseTypeCode__c" : "SE",  '  + 
  '         "DCId__c" : "1291052",  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "101272217"  '  + 
  '         },  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Expense"  '  + 
  '         }  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "ExpenseInformation"  '  + 
  '  }  ' ;  
  public static final String sAbsentParentInformation = 
  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_NonCustodialParent__c" : [ {  '  + 
  '         "AbsentParentVerificationCode__c" : 0,  '  + 
  '         "DCNonCustodialParentId__c" : "1101078",  '  + 
  '         "IsParentUnknown__c" : 0,  '  + 
  '         "SSN__c" : "987070126",  '  + 
  '         "GenderCode__c" : "M",  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "LastName__c" : "HLMJXTAY",  '  + 
  '         "MiddleInitial__c" : "",  '  + 
  '         "FirstName__c" : "CBENY",  '  + 
  '         "SSP_Member__r" : null  '  + 
  '       } ],  '  + 
  '       "SSP_NoncustodialRelationship__c" : [ {  '  + 
  '         "MedicalSupportComments__c" : null,  '  + 
  '         "HasChildSupportToggle__c" : "Y",  '  + 
  '         "GoodCauseCode__c" : null,  '  + 
  '         "DCNonCustodialRelationshipId__c" : "1194472",  '  + 
  '         "SSP_NonCustodialParent__r" : {  '  + 
  '           "DCNonCustodialParentId__c" : "1101078"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "MedicalSupportComments__c" : null,  '  + 
  '         "HasChildSupportToggle__c" : "Y",  '  + 
  '         "GoodCauseCode__c" : null,  '  + 
  '         "DCNonCustodialRelationshipId__c" : "1194481",  '  + 
  '         "SSP_NonCustodialParent__r" : {  '  + 
  '           "DCNonCustodialParentId__c" : "1101078"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "AbsentParentInformation"  '  + 
  '  }  ' ;  
  
  public static final String sHealthCoverageInformation =   
  

  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_Application__c" : [ {  '  + 
  '         "NotEnrolledInHealthCareCoverageToggle__c" : null,  '  + 
  '         "EnrolledInHealthCareCoverageToggle__c" : null  '  + 
  '       } ],  '  + 
  '       "SSP_HealthInsuranceFacilityType__c" : [ {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "1041796,101227475,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : "2299-12-31",  '  + 
  '         "CoverageStartDate__c" : "2014-12-01",  '  + 
  '         "FacilityType__c" : "HP",  '  + 
  '         "DCId__c" : "793736"  '  + 
  '       }, {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "1041796,101227475,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : "2299-12-31",  '  + 
  '         "CoverageStartDate__c" : "2014-12-01",  '  + 
  '         "FacilityType__c" : "HP",  '  + 
  '         "DCId__c" : "793737"  '  + 
  '       }, {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "2209393,101272217,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : null,  '  + 
  '         "CoverageStartDate__c" : "2019-01-01",  '  + 
  '         "FacilityType__c" : "MD",  '  + 
  '         "DCId__c" : "1975771"  '  + 
  '       }, {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "2261606,101272217,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : null,  '  + 
  '         "CoverageStartDate__c" : "2019-06-01",  '  + 
  '         "FacilityType__c" : "MD",  '  + 
  '         "DCId__c" : "2036873"  '  + 
  '       }, {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "2209393,101227475,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : null,  '  + 
  '         "CoverageStartDate__c" : "2019-01-01",  '  + 
  '         "FacilityType__c" : "MD",  '  + 
  '         "DCId__c" : "2038483"  '  + 
  '       }, {  '  + 
  '         "SSP_InsuranceCoveredIndiv__r" : {  '  + 
  '           "DCInsuranceCoveredIndivId__c" : "2209393,101227474,0"  '  + 
  '         },  '  + 
  '         "CoverageEndDate__c" : null,  '  + 
  '         "CoverageStartDate__c" : "2019-01-01",  '  + 
  '         "FacilityType__c" : "MD",  '  + 
  '         "DCId__c" : "2038484"  '  + 
  '       } ],  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "PreferredIssuanceMethod__c" : "CH",  '  + 
  '         "CheckingAccountNumber__c" : null,  '  + 
  '         "RoutingNumber__c" : null,  '  + 
  '         "BirthDate__c" : "1974-08-19",  '  + 
  '         "SSN__c" : "201749508",  '  + 
  '         "GenderCode__c" : "F",  '  + 
  '         "LastName__c" : "SQLN",  '  + 
  '         "FirstName__c" : "SQLN",  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       } ],  '  + 
  '       "SSP_InsuranceCoveredIndiv__c" : [ {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : "12791",  '  + 
  '         "ExtZipCode4__c" : "",  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : "QVK UPBZRVID",  '  + 
  '         "ExtAddressLine2__c" : "",  '  + 
  '         "ExtAddressLine1__c" : "QVK UPBZRVID",  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "1041796,248382,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance External Policy Holder"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : null,  '  + 
  '         "MedicaidId__c" : null,  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : null,  '  + 
  '         "DCId__c" : 248382,  '  + 
  '         "ExtPolicyHolderSSN__c" : "637009697",  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : "HLMJXTAY",  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : "",  '  + 
  '         "ExtPolicyHolderFirstName__c" : "CBENY",  '  + 
  '         "SSP_Member__r" : null,  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "1041796"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : null,  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "1041796,101227475,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : null,  '  + 
  '         "MedicaidId__c" : "0113514066",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : null,  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "1041796"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : null,  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "1041796,101227475,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : "3",  '  + 
  '         "MedicaidId__c" : "0113514066",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : null,  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "1041796"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : null,  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "2209393,101227474,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : "3",  '  + 
  '         "MedicaidId__c" : "0114680035",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : "Y",  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "2209393"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : "101272217",  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "2209393,101227475,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : "3",  '  + 
  '         "MedicaidId__c" : "0113514066",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : "Y",  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "2209393"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : "101272217",  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "2209393,101272217,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : "1",  '  + 
  '         "MedicaidId__c" : "0115605590",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : "Y",  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "2209393"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : "101272217",  '  + 
  '         "SSN__c" : null  '  + 
  '       }, {  '  + 
  '         "ExtCountyCode__c" : null,  '  + 
  '         "ExtZipCode5__c" : null,  '  + 
  '         "ExtZipCode4__c" : null,  '  + 
  '         "ExtStateCode__c" : null,  '  + 
  '         "ExtCity__c" : null,  '  + 
  '         "ExtAddressLine2__c" : null,  '  + 
  '         "ExtAddressLine1__c" : null,  '  + 
  '         "DCInsuranceCoveredIndivId__c" : "2261606,101272217,0",  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "Insurance Covered Individual"  '  + 
  '         },  '  + 
  '         "RelationshipCode__c" : "1",  '  + 
  '         "MedicaidId__c" : "0115605590",  '  + 
  '         "LastName__c" : null,  '  + 
  '         "FirstName__c" : null,  '  + 
  '         "DateOfBirth__c" : null,  '  + 
  '         "Gender__c" : null,  '  + 
  '         "IsTobbacoConsumerToggle__c" : "Y",  '  + 
  '         "DCId__c" : null,  '  + 
  '         "ExtPolicyHolderSSN__c" : null,  '  + 
  '         "SuffixCode__c" : null,  '  + 
  '         "ExtPolicyHolderLastName__c" : null,  '  + 
  '         "ExtPolicyHolderMiddleInitial__c" : null,  '  + 
  '         "ExtPolicyHolderFirstName__c" : null,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_InsurancePolicy__r" : {  '  + 
  '           "DCId__c" : "2261606"  '  + 
  '         },  '  + 
  '         "InsuranceInternalPolicyHolder__c" : "101272217",  '  + 
  '         "SSN__c" : null  '  + 
  '       } ],  '  + 
  '       "SSP_InsurancePolicy__c" : [ {  '  + 
  '         "EmployerName__c" : null,  '  + 
  '         "DCEmploymentDetailId__c" : null,  '  + 
  '         "IsHealthCareCoverageApproved__c" : 0,  '  + 
  '         "IsHealthCareCovPolicyHolderOutSideCase__c" : 0,  '  + 
  '         "EnrollmentTierLevel__c" : null,  '  + 
  '         "InsuranceGroupNumber__c" : "",  '  + 
  '         "InsurancePolicyNumber__c" : "RKP172X58567",  '  + 
  '         "PlanName__c" : null,  '  + 
  '         "PhysicalAddressLine2__c" : "",  '  + 
  '         "PhysicalZipCode5__c" : "12791",  '  + 
  '         "PhysicalZipCode4__c" : "",  '  + 
  '         "PhysicalStateCode__c" : null,  '  + 
  '         "PhysicalCountyCode__c" : null,  '  + 
  '         "PhysicalCountryCode__c" : "",  '  + 
  '         "PhysicalCity__c" : "QVK UPBZRVID",  '  + 
  '         "PhysicalAddressLine1__c" : "QVK UPBZRVID",  '  + 
  '         "InsuranceCompanyName__c" : "VYMP CDIUP LQJH QGIK",  '  + 
  '         "TypeOfCoverageCode__c" : "OT",  '  + 
  '         "IsEnrolledInInsurance__c" : 1,  '  + 
  '         "DCId__c" : "1041796"  '  + 
  '       }, {  '  + 
  '         "EmployerName__c" : "SQLN",  '  + 
  '         "DCEmploymentDetailId__c" : "2141870",  '  + 
  '         "IsHealthCareCoverageApproved__c" : 0,  '  + 
  '         "IsHealthCareCovPolicyHolderOutSideCase__c" : 0,  '  + 
  '         "EnrollmentTierLevel__c" : "EMTD",  '  + 
  '         "InsuranceGroupNumber__c" : "1206839",  '  + 
  '         "InsurancePolicyNumber__c" : "Zfxdkrk",  '  + 
  '         "PlanName__c" : "PPO Plan (CDHP)",  '  + 
  '         "PhysicalAddressLine2__c" : null,  '  + 
  '         "PhysicalZipCode5__c" : "72709",  '  + 
  '         "PhysicalZipCode4__c" : null,  '  + 
  '         "PhysicalStateCode__c" : "KY",  '  + 
  '         "PhysicalCountyCode__c" : null,  '  + 
  '         "PhysicalCountryCode__c" : "",  '  + 
  '         "PhysicalCity__c" : "Zfxdkrk",  '  + 
  '         "PhysicalAddressLine1__c" : "Zfxdkrk",  '  + 
  '         "InsuranceCompanyName__c" : "VympCdiup LqjhQgikol",  '  + 
  '         "TypeOfCoverageCode__c" : "EM",  '  + 
  '         "IsEnrolledInInsurance__c" : 1,  '  + 
  '         "DCId__c" : "2209393"  '  + 
  '       }, {  '  + 
  '         "EmployerName__c" : "SQLN",  '  + 
  '         "DCEmploymentDetailId__c" : "3029049",  '  + 
  '         "IsHealthCareCoverageApproved__c" : 0,  '  + 
  '         "IsHealthCareCovPolicyHolderOutSideCase__c" : 0,  '  + 
  '         "EnrollmentTierLevel__c" : null,  '  + 
  '         "InsuranceGroupNumber__c" : "1206878",  '  + 
  '         "InsurancePolicyNumber__c" : null,  '  + 
  '         "PlanName__c" : "BCBS-CDHP",  '  + 
  '         "PhysicalAddressLine2__c" : null,  '  + 
  '         "PhysicalZipCode5__c" : null,  '  + 
  '         "PhysicalZipCode4__c" : null,  '  + 
  '         "PhysicalStateCode__c" : null,  '  + 
  '         "PhysicalCountyCode__c" : null,  '  + 
  '         "PhysicalCountryCode__c" : "",  '  + 
  '         "PhysicalCity__c" : null,  '  + 
  '         "PhysicalAddressLine1__c" : null,  '  + 
  '         "InsuranceCompanyName__c" : "Vymp Cdiup Lqjh Qgikol",  '  + 
  '         "TypeOfCoverageCode__c" : "OT",  '  + 
  '         "IsEnrolledInInsurance__c" : 1,  '  + 
  '         "DCId__c" : "2261606"  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "HealthCoverageInformation"  '  + 
  '  }  ' ; 
    
  public static final String sHealthInformation =         
  
  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_ApplicationIndividual__c" : null,  '  + 
  '       "SSP_Application__c" : [ {  '  + 
  '         "HasPendingAccidentSettlementToggle__c" : "N"  '  + 
  '       } ],  '  + 
  '       "SSP_Benefits__c" : null,  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "DCRecoveryIllnessId__c" : null,  '  + 
  '         "DCEMCId__c" : null,  '  + 
  '         "IsReceivingCaretakerServicesToggle__c" : null,  '  + 
  '         "IsRequestingOrReceivingCISToggle__c" : null,  '  + 
  '         "BlindnessVerificationCode__c" : 0,  '  + 
  '         "UnableToBuyCookForSelfToggle__c" : null,  '  + 
  '         "DisabilityVerificationCode__c" : 0,  '  + 
  '         "TBQIndividualVerificationCode__c" : 0,  '  + 
  '         "DCMemberWorkReqExemptionId__c" : null,  '  + 
  '         "ReturnToWorkDate__c" : null,  '  + 
  '         "IsOnSickLeaveToggle__c" : null,  '  + 
  '         "RecoveryDate__c" : null,  '  + 
  '         "EmergencyEndDate__c" : null,  '  + 
  '         "EmergencyBeginDate__c" : null,  '  + 
  '         "BlindnessStatus__c" : null,  '  + 
  '         "BlindnessBenefitTypeCode__c" : null,  '  + 
  '         "BlindnessParentUnableToCareForChild__c" : null,  '  + 
  '         "BlindnessHasEndStageRenalDisease__c" : null,  '  + 
  '         "DisabilityStatus__c" : null,  '  + 
  '         "ParentUnableToCareForChildToggle__c" : null,  '  + 
  '         "HasEndStageRenalDiseaseToggle__c" : null,  '  + 
  '         "BenefitTypeCode__c" : null,  '  + 
  '         "IsToBeReferredToWicToggle__c" : null,  '  + 
  '         "PregnancyTerminationDate__c" : null,  '  + 
  '         "PregnancyDueDate__c" : null,  '  + 
  '         "NumberOfBirthsExpected__c" : null,  '  + 
  '         "IsPregnantToggle__c" : null,  '  + 
  '         "DCPregnancyId__c" : null,  '  + 
  '         "IsPregnantInLastThreeMonthsToggle__c" : null,  '  + 
  '         "IsReceivingMedicareBenefitToggle__c" : null,  '  + 
  '         "IsRecoveryFromIllnessOrInjuryToggle__c" : null,  '  + 
  '         "IsBlindToggle__c" : null,  '  + 
  '         "IsDisabledToggle__c" : null,  '  + 
  '         "HasEmergencyMedicalConditionToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "DCRecoveryIllnessId__c" : null,  '  + 
  '         "DCEMCId__c" : null,  '  + 
  '         "IsReceivingCaretakerServicesToggle__c" : null,  '  + 
  '         "IsRequestingOrReceivingCISToggle__c" : null,  '  + 
  '         "BlindnessVerificationCode__c" : 0,  '  + 
  '         "UnableToBuyCookForSelfToggle__c" : null,  '  + 
  '         "DisabilityVerificationCode__c" : 0,  '  + 
  '         "TBQIndividualVerificationCode__c" : 0,  '  + 
  '         "DCMemberWorkReqExemptionId__c" : null,  '  + 
  '         "ReturnToWorkDate__c" : null,  '  + 
  '         "IsOnSickLeaveToggle__c" : null,  '  + 
  '         "RecoveryDate__c" : null,  '  + 
  '         "EmergencyEndDate__c" : null,  '  + 
  '         "EmergencyBeginDate__c" : null,  '  + 
  '         "BlindnessStatus__c" : null,  '  + 
  '         "BlindnessBenefitTypeCode__c" : null,  '  + 
  '         "BlindnessParentUnableToCareForChild__c" : null,  '  + 
  '         "BlindnessHasEndStageRenalDisease__c" : null,  '  + 
  '         "DisabilityStatus__c" : null,  '  + 
  '         "ParentUnableToCareForChildToggle__c" : null,  '  + 
  '         "HasEndStageRenalDiseaseToggle__c" : null,  '  + 
  '         "BenefitTypeCode__c" : null,  '  + 
  '         "IsToBeReferredToWicToggle__c" : null,  '  + 
  '         "PregnancyTerminationDate__c" : null,  '  + 
  '         "PregnancyDueDate__c" : null,  '  + 
  '         "NumberOfBirthsExpected__c" : null,  '  + 
  '         "IsPregnantToggle__c" : null,  '  + 
  '         "DCPregnancyId__c" : null,  '  + 
  '         "IsPregnantInLastThreeMonthsToggle__c" : null,  '  + 
  '         "IsReceivingMedicareBenefitToggle__c" : null,  '  + 
  '         "IsRecoveryFromIllnessOrInjuryToggle__c" : null,  '  + 
  '         "IsBlindToggle__c" : null,  '  + 
  '         "IsDisabledToggle__c" : null,  '  + 
  '         "HasEmergencyMedicalConditionToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "DCRecoveryIllnessId__c" : null,  '  + 
  '         "DCEMCId__c" : null,  '  + 
  '         "IsReceivingCaretakerServicesToggle__c" : null,  '  + 
  '         "IsRequestingOrReceivingCISToggle__c" : null,  '  + 
  '         "BlindnessVerificationCode__c" : 0,  '  + 
  '         "UnableToBuyCookForSelfToggle__c" : null,  '  + 
  '         "DisabilityVerificationCode__c" : 0,  '  + 
  '         "TBQIndividualVerificationCode__c" : 0,  '  + 
  '         "DCMemberWorkReqExemptionId__c" : null,  '  + 
  '         "ReturnToWorkDate__c" : null,  '  + 
  '         "IsOnSickLeaveToggle__c" : null,  '  + 
  '         "RecoveryDate__c" : null,  '  + 
  '         "EmergencyEndDate__c" : null,  '  + 
  '         "EmergencyBeginDate__c" : null,  '  + 
  '         "BlindnessStatus__c" : null,  '  + 
  '         "BlindnessBenefitTypeCode__c" : null,  '  + 
  '         "BlindnessParentUnableToCareForChild__c" : null,  '  + 
  '         "BlindnessHasEndStageRenalDisease__c" : null,  '  + 
  '         "DisabilityStatus__c" : null,  '  + 
  '         "ParentUnableToCareForChildToggle__c" : null,  '  + 
  '         "HasEndStageRenalDiseaseToggle__c" : null,  '  + 
  '         "BenefitTypeCode__c" : null,  '  + 
  '         "IsToBeReferredToWicToggle__c" : null,  '  + 
  '         "PregnancyTerminationDate__c" : null,  '  + 
  '         "PregnancyDueDate__c" : null,  '  + 
  '         "NumberOfBirthsExpected__c" : null,  '  + 
  '         "IsPregnantToggle__c" : null,  '  + 
  '         "DCPregnancyId__c" : null,  '  + 
  '         "IsPregnantInLastThreeMonthsToggle__c" : null,  '  + 
  '         "IsReceivingMedicareBenefitToggle__c" : null,  '  + 
  '         "IsRecoveryFromIllnessOrInjuryToggle__c" : null,  '  + 
  '         "IsBlindToggle__c" : null,  '  + 
  '         "IsDisabledToggle__c" : null,  '  + 
  '         "HasEmergencyMedicalConditionToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "HealthInformation"  '  + 
  '  }  ' ; 
  

  public static final String sHouseHoldOtherInformation =    '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_Application__c" : [ {  '  + 
  '         "ConvictionVerification__c" : 0,  '  + 
  '         "HasConvictedCrimeToggle__c" : null,  '  + 
  '         "HasConvictedOfTradingDrugsToggle__c" : null,  '  + 
  '         "HasConvictedOfTradingFirearm__c" : null,  '  + 
  '         "HasConvictedOfBuyingSellingToggle__c" : null,  '  + 
  '         "HasGivenWrongInformationToggle__c" : null,  '  + 
  '         "IsParticipatingCompltdTreatmentToggle__c" : null,  '  + 
  '         "IsConvictedChemicallyDependentToggle__c" : null,  '  + 
  '         "IsConvictedOfDrugFelonyToggle__c" : null,  '  + 
  '         "IsFleeingFelonToggle__c" : null  '  + 
  '       } ],  '  + 
  '       "SSP_Attendance__c" : [ {  '  + 
  '         "School_Name__c" : null,  '  + 
  '         "PlacedThroughProgramCode__c" : null,  '  + 
  '         "IsAssignedToInstitutionProgramToggle__c" : "N",  '  + 
  '         "IsParticipatingInWorkStudyProgramToggle__c" : "N",  '  + 
  '         "EnrollmentTypeCode__c" : "FT",  '  + 
  '         "InstitutionSchoolName__r" : null,  '  + 
  '         "ExpectedGraduationDate__c" : null,  '  + 
  '         "InstitutionSchoolTypeCode__c" : "MS",  '  + 
  '         "DCId__c" : 244097,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "School_Name__c" : null,  '  + 
  '         "PlacedThroughProgramCode__c" : null,  '  + 
  '         "IsAssignedToInstitutionProgramToggle__c" : "N",  '  + 
  '         "IsParticipatingInWorkStudyProgramToggle__c" : "N",  '  + 
  '         "EnrollmentTypeCode__c" : "FT",  '  + 
  '         "InstitutionSchoolName__r" : null,  '  + 
  '         "ExpectedGraduationDate__c" : null,  '  + 
  '         "InstitutionSchoolTypeCode__c" : "MS",  '  + 
  '         "DCId__c" : 244096,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       } ],  '  + 
  '       "SSP_Benefits__c" : [ {  '  + 
  '         "DCBenefitsId__c" : "EntitledBenefit,32749",  '  + 
  '         "BenefitTypeCode__c" : "UI",  '  + 
  '         "BenefitDenialDate__c" : null,  '  + 
  '         "BenefitDenialReason__c" : null,  '  + 
  '         "StatusofApplication__c" : "A",  '  + 
  '         "BenefitApplicationDate__c" : "2019-04-01",  '  + 
  '         "DCId__c" : 32749,  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "RecordType" : {  '  + 
  '           "Name" : "EntitledBenefit"  '  + 
  '         }  '  + 
  '       } ],  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "DCLAHospitalizationId__c" : null,  '  + 
  '         "HospitalizationEndDate__c" : null,  '  + 
  '         "HospitalizationStartDate__c" : null,  '  + 
  '         "IsFosterCareToggle__c" : null,  '  + 
  '         "AgeAtFosterCare__c" : null,  '  + 
  '         "IsStateMedicaidprogramCode__c" : "N",  '  + 
  '         "FosterStateCode__c" : null,  '  + 
  '         "ReceivesEntitledIncomeToggle__c" : "Y",  '  + 
  '         "ReceivesSSIBenefitsToggle__c" : null,  '  + 
  '         "IsMigrantOrSeasonalFarmWorkerToggle__c" : "N",  '  + 
  '         "IsCurrentlyEnrolledInSchoolToggle__c" : "Y",  '  + 
  '         "TemporarilyLivesElsewhereToggle__c" : null,  '  + 
  '         "HasHouseholdHomeless__c" : null,  '  + 
  '         "ReceiveInHouseAssistanceToggle__c" : "Y",  '  + 
  '         "InHomeCareType__c" : "NA",  '  + 
  '         "ProviderName__c" : null,  '  + 
  '         "ProviderId__c" : null,  '  + 
  '         "OrganizationName__r" : null,  '  + 
  '         "ExpectedReturnDate__c" : null,  '  + 
  '         "IsWaitingForDecisionToggle__c" : null,  '  + 
  '         "IncarcerationBeginDate__c" : "2014-04-01",  '  + 
  '         "HasRecievedHalfMealsFrmInstToggle__c" : null,  '  + 
  '         "LaTypeCode__c" : "IH",  '  + 
  '         "DCMemberLivingArrangementId__c" : 992094,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "DCLAHospitalizationId__c" : null,  '  + 
  '         "HospitalizationEndDate__c" : null,  '  + 
  '         "HospitalizationStartDate__c" : null,  '  + 
  '         "IsFosterCareToggle__c" : null,  '  + 
  '         "AgeAtFosterCare__c" : null,  '  + 
  '         "IsStateMedicaidprogramCode__c" : "N",  '  + 
  '         "FosterStateCode__c" : null,  '  + 
  '         "ReceivesEntitledIncomeToggle__c" : "Y",  '  + 
  '         "ReceivesSSIBenefitsToggle__c" : null,  '  + 
  '         "IsMigrantOrSeasonalFarmWorkerToggle__c" : "N",  '  + 
  '         "IsCurrentlyEnrolledInSchoolToggle__c" : "Y",  '  + 
  '         "TemporarilyLivesElsewhereToggle__c" : null,  '  + 
  '         "HasHouseholdHomeless__c" : null,  '  + 
  '         "ReceiveInHouseAssistanceToggle__c" : "Y",  '  + 
  '         "InHomeCareType__c" : "NA",  '  + 
  '         "ProviderName__c" : null,  '  + 
  '         "ProviderId__c" : null,  '  + 
  '         "OrganizationName__r" : null,  '  + 
  '         "ExpectedReturnDate__c" : null,  '  + 
  '         "IsWaitingForDecisionToggle__c" : null,  '  + 
  '         "IncarcerationBeginDate__c" : "2014-04-01",  '  + 
  '         "HasRecievedHalfMealsFrmInstToggle__c" : null,  '  + 
  '         "LaTypeCode__c" : "IH",  '  + 
  '         "DCMemberLivingArrangementId__c" : 996357,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "DCLAHospitalizationId__c" : null,  '  + 
  '         "HospitalizationEndDate__c" : null,  '  + 
  '         "HospitalizationStartDate__c" : null,  '  + 
  '         "IsFosterCareToggle__c" : null,  '  + 
  '         "AgeAtFosterCare__c" : null,  '  + 
  '         "IsStateMedicaidprogramCode__c" : "N",  '  + 
  '         "FosterStateCode__c" : null,  '  + 
  '         "ReceivesEntitledIncomeToggle__c" : "Y",  '  + 
  '         "ReceivesSSIBenefitsToggle__c" : null,  '  + 
  '         "IsMigrantOrSeasonalFarmWorkerToggle__c" : "N",  '  + 
  '         "IsCurrentlyEnrolledInSchoolToggle__c" : "N",  '  + 
  '         "TemporarilyLivesElsewhereToggle__c" : null,  '  + 
  '         "HasHouseholdHomeless__c" : null,  '  + 
  '         "ReceiveInHouseAssistanceToggle__c" : "Y",  '  + 
  '         "InHomeCareType__c" : "NA",  '  + 
  '         "ProviderName__c" : null,  '  + 
  '         "ProviderId__c" : null,  '  + 
  '         "OrganizationName__r" : null,  '  + 
  '         "ExpectedReturnDate__c" : null,  '  + 
  '         "IsWaitingForDecisionToggle__c" : null,  '  + 
  '         "IncarcerationBeginDate__c" : "2014-04-01",  '  + 
  '         "HasRecievedHalfMealsFrmInstToggle__c" : null,  '  + 
  '         "LaTypeCode__c" : "IH",  '  + 
  '         "DCMemberLivingArrangementId__c" : 724981,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "HouseHoldOtherInformation"  '  + 
  '  }  ' ; 
  
   
  public static final String sMemberInformation =   
  
  '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_AlienSponsor__c" : null,  '  + 
  '       "SSP_Application__c" : null,  '  + 
  '       "SSP_Member__c" : [ {  '  + 
  '         "HasParentOrSiblingNextOutHousehold__c" : null,  '  + 
  '         "HasParentOrSiblingCurrentOutHousehold__c" : null,  '  + 
  '         "CanBuyCookWithHOH__c" : 0,  '  + 
  '         "ExternalAlienSponsor__r" : null,  '  + 
  '         "InternalAlienSponsor__r" : null,  '  + 
  '         "DCInternalAlienSponsorId__c" : null,  '  + 
  '         "SponsoredByOrganization__c" : null,  '  + 
  '         "DCAlienSponsorRelationship__c" : null,  '  + 
  '         "TaxFilerMemberNext__r" : null,  '  + 
  '         "TaxFilerStatusNextYear__c" : null,  '  + 
  '         "TaxFilerMemberCurrent__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "TaxFilerStatusCurrentYear__c" : "DM",  '  + 
  '         "MailingAddressLine2__c" : null,  '  + 
  '         "MailingZipCode5__c" : "83705",  '  + 
  '         "MailingZipCode4__c" : "9256",  '  + 
  '         "MailingStateCode__c" : "KY",  '  + 
  '         "MailingCountyCode__c" : "011",  '  + 
  '         "MailingCity__c" : "ELFBJSUXVP",  '  + 
  '         "MailingAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "DCMailingAddressId__c" : 13717682,  '  + 
  '         "HasDifferentMailingAddressToggle__c" : null,  '  + 
  '         "PhysicalAddressLine2__c" : null,  '  + 
  '         "PhysicalZipCode5__c" : "83705",  '  + 
  '         "PhysicalZipCode4__c" : "9256",  '  + 
  '         "PhysicalStateCode__c" : "KY",  '  + 
  '         "PhysicalCountyCode__c" : "011",  '  + 
  '         "PhysicalCity__c" : "ELFBJSUXVP",  '  + 
  '         "PhysicalAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "IsFixedAddressToggle__c" : "Y",  '  + 
  '         "DCPhysicalAddressId__c" : "29553502",  '  + 
  '         "PreferredWrittenLanguageCode__c" : "1",  '  + 
  '         "PreferredSpokenLanguageCode__c" : "1",  '  + 
  '         "PreferredNotificationMethodCode__c" : "P",  '  + 
  '         "SecondaryPhoneExtension__c" : "1234",  '  + 
  '         "SecondaryPhoneNumber__c" : "1234567890",  '  + 
  '         "IsPrimaryTextPreferred__c" : "N",  '  + 
  '         "PrimaryPhoneTypeCode__c" : "CE",  '  + 
  '         "PrimaryPhoneExtension__c" : "1234",  '  + 
  '         "PrimaryPhoneNumber__c" : "8134567890",  '  + 
  '         "Email__c" : "Optim@Script.com",  '  + 
  '         "DCId__c" : 1460992,  '  + 
  '         "IsEligibleForIndianHealthServicesToggle__c" : null,  '  + 
  '         "IsEligibleForIHFlagToggle__c" : null,  '  + 
  '         "IndianTribeState__c" : null,  '  + 
  '         "IndianTribeCode__c" : null,  '  + 
  '         "IsFederalRecognizedIndianTribeToggle__c" : null,  '  + 
  '         "HighestEducationGraduatedDate__c" : null,  '  + 
  '         "HighestEducationLevelCode__c" : "8G",  '  + 
  '         "DCMemberHighestEducationLevelDetailsId__c" : 976133,  '  + 
  '         "ImmigrationDateOfBirth__c" : null,  '  + 
  '         "ImmigrationSuffix__c" : null,  '  + 
  '         "ImmigrationLastName__c" : null,  '  + 
  '         "ImmigrationMiddleName__c" : null,  '  + 
  '         "ImmigrationFirstName__c" : null,  '  + 
  '         "IsImmigrationDetailsMatch__c" : 0,  '  + 
  '         "PassportNumber__c" : null,  '  + 
  '         "NaturalizationNumber__c" : null,  '  + 
  '         "I94Number__c" : null,  '  + 
  '         "DocumentOtherDescription__c" : null,  '  + 
  '         "DocumentExpiryDate__c" : null,  '  + 
  '         "CountryOfIssuanceCode__c" : null,  '  + 
  '         "CitizenshipNumber__c" : null,  '  + 
  '         "AlienNumber__c" : null,  '  + 
  '         "ReceiptNumber__c" : null,  '  + 
  '         "SevisId__c" : null,  '  + 
  '         "ImmigrationDocumentTypeCode__c" : null,  '  + 
  '         "AlienTypeCode__c" : null,  '  + 
  '         "HasLivedInUsToggle__c" : null,  '  + 
  '         "IsMilitaryMemberToggle__c" : "N",  '  + 
  '         "HasLegalImmigrationStatusToggle__c" : null,  '  + 
  '         "HasAlienSponsorToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "HasParentOrSiblingNextOutHousehold__c" : null,  '  + 
  '         "HasParentOrSiblingCurrentOutHousehold__c" : null,  '  + 
  '         "CanBuyCookWithHOH__c" : 0,  '  + 
  '         "ExternalAlienSponsor__r" : null,  '  + 
  '         "InternalAlienSponsor__r" : null,  '  + 
  '         "DCInternalAlienSponsorId__c" : null,  '  + 
  '         "SponsoredByOrganization__c" : null,  '  + 
  '         "DCAlienSponsorRelationship__c" : null,  '  + 
  '         "TaxFilerMemberNext__r" : null,  '  + 
  '         "TaxFilerStatusNextYear__c" : null,  '  + 
  '         "TaxFilerMemberCurrent__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "TaxFilerStatusCurrentYear__c" : "DM",  '  + 
  '         "MailingAddressLine2__c" : null,  '  + 
  '         "MailingZipCode5__c" : "83705",  '  + 
  '         "MailingZipCode4__c" : "9256",  '  + 
  '         "MailingStateCode__c" : "KY",  '  + 
  '         "MailingCountyCode__c" : "011",  '  + 
  '         "MailingCity__c" : "ELFBJSUXVP",  '  + 
  '         "MailingAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "DCMailingAddressId__c" : 13717683,  '  + 
  '         "HasDifferentMailingAddressToggle__c" : "N",  '  + 
  '         "PhysicalAddressLine2__c" : null,  '  + 
  '         "PhysicalZipCode5__c" : "83705",  '  + 
  '         "PhysicalZipCode4__c" : "9256",  '  + 
  '         "PhysicalStateCode__c" : "KY",  '  + 
  '         "PhysicalCountyCode__c" : "011",  '  + 
  '         "PhysicalCity__c" : "ELFBJSUXVP",  '  + 
  '         "PhysicalAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "IsFixedAddressToggle__c" : "Y",  '  + 
  '         "DCPhysicalAddressId__c" : "29553500",  '  + 
  '         "PreferredWrittenLanguageCode__c" : "1",  '  + 
  '         "PreferredSpokenLanguageCode__c" : "1",  '  + 
  '         "PreferredNotificationMethodCode__c" : "P",  '  + 
  '         "SecondaryPhoneExtension__c" : "1234",  '  + 
  '         "SecondaryPhoneNumber__c" : "1234567890",  '  + 
  '         "IsPrimaryTextPreferred__c" : "N",  '  + 
  '         "PrimaryPhoneTypeCode__c" : "CE",  '  + 
  '         "PrimaryPhoneExtension__c" : "1234",  '  + 
  '         "PrimaryPhoneNumber__c" : "8134567890",  '  + 
  '         "Email__c" : "Optim@Script.com",  '  + 
  '         "DCId__c" : 1463025,  '  + 
  '         "IsEligibleForIndianHealthServicesToggle__c" : null,  '  + 
  '         "IsEligibleForIHFlagToggle__c" : null,  '  + 
  '         "IndianTribeState__c" : null,  '  + 
  '         "IndianTribeCode__c" : null,  '  + 
  '         "IsFederalRecognizedIndianTribeToggle__c" : null,  '  + 
  '         "HighestEducationGraduatedDate__c" : null,  '  + 
  '         "HighestEducationLevelCode__c" : "6G",  '  + 
  '         "DCMemberHighestEducationLevelDetailsId__c" : 976132,  '  + 
  '         "ImmigrationDateOfBirth__c" : null,  '  + 
  '         "ImmigrationSuffix__c" : null,  '  + 
  '         "ImmigrationLastName__c" : null,  '  + 
  '         "ImmigrationMiddleName__c" : null,  '  + 
  '         "ImmigrationFirstName__c" : null,  '  + 
  '         "IsImmigrationDetailsMatch__c" : 0,  '  + 
  '         "PassportNumber__c" : null,  '  + 
  '         "NaturalizationNumber__c" : null,  '  + 
  '         "I94Number__c" : null,  '  + 
  '         "DocumentOtherDescription__c" : null,  '  + 
  '         "DocumentExpiryDate__c" : null,  '  + 
  '         "CountryOfIssuanceCode__c" : null,  '  + 
  '         "CitizenshipNumber__c" : null,  '  + 
  '         "AlienNumber__c" : null,  '  + 
  '         "ReceiptNumber__c" : null,  '  + 
  '         "SevisId__c" : null,  '  + 
  '         "ImmigrationDocumentTypeCode__c" : null,  '  + 
  '         "AlienTypeCode__c" : null,  '  + 
  '         "HasLivedInUsToggle__c" : null,  '  + 
  '         "IsMilitaryMemberToggle__c" : "N",  '  + 
  '         "HasLegalImmigrationStatusToggle__c" : null,  '  + 
  '         "HasAlienSponsorToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       }, {  '  + 
  '         "HasParentOrSiblingNextOutHousehold__c" : null,  '  + 
  '         "HasParentOrSiblingCurrentOutHousehold__c" : null,  '  + 
  '         "CanBuyCookWithHOH__c" : 0,  '  + 
  '         "ExternalAlienSponsor__r" : null,  '  + 
  '         "InternalAlienSponsor__r" : null,  '  + 
  '         "DCInternalAlienSponsorId__c" : null,  '  + 
  '         "SponsoredByOrganization__c" : null,  '  + 
  '         "DCAlienSponsorRelationship__c" : null,  '  + 
  '         "TaxFilerMemberNext__r" : null,  '  + 
  '         "TaxFilerStatusNextYear__c" : null,  '  + 
  '         "TaxFilerMemberCurrent__r" : null,  '  + 
  '         "TaxFilerStatusCurrentYear__c" : "HH",  '  + 
  '         "MailingAddressLine2__c" : null,  '  + 
  '         "MailingZipCode5__c" : "83705",  '  + 
  '         "MailingZipCode4__c" : "9256",  '  + 
  '         "MailingStateCode__c" : "KY",  '  + 
  '         "MailingCountyCode__c" : "011",  '  + 
  '         "MailingCity__c" : "ELFBJSUXVP",  '  + 
  '         "MailingAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "DCMailingAddressId__c" : 4842144,  '  + 
  '         "HasDifferentMailingAddressToggle__c" : null,  '  + 
  '         "PhysicalAddressLine2__c" : null,  '  + 
  '         "PhysicalZipCode5__c" : "83705",  '  + 
  '         "PhysicalZipCode4__c" : "9256",  '  + 
  '         "PhysicalStateCode__c" : "KY",  '  + 
  '         "PhysicalCountyCode__c" : "011",  '  + 
  '         "PhysicalCity__c" : "ELFBJSUXVP",  '  + 
  '         "PhysicalAddressLine1__c" : "527 J 9QG UT",  '  + 
  '         "IsFixedAddressToggle__c" : "Y",  '  + 
  '         "DCPhysicalAddressId__c" : "13717679",  '  + 
  '         "PreferredWrittenLanguageCode__c" : "1",  '  + 
  '         "PreferredSpokenLanguageCode__c" : "1",  '  + 
  '         "PreferredNotificationMethodCode__c" : "P",  '  + 
  '         "SecondaryPhoneExtension__c" : "1234",  '  + 
  '         "SecondaryPhoneNumber__c" : "1234567890",  '  + 
  '         "IsPrimaryTextPreferred__c" : "N",  '  + 
  '         "PrimaryPhoneTypeCode__c" : "CE",  '  + 
  '         "PrimaryPhoneExtension__c" : "1234",  '  + 
  '         "PrimaryPhoneNumber__c" : "8134567890",  '  + 
  '         "Email__c" : "Optim@Script.com",  '  + 
  '         "DCId__c" : 1394196,  '  + 
  '         "IsEligibleForIndianHealthServicesToggle__c" : null,  '  + 
  '         "IsEligibleForIHFlagToggle__c" : null,  '  + 
  '         "IndianTribeState__c" : null,  '  + 
  '         "IndianTribeCode__c" : null,  '  + 
  '         "IsFederalRecognizedIndianTribeToggle__c" : null,  '  + 
  '         "HighestEducationGraduatedDate__c" : null,  '  + 
  '         "HighestEducationLevelCode__c" : "BG",  '  + 
  '         "DCMemberHighestEducationLevelDetailsId__c" : 976134,  '  + 
  '         "ImmigrationDateOfBirth__c" : null,  '  + 
  '         "ImmigrationSuffix__c" : null,  '  + 
  '         "ImmigrationLastName__c" : null,  '  + 
  '         "ImmigrationMiddleName__c" : null,  '  + 
  '         "ImmigrationFirstName__c" : null,  '  + 
  '         "IsImmigrationDetailsMatch__c" : 0,  '  + 
  '         "PassportNumber__c" : null,  '  + 
  '         "NaturalizationNumber__c" : null,  '  + 
  '         "I94Number__c" : null,  '  + 
  '         "DocumentOtherDescription__c" : null,  '  + 
  '         "DocumentExpiryDate__c" : null,  '  + 
  '         "CountryOfIssuanceCode__c" : null,  '  + 
  '         "CitizenshipNumber__c" : null,  '  + 
  '         "AlienNumber__c" : null,  '  + 
  '         "ReceiptNumber__c" : null,  '  + 
  '         "SevisId__c" : null,  '  + 
  '         "ImmigrationDocumentTypeCode__c" : null,  '  + 
  '         "AlienTypeCode__c" : null,  '  + 
  '         "HasLivedInUsToggle__c" : null,  '  + 
  '         "IsMilitaryMemberToggle__c" : "N",  '  + 
  '         "HasLegalImmigrationStatusToggle__c" : null,  '  + 
  '         "HasAlienSponsorToggle__c" : null,  '  + 
  '         "IndividualId__c" : "999034247"  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "101272217",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "MemberInformation"  '  + 
  '  }  ' ;  

  
  
  public static final String sRelationshipInformation =      '   {  '  + 
  '     "AckResponse" : null,  '  + 
  '     "Payload" : {  '  + 
  '       "SSP_Relationship__c" : [ {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "MO",  '  + 
  '         "DCId__c" : "2327380",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "MO",  '  + 
  '         "DCId__c" : "2327381",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "SO",  '  + 
  '         "DCId__c" : "2327383",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "DA",  '  + 
  '         "DCId__c" : "2327385",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "SI",  '  + 
  '         "DCId__c" : "2595920",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       }, {  '  + 
  '         "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
  '         "IsActingParentToggle__c" : "N",  '  + 
  '         "IsCareTakerToggle__c" : "N",  '  + 
  '         "RelationshipType__c" : "BR",  '  + 
  '         "DCId__c" : "2595921",  '  + 
  '         "SSP_MemberRelatedTo__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         },  '  + 
  '         "SSP_Member__r" : {  '  + 
  '           "IndividualId__c" : "999034247"  '  + 
  '         }  '  + 
  '       } ]  '  + 
  '     },  '  + 
  '     "role" : "Citizen_Individual",  '  + 
  '     "miscelleanousParameter" : "",  '  + 
  '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
  '     "mode" : "Intake",  '  + 
  '     "programCode" : "MA",  '  + 
  '     "individualIds" : "999034247;101227474;101227475",  '  + 
  '     "primaryApplicantIndividualId" : "999034247",  '  + 
  '     "caseNumber" : "0",  '  + 
  '     "viewName" : "RelationshipInformation"  '  + 
  '   }  '  + 
  '    ' ; 


   
   public static final String sResourceInformation =         
   '   {  '  + 
   '     "AckResponse" : null,  '  + 
   '     "Payload" : {  '  + 
   '       "SSP_Application__c" : null,  '  + 
   '       "SSP_ResourceOwnership__c" : null,  '  + 
   '       "SSP_Asset__c" : null,  '  + 
   '       "SSP_Member__c" : [ {  '  + 
   '         "HasPreArrangedFuneralContractToggle__c" : null,  '  + 
   '         "HasLifeInsuranceToggle__c" : null,  '  + 
   '         "HasRealEstatePropertyToggle__c" : null,  '  + 
   '         "HasVehicleToggle__c" : null,  '  + 
   '         "HasCashReloadableMoneyCardToggle__c" : null,  '  + 
   '         "HasInvestmentsToggle__c" : null,  '  + 
   '         "HasOwnBankAccountToggle__c" : null,  '  + 
   '         "IndividualId__c" : "999034247"  '  + 
   '       }, {  '  + 
   '         "HasPreArrangedFuneralContractToggle__c" : null,  '  + 
   '         "HasLifeInsuranceToggle__c" : null,  '  + 
   '         "HasRealEstatePropertyToggle__c" : null,  '  + 
   '         "HasVehicleToggle__c" : null,  '  + 
   '         "HasCashReloadableMoneyCardToggle__c" : null,  '  + 
   '         "HasInvestmentsToggle__c" : null,  '  + 
   '         "HasOwnBankAccountToggle__c" : null,  '  + 
   '         "IndividualId__c" : "999034247"  '  + 
   '       }, {  '  + 
   '         "HasPreArrangedFuneralContractToggle__c" : null,  '  + 
   '         "HasLifeInsuranceToggle__c" : null,  '  + 
   '         "HasRealEstatePropertyToggle__c" : null,  '  + 
   '         "HasVehicleToggle__c" : null,  '  + 
   '         "HasCashReloadableMoneyCardToggle__c" : null,  '  + 
   '         "HasInvestmentsToggle__c" : null,  '  + 
   '         "HasOwnBankAccountToggle__c" : null,  '  + 
   '         "IndividualId__c" : "999034247"  '  + 
   '       } ]  '  + 
   '     },  '  + 
   '     "role" : "Citizen_Individual",  '  + 
   '     "miscelleanousParameter" : "",  '  + 
   '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
   '     "mode" : "Intake",  '  + 
   '     "programCode" : "MA",  '  + 
   '     "individualIds" : "999034247;101227474;101227475",  '  + 
   '     "primaryApplicantIndividualId" : "999034247",  '  + 
   '     "caseNumber" : "0",  '  + 
   '     "viewName" : "ResourceInformation"  '  + 
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
                                             '         "caseNumber": "100059325", '+
                                             '         "primaryApplicantIndividualId": "999034247",   '+
                                             '         "individualIds": "999034247;999034363",    '+
                                             '         "programCode": "MA;KT;SN", '+
                                             '         "mode": "Intake",  '+
                                             '         "applicationID": "a0Xr0000000sp8T",    '+
                                             '         "miscelleanousParameter": null,    '+
                                             '         "Payload": {   '+
                                             '           "Benefit": [ '+
                                             '            {   '+
                                             '              "CaseNumber": "100059325",    '+
                                             '              "IndividualId": "999034247",  '+
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
                                             '            }' + 
                                                        ' ]   '+
                                                      ' }     '+
                                                 '   }    ';  
  public static final String sMedicaidMCOInformation =      '   {  '  + 
                                                  '   "viewName" : "MedicaidMCOInformation",      '+
                                                  '     "caseNumber" : "100059325",      '+
                                                  '     "primaryApplicantIndividualId" : "999034247",      '+
                                                  '     "individualIds" : "999034247",      '+
                                                  '     "programCode" : "MA;KT;SN",      '+
                                                  '     "mode" : "Intake",      '+
                                                  '     "applicationID" : "a0Xr0000000sp8T",      '+
                                                  '     "miscelleanousParameter" : null,      '+
                                                  '     "Payload"     : {      '+
                                                    '     "Individual"  : [      '+
                                                  '    {  '+
                                                        '     "CaseNumber" : "100059325",      '+
                                                        '     "IndividualId" : "999034247",      '+
                                                        '     "IndividualName" : "WEWRT GFG",      '+
                                                        '     "IsEnrolledInPlan" : "Y",      '+
                                                        '     "IsEligibleToEnroll" : "Y",      '+
                                                        '     "InEligibleDueToLTC" : "N",      '+
                                                        '     "InEligibleDueToIncarceration" : "N",      '+
                                                        '     "InEligibleDueToKIHIPP" : "N",      '+
                                                        '     "MCOBeginDate" : "N"      '+
                                                  '   }      '+
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
                                                          '   "AckResponse" : null,  '  + 
                                                          '   "Payload" : {  '  + 
                                                          '   "AgentAssisterAuthRep" : null,  '  + 
                                                          '   "Renewal" : null,  '  + 
                                                          '   "DemographicDetails" : [ {  '  + 
                                                          '   "PreferredIndividual" : "Y",  '  + 
                                                          '   "IndividualId" : "999034247",  '  + 
                                                          '   "BirthDate" : "1998-06-01",  '  + 
                                                          '   "GenderCode" : "M",  '  + 
                                                          '   "SuffixCode" : null,  '  + 
                                                          '   "MiddleInitial" : null,  '  + 
                                                          '   "LastName" : "JZBRPL",  '  + 
                                                          '   "FirstName" : "JKJHJJSNHDUD"  '  + 
                                                          '   } ],  '  + 
                                                          '   "CaseInfo" : [ {  '  + 
                                                          '   "LastEligibilityTransactionDate" : "2020-11-11T09:56:28.903",  '  + 
                                                          '   "MedicaidApplicationType" : null,  '  + 
                                                          '   "ApplicationSourceType" : null,  '  + 
                                                          '   "IndividualId" : "999034247",  '  + 
                                                          '   "IsCaseInChangeMode" : "N",  '  + 
                                                          '   "CaseOwnership" : null,  '  + 
                                                          '   "IsTmember" : null,  '  + 
                                                          '   "SNAPClaimAmount" : null,  '  + 
                                                          '   "IsRACEnabled" : "Y",  '  + 
                                                          '   "IsInRenewalPeriod" : "N",  '  + 
                                                          '   "RFICount" : 0,  '  + 
                                                          '   "IsHeadOfHousehold" : "Y",  '  + 
                                                          '   "CaseStatusCode" : "AP",  '  + 
                                                          '   "CaseNumber" : "100059325"  '  + 
                                                          '   } ],  '  + 
                                                          '   "TimeStampDetails" : [ {  '  + 
                                                          '   "TimeStamp" : "2020-12-05T05:00:00Z"  '  + 
                                                          '   } ]  '  + 
                                                          '   },  '  + 
                                                          '   "role" : "Citizen_Individual",  '  + 
                                                          '   "miscelleanousParameter" : "",  '  + 
                                                          '   "applicationID" : "",  '  + 
                                                          '   "mode" : "",  '  + 
                                                          '   "programCode" : "",  '  + 
                                                          '   "individualIds" : "",  '  + 
                                                          '   "primaryApplicantIndividualId" : "999034247",  '  + 
                                                          '   "caseNumber" : "0",  '  + 
                                                          '   "viewName" : "DashboardCaseInformation"  '  + 
                                                          '   }  '  + 
                                                          '    ' ; 
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