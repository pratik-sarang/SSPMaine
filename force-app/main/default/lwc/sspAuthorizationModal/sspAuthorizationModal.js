/**
 * Component Name: SspAuthorizationModal.
 * Author: Kyathi.
 * Description: The component is used for Authorization Modal.
 * Date: 6/1/2020.
 */
import { LightningElement,api,track } from "lwc";
import sspAuthorizations from "@salesforce/label/c.SSP_Authorizations";
import sspAuthorizationsModalContent1 from "@salesforce/label/c.SSP_AuthorizationsModalContent1";
import sspAuthorizationsModalContent2 from "@salesforce/label/c.SSP_AuthorizationsModalContent2";
import sspAuthorizationsModalContent3 from "@salesforce/label/c.SSP_AuthorizationsModalContent3";
import sspAuthorizationsModalContent4 from "@salesforce/label/c.SSP_AuthorizationsModalContent4";
import sspAuthorizationsModalContent5 from "@salesforce/label/c.SSP_AuthorizationsModalContent5";
import sspAuthorizationsModalContent6 from "@salesforce/label/c.SSP_AuthorizationsModalContent6";
import sspAgreeButton from "@salesforce/label/c.SSP_Agree";
import sspDisagreeButton from "@salesforce/label/c.SSP_Disagree";
import sspAgreesToTerms from "@salesforce/label/c.SSP_AgreesToTerms";
import sspDisagreeToTerms from "@salesforce/label/c.SSP_DisagreeToTerms";
import constants from "c/sspConstants";
export default class SspAuthorizationModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue = true;
    @track disabled = true;
    @track reference = this;
    label = {
        sspAgreesToTerms,
        sspDisagreeToTerms,
        sspAuthorizations,
        sspAgreeButton,
        sspDisagreeButton,
        sspAuthorizationsModalContent1,
        sspAuthorizationsModalContent2,
        sspAuthorizationsModalContent3,
        sspAuthorizationsModalContent4,
        sspAuthorizationsModalContent5,
        sspAuthorizationsModalContent6
    }
     /** 
     * @function : connectedCallback
     * @description : This method is used to get the api values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }else {
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
                        sFieldName: "authorization"
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