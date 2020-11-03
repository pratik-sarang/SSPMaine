import { api, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspUtility from "c/sspUtility";
import apConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import getIndividualId from "@salesforce/apex/SSP_Utility.getIndividualId";

import sspActive from "@salesforce/label/c.SSP_Active";
import sspPending from "@salesforce/label/c.SSP_Pending";
import sspInactive from "@salesforce/label/c.SSP_Inactive";
import sspApproved from "@salesforce/label/c.SSP_Approved";
import sspPendingVerification from "@salesforce/label/c.sspPendingVerification";
import sspPendingInterview from "@salesforce/label/c.SSP_PendingInterview";
import sspUnderReview from "@salesforce/label/c.SSP_UnderReview";
import sspDiscontinued from "@salesforce/label/c.SSP_Discontinued";

import sspDenied from "@salesforce/label/c.SSP_Denied";
import sspCaseHash from "@salesforce/label/c.sspCaseHash";
import sspApplicationHash from "@salesforce/label/c.sspApplicationHash";
import sspDiscontinueBenefits from "@salesforce/label/c.sspDiscontinueBenefits";
import sspPastApplications from "@salesforce/label/c.SSP_PastApplications";
import sspDisqualificationPenaltiesSuspension from "@salesforce/label/c.sspDisqualificationPenaltiesSuspension";
import sspMedicaidTitle from "@salesforce/label/c.sspMedicaidTitle";
import sspMedicaidWaiver from "@salesforce/label/c.sspMedicaidWaiver";
import sspKIHIPP from "@salesforce/label/c.SSP_KIHIPP";
import sspSNAP from "@salesforce/label/c.SSP_SNAP";
import sspChildCare from "@salesforce/label/c.sspChildCare";
import sspKTAP from "@salesforce/label/c.SSP_KTAP";
import sspKinshipCare from "@salesforce/label/c.sspKinshipCare";
import renewBenefits from "@salesforce/label/c.SSP_RenewBenefits";
import reportAChange from "@salesforce/label/c.SSP_ReportAChange";
import medicaidWaiver from "@salesforce/label/c.sspMedicaidWaiver";

import sspStateSupplementation from "@salesforce/label/c.SSP_StateSupplementation";

export default class SspBenefitsCaseDetails extends NavigationMixin(
    BaseNavFlowPage
) {
    @api caseNumber;
    @api program = {};
    @api isHeadOfHousehold = false;
    @api isChangeMode = false;
    @api isJORITWIST = false;
    @api availablePrograms = [];
    @api racCasesString = "";
    @api renewalCaseNumbersSet = [];
    @api isTMember = false;
    @api renderingMap = {}; // CD2 2.5 Security Role Matrix.
    @api selectedRole;
    @api caseVsStatusMap = {};
    @api loggedInIndividualId;
    @api mapWaiverDetails = {};
    @api mapWaiverStatus = {};
    @api listWaiverStatus = [];

    @track individualId;
    @track showRACPopUp = false;
    @track openDropDown = false;
    @track showKIHIPP = false;
    @track showMedicaid = false;
    @track showSS = false;
    @track showKinship = false;
    @track showSNAP = false;
    @track showKTAP = false;
    @track showCC = false;
    @track showWaiver = false;
    @track showSpinner = true;
    @track linkLabel = "";
    @track showDiscontinueBenefitLink = false;

    labels = {
        sspActive,
        sspPending,
        sspInactive,
        sspApproved,
        sspPendingVerification,
        sspPendingInterview,
        sspUnderReview,
        sspDenied,
        sspDiscontinued,
        sspCaseHash,
        sspApplicationHash,
        sspDiscontinueBenefits,
        sspPastApplications,
        sspDisqualificationPenaltiesSuspension,
        sspMedicaidTitle,
        sspMedicaidWaiver,
        sspKIHIPP,
        sspSNAP,
        sspChildCare,
        sspKTAP,
        sspKinshipCare,
        sspStateSupplementation,
        medicaidWaiver
    };
    /**
     * @function 		: programName.
     * @description 	: method to get programName.
     **/
    get programName () {
        return this.program.programCode || this.program.ProgramCode;
    }


    get kinshipProgramsData () {
        if(JSON.parse(JSON.stringify(this.program.KinshipBenefitsPerEDGList)).length > 0) {
            return this.program.KinshipBenefitsPerEDGList;
        }
        else {
            const returnData = [...this.program.KinshipBenefitsPerEDGList];
            returnData.push(this.program.KinshipBenefit);
            return returnData;
        }
    }

    get KTAPProgramsData () {
        if(JSON.parse(JSON.stringify(this.program.KTAPBenefitsPerEDGList)).length > 0) {
            return this.program.KTAPBenefitsPerEDGList;
        }
        else {
            const returnData = [...this.program.KTAPBenefitsPerEDGList];
            returnData.push(this.program.KTAPBenefit);
            return returnData;
        }
    }

    //Added for defect# 389537 - to display all benefits in Mixed Cases scenario.
    get isMixedCase () {
        try {
            if ((!sspUtility.isUndefinedOrNull(this.program) && !sspUtility.isUndefinedOrNull(this.program.MedicaidBenefits) && this.program.MedicaidBenefits.length > 0) || 
                (!sspUtility.isUndefinedOrNull(this.program) && !sspUtility.isUndefinedOrNull(this.program.KIHIPPBenefits) && this.program.KIHIPPBenefits.length > 0)
            ){
                return true;
            }
            else {
                return false;
            }
        } catch (error) {
            console.error("failed in isMixedCase in sspBenefitsCaseDetails" + JSON.stringify(error));
        }
        return false;
    }

    /**
     * @function 		: connectedCallback.
     * @description 	: method to handle rac popUp.
     **/
    connectedCallback () {

        if (
            !sspUtility.isUndefinedOrNull(this.caseVsStatusMap) &&
            !sspUtility.isUndefinedOrNull(
                this.caseVsStatusMap[this.caseNumber]
            ) &&
            this.caseVsStatusMap[this.caseNumber] === "AP"
        ) {
            this.showDiscontinueBenefitLink = true;
        }

        if (
            !sspUtility.isUndefinedOrNull(this.program) &&
            !sspUtility.isUndefinedOrNull(
                JSON.parse(JSON.stringify(this.program.KIHIPPBenefits))
            ) &&
            JSON.parse(JSON.stringify(this.program.KIHIPPBenefits)).length >
                0 &&
            this.availablePrograms.includes("KP")
        ) {
            this.showKIHIPP = true;
        }
        if (
            !sspUtility.isUndefinedOrNull(this.program) &&
            !sspUtility.isUndefinedOrNull(
                JSON.parse(JSON.stringify(this.program.MedicaidBenefits))
            ) &&
            JSON.parse(JSON.stringify(this.program.MedicaidBenefits)).length >
                0 &&
            this.availablePrograms.includes("MA")
        ) {
            this.showMedicaid = true;
        }
        if (
            !sspUtility.isUndefinedOrNull(this.program) &&
            !sspUtility.isUndefinedOrNull(JSON.parse(JSON.stringify(this.program.SSBenefits))) &&
            JSON.parse(JSON.stringify(this.program.SSBenefits)).length > 0 &&
            (this.availablePrograms.includes("SS") || this.selectedRole === "Citizen" || this.isMixedCase) 
        ) {
            this.showSS = true;
        }
        if (this.availablePrograms.includes("SN") || this.isMixedCase) {
            this.showSNAP = true;
        }
        if (this.availablePrograms.includes("KT") || this.isMixedCase) {
            this.showKTAP = true;
        }
        if (this.availablePrograms.includes("CC") || this.isMixedCase) {
            this.showCC = true;
        }
        if (
            this.availablePrograms.includes("KC") || this.isMixedCase ||
            this.selectedRole === "Citizen" || this.renderingMap.showKinship.isAccessible
        ) {
            this.showKinship = true;
        }
        if ( !sspUtility.isUndefinedOrNull(this.listWaiverStatus) && JSON.parse(JSON.stringify(this.listWaiverStatus)).length > 0 &&
            (this.selectedRole === "Citizen" || this.renderingMap.showWaiverReq.isAccessible)   //Using same flag- showWaiverReq that is used for Waiver link on MA card.
        ) {
            this.showWaiver = true;
        }
        if (
            !sspUtility.isUndefinedOrNull(this.renewalCaseNumbersSet) &&
            this.renewalCaseNumbersSet.length > 0 &&
            this.renewalCaseNumbersSet.includes(this.caseNumber)
        ) {
            this.linkLabel = renewBenefits;
        } else if (
            !sspUtility.isUndefinedOrNull(this.racCasesString) &&
            !sspUtility.isEmpty(this.racCasesString)
        ) {
            const racCasesList = JSON.parse(this.racCasesString);
            if (
                racCasesList.length > 0 &&
                racCasesList.includes(this.caseNumber)
            ) {
                this.linkLabel = reportAChange;
            }
        }

        getIndividualId().then(result => {
            this.individualId = result;
        });
        this.showSpinner = false;
    }


    /**
     * @function 		: handleLinkClick.
     * @description 	: method to handle rac popUp.
     **/
    handleLinkClick = () => {
        try {
            if (this.linkLabel === renewBenefits) {
                this[NavigationMixin.Navigate]({
                    type: apConstants.communityPageNames.community,
                    attributes: {
                        name: apConstants.communityPageNames.renewals
                    },
                    state: {
                        mode: "Renewal"
                    }
                });
            } else if (this.linkLabel === reportAChange) {
                this.showSpinner = false;
                this.showRACPopUp = true;
            }
        } catch (error) {
            console.error(
                "failed in handleLinkClick in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: dropDown.
     * @description 	: method to operate case level dropdown.
     * @param {*} event - Click event.
     **/
    dropDown (event) {
        try {
            if (
                event.type === "click" ||
                (event.type === "keydown" && event.keyCode === 13)
            ) {
                if (this.openDropDown) {
                    this.openDropDown = false;
                } else {
                    this.openDropDown = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in dropDown in sspBenefitsPage" + JSON.stringify(error)
            );
        }
    }


    /**
     * @function 		: handleDisqualification.
     * @description 	: method to handle rac popUp.
     **/
    handleDisqualification = () => {
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
                "failed in handleDisqualification in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handlePastApplication.
     * @description 	: method to handle rac popUp.
     **/
    handlePastApplication = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "past-applications"
                }
            });
        } catch (error) {
            console.error(
                "failed in handlePastApplication in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleDiscontinue.
     * @description 	: method to handle rac popUp.
     **/
    handleDiscontinue = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "discontinue-benefit"
                },
                state: {
                    caseId: this.caseNumber
                }
            });
        } catch (error) {
            console.error(
                "failed in handleDiscontinue in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleClose.
     * @description 	: method to handle rac popUp.
     **/
    handleClose () {
        try {
            this.showRACPopUp = false;
        } catch (error) {
            console.error(
                "failed in handleClose in sspDashboardExistingUser" +
                    JSON.stringify(error)
            );
        }
    }

}