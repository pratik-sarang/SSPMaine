import { LightningElement, api } from "lwc";
import nextStep from "@salesforce/label/c.SSP_NextStep";
import hearingNextStepsContentOne from "@salesforce/label/c.SSP_HearingNextStepsContentOne";
import hearingNextStepsContentTwo from "@salesforce/label/c.SSP_HearingNextStepsContentTwo";
import hearingNextStepsContentThree from "@salesforce/label/c.SSP_HearingNextStepsContentThree";
import haringNextStepsContentFour from "@salesforce/label/c.SSP_HearingNextStepsContentFour";
import uploadDocument from "@salesforce/label/c.SSP_UploadDocumentCenterDocuments";
import backHearingsSummary from "@salesforce/label/c.SSP_BackHearingsSummary";
import sspConstants from "c/sspConstants";

export default class SspHearingNextSteps extends LightningElement {
    label = {
        nextStep,
        hearingNextStepsContentOne,
        hearingNextStepsContentTwo,
        hearingNextStepsContentThree,
        haringNextStepsContentFour,
        uploadDocument,
        backHearingsSummary
    }

    @api hearingId;

    /**
     * @function - connectedCallback
     * @description - Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
           
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }

    /**
     * @function : backToHearingSummary
     * @description : This method is used to save the collected data.
     */
    backToHearingSummary () {
        try {
            this.dispatchEvent(new CustomEvent(sspConstants.hearing.closeNextStep));
        } catch (error) {
            console.error("Error in backToHearingSummary", error);
        }
    }

     /**
     * @function : navigateToDocumentUpload
     * @description : This method is used to save the collected data.
     */
    navigateToDocumentUpload () {
        try {
            this.dispatchEvent(new CustomEvent(sspConstants.hearing.navigateToUpload));
        } catch (error) {
            console.error("Error in navigateToDocumentUpload", error);
        }
    }
}