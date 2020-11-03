/**
 * Component Name: sspHealthCondition
 .* Author: Sharon, Naveena
 .* Description: This component creates a screen for Health Condition.
 * Date: 06/01/2020.
 */
import { track, api, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import sspHealthConditionCompleteQuestion from "@salesforce/label/c.SSP_HealthConditionCompleteQuestion";
import sspHealthConditionEmergencyTitle from "@salesforce/label/c.SSP_HealthConditionEmergencyTitle";
import sspHealthConditionEmergencyQuestionOne from "@salesforce/label/c.SSP_HealthConditionEmergencyQuestionOne";
import sspHealthConditionEmergencyQuestionTwo from "@salesforce/label/c.SSP_HealthConditionEmergencyQuestionTwo";
import sspHealthConditionRecoveryTitle from "@salesforce/label/c.SSP_HealthConditionRecoveryTitle";
import sspHealthConditionRecoveryQuestionOne from "@salesforce/label/c.SSP_HealthConditionRecoveryQuestionOne";
import sspHealthConditionRecoveryQuestionTwo from "@salesforce/label/c.SSP_HealthConditionRecoveryQuestionTwo";
import sspHealthConditionRecoveryQuestionThree from "@salesforce/label/c.SSP_HealthConditionRecoveryQuestionThree";
import EndDateStartDateValidator from "@salesforce/label/c.ssp_Health_Condition_EndDateStartDateValidator";
import sspOverlappingValidator from "@salesforce/label/c.ssp_Health_Condition_EmcOverlappingValidator";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import sspEMCOverlappingDateValidator from "@salesforce/label/c.sspEMCOverlappingDateValidator";
import emergencyBeginDate from "@salesforce/schema/SSP_Member__c.EmergencyBeginDate__c";
import emergencyEndDate from "@salesforce/schema/SSP_Member__c.EmergencyEndDate__c";
import recoveryDate from "@salesforce/schema/SSP_Member__c.RecoveryDate__c";
import returnToWorkDate from "@salesforce/schema/SSP_Member__c.ReturnToWorkDate__c";
import isOnSickLeave from "@salesforce/schema/SSP_Member__c.IsOnSickLeaveToggle__c";
import isEMCVerified from "@salesforce/schema/SSP_Member__c.DCEMCId__c";
import firstName from "@salesforce/schema/SSP_Member__c.FirstName__c";
import lastName from "@salesforce/schema/SSP_Member__c.LastName__c";
import isUSCitizenToggle from "@salesforce/schema/SSP_Member__c.IsUSCitizenToggle__c";
import hasEmergencyMedicalConditionToggle from "@salesforce/schema/SSP_Member__c.HasEmergencyMedicalConditionToggle__c";
import isRecoveryFromIllnessOrInjuryToggle from "@salesforce/schema/SSP_Member__c.IsRecoveryFromIllnessOrInjuryToggle__c";
import dcId from "@salesforce/schema/SSP_Member__c.DCId__c";
import individualId from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import getProgramsApplied from "@salesforce/apex/SSP_HealthConditionController.fetchProgramsApplied";
import checkOverlappingDate from "@salesforce/apex/SSP_MemberService.checkOverlappingDate";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import utility, { getYesNoOptions } from "c/sspUtility";
import { formatLabels } from "c/sspUtility";
import sspConstants, { toggleFieldValue } from "c/sspConstants";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
const FIELDS = [
  firstName,
  lastName,
  emergencyBeginDate,
  emergencyEndDate,
  recoveryDate,
  isOnSickLeave,
  returnToWorkDate,
  isUSCitizenToggle,
  hasEmergencyMedicalConditionToggle,
  isRecoveryFromIllnessOrInjuryToggle,
  dcId,
  individualId,
  isEMCVerified
];

const serviceIdentifier = "EmergencyMedicalCondition";
export default class SspHealthCondition extends BaseNavFlowPage {
  @api memberId;
  @api applicationId;
  @track member;
  @track optList = getYesNoOptions();
  @track pageName;
  @track metaData;
  @track isTrueSickLeave;
  @track basedOnProgramType = false;
  @track basedOnMedicaidType = false;
  @track
  sspEndDateStartDateValidator = EndDateStartDateValidator;
  @track label = {
    sspHealthConditionCompleteQuestion,
    sspHealthConditionEmergencyTitle,
    sspHealthConditionEmergencyQuestionOne,
    sspHealthConditionEmergencyQuestionTwo,
    sspHealthConditionRecoveryTitle,
    sspHealthConditionRecoveryQuestionOne,
    sspHealthConditionRecoveryQuestionTwo,
    sspHealthConditionRecoveryQuestionThree,
    sspOverlappingValidator,
    sspPageInformationVerified,
    toastErrorText,
    sspEMCOverlappingDateValidator,
    startBenefitsAppCallNumber
  };
  @track trueValue = true;
  @track hasSaveValidationError = false;
  @track showSpinner = false;
  @track toggleIsOnSickLeave;
  @track healthConditionVerified;
  @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track timeTravelDate;

  emergencyBeginDate1;
  emergencyEndDate1;
  recoveryDate1;
  returnToWorkDate1;
  oldEndDate;
  oldStartDate;
  isOnSickLeaveToggle;
  isUSCitizen;
  hasEmergencyMedicalCondition;
  isRecoveryFromIllnessOrInjury;
  sOverlappingDateErrorMsg = "";
  dcCaseNumber = "";
  doesCaseExists = "";
  callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
  /**
   * @function 	: nextEvent.
   * @description : This attribute is used to go to next queued screen.
   * */
  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    try {
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.nextValue = value;
        this.validateData();
      }
    } catch (error) {
      console.error("Error in set nextEvent of Health condition page", error);
    }
  }

  /**
   * @function : allowSaveData
   * @description : Getter setter methods for allowSave.
   */
  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    this.validationFlag = value;
    if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
      const currentStartEndDates = JSON.parse(value);
      const memberData = this.member;
      if (this.basedOnMedicaidType && this.doesCaseExists) {
        // For Emergency
        this.getOverlappingServiceData(
          memberData.fields.DCId__c.value,
          serviceIdentifier,
          value,
          currentStartEndDates.BeginDate__c,
          currentStartEndDates.EndDate__c,
          this.member.fields.IndividualId__c.value,
          this.applicationId,
          this.dcCaseNumber
        );
      } else if (this.basedOnMedicaidType || this.basedOnProgramType) {
        // For Recovery
        this.handleSave(value);
      }
    }
  }

  /**
   * @function 	: MetadataList.
   * @description : This function is part of validation framework which is used to get the metaData values.
   * */
  @api
  get MetadataList () {
    return this.metaData;
  }
  set MetadataList (value) {
    this.metaData = value;
    //CD2 2.5	Security Role Matrix and Program Access.                
    if (Object.keys(value).length > 0){
      this.constructRenderingMap(null, value); 
    }
  }

  /**
   * @function : Getter setter methods for pageToLoad.
   * @description : Getter setter methods for pageToLoad.
   */
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
   * @function - getRecord().
   * @description - This is a wire function to get INDIVIDUAL record for SSP Member.
   * @param {response} response - Response Data.
   */
  @wire(getRecord, { recordId: "$memberId", fields: FIELDS })
  getMember (response) {
    try {
      this.memberWire = response;
      const data = response.data;
      const error = response.error;
      if (data) {
        this.member = data;
        const dcIdValue = getFieldValue(this.member, isEMCVerified);
        if (dcIdValue){
          this.healthConditionVerified = true;
        } else {
          this.healthConditionVerified = false;
        }
        this.toggleIsOnSickLeave = getFieldValue(this.member, isOnSickLeave);
        this.isUSCitizen = getFieldValue(this.member, isUSCitizenToggle);
        this.hasEmergencyMedicalCondition = getFieldValue(
          this.member,
          hasEmergencyMedicalConditionToggle
        );
        this.isRecoveryFromIllnessOrInjury = getFieldValue(
          this.member,
          isRecoveryFromIllnessOrInjuryToggle
        );

        this.oldStartDate = getFieldValue(this.member, emergencyBeginDate);
        this.oldEndDate = getFieldValue(this.member, emergencyEndDate);
        this.isOnSickLeaveToggle = getFieldValue(this.member, isOnSickLeave);

        this.emergencyBeginDate1 = getFieldValue(
          this.member,
          emergencyBeginDate
        );
        this.updateLabels();
        this.wiredGetProgramsApplied();
      } else if (error) {
        console.error("Error in getMember:", error);
      }
      if (this.isOnSickLeaveToggle === toggleFieldValue.yes) {
        this.isTrueSickLeave = true;
      } else {
        this.isTrueSickLeave = false;
      }
    } catch (error) {
      console.error("Error in getMember:", error);
    }
  }

  /**
   * @function - wiredGetProgramsApplied().
   * @description - This is a wire function to display fields based on programs applied.
   */
  wiredGetProgramsApplied () {
    try {
      getProgramsApplied({
        memberId: this.memberId,
        applicationId: this.applicationId
      }).then(data => {
        if (data && data.mapResponse) {
          const medicaidType = data.mapResponse.medicaidType;
          const finalData = data.mapResponse.programsApplied;
          this.dcCaseNumber = data.mapResponse.dcCaseNumber;
          this.doesCaseExists = data.mapResponse.doesCaseExists;
          this.timeTravelDate = data.mapResponse.timeTravelTodayDate;
          if (
            medicaidType !== undefined &&
            (medicaidType.indexOf(sspConstants.medicaidTypes.MAGI) !== -1 ||
              medicaidType.indexOf(sspConstants.medicaidTypes.NonMAGI) !==
                -1) &&
            this.isUSCitizen === toggleFieldValue.no &&
            this.hasEmergencyMedicalCondition === toggleFieldValue.yes
          ) {
            this.basedOnMedicaidType = true;
          } else {
            this.basedOnMedicaidType = false;
          }
          if (
            finalData !== undefined &&
            (finalData.indexOf(sspConstants.programValues.SN) !== -1 ||
              finalData.indexOf(sspConstants.programValues.KT) !== -1) &&
            this.isRecoveryFromIllnessOrInjury === toggleFieldValue.yes
          ) {
            this.basedOnProgramType = true;
          }
        } else {
          this.basedOnProgramType = false;
          console.error(
            "Error in SSP_HealthConditionController:",
            JSON.parse(JSON.stringify(data))
          );
        }
      });
    } catch (error) {
      console.error("Error in getProgramsApplied:", error);
    }
  }

  /**
   * @function : connectedCallback.
   * @description : Fire an event from connectedCallback to have field and Object Details.
   */
  connectedCallback () {
    try {
      this.label.sspPageInformationVerified = formatLabels(
        this.label.sspPageInformationVerified,
        [this.pageName]
      );
      const fields = FIELDS.map(
        field => field.fieldApiName + "," + field.objectApiName
      );
      this.getMetadataDetails(fields, null, "SSP_APP_Details_HealthCondition");
    } catch (error) {
      console.error("Error in connectedCallback:", error);
    }
  }

  /**
   * @function : validateData.
   * @description : Fire an event from validateData.
   */
  validateData = () => {
    try {
      const inputElements = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );
      this.templateInputsValue = inputElements;
    } catch (error) {
      console.error("Error in validateData:", error);
    }
  };

  /**
   * @function : name
   * @description : Getter setter methods for name.
   */
  get name () {
    try {
      const firstName1 = getFieldValue(this.member, firstName);
      const lastName1 = getFieldValue(this.member, lastName);
      return firstName1 + " " + lastName1;
    } catch (error) {
      console.error("Error in getter name:", error);
      return utility.isUndefinedOrNull(getFieldValue(this.member, firstName));
    }
  }

  /**
   * @function : emergencyBeginDateReturn
   * @description : Getter setter methods for emergencyBeginDateReturn.
   */
  get emergencyBeginDateReturn () {
    try {
      return getFieldValue(this.member, emergencyBeginDate);
    } catch (error) {
      console.error("Error in getter emergencyBeginDateReturn:", error);
      return utility.isUndefinedOrNull(
        getFieldValue(this.member, emergencyBeginDate)
      );
    }
  }

  /**
   * @function : emergencyEndDateReturn
   * @description : Getter setter methods for emergencyEndDateReturn.
   */
  get emergencyEndDateReturn () {
    try {
      return getFieldValue(this.member, emergencyEndDate);
    } catch (error) {
      console.error("Error in getter emergencyEndDateReturn:", error);
      return utility.isUndefinedOrNull(
        getFieldValue(this.member, emergencyEndDate)
      );
    }
  }

  /**
   * @function : recoveryDateReturn
   * @description : Getter setter methods for recoveryDateReturn.
   */
  get recoveryDateReturn () {
    try {
      return getFieldValue(this.member, recoveryDate);
    } catch (error) {
      console.error("Error in getter recoveryDateReturn:", error);
      return utility.isUndefinedOrNull(
        getFieldValue(this.member, recoveryDate)
      );
    }
  }

  /**
   * @function : returnToWorkDateReturn
   * @description : Getter setter methods for returnToWorkDateReturn.
   */
  get returnToWorkDateReturn () {
    try {
      return getFieldValue(this.member, returnToWorkDate);
    } catch (error) {
      console.error("Error in getter returnToWorkDateReturn:", error);
      return utility.isUndefinedOrNull(
        getFieldValue(this.member, returnToWorkDate)
      );
    }
  }

  /**
   * @function : returnIsOnSickToggle
   * @description : Getter setter methods for returnIsOnSickToggle.
   */

  // eslint-disable-next-line getter-return
  get returnIsOnSickToggle () {
    try {
      return getFieldValue(this.member, isOnSickLeave);
    } catch (error) {
      console.error("Error in getter returnIsOnSickToggle:", error);
      return utility.isUndefinedOrNull(
        getFieldValue(this.member, isOnSickLeave)
      );
    }
  }

  /**
   * @function - handleEmergencyBeginDate().
   * @description - This is a handler for EmergencyBeginDate field.
   */

  handleEmergencyBeginDate = event => {
    try {
      this.emergencyBeginDate1 = event.target.value;
      
      this.emergencyEndDate1 = null;
      this.validateDates();
    } catch (error) {
      console.error("Error in handleEndDateOne:", error);
    }
  };

  /**
   * @function - handleEmergencyEndDate().
   * @description - This is a handler for EmergencyEndDate field.
   */

  handleEmergencyEndDate = event => {
    try {
      this.emergencyEndDate1 = event.target.value;
      this.validateDates();
    } catch (error) {
      console.error("Error in handleEndDateTwo:", error);
    }
  };

  /**
   * @function - handleReturnDate().
   * @description - This is a handler for returnToWorkDate field.
   */

  handleReturnDate = event => {
    try {
      this.returnToWorkDate1 = event.target.value;
    } catch (error) {
      console.error("Error in handleReturnDate:", error);
    }
  };

  /**
   * @function - handleRecoveryDate().
   * @description - This is a handler for recoveryDate field.
   */

  handleRecoveryDate = event => {
    try {
      this.recoveryDate1 = event.target.value;
    } catch (error) {
      console.error("Error in handleReturnEndDateOne:", error);
    }
  };

  /**
   * @function - toggleHealthConditionOption().
   * @description - This is a handler for toggle field.
   */

  toggleHealthConditionOption = event => {
    try {
      this.isOnSickLeaveToggle = event.target.value;
      if (event.target.value === toggleFieldValue.yes) {
        this.isTrueSickLeave = true;
      } else {
        this.isTrueSickLeave = false;
        this.returnToWorkDate1 = null;
        this.isOnSickLeaveToggle = toggleFieldValue.no;
      }
    } catch (error) {
      console.error("Error in toggleHealthConditionOption:", error);
    }
  };

  /**
   * @function - updateLabels().
   * @description - This method is used to update labels with Applicant Name wherever required.
   */

  updateLabels = () => {
    try {
      const label = JSON.parse(JSON.stringify(this.label));
      label.sspHealthConditionRecoveryQuestionOne = label.sspHealthConditionRecoveryQuestionOne.replace(
        /\{0\}/,
        this.name
      );
      label.sspHealthConditionRecoveryQuestionTwo = label.sspHealthConditionRecoveryQuestionTwo.replace(
        /\{1\}/,
        this.name
      );
      label.sspHealthConditionRecoveryQuestionThree = label.sspHealthConditionRecoveryQuestionThree.replace(
        /\{2\}/,
        this.name
      );
      const newDateLabel = new Date(this.oldEndDate);
      const oldEndDateLabel = [
        newDateLabel.getMonth() +
          1 +
          "/" +
          newDateLabel.getDate() +
          "/" +
          newDateLabel.getFullYear()
      ];
      label.sspOverlappingValidator = label.sspOverlappingValidator.replace(
        /\[Emergency Medical Condition End Date\]/,
        oldEndDateLabel
      );

      this.label = label;
    } catch (error) {
      console.error("Error in updating labels:", error);
    }
  };

  /**
   * @function - handleSave().
   * @description - This method is used to update record.
   */

  handleSave = () => {
    try {
      const fields = {};
      fields[emergencyBeginDate.fieldApiName] = this.emergencyBeginDate1;
      fields[emergencyEndDate.fieldApiName] = this.emergencyEndDate1;
      fields[recoveryDate.fieldApiName] = this.recoveryDate1;
      fields[isOnSickLeave.fieldApiName] = this.isOnSickLeaveToggle;
      fields[returnToWorkDate.fieldApiName] = this.returnToWorkDate1;
      const record = {
        recordId: this.memberId,
        fields: fields
      };

      updateRecord(record)
        .then(() => {
          refreshApex(this.memberWire);
          this.saveCompleted = true;
        })
        .catch(error => {
          console.error("error", error);
        });
      this.showSpinner = false;
    } catch (error) {
      console.error("Error in handleSave:", error);
    }
  };

  /**
   * @function - validateDates().
   * @description - This method is used to check whether emergencyEndDate is greater that emergencyBeginDate.
   */

  validateDates = () => {
    try {
      if (
        !utility.isUndefinedOrNull(this.emergencyBeginDate1) &&
        !utility.isUndefinedOrNull(this.emergencyEndDate1)
      ) {
        const contactInfo = this.template.querySelectorAll(
          ".ssp-applicationInputs"
        );
        contactInfo.forEach((contact, index) => {
          if (
            contact.getAttribute("data-id") ===
            sspConstants.sspBenefitFields.EndDate
          ) {
            const messageList = contactInfo[index].ErrorMessageList;
            const indexOfMessage = messageList.indexOf(
              EndDateStartDateValidator
            );

            const beginDate = new Date(this.emergencyBeginDate1);
            const endDate = new Date(this.emergencyEndDate1);
            if (indexOfMessage === -1 && beginDate >= endDate) {
              messageList.push(EndDateStartDateValidator);
            } else if (indexOfMessage >= 0 && endDate > beginDate) {
              messageList.splice(indexOfMessage, 1);
            }

            contactInfo[index].ErrorMessageList = JSON.parse(
              JSON.stringify(messageList)
            );
          }
        });
      }
    } catch (error) {
      console.error("Error in validateDates:", error);
    }
  };

  /**
   * @function - getOverlappingServiceData().
   * @description - This method is used to check the Overlapping dates.
   * @param {*} dcId - Contains Dc Id.
   * @param {*} identifier - Constains identifier.
   * @param {*} valueData - Constains identifier.
   * @param {*} startDate - Contains startDate.
   * @param {*} endDate - Contains endDate.
   * @param {*} individualId - Contains individualId.
   * @param {*} applicationId - Contains applicationId.
   * @param {*}caseNumber - Contains caseNumber.
   */
  getOverlappingServiceData (
    // eslint-disable-next-line no-shadow
    dcId,
    identifier,
    valueData,
    startDate,
    endDate,
    // eslint-disable-next-line no-shadow
    individualId,
    applicationId,
    caseNumber
  ) {
    this.showSpinner = true;
    try {
      const requestData = this.createOverlappingRequestData(
        dcId,
        identifier,
        startDate,
        endDate,
        individualId,
        applicationId,
        caseNumber
      );
      checkOverlappingDate({
        sOverlappingRequest: JSON.stringify(requestData)
      })
        .then(result => {
          if (result.bIsSuccess) {
            const overlappingData = JSON.parse(
              result.mapResponse.overlappingDatesResponse
            )[0];
            if (
              overlappingData !== undefined &&
              overlappingData.IsDateOverLapping !== undefined &&
              overlappingData.IsDateOverLapping
            ) {
              // eslint-disable-next-line no-shadow
              let endDate = overlappingData.EndDate[0].includes("null")
                ? ""
                : overlappingData.EndDate[0];
              if (endDate !== "") {
                endDate = endDate.includes("(")
                  ? endDate.replace("(", "")
                  : endDate;
                endDate = endDate.includes(")")
                  ? endDate.replace(")", "")
                  : endDate;
                endDate = endDate.includes("T")
                  ? endDate.split("T")[0]
                  : endDate;
                const endDateSplit = endDate.includes("-")
                  ? endDate.split("-")
                  : "";
                endDate =
                  endDateSplit !== ""
                    ? endDateSplit[1] +
                      "-" +
                      endDateSplit[2] +
                      "-" +
                      endDateSplit[0]
                    : "";
                this.sOverlappingDateErrorMsg = this.label.sspEMCOverlappingDateValidator.replace(
                  "{0}",
                  endDate
                );
              } else {
                this.sOverlappingDateErrorMsg = this.label.sspEMCOverlappingDateValidator.replace(
                  "ending {0}",
                  ""
                );
              }
              
              this.hasSaveValidationError = true;
              this.showSpinner = false;
            } else if (valueData !== undefined && valueData !== "") {
              this.sOverlappingDateErrorMsg = "";
              this.handleSave(valueData);
            }
          } else if (result.bIsSuccess === false) {
            console.error(
              "Error occurred in getOverlappingServiceData of health condition page. " +
                result.mapResponse.ERROR
            );
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in getOverlappingServiceData of health condition page" +
          JSON.stringify(error.message)
      );
    }
  }

  /**
   * @function - createOverlappingRequestData().
   * @description - This method is used to set Overlapping request.
   * @param {*} dcId - Contains Dc Id.
   * @param {*} identifier - Constains identifier.
   * @param {*} startDate - Contains startDate.
   * @param {*} endDate - Contains endDate.
   * @param {*} individualId - Contains individualId.
   * @param {*} applicationId - Contains applicationId.
   * @param {*} caseNumber - Contains caseNumber.
   */
  createOverlappingRequestData (
    // eslint-disable-next-line no-shadow
    dcId,
    identifier,
    startDate,
    endDate,
    // eslint-disable-next-line no-shadow
    individualId,
    applicationId,
    caseNumber
  ) {
    const requestData = {};
    try {
      requestData.dcId =
        dcId !== null && dcId !== undefined && dcId !== "" ? dcId : 0;
      requestData.identifier =
        identifier !== null && identifier !== undefined ? identifier : "";
      requestData.startDate =
        startDate !== null && startDate !== undefined ? startDate : "";
      requestData.endDate =
        endDate !== null && endDate !== undefined ? endDate : "";
      requestData.individualId =
        individualId !== null &&
        individualId !== undefined &&
        individualId !== ""
          ? individualId
          : 0;
      requestData.applicationId = applicationId;
      requestData.caseNumber = caseNumber;
    } catch (error) {
      console.error(
        "Error occurred in createOverlappingRequestData of health condition page" +
          JSON.stringify(error)
      );
    }
    return requestData;
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
        "Error in hideToast on health condition screen" + JSON.stringify(error)
      );
    }
  };
    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
      try{
          if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
              const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
              if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                this.isPageAccessible = true;
            }
            else {
                this.isPageAccessible = !(securityMatrix.screenPermission === sspConstants.permission.notAccessible);
            }
              this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
            if (!this.isPageAccessible) {
                this.showAccessDeniedComponent = true;
            } else {
                this.showAccessDeniedComponent = false;
            }
          }
      } catch (error) {
          console.error(
              "Error in highestEducation.constructRenderingMap", error
          );
      }
  }
}