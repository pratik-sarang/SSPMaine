import { track, api } from "lwc";
import execute from "@salesforce/apex/NavFlowController.execute";
import { NavigationMixin } from "lightning/navigation";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspSaveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspNextAltText from "@salesforce/label/c.SSP_NextAltText";
import goToDashboard from "@salesforce/label/c.SSP_GoDashboard";
import applicationAlreadySubmitted from "@salesforce/label/c.SSP_ApplicationAlreadySubmitted";
import applicationSubmittedHeading from "@salesforce/label/c.SSP_ApplicationSubmittedHeading";
import { formatLabels } from "c/sspUtility";
import sspSaveAndExitAltText from "@salesforce/label/c.SSP_SaveAndExitAltText";
import sspSubmitBenefitsApplication from "@salesforce/label/c.SSP_SubmitBenefitsApplication";
import sspSubmitApplicationTitle from "@salesforce/label/c.SSP_SubmitApplicationTitle";
import constants from "c/sspConstants";
import getApplicationDetails from "@salesforce/apex/SSP_Utility.getApplicationDetails";
import requestAccess from "@salesforce/apex/SSP_AuthRepAccessRequestService.getRequestAccessPermission";

export default class SspNavFlowFooter extends NavigationMixin(BaseNavFlowPage) {
  @api screenPermission; //CD2 2.5 Security Role Matrix and Program Access.
  @api flowName = "";
  @api isLastPage = false;
  @api isFirstPage = false;
  @api sectionId = "";
  @track i;
  @api pageToLoadReceived;
  @track updatedPageToLoad;
  @track onClickActions;
  @track goToPageConfigIdValue;
  @track allowSaveDataValue;
  @api applicationId;
  @api memberId;
  @track reviewReqValue;
  @track tempValueReceived;
  @track isReview;
  @track objectWrapper;
  @track noErrorValue;
  @track doneSavingValue;
  @api showExit;
  @api currentPageStatus;
  @api selectedScreensWrap;
  @api modeValue;
  //@api flowCompleteStatus;
  @api isReviewRequired;

  @track nextButtonLabel;
  @track nextButtonTitle;
  @track isSignSubmitPage = false;
  @track backButtonAlt;
    @track applicationSubmittedPopUp = false;
    @track reference = this;
    @track applicationAlreadySubmitted = applicationAlreadySubmitted;
  @api reviewRequiredPage;
    @track hideCross = false;
    @track saveExitValue = false;
    @track showNextSteps = false;
    _saveExitCalled;

    label = {
        sspSaveAndExit,
        sspBack,
        sspExitButton,
        sspNextAltText,
        sspSaveAndExitAltText,
        sspBackAltText,
        goToDashboard,
        applicationSubmittedHeading
  };

  get retExp1 (){
    if((this.screenPermission !== null &&
       this.screenPermission !== undefined &&
       this.screenPermission === constants.permission.readOnly) || this.showExit){
                return true;
            }
            return false;
  }

    @api
    get saveExitCalled (){
        return this._saveExitCalled;
    }
    set saveExitCalled (value){
        if(value === true){
            this._saveExitCalled = value;
            this.nextJs();
            this.onClickActions = "saveExit";
        }
    }

  @api
  get isSignaturePage () {
    return this.isSignaturePage;
  }
  set isSignaturePage (value) {
    if (value) {
      this.nextButtonLabel = sspSubmitBenefitsApplication;
      this.nextButtonTitle = sspSubmitApplicationTitle;
      this.isSignSubmitPage = true;
      this.backButtonAlt = sspBackAltText;
    } else if (value == false) {
      this.nextButtonLabel = sspNext;
      this.nextButtonTitle = sspNext;
            this.backButtonAlt = sspBackAltText;
            this.isSignSubmitPage = false; // CR Changes 1258
        }
    }
    get btnClassName () {
        return this.isSignSubmitPage ? "slds-col ssp-firstGroupBtn ssp-signature-page" : "slds-col ssp-firstGroupBtn";
    }
  @api
  get updCallDriver () {
    return this.isReview;
  }
  set updCallDriver (value) {
    if (value === true) {
      this.isReview = value;

      if (this.onClickActions !== "saveExit") {
        this.executeFlow("next", this.pageToLoadReceived.recordId, null, null);
        this.updCallDriver = false;
      }
    }
  }

  @api
  get doneSaving () {
    return this.doneSavingValue;
  }
  set doneSaving (value) {
    this.doneSavingValue = value;
    if (value === true) {
      this.validateReviewRequiredRules(
        this.applicationId,
        this.memberId,
        this.pageToLoadReceived.pageInfo.PageName__c,
        this.modeValue
      );
    }
  }

