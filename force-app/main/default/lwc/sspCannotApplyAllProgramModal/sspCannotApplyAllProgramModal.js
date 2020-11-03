/**
 * Component Name: sspCannotApplyAllProgramsModal.
 * Author: Chirag Garg.
 * Description: This modal appears when a user attempts to initiate or continue an application on behalf of a client who already has an application in-progress which includes programs which the user does not have access to.
 * Date: 05/07/2020.
 */

import { LightningElement, track, api } from "lwc";
import sspConstants from "c/sspConstants";
import sspCannotApplyAllPrograms from "@salesforce/label/c.SSP_CannotApplyAllPrograms";
import sspCannotApplyAllProgramsContent from "@salesforce/label/c.SSP_CannotApplyAllProgramsContent";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspExitApplication from "@salesforce/label/c.SSP_ExitApplication";
import sspExitTheApplication from "@salesforce/label/c.SSP_ExitTheApplication";
import sspContinueTheApplication from "@salesforce/label/c.SSP_ContinueTheApplication";

export default class SspCannotApplyAllProgramModal extends LightningElement {
    @api openModel = false;
    @track reference = this;
    label = {
        sspCannotApplyAllPrograms,
        sspCannotApplyAllProgramsContent,
        sspContinue,
        sspExitApplication,
        sspExitTheApplication,
        sspContinueTheApplication
    };

    /*
     * @function : continueSummary
     * @description	: Fire event to Dashboard
     */
    continueSummary () {
        try {
            this.progressValue = true;
            const selectedEvent = new CustomEvent(
                sspConstants.events.progressValueChange,
                {
                    detail: this.progressValue
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "failed in sspCannotApplyAllProgramModal.continueSummary " +
                    JSON.stringify(error)
            );
        }
    }

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
                "failed in sspCannotApplyAllProgramModal.closeModal " +
                    JSON.stringify(error)
            );
        }
    }

    /* only for testing purpose remove after that */
    openModal () {
        this.openModel = true;
    }
}