import { api, track } from "lwc";
import sspUtility from "c/sspUtility";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

import nextStep from "@salesforce/label/c.SSP_NextStep";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import caseHash from "@salesforce/label/c.SSP_CaseHashcolon";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import uploadDocumentation from "@salesforce/label/c.SSP_UploadDocumentation";
import documentUploadNote from "@salesforce/label/c.SSP_DocumentUploadNote";
import documentCenterButton from "@salesforce/label/c.SSP_DocumentCenterButton";
import applyWaiver from "@salesforce/label/c.SSP_ApplyWaiver";
import applyWaiverNote from "@salesforce/label/c.SSP_ApplyWaiverNote";
import needMoreHelp from "@salesforce/label/c.SSP_NeedMoreHelp";
import needMoreHelpNote from "@salesforce/label/c.SSP_NeedMoreHelpNote";
import visitHealthcare from "@salesforce/label/c.SSP_VisitHealthcare";
import sspLowCostHealthInsurance from "@salesforce/label/c.sspLowCostHealthInsurance";
import sspHealthBenefitExchange from "@salesforce/label/c.sspHealthBenefitExchange";
import visitHealthcareNote from "@salesforce/label/c.SSP_VisitHealthcareNote";
import homePageApplyBenefit from "@salesforce/label/c.sspHomePageApplyBenefit";
import eligibleOtherPrograms from "@salesforce/label/c.SSP_EligibleOtherPrograms";
import documentsUploadNote from "@salesforce/label/c.SSP_kiHippDocumentUploadNote";
import completeInterview from "@salesforce/label/c.SSP_CompleteInterview";
import completeInterviewNote from "@salesforce/label/c.SSP_CompleteInterviewNote";
import interviewByPhone from "@salesforce/label/c.SSP_InterviewByPhone";
import phoneInterview from "@salesforce/label/c.SSP_DcbsPhoneInterview";
import interviewAtOffice from "@salesforce/label/c.SSP_InterviewAtOffice";
import visitOfficeInterview from "@salesforce/label/c.SSP_VisitOfficeInterview";
import callOfficeButton from "@salesforce/label/c.SSP_CallDcbs";
import findOfficeButton from "@salesforce/label/c.SSP_FindOffice";
import viewMore from "@salesforce/label/c.SSP_ViewMore";
import takeActionNow from "@salesforce/label/c.SSP_TakeActionNow";
import receiveSnapBenefits from "@salesforce/label/c.SSP_RecieveSnapBenefits";
import overviewKTAPDescription from "@salesforce/label/c.sspOverviewKTAPDescription";
import homePagePremiumAssistContent2 from "@salesforce/label/c.sspHomePagePremiumAssistContent2";
import homePageChildAssistContent2 from "@salesforce/label/c.sspHomePageChildAssistContent2";
import homePageFoodAssistanceContent2 from "@salesforce/label/c.sspHomePageFoodAssistanceContent2";
import homePageHealthAssistContent2 from "@salesforce/label/c.sspHomePageHealthAssistContent2";
import goDashboard from "@salesforce/label/c.SSP_GoDashboard";
import kTAP from "@salesforce/label/c.SSP_KTAP";
import kIHIPP from "@salesforce/label/c.SSP_KIHIPP";
import startBenefitsAppCCAP from "@salesforce/label/c.SSP_StartBenefitsAppCCAP";
import sNAP from "@salesforce/label/c.SSP_SNAP";
import medicaid from "@salesforce/label/c.SSP_NextStepsMedicaid";
import sspDocumentsName from "@salesforce/label/c.SSP_DocumentsName"; // changed as part of defect 370975
import sspDocumentVerificationHeader from "@salesforce/label/c.sspDocumentVerificationHeader";
import sspDocumentVerificationContent from "@salesforce/label/c.sspDocumentVerificationContent";
import invokeDashboardBenefitsCallOut from "@salesforce/apex/SSP_DashboardController.triggerBenefitsServiceCall";
import triggerDashboardServiceCallOut from "@salesforce/apex/SSP_DashboardController.triggerDashboardServiceCallOut";
import getHOHContactForNextSteps from "@salesforce/apex/SSP_DashboardController.getHOHContactForNextSteps";
import impersonateCitizenOnLoad from "@salesforce/apex/SSP_RoleSelection.impersonateCitizenOnLoad";

