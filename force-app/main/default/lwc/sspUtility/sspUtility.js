/* eslint-disable no-console */
import { api, wire, track } from "lwc";
import getValidationMessages from "@salesforce/apex/GenericValidationController.getMetadataList";
import sspMonthJanuary from "@salesforce/label/c.SSP_January";
import sspMonthFebruary from "@salesforce/label/c.SSP_February";
import sspMonthMarch from "@salesforce/label/c.SSP_March";
import sspMonthApril from "@salesforce/label/c.SSP_April";
import sspMonthMay from "@salesforce/label/c.SSP_May";
import sspMonthJune from "@salesforce/label/c.SSP_June";
import sspMonthJuly from "@salesforce/label/c.SSP_July";
import sspMonthAugust from "@salesforce/label/c.SSP_August";
import sspMonthSeptember from "@salesforce/label/c.SSP_September";
import sspMonthOctober from "@salesforce/label/c.SSP_October";
import sspMonthNovember from "@salesforce/label/c.SSP_November";
import sspMonthDecember from "@salesforce/label/c.SSP_December";
import getTimeTravelDate from "@salesforce/apex/SSP_Utility.today";
import reviewRequiredRules from "@salesforce/apex/SSP_RulesEngine.getRRTriggerRules"
import sspResourceOtherAccount from "@salesforce/label/c.SSP_IndividualOutsideOfHousehold";
import helpContentUtility from "@salesforce/apex/NavFlowController.fetchHelpContent";
import sspOther from "@salesforce/label/c.Other";

import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspLandline from "@salesforce/label/c.sspLandline";
import sspCell from "@salesforce/label/c.sspCell";
import BaseComponent from "c/sspBaseComponent";

import { applicationMode, summaryPageNameMap } from "c/sspConstants";
import markSectionComplete from "@salesforce/apex/SSP_ApplicationSummaryController.markSectionsComplete";
import markSectionsReviewRequired from "@salesforce/apex/SSP_ApplicationSummaryController.markSectionsReviewRequired";
import getCurrentLoggedInUserLang from "@salesforce/apex/SSP_CollateralContact.getCurrentLoggedInUserLang";

const months = new Array();
months[0] = sspMonthJanuary;
months[1] = sspMonthFebruary;
months[2] = sspMonthMarch;
months[3] = sspMonthApril;
months[4] = sspMonthMay;
months[5] = sspMonthJune;
months[6] = sspMonthJuly;
months[7] = sspMonthAugust;
months[8] = sspMonthSeptember;
months[9] = sspMonthOctober;
months[10] = sspMonthNovember;
months[11] = sspMonthDecember;

const getCurrentMonthName = (month) => months[month];
const getPreviousMonthName = (month) => {
    if (month === 0) {
        return months[11];
    }
    return months[month - 1];
};
const getNextMonthName = (month) => {
    if (month === 11) {
        return months[0];
    }
    return months[month + 1];
};

const formatLabels = (format, parameters) => {
    const args = Array.prototype.slice.call(parameters, 0);
    return format.replace(/{(\d+)}/g, function (match, number) {
        return typeof args[number] != "undefined" ? args[number] : match;
    });
};

const getPicklistSubTypeValues = (
    controllingFieldSelectedValue,
    dependentFieldData
) => {
    const key =
        dependentFieldData.controllerValues[controllingFieldSelectedValue];
    const subTypeOptions = dependentFieldData.values.filter(opt =>
        opt.validFor.includes(key)
    );
    return subTypeOptions;
};

const getYesNoOptions = () => [
    {
        label: sspYes,
        value: "Y"
    },
    { label: sspNo, value: "N" }
];

const getPhoneTypeOptions = () => [
    {
        label: sspLandline,
        value: "LND"
    },
    {
        label: sspCell,
        value: "CE"
    }
];

const getOtherValue = () => ({ label: sspOther, value: "Other" });
const getOtherAccountValue = () => ({ label: sspResourceOtherAccount, value: "Other" });

/**
 * @function isBoolean
 * @description Utility method to check if the value passed is boolean or not.
 * @param {any} value - Boolean value.
 */
const isBoolean = value => typeof value === "boolean";

/**
 * @function isString Checks if the value passed is a string or not
 * @param {*} value  - The value to check for string type.
 * @returns {boolean} Returns true if the type of the value is string or false.
 * @example
 *  isString('foo') => true
 *  isString(1) => false
 *  isString(new String('foo')) => true
 */
const isString = value => {
    const toString = Object.prototype.toString;
    const type = typeof value;
    return (
        type === "string" ||
        (type === "object" &&
            value !== null &&
            !Array.isArray(value) &&
            toString.call(value) === "[object String]")
    );
};

