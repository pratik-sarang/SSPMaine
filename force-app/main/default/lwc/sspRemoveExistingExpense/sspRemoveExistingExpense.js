/**
 * Component Name: sspRemoveExistingExpense.
 * Author: Yathansh Sharma, Chirag Garg.
 * Description: This screen gives the user an option to mark an existing expense as no longer valid.
 * Date: 11/28/2019.
 */
import { api, wire, track } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import sspConstants from "c/sspConstants";

import MEMBER_NAME from "@salesforce/schema/SSP_Member__c.Name";
import MEMBER_FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import MEMBER_LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import fetchExistingExpenseDetails from "@salesforce/apex/SSP_ExpenseController.fetchExistingExpenseDetails";
import ID_FIELD from "@salesforce/schema/SSP_Asset__c.Id";
import ENDDATE_FIELD from "@salesforce/schema/SSP_Asset__c.EndDate__c";
import DELETED_FIELD from "@salesforce/schema/SSP_Asset__c.IsDeleted__c";
import sspDoes from "@salesforce/label/c.SSP_Does";
import sspNoLongerExpense from "@salesforce/label/c.SSP_NoLongerExpense";
import sspExpenseEndDate from "@salesforce/label/c.SSP_ExpenseEndDate";
import sspStillHasAboveExpense from "@salesforce/label/c.SSP_StillHasAboveExpense";
import sspDollarSign from "@salesforce/label/c.SSP_DollarSign";
import sspForwardSlash from "@salesforce/label/c.SSP_forwardSlash";
import errorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspDoesNoLongerExpense from "@salesforce/label/c.SSP_DoesNoLongerExpense";
import utility,{ formatLabels } from "c/sspUtility";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspHigherEducation from "@salesforce/label/c.SSP_HigherEducation";
import getApplicationIndividualRecord from "@salesforce/apex/SSP_ResourcesService.getApplicationIndividualForMember";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVOWNSEXPENSE_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsMemberStillOwnsExpenses__c";

export default class sspRemoveExistingExpense extends BaseNavFlowPage {
  @api memberId;
  @api applicationId;

