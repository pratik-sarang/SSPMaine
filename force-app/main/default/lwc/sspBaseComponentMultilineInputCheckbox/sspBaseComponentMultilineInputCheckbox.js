/*
 * Component Name: SspBaseComponentMultiLineInputCheckbox
 * Author: Sharon
 * Description: This screen is used for multi line checkbox  field.
 * Date: 1/3/2019.
 */
import { LightningElement, api, track } from "lwc";
import sspConstants from "c/sspConstants";

export default class SspBaseComponentMultiLineInputCheckbox extends LightningElement {
  @api value = "";
  @api title = "";
  @api name = "";
  @api disabled = false;
  @api objectData;
  @api hideAdditionalFields = false;
  @api isChecked = false;
  @api entityName;
  @api fieldName;
  @api customValidationError = [];
  @api alwaysShowAdditionalFields = false;
  @track errorMessageList = [];

  /**
   * @function : showHideFields
   * @description :This method is used to show or hide fields .
   * @param {event} event - Event details.
   */
  showHideFields = event => {
    try {
      event.preventDefault();
      event.stopPropagation();
      const valChecked = event.srcElement.checked;
      this.isChecked = valChecked;
      this.value = valChecked;
      const selectedEvent = new CustomEvent(
        sspConstants.events.handleMultiSelectChange,
        {
          detail: this.objectData
        }
      );

      this.dispatchEvent(selectedEvent);
    } catch (error) {
      console.error("Error in showHideFields", error);
    }
  };

  /*
   * @function : ErrorMessages
   * @description : This method is used to check for the error message list.
   */
  @api
  ErrorMessages () {
    try {
      const errorList =
        this.errorMessageList !== undefined && this.errorMessageList.length > 0
          ? this.errorMessageList
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

  /**
   * @function : handleModalShowHideFields
   * @description :This method is used to show or hide fields .
   */
  @api
  handleModalShowHideFields () {
    try {
      this.isChecked = false;
    } catch (error) {
      console.error("Error in handleModalShowHideFields", error);
    }
  }
}