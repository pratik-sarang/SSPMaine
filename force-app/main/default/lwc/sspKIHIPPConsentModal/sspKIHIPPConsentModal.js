/**
 * Component Name: sspKIHIPPConsentModal.
 * Author: Sharon Roja.
 * Description: This component creates a screen for KI-HIPP Consent Modal.
 * Date: 04/02/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspKIHIPPConsentHeader from "@salesforce/label/c.SSP_KIHIPPConsentHeader";
import sspKIHIPPConsentContentModalOne from "@salesforce/label/c.SSP_KIHIPPConsentContentModalOne";
import sspKIHIPPConsentModalListOne from "@salesforce/label/c.SSP_KIHIPPConsentModalListOne";
import sspKIHIPPConsentModalListTwo from "@salesforce/label/c.SSP_KIHIPPConsentModalListTwo";
import sspKIHIPPConsentModalListTwoLink from "@salesforce/label/c.SSP_KIHIPPConsentModalListTwoLink";
import sspKIHIPPConsentModalListThree from "@salesforce/label/c.SSP_KIHIPPConsentModalListThree";
import sspKIHIPPConsentModalListFour from "@salesforce/label/c.SSP_KIHIPPConsentModalListFour";
import sspKIHIPPConsentModalListFive from "@salesforce/label/c.SSP_KIHIPPConsentModalListFive";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspKIHIPPConsentAgreeButton from "@salesforce/label/c.SSP_KIHIPPConsentAgreeButton";
import sspKIHIPPConsentDisagreeButtonAlternate from "@salesforce/label/c.SSP_KIHIPPConsentDisagreeButtonAlternate";
import constants from "c/sspConstants";

export default class SspKIHIPPConsentModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue;
    @track disabled = true;
    @track reference = this;
    @track entered = false;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspKIHIPPConsentHeader,
        sspKIHIPPConsentContentModalOne,
        sspKIHIPPConsentModalListTwo,
        sspKIHIPPConsentModalListTwoLink,
        sspKIHIPPConsentModalListThree,
        sspKIHIPPConsentModalListFour,
        sspKIHIPPConsentModalListFive,
        sspAgreeButton,
        sspKIHIPPConsentAgreeButton,
        sspKIHIPPConsentModalListOne,
        sspDisagreeButton,
        sspKIHIPPConsentDisagreeButtonAlternate
    };

    get buttonDisability () {
        return this.disabled || this.isReadOnlyUser;
    }

    @api
    get scrollFunction () {
        return this.trueValue;
    }
    set scrollFunction (value) {
        if (!value) {
            this.trueValue = false;
        } else {
            this.trueValue = true;
        }
    }
    /**
     * @function : connectedCallback
     * @description : This method is used to get the api values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }
        } catch (error) {
            console.error(
                "Error occurred in KI-HIPP Consent Modal" + error
            );
        }
    }

    /**
     * @function : closeKIHIPPConsentModal
     * @description : This method is used to close the KI-HIPP Consent.
     */
    closeKIHIPPConsentModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch(error) {
            console.error("Error occurred in Application Statement of Understanding Modal" + error);
        }
    }

    /**
     * @function : handleOnClick
     * @description : This method is used to agree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = (event) => {
        let fieldValue;
        try {
            if (event.target.name === constants.signaturePage.Agree) {
                fieldValue = constants.toggleFieldValue.yes;
            } else {
                fieldValue = fieldValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: {
                        sFieldValue: fieldValue,
                        sFieldName: "IsAgreeingToKiHippConsent__c"
                    }
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in KI-HIPP Consent Modal" + error);
        }
    }

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable buttons in KI-HIPP Consent Modal.
     */

    enableModalButtons =  () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error("Error occurred in KI-HIPP Consent Modal" + error);
        }
    }
     /**
     * @function : renderedCallback.
     * @description : This method is used to execute after html rendering.
     */
    renderedCallback () {
        try {
            if (!this.entered) {
                if (this.template.querySelector(".ssp-mainContent")) {
                    this.template
                        .querySelector(".ssp-kIHIPPConsentModal")
                        .lessContentEnableButtons();
                    this.entered = true;
                }
            }
        } catch (error) {
            console.error("Error occurred in renderedCallback" + error);
        }
    }
    
}