/*
 * Component Name: SspDocumentCenterWizWelcome.
 * Author: Kyathi Kanumuri,Aniket
 * Description: This screen is container for Start Uploading Forms Of Proof screen.
 * Date: 4/10/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspStartBenefitsExit from "@salesforce/label/c.SSP_StartBenefitsExit";
import sspStartProofUploadHeader from "@salesforce/label/c.SSP_StartProofUploadHeader";
import sspStartProofUploadContent1 from "@salesforce/label/c.SSP_StartProofUploadContent1";
import sspStartProofUploadContent2 from "@salesforce/label/c.SSP_StartProofUploadContent2";
import sspIdentifyEvidenceLabel from "@salesforce/label/c.SSP_IdentifyEvidenceLabel";
import sspIdentifyEvidenceContent1 from "@salesforce/label/c.SSP_IdentifyEvidenceContent1";
import sspIdentifyEvidenceContent2 from "@salesforce/label/c.SSP_IdentifyEvidenceContent2";
import sspUploadDocument from "@salesforce/label/c.SSP_UploadDocument";
import sspUploadDocumentContent1 from "@salesforce/label/c.SSP_UploadDocumentContent1";
import sspUploadDocumentContent2 from "@salesforce/label/c.SSP_UploadDocumentContent2";
import sspStartUploading from "@salesforce/label/c.SSP_StartUploading";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspBackgroundIcons from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspKynectImages from "@salesforce/resourceUrl/SSP_KynectImages5";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import { url, events } from "c/sspConstants";
import sspStartUploadingTitle from "@salesforce/label/c.SSP_StartUploadingTitle";
import sspExitWizardTitle from "@salesforce/label/c.SSP_ExitWizardTitle";

export default class SspDocumentCenterWizWelcome extends LightningElement {
    @api showWelcome;
    @track trueValue = true;
    @track openExitWizardModel = false;
    label = {
        sspStartBenefitsExit,
        sspStartProofUploadHeader,
        sspStartProofUploadContent1,
        sspStartProofUploadContent2,
        sspIdentifyEvidenceLabel,
        sspIdentifyEvidenceContent1,
        sspIdentifyEvidenceContent2,
        sspUploadDocument,
        sspUploadDocumentContent2,
        sspStartUploading,
        sspExitButton,
        sspUploadDocumentContent1,
        sspStartUploadingTitle,
        sspExitWizardTitle
    };
    mobileBackgroundImage =
        sspKynectImages + "/getStartedUploadingFormsMobile.jpg";
    desktopBackgroundImage = sspKynectImages + "/getStartedUploadingForms.png";
    identifyEvidenceIcon = sspIcons + url.fileLargeIcon;
    uploadDocumentIcon = sspIcons + url.laptopLargeIcon;
    mobileSideBackground = sspIcons + url.mobileBackgroundImage;
    desktopSideBackground = sspIcons + url.renewalApplicationBackgroundImage;
    bluePolygon = sspBackgroundIcons + url.bluePolygon;
    purplePolygon = sspBackgroundIcons + url.purplePolygon;
    yellowPolygon = sspBackgroundIcons + url.yellowPolygon;
    greyPolygon = sspBackgroundIcons + url.greyPolygon;
    /**
     * @function : startUploading
     * @description : Function used to Exit from current page.
     */
    startUploading = () => {
        try {
            const event = new CustomEvent(events.loadRFIIteration, {
                detail: "NEXT"
            });
            // Fire the event from model 3
            this.dispatchEvent(event);
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            console.error(
                "Error in startUploading of SspDocumentCenterWizWelcome" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : redirectDocCenterHome
     * @description : Function used to navigate to  upload page .
     */
    redirectDocCenterHome = () => {
        try {
            this.openExitWizardModel = true;
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            console.error(
                "Error in redirectDocCenterHome of SspDocumentCenterWizWelcome" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : closeExitWizardModel
     * @description : Function used to close Exit Wizard Model.
     */
    closeExitWizardModel = () => {
        try {
            this.openExitWizardModel = false;
            this.openExitWizardModel = "";
        } catch (error) {
            console.error(
                "Error in closeExitWizardModel of SspDocumentCenterWizWelcome" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : connectedCallback
     * @description : This method is used to scroll to the top.
     */
    connectedCallback () {
        try {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }
}