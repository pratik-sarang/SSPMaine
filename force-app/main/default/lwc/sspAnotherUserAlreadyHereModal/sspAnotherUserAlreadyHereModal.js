/**
 * Component Name: sspAnotherUserAlreadyHereModal.
 * Author: Chirag Garg.
 * Description: This modal appears when a user tries to enter the application flow while another user is already logged in.
 * Date: 05/07/2020.
 */

import { LightningElement, track, api } from "lwc";
import sspConstants from "c/sspConstants";
import sspExitApplication from "@salesforce/label/c.SSP_ExitApplication";
import sspAnotherUserAlreadyHere from "@salesforce/label/c.SSP_AnotherUserAlreadyHere";
import sspAnotherUserAlreadyHereContent from "@salesforce/label/c.SSP_AnotherUserAlreadyHereContent";
import sspExitTheApplication from "@salesforce/label/c.SSP_ExitTheApplication";

export default class SspAnotherUserAlreadyHereModal extends LightningElement {
    
    @api openModel = false;
    @track reference = this;
    label = {
        sspExitApplication,
        sspAnotherUserAlreadyHere,
        sspAnotherUserAlreadyHereContent,
        sspExitTheApplication
    };
    /*
     * @function : closeModal
     * @description	: Method to close modal on click of close button
     */
    closeModal () {
        try {
            this.openModel = false;
            this.openModel = "";
            this.progressValue = false;
            const selectedEvent = new CustomEvent(
                sspConstants.events.progressValueChange,
                {
                    detail: this.progressValue
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "failed in sspAnotherUserAlreadyHereModal.closeModal " +
                    JSON.stringify(error)
            );
        }
    }
    /* only for testing purpose remove after that */

    openModal () {
        try {
            this.openModel = true;
        } catch (error) {
            console.error(
                "failed in sspAnotherUserAlreadyHereModal.openModal " +
                    JSON.stringify(error)
            );
        }
    }
}