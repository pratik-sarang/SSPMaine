/* eslint-disable spellcheck/spell-checker */
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
import sspPolicyId from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyId";
import sspViewPaymentSummary from "@salesforce/label/c.sspViewPaymentSummary";
import sspManagePreferredPayment from "@salesforce/label/c.sspManagePrefferedPayment";
import sspType from "@salesforce/label/c.SSP_Type";
import sspPatientLiability from "@salesforce/label/c.sspPatientLiability";
import sspEligibilityWaiverPrograms from "@salesforce/label/c.sspEligilityWaiverPrograms";
import sspProgramSuspended from "@salesforce/label/c.sspProgramSuspended";
import sspOneActivePenalty from "@salesforce/label/c.sspOneActivePenaty";
import sspViewPenalty from "@salesforce/label/c.sspViewPenalty";
import sspPlanName from "@salesforce/label/c.sspPlanName";
import sspPhoneNumber from "@salesforce/label/c.SSP_FooterBenefindContactNumber";
import sspVisitHealthCare from "@salesforce/label/c.SSP_VisitHealthcare";
import sspViewSuspension from "@salesforce/label/c.sspViewSuspension";
import sspPhoneNumber2 from "@salesforce/label/c.sspPhoneNumber2";
import sspRequestMedicaidCard from "@salesforce/label/c.sspRequestMedicaidCard";
import sspViewEligibilityNotice from "@salesforce/label/c.sspViewEligibilityNotice";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import medicaidEBTData from "@salesforce/apex/SSP_RequestAMedicaidCard.medicaidEBTData";
import getMemberGenderCode from "@salesforce/apex/SSP_RequestAMedicaidCard.getMemberGenderCode";
import sspDollarSign from "@salesforce/label/c.sspDollarSign";

import sspApproved from "@salesforce/label/c.SSP_Approved";
import sspUnderReview from "@salesforce/label/c.SSP_UnderReview";
import sspDenied from "@salesforce/label/c.SSP_Denied";
import sspPendingVerification from "@salesforce/label/c.SSP_PendingVerification";
import sspPendingInterview from "@salesforce/label/c.SSP_PendingInterview";
import sspDiscontinued from "@salesforce/label/c.SSP_Discontinued";

//requestACard changes
import sspMedicaidCardSuccessToast from "@salesforce/label/c.SSP_RequestMedicaidCardSuccessToast";
import sspEBTCardSuccessToast from "@salesforce/label/c.SSP_RequestEBTCardSuccessToast";

import sspReferralMadeToFFM from "@salesforce/label/c.sspRefferalMadeToFFM";

import { formatLabels } from "c/sspUtility";

// SSO redirect
import validateSSORedirect from "@salesforce/apex/SSP_Utility.validateSSORedirect";

