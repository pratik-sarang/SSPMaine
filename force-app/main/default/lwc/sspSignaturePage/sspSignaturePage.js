/**
 * Component Name: sspSignaturePage.
 * Author: Karthik Velu, Sai Kiran.
 * Description: .
 * Date: 1/21/2020.
 */
import { track, api, wire } from "lwc";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspTermsOfAgreement from "@salesforce/label/c.SSP_SignaturePageTermsOfAgreement";
import sspTermOne from "@salesforce/label/c.SSP_SignaturePageTermOne";
import sspTermTwo from "@salesforce/label/c.SSP_SignaturePageTermTwo";
import sspTermThree from "@salesforce/label/c.SSP_SignaturePageTermThree";
import sspTermFour from "@salesforce/label/c.SSP_SignaturePageTermFour";
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
import sspVoterRegistration from "@salesforce/label/c.SSP_SignaturePageVoterRegistration";
import sspRegisterToVote from "@salesforce/label/c.SSP_SignaturePageRegisterToVote";
import sspVoterRegistrationForms from "@salesforce/label/c.SSP_SignaturePageVoterRegistrationForms";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspReadPolicyValidatorErrorText from "@salesforce/label/c.SSP_ReadPolicyValidatorErrorText";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspToVoteHelpText from "@salesforce/label/c.SSP_SignaturePageRegisterToVoteHelpText";
import sspThePrimaryHelpText from "@salesforce/label/c.SSP_SignaturePageDoesThePrimaryHelpText";
import sspSignaturePage from "@salesforce/label/c.sspSignaturePage";
import utility, { getYesNoOptions } from "c/sspUtility";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import constant from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import SSPAPPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";

import IsRegisteredToVote from "@salesforce/schema/SSP_Application__c.IsRegisteredToVote__c";
import ApplicationEsignLastName from "@salesforce/schema/SSP_Application__c.ApplicationEsignLastName__c";
import ApplicationEsignFirstName from "@salesforce/schema/SSP_Application__c.ApplicationEsignFirstName__c";
import ApplicationEsignSuffixCode from "@salesforce/schema/SSP_Application__c.ApplicationEsignSuffixCode__c";
import ApplicationEsignMiddleInitial from "@salesforce/schema/SSP_Application__c.ApplicationEsignMiddleInitial__c";
import IsApplicantAgreeToWorkRegister from "@salesforce/schema/SSP_Application__c.IsApplicantAgreeToWorkRegister__c";
import IsRenewalConsent from "@salesforce/schema/SSP_Application__c.IsRenewalConsent__c";

import ProgramsApplied from "@salesforce/schema/SSP_Application__c.ProgramsApplied__c";
import IsAgreeingToKiHippConsent from "@salesforce/schema/SSP_Application__c.IsAgreeingToKiHippConsent__c";
import IsAgreeingToMA34Declaration from "@salesforce/schema/SSP_Application__c.IsAgreeingToMA34Declaration__c";
import IsAgreeingToMedicaidPenalty from "@salesforce/schema/SSP_Application__c.IsAgreeingToMedicaidPenalty__c";
import IsAgreeingToSNAPRightsConsent from "@salesforce/schema/SSP_Application__c.IsAgreeingToSNAPRightsConsent__c";
import IsAgreeingToApplicationConsent from "@salesforce/schema/SSP_Application__c.IsAgreeingToApplicationConsent__c";
import IsAgreeingToLTCResourceTransferConsent from "@salesforce/schema/SSP_Application__c.IsAgreeingToLTCResourceTransferConsent__c";

