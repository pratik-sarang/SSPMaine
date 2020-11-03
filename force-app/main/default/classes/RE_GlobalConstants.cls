/**
 * @File Name          :  RE_GlobalConstants.cls
 * @Description        : 
 * @Author             :  ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/6/2020, 11:15:43 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    6/10/2019, 4:44:35 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public with sharing class RE_GlobalConstants {
    // User Constants
    public static final String USER_STATUS_ACTIVE = 'Active';
    public static final String USER_STATUS_INACTIVE = 'Inactive';
    public static final String CONTACT_TRAINING_LEVEL_NOT_TRAINED = 'Not Complete';
    public static final String LOCATION = 'Location';
    public static final String USER_TIMEZONE = 'America/Chicago'; 
    public static final String USER_LANGUAGE = 'en_US';
    public static final String CHARSET = 'UTF-8';
    public static final String USER_ALIAS = 'reCusr';
    public static final String USER_FIRSTNAME = 'RECitizenUser';
    // added by Pankaj [12/09/2019]
    public static final String RE_STATE_USER = 'RE State User';
    public static final String RE_UW_STAFF_USER = 'RE United Way Staff';
     public static final String RE_SOURCESYSTEM = 'RE';
    //KOG Constants
    public static final String KOGROLE = 'KOG_Role__c';
    public static final String COMMUNITY_PARTNER_ADMIN = 'Community Partner Admin';
    public static final String COMMUNITY_PARTNER_STAFF = 'Community Partner Staff';
    public static final String CASE_WORKER_SUPERVISOR = 'Case Worker Supervisor';
    public static final String CASE_WORKER = 'Case Worker';
    public static final String UWSTAFF = 'UW Staff';
    public static final String SF_PROD_SUPP = 'SF Production Support';
    public static final String STATE_USER = 'State User';
    public static final String CITIZEN = 'Citizen';
    public static final String CITIZEN_INDIVIDUAL = 'Citizen_Individual';
   
    //MyPaln Constants
    public static final String REFERRAL_STATUS_CLOSED = 'Closed';
    public static final String REFERRAL_OUTCOME_STATUS = 'Resource Cancelled';
    public static final String REFERRAL_CANCELLED_BY_CLIENT = 'Cancelled by Client';
    public static final String STATUS_INPROGRESS = 'In Progress';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String REFERRAL_STATUS_DRAFT = 'Draft';
	public static final String sAccountStatus = 'Active - Allow referrals';
    public static final String CONNECT = 'Connect';
    public static final String ACCEPTED = 'Accepted';
    public static final String DECLINED = 'Declined';
    public static final String NO_THANKS = 'NoThanks';
    public static final String SUGGESTED_BY_SYSTEM = 'Suggested by System';
    
    //ClaimSite Constants
    public static final String CLAIM_STATUS_APPROVED = 'Approved'; 
    public static final String CLAIM_STATUS_DENIED = 'Denied';
    public static final String CLAIM_ConsentProvidedVerbal = 'Verbal'; 
    public static final String CLAIM_ConsentProvidedEmail = 'Email';
    public static final String CLAIM_ConsentProvidedText = 'Text';
    public static final String CLAIM_ConsentProvidedResident = 'Resident';
    public static final String CLAIM_ResourceProvided = 'Resource Provided'; 
    public static final String STANDARD_USER_PROFILE_TEST = 'Standard User';
    public static final String CPADMIN_USER1_EMAIL_TEST = 'cpadminuser@deloitte.com';
    public static final String COMMUNITY_USER_EMAIL_TEST = 'communityusr@deloitte.com';
    public static final String CONTACT_EMAIL_TEST = 'cpstaffuser@deloitte.com';
    public static final String STAFF_PERMISSIONSET_NAME ='RE_Community_Partner_Staff';
    public static final String ADMIN_PERMISSIONSET_NAME ='RE_Community_Partner_Admin';
    public static final String SAMPLE_USER_EMAIL_TEST = 're_sampleuser@test.com';
    public static final String SAMPLE_USER_NAME_TEST = 'Sample';
    public static final String STAFF_CONTACT_USER_NAME_TEST = 'Staff Contact User';
    public static final String RE_COMMUNITY_USER_ADMIN_EMAIL_TEST = 're_communityadmin@deloitte.com'; 
    public static final String RE_COMMUNITY_USER_ADMIN_NAME_TEST = 'Admin1 Contact User';
    public static final String RE_ADMIN_NAME_TEST = 'Admin';  
    public static final String RE_COMMUNITY_USER_CONTACT_EMAIL_TEST = 're_communityadmin123@deloitte.com';
    public static final String COMMUNITY_USER_STAFF_EMAIL_TEST = 'communitystaffusr@deloitte.com';
    public static final String COMMUNITY_USER_RE_STAFF_EMAIL_TEST = 're_communitystaff@deloitte.com';
    public static final String CONTACT_PICKLIST_VALUES_TEST = 'TrainingLevel__c,PermissionsLevel__c,Status__c,PrimaryLocation__c';
    public static final String ORGANIZATION = 'Organization';
    public static final String ASSISTER = 'Assister';
    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String PENDING = 'Pending';
    public static final String DENY = 'Deny';
    /* SOQL variables */
    public static final String SOQL_FROM = ' FROM ';
    public static final String SOQL_WHERE = ' WHERE ';
    
    public static final String GUEST = 'Guest';    
    public static final String strCommunicationRecTypeDevName ='Communication';
    public static final String strRecordTypeDeveloperName ='CPUserContact';
    public static final String strSobjectName = 'Contact';
    public static final String strReferralRecordTypeDeveloperName = 'ReferralRecord';
    public static final String strClientFeedbackRecTypeDevName = 'ClientFeedback';
    public static final String strPartnerFeedbackRecTypeDevName = 'PartnerFeedback';
    public static final String strReferralObjectName = 'Referral__c';
    public static final String strClaimRecordTypeDeveloperName = 'State_User_View';
    public static final String strClaimObjectName = 'ClaimMySiteRequest__c';
    public static final String strNotesVisibility = 'AllUsers';
    public static final String strNotesShareType = 'V';
    public static final String strContactRecordTypeName = 'CP User Contact';
    public static final String strCitizenRecordTypeName = 'Citizen';
    public static final String strNonCitizenRecordTypeName = 'Non Citizen';
    public static final String strNonCitizenProfileName = 'SSP Non Citizen Profile';
    public static final String strReAccRecordTypeName = 'Organization';
    public static final String strLocationRecordTypeName = 'Location';
    public static final String strResourceRecordTypeName = 'Community Partner Resource';
    public static final String strCommunityProfileName = 'RE Community Partner User Profile';
    public static final String strGuestProfileName = 'Resource Engine Profile';
    public static final String strSobjectUser = 'User';
    // Added by Pankaj as part of ONEVIEW-1531
    public static final String RE_ASSISTER_PROFILE = 'RE Assister Profile';
    public static final String strStaffPermissionSetName = 'RE_Community_Partner_Staff'; 
    public static final String RESP_CLIENT_DATA = 'IEESClientData';
    public static final String str_RE_ADMIN_CONTACT_PERMISSION = 'Admin';
    public static final String strCitizenProfileName = 'RE Citizen Profile';
    public static final String strCitizenFirstName = 'Citizen Test';
    public static final String strCitizenLastName = 'Dummy User';
    public static final String strCitizenEmail = 'citizentest@dummy.com';
    public static final String strLocationObjectName = 'Location__c';
    public static final String strFeedbackObjectName = 'Feedback__c';
    public static final String strMetaDataDeveloperName = 'ClientListView';
    public static final String sSharingMyPlanStaticStyling = '<div style="margin-left:10px;"><p><b>';
    public static final String sBRTag = '<br>';
	public static final String RESP_SHORT_URL_DATA = 'BitlyResponseData';
    
    // Used in General Utility Method.
    public static final String sWhereClauseKey = 'WHERE';
    public static final String sOrderByKey = 'ORDERBY';
    public static final String sLimitKey = 'LIMIT'; 
    public static final String sOffset = 'OFFSET';
    public static final String sGroupByKey = 'GROUPBY'; 
    public static final Set<String> setStdFields = new Set<String>{'id', 'createddate', 'lastmodifieddate', 'createdby', 'lastmodifiedby','profile','owner'};
    public static final Set<String> stdObjName = new Set<String>{'Account','Contact'};
    //DML Types
    public static final String sInsert = 'INSERT';
    public static final String sUpsert = 'UPSERT';
    public static final String sUpdate = 'UPDATE'; 
    public static final String sDelete = 'DELETE';  
    //reCaptcha v2 Keys
    public static final String strCaptchaSecretKey = '6Lf6cKcUAAAAAIfIlyp_5W6Z8lnRYeylKHu7ZZp0';
    public static final String strCaptchSiteKey = '6Lf6cKcUAAAAANRRFR1rOJCoFJ_RyhJq7oaaINRV';
    public static final String strMapAPIKey = 'AIzaSyBwQAy5ZMxTXt-Wrc64WsdYtxyYs5N1WYs';
    
    //Queue Names
    public static final String CLAIM_SITE_QUEUE = 'ClaimSiteQueue';
    //Delimiters
    public static final String SEMICOLON_DELIMITER = ';';
    public static final String sReferralSort = 'DaysSinceOpened__c ASC';
    //Note, File, Content, Document Links
    public static final String CONTENT_LOCATION_SALESFORCE = 'S';
    public static final String SHARE_TYPE_VIEWER = 'V';
    public static final String VISIBILITY_ALL_USERS = 'AllUsers';
    public static final String NOTES_BODY_Tag = '<p>';
    public static final String NOTES_BODY_END_Tag = '</p>';
    
    public static final String STATUS_OK = 'OK';
    //Referral related
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_CLOSING_REFERRAL = 'Closed';
    public static final STRING OUTCOME_REASON_SERVICE_PROVIDED = 'Service Provided';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_INPROGRESS_ORG_IN_SYSTEM = 'In Progress - Org in System';
    public static final String STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM = 'In Progress - Org Not in System';
    public static final String STATUS_CLOSED  = 'Closed';
    public static final String REFERRAL_RECORD_TYPE = 'Referral Record';
    public static final String SUGGESTED_BY_PARTNER = 'Suggested by Partner';
    public static final String ADDED_BY_RESIDENT = 'Added by Resident';
    
    
    // Objects fields names
    public static final String strFieldName = 'LeadSource';
    // Consent related
    public static final String CONSENT_STATUS_ACTIVE = 'Active';
    public static final String CONSENT_PROVIDEDBY_RESIDENT = 'Resident';
    
    // Location related
    public static final String LOCATION_STATUS_ACTIVE = 'Active';
    
     // Switch case fields related
    public enum SWITCH_CONSTANTS {SWITCH_SUCCESS, SWITCH_FAILURE, SWITCH_CREATE, SWITCH_UPDATE}
    public static final String FLS_ERROR = 'Some Fields doesn\'t have the required access :: ';
    public static final String PROFILE_MISMATCH_ERROR = 'Loggedin user profile does not match citizen user profile.';
    
    //For Test class inputs.
    public static final String sAccountName = 'Test Account';
    public static final String strClaimReqFirstName = 'Test Claim';
    public static final String strClaimUinNo = '1234';
    public static final String strClaimEmail= 'test@mailinator.com';
    public static final String strOrgUniqueId = '1234';
    public static final String strAccShipCity = 'TestCity';
    public static final Decimal dContactLocLatitude = 38.328732;
    public static final Decimal dContactLocLongitude = 85.764771;
    public static final String sInvalidEmail = 'test@';
    public static final String sTestUser1 = 'User1';
    public static final String STAFF_ROLE = 'Staff';
    public static final String ADMIN_ROLE = 'Admin';
    public static final String CONTACT_STAFF_FIRSTNAME = 'Contact Staff';
    public static final String CONTACT_ADMIN_FIRSTNAME = 'Contact Admin';
    public static final String CONTACT_LASTNAME = 'RE User';
    public static final String STAFF_USER_ALIAS = 'stafusr';
    public static final String ADMIN_USER_ALIAS = 'comusr';

    public static final String userobjectName = 'User';   
    public static final String noteobjectName = 'ContentNote';
    public static final String consentobjectName = 'Consent__c';
    public static final String ASSISTER_PERMISSIONSET_NAME = 'Assister';
    public static final String RESIDENT_PERMISSIONSET_NAME = 'RE_Resident';
    public static final String CONSENT_STATUS_PENDING = 'Pending';
    public static final String HANDLER_NAME = 'ContactTriggerHandler';
    public static final String GUEST_USERTYPE = 'Guest';
    
    //Added by LK
    public static final String strFieldsApiNameContentDocId = 'ContentDocumentId';
    public static final String strFieldsApiNameContentDocumentLink = 'ContentDocumentLink';
    public static final String strContentDocument = 'ContentDocument';
    public static final String strDocumentAPIame = 'DocumentDetail__c';
    public static final String sEmptyString = '';
    public static final String sSuccess = 'success';
    public static final String sFailure = 'failure';
    public static final String sLocationTypeHead = 'Headquarters';
    public static final String sLocationTypeNonHead = 'Non Headquarters';
    
    // JSON response
    public static final String sMapMockJsonResponse='{ "results": [ { "address_components": [ { "long_name": "52726", "short_name": "52726", "types": [ "postal_code" ] }, { "long_name": "Blue Grass", "short_name": "Blue Grass", "types": [ "locality", "political" ] }, { "long_name": "Iowa", "short_name": "IA", "types": [ "administrative_area_level_1", "political" ] }, { "long_name": "United States", "short_name": "US", "types": [ "country", "political" ] } ], "formatted_address": "Blue Grass, IA 52726, USA", "geometry": { "bounds": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } }, "location": { "lat": 41.4986961, "lng": -90.7722974 }, "location_type": "APPROXIMATE", "viewport": { "northeast": { "lat": 41.5460111, "lng": -90.707594 }, "southwest": { "lat": 41.4545509, "lng": -90.8720878 } } }, "place_id": "ChIJ93fcNsbF44cR6AyPC07TrQI", "types": [ "postal_code" ] } ], "status": "OK" }';
    //fields related to Custom Setting
    public static final String CONTACT_TRIGGER_CUSTOM_SETTING = 'ContactTrigger';
    public static final String LOCATION_TRIGGER_CUSTOM_SETTING = 'LocationTrigger';
    //Feedback Related
    public static final String RATING_DESC = 'Rating Notes';
    //Permission Set
    public static final String sPermissionSetObj='PermissionSetAssignment';
    //Client Search
    public static final String sClientRelationshipName='Client__r';
    // ZipCode for google map api
    public static final Decimal dZipCode_TEST=18236;

    //Log Message Utility Constants
    public static final String LOGS_MESSAGE_INFO = 'Info';
    public static final String LOGS_DEFAULT_AUTOGENERATED = 'Default_AutoGenerated';
    public static final String LOGS_FIELDSINERROR = '\nFields In Error: ';
    public static final String LOGS_BATCHROW = 'Batch Row #: ';
    public static final String LOGS_MESSAGE = 'Message: ';

    //Archetype 
    public static final String sArchetypeObjName='RE_Archetype__c';
    public static final String sArchetypeFieldSetName='Resident_Registration_FieldSet';
    public static final String strArchetypeRecordtypeName='Archetype';
    public static final String strContactFieldSetForRegistration='Contact_FieldSet_Resident_Registration';
    public static final String strContactFieldSetForMyAccount='Contact_MyAccountFieldset';
    
    //Notes
    public static final String pageSize='1000';
    public static final String pageNumber='1';
    
    //Mock JSON Response
     public static final String CLIENT_DETAILS_MOCK_RESPONSE='{ "Response": [{ "ResponseMetadata": { "ResponseStatus": "Success", "ResponseDescription": "Success", "ResponseStatusCode": 200 }, "SourceSystem": "IEES", "Total_Row_Count": 100, "Data": [{ "ClientName": "John Appleseed", "ClientUniqueId": "CID211180980", "TotalAnnualIncome": "$40.00", "FPL": "10.00%", "EmploymentType": "Unemployed", "HomeAddressL1": "Test Add Line 1", "HomeAddressL2": "Test Address Line 2", "Email": "Test@test.com", "MobilePhone": "1234567890", "PreferredCommunicationMethod": "Email","AddressType": "Mailing Address","Gender": "Male","DOB": "12/09/1976","SSN": "123 54 1242","HouseholdComposition": [{ "HHCUniqueId": "HHC7867878788", "ClientName": "John Appleseed", "Age": "22" ,"Relationship":"Brother","EarningMonthly":"$540.00"}, { "HHCUniqueId": "HHC7867878789", "ClientName": "John Appleseed Father", "Age": "50","Relationship":"Father","EarningMonthly":"$570.00"}, { "HHCUniqueId": "HHC7867878791", "ClientName": "John Appleseed Cousin 1", "Age": "28" ,"Relationship":"Brother","EarningMonthly":"$543.00"}, { "HHCUniqueId": "HHC7867878731", "ClientName": "John Appleseed Cousin 2", "Age": "30","Relationship":"Brother" ,"EarningMonthly":"$522.00"}, { "HHCUniqueId": "HHC7867878790", "ClientName": "John Appleseed Mother", "Age": "49","Relationship":"Mother","EarningMonthly":"$340.00" }], "EnrolledPrograms": [{ "ProgramFullName": "SNAP", "StartDate": "2020-12-23", "RenewalDate": "2020-12-23" }, { "ProgramFullName": "Medicaid", "StartDate": "2020-12-23", "RenewalDate": "2020-12-23" }, { "ProgramFullName": "TANF", "StartDate": "2020-11-23", "RenewalDate": "2020-12-23" }, { "ProgramFullName": "CHIP", "StartDate": "2020-10-23", "RenewalDate": "2020-12-23" }, { "ProgramFullName": "KTAP", "StartDate": "2020-12-23", "RenewalDate": "2020-12-23" }] }] }] }';
    
    //Integrations Constants
    public static final String RoleManagementError = 'Received Invalid Error Code From Role Management Service';
    
    // Our CLients Column
    public static final String CONTACT_LABEL= 'CONTACT_LABEL';
    public static final String CONTACT_FIELD= 'CONTACT_FIELD';
    public static final String CONTACT_FIELD_TYPE= 'CONTACT_FIELD_TYPE';
    public static final String CONTACT_JSON  = '{"label": "'+CONTACT_LABEL+'", "fieldName": "'+CONTACT_FIELD+'", "type": "'+ CONTACT_FIELD_TYPE+'", "sortable" : "true"}';
       
    public static final String resourceobjectName = 'Resource__c';  
    public static final String referralobjectName = 'Referral__c'; 
    //Archetype Detail
    public static final String strConfigObjectName ='RE_Config__c';
    public static final String strGoalObjectName ='RE_Goal__c';
    public static final String strResTaxonomyObjectName ='RE_Resource_Taxonomy__c';
    public static final String strLocResObjectName ='LocationResource__c';
    
    public static final String strRecordTypeDeveloperNameReportconcern ='Change';
    
    //ContentVersion
    public static final String strContentVersionName = 'ContentVersion';
    //ContentDistribution
    public static final String strContentDistributionName = 'ContentDistribution';
    //CommunicationLog
    public static final String communicationLogObjName = 'CommunicationLog__c';

    public static final String sdohObjName = 'SDOH__c';
    public static final String sdohFieldSetForOneView = 'SDOH_OneView';
    

    // Report and Folder names
    public static final String sfolderName = 'Community_Partner_Reports';
    public static final String sUnassignedQueueName = 'Unassigned';
    // Assessment names
    public static final String sAssessmentObjectName = 'Assessment__c';
    public static final String sAssessmentResponseObjectName = 'AssessmentResponse__c';
    public static final String sAssessmentDeveloperName = 'Assessment_Template';
    public static final String sAssessmentUserDeveloperName = 'User_Assessment';
    public static final String sAssessmentTitleForGuest = 'CMS Self-sufficiency Assessment';
    // SDOH
    public static final String sSDOHObjectName = 'SDOH__c';
	// Survey Related Constants
    public static final String ReferralKey = 'Referral';
    public static final String ConsentKey = 'Consent';
    public static final String ChoiceValueYes = 'Yes';
    public static final String CommunityName = 'Resource Engine';
	public static final String TEST_STRING = 'Test';
    //Added by Siri: For LMS Utility 
    public static final String LearningPlanName = 'CP User Onboarding Training Plan';
	// Constants
    public static final String sConcernKey = 'Concern';
    public static final String sRegexSMSReuest='[a-zA-Z]{1,}|\\-'; //User Global Constants
    public static final String sPhoneInitialization='+1';
    public static final String sCommunityPartner='Community Partner';
    public static final String sStaffforBody='staff at the Community Partner';
    public static final String sassisterforBody='assister';
	public static final String sStartStringPercent='\'%';		
    public static final String sEndStringPercent='%\'';		
    public static final String sContactLastName= 'Contacts__r.LastName';		
    public static final String sAtforEmail='at ';		
    public static final String sBasic= 'Basic ';		
    public static final String sTo='To=';   		
    public static final String sAccessTokenType = 'Azure'; 		
    public static final String sBody1 = 'client_id='; 		
    public static final String sBody2 = 'username='; 		
    public static final String sBody3 = 'grant_type=password&resource=';
    //Nandita:03/24/2020: Added constants for Favorite Clients query : 357475
    // Favorite names
    public static final String sFavoriteObjectName = 'Favorite__c';
    public static final String sFavoriteDeveloperName = 'RE_Client_Favorite';

    //RE_Release 1.1 - Agency User Capture- Ram
   
    public static final String AGENCY_ADMIN_ROLE  = 'Admin';
    public static final String AGENCY_STAFF_ROLE  = 'Staff';
    public static final String CONTACT_AGENCY_ADMIN_FIRSTNAME = 'Agency Admin';
    public static final String CONTACT_AGENCY_STAFF_FIRSTNAME = 'Agency Staff';
    public static final String AGENCY_ADMIN_USER1_EMAIL_TEST ='agencyadminuser@deloitte.com';
    public static final String strAgencyContactRecordTypeName = 'Agency User';
    public static final String strAgencyAccountRecordTypeName = 'Agency User';
    public static final String AGENCY_ADMIN_USER_ALIAS = 'adminusr'; 
    public static final String AGENCY_STAFF_USER_ALIAS  = 'stafusr';
    public static final String COMMUNITY_AGENCY_USER_EMAIL_TEST = 'agencyadminusr@deloitte.com';
    public static final String COMMUNITY_AGENCY_USER_STAFF_EMAIL_TEST = 'agencystaffusr@deloitte.com';
    public static final String AGENCY_STAFF_PERMISSIONSET_NAME ='RE_Agency_Staff';
    public static final String AGENCY_ADMIN_PERMISSIONSET_NAME ='RE_Agency_Admin';
    public static final String strAgencyProfileName = 'RE Agency User Profile';
    public static final String strSystemAutoProcessProfile='System Auto Process';
    public static final String CITIZEN_USER_ALIAS  = 'citizenU';
    public static final String CONTACT_CITIZEN_FIRSTNAME = 'Citizen';
    public static final String COMMUNITY_CITIZEN_EMAIL_TEST = 'citizenUsrTest@deloitte.com';
      //Kojashrri
    public static final String ASSISTER_USER_ALIAS  = 'assisU';
    public static final String ASSISTER_USER_EMAIL_TEST = 'testAssisterUser@deloitte.com';
 
    // R1.1 - Survey Name
    
    public static final String  emailConsentSurveyNoPreferredComm ='RE_ConsentSurvey_NoPreferredComm';
    public static final String  emailConsentSurveyPreferredCommAvl ='RE_Consent_Survey_1';
    public static final String  MobilePhone ='Mobile Phone';
    public static final String  CelularPhone ='Celular';
	public static final String  EmailOption ='Email';

    public static final String SIMILAR_RESOURCE='Similar Resource';
    public static final String COMPLEMENTARY_RESOURCE='Complementary Resource';
    public static final String REFERRAL_SOURCE_FREQUENTLYPAIRED='Frequently Paired Together';
    public static final String REFERRAL_SOURCE_RELATEDSERVICES='Related Services';
    public static final String UNDEFINED='undefined';
    public static final String CONTACT_AGENCY_RECORDTYPE='Agency_User';
    public static final String CONTACT_TRAINING_LEVEL_TRAINED='Complete';

    public static final String strNonCitizenContactDevName ='Non_Citizen';
    public static final String strCitizenAppRole ='Citizen_Individual';
    public static final String sPercentage ='%';

    // Venkat: 7/31/2020: RE Security Changes
    public static final String RE_ASSISTER_ROLE ='Assister';
   
}