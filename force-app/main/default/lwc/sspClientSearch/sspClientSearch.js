/*
 * Component Name: sspClientSearch.
 * Author:  Shekhar Chandra,Nikhil Shinde.
 * Description: This component provides search fields, search results and export to excel functionality.
 * Date: 02-06-2020
 */

import { track, api } from "lwc";
import firstName from "@salesforce/label/c.SSP_FirstName";
import lastName from "@salesforce/label/c.SSP_LastName";
import sspAddressLine1 from "@salesforce/label/c.SSP_SearchAddressLine1";
import sspSocialSecurityNumber9Digit from "@salesforce/label/c.SSP_SearchSocialSecurityNumber9Digit";
import sspSocialSecurityNumber4Digit from "@salesforce/label/c.SSP_SearchSocialSecurityNumber4Digit";
import dateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspApplicationNumber from "@salesforce/label/c.SSP_SearchApplicationNumber";
import sspEmailAddress from "@salesforce/label/c.SSP_MyInformationEmailAddress";
import sspPhoneNumber from "@salesforce/label/c.SSP_MyInformationPhoneNumber";
import sspMCOEnrollmentStatus from "@salesforce/label/c.SSP_SearchMCO_EnrollmentStatus";
import sspMCOEnrollmentStatusAlternateText from "@salesforce/label/c.SSP_SearchMCO_EnrollmentStatusAlternateText";
import sspRenewalDue from "@salesforce/label/c.SSP_SearchRenewalDue";
import sspRenewalDueAlternateText from "@salesforce/label/c.SSP_SearchRenewalDueAlternateText";
import sspRFIDue from "@salesforce/label/c.SSP_SearchRFI_Due";
import sspRFIDueAlternateText from "@salesforce/label/c.SSP_SearchRFI_DueAlternateText";
import sspUnsubmittedApplication from "@salesforce/label/c.SSP_SearchUnsubmittedApplication";
import sspCaseStatus from "@salesforce/label/c.SSP_SearchCaseStatus";
import sspCaseStatusAlternateText from "@salesforce/label/c.SSP_SearchCaseStatusAlternateText";
import sspMaidNumber from "@salesforce/label/c.SSP_SearchMAID_Number";
import gender from "@salesforce/label/c.SSP_Gender";
import sspGenderAlternateText from "@salesforce/label/c.SSP_SearchGenderAlternateText";
import sspSubmittedDate from "@salesforce/label/c.SSP_SearchSubmittedDate";
import sspSubmittedDateAlternateText from "@salesforce/label/c.SSP_SearchSubmittedDateAlternateText";
import sspCounty from "@salesforce/label/c.SSP_County";
import sspCountyAlternateText from "@salesforce/label/c.SSP_SearchCountyAlternateText";
import sspAssistedBy from "@salesforce/label/c.SSP_SearchAssistedBy";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import sspResults from "@salesforce/label/c.SSP_Results";
import sspAtLeastTwoField from "@salesforce/label/c.SSP_SearchAtLeastTwoValidation";
import sspClientFound from "@salesforce/label/c.SSP_SearchClientFound";
import sspOneClientFound from "@salesforce/label/c.SSP_OneClientFound";
import sspClients from "@salesforce/label/c.SSP_MyInformationClients";
import sspAge from "@salesforce/label/c.SSP_Age";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspRenewalPageCase from "@salesforce/label/c.SSP_RenewalPageCase";
import sspAddressLine2 from "@salesforce/label/c.AddressLine2";
import sspZipCode from "@salesforce/label/c.SSP_ZipCode";
import sspClientRole from "@salesforce/label/c.SSP_SearchClientRole";
import sspAssistedByAssister from "@salesforce/label/c.SSP_SearchAssistedByAssister";
import sspAssistedByAuthorized from "@salesforce/label/c.SSP_SearchAssistedByAuthorized";
import sspRenewalDueDate from "@salesforce/label/c.SSP_SearchRenewalDueDate";
import sspRFIDueDate from "@salesforce/label/c.SSP_SearchRFI_DueDate";
import sspNumberOfRFIDue from "@salesforce/label/c.SSP_SearchNumberOfRFIDue";
import sspProgramsDueForRenewal from "@salesforce/label/c.SSP_SearchProgramsDueForRenewal";
import sspLastUpdated from "@salesforce/label/c.SSP_SearchLastUpdated";
import sspClientDetails from "@salesforce/label/c.SSP_ClientDetails";
import sspManagedCareOrganization from "@salesforce/label/c.SSP_SearchManagedCareOrganization";
import sspLastFourOfSSN from "@salesforce/label/c.SSP_SearchLastFourOfSSN";
import sspClientDashboard from "@salesforce/label/c.SSP_SearchClientDashboard";
import sspAssisterName from "@salesforce/label/c.SSP_SearchAssisterName";
import sspApplicationDate from "@salesforce/label/c.SSP_SearchApplicationDate";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText"; //#379953
import sspSearchButtonText from "@salesforce/label/c.SSP_SearchButtonText";
import sspSearchButtonAlternateText from "@salesforce/label/c.SSP_SearchButtonAlternateText";
import sspSearchResetButtonText from "@salesforce/label/c.SSP_SearchResetButtonText";
import sspSearchResetButtonAlternateText from "@salesforce/label/c.SSP_SearchResetButtonAlternateText";
import sspSearchExportToExcel from "@salesforce/label/c.SSP_SearchExportToExcel";
import sspSearchExportToExcelAlternateText from "@salesforce/label/c.SSP_SearchExportToExcelAlternateText";
import sspSearchShowAdvanced from "@salesforce/label/c.SSP_SearchShowAdvanced";
import sspSearchHideAdvanced from "@salesforce/label/c.SSP_SearchHideAdvanced";
import explicitText from "@salesforce/label/c.SSP_ExplicitText";
import sspSSNValidationMessage from "@salesforce/label/c.SSP_SSNValidation_Message";
import getPicklistForSearch from "@salesforce/apex/SSP_NonCitizenDashboardController.getPicklistForSearch";
import searchNonCitizenClients from "@salesforce/apex/SSP_NonCitizenDashboardController.searchNonCitizenClients";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspConstants from "c/sspConstants";
import getContactFromWrapper from "@salesforce/apex/SSP_NonCitizenDashboardController.getContactFromWrapper";
import nonCitizenId from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";

