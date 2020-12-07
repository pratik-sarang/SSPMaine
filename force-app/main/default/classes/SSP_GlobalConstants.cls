/* @File Name          : SSP_GlobalConstants.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/04/2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
* 1.0       12/04/2019             Sanchita Tibrewala           Initial Version
**/
public class SSP_GlobalConstants {
    //checking git Dec07
    public static final String PHONE_TYPE_CODE = 'LND';
    public static final String CHILD_CARE_CODE = 'CC';
    public static final String OTHER_RELATIONSHIP = 'Other Relationship';
    public static final String UNRELATED = 'Unrelated';
    public static final String AMERICAN_INDIAN_RACE_CODE = 'IN';
    public static final String MAGI = 'MAGI';
    public static final String KP = 'KP';
    public static final String NO = 'N';
    public static final String YES = 'Y'; 
    public static final String FEMALE = 'F'; 
    public static final String MALE = 'M';
    public static final String BOTH = 'B';
    public static final Set<String> IN_HOME_ASSISTANCE_PROGRAMS = new Set<String>{'MA', 'KT', 'SN', 'SS', 'CC'};
    public static final Set<String> PREGNANCY_ASSISTANCE_PROGRAMS = new Set<String>{'MA', 'KT', 'SN', 'SS'};
    public static final List<String> CONTACT_INFORMATION_PROGRAMS = new List<String>{'MA', 'KT', 'SN', 'SS', 'CC', 'KP'};
    public static final List<String> FORMER_FOSTER_CARE_PROGRAMS = new List<String>{'MA', 'KT', 'SN', 'SS', 'CC'};
    public static final Set<String> ALIEN_SPONSOR_PROGRAMS = new Set<String>{'MA', 'KT', 'SN'};
    public static final Set<String> CONVICTION_PROGRAMS = new Set<String>{'KT', 'SN'};
    public static final Set<String> MCO_SELECTION_PROGRAMS = new Set<String>{'MA', 'SS'};
    public static final Set<String> ALL_PROGRAMS = new Set<String>{'MA', 'KT', 'SN', 'SS', 'DS', 'CC', 'KP'};
    public static final Set<String> SSI_BENEFITS_PROGRAMS = new Set<String> {'MA', 'SS'};
    public static final Set<String> BENEFITS_STATE_PROGRAMS = new Set<String> {'MA', 'SN', 'KT'};
    public static final Set<String> ADDRESS_PROGRAMS = new Set<String> {'MA', 'KP', 'SN', 'KT', 'CC', 'SS'};
    public static final String ZERO = '0';
    public static final List<String> HEARING_REP_ROLES = new List<String>{'Authorized Representative', 'Assister', 'Organization_Auth_Rep', 'Individual_Auth_Rep'};
    public static final String HEARING_PARTY_TYPE_DEFAULT_VALUE = 'INDV';
    public static final String NOTIFICATION_EXTENSION_DEFAULT_VALUE = 'pdf';
    public static final String REP_ROLE_ASSISTER_VALUE = 'Assister';
    public static final Map<String,String> REP_ADDRESS_MAP = New Map<String,String>{'AddressLine1__c' => 'RepresentativeAddressLine1', 'AddressLine2__c' => 'RepresentativeAddressLine2',
        'City__c' => 'RepresentativeCity', 'CountyCode__c' => 'RepresentativeCounty', 'StateCode__c' => 'RepresentativeState',
        'CountryCode__c' => 'RepresentativeCountry', 'ZipCode4__c' => 'RepresentativeZip4', 'ZipCode5__c' => 'RepresentativeZip5'};
        
    //Relationship Constants
    public static final Set<String> CHILD_CODE_SET = new Set<String> {'DA', 'AD', 'SO', 'AS'};
    public static final Set<String> PARENT_CODE_SET = new Set<String> {'FA', 'MO'};       
    
    public static final String OBJECT_NAME = 'objectName';
    public static final String ELIGIBILITY_SUMMARY_VIEW_NAME ='EligibilitySummary';
    public static final String SSPDC_F_Message='F';
    public static final String SSPDC_HBE3_Message='HBE3000';
    public static final String SSPDC_HBE1_Message='HBE1000';
    public static final String SSPDC_LOG2_Message='LOG2000';
    public static final String SSPDC_LOG3_Message='LOG3000';
    public static final String SSPDC_LOG4_Message='LOG4000';
    public static final String SSPDC_LOG1_Message='LOG1000';
    public static final String SSPDC_P_Message='P';
    public static final String EligibleForKIHIPP_False='0';
    public static final String IsReferredToFFM_False='N';
    public static final String  EligibleForExpeditedSNAP_False='0';
    public static final String DEFAULT_AGE='0';
    public static final String MEMBER_STATUS_DELETED ='Deleted';
    public static final String APPLICATION_NUMBER ='applicationNumber';
    public static final String CASE_NUMBER ='caseNumber';
    public static final String RECORD_TYPE ='RecordType';
    
    // HouseHold Summary Constants 
    public static final set<String> SSP_MEMBER_FIELDS_HH_SUMMARY = new Set<String>{'Id','Name','Alias_First_Name__c','Alias_Last_Name__c','BirthDate__c','FirstName__c','DeathDateVerificationCode__c', 'MiddleInitial__c','LastName__c','SSN__c','GenderCode__c','Age__C','TaxFilerMemberCurrent__c','TaxFilerMemberNext__c', 'TaxFilerStatusCurrentYear__c', 'TaxFilerStatusNextYear__c', 'IsDateOfDeathValidated__c',
                                                                                           'IsIntendToResideToggle__c','RaceCode__c','IsMilitaryMemberToggle__c','HasSSN__c','IsUSCitizenToggle__c','SuffixCode__c','NationalityCode__c','IsHispanicLatinoSpanishToggle__c',
                                                                                           'EthnicityCode__c','DeathDate__c','NoReasonSSNCode__c','SpecialNeedIndicatorToggle__c','SSNVerified__c','IndividualId__c','IsUSCitizenValidated__c','MatchType__c', 'Contact__c', 'Contact__r.FirstName', 'Contact__r.LastName', 'IsFileCleared__c',
                                                                                           'SameAddressInfoAsHOHToggle__c', 'MailingAddressLine1__c', 'PhysicalAddressLine1__c', 'IsBlindToggle__c', 'IsDisabledToggle__c', 'Identify_verification_method__c', 'Reference_Number__c', 'Non_Citizen_Verification_Flag__c'
                                                                                        };//Added Contact__r.FirstName & Contact__r.LastName - CD2
                                                                                        
    public static final List<String> HH_SUMM_OBJECTS_APINAMES =  new list<String>{'SSP_Application__c','SSP_ApplicationIndividual__c','SSP_Member__c'};
    public static final set<String> SSP_APPLICATION_FIELDS_HH_SUMMARY = new Set<String>{'Id','ProgramsApplied__c','Account__c','DCCaseNumber__c','SectionStatus__c', 'Name' , 'RecordTypeId'} ;   
    public static final list<String> SSP_APPLICATION_WHERE_CONDITIONS_FIELDS = new list<String>{'Id'};  
        
    public static final set<String> SSP_APPLICATION_INDIV_FIELDS_HH_SUMMARY = new Set<String>{'Id','SSP_Application__c','SSP_Member__c','MemberProgramsApplied__c','ProgramsApplied__c','IsHeadOfHousehold__c','MemberStatus__c','isHOHDetailsCompleted__c','MCIcount__c','IsActiveIEESCasePresent__c','BlockedCaseNumber__c' , 'isApplicationBlocked__c', 'IsRACSNAPMealsRuleTriggered__c', 'MedicaidType__c','IsTMember__c'};    

    public static final String NATIONALITY_AS ='AI,CH,FI,JP,KR,OA,VT'; 
    public static final String NATIONALITY_HPI ='GU,NH,OPI,SM'; 
    public static final String DATA_PARSE_ERROR='Error in the data: Please check with Admin';
    public static final String NO_RECORD_FROM_MCI='No record was returned from MCI';
    public static final String SOURCE_SYSTEM_NAME='HBE';
    public static final String SOURCE_SYSTEM_INT='INT';
    public static final String SCREEN_ID_HH_DETAIL='SSP_APP_HHMemberDetails';
    public static final String PARTIAL_MATCH='Partial Match';
    public static final String FULL_MATCH='Full Match';
    public static final String NO_MATCH='No Match';
    public static final String ERROR_CODE_SSN_VALIDATION='ERRSSN001';
    public static final String ERROR_CODE_SSN_VERIFICATION='ERRSSN002';
    public static final String SSN_Verification_Error ='SSN_Verification_Error';
    public static final String SFCalloutException = 'SFCalloutException';
    public static final String BizTalk_Error = 'BizTalk Error';
    public static final String Cannot_Apply='Cannot_Apply';
    public static final String MEMBER_ADDED_TWICE = 'memberAddedTwice';
    public static final String SSP_APP_HHMembersSummary='SSP_APP_HHMembersSummary';
    public static final String MCI_SERVICE='SSP_MergedMCIService';
    public static final String SECTION_STATUS_Complete='COMPLETED';
    public static final String DEFAULT_EMPTY_STRING='';
    public static final String SOURCE_MEMBER='Member';
    public static final String SF_OBJECT_MEMBER='SSP_Member__c';
    public static final List<String> EDUCATION_SUMMARY_PROGRAMS_WITHOUT_AGE_CHECK = new List<String>{'KT','CC'};
    public static final String EDUCATION_SUMMARY_PROGRAMS_WITH_AGE_CHECK_MA = 'MA';
    public static final String EDUCATION_SUMMARY_PROGRAMS_WITH_AGE_CHECK_SN ='SN';
    public static final Integer EDUCATION_SUMMARY_MA_AGE_MIN = 18; 
    public static final Integer EDUCATION_SUMMARY_SN_AGE_MIN = 15;
    public static final Integer EDUCATION_SUMMARY_SN_AGE_MAX = 49;
    public static final String INVALID_SSN_START_DIGIT='9';

