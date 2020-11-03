/**
 * Component Name: sspFindAssisterOrAgent.
 * Author: Yathansh Sharma, Venkata.
 * Description: Search/Find the Assister or Agent component.
 * Date: 1/13/2020.
 */
import { track, api } from "lwc";
import utility from "c/sspUtility";
import getAgentAndAssister from "@salesforce/apex/SSP_AgentAssistorController.getAgentAndAssisstor";
import sspYourAssisterReps from "@salesforce/label/c.SSP_YourAssisterReps";
import sspFindAssisterOrAgentLabel from "@salesforce/label/c.SSP_FindAssisterOrAgent";
import sspType from "@salesforce/label/c.SSP_Type";
import sspSignaturePageLastName from "@salesforce/label/c.SSP_SignaturePageLastName";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspZipCode from "@salesforce/label/c.SSP_ZipCode";
import sspOrganization from "@salesforce/label/c.SSP_Organization";
import sspResults from "@salesforce/label/c.SSP_Results";
import sspFilter from "@salesforce/label/c.SSP_Filter";
import sspFilterOfAppliedFilters from "@salesforce/label/c.sspFilter";
import sspClose from "@salesforce/label/c.SSP_Close";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspResetFilter from "@salesforce/label/c.SSP_ResetFilter";
import sspViewResults from "@salesforce/label/c.SSP_ViewResults";
import sspPrivate from "@salesforce/label/c.SSP_Private";
import sspMondayFriday from "@salesforce/label/c.SSP_MondayFriday";
import sspSaturday from "@salesforce/label/c.SSP_Saturday";
import sspSunday from "@salesforce/label/c.SSP_Sunday";
import sspUnavailable from "@salesforce/label/c.SSP_Unavailable";
import sspViewAssisterDetails from "@salesforce/label/c.SSP_ViewAssisterDetails";
import sspViewAgentDetails from "@salesforce/label/c.SSP_ViewAgentDetails";
import sspShowMore from "@salesforce/label/c.SSP_ViewMore";
import sspAssister from "@salesforce/label/c.SSP_Assister";
import sspAgent from "@salesforce/label/c.SSP_Agent";
import sspSearchPlaceHolder from "@salesforce/label/c.SSP_SearchPlaceholder";
import sspLanguage from "@salesforce/label/c.SSP_LanguageS";
import sspAvailability from "@salesforce/label/c.SSP_Availability";
import sspSortBy from "@salesforce/label/c.SSP_SortBy";
import sspDistance from "@salesforce/label/c.SSP_Distance";
import sspNameAscending from "@salesforce/label/c.SSP_NameAscending";
import sspNameDescending from "@salesforce/label/c.SSP_NameDescending";
import sspQualifications from "@salesforce/label/c.SSP_Qualifications";
import sspPrivateAssister from "@salesforce/label/c.SSP_PrivateAssister";
import sspPublicAssister from "@salesforce/label/c.SSP_PublicAssister";
import sspRegisteredAgent from "@salesforce/label/c.SSP_RegisteredAgent";
import sspSearchBasedOnTheEnteredCriteria from "@salesforce/label/c.SSP_SearchBasedOnTheEnteredCriteria";
import sspFilterTheResults from "@salesforce/label/c.SSP_FilterTheResults";
import sspSeeMoreDetailsAbout from "@salesforce/label/c.SSP_SeeMoreDetailsAbout";
import sspViewFilteredResults from "@salesforce/label/c.SSP_ViewFilteredResults";
import sspClearAllSelectedFilters from "@salesforce/label/c.SSP_ClearAllSelectedFilters";
import sspMiles from "@salesforce/label/c.SSP_Miles";
import sspValidZipCode from "@salesforce/label/c.sspValidZipCode";
import findAgentCancelTitle from "@salesforce/label/c.SSP_FindAgentCancelTitle";
/*Added by kyathi as part of CR*/
import sspFilterModalHelpText from "@salesforce/label/c.SSP_FilterModalHelpText";


export default class sspFindAssisterOrAgent extends utility {
    @api selectedType = "Assister";
    @api applicationId;