  /**
   * @function : Getter setters for member Id.
   * @description : Getter setters for member Id.
   */
  get memberId () {
    try {
      return this.memberIdValue;
    } catch (error) {
      console.error(
        sspConstants.removeExistResourceConstants.resourceRemovalError
          .getMemberId + JSON.stringify(error.message)
      );
      return null;
    }
  }
  set memberId (value) {
    try {
      this.memberIdValue = value;
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.getApplicationIndividualDetails();
      }
    } catch (error) {
      console.error(
        sspConstants.removeExistResourceConstants.resourceRemovalError
          .setMemberId + JSON.stringify(error.message)
      );
    }
  }

  @track memberName;
  @track expenseList = [];
  @track expenseCallResult;
  @track showSkipAll = true;
  @track skipAll = false;
  @track stillExpenseLabel;
  @track doesNoLongerLabel;
  @track showMetadata = false;
  @track hasScreenError = false;
  @track customError = "";
  @track timeTravelDate;
  @track appIndividualRecordId;
  @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

  label = {
    errorMessage,
    sspDoes,
    sspNoLongerExpense,
    sspExpenseEndDate
  };

  /*
   * @function : connectedCallback
   * @description : This method is used to select the validation metadata.
   */
  connectedCallback () {
    try {
      //construction of fieldEntityNameList to retrieve validation related metadata
      const fieldEntityNameList = [];
      fieldEntityNameList.push("EndDate__c,SSP_Asset__c");
      this.getMetadataDetails(
        fieldEntityNameList,
        null,
        "SSP_APP_Details_RemoveExistingExpense"
      ); //calling base cmp method
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /*
   * @function : getApplicationIndividualDetails
   * @description : This method used to get existing application individual details.
   */
  getApplicationIndividualDetails = () => {
    try {
      /* @sApplicationId {applicationId} applicationId.
       * @sMemberId {memberId} memberId.
       * @returns { String JSON } Returns a string JSON with existing applicationIndividual details.
       */
      getApplicationIndividualRecord({
        sApplicationId: this.applicationId,
        sMemberId: this.memberId
      })
        .then(result => {
          this.skipAll = !utility.isArrayEmpty(result)
            ? result[0].IsMemberStillOwnsExpenses__c
            : true;
          this.appIndividualRecordId = !utility.isArrayEmpty(result)
            ? result[0].Id
            : null;
          if (this.skipAll) {
            this.hasScreenError = false;
          }
        })
        .catch(error => {
          console.error(
            sspConstants.removeExistResourceConstants.resourceRemovalError
              .getExistingResources + JSON.stringify(error.message)
          );
        });
    } catch (error) {
      console.error(
        sspConstants.removeExistResourceConstants.resourceRemovalError
          .getExistingResources + JSON.stringify(error.message)
      );
    }
  };

  /*
   * @function : memberNameSetter
   * @description : This method is used to get the name of the member for whom expenses list will be displayed.
   * @param wireResponseObj
   */
  @wire(getRecord, {
    recordId: "$memberId",
    fields: [MEMBER_NAME, MEMBER_FIRST_NAME, MEMBER_LAST_NAME]
  })
  memberNameSetter ({ error, data }) {
    try {
      if (data) {
        this.memberName =
          getFieldValue(data, MEMBER_FIRST_NAME) +
          " " +
          getFieldValue(data, MEMBER_LAST_NAME);
        this.stillExpenseLabel = formatLabels(sspStillHasAboveExpense, [
          this.memberName
        ]);
        this.doesNoLongerLabel = formatLabels(sspDoesNoLongerExpense, [
          this.memberName
        ]);
      } else {
        console.error(error);
      }
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  setDataForTest (respObj) {
    this.expenseCallResult = respObj;
    this.expenseList = [];
    if (this.expenseCallResult && this.expenseCallResult.data) {
      const respData = this.expenseCallResult.data.mapResponse.expenseRecords;
      const expTypes = this.expenseCallResult.data.mapResponse.expenseTypes;
      const expSubTypeCode = this.expenseCallResult.data.mapResponse
        .expenseSubTypes;
      const expenseFrequencies = this.expenseCallResult.data.mapResponse
        .expenseFrequencies;
      this.timeTravelDate = this.expenseCallResult.data.mapResponse.timeTravelDate;
      for (let i = 0; i < respData.length; i++) {
        let lineOne = "",
          showData = false,
          lineTwo = "",
          currentExpenseFreq = "";
        if (
          null !== expSubTypeCode[respData[i].ExpenseSubType__c] &&
          expSubTypeCode[respData[i].ExpenseSubType__c] !== undefined
        ) {
          lineOne = expSubTypeCode[respData[i].ExpenseSubType__c];
        } else {
          lineOne = expTypes[respData[i].ExpenseTypeCode__c];
        }
        currentExpenseFreq =
          null != expenseFrequencies[respData[i].ExpenseFrequencyCode__c] &&
          expenseFrequencies[respData[i].ExpenseFrequencyCode__c] !== undefined
            ? sspForwardSlash +
              expenseFrequencies[respData[i].ExpenseFrequencyCode__c]
            : "";
        if (
          respData[i].ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE &&
          respData[i].ExpenseAmount__c != null &&
          respData[i].ExpenseAmount__c !== undefined
        ) {
          lineTwo =
            respData[i].ExpenseAmount__c.toString().indexOf(".") > -1
              ? sspDollarSign +
                parseFloat(respData[i].ExpenseAmount__c)
                  .toFixed(2)
                  .toLocaleString() +
                currentExpenseFreq
              : sspDollarSign +
                respData[i].ExpenseAmount__c.toLocaleString() +
                ".00" +
                currentExpenseFreq;
        }

        const expenseLineTwoEE =
          null != respData[i].ExpenseTypeCode__c &&
          respData[i].ExpenseTypeCode__c !== undefined &&
          respData[i].ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE
            ? respData[i].ExpenseAmount__c
            : [
                respData[i].TuitionAmount__c,
                respData[i].BooksAmount__c,
                respData[i].FeesAmount__c,
                respData[i].MiscellaneousAmount__c
              ].reduce(function (total, number) {
                if (number !== undefined && number !== null && number !== "") {
                  return total + number;
                }
                return total;
              }, null);
        if (
          respData[i].ExpenseTypeCode__c === sspConstants.expenseTypeCodes.EE
        ) {
          if (null != expenseLineTwoEE) {
            lineTwo = sspDollarSign + parseFloat(expenseLineTwoEE).toFixed(2);
          } else {
            lineTwo = "";
          }
          lineOne = sspHigherEducation;
        }

        if (!respData[i].IsExistingData__c) {
          showData = true;
        } else {
          showData = respData[i].IsExistingData__c;
        }

        if (showData) {
          this.expenseList.push({
            Id: respData[i].Id,
            position: i,
            checkBoxEnabled: false,
            metaDataList: this.MetadataList,
            endDate: respData[i].EndDate__c,
            frequency: expenseFrequencies[respData[i].ExpenseFrequencyCode__c],
            lineOne: lineOne,
            lineTwo: lineTwo
          });
        }
      }
    }
  }

  /*
   * @function : generateExpenseList
   * @description : This method is used to create a wrapper of the data that needs to be displayed.
   * @param wireResponseObj
   */
  @wire(fetchExistingExpenseDetails, {
    sspMemberId: "$memberId",
    sspApplicationId: "$applicationId",
    callingComponent: "sspRemoveExistingExpense"
  })
  generateExpenseList (respObj) {
    if (respObj.data !== undefined) {
      if (
        localStorage.getItem(
          "SSP_APP_Details_RemoveExistingExpense_executed"
        ) === "true"
      ) {
        localStorage.setItem(
          "SSP_APP_Details_RemoveExistingExpense_executed",
          "false"
        );
        this.setDataForTest(respObj);
        refreshApex(respObj);
      } else {
        try {
          this.setDataForTest(respObj);
        } catch (err) {
          console.error("Remove existing expense (connectedCallback): " + err);
        }
      }
    } else {
      console.error(respObj.error);
    }
  }

  /*
   * @function : enableExpenseDate
   * @description : This method is used to show the date field for any checked expense.
   * @param event
   */
  enableExpenseDate (event) {
    try {
      this.expenseList[event.target.dataset.position].checkBoxEnabled =
        event.target.value;
      this.showSkipAll = true;
      for (let i = 0; i < this.expenseList.length; i++) {
        if (this.expenseList[event.target.dataset.position].checkBoxEnabled) {
          this.hasScreenError = false;
          this.showSkipAll = false;
          if (this.template.querySelector(".ssp-remove-expense-form")) {
            this.template
              .querySelector(".ssp-remove-expense-form")
              .classList.remove("ssp-checkbox-error");
          }
          break;
        }
      }
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /*
   * @function : initSaveProcess
   * @description : This method is used to iterate over the selected data and check which records needs to be updated.
   */
  initSaveProcess () {
    try {
      if (!this.skipAll) {
        const updateList = this.template.querySelectorAll(
          ".ssp-selector-class"
        );
        for (let i = 0; i < updateList.length; i++) {
          if (
            this.expenseList[updateList[i].dataset.position] !== undefined &&
            this.expenseList[updateList[i].dataset.position].checkBoxEnabled
          ) {
            this.updateDateInSF(
              this.expenseList[updateList[i].dataset.position].Id,
              updateList[i].value
            );
          }
        }
      }
      const appIndividualRecord = {};
      appIndividualRecord[
        APPLICATIONINDIVID_FIELD.fieldApiName
      ] = this.appIndividualRecordId;
      appIndividualRecord[
        APPLICATIONINDIVOWNSEXPENSE_FIELD.fieldApiName
      ] = !utility.isUndefinedOrNull(this.skipAll) ? this.skipAll : false;

      const recordInput = {};
      recordInput.fields = appIndividualRecord;

      //lwc standard updateRecord call to update application individual record
      updateRecord(recordInput)
        .then(() => {
          this.saveCompleted = true;
        })
        .catch(error => {
          console.error("error occurred" + JSON.stringify(error));
        });
      this.saveCompleted = true;
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  disconnectedCallback () {
    localStorage.setItem(
      "SSP_APP_Details_RemoveExistingExpense_executed",
      "true"
    );
  }

  /*
   * @function : saveData
   * @description : This method is used to check validations and sets the list of inputs for framework.
   */
  saveData () {
    try {
      this.validateInputEntry();
      if (!this.hasScreenError) {
        const templateAppInputs = this.template.querySelectorAll(
          ".ssp-selector-class"
        );
        this.templateInputsValue = templateAppInputs;
      }
      else {
        const showToastEvent = new CustomEvent("showcustomtoast", {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(showToastEvent);
        this.templateInputsValue = "invalid";
      }
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /*
   * @function : validateInputEntry
   * @description : This method is used to implement custom validations for the screen.
   */
  validateInputEntry () {
    try {
      if (this.skipAll) {
        this.hasScreenError = false;
        if (this.template.querySelector(".ssp-remove-expense-form")) {
          this.template
            .querySelector(".ssp-remove-expense-form")
            .classList.remove("ssp-checkbox-error");
        }
      } else {
        let validationSuccess = false;
        for (let i = 0; i < this.expenseList.length; i++) {
          validationSuccess =
            this.expenseList[i].checkBoxEnabled || validationSuccess;
        }

        if (!validationSuccess) {
          this.hasScreenError = true;
          this.customError = this.label.errorMessage;
          if (this.template.querySelector(".ssp-remove-expense-form")) {
            this.template
              .querySelector(".ssp-remove-expense-form")
              .classList.add("ssp-checkbox-error");
          }
        } else {
          this.hasScreenError = false;
          this.customError = "";
          if (this.template.querySelector(".ssp-remove-expense-form")) {
            this.template
              .querySelector(".ssp-remove-expense-form")
              .classList.remove("ssp-checkbox-error");
          }
        }
      }
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /*
   * @function : updateDateInSF
   * @description : This method updates the date of record in salesforce.
   * @param sfId
   * @param dateValue
   */
  updateDateInSF (sfId, dateValue) {
    try {
      const fields = {};
      fields[ID_FIELD.fieldApiName] = sfId;
      fields[ENDDATE_FIELD.fieldApiName] = dateValue;
      fields[DELETED_FIELD.fieldApiName] = true;
      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => true)
        .catch(error => {
          console.error(error);
        });
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /*
   * @function : updateSkipAll
   * @description : This method updates the skip all variable.
   * @param event
   */
  updateSkipAll (event) {
    try {
      this.skipAll = event.target.value;
      if (this.skipAll) {
        this.hasScreenError = false;
        if (this.template.querySelector(".ssp-remove-expense-form")) {
          this.template
            .querySelector(".ssp-remove-expense-form")
            .classList.remove("ssp-checkbox-error");
        }
      }
    } catch (err) {
      console.error("Remove existing expense (connectedCallback): " + err);
    }
  }

  /**
   * Framework related variables.
   */
  @track actionValue;
  @track nextValue;
  @track validationFlag;
  @track MetaDataListParent;
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  set MetadataList (value) {
    if (value !== null && value !== undefined) {
      this.MetaDataListParent = value;
      this.showMetaData = true;

      //CD2 2.5	Security Role Matrix and Program Access.                
      if (Object.keys(value).length > 0){
        this.constructRenderingMap(null, value); 
      }
    }
  }

  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    if (value !== undefined && value !== "") {
      this.nextValue = value;
      this.saveData();
    }
  }

  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    this.validationFlag = value;
    if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
      this.initSaveProcess();
    }
  }

  /**
   * @function : renderedCallback
   * @description : Rendered on load of removal of existing income page.
   */
  renderedCallback () {
    try {
      const ownsCheckboxValue = this.template.querySelector(
        ".ssp-ownsExpenseCheckbox"
      );
      if (!utility.isUndefinedOrNull(ownsCheckboxValue)) {
        ownsCheckboxValue.isChecked = this.skipAll;
      }
    } catch (error) {
      console.error(
        "Error occurred in rendered Callback" + JSON.stringify(error.message)
      );
    }
  }

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