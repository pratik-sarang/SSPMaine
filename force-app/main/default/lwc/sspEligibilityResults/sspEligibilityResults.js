/**
 * Name : SspEligibilityResults.
 * Description : To Show Eligibility Details for household.
 * Author : Saurabh Rathi.
 * Date : 11/02/2020.
 **/
import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspCardBackgroundImage from "@salesforce/resourceUrl/sspCardImages";
import apConstants from "c/sspConstants";
import getEligibilityData from "@salesforce/apex/SSP_EligibilityResultsCtrl.getEligibilityData";
import utility, { formatLabels } from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";

import sspEligibilityResults from "@salesforce/label/c.sspEligibilityResults";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspCaseNumber from "@salesforce/label/c.sspCaseNumber";
import sspThankYouSubmittingApplication from "@salesforce/label/c.sspThankYouSubmittingApplication";
import sspAdditionalActionRequired from "@salesforce/label/c.sspAdditionalActionRequired";
import sspSelectNextSteps from "@salesforce/label/c.sspSelectNextSteps";
import sspPotentiallyEligibleKIHIPP from "@salesforce/label/c.sspPotentiallyEligibleKIHIPP";
import sspCallDCBS from "@salesforce/label/c.sspCallDCBS";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import addMemberLearnMoreTitleText from "@salesforce/label/c.SSP_AddMemberLearnMoreTitleText";
import caseHash from "@salesforce/label/c.SSP_CaseHashcolon";
import callDCBS from "@salesforce/label/c.sspCallDCBS";
import bottomNote from "@salesforce/label/c.SSP_KiHippBottomNote";
import nextStep from "@salesforce/label/c.SSP_NextStep";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import eligibilityResultsThankText from "@salesforce/label/c.SSP_EligibilityResultsThankText";
import eligibilityResultsReviewText from "@salesforce/label/c.SSP_EligibilityResultsReviewText";
import eligibilityResultsNextText from "@salesforce/label/c.SSP_EligibilityResultsNextText";
import noticeCardPhoneNumber from "@salesforce/label/c.SSP_NoticeCardPhoneNumber";
import callText from "@salesforce/label/c.SSP_DcbsCallText";
import submissionSuccessText from "@salesforce/label/c.SSP_SubmissionSuccessText";
import thankForSubmissionText from "@salesforce/label/c.SSP_ThankForSubmissionText";
import unableApplicationResultText from "@salesforce/label/c.SSP_UnableApplicationResultText";
import contactPleaseVisit from "@salesforce/label/c.SSP_ContactPleaseVisit";
import sspFooterContactUs from "@salesforce/label/c.SSP_FooterContactUs";
import contactCustomerService from "@salesforce/label/c.SSP_ContactCustomerService";
import denied from "@salesforce/label/c.SSP_Denied";
import approved from "@salesforce/label/c.SSP_Approved";
import pendingVerification from "@salesforce/label/c.SSP_PendingVerification";
import pendingInterview from "@salesforce/label/c.SSP_PendingInterview";
import additionalVerification from "@salesforce/label/c.SSP_AdditionalVerification";
import completeInterviewReason from "@salesforce/label/c.SSP_CompleteInterviewReason";
import medicaid from "@salesforce/label/c.SSP_Medicaid";
import goDashboard from "@salesforce/label/c.SSP_GoDashboard";
import nextStepAltText from "@salesforce/label/c.SSP_NextStepAltText";
import medicaidText from "@salesforce/label/c.sspMedicaid";
import expeditedSnap from "@salesforce/label/c.SSP_ExpeditedSnap";
import snapLabel from "@salesforce/label/c.SSP_SNAPLabel";
import durationDate from "@salesforce/label/c.SSP_DurationDate";
import approvalReason from "@salesforce/label/c.SSP_ApprovalReason";
import expeditedSnapReason from "@salesforce/label/c.SSP_ExpeditedSnapReason";
import benefitsSubmitted from "@salesforce/label/c.SSP_BenefitsSubmitted";
import sspLearnMore from "@salesforce/label/c.SSP_PreferredPaymentLearnMore";
import kTAP from "@salesforce/label/c.SSP_KTAPLabel";
import stateSupplementation from "@salesforce/label/c.SSP_StateSupplementation";
import sspEligibilityResultsBanner from "@salesforce/label/c.SSP_EligibilityResultsBanner";

