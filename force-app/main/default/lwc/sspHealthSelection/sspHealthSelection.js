/**
 * Component Name - sspHealthSelection.js.
 * Author         - Chaitanya Kanakia, Ashwin Kasture.
 * Description    - Used to display the questions and applicable members for each question.
 *                  This screen takes the input for Health selection gatepost questions.
 * Date       	  - 11/12/2019.
 */
import { api, track } from "lwc";
import sspHealthSelectionDescLabel from "@salesforce/label/c.SSP_HealthSelectionDesc";
import sspLearnMoreLinkLabel from "@salesforce/label/c.SSP_LearnMoreLink";
import sspHealthSelectionNoteLabel from "@salesforce/label/c.SSP_HealthSelectionNote";
import sspHealthSelectionMedicalLabel from "@salesforce/label/c.SSP_HealthSelectionMedical";
import sspHealthSelectionMedicalHelpContent from "@salesforce/label/c.SSP_HealthSelectionMedicalHelpContent";
import sspHealthSelectionBlindLabel from "@salesforce/label/c.SSP_HealthSelectionBlind";
import sspHealthSelectionDisabilityLabel from "@salesforce/label/c.SSP_HealthSelectionDisability";
import sspHealthSelectionDisabilityHelpContent from "@salesforce/label/c.SSP_HealthSelectionDisabilityHelpContent";
import sspHealthSelectionRecoveringLabel from "@salesforce/label/c.SSP_HealthSelectionRecovering";
import sspHealthSelectionPregnantLabel from "@salesforce/label/c.SSP_HealthSelectionPregnant";
import sspHealthSelectionSettlementLabel from "@salesforce/label/c.SSP_HealthSelectionSettlement";
import sspHealthSelectionMedicareBenefitsLabel from "@salesforce/label/c.SSP_HealthSelectionMedicareBenefits";
import sspHealthSelectionMedicareBenefitsHelpContent from "@salesforce/label/c.SSP_HealthSelectionMedicareBenefitsHelpContent";
import sspHealthSelectionSelectApplicantLabel from "@salesforce/label/c.SSP_HealthSelectionSelectApplicant";
import sspHealthSelectionLearnMoreAlt from "@salesforce/label/c.SSP_HealthSelectionLearnMoreAlt";
import sspHealthSelectionLabel from "@salesforce/label/c.SSP_HealthSelectionLabel";
import sspHealthSelectionLearnMoreContent from "@salesforce/label/c.SSP_HealthSelectionLearnMoreContent";
import sspHealthSelectionCISLabel from "@salesforce/label/c.SSP_HealthSelectionCISLabel";
import sspHealthSelectionCaretakerServicesLabel from "@salesforce/label/c.SSP_HealthSelectionCaretakerServices";
import medicareCoverageLabel from "@salesforce/label/c.SSP_MedicareCoverageLabel";