import documentUploadNoteForKiHIPP from "@salesforce/label/c.SSP_NextStepsVerification";
//Added by kyathi as part of 5.8.3
import sspAuthNotGivenAccessText1 from "@salesforce/label/c.SSP_AuthNotGivenAccessText1";
import sspAuthNotGivenAccessText2 from "@salesforce/label/c.SSP_AuthNotGivenAccessText2";
import sspAuthRequestNotProcessedText1 from "@salesforce/label/c.SSP_AuthRequestNotProcessedText1";
import sspAuthRequestNotProcessedText2 from "@salesforce/label/c.SSP_AuthRequestNotProcessedText2";
import sspAlternativelyCallDCBS from "@salesforce/label/c.SSP_AlternativelyCallDCBS";
import sspNoCaseAccessText3 from "@salesforce/label/c.SSP_NoCaseAccessText3";
import sspMapAddress from "@salesforce/label/c.SSP_MapAddress";
import sspMAPLinkTitle from "@salesforce/label/c.SSP_MAPLinkTitle";
import sspMapLink from "@salesforce/label/c.SSP_MapLink";
import sspReturnToDCBS from "@salesforce/label/c.SSP_ReturnToDCBS";
import sspContactRegardingAuthApplication from "@salesforce/label/c.SSP_ContactRegardingAuthApplication";
//added as part of 381907
import requestAccess from "@salesforce/apex/SSP_AuthRepAccessRequestService.getRequestAccessPermission";


export default class SspNextSteps extends NavigationMixin(BaseNavFlowPage) {
    label = {
        sspHealthBenefitExchange,
        sspLowCostHealthInsurance,
        nextStep,
        benefitsApplication,
        caseHash,
        learnMoreLink,
        uploadDocumentation,
        documentUploadNote,
        documentCenterButton,
        applyWaiver,
        applyWaiverNote,
        needMoreHelp,
        needMoreHelpNote,
        visitHealthcare,
        visitHealthcareNote,
        homePageApplyBenefit,
        eligibleOtherPrograms,
        documentsUploadNote,
        completeInterview,
        completeInterviewNote,
        interviewByPhone,
        phoneInterview,
        interviewAtOffice,
        visitOfficeInterview,
        callOfficeButton,
        findOfficeButton,
        viewMore,
        takeActionNow,
        receiveSnapBenefits,
        goDashboard,
        sspDocumentVerificationHeader,
        sspDocumentVerificationContent,
        documentUploadNoteForKiHIPP,
        sspAuthNotGivenAccessText1,
        sspAuthNotGivenAccessText2,
        sspAuthRequestNotProcessedText1,
        sspAuthRequestNotProcessedText2,
        sspAlternativelyCallDCBS,
        sspNoCaseAccessText3,
        sspMapAddress,
        sspMAPLinkTitle,
        sspMapLink,
        sspReturnToDCBS,
        sspContactRegardingAuthApplication
    };

    icInfoUrl = sspIcons + apConstants.url.infoIcon;

    programList = [
        {
            programName: kTAP,
            programCode: apConstants.programValues.KT,
            programText: overviewKTAPDescription
        },
        {
            programName: kIHIPP,
            programCode: apConstants.programValues.KP,
            programText: homePagePremiumAssistContent2
        },
        {
            programName: startBenefitsAppCCAP,
            programCode: apConstants.programValues.CC,
            programText: homePageChildAssistContent2
        },
        {
            programName: sNAP,
            programCode: apConstants.programValues.SN,
            programText: homePageFoodAssistanceContent2
        },
        {
            programName: medicaid,
            programCode: apConstants.programValues.MA,
            programText: homePageHealthAssistContent2
        }
    ];

    @api nextStepsData;
    @api caseNumberData;
    @api isRFI;
    @track showSpinner;
    @track dashboardService = false;
    @track dashboardBenefit = false;
    @track isCallCompleted = false;
    @track isMoreHelpModal = false;
    @track additionalProgramLists = [];
    @track pendingInterviewPrograms = [];
    @track showLearnMore = false;
    @track modValue;
    @track reference=this; 
    @track showDocumentVerifyModal = false;
    @api showVerificationText ; // Ki-HIPP  DDD5 CR 6.11.2
    @api isNextStepsNotAccessible = false; //CD2 2.5 Security Role Matrix.
    @api isNextStepsShowAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    @api isInfoModalNotAccessible = false; //CD2 2.5 Security Role Matrix.
    @api isReadOnlyInfoModal = false; //CD2 2.5 Security Role Matrix.
    @track appRejected = false;
    @track nonMedicaidWithoutElectronicConsent = false;
    @track medicaidWithOtherWithoutElectronicConsent = false;
    @track medicaidOnlyWithoutElectronicConsent = false;
    @track mapURLLink = sspMapAddress;
    @track hasAuthRepHasAccess = false;
    @track applicationId;
   
