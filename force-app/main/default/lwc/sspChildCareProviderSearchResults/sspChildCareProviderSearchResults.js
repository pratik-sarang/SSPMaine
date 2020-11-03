/**
 * Component Name : sspChildCareProviderSearchResults.
 * Author: CHFS Development Team.
 * Description: Search/Find the Child Care Provider details.
 * Date: 06/23/2020.
 *
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------.
 CHFS Development Team          07/06/2020
**/
import { LightningElement, track, api, wire } from "lwc";
import sspUtility from "c/sspUtility";
import getChildCareProviderDetails from "@salesforce/apex/SSP_ChildCareProviderSearchController.getChildCareProviderDetails";
import getProviderIdsFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.getProviderIdsFromFavorite";
import isGuest from "@salesforce/apex/SSP_ChildCareProviderSearchController.isGuest";
import sspGetLoggedInUserInfo from "@salesforce/apex/SSP_HeaderCtrl.getLoggedInUserInfo";
import getCurrentAddressDetails from "@salesforce/apex/SSP_FindDCBSOfficeController.getCurrentAddress";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getAddressAutoCompleteLWC from "@salesforce/apex/SSPAddressAutocompleteController.getAddressAutoCompleteLWC";
import addToFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.addToFavorite";
import removeFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.removeFromFavorite";
import getFavoriteCount from "@salesforce/apex/SSP_ChildCareProviderSearchController.getFavoriteCount";
import sspImages from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspFilter from "@salesforce/label/c.SSP_Filter";
import sspFilterTheResults from "@salesforce/label/c.SSP_FilterTheResults";
import sspResults from "@salesforce/label/c.SSP_Results";
import sspMiles from "@salesforce/label/c.SSP_Miles";
import sspSearchPlaceHolder from "@salesforce/label/c.SSP_SearchPlaceholder";
import sspSortBy from "@salesforce/label/c.SSP_SortBy";
import sspDistance from "@salesforce/label/c.SSP_Distance";
import sspAvailability from "@salesforce/label/c.SSP_Availability";
import sspResetFilter from "@salesforce/label/c.SSP_ResetFilter";
import sspViewResults from "@salesforce/label/c.SSP_ViewResults";
import sspViewFilteredResults from "@salesforce/label/c.SSP_ReturnFilterApplied";
import sspClearAllSelectedFilters from "@salesforce/label/c.SSP_ClearAllSelectedFilters";
import sspSearchForProviders from "@salesforce/label/c.SSP_SearchForProviders";
import sspChildCareProviderSearch from "@salesforce/label/c.sspChildCareProviderSearch";
import sspFilterOfAppliedFilters from "@salesforce/label/c.sspFilter";
import sspShowMore from "@salesforce/label/c.sspViewMore";
import sspUseMyCurrentLocation from "@salesforce/label/c.sspUseMyCurrentLocation";
import sspClickUseCurrentLocation from "@salesforce/label/c.sspClickUseCurrentLoc";
import sspChildCareProviderbyLocation from "@salesforce/label/c.sspChildCareLocation";
import sspchildCareProviderbyName from "@salesforce/label/c.SSP_Name";
import sspchildCareProviderbyLicense from "@salesforce/label/c.sspChildCareLicense";
import sspSearchByProviderLabel from "@salesforce/label/c.sspChildCareSearchByProvider";
import sspSearchBy from "@salesforce/label/c.sspChildCareSearchBy";
import searchByLocationText from "@salesforce/label/c.sspChildCareLocationText";
import searchByProviderText from "@salesforce/label/c.sspChildCareProviderText";
import searchByLicenseText from "@salesforce/label/c.sspChildCareLicenseText";
import sspAllStarsDescription from "@salesforce/label/c.sspAllStarsDescription";
import sspAllStarLink from "@salesforce/label/c.sspAllstarLink";
import sspViewMoreDetails from "@salesforce/label/c.sspViewMoreDetails";
import sspAddToFavorites from "@salesforce/label/c.sspAddToFavorites";
import sspBackToCCP from "@salesforce/label/c.sspBackToCCP";
import favoritesLink from "@salesforce/label/c.sspFavoritesLink";
import allStarsLevel from "@salesforce/label/c.sspChildcareAllStarsLevel";
import sspProviderSearchText from "@salesforce/label/c.sspProviderSearchText";
import sspBrowserNotSupport from "@salesforce/label/c.sspBrowserNotSupport";
import sspChildCareProviderName from "@salesforce/label/c.sspChildCareProviderName";
import sspChildCareProviderType from "@salesforce/label/c.sspChildCareProviderType";
import sspChildCareCertified from "@salesforce/label/c.sspChildCareCertified";
import sspChildCareLicensed from "@salesforce/label/c.sspChildCareLicensed";
import sspChildCareInfant from "@salesforce/label/c.sspChildCareInfant";
import sspChildCareToddler from "@salesforce/label/c.sspChildCareToddler";
import sspChildCarePreschool from "@salesforce/label/c.sspChildCarePreschool";
import sspChildCareSchoolAge from "@salesforce/label/c.sspChildCareSchoolAge";
import sspChildCareSpecialNeeds from "@salesforce/label/c.sspChildCareSpecialNeeds";
import sspChildCareNontraditionalCare from "@salesforce/label/c.sspChildCareNontraditionalCare";
import sspChildCareProvidesTransportation from "@salesforce/label/c.sspChildCareProvidesTransportation";
import sspChildCareServices from "@salesforce/label/c.sspChildCareServices";
import sspChildCareLevel4 from "@salesforce/label/c.sspChildCareLevel4";
import sspChildCareLevel3 from "@salesforce/label/c.sspChildCareLevel3";
import sspChildCareLevel2 from "@salesforce/label/c.sspChildCareLevel2";
import sspChildCareLevel1 from "@salesforce/label/c.sspChildCareLevel1";
import sspAllStarModelPopUp1 from "@salesforce/label/c.sspAllStarmodelpopup1";
import sspAllStarModelPopUp2 from "@salesforce/label/c.sspAllStarmodelpopup2";
import sspAllStarModelPopUp3 from "@salesforce/label/c.sspAllStarmodelpopup2_3";
import sspAllStarModelPopUp4 from "@salesforce/label/c.sspAllStarmodelpopup3";
import sspAllStarModelPopUp5 from "@salesforce/label/c.sspAllStarmodelpopup4";
import sspOpenNow from "@salesforce/label/c.sspOpenNow";
import sspPleaseEnterAtLeastOneSearchCriteria from "@salesforce/label/c.SSP_PleaseEnterAtLeastOneSearchCriteria";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import sspWeekMorning from "@salesforce/label/c.sspWeekMorning";
import sspWeekAfternoon from "@salesforce/label/c.sspWeekAfternoon";
import sspWeekEvening from "@salesforce/label/c.sspWeekEvening";
import sspWeekend from "@salesforce/label/c.sspWeekend";
import sspSavedFav from "@salesforce/label/c.sspSavedFav";
import sspRemoveFromFavorites from "@salesforce/label/c.sspRemoveToFavorites";
import SspChildCareSuccess from "@salesforce/label/c.SspChildCareSuccess";
import sspChildCareInspectionHelp from "@salesforce/label/c.sspChildCareInspectionhelp";
import sspChildcareSuspendedHelp from "@salesforce/label/c.sspChildcareSuspendedHelp";
import sspChildcareNoInfo from "@salesforce/label/c.sspChildcareNoInfo";
import sspViewMoreAlt from "@salesforce/label/c.sspViewMoreAlt";
import sspAddToFavoritesAlt from "@salesforce/label/c.sspAddToFavoritesAlt";
import sspRemoveToFavoritesAlt from "@salesforce/label/c.sspRemoveToFavoritesalt";
import sspFavoritesLinkAlt from "@salesforce/label/c.sspFavoritesLinkalt";
import sspBackToCcpAlt from "@salesforce/label/c.sspBackToCCP_Alrt";
import SSPBackDashboard from "@salesforce/label/c.SSPBackDashboard";
import sspBackBenefit from "@salesforce/label/c.sspBackBenefit";
import sspBackDashBoardAlt from "@salesforce/label/c.SSPBackDashboard_alrt";
import sspBackBenefitAlt from "@salesforce/label/c.sspBackBenefit_alrt";
import sspSearchPlaceHolderAlt from "@salesforce/label/c.SSP_SearchPlaceholder_alrt";
import sspFilterAlt from "@salesforce/label/c.SSP_Filter_alrt";
import sspAddressAlt from "@salesforce/label/c.SSP_Address_alrt";
import sspPhoneAlt from "@salesforce/label/c.SSP_phone_alrt";
import sspFavAlt from "@salesforce/label/c.sspFavorities_Alt";
import childcareProviderSuspended from "@salesforce/label/c.sspChildcareProviderSuspended";
import childcareOneOrMoreInspection from "@salesforce/label/c.sspChildcareOneOrMoreInspection";
import sspConstants from "c/sspConstants";
import sspChildcareAddressAlt from "@salesforce/label/c.sspChildcareAddressAlt";
import sspRemovedFromFavorites from "@salesforce/label/c.sspRemovefromFavorites";
import sspClickToCall from "@salesforce/label/c.SSP_ClickToCall";
import sspPleaseSelectSuggestedLocation from "@salesforce/label/c.sspPleaseSelectSuggestedLocation";


