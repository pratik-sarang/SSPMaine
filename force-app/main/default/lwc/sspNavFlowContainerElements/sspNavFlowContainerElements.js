import { LightningElement, api, track } from "lwc";
import sspConstants from "c/sspConstants";
import sspPollingInterval from "@salesforce/label/c.SSP_IsDataProcessedPollingInterval";
import reviewRequiredNote from "@salesforce/label/c.SSP_ReviewRequiredNote";
import affectedScreensList from "@salesforce/label/c.SSP_AffectedScreensList";
import reviewRequiredToastMessage from "@salesforce/label/c.SSP_ReviewRequiredToastMessage";
//import sspRelatedScreen from "@salesforce/label/c.SSP_RelatedScreen";
import sspAffectedSections from "@salesforce/label/c.SSP_AffectedSections";
//import sspYouHaveAdded from "@salesforce/label/c.SSP_YouHaveAdded";
import sspYouHaveChangedInfo from "@salesforce/label/c.SSP_YouHaveChangedInfo";
import sspEditedScreen1 from "@salesforce/label/c.SSP_EditedScreen1";
import sspEditedScreen2 from "@salesforce/label/c.SSP_EditedScreen2";
import sspReviewBannerText from "@salesforce/label/c.SSP_ApplicationSummaryReviewText";

import fetchTransactionStatus from "@salesforce/apex/NavFlowManager.fetchTransactionStatus";
import fetchApplicationDetails from "@salesforce/apex/NavFlowManager.fetchApplicationDetails";
import fetchRequiredStatus from "@salesforce/apex/NavFlowManager.fetchReviewRequiredDetails";
import getOrStartRSSPDCTransaction from "@salesforce/apex/NavFlowController.getOrStartRSSPDCTransaction";
import retryRSSPDCTransaction from "@salesforce/apex/SSP_Utility.retryRSSPDCTransaction";
import { formatLabels } from "c/sspUtility";

export default class SspNavFlowContainerElements extends LightningElement {
  @track showErrorModal = false;
  @track errorMsg;
  @track pageToLoadReceived;
  @track applicantDetails = false;
  @track medicaid = false;
  @track ethnicity = false;
  @track income = false;
  @track followup = false;
  @track summary = false;
  @track hohContact = false;
  @track hohAddress = false;
  @track nonPrimaryContact = false;
  @track nonPrimaryAddress = false;
  @track removeExistingExpenses = false;
  @track healthSelection = false;
  @track householdSelection = false;
  @track resourceSelection = false;
  @track otherResourceSelection = false;
  @track showIncomeSummary = false;
  @track showExpensesSummary = false;
  @track showEntitledBenefits = false;
  @track changeExistingIncome = false;
  @track changeExistingExpense = false;
  @track showMedicalEnforcement = false;
  @track incomeAndSubsidiesSelection = false;
  @track expensesSelection = false;
  @track removeExistingIncome = false;
  @track householdMeals = false;
  @track healthCoverage = false;
  @track healthCoverageEnrollSummary = false;
  @track resourceSummary = false;
  @track removeExistingResource = false;
  @track changeExistingResource = false;
  @track relationship = false;
  @track pregnancy = false;
  @track showDisability = false;
  @track absentParent = false;
  @track nativeIndianAmerican = false;
  @track conviction = false;
  @track ssiBenefits = false;
  @track healthCoverageAccessSummary = false;
  @track noCitizen = false;
  @track inHome = false;
  @track expeditedSNAP = false;
  @track collateralSNAP = false;//CR�Changes�-�1258
  @track signaturePage = false;
  @track livingArrangement = false;
  @track healthCondition = false;
  @track medicareCoverageSummary = false;
  @track preferredPaymentMethod = false;
  @track medicalBills = false;
    @track planSelection = false;
  @track showAlienSponsor = false;
  @track showEducationSummary = false;
  @track taxFilingDetails = false;
  @track showCareTakerServices = false; //CD2 - 6.5.2 - Caretaker Services
  @track showCIS = false; //CD2 - 6.5.1 - CIS Services
  @track showOutOfStateSummary = false;
  @track showSpinner = false;
  @track fosterCare = false;

