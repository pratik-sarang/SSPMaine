/*
 * Component Name: sspCommunityIntegrationSupplementation.
 * Author:  Shekhar Chandra,Nikhil Shinde.
 * Description: This component takes information if the individual is requesting for CIS due to mental illness.
 * Date: 22-04-2020
 */


import { track, api } from "lwc";
import utility, { getYesNoOptions } from "c/sspUtility";
import { formatLabels } from "c/sspUtility";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import ADDRESS_LINE1 from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorAddressLine1__c";
import ADDRESS_LINE2 from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorAddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorCity__c";
import ADDRESS_COUNTY from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorCountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorStateCode__c";
import ADDRESS_ZIP4 from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorZipcode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/SSP_ApplicationIndividual__c.CareCoordinatorZipcode5__c";

import sspCISCompleteQuestionsText from "@salesforce/label/c.SSP_CISCompleteQuestionsText";
import sspCISDetails from "@salesforce/label/c.SSP_CISDetails";
import sspCISStartDate from "@salesforce/label/c.SSP_CISStartDate";
import sspCISEndDate from "@salesforce/label/c.SSP_CISEndDate";
import sspCISHasHadAMentalIllness from "@salesforce/label/c.SSP_CISHasHadAMentalIllness";
import sspCISUnlikelyToImproveWithoutTreatment from "@salesforce/label/c.SSP_CISUnlikelyToImproveWithoutTreatment";
import sspCISWhichDoesNotIncludePrimaryDiagnosis from "@salesforce/label/c.SSP_CISWhichDoesNotIncludePrimaryDiagnosis";
import sspCISPreventedFromBeingInstitutionalized from "@salesforce/label/c.SSP_CISPreventedFromBeingInstitutionalized";
import sspCISCareCoordinatorDetails from "@salesforce/label/c.SSP_CISCareCoordinatorDetails";
import sspCISWhoCoordinates from "@salesforce/label/c.SSP_CISWhoCoordinates";
import sspCISCoordinatorName from "@salesforce/label/c.SSP_CISCoordinatorName";
import sspCISCoordinatorAddress from "@salesforce/label/c.SSP_CISCoordinatorAddress";
import sspCISCoordinatorAddressLine2 from "@salesforce/label/c.SSP_CISCoordinatorAddressLine2";
import sspCISCaretakerPhoneNumber from "@salesforce/label/c.SSP_CISCaretakerPhoneNumber";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";

import getCISMemberData from "@salesforce/apex/SSP_CISCareTakerController.fetchRequiredData";
import updateApplicationIndividuals from "@salesforce/apex/SSP_CISCareTakerController.updateApplicationIndividuals";

const PA_FIELD_MAP = {
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspCISCoordinatorAddress,
        fieldApiName:
            sspConstants.appIndividualFields.CareCoordinatorAddressLine1__c,
        objectApiName: sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspCISCoordinatorAddressLine2,
        fieldApiName:
            sspConstants.appIndividualFields.CareCoordinatorAddressLine2__c,
        objectApiName: sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c
    },
    city: {
        ...ADDRESS_CITY,
        label: sspConstants.addressLabels.City
    },
    county: {
        ...ADDRESS_COUNTY,
        label: sspConstants.addressLabels.County
    },
    state: {
        ...ADDRESS_STATE,
        label: sspConstants.addressLabels.State
    },
    zipCode4: {
        ...ADDRESS_ZIP4,
        label: sspConstants.addressLabels.Zip
    },
    zipCode5: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    }
};
export default class SspCommunityIntegrationSupplementation extends BaseNavFlowPage {

    @api memberName;

    @track showSpinner = false;
    @track yesNoPicklist = getYesNoOptions();
    @track metaDataListParent;
    @track fieldMap = PA_FIELD_MAP;
    @track addressRecord;
    @track CISRelations;
    @track cisObjectValue;
    @track individualPrograms = [];
    @track renderingMap = {
        [sspConstants.appIndividualFields.CISStartDate__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CISEndDate__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .MentalIllnessImpairsFunctioningToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .MentalIllnessNeedsTreatmentToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .MentalIllnessWithoutAlzheimersToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .IsServiceStoppingInstitutalizationToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CareCoordinatorRelationship__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CareCoordinatorName__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CareCoordinatorPhoneNumber__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CareCoordinatorAddressLine1__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        }
    };
    @track appIndividual = [];

