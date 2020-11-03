/**
 * Component Name: sspSnapAddressInformation.
 * Author: Chirag , Shivam.
 * Description: Page for Address in short snap.
 * Date: 4/23/2020.
 */
import { track, api, wire } from "lwc";

import sspShortSNAPApplication from "@salesforce/label/c.SSP_ShortSNAPApplication";

import utility, { getYesNoOptions } from "c/sspUtility";
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from "lightning/flowSupport";
import { NavigationMixin } from "lightning/navigation";
import constants from "c/sspConstants";

import ADDRESS from "@salesforce/label/c.address";
import ADDRESS_LINE2 from "@salesforce/label/c.AddressLine2";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import COUNTRY from "@salesforce/label/c.Country";
import ZIP from "@salesforce/label/c.Zip_Code";
import MAILING from "@salesforce/label/c.Mailing";

import IS_KENTUCKY_RESIDENT from "@salesforce/schema/SSP_Application__c.ShortSnapIsIntentionToResideInKentucky__c";
import HAVE_PHYSICAL_ADDRESS from "@salesforce/schema/SSP_Application__c.ShortSnapIsFixedAddress__c";
import HAVE_MAILING_ADDRESS from "@salesforce/schema/SSP_Application__c.ShortSnapIsMailingAddress__c";

import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalAddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalAddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalCity__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalCountyCode__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalStateCode__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalCountryCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalZipCode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Application__c.ShortSnapPhysicalZipCode5__c";

import MAILING_ADDRESS_LINE1 from "@salesforce/schema/SSP_Application__c.ShortSnapMailingAddressLine1__c";
import MAILING_ADDRESS_LINE2 from "@salesforce/schema/SSP_Application__c.ShortSnapMailingAddressLine2__c";
import MAILING_ADDRESS_CITY from "@salesforce/schema/SSP_Application__c.ShortSnapMailingCity__c";
import MAILING_ADDRESS_COUNTY from "@salesforce/schema/SSP_Application__c.ShortSnapMailingCountyCode__c";
import MAILING_ADDRESS_STATE from "@salesforce/schema/SSP_Application__c.ShortSnapMailingStateCode__c";
import MAILING_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Application__c.ShortSnapMailingCountryCode__c";
import MAILING_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Application__c.ShortSnapMailingZipCode4__c";
import MAILING_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Application__c.ShortSnapMailingZipCode5__c";

import sspBack from "@salesforce/label/c.SSP_Back";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspExitShortSNAPApplication from "@salesforce/label/c.SSP_ExitShortSNAPApplication";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspNextButtonAltText from "@salesforce/label/c.SSP_NextButtonAltText";
import sspAddressInformation from "@salesforce/label/c.SSP_AddressInformation";
import sspShortSnapAddressContent from "@salesforce/label/c.SSP_ShortSnapAddressContent";
import sspShortSnapAddressContent2 from "@salesforce/label/c.SSP_ShortSnapAddressContent2";
import sspShortSnapAddressContent3 from "@salesforce/label/c.SSP_ShortSnapAddressContent3";
import sspMailingAddress from "@salesforce/label/c.SSP_Mailing_Address";
import sspMailingAddressLine2 from "@salesforce/label/c.SSP_Mailing_Address_Line2";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSnapDifferentMailingAddress from "@salesforce/label/c.SSP_SnapDifferentMailingAddress";
import sspGoBackPreviousPage from "@salesforce/label/c.SSP_GoBackPreviousPage";
import { getFieldValue } from "lightning/uiRecordApi";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import SSP_APPLICATION from "@salesforce/schema/SSP_Application__c";

const PHYSICAL_LATITUDE = {
    fieldApiName: "ShortSnapPhysicalGeolocation__Latitude__s",
    objectApiName: "SSP_Application__c"
};

const PHYSICAL_LONGITUDE = {
    fieldApiName: "ShortSnapPhysicalGeolocation__Longitude__s",
    objectApiName: "SSP_Application__c"
};