    @api
    get inputTempValue () {
        return this.tempValueReceived;
    }
    set inputTempValue (value) {
        if(value === "valid") {
            this.noError = true;
        }
        else if(value === "invalid") {
            this.noError = false;
        }
        else if (value) {
            this.tempValueReceived = value;
            this.checkRequestAccess();
            /**Added by Shrikant. */
            if (
                this.screenPermission != null &&
                this.screenPermission != undefined &&
                this.screenPermission === constants.permission.readOnly
            ) {
                this.saveCompleted = true;
            } else {
                /** */
                this.twoWayBindingUtility(value);
                this.checkValidations(value);
            }
        }
    }

  @api
  get goToPageConfigId () {
    return this.goToPageConfigIdValue;
  }
  set goToPageConfigId (value) {
    this.goToPageConfigIdValue = value;
    if (value) {
      this.onClickActions = "goToPage";
      this.executeFlow(
        "goToPage",
        this.pageToLoadReceived.recordId,
        value,
        null
      );
      this.goToPageConfigIdValue = "";
    }
  }

    @api
    get noError () {
        return this.noErrorValue;
    }
    set noError (value) {
        this.noErrorValue = value;
        if (value === true) {
            this.callSaveFunction();
        } else if (value === false) {
            if(this.onClickActions === "saveExit" ) {
                //const saveExitEvent = new CustomEvent("saveexit");
                //this.dispatchEvent(saveExitEvent);
            }
            else {
                const showToastEvent = new CustomEvent("showcustomtoast");
                this.dispatchEvent(showToastEvent);
            }
        }
    }

  get retexp1 () {
    return this.flowName !== "ReportAChange";
  }

  connectedCallback () {}

  backJs () {
    this.onClickActions = "back";
    this.executeFlow("back", this.pageToLoadReceived.recordId, null, null);
  }

    nextJs (event) {
        if (this.nextButtonLabel === sspSubmitBenefitsApplication) {
            this.getRecord();
        } else {
            this.onClickActions = "next";
            const nextEvent = new CustomEvent("nextevent");
            this.dispatchEvent(nextEvent);
            const actionNext = new CustomEvent("actionnext", {
                detail: {
                    action: this.pageToLoadReceived,
                    isSaveAndExit: !event
                }
            });
            this.dispatchEvent(actionNext);
        }
    }
    checkRequestAccess (){
            const url = new URL(window.location.href);
            const applicationId = url.searchParams.get("applicationId");
            requestAccess ({appId: applicationId})
            .then(result => {               
             if(result !==  undefined && result !==  null && result.mapResponse !== undefined && result.mapResponse !==  null ){       
                            
            
             if (result.mapResponse.hasAccess === undefined || result.mapResponse.hasAccess  === null) {
              const summaryNavigationEvent = new CustomEvent("summarynavigation");
              this.dispatchEvent(summaryNavigationEvent);
             }
            }
    });
  }
    saveExit () {
        const invokeDriver = new CustomEvent(constants.events.invokeDriver);
        this.dispatchEvent(invokeDriver);
    }

