/**
 * Component Name: sspSnapSignaturePage.
 * Author: Chirag , Shivam.
 * Description: Page for signature in short snap.
 * Date: 4/23/2020.
 */
import { track, api, wire } from "lwc";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspTermsOfAgreement from "@salesforce/label/c.SSP_SignaturePageTermsOfAgreement";
import sspTermOne from "@salesforce/label/c.SSP_SignaturePageTermOne";
import sspTermTwo from "@salesforce/label/c.SSP_SignaturePageTermTwo";
import sspTermThree from "@salesforce/label/c.SSP_SignaturePageTermThree";
import sspSignaturePageHeader from "@salesforce/label/c.SSP_SignaturePageHeader";
import sspReadAgreeTermsAgreement from "@salesforce/label/c.SSP_ReadAgreeTermsAgreement";
import sspClickReadAgreeTermsAgreement from "@salesforce/label/c.SSP_ClickReadAgreeTermsAgreement";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspExitShortSNAPApplication from "@salesforce/label/c.SSP_ExitShortSNAPApplication";
import sspSubmitShortSnapLabel from "@salesforce/label/c.SSP_SubmitShortSnapLabel";
import sspClickSubmitShortSNAPApplication from "@salesforce/label/c.SSP_ClickSubmitShortSNAPApplication";
import sspHaveAnswered from "@salesforce/label/c.SSP_SignaturePageHaveAnswered";
import sspIfAnyChanges from "@salesforce/label/c.SSP_SignaturePageIfAnyChanges";
import sspProvidingFalse from "@salesforce/label/c.SSP_SignaturePageProvidingFalse";
import sspPleaseReadAnd from "@salesforce/label/c.SSP_SignaturePagePleaseReadAnd";
import sspStatementOfUnderstanding from "@salesforce/label/c.SSP_SignaturePageStatementOfUnderstanding";
import sspMedicalPenaltyWarning from "@salesforce/label/c.SSP_SignaturePageMedicalPenaltyWarning";
import sspRightsAndResponsibilities from "@salesforce/label/c.SSP_SignaturePageRightsAndResponsibilities";
import sspResourceTransferConsent from "@salesforce/label/c.SSP_SignaturePageResourceTransferConsent";
import sspDeclarationOfAnnuities from "@salesforce/label/c.SSP_SignaturePageDeclarationOfAnnuities";
import sspReadAndAgreeConsent from "@salesforce/label/c.SSP_SignaturePageKihippConsent";
import sspDoYouAuthorize from "@salesforce/label/c.SSP_SignaturePageDoYouAuthorize";
import sspDoesThePrimary from "@salesforce/label/c.SSP_SignaturePageDoesThePrimary";
import sspByEnteringYour from "@salesforce/label/c.SSP_SignaturePageByEnteringYour";
import sspFirstNameLabel from "@salesforce/label/c.SSP_SignaturePageFirstName";
import sspMiddleInitialLabel from "@salesforce/label/c.SSP_SignaturePageMiddleInitial";
import sspDoesNotMiddleInitialLabel from "@salesforce/label/c.SSP_SignaturePageDoesNotMiddleInitial";
import sspLastNameLabel from "@salesforce/label/c.SSP_SignaturePageLastName";
import sspSuffixLabel from "@salesforce/label/c.SSP_SignaturePageSuffixLabel";
import sspDateLabel from "@salesforce/label/c.SSP_SignaturePageDateLabel";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspReadPolicyValidatorErrorText from "@salesforce/label/c.SSP_ReadPolicyValidatorErrorText";
import sspShortSNAPApplication from "@salesforce/label/c.SSP_ShortSNAPApplication";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspThePrimaryHelpText from "@salesforce/label/c.SSP_SignaturePageDoesThePrimaryHelpText";
import submitApplication from "@salesforce/apex/SSP_SubmitShortSNAPApplication.submitApplication";
import explicitText from "@salesforce/label/c.SSP_ExplicitText";
import outsideDCBSMsg from "@salesforce/label/c.SSP_OutsideDCBSMsg";
import { url } from "c/sspConstants";
import constants from "c/sspConstants";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspUtility from "c/sspUtility";
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from "lightning/flowSupport";

import SUFFIX from "@salesforce/schema/SSP_Application__c.ShortSnapSuffixCode__c";

import fetchTimeTravelDate from "@salesforce/apex/SSP_Utility.today";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import SSPAPPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import ApplicationESignMiddleInitial from "@salesforce/schema/SSP_Application__c.ApplicationEsignMiddleInitial__c";
import ApplicationESignLastName from "@salesforce/schema/SSP_Application__c.ApplicationEsignLastName__c";
import ApplicationESignFirstName from "@salesforce/schema/SSP_Application__c.ApplicationEsignFirstName__c";
import ApplicationESignSuffixCode from "@salesforce/schema/SSP_Application__c.ApplicationEsignSuffixCode__c";