/**
 * @function toggleClass toggles the class on the element based on its availability
 * @param {HTMLElement} element - Html markup element.
 * @param {string} className - Name of the class to be toggled.
 * @example
 *  toggleClass(elem, 'slds-hide')
 */
const toggleClass = (element, className) => {
    element.classList.toggle(className, !element.classList.contains(className));
};

/**
 * @function scrollToTop Scrolls to the top of the document
 * @example
 * scrollToTop()
 */
const scrollToTop = () => {
    window.scroll(0, 0);
};

const showHelpContent = screenNameValue => helpContentUtility({
        screenName: screenNameValue,
        language: navigator.language
    })
        .then(response => response)
        .catch(error => {
            console.error("error " + error);
            return null;
        });

export default class sspUtility extends NavigationMixin(BaseComponent) {
    @api MetadataList;
    @api entityMappingWrapper; //CD2 2.5 Security Role Matrix and Program Access.
    @api allowSave;
    @api objWrap;
    @api modalContentValue;

    @track months = [];
    @track todayDate;
    @track reviewRequiredListValue = [];
    @track language;
    self = this;
    reviewRequiredListValueVar = [];

    @wire(getTimeTravelDate)
    getTodayDate ({ error, data }) {
        if (data) {
            this.todayDate = data;
        }
    }

    //This function is used to check validations of the input screen element
    @api
    checkValidations (inputValue) {
        try {
            //const self = this;
            let AllowSave = true;
            let errList = [];
            const allowSaveArr = [];
            for (let i = 0; i < inputValue.length; i++) {
                if (
                    inputValue[i].entityName !== null &&
                    inputValue[i].fieldName !== null &&
                    inputValue[i].entityName !== undefined
                ) {
                    errList = inputValue[i].ErrorMessages();
                    if (errList != null && errList.length > 0) {
                        AllowSave = false;
                    } else {
                        AllowSave = true;
                    }
                    allowSaveArr.push(AllowSave);
                }
            }
            if (allowSaveArr.includes(false)) {
                this.allowSave = false;
            } else {
                this.allowSave = true;
                this.twoWayBinding(inputValue);
            }
        } catch (error) {
            console.error("Error in checkValidations", error);
        }
    }

    @api
    getMetadataDetails (fieldEntityNameList, inputValue, screenNameValue) {
        try {
            let fieldEntityConcat = [];
            if (inputValue !== null && this.inputValue !== "") {
                for (let i = 0; i < inputValue.length; i++) {
                    fieldEntityConcat.push(
                        inputValue[i].fieldName + "," + inputValue[i].entityName
                    );
                }
            } else {
                fieldEntityConcat = fieldEntityNameList;
            }
            getValidationMessages({
                FieldEntityConcatList: fieldEntityConcat,
                screenName: screenNameValue
            })
                .then(result => {
                    //if (1 === 1) {
                    /**CD2 2.5 Security Role Matrix and Program Access. */
                    const metadataMap = {};
                    if (result != null && result != undefined) {
                        this.entityMappingWrapper = result;
                        const {
                            metadataList: entityMap,
                            securityMatrix: { screenPermission }
                        } = result;
                        
                        if (entityMap != null && entityMap != undefined) {
                            Object.keys(entityMap).forEach(key => {
                                const metadata = entityMap[key];
                                metadata.isDisabled =
                                    screenPermission != null &&
                                    screenPermission != undefined &&
                                    screenPermission == "ReadOnly";
                                metadataMap[key] = metadata;
                            });
                        }
                    }

                       this.MetadataList = metadataMap != null && metadataMap != undefined && Object.keys(metadataMap).length > 0 ? metadataMap : result.metadataList;                    
                })
                .catch(error => {
                    /*eslint no-console: ["error", { allow: ["error"] }] */

                    console.error("Error in getValidationMessages", error);
                });
        } catch (error) {
            console.error("Error in getMetadataDetails", error);
        }
    }

    @api
    twoWayBinding (inputValue) {
        try {
            if (inputValue != null && inputValue.length > 0) {
                let jsonString = "";
                for (let i = 0; i < inputValue.length; i++) {
                    if (
                        inputValue[i].value !== null &&
                        inputValue[i].value !== undefined &&
                        inputValue[i].value !== ""
                    ) {
                        jsonString =
                            '"' +
                            inputValue[i].getAttribute("data-id") +
                            '"' +
                            ":" +
                            '"' +
                            inputValue[i].value +
                            '"' +
                            "," +
                            jsonString;
                    } else {
                        jsonString =
                            '"' +
                            inputValue[i].getAttribute("data-id") +
                            '"' +
                            ":" +
                            null +
                            "," +
                            jsonString;
                    }
                }
                jsonString = jsonString.substring(0, jsonString.length - 1);
                const objVar = "{" + jsonString + "}";
                this.objWrap = objVar;
            }
        } catch (error) {
            console.error("Error in twoWayBinding", error);
        }
    }

