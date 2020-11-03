/*
 * Component Name: sspBaseComponentInputTextIcon.
 * Author: Nupoor
 * Description: This screen is used for currency input field.
 * Date: 29/11/2019.
 */
import { LightningElement, track, api } from "lwc";
import { sspAssetFields } from "c/sspConstants";

export default class SspBaseComponentInputText extends LightningElement {
  @api recordId;
  @api label = "Name";
  @api handleChange = false;
  @api entityName;
  @api fieldName;
  @track inputValue = "";
  @api required;
  @api title = "";
  @api pattern = "";
  @api className = "";
  @api placeholder;
  @api ErrorMessageList = [];
  @api maxLength;
  @api minLength;
  @api maximumValue;
  @api disabled;
  @api isHelpText = false;
  @api helpTextContent = "";
  @api customValidationError = [];
  @track ErrorMsgList = [];
  @track metaListValues;
  @track hasError;
  @track metadataListRecords;
    @api oldValue = "";
  @api
  get value () {
    return this.inputValue;
  }
  set value (number) {
    this.inputValue = number;
  }
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
      console.error("Error in sspBaseComponentTextIcon.isDisabled", error);
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
      const val = event.target.value;
            if (val < 0 || val==""){
                event.target.value="";
            }

      if (event.type == "blur") {
        this.inputValue =
        val !== "" && val !== null && val !== undefined && !isNaN(val)
            ? parseFloat(event.target.value).toFixed(2)
            : "";
      } else {
        this.inputValue =
        val !== "" && val !== null && val !== undefined && !isNaN(val)
            ? parseFloat(event.target.value)
            : "";
      }
      const valueReceived = this.inputValue; //event.detail.value;
      const inputVal = this.inputValue;
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

