/*
 * Component Name: SspDashboardExistingUser.
 * Author: Kireeti Gora, Venkata.
 * Description: This file handles Dashboard Screen.
 * Date: 03/05/2020.
 **/
import { LightningElement, track, wire } from "lwc";
import sspOverviewIcons from "@salesforce/resourceUrl/sspOverviewIcons";
import apConstants from "c/sspConstants";
import sspTrashIcon from "@salesforce/resourceUrl/SSP_Icons";
import sspKynectImage from "@salesforce/resourceUrl/SSP_KynectImages5";
import { NavigationMixin } from "lightning/navigation";
import invokeDashboardBenefitsCallOut from "@salesforce/apex/SSP_DashboardController.triggerBenefitsServiceCall";
import updateUserLanguage from "@salesforce/apex/SSP_DashboardController.updateUserLanguage";
import invokeDashboardMedicaidCallOut from "@salesforce/apex/SSP_DashboardController.triggerMedicaidMCOServiceCall";
import triggerDashboardServiceCallOut from "@salesforce/apex/SSP_DashboardController.triggerDashboardServiceCallOut";
import getMemberTypeFlag from "@salesforce/apex/SSP_DashboardController.getMemberTypeFlag";
import resumeApplication from "@salesforce/apex/SSP_DashboardController.resumeApplication";
import generateEncryptedData from "@salesforce/apex/SSP_ShoppingIntegration.generateEncryptedData";
import updateReadStatus from "@salesforce/apex/SSP_MessageCenterCtrl.updateReadStatus";
import backYardNavigate from "@salesforce/apex/SSP_DashboardController.backYardNavigate"; //for defect fix 379797
import sspUtility from "c/sspUtility";
import sspCardImages from "@salesforce/resourceUrl/sspCardImages";
import sspAddOtherBenefits from "@salesforce/label/c.SSP_AddOtherBenefits";
import sspReportAChange from "@salesforce/label/c.SSP_ReportAChange";
import sspViewDetailsOnYourBenefitsApplicationCasesAndBenefits from "@salesforce/label/c.SSP_ViewDetailsOnYourBenefitsApplicationCasesAndBenefits";
import sspBenefits from "@salesforce/label/c.SSP_Benefits";
import sspActive from "@salesforce/label/c.SSP_Active";
import sspPending from "@salesforce/label/c.SSP_Pending";
import sspInActive from "@salesforce/label/c.SSP_Inactive";
import sspCase from "@salesforce/label/c.SSP_Case";
import sspApproved from "@salesforce/label/c.SSP_Approved";
import sspPendingInterview from "@salesforce/label/c.SSP_PendingInterview";
import sspPendingVerification from "@salesforce/label/c.SSP_PendingVerification";
import sspViewYourToDoListAndMessages from "@salesforce/label/c.SSP_ViewYourToDoListAndMessages";
import sspMessageCenter from "@salesforce/label/c.SSP_MessageCenter";
import sspToDos from "@salesforce/label/c.SSP_ToDos";
import sspUnread from "@salesforce/label/c.SSP_Unread";
import sspDueThisWeek from "@salesforce/label/c.SSP_DueThisWeek";
import sspNotice from "@salesforce/label/c.SSP_Notice";
import sspNew from "@salesforce/label/c.SSP_New";
import sspAnnouncements from "@salesforce/label/c.SSP_Announcements";
import sspNotifications from "@salesforce/label/c.SSP_Notifications";
import sspViewAndShopForYourCurrentMedicaidPlansAndMCOs from "@salesforce/label/c.SSP_ViewAndShopForYourCurrentMedicaidPlansAndMCOs";
import sspMedicaidPlansMCO from "@salesforce/label/c.SSP_MedicaidPlansMCO";
import sspNotEnrolled from "@salesforce/label/c.SSP_NotEnrolled";
import sspEnrolled from "@salesforce/label/c.SSP_Enrolled";
import sspManageAndViewDetailsAboutYourSupportTeam from "@salesforce/label/c.SSP_ManageAndViewDetailsAboutYourSupportTeam";
import sspRepsAssistersAgents from "@salesforce/label/c.SSP_RepsAssistersAgents";
import sspAuthorizedRepresentative from "@salesforce/label/c.SSP_AuthorizedRepresentative";
import sspIWantTo from "@salesforce/label/c.SSP_IWantTo";
import sspNavigateToCitizenConnect from "@salesforce/label/c.SSP_NavigateToCitizenConnect";
import sspCompleteSNAPAndMedicaidWorkParticipationRequirementsApplyForWorkforce from "@salesforce/label/c.SSP_CompleteSNAPAndMedicaidWorkParticipationRequirementsApplyForWorkforce";
import sspNavigateToLocalResourcePackages from "@salesforce/label/c.SSP_NavigateToLocalResourcePackages";
import sspTheBackYardConnectsKentuckyResidents from "@salesforce/label/c.sspKynectResourcesDescription";
import sspRequestAnEBTCard from "@salesforce/label/c.SSP_RequestAnEBTCard";
import sspSubmitRequestForNewEBTCard from "@salesforce/label/c.SSP_SubmitRequestForNewEBTCard";
import sspHomePageCheckEligibility from "@salesforce/label/c.sspHomePageCheckEligibility";
import sspUseTheScreeningTool from "@salesforce/label/c.SSP_HomePagePrescreeningSubText";
import sspRequestMedicaidCard from "@salesforce/label/c.SSP_RequestMedicaidCard";
import sspSubmitRequestForReplacementMedicaidCard from "@salesforce/label/c.SSP_SubmitRequestForReplacementMedicaidCard";
import sspSearchChildCareProviders from "@salesforce/label/c.SSP_SearchChildCareProviders";
import sspSearchForStateApprovedChildCareProvidersWithinTheCCAPNetwork from "@salesforce/label/c.SSP_SearchForStateApprovedChildCareProvidersWithinTheCCAPNetwork";
import sspRequestTaxForms from "@salesforce/label/c.SSP_RequestTaxForms";
import sspCreateRequestForUsToSendYourDetailsForYourTaxReturnFiling from "@salesforce/label/c.SSP_CreateRequestForUsToSendYourDetailsForYourTaxReturnFiling";
import sspKIHIPPPaymentSummary from "@salesforce/label/c.SSP_KIHIPPPaymentSummary";
import sspContinueApplication from "@salesforce/label/c.SSP_EarlySubmissionModalContinueApplication";
import sspRenewBenefit from "@salesforce/label/c.SSP_RenewBenefits";
import sspRepresentativeDescription from "@salesforce/label/c.SSP_RepresentativeDescription";
import sspAssisterDescription from "@salesforce/label/c.SSP_AssisterDescription";
import sspAgentDescription from "@salesforce/label/c.SSP_AgentDescription";
import sspViewHistoryOfKIHIPPPaymentsForThisHousehold from "@salesforce/label/c.SSP_ViewHistoryOfKIHIPPPaymentsForThisHousehold";
import sspConstants from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import sspYouHaveRequestsForInformationRelatedToYourBenefitsApplication from "@salesforce/label/c.SSP_YouHaveRequestsForInformationRelatedToYourBenefitsApplication";
import sspYouOweAmountOwedForProgramBenefits from "@salesforce/label/c.SSP_YouOweAmountOwedForProgramBenefits";
import sspYouHaveAnNotSubmittedApplication from "@salesforce/label/c.SSP_YouHaveAnUnSubmittedApplication";
import sspCompleteYourBenefitsApplicationBy from "@salesforce/label/c.SSP_CompleteYourBenefitsApplicationBy";
import sspExpiresToday from "@salesforce/label/c.SSP_ExpiresToday";
import sspExpiresInDays from "@salesforce/label/c.SSP_ExpiresInDays";
import sspYouHaveAnNotSubmittedApplicationPastDue from "@salesforce/label/c.SSP_YouHaveAnUnSubmittedApplicationPastDue";
import sspRecommendedOrderHasBeenGeneratedForYourHearing from "@salesforce/label/c.SSP_RecommendedOrderHasBeenGeneratedForYourHearing";
import sspYouHaveDaysToRenewYourMedicaidBenefits from "@salesforce/label/c.SSP_YouHaveDaysToRenewYourMedicaidBenefits";
import sspYourEligibilityResultsForBenefitsAreReadyForYourReview from "@salesforce/label/c.SSP_YourEligibilityResultsForBenefitsAreReadyForYourReview";
import sspYouMustCompleteAnInterviewToRenewYourSNAPBenefits from "@salesforce/label/c.SSP_YouMustCompleteAnInterviewToRenewYourSNAPBenefits";
import sspYouMustCompleteAnInterviewToReceiveChildCareSnapBenefits from "@salesforce/label/c.SSP_YouMustCompleteAnInterviewToReceiveChildCareKtapSnapBenefits";
import sspYouMustScheduleAnInterviewToReceiveSnapBenefits from "@salesforce/label/c.SSP_YouMustScheduleAnInterviewToReceiveSnapBenefits";
import sspWelcome from "@salesforce/label/c.SSP_Welcome";
import sspApplication from "@salesforce/label/c.SSP_Application";
import sspUnderReview from "@salesforce/label/c.SSP_UnderReview";
import sspMyInformation from "@salesforce/label/c.SSP_MyInformation";
import sspApplyForBenefitsDashboard from "@salesforce/label/c.SSP_ApplyForBenefitsDashboard";
import sspAssister from "@salesforce/label/c.SSP_Assister";
import sspInsuranceAgent from "@salesforce/label/c.SSP_InsuranceAgent";
import driverNavigationDetails from "@salesforce/apex/SSP_DashboardController.driverNavigationDetails";
import getCaseOwnershipFlag from "@salesforce/apex/SSP_MyInformationController.getCaseOwnershipFlag";

