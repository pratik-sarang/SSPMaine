/**
 * Component Name: sspCareTakerServices.
 * Author: Venkata Ranga Babu.
 * Description: Component for Agency Management Screen.
 */
import {api, track } from "lwc";
import userId from "@salesforce/user/Id";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspAgencyManagement from "@salesforce/label/c.SSP_AgencyManagement";
import sspAgencyManagementInfo from "@salesforce/label/c.SSP_AgencyManagementInfo";
import sspSearchPlaceholder from "@salesforce/label/c.SSP_SearchPlaceholder";
import sspAssignedTo from "@salesforce/label/c.SSP_AssignedTo";
import sspClientFirstName from "@salesforce/label/c.SSP_ClientFirstName";
import sspClientLastName from "@salesforce/label/c.SSP_ClientLastName";
import sspSearchApplicationNumber from "@salesforce/label/c.SSP_SearchApplicationNumber";
import sspSearchCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspReset from "@salesforce/label/c.SSP_Reset";
import sspResults from "@salesforce/label/c.SSP_Results";
import sspClientsSelected from "@salesforce/label/c.SSP_ClientsSelected";
import sspChangeAssignment from "@salesforce/label/c.SSP_ChangeAssignment";
import sspClientDetails from "@salesforce/label/c.SSP_ClientDetails";
import sspAssignmentStartDate from "@salesforce/label/c.SSP_AssignmentStartDate";
import sspNoResultsFound from "@salesforce/label/c.SSP_AgencyManagementNoResultsFound";
import sspAssignmentHasBeenChangedSuccessfully from "@salesforce/label/c.SSP_AssignmentHasBeenChangedSuccessfully";
import sspStartTypingNameOrClickToSeeAllAssisters from "@salesforce/label/c.SSP_StartTypingNameOrClickToSeeAllAssisters";
import sspSearchBasedOnTheEnteredCriteria from "@salesforce/label/c.SSP_SearchBasedOnTheEnteredCriteria";
import sspResetSearchCriteria from "@salesforce/label/c.SSP_ResetSearchCriteria";
import sspChangeAssignmentsForSelectedClients from "@salesforce/label/c.SSP_ChangeAssignmentsForSelectedClients";
import sspSelectClientFullNameForCaseApplication from "@salesforce/label/c.SSP_SelectClientFullNameForCaseApplication";
import sspStartTyping from "@salesforce/label/c.SSP_StartTypingAssisterName";

import sspSelectAll from "@salesforce/label/c.SSP_SelectAll";
import sspNotSelectAll from "@salesforce/label/c.SSP_UnselectAll";
import sspSelectCurrentPage from "@salesforce/label/c.SSP_SelectCurrentPage";
import sspNotSelectCurrentPage from "@salesforce/label/c.SSP_UnselectCurrentPage";
import sspSelectAllPages from "@salesforce/label/c.SSP_SelectAllPages";
import sspNotSelectAllPages from "@salesforce/label/c.SSP_UnselectAllPages";
import sspPleaseEnterAtLeastOneSearchCriteria from "@salesforce/label/c.SSP_PleaseEnterAtLeastOneSearchCriteria";
import sspChangeAssignmentForSelectedClientFullName from "@salesforce/label/c.SSP_ChangeAssignmentForSelectedClientFullName";
import sspBulkChangeAssignmentForClients from "@salesforce/label/c.SSP_BulkChangeAssignmentForClients";
import sspAssignTo from "@salesforce/label/c.SSP_AssignTo";
import sspAssign from "@salesforce/label/c.SSP_Assign";
import sspAssignClientsToSelectedAssister from "@salesforce/label/c.SSP_AssignClientsToSelectedAssister";
import sspCancelAndGoBackToAgencyManagementScreen from "@salesforce/label/c.SSP_CancelAndGoBackToAgencyManagementScreen";
import sspCancel from "@salesforce/label/c.sspCancel";
import sspAge from "@salesforce/label/c.SSP_Age";
import sspRenewalPageCase from "@salesforce/label/c.SSP_RenewalPageCase";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspLoggingAndErrorContent1 from "@salesforce/label/c.SSP_LoggingAndErrorContent1";
import sspDCBSContact from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import sspMoreThan200RecordsMessage from "@salesforce/label/c.sspMoreThan200RecordsMessage"; //Defect-392952