export default class SspBenefitsPageIndividualProgramCard extends NavigationMixin(
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
    @api loggedInIndividualId;
    @api mapWaiverDetails = {}; //Only for Medicaid Tiles
    @api mapWaiverStatus = {}; //Only for Medicaid Tiles
    @api selectedRole;

    @track individualId;

    @track showDenialNotice = false;
    @track showBenefitPeriod = false;
    @track benefitPeriod;
    @track showMedicaidType = false;
    @track medicaidType;
    @track showPatientLiability = false;
    @track patientLiabilityMonthVSAmount = [];
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
    @track showRequestMedicaidCard = false;
    @track showActiveSuspension = false;
    @track showPenalty = false;
    @track penaltyPeriod;
    @track ReferredToFFM = false;
    @track showPolicyHolderName = false;
    @track showInsuranceCompanyName = false;
    @track showInsurancePlanName = false;
    @track showPolicyId = false;
    @track policyHolderName;
    @track insuranceCompanyName;
    @track insurancePlanName;
    @track policyId;
    @track showPaymentSummary = false;
    @track showWaiverProgramLink = false;
    @track showSpinner = true;
    @track DMSId = "";
    @track showManagePreferredPayment = false;
    @track showErrorToast = false;
    @track toastMessage = "";
    @track policyHolderId;
    @track isEBTRequestVisibility = false;
    @track medicaidEBTIndividualName;
    @track medicaidEBTDataFlag = false;
    @track genderCode;
    @track genderCodeFlag = false;

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
        sspPolicyId,
        sspViewPaymentSummary,
        sspManagePreferredPayment,

        sspType,
        sspPatientLiability,
        sspEligibilityWaiverPrograms,
        sspProgramSuspended,
        sspOneActivePenalty,
        sspViewPenalty,
        sspReferralMadeToFFM,
        sspPlanName,
        sspPhoneNumber,
        sspVisitHealthCare,
        sspViewSuspension,
        sspPhoneNumber2,
        sspRequestMedicaidCard,
        sspViewEligibilityNotice,
        sspDollarSign,
        sspMedicaidCardSuccessToast,
        sspEBTCardSuccessToast
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
            this.programStatus === sspPendingVerification ||
            this.programStatus === sspPendingInterview ||
            this.programStatus === sspUnderReview
        );
    }

    /**
     * @function 		: showDenialSecurityMatrix.
     * @description 	: method for getting Security Matrix implementation for Denial Notice link.
     **/
    get showDenialSecurityMatrix () {

        if (this.renderingMap.showViewDenialNotice.isAccessible) {
            return true;
        } else if (
            this.program.benefitCombined.ProgramCode ===
                "State Supplementation" &&
            (this.selectedRole === apConstants.headerConstants.DAIL_Worker ||
                this.selectedRole === "CHFS Prod Support")
        ) {
            return true;
        } else if (
            (this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP" ||
                this.program.benefitCombined.ProgramCode === "KI-HIPP") &&
            (this.selectedRole === "Contact Center (View and Edit)" ||
                this.selectedRole === "Contact Center (View Only)")
        ) {
            return true;
        }
        return false;
    }

    /**
     * @function 		: showEligibilitySecurityMatrix.
     * @description 	: method for getting Security Matrix implementation for Eligibility Notice link.
     **/
    get showEligibilitySecurityMatrix () {

        if (this.renderingMap.showViewEligibility.isAccessible) {
            return true;
        } else if (
            this.program.benefitCombined.ProgramCode === "KI-HIPP" &&
            (this.selectedRole === "Contact Center (View and Edit)" ||
                this.selectedRole === "Contact Center (View Only)")
        ) {
            return true;
        }
        return false;
    }

    /**
     * @function 		: connectedCallback.
     * @description 	: method for connectedCallback.
     **/
    connectedCallback () {
        if (
            !sspUtility.isUndefinedOrNull(this.program) &&
            !sspUtility.isUndefinedOrNull(this.program.benefitCombined)
        ) {
            this.individualId = this.program.benefitCombined.IndividualId;
        }

        if (!sspUtility.isUndefinedOrNull(this.program)) {
            //Check if additional filter needed for SNAP, KTAP programs
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
                )
                    ? sspUtility.getNewFormatDate(this.program.benefitCombined.BenefitEndDate) : "Ongoing";
                    
                this.benefitPeriod = beginDate + " - " + endDate;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.TypeOfAssistanceCode
                ) &&
                this.programStatus !== sspDenied &&
                this.programStatus !== sspPendingVerification &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                this.showMedicaidType = true;
                this.medicaidType = this.program.benefitCombined.TypeOfAssistanceCode;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined
                        .CurrentMonthPatientLiabilityAmount
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PatientLiabilityCurrentMonth
                ) &&
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.PatientLiabilityCurrentMonth;
                obj.amount = this.program.benefitCombined.CurrentMonthPatientLiabilityAmount;
                this.patientLiabilityMonthVSAmount.push(obj);
                this.showPatientLiability = true;
            }
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined
                        .UpcomingMonthPatientLiabilityAmount
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PatientLiabilityUpcomingMonth
                ) &&
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                const obj = {};
                obj.month = this.program.benefitCombined.PatientLiabilityUpcomingMonth;
                obj.amount = this.program.benefitCombined.UpcomingMonthPatientLiabilityAmount;
                this.patientLiabilityMonthVSAmount.push(obj);
                this.showPatientLiability = true;
            }
            
            if (
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP" &&
                this.isHeadOfHousehold === true
            ) {
                
                this.getMemberGenderCodeHandler();
                this.medicaidEBTDataHandler();
            }
            //Have to modify this condition once waiver service is ready
            //Medicaid Status- Step 1.1 - If program status is Denied,Discontinued etc we will not enter into the loop
            //Medicaid Status- Step 1.2 - If program status is Approved,Pending we will enter into the loop
            if (this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP" &&
                this.programStatus !== sspDenied && this.programStatus !== sspDiscontinued
            ) {
                //Map Waiver details gives information About Prescreening Records for Individuals
                if (!sspUtility.isUndefinedOrNull(this.mapWaiverDetails) && Object.keys(this.mapWaiverDetails).length !== 0) {
                    //collecting information of detail record for the logged in individual to understand Prescreening Status
                    const waiverDetailRecord = this.mapWaiverDetails[
                        this.individualId
                    ];
                      //atleast one waiver application
                      //If there is a waiver Detail Record for logged in individual among Map of waiver Detail Records
                      //We can access Prescreening data  for logged in Individual
                    if (!sspUtility.isUndefinedOrNull(waiverDetailRecord)) {
                        // Prescreening Results - Step 1 and Step 2.1
                        //Accessing information if the prescreening 
                        //if atleastOneAnsweredYes is false
                        //Pre - Screening Results - Not Eligible
                        //Pre - Screening Results - Potentially Eligible - Continue Application Button is not clicked
                        if (waiverDetailRecord.atleastOneAnsweredYes === false) {
                            this.showWaiverProgramLink = true;
                        }
                        // Prescreening Results - Step 2.2
                        //if atleastOneAnsweredYes is true  
                        //Prescreening Result - Potentially Eligible - Continue Application button is clicked it depends on Step 2
                        else {
                            if (!sspUtility.isUndefinedOrNull(this.mapWaiverStatus) && Object.keys(this.mapWaiverStatus).length !== 0 && Object.keys(this.mapWaiverStatus).includes(this.individualId) ) {
                                const listStatusRecords = [];
                                    this.mapWaiverStatus[this.individualId].forEach(function (internalItem) { 
                                        listStatusRecords.push(internalItem); 
                                    });
                                
                                //collecting all Application Statuses which are complete
                                const allApplicationStatusComplete = [] ;
                                listStatusRecords.forEach(function (statusRecord) {
                                        if (statusRecord.ApplicationStatus === "COM" || statusRecord.ApplicationStatus === "DEAC") {
                                            allApplicationStatusComplete.push(statusRecord);
                                        }
                                });

                                if ( allApplicationStatusComplete.length === listStatusRecords.length) { 
                                    this.showWaiverProgramLink = true;  //Skipping the Step-based logic and directly making the link visible if for any Waiver Application, Status is COMPLETED.
                                }
                                
                            }
                            // If it not eligible or Potentially Eligible or map waiver status is not present
                            //Since the medicaid status is approved we need to show the link
                            else {
                                this.showWaiverProgramLink = true;    
                            }
                        }
                      }
                      //If the Individuals Waiver Detail Record is not available
                      //There is no prescreening data, but we need to show the link since Medicaid status is approved
                      else {
                        this.showWaiverProgramLink = true;    
                      }
                } else {
                    //When there are no prescreening results and the Medicaid Status is Approved/Pending link will be shown
                    this.showWaiverProgramLink = true;
                }
                //Once all the decisions are made for the card, we need to show for HOH user and not show for Non hoh user
                // If the person is not HOH and other household members cards are visible to him
                // waiver links on those cards should not be visible 
                if (!this.isHeadOfHousehold && !(this.loggedInIndividualId==this.individualId)) {
                    this.showWaiverProgramLink = false;
                }
            }
            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PolicyHolderName
                ) &&
                this.programStatus !== sspPendingVerification &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP"
            ) {
                this.showPolicyHolderName = true;
                this.policyHolderName = this.program.benefitCombined.PolicyHolderName;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.InsuranceComanyName
                ) &&
                this.programStatus !== sspPendingVerification &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP"
            ) {
                this.showInsuranceCompanyName = true;
                this.insuranceCompanyName = this.program.benefitCombined.InsuranceComanyName;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.InsurancePlanName
                ) &&
                this.programStatus !== sspPendingVerification &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP"
            ) {
                this.showInsurancePlanName = true;
                this.insurancePlanName = this.program.benefitCombined.InsurancePlanName;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PolicyId
                ) &&
                (this.programStatus === sspApproved  ||   //"Approved"
                    this.programStatus === sspUnderReview) &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP"
            ) {
                this.showPolicyId = true;
                this.policyId = this.program.benefitCombined.PolicyId;
            }

            if (
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP"
            ) {
                if (
                    this.isHeadOfHousehold ||
                    (!sspUtility.isUndefinedOrNull(
                        this.program.benefitCombined.PolicyHolderId
                    ) &&
                        this.program.benefitCombined.PolicyHolderId ===
                            this.loggedInIndividualId)
                ) {
                    this.showPaymentSummary = true;
                }
            }

            if (this.program.benefitCombined.ProgramCode === "KI-HIPP" && !sspUtility.isUndefinedOrNull(this.program.benefitCombined.PolicyHolderId)) {
                this.policyHolderId = this.program.benefitCombined.PolicyHolderId;
            }

            if (
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode === "KI-HIPP" &&
                this.isHeadOfHousehold === true
            ) {
                this.showManagePreferredPayment = true;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.HasActiveSuspension
                ) &&
                this.program.benefitCombined.HasActiveSuspension === "Y" &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                this.showActiveSuspension = true;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.HasActivePenalty
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PenaltyBeginDate
                ) &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.PenaltyEndDate
                ) &&
                this.program.benefitCombined.HasActivePenalty === "Y" &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                this.showPenalty = true;
              

                    this.penaltyPeriod = sspUtility.getNewFormatDate(this.program.benefitCombined.PenaltyBeginDate)+"-"+sspUtility.getNewFormatDate(this.program.benefitCombined.PenaltyEndDate);
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.EBTCardFundLoadDate
                ) &&
                this.programStatus === sspApproved
            ) {
                this.showEBTFundLoadDate = true;
                this.EBTFundLoadDate = sspUtility.getNewFormatDate(this.program.benefitCombined.EBTCardFundLoadDate);
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.RenewalDueDate
                ) &&
                this.programStatus === sspApproved  //"Approved"
            ) {
                this.showRenewalDueDate = true;
                this.renewalDueDate = sspUtility.getNewFormatDate(this.program.benefitCombined.RenewalDueDate); 
            }

            if (
                this.programStatus === sspApproved &&
                this.program.benefitCombined.ProgramCode !== "Medicaid/KCHIP" &&
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DMSDocumentId
                )
            ) {
                this.showEligibilityNotice = true;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.SNAPClaimAmount
                )
            ) {
                this.showSNAPClaimAmount = true;
                this.SNAPClaimAmount = this.program.benefitCombined.SNAPClaimAmount;
                this.labels.sspYouOweForSnapBenefits = formatLabels(
                    this.labels.sspYouOweForSnapBenefits,
                    [this.showSNAPClaimAmount]
                );
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DocumentDueDate
                ) &&
                this.programStatus === sspPendingVerification
            ) {
                this.showAdditionalVerificationNeeded = true;
                this.documentUploadDueDate = sspUtility.getNewFormatDate(this.program.benefitCombined.DocumentDueDate);
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DocumentDueDate
                ) &&
                this.programStatus === sspPendingInterview
            ) {
                this.showAskForInterview = true;
            }

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

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.ApplicationSubmissionDate
                ) &&
                this.programStatus === sspDenied
            ) {
                this.showApplicationSubmissionDate = true;
                this.applicationSubmissionDate =sspUtility.getNewFormatDate(this.program.benefitCombined.ApplicationSubmissionDate); 
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.ReferredToFFM
                ) &&
                this.programStatus === sspDenied &&
                this.program.benefitCombined.ProgramCode === "Medicaid/KCHIP"
            ) {
                this.ReferredToFFM = true;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DenialEffectiveDate
                ) &&
                (this.programStatus === sspDenied ||
                    this.programStatus === sspDiscontinued)
            ) {
                this.showEffectiveDate = true;
                this.effectiveDate = sspUtility.getNewFormatDate(this.program.benefitCombined.DenialEffectiveDate);
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DenialReason
                ) &&
                (this.programStatus === sspDenied ||
                    this.programStatus === sspDiscontinued)
            ) {
                this.showDenialReason = true;
                this.reason = this.program.benefitCombined.DenialReason;
            }

            if (
                !sspUtility.isUndefinedOrNull(
                    this.program.benefitCombined.DMSDocumentId
                ) &&
                (this.programStatus === sspDenied ||
                    this.programStatus === sspDiscontinued) &&
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
        // Request a Card Changes
        
        this.showDashboard();
        this.showSpinner = false;
    }

    /**
     * @function 		: handleWaiverProgramClick.
     * @description 	: method for handleWaiverProgramClick.
     * @param {*} event - Event parameter.
     **/
    handleWaiverProgramClick = event => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "waiver-screening-questions"
                },
                state: {
                    caseNumber: this.caseNumber,
                    individualId: event.target.id.split("-")[0], //splitting it and taking 0th element to remove randomly appended browser number.
                    individualName: encodeURIComponent(this.individualName)
                }
            });
        } catch (error) {
            console.error(
                "failed in handleWaiverProgramClick in sspBenefitsPageIndividualProgramCard" +
                    JSON.stringify(error)
            );
        }
    };


    /**
     * @function 		: handlePreferredPaymentClick.
     * @description 	: method for handlePreferredPaymentClick.
     * @param {*} event - Event parameter.
     **/
    handlePreferredPaymentClick = event => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "kihipp-preffered-method"
                },
                state: {
                    caseNumber: this.caseNumber,
                    IndividualIds: event.target.getAttribute("data-individual-id"),
                    PolicyHolderId: event.target.getAttribute("data-policy-holder-id"),
                    policyHolderName: encodeURIComponent(event.target.getAttribute("data-policy-holder-name"))
                }
            });
        } catch (error) {
            console.error(
                "failed in handlePreferredPaymentClick in sspBenefitsPageIndividualProgramCard" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleSuspensionClick.
     * @description 	: method for handleSuspensionClick.
     **/
    handleSuspensionClick = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "disqualification-details"
                },
                state: {
                    individualId: this.individualId
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
     * @function 		: handlePaymentSummaryClick.
     * @description 	: method for handlePaymentSummaryClick.
     * @param {*} event - Event parameter.
     **/
    handlePaymentSummaryClick = (event) => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "kihipp-payment-summary"
                },
                state: {
                    individualId: event.target.id.split("-")[0] //splitting it and taking 0th element to remove randomly appended browser number.
                }
            });
        } catch (error) {
            console.error(
                "failed in handlePaymentSummaryClick in sspBenefitsPageIndividualProgramCard" +
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
                                "Error occurred in DownloadDoc of sspIndvBenefits " +
                                    JSON.stringify(result)
                            );
                            this.showSpinner = false;
                        }
                        this.showSpinner = false;
                    } else {
                        console.error(
                            "Error occurred in DownloadDoc of sspIndvBenefits " +
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
     * @function 		: handleRequestACard.
     * @description 	: method to navigate to Request a card screen.
     * @param {object} event - Js event.
     **/
    handleRequestACard = event => {
        try {
            if ((event.type === "keydown" && event.keyCode === 13) || event.type === "click") {
                this.showSpinner = true;
                if (event.target.name === "EBT") { 
                    validateSSORedirect({ sOperationName: "EBT_CARD_REQUEST" })
                    .then(result => {
                        const parsedData = result.mapResponse;
                        if (parsedData.hasOwnProperty("endPoint") && parsedData.hasOwnProperty("encryptedToken")) {
                            this.showSpinner = false;
                            const portalUrl = new URL(parsedData.endPoint);
                            portalUrl.searchParams.append("EncryptedData", parsedData.encryptedToken);
                            window.open(portalUrl.href);
                        } else {
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    name: "Request_A_Card__c"
                                },
                                state: {
                                    requestEBT: "request",
                                    fromBenefit: true
                                }
                            });
                        }
                    })
                    .catch(error => {
                        console.error("Error in Fraud" + JSON.stringify(error.message));
                    });
                }
                if (event.target.name === "Medicaid") {
                    validateSSORedirect({ sOperationName: "MEDICAID_CARD_REQUEST" })
                        .then(result => {
                            const parsedData = result.mapResponse;
                            if (parsedData.hasOwnProperty("endPoint") && parsedData.hasOwnProperty("encryptedToken")) {
                                this.showSpinner = false;
                                const portalUrl = new URL(parsedData.endPoint);
                                portalUrl.searchParams.append("EncryptedData", parsedData.encryptedToken);
                                window.open(portalUrl.href);
                            } else {
                                this[NavigationMixin.Navigate]({
                                    type: "comm__namedPage",
                                    attributes: {
                                        name: "Request_A_Card__c"
                                    },
                                    state: {
                                        requestMedicaid: "request",
                                        fromBenefit: true
                                    }
                                });
                            }
                        })
                        .catch(error => {
                            console.error("Error in Fraud" + JSON.stringify(error.message));
                        });
                }
            }
        } catch (error) {
            console.error("Error in handleRequestACard =>", error);
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };

    /**
     * @function : medicaidEBTDataHandler
     * @description : This method is used to get request cards link accessibility.
     */
    medicaidEBTDataHandler = () => {
        medicaidEBTData()
            .then(result => {
                if (result.bIsSuccess) {
                   
                    const medicaidVisibility =
                        result.mapResponse.showMedicaidLink;
                    const visibilityEBT = result.mapResponse.showEBTLink;
                    if (
                        medicaidVisibility !== null &&
                        medicaidVisibility !== undefined &&
                        medicaidVisibility === true
                    ) {
                        
                        this.showRequestMedicaidCard = true;
                    }
                    if (
                        visibilityEBT !== null &&
                        visibilityEBT !== undefined &&
                        visibilityEBT === true
                    ) {
                        this.isEBTRequestVisibility = true;
                    }
                    const url = new URL(window.location.href);
                    let whoNeedsPickList = [];
                    whoNeedsPickList = JSON.parse(result.mapResponse.response);
                    if (
                        url.searchParams.get("requestEBTCard") ||
                        url.searchParams.get("requestMedicaidCard")
                    ) {
                        if (url.searchParams.get("individualId")) {
                            const individualId = url.searchParams.get(
                                "individualId"
                            );
                            for (
                                let pickList = 0;
                                pickList < whoNeedsPickList.length;
                                pickList++
                            ) {
                                if (
                                    whoNeedsPickList[pickList].IndividualId ===
                                    individualId
                                ) {
                                    this.medicaidEBTIndividualName =
                                        whoNeedsPickList[
                                            pickList
                                        ].IndividualName;

                                    this.medicaidEBTDataFlag = true;
                                    this.showDashboard();
                                }
                            }
                        }
                    }
                } else {
                    console.error(
                        "@@@medicaidEBTHandler false response " +
                            JSON.stringify(result)
                    );
                }
            })
            .catch(error => {
                console.error(
                    "@@@medicaidEBTHandler error" + JSON.stringify(error)
                );
            });
    };
    getMemberGenderCodeHandler () {
        const url = new URL(window.location.href);
        if (
            url.searchParams.get("requestEBTCard") ||
            url.searchParams.get("requestMedicaidCard")
        ) {
            if (url.searchParams.get("individualId")) {
                const individualId = url.searchParams.get("individualId");
                getMemberGenderCode({
                    individualId: individualId
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                            this.genderCode = result.mapResponse.genderCode;
                        } else {
                            this.genderCode = "U";
                        }
                        this.genderCodeFlag = true;
                        this.showDashboard();
                    })
                    .catch(error => {
                        console.error(
                            "gendercode error" + JSON.stringify(error)
                        );
                    });
            }
        }
    }

    showDashboard = () => {
        try {
            if (this.medicaidEBTDataFlag && this.genderCodeFlag) {
                this.showSpinner = false;
                let genderPronoun = "";
                if (this.genderCode == "M") {
                    genderPronoun = "His";
                } else if (this.genderCode == "F") {
                    genderPronoun = "Her";
                } else {
                    genderPronoun = "The";
                }
                // Request a Card Changes

                const url = new URL(window.location.href);
                if (url.searchParams.get("requestEBTCard")) {
                    this.labels.sspEBTCardSuccessToast = formatLabels(
                        this.labels.sspEBTCardSuccessToast,
                        [this.medicaidEBTIndividualName]
                        //contactName
                    );
                    this.toastMessage = this.labels.sspEBTCardSuccessToast;
                    this.showErrorToast = true;
                }
                if (url.searchParams.get("requestMedicaidCard")) {
                    //const individualId = url.searchParams.get("individualId");

                    this.labels.sspMedicaidCardSuccessToast = formatLabels(
                        this.labels.sspMedicaidCardSuccessToast,
                        [this.medicaidEBTIndividualName, genderPronoun]
                    );

                    this.toastMessage = this.labels.sspMedicaidCardSuccessToast;
                    this.showErrorToast = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in showDashboard in sspDashboardExistingUser" +
                    JSON.stringify(error)
            );
        }
    };
}
