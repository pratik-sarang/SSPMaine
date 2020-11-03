import { api, track } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import utility, { formatLabels } from "c/sspUtility";
//import fetchExistingIncomeDetails from "@salesforce/apex/SSP_IncomeController.fetchExistingIncomeDetails";
import fetchExistingIncomeDetailsImperative from "@salesforce/apex/SSP_IncomeController.fetchExistingIncomeDetailsImperative";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import sspStart from "@salesforce/label/c.SSP_StartButton";
import sspEdit from "@salesforce/label/c.SSP_EditButton";
import sspJobIncomeFromEmployerAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_JobIncomeFromEmployer";
import sspSelfEmploymentIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_SelfEmploymentIncome";
import sspUnpaidIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_UnpaidIncome";
import sspIncomeSummaryInfo1 from "@salesforce/label/c.SSP_IncomeSummaryInfo1";
import sspIncomeSummaryInfo2 from "@salesforce/label/c.SSP_IncomeSummaryInfo2";
import sspIncomeSummarySubText from "@salesforce/label/c.SSP_IncomeSummarySubText";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspCommaUnpaid from "@salesforce/label/c.SSP_CommaUnpaid";
import sspDeleteIncomeHeader from "@salesforce/label/c.SSP_DeleteIncomeHeader";
import sspExistingIncomeInfo1 from "@salesforce/label/c.SSP_ExistingIncomeInfo1";
import sspExistingIncomeInfo2 from "@salesforce/label/c.SSP_ExistingIncomeInfo2";
import sspIncomeSummaryError from "@salesforce/label/c.SSP_IncomeSummary_Error";
import sspAddIncome from "@salesforce/label/c.SSP_AddIncome";
import sspAddIncomeAlt from "@salesforce/label/c.SSP_AddIncome_Alt";
import removeIncomeAlText from "@salesforce/label/c.SSP_RemoveIncomeAlText";
import learnMoreIncomeTitleText from "@salesforce/label/c.SSP_LearnMoreIncomeTitleText";
import removeIncome from "@salesforce/label/c.SSP_RemoveIncome";
import tileEditButtonAltText from "@salesforce/label/c.SSP_TileEditButtonAltText";
import tileStartButtonAltText from "@salesforce/label/c.SSP_TileStartButtonAltText";
import sspTileViewButtonAltText from "@salesforce/label/c.SSP_TileViewButtonAltText";
import year from "@salesforce/label/c.SSP_YearFrequency";
import week from "@salesforce/label/c.SSP_Week";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import hour from "@salesforce/label/c.SSP_Hour";
import hours from "@salesforce/label/c.SSP_Hours";
import sspContractual from "@salesforce/label/c.SSP_Contractual";
import sspOneTime from "@salesforce/label/c.SSP_LumpSum";
import sspIncomeSummary from "@salesforce/label/c.sspIncomeSummary";

import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import apConstants from "c/sspConstants";
import sspDeleteIncomeTitle from "@salesforce/label/c.SSP_DeleteIncomeTitle";
import sspCancelGoToIncomeSummary from "@salesforce/label/c.SSP_CancelGoToIncomeSummary";

const frequencyMap = {
    MO: month,
    BW: biWeek,
    QU: quarter,
    SM: twiceMonth,
    WE: week,
    YR: year,
    DA: dayFrequency,
    HO: hour,
    SP: sspContractual,
    ON: sspOneTime
};

