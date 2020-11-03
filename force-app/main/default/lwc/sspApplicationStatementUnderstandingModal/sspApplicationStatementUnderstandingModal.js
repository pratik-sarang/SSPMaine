/**
 * Component Name: sspApplicationStatementUnderstandingModal.
 * Author: Sharon Roja.
 * Description: This component creates a screen for Application Statement of Understanding Modal.
 * Date: 26/01/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspKIHIPPConsentContentOne from "@salesforce/label/c.SSP_KIHIPPConsentContentOne";
import sspApplicationStatementHeader from "@salesforce/label/c.SSP_ApplicationStatementHeader";
import sspApplicationStatementSnapHeading from "@salesforce/label/c.SSP_ApplicationStatementSnapHeading";
import sspApplicationStatementKTAPHeading from "@salesforce/label/c.SSP_ApplicationStatementKTAPHeading";
import sspApplicationStatementMedicaidHeading from "@salesforce/label/c.SSP_ApplicationStatementMedicaidHeading";
import sspApplicationStatementUnderstandingText from "@salesforce/label/c.SSP_ApplicationStatementUnderstandingText";
import sspApplicationSnapOne from "@salesforce/label/c.SSP_ApplicationSnapOne";
import sspApplicationStatementLinkOne from "@salesforce/label/c.SSP_ApplicationStatementLinkOne";
import sspApplicationStatementLinkNextContent from "@salesforce/label/c.SSP_ApplicationStatementLinkNextContent";
import sspApplicationSnapTwo from "@salesforce/label/c.SSP_ApplicationSnapTwo";
import sspApplicationSnapThree from "@salesforce/label/c.SSP_ApplicationSnapThree";
import sspApplicationSnapFour from "@salesforce/label/c.SSP_ApplicationSnapFour";
import sspApplicationSnapFive from "@salesforce/label/c.SSP_ApplicationSnapFive";
import sspApplicationSnapSix from "@salesforce/label/c.SSP_ApplicationSnapSix";
import sspApplicationKTAPOne from "@salesforce/label/c.SSP_ApplicationKTAPOne";
import sspApplicationKTAPTwo from "@salesforce/label/c.SSP_ApplicationKTAPTwo";
import sspApplicationMedicaidOne from "@salesforce/label/c.SSP_ApplicationMedicaidOne";
import sspApplicationMedicaidTwo from "@salesforce/label/c.SSP_ApplicationMedicaidTwo";
import sspKIHIPPConsentContentTwo from "@salesforce/label/c.SSP_KIHIPPConsentContentTwo";
import sspKIHIPPConsentContentThree from "@salesforce/label/c.SSP_KIHIPPConsentContentThree";
import sspKIHIPPConsentContentFour from "@salesforce/label/c.SSP_KIHIPPConsentContentFour";
import sspKIHIPPConsentContentFive from "@salesforce/label/c.SSP_KIHIPPConsentContentFive";
import sspKIHIPPConsentContentSix from "@salesforce/label/c.SSP_KIHIPPConsentContentSix";
import sspKIHIPPConsentContentSeven from "@salesforce/label/c.SSP_KIHIPPConsentContentSeven";
import sspKIHIPPConsentContentEight from "@salesforce/label/c.SSP_KIHIPPConsentContentEight";
import sspKIHIPPConsentListOne from "@salesforce/label/c.SSP_KIHIPPConsentListOne";
import sspKIHIPPConsentListTwo from "@salesforce/label/c.SSP_KIHIPPConsentListTwo";
import sspKIHIPPConsentListThree from "@salesforce/label/c.SSP_KIHIPPConsentListThree";
import sspKIHIPPConsentListFour from "@salesforce/label/c.SSP_KIHIPPConsentListFour";
import sspKIHIPPConsentListFive from "@salesforce/label/c.SSP_KIHIPPConsentListFive";
import sspKIHIPPConsentListSix from "@salesforce/label/c.SSP_KIHIPPConsentListSix";
import sspKIHIPPConsentListSeven from "@salesforce/label/c.SSP_KIHIPPConsentListSeven";
import sspKIHIPPConsentListEight from "@salesforce/label/c.SSP_KIHIPPConsentListEight";
import sspKIHIPPConsentContentNineList from "@salesforce/label/c.SSP_KIHIPPConsentContentNineList";
import sspKIHIPPConsentContentListTen from "@salesforce/label/c.SSP_KIHIPPConsentContentListTen";
import sspKIHIPPConsentHeading from "@salesforce/label/c.SSP_KIHIPPConsentHeading";
import sspKIHIPPConsentOrderListTwo from "@salesforce/label/c.SSP_KIHIPPConsentOrderListTwo";
import sspKIHIPPConsentOrderListOne from "@salesforce/label/c.SSP_KIHIPPConsentOrderListOne";
import sspKIHIPPConsentOrderListThree from "@salesforce/label/c.SSP_KIHIPPConsentOrderListThree";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspApplicationStatementAgreeButtonAlternate from "@salesforce/label/c.SSP_ApplicationStatementAgreeButtonAlternate";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspApplicationStatementDisagreeButtonAlternate from "@salesforce/label/c.SSP_ApplicationStatementDisagreeButtonAlternate";


import constants from "c/sspConstants";

export default class SspApplicationStatementUnderstandingModal extends LightningElement {
    @api isSelectedValue = false;
    @api additionalInfoSnap = false;
    @api additionalInfoKTAP = false;
    @api additionalInfoMedicaid = false;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track openModel = true;
    @track trueValue;
    @track disabled = false;
    @track reference = this;
    @track entered = false;
    label = {
        sspApplicationStatementHeader,
        sspApplicationStatementSnapHeading,
        sspApplicationStatementKTAPHeading,
        sspApplicationStatementMedicaidHeading,
        sspApplicationStatementUnderstandingText,
        sspApplicationStatementLinkOne,
        sspApplicationStatementLinkNextContent,
        sspApplicationSnapOne,
        sspApplicationSnapTwo,
        sspApplicationSnapThree,
        sspApplicationSnapFour,
        sspApplicationSnapFive,
        sspApplicationSnapSix,
        sspApplicationKTAPOne,
        sspApplicationKTAPTwo,
        sspApplicationMedicaidOne,
        sspApplicationMedicaidTwo,
        sspKIHIPPConsentContentOne,
        sspKIHIPPConsentContentTwo,
        sspKIHIPPConsentContentFour,
        sspKIHIPPConsentContentFive,
        sspKIHIPPConsentContentSix,
        sspKIHIPPConsentContentSeven,
        sspKIHIPPConsentContentEight,
        sspKIHIPPConsentListOne,
        sspKIHIPPConsentListTwo,
        sspKIHIPPConsentListThree,
        sspKIHIPPConsentListFour,
        sspKIHIPPConsentListFive,
        sspKIHIPPConsentListSix,
        sspKIHIPPConsentListSeven,
        sspKIHIPPConsentListEight,
        sspKIHIPPConsentContentNineList,
        sspKIHIPPConsentContentListTen,
        sspKIHIPPConsentHeading,
        sspKIHIPPConsentOrderListOne,
        sspKIHIPPConsentOrderListTwo,
        sspKIHIPPConsentOrderListThree,
        sspAgreeButton,
        sspApplicationStatementAgreeButtonAlternate,
        sspKIHIPPConsentContentThree,
        sspDisagreeButton,
        sspApplicationStatementDisagreeButtonAlternate
    };
    /**
     * @function : disabledState
     * @description : Getter setter for disabled state.
     */
    @api
    get disabledState () {
        return this.disabled;
    }
    set disabledState (value) {
        if (value) {
            this.disabled = value;
        }
    }
    /**
     * @function : disabledState
     * @description : Getter setter for disabled state.
     */
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
            } else {
                this.disabled = true;
            }
        } catch (error) {
            console.error(
                "Error occurred in Application Statement of Understanding Modal" + error
            );
        }
    }
    
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
                fieldValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(constants.signaturePage.Close, {
                detail: {
                    sFieldValue: fieldValue,
                    sFieldName: "IsAgreeingToApplicationConsent__c"
                }
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in Application Statement of Understanding Modal" + error
            );
        }
    }

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable the Buttons in the Modal.
     */
    enableModalButtons = () => {
       this.disabled= false;
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
                        .querySelector(".ssp-applicationStatementModal")
                        .lessContentEnableButtons();
                    this.entered = true;
                }
            }
        } catch (error) {
            console.error("Error occurred in renderedCallback" + error);
        }
    }
}