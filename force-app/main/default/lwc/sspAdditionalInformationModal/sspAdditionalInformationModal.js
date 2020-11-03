/**
 * Component Name: SspAdditionalInformationModal.
 * Author: Kyathi.
 * Description: The component is used for AdditionalInformationModal.
 * Date: 6/1/2020.
 */
import { LightningElement,api,track } from "lwc";
import sspAdditionalImportantInformation from "@salesforce/label/c.SSP_AdditionalImportantInformation";
import sspAdditionalInfoModalContent1 from "@salesforce/label/c.SSP_AdditionalInfoModalContent1";
import sspAdditionalInfoModalContent2 from "@salesforce/label/c.SSP_AdditionalInfoModalContent2";
import sspAdditionalInfoModalContent3 from "@salesforce/label/c.SSP_AdditionalInfoModalContent3";
import sspAdditionalInfoModalContent4 from "@salesforce/label/c.SSP_AdditionalInfoModalContent4";
import sspAdditionalInfoModalContent5 from "@salesforce/label/c.SSP_AdditionalInfoModalContent5";
import sspAdditionalInfoModalContent6 from "@salesforce/label/c.SSP_AdditionalInfoModalContent6";
import sspAdditionalInfoModalContent7 from "@salesforce/label/c.SSP_AdditionalInfoModalContent7";
import sspAdditionalInfoModalContent8 from "@salesforce/label/c.SSP_AdditionalInfoModalContent8";
import sspAdditionalInfoModalContent9 from "@salesforce/label/c.SSP_AdditionalInfoModalContent9";
import sspAgreeButton from "@salesforce/label/c.SSP_Agree";
import sspDisagreeButton from "@salesforce/label/c.SSP_Disagree";
import sspAgreesToTerms from "@salesforce/label/c.SSP_AgreesToTerms";
import sspDisagreeToTerms from "@salesforce/label/c.SSP_DisagreeToTerms";
import constants from "c/sspConstants";
export default class SspAdditionalInformationModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue = true;
    @track disabled = true;
    @track reference = this;
    label = {
        sspAgreesToTerms,
        sspDisagreeToTerms,
        sspAdditionalInfoModalContent1,
        sspAdditionalInfoModalContent2,
        sspAdditionalInfoModalContent3,
        sspAdditionalInfoModalContent4,
        sspAdditionalInfoModalContent5,
        sspAdditionalInfoModalContent6,
        sspAdditionalInfoModalContent7,
        sspAdditionalInfoModalContent8,
        sspAdditionalInfoModalContent9,
        sspAdditionalImportantInformation,
        sspAgreeButton,
        sspDisagreeButton
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
    } /**
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
                       sFieldName: "additionalInfo"
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