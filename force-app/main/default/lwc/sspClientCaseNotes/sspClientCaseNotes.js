/**
 * Component Name: sspClientCaseNotes.
 * Author: Venkata Ranga Babu.
 * Description: Component for Client Case Notes Screen.
 */
import { LightningElement, track } from "lwc";
import sspConstants from "c/sspConstants";
import sspCase from "@salesforce/label/c.SSP_Case";
import sspClientCaseNotes from "@salesforce/label/c.SSP_ClientCaseNotes";
import sspViewAndManageYourPersonalNotesForThisCase from "@salesforce/label/c.SSP_ViewAndManageYourPersonalNotesForThisCase";
import sspAddNewNote from "@salesforce/label/c.SSP_AddNewNote";
import sspClickToAddNewCaseNote from "@salesforce/label/c.SSP_ClickToAddNewCaseNote";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspDiscard from "@salesforce/label/c.SSP_Discard";
import sspClickToSaveCaseNote from "@salesforce/label/c.SSP_ClickToSaveCaseNote";
import sspClickToDiscardCaseNote from "@salesforce/label/c.SSP_ClickToDiscardCaseNote";
import sspEnterYourNoteHere from "@salesforce/label/c.SSP_EnterYourNoteHere";
import sspViewMore from "@salesforce/label/c.SSP_ViewMore";
import utility from "c/sspUtility";
import userId from "@salesforce/user/Id";
import getScreenPermissionBasedOnRole from "@salesforce/apex/SSP_NonCitizenDashboardService.getScreenPermissionBasedOnRole";
import getCaseDetails from "@salesforce/apex/SSP_ClientCaseNoteCtrl.getCaseDetails";
import getClientCaseNotes from "@salesforce/apex/SSP_ClientCaseNoteCtrl.getClientCaseNotes";
import saveClientCaseNotes from "@salesforce/apex/SSP_ClientCaseNoteCtrl.saveClientCaseNotes";
import sspActive from "@salesforce/label/c.SSP_Active"; //381136
import sspPending from "@salesforce/label/c.SSP_Pending"; //381136
import sspInActive from "@salesforce/label/c.SSP_Inactive"; //381136

export default class SspClientCaseNotes extends LightningElement {
  @track selectedCase = "";
  @track caseStatus = "";
  @track caseDetails = {};
  @track caseList;
  @track notesData = [];
  @track notes = [];
  @track isViewMore = false;
  @track isAddNewNote = false;
  @track newNotes;
  @track isReadOnly = false;
  @track userId = userId;
  @track screenPermissionsMap = {};
  @track userRole;
  @track listClientCaseNotesWrapper;
  @track showSpinner = false;
  @track isSaveButton = true;
  customLabels = {
    sspCase,
    sspClientCaseNotes,
    sspViewAndManageYourPersonalNotesForThisCase,
    sspAddNewNote,
    sspClickToAddNewCaseNote,
    sspSave,
    sspDiscard,
    sspClickToSaveCaseNote,
    sspClickToDiscardCaseNote,
    sspEnterYourNoteHere,
    sspViewMore
  };

  /**
   * @function 		: selectCase.
   * @description 	: method to fetch case related notes.
   * @param {event} event - Gets current value.
   **/
  selectCase = event => {
    try {
      this.showSpinner = true;
      this.toggleDropdown();
      this.selectedCase = event.target.getAttribute("data-id");
            //381136
            const status = this.caseDetails[this.selectedCase];
            if (status === "AP") {
                this.caseStatus = sspActive;
            } else if (status === "PE" || status === "PI") {
                this.caseStatus = sspPending;
            } else if (status === "DN" || status === "DC") {
                this.caseStatus = sspInActive;
            }
  
      /*Server call to get the notes */
      // code here
      getClientCaseNotes({
        caseNumber: parseInt(this.selectedCase, 10)
      }).then(result => {
        this.notesData = result.mapResponse.listClientCaseNotes;
        for (const notes of this.notesData) {
          let header = notes.Comments__c.substring(0, 16);
          header = header.length > 15 ? header + "..." : header;
          notes["noteHeader"] = header;
          notes["LastModifiedDate"] = this.formatDateTime(notes["LastModifiedDate"]);
        }
        this.notes = this.notesData.slice(0, 10);
        this.isViewMore = this.notesData.length > 10 && this.notesData.length !== this.notes.length ? true : false;
        this.showSpinner = false;
      }).catch(error => {
          this.showSpinner = false;
          console.error(error);
      });
    } catch (error) {
      console.error(error);
    }

  };