import sspRenewBenefits from "@salesforce/label/c.SSP_RenewBenefits";
import sspCallDCBS from "@salesforce/label/c.SSP_CallDcbs";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspViewApplication from "@salesforce/label/c.SSP_ViewApplication"; //#379955
import sspPayBalance from "@salesforce/label/c.SSP_PayBalance";
import sspUploadDocuments from "@salesforce/label/c.SSP_UploadDocuments";
import sspReportFraud from "@salesforce/label/c.SSP_ReportFraud";
import sspHelpTheCommonwealthOfKentuckyStopScammers from "@salesforce/label/c.SSP_HelpTheCommonwealthOfKentuckyStopScammers";
//Added by Kyathi as a part of CD2 section 5.8.1.2
import sspAuthRepAccessModalContentOne from "@salesforce/label/c.SSP_AuthRepAccessModalContentOne";
import sspWantsToBeAssister from "@salesforce/label/c.SSP_WantsToBeAssister";
import sspHealthPlans from "@salesforce/label/c.SSP_HealthPlans";
import sspEnrollmentManager from "@salesforce/label/c.SSP_EnrollmentManager";
import sspEnrollmentManagerNonPrimary from "@salesforce/label/c.SSP_EnrollmentManagerNonPrimary";
import sspNoEligibleIndividuals from "@salesforce/label/c.SSP_NoEligibleIndividuals";
import sspAllEligibleIndividuals from "@salesforce/label/c.SSP_AllEligibleIndividuals";
import sspEnrollmentManagerTitle from "@salesforce/label/c.SSP_EnrollmentManagerTitle";
import sspEnrollmentManagerNonPrimaryTitle from "@salesforce/label/c.SSP_EnrollmentManagerNonPrimaryTitle";
import sspReviewAndConsent from "@salesforce/label/c.SSP_ReviewAndConsent";
import sspReviewAndConsentTitle from "@salesforce/label/c.SSP_ReviewAndConsentTitle";
import sspViewMCOHistory from "@salesforce/label/c.SSP_ViewMCOHistory";
import sspMCOHistoryTitle from "@salesforce/label/c.SSP_MCOHistoryTitle";
import sspNoticeCardPhoneNumberLink from "@salesforce/label/c.SSP_NoticeCardPhoneNumberLink";
import medicaidEBTData from "@salesforce/apex/SSP_RequestAMedicaidCard.medicaidEBTData";
import getMemberGenderCode from "@salesforce/apex/SSP_RequestAMedicaidCard.getMemberGenderCode";
//requestACard changes
import sspMedicaidCardSuccessToast from "@salesforce/label/c.SSP_RequestMedicaidCardSuccessToast";
import sspEBTCardSuccessToast from "@salesforce/label/c.SSP_RequestEBTCardSuccessToast";

