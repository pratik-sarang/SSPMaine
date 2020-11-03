/*
 * Component Name: sspGetInterpreterModal.
 * Author: Karthik Velu, Kochar Varun.
 * Description: This modal is shown when user selects other languages.
 * Date: 2/27/2020.
 **/
import { LightningElement, api, track } from "lwc";
import apConstants from "c/sspConstants";
import sspGetInterpreterHeader from "@salesforce/label/c.SSP_GetInterpreterModalHeader";
import sspIfYouDoNot from "@salesforce/label/c.SSP_GetInterpreterModalIfYouDoNot";
import sspContinueInEnglish from "@salesforce/label/c.SSP_GetInterpreterModalContinueInEnglish";
import sspGetGetInterpreterModalDetail from "@salesforce/apex/SSP_GetInterpreterModalCtrl.getGetInterpreterModalDetail";
export default class SspGetInterpreterModal extends LightningElement {
    @api selectedLanguage;
    @track sspGetInterpreterModalWrapper;
    @track isComponentLoaded = false;
    @track rightSideLanguage = false;
    @track reference = this;
    label = {
        sspGetInterpreterHeader,
        sspIfYouDoNot,
        sspContinueInEnglish
    };

    /**
     * @function : connectedCallback.
     * @description : Fire an event from connectedCallback to load Interpreter Modal details.
     */
    connectedCallback () {
        try {
            sspGetGetInterpreterModalDetail({
                selectedLanguage: this.selectedLanguage
            })
                .then(result => {
                    this.sspGetInterpreterModalWrapper = JSON.parse(
                        JSON.stringify(result.mapResponse.wrapper)
                    );
                    this.isComponentLoaded = true;
                })
                .catch(error => {
                    console.error(
                        "Error in SspGetInterpreterModal screen" +
                            JSON.stringify(error)
                    );
                });
            if (this.selectedLanguage === apConstants.languageOptions.Arabic) {
                this.rightSideLanguage = true;
            } else {
                this.rightSideLanguage = false;
            }
        } catch (error) {
            console.error(
                "Error in SspGetInterpreterModal screen" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : closeModal.
     * @description : Method to close modal.
     * @param {*}event - Fired while closing the modal.
     */
    closeModal = event => {
        try {
            event.preventDefault();
            const languageModal = new CustomEvent(apConstants.events.closeModal, {
                detail: false
            });
            this.dispatchEvent(languageModal);
        } catch (error) {
            console.error(
                "Error in SspGetInterpreterModal screen" +
                    JSON.stringify(error.message)
            );
        }
    };
}