/**
 * Name : SspAddHouseHoldMember.
 * Description : To add details about house hold members.
 * Author : Saurabh Rathi.
 * Date : 11/12/2019.
 **/
// eslint-disable-next-line no-unused-vars
import { LightningElement, api, wire, track } from "lwc";
import utility, { formatLabels, getYesNoOptions } from "c/sspUtility";

import constants from "c/sspConstants";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import firstName from "@salesforce/label/c.SSP_FirstName";
import middleName from "@salesforce/label/c.SSP_MI";
import lastName from "@salesforce/label/c.SSP_LastName";
import suffix from "@salesforce/label/c.SSP_Suffix";
import yes from "@salesforce/label/c.SSP_Yes";
import no from "@salesforce/label/c.SSP_No";
import cancelButton from "@salesforce/label/c.SSP_Cancel";
import saveButton from "@salesforce/label/c.SSP_Save";
import dateOfDeath from "@salesforce/label/c.SSP_DateOfDeath";
import memberPassedAwayText from "@salesforce/label/c.SSP_MemberPassedAwayText";
import programSelection from "@salesforce/label/c.SSP_ProgramSelection";
import dateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import gender from "@salesforce/label/c.SSP_Gender";
import addHouseholdMember from "@salesforce/label/c.SSP_AddHouseholdMember";
import completeQuestionText from "@salesforce/label/c.SSP_CompleteQuestionText";
import noMiddleNameText from "@salesforce/label/c.SSP_NoMiddleNameText";
import socialSecurityNumber from "@salesforce/label/c.SSP_SocialSecurityNumber";
import confirmSocialSecurity from "@salesforce/label/c.SSP_ConfirmSocialSecurity";
import usCitizenQuestion from "@salesforce/label/c.ssp_UsCitizenQuestion";
import servedUsMilitaryQuestion from "@salesforce/label/c.ssp_ServedUsMilitaryQuestion";
import residentKentuckyQuestion from "@salesforce/label/c.SSP_ResidentKentuckyQuestion";
import raceAffiliatesQuestion from "@salesforce/label/c.SSP_RaceAffiliatesQuestion";
import hispanicQuestion from "@salesforce/label/c.SSP_HispanicQuestion";
import ethnicityQuestion from "@salesforce/label/c.SSP_EthnicityQuestion";
import programApplyQuestion from "@salesforce/label/c.SSP_ProgramApplyQuestion";
import ssnQuestion from "@salesforce/label/c.SSP_SsnQuestion";
import noSsnQuestion from "@salesforce/label/c.SSP_NoSnnQuestion";
import selectRace from "@salesforce/label/c.SSP_SelectRace";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import reviewRequired from "@salesforce/label/c.SSP_ReviewRequired";
import ssnValidationFailedText from "@salesforce/label/c.SSP_SsnValidationFailedText";
import continueAnywayButton from "@salesforce/label/c.SSP_ContinueAnywayButton";
import deceasedMemberNote from "@salesforce/label/c.SSP_DeceasedMemberNote";
import checkMyEntries from "@salesforce/label/c.SSP_CheckMyEntries";
import genderOptionsTitleText from "@salesforce/label/c.SSP_GenderOptionsTitleText";
import suffixOptionsTitleText from "@salesforce/label/c.SSP_SuffixOptionsTitleText";
import saveDetailTitleText from "@salesforce/label/c.SSP_SaveDetailTitleText";
import cancelMemberTitleText from "@salesforce/label/c.SSP_CancelMemberTitleText";
import memberPassedTitleText from "@salesforce/label/c.SSP_MemberPassedTitleText";
import ethnicityOptionsTitleText from "@salesforce/label/c.SSP_EthnicityOptionsTitleText";
import affiliationTitleText from "@salesforce/label/c.SSP_AffiliationTitleText";
import chooseOneMissing from "@salesforce/label/c.SSP_ChooseOneMissing";
import noteText from "@salesforce/label/c.SSP_NoteText";
import addProgramNoteHeading from "@salesforce/label/c.SSP_AddProgramNoteHeading";
import specialNeedQuestion from "@salesforce/label/c.ssp_SpecialNeedQuestion";
import saveData from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.saveData";
import fetchMemberIdNotCitizen from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.fetchMemberIdNotCitizen";
import programNoteText from "@salesforce/label/c.SSP_ProgramNoteText";
import houseHoldLevelPrograms from "@salesforce/label/c.SSP_HouseHoldLevelPrograms";
import socialSecurityHelpText from "@salesforce/label/c.SSP_SocialSecurityHelpText";
import ssnNotMatch from "@salesforce/label/c.SSP_SsnNotMatch";
import usCitizenHelpText from "@salesforce/label/c.ssp_UsCitizenHelpText";
import hispanicHelpText from "@salesforce/label/c.SSP_HispanicHelpText";
import hispanicHelpTextDisclaimer from "@salesforce/label/c.SSP_HispanicHelpTextDisclaimer";
import specialNeedHelpText from "@salesforce/label/c.ssp_SpecialNeedHelpText";
import sspInformationVerifiedByFederalSources from "@salesforce/label/c.SSP_InformationVerifiedByFederalSources";
import thisIndividualText from "@salesforce/label/c.SSP_ThisIndividualText";
import programApplyQuestionHelpText from "@salesforce/label/c.SSP_ProgramApplyQuestionHelpText";
import checkMyEntriesToast from "@salesforce/label/c.SSP_CheckMyEntriesToast";
import nameSsnNotMatch from "@salesforce/label/c.SSP_NameSsnNotMatch";
import sspSocialSecurityNumberDoesNotMatch from "@salesforce/label/c.ssp_SocialSecurityNumberDoesNotMatch";
import sspReviewRequired from "@salesforce/label/c.sspReviewRequired";
import sspContinueAnywayButton from "@salesforce/label/c.SSP_ContinueAnywayButton";
import sspCheckMyEntries from "@salesforce/label/c.SSP_CheckMyEntries";
import sspDateOfDeathValidationMsg from "@salesforce/label/c.SSP_DateOfDeathValidationMsg";
import sspStartBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import sspPageInfoVerifiedHouseholdMember from "@salesforce/label/c.SSP_PageInfoVerifiedHouseholdMember";
import singleProgramNoteText from "@salesforce/label/c.SSP_SingleProgramNoteText";
import sspApplicantVerificationMethod from "@salesforce/label/c.SSP_ApplicantVerificationMethod";
import sspNewRIDP from "@salesforce/label/c.SSP_ApplicantVerificationNewRIDP";
import sspResumeRIDP from "@salesforce/label/c.SSP_ApplicantVerificationResumeRIDP";
import resumeRIDP from "@salesforce/apex/SSP_RIDPServices.resumeRIDP";
import getMemberData from "@salesforce/apex/SSP_RIDPServices.getData";
import sspHouseholdAliasHelpText from "@salesforce/label/c.SSP_HouseholdAliasHelpText"; //CR Alias help text label
import sspAliasFirstName from "@salesforce/label/c.SSP_AliasFirstName"; //CR Alias First Name label
import sspAliasLastName from "@salesforce/label/c.SSP_AliasLastName"; //CR Alias First Name label
import handleAlienSponsor from "@salesforce/apex/SSP_NotUSCitizenController.handleAlienSponsor";
import updateApplicationStatusUnsubmitted from "@salesforce/apex/SSP_RIDPServices.updateApplicationStatusUnSubmitted";
import checkExistingPermission from "@salesforce/apex/SSP_HouseHoldSummaryService.checkExistingPermission";
import sspModalContentTwo from "@salesforce/label/c.SSP_ApplicantVerificationModalContent2";
import sspModalHeader from "@salesforce/label/c.SSP_ApplicantVerificationModalHeader";
import sspModalContent from "@salesforce/label/c.SSP_ApplicantVerificationModalContent";
import sspTelephoneHREF from "@salesforce/label/c.SSP_FooterTelephoneHREF";
import sspContactNumber from "@salesforce/label/c.SSP_ApplicantVerificationExperianContact";
import impersonateCitizenOnLoad from "@salesforce/apex/SSP_RoleSelection.impersonateCitizenOnLoad";// Bug 389924
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import noReasonSsnField from "@salesforce/schema/SSP_Member__c.NoReasonSSNCode__c";
import ETHNICITY_CODE from "@salesforce/schema/SSP_Member__c.EthnicityCode__c";
import RACE_CODE from "@salesforce/schema/SSP_Member__c.RaceCode__c";
import GENDER_CODE from "@salesforce/schema/SSP_Member__c.GenderCode__c";
import SUFFIX_CODE from "@salesforce/schema/SSP_Member__c.SuffixCode__c";
import NATIONALITY_CODE from "@salesforce/schema/SSP_Member__c.NationalityCode__c";
import apConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import deleteNavFlowRecords from "@salesforce/apex/SSP_RIDPServices.deleteNavFlowRecords";
import { bHOHSSNPresentCheck, getAgeValue, getAgeInMonthsValue, ageBoundariesCrossedValue } from "c/sspAddHouseHoldMemberExtended";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspAddHouseHoldMember extends NavigationMixin(utility) {
  ssnInputType = "password";
  showProgramNote = false;
  showHelpIcon = true;
  mIMaxLength = 1;
  confirmSsnValue;
  toggleButtonOptions = getYesNoOptions();
  oldAgeValue;
  newAgeValue;
  label = {
    firstName,
    middleName,
    lastName,
    suffix,
    yes,
    no,
    cancelButton,
    saveButton,
    dateOfDeath,
    memberPassedAwayText,
    programSelection,
    dateOfBirth,
    gender,
    addHouseholdMember,
    completeQuestionText,
    noMiddleNameText,
    socialSecurityNumber,
    confirmSocialSecurity,
    usCitizenQuestion,
    servedUsMilitaryQuestion,
    residentKentuckyQuestion,
    raceAffiliatesQuestion,
    hispanicQuestion,
    ethnicityQuestion,
    programApplyQuestion,
    ssnQuestion,
    noSsnQuestion,
    selectRace,
    reviewRequired,
    ssnValidationFailedText,
    checkMyEntries,
    continueAnywayButton,
    deceasedMemberNote,
    genderOptionsTitleText,
    suffixOptionsTitleText,
    saveDetailTitleText,
    cancelMemberTitleText,
    memberPassedTitleText,
    ethnicityOptionsTitleText,
    affiliationTitleText,
    chooseOneMissing,
    noteText,
    addProgramNoteHeading,
    programNoteText,
    specialNeedQuestion,
    toastErrorText,
    sspInformationVerifiedByFederalSources,
    socialSecurityHelpText,
    usCitizenHelpText,
    specialNeedHelpText,
    hispanicHelpText,
    sspPageInformationVerified,
    programApplyQuestionHelpText,
    hispanicHelpTextDisclaimer,
    sspSocialSecurityNumberDoesNotMatch,
    sspReviewRequired,
    sspContinueAnywayButton,
    sspCheckMyEntries,
    sspDateOfDeathValidationMsg,
    sspStartBenefitsAppCallNumber,
    sspPageInfoVerifiedHouseholdMember,
    singleProgramNoteText,
    sspApplicantVerificationMethod,
    sspNewRIDP,
    sspResumeRIDP,
    sspHouseholdAliasHelpText,
    sspAliasFirstName,
    sspAliasLastName,
    sspModalContentTwo,
    sspModalHeader,
    sspModalContent,
    sspTelephoneHREF,
    sspContactNumber,
    startBenefitsAppCallNumber
  };
  
  @track recordId = "";
  @track Name = "";
  @track appIndividualId = "";
  @track appNumber;
  @track nonCitizenIdList = [];
  @track memberIndividualId = "";
  @track headOfHoldIndividualId = "";
  @track caseNumber = "";
  @track MetaDataListParent;
  @track allowSaveValue;
  @track objValue;
  @track deathChecked = false;
  @track updatedData;
  @track memberFullName = "";
  @track showRaceDropDown = false;
  @track showVerificationFailedModal = false;
  @track showEthnicity = false;
  @track ssnValue;
  @track suffixCodes;
  @track nationalityCodes;
  @track showErrorToast = false;
  @track isCitizen;
  @track newFirstName;
  @track showErrorModal = false;
  @track errorMsg = "";
  @track reference = this;
  @track programListLength = true;
  @track middleInitialFlag = true;
  @track disableDeathVerificationFlag = false;
  @track isVerification = false;
  parameters = {};
  @track isHandleSaveProcessing = false;
  @track memberObject = {
    sProgramsRequested: null,
    sEthnicityCode: null,
    bisHispanicLatino: null,
    sRace: null,
    bKentuckyResident: null,
    bServedInUSMilitary: null,
    bisUSCitizen: null,
    bSSNPresent: null,
    dDOB: "",
    sGender: "",
    sSufficeCode: "",
    sLastName: null,
    sMiddleName: null,
    sFirstName: null,
    sAliasLastName: null,
    sAliasFirstName: null,
    isNonPrimaryMember: true,
    bSSNVerified: null,
    sRecordId: null,
    sAppIndividualId: null,
    sApplicationNumber: null,
    bisHOH: false,
    sAge: null,
    sPrograms: null,
    sName: "",
    isUSCitizenValidated: null,
    sHOHMCIId: null,
    sCaseNumber: null,
  };
  @track pageName;
  @track defaultedProgramToShow = [];
  @track showMatchFoundModal = false;
  @track showPreVerificationModal = false;
  @track SSNRetryFlag = true;
  @track currentIndividualChild;
  @track existingIndividualChild;
  @track caseNumberCurrentChild;
  @track caseNumberExistingChild;
  @track showCannotApplyModal = false;
  @track continueAnywayChild;
  @track returnToDashboardChild;
  @track logOutChild;
  @track cannotApplyModalText;
  @track showSpinner = true; //2.5  Security Role Matrix and Program Access
  @track raceOptions;
  @track defaultNationalities = [];
  @track showDateOfDeathValidationMsg = false;
  @track citizenGreaterThan17Temp;
  @track showHouseholdProgramCount = false;
  @track applicationAlreadyExists = false;
  @track isReadOnlyUser = false; //2.5  Security Role Matrix and Program Access
  @track isScreenAccessible = false; //2.5  Security Role Matrix and Program Access
  @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
  @track renderingMap = {}; //2.5	Security Role Matrix and Program Access.
  @track verificationRIDPToggle; // CD2 5.2.1.1 - RIDP verification toggle
  @track isRoleContactCenter = false;
  @track isNonCitizenAndHOH = false;
  @track isNonCitizenDashboard = true; // Added as part of Defect - 383998
  @track methodRIDP = "";
  @track isResumeRIDP = false;
  @track isNewRIDP;
  @track referenceNumber = "";
  @track modalContentTwo = ".";
  @api mapforasnatinality;
  @api mapforhpinatinality;
  @track resumeRIDPResult;
  @track sspRIDPMemberData;
  @track uploadDocFlag = false;
  @track oldProgramApplied;
  defaultedProgram = houseHoldLevelPrograms.split(",");
  @track programRemoved = false;
  @track finalProgramListSize = false;
  @track callMCIForNonCitizen = false;
  @track callMCI = false;
  @track individualId;

  @api appId = "";
  @api addRemoveMember = false;
  @api reportChangeMode = false;
  @api addRemoveMode = false;
  @api mode;
  @api userDetails; //Added by Shrikant, to get profile and role of loggedIn user - CD2
  @api householdMembers = [];
  @api isStartEditClick = false; // Added as a part of Defect - 380582
  @track waiverUserRedirection = false;
  summaryTitle="";
  callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
  get isUSCitizenValidated () {
    return (
      this.memberObject.isUSCitizenValidated || this.memberObject.addRemoveMember || this.isReadOnlyUser //2.5  Security Role Matrix and Program Access
    );
  }
  /**CD2 2.5  Security Role Matrix and Program Access. */
  get isAddRemoveMember () {
    return this.memberObject.addRemoveMember || this.isReadOnlyUser;
  }
  get informationVerified () {
    return this.memberObject.isUSCitizenValidated || this.ifMciMember;
  }
  get deathCheckbox () {
    return !this.memberObject.bisHOH && this.appPrograms.includes("Medicaid") ? true : false;
  }
  get programList () {
    const updatedProgram = [];
    let householdProgramCount = 0;
    const programsRequested = this.memberObject.sProgramsRequested ? this.memberObject.sProgramsRequested.split(";") : null;
    this.oldProgramApplied = programsRequested;
    const list = this.appPrograms ? this.appPrograms.split(";") : null;
    if (list) {
      list.forEach((currentItem, index) => {
        const programObject = {
          label: "",
          value: null,
          disable: false,
          dataId: "",
        };
        programObject.label = currentItem;
        if (programsRequested) {
          programsRequested.forEach((item) => {
            if (item === currentItem) {
              programObject.value = currentItem;
            }
          });
        }
        if (currentItem === this.defaultedProgram[0] || currentItem === this.defaultedProgram[1] || this.reportChangeMode) {
          programObject.disable = true;
          householdProgramCount = householdProgramCount + 1;
          programObject.value = currentItem;
        }
        const ccCheck = currentItem === "Child Care Assistance" ? ((this.memberObject.sAge < 19 && !this.memberObject.bisHOH) ? false : true) : false; // Added # 391669

        if (!ccCheck) {
          programObject.dataId = "sProgramsRequested-" + index;
          programObject.disable = programObject.disable || this.isReadOnlyUser; //2.5	Security Role Matrix and Program Access.
          updatedProgram.push(programObject);
        }
      });
    }
    this.showHouseholdProgramCount = householdProgramCount > 1;
    this.programListLength = updatedProgram.length > 0 ? true : false;
    return updatedProgram;
  }
  get programNote () {
    return (
        this.appPrograms.includes(this.defaultedProgram[0]) ||
        this.appPrograms.includes(this.defaultedProgram[1])
    );
  }
  //Added by Shrikant CD2 - Bug 369486 Fix
  get disableMiddleInitial () {
    let isDisabled = !utility.isUndefinedOrNull(this.userDetails) && this.userDetails.profileName === apConstants.profileNames.nonCitizen ? false : this.memberObject.bisHOH; //made changes to enable fields in case of non citizen user
    isDisabled = (this.middleInitialFlag ? true : isDisabled) || this.isReadOnlyUser; //2.5 Security Role Matrix and Program Access
    return isDisabled || this.memberObject.addRemoveMember || this.memberObject.bSSNVerified ? true : false;
  }
  //Shikha - added
  get ifInitialsDisabled () {
    if (this.ifMciMember || this.memberObject.sMiddleName) {
      return true;
    }
    return false;
  }
  get ifMciMember () {
    const checkNonCitizen = this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.userDetails.userRole !== "Citizen_Individual";
    let isDisabled =
        !utility.isUndefinedOrNull(this.userDetails) && checkNonCitizen
            ? false
            : this.memberObject.bisHOH; //made changes to enable fields in case of non citizen user
    isDisabled = isDisabled || this.isReadOnlyUser; //2.5 Security Role Matrix and Program Access

    return isDisabled ||
        this.memberObject.addRemoveMember ||
        this.memberObject.bSSNVerified
        ? true
        : false;
  }
  get deathDateDisabled () {
    //Added by Sanchita
    const isDisabled = this.isReadOnlyUser; //CD2 2.5 Security Role Matrix and Program Access
    return isDisabled ||
      this.memberObject.addRemoveMember ||
      this.disableDeathVerificationFlag ||
      // this.memberObject.bSSNVerified || // CR 698 - Rahul
      this.memberObject.bIsDODVerified
      ? true
      : false;
  }
  get bHOHSSNPresent () {
    let isDisabled = bHOHSSNPresentCheck(this.memberObject);
    isDisabled = isDisabled || this.isReadOnlyUser;
    return isDisabled;
  }
  get showSpecialNeed () {
    return this.memberObject.sAge < 19 && this.appPrograms.includes("Child") && !this.memberObject.bisHOH ? true : false; // Added # 391669
  }
  get ssnAvailable () {
    this.ssnNotAvailable = this.memberObject.bSSNPresent === null ? true : this.memberObject.bSSNPresent === apConstants.toggleFieldValue.yes ? true : false;
    return this.memberObject.bSSNPresent === null ? false : this.memberObject.bSSNPresent === apConstants.toggleFieldValue.yes ? true : false;
  }
  set ssnAvailable (value) {
    this.memberObject.bSSNPresent = value ? apConstants.toggleFieldValue.yes : apConstants.toggleFieldValue.no;
  }
  @wire(getObjectInfo, { objectApiName: MEMBER_OBJECT })
  objectInfo;
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",

    fieldApiName: noReasonSsnField,
  })
  NoReasonSSNFieldValues ({ data, error }) {
    if (data) {
      this.noReasonSSNOptions = data.values;
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: ETHNICITY_CODE,
  })
  EthnicityPicklistValues ({ data, error }) {
    if (data) {
      this.ethnicityOptions = data.values;
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: RACE_CODE,
  })
  RaceCodeValues ({ data, error }) {
    if (data) {
      this.raceOptions = data.values;
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: GENDER_CODE,
  })
  GenderCodeValues ({ data, error }) {
    if (data) {
      this.genderOptions = data.values.filter((item) => item.value !== "U");
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: SUFFIX_CODE,
  })
  SuffixCodeValues ({ data, error }) {
    if (data) {
      this.suffixCodes = data.values;
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: NATIONALITY_CODE,
  })
  nationalityCode ({ data, error }) {
    if (data) {
      this.nationalityCodes = data.values;
      this.defaultNationalities = data.values;
      this.memberObject.sRace = this.memberObject.sRace;
      const itemCount = this.memberObject.sRace.filter((item) => item === "AS" || item === "HPI");
      const MapOfAsia = this.mapforasnatinality;
      const nativeMap = this.mapforhpinatinality;
      const finalRaceMap = [];
      if (itemCount.includes("HPI") && itemCount.includes("AS")) {
        this.nationalityCodes = this.defaultNationalities;
      } else if (itemCount == "AS") {
        Object.keys(MapOfAsia).map((key) => {
          const nation = {};
          nation.label = MapOfAsia[key];
          nation.value = key;
          finalRaceMap.push(nation);
        });
        this.nationalityCodes = finalRaceMap;
      } else if (itemCount == "HPI") {
        Object.keys(nativeMap).map((key) => {
          const nation = {};
          nation.label = nativeMap[key];
          nation.value = key;
          finalRaceMap.push(nation);
        });
        this.nationalityCodes = finalRaceMap;
      }
    }
    if (error) {
      console.error(`Error occurred while fetching picklist ${error}`);
    }
  }
  @api memberData;
  @api appPrograms;
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  set MetadataList (value) {
    if (value !== undefined && value !== null) {
      this.MetaDataListParent = value;
      /** CD2 2.5	Security Role Matrix and Program Access. */
      const appPrograms = !utility.isUndefinedOrNull(this.userDetails) && !utility.isUndefinedOrNull(this.userDetails.appPrograms) && this.userDetails.appPrograms != "" ? this.userDetails.appPrograms.split(";") : [];
      const { renderingMap, securityMatrix } = this.constructVisibilityMatrix(appPrograms);
      this.isReadOnlyUser = !utility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission === constants.permission.readOnly;
      this.isScreenAccessible = !utility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == constants.permission.notAccessible ? false : true;
      this.showAccessDeniedComponent = !this.isScreenAccessible;
      this.renderingMap = renderingMap;
      this.showSpinner = false;
      /** */
      if (value.mapOfPicklistOptions === undefined) {
        // Added the below condition to bypass the MiddleInitial field Validations.
        if (this.middleInitialFlag === true) {
          this.byPassValidations("MiddleInitial__c,SSP_Member__c", false);
        }
      }
    }
  }
  @api
  get allowSave () {
    return this.allowSaveValue;
  }
  set allowSave (value) {
    if (value !== undefined) {
      this.allowSaveValue = value;
    }
  }
  @api
  get objWrap () {
    return this.objValue;
  }
  set objWrap (value) {
    try {
      if (value) {
        this.createWrapperObject(value);
      }
    } catch (error) {
      console.error("error in objWrap", error);
    }
  }
  /**
   * @function : handleMiddleInitialData
   * @description : This method is used to disable checkbox field if it has valid middle initial name.
   */
  handleMiddleInitialData = () => {
    const errorMessages = this.template.querySelector(".ssp-middle-initial").ErrorMessageList;
    if (errorMessages.length) {
      this.template.querySelector(".ssp-no-mi").disabled = false;
    } else {
      this.template.querySelector(".ssp-no-mi").disabled = true;
    }
  };
  /**
   * @function : createWrapperObject
   * @description : This method is used to create the updated wrapper object for data saving.
   * @param {*} value -  This parameter provides the updated values for wrapper.
   */
  createWrapperObject (value) {
    try {
      const reference = this;
      const objWrapValue = JSON.parse(value);
      objWrapValue.sProgramsRequested = "";
      Object.keys(objWrapValue).forEach(function (key) {
        if (key === "sRace") {
          objWrapValue[key] = objWrapValue[key].replace(/,/g, ";");
        }
        if (key.includes("sProgramsRequested-") && objWrapValue[key] && objWrapValue[key] !== "false") {
          const particularValue = reference.programList.filter((item) => item.dataId === key)[0];
          objWrapValue.sProgramsRequested = `${objWrapValue.sProgramsRequested}${particularValue.label};`;
        }
      });
      objWrapValue.sRecordId = this.recordId;
      objWrapValue.sName = this.Name;
      objWrapValue.sAppIndividualId = this.appIndividualId;
      objWrapValue.sApplicationId = this.appId;
      objWrapValue.memberIndividualId = this.memberIndividualId;
      objWrapValue.sHOHMCIId = this.headOfHoldIndividualId;
      objWrapValue.sCaseNumber = this.caseNumber;
      objWrapValue.sApplicationNumber = this.appNumber;
      objWrapValue.bisHOH = this.memberObject.bisHOH;
      objWrapValue.referenceNumber= this.referenceNumber;
      this.objValue = JSON.stringify(objWrapValue);
    } catch (error) {
      console.error("error in createWrapperObject", error);
    }
  }
  /**
   * @function : connectedCallback
   * @description : This method is called when html is attached to the component.
   */
  connectedCallback () {
    try {
      this.summaryTitle = document.title;
      document.title = "Household Member Details";
      this.parameters = this.getQueryParameters();
      if (this.userDetails.userRole === "Contact_Center_View_and_Edit") {
        this.isRoleContactCenter = true;
      } else {
        this.isRoleContactCenter = false;
      }
      this.fieldMapping();
      this.memberObject = this.memberData ? Object.assign(this.memberObject, this.memberData) : this.memberObject;
      if (this.memberObject.bisHispanicLatino === apConstants.toggleFieldValue.yes) {
        this.showEthnicity = true;
      }
      if (this.memberObject.sDeathDateVerification != null) {
        if (this.memberObject.sDeathDateVerification === "SV" || this.memberObject.sDeathDateVerification === "MI") {
          this.disableDeathVerificationFlag = true;
        }
      }
      if (this.memberObject.dDeathDate) {
        this.deathChecked = true;
      }
      if (null != this.userDetails.sHOHId) {
        this.headOfHoldIndividualId = this.userDetails.sHOHId;
      }
      if (null != this.userDetails.sApplicationNumber) {
        this.appNumber = this.userDetails.sApplicationNumber;
      }
      if (null != this.userDetails.sCaseNumber) {
        this.caseNumber = this.userDetails.sCaseNumber;
      }
      for (const key of Object.keys(this.memberObject)) {
        if (key === "sRecordId") {
          this.recordId = this.memberObject[key];
        }
        if (key === "sAppIndividualId") {
          this.appIndividualId = this.memberObject[key];
        }

        if (key === "sRace") {
          this.memberObject[key] = this.memberObject[key] ? this.memberObject[key].replace(/;/g, ",") : [];
        }
        if (key === "sApplicationId") {
          this.appId = this.memberObject[key];
        }
        if (key === "memberIndividualId") {
          this.memberIndividualId = this.memberObject[key];
        }
        if (key === "sHOHMCIId" && null == this.headOfHoldIndividualId) {
          this.headOfHoldIndividualId = this.memberObject[key];
        }
        if (key === "sCaseNumber") {
          this.caseNumber = this.memberObject[key];
        }
        if (key === "sName") {
          this.Name = this.memberObject[key];
        }
      }
      if (this.memberObject.sRace.length > 0) {
        this.memberObject.sRace = this.memberObject.sRace.split(",");
        const itemCount = this.memberObject.sRace.filter((item) => item === "AS" || item === "HPI");
        this.showRaceDropDown = itemCount.length > 0 ? true : false;
      }
      this.newFirstName = this.memberObject.sFirstName !== null ? this.memberObject.sFirstName : thisIndividualText;

      this.memberObject.sLastName = this.memberObject.sLastName !== null ? this.memberObject.sLastName : "";
      this.memberFullName = [this.newFirstName, this.memberObject.sLastName].join(" ");
      this.updateLabel();
      //Set Middle Initial checkbox
      this.middleInitialFlag =
        //this.memberObject.sRecordId !== undefined &&
        //this.memberObject.sRecordId &&
        this.memberObject.sMiddleName === undefined || this.memberObject.sMiddleName === null || this.memberObject.sMiddleName === "" ? true : false;

      this.middleInitialFlag =
        !utility.isUndefinedOrNull(this.userDetails) && this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.middleInitialFlag && this.memberObject.bisHOH
          ? !utility.isUndefinedOrNull(this.memberObject.sFirstName) && this.memberObject.sFirstName != ""
            ? this.middleInitialFlag
            : false
          : this.middleInitialFlag;
      this.showDateOfDeathValidationMsg = false;
      this.methodRIDP = this.memberObject.sIdentityMethod;
      this.referenceNumber = this.memberObject.referenceNumber;
      this.getMemberDataHandler(false);
      const getRIDPToggleOptions = () => [
        {
          label: sspNewRIDP,
          value: apConstants.applicantIdentity.newRIDP,
        },
        {
          label: sspResumeRIDP,
          value: apConstants.applicantIdentity.resumeRIDP,
        },
      ];
      this.verificationRIDPToggle = getRIDPToggleOptions();
      if (this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.memberObject.bisHOH) {
        this.isNonCitizenAndHOH = true;
      }
      //Start - Added as part of Defect - 383998
      if (this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.userDetails.showCitizenDashboard === "true") {
        this.isNonCitizenDashboard = false;
      }
      //End - Added as part of Defect- 383998
      if (this.isNonCitizenAndHOH) {
        if (this.userDetails.profileName !== apConstants.profileNames.nonCitizen) {
          this.uploadDocFlag = false;
        } else if (
          // 397543, Remove Identity Document Upload for MWMA Users
          constants.identityUploadFlagFalseRoles.includes(this.userDetails.userRole)
        ) {
          this.uploadDocFlag = false;
        }
        //Start - Added condition as part of Defect - 383998
        else if (this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.userDetails.showCitizenDashboard === "false") {
          this.uploadDocFlag = true;
        }
        //End - Added condition as part of Defect - 383998
      }
      this.callMCIForNonCitizen = true;
    } catch (error) {
      console.error("error in connectedCallback", error);
    }
  }
  @api
  get pageToLoad () {
    return this.pageName;
  }
  set pageToLoad (value) {
    if (value) {
      this.pageName = value;
    }
  }
  /**
   * @function : renderedCallback
   * @description : This method is called after html is rendered.
   */
  renderedCallback () {
    try {
      const element = Array.from(this.template.querySelectorAll(".applicationInputs"));
      if (this.memberObject.addRemoveMember) {
        element.forEach((currentItem) => {
          if ((utility.isUndefinedOrNull(currentItem.value) || currentItem.value.length === 0) && currentItem.disabled) {
            currentItem.classList.remove("applicationInputs");
          }
        });
      }
      if (!this.isHandleSaveProcessing && element && element.length > 0 && this.callMCIForNonCitizen && this.sspRIDPMemberData != null && !this.isStartEditClick && this.sspRIDPMemberData.NonCitizenVerificationFlag) {
        this.callMCI = true;
        this.callMCIForNonCitizen = false;
        this.handleSave();
      }
    } catch (error) {
      console.error("error in renderedCallback", error);
    }
  }
  /**
   * @function : updateLabel
   * @description : This method is used for updating  the data in the label.
   */
  updateLabel () {
    try {
      this.label.usCitizenQuestion = formatLabels(this.label.usCitizenQuestion, [thisIndividualText]);
      this.label.servedUsMilitaryQuestion = formatLabels(this.label.servedUsMilitaryQuestion, [thisIndividualText]);
      this.label.residentKentuckyQuestion = formatLabels(this.label.residentKentuckyQuestion, [thisIndividualText]);
      this.label.servedUsMilitaryQuestion = formatLabels(this.label.servedUsMilitaryQuestion, [thisIndividualText]);
      this.label.hispanicQuestion = formatLabels(this.label.hispanicQuestion, [thisIndividualText]);
      this.label.ethnicityQuestion = formatLabels(this.label.ethnicityQuestion, [thisIndividualText]);
      this.label.programApplyQuestion = formatLabels(this.label.programApplyQuestion, [thisIndividualText]);
      this.label.ssnQuestion = formatLabels(this.label.ssnQuestion, [thisIndividualText]);
      this.label.noSsnQuestion = formatLabels(this.label.noSsnQuestion, [thisIndividualText]);
      this.label.raceAffiliatesQuestion = formatLabels(this.label.raceAffiliatesQuestion, [thisIndividualText]);
      this.label.selectRace = formatLabels(this.label.selectRace, [thisIndividualText]);

      this.label.deceasedMemberNote = formatLabels(this.label.deceasedMemberNote, [thisIndividualText]);

      this.label.specialNeedQuestion = formatLabels(this.label.specialNeedQuestion, [thisIndividualText]);
      this.label.reviewRequired = this.label.reviewRequired.replace(":", "");
      this.label.sspPageInfoVerifiedHouseholdMember = formatLabels(this.label.sspPageInfoVerifiedHouseholdMember, [addHouseholdMember]);
    } catch (error) {
      console.error("Error in updateLabel", error);
    }
  }

  /**
   * @function : fieldMapping
   * @description : This method is used for mapping the field.
   */
  fieldMapping () {
    try {
      const fieldEntityNameList = [];
      fieldEntityNameList.push(
        "FirstName__c,SSP_Member__c",
        "MiddleInitial__c,SSP_Member__c",
        "Alias_First_Name__c,SSP_Member__c",
        "Alias_Last_Name__c,SSP_Member__c",
        "LastName__c,SSP_Member__c",
        "SuffixCode__c,SSP_Member__c",
        "SSN__c,SSP_Member__c",
        "GenderCode__c,SSP_Member__c",
        "BirthDate__c,SSP_Member__c",
        "IsUSCitizenToggle__c,SSP_Member__c",
        "IsMilitaryMemberToggle__c,SSP_Member__c",
        "IsIntendToResideToggle__c,SSP_Member__c",
        "RaceCode__c,SSP_Member__c",
        "NationalityCode__c,SSP_Member__c",
        "IsHispanicLatinoSpanishToggle__c,SSP_Member__c",
        "EthnicityCode__c,SSP_Member__c",
        "DeathDate__c,SSP_Member__c",
        "NoReasonSSNCode__c,SSP_Member__c",
        "MemberProgramsApplied__c,SSP_ApplicationIndividual__c",
        "SpecialNeedIndicatorToggle__c,SSP_Member__c",
        "Identify_verification_method__c,SSP_Member__c"
      );
      this.getMetadataDetails(fieldEntityNameList, null, "SSP_APP_HHMemberDetails");
    } catch (error) {
      console.error("Error in fieldMapping", error);
    }
  }
  getAge (birthValue) {
    return getAgeValue(birthValue, this.todayDate);
  }
  getAgeInMonths = (date) => getAgeInMonthsValue(date, this.todayDate);

  ageBoundariesCrossed = (oldBirthDate, newBirthDate) => 
     ageBoundariesCrossedValue(oldBirthDate, newBirthDate,this.todayDate) //Defect-392437 - Added this.todayDate param
  ;

  /**
   * @function : handleSave
   * @description : This method is used to fire add member event for adding member details.
   */
  handleSave () {
    try {
      this.isHandleSaveProcessing= true;
      /** 383043 fix.*/
      if (this.isReadOnlyUser) {
        this.handleCancel();
      } else {
        //added for RIDP defect 143 by Gunjyot
        const elem = this.template.querySelectorAll(
          ".applicationInputs"
      );
      this.checkValidations(elem);
        // RIDP CODE ---------
        if (//added for RIDP defect 143 by Gunjyot
          this.allowSaveValue &&
          this.isNonCitizenAndHOH &&
          this.isRoleContactCenter &&
                    !utility.isUndefinedOrNull(this.sspRIDPMemberData) &&
          this.sspRIDPMemberData.NonCitizenVerificationFlag != null &&
          !this.sspRIDPMemberData.NonCitizenVerificationFlag &&
          !utility.isUndefinedOrNull(this.sspRIDPMemberData.ReferenceNumber) &&
          this.sspRIDPMemberData.IdentityVerificationMethod !== undefined &&
          this.sspRIDPMemberData.IdentityVerificationMethod === apConstants.applicantIdentity.resumeRIDP
        ) {
          try {
            this.showSpinner = true;
            this.label.sspModalContentTwo = formatLabels(this.label.sspModalContentTwo, [this.sspRIDPMemberData.ReferenceNumber]);
            this.isHandleSaveProcessing = false;
            this.resumeRIDPHandler();
          } catch (error) {
            console.error("Error in executing  Resume RIDP ", error);
          }
        } else {
          this.showPreVerificationModal = false;
          //commented for RIDP defect 143 by Gunjyot
         /* const elem = this.template.querySelectorAll(".applicationInputs");
          this.checkValidations(elem);*/ 
          //Start - Validation to check Date of death should be later than date of birth.
          let birthDate = "";
          let deathDate = "";
          for (let index = 0; index < elem.length; index++) {
            const element = elem[index];
            if (element.fieldName !== undefined && element.fieldName === constants.sspMemberFields.BirthDate && element.value !== null) {
              birthDate = new Date(element.value);
            }
            if (element.fieldName !== undefined && element.fieldName === constants.sspMemberFields.DeathDate && element.value !== null) {
              deathDate = new Date(element.value);
              break;
            }
          }
          if (birthDate !== "" && deathDate !== "" && deathDate < birthDate) {
            this.showDateOfDeathValidationMsg = true;
            this.allowSaveValue = false;
          } else {
            this.showDateOfDeathValidationMsg = false;
          }
          //End - Validation to check Date of death should be later than date of birth.
          this.showSpinner = true;
          if (this.objValue && this.allowSaveValue) {
            const saveObjectWrapper = this.objValue;
            const saveWrapper = JSON.parse(saveObjectWrapper);
            const revRules = [];
            const rulesAdded = this.triggerReviewRequiredOnNewMember(saveWrapper);
            if (rulesAdded) {
              revRules.push(rulesAdded);
            }
            //Start - Added as part of Defect - 383998
            if (this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.userDetails.showCitizenDashboard === "true") {
              this.callMCI = true;
            }
            const toBeSavedWrapper = JSON.parse(this.objValue);
            //Added to default MA program to deceased members
            if(!utility.isUndefinedOrNull(toBeSavedWrapper.dDeathDate)) {
                toBeSavedWrapper.sProgramsRequested = "Medicaid/KCHIP;";
            }
            //End - Added as part of Defect - 383998
            saveData({sJSON: JSON.stringify(toBeSavedWrapper),bSSNRetryFlag: this.SSNRetryFlag,sMode:this.addRemoveMember || this.reportChangeMode,callMCI: this.callMCI})
              .then(async (result) => {
                 //Added for Alien Sponsor Track Deletion changes
                 if(!utility.isUndefinedOrNull(result.mapResponse) && !utility.isUndefinedOrNull(result.mapResponse.Member)){ 
                 handleAlienSponsor({
                  applicationId: this.appId,
                  memberId: result.mapResponse.Member.Id
                  })
                  .then(() => {
                  //Do nothing.
                  })
                  .catch((error) => {
                  console.error("Error in getting response from handleAlienSponsor:", JSON.stringify(error));
                  });
                }
                  //Track Deletion changes end
                this.individualId = result.mapResponse.individualId;
                this.showSpinner = false;
                let noDriverNavigationModal = true;
                // Bug 389924
                if (result.mapResponse.waiverRole) {
                  if (this.isNonCitizenAndHOH && result.mapResponse.isFullMatch) {
                    this.waiverUserRedirection = true;
                    impersonateCitizenOnLoad({ contactJson: result.mapResponse.memberContact }).then((resultOnLoad) => {
                      this[NavigationMixin.Navigate]({ type: "comm__namedPage", attributes: { pageName: "dashboard" }, state: { redirectFromMember: "redirectFromSSPMember" } });
                    });
                  }// Bug 389924
                } else if (!utility.isUndefinedOrNull(result.mapResponse.redirectForConsent) && result.mapResponse.redirectForConsent) {
                  /** #382177 fix.*/
                  const applicationNumber = result.mapResponse.applicationNumber;
                  const applicationId = result.mapResponse.applicationId;
                  const individualIdForConsent = result.mapResponse.individualIdForConsent;
                  const userRole = result.mapResponse.selectedRole;
                  if (!utility.isUndefinedOrNull(userRole)) {
                    if ((userRole === constants.userRole.Organization_Auth_Rep || userRole === constants.userRole.Individual_Auth_Rep) && !utility.isUndefinedOrNull(applicationNumber)) {
                      this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: { name: constants.url.accessRequestPageAuthRep },
                        state: { applicationNumber: applicationNumber },
                      });
                    } else if (userRole === constants.userRole.Assister && !utility.isUndefinedOrNull(applicationId) && !utility.isUndefinedOrNull(individualIdForConsent)) {
                      this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: { name: constants.url.accessRequestPageAssister },
                        state: { applicationId: applicationId, individualId: individualIdForConsent },
                      });
                    }
                  }
                  noDriverNavigationModal = false;
                } else if (!utility.isUndefinedOrNull(result.mapResponse.existingApplicationPresent) && result.mapResponse.existingApplicationPresent) {
                  if (!this.waiverUserRedirection) {
                    this.applicationAlreadyExists = true;
                  }
                  noDriverNavigationModal = false;
                } else {
                  this.applicationAlreadyExists = false;
                  noDriverNavigationModal = true;
                }
                if (!this.waiverUserRedirection) {// Bug 389924
                  //check added to process response if no Driver navigation modal : Driver Navigation
                  if (noDriverNavigationModal && !result.mapResponse.bIsSuccess) {
                    const error = JSON.stringify(result.mapResponse.error);
                    this.showPreVerificationModal = false;
                    this.showCannotApplyModal = false;
                    this.showMatchFoundModal = false;
                                    if (error && error.includes("SSN_Verification_Error") && this.SSNRetryFlag) {
                      this.showPreVerificationModal = true;
                      this.SSNRetryFlag = false;
                                    } else if (error && error.includes("Cannot_Apply")) {
                      if (!this.waiverUserRedirection) {
                        this.showCannotApplyModal = true;
                      }
                      this.currentIndividualChild = result.mapResponse.BlockedMember;
                      if (result.mapResponse.CaseNumber) {
                        this.cannotApplyModalText = apConstants.openModal.existingCaseFound;
                      } else if (result.mapResponse.reason === apConstants.openModal.memberAddedTwice) {
                        this.cannotApplyModalText = apConstants.openModal.memberAddedTwice;
                      } else if (result.mapResponse.reason === apConstants.openModal.duplicateKOGAccount) {
                        this.cannotApplyModalText = apConstants.openModal.duplicateKOGAccount;
                      }
                    } else {
                      this.errorMsg = result.mapResponse.error;
                      this.showErrorModal = true;
                    }
                  }
                  //check added to process response if no Driver navigation modal : Driver Navigation
                  else if (noDriverNavigationModal) {
                    let ageGreaterThanEleven = false;
                    let genderFemale = false;
                    let citizenGreaterThan17 = false;
                    let isUSCitizen = false;
                    const [hohRecord] = this.householdMembers.filter((member) => member.bisHOH);
                    if (this.memberObject.dDeathDate && this.deathChecked === false) {
                      revRules.push("reviewTMemberChange," + true + ",null");
                      revRules.push("snapHouseholdMealsRule," + true + "," + hohRecord.sRecordId);
                      if (hohRecord.everyoneInHouseholdHaveSameAddress === true) {
                        revRules.push("HOHaddressOnNewMember," + true + "," + hohRecord.sRecordId);
                      }
                    }
                    elem.forEach((key) => {
                      if (key.fieldName === "BirthDate__c") {
                        const oldAge = this.getAge(key.oldValue);
                        this.oldAgeValue = oldAge;
                        const newAge = this.getAge(key.value);
                        this.newAgeValue = newAge;
                        if (oldAge !== newAge && !this.reportChangeMode) {
                          revRules.push("review_age_change," + true + "," + result.mapResponse.Member.Id);
                        }
                        const crossedBoundary = this.ageBoundariesCrossed(key.oldValue, key.value);
                        if (oldAge >= newAge && newAge <= 18 && oldAge !== newAge) {
                          revRules.push("AbsentParentReviewRequired," + "true," + result.mapResponse.Member.Id);
                        }
                        if (11 in crossedBoundary) {
                          ageGreaterThanEleven = crossedBoundary[11] === true;
                        }

                        if (13 in crossedBoundary) {
                          revRules.push("age_change_13," + crossedBoundary[13] + ",null");
                        }

                        if (17 in crossedBoundary) {
                          revRules.push("AgeGreaterThan17," + crossedBoundary[17] + ",null");
                          citizenGreaterThan17 = crossedBoundary[17] === true;
                        }
                        //
                        if (19 in crossedBoundary) {
                          revRules.push("checkAge19AndAbove," + crossedBoundary[19] + ",null");
                        }
                        if (60 in crossedBoundary) {
                          revRules.push("AgeGreaterThan60," + crossedBoundary[60] + "," + result.mapResponse.Member.Id);
                        }
                        const ageElement = this.template.querySelector(".ageField");
                        if (65 in crossedBoundary) {
                          revRules.push(...this.checkMedicaidRule(crossedBoundary[65]));
                        } else if (ageElement && ageElement.oldValue === undefined) {
                          revRules.push(...this.checkMedicaidRule(newAge >= 65));
                        }
                        if (this.mode === constants.applicationMode.INTAKE) {
                          if (65 in crossedBoundary) {
                            revRules.push("checkAge65AndAbove," + crossedBoundary[65] + ",null");
                          }
                        }
                        if (this.mode !== constants.applicationMode.RAC) {
                          if (this.getAgeInMonths(key.oldValue) < 4 && this.getAgeInMonths(key.value) >= 4) {
                            revRules.push("checkAge4MonthsAndAbove," + true + "," + result.mapResponse.Member.Id);
                          }
                        }
                      }
                      if (key.fieldName === "GenderCode__c") {
                        if (key.oldValue === "M" && key.value === "F" && !this.addRemoveMember && !this.reportChangeMode) {
                          revRules.push("PregnancyGender," + true + ",null");
                        }
                        if (key.value === "F") {
                          genderFemale = true;
                        }
                      }

                      if (key.fieldName === "IsUSCitizenToggle__c" && key.oldValue !== key.value) {
                        if (key.oldValue !== "N" && key.value === "N") {
                          if (!this.reportChangeMode) {
                            revRules.push("IsUSCitizenHealth," + true + ",null");
                          }
                          revRules.push("IsUSCitizen," + true + "," + result.mapResponse.Member.Id);
                        } else {
                          if (!this.reportChangeMode) {
                            revRules.push("IsUSCitizenHealth," + false + ",null");
                          }
                          revRules.push("IsUSCitizen," + false + "," + result.mapResponse.Member.Id);
                        }
                        if (key.oldValue === "N" && key.value === "Y") {
                          isUSCitizen = true;
                        }
                      }

                      if (key.fieldName === "RaceCode__c" && key.oldValue.toString() !== key.value.toString()) {
                        const oldV = key.oldValue;
                        const newV = key.value;
                        if (!oldV.toString().split(",").includes("IN") && newV.toString().split(",").includes("IN")) {
                          revRules.push("AmericanIndian," + true + "," + result.mapResponse.Member.Id);
                        } else {
                          revRules.push("AmericanIndian," + false + "," + result.mapResponse.Member.Id);
                        }
                      }
                    });
                    if (this.mode !== constants.applicationMode.RAC && this.oldAgeValue !== this.newAgeValue) {
                      if (ageGreaterThanEleven && genderFemale) {
                        revRules.push("checkAge11AndAbove," + true + ",null");
                      } else {
                        revRules.push("checkAge11AndAbove," + false + ",null");
                      }

                      if (ageGreaterThanEleven && genderFemale) {
                        revRules.push("checkAge11AndAboveRAC," + true + ",null");
                      } else {
                        revRules.push("checkAge11AndAboveRAC," + false + ",null");
                      }
                    }
                    if ((citizenGreaterThan17 || isUSCitizen) && !this.addRemoveMember && !this.reportChangeMode && this.nonCitizenIdList.length > 0 && this.oldAgeValue !== this.newAgeValue) {
                      revRules.push("AgeGreaterThan17USCitizen," + true + "," + this.nonCitizenIdList.join(","));
                    } else if (this.nonCitizenIdList.length > 0) {
                      revRules.push("AgeGreaterThan17USCitizen," + false + "," + this.nonCitizenIdList.join(","));
                    }
                    const isTMember = this.memberObject.isTMember;
                    if (isTMember && (this.oldProgramApplied === null || this.oldProgramApplied === undefined) && saveWrapper && saveWrapper.sProgramsRequested && saveWrapper.sProgramsRequested.split(";").length > 0) {
                      revRules.push("reviewTMemberRelationships," + true + "," + result.mapResponse.Member.Id);
                    }
                    if (
                      this.oldProgramApplied &&
                      this.oldProgramApplied.length > 0 &&
                      !this.oldProgramApplied.includes(apConstants.preferredMcoSelectionConstants.medicaid) &&
                      saveWrapper &&
                      saveWrapper.sProgramsRequested &&
                      saveWrapper.sProgramsRequested.split(";").length > 0 &&
                      saveWrapper.sProgramsRequested.split(";").includes(apConstants.preferredMcoSelectionConstants.medicaid)
                    ) {
                      revRules.push("addMedicaid," + true + "," + result.mapResponse.Member.Id);
                    }

                    const selectedScreens = [];
                    selectedScreens.push("SSP_APP_HHMemberDetails");
                    selectedScreens.push("SSP_APP_RTF_TaxFiling");
                    this.validateReviewRequiredRules(this.appId, result.mapResponse.Member.Id, selectedScreens, revRules, this.mode);

                    try {
                      if (
                        this.isNonCitizenAndHOH &&
                        !this.sspRIDPMemberData.NonCitizenVerificationFlag &&
                        this.userDetails.showCitizenDashboard === "false" //383998
                      ) {
                        if (this.isRoleContactCenter && this.sspRIDPMemberData.IdentityVerificationMethod !== apConstants.applicantIdentity.resumeRIDP) {
                          this.showSpinner = true;
                          deleteNavFlowRecords({
                            applicationId: this.appId,
                          })
                            .then((resultFlowRecords) => {
                              this.showSpinner = false;
                              this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                  name: "Contact_Information__c",
                                },
                                state: {
                                  memberId: this.recordId,
                                  applicationId: this.appId,
                                  mode: this.mode,
                                },
                              });
                            })
                            .catch((error) => {
                              console.error("Error in deleteNavFlowRecords" + JSON.stringify(error));
                            });
                        }
                      }
                    } catch (error) {
                      console.error("Error in navigating contact information ", error);
                    }
                    if (
                      !utility.isUndefinedOrNull(result.mapResponse.programRemoved) &&
                      !utility.isUndefinedOrNull(result.mapResponse.selectedRole) &&
                      result.mapResponse.selectedRole !== "Individual_Auth_Rep" &&
                      result.mapResponse.selectedRole !== "Organization_Auth_Rep"
                    ) {
                      if (!this.waiverUserRedirection) {
                        this.programRemoved = result.mapResponse.programRemoved;
                      }
                    }
                    if (!utility.isUndefinedOrNull(result.mapResponse.finalProgramListSize)) {
                      if (!this.waiverUserRedirection) {
                        this.finalProgramListSize = result.mapResponse.finalProgramListSize;
                      }
                    }
                    // Start - CD2 Auth Reps/Assister Login
                    const sRole = result.mapResponse.selectedRole;
                    const sMemberData = result.mapResponse.Member;
                    const sAppIndividualData = result.mapResponse.sAppIndividual;
                    const sPartialMatch = "Partial Match";
                    const sOrgAuthRepLabel = "Organization_Auth_Rep";
                    const sIndividualAuthRepLabel = "Individual_Auth_Rep";
                    const sAgencyAdmin = "Agency_Admin";
                    const sAssisterLabel = "Assister";
                    if (sRole && ((!this.programRemoved && (sRole === sAssisterLabel || sRole === sAgencyAdmin)) || sRole === sIndividualAuthRepLabel || sRole === sOrgAuthRepLabel)) {
                      // Check is HOH
                      if (
                        ((result.mapResponse.MatchType__c !== undefined && result.mapResponse.MatchType__c !== null && result.mapResponse.MatchType__c) ||
                          (result.mapResponse.isFullMatch !== undefined && result.mapResponse.isFullMatch !== null && result.mapResponse.isFullMatch) ||
                          (result.mapResponse.MergeCaseNumber !== undefined && result.mapResponse.MergeCaseNumber !== null)) &&
                        sMemberData &&
                        sAppIndividualData &&
                        sAppIndividualData.IsHeadOfHousehold__c
                      ) {
                        this.showSpinner = true;

                        checkExistingPermission({
                          sCaseNumber: result.mapResponse.MergeCaseNumber,
                          sProgramApplied: result.mapResponse.sAppIndividual.ProgramsApplied__c,
                          sRoleType: sRole,
                          sApplicationId: this.appId,
                        })
                          .then((resultResponse) => {
                            this.showSpinner = false;

                            const hasPermission = resultResponse.hasPermission;
                            const hasReverseSSPDCResponse = resultResponse.hasReverseSSPDCResponse;
                            // Check MatchType as Full/Partial
                            if (
                              ((result.mapResponse.MatchType__c !== undefined && result.mapResponse.MatchType__c !== null && result.mapResponse.MatchType__c === sPartialMatch) ||
                                (((result.mapResponse.isFullMatch !== undefined && result.mapResponse.isFullMatch !== null && result.mapResponse.isFullMatch) ||
                                  (result.mapResponse.MergeCaseNumber !== undefined && result.mapResponse.MergeCaseNumber !== null)) &&
                                  !hasPermission &&
                                  hasReverseSSPDCResponse)) &&
                              sRole !== sAssisterLabel &&
                              sRole !== sAgencyAdmin
                            ) {
                              const isPartialMatch = result.mapResponse.MatchType__c === sPartialMatch ? true : false;
                              const isAccessAvailable = !hasPermission ? true : false;
                              this.navigateToNextPageUpdate(false, isPartialMatch, isAccessAvailable);
                            } else if (
                              ((result.mapResponse.isFullMatch !== undefined && result.mapResponse.isFullMatch !== null && result.mapResponse.isFullMatch) ||
                                (result.mapResponse.MergeCaseNumber !== undefined && result.mapResponse.MergeCaseNumber !== null)) &&
                              !hasPermission &&
                              (sRole === sAssisterLabel || sRole === sAgencyAdmin) &&
                              hasReverseSSPDCResponse
                            ) {
                              this.navigateToNextPageUpdate(true, false, false);
                            } else if (result.mapResponse.programRemoved && (sRole === sIndividualAuthRepLabel || sRole === sOrgAuthRepLabel)) {
                              this.programRemoved = result.mapResponse.programRemoved;
                            } else if (result.mapResponse.MergeCaseNumber !== undefined && (!this.programRemoved || !result.mapResponse.programRemoved)) {
                              if (!this.waiverUserRedirection) {
                                this.showMatchFoundModal = true;
                              }
                              this.caseNumberCurrentChild = result.mapResponse.MergeCaseNumber;
                              this.caseNumberExistingChild = result.mapResponse.CaseNumber;
                            } else if (!this.programRemoved || !result.mapResponse.programRemoved) {
                              this.acknowledgeMemberAddition();
                            }
                          })
                          .catch((error) => {
                            console.error("Error in checkExistingPermission:" + JSON.stringify(error));
                          });
                      } 
                      else if ((sRole === sIndividualAuthRepLabel || sRole === sOrgAuthRepLabel) &&
                        sMemberData &&
                        sMemberData.MatchType__c === sPartialMatch &&
                        sAppIndividualData &&
                        sAppIndividualData.IsHeadOfHousehold__c) {
                        this.navigateToNextPageUpdate(false, true, true);
                      }
                      else if (result.mapResponse.MergeCaseNumber !== undefined && (!this.programRemoved || !result.mapResponse.programRemoved)) {
                        if (!this.waiverUserRedirection) {
                          this.showMatchFoundModal = true;
                        }
                        this.caseNumberCurrentChild = result.mapResponse.MergeCaseNumber;
                        this.caseNumberExistingChild = result.mapResponse.CaseNumber;
                      } else if (!this.programRemoved || !result.mapResponse.programRemoved) {
                        this.acknowledgeMemberAddition();
                      }
                    }
                    // End - CD2 Auth Reps/Assister Login
                    this.navigateToIdentityDocumentUpload();
                    await this.fetchMemberIdNotCitizenFunction(result.mapResponse.Member.Id);

                    if (!(sRole && (sRole === sIndividualAuthRepLabel || sRole === sOrgAuthRepLabel || sRole === sAssisterLabel))) {
                      if (
                        result.mapResponse.MergeCaseNumber !== undefined &&
                        !this.programRemoved &&
                        (this.userDetails.profileName === constants.profileNames.citizen ||
                          (this.userDetails.profileName === constants.profileNames.nonCitizen &&
                            this.userDetails.showCitizenDashboard === "false" &&
                            this.userDetails.profileName === constants.profileNames.nonCitizen &&
                            ((this.sspRIDPMemberData && this.sspRIDPMemberData.NonCitizenVerificationFlag === true) || (sAppIndividualData && sAppIndividualData.IsHeadOfHousehold__c === false))) ||
                          (this.userDetails.profileName === constants.profileNames.nonCitizen && this.userDetails.showCitizenDashboard === "true")) //383998
                      ) {
                        if (!this.waiverUserRedirection) {
                          this.showMatchFoundModal = true;
                        }
                        this.caseNumberCurrentChild = result.mapResponse.MergeCaseNumber;
                        this.caseNumberExistingChild = result.mapResponse.CaseNumber;
                      } else {
                        if (
                          sRole &&
                          sRole != constants.userRole.Citizen_Individual &&
                          sRole != constants.userRole.Mail_Center_Supervisor &&
                          sRole != constants.userRole.Mail_Center_Worker &&
                          ((this.sspRIDPMemberData && this.sspRIDPMemberData.NonCitizenVerificationFlag == true) || (sAppIndividualData && sAppIndividualData.IsHeadOfHousehold__c === false)) &&
                          !this.programRemoved
                        ) {
                          this.acknowledgeMemberAddition();
                        } else if (
                          sRole &&
                          (sRole == constants.userRole.Citizen_Individual ||
                            sRole == constants.userRole.Mail_Center_Supervisor ||
                            sRole == constants.userRole.Mail_Center_Worker ||
                            constants.identityUploadFlagFalseRoles.includes(this.userDetails.userRole) || // 397543, Remove Identity Document Upload for MWMA Users
                            (this.userDetails.profileName === constants.profileNames.nonCitizen && //383998
                              this.userDetails.showCitizenDashboard === "true")) &&
                          !this.programRemoved
                        ) {
                          this.acknowledgeMemberAddition();
                        }
                      }
                    }
                  }
                }// Bug 389924
              })
              .catch((error) => {
                this.showSpinner = false;
                console.error("Error in handleSave", error);
              });
          } else {
            this.showSpinner = false;
            this.toastMessage = toastErrorText;
            this.showErrorToast = true;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
              this.showErrorToast = false;
            }, 5000);
          }
        }
      } //#383043
    } catch (error) {
      this.showSpinner = false; // added now
      console.error("Error in handleNext", error);
    }
  }
  checkMedicaidRule = (upOrDown) => {
    const revRules = [];
    const isNonMagi = this.householdMembers.some((member) => (member.sRecordId !== this.memberObject.sRecordId && parseInt(member.sAge) >= 65) || member.isBlind || member.isDisabled);
    const membersIdList = this.householdMembers.map((member) => member.sRecordId);
    membersIdList.push("null");
    if (upOrDown) {
      revRules.push(["MAGI2Non_MAGI", true, ...membersIdList].join(","));
      revRules.push(["Non_MAGI2MAGI", false, ...membersIdList].join(","));
    } else if (!isNonMagi) {
      revRules.push(["Non_MAGI2MAGI", true, ...membersIdList].join(","));
      revRules.push(["MAGI2Non_MAGI", false, ...membersIdList].join(","));
    }
    this.validateReviewRequiredRules(this.appId, membersIdList[0], ["SSP_APP_HHMemberDetails"], revRules, this.mode);
    return revRules;
  };
  /**
   * @function : fetchMemberIdNotCitizenFunction
   * @description : This method is used to fetch contact information from org.
   * @param {string} value - Member Id.
   */
  fetchMemberIdNotCitizenFunction = (value) =>
    fetchMemberIdNotCitizen({
      memberId: value,
      applicationId: this.appId,
    })
      .then((result) => {
        this.nonCitizenIdList = result.mapResponse.memberIdList;
      })
      .catch((error) => {
        console.error("Error in fetchMemberIdNotCitizenFunction of Add HouseHold Member page" + JSON.stringify(error));
      });

  /**
   * @function : handleCancel
   * @description : This method is used to fire cancel event for adding member details.
   */
  handleCancel () {
    try {
      this.dispatchEvent(new CustomEvent(apConstants.events.cancelMemberAdded));
    } catch (error) {
      console.error("Error in handleCancel", error);
    }
  }
  /**
   * @function : handleSsnToggle
   * @description : This method is used to track change in ssn availability.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleSsnToggle (event) {
    try {
      this.ssnAvailable = event.detail.value === apConstants.toggleFieldValue.yes ? true : false;
      this.ssnNotAvailable = !this.ssnAvailable;
      this.confirmSsnValue = this.ssnAvailable ? this.confirmSsnValue : "";
    } catch (error) {
      console.error("Error in handleSsnToggle", error);
    }
  }

  updateAge (event) {
    this.memberObject.sAge = this.getAge(event.detail.value);
    if (event.target.fieldName === "BirthDate__c") {
      this.sspRIDPMemberData["BirthDate"] = event.target.value;
    }
    if (this.appPrograms.includes("Child") && this.programListLength === false && this.memberObject.sAge < 19) {
      this.programListLength = true;
    }
  }

  /**
   * @function : handleDeathCheckbox
   * @description : This method is used to track change in death checkbox.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleDeathCheckbox (event) {
    try {
      this.deathChecked = event.target.value;
    } catch (error) {
      console.error("Error in handleDeathCheckbox", error);
    }
  }

  /**
   * @function : handleHispanicChange
   * @description : This method is used to show Ethnicity drop down.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleHispanicChange (event) {
    try {
      this.showEthnicity = event.detail.value === apConstants.toggleFieldValue.yes ? true : false;
      if (!this.showEthnicity) {
        this.memberObject.sEthnicityCode = "";
      }
    } catch (error) {
      console.error("Error in handleHispanicChange", error);
    }
  }

  /**
   * @function : handleRaceSelect
   * @description : This method is used to track change in race selection.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleRaceSelect (event) {
    try {
      const itemCount = event.target.value.filter((item) => item === "AS" || item === "HPI");
      const MapOfAsia = this.mapforasnatinality;
      const nativeMap = this.mapforhpinatinality;
      const finalRaceMap = [];
      if (itemCount.includes("HPI") && itemCount.includes("AS")) {
        this.nationalityCodes = this.defaultNationalities;
      } else if (itemCount == "AS") {
        Object.keys(MapOfAsia).map((key) => {
          const nation = {};
          nation.label = MapOfAsia[key];
          nation.value = key;
          finalRaceMap.push(nation);
        });
        this.nationalityCodes = finalRaceMap;
      } else if (itemCount == "HPI") {
        Object.keys(nativeMap).map((key) => {
          const nation = {};
          nation.label = nativeMap[key];
          nation.value = key;
          finalRaceMap.push(nation);
        });
        this.nationalityCodes = finalRaceMap;
      }
      this.showRaceDropDown = itemCount.length > 0 ? true : false;
      if (!this.showRaceDropDown) {
        this.memberObject.sNationalityCode = "";
      }
    } catch (error) {
      console.error("Error in handleRaceSelect", error);
    }
  }

  /**
   * @function : handleContinueAnyway
   * @description : This method is used to close the verification modal.
   */
  handleContinueAnyway () {
    try {
      this.showVerificationFailedModal = false;
    } catch (error) {
      console.error("Error in handleRaceSelect", error);
    }
  }

  /**
   * This method is used to show the verification modal.
   */
  handleCheckMyEntries () {
    try {
      this.showVerificationFailedModal = false;
    } catch (error) {
      console.error("Error in handleCheckMyEntries", error);
    }
  }
  /**
   * This method is used to track change in list of program selection.
   */
  handleCheckboxChange (event) {
    try {
      if (event.target.value) {
        event.target.value = event.target.label;
      } else {
        event.target.value = false;
      }
    } catch (error) {
      console.error("Error in handleCheckMyEntries", error);
    }
  }
  /**
   * This method is used to track change in value of middle initial checkbox.
  */
  handleNoMiddleInitial (event) {
    try {
      this.middleInitialFlag = event.target.value;
      const element = this.template.querySelector(".ssp-middle-initial");
      if (this.middleInitialFlag) {
        element.classList.remove("applicationInputs");
        element.disabled = true;
        element.value = null;
        element.ErrorMessageList = [];
        // Added the below condition to bypass the MiddleInitial field Validations.
        this.byPassValidations("MiddleInitial__c,SSP_Member__c", false);
      } else {
        //element.classList.add("applicationInputs");
        element.disabled = false;
        // Added the below condition to bypass the MiddleInitial field Validations.
        this.byPassValidations("MiddleInitial__c,SSP_Member__c", true);
        element.classList.add("applicationInputs");
      }
      //element.ErrorMessageList = [];
    } catch (error) {
      console.error("Error in handleNoMiddleInitial", error);
    }
  }

  /**
   * This method is used to get the updated value of ssn.
   */
  handleSsnChange (event) {
    try {
      this.ssnValue = event.detail.value;
      if (this.confirmSsnValue && this.confirmSsnValue === this.ssnValue) {
        this.template.querySelector(".ssp-confirm-ssn").ErrorMessageList = [];
      } else if (this.confirmSsnValue && this.confirmSsnValue !== this.ssnValue) {
        this.template.querySelector(".ssp-confirm-ssn").ErrorMessageList = [ssnNotMatch];
      }
    } catch (error) {
      console.error("Error in handleSsnChange", error);
    }
  }
  /**
   * This method is used to verify the  ssn.
   */
  verifySsn (event) {
    try {
      const line1 = this.template.querySelector(".ssp-confirm-ssn");
      this.confirmSsnValue = event.detail.value;
      if (this.confirmSsnValue !== this.ssnValue) {
        line1.ErrorMessageList = [ssnNotMatch];
      } else {
        line1.ErrorMessageList = [];
      }
    } catch (error) {
      console.error("Error in verifySsn", error);
    }
  }
  /**
   * This method is used to get notified when toast hides.
   */
  handleHideToast () {
    try {
      this.showErrorToast = false;
    } catch (error) {
      console.error("Error in handleHideToast", error);
    }
  }
  /**
   * This method is used close the modal opened.
   */
  closeModal () {
    try {
      if (this.showPreVerificationModal) {
        this.SSNRetryFlag = false;
      }
      if (this.showMatchFoundModal) {
        this.dispatchEvent(
          new CustomEvent(apConstants.events.memberAdded, {
            detail: this.memberIndividualId,
          })
        );
      }
      this.showCannotApplyModal = false;
      this.showPreVerificationModal = false;
      this.showMatchFoundModal = false;
    } catch (error) {
      console.error("Error in closeModal", error);
    }
  }
  /**
   * Method to close error modal.
   */
  closeError = () => {
    try {
      this.showErrorModal = false;
      this.showSpinner = false;
    } catch (error) {
      console.error("Error in closeError:" + JSON.stringify(error.message));
    }
  };

  /**
   * @function : disconnectedCallback
   * @description : This method is used to scroll to the top.
   */
  disconnectedCallback () {
    try {
      document.title = this.summaryTitle;
      document.body.scrollTop = 0;
      document.documentElement.scrollTop = 0;
    } catch (error) {
      console.error("Error in disconnectedCallback", error);
    }
  }

  /**
   * @function : checkEntry
   * @description : This method is used to show error for check my entries.
   */
  checkEntry () {
    try {
      this.showPreVerificationModal = false;
      this.toastMessage = checkMyEntriesToast;
      this.objValue = "";
      this.showErrorToast = true;
      let element;
      if (this.memberObject && !this.memberObject.bisHOH) {
        element = this.template.querySelectorAll(".ssp-check-entries");
      } else {
        element = this.template.querySelectorAll(".ssp-check-entries-hoh");
      }
      if (element.length > 0) {
        element.forEach((item) => {
          item.ErrorMessageList = [nameSsnNotMatch];
        });
      }
    } catch (error) {
      console.error("Error in checkEntry", error);
    }
  }

  /**
   * @function : byPassValidations
   * @description : This method is used to by pass the Validation.
   * @param {string} fieldObject -Accepts the field and object as parameter.
   * @param {string} isToActive - To set Input Required flag to true/false.
   */
  byPassValidations = (fieldObject, isToActive) => {
    if (
      this.MetaDataListParent !== undefined &&
      Object.keys(this.MetaDataListParent).length > 0 &&
      this.MetaDataListParent[fieldObject] !== undefined &&
      this.MetaDataListParent[fieldObject][constants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c] !== undefined
    ) {
      this.MetaDataListParent[fieldObject][constants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c] = isToActive;
    }
  };

  //CD2 RIDP
  /**
   * @function : handleVerificationMethodChange
   * @description : This method is used to get the updated value of RIDP verification method.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleVerificationMethodChange = (event) => {
    this.sspRIDPMemberData["IdentityVerificationMethod"] = event.detail.value;
    if (event.detail.value === apConstants.applicantIdentity.newRIDP) {
      this.methodRIDP = apConstants.applicantIdentity.newRIDP;
      this.isResumeRIDP = false;
      this.isNewRIDP = true;
    } else if (event.detail.value === apConstants.applicantIdentity.resumeRIDP) {
      this.methodRIDP = apConstants.applicantIdentity.resumeRIDP;
      this.isResumeRIDP = true;
    }
  };
  handleLastName = (event) => {
    try {
      if (event.target.fieldName === "LastName__c") {
        this.sspRIDPMemberData["LegalLastName"] = event.target.value;
      }
    } catch (error) {
      console.error("Error in handleLastName => ", error);
    }
  };
  handleGender = (event) => {
    if (event.target.fieldName === "GenderCode__c") {
      this.sspRIDPMemberData["Gender"] = event.target.value;
    }
  };
  handleReferenceNumber = (event) => {
    try {
      if (event.target.name === "referenceNumber") { //Defect - 387064
        this.referenceNumber = event.target.value; //Defect - 387064
        this.sspRIDPMemberData["ReferenceNumber"] = event.target.value;
      }
    } catch (error) {
      console.error("Error in handleReferenceNumber =>", error);
    }
  };
  getMemberDataHandler (callHandleSave) {
    this.sspRIDPMemberData=null;
    getMemberData({ memberId: this.recordId })
      .then((result) => {
        if (result.bIsSuccess) {
          this.sspRIDPMemberData = result.mapResponse;
          if (this.userDetails.userRole === "Contact_Center_View_and_Edit" && this.sspRIDPMemberData.IdentityVerificationMethod !== undefined && this.sspRIDPMemberData.IdentityVerificationMethod !== null) {
            if (this.sspRIDPMemberData.IdentityVerificationMethod === apConstants.applicantIdentity.resumeRIDP) {
              this.methodRIDP = this.sspRIDPMemberData.IdentityVerificationMethod;
              this.isResumeRIDP = true;
              this.isNewRIDP = false;
              if (this.isResumeRIDP && this.sspRIDPMemberData.NonCitizenVerificationFlag && callHandleSave) {
                this.handleSave();
              }
            }
            if (this.sspRIDPMemberData.ReferenceNumber) {
              this.referenceNumber = this.sspRIDPMemberData.ReferenceNumber;
            }
          }
        }
      })
      .catch((error) => {
        console.error("the error occured at SspAddHouseHoldMember=>getMemberData" + JSON.stringify(error));
      });
  }
  resumeRIDPHandler = () => {
    resumeRIDP({
      mp: this.sspRIDPMemberData,
    })
      .then((result) => {
        if (result.bIsSuccess) {
          this.resumeRIDPResult = result.mapResponse;

          this.updateApplicationStatusUnsubmittedHandler();
        } else {
          if (result.mapResponse.hasOwnProperty("ReferenceNumber")) {
            if (this.resumeRIDPResult.ReferenceNumber !== undefined) {
              this.modalContentTwo = this.label.sspModalContentTwo;
            }
          }
          this.showSpinner = false;
          this.isVerification = true;
        }
      })
      .catch((error) => {
        this.showSpinner = false;
        console.error("Error in resume RIDP", JSON.stringify(error));
        this.isVerification = true;
      });
  };
  navigateToIdentityDocumentUpload () {
    if (this.uploadDocFlag && !this.sspRIDPMemberData.NonCitizenVerificationFlag) {
      this.showSpinner = true;
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "SSP_APP_IDDocumentUpload__c",
        },
        state: {
          memberId: this.recordId,
          applicationId: this.appId,
          mode: this.mode,
        },
      });
    }
  }
  /**
   * @function : acknowledgeMemberAddition
   * @description : This method is used acknowledge on update/addition of member information.
   */
  acknowledgeMemberAddition = () => {
    this.dispatchEvent(
      new CustomEvent(apConstants.events.memberAdded, {
        detail: this.memberIndividualId,
      })
    );
  };
  triggerReviewRequiredOnNewMember = (saveWrapper) => {
    let revRules;
    if (saveWrapper && (saveWrapper.sRecordId === undefined || saveWrapper.sRecordId === null || saveWrapper.sRecordId === "")) {
      revRules = "reviewTMemberChange," + true + ",null";
    }
    return revRules;
  };

  /**
   * @function : updateApplicationStatusUnsubmittedHandler.
   * @description	: Method to update application status as unsubmitted.
   */
  updateApplicationStatusUnsubmittedHandler () {
    updateApplicationStatusUnsubmitted({
      applicationId: this.appId,
      memberId: this.recordId,
      sPage: "AddHouseHoldMemberPage" //Defect - 387064
    })
      .then((result) => {
        if (result.bIsSuccess) {
          this.getMemberDataHandler(true);
        } else {
          console.error("updateApplicationStatusUnsubmitted Failed" + JSON.stringify(result));
        }
      })
      .catch((error) => {
        console.error("updateApplicationStatusUnsubmitted Failed" + JSON.stringify(error));
      });
  }
  /**
   * @function : getQueryParameters
   * @description : This method is used get the URL parameters.
   */
  getQueryParameters () {
    let params = {};
    const search = location.search.substring(1);
    if (search) {
      params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => (key === "" ? value : decodeURIComponent(value)));
    }
    return params;
  }
  /**
   * @function : navigateToNextPageUpdate
   * @description	: Method Navigate user to Next page update.
   * @param {*} navigateToRepsHome -  This parameter provides the updated value.
   * @param {*} isPartialMatch -  This parameter provides the updated value.
   * @param {*} isAccessAvailable -  This parameter provides the updated value.
   */
  navigateToNextPageUpdate = (navigateToRepsHome, isPartialMatch, isAccessAvailable) => {
    if (navigateToRepsHome) {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "assister_access_request__c",
        },
        state: {
          applicationId: this.parameters.applicationId,
          individualId: this.individualId,
          household: "true",
        },
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "reps_asisters_agents_next_steps__c",
        },
        state: {
          applicationId: this.parameters.applicationId,
          noCaseMatch: isAccessAvailable,
          authRequestPartialMatch: isPartialMatch,
        },
      });
    }
  };
  /**
   * @function : closeAdditionalVerification
   * @description : This method is used close the verification modal.
   */
  closeAdditionalVerification = () => {
    try {
      this.isVerification = false;
    } catch (error) {
      console.error("Error in closing Additional Verification modal");
    }
  };
}
