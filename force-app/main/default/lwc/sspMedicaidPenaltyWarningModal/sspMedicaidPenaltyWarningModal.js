/*
 * Component Name: sspMedicaidPenaltyWarningModal.
 * Author: Karthik Velu, Sai Kiran.
 * Description: This component opens the Medicaid Penalty Warning Modal.
 * Date: 1/29/2020.
 **/
import { LightningElement, track, api } from "lwc";
import sspMedicaidPenaltyTitle from "@salesforce/label/c.SSP_MedicaidPenaltyWarningHeader";
import sspMedicaidRecipients from "@salesforce/label/c.SSP_MedicaidPenaltyWarningMedicaidRecipients";
import sspMedicaidRecipients2 from "@salesforce/label/c.SSP_MedicaidPenaltyWarningMedicaidRecipients2";
import sspTheRules from "@salesforce/label/c.SSP_MedicaidPenaltyWarningTheRules";
import sspDoNotGive from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDoNotGive";
import sspDoNotLet from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDoNotLet";
import sspDoNotAbuse from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDoNotAbuse";
import sspAllApplications from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAllApplicants";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspAgreeButtonAlternate from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgreeAlternate";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspDisagreeButtonAlternate from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagreeAlternate";
import sspUnderstandThat from "@salesforce/label/c.SSP_MedicaidPenaltyWarningUnderstandThat";
import constants from "c/sspConstants";
export default class SspMedicaidPenaltyWarningModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue;
    @track disabled = true;
    @track reference = this;
    @track entered = false;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspMedicaidPenaltyTitle,
        sspMedicaidRecipients,
        sspMedicaidRecipients2,
        sspTheRules,
        sspDoNotGive,
        sspDoNotLet,
        sspDoNotAbuse,
        sspAllApplications,
        sspAgreeButton,
        sspAgreeButtonAlternate,
        sspDisagreeButton,
        sspDisagreeButtonAlternate,
        sspUnderstandThat
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
     * @function : connectedCallback.
     * @description : This method is used to get the Meta Data values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }
        } catch (error) {
            console.error("Error occurred in connectedCallback" + error);
        }
    }

    /**
     * @function : closeMedicaidModal.
     * @description : This method is used to close the Modal.
     */
    closeMedicaidModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in closeMedicaidModal" + error);
        }
    };

    /**
     * @function : handleOnClick.
     * @description : This method is used to agree/disAgree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = event => {
        try {
            const eventName = event.target.name;
            let fieldValue;
            if (eventName === constants.signaturePage.Agree) {
                fieldValue = constants.toggleFieldValue.yes;
            } else {
                fieldValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: {
                        sFieldValue: fieldValue,
                        sFieldName: "IsAgreeingToMedicaidPenalty__c"
                    }
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in agreeMedicaidModal" + error);
        }
    };

    /**
     * @function : enableModalButtons.
     * @description : This method is used to enable the buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error("Error occurred in enableModalButtons" + error);
        }
    };
    /**
     * @function : renderedCallback.
     * @description : This method is used to execute after html rendering.
     */
    renderedCallback () {
        try {
            if (!this.entered) {
                if (this.template.querySelector(".ssp-mainContent")) {
                    this.template
                        .querySelector(".ssp-MedicaidPenaltyWarningModal")
                        .lessContentEnableButtons();
                    this.entered = true;
                }
            }
        } catch (error) {
            console.error("Error occurred in renderedCallback" + error);
        }
    }
}