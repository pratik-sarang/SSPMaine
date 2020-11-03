/* eslint-disable camelcase */
/* eslint-disable no-restricted-syntax */
/**
 * Component Name: SspSnapContactInformation.
 * Author: Chirag , Shivam.
 * Description: Page for Contact Information in short SNAP.
 * Date: 4/23/2020.
 */
import { track, wire, api } from "lwc";
import sspCompleteTheQuestions from "@salesforce/label/c.SSP_CompleteTheQuestions";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspPrimaryPhoneNumber from "@salesforce/label/c.SSP_OnlyPhoneNumber";
import sspExtOptional from "@salesforce/label/c.sspExt";
import sspPrimaryPhoneType from "@salesforce/label/c.SSP_PhoneType";
import sspPhoneNumber from "@salesforce/label/c.SSP_OnlyPhoneNumber";
import sspPreferredContactMethod from "@salesforce/label/c.SSP_SnapPreferredContactMethod";
import sspPreferredSpokenLanguage from "@salesforce/label/c.SSP_PreferredSpokenLanguage";
import sspPreferredWrittenLang from "@salesforce/label/c.SSP_PreferredWrittenLang";
import sspCanWeSendTextMessages from "@salesforce/label/c.SSP_CanWeSendTextMessages";
import sspNotUSCitizenPlaceHolder from "@salesforce/label/c.sspNotUSCitizenPlaceHolder";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspAltTextPreferredSpokenLanguage from "@salesforce/label/c.sspAltTextPreffereSpokenLang";
import sspAltTextPreferredWrittenLanguage from "@salesforce/label/c.sspAltTextPrefferedWrittenLang";
import sspFirstNameLabel from "@salesforce/label/c.SSP_SignaturePageFirstName";
import sspMiddleInitialLabel from "@salesforce/label/c.SSP_SignaturePageMiddleInitial";
import sspDoesNotMiddleInitialLabel from "@salesforce/label/c.SSP_SignaturePageDoesNotMiddleInitial";
import sspLastNameLabel from "@salesforce/label/c.SSP_SignaturePageLastName";
import sspSuffixLabel from "@salesforce/label/c.SSP_SignaturePageSuffixLabel";
import sspContactInformation from "@salesforce/label/c.SSP_ContactInformation";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspExitShortSNAPApplication from "@salesforce/label/c.SSP_ExitShortSNAPApplication";
import sspSocialSecurityNumber from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspConfirmSocialSecurity from "@salesforce/label/c.SSP_ConfirmSocialSecurity";
import sspCanSendTextMessagesMobileDevice from "@salesforce/label/c.SSP_CanSendTextMessagesMobileDevice";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspShortSNAPApplication from "@salesforce/label/c.SSP_ShortSNAPApplication";
import sspNotUSCitizenSuffixTitle from "@salesforce/label/c.sspNotUSCitizenSuffixTitle";
import sspContactMethodAltText from "@salesforce/label/c.SSP_ContactMethodAltText";
import sspPreferredSpokenLanguageAltText from "@salesforce/label/c.SSP_PreferredSpokenLanguageAltText";
import sspPreferredWrittenLanguageAltText from "@salesforce/label/c.SSP_PreferredWrittenLanguageAltText";
import sspNextButtonAltText from "@salesforce/label/c.SSP_NextButtonAltText";
import sspGoBackPreviousPage from "@salesforce/label/c.SSP_GoBackPreviousPage";
import sspContactInformationPageText from "@salesforce/label/c.SSP_ContactInformationPageText";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import SSPAPPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import constants from "c/sspConstants";
import utility, { getYesNoOptions, getPhoneTypeOptions } from "c/sspUtility";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspReadPolicyValidator from "@salesforce/label/c.SSP_ReadPolicyValidatorErrorText";
import sspRequiredValidator from "@salesforce/label/c.SSP_RequiredErrorMessage";
import ssnNotMatch from "@salesforce/label/c.SSP_SsnNotMatch";
import sspSnapContactFirstName from "@salesforce/label/c.SSP_SnapContactFirstName";
import sspSnapContactMiddleInitial from "@salesforce/label/c.sspSnapContactMiddleInitial";
import sspSnapContactLastName from "@salesforce/label/c.SSP_SnapContactLastName";
import sspLearnWhy from "@salesforce/label/c.SSP_LearnWhy";
import sspLearnWhyAltText from "@salesforce/label/c.SSP_LearnWhyAltText";
import sspSNAPContactLearnHeading from "@salesforce/label/c.SSP_SNAPContactLearnHeading";
import sspSNAPContactLearnContent from "@salesforce/label/c.SSP_SNAPContactLearnContent";

