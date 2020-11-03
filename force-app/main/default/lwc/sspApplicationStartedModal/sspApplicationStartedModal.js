/**
 * Component Name: sspApplicationStartedModal.
 * Author: Chirag Garg.
 * Description: This modal appears when a user attempts to initiate an application on behalf of a client who already has an application in-progress.
 * Date: 05/07/2020.
 */

import { LightningElement, track, api } from "lwc";
import sspApplicationHasBeenStartedContent from "@salesforce/label/c.SSP_ApplicationHasBeenStartedContent";
import sspApplicationHasBeenStarted from "@salesforce/label/c.SSP_ApplicationHasBeenStarted";
import sspDashboard from "@salesforce/label/c.SSP_GoDashboard";
import { NavigationMixin } from "lightning/navigation";
import constants from "c/sspConstants";

export default class SspCannotApplyModal extends NavigationMixin(
    LightningElement
) {
    @api openModel = false;
    @track reference = this;

    label = {
        sspApplicationHasBeenStartedContent,
        sspApplicationHasBeenStarted,
        sspDashboard
    };
    /*
     * @function : closeModal
     * @description	: Method to close modal on click of close button
     */
    closeModal = () => {
        try {
            this.returnToDashboard();
            /*
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
            */
        } catch (error) {
            console.error(
                "failed in sspRemoveIncomeModal.closeModal " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : returnToDashboard
     * @description : This function is used to redirect to Home Page.
     */
    returnToDashboard = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: constants.eligibilityStatus.dashboardUrl
                }
            });
        } catch (error) {
            console.error(
                "failed in sspRemoveIncomeModal.returnToDashboard " +
                    JSON.stringify(error)
            );
        }
    };

    /* only for testing purpose remove after that */
    openModal = () => {
        this.openModel = true;
    };
}