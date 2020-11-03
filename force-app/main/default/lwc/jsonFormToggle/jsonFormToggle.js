/*
 * Component Name: JsonFormToggle
 * Author: Narapa 
 * Description: Component to generate lightning Radio Group in jsonFormElement
 * Date: 05/27/2020.
 */
import { track, api } from "lwc";
import { JsonFormField } from "c/jsonFormField";
import { getYesNoOptions } from "c/sspUtility";

export default class JsonFormToggle extends JsonFormField {
    connectedCallback () {
    this.parentConnectedCallback();
  }

  @track radiogroupOptions = getYesNoOptions();

    //using salesforce checkValidity functionality to check the
    //validity of the user input
  @api
    isValid () {
    try {
            let validationResult = true;
            const input = this.template.querySelector(
                '[data-id="' + this.name + '"]'
            );
      if (input) {
        //out of the box check validity is not working hence
        //added custom check
                validationResult = input.checkValidity();
        if (!validationResult) {
          input.reportValidity();
        }
      }
      return validationResult;
        } catch (error) {
            console.error(
                "failed in isValid in jsonFormToggle" + JSON.stringify(error)
            );
        }
  }

    /**
 * @function : handleChange
     * @description : Method to generate an event when the option is chosen by the user.
 * This event will be handled in the jsonFlowContainer.
 * @param {event} event - JS event.
     */
    handleChange (event){
    event.preventDefault();
    const dtl = new Object();
    dtl.name = this.name;
    dtl.value = event.target.value;
        const changeEvent = new CustomEvent("fieldchange", {
            detail: dtl,
            bubbles: true
        });
    this.dispatchEvent(changeEvent);
  }
}