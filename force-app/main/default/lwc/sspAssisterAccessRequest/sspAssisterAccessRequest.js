// eslint-disable-next-line @lwc/lwc/no-async-operation
/**
 * Component Name: SspAssisterAccessRequest.
 * Author: Kyathi & Rahul.
 * Description: The component is used for Assister Access Request.
 * Date: 5/28/2020.
 */
import { track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspPleaseReviewContact from "@salesforce/label/c.SSP_PleaseReviewContact";

import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import sspAssisterAccessRequest from "@salesforce/label/c.SSP_AssisterAccessRequest";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspLearnMoreAltText from "@salesforce/label/c.SSP_AssisterLearnMoreAltText";
import sspDownloadAppendixForm from "@salesforce/label/c.SSP_DownloadAppendixForm";
import sspDownloadAppendixFormTitle from "@salesforce/label/c.SSP_DownloadAppendixTitle";
import sspNoAssisterRelationText from "@salesforce/label/c.SSP_NoAssisterRelationText";
import sspClickContentSendNotificationText from "@salesforce/label/c.SSP_ClickContentSendNotificationText";
import sspRequestElectronicConsent from "@salesforce/label/c.SSP_RequestElectronicConsent";
import sspRequestElectronicConsentTitle from "@salesforce/label/c.SSP_RequestElectronicConsentTitle";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspAssisterCancelTitle from "@salesforce/label/c.SSP_AssisterCancelTitle";
import sspNextButton from "@salesforce/label/c.SSP_NextButton";
import sspWaitingClientConsent from "@salesforce/label/c.SSP_WaitingClientConsent";
import sspClientConsentReceived from "@salesforce/label/c.SSP_ClientConsentReceived";
import sspContinueClientCaseText from "@salesforce/label/c.SSP_ContinueClientCaseText";
import sspClientDidNotConsent from "@salesforce/label/c.SSP_ClientDidNotConsent";
import sspNotGivenConsentAccess from "@salesforce/label/c.SSP_NotGivenConsentAccess";
import sspRequestConsentOneMoreTime from "@salesforce/label/c.SSP_RequestConsentOneMoreTime";
import sspRequestConsentAgain from "@salesforce/label/c.SSP_RequestConsentAgain";
import sspRequestConsentAgainTitle from "@salesforce/label/c.SSP_RequestConsentAgainTitle";

import sspClientDidNotRespond from "@salesforce/label/c.SSP_ClientDidNotRespond";
import sspConfirmVerbalConsent from "@salesforce/label/c.SSP_ConfirmVerbalConsent";
import sspConfirmVerbalConsentTitle from "@salesforce/label/c.SSP_ConfirmVerbalConsentTitle";
import sspAgreementItemsTitle from "@salesforce/label/c.SSP_AgreementItemsTitle";
import sspGoToNextScreenTitle from "@salesforce/label/c.SSP_GoToNextScreenTitle";
import sspVerbalConsent from "@salesforce/label/c.SSP_VerbalConsent";
import sspAgreeConsentToContinueApplication from "@salesforce/label/c.SSP_AgreeConsentToContinueApplication";
import sspAcknowledgeAssisterRoles from "@salesforce/label/c.SSP_AcknowledgeAssisterRoles";
import sspAuthorizations from "@salesforce/label/c.SSP_Authorizations";
import sspAdditionalImportantInformation from "@salesforce/label/c.SSP_AdditionalImportantInformation";
import sspClientWillReceiveConfirmation from "@salesforce/label/c.SSP_ClientWillReceiveConfirmation";
import sspAppendixBForm from "@salesforce/label/c.SSP_AppendixBForm";
import sspPollingInterval from "@salesforce/label/c.SSP_IsDataProcessedPollingInterval"; 
import sspImages from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspConstants from "c/sspConstants";
import sspUtility, { formatLabels } from "c/sspUtility";
import getAssisterTimeConfig from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.getAssisterTimeConfig";
import pollingNotificationData from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.pollingNotificationData";
import requestConsentApplication from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.requestConsentApplication";
import createACRNotification from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.createACRNotification";
import updateAccountContactRelation from "@salesforce/apex/SSP_AssisAuthRepConsentNotSignedService.updateAccountContactRelation";
import updateApplicationBlocked from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.updateApplicationBlocked";
import revertRequestAccess from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.revertRequestAccess";
import fetchTransactionStatus from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.isDataProcessed"; 
//user info
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import sspRepsAssistAgentsTitle from "@salesforce/label/c.SSP_Reps_Assisters_Agents_Title";
import sspAddAuthReps from "@salesforce/label/c.SSP_AuthRepAccessModalHeading";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspMiOptional from "@salesforce/label/c.SSP_MI";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspSuffix from "@salesforce/label/c.SSP_Suffix";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspSearchAuthRep from "@salesforce/label/c.SSP_SearchButtonText";
import sspSSN from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspGender from "@salesforce/label/c.SSP_Gender";
import sspDateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import sspSuffixTitle from "@salesforce/label/c.SSP_SuffixTitle";
import sspGenderTitle from "@salesforce/label/c.SSP_GenderTitle";
//import sspAddAuthRepsInfo1 from "@salesforce/label/c.SSP_AddAuthRepsInfo1";
import sspAddAuthRepsInfo2 from "@salesforce/label/c.SSP_AuthRepEnterDetails";
import sspSocialSecurityNumber9Digit from "@salesforce/label/c.SSP_SearchSocialSecurityNumber9Digit";
import sspSearchBasedOnTheEnteredCriteria from "@salesforce/label/c.SSP_SearchBasedOnTheEnteredCriteria";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
//import ACCOUNTCONTACT_OBJECT from "@salesforce/schema/AccountContactRelation";
import CONTACT_SUFFIX from "@salesforce/schema/Contact.SuffixCode__c";
import CONTACT_GENDER from "@salesforce/schema/Contact.GenderCode__c";
import ADDRESS_LINE1 from "@salesforce/schema/Contact.Street__c";
import ADDRESS_LINE2 from "@salesforce/schema/Contact.AddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/Contact.City__c";
import ADDRESS_COUNTY from "@salesforce/schema/Contact.CountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/Contact.SSP_State__c";
import ADDRESS_ZIP4 from "@salesforce/schema/Contact.Zipcode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/Contact.Zipcode5__c";
//import RELATIONSHIP_CODE from "@salesforce/schema/AccountContactRelation.RepresentativeRelationshipCode__c";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import sspAuthRepRelationship from "@salesforce/label/c.SSP_AuthRepRelationship";
import sspSearchApplicationNumber from "@salesforce/label/c.SSP_SearchApplicationNumber";
import sspSearchCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspClickHereToSeeOptionsForRelationships from "@salesforce/label/c.SSP_ClickHereToSeeOptionsForRelationships";
import sspIndicateAccessLevel from "@salesforce/label/c.SSP_IndicateAccessLevel";
import sspWhichProgramDoYouWant from "@salesforce/label/c.SSPWhichProgramDoYouWantThisAuthorizedRepresentativeToHaveAccessTo";
import sspContinueToNextScreenToEnterFurtherDetails from "@salesforce/label/c.SSP_ContinueToNextScreenToEnterFurtherDetails";
import sspReturnPreviousScreen from "@salesforce/label/c.SSP_ReturnPreviousScreen";
import sspCancelEnteringDetailsAuthorizedRepresentative from "@salesforce/label/c.SSP_CancelEnteringDetailsAuthorizedRepresentative";
import searchClientMCIService from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.searchClientMCIService";
//import loadAuthRepDetails from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.loadAuthRepDetails";
import sspIndividualHasAssister from "@salesforce/label/c.SSP_IndividualHasAssister";
import sspAssert from "@salesforce/resourceUrl/SSP_Assert";

const PA_FIELD_MAP = {
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspAddress,
        fieldApiName: sspConstants.contactFields.Street__c,
        objectApiName: sspConstants.sspObjectAPI.Contact
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspAddressLine2,
        fieldApiName: sspConstants.contactFields.AddressLine2__c,
        objectApiName: sspConstants.sspObjectAPI.Contact
    },
    city: {
        ...ADDRESS_CITY,
        label: sspConstants.addressLabels.City
    },
    county: {
        ...ADDRESS_COUNTY,
        label: sspConstants.addressLabels.County
    },
    state: {
        ...ADDRESS_STATE,
        label: sspConstants.addressLabels.State
    },
    zipCode4: {
        ...ADDRESS_ZIP4,
        label: sspConstants.addressLabels.Zip
    },
    zipCode5: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    }
};
//user info