const MAILING_LATITUDE = {
    fieldApiName: "ShortSnapMailingGeolocation__Latitude__s",
    objectApiName: "SSP_Application__c"
};

const MAILING_LONGITUDE = {
    fieldApiName: "ShortSnapMailingGeolocation__Longitude__s",
    objectApiName: "SSP_Application__c"
};

const PA_FIELD_MAP = {
    addressLine1: {
        ...PHYSICAL_ADDRESS_LINE1,
        label: ADDRESS
    },
    addressLine2: {
        ...PHYSICAL_ADDRESS_LINE2,
        label: ADDRESS_LINE2
    },
    city: {
        ...PHYSICAL_ADDRESS_CITY,
        label: CITY
    },
    county: {
        ...PHYSICAL_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...PHYSICAL_ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...PHYSICAL_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...PHYSICAL_ADDRESS_ZIP5,
        label: ZIP
    },
    postalCode4: {
        ...PHYSICAL_ADDRESS_ZIP4,
        label: ZIP
    },
    latitude: {
        ...PHYSICAL_LATITUDE
    },
    longitude: {
        ...PHYSICAL_LONGITUDE
    }
};

const MA_FIELD_MAP = {
    addressLine1: {
        ...MAILING_ADDRESS_LINE1,
        label: sspMailingAddress
    },
    addressLine2: {
        ...MAILING_ADDRESS_LINE2,
        label: sspMailingAddressLine2
    },
    city: {
        ...MAILING_ADDRESS_CITY,
        label: CITY
    },
    county: {
        ...MAILING_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...MAILING_ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...MAILING_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...MAILING_ADDRESS_ZIP5,
        label: ZIP
    },
    postalCode4: {
        ...MAILING_ADDRESS_ZIP4,
        label: ZIP
    },
    latitude: {
        ...MAILING_LATITUDE
    },
    longitude: {
        ...MAILING_LONGITUDE
    }
};

