/**
 * Name : sspReportAdditionalChangesModal.
 * Description : This modal appears in both Report a Change and Add and Remove Member Flows to ensure user has completed all changes required in a single session prior to eligibility run.
 * Author : Siddarth.
 * Date : 15/02/20.
 **/

import { track, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import sspReportAdditionalChanges from "@salesforce/label/c.sspReportAdditionalChanges";
import sspAnyAdditionalChangesNeedReported from "@salesforce/label/c.sspAnyAdditionalChangesNeedReported";
import sspAddRemoveHouseholdMember from "@salesforce/label/c.sspAddRemoveHouseholdMember";
import sspReportChangeExistingHouseHoldMember from "@salesforce/label/c.sspReportChangeExistingHouseHoldMember";
import sspNoAdditionalChanges from "@salesforce/label/c.sspNoAdditionalChanges";

import constants from "c/sspConstants";

export default class SspReportAdditionalChangesModal extends NavigationMixin(
    BaseNavFlowPage
) {
    @track label = {
        sspReportAdditionalChanges,
        sspAnyAdditionalChangesNeedReported,
        sspAddRemoveHouseholdMember,
        sspReportChangeExistingHouseHoldMember,
        sspNoAdditionalChanges
    };

    @track reference = this;
    @api openModel;
    @api changeMode;
    @api applicationId;
    @api caseNumber;

    get bIsMemberFlow () {
        return this.changeMode === "addRemoveMember";
    }
    /**
     * @function : handleProp
     * @description : This method is used to close modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }

 

    /**
     * @function : cancelModal
     * @description : This method is used to close Modal.
     */
    cancelModal () {
        this.openModel = false;
        this.fireEvent();
        // const modeValue = this.bIsMemberFlow ? "addRemoveMember" : "RAC";
        // this[NavigationMixin.Navigate]({
        //     type: "comm__namedPage",
        //     attributes: {
        //         name: "Sign_and_Submit__c"
        //     },
        //     state: {
        //         applicationId: this.applicationId,
        //         mode: modeValue
        //     }
        // });
    }
    /**
     * @function : fireEvent
     * @description : This method is used to pass value to parent component to close the modal.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(constants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }
    /**
     * @function : addRemoveHouseholdMember
     * @description : This function is used to redirect to Home Page.
     */

    addRemoveHouseholdMember () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "household-summary"
                },
                state: {
                    applicationId: this.applicationId,
                    mode: "addRemoveMember"
                }
            });
            /*this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: constants.navigationUrl.addRemoveHouseholdMemberUrl
                },
                state: {                                        
                    applicationId: this.applicationId,
                    mode: "addRemoveMember"
                }
            });*/
        } catch (error) {
            console.error("Error occurred in continueEarly" + error);
        }
    }
    /**
     * @function : reportChangeExistingHouseHoldMember
     * @description : This function is used to redirect to Home Page.
     */

    reportChangeExistingHouseHoldMember () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "report-change-selection"
                },
                state: {
                    changeType: "modifyNew",
                    selectedApplication: this.caseNumber,
                    applicationId: this.applicationId,
                    mode: "RAC"
                }
            });
            /*this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url:
                        constants.navigationUrl
                            .reportChangeExistingHouseHoldMember
                }
            });*/
        } catch (error) {
            console.error("Error occurred in continueEarly" + error);
        }
    }
}
