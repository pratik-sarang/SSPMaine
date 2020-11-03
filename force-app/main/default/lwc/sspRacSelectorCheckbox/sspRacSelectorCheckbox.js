/*
 * Component Name: SspRacSelectorCheckbox.
 * Author: Shivam
 * Description: Container for Report Change Selection screen
 * Date: 1/23/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspHealthSelectionErrorMsg from "@salesforce/label/c.SSP_HealthSelectionErrorMsg";
import apConstants from "c/sspConstants";
import sspHealthSelectionSelectApplicant from "@salesforce/label/c.SSP_HealthSelectionSelectApplicant";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspPolicyId from "@salesforce/label/c.SSP_HealthCareEnrollPolicyId";
import sspCommaUnpaid from "@salesforce/label/c.SSP_CommaUnpaid";
import week from "@salesforce/label/c.SSP_Week";
import hours from "@salesforce/label/c.SSP_Hours"; //Added this as part of defect 368480

export default class SspRacSelectorCheckbox extends LightningElement {
    @api menuItem = {};
    @api json = {};
    @api selected;
    @track showMembers;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @api members;
    label = {
        sspPolicyId,
        sspHealthSelectionSelectApplicant,
        toastErrorText
    };

    //To hide Healthcare additional field section when there are no related members
    get hideAdditionalFields () {
        if (this.menuItem.optionId === "Healthcare_Coverage") {
            if (this.menuItem.hasOwnProperty("summary")) {
                if (JSON.parse(JSON.stringify(this.menuItem.summary)).length === 0) {
                    return true;
                }
                return false;
            }
        }
        else if (this.menuItem.optionId === "Member_Information") {
            if (this.menuItem.hasOwnProperty("isBasedOnIndividual")) {
                if (JSON.parse(JSON.stringify(this.menuItem.isBasedOnIndividual)) === true) {
                    return true;
                }
                return false;
            }
        }
        return false;
    }

    /**
     * @function : mapOfIncome
     * @description : Used to map Income or members.
     */
    get mapOfIncome () {
        if (this.menuItem && this.menuItem.incomeMap) {
            let data = JSON.parse(JSON.stringify(this.menuItem.incomeMap));
            data = Object.assign({}, data);
            const mapOfIncomeList = [];
            // eslint-disable-next-line no-restricted-syntax
            for (const key in data) {
                if (data.hasOwnProperty(key)) {
                    const keyTemp = data[key];
                    // Filtering the data in the loop
                    for(let i=0;i<keyTemp.length;i++){
                        if (keyTemp[i].IncomeTypeCode === "Unpaid income") {
                            keyTemp[i].incomeSourceName =null!= keyTemp[i].incomeSourceName && keyTemp[i].incomeSourceName!==undefined ? keyTemp[i].incomeSourceName :keyTemp[i].IncomeTypeCode;
                            keyTemp[i].grossIncomeFormatted = `${keyTemp[i].IncomePayDetailHoursPerWeek} ${hours}/${week} ${sspCommaUnpaid}`;
                        }
                    }

                    mapOfIncomeList.push({
                        key: key,
                        value: data[key]
                    });
                }
            }
            return mapOfIncomeList;
        } else {
            return false;
        }
    }

    /**
     * @function : showSummary
     * @description : Used to show summary.
     */
    get showSummary () {
        return !this.menuItem.isBasedOnIndividual
            ? !this.showMembers
            : this.menuItem.summary;
    }
    /**
     * @function : atLeastOneSelected
     * @description :This method is called when atLeast one checkbox is selected.
     */
    @api
    atLeastOneSelected () {
        const element = this.template.querySelector(
            "c-ssp-base-component-input-checkbox-group"
        );
        if (!element) {
            return true;
        }
        if (!this.selected) {
            element.ErrorMessageList = [];
            this.hasSaveValidationError = false;
            return true;
        }
        const isValid = Array.isArray(this.members) && this.members.length > 0;
        if (!isValid) {
            element.ErrorMessageList = [sspHealthSelectionErrorMsg];
            this.hasSaveValidationError = true;
            return false;
        } else {
            element.ErrorMessageList = [];
            this.hasSaveValidationError = false;
            return true;
        }
    }

    /**
     * @function : handleCheckboxAction
     * @description : Used to handle Checkbox Action.
     *  @param {object} event - Js event.
     */
    handleCheckboxAction = event => {
        try {
            this.showMembers = !this.showMembers;
            this.selected = event.target.value;
            const value = event.target.value;
            if (!value) {
                this.members = null;
            }
            if (value) {
                const hideFieldErrorEvent = new CustomEvent(
                    apConstants.events.hideFieldValidationError
                );
                this.dispatchEvent(hideFieldErrorEvent);
            }
        } catch (error) {
            console.error(
                "### Error occurred in sspReportChangeSelection - handleCheckboxAction ###" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleMemberChange
     * @description : Used to handle member changes .
     *  @param {object} event - Js event.
     */
    handleMemberChange = event => {
        try {
            const members = event.target.value;
            this.members = members;
            const element = this.template.querySelector(
                "c-ssp-base-component-input-checkbox-group"
            );
            if (event.target.value.length) {
                const hideFieldErrorEvent = new CustomEvent(
                    apConstants.events.hideFieldValidationError
                );
                this.dispatchEvent(hideFieldErrorEvent);

                element.ErrorMessageList = [];
                this.hasSaveValidationError = false;
            } else {
                element.ErrorMessageList = [sspHealthSelectionErrorMsg];
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(
                "### Error occurred in sspReportChangeSelection - handleCheckboxAction ###" +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in HideToast " + JSON.stringify(error.message)
            );
        }
    };
}