    @track renderingAttributes = {
        connectedCallBackExecuted: false,
        validationMetadataRetrieved: false,
        requiredDataRetrieved: false,
        isDataProcessed: true,
        fieldVisibilityDetermined: false
    };

    @track label = {
        sspCISCompleteQuestionsText,
        sspCISDetails,
        sspCISStartDate,
        sspCISEndDate,
        sspCISHasHadAMentalIllness,
        sspCISUnlikelyToImproveWithoutTreatment,
        sspCISWhichDoesNotIncludePrimaryDiagnosis,
        sspCISPreventedFromBeingInstitutionalized,
        sspCISCareCoordinatorDetails,
        sspCISWhoCoordinates,
        sspCISCoordinatorName,
        sspCISCoordinatorAddress,
        sspCISCoordinatorAddressLine2,
        sspCISCaretakerPhoneNumber,
        sspPlaceholderPhoneNumber
    };

    applicationId;
    memberId;
    accessiblePrograms = [];
    accessDetails = {};
    appPrograms = [];
    roleToProgramAccess = {};
    cisRenderValue = false;
    phoneMaxLength = 12;
    /**
     * @function : allowSaveData
     * @description	: To handle saving logic.
     */

    @api
    get allowSaveData () {
        return this.validationFlag;
    }