  @api newMember = false;
  @api applicationId;
  @api mode = "Intake"; //Intake / RAC
  @track appIdValue;
  @track actionVal;
  @api memberId;
  @track isOnLoadVal;
  @api flowName;
  @api flowStatus;
  @track nextEventValue;
  @track isEditable;
  @track allowSaveData;
  @track pageNameValue;
  @api action;
  @api headOfHousehold;
  @api currentMemberName;
  @api currentMemberFullName;
  @api memberFirstName;
  @track screenName;
  @track pageName;
  @track mapReviewRequired = [{}];
  @track lstReviewRequired = [];
  @track showBanner = false;
  @track bannerText = "";
  @track lstReviewRequiredNames = [];
  applicationDetails = {};
  isDataProcessed = true;
  @track showLinkForBanner = false;
  @track lstReviewRequiredScreenNames;
  @track showReviewScreenPopup = false;
  @track reference = this;
  @track objReviewRequired;
  @track showBlindness;
  @api applicationPrograms;
  @track noFlowReviewRequired = false;
  @track noFlowReviewScreens;


  @api
  get allowSave () {
    return this.allowSaveData;
  }
  set allowSave (value) {
    this.allowSaveData = value;
  }

  @api
  get pageToLoadApi () {
    return this.pageToLoadReceived;
  }
  set pageToLoadApi (value) {
    this.applicationDetails = {};
    if (this.pageToLoadReceived !== value && value !== undefined) {
      this.pageToLoadReceived = value;
      this.flowStatus = value.flowStatus;
      try {
        // this.determineDataVisibility(
        //     this,
        //     this.mode,
        //     this.pageToLoadReceived.pageInfo.PageName__c
        // );
        this.startRSSPDCTransaction();
        this.fetchReviewRequired();
      } catch (error) {
        console.error(
          "Error in sspNavFlowContainerElements.pageToLoadApi" + error
        );
      }
      //End -For polling
    }
  }

  @api
  get nextEvent () {
    return this.nextEventValue;
  }
  set nextEvent (value) {
    if (value !== undefined) {
      this.nextEventValue = value;
    }
  }

  @api
  get actionReceived () {
    return this.actionVal;
  }
  set actionReceived (value) {
    this.actionVal = value;
  }

  label = {
    sspAffectedSections,
    affectedScreensList,
    reviewRequiredToastMessage,
    reviewRequiredNote,
    sspReviewBannerText,
    sspYouHaveChangedInfo
  };
  connectedCallback () {
    this.showSpinner = true;
  }

  startRSSPDCTransaction = async () => {
    try {
      this.pollCounter = 0;
      this.showSpinner = true;
      await new Promise(this.transactionHelper);
      this.initiatePageLoad();
      this.showSpinner = false;
    } catch (error) {
      this.showSpinner = false;
      this.showErrorModal = true;
    }
  };

  transactionHelper = (resolve, reject) => {
    try {
      getOrStartRSSPDCTransaction({
        applicationId: this.applicationId,
        screenName: this.pageToLoadReceived.pageInfo.PageName__c,
        mode: this.mode
      }).then(response => {
        if (response.bIsSuccess && response.mapResponse) {
          if (response.mapResponse.isSuccess) {
            resolve(response);
          } else if (response.mapResponse.isFailed) {
            this.errorMsg = response.mapResponse.logName;
            reject(response);
          } else {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(
              () => this.transactionHelper(resolve, reject),
              +sspPollingInterval
            );
          }
        } else {
          reject(response);
        }
      });
    } catch (error) {
      reject(error);
    }
  };

  retryTransaction = async () => {
    try {
      this.showErrorModal = false;
      this.showSpinner = true;
      const mode = this.mode === "addRemoveMember" ? "RAC" : this.mode;
      await retryRSSPDCTransaction({
        mode,
        applicationId: this.applicationId
      });
      this.startRSSPDCTransaction();
    } catch (error) {
      console.error("Error in retry", error);
    }
  };

