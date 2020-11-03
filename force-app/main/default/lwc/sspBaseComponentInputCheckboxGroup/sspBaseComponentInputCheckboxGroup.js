/*
 * Component name  : sspBaseComponentInputCheckboxGroup
 * @description    : Generic component for Input check box Group.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";

export default class sspBaseComponentInputCheckboxGroup extends LightningElement {
    @api recordId;
    @api label;
    @api entityName;
    @api value = [];
    @api fieldName;
    @api required;
    @api title = "";
    @api className = "";
    @api handleChange = false;
    @track FieldValidationList = [];
    @track hasError;
    @api ErrorMessageList = [];
    @api disabled;
    @track ErrorMsgList = [];
    @track metaListValues;
    @api oldValue = "";
    @api options;

  /*
   * @function : handleValidations
   * @description : This method is used to handle the checkbox group validations.
   * @param {event}
   */
  handleValidations = event => {
    try {
      let msg;
      const inputVal =
        event.detail.value !== undefined && event.detail.value !== null
          ? event.detail.value
          : "";

      const errorMessageList = this.ErrorMessageList;
      this.value = inputVal;
      this.valueReceived = inputVal;

      const fetchedList =
        this.metaListValues !== undefined && this.metaListValues !== null
          ? this.fieldName !== null && this.fieldName !== undefined
            ? this.entityName !== null && this.entityName !== undefined
              ? this.metaListValues[this.fieldName + "," + this.entityName]
              : null
            : null
          : null;
      if (
        fetchedList !== null &&
        fetchedList !== undefined &&
        fetchedList.Input_Required__c
      ) {
        msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(inputVal, errorMessageList, msg);
      }
      if (this.handleChange) {
        const selectedEvent = new CustomEvent(events.handleChange, {
          detail: this.value
        });
        this.dispatchEvent(selectedEvent);
      }
            if (this.ErrorMessageList.length){
                if (this.template.querySelector(".ssp-checkboxGroup")){
                    this.template.querySelector(".ssp-checkboxGroup").classList.add("ssp-checkbox-error");
                }
            }
            else{
                if (this.template.querySelector(".ssp-checkboxGroup")) {
                    this.template.querySelector(".ssp-checkboxGroup").classList.remove("ssp-checkbox-error");
                }
            }
    } catch (error) {
      console.error("Error in handleValidations: ", error);
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to check for the error message list.
   */
  @api ErrorMessages () {
    try {
      const inputVal = this.value;
      let msg;

      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];

      if (
        fetchedList !== null &&
        fetchedList !== undefined &&
        fetchedList.Input_Required__c
      ) {
        msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(inputVal, errorMessageList, msg);
      }

      const errorList = this.ErrorMessageList;
            if (this.ErrorMessageList.length) {
                if (this.template.querySelector(".ssp-checkboxGroup")) {
                    this.template.querySelector(".ssp-checkboxGroup").classList.add("ssp-checkbox-error");
                }
            }
            else {
                if (this.template.querySelector(".ssp-checkboxGroup")) {
                    this.template.querySelector(".ssp-checkboxGroup").classList.remove("ssp-checkbox-error");
                }
            }
      return errorList;
    } catch (error) {
      console.error("Error in ErrorMessages: ", error);
      return null;
    }
  }

  @api
  get metaList () {
    return this.metaListValues;
  }
  set metaList (value) {
    try {
      this.metaListValues = value;
    } catch (error) {
      console.error("Error in metaList: ", error);
    }
  }

  /*
   * @function : handleAllowOnly1Selection
   * @description : This method is used to let you select only one value.
   * @param    {event}
   */
  handleAllowOnly1Selection = event => {
    try {
      let oldValue;
      let newValue;
      let result;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];
      if (fetchedList.Allow_Only_1_Selection__c) {
        oldValue = event.detail.oldValue;
        newValue = event.detail.value;

        if (oldValue.length < newValue.length) {
          result = this.getDifference(oldValue, newValue);
          this.value = result;
          this.handleAllowOnly1Selection(this.value);
        }
      }
    } catch (error) {
      console.error("Error in handleAllowOnly1Selection method: ", error);
    }
  };

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputText, valueReceived, errorMessageList, msg}
   */
  @api
  handleRequiredValidation (inputVal, errorMessageList, msg) {
    try {
      this.required = true;

      if (this.required && (inputVal.length === 0||inputVal === "[]")) {
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
      console.error("Error in handleRequiredValidation method: ", error);
    }
  }

  /*
   * @function : getDifference
   * @description : This method is used to handle the change in list of selected values.
   * @param    {oldValue, newValue}
   */
  @api
  getDifference (oldValue, newValue) {
    try {
      const result = [];
      let i;
      for (i = 0; i < newValue.length; i++) {
        if (oldValue.indexOf(newValue[i]) === -1) {
          result.push(newValue[i]);
        }
      }
      for (i = 0; i < oldValue.length; i++) {
        if (newValue.indexOf(oldValue[i]) === -1) {
          result.push(oldValue[i]);
        }
      }

      return result;
    } catch (error) {
      console.error("Error in getDifference Method: ", error);
      return null;
    }
  }
    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
        if (this.ErrorMessageList.length) {
            if (this.template.querySelector(".ssp-checkboxGroup")) {
                this.template.querySelector(".ssp-checkboxGroup").classList.add("ssp-checkbox-error");
            }
        }
        else {
            if (this.template.querySelector(".ssp-checkboxGroup")) {
                this.template.querySelector(".ssp-checkboxGroup").classList.remove("ssp-checkbox-error");
            }
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
        }
        return oldValueReceived;
    };
}