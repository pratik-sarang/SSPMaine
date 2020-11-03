/**
 * Name : SspAddHouseHoldMember.
 * Description : This screen contains three modals which open when the condition do not match.
 * Author : Suyash and Siddarth.
 * Date : 07/01/20.
 **/
import { api, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { NavigationMixin } from "lightning/navigation";
import { formatLabels } from "c/sspUtility";

import sspExistingCaseFound from "@salesforce/label/c.sspExistingCaseFound";
import sspRecordFoundDuplicate from "@salesforce/label/c.sspRecordFoundDuplicate";
import sspPleaseContactDCBS from "@salesforce/label/c.sspPleaseContactDCBS";
import sspReturnToDashboard from "@salesforce/label/c.sspReturnToDashboard";
import sspMemberAddedTwice from "@salesforce/label/c.sspMemberAddedTwice";
import sspFoundIndividualInformation from "@salesforce/label/c.sspFoundIndividualInformation";
import sspMembersAddedOnlyOnce from "@salesforce/label/c.sspMembersAddedOnlyOnce";
import sspRemoveDuplicateEntry from "@salesforce/label/c.sspRemoveDuplicateEntry";
import sspDuplicateKOGAccount from "@salesforce/label/c.sspDuplicateKOGAccount";
import sspYouAlreadyHaveAnAccount from "@salesforce/label/c.sspYouAlreadyHaveAnAccount";
import sspPleaseContactCustomerService from "@salesforce/label/c.sspPleaseContactBenefindCustomerService";
import sspLogOut from "@salesforce/label/c.sspLogOut";
import constants from "c/sspConstants";
import sspPleaseContactDCBSText1 from "@salesforce/label/c.SSP_PleaseContactDCBSText1";
import sspPleaseContactDCBSText3 from "@salesforce/label/c.SSP_PleaseContactDCBSText3";
import sspPleaseContactDCBSText2 from "@salesforce/label/c.SSP_PleaseContactDCBSText2";
export default class SspCannotApplyModal extends NavigationMixin(
    BaseNavFlowPage
) {
    @api currentIndividual;
    @api existingIndividual;
    @api logOut;
    @api showModal;
    @api sspMemberAddedTwice;
    @api openDuplicateKOGAccount = false;
    @api openMemberAddedTwice = false;
    @api openExistingCaseFound = false;
    @api openModel;
    @track reference = this;
    telephoneNumber = `tel:${sspPleaseContactDCBSText2}`;
    label = {
        sspExistingCaseFound,
        sspReturnToDashboard,
        sspPleaseContactDCBS,
        sspRecordFoundDuplicate,
        sspFoundIndividualInformation,
        sspMemberAddedTwice,
        sspMembersAddedOnlyOnce,
        sspRemoveDuplicateEntry,
        sspDuplicateKOGAccount,
        sspYouAlreadyHaveAnAccount,
        sspLogOut,
        sspPleaseContactCustomerService,
        sspPleaseContactDCBSText3,
        sspPleaseContactDCBSText1,
        sspPleaseContactDCBSText2
    };

    /**
     * @function : openModal
     * @description : This used to open Modal.
     */
    openModal () {
        this.openModel = true;
    }
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }
    /**
     * @function : returnToDashboard
     * @description : This function is used to redirect to Home Page.
     */

    returnToDashboard () {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: constants.eligibilityStatus.dashboardUrl
            }
        });
    }

    /**
     * @function : fireEvent
     * @description : This event is used to fire event in the parent component.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(constants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }

    loadModal () {
        if (this.showModal === constants.openModal.duplicateKOGAccount) {
            this.openDuplicateKOGAccount = true;
            this.openMemberAddedTwice = false;
            this.openExistingCaseFound = false;
        } else if (this.showModal === constants.openModal.memberAddedTwice) {
            this.openDuplicateKOGAccount = false;
            this.openMemberAddedTwice = true;
            this.openExistingCaseFound = false;

            this.label.sspFoundIndividualInformation = formatLabels(
                this.label.sspFoundIndividualInformation,
                [this.currentIndividual]
            );
        } else if (this.showModal === constants.openModal.existingCaseFound) {
            this.openDuplicateKOGAccount = false;
            this.openMemberAddedTwice = false;
            this.openExistingCaseFound = true;

            this.label.sspRecordFoundDuplicate = formatLabels(
                this.label.sspRecordFoundDuplicate,
                [this.currentIndividual]
            );
        } else {
            this.openDuplicateKOGAccount = false;
            this.openMemberAddedTwice = false;
            this.openExistingCaseFound = false;
        }
    }

    /**
     * @function : connectedCallback
     * @description : This method loads as soon as the page loads.
     */
    connectedCallback () {
        try {
            this.loadModal();
        } catch (e) {
            console.error(
                "Error in connectedCallback of Primary Applicant Contact page",
                e
            );
        }
    }
    logOutFunction () {
        try {
            window.location.href = constants.url.logoutUrl;
        } catch (error) {
            console.error(
                "Error in connectedCallback of Primary Applicant Contact page",
                error
            );
        }
    }
}