  fetchReviewRequired () {
    let tempmemberId = "";
    if (this.memberId !== null) {
      tempmemberId = this.memberId;
    }
    fetchRequiredStatus({
      applicationId: this.applicationId,
      memberId: tempmemberId,
      flowName: this.flowName,
      mode : this.mode
    }).then(result => {
      if (result) {
        const lstReviewRequiredNames = [];
        let mapDisplayNameVSScreenName = [{}];
        const reviewLastPage = result.mapResponse.reviewLastPage;
        if (result.mapResponse.hasOwnProperty("mapScreenNames")) {
          mapDisplayNameVSScreenName = JSON.parse(
            result.mapResponse.mapScreenNames
          );
        }
        if (result.mapResponse.hasOwnProperty(
          "noFlowReviewRequired")
          ){
          this.noFlowReviewRequired = result.mapResponse.noFlowReviewRequired;
          if(this.noFlowReviewRequired === true){
              this.showBanner = true;
          }
        }
        if (result.mapResponse.hasOwnProperty(
          "reviewRequiredPages")){
              const reviewPages = result.mapResponse.reviewRequiredPages;
              if(reviewPages && reviewPages.length > 1){
                  this.showLinkForBanner = true;
                  this.lstReviewRequiredScreenNames = reviewPages;
                  this.noFlowReviewScreens = reviewPages;
              }
              else{
                  this.showLinkForBanner = false;
                  this.lstReviewRequiredScreenNames = [];
              }
          }
        if (result.mapResponse.hasOwnProperty("screenStatus")) {
          this.mapReviewRequired = JSON.parse(result.mapResponse.screenStatus);
          if (
            this.mapReviewRequired.hasOwnProperty(
              this.pageToLoadReceived.pageInfo.PageName__c
            )
          ) {
            this.objReviewRequired = this.mapReviewRequired[
              this.pageToLoadReceived.pageInfo.PageName__c
            ];
            let lstReviewReqScreens = [];
            let lstReviewEffectedScreens = [];
            const lstReviewEffectedScreensNames = [];
            if (result.mapResponse.hasOwnProperty("reviewRequiredScreens")) {
              lstReviewReqScreens = JSON.parse(
                result.mapResponse.reviewRequiredScreens
              );
            }

            if (
              this.objReviewRequired.reviewReqScreens !== null &&
              this.objReviewRequired.reviewReqScreens !== undefined &&
              this.objReviewRequired.reviewReqScreens.includes(",")
            ) {
              lstReviewEffectedScreens = this.objReviewRequired.reviewReqScreens.split(
                ","
              );
            } else {
              lstReviewEffectedScreens.push(
                this.objReviewRequired.reviewReqScreens
              );
            }
            if (
              lstReviewEffectedScreens.length > 0 &&
              mapDisplayNameVSScreenName !== null
            ) {
              lstReviewEffectedScreens.forEach(reviewRequiredObject => {
                if (
                  mapDisplayNameVSScreenName.hasOwnProperty(
                    reviewRequiredObject
                  )
                ) {
                  lstReviewEffectedScreensNames.push(
                    mapDisplayNameVSScreenName[reviewRequiredObject]
                  );
                }
              });
            }
            if (
              lstReviewReqScreens.length > 0 &&
              mapDisplayNameVSScreenName !== null
            ) {
              lstReviewReqScreens.forEach(reviewRequiredObject => {
                if (reviewRequiredObject === "SSP_APP_HHMemberDetails") {
                  lstReviewRequiredNames.push("Household Member");
                } else {
                  if (
                    mapDisplayNameVSScreenName.hasOwnProperty(
                      reviewRequiredObject
                    )
                  ) {
                    lstReviewRequiredNames.push(
                      mapDisplayNameVSScreenName[reviewRequiredObject]
                    );
                  }
                }
              });
            }

            if (this.objReviewRequired.isReviewRequired) {
              this.showBanner = true;
              //const strScreenNames = "";
              if (
                lstReviewRequiredNames &&
                lstReviewRequiredNames.length <= 1
              ) {
                this.showLinkForBanner = false;
                /*if (lstReviewEffectedScreensNames.length === 1) {
                  strScreenNames = lstReviewEffectedScreensNames[0];
                } else if (lstReviewEffectedScreensNames.length > 1) {
                  strScreenNames = lstReviewEffectedScreensNames.join(", ");
                } else {
                  strScreenNames = sspRelatedScreen;
                }
                if (strScreenNames !== null && strScreenNames !== "") {
                  this.bannerText = formatLabels(sspYouHaveAdded, [
                    strScreenNames,
                    mapDisplayNameVSScreenName[
                      this.pageToLoadReceived.pageInfo.PageName__c
                    ]
                  ]);
                }*/
              } else if (lstReviewRequiredNames.length > 1) {
                this.lstReviewRequiredScreenNames = [];
                this.lstReviewRequiredScreenNames = lstReviewRequiredNames;
                this.showLinkForBanner = true;
                this.bannerText = sspYouHaveChangedInfo;
              } else if (
                mapDisplayNameVSScreenName.hasOwnProperty(
                  this.pageToLoadReceived.pageInfo.PageName__c
                )
              ) {
                this.bannerText = formatLabels(sspEditedScreen1, [
                  mapDisplayNameVSScreenName[
                    this.pageToLoadReceived.pageInfo.PageName__c
                  ]
                ]);
              } else {
                this.bannerText = sspEditedScreen2;
              }
            } else {
              this.showBanner = false;
            }
          }
        }
        const reviewReqEvent = new CustomEvent("reviewrequiredevent", {
          detail: {
            requiredFlag:
              this.objReviewRequired && (this.objReviewRequired.isReviewRequired || this.noFlowReviewRequired),
            reviewComplete: reviewLastPage,
            lstReviewScreens : this.noFlowReviewScreens
          }
        });
        this.dispatchEvent(reviewReqEvent);
      }
    });
  }