import getNonCitizenUserRoleVisibility from "@salesforce/apex/SSP_NonCitizenDashboardController.getNonCitizenUserRoleVisibility";
import exportToExcelCallout from "@salesforce/apex/SSP_NonCitizenDashboardController.exportToExcel";

import metadataUtility, { getYesNoOptions } from "c/sspUtility"; 
const submittedDefaultValue = "LR";
export default class SspClientSearch extends NavigationMixin(metadataUtility) {
    @api userRole;
    @api dashboardSearchResult = {};

    @track showSpinner = false;
    @track showSearchResults = false;
    @track assignedTo = "";
    @track assignedToLabel = "";
    @track clientFirstName = "";
    @track clientLastName = "";
    @track currentPageData = [];
    @track perPage = 10;
    @track userId = nonCitizenId;
    @track pageSize = 6;
    @track isAppNumberDisabled = false;
    @track isCaseNumberDisabled = false;
    @track iconUrl = sspIcons + "/sspIcons/ic_sort@2x.png";
    @track selectedRecords = [];
    @track isSelectAllRecords = false;
    @track isSearch = false;
    @track isSearchErrorMessage = false;
    @track noResultFound = false;

    @track selectAllPagesDisplayText = "Select All Pages";

    @track modifiedColumn = [];
    @track searchResultDataNC;

    @track tableData;
  
    @track trueValue = false; //#379953
    @track hasSaveValidationError = false; //#379953
  @track showErrorModal = false;
  @track errorMsg = "";
    @track label = {
        toastErrorText, //#379953
        firstName,
        lastName,
        sspAddressLine1,
        sspSocialSecurityNumber9Digit,
        sspSocialSecurityNumber4Digit,
        dateOfBirth,
        sspCaseNumber,
        sspApplicationNumber,
        sspEmailAddress,
        sspPhoneNumber,
        sspMCOEnrollmentStatus,
        sspMCOEnrollmentStatusAlternateText,
        sspRenewalDue,
        sspRenewalDueAlternateText,
        sspRFIDue,
        sspRFIDueAlternateText,
        sspUnsubmittedApplication,
        sspCaseStatus,
        sspCaseStatusAlternateText,
        sspMaidNumber,
        gender,
        sspGenderAlternateText,
        sspSubmittedDate,
        sspSubmittedDateAlternateText,
        sspCounty,
        sspCountyAlternateText,
        sspAssistedBy,
        sspPlaceholderPhoneNumber,
        sspSearchButtonText,
        sspSearchButtonAlternateText,
        sspSearchResetButtonText,
        sspSearchResetButtonAlternateText,
        sspSearchExportToExcel,
        sspSearchExportToExcelAlternateText,
        sspSearchShowAdvanced,
        sspSearchHideAdvanced,
        sspNoResultsFound,
        sspResults,
        sspAtLeastTwoField,
        explicitText,
        sspClientFound,
        sspClients,
        sspAge,
        sspApplicationHash,
        sspRenewalPageCase,
        sspAddressLine2,
        sspZipCode,
        sspClientRole,
        sspAssistedByAssister,
        sspAssistedByAuthorized,
        sspRenewalDueDate,
        sspRFIDueDate,
        sspNumberOfRFIDue,
        sspProgramsDueForRenewal,
        sspLastUpdated,
        sspClientDetails,
        sspManagedCareOrganization,
        sspLastFourOfSSN,
        sspClientDashboard,
        sspAssisterName,
        sspApplicationDate,
        sspOneClientFound
    };
    @track columns = [
        { colName: this.label.sspClientDetails },
        { colName: this.label.sspCaseStatus },
        { colName: this.label.sspSubmittedDate },
        { colName: this.label.sspLastUpdated },
        { colName: this.label.sspAssistedBy }
    ];
    @track is9Digit = true;
    @track is4Digit = false;
    @track isDisabled = false;
    @track showAdvanced = false;

    @track cFirstName = "";
    @track cLastName = "";
    @track caseNumber = "";
    @track applicationNumber = "";
    @track socialSecurityDigit9 = "";
    @track socialSecurityDigit4 = "";
    @track dateOfBirth = "";
    @track phoneNumber = "";
    @track email = "";
    @track selectedRadioButton = null;
    @track yesNoPicklist = getYesNoOptions();
    @track isCaseNumberDisabled = false;
    @track isAppNumberDisabled = false;
    @track isFieldVisible = true;

    @track addressLine = "";
    @track countyPicklistValue;
    @track countyValue = "";
    @track genderPicklistValue;
    @track genderValue = "";
    @track dateFilterPicklist;
    @track dateFilter = "";
    @track dueDate = "";
    @track submittedDatePicklist;
    @track submittedDate = "";
    @track applicationSearchPicklist;
    @track applicationSearch = "";
    @track casePicklist;
    @track caseValues = "";
    @track assisterPicklist;
    @track assistedBy = "";
    @track maidNumber = "";
    @track applicationSubmittedToggle = "";
    @track isToggleDisabled = false;
    @track isApplicationUnsubmitted = "";
    @track selectAtLeastTwoFields = false;
    @track hrefData = "";
    @track contactList;
    @track clientFound = "";
    @track isAgencyAdmin = false;
    @track isExport = false;
    @track searchQuery = {
        firstName: "",
        lastName: "",
        caseApplication: "",
        SSN: "",
        dob: "",
        gender: "",
        addressLine1: "",
        county: "",
        applicationStatus: "",
        caseStatus: "",
        renewalDueDate: "",
        rfiDueDate: "",
        submittedDate: "",
        assistedBy: "",
        maidNumber: "",
        phone: "",
        email: "",
        applicationSubmittedToggle: ""
    };
    @track metaDataListParent;
    @track ssn9 = "";
    @track roleVisibility = {};
    @track csvIterativeData = "";
    @track isLoadedForFirstTime = false;
    @track errorMessagesList = [];
    
    isSearchClick = false;
    ssnInputType = sspConstants.inputTypes.password;
    selectedRadio = null;
    clientDetailsOrder = "ASC";
    statusOrder = "ASC";
    submittedDateOrder = "ASC";
    assignedTo = "ASC";

    /**
     * @function : clientsSelected
     * @description	: To get clients selected.
     */
    get clientsSelected () {
        return this.selectedRecords.length;
    }