    // changes for KI-HIPP Enhancement DDD4 CR 6.11.2
    get isShowKPPendingVerificationNote (){
        return this.isKPPendingVerification
            ? this.nextStepsData.isKPPendingVerification
            : "";
    }
    // end 

    get isVerificationPending () {
        return this.nextStepsData
            ? this.nextStepsData.isPendingVerification
            : "";
    }

    get isInterviewPending () {
        const interviewStatus = this.nextStepsData
            ? this.nextStepsData.isPendingInterview
            : "";
        this.pendingInterviewPrograms = interviewStatus
            ? this.programMapping(this.nextStepsData.pendingInterviewPrograms)
            : [];

        return interviewStatus;
    }
    get additionalProgramStatus () {
        const additionalProgramsLength =
            this.nextStepsData.additionalPrograms.length > 0;

        this.additionalProgramLists = additionalProgramsLength
            ? this.programMapping(this.nextStepsData.additionalPrograms)
            : [];
        return additionalProgramsLength;
    }

    get uploadDocumentStatus () {
        return this.isVerificationPending || (this.isInterviewPending && this.isRFI)|| (this.isShowKPPendingVerificationNote) || this.showVerificationText;
    }

    get applyWaiverStatus () {
        return this.nextStepsData.ProgramCode.includes(
            apConstants.programValues.MA
        );
    }

    get visitHealthCareStatus () {
        return this.applyWaiverStatus && this.nextStepsData.isReferredToFFM;
    }

    get moreInformationStatus () {
        return this.nextStepsData.ProgramCode.includes(
            apConstants.programValues.SN
        );
    }

    openMoreHelpModal = () => {
        try {
            this.isMoreHelpModal = !this.isMoreHelpModal;
        } catch (error) {
            console.error("Error calling openMoreHelpModal: ", error);
        }
    };
    /**
     * @function : programMapping
     * @description : This method is used to map the program code with program names.
     * @param {*} compareProgram  - : List of program codes.
     */
    programMapping (compareProgram) {
        try {
            return this.programList.filter(program =>
                compareProgram.includes(program.programCode)
            );
        } catch (error) {
            console.error("Error in programMapping", error);
        }
    }