export default class SspEligibilityResults extends NavigationMixin(BaseNavFlowPage) {
    label = {
        sspEligibilityResultsBanner,
        sspEligibilityResults,
        sspLearnMoreLink,
        sspCaseNumber,
        sspThankYouSubmittingApplication,
        sspAdditionalActionRequired,
        sspSelectNextSteps,
        sspPotentiallyEligibleKIHIPP,
        sspCallDCBS,
        learnMoreLink,
        addMemberLearnMoreTitleText,
        caseHash,
        callDCBS,
        bottomNote,
        nextStep,
        benefitsApplication,
        eligibilityResultsThankText,
        eligibilityResultsReviewText,
        eligibilityResultsNextText,
        noticeCardPhoneNumber,
        callText,
        submissionSuccessText,
        thankForSubmissionText,
        unableApplicationResultText,
        contactPleaseVisit,
        sspFooterContactUs,
        contactCustomerService,
        goDashboard,
        nextStepAltText,
        medicaidText,
        benefitsSubmitted,
        sspLearnMore,
        expeditedSnapReason
    };

    discStyle = "ssp-appDiscOrange";
    listStyle = "ssp-userCardWidth";
    greenBackground = "ssp-bg_greenAlpha";
    redBackground = "ssp-bg_redAlpha";
    orangeBackground = "ssp-bg_orangeAlpha";
    telephoneNumber = `tel:${noticeCardPhoneNumber}`;
    backgroundUrl = sspCardBackgroundImage + apConstants.url.backgroundImage;
    isProgramInValid = true;
    memberList = [];

    @track programCard = [];
    @track showBottomNote = false;
    @track isNextStep = false;
    @track isRequireAction = false;
    @track showNextSteps = false;
    @track nextStepsData;
    @track underReview = false;
    @track notUnderReview = false;
    @track showToast = false;
    @track showEligibility = false;
    @track showSpinner = false;
    @track caseNumber;
    @track isLearnMoreModal;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track modValue;
    @track reference = this;
    @track isEligibleForExpeditedSNAP = false;
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isNextStepsNotAccessible = false; //CD2 2.5 Security Role Matrix.
    @track isNextStepsShowAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track isInfoModalNotAccessible = false; //CD2 2.5 Security Role Matrix.
    @track isReadOnlyInfoModal = false; //CD2 2.5 Security Role Matrix.
    @track isRFI;
    @track isBannerTextVisible = false;
    @track showReportedPolicyNote ;// Added for KI-HIPP Enhancement 
    @track showVerificationText;

    get screenRenderingStatus () {
        if (this.isNotAccessible){
            return true;
        }
        return this.showNextSteps;
    }

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
    /**
     * @function - renderedCallback
     * @description - This method is used to called whenever there is track variable changing.

     */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.showHelpContentData("SSP_APP_Details_EligibilityResults");
            const sPageURL = decodeURIComponent(
                window.location.search.substring(1)
            );
            const sURLVariables = sPageURL.split("&");
            let applicationId = null;
            if (sURLVariables != null) {
                for (let i = 0; i < sURLVariables.length; i++) {
                    const sParam = sURLVariables[i].split("=");
                    if (sParam[0] === "applicationId") {
                        applicationId =
                            sParam[1] === undefined ? "Not found" : sParam[1];
                    }
                }
            }

