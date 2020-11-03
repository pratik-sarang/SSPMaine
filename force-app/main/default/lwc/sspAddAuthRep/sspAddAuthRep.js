/**
 * Component Name: sspAddAuthRep.
 * Author: Shrikant Raut, Soumyashree Jena.
 * Description: The component is to add/edit auth rep.
 * Date:  12/08/2019.
 */

import { api, track, wire } from "lwc";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspRepsAssistAgentsTitle from "@salesforce/label/c.SSP_Reps_Assisters_Agents_Title";
import sspAddAuthReps from "@salesforce/label/c.SSP_AddAuthReps";
import sspAddAuthRepsInfo1 from "@salesforce/label/c.SSP_AddAuthRepsInfo1";
import sspAddAuthRepsInfo2 from "@salesforce/label/c.SSP_AddAuthRepsInfo2";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspMiOptional from "@salesforce/label/c.SSP_MI_Optional";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspSuffix from "@salesforce/label/c.SSP_Suffix_Optional";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspSearchAuthRep from "@salesforce/label/c.SSP_SearchAuthRep";
import sspSSN from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspGender from "@salesforce/label/c.SSP_Gender";
import sspDateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspPhoneNumber from "@salesforce/label/c.SSP_OnlyPhoneNumber";
import sspExt from "@salesforce/label/c.SSP_Ext_Optional";
import sspPreferredLanguage from "@salesforce/label/c.SSP_AddAuthRepPreferredLang";
//import sspPersonRelation from "@salesforce/label/c.SSP_AddAuthRepPersonRelation"; // Commented - As a part of CD2 R3 Section 5.8.1.1
import sspQuestion2 from "@salesforce/label/c.SSP_AddAuthRepQuestion2";
import sspOrganizationName from "@salesforce/label/c.OrganizationName";
import sspOrganizationId from "@salesforce/label/c.SSP_OrganizationId";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspClose from "@salesforce/label/c.SSP_Close";
import sspStartTyping from "@salesforce/label/c.sspNotUSCitizenPlaceHolder";
import fetchContactInformation from "@salesforce/apex/SSP_AddAuthRepController.fetchContactInformation";
import checkForDuplicateAuthRep from "@salesforce/apex/SSP_AddAuthRepController.checkForDupicateAuthRep";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import { refreshApex } from "@salesforce/apex";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import CONTACT_GENDER from "@salesforce/schema/Contact.GenderCode__c";
import CONTACT_SUFFIX from "@salesforce/schema/Contact.SuffixCode__c";
import CONTACT_PREFERRED_LANGUAGE from "@salesforce/schema/Contact.PreferredLanguageCode__c";
import sspAuthorizedRepresentativeSearchResults from "@salesforce/label/c.SSP_AuthorizedRepresentativeSearchResults";
import sspFoundMatchInDatabase from "@salesforce/label/c.SSP_FoundMatchInDatabase";
import sspPersonYouWantAdd from "@salesforce/label/c.SSP_PersonYouWantAdd";
import sspUseMatchedRepresentative from "@salesforce/label/c.SSP_UseMatchedRepresentative";
import sspEnterTheInformationMyself from "@salesforce/label/c.SSP_EnterTheInformationMyself";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import sspContinueEnteringInformation from "@salesforce/label/c.SSP_ContinueEnteringInformation";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";

import sspSuffixTitle from "@salesforce/label/c.SSP_SuffixTitle";
import sspGenderTitle from "@salesforce/label/c.SSP_GenderTitle";
import sspSearchForIndividualWithThisNameAndEmail from "@salesforce/label/c.SSP_SearchForIndividualWthThisNameAndEmail";
import sspStartTypingOrClickHereToSeePreferredLanguageOptions from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeePreferredLanguageOptions";
//import sspClickHereToSeeOptionsForRelationships from "@salesforce/label/c.SSP_ClickHereToSeeOptionsForRelationships"; // Commented - As a part of CD2 R3 Section 5.8.1.1
import sspContinueToNextScreenToEnterFurtherDetails from "@salesforce/label/c.SSP_ContinueToNextScreenToEnterFurtherDetails";
import sspCancelEnteringDetailsAuthorizedRepresentative from "@salesforce/label/c.SSP_CancelEnteringDetailsAuthorizedRepresentative";

