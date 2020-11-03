/*
 * Component name  : sspBaseComponentInputCheckbox
 * @description    : Generic component for Input check box
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";
import sspUtility from "c/sspUtility";

export default class sspBaseComponentInputCheckbox extends LightningElement {
    @api entityName;
    @api fieldName;
    @api recordId;
    @api handleChange = false;
    @api label;
    @api customValidationError = [];
    @api title = "";
    @api required;
    @api className = "";
    @api value;
    @api inputValue;
    @api disabled;

    @api oldValue = "";

    @track hasError;
    @api ErrorMessageList = [];
    @track ErrorMsgList = [];
    @track metaListValues;
    @track name = "";

  @api
  get metaList () {
    return this.metaListValues;
  }
  set metaList (value) {
    try {
      this.metaListValues = value;
    } catch (error) {
      console.error("Error in metaList", error);
    }
  }

  /*
   * @function : handleValidations
   * @description : This method is used to handle the checkbox validations.
   * @param {event}
   */
  handleValidations = event => {
    try {
      const valueReceived = event.target.checked;
      const inputVal = valueReceived;
      const errorMessageList = [];
      let fetchedList;
      this.value = event.target.checked;
            if (!sspUtility.isUndefinedOrNull(this.fieldName) &&
                !sspUtility.isUndefinedOrNull(this.entityName) &&
                this.fieldName !== "" && this.entityName !== "") {
                fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];
                }
            
            if (
                fetchedList !== null &&
                fetchedList !== undefined &&
                fetchedList.Input_Required__c
            ) {
        const msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(
          inputVal,
          valueReceived,
          errorMessageList,
          msg
        );
      }
      if (this.handleChange) {
        const selectedEvent = new CustomEvent(events.handleChange, {
          detail: this.value
        });
        this.dispatchEvent(selectedEvent);
      }
    } catch (error) {
      console.error("Error in Validation method: ", error);
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to check for the error message list.
   */
  @api
  ErrorMessages () {
    try {
      const valueReceived = this.value;

      const errorMessageList = this.ErrorMessageList;

      let fetchedList;
      if (
        this.metaListValues !== undefined &&
        this.fieldName !== undefined &&
        this.entityName !== undefined
      ) {
        fetchedList = this.metaListValues[
          this.fieldName + "," + this.entityName
        ];
      }
      const inputVal = this.value;

      if (
        fetchedList !== undefined &&
        fetchedList !== null &&
        fetchedList.Input_Required__c
      ) {
        const msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(
          inputVal,
          valueReceived,
          errorMessageList,
          msg
        );
      }

      const errorList =
        this.ErrorMessageList !== undefined && this.ErrorMessageList.length > 0
          ? this.ErrorMessageList
          : this.customValidationError !== undefined &&
            this.customValidationError.length > 0
          ? this.customValidationError
          : undefined;
      return errorList;
    } catch (error) {
      console.error("Error in ErrorMessages", error);
      return null;
    }
  }

  /*
   * @function : getMetadataRecord
   * @description : This method is used to check for the required property.
   */
  getMetadataRecord = () => {
    try {
      const metadataList = this.metaListValues;
      if (
        metadataList[this.fieldName + "," + this.entityName].Input_Required__c
      ) {
        this.required = true;
      }
    } catch (error) {
      console.error("Error in getMetadataRecord", error);
    }
  };

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputText, valueReceived, errorMessageList, msg}
   */
  handleRequiredValidation = (
    inputText,
    valueReceived,
    errorMessageList,
    msg
  ) => {
    try {
      this.required = true;
      const requiredValue = this.required;
      if (requiredValue && !inputText && !valueReceived) {
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
      console.error("Error in handleRequiredValidation", error);
    }
  };

    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
        const elem = this.template.querySelector(
            ".ssp-checkbox"
        );
        if (this.disabled && elem) {
            elem.classList.add("ssp-disabled-checkbox");
        }
    }

    /*
     * @function : setOldValue()
     * @description : This method is use to set the old value.
     * @param {String} newValue - New value.
     * @param {String} oldValue - Old value.
     */
    setOldValue = (newValue, oldValue) => {
        let oldValueReceived = oldValue;
        if (newValue !== undefined && oldValue === "") {
            oldValueReceived = newValue;
        } else if (oldValueReceived === "" || oldValueReceived === undefined || oldValueReceived === null) {
            oldValueReceived = false;
        }
        return oldValueReceived;
    };
   
}