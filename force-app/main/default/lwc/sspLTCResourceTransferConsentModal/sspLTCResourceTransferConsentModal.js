/**
 * Component Name: sspLTCResourceTransferConsentModal.
 * Author: Sharon Roja.
 * Description: This component creates a modal for LTC Resource Transfer Consent.
 * Date: 04/02/2020.
 */
import { track, api } from "lwc";
import sspLTCResourceTransferConsentModalHeader from "@salesforce/label/c.SSP_LTCResourceTransferConsentModalHeader";
import sspLTCResourceTransferConsentModalContent from "@salesforce/label/c.SSP_LTCResourceTransferConsentModalContent";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspAgreeButtonAlternate from "@salesforce/label/c.SSP_LTCReportConsentAgreeAlt";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspDisagreeButtonAlternate from "@salesforce/label/c.SSP_LTCReportConsentDisagreeAlt";
import constants from "c/sspConstants";
import utility, { formatLabels} from "c/sspUtility";


export default class SspLTCResourceTransferConsentModal extends utility {
    @api isSelectedValue = false;
    @api sHouseHoldSpouseName;
    @track openModel = true;
    @track trueValue;
    @track disabled = true;
    @track sspLTCResourceTransferConsentModalContent;
    @track reference = this;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspLTCResourceTransferConsentModalHeader,
        sspAgreeButton,
        sspAgreeButtonAlternate,
        sspDisagreeButton,
        sspDisagreeButtonAlternate
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
     * @description : This method is used to get the Meta Data values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }
            this.sspLTCResourceTransferConsentModalContent = formatLabels(
                sspLTCResourceTransferConsentModalContent,
                [this.sHouseHoldSpouseName]);
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    }

    /** 
     * @function : renderedCallback
     * @description : This method is used to get the Meta Data values.
     */
    renderedCallback () {
        try {
            const divContainer = this.template.querySelector(
                ".ssp-resourceTransferContentContainer"
            );
            const paddingBottom = 30;
            if (this.trueValue) {
                if (
                    divContainer.scrollHeight - divContainer.scrollTop <
                    divContainer.clientHeight + paddingBottom
                ) {
                    this.disabled = false;
                }
            }
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    }

    /**
     * @function : closeResourceTransferModal
     * @description : This method is used to close the modal.
     */
    closeResourceTransferModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    }

    /**
     * @function : handleOnClick
     * @description : This method is used to agree/disagree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = (event) => {
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
                    detail: {
                        sFieldValue: fieldValue,
                        sFieldName: "IsAgreeingToLTCResourceTransferConsent__c"
                    }
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in LTC Resource Transfer Consent Modal" + error
            );
        }
    }

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
    }
}