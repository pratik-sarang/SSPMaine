/* eslint-disable no-unused-vars */
/**
 * Component Name: sspChildCareProviderDetails. 
 * Author: Code develop by CHFS Development team.
 * Description: Search/Find the Child Care Provider component.
 * Date: 06/23/2020.
 * MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------.
 CHFS Development Team          07/06/2020.
**/
import { LightningElement,track,api } from "lwc";
import getFavoriteCount from "@salesforce/apex/SSP_ChildCareProviderSearchController.getFavoriteCount";
import addToFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.addToFavorite";
import removeFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.removeFromFavorite";
import getProviderIdsFromFavorite from "@salesforce/apex/SSP_ChildCareProviderSearchController.getProviderIdsFromFavorite";
import isGuest from "@salesforce/apex/SSP_ChildCareProviderSearchController.isGuest";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import getInspectionReport from "@salesforce/apex/SSP_ChildCareProviderSearchController.getInspectionReport";
import sspConstants from "c/sspConstants";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import favoritesLink from "@salesforce/label/c.sspFavoritesLink";
import sspUseMyCurrentLocation from "@salesforce/label/c.sspUseMyCurrentLocation";
import sspClickUseCurrentLocation from "@salesforce/label/c.sspClickUseCurrentLoc";
import sspAddToFavorites from "@salesforce/label/c.sspAddToFavorites";
import sspRemoveFromFavorites from "@salesforce/label/c.sspRemoveToFavorites";
import sspChildCareProviderType from "@salesforce/label/c.sspChildCareProviderType";
import SSP_TIME from "@salesforce/label/c.SSP_Time";
import sspChildCareServices from "@salesforce/label/c.sspChildCareServices";
import backtosearchResults from "@salesforce/label/c.backtosearchResults";
import sspGeneral from "@salesforce/label/c.sspGeneral";
import sspProviderStatus from "@salesforce/label/c.sspProviderStatus";
import sspCounty from "@salesforce/label/c.sspCounty";
import sspOprHours from "@salesforce/label/c.sspOprHours";
import sspCost from "@salesforce/label/c.sspCost";
import sspMoreDetails from "@salesforce/label/c.sspMoreDetails";
import sspInspection from "@salesforce/label/c.sspInspection";
import sspDay from "@salesforce/label/c.sspDay";
import sspFullTime from "@salesforce/label/c.sspFullTime";
import sspPartTime from "@salesforce/label/c.sspPartTime";
import sspCapacity from "@salesforce/label/c.sspCapacity";
import sspCcapSubsidy from "@salesforce/label/c.sspCcapSubsidy";
import sspAcceditations from "@salesforce/label/c.sspAcceditations";
import sspFoodPermit from "@salesforce/label/c.sspFoodPermit";
import sspTransportation from "@salesforce/label/c.sspTransportation";
import allStarsLevel from "@salesforce/label/c.sspChildcareAllStarsLevel";
import sspAllStarModelPopUp1 from "@salesforce/label/c.sspAllStarmodelpopup1";
import sspAllStarModelPopUp2 from "@salesforce/label/c.sspAllStarmodelpopup2";
import SSPALLSTARMODELPOPUP3 from "@salesforce/label/c.sspAllStarmodelpopup2_3";
import sspAllStarModelPopUp4 from "@salesforce/label/c.sspAllStarmodelpopup3";
import sspAllStarModelPopUp5 from "@salesforce/label/c.sspAllStarmodelpopup4";
import sspLearnMore from "@salesforce/label/c.sspLearnMore";
import sspOpenNow from "@salesforce/label/c.sspOpenNow";
import sspChildcareOneOrMoreInspection from "@salesforce/label/c.sspChildcareOneOrMoreInspection";
import sspChildCareOngoing from "@salesforce/label/c.sspChildCareOngoing";
import sspChildCareInspectionHelp from "@salesforce/label/c.sspChildCareInspectionhelp";
import sspChildCareInspectionHistory from "@salesforce/label/c.sspChildCareInspectionHistory";
import sspChildCareStart from "@salesforce/label/c.sspChildCareStart";
import sspChildCareEnd from "@salesforce/label/c.sspChildCareEnd";
import sspChildcareSuspendedHelp from "@salesforce/label/c.sspChildcareSuspendedHelp";
import sspBackToSearchProviders from "@salesforce/label/c.sspbacktosearchProviders";
import sspChildcareNoInfo from "@salesforce/label/c.sspChildcareNoInfo";
import sspChildren from "@salesforce/label/c.sspChildren";
import sspAddToFavoritesAlt from "@salesforce/label/c.sspAddToFavoritesAlt";
import sspRemoveToFavoritesalt from "@salesforce/label/c.sspRemoveToFavoritesalt";
import sspAllstarLinkAlt from "@salesforce/label/c.sspAllstarLinkAlt";
import sspFavoritesLinkalt from "@salesforce/label/c.sspFavoritesLinkalt";
import sspViewdocAlt from "@salesforce/label/c.sspViewdocAlt";
import sspSavedFav from "@salesforce/label/c.sspSavedFav";
import sspChildCareBackToFav from "@salesforce/label/c.sspChildCareBackToFav";
import sspRemovedFromFavorites from "@salesforce/label/c.sspRemovefromFavorites";
import sspBackToSearchProvidersAlt from "@salesforce/label/c.sspbacktosearchProviders_alrt";
import sspBackFavProvidersAlrt from "@salesforce/label/c.sspbackFavProviders_alrt";

