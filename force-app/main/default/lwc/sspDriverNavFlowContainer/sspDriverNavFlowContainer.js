/* eslint-disable no-console */
/**
 * Component Name: sspDriverNavFlowContainer.
 * Author: Shikha Khanuja.
 * Description: This component is base component of framework which acts as container.
 * Date: 11/11/2019.
 */
import { track, api } from "lwc";
import execute from "@salesforce/apex/NavFlowController.execute";
import getMemberData from "@salesforce/apex/NavFlowController.getMemberDataImperative"; //#392585
import BaseComponent from "c/sspUtility";
import { formatLabels } from "c/sspUtility";
//import getMemberDetails from "@salesforce/apex/NavFlowController.getMemberDetails";

import sspProgressWillBeLost from "@salesforce/label/c.sspProgressWillBeLost";
import sspCannotBeConsideredForBenefits from "@salesforce/label/c.sspCannotBeConsideredForBenefits";
import sspLeaveTheApplication from "@salesforce/label/c.sspLeaveTheApplication";
import sspPleaseNote from "@salesforce/label/c.sspPleaseNote";
import sspLeaveApplication from "@salesforce/label/c.sspLeaveApplication";
import sspKihippPreferredPayment from "@salesforce/label/c.SSP_KihippPreferredPayment";
import sspSignaturePage from "@salesforce/label/c.sspSignaturePage";
import sspExpediteSnapBenefit from "@salesforce/label/c.SSP_ExpediteSnapBenefit"; 
import sspCollateralContactSnap from "@salesforce/label/c.SSP_CollateralContact"; //CR Changes - 1258

import constant , { applicationMode } from "c/sspConstants";
import changeSummary from "@salesforce/label/c.SSP_ChangeSummary";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import applicationSummary from "@salesforce/label/c.SSP_ApplicationSummary";
import applicationSummaryAlt from "@salesforce/label/c.SSP_ApplicationSummaryAlt";
import sectionDetail from "@salesforce/label/c.SSP_SectionDetail";
import sspHouseholdInformation from "@salesforce/label/c.SSP_HouseholdInformation";
import renewalSummary from "@salesforce/label/c.SSP_RenewalSummary";
import sspViewRenewalSummary from "@salesforce/label/c.SSP_ViewRenewalSummary";
import saveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import summaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidatorMessage";

const suffixArray = {
    JR: "JR.",
    SR: "SR.",
    TW: "II",
    TH: "III",
    FO: "IV",
    FV: "V",
    SI: "VI",
    SE: "VII"
};

export default class SspDriverNavFlowContainer extends BaseComponent {
  @api flowName;
  @api sectionId;
    @api mode; //= //constant.applicationMode.INTAKE;

  @track currentPageNo;
  @track totalPageCount;
  @track isLastPage;
  @track isFirstPage = false;
  @track contactId;
  @track screenPermission; //CD2 2.5 Security Role Matrix and Program Access.

  @track pageToLoad;
  @track pageName;
  @track curNavFlowPageConfigId;
  @track navFlowStatusId;
  @track recordId;
  @track displayHeaderFooter = true;
  @track ProgramShown;
  @track applicationId;
  @track buttonClicked;
  @track goToPageConfigIdValue;
  @track selectedScreens;
  @track selectedProgs;
  @track actVal;
  @track inputTempValue;
  @track objectValueSave;
  @track memberScreenDetails;
  @track memberScreenFullName;
  @track memberFirstName;
  @track action;
  @track headOfHousehold = false;
  @track isHouseholdFlow = false;
  @track isMemberFlow = false;
  @track isHealthCareFlow = false;
  @track isSignAndSubmitFlow = false;
  @track showSection = false;
  @track hideSection = false;
  @track isSignaturePage;
  @track sspConstants = constant;
  @track doneSaving;
  @track headerForHealthFlow = "";
  @track headerForSignSubmitFlow = "";

  @track memberId;
  @track saveExit;
  @track resolveErrors;
  @track showExit;
  @track isReviewRequiredFlow;
  @track sectionDetails;
  @track showSpinner = false;
  @track showNextSteps = false;
  @track reviewRequiredPages;
  @track saveExitTriggered = false;
  @track errorToast;

