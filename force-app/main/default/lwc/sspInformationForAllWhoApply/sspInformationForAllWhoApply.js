/***
 * Component Name:sspInformationForAllWhoApply.js.
 * Author: Nikhil Shinde
 * Description: This is the Important Information for All Who Apply Modal. It is a generic modal which pops up when an event is triggered.
 * Date:14/02/2020.
 */

import { api, track } from "lwc";
import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspUtility from "c/sspUtility";
import sspApplicationStatementDisagreeButtonAlternate from "@salesforce/label/c.SSP_ApplicationStatementDisagreeButtonAlternate";
import sspApplicationStatementAgreeButtonAlternate from "@salesforce/label/c.SSP_ApplicationStatementAgreeButtonAlternate";
import sspDisagreeButton from "@salesforce/label/c.SSP_DisagreeButton";
import sspAgreeButton from "@salesforce/label/c.SSP_AgreeButton";
import sspInformationModalHeader from "@salesforce/label/c.sspInformationModalHeader";

export default class SspGetStartedBenefitsApplication extends NavigationMixin(
    sspUtility
) {
    @track openModel = true;
    @track disabled = true;
    @track trueValue = true;
    @track accepted = false;
    @track reference = this;
    @track showSpinner = false;
    label = {
        sspApplicationStatementDisagreeButtonAlternate,
        sspApplicationStatementAgreeButtonAlternate,
        sspDisagreeButton,
        sspAgreeButton,
        sspInformationModalHeader
    };
    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.showHelpContentData(
                "SSP_APP_Details_Information_For_All_Who_Apply"
            );
            this.showSpinner = false;
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }
    /**
     * @function : modalContentValue
     * @description : This api sets and returns the modValue.
     */
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
            const sectionReference = this.template.querySelector(
                ".informationForAllWhoApplyContent"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        }
    }

    /**
     * @function : closeModal
     * @description : This method is used to close modal.
     */

    closeModal = () => {
        try {
            if (this.accepted === true) {
                this.disabled = false;
            } else {
                this.disabled = true;
            }

            this.openModel = false;
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in close Important Information Modal" + error
            );
        }
    };

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable the modal buttons when the user reads the given information.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error("Error occurred in enableModalButtons" + error);
        }
    };

    /**
     * @function : handleClick
     * @description : This method is used to save the response of the user (Agree/Disagree).
     * @param {*} event - : Navigates to other pages.
     */
    handleClick = event => {
        const eventName = event.target.name;
        try {
            let eventValue;
            if (eventName === constants.signaturePage.Agree) {
                eventValue = constants.toggleFieldValue.yes;
                this.accepted = true; //If the user accepts the Modal, On closing the buttons wont be disabled.
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: constants.navigationUrl.programSelection
                    }
                });
            } else {
                eventValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: {
                        sFieldValue: eventValue,
                        sFieldName:
                            "isAgreeingOrDisagreeingToInformationForAllWhoApply__c"
                    }
                }
            );
            this.openModel = false;
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error in Agree Or Disagree event in Information for All Who Apply " +
                    error
            );
        }
    };
}
