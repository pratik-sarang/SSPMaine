import { api, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspUtility from "c/sspUtility";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

//  - - - SNAP Card Labels - -
import sspIndividualNames from "@salesforce/label/c.sspIndividuaNames";
import sspBenefitPeriod from "@salesforce/label/c.sspBenefitPeriod";
import sspAllotment from "@salesforce/label/c.sspAllotment";
import sspCardFundsLoadedOn from "@salesforce/label/c.sspCardFundsLoadedOn";
import sspRenewalDate from "@salesforce/label/c.sspRenewalDate";
// import sspEligibilityNotice from "@salesforce/label/c.sspEligibilityNotice";
import sspYouOweForSnapBenefits from "@salesforce/label/c.sspYouOweForSnapBenefits";
import sspPayBalance from "@salesforce/label/c.SSP_PayBalance";
import sspYouMaySetupRepaymentAgreement from "@salesforce/label/c.sspYouMaySetupRepaymentAgreement";
import sspAdditionalVerification from "@salesforce/label/c.SSP_AdditionalVerification";
import sspDocumentsDueBy from "@salesforce/label/c.sspDocumentsDueBy";
import sspCompleteInterviewDCBS from "@salesforce/label/c.sspCompleteInterviewDCBS";
import sspYourEligibilityDetermination from "@salesforce/label/c.sspYourEligibilityDetermination";
import sspApplicationSubmitted from "@salesforce/label/c.sspApplicationSubmitted";
import sspEffectiveDate from "@salesforce/label/c.sspEffectiveDate";
import sspReason from "@salesforce/label/c.SSP_MedicalSupportEnforcementReasonText";
import sspViewDenialNotice from "@salesforce/label/c.sspViewDenialNotice";
import sspUploadDocuments from "@salesforce/label/c.SSP_UploadDocuments";
//  - - Child Care Card Labels - -
import sspFamilyAssessedCoPay from "@salesforce/label/c.sspFamilyAssessedCoPay";
import sspCoPayEffectiveFrom from "@salesforce/label/c.sspCoPayEffectiveFrom";
import sspActivePendingEnrollments from "@salesforce/label/c.sspActivePendingEnrollments";
import sspViewDetails from "@salesforce/label/c.sspViewDetails";
import sspVisitContactDCBSOffice from "@salesforce/label/c.sspVisitContactDcbsOffice";
//  - - Ki-HIPP Labels - -
import sspPreferredPaymentPolicyHolder from "@salesforce/label/c.SSP_PreferredPaymentPolicyHolder";
import sspInsuranceCompany from "@salesforce/label/c.SSP_InsuranceCompany";
import sspPlanName from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyId";
import sspViewPaymentSummary from "@salesforce/label/c.sspViewPaymentSummary";
import sspManagePreferredPayment from "@salesforce/label/c.sspManagePrefferedPayment";
import sspType from "@salesforce/label/c.SSP_Type";
import sspPatientLiability from "@salesforce/label/c.sspPatientLiability";
import sspEligibilityWaiverPrograms from "@salesforce/label/c.sspEligilityWaiverPrograms";
import sspProgramSuspended from "@salesforce/label/c.sspProgramSuspended";
import sspOneActivePenalty from "@salesforce/label/c.sspOneActivePenaty";
import sspViewPenalty from "@salesforce/label/c.sspViewPenalty";
import { formatLabels } from "c/sspUtility";
import sspReferralMadeToFFM from "@salesforce/label/c.sspRefferalMadeToFFM";
import sspPhoneNumber from "@salesforce/label/c.SSP_FooterBenefindContactNumber";
import sspVisitHealthCare from "@salesforce/label/c.SSP_VisitHealthcare";
import sspViewSuspension from "@salesforce/label/c.sspViewSuspension";
import sspPhoneNumber2 from "@salesforce/label/c.sspPhoneNumber2";
import sspRequestMedicaidCard from "@salesforce/label/c.sspRequestMedicaidCard";
import sspViewEligibilityNotice from "@salesforce/label/c.sspViewEligibilityNotice";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import sspDollarSign from "@salesforce/label/c.sspDollarSign";

import sspApproved from "@salesforce/label/c.SSP_Approved";
import sspUnderReview from "@salesforce/label/c.SSP_UnderReview";
import sspDenied from "@salesforce/label/c.SSP_Denied";
import sspPendingVerification from "@salesforce/label/c.SSP_PendingVerification";
import sspPendingInterview from "@salesforce/label/c.SSP_PendingInterview";
import sspDiscontinued from "@salesforce/label/c.SSP_Discontinued";
// SSO Redirect
import validateSSORedirect from "@salesforce/apex/SSP_Utility.validateSSORedirect";

export default class SspBenefitsPageProgramCard extends NavigationMixin(
    BaseNavFlowPage
) {
    @api program = {};
    @api key;
    @api caseNumber;
    @api isHeadOfHousehold = false;
    @api isChangeMode = false;
    @api isJORITWIST = false;
    @api isTMember = false;
    @api renderingMap = {}; // CD2 2.5 Security Role Matrix.

    @track openDropDown = false;

    @track showSpinner = true;
    @track showBenefitPeriod = false;
    @track benefitPeriod;
    @track showAllotment = false;
    @track allotmentMonthVSAmount = [];
    @track showEBTFundLoadDate = false;
    @track EBTFundLoadDate;
    @track showRenewalDueDate = false;
    @track renewalDueDate;
    @track showEligibilityNotice = false;
    @track showSNAPClaimAmount = false;
    @track SNAPClaimAmount;
    @track showAdditionalVerificationNeeded = false;
    @track documentUploadDueDate;
    @track showAskForInterview = false;
    @track showReviewDate = false;
    @track reviewDate = false;
    @track showApplicationSubmissionDate = false;
    @track applicationSubmissionDate;
    @track showEffectiveDate = false;
    @track effectiveDate;
    @track showDenialReason = false;
    @track reason;
    @track showCoPay = false;
    @track coPayMonthVSAmount = [];
    @track showCoPayEffectiveDate = false;
    @track coPayEffectiveDate;
    @track showDenialNotice = false;
    @track CCEnrollmentsList = [];
    @track showCCEnrollmentsList = false;
    @track enrollmentLabelsList = [];
    @track DMSId = "";

    needsReviewIconUrl = sspIcons + apConstants.url.needsReviewIcon;
    
    labels = {
        sspIndividualNames,
        sspBenefitPeriod,
        sspAllotment,
        sspCardFundsLoadedOn,
        sspRenewalDate,
        sspYouOweForSnapBenefits,
        sspPayBalance,
        sspYouMaySetupRepaymentAgreement,
        sspAdditionalVerification,
        sspUploadDocuments,
        sspDocumentsDueBy,
        sspCompleteInterviewDCBS,
        sspYourEligibilityDetermination,
        sspApplicationSubmitted,
        sspEffectiveDate,
        sspReason,
        sspViewDenialNotice,
        sspFamilyAssessedCoPay,
        sspCoPayEffectiveFrom,
        sspActivePendingEnrollments,
        sspViewDetails,
        sspVisitContactDCBSOffice,
        sspPreferredPaymentPolicyHolder,
        sspInsuranceCompany,
        sspPlanName,
        sspViewPaymentSummary,
        sspManagePreferredPayment,

        sspType,
        sspPatientLiability,
        sspEligibilityWaiverPrograms,
        sspProgramSuspended,
        sspOneActivePenalty,
        sspViewPenalty,
        sspReferralMadeToFFM,
        sspPhoneNumber,
        sspVisitHealthCare,
        sspViewSuspension,
        sspPhoneNumber2,
        sspRequestMedicaidCard,
        sspViewEligibilityNotice,
        sspDollarSign
    };

    /**
     * @function 		: programName.
     * @description 	: method for programName.
     **/
    get programName () {
        return this.program.programCode || this.program.ProgramCode;
    }

    /**
     * @function 		: individualName.
     * @description 	: method for individualName.
     **/
    get individualName () {
        return this.program.fullName || this.program.IndividualName;
    }

    /**
     * @function 		: programStatus.
     * @description 	: method for programStatus.
     **/
    get programStatus () {
        let programCode;
        let status;
        if (!sspUtility.isUndefinedOrNull(this.program.benefitCombined)) {
            programCode = this.program.benefitCombined.ProgramStatusCode;
        } else if (
            !sspUtility.isUndefinedOrNull(this.program.ProgramStatusCode)
        ) {
            programCode = this.program.ProgramStatusCode;
        }
        if (programCode === "AP") {
            status = sspApproved;
        } else if (programCode === "DN") {
            status = sspDenied;
        } else if (programCode === "PE") {
            status = sspPendingVerification;
        } else if (programCode === "PI") {
            status = sspPendingInterview;
        } else if (programCode === "DC") {
            status = sspDiscontinued;
        } else if (programCode === "UR") {
            status = sspUnderReview;
        } else {
            status = programCode;
        }
        return status;
    }

    /**
     * @function 		: showGreenDisc.
     * @description 	: method for showGreenDisc.
     **/
    get showGreenDisc () {
        return this.programStatus === sspApproved;
    }
    /**
     * @function 		: showRedDisc.
     * @description 	: method for showRedDisc.
     **/
    get showRedDisc () {
        return (
            this.programStatus === sspDenied ||
            this.programStatus === sspDiscontinued
        );
    }
    /**
     * @function 		: showOrangeDisc.
     * @description 	: method for showOrangeDisc.
     **/
    get showOrangeDisc () {
        return (
            this.programStatus === sspPendingInterview ||
            this.programStatus === sspPendingVerification ||
            this.programStatus === sspUnderReview
        );
    }

    /**
     * @function 		: connectedCallback.
     * @description 	: method for connectedCallback.
     **/
    connectedCallback () {

        if (!sspUtility.isUndefinedOrNull(this.program)) {
            //Check if additional filter needed for SNAP, KTAP programs
            //For SNAP, KTAP, CC
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.BenefitBeginDate
                ) &&
                this.programStatus === sspApproved
            ) {
                this.showBenefitPeriod = true;
                const beginDate = sspUtility.getNewFormatDate(this.program.benefitCombined.BenefitBeginDate);
                    const endDate = !sspUtility.isUndefinedOrNull(
                        this.program.benefitCombined.BenefitEndDate
                    ) ? sspUtility.getNewFormatDate(this.program.benefitCombined.BenefitEndDate):"Ongoing";

                this.benefitPeriod = beginDate + " - " + endDate;
            }

            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentMonth1
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentAmountMonth1
                ) &&
                this.programStatus === sspApproved &&
                (this.program.isSNAPProgram ||
                    this.program.isKTAPProgram ||
                    this.program.isKinshipProgram)
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.AllotmentMonth1;
                obj.amount = this.program.benefitCombined.AllotmentAmountMonth1;
                this.allotmentMonthVSAmount.push(obj);
                this.showAllotment = true;
            }
            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentMonth2
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentAmountMonth2
                ) &&
                this.programStatus === sspApproved &&
                (this.program.isSNAPProgram ||
                    this.program.isKTAPProgram ||
                    this.program.isKinshipProgram)
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.AllotmentMonth2;
                obj.amount = this.program.benefitCombined.AllotmentAmountMonth2;
                this.allotmentMonthVSAmount.push(obj);
                this.showAllotment = true;
            }
            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentMonth3
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.AllotmentAmountMonth3
                ) &&
                this.programStatus === sspApproved &&
                (this.program.isSNAPProgram ||
                    this.program.isKTAPProgram ||
                    this.program.isKinshipProgram)
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.AllotmentMonth3;
                obj.amount = this.program.benefitCombined.AllotmentAmountMonth3;
                this.allotmentMonthVSAmount.push(obj);
                this.showAllotment = true;
            }

            //For CC
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayMonth1
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayAmountMonth1
                ) &&
                this.programStatus === sspApproved &&
                this.program.isCCProgram
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.CopayMonth1;
                obj.amount = this.program.benefitCombined.CopayAmountMonth1;
                this.coPayMonthVSAmount.push(obj);
                this.showCoPay = true;
            }
            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayMonth2
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayAmountMonth2
                ) &&
                this.programStatus === sspApproved &&
                this.program.isCCProgram
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.CopayMonth2;
                obj.amount = this.program.benefitCombined.CopayAmountMonth2;
                this.coPayMonthVSAmount.push(obj);
                this.showCoPay = true;
            }
            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayMonth3
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayAmountMonth3
                ) &&
                this.programStatus === sspApproved &&
                this.program.isCCProgram
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.CopayMonth3;
                obj.amount = this.program.benefitCombined.CopayAmountMonth3;
                this.coPayMonthVSAmount.push(obj);
                this.showCoPay = true;
            }

            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.EBTCardFundLoadDate
                ) &&
                this.programStatus === sspApproved
            ) {
                this.showEBTFundLoadDate = true;
                this.EBTFundLoadDate = sspUtility.getNewFormatDate(this.program.benefitCombined.EBTCardFundLoadDate);
            }

            //For SNAP, KTAP, CC
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.RenewalDueDate
                ) &&
                this.programStatus === sspApproved
            ) {
                this.showRenewalDueDate = true;
                this.renewalDueDate = sspUtility.getNewFormatDate(this.program.benefitCombined.RenewalDueDate);
            }

            //For CC
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.CopayEffectiveDate
                ) &&
                this.programStatus === sspApproved &&
                this.program.isCCProgram
            ) {
                this.showCoPayEffectiveDate = true;
                this.coPayEffectiveDate = sspUtility.getNewFormatDate(this.program.benefitCombined.CopayEffectiveDate);
            }

            //For CC
            if (
                this.program.CCWrapperList.length > 0 &&
                this.programStatus === sspApproved &&
                this.program.isCCProgram
            ) {
                this.CCEnrollmentsList = this.program.CCWrapperList;
                this.showCCEnrollmentsList = true;
                //Siddarth to create Custom Label for it.
                const enrollmentLabel = this.labels.sspActivePendingEnrollments;
                for (const element of this.CCEnrollmentsList) {
                    const formatted = formatLabels(enrollmentLabel, [
                        element.fullName,
                        element.activeEnrollments,
                        element.pendingEnrollments
                    ]);
                    this.enrollmentLabelsList.push({
                        label: formatted,
                        individualId: element.individualId
                    });
                }
            }

            //For SNAP, KTAP, CC
            if (
                this.programStatus === sspApproved &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DMSDocumentId
                )
            ) {
                this.showEligibilityNotice = true;
            }

            //For SNAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.SNAPClaimAmount
                ) &&
                this.program.isSNAPProgram
            ) {
                this.showSNAPClaimAmount = true;
                this.SNAPClaimAmount = this.program.benefitCombined.SNAPClaimAmount;
                this.labels.sspYouOweForSnapBenefits = formatLabels(
                    this.labels.sspYouOweForSnapBenefits,
                    [this.SNAPClaimAmount]
                );
            }

            //For SNAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DocumentDueDate
                ) &&
                this.programStatus === sspPendingVerification &&
                this.program.isSNAPProgram
            ) {
                this.showAdditionalVerificationNeeded = true;
                this.documentUploadDueDate = sspUtility.getNewFormatDate(this.program.benefitCombined.DocumentDueDate);
            }

            //For SNAP, KTAP, CC
            if (this.programStatus === sspPendingInterview) {
                this.showAskForInterview = true;
            }

            //For SNAP, KTAP, CC
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.ReviewDate
                ) &&
                (this.programStatus === sspPendingInterview ||
                    this.programStatus === sspUnderReview)
            ) {
                this.showReviewDate = true;
                this.reviewDate = sspUtility.getNewFormatDate(this.program.benefitCombined.ReviewDate);
            }

            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.ApplicationSubmissionDate
                ) &&
                this.programStatus === sspDenied
            ) {
                this.showApplicationSubmissionDate = true;
                this.applicationSubmissionDate = sspUtility.getNewFormatDate(this.program.benefitCombined.ApplicationSubmissionDate);
            }

            //For SNAP, KTAP
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DenialEffectiveDate
                ) &&
                (this.programStatus === sspDenied ||
                    this.programStatus === sspDiscontinued)
            ) {
                this.showEffectiveDate = true;
                this.effectiveDate = sspUtility.getNewFormatDate(this.program.benefitCombined.DenialEffectiveDate);

                if (
                    !sspUtility.isUndefinedOrNull(
                        this.program.benefitCombined.DenialReason
                    )
                ) {
                    this.showDenialReason = true;
                    this.reason = this.program.benefitCombined.DenialReason;
                }
            }

            if (
                (this.programStatus === sspDenied ||
                    this.programStatus === sspDiscontinued) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DMSDocumentId
                ) &&
                this.isHeadOfHousehold === true
            ) {
                this.showDenialNotice = true;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DMSDocumentId
                )
            ) {
                this.DMSId = this.program.benefitCombined.DMSDocumentId;
            }
        }
        this.showSpinner = false;
    }

    /**
     * @function 		: handleDocumentClick.
     * @description 	: method for handleDocumentClick.
     **/
    handleDocumentClick = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "documents"
                }
            });
        } catch (error) {
            console.error(
                "failed in handleSuspensionClick in sspBenefitsPageIndividualProgramCard" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: downloadDocumentOnClick.
     * @description 	: method for downloadDocumentOnClick.
     * @param {*} event - Event parameter.
     **/
    downloadDocumentOnClick = event => {
        try {
     

            const documentDMSId = event.target.getAttribute("data-dms-id");
            this.showSpinner = true;
            const documentData = {};
            const documentMetadataId = documentDMSId;
            const extension = "pdf";
            const documentName = "Application";
            documentData.documentMetaDataId = documentMetadataId
                ? documentMetadataId
                : "";
            documentData.contentDocumentId = "";
            downloadDocumentMethod({
                sDocumentData: JSON.stringify(documentData)
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        const base64Data = result.mapResponse.docBase64Data;
                        const pageUrl =
                            apConstants.documentCenterHome.downloadDocumentUrl;
                        if (
                            base64Data &&
                            base64Data !== "ERROR Empty Response"
                        ) {
                            // Start - Download Document Code
                            const userAgentString = navigator.userAgent;
                            const browserIsEdge =
                                window.navigator.userAgent.indexOf("Edge") !==
                                -1;
                            const browserIsSafari =
                                userAgentString.indexOf("Safari") > -1;
                            const browserIExplorer =
                                window.navigator &&
                                window.navigator.msSaveOrOpenBlob
                                    ? true
                                    : false;
                            this.browserIExplorerTemp = browserIExplorer;
                            let fileURL;
                            let fileBlob;
                            //For IE11
                            if (
                                window.navigator &&
                                window.navigator.msSaveOrOpenBlob
                            ) {
                                fileBlob = this.base64ToBlob(
                                    base64Data,
                                    extension
                                );
                                window.navigator.msSaveOrOpenBlob(
                                    fileBlob,
                                    documentName
                                );
                            } else {
                                if (browserIsEdge || browserIsSafari) {
                                    // Edge Browser or Mozilla Browser or Safari
                                    fileBlob = this.base64ToBlob(
                                        base64Data,
                                        extension
                                    );
                                    fileURL = URL.createObjectURL(fileBlob);
                                } else {
                                    // Chrome & Firefox
                                    fileURL =
                                        "data:application/" +
                                        extension +
                                        ";base64," +
                                        base64Data; // PDF
                                }
                                const link = document.createElement("a");
                                link.download = documentName;
                                link.href = fileURL;
                                link.style.display = "none";
                                link.target = "_blank";
                                link.click();
                            }
                            // Start - Open in new Tab and Preview the Document
                            const previewUrl =
                                pageUrl +
                                "?dmsId=" +
                                documentDMSId +
                                "&fileExtension=pdf";
                            window.open(previewUrl, "_blank");
                        } else {
                            console.error(
                                "Error occurred in DownloadDoc of sspIndividualBenefits " +
                                    JSON.stringify(result)
                            );
                            this.showSpinner = false;
                        }
                        this.showSpinner = false;
                    } else {
                        console.error(
                            "Error occurred in DownloadDoc of sspIndividualBenefits " +
                                result.mapResponse.ERROR
                        );
                        this.showSpinner = false;
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "failed in downloadDocumentOnClick in sspBenefitsPageIndividualProgramCard" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : base64ToBlob
     * @description : Used to open pdf version of application.
     * @param  {object} base64String - Base 64 format data.
     * @param  {object} extension - Extension of the file.
     */
    base64ToBlob (base64String, extension) {
        try {
            let fileBlob;
            const byteCharacters = atob(base64String);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            if (extension === "pdf") {
                fileBlob = new Blob([byteArray], { type: "application/pdf" });
            }
            return fileBlob;
        } catch (error) {
            console.error(
                "Error in base64ToBlob" + JSON.stringify(error.message)
            );
            this.showSpinner = false;
            return null;
        }
    }

    /**
     * @function - handleNavigateToCC.
     * @description - Method to navigate to Child Care Enrollment Screen.
     * @param  {object} event - Fired on key down or click of the link.
     */
    handleNavigateToCC = event => {
        try {
            const individualId = event.target.dataset.individual;
            this.showSpinner = true;
            if (event.keyCode === 13 || event.type === "click") {
                // SSO Redirection logic
                validateSSORedirect({ sOperationName: "CHILD_CARE_ENROLLMENT_SUMMARY" })
                .then(result => {
                    if (result.bIsSuccess && !sspUtility.isUndefined(result.mapResponse.endPoint) && !sspUtility.isUndefined(result.mapResponse.encryptedToken)) {
                        this.showSpinner = false;
                        const portalUrl = new URL(result.mapResponse.endPoint);
                        portalUrl.searchParams.append("EncryptedData",result.mapResponse.encryptedToken);
                        window.open(portalUrl.href);
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: "SSP_ChildcareEnrollmentSummary__c"
                            },
                            state: {
                                individualId: individualId
                            }
                        });    
                    }
                })
                .catch(error => {
                    console.error("Error in SSO Direction", error);
                });
            }
        } catch (error) {
            console.error("Error in handleNavigateToCC =>", error);
        }
    }


    /**
     * @function - handlePayBalanceClick.
     * @description - Method to navigate to Child Care Enrollment Screen.
     */
    handlePayBalanceClick = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "claims"
                }
            });
        } catch (error) {
            console.error("Error in handlePayBalanceClick =>", error);
        }
    }
}