      if (fetchedList !== null && fetchedList !== "undefined") {
        if (fetchedList.IllegalCharactersValidator__c) {
          const msg = fetchedList.IllegalCharactersValidator_Msg__c;
          this.ValidateIllegalCharacters(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
        if (fetchedList.SSNValidator__c) {
          const msg = fetchedList.SSNValidator_Msg__c;
          this.handleSSNValidation(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
        if (fetchedList.Input_Required__c) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }
        if (fetchedList.Specify_Pattern__c) {
          const msg = fetchedList.Specify_Pattern_Msg__c;

          this.validatePattern(inputVal, valueReceived, errorMessageList, msg);
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
        if (fetchedList[sspAssetFields.validateMinLength]) {
          const msg = fetchedList[sspAssetFields.validateMinLengthMessage];
          this.validateMinLength(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }

        if (fetchedList.NonZeroValidator__c) {
          const msg = fetchedList.NonZeroValidator_Msg__c;
          this.validateForNonZeroValue(
            inputVal,
            valueReceived,
            errorMessageList,
            msg
          );
        }

        // For lessThanEqualTo validator
        if (fetchedList.LessThanEqualToValidator__c) {
          let msg = fetchedList.LessThanEqualToValidator_Msg__c;
          msg = msg.replace("{val}", this.maximumValue);
          this.validateMaxValue(inputVal, valueReceived, errorMessageList, msg);
        }
      }
      if (this.handleChange) {
        const selectedEvent = new CustomEvent(sspAssetFields.handleChange, {
          detail: this.inputValue
        });
        this.dispatchEvent(selectedEvent);
            }
            if (this.ErrorMessageList.length) {
                event.target.classList.add("ssp-input-error");
            } else {
                event.target.classList.remove("ssp-input-error");
      }
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputTextIcon.handleValidations " +
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
      const valueReceived = this.inputValue;
      const inputVal = valueReceived;
            //const errorMessageList = this.ErrorMessageList;
            this.ErrorMessageList =
                this.ErrorMessageList.length === 0 ? [] : this.ErrorMessageList;
      const fetchedList =
        this.metaListValues !== null
                    ? this.metaListValues[
                          this.fieldName + "," + this.entityName
                      ]
          : null;

      if (fetchedList != null && fetchedList !== "undefined") {
        if (fetchedList.IllegalCharactersValidator__c) {
          const msg = fetchedList.IllegalCharactersValidator_Msg__c;
          this.ValidateIllegalCharacters(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }
        if (fetchedList.SSNValidator__c) {
          const msg = fetchedList.SSNValidator_Msg__c;
          this.handleSSNValidation(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }
        if (fetchedList.Input_Required__c) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }
        if (fetchedList.Specify_Pattern__c) {
          const msg = fetchedList.Specify_Pattern_Msg__c;
                    this.validatePattern(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
        }
        if (fetchedList[sspAssetFields.validateMaxLength]) {
          const msg = fetchedList[sspAssetFields.validateMaxLengthMessage];
          this.validateMaxLength(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }
        if (fetchedList[sspAssetFields.validateMinLength]) {
          const msg = fetchedList[sspAssetFields.validateMinLengthMessage];
          this.validateMinLength(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }

        if (fetchedList.NonZeroValidator__c) {
          const msg = fetchedList.NonZeroValidator_Msg__c;
          this.validateForNonZeroValue(
            inputVal,
            valueReceived,
                        this.ErrorMessageList,
            msg
          );
        }

        // For lessThanEqualTo validator
        if (fetchedList.LessThanEqualToValidator__c) {
          let msg = fetchedList.LessThanEqualToValidator_Msg__c;
          msg = msg.replace("{val}", this.maximumValue);
                    this.validateMaxValue(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (this.ErrorMessageList.length) {
                    this.template
                        .querySelector(".ssp-genericInput lightning-input")
                        .classList.add("ssp-input-error");
        }
      }

      return this.ErrorMessageList !== undefined &&
        this.ErrorMessageList.length > 0
        ? this.ErrorMessageList
        : this.customValidationError !== undefined &&
          this.customValidationError.length > 0
        ? this.customValidationError
        : undefined;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputTextIcon.ErrorMessages " +
          JSON.stringify(error)
      );
      return null;
    }
  }
  /**
   * @function : getMetadataRecord
   * @description :This method is used to get MetadataRecord.
   */
  getMetadataRecord = () => {
    try {
      const metadataList = this.metaListValues;
      this.metadataListRecords = metadataList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputTextIcon.getMetadataRecord " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : ValidateIllegalCharacters
   * @description :This method is used to handle validations.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  ValidateIllegalCharacters = (
    inputVal,
    valueReceived,
    errorMessageList,
    msg
  ) => {
    try {
      const regexExpr = new RegExp(
        "^(?!.*\\s{2})([a-zA-Z]+(([,.'-][a-zA-Z ])?( )?[a-zA-Z]*)*)$"
      );
      const regexResult = regexExpr.test(inputVal);
      if (regexResult.toString() === "false" && !(inputVal === "")) {
        this.hasError = true;
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
        "failed in sspBaseComponentInputTextIcon.ValidateIllegalCharacters " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : handleSSNValidation
   * @description :This method is used to handleSSNValidation.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  handleSSNValidation = (inputVal, valueReceived, errorMessageList, msg) => {
    try {
      const regexExpr = new RegExp(
        "^(?!(000|666|111-11-1111|222-22-2222|333-33-3333|444-44-4444|555-55-5555|666-66-666|777-77-7777|888-88-8888))([0-8]\\d{2})(-?)(?!00)\\d{2}(-?)(?!0000)\\d{4}$"
      );
      const regexResult = regexExpr.test(inputVal);

      if (regexResult.toString() === "false" && !(inputVal === "")) {
        this.hasError = true;
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
        "failed in sspBaseComponentInputTextIcon.handleSSNValidation " +
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
      const requiredValue = true;

      const inputValue =
        inputVal != null
          ? inputVal
          : valueReceived != null
          ? valueReceived
          : "";

            if (
                requiredValue &&
                (inputValue === "" || inputValue === undefined)
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
        "failed in sspBaseComponentInputTextIcon.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : validateMaxValue
   * @description :This method is used to validateMaxValue.
   * @param {string}inputVal - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
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
        if (parseFloat(inputValue) > parseFloat(this.maximumValue)) {
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
        "failed in sspBaseComponentInputTextIcon.validateMaxValue " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : validatePattern
   * @description :This method is used to validatePattern.
   * @param {string}inputText - Input details.
   * @param {string}valueReceived - Input details.
   *  @param {object[]}errorMessageList - Input details.
   *  @param {string}msg - Input details.
   */
  validatePattern = (inputText, valueReceived, errorMessageList, msg) => {
    try {
      const receivedPattern = this.pattern;
            const inputReceive = inputText ? inputText : "";
      const regexExpr = new RegExp(receivedPattern);
            const regexResult = regexExpr.test(inputReceive);

            if (regexResult.toString() === "false" && !(inputReceive === "")) {
        this.hasError = true;
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
        "failed in sspBaseComponentInputTextIcon.validatePattern " +
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

  /*
   * @function : validateForNonZeroValue
   * @description : This method is used to  For Non Zero value validation.
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
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
        if (this.ErrorMessageList.length) {
            this.template.querySelector(".ssp-genericInput lightning-input").classList.add("ssp-input-error");
          }
          else {
            this.template.querySelector(".ssp-genericInput lightning-input").classList.remove("ssp-input-error");
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
     /**
     * @function : restrictNumeric
     * @description : This method is used to restrict large  numeric values.
     * @param {*} event - Gives the typed data.
     */
    restrictNumeric (event) {
        try {
            const currentValue = String.fromCharCode(event.which);
            const finalValue =  event.target.value + currentValue;
            if (finalValue > 9999999999.99 ) {
                event.preventDefault();
            }
        } catch (error) {
            console.error("Error in restrictNonNumeric: ", error);
        }
    }
}