export default class SspSnapAddressInformation extends NavigationMixin(
    utility
) {
    @api applicationObject = {};
    @api applicationString;

    @api applicationStringInput;
    @api applicationStringOutput;

    @track isVisible = true;
    @track havePhysicalAddress = false;
    @track isMailingAddressDifferent = false;
    @track spinnerOn = false;

    @track metaDataListParent = {};
    @track toggleButtonOptions = getYesNoOptions();
    @track showPhysicalAddress = false;
    @track showAddressComp = false;
    @track showMailingAddressField = false;
    @track hasSaveValidationError = false;
    @track showDifferentMailingAddress = false;
    @track trueValue = true;
    @track addressRecord;
    @track allowNavigation = false;
    @track mailingTemp = MAILING;
    @track applicationRecordTypeId;
    @track CountyOptions;
    @track StateOptions;
    @track CountyMap;
    @track StateMap;
    
    label = {
        sspShortSNAPApplication,
        sspBack,
        sspBackAltText,
        sspExitButton,
        sspExitShortSNAPApplication,
        sspNext,
        sspNextButtonAltText,
        sspAddressInformation,
        sspShortSnapAddressContent,
        sspShortSnapAddressContent2,
        sspShortSnapAddressContent3,
        toastErrorText,
        sspSnapDifferentMailingAddress,
        sspGoBackPreviousPage
    };

    appFieldList = [
        HAVE_PHYSICAL_ADDRESS,
        HAVE_MAILING_ADDRESS,
        PHYSICAL_ADDRESS_LINE1,
        PHYSICAL_ADDRESS_LINE2,
        PHYSICAL_ADDRESS_CITY,
        PHYSICAL_ADDRESS_COUNTY,
        PHYSICAL_ADDRESS_STATE,
        PHYSICAL_ADDRESS_COUNTRY,
        PHYSICAL_ADDRESS_ZIP4,
        PHYSICAL_ADDRESS_ZIP5,
        PHYSICAL_LATITUDE,
        PHYSICAL_LONGITUDE,
        MAILING_ADDRESS_LINE1,
        MAILING_ADDRESS_LINE2,
        MAILING_ADDRESS_CITY,
        MAILING_ADDRESS_COUNTY,
        MAILING_ADDRESS_STATE,
        MAILING_ADDRESS_COUNTRY,
        MAILING_ADDRESS_ZIP4,
        MAILING_ADDRESS_ZIP5,
        MAILING_LATITUDE,
        MAILING_LONGITUDE
    ];

    get mailingAddFieldMap () {
        return MA_FIELD_MAP;
    }

    get fieldMap () {
        if (this.havePhysicalAddress) {
            return PA_FIELD_MAP;
        }
        return MA_FIELD_MAP;
    }

    /**
     * @function - get MetadataList.
     * @description - MetadataList getter method for framework.
     */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
     * @function - set MetadataList.
     * @description - Next Event setter method for framework.
     * @param {string} value - Setter for MetadataList framework property.
     */
    set MetadataList (value) {
        try {
            if (value) {
                this.metaDataListParent = value;
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of Short SNAP Contact page",
                e
            );
        }
    }

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSave () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error("Error Occurred::: ", JSON.stringify(error.message));
            return null;
        }
    }
    set allowSave (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.allowSaveValue = value;
            }
        } catch (error) {
            console.error("Error Occurred::: ", JSON.stringify(error.message));
        }
    }


    /**
     * @function - objectInfo.
     * @description - This method is used to get INDIVIDUAL record type for SSP Member.
     */
    @wire(getObjectInfo, { objectApiName: SSP_APPLICATION })
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
                    "Error occurred while fetching record type in Short SNAP Address Page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type in Short SNAP Address Page" +
                    error
            );
        }
    }

    /**
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: PHYSICAL_ADDRESS_COUNTY
    })
    fetchCountyPicklistValues ({ error, data }) {
        try {
            if (data) {
                this.CountyOptions = data.values.reduce((map, item) => {
                    map[item.value] = item.label;
                    return map;
                }, {});

                this.CountyMap = data.values.reduce((map, item) => {
                    map[item.label] = item.value;
                    return map;
                }, {});

                if (this.fields) {
                    this.fields[MAILING_ADDRESS_COUNTY.fieldApiName] = this.CountyOptions[this.applicationObject.ShortSnapMailingCountyCode__c];
                    this.fields[PHYSICAL_ADDRESS_COUNTY.fieldApiName] = this.CountyOptions[this.applicationObject.ShortSnapPhysicalCountyCode__c];
                    this.addressRecord = {fields:this.fields};
                }
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
    }


    /**
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: PHYSICAL_ADDRESS_STATE
    })
    fetchStatePicklistValues ({ error, data }) {
        try {
            if (data) {
                this.StateOptions = data.values.reduce((map, item) => {
                    map[item.value] = item.label;
                    return map;
                }, {});

                this.StateMap = data.values.reduce((map, item) => {
                    map[item.label] = item.value;
                    return map;
                }, {});

                if (this.fields) {
                    this.fields[MAILING_ADDRESS_STATE.fieldApiName] = this.StateOptions[this.applicationObject.ShortSnapMailingStateCode__c];
                    this.fields[PHYSICAL_ADDRESS_STATE.fieldApiName] = this.StateOptions[this.applicationObject.ShortSnapPhysicalStateCode__c];
                    this.addressRecord = {fields:this.fields};
                }

            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
    }

    /**
     * @function - connectedCallback.
     * @description - This method is called on component initialization.
     */
    connectedCallback () {
        try {
            if (this.applicationString) {
                //This line initializes the applicationObject with the values present in the String variable from the lightning flow.
                //Useful to pre-populate data when user comes back to this screen.
                this.applicationObject = JSON.parse(this.applicationString);

                //If Address fields already have values, show them on screen
                this.fetchExistingFieldsData();
                this.getData();
            }
            this.spinnerOn = false;
            const fieldList = this.appFieldList.map(
                item => item.fieldApiName + "," + item.objectApiName
            );

            //Added for Bug# 386132 - 
            //The validation message for "ShortSnapIsIntentionToResideInKentucky__c" field wasn't getting triggered on back-forth navigation.
            //I found out that the fieldApiName for this field was comming as undefined 2nd time and hence validation metadata record wasnt coming.
            //So, I removed it from fieldApiName array and added it explicitly to the fieldList to get its validation metadata record.
            fieldList.push("ShortSnapIsIntentionToResideInKentucky__c,SSP_Application__c");
            
            this.getMetadataDetails(fieldList, null, "SSP_ShortSNAP_Address");
        } catch (error) {
            console.error("Error in connectedCallBack:", error);
        }
    }

    getData = () => {
        try {
            IS_KENTUCKY_RESIDENT.fieldApiName = this.applicationObject.ShortSnapIsIntentionToResideInKentucky__c;
            this.fields = {
                [MAILING_ADDRESS_LINE1.fieldApiName]: this.applicationObject
                    .ShortSnapMailingAddressLine1__c,
                [MAILING_ADDRESS_LINE2.fieldApiName]: this.applicationObject
                    .ShortSnapMailingAddressLine2__c,
                [MAILING_ADDRESS_CITY.fieldApiName]: this.applicationObject
                    .ShortSnapMailingCity__c,
                [MAILING_ADDRESS_COUNTY.fieldApiName]: getFieldValue(
                    this.applicationObject.ShortSnapMailingCountryCode__c,
                    MAILING_ADDRESS_COUNTRY
                ),
                [MAILING_ADDRESS_ZIP5.fieldApiName]: this.applicationObject
                    .ShortSnapMailingZipCode5__c,
                [MAILING_ADDRESS_ZIP4.fieldApiName]: this.applicationObject
                    .ShortSnapMailingZipCode4__c,

                [PHYSICAL_ADDRESS_LINE1.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalAddressLine1__c,
                [PHYSICAL_ADDRESS_LINE2.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalAddressLine2__c,
                [PHYSICAL_ADDRESS_CITY.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalCity__c,
                [PHYSICAL_ADDRESS_COUNTRY.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalCountryCode__c,
                [PHYSICAL_ADDRESS_ZIP5.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalZipCode5__c,
                [PHYSICAL_ADDRESS_ZIP4.fieldApiName]: this.applicationObject
                    .ShortSnapPhysicalZipCode4__c
            };
        } catch (error) {
            console.error("Error in getData:", error);
        }
    };

    /**
     * @function    : fetchExistingFieldsData
     * @description : Method to toggle the fetch existing fields.
     */
    fetchExistingFieldsData = () => {
        try {
            if (this.applicationObject.hasOwnProperty(constants.shortSNAPFlowConstants.isKentuckyResidentFieldAPIName)) {
                if (this.applicationObject.ShortSnapIsIntentionToResideInKentucky__c === constants.toggleFieldValue.no ) {
                    this.showMailingAddressField = true;
                    this.showPhysicalAddress = false;
                    this.showAddressComp = false;
                    this.showDifferentMailingAddress = false;
                }
                else if (this.applicationObject.ShortSnapIsIntentionToResideInKentucky__c === constants.toggleFieldValue.yes) {
                    if (this.applicationObject.hasOwnProperty(constants.shortSNAPFlowConstants.isFixedAddressFieldAPIName)) {
                        this.showPhysicalAddress = true;
                        if (this.applicationObject.ShortSnapIsFixedAddress__c === constants.toggleFieldValue.no) {
                            this.showMailingAddressField = false;
                            this.showDifferentMailingAddress = false;
                            this.havePhysicalAddress = false;
                            this.showAddressComp = true;
                        }
                        else if (this.applicationObject.ShortSnapIsFixedAddress__c === constants.toggleFieldValue.yes) {
                            this.havePhysicalAddress = true;
                            this.showDifferentMailingAddress = true;
                            this.showAddressComp = true;
                            if (this.applicationObject.hasOwnProperty(constants.shortSNAPFlowConstants.isMailingAddressFieldAPIName)) {
                                if (this.applicationObject.ShortSnapIsMailingAddress__c === constants.toggleFieldValue.yes ) {
                                    this.showMailingAddressField = true;
                                } else {
                                    this.showMailingAddressField = false;
                                }
                            }

                        }
                    }
                }
            }
        } catch (error) {
            console.error("Error in fetchExistingFieldsData:", error);
        }
    };

    /**
     * @function    : handleKentuckyResidentChange
     * @description : Method to toggle the handle resident change.
     * @param {event} event - : This event is used to trigger the values.
     */
    handleKentuckyResidentChange = event => {
        try {
            this.showAddressComp = false;
            if (event.target.value === constants.toggleFieldValue.yes) {
                this.showPhysicalAddress = true;
                this.isMailingAddressDifferent = false;
                this.showMailingAddressField = false;
                this.applicationObject[HAVE_PHYSICAL_ADDRESS.fieldApiName] = null;
            } else if (event.target.value === constants.toggleFieldValue.no) {
                this.isMailingAddressDifferent = true;
                this.showPhysicalAddress = false;
                this.havePhysicalAddress = false;
                this.showMailingAddressField = true;
                this.showDifferentMailingAddress = false;
            } else {
                this.showPhysicalAddress = false;
                this.isMailingAddressDifferent = false;
                this.showDifferentMailingAddress = false;
            }
        } catch (error) {
            console.error("Error in handleKentuckyResidentChange:", error);
        }
    };

    /**
     * @function    : togglePhysicalMailingAddress
     * @description : Method to toggle the physical address.
     * @param {event} event - : This event is used to trigger the values.
     */
    togglePhysicalMailingAddress = event => {
        try {
            this.showAddressComp = true;
            this.showMailingAddressField = false;
            if (event.target.value === constants.toggleFieldValue.yes) {
                this.havePhysicalAddress = true;
                this.showDifferentMailingAddress = true;
            } else if (event.target.value === constants.toggleFieldValue.no) {
                this.havePhysicalAddress = false;
                this.showDifferentMailingAddress = false;
            } else {
                this.havePhysicalAddress = false;
                this.showDifferentMailingAddress = false;
            }
        } catch (error) {
            console.error("Error in togglePhysicalMailingAddress:", error);
        }
    };

    /**
     * @function    : toggleIsMailingAddressDifferent
     * @description : Method to toggle the mailing address.
     * @param {event} event - : This event is used to trigger the values.
     */
    toggleIsMailingAddressDifferent = event => {
        try {
            this.showMailingAddressField = event.target.value === constants.toggleFieldValue.yes;
        } catch (error) {
            console.error("Error in toggleIsMailingAddressDifferent:", error);
        }
    };

    /**
     * @function    : initSave
     * @description : Method to save data.
     */
    initSave = () => {
        try {
            this.allowNavigation = false;
            const allDataReference = this.template.querySelectorAll(
                ".ssp-snapAddressInput"
            );
            
            //(Framework) Utility component method to handle validations.
            this.checkValidations(allDataReference);

            for (const element of allDataReference) {
                const value = element.value;
                this.applicationObject[element.fieldName] = value;

                //Logic to allow Navigation to next screen
                if (
                    element.ErrorMessageList &&
                    element.ErrorMessageList.length
                ) {
                    this.hasSaveValidationError = true;
                    this.allowNavigation = false;
                    this.spinnerOn = false;
                    break;
                } else {
                    this.allowNavigation = true;
                    this.hasSaveValidationError = false;
                    this.spinnerOn = true;
                }
            }

            //-- ADDRESS COMPONENT LOGIC
            const addressElement1 = this.template.querySelector(
                ".ssp-address1"
            );
            const addressElement2 = this.template.querySelector(
                ".ssp-address2"
            );
            let physicalAddress = {};
            let mailingAddress = {};

            if (addressElement2 || addressElement1) {
                if (addressElement1) {
                    const errorList = addressElement1.ErrorMessages();
                    if (errorList.length > 0) {
                        this.hasSaveValidationError = true;
                        this.allowNavigation = false;
                    }
                }

                if (addressElement2) {
                    const errorList = addressElement2.ErrorMessages();
                    if (errorList.length > 0) {
                        this.hasSaveValidationError = true;
                        this.allowNavigation = false;
                    }
                }
            }
            if (addressElement2) {
                mailingAddress = addressElement2.value;
                this.applicationObject[MAILING_ADDRESS_LINE1.fieldApiName] =
                    mailingAddress.addressLine1 || null;
                this.applicationObject[MAILING_ADDRESS_LINE2.fieldApiName] =
                    mailingAddress.addressLine2 || null;
                this.applicationObject[MAILING_ADDRESS_CITY.fieldApiName] =
                    mailingAddress.city || null;
                this.applicationObject[MAILING_ADDRESS_COUNTY.fieldApiName] =
                this.CountyMap[mailingAddress.county] || mailingAddress.county || null;
                this.applicationObject[MAILING_ADDRESS_STATE.fieldApiName] =
                this.StateMap[mailingAddress.state] || mailingAddress.state || null;
                this.applicationObject[MAILING_ADDRESS_COUNTRY.fieldApiName] =
                    mailingAddress.country || null;
                this.applicationObject[MAILING_ADDRESS_ZIP5.fieldApiName] =
                    mailingAddress.postalCode || null;
                this.applicationObject[MAILING_ADDRESS_ZIP4.fieldApiName] =
                    mailingAddress.postalCode4 || null;
                this.applicationObject[MAILING_LATITUDE.fieldApiName] =
                    mailingAddress.latitude || null;
                this.applicationObject[MAILING_LONGITUDE.fieldApiName] =
                    mailingAddress.longitude || null;
            }

            if (addressElement1 && this.havePhysicalAddress) {
                physicalAddress = addressElement1.value;
                this.applicationObject[PHYSICAL_ADDRESS_LINE1.fieldApiName] =
                    physicalAddress.addressLine1 || null;
                this.applicationObject[PHYSICAL_ADDRESS_LINE2.fieldApiName] =
                    physicalAddress.addressLine2 || null;
                this.applicationObject[PHYSICAL_ADDRESS_CITY.fieldApiName] =
                    physicalAddress.city || null;
                this.applicationObject[PHYSICAL_ADDRESS_COUNTY.fieldApiName] =
                this.CountyMap[physicalAddress.county] || physicalAddress.county || null;
                this.applicationObject[PHYSICAL_ADDRESS_STATE.fieldApiName] =
                this.StateMap[physicalAddress.state] || physicalAddress.state || null;
                this.applicationObject[PHYSICAL_ADDRESS_COUNTRY.fieldApiName] =
                    physicalAddress.country || null;
                this.applicationObject[PHYSICAL_ADDRESS_ZIP5.fieldApiName] =
                    physicalAddress.postalCode || null;
                this.applicationObject[PHYSICAL_ADDRESS_ZIP4.fieldApiName] =
                    physicalAddress.postalCode4 || null;
                this.applicationObject[PHYSICAL_LATITUDE.fieldApiName] =
                    physicalAddress.latitude || null;
                this.applicationObject[PHYSICAL_LONGITUDE.fieldApiName] =
                    physicalAddress.longitude || null;
            } else if (addressElement1 && !this.havePhysicalAddress) {
                mailingAddress = addressElement1.value;
                this.applicationObject[MAILING_ADDRESS_LINE1.fieldApiName] =
                    mailingAddress.addressLine1 || null;
                this.applicationObject[MAILING_ADDRESS_LINE2.fieldApiName] =
                    mailingAddress.addressLine2 || null;
                this.applicationObject[MAILING_ADDRESS_CITY.fieldApiName] =
                    mailingAddress.city || null;
                this.applicationObject[MAILING_ADDRESS_COUNTY.fieldApiName] =
                this.CountyMap[mailingAddress.county] || mailingAddress.county || null;
                this.applicationObject[MAILING_ADDRESS_STATE.fieldApiName] =
                this.StateMap[mailingAddress.state] || mailingAddress.state || null;
                this.applicationObject[MAILING_ADDRESS_COUNTRY.fieldApiName] =
                    mailingAddress.country || null;
                this.applicationObject[MAILING_ADDRESS_ZIP5.fieldApiName] =
                    mailingAddress.postalCode || null;
                this.applicationObject[MAILING_ADDRESS_ZIP4.fieldApiName] =
                    mailingAddress.postalCode4 || null;
                this.applicationObject[MAILING_LATITUDE.fieldApiName] =
                    mailingAddress.latitude || null;
                this.applicationObject[MAILING_LONGITUDE.fieldApiName] =
                    mailingAddress.longitude || null;
            }
            //Address population logic ends here

            //Logic to clear-out the Physical Address data in case its not needed.
            this.removeAddressDetailsConditionally();

            //Prepare the variable to carry forward the collected data.
            this.applicationStringOutput = JSON.stringify(
                this.applicationObject
            );

            const obj1 = JSON.parse(this.applicationStringInput);
            const obj2 = JSON.parse(this.applicationStringOutput);
            const mergedObject = { ...obj2, ...obj1 };
            this.applicationString = JSON.stringify(mergedObject);

            //Flow event to navigate to next Page of the flow
            if (this.allowNavigation) {
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
                this.spinnerOn = true;
            }
            else {
                this.spinnerOn = false;
            }
        } catch (error) {
            console.error("Error in initSave:", error);
        }
    };


    /**
     * @function    : removeAddressDetailsConditionally
     * @description : Method to remove Physical Address Details if not Needed.
     */
    removeAddressDetailsConditionally = () => {
        if ((!utility.isUndefinedOrNull(this.applicationObject.ShortSnapIsIntentionToResideInKentucky__c) && this.applicationObject.ShortSnapIsIntentionToResideInKentucky__c === constants.toggleFieldValue.no) ||
            (!utility.isUndefinedOrNull(this.applicationObject.ShortSnapIsFixedAddress__c) && this.applicationObject.ShortSnapIsFixedAddress__c === constants.toggleFieldValue.no)
        ) {
            this.applicationObject[PHYSICAL_ADDRESS_CITY.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_COUNTRY.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_LINE1.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_LINE2.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_STATE.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_ZIP4.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_ZIP5.fieldApiName] = null;
            this.applicationObject[PHYSICAL_LATITUDE.fieldApiName] = null;
            this.applicationObject[PHYSICAL_LONGITUDE.fieldApiName] = null;
            this.applicationObject[PHYSICAL_ADDRESS_COUNTY.fieldApiName] = null;
        }
    }

    /**
     * @function    : handleBack
     * @description : Method to navigate back.
     */
    handleBack = () => {
        try {
            this.spinnerOn = true;
            
            const backNavigationEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(backNavigationEvent);
        } catch (error) {
            console.error("Error in handleBack:", error);
        }
    };

    /**
     * @function    : handleExit
     * @description : Method to handle exit.
     */
    handleExit = () => {
        this.spinnerOn = true;
        // Navigate to a Program Page URL
        try {
            this[NavigationMixin.Navigate](
                {
                    type: "standard__webPage",
                    attributes: {
                        url:
                            constants.shortSNAPFlowConstants
                                .programSelectionPageURL
                    }
                },
                true
            );
        } catch (error) {
            console.error(
                "Error occurred in handleExit:",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function    : hideToast
     * @description : Method to hide Toast.
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error occurred in error toast:",
                JSON.stringify(error.message)
            );
        }
    };
}