import getSearchResults from "@salesforce/apex/SSP_AgencyManagementController.getSearchResults";
import getAssisters from "@salesforce/apex/SSP_AgencyManagementController.getAssisters";
import assignNewAssister from "@salesforce/apex/SSP_AgencyManagementController.assignNewAssisters";
import sspConstants from "c/sspConstants";
import sspUtility,{ formatLabels } from "c/sspUtility";

const limit200 = 200; //Defect-392952
export default class SspAgencyManagement extends sspUtility {//LightningElement {
  @track assignedTo = "";
  @track clientFirstName = "";
  @track clientLastName = "";
  @track applicationNumber = "";
  @track caseNumber = "";
  @track tableData = [];
  @track currentPageData = [];
  @track perPage = 10;
  @track pageSize = 6;
  @track isAppNumberDisabled = false;
  @track isCaseNumberDisabled = false;
  @track iconUrl = sspIcons + "/sspIcons/ic_sort@2x.png";
  @track selectedRecords = [];
  @track isSelectAllRecords = false;
  @track isSearch = false;
  @track listOfAssisters;
  @track isSearchErrorMessage = false;
  @track changeAssignmentHeaderLabel = "";
  @track isChangeAssignmentModal = false;
  @track assignTo = "";
  @track showSpinner = false;
  @track showToast = false;
  @track allowSaveValue;
  @track reference = this;
  @track isToShowMoreThan200RecordsMessage = false; //Defect-392952
  @track showMoreThan200RecordsMessageLabel = ""; //Defect-392952
  
  get clientsSelected () {
    return this.selectedRecords.length;
  }
  get clientResultsCount () {
    return this.tableData.length;
  }
  get isSearchResults () {
    return this.tableData.length > 0;
  }
  get isSelectAll () {
    const noOfPages = Math.ceil(this.tableData.length / this.perPage); //Change to Math.ceil for Defect - 387353
    return noOfPages === 1 || noOfPages === 0 ? true : false;
  }
  get isChangeAssignmentDisabled () {
    return this.selectedRecords.length > 0 ? false : true;
  }
  selectedRadio = null;
  clientDetailsOrder = "ASC";
  assignmentDateOrder = "ASC";
  assignedToOrder = "ASC";
  customLabels = {
    sspAgencyManagement,
    sspAgencyManagementInfo,
    sspSearchPlaceholder,
    sspAssignedTo,
    sspClientFirstName,
    sspClientLastName,
    sspSearchApplicationNumber,
    sspSearchCaseNumber,
    sspReset,
    sspResults,
    sspClientsSelected,
    sspChangeAssignment,
    sspClientDetails,
    sspAssignmentStartDate,
    sspNoResultsFound,
    sspAssignmentHasBeenChangedSuccessfully,
    sspStartTypingNameOrClickToSeeAllAssisters,
    sspSearchBasedOnTheEnteredCriteria,
    sspResetSearchCriteria,
    sspChangeAssignmentsForSelectedClients,
    sspSelectClientFullNameForCaseApplication,
    sspSelectAll,
    sspNotSelectAll,
    sspSelectCurrentPage,
    sspNotSelectCurrentPage,
    sspSelectAllPages,
    sspNotSelectAllPages,
    sspStartTyping,
    sspPleaseEnterAtLeastOneSearchCriteria,
    sspChangeAssignmentForSelectedClientFullName,
    sspBulkChangeAssignmentForClients,
    sspAssignTo: sspAssignTo + ":",
    sspAssign,
    sspAssignClientsToSelectedAssister,
    sspCancelAndGoBackToAgencyManagementScreen,
    sspCancel,
    sspAge,
    sspRenewalPageCase,
    sspApplicationHash,
    sspLoggingAndErrorContent1,
    sspDCBSContact,
    sspMoreThan200RecordsMessage //Defect-392952
  };
  @track selectAllDisplayText = this.customLabels.sspSelectAll;
  @track selectCurrentPageDisplayText = this.customLabels.sspSelectCurrentPage;
  @track selectAllPagesDisplayText = this.customLabels.sspSelectAllPages;
  @track columns = [
    { colName: this.customLabels.sspClientDetails },
    { colName: this.customLabels.sspAssignmentStartDate },
    { colName: this.customLabels.sspAssignedTo }
  ];
  @track toastMessage = this.customLabels.sspAssignmentHasBeenChangedSuccessfully;
  @track toastCondition = "positive";
  @track metaDataListParent;
 


