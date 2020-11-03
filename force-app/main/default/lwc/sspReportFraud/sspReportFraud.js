/**
 * Name : sspReportFraud.
 * Description : To report a fraud.
 * Author : Vishakha Verma, Nikhil Shinde.
 * Date : 07/13/2020.
 **/

import { api, wire, track } from "lwc";
import utility, { getYesNoOptions } from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import sspConstants from "c/sspConstants";
import submitFraudReport from "@salesforce/apex/SSP_ReportFraudService.submitFraudReport";
import getUserContactInfo from "@salesforce/apex/SSP_ReportFraudService.getUserContactInfo";

import pageUrl from "@salesforce/resourceUrl/captchaFraud";

import GENDER_CODE from "@salesforce/schema/SSP_Member__c.GenderCode__c";
import SUFFIX_CODE from "@salesforce/schema/SSP_Member__c.SuffixCode__c";
import MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";

// custom labels
import sspFooterReportFraud from "@salesforce/label/c.SSP_FooterReportFraud";
import gender from "@salesforce/label/c.SSP_Gender";
import chooseOneMissing from "@salesforce/label/c.SSP_ChooseOneMissing";
import genderOptionsTitleText from "@salesforce/label/c.SSP_GenderOptionsTitleText";
import suffixOptionsTitleText from "@salesforce/label/c.SSP_SuffixOptionsTitleText";
import fraudType from "@salesforce/label/c.sspFraudType";

import sspWhoCommitted from "@salesforce/label/c.SSP_ReportFraudWhoCommitted";
import sspWhoCommittedAlternateText from "@salesforce/label/c.SSP_ReportFraudWhoCommittedAlternateText";
import sspFraudLetUsKnow from "@salesforce/label/c.SSP_ReportFraudLetUsKnow";
import sspProvideInfoToIdentify from "@salesforce/label/c.SSP_ReportFraudProvideInfoToIdentify";
import sspMiddleName from "@salesforce/label/c.SSP_ReportFraudMiddle";
import sspLetUsKnowEmployer from "@salesforce/label/c.SSP_ReportFraudLetUsKnowEmployer";
import sspEmployerName from "@salesforce/label/c.SSP_ReportFraudEmployerName";
import sspEmployerAddress from "@salesforce/label/c.SSP_ReportFraudEmployerAddress";
import sspCanOIGContactYou from "@salesforce/label/c.SSP_ReportFraudCanOIGContactYou";
import sspYourContactInfo from "@salesforce/label/c.SSP_ReportFraudYourContactInfo";
import sspHowCanOIGContact from "@salesforce/label/c.SSP_ReportFraudHowCanOIGContact";
import sspYourEmail from "@salesforce/label/c.SSP_ReportFraudYourEmail";
import sspSubmitFeedback from "@salesforce/label/c.SSP_ReportFraudSubmitFeedback";
import sspSubmitFeedbackAlternateText from "@salesforce/label/c.SSP_ReportFraudSubmitFeedbackAlternateText";
import sspCancelAlternateText from "@salesforce/label/c.SSP_ReportFraudCancelAlternateText";
import sspAddress from "@salesforce/label/c.SSP_ReportFraudAddress";
import sspPhoneExtension from "@salesforce/label/c.SSP_ReportFraudPhoneExtension";

import firstName from "@salesforce/label/c.SSP_FirstName";
import lastName from "@salesforce/label/c.SSP_LastName";
import suffix from "@salesforce/label/c.SSP_Suffix";
import socialSecurityNumber from "@salesforce/label/c.SSP_SocialSecurityNumber";
import dateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspPhoneNumber from "@salesforce/label/c.SSP_MyInformationPhoneNumber";
import sspCounty from "@salesforce/label/c.SSP_County";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspZipCode from "@salesforce/label/c.SSP_ZipCode";
import sspState from "@salesforce/label/c.SSP_State";
import sspCity from "@salesforce/label/c.SSP_City";
import sspCancel from "@salesforce/label/c.SSP_RequestMedicaidCardCancel";
import sspName from "@salesforce/label/c.SSP_Name";
import ADDRESS from "@salesforce/label/c.SSP_SearchAddressLine1";
import ADDRESS_LINE2 from "@salesforce/label/c.AddressLine2";
import COUNTRY from "@salesforce/label/c.Country";
import sspReportFraudHowCanOIGContactOptions from "@salesforce/label/c.SSP_ReportFraudHowCanOIGContactOptions";
import sspReportFraudStateAlternateText from "@salesforce/label/c.SSP_ReportFraudStateAlternateText";
import sspReportFraudEmployerAddressLineOne from "@salesforce/label/c.SSP_ReportFraudEmployerAddressLineOne";
import sspReportFraudEmployerAddressLineTwo from "@salesforce/label/c.SSP_ReportFraudEmployerAddressLineTwo";