    //Added by Shrikant
    public static final String HAS_ALIMONY_EXPENSE =  'HasAlimonyExpenseToggle__c';
    public static final String HAS_HOUSEHOLD_PAID_CHILD_SUPPORT =  'HasHouseholdPaidChildSupportToggle__c';
    public static final String HAS_DEPENDENT_CARE_EXPENSE=  'HasDependentCareExpenseToggle__c';
    public static final String HAS_MEDICAL_BILLS=  'HasMedicalBillsToggle__c';
    public static final String HAS_SHELTER_EXPENSE=  'HasShelterExpenseToggle__c';
    public static final String HAS_TAX_DEDUCTION_EXPENSE=  'HasTaxDeductionsExpenseToggle__c';
    public static final String HAS_UTILITY_EXPENSE =  'HasUtilityExpenseToggle__c';
    public static final String HAVE_HIGHER_EDUCATION_EXPENSE=  'HaveHigherEducationExpenseToggle__c';
    public static final String SNAP =  'SN';
    public static final String TANF =  'TN';
    public static final String MEDICAID =  'MA';
    public static final String CHILDCARE =  'CC';
    public static final String STATE =  'SS';
    public static final String KTAP =  'KT';
    public static final String KHIPP =  'KP';     
    public static final String PE =  'PE';
    public static final String BCCTP =  'BCCTP';
     public static final String SHELTER_EXPENSE_TYPE =  'SE';
     public static final String UTILITY_EXPENSE_TYPE =  'UE';
     public static final String EDUCATION_EXPENSE_TYPE =  'EE';
     public static final String MEDICAL_EXPENSE_TYPE =  'ME';
     public static final String DEPENDENT_CARE_EXPENSE_TYPE =  'DCE';
     public static final String TAX_DEDUCTION_EXPENSE_TYPE =  'DE';
     public static final String ALIMONY_EXPENSE_TYPE =  'AL';
      public static final String CHILD_SUPPORT_EXPENSE_TYPE =  'CAE';
     public static final String DIVIDEND_INCOME_TYPE =  'DIR';
    public static final String UNPAID_INCOME_TYPE =  'UI';
    public static final String EARNED_EMPLOYMENT_INCOME_TYPE =  'EA';
    public static final String SELF_EMPLOYMENT_INCOME_TYPE =  'SE';
    public static final String SERVICE_INCOME_TYPE =  'OUI';
    public static final String MAINTENANCE_INCOME_TYPE =  'SM';
    public static final String INSURANCE_INCOME_TYPE =  'IS';
    public static final String UNEARNED_INCOME_TYPE =  'SRP';
    
    // Used in  SSP_Utility Method. Added by Sai
    public static final String sWhereClauseKey = 'WHERE';
    public static final String sOrderByKey = 'ORDERBY';
    public static final String sLimitKey = 'LIMIT'; 
    public static final String sOffset = 'OFFSET';
    public static final String sGroupByKey = 'GROUPBY'; 
    public static final Set<String> setStdFields = new Set<String>{'id', 'createddate', 'lastmodifieddate', 'createdby', 'lastmodifiedby','profile','owner'};
    public static final Set<String> stdObjName = new Set<String>{'Account','Contact'};
        //Added by Sai
    public static final String sProgramValidationStartMsg = 'You already have a previous benefit from another state entry for ';
    public static final String sProgramValidationStartMsgPart2 = '. Benefit dates cannot be overlapping. Please correct the date for this entry to save.';
    //AnotherState Benefit Fields - Added By Sai
    public static final Integer SIX_MONTH = 6;
    public static final Integer ONE_MONTH = 1;
    public static final String sBenefitFields = 'ID,BenefitStateCountyKey__c,BenefitPrograms__c,State__c,BenefitInfoCounty__c,BeginDate__c,EndDate__c,SSP_Member__c';
    public static final String sBenefitFieldsWhereClause = 'SSP_Member__c =: sMemberId AND BenefitPrograms__c IN:benefitProgramTypes AND ((EndDate__c >= :dateBeforeMonth AND EndDate__c <= :dateAfterMonth) OR EndDate__c = NULL)';

    //Constant Used in SSP-DC Service Call
    public static final String RAC_AddMember = 'addRemoveMember';
    public static final String SUCCESS = 'Success';
    public static final String STATUS_INACTIVE = 'Inactive';
    //Resources Constants
    public static final Integer IRANDOMVALUELENGTH = 6;
    public static final String MEMBERID = 'memberId';
    public static final String APPLICATIONID = 'applicationId';
    public static final String EXISTINGRESOURCES = 'ExistingResources';
    public static final String ASSETOBJECTNAME = 'SSP_Asset__c';
    public static final String ID = 'Id';
    public static final String RESOURCERECORDTYPENAME = 'Resource';
    public static final String RESOURCETYPEAPI = 'ResourceType__c';
    public static final String SOBJECTFIELD = 'SObjectField__c';
    public static final String REQUIREDRESOURCES = 'requiredResources';
    public static final String NOTREQUIREDRESOURCES = 'notRequiredResources';
    public static final String NONMAGI = 'Non-MAGI';
    public static final String MEDICAIDNONMAGI = 'MedicaidNonMagi';
    public static final String RESREQUIRINGDETAILS = 'ResRequiringDetails';
    public static final String RESNOTREQUIRINGDETAILS = 'ResNotRequiringDetails';
    public static final String ADDITIONALDETAILS = 'AdditionalDetails';
    public static final String COMMA = ',';
    public static final String COLON = ';';
    public static final String STRRESOURCEID = 'strResourceId';
    public static final String STRMEMBERID = 'strMemberId';
    public static final String STRAPPLICATIONID = 'strApplicationId';
    public static final String REMOVE = 'remove';
    public static final String ADD = 'add';
    public static final String EMPTYARRAY = '[]';
    public static final String EMPTY = '';
    public static final String HOUSEHOLDMEMBERS = 'householdMembers';
    public static final String RESOURCETYPECODE = 'ResourceTypeCode__c';
    public static final String BOOLEANTYPE = 'Boolean';
    public static final String CURRENCYTYPE = 'Currency';
    public static final String DATETYPE = 'Date';
    public static final String STRADDITIONALOWNERS = 'strAdditionalOwners';
    public static final String ADDITIONALOWNERSFIELD = 'AdditionalOwners__c';
    public static final String STROTHEROWNERS = 'strOtherOwners';
    public static final String OTHER = 'Other';
    public static final String STRTEMPRESID = 'strTempResId';
    public static final String STRRESOURCETYPE = 'strResourceType';
    public static final String UPDATEDRESOURCEDETAILS = 'updatedResourceDetails';
    public static final String INSURANCEPOLICIES = 'insurancePolicies';
    public static final String STRINSURANCECOVEREDINDIVID = 'strInsuranceCoveredIndivId';
    public static final String FUNERALFUNDCODEFIELD = 'FuneralFundCode__c';
    public static final String FUNERALCONTRACTRESOURCETYPE = 'FA';
    public static final String OTHERVALUE = ',Other';
    public static final String FUNDOPTIONLIFEINSURANCE = 'BO';
    public static final String RTYPE = 'Rtype';
    public static final String LINEONE = 'line1';
    public static final String LINETWO = 'line2';
    public static final String RESOURCEOWNERSHIPOBJECT = 'SSP_ResourceOwnership__c';
    public static final String JOINTOWNERSHIPRECORDTYPE = 'JointOwnership';
    public static final String SSPAPPLICATIONOBJECT = 'SSP_Application__c';
    public static final String SSPMEMBEROBJECT = 'SSP_Member__c';
    public static final String ALL = 'All'; 
    public static final String OTHERS = 'Others';
    public static final String ISASSETSINEXCESSTOGGLE = 'IsAssetsInExcess1MToggle__c';
    public static final String PROGRAMSAPPLIED = 'ProgramsApplied';
    public static final String RESOURCEFIELDMAPPINGS = 'resourceFieldMappings';
    public static final String INSURANCEASSETS = 'insuranceAssets';
    public static final String ASSETRECORD = 'assetRecord';
    public static final String STANDARDFIELDS = 'standardFields';
    public static final String ADDITIONALOWNERS = 'additionalOwners';
    public static final String RESOURCEOWNERSHIPS = 'resourceOwnerships';
    public static final String RESOURCESELECTIONDETAILS = 'resourceSelectionDetails';
    public static final String MAPMEMBERSRESOURCECOUNT = 'mapMembersResourceCount';
    public static final String INCOMERECORDTYPENAME = 'Income';
    public static final String EXPENSERECORDTYPENAME = 'Expense';
    public static final String APPRECORDTYPENAME = 'SSP_Application';
    public static final String CASERECORDTYPENAME = 'Case';
    public static final String MODEVALUE = 'mode';
    public static final String LIQUID_RESOURCE_TYPE_ESNAP='CA,CH,SA';
    public static final String PRIMARYUSERINDIVIDUAL = 'PrimaryUserIndividual__c';
    public static final String PRIMARYUSERIFOTHER = 'PrimaryUserIfOther__c';
    public static final String REFERENCE = 'REFERENCE';

