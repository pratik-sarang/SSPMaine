/* eslint-disable no-console */
import { track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import getBenefitsData from "@salesforce/apex/SSP_BenefitsPageController.getBenefitsData";
import applicationButtonDetails from "@salesforce/apex/SSP_BenefitsPageController.applicationButtonDetails";
import getMemberTypeFlag from "@salesforce/apex/SSP_DashboardController.getMemberTypeFlag";
import resumeApplication from "@salesforce/apex/SSP_DashboardController.resumeApplication";
import getDashboardRefreshFlag from "@salesforce/apex/SSP_BenefitsPageController.getDashboardRefreshFlag";
import invokeDashboardBenefitsCallOut from "@salesforce/apex/SSP_DashboardController.triggerBenefitsServiceCall";
import triggerDashboardServiceCallOut from "@salesforce/apex/SSP_DashboardController.triggerDashboardServiceCallOut";
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
import sspInterestedInOtherStatePrograms from "@salesforce/label/c.sspInteresetedInOtherStatePrograms";

import sspBenefits from "@salesforce/label/c.sspBenefits";
import sspViewManageApprovedPrograms from "@salesforce/label/c.sspViewManageApprovedPrograms";
import sspReportAChange from "@salesforce/label/c.SSP_ReportAChange";
import sspKeepYourBenefits from "@salesforce/label/c.sspKeepYourBenefits";
import sspCaseHash from "@salesforce/label/c.SSP_CaseHash";
import sspIsUpForRenewal from "@salesforce/label/c.sspIsUpForRenewal";
import sspRenewBenefits from "@salesforce/label/c.SSP_RenewBenefits";
import sspSearchChildCareProviders from "@salesforce/label/c.sspSearchChildCareProviders";
import sspSearchStateApprovedProviders from "@salesforce/label/c.sspSearchStateApprovedProviders";
import sspSearchProviders from "@salesforce/label/c.sspSearchProviders";
import sspApplyForBenefits from "@salesforce/label/c.sspApplyForBenefits";
import sspGetBenefitsHealthFood from "@salesforce/label/c.sspGetBenefitsHealthFood";
import sspAddOtherBenefits from "@salesforce/label/c.sspAddOtherBenefits";
import sspActivePendingCases from "@salesforce/label/c.sspActivePendingCases";
import sspInactiveCases from "@salesforce/label/c.sspInactiveCases";



import sspReferralMadeToFFM from "@salesforce/label/c.sspRefferalMadeToFFM";
import sspUtility from "c/sspUtility";

export default class SspBenefitsPage extends NavigationMixin(BaseNavFlowPage) {

    @track openDropDown = false;
    @track renewalCaseNumbersSet = [];
    @track buttonLabel = "";
    @track isHeadOfHousehold = false;
    @track isChangeMode = false;
    @track isJORITWIST = false; //is true if Ownership field has value- JORI/TWIST/ICAMA/ICPC/FCM/ASM
    @track ownershipFlag = "";
    @track isDAILOwner = false;
    @track showScreen= false;
    @track showAccessDenied= false;
    @track isTMember = false;
    @track isWorkerPortalBannerVisible = false;
    @track renderingMap = {};

    @track cardName = "SNAP";
    @track caseNo = 3456789555;
    @track months = ["April", "May"];
    @track amount = ["$222", "$999"];
    @track applicants = "John Doe, Jane Doe, Jill Doe";
    @track status = "Approved";
    @track dateFieldAlpha = [sspBenefitPeriod];
    @track dateFieldBeta = [sspCardFundsLoadedOn, sspRenewalDate];
    @track noticeMessage = [sspAdditionalVerification];
    @track noticeMessageLink = [sspUploadDocuments];
    @track showSpinner = true;
    @track showRACPopUp = false;
    @track strActiveCases = "";
    @track selectedRole = "";
    @track isDAILCBWOwner = false;
    @track hasRACCases = false;
    @track loggedInIndividualId;

    @track activePrograms = [];
    @track inactivePrograms = [];
    @track listPendingApps = [];
    @track availablePrograms = [];
    @track caseVsStatusMap = {};
    @track mapWaiverDetails = {};
    @track mapWaiverStatus = {};
    @track listWaiverStatus = [];

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
        sspBenefits,
        sspViewManageApprovedPrograms,
        sspReportAChange,
        sspKeepYourBenefits,
        sspCaseHash,
        sspIsUpForRenewal,
        sspRenewBenefits,
        sspInterestedInOtherStatePrograms,
        sspSearchChildCareProviders,
        sspSearchStateApprovedProviders,
        sspSearchProviders,
        sspApplyForBenefits,
        sspGetBenefitsHealthFood,
        sspAddOtherBenefits,
        sspActivePendingCases,
        sspInactiveCases
    };

  
    /**
     * @function 		: connectedCallback.
     * @description 	: method to handle rac popUp.
     **/
    connectedCallback () {
        // CD2 2.5 Security Role Matrix.
        this.renderingMap = {
            showCCPS: {
                id: "BEN_CCPS",
                isAccessible: true
            },
            showDiscontinue: {
                id: "BEN_DISCONTINUE",
                isAccessible: true
            },
            showDisqualification: {
                id: "BEN_DISQUAL",
                isAccessible: true
            },
            showPastApps: {
                id: "BEN_PASTAPP",
                isAccessible: true
            },
            showRAC: {
                id: "BEN_RAC",
                isAccessible: true
            },
            showRenewal: {
                id: "BEN_RENEW",
                isAccessible: true
            },
            showCCEnrollSummary: {
                id: "BEN_CCEnrollSummary",
                isAccessible: true
            },
            showPreferredPayMethod: {
                id: "BEN_PreferredPayMethod",
                isAccessible: true
            },
            showReqMedCard: {
                id: "BEN_ReqMedCard",
                isAccessible: true
            },
            showUploadDoc: {
                id: "BEN_UploadDoc",
                isAccessible: true
            },
            showViewDenialNotice: {
                id: "BEN_ViewDenialNotice",
                isAccessible: true
            },
            showViewEligibility: {
                id: "BEN_ViewEligibility",
                isAccessible: true
            },
            showViewPaySummary: {
                id: "BEN_ViewPaySummary",
                isAccessible: true
            },
            showViewPenalty: {
                id: "BEN_ViewPenalty",
                isAccessible: true
            },
            showViewSuspension: {
                id: "BEN_ViewSuspension",
                isAccessible: true
            },
            showVisitHealthcare: {
                id: "BEN_VisitHealthcare",
                isAccessible: true
            },
            showWaiverContinueApp: {
                id: "BEN_WaiverContinueApp",
                isAccessible: true
            },
            showWaiverDashboard: {
                id: "BEN_WaiverDashboard",
                isAccessible: true
            },
            showWaiverReq: {
                id: "BEN_WaiverReq",
                isAccessible: true
            },
             //Shikha
             showKinship : {
                id: "BEN_KinshipCare",
                isAccessible: true
            },
            showAddApplyBenefits : {
                id: "BEN_AddApplyBenefits",
                isAccessible: true
            }
        };

        //Call Apex to check if refresh needed for dashboard
        getDashboardRefreshFlag().then(data => {
            if (data && data.mapResponse && data.mapResponse.refreshNeeded) {
                triggerDashboardServiceCallOut()
                .then( () => {
                    invokeDashboardBenefitsCallOut();
                })
                .then ( () => {
                    this.getDataFromController();
                })
            }
            else {
                this.getDataFromController();
            }
            //this.showSpinner = false;
        })
    }


    getDataFromController = () => {
        try {
            //Call Apex Controller method to get benefits related data
            applicationButtonDetails().then(response => {
                if (response) {

                    if (response.mapResponse && response.mapResponse.hasOwnProperty("listUnderReviewApplicationVsPrograms") && JSON.parse(response.mapResponse.listUnderReviewApplicationVsPrograms).length > 0) {
                        this.activePrograms.push(JSON.parse(response.mapResponse.listUnderReviewApplicationVsPrograms)[0]);
                    }

                    if (response.mapResponse && response.mapResponse.hasOwnProperty("individualId")) {
                        this.loggedInIndividualId = response.mapResponse.individualId;
                    }

                    if (response.mapResponse && response.mapResponse.hasOwnProperty("screenPermission")) {
                        const {screenPermission:securityMatrix} = response.mapResponse;
                        const ids = (!sspUtility.isUndefinedOrNull(securityMatrix) && !sspUtility.isUndefinedOrNull(securityMatrix.fieldPermissions)) ? Object.keys(securityMatrix.fieldPermissions) : null;
                        for (const elementName of Object.keys(this.renderingMap)) {
                            if (!sspUtility.isUndefinedOrNull(ids) && ids.indexOf(this.renderingMap[elementName].id) > -1 && securityMatrix.fieldPermissions[this.renderingMap[elementName].id] === "NotAccessible") {
                                this.renderingMap[elementName].isAccessible = false;
                            } else {
                                this.renderingMap[elementName].isAccessible = true;
                            }
                        }
                    }
                    if (response.mapResponse && response.mapResponse.hasOwnProperty(apConstants.headerConstants.selectedRole)) {
                        this.selectedRole = response.mapResponse.selectedRole;
                    }
                    
                    if (response.mapResponse && response.mapResponse.hasOwnProperty("hasActiveCases") && response.mapResponse.hasActiveCases) {
                            this.buttonLabel = this.labels.sspAddOtherBenefits;
                    }
                    else {
                        this.buttonLabel = this.labels.sspApplyForBenefits;
                    }

                    if (response.mapResponse && response.mapResponse.hasOwnProperty("hasPendingApplication") && response.mapResponse.hasOwnProperty("listPendingApps") && !sspUtility.isUndefinedOrNull(response.mapResponse.listPendingApps)) {
                        this.listPendingApps = response.mapResponse.listPendingApps;
                    }
                    if (response.mapResponse && response.mapResponse.hasOwnProperty("programLevelAccess") && !sspUtility.isUndefinedOrNull(response.mapResponse.programLevelAccess)) {
                        this.availablePrograms = response.mapResponse.programLevelAccess;
                    }
                    if (response.mapResponse && response.mapResponse.hasOwnProperty("hasRACCases")) {
                        this.strActiveCases = response.mapResponse.hasRACCases;
                        this.hasRACCases = true;
                    }
                }
            })
            .then(() => {
                getMemberTypeFlag().then(result => {
                    if (!sspUtility.isUndefinedOrNull(result) && !sspUtility.isUndefinedOrNull(result.mapResponse) && !sspUtility.isUndefinedOrNull(result.mapResponse.memberType)) {
                        this.isHeadOfHousehold = (result.mapResponse.memberType).includes(apConstants.headerConstants.HOH);
                        this.isTMember = (result.mapResponse.memberType).includes(apConstants.headerConstants.TMEM);
                    }
                    if (!sspUtility.isUndefinedOrNull(result) && !sspUtility.isUndefinedOrNull(result.mapResponse) && !sspUtility.isUndefinedOrNull(result.mapResponse.ownerType)) {
                        this.ownershipFlag = result.mapResponse.ownerType;
                        if (this.ownershipFlag.includes(apConstants.headerConstants.CHANGE)) {
                            this.isChangeMode = true;
                            this.isWorkerPortalBannerVisible = true;
                        }
                        if ((this.ownershipFlag.includes(apConstants.headerConstants.DAIL) && this.selectedRole !== apConstants.headerConstants.DAIL_Worker) || this.ownershipFlag.includes(apConstants.headerConstants.CBW)) {
                            this.isDAILCBWOwner = true;
                        }
                        if (this.ownershipFlag.includes(apConstants.headerConstants.DAIL)) {
                            this.isDAILOwner = true;
                        }
                        if (this.ownershipFlag.includes("JORI") || this.ownershipFlag.includes("TWIST") || this.ownershipFlag.includes("ICAMA") || this.ownershipFlag.includes("ICPC") || this.ownershipFlag.includes("FCM") || this.ownershipFlag.includes("ASM")) {
                            this.isJORITWIST = true;
                        }
                    }

                });
            })
            .then(() => {
                //Call Apex Controller method to get benefits related data
                getBenefitsData().then(result => {
                    if (result) {
                        if (result.mapResponse.hasOwnProperty("mapWaiverDetails")) {
                            this.mapWaiverDetails = JSON.parse(result.mapResponse.mapWaiverDetails);
                        }
                        if (result.mapResponse.hasOwnProperty("mapWaiverStatus")) {
                            this.mapWaiverStatus = JSON.parse(result.mapResponse.mapWaiverStatus);
                        }
                        if (result.mapResponse.hasOwnProperty("listWaiverStatus")) {
                            this.listWaiverStatus = JSON.parse(result.mapResponse.listWaiverStatus);
                        }

                        if ( result.mapResponse.hasOwnProperty("showScreen") && result.mapResponse.showScreen) {
                            this.showScreen = true;
                        }else{
                            this.showAccessDenied = true;
                        }
                        if (result.mapResponse.hasOwnProperty("disabled")) {
                            this.disabled = true;
                        }
                        if ( result.mapResponse && result.mapResponse.hasOwnProperty("CaseVsStatus") ) {
                            this.caseVsStatusMap = JSON.parse(result.mapResponse.CaseVsStatus);
                        }
                        if ( result.mapResponse && result.mapResponse.hasOwnProperty("renewalCaseNumbersSet") ) {
                            this.renewalCaseNumbersSet = result.mapResponse.renewalCaseNumbersSet;
                        }
                        if (result.mapResponse && result.mapResponse.hasOwnProperty("activeCases") && !sspUtility.isUndefinedOrNull(result.mapResponse.activeCases)) {
                            Array.prototype.push.apply(this.activePrograms, JSON.parse(result.mapResponse.activeCases));
                        }
                        if (result.mapResponse && result.mapResponse.hasOwnProperty("inactiveCases") && !sspUtility.isUndefinedOrNull(result.mapResponse.inactiveCases)) {
                            this.inactivePrograms = JSON.parse(result.mapResponse.inactiveCases);
                        }

                    }            
                })
                .then (() => {
                    const activeTab = this.template.querySelectorAll(".ssp-activeBenefits");
                    const inactiveTab = this.template.querySelectorAll(".ssp-inactiveBenefits");
                    if (JSON.parse(JSON.stringify(this.activePrograms)).length === 0 && JSON.parse(JSON.stringify(this.inactivePrograms)).length > 0) {
                        activeTab.forEach(element => {
                            element.classList.remove("ssp-active");
                            element.classList.remove("ssp-show");
                        });
                        inactiveTab.forEach(element => {
                            element.classList.add("ssp-active");
                            element.classList.add("ssp-show");
                        });
                    }
                    else {
                        activeTab.forEach(element => {
                            element.classList.add("ssp-active");
                            element.classList.add("ssp-show");
                        });
                        inactiveTab.forEach(element => {
                            element.classList.remove("ssp-active");
                            element.classList.remove("ssp-show");
                        });
                    }
                    
                    this.showSpinner = false
                });
            });
        } catch (error) {
            console.error(
                "failed in getDataFromController in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    }


    /**
     * @function : openSelected
     * @description : This method is used to open a selected tab.
     * @param {*} event - Returns a particular tab.
     */
    openSelected (event) {
        if (
            event.type === "click" ||
            (event.type === "keydown" && event.keyCode === 13)
        ) {
            const tabs = this.template.querySelectorAll(".ssp-Tab");
            const tabsContent = this.template.querySelectorAll(
                ".ssp-TabsContent"
            );
            tabs.forEach(element => {
                element.classList.remove("ssp-active");
            });
            event.target.classList.add("ssp-active");
            for (let i = 0; i < tabs.length; i++) {
                if (tabs[i].classList.contains("ssp-active")) {
                    tabsContent[i].classList.add("ssp-show");
                } else {
                    tabsContent[i].classList.remove("ssp-show");
                }
            }
        }
    }

    /**
     * @function 		: redirectToRenewal.
     * @description 	: renewal redirection.
     **/
    redirectToRenewal = () => {
        this.showSpinner = true;
        this[NavigationMixin.Navigate]({
            type: apConstants.communityPageNames.community,
            attributes: {
                name: apConstants.communityPageNames.renewals
            },
            state: {
                mode: "Renewal"
            }
        });
        this.showSpinner = false;
    };

    /**
     * @function 		: navigateToBenefitsScreen.
     * @description 	: method to navigate to benefits Page.
     **/
    navigateToBenefitsScreen = () => {
        this.showSpinner = true;
        try {
            if (this.listPendingApps.length > 0) {
                resumeApplication({
                    sApplicationId: this.listPendingApps[0]
                }).then(() => {
                    this[NavigationMixin.Navigate]({
                        type: apConstants.communityPageNames.community,
                        attributes: {
                            name: apConstants.communityPageNames.applicationSummaryApi
                        },
                        state: {
                            applicationId: this.listPendingApps[0],
                            mode: "intake"
                        }
                    });
                })
            }
            else {
                this[NavigationMixin.Navigate]({
                    type: apConstants.communityPageNames.community,
                    attributes: {
                        name: apConstants.communityPageNames.getStartedBenefits
                    }
                });
            }
            
        } catch (error) {
            console.error(
                "failed in navigateToBenefitsScreen in sspDashboardExistingUser" +
                    JSON.stringify(error)
            );
        }
    };


    /**
     * @function 		: handleRac.
     * @description 	: method to handle navigation on click of rac button.
     **/
    handleRac = () => {
        this.showSpinner = false;
        this.showRACPopUp = true;
    }


    /**
     * @function 		: handleChildCareSearch.
     * @description 	: method for handleChildCareSearch.
     **/
    handleChildCareSearch = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: apConstants.communityPageNames.community,
                attributes: {
                    pageName: "child-care-provider"
                },
                state: {
                    origin: "benefits-page"
                }
            });
        } catch (error) {
            console.error(
                "failed in handleChildCareSearch in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    }


    /**
     * @function 		: handleClose.
     * @description 	: method to handle rac popUp.
     **/
    handleClose () {
        try {
            this.showRACPopUp = false;
        } catch (error) {
            console.error(
                "failed in handleClose in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    }
}