//Next Steps
import sspNextSteps from "@salesforce/label/c.SSP_ReportFraudNextSteps";
import sspConfirmationNumber from "@salesforce/label/c.SSP_ReportFraudConfirmationNumber";
import sspSubmittedToast from "@salesforce/label/c.SSP_ReportFraudSubmittedToast";
import sspAnonymouslyText from "@salesforce/label/c.SSP_ReportFraudAnonymouslyText";
import sspOIGReachOutText from "@salesforce/label/c.SSP_ReportFraudOIGReachOutText";
import sspReturnToKentuckyHome from "@salesforce/label/c.SSP_ReportFraudReturnToKentuckyHome";
import sspReturnToKentuckyHomeAlternate from "@salesforce/label/c.SSP_ReportFraudReturnToKentuckyHomeAlternate";

import MAILING_ADDRESS_LINE1 from "@salesforce/schema/SSP_Member__c.MailingAddressLine1__c";
import MAILING_ADDRESS_LINE2 from "@salesforce/schema/SSP_Member__c.MailingAddressLine2__c";
import MAILING_ADDRESS_CITY from "@salesforce/schema/SSP_Member__c.MailingCity__c";
import MAILING_ADDRESS_COUNTY from "@salesforce/schema/SSP_Member__c.MailingCountyCode__c";
import MAILING_ADDRESS_STATE from "@salesforce/schema/SSP_Member__c.MailingStateCode__c";
import MAILING_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Member__c.MailingCountryCode__c";
import MAILING_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Member__c.MailingZipCode4__c";
import MAILING_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Member__c.MailingZipCode5__c";

import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_Member__c.PhysicalAddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_Member__c.PhysicalAddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_Member__c.PhysicalCity__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_Member__c.PhysicalCountyCode__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_Member__c.PhysicalStateCode__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Member__c.PhysicalCountryCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Member__c.PhysicalZipCode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Member__c.PhysicalZipCode5__c";

import STATE_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalStateCode__c";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspHowCanOIGContactAlt from "@salesforce/label/c.SSP_FraudCheckitle";

import { getObjectInfo } from "lightning/uiObjectInfoApi";

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
        label: sspCity
    },
    county: {
        ...PHYSICAL_ADDRESS_COUNTY,
        label: sspCounty
    },
    state: {
        ...PHYSICAL_ADDRESS_STATE,
        label: sspState
    },
    country: {
        ...PHYSICAL_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...PHYSICAL_ADDRESS_ZIP5,
        label: sspZipCode
    },
    postalCode4: {
        ...PHYSICAL_ADDRESS_ZIP4,
        label: sspZipCode
    }
};

const EA_FIELD_MAP = {
    addressLine1: {
        ...MAILING_ADDRESS_LINE1,
        label: sspReportFraudEmployerAddressLineOne
    },
    addressLine2: {
        ...MAILING_ADDRESS_LINE2,
        label: sspReportFraudEmployerAddressLineTwo
    },
    city: {
        ...MAILING_ADDRESS_CITY,
        label: sspCity
    },
    county: {
        ...MAILING_ADDRESS_COUNTY,
        label: sspCounty
    },
    state: {
        ...MAILING_ADDRESS_STATE,
        label: sspState
    },
    country: {
        ...MAILING_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...MAILING_ADDRESS_ZIP5,
        label: sspZipCode
    },
    postalCode4: {
        ...MAILING_ADDRESS_ZIP4,
        label: sspZipCode
    }
};