  handleCallDriver () {
    const callDriverParent = new CustomEvent("calldriverparent");
    this.dispatchEvent(callDriverParent);
  }

  /**
   * @function : determineDataVisibility
   * @description	: Method fetch data required for determining IsDataProcessed.
   * @param {object} self - Reference to same cmp.
   * @param {object} flowName - Mode name.
   * @param {object} screenName - Screen Id.
   */
  determineDataVisibility (self, flowName, screenName) {
    try {
      this.isDataProcessed = false;
      this.fetchApplicationDetailsFromServer(function (result) {
        if (result) {
          const args = {
            sHOHId: self.applicationDetails.sHOHId,
            sScreenName: screenName,
            sMode: flowName
          };
          self.fetchTransactionStatusFromServer(args);
        }
      });
    } catch (error) {
      console.error(
        "Error in sspNavFlowContainerElements.determineDataVisibility" + error
      );
    }
  }

  /**
   * @function : fetchTransactionStatusFromServer
   * @description	: Fetch if data related to current screen is loaded to SF objects.
   * @param {object} functionArguments - Parameters to Apex method.
   */
  fetchTransactionStatusFromServer (functionArguments) {
    try {
      fetchTransactionStatus({ detailMap: functionArguments })
        .then(response => {
          const result = response.mapResponse;
          if (result.hasOwnProperty("ERROR")) {
            console.error(
              "Error in sspNavFlowContainerElements.fetchTransactionStatusFromServer" +
                result.ERROR
            );
          } else if (result.hasOwnProperty("status")) {
            const status = result.status;
            if (
              status === "NULL" ||
              status === sspConstants.pollingStatus_RAC.success
            ) {
              this.isDataProcessed = true;
              this.initiatePageLoad();
            } else if (status === sspConstants.pollingStatus_RAC.failure) {
              const message = result.message;
              this.showErrorModal = true;
              this.errorMsg = message;
              this.isDataProcessed = true;
            } else if (status === sspConstants.pollingStatus_RAC.pending) {
              const pollingInterval = parseInt(sspPollingInterval);
              // eslint-disable-next-line @lwc/lwc/no-async-operation
              setTimeout(() => {
                this.fetchTransactionStatusFromServer(functionArguments);
              }, pollingInterval);
            }
          }
        })
        .catch(error => {
          console.error(
            "failed in sspNavFlowContainerElements.fetchTransactionStatusFromServer " +
              error
          );
        });
    } catch (error) {
      console.error(
        "Error in sspNavFlowContainerElements.fetchApplicationDetailsFromServer" +
          error
      );
    }
  }

