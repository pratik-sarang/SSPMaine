/**
 * Component Name: sspEntitledBenefits.
 * Author: Shrikant Raut.
 * Description: Component to handle entitled benefits screen.
 * Date: 11/28/2019.
 */
import { track, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspApplicationStatus from "@salesforce/label/c.SSP_ApplicationStatus";
import sspApplicationDate from "@salesforce/label/c.SSP_ApplicationDate";
import sspAtLeastOneValidationMessage from "@salesforce/label/c.SSP_SelectAtLeastOneValidatorMessage";
import sspCompleteEntitledBenefitsQuestions from "@salesforce/label/c.SSP_CompleteEntitledBenefitsQuestions";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import fetchBenefitDetails from "@salesforce/apex/SSP_EntitledBenefitsController.fetchBenefitDetails";
import sspConstants from "c/sspConstants";
import updateBenefits from "@salesforce/apex/SSP_EntitledBenefitsController.updateBenefits";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import sspBenefits from "@salesforce/schema/SSP_Benefits__c";
import benefitTypeCode from "@salesforce/schema/SSP_Benefits__c.BenefitTypeCode__c";
import statusOfApplication from "@salesforce/schema/SSP_Benefits__c.StatusofApplication__c";
import utility from "c/sspUtility";
import sspApplicationStatusAltText from "@salesforce/label/c.SSP_ApplicationStatusAltText";
import sspLearnMoreAltText from "@salesforce/label/c.SSP_EntitledBenefitsLearnMoreAltText";
import sspBenefitOrPlanApplied from "@salesforce/label/c.SSP_BenefitOrPlanApplied";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

const applicationStatusClass =
    "slds-size_1-of-1 slds-large-size_1-of-2 slds-p-horizontal_small slds-p-vertical_x-small ssp-applicationInputs";
const applicationDateClass =
    "slds-size_1-of-1 slds-large-size_1-of-2 slds-p-horizontal_small slds-p-vertical_x-small ssp-applicationInputs";
const benefitsTypeClass = "";
const programs = {
    MA: sspConstants.programValues.MA,
    KT: sspConstants.programValues.KT,
    SN: sspConstants.programValues.SN,
    SS: sspConstants.programValues.SS,
    DS: sspConstants.programValues.DS,
    CC: sspConstants.programValues.CC,
    KP: sspConstants.programValues.KP
};

const fieldToProgramMapping = {
    [sspConstants.sspBenefitsFields.BenefitTypeCode__c]: [
        programs.MA,
        programs.KT
    ],
    [sspConstants.sspBenefitsFields.StatusOfApplication__c]: [
        programs.MA,
        programs.KT
    ],
    [sspConstants.sspBenefitsFields.BenefitApplicationDate__c]: [
        programs.MA,
        programs.KT
    ]
};

export default class SspEntitledBenefits extends baseNavFlowPage {
    @api sspMemberId;
    @api sspApplicationId;
    @api memberFirstName;
    retrievedData;
    appliedPrograms = [];
    existingBenefitsRecords = [];
    applicationStatusValueToLabel = {};
    benefitTypesValueToLabel = {};
    benefitTypeToRecordMapping = {};
    benefitsIdList = [];
    entitledBenefitTypeId;
    label = {
        sspLearnMoreLink,
        sspApplicationStatus,
        sspApplicationDate,
        sspCompleteEntitledBenefitsQuestions,
        sspLearnMoreAltText,

        sspBenefitOrPlanApplied,
        sspApplicationStatusAltText,
        toastErrorText
    };
    @track reference = this;
    @track applicationStatusList;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track benefitValidationError = "";
    @track validationFlag;
    @track nextValue;
    @track metaDataListParent;
    @track benefitsWrapperList = [];
    @track connectedCallBackExecuted = false;
    @track validationMetadataLoaded = false;
    @track requiredDataFetched = false;
    @track openLearnMoreModel = false;
    @track modValue;

    @track fetchedResult;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track errorClass = false; // for defect 382490 by saurabh rathi

    @wire(getObjectInfo, { objectApiName: sspBenefits })
    objectInfo;

    /**
     * @function : fetchBenefitTypes
     * @description	: Wire method to fetch benefit type values.
     * @param {object} objData - Retrieved data.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$entitledBenefitTypeId",
        fieldApiName: benefitTypeCode
    })
    fetchBenefitTypes (objData) {
        try {
            if (objData.data !== undefined) {
                const pickListValues = objData.data.values;
                if (pickListValues !== null && pickListValues !== undefined) {
                    this.benefitTypesValueToLabel = this.constructPicklistValueToLabelMapping(
                        pickListValues
                    );
                    this.benefitTypeToRecordMapping = this.constructBenefitTypeToRecordMapping(
                        this.existingBenefitsRecords
                    );
                    this.constructRequiredWrapper(
                        this.benefitTypeToRecordMapping
                    );
                }
            }
        } catch (error) {  
            console.error(
                "failed in sspEntitledBenefits.fetchBenefitTypes " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchApplicationStatus
     * @description	: Wire method to fetch application status values.
     * @param {object} objData - Retrieved data.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$entitledBenefitTypeId",
        fieldApiName: statusOfApplication
    })
    fetchApplicationStatus (objData) {
        try {
            if (objData.data !== undefined) {
                const pickListValues = objData.data.values;
                if (pickListValues !== null && pickListValues !== undefined) {
                    this.applicationStatusList = pickListValues;
                    this.applicationStatusValueToLabel = this.constructPicklistValueToLabelMapping(
                        pickListValues
                    );
                }
            }
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.fetchApplicationStatus " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchExpenseData
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     * @param {object} objData - Retrieved data.
     */
    @wire(fetchBenefitDetails, {
        sspMemberId: "$sspMemberId",
        sspApplicationId: "$sspApplicationId",
        callingComponent: "sspEntitledBenefits"
    })
    fetchBenefitsData (objData) {
        try {
            if (objData.data !== undefined) {
                this.retrievedData = objData;
                if (this.retrievedData.data) {
                    const parsedData = this.retrievedData.data.mapResponse;
                    if (parsedData !== null && parsedData !== undefined) {
                        if (parsedData.hasOwnProperty("ERROR")) {
                            console.error(
                                "Error in retrieving data sspChangeExistingExpense" +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else {
                            this.extractBenefitRecords(parsedData);
                            this.setAppliedPrograms(parsedData);
                            this.entitledBenefitTypeId = parsedData.hasOwnProperty(
                                "entitledBenefitTypeId"
                            )
                                ? parsedData.entitledBenefitTypeId
                                : this.entitledBenefitTypeId;
                            this.requiredDataFetched = true;
                        }
                    }
                }
            } else if (objData.error !== undefined) {
                console.error(
                    "Error in retrieving data sspChangeExistingExpense" +
                        JSON.stringify(objData.error)
                );
            }
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.fetchBenefitsData " +
                    JSON.stringify(error)
            );
        }
    }
    /**
    * @function - renderedCallback
    * @description - This method is used to called whenever there is track variable changing.

    */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /*
     * @function : connectedCallback
     * @description	: Connected Callback - to fetch details for validation framework
     */
    connectedCallback () {
        //to retrieve validation metadata records
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.sspBenefitsFields.StatusOfApplication__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Benefits__c,
                sspConstants.sspBenefitsFields.BenefitApplicationDate__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Benefits__c
            );
            this.showHelpContentData("SSP_APP_Details_EntitledBenefits");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_EntitledBenefits"
            ); //calling base cmp method
            this.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value !== undefined && value !== "") {
                this.nextValue = value;
                this.saveData();
            }
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.nextEvent " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;
            if (value !== null && value !== undefined) {
                this.callSaveOnValidation();
            }
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.allowSaveData " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (value !== null && value !== undefined) {
                this.metaDataListParent = value;
                this.validationMetadataLoaded = true;
                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                }
            }
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.fetchBenefitsData " +
                    JSON.stringify(error)
            );
        }
    }

    get isVisible () {
        if(this.isNotAccessible){
            return false;
        }
        return (
            this.validationMetadataLoaded &&
            this.requiredDataFetched &&
            this.connectedCallBackExecuted
        );
    }
    /**
     * @function : showSpinner
     * @description	: Method to handle spinner.
     */
    get showSpinner () {
        const flag =
            this.validationMetadataLoaded &&
            this.requiredDataFetched &&
            this.connectedCallBackExecuted;
        return (
            !flag
        );
    }
    /**
     * @function : showHideFields
     * @description	: Method to handle visibility of input fields for particular benefit type.
     * @param  {object} event - JS event.
     */
    showHideFields (event) {
        try {
            const val = event.detail;
            const index = event.target.dataset.index;
            const benefitsWrapperList = this.benefitsWrapperList;

            benefitsWrapperList[index][
                sspConstants.sspBenefitsFields.BenefitTypeCode__c
            ].isChecked = val;

            this.benefitsWrapperList = benefitsWrapperList;
            this.validateOptions();
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.showHideFields " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : validateOptions
     * @description	: Method to validate selection of at least one option.
     */
    validateOptions () {
        let showError = true;
        const benefitsList = this.template.querySelectorAll(
            ".ssp-benefitTypes"
        );
        if (benefitsList !== null && benefitsList !== undefined) {
            //iterating on benefit type sections
            benefitsList.forEach(function (benefitTypeCmp) {
                if (benefitTypeCmp.isChecked) {
                    showError = false;
                }
            });
        }
        if (showError) {
            const errorMsg = sspAtLeastOneValidationMessage.replace(
                "[field]",
                "Benefit"
            );
            this.toastErrorText = errorMsg;
            this.benefitValidationError = errorMsg;
            this.errorClass = true;    // for defect 382490 by saurabh rathi
        } else {
            this.benefitValidationError = "";
            this.errorClass = false;    // for defect 382490 by saurabh rathi
        }
    }

    /**
     * @function : constructBenefitTypeToRecordMapping
     * @description	: Method to construct value/API to label mapping for benefit type picklist values.
     * @param {object[]} benefitRecords - Benefits records.
     */
    constructBenefitTypeToRecordMapping (benefitRecords) {
        const benefitTypeToRecordMapping = {};
        const idList = [];
        if (benefitRecords != null && benefitRecords !== undefined) {
            benefitRecords.forEach(function (benefit) {
                if (
                    benefit !== null &&
                    benefit !== undefined &&
                    benefit.BenefitTypeCode__c !== null &&
                    benefit.BenefitTypeCode__c !== undefined
                ) {
                    idList.push(benefit.Id);
                    benefitTypeToRecordMapping[
                        benefit.BenefitTypeCode__c
                    ] = benefit;
                }
            });
        }
        this.benefitsIdList = idList;
        return benefitTypeToRecordMapping;
    }

    /**
     * @function : constructRequiredWrapper
     * @description	: Method to construct wrapper with field details for loading/rendering html fields.
     * @param {object{}} benefitTypeToRecordMapping - Type to record mapping.
     */
    constructRequiredWrapper (benefitTypeToRecordMapping) {
        const self = this;
        const benefitsWrapperList = [];
        const benefitTypesValueToLabel = this.benefitTypesValueToLabel;
        let index = 0;
        Object.keys(benefitTypesValueToLabel).forEach(benefitTypeValue => {
            const benefitRecord =
                benefitTypeToRecordMapping !== null &&
                benefitTypeToRecordMapping !== undefined &&
                benefitTypeToRecordMapping.hasOwnProperty(benefitTypeValue)
                    ? benefitTypeToRecordMapping[benefitTypeValue]
                    : null;
            const tmpWrapper = {
                [sspConstants.sspBenefitsFields
                    .BenefitTypeCode__c]: self.constructFieldWrapper(
                    sspConstants.sspBenefitsFields.BenefitTypeCode__c,
                    benefitRecord,
                    benefitsTypeClass + " ssp-benefitTypes",
                    benefitTypeValue,
                    benefitTypesValueToLabel
                ),

                [sspConstants.sspBenefitsFields
                    .StatusOfApplication__c]: self.constructFieldWrapper(
                    sspConstants.sspBenefitsFields.StatusOfApplication__c,
                    benefitRecord,
                    applicationStatusClass +
                        " ssp-applicationInputs" +
                        benefitTypeValue,
                    benefitTypeValue,
                    benefitTypesValueToLabel
                ),

                [sspConstants.sspBenefitsFields
                    .BenefitApplicationDate__c]: self.constructFieldWrapper(
                    sspConstants.sspBenefitsFields.BenefitApplicationDate__c,
                    benefitRecord,
                    applicationDateClass +
                        " ssp-applicationInputs" +
                        benefitTypeValue,
                    benefitTypeValue,
                    benefitTypesValueToLabel
                )
            };
            tmpWrapper.key = index;
            tmpWrapper.isDateVisible = self.determineDateVisibility(
                benefitRecord
            );
            if (
                tmpWrapper[sspConstants.sspBenefitsFields.BenefitTypeCode__c]
                    .isVisible
            ) {
                benefitsWrapperList.push(tmpWrapper);
            }
            index++;
        });
        this.benefitsWrapperList = benefitsWrapperList;
    }

    /**
     * @function : determineDateVisibility
     * @description	: Method to determine that the visibility of date field.
     * @param {object} benefitsRecord - Benefits Record.
     */
    determineDateVisibility (benefitsRecord) {
        let dateVisibility = false;
        if (benefitsRecord !== null && benefitsRecord !== undefined) {
            dateVisibility =
                benefitsRecord[
                    sspConstants.sspBenefitsFields.StatusOfApplication__c
                ] === sspConstants.statusOfApplication.A
                    ? true
                    : dateVisibility;
        }
        return dateVisibility;
    }

    /**
     * @function : determineFieldVisibility
     * @description	: Method to determine that the field should be visible.
     * @param {string} fieldName - SF field name.
     */
    determineFieldVisibility (fieldName) {
        let result = false;
        const appliedProgramList = this.appliedPrograms;
        const fieldLevelProgramList =
            fieldToProgramMapping[fieldName] !== null &&
            fieldToProgramMapping[fieldName] !== undefined
                ? fieldToProgramMapping[fieldName]
                : [];
        result =
            fieldLevelProgramList !== null &&
            fieldLevelProgramList !== undefined &&
            fieldLevelProgramList.length === 0
                ? true
                : result;
        fieldLevelProgramList.forEach(function (program) {
            if (appliedProgramList.includes(program)) {
                result = true;
            }
        });
        return result;
    }

    /**
     * @function : constructPicklistValueToLabelMapping
     * @description	: Method to create value to label mapping.
     * @param {object[]} pickListValues - Picklist values.
     */
    constructPicklistValueToLabelMapping (pickListValues) {
        const valueToLabelMapping = {};
        pickListValues.forEach(function (entry) {
            valueToLabelMapping[entry.value] = entry.label;
        });
        return valueToLabelMapping;
    }

    /**
     * @function : triggerValueBinding
     * @description	: Method to perform two way binding and return required input components for validation.
     */
    triggerValueBinding () {
        const benefitTypeToRecordMapping = this.benefitTypeToRecordMapping;
        const benefitsRecordList = [];
        const self = this;
        const benefitsList = this.template.querySelectorAll(
            ".ssp-benefitTypes"
        );
        let idList = this.benefitsIdList;
        if (benefitsList !== null && benefitsList !== undefined) {
            //iterating on benefit type sections
            benefitsList.forEach(function (benefitTypeCmp) {
                const selectedBenefitType = benefitTypeCmp.dataset.type;
                //construct className for input components under type section being iterated
                const className =
                    ".ssp-applicationInputs" + selectedBenefitType;

                //if the section is checked/selected, only then query for related input components
                if (benefitTypeCmp.isChecked) {
                    const inputComponents = self.template.querySelectorAll(
                        className
                    );
                    const benefitsRecord = {};
                    if (
                        inputComponents !== null &&
                        inputComponents !== undefined
                    ) {
                        //iterating over list of input base components to construct/gather benefits record values
                        inputComponents.forEach(function (inputCmp) {
                            benefitsRecord[inputCmp.fieldName] = inputCmp.value;
                        });
                        benefitsRecord[
                            sspConstants.sspBenefitsFields.BenefitTypeCode__c
                        ] = selectedBenefitType;
                        benefitsRecord[
                            sspConstants.sspBenefitsFields.SSP_Member__c
                        ] = self.sspMemberId;
                        benefitsRecord.recordTypeId =
                            self.entitledBenefitTypeId;
                        benefitsRecord[
                            sspConstants.sspBenefitsFields.BenefitApplicationDate__c
                        ] =
                            benefitsRecord[
                                sspConstants.sspBenefitsFields
                                    .BenefitApplicationDate__c
                            ] !== null &&
                            benefitsRecord[
                                sspConstants.sspBenefitsFields
                                    .BenefitApplicationDate__c
                            ] !== undefined &&
                            benefitsRecord[
                                sspConstants.sspBenefitsFields
                                    .BenefitApplicationDate__c
                            ].length > 0
                                ? benefitsRecord[
                                      sspConstants.sspBenefitsFields
                                          .BenefitApplicationDate__c
                                  ]
                                : null;
                        //in case there already exists a record for benefit type being iterated, assign that record id to the data being created
                        if (
                            benefitTypeToRecordMapping !== null &&
                            benefitTypeToRecordMapping !== undefined &&
                            benefitTypeToRecordMapping.hasOwnProperty(
                                selectedBenefitType
                            )
                        ) {
                            benefitsRecord.Id =
                                benefitTypeToRecordMapping[
                                    selectedBenefitType
                                ].Id;
                            idList = self.remove(idList, benefitsRecord.Id);
                        }
                        benefitsRecordList.push(benefitsRecord);
                    }
                }
            });
        }
        this.benefitsIdList = idList;
        return benefitsRecordList;
    }

    /**
     * @function : constructFieldWrapper
     * @description	: Method to construct field level wrapper.
     * @param {string} fieldAPI - SF field API.
     * @param {object} benefitsRecord - Benefit record.
     * @param {string} className - Class name.
     * @param {string} type - Benefit type.
     * @param {object{}} benefitTypesValueToLabel - Value to label mapping.
     */ 
    constructFieldWrapper (
        fieldAPI,
        benefitsRecord,
        className,
        type,
        benefitTypesValueToLabel
    ) {
        let tmpWrapper;
        if (fieldAPI !== null && fieldAPI !== undefined) {
            tmpWrapper = {
                fieldAPI: fieldAPI,
                objectAPI: sspConstants.sspObjectAPI.SSP_Benefits__c,
                className: className,
                recordId:
                    benefitsRecord !== null && benefitsRecord !== undefined
                        ? benefitsRecord.Id
                        : "",
                isVisible: this.determineFieldVisibility(fieldAPI),
                value:
                    benefitsRecord !== null && benefitsRecord !== undefined
                        ? benefitsRecord[fieldAPI]
                        : "",
                label: benefitTypesValueToLabel[type]
            };

            if (
                fieldAPI === sspConstants.sspBenefitsFields.BenefitTypeCode__c
            ) {
                tmpWrapper.isChecked =
                    benefitsRecord !== null && benefitsRecord !== undefined
                        ? true
                        : false;
                tmpWrapper.typeValue = type;
            }
        }
        return tmpWrapper;
    }

    /**
     * @function : setAppliedPrograms
     * @description	: Method to parse and set applied programs.
     * @param {object} parsedData  - Parsed data.
     */
    setAppliedPrograms (parsedData) {
        if (parsedData.hasOwnProperty("applicationIndividual")) {
            const appIndividual = parsedData.applicationIndividual[0];
            if (
                appIndividual !== null &&
                appIndividual !== undefined &&
                appIndividual.ProgramsApplied__c !== null
            ) {
                this.setMemberName(this.memberFirstName);
                const programList = appIndividual.ProgramsApplied__c.split(";");
                this.appliedPrograms = programList;
            }
        }
    }

    /**
     * @function : setAppliedPrograms
     * @description	: Method to parse and set existing benefit records related data.
     * @param {object} parsedData - Parsed data.
     */
    extractBenefitRecords (parsedData) {
        if (parsedData.hasOwnProperty("benefitsRecords")) {
            this.existingBenefitsRecords = parsedData.benefitsRecords;
        }
    }

    /**
     * @function : setAppliedPrograms
     * @description	: Method to parse and set application status.
     */
    saveData () {
        if (this.allowToProceed()) {
            this.templateInputsValue = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.benefitValidationError = "";
            this.errorClass = false;
            
        } else {
            const errorMsg = sspAtLeastOneValidationMessage.replace(
                "[field]",
                "Benefit"
            );
            const showToastEvent = new CustomEvent("showcustomtoast", {
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(showToastEvent);
            this.templateInputsValue = "invalid";
            this.toastErrorText = errorMsg;
            this.benefitValidationError = errorMsg;
            this.errorClass = true;
        }
    }

    /**
     * @function : setAppliedPrograms
     * @description	: Method to parse and set application status.
     */
    callSaveOnValidation () {
        const detailMap = {};
        const benefitsToBeSaved = this.triggerValueBinding();
        const benefitsToBeDeleted = this.constructRecordsToBeDeleted();
        let result = false;
        if (
            benefitsToBeDeleted !== null &&
            benefitsToBeDeleted !== undefined &&
            benefitsToBeDeleted.length > 0
        ) {
            detailMap.toDelete = JSON.stringify(benefitsToBeDeleted);
            result = true;
        }

        if (
            benefitsToBeSaved !== null &&
            benefitsToBeSaved !== undefined &&
            benefitsToBeSaved.length > 0
        ) {
            result = true;
            detailMap.toUpsert = JSON.stringify(benefitsToBeSaved);
        }

        if (result) {
            this.saveDataToServer(detailMap);
        }
    }

    /**
     * @function : setAppliedPrograms
     * @description	: Method to validate if a single benefit type is selected.
     */
    allowToProceed () {
        let result = false;
        const benefitsList = this.template.querySelectorAll(
            ".ssp-benefitTypes"
        );
        if (benefitsList !== null && benefitsList !== undefined) {
            //iterating on benefit type sections
            benefitsList.forEach(function (benefitTypeCmp) {
                if (benefitTypeCmp.isChecked) {
                    result = true;
                }
            });
        }
        return result;
    }

    /**
     * @function : saveDataToServer
     * @description	: Server call with updated records to save them to SF database.
     * @param {object[]} detailMap - IncomeList.
     */
    saveDataToServer (detailMap) {
        const mParam = {
            detailMap: detailMap
        };
        updateBenefits(mParam)
            .then(result => {
                this.fetchedResult = result;
                refreshApex(this.retrievedData);
                this.saveCompleted = true;
            })
            .catch(error => {
                console.error(
                    "error occurred in sspEntitledBenefits.saveDataToServer" +
                        JSON.stringify(error)
                );
            });
    }

    /**
     * @function : constructRecordsToBeDeleted
     * @description	: Method to construct benefits records to be deleted.
     */
    constructRecordsToBeDeleted () {
        const tmpObjList = [];
        const idList = this.benefitsIdList;
        if (idList !== null && idList !== undefined) {
            idList.forEach(function (id) {
                tmpObjList.push({ Id: id });
            });
        }
        return tmpObjList;
    }

    /**
     * @function : remove
     * @description	: Method to remove item from array.
     * @param {object[]} array - Array.
     * @param {string} element - Array element.
     */
    remove (array, element) {
        return array.filter(el => el !== element);
    }

    /**
     * @function : setApplicationStatus
     * @description	: Method to set application status to wrapper and determine related date field visibility.
     * @param {object} event - JS event.
     */
    setApplicationStatus (event) {
        try {
            const value = event.target.value;
            let index = event.target.dataset.index;
            index =
                index !== null && index !== undefined
                    ? parseInt(index, 10)
                    : null;
            const benefitsWrapperList = this.benefitsWrapperList;
            const dateVisibility =
                value !== null &&
                value !== undefined &&
                value === sspConstants.statusOfApplication.A;
            if (index !== null) {
                benefitsWrapperList[index].isDateVisible = dateVisibility;
            }
            this.benefitsWrapperList = benefitsWrapperList;
        } catch (error) {
            console.error(
                "failed in sspEntitledBenefits.setApplicationStatus " +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function : displayLearnMoreModelMethod
     * @description : Used to open learn more modal.
     * @param {object} event - Js event.
     */
    displayLearnMoreModelMethod (event) {
        if (event.keyCode === 13 || event.type == "click") {
            this.openLearnMoreModel = true;
        }
    }
    /**
     * @function : hideLearnMoreModelMethod
     * @description : Used to hide learn more modal.
     */
    hideLearnMoreModelMethod () {  
        this.openLearnMoreModel = false;
        this.openLearnMoreModel = "";
    }
    /**
     * @function : setMemberName
     * @description	: Method to set member name.
     * @param {object} name - Member name.
     */
    setMemberName (name) {
        const question = this.label.sspBenefitOrPlanApplied;
        this.label.sspBenefitOrPlanApplied = question.replace("{0}", name);
    }
    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast () {
        this.hasSaveValidationError = false;
    }
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
                this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else {
                    this.isNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if(this.isNotAccessible){
                    this.showAccessDeniedComponent = true;
                }
            }
        } catch (error) {
            console.error(
                "Error in highestEducation.constructRenderingMap", error
            );
        }
    }
}