/**
 * Component Name: sspChangeExistingExpenseDetail.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component to handle individual record/entry for change existing expense screen.
 * Date: 11/27/2019.
 */
import { LightningElement, api, track } from "lwc";

import sspAlimonyAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_Alimony";
import sspChildSupportAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_ChildSupport";
import sspDependentCareAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_DependentCare";
import sspMedicalAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_Medical";
import sspShelterAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_Shelter";
import sspTaxDeductionsAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_TaxDeductions";
import sspUtilityExpenseAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_UtilityExpense";
import sspEducationExpenseAPI from "@salesforce/label/c.SSP_ExpenseTypeAPI_EducationExpense";
import sspAtLeastOneEducationExpenseErrorMessage from "@salesforce/label/c.SSP_AtLeastOneEducationExpenseErrorMessage";

import sspExpenseFrequency from "@salesforce/label/c.SSP_ExpenseFrequency";
import sspAmount from "@salesforce/label/c.SSP_Amount";
import sspTuitionAmount from "@salesforce/label/c.SSP_TuitionAmount";
import sspBooksAmount from "@salesforce/label/c.SSP_BooksAmount";
import sspFeesAmount from "@salesforce/label/c.SSP_FeesAmount";
import sspMiscellaneousAmount from "@salesforce/label/c.SSP_MiscellaneousAmount";

import sspDollarSign from "@salesforce/label/c.SSP_DollarSign";
import sspExpenseFrequencyAlt from "@salesforce/label/c.SSP_ExpenseFrequencyAlt";
import sspHigherEducation from "@salesforce/label/c.SSP_HigherEducation";

import sspConstants from "c/sspConstants";

const programs = {
    MA: sspConstants.programValues.MA,
    KT: sspConstants.programValues.KT,
    SN: sspConstants.programValues.SN,
    SS: sspConstants.programValues.SS,
    DS: sspConstants.programValues.DS,
    CC: sspConstants.programValues.CC,
    KP: sspConstants.programValues.KP
};

export default class SspChangeExistingExpenseDetail extends LightningElement {
    @api metaDataListParent;
    @api appliedProgramList = [];
    @api expenseFrequencyValueToLabel;
    @api expenseTypeValueToLabel;
    @api expenseSubTypeValueToLabel;
    @api isParticipatingInWorkStudyProgram;
    @api disabled;
    @api expenseObj = {
        [sspConstants.sspAssetFields.ExpenseFrequencyCode__c]: "",
        [sspConstants.sspAssetFields.ExpenseAmount__c]: "",
        [sspConstants.sspAssetFields.TuitionAmount__c]: "",
        [sspConstants.sspAssetFields.BooksAmount__c]: "",
        [sspConstants.sspAssetFields.FeesAmount__c]: "",
        [sspConstants.sspAssetFields.MiscellaneousAmount__c]: ""
    };

    checkForAtLeastOneEducationExpense = false;
    label = {
        sspAtLeastOneEducationExpenseErrorMessage
    };
    educationValidationWrapper = {
        [sspConstants.sspAssetFields.TuitionAmount__c]: false,
        [sspConstants.sspAssetFields.BooksAmount__c]: false,
        [sspConstants.sspAssetFields.FeesAmount__c]: false,
        [sspConstants.sspAssetFields.MiscellaneousAmount__c]: false
    };
    tmpExpenseRecord = {
        [sspConstants.sspAssetFields.ExpenseFrequencyCode__c]: "",
        [sspConstants.sspAssetFields.ExpenseAmount__c]: "",
        [sspConstants.sspAssetFields.TuitionAmount__c]: "",
        [sspConstants.sspAssetFields.BooksAmount__c]: "",
        [sspConstants.sspAssetFields.FeesAmount__c]: "",
        [sspConstants.sspAssetFields.MiscellaneousAmount__c]: ""
    };

    @track headerOne;
    @track headerTwo;
    @track header;
    @track expenseFrequencyLabel = sspExpenseFrequency;
    @track expensesAmountLabel = sspAmount;
    @track tuitionAmountLabel = sspTuitionAmount;
    @track booksAmountLabel = sspBooksAmount;
    @track feesAmountLabel = sspFeesAmount;
    @track miscellaneousAmountLabel = sspMiscellaneousAmount;
    @track sspExpenseFrequencyAltLabel = sspExpenseFrequencyAlt;
    @track expenseFrequencyOptions = [];
    @track toggleExpenseRecord = false;
    @track containerClass = "slds-hide";
    @track customValidationError = "";
    @track isError = false;

