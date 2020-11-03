/* eslint-disable spellcheck/spell-checker */
/* eslint-disable camelcase */
/**
 * Constants file to maintain various constants used across LWC
 * usage: import the constants file to your component file and refer the constants
 * ex:
 *      import apConstants from 'c/sspConstants';
 *      apConstants.radioLabels.yes.
 */

/**
 * All the event for communication either in lwc or lwc to aura goes here.
 * NOTE: Event values should be in lower case to avoid Es lint issues.
 */
import sspAddRemoveMember from "@salesforce/label/c.sspAddRemoveMember";
import sspModifyInfoIncomeExpense from "@salesforce/label/c.sspModifyInfoIncomeExpense";
import healthCovSelectionLabel from "@salesforce/label/c.SSP_HealthCovSelectionLabel";
import healthCareEnrollTitle from "@salesforce/label/c.SSP_HealthCareEnrollTitle";
import kihippPreferredPayment from "@salesforce/label/c.SSP_KihippPreferredPayment";
import accessHealthcareCoverageTitle from "@salesforce/label/c.SSP_AccessHealthcareCoverageTitle";
import sspURLPath from "@salesforce/label/c.SSP_URL";
import sspHealthBenefitExchangeURL from "@salesforce/label/c.SSP_HealthBenefitExchangeURL";
import sspMapURL from "@salesforce/label/c.SSP_MapURL";
import sspAssisterMapLinkSpanishDocument from "@salesforce/label/c.SSP_AssisterMapLinkSpanishDoc";
import sspHealthCoverageFormURL from "@salesforce/label/c.SSP_HealthCoverageFormURL";
import sspFormURL from "@salesforce/label/c.SSP_Form1095URL";
import sspAgentURL from "@salesforce/label/c.SSP_AgentURL";

const events = {
    roleSelection: "roleselection",
    keyDown: "keydown",
    closeModal: "closemodal",
    saveDetail: "savedetail",
    cancelDetail: "canceldetail",
    saveEducationDetail: "saveeducation",
    cancelEducationDetail: "canceleducation",
    save: "save",
    cancel: "cancel",
    cancelMemberAdded: "canceladdmember",
    memberAdded: "memberadded",
    progressValueChange: "progressvaluechange",
    hideSection: "hidesection",
    benefitDetailButtonAction: "benefitdetailbuttonaction",
    remove: "remove",
    cardAction: "cardaction",
    detailButtonAction: "detailbuttonaction",
    hideToast: "hidetoast",
    handlePicklistChange: "handlepicklistchange",
    handleMultiSelectChange: "handlemultiselectchange",
    selectedVal: "selectedval",
    continueAnyway: "continueanyway",
    hideSpinner: "hidespinner",
    handleChange: "handlechange",
    inputTemplateValue: "inputtempval",
    doneSaving: "donesaving",
    medicareDetailButtonAction: "medicaredetailbuttonaction",
    changeTypeAheadPicklistValue: "changetypeaheadpicklistvalue",
    buttonClick: "buttonclick",
    updateHeader: "updateheader",
    toastEvent: "showcustomtoast",
    enableModalButtons: "enablemodalbuttons",
    PreferredSpokenLanguageCode__c: "PreferredSpokenLanguageCode__c",
    handleBlur: "handleblur",
    back: "back",
    hideFieldValidationError: "hidefieldvalidationerror",
    checkAllSelectedFields: "checkallselectedfields",
    checkSignaturePage: "checksignaturepage",
    navigateToWizardScreen: "navigatetowizardscreen",
    updateSignatureHeader: "updatesignheader",
    updateExpediteHeader: "updateexpediteheader",
    loadRFIIteration: "loadrfiiteration",
    showDocumentCenterHome: "showdocumentcenterhome",
    showUpload: "showupload",
    showNextRFI: "shownextrfi",
    loadNextRFI: "loadnextrfi",
    formProofChange:"formproofchange",
    singleFileUpload: "singlefileupload",
    hideLeftNavigation:"hideleftnavigation",
    fileUploadForRFI: "fileuploadforrfi",
    resetFormOfProof: "resetformofproof",
    hideAccessRequestModal:"hideaccessrequestmodal",
    reviewWorkStudyProg: "reviewworkstudyprog",
    iconClick: "iconclick",
    updateCollateralHeader: "updateCollateralHeader",
    hearingDocumentType: "hearingdocumenttype",
    invokeDriver: "invokedriver",
    saveCalled: "savecalled"
};

/**
 * List of screens not applicable for RAC.
 */
const inAccessibleScreens_RAC = [
    "SSP_APP_Select_Resources_1",
    "SSP_APP_Select_Resources_2",
    "SSP_APP_Select_Income",
    "SSP_APP_Select_Expenses"
];

/**
 * List of RAC flow names.
 */
const flowNames_RAC = ["RAC"];

/**
 *  Urls for static resource.
 */
const url = {
    needsReviewIcon: "/sspIcons/ic_needsreview@3x.png",
    infoIcon: "/sspIcons/ic_info@3x.png",
    progressNotStartedIcon: "/sspIcons/ic_progress_notstarted@2x.png",
    inProgressIcon: "/sspIcons/ic_progress_inprogress@2x.png",
    desktopBackgroundImage: "/sspIcons/EligibilityResultsBackground@2x.png",
    mobileBackgroundImage: "/sspIcons/Background@3x.png",
    backgroundImage: "/sspToastVariationCardIcons/Background@3x.png",
    progressChecked: "/sspIcons/ic_progress_checked@2x.png",
    nextIcon: "/sspIcons/ic_next@3x.png",
    spinner: "/sspLoadingImage/loadingIcon.gif",
    removeIcon: "/sspIcons/ic_remove.png",
    disagreeIcon: "/sspIcons/ic_disagree@3x.png",
    fileIcon: "/programPageResources/file@3x.png",
    pencilIcon: "/programPageResources/pencil@3x.png",
    laptopIcon: "/programPageResources/laptop@3x.png",
    incomeIcon: "/programPageResources/income@2x.png",
    redNextIcon: "/sspIcons/redCircledNextIcon.png",
    blueNextIcon: "/sspIcons/blueCircledNextIcon.png",
    darkNextIcon: "/sspIcons/darkCircledNextIcon.png",
    notStartedNextIcon: "/sspIcons/ic_next_white@3x.png",
    bannerBackgroundImage: "/sspIcons/HomePageBottomBackground@2x.png",
    renewalApplicationBackgroundImage:
        "/sspIcons/renewalApplicationBackground.png",
    expandIcon: "/sspIcons/ic_dropdown@3x.png",
    collapseIcon: "/sspIcons/ic_collapsedropdown@3x.png",
    nextWhiteArrow: "/icons/ic_next_white/ic_next@3x.png",
    nextPrimaryArrow: "/icons/ic_next_primary/ic_next_primary.png",
    citizenConnect: "/icons/ic_citizenConnectLogo/citizenConnect.png",
    authReps: sspURLPath + "auth-reps-assisters",
    home: sspURLPath,
    loginUrl: sspURLPath + "login",
    logoutUrl: "../secur/logout.jsp?retUrl=" + sspURLPath,
    emailIcon: "/programPageMobileImage/email@2x.png",
    mailIcon: "/programPageMobileImage/mail@2x.png",
    uploadIcon: "/programPageMobileImage/upload@2x.png",
    uploadProofDesktopImage: "/sspIcons/Upload_Forms_of_Proof@2x.png",
    uploadProofMobileImage: "/sspIcons/Upload_Forms_of_Proof.mobile@2x.png",
    bluePolygon: "/sspIcons/bluePolygon@2x.png",
    purplePolygon: "/sspIcons/purplePolygon@2x.png",
    yellowPolygon: "/sspIcons/yellowPolygon@2x.png",
    greyPolygon: "/sspIcons/greyPolygon@2x.png",
    fileLargeIcon: "/sspIcons/file@2x.png",
    laptopLargeIcon: "/sspIcons/laptop@3x.png",
    affidavitUrl: "/i-864-pc.pdf",
    shortSnapGetStartedUrl: sspURLPath + "getstartedsnap",
    accessRequestPage: "add_auth_rep_permissions__c",
    accessRequestPageAssister: "assister_access_request__c", // #382177
    accessRequestPageAuthRep: "auth_rep_access_request__c", // #382177
    consentChecked: "/sspIcons/ic_progress_checked-icon.png",
    consentDisagreed: "/sspIcons/ic_disagree_icon.png",
    medicaidFamily : "/MedicaidKCHIPAppForFamily.pdf",
    medicaidPerson : "/MedicaidKCHIPAppForOnePerson.pdf",
    childCareEnglish: "/Childcare_Application_English.pdf",
    childCareSpanish: "/Childcare_Application_Spanish.pdf",
    healthCoverKIHip: "/KIHIPPHealthCover.pdf",
    healthCoverKIHipSpanish: "/KIHIPPHealthCoverSpanish.pdf",
    healthCoverKIHipInstruction: "/HealthCoverageWithInstructions.pdf",
    healthCoverAuthorization: "/KHIPPDirectDepositAuthorizationForm.pdf",
    healthCoverAuthorizationSpanish:
        "/KHIPPDirectDepositAuthorizationFormSpanish.pdf",
    snapAppArabic: "/SNAPApplicationArabic.pdf",
    snapAppBosnian: "/SNAPApplicationBosnian.pdf",
    snapAppChinese: "/SNAPApplicationChinese.pdf",
    snapAppEnglish: "/SNAPApplicationEnglish.pdf",
    snapAppFrench: "/SNAPApplicationFrench.pdf",
    snapAppRussian: "/SNAPApplicationRussian.pdf",
    snapAppSomali: "/SNAPApplicationSomali.pdf",
    snapAppSpanish: "/SNAPApplicationSpanish.pdf",
    snapAppVietnamese: "/SNAPApplicationVietnamese.pdf",
    comparisonChart: "/MCO_Comparison_Chart.pdf",
    eligibilityLogoLoader: "/kynect-logo-loader.gif",
    eligibilityLoadBackGroundDesktop: "/Dashboard.png",
    eligibilityLoadBackGroundMobile: "/DashboardMobile.jpg",
    consentFormAppendix: "/ConsentFormAppendix.pdf",
    consentFormAppendixSpanish: "/ConsentFormAppendixSpanish.pdf",
    healthBenefitExchange: sspHealthBenefitExchangeURL,
    profileIcon: "/sspIcons/profile_icon.png",
    headerLogo: "/kynectBenefitsLogo.png",
    socialMediaFaceBookURL: "https://www.facebook.com/kynect.ky",
    socialMediaTwitterURL: "https://twitter.com/ky_kynect",
    sspFooterFaceBookIcon: "/sspSocialMediaIcon/FaceBookIconSmall.png",
    sspFooterTwitterIcon: "/sspSocialMediaIcon/TwitterIconSmall.png",
    sspHomePageBannerKynectLogo: "/sspHomePageKynectBannerLogo/kynect-logo-RGB.png"
};

/**
 *  Application Form fields constants.
 */
const fieldNames = {
    cell: "Cell"
};

/**
 *  Yes/No radio labels.
 */
const radioLabels = {
    yes: "Yes",
    no: "No"
};

/**
 *
 */
const pollingStatus_RAC = {
    success: "Success",
    failure: "Failed",
    pending: "Pending"
};

/**
 *  Toggle Field API Value.
 */
const toggleFieldValue = {
    yes: "Y",
    no: "N",
    unknown: "U",
    null: "NULL",
    historical: "H"
};

/**
 *  Navigation URL constants for Application form.
 */
const navigationUrl = {
    signAndSubmit: "Sign_and_Submit__c",
    dashBoard: "Home",
    repsAssisters: "authRepsAssisters__c",
    programSelection: "programSelection__c",
    mapUrl: sspMapURL,
    existingDashboard: "dashboard__c",
    findDCBSOffice: "google_map__c",
    citizenDashboard: "dashboard", //CD2
    benefitsPageName: "benefits-page", //#
    myInformation: "myInformation__c",
    authRepsAccessRequest: sspURLPath + "auth-rep-access-request",
    assisterAccessRequest: sspURLPath + "assister-access-request",
    assisterMapLinkSpanish: sspAssisterMapLinkSpanishDocument,
    benefitsPage: sspURLPath + "benefits-page",
    healthCoverageForm: sspHealthCoverageFormURL
};

