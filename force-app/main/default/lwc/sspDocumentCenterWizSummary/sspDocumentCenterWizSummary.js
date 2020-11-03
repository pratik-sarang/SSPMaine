/*
 * Component Name: SspDocumentCenterWizSummary.
 * Author: Aniket Shinde,Kyathi
 * Description: This screen is used for Submitted Documents Page.
 * Date: 4/13/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspSubmittedDocuments from "@salesforce/label/c.SSP_SubmittedDocuments";
import sspSubmittedDocumentsContent1 from "@salesforce/label/c.SSP_SubmittedDocumentsContent1";
import sspSubmittedDocumentsContent2 from "@salesforce/label/c.SSP_SubmittedDocumentsContent2";
import sspBackToDocumentCenter from "@salesforce/label/c.SSP_BackToDocumentCenter";
import sspBackToDocumentCenterTitle from "@salesforce/label/c.SSP_BackToDocumentCenterTitle";
import { url, events } from "c/sspConstants";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";

export default class SspDocumentCenterWizSummary extends LightningElement {
    @api showSummary;
    @api uploadedFileSummary;
    @track trueValue = true;
    @track showSpinner = false;
    label = {
        sspSubmittedDocuments,
        sspSubmittedDocumentsContent1,
        sspSubmittedDocumentsContent2,
        sspBackToDocumentCenter,
        sspBackToDocumentCenterTitle
    };
    backgroundImg = sspIcons + url.mobileBackgroundImage;

    /**
     * @function : redirectDocCenterHome
     * @description : Used to redirect to Document center Home.
     */
    redirectDocCenterHome = () => {
        const event = new CustomEvent(events.showDocumentCenterHome, {
            bubbles: true,
            composed: true,
            detail: "Show Home"
        });
        // Fire the event from model 3
        this.dispatchEvent(event);
    };
}