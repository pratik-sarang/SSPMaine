/*
 * Component Name: sspBaseComponentInputSelect
 * Author: Shikha
 * Description: This screen is used for select input field.
 * Date: 1/3/2019.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";
import sspSelect from "@salesforce/label/c.SSP_Select";

export default class baseComponentInputSelect extends LightningElement {
  @api name = "";
  @api label = "";
  @api title = "";
  @api required;
  @api className = "";
  @api handleChange = false;
  @api value = "";
  @api option;
  @api fieldName;
  @api entityName;
  @api disabled;
  @api oldValue = "";
  @track ErrorMessageList = [];
  @track changedValue = "";
  @track ErrorMsgList = [];
  @track metadataListRecords;
  label = { sspSelect };

  /**
   * @function : metaList
   * @description : Getter setters for metadata list.
   */
  @api
  get metaList () {
    return this.metaListValues;
  }
  set metaList (value) {
    this.metaListValues = value;
    if (value !== undefined) {
      this.getMetadataRecord();
    }
  }

  get isDisabled () {
    let isDisabled = this.disabled;
    try {
      const metaList = this.metaListValues;
      if (metaList != null && this.metaList != undefined &&
        this.fieldName != null && this.fieldName != undefined &&
        this.entityName != null && this.entityName != undefined &&
        metaList[this.fieldName + "," + this.entityName] != null && metaList[this.fieldName + "," + this.entityName] != undefined) {
        const fieldDisability = metaList[this.fieldName + "," + this.entityName].isDisabled;
        isDisabled = (fieldDisability != null && fieldDisability != undefined) ? (isDisabled || fieldDisability) : isDisabled;
      }
    } catch (error) {
      console.error("Error in sspCaseComponentInputSelect.isDisabled", error);
    }

    return isDisabled;
  }

  /**
   * @function : handleValidations
   * @description :This method is used to handle validations.
   * @param {event} event - Event details.
   */
  handleValidations = event => {
    try {
      this.value = event.srcElement.value;
      const inputVal = event.srcElement.value;

      const valueReceived = this.value;

      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];

      if (fetchedList !== null && fetchedList !== "undefined") {
        if (fetchedList.Input_Required__c) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
      }
      if (this.handleChange) {
        const selectedEvent = new CustomEvent(events.handleChange, {
          detail: this.value
        });
        this.dispatchEvent(selectedEvent);
      }
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.handleValidations " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : handleOnchangeValidations
   * @description :This method is used to  handleOnchangeValidations.
   * @param {event} event - Event details.
   */
  handleOnchangeValidations = event => {
    try {
      const changedVal = this.value;
      this.changedValue = changedVal;
      this.value = event.srcElement.value;
      const inputVal = event.srcElement.value;

      const valueReceived = event.srcElement.value;

      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];

      if (fetchedList !== null && fetchedList !== "undefined") {
        if (fetchedList.Input_Required__c) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
      }
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.handleOnchangeValidations " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : ErrorMessages
   * @description :This method is used to handle error messages.
   */
  @api
  ErrorMessages () {
    try {
      let msg;
      const valueReceived = this.value;
      const inputVal = valueReceived;
      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];
      if (fetchedList !== null && fetchedList !== "undefined") {
        if (fetchedList.Input_Required__c) {
          msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
      }

      const errorList = this.ErrorMessageList;

      return errorList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.ErrorMessages " +
          JSON.stringify(error)
      );
      return null;
    }
  }

  /**
   * @function : getMetadataRecord
   * @description :This method is used to getMetadataRecord.
   */
  getMetadataRecord = () => {
    try {
      const picklistOptions = this.option;
      const picklistLabelValue = [];
      picklistLabelValue.push({
        label: this.label.sspSelect,
        value: this.label.sspSelect
      });

      picklistOptions.forEach(function (key) {
        picklistLabelValue.push({
          label: picklistOptions[key].label,
          value: picklistOptions[key].value
        });
      });
      this.option = picklistLabelValue;

      const metadataList = this.metaListValues;
      this.metadataListRecords = metadataList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.getMetadataRecord " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : OnChangedValues
   * @description :This method is used to return changed values.
   */
  OnChangedValues = () => {
    try {
      return this.changedValue;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.OnChangedValues " +
          JSON.stringify(error)
      );
      return null;
    }
  };

  /**
   * @function : handleRequiredValidation
   * @description :This method is used to handleRequiredValidation.
   * @param {string}inputText - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  handleRequiredValidation = (
    inputText,
    valueReceived,
    errorMessageList,
    msg
  ) => {
    try {
      const requiredValue = true;
      if (
        requiredValue &&
        (inputText === "" || inputText === undefined || inputText === "Select")
      ) {
        if (errorMessageList.indexOf(msg) === -1) {
          errorMessageList.push(msg);
        }
      } else {
        if (errorMessageList.indexOf(msg) > -1) {
          errorMessageList.splice(errorMessageList.indexOf(msg), 1);
        }
      }

      this.ErrorMessageList = errorMessageList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSelect.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  };

    /*
    * @function : renderedCallback()
    * @description : This method is called when component gets rendered.
    */
   renderedCallback () {        
    this.oldValue = this.setOldValue(this.value, this.oldValue);       
  }

  /*
  * @function : setOldValue()
  * @description : This method is use to set the old value.
  * @param {String} newValue - New value.
  * @param {String} oldValue - Old value.
  */
  setOldValue = (newValue, oldValue) => {
    let oldValueReceived = oldValue
      if(newValue !== undefined && oldValue === "") {
        oldValueReceived = newValue;
      }
      return oldValueReceived;
  }
}