export default class IncomeSummary extends BaseNavFlowPage {
  @api memberId;
  @api sspApplicationId;
  @api memberFirstName;
  @api memberName;
  @api flowStatus;
  @track trueValue = true;
  @track falseValue = false;
  @track incomeList;
  @track hasIncomes = false;
  @track incomeAddList = [];
  @track incomeReceiveList;
  @track incomeNewAdd = false;
  @track isButtonEnabled;
  @track objectInfo = "1";
  @track showIncomeDetails = false;
  @track incomeUpdateId = "";
  @track incomeDetailMode;
  @track incomeName;
  @track nextValue;
  @api sspMemberId;
  @track addNewIncomeMode = false;
  @track updatedIncomeRecord;
  @track sourceIncomeJson;
  @track showIncompleteIncomeError = false;
  @track showSpinner = true;
  @track isLearnMoreModal = false;
  @track modValue;
  @track reference = this;
  @track timeTravelDate ;
  @track isReadOnlyUser = false;  //CD2 2.5 Security Role Matrix.
  @track isReadOnlyDetails = false; //CD2 2.5 Security Role Matrix.
  @track canDeleteIncome = true; //CD2 2.5 Security Role Matrix.
  @track disableIncomeDetails = false; //CD2 2.5 Security Role Matrix.
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track showAddIncomeModal = false;
  label = {
    sspTileViewButtonAltText,
    sspDeleteIncomeTitle,
    sspCancelGoToIncomeSummary,
    sspIncomeSummarySubText,
    sspStart,
    sspEdit,
    sspIncomeSummaryInfo1,
    sspIncomeSummaryInfo2,
    sspLearnMoreLink,
    sspExistingIncomeInfo1,
    sspExistingIncomeInfo2,
    sspAddIncome,
    sspIncomeSummaryError,
    sspLearnMoreModalContent,
        sspAddIncomeAlt,
        removeIncomeAlText,
      learnMoreIncomeTitleText,
      removeIncome,
      tileEditButtonAltText,
        tileStartButtonAltText,
        sspIncomeSummary
  };
  selectedPosition = -1;

  get isIncomeNewAdd () {  //CD2 2.5 Security Role Matrix.
    if (this.isReadOnlyDetails || this.disableIncomeDetails) {
      return false;
    }
    return this.incomeNewAdd;
  }
  get isIncomeNewAddDefault () {
    if (this.isReadOnlyDetails || this.disableIncomeDetails) {
      return true;
    }
    return this.incomeNewAdd;
  }