    /**
     * @function : connectedCallback
     * @description	: Connected callback - to identify expense headers and construct educational expense validation wrapper.
     */
    connectedCallback () {
        try {
            this.identifyHeaders(this.expenseObj);
            const expenseObj = this.expenseObj;
            if (
                expenseObj.ExpenseTypeCode__c === sspEducationExpenseAPI &&
                expenseObj != null &&
                expenseObj !== undefined &&
                this.isParticipatingInWorkStudyProgram &&
                this.checkForAppliedProgram(this.appliedProgramList, [
                    programs.SN
                ])
            ) {
                this.checkForAtLeastOneEducationExpense = true;
                Object.keys(this.educationValidationWrapper).forEach(
                    fieldAPI => {
                        if (
                            expenseObj[fieldAPI] !== null &&
                            expenseObj[fieldAPI] !== undefined &&
                            parseFloat(expenseObj[fieldAPI]) > 0
                        ) {
                            this.educationValidationWrapper[fieldAPI] = true;
                        }
                    }
                );
            } else {
                Object.keys(this.educationValidationWrapper).forEach(
                    fieldAPI => {
                        this.educationValidationWrapper[fieldAPI] = true;
                    }
                );
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : expenseFrequencies
     * @description	: Method to set expense expenseFrequencies.
     * @param {object} value - Expense frequency values.
     */
    set expenseFrequencies (value) {
        let expenseFrequencyOptions = [];
        if (value != null && value != undefined) {
            expenseFrequencyOptions = value;
        }
        this.expenseFrequencyOptions = expenseFrequencyOptions;
    }

    @api
    get expenseFrequencies () {
        return this.expenseFrequencyOptions;
    }

    /**
     * @function : inputClassName
     * @description	: Construct dynamic class name for base input elements.
     */
    get inputClassName () {
        let className = "expenseInputs";
        if (this.expenseObj !== null) {
            className = this.expenseObj.Id + "expenseInputs";
        }
        return className;
    }

    /**
     * @function : showExpenseFrequency
     * @description	: Method/Parameter to identify visibility of showExpenseFrequency input component.
     */
    get showExpenseFrequency () {
        let expenseTypeResult = false;
        const programList = [programs.MA, programs.SN, programs.KT];
        try {
            if (
                this.expenseObj != null &&
                (this.expenseObj.ExpenseTypeCode__c === sspAlimonyAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspChildSupportAPI ||
                    this.expenseObj.ExpenseTypeCode__c ===
                        sspDependentCareAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspMedicalAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspShelterAPI ||
                    this.expenseObj.ExpenseTypeCode__c ===
                        sspTaxDeductionsAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspUtilityExpenseAPI)
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showExpenseFrequency " +
                    JSON.stringify(error)
            );
        }
        return expenseTypeResult;
    }

    /**
     * @function : showExpensesAmount
     * @description	: Method/Parameter to identify visibility of showExpensesAmount input component.
     */
    get showExpensesAmount () {
        let expenseTypeResult = false;
        const programList = [programs.MA, programs.SN, programs.KT];
        try {
            if (
                this.expenseObj != null &&
                (this.expenseObj.ExpenseTypeCode__c === sspAlimonyAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspChildSupportAPI ||
                    this.expenseObj.ExpenseTypeCode__c ===
                        sspDependentCareAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspMedicalAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspShelterAPI ||
                    this.expenseObj.ExpenseTypeCode__c ===
                        sspTaxDeductionsAPI ||
                    this.expenseObj.ExpenseTypeCode__c === sspUtilityExpenseAPI)
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showExpensesAmount " +
                    JSON.stringify(error)
            );
        }
        return expenseTypeResult;
    }

    /**
     * @function : showTuitionAmount
     * @description	: Method/Parameter to identify visibility of showTuitionAmount input component.
     */
    get showTuitionAmount () {
        let expenseTypeResult = false;
        const programList = [programs.SN];
        try {
            if (
                this.expenseObj != null &&
                this.expenseObj.ExpenseTypeCode__c === sspEducationExpenseAPI
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.expenseObj != null &&
                this.expenseObj !== undefined &&
                this.isParticipatingInWorkStudyProgram &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showTuitionAmount " +
                    JSON.stringify(error)
            );
        }
        return expenseTypeResult;
    }

    /**
     * @function : showBooksAmount
     * @description	: Method/Parameter to identify visibility of showBooksAmount input component.
     */
    get showBooksAmount () {
        let expenseTypeResult = false;
        const programList = [programs.SN];
        try {
            if (
                this.expenseObj != null &&
                this.expenseObj.ExpenseTypeCode__c === sspEducationExpenseAPI
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.expenseObj != null &&
                this.expenseObj !== undefined &&
                this.isParticipatingInWorkStudyProgram &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showBooksAmount " +
                    JSON.stringify(error)
            );
        }
        return expenseTypeResult;
    }

    /**
     * @function : showMiscellaneousAmount
     * @description	: Method/Parameter to identify visibility of showMiscellaneousAmount input component.
     */
    get showMiscellaneousAmount () {
        let expenseTypeResult = false;
        const programList = [programs.SN];
        try {
            if (
                this.expenseObj != null &&
                this.expenseObj.ExpenseTypeCode__c === sspEducationExpenseAPI
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.expenseObj != null &&
                this.expenseObj !== undefined &&
                this.isParticipatingInWorkStudyProgram &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showMiscellaneousAmount " +
                    JSON.stringify(error)
            );
        }

        return expenseTypeResult;
    }

    /**
     * @function : showFeesAmount
     * @description	: Method/Parameter to identify visibility of showFeesAmount input component.
     */
    get showFeesAmount () {
        let expenseTypeResult = false;
        try {
            const programList = [programs.SN];
            if (
                this.expenseObj != null &&
                this.expenseObj.ExpenseTypeCode__c === sspEducationExpenseAPI
            ) {
                expenseTypeResult = true;
            }

            expenseTypeResult =
                expenseTypeResult &&
                this.expenseObj != null &&
                this.expenseObj !== undefined &&
                this.isParticipatingInWorkStudyProgram &&
                this.checkForAppliedProgram(
                    this.appliedProgramList,
                    programList
                );
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.showFeesAmount " +
                    JSON.stringify(error)
            );
        }

        return expenseTypeResult;
    }

    /**
     * @function : triggerTwoWayBinding
     * @description	: Method to construct a fieldApi and value pair with the updated values.
     */
    @api
    triggerTwoWayBinding () {
        const expenseObj = this.tmpExpenseRecord;
        try {
            expenseObj.Id = this.expenseObj.Id;
            const inputComponents = this.template.querySelectorAll(
                "." + this.inputClassName
            );

            for (let i = 0; i < inputComponents.length; i++) {
                const tmpCmp = inputComponents[i];
                expenseObj[tmpCmp.fieldName] = tmpCmp.value;
            }

            Object.keys(expenseObj).forEach(function (key) {
                if (expenseObj[key] === null ||
                    expenseObj[key] === undefined ||
                    expenseObj[key] === "") {
                    delete expenseObj[key];
                }
            });
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.triggerTwoWayBinding " +
                    JSON.stringify(error)
            );
        }
        return expenseObj;
    }

    /**
     * @function : fetchInputComponents
     * @description	: Method to fetch all input components - to be used by parent component.
     */
    @api
    fetchInputComponents () {
        try {
            if (this.checkForAtLeastOneEducationExpense) {
                this.setEducationalFieldsValidationStatus(true);
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.fetchInputComponents " +
                    JSON.stringify(error)
            );
        }
        return this.template.querySelectorAll("." + this.inputClassName);
    }

    /**
     * @function : checkForAppliedProgram
     * @description	: Method to identify if programs opted by individual member match with the once applicable for input field visibility.
     * @param {object[]} appliedProgramList - List of applied programs.
     * @param {object[]} fieldSpecificProgramList - List of programs that are required to render particular field.
     */
    checkForAppliedProgram (appliedProgramList, fieldSpecificProgramList) {
        let result = false;
        for (let i = 0; i < appliedProgramList.length; i++) {
            const tmpProgram = appliedProgramList[i];
            if (fieldSpecificProgramList.includes(tmpProgram)) {
                result = true;
                break;
            }
        }
        return result;
    }

    /**
     * @function : toggleExpenseRecordFunction
     * @description	: Method to handle show & hide for input fields specific to particular Expense tile.
     */
    toggleExpenseRecordFunction () {
        try {
            if (this.toggleExpenseRecord) {
                this.toggleExpenseRecord = false;
                this.containerClass = "slds-hide";
            } else {
                this.toggleExpenseRecord = true;
                this.containerClass = "slds-show";
            }

            const toggleEvent = new CustomEvent("toggle", {
                detail: this.toggleExpenseRecord
            });
            this.dispatchEvent(toggleEvent);
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpenseDetail.toggleExpenseRecordFunction " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : identifyHeaders
     * @description	: Method to construct header details for a particular expense tile.
     * @param {object} expenseRecord - SF expense record.
     */
    identifyHeaders (expenseRecord) {
        if (expenseRecord != null && expenseRecord != undefined) {
            const expense = expenseRecord.ExpenseAmount__c!=null && expenseRecord.ExpenseAmount__c!==undefined ? sspDollarSign + expenseRecord.ExpenseAmount__c.toFixed(2) : "";
            const expenseEE = expenseRecord.ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE ?
                      expenseRecord.ExpenseAmount__c :
                      [expenseRecord.TuitionAmount__c,
                       expenseRecord.BooksAmount__c,
                       expenseRecord.FeesAmount__c,
                       expenseRecord.MiscellaneousAmount__c].reduce(function (total, number) {
                        if(number !== undefined && number !== null && number !== ""){
                            return total + number;
                            }
                            return total;
                      }, null);  
              
            const EEHeader =   expenseEE!=null ? sspDollarSign + expenseEE.toFixed(2):"";     

            const expenseTypeCode = expenseRecord.ExpenseTypeCode__c;
            let expenseType = "";
            expenseType =  this.expenseSubTypeValueToLabel !== null &&
                this.expenseSubTypeValueToLabel !== undefined && 
            this.expenseSubTypeValueToLabel.hasOwnProperty(
                 expenseRecord.ExpenseSubType__c)
                 ? this.expenseSubTypeValueToLabel[
                    expenseRecord.ExpenseSubType__c
                ]
              : "";

              if(expenseType ===""){
                expenseType = this.expenseTypeValueToLabel !== null &&
                this.expenseTypeValueToLabel !== undefined &&
                this.expenseTypeValueToLabel.hasOwnProperty(
                    expenseRecord.ExpenseTypeCode__c
                )
                    ? this.expenseTypeValueToLabel[
                          expenseRecord.ExpenseTypeCode__c
                      ]
                    : ""; 
              }
 //this.expenseRecord.fields.RecordType.value.fields.DeveloperName.value;//
            const expensePayFrequency =
                this.expenseFrequencyValueToLabel !== null &&
                this.expenseFrequencyValueToLabel !== undefined &&
                this.expenseFrequencyValueToLabel.hasOwnProperty(
                    expenseRecord.ExpenseFrequencyCode__c
                )
                    ? "/"+ this.expenseFrequencyValueToLabel[
                          expenseRecord.ExpenseFrequencyCode__c
                      ]
                    : "";

                    if(expenseTypeCode === sspConstants.expenseTypeCodes.EE){
                        expenseType = sspHigherEducation;
                    }        

            this.headerOne = expenseType;

            this.headerTwo =
                expenseTypeCode != "EE"
                    ? expense +
                      expensePayFrequency
                    : EEHeader;
            this.header = this.headerOne + " " + this.headerTwo;
        }
    }

    @api
    fetchToggleStatus () {
        return this.toggleExpenseRecord;
    }

    /**
     * @function : handleOnChange
     * @description	: Method to handle on change event of educational expense related fields.
     * @param {object} event - On change event handler.
     */
    handleOnChange (event) {
        try {
            if (this.checkForAtLeastOneEducationExpense) {
                this.customValidationError = "";
                this.isError = false;
                const value = event.target.value;
                const fieldAPI = event.target.fieldName;
                if (
                    value !== null &&
                    value !== undefined &&
                    parseFloat(value) > 0
                ) {
                    this.educationValidationWrapper[fieldAPI] = true;
                } else {
                    this.educationValidationWrapper[fieldAPI] = false;
                    this.setEducationalFieldsValidationStatus(false);
                }
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExpenseDetail.handleOnChange " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : handleOnChange
     * @description	: Method to check for at least educational expense value and set error flag.
     * @param {boolean} enableErrorMessage - Boolean.
     */
    setEducationalFieldsValidationStatus (enableErrorMessage) {
        let result = false;
        Object.keys(this.educationValidationWrapper).forEach(fieldAPI => {
            if (this.educationValidationWrapper[fieldAPI]) {
                result = true;
            }
        });
        if (!result) {
            this.customValidationError = sspAtLeastOneEducationExpenseErrorMessage;
            this.isError = enableErrorMessage ? true : this.isError;
        }
    }
}