    public static final String Monthly='MO';
    public static final String BI_Weekly='BW';
    public static final String TWICEAMONTH='SM';
    public static final String Week='WE';
    public static final String Yearly='YR';
    public static final String Quarterly='QU';
    
    //SSI Benefit Constants - Added by Sai
    public static final String OBJ_SSIBENEFIT = 'SSP_Benefits__c';
    public static final String SSIBENEFIT_RECORDTYPE = 'SSIBenefits';
    
    public static final String ABSENT_PARENT = 'Absent Parent';
     public static final String MEDICAID_PROGRAM = 'Medicaid/KCHIP';
     public static final String SNAP_PROGRAM = 'SNAP (Food Assistance)';
     public static final String KTAP_PROGRAM = 'KTAP (Cash Assistance)';
     public static final String CHILDCARE_PROGRAM = 'Child Care Assistance';
     public static final String KHIPP_PROGRAM = 'KI-HIPP (Health Insurance Premium Payments)';
     public static final String STATE_PROGRAM = 'State Supplementation';
     public static final String AUTHORIZED_REPRESENTATIVE_ROLE = 'Authorized Representative';
     public static final String ASSISTER_ROLE = 'Assister';
     public static final String INSURANCE_AGENT_ROLE = 'Insurance Agent';
     public static final String CONTACT_AUTH_REP_RECORDTYPE='Auth_Rep';
    
    public static final String fathersCodeList = 'FA';
    public static final String mothersCodeList = 'MO';
    public static final String ORGANIZATION = 'Organization';
    public static final String AUTH_REP_PERMISSION_ST = 'ST';
    public static final String AUTH_REP_PERMISSION_NT = 'NT';
    public static final String AUTH_REP_PERMISSION_SE = 'SE';
    public static final String AUTH_REP_PERMISSION_CC = 'CC';
    public static final String AUTH_REP_PERMISSION_CA= 'CA';
    public static final String AUTH_REP_PERMISSION_ET = 'ET';
    public static final String AUTH_REP_PERMISSION_PY = 'PY';
    
    public static final string SCHOOL_RECORDTYPE_NAME = 'School';
    public static final String INSURANCE_EXTERNAL_POLICY_HOLDER = 'InsuranceExternalPolicyHolder';
    public static final String INSURANCE_EXTERNAL_COVERED_INDIVIDUAL = 'InsuranceExternalCoveredIndividual';
    
    public static final String IMMIGRATION_DOCTYPE_DHS = 'DHS';
    public static final String IMMIGRATION_DOCTYPE_CZ = 'CZ';
    public static final String IMMIGRATION_DOCTYPE_HHS = 'HHS';
    public static final String IMMIGRATION_DOCTYPE_CHE = 'CHE';
    public static final String IMMIGRATION_DOCTYPE_WR = 'WR';
    public static final String IMMIGRATION_DOCTYPE_DS2 = 'DS2';
    public static final String IMMIGRATION_DOCTYPE_I20 = 'I20';
    public static final String IMMIGRATION_DOCTYPE_I3 = 'I3';
    public static final String IMMIGRATION_DOCTYPE_AR = 'IAR';
    public static final String IMMIGRATION_DOCTYPE_I57 = 'I57';
    public static final String IMMIGRATION_DOCTYPE_I76 = 'I76';
    public static final String IMMIGRATION_DOCTYPE_I9 = 'I9';
    public static final String IMMIGRATION_DOCTYPE_I9F = 'I9F';
    public static final String IMMIGRATION_DOCTYPE_MRV = 'MRV';
    public static final String IMMIGRATION_DOCTYPE_AI = 'AI';
    public static final String IMMIGRATION_DOCTYPE_INT = 'NT';
    public static final String IMMIGRATION_DOCTYPE_NA = 'NA';
    public static final String IMMIGRATION_DOCTYPE_I79 = 'I79';
    public static final String IMMIGRATION_DOCTYPE_ORR = 'ORR';
    public static final String IMMIGRATION_DOCTYPE_OREL = 'OREL';
    public static final String IMMIGRATION_DOCTYPE_OT = 'OT';
    public static final String IMMIGRATION_DOCTYPE_INA1 = 'INA1';
    public static final String IMMIGRATION_DOCTYPE_INA3 = 'INA3';
    public static final String IMMIGRATION_DOCTYPE_RAS = 'RAS';
    public static final String IMMIGRATION_DOCTYPE_I5 = 'I5';
    public static final String IMMIGRATION_DOCTYPE_FP = 'FP';
    
    //NotUSCitizen Constants -- Added by Shivam
    public static final String SSP = 'SSP';
    public static final String CHP = 'CHP';
    public static final String AR = 'AR';
    public static final String CV = 'CV';
    public static final String CUBAN_HAITIAN = 'Cuban/Haitian';
    public static final Set<String> NOT_US_CITIZEN_PROGRAMS = new Set<String>{'MA', 'KT', 'SN', 'SS', 'CC'};
    
    //Pregnancy Constants -- Added by Shivam
    public static final String PREGNANCY_SCREEN_ID = 'SSP_APP_Details_Pregnancy';
    
    //Waiver Constants -- Added by Shivam
    public static final List<String> ALL_WAIVER_ROLES = new List<String>{'CASE MANAGER IN TRAINING', 'CAPACITY MANAGEMENT ADMINISTRATOR', 'WAIVER DIRECT SERVICE PROVIDER SUPERVISOR', 'WAIVER DIRECT SERVICE PROVIDER', 'INTERNAL LOC ASSESSOR', 'SERVICE NEEDS ASSESSOR', 'POC REVIEWER', 'LOC REVIEWER', 'LEVEL OF CARE ASSESSOR', 'CHFS APPLICATION INITIATOR', 'APPLICATION INITIATOR', 'APPLICATION REVIEWER', 'CASE MANAGEMENT ADMINISTRATOR (INTERNAL)', 'WAIVER CAPACITY REVIEWER', 'CASE MANAGER', 'CASE SUPERVISOR','CASE MANAGEMENT ADMINISTRATOR (READ ONLY)', 'PROD SUPPORT (READ ONLY)', 'CHFS INTERNAL REVIEWER'};
    public static final list<String> waiverRoles = new list<String>{
        'APPLICATION_INITIATOR',
        'APPLICATION_REVIEWER',
        'CASE_MANAGEMENT_ADMINISTRATOR_INTERNAL',
        'WAIVER_CAPACITY_REVIEWER',
        'CASE_MANAGER',
        'CASE_SUPERVISOR',
        'CHFS_APPLICATION_INITIATOR',
        'LEVEL_OF_CARE_ASSESSOR',
        'LOC_REVIEWER',
        'POC_REVIEWER',
        'SERVICE_NEEDS_ASSESSOR',
        'INTERNAL_LOC_ASSESSOR',
        'WAIVER_DIRECT_SERVICE_PROVIDER',
        'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR',
        'CAPACITY_MANAGEMENT_ADMINISTRATO',
        'CASE_MANAGER_IN_TRAINING',
        'Case_Management_Administrator_Read_Only',
        'PROD_Support_Read_Only',
        'CHFS_Internal_Reviewer'
        };
    
