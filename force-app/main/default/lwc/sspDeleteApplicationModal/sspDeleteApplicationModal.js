import { LightningElement, api, track } from "lwc";

import sendNotificationAndDeleteApplication from "@salesforce/apex/SSP_DeleteApplicationController.sendNotificationAndDeleteApplication"
import sspDeleteApplication from "@salesforce/label/c.SSP_DeleteApplication";
import sspDeleteApplicationNote from "@salesforce/label/c.SSP_DeleteApplicationNote";
import sspYesDeleteApplication from "@salesforce/label/c.SSP_YesDeleteApplication";
import sspNoCancel from "@salesforce/label/c.SSP_NoCancel";

export default class SspDeleteApplicationModal extends LightningElement {
    @api applicationId;
    @api showPopup = false;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track showSpinner = false;

    customLabels = {
        sspDeleteApplication,
        sspDeleteApplicationNote,
        sspYesDeleteApplication,
        sspNoCancel
    };

    startDeleteFlow () {
        this.showSpinner = true;
        this.showPopup = false;
        sendNotificationAndDeleteApplication({
            applicationId: this.applicationId
        }).then(result => {
            if (result.bIsSuccess) {
                this.dispatchEvent(
                    new CustomEvent("success")
                );
            } else {
                this.showErrorModal = true;
                this.showSpinner = false;
                this.errorMsg = result.mapResponse.SERVICE_ERROR;
                this.showPopup = true;
                console.error(result.mapResponse.SERVICE_ERROR);
            }
            this.showSpinner = false;
        }).catch(error => {
            console.error(error);
        })
    }

    closeModal () {
        this.dispatchEvent(
            new CustomEvent("cancel")
        );
    }
}
