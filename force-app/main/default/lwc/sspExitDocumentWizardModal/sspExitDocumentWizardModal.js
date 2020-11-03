/*
 * Component Name: SspExitDocumentWizardModal.
 * Author: Kyathi Kanumuri
 * Description: This screen is container for Exit wizard modal.
 * Date: 4/15/2020.
 */
import { LightningElement, track, api } from "lwc";

import sspExitDocumentWizard from "@salesforce/label/c.SSP_ExitDocumentWizard";
import sspExitWizardContent from "@salesforce/label/c.SSP_ExitWizardContent";
import sspExitDocumentCenter from "@salesforce/label/c.SSP_ExitDocumentCenter";
import sspContinueUploading from "@salesforce/label/c.SSP_ContinueUploading";
import sspExitWizardModalTitle from "@salesforce/label/c.SSP_ExitWizardModalTitle";
import sspContinueUploadingTitle from "@salesforce/label/c.SSP_ContinueUploadingTitle";
import { events } from "c/sspConstants";

export default class SspExitDocumentWizardModal extends LightningElement {
    @api openModel = false;
    @track reference = this;
    label = {
        sspExitDocumentWizard,
        sspExitWizardContent,
        sspExitDocumentCenter,
        sspContinueUploading,
        sspExitWizardModalTitle,
        sspContinueUploadingTitle
    };
    /**
     * @function : closeModal
     * @description : Used to close Modal.
     */
    closeModal = () => {
        try {
            this.openModel = false;
            this.openModel = "";
            this.dispatchEvent(CustomEvent(events.closeModal));
        } catch (error) {
            console.error(
                "Error in closeModal of Exit Document Wizard Modal" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : exitDocumentCenter
     * @description : Used to go back to Document Center Home Page.
     */
    exitDocumentCenter = () => {
        try {
            const event = new CustomEvent(events.showDocumentCenterHome, {
                bubbles: true,
                composed: true,
                detail: "Show Home"
            });
            this.dispatchEvent(event);
        } catch (error) {
            console.error(
                "Error in exitDocumentCenter of Exit Document Wizard Modal" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : continueUploading
     * @description : Used to navigate to next screen.
     */
    continueUploading = () => {
        try {
            const event = new CustomEvent(events.loadRFIIteration, {
                detail: "NEXT"
            });
            this.dispatchEvent(event);
        } catch (error) {
            console.error(
                "Error in continueUploading of Exit Document Wizard Modal" +
                    JSON.stringify(error.message)
            );
        }
    };
}