import { track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspCardImages from "@salesforce/resourceUrl/sspCardImages";

import sspYes from "@salesforce/label/c.SSP_Yes";
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

import sspPastApplications from "@salesforce/label/c.SSP_PastApplications";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspDateSigned from "@salesforce/label/c.sspDateSigned";
import sspSignedBy from "@salesforce/label/c.sspSignedBy";
import sspAgreementSignature from "@salesforce/label/c.sspAgreementSignature";
import fetchSignatureData from "@salesforce/apex/SSP_AgreementAndSignatureController.fetchSignatureData";
import sspUtility from "c/sspUtility";

import constant from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

export default class SspAgreementSignaturePage extends NavigationMixin(
    BaseNavFlowPage
) {
    @track label = {
        sspAgreementSignature,
        sspSignedBy,
        sspDateSigned,
        sspApplicationHash,
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
        sspPastApplications,
        sspYes
    };

    @track applicationNumber; // = "123456789";
    @track signedBy; // = "John Doe";
    @track dateSigned; // = "05/03/2019";
    @track applicationId = 1234567;

    @track fieldDisabled = true;
    @track buttonDisabled = false;

    @track isApplicationConsentProgressStart = true;
    @track isApplicationConsentProgressComplete = false;
    @track additionalInfoSnap = true;
    @track additionalInfoKTAP = true;
    @track additionalInfoMedicaid = true;
    @track bShowStatementOfUnderstanding = false;
    @track sspStatementOfUnderstanding = false;

    @track isMedicaidPenaltyProgressStart = true;
    @track isMedicaidPenaltyProgressComplete = false;
    @track sspMedicaidPenaltyWarning = false;
    @track bShowAgreeingToMedicaidPenalty = false;

    @track bShowAgreeingToSNAPRightsConsent = false;
    @track isSNAPRightsConsentProgressStart = true;
    @track isSNAPRightsConsentProgressComplete = false;
    @track sspRightsAndResponsibilities = false;
    @track isAgreeingToSNAPRightsConsent = false;

    @track bShowAgreeingToLTCResourceTransferConsent = false;
    @track isLTCResourceTransferConsentProgressStart = true;
    @track isLTCResourceTransferConsentProgressComplete = false;
    @track sspResourceTransferConsent = false;
    @track isAgreeingToLTCResourceTransferConsent = false;
    @track LTCConsentName; // = "John Doe";

    @track sspDeclarationAnnuities = false;
    @track isMA34DeclarationProgressStart = true;
    @track isMA34DeclarationProgressComplete = false;
    @track sspModalDeclarationOfAnnuities = false;
    @track isAgreeingToMA34Declaration = false;

    @track bShowAgreeingToKIHIPPConsent = false;
    @track isKIHIPPConsentProgressStart = true;
    @track isKIHIPPConsentProgressComplete = false;
    @track sspReadAndAgreeConsent = false;
    @track isAgreeingToKIHIPPConsent = false;

    //Agree to work register toggle
    @track sspDoesThePrimaryYesBtn = false;
    @track sspDoesThePrimaryNoBtn = false;
    @track bWorkRegister = false;

    //Authorize Benefits Renewal toggle
    @track sspDoYouAuthorizeYesBtn = false;
    @track sspDoYouAuthorizeNoBtn = false;
    @track bRenewal = false;

    //Register to vote toggle
    @track sspRegisterToVoteNoBtn = true;
    @track sspRegisterToVoteYesBtn = false;
    @track bRegisterToVote = false;

    @track showScreen;
    @track showAccessDenied;
    @track application={};
    @track showSpinner;
    @track applicationId;

    backgroundImg = sspCardImages + constant.url.backgroundImage;

    openLinkModal = e => {
        // this.sspStatementOfUnderstanding = true;
        // this.isAgreeingToApplicationConsent = true;
        if (
            e.keyCode === constant.learnMoreModal.enterKeyCode ||
            e.type === constant.learnMoreModal.clickLearn
        ) {
            const type = e.currentTarget.dataset.type;
            this.sspStatementOfUnderstanding = false;
            this.sspResourceTransferConsent = false;
            this.sspReadAndAgreeConsent = false;
            this.sspModalDeclarationOfAnnuities = false;
            this.sspMedicaidPenaltyWarning = false;
            this.sspRightsAndResponsibilities = false;
            this[type] = true;
        }
    };
    additionalInfoSnap;

    updateToggleFields = event => {
        const type = event.currentTarget.dataset.type;
        this.sspStatementOfUnderstanding = false;
        this.sspResourceTransferConsent = false;
        this.sspReadAndAgreeConsent = false;
        this.sspModalDeclarationOfAnnuities = false;
        this.sspMedicaidPenaltyWarning = false;
        this.sspRightsAndResponsibilities = false;
        this[type] = true;
    };

    connectedCallback () {
        try {
            this.showSpinner = true;
            const url = new URL(window.location.href);
            this.applicationId = url.searchParams.get("appId");
            fetchSignatureData({
                appId:this.applicationId //"600000855"
            })
                .then(result => {
                    const parsedData = result.mapResponse;
                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty("ERROR")
                    ) {
                        console.error(
                            "failed to load signature page" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        if (parsedData.hasOwnProperty("resultString")) {
                            this.application = JSON.parse(parsedData.resultString);
                            this.applicationNumber = this.application.ApplicationNumber;
                            this.signedBy =
                                this.application.ApplicationEsignFirstName +
                                " " +
                                this.application.ApplicationEsignLastName;
                            this.dateSigned = this.application.submittedDate;
                            
                            if(!sspUtility.isUndefinedOrNull(this.application.additionalInfoKTAP)){
                                this.additionalInfoKTAP = this.application.additionalInfoKTAP;
                            }
                            if(!sspUtility.isUndefinedOrNull(this.application.additionalInfoMedicaid)){
                                this.additionalInfoMedicaid = this.application.additionalInfoMedicaid;
                            }
                            if(!sspUtility.isUndefinedOrNull(this.application.additionalInfoSnap)){
                                this.additionalInfoSnap = this.application.additionalInfoSnap;
                            }
                            
                            //Statement of understanding
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToApplicationConsent
                                )
                            ) {
                                this.bShowStatementOfUnderstanding = true;
                                if (
                                    this.application
                                        .IsAgreeingToApplicationConsent ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isApplicationConsentProgressComplete = true;
                                } else if (
                                    this.application
                                        .IsAgreeingToApplicationConsent ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isApplicationConsentProgressComplete = false;
                                }
                            }
                            //Medicaid Penalty Warning
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToMedicaidPenalty
                                )
                            ) {
                                this.bShowAgreeingToMedicaidPenalty = true;
                                if (
                                    this.application
                                        .IsAgreeingToMedicaidPenalty ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isMedicaidPenaltyProgressComplete = true;
                                } else if (
                                    this.application
                                        .IsAgreeingToMedicaidPenalty ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isMedicaidPenaltyProgressComplete = false;
                                }
                            }

                            //SNAP Rights & Responsibilities
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToSNAPRightsConsent
                                )
                            ) {
                                this.bShowAgreeingToSNAPRightsConsent = true;
                                if (
                                    this.application
                                        .IsAgreeingToSNAPRightsConsent ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isSNAPRightsConsentProgressComplete = true;
                                } else if (
                                    this.application
                                        .IsAgreeingToSNAPRightsConsent ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isSNAPRightsConsentProgressComplete = false;
                                }
                            }

                            //LTC Resource Transfer Consent
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToLTCResourceTransferConsent
                                )
                            ) {
                                this.bShowAgreeingToLTCResourceTransferConsent = true;
                                if (
                                    this.application
                                        .IsAgreeingToLTCResourceTransferConsent ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isLTCResourceTransferConsentProgressComplete = true;
                                    this.LTCConsentName =
                                        this.application
                                            .ApplicationEsignFirstName +
                                        " " +
                                        this.application
                                            .ApplicationEsignLastName;
                                } else if (
                                    this.application
                                        .IsAgreeingToLTCResourceTransferConsent ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isLTCResourceTransferConsentProgressComplete = false;
                                }
                            }

                            //MA 34 - Declaration of Annuities
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToMA34Declaration
                                )
                            ) {
                                this.sspDeclarationAnnuities = true;
                                if (
                                    this.application
                                        .IsAgreeingToMA34Declaration ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isMA34DeclarationProgressComplete = true;
                                } else if (
                                    this.application
                                        .IsAgreeingToMA34Declaration ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isMA34DeclarationProgressComplete = false;
                                }
                            }

                            //KI-HIPP Consent
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsAgreeingToKiHippConsent
                                )
                            ) {
                                this.bShowAgreeingToKIHIPPConsent = true;
                                if (
                                    this.application
                                        .IsAgreeingToKiHippConsent ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.isKIHIPPConsentProgressComplete = true;
                                } else if (
                                    this.application
                                        .IsAgreeingToKiHippConsent ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.isKIHIPPConsentProgressComplete = false;
                                }
                            }

                            //benefits renewal question rendering
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application.IsRenewalConsent
                                )
                            ) {
                                this.bRenewal = true;
                                if (
                                    this.application.IsRenewalConsent ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.sspDoYouAuthorizeYesBtn = true;
                                    this.sspDoYouAuthorizeNoBtn = false;
                                } else if (
                                    this.application.IsRenewalConsent ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.sspDoYouAuthorizeYesBtn = false;
                                    this.sspDoYouAuthorizeNoBtn = true;
                                }
                            }

                            //agree to work register question rendering
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application
                                        .IsApplicantAgreeToWorkRegister
                                )
                            ) {
                                this.bWorkRegister = true;
                                if (
                                    this.application
                                        .IsApplicantAgreeToWorkRegister ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.sspDoesThePrimaryYesBtn = true;
                                    this.sspDoesThePrimaryNoBtn = false;
                                } else if (
                                    this.application
                                        .IsApplicantAgreeToWorkRegister ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.sspDoesThePrimaryYesBtn = false;
                                    this.sspDoesThePrimaryNoBtn = true;
                                }
                            }

                            //register to vote question rendering
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    this.application.IsRegisteredToVote
                                )
                            ) {
                                this.bRegisterToVote = true;
                                if (
                                    this.application.IsRegisteredToVote ===
                                    constant.toggleFieldValue.yes
                                ) {
                                    this.sspRegisterToVoteYesBtn = true;
                                    this.sspRegisterToVoteNoBtn = false;
                                } else if (
                                    this.application.IsRegisteredToVote ===
                                    constant.toggleFieldValue.no
                                ) {
                                    this.sspRegisterToVoteYesBtn = false;
                                    this.sspRegisterToVoteNoBtn = true;
                                }
                            }

                        }
                    }
                    if (parsedData.hasOwnProperty("showScreen") && parsedData.showScreen) {
                        this.showScreen = true;
                    }else{
                        this.showAccessDenied = true;
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error("Error : " + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error in connectedCallBack:" + JSON.stringify(error)
            );
        }
    }
    returnToPastApplication () {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "past_applications__c"
            }
        });
    }
}