import fetchResponseData from "@salesforce/apex/SSP_SignaturePageCtrl.fetchResponseData";
import invokeSSPDC from "@salesforce/apex/SSP_SignaturePageCtrl.sspDCServiceCall";
import sspTwentyDateValidatorMessage from "@salesforce/label/c.SSP_TwentyDateValidatorMessage"; // Added as a part of Defect - 377050
import fetchTiming from "@salesforce/apex/SSP_SignaturePageService.fetchTiming";
import explicitText from "@salesforce/label/c.SSP_ExplicitText";
import outsideDCBSMsg from "@salesforce/label/c.SSP_OutsideDCBSMsg";
const FIELDS = [
    IsRegisteredToVote,
    ApplicationEsignLastName,
    ApplicationEsignFirstName,
    ApplicationEsignSuffixCode,
    ApplicationEsignMiddleInitial,
    IsApplicantAgreeToWorkRegister,
    IsRenewalConsent,
    ProgramsApplied,
    IsAgreeingToKiHippConsent,
    IsAgreeingToMA34Declaration,
    IsAgreeingToMedicaidPenalty,
    IsAgreeingToSNAPRightsConsent,
    IsAgreeingToApplicationConsent,
    IsAgreeingToLTCResourceTransferConsent
];
const dayLimit = 19; // Added as a part of Defect - 377050
const signatureDateFieldAPI = "SignatureDate__c"; // Added as a part of Defect - 377050 
export default class SspSignaturePage extends NavigationMixin(baseNavFlowPage) {
    @track scrollModal = true;
    @track isMiddleInitialDisabled = false;
    @track IsAgreeingToMA34DeclarationConsent;
    @track displayNoticeCard = false;
    @track isProgressStart = true;
    @track isProgressComplete = false;
    @track sspReadAndAgreeConsent = false;
    @track sspDeclarationOfAnnuities = false;
    @track sspMedicaidPenaltyWarning = false;
    @track sspResourceTransferConsent = false;
    @track sspStatementOfUnderstanding = false;
    @track sspRightsAndResponsibilities = false;
    @track responseOptions = getYesNoOptions();
    @track appId;
    @track sMode;
    @track nextValue;
    @track suffixCode;
    @track allowSaveValue;
    @track MetaDataListParent;
    @track objApplication = {};
    @track applicationWrapper = {};
    @track resourceRecordTypeId;
    @track toastErrorText;
    @track serviceCall = false;
    @track showErrorModal = false;
    @track showSpinner = false;
    @track errorMsg;
    @track trueValue = true;
    @track isFieldValuesLoaded = false;
    @track isDisableMIField = false;
    @track isDisableMICheckbox = false;
    @track bIsSnapApplication = false;
    @track bIsMedicaidApplication = false;
    @track additionalInfoSnap = false;
    @track additionalInfoKTAP = false;
    @track additionalInfoMedicaid = false;
    @track isKiHippConsentProgressStart = false;
    @track isMA34DeclarationProgressStart = false;
    @track isMedicaidPenaltyProgressStart = false;
    @track isSNAPRightsConsentProgressStart = false;
    @track isApplicationConsentProgressStart = false;
    @track isLTCResourceTransferConsentProgressStart = false;
    @track isKiHippConsentProgressComplete = false;
    @track isMA34DeclarationProgressComplete = false;
    @track isMedicaidPenaltyProgressComplete = false;
    @track isSNAPRightsConsentProgressComplete = false;
    @track isApplicationConsentProgressComplete = false;
    @track isLTCResourceTransferConsentProgressComplete = false;
    @track bShowAgreeingToKiHippConsent = false;
    @track bShowAgreeingToMedicaidPenalty = false;
    @track bShowAgreeingToSNAPRightsConsent = false;
    @track bShowAgreeingToLTCResourceTransferConsent = false;
    @track isAgreeingToKiHippConsent;
    @track isAgreeingToMA34Declaration;
    @track isAgreeingToMedicaidPenalty;
    @track isAgreeingToSNAPRightsConsent;
    @track isAgreeingToApplicationConsent;
    @track isAgreeingToLTCResourceTransferConsent;
    @track isAgreeingToKiHippConsentValue;
    @track isAgreeingToMA34DeclarationValue;
    @track IsDMSAnnuitiesBeneficiaryValue;
    @track IsAnnutiesDeclarationCodeValue;
    @track isAgreeingToMedicaidPenaltyValue;
    @track isAgreeingToSNAPRightsConsentValue;
    @track isAgreeingToApplicationConsentValue;
    @track isAgreeingToLTCResourceTransferConsentValue;
    @track isAgreeingToKiHippConsentRequiredFieldError;
    @track isAgreeingToMA34DeclarationRequiredFieldError;
    @track isAgreeingToMedicaidPenaltyRequiredFieldError;
    @track isAgreeingToSNAPRightsConsentRequiredFieldError;
    @track isAgreeingToApplicationConsentRequiredFieldError;
    @track
    isAgreeingToLTCResourceTransferConsentRequiredFieldError;
    @track isAgreeingToKiHippConsentErrorText;
    @track isAgreeingToMA34DeclarationErrorText;
    @track isAgreeingToMedicaidPenaltyErrorText;
    @track isAgreeingToSNAPRightsConsentErrorText;
    @track isAgreeingToApplicationConsentErrorText;
    @track isAgreeingToLTCResourceTransferConsentErrorText;
    @track bShowHyperlinkValidation = false;
    @track hasSaveValidationError = false;
    @track goAhead = true;
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isApplicationStatementReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isMedicaidPenaltyReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isSnapRightsReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isLTCReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isAnnuitiesReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isKIHIPPReadOnly = false;//CD2 2.5 Security Role Matrix.
    @track isApplicationStatementNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track isMedicaidPenaltyNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track isSnapRightsNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track isLTCNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track isAnnuitiesNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track isKIHIPPNotAccessible = false;//CD2 2.5 Security Role Matrix.
    @track appMode;//CD2 2.5 Security Role Matrix.
    @track isDateReadOnly = true; //Added as part of Defect-377050
    @track isToShows20DateValidator = false; //Added as part of Defect-377050    
    @track timeFlag;// CR - Changes
    @track submitCount = 0;
    @track showGreyLine = false;  //Added as part of Defect-383381
    selectedRole = ""; //Added as part of Defect-377050
    @track toShowBannerMessage =false;  //Added as part of Defect-386154

    label = {
        sspTermsOfAgreement,
        sspTermOne,
        sspTermTwo,
        sspTermThree,
        sspTermFour,
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
        sspVoterRegistration,
        sspRegisterToVote,
        sspVoterRegistrationForms,
        sspRequiredErrorMessage,
        sspReadPolicyValidatorErrorText,
        toastErrorText,
        sspToVoteHelpText,
        sspThePrimaryHelpText,
explicitText,
        outsideDCBSMsg,
        sspTwentyDateValidatorMessage // Added as part of Defect - 377050
    };

    customLabel = {
        sspYes,
        sspNo
    };

    get annuitiesModal () {
        return this.objApplication.bIsNonMagi && !this.isAnnuitiesNotAccessible;
    }

    get pageRenderingStatus () {
        return this.isFieldValuesLoaded && !this.isNotAccessible;
    }

    get middleInitialDisablingStatus () {
        return this.isMiddleInitialDisabled || this.isReadOnlyUser; //CD2 2.5 Security Role Matrix.
    }