    @api
    getMonthName (monthCriteria) {
        this.months.push(sspMonthJanuary);
        this.months.push(sspMonthFebruary);
        this.months.push(sspMonthMarch);
        this.months.push(sspMonthApril);
        this.months.push(sspMonthMay);
        this.months.push(sspMonthJune);
        this.months.push(sspMonthJuly);
        this.months.push(sspMonthAugust);
        this.months.push(sspMonthSeptember);
        this.months.push(sspMonthOctober);
        this.months.push(sspMonthNovember);
        this.months.push(sspMonthDecember);

        let today;

        if (monthCriteria === "current") {
            return this.months[this.today.getMonth()];
        } else if (monthCriteria === "previous") {
            if (this.today.getMonth() === 0) {
                return this.months[11];
            }
            return this.months[today.getMonth() - 1];
        } else if (monthCriteria === "next") {
            if (today.getMonth() === 11) {
                return this.months[0];
            }
            return this.months[today.getMonth() + 1];
        }
    }
    static isUndefinedOrNull (obj) {
        return obj === undefined || obj === null;
    }
    static isEmpty (obj) {
        return obj === "";
    }
    static isArrayEmpty (obj) {
        return obj.length === 0;
    }
    static isUndefined (obj) {
        return obj === undefined;
    }
    // if date is YYYY-MM-DD converted to MM/DD/YYYY
    static getNewFormatDate (currentDate) {
        if (currentDate !== undefined && currentDate !== null) {
            const dateSplitData = currentDate.split("-");
            return (
                dateSplitData[1] +
                "/" +
                dateSplitData[2] +
                "/" +
                dateSplitData[0]
            );
        }
       return "";
     }

    
    /**
    * @function constructVisibilityMatrix
    * @description To construct visibility matrix - CD2 2.5 Security Role Matrix and Program Access.
    * @param {object} appProgramList - List of application level program codes.
    * @author Shrikant Raut
    */
    @api
    constructVisibilityMatrix = (appProgramList) => {
        const { applicableProgramSet, metadataList: entityMap, renderingMap, securityMatrix } = this.entityMappingWrapper;
        const applicablePrograms = (applicableProgramSet != null && applicableProgramSet != undefined) ? applicableProgramSet.filter(program => (appProgramList != null && appProgramList != undefined && appProgramList.includes(program))) : [];
        Object.keys(entityMap).forEach(key => {
            const fieldAPI = key.split(",")[0];
            const fieldPrograms = renderingMap[fieldAPI].programs;
            renderingMap[fieldAPI].renderElement = (fieldPrograms && fieldPrograms.some(program => applicablePrograms.includes(program)));
        });
        return { renderingMap, securityMatrix};
    }

    @api
    showHelpContentData (screenNameValue) {
        try {
            getCurrentLoggedInUserLang()
            .then(result => {
                this.language=result;
                this.showContentData(screenNameValue);
            })
            .catch(error => {
                this.showContentData(screenNameValue);
                console.error("Error"  + JSON.stringify(error));
            });

        } catch (error) {
            console.error("Error calling showHelpContentData method: ", error);
        }
    }

        /**
     * @function showContentData
     * @description To get the modal content based on language selected by the the user.
     * @param {string} screenNameValue - Screen Name.
     * @author Venkata Ranga Babu
     */
    showContentData = (screenNameValue) => {
        let customLanguage;
        const currentURL = window.location.href;
        if (
            currentURL.indexOf("en_US") === -1 &&
            currentURL.indexOf("es_US") === -1
        ) {
            
            customLanguage = this.language === "en_US" || this.language === "es_US" ? this.language : "en_US";
            // customLanguage = "en_US";
        } else if ((currentURL.indexOf("en_US") != -1)) {
            customLanguage = "en_US";
        } else if ((currentURL.indexOf("es_US") != -1)) {
            customLanguage = "es_US";
        }

        helpContentUtility({
            screenName: screenNameValue,
            language: customLanguage
        })
            .then(response => {

                this.modalContentValue = response;
            })
            .catch(error => {
                this.modalContentValue = "";
                console.error("error " + error);
            });
    }

    @api
    validateReviewRequiredRules (appId, memberId, selectedScreens,reviewRequiredList, sMode) {
        try {

            return reviewRequiredRules({
                applicationId: appId,
                memberId: memberId,
                selectedScreens: selectedScreens,
                reviewRequiredList: reviewRequiredList,
                mode: sMode
            });
        } catch (error) {
            console.error("Error in RR", error);
        }
        return Promise.reject();
    }

    @api
    get reviewRequiredList () {
        return this.reviewRequiredListValue;
    }
    set reviewRequiredList (value) {
        if (value) {
            this.reviewRequiredListValue = value;
            // self.reviewRequiredListValueVar = value;
        }
    }

    @track sourceApplicationId;

