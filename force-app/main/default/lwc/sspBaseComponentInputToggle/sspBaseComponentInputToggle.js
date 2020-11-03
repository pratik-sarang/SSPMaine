/**
 * Component Name: sspBaseComponentInputToggle.
 * Description: This component is used to render a question with options.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";

export default class baseComponentInputRadioGroup extends LightningElement {
  @api label;
  @api title = "";
  @api required;
  @api className = "";
  @api handleChange = false;
  @api value = [];
  @api fieldName;
  @api entityName;
  @api options;
  @api isHelpText = false;
  @track hasError;
  @api ErrorMessageList = [];
  @api disabled;
  @track ErrorMsgList = [];
  @track metaListValues;
  @api helpTextContent;
  @api oldValue = "";  
  @api isCustomTooltip=false;
  hasRendered=false;

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
      console.error("Error in sspBaseComponentInputCheckbox.isDisabled", error);
    }

    return isDisabled;
  }

  /*
   * @function : handleValidations
   * @description : This method is used to handle the question related validations.
   * @param    {event}
   */
  handleValidations = event => {
    try {
      this.value = event.srcElement.value;      

      const errorMessageList = this.ErrorMessageList !== null ? this.ErrorMessageList : [];
      if (this.metaListValues !== null && this.metaListValues !== undefined) {
        const fetchedList = this.metaListValues[
          this.fieldName + "," + this.entityName
        ];
        const inputValue = event.srcElement.value;
        if (
          fetchedList !== null &&
          fetchedList !== undefined &&
          fetchedList.Input_Required__c
        ) {
          const msg = fetchedList.Input_Required_Msg__c;
          this.handleRequiredValidation(inputValue, errorMessageList, msg);
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
        "failed in sspBaseComponentInputToggle.handleValidations " +
          JSON.stringify(error.message)
      );
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to handle error messages.
   */
  @api
  ErrorMessages () {
    try {
      const inputValue = this.value;

      const errorMessageList = this.ErrorMessageList !== null ? this.ErrorMessageList : [];
      const fieldName = this.fieldName;
      const entityName = this.entityName;
      const fieldEntityConcat = fieldName + "," + entityName;
      const metadataListReceived = this.metaListValues;
      const fetchedList =
        metadataListReceived !== undefined
          ? metadataListReceived[fieldEntityConcat]
          : null;
      if (
        fetchedList !== null &&
        fetchedList !== undefined &&
        fetchedList.Input_Required__c
      ) {
        const msg = fetchedList.Input_Required_Msg__c;
        this.handleRequiredValidation(inputValue, errorMessageList, msg);
      }

      const errorList = this.ErrorMessageList;
      return errorList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputToggle.ErrorMessages " +
          JSON.stringify(error)
      );
      return null;
    }
  }

  /*
   * @function : metaList
   * @description : This method is used to get/set meta list values.
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

  /*
   * @function : handleRequiredValidation
   * @description : This method is used to handle the required validation.
   * @param    {inputValue, errorMessageList, msg}
   */
  @api
  handleRequiredValidation (inputValue, errorMessageList, msg) {
    let newErrorMessageList = [];
    if (errorMessageList !== null && errorMessageList !== undefined){
      newErrorMessageList = JSON.parse(JSON.stringify(errorMessageList));
    }
    try {
      const requiredValue = true;
      const allowedValues =
        (this.options && this.options.map(option => option.value)) || [];
      if (
        (requiredValue &&
          (inputValue === "" ||
            inputValue === undefined ||
            inputValue === null)) ||
        !allowedValues.includes(inputValue)
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
        "failed in sspBaseComponentInputToggle.handleRequiredValidation " +
          JSON.stringify(error.message)
      );
    }
  }

  /*
    * @function : renderedCallback()
    * @description : This method is called when component gets rendered.
    */
    renderedCallback () {        
      this.oldValue = this.setOldValue(this.value, this.oldValue);   
      if (!this.hasRendered){
        if (this.helpTextContent && this.isCustomTooltip && this.template.querySelector(".ssp-toolTip-content")){
          // eslint-disable-next-line @lwc/lwc/no-inner-html
           this.template.querySelector(".ssp-toolTip-content").innerHTML = this.helpTextContent
           this.hasRendered=true;
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
        if(newValue && oldValue === "") {
          oldValueReceived = newValue;
        }
        else if (oldValueReceived === "" || oldValueReceived === undefined || oldValueReceived === null) {
          oldValueReceived = "null";
        } 
        return oldValueReceived;
    }
}