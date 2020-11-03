/*
 * Component Name: SspMultiselectWithAdditionalInput.
 * Author: Nupoor
 * Description: This screen is used for multi select input.
 * Date: 11/11/2019.
 */
import { LightningElement, track, api } from "lwc";
import events from "c/sspConstants";

export default class SspMultiselectWithAdditionalInput extends LightningElement {
    @api label = "";
    @api value = "";
    @api title = "";
    @api name = "";
    @api isChecked = false;
    @api disabled = false;

    _showError = false;
    @api // for defect 382490 by saurabh rathi
    get showError () {
        return this._showError;
    }
    set showError (value) {
        if (value) {
            this.className = `${this.className} ssp-input-error`;
        } else {
            this.className = "ssp-checkbox ssp-multipleCheckbox_container";
        }
    }
    @api hideAdditionalSection = false;
    @track className = "ssp-checkbox ssp-multipleCheckbox_container";
    /*
     * @function : showHideFields
     * @description : This method is used to handle the show or hide fields .
     * @param {event}
     */
    showHideFields (event) {
        const valChecked = event.srcElement.checked;
        this.isChecked = valChecked;
        const selectedEvent = new CustomEvent(
            events.events.handleMultiSelectChange,
            {
                detail: valChecked
            }
        );

        this.dispatchEvent(selectedEvent);
    }
}