const UA_FIELD_MAP = {
    addressLine1: {
        ...MAILING_ADDRESS_LINE1,
        label: ADDRESS
    },
    addressLine2: {
        ...MAILING_ADDRESS_LINE2,
        label: ADDRESS_LINE2
    },
    city: {
        ...MAILING_ADDRESS_CITY,
        label: sspCity
    },
    county: {
        ...MAILING_ADDRESS_COUNTY,
        label: sspCounty
    },
    state: {
        ...MAILING_ADDRESS_STATE,
        label: sspState
    },
    country: {
        ...MAILING_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...MAILING_ADDRESS_ZIP5,
        label: sspZipCode
    },
    postalCode4: {
        ...MAILING_ADDRESS_ZIP4,
        label: sspZipCode
    }
};
export default class sspReportFraud extends utility {
    @track vFPage = pageUrl;
    @track fraudRecord = {
        WhoCommittedFraud: null,
        WhatHappened: null,
        IndividualFraudFirstName: null,
        IndividualFraudMiddleName: null,
        IndividualFraudLastName: null,
        IndividualFraudSuffix: null,
        IndividualFraudGender: null,
        IndividualFraudSSN: null,
        IndividualFraudDOB: null,
        BusinessFraudName: null,
        FraudAddressLine1: null,
        FraudAddressLine2: null,
        FraudCity: null,
        FraudState: null,
        FraudZipCode: null,
        FraudCounty: null,
        FraudPhoneNumber: null,
        FraudExt: null,
        FraudCaseNumber: null,
        IndividualFraudEmployerName: null,
        IndividualFraudEmployerAddressLine1: null,
        IndividualFraudEmployerAddressLine2: null,
        IndividualFraudEmployerCity: null,
        IndividualFraudEmployerState: null,
        IndividualFraudEmployerZipCode: null,
        IndividualFraudEmployerCounty: null,
        CanOIGContactYou: null,
        HowOIGContactYou: [],
        UserEmail: null,
        UserAddressLine1: null,
        UserAddressLine2: null,
        UserCity: null,
        UserStateCode: null,
        UserCounty: null,
        UserZipCode: null,
        UserPhoneNumber: null,
        UserExt: null
    };
    @track isDisabledSubmitButton = true;
    @track yesNoPicklist = getYesNoOptions();
    @track fieldMap = PA_FIELD_MAP;
    @track fieldMapTwo = UA_FIELD_MAP;
    @track fieldMapThree = EA_FIELD_MAP;
    @track showFieldsForIndividual = false;
    @track showFieldsForBusiness = false;
    @track showFieldsForBoth = false;
    @track metaDataListParent;
    @track addressMetadata;
    @track allowSaveValue;
    @track objValue;
    @track genderOptions = [];
    @track suffixCodes = [];
    @track listData = [];
    @track optionsList = [];
    @track showIndividualFields = false;
    @track showBothFields = false;
    @track showBusinessFields = false;
    @track showFields = false;
    @track isProvideInfo = false;
    @track howCanOIGOptions = [];
    @track ifOIGCanContact = false;
    @track isYourEmail = false;
    @track isYourMail = false;
    @track isYourPhone = false;
    @track fraudId = null;
    @track ExceptionId = null;
    @track statePicklist = [];
    @track selectedFraud = "";
    @track isNextSteps = false;
    @track showSpinner = true;
    @track currentIndividualId;
    @track contactId;
    @track toastCondition = "positive";
    @track toastText = "";
    @track trueValue = true;
    @track showToast = false;
    @track canOIGContact = false;
    @track originPage = "";
    @track requiredFilled = false;
    @track captchaVerified = false;
    @track addressRecord;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track userAddressAvailable = false;
    @track showErrorToast = false;
    @track mIMaxLength = 1;
    @track isMetaDataLoaded = false;
    @track userEmail;
    @track userPhone;
    @track userPhoneExt;

    @track label = {
        sspHowCanOIGContactAlt,
        sspFooterReportFraud,
        genderOptionsTitleText,
        suffixOptionsTitleText,
        gender,
        chooseOneMissing,
        sspWhoCommitted,
        sspWhoCommittedAlternateText,
        sspFraudLetUsKnow,
        sspProvideInfoToIdentify,
        sspMiddleName,
        sspLetUsKnowEmployer,
        sspEmployerName,
        sspEmployerAddress,
        sspCanOIGContactYou,
        sspYourContactInfo,
        sspHowCanOIGContact,
        sspYourEmail,
        sspSubmitFeedback,
        sspSubmitFeedbackAlternateText,
        sspCancelAlternateText,
        sspAddress,
        sspPhoneExtension,
        firstName,
        lastName,
        suffix,
        socialSecurityNumber,
        dateOfBirth,
        sspCaseNumber,
        sspPhoneNumber,
        sspCounty,
        sspPlaceholderPhoneNumber,
        sspZipCode,
        sspState,
        sspCity,
        sspCancel,
        sspName,
        sspReportFraudHowCanOIGContactOptions,
        sspReportFraudStateAlternateText,
        sspReportFraudEmployerAddressLineOne,
        sspReportFraudEmployerAddressLineTwo,
        sspNextSteps,
        sspConfirmationNumber,
        sspSubmittedToast,
        sspAnonymouslyText,
        sspOIGReachOutText,
        sspReturnToKentuckyHome,
        sspReturnToKentuckyHomeAlternate,
        toastErrorText
    };
    extMaxLength = 4;
    primaryPhoneNumberMaxLength = 12;
    ssnInputType = sspConstants.inputTypes.password;

