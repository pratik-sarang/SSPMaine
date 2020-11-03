/**
 * Component Name: sspChangeExistingExpense.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component for change existing expense screen.
 * Date: 11/27/2019.
 */
import { api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import fetchExistingExpenseDetails from "@salesforce/apex/SSP_ExpenseController.fetchExistingExpenseDetailsImperative";
import updateExistingExpenseRecords from "@salesforce/apex/SSP_ExpenseController.updateExistingExpenseRecords";
import sspExpenseDetailsChangeBelowExpenses from "@salesforce/label/c.SSP_ExpenseDetailsChangeBelowExpenses";
import sspDid from "@salesforce/label/c.SSP_Did";
import errorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspChangeExistingExpense1 from "@salesforce/label/c.SSP_ChangeExistingExpense";
import utility,{ formatLabels } from "c/sspUtility";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVNOCHANGEEXPENSE_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsNoChangesToExpenses__c";
import apConstants from "c/sspConstants";

export default class sspChangeExistingExpense extends baseNavFlowPage {
    @api sspMemberId;
    @api sspApplicationId;
    @api appliedPrograms = [];
    @api memberName;

    allowToSaveData = true;
    customLabel = {
        errorMessage,
        sspExpenseDetailsChangeBelowExpenses,
        sspDid,
        sspChangeExistingExpense1
    };

    @track existingExpenseRecords = [];
    @track tmpMetaData = {};
    @track expenseFrequencies;
    @track expenseFrequencyValueToLabel = {};
    @track expenseTypeValueToLabel = {};
    @track expenseSubTypeValueToLabel = {};
    @track requiredDataFetched = false;
    @track connectedCallBackExecuted = false;
    @track validationMetadataLoaded = false;
    @track isError = false;
    @track retrievedData;
    @track actionValue;
    @track nextValue;
    @track validationFlag;
    @track MetaDataListParent;
    @track customValidationError = "";
    @track noChangeVisibility = true;
    @track isParticipatingInWorkStudyProgram = false;
    @track isDataProcessed = true;
    @track timeTravelDate;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    get isDisableDetailComponents () {
        return this.disableDetailComponents || this.isReadOnlyUser;
    }
    get isDisableNoChange () {
        return this.disableNoChange || this.isReadOnlyUser;
    }

    /**
     * @function : fetchExpenseData
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     * @param {object} objData - Retrieved data.
     */
   /* @wire(fetchExistingExpenseDetails, {
        sspMemberId: "$sspMemberId",
        sspApplicationId: "$sspApplicationId",
        callingComponent: "sspChangeExistingExpense"
    })
    fetchExpenseData (objData) { */

    fetchExpenseData = () => {
            fetchExistingExpenseDetails({
                sspMemberId: this.sspMemberId,
                sspApplicationId: this.sspApplicationId,
                callingComponent: "sspChangeExistingExpense"
            })
       .then(objData => {
            if (  objData.mapResponse!= undefined) {
                this.retrievedData = objData.mapResponse;
                if (this.retrievedData) {
                    const parsedData = this.retrievedData;

                    if (parsedData.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in retrieving data sspChangeExistingExpense" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else {
                        if (
                            parsedData.hasOwnProperty(
                                "isParticipatingInWorkStudyProgram"
                            )
                        ) {
                            this.isParticipatingInWorkStudyProgram =
                                parsedData.isParticipatingInWorkStudyProgram;
                        }

                        if(parsedData.hasOwnProperty("timeTravelDate")){
                            this.timeTravelDate = parsedData.timeTravelDate;

                        }

                        if (parsedData.hasOwnProperty("expenseRecords")) {
                            const respData =  parsedData.expenseRecords;                            
                            for (let i = 0; i < respData.length; i++) {
                                let showData=false;
                                if(!respData[i].IsExistingData__c)
                                {
                                    showData= true;
                                }
                                else { 
                                    showData = respData[i].IsExistingData__c;
                                }
            
                                if(showData){    
                                    this.existingExpenseRecords.push(respData[i]);}
                                }        
                        }

                        if (
                            parsedData.hasOwnProperty("applicationIndividual")
                        ) {
                            const appIndividual =
                                parsedData.applicationIndividual[0];
                            if (
                                appIndividual != null &&
                                appIndividual != undefined &&
                                appIndividual.ProgramsApplied__c != null
                            ) {
                                const programList = appIndividual.ProgramsApplied__c.split(
                                    ";"
                                );
                                this.appliedPrograms = programList;
                                this.allowToSaveData = !utility.isArrayEmpty(appIndividual) ? !appIndividual.IsNoChangesToExpenses__c : false;
                                this.appIndividualRecordId = !utility.isArrayEmpty(appIndividual) ? appIndividual.Id : null;
                            }
                        }

                        if (parsedData.hasOwnProperty("expenseFrequencies")) {
                            const frequencyList = [];
                            const expenseFrequencies =
                                parsedData.expenseFrequencies;
                            Object.keys(expenseFrequencies).forEach(
                                frequencyValue => {
                                    const tmpWrapper = {
                                        label:
                                            expenseFrequencies[frequencyValue],
                                        value: frequencyValue
                                    };
                                    frequencyList.push(tmpWrapper);
                                }
                            );
                            this.expenseFrequencyValueToLabel = expenseFrequencies;
                            this.expenseFrequencies = frequencyList;
                        }

                        if (parsedData.hasOwnProperty("expenseTypes")) {
                            this.expenseTypeValueToLabel =
                                parsedData.expenseTypes;
                        }
                        if (parsedData.hasOwnProperty("expenseSubTypes")) {
                            this.expenseSubTypeValueToLabel =
                                parsedData.expenseSubTypes;
                        }
                        this.requiredDataFetched = true;
                    }
                }
            } else if (objData.error != undefined) {
                console.error(
                    "Error in retrieving data sspChangeExistingExpense" +
                        JSON.stringify(objData.error)
                );
            }        
      }).catch(error => {
        console.error(
            "failed in sspChangeExistingExpense.fetchExpenseData " +
                JSON.stringify(error)
        );
    });
 }
    



    /**
     * @function futureDate
     * @description Checks whether the expense end date.
     * @param {*} endDate - Expense end date.
     * @param {*} todayDate - Today end date.
     */
    futureDate (endDate, todayDate) {
        try {
            if (endDate !== null && endDate !== undefined && endDate !== "" 
                && todayDate !== null && todayDate !== undefined && todayDate !== "" ) {
                const jsTodayDate = new Date(todayDate);
                const jsEndDate = new Date(endDate);
                return jsEndDate.getTime() > jsTodayDate.getTime();
            }
            else{
                return false;
            }
        } catch (error) {
            console.error("Error in futureDate:", error);
        }
    }

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;

    /**
     * @function : connectedCallback
     * @description	: Connected Callback - to fetch details for validation framework.
     */
    connectedCallback () {
        //to retrieve validation metadata records
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "ExpenseFrequencyCode__c,SSP_Asset__c",
                "ExpenseAmount__c,SSP_Asset__c",
                "TuitionAmount__c,SSP_Asset__c",
                "BooksAmount__c,SSP_Asset__c",
                "FeesAmount__c,SSP_Asset__c",
                "MiscellaneousAmount__c,SSP_Asset__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_EditExistingExpense"
            ); //calling base cmp method
            this.customLabel.sspExpenseDetailsChangeBelowExpenses = formatLabels(
                this.customLabel.sspExpenseDetailsChangeBelowExpenses,
                [this.memberName]
            );
            this.customLabel.sspChangeExistingExpense1 = formatLabels(
                this.customLabel.sspChangeExistingExpense1,
                [this.memberName]
            );

            if(this.sspMemberId!=null && this.sspMemberId!==undefined && this.sspApplicationId!=null && this.sspApplicationId!==undefined)   
            {
            this.fetchExpenseData();
            }
            this.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.connectedCallback " +
                    JSON.stringify(error)
            );
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
                this.saveData(); // use to check validations on component
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.nextEvent " +
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
            if (value !== undefined && value !== "") {
                this.handleSave();
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.allowSaveData " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                value != null &&
                value != undefined &&
                Object.keys(value).length > 0
            ) {
                this.MetaDataListParent = value;
                this.validationMetadataLoaded = true;

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                }
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.MetadataList " +
                    JSON.stringify(error)
            );
        }
    }

    get showNoChange () {
        return this.noChangeVisibility;
    }

    get disableNoChange () {
        return !this.noChangeVisibility;
    }

    get disableDetailComponents () {
        return !this.allowToSaveData;
    }

    get noChangeExpenseLabel () {
        return this.customLabel.sspChangeExistingExpense1;
    }

    /**
     * @function : isVisible
     * @description	: Parameter to make sure that all the data is gather before loading child components.
     */
    get isVisible () {
        return (
            this.connectedCallBackExecuted &&
            this.requiredDataFetched &&
            this.validationMetadataLoaded
        );
    }

    /**
     * @function : showSpinner
     * @description	: Method to identify visibility of spinner.
     */
    get showSpinner () {
        return (
            this.connectedCallBackExecuted &&
            this.requiredDataFetched &&
            this.validationMetadataLoaded &&
            this.isDataProcessed
        );
    }

    /**
     * @function : saveData
     * @description	: Method to perform required actions prior to save.
     */
    saveData = () => {
        try {
            this.customValidationError =
                this.noChangeVisibility && this.allowToSaveData ? "error" : "";
            this.isError =
                this.noChangeVisibility && this.allowToSaveData ? true : false;
            if(this.isError){
                if (this.template.querySelector(".ssp-change-expense-form")) {
                    this.template.querySelector(".ssp-change-expense-form").classList.add("ssp-checkbox-error");
                }
            }
            else{
                if (this.template.querySelector(".ssp-change-expense-form")) {
                    this.template.querySelector(".ssp-change-expense-form").classList.remove("ssp-checkbox-error");
                }
            }
            if (this.allowToSaveData) {
                const combinedInputComponents = [];

                //fetch input components from current component
                let templateAppInputs =
                    this.customValidationError.length > 0
                        ? this.template.querySelectorAll(".applicationInputs")
                        : [];
                for (let i = 0; i < templateAppInputs.length; i++) {
                    combinedInputComponents.push(templateAppInputs[i]);
                }
                templateAppInputs =
                    templateAppInputs != null || templateAppInputs != undefined
                        ? templateAppInputs
                        : [];

                //fetch input components from child components
                const editIncomeRowItems = this.template.querySelectorAll(
                    ".editExistingExpense"
                );
                for (let i = 0; i < editIncomeRowItems.length; i++) {
                    const childInputComponents = editIncomeRowItems[
                        i
                    ].fetchInputComponents();
                    if (childInputComponents.length > 0) {
                        for (let j = 0; j < childInputComponents.length; j++) {
                            combinedInputComponents.push(
                                childInputComponents[j]
                            );
                        }
                    }
                }

                this.templateInputsValue = combinedInputComponents; //setting base cmp attribute
            } else {
                this.templateInputsValue = this.template.querySelectorAll(
                    ".applicationInputs"
                );
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.saveData " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : handleSave
     * @description	: Method to fetch updated data from child components and perform two way binding.
     */
    handleSave () {
        const appIndividualRecord = {};
        appIndividualRecord[APPLICATIONINDIVID_FIELD.fieldApiName] = this.appIndividualRecordId;
        appIndividualRecord[APPLICATIONINDIVNOCHANGEEXPENSE_FIELD.fieldApiName] = !this.allowToSaveData;

        const recordInput = {};
        recordInput.fields = appIndividualRecord;

        //lwc standard updateRecord call to update application individual record
        updateRecord(recordInput)
            .then(() => {
                this.saveCompleted = true;
            })
            .catch(error => {
                console.error("error occurred" + JSON.stringify(error));
            })

        if (this.allowToSaveData) {
            this.isDataProcessed = false;
            const editExpenseRowItems = this.template.querySelectorAll(
                ".editExistingExpense"
            );

            const updatedIncomeRecords = [];
            for (let i = 0; i < editExpenseRowItems.length; i++) {
                if (editExpenseRowItems[i].fetchToggleStatus()) {
                    updatedIncomeRecords.push(
                        editExpenseRowItems[i].triggerTwoWayBinding()
                    );
                }
            }
            this.saveDataToServer(updatedIncomeRecords);
        } else {
            this.saveCompleted = true;
        }
    }

    /**
     * @function : saveDataToServer
     * @description	: Server call with updated records to save them to SF database.
     * @param {object[]} expenseList - Expense record list.
     */
    saveDataToServer (expenseList) {
        const mParam = {
            incomeJSON: JSON.stringify(expenseList)
        };
        updateExistingExpenseRecords(mParam)
            .then(result => {
                refreshApex(this.retrievedData);
                this.saveCompleted = true;
                this.isDataProcessed = true;
            })
            .catch(error => {
                console.error("error occurred" + JSON.stringify(error));
            });
    }

    /**
     * @function : expenseNotChange
     * @description	: Method to identify whether to allow to save data.
     * @param {object} event - JS event.
     */
    expenseNotChange (event) {
        try {
            if (event.target.value) {
                this.allowToSaveData = false;
            } else {
                this.allowToSaveData = true;
            }
            this.isError = false;
            if (this.template.querySelector(".ssp-change-expense-form")) {
                this.template.querySelector(".ssp-change-expense-form").classList.remove("ssp-checkbox-error");
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.expenseNotChange " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : handleExpenseToggle
     * @description	: Method to handle toggle changes.
     */
    handleExpenseToggle () {
        try {
            const editExpenseRowItems = this.template.querySelectorAll(
                ".editExistingExpense"
            );
            let showNoChange = true;
            for (let i = 0; i < editExpenseRowItems.length; i++) {
                if (editExpenseRowItems[i].fetchToggleStatus()) {
                    showNoChange = false;
                    break;
                }
            }

            this.noChangeVisibility = showNoChange;
            this.allowToSaveData = true;
            this.isError = false;
            if (this.template.querySelector(".ssp-change-expense-form")) {
                this.template.querySelector(".ssp-change-expense-form").classList.remove("ssp-checkbox-error");
            }
        } catch (error) {
            console.error(
                "failed in sspChangeExistingExpense.handleExpenseToggle " +
                    JSON.stringify(error)
            );
        }
    }
    
    /**
    * @function : renderedCallback
    * @description : Rendered on load of removal of existing income page.
    */
    renderedCallback () {
        try {
            const noChangeCheckboxValue = this.template.querySelector(".ssp-noChangeCmp");
            if (!utility.isUndefinedOrNull(noChangeCheckboxValue)) {
                noChangeCheckboxValue.isChecked = !this.allowToSaveData;
            }
        } catch (error) {
            console.error("Error occurred in rendered Callback" + JSON.stringify(error.message));
        }
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