import { api, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspUtility from "c/sspUtility";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspProgramLabel from "@salesforce/label/c.SSP_HearingRequestProgramTitle";
import sspWaiverCardVisitDashboard from "@salesforce/label/c.SSP_BenefitsWaiverVisitDashboard";
import sspContinueApplication from "@salesforce/label/c.SSP_EarlySubmissionModalContinueApplication";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspWaiverCaseHash from "@salesforce/label/c.SSP_WaiverCaseHash";
import sspSubmitApplicationWaiver from "@salesforce/label/c.SSP_SubmitApplicationWaiver";
import sspNotSubmitted from "@salesforce/label/c.SSP_NotSubmitted";
import sspEnrolled from "@salesforce/label/c.SSP_Enrolled";
import sspUnderReview from "@salesforce/label/c.SSP_UnderReview";
import sspClosed from "@salesforce/label/c.Closed";
import sspReviewDashboard from "@salesforce/label/c.SSP_ReviewWaiverDashboard";

import sspActionRequired from "@salesforce/label/c.SSP_ActionRequired";
import sspWaitListed from "@salesforce/label/c.SSP_Waitlisted";
import sspSupportsCommunity from "@salesforce/label/c.SSP_WaiverSupportsCommunity";
import sspModel from "@salesforce/label/c.SSP_WaiverModelII";
import sspAcquiredBrainInjury from "@salesforce/label/c.SSP_WaiverAcquiredBrainInjury";
import sspAcquiredBrainInjuryLTC from "@salesforce/label/c.SSP_WaiverAcquiredBrainInjuryLTC";
import sspHomeCommunity from "@salesforce/label/c.SSP_WaiverHomeCommunityBased";
import sspMichelle from "@salesforce/label/c.SSP_WaiverMichelleP";
import triggerWaiverTokenGeneration from "@salesforce/apex/SSP_WaiverController.triggerWaiverTokenGeneration";

export default class SspBenefitsWaiverProgramCard extends NavigationMixin(BaseNavFlowPage) {

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


    @track individualId;
    @track individualName;
    @track showApplicationStatus = false;
    @track applicationStatus;
    @track showApplicationNumber = false;
    @track applicationNumber;
    @track showReminderText = false;
    @track showWaiverCaseStatus = false;
    @track waiverCaseStatus;
    @track showWaiverCaseNumber = false;
    @track waiverCaseNumber;
    @track showWaiverProgramStatus = false;
    @track waiverProgramStatus;
    @track showWaiverProgram = false;
    @track waiverProgram;
    @track showContinueApplication = false;
    @track showVisitWaiverDashboard = false;
    @track showSpinner =false;
    @track finalStatusLabel;
    
    needsReviewIconUrl = sspIcons + apConstants.url.needsReviewIcon;
    labels = {
        sspProgramLabel,
        sspWaiverCardVisitDashboard,
        sspContinueApplication,
        sspApplicationHash,
        sspWaiverCaseHash,
        sspSubmitApplicationWaiver
    }

    /**
     * @function 		: finalStatus.
     * @description 	: method for final status - Case level/ Program Level/ Application level.
     **/
    get finalStatus () {
        return (this.waiverCaseStatus || this.waiverProgramStatus || this.applicationStatus);
    }

    /**
     * @function 		: showGreenDisc.
     * @description 	: method for showGreenDisc.
     **/
    get showGreenDisc () {
        return (
            this.finalStatus === apConstants.headerConstants.Enrolled ||
            this.finalStatus === apConstants.headerConstants.WaitList
        );
    }

    /**
     * @function 		: showRedDisc.
     * @description 	: method for showRedDisc.
     **/
    get showRedDisc () {
        return (
            this.finalStatus === apConstants.headerConstants.Closed ||
            this.finalStatus === apConstants.headerConstants.ReviewOnDashboard
        );
    }

    /**
     * @function 		: showOrangeDisc.
     * @description 	: method for showOrangeDisc.
     **/
    get showOrangeDisc () {
        return (
            this.finalStatus === apConstants.headerConstants.NotSubmitted ||
            this.finalStatus === apConstants.headerConstants.UnderReview ||
            this.finalStatus === apConstants.headerConstants.ActionRequired
        );
    }

    /**
     * @function 		: connectedCallback.
     * @description 	: method for connectedCallback.
     **/
    connectedCallback () {

        if (!sspUtility.isUndefinedOrNull(this.program)) {

            this.individualId = this.program.IndividualId;
            this.individualName = this.program.IndividualName;

            //Logic for STEP-2 in DDD- Check for Waiver Application Status.
            if (!sspUtility.isUndefinedOrNull(this.program.ApplicationStatus)) {
                this.showApplicationStatus = true;

                if (this.program.ApplicationStatus === "SAV") {
                    this.applicationStatus = apConstants.headerConstants.NotSubmitted;
                    this.finalStatusLabel = sspNotSubmitted;
                    this.showReminderText = true;
                    this.showContinueApplication = true;
                    this.showVisitWaiverDashboard = false;

                    //Logic to Show Waiver Application Data.
                    this.getWaiverApplicationNumber();
                }
                else if (this.program.ApplicationStatus === "SUB" || this.program.ApplicationStatus === "RESUB" || this.program.ApplicationStatus === "INREV") {
                    this.applicationStatus = apConstants.headerConstants.UnderReview;
                    this.finalStatusLabel = sspUnderReview;
                    this.showContinueApplication = false;
                    this.showVisitWaiverDashboard = true;
                    
                    //  Logic to get Waiver Case Number.
                    this.getWaiverCaseNumber();

                    //Logic to Show Waiver Application Data.
                    this.getWaiverApplicationNumber();
                }
                else if (this.program.ApplicationStatus === "INCOM") {
                    this.applicationStatus = apConstants.headerConstants.ActionRequired;
                    this.finalStatusLabel = sspActionRequired;
                    this.showContinueApplication = false;
                    this.showVisitWaiverDashboard = true;

                    //  Logic to get Waiver Case Number.
                    this.getWaiverCaseNumber();

                    //Logic to Show Waiver Application Data.
                    this.getWaiverApplicationNumber();
                }

                //Logic for STEP-3 in DDD- Check for Waiver Program Status.
                else if (this.program.ApplicationStatus === "COM") {
                    this.showWaiverProgramStatus = true;
                    this.showContinueApplication = false;
                    this.showVisitWaiverDashboard = true;

                    //  Logic to decide Waiver Program Name based on Program Code.
                    this.getWaiverProgramName();

                    //  Logic to get Waiver Case Number.
                    this.getWaiverCaseNumber();

                    if (this.program.ProgramStatusCode === "EN") {
                        this.waiverProgramStatus = apConstants.headerConstants.Enrolled;
                        this.finalStatusLabel = sspEnrolled;
                    }
                    else if (this.program.ProgramStatusCode === "WL") {
                        this.waiverProgramStatus = apConstants.headerConstants.WaitList;
                        this.finalStatusLabel = sspWaitListed;
                    }

                    //Logic for STEP-4 in DDD- Check for Waiver Case Status.
                    else {
                        if (!sspUtility.isUndefinedOrNull(this.program.WaiverCaseStatus)) {
                            this.showWaiverCaseStatus = true;
                            this.showWaiverProgram = false;     //To hide Waiver Program Name in Step 4
                            this.showContinueApplication = false;
                            this.showVisitWaiverDashboard = true;

                            //  Logic to get Waiver Case Number.
                            this.getWaiverCaseNumber();

                            if (this.program.WaiverCaseStatus === "CLDTC" || this.program.WaiverCaseStatus === "CL") {
                                this.waiverCaseStatus = apConstants.headerConstants.Closed;
                                this.finalStatusLabel = sspClosed;
                                //Logic to Show Waiver Application Data.
                                this.getWaiverApplicationNumber();
                            }
                            else {
                                this.waiverCaseStatus = apConstants.headerConstants.ReviewOnDashboard;
                                this.finalStatusLabel = sspReviewDashboard;
                            }
                        }
                    }
                }
                
            }

        }
    }


    /**
     * @function 		: getWaiverProgramName.
     * @description 	: method to decide Waiver Program Name based on Program Code..
     **/
    getWaiverProgramName = () => {
        try {
            if (!sspUtility.isUndefinedOrNull(this.program.ProgramCode)) {
                this.showWaiverProgram = true;
                if (this.program.ProgramCode === "SCL") {
                    this.waiverProgram = sspSupportsCommunity;
                }
                else if (this.program.ProgramCode === "MII") {
                    this.waiverProgram = sspModel;
                }
                else if (this.program.ProgramCode === "ABI-Acute") {
                    this.waiverProgram = sspAcquiredBrainInjury;
                }
                else if (this.program.ProgramCode === "HCB") {
                    this.waiverProgram = sspHomeCommunity;
                }
                else if (this.program.ProgramCode === "MPW") {
                    this.waiverProgram = sspMichelle;
                }
                else if (this.program.ProgramCode === "ABI") {
                    this.waiverProgram = sspAcquiredBrainInjuryLTC;
                }
            }
        }
        catch (error) {
            console.error("Error in getWaiverProgramName in sspBenefitsWaiverProgramCard" + JSON.stringify(error));
        }
    }


    /**
     * @function 		: getWaiverCaseNumber.
     * @description 	: method to get Waiver Case Number.
     **/
    getWaiverCaseNumber = () => {
        try {
            if (!sspUtility.isUndefinedOrNull(this.program.WavierCaseNumber)) {
                this.waiverCaseNumber = this.program.WavierCaseNumber;
                this.showWaiverCaseNumber = true;
            }
        }
        catch (error) {
            console.error("Error in getWaiverCaseNumber in sspBenefitsWaiverProgramCard" + JSON.stringify(error));
        }
    }


    /**
     * @function 		: getWaiverApplicationNumber.
     * @description 	: method to get Waiver Application Number.
     **/
    getWaiverApplicationNumber = () => {
        try {
            if (!sspUtility.isUndefinedOrNull(this.program.ApplicationNumber)) {
                this.showApplicationNumber = true;
                this.applicationNumber = this.program.ApplicationNumber;
            }
        }
        catch (error) {
            console.error("Error in getWaiverApplicationNumber in sspBenefitsWaiverProgramCard" + JSON.stringify(error));
        }
    }


    /**
     * @function 		: handleVisitDashboardClick.
     * @description 	: method to get Waiver Application Number.
     **/
    handleVisitDashboardClick = () => {
        try {
            this.showSpinner = true;
            let waiverURL;
            triggerWaiverTokenGeneration({
                caseNumber: this.caseNumber,
                IndividualId: this.individualId,
                Name: this.individualName,
                targetWidget: "DSH_020"
            })
            .then(result => {                   
                const parsedData = result.mapResponse;  
                if (
                    !sspUtility.isUndefinedOrNull(parsedData) &&
                    parsedData.hasOwnProperty("ERROR")
                ) {
                    this.errorCode = parsedData.ERROR;
                    this.showErrorModal = true;                       
                
                }
                else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    if (parsedData.hasOwnProperty("tokenId" )) {
                        waiverURL = parsedData.tokenId;
                    }
            
                    if(waiverURL !== undefined && waiverURL !== null && waiverURL !== ""){
                        window.open(waiverURL);
                    }
                    this.showSpinner = false;
                }
                
            });
        }
        catch (error) {
            console.error("Error in handleVisitDashboardClick in sspBenefitsWaiverProgramCard" + JSON.stringify(error));
        }
    }


    /**
     * @function 		: handleContinueApplicationClick.
     * @description 	: method to get Waiver Application Number.
     **/
    handleContinueApplicationClick = () => {
        try {
            this.showSpinner = true;
            let waiverURL;
            triggerWaiverTokenGeneration({
                caseNumber: this.caseNumber,
                IndividualId: this.individualId,
                Name: this.individualName,
                WaiverApplicationNumber: this.applicationNumber,
                targetWidget: "APP_004"
            })
            .then(result => {                   
                const parsedData = result.mapResponse;  
                if (
                    !sspUtility.isUndefinedOrNull(parsedData) &&
                    parsedData.hasOwnProperty("ERROR")
                ) {
                    this.errorCode = parsedData.ERROR;
                    this.showErrorModal = true;                       
                
                }
                else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    if (parsedData.hasOwnProperty("tokenId" )) {
                        waiverURL = parsedData.tokenId;
                    }
            
                    if(waiverURL !== undefined && waiverURL !== null && waiverURL !== ""){
                        window.open(waiverURL);
                    }
                    this.showSpinner = false;
                }
                
            });
        }
        catch (error) {
            console.error("Error in handleContinueApplicationClick in sspBenefitsWaiverProgramCard" + JSON.stringify(error));
        }
    }

}