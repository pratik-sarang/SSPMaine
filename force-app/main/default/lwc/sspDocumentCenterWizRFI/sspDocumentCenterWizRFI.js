/*
 * Component Name: sspDocumentCenterWizard.
 * Author: Aniket Shinde,Kyathi
 * Description: This screen is used for Document Wizard Navigation through RFIs.
 * Date: 4/10/2020.
 */
import { LightningElement, api, track } from "lwc";
import { events } from "c/sspConstants";

export default class SspDocumentCenterWizRFI extends LightningElement {
    @api currentRFI;
    @api showRFI;
    @api totalRFICount;
    @api currentRFIIndex;
    @track showProofs = true;
    @track showUpload = false;
    @track selectedProof;
    /**
     * @function : connectedCallback
     * @description : Used to set variables on page load.
     */
    connectedCallback = () => {
        try {
            this.showProofs = true;
            this.showUpload = false;
        } catch (error) {
            console.error(
                "Error in connectedCallback of SspDocumentCenterWizRFI" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : initRFI
     * @description : Used to load Next RFI.
     */
    initRFI = () => {
        this.showProofs = true;
        this.showUpload = false;
    }

    /**
     * @function : applyChanges
     * @description : Apply changes for rfi track property.
     */
    @api
    applyChanges () {
        this.template
            .querySelector("c-ssp-document-center-proof")
            .applyChanges();
    }

    /**
     * @function : loadNextRFI
     * @description : Used to load Next RFI.
     */
    loadNextRFI = () => {
        try {
            const event = new CustomEvent(events.loadNextRFI, {
                detail: "NEXT"
            });
            // Fire the event from model 3
            this.dispatchEvent(event);
            this.showProofs = true;
            this.showUpload = false;
        } catch (error) {
            console.error(
                "Error in loadNextRFI of SspDocumentCenterWizRFI" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : renderUpload
     * @description : Used to render upload screen.
     *  @param {object} event - Js event.
     */
    renderUpload = event => {
        try {
            this.selectedProof = event.detail.selectedProof;
            this.showProofs = false;
            this.showUpload = true;
        } catch (error) {
            console.error(
                "Error in renderUpload of SspDocumentCenterWizRFI" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : closeWizard
     * @description : Used to close wizard screen.
     */
    closeWizard = () => {
        // eslint-disable-next-line no-empty
        try {
        } catch (error) {
            console.error(
                "Error in closeWizard of SspDocumentCenterWizRFI" +
                    JSON.stringify(error.message)
            );
        }
    };
}