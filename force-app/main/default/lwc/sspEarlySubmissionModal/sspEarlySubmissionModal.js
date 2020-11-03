/**
 * Component Name: sspEarlySubmissionModal.
 * Author: Karthik Velu.
 * Description: This component is used to enter early submission screen.
 * Date: 1/13/2020.
 */
import { api, track } from "lwc";
import { events } from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspAreYou from "@salesforce/label/c.SSP_EarlySubmissionModalAreYou";
import sspIfYouChoose from "@salesforce/label/c.SSP_EarlySubmissionModalIfYouChoose";
import sspWeRecommend from "@salesforce/label/c.SSP_EarlySubmissionModalWeRecommend";
import sspContinueToSubmit from "@salesforce/label/c.SSP_EarlySubmissionModalContinueToSubmit";
import sspContinueApplication from "@salesforce/label/c.SSP_EarlySubmissionModalContinueApplication";
import sspSubmitApplicationNow from "@salesforce/label/c.SSP_EarlySubmissionModalSubmitApplicationNow";
import { updateRecord } from "lightning/uiRecordApi";
import baseNavFlowPage from "c/sspBaseNavFlowPage";

export default class SspEarlySubmissionModal extends NavigationMixin(
    baseNavFlowPage
) {
    @api applicationId;
    @api isOpenModal;
    @api mode;
    @track reference = this;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspAreYou,
        sspIfYouChoose,
        sspWeRecommend,
        sspContinueToSubmit,
        sspContinueApplication,
        sspSubmitApplicationNow
    };

    /**
     * @function : continueEarly
     * @description : This method is used to navigate to expedited benefits screen.
     */
    continueEarly = () => {
        try {
            const objApplication = {};
            objApplication["IsApplicationSubmittedEarly__c"] = "Y";
            const record = {
                recordId: this.applicationId,
                fields: objApplication
            };
            updateRecord(record)
                .then(() => 
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Sign_and_Submit__c"
                        },
                        state: {
                            applicationId: this.applicationId,
                            mode: this.mode
                        }
                    })
                )
                .catch(error => {
                    console.error("error", error);
                });
        } catch (error) {
            console.error("Error occurred in continueEarly" + error);
        }
    };

    /**
     * @function : closeModal
     * @description : This method is used to close the modal.
     */
    closeModal = () => {
        this.isOpenModal=false;
        const closeEvent = new CustomEvent(events.closeModal);
        this.dispatchEvent(closeEvent);
    };
}