import sspUseMatchedRepTitle from "@salesforce/label/c.SSP_UseMatchedRepTitle";
import sspEnterInfoMyselfTitle from "@salesforce/label/c.SSP_EnterInfoMyselfTitle";
import sspContinueEnteringInfoTitle from "@salesforce/label/c.SSP_ContinueEnteringInfoTitle";



export default class SspAddAuthRep extends sspUtility {
    @api sspContactId;
    @api sspApplicationId;
    @api authRepRequest;
    @api flowName = sspConstants.addAuthRepConstants.addAuthRep;
    sspApplicationAccount;
    languageLabelToValueMapping;
    languageValueToLabelMapping;
    customLabel = {
        sspUseMatchedRepTitle,
        sspEnterInfoMyselfTitle,
        sspContinueEnteringInfoTitle,
        sspYes,
        sspNo,
        toastErrorText,
        sspRepsAssistAgentsTitle,
        sspAddAuthReps,
        sspAddAuthRepsInfo1,
        sspAddAuthRepsInfo2,
        sspFirstName,
        sspMiOptional,
        sspLastName,
        sspSuffix,
        sspEmail,
        sspSearchAuthRep,
        sspSSN,
        sspGender,
        sspDateOfBirth,
        sspPhoneNumber,
        sspExt,
        sspPreferredLanguage,
        sspQuestion2,
        sspOrganizationName,
        sspOrganizationId,
        sspCancel,
        sspNext,
        sspMaxLength: sspConstants.validationEntities.phoneExtensionMaxLength,
        sspAuthorizedRepresentativeSearchResults,
        sspFoundMatchInDatabase,
        sspPersonYouWantAdd,
        sspUseMatchedRepresentative,
        sspEnterTheInformationMyself,
        sspNoResultsFound,
        sspContinueEnteringInformation,
        sspMiddleInitialMaxLength:
            sspConstants.validationEntities.sspMiddleInitialMaxLength,
        sspClose,
        sspSuffixTitle,
        sspGenderTitle,
        sspSearchForIndividualWithThisNameAndEmail,
        sspStartTypingOrClickHereToSeePreferredLanguageOptions,
        sspContinueToNextScreenToEnterFurtherDetails,
        sspCancelEnteringDetailsAuthorizedRepresentative,
        sspPlaceholderPhoneNumber,
        sspStartTyping
    };