 /**
     * @function : allowSave
     * @description	: To get allowSave.
     */
    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
        }
    }

  @api
  get MetadataList () {
      return this.metaDataListParent;
  }
  /**
     * @function : MetadataList
     * @description	: Set property to assign entity mapping values to metaDataListParent.
     * @param {object} value - SF entity mapping values.
     */
    set MetadataList (value) {
      try {
          if (
              !sspUtility.isUndefinedOrNull(value) &&
              Object.keys(value).length > 0
          ) {
              this.metaDataListParent = value;
          }
      } catch (error) {
          console.error(
              "Error in sspAgencyManagement " +
                  JSON.stringify(error)
          );
      }
  }

   /**
     * @function : objWrap
     * @description :this attribute contains validated data which is used to save.
     */
    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        try {
            if (!sspUtility.isUndefinedOrNull(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error(
                "failed in sspAgencyManagement.objWrap " + JSON.stringify(error)
            );
        }
    }
  
  

  /**
   * @function : onSelectTypeAhead
   * @description	: To handle type ahead changes.
   * @param  {object} event - .
   */
  onSelectTypeAhead = event => {
    try {
      this.resetInputError();
      this.assignedTo = event.detail.selectedValue;
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : onChangeTypeAhead
   * @description	: To handle type ahead changes.
   * @param  {object} event - .
   */
  onChangeTypeAhead = event => {
    try {
      this.assignedTo = event.detail.selectedValue;
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : onChangeAssignTo
   * @description	: To handle assign to type ahead changes.
   * @param  {object} event - .
   */
  onChangeAssignTo = event => {
    try {
      this.assignTo = event.detail.selectedValue;
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : onSelectAssignTo
   * @description	: To handle assign to type ahead changes.
   * @param  {object} event - .
   */
  onSelectAssignTo = event => {
    try {
      this.resetInputError();
      this.assignTo = event.detail.selectedValue;
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : handleInputChange
   * @description	: To handle text box changes.
   * @param  {object} event - .
   */
  handleInputChange = event => {
    try {
      const inputValue = event.target.value;
      const lastChar = inputValue.substr(inputValue.length - 1);
      const onlyChar = /^[a-zA-Z]+$/;
      if (!onlyChar.test(lastChar)) {
        // restrict characters other than alphabet characters
        event.target.value = inputValue.slice(0, -1);
      }
      this.resetInputError();
      if (event.target.name === sspConstants.agencyManagement.clientFirstName) {
        this.clientFirstName = event.target.value;
        this.clientFirstName = this.clientFirstName.toUpperCase();
      } else if (
        event.target.name === sspConstants.agencyManagement.clientLastName
      ) {
        this.clientLastName = event.target.value;
        this.clientLastName = this.clientLastName.toUpperCase();
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : handleRadioClick
   * @description	: To handle radio button changes.
   * @param  {object} event - .
   */
  handleRadioClick = event => {
    try {
      if (this.selectedRadio !== event.target.value) {
        // Checking for value change
        this.selectedRadio = event.target.value;
        if (
          this.selectedRadio === sspConstants.agencyManagement.applicationNumber
        ) {
          this.isCaseNumberDisabled = true;
          this.isAppNumberDisabled = false;
        } else {
          this.isAppNumberDisabled = true;
          this.isCaseNumberDisabled = false;
        }
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : handleAppNumberChange
   * @description	: To handle Application Number change.
   * @param  {object} event - .
   */
  handleAppNumberChange = event => {
    try {
      this.resetInputError();
      const appNumber = event.detail.value;
      this.applicationNumber = appNumber;
      if (appNumber !== "" && appNumber !== null) {
        const radioRef = this.template.querySelectorAll(
          sspConstants.agencyManagement.sspMultiLineRadioInput
        );
        radioRef.forEach(element => {
          if (
            element.value === sspConstants.agencyManagement.applicationNumber &&
            !element.checked
          ) {
            element.checked = true;
            element.click();
          }
        });
        this.isCaseNumberDisabled = true;
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : handleCaseNumberChange
   * @description	: To handle Case Number change.
   * @param  {object} event - .
   */
  handleCaseNumberChange = event => {
    try {
      this.resetInputError();
      const caseNumber = event.detail.value;
      this.caseNumber = caseNumber;
      if (caseNumber !== "" && caseNumber !== null) {
        const radioRef = this.template.querySelectorAll(
          sspConstants.agencyManagement.sspMultiLineRadioInput
        );
        radioRef.forEach(element => {
          if (
            element.value === sspConstants.agencyManagement.caseNumber &&
            !element.checked
          ) {
            element.checked = true;
            element.click();
          }
        });
        this.isAppNumberDisabled = true;
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : resetInputError
   * @description	: Remove the validation border of input fields.
   */
  resetInputError = () => {
    try {
      const inputReferences = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );
      inputReferences.forEach(element => {
        element.classList.remove("ssp-input-error");
      });
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : resetSearchCriteria
   * @description	: Rest Search Criteria.
   */
  resetSearchCriteria = () => {
    try {
      this.assignedTo = "";
      this.clientFirstName = "";
      this.clientLastName = "";
      this.applicationNumber = null;
      this.caseNumber = null;
      this.isAppNumberDisabled = false;
      this.isCaseNumberDisabled = false;
      this.isSearchErrorMessage = false;
      this.tableData = [];
      this.isToShowMoreThan200RecordsMessage = false; //Defect-392952
      const radioRef = this.template.querySelectorAll(
        sspConstants.agencyManagement.sspMultiLineRadioInput
      );
      radioRef.forEach(element => {
        element.checked = false;
      });
      this.resetInputError();
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : onSearch
   * @description	: To handle Search.
   */
  onSearch = () => {
    try {
      this.isToShowMoreThan200RecordsMessage = false; //Defect-392952
      const inputReferences = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );
      if (
        (this.assignedTo !== "" && this.assignedTo !== undefined) ||
        this.clientFirstName !== "" ||
        this.clientLastName !== "" ||
        (this.applicationNumber !== "" &&
          this.applicationNumber !== null &&
          this.applicationNumber !== undefined) ||
        (this.caseNumber !== "" &&
          this.caseNumber !== null &&
          this.caseNumber !== undefined)
      ) {
        this.showSpinner = true;
        this.resetInputError();
        this.isSearchErrorMessage = false;
        const applicationNumber = this.isAppNumberDisabled
          ? ""
          : this.applicationNumber;
        const caseNumber = this.isCaseNumberDisabled ? "" : this.caseNumber;
        getSearchResults({
          assignedTo: this.assignedTo,
          firstName: this.clientFirstName,
          lastName: this.clientLastName,
          [sspConstants.agencyManagement
            .sspApplicationNumber]: applicationNumber,
          [sspConstants.agencyManagement.sspCaseNumber]: caseNumber
        })
          .then(result => {
            this.tableData = [];
            this.selectedRecords = [];  // 389691
            let dataTable = [...result]; //Change to let from const for Defect-390559
            dataTable.forEach(data => {
              if (
                data.clientDetails.caseNumber &&
                data.clientDetails.caseNumber !== ""
              ) {
                data["isCaseNumber"] = true;
              } else {
                data["isCaseNumber"] = false;
              }
            });
            dataTable = this.assisterAndClientSortByLastName(dataTable); //Defect-390559
            this.tableData = dataTable.length > 0 ? dataTable : this.tableData; //Defect-390559
            //Start - Added as part of Defect-392952
            if (this.tableData && this.tableData.length >= limit200) {
              this.isToShowMoreThan200RecordsMessage = true;
              this.showMoreThan200RecordsMessageLabel = formatLabels(
                  this.customLabels.sspMoreThan200RecordsMessage,
                  [this.tableData.length]
              );
            } else {
              this.isToShowMoreThan200RecordsMessage = false;
            }
            //End - Added as part of Defect-392952
            this.isSearch = true;
            this.showSpinner = false;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
              this.template.querySelector(".ssp-agency-pagination").currentPage = 1;
            }, 0);
          })
          .catch(error => {
            this.tableData = [];
            this.selectedRecords = []; // 389691
            this.isSearch = true;
            this.showSpinner = false;
            console.error(error);
          });
      } else {
        inputReferences.forEach(element => {
          element.classList.add("ssp-input-error");
        });
        this.isSearchErrorMessage = true;
      }
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : changeAssignment
   * @description	: To change the assister assignment.
   */
  changeAssignment = () => {
    this.isChangeAssignmentModal = true;
    if (this.selectedRecords.length === 1) {
      this.changeAssignmentHeaderLabel = formatLabels(
        this.customLabels.sspChangeAssignmentForSelectedClientFullName,
        [
          this.selectedRecords[0].clientDetails.firstName +
            " " +
            this.selectedRecords[0].clientDetails.lastName
        ]
      );
    } else if (this.selectedRecords.length > 1) {
      this.changeAssignmentHeaderLabel = formatLabels(
        this.customLabels.sspBulkChangeAssignmentForClients,
        [this.selectedRecords.length]
      );
    }
  };

  /**
   * @function : assignAssister
   * @description	: To change the assister assignment.
   */
  assignAssister = () => {
  
    const elem = this.template.querySelectorAll(".ssp-applicationInputs");
  this.checkValidations(elem);

  if (this.allowSaveValue){
    this.showSpinner = true; 
    assignNewAssister({
      listSelectedWrappers: this.selectedRecords,
      newAssignedTo: this.assignTo
    })
      .then(result => {
        if (result.mapResponse.bIsSuccess) {
        this.showToast = true;
        this.toastMessage = this.customLabels.sspAssignmentHasBeenChangedSuccessfully;
        this.toastCondition = "positive";
        this.showSpinner = false;
        /*clear the selected records after assignment*/
        this.assignTo = "";
        const dataTable = [...this.tableData];
        dataTable.forEach(data => {
          data.isSelected = false;
        });
        this.tableData = dataTable;
        this.selectedRecords = [];
        this.closeChangeAssignmentModal();

        this.onSearch();
      } else {
        this.showSpinner = false;
        this.showToast = true;
        this.toastMessage = this.customLabels.sspLoggingAndErrorContent1 + " " + this.customLabels.sspDCBSContact;
        this.toastCondition = "negative";
      }

      })
      .catch(error => {
        this.showSpinner = false;
        console.error(error);
      });
    }
  };

  /*
   * @function    : hideToast
   * @description : Method to hide Toast
   */
  hideToast = () => {
    try {
      this.showToast = false;
    } catch (error) {
      console.error(
        "failed in sspAgencyManagement.hideToast " + JSON.stringify(error)
      );
    }
  };

  /**
   * @function : closeChangeAssignmentModal
   * @description	: To close change assignment modal.
   */
  closeChangeAssignmentModal = () => {
    this.isChangeAssignmentModal = false;
  };

  /**
   * @function : toggleDropdown
   * @description	: To toggle drop down icon.
   */
  toggleDropdown = () => {
    try {
      const dropdownIcon = this.template.querySelector(
        sspConstants.agencyManagement.sspDashboardDropdownIcon
      );
      this.template
        .querySelector(
          sspConstants.agencyManagement.sspDashboardDropdownContent
        )
        .classList.toggle(sspConstants.agencyManagement.sspExpandDropdown);
      dropdownIcon.classList.toggle(
        sspConstants.agencyManagement.sspCollapseDropdown
      );
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function - closeDropDown.
   * @description - Method to hide the drop down.
   */
  closeDropDown = () => {
    try {
      const dropDownIcon = this.template.querySelector(
        sspConstants.agencyManagement.sspDashboardDropdownIcon
      );
      this.template
        .querySelector(
          sspConstants.agencyManagement.sspDashboardDropdownContent
        )
        .classList.remove(sspConstants.agencyManagement.sspExpandDropdown);
      dropDownIcon.classList.remove(
        sspConstants.agencyManagement.sspCollapseDropdown
      );
    } catch (error) {
      console.error("Error hiding drop down", error);
    }
  };
  /**
   * @function : onSelectAll
   * @description	: To handle Select All Records functionality.
   * @param  {object} event - .
   */
  onSelectAllPages = event => {
    try {
      event.preventDefault();
      this.toggleDropdown();
      const val = event.target.getAttribute("data-id");
      if (val === this.customLabels.sspSelectAllPages) {
        this.isSelectAllRecords = true;
        this.selectAllPagesDisplayText = this.customLabels.sspNotSelectAllPages;
        const dataTable = [...this.tableData];
        dataTable.forEach(data => {
          data.isSelected = true;
        });
        this.tableData = dataTable;
        this.selectedRecords = [];
        this.selectedRecords = JSON.parse(JSON.stringify(dataTable));
      } else {
        this.isSelectAllRecords = false;
        this.selectAllPagesDisplayText = this.customLabels.sspSelectAllPages;
        const dataTable = [...this.tableData];
        dataTable.forEach(data => {
          data.isSelected = false;
        });
        this.tableData = dataTable;
        this.selectedRecords = [];
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : onSelectAll
   * @description	: To handle Select All Records functionality.
   * @param  {object} event - .
   */
  onSelectAll = event => {
    try {
      event.preventDefault();
      this.toggleDropdown();
      const val = event.target.getAttribute("data-id");
      if (val === this.customLabels.sspSelectAll) {
        this.isSelectAllRecords = true;
        this.selectAllDisplayText = this.customLabels.sspNotSelectAll;
        const dataTable = [...this.tableData];
        dataTable.forEach(data => {
          data.isSelected = true;
        });
        this.tableData = dataTable;
        this.selectedRecords = [];
        this.selectedRecords = JSON.parse(JSON.stringify(dataTable));
      } else {
        this.isSelectAllRecords = false;
        this.selectAllDisplayText = this.customLabels.sspSelectAll;
        const dataTable = [...this.tableData];
        dataTable.forEach(data => {
          data.isSelected = false;
        });
        this.tableData = dataTable;
        this.selectedRecords = [];
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : onSelectCurrentPage
   * @description	: To handle Select Current Page Records functionality.
   * @param  {object} event - .
   */
  onSelectCurrentPage = event => {
    try {
      event.preventDefault();
      this.toggleDropdown();
      const val = event.target.getAttribute("data-id");
      if (val === this.customLabels.sspSelectCurrentPage) {
        this.isSelectAllRecords = true;
        this.selectCurrentPageDisplayText = this.customLabels.sspNotSelectCurrentPage;
        const dataTable = [...this.tableData];
        const selectedRecords = [];
        for (const currentData of this.currentPageData) {
          for (const data of this.tableData) {
            if (data.recordId === currentData.recordId) {
              data.isSelected = true;
              selectedRecords.push(data);
              break;
            }
          }
        }
        this.tableData = dataTable;
        this.selectedRecords = [];
        this.selectedRecords = selectedRecords;
      } else {
        this.isSelectAllRecords = false;
        this.selectCurrentPageDisplayText = this.customLabels.sspSelectCurrentPage;
        const dataTable = [...this.tableData];
        for (const currentData of this.currentPageData) {
          for (const data of this.tableData) {
            if (data.recordId === currentData.recordId) {
              data.isSelected = false;
              break;
            }
          }
        }
        this.tableData = dataTable;
        this.selectedRecords = [];
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : handleCheck
   * @description	: To handle Record Selection.
   * @param  {object} event - .
   */
  handleCheck = event => {
    try {
      const index = parseInt(event.target.getAttribute("data-id"), 10);
      if (event.target.checked) {
        this.currentPageData[index].isSelected = true;
        const dataTable = [...this.tableData];
        for (const data of dataTable) {
          if (data.recordId === this.currentPageData[index].recordId) {
            data.isSelected = true;
            break;
          }
        }
        this.tableData = dataTable;
        this.selectedRecords.push(this.currentPageData[index]);
      } else {
        this.isSelectAllRecords = false;
        this.currentPageData[index].isSelected = true;
        const dataTable = [...this.tableData];
        for (const data of dataTable) {
          if (data.recordId === this.currentPageData[index].recordId) {
            data.isSelected = false;
            break;
          }
        }
        this.tableData = dataTable;
        this.selectedRecords = this.selectedRecords.filter(
          obj => obj.recordId !== this.currentPageData[index].recordId
        );
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : convertDateToTimestamp
   * @description	: To handle date to time stamp conversion.
   * @param  {object} dateToConvert - .
   */
  convertDateToTimestamp = dateToConvert => {
    try {
      const date = dateToConvert.split("/");
      const timestamp = new Date(
        date[0] + "-" + date[1] + "-" + date[2]
      ).getTime();
      return timestamp;
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : clientDetailsSort
   * @description	: To handle Client Details Sorting.
   * @param  {object} a - .
   * @param  {object} b - .
   */
  clientDetailsSort = (a, b) => {
    try {
      const lastNameA = a.clientDetails.lastName.toUpperCase();
      const lastNameB = b.clientDetails.lastName.toUpperCase();
      if (this.clientDetailsOrder === "ASC") {
        return lastNameA < lastNameB ? -1 : lastNameA > lastNameB ? 1 : 0;
      } else {
        return lastNameA < lastNameB ? 1 : lastNameA > lastNameB ? -1 : 0;
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : assignmentDateSort
   * @description	: To handle Assignment Start Date Sorting.
   * @param  {object} a - .
   * @param  {object} b - .
   */
  assignmentDateSort = (a, b) => {
    try {
      const startDateA = this.convertDateToTimestamp(
        a.assignedTo.assignmentStartDate
      );
      const startDateB = this.convertDateToTimestamp(
        b.assignedTo.assignmentStartDate
      );
      if (this.assignmentDateOrder === "ASC") {
        return startDateA < startDateB ? -1 : startDateA > startDateB ? 1 : 0;
      } else {
        return startDateA < startDateB ? 1 : startDateA > startDateB ? -1 : 0;
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : assignedToSort
   * @description	: To handle Assigned To Sorting.
   * @param  {object} a - .
   * @param  {object} b - .
   */
  assignedToSort = (a, b) => {
    try {
      const assignedToA = a.assignedTo.lastName.toUpperCase();
      const assignedToB = b.assignedTo.lastName.toUpperCase();
      if (this.assignedToOrder === "ASC") {
        return assignedToA < assignedToB
          ? -1
          : assignedToA > assignedToB
          ? 1
          : 0;
      } else {
        return assignedToA < assignedToB
          ? 1
          : assignedToA > assignedToB
          ? -1
          : 0;
      }
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : handleSorting
   * @description	: To handle Sorting functionality.
   * @param  {object} event - .
   */
  handleSorting = event => {
    try {
      const colToSort = event.target.getAttribute("data-name");
      const dataToSort = [...this.tableData];
      // const dataToSort = [...this.currentPageData];
      if (colToSort === sspConstants.agencyManagement.clientDetails) {
        this.clientDetailsOrder =
          this.clientDetailsOrder === "ASC" ? "DESC" : "ASC";
        dataToSort.sort(this.clientDetailsSort);
      } else if (
        colToSort === sspConstants.agencyManagement.assignmentStartDate
      ) {
        this.assignmentDateOrder =
          this.assignmentDateOrder === "ASC" ? "DESC" : "ASC";
        dataToSort.sort(this.assignmentDateSort);
      } else if (colToSort === sspConstants.agencyManagement.assignedTo) {
        this.assignedToOrder = this.assignedToOrder === "ASC" ? "DESC" : "ASC";
        dataToSort.sort(this.assignedToSort);
      }
      this.tableData = dataToSort.length > 0 ? dataToSort : this.tableData;
    } catch (error) {
      console.error(error);
    }
  };
  /**
   * @function : getCurrentPageData
   * @description	: To get data for current page.
   * @param  {object} event - .
   */
  getCurrentPageData = event => {
    this.currentPageData = event.detail.currentPageData;
  };

  connectedCallback () {
    getAssisters({
      userId: userId
    })
      .then(result => {
        const listAssisters = result;
        const listOfAssisters = listAssisters.map(item => ({
          label: item.FirstName + " " + item.LastName,
          value: item.Id
        }));
        this.listOfAssisters = listOfAssisters;
      })
      .catch(error => {
        console.error(error);
      });

      const fieldEntityNameList = [];
      fieldEntityNameList.push("FirstName__c,SSP_Member__c");

      this.getMetadataDetails(
        fieldEntityNameList,
        null,
        "SSP_Request_Fraud"
    );
  }

  //Start - Added as part of Defect-390559
  /**
   * @function : assisterAndClientSortByLastName
   * @description	: First Sort Assister by lastName & then Sort by Client lastName.
   * @param  {object} data - List of Wrapper Data.
   */
  assisterAndClientSortByLastName = (data) => {
    try {
      if (data !== undefined && data.length > 0) {
        data.sort(function (firstRecord, secondRecord) {
          //Assister LastName Sort
          if (
              firstRecord.assignedTo.lastName !== undefined &&
              secondRecord.assignedTo.lastName !== undefined &&
              firstRecord.assignedTo.lastName !== "" &&
              secondRecord.assignedTo.lastName !== ""
          ) {
              const assister1LastName = firstRecord.assignedTo.lastName.toUpperCase();
              const assister2LastName = secondRecord.assignedTo.lastName.toUpperCase();
              if (assister1LastName > assister2LastName) {return 1;}
              if (assister1LastName < assister2LastName) {return -1;}
          }
          //Client LastName Sort
          if (
              firstRecord.clientDetails.lastName !== undefined &&
              secondRecord.clientDetails.lastName !== undefined &&
              firstRecord.clientDetails.lastName !== "" &&
              secondRecord.clientDetails.lastName !== ""
          ) {
              const client1LastName = firstRecord.clientDetails.lastName.toUpperCase();
              const client2LastName = secondRecord.clientDetails.lastName.toUpperCase();
              if (client1LastName > client2LastName) {return 1;}
              if (client1LastName < client2LastName) {return -1;}
          }
        });
      }
    } catch (error) {
        console.error(error);
    }
    return data;
  }
  //End - Added as part of Defect-390559
}