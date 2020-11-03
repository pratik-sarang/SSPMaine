import { LightningElement, track, api } from "lwc";
import getAddressAutoCompleteLWC from "@salesforce/apex/SSPAddressAutocompleteController.getAddressAutoCompleteLWC";
import getOfficeLocations from "@salesforce/apex/SSP_FindDCBSOfficeController.getOfficeLocations";
import getCurrentAddressDetails from "@salesforce/apex/SSP_FindDCBSOfficeController.getCurrentAddress";

import sspFIndDCBSOffice from "@salesforce/label/c.sspFIndDCBSOffice";
import sspUseMyCurrentLocation from "@salesforce/label/c.sspUseMyCurrentLocation";
import sspAltMyCurrentLocation from "@salesforce/label/c.sspAltMyCurrentLocation";
import sspSearchCityCountryZipCode from "@salesforce/label/c.sspSearchCityCountryZipCode";
import sspViewMore from "@salesforce/label/c.sspViewMore";
import sspMondayToFriday from "@salesforce/label/c.sspMondayToFriday";
import sspMailingAddress from "@salesforce/label/c.sspMailingAddress";
import sspResults from "@salesforce/label/c.sspResults";
import sspHoursHyphen from "@salesforce/label/c.sspHoursHiphen";
import sspResultsToShow from "@salesforce/label/c.sspResultsToShow";
import sspSearchByAddress from "@salesforce/label/c.sspSearchByAddress";
import sspClickToCallNumber from "@salesforce/label/c.sspClickToCallNumber";
import sspSelectOffice from "@salesforce/label/c.sspSelectOffice";
import sspClickUseCurrentLocation from "@salesforce/label/c.sspClickUseCurrentLoc";
import sspClickSelectOffice from "@salesforce/label/c.sspClickSelectOffix";
import sspClickToOpenDeviceMapAppWithAddress from "@salesforce/label/c.SSP_ClickToOpenDeviceMapAppWithAddress";
import sspAddMailing1 from "@salesforce/label/c.sspAddMailing1";
import sspAddressMailing2 from "@salesforce/label/c.sspAddressMailing2";
import sspSearch from "@salesforce/label/c.SSP_SearchPlaceholder";

import sspClickToCall from "@salesforce/label/c.SSP_ClickToCall";
import sspConstants from "c/sspConstants";
import sspImages from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspUtility from "c/sspUtility";

export default class SspFindDcbsOffice extends LightningElement {
    @track addressResults;
    @track error;
    @track selectedAddress;
    @track locationResults;
    @track cssResults;
    @track inputLocation = "";
    @track predictions = [];
    @track placeResultArray;
    @track mapMarkers = [];
    @track iterateResultArray = [];
    @track doShowMore = false;
    @track resultCount;
    @track latitude;
    @track longitude;
    @track mailingAddress;
    @track redirectAddress;
    @track phoneNumber;
    @track redirectMailingAddress;
    @track address = "";
    @track mailingAddress = "";
    @track desktopShow = true;
    @api openModel = false;
    @track showSpinner = false;
    @track addressComponents;
    @track selectedOfficeInfo = {
        addressLine1: "",
        addressLine2: "",
        city: "",
        zipCode:"",
        Id: "",
        name: ""
    };
    @api isMedicaidRequest = false;
    currentResultCount = 0;
	
	//for defect fix 379640
    @track centerLocation = {
        location: {
            Latitude: "37.8010013",
            Longitude: "-88.0124013",
            State: "KY",
            Country: "USA",
            PostalCode: "40201",
            City: "Louisville"

       // City: "San Francisco",
       // Country: 'USA',
      //  PostalCode: '94105',
      //  State: 'CA'
        },
    };
	
    defaultResultsToShow = parseInt(sspResultsToShow, 10); //result to show on click of view more

    mailingAdd = sspAddMailing1 + " " + sspAddressMailing2;

    mailingAltText =
        sspClickToOpenDeviceMapAppWithAddress +
        " " +
        sspAddMailing1 +
        " " +
        sspAddressMailing2;

    locationArray = [];

    @track labels = {
        sspFIndDCBSOffice,
        sspUseMyCurrentLocation,
        sspAltMyCurrentLocation,
        sspSearchCityCountryZipCode,
        sspViewMore,
        sspMondayToFriday,
        sspMailingAddress,
        sspResults,
        sspHoursHyphen,
        sspSearchByAddress,
        sspClickToCallNumber,
        sspSelectOffice,
        sspClickUseCurrentLocation,
        sspClickSelectOffice,
        sspClickToOpenDeviceMapAppWithAddress,
        sspClickToCall,
        sspAddMailing1,
        sspAddressMailing2,
        sspSearch
    };