const genericYesNo = [
    {
        label: "Yes",
        value: "yes"
    },
    {
        label: "No",
        value: "no"
    }
];

const mode = {
    addRemoveMember: "addRemoveMember"
};

const genericIds = {
    IndividualRecordType: "012r0000000GsGWAA0",
    RelationshipRecordType: "012r0000000H4mKAAS",
    AttendanceRecordType: "012000000000000AAA",
    BenefitRecordType: "012r0000000Gyly"
};

const femaleGenderCode = "F";

const pregnancyAge = 11;

const recordTypeNames = {
    SSPBenefitRecordType: "OutOfStateBenefit",
    SSPApplicationRecordType: "Application"
};
const programValues = {
    MA: "MA",
    MAGI: "MAGI",
    NONMAGI: "Non-MAGI",
    KT: "KT",
    TN: "TN",
    SN: "SN",
    SS: "SS",
    DS: "DS",
    CC: "CC",
    KP: "KP"
};
const screenName = {
    SSP_APP_Signature: "SSP_APP_Signature",
    SSP_APP_CollateralContact:"SSP_APP_CollateralContact"
};
const ACRFieldAPINames = {
    MA: "PermissionLevel_Medicaid__c",
    KT: "PermissionLevel_KTAP__c",
    SN: "PermissionLevel_SNAP__c",
    SS: "PermissionLevel_StateSupp__c",
    CC: "PermissionLevel_CCAP__c",
    KP: "PermissionLevel_KIHIPP__c",
    URL: "/auth-reps-assisters"
};

const medicaidTypes = {
    MAGI: "MAGI",
    NonMAGI: "Non-MAGI"
};

const stateLabels = {
  KY: "Kentucky"
};

const countyValues = {
    OUT_OF_STATE: {
        label: "Out Of State",
        value: "200"
    }
};

const pageActionValues = {
    SAVE: "save",
    EDIT: "edit"
};

const picklistValues = {
    Cell: "CE",
    Landline: "LND"
};

const householdCircumstancesConstants = {
    convictedForCrime: {
        notApplicableAgeRanges: {
            KT: [[0, 16]],
            SN: [[0, 16]]
        }
    },
    enrolledInSchool: {
        notApplicableAgeRanges: {
            MA: [[0, 17]],
            SN: [[0, 14], [50]]
        },
        notRequiredAgeRanges: {
            KT: [[0, 15], [20]]
        }
    },
    inFosterCare: {
        notApplicableAgeRanges: {
            MA: [[0, 18], [27]]
        }
    }
};

const expenseTypeCodes = {
    SE: "SE",
    UE: "UE",
    EE: "EE",
    ME: "ME",
    CAE: "CAE",
    DCE: "DCE",
    DE: "DE",
    AL: "AL"
};

const statusOfApplication = {
    A: "A",
    P: "P"
};
const benefitTypeCode = {
    BL: "BL",
    IR: "IR",
    RR: "RR",
    RS: "RS",
    UMWA: "UMWA",
    UI: "UI",
    VC: "VC",
    VP: "VP",
    WC: "WC"
};

const sspAssetFields = {
    ReceiveInHouseAssistance__c: "ReceiveInHouseAssistance__c",
    ExpensesAmount__c: "ExpensesAmount__c",
    IncomePayFrequency__c: "IncomePayFrequency__c",
    TotalGrossAmount__c: "TotalGrossAmount__c",
    Tips__c: "Tips__c",
    IncomePayDetailHoursPerWeek__c: "IncomePayDetailHoursPerWeek__c",
    ExpenseAmount__c: "ExpenseAmount__c",
    ExpenseTypeCode__c: "ExpenseTypeCode__c",
    ExpenseSubType__c: "ExpenseSubType__c",
    StartDate__c: "StartDate__c",
    EndDate__c: "EndDate__c",
    TuitionAmount__c: "TuitionAmount__c",
    BooksAmount__c: "BooksAmount__c",
    FeesAmount__c: "FeesAmount__c",
    MiscellaneousAmount__c: "MiscellaneousAmount__c",
    ExpenseFrequencyCode__c: "ExpenseFrequencyCode__c",
    IsNonHouseHoldMemberPayingExpenseToggle__c:
        "IsNonHouseHoldMemberPayingExpenseToggle__c",
    IsNonHouseHoldMemberPayingExpense__c: "IsNonHouseHoldMemberPayingExpense__c",
    IsPaidToVendor__c: "IsPaidToVendor__c",
    ChildName__c: "ChildName__c",
    DependentCareProvider__c: "DependentCareProvider__c",
    DependentIndividual__c: "DependentIndividual__c",
    ProviderName__c: "ProviderName__c",
    validateMaxLength: "Validate_Maxlength__c",
    validateMaxLengthMessage: "Validate_Maxlength_Msg__c",
    validateMinLength: "Validate_Minlength__c",
    validateMinLengthMessage: "Validate_Minlength_Msg__c",
    isDeleted: "IsDeleted__c",
    IncomeSubTypeCode__c: "IncomeSubtypeCode__c",
    ActivityType__c: "ActivityType__c"
};

const sspObjectAPI = {
    Contact: "Contact",
    SSP_Member__r: "SSP_Member__r",
    SSP_Member__c: "SSP_Member__c",
    SSP_Asset__c: "SSP_Asset__c",
    SSP_Application__c: "SSP_Application__c",
    SSP_Benefits__c: "SSP_Benefits__c",
    AccountContactRelation: "AccountContactRelation",
    SSP_ApplicationIndividual__c: "SSP_ApplicationIndividual__c" //Caretaker 6.5.2
};

/*For Caretaker 6.5.2*/
const appIndividualFields = {
    ServiceStartDate__c: "ServiceStartDate__c",
    ServiceEndDate__c: "ServiceEndDate__c",
    IsServiceProvidedSafelyToggle__c: "IsServiceProvidedSafelyToggle__c",
    IsPreventedNursingFacilityToggle__c: "IsPreventedNursingFacilityToggle__c",
    IsServiceReceivedRegularlyToggle__c: "IsServiceReceivedRegularlyToggle__c",
    CaretakerRelation__c: "CaretakerRelation__c",
    IsCaretakerLivingTogetherToggle__c: "IsCaretakerLivingTogetherToggle__c",
    CaretakerName__c: "CaretakerName__c",
    CaretakerPhone__c: "CaretakerPhone__c",
    //CIS
    CareCoordinatorAddressLine1__c: "CareCoordinatorAddressLine1__c",
    CareCoordinatorAddressLine2__c: "CareCoordinatorAddressLine2__c",
    CareCoordinatorCity__c: "CareCoordinatorCity__c",
    CareCoordinatorCountyCode__c: "CareCoordinatorCountyCode__c",
    CareCoordinatorStateCode__c: "CareCoordinatorStateCode__c",
    CareCoordinatorZipcode4__c: "CareCoordinatorZipcode4__c",
    CareCoordinatorZipcode5__c: "CareCoordinatorZipcode5__c",
    CISStartDate__c: "CISStartDate__c",
    CISEndDate__c: "CISEndDate__c",
    MentalIllnessImpairsFunctioningToggle__c:
        "MentalIllnessImpairsFunctioningToggle__c",
    MentalIllnessNeedsTreatmentToggle__c: "MentalIllnessNeedsTreatmentToggle__c",
    MentalIllnessWithoutAlzheimersToggle__c:
        "MentalIllnessWithoutAlzheimersToggle__c",
    IsServiceStoppingInstitutalizationToggle__c:
        "IsServiceStoppingInstitutalizationToggle__c",
    CareCoordinatorRelationship__c: "CareCoordinatorRelationship__c",
    CareCoordinatorName__c: "CareCoordinatorName__c",
    CareCoordinatorPhoneNumber__c: "CareCoordinatorPhoneNumber__c"
};

const accountContactRelationFields = {
    LastName__c: "LastName__c",
    FirstName__c: "FirstName__c",
    ConsentDate__c: "ConsentDate__c",
    SuffixCode__c: "SuffixCode__c",
    MiddleName__c: "MiddleName__c",
    RepresentativeRelationshipCode__c: "RepresentativeRelationshipCode__c"
};
const contactFields = {
    DoesAuthRepHasOrg__c: "DoesAuthRepHasOrg__c",
    Street__c: "Street__c",
    City__c: "City__c",
    SSP_State__c: "SSP_State__c",
    FirstName: "FirstName",
    MiddleName: "MiddleName",
    LastName: "LastName",
    SuffixCode__c: "SuffixCode__c",
    Email: "Email",
    SSN__c: "SSN__c",
    Gender__c: "Gender__c",
    GenderCode__c: "GenderCode__c",
    BirthDate: "Birthdate",
    Phone: "Phone",
    PrimaryPhoneExtension__c: "PrimaryPhoneExtension__c",
    MailingStreet: "MailingStreet",
    MailingCity: "MailingCity",
    CountyCode__c: "CountyCode__c",
    MailingState: "MailingState",
    ZipCode5__c: "Zipcode5__c",
    ZipCode4__c: "Zipcode4__c",
    AddressLine2__c: "AddressLine2__c",
    PreferredLanguageCode__c: "PreferredLanguageCode__c",
    RepresentativeRelationshipCode__c: "RepresentativeRelationshipCode__c",
    WorksForOrganization__c: "WorksForOrganization__c",
    OrganizationName__c: "OrganizationName__c",
    DCDataId__c: "DCDataId__c",
    OrganizationIdentificationNumber__c:"OrgranizationIdentificationNumber__c"
};

const assetAddressFields = {
    AddressLine1__c: "AddressLine1__c",
    AddressLine2__c: "AddressLine2__c",
    City__c: "City__c",
    CountyCode__c: "CountyCode__c",
    StateCode__c: "StateCode__c",
    zipCode4: "ZipCode4__c",
    zipCode5: "ZipCode5__c"
};

const addressLabels = {
    Address: "Address",
    AddressLineTwo: "Address line 2 (Optional)",
    City: "CITY",
    County: "COUNTY",
    State: "STATE",
    Zip: "ZIP"
};
const waiverFields = {
    HasBrainInjury: "HasBrainInjury",
    IsVentilatorDependent: "IsVentilatorDependent",
    RequireAssistance:
        "RequireAssistance",
    HasDevelopmentalDisability: "HasDevelopmentalDisability",
    WillContinueServices:
        "WillContinueServices",
        GenderCode__c:
        "GenderCode__c",
        WaiverScreeningId:
        "WaiverScreeningId",
        IndividualId:
        "IndividualId",
        IndividualName:
        "IndividualName"

};
const sspMemberFields = {
    SecondaryPhoneTypeCode__c: "SecondaryPhoneTypeCode__c",
    SecondaryPhoneNumber__c: "SecondaryPhoneNumber__c",
    SecondaryPhoneExtension__c: "SecondaryPhoneExtension__c",
    Send_Text_messages_to_Secondary__c: "Send_Text_messages_to_Secondary__c",
    PreferredSpokenLanguageCode__c: "PreferredSpokenLanguageCode__c",
    IsPrimaryTextPreferred__c: "IsPrimaryTextPreferred__c",
    ReceiveInHouseAssistance__c: "ReceiveInHouseAssistance__c",
    HasServicesorPayments__c: "HasServicesorPayments__c",
    IsReceivingHousingAssistance__c: "IsReceivingHousingAssistanceToggle__c",
    IsParticipatingInWorkStudyProgram__c: "IsParticipatingInWorkStudyProgram__c",
    IsNonHouseHoldMemberPayingExpense__c: "IsNonHouseHoldMemberPayingExpense__c",
    IsNonHouseHoldMemberPayingExpenseToggle__c:
        "IsNonHouseHoldMemberPayingExpenseToggle__c",
    IsMoneyPaidToOutsideToggle__c: "IsMoneyPaidToOutsideToggle__c",
    SameContactInfoAsHead__c: "SameContactInfoAsHOH__c",
    PrimaryPhoneNumber__c: "PrimaryPhoneNumber__c",
    PrimaryPhoneExtension__c: "PrimaryPhoneExtension__c",
    PreferredNotificationMethodCode__c: "PreferredNotificationMethodCode__c",
    PrimaryPhoneTypeCode__c: "PrimaryPhoneTypeCode__c",
    Email__c: "Email__c",
    PreferredWrittenLanguageCode__c: "PreferredWrittenLanguageCode__c",
    IndianTribeCode__c: "IndianTribeCode__c",
    IndianTribeState__c: "IndianTribeState__c",
    IsFederalRecognizedIndianTribeToggle__c:
        "IsFederalRecognizedIndianTribeToggle__c",
    IsEligibleForIHFlagToggle__c: "IsEligibleForIHFlagToggle__c",
    PreferredIssuanceMethod: "PreferredIssuanceMethod__c",
    RoutingNumber: "RoutingNumber__c",
    CheckingAccountNumber: "CheckingAccountNumber__c",
    BirthDate: "BirthDate__c",
    DeathDate: "DeathDate__c"
};

