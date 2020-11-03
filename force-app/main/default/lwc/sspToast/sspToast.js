/***
 * Component Name: sspToast.js.
 * Author: Saurabh.
 * Description: This component is used to show Toast messages.
 * Date: 12/11/2019.
 */
import { LightningElement, api, track } from "lwc";
import sspCardImages from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

export default class sspToast extends LightningElement {
    @track isPositive = false;
    @track isNegative = false;
    @api condition = "negative"; //condition will go here based on which the toast will be shown
    @api sspToastTitleVal;
    @api sspToastAdditionalInfo;
    @api showErrorToast = false;

    positiveIcon = sspCardImages + apConstants.url.progressChecked;

    negativeIcon = sspCardImages + apConstants.url.disagreeIcon;

    /**
     * @function - renderedCallback
     * @description -Method is called when the entire UI is done rendering.
     */
    renderedCallback () {
        try {
            const toastContainer = this.template.querySelector(
                ".ssp-toastContainer"
            );
            const toastTitle = this.template.querySelector(".ssp-toastHeading");

            let classesToAdd;

            if (this.condition == "neutral") {
                classesToAdd = [
                    "ssp-bg_whiteBeta",
                    "ssp-neutralToastContainer"
                ];
                toastTitle.classList.add("ssp-color_blueAlpha");
            } else if (this.condition == "positive") {
                this.isPositive = true;
                classesToAdd = [
                    "ssp-bg_whiteBeta",
                    "ssp-positiveToastContainer"
                ];
            } else {
                this.isNegative = true;
                classesToAdd = [
                    "ssp-bg_redGamma",
                    "ssp-negativeToastContainer"
                ];
            }
            //Added by Kyathi as part of CD1 Defect
            if (toastContainer!==null && toastContainer!==undefined) {
                toastContainer.classList.add(...classesToAdd);
            }
            if (this.showErrorToast) {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.showErrorToast = false;
                    this.dispatchEvent(
                        new CustomEvent(apConstants.events.hideToast)
                    );
                }, 5000);
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }
}
