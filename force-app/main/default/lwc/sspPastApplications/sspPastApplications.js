/**
 * Component Name: sspPastApplications.
 * Author: Abhishek.
 * Description: This a component shows the list of past applications.
 * Date: 6/9/2020.
 */

import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspPastApplications from "@salesforce/label/c.SSP_PastApplications";
import sspCaseHash from "@salesforce/label/c.SSP_CaseTxt";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspDetails from "@salesforce/label/c.SSP_Details";
import sspSearchSubmittedDate from "@salesforce/label/c.SSP_SearchSubmittedDate";
import sspAction from "@salesforce/label/c.SSP_Action";
import sspDownloadApplication from "@salesforce/label/c.SSP_DownloadApplication";
import sspViewAgreementSignature from "@salesforce/label/c.SSP_ViewAgreementSignature";
import sspViewAgreementSignatureAlt from "@salesforce/label/c.SSP_ViewAgreementSignatureAlt";
import sspBackToBenefits from "@salesforce/label/c.SSP_BackToBenefits";
import sspBackToBenefitsAlt from "@salesforce/label/c.SSP_BackToBenefitsAlt";
import sspPastApplicationsPerPage from "@salesforce/label/c.SSP_PastApplicationsPerPage";
import sspPastApplicationsPageSize from "@salesforce/label/c.SSP_PastApplicationsPageSize";
import sspApproved from "@salesforce/label/c.SSP_Approved";
import sspPending from "@salesforce/label/c.SSP_Pending";
import sspDenied from "@salesforce/label/c.SSP_Denied";
import sspDiscontinued from "@salesforce/label/c.SSP_Discontinued";
import fetchPastApplication from "@salesforce/apex/SSP_PastApplicationsController.fetchPastApplications"; 
import sspUtility from "c/sspUtility";

export default class SspPastApplications extends NavigationMixin(LightningElement) {
    @track caseMapping ={
        PE:"Pending",
        AP:"Approved",
        DN:"Denied",
        DC:"Discontinued"
    };
    @track displayCaseMapping ={
        PE: sspPending,
        AP: sspApproved,
        DN: sspDenied,
        DC: sspDiscontinued
    }
    @track showSpinner=false;
    @track columns = [
        { colName: sspDetails, isSorting:false },
        { colName: sspSearchSubmittedDate, isSorting: true },
        { colName: sspAction, isSorting: false }
    ];
    @track mobileColumns = [
        { colName: sspDetails, isSorting: false },
        { colName: sspSearchSubmittedDate, isSorting: true }
    ];
    @track iconUrl = sspIcons + "/sspIcons/ic_sort@2x.png";
    @track currentPageData = [];
    @track perPage = sspPastApplicationsPerPage;
    @track pageSize = sspPastApplicationsPageSize;
    @track selectedDmsId;
    @track tableData = [];
    @track isMobile=false;
    @track selectedCaseNumber;
    @track selectedStatus;
    @track displaySelectedStatus;
    @track selectedReadableCaseNumber ;
    @track caseArray=[];
    @track isTabPressed=false;
    @track mapData;
    @track applicationList = [];
    @track showAccessDenied;
    @track showScreen;
    selectedApplicationNumber;
    selectedDropdownValue;
    assignmentDateOrder = "DESC";
    customLabels={
        sspBackToBenefitsAlt,
        sspBackToBenefits,
        sspViewAgreementSignatureAlt,
        sspViewAgreementSignature,
        sspDownloadApplication,
        sspPastApplications,
        sspCaseHash,
        sspApplicationHash
    };

    get getStatusColor (){
        if (this.selectedStatus === "Discontinued" || this.selectedStatus === "Denied"){
            return "ssp-status-dot ssp-bg_redAlpha";
        }
        else if (this.selectedStatus === "Pending"){
            return "ssp-status-dot ssp-bg_orangeAlpha";
        }
        else{
            return "ssp-status-dot ssp-bg_greenAlpha";
        }
    }