    searchIcon = sspImages + "/sspIcons/ic_search@3x.png";

    /**
     * @function : getCurrentLocation
     * @description : Gets current position.
     */
    getCurrentLocation () {
        navigator.geolocation.getCurrentPosition(
            this.success.bind(this),
            this.error
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
     * @function : connectedCallback
     * @description : This function runs when the page is loaded for the first time.
     */
    connectedCallback () {
        this.showSpinner = true;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                this.setPosition.bind(this),
                this.setDefaultPositionForMember.bind(this)
            );
            this.showSpinner = false;
        } else {
            this.showSpinner = false;
            console.error("The browser doesn't support Geolocation.");
        }
    }

    center;

    zoomLevel = 4;
    markersTitle = "Salesforce locations in United States";
    showFooter = false;
    listView = "hidden";

    /**
     * @function : handleOnChangeAddressInput
     * @description : This function is called when we change values in the search box.
     * @param {object} event - Gets address entered.
     */
    handleOnChangeAddressInput (event) {
        const value = event.detail.value;
        if (value) {
            if (value.length > 2) {
                getAddressAutoCompleteLWC({ searchKey: JSON.stringify(value) })
                    .then(result => {
                        
                        this.placeResultArray = JSON.parse(result);
                    })
                    .catch(error => {
                        console.error("error " + JSON.stringify(error));
                        
                    });
            } else {
                this.placeResultArray = null;
            }
        } else {
            this.placeResultArray = null;
        }
    }
    /**
     * @function : getAddressDetails
     * @description :  Searches the address which user enters in the search box.
     * @param {object} event - Gets address.
     */
    getAddressDetails (event) {
        event.preventDefault();
        const selectedLocation = event.target.dataset.id;
        this.inputLocation = selectedLocation;

        if (this.placeResultArray) {
            for (let i = 0; i < this.placeResultArray.length; i++) {
                if (
                    this.placeResultArray[i].formatted_address ===
                    selectedLocation
                ) {
                    const locationObject = this.placeResultArray[i].geometry;

                    if(this.placeResultArray[i].address_components){
                            const temp=[];
                            for(let j=0; j<this.placeResultArray[i].address_components.length ; j++){
                                temp.push(this.placeResultArray[i].address_components[j]);
                            }
                            
                        this.addressComponents = JSON.stringify(temp);
                    }
                    if (locationObject) {
                        this.latitude = locationObject.location.lat;
                        this.longitude = locationObject.location.lng;
                    }
                    break;
                }
            }
            this.placeResultArray = null;
            if (this.latitude && this.longitude) {
                this.getOfficeLocationsApex();
            }
        }
    }
    /**
     * @function : getOfficeLocationsApex
     * @description :  * Function to make apex controller call to get sorted list of offices to be shown on UI.This function sets the latitude and longitude values of user upon getting access.
     */
    getOfficeLocationsApex () {
        this.iterateResultArray = [];
        getOfficeLocations({
            lat: this.latitude,
            lng: this.longitude,
            addressCmp: this.addressComponents
        })
            .then(result => {
                this.addressResults = result;

                this.locationArray = [];
                if (this.addressResults) {
                    this.resultCount = this.addressResults.length;
                    //This for loop is to add markers to map.
                    for (let j = 0; j < this.addressResults.length; j++) {
                        this.locationArray.push({
                            location: {
                                Latitude: this.addressResults[j]
                                    .Geolocation__Latitude__s,
                                Longitude: this.addressResults[j]
                                    .Geolocation__Longitude__s
                            },
                            title: this.addressResults[j].Name
                        });
                        this.addressResults[j][
                            sspConstants.findDCBSOffice.officeHoursFromText
                        ] =
                            "2015-03-04T" +
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.officeHoursFromText
                            ];
                        this.addressResults[j][
                            sspConstants.findDCBSOffice.officeHoursToText
                        ] =
                            "2015-03-04T" +
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.officeHoursToText
                            ];
                        const tempArray = [
                            "PhysicalAddressLine1__c",
                            "PhysicalAddressLine2__c",
                            "PhysicalCity__c",
                            "PhysicalCountyCode__c",
                            "PhysicalStateCode__c",
                            "PhysicalZipCode4__c",
                            "PhysicalZipCode5__c"
                        ];
                        let address = "";
                        tempArray.forEach(element => {
                            if (this.addressResults[j][element]) {
                                address =
                                    address + this.addressResults[j][element];
                            }
                        });
                        this.addressResults[j]["addressAltText"] =
                            this.labels.sspClickToOpenDeviceMapAppWithAddress +
                            " " +
                            address;
                        this.addressResults[j]["callAltText"] =
                            this.labels.sspClickToCall +
                            " " +
                            this.addressResults[j].OfficePhone__c;
                    }
                    this.mapMarkers = this.locationArray;

                    if (
                        this.addressResults.length > this.defaultResultsToShow
                    ) {
                        this.doShowMore = true;
                        for (let j = 0; j < this.defaultResultsToShow; j++) {
                            //add static address for mailing address - confirmed with on site
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingAddressLineOne
                            ] = "275 E. Main St.";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingCity
                            ] = "Frankfurt";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingStateCode
                            ] = "KY";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingZipCodeFive
                            ] = "40621";