  intakeFlow;
  racFlow;

  label = {
    sspLeaveTheApplication,
    sspPleaseNote,
    sspCannotBeConsideredForBenefits,
    sspProgressWillBeLost,
    sspLeaveApplication,
    toastErrorText,
    benefitsApplication,
    applicationSummary,
    applicationSummaryAlt,
        sspHouseholdInformation,
        changeSummary,
        renewalSummary,
      sspViewRenewalSummary,
      saveAndExit
  };

  constructor () {
    super();
    try {
      this.template.addEventListener(
        "inputtempval",
        this.handleInputValue.bind(this)
      );
      this.template.addEventListener(
        this.sspConstants.events.hideSection,
        this.handleFrameworkSectionDisplay.bind(this)
      );
      this.template.addEventListener(
        "donesaving",
        this.handleDoneSaving.bind(this)
      );
      this.template.addEventListener(
        "updateheader",
        this.handleHeaderUpdate.bind(this)
      );
      this.template.addEventListener(
        "showcustomtoast",
        this.handleToastOnError.bind(this)
      );
      this.template.addEventListener(
        this.sspConstants.events.checkSignaturePage,
        this.checkTheSignaturePage.bind(this)
      );
            this.template.addEventListener(
                this.sspConstants.events.updateSignatureHeader,
                this.handleSignatureHeaderUpdate.bind(this)
            );
            this.template.addEventListener(
                constant.events.updateExpediteHeader,
                this.handleExpediteHeaderUpdate.bind(this)
            );
            //CR Changes - 1258
            this.template.addEventListener(
              this.sspConstants.events.updateCollateralHeader,
              this.handleCollateralHeaderUpdate.bind(this)
          );
          //CR Changes - 1258 end
    } catch (error) {
      console.error("Error loading framework constructor " + error);
    }
  }
  
  //#392585
  fetchMemberData (){
    if (this.memberId && this.applicationId){
      getMemberData({
        memberId: this.memberId,
        applicationId: this.applicationId
      }).then(data => {
        if(data){
          if (data.mapResponse && data.mapResponse.individual) {
            this.memberScreenDetails = [
              data.mapResponse.individual.SSP_Member__r.FirstName__c,
              data.mapResponse.individual.SSP_Member__r.LastName__c
            ]
              .filter(item => !!item)
              .join(" ");
            this.memberScreenFullName = [
              data.mapResponse.individual.SSP_Member__r.FirstName__c,
              data.mapResponse.individual.SSP_Member__r.MiddleInitial__c,
              data.mapResponse.individual.SSP_Member__r.LastName__c,
              suffixArray[data.mapResponse.individual.SSP_Member__r.SuffixCode__c]
            ]
              .filter(item => !!item)
              .join(" ");
            this.memberFirstName = data.mapResponse.individual.SSP_Member__r.FirstName__c + " " + data.mapResponse.individual.SSP_Member__r.LastName__c;

            this.headOfHousehold =
              data.mapResponse.individual.IsHeadOfHousehold__c;
          }
        }
      })
      .catch(error => {
        console.error(
          "failed in member data " +
          JSON.stringify(error)
        );
      });
    }   
  }

  connectedCallback () {
    try {
      this.showSpinner = true;
      const pageRef = this.pageReference;
      if (null != pageRef) {
        this.contactId = pageRef.state.contactId;
        this.flowName = pageRef.state.flowName;
        this.curNavFlowPageConfigId = pageRef.state.curNavFlowPageConfigId;
        this.navFlowStatusId = pageRef.state.navFlowStatusId;
        this.recordId = pageRef.state.recordId;
        this.loadFlow();
      } else {
        const url = new URL(window.location.href);
        this.applicationId = url.searchParams.get("applicationId");
        this.memberId = url.searchParams.get("memberId");
        this.recordId = url.searchParams.get("applicationId");
        this.mode = url.searchParams.get("mode") || "Intake";
        this.loadFlow();
      }
      if (this.mode && this.mode != "Intake") {
        this.showExit = true;
      } else {
        this.showExit = false;
      }
    this.fetchMemberData(); //#392585
    } catch (error) {
      console.error("Error in framework connected callback:", error);
    }
  }