    //App Config Csustom Setting Constants -- Added by Shivam
    public static final String BACKYARD_URL = 'BackyardURL';
    //SSP interface Team Constants 
    public static final String ROLE_DOESNOT_EXIST = 'role doesnot match'; // SSP_Interface_Security Fixes
    public static final String CPJITHANDLER = 'CPJITHandler'; // SSP_Interface_Security Fixes
    public static final String CREATE_USER = 'createUser'; // SSP_Interface_Security Fixes
    public static final String CALLOUT_COLON = 'callout:'; // SSP_Interface_Security Fixes
    public static final String STATUS_COLON = 'Status : '; // SSP_Interface_Security Fixes
    public static final String PROCESS_RESPONSE = 'processResponse'; // SSP_Interface_Security Fixes
    public static final String CANCELLED = 'Cancelled'; // SSP_Interface_Security Fixes
    public static final String FALSE_VAL= 'false'; // SSP_Interface_Security Fixes
    public static final String UPDATE_ALL= 'UpdateAll'; // SSP_Interface_Security Fixes
    public static final String EMPLOYMENT= 'Employment'; // SSP_Interface_Security Fixes
    public static final String PAY_PERIOD= 'PayPeriod'; // SSP_Interface_Security Fixes
    public static final String ORDER_CUSTOMFIELD_APINAME= 'order__c'; // SSP_Interface_Security Fixes
    public static final String TRACKDELETE_CUSTOMFIELD_APINAME= 'SSP_TrackDeletion__c'; // SSP_Interface_Security Fixes
    public static final String INSURANCE_CUSTOMFIELD_APINAME= 'SSP_InsurancePolicy__c'; // SSP_Interface_Security Fixes
    //Short SNAP flow Constants -- Added by Shivam
    public static final String SNAP_FULL = 'SNAP';
    public static final String SSP_DCSNAP = 'SSP_DCSNAP';
    public static final String HBE_055 = 'HBE-055';
    public static final String SF_SSPUser = 'SF-SSPUser';
    public static final String LP = 'LP';
    public static final String SN_CODE = 'SN';
    public static final String NEW_CODE = 'NEW';
    public static final String SF_SSP_SYSTEM_TRG = 'SF_SSP_SYSTEM_TRG';
    public static final String GenerateCorrespondence = 'GenerateCorrespondence';
    public static final String AnonymousShortSNAP = 'AnonymousShortSNAP';
    public static final String YES_CODE = 'Y';
    public static final String SSP_Correspondence = 'SSP_Correspondence';
    
    //sspHeader Constants -- Added by Shivam
    public static final String HOH = 'HOH';
    public static final String DEP = 'DEP';
    public static final String TMEM = 'TMEM';
    public static final String CHANGE = 'CHANGE';

    //sspBenefits Constants -- Added by Shivam
    public static final String ChildCareAssistance = 'Child Care Assistance';
    public static final String ChildCareSpanish = 'Ayuda para Cuidados Infantiles';
    public static final String Kinship = 'Kinship';
    public static final String KC_Code = 'KC';
    public static final String KinshipCare = 'Kinship Care';
    public static final String zeroValue = '0';
    public static final String PE_Code = 'PE';
    public static final String AP_Code = 'AP';
    public static final String PI_Code = 'PI';
	public static final String DN_Code = 'DN';
    public static final String DC_Code = 'DC';
    public static final String UR_Code = 'UR';
    
    public static final String CONTENT_DISPOSITION = 'content-disposition';
    public static final String ATTACHMENT_MORE_HELP_AND_INFORMATION = 'Attachment; filename=More Help & Information.pdf';
    public static final String SCREEN_MORE_HELP_AND_INFORMATION = 'SSP_APP_More_Help_Info';
    public static final String LANGUAGE_CODE_US_ENGLISH = 'en_US';
    public static final String MEDICARE_COVERAGE = 'Medicare Coverage';
    public static final String MEDICAREBENEFIT = 'MedicareBenefit';
    public static final String EFT = 'EFT';
    public static final String CH = 'CH';
    public static final String MAP_URL = 'https://www.google.com/maps/dir/?api=1&destination=';
    public static final String LONG_TERM_CARE = 'LTC';
    public static final String PSYCHIATRIC_TREATMENT = 'APF';
       
    public static final String INDIVIDUAL_LEVEL_PROGRAMS_MEDICATE='MA,SS';
    public static final String HOUSEHOLD_LEVEL_PROGRAMS='SN,KP';
    public static final String STATUS_CODE_PENDING_VERIFICATION='P';
    public static final String STATUS_CODE_PENDING_INTERVIEW='I';
    public static final String STATUS_CODE_ONE='1';
    public static final String RE_CITIZEN_PROFILE ='RE Citizen Profile';

    //Renewal Flow Constants - Added by Shrikant
    public static final String SSP_OP_BACKUP = 'backup';
    public static final String SSP_OP_RESTORE = 'restore';
    public static final String SSP_PROGRAMS_FIELD = 'ProgramsApplied__c';
    public static final String SSP_PROGRAMS_BACKUP_FIELD = 'ProgramsAppliedRenewal__c';
    public static final String SSP_PROGRAM_TO_BE_RETAINED = 'MA';
    public static final String SSP_OPERATOR = 'operator';
    public static final String SSP_OBJECT_NAME = 'objectName';
    public static final Set<String> SSP_INCOMESEL_MEMBERLEVEL_PROGRAMS = new Set<String>{'MA','SN','KT','CC','SS'};
    public static final Set<String> SSP_EXPENSESEL_PROGRAMS = new Set<String>{'MA','SN','KT','CC'};
    public static final Set<String> SSP_INCOMESEL_APPLEVEL_PROGRAMS = new Set<String>{'CC'};   
    public static final String SSP_APPLEVEL = 'appLevel';
    public static final String SSP_INDVLEVEL = 'indvLevel';

    public static final String SSP_RENEWAL_FLOW = 'Renewal';
    public static final String SSP_INTAKE_FLOW = 'Intake';
    public static final String SSP_RAC_FLOW = 'RAC';
    public static final String SSP_RAC_MODIFY_FLOW_SECTION = 'ModifyExistingData';
    public static final String SSP_RAC_ADDMEMBER_SECTION = 'AddRemoveMember';
    public static final Set<String> SSP_AVAILABLE_PROGRAMS = new Set<String>{MEDICAID, SNAP, KTAP, CHILDCARE, KHIPP};    

    public static final String SSP_MODE = 'mode';
    public static final String SSP_CASE_NO = 'caseNo';
    public static final String SSP_PROGRAMS = 'programs';
    public static final String SSP_INDV_ID = 'indvId';
    public static final String SSP_APP_ID = 'appId';
    public static final String SSP_FLOW_NAME = 'flowName';
    public static final String SSP_APPLICATION_ID = 'applicationId';
    public static final String APPOBJECTNAME = 'SSP_Application__c';
    //Shrikant CD-2
    public static final String USER_DETAILS = 'userDetails';
    public static final String USER_ROLE = 'userRole';
    public static final String INDIVIDUAL_ID = 'individualId';
    public static final String SELECTED_ROLE = 'selectedrole';
    public static final String NON_CITIZEN_PROFILE = 'SSP Non Citizen Profile';
    public static final String DAIL_WORKER_ROLE = 'DailWorker';
    public static final Map<String, Set<String>> ROLE_TO_PROGRAM_MAPPING = new Map<String, Set<String>>{DAIL_WORKER_ROLE => new Set<String>{STATE}};
    public static final String OBJ_APPLICATION_INDIVIDUAL = 'SSP_ApplicationIndividual__c';
    public static final String MDT_ROLE_PROGRAM_MAPPING = 'Role_Program_Mapping__mdt';
    public static final String MDT_SCREEN_PERMISSIONS = 'ScreenPermissions__mdt';
    public static final String MDT_FIELD_PERMISSIONS = 'FieldPermissions__mdt';
    public static final Set<String> MDT_SCREEN_PERMISSIONS_FIELDS = new Set<String>{'Id', 'CanDelete__c', 'Permission__c', 'Role__c', 'ScreenName__c'};
    public static final Set<String> MDT_FIELD_PERMISSIONS_FIELDS = new Set<String>{'FieldElementName__c', 'Permission__c', 'Role__c','ScreenName__c'};
    public static final String OBJ_MEMBER = 'SSP_Member__c';
    public static final String OBJ_APPLICATION = 'SSP_Application__c';
    public static final String OPERATOR_AND = 'AND';
    public static final String OPERATOR_OR = 'OR'; 
    public static final String OPERATOR_IN = 'IN';
    public static final String OPERATOR_EQUAL_TO = '=';
    public static final String OPERATOR_NOT_EQUAL_TO = '!=';
    public static final String KEY_LIMIT = 'LIMIT';
    public static final String TRUE_VALUE = '#true#';
    public static final String FALSE_VALUE = '#false#';
    public static final Set<String> ALL_AVAILABLE_PROGRAMS = new Set<String>{MEDICAID, SNAP, KTAP, CHILDCARE, KHIPP, STATE, PE, BCCTP};    
    public static final Map<Integer, String> AVAILABLE_PROGRAMS_SEQ = new Map<Integer, String>{1 => MEDICAID, 2 => SNAP, 3 => KTAP, 4 => CHILDCARE, 5 => KHIPP, 6 => STATE};   
    public static final String DUMMY_KEY = 'DUMMYDATA';
    public static final String KEY_RESPONSE_APP_INDV = 'responseAppIndv';
    public static final String KEY_UI_APP_INDV = 'uiAppIndv';
    public static final String KEY_RESPONSE_MEMBER = 'responseMember';
    public static final String KEY_UI_MEMBER = 'uiMember';