const sspBenefitsFields = {
    BenefitTypeCode__c: "BenefitTypeCode__c",
    StatusOfApplication__c: "StatusofApplication__c",
    BenefitApplicationDate__c: "BenefitApplicationDate__c",
    BenefitDenialDate__c: "BenefitDenialDate__c",
    BenefitDenialReason__c: "BenefitDenialReason__c",
    SSP_Member__c: "SSP_Member__c",
    BenefitRecordType: "SSIBenefits"
};

const benefitVariables = {
    BenefitFieldEntityNameList: "StatusofApplication__c,SSP_Benefits__c",
    denialReasonValue: "DN"
};

const fieldApiIncomeDetails = {
    PrimaryPhoneNumber__c: "PrimaryPhoneNumber__c",
    PrimaryPhoneExtension__c: "PrimaryPhoneExtension__c",
    IsSchoolDegreeRequiredToggle__c: "IsSchoolDegreeRequiredToggle__c",
    IsUnemployedBenefitsRequiredToggle__c: "IsUnempBenefitsRequiredToggle__c",
    SSP_Member__c: "SSP_Member__c",
    IncomeSubTypeCode__c: "IncomeSubtypeCode__c",
    IncomeSubType_Asset: "IncomeSubtypeCode__c,SSP_Asset__c",
    IsUnemployedBenefitsRequired_Member:
        "IsUnempBenefitsRequiredToggle__c,SSP_Member__c",
    incomeSuccess: "incomesuccess",
    showChildCareRecords: ["CC"],
    showMagiRecords: ["MAGI"],
    showMedicaidRecords: ["MAGI", "Non-MAGI"],
    showProgramRecords: ["MAGI", "Non-MAGI", "SN", "KT", "CC", "SS"],
    IncomeSubtypeCode__c: "IncomeSubtypeCode__c",
    Alimony: "AR",
    DivorceDate__c: "DivorceDate__c"
};

const currentEducationDetail = {
    highSchoolIndex: 13,
    highSchoolInstitutionIndex: 3,
    teenThreshold: 13,
    inputRequiredField: "Input_Required__c",
    schoolsListViewName: "SCHOOLS",
    TOGGLE: "TOGGLE",
    TYPEAHEAD: "TYPE-AHEAD-PICKLIST",
    showAgeRanges: {
        instituteType: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[0]],
            CC: [[0]],
            SP: [[0]]
        },
        graduationDate: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[16, 18]],
            CC: [[13]]
        },
        enrollmentType: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[16, 18]],
            CC: [[13]]
        },
        participatingInWorkStudyProgram: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[16, 18]],
            CC: [[13]]
        },
        assignedInstituteThroughProgram: {
            KT: [[16, 18]]
        },
        programCode: {
            KT: [[16, 18]]
        }
    },
    showIfAgeRanges: {
        graduationDate: {
            KT: [[15, 15], [19, 19]]
        },
        instituteName: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[0]],
            CC: [[13]]
        },
        enrollmentType: {
            KT: [[15, 15], [19, 19]]
        },
        participatingInWorkStudyProgram: {
            KT: [[15, 15], [19, 19]]
        },
        assignedInstituteThroughProgram: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[15, 15], [19, 19]],
            CC: [[13]]
        }
    },
    requiredAgeRanges: {
        instituteType: {
            SN: [[15, 49]],
            KT: [[16, 19]],
            CC: [[0]],
            SP: [[0]]
        },
        instituteName: {
            KT: [[16, 18]]
        },
        enrollmentType: {
            SN: [[15, 49]],
            KT: [[16, 18]]
            //CC: [[13]] vishakha : removed as part of 365306
        },// Added Defect #: 378196
        programCode : {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[15, 19]],
            CC: [[13]]
        }
    },
    requiredIfAgeRanges: {
        graduationDate: {
            KT: [[16, 18]],
            CC: [[13]]
        }
    }
};

const highestEducationDetail = {
    highSchoolIndex: 13,
    notRequiredAgeBound: 18,
    inputRequiredField: "Input_Required__c",
    showAgeRanges: {
        educationLevel: {
            MA: [[18]],
            SN: [[15, 49]],
            KT: [[0]],
            CC: [[0]]
        }
    },
    requiredAgeRange: {
        educationLevel: {
            SN: [[15, 49]],
            KT: [[0]],
            CC: [[0]]
        },
        graduationDate: {
            KT: [[0, 19]]
        }
    },
    sfFieldApi: "SF_FieldAPI__c",
    graduationDate: "HighestEducationGraduatedDate__c"
};

const sspExpenseFields = {
    SSP_Member__c: "SSP_Member__c",
    DependentIndividual__c: "DependentIndividual__c",
    DependentCareProvider__c: "DependentCareProvider__c",
    ExpenseSubType__c: "ExpenseSubType__c",
    HasChildSupport__c: "HasChildSupport__c",
    isShelter: "SE",
    isUtility: "UE",
    isHigherEducation: "EE",
    isMedical: "ME",
    isChildSupport: "CAE",
    isDependentCare: "DCE",
    isTaxDeduction: "DE",
    isAlimony: "AL",
    outside: "outside",
    ExpenseSubTypeAlimony: "AL",
    Alimony: "Alimony",
    true: "true",
    false: "false",
    showSnapRecords: ["SN"],
    showSnapKtRecords: ["SN", "KT"],
    showNonMagiSnapKtRecords: ["SN", "KT", "Non-MAGI","CC"],
    showNonMagiSnapRecords: ["SN", "Non-MAGI"],
    showMedicaidSnapKtRecords: ["SN", "KT", "Non-MAGI", "MAGI","CC"],
    showMagiRecords:  ["MAGI","Non-MAGI", "MA"],
    showKtRecords:["KT"],
    ChildName__c: "ChildName__c",
    ProviderName__c: "ProviderName__c"
};

const orderedEducationLevel = [
    "NG",
    "KG",
    "1G",
    "2G",
    "3G",
    "4G",
    "5G",
    "6G",
    "7G",
    "8G",
    "9G",
    "10G",
    "11G",
    "HG",
    "GED",
    "AG",
    "BG",
    "GG",
    "OG"
];

const orderInstitutionLevel =  ["HS", "MS", "ES", "HM", "OT", "TC", "CL", "GED"];

const resourceSummary = {
    resourceTempId: "strTempResId",
    addResource: "addresource",
    resourceType: "strResourceType",
    resourceId: "strResourceId",
    resourceSummaryError: {
        getApplicationId:
            "### Error occured in resource summary - getApplicationId ###",
        setApplicationId:
            "### Error occured in resource summary - setApplicationId ###",
        getMemberId: "### Error occured in resource summary - getMemberId ###",
        setMemberId: "### Error occured in resource summary - setMemberId ###",
        getNextEvent: "### Error occured in resource summary - getNextEvent ###",
        setNextEvent: "### Error occured in resource summary - setNextEvent ###",
        getAllowSaveData:
            "### Error occured in resource summary - getAllowSaveData ###",
        setAllowSaveData:
            "### Error occured in resource summary - setAllowSaveData ###",
        getMetadataList:
            "### Error occured in resource summary - getMetadataList ###",
        setMetadataList:
            "### Error occured in resource summary - setMetadataList ###",
        saveData: "### Error occured in resource summary - saveData ###",
        closeAddResourceModel:
            "### Error occured in resource summary - closeAddResourceModel ###",
        hideToast: "### Error occured in resource summary - hideToast ###",
        displayLearnMoreModelMethod:
            "### Error occured in resource summary - displayLearnMoreModelMethod ###",
        hideLearnMoreModelMethod:
            "### Error occured in resource summary - hideLearnMoreModelMethod ###",
        handleRemoveAction:
            "### Error occured in resource summary - handleRemoveAction ###",
        openResourceDetails:
            "### Error occured in resource summary - openResourceDetails ###",
        hideResourceDetails:
            "### Error occured in resource summary - hideResourceDetails ###",
        getResourceDetails:
            "### Error occured in resource summary - getResourceDetails ###"
    },
    result: "result",
    hideSection: "hidesection"
};

const resourceDetailConstants = {
    others: "Others",
    resourceType: "ResourceType__c",
    resourceTypeLabel: "strResourceTypeLabel",
    resourceAnotherOwner: "strAnotherOwner",
    resourceOtherOwners: "strOtherOwners",
    resourceHouseholdName: "strHouseholdMemberName",
    resourceMemberId: "strMemberId",
    resourceApplicationId: "strApplicationId",
    resourceAdditionalOwners: "strAdditionalOwners",
    resourceIncomeProducingProperty: "strIncomeProducingProperty",
    resourceRecordTypes: "recordTypeInfos",
    resourceDetailPage: "SSP_APP_Details_ResourceDetails",
    resourceDetailsError: {
        getObjectInfo: "### Error occured in resource details - getObjectInfo ###",
        getCurrentApplicationHouseholdMembers:
            "### Error occured in resource details - getCurrentApplicationHouseholdMembers ###",
        getInsurancePolicyDetailsForAsset:
            "### Error occured in resource details - getInsurancePolicyDetailsForAsset ###",
        getAllowSave: "### Error occured in resource details - getAllowSave ###",
        getObjWrap: "### Error occured in resource details - getObjWrap ###",
        setObjWrap: "### Error occured in resource details - setObjWrap ###",
        getMetadataList:
            "### Error occured in resource details - getMetadataList ###",
        setMetadataList:
            "### Error occured in resource details - setMetadataList ###",
        getPicklistValuesByRecordType:
            "### Error occured in resource details - getPicklistValuesByRecordType ###",
        handleButtonClick:
            "### Error occured in resource details - handleButtonClick ###",
        saveResourceDetails:
            "### Error occured in resource details - saveResourceDetails ###",
        renderedCallback:
            "### Error occured in resource details - renderedCallback ###",
        connectedCallback:
            "### Error occured in resource details - connectedCallback ###",
        getFieldProgramMappingsForResources:
            "### Error occured in resource details - getFieldProgramMappingsForResources ###",
        handleResourceTypeChange:
            "### Error occured in resource details - handleResourceTypeChange ###",
        processOnResourceDetailLoad:
            "### Error occured in resource details - processOnResourceDetailLoad ###",
        handleOwnerToggle:
            "### Error occured in resource details - handleOwnerToggle ###",
        handleVehicleAccessChange:
            "### Error occured in resource details - handleVehicleAccessChange ###",
        handleOwnerChange:
            "### Error occured in resource details - handleOwnerChange ###",
        addAnotherOwner:
            "### Error occured in resource details - addAnotherOwner ###",
        removeCurrentOwner:
            "### Error occured in resource details - removeCurrentOwner ###",
        handleConsentChange:
            "### Error occured in resource details - handleConsentChange ###",
        getResourceTypeLabel:
            "### Error occured in resource details - getResourceTypeLabel ###",
        handleIncomeProducingPropertyToggle:
            "### Error occured in resource details - handleIncomeProducingPropertyToggle ###",
        handleChangeFundOption:
            "### Error occured in resource details - handleChangeFundOption ###",
        handleResourceSubTypeChange:
            "### Error occured in resource details - handleResourceSubTypeChange ###",
        handleLifeInsuranceSubTypeChange:
            "### Error occured in resource details - handleLifeInsuranceSubTypeChange ###",
        handleVehicleCategoryChange:
            "### Error occured in resource details - handleVehicleCategoryChange ###",
        setPrimaryUserOptions:
            "### Error occured in resource details - setPrimaryUserOptions ###",
        removeOtherOwnersFromPrimaryUsers:
            "### Error occured in resource details - removeOtherOwnersFromPrimaryUsers ###",
        addNewOtherOwnersToPrimaryUsers:
            "### Error occured in resource details - addNewOtherOwnersToPrimaryUsers ###",
        handleAdditionalOwnerOnBlur:
            "### Error occured in resource details - handleAdditionalOwnerOnBlur ###",
        addPrimaryUsersFromAdditionalOwners:
            "### Error occured in resource details - addPrimaryUsersFromAdditionalOwners ###",
        checkIfProgramApplicableForMember:
            "### Error occured in resource details - checkIfProgramApplicableForMember ###",
        hideToast: "### Error occured in resource details - hideToast ###",
        setAllowSave: "### Error occured in resource details - setAllowSave ###",
        validateOtherOwnerErrors: "### Error occured in resource details - validateOtherOwnerErrors ###",
        checkIfArrayHasDuplicates: "### Error occured in resource details - checkIfArrayHasDuplicates ###"
    },
    resourceRecordTypeName: "SSPResource",
    resourceFieldIncomeEssentialToSupport: "IsIncomeEssentialToSelfSupport__c",
    resourceFieldIncomeProducingProperty: "IsIncomeProducingProperty__c",
    trueValue: "true",
    falseValue: "false",
    otherValue: "Other",
    resourceInsurancePolicyNumber: "strInsurancePolicyNumber",
    resourceInsuranceAssetId: "strInsuranceAssetId",
    resourceLastAdditionalOwner: "lastAdditionalOwner",
    resourceFuneralFundCode: "FuneralFundCode__c",
    resourcePolicyForFuneral: "strPolicyBeenAssignedForFuneral",
    resourceFuneralFundOption: "strFuneralFundedOption",
    resourceSubType: "strResourceSubType",
    resourceSubTypeField: "ResourceSubTypeCode__c",
    resourceTypeField: "ResourceTypeCode__c",
    resourceCashSurrenderValue: "CashSurrenderValue__c",
    resourcePolicyForBurial: "IsPolicyDesignatedToPayBurial__c",
    resourceAccessToVehicle: "strAccessToVehicle",
    resourceRecreationalVehicle: "RECR",
    resourceVehicleCategoryField: "VehicleCategoryCode__c",
    resourceVehicleCategory: "strVehicleCategory",
    resourceNoAccessReasonField: "NoAccessReason__c",
    resourceVehicleAccessField: "HasAccessToVehicle__c",
    resourceNotEnoughInformation: "NotEnoughInformation__c"
};

