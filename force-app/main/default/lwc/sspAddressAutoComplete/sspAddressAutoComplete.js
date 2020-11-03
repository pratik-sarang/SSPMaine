/**
 * Component Name: SspAddressAutoComplete.
 * Author: Ajay Saini.
 * Description: Generic component for address autocomplete.
 * Date: 11/12/2019.
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
import COUNTY_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalCountyCode__c";
import STATE_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalStateCode__c";
import COUNTRY_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalCountryCode__c";

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

export default class SspAddressAutoComplete extends BaseNavFlowPage {
    @track predictions = [];
    @track searchRunning = false;
    @track manualMode = false;
    @track _showOverlay = false;
    @track _fieldMap;
    @track addressLine1;
    @track addressLine2;
    @track recordTypeId;
    @track reference = this;
    @track isTabPressed=false;
    shouldDropdownClose = false;

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

    handleKeyDown = (event) => {
        const searchOptions = this.template.querySelector(".ssp-address-options");
        if (event.keyCode === 9 || event.keyCode === 40){
            this.isTabPressed = true;
        }
        if (event.keyCode === 40 && searchOptions && searchOptions.children && searchOptions.children[0]) {
            searchOptions.children[0].focus();
            this.isTabPressed = true;
        }
    }

    @wire(getObjectInfo, {
        objectApiName: COUNTY_FIELD
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

    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
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

    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
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

    @api
    ErrorMessages () {
        return this.validateAddress();
    }

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

    get zeroPredictions () {
        return (
            this.searchKey &&
            (!this.predictions || this.predictions.length === 0)
        );
    }

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
                    addressDisplayValue.postalCode,
                    addressDisplayValue.postalCode4
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

     handleBlur = () => {
         if(this.shouldDropdownClose){
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                 this.showOverlay = false;
                 this.validateAddress();
            }, 100);
         }
         this.shouldDropdownClose = true;
     }

    /**
     * @function handleInputFocusOrBlur
     * @description Closes the drop-down for suggestion on line1.
     */
    handleInputFocusOrBlur = () => {
         if (!this.isTabPressed) {
             // eslint-disable-next-line @lwc/lwc/no-async-operation
             setTimeout(() => {
                 this.showOverlay = false;
                 this.validateAddress();
             }, 100);
         }
         this.isTabPressed = false;
         this.shouldDropdownClose = true;
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
            if (
                event.type === "mousedown" ||
                (event.type === "keydown" && event.keyCode === 13)
                ) {
                    event.preventDefault();
                    const placeId = event.currentTarget.dataset.placeId;
                    this.setAddressValues(placeId);
                    this.shouldDropdownClose = false;
            } else if (event.keyCode === 40) {
                this.shouldDropdownClose = false;
                event.target.nextSibling.focus();
            } else if (event.keyCode === 38) {
                this.shouldDropdownClose = false;
                event.target.previousSibling.focus();
            } else if (event.keyCode === 9) {
                this.shouldDropdownClose = false;
            } 
        } catch (error) {
            console.error("Error in handleAddressSelect:", error);
        }
    };

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

    setAddressValues = placeId => {
        getPlaceDetail({
            placeId
        })
            .then(resultString => {
                this.showOverlay = false;
                const result = JSON.parse(resultString || "{}");
                if (result.status === "OK" && result.result) {
                    this.value = this.transformGoogleApiAddress(result.result);
                    this.addressLine1 = null;
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout(() => {
                        this.addressLine1 = this.value.displayValue;
                        this.validateAddress();
                    }, 50); 
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