  // Generic method to create two lists for income existing list and income add list.
  generateIncomeList (obj) {
    let position = 0;
    if (obj) {
      const tempList = obj.data;
      this.incomeNewAdd = true;

      this.sourceIncomeJson = [];
      this.sourceIncomeJson = tempList.incomeRecords;
      // Existing income list.
      this.incomeList = [];
      // List of income added from screen.
      this.incomeAddList = [];
      const incomeTypeMap = tempList.incomeTypes;
     for (let i = 0; i < tempList.incomeRecords.length; i++) {
      const freq = null!=frequencyMap[tempList.incomeRecords[i].IncomePayFrequency__c] && frequencyMap[tempList.incomeRecords[i].IncomePayFrequency__c]!==undefined ?"/"+ frequencyMap[tempList.incomeRecords[i].IncomePayFrequency__c]:"";
      const incomeType = incomeTypeMap[tempList.incomeRecords[i].IncomeTypeCode__c];
        tempList.incomeRecords[i].lineOne = incomeType;
        tempList.incomeRecords[i].lineTwo = null != tempList.incomeRecords[i].TotalGrossAmount__c && tempList.incomeRecords[i].TotalGrossAmount__c !== undefined ?
          "$" + tempList.incomeRecords[i].TotalGrossAmount__c.toFixed(2) + freq : "";

                if (
                    tempList.incomeRecords[i].IncomeSubtypeCode__c !== null &&
                    tempList.incomeRecords[i].IncomeSubtypeCode__c !== undefined
                ) {
                    tempList.incomeRecords[i].lineOne =
                        tempList.incomeSubtypeCodes[
                            tempList.incomeRecords[i].IncomeSubtypeCode__c
                        ];
                }
                if (
                    tempList.incomeRecords[i].IncomeTypeCode__c ===
                    sspJobIncomeFromEmployerAPI
                ) {
                    if (
                        tempList.incomeRecords[i].EmployerName__c !==
                            undefined &&
            tempList.incomeRecords[i].EmployerName__c !== null
          ) {
            tempList.incomeRecords[i].lineOne =
              tempList.incomeRecords[i].EmployerName__c;
          } else {
            tempList.incomeRecords[i].lineOne = incomeType;
          }
        } else if (
          tempList.incomeRecords[i].IncomeTypeCode__c ===
          sspSelfEmploymentIncomeAPI
        ) {
          if(tempList.incomeBusinessTypes[tempList.incomeRecords[i].BusinessTypeCode__c] !== undefined &&
            tempList.incomeBusinessTypes[tempList.incomeRecords[i].BusinessTypeCode__c] !== null) {
          tempList.incomeRecords[i].lineOne =
            tempList.incomeBusinessTypes[
              tempList.incomeRecords[i].BusinessTypeCode__c
            ];
          } else {
            tempList.incomeRecords[i].lineOne = incomeType;
          }
        } else if (
                    tempList.incomeRecords[i].IncomeTypeCode__c ===
                    sspUnpaidIncomeAPI
        ) {
          tempList.incomeRecords[i].lineOne =  tempList.incomeRecords[i].ActivityType__c;
        
          tempList.incomeRecords[i].lineTwo = null!= tempList.incomeRecords[i]
          .IncomePayDetailHoursPerWeek__c &&  tempList.incomeRecords[i]
          .IncomePayDetailHoursPerWeek__c!==undefined ?
                        tempList.incomeRecords[i]
                            .IncomePayDetailHoursPerWeek__c +" "+
                            hours + "/" + week :"";
            tempList.incomeRecords[i].lineThree = sspCommaUnpaid;
        }

        if (tempList.incomeRecords[i].IsExistingData__c) {
            this.incomeList.push(tempList.incomeRecords[i]);
          
        } else {
          if (
            (tempList.incomeRecords[i].IncomeTypeCode__c !==
              sspUnpaidIncomeAPI &&
              (tempList.incomeRecords[i].TotalGrossAmount__c === undefined ||
                tempList.incomeRecords[i].IncomePayFrequency__c ===
                  undefined)) ||
            (tempList.incomeRecords[i].IncomeTypeCode__c ===
              sspUnpaidIncomeAPI &&
                            tempList.incomeRecords[i]
                                .IncomePayDetailHoursPerWeek__c === undefined)
          ) {
            this.incomeNewAdd = false;
            tempList.incomeRecords[i].showStart = true;
          } else {
            tempList.incomeRecords[i].showStart = false;
          }
          tempList.incomeRecords[i].position = position++;
          this.incomeAddList.push(tempList.incomeRecords[i]);
        }
      }
      this.hasIncomes = this.incomeList.length > 0 ? true : false;
      this.showSpinner = false;

     
            this.incomeAddList.forEach(income => {
                income.modalHeaderValue = formatLabels(
                    sspDeleteIncomeHeader,
                    [income.lineOne]
                );
            });
    } else if (obj.error) {
      console.error(obj.error);
    }
  }