    //#384763                                                                                        
    public static final String continueNotificationCode ='SF-TOD-001';
    public static final String continueFieldId = 'INDV_DB_2';

    //#385049
    public static final String EMERGENCY_MEDICAL_QUESTIONS = 'Emergency Medical Condition and Disability';
    public static final String CIS_CARETAKER_QUESTIONS = 'Community Integration Supplementation and Caretaker Services';
    
    //Screen Permissions
    public static final String READ_ONLY = 'ReadOnly';
    public static final String NOT_ACCESSIBLE = 'NotAccessible';
    public static final String EDITABLE = 'Editable';                                                                                        
    //ProgramSelection changes
    public static final String CITIZEN_RECORD_CREATION = 'citizenRecordCreation';
    public static final String IMPERSONATED_W_INDVID_RECORD_CREATION = 'impersonatedCitizenWithIndividualId';
    public static final String QUALIFIED_INDV_CALL = 'qualifiedIndividualCall';
    public static final String IMPERSONATED_WO_INDVID_RECORD_CREATION = 'impersonatedCitizenWOIndividualId';
    //CareTakerServices CD-2
    public static final String CARE_TAKER_SERVICES = 'sspCareTakerServices';
    public static final String CIS = 'sspCommunityIntegrationSupplementation';
    public static final String KEY_APP_INDVS = 'applicationIndividuals';
    public static final String KEY_CARE_TAKER_RELATIONS = 'careTakerRelations';
    public static final String KEY_CIS_RELATIONS = 'cisRelations';
    public static final String KEY_PROGRAM_ACCESS_DETAILS = 'programAccessDetails';
    public static final String KEY_ACCESS_DETAILS = 'accessDetails';
    public static final String KEY_HAS_PERMISSON='hasPermission';
    public static final String CARETAKER_SERVICES_SCREENID = 'SSP_APP_MD_CS';
    public static final String CIS_SCREENID = 'SSP_APP_MD_CIS';
    public static final String CITIZEN_ROLE=	'Citizen_Individual';
    // Added new Roles QE_Hospital and QE_Pregnancy CD-2
    public static final String QE_HOSPITAL_ROLE = 'QE_Hospital';
    public static final String QE_PREGNANCY_ROLE = 'QE_Pregnancy';
    public static final String JAILOR=	'Jailor';
    public static final String ORGANISATION_AUTH_REP=	'Organization_Auth_Rep';
    public static final String DOC_REPRESENTATIVE=	'DOC_Representative';
    
    //DashboardController CD-2
    public static final String KEY_ACCESSIBLE_PROGRAMS='accessiblePrograms';
    public static final String  HH_EDUCATION_SUMMARY_SCREENID = 'SSP_APP_Details_EducationSummary';
    public static final String  HH_HIGHEST_EDUCATION_DETAILS_SCREENID = 'SSP_APP_Details_HighestEducationDetails';
    public static final String  HH_CURRENT_EDUCATION_DETAILS_SCREENID = 'SSP_APP_Details_CurrentEducationDetails';
    public static final String  HH_ABSENTP_SUMMARY_SCREENID = 'SSP_APP_Details_AbsentParentSummary';
    public static final String  HH_ABSENTP_DETAILS_SCREENID = 'SSP_APP_Details_AbsentParentDetails';

    public static final String  HH_INCOME_SUMMARY_SCREENID = 'SSP_APP_Details_IncomeSummary';
    public static final String  HH_INCOME_DETAILS_SCREENID = 'SSP_APP_Details_IncomeDetails';

    public static final String  HH_EXPENSE_SUMMARY_SCREENID = 'SSP_APP_Details_Expense';
    public static final String  HH_EXPENSE_DETAILS_SCREENID = 'SSP_APP_Details_ExpenseDetails';

    public static final String  HH_RESOURCE_SUMMARY_SCREENID = 'SSP_APP_Details_Resource';
    public static final String  HH_RESOURCE_DETAILS_SCREENID = 'SSP_APP_Details_ResourceDetails';   
    
    public static final String  BENEFITS_ANOTHER_STATE_SUMMARY_SCREENID = 'SSP_APP_Details_BenefitsFromAnotherState';
    public static final String  BENEFITS_ANOTHER_STATE_DETAILS_SCREENID = 'SSP_APP_Details_BenefitsFromAnotherStateDetails';
    
    public static final String  HEALTHC_ENROLL_SUMMARY_SCREENID = 'SSP_APP_Healthcare_EnrollmentSummary';
    public static final String  HEALTHC_ENROLL_DETAILS_SCREENID = 'SSP_APP_Healthcare_EnrollDetails';
    public static final String  HEALTHC_ENROLL_INDV_DETAILS_SCREENID = 'SSP_APP_Healthcare_IndivEnrollDetails';
    
    public static final String  HEALTHC_ACCESS_SUMMARY_SCREENID = 'SSP_APP_Healthcare_AccessSummary';
    public static final String  HEALTHC_ACCESS_DETAILS_SCREENID = 'SSP_APP_Healthcare_AccessDetails';
    public static final String  HEALTHC_ACCESS_INDV_DETAILS_SCREENID = 'SSP_APP_Healthcare_IndivAccessDetails'; 

    public static final String  MEDICARE_COVERAGE_SUMMARY_SCREENID = 'SSP_APP_Details_MedicareCoverageSummary'; 
    public static final String  MEDICARE_COVERAGE_DETAILS_SCREENID = 'SSP_APP_Details_MedicareCoverageDetails';

    public static final String  INCOME_SELECTION_SCREENID = 'SSP_APP_Select_Income';
    public static final String  OTHER_RESOURCE_SELECTION_SCREENID = 'SSP_APP_Select_Resources_2';
    public static final String  RESOURCE_SELECTION_SCREENID = 'SSP_APP_Select_Resources_1';
    public static final String  EXPENSE_SELECTION_SCREENID = 'SSP_APP_Select_Expenses';
    public static final String  MY_INFORMATION_LANDING_SCREENID = 'INFO_LandingPage';
    public static final String  PROGRAM_SELECTION_SCREENID = 'SSP_APP_ProgramSelection';
    public static final String  INDIVIDUAL_DASHBOARD_SCREENID = 'SSP_APP_IndvDashboard';
    public static final String  APPLICATION_SUMMARY_SCREENID = 'SSP_APP_ApplicationSummary';
    public static final String  ELIGIBILITY_RESULTS_SCREENID = 'SSP_APP_Details_EligibilityResults';
    public static final String  NEXT_STEPS_SCREENID = 'SSP_APP_Details_NextSteps';
    public static final String  RAC_CHANGES_SCREENID = 'SSP_RAC_SelectChangesToReport';
    public static final String  CHANGE_SUMMARY_SCREENID = 'SSP_APP_ChangeSummary';
    public static final String  RENEWAL_SUMMARY_SCREENID = 'SSP_APP_RenewalSummary';
    public static final String  GET_STARTED_RENEWAL_SCREENID = 'SSP_APP_GetStartedRenewal';
    public static final String  RAC_HH_COMPOSITION_SCREENID = 'SSP_APP_RACHHComposition';

    public static final String  REQUEST_MEDICAID_CARD_SCREENID='SSP_APP_REQUESTMEDICAIDCARD';
    public static final String  REQUEST_EBT_CARD_SCREENID='SSP_APP_REQUESTEBTCARD';
    public static final String  CHILDCARE_ENROLLEMENT_SUMMARY_SCREENID='SSP_APP_CHILDCAREENROLLMEMNTSUMMARY';


    public static final String  APP_AGREEMENT_SCREENID = 'SSP_APP_Agree_AppAgreement'; 
    public static final String  MEDICAID_PENALTY_SCREENID = 'SSP_APP_Agree_MedicaidPenalty';
    public static final String  SNAP_INFO_RULES_SCREENID = 'SSP_APP_Agree_SNAPInfoRules';
    public static final String  LTC_RESOURCE_TRANSFER_SCREENID = 'SSP_APP_Agree_LTCResourceTransfer';
    public static final String  DECLARATION_ANNUITIES_SCREENID = 'SSP_APP_Agree_DeclarationAnnuities';
    public static final String  KIHIPP_CONSENT_SCREENID = 'SSP_APP_Agree_KIHIPPConsent';
    public static final String  HELP_AND_INFO_SCREENID = 'SSP_APP_HelpAndInfo';
    public static final String  EARLY_SUBMISSION_SCREENID = 'SSP_APP_EarlySibmission';
    public static final String  EXPEDITED_SNAP_SCREENID = 'SSP_APP_ExpeditedSNAP';
    public static final String  ELIGIBILITY_RESULTS_LOADING_SCREENID = 'SSP_APP_EligibilityResultsLoading';
    public static final String  NON_CITIZEN_DASHBOARD_SCREENID = 'SSP_APP_NonCitizenDashboard';
    public static final String  VERIFICATION_DOCS_POPUP_SCREENID = 'SSP_APP_VerificationDocsPopup';