const taxFilingConstants = {
    taxFilingError: {
        getMemberId: "### Error occured in taxfiling details - getMemberId ###",
        setMemberId: "### Error occured in taxfiling details - setMemberId ###",
        getAllowSaveData:
            "### Error occured in taxfiling details - getAllowSaveData ###",
        setAllowSaveData:
            "### Error occured in taxfiling details - setAllowSaveData ###",
        getMetadataList:
            "### Error occured in taxfiling details - getMetadataList ###",
        setMetadataList:
            "### Error occured in taxfiling details - setMetadataList ###",
        getNextEvent: "### Error occured in taxfiling details - getNextEvent ###",
        setNextEvent: "### Error occured in taxfiling details - setNextEvent ###",
        connectedCallback:
            "### Error occured in taxfiling details - connectedCallback ###",
        getObjectInfoWiredMethod:
            "### Error occured in taxfiling details - getObjectInfoWiredMethod ###",
        getPicklistValues:
            "### Error occured in taxfiling details - getPicklistValues ###",
        getCurrentApplicationHouseholdMembers:
            "### Error occured in taxfiling details - getCurrentApplicationHouseholdMembers ###",
        getTaxFilingDetails:
            "### Error occured in taxfiling details - getTaxFilingDetails ###",
        calculateReviewRequiredRules:
            "### Error occured in taxfiling details - calculateReviewRequiredRules ###",
        handleTaxFilingStatusChange:
            "### Error occured in taxfiling details - handleTaxFilingStatusChange ###",
        handleTaxFilingNextYearChange:
            "### Error occured in taxfiling details - handleTaxFilingNextYearChange ###",
        handleParentOrSiblingChange:
            "### Error occured in taxfiling details - handleParentOrSiblingChange ###",
        handleTaxFilingClaimingDependentChange:
            "### Error occured in taxfiling details - handleTaxFilingClaimingDependentChange ###",
        handleDependentOfChange:
            "### Error occured in taxfiling details - handleDependentOfChange ###",
        handleDependentsChange:
            "### Error occured in taxfiling details - handleDependentsChange ###",
        handleTaxFilingDependentsChange:
            "### Error occured in taxfiling details - handleTaxFilingDependentsChange ###",
        showTaxFilingWarnings:
            "### Error occured in taxfiling details - showTaxFilingWarnings ###",
        getRequiredInputElements:
            "### Error occured in taxfiling details - getRequiredInputElements ###",
        closeWarningModal:
            "### Error occured in taxfiling details - closeWarningModal ###",
        getLocalRequiredValidations:
            "### Error occured in taxfiling details - getLocalRequiredValidations ###",
        saveTaxFilingData:
            "### Error occured in taxfiling details - saveTaxFilingData ###",
        checkMarkedClaimantWarning:
            "### Error occured in taxfiling details - checkMarkedClaimantWarning ###",
        hideToast: "### Error occured in taxfiling details - hideToast ###"
    },
    cDependentsStatusList: ["FJ", "FS", "HH", "QW", "SI"],
    sTaxFilingStatusList: ["FJ", "FS", "NF"],
    dStatusList: ["DM", "DN"],
    mStatusList: ["FJ", "FS"],
    individualRecordTypeName: "Individual",
    taxFilingPage: "SSP_APP_RTF_TaxFiling",
    sRelationshipType: "strRelationshipType",
    sRelatedMemberId: "strRelatedMemberId",
    spouseRelationship: "SP",
    sTaxFilerMemberCurrentYear: "strTaxFilerMemberCurrentYear",
    sTaxFilerMemberNextYear: "strTaxFilerMemberNextYear",
    sTaxFilingClaimingCurrent: "strTaxFilingClaimingCurrentYear",
    sTaxFilingClaimingNext: "strTaxFilingClaimingNextYear",
    sMemberId: "strMemberId",
    taxFilerMembersCurrent: "taxFilerMembersCurrent",
    taxFilerMembersNext: "taxFilerMembersNext",
    taxFilingDetailsClaimingDependentCurrentYear:
        "taxFilingDetailsClaimingDependentCurrentYear",
    taxFilingDetailsClaimingDependentNextYear:
        "taxFilingDetailsClaimingDependentNextYear",
    sTaxFilingStatusCurrentYear: "strTaxFilingStatusCurrentYear",
    sTaxFilingStatusNextYear: "strTaxFilingStatusNextYear",
    taxFilingDetailsSameNextYear: "taxFilingDetailsSameNextYear",
    currentYearType: "current",
    nextYearType: "next",
    sTaxFilerMemberCurrentYearName: "strTaxFilerMemberCurrentYearName",
    sMemberName: "strMemberName",
    taxFilingDependentsChange: "taxFilingDependentsChange,",
    taxFilerMemberCurrent: "TaxFilerMemberCurrent__c",
    taxFilerMemberNext: "TaxFilerMemberNext__c",
    filingStatus: {
        dependentInHousehold: "DM",
        dependentOutHousehold: "DN",
        marriedJointly: "FJ",
        marriedSeparately: "FS",
        headOfHousehold: "HH",
        single: "SI",
        notApplicable: "NA",
        doNotIntend: "NF",
        widower: "QW",
        markedClaimantWarning: "MCW",
        markedClaimantWarningDependent: "MCWD"
    }
};

const taxFilingDetailsFieldEntityNameList = [];
taxFilingDetailsFieldEntityNameList.push(
    "TaxFilerStatusCurrentYear__c,SSP_Member__c",
    "TaxFilerStatusNextYear__c,SSP_Member__c",
    "TaxFilerMemberCurrent__c,SSP_Member__c",
    "TaxFilerMemberNext__c,SSP_Member__c",
    "HasParentOrSiblingCurrentOutHousehold__c,SSP_Member__c",
    "HasParentOrSiblingNextOutHousehold__c,SSP_Member__c",
    "TaxFilingClaimingCurrent__c,SSP_Member__c",
    "TaxFilingClaimingNext__c,SSP_Member__c",
    "TaxFilingSameNextYear__c,SSP_Member__c"
);

const removeExistResourceConstants = {
    resourceRemovalError: {
        getAllowSaveData:
            "### Error occured in remove Existing resource - getAllowSaveData ###",
        setAllowSaveData:
            "### Error occured in remove Existing resource - setAllowSaveData ###",
        getMetadataList:
            "### Error occured in remove Existing resource - getMetadataList ###",
        setMetadataList:
            "### Error occured in remove Existing resource - setMetadataList ###",
        getMemberId:
            "### Error occured in remove Existing resource -  getMemberId ###",
        setMemberId:
            "### Error occured in remove Existing resource - setMemberId ###",
        getNextEvent:
            "### Error occured in remove Existing resource - getNextEvent ###",
        setNextEvent:
            "### Error occured in remove Existing resource - setNextEvent ###",
        getObjectInfoWiredMethod:
            "### Error occured in remove Existing resource - getObjectInfoWiredMethod ###",
        getPicklistValues:
            "### Error occured in remove Existing resource - getPicklistValues ###",
        connectedCallback:
            "### Error occured in remove Existing resource -  connectedCallback ###",
        hideToast: "### Error occured in remove Existing resource - hideToast ###",
        handleCheckboxAction:
            "### Error occured in remove Existing resource - handleCheckboxAction ###",
        handleOwnResourcesAction:
            "### Error occured in remove Existing resource - handleOwnResourcesAction ###",
        saveRemovalResourcesData:
            "### Error occured in remove Existing resource - saveRemovalResourcesData ###",
        getRequiredInputElements:
            "### Error occured in remove Existing resource - getRequiredInputElements ###",
        getExistingResources:
            "### Error occured in remove Existing resource - getExistingResources ###"
    },
    removeExistResourcePage: "SSP_APP_Details_RemoveExistingResource"
};

const changeExistResourceConstants = {
    resourceChangeError: "### Error occured in change Existing resource ###",
    recordId: "Id"
};

const resourceNotRequired = [
    "AN",
    "BF",
    "BP",
    "LE",
    "LSC",
    "LTC",
    "OT",
    "PQ",
    "PN",
    "TR"
];

const resourceTypes = {
    vehicle: "VI",
    funeralContract: "FA",
    otherLiquidResource: "OR",
    investment: "IN",
    lifeInsurance: "LI",
    account: "AC",
    realEstateProperty: "RP",
    funeralFundLIValue: ["LI", "LIFH"],
    wholeLifeInsurance: "WH",
    modifiedTermLifeInsurance: "MD",
    burialLifeInsurance: "BR"
};

const changeResourcesFieldEntityNameList = [];
changeResourcesFieldEntityNameList.push(
    "AccountBalance__c,SSP_Asset__c",
    "FaceValueAmount__c,SSP_Asset__c",
    "CashSurrenderValue__c,SSP_Asset__c",
    "LoanBalance__c,SSP_Asset__c",
    "RealEstateFairMarketValue__c,SSP_Asset__c",
    "PreFuneralAgmtGoodsAndServicesCost__c,SSP_Asset__c",
    "VehicleFairMarketValue__c,SSP_Asset__c",
    "VehicleDebt__c,SSP_Asset__c"
);

