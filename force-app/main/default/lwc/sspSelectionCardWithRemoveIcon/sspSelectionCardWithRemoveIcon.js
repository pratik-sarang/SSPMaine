/***
 * Component Name:sspSelectionCardWithRemoveIcon.js.
 * Author: Kyathi.
 * Description: This is user information card with remove icon.
 * Date:12/11/2019.
 */
import { LightningElement, api, track } from "lwc";
import sspCardImages from "@salesforce/resourceUrl/SSP_Icons";
import sspRemoveModalContent from "@salesforce/label/c.SSP_RemoveModalContent";
import sspDelete from "@salesforce/label/c.SSP_Delete";
import startButton from "@salesforce/label/c.SSP_StartButton";
import editButton from "@salesforce/label/c.SSP_EditButton";
import cancelButton from "@salesforce/label/c.SSP_Cancel";
import sspRemove from "@salesforce/label/c.SSP_Remove";
import sspProgressIcon from "@salesforce/label/c.SSP_ProgressIcon";
import apConstants from "c/sspConstants";
import sspRemoveAlt from "@salesforce/label/c.SSP_RemoveAlt";
import sspView from "@salesforce/label/c.SSP_View";
import { formatLabels } from "c/sspUtility";

export default class sspSelectionCardWithRemoveIcon extends LightningElement {
    label = {
        sspView,
        sspRemoveModalContent,
        sspDelete,
        startButton,
        editButton,
        cancelButton,
        sspProgressIcon,
        sspRemove,
        sspRemoveAlt
    };
    /*If any of the below @api property is not passed from the parent, that element will not be displayed */
    /*cardId will include the index of the card which is used to track which card is to be deleted on clicking removing icon */
    @api cardId;
    @api objCard;
    /*displayEdit is a boolean value to display the edit button.*/
    @api displayEdit = false;
    @api displayCheckmark = false;
    @api removeModalHeading;
    @api hideButtons = false;
    @api hideRemoveIcon = false;
    @api buttonAltText;
    @api removeAltText = "";
    @api memberId;
    @api policyData;
    @api applicationId;
    @api coveredIndData;
    @api isCoveredIndDeletion;
    @api showModelForExist = false;
    @api openModelForExist = false;
    @api recordValue;
    @api cancelButtonTitle = this.label.cancelButton;
    @api deleteButtonTitle = this.label.sspDelete;
    @api deleteButtonLabel = this.label.sspDelete;
    @api removeModalContent= this.label.sspRemoveModalContent;
    @api disabled = false; //CD2 2.5 Security Role Matrix and Program Access.
    @api canDelete; //CD2 2.5 Security Role Matrix and Program Access.
    @api editButtonText = this.label.editButton;
    @api isViewButtonVisible = false;
    @api viewButtonAltText = sspView;
    @api hideDeleteModal = false;
    @track showModel;
    @track removeIconAlt;
    @track reference = this;
    
    checkedIconUrl = sspCardImages + apConstants.url.progressChecked;
    uncheckedIconUrl = sspCardImages + apConstants.url.progressNotStartedIcon;
    removeIcon = sspCardImages + apConstants.url.removeIcon;

    connectedCallback (){
        // Added below code to decrease the font size of Spanish Start button in mobile
        const urlString = window.location.href;
        const url = new URL(urlString);
        const language = url.searchParams.get("language");
        if (language === "es_US") {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                const btnRef = this.template.querySelector(".ssp-startButton");
                btnRef.classList.add("ssp-SpanishStartBtn");
            }, 0);
        }
        this.canDelete = (this.canDelete != null && this.canDelete != undefined) ? this.canDelete : true;
    }

    /**
     * @function : renderedCallback
     * @description : This method is called when the entire page has been rendered.
     */
    renderedCallback () {
        this.changeAltText();
    }

    /**
     * @function : changeAltText
     * @description : This method is used to change the alt text of the start and edit buttons.
     */
    changeAltText () {
        if (this.recordValue != null && this.recordValue != undefined) {
            this.removeIconAlt = formatLabels(sspRemoveAlt, [this.recordValue]);
        } else {
            this.removeIconAlt =
                this.removeAltText != "" ? this.removeAltText : "Delete";
        }
    }

    /**
     * @function : handleActionButton
     * @description : This method is used to dispatch event.
     * @param {*} event - This event returns particular class.
     */
    handleActionButton (event) {
        const actionObj = event.srcElement.name;
        const cardActionEvt = new CustomEvent(apConstants.events.cardAction, {
            detail: actionObj
        });
        this.dispatchEvent(cardActionEvt);
    }
    /**
     * @function : displayRemoveModal
     * @description : This method is used to show Modal.
     * @param {*} event -  Event.
     */
    displayRemoveModal (event) {
        if (event.keyCode === 13 || event.type == "click"){
            this.showModelForExist = this.openModelForExist;
            this.template
                .querySelector("c-ssp-detailed-information-modal")
                .openModal();
            this.showModel = true;
        }
    }
    /**
     * @function : removeCard.
     * @description : This method is used to hide the card.
     * @param {*} event - This event returns particular class.
     */
    removeCard (event) {
        const actionObj = event.srcElement.name;

        const selectedEvent = new CustomEvent(apConstants.events.remove, {
            detail: actionObj
        });
        this.showModel = false;
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    /**
     * @function : closeModal
     * @description : This method is used to close Modal.
     */
    closeModal () {
        this.showModel = false;
    }
    /**
     * @function : closeRemoveModal
     * @description : This method is used to close Remove Coverage Modal.
     */
    closeRemoveModal () {
        this.showModelForExist = false;
    }
}