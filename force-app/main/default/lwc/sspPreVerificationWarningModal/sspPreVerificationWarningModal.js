/**
 * Component Name: sspPrimaryApplicantContactPage.
 * Author: Suyash, P V Siddarth.
 * Description: This screen gives a warning Modal.
 * Date: 17/12/2019.
 */

import { api, track } from "lwc";

import sspSocialSecurityNumberDoesNotMatch from "@salesforce/label/c.ssp_SocialSecurityNumberDoesNotMatch";
import sspReviewRequired from "@salesforce/label/c.sspReviewRequired";
import sspContinueAnywayButton from "@salesforce/label/c.SSP_ContinueAnywayButton";
import sspCheckMyEntries from "@salesforce/label/c.SSP_CheckMyEntries";

import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { events } from "c/sspConstants";
import constants from "c/sspConstants";

export default class SspPreVerificationWarningModal extends BaseNavFlowPage {
    label = {
        sspSocialSecurityNumberDoesNotMatch,
        sspReviewRequired,
        sspContinueAnywayButton,
        sspCheckMyEntries
    };

    @api openModel = false;
    @track reference = this;

    /**
     * @function : openModal
     * @description : This used to open Modal.
     */
    openModal () {
        this.openModel = true;
    }
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        try {
            this.dispatchEvent(CustomEvent(events.closeModal));
            this.openModel = false;
        } catch (error) {
            console.error("Error in handleProp", error);
        }
    }
    /**
     * @function : continueAnyway
     * @description : This function fires event to the parent component.
     */
    continueAnyway () {
        const closeEvt = new CustomEvent(constants.events.continueAnyway);
        this.dispatchEvent(closeEvt);
    }
}