    /**
     * @function : allowSaveData
     * @description	: To handle saving logic.
     * @param  {object} value - FieldApi to value mapping of validation passed fields.
     */
    set allowSaveData (value) {
        this.validationFlag = value;
       
        try {
            if (value !== undefined && value !== "") {
                this.renderingAttributes.isDataProcessed = false;
                this.saveData(value);
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.allowSaveData " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : nextEvent
     * @description	: To handle next click from framework next button.
     */

    @api
    get nextEvent () {
        return this.nextValue;
    }
    /**
     * @function : nextEvent
     * @description	: To handle next click from framework next button.
     * @param  {object} value - Next value.
     */
    set nextEvent (value) {
        try {
            if (value !== undefined && value !== "") {
                this.nextValue = value;
                this.checkValidation(); // use to check validations on component
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.nextEvent " +
                    JSON.stringify(error)
            );
        }
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
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
                const self = this;
                Object.keys(value).forEach(key => {
                    const fieldAPI = !sspUtility.isUndefinedOrNull(key)
                        ? key.split(sspConstants.symbols.comma)[0]
                        : [];

                    if (
                        !sspUtility.isUndefinedOrNull(fieldAPI) &&
                        !sspUtility.isUndefinedOrNull(
                            self.renderingMap[fieldAPI]
                        )
                    ) {
                        self.renderingMap[
                            fieldAPI
                        ].programs = !sspUtility.isUndefinedOrNull(
                            value[key].Programs__c
                        )
                            ? value[key].Programs__c.split(
                                  sspConstants.symbols.comma
                              )
                            : [];
                    }
                });
                this.renderingAttributes.validationMetadataRetrieved = true;
                this.determineFieldVisibility();
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.MetadataList " +
                    JSON.stringify(error)
            );
        }
    }

    /**
    * @function : sspMemberId
    * @description	: Fetch required data in setting valid sspMemberId.
     */
    @api
    get sspMemberId () {
        return this.memberId;
    }

    /**
     * @function : sspMemberId
     * @description	: Fetch required data in setting valid sspMemberId.
     * @param  {string} value - Member Id.
     */
    set sspMemberId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.memberId = value;
                this.fetchCISMemberData();
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.sspMemberId " +
                    JSON.stringify(error)
            );
        }
    }

    /**
    * @function : sspApplicationId
    * @description	: Fetch required data in setting valid sspApplicationId.
    */
    @api
    get sspApplicationId () {
        return this.applicationId;
    }

    /**
     * @function : sspApplicationId
     * @description	: Fetch required data in setting valid sspApplicationId.
     * @param  {string} value - Application id.
     */
    set sspApplicationId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.applicationId = value;
                this.fetchCISMemberData();
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.sspApplicationId " +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 	: appId.
     * @description : This attribute is part of validation framework which gives the application ID.
     * */
    @api
    get appId () {
        return this.applicationId;
    }
    /**
     * @function 	: appId.
     * @description : This attribute is part of validation framework which gives the application ID.
     * @param  {string} value - App Id.
     * */
    set appId (value) {
        this.applicationId = value;
        this.fetchCISMemberData();
    }

    /**
     * @function : isVisible
     * @description	: Get property to identify if component is ready to render UI elements.
     */
    get isVisible () {
        let renderPage = true;
        try {
            const renderingAttributes = this.renderingAttributes;
            Object.keys(renderingAttributes).forEach(attribute => {
                renderPage = renderPage && renderingAttributes[attribute];
            });
        } catch (error) {
            console.error(
                "Error in sspCommunityIntegrationSupplementation.isVisible : " +
                    JSON.stringify(error)
            );
        }
        return renderPage;
    }

    /**
     * @function : connectedCallback
     * @description	: Runs on load to take care of initializing entity mapping list and replace labels data dynamically.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "CISStartDate__c,SSP_ApplicationIndividual__c",
                "CISEndDate__c,SSP_ApplicationIndividual__c",
                "MentalIllnessImpairsFunctioningToggle__c,SSP_ApplicationIndividual__c",
                "MentalIllnessNeedsTreatmentToggle__c,SSP_ApplicationIndividual__c",
                "MentalIllnessWithoutAlzheimersToggle__c,SSP_ApplicationIndividual__c",
                "IsServiceStoppingInstitutalizationToggle__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorRelationship__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorName__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorAddressLine1__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorCity__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorStateCode__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorZipcode4__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorZipcode5__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorCountyCode__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorAddressLine2__c,SSP_ApplicationIndividual__c",
                "CareCoordinatorPhoneNumber__c,SSP_ApplicationIndividual__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_MD_CIS"
            );
            Object.keys(this.label).forEach(labelKey => {
                this.label[labelKey] = formatLabels(this.label[labelKey], [
                    this.memberName
                ]);
            });
            this.fetchCISMemberData();
            this.renderingAttributes.connectedCallBackExecuted = true;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback of CIS page" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function - fetchCISMemberData().
     * @description - This method is used to get health selection data for members of application.
     */
    fetchCISMemberData = () => {
        try {
            getCISMemberData({
                sspApplicationId: this.applicationId,
                sspMemberId: this.memberId,
                callingComponent: "sspCommunityIntegrationSupplementation"
            })
                .then(result => {
                    const cisData = result.mapResponse;

                    if (
                        result.bIsSuccess &&
                        !utility.isUndefinedOrNull(cisData)
                    ) {
                        if (
                            cisData.hasOwnProperty("applicationIndividuals") &&
                            cisData.applicationIndividuals.length > 0
                        ) {
                            const appIndividual =
                                cisData.applicationIndividuals[0];
                            this.appPrograms =
                                !sspUtility.isUndefinedOrNull(appIndividual) &&
                                !sspUtility.isUndefinedOrNull(
                                    appIndividual.SSP_Application__r
                                        .ProgramsApplied__c
                                ) &&
                                appIndividual.SSP_Application__r
                                    .ProgramsApplied__c !== ""
                                    ? appIndividual.SSP_Application__r.ProgramsApplied__c.split(
                                          ";"
                                      )
                                    : [];
                            this.individualPrograms =
                                !sspUtility.isUndefinedOrNull(appIndividual) &&
                                !sspUtility.isUndefinedOrNull(
                                    appIndividual.ProgramsApplied__c
                                ) &&
                                appIndividual.ProgramsApplied__c !== ""
                                    ? appIndividual.ProgramsApplied__c.split(
                                          ";"
                                      )
                                    : [];
                            this.appIndividual = appIndividual;
                            this.setAddressLineStructure();
                        }
                        if (cisData.hasOwnProperty("cisRelations")) {
                            const CISRelations = [];
                            const retrievedCISRelations = cisData.cisRelations;
                            Object.keys(retrievedCISRelations).forEach(key => {
                                CISRelations.push({
                                    label: retrievedCISRelations[key],
                                    value: key
                                });
                            });
                            this.CISRelations = CISRelations;
                        }
                        if (cisData.hasOwnProperty("accessDetails")) {
                            this.accessDetails = cisData.accessDetails;
                        }
                        if (cisData.hasOwnProperty("accessiblePrograms")) {
                            this.accessiblePrograms =
                                cisData.accessiblePrograms;
                        }
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error in retrieving data sspCommunityIntegrationSupplementation  " +
                                JSON.stringify(cisData.ERROR)
                        );
                    }
                    this.renderingAttributes.requiredDataRetrieved = true;
                    this.determineFieldVisibility();
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in fetchCISMemberData of health selection page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - setAddressLineStructure.
     * @description - Use to set the Address Line Structure on Page Load.
     */
    setAddressLineStructure = () => {
        try {
            //Start - Address Line Structure
            const addressRecord = {};
            addressRecord.apiName = "SSP_ApplicationIndividual__c";
            addressRecord.id = this.appIndividual.Id;

            const sFields = {};

            const addressLine1 = {};
            addressLine1.displayValue = null;
            addressLine1.value =
                this.appIndividual.CareCoordinatorAddressLine1__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorAddressLine1__c
            ] = addressLine1;

            const addressLine2 = {};
            addressLine2.displayValue = null;
            addressLine2.value =
                this.appIndividual.CareCoordinatorAddressLine2__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorAddressLine2__c
            ] = addressLine2;

            const city = {};
            city.displayValue = null;
            city.value = this.appIndividual.CareCoordinatorCity__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorCity__c
            ] = city;

            const countyCode = {};
            countyCode.displayValue = null;
            countyCode.value =
                this.appIndividual.CareCoordinatorCountyCode__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorCountyCode__c
            ] = countyCode;

            const stateCode = {};
            stateCode.displayValue = null;
            stateCode.value =
                this.appIndividual.CareCoordinatorStateCode__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorStateCode__c
            ] = stateCode;

            const zipCode4 = {};
            zipCode4.displayValue = null;
            zipCode4.value =
                this.appIndividual.CareCoordinatorZipcode4__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorZipcode4__c
            ] = zipCode4;

            const zipCode5 = {};
            zipCode5.displayValue = null;
            zipCode5.value =
                this.appIndividual.CareCoordinatorZipcode5__c || null;
            sFields[
                sspConstants.appIndividualFields.CareCoordinatorZipcode5__c
            ] = zipCode5;

            addressRecord.fields = sFields;
            this.addressRecord = JSON.parse(JSON.stringify(addressRecord));
            //End - Address Line Structure
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setAddressLineStructure" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on ApplicationIndividual record.
     * @param {object} ApplicationIndividual - ApplicationIndividual record.
     */
    bindAddressFields = ApplicationIndividual => {
        try {
            const addressLineClass = this.template.querySelector(
                ".addressLineClass"
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                ApplicationIndividual[
                    sspConstants.appIndividualFields.CareCoordinatorAddressLine1__c
                ] = !utility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                ApplicationIndividual[
                    sspConstants.appIndividualFields.CareCoordinatorAddressLine2__c
                ] = !utility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                ApplicationIndividual[
                    sspConstants.appIndividualFields.CareCoordinatorCity__c
                ] = !utility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                ApplicationIndividual[
                    sspConstants.appIndividualFields.CareCoordinatorCountyCode__c
                ] = !utility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                ApplicationIndividual[
                    sspConstants.appIndividualFields.CareCoordinatorStateCode__c
                ] = !utility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                const zipCode = physicalAddress.postalCode;
                if (!utility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        ApplicationIndividual[
                            sspConstants.appIndividualFields.CareCoordinatorZipcode4__c
                        ] = zipCode;
                        ApplicationIndividual[
                            sspConstants.appIndividualFields.CareCoordinatorZipcode5__c
                        ] = "";
                    } else {
                        ApplicationIndividual[
                            sspConstants.appIndividualFields.CareCoordinatorZipcode5__c
                        ] = zipCode;
                        ApplicationIndividual[
                            sspConstants.appIndividualFields.CareCoordinatorZipcode4__c
                        ] = "";
                    }
                }
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.bindAddressFields " +
                    JSON.stringify(error)
            );
        }
        return ApplicationIndividual;
    };
    /**
     * @function : determineFieldVisibility
     * @description	: Method to determine field level access(Render/ Hide/ Read/ Write).
     */
    determineFieldVisibility = () => {
        try {
            if (
                this.renderingAttributes.validationMetadataRetrieved &&
                this.renderingAttributes.requiredDataRetrieved
            ) {
                const renderingMap = this.renderingMap;
                const appliedPrograms = this.appPrograms;
                const self = this;
                const accessiblePrograms = this.accessiblePrograms;
                Object.keys(renderingMap).forEach(key => {
                    const isReadOnly =
                        !sspUtility.isUndefinedOrNull(this.accessDetails) &&
                        !sspUtility.isUndefinedOrNull(
                            this.accessDetails.screenPermission
                        ) &&
                        this.accessDetails.screenPermission === "ReadOnly"
                            ? true
                            : false;

                    const programRequiredToRenderField =
                        renderingMap[key].programs;

                    //renderingMap[key].renderElement
                    const appLevelProgramAccess = !utility.isUndefinedOrNull(
                        appliedPrograms
                    )
                        ? programRequiredToRenderField.some(programCode =>
                              appliedPrograms.includes(programCode)
                          )
                        : false;

                    const roleLevelProgramAccess = !sspUtility.isUndefinedOrNull(
                        accessiblePrograms
                    )
                        ? programRequiredToRenderField.some(programCode =>
                              accessiblePrograms.includes(programCode)
                          )
                        : false;

                    if (
                        key ===
                        sspConstants.appIndividualFields
                            .IsCaretakerLivingTogetherToggle__c
                    ) {
                        self.cisRenderValue =
                            appLevelProgramAccess && roleLevelProgramAccess;
                    }
                    renderingMap[key].renderElement =
                        appLevelProgramAccess && roleLevelProgramAccess;
                    renderingMap[key].isDisabled = isReadOnly;
                });
                this.appliedPrograms = appliedPrograms;
                this.renderingAttributes.fieldVisibilityDetermined = true;
                this.renderingAttributes.fieldVisibilityDetermined = true;
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.determineFieldVisibility " +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : saveData
     * @description	: Method to save data to server.
     * @param {string} value - JSON of successfully validated field values.
     */
    saveData = value => {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                const appIndividualRecord = JSON.parse(value);
                appIndividualRecord.Id = this.appIndividual.Id;
                this.appIndividualRecord = this.bindAddressFields(
                    appIndividualRecord
                );
                this.cisObjectValue = JSON.stringify([appIndividualRecord]);
                const objectToSave = this.cisObjectValue;

                updateApplicationIndividuals({
                    serializedJSON: objectToSave
                })
                    .then(result => {
                        const parsedData = result.mapResponse;
                        if (
                            !utility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty("ERROR")
                        ) {
                            console.error(
                                "Error in retrieving data sspCommunityIntegrationSupplementation  " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (
                            !utility.isUndefinedOrNull(result) &&
                            result.bIsSuccess
                        ) {
                            //this.renderingAttributes.isDataProcessed = true;
                            this.saveCompleted = true;
                            this.fetchCISMemberData();
                        }
                    })
                    .catch(error => {
                        console.error(
                            "failed in sspCommunityIntegrationSupplementation.saveData " +
                                JSON.stringify(error)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.saveData " +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : checkValidation
     * @description	: Method to check field validations.
     */
    checkValidation = () => {
        try {
            let inputFields = [];
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            templateAppInputs.forEach(function (entity) {
                //const isDisabled = entity.disabled;
                //if (!utility.isUndefinedOrNull(isDisabled) && !isDisabled) {
                inputFields.push(entity);
                // }
            });
             //for Address-Line 1 
            const addressElement1 = this.template.querySelector(
                ".ssp-address1"
            );
            if (addressElement1) {
                addressElement1.ErrorMessages();
            }
            inputFields = inputFields.concat(
                Array.from(addressElement1.inputElements)
            );
            this.templateInputsValue = inputFields; //setting base cmp attribute
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.checkValidation " +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : handleStartDateChange
     * @description	: Method to handle onchange event for service start date.
     * @param {object{}} event - Onchange event.
     */
    handleStartDateChange = event => {
        try {
            let startDate = event.target.value;
            if (utility.isUndefinedOrNull(startDate)) {
                startDate = "";
                this.appIndividual[
                    sspConstants.appIndividualFields.CISStartDate__c
                ] = startDate;
            } else {
                this.renderingAttributes.isDataProcessed = false;
                this.appIndividual[
                    sspConstants.appIndividualFields.CISStartDate__c
                ] = startDate;
                this.renderingAttributes.isDataProcessed = true;
                const endDateInput = this.template.querySelectorAll(
                    ".ssp-inputEndDate"
                );
                if (
                    !utility.isUndefinedOrNull(endDateInput) &&
                    !utility.isUndefinedOrNull(
                        this.appIndividual[
                            sspConstants.appIndividualFields.CISEndDate__c
                        ]
                    )
                ) {
                    endDateInput[0].comparingDate = startDate;
                    endDateInput[0].ErrorMessages();
                }
            }
        } catch (error) {
            console.error(
                "failed in sspCommunityIntegrationSupplementation.handleStartDateChange " +
                    JSON.stringify(error)
            );
        }
    };
}