    /**
     * @function wiredGetPageRef
     * @description Gets current page reference.
     * @param {object} value - Page Reference value.
     * @author Ajay Saini
     */
    @wire(CurrentPageReference)
    wiredGetPageRef (value) {
        if (value) {
            
            this.pageRef = value;
            if (value.state && value.state.applicationId) {
                this.sourceApplicationId = value.state.applicationId;
            }
            if (value.state && value.state.mode) {
                this.mode = value.state.mode;
            }
            if (value.attributes && value.attributes.sectionId) {
                this.$sourceSectionId = value.attributes.sectionId;
            }
            if (value.attributes && value.attributes.incompleteSections) {
                this.$incompleteSections = value.attributes.incompleteSections;
            }
        }
    }

    /**
     * @function navigateToAppSummary
     * @description Navigates to app summary page.
     * @returns {promise} Promise about navigation status.
     * @param {string} sectionOverride - Override Screen Id override.
     * @param {string} applicationOverride - Override Application Id.
     * @param {string} modeOverride - Override mode.
     * @author Ajay Saini
     */
    navigateToAppSummary = (sectionOverride, applicationOverride, modeOverride) => {
        const mode = modeOverride || this.mode || applicationMode.INTAKE;
        const pageName = summaryPageNameMap[mode];
        const sectionId = sectionOverride || this.$sourceSectionId;
        const incompleteSections = this.$incompleteSections;
        const applicationId = applicationOverride || this.sourceApplicationId;
        return this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: pageName,
                sectionId,
                incompleteSections
            },
            state: {
                applicationId
            }
        });
    }

    /**
     * @function markScreenComplete
     * @description Marks screen complete on application level.
     * @returns {promise} Promise about update status.
     * @param {string} screenId - Id of the screen.
     * @author Ajay Saini
     */
    markScreenComplete = (screenId) =>
        sspUtility.markScreenComplete(this.sourceApplicationId, screenId)
            .then(response => {
                if(response.mapResponse) {
                    this.newlyCompletedSections = response.mapResponse.newlyCompletedSections;
                }
            })


    /**
     * @function markScreenComplete
     * @description Marks screen complete on application level.
     * @returns {promise} Promise about update status.
     * @param {string} applicationId - Application Id.
     * @param {string} screenId - Id of the screen.
     * @author Ajay Saini
     */
    static markScreenComplete = (applicationId, screenId) => {
        
        if (applicationId) {
            return markSectionComplete({
                applicationId,
                sections: screenId
            }).then(response => {
                
                if (response.bIsSuccess) {
                    // this.newlyCompletedSections = response.mapResponse.newlyCompletedSections;
                    return Promise.resolve(response);
                }
                return Promise.reject(response);
            });
        }
        return Promise.reject("Application Id not set.");
    }

    /**
     * @function markScreenReviewRequired
     * @description Marks screen review required on application level.
     * @returns {promise} Promise about update status.
     * @param {string} applicationId - Application Id.
     * @param {string} screenId - Id of the screen.
     * @author Ajay Saini
     */
    static markScreenReviewRequired = (applicationId, screenId) => {
        
        if (applicationId) {
            return markSectionsReviewRequired({
                applicationId,
                sections: screenId
            }).then(response => response);
        }
        return Promise.reject("Application Id not set.");
    }
}



/**
    * @function futureDate
    * @description Checks whether the expense end date.
    * @param {*} endDate - Expense end date.
    * @param {*} todayDate - Today end date.
    */
const  futureDate =(endDate, todayDate)=> { 
    try {
        if (endDate !== null && endDate !== undefined && endDate !== ""
            && todayDate !== null && todayDate !== undefined && todayDate !== "" ) {
            const jsTodayDate = new Date(todayDate);
            const jsEndDate = new Date(endDate);
            return jsEndDate.getTime() > jsTodayDate.getTime();
        }
        else{
            return false;
        }
    } catch (error) {
        console.error("Error in futureDate:", error);
    }
}

/**
 * @function getUrlParameter
 * @description Decodes the url parameter provided - Added by Narapa.
 * @param {*} name - Name of the url parameter to be decoded.
 */
const getUrlParameter=(name)=>{
    const changedName = name.replace(/[[]/, "\\[").replace(/[\]]/, "\\]");
    const regex = new RegExp("[\\?&]" + changedName + "=([^&#]*)");
    const results = regex.exec(location.search); 
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}






export {
    formatLabels,
    getPicklistSubTypeValues,
    getCurrentMonthName,
    getPreviousMonthName,
    getNextMonthName,
    getYesNoOptions,
    getPhoneTypeOptions,
    getOtherValue,
    isBoolean,
    isString,
    toggleClass,
    scrollToTop,
    getOtherAccountValue,
    showHelpContent,
    futureDate,
	getUrlParameter
};
