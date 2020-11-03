/*
 * Component Name: sspMyInformationCard.
 * Author: Nikhil Shinde.
 * Description: This component provides search fields, search results and export to excel functionality.
 * Date: 02-06-2020
 */

import { LightningElement, track, api } from "lwc";
import sspMyInformationId from "@salesforce/label/c.SSP_MyInformationId";
import sspMyInformationOrganization from "@salesforce/label/c.SSP_MyInformationOrganization";
import sspMyInformationCoverageArea from "@salesforce/label/c.SSP_MyInformationCoverageArea";
import sspMyInformationPublic from "@salesforce/label/c.SSP_MyInformationPublic";
import sspMyInformationPrivate from "@salesforce/label/c.SSP_MyInformationPrivate";
import sspMyInformationClients from "@salesforce/label/c.SSP_MyInformationClients";
import sspViewMore from "@salesforce/label/c.sspViewMore";
import sspContactInformation from "@salesforce/label/c.SSP_ContactInformation";
import sspOrganizationInformation from "@salesforce/label/c.SSP_MyInformationOrganizationInformation";
import sspViewLess from "@salesforce/label/c.SSP_MyInformationViewLess";

import firstName from "@salesforce/label/c.SSP_FirstName";
import lastName from "@salesforce/label/c.SSP_LastName";
import gender from "@salesforce/label/c.SSP_Gender";
import sspAddressLine1 from "@salesforce/label/c.SSP_SearchAddressLine1";
import sspAddressLine2 from "@salesforce/label/c.AddressLine2";
import sspZipCode from "@salesforce/label/c.SSP_ZipCode";
import sspLastFourOfSSN from "@salesforce/label/c.SSP_SearchLastFourOfSSN";
import dateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspRFIDueDate from "@salesforce/label/c.SSP_SearchRFI_DueDate";
import sspNumberOfRFIDue from "@salesforce/label/c.SSP_SearchNumberOfRFIDue";
import sspRenewalDueDate from "@salesforce/label/c.SSP_SearchRenewalDueDate";
import sspProgramsDueForRenewal from "@salesforce/label/c.SSP_SearchProgramsDueForRenewal";
import sspCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspApplicationNumber from "@salesforce/label/c.SSP_SearchApplicationNumber";
import sspManagedCareOrganization from "@salesforce/label/c.SSP_SearchManagedCareOrganization";
import sspCaseStatus from "@salesforce/label/c.SSP_SearchCaseStatus";
import sspSubmittedDate from "@salesforce/label/c.SSP_SearchSubmittedDate";
import sspLastUpdated from "@salesforce/label/c.SSP_SearchLastUpdated";
import sspMaidNumber from "@salesforce/label/c.SSP_SearchMAID_Number";
import sspAssistedByAssister from "@salesforce/label/c.SSP_SearchAssistedByAssister";
import sspAssistedByAuthorized from "@salesforce/label/c.SSP_SearchAssistedByAuthorized";
import sspClientRole from "@salesforce/label/c.SSP_SearchClientRole";

import sspEmailAddress from "@salesforce/label/c.SSP_MyInformationEmailAddress";
import sspPhoneNumber from "@salesforce/label/c.SSP_MyInformationPhoneNumber";
import sspPhoneType from "@salesforce/label/c.SSP_MyInformationPhoneType";
import sspMailingAddress from "@salesforce/label/c.SSP_MyInformationMailingAddress";
import sspPreferredMethodOfContact from "@salesforce/label/c.SSP_MyInformationPreferredMethodOfContact";
import sspPreferredTimeOfContact from "@salesforce/label/c.SSP_MyInformationPreferredTimeOfContact";

import sspAssisterID from "@salesforce/label/c.SSP_MyInformationAssisterID";
import sspAssisterOrganizationName from "@salesforce/label/c.SSP_MyInformationAssisterOrganizationName";
import sspOrganizationPhysicalAddress from "@salesforce/label/c.SSP_MyInformationOrganizationPhysicalAddress";
import sspOrganizationMailingAddress from "@salesforce/label/c.SSP_MyInformationOrganizationMailingAddress";

import sspName from "@salesforce/label/c.SSP_Name";
import sspSecondaryNumber from "@salesforce/label/c.SSP_MyInformationSecondaryNumber";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspViewMoreAlternateText from "@salesforce/label/c.SSP_MyInformationViewMoreAlternateText";
import sspViewLessAlternateText from "@salesforce/label/c.SSP_MyInformationViewLessAlternateText";
import sspConstants from "c/sspConstants";
import exportToExcelCallout from "@salesforce/apex/SSP_NonCitizenDashboardController.exportToExcel";
import nonCitizenId from "@salesforce/user/Id";
import getNonCitizenUserRoleVisibility from "@salesforce/apex/SSP_NonCitizenDashboardController.getNonCitizenUserRoleVisibility";
import metadataUtility, { getYesNoOptions } from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";
import sspExportClientList from "@salesforce/label/c.SSP_ExportClientList";