import FIRST_NAME from "@salesforce/schema/SSP_Application__c.ShortSnapFirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Application__c.ShortSnapLastName__c";
import SSN_NUMBER from "@salesforce/schema/SSP_Application__c.ShortSnapReportedSsn__c";
import MIDDLE_NAME from "@salesforce/schema/SSP_Application__c.ShortSnapMiddleInitial__c";
import SUFFIX from "@salesforce/schema/SSP_Application__c.ShortSnapSuffixCode__c";
import EMAIL from "@salesforce/schema/SSP_Application__c.ShortSnapEmail__c";
import PHONE from "@salesforce/schema/SSP_Application__c.ShortSnapPrimaryPhoneNumber__c";
import EXTENSION from "@salesforce/schema/SSP_Application__c.ShortSnapPrimaryPhoneExetnsion__c";
import PHONE_TYPE_CODE from "@salesforce/schema/SSP_Application__c.ShortSnapPrimaryPhoneTypeCode__c";
import IS_TEXT_PREFERRED from "@salesforce/schema/SSP_Application__c.ShortSnapIsPrimaryTextPreferred__c";
import NOTIFICATION_CODE from "@salesforce/schema/SSP_Application__c.ShortSnapPreferredNotificationMethodCode__c";
import SPOKEN_LANGUAGE from "@salesforce/schema/SSP_Application__c.ShortSnapPreferredSpokenLanguageCode__c";
import WRITTEN_LANGUAGE from "@salesforce/schema/SSP_Application__c.ShortSnapPreferredWrittenLanguageCode__c";
import { NavigationMixin } from "lightning/navigation";