  /**
   * @function : renderedCallback
   * @description : This method is called when the entire page content has been rendered.
   */
  renderedCallback () {
    const mainContainer = this.template.querySelector(".sspInputElement");
    if (this.isHealthCareFlow === true || this.isSignAndSubmitFlow === true) {
      mainContainer.classList.remove("ssp-bg_monoDelta");
    }
  }

  get hiddenClass () {
    return (this.hideSection && "slds-hide") || "slds-show";
  }

  /**
   * @function : pageTitle
   * @description : This getter is used to dynamically add label to screen based on mode.
   */
  get pageTitle () {
    if (this.mode === applicationMode.RENEWAL) {
      return renewalSummary;
    }
        if (this.mode === applicationMode.RAC || this.mode === constant.mode.addRemoveMember) {
      return changeSummary;
    }
    return applicationSummary;
  }

  get pageTitleAlt () {
        if (this.mode === applicationMode.RENEWAL) {
          return sspViewRenewalSummary;
        }
        if (this.mode === applicationMode.RAC || this.mode === constant.mode.addRemoveMember) {
            const searchMask = applicationSummary;
            const regEx = new RegExp(searchMask, "i");
            return applicationSummaryAlt.replace(
                regEx,
                changeSummary
            );
    }
    return applicationSummaryAlt;
  }

  /**
   * @function : loadFlow
   * @description : This method is used to load appropriate flow.
   */
  loadFlow () {
    try {
      const memberList = constant.flowNamesConstant.memberFlowList;
      if (
        this.flowName ===
        constant.flowNamesConstant.householdInformation
      ) {
        this.isHouseholdFlow = true;
      } else if (memberList.includes(this.flowName)) {
        this.isMemberFlow = true;
      } else if (
        this.flowName === constant.flowNamesConstant.healthCareCoverage
      ) {
        this.isHealthCareFlow = true;
      } else if (this.flowName === "SignAndSubmit") {
        this.isSignAndSubmitFlow = true;
      }

      this.intakeFlow =
        memberList.includes(this.flowName) ||
          this.flowName ===
          constant.flowNamesConstant.householdInformation
          ? true
          : false;
      this.racFlow = this.flowName === "Report a change Member" ? true : false;

      execute({
        action: "loadFlow",
        contactId: this.contactId,
        flowName: this.flowName,
        curNavFlowPageConfigId: this.curNavFlowPageConfigId,
        navFlowStatusId: this.navFlowStatusId,
        recordId: this.recordId,
        ApplicationId: this.applicationId,
        MemberId: this.memberId,
        selectedScreens: this.selectedScreens,
        lstOfSelectedPrograms: this.selectedProgs,
        mode: this.mode
      })
        .then(responseReceived => {
          this.pageToLoad = responseReceived;
          if(this.pageToLoad.hasNoAccess !== undefined && this.pageToLoad.hasNoAccess !== null && this.pageToLoad.hasNoAccess){
            this.showNextSteps = true;
          }else{
          this.screenPermission = responseReceived.screenPermission; ////CD2 2.5 Security Role Matrix and Program Access.
          this.showSpinner = false;
          if (
            responseReceived.pageInfo.PageName__c ===
            constant.pageNamesConstant.healthCareSelection
          ) {
            this.headerForHealthFlow = constant.pageHeaders.healthCareSelectionHeader;
          }
          if (
            responseReceived.pageInfo.PageName__c ===
            constant.pageNamesConstant.healthCareEnrollmentSummary
          ) {
            this.headerForHealthFlow = constant.pageHeaders.enrollmentHealthCoverage;
          }
          if (
            responseReceived.pageInfo.PageName__c ===
            constant.pageNamesConstant.healthCareAccessSummary
          ) {
            this.headerForHealthFlow = constant.pageHeaders.accessToHealthCoverage;
          }
          if (
            responseReceived.pageInfo.PageName__c ===
            constant.pageNamesConstant.healthCarePreferredPayment
          ) {
            this.headerForHealthFlow = sspKihippPreferredPayment;
          }
          if (
            responseReceived.pageInfo.PageName__c === "SSP_APP_ExpeditedSNAP"
          ) {
            this.headerForSignSubmitFlow = sspExpediteSnapBenefit;
          }
          // CR Changes 1258
          if (
            responseReceived.pageInfo.PageName__c === "SSP_APP_CollateralContact"
          ) {
            this.headerForSignSubmitFlow = sspCollateralContactSnap;
          }
          //  CR Changes 1258 End
          if (responseReceived.pageInfo.PageName__c === "SSP_APP_Signature") {
                        this.headerForSignSubmitFlow = sspSignaturePage;
          }

          this.handleNavDetails({
            responseReceived: responseReceived
          });
        }
        })
        .catch(errorOccurred => {
          console.error("Error in execute", errorOccurred);
        });
    } catch (error) {
      console.error("Error in framework load flow " + error);
    }
  }