import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import sspHealthSelectionErrorMsg from "@salesforce/label/c.SSP_HealthSelectionErrorMsg";
import programConstant from "c/sspConstants";
import getHealthSelectionData from "@salesforce/apex/SSP_HealthSelectionCtrl.getHealthSelectionData";
import storeHealthSelectionData from "@salesforce/apex/SSP_HealthSelectionCtrl.storeHealthSelectionData";
import hasPermission from "@salesforce/apex/SSP_Utility.hasPermission";
import getCISData from "@salesforce/apex/SSP_NonCitizenRAC.getCISData";
import sspBaseNavFlowPage from "c/sspBaseNavFlowPage";
import blindness from "@salesforce/label/c.SSP_blindness";
import disability from "@salesforce/label/c.SSP_Disability";
import utility, { getYesNoOptions, formatLabels } from "c/sspUtility";
const yesValue = getYesNoOptions ()[0].value;
const noValue = getYesNoOptions ()[1].value;
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class sspHealthSelection extends sspBaseNavFlowPage {
  /**
   * @function 	: mode.
   * @description : This attribute is part of mode to determine the current Flow.
   * */
  @api
  get mode () {
    return this.modeVal;
  }
  set mode (value) {
    if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
      this.modeVal = value;
    }
  }

  /**
   * @function 	: nextEvent.
   * @description : This attribute is part of validation framework which is used to navigate to next Screen.
   * */
  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    try {
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.nextValue = value;
        this.saveData (); // use to check validations on component
        this.reviewRequiredLogic ();
      }
    } catch (error) {
      console.error("Error in nextEvent of Health Selection Page" + error);
    }
  }

  /**
   * @function 	: allowSaveData.
   * @description : This attribute is part of validation framework which indicates data is valid or not.
   * */
  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    this.validationFlag = value;
    if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
      this.storeHealthSelectionData ();
    }
  }

  /**
   * @function 	: MetadataList.
   * @description : This function is part of validation framework which is used to get the metaData values.
   * */
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  set MetadataList (value) {
    this.MetaDataListParent = value;
  }

  /**
   * @function 	: appId.
   * @description : This attribute is part of validation framework which gives the application ID.
   * */
  @api
  get appId () {
    return this.applicationId;
  }
  set appId (value) {
    this.applicationId = value;
    this.fetchHealthSelectionData();
  }

  @track applicationId;
  @track MetaDataListParent;
  @track validationFlag;
  @track objHealthSelectionInfo = {};
  @track objApplication = {};

  @track hasEmergencyMedicalErrorMsg;
  @track isBlindErrorMsg;
  @track isDisabledErrorMsg;
  @track sRecoveryFromIllnessOrInjuryErrorMsg;
  @track sIsPregnantInLastThreeMonthErrorMsg;
  @track hasPendingAccidentSettlementErrorMsg;
  @track sIsReceivingMedicareBenefitErrorMsg;
  @track isRequestingOrReceivingCISErrorMsg = "";
  @track isReceivingCaretakerServicesErrorMsg = "";

  @track sHasEmergencyMedicalValue = "";
  @track sIsDisabledValue = "";
  @track sIsDisabilityDisabled = false;
  @track sIsBlindValue = "";
  @track sIsBlindnessDisabled = false;
  @track sIsEMCDisabled = false;
  @track sIsRecoveryFromIllnessOrInjuryValue = "";
  @track sHasPendingAccidentSettlementValue = "";
  @track sIsReceivingMedicareBenefitValue = "";
  @track sIsMedicareDisabled = false;
  @track sIsPregnantInLastThreeMonthsValue = "";
  @track sIsRequestingOrReceivingCIS = ""; //CS
  @track sIsReceivingCaretakerServices = ""; //CS

  @track hasEmergencyMedicalMemberList = [];
  @track hasPendingAccidentSettlementList = [];
  @track isBlindList = [];
  @track isDisabledList = [];
  @track isPregnantInLastThreeMonthsList = [];
  @track isReceivingMedicareBenefitList = [];
  @track isRecoveryFromIllnessOrInjuryList = [];
  @track isRequestingOrReceivingCISList = []; //CS
  @track isReceivingCaretakerServicesList = []; //CS

  @track hasEmergencyMedicalMemberIds = [];
  @track hasPendingAccidentSettlementMemberIds = [];
  @track isBlindMemberIds = [];
  @track IsDisabledListMemberIds = [];
  @track isPregnantInLastThreeMonthsMemberIds = [];
  @track isReceivingMedicareBenefitMemberIds = [];
  @track isRecoveryFromIllnessOrInjuryMemberIds = [];
  @track isRequestingOrReceivingCISListIds = []; //CS
  @track isReceivingCaretakerServicesListIds = []; //CS

  @track isToShowEmergencyMedical = false;
  @track isToShowPendingAccidentSettlement = false;
  @track isToShowBlind = false;
  @track isToShowDisabled = false;
  @track isToShowPregnantInLastThreeMonths = false;
  @track isToShowReceivingMedicareBenefit = false;
  @track isToShowRecoveryFromIllnessOrInjury = false;
  @track showSpinner = false;
  @track isLearnMoreModal = false;
  @track optList = getYesNoOptions ();
  @track modeValue = false;
  @track reference = this;
  @track isToShowRequestOrReceiveCIS = false; //CS
  @track isToShowReceivingCaretakerServices = false; //CS
  @track visibility = false; //CS
  @track memberList;
  @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
  @track programList;
  @track medicaidType;
  @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track questionsMap = {}; //#385049
  label = {
    sspHealthSelectionDescLabel,
    sspLearnMoreLinkLabel,
    sspHealthSelectionNoteLabel,
    sspHealthSelectionMedicalLabel,
    sspHealthSelectionBlindLabel,
    sspHealthSelectionDisabilityLabel,
    sspHealthSelectionRecoveringLabel,
    sspHealthSelectionPregnantLabel,
    sspHealthSelectionSettlementLabel,
    sspHealthSelectionMedicareBenefitsLabel,
    sspHealthSelectionSelectApplicantLabel,
    sspHealthSelectionLearnMoreAlt,
    sspHealthSelectionLabel,
    sspHealthSelectionLearnMoreContent,
    sspHealthSelectionMedicalHelpContent,
    sspHealthSelectionDisabilityHelpContent,
    sspHealthSelectionMedicareBenefitsHelpContent,
    sspHealthSelectionCISLabel,
    sspHealthSelectionCaretakerServicesLabel,
    sspPageInformationVerified,
    startBenefitsAppCallNumber
  };

  hasRendered = false;
  healthInformationWrapperList = [];
  allMemberIdCheckChanged = [];
  sHasEmergencyMedicalMemberId = [];
  sIsDisabledMemberId = [];
  sIsBlindMemberId = [];
  sIsRecoveryFromIllnessOrInjuryMemberId = [];
  sHasPendingAccidentSettlementMemberId = [];
  sIsReceivingMedicareBenefitMemberId = [];
  sIsPregnantInLastThreeMonthsMemberId = [];
  modeVal = "";
  isRequestingOrReceivingCISListId = []; //CS
  isReceivingCaretakerServicesListId = []; //CS
  hasPermission = false;
  isLoadedPendingAccidentSettlement = false; // Added as part of Defect
  isLoadedReceivingMedicareBenefit = false; // Added as part of Defect

  callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
  /**
   * @function - connectedCallback.
   * @description - This method creates the field and object list to get metadata details
   *                from Entity Mapping as per screen name.
   */
  connectedCallback () {
    try {
      this.showSpinner = true;
      const fieldEntityNameList = [];
      fieldEntityNameList.push(
        "HasEmergencyMedicalConditionToggle__c,SSP_Member__c",
        "IsDisabledToggle__c,SSP_Member__c",
        "IsBlindToggle__c,SSP_Member__c",
        "IsRecoveryFromIllnessOrInjuryToggle__c,SSP_Member__c",
        "HasPendingAccidentSettlementToggle__c,SSP_Application__c",
        "IsPregnantInLastThreeMonthsToggle__c,SSP_Member__c",
        "IsReceivingMedicareBenefitToggle__c,SSP_Member__c",
        "IsReceivingCaretakerServicesToggle__c,SSP_Member__c",
        "IsRequestingOrReceivingCISToggle__c,SSP_Member__c"
      );
      this.getMetadataDetails(
        fieldEntityNameList,
        null,
        "SSP_APP_Select_Health"
      );
      this.getCISData ();
      if (location.href.includes("mode=RAC")) {
        this.modeValue = true;
      }
    } catch (error) {
      console.error(
        "Error occurred in connectedCallback of health selection page" +
          JSON.stringify(error)
      );
    }
  }

  /**
   * @function : hideToast
   * @description	: Method to hide Toast.
   */
  hideToast = () => {
    try {
      this.hasSaveValidationError = false;
    } catch (error) {
      console.error(
        "Error in hideToast on sspEnrollmentDetails screen" +
          JSON.stringify(error)
      );
    }
  };
  getCISData = () => {
    try {
      getCISData({
        sApplicationId: this.applicationId,
        sMode: this.mode,
      })
        .then((result) => {
          if (result.bIsSuccess) {
            this.visibility = result.mapResponse.CIS_CareTaker;
          } else if (!result.bIsSuccess) {
            console.error(
              "Error occurred in fetchHealthSelectionData of health selection page" +
                result.mapResponse.ERROR
            );
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in fetchHealthSelectionData of health selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - fetchHealthSelectionData().
   * @description - This method is used to get health selection data for members of application.
   */
  fetchHealthSelectionData = () => {
    try {
      getHealthSelectionData({
        sApplicationId: this.applicationId,
        sMode: this.mode,
      })
        .then((result) => {
          if (result.bIsSuccess) {
            //CD2 2.5 Security Role Matrix and Program Access.
            this.isReadOnlyUser = (result.mapResponse.screenPermission != null && result.mapResponse.screenPermission != undefined && result.mapResponse.screenPermission == programConstant.permission.readOnly);
            this.isScreenAccessible = (result.mapResponse.screenPermission != null && result.mapResponse.screenPermission != undefined && result.mapResponse.screenPermission == programConstant.permission.notAccessible) ? false : true;
            this.showAccessDeniedComponent = !this.isScreenAccessible;
            /** */

            this.questionsMap = !utility.isUndefinedOrNull(result.mapResponse.questionsMap) ? result.mapResponse.questionsMap : {}; //#385049
            this.objHealthSelectionInfo =
              result.mapResponse.healthInformationData;
            let progList;
            if (this.objHealthSelectionInfo.length > 0) {
              progList = this.objHealthSelectionInfo[0].sProgramsApplied.split(
                ";"
              );
              this.programList = progList;
              this.medicaidType = this.objHealthSelectionInfo[0].sMedicaidType;
            }
            this.memberList = result.mapResponse.healthInformationData;

            this.setQuestionValue(this.memberList);
            this.setQuestionMembers(this.memberList);
            this.showSpinner = false;
          } else if (!result.bIsSuccess) {
            console.error(
              "Error occurred in fetchHealthSelectionData of health selection page" +
                result.mapResponse.ERROR
            );
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in fetchHealthSelectionData of health selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - fetchHasPermissionData().
   * @description - This method is used to get State Supplementation data  for members of application.
   */
  fetchHasPermissionData = () => {
    try {
      hasPermission({
        customPermissionName: programConstant.programValues.SS,
      })
        .then((result) => {
          if (result) {
            this.hasPermission = result;
            this.showSpinner = false;
          } else if (!result) {
            console.error(
              "Error occurred in fetchHealthSelectionData of health selection page" +
                result.mapResponse.ERROR
            );
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in fetchHasPermissionData of health selection page" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function - setQuestionValue().
   * @description - This method is used to assign the values for each health selection question.
   * @param {object[]} memberList - This is list of members.
   */
  setQuestionValue = (memberList) => {
    try {
      memberList.forEach((element) => {
        if (
          element.sHasEmergencyMedicalCondition !== undefined &&
          element.sHasEmergencyMedicalCondition === yesValue
        ) {
          this.sHasEmergencyMedicalValue = yesValue;
        } else if (
          element.sHasEmergencyMedicalCondition !== undefined &&
          element.sHasEmergencyMedicalCondition === noValue &&
          this.sHasEmergencyMedicalValue !== yesValue
        ) {
          this.sHasEmergencyMedicalValue = noValue;
        }

        if (
          element.sIsDisabled !== undefined &&
          element.sIsDisabled === yesValue
        ) {
          this.sIsDisabledValue = yesValue;
        } else if (
          element.sIsDisabled !== undefined &&
          element.sIsDisabled === noValue &&
          this.sIsDisabledValue !== yesValue
        ) {
          this.sIsDisabledValue = noValue;
        }

        if (element.sIsBlind !== undefined && element.sIsBlind === yesValue) {
          this.sIsBlindValue = yesValue;
        } else if (
          element.sIsBlind !== undefined &&
          element.sIsBlind === noValue &&
          this.sIsBlindValue !== yesValue
        ) {
          this.sIsBlindValue = noValue;
        }

        if (
          element.sIsRecoveryFromIllnessOrInjury !== undefined &&
          element.sIsRecoveryFromIllnessOrInjury === yesValue
        ) {
          this.sIsRecoveryFromIllnessOrInjuryValue = yesValue;
        } else if (
          element.sIsRecoveryFromIllnessOrInjury !== undefined &&
          element.sIsRecoveryFromIllnessOrInjury === noValue &&
          this.sIsRecoveryFromIllnessOrInjuryValue !== yesValue
        ) {
          this.sIsRecoveryFromIllnessOrInjuryValue = noValue;
        }

        if (
          element.sHasPendingAccidentSettlement !== undefined &&
          element.sHasPendingAccidentSettlement === yesValue
        ) {
          this.sHasPendingAccidentSettlementValue = yesValue;
        } else if (
          element.sHasPendingAccidentSettlement !== undefined &&
          element.sHasPendingAccidentSettlement === noValue &&
          this.sHasPendingAccidentSettlementValue !== yesValue
        ) {
          this.sHasPendingAccidentSettlementValue = noValue;
        }

        if (
          element.sIsReceivingMedicareBenefit !== undefined &&
          element.sIsReceivingMedicareBenefit === yesValue
        ) {
          this.sIsReceivingMedicareBenefitValue = yesValue;
        } else if (
          element.sIsReceivingMedicareBenefit !== undefined &&
          element.sIsReceivingMedicareBenefit === noValue &&
          this.sIsReceivingMedicareBenefitValue !== yesValue
        ) {
          this.sIsReceivingMedicareBenefitValue = noValue;
        }

        if (
          element.sIsPregnantInLastThreeMonths !== undefined &&
          element.sIsPregnantInLastThreeMonths === yesValue
        ) {
          this.sIsPregnantInLastThreeMonthsValue = yesValue;
        } else if (
          element.sIsPregnantInLastThreeMonths !== undefined &&
          element.sIsPregnantInLastThreeMonths === noValue &&
          this.sIsPregnantInLastThreeMonthsValue !== yesValue
        ) {
          this.sIsPregnantInLastThreeMonthsValue = noValue;
        }
        if (
          element.sIsRequestingOrReceivingCIS !== undefined &&
          element.sIsRequestingOrReceivingCIS === yesValue
        ) {
          this.sIsRequestingOrReceivingCIS = yesValue;
        } else if (
          element.sIsRequestingOrReceivingCIS !== undefined &&
          element.sIsRequestingOrReceivingCIS === noValue &&
          this.sIsRequestingOrReceivingCIS !== yesValue
        ) {
          this.sIsRequestingOrReceivingCIS = noValue;
        }
        if (
          element.sIsReceivingCaretakerServices !== undefined &&
          element.sIsReceivingCaretakerServices === yesValue
        ) {
          this.sIsReceivingCaretakerServices = yesValue;
        } else if (
          element.sIsReceivingCaretakerServices !== undefined &&
          element.sIsReceivingCaretakerServices === noValue &&
          this.sIsReceivingCaretakerServices !== yesValue
        ) {
          this.sIsReceivingCaretakerServices = noValue;
        }

        if (
          (element.isDisabilityVerified !== undefined &&
            element.isDisabilityVerified) || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
        ) {
          this.sIsDisabilityDisabled = true;
        } else if (
          element.isDisabilityVerified !== undefined &&
          !element.isDisabilityVerified &&
          !this.sIsDisabilityDisabled
        ) {
          this.sIsDisabilityDisabled = false;
        }
        if (
          (element.isOngoingEmergencyMedicalCondition !== undefined &&
            element.isOngoingEmergencyMedicalCondition) || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
        ) {
          this.sIsEMCDisabled = true;
        } else if (
          element.isOngoingEmergencyMedicalCondition !== undefined &&
          !element.isDisabilityVerified &&
          !this.sIsEMCDisabled
        ) {
          this.sIsEMCDisabled = false;
        }

        if (
          (element.isBlindnessVerified !== undefined &&
            element.isBlindnessVerified) || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
        ) {
          this.sIsBlindnessDisabled = true;
        } else if (
          element.isBlindnessVerified !== undefined &&
          !element.isBlindnessVerified &&
          !this.sIsBlindnessDisabled
        ) {
          this.sIsBlindnessDisabled = false;
        }
        if (
          (element.isMedicareVerified !== undefined &&
            element.isMedicareVerified) || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
        ) {
          this.sIsMedicareDisabled = true;
        } else if (
          element.isMedicareVerified !== undefined &&
          !element.isMedicareVerified &&
          !this.sIsMedicareDisabled
        ) {
          this.sIsMedicareDisabled = false;
        }
      });
    } catch (error) {
      console.error(
        "Error occurred in setQuestionValue on Health Selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - setQuestionMembers.
   * @description - This method is used to create applicable members list for each question depending on conditions.
   * @param {object[]} memberList - This is list of member.
   */
  setQuestionMembers = (memberList) => {
    try {
      memberList.forEach((element) => {
        let listPrograms = [];
        if (
          element.sProgramsApplied !== undefined &&
          element.sProgramsApplied !== ""
        ) {
          listPrograms = element.sProgramsApplied.split(";");
        }

        if (
          (element.sMedicaidType === programConstant.medicaidTypes.MAGI ||
            element.sMedicaidType === programConstant.medicaidTypes.NonMAGI ||
            listPrograms.indexOf(programConstant.programValues.MA) !== -1) &&
          element.sIsUSCitizen === noValue
        ) {
          this.hasEmergencyMedicalMemberList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sHasEmergencyMedicalCondition === yesValue ? true : false,
            disabled: element.isOngoingEmergencyMedicalCondition || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowEmergencyMedical = true;

          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sHasEmergencyMedicalCondition",
            "sMemberId",
            element.sMemberId,
            element.sHasEmergencyMedicalCondition
          );
        }

        if (
          listPrograms.includes(programConstant.programValues.SS) ||
          (listPrograms.includes(programConstant.programValues.MA) &&
            element.sMedicaidType === programConstant.medicaidTypes.NonMAGI) ||
            this.sIsBlindValue === yesValue || this.sIsDisabledValue === yesValue
        ) {
          this.hasPendingAccidentSettlementList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sHasPendingAccidentSettlement === yesValue ? true : false,
            disabled: this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowPendingAccidentSettlement = true;
          this.isLoadedPendingAccidentSettlement = true; // Added as part of Defect
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sHasPendingAccidentSettlement",
            "sMemberId",
            element.sMemberId,
            element.sHasPendingAccidentSettlement
          );
        }

        if (
          listPrograms.indexOf(programConstant.programValues.SS) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.SN) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.KT) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.CC) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.MA) !== -1 ||
          element.sMedicaidType === programConstant.medicaidTypes.MAGI ||
          element.sMedicaidType === programConstant.medicaidTypes.NonMAGI
        ) {
          this.isBlindList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked: element.sIsBlind === yesValue ? true : false,
            disabled: element.isBlindnessVerified || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowBlind = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsBlind",
            "sMemberId",
            element.sMemberId,
            element.sIsBlind
          );
        }

        if (
          listPrograms.indexOf(programConstant.programValues.SS) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.SN) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.KT) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.CC) !== -1 ||
          listPrograms.indexOf(programConstant.programValues.MA) !== -1 ||
          element.sMedicaidType === programConstant.medicaidTypes.MAGI ||
          element.sMedicaidType === programConstant.medicaidTypes.NonMAGI
        ) {
          this.isDisabledList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked: element.sIsDisabled === yesValue ? true : false,
            disabled: element.isDisabilityVerified || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowDisabled = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsDisabled",
            "sMemberId",
            element.sMemberId,
            element.sIsDisabled
          );
        }

        if (
          element.sGenderCode === programConstant.femaleGenderCode &&
          element.iMemberAge >= programConstant.pregnancyAge &&
          (listPrograms.indexOf(programConstant.programValues.SN) !== -1 ||
            listPrograms.indexOf(programConstant.programValues.KT) !== -1 ||
            listPrograms.indexOf(programConstant.programValues.SS) !== -1 ||
            listPrograms.indexOf(programConstant.programValues.MA) !== -1 ||
            element.sMedicaidType === programConstant.medicaidTypes.MAGI ||
            element.sMedicaidType === programConstant.medicaidTypes.NonMAGI)
        ) {
          this.isPregnantInLastThreeMonthsList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sIsPregnantInLastThreeMonths === yesValue ? true : false,
            disabled: this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowPregnantInLastThreeMonths = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsPregnantInLastThreeMonths",
            "sMemberId",
            element.sMemberId,
            element.sIsPregnantInLastThreeMonths
          );
        }

        if (
          listPrograms.includes(programConstant.programValues.SS) ||
          (listPrograms.includes(programConstant.programValues.MA) &&
                element.sMedicaidType === programConstant.medicaidTypes.NonMAGI) ||
            this.sIsBlindValue === yesValue || this.sIsDisabledValue === yesValue
        ) {
          this.isReceivingMedicareBenefitList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sIsReceivingMedicareBenefit === yesValue ? true : false,
            verified: element.isMedicareVerified,
            disabled: element.isMedicareVerified || this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowReceivingMedicareBenefit = true;
          this.isLoadedReceivingMedicareBenefit = true; // Added as part of Defect
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsReceivingMedicareBenefit",
            "sMemberId",
            element.sMemberId,
            element.sIsReceivingMedicareBenefit
          );
        }

        if (
          element.iMemberAge >= 19 &&
          (listPrograms.indexOf(programConstant.programValues.SN) !== -1 ||
            listPrograms.indexOf(programConstant.programValues.KT) !== -1)
        ) {
          this.isRecoveryFromIllnessOrInjuryList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sIsRecoveryFromIllnessOrInjury === yesValue
                ? true
                : false,
            disabled: this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.                
          });
          this.isToShowRecoveryFromIllnessOrInjury = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsRecoveryFromIllnessOrInjury",
            "sMemberId",
            element.sMemberId,
            element.sIsRecoveryFromIllnessOrInjury
          );
        }
        //CIS
        if (
          element.iMemberAge >= 18 &&
          listPrograms.indexOf(programConstant.programValues.SS) !== -1 &&
          hasPermission
        ) {
          this.isRequestingOrReceivingCISList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sIsRequestingOrReceivingCIS === yesValue ? true : false,
            disabled: this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowRequestOrReceiveCIS = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsRequestingOrReceivingCIS",
            "sMemberId",
            element.sMemberId,
            element.sIsRequestingOrReceivingCIS
          );
        }
        //caretaker
        if (
          element.iMemberAge >= 18 &&
          listPrograms.indexOf(programConstant.programValues.SS) !== -1 &&
          hasPermission
        ) {
          this.isReceivingCaretakerServicesList.push({
            label: element.sMemberName,
            value: element.sMemberId,
            checked:
              element.sIsReceivingCaretakerServices === yesValue ? true : false,
            disabled: this.isReadOnlyUser //CD2 2.5 Security Role Matrix and Program Access.
          });
          this.isToShowReceivingCaretakerServices = true;
          this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
            this.healthInformationWrapperList,
            "sIsReceivingCaretakerServices",
            "sMemberId",
            element.sMemberId,
            element.sIsReceivingCaretakerServices
          );
        }
      });
    } catch (error) {
      console.error(
        "Error occurred in setQuestionMembers on Health Selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - saveData
   * @description - This method use to push the data inside the wrapper and check the checkbox clicked to show the validation messages.
   */
  saveData = () => {
    try {
      if (
        this.sHasEmergencyMedicalValue === yesValue ||
        this.sHasEmergencyMedicalValue === noValue
      ) {
        const hasEmergencyMedicalClass = this.template.querySelectorAll(
          ".ssp-hasEmergencyMedicalClass"
        );
        for (let i = 0; i < hasEmergencyMedicalClass.length; i++) {
          if (
            hasEmergencyMedicalClass[i].value === true &&
            this.sHasEmergencyMedicalValue === yesValue
          ) {
            this.hasEmergencyMedicalErrorMsg = "";
            if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
              this.template
                .querySelector(".ssp-hasEmergencyMedicalBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sHasEmergencyMedicalValue === noValue) {
            this.hasEmergencyMedicalErrorMsg = "";
            if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
              this.template
                .querySelector(".ssp-hasEmergencyMedicalBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === hasEmergencyMedicalClass.length - 1) {
            this.hasEmergencyMedicalErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
              this.template
                .querySelector(".ssp-hasEmergencyMedicalBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      if (this.sIsBlindValue === yesValue || this.sIsBlindValue === noValue) {
        const isBlindClass = this.template.querySelectorAll(
          ".ssp-isBlindClass"
        );
        for (let i = 0; i < isBlindClass.length; i++) {
          if (
            isBlindClass[i].value === true &&
            this.sIsBlindValue === yesValue
          ) {
            this.isBlindErrorMsg = "";
            if (this.template.querySelector(".ssp-isBlindBlock")) {
              this.template
                .querySelector(".ssp-isBlindBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sIsBlindValue === noValue) {
            this.isBlindErrorMsg = "";
            if (this.template.querySelector(".ssp-isBlindBlock")) {
              this.template
                .querySelector(".ssp-isBlindBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === isBlindClass.length - 1) {
            this.isBlindErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-isBlindBlock")) {
              this.template
                .querySelector(".ssp-isBlindBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      if (
        this.sIsDisabledValue === yesValue ||
        this.sIsDisabledValue === noValue
      ) {
        const isDisabledClass = this.template.querySelectorAll(
          ".ssp-isDisabledClass"
        );
        for (let i = 0; i < isDisabledClass.length; i++) {
          if (
            isDisabledClass[i].value === true &&
            this.sIsDisabledValue === yesValue
          ) {
            this.isDisabledErrorMsg = "";
            if (this.template.querySelector(".ssp-isDisabledBlock")) {
              this.template
                .querySelector(".ssp-isDisabledBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sIsDisabledValue === noValue) {
            this.isDisabledErrorMsg = "";
            if (this.template.querySelector(".ssp-isDisabledBlock")) {
              this.template
                .querySelector(".ssp-isDisabledBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === isDisabledClass.length - 1) {
            this.isDisabledErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-isDisabledBlock")) {
              this.template
                .querySelector(".ssp-isDisabledBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      if (
        this.sIsRecoveryFromIllnessOrInjuryValue === yesValue ||
        this.sIsRecoveryFromIllnessOrInjuryValue === noValue
      ) {
        const isRecoveryFromIllnessOrInjuryClass = this.template.querySelectorAll(
          ".ssp-isRecoveryFromIllnessOrInjuryClass"
        );
        for (let i = 0; i < isRecoveryFromIllnessOrInjuryClass.length; i++) {
          if (
            isRecoveryFromIllnessOrInjuryClass[i].value === true &&
            this.sIsRecoveryFromIllnessOrInjuryValue === yesValue
          ) {
            this.sRecoveryFromIllnessOrInjuryErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isRecoveryFromIllnessOrInjuryBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sIsRecoveryFromIllnessOrInjuryValue === noValue) {
            this.sRecoveryFromIllnessOrInjuryErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isRecoveryFromIllnessOrInjuryBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === isRecoveryFromIllnessOrInjuryClass.length - 1) {
            this.sRecoveryFromIllnessOrInjuryErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isRecoveryFromIllnessOrInjuryBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      if (
        this.sIsPregnantInLastThreeMonthsValue === yesValue ||
        this.sIsPregnantInLastThreeMonthsValue === noValue
      ) {
        const isPregnantInLastThreeMonthsClass = this.template.querySelectorAll(
          ".ssp-isPregnantInLastThreeMonthsClass"
        );
        for (let i = 0; i < isPregnantInLastThreeMonthsClass.length; i++) {
          if (
            isPregnantInLastThreeMonthsClass[i].value === true &&
            this.sIsPregnantInLastThreeMonthsValue === yesValue
          ) {
            this.sIsPregnantInLastThreeMonthErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isPregnantInLastThreeMonthsBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sIsPregnantInLastThreeMonthsValue === noValue) {
            this.sIsPregnantInLastThreeMonthErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isPregnantInLastThreeMonthsBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === isPregnantInLastThreeMonthsClass.length - 1) {
            this.sIsPregnantInLastThreeMonthErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isPregnantInLastThreeMonthsBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      if (
        this.sHasPendingAccidentSettlementValue === yesValue ||
        this.sHasPendingAccidentSettlementValue === noValue
      ) {
        const hasPendingAccidentSettlementClass = this.template.querySelectorAll(
          ".ssp-hasPendingAccidentSettlementClass"
        );
        for (let i = 0; i < hasPendingAccidentSettlementClass.length; i++) {
          if (
            hasPendingAccidentSettlementClass[i].value === true &&
            this.sHasPendingAccidentSettlementValue === yesValue
          ) {
            this.hasPendingAccidentSettlementErrorMsg = "";
            break;
          } else if (this.sHasPendingAccidentSettlementValue === noValue) {
            this.hasPendingAccidentSettlementErrorMsg = "";
          } else if (i === hasPendingAccidentSettlementClass.length - 1) {
            this.hasPendingAccidentSettlementErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
      }
      if (
        this.sIsReceivingMedicareBenefitValue === yesValue ||
        this.sIsReceivingMedicareBenefitValue === noValue
      ) {
        const isReceivingMedicareBenefitClass = this.template.querySelectorAll(
          ".ssp-isReceivingMedicareBenefitClass"
        );
        for (let i = 0; i < isReceivingMedicareBenefitClass.length; i++) {
          if (
            isReceivingMedicareBenefitClass[i].value === true &&
            this.sIsReceivingMedicareBenefitValue === yesValue
          ) {
            this.sIsReceivingMedicareBenefitErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isReceivingMedicareBenefitBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isReceivingMedicareBenefitBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (this.sIsReceivingMedicareBenefitValue === noValue) {
            this.sIsReceivingMedicareBenefitErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isReceivingMedicareBenefitBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isReceivingMedicareBenefitBlock")
                .classList.remove("ssp-checkbox-error");
            }
          } else if (i === isReceivingMedicareBenefitClass.length - 1) {
            this.sIsReceivingMedicareBenefitErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isReceivingMedicareBenefitBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isReceivingMedicareBenefitBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
      }
      //CIS
      if (
        this.sIsRequestingOrReceivingCIS === yesValue ||
        this.sIsRequestingOrReceivingCIS === noValue
      ) {
        const isRequestingOrReceivingCISList = this.template.querySelectorAll(
          ".ssp-isRequestingOrReceivingCIS"
        );
        for (let i = 0; i < isRequestingOrReceivingCISList.length; i++) {
          if (
            isRequestingOrReceivingCISList[i].value === true &&
            this.sIsRequestingOrReceivingCIS === yesValue
          ) {
            this.isRequestingOrReceivingCISErrorMsg = "";
            break;
          } else if (this.sIsRequestingOrReceivingCIS === noValue) {
            this.isRequestingOrReceivingCISErrorMsg = "";
          } else if (i === isRequestingOrReceivingCISList.length - 1) {
            this.isRequestingOrReceivingCISErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
      }
      //Caretaker
      if (
        this.sIsReceivingCaretakerServices === yesValue ||
        this.sIsReceivingCaretakerServices === noValue
      ) {
        const isReceivingCaretakerServicesList = this.template.querySelectorAll(
          ".ssp-isReceivingCaretakerServices"
        );
        for (let i = 0; i < isReceivingCaretakerServicesList.length; i++) {
          if (
            isReceivingCaretakerServicesList[i].value === true &&
            this.sIsReceivingCaretakerServices === yesValue
          ) {
            this.isReceivingCaretakerServicesErrorMsg = "";
            break;
          } else if (this.sIsReceivingCaretakerServices === noValue) {
            this.isReceivingCaretakerServicesErrorMsg = "";
          } else if (i === isReceivingCaretakerServicesList.length - 1) {
            this.isReceivingCaretakerServicesErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
      }
      const templateAppInputs = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );
      this.templateInputsValue = templateAppInputs;
    } catch (error) {
      console.error(
        "Error occurred in saveData on Health Selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
    * @function - toggleMembers.
    * @description - Method checks which toggle button the user has clicked on and based on that
                     shows the applicable members for that specific question.
    * @param {*} event - Fired on selection of member.
    */
  toggleMembers = (event) => {
    try {
      const dataId = event.target.dataset.id;
      const dataValue = event.target.value;
      const memberSelection = this.template.querySelectorAll(
        ".ssp-healthSelectionMembers"
      );
      if (dataId === "HasPendingAccidentSettlementToggle__c") {
        this.objApplication.sHasPendingAccidentSettlement = dataValue;
      }
      for (let i = 0; i < memberSelection.length; i++) {
        // Emergency Medical Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "HasEmergencyMedicalConditionToggle__c" &&
          memberSelection[i].classList.contains("ssp-hasEmergencyMedicalBlock")
        ) {
          this.sHasEmergencyMedicalValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "HasEmergencyMedicalConditionToggle__c" &&
          memberSelection[i].classList.contains("ssp-hasEmergencyMedicalBlock")
        ) {
          this.sHasEmergencyMedicalValue = noValue;
          this.hasEmergencyMedicalErrorMsg = "";
          if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
            this.template
              .querySelector(".ssp-hasEmergencyMedicalBlock")
              .classList.remove("ssp-checkbox-error");
          }
          memberSelection[i].classList.remove("ssp-showMembers");
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.hasEmergencyMedicalMemberList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sHasEmergencyMedicalCondition",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Blind Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsBlindToggle__c" &&
          memberSelection[i].classList.contains("ssp-isBlindBlock")
        ) {
          this.sIsBlindValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          //Start - Added only intake condition as a part of Defect
          if (this.programList.includes(programConstant.programValues.MA)) {
              this.isToShowReceivingMedicareBenefit = true;
          }
          if (this.programList.includes(programConstant.programValues.MA)) {
              this.isToShowPendingAccidentSettlement = true;
          }
          //End - Added only intake condition as a part of Defect
          this.updateNonMagiMember ();
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsBlindToggle__c" &&
          memberSelection[i].classList.contains("ssp-isBlindBlock")
        ) {
          //Start - Added only intake condition as a part of Defect
          if (this.sIsDisabledValue !== yesValue
              && !this.isLoadedPendingAccidentSettlement) {
              this.isToShowPendingAccidentSettlement = false;
          }

          if (this.sIsDisabledValue !== yesValue
              && !this.isLoadedReceivingMedicareBenefit) {
              this.isToShowReceivingMedicareBenefit = false;
          }
          //End - Added only intake condition as a part of Defect
          this.sIsBlindValue = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.isBlindErrorMsg = "";
          if (this.template.querySelector(".ssp-isBlindBlock")) {
            this.template
              .querySelector(".ssp-isBlindBlock")
              .classList.remove("ssp-checkbox-error");
          }
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isBlindList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsBlind",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Disabled Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsDisabledToggle__c" &&
          memberSelection[i].classList.contains("ssp-isDisabledBlock")
        ) {
          this.sIsDisabledValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          //Start - Added only intake condition as a part of Defect
          if (this.programList.includes(programConstant.programValues.MA)) {
              this.isToShowPendingAccidentSettlement = true;
          }
          if (this.programList.includes(programConstant.programValues.MA)) {
              this.isToShowReceivingMedicareBenefit = true;
          }
          //End - Added only intake condition as a part of Defect
          this.updateNonMagiMember ();
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsDisabledToggle__c" &&
          memberSelection[i].classList.contains("ssp-isDisabledBlock")
        ) {
          //Start - Added only intake condition as a part of Defect
          if (this.sIsBlindValue !== yesValue
              && !this.isLoadedPendingAccidentSettlement) {
              this.isToShowPendingAccidentSettlement = false;
          }
          if (this.sIsBlindValue !== yesValue
              && !this.isLoadedReceivingMedicareBenefit) {
              this.isToShowReceivingMedicareBenefit = false;
          }
          //End - Added only intake condition as a part of Defect
          this.sIsDisabledValue = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.isDisabledErrorMsg = "";
          if (this.template.querySelector(".ssp-isDisabledBlock")) {
            this.template
              .querySelector(".ssp-isDisabledBlock")
              .classList.remove("ssp-checkbox-error");
          }
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isDisabledList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsDisabled",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Recovery From Illness Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsRecoveryFromIllnessOrInjuryToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isRecoveryFromIllnessOrInjuryBlock"
          )
        ) {
          this.sIsRecoveryFromIllnessOrInjuryValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsRecoveryFromIllnessOrInjuryToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isRecoveryFromIllnessOrInjuryBlock"
          )
        ) {
          this.sIsRecoveryFromIllnessOrInjuryValue = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.sRecoveryFromIllnessOrInjuryErrorMsg = "";
          if (
            this.template.querySelector(
              ".ssp-isRecoveryFromIllnessOrInjuryBlock"
            )
          ) {
            this.template
              .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
              .classList.remove("ssp-checkbox-error");
          }
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isRecoveryFromIllnessOrInjuryList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsRecoveryFromIllnessOrInjury",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Pregnancy Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsPregnantInLastThreeMonthsToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isPregnantInLastThreeMonthsBlock"
          )
        ) {
          this.sIsPregnantInLastThreeMonthsValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsPregnantInLastThreeMonthsToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isPregnantInLastThreeMonthsBlock"
          )
        ) {
          this.sIsPregnantInLastThreeMonthsValue = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.sIsPregnantInLastThreeMonthErrorMsg = "";
          if (
            this.template.querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
          ) {
            this.template
              .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
              .classList.remove("ssp-checkbox-error");
          }
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isPregnantInLastThreeMonthsList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsPregnantInLastThreeMonths",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Pending Accidental Settlement
        /* if (
                    dataValue === yesValue &&
                    dataId === "HasPendingAccidentSettlementToggle__c" &&
                    memberSelection[i].classList.contains(
                        "ssp-hasPendingAccidentSettlementBlock"
                    )
                ) {
                    this.sHasPendingAccidentSettlementValue = yesValue;
                    memberSelection[i].classList.add("ssp-showMembers");
                    break;
                } else if (
                    dataValue === noValue &&
                    dataId === "HasPendingAccidentSettlementToggle__c" &&
                    memberSelection[i].classList.contains(
                        "ssp-hasPendingAccidentSettlementBlock"
                    )
                ) {
                    this.sHasPendingAccidentSettlementValue = noValue;
                    memberSelection[i].classList.remove("ssp-showMembers");
                    this.hasPendingAccidentSettlementErrorMsg = "";
                    // When click on No then for all members we set No in healthInformationWrapperList.
                    this.hasPendingAccidentSettlementList.forEach(element => {
                        element.checked = false;
                        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
                            this.healthInformationWrapperList,
                            "sHasPendingAccidentSettlement",
                            "sMemberId",
                            element.value,
                            noValue
                        );
                    });
                    // End
                    break;
                } */
        // Receiving Medicare Benefit Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsReceivingMedicareBenefitToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingMedicareBenefitBlock"
          )
        ) {
          this.sIsReceivingMedicareBenefitValue = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsReceivingMedicareBenefitToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingMedicareBenefitBlock"
          )
        ) {
          this.sIsReceivingMedicareBenefitValue = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.sIsReceivingMedicareBenefitErrorMsg = "";
          if (
            this.template.querySelector(".ssp-isReceivingMedicareBenefitBlock")
          ) {
            this.template
              .querySelector(".ssp-isReceivingMedicareBenefitBlock")
              .classList.remove("ssp-checkbox-error");
          }
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isReceivingMedicareBenefitList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsReceivingMedicareBenefit",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        // Receiving CIS Toggle Question
        if (
          dataValue === yesValue &&
          dataId === "IsRequestingOrReceivingCISToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isRequestingOrReceivingCISBlock"
          )
        ) {
          this.sIsRequestingOrReceivingCIS = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsRequestingOrReceivingCISToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isRequestingOrReceivingCISBlock"
          )
        ) {
          this.sIsRequestingOrReceivingCIS = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.isRequestingOrReceivingCISErrorMsg = "";
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isRequestingOrReceivingCISList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsRequestingOrReceivingCIS",
              "sMemberId",
              element.value,
              noValue
            );
          });
          // End
          break;
        }
        //Caretaker Toggle
        if (
          dataValue === yesValue &&
          dataId === "IsReceivingCaretakerServicesToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingCaretakerServicesBlock"
          )
        ) {
          this.sIsReceivingCaretakerServices = yesValue;
          memberSelection[i].classList.add("ssp-showMembers");
          break;
        } else if (
          dataValue === noValue &&
          dataId === "IsReceivingCaretakerServicesToggle__c" &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingCaretakerServicesBlock"
          )
        ) {
          this.sIsReceivingCaretakerServices = noValue;
          memberSelection[i].classList.remove("ssp-showMembers");
          this.isReceivingCaretakerServicesErrorMsg = "";
          // When click on No then for all members we set No in healthInformationWrapperList.
          this.isReceivingCaretakerServicesList.forEach((element) => {
            element.checked = false;
            this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
              this.healthInformationWrapperList,
              "sIsReceivingCaretakerServices",
              "sMemberId",
              element.value,
              noValue
            );
          });
          break;
        }
      }
    } catch (error) {
      console.error(
        "Error occurred in toggleMembers of Health Selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - openLearnMoreModal
   * @description - This method is used open Learn More Modal.
   */
  openLearnMoreModal = () => {
    this.isLearnMoreModal = true;
  };

  /**
   * @function - closeLearnMoreModal
   * @description - This method is used close Learn More Modal.
   */
  closeLearnMoreModal = () => {
    this.isLearnMoreModal = false;
  };

  /**
   * @function - renderedCallback
   * @description - This method is used to show the members block for a question when the form is in edit mode.
   */
  renderedCallback () {
    try {
      this.hasRendered = true;
      const memberSelection = this.template.querySelectorAll(
        ".ssp-healthSelectionMembers"
      );
      for (let i = 0; i < memberSelection.length; i++) {
        if (
          this.sHasEmergencyMedicalValue === yesValue &&
          memberSelection[i].classList.contains("ssp-hasEmergencyMedicalBlock")
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sHasEmergencyMedicalValue === noValue &&
          memberSelection[i].classList.contains(
            "ssp-hasEmergencyMedicalBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sIsBlindValue === yesValue &&
          memberSelection[i].classList.contains("ssp-isBlindBlock")
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsBlindValue === noValue &&
          memberSelection[i].classList.contains("ssp-isBlindBlock") &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sIsDisabledValue === yesValue &&
          memberSelection[i].classList.contains("ssp-isDisabledBlock")
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsDisabledValue === noValue &&
          memberSelection[i].classList.contains("ssp-isDisabledBlock") &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sIsRecoveryFromIllnessOrInjuryValue === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-isRecoveryFromIllnessOrInjuryBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsRecoveryFromIllnessOrInjuryValue === noValue &&
          memberSelection[i].classList.contains(
            "ssp-isRecoveryFromIllnessOrInjuryBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sHasPendingAccidentSettlementValue === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-hasPendingAccidentSettlementBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sHasPendingAccidentSettlementValue === noValue &&
          memberSelection[i].classList.contains(
            "ssp-hasPendingAccidentSettlementBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sIsReceivingMedicareBenefitValue === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingMedicareBenefitBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsReceivingMedicareBenefitValue === noValue &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingMedicareBenefitBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }

        if (
          this.sIsPregnantInLastThreeMonthsValue === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-isPregnantInLastThreeMonthsBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsPregnantInLastThreeMonthsValue === noValue &&
          memberSelection[i].classList.contains(
            "ssp-isPregnantInLastThreeMonthsBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }
        //CIS
        if (
          this.sIsRequestingOrReceivingCIS === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-isRequestingOrReceivingCISBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsRequestingOrReceivingCIS === noValue &&
          memberSelection[i].classList.contains(
            "ssp-isRequestingOrReceivingCISBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }
        //Caretaker
        if (
          this.sIsReceivingCaretakerServices === yesValue &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingCaretakerServicesBlock"
          )
        ) {
          memberSelection[i].classList.add("ssp-showMembers");
        } else if (
          this.sIsReceivingCaretakerServices === noValue &&
          memberSelection[i].classList.contains(
            "ssp-isReceivingCaretakerServicesBlock"
          ) &&
          memberSelection[i].classList.contains("ssp-showMembers")
        ) {
          memberSelection[i].classList.remove("ssp-showMembers");
        }
      }
    } catch (error) {
      console.error(
        "Error occurred in renderedCallback of health selection page" +
          JSON.stringify(error)
      );
    }
  }

  /**
   * @function - storeHealthSelectionData
   * @description - This method is used to save health selection information for a member.
   */

  storeHealthSelectionData = () => {
    try {
      storeHealthSelectionData({
        sApplicationId: this.applicationId,
        sMemberHealthSelectionData: JSON.stringify(
          this.healthInformationWrapperList
        ),
        sApplicationData: JSON.stringify(this.objApplication),
      })
        .then((result) => {
          if (result.bIsSuccess === false) {
            console.error(
              "Error occurred in storeHealthSelectionData of health selection page. " +
                result.mapResponse.ERROR
            );
          } else {
            this.saveCompleted = true;
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in storeHealthSelectionData of health selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - handleConditions.
   * @description - This method is used for checkbox handling. It adds the member checked/unchecked value to wrapper.
   *                Also check at least one member is selected else show the validation messages.
   * @param {*} event - Fired on selection of member.
   */
  handleConditions = (event) => {
    try {
      const checkedVal = event.target.value;
      const question = event.target.dataset.question;
      const selectedMemberId = event.target.inputValue;

      if (question === "sHasEmergencyMedicalCondition") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sHasEmergencyMedicalCondition",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const hasEmergencyMedicalClass = this.template.querySelectorAll(
          ".ssp-hasEmergencyMedicalClass"
        );
        for (let i = 0; i < hasEmergencyMedicalClass.length; i++) {
          if (hasEmergencyMedicalClass[i].value === true) {
            this.hasEmergencyMedicalErrorMsg = "";
            if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
              this.template
                .querySelector(".ssp-hasEmergencyMedicalBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === hasEmergencyMedicalClass.length - 1 &&
            hasEmergencyMedicalClass[i].value === false
          ) {
            this.hasEmergencyMedicalErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-hasEmergencyMedicalBlock")) {
              this.template
                .querySelector(".ssp-hasEmergencyMedicalBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsBlind") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsBlind",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isBlindClass = this.template.querySelectorAll(
          ".ssp-isBlindClass"
        );
        for (let i = 0; i < isBlindClass.length; i++) {
          if (isBlindClass[i].value === true) {
            this.isBlindErrorMsg = "";
            if (this.template.querySelector(".ssp-isBlindBlock")) {
              this.template
                .querySelector(".ssp-isBlindBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === isBlindClass.length - 1 &&
            isBlindClass[i].value === false
          ) {
            this.isBlindErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-isBlindBlock")) {
              this.template
                .querySelector(".ssp-isBlindBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsDisabled") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsDisabled",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isDisabledClass = this.template.querySelectorAll(
          ".ssp-isDisabledClass"
        );
        for (let i = 0; i < isDisabledClass.length; i++) {
          if (isDisabledClass[i].value === true) {
            this.isDisabledErrorMsg = "";
            if (this.template.querySelector(".ssp-isDisabledBlock")) {
              this.template
                .querySelector(".ssp-isDisabledBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === isDisabledClass.length - 1 &&
            isDisabledClass[i].value === false
          ) {
            this.isDisabledErrorMsg = sspHealthSelectionErrorMsg;
            if (this.template.querySelector(".ssp-isDisabledBlock")) {
              this.template
                .querySelector(".ssp-isDisabledBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsRecoveryFromIllnessOrInjury") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsRecoveryFromIllnessOrInjury",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isRecoveryFromIllnessOrInjuryClass = this.template.querySelectorAll(
          ".ssp-isRecoveryFromIllnessOrInjuryClass"
        );
        for (let i = 0; i < isRecoveryFromIllnessOrInjuryClass.length; i++) {
          if (isRecoveryFromIllnessOrInjuryClass[i].value === true) {
            this.sRecoveryFromIllnessOrInjuryErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isRecoveryFromIllnessOrInjuryBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === isRecoveryFromIllnessOrInjuryClass.length - 1 &&
            isRecoveryFromIllnessOrInjuryClass[i].value === false
          ) {
            this.sRecoveryFromIllnessOrInjuryErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isRecoveryFromIllnessOrInjuryBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isRecoveryFromIllnessOrInjuryBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsPregnantInLastThreeMonths") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsPregnantInLastThreeMonths",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isPregnantInLastThreeMonthsClass = this.template.querySelectorAll(
          ".ssp-isPregnantInLastThreeMonthsClass"
        );
        for (let i = 0; i < isPregnantInLastThreeMonthsClass.length; i++) {
          if (isPregnantInLastThreeMonthsClass[i].value === true) {
            this.sIsPregnantInLastThreeMonthErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isPregnantInLastThreeMonthsBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === isPregnantInLastThreeMonthsClass.length - 1 &&
            isPregnantInLastThreeMonthsClass[i].value === false
          ) {
            this.sIsPregnantInLastThreeMonthErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isPregnantInLastThreeMonthsBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isPregnantInLastThreeMonthsBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sHasPendingAccidentSettlement") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sHasPendingAccidentSettlement",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const hasPendingAccidentSettlementClass = this.template.querySelectorAll(
          ".ssp-hasPendingAccidentSettlementClass"
        );
        for (let i = 0; i < hasPendingAccidentSettlementClass.length; i++) {
          if (hasPendingAccidentSettlementClass[i].value === true) {
            this.hasPendingAccidentSettlementErrorMsg = "";
            break;
          } else if (
            i === hasPendingAccidentSettlementClass.length - 1 &&
            hasPendingAccidentSettlementClass[i].value === false
          ) {
            this.hasPendingAccidentSettlementErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsReceivingMedicareBenefit") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsReceivingMedicareBenefit",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isReceivingMedicareBenefitClass = this.template.querySelectorAll(
          ".ssp-isReceivingMedicareBenefitClass"
        );
        for (let i = 0; i < isReceivingMedicareBenefitClass.length; i++) {
          if (isReceivingMedicareBenefitClass[i].value === true) {
            this.sIsReceivingMedicareBenefitErrorMsg = "";
            if (
              this.template.querySelector(
                ".ssp-isReceivingMedicareBenefitBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isReceivingMedicareBenefitBlock")
                .classList.remove("ssp-checkbox-error");
            }
            break;
          } else if (
            i === isReceivingMedicareBenefitClass.length - 1 &&
            isReceivingMedicareBenefitClass[i].value === false
          ) {
            this.sIsReceivingMedicareBenefitErrorMsg = sspHealthSelectionErrorMsg;
            if (
              this.template.querySelector(
                ".ssp-isReceivingMedicareBenefitBlock"
              )
            ) {
              this.template
                .querySelector(".ssp-isReceivingMedicareBenefitBlock")
                .classList.add("ssp-checkbox-error");
            }
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsRequestingOrReceivingCIS") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsRequestingOrReceivingCIS",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isRequestingOrReceivingCIS = this.template.querySelectorAll(
          ".ssp-isRequestingOrReceivingCIS"
        );
        for (let i = 0; i < isRequestingOrReceivingCIS.length; i++) {
          if (isRequestingOrReceivingCIS[i].value === true) {
            this.isRequestingOrReceivingCISErrorMsg = "";
            break;
          } else if (
            i === isRequestingOrReceivingCIS.length - 1 &&
            isRequestingOrReceivingCIS[i].value === false
          ) {
            this.isRequestingOrReceivingCISErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      } else if (question === "sIsReceivingCaretakerServices") {
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsReceivingCaretakerServices",
          "sMemberId",
          selectedMemberId,
          checkedVal
        );
        // Start - Code is added to check, at least one checkbox is checked else show validation messages
        const isReceivingCaretakerServices = this.template.querySelectorAll(
          ".ssp-isReceivingCaretakerServices"
        );
        for (let i = 0; i < isReceivingCaretakerServices.length; i++) {
          if (isReceivingCaretakerServices[i].value === true) {
            this.isReceivingCaretakerServicesErrorMsg = "";
            break;
          } else if (
            i === isReceivingCaretakerServices.length - 1 &&
            isReceivingCaretakerServices[i].value === false
          ) {
            this.isReceivingCaretakerServicesErrorMsg = sspHealthSelectionErrorMsg;
          }
        }
        // End - Code is added to check, at least one checkbox is checked else show validation messages
      }
    } catch (error) {
      console.error(
        "Error occurred in handleConditions of health selection page" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - assignDataToHealthInfoWrapperList
   * @description - This method is used to assign the healthInformationWrapperList.
   * @param {object[]} healthInformationWrapperList - Wrapper list which we need to assign the data.
   * @param {string} questionNode - Question Key node of healthInformationWrapperList.
   * @param {string} memberIdNode - Member Id key node of healthInformationWrapperList.
   * @param {string} selectedMemberId - Current selected memberId.
   * @param {string} checkedVal - To set the Y/N value.
   */
  assignDataToHealthInfoWrapperList = (
    healthInformationWrapperList,
    questionNode,
    memberIdNode,
    selectedMemberId,

    checkedVal
  ) => {
    try {
      const memberData = {};
      memberData[memberIdNode] = selectedMemberId;
      memberData[questionNode] =
        checkedVal === true || checkedVal === yesValue ? yesValue : noValue;

      if (healthInformationWrapperList.length > 0) {
        for (const element of healthInformationWrapperList) {
          if (element[memberIdNode] === selectedMemberId) {
            element[questionNode] =
              checkedVal === true || checkedVal === yesValue
                ? yesValue
                : noValue;
            break;
          } else if (
            this.allMemberIdCheckChanged.indexOf(selectedMemberId) === -1
          ) {
            healthInformationWrapperList.push(memberData);
            this.allMemberIdCheckChanged.push(selectedMemberId);
          }
        }
      } else {
        healthInformationWrapperList.push(memberData);
      }
    } catch (error) {
      console.error(
        "Error occurred in assignDataToHealthInfoWrapperList of health selection page" +
          JSON.stringify(error)
      );
    }
    return healthInformationWrapperList;
  };
  updateLabel () {
    let labelValue = "";
    if (this.isDisabilityVerified) {
      labelValue = labelValue + ", " + disability;
    }
    if (this.isBlindnessVerified) {
      labelValue = labelValue + ", " + blindness;
    }
    if (this.isMedicareVerified) {
      labelValue = labelValue + ", " + medicareCoverageLabel;
    }
    labelValue = labelValue.substring(1, labelValue.length);

    this.label.sspPageInformationVerified = formatLabels(
      this.label.sspPageInformationVerified,
      [labelValue]
    );
  }
  updateNonMagiMember () {
    try {
      this.isReceivingMedicareBenefitList = [];
      this.memberList.forEach((element) => {
        this.isReceivingMedicareBenefitList.push({
          label: element.sMemberName,
          value: element.sMemberId,
          checked:
            element.sIsReceivingMedicareBenefit === yesValue ? true : false,
          verified: element.isMedicareVerified,
        });
        this.healthInformationWrapperList = this.assignDataToHealthInfoWrapperList(
          this.healthInformationWrapperList,
          "sIsReceivingMedicareBenefit",
          "sMemberId",
          element.sMemberId,
          element.sIsReceivingMedicareBenefit
        );
      });
    } catch (error) {
      console.error(
        "Error occurred in updateNonMagiMember of health selection page" +
          JSON.stringify(error)
      );
    }
  }

  reviewRequiredLogic () {
    const appInputs = this.template.querySelectorAll(".ssp-applicationInputs");
    const revRules = [];    
    const self = this;
    let disabledFlag, blindNessFlag;

    appInputs.forEach(function (key) {      
      if (key.fieldName === "IsBlindToggle__c") {
        //Check if toggle value changed
        const blindList = self.template.querySelectorAll(".ssp-isBlindClass");
        if (key.oldValue !== key.value) {
          const blindMemberList = [];
          const blindMemberNoList = [];
          blindList.forEach(function (item) {
            if (item.value) {
              blindMemberList.push(item.inputValue);
            }
            blindMemberNoList.push(item.inputValue);
          });
          if (key.value === "Y") {
            blindNessFlag = true;
            revRules.push(
              programConstant.reviewRequiredRules.blindnessRule +
                "," +
                true +
                "," +
                blindMemberList
            );
          } else {
            blindNessFlag = false;
            revRules.push(
              programConstant.reviewRequiredRules.blindnessRule +
                "," +
                false +
                "," +
                blindMemberNoList
            );
          }
        } else {
          //Check if changed value got added
          const blindMember1 = [];
          const blindMember1No = [];
          blindList.forEach(function (item) {            
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                blindMember1.push(item.inputValue);
              } else {
                blindMember1No.push(item.inputValue);
              }
            }
          });
          if (blindMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.blindnessRule +
                "," +
                true +
                "," +
                blindMember1
            );
          }
          if (blindMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.blindnessRule +
                "," +
                false +
                "," +
                blindMember1No
            );
          }
        }
      }

      if (key.fieldName === "IsDisabledToggle__c") {
        const disableList = self.template.querySelectorAll(
          ".ssp-isDisabledClass"
        );
        //Check if toggle value is changed
        if (key.oldValue !== key.value) {
          const disableMemberList = [];
          const disableMemberNoList = [];          
          disableList.forEach(function (item) {            
            if (item.value) {
              disableMemberList.push(item.inputValue);
            }
            disableMemberNoList.push(item.inputValue);
          });          
          if (key.value === "Y") {
            disabledFlag = true;
            revRules.push(
              programConstant.reviewRequiredRules.disabilityRule +
                "," +
                true +
                "," +
                disableMemberList
            );
          } else {
            disabledFlag = false;
            revRules.push(
              programConstant.reviewRequiredRules.disabilityRule +
                "," +
                false +
                "," +
                disableMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const disableMember1 = [];
          const disableMember1No = [];
          disableList.forEach(function (item) {            
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                disableMember1.push(item.inputValue);
              } else {
                disableMember1No.push(item.inputValue);
              }
            }
          });
          if (disableMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.disabilityRule +
                "," +
                true +
                "," +
                disableMember1
            );
          }
          if (disableMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.disabilityRule +
                "," +
                false +
                "," +
                disableMember1No
            );
          }
        }
      }

      if (key.fieldName === "IsRecoveryFromIllnessOrInjuryToggle__c") {
        const recoveryList = self.template.querySelectorAll(
          ".ssp-isRecoveryFromIllnessOrInjuryClass"
        );
        if (key.oldValue !== key.value) {
          const recoveryMemberList = [];
          const recoveryMemberNoList = [];
          recoveryList.forEach(function (item) {            
            if (item.value) {
              recoveryMemberList.push(item.inputValue);
            }
            recoveryMemberNoList.push(item.inputValue);
          });
          if (key.value === "Y") {
            revRules.push(
              programConstant.reviewRequiredRules.healthConditionRule +
                "," +
                true +
                "," +
                recoveryMemberList
            );
          } else {
            revRules.push(
              programConstant.reviewRequiredRules.healthConditionRule +
                "," +
                false +
                "," +
                recoveryMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const recoveryMember1 = [];
          const recoveryMember1No = [];
          recoveryList.forEach(function (item) {            
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                recoveryMember1.push(item.inputValue);
              } else {
                recoveryMember1No.push(item.inputValue);
              }
            }
          });
          if (recoveryMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.healthConditionRule +
                "," +
                true +
                "," +
                recoveryMember1
            );
          }
          if (recoveryMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.healthConditionRule +
                "," +
                false +
                "," +
                recoveryMember1No
            );
          }
        }
      }
      if (key.fieldName === "HasEmergencyMedicalConditionToggle__c") {
        const emergencyList = self.template.querySelectorAll(
          ".ssp-hasEmergencyMedicalClass"
        );
        if (key.oldValue !== key.value) {
          const emergencyMemberList = [];
          const emergencyMemberNoList = [];
          emergencyList.forEach(function (item) {            
            if (item.value) {
              emergencyMemberList.push(item.inputValue);
            }
            emergencyMemberNoList.push(item.inputValue);
          });
          if (key.value === "Y") {
            revRules.push(
              programConstant.reviewRequiredRules.emergencyRule +
                "," +
                true +
                "," +
                emergencyMemberList
            );
          } else {
            revRules.push(
              programConstant.reviewRequiredRules.emergencyRule +
                "," +
                false +
                "," +
                emergencyMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const emergencyMember1 = [];
          const emergencyMember1No = [];
          emergencyList.forEach(function (item) {
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                emergencyMember1.push(item.inputValue);
              } else {
                emergencyMember1No.push(item.inputValue);
              }
            }
          });
          if (emergencyMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.emergencyRule +
                "," +
                true +
                "," +
                emergencyMember1
            );
          }
          if (emergencyMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.emergencyRule +
                "," +
                false +
                "," +
                emergencyMember1No
            );
          }
        }
      }
      if (key.fieldName === "IsReceivingMedicareBenefitToggle__c") {        
        const medicareList = self.template.querySelectorAll(
          ".ssp-isReceivingMedicareBenefitClass"
        );        
        if (key.oldValue !== key.value) {
          const medicareMemberList = [];
          const medicareMemberNoList = [];
          medicareList.forEach(function (item) {            
            if (item.value) {
              medicareMemberList.push(item.inputValue);
            }
            medicareMemberNoList.push(item.inputValue);
          });          
          if (key.value === "Y") {
            revRules.push(
              programConstant.reviewRequiredRules.medicareRule +
                "," +
                true +
                "," +
                medicareMemberList
            );
          } else {
            revRules.push(
              programConstant.reviewRequiredRules.medicareRule +
                "," +
                false +
                "," +
                medicareMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const medicareMember1 = [];
          const medicareMember1No = [];
          medicareList.forEach(function (item) {          
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                medicareMember1.push(item.inputValue);
              } else {
                medicareMember1No.push(item.inputValue);
              }
            }
          });
          if (medicareMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.medicareRule +
                "," +
                true +
                "," +
                medicareMember1
            );
          }
          if (medicareMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.medicareRule +
                "," +
                false +
                "," +
                medicareMember1No
            );
          }
        }
      }

      //Shikha - CIS
      if (key.fieldName === "IsRequestingOrReceivingCISToggle__c") {
        const communityList = self.template.querySelectorAll(
          ".ssp-isRequestingOrReceivingCIS"
        );
        if (key.oldValue !== key.value) {
          const communityMemberList = [];
          const communityMemberNoList = [];
          communityList.forEach(function (item) {
            if (item.value) {
              communityMemberList.push(item.inputValue);
            }
            communityMemberNoList.push(item.inputValue);
          });
          if (key.value === "Y") {
            revRules.push(
              programConstant.reviewRequiredRules.communityRule +
              "," +
              true +
              "," +
              communityMemberList
            );
          } else {
            revRules.push(
              programConstant.reviewRequiredRules.communityRule +
              "," +
              false +
              "," +
              communityMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const communityMember1 = [];
          const communityMember1No = [];
          communityList.forEach(function (item) {
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                communityMember1.push(item.inputValue);
              } else {
                communityMember1No.push(item.inputValue);
              }
            }
          });
          if (communityMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.communityRule +
              "," +
              true +
              "," +
              communityMember1
            );
          }
          if (communityMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.communityRule +
              "," +
              false +
              "," +
              communityMember1No
            );
          }          
        }
      }

      //Shikha - Caretaker
      if (key.fieldName === "IsReceivingCaretakerServicesToggle__c") {
        const communityList = self.template.querySelectorAll(
          ".ssp-isReceivingCaretakerServices"
        );
        if (key.oldValue !== key.value) {
          const communityMemberList = [];
          const communityMemberNoList = [];
          communityList.forEach(function (item) {
            if (item.value) {
              communityMemberList.push(item.inputValue);
            }
            communityMemberNoList.push(item.inputValue);
          });
          if (key.value === "Y") {
            revRules.push(
              programConstant.reviewRequiredRules.careTaker +
              "," +
              true +
              "," +
              communityMemberList
            );
          } else {
            revRules.push(
              programConstant.reviewRequiredRules.careTaker +
              "," +
              false +
              "," +
              communityMemberNoList
            );
          }
        } else {
          //Check if value is changed
          const communityMember1 = [];
          const communityMember1No = [];
          communityList.forEach(function (item) {
            if (item.oldValue !== item.value) {
              if (item.value === true) {
                communityMember1.push(item.inputValue);
              } else {
                communityMember1No.push(item.inputValue);
              }
            }
          });
          if (communityMember1.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.careTaker +
              "," +
              true +
              "," +
              communityMember1
            );
          }
          if (communityMember1No.length > 0) {
            revRules.push(
              programConstant.reviewRequiredRules.careTaker +
              "," +
              false +
              "," +
              communityMember1No
            );
          }
        }
      }
    });

    if (
      (disabledFlag === true || blindNessFlag === true) &&
      this.programList.includes("MA") && this.medicaidType !== "Non-MAGI"
    ) {
      revRules.push(
        programConstant.reviewRequiredRules.nonMagiSelection +
          "," +
          true +
          ",null"
      );
    } else if (
      this.programList.includes("MA") &&
      this.medicaidType !== "Non-MAGI" && this.modeVal === "RAC"
    ) {
      revRules.push(
        programConstant.reviewRequiredRules.nonMagiSelection +
          "," +
          false +
          ",null"
      );
    }
    this.reviewRequiredList = revRules;
  }

  // #385049
  get showEmergencyMedical (){
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.isToShowEmergencyMedical && this.questionsMap.showMedicalQuestions) : this.isToShowEmergencyMedical;
  }

  // #385049
  get showBlind (){
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.isToShowBlind && this.questionsMap.showMedicalQuestions) : this.isToShowBlind;
  }

  // #385049
  get showDisabled (){
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.isToShowDisabled && this.questionsMap.showMedicalQuestions) : this.isToShowDisabled;
  }

  // #385049
  get showRecoveryFromIllnessOrInjury (){
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.isToShowRecoveryFromIllnessOrInjury && this.questionsMap.showMedicalQuestions) : this.isToShowRecoveryFromIllnessOrInjury;
  }

  // #385049
  get showCaretakerCIS (){
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.visibility && this.questionsMap.showCommunityQuestions) : this.visibility;
  }

  // #385049
  get showReceivingMedicareBenefit () {
    return (this.modeVal === programConstant.applicationMode.RAC) ? (this.isToShowReceivingMedicareBenefit && this.questionsMap.showMedicalQuestions) : this.isToShowReceivingMedicareBenefit;
  }
}