    public static final String  VERIFICATION_DOCS_POPUP = 'verificationDocumentsPopupPermission';
    public static final String  RAC_HH_COMPOSITION = 'securityMatrixRACHHComposition';
    public static final String  EXPEDITED_SNAP = 'securityMatrixExpeditedSNAP';
    public static final String  ELIGIBILITY_RESULTS_LOADING = 'securityMatrixEligibilityResultsLoading';
    public static final String  EARLY_SUBMISSION = 'screenPermissionEarlySubmission';
    public static final String  HELP_AND_INFO = 'securityMatrixHelpAndInformation';
    public static final String  APP_AGREEMENT = 'securityMatrixAppAgreement';
    public static final String  MEDICAID_PENALTY = 'securityMatrixMedicaidPenalty';
    public static final String  SNAP_INFO_RULES = 'securityMatrixNAPInfoRules';
    public static final String  LTC_RESOURCE_TRANSFER = 'securityMatrixLTCResourceTransfer';
    public static final String  DECLARATION_ANNUITIES = 'securityMatrixDeclarationAnnuities';
    public static final String  KIHIPP_CONSENT = 'securityMatrixKIHIPPConsent';

    public static final String  SECURITY_MATRIX_ELIGIBILITY = 'securityMatrixEligibility';
    public static final String  SECURITY_MATRIX_NEXT_STEPS = 'securityMatrixNextSteps';

    public static final String  SECURITY_MATRIX_SUMMARY = 'securityMatrixSummary';   
    public static final String  SECURITY_MATRIX_DETAILS = 'securityMatrixDetails';
     
    public static final String  SECURITY_MATRIX_ENROLL_SUMMARY = 'securityMatrixEnrollmentSummary'; 
    public static final String  SECURITY_MATRIX_ENROLL_DETAILS = 'securityMatrixEnrollmentDetails';  
    public static final String  SECURITY_MATRIX_ENROLL_INDV_DETAILS = 'securityMatrixEnrollmentIndividualDetails';
    
    public static final String  SECURITY_MATRIX_ACCESS_SUMMARY = 'securityMatrixAccessSummary'; 
    public static final String  SECURITY_MATRIX_ACCESS_DETAILS = 'securityMatrixAccessDetails';  
    public static final String  SECURITY_MATRIX_ACCESS_INDV_DETAILS = 'securityMatrixAccessIndividualDetails';  

    public static final String  SCREEN_PERMISSION_KEY = 'screenPermission';  

    
    public static final String FIRST_NAME_IS_MANDATORY = 'FirstName is Mandatory';
	public static final String CONTACT_TRIGGER_HANDLER = 'ContactTriggerHandler';
	public static final String CREATE_CITIZEN_ACCOUNT = 'createCitizenAccount';
	public static final String MCI_ENTITIY_SEARCH = 'MCI Entity Search';
	public static final String CALLOUT_TO_MCI_SERVICE_IS_FAILED = 'Callout to MCI service is Failed';
	public static final String MCI_SERVICE_HANDLER = 'MciServiceHandler';
	public static final String GET_INDIVIDUAL_BENEFIND = 'getIndividualBenefindId';
	public static final String RE_ASSISTER_PROFILE = 'RE Assister Profile';
	public static final String KOG_INQUIRY_SERVICE = 'KOG Inquiry Service';
	public static final String ERROR_IN_RECEIVING_ROLEPROVISION = 'Error in receiving the roleProvision from KOG';
	public static final String RECOMMUNITYPARTNERLOGIN = 'RECommunityPartnerLogin';
	public static final String SEND_EMAIL_TO_COMMUNITY_PARTNER = 'sendEmailtoCommunityPartner';
	public static final String ERROR_IN_RECEIVING_CONTEXTID = 'Error in receiving the context id from KOG';
	public static final String RE_COMMUNITY_PARTNER_ADMIN = 'RE_Community_Partner_Admin';
	public static final String COMMUNITY_PARTNER_ADMIN = 'Community Partner Admin';
	public static final String COMMUNITY_PARTNER_STAFF = 'Community Partner Staff';
	public static final String RE_COMMUNITY_PARTNER_STAFF = 'RE_Community_Partner_Staff';
	public static final String RE_COMMUNITY_PARTNER_USER_PROFILE = 'RE Community Partner User Profile';
	public static final String ERROR_WHILE_CREATING_USER = 'Error while creating user';
	public static final String COMMUNITYPARTNERLOGIN = 'communityPartnerLogin';
	public static final String ERROR_WHILE_CREATING_PERMISSION_SET = 'Error while creating Permission set';
	public static final String METADATA_NOT_PRESENT_IN_SYSTEM = 'Metadata not present in system.';
	public static final String ERROR_WHILE_CREATING_CONTACT_RECORD = 'Error while creating a contact record in salesforce';  
	public static final String RE_RESIDENTLOGIC = 'RE_ResidentLogic';
	public static final String CREATE_CITIZEN_CONTACT = 'createCitizenContact';
	public static final String ELIGIBILITY_BENEFIT_INQUIRY_USER = 'Eligibility_Benefit_Inquiry_User';
	public static final String ERROR_WHILE_CREATING_CITIZEN_USER = 'Error while creating citizen userx';
	public static final String CREATE_CITIZEN_USER = 'createCitizenUser';
	public static final String ERROR_WHILE_CREATING_CONTACT_MAPPING = 'Error while Contact Mapping Record Creation';
	public static final String THIS_IS_DUPLICATE_CONTACT = 'This is a duplicate the contact';
	public static final String CONTACT_MAPPING = 'Contact Mapping';
	public static final String GET_INDIVIDUAL_INFO = 'getIndividualInfo';
	public static final String SSP_RESIDENT_LOGIC = 'SSP_ResidentLogic';
	public static final String ASSIGN_PERMISSIONSET = 'assignPermissionset';
	public static final String ERROR_WHILE_DELETING_PERMISSION_SET = 'Error while deleting Permission set';
	public static final String INSERT_LIST_SOBJECT = 'insertListSObject';
    public static final String SSP_NON_CITIZEN_USER_LOGIN = 'SSP_NonCitizenUserLogic';
    public static final String ERROR_WHILE_CREATING_CONTACT = 'Error while Updating a contact record in salesforce';

    //Dashboard Constants 
     public static final String BENEFIT_STATUS_PENDINGINTERVIEW = 'PI';
     public static final String BENEFIT_STATUS_PENDINGVERIFICATION = 'PE';
     public static final String BENEFIT_STATUS_APPROVED = 'AP';
     public static final String CACHE_PARTITION_NAME = 'local.SSP';
    public static final String ROLE_AUTH_REP = 'AUTHREP';
    public static final String ROLE_ASSISTER = 'ASSISTER';
    public static final String ROLE_AGENT = 'AGENT';
    
    //Added by Ashwin
    public static final Integer MEMBER_AGE = 65;
    public static final String UNKNOWN = 'U';
    public static final String NULL_Value = 'NULL';
    public static final String HISTORICAL = 'H';
    public static final String MODE = 'addRemoveMember';
    public static final String MEMBER_STATUS_New = 'New';    
    
    //Added by Ashwin
    public static final String Document_STATUS_Code_Valid = 'CO';
    public static final String Document_STATUS_Code_NotValidated = 'PE';
    public static final String Document_STATUS_Code_Invalid = 'IV';    
    //Added by Ashwin For Auth Rep Request Access Screen
    public static final String FullMatch_Label = 'Full Match';  
    public static final String PartialMatch_Label = 'Partial Match';  
    public static final String HBE_System_Label = 'HBE';  
    public static final String MA_Label = 'Medicaid';  
    public static final String SN_Label = 'SNAP';  
    public static final String KP_Label = 'KI-HIPP';  
    public static final String SS_Label = 'State Supplementation';  
    public static final String KT_Label = 'KTAP';  
    public static final String CC_Label = 'Child Care Assistance';
	public static final String Auth_Rep = 'Auth_Rep';
    public static final String RoleType_AuthRep = 'Auth Rep';
    public static final String RoleType_Assister = 'Assister';
    public static final String Role_AuthRep = 'Authorized Representative';
    
    //Added by Ashwin
    public static final String HAMBURGER = 'hamburger'; //Added as part of Defect - 383060
    public static final String ES_US = 'es_US'; //Added as part of Defect - 382855
    public static final String UnSubmittedApplication = '{"applicationSubmittedToggle":true}'; // Added as part of Defect - 382837
    public static final String RoleType_Agent = 'Agent'; // Added as part of Defect - 392986
     //Added by Rahul
    public static final String CLIENT_ACCEPTED = 'Client Accepted';
    public static final String CLIENT_REJECTED = 'Client Rejected';
    public static final String NO_RESPONSE = 'No Action';
    public static final String PROGRAM_TYPE_MA = 'MA';
    public static final String PROGRAM_TYPE_KP = 'KP';
    public static final String RoleType_ForAssister = 'Assister';
    public static final String MA_LABEL_ASSISTER = 'true';
    public static final String KIHIPP_LABEL_ASSISTER = 'true';
    public static final String INDIVIDUAL_AUTH_REP = 'Individual_Auth_Rep';
    public static final String ORGANIZATION_AUTH_REP = 'Organization_Auth_Rep';
    public static final String ASSISTER = 'Assister';
    public static final String AGENCY_ADMIN = 'Agency_Admin';
    //SHikha
    public static final String MEMBER_REMOVE_STATUS = 'Removed';