const sPDFValue = "pdf";

export default class SspChildCareProviderDetails extends LightningElement {

    @api providerData;
    @api showTable;
    @api showDetails;
    @api showSearchOptions;
    @api buttonTitle;
    @api pageType;
    
    @track FavoriteDetails = false;
    @track addToFav= false;
    @track showModalWindow = false;

    @track data;
    @track showSelectedData;
    @track ShowFavoriteCount;
    @track modalHeader;
    @track modalBody;
    @track modalFooter;
    @track guestUser;
    @track showProviderId;
    @track curProviderId;
    @track pageSearchNav = false;

    @track mapMarkers = [];
    @track mapAddress = [];
    @track dataList = [];
    @track getFavProviderIdList;
    
    locationArray = [];
    showFooter = false;
    listView = "hidden";

    customLabels = {
        sspUseMyCurrentLocation,
        sspClickUseCurrentLocation,
        favoritesLink,
        sspAddToFavorites,
        sspRemoveFromFavorites,
        sspChildCareProviderType,
        SSP_TIME,
        sspChildCareServices,
        backtosearchResults,
        sspGeneral,
        sspProviderStatus,
        sspCounty,
        sspOprHours,
        sspCost,
        sspMoreDetails,
        sspInspection,
        sspDay,
        sspFullTime,
        sspPartTime,
        sspCapacity,
        sspCcapSubsidy,
        sspAcceditations,
        sspFoodPermit,
        sspTransportation,
        allStarsLevel,
        sspAllStarModelPopUp1,
        sspAllStarModelPopUp2,
        SSPALLSTARMODELPOPUP3,
        sspAllStarModelPopUp4,
        sspAllStarModelPopUp5,
        sspLearnMore,
        sspOpenNow,
        sspChildcareOneOrMoreInspection,
        sspChildCareOngoing,
        sspChildCareInspectionHelp,
        sspChildCareInspectionHistory,
        sspChildCareStart,
        sspChildCareEnd,
        sspChildcareSuspendedHelp,
        sspBackToSearchProviders,
        sspChildcareNoInfo,
        sspChildren,
        sspAddToFavoritesAlt,
        sspRemoveToFavoritesalt,
        sspAllstarLinkAlt,
        sspFavoritesLinkalt,
        sspViewdocAlt,
        sspSavedFav,
        sspChildCareBackToFav,
        sspRemovedFromFavorites,
        sspBackToSearchProvidersAlt,
        sspBackFavProvidersAlrt
    }