  // Apex method wired to get income list whenever member id is changed.
 /* @wire(fetchExistingIncomeDetails, {
    sspMemberId: "$memberId",
    sspApplicationId: null
  })
  callGenerateIncome (objData) {
    this.incomeReceiveList = objData;
    if (this.incomeReceiveList.data) {
      this.incomeReceiveList.data = JSON.parse(this.incomeReceiveList.data);
    }
    this.generateIncomeList({ error: objData.error, data: objData.data });
  }*/

  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    if (value !== undefined && value !== "") {
      this.nextValue = value;
      this.saveData();
    }
  }

  saveData () {
        const tmpWrapperList = this.template.querySelectorAll(
            ".applicationInputs"
        );
    this.showIncompleteIncomeError = false;
    for (let i = 0; i < this.incomeAddList.length; i++) {
      if (this.incomeAddList[i].showStart) {
        this.saveCompleted = false;
        this.showIncompleteIncomeError = true;
      }
    }
    if (this.saveCompleted === undefined) {
      this.saveCompleted = true;
    }
    this.templateInputsValue = tmpWrapperList;
  }

  /**
   * @function handleHideToast
   * @description Raises error toast if required.
   */
  handleHideToast () {
    try {
      this.showIncompleteIncomeError = false;
      this.saveCompleted = undefined;
    } catch (error) {
      console.error("Error in handleHideToast", error);
    }
  }

  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    this.validationFlag = value;
  }

  @api
  get actionReceived () {
    return this.actionValue;
  }
  set actionReceived (value) {
    this.actionValue = value;
    if (value !== undefined && value !== "") {
      const btnClick = value.split(",")[1];
      const loadValue = value.split(",")[2];
      if (btnClick === "next" && loadValue) {
        this.saveData();
      } else {
        this.onRecordSaveSuccess(this.applicationId);
      }
    }
  }

  /**
   * @function : openLearnMoreModal
   * @description	: Method to open learn more modal.
   * @param {event} event - Scans Click functions.
   */
    openLearnMoreModal (event) {
    try {
      if (event.keyCode === 13 || event.type == "click") {
        this.isLearnMoreModal = true;
      }
    } catch (error) {
      console.error(
        apConstants.resourceSelectionConstants.resourceSelectionError
          .openLearnMoreModal + JSON.stringify(error.message)
      );
    }
  }

  /**
   * @function : closeLearnMoreModal
   * @description	: Method to close learn more modal.
   */
  closeLearnMoreModal () {
    try {
      this.isLearnMoreModal = false;
    } catch (error) {
      console.error(
        apConstants.resourceSelectionConstants.resourceSelectionError
          .closeLearnMoreModal + JSON.stringify(error.message)
      );
    }
  }

  // This method is called when the add income button is clicked.
  addIncomeFlow () {
    this.showIncomeDetails = true;
    this.sspMemberId = this.memberId;
    this.addNewIncomeMode = true;
    this.incomeUpdateId = "";
    this.incomeDetailMode = "";
    this.incomeName = "";
        const hideFrameworkEvent = new CustomEvent(
            apConstants.events.hideSection,
            {
      bubbles: true,
      composed: true,
      detail: {
        hideSectionFlag: true
      }
            }
        );
    this.dispatchEvent(hideFrameworkEvent);
  }

  // This method is called when start or edit buttons are clicked.
  initStartFlow (event) {
    if (event.detail === undefined || event.detail === "") {
      return;
    }
    this.selectedPosition = event.target.dataset.position;
    this.showIncomeDetails = true;
    this.incomeUpdateId = event.detail.Id;
    this.incomeDetailMode = event.target.dataset.mode;
    this.incomeName = event.detail.IncomeTypeCode__c;
    this.sspMemberId = event.target.dataset.memberId;
        const hideFrameworkEvent = new CustomEvent(
            apConstants.events.hideSection,
            {
      bubbles: true,
      composed: true,
      detail: {
        hideSectionFlag: true
      }
            }
        );
    this.dispatchEvent(hideFrameworkEvent);
  }

  // This method is called when onComplete event fires from income details.
  completeAddIncome () {
    if(this.memberId!=null && this.memberId!==undefined ){
      this.fetchData();     
    }
   // refreshApex(this.incomeReceiveList);
    this.showIncomeDetails = false;
    this.incomeUpdateId = "";
    this.incomeDetailMode = "";
        const hideFrameworkEvent = new CustomEvent(
            apConstants.events.hideSection,
            {
      bubbles: true,
      composed: true,
      detail: {
        hideSectionFlag: false
      }
            }
        );
    this.dispatchEvent(hideFrameworkEvent);
  }

  // This method is called when the onDelete event is fired from the cards.
  handleRemoveAction (event) {
    this.showSpinner = true;
    deleteRecord(event.target.dataset.itemId)
      .then(() => {
        if(this.memberId!=null && this.memberId!==undefined ){
          this.fetchData();     
        }
        //refreshApex(this.incomeReceiveList);
      })
      .catch(error => {
        console.error(error);
        this.showSpinner = false;
      });
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
   * @function : connectedCallback
   * @description : To retrieve values related to validation framework.
   */

  connectedCallback () {
    try {
      this.showAddIncomeModal = utility.isUndefinedOrNull(this.flowStatus) ? true : (this.flowStatus.charAt(0) === "R") ? true : false;
      this.label.sspIncomeSummarySubText = formatLabels(
        this.label.sspIncomeSummarySubText,
        [this.memberName, this.memberFirstName]
      );
      this.showHelpContentData("SSP_APP_Details_IncomeSummary");
      if(this.memberId!=null && this.memberId!==undefined ){
        this.fetchData();     
      }
    } catch (error) {
      console.error("Error in connectedCallback", error);
    }
  }
  /**
  * @function - renderedCallback
  * @description - This method is used to called whenever there is track variable changing.

  */
  renderedCallback () {
    try {
      const sectionReference = this.template.querySelector(
        ".ssp-learnMoreModal"
      );
      if (sectionReference) {
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        sectionReference.innerHTML = this.modValue.HelpModal__c;
      }
    } catch (error) {
      console.error("Error in renderedCallback", error);
    }
  }

fetchData=() =>{
fetchExistingIncomeDetailsImperative ({
  sspMemberId: this.memberId,
  sspApplicationId: this.sspApplicationId,
  callingComponent: "sspIncomeSummary"
      })
          .then(objData => {
            this.incomeReceiveList = objData;

            /**2.5	Security Role Matrix and Program Access. */
            const parsedData = JSON.parse(this.incomeReceiveList);
            this.constructRenderingAttributes(parsedData);            
            /** */

            if (null!=this.incomeReceiveList) {            
            this.generateIncomeList({ error: objData.error, data: JSON.parse(this.incomeReceiveList) });
            }
          })
          .catch(error => {
              console.error(
                  "Error in fetchMemberIdNotCitizenFunction of Add HouseHold Member page" +
                      JSON.stringify(error)
              );
          });
        }

  /**
  * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
  * @description : This method is used to construct rendering attributes.
  * @param {object} response - Backend response.
  */
  constructRenderingAttributes = response => {
    try {
      if (response != null && response != undefined && response.hasOwnProperty("securityMatrixSummary") && response.hasOwnProperty("securityMatrixDetails")) {
        const { securityMatrixSummary, securityMatrixDetails } = response;
        //code here
        this.isReadOnlyUser =
        !utility.isUndefinedOrNull(securityMatrixSummary) &&
        !utility.isUndefinedOrNull(securityMatrixSummary.screenPermission) &&
        securityMatrixSummary.screenPermission === apConstants.permission.readOnly;

        this.canDeleteIncome =
        !utility.isUndefinedOrNull(securityMatrixSummary) &&
        !utility.isUndefinedOrNull(securityMatrixSummary.canDelete) &&
        !securityMatrixSummary.canDelete ? false : true;

        this.disableIncomeDetails =
        !utility.isUndefinedOrNull(securityMatrixDetails) &&
        !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
        securityMatrixDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

        this.isReadOnlyDetails =
        !utility.isUndefinedOrNull(securityMatrixDetails) &&
        !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
        securityMatrixDetails.screenPermission === apConstants.permission.readOnly;

        if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
            this.isPageAccessible = true;
        }
        else {
            this.isPageAccessible = !(securityMatrixSummary.screenPermission === apConstants.permission.notAccessible);
        }
        if (!this.isPageAccessible) {
            this.showAccessDeniedComponent = true;
        } else {
            this.showAccessDeniedComponent = false;
        }
      }
    }
    catch (error) {
      console.error(
        JSON.stringify(error.message)
      );
    }
  };

}