    //Tax Filing Constants
    public static final String CURRENTENROLLMENTYEAR = 'CurrentEnrollmentYear';
    public static final String ISINOPENENROLLMENT = 'IsInOpenEnrollment';
    public static final String TAXFILINGDETAILS = 'taxFilingDetails';
    public static final String TAXFILINGMEMBERS = 'taxFilingMembers';
    public static final String RELATIONSHIPS = 'relationships';
    public static final String TMEMBERSTATUS = 'T';
    public static final String TAXFILERSTATUSCURRENTYEAR = 'TaxFilerStatusCurrentYear__c';
    public static final String TAXFILERSTATUSNEXTYEAR = 'TaxFilerStatusNextYear__c';
    public static final String TAXFILINGSAMENEXTYEAR = 'TaxFilingSameNextYear__c';
    public static final String TAXFILINGCLAIMINGCURRENTYEAR = 'TaxFilingClaimingCurrent__c';
    public static final String TAXFILINGCLAIMINGNEXTYEAR = 'TaxFilingClaimingNext__c';
    public static final String HASPARENTORSIBLINGCURRENTOUTHOUSEHOLD = 'HasParentOrSiblingCurrentOutHousehold__c';
    public static final String HASPARENTORSIBLINGNEXTOUTHOUSEHOLD = 'HasParentOrSiblingNextOutHousehold__c';
    public static final String TAXFILERMEMBERCURRENT = 'TaxFilerMemberCurrent__c';
    public static final String TAXFILERMEMBERNEXT = 'TaxFilerMemberNext__c';
    public static final String TMEMBERHOUSEHOLDSTATUS = 'IN';
    public static final String RELATIONSHIPSANDTAXFILINGFLOWNAME = 'Relationships&TaxFiling';
    public static final String NOTMEMBERS = 'NoTMembers';
    public static final String TMEMBERSNOTTRIGGERED = 'TMemberNotTriggered';
    public static final String WIAPROGRAMCODE = 'WIA';
    public static final String TAAPROGRAMCODE = 'TAA';
    public static final String PREVIOUSTAXFILINGSTATUS = 'previousTaxFilingStatus';
    public static final String REVIEWREQUIREDRESPONSE = 'reviewRequiredResponse';
    public static final String TAXFILINGPAGE = 'SSP_APP_RTF_TaxFiling';
    public static final String REVIEWREQUIREDLIST = 'reviewRequiredList';
    public static final String DEPENDANTMEMBERMAP = 'dependantMemberMap';
    public static final String NEWDEPENDANTMEMBERMAP = 'newDependantMemberMap';
    public static final String REMOVEDDEPENDANTS = 'removedDependants';

        //RAC Non Citizen
    public static final String SSP_Non_Citizen_Profile = 'SSP Non Citizen Profile';
    public static final String individualId = 'individualId';
    
    //Agency Management Constants
    public static final String APPLICATION = 'Application';
    public static final String CITIZEN = 'Citizen';
    public static final String DATEFORMAT = 'MM/dd/yyyy';

    //Driver Navigation
    public static final String INDIVDIUDAL_AUTH_REP_ROLE_STRING = 'Individual_Auth_Rep';
    public static final String DAIL_WORKER_ROLE_STRING = 'DAIL_Worker';
    public static final String APPLICATION_STATUS_BLOCKED = 'Blocked';
        //Non Citizen Client Search
    public Static Final String query ='Select Id, IsHeadOfHousehold__c,SSP_Application__r.ApplicationCreationInSSP__c,SSP_Application__r.LastModifiedDate,SSP_Application__r.Account__c,SSP_Member__r.FirstName__c,SSP_Member__r.IndividualId__c,SSP_Member__r.LastName__c,SSP_Member__r.GenderCode__c,SSP_Member__r.BirthDate__c,SSP_Application__r.Name,SSP_Member__r.SSN__c,SSP_Member__r.MailingAddressLine1__c ,SSP_Member__r.MailingCountyCode__c,SSP_Member__r.PrimaryPhoneNumber__c,SSP_Member__r.MaidCardNumber__c,SSP_Member__r.Email__c, SSP_Member__r.MailingAddressLine2__c, SSP_Member__r.MailingZipCode5__c,toLabel(SSP_Application__r.Status__c) from SSP_ApplicationIndividual__c where (SSP_Application__r.Status__c =\'UN\' or (SSP_Application__r.Status__c =\'P\'and SSP_Application__r.SSPDCMessage__c=\'HBE3000\' )) and SSP_Application__r.Recordtype.Name = \'Application\' $searchQuery$ ORDER BY SSP_Application__r.LastModifiedDate DESC limit 200'; //#378934
    
    public Static Final String queryAccessAssociated='Select Id,IsHeadOfHousehold__c, SSP_Application__r.ApplicationCreationInSSP__c,SSP_Application__r.LastModifiedDate,SSP_Application__r.Account__c,SSP_Member__r.FirstName__c,SSP_Member__r.IndividualId__c,SSP_Member__r.LastName__c,SSP_Member__r.GenderCode__c,SSP_Member__r.BirthDate__c,SSP_Application__r.Name,SSP_Member__r.SSN__c,SSP_Member__r.MailingAddressLine1__c ,SSP_Member__r.MailingCountyCode__c,SSP_Member__r.PrimaryPhoneNumber__c,SSP_Member__r.MaidCardNumber__c,SSP_Member__r.Email__c, SSP_Member__r.MailingAddressLine2__c, SSP_Member__r.MailingZipCode5__c,toLabel(SSP_Application__r.Status__c) from SSP_ApplicationIndividual__c where ( SSP_Application__r.Status__c =\'UN\'  or (SSP_Application__r.Status__c =\'P\'and SSP_Application__r.SSPDCMessage__c=\'HBE3000\' )) and SSP_Application__r.Recordtype.Name = \'Application\' AND SSP_Application__r.Account__c in :setofClientAccountId $searchQuery$ ORDER BY SSP_Application__r.LastModifiedDate DESC limit 200'; //#378934
    
    //#379715
    public static final String ELIGIBILITY_BENEFIT_ROLE_API = 'Eligibility_&_Benefit_Inquiry_User';
    public static final String ELIGIBILITY_BENEFIT_PERMISSION_SET_API = 'Eligibility_Benefit_Inquiry_User';

    //Message Center
    public static final String SF_TOD_002 = 'SF_TOD_002';
    public static final String SF_TOD_003 = 'SF_TOD_003';
    public static final String SF_NOT_002 = 'SF_NOT_002';
    public static final String SF_NOT_003 = 'SF_NOT_003';
    public static final String AGENCY_ADMIN_ROLE = 'Agency_Admin';
    public static final String NOTIFICATION_CITIZEN = 'Citizen';
    public static final String NOTIFICATION_ASSISTER = 'Assister';
    public static final String NOTIFICATION_ORG_AUTH_REP = 'Organization Auth Rep';
    public static final String NOTIFICATION_AGENCY_ADMIN = 'Agency Admin';
    public static final String NOTIFICATION_IND_AUTH_REP = 'Individual Auth Rep';
    public static final String LANGUAGE_CODE_US_SPANISH = 'eS_US';
    public static final String MESSAGE_EE = 'EE';
    public static final String MESSAGE_ES = 'ES';
    public static final String MESSAGE_P = 'P';
    public static final String IN_PROGRESS_STATUS = 'In Progress';
    public static final String MESSAGE_SUBJECT = 'Benefind {0}.';
    public static final String MESSAGE_HEADER = 'Hi {0}, <br/><br/>';
    public static final String MESSAGE_FOOTER = '<br/><br/>Please do not reply to this message. Responses are routed to an unmonitored email box.';
    public static final String NOTIFICATION_ACTIVE = 'Active';
    public static final String NOTIFICATION_EXPIRED = 'Expired';
    public static final String VIRUS_AFFECTED = 'Virus Scan Failure';
    public static final String PASSWORD_PROTECTED = 'Password Protected Document';
    public static final String SF_TOD_004_DOCCENTER = 'SF_TOD_004_DocCenter';
    public static final String SF_TOD_005_DOCCENTER = 'SF_TOD_005_DocCenter';
    public static final String SF_TOD_004_DOCCENTER_CODE = 'SF-TOD-005-DocCenter';
    public static final String SF_TOD_005_DOCCENTER_CODE = 'SF-TOD-004-DocCenter';
    public static final String CRITICAL_NOTIFICATION = 'Notification';    

