/**
 * Component Name: SspAcknowledgeAssisterModal.
 * Author: Kyathi.
 * Description: The component is used for Acknowledge consent modal.
 * Date: 6/1/2020.
 */
import { LightningElement,api,track } from "lwc";
import sspAgreeButton from "@salesforce/label/c.SSP_Agree";
import sspDisagreeButton from "@salesforce/label/c.SSP_Disagree";
import sspAgreesToTerms from "@salesforce/label/c.SSP_AgreesToTerms";
import sspDisagreeToTerms from "@salesforce/label/c.SSP_DisagreeToTerms";
import sspAcknowledgeRoleModalHeader from "@salesforce/label/c.SSP_AcknowledgeRoleModalHeader";
import sspAcknowledgeRoleModalContent1 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent1";
import sspAcknowledgeRoleModalContent2 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent2";
import sspAcknowledgeRoleModalContent3 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent3";
import sspAcknowledgeRoleModalContent4 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent4";
import sspAcknowledgeRoleModalContent5 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent5";
import sspAcknowledgeRoleModalContent6 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent6";
import sspAcknowledgeRoleModalContent7 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent7";
import sspAcknowledgeRoleModalContent8 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent8";
import sspAcknowledgeRoleModalContent9 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent9";
import sspAcknowledgeRoleModalContent10 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent10";
import sspAcknowledgeRoleModalContent11 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent11";
import sspAcknowledgeRoleModalContent12 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent12";
import sspAcknowledgeRoleModalContent13 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent13";
import sspAcknowledgeRoleModalContent14 from "@salesforce/label/c.SSP_AcknowledgeRoleModalContent14";
import constants from "c/sspConstants";
export default class SspAcknowledgeAssisterModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue = true;
    @track disabled = true;
    @track reference = this;
    label = {
        sspAgreesToTerms,
        sspDisagreeToTerms,
        sspAgreeButton,
        sspDisagreeButton,
        sspAcknowledgeRoleModalHeader,
        sspAcknowledgeRoleModalContent1,
        sspAcknowledgeRoleModalContent2,
        sspAcknowledgeRoleModalContent3,
        sspAcknowledgeRoleModalContent4,
        sspAcknowledgeRoleModalContent5,
        sspAcknowledgeRoleModalContent6,
        sspAcknowledgeRoleModalContent7,
        sspAcknowledgeRoleModalContent8,
        sspAcknowledgeRoleModalContent9,
        sspAcknowledgeRoleModalContent10,
        sspAcknowledgeRoleModalContent11,
        sspAcknowledgeRoleModalContent12,
        sspAcknowledgeRoleModalContent13,
        sspAcknowledgeRoleModalContent14
    }
     /** 
     * @function : connectedCallback
     * @description : This method is used to get the api values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            } else {
                this.disabled = true;
            }
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback" + error
            );
        }
    }
      /**
     * @function : closeConsentModal
     * @description : This method is used to close  Consent.
     */
    closeConsentModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch(error) {
            console.error("Error occurred in closeConsentModal" + error);
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
            console.error("Error occurred in enableModalButtons" + error);
        }
    }
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
                fieldValue = true;
            } else {
                fieldValue = false;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {   
                    detail: {
                        sFieldValue: fieldValue,
                        sFieldName: "acknowledgeRoles"
                    }
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in handleOnClick" + error
            );
        }
    };
}