import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/pubsub";
import fetchMessageCenterData from "@salesforce/apex/SSP_DashboardController.fetchMessageCenterData";
import sspMessageCenterCurrentlyNoData from "@salesforce/label/c.SSP_MessageCenterCurrentlyNoData";
import sspMessageCenterNoToDo from "@salesforce/label/c.SSP_MessageCenterNoToDo";
import sspMessageCenterNoMessage from "@salesforce/label/c.SSP_MessageCenterNoMessage";
import sspNavigateToBackyard from "@salesforce/label/c.sspNavigateToBackyard";
import sspGoToKynectResources from "@salesforce/label/c.sspGoToKynectResources";
// SSO redirect
import validateSSORedirect from "@salesforce/apex/SSP_Utility.validateSSORedirect";
export default class SspDashboardExistingUser extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference) pageRef;
  @track isScreenAccessible = false; //#392529
  @track showAccessDeniedComponent = false; //#392529
  @track nextArrow = sspOverviewIcons + sspConstants.url.nextWhiteArrow;
  @track nextArrowPrimary =
    sspOverviewIcons + sspConstants.url.nextPrimaryArrow;
  @track citizenConnect = sspOverviewIcons + sspConstants.url.citizenConnect;
    @track kynectImage = sspKynectImage + "/kynect-resources-logo-RGB.jpg";
  @track options = [];
  @track selectedCase;
  @track isHeadOfHouseHold = false;
    @track bIsShoppingDataUpdated = false
  @track enableRac = false;
  @track enableRenewal = false;
  @track isUnderReview = false;
  @track lstExpiringApplications = [];
  @track lstActiveBenefits = [];
  @track mapActiveBenefits = [{}];
  @track mapCaseStatus = [{}];
  @track caseStatus = "";
  @track showApplyOtherBenefits = false;
    @track notDependent = true;
  @track applicationId = "";
  @track mapPendingVerificationBenefits = [{}];
  @track mapUnderReviewBenefits = [{}];
  @track mapPendingPendingInterviewBenefits = [{}];
  @track lstPendingVerificationBenefits = [];
  @track lstPendingInterviewBenefits = [];
    @track hasMedicaidFlag = false;
  @track lstEnrolledMedicaidPrograms = [];
  @track lstNonEnrolledMedicaidPrograms = [];
  @track pendingInterviewApplications = [];
  @track showDeletePopUp = false;
  @track dashboardDataToRefresh = false;
  @track lstNotifications = [];
  @track medicaidRenewalList = [];
  @track otherRenewalList = [];
  @track isExistingUser = false;
  @track isFirstTimeUser = false;
  @track showSpinner = true;
  @track benefitButtonLabel = sspAddOtherBenefits;
  @track racButtonLabel = sspReportAChange;
  @track showApplyForBenefits = false;
  @track hasActiveCase = false;
  @track showBenefitsWidget = false;
  @track showMedicaidWidget = false;
  @track benefitActionType = "Benefit";
  @track racActionType = "Report";
  @track showRACPopUp = false;
  @track dashboardLoaded = false;
  @track benefitLoaded = false;
  @track medicaidLoaded = false;
  @track strActiveCases = "";
  @track strAuthRep = sspRepresentativeDescription;
  @track strAssister = sspAssisterDescription;
  @track strAgent = sspAgentDescription;
  @track mapRoleVsList;
  @track contactName = "";
  //driver navigation
  @track showMadeProgressModal = false;
  @track showAnotherUserInProgress = false;
  @track programAccessCheck = false;
  @track caseOwner;
  @track showWorkerPortalBanner = false;
  @track isNotTeamMember = false;
  @track showMessageCenter = false;
  @track isDAILOrCBW = false;
  @track isTeamMember = false;
  @track renderingMap;
  //Added as part of defect fix
  @track selectedRole = "";
  @track displayAuthConsentModal = false;
  @track displayAssisterConsentModal = false;
  @track isEmptyNotEnrolled = false;
  @track isEmptyEnrolled = false;
  @track showOptionDropDown = false;
  @track messageCenterLoad = false;
  @track criticalMessageNotifications = [];
  @track noMessage = false;
  @track noTodo = false;
  @track noUnread = false;
    @track hideMessageCenter =false;

  @track authAssisterNotificationId;

  @track messages = [];
  @track messageTableData1 = [];
  @track messageTableDataMessages = [];
  @track notificationId = [];
  @track msgCenterSummary = 0;
  @track msgCenterAnnouncements = 0;
  @track msgCenterAnnouncementsCount = 0;
  @track msgCenterNotifications = 0;
  @track msgCenterToDos = 0;
  @track msgCenterNotices = 0;
  @track dueToDos = 0;
  @track totalToDos = 0;
  @track appId;
  @track isPrimaryApplicant; //372375 Fix
  //@track initLoadNotificationStatus =[];
    //requestACard changes
    @track toastMessage = "";
    @track showErrorToast = false;
    @track medicaidEBTData = [];
    @track isMedicaidRequestVisibility = false;
    @track isEBTRequestVisibility = false;
  @track showKIHIPPSummary = false;
  @track showKIHIPPSummaryLink = false;
  @track individualId;
   @track medicaidEBTIndividualName;
   @track medicaidEBTDataFlag = false;

   @track isJORITWIST = false;  //Added for Bug# 385818.
    @track genderCode;
    @track genderCodeFlag = false;
    @track enrolledMember=false;
    @track showBenefitTileSpinner = false; // Added for benefit tile spinner 

    isReadOnlyUser = false; //#379955
    authorizedRepresentativeURL = sspConstants.url.authReps;
    backgroundImg = sspCardImages + sspConstants.url.backgroundImage;
    trashIcon = sspTrashIcon + apConstants.url.removeIcon;
    customLabels = {
        sspGoToKynectResources,
        sspViewApplication, //#379955
        sspMCOHistoryTitle,
        sspViewMCOHistory,
        sspApplication,
        sspUnderReview,
        sspAddOtherBenefits,
        sspReportAChange,
        sspViewDetailsOnYourBenefitsApplicationCasesAndBenefits,
        sspBenefits,
        sspActive,
        sspCase,
        sspApproved,
        sspPendingInterview,
        sspPendingVerification,
        sspViewYourToDoListAndMessages,
        sspMessageCenter,
        sspToDos,
        sspUnread,
        sspDueThisWeek,
        sspNotice,
        sspNew,
        sspAnnouncements,
        sspNotifications,
        sspViewAndShopForYourCurrentMedicaidPlansAndMCOs,
        sspMedicaidPlansMCO,
        sspNotEnrolled,
        sspEnrolled,
        sspManageAndViewDetailsAboutYourSupportTeam,
        sspRepsAssistersAgents,
        sspAuthorizedRepresentative,
        sspIWantTo,
        sspNavigateToCitizenConnect,
        sspCompleteSNAPAndMedicaidWorkParticipationRequirementsApplyForWorkforce,
        sspNavigateToLocalResourcePackages,
        sspTheBackYardConnectsKentuckyResidents,
        sspRequestAnEBTCard,
        sspSubmitRequestForNewEBTCard,
        sspHomePageCheckEligibility,
        sspUseTheScreeningTool,
        sspRequestMedicaidCard,
        sspSubmitRequestForReplacementMedicaidCard,
        sspSearchChildCareProviders,
        sspSearchForStateApprovedChildCareProvidersWithinTheCCAPNetwork,
        sspRequestTaxForms,
        sspCreateRequestForUsToSendYourDetailsForYourTaxReturnFiling,
        sspKIHIPPPaymentSummary,
        sspViewHistoryOfKIHIPPPaymentsForThisHousehold,
        sspYouHaveRequestsForInformationRelatedToYourBenefitsApplication,
        sspYouOweAmountOwedForProgramBenefits,
        sspYouHaveAnNotSubmittedApplication,
        sspExpiresToday,
        sspExpiresInDays,
        sspYouHaveAnNotSubmittedApplicationPastDue,
        sspRecommendedOrderHasBeenGeneratedForYourHearing,
        sspYouHaveDaysToRenewYourMedicaidBenefits,
        sspYourEligibilityResultsForBenefitsAreReadyForYourReview,
        sspYouMustCompleteAnInterviewToRenewYourSNAPBenefits,
        sspYouMustCompleteAnInterviewToReceiveChildCareSnapBenefits,
        sspYouMustScheduleAnInterviewToReceiveSnapBenefits,
        sspWelcome,
        sspMyInformation,
        sspApplyForBenefitsDashboard,
        sspAssister,
        sspInsuranceAgent,
        sspRenewBenefits,
        sspCallDCBS,
        sspContinue,
        sspPayBalance,
        sspUploadDocuments,
        sspCompleteYourBenefitsApplicationBy,
        sspReportFraud,
        sspHelpTheCommonwealthOfKentuckyStopScammers,
        sspAuthRepAccessModalContentOne,
        sspReviewAndConsent,
        sspReviewAndConsentTitle,
        sspEnrollmentManager,
        sspEnrollmentManagerNonPrimary,
        sspHealthPlans,
        sspNoEligibleIndividuals,
        sspAllEligibleIndividuals,
        sspEnrollmentManagerTitle,
        sspEnrollmentManagerNonPrimaryTitle,
        sspWantsToBeAssister,
        sspNoticeCardPhoneNumberLink,
        sspMessageCenterCurrentlyNoData,
        sspMessageCenterNoToDo,
        sspMessageCenterNoMessage,
        sspMedicaidCardSuccessToast,
        sspEBTCardSuccessToast,
        sspNavigateToBackyard
  };

  /**
   * @function 		: toggleDropdown.
   * @description 	: method to handle dropdown change.
   **/
  toggleDropdown () {
    try {
      const dropdownIcon = this.template.querySelector(
        sspConstants.dashboardConstants.sspDashboardDropdownIcon
      );
      this.template
        .querySelector(
          sspConstants.dashboardConstants.sspDashboardDropdownContent
        )
        .classList.toggle(sspConstants.dashboardConstants.sspExpandDropdown);
      dropdownIcon.classList.toggle(
        sspConstants.dashboardConstants.sspCollapseDropdown
      );
    } catch (error) {
      console.error(
        "failed in toggleDropdown in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  }
    //#382962 fix
    get isHohEnrolled () {
        if(this.isEmptyEnrolled == true && this.isHeadOfHouseHold == true){
            return true;
        }else{
            return false;
        }
        
    }
    get isHohNotEnrolled () {
        if(this.isEmptyNotEnrolled == true && this.isHeadOfHouseHold == true){
            return true;
        }else{
            return false;
        }
        
    }
  get showMessageCenterColumnOnePrimary () {
    return this.isPrimaryApplicant && !this.noTodo;
  }

  //Added by Shivam - to fix issue - 2nd column not displaying correctly.
  get showMessageCenterColumnTwoPrimary () {
    return this.isPrimaryApplicant && !this.noUnread;
}

  //#372375 fix
  get showMessageCenterColumnOneNonPrimary () {
    return !this.isPrimaryApplicant && !this.noTodo;
  }
  /**
   * @function 		: selectCase.
   * @description 	: method to assign case value.
   * @param {event} event - Gets current value.
   **/
  selectCase (event) {
    try {
      this.toggleDropdown();
      this.selectedCase = event.target.id.split("-")[0];

      if (this.mapCaseStatus.hasOwnProperty(this.selectedCase)) {
        const status = this.mapCaseStatus[this.selectedCase];
        if (status === "AP") {
          this.caseStatus = sspActive;
        } else if (status === "PE" || status === "PI") {
          this.caseStatus = sspPending;
        } else if (status === "DN" || status === "DC") {
          this.caseStatus = sspInActive;
        }
      }
      if (this.mapActiveBenefits.hasOwnProperty(this.selectedCase)) {
        this.lstActiveBenefits = this.mapActiveBenefits[this.selectedCase];
        const setActiveBenefit = [];
        if (this.lstActiveBenefits.length > 0) {
          this.lstActiveBenefits.forEach((expiringObject) => {
            setActiveBenefit.push(expiringObject.ProgramCode);
          });
        }
        if (setActiveBenefit.length > 0) {
          this.lstActiveBenefits = [...new Set(setActiveBenefit)];
        }
      } else if (!this.isUnderReview) {
        this.lstActiveBenefits = [];
      }
      if (
        this.mapUnderReviewBenefits.hasOwnProperty(this.selectedCase) &&
        this.isUnderReview
      ) {
        this.lstActiveBenefits = this.mapUnderReviewBenefits[this.selectedCase];
      } else if (this.isUnderReview) {
        this.lstActiveBenefits = [];
      }
      if (
        this.mapPendingPendingInterviewBenefits.hasOwnProperty(
          this.selectedCase
        )
      ) {
        this.lstPendingInterviewBenefits = this.mapPendingPendingInterviewBenefits[
          this.selectedCase
        ];
        const setPendingInterviewBenefits = [];
        if (this.lstPendingInterviewBenefits.length > 0) {
          this.lstPendingInterviewBenefits.forEach((expiringObject) => {
            setPendingInterviewBenefits.push(expiringObject.ProgramCode);
          });
        }
        if (setPendingInterviewBenefits.length > 0) {
          this.lstPendingInterviewBenefits = [
            ...new Set(setPendingInterviewBenefits),
          ];
        }
      } else {
        this.lstPendingInterviewBenefits = [];
      }
      if (
        this.mapPendingVerificationBenefits.hasOwnProperty(this.selectedCase)
      ) {
        this.lstPendingVerificationBenefits = this.mapPendingVerificationBenefits[
          this.selectedCase
        ];
        const setPendingVerificationBenefits = [];
        if (this.lstPendingVerificationBenefits.length > 0) {
          this.lstPendingVerificationBenefits.forEach((expiringObject) => {
            setPendingVerificationBenefits.push(expiringObject.ProgramCode);
          });
        }
        if (setPendingVerificationBenefits.length > 0) {
          this.lstPendingVerificationBenefits = [
            ...new Set(setPendingVerificationBenefits),
          ];
        }
      } else {
        this.lstPendingVerificationBenefits = [];
      }
    } catch (error) {
      console.error(
        "failed in selectCase in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function 		: openSelected.
   * @description 	: method to open selected tab.
   * @param {event} e - Gets current value.
   **/
  openSelected (e) {
    try {
      const tabs = this.template.querySelectorAll(
        sspConstants.dashboardConstants.sspBenefitsTab
      );
      const tabsContent = this.template.querySelectorAll(
        sspConstants.dashboardConstants.sspBenefitsContent
      );
      for (let i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove(sspConstants.dashboardConstants.active);
      }
      e.target.classList.add(sspConstants.dashboardConstants.active);
      for (let i = 0; i < tabs.length; i++) {
        if (
          tabs[i].classList.contains(sspConstants.dashboardConstants.active)
        ) {
          tabsContent[i].classList.add(sspConstants.dashboardConstants.show);
        } else {
          tabsContent[i].classList.remove(sspConstants.dashboardConstants.show);
        }
      }
    } catch (error) {
      console.error(
        "failed in openSelected in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function 		: openSelectedTab.
   * @description 	: method to open selected tab.
   * @param {event} e - Gets current value.
   **/
  openSelectedTab (e) {
    try {
      const tabs = this.template.querySelectorAll(
        sspConstants.dashboardConstants.sspMedicaidTab
      );
      const tabsContent = this.template.querySelectorAll(
        sspConstants.dashboardConstants.sspMedicaidContent
      );
      for (let i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove(sspConstants.dashboardConstants.active);
      }
      e.target.classList.add(sspConstants.dashboardConstants.active);
      for (let i = 0; i < tabs.length; i++) {
        if (
          tabs[i].classList.contains(sspConstants.dashboardConstants.active)
        ) {
          tabsContent[i].classList.add(sspConstants.dashboardConstants.show);
        } else {
          tabsContent[i].classList.remove(sspConstants.dashboardConstants.show);
        }
      }
    } catch (error) {
      console.error(
        "failed in openSelectedTab in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function 		: loadBenefitsForDashboard.
   * @description 	: method to fetch  Dashboard details .
   * @returns {string}  : JSON of Object Record.
   * */
  loadBenefitsForDashboard = () => {
    try {
this.showBenefitTileSpinner =true;
      invokeDashboardBenefitsCallOut().then((result) => {
        const parsedData = result.mapResponse;
        if (
          !sspUtility.isUndefinedOrNull(parsedData) &&
          parsedData.hasOwnProperty("ERROR")
        ) {
          console.error(
            "failed in loading dashboard" + JSON.stringify(parsedData.ERROR)
          );
        } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    this.getMemberGenderCodeHandler();
                    this.medicaidEBTDataHandler(); // for visibility of request medicaid/ EBT card.
          if (parsedData.hasOwnProperty("showKIHIPPSummary")) {
            this.showKIHIPPSummary = parsedData.showKIHIPPSummary;
          }
          if (parsedData.hasOwnProperty("individualId")) {
            this.individualId = parsedData.individualId;
          }
          this.handleKIHIPPPaymentSummaryAccess();
          if (
            parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.ActiveBenefits
            )
          ) {
            this.mapActiveBenefits = JSON.parse(parsedData.ActiveBenefits);
            if (this.mapActiveBenefits.hasOwnProperty(this.selectedCase)) {
              this.lstActiveBenefits = this.mapActiveBenefits[
                this.selectedCase
              ];
              const setActiveBenefit = [];
              if (this.lstActiveBenefits.length > 0) {
                this.lstActiveBenefits.forEach((expiringObject) => {
                  setActiveBenefit.push(expiringObject.ProgramCode);
                });
                if (setActiveBenefit.length > 0) {
                  this.lstActiveBenefits = [...new Set(setActiveBenefit)];
                }
              }
            }
          }
          if (
            parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.PendingInterviewBenefits
            )
          ) {
            this.mapPendingPendingInterviewBenefits = JSON.parse(
              parsedData.PendingInterviewBenefits
            );
            if (
              this.mapPendingPendingInterviewBenefits.hasOwnProperty(
                this.selectedCase
              )
            ) {
              this.lstPendingInterviewBenefits = this.mapPendingPendingInterviewBenefits[
                this.selectedCase
              ];
              const setPendingInterviewBenefits = [];
              if (this.lstPendingInterviewBenefits.length > 0) {
                this.lstPendingInterviewBenefits.forEach((expiringObject) => {
                  setPendingInterviewBenefits.push(expiringObject.ProgramCode);
                });
                if (setPendingInterviewBenefits.length > 0) {
                  this.lstPendingInterviewBenefits = [
                    ...new Set(setPendingInterviewBenefits),
                  ];
                }
              }
            }
          }
          if (
            parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.PendingVerificationBenefits
            )
          ) {
            this.mapPendingVerificationBenefits = JSON.parse(
              parsedData.PendingVerificationBenefits
            );
            if (
              this.mapPendingVerificationBenefits.hasOwnProperty(
                this.selectedCase
              )
            ) {
              this.lstPendingVerificationBenefits = this.mapPendingVerificationBenefits[
                this.selectedCase
              ];
              const setPendingVerificationBenefits = [];
              if (this.lstPendingVerificationBenefits.length > 0) {
                this.lstPendingVerificationBenefits.forEach(
                  (expiringObject) => {
                    setPendingVerificationBenefits.push(
                      expiringObject.ProgramCode
                    );
                  }
                );
              }
              if (setPendingVerificationBenefits.length > 0) {
                this.lstPendingVerificationBenefits = [
                  ...new Set(setPendingVerificationBenefits),
                ];
              }
            }
          }
                    //Defect 383001
                    if (parsedData.hasOwnProperty("hasMedicaidProgram")) {
                        this.hasMedicaidFlag = true;
                    }
                    
                    if (
                        (this.lstNonEnrolledMedicaidPrograms.length !== 0 ||
                        this.lstEnrolledMedicaidPrograms.length !== 0) &&
                        this.template.querySelector(".ssp-medicaidWidget") != null && 
                        this.hasMedicaidFlag === true
                    ) {
                        this.template
                            .querySelector(".ssp-medicaidWidget")
                            .classList.remove("slds-hide");
                    }

                    else if(
                        this.template.querySelector(".ssp-medicaidWidget") !=
                        null 
                    ){
                        this.template
                        .querySelector(".ssp-medicaidWidget")
                        .classList.add("slds-hide"); 
                    }
                    //Defect 383001
          if (
            !parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.hasKHIPPProgram
            )
          ) {
            if (!this.isHeadOfHouseHold) {
              this.showApplyForBenefits = true;
            }
          }
                    if (parsedData.hasOwnProperty("onlyKihippHoh") && parsedData.hasOwnProperty(
                        sspConstants.dashboardConstants.hasKHIPPProgram
                    )) {
                        this.notDependent = false; 
                    }
                    this.benefitLoaded = true;
                    this.showBenefitTileSpinner = false;
                    this.showDashboard();
                }
            });
        } catch (error) {
            console.error(
                "failed in loadBenefitsForDashboard in sspDashboardExistingUser" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function 		: loadMedicaidForDashboard.
     * @description 	: method to fetch  Dashboard Medicaid details .
     * @returns {string}  : JSON of Object Record.
     * */
    loadMedicaidForDashboard = () => {
        try {
            const sPageURL = decodeURIComponent(
                window.location.search.substring(1)
            );
            const sURLVariables = sPageURL.split("&");
            if (sURLVariables != null) {
                for (let i = 0; i < sURLVariables.length; i++) {
                    const sParam = sURLVariables[i].split("=");
                    if (
                        sParam[0] === "isShoppingReturn" &&
                        sParam[1] !== undefined &&
                        sParam[1] === "Y"
                    ) {
                        this.bIsShoppingDataUpdated = true;
                    }
                }
            }
            invokeDashboardMedicaidCallOut({
                bIsShoppingDataUpdated : this.bIsShoppingDataUpdated
            }).then(result => {
        const parsedData = result.mapResponse;
        if (
          !sspUtility.isUndefinedOrNull(parsedData) &&
          parsedData.hasOwnProperty("ERROR")
        ) {
          console.error(
            "failed in loading dashboard" + JSON.stringify(parsedData.ERROR)
          );
        } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
          if (
            parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.NonEnrolledMedicaidPrograms
            )
          ) {
            this.lstNonEnrolledMedicaidPrograms = JSON.parse(
              parsedData.NonEnrolledMedicaidPrograms
            );
          }
          if (
            parsedData.hasOwnProperty(
              sspConstants.dashboardConstants.EnrolledMedicaidPrograms
            )
          ) {
            this.lstEnrolledMedicaidPrograms = JSON.parse(
              parsedData.EnrolledMedicaidPrograms
            );
          }
           //391302
          if (this.isHeadOfHouseHold || this.lstEnrolledMedicaidPrograms.length !== 0) {
            this.enrolledMember = true;
          }
        //Defect 383001
                    //Defect 383001
                    if (
                        (this.lstNonEnrolledMedicaidPrograms.length !== 0 ||
                        this.lstEnrolledMedicaidPrograms.length !== 0) &&
                        this.template.querySelector(".ssp-medicaidWidget") != null && //#376088
                        this.hasMedicaidFlag === true
                    ) {
                        this.template
                            .querySelector(".ssp-medicaidWidget")
                            .classList.remove("slds-hide");
                    }

                    else if(
                        this.template.querySelector(".ssp-medicaidWidget") !=
                        null //#376088
                    ){
                        this.template
                        .querySelector(".ssp-medicaidWidget")
                        .classList.add("slds-hide"); 
                    }
                    //Defect 383001

          if (this.lstNonEnrolledMedicaidPrograms.length === 0) {
            this.isEmptyNotEnrolled = true;
            if (this.template.querySelector(".ssp-allEnrolledTab") != null) {
              //#376088
              this.template
                .querySelector(".ssp-allEnrolledTab")
                .classList.add("active");
            }
            if (
              this.template.querySelector(".ssp-allEligibleContent") != null
            ) {
              //#376088
              this.template
                .querySelector(".ssp-allEligibleContent")
                .classList.add("show");
            }
          }
          if (this.lstEnrolledMedicaidPrograms.length === 0) {
            this.isEmptyEnrolled = true;
            if (this.template.querySelector(".ssp-noEnrolledTab") != null) {
              //#376088
              this.template
                .querySelector(".ssp-noEnrolledTab")
                .classList.add("active");
            }
            if (this.template.querySelector(".ssp-noEligibleContent") != null) {
              //#376088
              this.template
                .querySelector(".ssp-noEligibleContent")
                .classList.add("show");
            }
          }
          if (
            this.lstEnrolledMedicaidPrograms.length !== 0 &&
            this.lstNonEnrolledMedicaidPrograms.length !== 0
          ) {
            if (this.template.querySelector(".ssp-allEnrolledTab") != null) {
              //#376088
              this.template
                .querySelector(".ssp-allEnrolledTab")
                .classList.add("active");
            }
            if (
              this.template.querySelector(".ssp-allEligibleContent") != null
            ) {
              //#376088
              this.template
                .querySelector(".ssp-allEligibleContent")
                .classList.add("show");
            }
          }
          this.medicaidLoaded = true;
          this.showDashboard();
        }
      });
    } catch (error) {
      console.error(
        "failed in loadMedicaidForDashboard in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: loadMessageCenterData.
   * @description 	: method to fetch  Message Center details .
   * @returns {string}  : JSON of Object Record.
   * */
  loadMessageCenterData = () => {
    try {
            fetchMessageCenterData().then(result => {
                try {
        if (
          result.bIsSuccess &&
          !sspUtility.isUndefinedOrNull(result.mapResponse)
        ) {
          //const parsedData = result.mapResponse;
                    this.hideMessageCenter = (!sspUtility.isUndefinedOrNull(result.mapResponse.hideMessageCenter) && result.mapResponse.hideMessageCenter === true) ? true : false;
                    if (this.renderingMap.messageCenterWidget.isAccessible && !this.hideMessageCenter) {
                        this.hideMessageCenter = true;
                    }
                    else {
                        this.hideMessageCenter = false;
                    }
          this.messageCenterLoad = true;
          if (
            !sspUtility.isUndefinedOrNull(result.mapResponse.messageWrapper) &&
            !sspUtility.isUndefinedOrNull(
              result.mapResponse.messageWrapper.messages
            )
          ) {
            this.messages = JSON.stringify(
              result.mapResponse.messageWrapper.messages
                            );
                        
          const criticalNotifications = JSON.parse(this.messages);
          criticalNotifications.forEach((element) => {
            // // CD2 2.5 Security Role Matrix.
            if (
              element.buttonName === "Review & Consent" &&
              this.renderingMap.reviewConsentLink.isAccessible === false
            ) {
              element.isVisible = false;
            } else {
              element.isVisible = true;
            }
                        if (
                            element.buttonName === "Renew Benefits" &&
                            this.renderingMap.reportAChangeLink.isAccessible ===
                                false
                        ) {
                            element.isToDo = false;
                        } else {
                            element.isToDo = true;
                        }
          });
          this.criticalMessageNotifications = criticalNotifications;
                        
                        }

          //for message center widget on dashboard
          if (
            !sspUtility.isUndefinedOrNull(result.mapResponse.msgCenterSummary)
          ) {
            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.unreadMessagesNotices
              )
            ) {
              //modified by Shivam added since unread Notices were not coming on benefits widget
              this.msgCenterSummary = JSON.stringify(
                result.mapResponse.msgCenterSummary.unreadMessagesNotices
              );
            }
            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.messages
              )
            ) {
              this.msgCenterAnnouncements = JSON.parse(
                JSON.stringify(result.mapResponse.msgCenterSummary.messages)
              );
            }
            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.countOfUnreadNotifications
              )
            ) {
              this.msgCenterNotifications = JSON.stringify(
                result.mapResponse.msgCenterSummary.countOfUnreadNotifications
              );
            }
            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.countOfUnreadToDos
              )
            ) {
              this.msgCenterToDos = JSON.stringify(
                result.mapResponse.msgCenterSummary.countOfUnreadToDos
              );
            }

            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.todosDue
              )
            ) {
              this.dueToDos = JSON.stringify(
                result.mapResponse.msgCenterSummary.todosDue
              );
            }
            if (
              !sspUtility.isUndefinedOrNull(
                result.mapResponse.msgCenterSummary.totaltodos
              )
            ) {
              this.totalToDos = JSON.stringify(
                result.mapResponse.msgCenterSummary.totaltodos
              );
            }
          }

          if (this.msgCenterSummary == 0 && this.totalToDos == 0) {
            this.noMessage = true;
          }
          if (this.totalToDos == 0) {
            this.noTodo = true;
          }
          if (this.msgCenterSummary == 0) {
            this.noUnread = true;
          }
          if (
            !sspUtility.isUndefinedOrNull(
              result.mapResponse.msgCenterSummary
            ) &&
            !sspUtility.isUndefinedOrNull(
              result.mapResponse.msgCenterSummary.totalNotices
            )
          ) {
            this.msgCenterNotices = JSON.stringify(
              result.mapResponse.msgCenterSummary.totalNotices
            );
          }
          for (
            this.i = 0;
            this.i < this.msgCenterAnnouncements.length;
            this.i++
          ) {
            if (this.msgCenterAnnouncements[this.i].isAnnouncement === true) {
              this.msgCenterAnnouncementsCount =
                this.msgCenterAnnouncementsCount + 1;
              // this.updateReadStatuses();
            }
          }
          this.showDashboard();

          //for making notifications read on display of dashboard
          for (
            this.i = 0;
            this.i < this.criticalMessageNotifications.length;
            this.i++
          ) {
            this.notificationId = [];
            if (
              this.criticalMessageNotifications[this.i].isNotification ===
                true &&
              this.criticalMessageNotifications[this.i].readStatus === false
            ) {
              this.notificationId.push(
                this.criticalMessageNotifications[this.i].sfdcId
              );
              this.updateReadStatuses();
            }
          }
        } else {
          this.messageCenterLoad = true;
          this.showDashboard();
          console.error(
            "failed in loadMessageCenterData in sspDashboardExistingUser" +
              JSON.stringify(result)
          );
          this.showDashboard();
                    }
                } catch (error) {
                        console.error(
                            "failed in loadMessageCenterData in sspDashboardExistingUser" +
                                JSON.stringify(error)
                        );
                        this.showSpinner = false;
                        this.messageCenterLoad = true;
                        this.showDashboard();
                }
      });
    } catch (error) {
      console.error(
        "failed in loadMessageCenterData in sspDashboardExistingUser" +
          JSON.stringify(error)
            );
            this.showSpinner = false;
            this.messageCenterLoad = true;
      this.showDashboard();
    }
  };
  /**
   * @function 		: handleDeleteApplication.
   * @description 	: method to handle Delete Application.
   * @param {event} event - Gets current value.
   **/
    handleDeleteApplication = event => {
        try {
            this.appId = event.currentTarget.dataset.application;
            this.applicationId = this.appId;
            this.showDeletePopUp = true;
    } catch (error) {
      console.error(
        "failed in handleDeleteApplication in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: handleDeleteApplication.
   * @description 	: method to handle show/hide Delete Pop Up.
   **/
  handleDeleteCancel = () => {
    try {
      this.showDeletePopUp = false;
      this.messageCenterLoad();
    } catch (error) {
      console.error(
        "failed in handleDeleteCancel in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: handleDeleteSuccess.
   * @description 	: method to handle show/hide Delete Pop Up.
   **/
  handleDeleteSuccess = () => {
    try {
      this.showDeletePopUp = false;
      this.showSpinner = true;
      this.lstExpiringApplications = [];
      this.benefitButtonLabel = sspAddOtherBenefits;
      this.benefitActionType = "Benefit";
      this.applicationId = "";
      this.isFirstTimeUser = false;
      this.isExistingUser = false;
      this.connectedCallback();
    } catch (error) {
      console.error(
        "failed in handleDeleteSuccess in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: connectedCallback.
   * @description 	: method to get Dashboard Details.
   **/
  connectedCallback () {
    try {
            const url = new URL(window.location.href);
            const language = url.searchParams.get("language");
            if ((!sspUtility.isUndefinedOrNull(language) &&
            (language === "en_US" || language === "es_US" ))
            ){                
                updateUserLanguage({
                    language: language
                }) 
            }    
      // CD2 2.5 Security Role Matrix.
      this.renderingMap = {
        myInformation: {
          id: "INDV_DB_15",
          isAccessible: false,
        },
        addBenefitsButton: {
          id: "INDV_DB_1",
          isAccessible: false,
        },
        reportAChangeLink: {
          id: "INDV_DB_2",
          isAccessible: false,
        },
        reviewConsentLink: {
          id: "INDV_DB_3",
          isAccessible: false,
        },
        benefitsWidget: {
          id: "INDV_DB_4",
          isAccessible: false,
        },
        messageCenterWidget: {
          id: "INDV_DB_5",
          isAccessible: false,
        },
        medicaidPlansWidget: {
          id: "INDV_DB_6",
          isAccessible: false,
        },
        repsWidget: {
          id: "INDV_DB_7",
          isAccessible: false,
        },
        navigateToCitizenConnect: {
          id: "INDV_DB_8",
          isAccessible: false,
        },
        navigateToBackyard: {
          id: "INDV_DB_9",
          isAccessible: false,
        },
        requestEBTCard: {
          id: "INDV_DB_10",
          isAccessible: false,
        },
        requestMedicaidCard: {
          id: "INDV_DB_11",
          isAccessible: false,
        },
        requestTaxForms: {
          id: "INDV_DB_12",
          isAccessible: false,
        },
        searchChildCareProviders: {
          id: "INDV_DB_13",
          isAccessible: false,
        },
        kHIPPPaymentSummary: {
          id: "INDV_DB_14",
          isAccessible: false,
        },
      };
      triggerDashboardServiceCallOut()
        .then((result) => {
          this.dashboardDataToRefresh = result;
          if (result) {
            const parsedData = result.mapResponse;
            if (
              !sspUtility.isUndefinedOrNull(parsedData) &&
              parsedData.hasOwnProperty("ERROR")
            ) {
              console.error(
                "failed in loading dashboard" + JSON.stringify(parsedData.ERROR)
              );
            } else if (!sspUtility.isUndefinedOrNull(parsedData)) {

              /** #379955 fix. */
              if (parsedData.hasOwnProperty("isReadOnlyUser")) {
                this.isReadOnlyUser = parsedData.isReadOnlyUser;
              }
              /** */

              /* CD2 2.5 Security Role Matrix. */
              const { screenPermission: securityMatrix } = parsedData;
              this.isScreenAccessible =
                !sspUtility.isUndefinedOrNull(securityMatrix) &&
                securityMatrix.screenPermission ==
                  sspConstants.permission.notAccessible
                  ? false
                  : true; //#392529
              this.showAccessDeniedComponent = !this.isScreenAccessible; //#392529
              const ids =
                !sspUtility.isUndefinedOrNull(securityMatrix) &&
                !sspUtility.isUndefinedOrNull(securityMatrix.fieldPermissions)
                  ? Object.keys(securityMatrix.fieldPermissions)
                  : null;
              for (const elementName of Object.keys(this.renderingMap)) {
                if (
                  !sspUtility.isUndefinedOrNull(ids) &&
                  ids.indexOf(this.renderingMap[elementName].id) > -1 &&
                  securityMatrix.fieldPermissions[
                    this.renderingMap[elementName].id
                  ] === "NotAccessible"
                ) {
                  this.renderingMap[elementName].isAccessible = false;
                } else {
                  this.renderingMap[elementName].isAccessible = true;
                }
              }
              /* CD2 2.5 Security Role Matrix. */

              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.contactName
                )
              ) {
                this.contactName = parsedData.contactName;
                fireEvent(this.pageRef, "contactNameEvent", this.contactName);
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.isExistingUser
                )
              ) {
                this.isExistingUser = parsedData.isExistingUser;
                this.isFirstTimeUser = false;
              } else {
                this.isFirstTimeUser = true;
                this.isExistingUser = false;
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.isHeadOfHouseHold
                )
              ) {
                this.isHeadOfHouseHold = parsedData.isHeadOfHouseHold;
              }
              if (parsedData.hasOwnProperty("caseVsStatus")) {
                this.mapCaseStatus = JSON.parse(parsedData.caseVsStatus);
                if (parsedData.hasOwnProperty("caseOptions")) {
                  this.options = JSON.parse(parsedData.caseOptions);
                }
                this.showOptionDropDown = this.options.length > 1;
                this.selectedCase = this.options[0];
                if (this.mapCaseStatus.hasOwnProperty(this.selectedCase)) {
                  const status = this.mapCaseStatus[this.selectedCase];
                  if (status === "AP") {
                    this.caseStatus = sspActive;
                  } else if (status === "PE" || status === "PI") {
                    this.caseStatus = sspPending;
                  } else if (status === "DN" || status === "DC") {
                    this.caseStatus = sspInActive;
                  }
                }
                this.showBenefitsWidget = true;
                const cases = this.options;
                const mapCaseStatus = this.mapCaseStatus;
                const self = this;
                cases.forEach(function (eachCase) {
                  if (
                    mapCaseStatus.hasOwnProperty(eachCase) &&
                    (mapCaseStatus[eachCase] === "AP" ||
                      mapCaseStatus[eachCase] === "PE" ||
                      mapCaseStatus[eachCase] === "PI")
                  ) {
                    self.showApplyOtherBenefits = true;
                  } else if (
                    mapCaseStatus.hasOwnProperty(eachCase) &&
                    !self.isHeadOfHouseHold &&
                    mapCaseStatus[eachCase] === "AP"
                  ) {
                    self.showApplyOtherBenefits = false;
                  }
                });
                //commented as Part of defect 379639
                /*if (this.showApplyOtherBenefits === false) {
                                    this.showApplyForBenefits = true;
                                }*/
              } else {
                this.showBenefitsWidget = false;
              }
              if (parsedData.hasOwnProperty("hasActiveCase")) {
                this.strActiveCases = parsedData.hasActiveCase;
                this.hasActiveCase = true;
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.hasExpiringApplications
                )
              ) {
                this.lstExpiringApplications = JSON.parse(
                  parsedData.hasExpiringApplications
                );
                this.showApplyOtherBenefits = true;
                this.benefitButtonLabel = this.isReadOnlyUser
                  ? sspViewApplication
                  : sspContinueApplication; //#379955
                this.benefitActionType =
                  sspConstants.dashboardConstants.continue;
                this.applicationId = this.lstExpiringApplications[0].applicationId;
                this.isFirstTimeUser = false;
                this.isExistingUser = true;
                this.lstExpiringApplications.forEach((expiringObject) => {
                  expiringObject[
                    sspConstants.dashboardConstants.primaryInfoLabel
                  ] = formatLabels(
                    this.customLabels.sspYouHaveAnNotSubmittedApplication,
                    [expiringObject.programsApplied]
                  );
                  expiringObject[
                    sspConstants.dashboardConstants.infoLabel
                  ] = formatLabels(
                    this.customLabels.sspCompleteYourBenefitsApplicationBy,
                    [expiringObject.expiryDate]
                  );
                });
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.notificationsList
                )
              ) {
                this.lstNotifications = JSON.parse(
                  parsedData.notificationsList
                );
                this.lstNotifications.forEach((notificationObject) => {
                  notificationObject[
                    sspConstants.dashboardConstants.primaryInfoLabel
                  ] = formatLabels(
                    this.customLabels.sspYouOweAmountOwedForProgramBenefits,
                    [notificationObject.SnapAmount]
                  );
                  notificationObject[
                    sspConstants.dashboardConstants.infoLabel
                  ] = formatLabels(
                    this.customLabels
                      .sspYouHaveRequestsForInformationRelatedToYourBenefitsApplication,
                    [notificationObject.RFICount]
                  );
                });
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.hasMedicaidRenewals
                )
              ) {
                this.medicaidRenewalList = JSON.parse(
                  parsedData.hasMedicaidRenewals
                );
                this.medicaidRenewalList.forEach((renewalObject) => {
                  renewalObject[
                    sspConstants.dashboardConstants.infoLabel
                  ] = formatLabels(
                    this.customLabels.sspYouHaveDaysToRenewYourMedicaidBenefits,
                    [renewalObject.RenewalDueDate]
                  );
                });
                this.racButtonLabel = sspRenewBenefit;
                this.racActionType = sspConstants.dashboardConstants.Renewal;
                this.hasActiveCase = true;
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.hasOtherRenewals
                )
              ) {
                this.otherRenewalList = JSON.parse(parsedData.hasOtherRenewals);
                this.otherRenewalList.forEach((renewalObject) => {
                  renewalObject[
                    sspConstants.dashboardConstants.infoLabel
                  ] = formatLabels(this.customLabels.sspExpiresInDays, [
                    renewalObject.RenewalDueDate,
                  ]);
                });
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants
                    .hasPendingInterviewApplications
                )
              ) {
                this.pendingInterviewApplications = JSON.parse(
                  parsedData.hasPendingInterviewApplications
                );
                this.pendingInterviewApplications.forEach((pendingObject) => {
                  pendingObject[
                    sspConstants.dashboardConstants.infoLabel
                  ] = formatLabels(this.customLabels.sspExpiresInDays, [
                    pendingObject.daysRemaining,
                  ]);
                  pendingObject[
                    sspConstants.dashboardConstants.primaryInfoLabel
                  ] = formatLabels(
                    this.customLabels
                      .sspYouMustCompleteAnInterviewToReceiveChildCareSnapBenefits,
                    [pendingObject.programsApplied]
                  );
                });
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.hasAuthRepAgents
                )
              ) {
                this.mapRoleVsList = JSON.parse(parsedData.hasAuthRepAgents);
                if (
                  this.mapRoleVsList[
                    sspConstants.dashboardConstants.AUTHREP
                  ] !== null &&
                  this.mapRoleVsList[
                    sspConstants.dashboardConstants.AUTHREP
                  ] !== undefined
                ) {
                  this.strAuthRep = this.mapRoleVsList[
                    sspConstants.dashboardConstants.AUTHREP
                  ];
                }
                if (
                  this.mapRoleVsList[
                    sspConstants.dashboardConstants.ASSISTER
                  ] !== null &&
                  this.mapRoleVsList[
                    sspConstants.dashboardConstants.ASSISTER
                  ] !== undefined
                ) {
                  this.strAssister = this.mapRoleVsList[
                    sspConstants.dashboardConstants.ASSISTER
                  ];
                }
                if (
                  this.mapRoleVsList[sspConstants.dashboardConstants.AGENT] !==
                    null &&
                  this.mapRoleVsList[sspConstants.dashboardConstants.AGENT] !==
                    undefined
                ) {
                  this.strAgent = this.mapRoleVsList[
                    sspConstants.dashboardConstants.AGENT
                  ];
                }
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.headerConstants.caseOwnership
                )
              ) {
                if (
                  parsedData.caseOwnership ===
                    sspConstants.headerConstants.DAIL ||
                  parsedData.caseOwnership === sspConstants.headerConstants.CBW
                ) {
                  this.isDAILOrCBW = true;
                } else {
                  this.isDAILOrCBW = false;
                }
              }
              if (
                parsedData.hasOwnProperty(
                  sspConstants.headerConstants.isTeamMember
                )
              ) {
                if (parsedData.isTeamMember === true) {
                  this.isTeamMember = true;
                } else {
                  this.isTeamMember = false;
                }
              }
              //Added as part of defect fix
              if (
                parsedData.hasOwnProperty(
                  sspConstants.headerConstants.selectedRole
                )
              ) {
                this.selectedRole = parsedData.selectedRole;
              }
              if (
                parsedData.hasOwnProperty("underReviewPrograms") &&
                parsedData.hasOwnProperty("underReviewApplicationNumber") &&
                !this.isExistingUser &&
                this.options.length === 0
              ) {
                this.lstActiveBenefits = JSON.parse(
                  parsedData.underReviewPrograms
                );
                this.options = parsedData.underReviewApplicationNumber;
                this.selectedCase = this.options[0];
                this.mapUnderReviewBenefits = JSON.parse(
                  parsedData.underReviewPrograms
                );
                this.lstActiveBenefits = this.mapUnderReviewBenefits[
                  this.options[0]
                ];
                this.showBenefitsWidget = true;
                this.isExistingUser = true;
                this.isFirstTimeUser = false;
                this.isUnderReview = true;
                this.caseStatus = sspPending;
                this.showApplyOtherBenefits = true;
              }
                this.dashboardLoaded = true;
                this.showSpinner = false;
              this.showDashboard();
              if (
                parsedData.hasOwnProperty(
                  sspConstants.dashboardConstants.isExistingUser
                ) &&
                this.isScreenAccessible //#392529
              ) {
                this.loadBenefitsForDashboard();
                this.loadMedicaidForDashboard();
              } else {
                this.showSpinner = false;
              }
              //message center changes
              this.loadMessageCenterData();
              //Added as Part of defect 379639
              if (this.showApplyOtherBenefits === false) {
                this.showApplyForBenefits = true;
              } else if (this.showApplyOtherBenefits === true) {
                this.showApplyForBenefits = false;
              }
              //end
            }
          } else if (result.error) {
            console.error(result.error);
          }

          //#379955 
          if (this.isReadOnlyUser && this.benefitButtonLabel === sspAddOtherBenefits) {
            this.renderingMap.addBenefitsButton.isAccessible = false;
          }
        })
        .then(() => {
          //pub-sub event to provide isHeadOfHouseHold flag to sspHeader component
          fireEvent(
            this.pageRef,
            apConstants.headerConstants.HOHFlagEvent,
            this.isHeadOfHouseHold
          );
          fireEvent(
            this.pageRef,
            apConstants.headerConstants.isNewUserDashboard,
            {
              isFirstTimeUser: this.isFirstTimeUser,
              isHeadOfHousehold: this.isHeadOfHouseHold,
            }
          );
          getMemberTypeFlag()
            .then((result) => {
              if (
                !sspUtility.isUndefinedOrNull(result) &&
                !sspUtility.isUndefinedOrNull(result.mapResponse)
              ) {
                const data = result.mapResponse;
                /** #372375 fix. */
                this.isPrimaryApplicant =
                  !sspUtility.isUndefinedOrNull(data) &&
                  !sspUtility.isUndefinedOrNull(data.memberType)
                    ? data.memberType.includes(sspConstants.headerConstants.HOH)
                    : true;
                /** */

                if (!sspUtility.isUndefinedOrNull(data.memberType)) {
                  if (
                    data.memberType.includes(sspConstants.headerConstants.TMEM)
                  ) {
                    this.isNotTeamMember = false;
                    this.showMessageCenter = false;
                  } else {
                    this.isNotTeamMember = true;
                    this.showMessageCenter = true;
                  }
                } else {
                  this.isNotTeamMember = true;
                  this.showMessageCenter = true;
                }
                if (!sspUtility.isUndefinedOrNull(data.ownerType)) {
                  if (
                    (data.ownerType.includes(
                      sspConstants.headerConstants.DAIL
                    ) &&
                      this.selectedRole !==
                        sspConstants.headerConstants.DAIL_Worker) ||
                    data.ownerType.includes(sspConstants.headerConstants.CBW)
                  ) {
                    this.isDAILOrCBW = true;
                  } else {
                    this.isDAILOrCBW = false;
                  }
                  //Added for Bug# 385818.
                  if (data.ownerType.includes("JORI") || data.ownerType.includes("TWIST") || data.ownerType.includes("ICAMA") || data.ownerType.includes("ICPC") || data.ownerType.includes("FCM") || data.ownerType.includes("ASM")) {
                    this.isJORITWIST = true;
                  }
                } else {
                  this.isDAILOrCBW = false;
                }
              }
            })
            .then(() => {
              fireEvent(
                this.pageRef,
                apConstants.headerConstants.TeamMemberFlagEvent,
                this.isNotTeamMember
              );
            })
            .catch((error) => {
              console.error(
                "failed in getMemberTypeFlag in sspDashboardExistingUser" +
                  JSON.stringify(error)
              );
            });
        })
        .then(() => {
          getCaseOwnershipFlag().then((data) => {
            try {
              if (!sspUtility.isUndefinedOrNull(data)) {
                this.caseOwner = data;
                if (
                  this.caseOwner.includes(sspConstants.headerConstants.CHANGE)
                ) {
                  this.showWorkerPortalBanner = true;
                } else {
                  this.showWorkerPortalBanner = false;
                }
              }
            } catch (error) {
              console.error(
                "failed in getCaseOwnershipFlag in dashboard" +
                  JSON.stringify(error)
              );
            }
          });
                    window.document.body.style.overflow = "";
        });
                window.document.body.style.overflow = "";
    } catch (error) {
            window.document.body.style.overflow = "";
      console.error(
        "failed in triggerDashboardServiceCallOut in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function 		: handleBenefitNavigation.
   * @description 	: method to handle navigation on click of benefit/renewal button.
   **/
  handleBenefitNavigation = () => {
    this.showSpinner = true;
    try {
      if (this.benefitActionType === sspConstants.dashboardConstants.continue) {
        resumeApplication({
          sApplicationId: this.applicationId,
        })
          .then((result) => {
            // Modal Driver navigation
            this.showMadeProgressModal = false;
            this.showAnotherUserInProgress = false;
            this.programAccessCheck = false;

            const response = result.mapResponse;
            if (response.bIsSuccess === true) {
              let noModal = true;
              //user in progress - other user is modifying application OR less than 30 minutes since last accessed
              let timeLock = 30;
              if (!sspUtility.isUndefinedOrNull(response.timeLock)) {
                timeLock = parseInt(response.timeLock);
              }
              if (
                response.applicationChangedBy !== undefined &&
                response.loggedInUserName != response.applicationChangedBy &&
                !sspUtility.isUndefinedOrNull(response.minutesGap) &&
                response.minutesGap <= timeLock
              ) {
                this.showAnotherUserInProgress = true;
                noModal = false;
              }
              //program access - other user changed application, lesser access
              let listAppPrograms = [];
              if (!sspUtility.isUndefinedOrNull(response.applicationPrograms)) {
                listAppPrograms = response.applicationPrograms.split(";");
              }
              let availablePrograms = [];
              if (!sspUtility.isUndefinedOrNull(response.applicationPrograms)) {
                availablePrograms = response.availablePrograms;
              }
              const canAccessAppProgramsList = [];
              let hasLesserAccess = false;
              listAppPrograms.forEach((appProgram) => {
                if (availablePrograms.includes(appProgram)) {
                  canAccessAppProgramsList.push(appProgram);
                } else {
                  hasLesserAccess = true;
                }
              });
              if (
                noModal &&
                response.applicationChangedBy !== undefined &&
                response.loggedInUserName != response.applicationChangedBy &&
                hasLesserAccess && 
                !this.isReadOnlyUser && //#379955
                response.userRole !== "Citizen_Individual"
              ) {
                this.programAccessCheck = true;
                noModal = false;
              }
              //progress made - other user changed application, has program access
              if (
                noModal &&
                response.applicationChangedBy !== undefined &&
                response.loggedInUserName != response.applicationChangedBy
              ) {
                this.showMadeProgressModal = true;
                noModal = false;
              }

              //No Modal - redirection
              if (noModal) {
                this.redirectToIntake();
              } else {
                this.showSpinner = false;
              }
            } else {
              this.showSpinner = false;
              this.errorMsg = result.error;
              this.showErrorModal = true;
            }
          })
          .catch((error) => {
            this.showSpinner = false;
            console.error(
              "Error in resumeApplication" + JSON.stringify(error.message)
            );
          });
      } else {
        this.showSpinner = false;
        this[NavigationMixin.Navigate]({
          type: sspConstants.communityPageNames.community,
          attributes: {
            name: sspConstants.communityPageNames.getStartedBenefits,
          },
        });
      }
    } catch (error) {
      this.showSpinner = false;
      console.error(
        "failed in handleBenefitNavigation in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function : progressValueUpdated
   * @description :  Driver navigation - Process progress behavior.
   *  @param {object} event - Js event.
   */
  progressValueUpdated = (event) => {
    try {
      const progress = event.detail;
      if (progress) {
        if (
          // eslint-disable-next-line spellcheck/spell-checker
          !sspUtility.isUndefinedOrNull(this.racActionType) &&
          // eslint-disable-next-line spellcheck/spell-checker
          this.racActionType === sspConstants.dashboardConstants.Renewal
        ) {
          this.redirectToRenewal();
        } else {
          if (this.programAccessCheck) {
            this.redirectToProgramSelect();
          } else {
            this.redirectToIntake();
          }
        }
      }
      this.showMadeProgressModal = false;
      this.showAnotherUserInProgress = false;
      this.programAccessCheck = false;
      this.showSpinner = false;
    } catch (error) {
      console.error(
        "Error in progressValueUpdated" + JSON.stringify(error.message)
      );
    }
  };

  /**
   * @function 		: redirectToIntake.
   * @description 	: intake redirection.
   **/
  redirectToIntake = () => {
    this[NavigationMixin.Navigate]({
      type: sspConstants.communityPageNames.community,
      attributes: {
        name: sspConstants.communityPageNames.applicationSummaryApi,
      },
      state: {
        applicationId: this.applicationId,
        mode: "intake",
      },
    });
    this.showSpinner = false;
  };

  /**
   * @function 		: redirectToProgramSelect.
   * @description 	: intake program selection screen.
   **/
  redirectToProgramSelect = () => {
    this[NavigationMixin.Navigate]({
      type: sspConstants.communityPageNames.community,
      attributes: {
        name: sspConstants.navigationUrl.programSelection,
      },
      state: {
        applicationId: this.applicationId,
        mode: "Intake",
      },
    });
    this.showSpinner = false;
  };

  /**
   * @function 		: redirectToRenewal.
   * @description 	: renewal redirection.
   **/
  redirectToRenewal = () => {
    this[NavigationMixin.Navigate]({
      type: sspConstants.communityPageNames.community,
      attributes: {
        name: sspConstants.communityPageNames.renewals,
      },
      state: {
        mode: "Renewal",
      },
    });
    this.showSpinner = false;
  };

  /**
   * @function 		: redirectToKIHIPPSummary.
   * @description 	: KIHIPPSummary redirection.
   **/
  redirectToKIHIPPSummary = () => {
    this[NavigationMixin.Navigate]({
      type: sspConstants.communityPageNames.community,
      attributes: {
        name: "KIHIPP_Payment_Summary__c",
      },
      state: {
        individualId: this.individualId,
      },
    });
    this.showSpinner = false;
  };

  /* @function 		: handleBenefitNavigation.
   * @description 	: method to handle navigation on click of rac button.
   **/
  handleRac = () => {
    try {
      this.showSpinner = true;
      if (this.racActionType === sspConstants.dashboardConstants.Renewal) {
        if (this.medicaidRenewalList && this.medicaidRenewalList.length > 0) {
          driverNavigationDetails({
            caseNumber: this.medicaidRenewalList[0].CaseNumber,
          })
            .then((result) => {
              const response = result.mapResponse;
              if (response.bIsSuccess === true) {
                //test data
                //response.loggedInUserName='test@test.com';
                //response.availablePrograms.push('MA');
                let noModal = true;
                let timeLock = 30;
                if (!sspUtility.isUndefinedOrNull(response.timeLock)) {
                  timeLock = parseInt(response.timeLock);
                }
                if (
                  response.loggedInUserName != response.applicationChangedBy &&
                  !sspUtility.isUndefinedOrNull(response.minutesGap) &&
                  response.minutesGap <= timeLock
                ) {
                  this.showAnotherUserInProgress = true;
                  noModal = false;
                  this.showSpinner = false;
                }
                if (noModal) {
                  this.redirectToRenewal();
                }
              } else {
                this.showSpinner = false;
                console.error(
                  "Error in resumeApplication" + JSON.stringify(result)
                );
              }
            })
            .catch((error) => {
              this.showSpinner = false;
              console.error(
                "Error in resumeApplication" + JSON.stringify(error.message)
              );
            });
        } else {
          this.redirectToRenewal();
        }
      } else {
        this.showSpinner = false;
        this.showRACPopUp = true;
      }
    } catch (error) {
      this.showSpinner = false;
      console.error(
        "failed in handleRac in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: handleBenefitNavigation.
   * @description 	: method to handle spinner load.
   **/
  showDashboard = () => {
    try {
      if (
        this.medicaidLoaded &&
        this.benefitLoaded &&
        this.dashboardLoaded 
      ) {
        this.showSpinner = false;
                if (this.medicaidEBTDataFlag && this.genderCodeFlag) {
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
                    this.customLabels.sspEBTCardSuccessToast = formatLabels(
                        this.customLabels.sspEBTCardSuccessToast,
                        [this.medicaidEBTIndividualName]
                        //contactName
                    );
                    this.toastMessage = this.customLabels.sspEBTCardSuccessToast;
                    this.showErrorToast = true;
                }
                if (url.searchParams.get("requestMedicaidCard")) {
                    this.customLabels.sspMedicaidCardSuccessToast = formatLabels(
                        this.customLabels.sspMedicaidCardSuccessToast,
                        [this.medicaidEBTIndividualName, genderPronoun]
                    );
                    this.toastMessage = this.customLabels.sspMedicaidCardSuccessToast;
                    this.showErrorToast = true;
                }
      }
            }
    } catch (error) {
            this.showSpinner = false;
      console.error(
        "failed in showDashboard in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: handleBenefitNavigation.
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
  /**
   * @function 		: navigateMyInformation.
   * @description 	: method to navigate to My Information Page.
   **/
  navigateMyInformation = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: sspConstants.communityPageNames.community,
        attributes: {
          name: sspConstants.communityPageNames.myInformationApi,
          hasActiveCase: this.hasActiveCase,
          racButtonLabel: this.racButtonLabel,
        },
      });
    } catch (error) {
      console.error(
        "failed in navigateMyInformation in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: navigateToBenefitsScreen.
   * @description 	: method to navigate to benefits Page.
   **/
  navigateToBenefitsScreen = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: sspConstants.communityPageNames.community,
        attributes: {
          name: sspConstants.communityPageNames.getStartedBenefits,
        },
      });
    } catch (error) {
      console.error(
        "failed in navigateToBenefitsScreen in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: openConsentModal.
   * @description 	: Open Auth Rep Consent Modal.
   * @param {object} event - Js event.
   **/
  openConsentModal = (event) => {
    try {
      if (event.keyCode === 13 || event.type == "click") {
        if (event.target.dataset.type === "assister") {
          this.displayAssisterConsentModal = true;
        } else if (event.target.dataset.type === "auth") {
          this.displayAuthConsentModal = true;
        }
      }
    } catch (error) {
      console.error(
        "failed in openConsentModal in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: hideAuthConsentModal.
   * @description 	: hide Auth Rep Consent Modal.
   **/
  hideAuthConsentModal = () => {
    try {
          
     // this.loadMessageCenterData();
      this.displayAuthConsentModal = false;
      location.reload(); // for defect 391671
    } catch (error) {
      console.error(
        "failed in hideAuthConsentModal in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: hideAssisterConsentModal.
   * @description 	: hide Assister Consent Modal.
   **/
  hideAssisterConsentModal = () => {
    try {
            this.showSpinner = true;
    //  this.loadMessageCenterData();
      this.displayAssisterConsentModal = false;
      location.reload(); // for defect 391671
    } catch (error) {
      console.error(
        "failed in hideAssisterConsentModal in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };
  /**
   * @function 		: handleClick.
   * @description 	: method to handle Click on notification Banner Buttons.
   * @param {object} event - Js event.
   **/
  handleClick = (event) => {
    try {
      this.appId = event.currentTarget.dataset.application;
      this.showSpinner = true;
      this.notificationId = [];
      this.notificationId.push(event.currentTarget.dataset.id);
      this.authAssisterNotificationId = event.currentTarget.dataset.id;
      this.updateReadStatuses();
      const buttonAction = event.target.name;
      if (
        buttonAction === "opens Authorized Representative Access Request modal"
      ) {
        this.showSpinner = false;
        this.displayAuthConsentModal = true;
      } else if (buttonAction === "opens Assister Access Request modal") {
        this.showSpinner = false;
        this.displayAssisterConsentModal = true;
      } else if (buttonAction === "navigate user to Find a DCBS Office page") {
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
          attributes: {
            name: apConstants.navigationUrl.findDCBSOffice,
          },
        });
      } else if (buttonAction === "navigate user to Document Center") {
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
          attributes: {
            name: "documents__c",
          },
        });
      } else if (
        buttonAction === "navigate user to Renewal of Benefits screen"
      ) {
        this.redirectToRenewal();
      } else if (buttonAction === "navigate user to Claim Payments screen") {
        // Page Not created yet
      } else if (buttonAction === "navigate user to Application Summary") {
        this.applicationId = this.appId;
        this.redirectToIntake();
      } else if (
        buttonAction ===
        "navigate user to Message Center with Notice tab selected"
      ) {
        // need to set Notice tab as default
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
          attributes: {
            name: "Message_Center__c",
          },
        });
      } else if (
        buttonAction ===
        "navigate user to the assisted individual's Client View Dashboard"
      ) {
        // need implementation
      } else if (
        buttonAction ===
        "navigate user to Renewal of assisted individual's Benefits screen"
      ) {
        this.redirectToRenewal();
      } else if (buttonAction === "navigate user to Hearing Summary") {
                 this[NavigationMixin.Navigate]({
                     type: "comm__namedPage",
                     attributes: {
                         name: "Hearings__c"
                     },
                     state: {
                         hearingId: this.appId
                     }
                 });
            } else if (buttonAction === "call") {
        this.showSpinner = false;
        this.template.querySelector(".ssp-callPhone").click();
      }
    } catch (error) {
      console.error(
        "failed in handleClick in sspDashboardExistingUser" +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function 		: updateReadStatuses.
   * @description 	: method to Update read Status  of messages .
   **/
  updateReadStatuses = () => {
    updateReadStatus({
      notificationId: JSON.stringify(this.notificationId),
    })
      .then((result) => {})
      .catch((error) => {
        console.error(
          "Error in updateReadStatuses on Dashboard" +
            JSON.stringify(error.message)
        );
      });
  };
  /**
   * @function - navigateToPreScreeningToolPage
   * @description - Method is used to navigate to Pre-screening Tool Page.
   * @author : Narapa
   **/
  navigateToPreScreeningToolPage () {
    {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: sspConstants.communityPageNames.prescreeening,
        },
        state: {
          retPage: "dashboard__c",
        },
      });
    }
  }
  /**
     * @function - navigateToCCProviderSearchPage
     * @description - Method is used to navigate to Child Care Provider Search Tool Page.
     * @author : ChangeMeIn@UserSettingsUnder.SFDoc
     */

    navigateToCCProviderSearchPage () {
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.childCareProviderSearch
                },
                state: {
                    origin: "dashboard"
                }
            });
        }
    }

  iconClick = (event) => {
    if (
      event.keyCode === 13 ||
      event.type === "click" ||
      event.type === apConstants.events.iconClick
    ) {
      if (!sspUtility.isUndefinedOrNull(this.selectedCase)) {
        try {
          let result;
          generateEncryptedData({
            caseNumber: this.selectedCase,
            isHeadOfHouseHold: this.isHeadOfHouseHold,
          })
            .then((response) => {
              result = response.mapResponse;
              if (response.bIsSuccess) {
                const shoppingUrl = result.shoppingPortalUrl;
                window.open(shoppingUrl, "_self");
              }
            })
            .catch((error) => {
              console.error(
                "Error in iconClick on Dashboard" +
                  JSON.stringify(error.message)
              );
            });
        } catch (error) {
          console.error(
            "Error occurred in iconClick function on Dashboard" +
              JSON.stringify(error.message)
          );
        }
      }
    }
  }

  navigateMessageCenter () {
    this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
            name: "Message_Center__c"
        }
    });
  }

  navigateToRepsAssisters () {
    try {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: "auth-reps-assisters"
            }
        });
    } catch (error) {
        this.showSpinner = true;
        console.error("Error in navigateToRepsAssisters =>", error);
    }
}

navigateToBenefitsPage () {
    try {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: "benefits-page"
            }
        });
    } catch (error) {
        this.showSpinner = true;
        console.error("Error in navigateToBenefitsPage =>", error);
    }
    
}


  navigateBenefits () {
    this[NavigationMixin.Navigate]({
      type: sspConstants.communityPageNames.community,
      attributes: {
        pageName: "benefits-page",
      }
    });
  }
    /**
     * @function 		: handleRequestACard.
     * @description 	: method to navigate to Request a card screen.
     * @param {object} event - Js event.
     **/