    /**
     * @function 	: applicationId.
     * @description : This attribute is part of validation framework which gives the Application ID.
     * */
    @api
    get applicationId () {
        return this.appId;
    }
    set applicationId (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.appId = value;
                this.fetchApplication(value);
            }
        } catch (error) {
            console.error(
                "Error while fetching Application ID in Signature Page" + error
            );
        }
    }

    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.MetaDataListParent = value;
                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                }
            }
        } catch (error) {
            console.error(
                "Error while fetching metadata values in Signature Page" + error
            );
        }
    }

    /**
     * @function 	: allowSave.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSaveData () {
        return this.allowSaveValue;
    }
    set allowSaveData (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                if (!this.hasSaveValidationError) {
                    this.allowSaveValue = value;
                    this.showSpinner = true;
                    this.saveData();
                }
            }
        } catch (error) {
            this.showSpinner = false;
            console.error("Error in allowSave of Signature Page" + error);
        }
    }

    /**
     * @function 	: nextEvent.
     * @description : This attribute is part of validation framework which is used to navigate to next Screen.
     * */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
          if (this.isReadOnlyUser){
              this[NavigationMixin.Navigate]({
                  type: constant.communityPageNames.community,
                  attributes: {
                      name: constant.communityPageNames.applicationSummaryApi
                  },
                  state: {
                      applicationId: this.appId,
                      mode: this.appMode
                  }
              }); 
          }
          else{
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.goAhead = true;
                if (this.bShowAgreeingToSNAPRightsConsent) {
                    if (
                        !utility.isUndefinedOrNull(
                            this.isAgreeingToSNAPRightsConsentRequiredFieldError
                        )
                    ) {
                        this.goAhead = false;
                    }
                }
                if (this.bShowAgreeingToKiHippConsent) {
                    if (
                        !utility.isUndefinedOrNull(
                            this.isAgreeingToKiHippConsentRequiredFieldError
                        )
                    ) {
                        this.goAhead = false;
                    }
                }
                if (this.bShowAgreeingToMedicaidPenalty) {
                    if (
                        !utility.isUndefinedOrNull(
                            this.isAgreeingToMedicaidPenaltyRequiredFieldError
                        )
                    ) {
                        this.goAhead = false;
                    }
                }
            }
            if (this.IsAgreeingToMA34DeclarationConsent) {
                if (
                    !utility.isUndefinedOrNull(
                        this.isAgreeingToMA34DeclarationRequiredFieldError
                    )
                ) {
                    this.goAhead = false;
                }
            }
            if (this.bShowAgreeingToLTCResourceTransferConsent) {
                if (
                    !utility.isUndefinedOrNull(
                        this
                            .isAgreeingToLTCResourceTransferConsentRequiredFieldError
                    )
                ) {
                    this.goAhead = false;
                }
            }
            if (
                !utility.isUndefinedOrNull(
                    this.isAgreeingToApplicationConsentRequiredFieldError
                )
            ) {
                this.goAhead = false;
            }
            if (this.goAhead == false) {
                this.bShowHyperlinkValidation = true;
                this.hasSaveValidationError = true;
                this.toastErrorText = this.label.toastErrorText;
            } else {
                this.hasSaveValidationError = false;
            }
            //Start - Added this as part of Defect - 377050
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                const signatureElement = this.template.querySelector(
                      ".ssp-signatureDateClass"
                );
                if (
                    (this.selectedRole === constant.userRole.Mail_Center_Worker ||
                    this.selectedRole === constant.userRole.Mail_Center_Supervisor) &&
                    signatureElement &&
                    signatureElement.fieldName === signatureDateFieldAPI && 
                    signatureElement.value !== ""
                ) {
                    const currentDate = new Date(this.timeTravelCurrentDate);
                    const inputDate = new Date(signatureElement.value);
                    currentDate.setHours(0,0,0);
                    inputDate.setHours(0,0,0);
                    // Time difference
                    const differenceInTime = Math.abs(inputDate.getTime() - currentDate.getTime());
                    // Calculate the no. of days between two dates
                    const days = parseInt(differenceInTime / (24 * 60 * 60 * 1000), 10);
                    if (days > dayLimit || inputDate > currentDate) {
                        this.isToShows20DateValidator = true;
                        this.toastErrorText = this.label.toastErrorText;
                        this.template.querySelector(".ssp-signatureDateClass").classList.add("ssp-signatureDateHasError");
                        this.hasSaveValidationError = true;
                    }
                    else {
                        this.isToShows20DateValidator = false;
                        this.template.querySelector(".ssp-signatureDateClass").classList.remove("ssp-signatureDateHasError");
                    }
                }
                else {
                    this.template.querySelector(".ssp-signatureDateClass").classList.remove("ssp-applicationInputs");
                }
            }
            //End - Added this as part of Defect - 377050
            this.nextValue = value;
            this.getRequiredInputElements(); // use to check validations on component
          }
        } catch (error) {
            console.error(
                "Error in nextEvent of Expedite Benefits Page" + error
            );
        }
    }

    /**
     * @function 	: objectInfo.
     * @description 	: this is used to get the RecordType of the Object.
     * */
    @wire(getObjectInfo, {
        objectApiName: SSPAPPLICATION_OBJECT
    })
    objectInfo ({ data, error }) {
        try {
            if (data) {
                const recordTypeInformation =
                    data[constant.resourceDetailConstants.resourceRecordTypes];
                this.resourceRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name ===
                        constant.recordTypeNames.SSPApplicationRecordType
                );
            } else if (error) {
                console.error(
                    "### Error while trying to fetch Record Type values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "### Error while trying to fetch Record Type values ###" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSPAPPLICATION_OBJECT,
        recordTypeId: "$resourceRecordTypeId"
    })
    picklistOptions ({ error, data }) {
        try {
            if (data) {
                this.suffixCode =
                    data.picklistFieldValues.ApplicationEsignSuffixCode__c.values;
            } else if (error) {
                console.error(
                    "### Error while trying to fetch picklist values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "### Error while trying to fetch picklist values ###" +
                    JSON.stringify(error)
            );
        }
    }

    @wire(getRecord, { recordId: "$appId", fields: FIELDS })
    getApplication (response) {
        const data = response.data;
        const error = response.error;
        if (data) {
            this.applicationWrapper = data;
            this.isFieldValuesLoaded = true;
            if (
                data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.SN
                )
            ) {
                this.bIsSnapApplication = true;
                this.bShowAgreeingToSNAPRightsConsent = true;
                this.additionalInfoSnap = true;
                this.showGreyLine = true;
            }
            if (
                data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.KT
                )
            ) {
                this.additionalInfoKTAP = true;
            }
            if (
                data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.MA
                )
            ) {
                this.bIsMedicaidApplication = true;
                this.bShowAgreeingToMedicaidPenalty = true;
                this.additionalInfoMedicaid = true;
                this.showGreyLine = true;
            }
            if (
                data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.KP
                )
            ) {
                this.bShowAgreeingToKiHippConsent = true;
            }
            // Added as part of Defect-386154
            if (
                data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.SN
                ) || data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.KT
                ) || data.fields.ProgramsApplied__c.value.includes(
                    constant.programValues.CC
                )
            ) {
               
                this.toShowBannerMessage = true;
                
            }
            // End here Added as part of Defect-386154
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToMedicaidPenalty__c.value
                ) ||
                utility.isEmpty(
                    data.fields.IsAgreeingToMedicaidPenalty__c.value
                )
            ) {
                this.isAgreeingToMedicaidPenaltyRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToMedicaidPenaltyErrorText = this.label.sspReadPolicyValidatorErrorText;
            }
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToKiHippConsent__c.value
                ) ||
                utility.isEmpty(data.fields.IsAgreeingToKiHippConsent__c.value)
            ) {
                this.isAgreeingToKiHippConsentRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToKiHippConsentErrorText = this.label.sspReadPolicyValidatorErrorText;
            }
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToMA34Declaration__c.value
                ) ||
                utility.isEmpty(
                    data.fields.IsAgreeingToMA34Declaration__c.value
                )
            ) {
                this.isAgreeingToMA34DeclarationRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToMA34DeclarationErrorText = this.label.sspReadPolicyValidatorErrorText;
            }
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToSNAPRightsConsent__c.value
                ) ||
                utility.isEmpty(
                    data.fields.IsAgreeingToSNAPRightsConsent__c.value
                )
            ) {
                this.isAgreeingToSNAPRightsConsentRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToSNAPRightsConsentErrorText = this.label.sspReadPolicyValidatorErrorText;
            }
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToApplicationConsent__c.value
                ) ||
                utility.isEmpty(
                    data.fields.IsAgreeingToApplicationConsent__c.value
                )
            ) {
                this.isAgreeingToApplicationConsentRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToApplicationConsentErrorText = this.label.sspReadPolicyValidatorErrorText;
            }
            if (
                utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToLTCResourceTransferConsent__c.value
                ) ||
                utility.isEmpty(
                    data.fields.IsAgreeingToLTCResourceTransferConsent__c.value
                )
            ) {
                this.isAgreeingToLTCResourceTransferConsentRequiredFieldError = this.label.sspRequiredErrorMessage;
                this.isAgreeingToLTCResourceTransferConsentErrorText = this.label.sspReadPolicyValidatorErrorText;
            }

            if (
                data.fields.IsAgreeingToMedicaidPenalty__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToMedicaidPenalty = true;
                this.isMedicaidPenaltyProgressStart = true;
                this.isMedicaidPenaltyProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToMedicaidPenalty__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToMedicaidPenalty = true;
                this.isMedicaidPenaltyProgressStart = true;
                this.isMedicaidPenaltyProgressComplete = false;
            }
            if (
                data.fields.IsAgreeingToKiHippConsent__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToKiHippConsent = true;
                this.isKiHippConsentProgressStart = true;
                this.isKiHippConsentProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToKiHippConsent__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToKiHippConsent = true;
                this.isKiHippConsentProgressStart = true;
                this.isKiHippConsentProgressComplete = false;
            }
            if (
                data.fields.IsAgreeingToMA34Declaration__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToMA34Declaration = true;
                this.isMA34DeclarationProgressStart = true;
                this.isMA34DeclarationProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToMA34Declaration__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToMA34Declaration = true;
                this.isMA34DeclarationProgressStart = true;
                this.isMA34DeclarationProgressComplete = false;
            }
            if (
                data.fields.IsAgreeingToSNAPRightsConsent__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToSNAPRightsConsent = true;
                this.isSNAPRightsConsentProgressStart = true;
                this.isSNAPRightsConsentProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToSNAPRightsConsent__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToSNAPRightsConsent = true;
                this.isSNAPRightsConsentProgressStart = true;
                this.isSNAPRightsConsentProgressComplete = false;
            }
            if (
                data.fields.IsAgreeingToApplicationConsent__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToApplicationConsent = true;
                this.isApplicationConsentProgressStart = true;
                this.isApplicationConsentProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToApplicationConsent__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToApplicationConsent = true;
                this.isApplicationConsentProgressStart = true;
                this.isApplicationConsentProgressComplete = false;
            }
            if (
                data.fields.IsAgreeingToLTCResourceTransferConsent__c.value ===
                constant.toggleFieldValue.yes
            ) {
                this.isAgreeingToLTCResourceTransferConsent = true;
                this.isLTCResourceTransferConsentProgressStart = true;
                this.isLTCResourceTransferConsentProgressComplete = true;
            } else if (
                data.fields.IsAgreeingToLTCResourceTransferConsent__c.value ===
                constant.toggleFieldValue.no
            ) {
                this.isAgreeingToLTCResourceTransferConsent = true;
                this.isLTCResourceTransferConsentProgressStart = true;
                this.isLTCResourceTransferConsentProgressComplete = false;
            }

            //Code for Field Level Validations for Hyperlinks
            if (
                !utility.isUndefinedOrNull(
                    data.fields.IsAgreeingToLTCResourceTransferConsent__c.value
                ) &&
                !utility.isEmpty(
                    data.fields.IsAgreeingToLTCResourceTransferConsent__c.value
                )
            ) {
                this.isAgreeingToLTCResourceTransferConsentErrorText = "";
            }
            if (
                data.fields.IsRegisteredToVote__c.value ==
                constant.toggleFieldValue.yes
            ) {
                this.displayNoticeCard = true;
            }
        } else if (error) {
            console.error("Error in getMember:", error);
        }
    }
    //Added as part of Defect-386154
    get bannerVisibility (){
        return this.toShowBannerMessage && this.timeFlag;
    }
    // End part of Defect-386154

    /**
     * @function : connectedCallback.
     * @description : This function is fetch the MetaData values on Load.
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
        const url = new URL(window.location.href);
        this.appMode = url.searchParams.get("mode") || "Intake";
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            "ApplicationEsignFirstName__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignLastName__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignMiddleInitial__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignSuffixCode__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "IsApplicantAgreeToWorkRegister__c,SSP_Application__c"
        );
        fieldEntityNameList.push("SignatureDate__c,SSP_Application__c"); // Added as a part of Defect - 377050
        fieldEntityNameList.push("IsRegisteredToVote__c,SSP_Application__c");
        fieldEntityNameList.push("IsRenewalConsent__c,SSP_Application__c");
        this.getMetadataDetails(fieldEntityNameList, null, "SSP_APP_Signature");
        const signatureHeader = new CustomEvent(
            constant.events.updateSignatureHeader,
            {
                bubbles: true,
                composed: true,
                detail: {
                    header: sspSignaturePage
                }
            }
        );

        this.dispatchEvent(signatureHeader);
    }

    /**
     * @function : fetchApplication.
     * @description : This function is fetch the Application Data.
     * @param {appId} appID - Application ID.
     */
    fetchApplication = appID => {
        fetchResponseData({
            sApplicationId: appID
        })
            .then(result => {
                if (result.bIsSuccess) {
                    const objApplication = result.mapResponse.objWrapper;
                    const { securityMatrixAppAgreement, securityMatrixMedicaidPenalty, securityMatrixNAPInfoRules, securityMatrixLTCResourceTransfer, securityMatrixDeclarationAnnuities, securityMatrixKIHIPPConsent} = result.mapResponse;
                    if (result && result.mapResponse){
                        if (securityMatrixAppAgreement && securityMatrixAppAgreement.hasOwnProperty("screenPermission") && securityMatrixAppAgreement.screenPermission){
                            this.isApplicationStatementReadOnly = securityMatrixAppAgreement.screenPermission === constant.permission.readOnly;
                            this.isApplicationStatementNotAccessible = securityMatrixAppAgreement.screenPermission === constant.permission.notAccessible;
                            if(this.isApplicationStatementNotAccessible){
                                this.isAgreeingToApplicationConsentRequiredFieldError = null;
                            }
                        }
                        if (securityMatrixMedicaidPenalty && securityMatrixMedicaidPenalty.hasOwnProperty("screenPermission") && securityMatrixMedicaidPenalty.screenPermission) {
                            this.isMedicaidPenaltyReadOnly = securityMatrixMedicaidPenalty.screenPermission === constant.permission.readOnly;
                            this.isMedicaidPenaltyNotAccessible = securityMatrixMedicaidPenalty.screenPermission === constant.permission.notAccessible;
                            if (this.isMedicaidPenaltyNotAccessible){
                                this.bShowAgreeingToMedicaidPenalty = false;
                            }
                        }
                        if (securityMatrixNAPInfoRules && securityMatrixNAPInfoRules.hasOwnProperty("screenPermission") && securityMatrixNAPInfoRules.screenPermission) {
                            this.isSnapRightsReadOnly = securityMatrixNAPInfoRules.screenPermission === constant.permission.readOnly;
                            this.isSnapRightsNotAccessible = securityMatrixNAPInfoRules.screenPermission === constant.permission.notAccessible;
                            if (this.isSnapRightsNotAccessible){
                                this.bShowAgreeingToSNAPRightsConsent = false;
                            }    
                        }
                        if (securityMatrixLTCResourceTransfer && securityMatrixLTCResourceTransfer.hasOwnProperty("screenPermission") && securityMatrixLTCResourceTransfer.screenPermission) {
                            this.isLTCReadOnly = securityMatrixLTCResourceTransfer.screenPermission === constant.permission.readOnly;
                            this.isLTCNotAccessible = securityMatrixLTCResourceTransfer.screenPermission === constant.permission.notAccessible;
                            if (this.isLTCNotAccessible){
                                this.bShowAgreeingToLTCResourceTransferConsent = false;
                            }
                        }
                        if (securityMatrixDeclarationAnnuities && securityMatrixDeclarationAnnuities.hasOwnProperty("screenPermission") && securityMatrixDeclarationAnnuities.screenPermission) {
                            this.isAnnuitiesReadOnly = securityMatrixDeclarationAnnuities.screenPermission === constant.permission.readOnly;
                            this.isAnnuitiesNotAccessible = securityMatrixDeclarationAnnuities.screenPermission === constant.permission.notAccessible;
                            if (this.isAnnuitiesNotAccessible){
                                this.IsAgreeingToMA34DeclarationConsent = false;
                                this.isAgreeingToMA34DeclarationRequiredFieldError = null;
                            }
                        }
                        if (securityMatrixKIHIPPConsent && securityMatrixKIHIPPConsent.hasOwnProperty("screenPermission") && securityMatrixKIHIPPConsent.screenPermission) {
                            this.isKIHIPPReadOnly  = securityMatrixKIHIPPConsent.screenPermission === constant.permission.readOnly;
                            this.isKIHIPPNotAccessible = securityMatrixKIHIPPConsent.screenPermission === constant.permission.notAccessible;
                            if (this.isKIHIPPNotAccessible){
                                this.bShowAgreeingToKiHippConsent = false;
                            }
                        }
                    }
                    //Added as part of defect 366599 by Abhishek, CD1.
                    if (objApplication.hasOwnProperty("sPrimaryApplicantMiddleName") && objApplication.sPrimaryApplicantMiddleName ){
                        this.isMiddleInitialDisabled=true;
                    }
                    this.IsAgreeingToMA34DeclarationConsent =
                        objApplication.bIsNonMagi;
                    this.objApplication = objApplication;
                    this.timeTravelCurrentDate =
                        result.mapResponse.timeTravelTodayDate;
                    if (
                        !utility.isUndefinedOrNull(objApplication) &&
                        !utility.isEmpty(objApplication)
                    ) {
                        if (
                            objApplication.bIsNonMagi &&
                            objApplication.bShowLTCSection
                        ) {
                            this.bShowAgreeingToLTCResourceTransferConsent = true;
                        }
                    }
                    //Start - Added as part of Defect - 377050
                    if (result && result.mapResponse) { 
                        this.selectedRole = result.mapResponse.selectedRole;
                        if (
                            this.selectedRole === constant.userRole.Mail_Center_Worker ||
                            this.selectedRole === constant.userRole.Mail_Center_Supervisor
                        ) {
                            this.isDateReadOnly = false;
                        } else {
                            this.template
                                .querySelector(".ssp-signatureDateClass")
                                .classList.remove("ssp-applicationInputs");
                        }
                    }
                    //End - Added as part of Defect - 377050
                }
            })
            .catch(error => {
                console.error(
                    "Error in Signature Benefit Page while Fetching the Application Record" +
                        JSON.stringify(error)
                );
            });
    };

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.templateInputsValue = elem;
        } catch (error) {
            console.error(
                "Error in getRequiredInputElements of Expedite Benefits Page" +
                    error
            );
        }
    };

    openLinkModal = e => {
         if (
             e.keyCode === constant.learnMoreModal.enterKeyCode ||
             e.type === constant.learnMoreModal.clickLearn
         ) {
        const type = e.currentTarget.dataset.type;
        this.sspStatementOfUnderstanding = false;
        this.sspResourceTransferConsent = false;
        this.sspReadAndAgreeConsent = false;
        this.sspDeclarationOfAnnuities = false;
        this.sspMedicaidPenaltyWarning = false;
        this.sspRightsAndResponsibilities = false;
        this[type] = true;
         }
    };

    /**
     * @function 	: saveData.
     * @description : This function is used to update the Application Data with the User Provided values.
     * */
    saveData = () => {
        try {
            const objApplication = {};
            if (!utility.isUndefinedOrNull(this.allowSaveValue)) {
                //Code to get the Mode of Application
                const sPageURL = decodeURIComponent(
                    window.location.search.substring(1)
                );
                const sURLVariables = sPageURL.split("&");
                let sMode = null;
                if (sURLVariables != null) {
                    for (let i = 0; i < sURLVariables.length; i++) {
                        const sParam = sURLVariables[i].split("=");
                        if (sParam[0] === "mode") {
                            sMode =
                                sParam[1] === undefined
                                    ? "Not found"
                                    : sParam[1];
                        }
                    }
                }
                if (!utility.isUndefinedOrNull(sMode)) {
                    this.sMode = sMode;
                }
                //Below Code is to create the App Json
                    const jsonObjApp = JSON.parse(this.allowSaveValue);
                    objApplication["IsRenewalConsent__c"] =
                        jsonObjApp.sRenewalConsent;
                    objApplication["IsApplicantAgreeToWorkRegister__c"] =
                        jsonObjApp.sAgreeToWork;
                    objApplication["ApplicationEsignFirstName__c"] =
                        jsonObjApp.sFirstName;
                    objApplication["ApplicationEsignMiddleInitial__c"] =
                        jsonObjApp.sMiddleName;
                    objApplication["ApplicationEsignLastName__c"] =
                        jsonObjApp.sLastName;
                    objApplication["ApplicationEsignSuffixCode__c"] =
                        jsonObjApp.sSuffixCode;
                    objApplication["IsRegisteredToVote__c"] =
                        jsonObjApp.sRegisterToVote;
                objApplication["IsAgreeingToKiHippConsent__c"] = this.isAgreeingToKiHippConsentValue;
                objApplication["IsAgreeingToMA34Declaration__c"] = this.isAgreeingToMA34DeclarationValue;
                objApplication["DeclrtnfAnnuitiesAcceptanceCode__c"] = this.IsAnnutiesDeclarationCodeValue;
                objApplication["IsDMSAnnuitiesBeneficiary__c"] = this.IsDMSAnnuitiesBeneficiaryValue;
                objApplication["IsAgreeingToMedicaidPenalty__c"] = this.isAgreeingToMedicaidPenaltyValue;
                objApplication["IsAgreeingToSNAPRightsConsent__c"] = this.isAgreeingToSNAPRightsConsentValue;
                objApplication["IsAgreeingToApplicationConsent__c"] = this.isAgreeingToApplicationConsentValue
                objApplication["IsAgreeingToLTCResourceTransferConsent__c"] = this.isAgreeingToLTCResourceTransferConsentValue;
                //Start - Added as part of Defect - 377050
                const signatureElement = this.template.querySelector(
                    ".ssp-signatureDateClass"
                );
                if (
                    signatureElement &&
                    signatureElement.fieldName === signatureDateFieldAPI &&
                    signatureElement.value !== ""
                ) {
                    objApplication["SignatureDate__c"] = signatureElement.value;
                }
                //End - Added as part of Defect - 377050

                    const record = {
                        recordId: this.appId,
                        fields: objApplication
                    };
                    updateRecord(record)
                                .then(result=>{
                        this.serviceCall = true;
                        this.submitCount = this.submitCount + 1;
                        if (this.serviceCall &&  this.submitCount === 1) {
                            this.invokeSSPDCService(this.serviceCall);
                        }
                                })
                                .catch(error => {
                        this.showSpinner = false;
                                    console.error("error", error);
                                });
            }
        } catch (error) {
            this.showSpinner = false;
            console.error("Error in saveData of Signature Page" + error);
        }
    };
    /**
     * @function : invokeSSPDCService.
     * @description : Function used to Invoke Service Call.
     * @param {callSSPDC}  callSSPDC - CallSSPDC.
     */
    invokeSSPDCService = callSSPDC => {
        if (callSSPDC) {
            invokeSSPDC({
                sApplicationId: this.appId,
                sMode: this.sMode
            })
                .then(response => {
                    if (
                        !utility.isUndefinedOrNull(response.mapResponse) &&
                        !utility.isEmpty(response.mapResponse)
                    ) {
                        if (response.mapResponse.ERROR) {
                            this.showSpinner = false;
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    name: "Eligibility_Results__c"
                                },
                                state: {
                                    applicationId: this.appId
                                }
                            });
                        } else if (
                            !utility.isUndefinedOrNull(
                                response.mapResponse.response
                            ) &&
                            !utility.isEmpty(response.mapResponse.response)
                        ) {
                            this.showSpinner = false;
                            if (
                                JSON.parse(response.mapResponse.response)
                                    .SubmitApplicationResponse.AckResponse
                                    .AckResponseDescription === "Success"
                            ) {
                                //this.isEligibilityResultsLoaded = true;
                                this[NavigationMixin.Navigate]({
                                    type: "comm__namedPage",
                                    attributes: {
                                        name:
                                            "eligibility_results_loading_page__c"
                                    },
                                    state: {
                                        applicationId: this.appId,
                                        mode: this.sMode
                                    }
                                });
                            }
                        } else {
                            this.showSpinner = false;
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    name: "Eligibility_Results__c"
                                },
                                state: {
                                    applicationId: this.appId
                                }
                            });
                        }
                    } else {
                        this.showSpinner = false;
            }
                })
                        .catch(error => {
                    this.showSpinner = false;
                    console.error("error", JSON.stringify(error));
                        });
        }
    };

    /**
     * @function : fetchAppData.
     * @description : Function used to fetch to Application Record.
     * @param {event} event - Event.
     */
    updateToggleFields = event => {
        const type = event.currentTarget.dataset.type;
        this.sspStatementOfUnderstanding = false;
        this.sspResourceTransferConsent = false;
        this.sspReadAndAgreeConsent = false;
        this.sspDeclarationOfAnnuities = false;
        this.sspMedicaidPenaltyWarning = false;
        this.sspRightsAndResponsibilities = false;
        this[type] = true;
        const fieldName = event.detail.sFieldName;
        if (fieldName === "IsAgreeingToMA34Declaration__c") {
            this.isAgreeingToMA34DeclarationRequiredFieldError = null;
            this.isAgreeingToMA34DeclarationErrorText = null;
            this.isAgreeingToMA34DeclarationValue = event.detail.sFieldValue;
            this.IsDMSAnnuitiesBeneficiaryValue = event.detail.IsDMSAnnuitiesBeneficiary;
            this.IsAnnutiesDeclarationCodeValue = event.detail.IsAnnutiesDeclarationCode;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToMA34Declaration = true;
                this.isMA34DeclarationProgressStart = true;
                this.isMA34DeclarationProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToMA34Declaration = true;
                this.isMA34DeclarationProgressStart = true;
                this.isMA34DeclarationProgressComplete = false;
            }
        }
        if (fieldName === "IsAgreeingToApplicationConsent__c") {
            this.isAgreeingToApplicationConsentRequiredFieldError = null;
            this.isAgreeingToApplicationConsentErrorText = null;
            this.isAgreeingToApplicationConsentValue = event.detail.sFieldValue;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToApplicationConsent = true;
                this.isApplicationConsentProgressStart = true;
                this.isApplicationConsentProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToApplicationConsent = true;
                this.isApplicationConsentProgressStart = true;
                this.isApplicationConsentProgressComplete = false;
            }
        }
        if (fieldName === "IsAgreeingToMedicaidPenalty__c") {
            this.isAgreeingToMedicaidPenaltyRequiredFieldError = null;
            this.isAgreeingToMedicaidPenaltyErrorText = null;
            this.isAgreeingToMedicaidPenaltyValue = event.detail.sFieldValue;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToMedicaidPenalty = true;
                this.isMedicaidPenaltyProgressStart = true;
                this.isMedicaidPenaltyProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToMedicaidPenalty = true;
                this.isMedicaidPenaltyProgressStart = true;
                this.isMedicaidPenaltyProgressComplete = false;
            }
        }
        if (fieldName === "IsAgreeingToSNAPRightsConsent__c") {
            this.isAgreeingToSNAPRightsConsentRequiredFieldError = null;
            this.isAgreeingToSNAPRightsConsentErrorText = null;
            this.isAgreeingToSNAPRightsConsentValue = event.detail.sFieldValue;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToSNAPRightsConsent = true;
                this.isSNAPRightsConsentProgressStart = true;
                this.isSNAPRightsConsentProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToSNAPRightsConsent = true;
                this.isSNAPRightsConsentProgressStart = true;
                this.isSNAPRightsConsentProgressComplete = false;
            }
        }
        if (fieldName === "IsAgreeingToLTCResourceTransferConsent__c") {
            this.isAgreeingToLTCResourceTransferConsentRequiredFieldError = null;
            this.isAgreeingToLTCResourceTransferConsentErrorText = null;
            this.isAgreeingToLTCResourceTransferConsentValue = event.detail.sFieldValue;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToLTCResourceTransferConsent = true;
                this.isLTCResourceTransferConsentProgressStart = true;
                this.isLTCResourceTransferConsentProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToLTCResourceTransferConsent = true;
                this.isLTCResourceTransferConsentProgressStart = true;
                this.isLTCResourceTransferConsentProgressComplete = false;
            }
        }
        if (fieldName === "IsAgreeingToKiHippConsent__c") {
            this.isAgreeingToKiHippConsentRequiredFieldError = null;
            this.isAgreeingToKiHippConsentErrorText = null;
            this.isAgreeingToKiHippConsentValue = event.detail.sFieldValue;
            if (event.detail.sFieldValue === constant.toggleFieldValue.yes) {
                this.isAgreeingToKiHippConsent = true;
                this.isKiHippConsentProgressStart = true;
                this.isKiHippConsentProgressComplete = true;
            } else if (
                event.detail.sFieldValue === constant.toggleFieldValue.no
            ) {
                this.isAgreeingToKiHippConsent = true;
                this.isKiHippConsentProgressStart = true;
                this.isKiHippConsentProgressComplete = false;
            }
        }
    };

    /**
     * @function 		: toggleMiCheckbox.
     * @description 	: This method is used to toggle Middle Initial checkbox change.
     * */

    toggleMiCheckbox = () => {
        try {
            this.template.querySelector(".ssp-middleInitialField").value = "";
            this.isDisableMIField = !this.isDisableMIField;
            if (this.isDisableMIField){
                const line1 = this.template.querySelector(
                    ".ssp-middleInitialField"
                );
                line1.ErrorMessageList = [];
                this.template
                    .querySelector(".ssp-middleInitialField")
                    .classList.remove("ssp-applicationInputs");
            } else {
                this.template.querySelector(
                    ".ssp-middleInitialField"
                ).className = "ssp-applicationInputs ssp-middleInitialField";
            }
        } catch (error) {
            console.error("Error in toggle Middle Initial Checkbox");
        }
    };
    /**
     * @function 		: toggleVoteOptions.
     * @description 	: This method is used to toggle Vote Options.
     * @param {event} event - Event.
     * */
    toggleVoteOptions = event => {
        if (event.detail == constant.toggleFieldValue.yes) {
            this.displayNoticeCard = true;
        } else {
            this.displayNoticeCard = false;
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
                "Error in  hideToast" + JSON.stringify(error.message)
            );
        }
    };

    /**
    * @function : constructRenderingMap
    * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
    * @param {string} appPrograms - Application level programs.
    * @param {string} metaValue - Entity mapping data.
    */
     constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                    this.isNotAccessible = securityMatrix.screenPermission === constant.permission.notAccessible;
                }
                if (securityMatrix && securityMatrix.hasOwnProperty("screenPermission") && securityMatrix.screenPermission){
                    this.isReadOnlyUser = securityMatrix.screenPermission === constant.permission.readOnly;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                              "Error in constructRenderingMap", error
                        );
        }
    }
}
