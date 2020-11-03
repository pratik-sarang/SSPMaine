/*
 * Component Name: sspBaseComponentInputTextArea.
 * Author: Shikha
 * Description: This screen is used for currency input field.
 * Date: 29/11/2019.
 */
import { LightningElement, track, api } from "lwc";
import { sspAssetFields, events } from "c/sspConstants";

export default class sspBaseComponentInputTextArea extends LightningElement {
  @api name;
  @api label;
  @api value;
  @api handleChange = false;
  @api className;
  @api title = "";
  @api disabled;
  @api readOnly;
  @api required;
  @api placeholder;
  @api maxLength;
  @api minLength;
  @api fieldName;
  @api entityName;
    @api ErrorMessageList = [];
  @track metaListValues;
  /**
   * @function : metaList.
   * @description : Getter setters for metadata list.
   */
  @api
  get metaList () {
    return this.metaListValues;
  }
  set metaList (value) {
    if (value) {
      this.metaListValues = value;
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
      console.error("Error in sspBaseComponentInputTextArea.isDisabled", error);
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
      let inputVal;
      if (event !== undefined) {
        this.value = event.detail.value?event.detail.value.replace(/\n/g, " ").replace(/  +/g, " "):event.detail.value;
        inputVal = event.detail.value?event.detail.value.replace(/\n/g, " ").replace(/  +/g, " "):event.detail.value;
      }
      const valueReceived = this.value;

      const errorMessageList = this.ErrorMessageList;

      if (
        this.metaListValues !== undefined &&
        this.fieldName !== undefined &&
        this.entityName
      ) {
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

          if (fetchedList[sspAssetFields.validateMinLength]) {
            const msg = fetchedList[sspAssetFields.validateMinLengthMessage];
            this.validateMinLength(
              inputVal,
              valueReceived,
              errorMessageList,
              msg
            );
          }
          if (fetchedList[sspAssetFields.validateMaxLength]) {
            const msg = fetchedList[sspAssetFields.validateMaxLengthMessage];
            this.validateMaxLength(
              inputVal,
              valueReceived,
              errorMessageList,
              msg
            );
          }
        }
      }
      if (this.handleChange) {
                const selectedEvent = new CustomEvent(
                    events.handleChange,
                    {
          detail: this.value
                    }
                );
                this.dispatchEvent(selectedEvent)
            }
        if (this.ErrorMessageList.length) {
            if (this.template.querySelector(".ssp-inputText")) {
                this.template
                    .querySelector(".ssp-inputText")
                    .classList.add("ssp-input-error");
            }
        } else {
            if (this.template.querySelector(".ssp-inputText")) {
                this.template
                    .querySelector(".ssp-inputText")
                    .classList.remove("ssp-input-error");
            }
          }
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputTextIcon.handleValidations " +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function : handleRequiredValidation
   * @description :This method is used to handleRequiredValidation.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  handleRequiredValidation = (
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
      const requiredValue = true;
      if (requiredValue && (inputValue === "" || inputValue === undefined)) {
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
        "failed in sspBaseComponentInputTextIcon.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function : validateMinLength
   * @description :This method is used to validateMinLength.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  validateMinLength = (inputVal, valueReceived, errorMessageList, msg) => {
    try {
      const inputValue =
        inputVal !== null && inputVal !== undefined
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";
      const minLength = this.minLength;
      const inputValLength = inputValue.length;

      if (inputValLength != null && minLength != null) {
        if (inputValLength < minLength) {
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
      console.error(
        "failed in sspBaseComponentInputTextIcon.validateMinLength " +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function : validateMaxLength
   * @description :This method is used to validateMaxLength.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  validateMaxLength = (inputVal, valueReceived, errorMessageList, msg) => {
    try {
      const inputValue =
        inputVal !== null && inputVal !== undefined
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";
      const maxLength = this.maxLength;
      const inputValLength = inputValue.length;

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
      console.error(
        "failed in sspBaseComponentInputTextIcon.validateMaxLength " +
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
      this.handleValidations();
      const errorList = this.ErrorMessageList;
        if (this.ErrorMessageList.length && this.template.querySelector(".ssp-inputText")) {
                this.template
                    .querySelector(".ssp-inputText")
                    .classList.add("ssp-input-error");
        }
      return errorList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputTextIcon.ErrorMessages " +
          JSON.stringify(error)
      );
      return null;
    }
  }
}