    providerRateIcon = sspIcons + "/sspIcons/ic_star_yellow.png";
    providerNotificationIcon = sspIcons + "/sspIcons/ic_needsreview.png";

    /**
     * @function : connectedCallback
     * @description : This method is used to request the location of the user on load.
     */
    connectedCallback () {
      this.getUserType();
      this.pageSearchNav = false;
      const providerDetails= JSON.parse(JSON.stringify(this.providerData));      
      this.showSelectedData=true;
      this.data = providerDetails;
      this.favoriteCount();
      this.getAddressPin(providerDetails);
        this.updateProviderIds();
        if (this.pageType === "search") {
            this.pageSearchNav = true;
        }
        if (this.pageType === "Favorites") {
            this.data.citizenLogin = true;         
        }
    } 

/**
     * @function : getAddressPin
     * @description : This method is to set the Mapmaker data setup.
     * @param {object} providerDetails - Js event.
     */
    getAddressPin = (providerDetails)=>{
    this.mapMarkers = [];
    this.mapMarkers = [{
      location: {
          City: providerDetails.LocationCity,
          Country: " ",
          PostalCode: providerDetails.LocationZipCode5,
          State: providerDetails.LocationStateDescription,
          Street: providerDetails.LocationAddressLine1 +providerDetails.LocationAddressLine2
      },
      value: "location001",
      title: providerDetails.LocationAddressLine1,
      description: providerDetails.LocationAddressLine1,
      icon: "standard:account"
  }];
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
     * @function : backToSearch
     * @description : This method is to back to Provider search results screen .
     * @param {object} event - Js event.
     */
    backToSearch (event) {
      let selectedProviderId = "";
      if(this.data.ShowFavorite){
        selectedProviderId = event.target.dataset.id;
      }
      let eventName = "searchresultsfav";
      if (this.pageType === "search") {
        eventName = "searchresults";
      }
      const selectedEvent = new CustomEvent(eventName, {
        detail: {
          showSearchOptions: true,
          showTable: true,
          showDetails: false,
          showProviderId : this.getFavProviderIdList,  
          ShowFavoriteCount : this.ShowFavoriteCount
        }
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
    
  
    /**
     * @function :     handleBackToSearchProvider
     * @description : This method is Back to search provider button responds function .
     * @param {object} event - Js event.
    */
    handleBackToSearchProvider (event) {
      this.showSelectedData=event.detail.showSearchOptions;
      this.FavoriteDetails= event.detail.showDetails;
      this.ShowFavoriteCount=event.details.ShowFavoriteCount;
   }

   /**
     * @function :     favoriteCount
     * @description : This method is To get the FavoriteCount by calling Apex method .
     */
    favoriteCount (){
      if (sessionStorage.getItem("guestproviderids")) {
        let guestProviderIds = sessionStorage.getItem("guestproviderids");
        guestProviderIds = Array.from(new Set(guestProviderIds.split(","))).toString();
        this.ShowFavoriteCount = guestProviderIds.split(",").length;
      } else{
      getFavoriteCount().then(favcount => {
            try{
          this.ShowFavoriteCount =  favcount;
            }catch(e){  
              /* continue regardless of error */    
            }
        });
    }
  }

   /**
     * @function :   viewToFavoritesList
     * @description : This method is To get the View Favorite list onclick function.
     */
    viewToFavoritesList = () =>{ 
      this.showSelectedData=false;
      this.FavoriteDetails= true;
    }
       /**
     * @function : openModal.
     * @description : method to open the modal.
     */
    openModal = () => {
      this.isProviderDetails = true;
   }
  
  /**
   * @function : closeModal.
   * @description : method to close the modal.
   */
  closeModal = () => {
      this.isProviderDetails = false;
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
     * @function : handleFavorites
     * @description : Handle favorites method to Add / Remove the Favorites.
     * @param {object} event - Js event.
    */
   handleFavorites (event) {
       const selectedProviderId = event.target.dataset.id;
       const selectedProviderName = event.target.dataset.name;
      this.data.ShowFavorite = !this.data.ShowFavorite;
      if (event.target.value == "AddToFavorites") {
          try {        
                  if(this.guestUser){
                    if (sessionStorage.getItem("guestproviderids")) {
                    let guestProviderIds = sessionStorage.getItem("guestproviderids") + "," + selectedProviderId;
                    guestProviderIds = Array.from(new Set(guestProviderIds.split(","))).toString();
                    this.ShowFavoriteCount = guestProviderIds.split(",").length;
                    sessionStorage.setItem("guestproviderids", guestProviderIds);
                    } else {
                      sessionStorage.setItem("guestproviderids", selectedProviderId);
                      this.ShowFavoriteCount = 1;
                      
                    }
                    this.updateProviderIds();
                  } else {
                    addToFavorite({ providerId: selectedProviderId })
                    .then(result => {
                        this.favoriteCount();
                        this.updateProviderIds();
                    })
                  }
              event.target.label = this.customLabels.sspRemoveFromFavorites;
              event.target.value = "RemoveFromFavorites";
              this.showToast("success",selectedProviderName+ "\n" +this.customLabels.sspSavedFav, "success"); 
               } catch (error) {
              console.error(this.error);
          }
          } else if (event.target.value == "RemoveFromFavorites") {
          try {
                  if(this.guestUser){
                    if (sessionStorage.getItem("guestproviderids")) {
                      let guestProviderIds = sessionStorage.getItem("guestproviderids");
                      const separator =  ",";
                      const values = guestProviderIds.split(separator);
                      for(let i = 0 ; i < values.length ; i++) {
                        if(values[i] == selectedProviderId) {
                          values.splice(i, 1);
                          guestProviderIds =  values.join(separator);
                        }
                      }
                    sessionStorage.setItem("guestproviderids", guestProviderIds);
                    this.ShowFavoriteCount = guestProviderIds === "" ? 0 : guestProviderIds.split(",").length;
                  } 
                  this.updateProviderIds();
                  } else {
                    removeFromFavorite({ providerId: selectedProviderId })
                    .then(result => {
                        this.favoriteCount();
                        this.updateProviderIds();
                    })
                  }
              event.target.label = this.customLabels.sspAddToFavorites;
              event.target.value = "AddToFavorites";
              this.showToast("success", selectedProviderName+ "\n" + this.customLabels.sspRemovedFromFavorites, "success");
          } catch (error) {
              console.error(this.error);
          }
      }
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
      )
    }


    /**
     * @function 		: allStarLinkClick.
     * @description 	: method to display the model Popup.
    **/
      allStarLinkClick = () => {
        this.showModalWindow = true;
        this.modalHeader = this.customLabels.allStarsLevel;
        this.modalBody = this.customLabels.sspAllStarModelPopUp1 +"\n"+ this.customLabels.sspAllStarModelPopUp2 +"\n"+ this.customLabels.SSPALLSTARMODELPOPUP3 +"\n"+this.customLabels.sspAllStarModelPopUp4+"\n"+this.customLabels.sspAllStarModelPopUp5;
        this.modalFooter = " ";
    }
    
     /**
     * @function 		: handleCloseModal.
     * @description 	: method to close the model Popup.
    **/
    handleCloseModal = () =>{
      this.showModalWindow = false; 
    }

  /**
     * @function : downloadTheFile
     * @description : Used to download file.
     * @param {object} event - Js event.
     */
    handleDocumentDownload = event => {
      try {
          if (event.keyCode === 13 || event.type === "click") {
              this.showSpinner = true;
              const documentName = event.target.dataset.documentName;
              const documentType = event.target.dataset.documentType;
              const inspectionId = event.target.dataset.inspectionId;
              const planOfCorrectionId = event.target.dataset.planOfCorrectionId;
              const source = event.target.dataset.source;
              const extension= "pdf";
              getInspectionReport({
                 queryData : {
                  inspectionId: (inspectionId === undefined || inspectionId === null || inspectionId === "") ? "": inspectionId,
                  reportName: (documentName === undefined || documentName === null || documentName === "") ? "" : documentName,
                  planOfCorrectionID: (planOfCorrectionId === undefined || planOfCorrectionId === null || planOfCorrectionId === "")? "" : planOfCorrectionId,
                  source : (source === undefined || source === null || source === "")? "" : source,
                  reportType : (documentType === undefined || documentType === null || documentType === "")? "" : documentType
                }
               }).then(result => {
                      if (result) {                        
                          let base64Data = "";
                          const docBase64Data = result.binaryData;
                          base64Data = docBase64Data;
                          if (
                              base64Data &&
                              base64Data !== "ERROR Empty Response"
                          ) {
                              const userAgentString = navigator.userAgent;
                              const browserIsEdge =
                                  window.navigator.userAgent.indexOf(
                                      "Edge"
                                  ) !== -1;
                              const browserIsSafari =
                                  userAgentString.indexOf("Safari") > -1;
                              const browserIExplorer =
                                  window.navigator &&
                                  window.navigator.msSaveOrOpenBlob
                                      ? true
                                      : false;
                              this.browserIExplorerTemp = browserIExplorer;
                              let fileURL;
                              let fileBlob;
                              //For IE11
                              if (
                                  window.navigator &&
                                  window.navigator.msSaveOrOpenBlob
                              ) {
                                  fileBlob = this.base64ToBlob(
                                      base64Data,
                                      extension
                                  );
                                  window.navigator.msSaveOrOpenBlob(
                                      fileBlob,
                                      documentName
                                  );
                              } else {
                                  if (browserIsEdge || browserIsSafari) {

                                      fileBlob = this.base64ToBlob(
                                          base64Data,
                                          extension
                                      );
                                      fileURL = URL.createObjectURL(fileBlob);
                                  } else {
                                      if (extension === sPDFValue) {
                                          fileURL =
                                              "data:application/" +
                                              extension +
                                              ";base64," +
                                              base64Data;
                                      } else {
                                          fileURL =
                                              "data:image/" +
                                              extension +
                                              ";base64," +
                                              base64Data; 
                                      }
                                  }
                                  const link = document.createElement("a");
                                  link.download = documentName;
                                  link.href = fileURL;
                                  link.style.display = "none";
                                  link.target = "_blank";
                                  link.click();
                              }
                          } else {
                              console.error(
                                  "Error occurred in downloadTheFile of SspDocumentCenterHome " +
                                      JSON.stringify(result)
                              );
                              this.showErrorModal = true;
                          }
                          this.showSpinner = false;
                      } else {
                          console.error(
                              "Error occurred in downloadTheFile of SspDocumentCenterHome " +
                                  result.mapResponse.ERROR
                          );
                          this.showErrorModal = true;
                          this.showSpinner = false;
                      }
                  })
                  .catch(error =>{
                      console.error(error);
                      this.showErrorModal = true;
                      this.showSpinner = false;
                  });
          }
      } catch (error) {
          console.error(
              "Error in downloadTheFile of SspDocumentCenterHome" +
                  JSON.stringify(error.message)
          );
          this.showSpinner = false;
      }
  };

  base64ToBlob (base64String, extension) {
    try {
        let fileBlob;
        const byteCharacters = atob(base64String);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        /*global Uint8Array*/
        const byteArray = new Uint8Array(byteNumbers);

        if (extension === "pdf") {
            fileBlob = new Blob([byteArray], { type: "application/pdf" });
        } else if (
            extension === sspConstants.sspDocUpload.formatJPG ||
            extension === sspConstants.sspDocUpload.formatJPEG
        ) {
            fileBlob = new Blob([byteArray], { type: "image/jpeg" });
        } else if (
            extension === sspConstants.sspDocUpload.formatTIF ||
            extension === "tiff"
        ) {
            fileBlob = new Blob([byteArray], { type: "image/tiff" });
        } else if (extension === "png") {
            fileBlob = new Blob([byteArray], { type: "image/png" });
        }
        return fileBlob;
    } catch (error) {
        console.error(
            "Error in base64ToBlob" + JSON.stringify(error.message)
        );
        return null;
    }
}

}