    /**
     * @function : MetadataList
     * @description	: To get MetadataList.
     */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        if (!utility.isUndefinedOrNull(value)) {
            this.metaDataListParent = value;
            this.isMetaDataLoaded = true;
            this.addressMetadata = {
                "MailingAddressLine2__c,SSP_Member__c" : value["MailingAddressLine2__c,SSP_Member__c"],
                "PhysicalAddressLine2__c,SSP_Member__c" : value["PhysicalAddressLine2__c,SSP_Member__c"]
            }
        }
    }

    /**
     * @function : allowSave
     * @description	: To get allowSave.
     */
    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
        }
    }

    /**
     * @function : objWrap
     * @description	: To get objWrap.
     */
    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        try {
            if (value) {
                this.objValue = JSON.parse(value);
            }
        } catch (error) {
            console.error("error in objWrap", error);
        }
    }

    @wire(getObjectInfo, { objectApiName: MEMBER_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: GENDER_CODE
    })
    GenderCodeValues ({ data, error }) {
        if (data) {
            this.genderOptions = data.values.filter(item => item.value !== "U");
        }
        if (error) {
            console.error(`Error occurred while fetching picklist ${error}`);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: SUFFIX_CODE
    })
    SuffixCodeValues ({ data, error }) {
        if (data) {
            this.suffixCodes = data.values;
        }
        if (error) {
            console.error(`Error occurred while fetching picklist ${error}`);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: STATE_FIELD
    })
    fetchStatePicklistValues ({ error, data }) {
        if (data) {
            this.statePicklist = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    /**
     * @function : getPicklistFormattedValue
     * @description	: To get getPicklistFormattedValue.
     */
    getPicklistFormattedValue = () => {
        try {
            const listData = JSON.parse(JSON.stringify(fraudType));
            const howCanOIGContactOptions = JSON.parse(
                JSON.stringify(sspReportFraudHowCanOIGContactOptions)
            );
            const optionList = [];
            const optionsOIGList = [];
            const splitData = listData.split(";");
            const splitOIGData = howCanOIGContactOptions.split(";");
            for (let i = 0; i <= splitData.length; i++) {
                if (splitData[i] !== undefined) {
                    const objectData = {};
                    objectData.label = splitData[i].split(":")[1];
                    objectData.value = splitData[i].split(":")[0];
                    optionList.push(objectData);
                }
            }
            this.optionsList = optionList;
            // For OIG options
            for (let i = 0; i <= splitOIGData.length; i++) {
                if (splitOIGData[i] !== undefined) {
                    const objectData = {};
                    objectData.label = splitOIGData[i].split(":")[1];
                    objectData.value = splitOIGData[i].split(":")[0];
                    optionsOIGList.push(objectData);
                }
            }
            this.howCanOIGOptions = optionsOIGList;
        } catch (error) {
            console.error(
                "Error in getting picklist in formatted value =>",
                error
            );
        }
    };

    /**
     * @function : connectedCallback
     * @description	: The method is executed on load.
     */
    connectedCallback () {
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "GenderCode__c,SSP_Member__c",
                "SSN__c,SSP_Member__c",
                "BirthDate__c,SSP_Member__c",
                "FirstName__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Member__c",
                "PrimaryPhoneExtension__c,SSP_Member__c",
                "PhysicalZipCode5__c,SSP_Member__c",
                "Email__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Asset__c",
                "MailingAddressLine1__c,SSP_Member__c" ,
                "MailingAddressLine2__c,SSP_Member__c" ,
                "MailingCity__c,SSP_Member__c",
                "MailingStateCode__c,SSP_Member__c",
                "FederalCaseNumber__c,SSP_Member__c",
                "PhysicalAddressLine1__c,SSP_Member__c" ,
                "PhysicalAddressLine2__c,SSP_Member__c" ,
                "PhysicalCity__c,SSP_Member__c",
                "PhysicalStateCode__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_Request_Fraud"
            );
            getUserContactInfo().then(this.handleUserContactInfo);
            const url = new URL(window.location.href);
            this.originPage = url.searchParams.get("pageOrigin");
            if (window.addEventListener) {
                window.addEventListener(
                    "message",
                    this.handleCallback.bind(this)
                );
            } else {
                window.attachEvent("onmessage", this.listenMessage);
            }

            this.getPicklistFormattedValue();
            this.showSpinner = false;
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }

    /**
     * @function : handleCallback
     * @description : This method is called on captcha status change.
     * @param {*} evt - Js event.
     */
    handleCallback = evt => {
        try {
            const frameReference = this.template.querySelector(
                ".ssp-getBenefitCaptcha"
            );
            if (evt.data === sspConstants.shortSNAPFlowConstants.Unlock) {
                this.captchaVerified = true;
                this.enableSubmitButton();
                frameReference.style.zIndex = 0;
            } else if (
                evt.data === sspConstants.shortSNAPFlowConstants.Expired
            ) {
                this.captchaVerified = false;
                frameReference.style.zIndex = 9;
            } else if (
                evt.data === sspConstants.shortSNAPFlowConstants.Loaded
            ) {
                //Nothing to handle
            }
            this.enableSubmitButton();
        } catch (error) {
            console.error("Error in handleCallback:", error);
        }
    };

    /**
     * @function : showSelectiveFields
     * @description : This method gets the selected picklist value.
     * @param {*} event - Js event.
     */
    showSelectiveFields = event => {
        try {
            this.fraudRecord.WhoCommittedFraud = event.target.value;
            this.updateLabel(event.detail);
            if (event.detail === "IN") {
                this.showIndividualFields = true;
                this.showBothFields = true;
                this.showBusinessFields = false;
                this.showFields = true;
            } else if (event.detail === "BO") {
                this.showBothFields = true;
                this.showIndividualFields = true;
                this.showBusinessFields = false;
                this.showFields = true;
            } else if (event.detail === "BU") {
                this.showBusinessFields = true;
                this.showIndividualFields = false;
                this.showBothFields = false;
                this.showFields = true;
            } else if (event.detail === "") {
                this.showBusinessFields = false;
                this.showIndividualFields = false;
                this.showBothFields = false;
                this.showFields = false;
            }
        } catch (error) {
            console.error("Error in showSelectiveFields =>", error);
        }
    };

    /**
     * @function : resetFields
     * @description : This method resets all fields.
     */
    resetFields = () => {
        try {
            this.fraudRecord = {
                WhatHappened: "",
                IndividualFraudFirstName: "",
                IndividualFraudMiddleName: "",
                IndividualFraudLastName: "",
                IndividualFraudSSN: "",
                IndividualFraudDOB: "",
                BusinessFraudName: "",
                FraudAddressLine1: "",
                FraudAddressLine2: "",
                FraudCity: "",
                FraudState: "",
                FraudZipCode: "",
                FraudCounty: "",
                FraudPhoneNumber: "",
                FraudExt: "",
                FraudCaseNumber: "",
                IndividualFraudEmployerName: "",
                IndividualFraudEmployerAddressLine1: "",
                IndividualFraudEmployerAddressLine2: "",
                IndividualFraudEmployerCity: "",
                IndividualFraudEmployerState: "",
                IndividualFraudEmployerZipCode: "",
                IndividualFraudEmployerCounty: "",
                CanOIGContactYou: "",
                HowOIGContactYou: [],
                UserEmail: "",
                UserAddressLine1: "",
                UserAddressLine2: "",
                UserCity: "",
                UserStateCode: "",
                UserCounty: "",
                UserZipCode: "",
                UserPhoneNumber: "",
                UserExt: ""
            };
        } catch (error) {
            console.error("Error in resetting fields =>", error);
        }
    };

    /**
     * @function : updateLabel
     * @description : This method gets the selected picklist value.
     * @param {*} value - Selected member information.
     */
    updateLabel = value => {
        try {
            for (const picklist of this.optionsList) {
                if (value === picklist.value) {
                    this.selectedFraud = picklist.label + ".";
                }
            }
        } catch (error) {
            console.error("Error in updateLabel =>", error);
        }
    };

    /**
     * @function : handleInputFields
     * @description : This method gets the updated value of the fields.
     * @param {*} event - Js event.
     */
    handleInputFields = event => {
        try {
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.whatHappened
            ) {
                this.fraudRecord.WhatHappened = event.target.value;
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.individualFraudFirstName
            ) {
                this.fraudRecord.IndividualFraudFirstName = event.target.value;
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.individualFraudLastName
            ) {
                this.fraudRecord.IndividualFraudLastName = event.target.value;
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.individualFraudGender
            ) {
                this.fraudRecord.IndividualFraudGender = event.detail;
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.businessFraudName
            ) {
                this.fraudRecord.BusinessFraudName = event.target.value;
            }

            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.canOIGContactYou
            ) {
                this.fraudRecord.CanOIGContactYou = event.target.value;
                if (
                    this.fraudRecord.CanOIGContactYou ===
                    sspConstants.toggleFieldValue.yes
                ) {
                    this.ifOIGCanContact = true;
                } else {
                    this.ifOIGCanContact = false;
                }
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.howOIGContactYou
            ) {
                this.fraudRecord.HowOIGContactYou = event.target.value;
                this.isYourEmail = this.fraudRecord.HowOIGContactYou.includes(
                    "EM"
                );
                this.isYourMail = this.fraudRecord.HowOIGContactYou.includes(
                    "PM"
                );
                this.isYourPhone = this.fraudRecord.HowOIGContactYou.includes(
                    "PH"
                );
                this.enableSubmitButton();
            }

            if (
                event.target.dataset.id === sspConstants.reportFraud.userEmail
            ) {
                this.fraudRecord.UserEmail = event.target.value;
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.userAddressLine1
            ) {
                if (this.isYourMail) {
                    const userAddressInput = this.template.querySelector(
                        ".ssp-userAddress"
                    );
                    const userAddress = userAddressInput.value;
                    if (
                        userAddress !== null &&
                        userAddress !== undefined &&
                        (userAddress.city !== null ||
                            userAddress.county !== null ||
                            userAddress.state !== null ||
                            userAddress.addressLine1 !== null)
                    ) {
                       this.userAddressAvailable = true;
                    }

                    //user address
                    this.fraudRecord.UserAddressLine1 =
                        userAddress.addressLine1 || null;
                    this.fraudRecord.UserAddressLine2 =
                        userAddress.addressLine2 || null;
                    this.fraudRecord.UserCity = userAddress.city || null;
                    this.fraudRecord.UserCounty = userAddress.county || null;
                    this.fraudRecord.UserStateCode = userAddress.state || null;
                    this.fraudRecord.UserZipCode =
                        userAddress.postalCode || null;
                }
            }
            if (
                event.target.dataset.id ===
                sspConstants.reportFraud.userPhoneNumber
            ) {
                this.fraudRecord.UserPhoneNumber = event.target.value;
            }
            if (event.target.dataset.id === sspConstants.reportFraud.userExt) {
                this.fraudRecord.UserExt = event.target.value;
            }
            this.enableSubmitButton();
        } catch (error) {
            console.error("Error in handleInputTextFields =>", error);
        }
    };

    /**
     * @function :
     * @description : This method gets the updated address fields.
     */
    updateAddress = () => {
        try {
            let fraudAddressInput;
            if (this.showBothFields === true) {
                fraudAddressInput = this.template.querySelector(
                    ".ssp-fraudAddress"
                );
            } else if (this.showBusinessFields === true) {
                fraudAddressInput = this.template.querySelector(
                    ".ssp-businessAddress"
                );
            }

            //individual address
            if (
                fraudAddressInput !== undefined &&
                fraudAddressInput !== null &&
                fraudAddressInput.value !== undefined &&
                fraudAddressInput !== null &&
                this.objWrap !== undefined
            ) {
                const fraudAddress = fraudAddressInput.value;
                this.objWrap.FraudAddressLine1 =
                    fraudAddress.addressLine1 || null;
                this.objWrap.FraudAddressLine2 =
                    fraudAddress.addressLine2 || null;
                this.objWrap.FraudCity = fraudAddress.city || null;
                this.objWrap.FraudCounty = fraudAddress.county || null;
                this.objWrap.FraudState = fraudAddress.state || null;
                this.objWrap.FraudZipCode = fraudAddress.postalCode || null;
            }

            //employer address
            const employerAddressInput = this.template.querySelector(
                ".ssp-employerAddress"
            );

            if (
                employerAddressInput !== undefined &&
                employerAddressInput !== null &&
                employerAddressInput.value !== undefined &&
                employerAddressInput !== null &&
                this.objWrap !== undefined
            ) {
                const employerAddress = employerAddressInput.value;
                this.objWrap.IndividualFraudEmployerAddressLine1 =
                    employerAddress.addressLine1 || null;
                this.objWrap.IndividualFraudEmployerAddressLine2 =
                    employerAddress.addressLine2 || null;
                this.objWrap.IndividualFraudEmployerCity =
                    employerAddress.city || null;
                this.objWrap.IndividualFraudEmployerCounty =
                    employerAddress.county || null;
                this.objWrap.IndividualFraudEmployerState =
                    employerAddress.state || null;
                this.objWrap.IndividualFraudEmployerZipCode =
                    employerAddress.postalCode || null;
            }

            // user address
            const userAddressData = this.template.querySelector(
                ".ssp-userAddress"
            );

            if (
                userAddressData !== undefined &&
                userAddressData !== null &&
                userAddressData.value !== undefined &&
                userAddressData !== null
            ) {
                if (
                    userAddressData !== null &&
                    userAddressData !== undefined &&
                    (userAddressData.city !== null ||
                        userAddressData.county !== null ||
                        userAddressData.state !== null ||
                        userAddressData.addressLine1 !== null)
                ) {
                    this.userAddressAvailable = true;
                }
                const userAddress = userAddressData.value;
                if (this.objWrap !== undefined) {
                    this.objWrap.UserAddressLine1 =
                        userAddress.addressLine1 || null;
                    this.objWrap.UserAddressLine2 =
                        userAddress.addressLine2 || null;
                    this.objWrap.UserCity = userAddress.city || null;
                    this.objWrap.UserCounty = userAddress.county || null;
                    this.objWrap.UserStateCode = userAddress.state || null;
                    this.objWrap.UserZipCode = userAddress.postalCode || null;
                } else if (this.fraudRecord !== undefined) {
                    this.fraudRecord.UserAddressLine1 =
                        userAddress.addressLine1 || null;
                    this.fraudRecord.UserAddressLine2 =
                        userAddress.addressLine2 || null;
                    this.fraudRecord.UserCity = userAddress.city || null;
                    this.fraudRecord.UserCounty = userAddress.county || null;
                    this.fraudRecord.UserStateCode = userAddress.state || null;
                    this.fraudRecord.UserZipCode =
                        userAddress.postalCode || null;
                }
            }
        } catch (error) {
            console.error("Error in updating Address in obj wrapper =>", error);
        }
    };

    /**
     * @function handleUserContactInfo
     * @description Sets properties based on the data received.
     * @param {object} response - Object having email, address and preferred notification method.
     */
    handleUserContactInfo = (response) => {
        try {
            if(response.bIsSuccess === false || !response.mapResponse) {
                console.error("myInfo", JSON.parse(JSON.stringify(response)));
                throw response;
            }
            if(response.mapResponse.memberRecord) {
                const valueMap = Object.assign({}, response.mapResponse.stateMap, response.mapResponse.countyMap);
                const memberDetail = response.mapResponse.memberRecord;
                this.userEmail = memberDetail.Email__c;
                this.userPhone = memberDetail.PrimaryPhoneNumber__c;
                this.userPhoneExt = memberDetail.PrimaryPhoneExtension__c;
                this.fraudRecord.UserEmail = memberDetail.Email__c;
                this.fraudRecord.UserPhoneNumber = memberDetail.PrimaryPhoneNumber__c;
                this.fraudRecord.UserExt = memberDetail.PrimaryPhoneExtension__c;
                this.fraudRecord.UserAddressLine1 = memberDetail.MailingAddressLine1__c;
                this.fraudRecord.UserAddressLine2 = memberDetail.MailingAddressLine2__c;
                this.fraudRecord.UserCity = memberDetail.MailingCity__c;
                this.fraudRecord.UserStateCode = valueMap[memberDetail.MailingStateCode__c] || memberDetail.MailingStateCode__c;
                this.fraudRecord.UserCountyCode = valueMap[memberDetail.MailingCountyCode__c] || memberDetail.MailingCountyCode__c;
                this.fraudRecord.UserZipCode = memberDetail.MailingZipCode5__c;
                this.addressRecord = {
                    fields: Object.keys(memberDetail).reduce((map, key) => Object.assign(map, {
                        [key]: {
                            value: valueMap[memberDetail[key]] || memberDetail[key],
                            displayValue: memberDetail[key]
                        }
                    }), {})
                };
            }
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleMyInfoResponse", error);
        }
    }

    /**
     * @function : enableSubmitButton
     * @description : This method handles Submit button enable-disable logic.
     */
    enableSubmitButton = () => {
        try {
            this.updateAddress();
            let count = 0;
            if (this.showBothFields === true) {
                if (
                    this.fraudRecord.WhatHappened != null &&
                    this.fraudRecord.IndividualFraudFirstName != null &&
                    this.fraudRecord.IndividualFraudLastName !== null &&
                    this.fraudRecord.IndividualFraudGender != null &&
                    this.fraudRecord.CanOIGContactYou !== null &&
                    this.fraudRecord.WhatHappened !== "" &&
                    this.fraudRecord.IndividualFraudFirstName !== "" &&
                    this.fraudRecord.IndividualFraudLastName !== "" &&
                    this.fraudRecord.IndividualFraudGender !== "" &&
                    this.fraudRecord.CanOIGContactYou !== ""
                ) {
                    count = count + 1;
                }
            }
            if (this.showBusinessFields === true) {
                if (
                    this.fraudRecord.WhatHappened != null &&
                    this.fraudRecord.BusinessFraudName != null &&
                    this.fraudRecord.CanOIGContactYou !== null &&
                    this.fraudRecord.WhatHappened != "" &&
                    this.fraudRecord.BusinessFraudName != "" &&
                    this.fraudRecord.CanOIGContactYou !== ""
                ) {
                    count = count + 1;
                }
            }

            if (
                this.fraudRecord.CanOIGContactYou ===
                sspConstants.toggleFieldValue.yes
            ) {
                if (this.isYourEmail === true) {
                    if (
                        this.fraudRecord.UserEmail !== null &&
                        this.fraudRecord.UserEmail !== ""
                    ) {
                        count = count + 1;
                    }
                }

                if (this.isYourMail === true) {
                    if (
                        this.userAddressAvailable
                        /*  this.fraudRecord.UserAddressLine1 !== null &&
                        this.fraudRecord.UserAddressLine1 !== ""*/
                    ) {
                        count = count + 1;
                    }
                }
                if (this.isYourPhone === true) {
                    if (
                        this.fraudRecord.UserPhoneNumber !== null &&
                        this.fraudRecord.UserPhoneNumber !== ""
                    ) {
                        count = count + 1;
                    }
                }
            } else if (
                this.fraudRecord.CanOIGContactYou ===
                sspConstants.toggleFieldValue.no
            ) {
                count = count + 1;
            }

            //enable fields
            if (
                this.fraudRecord.CanOIGContactYou ===
                    sspConstants.toggleFieldValue.no &&
                count === 2
            ) {
                this.requiredFilled = true;
            } else if (
                this.fraudRecord.CanOIGContactYou ===
                sspConstants.toggleFieldValue.yes
            ) {
                if (
                    count === 1 &&
                    this.fraudRecord.HowOIGContactYou.length === 0
                ) {
                    this.requiredFilled = false;
                } else if (count > this.fraudRecord.HowOIGContactYou.length) {
                    this.requiredFilled = true;
                }
            } else {
                this.requiredFilled = false;
            }
            if (this.requiredFilled && this.captchaVerified) {
                this.isDisabledSubmitButton = false;
            } else {
                this.isDisabledSubmitButton = true;
            }
        } catch (error) {
            console.error("Error in enable Submit =>", error);
        }
    };

    /**
     * @function : handleSubmitFraud
     * @description : This method handles submit fraud report button.
     */
    handleSubmitFraud = () => {
        this.showSpinner = true;
        try {
            this.allowSaveValue = true;
            if (
                this.fraudRecord.HowOIGContactYou !== "" &&
                this.fraudRecord.HowOIGContactYou !== null
            ) {
                if (this.fraudRecord.HowOIGContactYou.length !== 0) {
                    this.canOIGContact = true;
                }
            } else {
                this.canOIGContact = false;
                this.fraudRecord.HowOIGContactYou = null;
            }

            const elem = this.template.querySelectorAll(".applicationInputs");
            this.checkValidations(elem);
            const addressElements = this.template.querySelectorAll("c-ssp-address-auto-complete");
            const hasError = Array.from(addressElements).reduce((errors, addressElement) => {
                const haveSomeValues = Object.values(addressElement.value).filter(item => !!item).length > 0;
                const errorList = addressElement.ErrorMessages();
                if(errorList.length === 0 && haveSomeValues) {
                    const originalMetadata = addressElement.metaList;
                    addressElement.metaList = this.metaDataListParent;
                    const errorList2 = addressElement.ErrorMessages();
                    addressElement.metaList = originalMetadata;
                    return errors.concat(errorList2);
                }
                return errors.concat(errorList);
            }, []).length > 0;

            const validateDOB = this.template.querySelector(
                ".ssp-reportFraudDOB"
            );
            
            if ((validateDOB && validateDOB.ErrorMessageList && validateDOB.ErrorMessageList.length > 0) || hasError) {
                this.allowSaveValue = false;
            }

            if (this.allowSaveValue ) {
                this.objWrap.FraudReportDate = this.todayDate;
                this.updateAddress();

                Object.keys(this.objWrap).forEach(key => {
                    if (this.objWrap[key] === null) {
                        delete this.objWrap[key];
                    }
                });

                submitFraudReport({
                    jsonData: JSON.stringify(this.objWrap),
                    contactData: this.canOIGContact
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                            this.fraudId = result.fraudID;
                            this.showSpinner = false;
                            this.ExceptionId = result.ExceptionId;
                            if (
                                this.fraudId !== "0"
                            ) {
                                this.toastCondition = "positive";
                                this.toastText = this.label.sspSubmittedToast;
                                this.showToast = true;
                                this.isNextSteps = true;
                            } else {
                                this.showErrorModal = true;
                                this.errorMsg = this.ExceptionId;
                                this.showSpinner = false;
                            }
                        } else {
                            this.showSpinner = false;
                            this.errorMsg = result.error;
                            this.showErrorModal = true;
                        }
                    })
                    .catch(error => {
                        console.error("Error in handleSave", error);
                    });
            } else {
                this.showSpinner = false;
                this.showErrorToast = true;
            }
        } catch (error) {
            console.error("Error in handleSubmitHearing", error);
        }
    };

    /**
     * @function : handleCancel
     * @description : This method is used to go back to previous screen.
     */
    handleCancel = () => {
        try {
            this.showSpinner = true;
            let cancelURL = "";
            if (this.originPage !== null) {
                cancelURL =
                    window.location.origin +
                    sspConstants.url.home +
                    this.originPage;
            } else {
                cancelURL = window.location.origin + sspConstants.url.home;
            }
            
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: cancelURL
                }
            });
        } catch (error) {
            console.error("Error in handleCancel =>", error);
        }
    };

    /**
     * @function : handleReturnHome
     * @description : This method is used to go back to previous screen.
     */
    handleReturnHome = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.navigationUrl.dashBoard
                }
            });
        } catch (error) {
            console.error("Error in handleReturnHome=>", error);
        }
    };

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.showToast = false;
        } catch (error) {
            console.error(
                "Error in hideToast of SspDocumentFileUpload" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast () {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    }

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : restrictNonNumeric
     * @description : This method is used to non numeric values.
     * @param {*} event - Gives the typed data.
     */
    restrictNonNumeric (event) { 
        try {
            // let charCode = (event.which) ? event.which : event.keyCode;
            // if (charCode > 31 && ( charCode < 48 || charCode > 57)) {
            //     event.preventDefault();
            // }
            const charCode = String.fromCharCode(event.which);
            if (!(/[0-9]/.test(charCode))) {
                event.preventDefault();
            }
            
        } catch (error) {
            console.error("Error in restrictNonNumeric: ", error);
        }
    } 
}