    /**
     * @function : clientResultsCount
     * @description	: To get client result count.
     */
    get clientResultsCount () {
        if (this.tableData.length > 0) { // Added as part of Defect - 380560
            return this.tableData.length;
        } else {
          return 0;
        }
    }

    /**
     * @function : isSearchResults
     * @description	: To get is search result exists.
     */
    get isSearchResults () {
        return this.tableData.length > 0;
    }

    /**
     * @function : MetadataList
     * @description	: To get MetadataList.
     */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    /**
     * @function : MetadataList
     * @description	: To set MetadataList.
     * @param  {object} value - MetadataList Value.
     */
    set MetadataList (value) {
        this.metaDataListParent = value;
    }

    /**
     * @function : connectedCallback
     * @description	: Runs on load to take care of initializing entity mapping list and display search fields according to the role visibility.
     */
    connectedCallback () {
        try {
            this.isLoadedForFirstTime = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "BirthDate__c,SSP_Member__c",
                "Email__c,SSP_Member__c",
                "FirstName__c,SSP_Member__c",
                "LastName__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Member__c",
                "SSN__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSSP_NonCitDash_Search"
            );
            this.getNonCitizenUserRoleVisibility();
            this.getPicklistForSearch();
            if (
                this.dashboardSearchResult !== undefined ||
                this.dashboardSearchResult !== null
            ) {
                this.tableData = this.dashboardSearchResult;                
            } else {
                this.showSearchResults = false;
            }
            this.displayAssistedByColumn();
            this.ssnFieldDisplay();
            

            if (this.tableData.length < 10 && this.tableData.length > 0) {
                this.clientFound = this.label.sspClients;
            } else if (this.tableData.length >= 10) {
                this.clientFound = this.label.sspClientFound;
            }
        } catch (e) {
            console.error(
                "Error in connectedCallback of NonCitizen Search page page",
                e
            );
        }
    }

    /**
     * @function : renderedCallback
     * @description	: This method is called when search is rendered.
     */

    renderedCallback () {
        if (this.entered === false && this.template.querySelector(".ssp-offAutoFill")) {
            
            this.template.querySelectorAll(".ssp-offAutoFill").forEach(component => {
                component.setAttribute("autocomplete", "off");
            });
            this.entered = true;
            //Add the below code for masking
            const agent = window.navigator.userAgent;
            const browserIE = /MSIE|Trident/.test(agent);
            if (browserIE) 
            {
                this.ssnInputType = sspConstants.inputTypes.password;
            }
            else {
                this.ssnInputType = "text";
            }
        }
    }


    
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
                        this.roleVisibility =
                            result.mapResponse.fieldPermissionsMap;
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
                        //End - Added as part of Defect-394044
                    }
                })
                .catch({});
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "Error occurred in getNonCitizenUserRoleVisibility of sspClientSearch page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : getPicklistForSearch.
     * @description	: To get pickList values on load.
     */
    getPicklistForSearch = () => {
        try {
            getPicklistForSearch()
                .then(result => {
                    const pickListData = result.mapResponse;
                    if (
                        result.bIsSuccess &&
                        !metadataUtility.isUndefinedOrNull(pickListData)
                    ) {
                        if (pickListData.hasOwnProperty("gender")) {
                            const genderList = [];
                            const retrievedGender = pickListData.gender;
                            Object.keys(retrievedGender).forEach(key => {
                                genderList.push({
                                    label: retrievedGender[key],
                                    value: key
                                });
                            });
                            this.genderPicklistValue = genderList;
                        }
                        if (pickListData.hasOwnProperty("county")) {
                            const countyPicklistValue = [];
                            const retrievedCounty = pickListData.county;
                            Object.keys(retrievedCounty).forEach(key => {
                                countyPicklistValue.push({
                                    label: retrievedCounty[key],
                                    value: key
                                });
                            });
                            this.countyPicklistValue = countyPicklistValue;
                        }
                        if (pickListData.hasOwnProperty("submittedDate")) {
                            const submittedDatePicklist = [];
                            const retrievedSubmittedDate =
                                pickListData.submittedDate;

                            Object.keys(retrievedSubmittedDate).forEach(key => {
                                submittedDatePicklist.push({
                                    label: retrievedSubmittedDate[key],
                                    value: key
                                });
                            });
                            this.submittedDatePicklist = submittedDatePicklist;
                            this.submittedDate = submittedDefaultValue;
                        }
                        if (pickListData.hasOwnProperty("renewalDate")) {
                            const dateFilterPicklist = [];
                            const retrievedDateFilter =
                                pickListData.renewalDate;
                            Object.keys(retrievedDateFilter).forEach(key => {
                                dateFilterPicklist.push({
                                    label: retrievedDateFilter[key],
                                    value: key
                                });
                            });
                            this.dateFilterPicklist = dateFilterPicklist;
                        }
                        if (pickListData.hasOwnProperty("mcoStatus")) {
                            const applicationSearchPicklist = [];
                            const retrievedApplicationValues =
                                pickListData.mcoStatus;
                            Object.keys(retrievedApplicationValues).forEach(
                                key => {
                                    applicationSearchPicklist.push({
                                        label: retrievedApplicationValues[key],
                                        value: key
                                    });
                                }
                            );
                            this.applicationSearchPicklist = applicationSearchPicklist;
                        }
                        if (pickListData.hasOwnProperty("caseStatus")) {
                            const casePicklist = [];
                            const retrievedCaseStatus = pickListData.caseStatus;
                            Object.keys(retrievedCaseStatus).forEach(key => {
                                casePicklist.push({
                                    label: retrievedCaseStatus[key],
                                    value: key
                                });
                            });
                            this.casePicklist = casePicklist;
                        }

                        if (pickListData.hasOwnProperty("assisterPicklist")) {
                            const assisterPicklist = [];
                            const retrievedCaseStatus =
                                pickListData.assisterPicklist;
                            Object.keys(retrievedCaseStatus).forEach(key => {
                                assisterPicklist.push({
                                    label: retrievedCaseStatus[key],
                                    value: key
                                });
                            });
                            this.assisterPicklist = assisterPicklist;
                        }
                        this.showSpinner = false;
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error in retrieving data sspClientSearch  " +
                                JSON.stringify(pickListData.ERROR)
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in getPicklistForSearch" + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : displayAssistedByColumn.
     * @description	: To display assisted by column on condition.
     */
    displayAssistedByColumn = () => {
        try {
            if (this.userRole === "Agency_Admin") {
                this.isAgencyAdmin = true;
            } else {
                this.modifiedColumn = [
                    { colName: this.label.sspClientDetails },
                    { colName: this.label.sspCaseStatus },
                    { colName: this.label.sspSubmittedDate },
                    { colName: this.label.sspLastUpdated }
                ];
                this.isAgencyAdmin = false;
            }
        } catch (error) {
            console.error("Error in displaying assisted by column", error);
        }
    };

    /**
     * @function : ssnFieldDisplay.
     * @description	: To display SSN 9 Digit / 4 Digit Search Field on condition.
     */
    ssnFieldDisplay = () => {
        try {
            if (
                this.userRole === "DCBS_View_Only" ||
                this.userRole === "DCBS_Central_Office_View_and_Edit" ||
                this.userRole === "Mail_Center_Supervisor" ||
                this.userRole === "Mail_Center_Worker"
            ) {
                this.is4Digit = true;
                this.is9Digit = false;
            } else {
                this.is9Digit = true;
                this.is4Digit = false;
            }
        } catch (error) {
            console.error("Error in displaying ssn Field", error);
        }
    };

    /**
     * @function : hideFirstFiveDigits.
     * @description	: To hide first five digit in SSN Field on condition.
     */
    hideFirstFiveDigits = () => {
        this.errorMessagesList = [];
        try {
            if(this.socialSecurityDigit9.length <= 9) {
              const regexExpr = new RegExp("^(?!(000000000|9))([0-9]){9}$");
              const regexResult = regexExpr.test(this.socialSecurityDigit9);
              if (regexResult && this.socialSecurityDigit9.length === 9) {
                  const ssn = this.socialSecurityDigit9;
                  this.ssn9 = this.socialSecurityDigit9;
                  const lastFourDigit = ssn.slice(-4);
                  const fiveDigit = ssn.slice(0, 5);

                  this.socialSecurityDigit9 =
                      fiveDigit.replace(/\d/g, "\u2022") + lastFourDigit;
              } else if (this.socialSecurityDigit9.length > 0) {
                  if (regexExpr.test(this.ssn9)) {
                    return;
                  }
                  this.ssn9 = "";
                  this.errorMessagesList.push(sspSSNValidationMessage);
              }
            }
        } catch (error) {
            console.error("Error in displaying ssn Field", error);
        }
    };

    /**
     * @function : handleInputText
     * @description	: Method to handle onclick event for SSN 9 Digit.
     * @param {object{}} event - OnClick event.
     */
    showInputNineSSN = event => {
        try {
            if (this.ssn9.length !== 9) {
                event.target.value = this.socialSecurityDigit9;
            } else {
                this.socialSecurityDigit9 = this.ssn9;
            }
        } catch (error) {
            console.error("Error in displaying ssn Field", error);
        }
    };

    /**
     * @function : searchData.
     * @description	: To evaluate the search fields and gather entered data for search query on click of search button.
     */
    searchData = () => {
        try {
            this.showSpinner = true;
            this.noResultFound = false;
            this.showSearchResults = false;
            this.searchQuery.firstName = this.cFirstName;
            this.searchQuery.lastName = this.cLastName;
            if (
                metadataUtility.isEmpty(this.caseNumber) &&
                this.isCaseNumberDisabled === false
            ) {
                this.searchQuery.caseApplication = this.caseNumber;
            } else if (
                metadataUtility.isEmpty(this.applicationNumber) &&
                this.isAppNumberDisabled === false
            ) {
                this.searchQuery.caseApplication = this.applicationNumber;
            } else if (
                !metadataUtility.isEmpty(this.caseNumber) &&
                this.isCaseNumberDisabled === false
            ) {
                this.searchQuery.caseApplication = this.caseNumber;
            } else if (
                !metadataUtility.isEmpty(this.applicationNumber) &&
                this.isAppNumberDisabled === false
            ) {
                this.searchQuery.caseApplication = this.applicationNumber;
            }

            if (this.roleVisibility.SSP_SSN9) {
                this.searchQuery.SSN = this.ssn9;
            } else if (this.roleVisibility.SSP_SSN4) {
                this.searchQuery.SSN = this.socialSecurityDigit4;
            }
            this.searchQuery.dob = this.dateOfBirth;
            this.searchQuery.gender = this.genderValue;
            this.searchQuery.addressLine1 = this.addressLine;
            this.searchQuery.county = this.countyValue;
            this.searchQuery.applicationStatus = this.applicationSearch;
            this.searchQuery.caseStatus = this.caseValues;
            this.searchQuery.renewalDueDate = this.dateFilter;
            this.searchQuery.rfiDueDate = this.dueDate;
            this.searchQuery.submittedDate = this.submittedDate;
            this.searchQuery.assistedBy = this.assistedBy;
            this.searchQuery.maidNumber = this.maidNumber;
            this.searchQuery.phone = this.phoneNumber;
            this.searchQuery.email = this.email;
            this.searchQuery.applicationSubmittedToggle = this.isApplicationUnsubmitted;

            let searchedFieldCount = 0;
            if (
                this.userRole === "Assister" ||
                this.userRole === "Organization_Auth_Rep" ||
                this.userRole === "Individual_Auth_Rep" ||
                this.userRole === "Agency_Admin"
            ) {
                this.selectAtLeastTwoFields = false;
                this.searchNonCitizenClients();
            } else if (!metadataUtility.isEmpty(this.searchQuery.caseApplication)) {
                this.selectAtLeastTwoFields = false;
                this.validateHighLightAll(this.selectAtLeastTwoFields);
                this.searchNonCitizenClients();
            } else {
                Object.keys(this.searchQuery).forEach((searchedFields) => {
                    if (!metadataUtility.isUndefinedOrNull(searchedFields)) {
                        if (
                            !metadataUtility.isEmpty(
                                this.searchQuery[searchedFields]
                            ) &&
                            !metadataUtility.isUndefinedOrNull(
                                this.searchQuery[searchedFields]
                            ) && //Added as a part of Defect - 380560
                            this.showAdvanced //Added as a part of Defect - 380560
                        ) {
                            searchedFieldCount = searchedFieldCount + 1;
                        }
                        //Start - Added as a part of Defect - 380560
                        else if (
                            (searchedFields === "firstName" ||
                                searchedFields === "lastName" ||
                                searchedFields === "caseApplication" ||
                                searchedFields === "SSN" ||
                                searchedFields === "dob") &&
                            !metadataUtility.isEmpty(
                                this.searchQuery[searchedFields]
                            ) &&
                            !metadataUtility.isUndefinedOrNull(
                                this.searchQuery[searchedFields]
                            ) &&
                            !this.showAdvanced
                        ) {
                            searchedFieldCount = searchedFieldCount + 1;
                        }
                        //End - Added as a part of Defect - 380561
                    }
                })

                if (searchedFieldCount >= 2) {
                    this.selectAtLeastTwoFields = false;
                    this.validateHighLightAll(this.selectAtLeastTwoFields);
                    this.searchNonCitizenClients();
                } else {
                    this.selectAtLeastTwoFields = true;
                    this.validateHighLightAll(this.selectAtLeastTwoFields);
                    this.showSpinner = false;
                }
            }

            if (this.clientResultsCount === 1) {
                this.clientFound = this.label.sspOneClientFound;
            } else {
                this.clientFound = this.label.sspClientFound;
            }
        } catch (error) {
            console.error("Error in search", error);
        }
    };

    /**
     * @function - searchNonCitizenClients.
     * @description - Use to search Data.
     */
    searchNonCitizenClients = () => {
        try {
            /** #379953 Fix. */
            const searchInputComponents = this.template.querySelectorAll(".ssp-applicationInputs");
            let isValid = true;
            if (!metadataUtility.isUndefinedOrNull(searchInputComponents) && this.template.querySelectorAll(".ssp-applicationInputs").length > 0) {
                searchInputComponents.forEach(inputComponent => {
                    const validationMessages = inputComponent.ErrorMessageList;
                    if (!metadataUtility.isUndefinedOrNull(validationMessages) && validationMessages.length > 0) {
                        isValid = false;
                    }
                });
            }
            if (isValid) {
                this.hasSaveValidationError = false;
            /** */
                searchNonCitizenClients({
                    userId: this.userId,
                    searchQuery: JSON.stringify(this.searchQuery)
                })
                    .then(result => {
                        if (
                            result.mapResponse.bIsSuccess &&
                            !metadataUtility.isUndefined(
                                result.mapResponse.searchResultDataNC
                            ) &&
                            result.mapResponse.searchResultDataNC !== "null"
                        ) {
                            this.isSearchClick = true;
                            this.tableData = result.mapResponse.searchResultDataNC;

                            /** #374831 Fix.*/
                            const dataToSort = [...this.tableData];

                            this.submittedDateOrder = "DESC";
                            dataToSort.sort(this.lastUpdatedSort);

                            this.tableData =
                                dataToSort.length > 0 ? dataToSort : this.tableData;
                            /** */
                            if (this.tableData.length > 200) {
                                this.tableData = this.tableData.slice(0, 200);
                            }
                            //commented as part of 380146 Defect Fix
                         /*   if (this.isLoadedForFirstTime) {
                                this.isLoadedForFirstTime = false;
                                if (
                                    this.tableData.length > 0 &&
                                    this.tableData.length < 10
                                ) {
                                    this.showSearchResults = true;
                                    this.noResultFound = false;
                                    this.clientFound = this.label.sspClients;
                                } else {
                                    this.showSearchResults = false;
                                    this.noResultFound = false;
                                }
                            } else {*/
                                if (
                                    metadataUtility.isUndefined(this.tableData.length) ||
                                    this.tableData.length === 0
                                ) {
                                    this.showSpinner = false;
                                    this.noResultFound = true;
                                    this.showSearchResults = false;
                                } else {
                                    this.noResultFound = false;
                                    this.showSearchResults = true;
                                    this.clientFound = this.label.sspClientFound;
                                }
                          //  }

            //  this.loadDataToCSV();

                            this.showSpinner = false;
                        } else {
                            console.error(
                                "Error in loading Results" + JSON.stringify(result)
                            );
                            this.showSpinner = false;
                        }
                    })
                    .catch(error => {
                        console.error("Error in getting data", error);
                        this.showSpinner = false;
                    });
                /** #379953 Fix. */
            }
            else {
                this.hasSaveValidationError = true;
                this.showSpinner = false;
            }
            /** */
        } catch (error) {
            console.error(
                "Error occurred in searchNonCitizenClients of sspClientSearch page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : validateHighLightAll
     * @description	: To show validation highlight on all the fields which does not match the search criteria.
     * @param {boolean} highLight - Boolean value.
     */
    validateHighLightAll = highLight => {
        try {
            if (highLight) {
                const fields = this.template.querySelectorAll(
                    ".ssp-applicationInputs"
                );

                const value = [];
                for (let count = 0; count < fields.length; count++) {
                    if (
                        fields[count].name === sspConstants.clientSearch.gender
                    ) {
                        value[count] = this.genderValue;
                    } else if (
                        fields[count].name === sspConstants.clientSearch.county
                    ) {
                        value[count] = this.countyValue;
                    } else if (
                        fields[count].name === sspConstants.clientSearch.mco
                    ) {
                        value[count] = this.applicationSearch;
                    } else if (
                        fields[count].name === sspConstants.clientSearch.renewal
                    ) {
                        value[count] = this.dateFilter;
                    } else if (
                        fields[count].name ===
                        sspConstants.clientSearch.caseStatus
                    ) {
                        value[count] = this.caseValues;
                    } else if (
                        fields[count].name === sspConstants.clientSearch.rfi
                    ) {
                        value[count] = this.dueDate;
                    } else if (
                        fields[count].name ===
                        sspConstants.clientSearch.submittedDate
                    ) {
                        value[count] = this.submittedDate;
                    } else if (
                        fields[count].name ===
                        sspConstants.clientSearch.assistedBy
                    ) {
                        value[count] = this.assistedBy;
                    } else if (
                        fields[count].value !== null &&
                        fields[count].value !== undefined
                    ) {
                        value[count] = fields[count].value;
                    } else {
                        value[count] = "";
                    }

                    if (metadataUtility.isEmpty(value[count])) {
                        fields[count].classList.add("ssp-validationHighLight");
                    }
                }
                const validateToggle = this.template.querySelector(
                    ".ssp-clientSearchToggle"
                );
                if (this.showAdvanced) {
                    if (!this.isToggleDisabled) {
                        if (metadataUtility.isEmpty(validateToggle.value)) {
                            validateToggle.ErrorMessageList = [
                                this.label.sspAtLeastTwoField
                            ];
                        }
                    } else {
                        validateToggle.ErrorMessageList = [];
                    }
                }
            } else if (!highLight) {
                const fields = this.template.querySelectorAll(
                    ".ssp-applicationInputs"
                );
                for (let count = 0; count < fields.length; count++) {
                    fields[count].classList.remove("ssp-validationHighLight");
                }
                if (this.showAdvanced) {
                    const validateToggle = this.template.querySelector(
                        ".ssp-clientSearchToggle"
                    );
                    validateToggle.ErrorMessageList = [];
                }
                
            }
        } catch (error) {
            console.error(
                "Error in custom validation fields high light",
                error
            );
        }
    };

    /**
     * @function - toggleSearchAdvanced.
     * @description - To toggle show/hide advanced search fields.
     * @param {event} event - Toggle advanced search fields event.
     */
    toggleSearchAdvanced = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                if (this.showAdvanced === false) {
                    this.showAdvanced = true;
                } else if (this.showAdvanced === true) {
                    this.showAdvanced = false;
                }
            }
        } catch (error) {
            console.error("Error in toggle advanced search", error);
        }
    };

    /**
     * @function : handleInputText
     * @description	: Method to handle onchange event for Input Text, Numbers, Phone, Email.
     * @param {object{}} event - Onchange event.
     */
    handleInputText = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (event.target.name === sspConstants.clientSearch.firstName) {
                this.cFirstName = event.target.value;
            } else if (
                event.target.name === sspConstants.clientSearch.lastName
            ) {
                this.cLastName = event.target.value;
            } else if (
                event.target.name === sspConstants.clientSearch.phoneNumber
            ) {
                this.phoneNumber = event.target.value;
            } else if (
                event.target.name === sspConstants.clientSearch.emailAddress
            ) {
                this.email = event.target.value;
            } else if (
                event.target.name ===
                sspConstants.clientSearch.socialSecurityNumber9
            ) {
                this.socialSecurityDigit9 = event.target.value;
                this.ssn9 = this.socialSecurityDigit9;
                this.hideFirstFiveDigits();
            } else if (
                event.target.name ===
                sspConstants.clientSearch.socialSecurityNumber4
            ) {
                this.socialSecurityDigit4 = event.target.value;
            } else if (
                event.target.name === sspConstants.clientSearch.maidNumber
            ) {
                this.maidNumber = event.target.value;
            } else if (
                event.target.name === sspConstants.clientSearch.address
            ) {
                this.addressLine = event.target.value;
            }
        } catch (error) {
            console.error("Error Occured in handling input text", error);
        }
    };

    /**
     * @function : handleRadioClick
     * @description	: Method to handle onchange event for case/application radio button.
     * @param {object{}} event - Onchange event.
     */
    handleRadioClick = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (this.selectedRadioButton !== event.target.value) {
                // Checking for value change
                this.selectedRadioButton = event.target.value;
                if (
                    this.selectedRadioButton ===
                    sspConstants.clientSearch.applicationNumber
                ) {
                    this.isCaseNumberDisabled = true;
                    this.isAppNumberDisabled = false;
                    const element = this.template.querySelector(
                        ".ssp-disable-caseNumber"
                    );
                    element.value = null;
                    element.ErrorMessageList = [];
                } else {
                    this.isAppNumberDisabled = true;
                    this.isCaseNumberDisabled = false;
                    const element = this.template.querySelector(
                        ".ssp-disable-appNumber"
                    );
                    element.value = null;
                    element.ErrorMessageList = [];
                }
            }
        } catch (error) {
            console.error(error);
        }
    };

    /**
     * @function : handleCaseNumberChange
     * @description	: Method to handle onchange event for case number field.
     * @param {object{}} event - Onchange event.
     */
    handleCaseNumberChange = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (event.target.name === sspConstants.clientSearch.caseNumber) {
                this.caseNumber = event.detail.value;
                this.isAppNumberDisabled = true;
                if (this.caseNumber !== "" && this.caseNumber !== null) {
                    const radioRef = this.template.querySelectorAll(
                        sspConstants.clientSearch.sspMultiLineRadioInput
                    );
                    radioRef.forEach(element => {
                        if (
                            element.value ===
                            sspConstants.clientSearch.caseNumber
                        ) {
                            element.checked = true;
                            element.click();
                            this.isToggleDisabled = true;
                        }
                    });
                }
            }
        } catch (error) {
            console.error("Error in Case Number", error);
        }
    };

    /**
     * @function : handleApplicationNumberChange
     * @description	: Method to handle onchange event for application number field.
     * @param {object{}} event - Onchange event.
     */
    handleApplicationNumberChange = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (
                event.target.name ===
                sspConstants.clientSearch.applicationNumber
            ) {
                this.applicationNumber = event.detail.value;
                this.isCaseNumberDisabled = true;

                if (
                    this.applicationNumber !== "" &&
                    this.applicationNumber !== null
                ) {
                    const radioRef = this.template.querySelectorAll(
                        sspConstants.clientSearch.sspMultiLineRadioInput
                    );
                    radioRef.forEach(element => {
                        if (
                            element.value ===
                            sspConstants.clientSearch.applicationNumber
                        ) {
                            element.checked = true;
                            element.click();
                            this.isToggleDisabled = true;
                        }
                    });
                }
            }
        } catch (error) {
            console.error("Error in Case Number", error);
        }
    };

    /**
     * @function : handleBirthDate
     * @description	: Method to handle onchange event for birth date field.
     * @param {object{}} event - Onchange event.
     */
    handleBirthDate = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            this.dateOfBirth = event.target.value;
        } catch (error) {
            console.error("Error in handling Birth Date", error);
        }
    };

    /**
     * @function : handlePickListChange
     * @description	: Method to handle onchange event for all pickList fields.
     * @param {object{}} event - Onchange event.
     */
    handlePickListChange = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (event.target.name === sspConstants.clientSearch.gender) {
                this.genderValue = event.target.value;
                event.target.value = "";
            } else if (event.target.name === sspConstants.clientSearch.county) {
                this.countyValue = event.target.value;
                event.target.value = "";
            } else if (event.target.name === sspConstants.clientSearch.mco) {
                this.applicationSearch = event.target.value;
                event.target.value = "";
            } else if (
                event.target.name === sspConstants.clientSearch.renewal
            ) {
                this.dateFilter = event.target.value;
                event.target.value = "";
            } else if (
                event.target.name === sspConstants.clientSearch.caseStatus
            ) {
                this.caseValues = event.target.value;
                event.target.value = "";
            } else if (event.target.name === sspConstants.clientSearch.rfi) {
                this.dueDate = event.target.value;
                event.target.value = "";
            } else if (
                event.target.name === sspConstants.clientSearch.submittedDate
            ) {
                this.submittedDate = event.target.value;
                event.target.value = "";
            } else if (
                event.target.name === sspConstants.clientSearch.assistedBy
            ) {
                this.assistedBy = event.target.value;
                event.target.value = "";
            }
        } catch (error) {
            console.error("Error Occured in handling input text", error);
        }
    };

    /**
     * @function : toggleUnsubmittedApplication
     * @description	: Method to handle onchange event for toggle unsubmitted application field.
     * @param {object{}} event - Onchange event.
     */
    toggleUnsubmittedApplication = event => {
        try {
            this.selectAtLeastTwoFields = false;
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            if (event.target.value === sspConstants.toggleFieldValue.yes) {
                this.isApplicationUnsubmitted = true;
                this.applicationSubmittedToggle =
                    sspConstants.toggleFieldValue.yes;
            } else {
                this.isApplicationUnsubmitted = false;
                this.applicationSubmittedToggle =
                    sspConstants.toggleFieldValue.no;
            }
        } catch (e) {
            console.error("Error in Unsubmitted Application toggle", e);
        }
    };

    /**
     * @function : resetClientSearchFields
     * @description	: To reset all search fields and validations error messages.
     */
    resetClientSearchFields = () => {
        try {
            this.showSpinner = true;
            this.selectAtLeastTwoFields = false;
            this.hasSaveValidationError = false; 
            this.validateHighLightAll(this.selectAtLeastTwoFields);
            this.cFirstName = "";
            this.cLastName = "";
            this.caseNumber = "";
            this.applicationNumber = "";
            this.socialSecurityDigit9 = "";
            this.socialSecurityDigit4 = "";
            this.dateOfBirth = "";
            this.phoneNumber = "";
            this.email = "";
            this.addressLine = "";
            this.isCaseNumberDisabled = false;
            this.isAppNumberDisabled = false;
            this.countyValue = "";
            this.genderValue = "";
            this.dueDate = "";
            this.dateFilter = "";
            this.submittedDate = "";
            this.applicationSearch = "";
            this.caseValues = "";
            this.assistedBy = "";
            this.maidNumber = "";
            this.ssn9 = "";
            this.isToggleDisabled = false;
            this.isApplicationUnsubmitted = "";
            this.applicationSubmittedToggle = "";
            this.csvIterativeData = "";
            this.hrefData = "";

            this.showSearchResults = false;
            this.noResultFound = false;

            Object.keys(this.searchQuery).forEach((searchedFields) => {
                if (this.searchQuery) {
                    this.searchQuery[searchedFields] = "";
                }
            });
            const radioRef = this.template.querySelectorAll(
                sspConstants.clientSearch.sspMultiLineRadioInput
            );
            radioRef.forEach(element => {
                element.checked = false;
            });

            const resetValidations = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            resetValidations.forEach(components => {
                components.ErrorMessageList = [];
                components.classList.remove("ssp-input-error");
            });
            // this.searchNonCitizenClients();
            this.getPicklistForSearch();
        } catch (error) {
            console.error(
                "Error in resetting search field values value",
                error
            );
        }
    };

    /**
     * @function : handleCheck
     * @description	: To handle Record Selection.
     * @param  {object} event - .
     */
    handleCheck = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                const index = parseInt(
                    event.target.getAttribute("data-id"),
                    10
                );
                const dataTable = [...this.tableData];
                for (const data of dataTable) {
                    if (
                        data.recordId === this.currentPageData[index].recordId
                    ) {
                        this.navigate(this.currentPageData[index]);
                        break;
                    }
                }
            }
        } catch (error) {
            console.error("Error in handle check, data in data check", error);
        }
    };
    navigate = contactData => {
        try {
            const benefitsUsers = [sspConstants.userRole.DJJ, sspConstants.userRole.EBI, sspConstants.userRole.DOE];
            getContactFromWrapper({
                wrapperData: JSON.stringify(contactData)
            })
                .then(() => {
                    const navigateTo = (this.userRole && benefitsUsers.includes(this.userRole)) ? sspConstants.navigationUrl.benefitsPageName : sspConstants.navigationUrl.citizenDashboard;
                    window.location.href = "../s/" + navigateTo;
                    this.showSpinner = false;
                })
                .catch({});
        } catch (error) {
            console.error("Error in getting contact from wrapper", error);
        }
        return null;
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
        return null;
    };
    /**
     * @function : clientDetailsSort
     * @description	: To handle Client Details Sorting.
     * @param  {object} a - .
     * @param  {object} b - .
     */
    clientDetailsSort = (a, b) => {
        try {
            const lastNameA = a.lastName.toUpperCase();
            const lastNameB = b.lastName.toUpperCase();
            if (this.clientDetailsOrder === "ASC") {
                return lastNameA < lastNameB
                    ? -1
                    : lastNameA > lastNameB
                    ? 1
                    : 0;
            }
            return lastNameA < lastNameB ? 1 : lastNameA > lastNameB ? -1 : 0;
        } catch (error) {
            console.error(error);
        }
        return null;
    };
    /**
     * @function : statusOrderSort
     * @description	: To handle Client Status Sorting.
     * @param  {object} a - .
     * @param  {object} b - .
     */
    statusOrderSort = (a, b) => {
        try {
            const statusA = a.caseApplicationStatus;
            const statusB = b.caseApplicationStatus;
            if (this.statusOrder === "ASC") {
                return statusA < statusB ? -1 : statusA > statusB ? 1 : 0;
            }
            return statusA < statusB ? 1 : statusA > statusB ? -1 : 0;
        } catch (error) {
            console.error(error);
        }
        return null;
    };
    /**
     * @function : assignedToOrderSort
     * @description	: To handle Client assistedBy Sorting.
     * @param  {object} a - .
     * @param  {object} b - .
     */
    assignedToOrderSort = (a, b) => {
        try {
            const statusA = metadataUtility.isUndefinedOrNull(a.assistedByAuthRep)
                ? ""
                : a.assistedByAuthRep.toUpperCase();
            const statusB = metadataUtility.isUndefinedOrNull(b.assistedByAuthRep)
                ? ""
                : b.assistedByAuthRep.toUpperCase();
            if (this.assignedTo === "ASC") {
                return statusA < statusB ? -1 : statusA > statusB ? 1 : 0;
            }
            return statusA < statusB ? 1 : statusA > statusB ? -1 : 0;
        } catch (error) {
            console.error(error);
        }
        return null;
    };
    /**
     * @function : assignmentDateSort
     * @description	: To handle Assignment Start Date Sorting.
     * @param  {object} a - .
     * @param  {object} b - .
     */
    submittedDateSort = (a, b) => {
        try {
            const startDateA = this.convertDateToTimestamp(a.submittedDate);
            const startDateB = this.convertDateToTimestamp(b.submittedDate);
            if (this.submittedDateOrder === "ASC") {
                return startDateA < startDateB
                    ? -1
                    : startDateA > startDateB
                    ? 1
                    : 0;
            }
            return startDateA < startDateB
                ? 1
                : startDateA > startDateB
                ? -1
                : 0;
        } catch (error) {
            console.error(error);
        }
        return null;
    };
    /**
     * @function : lastUpdatedSort
     * @description	: To handle Assignment Start Date Sorting.
     * @param  {object} a - .
     * @param  {object} b - .
     */
    lastUpdatedSort = (a, b) => {
        try {
            const startDateA = this.convertDateToTimestamp(a.lastUpdatedDate);
            const startDateB = this.convertDateToTimestamp(b.lastUpdatedDate);
            if (this.submittedDateOrder === "ASC") {
                return startDateA < startDateB
                    ? -1
                    : startDateA > startDateB
                    ? 1
                    : 0;
            }
            return startDateA < startDateB
                ? 1
                : startDateA > startDateB
                ? -1
                : 0;
        } catch (error) {
            console.error(error);
        }
        return null;
    };
    /**
     * @function : handleSorting
     * @description	: To handle Sorting functionality.
     *   @param  {object} event - .
     */
    handleSorting = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                const colToSort = event.target.getAttribute("data-name");
                const dataToSort = [...this.tableData];
                // const dataToSort = [...this.currentPageData];
                if (
                    colToSort === "Client Details" ||
                    colToSort ===
                        sspConstants.clientSearch.sspClientDetailsSpanish
                ) {
                    this.clientDetailsOrder =
                        this.clientDetailsOrder === "ASC" ? "DESC" : "ASC";
                    dataToSort.sort(this.clientDetailsSort);
                } else if (
                    colToSort === "Case Status" ||
                    colToSort === sspConstants.clientSearch.sspCaseStatus
                ) {
                    this.statusOrder =
                        this.statusOrder === "ASC" ? "DESC" : "ASC";
                    dataToSort.sort(this.statusOrderSort);
                } else if (
                    colToSort === "Submitted Date" ||
                    colToSort === sspConstants.clientSearch.sspSubmittedDate
                ) {
                    this.submittedDateOrder =
                        this.submittedDateOrder === "ASC" ? "DESC" : "ASC";
                    dataToSort.sort(this.submittedDateSort);
                } else if (
                    colToSort === "Last Updated" ||
                    colToSort === sspConstants.clientSearch.sspLastUpdated
                ) {
                    this.submittedDateOrder =
                        this.submittedDateOrder === "ASC" ? "DESC" : "ASC";
                    dataToSort.sort(this.lastUpdatedSort);
                } else if (
                    colToSort === "Assisted By" ||
                    colToSort === sspConstants.clientSearch.sspAssistedBy
                ) {
                    this.assignedTo =
                        this.assignedTo === "ASC" ? "DESC" : "ASC";
                    dataToSort.sort(this.assignedToOrderSort);
                }
                this.tableData =
                    dataToSort.length > 0 ? dataToSort : this.tableData;
            }
            
        } catch (error) {
            console.error(error);
        }
    };
    /**
     * @function : getCurrentPageData
     * @description	: To get data for current page.
     * @param  {object} event - Get current page data.
     */
    getCurrentPageData = event => {
        try {
            this.currentPageData = event.detail.currentPageData;
        } catch (error) {
            console.error("Error in getting current page data", error);
        }
    };

    /**
     * @function : exportToCSV
     * @description	: To export table data into CSV.
     * @param  {object} event - Event onclick or on key down.
     */
    exportToCSV = event => {
        try {
       this.showSpinner = true;
      if (event.keyCode === 13 || event.type === "click" && this.clientResultsCount>0) {
          exportToExcelCallout({
            listClientSearchResult: JSON.stringify(this.tableData),
            userId: this.userId
          }).then(result => {
            if (result.mapResponse.bIsSuccess) {
              this.contactList = result.mapResponse.finalList;
              this.generateCSV();
              this.showSpinner = false;
            }
            else {
              this.showSpinner = false;
              this.errorMsg = result.mapResponse.error;
              this.showErrorModal = true;
            }

          });
      }
      else {
        this.showSpinner = false;
      }
    } catch (error) {
      this.showSpinner = false;
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

                const mapFieldPermission = new Map(
                    Object.entries(this.roleVisibility)
                );
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
                jsonKeys.push("birthDate"); // Defect - 381071. Change from age to birthDate.
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
                if (
                    mapFieldPermission.get("SSP_Excel_Programs_Due_for_Renew")
                ) {
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
                Object.keys(columnHeader).forEach((header) => {
                    if (inForLoop) {
                        this.csvIterativeData +=
                            '"' + columnHeader[header] + '"' + csvSeparator;
                    }
                })
                
                if (jsonRecordsData && jsonRecordsData.length > 0) {
                    this.csvIterativeData += newLineCharacter;
                    for (let i = 0; i < jsonRecordsData.length; i++) {
                        let counter = 0;
                        Object.keys(jsonKeys).forEach((iteratorObj) => {
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
                                            '"' +
                                            jsonRecordsData[i][dataKey].slice(
                                                -4
                                            ) +
                                            '"';
                                    } else {
                                        this.csvIterativeData +=
                                            '"' +
                                            jsonRecordsData[i][dataKey] +
                                            '"';
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

   /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
      try {
          this.showErrorModal = false;
          this.showSpinner = false;
      } catch (error) {
          console.error(
              "Error in closeError:" + JSON.stringify(error.message)
          );
      }
  };
}