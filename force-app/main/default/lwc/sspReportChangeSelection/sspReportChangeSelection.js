/* eslint-disable no-console */
/*
 * Component Name: SspReportChangeSelection.
 * Author: Kyathi,Shivam
 * Description: Container for Report Change Selection screen
 * Date: 1/23/2020.
 */
import { track } from "lwc";
import sspLearnMoreReportChangeTitle from "@salesforce/label/c.SSP_LearnMoreReportChangeTitle";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_ReportChangeLearnMoreContent";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspReportAChange from "@salesforce/label/c.SSP_ReportAChange";
import sspReportChangeToastMessage from "@salesforce/label/c.SSP_ReportChangeToastMessage";
import sspChangesToReportLabel from "@salesforce/label/c.SSP_ChangesToReportLabel";
import sspReportContactNumber from "@salesforce/label/c.SSP_ReportContactNumber";
import sspReportContactNumberText from "@salesforce/label/c.SSP_ReportContactNumberText";
import sspContinueButton from "@salesforce/label/c.SSP_ContinueButton";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspReportResourcesHelpText from "@salesforce/label/c.SSP_ReportResourcesHelpText";
import sspReportExpenseHelpText from "@salesforce/label/c.SSP_ReportExpenseHelpText";
import sspReportArrangementHelpText from "@salesforce/label/c.SSP_ReportArrangementHelpText";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspAtLeastOneValidationMessage from "@salesforce/label/c.SSP_SelectAtleastOneChangeToReport";
import sspUtility from "c/sspUtility";
import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation"; 