  /**
   * @function : fetchApplicationDetailsFromServer
   * @description	: Fetch current application related data from server.
   * @param {object} callback - Calling method call back.
   */
  fetchApplicationDetailsFromServer (callback) {
    try {
      const applicationDetails = {};
      const functionAttributes = {
        sspApplicationId: this.applicationId
      };
      fetchApplicationDetails(functionAttributes)
        .then(response => {
          const result = response.mapResponse;
          if (result.hasOwnProperty("ERROR")) {
            console.error(
              "Error in sspNavFlowContainerElements.fetchApplicationDetailsFromServer  : " +
                result.ERROR
            );
          } else if (
            result.hasOwnProperty("sHOHId") &&
            result.sHOHId === "NULL"
          ) {
            this.isDataProcessed = true;
            this.initiatePageLoad();
          } else {
            applicationDetails.sHOHId = result.hasOwnProperty("sHOHId")
              ? result.sHOHId
              : null;
            this.applicationDetails = applicationDetails;
            if (callback) {
              callback(true);
            }
          }
        })
        .catch(error => {
          console.error(
            "failed in sspNavFlowContainerElements.fetchApplicationDetailsFromServer " +
              error
          );
        });
    } catch (error) {
      console.error(
        "Error in sspNavFlowContainerElements.fetchApplicationDetailsFromServer" +
          error
      );
    }
  }

  // get showSpinner () {
  //     return !this.isDataProcessed;
  // }

  initiatePageLoad () {
    const value = this.pageToLoadReceived;
    this.screenName = value.pageInfo.PageName__c;
    if (this.pageToLoadReceived.flowName === "ApplicationIntake") {
      this.loadTemplate();
    }
    if (
      this.pageToLoadReceived.flowName === "MemberDetails" ||
      this.pageToLoadReceived.flowName === "MemberRemoveDetails"
    ) {
      this.loadTemplateMemberDetails();
    }
    if (this.pageToLoadReceived.flowName === "MemberIndividualInformation") {
      this.loadTemplateMemberIndividualInfo();
    }
    if (this.pageToLoadReceived.flowName === "MemberHealthInformation") {
      this.loadTemplateMemberHealthInfo();
    }
    if (this.pageToLoadReceived.flowName === "MemberOtherInformation") {
      this.loadTemplateMemberOtherInfo();
    }
    if (this.pageToLoadReceived.flowName === "MemberResourcesInformation") {
      this.loadTemplateMemberResourcesInfo();
    }
    if (this.pageToLoadReceived.flowName === "MemberIncomeSubsidiesInfo") {
      this.loadTemplateMemberIncomeInfo();
    }
    if (this.pageToLoadReceived.flowName === "MemberExpensesInformation") {
      this.loadTemplateMemberExpInfo();
    }
    if (this.pageToLoadReceived.flowName === "ContactInformation") {
      this.loadTemplateContactInfo();
    }
    /*if (this.pageToLoadReceived.flowName === "ContactInformation - NP") {
            this.loadTemplateContactInfoNP();
        }*/
    if (this.pageToLoadReceived.flowName === "HouseholdInformation") {
      this.loadTemplateHouseholdInfo();
    }
    if (this.pageToLoadReceived.flowName === "HealthcareCoverage") {
      this.loadTemplateHealthCareCoverage();
    }
    if (this.pageToLoadReceived.flowName === "Relationships&TaxFiling") {
      this.loadTemplateRelationships();
    }
    if (this.pageToLoadReceived.flowName === "SignAndSubmit") {
      this.loadTemplateSignAndSubmit();
    } else {
      this.handleSignaturePageEvent(false);
    }

    this.scrollToTopPage();
    this.showSpinner = false;
  }

