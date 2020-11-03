/**
 * Component Name: sspTermsAgreementModal.
 * Author: Chirag , Shivam.
 * Description: This is a Generic modal for approving Terms Of Agreement.
 * Date: 4/23/2020.
 */

import { LightningElement, track } from "lwc";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspTermsAgreementContent from "@salesforce/label/c.SSP_TermsAgreementContent";
import sspTermsOfAgreement from "@salesforce/label/c.SSP_TermsOfAgreement";
import sspTermsAgreementAgreeAltText from "@salesforce/label/c.SSPTermsAgreementAgreeAltText";
import sspTermsAgreementDisagreeAltText from "@salesforce/label/c.SSP_TermsAgreementDisagreeAltText";

import constants from "c/sspConstants";

export default class SspTermsAgreementModal extends LightningElement {
    @track reference = this;
    @track trueValue = true;
    @track openModel = true;
    @track disabled = true;

    label = {
        sspAgreeButton,
        sspDisagreeButton,
        sspTermsAgreementContent,
        sspTermsOfAgreement,
        sspTermsAgreementAgreeAltText,
        sspTermsAgreementDisagreeAltText
    };

    /**
     * @function : closeApplicationStatementModal
     * @description : This method is used to close the Modal.
     */
    closeApplicationStatementModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in Terms Agreement Modal" + error);
        }
    };

    /**
     * @function : handleOnClick
     * @description : This method is used to agree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = event => {
        let fieldValue;
        try {
            if (event.target.name === constants.signaturePage.Agree) {
                fieldValue = constants.toggleFieldValue.yes;
            } else {
                fieldValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: fieldValue
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in Terms Agreement Modal" + error);
        }
    };

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable the Buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    };

    /**
     * @function : renderedCallback
     * @description : This method is used to get the Meta Data values.
     */
    renderedCallback () {
        try {
            const divContainer = this.template.querySelector(
                ".ssp-TermsAgreementContentContainer"
            );

            const paddingBottom = 30;
            if (
                divContainer.scrollHeight - divContainer.scrollTop <
                divContainer.clientHeight + paddingBottom
            ) {
                this.disabled = false;
            }
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    }
}