    @track dataList = [];
    @track firstName;
    @track lastName;
    @track zipCode;
    @track organization;
    @track showSpinner = false;
    @track hoursList = [];
    @track languageList = [];
    @track selectedHours = [];
    @track selectedLanguages = [];
    @track selectedQualification = [];
    @track respData;
    @track sortByField = "distance";
    // @track sortByField = "";
    //Filter modal code
    @track showModal = false;
    @track isRadio;
    @track isCheckbox;
    @track wrapperList = [];

    @track reference = this;
    @track showDetails = false;
    @track MetaDataListParent;
    @track allowSaveValue;
    @track appliedFilters = 1;
    @track appliedFiltersLabel = "";
    actualData = [];
    actualDataReceived = [];
    recordsPerPage = 10;
    latitude = undefined;
    longitude = undefined;
    reverseSort = false;
    coveredInShow = 0;
    hardReset = false;
    fieldPriority = ["distance"];
    customLabels = {
        sspYourAssisterReps,
        sspFindAssisterOrAgentLabel,
        sspType,
        sspSignaturePageLastName,
        sspFirstName,
        sspZipCode,
        sspOrganization,
        sspResults,
        sspFilter,
        sspClose,
        sspResetFilter,
        sspViewResults,
        sspPrivate,
        sspMondayFriday,
        sspSaturday,
        sspSunday,
        sspCancel,
        sspUnavailable,
        sspViewAssisterDetails,
        sspViewAgentDetails,
        sspShowMore,
        sspAssister,
        sspAgent,
        sspSearchPlaceHolder,
        sspLanguage,
        sspAvailability,
        sspSortBy,
        sspDistance,
        sspNameAscending,
        sspNameDescending,
        sspQualifications,
        sspPrivateAssister,
        sspPublicAssister,
        sspRegisteredAgent,
        sspSearchBasedOnTheEnteredCriteria,
        sspFilterTheResults,
        sspSeeMoreDetailsAbout,
        sspViewFilteredResults,
        sspClearAllSelectedFilters,
        sspMiles,
        sspFilterOfAppliedFilters,
        sspValidZipCode,
        findAgentCancelTitle,
        sspFilterModalHelpText
    };
    /**
     * Method 		: MetadataList.
     *
     * @description 	: The method fetches metadata for validation from framework.
     * @author 		: Kireeti Gora
     **/

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value !== undefined && value !== null) {
            this.MetaDataListParent = value;
        }
    }
    /**
* Method 		: allowSave.
* 
* @description 	: This attribute is part of validation framework which indicates data is valid or not.
* @author 		: Kireeti Gora
 
* */

    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
            //set the toast component
        }
    }
    /**
     * @function : connectedCallback
     * @description : This method is used to request the location of the user on load.
     */
    connectedCallback () {
        this.appliedFiltersLabel =
            sspFilter + " ( " + this.appliedFilters + " )";
        const fieldEntityNameList = [];
        fieldEntityNameList.push("MailingPostalCode,Contact");
        this.getMetadataDetails(fieldEntityNameList, null, "REPS_FAA");
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                this.setPosition.bind(this),
                this.setDefaultPositionForMember.bind(this)
            );
        } else {
            console.error("The browser doesn't support Geolocation.");
        }
    }

    /**
     * @function : setPosition
     * @description : This function sets the latitude and longitude values of user upon getting access.
     * @param {object} userPosition - Coordinates received from the navigator class.
     */
    setPosition = userPosition => {
        if (userPosition.coords !== undefined && userPosition.coords !== null) {
            this.latitude = userPosition.coords.latitude;
            this.longitude = userPosition.coords.longitude;
        } else {
            this.setDefaultPositionForMember();
        }
    };

    /**
     * @function : setDefaultPositionForMember
     * @description : This function sets the latitude and longitude values of user upon rejecting access.
     */
    setDefaultPositionForMember = () => {
        this.longitude = undefined;
        this.latitude = undefined;
    };

    /**
     * @function : sortDataForFilter
     * @description : This function evaluates the sorting criteria and filter criteria.
     */
    sortDataForFilter = () => {
        this.actualData = [];

        for (let i = 0; i < this.actualDataReceived.length; i++) {
            const currentData = this.actualDataReceived[i];
            if (
                currentData.distance !== undefined &&
                currentData.distance !== null &&
                currentData.distance !== ""
            ) {
                currentData.distance = parseFloat(
                    currentData.distance.toFixed(2)
                );
            } else {
                currentData.distance = "";
            }
            if (this.verifyAllFilter(currentData)) {
                this.actualData.push(currentData);
            }
        }
        this.actualData.sort(this.calculateSortOrder.bind(this));
    };

    /**
     * @function : sortSearchDataForFilter
     * @description : This function evaluates the sorting criteria and filter criteria for first time when search happens.
     */
    sortSearchDataForFilter () {
        this.actualData = [];
        let defaultFilters = true; //property to track if default filters are applicable

        for (let i = 0; i < this.actualDataReceived.length; i++) {
            defaultFilters = true;
            const currentData = this.actualDataReceived[i];

            //only check for distance criteria and qualification
            if (
                currentData.distance !== undefined &&
                currentData.distance !== null
            ) {
                currentData.distance = parseFloat(
                    currentData.distance.toFixed(2)
                );
            } else {
                currentData.distance = "";
            }

            if (
                this.selectedType === "Agent" &&
                !currentData.IsSearchEnabled__c
            ) {
                defaultFilters = false;
            }

            if (
                this.selectedType === "Assister" &&
                currentData.InHousePrivateAssister__c
            ) {
                defaultFilters = false;
            }

            if (defaultFilters) {
                this.actualData.push(currentData);
            }
        }

        this.actualData.sort(this.calculateSortOrder.bind(this));
    }

    /**
     * @function : calculateSortOrder
     * @description : This function evaluates and sort the data as per the criteria.
     * @param {object} a - The nth index in array.
     * @param {object} b - The nth + 1 element in the array.
     */
    calculateSortOrder = (a, b) => {
        for (let i = 0; i < this.fieldPriority.length; i++) {
            if (
                a[this.fieldPriority[i]] === null ||
                a[this.fieldPriority[i]] === ""
            ) {
                return 1;
            } else if (
                b[this.fieldPriority[i]] === null ||
                b[this.fieldPriority[i]] === ""
            ) {
                return -1;
            } else if (
                (a[this.fieldPriority[i]] === null &&
                    b[this.fieldPriority[i]] === null) ||
                (a[this.fieldPriority[i]] === "" &&
                    b[this.fieldPriority[i]] === "")
            ) {
                return 0;
            } else if (a[this.fieldPriority[i]] > b[this.fieldPriority[i]]) {
                return this.sortByField.includes("-desc") ? -1 : 1;
            } else if (a[this.fieldPriority[i]] < b[this.fieldPriority[i]]) {
                return this.sortByField.includes("-desc") ? 1 : -1;
            }
        }
        return 0;
    };

    /**
     * @function : handleFirstNameChange
     * @description : This function updates the value of firstName variable.
     * @param {object} event - The event variable provided by JS.
     */
    handleFirstNameChange = event => {
        this.firstName = event.target.value;
    };

    /**
     * @function : handleLastNameChange
     * @description : This function updates the value of lastName variable.
     * @param {object} event - The event variable provided by JS.
     */
    handleLastNameChange = event => {
        this.lastName = event.target.value;
    };

    /**
     * @function : handleZipCodeChange
     * @description : This function updates the value of zipCode variable.
     * @param {object} event - The event variable provided by JS.
     */
    handleZipCodeChange = event => {
        this.zipCode = event.target.value;
    };

    /**
     * @function : handleOrganizationChange
     * @description : This function updates the value of organization variable.
     * @param {object} event - The event variable provided by JS.
     */
    handleOrganizationChange = event => {
        this.organization = event.target.value;
    };

    /**
     * @function : handleSearch
     * @description : This function initiates APEX search as per the parameters.
     */
    handleSearch = () => {
        let elem = {};
        elem = this.template.querySelectorAll(".ssp-applicationInputs");

        this.checkValidations(elem);
        if (this.allowSave) {
            this.showSpinner = true;
            getAgentAndAssister({
                contactType: this.selectedType,
                queryData: {
                    memberId: "",
                    latitude: this.latitude === undefined ? "" : this.latitude,
                    longitude:
                        this.longitude === undefined ? "" : this.longitude,
                    FirstName: this.firstName,
                    LastName: this.lastName,
                    ZipCode: this.zipCode,
                    Organization: this.organization
                }
            })
                .then(data => {
                    this.dataList = [];
                    let lstData = [{}];
                    this.actualDataReceived = [];
                    lstData = data.mapResponse.contactRecords;
                    lstData.forEach(contact => {
                        let objContact = {};
                        objContact = contact.objContact;
                        objContact.accountName = contact.organizationName !== undefined?contact.organizationName:"";
                        objContact.accountDataId = contact.organizationDataId;
                        objContact.accountPhone = contact.organizationPhone;
                        objContact.accountContactId =
                        contact.organizationContactId;
                        objContact.updatedName = contact.FirstName +" "+contact.LastName;
                        objContact.isOrganization = contact.isOrganization;
                        objContact.organizationAddressLine2 = contact.organizationAddressLine2;
                        objContact.organizationAddressLine1 = contact.organizationAddressLine1;
                        objContact.organizationEmail = contact.organizationEmail;
                        this.actualDataReceived.push(objContact);
                    });
                    this.languageList = data.mapResponse.LanguageTypes;
                    this.hoursList = data.mapResponse.HoursTypes;
                    for (let i = 0; i < this.actualDataReceived.length; i++) {
                        this.actualDataReceived[i].hoursList = [];
                        if (
                            this.actualDataReceived[i].HoursAvailableCode__c !==
                            undefined
                        ) {
                            const hoursListContact = this.actualDataReceived[
                                i
                            ].HoursAvailableCode__c.split(";");
                            hoursListContact.forEach(hour => {
                                this.actualDataReceived[i].hoursList.push(
                                    this.hoursList[hour]
                                );
                            });
                        }
                    }
                    if (data.mapResponse.error !== undefined) {
                        console.error(data.mapResponse.error);
                    }
                    this.coveredInShow = 0;
                    this.generateWrapperListForFilter();
                    //this.actualData = this.actualDataReceived; // directly assign result to array before sorting
                    //this.sortDataForFilter(); //commenting this original method call instead calling new function
                    this.sortSearchDataForFilter();
                    this.handleShowMore();
                    //  this.showTable = true;
                    this.showDetails = true;
                    this.resetFilters();
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(error);
                    this.showSpinner = false;
                });
        }
    };

    /**
     * @function : typeSetter
     * @description : This function updates the value of selectedType variable.
     * @param {object} event - The event variable provided by JS.
     */
    typeSetter = event => {
        this.selectedType = event.target.value;
        this.wrapperList = [];
        this.generateWrapperListForFilter();
        this.dataList = [];
        this.actualData = [];
        this.actualDataReceived = [];
    };

    /**
     * @function : handleShowMore
     * @description : This function shows next set of results in the list.
     */
    handleShowMore = () => {
        for (
            let i = 0;
            i < this.recordsPerPage &&
            this.coveredInShow < this.actualData.length;
            i++
        ) {
            const currentData = this.actualData[this.coveredInShow++];
            this.dataList.push({
                id: currentData.Id,
                name: currentData.updatedName,
                distance: currentData.distance,
                hoursList: currentData.hoursList,
                accountName: currentData.accountName,
                private:
                    currentData.InHousePrivateAssister__c &&
                    this.selectedType === "Assister",
                viewDetails: sspSeeMoreDetailsAbout + " " + currentData.Name,
                isRegistered:
                    currentData.IsSearchEnabled__c  &&
                    this.selectedType === "Agent",
                dataId: currentData.accountDataId,
                accountPhone: currentData.accountPhone,
                accountContactId: currentData.accountContactId,
                isOrganization:currentData.isOrganization,
                organizationAddressLine1:currentData.organizationAddressLine1,
                organizationAddressLine2:currentData.organizationAddressLine2,
                organizationEmail:currentData.organizationEmail
            });
        }
    };

    /**
     * @function : verifyAllFilter
     * @description : This function verifies all the filters as per the filter model.
     * @param {object} currentData - The object in nth position in the display list.
     */
    verifyAllFilter = currentData => {
        const sLanguage =
            this.selectedType === "Agent"
                ? currentData.SpokenLanguageCode__c
                : currentData.PreferredLanguageCode__c;
        if (
            this.selectedLanguages !== null &&
            this.selectedLanguages.length > 0 &&
            !this.selectedLanguages.includes(sLanguage)
        ) {
            return false;
        }
        if (
            this.selectedHours.length > 0 &&
            currentData.HoursAvailableCode__c !== undefined
        ) {
            const agentHours = currentData.HoursAvailableCode__c.split(";");
            if (
                this.selectedType === "Agent" &&
                this.selectedHours.filter(value => agentHours.includes(value))
                    .length === 0
            ) {
                return false;
            }
        } else if (
            this.selectedHours.length > 0 &&
            currentData.HoursAvailableCode__c === undefined
        ) {
            return false;
        }
        if (
            this.selectedType === "Agent" &&
            this.selectedQualification.includes("registered") &&
            !currentData.IsSearchEnabled__c
        ) {
            return false;
        }

        if (
            this.selectedType === "Assister" &&
            !(
                this.selectedQualification.includes("public") &&
                !currentData.InHousePrivateAssister__c
            ) &&
            !(
                this.selectedQualification.includes("private") &&
                currentData.InHousePrivateAssister__c 
            )
        ) {
            return false;
        }
        return true;
    };

    /**
     * @function : showTable
     * @description : This function returns if the search result div is shown.
     */
    calculateAppliedFilters = () => {
        let languageApplied = 0;
        let hoursApplied = 0;
        let qualificationApplied = 0;

        if (
            this.selectedLanguages !== null &&
            this.selectedLanguages.length > 0
        ) {
            languageApplied = 1;
        } else if (this.selectedLanguages.length === 0) {
            languageApplied = 0;
        }
        if (this.selectedHours.length > 0 && this.selectedType === "Agent") {
            hoursApplied = 1;
        } else if (
            this.selectedType === "Agent" &&
            this.selectedHours.length === 0
        ) {
            hoursApplied = 0;
        }
        if (this.selectedQualification.length > 0) {
            qualificationApplied = 1;
        } else if (this.selectedQualification.length === 0) {
            qualificationApplied = 0;
        }

        this.appliedFilters =
            this.appliedFilters +
            languageApplied +
            qualificationApplied +
            hoursApplied;
        this.appliedFiltersLabel =
            sspFilter + " ( " + this.appliedFilters + " )";
    };
    /**
     * @function : showTable
     * @description : This function returns if the search result div is shown.
     */
    get showTable () {
        return this.actualDataReceived.length > 0 && this.showDetails;
    }

    /**
     * @function : dataListLength
     * @description : This function returns the length of the received data.
     */
    get dataListLength () {
        return this.actualData.length;
    }

    /**
     * @function : showFilterButton
     * @description : This function returns if the filter button is shown.
     */
    get showFilterButton () {
        return this.actualDataReceived !== undefined;
    }

    /**
     * @function : displayShowMore
     * @description : This function returns if show more button is to be displayed.
     */
    get displayShowMore () {
        return this.coveredInShow < this.actualData.length;
    }

    /**
     * @function : typeOptions
     * @description : This function returns the list type options.
     */
    get typeOptions () {
        return [
            { label: this.customLabels.sspAssister, value: "Assister" },
            { label: this.customLabels.sspAgent, value: "Agent" }
        ];
    }

    /**
     * @function : isAssister
     * @description : This function returns if the assister search is selected right now.
     */
    get isAssister () {
        return this.selectedType === "Assister";
    }

    /**
     * @function : isAgent
     * @description : This function returns if the agent search is selected right now.
     */
    get isAgent () {
        return this.selectedType === "Agent";
    }

    /**
     * @function : searchButtonText
     * @description : This function returns the text for search button.
     */

    /**
     * @function : showFilterModal
     * @description : This function returns of the filter modal is to be displayed.
     */
    get showFilterModal () {
        return this.wrapperList.length > 0;
    }

    /**
     * @function : generateWrapperListForFilter
     * @description : This function generates the wrapper list for filter modal.
     */
    generateWrapperListForFilter = () => {
        if (this.wrapperList.length !== 0 && !this.hardReset) {
            return;
        }
        this.wrapperList = [
            {
                title: this.customLabels.sspSortBy,
                target: "sort",
                optionList: [
                    { label: this.customLabels.sspDistance, value: "distance" },
                    {
                        label: this.customLabels.sspNameAscending,
                        value: "Name"
                    },
                    {
                        label: this.customLabels.sspNameDescending,
                        value: "Name-desc"
                    }
                ],
                type: "Radio",
                isRadio: true,
                isCheckbox: false,
                index: 0,
                show: true
            }
        ];
        const optionList = [];
        Object.keys(this.languageList).forEach(key => {
            optionList.push({
                label: this.languageList[key],
                value: key
            });
            // this.selectedLanguages.push(key);
        });
        this.wrapperList.push({
            title: this.customLabels.sspLanguage,
            target: "language",
            optionList: optionList,
            selectedList: this.selectedLanguages,
            type: "Checkbox",
            isRadio: false,
            isCheckbox: true,
            index: 1,
            show: true
        });

        const hoursOptionList = [];
        Object.keys(this.hoursList).forEach(key => {
            hoursOptionList.push({
                label: this.hoursList[key],
                value: key
            });
            //this.selectedHours.push(key);
        });
        this.wrapperList.push({
            title: this.customLabels.sspAvailability,
            target: "availability",
            optionList: hoursOptionList,
            selectedList: this.selectedHours,
            type: "Checkbox",
            isRadio: false,
            isCheckbox: true,
            index: 2,
            show: this.isAgent
        });

        this.selectedQualification = [/*"private",*/ "public", "registered"];
        /*Modified by kyathi as part of CR*/
        this.wrapperList.push({
            title: this.customLabels.sspQualifications,
            target: "qualification",
            helpText: this.isAgent? null : sspFilterModalHelpText,
            optionList: this.isAgent
                ? [
                      {
                          label: this.customLabels.sspRegisteredAgent,
                          value: "registered"
                      }
                  ]
                : [
                      {
                          label: this.customLabels.sspPrivateAssister,
                          value: "private"
                      },
                      {
                          label: this.customLabels.sspPublicAssister,
                          value: "public"
                      }
                  ],
            selectedList: this.selectedQualification,
            type: "Checkbox",
            isRadio: false,
            isCheckbox: true,
            index: 3,
            show: true
        });
    };

    /**
     * @function : handleFilterChange
     * @description : This function applies re-evaluates filters upon update.
     * @param {object} event - The event variable provided by JS.
     */
    handleFilterChange = event => {
        if (event.target.dataset.target === "sort") {
            this.sortByField = event.detail.value;
            this.fieldPriority = [];
            this.fieldPriority.push(
                this.sortByField.indexOf("-desc") > 1
                    ? this.sortByField.substr(
                          0,
                          this.sortByField.indexOf("-desc")
                      )
                    : this.sortByField
            );
        }
        if (event.target.dataset.target === "language") {
            this.selectedLanguages = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.selectedLanguages;
        }
        if (event.target.dataset.target === "availability") {
            this.selectedHours = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.selectedHours;
        }
        if (event.target.dataset.target === "qualification") {
            this.selectedQualification = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[
                position
            ].selectedList = this.selectedQualification;
        }
    };

    /**
     * @function : openModal
     * @description : Opens the assister agent modal.
     */
    openModal = () => {
        this.showModal = true;
    };

    /**
     * @function : closeModal
     * @description : Closes the assister agent modal.
     */
    closeModal = () => {
        this.showModal = false;
    };

    resetFilters = () => {
        this.hardReset = true;
        this.selectedHours = [];
        this.selectedLanguages = [];
        this.generateWrapperListForFilter();
        this.hardReset = false;
        this.sortByField = "distance";
        this.fieldPriority = ["distance"];
       
    };

    /**
     * @function : applyFilters
     * @description : Initiates the re-evaluation of filter criteria.
     */
    applyFilters = () => {
        this.appliedFilters = 0;
        this.showModal = false;
        this.dataList = [];
        this.coveredInShow = 0;
        this.sortDataForFilter();
        this.handleShowMore();
        this.calculateAppliedFilters();
    };

    /**
     * @function : handleCancel
     * @description : Takes back to the auth reps, agent, assister home screen.
     */
    handleCancel = () => {
        this.dispatchEvent(
            new CustomEvent("cancel", { bubbles: true, composed: true })
        );
    };
    /**
     * @function preventNonNumericInput
     * @description Prevents user from entering invalid key.
     * @param {object} event - Event object to capture key code.
     */
    preventNonNumericInput = event => {
        try {
            if (event.keyCode < 48 || event.keyCode > 57) {
                event.preventDefault();
            }
        } catch (error) {
            console.error("Error in preventNonNumericInput:", error);
        }
    };
}