/**
 * Component Name: SspShortSNAPAddressAutoComplete.
 * Author: Chirag Garg, Shivam Tiwari.
 * Description: Manual address entry screen in Short SNAP.
 * Date: 29/4/2020.
 */

import { track, api, wire } from "lwc";
import { getFieldValue, getFieldDisplayValue } from "lightning/uiRecordApi";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { events, countyValues } from "c/sspConstants";
import addressNotFound from "@salesforce/label/c.SSP_AddressNotFound";
import manuallyEnterAddress from "@salesforce/label/c.SSP_ManuallyEnterAddress";
import pleaseSelectAnAddress from "@salesforce/label/c.SSP_PleaseSelectAddress";
import addressLineTwoAltText from "@salesforce/label/c.SSP_AddressLineTwoAltText";
import modalHeader from "@salesforce/label/c.SSP_Modal_Header";
import getAddressAutoComplete from "@salesforce/apex/SSPAddressAutocompleteController.getAddressAutoComplete";
import getPlaceDetail from "@salesforce/apex/SSPAddressAutocompleteController.getPlaceDetail";
import requiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import COUNTY_FIELD from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalCountyCode__c";
import STATE_FIELD from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalStateCode__c";
import COUNTRY_FIELD from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalCountryCode__c";

import SSPAPPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import constants from "c/sspConstants";

const EMPTY_ADDRESS = {
    addressLine1: null,
    addressLine2: null,
    city: null,
    state: null,
    postalCode: null,
    county: null,
    country: null,
    latitude: null,
    longitude: null,
    postalCode4: null
};

export default class SspShortSNAPAddressAutoComplete extends BaseNavFlowPage {
    @track predictions = [];
    @track searchRunning = false;
    @track manualMode = false;
    @track _showOverlay = false;
    @track _fieldMap;
    @track addressLine1;
    @track addressLine2;
    @track recordTypeId;
    @track reference = this;

    @track applicationRecordTypeId;

    label = {
        addressNotFound,
        manuallyEnterAddress,
        addressLineTwoAltText,
        pleaseSelectAnAddress,
        modalHeader
    };
    _value = EMPTY_ADDRESS;
    cache = {};

    @api metaList;
    @api disabled;