  /**
   * @function : onExit
   * @description : This method is used to navigate to dashboard in RAC/Renewal/Add or remove flow.
   */
  onExit = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.navigationUrl.existingDashboard
        },
        state: {}
      });
    } catch (error) {
      console.error("Error occurred in continueEarly" + error);
    }
  };
  leaveHandler (event) {
    event.returnValue =
      "Are you sure you want to leave? All changes will be lost!";
  }

  @api
  preventLeaving () {
    window.addEventListener("beforeunload", this.leaveHandler);
  }

  executeFlow (action, recordId, goToPageConfigId, selectedProgram) {
    let selectedScreens;
    if (this.flowName === "Report a change Member") {
      selectedScreens = JSON.parse(
        window.localStorage.getItem(this.applicationId)
      );
    }
    let selectedPrograms = selectedProgram;
    selectedPrograms = JSON.parse(window.localStorage.getItem(this.memberId));

    if (this.isFirstPage && this.onClickActions === "back") {
      const summaryNavigationEvent = new CustomEvent("summarynavigation");
      this.dispatchEvent(summaryNavigationEvent);
    } else {
      const index = this.pageToLoadReceived.pageConfig && this.pageToLoadReceived.pageConfig.SequenceNumber__c;
      const pageDuplicateStatus = index && this.pageToLoadReceived.flowStatus && this.pageToLoadReceived.flowStatus[index - 1];
      execute({
        action: action,
        contactId: this.pageToLoadReceived.contactId,
        flowName: this.flowName,
        curNavFlowPageConfigId: this.pageToLoadReceived.pageConfig.Id,
        navFlowStatusId: this.pageToLoadReceived.navFlowStatusId,
        recordId: recordId,
        goToPageConfigId: goToPageConfigId,
        selectedScreens: selectedScreens,
        lstOfSelectedPrograms: selectedPrograms,
        ApplicationId: this.pageToLoadReceived.applicationId,
        MemberId: this.pageToLoadReceived.memberId,
        mode: this.modeValue,
        noStatusReviewRequired : this.reviewRequiredPage     
      })
        .then(result => {
          /** #379955 fix.*/
          if (result != null && result != undefined && result.navigateToSummary && !result.applicableMemberFlow) {
            const summaryNavigationEvent = new CustomEvent("summarynavigation", {
              detail: {
                withToast: pageDuplicateStatus === "R" || !pageDuplicateStatus
              }
            });
            this.dispatchEvent(summaryNavigationEvent);
          }
          else if (result.applicableMemberFlow){
            this[NavigationMixin.Navigate]({
              type: "comm__namedPage",
              attributes: {
                  name: result.applicableMemberFlow,
              },
              state: {
                  applicationId: this.pageToLoadReceived.applicationId,
                  memberId: this.pageToLoadReceived.memberId,
                  mode: this.modeValue
              }
            });
          }
          else {
          /** */
            this.screenPermission = result.screenPermission; //CD2 2.5 Security Role Matrix and Program Access.
            const flowPageStatus = result.flowPageStatus;
                        if(result.hasNoAccess !== undefined && result.hasNoAccess !== null && result.hasNoAccess){
                          this.showNextSteps = true;
                          const summaryNavigationEvent = new CustomEvent("summarynavigation");
                          this.dispatchEvent(summaryNavigationEvent);
                        }else{
            if (
              (((!flowPageStatus.includes("R") &&
                (goToPageConfigId === null || goToPageConfigId === undefined)) ||
                (this.isReviewRequired && result.currentPageNo === "1" && !flowPageStatus.includes("R"))) &&
                this.onClickActions !== "back") ||
              (this.isFirstPage && this.onClickActions === "back")
            ) {
              const summaryNavigationEvent = new CustomEvent("summarynavigation");
              this.dispatchEvent(summaryNavigationEvent);
            } else {
              this.updPageToLoad = result;
              const buttonEvent = new CustomEvent("buttoneventnext", {
                detail: {
                  action: result,
                  isCalledFromBrowser: false,
                  buttonClicked: this.actVal,
                  responseReceived: result
                }
              });
              this.dispatchEvent(buttonEvent);
                        }
            }
          } //#379955
        })
        .catch(error => {
          console.error("Error in executeFlow", error);
        });
    }
  }

  twoWayBindingUtility (inputValue) {
    if (inputValue.length > 0) {
      let jsonStr = "";
      for (let i = 0; i < inputValue.length; i++) {
        if (
          inputValue[i].value !== null &&
          inputValue[i].value !== undefined &&
          inputValue[i].value !== ""
        ) {
          jsonStr =
            '"' +
            inputValue[i].getAttribute("data-id") +
            '"' +
            ":" +
            '"' +
            inputValue[i].value +
            '"' +
            "," +
            jsonStr;
        } else {
          jsonStr =
            '"' +
            inputValue[i].getAttribute("data-id") +
            '"' +
            ":" +
            null +
            "," +
            jsonStr;
        }
      }
      jsonStr = jsonStr.substring(0, jsonStr.length - 1);
      const objVar = "{" + jsonStr + "}";
      this.objectWrapper = objVar;
    }
  }

  callSaveFunction () {
    const saveScreenData = new CustomEvent("savescreendata", {
      detail: {
        objVar: this.objectWrapper
      }
    });
    this.dispatchEvent(saveScreenData);
  }
    /**
     * @function - getRecord().
     * @description - This is a  function to get INDIVIDUAL record for SSP Member.
     */
    getRecord () {
        try {
            getApplicationDetails({
                applicationId: this.applicationId
            })
                .then(response => {
                    if (response) {
                        this.application = JSON.parse(
                            response.mapResponse.applicationDetails
                        );
                        if (
                            this.application.Status__c === constants.navFlowApplicationStatus.P &&
                            this.application.RecordType.DeveloperName ===
                            constants.navFlowApplicationStatus.SSP_Application
                        ) {
                            this.applicationAlreadySubmitted = formatLabels(
                                this.applicationAlreadySubmitted,
                                [this.application.Name]
                            );
                            this.applicationSubmittedPopUp = true;
                        } else {
                            this.onClickActions = "next";
                            const nextEvent = new CustomEvent("nextevent");
                            this.dispatchEvent(nextEvent);
                            const actionNext = new CustomEvent("actionnext", {
                                detail: {
                                    action: this.pageToLoadReceived
                                }
                            });
                            this.dispatchEvent(actionNext);
                        }
                    }
                })
                .catch(error => {
                    console.error(
                        "failed in  getApplicationDetails" +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in getMember:", error);
        }
    }
}