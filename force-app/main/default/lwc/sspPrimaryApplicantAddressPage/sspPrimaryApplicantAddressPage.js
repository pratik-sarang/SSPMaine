/**
 * Component Name: SspPrimaryApplicantAddressPage.
 * Author: Ajay Saini, Saurabh Rathi.
 * Description: This screen takes Address Information for an applicant.
 * Date: 11/12/2019.
 */

import { track, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { toggleFieldValue, applicationMode, permission } from "c/sspConstants"; //2.5 Security Role Matrix and Program Access.
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import ADDRESS from "@salesforce/label/c.address";
import ADDRESS_LINE2 from "@salesforce/label/c.AddressLine2";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import COUNTRY from "@salesforce/label/c.Country";
import ZIP from "@salesforce/label/c.Zip_Code";
import sameAddressInfoAltText from "@salesforce/label/c.SSP_SameAddressInfoAltText";
import sspUtility from "c/sspUtility";

import YES from "@salesforce/label/c.SSP_Yes";
import NO from "@salesforce/label/c.SSP_No";
import HAVE_SAME_ADDRESS_LABEL from "@salesforce/label/c.SSP_EveryoneHaveSameAddress";
import HAVE_ADDRESS_AS_HOH_LABEL from "@salesforce/label/c.HaveSameAddressInfoAsPrimary";
import HAVE_PHYSICAL_ADDRESS_LABEL from "@salesforce/label/c.SSP_HavePhysicalAddress";
import DIFFERENT_MAILING_ADDRESS_LABEL from "@salesforce/label/c.SSP_DifferentMailingAddress";
import MAILING_ADDRESS_1 from "@salesforce/label/c.SSP_Mailing_Address"; //TFS: 362284
import MAILING_ADDRESS_2 from "@salesforce/label/c.SSP_Mailing_Address_Line2"; //TFS: 362284

import MEMBER_ID from "@salesforce/schema/SSP_Member__c.Id";
import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import VERIFICATION_FLAG from "@salesforce/schema/SSP_Member__c.Non_Citizen_Verification_Flag__c";

import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_Member__c.PhysicalAddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_Member__c.PhysicalAddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_Member__c.PhysicalCity__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_Member__c.PhysicalCountyCode__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_Member__c.PhysicalStateCode__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Member__c.PhysicalCountryCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Member__c.PhysicalZipCode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Member__c.PhysicalZipCode5__c";

import MAILING_ADDRESS_LINE1 from "@salesforce/schema/SSP_Member__c.MailingAddressLine1__c";
import MAILING_ADDRESS_LINE2 from "@salesforce/schema/SSP_Member__c.MailingAddressLine2__c";
import MAILING_ADDRESS_CITY from "@salesforce/schema/SSP_Member__c.MailingCity__c";
import MAILING_ADDRESS_COUNTY from "@salesforce/schema/SSP_Member__c.MailingCountyCode__c";
import MAILING_ADDRESS_STATE from "@salesforce/schema/SSP_Member__c.MailingStateCode__c";
import MAILING_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Member__c.MailingCountryCode__c";
import MAILING_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Member__c.MailingZipCode4__c";
import MAILING_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Member__c.MailingZipCode5__c";

import HAVE_PHYSICAL_ADDRESS from "@salesforce/schema/SSP_Member__c.IsFixedAddressToggle__c";
import HAVE_DIFFERENT_MAILING_ADDRESS from "@salesforce/schema/SSP_Member__c.HasDifferentMailingAddressToggle__c";
import SAME_ADDRESS_AS_HOH from "@salesforce/schema/SSP_Member__c.SameAddressOfHoh__c";
import ALL_HAVE_SAME_ADDRESS from "@salesforce/schema/SSP_Member__c.SameAddressInfoAsHOHToggle__c";

import UTILITY_EXPENSE from "@salesforce/schema/SSP_Member__c.HasUtilityExpenseToggle__c";
import SHELTER_EXPENSE from "@salesforce/schema/SSP_Member__c.HasShelterExpenseToggle__c";

import updateAddress from "@salesforce/apex/SSP_ApplicantAddressController.updateAddress";
import getPrimaryApplicantData from "@salesforce/apex/SSP_ApplicantAddressController.getPrimaryApplicantData";
import getExpenseDetails from "@salesforce/apex/SSP_ApplicantAddressController.getExpenseDetails";
import getAllNonHohMembers from "@salesforce/apex/SSP_ApplicantAddressController.fetchMemberIdNonPrimary";
import { NavigationMixin } from "lightning/navigation";
import getUserDetails from "@salesforce/apex/SSP_Utility.getUserDetails"; //Defect-391009

const PHYSICAL_LATITUDE = {
    fieldApiName: "PhysicalGeolocation__Latitude__s",
    objectApiName: "SSP_Member__c"
};

const PHYSICAL_LONGITUDE = {
    fieldApiName: "PhysicalGeolocation__Longitude__s",
    objectApiName: "SSP_Member__c"
};

const MAILING_LATITUDE = {
    fieldApiName: "MailingGeolocation__Latitude__s",
    objectApiName: "SSP_Member__c"
};

const MAILING_LONGITUDE = {
    fieldApiName: "MailingGeolocation__Longitude__s",
    objectApiName: "SSP_Member__c"
};

const PA_FIELD_MAP = {
    addressLine1: {
        ...PHYSICAL_ADDRESS_LINE1,
        label: ADDRESS
    },
    addressLine2: {
        ...PHYSICAL_ADDRESS_LINE2,
        label: ADDRESS_LINE2
    },
    city: {
        ...PHYSICAL_ADDRESS_CITY,
        label: CITY
    },
    county: {
        ...PHYSICAL_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...PHYSICAL_ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...PHYSICAL_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...PHYSICAL_ADDRESS_ZIP5,
        label: ZIP
    },
    postalCode4: {
        ...PHYSICAL_ADDRESS_ZIP4,
        label: ZIP
    },
    latitude: {
        ...PHYSICAL_LATITUDE
    },
    longitude: {
        ...PHYSICAL_LONGITUDE
    }
};

const MA_FIELD_MAP = {
    addressLine1: {
        ...MAILING_ADDRESS_LINE1,
        label: MAILING_ADDRESS_1 //TFS: 362284
    },
    addressLine2: {
        ...MAILING_ADDRESS_LINE2,
        label: MAILING_ADDRESS_2 //TFS: 362284
    },
    city: {
        ...MAILING_ADDRESS_CITY,
        label: CITY
    },
    county: {
        ...MAILING_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...MAILING_ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...MAILING_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode: {
        ...MAILING_ADDRESS_ZIP5,
        label: ZIP
    },
    postalCode4: {
        ...MAILING_ADDRESS_ZIP4,
        label: ZIP
    },
    latitude: {
        ...MAILING_LATITUDE
    },
    longitude: {
        ...MAILING_LONGITUDE
    }
};

const memberFields = [
  FIRST_NAME,
  LAST_NAME,
  VERIFICATION_FLAG,

    PHYSICAL_ADDRESS_LINE1,
    PHYSICAL_ADDRESS_LINE2,
    PHYSICAL_ADDRESS_CITY,
    PHYSICAL_ADDRESS_COUNTY,
    PHYSICAL_ADDRESS_STATE,
    PHYSICAL_ADDRESS_COUNTRY,
    PHYSICAL_ADDRESS_ZIP4,
    PHYSICAL_ADDRESS_ZIP5,
    PHYSICAL_LATITUDE,
    PHYSICAL_LONGITUDE,

    MAILING_ADDRESS_LINE1,
    MAILING_ADDRESS_LINE2,
    MAILING_ADDRESS_CITY,
    MAILING_ADDRESS_COUNTY,
    MAILING_ADDRESS_STATE,
    MAILING_ADDRESS_COUNTRY,
    MAILING_ADDRESS_ZIP4,
    MAILING_ADDRESS_ZIP5,
    MAILING_LATITUDE,
    MAILING_LONGITUDE,

    HAVE_DIFFERENT_MAILING_ADDRESS,
    HAVE_PHYSICAL_ADDRESS,
    SAME_ADDRESS_AS_HOH,
    ALL_HAVE_SAME_ADDRESS,

    UTILITY_EXPENSE,
    SHELTER_EXPENSE
];

const toggleToBoolean = {
    [toggleFieldValue.yes]: true,
    [toggleFieldValue.no]: false,
    [toggleFieldValue.unknown]: null
};

const booleanToToggle = {
    true: toggleFieldValue.yes,
    false: toggleFieldValue.no,
    null: toggleFieldValue.unknown
};

export default class SspPrimaryApplicantAddressPage extends NavigationMixin(
    BaseNavFlowPage
) {
    toggleButtonOptions = [
        { label: YES, value: toggleFieldValue.yes },
        { label: NO, value: toggleFieldValue.no }
    ];

    @track label = {};
    @track isHoh = true;
    @track addressRecord;
    @track primaryMemberId;
    @track havePhysicalAddress = true;
    @track isMailingAddressDifferent = null;
    @track doesEveryMemberHasSameAddress = null;
    @track haveSameAddressInformationAsHoh = false;
    @track isMailingAddressDifferentToggleValue = null;
    @track spinnerOn = true;
    @track MetaDataListParent;
    @track shelterExpense;
    @track utilityExpense;
    @track differentAddressFieldValue;

    @track wiredGetMemberCompleted = false;
    @track wiredGetPrimaryMemberCompleted = false;
    @track bIsDataLoaded = false;
    @track bIsAddressChanged = false;
    @api memberId;
    @api flowName;
    @api mode;
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track userRole;
  @track nonCitizenVerified = false;
  @track userDetails = {}; //Defect-391009
    /**
     * @function : Getter setters for application Id.
     * @description : Getter setters for application Id.
     */
    @api
    get applicationId () {
        return this.applicationIdValue;
    }
    set applicationId (value) {
        if (!sspUtility.isUndefinedOrNull(value) && !sspUtility.isEmpty(value)) {
            this.applicationIdValue = value;
            this.getAddressInformationDetails();
        }
    }

    //#383004
    get disableHasPhysicalAddress () {
        return this.haveSameAddressInformationAsHoh || this.isReadOnlyUser;
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: memberFields
    })
    wiredGetMember (value) {
        this.wiredMember = value;
        const { error, data } = value;
        try {
            if (data) {
                this.wiredGetMemberCompleted = true;
                this.member = JSON.parse(JSON.stringify(data));
                this.addressRecord = this.member;

                this.haveSameAddressInformationAsHoh = getFieldValue(
                    this.member,
                    SAME_ADDRESS_AS_HOH
                );
        this.nonCitizenVerified = getFieldValue(this.member, VERIFICATION_FLAG);
                this.updateFields();
                this.updateLabels();
            } else if (error) {
                this.wiredGetMemberCompleted = true;
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (e) {
            console.error(e);
        }
    }

    @wire(getExpenseDetails, {
        memberId: "$memberId"
    })
    wiredExpenseRecords (value) {
        const { error, data } = value;
        try {
            if (data) {
                const expenseData = data.mapResponse.assetsList;
                this.assetList = expenseData;
            } else if (error) {
                console.error(error);
            }
        } catch (e) {
            console.error(e);
        }
    }

    getAddressInformationDetails = () => {
        getPrimaryApplicantData({
            applicationId: this.applicationIdValue
        })
            .then(data => {
                if (data) {
                    const response = data;
                    if (response && response.mapResponse) {
                        if (this.memberId !== response.mapResponse.member.Id) {
                            this.primaryMemberId = response.mapResponse.member.Id;
                            this.isHoh = this.primaryMemberId === this.memberId;
                            this.isMailingAddressDifferentToggleValue = this.isHoh
                                ? this.differentAddressFieldValue
                                : this.differentAddressFieldValue
                                ? this.differentAddressFieldValue
                                : toggleFieldValue.no;
                        } else {
                            if (
                                response.mapResponse.member[
                                    ALL_HAVE_SAME_ADDRESS.fieldApiName
                                ] !== null &&
                                response.mapResponse.member[
                                    ALL_HAVE_SAME_ADDRESS.fieldApiName
                                ] !== undefined
                            ) {
                                this.doesEveryMemberHasSameAddress =
                                    response.mapResponse.member[
                                        ALL_HAVE_SAME_ADDRESS.fieldApiName
                                    ] === toggleFieldValue.yes;
                            }
                        }
                    }
                }
                this.queryMetadata(this.isHoh); //2.5 Security Role Matrix and Program Access.
            })
            .catch(error => {
                console.error(JSON.parse(JSON.stringify(error)));
            });
    };

    @wire(getRecord, {
        recordId: "$primaryMemberId",
        fields: memberFields
    })
    wiredGetPrimaryMember ({ error, data }) {
        if (data) {
            this.wiredGetPrimaryMemberCompleted = true;
            this.primaryMember = JSON.parse(JSON.stringify(data));
            this.updateLabels();
        } else if (error) {
            this.wiredGetPrimaryMemberCompleted = true;
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value) {
            //CD2 2.5	Security Role Matrix and Program Access.
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
                this.showAccessDeniedComponent = !this.isScreenAccessible;
            }

            this.MetaDataListParent = value;
            this.bIsDataLoaded = true;
            this.spinnerOn = false;
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (value) {
            this.nextValue = value;
            this.validateData();
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (value) {
            this.saveData(value);
        }
    }

    //2.5	Security Role Matrix and Program Access.
    get showContents () {
        return this.bIsDataLoaded && this.isScreenAccessible;
    }

    //2.5	Security Role Matrix and Program Access.
    get disableAddress () {
        return this.haveSameAddressInformationAsHoh || this.isReadOnlyUser;
    }

    get showScreen () {
        return this.wiredGetPrimaryMemberCompleted && this.wiredGetMemberCompleted;
    }

    get mailingAddFieldMap () {
        return MA_FIELD_MAP;
    }

    get fieldMap () {
        if (this.havePhysicalAddress) {
            return PA_FIELD_MAP;
        }
        return MA_FIELD_MAP;
    }

    get doesEveryMemberHasSameAddressToggleValue () {
        if (
            this.doesEveryMemberHasSameAddress !== undefined &&
            this.doesEveryMemberHasSameAddress !== null
        ) {
            return booleanToToggle[this.doesEveryMemberHasSameAddress];
        } else {
            return getFieldValue(this.addressRecord, ALL_HAVE_SAME_ADDRESS);
        }
    }

    /**
     * @function queryMetadata
     * @description Fetches metadata field validation  - 2.5 Security Role Matrix and Program Access.
     */
    queryMetadata () {
        try {
            const fieldList = memberFields.map(item =>
                [item.fieldApiName, item.objectApiName].join(",")
            );
            //2.5 Security Role Matrix and Program Access.
            if (!this.isHoh) {
                fieldList.push("SSP_APP_NonPrimary_Address,ScreenName");
            }
            this.getMetadataDetails(fieldList, null, "SSP_APP_Primary_Address");
        } catch (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    /**
     * @function isNotEmpty
     * @param {object} record - Address record to be checked.
     * @description Checks if the any of the object property has some truthy value.
     */
    isNotEmpty = record =>
        Object.values(MA_FIELD_MAP).some(field => !!getFieldValue(record, field));
    /**
     * @function connectedCallback
     * @description This method is called every time is loaded.
     */
    connectedCallback () {
    this.getUserDetailsInfo(); //Defect-391009
    }

    /**
     * @function connectedCallback
     * @description Fetches metadata field validation.
     */
    updateLabels = () => {
        const unicorn0 = /\{0\}/g;
        const unicorn1 = /\{1\}/g;
        try {
            let memberName = "";
            let primaryApplicantName = "";
            if (this.member) {
                memberName = [
                    getFieldValue(this.member, FIRST_NAME),
                    getFieldValue(this.member, LAST_NAME)
                ]
                    .filter(item => !!item)
                    .join(" ");
            }
            if (this.primaryMember) {
                primaryApplicantName = [
                    getFieldValue(this.primaryMember, FIRST_NAME),
                    getFieldValue(this.primaryMember, LAST_NAME)
                ]
                    .filter(item => !!item)
                    .join(" ");
            }
            this.label = {
                haveSameAddressInformationAsHoh: HAVE_ADDRESS_AS_HOH_LABEL.replace(
                    unicorn0,
                    memberName
                ).replace(unicorn1, primaryApplicantName),
                havePhysicalAddress: HAVE_PHYSICAL_ADDRESS_LABEL.replace(
                    unicorn0,
                    memberName
                ),
                haveDifferentMailingAddress: DIFFERENT_MAILING_ADDRESS_LABEL.replace(
                    unicorn0,
                    memberName
                ),
                haveSameAddressInformation: HAVE_SAME_ADDRESS_LABEL.replace(
                    unicorn0,
                    memberName
                ),
                sameAddressInfoAltText: sameAddressInfoAltText
                    .replace(unicorn0, memberName)
                    .replace(unicorn1, primaryApplicantName)
            };
        } catch (e) {
            console.error(e);
        }
    };

    /**
     * @function validateData
     * @description Runs validation on entered address.
     */
    validateData = async () => {
        try {
            let elements = [];
            elements = Array.from(
                this.template.querySelectorAll(".ssp-address-input")
            );
            const addressElement1 = this.template.querySelector(".ssp-address1");
            if (addressElement1) {
                addressElement1.ErrorMessages();
                elements = elements.concat(Array.from(addressElement1.inputElements));
            }
            const addressElement2 = this.template.querySelector(".ssp-address2");
            if (addressElement2) {
                addressElement2.ErrorMessages();
                elements = elements.concat(Array.from(addressElement2.inputElements));
            }
            elements.map(element => element.ErrorMessages());
            this.templateInputsValue = elements;
            const hasSameAddressAsHOHElement = this.template.querySelector(
                "c-ssp-base-component-input-checkbox"
            );
            const revRules = [];
            const hasChanged =
                (!!addressElement1 && addressElement1.hasChanged) ||
                (!!addressElement2 && addressElement2.hasChanged) ||
                (hasSameAddressAsHOHElement &&
                    hasSameAddressAsHOHElement.oldValue === false &&
                    hasSameAddressAsHOHElement.value == true);
            if (
                !sspUtility.isUndefinedOrNull(addressElement1) &&
                !sspUtility.isEmpty(addressElement1) &&
                addressElement1.hasChanged
            ) {
                this.bIsAddressChanged = true;
            }
            if (hasChanged) {
                if(this.mode !== applicationMode.RAC){
                    sspUtility.markScreenReviewRequired(
                        this.applicationId,
                        "SSP_APP_HHMembersSummary"
                    );
                }
                const hasUtilityExpense =
                    getFieldValue(this.member, UTILITY_EXPENSE) === toggleFieldValue.yes;
                const hasShelterExpense =
                    getFieldValue(this.member, SHELTER_EXPENSE) === toggleFieldValue.yes;
                const expenseData = this.assetList;
                let existingData;
                expenseData.forEach(function (item) {
                    if (item.IsExistingData__c) {
                        existingData = true;
                    }
                });

                if (hasUtilityExpense || hasShelterExpense) {
                    revRules.push(["hasExpensesRule", true, this.memberId].join(","));
                    if (existingData) {
                        revRules.push(
                            ["hasExistingExpensesRule", true, this.memberId].join(",")
                        );
                    }
                }
                if (!hasUtilityExpense || !hasShelterExpense) {
                    revRules.push(
                        this.mode === applicationMode.RAC
                            ? "noExpensesRuleRAC," + true + "," + this.memberId
                            : "noExpensesRule," + true + ",null"
                    );
                }
            }
            const response = await getAllNonHohMembers({
                applicationId: this.applicationId
            });
            if (
                Array.isArray(response.mapResponse.memberIdList) &&
                response.mapResponse.memberIdList.length > 0
            ) {
                const originalValue =
                    getFieldValue(this.addressRecord, ALL_HAVE_SAME_ADDRESS) ===
                    toggleFieldValue.yes;
                const newValue = this.doesEveryMemberHasSameAddress === true;
                if (originalValue !== newValue) {
                    revRules.push(
                        [
                            "DontHaveSameAddressAsHOH",
                            originalValue && !newValue,
                            response.mapResponse.memberIdList
                        ].join(",")
                    );
                }
            }
            this.reviewRequiredList = revRules;
            
        } catch (error) {
            console.error("Error in validateData:", error);
        }
    };

    /**
     * @function saveData
     * @description Saves the data on salesforce.
     */
    saveData = () => {
        try {
            if (!this.memberId) {
                return;
            }
            this.spinnerOn = true;
            const addressElement1 = this.template.querySelector(".ssp-address1");
            const addressElement2 = this.template.querySelector(".ssp-address2");
            let physicalAddress = {};
            let mailingAddress = {};

            if (addressElement1 && this.havePhysicalAddress) {
                physicalAddress = addressElement1.value;
            } else if (addressElement1) {
                mailingAddress = addressElement1.value;
            }
            if (addressElement2 && this.isMailingAddressDifferent) {
                mailingAddress = addressElement2.value;
            }
            const fields = {
                [MEMBER_ID.fieldApiName]: this.memberId,
                [HAVE_PHYSICAL_ADDRESS.fieldApiName]:
                    booleanToToggle[this.havePhysicalAddress],
                [HAVE_DIFFERENT_MAILING_ADDRESS.fieldApiName]: this
                    .isMailingAddressDifferentToggleValue,
                [ALL_HAVE_SAME_ADDRESS.fieldApiName]:
                    booleanToToggle[this.doesEveryMemberHasSameAddress],
                [SAME_ADDRESS_AS_HOH.fieldApiName]: this
                    .haveSameAddressInformationAsHoh,
                [PHYSICAL_ADDRESS_LINE1.fieldApiName]:
                    physicalAddress.addressLine1 || null,
                [PHYSICAL_ADDRESS_LINE2.fieldApiName]:
                    physicalAddress.addressLine2 || null,
                [PHYSICAL_ADDRESS_CITY.fieldApiName]: physicalAddress.city || null,
                [PHYSICAL_ADDRESS_COUNTY.fieldApiName]: physicalAddress.county || null,
                [PHYSICAL_ADDRESS_STATE.fieldApiName]: physicalAddress.state || null,
                [PHYSICAL_ADDRESS_COUNTRY.fieldApiName]:
                    physicalAddress.country || null,
                [PHYSICAL_ADDRESS_ZIP5.fieldApiName]:
                    physicalAddress.postalCode || null,
                [PHYSICAL_LATITUDE.fieldApiName]: physicalAddress.latitude || null,
                [PHYSICAL_LONGITUDE.fieldApiName]: physicalAddress.longitude || null,
                [MAILING_ADDRESS_LINE1.fieldApiName]:
                    mailingAddress.addressLine1 || null,
                [MAILING_ADDRESS_LINE2.fieldApiName]:
                    mailingAddress.addressLine2 || null,
                [MAILING_ADDRESS_CITY.fieldApiName]: mailingAddress.city || null,
                [MAILING_ADDRESS_COUNTY.fieldApiName]: mailingAddress.county || null,
                [MAILING_ADDRESS_STATE.fieldApiName]: mailingAddress.state || null,
                [MAILING_ADDRESS_COUNTRY.fieldApiName]: mailingAddress.country || null,
                [MAILING_ADDRESS_ZIP5.fieldApiName]: mailingAddress.postalCode || null,
                [MAILING_LATITUDE.fieldApiName]: mailingAddress.latitude || null,
                [MAILING_LONGITUDE.fieldApiName]: mailingAddress.longitude || null
            };
            updateAddress({
                address: fields,
                applicationId: this.applicationId,
                bIsAddressChanged: this.bIsAddressChanged
            })
                .then(response => {
                    if (response && response.bIsSuccess === true) {
            if (
              this.userRole === "Contact_Center_View_and_Edit" &&
              this.mode === applicationMode.INTAKE &&
              !this.nonCitizenVerified &&
              this.isHoh === true && //Defect-391009 
              this.userDetails.showCitizenDashboard === "false" //Defect-391009 
            ) {
                            this.navigateToRIDP();
                        }
                        this.spinnerOn = false;
                        this.saveCompleted = true;
                        return refreshApex(this.wiredMember);
                    }
                    return Promise.reject(response);
                })
                .catch(error => {
                    this.spinnerOn = false;
                    this.saveCompleted = false;
                    console.error(JSON.parse(JSON.stringify(error || {})));
                });
        } catch (error) {
            console.error("Error in saveData:", error);
        }
    };

    /**
     * @function togglePhysicalMailingAddress
     * @description Toggles fieldMap for the first address element.
     * @param {object} event - Event object for capturing value.
     */
    togglePhysicalMailingAddress = event => {
        this.havePhysicalAddressToggleValue = event.target.value;
        this.havePhysicalAddress =
            toggleToBoolean[this.havePhysicalAddressToggleValue];
    };

    /**
     * @function toggleIsMailingAddressDifferent
     * @description Sets appropriate reactive flag.
     * @param {object} event - Event object for capturing value.
     */
    toggleIsMailingAddressDifferent = event => {
        this.isMailingAddressDifferentToggleValue = event.target.value;
        this.isMailingAddressDifferent =
            toggleToBoolean[this.isMailingAddressDifferentToggleValue];
    };

    /**
     * @function toggleDoesEveryMemberHasSameAddress
     * @description Sets appropriate reactive flag.
     * @param {object} event - Event object for capturing value.
     */
    toggleDoesEveryMemberHasSameAddress = event => {
        this.doesEveryMemberHasSameAddress = toggleToBoolean[event.target.value];
    };

    /**
     * @function toggleHaveSameAddressInformationAsHoh
     * @description Sets appropriate reactive flags and toggles between address records.
     * @param {object} event - Event object for capturing value.
     */
    toggleHaveSameAddressInformationAsHoh = event => {
        try {
            this.haveSameAddressInformationAsHoh = event.target.value;
            if (this.primaryMember && this.primaryMember.Id === this.memberId) {
                return;
            }
            if (this.haveSameAddressInformationAsHoh) {
                this.addressRecord = this.primaryMember;
            } else {
                this.addressRecord = this.member;
            }
            this.updateFields();
        } catch (error) {
            console.error(
                "Error in toggleHaveSameAddressInformationAsHoh:",
                error
            );
        }
    };

    /**
     * @function updateFields
     * @description Updates the various field values on the screen.
     */
    updateFields () {
        try {
            this.differentAddressFieldValue = getFieldValue(
                this.addressRecord,
                HAVE_DIFFERENT_MAILING_ADDRESS
            );
            this.havePhysicalAddressToggleValue =
                getFieldValue(this.addressRecord, HAVE_PHYSICAL_ADDRESS) ||
                toggleFieldValue.yes;
            this.isMailingAddressDifferentToggleValue = this.isHoh
                ? this.differentAddressFieldValue
                : this.differentAddressFieldValue
                ? this.differentAddressFieldValue
                : toggleFieldValue.no;
            this.havePhysicalAddress =
                toggleToBoolean[this.havePhysicalAddressToggleValue];
            this.isMailingAddressDifferent =
                toggleToBoolean[this.isMailingAddressDifferentToggleValue];

            this.doesEveryMemberHasSameAddress =
                toggleToBoolean[this.doesEveryMemberHasSameAddressToggleValue];
        } catch (error) {
            console.error("Error in updateFields:", error);
        }
    }

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try {
            if (
                !sspUtility.isUndefinedOrNull(metaValue) &&
                Object.keys(metaValue).length > 0
            ) {
                const { securityMatrix } = this.constructVisibilityMatrix(
                    !sspUtility.isUndefinedOrNull(appPrograms) &&
                        appPrograms != ""
                        ? appPrograms
                        : []
                );
                this.isReadOnlyUser =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission === permission.readOnly;
                this.isScreenAccessible =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission == permission.notAccessible
                        ? false
                        : true;                
            } else {
                this.isScreenAccessible = true;
            }
        } catch (e) {
            console.error(
                "Error in sspPrimaryApplicantContactPage.constructRenderingMap",
                e
            );
        }
    };
  //Start - Added as part of Defect-391009
  getUserDetailsInfo () {
    getUserDetails()
      .then(result => {
          if (!sspUtility.isUndefinedOrNull(result)) {
              this.userRole = result.userRole;
              this.userDetails = result;
          }
      })
      .catch(error => {
        console.error(
          "Error at sspPrimaryApplicantAddressPage => getUserDetailsInfo",
          error
        );
      });
  }
  //End - Added as part of Defect-391009

    navigateToRIDP = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "RIDP__c"
                },
                state: {
                    memberId: this.memberId,
                    applicationId: this.applicationIdValue,
                    mode: this.mode
                }
            });
        } catch (error) {
            console.error(
                "Error in navigateToRIDP => sspPrimaryApplicantAddressPage",
                error
            );
        }
    };
}
