/**
 * Component Name: sspBaseComponentInputRadioGroup.
 * Description: This component is used to render radio button group.
 */
import { LightningElement, track, api } from "lwc";

export default class baseComponentInputRadioGroup extends LightningElement {
  @api label;
  @api title = "";
  @api required;
  @api className = "";
  @api value = [];
  @api fieldName;
  @api entityName;
  @api handleChange = false;
  @api options = [];
  @track hasError;
  @api ErrorMessageList = [];
  @api disabled;
  @track ErrorMsgList = [];
  @api metaListValues;
  @api oldValue = "";
  @api isHelpText = false;
  @api helpTextContent;
  

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
      console.error("Error in sspBaseComponentInputRadioGroup.isDisabled", error);
    }

    return isDisabled;
  }
  
  /*
   * @function : handleValidations
   * @description : This method is used to handle the radio button group validations.
   * @param    {event}
   */
  handleValidations = event => {
    try {
      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues !== undefined ? this.metaListValues[
          this.fieldName + "," + this.entityName
      ] : undefined;
      const inputValue = event.srcElement.value;
      this.value = event.srcElement.value;
      if (
        (fetchedList !== null && fetchedList !== undefined) &&
        fetchedList.Input_Required__c
      ) {
        const msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(inputValue, errorMessageList, msg);
      } else if(fetchedList !== null && fetchedList !== undefined) {
        this.removeMsgFromErrorMessageList(fetchedList.Input_Required_Msg__c);
      }
      if (this.handleChange) {
        const selectedEvent = new CustomEvent("update", {
          detail: this.value
        });

        this.dispatchEvent(selectedEvent);
      }
      if (this.ErrorMessageList.length){
        if (this.template.querySelector(".ssp-radioGroup")){
          this.template.querySelector(".ssp-radioGroup").classList.add("ssp-checkbox-error");
        }
      }
      else{
        if (this.template.querySelector(".ssp-radioGroup")) {
          this.template.querySelector(".ssp-radioGroup").classList.remove("ssp-checkbox-error");
        }
      }
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputRadioGroup.handleValidations " +
          JSON.stringify(error)
      );
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to handle error messages in validations.
   */
  @api
  ErrorMessages () {
    try {
      const inputValue = this.value;
      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues !== undefined ? this.metaListValues[
          this.fieldName + "," + this.entityName
      ] : undefined;
      if (
        (fetchedList !== null && fetchedList !== undefined) &&
        fetchedList.Input_Required__c
      ) {
        const msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(inputValue, errorMessageList, msg);
      } else if(fetchedList !== null && fetchedList !== undefined) {
        this.removeMsgFromErrorMessageList(fetchedList.Input_Required_Msg__c);
      }

      const errorList = this.ErrorMessageList;
      if (this.ErrorMessageList.length) {
        if (this.template.querySelector(".ssp-radioGroup")) {
          this.template.querySelector(".ssp-radioGroup").classList.add("ssp-checkbox-error");
        }
      }
      else {
        if (this.template.querySelector(".ssp-radioGroup")) {
          this.template.querySelector(".ssp-radioGroup").classList.remove("ssp-checkbox-error");
        }
      }
      return errorList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputRadioGroup.ErrorMessages " +
          JSON.stringify(error)
      );
      return null;
    }
  }

  /*
   * @function : get/set metaList
   * @description : Getter and setter for meta list for radio group values.
   */
  @api
  get metaList () {
    return this.metaListValues;
  }
  set metaList (value) {
    this.metaListValues = value;
  }

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputValue, errorMessageList, msg}
   */
  @api
  handleRequiredValidation (inputValue, errorMessageList, msg) {
    let newErrorMessageList = [];
    if (errorMessageList !== null && errorMessageList !== undefined) {
      newErrorMessageList = JSON.parse(JSON.stringify(errorMessageList));
    }
    try {
      const requiredValue = true;
      if (
        requiredValue &&
        (inputValue === null ||
          inputValue === "" ||
          inputValue === undefined ||
          inputValue.length === 0)
      ) {
        if (newErrorMessageList.indexOf(msg) === -1) {
          newErrorMessageList.push(msg);
        }
      } else {
        if (newErrorMessageList.indexOf(msg) > -1) {
          newErrorMessageList.splice(errorMessageList.indexOf(msg), 1);
        }
      }
      this.ErrorMessageList = newErrorMessageList; 
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputRadioGroup.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  }
  
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
  * @function : renderedCallback()
  * @description : This method is called when component gets rendered.
  */

  renderedCallback () {
      this.oldValue = this.setOldValue(this.value, this.oldValue);        
      if (this.ErrorMessageList.length){
        if (this.template.querySelector(".ssp-radioGroup")){
          this.template.querySelector(".ssp-radioGroup").classList.add("ssp-checkbox-error");
        }
      }
      else{
        if (this.template.querySelector(".ssp-radioGroup")) {
          this.template.querySelector(".ssp-radioGroup").classList.remove("ssp-checkbox-error");
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
  let oldValueReceived = oldValue
    if(newValue !== undefined && oldValue === "") {
      oldValueReceived = newValue;
    }
    return oldValueReceived;
}
}