/**
 * Component Name - sspHealthInformationPregnancy.
 * Author         - Siddarth, Shivam.
 * Description    - This component is used to take information on pregnancy.
 * Date       	  - 19/12/2019.
 */

import { track, api, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { formatLabels } from "c/sspUtility";

import sspCompleteQuestionsAboutPregnancy from "@salesforce/label/c.sspCompleteQuestionsAboutPregnancy";
import sspIsPregnant from "@salesforce/label/c.sspIsPregnant";

import { updateRecord, getRecord, getFieldValue } from "lightning/uiRecordApi";

import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import constants from "c/sspConstants";
import { getYesNoOptions } from "c/sspUtility";
import sspUtility from "c/sspUtility";

import sspBirthsExpected from "@salesforce/label/c.sspBirthsExpected";
import sspAltChildrenOptions from "@salesforce/label/c.sspAltChildrenOptions";
import sspExpectedDueDate from "@salesforce/label/c.sspExpectedDueDate";
import sspKnownDatePregnancy from "@salesforce/label/c.sspKnownDatePregnancy";
import sspReferralForWomen from "@salesforce/label/c.sspReferralForWomen";
import sspWICProgram from "@salesforce/label/c.sspWicProgram";
import sspPregnancyDueDateValidator from "@salesforce/label/c.sspPregnancyDueDateValidator";
import sspRACPregnancyValidator from "@salesforce/label/c.sspRACPregnancyValidator";
import sspPregnancyOverlappingDateValidator from "@salesforce/label/c.sspPregnancyOverlappingDateValidator";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import IS_PREGNANT from "@salesforce/schema/SSP_Member__c.IsPregnantToggle__c";
import BIRTHS_EXPECTED from "@salesforce/schema/SSP_Member__c.NumberOfBirthsExpected__c";
import REFFERED_TO_WIC from "@salesforce/schema/SSP_Member__c.IsToBeReferredToWicToggle__c";
import PREGNANCY_DUE_DATE from "@salesforce/schema/SSP_Member__c.PregnancyDueDate__c";
import PREGNANCY_TERMINATION_DATE from "@salesforce/schema/SSP_Member__c.PregnancyTerminationDate__c";
import MEMBER_FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import MEMBER_LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import DC_ID from "@salesforce/schema/SSP_Member__c.DCId__c";
import DCPREGNANCY_ID from "@salesforce/schema/SSP_Member__c.DCPregnancyId__c";
import INDIVIDUAL_ID from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import getPregnancyScreenData from "@salesforce/apex/SSP_PregnancyScreenController.getPregnancyScreenData";
import createTrackDeletion from "@salesforce/apex/SSP_PregnancyScreenController.createTrackDeletion";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import checkOverlappingDate from "@salesforce/apex/SSP_MemberService.checkOverlappingDate";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import { refreshApex } from "@salesforce/apex";
const serviceIdentifier = "PREG";
const pregMonths = 8;
const unicorn0 = /\{0\}/g;
export default class SspHealthInformationPregnancy extends BaseNavFlowPage {
  @api memberId;
  @api applicationId;
  @track optList = getYesNoOptions();
  @track label = {
    sspCompleteQuestionsAboutPregnancy,
    sspIsPregnant,
    sspBirthsExpected,
    sspAltChildrenOptions,
    sspExpectedDueDate,
    sspKnownDatePregnancy,
    sspReferralForWomen,
    sspWICProgram,
    sspPageInformationVerified,
    toastErrorText,
        sspPregnancyOverlappingDateValidator,
        startBenefitsAppCallNumber
  };
  @track pregnancyVerification = false;
  @track showSpinner = false;
  @track showExpectedDueDate = false;
  @track showLastPregnancyDate = false;
  @track isPregnant;
  @track expectedBirthCountPicklistValues = [];
  @track expectedBirthCount;
  @track expectedDueDate;
  @track expectedTerminationDate;
  @track referredTOWIC;
  @track memberFullName = MEMBER_FIRST_NAME + " " + MEMBER_LAST_NAME;
  @track sspCompleteQuestionsAboutPregnancyReplaced;
  @track sspIsPregnantReplaced;
  @track sspReferralForWomenReplaced;
  @track MetaDataListParent;
  @track currentMonthValue;
  @track trueValue = true;
  @track hasSaveValidationError = false;
  @track DCPregnancyId;
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track individualRecordTypeId;
  wiredRefresh;
  updatedMember = {};
  recordFieldList = [
    IS_PREGNANT,
    BIRTHS_EXPECTED,
    PREGNANCY_DUE_DATE,
    PREGNANCY_TERMINATION_DATE,
    REFFERED_TO_WIC,
    MEMBER_LAST_NAME,
    MEMBER_FIRST_NAME,
    DC_ID,
    DCPREGNANCY_ID,
    INDIVIDUAL_ID
  ];
  sOverlappingDateErroMsg = "";
  dcCaseNumber = "";
  doesCaseExists = "";
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
  /**
   * @function - setQuestionValue().
   * @description - This method is used to assign the values for each health selection question.
   *
   */
  connectedCallback () {
    try {
      this.label.sspPageInformationVerified = formatLabels(
        this.label.sspPageInformationVerified,
        [this.pageName]
      );
      this.showSpinner = true;
      refreshApex(this.wiredRefresh);
      const fieldList = this.recordFieldList.map(
        item => item.fieldApiName + "," + item.objectApiName
      );
      this.getMetadataDetails(fieldList, null, "SSP_APP_Details_Pregnancy");
    } catch (error) {
      console.error("Error in connectedCallBack:", error);
    }
  }

  /**
   * @function - objectInfo.
   * @description - This method is used to get INDIVIDUAL record type for SSP Member.
   *
   */
  @wire(getObjectInfo, { objectApiName: SSP_MEMBER })
  objectInfo ({ error, data }) {
    try {
      if (data) {
        const RecordTypesInfo = constants.sspMemberConstants.RecordTypesInfo;
        const individual =
          constants.sspMemberConstants.IndividualRecordTypeName;
        const recordTypeInformation = data[RecordTypesInfo];
        this.individualRecordTypeId = Object.keys(recordTypeInformation).find(
          recTypeInfo => recordTypeInformation[recTypeInfo].name === individual
        );
      } else if (error) {
        console.error(
          "Error occurred while fetching record type in Not a US citizen screen" +
            error
        );
      }
    } catch (error) {
      console.error(
        "Error occurred while fetching record type in Not a US citizen screen" +
          error
      );
    }
  }

  /**
   * @function - fetchExpectedBirthCountPicklistValues().
   * @description - This method is used to get picklist values for Expected Birth Count field.
   *
   */
  @wire(getPicklistValues, {
    recordTypeId: "$individualRecordTypeId",
    fieldApiName: BIRTHS_EXPECTED
  })
  fetchExpectedBirthCountPicklistValues ({ error, data }) {
    try {
      if (data) {
        this.expectedBirthCountPicklistValues = data.values;
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in getPicklistValues: ", error);
    }
  }

  /**
   * @function - wiredGetRecord().
   * @description - This method is used to Load the record with saved values from the database.
   * @param {string} value - Gets the record from database.
   */
  @wire(getRecord, {
    recordId: "$memberId",
    fields: "$recordFieldList"
  })
  wiredGetRecord (value) {
    try {
      this.wiredRecord = value;
      const { data, error } = value;
      if (data) {
        this.record = data;
        this.updateLabels();

        this.isPregnant = getFieldValue(this.record, IS_PREGNANT);
        this.expectedBirthCount = getFieldValue(this.record, BIRTHS_EXPECTED);
        this.expectedDueDate = getFieldValue(this.record, PREGNANCY_DUE_DATE);
        this.expectedTerminationDate = getFieldValue(
          this.record,
          PREGNANCY_TERMINATION_DATE
        );
        this.referredTOWIC = getFieldValue(this.record, REFFERED_TO_WIC);
                this.DCPregnancyId = getFieldValue(
                    this.record,
                    DCPREGNANCY_ID
                );

                if (this.DCPregnancyId) {
                    this.pregnancyVerification = true;
                } else {
                    this.pregnancyVerification = false;
                }

        if (this.isPregnant === constants.toggleFieldValue.yes) {
          this.showExpectedDueDate = true;
          this.showLastPregnancyDate = false;
        } else if (this.isPregnant === constants.toggleFieldValue.no) {
          this.showExpectedDueDate = false;
          this.showLastPregnancyDate = true;
        }
        this.showSpinner = false;
      } else if (error) {
        console.error(JSON.stringify(error));
      }
      this.showSpinner = false;
    } catch (error) {
      console.error("Error in wiredGetRecord: ", error);
    }
  }

  /**
   * @function - currentMonth().
   * @description - This method is used to get today's date through utility class.
   * @param {object} response - Response object.
   */
  @wire(getPregnancyScreenData, {
    sApplicationId: "$applicationId",
    sMemberId: "$memberId"
  })
  getPregnancyData (response) {
    try {
      const { data, error } = response;
      this.wiredRefresh = response;
      if (data) {
        this.currentMonthValue = data.mapResponse.todayDate;
        if (data.mapResponse.appIndData.length > 0) {
          const applicationIndividual = data.mapResponse.appIndData[0];
          this.dcCaseNumber =
            applicationIndividual.SSP_Application__r !== undefined
              ? applicationIndividual.SSP_Application__r.DCCaseNumber__c
              : "";
          this.doesCaseExists =
            applicationIndividual.SSP_Member__r !== undefined &&
            applicationIndividual.SSP_Member__r.Contact__r !== undefined
              ? applicationIndividual.SSP_Member__r.Contact__r
                  .DoesCaseExistForIndividual__c
              : "";
        }
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in wired getPregnancyData: ", error);
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
   * @function - nextEvent().
   * @description - Next Event getter method for framework.
   *
   */
  @api
  get nextEvent () {
    return this.nextValue;
  }
  /**
   * @function - nextEvent().
   * @description - Next Event setter method for framework.
   * @param {string} value - Setter for Next Event framework property.
   */
  set nextEvent (value) {
    try {
      if (!sspUtility.isUndefinedOrNull(value)) {
        this.nextValue = value;
        this.checkInputValidation();
      }
    } catch (e) {
      console.error(
        "Error in set nextEvent of Primary Applicant Contact page",
        e
      );
    }
  }

  /**
   * @function - MetadataList().
   * @description - MetadataList getter method for framework.
   *
   */
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  /**
   * @function - MetadataList().
   * @description - Next Event setter method for framework.
   * @param {string} value - Setter for MetadataList framework property.
   */
  set MetadataList (value) {
    try {
      if (!sspUtility.isUndefinedOrNull(value)) {
        this.MetaDataListParent = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
          if (Object.keys(value).length > 0){
            this.constructRenderingMap(null, value); 
        }
      }
    } catch (e) {
      console.error(
        "Error in set MetadataList of Primary Applicant Contact page",
        e
      );
    }
  }

  /**
   * @function - allowSaveData().
   * @description - This method validates the input data and then saves it.
   *
   */
  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    try {
      this.validationFlag = value;
      if (
        !sspUtility.isUndefinedOrNull(value) &&
        !sspUtility.isEmpty(value) &&
        this.doesCaseExists
      ) {
        const memberData = this.record;
        const currentInputData = JSON.parse(value);
        if (currentInputData.PregnancyDueDate__c) {
            const pregEndDate = currentInputData.PregnancyDueDate__c;
            const pregNewEndDate = new Date(pregEndDate);
            const pregNewStartDate = new Date(
                pregNewEndDate.setMonth(
                    pregNewEndDate.getMonth() - pregMonths
                )
          );
          const pregStartDate =
            pregNewStartDate.getFullYear() +
            "-" +
            (pregNewStartDate.getMonth() + 1) +
            "-" +
            pregNewStartDate.getDate();
          this.getOverlappingServiceData(
            memberData.fields.DCPregnancyId__c.value,
            serviceIdentifier,
            value,
            pregStartDate,
            pregEndDate,
            memberData.fields.IndividualId__c.value,
            this.applicationId,
            this.dcCaseNumber
          );
        }
        else  if (
          !sspUtility.isUndefinedOrNull(value) &&
          !sspUtility.isEmpty(value)
        ){
          this.handleSave();
        }       
      } else if (
        !sspUtility.isUndefinedOrNull(value) &&
        !sspUtility.isEmpty(value)
      ) {
        this.handleSave();
      }
    } catch (e) {
      console.error(
        "Error in set allowSaveData of Primary Applicant Contact page",
        e.message
      );
    }
  }

  /**
   * @function - isPregnantValue().
   * @description - Getter method to get isPregnant value as true/False instead of YES/NO.
   *
   */
  get isPregnantValue () {
    return this.isPregnant;
  }

  /**
   * @function - isReferredToWIC().
   * @description - Getter method to get isWICReferred value as true/False instead of YES/NO.
   *
   */
  get isReferredToWIC () {
    return this.referredTOWIC;
  }

  /**
   * @function - populateExpectedBirths().
   * @description - Getter method to get Expected Number of births value, otherwise defaulted to 1.
   *
   */
  get populateExpectedBirths () {
    return this.expectedBirthCount ? this.expectedBirthCount : "1";
  }

  /**
   * @function - checkInputValidation().
   * @description - this method is used to validate the inputs made by user.
   */
  checkInputValidation = () => {
    try {
      const inputElements = this.template.querySelectorAll(".ssp-input");
      const inputElementsArray = Array.from(inputElements);
      inputElements.forEach(a => { a.ErrorMessageList = [] });
      this.templateInputsValue = inputElementsArray;
    } catch (error) {
      console.error("Error in checkInputValidation: ", error);
    }
  };

  /**
   * @function - handleIsPregnantChange().
   * @description - this method is used to handle value changes to isPregnant field.
   * @param {*} event - On change of IsPregnant field.
   */
  handleIsPregnantChange = event => {
    try {
      const value = event.detail.value;
      if (value === constants.toggleFieldValue.no) {
        this.showExpectedDueDate = false;
        this.showLastPregnancyDate = true;
        this.isPregnant = constants.toggleFieldValue.no;
      } else if (value === constants.toggleFieldValue.yes) {
        this.showExpectedDueDate = true;
        this.showLastPregnancyDate = false;
        this.isPregnant = constants.toggleFieldValue.yes;
      }
      this.updatedMember[IS_PREGNANT.fieldApiName] = value;
    } catch (error) {
      console.error("Error in handleIsPregnantChange: ", error);
    }
  };

  /**
   * @function - handleExpectedBirthCountChange().
   * @description - This method is used to handle value changes to ExpectedBirthNumber field.
   * @param {*} event - On change of Expected Birth Count Change.
   */
  handleExpectedBirthCountChange = event => {
    try {
      const value = event.target.value;
      this.updatedMember[BIRTHS_EXPECTED.fieldApiName] = value;
    } catch (error) {
      console.error("Error in handleExpectedBirthCountChange: ", error);
    }
  };
  /**
   * @function - handleDueDateChange().
   * @description - this method is used to handle value changes to ExpectedDueDate field.
   * @param {*} event - On change of Expected Due Date.
   */
  handleDueDateChange = event => {
    try {
      const value = event.target.value;
      this.sOverlappingDateErroMsg = "";
      this.updatedMember[PREGNANCY_DUE_DATE.fieldApiName] = value;
      event.target.classList.remove("has-overlapping-error");
    } catch (error) {
      console.error("Error in handleDueDateChange: ", error);
    }
  };
  /**
   * @function - handleTermDateChange().
   * @description - this method is used to handle value changes to TerminationDate field.
   * @param {*} event - On change of Termination Date.
   */
  handleTermDateChange = event => {
    try {
      const value = event.target.value;
      this.updatedMember[PREGNANCY_TERMINATION_DATE.fieldApiName] = value;
    } catch (error) {
      console.error("Error in handleTermDateChange: ", error);
    }
  };

  /**
   * @function - updateLabels().
   * @description - this method is used to update Member Name dynamically.
   */
  updateLabels = () => {
    try {
      const name = [
        getFieldValue(this.record, MEMBER_FIRST_NAME),
        getFieldValue(this.record, MEMBER_LAST_NAME)
      ]
        .filter(item => !!item)
        .join(" ");
      this.sspCompleteQuestionsAboutPregnancyReplaced = sspCompleteQuestionsAboutPregnancy.replace(
        unicorn0,
        name
      );

      this.sspIsPregnantReplaced = sspIsPregnant.replace(unicorn0, name);

      this.sspReferralForWomenReplaced = sspReferralForWomen.replace(
        unicorn0,
        name
      );
    } catch (error) {
      console.error("Error in updateLabels: ", error);
    }
  };

  /**
   * @function - handleSave().
   * @description - This method is used to save/update the record.
   */
  handleSave = () => {
    try {
      const updatedMember = {};
      const pregnantInput = this.template.querySelector(".ssp-inputIsPregnant");
      const expectedCountInput = this.template.querySelector(
        ".ssp-inputExpectedCount"
      );
      const dueDateInput = this.template.querySelector(".ssp-inputDueDate");
      const termDateInput = this.template.querySelector(".ssp-inputTermDate");
      const wICInput = this.template.querySelector(".ssp-inputWIC");
      updatedMember.Id = this.memberId;
      if (pregnantInput) {
        if (!pregnantInput.value) {
          updatedMember[pregnantInput.fieldName] = null;
        } else {
          updatedMember[pregnantInput.fieldName] = pregnantInput.value;
        }
      }
      if (expectedCountInput) {
        updatedMember[expectedCountInput.fieldName] = expectedCountInput.value;
      }
      if (dueDateInput) {
        if (pregnantInput.value === constants.toggleFieldValue.yes) {
          updatedMember[PREGNANCY_DUE_DATE.fieldApiName] = dueDateInput.value;
        } else {
          updatedMember[PREGNANCY_DUE_DATE.fieldApiName] = null;
        }
      } else if (!dueDateInput) {
        updatedMember[PREGNANCY_DUE_DATE.fieldApiName] = null;
      }

      if (termDateInput) {
        if (pregnantInput.value === constants.toggleFieldValue.no) {
          updatedMember[PREGNANCY_TERMINATION_DATE.fieldApiName] =
            termDateInput.value;
          this.createTrackDeletionHelper();
        } else {
          updatedMember[PREGNANCY_TERMINATION_DATE.fieldApiName] = null;
        }
      } else if (!termDateInput) {
        updatedMember[PREGNANCY_TERMINATION_DATE.fieldApiName] = null;
      }
      if (wICInput) {
        if (!wICInput.value) {
          updatedMember[wICInput.fieldName] = null;
        } else {
          updatedMember[wICInput.fieldName] = wICInput.value;
        }
      }
      updateRecord({ fields: updatedMember }).then(
        () => refreshApex(this.wiredRecord),
        error => console.error("Error in saving: ", error)
      );
      this.showSpinner = false;
      this.saveCompleted = true;
    } catch (error) {
      console.error("Error in handleSave: ", error);
    }
  };

  createTrackDeletionHelper = () => {
    createTrackDeletion({
      applicationId: this.applicationId,
      memberId: this.memberId
    })
      .then(response => {
        const { error } = response;
        if (error) {
          console.error("Error in createTrackDeletionHelper: ", error);
        }
      })
      .catch(error => {
        console.error("Catch in createTrackDeletionHelper: ", error);
      });
  };

  /**
   * @function - pregnancyDueDateValidator().
   * @description - this method is used to validate Expected Due date field.
   * It shouldn't be more than 9 months from now.
   * @param {*} event - On focus out of Expected Due Date field.
   */
  pregnancyDueDateValidator = event => {
    try {
      const dueDateInput = this.template.querySelector(".ssp-inputDueDate");
      const selectedDate = new Date(event.target.value);
      if (selectedDate) {
        const selectedDateValue = new Date(
          selectedDate.getFullYear(),
          selectedDate.getMonth(),
          selectedDate.getDate()
        );
        const currentDateValue = this.currentMonthValue;
        const dateElements = currentDateValue.split("-");
        const todayDate = new Date(
          dateElements[0],
          dateElements[1] - 1,
          dateElements[2]
        );
        todayDate.setMonth(todayDate.getMonth() + 9);
        if (selectedDateValue > todayDate) {
          dueDateInput.ErrorMessageList = [sspPregnancyDueDateValidator];
        } else if (dueDateInput.ErrorMessageList) {
          dueDateInput.ErrorMessageList = dueDateInput.ErrorMessageList.filter(
            message => message !== sspPregnancyDueDateValidator
          );
        }
      }
    } catch (error) {
      console.error("Error in pregnancyDueDateValidator: ", error);
    }
  };

  /**
   * @function - RACPregnancyValidator().
   * @description - This method is used to validate Termination date value.
   * It shouldn't be less than start date of pregnancy.
   * @param {*} event - On focus out of Termination date.
   */
  RACPregnancyValidator = event => {
    try {
      const selectedDate = new Date(event.target.value);
      const expectedDueDate = this.expectedDueDate;
      if (expectedDueDate) {
        const dateElements = expectedDueDate.split("-");
        const startDate = new Date(
          dateElements[0],
          dateElements[1],
          dateElements[2]
        );
        startDate.setMonth(startDate.getMonth() - 10);
        const TermDateInput = this.template.querySelector(".ssp-inputTermDate");
        if (selectedDate <= startDate) {
          TermDateInput.ErrorMessageList = [sspRACPregnancyValidator];
        } else if (TermDateInput.ErrorMessageList) {
          TermDateInput.ErrorMessageList = TermDateInput.ErrorMessageList.filter(
            message => message !== sspRACPregnancyValidator
          );
        }
      }
    } catch (error) {
      console.error("Error in RACPregnancyValidator: ", error);
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
   * @param {*} caseNumber - Contains caseNumber.
   */
  getOverlappingServiceData (
    dcId,
    identifier,
    valueData,
    startDate,
    endDate,
    individualId,
    applicationId,
    caseNumber
  ) {
      this.showSpinner = true;
      const dueDateInput = this.template.querySelector(".ssp-inputDueDate");
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
                      "/" +
                      endDateSplit[2] +
                      "/" +
                      endDateSplit[0]
                    : "";
              }
              this.sOverlappingDateErroMsg = this.label.sspPregnancyOverlappingDateValidator.replace(
                "{0}",
                endDate
              );
              dueDateInput.classList.add("has-overlapping-error");
              this.hasSaveValidationError = true;
              this.showSpinner = false;
            } else if (valueData !== undefined && valueData !== "") {
                this.sOverlappingDateErroMsg = "";
                dueDateInput.classList.remove("has-overlapping-error");
              this.handleSave();
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
    dcId,
    identifier,
    startDate,
    endDate,
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
          if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
              const {securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
              if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                  this.isPageAccessible = true;
              }
              else {
                  this.isPageAccessible = !(securityMatrix.screenPermission === constants.permission.notAccessible);
              }
              this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
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