    /**
     * @function - objectInfo.
     * @description - This method is used to get SHORTSNAP record type for SSP Member.
     *
     */
    @wire(getObjectInfo, { objectApiName: SSPAPPLICATION_OBJECT })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const RecordTypesInfo =
                    constants.sspMemberConstants.RecordTypesInfo;
                const applicationRTName =
                    constants.shortSNAPFlowConstants.recordTypeName;
                const recordTypeInformation = data[RecordTypesInfo];
                this.applicationRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name ===
                        applicationRTName
                );
            } else if (error) {
                console.error(
                    "Error occurred while fetching record type in Short SNAP Contact Page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type in Short SNAP Contact Page" +
                    error
            );
        }
    }


    /**
     * @function - getPicklistValues.
     * @description - This method is used to get picklist values.
     *
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: COUNTY_FIELD
    })
    fetchCountyPicklistValues ({ error, data }) {
        try {
            if (data) {
                this.countyPicklist = {};
                for (const item of data.values) {
                    this.countyPicklist[item.label.toLowerCase()] = item.value;
                }
            } else if (error) {
                console.error(error);
            }
        } catch (error) {
            console.error("Error in fetchCountyPicklistValues:", error);
        }
    }


    /**
     * @function - getPicklistValues.
     * @description - This method is used to get picklist values.
     *
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: STATE_FIELD
    })
    fetchStatePicklistValues ({ error, data }) {
        try {
            if (data) {
                this.statePicklist = {};
                for (const item of data.values) {
                    this.statePicklist[item.label.toLowerCase()] = item.value;
                }
            } else if (error) {
                console.error(error);
            }
        } catch (error) {
            console.error("Error in fetchStatePicklistValues:", error);
        }
    }


    /**
     * @function - getPicklistValues.
     * @description - This method is used to get picklist values.
     *
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: COUNTRY_FIELD
    })
    fetchCountryPicklistValues ({ error, data }) {
        try {
            if (data) {
                this.countryPicklist = {};
                for (const item of data.values) {
                    this.countryPicklist[item.label.toLowerCase()] = item.value;
                }
            } else if (error) {
                console.error(error);
            }
        } catch (error) {
            console.error("Error in fetchCountryPicklistValues:", error);
        }
    }


    /**
     * @function - fieldMap.
     * @description - These are getter and setter for fieldMap.
     *
     */
    @api
    get fieldMap () {
        return this._fieldMap;
    }
    set fieldMap (value) {
        try {
            this._fieldMap = value;
            this.updateValues();
        } catch (error) {
            console.error("Error in set fieldMap:", error);
        }
    }


    /**
     * @function - record.
     * @description - These are getter and setter for record.
     *
     */
    @api
    get record () {
        return this._record;
    }
    set record (value) {
        try {
            this._record = value;
            this.updateValues();
        } catch (error) {
            console.error("Error in set record:", error);
        }
    }


    /**
     * @function - value.
     * @description - These are getter and setter for value.
     *
     */
    @api
    get value () {
        return this._value || EMPTY_ADDRESS;
    }
    set value (value) {
        try {
            this._value = value;
            this.showOverlay = false;
        } catch (e) {
            console.error("error in setting value", e);
        }
    }


    /**
     * @function - inputElements.
     * @description - These are getter and setter for inputElements.
     *
     */
    @api
    get inputElements () {
        try {
            if (!this.manualMode) {
                return Array.from(
                    this.template.querySelectorAll(".ssp-address-input")
                );
            }
            return this.template.querySelector("c-ssp-manual-address")
                .inputElements;
        } catch (error) {
            console.error("Error in get inputElements:", error);
        }
        return null;
    }


    /**
     * @function - ErrorMessages.
     * @description - This method is used to validate Address.
     *
     */
    @api
    ErrorMessages () {
        return this.validateAddress();
    }


    /**
     * @function - hasChanged.
     * @description - This method is used to handle address field change.
     *
     */
    @api
    get hasChanged () {
        if (this.oldAddress && this._value) {
            const allBlank = Object.keys(this._fieldMap).every(
                component => !this.oldAddress[component]
            );
            return (
                !allBlank &&
                Object.keys(this._fieldMap).some(
                    component =>
                        this.oldAddress[component] !== this._value[component]
                )
            );
        }
        return this.oldAddress !== this._value;
    }


    /**
     * @function - showOverlay.
     * @description - This method is used to show/hide overlay.
     *
     */
    get showOverlay () {
        return !!this._showOverlay;
    }
    set showOverlay (value) {
        try {
            this._showOverlay = !!value;
            const searchElement = this.template.querySelector(".search-input");
            if (searchElement) {
                if (this._showOverlay) {
                    searchElement.ErrorMessageList = [];
                    searchElement.classList.add("ssp-search-input-focus");
                } else {
                    searchElement.classList.remove("ssp-search-input-focus");
                }
            }
        } catch (error) {
            console.error("Error in set showOverlay:", error);
        }
    }


    /**
     * @function - zeroPredictions.
     * @description - This method is used when there are zero Predictions.
     *
     */
    get zeroPredictions () {
        return (
            this.searchKey &&
            (!this.predictions || this.predictions.length === 0)
        );
    }


    /**
     * @function - searchKey.
     * @description - This method is used to search elements.
     *
     */
    get searchKey () {
        try {
            const searchElement = this.template.querySelector(".search-input");
            return (
                searchElement &&
                searchElement.value &&
                searchElement.value.trim()
            );
        } catch (error) {
            console.error("Error in get searchKey:", error);
        }
        return null;
    }

    /**
     * @function connectedCallback
     * @description Fetches metadata for validations.
     */
    connectedCallback () {
        try {
            this.addEventListener(
                events.saveExitCloseModal,
                this.handleCloseModal.bind(this)
            );
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    /**
     * @function updateValues
     * @description Updates display values of address line 1 and line 2.
     */
    updateValues = () => {
        try {
            const address = {};
            const addressDisplayValue = {};
            if (this._record && this._fieldMap) {
                for (const key of Object.keys(this._fieldMap)) {
                    address[key] = getFieldValue(
                        this._record,
                        this._fieldMap[key]
                    );
                }
                for (const key of Object.keys(this._fieldMap)) {
                    addressDisplayValue[key] =
                        getFieldDisplayValue(
                            this._record,
                            this._fieldMap[key]
                        ) || getFieldValue(this._record, this._fieldMap[key]);
                }
                const addressLine1 = [
                    addressDisplayValue.addressLine1,
                    addressDisplayValue.city,
                    addressDisplayValue.county,
                    addressDisplayValue.state,
                    addressDisplayValue.country,
                    addressDisplayValue.postalCode4,
                    addressDisplayValue.postalCode
                ]
                    .filter(
                        item =>
                            !!item && item !== countyValues.OUT_OF_STATE.label
                    )
                    .join(", ");
                this.addressLine1 = addressLine1
                    .replace(/,[\s,]*,/g, ", ")
                    .replace(/(^[,\s]+)|([,\s]+$)/g, "");
                this.addressLine2 = addressDisplayValue.addressLine2;
                this._value = address;
                this.oldAddress = JSON.parse(JSON.stringify(address));
            }
            this.inputElements.forEach(
                element => (element.ErrorMessageList = [])
            );
        } catch (error) {
            console.error("Error in updateValues:", error);
        }
    };

    /**
     * @function transformGoogleApiAddress
     * @description Transforms address information received from google api
     *              into format suitable for our use.
     * @param {object} googleAddress - Address information as received from the api.
     */
    transformGoogleApiAddress = googleAddress => {
        try {
            const address = Object.assign({}, EMPTY_ADDRESS);
            const components = googleAddress.address_components;
            // address.county = "200";
            address.addressLine1 = [];
            const displayItems = [];
            for (const cmp of components) {
                if (cmp.types.includes("postal_code")) {
                    address.postalCode = cmp.long_name;
                    displayItems.push(cmp.long_name);
                } else  if (cmp.types.includes("postal_code_suffix")) {
                    address.postalCode4 = cmp.long_name;
                    displayItems.push(cmp.long_name);
                } else if (cmp.types.includes("country")) {
                    address.country =
                        this.countryPicklist &&
                        this.countryPicklist[cmp.long_name.toLowerCase()];
                    if (address.country) {
                        displayItems.push(cmp.long_name);
                    }
                } else if (cmp.types.includes("administrative_area_level_1")) {
                    address.state =
                        this.statePicklist &&
                        this.statePicklist[cmp.long_name.toLowerCase()];
                    if (address.state) {
                        displayItems.push(cmp.long_name.toUpperCase());
                    }
                } else if (cmp.types.includes("administrative_area_level_2")) {
                    const [county] =
                        (this.countyPicklist &&
                            cmp.long_name
                                .split(/\s+/)
                                .map(
                                    item =>
                                        this.countyPicklist[item.toLowerCase()]
                                )
                                .filter(item => item)) ||
                        [];
                    if (county) {
                        displayItems.push(cmp.long_name.toUpperCase());
                        address.county = county;
                    }
                } else if (cmp.types.includes("locality")) {
                    address.city = cmp.long_name;
                    displayItems.push(cmp.long_name);
                } else {
                    address.addressLine1.push(cmp.long_name);
                    displayItems.push(cmp.long_name);
                }
            }
            address.latitude = googleAddress.geometry.location.lat;
            address.longitude = googleAddress.geometry.location.lng;
            address.addressLine1 = address.addressLine1
                .filter(item => !!item)
                .join(", ");
            address.displayValue = displayItems
                .filter(item => !!item)
                .join(", ");
            if (address.state === "KY" && !address.county) {
                address.county = "200";
            } else if (!address.county) {
                address.county = "200";
            }
            return address;
        } catch (error) {
            console.error("Error in transformGoogleApiAddress:", error);
        }
    };

    /**
     * @function handleInputFocusOrBlur
     * @description Closes the drop-down for suggestion on line1.
     */
    handleInputFocusOrBlur = () => {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showOverlay = false;
            this.validateAddress();
        }, 100);
    };

    /**
     * @function handleLine1Change
     * @description Fires an api call to google address service to fetch suggestion for changed input value.
     * @param {object} event - Event object to capture input value.
     */
    handleLine1Change = event => {
        try {
            const searchKey = event.target.value;
            this._value = EMPTY_ADDRESS;
            if (!searchKey || searchKey.length < 3) {
                this.showOverlay = false;
                return;
            }
            if (this.cache[searchKey]) {
                this.predictions = this.cache[searchKey];
                this.showOverlay = true;
                return;
            }
            this.getPredictions(searchKey).then(() => {
                if (this.cache[searchKey]) {
                    this.predictions = this.cache[searchKey];
                    this.showOverlay = true;
                }
            });
        } catch (error) {
            console.error("Error in handleLine1Change", error);
        }
    };

    /**
     * @function handleLine2Change
     * @description Simply captures any change in line 2 in an object.
     * @param {object} event - Event object to capture input value.
     */
    handleLine2Change = event => {
        try {
            if (this._value) {
                this._value.addressLine2 = event.target.value;
            }
        } catch (error) {
            console.error("Error in handleLine2Change:", error);
        }
    };

    /**
     * @function handleAddressSelect
     * @description Makes an api call to google service to fetch the detail of selected place.
     * @param {object} event - Event object to capture input value.
     */
    handleAddressSelect = event => {
        try {
            event.preventDefault();
            const placeId = event.currentTarget.dataset.placeId;
            this.setAddressValues(placeId);
        } catch (error) {
            console.error("Error in handleAddressSelect:", error);
        }
    };

    /**
     * @function - getPredictions.
     * @description - This method is used to get predictions.
     * @param {object} searchKey - Parameter.
     */
    getPredictions = searchKey => {
        this.searchRunning = true;
        return getAddressAutoComplete({
            searchKey
        }).then(resultString => {
            const result = JSON.parse(resultString || "{}");
            this.cache[searchKey] = result.predictions;
            this.searchRunning = false;
        });
    };


    /**
     * @function - setAddressValue.
     * @description - This method is used to set address.
     * @param {object} placeId - Parameter.
     */
    setAddressValues = placeId => {
        getPlaceDetail({
            placeId
        })
            .then(resultString => {
                this.showOverlay = false;
                const result = JSON.parse(resultString || "{}");
                if (result.status === "OK" && result.result) {
                    this.value = this.transformGoogleApiAddress(result.result);
                    this.addressLine1 = this.value.displayValue;
                    this.validateAddress();
                }
            })
            .catch(error => {
                console.error("Error in api call", error);
            });
    };

    /**
     * @function toggleManualEntryModal
     * @description Open/closes the manual entry modal.
     * @param {object} event - Event object to capture input value.
     */
    toggleManualEntryModal = event => {
        try {
            event.preventDefault();
            event.stopPropagation();
            this.manualMode = !this.manualMode;
        } catch (error) {
            console.error("Error in toggleManualEntryModal", error);
        }
    };

    /**
     * @function handleCloseModal
     * @description Closes the manual entry modal and reads the address captured in the modal.
     * @param {object} event - Event object to capture input value.
     */
    handleCloseModal = event => {
        try {
            if (event.type === events.save) {
                const hasError = event.detail.hasError;
                if (
                    !hasError &&
                    event.detail.value &&
                    event.detail.displayValue
                ) {
                    this.value = event.detail.value;
                    const addressLine1 = event.detail.displayValue.addressLine1;
                    this.addressLine1 = addressLine1
                        .replace(/,[\s,]*,/g, ", ")
                        .replace(/(^[,\s]+)|([,\s]+$)/g, "");
                    this.addressLine2 = event.detail.displayValue.addressLine2;
                    this.validateAddress();
                    this.manualMode = !this.manualMode;
                }
            } else {
                this.manualMode = !this.manualMode;
            }
        } catch (error) {
            console.error("Error in handleCloseModal", error);
        }
    };

    /**
     * @function validateAddress
     * @description Validates if line1 is not empty when there line2 is non-empty.
     */
    validateAddress = () => {
        try {
            const line1 = this.template.querySelector(".search-input");
            if (!this.metaList) {
                return false;
            }
            const value = this.value || {};
            const errorList = Array.from(
                new Set([
                    this.validateField(
                        this.fieldMap.addressLine1,
                        value.addressLine1
                    ),
                    this.validateField(this.fieldMap.city, value.city),
                    this.validateField(this.fieldMap.county, value.county),
                    this.validateField(this.fieldMap.state, value.state),
                    this.validateField(
                        this.fieldMap.postalCode,
                        value.postalCode
                    ),
                    this.validateField(this.fieldMap.country, value.country),
                    this.conditionalLine1Validation()
                ])
            ).filter(message => !!message);
            line1.ErrorMessageList = errorList;
            return errorList;
        } catch (error) {
            console.error("Error in validateAddressLine1:", error);
        }
    };

    /**
     * @function validateField
     * @description Validates if any of the required component is not empty.
     * @param {string} field - Field Api name.
     * @param {string} value - Field value.
     */
    validateField = (field, value) => {
        try {
            if (!field) {
                return;
            }
            const key = field.fieldApiName + "," + field.objectApiName;
            const validationConfig = this.metaList[key];
            const isRequired =
                !!validationConfig && validationConfig.Input_Required__c;
            if (isRequired) {
                if (!value) {
                    return validationConfig.Input_Required_Msg__c;
                }
            }
        } catch (error) {
            console.error("Error in validateField:", error);
        }
    };

    /**
     * @function conditionalLine1Validation
     * @description Validates if line 1 is populated in case line 2 is populated.
     */
    conditionalLine1Validation = () => {
        try {
            const value = this.value || {};
            const addressLine1 = value.addressLine1;
            const addressLine2 = value.addressLine2;
            const addressLine1Element = this.template.querySelector(
                ".search-input"
            );
            if (addressLine1Element && addressLine2 && !addressLine1) {
                return requiredErrorMessage;
            }
        } catch (error) {
            console.error("Error in validateField:", error);
        }
    };
}