const resourcesFieldEntityNameList = [];
resourcesFieldEntityNameList.push("FuneralLocation__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("ResourceTypeCode__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("ResourceSubTypeCode__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "IsHomeHomesteadPropertyToggle__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push("Location__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("RealEstateFairMarketValue__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("AccountBalance__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "PreFuneralAgmtGoodsAndServicesCost__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push("FuneralFundCode__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "HasItemizedStmtOfGoodsSignByClientToggle__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push("VehicleCategoryCode__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("Make__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("Model__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("ModelYear__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("NoAccessReason__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("VehicleUseReason__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("StartDate__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("VehicleFairMarketValue__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("VehicleDebt__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "IsIndividualAbleToRideToggle__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push("HasAccessToVehicleToggle__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("PrimaryUserIndividual__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("CashSurrenderValue__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("FaceValueAmount__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("PolicyNumber__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("InsuranceCompanyName__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("LoanBalance__c,SSP_Asset__c");
resourcesFieldEntityNameList.push("Name,SSP_Member__c");
resourcesFieldEntityNameList.push("IsThereAnotherOwnerToggle__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "IsPolicyDesignatedToPayBurialToggle__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push(
    "IsPolicyUsedForPrearrangedFuneralToggle__c,SSP_Asset__c"
);
resourcesFieldEntityNameList.push("InsuranceCompanyAddress__c,SSP_Asset__c");
resourcesFieldEntityNameList.push(
    "InsuranceCompanyPhoneNumber__c,SSP_Asset__c"
);

const resourceSelectionConstants = {
    sAppliedPrograms: "strAppliedPrograms",
    sNewStatus: "New",
    sMemberStatus: "strMemberStatus",
    sIsTMember: "bTMember",
    stringQuestionValue: "strQuestionValue",
    sObjectRecords: "strObjectRecords",
    sQuestionId: "questionId",
    sQuestionLabel: "questionLabel",
    sApplicableMembers: "applicableMembers",
    sShowQuestion: "showQuestion",
    sObjectAPI: "objectAPI",
    sFieldAPI: "fieldAPI",
    sObjectField: "SobjectField__c",
    sQuestionValue: "questionValue",
    sSelectedRecords: "selectedRecords",
    sShowMembersList: "showMembersList",
    stringObject: "strObject",
    stringField: "strField",
    sAll: "All",
    resourceSelectionError: {
        getAllowSaveData:
            "### Error occured in resource selection - getAllowSaveData ###",
        setAllowSaveData:
            "### Error occured in resource selection - setAllowSaveData ###",
        getMetadataList:
            "### Error occured in resource selection - getMetadataList ###",
        setMetadataList:
            "### Error occured in resource selection - setMetadataList ###",
        getNextEvent: "### Error occured in resource selection - getNextEvent ###",
        setNextEvent: "### Error occured in resource selection - setNextEvent ###",
        connectedCallback:
            "### Error occured in resource selection - connectedCallback ###",
        hideToast: "### Error occured in resource selection - hideToast ###",
        getCurrentApplicationHouseholdMembers:
            "### Error occured in resource selection - getCurrentApplicationHouseholdMembers ###",
        buildResourceSelectionQuestions:
            "### Error occured in resource selection - buildResourceSelectionQuestions ###",
        handleQuestionsChange:
            "### Error occured in resource selection - handleQuestionsChange ###",
        handleMembersChange:
            "### Error occured in resource selection - handleMembersChange ###",
        checkIfProgramApplicableForMember:
            "### Error occured in resource selection - checkIfProgramApplicableForMember ###",
        getRequiredInputElements:
            "### Error occured in resource selection - getRequiredInputElements ###",
        saveResourceSelectionData:
            "### Error occured in resource selection - saveResourceSelectionData ###",
        getResourceSelectionData:
            "### Error occured in resource selection - getResourceSelectionData ###",
        getCurrentHouseholdMemberIds:
            "### Error occured in resource selection - getCurrentHouseholdMemberIds ###",
        openLearnMoreModal:
            "### Error occured in resource selection - openLearnMoreModal ###",
        closeLearnMoreModal:
            "### Error occured in resource selection - closeLearnMoreModal ###",
        updateResourcesSelection:
            "### Error occured in resource selection - updateResourcesSelection ###",
        getFieldProgramMappingsForResources:
            "### Error occured in resource selection - getFieldProgramMappingsForResources ###"
    },
    otherResourceSelectionError: {
        getAllowSaveData:
            "### Error occured in other resource selection - getAllowSaveData ###",
        setAllowSaveData:
            "### Error occured in other resource selection - setAllowSaveData ###",
        getMetadataList:
            "### Error occured in other resource selection - getMetadataList ###",
        setMetadataList:
            "### Error occured in other resource selection - setMetadataList ###",
        getNextEvent:
            "### Error occured in other resource selection - getNextEvent ###",
        setNextEvent:
            "### Error occured in other resource selection - setNextEvent ###",
        connectedCallback:
            "### Error occured in other resource selection - connectedCallback ###",
        wireApplicationRecord:
            "### Error occured in other resource selection - wireApplicationRecord ###",
        buildOtherResourceSelectionQuestions:
            "### Error occured in other resource selection - buildOtherResourceSelectionQuestions ###",
        getFieldProgramMappingsForResources:
            "### Error occured in other resource selection - getFieldProgramMappingsForResources ###",
        checkIfProgramApplicableForApplication:
            "### Error occured in other resource selection - checkIfProgramApplicableForApplication ###",
        getRequiredInputElements:
            "### Error occured in other resource selection - getRequiredInputElements ###",
        saveOtherResourceSelectionData:
            "### Error occured in other resource selection - saveOtherResourceSelectionData ###",
        updateRecord:
            "### Error occured in other resource selection - updateRecord ###",
        openLearnMoreModal:
            "### Error occured in other resource selection - openLearnMoreModal ###",
        closeLearnMoreModal:
            "### Error occured in other resource selection - closeLearnMoreModal ###",
        handleQuestionsChange:
            "### Error occured in other resource selection - handleQuestionsChange ###"
    },
    resourceSelectionPage: "SSP_APP_Select_Resources_1",
    otherResourceSelectionPage: "SSP_APP_Select_Resources_2",
    sShowHelp: "showHelp",
    sHelpContent: "helpContent",
    resourceTypeChange: "resourceTypeChange,",
    N: "N",
    Y: "Y",
    otherResourceTypeChange: "otherResourceTypeChange,"
};

const resourceSelectionFieldEntityNameList = [];

resourceSelectionFieldEntityNameList.push(
    "IsAssetsInExcess1MToggle__c,SSP_Application__c",
    "HasOwnBankAccountToggle__c,SSP_Member__c",
    "HasInvestmentsToggle__c,SSP_Member__c",
    "HasCashReloadableMoneyCardToggle__c,SSP_Member__c",
    "HasVehicleToggle__c,SSP_Member__c",
    "HasRealEstatePropertyToggle__c,SSP_Member__c",
    "HasLifeInsuranceToggle__c,SSP_Member__c",
    "HasPreArrangedFuneralContractToggle__c,SSP_Member__c",
    "Name,SSP_Member__c"
);

const otherResourcesSelectionFieldEntityNameList = [];

otherResourcesSelectionFieldEntityNameList.push(
    "HasAnnuityToggle__c,SSP_Application__c",
    "HasBurialFundToggle__c,SSP_Application__c",
    "HasBurialPlotsToggle__c,SSP_Application__c",
    "HasLifeEstateToggle__c,SSP_Application__c",
    "HasLifeSettlementContractToggle__c,SSP_Application__c",
    "HasLTCAgreementToggle__c,SSP_Application__c",
    "HasOtherResourceToggle__c,SSP_Application__c",
    "HasPartnershipQualifiedLTCPolicyToggle__c,SSP_Application__c",
    "HasPromissoryNoteOrLandContractToggle__c,SSP_Application__c",
    "HasSpecialNeedTrustToggle__c,SSP_Application__c"
);

const removeResourcesFieldEntityNameList = [];
removeResourcesFieldEntityNameList.push(
    "ResourceEndReason__c,SSP_Asset__c",
    "EndDate__c,SSP_Asset__c"
);

const relationshipConstants = {
    ageLessThanTen: ["MO", "SM", "FA", "SF"],
    ageLessThanTwenty: ["GM", "SX", "GF", "SG"],
    individualAgeLessThanRelated: ["MO", "GM", "FA", "GF", "SX", "SG"],
    individualIsMinor: ["MO", "GM", "SX", "FA", "GF", "SG"],
    individualAgeGreaterThanRelated: ["DA", "AD", "SO", "AS", "GS", "SR", "GD", "SH"],
    otherRelationship: ["VR", "UR"],
    femaleGenderCode: "F",
    maleGenderCode: "M",
    relationshipRecordTypeName: "Relationship",
    childCodeList: [
        "Daughter",
        "Adopted Daughter",
        "Son",
        "Step Son",
        "Adopted Son",
        "Foster Child",
        "Step Daughter"
    ],
    relationshipType: "RelationshipType__c",
    spouseLabel: "Spouse"
};
const absentParentConstants = {
    gender: {
        M: "Father",
        F: "Mother"
    }
};

const memberDisability = {
    showReceivingBenefitsProgram: ["MA", "SN", "KT", "SS", "CC"],
    showRenalDiseaseProgram: ["MA", "SN", "KT", "SS"],
    memberDisabilityScreenId: "SSP_APP_Details_Disability",
    memberBlindnessScreenId: "SSP_APP_Details_Blindness"
};

const memberConviction = {
    showMultipleProgram: ["KT", "SN"],
    showSingleProgram: ["SN"]
};

const classNames = {
    sspPicklistDropDown: ".ssp-picklistDropdown",
    sspSideNav: ".ssp-sidenav",
    sspDropDownContainer: ".ssp-dropdown-container",
    sspDropDownBtn: ".ssp-dropdown-btn",
    sspDashboardOptionBorder: "ssp-dashboard-option-border",
    utilityChevronDown: "utility:chevrondown",
    utilityChevronUp: "utility:chevronup",
    addressLineClass: ".addressLineClass",
    sspApplicationInputs: ".ssp-applicationInputs",
    sspApplicationDuplicateInputs: ".ssp-applicationDuplicateInputs",
    sspActiveItem: "ssp-active-item"
};

const fetchedListData = {
    Validate_MaxLength__c: "Validate_Maxlength__c",
    Validate_MaxLength_Msg__c: "Validate_Maxlength_Msg__c",
    Validate_MinLength__c: "Validate_Minlength__c",
    Validate_MinLength_Msg__c: "Validate_Minlength_Msg__c"
};

const validationEntities = {
    phoneExtensionMaxLength: "4",
    sspMiddleInitialMaxLength: "1"
};

const reportAChangeTypeOptions = [
    {
        label: sspAddRemoveMember,
        value: "add-remove"
    },
    {
        label: sspModifyInfoIncomeExpense,
        value: "modify"
    }
];

const contactRecordTypes = {
    Agent: "Agent",
    Assister: "Assister",
    Auth_Rep: "Auth Rep"
};

const assetRecordTypes = {
    Expense: "Expense",
    Income: "Income"
};
const sspMemberConstants = {
    IndividualRecordTypeName: "Individual",
    RecordTypesInfo: "recordTypeInfos"
};

/**
 *  Framework : Different flows configured in ssp.
 */
const flowNamesConstant = {
    householdInformation: "HouseholdInformation",
    memberDetails: "MemberDetails",
    healthCareCoverage: "HealthcareCoverage",
    ContactInformation: "ContactInformation",
    nonPrimaryContactInformation: "ContactInformation - NP",
    relationshipFlow: "Relationships&TaxFiling",
    memberIndividual: "MemberIndividualInformation",
    memmberHealth: "MemberHealthInformation",
    memberOtherInfo: "MemberOtherInformation",
    memberIncome: "MemberIncomeSubsidiesInfo",
    memberExpense: "MemberExpensesInformation",
    memberResources: "MemberResourcesInformation",
    memberFlowList: [
        "MemberDetails",
        "ContactInformation",
        "ContactInformation - NP",
        "Relationships&TaxFiling",
        "MemberIndividualInformation",
        "MemberHealthInformation",
        "MemberOtherInformation",
        "MemberIncomeSubsidiesInfo",
        "MemberExpensesInformation",
        "MemberHealthInformation",
        "MemberResourcesInformation"
    ]
};

/**
 *  Framework : Different Page Names in flows.
 */
const pageNamesConstant = {
    healthCareSelection: "SSP_APP_HealthCare_Select",
    healthCareEnrollmentSummary: "SSP_APP_Healthcare_EnrollmentSummary",
    healthCareAccessSummary: "SSP_APP_Healthcare_AccessSummary",
    healthCarePreferredPayment: "SSP_APP_Healthcare_PreferredPayment"
};

/**
 *  Framework : Different Page Headers in flow.
 */
const pageHeaders = {
    healthCareSelectionHeader: healthCovSelectionLabel,
    enrollmentHealthCoverage: healthCareEnrollTitle,
    accessToHealthCoverage: accessHealthcareCoverageTitle,
    preferredPayment: kihippPreferredPayment
};

const openModal = {
    duplicateKOGAccount: "duplicateKOGAccount",
    memberAddedTwice: "memberAddedTwice",
    existingCaseFound: "existingCaseFound"
};

const sspIndividualEnrollmentFields = {
    ExtAddressLine1: "ExtAddressLine1__c",
    EmployerName: "EmployerName__c",
    MedicaidId: "MedicaidId__c",
    ExtAddressLine2: "ExtAddressLine2__c",
    ExtCity: "ExtCity__c",
    ExtStateCode: "ExtStateCode__c",
    ExtZipCode4: "ExtZipCode4__c",
    ExtZipCode5: "ExtZipCode5__c",
    ExtCountyCode: "ExtCountyCode__c",
    ExtCountryCode: "ExtCountryCode__c",
    RelationshipCode: "RelationshipCode__c",
    IsTobaccoConsumer: "IsTobbacoConsumerToggle__c",
    CoverageStartDate: "CoverageStartDate__c",
    EndReason: "EndReason__c",
    CoverageEndDate: "CoverageEndDate__c",
    OtherReason: "OtherReason__c",
    ExtPolicyHolderSsn: "ExtPolicyHolderSsn__c",
    Gender: "Gender__c",
    DateOfBirth: "DateofBirth__c",
    HasMedicaid: "HasMedicaidToggle__c",
    SSPAPPHealthCareIndividualEnrollDetails:
        "SSP_APP_Healthcare_IndivEnrollDetails",
    sspAddress: ".addressLineClass",
    IsKHIPPSourceOfCoverage: "IsKhippSourceOfCoverage__c",
    SSP_InsuranceCoveredIndividual: "SSP_InsuranceCoveredIndiv__c",
    zipCode4: "zipcode4",
    zipCode5: "zipcode5",
    hideIndividualEnrollmentDetails: "hideindividualenrollmentdetails",
    IndividualEnrollmentDetailsErrorMessage:
        "Error occurred in Individual Enrollment Detail screen",
    yesValue: "yes",
    noValue: "no",
    Y: "Y",
    N: "N",
    Other: "Other",
    Address: "Address",
    AddressLine2: "Address Line 2",
    true: "true",
    OT: "OT",
    IsHealthCareCoveredPolicyHolderOutSideCase:
        "IsHealthCareCovPolicyHolderOutSideCase__c"
};

const sspHealthCoverageSelection = {
    sspApplicationObject: {
        objectApi: "SSP_Application__c",
        enrolledInHealthCareCoverageFieldApi:
            "EnrolledInHealthCareCoverageToggle__c",
        notEnrolledInHealthCareCoverageFieldApi:
            "NotEnrolledInHealthCareCoverageToggle__c"
    },
    screenId: "SSP_APP_HealthCare_Select",
    sEnrolledQuestion: "sEnrolledQuestion",
    sNotEnrolledQuestion: "sNotEnrolledQuestion"
};

const sspEnrollmentDetails = {
    sspInsuranceCoveredIndividual: {
        objectApi: "SSP_InsuranceCoveredIndiv__c",
        insuranceInternalPolicyHolderFieldApi: "IsPolicyHolder__c",
        suffixCodeFieldApi: "SuffixCode__c",
        extPolicyHolderFirstNameFieldApi: "ExtPolicyHolderFirstName__c",
        extPolicyHolderMiddleInitialFieldApi: "ExtPolicyHolderMiddleInitial__c",
        extPolicyHolderLastNameFieldApi: "ExtPolicyHolderLastName__c",
        firstNameFieldApi: "FirstName__c",
        lastNameFieldApi: "LastName__c"
    },
    sspInsurancePolicy: {
        objectApi: "SSP_InsurancePolicy__c",
        typeOfCoverageFieldApi: "TypeOfCoverageCode__c",
        insuranceCompanyNameFieldApi: "InsuranceCompanyName__c",
        insurancePolicyNumberFieldApi: "InsurancePolicyNumber__c",
        insuranceGroupNumberFieldApi: "InsuranceGroupNumber__c",
        physicalAddressLine1FieldApi: "PhysicalAddressLine1__c",
        physicalAddressLine2FieldApi: "PhysicalAddressLine2__c",
        planNameFieldName: "PlanName__c",
        policyBeginDateFieldApi: "PolicyBeginDate__c",
        enrollmentTierLevelFieldApi: "EnrollmentTierLevel__c",
        doNotHaveAllInformationFieldApi: "DoNotHaveAllInformation__c"
    },
    addressFields: {
        PhysicalAddressLine1__c: "PhysicalAddressLine1__c",
        PhysicalAddressLine2__c: "PhysicalAddressLine2__c",
        PhysicalCity__c: "PhysicalCity__c",
        PhysicalCountryCode__c: "PhysicalCountryCode__c",
        PhysicalCountyCode__c: "PhysicalCountyCode__c",
        PhysicalStateCode__c: "PhysicalStateCode__c",
        PhysicalZipCode4__c: "PhysicalZipCode4__c",
        PhysicalZipCode5__c: "PhysicalZipCode5__c"
    },
    entityMappingMetaData: {
        Input_Required__c: "Input_Required__c",
        Input_Required_Msg__c: "Input_Required_Msg__c"
    },
    ruleChange: "rulechange",
    policyHolderChangeRule: "policyHolderChangeRule"
};

const headerConstants = {
    DEP: "DEP",
    HOH: "HOH",
    TMEM: "TMEM",
    DAIL: "DAIL",
    DAIL_WORKER_API: "DAIL_Worker",
    CBW: "CBW",
    DAIL_Worker: "DAIL Worker",
    caseOwnership: "caseOwnership",
    selectedRole: "selectedRole",
    isTeamMember: "isTeamMember",
    HOHFlagEvent: "HOHFlagEvent",
    isNewUserDashboard: "isNewUserDashboard",
    TeamMemberFlagEvent: "TeamMemberFlagEvent",
    CHANGE: "CHANGE",
    WaitList: "Waitlisted",
    Enrolled: "Enrolled",
    Closed: "Closed",
    ReviewOnDashboard: "Review on Waiver Dashboard",
    NotSubmitted: "Not Submitted",
    UnderReview: "Under Review",
    ActionRequired: "Action Required"
};

const shortSNAPFlowConstants = {
    //Constants for Get Started Screen
    Unlock : "Unlock",
    Expired : "Expired",
    Loaded : "Loaded",
    nextPageURL : "/shortsnapflow",
    programSelectionPageURL : "/program-page?program=SN",

    //Constants for Contact Screen
    recordTypeName : "ShortSNAP",
    SSNFieldAPIName : "ShortSnapReportedSsn__c",
    CE : "CE",
    EE : "EE",
    ES : "ES",
    SSNNotMatchMessage : "Social Security Number does not match.",
    PhoneNumberFieldAPIName : "ShortSnapPrimaryPhoneNumber__c",
    PhoneTypeFieldAPIName : "ShortSnapPrimaryPhoneTypeCode__c",
    fieldRequiredMessage : "Please answer all required fields.",
    undefinedKey : "undefined",
    getStartedPageURL : "/getstartedsnap",

    //Constants for Address Screen
    isKentuckyResidentFieldAPIName : "ShortSnapIsIntentionToResideInKentucky__c",
    isFixedAddressFieldAPIName : "ShortSnapIsFixedAddress__c",
    isMailingAddressFieldAPIName : "ShortSnapIsMailingAddress__c",
    physicalGeolocationLatitude : "ShortSnapPhysicalGeolocation__Latitude__s",
    physicalGeolocationLongitude : "ShortSnapPhysicalGeolocation__Longitude__s",
    mailingGeolocationLatitude : "ShortSnapMailingGeolocation__Latitude__s",
    mailingGeolocationLongitude : "ShortSnapMailingGeolocation__Longitude__s",

    //Constants for Sign-Submit Screen
    ShortSNAP_RTName : "ShortSNAP"
};

const notUSCitizen = {
    immigrationDocumentTypeOptions: {
        DS2: "DS2",
        I20: "I20",
        AR: "AR",
        I76: "I76",
        CZ: "CZ",
        I9F: "I9F",
        FP: "FP",
        MRV: "MRV",
        I9: "I9",
        NT: "NT",
        CHE: "CHE",
        DHS: "DHS",
        HHS: "HHS",
        I79: "I79",
        OREL: "OREL",
        ORR: "ORR",
        OT: "OT",
        RAS: "RAS",
        WR: "WR",
        INA1: "INA1",
        INA3: "INA3",
        AI: "AI",
        NA: "NA",
        I3: "I3",
        I5: "I5",
        I57: "I57"
    },
    TYPEAHEAD: "C-SSP-TYPE-AHEAD-PICKLIST",
    picklistOptions: {
        Y: "Y",
        N: "N"
    },
    alienSponsorPrograms: ["MA", "SN", "KT"],
    legalStatusProgram: ["MA", "SN", "KT", "SS", "CC"],
    servedInMilitaryProgram: ["MA", "SN", "KT", "SS"],
    medicaid: "MA"
};

const inputTypes = {
    password: "password"
};

const removeCoverageConstants = {
    Other: "OT",
    COBRA: "CO",
    EventName: "removemodalclose",
    RecordTypeName: "Health Insurance Facility Type",
    ScreenName: "SSP_APP_RemoveCoverageModal"
};

const livingArrangement = {
    dailyMealCondition: ["IC", "GLA", "OC"],
    incarcerationCondition: ["IC"],
    returnRequiredCondition: ["DAA", "GLA", "HW", "BW", "APF", "PCH", "FCH"],
    returnCondition: [
        "DAA",
        "OC",
        "GLA",
        "HW",
        "IC",
        "BW",
        "SH",
        "LTC",
        "APF",
        "PCH",
        "FCH",
        "JC",
        "AS",
        "ECS",
        "HS",
        "MB",
        "RF",
        "SSE",
        "CH"
    ],
    organizationCondition: ["APF", "DAA", "FCH", "GLA", "LTC", "PCH"],
    organizationRequiredCondition: ["DAA", "GLA", "HW", "BW", "APF", "PCH", "FCH"]
};

const addAuthRepConstants = {
    dateToday: "dateToday",
    accountId: "accountId",
    flowName: "flowName",
    addAuthRep: "addAuthRep",
    updateAuthRep: "updateAuthRep",
    contactRecord: "contactRecord",
    accountContactRelationRecord: "accountContactRelationRecord",
    relationshipCodes: "relationshipCodes",
    applicationAccount: "applicationAccount",
    ERROR: "ERROR",
    EXCEPTION: "EXCEPTION",
    RepresentativeRelationshipCode: "RepresentativeRelationshipCode",
    close: "close",
    contactDuplicateRecord: "contactDuplicateRecord",
    mailto: "mailto:",
    tel: "tel:",
    duplicateAddress: "duplicateAddress",
    suffixCodeValues: "suffixCodeValues",
    appIndividualRecord: "appIndividualRecord",
    REPS_AuthorizedRepConsent: "REPS_AuthorizedRepConsent",
    contactId: "contactId"
};

const loggingAndErrorHandlingConstants = {
    contactNumber: "1-844-407-8398"
};

const agentModalConstants = {
    assist: "Assister",
    sspAssistOrAgentModal: "SspAssisterOrAgentModal",
    inHousePrivateAssist: "InHousePrivateAssister__c"
};
const dashboardConstants = {
    AUTHREP: "AUTHREP",
    ASSISTER: "ASSISTER",
    AGENT: "AGENT",
    sspDashboardDropdownIcon: ".ssp-dashboardDropdownIcon",
    sspDashboardDropdownContent: ".ssp-dashboardDropdownContent",
    sspExpandDropdown: "ssp-expandDropdown",
    sspCollapseDropdown: "ssp-collapseDropdown",
    sspBenefitsTab: ".ssp-benefitsTab",
    sspBenefitsContent: ".ssp-benefitsContent",
    active: "active",
    show: "show",
    sspMedicaidTab: ".ssp-medicaidTab",
    sspMedicaidContent: ".ssp-medicaidContent",
    caseOptions: "caseOptions",
    benefitStatus: "benefitStatus",
    ActiveBenefits: "ActiveBenefits",
    PendingInterviewBenefits: "PendingInterviewBenefits",
    PendingVerificationBenefits: "PendingVerificationBenefits",
    hasKHIPPProgram: "hasKihippProgram",
    hasActiveCase: "hasActiveCase",
    NonEnrolledMedicaidPrograms: "NonEnrolledMedicaidPrograms",
    EnrolledMedicaidPrograms: "EnrolledMedicaidPrograms",
    isExistingUser: "isExistingUser",
    isHeadOfHouseHold: "isHeadOfHouseHold",
    enableRAC: "enableRAC",
    enableRenewal: "enableRenewal",
    hasExpiringApplications: "hasExpiringApplications",
    continue: "continue",
    infoLabel: "infoLabel",
    primaryInfoLabel: "primaryInfoLabel",
    hasMedicaidRenewals: "hasMedicaidRenewals",
    Renewal: "Renewal",
    hasOtherRenewals: "hasOtherRenewals",
    hasPendingInterviewApplications: "hasPendingInterviewApplications",
    hasAuthRepAgents: "hasAuthRepAgents",
    contactName: "contactName"
};
const sspBenefitFields = {
    BeginDate: "BeginDate__c",
    EndDate: "EndDate__c",
    MedicareNumber: "MedicareNumber__c",
    HasMedicareCoverageButNoInfo: "HasMedicareCoverageButNoInfo__c",
    MedicareTypeCode: "MedicareTypeCode__c",
    MedicareCoverageSummaryErrorMessage:
        "Error occurred in Medicare Coverage summary screen",
    MedicareCoverageDetailsErrorMessage:
        "Error occurred in Medicare Coverage details screen",
    PartA: "Part A",
    PartB: "Part B",
    PartAB: "Part A & B",
    PA: "PA",
    PB: "PB",
    MD: "MD",
    MedicarePartA: "Medicare Part A",
    MedicarePartB: "Medicare Part B",
    MedicarePartAB: "Medicare Part A & B",
    Medicare: "Medicare"
};

const contactDetailsConstants = {
    cell: "CE",
    inputRequired: "Input_Required__c",
    inputRequiredMsg: "Input_Required_Msg__c",
    emailMetadataEntry: "Email__c,SSP_Member__c",
    emailOnlyValue: "EE",
    emailAndMessageValue: "ES",
    inputRequiredMsgString: "Please answer all required fields.",
    phoneTypeMetadataEntry: "PrimaryPhoneTypeCode__c,SSP_Member__c",
    //for defect 391731
    phoneNumberMetadata: "SecondaryPhoneNumber__c,SSP_Member__c",
    primaryPhoneNumberMetadata: "PrimaryPhoneNumber__c,SSP_Member__c", //used for primary contact applicant
    notificationMethod : "PreferredNotificationMethodCode__c,SSP_Member__c"
};
const formerFosterCareAge = "21";

const learnMoreModal = {
    enterKeyCode: 13,
    clickLearn: "click"
};

const blindnessMeta = {
    BenefitTypeCode: "BlindnessBenefitTypeCode__c",
    HasEndStageRenalDisease: "BlindnessHasEndStageRenalDisease__c",
    ParentUnableToCareForChild: "BlindnessParentUnableToCareForChild__c",
    DisabilityPermanentTemporary: "BlindnessStatus__c"
};
const disabilityMeta = {
    BenefitTypeCode: "BenefitTypeCode__c",
    HasEndStageRenalDisease: "HasEndStageRenalDiseaseToggle__c",
    UnableToBuyCookForSelf: "UnableToBuyCookForSelfToggle__c",
    ParentUnableToCareForChild: "ParentUnableToCareForChildToggle__c",
    DisabilityPermanentTemporary: "DisabilityPermanentTemporary__c"
};

const signaturePage = {
    Agree: "Agree",
    Close: "close"
};

const verticalNavigation = {
    pathName: "pathname"
};

const myInformationConstants = {
    availablePreferredContactMethods: ["EE", "ES", "P"],
    availablePhoneTypes: ["CE", "LND"]
};

const communityPageNames = {
  authRepsAssisters: "auth-reps-assisters",
  authRepsAssistersApi: "authRepsAssisters__c",
  myInformationApi: "myInformation__c",
  applicationSummaryApi: "Application_Summary__c",
  getStartedBenefits: "getStartedBenefits__c",
  renewals: "testpage_renewalapplicationstart__c",
  community: "comm__namedPage",
  prescreeening: "PreScreening__c",
  helpFAQ: "Knowledge_Categories__c", //Narapa: Task 363516 - Added a , in the before line and helpFAQ
    helpArticles: "Help_Articles__c", //Narapa: Task 363516 
  childCareProviderSearch: "child_care_provider__c",
  home: "Home", //Narapa: Defect 384767
  dashboard:"dashboard__c", //Narapa: Defect 384767
  reportFraud: "report-fraud",
  reportFraudApi: "ReportFraud__c"
};

const preferredPaymentFields = {
    preferredPaymentScreenError: "Error in Preferred Payment Method screen",
    EFT: "EFT",
    CH: "CH",
    SSPAPPHealthCarePreferredPayment: "SSP_APP_Healthcare_PreferredPayment",
    FederalReserve: "FederalReserve__c"
};

const preferredMcoSelectionConstants = {
    preferredName: "PreferredMCOName__c",
    preferredId: "PreferredMCOId__c",
    medicaid: "Medicaid/KCHIP"
}
const homePageConstants = {
    topBannerSec: "/sspIcons/HomePageTopBackground@2x.png",
    bottomBannerSec: "/sspIcons/HomePageBottomBackground@2x.png",
    mobileSection: "/sspIcons/Illustration.png",
    telephoneNumber: "18553068959",
    portalURL: sspFormURL,
    agentURL: sspAgentURL,
    applyBenefitPageName: "getStartedBenefits__c",
    programPage: "Program_Page__c",
    programState: "program",
    medicaidSection: "MA",
    KTAPSection: "KT",
    childCareSection: "CC",
    KHIPPSection: "KP",
    snapSection: "SN",
    UnitedWayBluegrass: "/UnitedWayoftheBluegrass.png"
};

const preferredPaymentConstants = {
    minLength: 4,
    maxLength: 17
};

const languageOptions = {
    Arabic: "ar"
};

const applicationMode = {
    RAC: "RAC",
    INTAKE: "Intake",
    RENEWAL: "Renewal",
    addRemoveMember: "addRemoveMember"
};

const summaryPageNameMap = {
    RAC: "ChangeSummary__c",
    Intake: "Application_Summary__c",
    Renewal: "RenewalSummary__c",
    addRemoveMember: "ChangeSummary__c",
    summaryPage : ["SSP_APP_Healthcare_AccessSummary","SSP_APP_Details_BenefitsFromAnotherStateDetails",
                    "SSP_APP_Details_EducationSummary","SSP_APP_Healthcare_EnrollmentSummary",
                    "SSP_APP_Details_Expense","SSP_APP_Details_Income_Summary","SSP_APP_Details_MedicareCoverageSummary",
                    "SSP_APP_Details_AbsentParentSummary","SSP_APP_Details_Resource"]
};

const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
];

const monthsValues = ["MonthA", "MonthB", "MonthC"];

const googleMap = {
    hostUrl: "../apex/SSP_GoogleMap?lcHost="
};

const eligibilityStatus = {
    approved: "E",
    denied: "X",
    pendingVerification: "P",
    dashboardUrl: "dashboard__c"
};

const generalConstants = {
    focusElementsString:
        "lightning-button, [href], lightning-radio-group, select, input, lightning-input, lightning-textarea, lightning-button-icon, lightning-checkbox-group, [tabindex]:not([tabindex='-1'])"
};

/**For caretaker 6.5.2 .*/
const symbols = {
    comma: ","
};

/**For caretaker 6.5.2 .*/
const screenIds = {
    careTaker: "SSP_APP_MD_CS",
    cis: "SSP_APP_MD_CIS"
};

/**For caretaker 6.5.2 .*/
const careTakerServices = {
    IsCaretakerLivingTogetherRenderRelation: ["CH", "PA", "SP"]
};

/**For caretaker 6.5.2 .*/
const profileNames = {
    citizen: "RE Citizen Profile",
    nonCitizen: "SSP Non Citizen Profile"
};

const programs = {
    MEDICAID: "MA",
    SNAP: "SN",
    KTAP: "KT",
    KHIPP: "KP",
    CCAP: "CC",
    SS: "SS",
    BCCTP: "BCCTP",
    PE: "PE",
    DSNAP:"DSNAP"
};

const findDCBSOffice = {
    addressCity: "addresscity",
    addressState: "addresstate",
    addressCountyCode: "addresscountycode",
    addressStateCode: "addressstatecode",
    addressZipCodeFour: "addresszipcode4",
    addressZipCodeFive: "addresszipcode5",
    officeHoursFromText: "OfficeHoursFromText__c",
    officeHoursToText:"OfficeHoursToText__c"
}

const sspDocUpload = {
    chunkSize: 750000,
    allSupportedFiles: ["JPEG", "JPG", "PNG", "PDF", "TIFF", "TIF"],
    supportedSet1: ["JPEG", "JPG", "PNG"],
    supportedSet2: ["PDF", "TIFF", "TIF"],
    maxSizeSet1: 3670016, // 3.5MB
    preMaxSizeSet1: 5242880, // 5MB
    maxSizeSet2: 2097152, // 2MB
    //maxSizeSet2: 10485760, //10MB
    quality: 0.5,
    convertSize: 0,
    formatJPEG: "jpeg",
    formatJPG: "jpg",
    formatTIF: "tif",
    language: "en_US"
}

const documentCenterHome = {
    //downloadDocumentUrl: "https://benefind--sspdev--c.visualforce.com/apex/SSP_DownloadDocument",
    downloadDocumentUrl: "download-document",
    editable: "Editable",
    readOnly: "ReadOnly",
    notAccessible: "NotAccessible"
};

const agencyManagement = {
    clientFirstName: "clientFirstName",
    clientLastName: "clientLastName",
    applicationNumber: "Application Number",
    caseNumber: "Case Number",
    clientDetails: "Client Details",
    assignmentStartDate: "Assignment Start Date",
    assignedTo: "Assigned To",
    sspMultiLineRadioInput: ".ssp-multilineRadioInput",
    sspDashboardDropdownIcon: ".ssp-dashboardDropdownIcon",
    sspDashboardDropdownContent: ".ssp-dashboardDropdownContent",
    sspExpandDropdown: "ssp-expandDropdown",
    sspCollapseDropdown: "ssp-collapseDropdown",
    sspApplicationNumber: "applicationNum",
    sspCaseNumber: "caseNum",
    pageData: "pagedata"
};

const clientSearch = {
    firstName: "clientSearchFirstName",
    lastName: "clientSearchLastName",
    caseNumber: "clientSearchCaseNumber",
    applicationNumber: "clientSearchApplicationNumber",
    socialSecurityNumber9: "socialSecurityNumber9",
    socialSecurityNumber4: "socialSecurityNumber4",
    dateOfBirth: "clientSearchDateOfBirth",
    phoneNumber: "clientSearchPhoneNumber",
    emailAddress: "clientSearchEmail",
    address: "clientSearchAddress",
    gender: "clientSearchGender",
    county: "clientSearchCounty",
    mco: "clientSearchMCO",
    renewal: "clientSearchRenewal",
    caseStatus: "clientSearchCaseStatus",
    rfi: "clientSearchRFI",
    submittedDate: "clientSearchSubmittedDate",
    assistedBy: "clientSearchAssistedBy",
    maidNumber: "clientSearchMaidNumber",
    sspMultiLineRadioInput: ".ssp-multilineRadioInput",
    sspClientDetailsSpanish: "Detalles del cliente",
    sspCaseStatus: "Estatus de caso",
    sspSubmittedDate: "Fecha en que se envió",
    sspLastUpdated: "Última actualización",
    sspAssistedBy: "Ayudado por"
};
const householdSummary = {
    ChangeSummaryMode: "ChangeSummaryMode__c"
}

const permission = {
    readOnly: "ReadOnly",
    editable: "Editable",
    notAccessible: "NotAccessible"
};
const clientCaseNotes = {
    sspAddNoteTextArea : ".ssp-addNoteTextArea",
    sspClientCaseNotes: ".ssp-clientCaseNotes"
};
const applicantIdentity = {
    newRIDP: "New RIDP",
    resumeRIDP: "Resume RIDP",
    questionKey: "x_x003C_Question_x003E_k_xBackingField",
    answerKey: "KeyValuePairOfstringstring",
    key: "key",
    value: "value",
    object: "object",
    sessionId: "SessionID"
};

const navFlowApplicationStatus = {
    SSP_Application: "SSP_Application",
    P: "P"
};


const requestCards = {
    medicaid: "Medicaid",
    EBT: "EBT",
    selectOffice: "selectoffice"
};
const typeOfAccount ="STA";

const reviewRequiredRules = {
    emergencyRule: "racEMC",
    healthConditionRule: "racHealthCondition",
    disabilityRule : "racDisability",
    blindnessRule : "racBlindness",
    nonMagiSelection : "NonMagiSelection",
    medicareRule : "medicareRule",
    resourceSelection : "resourceSelectRule",
    expenseRule : "review_expense_summary",
    communityRule: "review_cis_rule",
    careTaker: "review_caretaker"  
};

const alienSponsorFieldEntityNameList = [];
alienSponsorFieldEntityNameList.push(
    "SponsoredByOrganization__c,SSP_Member__c",
    "InternalAlienSponsor__c,SSP_Member__c",
    "ExternalAlienSponsor__c,SSP_Member__c",
    "SponsorFirstName__c,SSP_AlienSponsor__c",
    "AddressLine1__c,SSP_AlienSponsor__c",
    "AddressLine2__c,SSP_AlienSponsor__c",
    "PrimaryPhoneNumber__c,SSP_AlienSponsor__c",
    "City__c,SSP_AlienSponsor__c",
    "Countycode__c,SSP_AlienSponsor__c",
    "StateCode__c,SSP_AlienSponsor__c",
    "Zipcode5__c,SSP_AlienSponsor__c"
);

const userRole = {
    Organization_Auth_Rep: "Organization_Auth_Rep",
    Individual_Auth_Rep: "Individual_Auth_Rep",
    DAIL_Worker: "DAIL_Worker",
    Mail_Center_Worker: "Mail_Center_Worker",
    Mail_Center_Supervisor:"Mail_Center_Supervisor",
    Assister: "Assister", //#382177
    Citizen_Individual: "Citizen_Individual", //#384773
    EBI: "Eligibility_&_Benefit_Inquiry_User",
    DOE: "Department_Of_Education_Representative",
    DJJ: "DJJ_Representative",
    Agency_Admin:"Agency_Admin"
};
const pensionBasedDisability="PBD";

const childCareAttributes = {
    Active:"Active",
    EnrollmentStatusFromDate:"EnrollmentStatusFromDate",
    EnrollmentStatusEndDate:"EnrollmentStatusEndDate",
    ProviderDailyRate:"ProviderDailyRate",
    IndividualAllocatedDailyCoPayAmount:"IndividualAllocatedDailyCoPayAmount",
    FamilyAllocatedDailyCoPayAmount:"FamilyAllocatedDailyCoPayAmount",
    FlexiMaxFullDays:"FlexiMaxFullDays",
    FlexiMaxPartDays:"FlexiMaxPartDays",
    ServiceScheduleOnFriday:"ServiceScheduleOnFriday",
    ServiceScheduleOnMonday:"ServiceScheduleOnMonday",
    ServiceScheduleOnSaturday:"ServiceScheduleOnSaturday",
    ServiceScheduleOnSunday:"ServiceScheduleOnSunday",
    ServiceScheduleOnThursday:"ServiceScheduleOnThursday",
    ServiceScheduleOnTuesday:"ServiceScheduleOnTuesday",
    ServiceScheduleOnWednesday:"ServiceScheduleOnWednesday",
    SchoolSunday:"SchoolSunday",
    SchoolClosedNeed:"SchoolClosedNeed",
    SchoolOpenNeed:"SchoolOpenNeed"
};

const reportFraud = {
    reportFraudApi: "ReportFraud__c",
    whoCommittedFraud: "WhoCommittedFraud",
    whatHappened: "WhatHappened",
    individualFraudFirstName: "IndividualFraudFirstName",
    individualFraudMiddleName: "IndividualFraudMiddleName",
    individualFraudLastName: "IndividualFraudLastName",
    individualFraudSuffix: "IndividualFraudSuffix",
    individualFraudGender: "IndividualFraudGender",
    individualFraudSSN: "IndividualFraudSSN",
    individualFraudDOB: "IndividualFraudDOB",
    businessFraudName: "BusinessFraudName",
    fraudAddress: "FraudAddress",
    fraudCity: "FraudCity",
    fraudState: "FraudState",
    fraudZipCode: "FraudZipCode",
    fraudPhoneNumber: "FraudPhoneNumber",
    fraudCounty: "FraudCounty",
    fraudExt: "FraudExt",
    fraudCaseNumber: "FraudCaseNumber",
    individualFraudEmployerName: "IndividualFraudEmployerName",
    individualFraudEmployerAddress: "IndividualFraudEmployerAddress",
    individualFraudEmployerCity: "IndividualFraudEmployerCity",
    individualFraudEmployerState: "IndividualFraudEmployerState",
    individualFraudEmployerZipCode: "IndividualFraudEmployerZipCode",
    individualFraudEmployerCounty: "IndividualFraudEmployerCounty",
    canOIGContactYou: "CanOIGContactYou",
    howOIGContactYou: "HowOIGContactYou",
    userEmail: "UserEmail",
    userAddressLine1: "UserAddressLine1",
    userAddressLine2: "UserAddressLine2",
    userPhoneNumber: "UserPhoneNumber",
    userExt: "UserExt"
};
const hearing = {
    AddressLine1__c: "MailingAddressLine1__c",
    AddressLine2__c: "MailingAddressLine2__c",
    City__c: "MailingCity__c",
    CountyCode__c: "MailingCountyCode__c",
    StateCode__c: "MailingStateCode__c",
    CountryCode__c: "MailingCountryCode__c",
    zipCode4: "MailingZipCode4__c",
    zipCode5: "MailingZipCode5__c",
    cancelRequestHearing: "cancelrequesthearing",
    saveRequestHearing: "saverequesthearing",
    closeNextStep: "closenextstep",
    navigateToUpload: "navigatetoupload",
    goBackRequestDetails: "gobackrequestdetails",
    goBackNextSteps: "gobacknextsteps",
    uploadFromRequestDetails: "uploadfromrequestdetails",
    goBackHearing: "gobackhearing",
    DMSID: "?dmsId="
};

const kynectHomeCardStyle = "kynect-hp-card-header kynect-bgcolor_blue";

const reviewRequiredStatus = "REVIEW_REQUIRED";

// 397543, Remove Identity Document Upload for MWMA Users
const identityUploadFlagFalseRoles = [
    "APPLICATION_INITIATOR",
    "APPLICATION_REVIEWER",
    "CASE_MANAGEMENT_ADMINISTRATOR_INTERNAL",
    "WAIVER_CAPACITY_REVIEWER",
    "CASE_MANAGER",
    "CASE_MANAGER_IN_TRAINING", //387455
    "CASE_SUPERVISOR",
    "CHFS_APPLICATION_INITIATOR",
    "LEVEL_OF_CARE_ASSESSOR",
    "LOC_REVIEWER",
    "POC_REVIEWER",
    "SERVICE_NEEDS_ASSESSOR",
    "INTERNAL_LOC_ASSESSOR",
    "WAIVER_DIRECT_SERVICE_PROVIDER",
    "WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR",
    "CAPACITY_MANAGEMENT_ADMINISTRATOR",
    "Case_Management_Administrator_Read_Only",
    "PROD_Support_Read_Only",
    "CHFS_Internal_Reviewer",
    "CASE_MANAGER_IN_TRAINING",
    "Contact_Center_View_and_Edit",
    "Mail_Center_Supervisor",
    "Mail_Center_Worker"
];

// Added for defect 397691
const waiverRoles = [
    "APPLICATION_INITIATOR",
    "APPLICATION_REVIEWER",
    "CASE_MANAGEMENT_ADMINISTRATOR_INTERNAL",
    "WAIVER_CAPACITY_REVIEWER",
    "CASE_MANAGER",
    "CASE_MANAGER_IN_TRAINING", //387455
    "CASE_SUPERVISOR",
    "CHFS_APPLICATION_INITIATOR",
    "LEVEL_OF_CARE_ASSESSOR",
    "LOC_REVIEWER",
    "POC_REVIEWER",
    "SERVICE_NEEDS_ASSESSOR",
    "INTERNAL_LOC_ASSESSOR",
    "WAIVER_DIRECT_SERVICE_PROVIDER",
    "WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR",
    "CAPACITY_MANAGEMENT_ADMINISTRATOR",
    "Case_Management_Administrator_Read_Only", //386177
    "PROD_Support_Read_Only", //386177
    "CHFS_Internal_Reviewer", //386177
    "CASE_MANAGER_IN_TRAINING"
];

export {
    childCareAttributes,
    generalConstants,
    applicationMode,
    events,
    fieldNames,
    radioLabels,
    stateLabels,
    countyValues,
    navigationUrl,
    genericYesNo,
    genericIds,
    programValues,
    medicaidTypes,
    pageActionValues,
    householdCircumstancesConstants,
    femaleGenderCode,
    pregnancyAge,
    expenseTypeCodes,
    sspAssetFields,
    sspObjectAPI,
    sspMemberFields,
    fieldApiIncomeDetails,
    currentEducationDetail,
    highestEducationDetail,
    orderedEducationLevel,
    orderInstitutionLevel,
    sspExpenseFields,
    resourceSummary,
    sspBenefitsFields,
    resourceNotRequired,
    resourceDetailConstants,
    resourcesFieldEntityNameList,
    relationshipConstants,
    resourceTypes,
    benefitTypeCode,
    statusOfApplication,
    absentParentConstants,
    memberDisability,
    classNames,
    url,
    fetchedListData,
    removeExistResourceConstants,
    reportAChangeTypeOptions,
    changeExistResourceConstants,
    changeResourcesFieldEntityNameList,
    sspMemberConstants,
    flowNamesConstant,
    pageNamesConstant,
    pageHeaders,
    benefitVariables,
    openModal,
    sspIndividualEnrollmentFields,
    sspEnrollmentDetails,
    toggleFieldValue,
    inAccessibleScreens_RAC,
    flowNames_RAC,
    contactFields,
    pollingStatus_RAC,
    memberConviction,
    shortSNAPFlowConstants,
    headerConstants,
    notUSCitizen,
    removeCoverageConstants,
    resourceSelectionConstants,
    resourceSelectionFieldEntityNameList,
    validationEntities,
    contactRecordTypes,
    assetRecordTypes,
    accountContactRelationFields,
    assetAddressFields,
    ACRFieldAPINames,
    addressLabels,
    inputTypes,
    sspHealthCoverageSelection,
    otherResourcesSelectionFieldEntityNameList,
    livingArrangement,
    addAuthRepConstants,
    loggingAndErrorHandlingConstants,
    agentModalConstants,
    sspBenefitFields,
    recordTypeNames,
    contactDetailsConstants,
    learnMoreModal,
    blindnessMeta,
    disabilityMeta,
    signaturePage,
    verticalNavigation,
    preferredPaymentFields,
    formerFosterCareAge,
    removeResourcesFieldEntityNameList,
    picklistValues,
    homePageConstants,
    preferredPaymentConstants,
    myInformationConstants,
    communityPageNames,
    languageOptions,
    months,
    monthsValues,
    googleMap,
    dashboardConstants,
    eligibilityStatus,
    summaryPageNameMap,
    taxFilingDetailsFieldEntityNameList,
    taxFilingConstants,
    mode,
    programs,
    findDCBSOffice,
    appIndividualFields, //caretaker 6.5.2
    symbols, //caretaker 6.5.2
    screenIds, //caretaker 6.5.2
    careTakerServices, //caretaker 6.5.2
    profileNames,
    sspDocUpload,
    documentCenterHome,
    agencyManagement,
    clientSearch,
    householdSummary,
    waiverFields,
    permission,
    clientCaseNotes,
    applicantIdentity,
    reviewRequiredRules,
    navFlowApplicationStatus,
    userRole,
    requestCards,
    typeOfAccount,
    alienSponsorFieldEntityNameList,    
    pensionBasedDisability,
    reportFraud,
    hearing,
    reviewRequiredStatus,
    screenName,
    preferredMcoSelectionConstants,
    kynectHomeCardStyle,
    identityUploadFlagFalseRoles, // 397543, Remove Identity Document Upload for MWMA Users
    waiverRoles
};