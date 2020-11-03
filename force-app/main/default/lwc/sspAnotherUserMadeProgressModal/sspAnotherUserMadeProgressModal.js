/**
 * Component Name: sspAnotherMadeProgressModal.
 * Author: Chirag Garg.
 * Description: This modal appears when a user enters the application flow after another user has accessed the application.
 * Date: 05/07/2020.
 */

import { LightningElement, track, api } from "lwc";
import sspConstants from "c/sspConstants";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspExitApplication from "@salesforce/label/c.SSP_ExitApplication";
import sspAnotherUserHasMadeProgressContent from "@salesforce/label/c.SSP_AnotherUserHasMadeProgressContent";
import sspAnotherUserHasMadeProgress from "@salesforce/label/c.SSP_AnotherUserHasMadeProgress";
import sspExitTheApplication from "@salesforce/label/c.SSP_ExitTheApplication";
import sspContinueTheApplication from "@salesforce/label/c.SSP_ContinueTheApplication";

export default class SspAnotherUserMadeProgressModal extends LightningElement {
    @api openModel = false;
    @track reference = this;
    label = {
        sspContinue,
        sspExitApplication,
        sspAnotherUserHasMadeProgressContent,
        sspAnotherUserHasMadeProgress,
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
                "failed in sspAnotherUserMadeProgressModal.closeModal " +
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
                "failed in sspAnotherUserMadeProgressModal.closeModal " +
                    JSON.stringify(error)
            );
        }
    }
}