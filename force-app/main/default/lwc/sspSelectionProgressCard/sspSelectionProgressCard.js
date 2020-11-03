/**
 * Component Name: sspSelectionProgressCard.
 * Author: Kyathi.
 * Description: This a component which shows summary information in a card.
 * Date: 12/11/2019.
 */
import { LightningElement, api, track } from "lwc";

import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";
import sspStartButton from "@salesforce/label/c.SSP_StartButton";
import sspEditButton from "@salesforce/label/c.SSP_EditButton";
import sspRemoveModalContent from "@salesforce/label/c.SSP_RemoveModalContent";
import sspDelete from "@salesforce/label/c.SSP_Delete";
import cancelButton from "@salesforce/label/c.SSP_Cancel";
import sspView from "@salesforce/label/c.SSP_View";
import sspEditButtonAlt from "@salesforce/label/c.SSP_EditButtonAlt";
import sspStartButtonAlt from "@salesforce/label/c.SSP_StartButtonAlt";
import sspRemoveAlt from "@salesforce/label/c.SSP_RemoveAlt";
import sspViewDetails from "@salesforce/label/c.SSP_ViewDetails";



import {
    formatLabels
} from "c/sspUtility";

export default class SspSelectionProgressCard extends LightningElement {
    /*The below @api properties get the title and button value to be displayed on the card */
    @api titleValue;
    @api hideTrash = false;
    @api subtitleValue;
    @api buttonValue;
    @api progressChecked = false;
    @api editButton = false;
    @api startButton = false;
    @api memberId;
    @api policyData;
    @api objCard;
    @api applicationId;
    @api isCoveredIndDeletion;
    @api removeModalHeading;
    @api showModelForExist = false;
    @api openModelForExist = false;
    @api recordValue; //the name of the record sent from the parent screen.
    @api disabled = false; //CD2 2.5 Security Role Matrix and Program Access.
    @api isViewButtonVisible = false;
    @track viewButtonAltText;
    @track editButtonAlt;
    @track startButtonAlt;
    @track removeIconAlt;

    @track showModel;
    @track reference = this;

    inProgressIconUrl = sspIcons + apConstants.url.inProgressIcon;

    ProgressCheckedIconUrl = sspIcons + apConstants.url.progressChecked;

    removeIconUrl = sspIcons + apConstants.url.removeIcon;

    label = {
        sspView,
        sspStartButton,
        sspEditButton,
        sspRemoveModalContent,
        sspDelete,
        cancelButton,
        sspEditButtonAlt,
        sspStartButtonAlt,
        sspRemoveAlt
    };

    renderedCallback () {
        this.changeAltText();
    }

    changeAltText = () => {
        if (this.recordValue != null && this.recordValue != undefined) {
            this.editButtonAlt = formatLabels(sspEditButtonAlt, [
                this.recordValue
            ]);
            this.startButtonAlt = formatLabels(sspStartButtonAlt, [
                this.recordValue
            ]);
            this.removeIconAlt = formatLabels(sspRemoveAlt, [
                this.recordValue
            ]);
            this.viewButtonAltText = formatLabels(sspViewDetails, [
                this.recordValue
            ]);
        } else {
            this.editButtonAlt = "Edit Button";
            this.startButtonAlt = "Start Button";
            this.removeIconAlt = "Delete";
            this.viewButtonAltText = sspView;
        }
    }

    handleClick = () => {
        const hideCard = this.template.querySelector("div");
        hideCard.classList.add("slds-hide");
    }

    /**
     * @function : displayRemoveModal
     * @description : This functions opens the modal.
     */
    displayRemoveModal = () => {
        this.showModelForExist = this.openModelForExist;
        this.template
            .querySelector("c-ssp-detailed-information-modal")
            .openModal();
        this.showModel = true;
    }

    /**
     * @function : closeRemoveModal
     * @description : This method is used to close Remove Coverage Modal.
     */
    closeRemoveModal = () => {
        this.showModelForExist = false;
    }

    removeCard = (event) => {
        const actionObj = event.srcElement.name;
        const hideCard = this.template.querySelector(
            ".ssp-ProgressCardContainer"
        );
        hideCard.classList.add("slds-hide");
        const selectedEvent = new CustomEvent("remove", {
            detail: actionObj
        });

        this.dispatchEvent(selectedEvent);
    }

    /**
     * @function : handleButton
     * @description : This method is used to dispatch event.
     * @param {*} event - This event is used to dispatch event.
     * */
    handleButton = (event) => {
        const actionObj = event.srcElement.name;
        if (actionObj !== undefined) {
            const selectedEvent = new CustomEvent("button", {
                detail: actionObj
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    /**
     * @function : closeModal
     * @description : This method is used to close Modal.
     */
    closeModal = () => {
        this.showModel = false;
    }
}
