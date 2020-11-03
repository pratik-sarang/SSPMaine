/*
 * Component Name: SspDocumentCenterPopup.
 * Author: Kyathi Kanumuri
 * Description: This screen is used for Document center Popup.
 * Date: 4/7/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspDocumentCenterPopupHeading from "@salesforce/label/c.SSP_DocumentCenterPopupHeading";
import sspDocumentCenterPopupContent1 from "@salesforce/label/c.SSP_DocumentCenterPopupContent1";
import sspDocumentCenterPopupContent2 from "@salesforce/label/c.SSP_DocumentCenterPopupContent2";
import sspDocumentCenterPopupContent3 from "@salesforce/label/c.SSP_DocumentCenterPopupContent3";
import sspDocumentCenterPopupContent4 from "@salesforce/label/c.SSP_DocumentCenterPopupContent4";
import sspGoToNextScreenTitle from "@salesforce/label/c.SSP_GoToNextScreenTitle";
import sspNextButton from "@salesforce/label/c.SSP_NextButton";
import { getYesNoOptions } from "c/sspUtility";
import apConstants from "c/sspConstants";

export default class SspDocumentCenterPopup extends LightningElement {
    @api openModel = false;
    @track reference = this;
    @track yesNoOptions = getYesNoOptions();
    @track trueValue = true;
    @track navigateToWizard = false;
    label = {
        sspDocumentCenterPopupHeading,
        sspDocumentCenterPopupContent1,
        sspDocumentCenterPopupContent2,
        sspDocumentCenterPopupContent3,
        sspDocumentCenterPopupContent4,
        sspNextButton,
        sspGoToNextScreenTitle
    };
    /**
     * @function : closeDocumentCenterModal
     * @description : Used to navigate based on toggle options.
     */
    closeDocumentCenterModal = () => {
        try {
            this.openModel = false;
            this.openModel = "";
        } catch (error) {
            console.error(
                "Error in closeDocumentCenterModal of Document Center Home screen" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleModalNextButton
     * @description : Used to close document center pop up modal.
     */
    handleModalNextButton = () => {
        try {
            this.closeDocumentCenterModal();
            if (this.navigateToWizard) {
                const navigateToWizard = new CustomEvent(
                    apConstants.events.navigateToWizardScreen
                );
                this.dispatchEvent(navigateToWizard);
            }
        } catch (error) {
            console.error(
                "Error in handleModalNextButton of Document Center Home screen" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : setModalToggleOption
     * @description : Used to set yes or no toggle option in modal.
     * @param  {object} event - Js Event.
     */
    setModalToggleOption = event => {
        try {
            if (event.detail === apConstants.toggleFieldValue.no) {
                this.navigateToWizard = false;
            } else {
                this.navigateToWizard = true;
            }
        } catch (error) {
            console.error(
                "Error in setModalToggleOption of Document Center Home screen" +
                    JSON.stringify(error.message)
            );
        }
    };
}