import sspReadPolicyValidator from "@salesforce/label/c.SSP_ReadPolicyValidatorErrorText";
import sspRequiredValidator from "@salesforce/label/c.SSP_RequiredErrorMessage";

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
import fetchTiming from "@salesforce/apex/SSP_SignaturePageService.fetchTiming";

import { NavigationMixin } from "lightning/navigation";

export default class SspSnapSignaturePage extends NavigationMixin(sspUtility) {
    @api applicationObject;
    @api applicationString;
    @api applicationNumber;

    @track sspTermsAgreement = false;
    @track isTermsAgreementProgressComplete = false;
    @track isTermsAgreementProgressStarted = false;
    @track spinnerOn = false;
    @track showErrorModal = false;
    @track errorMsg;

    @track signPageInfo = {};
    @track isDisableMIField = false;
    @track exceptionCode;
    @track timeTravelCurrentDate;
    @track resourceRecordTypeId;
    @track applicationRecordTypeId;
    @track suffixOptions;
    @track ErrorMessageList = [];
    @track metaDataListParent = {};
    @track objApplication = {};
    @track trueValue = true;
    @track hasSaveValidationError = false;
    @track timeFlag;
    @track middleNameMaxLength =
        constants.validationEntities.sspMiddleInitialMaxLength;

    @track label = {
        sspTermsOfAgreement,
        sspTermOne,
        sspTermTwo,
        sspTermThree,
        sspSignaturePageHeader,
        sspHaveAnswered,
        sspIfAnyChanges,
        sspProvidingFalse,
        sspPleaseReadAnd,
        sspStatementOfUnderstanding,
        sspMedicalPenaltyWarning,
        sspRightsAndResponsibilities,
        sspResourceTransferConsent,
        sspDeclarationOfAnnuities,
        sspReadAndAgreeConsent,
        sspDoYouAuthorize,
        sspDoesThePrimary,
        sspByEnteringYour,
        sspFirstNameLabel,
        sspMiddleInitialLabel,
        sspDoesNotMiddleInitialLabel,
        sspLastNameLabel,
        sspSuffixLabel,
        sspDateLabel,
        sspRequiredErrorMessage,
        sspReadPolicyValidatorErrorText,
        toastErrorText,
        sspThePrimaryHelpText,
        sspSubmitShortSnapLabel,
        sspReadAgreeTermsAgreement,
        sspClickReadAgreeTermsAgreement,
        sspBack,
        sspBackAltText,
        sspExitButton,
        sspExitShortSNAPApplication,
        sspClickSubmitShortSNAPApplication,
        sspReadPolicyValidator,
        sspRequiredValidator,
        sspShortSNAPApplication,
        explicitText,
        outsideDCBSMsg

    };

    appFieldList = [
        ApplicationESignMiddleInitial,
        ApplicationESignLastName,
        ApplicationESignFirstName,
        ApplicationESignSuffixCode
    ];

    backgroundImg = sspIcons + url.mobileBackgroundImage;
    desktopBackgroundImg = sspIcons + url.desktopBackgroundImage;

    customLabel = {
        sspYes,
        sspNo
    };

    /**
     * @function - fetchTimeTravelDate.
     * @description - This method is used to get INDIVIDUAL Current Date data.
     *
     */
    @wire(fetchTimeTravelDate)
    wiredDate ({ error, data }) {
        if (data) {
            this.timeTravelCurrentDate = data;
        } else if (error) {
            this.timeTravelCurrentDate = undefined;
            console.error("Error occurred in fetchTimeTravelDate: ", error);
        }
    }