   /**
   * @function - backToBenefits.
   * @description - Method to navigate to benefits screen.
   * @param  {object} event - Fired on key down or click of the link.
   */
    backToBenefits = (event) =>{
        try{
            if (event.type === "click" || (event.type === "keydown" && event.keyCode === 13)){
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Benefits_Page__c"
                    }
                });
            } 
        }
        catch(error){
            console.error("Error occurred in backToBenefits",error);
        }
    }

   /**
   * @function - handleKeyPress.
   * @description - Method to handle key press event for JAWS.
   * @param  {object} event - Fired on key down of dropdown value.
   */
    handleKeyPress = (event) =>{
        try{
            if (event.keyCode === 13) {
                this.toggleDropDown();
            }
            if (event.keyCode === 9) {
                this.isTabPressed = true;
            }
        }
        catch(error){
            console.error("Error occurred in handleKeyPress", error);
        }
    }

    /**
   * @function - handleSelectedValue.
   * @description - Method to select value from drop down.
   * @param  {object} event - Fired on click of dropdown value.
   */
    handleSelectedValue = event => {
        try {
            if (event.type === "mousedown" || (event.type === "keydown" && event.keyCode===13) ){
                event.preventDefault();
                this.selectedStatus = event.currentTarget.dataset.status;
                this.displaySelectedStatus = event.currentTarget.dataset.condition;
                this.selectedCaseNumber = event.currentTarget.dataset.case;
                this.template.querySelector(".ssp-past-applications-pagination").currentPage=1;
                this.tableData = [];
                this.tableData = JSON.parse(JSON.stringify(this.mapData[this.selectedCaseNumber]));
                this.selectedReadableCaseNumber = sspCaseHash + this.selectedCaseNumber.toString().split("").join(" ") + this.displaySelectedStatus;
                this.toggleDropDown();
            }else if (event.keyCode === 40) {
                event.target.nextSibling.focus();
            } else if (event.keyCode === 38) {
                event.target.previousSibling.focus();
            }
        } catch (error) {
            console.error("Error selecting value from drop down", error);
        }
    };

    /**
     * @function : connectedCallback.
     * @description : Method called on initial load.
     */
    connectedCallback () {
        this.selectedCaseNumber = null;
        try {
            this.showSpinner = true;
            this.detectMobileDevice();
            //Fetch past applications data
            fetchPastApplication()
            .then(result => {
                const parsedData = result.mapResponse;  
                if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
                    console.error("failed in loading dashboard" +JSON.stringify(parsedData.ERROR));
                } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    //expecting mapData as a map of case no to list of applications
                    if (parsedData.hasOwnProperty("mapData" )) {
                        this.mapData = JSON.parse(parsedData.mapData);
                        //key is case number and value is list applications
                        Object.keys(this.mapData).forEach((key) => {
                            const caseStatus = this.caseMapping[this.mapData[key][0].caseStatus];
                            if (caseStatus ==="Denied"){
                                this.caseArray.push({ caseNumber: key, caseStatus: caseStatus, className: "ssp-status-dot ssp-bg_redAlpha", caseDisplayStatus: sspDenied, readableCaseNumber: key.toString().split("").join(" ")});
                            }
                            else if (caseStatus === "Discontinued"){
                                this.caseArray.push({ caseNumber: key, caseStatus: caseStatus, className: "ssp-status-dot ssp-bg_redAlpha", caseDisplayStatus: sspDiscontinued, readableCaseNumber: key.toString().split("").join(" ") });
                            }
                            else if (caseStatus === "Pending"){
                                this.caseArray.push({ caseNumber: key, caseStatus: caseStatus, className: "ssp-status-dot ssp-bg_orangeAlpha", caseDisplayStatus: sspPending, readableCaseNumber: key.toString().split("").join(" ") });
                            }
                            else{
                                this.caseArray.push({ caseNumber: key, caseStatus: caseStatus, className: "ssp-status-dot ssp-bg_greenAlpha", caseDisplayStatus: sspApproved , readableCaseNumber: key.toString().split("").join(" ")}); 
                            }
                            const appList = this.mapData[key];
                            if(!sspUtility.isUndefinedOrNull(appList)){
                                if (this.selectedCaseNumber == null || this.selectedCaseNumber == undefined) {
                                    this.tableData = JSON.parse(JSON.stringify(this.mapData[key]));
                                    this.selectedCaseNumber = key;
                                    this.selectedReadableCaseNumber = sspCaseHash + this.selectedCaseNumber.toString().split("").join(" ") + this.displaySelectedStatus;
                                    this.selectedStatus = this.caseMapping[appList[0].caseStatus];
                                    this.displaySelectedStatus = this.displayCaseMapping[appList[0].caseStatus];  
                                }                          
                            }
                        });
                        this.tableData.forEach((currentRow) => {
                            currentRow.readableApplicationNumber = currentRow.applicationNumber.toString().split("").join(" ");
                        });
                    }
                }
                if (parsedData.hasOwnProperty("showScreen") && parsedData.showScreen) {
                    this.showScreen = true;
                }else{
                    this.showAccessDenied = true;
                }                
                this.showSpinner = false;
            })
            .catch(error => {
                console.error("Error : " +JSON.stringify(error));
            });
        }
        catch(error){
            console.error("Error occured in connectedCallback", error); 
        }
    }

    /**
     * @function : detectMobileDevice.
     * @description : Method used to detect mobile device.
     */
    detectMobileDevice = () =>{
        try {
            this.isMobile = navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/BlackBerry/i) || navigator.userAgent.match(/iPhone|iPod/i) || navigator.userAgent.match(/Opera Mini/i) || navigator.userAgent.match(/IEMobile/i);
        }
        catch (error) {
            console.error("Error occured in detectMobileDevice", error);
        }
    }

   /**
   * @function : getCurrentPageData
   * @description	: To get data for current page.
   * @param  {object} event - To get data from pagination component.
   */
   getCurrentPageData = event => {
       try{
           this.currentPageData = event.detail.currentPageData;
       }
       catch (error) {
           console.error("Error occured in getCurrentPageData", error);
       }       
   };

   /**
   * @function : handleDropdown
   * @description	: To get data from selected dropdown.
   * @param  {object} event - To get application number and selected option.
   */
    handleDropdown = (event) =>{
        try{ 
            this.selectedApplicationNumber = event.target.getAttribute("data-app-number");
            this.selectedDmsId = event.target.getAttribute("data-metadata-id");
            this.selectedDropdownValue = event.detail.value;
            if (this.selectedDropdownValue !== "Download") {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Agreement_and_Signature__c"
                    },
                    state: {
                        appId: this.selectedApplicationNumber
                    }
                });
            }
        }
        catch (error) {
            console.error("Error occured in handleDropdown",error);
        }
    }



    /**
     * @function : base64ToBlob
     * @description : Used to open pdf version of application.
     * @param  {object} base64String - Base 64 format data.
     * @param  {object} extension - Extension of the file.
    */
    base64ToBlob (base64String, extension) {
        try {
            let fileBlob;
            const byteCharacters = atob(base64String);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            if (extension === "pdf") {
                fileBlob = new Blob([byteArray], { type: "application/pdf" });
            }
            return fileBlob;
        } catch (error) {
            console.error(
                "Error in base64ToBlob" + JSON.stringify(error.message)
            );
            this.showSpinner = false;
            return null;
        }
    }

   /**
   * @function : handleSorting
   * @description	: To handle Sorting functionality.
   * @param  {object} event - Event to get the column name.
   */
    handleSorting = event => {
        try {
            const colToSort = event.currentTarget.getAttribute("data-name");
            const dataToSort = [...this.tableData];
            this.assignmentDateOrder = this.assignmentDateOrder === "ASC" ? "DESC" : "ASC";
            if (colToSort === "Submitted Date"){
                dataToSort.sort(this.submittedDateToSort);
            }
            this.tableData = dataToSort.length > 0 ? dataToSort : this.tableData;
        }
        catch (error) {
            console.error("Error occured in handleSorting", error);
        }
    }

   /**
   * @function : submittedDateToSort
   * @description	: To handle Assigned To Sorting.
   * @param  {object} a - Comparison first element.
   * @param  {object} b - Comparison second element.
   */
    submittedDateToSort = (a, b) => {
      try {
        const startDateA = this.convertDateToTimestamp(
            a.submittedDate
        );
        const startDateB = this.convertDateToTimestamp(
            b.submittedDate
        );
        if (this.assignmentDateOrder === "ASC") {
            return startDateA < startDateB ? -1 : startDateA > startDateB ? 1 : 0;
        } else {
            return startDateA < startDateB ? 1 : startDateA > startDateB ? -1 : 0;
        }
      }
      catch (error){
          console.error("Error occured in submittedDateToSort",error);
      }
  }

   /**
   * @function : convertDateToTimestamp
   * @description	: To handle date to time stamp conversion.
   * @param  {object} dateToConvert - Date which is to be converted.
   */
    convertDateToTimestamp = dateToConvert => {
        try {
            const date = dateToConvert.split("/");
            const timestamp = new Date(
                date[0] + "-" + date[1] + "-" + date[2]
            ).getTime();
            return timestamp;
        } catch (error) {
            console.error("Error occured in convertDateToTimestamp",error);
        }
    };

   /**
   * @function - closeDropDown.
   * @description - Method to hide the drop down.
   */
  closeDropDown = () => {
     try {
         if(!this.isTabPressed){
             const dropDownIcon = this.template.querySelector(".ssp-menuItemDropDownIcon");
             this.template.querySelector(".ssp-menuItemDropDownContent").classList.remove("ssp-expandDropDown");
             dropDownIcon.classList.remove("ssp-collapseDropDown");
         }
         this.isTabPressed=false;
     } catch (error) {
           console.error("Error hiding drop down", error);
     }
  }

   /**
   * @function - toggleDropDown.
   * @description - Method to show/hide the drop down.
   */
    toggleDropDown = () => {
        try {
            const dropDownIcon = this.template.querySelector(
                ".ssp-menuItemDropDownIcon"
            );
            this.template
                .querySelector(".ssp-menuItemDropDownContent")
                .classList.toggle("ssp-expandDropDown");
            dropDownIcon.classList.toggle("ssp-collapseDropDown");
        } catch (error) {
            console.error("Error toggling drop down", error);
        }
    };
}