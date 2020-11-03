/*
 * Component name  : sspBaseComponentInputNumber
 * @description    : Generic component for Input number.
 */
import { LightningElement, track, api } from "lwc";
import { fetchedListData, events } from "c/sspConstants";
import negativeErrorMessage from "@salesforce/label/c.SSP_NegativeErrorMessage";
import sspCaseApplicationMessage from "@salesforce/label/c.SSP_SearchCaseApplicationValidationMessage";

export default class sspBaseComponentInputNumber extends LightningElement {
  @api recordId;
  @api label;
  @api entityName;
  @api fieldName;
  @api value;
  @api required;
  @api title = "";
  @api handleChange = false;
  @api className = "";
  @api placeholder = "";
  @api formatter = "";
  @api maxLength;
  @api minLength;
  @api maximumValue; //added by Shrikant, for lessThanEqualTo validator
  @api disabled;
  @api step;
  @api customValidationError = [];
  @api inputType = "number";
  @api caseApplicationField = false;
  @track metaListValues;
  @track hasError;
  @api ErrorMessageList = [];
  @track ErrorMsgList = [];
  @api oldValue = "";
  @track labelVariant = "standard";
  hasRendered=false;
  @api
  get hideLabel () {
    return this.hideLabel;
  }
  set hideLabel (value) {
    try {
      if (value === "true") {
        this.labelVariant = "label-hidden"
      }
    } catch (error) {
      console.error("Error in hideLabel", error);
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
      console.error("Error in metaList", error);
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
      console.error("Error in sspBaseComponentInputNumber.isDisabled", error);
    }

    return isDisabled;
  }

  get retExp1 () {
    return this.required ? "*" : "";
  }