    /**
     * @function - objectInfo.
     * @description - This method is used to get INDIVIDUAL record type for SSP Member.
     *
     */
    @wire(getObjectInfo, {
        objectApiName: SSPAPPLICATION_OBJECT
    })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const RecordTypesInfo =
                    constants.sspMemberConstants.RecordTypesInfo;
                const applicationRTName =
                    constants.shortSNAPFlowConstants.ShortSNAP_RTName;
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
                    "Error occurred while fetching record type" + error
                );
            }
        } catch (error) {
            console.error("Error occurred while fetching record type" + error);
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
            if (!sspUtility.isUndefinedOrNull(value)) {
                this.allowSaveValue = value;
            }
        } catch (error) {
            console.error("Error Occurred::: ", JSON.stringify(error.message));
        }
    }

    /**
     * @function - connectedCallback.
     * @description - This method gets called when the component is initialized.
     *
     */
    connectedCallback () {
        /*CR -Changes */
        fetchTiming()
        .then(result => {
            this.timeFlag = result;
            this.error = undefined;           
        })
        .catch(error => {
            this.error = error;
          
        });
        /*CR - Changes End here */
        try {
            if (this.applicationString) {
                this.objApplication = JSON.parse(this.applicationString);
            }
            this.spinnerOn = false;
            const fieldList = this.appFieldList.map(
                item => item.fieldApiName + "," + item.objectApiName
            );
            this.getMetadataDetails(
                fieldList,
                null,
                "SSP_APP_Details_SignaturePage"
            );
        } catch (error) {
            console.error(
                "Error Occurred in connectedCallback::: ",
                JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function - openLinkModal.
     * @description - This method is used to open the modal on link click.
     * @param {object} e - Event parameter.
     */
    openLinkModal = e => {
        try {
            if (
                e.keyCode === constants.learnMoreModal.enterKeyCode ||
                e.type === constants.learnMoreModal.clickLearn
            ) {
                const type = e.currentTarget.dataset.type;
                this.sspTermsAgreement = true;
                this[type] = true;
            }
        } catch (error) {
            console.error(
                "Error Occurred in openLinkModal::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - updateToggleFields.
     * @description - This method is called on close of the modal on link click.
     * @param {object} event - Event parameter.
     */
    updateToggleFields (event) {
        try {
            if (event.detail) {
                const eventValue = event.detail;
                if (eventValue === constants.toggleFieldValue.yes) {
                    this.isTermsAgreementProgressComplete = true;
                    this.isTermsAgreementProgressStarted = true;
                    this.ErrorMessageList = "";
                } else if (eventValue === constants.toggleFieldValue.no) {
                    this.isTermsAgreementProgressComplete = false;
                    this.isTermsAgreementProgressStarted = true;
                    this.ErrorMessageList = "";
                }
                this.sspTermsAgreement = false;
            }
        } catch (error) {
            console.error(
                "Error Occurred in updateToggleFields::: ",
                JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function - toggleMiCheckbox.
     * @description - This method is used to update MI field value.
     * @param {object} event - Event parameter.
     */
    toggleMiCheckbox = event => {
        try {
            if (event.target) {
                this.isDisableMIField = event.target.value;
                if (this.isDisableMIField === true) {
                    this.signPageInfo.middleName = null;
                    this.template
                        .querySelectorAll(".snapSign")
                        .forEach(element => {
                            if (
                                element.label ===
                                this.label.sspMiddleInitialLabel
                            ) {
                                element.ErrorMessageList = "";
                            }
                        });
                }
            }
        } catch (error) {
            console.error(
                "Error Occurred in toggleMiCheckbox::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleMIChange.
     * @description - This method is called on change of MI field.
     * @param {object} event - Event parameter.
     */
    handleMIChange = event => {
        try {
            if (event.target) {
                this.signPageInfo.middleName = event.target.value;
                event.target.ErrorMessageList = "";
            }
        } catch (error) {
            console.error(
                "Error Occurred in handleMIChange::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleFirstNameChange.
     * @description - This method is called on change of First Name field.
     * @param {object} event - Event parameter.
     */
    handleFirstNameChange = event => {
        try {
            if (event.target) {
                this.signPageInfo.firstName = event.target.value;
                event.target.ErrorMessageList = "";
            }
        } catch (error) {
            console.error(
                "Error Occurred in handleFirstNameChange::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleLastNameChange.
     * @description - This method is called on change of Lat Name field.
     * @param {object} event - Event parameter.
     */
    handleLastNameChange = event => {
        try {
            if (event.target) {
                this.signPageInfo.lastName = event.target.value;
                event.target.ErrorMessageList = "";
            }
        } catch (error) {
            console.error(
                "Error Occurred in handleLastNameChange::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleSuffixChange.
     * @description - This method is called on change of Suffix field.
     * @param {object} event - Event parameter.
     */
    handleSuffixChange = event => {
        try {
            if (event.target) {
                this.signPageInfo.suffix = event.target.value;
                event.target.ErrorMessageList = "";
            }
        } catch (error) {
            console.error(
                "Error Occurred in handleSuffixChange::: ",
                JSON.stringify(error.message)
            );
        }
    };


    /**
     * @function : copyPhysicalAddress.
     * @description	: Method to copy Physical address to Mailing address in case both are same.
     */
    copyPhysicalAddress = () => {
        if (this.objApplication && this.objApplication.hasOwnProperty(HAVE_MAILING_ADDRESS.fieldApiName) && this.objApplication.ShortSnapIsMailingAddress__c === constants.toggleFieldValue.no) {
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_LINE1.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_LINE1.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_LINE1.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_LINE2.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_LINE2.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_LINE2.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_CITY.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_CITY.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_CITY.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_COUNTY.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_COUNTY.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_COUNTY.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_STATE.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_STATE.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_STATE.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_COUNTRY.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_COUNTRY.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_COUNTRY.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_ZIP4.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_ZIP4.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_ZIP4.fieldApiName];
            }
            if (this.objApplication.hasOwnProperty(PHYSICAL_ADDRESS_ZIP5.fieldApiName)) {
                this.objApplication[MAILING_ADDRESS_ZIP5.fieldApiName] = this.objApplication[PHYSICAL_ADDRESS_ZIP5.fieldApiName];
            }
        }
    }

    /**
     * @function - initSave.
     * @description - This method is called on click of Continue button.
     *
     */
    initSave = () => {
        try {
            //This is used to check metadata validations
            const elem = this.template.querySelectorAll(".snapSignSubmit");

            //(Framework) Utility component method to handle validations.
            this.checkValidations(elem);

            //Copy Physical Address to Mailing if Mailing address is same as Physical address.
            this.copyPhysicalAddress();

            const messageTermsAgreement = this.label.sspReadPolicyValidator;
            const mess = this.label.sspRequiredValidator;
            if (!this.isTermsAgreementProgressStarted) {
                if (!this.ErrorMessageList.includes(messageTermsAgreement)) {
                    this.ErrorMessageList.push(messageTermsAgreement);
                    this.ErrorMessageList.push(mess);
                }
            }
            let allowNavigation = false;
            const allData = this.template.querySelectorAll(".snapSign");

            //allData.forEach(element => {
            for (const element of allData) {
                const enteredData = element.value;
                let dList = element.ErrorMessageList;
                if (
                    enteredData === undefined ||
                    enteredData === null ||
                    enteredData.trim().length === 0
                ) {
                    if (element.label === this.label.sspFirstNameLabel ||
                        element.label === this.label.sspLastNameLabel) 
                    {
                        allowNavigation = false;

                        if (!dList.includes(mess)) {
                            dList.push(mess);
                        }
                    }
                    //This block prevents navigation in case, Middle name or Suffix have any validations.
                    else if ( element.label === this.label.sspMiddleInitialLabel || element.label === this.label.sspSuffixLabel ) {
                        if (dList.length > 0) {
                            allowNavigation = false;
                            break;
                        }
                    }
                } else {
                    if (dList.length) {
                        allowNavigation = false;
                        this.hasSaveValidationError = true;
                        dList = dList.filter(message => message !== mess);
                        break;
                    } else {
                        allowNavigation = true;
                        this.hasSaveValidationError = false;
                    }
                }
                element.ErrorMessageList = dList;
            }

            //Navigate to next screen...
            if (allowNavigation && this.isTermsAgreementProgressStarted) {
                this.spinnerOn = true;
                //Apex method call to submit application.
                submitApplication({
                    application: JSON.stringify(this.objApplication)
                })
                    .then(response => {
                        if (response && response.mapResponse) {
                            if (response.mapResponse.bIsSuccess) {
                                this.applicationNumber =
                                    response.mapResponse.applicationNumber;
                            } else {
                                this.exceptionCode = response.mapResponse.errorName;
                                this.errorMsg = response.mapResponse.errorName;
                                this.showErrorModal = true;
                                this.spinnerOn = false;
                                allowNavigation = false;
                            }
                        }
                    })
                    .then(() => {
                        if (allowNavigation) {
                            const nextNavigationEvent = new FlowNavigationNextEvent();
                            this.dispatchEvent(nextNavigationEvent);
                            this.spinnerOn = false;
                        }
                    })
                    .catch(error => {
                        this.spinnerOn = false;
                        console.error(
                            "Error Occurred in initSave::: ",
                            JSON.stringify(error.message)
                        );
                    });
            } else {
                this.hasSaveValidationError = true;
                this.spinnerOn = false;
            }
        } catch (error) {
            console.error(
                "Error Occurred in initSave::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleBack.
     * @description - This method is called on click of Back button.
     *
     */
    handleBack = () => {
        try {
            this.spinnerOn = true;
            const backNavigationEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(backNavigationEvent);
        } catch (error) {
            console.error(
                "Error Occurred in handleBack::: ",
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleExit.
     * @description - This method is called on click of Exit button.
     *
     */
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
            console.error(
                "Error Occurred in handleExit::: ",
                JSON.stringify(error.message)
            );
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
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
            this.spinnerOn = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };
}