  /**
   * @function : handleCallDriverParent
   * @description : This method is used to set review required flag to true.
   */
  handleCallDriverParent () {
    this.isReviewRequired = true;
  }

  /**
   * @function : handleDoneSaving
   * @description : This method is used to notify footer component that save has been completed.
   * @param {string} event - Event is fired from BaseNavFlowPage.
   */
  handleDoneSaving (event) {
    this.doneSaving = event.detail.doneSaving;
  }

  /**
   * @function : handleNextEvent
   * @description : This method is used to notify child components that next has been called.
   * @param {string} event - Event is fired from footer component.
   */
  handleNextEvent (event) {
    const actionToCall = event.detail.action;
    this.actVal = actionToCall;
    this.isSaveAndExit = event.detail.isSaveAndExit;
  } 

  /**
   * @function : handleToastOnError
   * @description : This method is used to raise toast on component if validation fails.
   */
  handleToastOnError () {
    if(this.isSaveAndExit !== true) {
      const summaryScreens = constant.summaryPageNameMap.summaryPage;
      if(summaryScreens.includes(this.actVal.pageInfo.PageName__c)){
        this.errorToast = summaryRecordValidator;
      }
      else{
        this.errorToast = toastErrorText;
      }
      this.resolveErrors = true;
    }
  }

  /**
   * @function : handleInputValue
   * @description : This method is used to get array of html elements from child component.
   * @param {string} event - Event is fired from child component having array of elements.
   */
  handleInputValue (event) {
    this.inputTempValue = event.detail.tempInput;
  }

  /**
   * @function : handleInputValue
   * @description : This method is used to show/Hide the framework section.
   * @param {string} event - Event is fired from child component to hide framework headers.
   */
  handleFrameworkSectionDisplay (event) {
    this.hideSection = event.detail.hideSectionFlag;
  }
  /**
   * @function : checkTheSignaturePage
   * @description : This method is check if the page is sign and submit.
   * @param {string} event - Event is fired from child component.
   */
  checkTheSignaturePage (event) {
    this.isSignaturePage = event.detail.isSignaturePage;
  }
  /**
   * @function : handleAllowSave
   * @description : This method is used to notify child component to save data.
   * @param {string} event - Event is fired from footer component.
   */
  handleAllowSave (event) {
    this.objectValueSave = event.detail.objVar;
  }

  /**
   * @function : handleNavigateSummary
   * @description : This method is used to navigate to application summary page.
   * @param {string} event - Event is fired from child components.
   */
  handleNavigateSummary (event) {
    try {
      event.preventDefault();
      event.stopPropagation();
      const isMemberFlow = this.pageToLoad && this.pageToLoad.flowName && this.pageToLoad.flowName.includes("Member");
      const withToast = event.detail && event.detail.withToast;
      if(isMemberFlow && withToast && !Array.isArray(this.$incompleteSections)) {
        this.$sourceSectionId = "Member_Details";
        this.$incompleteSections = ["Member_Details"];
      }
      this.navigateToAppSummary(null, this.applicationId);
    } catch (error) {
      console.error("Error in handleNavigateSummary " + error);
    }
  }