    //HealthSelection - Changes
    public static final String FLOWSTATUS_R = 'R';
    public static final String FLOWSTATUS_N = 'N';
    public static final String FLOWSTATUS_C = 'C';
    public static final String DISABILITY_SCREEN = 'SSP_APP_Details_Disability';
    public static final String BLINDNESS_SCREEN = 'SSP_APP_Details_Blindness';
    public static final String EMC_SCREEN = 'SSP_APP_Details_HealthCondition';
    public static final String FLOWNAME_HEALTH = 'MemberHealthInformation';
    public static final String CIS_SCREEN = 'SSP_APP_MD_CIS';
    public static final String CIS_CARETAKER = 'SSP_APP_MD_CS';

    public static final Set<String> AUTH_REP_ROLES = new Set<String>{ORGANISATION_AUTH_REP, INDIVDIUDAL_AUTH_REP_ROLE_STRING};
    public static final String SF_NOT_002_CODE = 'SF-NOT-002';
    public static final String SF_NOT_003_CODE = 'SF-NOT-003';
    public static final String SF_TOD_001 = 'SF_TOD_001';
   //CD2 Roles
    public static final String INSURANCEAGENT_ROLE = 'Insurance_Agent';
    public static final Set<String> ASSISTER_ROLES = new Set<String>{AGENCY_ADMIN_ROLE, ASSISTER_ROLE};
    public static final Set<String> REPS_HOME_ROLES = new Set<String>{INSURANCEAGENT_ROLE, ASSISTER_ROLE,INDIVDIUDAL_AUTH_REP_ROLE_STRING,ORGANISATION_AUTH_REP,AGENCY_ADMIN_ROLE};
    
    public static final String DENIED_LABEL = System.Label.SSP_Denied;
    public static final String DISCONTINUED_LABEL = System.Label.SSP_Discontinued;
    public static final String APPROVED_LABEL = System.Label.SSP_Approved;
    public static final String PENDING_LABEL = System.Label.SSP_Pending;
    
    //RIDP Services Data
    public static final String RIDP_LEGAL_FIRST_NAME = 'LegalFirstName';
    public static final String RIDP_LEGAL_LAST_NAME = 'LegalLastName';
    public static final String RIDP_MIDDLE_NAME = 'MiddleName';
    public static final String RIDP_NAME_SUFFIX ='NameSuffix';
    public static final String RIDP_BIRTH_DATE='BirthDate';
    public static final String RIDP_SSN='SSN';
    public static final String RIDP_STREET_NAME='StreetName';
    public static final String RIDP_CITY_NAME='CityName';
    public static final String RIDP_STATE='State';
    public static final String RIDP_POSTAL_CODE='PostalCode';
    public static final String RIDP_POSTAL_CODE_EXTENSION='PostalCodeExtension';
    public static final String RIDP_FULL_TELEPHONE_NUMBER='FullTelephoneNumber';
    public static final String RIDP_USER_KOGID='userKOGID';
    public static final String RIDP_IDENTITY_VERIFICATION_METHOD='IdentityVerificationMethod';
    public static final String RIDP_REFERENCE_NUMBER='ReferenceNumber';
    public static final String RIDP_GENDER='Gender';
    public static final String RIDP_INDIVIDUALID='Individualid';
    public static final String RIDP_RESPONSE_CHECK='Identity proofing request Successful';
    public static final String RIDP_RESUME_RIDP_VALUE='Resume RIDP';
    public static final String RIDP_NON_CITIZEN_FLAG='NonCitizenVerificationFlag';
    
    public static final List<String>   RIDP_MEMBER_QUERY_FIELDS= new List<String>{'Id','Contact__c','IndividualId__c','Identify_verification_method__c','SSN__c','MailingAddressLine1__c','MailingCity__c','MailingStateCode__c','MailingZipCode5__c','MailingZipCode4__c','PrimaryPhoneNumber__c','BirthDate__c','SuffixCode__c','FirstName__c','LastName__c','MiddleInitial__c','Reference_Number__c','GenderCode__c','Non_Citizen_Verification_Flag__c'};                                                                              

    public static final List<String> RIDP_UPADTE_REFERENCE_NUMBER = new List<String>{'Id','Identify_verification_method__c','Reference_Number__c'};
    public static final String RIDP_LANGUAGUE_PREFERENCE='EN-US';

    //Identity Verification Upload

    public static final String IDENTITY_DOCUMENT_UPLOAD_FOP_OPTIONS='FormOfProofOptions';

//User ROLEs
public static final String ROLE_CONTACT_CENTER_VIEW_AND_EDIT='Contact_Center_View_and_Edit';
public static final String ROLE_CONTACT_CENTER_VIEW_ONLY='Contact_Center_View_Only';
public static final String ROLE_MAIL_CENTER_SUPERVISOR='Mail_Center_Supervisor';
public static final String ROLE_MAIL_CENTER_WORKER='Mail_Center_Worker';

//batch

public static final String BATCH_RECORDTYPE_DEVNAME_SSPAPPLICATION='SSP_Application';
public static final String BATCH_SSP_APPLICATION_STATUS_UN='UN';
public static final String BATCH_SSP_APPLICATION_STATUS_INACTIVE='Inactive';



    //Request a Card 
public static final String REQUEST_CARD_CASENUMBER= 'memberCaseNumber';
public static final String REQUEST_CARD_INDIVIDUALID= 'memberIndividualId';
public static final String REQUEST_CARD_REASON= 'whyReplace';
public static final String REQUEST_CARD_CHILDCARESUMMARYSUBMITTYPE='ChildCareEnrollmentSummary';
public static final String REQUEST_CARD_COMMENT= 'addInfo';
public static final String REQUEST_CARD_EBT_CARD_STATUS_VALUE='RR';
public static final String REQUEST_CARD_COUNTY_CODE='countyCode';

public static final String REQUEST_CARD_ISDCBS='isDCBS';
public static final String REQUEST_CARD_ISDCBS_YES='Y';
public static final String REQUEST_CARD_ISDCBS_TRUE_VALUE='true';
public static final String REQUEST_CARD_ISDCBS_NO='N';
public static final String REQUEST_CARD_EBT_MODE_VALUE='New';
public static final String REQUEST_CARD_VALIDATION_CHECK ='"Status":true';
public static final String REQUEST_CARD_DCBS_OFFICEID='officeId';
public static final String REQUEST_CARD_HOH_CHECK='HOH';
public static final String REQUEST_CARD_MEDICAID_DATA='medicaidData';
public static final String REQUEST_CARD_EBT_DATA='ebtData';
public static final String REQUEST_CARD_SHOW_MEDICAID_LINK='showMedicaidLink';
public static final String REQUEST_CARD_SHOW_EBT_LINK='showEBTLink';
public static final String REQUEST_CARD_HOH_VALUE='bIsHOH';
public static final String REQUEST_CARD_OFFICE_RECORDID='recordId';

//Reference Data Service
public static final String REFERENCEDATA_FROM_QUERY ='FROM ReferenceData__mdt WHERE ';
public static final String REFERENCEDATA_CONDN_QUERY ='Type__c =:type AND Key__c=:key';
public static final String REFERENCEDATA_CONDN_PPL_QUERY =' AND Number_Of_People__c =:noOfPeople';
public static final String REFERENCEDATA_ORDER_BY_QUERY =' ORDER BY Number_Of_People__c ASC';




public static final String CC_ENROLLMENT_ACTIVE_BENEFITS='ActiveBenefits';
public static final String CC_ENROLLMENT_PENDING_INTERVIEW_BENEFITS='PendingInterviewBenefits';
public static final String CC_ENROLLMENT_PENDING_VERIFICATION_BENEFITS='PendingVerificationBenefits';
public static final String CC_ENROLLMENT_LOGGED_IN_CONTACT='loggedInContact';
public static final String CC_ENROLLMENT_CHILDCARESUMMARYSUBMITTYPE='ChildCareEnrollmentSummary';
public static final String CC_ENROLLMENT_ENROLLMEMNT_DETAILS='ccEnrollmentDetails';
public static final String CC_ENROLLMENT_ENROLLMEMNT_SCH_DETAILS='ccEnrollmentSchDetails';
public static final String CC_ENROLLMENT_CHILD_CARE_ASSISTANCE='Child Care Assistance';
public static final String EDUCATIONENROLLMENT = 'EducationEnrollment';
//Flownames    
public static final String CONTACT_INFORMATION = 'ContactInformation';

//Added part of DCBC non working day
public static final String SATURDAY = 'Saturday';
public static final String SUNDAY = 'Sunday';
public static final String DAY_FORMAT = 'EEEE';  

//Expense Constants
public static final String SPOUSE = 'SP';
public static final String HOSP = 'HS';
public static final String LTC = 'LTC';
    
    public static final String BENEFITPROGRAMSKEY = 'HasAllProgramAccess'; //Defect 386563
}