handleRequestACard = event => {
        try {
          if (event.keyCode !== 9) {
				this.showSpinner = true;
				if (event.keyCode === 13 || event.type === "click") {
					if (event.target.name === "EBT") {
						validateSSORedirect({ sOperationName: "EBT_CARD_REQUEST" })
						.then(result => {
							const parsedData = result.mapResponse;
							this.showSpinner = true;
							if (parsedData.hasOwnProperty("endPoint") && parsedData.hasOwnProperty("encryptedToken")) {
								this.showSpinner = false;
								const portalUrl = new URL(parsedData.endPoint);
								portalUrl.searchParams.append("EncryptedData",parsedData.encryptedToken);
								window.open(portalUrl.href);
							} else {
								this[NavigationMixin.Navigate]({
									type: "comm__namedPage",
									attributes: {
										name: "Request_A_Card__c"
									},
									state: {
										requestEBT: "request"
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
							this.showSpinner = true;
							if (parsedData.hasOwnProperty("endPoint") && parsedData.hasOwnProperty("encryptedToken")) {
								this.showSpinner = false;
								const portalUrl = new URL(parsedData.endPoint);
								portalUrl.searchParams.append("EncryptedData",parsedData.encryptedToken);
								window.open(portalUrl.href);
							} else {
								this[NavigationMixin.Navigate]({
									type: "comm__namedPage",
									attributes: {
										name: "Request_A_Card__c"
									},
									state: {
										requestMedicaid: "request"
									}
								});
							}
						})
						.catch(error => {
							console.error("Error in Fraud" + JSON.stringify(error.message));
						});
					}
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
  /*
   * @function : handleKIHIPPPaymentSummaryAccess
   * @description : This method is used to get notified when toast hides.
   */
  handleKIHIPPPaymentSummaryAccess = () => {
    try {
      if (
        this.renderingMap.kHIPPPaymentSummary.isAccessible &&
        this.showKIHIPPSummary
      ) {
        this.showKIHIPPSummaryLink = true;
      } else {
        this.showKIHIPPSummaryLink = false;
      }
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
                
                    const medicaidVisibility = result.mapResponse.showMedicaidLink;
                    const visibilityEBT = result.mapResponse.showEBTLink;
                    if (medicaidVisibility !== null && 
                        medicaidVisibility !== undefined &&
                        medicaidVisibility === true &&
                        this.isHeadOfHouseHold  
                    ) {
                        this.isMedicaidRequestVisibility = true;
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
                    "@@@MediCaidEBTHandler error" + JSON.stringify(error)
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
                            "getMemberGenderCodeHandler error" +
                                JSON.stringify(error)
                        );
                    });
            }
        }
    }
    navigateToRequestTaxForms () {
        try {
            validateSSORedirect({
                sOperationName: "TAX_FORMS"
            })
            .then(result => {
                const parsedData = result.mapResponse;
                if (parsedData.hasOwnProperty("endPoint")) {
                    this.showSpinner = false;
                        const portalUrl = new URL(parsedData.endPoint);
                        portalUrl.searchParams.append("LookUpToken", "NULL");
                        portalUrl.searchParams.append("Source", "SSP");
                        portalUrl.searchParams.append("EncryptedData", parsedData.portal1095BToken);
                        window.open(portalUrl.href);
                } else {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: { name: "Request_Tax_Forms__c" }
                    });
                }
            })
            .catch(error => {
                console.error("Error loading SSO Tax Forms" + JSON.stringify(error.message));
            });
        } catch (error) {
            this.showSpinner = false;
            this.errorMsg = result.error;
            this.showErrorModal = true;
            this.isNotAccessible = false;
            console.error("Error Navigating Tax Forms"+error);
        }
    }
    handleBackyardNavigation () {
        backYardNavigate()
        .then(result => {
            this.backYardURL = result;
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: this.backYardURL
                }
            },
            true // Replaces the current page in your browser history with the URL
          );
        })
        .catch(error =>{
            console.error(error);
        });
    }


    /**
     * @function 		: reportFraud.
     * @description 	: method to navigate to Report Fraud.
     * @param {*} event - Js event.
     **/
    reportFraud = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                validateSSORedirect({ sOperationName: "FRAUD" })
                    .then(result => {
                        const parsedData = result.mapResponse;
                        this.showSpinner = true;
                        if (parsedData.hasOwnProperty("endPoint") && parsedData.hasOwnProperty("encryptedToken")) {
                            this.showSpinner = false;
                            const portalUrl = new URL(parsedData.endPoint);
                            portalUrl.searchParams.append("EncryptedData",parsedData.encryptedToken);
                            window.open(portalUrl.href);
                        } else {
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName:
                                        sspConstants.communityPageNames
                                            .reportFraud
                                }
                            });
                        }
                    })
                    .catch(error => {
                        console.error("Error in Fraud" + JSON.stringify(error.message));
                    });
            }
        } catch (error) {
            this.showSpinner = false;
            this.errorMsg = result.error;
            this.showErrorModal = true;
            this.isNotAccessible = false;
            console.error(error);
        }
    };
}