export default class SspMyInformationCard extends NavigationMixin(metadataUtility){
    @api access;
    @api nonCitizenUserData = {};
    @api roleVisibility = false;
    @api userRole;
    @api renderingMap;
    @api dashboardSearchResult = {};
    @api exportDataForMyInformation;

    @track showSpinner = false;
    @track isAssisterOrAgencyAdminUser= false;
    @track csvIterativeData = "";
    @track showSearchResults = false;
    @track roleVisibility = {};
    @track showErrorModal = false;
    @track errorMsg = "";
    @track contactList;
    @track userId = nonCitizenId;
    @track isPublic = false;
    @track isPrivate = false;
    @track isExpanded = false;
    @track isMailCenterWorker = false;
    @track isToShowOrganisationBlock = true;
    @track label = {
        sspMyInformationId,
        sspMyInformationOrganization,
        sspMyInformationCoverageArea,
        sspMyInformationPublic,
        sspMyInformationPrivate,
        sspMyInformationClients,
        sspViewMore,
        sspContactInformation,
        sspOrganizationInformation,
        sspViewLess,
        sspEmailAddress,
        sspPhoneNumber,
        sspPhoneType,
        sspMailingAddress,
        sspPreferredMethodOfContact,
        sspPreferredTimeOfContact,
        sspAssisterID,
        sspAssisterOrganizationName,
        sspOrganizationPhysicalAddress,
        sspOrganizationMailingAddress,
        sspName,
        sspSecondaryNumber,
        sspEmail,
        sspViewMoreAlternateText,
        sspViewLessAlternateText,
        firstName,
        lastName,
        gender,
        sspAddressLine1,
        sspAddressLine2,
        sspZipCode,
        sspLastFourOfSSN,
        dateOfBirth,
        sspRFIDueDate,
        sspNumberOfRFIDue,
        sspRenewalDueDate,
        sspProgramsDueForRenewal,
        sspCaseNumber,
        sspApplicationNumber,
        sspManagedCareOrganization,
        sspCaseStatus,
        sspSubmittedDate,
        sspLastUpdated,
        sspMaidNumber,
        sspAssistedByAssister,
        sspAssistedByAuthorized,
        sspClientRole,
        sspExportClientList
    };
    get showViewLessButton () {
        return (
            this.renderingMap.showOrganizationName.isAccessible ||
            this.renderingMap.showContactInformation.isAccessible
        );
    }
    get showContents () {
        let result = false;
        const renderingMap = this.renderingMap;
        Object.keys(renderingMap).forEach(key => {
            result = result || renderingMap[key].isAccessible;
        });
        return result;
    }
    /**
     * @function : connectedCallback
     * @description : Method gets non citizen user info on load.
     **/
    connectedCallback () {
        try {
            if (this.access === true) {
                this.isPrivate = true;
            } else {
                 this.isPublic = true;
            }
            if (
                (this.userRole === sspConstants.userRole.Assister ||
                this.userRole === sspConstants.userRole.Agency_Admin)
            ){
                this.isAssisterOrAgencyAdminUser = true;
            } 
            //Added rendering condition based on selected User Role.
            if (
                this.userRole === sspConstants.userRole.Mail_Center_Worker ||
                this.userRole === sspConstants.userRole.Mail_Center_Supervisor
            ) {
                this.isMailCenterWorker = true;
            }
            //Hide Organisation Information when Individual Auth Rep user Logins
            if (this.userRole === sspConstants.userRole.Individual_Auth_Rep) {
                this.isToShowOrganisationBlock = false;
            }
            this.getNonCitizenUserRoleVisibility();
        } catch (error) {
            console.error("Error in My Information connectedCallback", error);
        }
        
    }

    /**
     * @function : expandInformation
     * @description : Method to expand my information.
     * @param {event} event - Expand event.
     **/
    expandInformation = event => {
        try {
            //Non citizen dashboard load time fix
            // eslint-disable-next-line spellcheck/spell-checker
            this.dispatchEvent(new CustomEvent("triggergetinfo"));
            if (event.keyCode === 13 || event.type === "click") {
                this.isExpanded = true;
            }
                
        } catch (error) {
            console.error("Error in expanding information", error);
        }
        
    };