export default class SspAssisterAccessRequest extends NavigationMixin(sspUtility) {
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
        }
    }
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
            }
        } catch (error) {
            console.error(
                "Error occured in MetadataList getter setter in sspAuthRepAccessRequest screen " +
                    JSON.stringify(error.message)
            );
        }
    }
    //user info
    @track fromHouseHoldSummary= false;
    @track showErrorModal = false;
    @track showSpinner = true;
    @track toastTrueValue = true;
    @track suffixOptions;
    @track genderOptions;
    @track representativeRelationshipCodes;
    @track fieldMap = PA_FIELD_MAP;
    @track programs;
    @track isAppNumberDisabled = false;
    @track isCaseNumberDisabled = false;
    @track metaDataListParent;
    @track recordTypeId;
    @track isFullMatch = false;
    @track isPartialMatch = false;
    @track disableNextButton = true;
    @api isNoMatch = false;
    @api isCaseInactive = false;
    @api isAccessPresent = false;
    @api isPendingRequest = false;
    @track assisterMatchFound = false;
    @track showErrorToast = false;
    @track isToShow = true;
    @track inputTypePassword;
    @track hideConsentAgainButton = false;
    @track numberOfTimesVisited = 0;
    @api FirstName;
    @track UserFullName;
    @track individualId;
    @track applicationId;
    @track caseNumber;
    @track applicationInitiated;
    @track caseInfoFlag = false;
    @track fullyConsentGiven = false;
    @track verbalConsentGiven = false;//added for 388765, to identify whether verbal consent is given by assister, In case client dint approve.
    @api requestAccessResponse;
    @api applicationNumber;
    @api caseNumber;
    selectedRadio = null;
    entered = false;
    //user info

    //@track showSpinner = false;
    @track requestClientAccess = true;
    @track openLearnMoreModel = false;
    @track reference = this;
    @track disableRequestButton = false;
    @track sspAuthorizationType = false;
    @track sspAdditionalInfo = false;
    @track sspAcknowledgeRoles = false;
    @track isAckStart = false;
    @track isActComplete = false;
    @track isAuthStart = false;
    @track isAuthComplete = false;
    @track isAdditionalInfoStart = false;
    @track isAdditionalInfoComplete = false;
    @track falseValue = false;
    @track trueValue = false;
    @track thirdValue = false;
    @track clientAgreed = false;
    @track clientDisagreed = false;
    @track showVerbalConsent = false;
    @track clientDidNotRespond = false;
    @track userName;
    @track RequestType;
    @track showSearchIndividual;
    @track permissionMedicare;
    @track permissionKHIP;
    @api caseNo;
    @track objUser = {};
    @track timerConfigValue;
    @track currentLoggedInUser;
    @track progress = 5000;
    @track assisterName;
    @track sspNoAssisterRelationTextLabel;
    @track selectedAcknowledgeRoles = false;
    @track selectedAdditionalInfoConsent = false;
    @track selectedAuthorizationConsent = false;
    @track notificationId;
    @track requestAccessJson;
    @track showNextStepScreen = false;
    @track noCaseMatchAssister = false;
    @track assisterRequestPartialMatch = false; //remove if not required
    @track noMatchOrCaseInactive = false;
    @track isPartialMatch = false;
    @track anotherAssisterPresent = false;
    @track setCaseIds;
    @track mapCaseInfo;
    @track mapAppInfo;
    @track ssnValidationErr;
    @track requestButtonClicked = false;
    @track rejectedTwice = false;
    @track clientNoResponse=false;
    @track medicaidOnlyApplication= false;
    @track medicaidOtherApplication=false;
    @track nonMedicaidApplication=false;
    @track modValue;
    @track onlyLangVariable = false;
    @track languageSpanish = false;
    consentFormAppendix = `${sspAssert}${sspConstants.url.consentFormAppendix}`;
    consentFormAppendixSpanish = `${sspAssert}${sspConstants.url.consentFormAppendixSpanish}`;
    variable1;
    variable2;
    label = {
        sspPleaseReviewContact,
        toastErrorText,
        sspAppendixBForm,
        sspGoToNextScreenTitle,
        sspAgreementItemsTitle,
        sspRequestElectronicConsentTitle,
        sspConfirmVerbalConsentTitle,
        sspDownloadAppendixFormTitle,
        sspAssisterCancelTitle,
        sspClientWillReceiveConfirmation,
        sspAcknowledgeAssisterRoles,
        sspAuthorizations,
        sspAdditionalImportantInformation,
        sspBenefitsApplication,
        sspAssisterAccessRequest,
        sspLearnMoreLink,
        sspLearnMoreAltText,
        sspDownloadAppendixForm,
        sspNoAssisterRelationText,
        sspClickContentSendNotificationText,
        sspRequestElectronicConsent,
        sspCancel,
        sspNextButton,
        sspWaitingClientConsent,
        sspClientConsentReceived,
        sspContinueClientCaseText,
        sspClientDidNotConsent,
        sspNotGivenConsentAccess,
        sspRequestConsentOneMoreTime,
        sspRequestConsentAgain,
        sspClientDidNotRespond,
        sspConfirmVerbalConsent,
        sspVerbalConsent,
        sspAgreeConsentToContinueApplication,
        sspRequestConsentAgainTitle,
        //user info
        sspReturnPreviousScreen,
        sspCancelEnteringDetailsAuthorizedRepresentative,
        sspContinueToNextScreenToEnterFurtherDetails,
        sspSearchApplicationNumber,
        sspSearchCaseNumber,
        sspBack,
        sspRequestAccess,
        sspAddress,
        sspAddressLine2,
        sspSuffixTitle,
        sspGenderTitle,
        sspRepsAssistAgentsTitle,
        sspAddAuthReps,
        //sspAddAuthRepsInfo1,
        sspAddAuthRepsInfo2,
        sspFirstName,
        sspMiOptional,
        sspLastName,
        sspSuffix,
        sspEmail,
        sspSearchAuthRep,
        sspSocialSecurityNumber9Digit,
        sspSSN,
        sspGender,
        sspDateOfBirth,
        sspSearchBasedOnTheEnteredCriteria,
        sspAuthRepRelationship,
        sspClickHereToSeeOptionsForRelationships,
        sspIndicateAccessLevel,
        sspWhichProgramDoYouWant,
        sspMiddleInitialMaxLength:
            sspConstants.validationEntities.sspMiddleInitialMaxLength,
        sspIndividualHasAssister
    };
    checkedIconUrl = sspImages + sspConstants.url.consentChecked;
    disagreeIconUrl = sspImages + sspConstants.url.consentDisagreed;
    ackItemTitle = formatLabels(sspAgreementItemsTitle, [
        this.label.sspAcknowledgeAssisterRoles
    ]);
    authItemTitle = formatLabels(sspAgreementItemsTitle, [
        this.label.sspAuthorizations
    ]);
    addInfoItemTitle = formatLabels(sspAgreementItemsTitle, [
        this.label.sspAdditionalImportantInformation
    ]);
      /**
     * @function : closeError
     * @description : Method used to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
        } catch (error) {
            console.error("failed in closeError" + JSON.stringify(error));
        }
    };
    connectedCallback () {
        this.showHelpContentData("SSP_APP_AssisterAccessRequest");
        if (location.href.includes("language=es_US")) {
            this.languageSpanish = true;
        } else {
            this.languageSpanish = false;
        }
        //If assister initiates an applicationId
        const sPageURL = decodeURIComponent(
            window.location.search.substring(1)
        );
        const sURLVariables = sPageURL.split("&");
        this.onlyLangVariable = sURLVariables.length === 1 && (sURLVariables[0].toLowerCase().indexOf("language") !== -1 || sURLVariables[0] === "");
        if(sURLVariables.includes("household=true")){
            this.fromHouseHoldSummary = true;
        }
        this.showSpinner = true;
        if (sURLVariables != null && sURLVariables != "") {
            for (let i = 0; i < sURLVariables.length; i++) {
                const sParam = sURLVariables[i].split("=");
                if (sParam[0] === "applicationId") {
                    this.applicationId =
                        sParam[1] === undefined ? "Not found" : sParam[1];
                    this.applicationInitiated = true;
                }
                if (sParam[0] === "individualId") {
                    this.individualId =
                        sParam[1] === undefined ? "Not found" : sParam[1];
                }                
                if (
                    !sspUtility.isUndefinedOrNull(this.applicationId) &&
                    !sspUtility.isUndefinedOrNull(this.individualId)
                ) {                    
                    //Defect 391232
                    if (this.fromHouseHoldSummary){
                        
                        this.fetchTransactionStatusFromServer({
                            applicationId: this.applicationId,
                            mode: "Intake"
                        }); 
                    }
                    else
                    {
                        requestConsentApplication({
                            individualId: this.individualId,
                            applicationId: this.applicationId
                        })
                            .then(result => {
                            this.applicationNumber =
                                result.mapResponse.applicationNumber;                                
                            const caseResponse =
                                result.mapResponse.associationResponse;
                            if (caseResponse !== undefined && caseResponse.isCaseInactive) {
                                this.disableNextButton = false;
                                this.noMatchOrCaseInactive =
                                    caseResponse.isCaseInactive;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined &&
                                caseResponse.accessPresent &&
                                !caseResponse.canRequestAccess
                            ) {
                                this.disableNextButton = true;
                                this.isAccessPresent =
                                    caseResponse.accessPresent;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined &&
                                caseResponse.pendingRequest &&
                                !caseResponse.canRequestAccess
                            ) {
                                this.disableNextButton = true;
                                this.isPendingRequest =
                                    caseResponse.pendingRequest;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined &&                                    
                                caseResponse.canRequestAccess
                            ) {
                                this.disableNextButton = true;
                                this.assisterName = caseResponse.assisterName;
                                this.anotherAssisterPresent =
                                    caseResponse.anotherAssisterPresent;                                                                  
                                let mapInfoData, keyValue;
                                if (this.applicationNumber !== undefined && caseResponse.mapAppInfo != null && caseResponse.mapAppInfo !== undefined) {
                                    this.mapAppInfo = caseResponse.mapAppInfo;
                                    mapInfoData = JSON.stringify(caseResponse.mapAppInfo);
                                    keyValue = this.applicationNumber;
                                }                                                                        
                                const jsonParse = JSON.parse(mapInfoData);
                                const mapInfoProgramCode = jsonParse[keyValue].ProgramCode;
                                const mapInfoProgramCodeArray = [];
                                const programValues = mapInfoProgramCode.split(";");
                                for (let index = 0; index < programValues.length; index++) {
                                    mapInfoProgramCodeArray.push(programValues[index]);
                                }
                                this.RequestType = true;
                                this.showSpinner = false;
                                
                                this.UserFullName = caseResponse.contactName;
                                this.sspNoAssisterRelationTextLabel = formatLabels(
                                    this.label.sspNoAssisterRelationText,
                                    [this.UserFullName, this.assisterName]
                                );
                            }
                            this.showSearchIndividual = false;

                            this.error = undefined;
                            this.showSpinner = false;
                        })
                        .catch(error => {
                            this.error = error;
                            this.showSpinner = false;
                        });                        
                    }                
                }
            } 
        } else {
            this.showSearchIndividual = true;
            this.applicationInitiated = false;
        }       
       
         if(this.onlyLangVariable){
            this.showSearchIndividual = true;
        }
        getAssisterTimeConfig()
            .then(result => {
                this.timerConfigValue = result;
                this.error = undefined;
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
            });
        //user info code
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            sspConstants.contactFields.FirstName +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.MiddleName +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.LastName +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.SuffixCode__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.SSN__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.GenderCode__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.BirthDate +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.Street__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.City__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.CountyCode__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.SSP_State__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.ZipCode5__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.ZipCode4__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.contactFields.AddressLine2__c +
                "," +
                sspConstants.sspObjectAPI.Contact,
            sspConstants.accountContactRelationFields
                .RepresentativeRelationshipCode__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation
        );
        this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "REPS_AddAuthorizedRepresentative2"
        );
    }
    /**
     * @function : openConsentFormAppendix.
     * @description : open and download file.
     *  @param {object} event - Js event.
     */
    openConsentFormAppendix = event => {
        try {
            const documentName = event.target.dataset.documentName;
            this.documentNameTemp = documentName;
            if (event.keyCode === 13 || event.type === "click") {
                const pageUrl = "program-form-download";
                const previewUrl = pageUrl + "?contentDoc=ConsentFormAppendix";
                // For other browsers Download Document
                const isSafari =
                    navigator.userAgent.indexOf("Safari") != -1 &&
                    navigator.userAgent.indexOf("Chrome") == -1;
                const isMobile = navigator.userAgent.match(
                    /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
                );
                if (isSafari || !isMobile) {
                    window.open(this.consentFormAppendix, "_blank");
                } else {
                    window.open(previewUrl, "_blank");
                }

                const downloadElement = document.createElement("a");
                downloadElement.href =
                    window.location.origin + this.consentFormAppendix;
                downloadElement.setAttribute("download", "download");
                downloadElement.download = "ConsentFormAppendix.pdf";
                downloadElement.click();
            }
        } catch (error) {
            console.error(
                "Error in openHealthCoverageForm" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : openConsentFormAppendixSpanish.
     * @description : open and download file.
     *  @param {object} event - Js event.
     */
    openConsentFormAppendixSpanish = event => {
        try {
            const documentName = event.target.dataset.documentName;
            this.documentNameTemp = documentName;
            if (event.keyCode === 13 || event.type === "click") {
                const pageUrl = "program-form-download";
                const previewUrl =
                    pageUrl + "?contentDoc=ConsentFormAppendixSpanish";
                // For other browsers Download Document
                const isSafari =
                    navigator.userAgent.indexOf("Safari") != -1 &&
                    navigator.userAgent.indexOf("Chrome") == -1;
                const isMobile = navigator.userAgent.match(
                    /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
                );
                if (isSafari || !isMobile) {
                    window.open(this.consentFormAppendixSpanish, "_blank");
                } else {
                    window.open(previewUrl, "_blank");
                }

                const downloadElement = document.createElement("a");
                downloadElement.href =
                    window.location.origin + this.consentFormAppendixSpanish;
                downloadElement.setAttribute("download", "download");
                downloadElement.download = "ConsentFormAppendixSpanish.pdf";

                downloadElement.click();
            }
        } catch (error) {
            console.error(
                "Error in openHealthCoverageFormSpanish" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleCustomEvent
     * @description : Used to get the user name from ssp-assister-access-request-user info.
     * @param {object} event - Js event.
     */
    handleCustomEvent (event) {
        const getFullName = event.detail.getUserName;
        const getRequestType = event.detail.type;
        const modPermissionLevelMedicaid =
            event.detail.modPermissionLevelMedicaid;
        const PermissionLevelKIHIPP = event.detail.PermissionLevelKIHIPP;
        const getRequestAccessJson = event.detail.requestAccessResp;
        const getPartialVal = event.detail.showNextStepScreen;
        const noCaseMatchAssister = event.detail.noCaseMatchFlag;

        this.noCaseMatchAssister = noCaseMatchAssister;
        this.assisterRequestPartialMatch = event.detail.authRequestPartialMatch;
        this.userName = getFullName;
        this.RequestType = getRequestType;
        this.permissionMedicare = modPermissionLevelMedicaid;
        this.permissionKHIP = PermissionLevelKIHIPP;
        this.requestAccessJson = getRequestAccessJson;
        this.showNextStepScreen = getPartialVal;
        this.sspNoAssisterRelationTextLabel = formatLabels(
            this.label.sspNoAssisterRelationText,
            [this.UserFullName, this.assisterName]
        );
    }
    /**
     * @function : displayLearnMoreModelMethod
     * @description : Used to open learn more modal.
     *  @param {object} event - Js event.
     */
    displayLearnMoreModelMethod = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.openLearnMoreModel = true;
            }
        } catch (error) {
            console.error(
                "Error in displayLearnMoreModelMethod" + error.message
            );
        }
    };
    /**
     * @function : hideLearnMoreModelMethod
     * @description : Used to hide learn more modal.
     */
    hideLearnMoreModelMethod = () => {
        try {
            this.openLearnMoreModel = false;
            this.openLearnMoreModel = "";
        } catch (error) {
            console.error("Error in hideLearnMoreModelMethod" + error.message);
        }
    };
    /**
     * @function : handleRequestConsent
     * @description : Used to Start Timer and request for program access.
     */
    handleTimer = () => {
        this.showSpinner = true;
        let notificationId = "";
        this.disableNextButton = true;
        createACRNotification({
            sSourceIndividualId: this.individualId,
            setCaseIds: this.setCaseIds,
            mapCaseInfo: this.mapCaseInfo,
            applicationNumber: this.applicationNumber,
            mapAppInfo: this.mapAppInfo
        })
            .then(result => {
                if (result.bIsSuccess) {
                    this.assisterMatchFound = result.mapResponse.assisterMatchFound;
                    notificationId = result.mapResponse.notificationId;
                    this.notificationId = notificationId;
                    this.clientDisagreed = false;
                    this.clientAgreed = false;

                    const duration = this.timerConfigValue,
                        display = this.template.querySelector(
                            ".ssp-timerSection"
                        );
                    const waitingConsent = this.template.querySelector(
                        ".ssp-waitingConsent"
                    );
                    const timerContainer = this.template.querySelector(
                        ".ssp-timerContainer"
                    );
                    let timer = parseInt(duration * 60);
                    let minutes, seconds;
                    const self = this;
                    let entered = false;
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    const myVar = setInterval(function () {
                        minutes = parseInt(timer / 60, 10);
                        seconds = parseInt(timer % 60, 10);

                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        seconds = seconds < 10 ? "0" + seconds : seconds;
                        self.showSpinner = false;
                        display.textContent = minutes + ":" + seconds;
                        if (!entered) {
                            self.disableRequestButton = true;
                            timerContainer.classList.remove("slds-hide");
                            waitingConsent.classList.remove("slds-hide");
                            entered = true;
                        }

                        if (--timer < -1) {
                            display.textContent = "";
                            clearInterval(myVar);
                            timerContainer.classList.add("slds-hide");
                            waitingConsent.classList.add("slds-hide");
                        }
                        if (self.falseValue) {
                            self.clientAgreed = true;
                            display.textContent = "";
                            clearInterval(myVar);
                            timerContainer.classList.add("slds-hide");
                            waitingConsent.classList.add("slds-hide");
                        }
                        if (self.trueValue) {
                            self.clientDisagreed = true;
                            display.textContent = "";
                            clearInterval(myVar);
                            timerContainer.classList.add("slds-hide");
                            waitingConsent.classList.add("slds-hide");
                        }
                        if (self.thirdValue) {
                            if (timer < -1) {
                                self.clientDidNotRespond = true;
                                display.textContent = "";
                                clearInterval(myVar);
                                timerContainer.classList.add("slds-hide");
                                waitingConsent.classList.add("slds-hide");
                            }
                        }
                    }, 1000);
                    //poll whether the notification is approved or denied
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this._interval = setInterval(() => {
                        this.progress = this.progress + 5000;
                        if (this.progress) {
                            pollingNotificationData({
                                notificationId: notificationId
                            })
                                .then(innerResult => {
                                    this.error = undefined;

                                    if (innerResult === "Client Accepted") {
                                        this.thirdValue = false;
                                        this.falseValue = true;
                                        this.clientAgreed = true;
                                        clearInterval(this._interval);
                                        clearInterval(myVar);
                                        display.textContent = "";
                                        timerContainer.classList.add(
                                            "slds-hide"
                                        );
                                        waitingConsent.classList.add(
                                            "slds-hide"
                                        );
                                        this.disableNextButton = false;
                                    } else if (innerResult === "Client Rejected") {
                                        this.thirdValue = false;
                                        if (this.numberOfTimesVisited > 0) {
                                            this.hideConsentAgainButton = true;
                                        }
                                        this.numberOfTimesVisited++;
                                        this.clientDisagreed = true;
                                        clearInterval(this._interval);
                                        clearInterval(myVar);
                                        display.textContent = "";
                                        timerContainer.classList.add(
                                            "slds-hide"
                                        );
                                        waitingConsent.classList.add(
                                            "slds-hide"
                                        );
                                        this.disableNextButton = false;
                                    }  else if (
                                        innerResult === "No Action"
                                    ) {
                                        this.thirdValue = true;
                                        this.disableNextButton = true;
                                    }
                                })
                                .catch(error => {
                                    this.error = error;
                                    this.disableNextButton = false;
                                });
                        }

                        if (this.progress === 180000) {
                            clearInterval(this._interval);
                        }
                    }, this.progress);
                }
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
                this.disableNextButton = true;
            });
    };

    openLinkModal = e => {
        if (e.keyCode === 13 || e.type === "click") {
            const type = e.currentTarget.dataset.type;
            this.sspAdditionalInfo = false;
            this.sspAuthorizationType = false;
            this.sspAcknowledgeRoles = false;
            this[type] = true;
        }
    };
    handleVerbalConsent = () => {
        this.showVerbalConsent = true;
    };
    updateToggleFields = event => {
        const type = event.currentTarget.dataset.type;
        this.sspAdditionalInfo = false;
        this.sspAuthorizationType = false;
        this.sspAcknowledgeRoles = false;
        this[type] = true;
        if (event.detail.sFieldName === "acknowledgeRoles") {
            this.isAckStart = true;
            this.isActComplete = event.detail.sFieldValue;
            this.selectedAcknowledgeRoles = true;
            
        } else if (event.detail.sFieldName === "authorization") {
            this.selectedAuthorizationConsent = true;
            this.isAuthStart = true;
            this.isAuthComplete = event.detail.sFieldValue;
        } else if (event.detail.sFieldName === "additionalInfo") {
            this.selectedAdditionalInfoConsent = true;
            this.isAdditionalInfoStart = true;
            this.isAdditionalInfoComplete = event.detail.sFieldValue;
        }
        if( this.isAckStart && this.isAuthStart && this.isAdditionalInfoStart){
            this.disableNextButton = false;
        }
    };

    // using wire service getting current user data

    @wire(getRecord, { recordId: USER_ID, fields: ["User.Name", "User.Id"] })
    userData ({ error, data }) {
        if (data) {

            const objCurrentData = data.fields;
            this.currentLoggedInUser = objCurrentData.Id.value;
            this.objUser = {
                Name: objCurrentData.Name.value
            };
            this.assisterName = this.objUser.Name;
        } 
    }
    handleNextButton = () => {
        try {
            this.showSpinner = true;//added for 388765
            if (
                (this.isAckStart && this.isActComplete) ||
                (this.isAuthStart && this.isAuthComplete) ||
                (this.isAdditionalInfoStart && this.isAdditionalInfoComplete)
            ) {//added condition for 388765, to call the server if client dint approved and to allow the assister.
                this.verbalConsentGiven = true;
            }
            if (
                (this.isAckStart && !this.isActComplete) ||
                (this.isAuthStart && !this.isAuthComplete) ||
                (this.isAdditionalInfoStart && !this.isAdditionalInfoComplete)
            ) {
                this.clientDisagreed = true;            
            }        
            else if (
                ((this.isAckStart && this.isActComplete) &&
                (this.isAuthStart && this.isAuthComplete) &&
                (this.isAdditionalInfoStart && this.isAdditionalInfoComplete)) ||(this.falseValue === true)
            ) {
                this.fullyConsentGiven= true;            
            }
            else if (this.thirdValue === true) {
                this.clientNoResponse = true;            
            }  

            if (
                this.verbalConsentGiven !== undefined &&
                this.verbalConsentGiven !== null &&
                this.verbalConsentGiven !== "" &&
                this.verbalConsentGiven === true
            ) {
                updateAccountContactRelation({
                    snotificationId: this.notificationId,
                    citizenConsent: true
                })
                    .then(result => {
                        if (!sspUtility.isUndefinedOrNull(this.applicationInitiated) && 
                            this.applicationInitiated){  
                            this.showSpinner = false;//added for 388765
                           if(this.fromHouseHoldSummary){
                                this[NavigationMixin.Navigate]({
                                    type: "comm__namedPage",
                                    attributes: {
                                        pageName: "household-summary"
                                    },
                                    state: {
                                        applicationId: this.applicationId,
                                        mode: "Intake"
                                    }
                                });
                           }
                           else {
                                this[NavigationMixin.Navigate]({
                                    type: "comm__namedPage",
                                    attributes: {
                                        pageName: "auth-reps-assisters"
                                    },
                                    state: {
                                        applicationId: this.applicationId,
                                        mode: "Intake"
                                    }
                                });
                           }
                        }
                        else {
                            if(result && result==="true"){
                                this.showNextStepScreen = true;
                                this.showSpinner = false;
                            }
                            else {
                                this.error = result;
                                this.showSpinner = false;
                                this.showErrorModal = true;
                            }
                            
                        }
                    })
                    .catch({                    
                    });
            }
            else if ( //Defect 391232
                this.applicationInitiated &&
                ((!sspUtility.isUndefinedOrNull(this.falseValue) &&
                    this.falseValue))) 
            {
                if (
                    !sspUtility.isUndefinedOrNull(
                        this.applicationInitiated
                    ) &&
                    this.applicationInitiated
                ) {
                    this.showSpinner = false;//added for 388765
                    if (this.fromHouseHoldSummary) {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "household-summary"
                            },
                            state: {
                                applicationId: this.applicationId,
                                mode: "Intake"
                            }
                        });
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "auth-reps-assisters"
                            },
                            state: {
                                applicationId: this.applicationId,
                                mode: "Intake"
                            }
                        });
                    }
                }
            }
            else if (this.applicationInitiated && 
                ((!sspUtility.isUndefinedOrNull(this.clientDisagreed) && this.clientDisagreed) || 
                (!sspUtility.isUndefinedOrNull(this.clientNoResponse) && this.clientNoResponse))){
                
                updateApplicationBlocked({
                    applicationId: this.applicationId
                })
                    .then(result => {
                        this.showSpinner = false;//added for 388765
                        this.showNextStepScreen = true;
                    })
                    .catch({                        
                    });   
            }
            else{
                this.showSpinner = false;//added for 388765
                this.showNextStepScreen = true;
            }
        }
        catch (error) {
            this.showSpinner = false;//added for 388765
            console.error("Error in handleNextButton of Assister Request page"+ JSON.stringify(error));
        }   
    };
    //user info
    /**
     * @function : renderedCallback
     * @description	: This method set the masking on input.
     */
    renderedCallback () {
        const sectionReference = this.template.querySelector(
            ".ssp-learnMore"
        );
        if (sectionReference) {
            // eslint-disable-next-line @lwc/lwc/no-inner-html
            sectionReference.innerHTML = this.modValue.HelpModal__c;
        }
        if (this.entered === false) {
            this.entered = true;
            //Add the below code for masking
            const agent = window.navigator.userAgent;
            const browserIE = /MSIE|Trident/.test(agent);
            if (browserIE) {
                this.inputTypePassword = sspConstants.inputTypes.password;
            } else {
                this.inputTypePassword = "text";
            }
        }
    }

    /**
     * @function : getObjectData
     * @description	: Wire call to retrieve contact metadata.
     * @param {object} objData - Retrieved data.
     */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    getObjectData ({ data }) {
        try {
            if (data) {
                const recordTypeInfo =
                    data[sspConstants.sspMemberConstants.RecordTypesInfo];
                this.recordTypeId = Object.keys(recordTypeInfo).find(
                    recordTypeId =>
                        recordTypeInfo[recordTypeId].name ===
                        sspConstants.contactRecordTypes.Auth_Rep
                );
            }
        } catch (error) {
            console.error(
                "Error in retrieving data sspAddAuthRep.getObjectData" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchSuffixValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Suffix api name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_SUFFIX
    })
    fetchSuffixValues ({ error, data }) {
        try {
            if (data) {
                this.suffixOptions = data.values;
            } else if (error) {
                console.error(
                    "Error occured in fetchSuffixValues in sspAuthRepAccessRequest screen" +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error occured in fetchSuffixValues in sspAuthRepAccessRequest screen" +
                    JSON.stringify(err.message)
            );
        }
    }

    /**
     * @function : fetchGenderValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Gender api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_GENDER
    })
    fetchGenderValues ({ error, data }) {
        try {
            if (data) {
                this.genderOptions = data.values;
            } else if (error) {
                console.error(
                    "Error occured in fetchGenderValues in sspAuthRepAccessRequest screen" +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error occured in fetchGenderValues in sspAuthRepAccessRequest screen" +
                    JSON.stringify(err.message)
            );
        }
    }

   

    /**
     * @function : getFirstName
     * @description	: To send User name to parent component.
     * @param {object} event - Js event.
     */
    getFirstName (event) {
        const firstName = event.target.value;
        this.FirstName = firstName;
    }
    /**
     * @function : handleRadioClick
     * @description	: To handle radio button changes.
     * @param  {object} event - .
     */
    handleRadioClick = event => {
        try {
            if (this.selectedRadio !== event.target.value) {
                // Checking for value change
                this.selectedRadio = event.target.value;
                if (
                    this.selectedRadio ===
                    sspConstants.agencyManagement.applicationNumber
                ) {
                    this.isCaseNumberDisabled = true;
                    this.isAppNumberDisabled = false;
                } else {
                    this.isAppNumberDisabled = true;
                    this.isCaseNumberDisabled = false;
                }
            }
        } catch (error) {
            console.error(error);
        }
    };
    /**
     * @function : handleCaseNumberChange
     * @description	: To handle Case Number change.
     * @param  {object} event - .
     */
    handleCaseNumberChange = event => {
        try {
            const caseNumber = event.detail.value;
            this.caseNumber = caseNumber;
            if (caseNumber !== "" && caseNumber !== null) {
                const radioRef = this.template.querySelectorAll(
                    sspConstants.agencyManagement.sspMultiLineRadioInput
                );
                radioRef.forEach(element => {
                    if (
                        element.value ===
                            sspConstants.agencyManagement.caseNumber &&
                        !element.checked
                    ) {
                        element.checked = true;
                        element.click();
                    }
                });
                this.isAppNumberDisabled = true;
            }
        } catch (error) {
            console.error(error);
        }
    };

    /**
     * @function : searchIndividualClick
     * @description	: To Search Individual based on entered criteria.
     */
    searchIndividualClick = () => {
        try {
            this.showSpinner = true;
            const sClientData = {};
            this.isFullMatch = false;
            this.isToShow = false;
            this.isPartialMatch = false;
            this.isNoMatch = false;
            const inputElement = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            this.checkValidations(inputElement);
            if (this.allowSave) {
                this.showErrorToast = false;
                inputElement.forEach(element => {
                    if (element.fieldName === "FirstName") {
                        sClientData.firstName = element.value;
                    }
                    if (element.fieldName === "LastName") {
                        sClientData.lastName = element.value;
                    }
                    if (element.fieldName === "MiddleName") {
                        sClientData.middleName = element.value;
                       
                    }
                    if (element.fieldName === "SuffixCode__c") {
                        sClientData.suffix = element.value;
                    }
                    if (element.fieldName === "GenderCode__c") {
                        sClientData.gender = element.value;
                    }
                    if (element.fieldName === sspConstants.contactFields.BirthDate) {
                        sClientData.birthDate = element.value;
                    }
                    if (element.fieldName === "SSN__c") {
                        sClientData.ssn = element.value;
                    }
                    if (
                        element.fieldName === "caseNumber" &&
                        !this.isCaseNumberDisabled
                    ) {
                        sClientData.caseNumber = element.value;
                        this.caseNumber = sClientData.caseNumber;
                       
                    }
                    if (
                        element.fieldName === "applicationNumber" &&
                        !this.isAppNumberDisabled
                    ) {
                        sClientData.applicationNumber = element.value;
                        this.applicationNumber = sClientData.applicationNumber;
                      
                    }
                });
                this.UserFullName =
                    sClientData.firstName + " " + sClientData.lastName;
                searchClientMCIService({
                    sClientDetails: JSON.stringify(sClientData)
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                           
                           
                            const matchResponse =
                                result.mapResponse.searchClientResponse
                                    .mciDetails;
                            const caseResponse =
                                result.mapResponse.associationResponse;
                            if( result.mapResponse.searchClientResponse.ERROR){
                                this.showErrorModal = true;
                                this.RequestType = false;
                            }
                            else if (matchResponse.bIsNoMatch) {
                                this.disableNextButton = true;
                                this.noMatchOrCaseInactive =
                                    matchResponse.bIsNoMatch;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            }
                            if (matchResponse.bIsPartialMatch) {
                                this.disableNextButton = true;
                                this.isPartialMatch =
                                    matchResponse.bIsPartialMatch;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (caseResponse!==undefined && caseResponse.isCaseInactive) {
                               // this.disableNextButton = false;
                                this.noMatchOrCaseInactive =
                                    caseResponse.isCaseInactive;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined && 
                                caseResponse.accessPresent &&
                                !caseResponse.canRequestAccess
                            ) {
                                this.disableNextButton = true;
                                this.isAccessPresent =
                                    caseResponse.accessPresent;
                                this.showSpinner = false;    
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined && 
                                caseResponse.pendingRequest &&
                                !caseResponse.canRequestAccess
                            ) {
                                this.disableNextButton = true;
                                this.isPendingRequest =
                                    caseResponse.pendingRequest;
                                this.showSpinner = false;
                                this.showNextStepScreen = true;
                            } else if (
                                caseResponse !== undefined && 
                                matchResponse.bIsFullMatch &&
                                caseResponse.canRequestAccess
                            ) {
                                //this.disableNextButton = false;
                                this.assisterName = caseResponse.assisterName;
                                this.anotherAssisterPresent =
                                    caseResponse.anotherAssisterPresent;
                                this.individualId =
                                    matchResponse.sSourceIndividualId;
                                this.setCaseIds = caseResponse.setCaseIds;
                                
                                let mapInfoData, keyValue;                                
                                if (this.applicationNumber!==undefined && caseResponse.mapAppInfo != null && caseResponse.mapAppInfo !== undefined) {
                                    this.mapAppInfo = caseResponse.mapAppInfo;
                                    mapInfoData = JSON.stringify(caseResponse.mapAppInfo);
                                    keyValue = this.applicationNumber;
                                }
                                else if (this.caseNumber && caseResponse.mapCaseInfo !== null && caseResponse.mapCaseInfo !== undefined) {
                                    this.mapCaseInfo = caseResponse.mapCaseInfo;
                                    mapInfoData = JSON.stringify(caseResponse.mapCaseInfo);
                                    keyValue = this.caseNumber;
                                }
                                else{
                                    this.mapCaseInfo = caseResponse.mapCaseInfo;
                                    mapInfoData = JSON.stringify(caseResponse.mapCaseInfo);
                                    keyValue = this.setCaseIds[0];
                                }
                                const jsonParse = JSON.parse(mapInfoData);
                                const mapInfoProgramCode = jsonParse[keyValue].ProgramCode;
                                const mapInfoProgramCodeArray = [];
                                const programValues = mapInfoProgramCode.split(";");
                                for (let index = 0; index < programValues.length; index++) {
                                    mapInfoProgramCodeArray.push(programValues[index]);
                                }
                                this.RequestType = true;
                                this.showSpinner = false;
                                
                               
                                this.sspNoAssisterRelationTextLabel = formatLabels(
                                    this.label.sspNoAssisterRelationText,
                                    [this.UserFullName, this.assisterName]
                                );
                            }

                            this.showSpinner = false;
                        } else if (!result.bIsSuccess) {
                            console.error(
                                "Error occurred in searchIndividualClick of sspAuthRepAccessRequest page" +
                                    result.mapResponse.ERROR
                            );
                            this.showSpinner = false;
                            this.showErrorModal = true;
                        }
                    })
                    .catch({});
            } else {
                this.showSpinner = false;
                this.disableNextButton = true;
                this.showErrorToast = true;
            }
        } catch (error) {
            console.error(
                "Error occurred in searchIndividualClick of sspAuthRepAccessRequest page" +
                    JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    };
    /**
     * @function 		: handleHideToast.
     * @description 	: this method is handle toast.
    
     * */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : handleCancelButton
     * @description	: To go to prev page.
     */
    handleCancelButton = () => {
        try {
            this.showSpinner = true;
            if(this.onlyLangVariable){
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url:
                            sspConstants.url.home
                    }
                });
            }
            else if(this.fromHouseHoldSummary){
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "household-summary"
                    },
                    state: {
                        applicationId: this.applicationId,
                        mode: "Intake"
                    }
                });
            }
            else {
                this.showSpinner = true;
                revertRequestAccess({
                    applicationId: this.applicationId
                })
                    .then(result => {
                        this.showSpinner = false
                
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "auth-reps-assisters"
                    },
                    state: {
                        applicationId: this.applicationId,
                        mode: "Intake"
                    }
                });
                    })
               }
            
        } catch (error) {
            console.error(
                "Error occurred in handleCancelButton of sspAuthRepAccessRequest page" +
                    JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    };

    /**
     * @function : handleAppNumberChange
     * @description           : To handle Application Number change.
     * @param  {object} event - .
     */
    handleAppNumberChange = event => {
        try {
            const appNumber = event.detail.value;
            this.applicationNumber = appNumber;
            if (appNumber !== "" && appNumber !== null) {
                const radioRef = this.template.querySelectorAll(
                    sspConstants.agencyManagement.sspMultiLineRadioInput
                );
                radioRef.forEach(element => {
                    if (
                        element.value ===
                            sspConstants.agencyManagement.applicationNumber &&
                        !element.checked
                    ) {
                        element.checked = true;
                        element.click();
                    }
                });
                this.isCaseNumberDisabled = true;
            }
        } catch (error) {
            console.error(error);
        }
    };

    //Defect 391232 - When request access visited from HOH summary check for transaction status  
    /**
    * @function : requestApplicationFromHHSummary
    * @description	: Request access to application method when initiated from HOH summary by Assister.
    */
    requestApplicationFromHHSummary (){
        requestConsentApplication({
            individualId: this.individualId,
            applicationId: this.applicationId
        })
            .then(result => {                
                this.applicationNumber =
                    result.mapResponse.applicationNumber;
                const caseResponse =
                    result.mapResponse.associationResponse;
                if (
                    caseResponse !== undefined &&
                    caseResponse.isCaseInactive
                ) {
                    this.disableNextButton = false;
                    this.noMatchOrCaseInactive =
                        caseResponse.isCaseInactive;
                    this.showSpinner = false;
                    this.showNextStepScreen = true;
                } else if (
                    caseResponse !== undefined &&
                    caseResponse.accessPresent &&
                    !caseResponse.canRequestAccess
                ) {
                    this.disableNextButton = true;
                    this.isAccessPresent =
                        caseResponse.accessPresent;
                    this.showSpinner = false;
                    this.showNextStepScreen = true;
                } else if (
                    caseResponse !== undefined &&
                    caseResponse.pendingRequest &&
                    !caseResponse.canRequestAccess
                ) {
                    this.disableNextButton = true;
                    this.isPendingRequest =
                        caseResponse.pendingRequest;
                    this.showSpinner = false;
                    this.showNextStepScreen = true;
                } else if (
                    caseResponse !== undefined &&
                    caseResponse.canRequestAccess
                ) {
                    this.disableNextButton = true;
                    this.assisterName = caseResponse.assisterName;
                    this.anotherAssisterPresent =
                        caseResponse.anotherAssisterPresent;
                    let mapInfoData, keyValue;
                    if (
                        this.applicationNumber !== undefined &&
                        caseResponse.mapAppInfo != null &&
                        caseResponse.mapAppInfo !== undefined
                    ) {
                        this.mapAppInfo = caseResponse.mapAppInfo;
                        mapInfoData = JSON.stringify(
                            caseResponse.mapAppInfo
                        );
                        keyValue = this.applicationNumber;
                    }
                    const jsonParse = JSON.parse(mapInfoData);
                    const mapInfoProgramCode =
                        jsonParse[keyValue].ProgramCode;
                    const mapInfoProgramCodeArray = [];
                    const programValues = mapInfoProgramCode.split(
                        ";"
                    );
                    for (
                        let index = 0;
                        index < programValues.length;
                        index++
                    ) {
                        mapInfoProgramCodeArray.push(
                            programValues[index]
                        );
                    }
                    this.RequestType = true;
                    this.showSpinner = false;
                    this.UserFullName = caseResponse.contactName;
                    this.sspNoAssisterRelationTextLabel = formatLabels(
                        this.label.sspNoAssisterRelationText,
                        [this.UserFullName, this.assisterName]
                    );
                }
                this.showSearchIndividual = false;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
            });
    }
    /**
   * @function : fetchTransactionStatusFromServer
   * @description	: Fetch if data related to current screen is loaded to SF objects. Added by Nupoor .
   * @param {object} functionArguments - Parameters to Apex method.
   */
    fetchTransactionStatusFromServer (functionArguments) {
        try {
            fetchTransactionStatus(functionArguments)
                .then(response => {                    
                    const result = response.mapResponse;
                    if (result.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in sspAssisterAccessRequest.fetchTransactionStatusFromServer" +
                            result.ERROR
                        );
                    } else if (result.hasOwnProperty("status")) {
                        const status = result.status;
                        if (
                            status === "NULL" ||
                            status === sspConstants.pollingStatus_RAC.success
                        ) {                            
                            this.requestApplicationFromHHSummary();
                        } else if (status === sspConstants.pollingStatus_RAC.failure) {
                            const message = result.message;
                            this.showErrorModal = true;
                            this.errorMsg = message;
                            this.showSpinner = false;
                        } else if (status === sspConstants.pollingStatus_RAC.pending) {
                            const pollingInterval = parseInt(sspPollingInterval);
                            // eslint-disable-next-line @lwc/lwc/no-async-operation
                            setTimeout(() => {
                                this.fetchTransactionStatusFromServer(functionArguments);
                            }, pollingInterval);
                        }
                    }
                })
                .catch(error => {
                    console.error(
                        "failed in sspAssisterAccessRequest.fetchTransactionStatusFromServer " +
                        error
                    );
                });
        } catch (error) {
            console.error(
                "Error in sspAssisterAccessRequest.fetchApplicationDetailsFromServer" +
                error
            );
        }
    }
}