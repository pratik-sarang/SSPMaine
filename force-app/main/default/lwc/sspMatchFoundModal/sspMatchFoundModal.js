/**
 * Component Name: sspMatchFoundModal.
 * Author: Suyash, P V Siddarth.
 * Description: This screen informs the user that a match was found, and we will be pulling that data for them to review and update if necessary.
 * Date: 17/12/2019.
 */
import { api, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import sspMergeCase from "@salesforce/label/c.sspMergeCase";
import sspPleaseReviewInformation from "@salesforce/label/c.sspPleaseReviewInformation";
import sspExistingCaseFound from "@salesforce/label/c.sspExistingCaseFound";
import sspApplication from "@salesforce/label/c.sspApplicationWord";
import sspCase from "@salesforce/label/c.sspCaseWord";

import constants from "c/sspConstants";
import { formatLabels } from "c/sspUtility";

export default class SspMatchFoundModal extends BaseNavFlowPage {
    @api openModel = false;
    @api caseNumberCurrent;
    @api caseNumberExisting;
    @track reference = this;
    @api mode;

    label = {
        sspMergeCase,
        sspPleaseReviewInformation,
        sspExistingCaseFound,
        sspApplication,
        sspCase
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
     * @function : fireEvent
     * @description : This function fires event to the parent component.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(constants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }
    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
     */
    connectedCallback () {
        if (this.mode === constants.applicationMode.INTAKE) {
            this.label.sspMergeCase = formatLabels(this.label.sspMergeCase, [
                this.caseNumberCurrent,
                this.label.sspApplication,
                this.caseNumberExisting
            ]);
        } else {
            this.label.sspMergeCase = formatLabels(this.label.sspMergeCase, [
                this.caseNumberCurrent,
                this.label.sspCase,
                this.caseNumberExisting
            ]);
        }
    }
}