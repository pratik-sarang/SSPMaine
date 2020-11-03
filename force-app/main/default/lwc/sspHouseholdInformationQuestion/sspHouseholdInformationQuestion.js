/**
 * Component Name: SspHouseholdCircumstancesSelection.
 * Author: Ajay Saini.
 * Description: Helper component for household circumstances questions screen.
 * Date: DEC-5-2019.
 */

import { LightningElement, api, track } from "lwc";
import { toggleFieldValue } from "c/sspConstants";
import pleaseSelectAtLeastOneMember from "@salesforce/label/c.SSP_PleaseSelectAtleastOneMember";
import pleaseAnswerThisQuestion from "@salesforce/label/c.SSP_PleaseAnswerThisQuestion";
import selectApplicableMembers from "@salesforce/label/c.SSP_SelectApplicableHouseholdMembers";
import queReceiveInHomeAsst from "@salesforce/label/c.SSP_RecieveInHomeAssistance";
import { getYesNoOptions } from "c/sspUtility";

export default class SspHouseholdInformationQuestion extends LightningElement {
    @api question = "";
    @api field = {};
    @api required;
    @api isHelpText = false;
    @api helpText = "";

    @track toggleDisabled = false;
    @track toggleValue = "";
    @track showOptions;
    @track errorMessage;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix and Program Access.
    applicationUpdates = {};

    toggleOptions = getYesNoOptions();

    label = {
        selectApplicableMembers,
        pleaseSelectAtLeastOneMember,
        pleaseAnswerThisQuestion,
        queReceiveInHomeAsst
    };

    get memberLevelQuestion () {
        return this.field.objectApiName && this.field.objectApiName.includes("Member");
    }

    get toggleOptionValues () {
        return this.toggleOptions && this.toggleOptions.map(option => option.value) || [];
    }

    /**
     * @function isAnswered
     * @description Checks if the required question is answered (at-least one member selected) or not.
     * @returns {boolean} - Valid or invalid.
     */
    @api
    isAnswered () {
        try {
            if (this.required === false) {
                return true;
            }
            const toggleElement = this.template.querySelector(
                "c-ssp-base-component-input-toggle"
            );
            if (
                toggleElement &&
                !this.toggleOptionValues.includes(this.toggleValue) &&
                this.question!=this.label.queReceiveInHomeAsst
            ) {
                this.errorMessage = this.label.pleaseAnswerThisQuestion;
                return false;
            }
            if(!this.memberLevelQuestion) {
                return true;
            }
            const checkboxElements = Array.from(this.template.querySelectorAll(
                "c-ssp-base-component-input-checkbox"
            ));
            const atLeastOneChecked = checkboxElements.some(
                element => element.value
            );
            if (checkboxElements.length > 0 && !atLeastOneChecked) {
                this.errorMessage = this.label.pleaseSelectAtLeastOneMember;
                return false;
            }
        } catch (e) {
            console.error("error in isAnswered", e);
        }
        return true;
    }

    /**
     * @function members
     * @returns {object[]} List of members with all the required field set for update.
     */
    @api
    get members () {
        return this._members || [];
    }
    set members (value) {
        try {
            const members = value || [];
            if (this.memberLevelQuestion) {
                const fieldApiName = this.field.fieldApiName;
                this._members = members.map(member =>
                    Object.assign(
                        {
                            checked: member[fieldApiName] === toggleFieldValue.yes,
                            label: [member.FirstName__c, member.LastName__c]
                                .filter(item => !!item)
                                .join(" ")
                        },
                        member
                    )
                );
                this.toggleDisabled = this._members.some(
                    member => member.disabled
                );
                const allNull = this._members.every(
                    member => !member[fieldApiName] || member[fieldApiName] === toggleFieldValue.null
                );
                const someYes = this._members.some(
                    member => member[fieldApiName] === toggleFieldValue.yes
                );
                if(allNull) {
                    this.toggleValue = "";
                }
                else if(someYes) {
                    this.toggleValue = toggleFieldValue.yes;
                }
                else {
                    this.toggleValue = toggleFieldValue.no;
                }
            }
            this.showOptions = this.toggleValue === toggleFieldValue.yes;
        } catch (e) {
            console.error("Error in set member: ", e);
        }
    }

    @api
    get application () {
        return Object.assign({}, this._application, this.applicationUpdates);
    }
    set application (value) {
        this._application = value;
        if(value && !this.memberLevelQuestion) {
            this.toggleValue = value[this.field.fieldApiName];
            this.showOptions = this.toggleValue === toggleFieldValue.yes;
        }
    }

    //CD2 2.5 Security Role Matrix and Program Access.
    get disableQuestions (){
        return (this.toggleDisabled != null && this.toggleDisabled != undefined) ? (this.toggleDisabled || this.isReadOnlyUser) : this.isReadOnlyUser; 
    }

    /**
     * @function handleCheckboxChange
     * @description Handles checkbox change against each member.
     * @param {object} event - Event object.
     */
    /*handleCheckboxChange = (event) => {
        try {
            this.errorMessage = null;
            const memberId = event.target.dataset.id;
            const value = event.target.value;
            if (this.field && this.field.fieldApiName) {
                this.members
                    //.filter(member => member.Id === memberId)
                    .forEach(member => {                      
                            member[this.field.fieldApiName] = value? toggleFieldValue.yes : toggleFieldValue.no;                                               
                    });
            }
        } catch (e) {
            console.error("Error in checkboxChange: ", e);
        }
    }*/

    handleCheckboxChange = event => {
        try {
            this.errorMessage = null;
            const memberId = event.target.dataset.id;
            const value = event.target.value
                ? toggleFieldValue.yes
                : toggleFieldValue.no;
            if (this.field && this.field.fieldApiName) {
                this.members
                    //.filter(member => member.Id === memberId)
                    .forEach(member => {
                        if (member.Id === memberId) {
                            member[this.field.fieldApiName] = value;
                        } else {
                            member[this.field.fieldApiName] =
                                member[this.field.fieldApiName] ===
                                toggleFieldValue.yes
                                    ? toggleFieldValue.yes
                                    : toggleFieldValue.no;
                        }
                    });
            }
        } catch (e) {
            console.error("Error in checkboxChange: ", e);
        }
    }


    /**
     * @function handleToggleChange
     * @description Handles change in (yes/no) toggle buttons.
     * @param {object} event - Event object.
     */
    handleToggleChange = (event) => {
        try {
            this.errorMessage = null;
            this.showOptions = event.detail.value === toggleFieldValue.yes;
            this.toggleValue = event.detail.value;
            if (this.memberLevelQuestion) {
                if (event.detail.value === toggleFieldValue.no) {
                    this.members.forEach(member => {
                        member[this.field.fieldApiName] = toggleFieldValue.no;
                        member.checked =
                            event.detail.value === toggleFieldValue.yes;
                    });
                }
            }
            else if(this.field.fieldApiName) {
                this.applicationUpdates[this.field.fieldApiName] = event.detail.value;
            }
        } catch (e) {
            console.error("Error in toggleChange: ", e);
        }
    }
}