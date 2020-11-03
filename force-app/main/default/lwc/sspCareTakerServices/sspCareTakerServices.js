/**
 * Component Name: sspCareTakerServices.
 * Author: Shrikant Raut, Venkata Ranga Babu.
 * Description: Component for Caretaker Services Screen.
 * Date: 04/09/2020.
 */
import { track, api } from "lwc";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import sspCompleteTheQuestionsBelowAboutCaretakerServices from "@salesforce/label/c.SSP_CompleteTheQuestionsBelowAboutCaretakerServices";
import sspServiceStartDate from "@salesforce/label/c.SSP_ServiceStartDate";
import sspServiceEndDate from "@salesforce/label/c.SSP_ServiceEndDate";
import sspHaveTheServicesEnabledHerToSafelyAndComfortablyLiveAtHome from "@salesforce/label/c.SSP_HaveTheServicesEnabledHerToSafelyAndComfortablyLiveAtHome";
import sspHaveTheProvidedServicesPreventedFromBeingPutInNursingFacility from "@salesforce/label/c.SSP_HaveTheProvidedServicesPreventedFromBeingPutInNursingFacility";
import sspDoesReceiveTheServicesOnRegularBasis from "@salesforce/label/c.SSP_DoesReceiveTheServicesOnRegularBasis";
import sspDoesThisCaretakerLiveWith from "@salesforce/label/c.SSP_DoesThisCaretakerLiveWith";
import sspHowIsThisCaretakerRelatedTo from "@salesforce/label/c.SSP_HowIsThisCaretakerRelatedTo";
import sspNameOfCaretaker from "@salesforce/label/c.SSP_NameOfCaretaker";
import phoneNumber from "@salesforce/label/c.phonenumber";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import { formatLabels } from "c/sspUtility";
import fetchRequiredData from "@salesforce/apex/SSP_CISCareTakerController.fetchRequiredData";
import updateApplicationIndividuals from "@salesforce/apex/SSP_CISCareTakerController.updateApplicationIndividuals";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";

export default class SspCareTakerServices extends baseNavFlowPage {
    @api memberName = "";

    applicationId;
    memberId;
    appPrograms = [];
    accessiblePrograms = [];
    individualPrograms = [];
    //roleToProgramAccess = {};
    accessDetails = {};
    careTakerRenderValue = false;

    @track customLabels = {
        sspCompleteTheQuestionsBelowAboutCaretakerServices,
        sspServiceStartDate,
        sspServiceEndDate,
        sspNameOfCaretaker,
        phoneNumber,
        sspHaveTheServicesEnabledHerToSafelyAndComfortablyLiveAtHome,
        sspHaveTheProvidedServicesPreventedFromBeingPutInNursingFacility,
        sspDoesReceiveTheServicesOnRegularBasis,
        sspHowIsThisCaretakerRelatedTo,
        sspDoesThisCaretakerLiveWith
    };

    @track renderingMap = {
        [sspConstants.appIndividualFields.ServiceStartDate__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.ServiceEndDate__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.IsServiceProvidedSafelyToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .IsPreventedNursingFacilityToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields
            .IsServiceReceivedRegularlyToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CaretakerRelation__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.IsCaretakerLivingTogetherToggle__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CaretakerName__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        },
        [sspConstants.appIndividualFields.CaretakerPhone__c]: {
            renderElement: false,
            programs: [],
            isDisabled: false
        }
    };

    @track appIndividual = {
        [sspConstants.appIndividualFields.ServiceStartDate__c]: "",
        [sspConstants.appIndividualFields.ServiceEndDate__c]: "",
        [sspConstants.appIndividualFields.IsServiceProvidedSafelyToggle__c]: "",
        [sspConstants.appIndividualFields.IsPreventedNursingFacilityToggle__c]:
            "",
        [sspConstants.appIndividualFields.IsServiceReceivedRegularlyToggle__c]:
            "",
        [sspConstants.appIndividualFields.CaretakerRelation__c]: "",
        [sspConstants.appIndividualFields.IsCaretakerLivingTogetherToggle__c]:
            "",
        [sspConstants.appIndividualFields.CaretakerName__c]: "",
        [sspConstants.appIndividualFields.CaretakerPhone__c]: ""
    };