export default class SspChildCareProviderSearchResults extends NavigationMixin(
    LightningElement
) {
    @api showSearchOptions;
    @api showTable = false;
    @api origin = null;

    @track reference = this;
    @track showModal = false;
    @track showFilterModal = true;
    @track closeModal = false;
    @track showDetails = false;
    @track favoriteDetails = false;
    @track showFilterButton = false;
    @track isSearchErrorMessage = false;
    @track noResults = false;
    @track showModalWindow = false;
    @track isCitizenUser = false;
    @track showProviderId;


    @track isRadio;
    @track isCheckbox;
    @track selectedProvider;
    @track error;
    @track latitude;
    @track longitude;
    @track ShowFavorite;
    @track ShowFavoriteCount;
    @track sspSearchInput;
    @track sspSearch;
    @track placeResultArray;
    @track modalHeader;
    @track modalBody;
    @track modalFooter;
    @track originPageName;
    @track originPageNameAlt;
    @track showSpinner = false;
	@track isLocationSearchErrorMessage = false;

    @track appliedFilters = 1;
    @track sortByField = "Distance";
    @track appliedFiltersLabel = "";

    @track mapsBaseLink = sspConstants.navigationUrl.mapUrl;
    @track selectedHours = [];
    @track dataList = [];
    @track response = [];
    @track selectedProviderType = [];
    @track selectedServicesType = [];
    @track allStarRange = [];
    @track wrapperList = [];

    actualDataReceived = [];
    actualData = [];

    hardReset = false;
    guestUser = false;
    recordsPerPage = 10;
    coveredInShow = 0;

    fieldPriority = ["Distance"];
    selectedSearchType = "Location";
    _title = this.sspProviderSearchText;

    customLabels = {
        sspCancel,
        sspSearchPlaceHolder,
        sspFilter,
        sspFilterTheResults,
        sspResults,
        sspMiles,
        sspSortBy,
        sspDistance,
        sspAvailability,
        sspResetFilter,
        sspViewResults,
        sspViewFilteredResults,
        sspClearAllSelectedFilters,
        sspSearchForProviders,
        sspChildCareProviderSearch,
        sspShowMore,
        sspUseMyCurrentLocation,
        sspClickUseCurrentLocation,
        sspFilterOfAppliedFilters,
        sspChildCareProviderbyLocation,
        sspchildCareProviderbyName,
        sspchildCareProviderbyLicense,
        sspSearchByProviderLabel,
        sspSearchBy,
        searchByLocationText,
        searchByProviderText,
        searchByLicenseText,
        sspAllStarsDescription,
        sspAllStarLink,
        sspViewMoreDetails,
        sspAddToFavorites,
        sspRemoveFromFavorites,
        sspBackToCCP,
        favoritesLink,
        allStarsLevel,
        sspProviderSearchText,
        sspBrowserNotSupport,
        sspChildCareProviderName,
        sspChildCareProviderType,
        sspChildCareCertified,
        sspChildCareLicensed,
        sspChildCareInfant,
        sspChildCareToddler,
        sspChildCarePreschool,
        sspChildCareSchoolAge,
        sspChildCareSpecialNeeds,
        sspChildCareNontraditionalCare,
        sspChildCareProvidesTransportation,
        sspChildCareServices,
        sspChildCareLevel4,
        sspChildCareLevel3,
        sspChildCareLevel2,
        sspChildCareLevel1,
        sspAllStarModelPopUp1,
        sspAllStarModelPopUp2,
        sspAllStarModelPopUp3,
        sspAllStarModelPopUp4,
        sspAllStarModelPopUp5,
        sspOpenNow,
        sspPleaseEnterAtLeastOneSearchCriteria,
        sspNoResultsFound,
        sspWeekMorning,
        sspWeekAfternoon,
        sspWeekEvening,
        sspWeekend,
        sspSavedFav,
        SspChildCareSuccess,
        sspChildCareInspectionHelp,
        sspChildcareSuspendedHelp,
        sspChildcareNoInfo,
        sspViewMoreAlt,
        sspAddToFavoritesAlt,
        sspRemoveToFavoritesAlt,
        sspFavoritesLinkAlt,
        sspBackToCcpAlt,
        SSPBackDashboard,
        sspBackBenefit,
        sspBackDashBoardAlt,
        sspBackBenefitAlt,
        sspSearchPlaceHolderAlt,
        sspFilterAlt,
        sspAddressAlt,
        sspPhoneAlt,
        sspFavAlt,
        childcareProviderSuspended,
        sspChildcareAddressAlt,
        sspRemovedFromFavorites,
        sspClickToCall,
        sspPleaseSelectSuggestedLocation
    };

    searchIcon = sspImages + "/sspIcons/ic_search@3x.png";
    providerRateIcon = sspIcons + "/sspIcons/ic_star_yellow.png";
    providerNotificationIcon = sspIcons + "/sspIcons/ic_needsreview.png";

    /**
     * @function : connectedCallback
     * @description : This method is used to request the location of the user on load.
     */
    connectedCallback () {
        this.getUserType();
        this.originPageName = this.customLabels.sspBackToCCP;
        this.originPageNameAlt = this.customLabels.sspBackToCcpAlt;
        this.appliedFiltersLabel =
            sspFilter + " ( " + this.appliedFilters + " )";
        this.showSearchOptions = true;
        this.sspSearch = this.customLabels.searchByLocationText;
        this.getProviderIds();
        this.favoriteCount();
        this.backToPageTitle();
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                this.setPosition.bind(this),
                this.setDefaultPositionForMember.bind(this)
            );
        } else {
            console.error(this.customLabels.sspBrowserNotSupport);
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

    // Injects the page reference that describes the current page
    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference.state.origin) {
            //use state.origin
            this.origin = this.currentPageReference.state.origin;
        }
        this.backToPageTitle();
    }

    /**
     * @function : searchOptions
     * @description : This function returns the list type options.
     */
    get searchOptions () {
        return [
            {
                label: this.customLabels.sspChildCareProviderbyLocation,
                value: "Location"
            },
            {
                label: this.customLabels.sspchildCareProviderbyName,
                value: "Provider"
            },
            {
                label: this.customLabels.sspchildCareProviderbyLicense,
                value: "License"
            }
        ];
    }

    /**
     * @function : Location
     * @description : This function returns if the user search is selected Location right now.
     */
    get isSearchTypeLocation () {
        return this.selectedSearchType === "Location";
    }

    /**
     * @function : Provider
     * @description : This function returns if the user search is selected Provider right now.
     */
    get isSearchTypeProvider () {
        return this.selectedSearchType === "Provider";
    }

    /**
     * @function : License
     * @description : This function returns if the user search is selected License right now.
     */
    get isSearchTypeLicense () {
        return this.selectedSearchType === "License";
    }

    /**
     * @function : displayShowMore
     * @description : This function returns if show more button is to be displayed.
     */
    get displayShowMore () {
        return this.coveredInShow < this.actualData.length;
    }

    /**
     * @function : typeSetter
     * @description : This function updates the value of selectedType variable.
     * @param {object} event - The event variable provided by JS.
     */
    searchOptionSetter = event => {
        try {
            this.sspSearchInput = "";
            this.placeResultArray = null;
            this.isSearchErrorMessage = false;
            this.isLocationSearchErrorMessage = false;
            this.selectedSearchType = event.target.value;
            if (this.isSearchTypeLocation) {
                this.sspSearch = this.customLabels.searchByLocationText;
                this.template
                    .querySelector(".ssp-searchField")
                    .classList.add("ssp-look-up-searchIcon");
            }
            if (this.isSearchTypeProvider) {
                this.sspSearch = this.customLabels.searchByProviderText;
                this.template
                    .querySelector(".ssp-searchField")
                    .classList.remove("ssp-look-up-searchIcon");
            }
            if (this.isSearchTypeLicense) {
                this.sspSearch = this.customLabels.searchByLicenseText;
                this.template
                    .querySelector(".ssp-searchField")
                    .classList.remove("ssp-look-up-searchIcon");
            }
        } catch (ex) {
            console.error(ex);
        }
    };

    /**
     * @function : handleInputFocusOrBlur
     * @description : This function is used to close search window when it loses focus.
     */
    handleInputFocusOrBlur () {
        this.isSearchErrorMessage = false;
        this.isLocationSearchErrorMessage = false;
        if (this.template.querySelector(".slds-box")) {
            this.template
                .querySelector(".slds-box")
                .classList.remove("ssp-show");
        }
        if (this.template.querySelector(".ssp-overlayBox")) {
            this.template
                .querySelector(".ssp-overlayBox")
                .classList.remove("ssp-show");
        }
        this.placeResultArray = null;
    }

    /**
     * @function : handleOnChangeAddressInput
     * @description : This function is called when we change values in the search box.
     * @param {object} event - Gets address entered.
     */
    handleOnChangeAddressInput (event) {
        this.isSearchErrorMessage = false;
        this.isLocationSearchErrorMessage = false;
        this.sspSearchInput = event.detail.value;
        const value = event.detail.value;
        this.placeResultArray = null;
        if (value) {
            if (value.length > 2) {
                if (this.selectedSearchType === "Location") {
                    getAddressAutoCompleteLWC({
                        searchKey: JSON.stringify(value)
                    })
                        .then(result => {
                            if (
                                this.sspSearchInput &&
                                this.sspSearchInput.length > 2
                            ) {
                                this.placeResultArray = JSON.parse(result);
                            }
                        })
                        .catch(error => {
                            console.error("error" + JSON.stringify(error));
                            console.error("error" + error);
                        });
                }
            }
        }
    }

    /**
     * @function : Favorite Count
     * @description : This function will get the count of favorite providers from the Favorite object .
     */
    favoriteCount () {
        if (sessionStorage.getItem("guestproviderids")) {
            let guestProviderIds = sessionStorage.getItem("guestproviderids");
            guestProviderIds = Array.from(
                new Set(guestProviderIds.split(","))
            ).toString();
            this.ShowFavoriteCount = guestProviderIds.split(",").length;
        } else {
            getFavoriteCount().then(count => {
                try {
                    this.ShowFavoriteCount = count;
                } catch (e) {
                    console.error(e);
                }
            });
        }
    }
    /*** @function : handleSearch
     * @description : This function initiates APEX search as per the parameters.
     *
     */
    handleSearch = () => {
        this.placeResultArray = null;
        if (this.sspSearchInput === undefined || this.sspSearchInput === "") {
            this.isSearchErrorMessage = true;
            this.isLocationSearchErrorMessage = false;
            return;
        }
        this.showSpinner = true;
        this.showModal = false;
        this.showTable = false;
        //We should not trigger when location selected and longitude and latitude are undefined
        if (this.isSearchTypeLocation === true && (this.longitude === undefined || this.latitude === undefined)) {
            this.showSpinner = false;
            this.isLocationSearchErrorMessage = true;
            return;
        }
        getChildCareProviderDetails({
            queryData: {
                latitude: (this.latitude === undefined || this.isSearchTypeProvider === true || this.isSearchTypeLicense === true) ? "" : this.latitude,
                longitude:
                    (this.longitude === undefined ||
                    this.isSearchTypeProvider === true ||
                    this.isSearchTypeLicense === true)
                        ? ""
                        : this.longitude,
                providerName:
                    this.isSearchTypeProvider === true
                        ? this.sspSearchInput
                        : null,
                licenseNumber:
                    this.isSearchTypeLicense === true
                        ? this.sspSearchInput
                        : null,
                providerIDValues: null,
                isFavoriteSearch: false
            }
        }).then(data => {
            this.latitude = undefined;
            this.longitude = undefined;
            if (data === null) {
                this.showTable = true;
                this.noResults = true;
                this.showFilterButton = false;
                this.actualData = [];
                this.dataList = [];
                this.showSpinner = false;
                return;
            }
            try {
                let response = [{}];
                response = JSON.parse(data);
                this.actualDataReceived = [];
                this.dataList = [];
                response.forEach(provider => {
                    const objProvider = {};
                    objProvider.ProviderId = provider.ProviderId;
                    objProvider.ProviderName = provider.ProviderName;
                    objProvider.ProviderType = provider.ProviderType;
                    objProvider.ProviderStatus = provider.ProviderStatus;
                    objProvider.LocationCountyDescription =
                        provider.LocationCountyDescription;
                    objProvider.LocationAddressLine1 =
                        provider.LocationAddressLine1;
                    objProvider.LocationAddressLine2 =
                        provider.LocationAddressLine2;
                    objProvider.Address =
                        provider.LocationAddressLine1 +
                        (provider.LocationAddressLine2 != null
                            ? provider.LocationAddressLine2
                            : "");
                    objProvider.LocationCity = provider.LocationCity;
                    objProvider.LocationZipCode5 = provider.LocationZipCode5;
                    objProvider.LocationStateDescription =
                        provider.LocationStateDescription;
                    objProvider.Address1 = provider.LocationAddressLine1 + " " + (provider.LocationAddressLine2 != null ? provider.LocationAddressLine2 : "");
                    objProvider.Address2 =provider.LocationCity + " " + provider.LocationStateDescription.trim() + " " + provider.LocationZipCode5;
                    objProvider.addressAlt = sspChildcareAddressAlt +" " + objProvider.Address1 +objProvider.Address2;
                    objProvider.mapsLink = this.mapsBaseLink + objProvider.Address;
                    objProvider.LocationCountyDescription =
                         provider.LocationCountyDescription;
                    objProvider.NumberOfStars = provider.NumberOfStars;
                    objProvider.Distance = provider.Distance;
                    objProvider.PhoneNumber = this.phoneMasked(provider.PhoneNumber);
                    objProvider.phoneHref = this.phoneHref(provider.PhoneNumber);
                    objProvider.phoneTitle = sspClickToCall +" " + objProvider.PhoneNumber;
                    objProvider.Capacity = provider.Capacity;
                    objProvider.IsSubsidyAccepted = "";
                    if (provider.IsSubsidyAccepted == "Y") {
                        objProvider.IsSubsidyAccepted = "Accepted";
                    } else if (provider.IsSubsidyAccepted == "N") {
                        objProvider.IsSubsidyAccepted = "No";
                    } else if (
                        provider.IsSubsidyAccepted == null ||
                        provider.IsSubsidyAccepted == ""
                    ) {
                        objProvider.IsSubsidyAccepted = sspChildcareNoInfo;
                    }
                    objProvider.IsOngoingProcess = false;
                    objProvider.IsProviderStatus = false;
                    objProvider.SuspendText = "";
                    if (
                        (provider.ProviderStatus != null ||
                            provider.ProviderStatus != undefined) &&
                        provider.ProviderStatus.trim() == "SUSPENDED"
                    ) {
                        objProvider.SuspendText = childcareProviderSuspended;
                        objProvider.IsProviderStatus = true;
                    }
                    objProvider.ProcessText = "";
                    if (provider.IsOngoingProcess == "Y") {
                        objProvider.ProcessText = childcareOneOrMoreInspection;
                        objProvider.IsOngoingProcess = true;
                    }
                    objProvider.OnGoingProcessList =
                        provider.OnGoingProcessList;
                    objProvider.IsAcceditationsAvailable = "";
                    if (provider.IsAcceditationsAvailable == "Y") {
                        objProvider.IsAcceditationsAvailable = "Yes";
                    } else if (provider.IsAcceditationsAvailable == "N") {
                        objProvider.IsAcceditationsAvailable = "No";
                    } else if (
                        provider.IsAcceditationsAvailable == null ||
                        provider.IsAcceditationsAvailable == ""
                    ) {
                        objProvider.IsAcceditationsAvailable = sspChildcareNoInfo;
                    }
                    objProvider.IsFoodPermitAvailable = "";
                    if (provider.IsFoodPermitAvailable == "Y") {
                        objProvider.IsFoodPermitAvailable = "Yes";
                    } else if (provider.IsFoodPermitAvailable == "N") {
                        objProvider.IsFoodPermitAvailable = "No";
                    } else if (
                        provider.IsFoodPermitAvailable == null ||
                        provider.IsFoodPermitAvailable == ""
                    ) {
                        objProvider.IsFoodPermitAvailable = sspChildcareNoInfo;
                    }
                    objProvider.Transportation = "";
                    if (provider.Transportation == "Y") {
                        objProvider.Transportation = "Yes";
                    } else if (provider.Transportation == "N") {
                        objProvider.Transportation = "No";
                    } else if (
                        provider.Transportation == null ||
                        provider.Transportation == ""
                    ) {
                        objProvider.Transportation = sspChildcareNoInfo;
                    }
                    objProvider.HoursOfOperationList =
                        provider.HoursOfOperationList;
                    objProvider.ServiceCostList = provider.ServiceCostList;
                    objProvider.InspectionHistoryList = this.processInspectionHistory(
                        provider.InspectionHistoryList
                    );
                    objProvider.ShowFavorite = this.toggleFavorite(
                        provider.ProviderId
                    );
                    objProvider.OpenNow = this.getHoursData(
                        provider.HoursOfOperationList
                    );
                    objProvider.availabilityFilter = this.getHoursFilterData(
                        provider.HoursOfOperationList
                    );
                    objProvider.citizenLogin = this.isCitizenUser;
                    this.actualDataReceived.push(objProvider);
                });

                if (this.actualDataReceived.length > 0) {
                    this.showTable = true;
                    this.noResults = false;
                    this.showFilterButton = true;
                    this.generateWrapperListForFilter();
                    this.coveredInShow = 0;
                    this.searchResultsSort(this.sspSearchInput);
                    this.sortSearchDataForFilter();
                    this.handleShowMore();
                    this.showSpinner = false;
                } 
            } catch (ex) {
                console.error(ex);
            }
        });
    };

    /**
     * @function : processInspectionHistory
     * @description : This function the InspectionHistory details.
     * @param {object} inspectionHistoryList - List - Js event.
     */
    processInspectionHistory = (inspectionHistoryList) => {
        if (inspectionHistoryList != null && inspectionHistoryList.length > 0) {
            inspectionHistoryList.forEach(item => {
                item.PlanOfCorrectionText = "";
                if (
                    item.InspectionType != null ||
                    item.InspectionType != "" ||
                    item.InspectionType != undefined
                ) {
                    item.InspectionType = item.InspectionType.trim();
                }
                if (item.Source != null || item.Source != "") {
                    item.PlanOfCorrectionText = "Plan of Correction.pdf";
                }
                item.FormatedStartDate = this.convertReportDateTime(item.InspectionStartDate);
                item.FormatedEndDate = this.convertReportDateTime(item.InspectionEndDate);
            });
        }
        return inspectionHistoryList;
    };
 /**
     * @function : convertReportDateTime
     * @description : This function the InspectionHistory details.
     * @param {object} passDate - List - Js event.
     */
    convertReportDateTime = (passDate) => {
        if (passDate != null || passDate != "") {
            const date = new Date(passDate);
            let day = date.getDate();
            let month = date.getMonth() + 1;
            let year = date.getFullYear();
            let hours = date.getHours();
            let minutes = date.getMinutes();
            const format = hours >= 12 ? "PM" : "AM";
            hours = hours ? hours : 12;
            minutes = minutes < 10 ? "0" + minutes : minutes;
            month = month < 10 ? "0" + month : month;
            day = day < 10 ? "0" + day : day;
            year = year.toString().substr(-2);
            return month + "/" + day + "/" + year + " " + hours + ":" + minutes + " " + format;
        } return "";
    }   

      /**
     * @function : phoneHref.
     * @description : Method to get the href for the phone field.
     * @param {object} PhoneNumber - List - Js event.
     */
   phoneHref (PhoneNumber) {
        return  `tel:${PhoneNumber}`;
    }

    /**
     * @function : phoneMasked.
     * @description : Method to get masked value for the phone number.
     * @param  {object} providerPhone - List - Js event.
     */
     phoneMasked = (providerPhone) => {
        if (providerPhone === undefined || providerPhone === null || providerPhone === "") {
            return "";
        }
        if ((providerPhone.match(/^\d{3}-\d{3}-\d{4}$/))) {
            return providerPhone;
        }
        const formatted = providerPhone.replace(/\D/g, "").match(/(\d{3})(\d{3})(\d{4})/);
        return (formatted[1] + "-" + formatted[2] + "-" + formatted[3]);
    }

    /**
     * @function : getOpenNow
     * @description : This function to get the current date.
     */
    getOpenNow = () =>
        Date()
            .toLocaleString()
            .substring(0, 3);

    /**
     * @function : getHoursData
     * @description : This function to get the current open time.
     * @param {object} hoursOfOperationList - List - Js event.
     */
    getHoursData = hoursOfOperationList => {
        let hoursList = "";
        const today = this.getOpenNow();
        if (hoursOfOperationList != null && hoursOfOperationList.length > 0) {
            hoursOfOperationList.forEach(data => {
                if (data.Day.includes(today)) {
                    hoursList = data.ServiceTime;
                }
            });
        }
        return hoursList;
    };

    /**
     * @function : toggleFavorite
     * @description : This function to set the  Provider Add/remove  button label  when first time loaded.
     * @param {object} providerId - List - Js event.
     */
    toggleFavorite = providerId => {
        if (
            this.getFavProviderIdList != null ||
            this.getFavProviderIdList != undefined
        ) {
            if (this.getFavProviderIdList.includes(providerId)) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    };

    /**
     * @function : getProviderIds
     * @description : This function to get the  Provider id's  from the favorite object.
     */
    getProviderIds = () => {
        const guestFavID = sessionStorage.getItem("guestproviderids");
        if (guestFavID === null || guestFavID === undefined) {
            getProviderIdsFromFavorite().then(favProviderIds => {
                this.getFavProviderIdList = favProviderIds;
            });
        } else {
            this.getFavProviderIdList = guestFavID;
        }
    };
    /**
     * @function : getHoursFilterData
     * @description : This function show get the weekday and weekend.
     * @param {object} hoursOfOperationList - List - Js event.
     */
    getHoursFilterData = hoursOfOperationList => {
        const weekdays = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday"
        ];
        const weekends = ["Sunday", "Saturday"];
        const hoursFilterList = [];
        if (hoursOfOperationList != null && hoursOfOperationList.length > 0) {
            hoursOfOperationList.forEach(data => {
                if (weekdays.includes(data.Day)) {
                    if (data.ServiceTime.indexOf("AM") > -1) {
                        hoursFilterList.push("Weekday-Morning");
                    }
                    if (data.ServiceTime.indexOf("PM") > -1) {
                        hoursFilterList.push("Weekday-Afternoon");
                        const res = data.ServiceTime.split("-")[1];
                        const matches = res.match(/(\d+)/);
                        if (parseInt(matches[0], 10) > 6) {
                            hoursFilterList.push("Weekday-Evening");
                        }
                    }
                }
                if (weekends.includes(data.Day)) {
                    if (
                        data.ServiceTime.indexOf("AM") > -1 ||
                        data.ServiceTime.indexOf("PM") > -1
                    ) {
                        hoursFilterList.push("Weekend");
                    }
                }
            });
        }
        return Array.from(new Set(hoursFilterList));
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
            this.dataList.push(currentData);
        }
        this.dataListLength = this.actualData.length;
    };

    /**
     * @function : handleSearchResults
     * @description : This function capture the responds of the back to search results button clicked on Provider detail page.
     * @param {object} event - List - Js event.
     */
    handleSearchResults (event) {
        this.showSearchOptions = event.detail.showSearchOptions;
        this.showTable = event.detail.showTable;
        this.showDetails = event.detail.showDetails;
        this.ShowFavoriteCount = event.detail.ShowFavoriteCount;
        this.getFavProviderIdList = event.detail.showProviderId;
        this.resetFavorites();
    }

    /**
     * @function : handleBackToSearchProvider
     * @description : This function navigate the user to Favorite screen to view the list of Favorites.
     */

    handleBackToSearchProvider (event) {
        this.showSearchOptions = event.detail.showSearchOptions;
        this.showTable = event.detail.showTable;
        this.favoriteDetails = event.detail.showDetails;
        this.ShowFavoriteCount = event.detail.ShowFavoriteCount;
        this.getFavProviderIdList = event.detail.updatedProviderIds;
        this.resetFavorites();
    }

    resetFavorites = () => {
        this.actualDataReceived.forEach(item => {
            item.ShowFavorite = this.toggleFavorite(item.ProviderId);
        });

        this.dataList.forEach(item => {
            item.ShowFavorite = this.toggleFavorite(item.ProviderId);
        });
    };

    /**
     * @function : resetFilters
     * @description : Reset all Filters from the filter model!
     */
    resetFilters = () => {
        this.hardReset = true;
        this.selectedProviderType = [];
        this.selectedHours = [];
        this.selectedServicesType = [];
        this.allStarRange = [];
        this.generateWrapperListForFilter();
        this.hardReset = false;
        this.sortByField = "Distance";
        this.fieldPriority = ["Distance"];
        this.applyFilters();
    };

    /**
     * @function : getCurrentLocation
     * @description : Gets current position of the user.
     */
    getCurrentLocation () {
        navigator.geolocation.getCurrentPosition(
            this.success.bind(this),
            this.error
        );
    }

    /**
     * @function : getAddressDetails
     * @description :  Searches the address which user enters in the search box.
     * @param {object} event - Gets address.
     */
    getAddressDetails (event) {
        event.preventDefault();
        const selectedLocation = event.target.dataset.id;
        this.sspSearchInput = selectedLocation;
        if (this.placeResultArray) {
            for (let i = 0; i < this.placeResultArray.length; i++) {
                if (
                    this.placeResultArray[i].formatted_address ===
                    selectedLocation
                ) {
                    const locationObject = this.placeResultArray[i].geometry;
                    if (locationObject) {
                        this.latitude = locationObject.location.lat;
                        this.longitude = locationObject.location.lng;
                    }
                    break;
                }
            }
            this.placeResultArray = null;
        }
    }

    /**
     * @function : showProviderDetails
     * @description : This function shows more details of provider.
     * @param {object} event - List - Js event.
     */
    showProviderDetails = event => {
        this.showSearchOptions = false;
        this.showTable = false;
        this.showDetails = true;
        this.selectedProvider = event.target.value;
        window.scrollTo(0, 0);
    };

    /**
     * @function : searchResultsSort
     * @description : This function shows set of results in the list in a sorted order.
     */
    searchResultsSort () {
        if (this.selectedSearchType === "Location") {
            this.sortByField = "Distance";
            this.fieldPriority = ["Distance"];
        }
        if (
            this.selectedSearchType === "Provider" ||
            this.selectedSearchType === "License"
        ) {
            this.sortByField = "NumberOfStars-desc";
            this.fieldPriority = ["NumberOfStars"];
        }
    }

    /**
     * @function : generateWrapperListForFilter
     * @description : This function shows the Filter model with multiple filter options.
     */
    generateWrapperListForFilter = () => {
        try {
            this.wrapperList = [
                {
                    title: this.customLabels.sspSortBy,
                    target: "sort",
                    optionList: [
                        {
                            label: this.customLabels.sspDistance,
                            value: "Distance"
                        },
                        {
                            label: this.customLabels.allStarsLevel,
                            value: "NumberOfStars-desc"
                        },
                        {
                            label: this.customLabels.sspChildCareProviderName,
                            value: "ProviderName"
                        }
                    ],
                    type: "Radio",
                    isRadio: true,
                    isCheckbox: false,
                    index: 0,
                    show: true
                }
            ];

            const providerOptionList = [];
            providerOptionList.push({
                label: this.customLabels.sspChildCareCertified,
                value: "Certified"
            });
            providerOptionList.push({
                label: this.customLabels.sspChildCareLicensed,
                value: "Licensed"
            });
            this.wrapperList.push({
                title: this.customLabels.sspChildCareProviderType,
                target: "providerType",
                optionList: providerOptionList,
                selectedList: this.selectedProviderType,
                type: "Checkbox",
                isRadio: false,
                isCheckbox: true,
                index: 1,
                show: true
            });

            const hoursOptionList = [];
            hoursOptionList.push({
                label: this.customLabels.sspWeekMorning,
                value: "Weekday-Morning"
            });
            hoursOptionList.push({
                label: this.customLabels.sspWeekAfternoon,
                value: "Weekday-Afternoon"
            });
            hoursOptionList.push({
                label: this.customLabels.sspWeekEvening,
                value: "Weekday-Evening"
            });
            hoursOptionList.push({
                label: this.customLabels.sspWeekend,
                value: "Weekend"
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
                show: true
            });

            const ServicesOptionList = [];
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareInfant,
                value: "Infant"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareToddler,
                value: "Toddler"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCarePreschool,
                value: "Preschool"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareSchoolAge,
                value: "School age"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareSpecialNeeds,
                value: "Special needs"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareNontraditionalCare,
                value: "Nontraditional care"
            });
            ServicesOptionList.push({
                label: this.customLabels.sspChildCareProvidesTransportation,
                value: "Provides transportation"
            });

            this.wrapperList.push({
                title: this.customLabels.sspChildCareServices,
                target: "Services",
                optionList: ServicesOptionList,
                selectedList: this.selectedServicesType,
                type: "Checkbox",
                isRadio: false,
                isCheckbox: true,
                index: 3,
                show: true
            });

            const allStarLevelOptionList = [];
            allStarLevelOptionList.push({
                label: this.customLabels.sspChildCareLevel4,
                value: "4"
            });
            allStarLevelOptionList.push({
                label: this.customLabels.sspChildCareLevel3,
                value: "3"
            });
            allStarLevelOptionList.push({
                label: this.customLabels.sspChildCareLevel2,
                value: "2"
            });
            allStarLevelOptionList.push({
                label: this.customLabels.sspChildCareLevel1,
                value: "1"
            });

            this.wrapperList.push({
                title: this.customLabels.allStarsLevel,
                target: "allStarLevel",
                optionList: allStarLevelOptionList,
                selectedList: this.allStarRange,
                type: "Checkbox",
                isRadio: false,
                isCheckbox: true,
                index: 4,
                show: true
            });
        } catch (e) {
            console.error(e);
        }
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
                currentData.Distance !== undefined &&
                currentData.Distance !== null &&
                currentData.Distance !== ""
            ) {
                currentData.Distance = parseFloat(
                    currentData.Distance.toFixed(2)
                );
            } else {
                currentData.Distance = "";
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
        for (let i = 0; i < this.actualDataReceived.length; i++) {
            const currentData = this.actualDataReceived[i];
            //only check for distance criteria
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

            this.actualData.push(currentData);
        }
        this.actualData.sort(this.calculateSortOrder.bind(this));
    }

    isEligible (value) {
        if (value !== null || value !== "" || value !== undefined) {
            return value;
        }
    }

    /**
     * @function : verifyAllFilter
     * @description : This function verifies all the filters as per the filter model.
     * @param {object} currentData - The object in nth position in the display list.
     */
    verifyAllFilter = currentData => {
        try {
            if (
                this.selectedProviderType.length > 0 &&
                currentData.ProviderType !== undefined
            ) {
                if (
                    this.selectedProviderType.filter(value =>
                        currentData.ProviderType.includes(value)
                    ).length === 0
                ) {
                    return false;
                }
            }

            if (
                this.allStarRange.length > 0 &&
                currentData.NumberOfStars !== undefined
            ) {
                if (
                    this.allStarRange.filter(
                        value => currentData.NumberOfStars >= value
                    ).length === 0
                ) {
                    return false;
                }
            }
            if (
                this.selectedServicesType.length > 0 &&
                currentData.ServiceCostList !== undefined
            ) {
                if (
                    currentData.ServiceCostList === null ||
                    this.selectedServicesType.filter(value =>
                        currentData.ServiceCostList[0].AgeGroup.includes(value)
                    ).length === 0
                ) {
                    return false;
                }
            }

            if (
                this.selectedHours.length > 0 &&
                currentData.availabilityFilter !== undefined
            ) {
                if (
                    this.selectedHours.filter(value =>
                        currentData.availabilityFilter.includes(value)
                    ).length === 0
                ) {
                    return false;
                }
            }
            return true;
        } catch (ex) {
            console.error(ex);
        }
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
        if (event.target.dataset.target === "providerType") {
            this.selectedProviderType = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.selectedProviderType;
        }
        if (event.target.dataset.target === "availability") {
            this.selectedHours = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.selectedHours;
        }
        if (event.target.dataset.target === "Services") {
            this.selectedServicesType = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.selectedServicesType;
        }
        if (event.target.dataset.target === "allStarLevel") {
            this.allStarRange = event.detail.value;
            const position = event.target.dataset.position;
            this.wrapperList[position].selectedList = this.allStarRange;
        }
    };

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
     * @function : calculateAppliedFilters
     * @description : This function calculate all the filters applied in the filter model.
     */
    calculateAppliedFilters = () => {
        try {
            let ProviderTypeApplied = 0;
            let hoursApplied = 0;
            let ServicesTypeApplied = 0;
            let allStarRangeApplied = 0;
            if (
                this.selectedProviderType !== null &&
                this.selectedProviderType.length > 0
            ) {
                ProviderTypeApplied = 1;
            } else if (this.selectedProviderType.length === 0) {
                ProviderTypeApplied = 0;
            }
            if (this.selectedHours.length > 0) {
                hoursApplied = 1;
            } else if (this.selectedHours.length === 0) {
                hoursApplied = 0;
            }
            if (this.selectedServicesType.length > 0) {
                ServicesTypeApplied = 1;
            } else if (this.selectedServicesType.length === 0) {
                ServicesTypeApplied = 0;
            }
            if (this.allStarRange.length > 0) {
                allStarRangeApplied = 1;
            } else if (this.allStarRange.length === 0) {
                allStarRangeApplied = 0;
            }
            this.appliedFilters =
                this.appliedFilters +
                ProviderTypeApplied +
                ServicesTypeApplied +
                hoursApplied +
                allStarRangeApplied;
            this.appliedFiltersLabel =
                sspFilter + " ( " + this.appliedFilters + " )";
        } catch (ex) {
            console.error("calculateAppliedFilters: " + ex);
        }
    };

    /**
     * @function : applyFilters
     * @description : Initiates the re-evaluation of filter criteria.
     */
    applyFilters = () => {
        this.appliedFilters = 1;
        this.showModal = false;
        this.dataList = [];
        this.coveredInShow = 0;
        this.showTable = true;
        this.sortDataForFilter();
        this.handleShowMore();
        this.calculateAppliedFilters();
        this.showSpinner = false;
    };

    /**
     * @function : viewToFavoritesList
     * @description : This function navigate the user to Favorite screen to view the list of Favorites.
     */
    viewToFavoritesList = () => {
        this.showSearchOptions = false;
        this.showTable = false;
        this.favoriteDetails = true;
    };

    /**
     * @function : getUserType
     * @description : This function verify the user is Guest or valid user.
     */
    getUserType = () => {
        isGuest().then(response => {
            this.guestUser = response;
            this.isCitizenUser = true;
             if (!this.guestUser) {
				sspGetLoggedInUserInfo().then((result) => {
					if (result && result.mapResponse) {
						const loggedInUserProfile =
							result.mapResponse.userDetails.userProfile;
						const loggedInSelectedRole =
							result.mapResponse.userDetails.selectedRole;
						if (loggedInUserProfile === sspConstants.profileNames.citizen) {
							this.isCitizenUser = true;
						} else if (
							loggedInUserProfile === sspConstants.profileNames.nonCitizen &&
							loggedInSelectedRole === sspConstants.userRole.Citizen_Individual
						) {
							this.isCitizenUser = true;
						} else {
							this.isCitizenUser = false;
						}
					}
				});
            }
        });
    };
    /**
     * @function : handleFavorites
     * @description : Handle favorites Add or Remove function.
     * @param {object} event - List - Js event.
     */
    handleFavorites (event) {
        const selectedProviderId = event.target.dataset.id;
        const selectedProviderName = event.target.dataset.name;
        if (event.target.value == "AddToFavorites") {
            try {
                //start add
                if (this.guestUser) {
                    if (sessionStorage.getItem("guestproviderids")) {
                        let guestProviderIds =
                            sessionStorage.getItem("guestproviderids") +
                            "," +
                            selectedProviderId;
                        guestProviderIds = Array.from(
                            new Set(guestProviderIds.split(","))
                        ).toString();
                        this.ShowFavoriteCount = guestProviderIds.split(
                            ","
                        ).length;
                        sessionStorage.setItem(
                            "guestproviderids",
                            guestProviderIds
                        );
                    } else {
                        sessionStorage.setItem(
                            "guestproviderids",
                            selectedProviderId
                        );
                        this.ShowFavoriteCount = 1;
                    }
                } else {
                    addToFavorite({ providerId: selectedProviderId }).then(
                        result => {
                            this.favoriteCount();
                        }
                    );
                }
                // end add
                event.target.label = this.customLabels.sspRemoveFromFavorites;
                event.target.value = "RemoveFromFavorites";
                this.showToast(
                    this.customLabels.SspChildCareSuccess,
                    selectedProviderName+ "\n" +this.customLabels.sspSavedFav,
                    "success"
                );
            } catch (error) {
                console.error(this.error);
            }
        } else if (event.target.value == "RemoveFromFavorites") {
            try {
                if (this.guestUser) {
                    if (sessionStorage.getItem("guestproviderids")) {
                        let guestProviderIds = sessionStorage.getItem(
                            "guestproviderids"
                        );
                        const separator = ",";
                        const values = guestProviderIds.split(separator);
                        for (let i = 0; i < values.length; i++) {
                            if (values[i] == selectedProviderId) {
                                values.splice(i, 1);
                                guestProviderIds = values.join(separator);
                            }
                        }
                        sessionStorage.setItem(
                            "guestproviderids",
                            guestProviderIds
                        );
                        this.ShowFavoriteCount =
                            guestProviderIds === ""
                                ? 0
                                : guestProviderIds.split(",").length;
                    }
                } else {
                    removeFromFavorite({ providerId: selectedProviderId }).then(
                        result => {
                            this.favoriteCount();
                        }
                    );
                }
                // end remove
                event.target.label = this.customLabels.sspAddToFavorites;
                event.target.value = "AddToFavorites";
                this.showToast(
                    this.customLabels.SspChildCareSuccess,
                    selectedProviderName+ "\n" +this.customLabels.sspRemovedFromFavorites,
                    "success"
                );
            } catch (error) {
                console.error(this.error);
            }
        } 
        this.favoriteItems(selectedProviderId);
    }
    /**
     * @function : favoriteItems
     * @description : maintain the changes!
     * @param {object} providerId - List - Js event.
     */
    favoriteItems = providerId => {
        this.actualDataReceived.forEach(item => {
            if (item.ProviderId == providerId) {
                item.ShowFavorite = !item.ShowFavorite;
            }
        });

        this.generateWrapperListForFilter();
    };

    /**
     * @function : openModal
     * @description : Opens the filter modal.
     */
    openModal = () => {
        this.showModal = true;
    };

    /**
     * @function : closeModal
     * @description : Closes the filter modal.
     */
    closeModal = () => {
        this.showModal = false;
    };

    /**
     * @function : showToast
     * @description : function to call the Toast message.
     * @param {object} title - Js event.
     * @param {object} message - Js event.
     * @param {object} variant - Js event.
     */
    showToast (title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    /**
     * @function : success
     * @description : Update the map marker.
     * @param {object} position - Gets current position.
     */
    success (position) {
        if (position) {
            this.latitude = position.coords.latitude;
            this.longitude = position.coords.longitude;
            //calling method to get current address from current lat long
            this.getCurrentAddress();
        }
    }

    /**
     * @function : error
     * @description : Called when there is an error.
     */
    error () {
        console.error("Failed");
    }

    /**
     * @function : getCurrentAddress
     * @description : Gets current location.
     */
    getCurrentAddress () {
        if (
            this.latitude !== undefined &&
            this.latitude !== null &&
            this.longitude !== undefined &&
            this.longitude !== null
        ) {
            getCurrentAddressDetails({
                lat: this.latitude,
                lng: this.longitude
            })
                .then(result => {
                    const parsedData = result.mapResponse;
                    if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        if (parsedData.hasOwnProperty("formattedAddress")) {
                            this.sspSearchInput = parsedData.formattedAddress;
                            this.isLocationSearchErrorMessage = false;
                        }
                    }
                })
                .catch(error => {
                    console.error("Error : " + JSON.stringify(error));
                });
        }
    }

    /**
     * @function 		: backToPageTitle.
     * @description 	: method for back To PageTitle and alt text!
     **/
    backToPageTitle () {
        if (this.origin === "program-page" || this.origin === "") {
            this.originPageName = this.customLabels.sspBackToCCP;
            this.originPageNameAlt = this.customLabels.sspBackToCcpAlt;
        }
        if (this.origin === "benefits-page") {
            this.originPageName = "<" + this.customLabels.sspBackBenefit;
            this.originPageNameAlt = this.customLabels.sspBackBenefitAlt;
        }
        if (this.origin === "dashboard") {
            this.originPageName = "<" + this.customLabels.SSPBackDashboard;
            this.originPageNameAlt = this.customLabels.sspBackDashBoardAlt;
        }
    }

    /**
     * @function 		: handleChildCareSearch.
     * @description 	: method for handleChildCareSearch with Navigation Mix function.
     **/
    handleChildCareSearch = () => {
        try {
            if (this.origin === "program-page" || this.origin === "") {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: this.origin
                    },
                    state: {
                        program: sspConstants.programs.CCAP
                    }
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: this.origin
                    }
                });
            }
        } catch (error) {
            console.error(
                "failed in handleChildCareSearch in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: allStarLinkClick.
     * @description 	: method to display the model Popup.
     **/
    allStarLinkClick = () => {
        this.showModalWindow = true;
        this.modalHeader = this.customLabels.allStarsLevel;
        this.modalBody =
            this.customLabels.sspAllStarModelPopUp1 +
            "\n" +
            this.customLabels.sspAllStarModelPopUp2 +
            "\n" +
            this.customLabels.sspAllStarModelPopUp3 +
            "\n" +
            this.customLabels.sspAllStarModelPopUp4 +
            "\n" +
            this.customLabels.sspAllStarModelPopUp5;
        this.modalFooter = " ";
    };

    /**
     * @function 		: handleCloseModal.
     * @description 	: method to close the model Popup.
     **/
    handleCloseModal = () => {
        this.showModalWindow = false;
    };
}