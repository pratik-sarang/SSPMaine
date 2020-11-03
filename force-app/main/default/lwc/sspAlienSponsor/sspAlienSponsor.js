 /**
 * Component Name - sspAlienSponsor.js.
 * Author         - Siddharth P V, Ashwin Kasture.
 * Description    - This screen use to select Alien sponsor for Member.
 * Date       	  - 26/03/2020.
 */
import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspCompleteQuestionsAlienSponsor from "@salesforce/label/c.sspCompleteQuestionsAlienSponsor";
import sspUnsureHowToCompleteSection from "@salesforce/label/c.sspUnsureHowToCompleteSection";
import sspAffidavitOfSupport from "@salesforce/label/c.sspAffidavitOfSupport";
import sspSponsoredByOrganization from "@salesforce/label/c.sspSponsoredByOrganization";
import sspAlienSponsorMemberOfHousehold from "@salesforce/label/c.sspAlienSponsorMemberOfHousehold";
import sspSelectHouseholdMember from "@salesforce/label/c.sspSelectHouseholdMember";
import sspAlienSponsorName from "@salesforce/label/c.sspAlienSponsorName";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import sspPrimaryPhoneNumber from "@salesforce/label/c.SSP_PrimaryPhoneNumber";
import sspAltAffidavitOfSupport from "@salesforce/label/c.sspAltAffidavitOfSupport";
import sspAltClickListRelevantHouseholdMembers from "@salesforce/label/c.sspAltClickListRelevantHouseholdMembers";
import alienSponsorName from "@salesforce/label/c.SSP_AlienSponsorName";

import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLineTwo from "@salesforce/label/c.SSP_AddressLine2";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import COUNTRY from "@salesforce/label/c.Country";
import ZIP from "@salesforce/label/c.Zip";
import utility,{ formatLabels, getYesNoOptions } from "c/sspUtility";
import sspAssert from "@salesforce/resourceUrl/SSP_Assert";
import apConstants,{ url } from "c/sspConstants";

import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_AlienSponsor__c.AddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_AlienSponsor__c.AddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_AlienSponsor__c.City__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_AlienSponsor__c.CountryCode__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_AlienSponsor__c.Countycode__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_AlienSponsor__c.StateCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_AlienSponsor__c.Zipcode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_AlienSponsor__c.Zipcode5__c";

import fetchAlienSponsorData from "@salesforce/apex/SSP_AlienSponsorCtrl.fetchAlienSponsorData";
import storeAlienSponsorData from "@salesforce/apex/SSP_AlienSponsorCtrl.storeAlienSponsorData";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

const yesValue = getYesNoOptions()[0].value;
const noValue = getYesNoOptions()[1].value;
const someoneElseLabel = "Someone Else";
const someoneElseValue = "someoneElse";

