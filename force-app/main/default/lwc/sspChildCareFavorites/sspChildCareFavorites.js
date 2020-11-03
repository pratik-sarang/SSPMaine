/**
 * Component Name: sspChildCareFavorites.
 * Author: CHFS Development team.
 * Description: Search/Find the Child Care Provider favorites.
 * Date: 06/23/2020.
 * * MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* --------------------------------------------------------------------------------------------.
 CHFS Development Team          07/06/2020.
**/
import { LightningElement,track,api } from "lwc";
import getChildCareProviderDetails from "@salesforce/apex/SSP_ChildCareProviderSearchController.getChildCareProviderDetails";
import isGuest from "@salesforce/apex/SSP_ChildCareProviderSearchController.isGuest";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import getProviderIdsFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.getProviderIdsFromFavorite";
import removeFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.removeFromFavorite";
import getFavoriteCount from "@salesforce/apex/SSP_ChildCareProviderSearchController.getFavoriteCount";
import sspMiles from "@salesforce/label/c.SSP_Miles";
import sspAddToFavorites from "@salesforce/label/c.sspAddToFavorites";
import sspRemoveFromFavorites from "@salesforce/label/c.sspRemoveToFavorites";
import allStarsLevel from "@salesforce/label/c.sspChildcareAllStarsLevel";
import sspViewMoreDetails from "@salesforce/label/c.sspViewMoreDetails";
import favoritesLink from "@salesforce/label/c.sspFavoritesLink";
import sspBackToSearchProviders from "@salesforce/label/c.sspbacktosearchProviders";
import sspOpenNow from "@salesforce/label/c.sspOpenNow";
import SSP_NORESULTSFOUND from "@salesforce/label/c.SSP_NoResultsFound";
import sspViewMoreAlt from "@salesforce/label/c.sspViewMoreAlt";
import sspRemoveToFavoritesalt from "@salesforce/label/c.sspRemoveToFavoritesalt";
import sspBackToSearchProvidersAlt from "@salesforce/label/c.sspbacktosearchProviders_alrt";
import sspChildCareInspectionHelp from "@salesforce/label/c.sspChildCareInspectionhelp";
import sspChildcareSuspendedHelp from "@salesforce/label/c.sspChildcareSuspendedHelp";
import childcareProviderSuspended from "@salesforce/label/c.sspChildcareProviderSuspended";
import childcareOneOrMoreInspection from "@salesforce/label/c.sspChildcareOneOrMoreInspection";
import sspChildcareNoInfo from "@salesforce/label/c.sspChildcareNoInfo";
import SspChildCareSuccess from "@salesforce/label/c.SspChildCareSuccess";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import sspRemovedFromFavorites from "@salesforce/label/c.sspRemovefromFavorites";
import sspChildcareAddressAlt from "@salesforce/label/c.sspChildcareAddressAlt";
import sspConstants from "c/sspConstants";
import sspClickToCall from "@salesforce/label/c.SSP_ClickToCall";

export default class sspChildCareFavorites extends LightningElement {
    
    @api showSearchOptions;
    @api showTable;
    @api FavoriteDetails;


    @track latitude;
    @track longitude;
    @track showSpinner = false;
    @track noResults = false;
    
    @track showFavoriteItems;
    @track getFavProviderIdList;
    @track showProviderId;
    @track mapsBaseLink = sspConstants.navigationUrl.mapUrl;
    
    @track dataList = [];

    actualFavItems =[];
    ShowFavoriteCount = 0;
    guestUser = false;

    customLabels = {
      sspMiles,
      sspAddToFavorites,
      sspRemoveFromFavorites,
      allStarsLevel,
      sspViewMoreDetails,
      favoritesLink,
      sspBackToSearchProviders,
      sspOpenNow,
      SSP_NORESULTSFOUND,
      sspViewMoreAlt,
      sspRemoveToFavoritesalt,
      sspBackToSearchProvidersAlt,
      sspChildCareInspectionHelp,
      sspChildcareSuspendedHelp,
      childcareProviderSuspended,
      childcareOneOrMoreInspection,
      sspChildcareNoInfo,
      SspChildCareSuccess,
      sspRemovedFromFavorites,
      sspChildcareAddressAlt,
      sspClickToCall
    }
   
    providerRateIcon = sspIcons + "/sspIcons/ic_star_yellow.png";
    providerNotificationIcon = sspIcons + "/sspIcons/ic_needsreview.png";
    /**
     * @function : connectedCallback
     * @description : This method is used to request the location of the user on load.
     */
  connectedCallback () {
    this.getUserType();
    this.showFavoriteItems = true;
    this.getProviderIds();
    this.favoriteCount();
  }

