
public  with sharing class SSP_DC_ReverseMockImpl_RAC2  {
    // SObject Structure
    public static final String sQualifiedIndividual =         '   {  '  + 
    '     '  + 
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_Member__c" : [ {  '  + 
    '   "DeathDateVerificationCode__c" : null,  '  + 
    '   "IsNonUSCitizenMilitaryMemberToggle__c" : "N",  '  + 
    '   "IsFileCleared__c" : 1,  '  + 
    '   "IsUSCitizenToggle__c" : "Y",  '  + 
    '   "RaceCode__c" : "W",  '  + 
    '   "IsUSCitizenValidated__c" : 1,  '  + 
    '   "PseudoSSN__c" : null,  '  + 
    '   "IsDateOfDeathValidated__c" : 1,  '  + 
    '   "IsDateOfBirthValidated__c" : 1,  '  + 
    '   "NationalityCode__c" : null,  '  + 
    '   "SSNVerified__c" : 1,  '  + 
    '   "MCIId__c" : "486587",  '  + 
    '   "IndividualId__c" : "999031236",  '  + 
    '   "NoReasonSSNCode__c" : null,  '  + 
    '   "GenderCode__c" : "F",  '  + 
    '   "DeathDate__c" : null,  '  + 
    '   "SSN__c" : "118655392",  '  + 
    '   "IsMilitaryMemberToggle__c" : "N",  '  + 
    '   "IsIntendToResideToggle__c" : "Y",  '  + 
    '   "IsHispanicLatinoSpanishToggle__c" : "N",  '  + 
    '   "EthnicityCode__c" : null,  '  + 
    '   "SuffixCode__c" : null,  '  + 
    '   "MiddleInitial__c" : "Y",  '  + 
    '   "BirthDate__c" : "1959-06-02",  '  + 
    '   "Alias_Last_Name__c" : null,  '  + 
    '   "Alias_First_Name__c" : null,  '  + 
    '   "LastName__c" : "SQTY",  '  + 
    '   "FirstName__c" : "SQWER"  '  + 
    '   } ],  '  + 
    '   "SSP_ApplicationIndividual__c" : [ {  '  + 
    '   "DCPrograms__c" : null,  '  + 
    '   "MemberProgramsApplied__c" : "MA",  '  + 
    '   "IsHeadOfHousehold__c" : 1,  '  + 
    '   "isApplicationBlocked__c" : 0,  '  + 
    '   "BlockedCaseNumber__c" : "110945931",  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "IsActiveIEESCasePresent__c" : 1  '  + 
    '   }, {  '  + 
    '   "DCPrograms__c" : null,  '  + 
    '   "MemberProgramsApplied__c" : "MA",  '  + 
    '   "IsHeadOfHousehold__c" : 0,  '  + 
    '   "isApplicationBlocked__c" : 0,  '  + 
    '   "BlockedCaseNumber__c" : "110945931",  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "IsActiveIEESCasePresent__c" : 1  '  + 
    '   } ],  '  + 
    '   "SSP_Application__c" : [ {  '  + 
    '   "Relationship_To_You__c" : null,  '  + 
    '   "Contact_Phone_Number__c" : null,  '  + 
    '   "Contact_Name__c" : null,  '  + 
    '   "ProgramsApplied__c" : "MA"  '  + 
    '   } ]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "QualifiedIndividual"  '  + 
    '  }  ' ;

    public static final String sIncomeInformation =           
    '   {  '  + 
    '     "AckResponse" : null,  '  + 
    '     "Payload" : {  '  + 
    '       "SSP_Application__c" : null,  '  + 
    '       "SSP_Benefits__c" : null,  '  + 
    '       "SSP_Asset__c" : [ {  '  + 
    '         "Is_Interface_Inserted__c" : false,  '  + 
    '         "DCAssetId__c" : "Income,23338835,2464156",  '  + 
    '         "EndDate__c" : null,  '  + 
    '         "ExpenseAmount__c" : null,  '  + 
    '         "IncomePayDetailHoursPerWeek__c" : null,  '  + 
    '         "Tips__c" : null,  '  + 
    '         "TotalGrossAmount__c" : "568.00",  '  + 
    '         "IncomePayFrequency__c" : "BW",  '  + 
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
    '         "IncomeSubtypeCode__c" : "UI",  '  + 
    '         "IncomeTypeCode__c" : "IS",  '  + 
    '         "DCUnearnedIncomeDetailId__c" : 2464156,  '  + 
    '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
    '         "DCId__c" : 23338835,  '  + 
    '         "DCEmploymentDetailId__c" : null,  '  + 
    '         "SSP_Member__r" : {  '  + 
    '           "IndividualId__c" : "999031236"  '  + 
    '         },  '  + 
    '         "RecordType" : {  '  + 
    '           "Name" : "Income"  '  + 
    '         }  '  + 
    '       }, {  '  + 
    '         "Is_Interface_Inserted__c" : false,  '  + 
    '         "DCAssetId__c" : "Income,20957074,1600227",  '  + 
    '         "EndDate__c" : null,  '  + 
    '         "ExpenseAmount__c" : null,  '  + 
    '         "IncomePayDetailHoursPerWeek__c" : null,  '  + 
    '         "Tips__c" : null,  '  + 
    '         "TotalGrossAmount__c" : null,  '  + 
    '         "IncomePayFrequency__c" : null,  '  + 
    '         "IsUnempBenefitsRequiredToggle__c" : null,  '  + 
    '         "IsSchoolDegreeRequiredToggle__c" : null,  '  + 
    '         "ActivityStartDate__c" : null,  '  + 
    '         "ActivityType__c" : null,  '  + 
    '         "BusinessTitle__c" : null,  '  + 
    '         "BusinessTypeCode__c" : null,  '  + 
    '         "PrimaryPhoneExtension__c" : null,  '  + 
    '         "PrimaryPhoneNumber__c" : null,  '  + 
    '         "CountyCode__c" : "034",  '  + 
    '         "ZipCode5__c" : "02705",  '  + 
    '         "ZipCode4__c" : null,  '  + 
    '         "StateCode__c" : "KY",  '  + 
    '         "City__c" : "Snfcwyjgh",  '  + 
    '         "AddressLine2__c" : null,  '  + 
    '         "AddressLine1__c" : "452 V Seeeizur",  '  + 
    '         "EIN__c" : 910923998,  '  + 
    '         "EmployerName__c" : "SQLN",  '  + 
    '         "IncomeSubtypeCode__c" : null,  '  + 
    '         "IncomeTypeCode__c" : "EA",  '  + 
    '         "DCUnearnedIncomeDetailId__c" : null,  '  + 
    '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
    '         "DCId__c" : 20957074,  '  + 
    '         "DCEmploymentDetailId__c" : "1600227",  '  + 
    '         "SSP_Member__r" : {  '  + 
    '           "IndividualId__c" : "999031236"  '  + 
    '         },  '  + 
    '         "RecordType" : {  '  + 
    '           "Name" : "Income"  '  + 
    '         }  '  + 
    '       }, {  '  + 
    '         "Is_Interface_Inserted__c" : false,  '  + 
    '         "DCAssetId__c" : "Income,21184383,2297381",  '  + 
    '         "EndDate__c" : null,  '  + 
    '         "ExpenseAmount__c" : null,  '  + 
    '         "IncomePayDetailHoursPerWeek__c" : null,  '  + 
    '         "Tips__c" : null,  '  + 
    '         "TotalGrossAmount__c" : "0.00",  '  + 
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
    '         "DCUnearnedIncomeDetailId__c" : 2297381,  '  + 
    '         "DCSelfEmploymentIncomeDetailId__c" : null,  '  + 
    '         "DCId__c" : 21184383,  '  + 
    '         "DCEmploymentDetailId__c" : null,  '  + 
    '         "SSP_Member__r" : {  '  + 
    '           "IndividualId__c" : "999031236"  '  + 
    '         },  '  + 
    '         "RecordType" : {  '  + 
    '           "Name" : "Income"  '  + 
    '         }  '  + 
    '       } ],  '  + 
    '       "SSP_Member__c" : [ {  '  + 
    '         "HasIncomefromGamblingorLotteryToggle__c" : "N",  '  + 
    '         "HasReceivedBenefitsFromOtherStateToggle__c" : "N",  '  + 
    '         "HasUnpaidEmploymentToggle__c" : null,  '  + 
    '         "HasUnearnedIncomeToggle__c" : "N",  '  + 
    '         "HasMaintenanceIncomeToggle__c" : "N",  '  + 
    '         "HasInsuranceSettlementBenefitToggle__c" : "Y",  '  + 
    '         "HasServicesorPaymentsToggle__c" : "N",  '  + 
    '         "HasDividendsRoyaltiesToggle__c" : "N",  '  + 
    '         "HasSelfEmploymentIncomeToggle__c" : "N",  '  + 
    '         "HasEarnedIncomeFromEmploymentToggle__c" : "Y",  '  + 
    '         "IndividualId__c" : "999031236"  '  + 
    '       } ]  '  + 
    '     },  '  + 
    '     "role" : "Citizen_Individual",  '  + 
    '     "miscelleanousParameter" : "",  '  + 
    '     "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '     "mode" : "Renewal",  '  + 
    '     "programCode" : "MA",  '  + 
    '     "individualIds" : "999031236;102437355",  '  + 
    '     "primaryApplicantIndividualId" : "999031236",  '  + 
    '     "caseNumber" : "110945931",  '  + 
    '     "viewName" : "IncomeInformation"  '  + 
    '  }  ' ;      
    
    public static final String sExpenseInformation =         
    '     '  + 
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_Member__c" : [ {  '  + 
    '   "IsCoverageMonth3__c" : 0,  '  + 
    '   "IsCoverageMonth2__c" : 0,  '  + 
    '   "IsCoverageMonth1__c" : 0,  '  + 
    '   "HasDependentCareExpenseToggle__c" : "N",  '  + 
    '   "HasHouseholdPaidChildSupportToggle__c" : "N",  '  + 
    '   "HasDisabledExpensesToggle__c" : "N",  '  + 
    '   "HasMedicalExpensePartDToggle__c" : "N",  '  + 
    '   "HasAlimonyExpenseToggle__c" : "N",  '  + 
    '   "HasTaxDeductionsExpenseToggle__c" : null,  '  + 
    '   "HaveHigherEducationExpenseToggle__c" : "N",  '  + 
    '   "HasUtilityExpenseToggle__c" : "N",  '  + 
    '   "HasShelterExpenseToggle__c" : "Y",  '  + 
    '   "HasMedicalBillsToggle__c" : null,  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   }, {  '  + 
    '   "IsCoverageMonth3__c" : 0,  '  + 
    '   "IsCoverageMonth2__c" : 0,  '  + 
    '   "IsCoverageMonth1__c" : 0,  '  + 
    '   "HasDependentCareExpenseToggle__c" : "N",  '  + 
    '   "HasHouseholdPaidChildSupportToggle__c" : "N",  '  + 
    '   "HasDisabledExpensesToggle__c" : "N",  '  + 
    '   "HasMedicalExpensePartDToggle__c" : "N",  '  + 
    '   "HasAlimonyExpenseToggle__c" : "N",  '  + 
    '   "HasTaxDeductionsExpenseToggle__c" : null,  '  + 
    '   "HaveHigherEducationExpenseToggle__c" : "N",  '  + 
    '   "HasUtilityExpenseToggle__c" : "N",  '  + 
    '   "HasShelterExpenseToggle__c" : "N",  '  + 
    '   "HasMedicalBillsToggle__c" : null,  '  + 
    '   "IndividualId__c" : "102437355"  '  + 
    '   } ],  '  + 
    '   "SSP_Asset__c" : [ {  '  + 
    '   "DCAssetId__c" : "Expense,962281",  '  + 
    '   "DependentIndividual__r" : null,  '  + 
    '   "DependentCareProvider__r" : null,  '  + 
    '   "ChildName__c" : null,  '  + 
    '   "MiscellaneousAmount__c" : null,  '  + 
    '   "FeesAmount__c" : null,  '  + 
    '   "BooksAmount__c" : null,  '  + 
    '   "TuitionAmount__c" : null,  '  + 
    '   "EndDate__c" : null,  '  + 
    '   "StartDate__c" : null,  '  + 
    '   "IsPaidToVendorToggle__c" : null,  '  + 
    '   "IsNonHouseHoldMemberPayingExpenseToggle__c" : null,  '  + 
    '   "ExpenseAmount__c" : 500.00,  '  + 
    '   "ExpenseFrequencyCode__c" : "MO",  '  + 
    '   "ExpenseSubType__c" : "RNT",  '  + 
    '   "ExpenseTypeCode__c" : "SE",  '  + 
    '   "DCId__c" : "962281",  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "RecordType" : {  '  + 
    '   "Name" : "Expense"  '  + 
    '   }  '  + 
    '   } ]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "ExpenseInformation"  '  + 
    '   }  '  + 
    '    ' ; 
    

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
    '           "IndividualId__c" : "999031236"  '  + 
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
    '           "IndividualId__c" : "999031236"  '  + 
    '         }  '  + 
    '       } ]  '  + 
    '     },  '  + 
    '     "role" : "Citizen_Individual",  '  + 
    '     "miscelleanousParameter" : "",  '  + 
    '     "applicationID" : "a2Rr00000007SYqEAM",  '  + 
    '     "mode" : "Intake",  '  + 
    '     "programCode" : "MA",  '  + 
    '     "individualIds" : "999031236;101227474;101227475",  '  + 
    '     "primaryApplicantIndividualId" : "999031236",  '  + 
    '     "caseNumber" : "0",  '  + 
    '     "viewName" : "AbsentParentInformation"  '  + 
    '  }  ' ;  
    
    public static final String sHealthCoverageInformation =   
    
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_Application__c" : [ {  '  + 
    '   "NotEnrolledInHealthCareCoverageToggle__c" : "N",  '  + 
    '   "EnrolledInHealthCareCoverageToggle__c" : "N"  '  + 
    '   } ],  '  + 
    '   "SSP_HealthInsuranceFacilityType__c" : null,  '  + 
    '   "SSP_Member__c" : null,  '  + 
    '   "SSP_InsuranceCoveredIndiv__c" : null,  '  + 
    '   "SSP_InsurancePolicy__c" : null  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "HealthCoverageInformation"  '  + 
    '   }  '  + 
    '    ' ; 

    public static final String sHealthInformation =         
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_ApplicationIndividual__c" : null,  '  + 
    '   "SSP_Application__c" : [ {  '  + 
    '   "HasPendingAccidentSettlementToggle__c" : null  '  + 
    '   } ],  '  + 
    '   "SSP_Benefits__c" : null,  '  + 
    '   "SSP_Member__c" : [ {  '  + 
    '   "DCRecoveryIllnessId__c" : null,  '  + 
    '   "DCEMCId__c" : null,  '  + 
    '   "IsReceivingCaretakerServicesToggle__c" : null,  '  + 
    '   "IsRequestingOrReceivingCISToggle__c" : null,  '  + 
    '   "BlindnessVerificationCode__c" : 0,  '  + 
    '   "UnableToBuyCookForSelfToggle__c" : "N",  '  + 
    '   "DisabilityVerificationCode__c" : 0,  '  + 
    '   "TBQIndividualVerificationCode__c" : 0,  '  + 
    '   "DCMemberWorkReqExemptionId__c" : null,  '  + 
    '   "ReturnToWorkDate__c" : null,  '  + 
    '   "IsOnSickLeaveToggle__c" : null,  '  + 
    '   "RecoveryDate__c" : null,  '  + 
    '   "EmergencyEndDate__c" : null,  '  + 
    '   "EmergencyBeginDate__c" : null,  '  + 
    '   "BlindnessStatus__c" : null,  '  + 
    '   "BlindnessBenefitTypeCode__c" : null,  '  + 
    '   "BlindnessParentUnableToCareForChild__c" : null,  '  + 
    '   "BlindnessHasEndStageRenalDisease__c" : null,  '  + 
    '   "DisabilityStatus__c" : null,  '  + 
    '   "ParentUnableToCareForChildToggle__c" : null,  '  + 
    '   "HasEndStageRenalDiseaseToggle__c" : null,  '  + 
    '   "BenefitTypeCode__c" : null,  '  + 
    '   "IsToBeReferredToWicToggle__c" : null,  '  + 
    '   "PregnancyTerminationDate__c" : null,  '  + 
    '   "PregnancyDueDate__c" : null,  '  + 
    '   "NumberOfBirthsExpected__c" : null,  '  + 
    '   "IsPregnantToggle__c" : null,  '  + 
    '   "DCPregnancyId__c" : null,  '  + 
    '   "IsPregnantInLastThreeMonthsToggle__c" : "N",  '  + 
    '   "IsReceivingMedicareBenefitToggle__c" : "N",  '  + 
    '   "IsRecoveryFromIllnessOrInjuryToggle__c" : null,  '  + 
    '   "IsBlindToggle__c" : null,  '  + 
    '   "IsDisabledToggle__c" : null,  '  + 
    '   "HasEmergencyMedicalConditionToggle__c" : null,  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   }, {  '  + 
    '   "DCRecoveryIllnessId__c" : null,  '  + 
    '   "DCEMCId__c" : null,  '  + 
    '   "IsReceivingCaretakerServicesToggle__c" : null,  '  + 
    '   "IsRequestingOrReceivingCISToggle__c" : null,  '  + 
    '   "BlindnessVerificationCode__c" : 0,  '  + 
    '   "UnableToBuyCookForSelfToggle__c" : "N",  '  + 
    '   "DisabilityVerificationCode__c" : 0,  '  + 
    '   "TBQIndividualVerificationCode__c" : 0,  '  + 
    '   "DCMemberWorkReqExemptionId__c" : null,  '  + 
    '   "ReturnToWorkDate__c" : null,  '  + 
    '   "IsOnSickLeaveToggle__c" : null,  '  + 
    '   "RecoveryDate__c" : null,  '  + 
    '   "EmergencyEndDate__c" : null,  '  + 
    '   "EmergencyBeginDate__c" : null,  '  + 
    '   "BlindnessStatus__c" : null,  '  + 
    '   "BlindnessBenefitTypeCode__c" : null,  '  + 
    '   "BlindnessParentUnableToCareForChild__c" : null,  '  + 
    '   "BlindnessHasEndStageRenalDisease__c" : null,  '  + 
    '   "DisabilityStatus__c" : null,  '  + 
    '   "ParentUnableToCareForChildToggle__c" : null,  '  + 
    '   "HasEndStageRenalDiseaseToggle__c" : null,  '  + 
    '   "BenefitTypeCode__c" : null,  '  + 
    '   "IsToBeReferredToWicToggle__c" : null,  '  + 
    '   "PregnancyTerminationDate__c" : null,  '  + 
    '   "PregnancyDueDate__c" : null,  '  + 
    '   "NumberOfBirthsExpected__c" : null,  '  + 
    '   "IsPregnantToggle__c" : null,  '  + 
    '   "DCPregnancyId__c" : null,  '  + 
    '   "IsPregnantInLastThreeMonthsToggle__c" : "N",  '  + 
    '   "IsReceivingMedicareBenefitToggle__c" : "N",  '  + 
    '   "IsRecoveryFromIllnessOrInjuryToggle__c" : null,  '  + 
    '   "IsBlindToggle__c" : null,  '  + 
    '   "IsDisabledToggle__c" : null,  '  + 
    '   "HasEmergencyMedicalConditionToggle__c" : null,  '  + 
    '   "IndividualId__c" : "102437355"  '  + 
    '   } ]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "HealthInformation"  '  + 
    '   }  '  + 
    '    ' ;     
  
    public static final String sHouseHoldOtherInformation =    
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_Application__c" : [ {  '  + 
    '   "ConvictionVerification__c" : 0,  '  + 
    '   "HasConvictedCrimeToggle__c" : "N",  '  + 
    '   "HasConvictedOfTradingDrugsToggle__c" : null,  '  + 
    '   "HasConvictedOfTradingFirearm__c" : null,  '  + 
    '   "HasConvictedOfBuyingSellingToggle__c" : null,  '  + 
    '   "HasGivenWrongInformationToggle__c" : null,  '  + 
    '   "IsParticipatingCompltdTreatmentToggle__c" : null,  '  + 
    '   "IsConvictedChemicallyDependentToggle__c" : null,  '  + 
    '   "IsConvictedOfDrugFelonyToggle__c" : null,  '  + 
    '   "IsFleeingFelonToggle__c" : null  '  + 
    '   } ],  '  + 
    '   "SSP_Attendance__c" : null,  '  + 
    '   "SSP_Benefits__c" : [ {  '  + 
    '   "DCBenefitsId__c" : "EntitledBenefit,93176",  '  + 
    '   "BenefitTypeCode__c" : "BL",  '  + 
    '   "BenefitDenialDate__c" : null,  '  + 
    '   "BenefitDenialReason__c" : null,  '  + 
    '   "StatusofApplication__c" : "A",  '  + 
    '   "BenefitApplicationDate__c" : "2020-11-01",  '  + 
    '   "DCId__c" : 93176,  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "RecordType" : {  '  + 
    '   "Name" : "EntitledBenefit"  '  + 
    '   }  '  + 
    '   } ],  '  + 
    '   "SSP_Member__c" : [ {  '  + 
    '   "DCLAHospitalizationId__c" : null,  '  + 
    '   "HospitalizationEndDate__c" : null,  '  + 
    '   "HospitalizationStartDate__c" : null,  '  + 
    '   "IsFosterCareToggle__c" : "N",  '  + 
    '   "AgeAtFosterCare__c" : null,  '  + 
    '   "IsStateMedicaidprogramCode__c" : "N",  '  + 
    '   "FosterStateCode__c" : null,  '  + 
    '   "ReceivesEntitledIncomeToggle__c" : "Y",  '  + 
    '   "ReceivesSSIBenefitsToggle__c" : "N",  '  + 
    '   "IsMigrantOrSeasonalFarmWorkerToggle__c" : "N",  '  + 
    '   "IsCurrentlyEnrolledInSchoolToggle__c" : "N",  '  + 
    '   "TemporarilyLivesElsewhereToggle__c" : null,  '  + 
    '   "HasHouseholdHomeless__c" : null,  '  + 
    '   "ReceiveInHouseAssistanceToggle__c" : "Y",  '  + 
    '   "InHomeCareType__c" : "NA",  '  + 
    '   "ProviderName__c" : null,  '  + 
    '   "ProviderId__c" : null,  '  + 
    '   "OrganizationName__r" : null,  '  + 
    '   "ExpectedReturnDate__c" : null,  '  + 
    '   "IsWaitingForDecisionToggle__c" : null,  '  + 
    '   "IncarcerationBeginDate__c" : "2016-02-01",  '  + 
    '   "HasRecievedHalfMealsFrmInstToggle__c" : null,  '  + 
    '   "LaTypeCode__c" : "IH",  '  + 
    '   "DCMemberLivingArrangementId__c" : 2309828,  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   } ]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "HouseHoldOtherInformation"  '  + 
    '  }  ' ;      
    
     
    public static final String sMemberInformation =   
    
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_AlienSponsor__c" : null,  '  + 
    '   "SSP_Application__c" : [ {  '  + 
    '   "HasShelterExpExceedIncomeResourcesToggle__c" : "N",  '  + 
    '   "IsDestituteFarmOrMigrantHouseholdToggle__c" : "N",  '  + 
    '   "HouseholdTotalMonthlyGrossIncAmount__c" : 0.00,  '  + 
    '   "HouseholdTotalMonthlyCashSavingAmount__c" : 0.00,  '  + 
    '   "DCCaseNumber__c" : 110945931,  '  + 
    '   "RecordType" : {  '  + 
    '   "Name" : "Case"  '  + 
    '   }  '  + 
    '   } ],  '  + 
    '   "SSP_Member__c" : [ {  '  + 
    '   "HasParentOrSiblingNextOutHousehold__c" : null,  '  + 
    '   "HasParentOrSiblingCurrentOutHousehold__c" : null,  '  + 
    '   "CanBuyCookWithHOH__c" : 1,  '  + 
    '   "ExternalAlienSponsor__r" : null,  '  + 
    '   "InternalAlienSponsor__r" : null,  '  + 
    '   "DCInternalAlienSponsorId__c" : null,  '  + 
    '   "SponsoredByOrganization__c" : null,  '  + 
    '   "DCAlienSponsorRelationship__c" : null,  '  + 
    '   "TaxFilerMemberNext__r" : null,  '  + 
    '   "TaxFilerStatusNextYear__c" : "HH",  '  + 
    '   "TaxFilerMemberCurrent__r" : null,  '  + 
    '   "TaxFilerStatusCurrentYear__c" : "HH",  '  + 
    '   "MailingAddressLine2__c" : "QTI 3",  '  + 
    '   "MailingZipCode5__c" : "02700",  '  + 
    '   "MailingZipCode4__c" : "2998",  '  + 
    '   "MailingStateCode__c" : "KY",  '  + 
    '   "MailingCountyCode__c" : "034",  '  + 
    '   "MailingCity__c" : "SNFCWYJGH",  '  + 
    '   "MailingAddressLine1__c" : "2576 V FDFPLZWFD",  '  + 
    '   "DCMailingAddressId__c" : 35584617,  '  + 
    '   "HasDifferentMailingAddressToggle__c" : null,  '  + 
    '   "PhysicalAddressLine2__c" : "QTI 3",  '  + 
    '   "PhysicalZipCode5__c" : "02700",  '  + 
    '   "PhysicalZipCode4__c" : "2998",  '  + 
    '   "PhysicalStateCode__c" : "KY",  '  + 
    '   "PhysicalCountyCode__c" : "034",  '  + 
    '   "PhysicalCity__c" : "SNFCWYJGH",  '  + 
    '   "PhysicalAddressLine1__c" : "2576 V FDFPLZWFD",  '  + 
    '   "IsFixedAddressToggle__c" : "Y",  '  + 
    '   "DCPhysicalAddressId__c" : "35584616",  '  + 
    '   "PreferredWrittenLanguageCode__c" : "1",  '  + 
    '   "PreferredSpokenLanguageCode__c" : "1",  '  + 
    '   "PreferredNotificationMethodCode__c" : "P",  '  + 
    '   "SecondaryPhoneExtension__c" : "1234",  '  + 
    '   "SecondaryPhoneNumber__c" : "9937299408",  '  + 
    '   "IsPrimaryTextPreferred__c" : "Y",  '  + 
    '   "PrimaryPhoneTypeCode__c" : "CE",  '  + 
    '   "PrimaryPhoneExtension__c" : "",  '  + 
    '   "PrimaryPhoneNumber__c" : "8134567890",  '  + 
    '   "Email__c" : "optim@script.com",  '  + 
    '   "DCId__c" : 3280405,  '  + 
    '   "IsEligibleForIndianHealthServicesToggle__c" : null,  '  + 
    '   "IsEligibleForIHFlagToggle__c" : null,  '  + 
    '   "IndianTribeState__c" : null,  '  + 
    '   "IndianTribeCode__c" : null,  '  + 
    '   "IsFederalRecognizedIndianTribeToggle__c" : null,  '  + 
    '   "HighestEducationGraduatedDate__c" : null,  '  + 
    '   "HighestEducationLevelCode__c" : "11G",  '  + 
    '   "DCMemberHighestEducationLevelDetailsId__c" : 115123,  '  + 
    '   "ImmigrationDateOfBirth__c" : null,  '  + 
    '   "ImmigrationSuffix__c" : null,  '  + 
    '   "ImmigrationLastName__c" : null,  '  + 
    '   "ImmigrationMiddleName__c" : null,  '  + 
    '   "ImmigrationFirstName__c" : null,  '  + 
    '   "IsImmigrationDetailsMatch__c" : 0,  '  + 
    '   "PassportNumber__c" : null,  '  + 
    '   "NaturalizationNumber__c" : null,  '  + 
    '   "I94Number__c" : null,  '  + 
    '   "DocumentOtherDescription__c" : null,  '  + 
    '   "DocumentExpiryDate__c" : null,  '  + 
    '   "CountryOfIssuanceCode__c" : null,  '  + 
    '   "CitizenshipNumber__c" : null,  '  + 
    '   "AlienNumber__c" : null,  '  + 
    '   "ReceiptNumber__c" : null,  '  + 
    '   "SevisId__c" : null,  '  + 
    '   "ImmigrationDocumentTypeCode__c" : null,  '  + 
    '   "AlienTypeCode__c" : null,  '  + 
    '   "HasLivedInUsToggle__c" : null,  '  + 
    '   "IsMilitaryMemberToggle__c" : "N",  '  + 
    '   "HasLegalImmigrationStatusToggle__c" : null,  '  + 
    '   "HasAlienSponsorToggle__c" : null,  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   }]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "MemberInformation"  '  + 
    '   }  '  + 
    '    ' ;  
    
    
    public static final String sRelationshipInformation =     
    '   {  '  + 
    '   "AckResponse" : null,  '  + 
    '   "Payload" : {  '  + 
    '   "SSP_Relationship__c" : [ {  '  + 
    '   "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
    '   "IsActingParentToggle__c" : "N",  '  + 
    '   "IsCareTakerToggle__c" : "N",  '  + 
    '   "RelationshipType__c" : "GS",  '  + 
    '   "DCId__c" : "7957980",  '  + 
    '   "SSP_MemberRelatedTo__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   }  '  + 
    '   }, {  '  + 
    '   "IntendToPursueLegalCustodyToggle__c" : "N",  '  + 
    '   "IsActingParentToggle__c" : "N",  '  + 
    '   "IsCareTakerToggle__c" : "N",  '  + 
    '   "RelationshipType__c" : "GM",  '  + 
    '   "DCId__c" : "7957981",  '  + 
    '   "SSP_MemberRelatedTo__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   },  '  + 
    '   "SSP_Member__r" : {  '  + 
    '   "IndividualId__c" : "999031236"  '  + 
    '   }  '  + 
    '   } ]  '  + 
    '   },  '  + 
    '   "role" : "Citizen_Individual",  '  + 
    '   "miscelleanousParameter" : "",  '  + 
    '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
    '   "mode" : "Renewal",  '  + 
    '   "programCode" : "MA",  '  + 
    '   "individualIds" : "999031236;102437355",  '  + 
    '   "primaryApplicantIndividualId" : "999031236",  '  + 
    '   "caseNumber" : "110945931",  '  + 
    '   "viewName" : "RelationshipInformation"  '  + 
    '   }  '  + 
    '    ' ;   
  
     
     public static final String sResourceInformation =         
     '   {  '  + 
     '   "AckResponse" : null,  '  + 
     '   "Payload" : {  '  + 
     '   "SSP_NonCustodialParent__c" : null,  '  + 
     '   "SSP_NoncustodialRelationship__c" : null  '  + 
     '   },  '  + 
     '   "role" : "Citizen_Individual",  '  + 
     '   "miscelleanousParameter" : "",  '  + 
     '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
     '   "mode" : "Renewal",  '  + 
     '   "programCode" : "MA",  '  + 
     '   "individualIds" : "999031236;102437355",  '  + 
     '   "primaryApplicantIndividualId" : "999031236",  '  + 
     '   "caseNumber" : "110945931",  '  + 
     '   "viewName" : "AbsentParentInformation"  '  + 
     '   }  '  + 
     '     '  + 
     '   ResourceInformation:  '  + 
     '   {  '  + 
     '   "AckResponse" : null,  '  + 
     '   "Payload" : {  '  + 
     '   "SSP_Application__c" : [ {  '  + 
     '   "HasOtherResourceToggle__c" : "N",  '  + 
     '   "HasLTCAgreementToggle__c" : "N",  '  + 
     '   "HasBurialPlotsToggle__c" : "N",  '  + 
     '   "HasBurialFundToggle__c" : "N",  '  + 
     '   "HasLifeSettlementContractToggle__c" : "N",  '  + 
     '   "HasPartnershipQualifiedLTCPolicyToggle__c" : "N",  '  + 
     '   "HasPromissoryNoteOrLandContractToggle__c" : "N",  '  + 
     '   "HasLifeEstateToggle__c" : "N",  '  + 
     '   "HasAnnuityToggle__c" : "N",  '  + 
     '   "HasSpecialNeedTrustToggle__c" : "N",  '  + 
     '   "IsAssetsInExcess1MToggle__c" : null,  '  + 
     '   "DCCaseNumber__c" : "110945931",  '  + 
     '   "RecordType" : {  '  + 
     '   "Name" : "Case"  '  + 
     '   }  '  + 
     '   } ],  '  + 
     '   "SSP_ResourceOwnership__c" : null,  '  + 
     '   "SSP_Asset__c" : null,  '  + 
     '   "SSP_Member__c" : [ {  '  + 
     '   "HasPreArrangedFuneralContractToggle__c" : "N",  '  + 
     '   "HasLifeInsuranceToggle__c" : "N",  '  + 
     '   "HasRealEstatePropertyToggle__c" : "N",  '  + 
     '   "HasVehicleToggle__c" : "N",  '  + 
     '   "HasCashReloadableMoneyCardToggle__c" : "N",  '  + 
     '   "HasInvestmentsToggle__c" : "N",  '  + 
     '   "HasOwnBankAccountToggle__c" : "N",  '  + 
     '   "IndividualId__c" : "999031236"  '  + 
     '   }, {  '  + 
     '   "HasPreArrangedFuneralContractToggle__c" : "N",  '  + 
     '   "HasLifeInsuranceToggle__c" : "N",  '  + 
     '   "HasRealEstatePropertyToggle__c" : "N",  '  + 
     '   "HasVehicleToggle__c" : "N",  '  + 
     '   "HasCashReloadableMoneyCardToggle__c" : "N",  '  + 
     '   "HasInvestmentsToggle__c" : "N",  '  + 
     '   "HasOwnBankAccountToggle__c" : "N",  '  + 
     '   "IndividualId__c" : "102437355"  '  + 
     '   } ]  '  + 
     '   },  '  + 
     '   "role" : "Citizen_Individual",  '  + 
     '   "miscelleanousParameter" : "",  '  + 
     '   "applicationID" : "a2Rr00000007UPlEAM",  '  + 
     '   "mode" : "Renewal",  '  + 
     '   "programCode" : "MA",  '  + 
     '   "individualIds" : "999031236;102437355",  '  + 
     '   "primaryApplicantIndividualId" : "999031236",  '  + 
     '   "caseNumber" : "110945931",  '  + 
     '   "viewName" : "ResourceInformation"  '  + 
     '  }  ' ;                                        // Wrapper Structure
    
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
                                                            '           "DCId__c": 887742,  '  + 
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
                                               '         "primaryApplicantIndividualId": "999031236",   '+
                                               '         "individualIds": "999031236;999034363",    '+
                                               '         "programCode": "MA;KT;SN", '+
                                               '         "mode": "Intake",  '+
                                               '         "applicationID": "a0Xr0000000sp8T",    '+
                                               '         "miscelleanousParameter": null,    '+
                                               '         "Payload": {   '+
                                               '           "Benefit": [ '+
                                               '            {   '+
                                               '              "CaseNumber": "100059325",    '+
                                               '              "IndividualId": "999031236",  '+
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
                                                    '     "primaryApplicantIndividualId" : "999031236",      '+
                                                    '     "individualIds" : "999031236",      '+
                                                    '     "programCode" : "MA;KT;SN",      '+
                                                    '     "mode" : "Intake",      '+
                                                    '     "applicationID" : "a0Xr0000000sp8T",      '+
                                                    '     "miscelleanousParameter" : null,      '+
                                                    '     "Payload"     : {      '+
                                                      '     "Individual"  : [      '+
                                                    '    {  '+
                                                          '     "CaseNumber" : "100059325",      '+
                                                          '     "IndividualId" : "999031236",      '+
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
                                                            '   "IndividualId" : "999031236",  '  + 
                                                            '   "BirthDate" : "1998-06-01",  '  + 
                                                            '   "GenderCode" : "M",  '  + 
                                                            '   "SuffixCode" : null,  '  + 
                                                            '   "MiddleInitial" : null,  '  + 
                                                            '   "LastName" : "Dave",  '  + 
                                                            '   "FirstName" : "David"  '  + 
                                                            '   } ],  '  + 
                                                            '   "CaseInfo" : [ {  '  + 
                                                            '   "LastEligibilityTransactionDate" : "2020-11-11T09:56:28.903",  '  + 
                                                            '   "MedicaidApplicationType" : null,  '  + 
                                                            '   "ApplicationSourceType" : null,  '  + 
                                                            '   "IndividualId" : "999031236",  '  + 
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
                                                            '   "primaryApplicantIndividualId" : "999031236",  '  + 
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