const PA_FIELD_MAP = {
    addressLine1: {
        ...PHYSICAL_ADDRESS_LINE1,
        label: sspAddress
    },
    addressLine2: {
        ...PHYSICAL_ADDRESS_LINE2,
        label: sspAddressLineTwo
    },
    city: {
        ...PHYSICAL_ADDRESS_CITY,
        label: CITY
    },
    country: {
        ...PHYSICAL_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    county: {
        ...PHYSICAL_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...PHYSICAL_ADDRESS_STATE,
        label: STATE
    },
    // zipCode4: {
    //     ...PHYSICAL_ADDRESS_ZIP4,
    //     label: ZIP
    // },
    // zipCode5: {
    //     ...PHYSICAL_ADDRESS_ZIP5,
    //     label: ZIP
    // }
    postalCode4: {
        ...PHYSICAL_ADDRESS_ZIP4,
        label: ZIP
    },
    postalCode: {
        ...PHYSICAL_ADDRESS_ZIP5,
        label: ZIP
    }
};

export default class SspAlienSponsor extends BaseNavFlowPage {
    @track showSpinner = false;
    @track listOfHouseholdData = [];
    @track listOfAlienSponsorData = [];
    @track externalAlienSponsor = "";
    @track currentMemberNameValue;
    @track isNotSponsoredByOrganization = false;
    @track MetaDataListParent;
    @track fieldMap = PA_FIELD_MAP;
    @track alienSponsorVerification;
    @track pageName;
    @track isFalseAlienSponsorMemberOfHousehold = false;
    @track firstTimeUser = true;
    @track isTrueWhoIsAlienSponsor = false;
    @track alienSponsorInfo = true;
    @track currentMemberNameValue;
    @track currentAlienSponsor;
    @track listOfAlienSponsor;
    @track addressRecord;
    @track nextValue = {};
    @track validationFlag = {};
    @track isTrueAlienSponsorMemberOfHousehold;
    @track optList = getYesNoOptions();
    @track listOfHousehold;
    @track sponsorValue;
    @track label = {
        sspCompleteQuestionsAlienSponsor,
        sspUnsureHowToCompleteSection,
        sspAffidavitOfSupport,
        sspSponsoredByOrganization,
        sspAlienSponsorMemberOfHousehold,
        sspSelectHouseholdMember,
        sspAlienSponsorName,
        sspAddress,
        sspAddressLineTwo,
        sspPrimaryPhoneNumber,
        sspAltClickListRelevantHouseholdMembers,
        sspAltAffidavitOfSupport,
        sspPageInformationVerified,
        alienSponsorName,
        startBenefitsAppCallNumber
    };
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @api applicationId;
    @api memberId;
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;

    /**
     * @function - get nextEvent.
     * @description - Next Event getter/setter method for framework.
     */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value) {
                this.nextValue = value;
                this.alienSponsorData = {};
                this.alienSponsorData.sMemberId = this.memberIdValue;
                let templateAppInputs = Array.from(
                    this.template.querySelectorAll(".ssp-applicationInputs")
                );
                const addressElement1 = this.template.querySelector(
                    ".ssp-address1"
                );
                if (addressElement1) {
                    addressElement1.ErrorMessages();
                    templateAppInputs = templateAppInputs.concat(
                        Array.from(addressElement1.inputElements)
                    );
                }
                this.templateInputsValue = templateAppInputs;
                for (let i = 0; i < templateAppInputs.length; i++) {
                    if (
                        templateAppInputs[i].fieldName === undefined &&
                        templateAppInputs[i].value.addressLine1 !== undefined
                    ) {
                        this.assignAddressLineData(templateAppInputs[i]);
                    } else if (templateAppInputs[i].fieldName !== undefined) {
                        this.alienSponsorData[templateAppInputs[i].fieldName] =
                            templateAppInputs[i].fieldName ===
                            "SponsoredByOrganization__c"
                                ? this.sponsorValue
                                : templateAppInputs[i].value;
                    }
                }
            }
        } catch (e) {
            console.error(
                "Error occur in nextEvent of sspAlienSponsor screen",
                e.message
            );
        }
    }

    /**
     * @function - allowSaveData().
     * @description - This method validates the input data and then saves it.
     */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            if (value !== undefined && value !== "") {
                this.validationFlag = value;
                this.storeAlienSponsorData(this.alienSponsorData);
            }
        } catch (e) {
            console.error(
                "Error occur in allowSaveData of sspAlienSponsor screen",
                e.message
            );
        }
    }

    /**
     * @function - get MetadataList.
     * @description - MetadataList getter method for framework.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        this.MetaDataListParent = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
        if (Object.keys(value).length > 0){
            this.constructRenderingMap(null, value); 
        }
    }

    /**
     * @function - sAppId.
     * @description - Application Id getter/setter method for framework.
     */
    @api
    get sAppId () {
        return this.appIdValue;
    }
    set sAppId (value) {
        if (value) {
            this.appIdValue = value;
        }
    }

    /**
     * @function - sMemberId.
     * @description - Member Id getter/setter method for framework.
     */
    @api
    get sMemberId () {
        return this.memberIdValue;
    }
    set sMemberId (value) {
        if (value) {
            this.memberIdValue = value;
            this.fetchAlienSponsorData(this.sAppId, value);
        }
    }

    /**
     * @function - get currentMemberName.
     * @description - This method is used to get current member name.
     */
    @api
    get currentMemberName () {
        return this.currentMemberNameValue;
    }
    set currentMemberName (value) {
        try {
            if (value) {
                this.currentMemberNameValue = value;
                this.label.sspSponsoredByOrganization = formatLabels(
                    this.label.sspSponsoredByOrganization,
                    [this.currentMemberNameValue]
                );

                this.label.sspAlienSponsorMemberOfHousehold = formatLabels(
                    this.label.sspAlienSponsorMemberOfHousehold,
                    [this.currentMemberNameValue]
                );
            }
        } catch (e) {
            console.error(
                "Error occur in currentMemberName of sspAlienSponsor screen",
                e.message
            );
        }
    }
    currentMemberData = {};
    alienSponsorMemberOfHouseholdToggle = "";
    alienSponsorData = {};
    affidavitLink = `${sspAssert}${url.affidavitUrl}`;

    /**
     * @function - connectedCallback.
     * @description - This method creates the field and object list to get metadata details from Entity Mapping as per screen name.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.getMetadataDetails(
                apConstants.alienSponsorFieldEntityNameList,
                null,
                "SSP_APP_Details_AlienSponsor"
            );
        } catch (error) {
            console.error(
                "Error occur in connectedCallback of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function - handlePicklist.
     * @description - Handle picklist onchange event.
     * @param {*} event - Get the current element event.
     */
    handlePicklist = event => {
        try {
            if (event.detail === someoneElseValue) {
                this.isFalseAlienSponsorMemberOfHousehold = true;
                this.isTrueWhoIsAlienSponsor = true;
                this.alienSponsorInfo = true;
            } else {
                this.alienSponsorInfo = false;
            }
        } catch (error) {
            console.error(
                "Error occur in handlePicklist of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handlePicklist.
     * @description - Renders the Elements.
     * @param {*} event - Get the current element event.
     */
    handleSponsoredByOrganization = event => {
        try {
            this.isTrueAlienSponsorMemberOfHousehold = false;
            this.isFalseAlienSponsorMemberOfHousehold = false;
            this.sponsorValue = event.target.value;
            if (this.sponsorValue == yesValue) {
                this.isNotSponsoredByOrganization = false;
            } else {
                this.isNotSponsoredByOrganization = true;
                this.alienSponsorMemberOfHouseholdToggle = "";
            }
        } catch (error) {
            console.error(
                "Error occur in handleSponsoredByOrganization of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleAlienSponsorMemberOfHousehold.
     * @description - Renders the Elements.
     * @param {*} event - Get the current element event.
     */
    handleAlienSponsorMemberOfHousehold = event => {
        try {
            if (event.target.value === yesValue) {
                this.isTrueAlienSponsorMemberOfHousehold = true;
                this.listOfHousehold = true;
                this.isFalseAlienSponsorMemberOfHousehold = false;
                this.alienSponsorInfo = false;
                this.isTrueWhoIsAlienSponsor = false;
            } else {
                this.isFalseAlienSponsorMemberOfHousehold = true;
                this.isTrueAlienSponsorMemberOfHousehold = false;
                this.externalAlienSponsor = "";
                if (this.listOfAlienSponsorData.length > 0) {
                    this.isTrueWhoIsAlienSponsor = true;
                    this.alienSponsorInfo = false;
                } else {
                    this.alienSponsorInfo = true;
                    this.isTrueWhoIsAlienSponsor = false;
                }
            }
        } catch (error) {
            console.error(
                "Error occur in handleAlienSponsorMemberOfHousehold of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - fetchAlienSponsorData.
     * @description - Method helps to fetch the Alien sponsor data.
     * @param {string} applicationId - Get the Application Id.
     * @param {string} memberId - Get the Member Id.
     */
    fetchAlienSponsorData = (applicationId, memberId) => {
        try {
            fetchAlienSponsorData({
                applicationId: applicationId,
                memberId: memberId
            })
                .then(result => {
                    const applicationIndividualList =
                        result.mapResponse.alienSponsorData;
                    if (applicationIndividualList.length > 0) {
                        const externalSponsorIdList = [];
                        applicationIndividualList.forEach(element => {
                            //Get Household Member Data
                            if (
                                element.SSP_Member__c !== memberId &&
                                element.SSP_Member__r.IsUSCitizenToggle__c ===
                                    yesValue
                            ) {
                                const sFirstName =
                                    element.SSP_Member__r.FirstName__c !==
                                    undefined
                                        ? element.SSP_Member__r.FirstName__c
                                        : "";
                                const sLastName =
                                    element.SSP_Member__r.LastName__c !==
                                    undefined
                                        ? element.SSP_Member__r.LastName__c
                                        : "";
                                this.listOfHouseholdData.push({
                                    label: sFirstName + " " + sLastName,
                                    value: element.SSP_Member__c
                                });
                            }

                            //To set External Who is Alien Sponsor dropdown
                            if (
                                element.SSP_Member__r
                                    .ExternalAlienSponsor__c !== undefined &&
                                !externalSponsorIdList.includes(
                                    element.SSP_Member__r
                                        .ExternalAlienSponsor__c
                                )
                            ) {
                                this.isTrueWhoIsAlienSponsor = true;
                                const sFirstName =
                                    element.SSP_Member__r
                                        .ExternalAlienSponsor__r
                                        .SponsorFirstName__c !== undefined
                                        ? element.SSP_Member__r
                                              .ExternalAlienSponsor__r
                                              .SponsorFirstName__c
                                        : "";

                                this.listOfAlienSponsorData.push({
                                    label: sFirstName,
                                    value:
                                        element.SSP_Member__r
                                            .ExternalAlienSponsor__c
                                });
                                externalSponsorIdList.push(
                                    element.SSP_Member__r
                                        .ExternalAlienSponsor__c
                                );
                            }

                            //Get Current Member Data
                            if (element.SSP_Member__c === memberId) {
                                this.currentMemberData = element.SSP_Member__r;
                                this.sponsorValue = this.currentMemberData.SponsoredByOrganization__c;

                                // To show alien sponsor fields
                                this.isNotSponsoredByOrganization =
                                    element.SSP_Member__r
                                        .SponsoredByOrganization__c === noValue
                                        ? true
                                        : false;

                                // To set Alien Sponsor Member of Household
                                if (
                                    element.SSP_Member__r
                                        .InternalAlienSponsor__c !== undefined
                                ) {
                                    this.currentAlienSponsor =
                                        element.SSP_Member__r.InternalAlienSponsor__c;
                                    this.alienSponsorMemberOfHouseholdToggle = yesValue;
                                    this.isTrueAlienSponsorMemberOfHousehold = true;
                                    this.listOfHousehold = true;
                                } else if (
                                    element.SSP_Member__r
                                        .ExternalAlienSponsor__c !== undefined
                                ) {
                                    this.externalAlienSponsor =
                                        element.SSP_Member__r.ExternalAlienSponsor__c;
                                    this.alienSponsorMemberOfHouseholdToggle = noValue;
                                    this.isFalseAlienSponsorMemberOfHousehold = true;
                                    this.isTrueWhoIsAlienSponsor = true;
                                    this.alienSponsorInfo = false;
                                }
                            }
                        });
                        if (externalSponsorIdList.length >= 0) {
                            this.listOfAlienSponsorData.push({
                                label: someoneElseLabel,
                                value: someoneElseValue
                            });
                        } else {
                            this.alienSponsorInfo = true;
                            this.isTrueWhoIsAlienSponsor = false;
                        }
                    }
                    this.showSpinner = false;
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occur in fetchAlienSponsorData of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - storeAlienSponsorData.
     * @description - Method use to store the Alien Sponsor data.
     * @param {object{}} alienSponsorData - Contains wrapper data of Alien sponsor.
     */
    storeAlienSponsorData = alienSponsorData => {
        try {
            const alienSponsor = JSON.stringify(alienSponsorData);
            storeAlienSponsorData({
                sAlienSponsorData: alienSponsor
            })
                .then(result => {
                    if (result.bIsSuccess === false) {
                        console.error(
                            "Error occurred in storeAlienSponsorData of sspAlienSponsor screen" +
                                result.mapResponse.ERROR
                        );
                    } else {
                        this.saveCompleted = true;
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in storeAlienSponsorData of sspAlienSponsor screen" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - assignAddressLineData.
     * @description - Method to store the Address Line values in Wrapper Variables.
     * @param {object{}} addressLineClass - Contains Address input element.
     */
    assignAddressLineData = addressLineClass => {
        try {
            if (addressLineClass) {
                this.alienSponsorData.sAddressLine1 =
                    addressLineClass.value.addressLine1;
                this.alienSponsorData.sAddressLine2 =
                    addressLineClass.value.addressLine2;
                this.alienSponsorData.sCity = addressLineClass.value.city;
                this.alienSponsorData.sCountryCode =
                    addressLineClass.value.country;
                this.alienSponsorData.sCountyCode =
                    addressLineClass.value.county;
                this.alienSponsorData.sStateCode = addressLineClass.value.state;
                this.alienSponsorData.sZipCode4 =
                    addressLineClass.value.postalCode;
            }
        } catch (error) {
            console.error(
                "Error in assignAddressLineData of sspAlienSponsor screen" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === apConstants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === apConstants.permission.readOnly;
                if (!this.isPageAccessible) {
                    this.showAccessDeniedComponent = true;
                } else {
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in highestEducation.constructRenderingMap", error
            );
        }
    }
}