/*
 * Classname         :  SSP_InterfaceConstants
 * @description  :  Constant class for Interfaces
 * @author       :  Rajeev Kumar
 * @date         :  02/12/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_InterfaceConstants {
    //public attributes
    public final static String CORRESPONDENCE_CODE_HBE_055 = 'HBE-055';
    public final static String CORRESPONDENCE_CODE_HBE_016 = 'HBE-016';
    public final static String CORRESPONDENCE_CODE_HBE_017 = 'HBE-017';
    public final static String CORRESPONDENCE_CODE_SSP_001 = 'SSP-001';
    // Common attributes
    public final static String JSON_BODY = 'jsonbody';
    public final static String FAILED = 'Failed';
    public final static String PENDING = 'Pending';
    public final static String COMPLETED = 'Completed';
    public final static String SUCCESS = 'Success';
    public final static String CANCELLED = 'Cancelled';
    public final static String NOT_STARTED = 'Not Started';
    public final static String RETRY = 'Retry';
    public final static String LOG_NUMBER = 'LogNumber';
    public final static String RESPONSE = 'Response';
    public final static String FORWARD_SLASH = '/';
    public final static String ANGULAR_OPEN = '<';
    public final static String ANGULAR_CLOSE = '>';
    public final static String BACKWARD_SLASH = '\\';
    public final static String SINGLE_QUOTE = '\'';
    public final static String EQUAL = '=';
    public final static String SEMICOLON = ';';
    public final static String OPERATOR_SEMICOLON = ';';
    public final static String AMPERSAND = '&';
    public final static String COMMA = ',';
    public final static String NEW_LINE = '\r\n|\n';
    // Reverse SSP DC 
    public final static Integer TOTAL_RETRY = 0;
    public final static String INDIVIDUALID = 'IndividualId';
    public final static String SSP_PAYLOAD = 'PAYLOAD';
    public final static String RSSPDC_RESPONSE = 'REVERSESSPDCRESPONSE';
    public final static String ACKRESPONSE = 'ACKRESPONSE';
    public final static String ACKRESPONSE_CODE = 'AckResponseCode';
    public final static String HBE_9000 = 'HBE9000';
    
    public final static String SSP_MEMBER = 'SSP_Member__c';
    public final static String SSP_APPLICATION = 'SSP_Application__c';
    public final static String SSP_MODE_RAC = 'RAC';
    public final static String SSP_MODE_RENEWAL = 'RENEWAL';
    public final static String SSP_RAC_SELECTION = 'RACSelections';
    public final static String RECORD_TYPE = 'RecordType';
    public final static String MODE_INTAKE = 'Intake';
    public final static String MODE_RENEWAL = 'Renewal';
    public final static String MODE_RAC = 'RAC';
    public final static String ALL_VIEWS = 'All_Views';
    public final static String PENDING_VIEWS = 'Pending_Views';
    public final Static String ADHOC_VIEWS = 'Adhoc_Views';
    public final static String PROGRAM_CODE = 'programCode';
    public final static String VIEW_NAME = 'viewName';
    public final static String SSP_SCREEN_NAMES = 'screenNames';
    public final static String REVERSE_SSP_DC = 'Reverse_SSP_DC';

    public final static String QUALIFIED_INDIVIDUALS = 'QualifiedIndividual';
    public final static String QUALIFIED_INDIVIDUAL = 'QualifiedIndividual';
    public final static String MEMBER_INFORMATION = 'MemberInformation';
    public final static String ABSENT_PARENT_INFORMATION = 'AbsentParentInformation';
    public final static String EXPENSE_INFORMATION = 'ExpenseInformation';
    public final static String HEALTH_COVERAGE_INFORMATION = 'HealthCoverageInformation';
    public final static String HEALTH_INFORMATION = 'HealthInformation';
    public final static String HOUSEHOLD_OTHER_INFORMATION = 'HouseHoldOtherInformation';
    public final static String INCOME_INFORMATION = 'IncomeInformation';
    public final static String RELATIONSHIP_INFORMATION = 'RelationshipInformation';
    public final static String RESOURCE_INFORMATION = 'ResourceInformation';
    public final static String DASHBOARD_INFORMATION = 'DashboardInformation';
    public final static String ELIGIBILITY_SUMMARY = 'EligibilitySummary';
    public final static String MY_INFORMATION = 'MyInformation';
    public final static String BENEFIT_INFORMATION = 'BenefitInformation';
    public final static String MEDICAID_MCO_INFORMATION = 'MedicaidMCOInformation';
    public final static String KHIPP_PAYMENT_SUMMARY = 'KHIPPPaymentSummary';
    public final static String DASHBOARD_CASE_INFORMATION = 'DashboardCaseInformation';
    public final static String AUTHREPS_ASSISTERS = 'AgentAssistAuthRepDetails';
    public final static String RAC_SELECTION_DETAILS = 'RACSelectionDetails';
    public final static String DISQUALIFICATION_DETAILS = 'DisqualificationDetails';
    public final static String PAST_APPLICATIONS= 'PastApplications';
    public final static String RFI_DETAILS = 'RFIDetails';
    public final static String NON_CITIZEN_CLIENT_INFORMATION = 'NonCitizenClientInformation';
    public final static String NON_CITIZEN_SEARCH_CASE = 'NonCitizenSearchCase';
    public final static String WAIVER_DETAILS = 'WaiverDetails';
    public final static String DISCONTINUE_BENEFITS = 'SSP_DiscontinueBenefits';
    public final static String CLAIMS_OVERVIEW = 'ClaimsOverview';
    public final static String ASSISTER_AUTHREP_CLIENT_DETAILS = 'AssisterAuthRepClientDetails';
    public final static String NOTIFICATION_INFORMATION = 'NotificationInformation';
    public final static String TAX_FORMS_1095A_INFORMATION = 'TaxForms1095AInformation';
    public final static String HEARINGS_SUMMARY_INFORMATION = 'HearingsSummaryInformation';
    public final static String KIHIPP_PREFERRED_PAYMENT = 'KIHIPPPreferredPayment';
    public final static String NON_CITIZEN_SEARCH_EXPORT = 'NonCitizenSearchExport';
    public final static String TAX_FORMS_CORRESPONDENCE = 'SSP_TaxFormsCorrespondence';
    public final static String ONBOARD_INDV_AUTHREP = 'OnboardIndivAuthRep';

    

    
    public final static String SSP_DC = 'SSP_DC';
    public static final String VIEWS ='Views';
    public static final String FLOW_TYPE = 'flowType';
    public static final String QUALIFIED_VIEWS = 'qualifiedViews';
    public static final String APPID = 'AppID';
    public static final String STATUS = 'Status'; 
    public static final String PRIMARY_APPID = 'PrimaryAppIndId';
    public static final String CASE_NUMBER = 'CaseNumber';
    public static final String MODE = 'Mode';
    public final static String ENTITY_MAPPING_API_NAME = 'EntityMapping__mdt';
    public static final String HELPER_URL = Page.SSP_RSSPDC_TransactionUpdatePage.getUrl() + '?';
    public final static String UNEXPECTED_RESPONSE_ERROR = 'Unexpected Response Body';
    public final static String RSSPDC_INTEGRATION_SERVICE= 'SSP_RSSPDCIntegrationService';
    public final static String INVOKE_CALLOUT= 'invokeCallout';

    //SSP_DC Constant Values
    public static final string SUBMIT_TYPE = 'SubmitType';
    public static final string MEMBER_API= 'SSP_Member__c';
    public static final string SCREEN_LIST = 'screeList';
    public static final string APPLICATION_ID = 'ApplicationId';
    public static final string ACCOUNT_ID = 'AccountID';
    public static final string APP_RECEIVEDDTTIME = 'ApplicationReceivedDateTime';
    public static final string ENTITY_MAPPING_MDT_API = 'EntityMapping__mdt';
    public static final string SSPDC_FILTER_MDT_API = 'SSPDCFilterMapping__mdt';
    public static final string SSPDC_UPDATE_AGENCY = 'SSPDC_UpdateAgency';
    public static final string SSPDC_UPDATE_REPRESENTATIVE = 'SSPDC_UpdateRepresentative';
    public static final string UPDATE_CONTACT_INFO = 'SSPDC_UpdateMyInformation';
    public static final string UPDATE_REPRESENTATIVE = 'UpdateRepresentative';
    public static final string IS_DEBUG = 'isDebug';
    public static final string ERROR_HBE_9000 = 'HBE 9000 Error';

    public final static String ACCOUNTCONTACTRELATION = 'AccountContactRelation';
    public final static String SSP_INSURANCEPOLICY = 'SSP_InsurancePolicy__c';
    public final static String SSP_ALIENSPONSOR = 'SSP_AlienSponsor__c';
    public final static String SSP_TRACKDELETION = 'SSP_TrackDeletion__c';
    public final static String SSP_TRANSACTION = 'SSP_Transaction__c';
    public final static String PHYSICALADDRESSLINE1 = 'PhysicalAddressLine1__c';
    public final static String MAILINGADDRESSLINE1 = 'MailingAddressLine1__c';
    public final static String PHYSICALCITY = 'PhysicalCity__c';
    public final static String MAILING_CITY_OBJ = 'MailingCity__c';
    public final static String PHYSICALSTATECODE = 'PhysicalStateCode__c';
    public final static String MAILINGSTATECODE = 'MailingStateCode__c';
    public final static String SSP_APP_REMOVECOVERAGEMODAL = 'SSP_APP_REMOVECOVERAGEMODAL';
    public final static String REPS_ADDAUTHORIZEDREPRESENTATIVE1 = 'REPS_ADDAUTHORIZEDREPRESENTATIVE1';
    public final static String SUNMIT_TYPE_IS_MISSING = 'Submit Type is Missing';
    public final static String INCORRECT_PARAMETERS_FOR_INTERFACE = 'Incorrect Parameters for Interface.';
    public final static String SSP_DEPENDENTSCREENMAPPING_MD = 'SSP_DependentScreenMapping__mdt';
    public final static String APPLICATIONRECEIVEDDATETIME = 'ApplicationReceivedDateTime';
    public final static String CHANGE_SUMMARY_MODE = 'ChangeSummaryMode';
    public final static String SSP_SSPDCINTEGRATIONSERVICE = 'SSP_SSPDCIntegrationService';
    public final static String SSP_APPLICATIONINDIVIDUAL = 'SSP_ApplicationIndividual__c';
    public final static String SSP_APPLICATION_OBJ = 'SSP_Application__c';
    
    //General purpose Contants
    public static final string SSP_CallOut = 'callout:';
    public static Boolean ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = false;
    public static Boolean ALLOW_ACCOUNT_CREATION_FROM_TRIGGER = false;
    public static final String IS_LOG_INSERTED = 'isLogInserted';
    public static final String ACCOUNT_ORGANIZATION_RECORD_TYPE = 'Organization';
    public static final String ASSISTER_ROLE = 'Assister';
    public static final String INDIVIDUAL_AUTH_REP_ROLE = 'Individual_Auth_Rep';
    public static final String ORGANIZATION_AUTH_REP_ROLE = 'Organization_Auth_Rep';
    public static final String INSURANCE_AGENT_ROLE = 'Insurance_Agent';
    public static final String CITIZEN_ROLE = 'Citizen_Individual';
    public static final String AGENCY_ADMIN = 'Agency_Admin';
    public static final String CITIZEN_PROFILE_NAME = 'RE Citizen Profile';
    public static final String ROLE_NAME = 'role';
    public static final String USER_ID = 'userId';
    public static final String CONTACT_ID = 'contactid';
    public static final String SKIP_DML_OPERATIONS = 'skipDMLOperations';
    public static final String SKIP_LOG = 'skip Log';
    public static final String SKIP_TRANSACTION_RECORD = 'SkipTransactionRecord';

    //SSP_AHI Constant Values
    public static final string SSPAHI_APPLICATIONID = 'ApplicationId';
    public static final string SSPAHI_CASENUMBER = 'CaseNumber';
    public static final string SSPAHI_METADATANAME = 'SSP_AHI';
    //SSP_TMember Constant Values
    public static final string SSPTMember_METADATANAME = 'SSP_TMember';
    
    // Medicaid Card Request
    public static final String MEDICAID_CARD_REQUEST = 'SSP_MedicaidCardRequest';
    
    // EBT Card Request
    public static final String EBT_CARD_REQUEST = 'SSP_EBTCardRequest';
    
    //SSP_AVS Constant Values
    public static final string SSPAVS_METADATANAME = 'SSP_AVS';

    //SSP_Hearing Citizen View Details
    public final static String CITIZEN_HEARING_VIEW_DETAILS = 'SSP_CitizenHearingViewDetails';
    
    //SSP_VLP Constant Values
    public static final string SSPVLP_METADATANAME = 'SSP_VLP';
    
    //SSP_VCI Constant Values
    public static final string SSPVCI_METADATANAME = 'SSP_VCI';
    public static final string SSPVCI_SETOFSSNs = 'MemberSSNs';
    public static final string SSPCASENumber = '0';
    
    //SSP_KIHIPPPayment Constant
    public static final string SSP_KIHIPPPayment_METADATANAME = 'SSP_KIHIPPPayment';

    //Hearing Constant
    public static final string SSP_CREATEHEARING_METADATANAME = 'SSP_CreateHearing';
    public static final string SSP_WITHDRAWHEARING_METADATANAME = 'SSP_WithdrawHearing';
    
    //SSP_Overlap Constant Values
    public static final string SSPOverlap_METADATANAME = 'SSP_Overlap';

    //Claims Payment Constant Values
    public static final string SSPGETURL_METADATANAME = 'SSP_ClaimsPaymentGetURL';
    public static final string SSPGETSTATUS_METADATANAME = 'SSP_ClaimsPaymentGetStatus';
    
    //SSP_UpdateAgentAssister Constant Values
    public static final string SSPUpdateAgentAssister_METADATANAME = 'SSP_UpdateAgentAssister';
    
    // SSP_NONESI MEC Service Constant Values
    public static final string SSPNONESIMEC_METADATANAME = 'SSP_NONESIMECService';
    //SSP Waiver Data Transfer Service Constant values
    public static final string SSP_APPLICATIONID = 'ApplicationId';
    public static final string SSP_CASENUMBER = 'CaseNumber';
    // SSP_MCI Merge Service Constant Values
    public static final string SMODE= 'Mode';
    public static final string SSPMCI_APPNUMBER = 'Applicationnumber'; 
    public static final string SSPMCI_INDID = 'IndividualId';
    public static final string SSPMCI_VIEWNAME = 'ViewName';
    public static final string SSPMCI_FILECLR = 'isMemberFileCleared';
    public static final string SSPMCI_MATCHSTATUS = 'MatchStatus';
    public static final string SSPMCI_APPBLOCK = 'IsApplicationBlocked';
    public static final string SSPMCI_BLOCKCNUMBER = 'BlockedCaseNumber';
    public static final string SSPMCI_ERRORDATA = 'errorData';
    public static final string SSPMCI_ERRORCODE = 'errorCode';
    public static final string SSPMCI_ERRORDES = 'errorDescription';
    public static final string SSPMCI_APPINDOBJECT = 'SSP_ApplicationIndividual__c';
    public static final string SSPMCI_APPOBJECT = 'SSP_Application__c';
    public static final string MCI_SSP_Payload = 'Payload';
    
    // SSP_Integration Error Log Constants
    public static final string SSPINT_ERRORRESPCODE  =  'Response Code is : - ';
    public static final string SSPINT_ERRORRESPBODY  = '.  Response Body is : - ';
    public static final string SSPINT_ERRORRESPSTCDE = '. Response Status Code is : - ';
    public static final string SSPINT_ERRORCAUSE =  'Error Cause :';
    public static final string SSPINT_ERRORMSG = '\n Error Message : ';
    public static final string SSPINT_ERRORTRACE = '\n Error StackTrace : ';
    public static final string SSPINT_ERRORLINENO = ' \n Error Line Number : ';
    
    // SSP_Address Verification Constants
    public static final string SSPINT_BODY = 'body';
    public static final string USAC_COUNTY_OP1 = 'COT_USAC_County_op1';
    public static final string USAC_COUNTY_OP1RESPONSE = 'COT_USAC_County_op1Response';
    public static final string USAC_COUNTY_OP1SERVICE_RESPONSE = 'SSP_AddressVerificationWSDLService.COT_USAC_County_op1Response';
    
    // SSP Provider Search
    public static final String SSP_PROVIDER_SEARCH = 'SSP_ProviderSearch';
    public static final String LIVING_ARRANGEMENT_TYPE = 'LivingArrangementType';
    public static final String ORGANIZATION_NAME = 'OrganizationName';
    
    //SSP Waiver Data Transfer
    public static final String SSP_WDT_Generate = 'SSP_WaiverDataTransferGenerate';
    public static final String SSP_WDT_Consume = 'SSP_WaiverDataTransferConsume';

    //SSP Update DC Representative
    public static final String SSP_UPDATE_DC_REPRESENTATIVE = 'SSP_UpdateDCRepresentative';    
    public static final String SSP_UPDATE_DC_REP_APP_ID     = 'applicationId';
    public static final String SSP_UPDATE_DC_REP_ACR        = 'acr';
    public static final String SSP_UPDATE_DC_REP_CONTACT_ID = 'contactID';
    public static final String SSP_UPDATE_DC_TrackDeletion  = 'trackDeletion';
    public static final String SSP_IS_FROM_REQUEST_ACCESS = 'isFromRquestAccess';
    public static final String SSP_UPDATE_DC_SERVICE_STATUS = 'Status : ';
    public static final String SSP_UPDATE_DC_DELETE_INDICATOR = 'deleteIndicator';
    public static final String SSP_UPDATE_DC_SERVICE = 'SSP_UpdateDCRepIntegrationService';
    
    //SSP Child Care Provider Search
    public static final String SSP_CHILDCARE_PROVIDER_SEARCH = 'SSP_ChildCareProviderSearch';

    //SSP_Save Waiver Screening Results
    public static final String SSP_SAVE_WAIVER_SCREENING_RESULTS = 'SSP_SaveWaiverScreeningResults';
    public static final String INTERFACE_NAME_SAVE_SCR ='SSP_SaveWaiverScreeningResults';
    public static final String SOURCE_SAVE_SCR = 'SSP_SaveWaiverScreeningResultsIntService';
    
    //SSP RIDP Integration
    public static final String SSP_RIDP_CHECK_RESUME = 'SSP_RIDP_Check_Resume' ;
    public static final String SSP_RIDP_GET_QUESTIONS = 'SSP_RIDP_GetQuestions' ;
    public static final String SSP_RIDP_POST_ANSWERS = 'SSP_RIDP_PostAnswers' ;
    public static final String SSP_RIDP_DMS_GET_DOC_SERV = 'DMSGetDocumentService' ;
    public static final String SSP_RIDP_GET_REQ = 'GetDocumentRequest' ;
    public static final String SSP_RIDP_GET_RES = 'GetDocumentResponse' ;
    public static final String SSP_RIDP_GET_RES_ELE = 'SSP_DocumentDownlaodResponse.GetDocumentResponse_element' ;
    public static final String SSP_RIDP_CHK_RESUME_RES = 'CheckResumeResponse' ;
    public static final String SSP_RIDP_CHK_RESUME_RES_ELE = 'SSP_RIDP_tempuriOrg.CheckResumeResponse_element' ;
    public static final String SSP_RIDP_GET_QUE_RES = 'GetQuestionsResponse' ;
    public static final String SSP_RIDP_GET_QUE_RES_ELE = 'SSP_RIDP_tempuriOrg.GetQuestionsResponse_element';
    public static final String SSP_RIDP_POST_ANS = 'PostAnswersResponse';
    public static final String SSP_RIDP_POST_ANS_ELE = 'SSP_RIDP_tempuriOrg.PostAnswersResponse_element';
    public static final String INTERFACE_NAME_GET_QUE ='SSP_RIDP_GetQuestions';
    public static final String SOURCE_GET_QUE = 'SSP_RIDP_GetQuestionsIntegrationService';
    public static final String SOURCE_FUNCTION = 'invokeCallout';
    public static final String INTERFACE_NAME_POST_ANS ='SSP_RIDP_PostAnswers';
    public static final String SOURCE_POST_ANS = 'SSP_RIDP_PostAnswersIntegrationService';
    
    //SSP MCI Service For Benefit application
    public static final String SSP_MCI_SERVICE_FOR_BENEFIT= 'SSP_MCIServiceForBenefit';
    public static final String ENTITY_MCI_SEARCH = 'EntityMciSearch';
    public static final String ENTITY_MCI_SEARCH_RESPONSE = 'EntityMciSearchResponse';
    public static final String ENTITY_MCI_SEARCH_RESPONSE_ELEMENT = 'kyHbeMci.EntityMciSearchResponse_element';

    //Integration Factory
    public static final String SSP_INTERFACE_DETAIL_MD = 'SSP_InterfaceDetail__mdt';
    public static final String SSP_SERVICE_CLASSNAME_OBJ = 'SSP_ServiceClassName__c';
    public static final String SSP_NOT_A_VALID_INTERFACE = 'Not a valid interface.';

    //SSP_CustomMetadataAccessor
    public static final String SSP_METADATA_NOT_PRESENT_IN_SYS = 'Metadata not present in system.';

    //SSP_FraudSubmission
    public static final String SSP_FRAUD_SUBMISSION = 'SSP_FraudSubmission';

    //SSP Preferred MCO Plan
    public static final String SSP_PREFERRED_MCO_SELECTION = 'SSP_PreferredMCOSelection';
    public static final String SSP_PREFERRED_MCO_SERVICE = 'SSP_PreferredMCOSelectionIntegService';

    //PERF Fix
    //Reps Home Page
    public static final String ACCOUNTS = 'lstAccounts';
   	public static final String SNAP =  'SN';
    public static final String TANF =  'TN';
    public static final String MEDICAID =  'MA';
    public static final String CHILDCARE =  'CC';
    public static final String STATE =  'SS';
    public static final String KTAP =  'KT';
    public static final String KHIPP =  'KP';     
    public static final String PE =  'PE';
    public static final String BCCTP =  'BCCTP';
    public static final Set<String> ALL_AVAILABLE_PROGRAMS = new Set<String>{MEDICAID, SNAP, KTAP, CHILDCARE, KHIPP, STATE, PE, BCCTP};
    public static final String CACHE_PARTITION_NAME = 'local.SSP';
    public static final String SELECTED_ROLE = 'selectedrole';


    //Communication Log to MC Service
    public static final String SSP_SENDCOMTOMC_EMAIL =  'SSP_SendComToMC_Email';
    public static final String SSP_SENDCOMTOMC_GENERATE_TKN =  'SSP_SendComToMC_GenerateToken';
    public static final String SSP_SFMC_GRANT_TYPE =  'client_credentials';
    public static final String SSP_SFMC_ACCOUNT_ID =  '100026637';
}