/**
 * Component Name: sspExitApplicationModal.
 * Author: Shikha Khanuja, P V Siddarth.
 * Description: This component is used to save and exit out of the flow.
 * Date: 11/15/2019.
 */

import { api, LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspProgressWillBeLost from "@salesforce/label/c.sspProgressWillBeLost";
import sspCannotBeConsideredForBenefits from "@salesforce/label/c.sspCannotBeConsideredForBenefits";
import sspLeaveTheApplication from "@salesforce/label/c.sspLeaveTheApplication";
import sspPleaseNote from "@salesforce/label/c.sspPleaseNote";
import sspLeaveApplication from "@salesforce/label/c.sspLeaveApplication";
import sspCancel from "@salesforce/label/c.sspCancel";
import sspSaveAndExit from "@salesforce/label/c.sspSaveAndExit";
import constants from "c/sspConstants";
import { updateRecord } from "lightning/uiRecordApi";

export default class sspExitApplicationModal extends NavigationMixin(
    LightningElement
) {
    label = {
        sspLeaveTheApplication,
        sspPleaseNote,
        sspCannotBeConsideredForBenefits,
        sspProgressWillBeLost,
        sspLeaveApplication,
        sspSaveAndExit,
        sspCancel
    };
    @api openModel = false;
    @api applicationId;
    @api summaryButtonLabel = sspSaveAndExit;
    @track reference = this;
    @track isLoading = false;

    /**
     * @function : handleProp
     * @description : This method is used to close modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }
    
    /**
     * @function : saveAndExitModal
     * @description : This method is used to navigate to dashboard when save and exit is being used.
     */
    saveAndExitModal () {
        try {
            this.isLoading = true;
            if (this.applicationId) {
              const objApplication = {};
              objApplication["Application_Change_Start_Timestamp__c"] = null;
              const record = {
                recordId: this.applicationId,
                fields: objApplication,
              };
              updateRecord(record)
                .then(() => {
                  //Shikha - firing event 
                  const saveAndExitClicked = new CustomEvent (constants.events.saveCalled);                  
                  this.dispatchEvent(saveAndExitClicked);
                  this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                      name: constants.eligibilityStatus.dashboardUrl,
                    },
                  });
                })
                .catch((error) => {
                  this.isLoading = true;
                  console.error("error", error);
                });
            } else {
              this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                  name: constants.eligibilityStatus.dashboardUrl,
                },
              });
            }
        } catch (error) {
            console.error("Error occurred in saveAndExitModal" + error);
        }
    }
    /**
     * @function : cancelModal
     * @description : This method is used to close Modal.
     */
    cancelModal () {
        this.openModel = false;
        this.fireEvent();
    }
    /**
     * @function : fireEvent
     * @description : This method is used to pass value to parent component to close the modal.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(constants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }
}