                            const mailingAddress =
                                this.addressResults[j].MailingAddressLine1__c +
                                this.addressResults[j].MailingCity__c +
                                this.addressResults[j].MailingStateCode__c +
                                this.addressResults[j].MailingZipCode5__c;
                            this.addressResults[j]["mailingAltText"] =
                                this.labels
                                    .sspClickToOpenDeviceMapAppWithAddress +
                                " " +
                                mailingAddress;

                            this.iterateResultArray.push(
                                this.addressResults[j]
                            );
                        }
                        this.currentResultCount = this.defaultResultsToShow;
                    } else {
                        this.doShowMore = false;
                        for (let j = 0; j < this.addressResults.length; j++) {
                            //add static address for mailing address - confirmed with on site
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingAddressLineOne
                            ] = "275 E. Main St.";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingCity
                            ] = "Frankfurt";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingStateCode
                            ] = "KY";
                            this.addressResults[j][
                                sspConstants.findDCBSOffice.mailingZipCodeFive
                            ] = "40621";

                            const mailingAddress =
                                this.addressResults[j].MailingAddressLine1__c +
                                this.addressResults[j].MailingCity__c +
                                this.addressResults[j].MailingStateCode__c +
                                this.addressResults[j].MailingZipCode5__c;
                            this.addressResults[j]["mailingAltText"] =
                                this.labels
                                    .sspClickToOpenDeviceMapAppWithAddress +
                                " " +
                                mailingAddress;

                            this.iterateResultArray.push(
                                this.addressResults[j]
                            );
                        }
                    }
                }
            })
            .catch(error => {
                console.error("error " + JSON.stringify(error));
            });
    }
    /**
     * @function : showMoreData
     * @description : Shows more data when clicking view more.
     */
    showMoreData () {
        if (
            this.addressResults.length >
            this.currentResultCount + this.defaultResultsToShow
        ) {
            this.doShowMore = true;
            const max = this.currentResultCount + this.defaultResultsToShow;
            for (let j = this.currentResultCount; j < max; j++) {
                //add static address for mailing address - confirmed with on site
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingAddressLineOne
                ] = "275 E. Main St.";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingCity
                ] = "Frankfurt";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingStateCode
                ] = "KY";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingZipCodeFive
                ] = "40621";
                this.iterateResultArray.push(this.addressResults[j]);
            }
            this.currentResultCount = max;
        } else {
            this.doShowMore = false;
            const maxJ = this.addressResults.length - this.currentResultCount;

            for (
                let j = this.currentResultCount;
                j < this.addressResults.length;
                j++
            ) {
                //add static address for mailing address - confirmed with on site
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingAddressLineOne
                ] = "275 E. Main St.";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingCity
                ] = "Frankfurt";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingStateCode
                ] = "KY";
                this.addressResults[j][
                    sspConstants.findDCBSOffice.mailingZipCodeFive
                ] = "40621";

                this.iterateResultArray.push(this.addressResults[j]);
            }
            //this.mapMarkers = this.locationArray;
            this.currentResultCount = this.currentResultCount + maxJ;
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
     * @function : getCurrentAddress
     * @description : Gets current location.
     */
    getCurrentAddress () {
        this.inputLocation = "";
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
                    //this.inputLocation = result;
                    const parsedData = result.mapResponse;  
                    if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
                        console.error("failed in loading dashboard" +JSON.stringify(parsedData.ERROR));
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        
                        if (parsedData.hasOwnProperty("formattedAddress")) {
                            
                            this.inputLocation = parsedData.formattedAddress;
                        }
                        if(parsedData.hasOwnProperty("addressComponent")){
                            
                            const addComponents = JSON.parse(parsedData.addressComponent);
                            const temp=[];
                            for(let j=0; j<addComponents.length ; j++){
                                temp.push(addComponents[j]);
                            }
                            
                            this.addressComponents = JSON.stringify(temp);
                        }
                        //calling method to get all offices based on current lat long
                        this.getOfficeLocationsApex();
                    }
                })
                .catch(error => {
                    console.error("error " + JSON.stringify(error));
                });
        }
    }

    /**
     * @function : sendToVF.
     * @description :  send data to visual force page.
     */
    sendToVF = () => {
        try {
            //Prepare message in the format required in VF page
            const message = {
                loadGoogleMap: true,
                mapData: this.mapData,
                mapOptions: this.mapOptions,
                mapOptionsCenter: this.mapOptionsCenter,
                origin: this.lightningWebCompHost
            };
            const visualForcePageWindow = this.template.querySelectorAll(
                ".ssp-visualForceFrame"
            )[0].contentWindow;
            visualForcePageWindow.postMessage(
                message,
                this.visualForcePageHost
            );
        } catch (error) {
            console.error(
                "failed in sendToVF in google map" + JSON.stringify(error)
            );
        }
    };
    /**
     * @function : redirectToAddress
     * @description : This opens google maps directions.
     * @param {object} event - Get address to redirect.
     */
    redirectToAddress (event) {
        try {
            const selectedAddress1 = event.target.dataset.address1;
            const selectedAddress2 = event.target.dataset.address2;
            const selectedAddressCity =
                event.target.dataset[sspConstants.findDCBSOffice.addressCity];
            const selectedAddressCountyCode =
                event.target.dataset[
                    sspConstants.findDCBSOffice.addressCountyCode
                ];
            const selectedAddressStateCode =
                event.target.dataset[
                    sspConstants.findDCBSOffice.addressStateCode
                ];

            if (selectedAddress1 !== undefined && selectedAddress1 !== "NULL") {
                this.address = this.address + selectedAddress1 + " ";
            }
            if (selectedAddress2 !== undefined && selectedAddress2 !== "NULL") {
                this.address = this.address + selectedAddress2 + " ";
            }
            if (
                selectedAddressCity !== undefined &&
                selectedAddressCity !== "NULL"
            ) {
                this.address = this.address + selectedAddressCity + " ";
            }
            if (
                selectedAddressCountyCode !== undefined &&
                selectedAddressCountyCode !== "NULL"
            ) {
                this.address = this.address + selectedAddressCountyCode + " ";
            }
            if (
                selectedAddressStateCode !== undefined &&
                selectedAddressStateCode !== "NULL"
            ) {
                this.address = this.address + selectedAddressStateCode + " ";
            }

            this.redirectAddress =
                "https://www.google.com/maps/dir/" +
                this.inputLocation +
                "/" +
                this.address;
            this.address = " ";
        } catch (error) {
            console.error("failed to redirect to address");
        }
    }
    /**
     * @function : redirectToMailingAddress
     * @description : This opens office mailing address directions in google maps.
     */
    redirectToMailingAddress () {
        try {
            this.redirectMailingAddress =
                "https://www.google.com/maps/dir/" +
                this.inputLocation +
                "/" +
                this.mailingAdd;
            this.mailingAddress = " ";
        } catch (error) {
            console.error("failed to redirect to address");
        }
    }
    /**
     * @function : redirectToPhone
     * @description : This opens phone links.
     * @param {object} event - Get phone number.
     */
    redirectToPhone (event) {
        const number = event.target.dataset.phone;
        this.phoneNumber = "Tel:" + number;
    }

    /**
     * @function : handleInputFocusOrBlur
     * @description : This function is used to close search window when it loses focus.
     */
    handleInputFocusOrBlur () {
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
     * @function : openModal
     * @description : This used to open Modal.
     */
    openModal () {
        this.openModel = true;
    }
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        this.openModel = false;
        this.desktopShow = false;
        this.fireEvent();
    }
    /**
     * @function : fireEvent
     * @description : This function fires event to the parent component.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(sspConstants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }

    /**
     * @function : getOfficeInformation
     * @description : This methods fires a custom event to send selected office info.
     * @param {object} event - Get selected office info.
     */
    getOfficeInformation = event => {
        try {
            this.selectedOfficeInfo = {
                addressLine1: event.target.dataset.address1,
                addressLine2: event.target.dataset.address2,
                city: event.target.dataset[sspConstants.findDCBSOffice.addressCity],
                zipCode:event.target.dataset[sspConstants.findDCBSOffice.addressZipCodeFive],
                Id: event.target.dataset.identity,
                name: event.target.dataset.office
            };
            if (this.isMedicaidRequest === true) {
                const selectOfficeEvent = new CustomEvent(
                    sspConstants.requestCards.selectOffice,
                    {
                        detail: this.selectedOfficeInfo
                    }
                );
                this.dispatchEvent(selectOfficeEvent);
                this.handleProp();
            }
        } catch (error) {
            console.error("Error in getOfficeInformation =>",error );
        }
    }
}