import insertCaseApplicationAndAccount from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.insertCaseApplicationAndAccount"; 
import getScreenPermission from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.getScreenPermission"; //2.5 Security Role Matrix and Program Access
import updateRACSelections from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.updateRACSelections";
import dummyRACCallOut from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.dummyRACCallout";
import invokeQualifiedCallOutHelper from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.invokeQualifiedCalloutHelper";
import invokeRACServiceCallOutHelper from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.invokeRACServiceCalloutHelper";
import applicationIndividualForPolling from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.applicationIndividualForPolling";
import deleteCreatedDataOnExit from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.deleteCreatedDataOnExit";
export default class SspReportChangeSelection extends NavigationMixin(
  sspUtility
) {
  @track fieldValidationError = "";
  @track showSpinner = false;
  @track openModel = true;
  @track openLearnMoreModel = false;
  @track trueValue = true;
  @track showResourceTip = false;
  @track showSummary = false;
  @track menuSelectionData;
  @track membersList;
  @track selectedMenuOptions = [];
  @track optionSubHeadingMap;
  @track wiredDataForRefresh;
  @track changeSelectionJSON = {};
  @track RACScreenJSON = {};
  @track finalArray = [];
  @track hasSaveValidationError = false;
  @track mapMetadata = {};
  @track errorMsg;
  @track householdMembers = [];
  @track showMemberDetails = false;
  @track applicationId;
  @track salesforceAppId;
  @track reference = this;
  @track showErrorModal = false;
  @track changeType;
  @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
  @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
  label = {
    sspReportContactNumberText,
    sspReportResourcesHelpText,
    sspReportExpenseHelpText,
    sspReportArrangementHelpText,
    sspLearnMoreReportChangeTitle,
    sspLearnMoreModalContent,
    sspLearnMoreLink,
    sspReportAChange,
    sspReportChangeToastMessage,
    sspChangesToReportLabel,
    sspReportContactNumber,
    sspExitButton,
    sspContinueButton,
    toastErrorText
  };
  @track processedData;
  @track individualId;
  programsApplied;
  contactNumber = "tel:+" + this.label.sspReportContactNumber;

  /**
   * @function : connectedCallback
   * @description : Connected callback - to retrieve values related to validation framework.
   */
  connectedCallback () {
    this.showSpinner = true;
    /**2.5 Security Role Matrix and Program Access. */
    getScreenPermission({})
      .then((response) => {
        if (!sspUtility.isUndefinedOrNull(response) && !sspUtility.isUndefinedOrNull(response.mapResponse) && !sspUtility.isUndefinedOrNull(response.mapResponse.isNotAccessible) && response.mapResponse.isNotAccessible) {
          this.isScreenAccessible = false;
          this.showAccessDeniedComponent = true;
          this.showSpinner = false;
        }
        else {
          this.isScreenAccessible = true;
          const url = new URL(window.location.href);
          this.applicationId = url.searchParams.get("selectedApplication");
          this.salesforceAppId = url.searchParams.get("applicationId");
          this.changeType =
            url.searchParams.get("changeType") === "modifyNew" ? true : false;

          if (!sspUtility.isUndefinedOrNull(url.searchParams.get("individualId"))) {
            this.individualId = url.searchParams.get("individualId");
            if (url.searchParams.get("changeType") !== "modifyNew") {
              this.invokeQualifiedCallOutHelper(
                this.salesforceAppId,
                this.applicationId
              );
            }
            /*this.applicationIndividualForPollingNonCitizen(
             this.salesforceAppId,
             this.individualId
           );*/
          } else {
            if (url.searchParams.get("changeType") !== "modifyNew") {
              this.invokeQualifiedCallOutHelper(
                this.salesforceAppId,
                this.applicationId
              );
            }
            //this.invokeRACServiceCallOutHelper(this.salesforceAppId, this.applicationId);
            this.applicationIndividualForPolling(this.salesforceAppId);
            //this.dummyCallHelperHelper(this.applicationId);
          }
        }

       })
      .catch((error) => {
        console.error(
          "failed in sspReportChangeSelection.getScreenPermission " +
          JSON.stringify(error)
        );
      });
    
  }
  /**
   * @function : insertCaseApplicationAndAccountHelper
   * @description : used to insert Case Application And Account Helper.
   * @param {number} caseNumber - Js caseNumber.
   */
  insertCaseApplicationAndAccountHelper = caseNumber => {
    try {
      if (caseNumber) {
        
        insertCaseApplicationAndAccount({
          caseNumber: caseNumber
        })
          .then(response => {
            //Call Qualified Individual Service
            this.salesforceAppId = response.mapResponse.applicationId;
            
            this.invokeQualifiedCallOutHelper(this.salesforceAppId, caseNumber);
          })
          .catch(error => {
            console.error(
              "error in apex call response- insertCaseApplicationAndAccount. Message-",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in - insertCaseApplicationAndAccountHelper ###" +
          error
      );
    }
  };
  /**
   * @function : invokeQualifiedCallOutHelper
   * @description : used to invoke Qualified Call Out Helper.
   * @param  {id} applicationId - Js applicationId.
   * @param  {number} caseNumber - Js caseNumber.
   */
  invokeQualifiedCallOutHelper = (applicationId, caseNumber) => {
    try {
      if (caseNumber && applicationId) {
        
        invokeQualifiedCallOutHelper({
          applicationId: applicationId,
          caseNumber: caseNumber
        })
          .then(() => {
            //this.invokeRACServiceCallOutHelper(applicationId);
          })
          .catch(error => {
            console.error(
              "error in apex call response- invokeQualifiedCallOutHelper. Message-",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - invokeQualifiedCallOutHelper ###" +
          JSON.stringify(error.message)
      );
    }
  };  
  /**
   * @function : invokeRACServiceCallOutHelper
   * @description : used to invoke RAC Service CallOut Helper.
   * @param  {id} applicationId - Js applicationId.
   * @param  {number} caseNumber - Js caseNumber.
   */
  invokeRACServiceCallOutHelper = (applicationId, caseNumber) => {
    
    try {
      if (applicationId && caseNumber) {
        
        invokeRACServiceCallOutHelper({
          applicationId: applicationId,
          caseNumber: caseNumber
        })
          .then(response => {
            if (
              response.mapResponse.bIsSuccess &&
              response.mapResponse.processedDataList
            ) {
              const returnData = response.mapResponse.processedDataList;

              this.processedData = returnData.filter(
                element =>
                  element.memberInfoList.length > 0 ||
                  element.optionId === "Member_Information" ||
                  element.optionId === "Healthcare_Coverage"
              );

              
              this.showSpinner = false;
            } else if (response.mapResponse.bIsSuccess === false) {
              this.showSpinner = false;
              this.showErrorModal = true;
              this.errorMsg = response.mapResponse.error;
            } else {
              this.showSpinner = false;
            }
            /*else if (!response.mapResponse.bIsSuccess) {
                            this.showSpinner = false;
                            this.showErrorModal = true;
                            this.errorMsg = response.mapResponse.exception;
                        }
                        else if (!response.mapResponse.applicationReady && response.mapResponse.serverFailure) {
                            this.showSpinner = false;
                            this.showErrorModal = true;
                            this.errorMsg = "Server failed!";
                        }*/
          })
          .catch(error => {
            console.error(
              "error in apex call response- invokeRACServiceCallOutHelper. Message-",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - invokeRACServiceCallOutHelper ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : applicationIndividualForPolling
   * @description : used to application Individual For Polling.
   * @param  {id} applicationId - Js applicationId.
   */
  applicationIndividualForPolling = applicationId => {
    if (applicationId) {
      this.pollCounter = 0;
      this.applicationReady().then(data => {
        if (data && data.bIsSuccess && data.mapResponse) {
          this.invokeRACServiceCallOutHelper(
            this.salesforceAppId,
            this.applicationId
          );
        }
        return data;
      });
    }
  };  
  /**
   * @function : applicationReady
   * @description : used to check if applicationReady.
   */
  applicationReady = () => new Promise(this.pollApplication);
  /**
   * @function : pollApplication
   * @description : used to poll application data.
   *  @param  {promise} resolve - Js resolve.
   * @param  {promise} reject - Js reject.
   */
  pollApplication = (resolve, reject) => {   
      applicationIndividualForPolling({
        applicationId: this.salesforceAppId
      }).then(response => {
        if (response.bIsSuccess) {
          if (response.mapResponse && response.mapResponse.applicationReady) {
            const returnValue = response.mapResponse.applicationIndividual;
            
            this.programsApplied = returnValue && returnValue[0].ProgramsApplied__c;
           
            resolve(response);
          } else if (this.pollCounter < 10) {
            this.pollCounter = this.pollCounter + 1;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => this.pollApplication(resolve, reject), 5000);
          } else {
            if (response.mapResponse.statusFailed) {
              this.errorMsg = response.mapResponse.Error;
            }
            this.showErrorModal = true;
            this.showSpinner = false;
            reject(response);
          }
        } else {
          this.showErrorModal = true;
          this.showSpinner = false;
          this.errorMsg = response.mapResponse.Error;
          reject(response);
        }
      });   
  };

  /**
   * @function : displayLearnMoreModelMethod
   * @description : Used to open learn more modal.
   * @param {object} event - Js event.
   */
  displayLearnMoreModelMethod = event => {
    try {
      if (event.keyCode === 13 || event.type == "click") {
        this.openLearnMoreModel = true;
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - displayLearnMoreModelMethod ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : hideLearnMoreModelMethod
   * @description : Used to hide learn more modal.
   */
  hideLearnMoreModelMethod = () => {
    try {
      this.openLearnMoreModel = false;
      this.openLearnMoreModel = "";
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - hideLearnMoreModelMethod ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : continueReporting
   * @description : Used to continue reporting change.
   */
  continueReporting = () => {
    try {
      this.showSpinner = true;
      const object = {};
      let valid = true;
      let atLeastOneSelectedOption = false;
      const selectedOptions = [];
      let signAndSubmitScreens = "";
      signAndSubmitScreens = constants.screenName.SSP_APP_Signature;
      if(this.programsApplied && this.programsApplied.includes(constants.programValues.SN)){
        signAndSubmitScreens = signAndSubmitScreens + "," + constants.screenName.SSP_APP_CollateralContact;
      }
      
      for (const element of this.template.querySelectorAll(
        "c-ssp-rac-selector-checkbox"
      )) {
        if (element.selected) {
          atLeastOneSelectedOption = true;
        }
        if (!element.atLeastOneSelected()) {
          valid = false;
          continue;
        }
        const screensToBeQueued = element.menuItem.screensToBeQueued;
        if (element.selected) {
          atLeastOneSelectedOption = true;
          selectedOptions.push(element.menuItem.RACMenuOption);
          const members = element.members || ["HOH"];
          for (const memberId of members) {
            if (object[memberId]) {
              object[memberId].selectedScreens = object[
                memberId
              ].selectedScreens.concat(screensToBeQueued);
            } else {
              object[memberId] = {
                memberId,
                selectedScreens: [...screensToBeQueued]
              };
            }
          }
        }
      }
      if (object["HOH"]) {
        delete object["HOH"].memberId;
      }
      const finalObject = Object.values(object).map(item => {
        item.selectedScreens = Object.values(
          item.selectedScreens.reduce((obj, screen) => {
            if (obj[screen.flowName]) {
              obj[screen.flowName].screens += "," + screen.screen;
            } else {
              obj[screen.flowName] = {
                flowName: screen.flowName,
                screens: screen.screen
              };
            }
            return obj;
          }, {})
        );
        return item;
      });
      finalObject.push({
        selectedScreens: [
          {
            flowName: "SignAndSubmit",
            screens: signAndSubmitScreens
          }
        ]
      });
      if (valid && atLeastOneSelectedOption) {
        this.updateRACSelectionsHelper(
          JSON.stringify(Object.values(finalObject)), 
          selectedOptions
        );
        this.hasSaveValidationError = false;
        this.fieldValidationError = "";
        if (this.template.querySelector(".ssp-reportChange_container")) {
          this.template
            .querySelector(".ssp-reportChange_container")
            .classList.remove("ssp-checkbox-error");
        }
      } else if (!atLeastOneSelectedOption) {
        this.hasSaveValidationError = true;
        this.fieldValidationError = sspAtLeastOneValidationMessage;
        if (this.template.querySelector(".ssp-reportChange_container")) {
          this.template
            .querySelector(".ssp-reportChange_container")
            .classList.add("ssp-checkbox-error");
        }
        
      }

      this.showSpinner = false;
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - continueReporting ###",
        error
      );
      this.showSpinner = false;
    }
  };

  /**
   * @function : handleCheckboxAction
   * @description : Used to handle Checkbox Action.
   *  @param {object} event - Js event.
   */
  handleCheckboxAction = event => {
    try {
      const value = event.target.value;
      const screenId = event.target.dataset.screenId;
      if (value) {
        const obj = {
          [screenId]: {
            selected: value,
            members: []
          }
        };
        Object.assign(this.changeSelectionJSON, obj);
      } else {
        delete this.changeSelectionJSON[screenId];
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - handleCheckboxAction ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : handleMemberChange
   * @description : Used to  handleMemberChange .
   *  @param {object} event - Js event.
   */
  handleMemberChange = event => {
    try {
      const screenId = event.target.dataset.screenId;
      const members = event.target.value;
      this.changeSelectionJSON[screenId].members = members;
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - handleCheckboxAction ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : dummyCallHelperHelper
   * @description : Used as  dummyCallHelper .
   *  @param {number} caseNumber - Js caseNumber.
   */
  dummyCallHelperHelper = caseNumber => {
    try {
      if (caseNumber) {
        dummyRACCallOut()
          .then(response => {
            if (response.mapResponse.processedData) {
              const returnData = response.mapResponse.processedDataList;
              this.processedData = returnData.filter(
                element =>
                  element.memberInfoList.length > 0 ||
                  (element.optionId === "Healthcare_Coverage" &&
                    element.hasOwnProperty("summary") &&
                    JSON.parse(JSON.stringify(element.summary)).length > 0)
              );
              
            }
          })
          .catch(error => {
            console.error(
              "error in apex call response- dummyRACCallOut. Message-",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - dummyRACCallOut ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : updateRACSelectionsHelper
   * @description : Used as  update RAC Selections Helper .
   *  @param {object} finalObject - Js finalObject.
   *   @param {object} selectedOptions - Js finalObject.
   */
  updateRACSelectionsHelper = (finalObject, selectedOptions) => {
    try {
      if (finalObject) {
        updateRACSelections({
          applicationId: this.salesforceAppId,
          jsonData: finalObject,
          modifyChangeType: this.changeType,
          optionList : selectedOptions
        })
          .then(() => {
            this.navigateToContinueScreen();
          })
          .catch(error => {
            console.error(
              "error in apex call response- updateRACSelections. Message-",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - updateRACSelectionsHelper ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function : navigateToContinueScreen
   * @description : Used as  navigate To Continue Screen.
   */
  navigateToContinueScreen = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "ChangeSummary__c"
        },
        state: {
          applicationId: this.salesforceAppId
        }
      });
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - navigateToContinueScreen ###" +
          JSON.stringify(error.message)
      );
    }
  };
  /**
   * @function :   createACRforNonCitizen
   * @description : Used as  Create Account Contact relationship for non citizen user .   *.
   */
  /*createACRforNonCitizen = () => {
    try {
      if (this.salesforceAppId) {
        createACRforNonCitizen({
          applicationID: this.salesforceAppId
        })
          .then()
          .catch(error => {
            console.error(
              "error in apex call response- createACRforNonCitizen",
              JSON.stringify(error)
            );
          });
      }
    } catch (error) {
      console.error(
        "### Error occurred in sspReportChangeSelection - createACRforNonCitizen ###" +
          JSON.stringify(error.message)
      );
    }
  };*/

  /**
   * @function : exitReporting
   * @description : Used to exit reporting change.
   */
  exitReporting = () => {
    try {
      this.showSpinner = true;
      deleteCreatedDataOnExit({
        applicationId: this.salesforceAppId
      })
        .then(() => {
          this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
              name: constants.navigationUrl.existingDashboard
            }
          });
        })
        .catch(error => {
          console.error(
            "error in apex call response- updateRACSelections. Message-",
            JSON.stringify(error)
          );
        });
    } catch (error) {
      this.showSpinner = false;
      console.error("Error in exitReporting", error);
    }
  };

  /*
   * @function : hideToast
   * @description	: Method to hide Toast
   */
  hideToast = () => {
    try {
      this.hasSaveValidationError = false;
    } catch (error) {
      console.error("Error in HideToast " + JSON.stringify(error.message));
    }
  };
  /*
   * @function : hideFieldValidationError
   * @description	: Method to hide Toast
   */
  hideFieldValidationError = () => {
    try {
      this.fieldValidationError = "";
      this.hasSaveValidationError = false;
      if (this.template.querySelector(".ssp-reportChange_container")) {
        this.template
          .querySelector(".ssp-reportChange_container")
          .classList.remove("ssp-checkbox-error");
      }
    } catch (error) {
      console.error(
        "Error in hideFieldValidationError " + JSON.stringify(error.message)
      );
    }
  };
  /*
   * @function : checkAllSelectedFields
   * @description	: Method to check all selected fields
   */
  checkAllSelectedFields = () => {
    try {
      let isFieldSelected = false;
      const elements = this.template.querySelectorAll(
        "c-ssp-rac-selector-checkbox"
      );
      elements.forEach(function (element) {
        if (element.selected) {
          isFieldSelected = true;
        }
      });
      if (!isFieldSelected) {
        this.fieldValidationError = sspAtLeastOneValidationMessage;
        this.hasSaveValidationError = true;
        if (this.template.querySelector(".ssp-reportChange_container")) {
          this.template
            .querySelector(".ssp-reportChange_container")
            .classList.add("ssp-checkbox-error");
        }
      }
    } catch (error) {
      console.error(
        "Error in checkAllSelectedFields " + JSON.stringify(error.message)
      );
    }
  };

  closeError = () => {
    try {
      this.showErrorModal = false;
      this.showSpinner = false;
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.navigationUrl.existingDashboard
        }
      });
    } catch (error) {
      console.error("Error in closeError:" + JSON.stringify(error.message));
    }
  };
}
