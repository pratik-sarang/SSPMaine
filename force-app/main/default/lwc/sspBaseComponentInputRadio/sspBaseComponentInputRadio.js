/**
 * Component Name: sspBaseComponentInputRadio.
 * Description: This component is used to render radio button.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";

export default class sspBaseComponentInputRadio extends LightningElement {
  @api label;
  @api title = "";
  @api required;
  @api className = "";
  @api value = "";
  @api handleChange = false;
  @api fieldName;
  @api entityName;
  @api oldValue = "";
  @track checked;
  @track hasError;
  @track ErrorMessageList = [];
  @track disabled;
  @track ErrorMsgList = [];
  @track metaListValues;

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
      console.error("Error in sspBaseComponentInputRadio.isDisabled", error);
    }

    return isDisabled;
  }
  
  /*
   * @function : handleValidations
   * @description : This method is used to handle the radio button validations.
   * @param    {event}
   */
  handleValidations = event => {
    try {
      let msg;
      const valueReceived = event.detail.value;
      const inputVal = valueReceived;
      const errorMessageList = this.ErrorMessageList;
      const fetchedList = this.metaListValues[
        this.fieldName + "," + this.entityName
      ];
      this.value = event.detail.value;
      if (fetchedList.Input_Required__c) {
        msg = fetchedList.Input_Required_Msg__c;
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
      console.error(
        "failed in sspBaseComponentInputRadio.handleValidations " +
          JSON.stringify(error)
      );
    }
  };
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
      if (fetchedList.Input_Required__c) {
        msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(
          inputVal,
          valueReceived,
          errorMessageList,
          msg
        );
      }

      const errorList = this.ErrorMessageList;
      return errorList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputRadio.ErrorMessages " +
          JSON.stringify(error)
      );
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
      console.error(
        "failed in sspBaseComponentInputRadio.getMetadataRecord " +
          JSON.stringify(error)
      );
    }
  };

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputText, valueReceived, errorMessageList, msg}
   */
  @api
  handleRequiredValidation (
    inputText,
    valueReceived,
    errorMessageList,
    msg
  ) {
    try {
      const requiredValue = this.required;
      this.required = true;
      if (requiredValue && inputText === "" && valueReceived === "") {
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
        "failed in sspBaseComponentInputRadio.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  }

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