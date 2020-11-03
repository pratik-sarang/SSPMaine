/*
 * Component Name: sspBaseComponentInputSearch.
 * Author: Shikha
 * Description: This screen is used for Search field.
 * Date: 1/3/2019.
 */
import { LightningElement, api, track } from "lwc";
import { events } from "c/sspConstants";

export default class sspBaseComponentInputSearch extends LightningElement {
  @api label;
  @api entityName;
  @api fieldName;
  @api handleChange = false;
  @api value;
  @api placeholder;
  @api required;
  @api title;
  @api className;
  @api disabled;
  @track ErrorMessageList = [];
  @track metaListValues;

  /**
   * @function : metaList
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
      console.error("Error in sspBaseComponentInputSearch.isDisabled", error);
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
      this.value = event.target.value;
      const valueReceived = this.value;
      const inputVal = event.detail.value;
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
        if (fetchedList !== null && fetchedList !== undefined) {
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
      console.error(
        "failed in sspBaseComponentInputSearch.handleValidations " +
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
      this.handleValidations(event);
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.add("ssp-input-error");
            }
      return this.ErrorMessageList;
    } catch (error) {
      console.error(
        "failed in sspBaseComponentInputSearch.ErrorMessages " +
          JSON.stringify(error)
      );
    }
  }

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
        "failed in sspBaseComponentInputSearch.handleRequiredValidation " +
          JSON.stringify(error)
      );
    }
  };
}