  /*
   * @function : handleValidations
   * @description : This method is used to handle the date validations.
   * @param {event}
   */
  handleValidations = event => {
    try {
             let negativeNumber = false;
            if (event.target.value && event.target.value<0) {
                negativeNumber = true;
            }
            this.ErrorMessageList = this.ErrorMessageList.filter(item => item !== negativeErrorMessage);
            this.negativeNumber = false;
      let message;
      this.value = event.target.value;
      const valueReceived = this.value;
      const inputVal = event.target.value;

      const errorMsgList = this.ErrorMessageList;
      let fetchedList = [];
      if (this.fieldName !== "" && this.entityName !== "") {
        fetchedList = this.metaList[
            this.fieldName + "," + this.entityName
        ];
      }
      else if (this.caseApplicationField) {
        message = sspCaseApplicationMessage;
        this.handleCaseApplicationValidation(
            inputVal,
            valueReceived,
            errorMsgList,
            message
        );
      }

      if (fetchedList !== null && fetchedList !== "undefined") {
        if (fetchedList.Input_Required__c) {
          message = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
            errorMsgList,
            message
          );
        }
      }

      if (fetchedList.LessThanEqualToValidator__c) {
        let msg = fetchedList.LessThanEqualToValidator_Msg__c;
                if (!negativeNumber) {
        msg = msg.replace("{val}", this.maximumValue);
                } else {
                    msg = negativeErrorMessage;
                }
                this.validateMaxValue(
                    inputVal,
                    valueReceived,
                    errorMsgList,
                    msg
                );
      }

      if (fetchedList.NonZeroValidator__c) {
        const msg = fetchedList.NonZeroValidator_Msg__c;
        this.validateForNonZeroValue(
          inputVal,
          valueReceived,
          errorMsgList,
          msg
        );
      }

      if (fetchedList[fetchedListData.Validate_MaxLength__c]) {
        let msg = fetchedList[fetchedListData.Validate_MaxLength_Msg__c];
        msg = msg.replace("{x}", this.maxLength); //added by Shrikant
        this.validateMaxLength(inputVal, valueReceived, errorMsgList, msg);
      }

            if (this.handleChange) {
                const selectedEvent = new CustomEvent(events.handleChange, {
                    detail: this.value
                });
                this.dispatchEvent(selectedEvent);
            }
            if (this.ErrorMessageList.length) {
                event.target.classList.add("ssp-input-error");
            } else {
                event.target.classList.remove("ssp-input-error");
            }
        } catch (error) {
            console.error("Error in handleValidations", error);
        }
    };

  /*
   * @function : validateMaxLength
   * @description : This method is used to handle the max length validation.
   * @param    {inputVal, valueReceived, errorMessageList, msg}
   */
  validateMaxLength = (inputVal, valueReceived, errorMessageList, msg) => {
    try {
      const value = inputVal || valueReceived || "";
      const maxLength = this.maxLength;
      const inputValLength = value.length;

      if (inputValLength != null && maxLength != null) {
        if (inputValLength > maxLength) {
          this.hasError = true;
          if (errorMessageList.indexOf(msg) === -1) {
            errorMessageList.push(msg);
          }
        } else {
          if (errorMessageList.indexOf(msg) > -1) {
            errorMessageList.splice(errorMessageList.indexOf(msg), 1);
          }
        }
      }
      this.ErrorMessageList = errorMessageList;
    } catch (error) {
      console.error("Error in validateMaxLength", error);
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
      const inputVal = this.value;

            let msg;
            const errorMsgList = this.ErrorMessageList;
            const fetchedList = this.metaListValues[
                this.fieldName + "," + this.entityName
            ];
            if (
                fetchedList !== null &&
                fetchedList !== "undefined" &&
                fetchedList.Input_Required__c
            ) {
                msg = fetchedList.Input_Required_Msg__c;
                this.handleRequiredValidation(
                    inputVal,
                    valueReceived,
                    errorMsgList,
                    msg
                );
            }
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.add("ssp-input-error");
            }
            return this.ErrorMessageList !== undefined &&
                this.ErrorMessageList.length > 0
                ? this.ErrorMessageList
                : this.customValidationError !== undefined &&
                  this.customValidationError.length > 0
                ? this.customValidationError
                : undefined;
        } catch (error) {
            console.error("Error in ErrorMessages", error);
            return null;
        }
    }

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputVal, valueReceived, errorMessageList, msg}
   */
  handleRequiredValidation = (inputVal, valueReceived, errorMsgList, msg) => {
    try {
      const inputValue =
        inputVal != null
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";

      if (inputValue === "") {
        if (errorMsgList.indexOf(msg) === -1) {
          errorMsgList.push(msg);
        }
      } else {
        if (errorMsgList.indexOf(msg) > -1) {
          errorMsgList.splice(errorMsgList.indexOf(msg), 1);
        }
      }

      this.ErrorMessageList = errorMsgList;
    } catch (error) {
      console.error("Error in handleRequiredValidation", error);
    }
  };

  /*
   * @function : validateMaxValue
   * @description : This method is used to handle the max value validation.
   * @param    {inputVal, valueReceived, errorMessageList, msg}
   */
  validateMaxValue = (inputVal, valueReceived, errorMessageList, msg) => {
    try {
      const inputValue =
        inputVal != null
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";

      if (inputValue != null && this.maximumValue != null) {
                if (parseFloat(inputValue) > parseFloat(this.maximumValue) || parseFloat(inputValue)<0) {
          this.hasError = true;
          if (errorMessageList.indexOf(msg) === -1) {
            errorMessageList.push(msg);
          }
        } else {
          if (errorMessageList.indexOf(msg) > -1) {
            errorMessageList.splice(errorMessageList.indexOf(msg), 1);
          }
        }
      }
      this.ErrorMessageList = errorMessageList;
    } catch (error) {
      console.error("Error in validateMaxValue", error);
    }
  };

  /*
   * @function : validateForNonZeroValue
   * @description : This method is used to check if the number is not zero.
   * @param    {inputVal, valueReceived, errorMessageList, msg}
   */
  validateForNonZeroValue = (
    inputVal,
    valueReceived,
    errorMessageList,
    msg
  ) => {
    try {
      const inputValue =
        inputVal != null
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";

      if (inputValue != null) {
        if (parseFloat(inputValue) <= 0) {
          this.hasError = true;
          if (errorMessageList.indexOf(msg) === -1) {
            errorMessageList.push(msg);
          }
        } else {
          if (errorMessageList.indexOf(msg) > -1) {
            errorMessageList.splice(errorMessageList.indexOf(msg), 1);
          }
        }
      }
      this.ErrorMessageList = errorMessageList;
    } catch (error) {
      console.error("Error in validateForNonZeroValue", error);
    }
  };

  /*
   * @function : handleCaseApplicationValidation
   * @description : This method is used to check if the case or application number is 10 digit.
   * @param    {inputVal, valueReceived, errorMessageList, msg}
   */
  handleCaseApplicationValidation = (inputVal, valueReceived,errorMessageList, msg) => {
    try {
        const inputValue =
            inputVal != null
                ? inputVal
                : valueReceived != null
                ? valueReceived
                : "";

      if (inputValue != null) {
          const checkForNumber = /^[0-9]+$/;
        if (inputValue.length !== 9 && inputValue.match(checkForNumber)){
                this.hasError = true;
                if (errorMessageList.indexOf(msg) === -1) {
                    errorMessageList.push(msg);
                }
            } else {
                if (errorMessageList.indexOf(msg) > -1) {
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
        }
        this.ErrorMessageList = errorMessageList;
    } catch (error) {
        console.error("Error in handleCaseApplicationValidation", error);
    }
  }

    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
      //Added by kyathi as part of  CD2 Development
      if (this.hasRendered) {
        if (this.ErrorMessageList.length) {
          this.template.querySelector(".ssp-genericInput lightning-input").classList.add("ssp-input-error");
        }
        else {
          this.template.querySelector(".ssp-genericInput lightning-input").classList.remove("ssp-input-error");
        }
      }
      this.hasRendered=true;  
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