    @track metaDataListParent;
    @track careTakerRelations;
    @track validationFlag;
    @track nextValue;
    @track responseOptions = [
        { label: sspYes, value: sspConstants.toggleFieldValue.yes },
        { label: sspNo, value: sspConstants.toggleFieldValue.no }
    ];
    @track questionWrapperList = [];
    @track questionList = {
        sspHaveTheServicesEnabledHerToSafelyAndComfortablyLiveAtHome,
        sspHaveTheProvidedServicesPreventedFromBeingPutInNursingFacility,
        sspDoesReceiveTheServicesOnRegularBasis,
        sspHowIsThisCaretakerRelatedTo,
        sspDoesThisCaretakerLiveWith
    };
    @track renderingAttributes = {
        connectedCallBackExecuted: false,
        validationMetadataRetrieved: false,
        requiredDataRetrieved: false,
        isDataProcessed: true,
        fieldVisibilityDetermined: false
    };

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
        if (value !== undefined && value !== "") {
            this.renderingAttributes.isDataProcessed = false;
            this.saveData(value);
        }
    }

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
                "failed in sspCareTakerServices.nextEvent " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
     * @function : MetadataList
     * @description	: Setter for entity mapping records.
     * @param  {object} value - Entity mapping records.
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
                    const fieldAPI = key.split(sspConstants.symbols.comma)[0];
                    self.renderingMap[
                        fieldAPI
                    ].programs = !sspUtility.isUndefinedOrNull(
                        value[key].Programs__c
                    )
                        ? value[key].Programs__c.split(
                              sspConstants.symbols.comma
                          )
                        : [];
                });
                this.renderingAttributes.validationMetadataRetrieved = true;
                this.determineFieldVisibility();
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.MetadataList " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get sspMemberId () {
        return this.memberId;
    }

    /**
     * @function : sspMemberId
     * @description	: Setter for memberId.
     * @param  {string} value - Member id.
     */
    set sspMemberId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.memberId = value;
                this.fetchDataFromServer();
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.sspMemberId " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get sspApplicationId () {
        return this.applicationId;
    }

    /**
     * @function : sspApplicationId
     * @description	: Setter for applicationId.
     * @param  {string} value - Application id.
     */
    set sspApplicationId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.applicationId = value;
                this.fetchDataFromServer();
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.sspApplicationId " +
                    JSON.stringify(error)
            );
        }
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
                "Error in sspCareTakerServices.isVisible : " +
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
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.appIndividualFields.ServiceStartDate__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields.ServiceEndDate__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields
                    .IsServiceProvidedSafelyToggle__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields
                    .IsPreventedNursingFacilityToggle__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields
                    .IsServiceReceivedRegularlyToggle__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields.CaretakerRelation__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields
                    .IsCaretakerLivingTogetherToggle__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields.CaretakerName__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c,
                sspConstants.appIndividualFields.CaretakerPhone__c +
                    sspConstants.symbols.comma +
                    sspConstants.sspObjectAPI.SSP_ApplicationIndividual__c
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                sspConstants.screenIds.careTaker
            ); //calling base cmp method

            Object.keys(this.customLabels).forEach(labelKey => {
                this.customLabels[labelKey] = formatLabels(
                    this.customLabels[labelKey],
                    [this.memberName]
                );
            });
            this.fetchDataFromServer();
            this.renderingAttributes.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function : fetchDataFromServer
     * @description	: Method to fetch required data from server.
     */
    fetchDataFromServer = () => {
        try {
            if (
                !sspUtility.isUndefinedOrNull(this.memberId) &&
                !sspUtility.isUndefinedOrNull(this.applicationId)
            ) {
                fetchRequiredData({
                    sspApplicationId: this.applicationId,
                    sspMemberId: this.memberId,
                    callingComponent: "sspCareTakerServices"
                })
                    .then(result => {
                        const parsedData = result.mapResponse;
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty("ERROR")
                        ) {
                            console.error(
                                "Error in retrieving data sspCareTakerServices  " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (
                            result.bIsSuccess &&
                            !sspUtility.isUndefinedOrNull(parsedData)
                        ) {
                            if (
                                parsedData.hasOwnProperty(
                                    "applicationIndividuals"
                                )
                            ) {
                                const appIndividual =
                                    parsedData.applicationIndividuals[0];
                                this.appPrograms =
                                    !sspUtility.isUndefinedOrNull(
                                        appIndividual
                                    ) &&
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
                                    !sspUtility.isUndefinedOrNull(
                                        appIndividual
                                    ) &&
                                    !sspUtility.isUndefinedOrNull(
                                        appIndividual.ProgramsApplied__c
                                    ) &&
                                    appIndividual.ProgramsApplied__c !== ""
                                        ? appIndividual.ProgramsApplied__c.split(
                                              ";"
                                          )
                                        : [];
                                this.appIndividual = appIndividual;
                            }
                            if (
                                parsedData.hasOwnProperty("careTakerRelations")
                            ) {
                                const careTakerRelations = [];
                                const retrievedCareTakerRelations =
                                    parsedData.careTakerRelations;
                                Object.keys(
                                    retrievedCareTakerRelations
                                ).forEach(key => {
                                    careTakerRelations.push({
                                        label: retrievedCareTakerRelations[key],
                                        value: key
                                    });
                                });
                                this.careTakerRelations = careTakerRelations;
                            }
                            if (parsedData.hasOwnProperty("accessDetails")) {
                                this.accessDetails = parsedData.accessDetails;
                            }
                            if (
                                parsedData.hasOwnProperty("accessiblePrograms")
                            ) {
                                this.accessiblePrograms =
                                    parsedData.accessiblePrograms;
                            }
                        }
                        this.renderingAttributes.requiredDataRetrieved = true;
                        this.determineFieldVisibility();
                    })
                    .catch(error => {
                        console.error(
                            "failed in sspCareTakerServices.fetchDataFromServer " +
                                JSON.stringify(error)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.fetchDataFromServer " +
                    JSON.stringify(error)
            );
        }
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
                const accessiblePrograms = this.accessiblePrograms;
                const self = this;

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
                    const appLevelProgramAccess = !sspUtility.isUndefinedOrNull(
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

                    renderingMap[key].renderElement =
                        appLevelProgramAccess && roleLevelProgramAccess;
                    renderingMap[key].isDisabled = isReadOnly;

                    //to store the rendering value for caretaker living with question.
                    if (
                        key ===
                        sspConstants.appIndividualFields
                            .IsCaretakerLivingTogetherToggle__c
                    ) {
                        self.careTakerRenderValue =
                            appLevelProgramAccess && roleLevelProgramAccess;
                        renderingMap[key].renderElement = false; //for this field, rendering value will be determined by handleLivingTogetherQVisibility method.
                    }
                });
                this.appliedPrograms = appliedPrograms;
                this.handleLivingTogetherQVisibility(null);
                this.renderingAttributes.fieldVisibilityDetermined = true;
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.determineFieldVisibility " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : handleLivingTogetherQVisibility
     * @description	: Method to handle Living Together question visibility.
     * @param {object{}} event - Onchange event.
     */
    handleLivingTogetherQVisibility = event => {
        try {
            const careTakerRelation = !sspUtility.isUndefinedOrNull(event)
                ? event.target.value
                : this.appIndividual[
                      sspConstants.appIndividualFields.CaretakerRelation__c
                  ];

            if (!sspUtility.isUndefinedOrNull(careTakerRelation)) {
                this.renderingMap[
                    sspConstants.appIndividualFields.IsCaretakerLivingTogetherToggle__c
                ].renderElement =
                    this.careTakerRenderValue &&
                    sspConstants.careTakerServices.IsCaretakerLivingTogetherRenderRelation.includes(
                        careTakerRelation
                    );
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.handleLivingTogetherQVisibility " +
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
            if (!sspUtility.isUndefinedOrNull(value)) {
                const appIndividualRecord = JSON.parse(value);
                appIndividualRecord.Id = this.appIndividual.Id;

                if (
                    !sspConstants.careTakerServices.IsCaretakerLivingTogetherRenderRelation.includes(
                        appIndividualRecord.CaretakerRelation__c
                    )
                ) {
                    appIndividualRecord[
                        sspConstants.appIndividualFields.IsCaretakerLivingTogetherToggle__c
                    ] = "";
                }

                updateApplicationIndividuals({
                    serializedJSON: JSON.stringify([appIndividualRecord])
                })
                    .then(result => {
                        const parsedData = result.mapResponse;
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty("ERROR")
                        ) {
                            console.error(
                                "Error in retrieving data sspCareTakerServices  " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (
                            !sspUtility.isUndefinedOrNull(result) &&
                            result.bIsSuccess
                        ) {
                            //this.renderingAttributes.isDataProcessed = true;
                            this.saveCompleted = true;
                            this.fetchDataFromServer();
                        }
                    })
                    .catch(error => {
                        console.error(
                            "failed in sspCareTakerServices.saveData " +
                                JSON.stringify(error)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.saveData " +
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
            const inputFields = [];
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            templateAppInputs.forEach(function (entity) {
                const isDisabled = entity.disabled;
                if (!sspUtility.isUndefinedOrNull(isDisabled) && !isDisabled) {
                    inputFields.push(entity);
                }
            });
            this.templateInputsValue = inputFields; //setting base cmp attribute
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.checkValidation " +
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
            if (sspUtility.isUndefinedOrNull(startDate)) {
                startDate = "";
                this.appIndividual[
                    sspConstants.appIndividualFields.ServiceStartDate__c
                ] = startDate;
            } else {
                this.renderingAttributes.isDataProcessed = false;
                this.appIndividual[
                    sspConstants.appIndividualFields.ServiceStartDate__c
                ] = startDate;
                this.renderingAttributes.isDataProcessed = true;
                const endDateInput = this.template.querySelectorAll(
                    ".ssp-ServiceEndDate"
                );
                if (
                    !sspUtility.isUndefinedOrNull(endDateInput) &&
                    !sspUtility.isUndefinedOrNull(
                        this.appIndividual[
                            sspConstants.appIndividualFields.ServiceEndDate__c
                        ]
                    )
                ) {
                    endDateInput[0].comparingDate = startDate;
                    endDateInput[0].ErrorMessages();
                }
            }
        } catch (error) {
            console.error(
                "failed in sspCareTakerServices.handleStartDateChange " +
                    JSON.stringify(error)
            );
        }
    };
}