            /**
             * @function : getEligibilityData
             * @description : This api method is called get the data for programs.
             */
            getEligibilityData({
                sApplicationId: applicationId
            })
                .then(result => {
                    this.showToast = true;
                    if (result.bIsSuccess){
                        this.constructRenderingAttributes(result);  //2.5 Security Role Matrix and Program Access (securityMatrixEligibility, securityMatrixNextSteps )
                        if(result.isRFI){
                            this.isRFI = true;
                        }
                        else{
                            this.isRFI = false;
                        }
                        // Added for CR-1061
                        if(result.isBannerShow){
                            this.isBannerTextVisible= true;
                        }else{
                            this.isBannerTextVisible= false;
                        }
                        //End for CR-1061

                          // change for KI-HIPP Enhancement CR 6.11.2
                          if(result.showReportedPolicyNote){
                            this.showReportedPolicyNote = result.showReportedPolicyNote; 
                         }
                           // end change for KI-HIPP Enhancement CR 6.11.2

                           if(result.showVerificationText){
                               this.showVerificationText= result.showVerificationText;
                           }
                    }
                    if (result.bIsSuccess && !result.underReview) {
                        this.showSpinner = false;
                        this.notUnderReview = true;
                        this.nextStepsData = result.nextStepData;
                        this.programCard = JSON.parse(result.eligibilityData);
                        this.caseNumber = `${caseHash} ${result.caseNumber}`;
                        this.programCard = this.programCard.map(currentItem => {
                            currentItem.style = "ssp-nonMedicaidList";
                            currentItem.lstMemberRecords.map(item => {
                                this.memberList.push(item);
                                if (
                                    item.BenefitStatusCode.includes(
                                        apConstants.eligibilityStatus.denied
                                    )
                                ) {
                                    item.BenefitStatus = denied;
                                    item.additionalNotes = item.DenialReason
                                        ? item.DenialReason.replace(/\?/g, "")
                                        : "";
                                    item.iconStyle = `${this.discStyle} ${this.redBackground}`;
                                } else if (
                                    item.BenefitStatusCode.includes(
                                        apConstants.eligibilityStatus.approved
                                    )
                                ) {
                                    item.BenefitStatus = approved;
                                    item.additionalNotes = `${formatLabels(
                                        durationDate,
                                        [
                                            utility.getNewFormatDate(item.BenefitBeginDate
                                                ? item.BenefitBeginDate
                                                : ""),
                                                utility.isUndefinedOrNull(item.BenefitEndDate) ? "Ongoing" : utility.getNewFormatDate(item.BenefitEndDate)
                                        ]
                                    )}<br>${approvalReason}`;
                                    item.iconStyle = `${this.discStyle} ${this.greenBackground}`;
                                } else if (
                                    item.BenefitStatusCode.includes(
                                        apConstants.eligibilityStatus
                                            .pendingVerification
                                    )
                                ) {
                                    item.BenefitStatus = pendingVerification;
                                    item.additionalNotes = additionalVerification;
                                    item.iconStyle = `${this.discStyle} ${this.orangeBackground}`;
                                    this.isNextStep = true;
                                    this.isRequireAction = true;
                                } else {
                                    item.BenefitStatus = pendingInterview;
                                    item.additionalNotes = completeInterviewReason;
                                    item.iconStyle = `${this.discStyle} ${this.orangeBackground}`;
                                    this.isNextStep = true;
                                    this.isRequireAction = true;
                                }
                                return item;
                            });

                            if (
                                (currentItem.sProgramCode ===
                                    stateSupplementation ||
                                    currentItem.sProgramCode === medicaid) &&
                                currentItem.lstMemberRecords.length > 1
                            ) {
                                currentItem.style = this.listStyle;
                            }
                            if (currentItem.sProgramCode === medicaid) {
                                this.showBottomNote = currentItem.lstMemberRecords.some(
                                    item => {
                                        item.BenefitStatus =
                                            item.BenefitStatus !== denied
                                                ? `${item.BenefitStatus} / ${medicaidText}`
                                                : item.BenefitStatus;
                                        if (!this.isNextStep) {
                                            this.isNextStep =
                                                item.IsReferredToFFM === true;
                                        }
                                        return item.EligibleForKIHIPP === true;
                                    }
                                );
                            }
                            if (
                                (currentItem.sProgramCode === kTAP || currentItem.sProgramCode === snapLabel) &&
                                currentItem.lstMemberRecords.length > 1
                            ) {
                                currentItem.style = this.listStyle;
                            }

                            if (currentItem.sProgramCode === snapLabel) {
                                currentItem.lstMemberRecords.map(item => {
                                    if (
                                        item.BenefitStatus !== denied &&
                                        item.BenefitStatus !== approved &&
                                        item.EligibleForExpeditedSNAP
                                    ) {
                                        item.additionalNotes2 = expeditedSnapReason;
                                        item.isEligibleForExpeditedSNAP = true;
                                    }
                                    item.BenefitStatus = item.EligibleForExpeditedSNAP
                                        ? `${item.BenefitStatus} / ${expeditedSnap}`
                                        : item.BenefitStatus;
                                    return item;
                                });
                            }
                            return currentItem;
                        });
                        if (
                            !this.isNextStep &&
                            this.nextStepsData.additionalPrograms.length > 0
                        ) {
                            this.isNextStep = this.memberList.every(
                                item =>
                                    item.BenefitStatusCode ===
                                        apConstants.eligibilityStatus
                                            .approved ||
                                    item.BenefitStatusCode ===
                                        apConstants.eligibilityStatus.denied
                            );
                        }
                    } else if (result.bIsSuccess && result.underReview) {
                        this.showSpinner = false;
                        this.underReview = result.underReview;
                        if (
                            result.RecordType === "Case" &&
                            result.caseNumber != null &&
                            result.caseNumber != undefined
                        ) {
                            this.label.submissionSuccessText = formatLabels(
                                this.label.submissionSuccessText,
                                [result.caseNumber]
                            );
                        } else {
                            this.label.submissionSuccessText = formatLabels(
                                this.label.submissionSuccessText,
                                [result.applicationNumber]
                            );
                        }
                    } else {
                        this.showSpinner = false;
                        this.errorMsg = result.error;
                        this.showErrorModal = true;
                        this.isNotAccessible = false;
                    }
                })
                .catch(error => {
                    console.error("Error in getEligibilityData" + JSON.stringify(error.message));
                });
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }

    /**
     * @function : handleNextButton
     * @description : This method used to move to next step screen.
     */
    handleNextButton () {
        try {
            if (this.isNextStep) {
                this.showNextSteps = true;
                this.showAccessDeniedComponent = false;
            } else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",

                    attributes: {
                        name: apConstants.eligibilityStatus.dashboardUrl
                    }
                });
            }
        } catch (error) {
            console.error("Error in handleNextButton", error);
        }
    }
    openLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = true;
        } catch (error) {
            console.error(
                "Error in openLearnMoreModal:" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error(
                "Error in closeLearnMoreModal:" + JSON.stringify(error.message)
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
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };
    formatDate (inputDate) {
         try {
            const date = new Date(inputDate);
            if (!isNaN(date.getTime())) {
                const day = date.getDate().toString();
                const month = (date.getMonth() + 1).toString();
                return (month[1] ? month : "0" + month[0]) + "/" +
                   (day[1] ? day : "0" + day[0]) + "/" + 
                   date.getFullYear();
            } else {
                return "";
            }
         } catch (error) {
            console.error(
                "Error in formatDate:" + JSON.stringify(error.message)
            );
         }
    }

    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
    constructRenderingAttributes = response => {
        try{
            if (response != null && response != undefined && response.hasOwnProperty("securityMatrixEligibility")) {
                const { securityMatrixEligibility } = response;
                //code here
                if (!securityMatrixEligibility || !securityMatrixEligibility.hasOwnProperty("screenPermission") || !securityMatrixEligibility.screenPermission) {
                    this.isNotAccessible = false;
                }
                else {
                    this.isNotAccessible = securityMatrixEligibility.screenPermission === apConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                this.isReadOnlyUser =
                    !utility.isUndefinedOrNull(securityMatrixEligibility) &&
                !utility.isUndefinedOrNull(securityMatrixEligibility.screenPermission) &&
                securityMatrixEligibility.screenPermission === apConstants.permission.readOnly;
            }
            if (response != null && response != undefined && response.hasOwnProperty("securityMatrixNextSteps")) {
                const { securityMatrixNextSteps } = response;
                if (!securityMatrixNextSteps || !securityMatrixNextSteps.hasOwnProperty("screenPermission") || !securityMatrixNextSteps.screenPermission) {
                    this.isNextStepsNotAccessible  = false;
                }
                else {
                    this.isNextStepsNotAccessible  = securityMatrixNextSteps.screenPermission === apConstants.permission.notAccessible;
                }
                if (this.isNextStepsNotAccessible ) {
                    this.isNextStepsShowAccessDeniedComponent  = true;
                }
            }
            if (response != null && response != undefined && response.hasOwnProperty("securityMatrixHelpAndInformation")) {
                const { securityMatrixHelpAndInformation } = response;

                this.isReadOnlyInfoModal = securityMatrixHelpAndInformation.screenPermission === apConstants.permission.readOnly;

                if (!securityMatrixHelpAndInformation || !securityMatrixHelpAndInformation.hasOwnProperty("screenPermission") || !securityMatrixHelpAndInformation.screenPermission) {
                    this.isInfoModalNotAccessible  = false;
                }
                else {
                    this.isInfoModalNotAccessible  = securityMatrixHelpAndInformation.screenPermission === apConstants.permission.notAccessible;
                }
            }
        }
        catch(error){
            console.error(
                JSON.stringify(error.message)
            );
        }
    }
    
    /**
         * @function - navigateToContactPage.
         * @description - Method to navigate to Contact Us Landing Page.
         */
        navigateToContactUsPage = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: apConstants.communityPageNames.helpArticles
                },
                state: { 
                    helpCategory: "Contact us"
                }
            });
        } catch (error) {
            console.error(
                "Error in navigateToContactUsPage:" + JSON.stringify(error.message)
            );
        }
    };

}