  loadTemplateMemberDetails () {
    this.pageNameValue =
      this.pageToLoadReceived.pageInfo.PageName__c +
      "," +
      this.pageToLoadReceived.memberId;
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_EditExistingIncome"
    ) {
      this.changeExistingIncome = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.changeExistingIncome = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_MedicalEnforcement" ||
      this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_ChildMedicalEnforcement"
    ) {
      this.showMedicalEnforcement = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showMedicalEnforcement = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_RemoveExistingIncome"
    ) {
      this.removeExistingIncome = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.removeExistingIncome = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_EditExistingExpense"
    ) {
      this.changeExistingExpense = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.changeExistingExpense = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Income_Summary"
    ) {
      this.showIncomeSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showIncomeSummary = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_RemoveExistingExpense"
    ) {
      this.removeExistingExpenses = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.removeExistingExpenses = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Resource"
    ) {
      this.resourceSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.resourceSummary = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_RemoveExistingResource"
    ) {
      this.removeExistingResource = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.removeExistingResource = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_EditExistingResource"
    ) {
      this.changeExistingResource = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.changeExistingResource = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_BenefitsFromAnotherStateDetails"
    ) {
      this.showOutOfStateSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showOutOfStateSummary = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Details_Expense"
    ) {
      this.showExpensesSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showExpensesSummary = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_EducationSummary"
    ) {
      this.showEducationSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showEducationSummary = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_EntitledBenefits"
    ) {
      this.showEntitledBenefits = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.showEntitledBenefits = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Pregnancy"
    ) {
      this.pregnancy = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.pregnancy = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Disability"
    ) {
      this.showDisability = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.showDisability = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Blindness"
    ) {
      this.showBlindness = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.showBlindness = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_AbsentParentSummary"
    ) {
      this.absentParent = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.absentParent = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_Conviction"
    ) {
      this.conviction = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.conviction = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_AmIndianAKNative"
    ) {
      this.nativeIndianAmerican = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.nativeIndianAmerican = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_SSIBenefits"
    ) {
      this.ssiBenefits = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.ssiBenefits = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_InHomeAssistance"
    ) {
      this.inHome = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.inHome = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_NotUSCitizen"
    ) {
      this.noCitizen = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.noCitizen = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_HealthCondition"
    ) {
      this.healthCondition = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.healthCondition = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_MedicareCoverageSummary"
    ) {
      this.medicareCoverageSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.medicareCoverageSummary = false;
    }
  }

  loadTemplateContactInfo () {
    this.pageNameValue =
      this.pageToLoadReceived.pageInfo.PageName__c +
      "," +
      this.pageToLoadReceived.memberId;
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Primary_Contact" &&
      this.headOfHousehold
    ) {
      this.hohContact = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.hohContact = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Primary_Address"
    ) {
      this.hohAddress = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.hohAddress = false;
      this.nonPrimaryAddress = true;
    }

    if (!this.hohContact && !this.headOfHousehold && !this.hohAddress) {
      this.nonPrimaryContact = true;
    } else {
      this.nonPrimaryContact = false;
    }
  }

  loadTemplateContactInfoNP () {
    this.pageNameValue =
      this.pageToLoadReceived.pageInfo.PageName__c +
      "," +
      this.pageToLoadReceived.memberId;
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_NonPrimary_Contact"
    ) {
      this.nonPrimaryContact = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.nonPrimaryContact = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_NonPrimary_Address"
    ) {
      this.nonPrimaryAddress = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.nonPrimaryAddress = false;
    }
  }

  loadTemplateHouseholdInfo () {
    this.pageNameValue =
      this.pageToLoadReceived.pageInfo.PageName__c +
      "," +
      this.pageToLoadReceived.memberId;
    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Select_Health"
    ) {
      this.healthSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.healthSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Select_HouseholdCircumstance"
    ) {
      this.householdSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.householdSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Select_Resources_1"
    ) {
      this.resourceSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.resourceSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Select_Resources_2"
    ) {
      this.otherResourceSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.otherResourceSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Select_Income"
    ) {
      this.incomeAndSubsidiesSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.incomeAndSubsidiesSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Select_Expenses"
    ) {
      this.expensesSelection = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.expensesSelection = false;
    }

    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Details_RemoveExistingIncome"
    ) {
      this.removeExistingIncome = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.removeExistingIncome = false;
    }
  }

  loadTemplateHealthCareCoverage () {
    this.pageNameValue =
      this.pageToLoadReceived.pageInfo.PageName__c +
      "," +
      this.pageToLoadReceived.memberId;
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_HealthCare_Select"
    ) {
      this.healthCoverage = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.healthCoverage = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Healthcare_EnrollmentSummary"
    ) {
      this.healthCoverageEnrollSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
    } else {
      this.healthCoverageEnrollSummary = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Healthcare_AccessSummary"
    ) {
      this.healthCoverageAccessSummary = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.healthCoverageAccessSummary = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_Healthcare_PreferredPayment"
    ) {
      this.preferredPaymentMethod = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.preferredPaymentMethod = false;
    }
  }

  loadTemplateRelationships () {
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_RTF_Relationships"
    ) {
      this.relationship = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.relationship = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c ===
      "SSP_APP_RTF_Household Meals"
    ) {
      this.householdMeals = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.householdMeals = false;
    }
    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_RTF_TaxFiling"
    ) {
      this.taxFilingDetails = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.taxFilingDetails = false;
    }
  }

  /**
   * @function : loadTemplateMemberIndividualInfo.
   * @description : loading template for Member Individual Information Flow.
   * */
  loadTemplateMemberIndividualInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_NotUSCitizen"
      ) {
        this.noCitizen = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.noCitizen = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_AlienSponsor"
      ) {
        this.showAlienSponsor = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showAlienSponsor = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_EducationSummary"
      ) {
        this.showEducationSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showEducationSummary = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_AmIndianAKNative"
      ) {
        this.nativeIndianAmerican = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.nativeIndianAmerican = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_AbsentParentSummary"
      ) {
        this.absentParent = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.absentParent = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_FormerFoster"
      ) {
        this.fosterCare = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.fosterCare = false;
      }
            if (
                this.pageToLoadReceived.pageInfo.PageName__c ===
                "SSP_APP_Details_MCOSelection"
            ) {
                this.planSelection = true;
                this.nextEventValue = "";
                this.allowSaveData = "";
            } else {
                this.planSelection = false;
            }
    } catch (error) {
      console.error("Error occured in load Template Individual Info " + error);
    }
  }

  /**
   * @function : loadTemplateMemberHealthInfo.
   * @description : loading template for Member Health Information Flow.
   * */
  loadTemplateMemberHealthInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Pregnancy"
      ) {
        this.pregnancy = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.pregnancy = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Disability"
      ) {
        this.showDisability = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.showDisability = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Blindness"
      ) {
        this.showBlindness = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.showBlindness = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_HealthCondition"
      ) {
        this.healthCondition = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.healthCondition = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_MedicareCoverageSummary"
      ) {
        this.medicareCoverageSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.medicareCoverageSummary = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Healthcare_PreferredPayment"
      ) {
        this.preferredPaymentMethod = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.preferredPaymentMethod = false;
      }
      /**For CD2 - 6.5.2 Caretaker Services. */
      if (this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_MD_CS") {
        this.showCareTakerServices = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showCareTakerServices = false;
      }
      /** */
      /**For CD2 - 6.5.2 Caretaker Services. */
      if (this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_MD_CIS") {
        this.showCIS = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showCIS = false;
      }
      /** */
    } catch (error) {
      console.error("Error occured in load Template Individual Info " + error);
    }
  }

  /**
   * @function : loadTemplateMemberOtherInfo.
   * @description : loading template for Member Other Information Flow.
   * */
  loadTemplateMemberOtherInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_LivingArrangement"
      ) {
        this.livingArrangement = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.livingArrangement = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_InHomeAssistance"
      ) {
        this.inHome = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.inHome = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Conviction"
      ) {
        this.conviction = true;
        this.nextEventValue = "";
        this.allowSaveData = "";

        this.pageName = this.pageToLoadReceived.pageConfig.PageInfo__r.Page_Display_Name_View__c;
      } else {
        this.conviction = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_SSIBenefits"
      ) {
        this.ssiBenefits = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.ssiBenefits = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_EntitledBenefits"
      ) {
        this.showEntitledBenefits = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showEntitledBenefits = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
          "SSP_APP_Details_MedicalSupport" ||
        this.pageToLoadReceived.pageInfo.PageName__c ===
          "SSP_APP_Details_ChildMedicalEnforcement"
      ) {
        this.showMedicalEnforcement = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showMedicalEnforcement = false;
      }
    } catch (error) {
      console.error("Error occured in load Template Other Info " + error);
    }
  }

  /**
   * @function : loadTemplateMemberResourcesInfo.
   * @description : loading template for Member Resources Information Flow.
   * */
  loadTemplateMemberResourcesInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Resource"
      ) {
        this.resourceSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.resourceSummary = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_RemoveExistingResource"
      ) {
        this.removeExistingResource = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.removeExistingResource = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_EditExistingResource"
      ) {
        this.changeExistingResource = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.changeExistingResource = false;
      }
    } catch (error) {
      console.error(
        "Error occured in loadTemplateMemberResourcesInfo " + error
      );
    }
  }

  /**
   * @function : loadTemplateMemberIncomeInfo.
   * @description : loading template for Member Income Information Flow.
   * */
  loadTemplateMemberIncomeInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Income_Summary"
      ) {
        this.showIncomeSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showIncomeSummary = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_RemoveExistingIncome"
      ) {
        this.removeExistingIncome = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.removeExistingIncome = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_EditExistingIncome"
      ) {
        this.changeExistingIncome = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.changeExistingIncome = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_BenefitsFromAnotherStateDetails"
      ) {
        this.showOutOfStateSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showOutOfStateSummary = false;
      }
    } catch (error) {
      console.error(
        "Error occured in loadTemplateMemberResourcesInfo " + error
      );
    }
  }

  /**
   * @function : loadTemplateMemberExpInfo.
   * @description : loading template for Member Expense Information Flow.
   * */
  loadTemplateMemberExpInfo () {
    try {
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_Expense"
      ) {
        this.showExpensesSummary = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.showExpensesSummary = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_RemoveExistingExpense"
      ) {
        this.removeExistingExpenses = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.removeExistingExpenses = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_EditExistingExpense"
      ) {
        this.changeExistingExpense = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.changeExistingExpense = false;
      }
      if (
        this.pageToLoadReceived.pageInfo.PageName__c ===
        "SSP_APP_Details_MedicalExpensesLast3Months"
      ) {
        this.medicalBills = true;
        this.nextEventValue = "";
        this.allowSaveData = "";
      } else {
        this.medicalBills = false;
      }
    } catch (error) {
      console.error(
        "Error occured in loadTemplateMemberResourcesInfo " + error
      );
    }
  }

  loadTemplateSignAndSubmit () {
    if (
      this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_ExpeditedSNAP"
    ) {
      this.expeditedSNAP = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
    } else {
      this.expeditedSNAP = false;
    }
         //  CR Changes - 1258 
        if (
            this.pageToLoadReceived.pageInfo.PageName__c ===
            "SSP_APP_CollateralContact"
        ) {
            this.collateralSNAP = true;
            this.nextEventValue = "";
            this.allowSaveData = "";
            this.handleSignaturePageEvent(false);
        } else {
            this.collateralSNAP = false;
        } 
         // CR Changes - 1258 End

    if (this.pageToLoadReceived.pageInfo.PageName__c === "SSP_APP_Signature") {
      this.signaturePage = true;
      this.nextEventValue = "";
      this.allowSaveData = "";
      this.handleSignaturePageEvent(true);
    } else {
      this.signaturePage = false;
      this.handleSignaturePageEvent(false);
    }
  }

  /**
   * @function : handleReviewRequiredPopUp
   * @description : This method is used to show and hide the modal which have the list of to be reviewed screen.
   */
  handleReviewRequiredPopUp () {
    try {
      this.showReviewScreenPopup = !this.showReviewScreenPopup;
    } catch (error) {
      console.error("Error occured in handleReviewRequiredPopUp " + error);
    }
  }
  /**
   * @function : handleSignaturePageEvent
   * @description : This method is used to trigger an event to check if the screen is signature page.
   *  @param {boolean} flag - Flag.
   */
  handleSignaturePageEvent (flag) {
    const checkSignaturePage = new CustomEvent(
      sspConstants.events.checkSignaturePage,
      {
        bubbles: true,
        composed: true,
        detail: {
          isSignaturePage: flag
        }
      }
    );
    this.dispatchEvent(checkSignaturePage);
  }

  /**
   * @function : scrollToTopPage
   * @description : This method is used to scroll to top of the page.
   */
  scrollToTopPage = () => {
    window.scroll({
      top: 0,
      left: 0,
      behavior: "smooth"
    });
  };
}