    @track searchButtonVisibility = {
        [sspConstants.contactFields.FirstName]: false,
        [sspConstants.contactFields.LastName]: false,
        [sspConstants.contactFields.Email]: false
    };
    @track isSearchPerformed = false;
    @track responseOptions = [
        {
            label: this.customLabel.sspYes,
            value: sspConstants.toggleFieldValue.yes
        },
        {
            label: this.customLabel.sspNo,
            value: sspConstants.toggleFieldValue.no
        }
    ];
    inputTypePassword = sspConstants.inputTypes.password;
    @track metaDataListParent;
    @track genderOptions;
    @track suffixOptions;
    @track preferredLanguageOptions;
    @track permissionParam;
    @track permissionClass;
    @track accountContactRelation = {
        [sspConstants.accountContactRelationFields
            .RepresentativeRelationshipCode__c]: ""
    };
    @track contact = {
        [sspConstants.contactFields.FirstName]: "",
        [sspConstants.contactFields.MiddleName]: "",
        [sspConstants.contactFields.LastName]: "",
        [sspConstants.contactFields.SuffixCode__c]: "",
        [sspConstants.contactFields.Email]: "",
        [sspConstants.contactFields.SSN__c]: "",
        [sspConstants.contactFields.GenderCode__c]: "",
        [sspConstants.contactFields.BirthDate]: null,
        [sspConstants.contactFields.Phone]: "",
        [sspConstants.contactFields.Street__c]: "",
        [sspConstants.contactFields.City__c]: "",
        [sspConstants.contactFields.CountyCode__c]: "",
        [sspConstants.contactFields.SSP_State__c]: "",
        [sspConstants.contactFields.ZipCode5__c]: "",
        [sspConstants.contactFields.ZipCode4__c]: "",
        [sspConstants.contactFields.AddressLine2__c]: "",
        [sspConstants.contactFields.PreferredLanguageCode__c]: "",
        [sspConstants.contactFields.OrganizationName__c]: "",
        [sspConstants.contactFields.OrganizationIdentificationNumber__c]: "",
        [sspConstants.contactFields.PrimaryPhoneExtension__c]: "",
        [sspConstants.contactFields.DoesAuthRepHasOrg__c]: ""
    };
    @track worksForAnOrganizationToggleValue = false;
    @track isSelectedViaSearch = false;    
    @track retrievedData;    
    @track showSpinner = true;
    @track isVisible = false;
    @track showAuthRepScreen = true;
    @track renderingAttributes = {
        contactInformationFetched: false,
        representativeRelationshipCodesFetched: false,
        genderValuesRetrieved: false,
        suffixValuesRetrieved: false,
        preferredLanguagesRetrieved: false,
        connectedCallBackExecuted: false,
        validationMetadataRetrieved: false
    };
    @track hasSaveValidationError = false;
    //@track representativeRelationshipCodes; // Commented - As a part of CD2 R3 Section 5.8.1.1
    @track trueValue = true;
    @track preferredLanguage;
    @track recordTypeId;
    @track objValue;
    @track showDuplicateModal;
    @track duplicateContact;
    @track duplicateAddress;
    @track duplicateAddressURL;
    @track showNoResultPopUp;
    @track duplicateEmailLink;
    @track duplicatePhoneLink;
    @track showPermissionScreen;
    @track ACRId;
    @track isEdit = false;    
    @track contactRecord;
    @track relationRecord;
    @track detailRecord;
    @track reference = this;
    @track organizationName;
    @track isOrgAuthRep = false; //#390707
    @track organizationId;
    @track disableNext = true;
    @track contactInformation = {}; //Added as a part of CD2 R3 Section 5.8.1.1
    