  /**
   * @function : handleResetAction.
   * @description : This method is used to reset track properties so that change is detected.
   */
  handleResetAction () {
    this.pageName = "";
    this.actValue = "";
    this.goToPageConfigIdValue = "";
    this.objectValueSave = "";
    this.actVal = "";
    this.doneSaving = "";
    this.resolveErrors = "";  
    this.saveExit = "";  
    this.inputTempValue = null;
  }
  
  /**
   * @function : handleNavButtonEventNext.
   * @description : This method is used to set new page to load on click of next .
   * @param {string} event - Event is fired from footer component.
   */
  handleNavButtonEventNext (event) {
    this.pageToLoad = event.detail.action;
    this.handleNavDetails(event.detail);
  }

  /**
   * @function : handleGoToAction.
   * @description : This method is used to go to page from section drop down.
   * @param {string} event - Event is fired from section drop down.
   */
  handleGoToAction (event) {
    this.goToPageConfigIdValue = event.detail.goToPageConfigId;
  }

  /**
   * @function : callSaveExit.
   * @description : This method is used to call save and exit modal on click of Save and Exit button.
   * @param {string} event - Event is fired from footer component.
   */
  callSaveExit (event) {
    try {
      if (event) {
        this.saveExit = true;
      } else {
        this.saveExit = false;
      }
    } catch (error) {
      console.error("Error in Framework callSaveExit " + error);
    }
  }

  /**
   * @function : closeModal.
   * @description : This method is used to close save and exit modal.
   */
  closeModal () {
    this.saveExit = false;
  }

  /**
   * @function : handleNavDetails.
   * @description : This method is used to determine whether current page is last page.
   * @param {string} detail - Detail is fired when next is clicked.
   */
  handleNavDetails (detail) {
    try {
      if (
        detail !== null &&
        detail !== undefined &&
        detail.responseReceived !== null &&
        detail.responseReceived !== undefined
      ) {
        const responseReceived = detail.responseReceived;
        this.currentPageNo =
          responseReceived.currentPageNo !== null &&
            responseReceived.currentPageNo !== undefined
            ? responseReceived.currentPageNo
            : this.currentPageNo;
        this.totalPageCount =
          responseReceived.totalPageCount !== null &&
            responseReceived.totalPageCount !== undefined
            ? responseReceived.totalPageCount
            : this.totalPageCount;
        this.isLastPage =
          responseReceived.isLastPage !== null &&
            responseReceived.isLastPage !== undefined
            ? responseReceived.isLastPage
            : this.isLastPage;

        this.isFirstPage = this.currentPageNo == 1;

        this.sectionDetails = formatLabels(sectionDetail, [
          this.currentPageNo,
          this.totalPageCount
        ]);
      }
    } catch (error) {
      console.error(
        "failed in sspDriverNavFlowContainer.handleNavDetails " +
        JSON.stringify(error)
      );
    }
  }
  handleReviewRequired (event) {
    if (this.isReviewRequiredFlow === undefined) {
      this.isReviewRequiredFlow = event.detail.requiredFlag;
    }
    
    this.flowCompleteStatus = event.detail.reviewComplete;
    this.reviewRequiredPages = event.detail.lstReviewScreens;
  }
  handleHeaderUpdate (event) {
    this.headerForHealthFlow = event.detail.header;
  }
    handleSignatureHeaderUpdate (event){
        
        this.headerForSignSubmitFlow = event.detail.header;
    }

    handleExpediteHeaderUpdate (event){
        
        this.headerForSignSubmitFlow = event.detail.header;
    }
    //CR Changes - 1258
    handleCollateralHeaderUpdate (event){
      this.headerForSignSubmitFlow = event.detail.header;
  }
   //CR Changes - 1258 end

   handleSaveExitCalled (){
     this.saveExitTriggered = true;
   }
}