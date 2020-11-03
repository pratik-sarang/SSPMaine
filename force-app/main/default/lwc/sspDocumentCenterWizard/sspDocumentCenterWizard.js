/*
 * Component Name: sspDocumentCenterWizard.
 * Author: Aniket Shinde
 * Description: This screen is used for Document Wizard.
 * Date: 4/10/2020.
 */
import { LightningElement, track, api } from "lwc";
import { formatLabels } from "c/sspUtility";
import sspProofType from "@salesforce/label/c.SSP_ProofType";
import { events } from "c/sspConstants";

export default class SspDocumentCenterWizard extends LightningElement {
    @api RFIWrapper = false;
    @track currentRFIIndex;
    @track totalRFICount;
    @track currentRFI;
    @track showWelcome = false;
    @track showRFI = false;
    @track showSummary = false;
    @track wizardWrapper = [];
    @track showSpinner=false;
    @track uploadedFileSummary=[];

    label = {
        sspProofType
    };

    /**
     * @function : connectedCallback
     * @description : Used to set variables on load of page.
     */
    connectedCallback () {
        try {
            this.showSpinner=true;
            this.parseRFIWrapForWiz();
            this.initWizard();
        } catch (error) {
            console.error(
                "Error in connectedCallback of SspDocumentCenterWizard" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : parseRFIWrapForWiz
     * @description : Parse RFI Wrap For Wizard screens.
     */
    parseRFIWrapForWiz = () => {
        try{
            let interimArray = [];
            this.RFIWrapper.forEach(wrap => {
                interimArray=interimArray.concat(wrap.individualData);
            });
            interimArray.forEach(wrap => {
                const wrapElement = {};
                wrapElement.name = wrap.sFullName;
                wrapElement.individualId = wrap.iIndividualId;
                wrapElement.CaseNo = wrap.iCaseNumber;
                wrapElement.RFI = wrap.sTypeOfProof;
                wrapElement.RFICode = wrap.sTypeOfProofRefCode;
                wrapElement.RFIIdentifier = wrap.sUniqueIdentifier;
                wrapElement.recordIdentifier = wrap.sRecordIdentifier;
                wrapElement.isEligibleForRenewal = wrap.isEligibleForRenewal;
                wrapElement.sDueDate = wrap.sDueDate;
                this.wizardWrapper.push(wrapElement);
            });
        } catch (error) {
            console.error(
                "Error in connectedCallback of parseRFIWrapForWiz" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : initWizard
     * @description : Init data for wizard. Called at welcome screen.
     */
    initWizard = () => {
        try{
            if (this.wizardWrapper && this.wizardWrapper.length > 0) {
                // Show welcome Screen
                this.showWelcome = true;
                this.showRFI = false;
                this.showSummary = false;
                this.totalRFICount = this.wizardWrapper.length;
            }
            this.showSpinner=false;
        } catch (error) {
            console.error(
                "Error in connectedCallback of initWizard" +
                    JSON.stringify(error.message)
            );
            this.showSpinner=false;
        }
    }

    /**
     * @function : prepareWizardNavForRFI
     * @description : Used to process Wizard Navigation.
     */
    prepareWizardNavForRFI = () => {
        try {
            this.currentRFIIndex = 0;
            this.currentRFI = this.wizardWrapper[this.currentRFIIndex];
        } catch (error) {
            console.error(
                "Error in prepareWizardNavForRFI of SspDocumentCenterWizard" +
                    JSON.stringify(error.message)
            );
        }
    };

    
    /**
     * @function : renderRFI
     * @description : Show RFI Screen. Event from Welcome wizard screen.
     */
    renderRFIScreen = () => {
        try {
            // screen rendering
            this.showWelcome = false;
            this.showRFI = true;
            this.showSummary = false;
            this.prepareWizardNavForRFI();
        } catch (error) {
            console.error(
                "Error in renderRFIScreen of SspDocumentCenterWizard" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : processNextRFI
     * @description : Used to process Next RFI.
     */
    processNextRFI = () => {
        try {
            this.showSpinner=true;
            this.currentRFIIndex = this.currentRFIIndex + 1;
            if (this.currentRFIIndex < this.wizardWrapper.length) {
               
                this.currentRFI = this.wizardWrapper[this.currentRFIIndex];
                
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(()=>this.template.querySelector("c-ssp-document-center-wiz-r-f-i").applyChanges());
               
            } else {
                this.renderSummary();
                // Show Summary Screen
            }
            this.showSpinner=false;
        } catch (error) {
            console.error(
                "Error in processNextRFI of SspDocumentCenterWizard" +
                    JSON.stringify(error.message)
            );
            this.showSpinner=false;
        }
    };

    /**
     * @function : renderSummary
     * @description : Used to render summary screen.
     */
    renderSummary = () => {
        try {
            // screen rendering
            if(this.uploadedFileSummary && this.uploadedFileSummary.length > 0){
                this.showWelcome = false;
                this.showRFI = false;
                this.showSummary = true;
            }
            else{
                const event = new CustomEvent(events.showDocumentCenterHome, {
                    bubbles: true,
                    composed: true,
                    detail: "Show Home"
                });
                this.dispatchEvent(event);                
            }
        } catch (error) {
            console.error(
                "Error in renderSummary of SspDocumentCenterWizard" +
                    JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : singleFileUploaded
     * @description	: uploaded single file
	 * @param {event} evt - Gets current value
     */
    collectUploadedFiles = evt => {
        const uploadedFiles = evt.detail;
        if(uploadedFiles && uploadedFiles.length > 0){
            const uploadDetails = {};
            uploadDetails.individualName = this.currentRFI.name;
            uploadDetails.typeOfProof = this.currentRFI.RFI;
            uploadDetails.individualId = this.individualId;
            //uploadDetails.cardHeader = this.currentRFI.name + "'s " +this.currentRFI.RFI;
            uploadDetails.cardHeader = formatLabels(this.label.sspProofType, [
                this.currentRFI.name,
                this.currentRFI.RFI
            ]);
            /* uploadedFiles wrapper details
                proofName > form of proof name
                fileName > file name
            */
           uploadDetails.uploadList = JSON.parse(JSON.stringify(uploadedFiles));
           this.uploadedFileSummary.push(uploadDetails);
        }
    }
}