    /**
     * @function : navigationFunction
     *  * @description : This method used to navigate to different pages.
     * @param {*}event - Fired on selection of option.
     */
    navigationFunction (event) {
        try {
            const selectedPage = event.currentTarget.getAttribute("data-page");

            //Modified for Tracker defect# 68 - to impersonate citizen for Waiver user.
            getHOHContactForNextSteps({applicationId : this.applicationId})
            .then(response => {
                if (response && response.mapResponse) {
                    if (response.mapResponse.isWaiverRole) {
                        const jsonContact = response.mapResponse.contactJSON;
                        impersonateCitizenOnLoad({ contactJson: jsonContact })
                        .then((result) => {
                            this[NavigationMixin.Navigate]({ 
                                type: "comm__namedPage", 
                                attributes: {
                                    name: selectedPage
                                }
                            });
                        });
                    }
                    else {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",

                            attributes: {
                                name: selectedPage
                            }
                        });
                    }
                }
            });
        } catch (error) {
            console.error("Error in navigationFunction", error);
        }
    }
    /**
     * @function learnMoreModal
     * @description This method is used to show learn more modal.
     */
    learnMoreModal () {
        try {
            this.showLearnMore = true;
            return false;
        } catch (error) {
            console.error("Error in learnMoreModal", error);
        }
        return null;
    }
    /**
     * @function closeLearnMoreModal
     * @description This method is used to close learn more modal.
     */
    closeLearnMoreModal () {
        try {
            this.showLearnMore = false;
        } catch (error) {
            console.error("Error in closeLearnMoreModal", error);
        }
    }
    /**
     * @function openDocumentVerifyModal
     * @description This method is used to show document verify modal.
     */
    openDocumentVerifyModal () {
        try {
            this.showDocumentVerifyModal = true;
            return false;
        } catch (error) {
            console.error("Error in openDocumentVerifyModal", error);
        }
        return null;
    }
    /**
     * @function closeDocumentVerifyModal
     * @description This method is used to close document verify modal.
     */
    closeDocumentVerifyModal () {
        try {
            this.showDocumentVerifyModal = false;
        } catch (error) {
            console.error("Error in closeDocumentVerifyModal", error);
        }
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
     * @function - connectedCallback
     * @description - Connected callback - to retrieve values related to validation framework.
     */

    connectedCallback () {
        try {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            this.showHelpContentData("SSP_ShortSNAP_NextSteps");
            const url = new URL(window.location.href);
            this.applicationId = url.searchParams.get("applicationId");
          this.showSpinner = true;
          requestAccess ({appId: this.applicationId})
                .then(result => {
                 let objACR;
                 let electronicConsentAvailable = false;             
                 if((!sspUtility.isUndefinedOrNull(result)) && (!sspUtility.isUndefinedOrNull(result.mapResponse))){             
                 if ("electronicConsent" in result.mapResponse) { 
                    electronicConsentAvailable = true;
                 }                   
                 if("isAuthRep" in result.mapResponse) {  
                 if ("requestPermission" in result.mapResponse) {                       
                        objACR =  JSON.parse(result.mapResponse.requestPermission);                       
                        if (
                            (!electronicConsentAvailable) &&
                            objACR.PermissionLevel_Medicaid__c !==
                                undefined &&
                                objACR.PermissionLevel_SNAP__c ===
                                undefined &&
                                objACR.PermissionLevel_StateSupp__c ===
                                undefined &&
                                objACR.PermissionLevel_KIHIPP__c ===
                                undefined &&
                                objACR.PermissionLevel_KTAP__c ===
                                undefined &&
                                objACR.PermissionLevel_CCAP__c ===
                                undefined
                        ) {
                            this.medicaidOnlyWithoutElectronicConsent = true;
                        }else  if (
                            (!electronicConsentAvailable) &&
                            objACR.PermissionLevel_Medicaid__c !==
                                undefined &&
                            (objACR.PermissionLevel_SNAP__c !==
                                undefined ||
                                objACR.PermissionLevel_StateSupp__c !==
                                    undefined ||
                                    objACR.PermissionLevel_KIHIPP__c !==
                                    undefined ||
                                    objACR.PermissionLevel_KTAP__c !==
                                    undefined ||
                                    objACR.PermissionLevel_CCAP__c !==
                                    undefined)
                        ) {
                            this.medicaidWithOtherWithoutElectronicConsent = true;
                        }else  if (
                            (!electronicConsentAvailable) &&
                            objACR.PermissionLevel_Medicaid__c ===
                                undefined &&
                            (objACR.PermissionLevel_SNAP__c !==
                                undefined ||
                                objACR.PermissionLevel_StateSupp__c !==
                                    undefined ||
                                    objACR.PermissionLevel_KIHIPP__c !==
                                    undefined ||
                                    objACR.PermissionLevel_KTAP__c !==
                                    undefined ||
                                    objACR.PermissionLevel_CCAP__c !==
                                    undefined)
                        ) {
                            this.nonMedicaidWithoutElectronicConsent = true;
                           
                        }
                    }else if(!("hasAccess" in result.mapResponse)){
                        this.appRejected = true;
                    }
                    if(!(this.appRejected || this.medicaidOnlyWithoutElectronicConsent || this.nonMedicaidWithoutElectronicConsent ||
                        this.medicaidWithOtherWithoutElectronicConsent)){
                            this.hasAuthRepHasAccess = true;
                        }
                    } else{
                        this.hasAuthRepHasAccess = true; 
                    }
                }
                    this.showSpinner = false;
                })
                .catch({});
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }
    
    navigateToDocumentCenter () {
        try {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: sspDocumentsName
            }
        });
        } catch (error) {
            console.error("Error in navigateToDocumentCenter", error);
        }
    }
    visitHealthCare () {
        try {
            window.open(apConstants.url.healthBenefitExchange, "_blank");
        } catch (error) {
            console.error("Error in visitHealthCare", error);
        }
    }
    /**
     * @function : applyForBenefitsNav
     * @description : This method used to navigate on click of Apply for other benefits.
     */
    applyForBenefitsNav () {
        try {
            this.showSpinner = true;
            triggerDashboardServiceCallOut()
            .then(result => {
                this.dashboardService = true;
                this.allowNavigation ();
            })
            .catch(error => {
                console.error(
                    "Error in dashboard service call" +
                        JSON.stringify(error)
                );
            });
            invokeDashboardBenefitsCallOut()
            .then(result => {
                this.dashboardBenefit = true;
                this.allowNavigation ();
            })
            .catch(error => {
                console.error(
                    "Error in dashboard benefits call" +
                        JSON.stringify(error)
                );
            });
        } catch (error) {
            console.error("Error in applyForBenefitsNav", error);
        }
    }

    allowNavigation () {
        if(this.dashboardService && this.dashboardBenefit){
            this.showSpinner = false;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",

                attributes: {
                    name: "getStartedBenefits__c"
                }
            }); 
        }
    }
}