  /**
   * @function 		: formatDateTime.
   * @description 	: method to format date time.
   * @param {string} dateToFormat - .
   **/
  formatDateTime = (dateToFormat) => {
    try {
      const date = new Date(dateToFormat);
      // format am pm
      let hours = date.getUTCHours();
      let minutes = date.getUTCMinutes();
      const amPm = hours >= 12 ? "PM" : "AM";
      hours = hours % 12;
      hours = hours ? hours : 12; // the hour '0' should be '12'
      hours = hours < 10 ? "0" + hours : hours;
      minutes = minutes < 10 ? "0" + minutes : minutes;
      const strTime = hours + ":" + minutes + " " + amPm;
  
      // format date string
      const dateString = (date.getUTCMonth()+1) +"/"+ date.getUTCDate() + "/" + date.getUTCFullYear().toString().substr(-2) +" "+ strTime;
      return dateString;
    } catch (error) {
      console.error(error);
    }

  }

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
   * @function - viewMoreNotes.
   * @description - To show more notes.
   */
  viewMoreNotes = () => {
    try {
      this.notes = this.notesData.slice(0, this.notes.length + 10);
      this.isViewMore =
        this.notesData.length > 10 && this.notesData.length !== this.notes.length
          ? true
          : false;
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function - addNewNote.
   * @description - To enable user to add new notes.
   */
  addNewNote = () => {
    try {
      this.isAddNewNote = true;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.template
          .querySelector(sspConstants.clientCaseNotes.sspAddNoteTextArea)
          .focus();
        this.template
          .querySelector(sspConstants.clientCaseNotes.sspAddNoteTextArea)
          .scrollIntoView();
      }, 0);
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function - addingNewNote.
   * @description - to get on change of text area.
    * @param {event} event - .
   */
  addingNewNote = (event) => {
    const newNote = event.target.value;
    this.isSaveButton = newNote.length > 0 ? false : true;
  }

  /**
   * @function - saveNewCaseNotes.
   * @description - To save new notes.
   */
  saveNewCaseNotes = () => {
    try {
      this.newNotes = this.template.querySelector(
        sspConstants.clientCaseNotes.sspAddNoteTextArea
      ).value;
      this.template.querySelector(
        sspConstants.clientCaseNotes.sspAddNoteTextArea
      ).value = "";
      this.isAddNewNote = false;
      this.template
        .querySelector(sspConstants.clientCaseNotes.sspClientCaseNotes)
        .scrollIntoView();
  
      this.saveClientCaseNotes(parseInt(this.selectedCase, 10), this.newNotes);
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function - discardNotes.
   * @description - To discard new notes.
   */
  discardNotes = () => {
    try {
      this.template.querySelector(
        sspConstants.clientCaseNotes.sspAddNoteTextArea
      ).value = "";
      this.isAddNewNote = false;
      this.template
        .querySelector(sspConstants.clientCaseNotes.sspClientCaseNotes)
        .scrollIntoView();
    } catch (error) {
      console.error(error);
    }
  };

  connectedCallback () {
    try {
      /*Server call to get the list of cases */
      // code here
      this.showSpinner = true;
      getCaseDetails().then(result => {
        this.caseDetails = result.mapResponse.caseDetails;
        this.caseList = Object.keys(this.caseDetails);
        this.selectedCase = this.caseList[0];
                    //381136
                    const status = this.caseDetails[this.selectedCase];
                    if (status === "AP") {
                        this.caseStatus = sspActive;
                    } else if (status === "PE" || status === "PI") {
                        this.caseStatus = sspPending;
                    } else if (status === "DN" || status === "DC") {
                        this.caseStatus = sspInActive;
                    }
        getClientCaseNotes({
            caseNumber: parseInt(this.selectedCase, 10)
          }).then(resultNotes => {
            this.notesData = resultNotes.mapResponse.listClientCaseNotes;
            for (const notes of this.notesData) {
              let header = notes.Comments__c.substring(0, 16);
              header = header.length > 15 ? header + "..." : header;
              notes["noteHeader"] = header;
              notes["LastModifiedDate"] = this.formatDateTime(notes["LastModifiedDate"]);
            }
            this.notes = this.notesData.slice(0, 10);
            this.isViewMore = this.notesData.length > 10 && this.notesData.length !== this.notes.length ? true : false;
            this.showSpinner = false;
          }).catch(error => {
              this.showSpinner = false;
              console.error(error);
          });
      }).catch(error => {
          this.showSpinner = false;
          console.error(error);
      });

      if (this.userId) {
        this.getScreenPermissionBasedOnRole();
      }
    } catch (error) {
      console.error("Error in connectedCallback", error);
    }
  }
  /**
   * @function : getScreenPermissionBasedOnRole
   * @description : used to get logged in user role.
   **/
  getScreenPermissionBasedOnRole () {
    try {
      getScreenPermissionBasedOnRole({
        userId: this.userId
      })
        .then(result => {
          if (
            result.mapResponse.bIsSuccess &&
            !utility.isUndefinedOrNull(result.mapResponse.screenPermissionsMap)
          ) {
            this.screenPermissionsMap = result.mapResponse.screenPermissionsMap;
            this.userRole = this.screenPermissionsMap.Assister;
            if (this.userRole !== "Editable") {
              this.isReadOnly = true;
            }
          } else if (!result.mapResponse.bIsSuccess) {
            console.error(
              "Error in retrieving data Client Case Notes  " +
                JSON.stringify(this.listClientCaseNotesWrapper.ERROR)
            );
          }
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in getScreenPermissionBasedOnRole on client notes" +
          JSON.stringify(error)
      );
    }
  }
 
  /**
   * @function : saveClientCaseNotes
   * @description : used to Save ClientCaseNotes.
   * @param {number} caseNumber - Current case number.
   * @param {string} newNotes - New notes.
   **/
  saveClientCaseNotes = (caseNumber, newNotes) => {
    try {
      this.showSpinner = true;
      saveClientCaseNotes({
        caseNumber: caseNumber,
        comment: newNotes
      })
        .then(result => {
          if (result.mapResponse.bIsSuccess && result.mapResponse.dmlSuccess) {
            getClientCaseNotes({
                caseNumber: parseInt(this.selectedCase, 10)
              }).then(resultNotes => {
                this.notesData = resultNotes.mapResponse.listClientCaseNotes;
                for (const notes of this.notesData) {
                  let header = notes.Comments__c.substring(0, 16);
                  header = header.length > 15 ? header + "..." : header;
                  notes["noteHeader"] = header;
                  notes["LastModifiedDate"] = this.formatDateTime(notes["LastModifiedDate"]);
                }
                this.notes = this.notesData.slice(0, 10);
                this.isViewMore = this.notesData.length > 10 && this.notesData.length !== this.notes.length ? true : false;
                this.showSpinner = false;
              }).catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
          }
        })
        .catch(error => {
          this.showSpinner = false;
          console.error(
            "Error in saving data Client Case Notes  " +
              JSON.stringify(this.listClientCaseNotesWrapper.ERROR)
          );
        });
    } catch (error) {
      console.error(
        "Error occurred in saveClientCaseNotes on client notes" +
          JSON.stringify(error)
      );
    }
  };
}