    /**
     * @function : getObjectData
     * @description	: Wire call to retrieve contact metadata.
     * @param {object} objData - Retrieved data.
     */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    getObjectData ({ data }) {
        try {
            if (data) {
                const recordTypeInfo =
                    data[sspConstants.sspMemberConstants.RecordTypesInfo];
                this.recordTypeId = Object.keys(recordTypeInfo).find(
                    recordTypeId =>
                        recordTypeInfo[recordTypeId].name ===
                        sspConstants.contactRecordTypes.Auth_Rep
                );
            }
        } catch (error) {
            console.error(
                "Error in retrieving data sspAddAuthRep.getObjectData" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchContactInformation
     * @description	: Wire call to retrieve contact details from server.
     * @param {object} objData - Retrieved data.
     */
    @wire(fetchContactInformation, {
        sspContactId: "$sspContactId",
        sspApplicationId: "$sspApplicationId",
        callingComponent: "sspAddAuthRep"
    })
    fetchContactInformation (objData) {
        try {
            if (!sspUtility.isUndefinedOrNull(objData.data)) {
                this.retrievedData = objData;
                if (this.retrievedData.data) {
                    const parsedData = this.retrievedData.data.mapResponse;
                    this.contactInformation = this.retrievedData.data.mapResponse; //Added as a part of CD2 R3 Section 5.8.1.1
                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty(
                            sspConstants.addAuthRepConstants.ERROR
                        )
                    ) {
                        console.error(
                            "Error in retrieving data sspChangeExistingIncome" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else {
                        //setting contact data
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                "organizationName"
                            )
                        ) {
                           
                         this.organizationName = parsedData.organizationName;
                        }
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                "organizationId"
                            )
                        ) {
                         this.organizationId = parsedData.organizationId;
                        }

                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants.contactRecord
                            )
                        ) {
                            const contactRecord = JSON.stringify(
                                parsedData.contactRecord
                            );
                            this.setContactData(JSON.parse(contactRecord));
                        }

                      
                        //setting AccountContactRelation data
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants
                                    .accountContactRelationRecord
                            )
                        ) {
                            const accountContactRelation = JSON.stringify(
                                parsedData.accountContactRelationRecord
                            );
                            this.accountContactRelation = JSON.parse(
                                accountContactRelation
                            );
                        }

                        //setting RepresentativeRelationshipCode values
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants
                                    .relationshipCodes
                            )
                        ) {
                      
                            this.renderingAttributes.representativeRelationshipCodesFetched = true;
                        }

                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants
                                    .applicationAccount
                            )
                        ) {
                            this.sspApplicationAccount =
                                parsedData.applicationAccount;
                        }
                    }
                }
                refreshApex(this.retrievedData).then(() => {
                    this.renderingAttributes.contactInformationFetched = true;
                    this.setVisibility();
                });
            } else if (!sspUtility.isUndefinedOrNull(objData.error)) {
                console.error(
                    "Error in retrieving data sspAddAuthRep.fetchContactInformation" +
                        JSON.stringify(objData.error)
                );
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.fetchContactInformation " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchGenderValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Gender api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_GENDER
    })
    fetchGenderValues ({ error, data }) {
        try {
            if (data) {
                this.genderOptions = data.values;
                this.renderingAttributes.genderValuesRetrieved = true;
                this.setVisibility();
            } else if (error) {
                console.error(
                    "Error in sspAddAuthRep.fetchGenderValues: " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspAddAuthRep.fetchGenderValues: " +
                    JSON.stringify(err)
            );
        }
    }

    /**
     * @function : fetchSuffixValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Suffix api name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_SUFFIX
    })
    fetchSuffixValues ({ error, data }) {
        try {
            if (data) {
                this.suffixOptions = data.values;
                this.renderingAttributes.suffixValuesRetrieved = true;
                this.setVisibility();
            } else if (error) {
                console.error(
                    "Error in sspAddAuthRep.fetchSuffixValues: " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspAddAuthRep.fetchSuffixValues: " +
                    JSON.stringify(err)
            );
        }
    }

    /**
     * @function : fetchPreferredLanguageValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Preferred Language api name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_PREFERRED_LANGUAGE
    })
    fetchPreferredLanguageValues ({ error, data }) {
        try {
            if (data) {
                const values = data.values;
                const languageLabelToValueMapping = {};
                const languageValueToLabelMapping = {};
                this.preferredLanguageOptions = values;

                if (!sspUtility.isUndefinedOrNull(values)) {
                    values.forEach(function (entry) {
                        languageLabelToValueMapping[entry.label] = entry.value;
                        languageValueToLabelMapping[entry.value] = entry.label;
                    });
                }
                this.languageLabelToValueMapping = languageLabelToValueMapping;
                this.languageValueToLabelMapping = languageValueToLabelMapping;
                this.setPreferredLanguage();
                this.renderingAttributes.preferredLanguagesRetrieved = true;
                this.setVisibility();
            } else if (error) {
                console.error(
                    "Error in sspAddAuthRep.fetchPreferredLanguageValues: " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspAddAuthRep.fetchPreferredLanguageValues: " +
                    JSON.stringify(err)
            );
        }
    }

    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
     * @function : MetadataList
     * @description	: Set property to assign entity mapping values to metaDataListParent.
     * @param {object} value - SF entity mapping values.
     */
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
                this.renderingAttributes.validationMetadataRetrieved = true;
                this.setVisibility();
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setMetadataList: " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : objWrap
     * @description :this attribute contains validated data which is used to save.
     */
    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        try {
            if (!sspUtility.isUndefinedOrNull(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.objWrap " + JSON.stringify(error)
            );
        }
    }

    /**
     * @function : connectedCallback
     * @description	: Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.contactFields.FirstName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.MiddleName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.LastName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.SuffixCode__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.Email +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.SSN__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.GenderCode__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.BirthDate +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.Phone +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
              
                sspConstants.contactFields.PreferredLanguageCode__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,               
                sspConstants.contactFields.OrganizationName__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.OrganizationIdentificationNumber__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.PrimaryPhoneExtension__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.DoesAuthRepHasOrg__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "REPS_AddAuthorizedRepresentative1"
            );
            this.isSearchPerformed = !sspUtility.isUndefinedOrNull(
                this.sspContactId
            )
                ? true
                : this.isSearchPerformed;
            this.renderingAttributes.connectedCallBackExecuted = true;
            this.setVisibility();
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : disableSearch
     * @description	: Method to identify the visibility of search button.
     */
    get disableSearch () {
        let result = this.isSelectedViaSearch;
        try {
            const searchVisibilityCriteria = this.searchButtonVisibility;

            Object.keys(searchVisibilityCriteria).forEach(entity => {
                if (!searchVisibilityCriteria[entity]) {
                    result = true;
                }
            });
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.disableSearch " + JSON.stringify(error)
            );
        }
        return result;
    }

    /**
     * @function : isVisible
     * @description	: Get property to identify if component is ready to render UI elements.
     */
    setVisibility = () => {
        try {
            let renderPage = true;
            if (sspUtility.isUndefinedOrNull(this.sspContactId)) {
                this.renderingAttributes.contactInformationFetched = true;
            }
            const renderingAttributes = this.renderingAttributes;
            Object.keys(renderingAttributes).forEach(attribute => {
                renderPage = renderPage && renderingAttributes[attribute];
            });
            this.isVisible = renderPage;
            this.showSpinner = !this.isVisible;
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.hideToast: " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : setPreferredLanguage
     * @description	: Method to bind label of preferred language code to preferredLanguage.
     */
    setPreferredLanguage = () => {
        try {
            if (
                !sspUtility.isUndefinedOrNull(this.contact) &&
                !sspUtility.isUndefinedOrNull(
                    this.contact[
                        sspConstants.contactFields.PreferredLanguageCode__c
                    ]
                ) &&
                !sspUtility.isUndefinedOrNull(this.languageValueToLabelMapping)
            ) {
                const languageCode = this.contact[
                    sspConstants.contactFields.PreferredLanguageCode__c
                ];
                this.preferredLanguage = this.languageValueToLabelMapping[
                    languageCode
                ];
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.setPreferredLanguage " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : setContactData
     * @description	: Method to set values to contact obj attributes.
     * @param {object} contactRecord - Contact record data fetched from server.
     */
    setContactData = contactRecord => {
        try {
            if (!sspUtility.isUndefinedOrNull(contactRecord)) {
                if (
                    sspUtility.isUndefinedOrNull(
                        contactRecord.IsManualAuthRep__c
                    ) ||
                    (!sspUtility.isUndefinedOrNull(
                        contactRecord.IsManualAuthRep__c
                    ) &&
                        !contactRecord.IsManualAuthRep__c)
                ) {
                    this.isSelectedViaSearch = true;
                }
                const selfContact = this.contact;
                const self = this;

                Object.keys(selfContact).forEach(fieldAPI => {
                    if (!sspUtility.isUndefinedOrNull(contactRecord)) {
                        self.contact[fieldAPI] = contactRecord[fieldAPI];
                    }
                });

                if (
                    !sspUtility.isUndefinedOrNull(this.contact) &&
                    !sspUtility.isUndefinedOrNull(
                        this.contact[
                            sspConstants.contactFields.DoesAuthRepHasOrg__c
                        ]
                    ) &&
                    !this.isSelectedViaSearch
                ) {
                    this.worksForAnOrganizationToggleValue =
                        this.contact[
                            sspConstants.contactFields.DoesAuthRepHasOrg__c
                        ] === sspConstants.toggleFieldValue.yes
                            ? true
                            : false;
                } else if (this.isSelectedViaSearch) {
                    if (
                        !sspUtility.isUndefinedOrNull(
                           this.organizationName
                        ) && this.isOrgAuthRep //#390707
                    ) {
                        this.worksForAnOrganizationToggleValue = true;
                        this.contact[
                            sspConstants.contactFields.OrganizationName__c
                        ] = this.organizationName;
                        this.contact[
                            sspConstants.contactFields.DoesAuthRepHasOrg__c
                        ] = "Y";
                        if (
                            !sspUtility.isUndefinedOrNull(
                               this.organizationId
                            ) 
                        ) {
                        this.contact[
                            sspConstants.contactFields.OrganizationIdentificationNumber__c
                        ] = this.organizationId;
                    }
                    } else {
                        this.worksForAnOrganizationToggleValue = false;
                        this.contact[
                            sspConstants.contactFields.DoesAuthRepHasOrg__c
                        ] = "N";
                    }
                   
                    this.setPreferredLanguage();
                    //this.setAddressLineStructure(); //Commented - As a part of CD2 R3 Section 5.8.1.1
                }else {
                    this.worksForAnOrganizationToggleValue = false;
                    this.contact[
                        sspConstants.contactFields.DoesAuthRepHasOrg__c
                    ] = "N";
                }
                if((!sspUtility.isUndefinedOrNull(
                    contactRecord.Id
                )) &&this.sspContactId !== contactRecord.Id){
                this.sspContactId = !sspUtility.isUndefinedOrNull(
                    contactRecord.Id
                )
                    ? contactRecord.Id
                    : this.sspContactId;
                }
                this.setPreferredLanguage();
                //this.setAddressLineStructure(); // Commented - As a part of CD2 R3 Section 5.8.1.1
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setContactData" +
                    JSON.stringify(error.message)
            );
        }
    };

 

    /**
     * @function : initSave.
     * @description	: Method to save the values entered/selected.
     */
    initSave = () => {
        try {
            let isError = false;
            const self = this;
            let contact = {};
            const templateAppInputs = [];
            if (!this.isSelectedViaSearch) {
                //this.template.querySelector(sspConstants.classNames.addressLineClass).ErrorMessages(); // Commented - As a part of CD2 R3 Section 5.8.1.1
                this.template
                    .querySelectorAll(
                        sspConstants.classNames.sspApplicationInputs
                    )
                    .forEach(function (inputElement) {
                        templateAppInputs.push(inputElement);
                    });
            }
            /* Commented - As a part of CD2 R3 Section 5.8.1.1
            else {
                const entity = this.template.querySelector(".ssp-existing");
                const errorMessageExisting = entity.ErrorMessages();

                if (
                    !sspUtility.isUndefinedOrNull(errorMessageExisting) &&
                    errorMessageExisting.length !== 0
                ) {
                    isError = true;
                }
                if (
                    entity.fieldName ===
                    sspConstants.accountContactRelationFields
                        .RepresentativeRelationshipCode__c
                ) {
                    self.accountContactRelation[entity.fieldName] =
                        entity.value;
                } else {
                    contact[entity.fieldName] = entity.value;
                }
            }*/
            /* Commented - As a part of CD2 R3 Section 5.8.1.1
            const addressElement = this.template.querySelector(
                sspConstants.classNames.addressLineClass
            );
            if (addressElement && !this.isSelectedViaSearch) {
                templateAppInputs = templateAppInputs.concat(
                    Array.from(addressElement.inputElements)
                );
            }*/

            this.showSpinner = true;
            contact = this.contact;
           

            templateAppInputs.push();
            templateAppInputs.forEach(function (entity) {
                const errorMessage = entity.ErrorMessages();
                if (
                    !sspUtility.isUndefinedOrNull(errorMessage) &&
                    errorMessage.length !== 0
                ) {
                    isError = true;
                } else if (!sspUtility.isUndefinedOrNull(entity.fieldName)) {
                    if (
                        entity.fieldName ===
                        sspConstants.contactFields.PreferredLanguageCode__c
                    ) {
                        const preferredLanguageCode =
                            self.languageLabelToValueMapping[entity.value];
                        if (
                            sspUtility.isUndefinedOrNull(preferredLanguageCode)
                        ) {
                            isError = true;
                        } else {
                            contact[entity.fieldName] = preferredLanguageCode;
                        }
                    } else if (
                        entity.fieldName !==
                            sspConstants.contactFields.Street__c ||
                        entity.fieldName !==
                            sspConstants.contactFields.AddressLine2__c
                    ) {
                       
                            contact[entity.fieldName] = entity.value;
                        
                    }
                }
            });

            if (!sspUtility.isUndefinedOrNull(this.sspContactId)) {
                contact.Id = this.sspContactId;
            }

            if(!contact["Birthdate"]) {
                contact["Birthdate"] = null;
            }
            if (!isError) {
                this.contact = contact;
                this.constructDataToSave([this.contact]);
            } else {
                this.hasSaveValidationError = true;
                this.showSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.initSave: " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : manageToggleQuestion
     * @description	: Method to manage change in toggle buttons.
     * @param {object} event - Onchange JS event.
     */
    manageToggleQuestion = event => {
        try {
            if (!sspUtility.isUndefinedOrNull(event.target.value)) {
                const worksForAnOrganization = event.target.value;
                if (
                    worksForAnOrganization === sspConstants.toggleFieldValue.no
                ) {
                    this.worksForAnOrganizationToggleValue = false;
                    this.contact[
                        sspConstants.contactFields.OrganizationName__c
                    ] = "";
                    this.contact[
                        sspConstants.contactFields.OrganizationIdentificationNumber__c
                    ] = "";
                } else {
                    this.worksForAnOrganizationToggleValue = true;
                }
            }
        } catch (error) {
            console.error(
                "error occurred sspAddAuthRep.manageToggleQuestion" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : constructDataToSave
     * @description	: Method to construct data to save to server.
     * @param {object[]} contactList - Contact record list.
     */
    constructDataToSave = contactList => {
        try {
            const detailMap = {
                isSelectedViaSearch:
                 this.isSelectedViaSearch, //only send the value of isSelectedViaSearch in case of add auth rep flow else send it as false
                flowName: this.flowName
            };

            //Map contact to AccountContactRelation if auth rep contact already exists
            if (
                sspUtility.isUndefinedOrNull(this.accountContactRelation.Id) &&
                !sspUtility.isUndefinedOrNull(this.sspContactId)
            ) {
                this.accountContactRelation.ContactId = this.sspContactId;
            }

            //In case of update flow, populating attributes needed by permission component
            if (!sspUtility.isUndefinedOrNull(this.accountContactRelation.Id)) {
                this.ACRId = this.accountContactRelation.Id;
              
                this.isEdit = true;
            }

            //If sspApplicationId not null (i.e. for update flow) copy applicationId, its accountId and AccountContactRelation record to detailMap
            if (!sspUtility.isUndefinedOrNull(this.sspApplicationId)) {
                detailMap.sspApplicationId = this.sspApplicationId;
                detailMap.sspApplicationAccount = this.sspApplicationAccount;
            }

            const mParam = {
                contactJSON: JSON.stringify(contactList),
                relationJSON: null,
                detailJSON: JSON.stringify(detailMap)
            };
            this.permissionParam = mParam;
          
            if (!sspUtility.isUndefinedOrNull(this.sspApplicationAccount)) {
                this.isEdit = true;
            }
            this.showSpinner = false;
            this.showPermissionScreen = true;
            this.permissionClass = "slds-show";
            this.showAuthRepScreen = false;
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.constructDataToSave " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.hideToast: " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : searchAuthRep
     * @description	: Server call to check Duplicate Auth Rep.
     */
    searchAuthRep = () => {
        try {
            const elem = this.template.querySelectorAll(
                sspConstants.classNames.sspApplicationDuplicateInputs
            );
            this.checkValidations(elem);

            if (
                this.allowSave &&
                !sspUtility.isUndefinedOrNull(this.objValue)
            ) {
                this.showSpinner = true;
                const mParam = {
                    sContactJSON: this.objValue
                };
                checkForDuplicateAuthRep(mParam)
                    .then(result => {
                        if (
                            sspConstants.addAuthRepConstants
                                .contactDuplicateRecord in result.mapResponse
                        ) {

                            this.isOrgAuthRep = (result.mapResponse && result.mapResponse.hasOwnProperty("isOrgAuthRep") && result.mapResponse.isOrgAuthRep && result.mapResponse.isOrgAuthRep === "Y"); //#390707

                            if (
                                !sspUtility.isUndefinedOrNull(
                                    result.mapResponse.contactDuplicateRecord
                                )
                            ) {
                                this.duplicateContact =
                                    result.mapResponse.contactDuplicateRecord;
                                this.showDuplicateModal = true;
                                this.duplicateEmailLink =
                                    sspConstants.addAuthRepConstants.mailto +
                                    this.duplicateContact.Email;
                                this.duplicatePhoneLink =
                                    sspConstants.addAuthRepConstants.tel +
                                    this.duplicateContact.Phone;
                            } else {
                                this.showNoResultPopUp = true;
                            }
                            if (
                                !sspUtility.isUndefinedOrNull(result.mapResponse) &&
                                result.mapResponse.hasOwnProperty(
                                    "organizationName"
                                )
                            ) {
                                this.organizationName = result.mapResponse.organizationName;
                            }
                            if (
                                !sspUtility.isUndefinedOrNull(result.mapResponse) &&
                                result.mapResponse.hasOwnProperty(
                                    "organizationId"
                                )
                            ) {
                                this.organizationId = result.mapResponse.organizationId;
                            }
                            if (
                                sspConstants.addAuthRepConstants
                                    .duplicateAddress in result.mapResponse
                            ) {
                                if (
                                    !sspUtility.isUndefinedOrNull(
                                        result.mapResponse.duplicateAddress
                                    )
                                ) {
                                    this.duplicateAddress =
                                        result.mapResponse.duplicateAddress;
                                    this.duplicateAddressURL =
                                        "https://www.google.com/maps/dir/?api=1&destination=" +
                                        result.mapResponse.duplicateAddress;
                                }
                            }
                        } else {
                            this.showNoResultPopUp = true;
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.error(
                            "error occurred sspAddAuthRep.searchAuthRep" +
                                JSON.stringify(error)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.searchAuthRep " + JSON.stringify(error)
            );
        }
    };
    /**
     * @function : loadDuplicateContact
     * @description	: method to duplicate contact.
     */
    loadDuplicateContact = () => {
        try {
            this.setContactData(this.duplicateContact);
            this.showDuplicateModal = false;
            this.isSelectedViaSearch = true;
            this.isSearchPerformed = true;
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.searchAuthRep " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : cancelDuplicateContact
     * @description	: method to close Modal.
     * @param {object} event - JS onchange event.
     */
    cancelDuplicateContact = (event) => {
        try {
            this.showDuplicateModal = false;
            this.showNoResultPopUp = false;
            this.isSelectedViaSearch = false;
            if (event.target.classList.contains("ssp-clicked-button")) {
                this.isSearchPerformed = true; 
            }
            else{
                this.isSearchPerformed = false; 
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.searchAuthRep " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : cancelDuplicateContact
     * @description	: method to close Modal.
     */
    showContactData = () => {
        try {
            this.showDuplicateModal = false;
            this.showNoResultPopUp = false;
            this.isSelectedViaSearch = false;
            this.isSearchPerformed = true;
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.searchAuthRep " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : handleValueChange
     * @description	: Method to handle field value change.
     * @param {object} event - JS onchange event.
     */
    handleValueChange = event => {
        try {
            const fieldName = event.target.dataset.id;
            const value = event.target.value;
            if (
                sspUtility.isUndefinedOrNull(value) ||
                (!sspUtility.isUndefinedOrNull(value) &&
                    value.trim().length === 0)
            ) {
                this.searchButtonVisibility[fieldName] = false;
            } else {
                this.searchButtonVisibility[fieldName] = true;
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.handleValueChange " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : handleCancel
     * @description	: Method to handle on click of Cancel button..
     */
    handleCancel () {
        this.dispatchEvent(new CustomEvent(sspConstants.events.cancel));
    }
    /**
     * @function : handleShowHomeOnSave
     * @description	: Method to handle on click of Cancel button..
     */
    handleShowHomeOnSave () {
        this.dispatchEvent(new CustomEvent(sspConstants.events.save));
    }

    /**
     * @function : handleShowPermissions
     * @description	: Method to handle on click of back button..
     */
    handleShowPermissions () {
        this.permissionClass = "slds-hide";
        this.showAuthRepScreen = true;
        if (!sspUtility.isUndefinedOrNull(this.contact)) {
            //this.setAddressLineStructure(); // Commented - As a part of CD2 R3 Section 5.8.1.1
            this.preferredLanguage = this.languageValueToLabelMapping[
                this.contact.PreferredLanguageCode__c
            ];
        }
    }

    /**
     * @function : renderedCallback
     * @description	: Method to handle on click of back button..
     */
    renderedCallback () {
        try {
            this.disableNext = !this.isSearchPerformed;
        } catch (error) {
            console.error(
                "failed in renderedCallback " + JSON.stringify(error)
            );
        }
    }
}