/**
 * Component Name: SspManualAddress.
 * Author: Ajay Saini, Saurabh.
 * Description: Generic component for manual address entry modal.
 * Date: 11/12/2019.
 */
import { api, track, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import { events, stateLabels, countyValues } from "c/sspConstants";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import cancelButton from "@salesforce/label/c.SSP_Cancel";
import saveButton from "@salesforce/label/c.SSP_Save";
import sspCity from "@salesforce/label/c.SSP_City";
import sspCounty from "@salesforce/label/c.SSP_County";
import sspState from "@salesforce/label/c.SSP_State";
import sspZipCode from "@salesforce/label/c.SSP_ZipCode";
import addressLineTwoAltText from "@salesforce/label/c.SSP_AddressLineTwoAltText";
import pleaseSelectAnAddress from "@salesforce/label/c.SSP_PleaseSelectAddress";
import statePlaceholder from "@salesforce/label/c.SSP_StateFieldPlaceholder";

import STATE_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalStateCode__c";
import COUNTY_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalCountyCode__c";

export default class SspManualAddress extends BaseNavFlowPage {
    label = {
        sspCity,
        sspCounty,
        sspState,
        sspZipCode,
        cancelButton,
        saveButton,
        addressLineTwoAltText,
        pleaseSelectAnAddress,
        statePlaceholder
    };

    line1 = null;
    line2 = null;
    city = null;
    state = null;
    postalCode = null;
    county = null;

    @track countyDisplayValue;
    @track stateDisplayValue;

    @track countyDisabled = false;
    @track statePicklist = [];
    @track countyPicklist = [];
    @track recordTypeId;

    @wire(getObjectInfo, {
        objectApiName: STATE_FIELD
    })
    fetchObjectInfo ({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error("Error in fetching object info: ", error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: STATE_FIELD
    })
    fetchStatePicklistValues ({ error, data }) {
        if (data) {
            this.statePicklist = data.values;
        } else if (error) {
            console.error(error);
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: COUNTY_FIELD
    })
    fetchCountyPicklistValues ({ error, data }) {
        if (data) {
            this.countyPicklist = data.values;
        } else if (error) {
            console.error(error);
        }
    }
    @api
    get MetadataList () {
        return this.metaList;
    }
    set MetadataList (value) {
        if (value) {
            this.metaList = value;
        }
    }

    @track metaList;

    @api
    get fieldMap () {
        return this._fieldMap;
    }
    set fieldMap (value) {
        try {
            this._fieldMap = value;
            const fieldList = Object.values(value).map(item =>
                [item.fieldApiName, item.objectApiName].join(",")
            );
            this.getMetadataDetails(fieldList, null, "SSP_EnterAddressOverlay");
        } catch (error) {
            console.error("Error in set fieldMap:", error);
        }
    }

    @api
    get value () {
        return {
            addressLine1: this.line1,
            addressLine2: this.line2,
            city: this.city,
            state: this.state,
            postalCode: this.postalCode,
            county: this.county
        };
    }

    @api
    get displayValue () {
        return {
            addressLine1: [
                this.line1,
                this.city,
                this.countyDisplayValue,
                this.stateDisplayValue,
                this.postalCode
            ]
                .filter(
                    item => !!item && item !== countyValues.OUT_OF_STATE.label
                )
                .join(", "),
            addressLine2: this.line2
        };
    }

    @api
    get inputElements () {
        return this.template.querySelectorAll(".address-input");
    }

    /**
     * @function handleChange
     * @description Marks if any of the change has been made in any of the input.
     */
    handleChange = () => {
        this.changed = true;
    };

    /**
     * @function handleSave
     * @description Fires a 'save' event with the values entered in the input fields.
     */
    handleSave = () => {
        try {
            Array.from(this.inputElements).forEach(element =>
                element.ErrorMessages()
            );
            const hasError = Array.from(this.inputElements).some(
                element =>
                    element.ErrorMessageList &&
                    element.ErrorMessageList.length > 0
            );
                const saveEvent = new CustomEvent(events.save, {
                    detail: {
                        value: this.value,
                        displayValue: this.displayValue,
                        hasChanged: this.changed,
                        hasError: hasError
                    }
                });
                this.dispatchEvent(saveEvent);
            return hasError;
        } catch (error) {
            console.error("Error in handleSave:", error);
        }
        return false;
    };

    /**
     * @function handleCancel
     * @description Fires 'cancel' event to close the modal.
     */
    handleCancel = () => {
        const saveEvent = new CustomEvent(events.cancel);
        this.dispatchEvent(saveEvent);
    };

    /**
     * @function handleLine1Change
     * @description Captures input change on line 1.
     * @param {object} event - Event object to capture input value.
     */
    handleLine1Change = event => {
        this.line1 = event.target.value && event.target.value.trim();
    };

    /**
     * @function handleLine2Change
     * @description Captures input change on line 2.
     * @param {object} event - Event object to capture input value.
     */
    handleLine2Change = event => {
        this.line2 = event.target.value && event.target.value.trim();
    };

    /**
     * @function handleCityChange
     * @description Captures input change on city field.
     * @param {object} event - Event object to capture input value.
     */
    handleCityChange = event => {
        this.city = event.target.value && event.target.value.trim();
    };

    /**
     * @function handleStateChange
     * @description Captures change in state and defaults the county field if required.
     * @param {object} event - Event object to capture input value.
     */
    handleStateChange = event => {
        try {
            this.state = event.detail.selectedValue;
            this.stateDisplayValue = event.detail.selectedDisplayValue;
            if (this.stateDisplayValue !== stateLabels.KY) {
                this.county = countyValues.OUT_OF_STATE.value;
                this.countyDisplayValue = countyValues.OUT_OF_STATE.label;
                this.countyDisabled = true;
            } else {
                this.county = null;
                this.countyDisplayValue = "";
                this.countyDisabled = false;
            }
        } catch (error) {
            console.error("Error in handleStateChange:", error);
        }
    };

    /**
     * @function handlePostalCodeChange
     * @description Captures input change on postal code field.
     * @param {object} event - Event object to capture input value.
     */
    handlePostalCodeChange = event => {
        this.postalCode = event.target.value && event.target.value.trim();
    };

    /**
     * @function handleCountyChange
     * @description Captures input change on county.
     * @param {object} event - Event object to capture input value.
     */
    handleCountyChange = event => {
        this.county = event.detail.selectedValue;
        this.countyDisplayValue = event.detail.selectedDisplayValue;
    };

    /**
     * @function preventNonNumericInput
     * @description Prevents user from entering invalid key.
     * @param {object} event - Event object to capture key code.
     */
    preventNonNumericInput = event => {
        try {
            const key = String.fromCharCode(event.keyCode);
            if (event.keyCode > 46 && !/^\d+$/.test(key)) {
                event.preventDefault();
            }
        } catch (error) {
            console.error("Error in preventNonNumericInput:", error);
        }
    };
}
