/*
 * Component name  : sspBaseComponentInputDate
 * @description    : Generic component for Input Date.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";
import sspInvalidDateMessage from "@salesforce/label/c.SSP_InvalidDateMessage";

export default class sspBaseComponentInputDate extends LightningElement {
  @api label;
  @api name = "";
  @api title = "";
  @api required;
  @api className = "";
  @api value;
  @api entityName;
  @api fieldName;
  @api handleChange = false;
  @api disabled;
  @api isReadOnly = false;
  @api ErrorMessageList = [];
  @api timeTravelCurrentDate = new Date();
  @api comparingDate = new Date();
  @api placeholder = "mm/dd/yyyy";
  @api oldValue = "";
  @track ErrorMsgList = [];
  @track metaListValues;
  @track auraId = "";
  @track operator = "";
  @track hasError;
  badValue = false;
  hasRendered = false;

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
      console.error("Error in sspBaseComponentInputDate.isDisabled", error);
    }

    return isDisabled;
  }

 /*
 * @function : handleText
 * @description : This method is used to prevent user from entering text.
 * @param {event}
 */
  handleText = (event) =>{
      if (event.keyCode >= 65 && event.keyCode<=90){
          event.preventDefault();
      }
  }

  /*
   * @function : handleValidations
   * @description : This method is used to handle the date validations.
   * @param {event}
   */
  handleValidations = event => {
    try {
      if (event) {
        if(event.target.validity.badInput){
          this.ErrorMessageList = [];
          this.badValue = true;
          if (this.ErrorMessageList.indexOf(sspInvalidDateMessage) === -1) {
            this.ErrorMessageList.push(sspInvalidDateMessage);
          }
          event.target.classList.add("ssp-input-error");
        }else{
          this.badValue = false;
          if (this.ErrorMessageList.indexOf(sspInvalidDateMessage) > -1) {
            this.ErrorMessageList.splice(this.ErrorMessageList.indexOf(sspInvalidDateMessage), 1);
          }
        const valueReceived = event.target.value;
        this.value = event.target.value;
        /* const errorMessageList = JSON.parse(
          JSON.stringify(this.ErrorMessageList)
        ); */
        const fetchedList = this.metaListValues[
          this.fieldName + "," + this.entityName
        ];
        if (!fetchedList) {
          return;
        }
        if (fetchedList.Input_Required__c) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(valueReceived, this.ErrorMessageList, msg);
        }
        else {
            this.removeMsgFromErrorMessageList(fetchedList.Input_Required_Msg__c);
          }
        if (fetchedList.Is_Date_Future__c) {
          const msg = fetchedList.Is_Date_Future_Msg__c;
          this.futureDateInValidator(valueReceived, this.ErrorMessageList, msg);
        }
        if (fetchedList.Is_Date_Past__c) {
          const msg = fetchedList.Past_Date_Validation_Msg__c;
          this.pastDateInValidator(valueReceived, this.ErrorMessageList, msg);
        }
        if (fetchedList.CompareDateValidator__c) {
          const msg = fetchedList.CompareDateValidatorMessage__c;
          this.compareDateValidator(valueReceived, this.ErrorMessageList, msg);
        }
        if (fetchedList.NextCurrentYear_Validator__c) {
          const msg = fetchedList.NextCurrentYear_Validator_Msg__c;
          this.currentNextYearValidator(valueReceived, this.ErrorMessageList, msg);
        }
        if (this.handleChange) {
          const selectedEvent = new CustomEvent(events.handleChange, {
            detail: this.value
          });
          this.dispatchEvent(selectedEvent);
        }
        if (this.ErrorMessageList.length) {
          event.target.classList.add("ssp-input-error");
        }
        else {
          event.target.classList.remove("ssp-input-error");
        }
      }
    }
    } catch (error) {
      console.error("Error in handleValidations", error);
    }
  };

  /*
   * @function - removeMsgFromErrorMessageList
   * @description - This method is used to remove the error message from ErrorMessageList if condition not satisfied.
   * @param {string} message - Contains the error message.
   */
  removeMsgFromErrorMessageList = message => {
    try {
      if (
        this.ErrorMessageList.length > 0 &&
        this.ErrorMessageList.indexOf(message) !== -1
      ) {
        //Exists Block
        this.ErrorMessageList.splice(this.ErrorMessageList.indexOf(message), 1);
      }
    } catch (error) {
      console.error("Error in removeMsgFromErrorMessageList method: ", error);
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to check for the error message list.
   */
  @api
  ErrorMessages () {
    try {
      let msg;
      const valueReceived = this.value;
      const errorMessageList = JSON.parse(
        JSON.stringify(this.ErrorMessageList)
      )
      const fetchedList = this.metaListValues !== undefined ? this.metaListValues[
        this.fieldName + "," + this.entityName
      ] : undefined;
      if (!fetchedList) {
        return null;
      }
      if (fetchedList.Input_Required__c && !this.badValue) {
        msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(valueReceived, this.ErrorMessageList, msg);
      }
      else {
        this.removeMsgFromErrorMessageList(fetchedList.Input_Required_Msg__c);
      }
      if (fetchedList.Is_Date_Future__c) {
        msg = fetchedList.Is_Date_Future_Msg__c;
        this.futureDateInValidator(valueReceived, this.ErrorMessageList, msg);
      }
      if (fetchedList.Is_Date_Past__c) {
        msg = fetchedList.Past_Date_Validation_Msg__c;
        this.pastDateInValidator(valueReceived, errorMessageList, msg);
      }
      if (fetchedList.Compare_Date__c) {
        msg = fetchedList.Compare_Date_Msg__c;
        this.compareDateValidator(valueReceived, this.ErrorMessageList, msg);
      }
      if (fetchedList.NextCurrentYear_Validator__c) {
        msg = fetchedList.NextCurrentYear_Validator_Msg__c;
        this.currentNextYearValidator(valueReceived, this.ErrorMessageList, msg);
      }
      if (this.ErrorMessageList.length) {
        this.template.querySelector(".ssp-genericInput lightning-input").classList.add("ssp-input-error");
      }
      const errorList = this.ErrorMessageList;
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
   * @function : pastDateInValidator
   * @description : This method is used to handle the past date validation.
   * @param    {valueReceived, errorMessageList, msg}
   */
  pastDateInValidator = (valueReceived, errorMessageList, msg) => {
    try {
      const dateSelected = valueReceived;

      const inputDate = Date.parse(dateSelected);
      const todayDate = this.timeTravelCurrentDate;

      if (
        new Date(new Date(inputDate).toDateString()).getTime() <
        new Date(new Date(todayDate).toDateString()).getTime()
      ) {
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
      console.error("Error in pastDateInValidator", error);
    }
  };

  /*
   * @function : futureDateInValidator
   * @description : This method is used to handle the future date validation.
   * @param    {valueReceived, errorMessageList, msg}
   */
  futureDateInValidator = (valueReceived, errorMessageList, msg) => {
    try {
      const dateSelected = valueReceived;
      const inputDate = Date.parse(dateSelected);
            this.ErrorMessageList = [].concat(this.ErrorMessageList);

      const todayDate = this.timeTravelCurrentDate;
      if (
        new Date(new Date(inputDate).toDateString()).getTime() >
        new Date(new Date(todayDate).toDateString()).getTime()
      ) {
                if (this.ErrorMessageList.indexOf(msg) === -1) {
                    this.ErrorMessageList.push(msg);
        }
      } else {
                if (this.ErrorMessageList.indexOf(msg) > -1) {
                    this.ErrorMessageList.splice(
                        this.ErrorMessageList.indexOf(msg),
                        1
                    );
        }
      }
    } catch (error) {
      console.error("Error in futureDateInValidator", error);
    }
  };

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {valueReceived, errorMessageList, msg}
   */
  handleRequiredValidation = (valueReceived, errorMessageList, msg) => {
    try {
      const requiredValue = true;
      if (
        requiredValue &&
        (valueReceived === "" ||
          valueReceived === null ||
          valueReceived === undefined)
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
      console.error("Error in handleRequiredValidation", error);
    }
  };

  /*
   * @function : compareDateValidator
   * @description : This method is used to handle the date comparison validation.
   * @param    {inputText, valueReceived, errorMessageList, msg}
   */
  compareDateValidator = (valueReceived, errorMessageList, msg) => {
    try {
      const endDate = valueReceived;
      const startDate = this.comparingDate;

      if (endDate !== null && endDate !== undefined && endDate !== "" && startDate !== null && startDate !== undefined && startDate !== "") {
        const jsStartDate = new Date(startDate);
        const jsEndDate = new Date(endDate);
        if (
          jsStartDate.getTime() >= jsEndDate.getTime()
        ) {
          if (errorMessageList.indexOf(msg) === -1) {
            errorMessageList.push(msg);
          }
        } else {
          if (errorMessageList.indexOf(msg) > -1) {
            errorMessageList.splice(
              errorMessageList.indexOf(msg),
              1
            );
          }
        }

        this.ErrorMessageList = errorMessageList;
      }
    } catch (error) {
      console.error("Error in compareDateValidator", error);
    }
  };

  /*
   * @function: currentNextYearValidator
   * @description : This method is used to handle the current and next year date validation.
   * @param    {valueReceived, errorMessageList, msg}
   */
  currentNextYearValidator = (valueReceived, errorMessageList, msg) => {
    try {
      const yearSelected = new Date(valueReceived).getFullYear();
      const currentYear = this.timeTravelCurrentDate.getFullYear();
      const nextYear = currentYear + 1;

      if (yearSelected != currentYear && yearSelected != nextYear) {
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
      console.error("Error in currentNextYearValidator", error);
    }
  };
  /*
   * @function : renderedCallback()
   * @description : This method is called when component gets rendered.
   */
  renderedCallback () {
    this.oldValue = this.setOldValue(this.value, this.oldValue);
    if (this.hasRendered) {
      if (this.ErrorMessageList.length) {
        this.template.querySelector(".ssp-genericInput lightning-input").classList.add("ssp-input-error");
      }
      else {
        this.template.querySelector(".ssp-genericInput lightning-input").classList.remove("ssp-input-error");
      }
    }
    this.hasRendered = true;
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