    /**
     * @function : collapseInformation
     * @description : Method to collapse my information.
     * @param {event} event - Collapse event.
     **/
    collapseInformation = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.isExpanded = false;
            }
            this.isExpanded = false;
            if (event.keyCode === 9 && this.isExpanded == false) {
                this.isExpanded = true;
            }
        } catch (error) {
            console.error("Error in collapsing information", error);
        }
    };


    /**
   * @function - getNonCitizenUserRoleVisibility.
   * @description - Use to search Data.
   */
  getNonCitizenUserRoleVisibility = () => {
    try {
      getNonCitizenUserRoleVisibility({
        userRole: this.userRole
      })
        .then(result => {
          if (
            result.mapResponse.bIsSuccess &&
            !metadataUtility.isUndefinedOrNull(
              result.mapResponse.fieldPermissionsMap
            )
          ) {
            this.roleVisibility = result.mapResponse.fieldPermissionsMap;
            //Start - Added as part of Defect-394044
            if(!metadataUtility.isUndefinedOrNull(this.roleVisibility) && Object.keys(this.roleVisibility).length > 0) {
              const mapFieldPermission = new Map(Object.entries(this.roleVisibility));
              if (!metadataUtility.isUndefinedOrNull(mapFieldPermission.get("SSP_ClientResultsTable"))
                && mapFieldPermission.get("SSP_ClientResultsTable") === true
                && !metadataUtility.isUndefinedOrNull(this.dashboardSearchResult)
                && this.dashboardSearchResult.length > 0) {
                  this.showSearchResults = true;
              } else {
                this.showSearchResults = false;
              }
            }
          }          
        })
        .catch({});
    } catch (error) {
      console.error(
        "Error occurred in getNonCitizenUserRoleVisibility of sspClientSearch page" +
          JSON.stringify(error)
      );
    }
  };

    /**
   * @function : exportToCSV
   * @description	: To export table data into CSV.
   * @param  {object} event - Event onclick or on key down.
   */
  exportToCSV (event) {     
    try {
        if (event.keyCode === 13 || event.type == "click") {
        if(this.nonCitizenUserData.clientCount > 0){
            this.showSpinner=true;
          exportToExcelCallout({
            listClientSearchResult:this.exportDataForMyInformation,
            userId: this.userId,
            screenName: "sspMyInformationCard"
          }).then(result => {
            if (result.mapResponse.bIsSuccess) {
              this.contactList = result.mapResponse.finalList;
              this.generateCSV();
            }
            else {
              this.errorMsg = result.mapResponse.error;
              this.showErrorModal = true;
            }
            this.showSpinner= false;
          });
            }
        }
    } catch (error) {
      console.error("Error in Export to excel", error);
    }
  }
  
  
   generateCSV = () =>  {
    this.loadDataToCSV();
    const a = window.document.createElement("a");
    a.setAttribute("href", this.hrefData);
    a.setAttribute("download", "ClientSearchResult.csv");
    a.click();
  }

  /**
   * @function : loadDataToCSV
   * @description	: To load table data before exporting to CSV.
   */
  loadDataToCSV = () => {
    try {  
      

      const inForLoop = true;
      // Start - To Show CSV Column and data as per roleVisibility
      const columnHeader = [];
      const jsonKeys = [];

      const mapFieldPermission = new Map(Object.entries(this.roleVisibility));
      if (mapFieldPermission.get("SSP_Excel_First_Name")) {
        columnHeader.push(this.label.firstName);
        jsonKeys.push("firstName");
      }
      if (mapFieldPermission.get("SSP_Excel_Last_Name")) {
        columnHeader.push(this.label.lastName);
        jsonKeys.push("lastName");
      }
      if (mapFieldPermission.get("SSP_Excel_Gender")) {
        columnHeader.push(this.label.gender);
        jsonKeys.push("gender");
      }
      if (mapFieldPermission.get("SSP_Excel_Address_Line_1")) {
        columnHeader.push(this.label.sspAddressLine1);
        jsonKeys.push("addressLine1");
      }
      if (mapFieldPermission.get("SSP_Excel_Address_Line_2")) {
        columnHeader.push(this.label.sspAddressLine2);
        jsonKeys.push("addressLine2");
      }
      if (mapFieldPermission.get("SSP_Excel_Zip_Code")) {
        columnHeader.push(this.label.sspZipCode);
        jsonKeys.push("zipcode");
      }
      if (mapFieldPermission.get("SSP_Excel_Phone_Number")) {
        columnHeader.push(this.label.sspPhoneNumber);
        jsonKeys.push("phoneNumber");
      }
      if (mapFieldPermission.get("SSP_Excel_Email_Address")) {
        columnHeader.push(this.label.sspEmailAddress);
        jsonKeys.push("email");
      }
      if (
        mapFieldPermission.get("SSP_Excel_SSN4") ||
        mapFieldPermission.get("SSP_Excel_SSN9")
      ) {
        columnHeader.push(this.label.sspLastFourOfSSN);
        jsonKeys.push("ssn4");
      }

      if (mapFieldPermission.get("SSP_Excel_Date_of_Birth_Age")) {
        columnHeader.push(this.label.dateOfBirth);
        jsonKeys.push("age");
      }

      if (mapFieldPermission.get("SSP_Excel_RFI_Due_Date")) {
        columnHeader.push(this.label.sspRFIDueDate);
        jsonKeys.push("rfiDueDate");
      }
      if (mapFieldPermission.get("SSP_Excel_RFI_Due_Date")) {
        columnHeader.push(this.label.sspNumberOfRFIDue);
        jsonKeys.push("numberOfRFI");
      }
      if (mapFieldPermission.get("SSP_Excel_Renewal_Due_Date")) {
        columnHeader.push(this.label.sspRenewalDueDate);
        jsonKeys.push("renewalDueDate");
      }
      if (mapFieldPermission.get("SSP_Excel_Programs_Due_for_Renew")) {
        columnHeader.push(this.label.sspProgramsDueForRenewal);
        jsonKeys.push("programDueRenewal");
      }
      if (mapFieldPermission.get("SSP_Excel_Case_Number")) {
        columnHeader.push(this.label.sspCaseNumber);
        jsonKeys.push("caseNumber");
      }
      if (mapFieldPermission.get("SSP_Excel_Application_Number")) {
        columnHeader.push(this.label.sspApplicationNumber);
        jsonKeys.push("applicationNumber");
      }
      if (mapFieldPermission.get("SSP_Excel_MCO_Enrollment_Status")) {
        columnHeader.push(this.label.sspManagedCareOrganization);
        jsonKeys.push("mcoEnrollmentStatus");
      }

      if (mapFieldPermission.get("SSP_Excel_Case_Status")) {
        columnHeader.push(this.label.sspCaseStatus);
        jsonKeys.push("caseApplicationStatus");
      }

      if (mapFieldPermission.get("SSP_Excel_Submitted_Date")) {
        columnHeader.push(this.label.sspSubmittedDate);
        jsonKeys.push("submittedDate");
      }
      if (mapFieldPermission.get("SSP_Excel_Last_Updated")) {
        columnHeader.push(this.label.sspLastUpdated);
        jsonKeys.push("lastUpdatedDate");
      }
      if (mapFieldPermission.get("SSP_Excel_MAID_Number")) {
        columnHeader.push(this.label.sspMaidNumber);
        jsonKeys.push("maidCardNumber");
      }
      if (mapFieldPermission.get("SSP_Excel_Assisted_By_Assister")) {
        columnHeader.push(this.label.sspAssistedByAssister);
        jsonKeys.push("assistedByAssister");
      }
      if (mapFieldPermission.get("SSP_Excel_Assisted_By_AuthRep")) {
        columnHeader.push(this.label.sspAssistedByAuthorized);
        jsonKeys.push("assistedByAuthRep");
      }
      if (mapFieldPermission.get("SSP_Excel_Client_Role")) {
        columnHeader.push(this.label.sspClientRole);
        jsonKeys.push("clientRole");
      }
      // End - To Show CSV Column and data as per roleVisibility
      const jsonRecordsData = this.contactList;
      const csvSeparator = ",";
      const newLineCharacter = "\n";
      this.csvIterativeData = "";
      Object.keys(columnHeader).forEach(header => {
        if (inForLoop) {
          this.csvIterativeData +=
            '"' + columnHeader[header] + '"' + csvSeparator;
        }
      });

      if (jsonRecordsData && jsonRecordsData.length > 0) {
        this.csvIterativeData += newLineCharacter;
        for (let i = 0; i < jsonRecordsData.length; i++) {
          let counter = 0;
          Object.keys(jsonKeys).forEach(iteratorObj => {
            if (inForLoop) {
              const dataKey = jsonKeys[iteratorObj];
              if (counter > 0) {
                this.csvIterativeData += csvSeparator;
              }
              if (
                jsonRecordsData[i][dataKey] !== null &&
                jsonRecordsData[i][dataKey] !== undefined
              ) {
                if (dataKey === "ssn4") {
                  this.csvIterativeData +=
                    '"' + jsonRecordsData[i][dataKey].slice(-4) + '"';
                } else {
                  this.csvIterativeData +=
                    '"' + jsonRecordsData[i][dataKey] + '"';
                }
              } else {
                this.csvIterativeData += '""';
              }
              counter++;
            }
          });
          this.csvIterativeData += newLineCharacter;
        }
      }
      this.isExport = false;
      this.hrefData =
        "data:text/csv;charset=utf-8,%EF%BB%BF" +
        encodeURIComponent(this.csvIterativeData);
    } catch (error) {
      console.error("Error in loading data in excel", error);
    }
  };
}