  /**
     * @function : getUserType
     * @description : This function verify the user is Guest or valid user.
    */
      getUserType = () => {
        try{
        isGuest().then(response => {
          this.guestUser = response;
        })
      } 
      catch(e){
        console.error(e);
      }
      }

   /**
     * @function : getProviderIds
     * @description : This function to get the  Provider id's  from the favorite object.
     */
    getProviderIds = () => {
        const guestFaIDs = sessionStorage.getItem("guestproviderids");
      if( guestFaIDs === null || guestFaIDs === undefined) {
      getProviderIdsFromFavorite().then(favproviderIds => {
          this.getFavProviderIdList = favproviderIds;
          this.displayResults();
      });   
     }else {
      this.getFavProviderIdList = guestFaIDs;
          this.displayResults();
     }
     
  }
     
/**
     * @function : backtosearchProd
     * @description : This method is used to back to provider search results.
     */

    backtosearchProd () {
      // Creates the event with the data.
      //const guestProviderIds = sessionStorage.getItem("guestproviderids");
      this.favoriteCount();
      const selectedEvent1 = new CustomEvent("backtosearchprovider", {
        detail: { showSearchOptions : true,
        showTable : true,
        FavoriteDetails : false,
        ShowFavoriteCount : this.ShowFavoriteCount,
        updatedProviderIds: this.getFavProviderIdList     
        }
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent1);
    }
    
    /**
     * @function :     displayResults
     * @description : This method is used to call the Apex method to get three results.
     */
    displayResults = () => {
      this.showSpinner = true;
      const guestProviderIds = sessionStorage.getItem("guestproviderids");
        this.actualFavItems = [];
        getChildCareProviderDetails({ queryData: {
          latitude: this.latitude === undefined ? "" : this.latitude,
          longitude : this.longitude === undefined ? "" : this.longitude,
          providerName: null,
          licenseNumber: null,
          providerIDValues: guestProviderIds === null ? this.getFavProviderIdList : guestProviderIds,
          isFavoriteSearch :true
        }}).then(data => {
          if (data === null) {
            this.noResults = true;
            this.actualFavItems = [];
            this.dataList = [];
            this.showSpinner = false;
            return;
         }
         try {
             let response = [{}];
             response = JSON.parse(data);
             this.dataList = [];
             response.forEach(provider => {
                 const objProvider = {};
                 objProvider.ProviderId = provider.ProviderId;
                 objProvider.ProviderName = provider.ProviderName;
                 objProvider.ProviderType = provider.ProviderType;
                 objProvider.ProviderStatus = provider.ProviderStatus;
                 objProvider.LocationCountyDescription = provider.LocationCountyDescription;
                 objProvider.LocationAddressLine1 = provider.LocationAddressLine1;
                 objProvider.LocationAddressLine2 = provider.LocationAddressLine2;
                 objProvider.LocationCity = provider.LocationCity;
                 objProvider.LocationZipCode5 = provider.LocationZipCode5;
                 objProvider.LocationStateDescription = provider.LocationStateDescription;
                 objProvider.Address1 = provider.LocationAddressLine1 + " " + (provider.LocationAddressLine2 != null ? provider.LocationAddressLine2 : "");
                 objProvider.Address2 =provider.LocationCity + " " + provider.LocationStateDescription.trim() + " " + provider.LocationZipCode5;
                 objProvider.addressAlt = sspChildcareAddressAlt +" " + objProvider.Address1 +objProvider.Address2;
                 objProvider.mapsLink = this.mapsBaseLink + objProvider.Address;
                 objProvider.LocationCountyDescription = provider.LocationCountyDescription;
                 objProvider.NumberOfStars= provider.NumberOfStars;
                 objProvider.Distance = provider.Distance;
                 objProvider.PhoneNumber = this.phoneMasked(provider.PhoneNumber);
                 objProvider.phoneHref = this.phoneHref(provider.PhoneNumber);
                 objProvider.phoneTitle = sspClickToCall +" " + objProvider.PhoneNumber;
                 objProvider.Capacity = provider.Capacity;
                 objProvider.IsSubsidyAccepted = "";
                 if (provider.IsSubsidyAccepted == "Y") {
                     objProvider.IsSubsidyAccepted = "Accepted";
                 }
                 else if (provider.IsSubsidyAccepted == "N") {
                     objProvider.IsSubsidyAccepted = "No";
                 }else if(provider.IsSubsidyAccepted == null || provider.IsSubsidyAccepted == ""){
                  objProvider.IsSubsidyAccepted =sspChildcareNoInfo;
                }
                 objProvider.IsOngoingProcess = false;
                 objProvider.IsProviderStatus = false;
                 objProvider.IsAcceditationsAvailable = "";
                    if (provider.IsAcceditationsAvailable == "Y") {
                        objProvider.IsAcceditationsAvailable = "Yes";
                    }
                    else if (provider.IsAcceditationsAvailable == "N") {
                        objProvider.IsAcceditationsAvailable = "No";
                    }
                    else if(provider.IsAcceditationsAvailable == null || provider.IsAcceditationsAvailable == ""){
                        objProvider.IsAcceditationsAvailable =sspChildcareNoInfo;
                    }
                 objProvider.SuspendText = "";
                 if ((provider.ProviderStatus != null || provider.ProviderStatus != undefined) &&
                     provider.ProviderStatus.trim() == "SUSPENDED") {
                     objProvider.SuspendText = childcareProviderSuspended;
                     objProvider.IsProviderStatus = true;
                 }
                 objProvider.ProcessText = "";
                 if (provider.IsOngoingProcess == "Y") {
                     objProvider.ProcessText = childcareOneOrMoreInspection;
                     objProvider.IsOngoingProcess = true;
                 }
                 objProvider.OnGoingProcessList = provider.OnGoingProcessList;
                 objProvider.IsFoodPermitAvailable = "";
                 if (provider.IsFoodPermitAvailable == "Y") {
                     objProvider.IsFoodPermitAvailable = "Yes";
                 }
                 else if (provider.IsFoodPermitAvailable == "N") {
                     objProvider.IsFoodPermitAvailable = "No";
                 }
                 else if(provider.IsFoodPermitAvailable == null || provider.IsFoodPermitAvailable == ""){
                     objProvider.IsFoodPermitAvailable =sspChildcareNoInfo;
                 }
                 objProvider.Transportation = "";
                 if (provider.Transportation == "Y") {
                     objProvider.Transportation = "Yes";
                 }
                 else if (provider.Transportation == "N") {
                     objProvider.Transportation = "No";
                 }else if(provider.Transportation == null || provider.Transportation == ""){
                     objProvider.Transportation =sspChildcareNoInfo;
                 }
                 objProvider.HoursOfOperationList = provider.HoursOfOperationList;
                 objProvider.ServiceCostList = provider.ServiceCostList;
                 objProvider.InspectionHistoryList = this.processInspectionHistory(provider.InspectionHistoryList);
                 objProvider.OpenNow = this.getHoursData(provider.HoursOfOperationList);
                 objProvider.availabilityFilter = this.getHoursFilterData(provider.HoursOfOperationList);
                 objProvider.isRender = true;
                 objProvider.ShowFavorite = this.toggleFavorite(provider.ProviderId);
                 this.actualFavItems.push(objProvider);
             });
            this.dataList = this.actualFavItems;
            this.noResults = false;
             this.showSpinner = false;
         } catch (ex) {
             console.error(ex);
         }
     });
 }

   /**
     * @function : toggleFavorite
     * @description : This function to set the  Provider Add/remove  button label  when first time loaded.
     * @param {object} providerId - Js event.
     */
    toggleFavorite = (providerId) => {
      if(this.getFavProviderIdList != null || this.getFavProviderIdList != undefined){
        if ( this.getFavProviderIdList.includes(providerId)) {
            return true;
        } else {
            return false;
        }
      }
      return false;
    }

 /**
     * @function : processInspectionHistory
     * @description : This function the InspectionHistory details.
     * @param {object} inspectionHistoryList - Js event.
     */
 processInspectionHistory = (inspectionHistoryList) => {
  if(inspectionHistoryList != null && inspectionHistoryList.length > 0){
      inspectionHistoryList.forEach(item => {
          item.PlanOfCorrectionText = "";
          if (item.InspectionType != null || item.InspectionType != "" || item.InspectionType != undefined) {
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
}

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
    getOpenNow = () => Date().toLocaleString().substring(0, 3) 

    /**
   * @function : getHoursData
   * @description : This function to get the current open time.
   * @param {object} hoursOfOperationList - Js event.
   */
  getHoursData = (hoursOfOperationList) => {
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
  }


  /**
    * @function : getHoursFilterData
    * @description : This function show get the weekday and weekend.
    * @param {object} hoursOfOperationList - Js event.
    */
   getHoursFilterData = (hoursOfOperationList) => {
    const weekdays = ["Monday","Tuesday","Wednesday","Thursday","Friday"];
    const weekends = ["Sunday","Saturday"];
    const hoursFilterList = [];
    if (hoursOfOperationList != null && hoursOfOperationList.length > 0) {            
         hoursOfOperationList.forEach(data => {
           if (weekdays.includes(data.Day)) {
   
             if (data.ServiceTime.indexOf("AM") > -1){
                hoursFilterList.push("Weekday-Morning");
             }
             if (data.ServiceTime.indexOf("PM") > -1){
                hoursFilterList.push("Weekday-Afternoon");
              const res = data.ServiceTime.split("-")[1];
              const matches = res.match(/(\d+)/); 
              if (parseInt(matches[0], 10) > 6){
                hoursFilterList.push("Weekday-Evening"); 
              }
            }
          } 
           if (weekends.includes(data.Day)) {
               if (data.ServiceTime.indexOf("AM") > -1 || data.ServiceTime.indexOf("PM") > -1 ){
                hoursFilterList.push("Weekend");
               }
           }
          
        });
    }
    return Array.from(new Set(hoursFilterList));
}

  /**
     * @function : showProviderDetails
     * @description : This function shows more details of provider.
     * @param {object} event - Js event.
     */
    showProviderDetails = (event) =>{ 
      this.showFavoriteItems =false;
      this.showDetails= true;
      this.selectedProvider=event.target.value;
    }

    /**
 * @function : handleSearchResults
 * @description : This function capture the responds of the back to search results button clicked on Provider detail page.
 * @param {object} event - Js event.
 */
    
handleSearchResultsFav (event) {
  this.showFavoriteItems=event.detail.showSearchOptions;
  this.showDetails= event.detail.showDetails;
  this.ShowFavoriteCount = event.detail.ShowFavoriteCount;
  this.getFavProviderIdList = event.detail.showProviderId;
  this.displayResults();
}


   /**
     * @function : handleFavorites
     * @description : This function is to remove the cards.
	   * @param {object} event - List - Js event.
     */
  handleFavorites (event) {
      const selectedProviderId = event.target.dataset.id;
      const selectedProviderName = event.target.dataset.name;
    try {
      if (this.guestUser) {
        if (sessionStorage.getItem("guestproviderids")) {
          let guestProviderIds = sessionStorage.getItem("guestproviderids");
          const separator = ",";
          const values = guestProviderIds.split(separator);
          for (let i = 0; i < values.length; i++) {
            if (values[i] == selectedProviderId) {
              values.splice(i, 1);
              guestProviderIds = values.join(separator);
            }
          }
          sessionStorage.setItem("guestproviderids", guestProviderIds);
          this.ShowFavoriteCount = guestProviderIds === "" ? 0 : guestProviderIds.split(",").length;
          this.reRenderFavItems(selectedProviderId);
        }
      }
      else {
        try {
          removeFromFavorite({ providerId: selectedProviderId })
            .then(result => {
              this.reRenderFavItems(selectedProviderId);
              this.favoriteCount();
            })
            this.showToast(
                this.customLabels.SspChildCareSuccess,
                selectedProviderName+ "\n" +this.customLabels.sspRemovedFromFavorites,
                "success"
            );
        } catch (error) {
          console.error(this.error);
        }
      }

    } catch (error) {
      console.error(this.error);
    }
    this.favoriteItems(selectedProviderId);
  }

  /**
     * @function : favoriteItems
     * @description : maintain the changes! 
     * @param {object} providerId - Js event.
    */
   favoriteItems = (providerId) => {
    this.actualDataReceived.forEach(item => {
        if(item.ProviderId == providerId){
            item.ShowFavorite = !item.ShowFavorite;
        }
    });

    this.generateWrapperListForFilter();
}
  
   /**
     * @function : reRenderFavItems
     * @description : This function is to reRender FavItems after remove the provider card.
     * @param {object} providerId - Js event.
     */
  reRenderFavItems (providerId) {
    this.dataList = [];
    this.actualFavItems.forEach(function (dataItem) {
      if (dataItem.ProviderId == providerId) {
        dataItem.isRender = false;
        dataItem.ShowFavorite = false;
      }
    });
    this.actualFavItems.forEach(function (dataItem) {
      if (dataItem.isRender == true) {
        /*...*/
      }
    });
    this.dataList = this.actualFavItems;
    this.favoriteCount();
    this.updateProviderIds();
  }


     /**
     * @function : updateProviderIds
     * @description : This function to get the  Provider id's  from the favorite object.
     */
    updateProviderIds = () =>{
      const guestFaIDs = sessionStorage.getItem("guestproviderids");
      if( guestFaIDs === null ||guestFaIDs === undefined) {
      getProviderIdsFromFavorite().then(favproviderIds => {
          this.getFavProviderIdList = favproviderIds;
       });  
     }else {
      this.getFavProviderIdList = guestFaIDs;
     }
  }

   /**
     * @function : favoriteCount
     * @description : This function is to call the apex to get the Favorite count.
     */
  favoriteCount () {
    if (sessionStorage.getItem("guestproviderids")) {
      let guestProviderIds = sessionStorage.getItem("guestproviderids");
      guestProviderIds = Array.from(new Set(guestProviderIds.split(","))).toString();
      this.ShowFavoriteCount = guestProviderIds.split(",").length;
    } else{
    getFavoriteCount().then(favcount => {
          try{
        this.ShowFavoriteCount =  favcount;
          }catch(e){  
         /*...*/       
          }
      });
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

}