export default class SspSnapContactInformation extends NavigationMixin(
    utility
) {
    @api applicationObject = {};
    @api applicationString;

    @api applicationObjectInOut = {};
    @api applicationStringInput;
    @api applicationStringOutput;

    @track isVisible = true;
    @track trueValue = true;
    @track hasSaveValidationError = false;
    @track retMemberObjectExpr = true;
    @track showSendMessageToggle = false;
    @track showPhoneType = false;
    @track extMaxLength = 4;
    @track middleNameMaxLength = 1;
    @track spinnerOn = false;
    @track disableExtension = false;

    @track suffixOptions;
    @track applicationRecordTypeId;
    @track phoneTypeCode = getPhoneTypeOptions();
    @track primaryTextPreferred = getYesNoOptions();
    @track notificationMethodList;
    @track spokenLanguageOptions;
    @track writtenLanguageOptions;
    @track metaDataListParent = {};
    @track allowSaveValue;
    @track confirmSSNValue;
    @track reference = this;
    @track isLearnMoreModal = false;

    appFieldList = [
        FIRST_NAME,
        LAST_NAME,
        SSN_NUMBER,
        MIDDLE_NAME,
        SUFFIX,
        EMAIL,
        PHONE,
        EXTENSION,
        IS_TEXT_PREFERRED,
        PHONE_TYPE_CODE,
        NOTIFICATION_CODE,
        SPOKEN_LANGUAGE,
        WRITTEN_LANGUAGE
    ];

    label = {
        sspCompleteTheQuestions,
        sspEmail,
        sspPrimaryPhoneNumber,
        sspExtOptional,
        sspPrimaryPhoneType,
        sspPhoneNumber,
        sspPreferredContactMethod,
        sspPreferredSpokenLanguage,
        sspPreferredWrittenLang,
        sspCanWeSendTextMessages,
        sspPlaceholderPhoneNumber,
        sspAltTextPreferredWrittenLanguage,
        sspAltTextPreferredSpokenLanguage,
        sspFirstNameLabel,
        sspMiddleInitialLabel,
        sspDoesNotMiddleInitialLabel,
        sspLastNameLabel,
        sspSuffixLabel,
        sspContactInformation,
        sspBack,
        sspBackAltText,
        sspExitButton,
        sspExitShortSNAPApplication,
        sspConfirmSocialSecurity,
        sspSocialSecurityNumber,
        sspCanSendTextMessagesMobileDevice,
        sspNext,
        sspShortSNAPApplication,
        sspNotUSCitizenSuffixTitle,
        sspContactMethodAltText,
        sspPreferredSpokenLanguageAltText,
        sspPreferredWrittenLanguageAltText,
        sspNextButtonAltText,
        sspGoBackPreviousPage,
        sspContactInformationPageText,
        toastErrorText,
        sspSnapContactFirstName,
        sspSnapContactMiddleInitial,
        sspSnapContactLastName,
        sspLearnWhy,
        sspLearnWhyAltText,
        sspSNAPContactLearnContent,
        sspSNAPContactLearnHeading,
	sspReadPolicyValidator,
        sspRequiredValidator,
        ssnNotMatch,
        sspNotUSCitizenPlaceHolder
    };
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
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: SUFFIX
    })
    fetchSuffixPicklistValues ({ error, data }) {
        try {
            if (data) {
                this.suffixOptions = data.values;
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch Notification Method Code pickList values for SSP Member.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: NOTIFICATION_CODE
    })
    notificationMethodCodePickListValues ({ data, error }) {
        try {
            if (data) {
                this.notificationMethodList = data.values;
            }
            if (error) {
                console.error(
                    `Error Occurred while fetching notificationMethodCodePickListValues picklist ${error}`
                );
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch pickList values.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: SPOKEN_LANGUAGE
    })
    spokenLanguageCodePickListValues ({ data, error }) {
        try {
            if (data) {
                this.spokenLanguageOptions = data.values;
                this.languageLabelMap = data.values.reduce((map, item) => {
                    map[item.label] = item.value;
                    return map;
                }, {});
            }
            if (error) {
                console.error(
                    `Error Occurred while fetching spokenLanguageCodePickListValues picklist ${error}`
                );
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch pickList values.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$applicationRecordTypeId",
        fieldApiName: WRITTEN_LANGUAGE
    })
    writtenLanguageCodePickListValues ({ data, error }) {
        try {
            if (data) {
                this.writtenLanguageOptions = data.values;
            }
            if (error) {
                console.error(
                    `Error Occurred while fetching writtenLanguageCodePickListValues picklist ${error}`
                );
            }
        } catch (error) {
            console.error("Error in getPicklistValues: ", error);
        }
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
     * @function - connectedCallback.
     * @description - This method is called on component initialization.
     */
    connectedCallback () {
        try {
            if (this.applicationStringInput) {
                //This line initializes the applicationObject with the values present in the String variable from the lightning flow.
                //Useful to pre-populate data when user comes back to this screen.
                this.applicationObject = JSON.parse(
                    this.applicationStringInput
                );

                //Logic to populate Confirm-SSN field from SSN.
                for (const key in this.applicationObject) {
                    if (this.applicationObject.hasOwnProperty(key)) {
                        if (
                            key ===
                            constants.shortSNAPFlowConstants.SSNFieldAPIName
                        ) {
                            this.confirmSSNValue = this.applicationObject[key];
                        }
                        else if (key === constants.shortSNAPFlowConstants.PhoneNumberFieldAPIName && this.applicationObject[key]) {
                            this.showPhoneType = true;
                        }
                        else if (key === constants.shortSNAPFlowConstants.PhoneTypeFieldAPIName && this.applicationObject[key] === constants.shortSNAPFlowConstants.CE) {
                            this.showSendMessageToggle = true;
                            this.disableExtension = true;
                        }
                    }
                }
            }
            this.spinnerOn = false;
            const fieldList = this.appFieldList.map(
                item => item.fieldApiName + "," + item.objectApiName
            );
            this.getMetadataDetails(fieldList, null, "SSP_ShortSNAP_Contact");
        } catch (error) {
            console.error("Error in connectedCallBack:", error);
        }
    }

    handleFirstNameChange = event => {
        try {
            this.applicationObject.ShortSnapFirstName__c = event.target.value;
        } catch (error) {
            console.error("Error in handleFirstNameChange:", error);
        }
    };

    handleSSNChange = event => {
        try {
            this.applicationObject.ShortSnapReportedSsn__c = event.target.value;
        } catch (error) {
            console.error("Error in handleSSNChange:", error);
        }
    };

    handlePhoneNumberChange = event => {
        try {
            if (event.target && !(utility.isUndefinedOrNull(event.target.value))) {
                event.target.ErrorMessageList = event.target.ErrorMessageList.filter(
                    messageElement => messageElement != this.label.sspRequiredValidator
                );
            }

            if (event.target.value) {
                this.showPhoneType = true;
                this.applicationObject.ShortSnapPrimaryPhoneNumber__c =
                    event.target.value;
            } else {
                this.showPhoneType = false;
                this.showSendMessageToggle = false;
                this.applicationObject.ShortSnapPrimaryPhoneTypeCode__c = null;
                this.applicationObject.ShortSnapIsPrimaryTextPreferred__c = null;
            }
        } catch (error) {
            console.error("Error in handlePhoneNumberChange:", error);
        }
    };


    handleEmailChange = (event) => {
        try {
            if (event.target && !(utility.isUndefinedOrNull(event.target.value))) {
                event.target.ErrorMessageList = event.target.ErrorMessageList.filter(
                    messageElement => messageElement != this.label.sspRequiredValidator
                );
            }
        } catch (error) {
            console.error("Error in handlePhoneNumberChange:", error);
        }
    }


    handlePhoneTypeChange = (event) => {
        try {
            const extElement = this.template.querySelector(".extensionInput");
            const value = event.detail.value;
            this.showSendMessageToggle =
            value === constants.shortSNAPFlowConstants.CE;
            if (value !== constants.shortSNAPFlowConstants.CE) {
                this.applicationObject.ShortSnapIsPrimaryTextPreferred__c = null;
                this.disableExtension = false;
            }
            else if (value === constants.shortSNAPFlowConstants.CE) {
                this.disableExtension = true;
                extElement.value = undefined;
            }
        } catch (error) {
            console.error("Error in handlePhoneTypeChange:", error);
        }
    };

    checkSSNMatch = () => {
        try {
            const ssnMatchElement = this.template.querySelector(
                ".ssnInputMatch"
            );
            let errorList = JSON.parse(
                JSON.stringify(ssnMatchElement.ErrorMessageList)
            );
            const message = this.label.ssnNotMatch;
            if (!utility.isUndefinedOrNull(ssnMatchElement)) {
                if (
                    (ssnMatchElement.value !==
                        this.applicationObject.ShortSnapReportedSsn__c &&
                        this.applicationObject.ShortSnapReportedSsn__c) ||
                    (ssnMatchElement.value &&
                        !this.applicationObject.ShortSnapReportedSsn__c)
                ) {
                    if (!errorList.includes(message)) {
                        errorList.push(message);
                    }
                } else {
                    if (errorList) {
                        errorList = errorList.filter(item => item !== message);
                    }
                }
                ssnMatchElement.ErrorMessageList = errorList;
            }
        } catch (error) {
            console.error("Error in handleSSNMatch:", error);
        }
    };

    handleEmailConditionallyRequired = () => {
        try {
            const requiredMessage = this.label.sspRequiredValidator;
            const preferredContactElement = this.template.querySelector(
                ".preferredContactMethod"
            );
            const emailElement = this.template.querySelector(".emailInput");
            let errorList = emailElement.ErrorMessageList;
            if ((preferredContactElement.value === constants.shortSNAPFlowConstants.EE || preferredContactElement.value === constants.shortSNAPFlowConstants.ES) && !(emailElement.value)) {
                if (!errorList.includes(requiredMessage)) {
                    errorList.push(requiredMessage);
                }
            } else if (errorList) {
                errorList = errorList.filter(mess => mess !== requiredMessage);
            }
            emailElement.ErrorMessageList = errorList;
        } catch (error) {
            console.error("Error in handleEmailConditionallyRequired:", error);
        }
    };

    handlePhoneConditionallyRequired = () => {
        try {
            const requiredMessage = this.label.sspRequiredValidator;

            const phoneElement = this.template.querySelector(".phoneInput");
            const extElement = this.template.querySelector(".extensionInput");
            const preferredContactElement = this.template.querySelector(
                ".preferredContactMethod"
            );
            const phoneValue = phoneElement.value;
            let errorList = phoneElement.ErrorMessageList;
            if (
                (extElement.value ||
                    preferredContactElement.value ===
                        constants.shortSNAPFlowConstants.ES) &&
                !phoneValue
            ) {
                if (!errorList.includes(requiredMessage)) {
                    errorList.push(requiredMessage);
                }
            } else if (errorList) {
                errorList = errorList.filter(mess => mess !== requiredMessage);
            }
            phoneElement.ErrorMessageList = errorList;
        } catch (error) {
            console.error("Error in handlePhoneConditionallyRequired:", error);
        }
    };

    initSave = () => {
        try {
            let allowNavigation = false;
            const elem = this.template.querySelectorAll(".snapInputs");
            //(Framework) Utility component method to handle validations.
            this.checkValidations(elem);

            //Method to check if both SSN's match or not.
            this.checkSSNMatch();

            //Method to check conditional required criteria of Email field.
            this.handleEmailConditionallyRequired();

            //Method to check conditional required criteria of Phone field.
            this.handlePhoneConditionallyRequired();

            //This loop updates/populates the value of all the keys in applicationObject.
            for (const element of elem) {
                let value = element.value;
                if (
                    element.tagName.includes(constants.notUSCitizen.TYPEAHEAD)
                ) {
                    value = this.languageLabelMap[element.value];
                }
                if (utility.isUndefinedOrNull(value) || value === "") {
                    value = null;
                }
                this.applicationObject[element.fieldName] = value;

                //Logic to allow Navigation to next screen
                if (
                    element.ErrorMessageList &&
                    element.ErrorMessageList.length
                ) {
                    this.hasSaveValidationError = true;
                    allowNavigation = false;
                    this.spinnerOn = false;
                    break;
                } else {
                    allowNavigation = true;
                    this.hasSaveValidationError = false;
                    this.spinnerOn = true;
                }
            }

            //Logic to remove "undefined" key from object.
            for (const key in this.applicationObject) {
                if (key === constants.shortSNAPFlowConstants.undefinedKey) {
                    delete this.applicationObject[key];
                }
            }
            this.applicationStringOutput = JSON.stringify(
                this.applicationObject
            );
            this.applicationStringInput = JSON.stringify(
                this.applicationObject
            );

            //Flow event to navigate to next Page of the flow
            if (allowNavigation) {
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
            }
        } catch (error) {
            console.error("Error in initSave:", error);
        }
    };

    handleBack = () => {
        try {
            this.spinnerOn = true;
            // Navigate to a Get Started Page URL
            this[NavigationMixin.Navigate](
                {
                    type: "standard__webPage",
                    attributes: {
                        url: constants.shortSNAPFlowConstants.getStartedPageURL
                    }
                },
                true
            );
        } catch (error) {
            console.error("Error in handleBack:", error);
        }
    };

    handleExit = () => {
        try {
            this.spinnerOn = true;
            // Navigate to a Program Page URL
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
            console.error("Error in handleExit:", error);
        }
    };

    /*
     * @function    : hideToast
     * @description : Method to hide Toast
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

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     */
    openLearnMoreModal () {
            this.isLearnMoreModal = true;
    }

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal () {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error(
                "Error in modal", error
            );
        }
    }
}