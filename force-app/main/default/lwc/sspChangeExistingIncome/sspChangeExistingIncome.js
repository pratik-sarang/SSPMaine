/**
 * Component Name: sspChangeIncome.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component for change in existing income screen.
 * Date:  11/12/2019.
 */
import { api, track, wire } from "lwc";
//import { refreshApex } from "@salesforce/apex";
import sspConstants from "c/sspConstants";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import fetchExistingIncomeDetails from "@salesforce/apex/SSP_IncomeController.fetchExistingIncomeDetailsImperative";
import updateExistingIncomeRecords from "@salesforce/apex/SSP_IncomeController.updateExistingIncomeRecords";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import incomeFrequencyField from "@salesforce/schema/SSP_Asset__c.IncomePayFrequency__c";
import incomeTypeField from "@salesforce/schema/SSP_Asset__c.IncomeTypeCode__c";
import incomeSubTypeCodeField from "@salesforce/schema/SSP_Asset__c.IncomeSubtypeCode__c";
import activityTypeField from "@salesforce/schema/SSP_Asset__c.ActivityType__c";
import businessTypeField from "@salesforce/schema/SSP_Asset__c.BusinessTypeCode__c";
import sspHas from "@salesforce/label/c.SSP_Has";
import errorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspChangeExistingIncome1 from "@salesforce/label/c.SSP_ChangeExistingIncome1";
import sspChangeExistingIncome2 from "@salesforce/label/c.SSP_ChangeExistingIncome2";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import utility,{ formatLabels } from "c/sspUtility";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVNOCHANGEINCOME_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsNoChangesToIncomes__c";

export default class sspChangeExistingIncome extends baseNavFlowPage {
    @api sspMemberId;
    @api sspApplicationId;
    @api appliedPrograms = [];
    @api memberName;
    @api memberFullName = "";

    allowToSaveData = true;
    @track customLabel = {
        errorMessage,
        sspHas,
        sspChangeExistingIncome1,
        sspChangeExistingIncome2
    };

    @track actionValue;
    @track nextValue;
    @track validationFlag;
    @track MetaDataListParent;
    @track recordTypeId;
    @track customValidationError = "";
    @track isError = false;
    @track existingIncomeRecords = [];
    @track tmpMetaData = {};
    @track incomeFrequencies;
    @track incomeFrequencyValueToLabel = {};
    @track incomeTypeValueToLabel = {};
    @track incomeSubTypeValueToLabel = {};
    @track activityTypeValueToLabel = {};
    @track businessTypeValueToLabel = {};
    @track connectedCallBackExecuted = false;
    @track incomeTypesFetched = false;
    @track incomeSubTypesFetched = false;
    @track activityTypesFetched = false;
    @track incomeFrequenciesFetched = false;
    @track validationMetadataLoaded = false;
    @track businessTypesFetched = false;
    @track retrievedData;
    @track noChangeVisibility = true;
    @track noChangeIncomeLabel = this.memberName + sspChangeExistingIncome2;
    @track isDataProcessed = true;
    @track appIndividualRecordId;
    @track timeTravelDate;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    get isDisableDetailComponents () {  //CD2 2.5 Security Role Matrix.
        return this.disableDetailComponents || this.isReadOnlyUser;
    }
    get isDisableNoChange () {  //CD2 2.5 Security Role Matrix.
        return this.disableNoChange || this.isReadOnlyUser;
    }

    /**
     * @function : getObjectData
     * @description	: Wire call to retrieve contact metadata.
     * @param {object} objData - Retrieved data.
     */
    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    getObjectData ({ data, error }) {
        try {
            if (data) {
                const recordTypeInfo =
                    data[sspConstants.sspMemberConstants.RecordTypesInfo];
                this.recordTypeId = Object.keys(recordTypeInfo).find(
                    recordTypeId =>
                        recordTypeInfo[recordTypeId].name ===
                        sspConstants.assetRecordTypes.Income
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
     * @function : picklistValuesForIncomeFrequency
     * @description	: Wire call to retrieve picklist values for IncomePayFrequency__c.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: incomeFrequencyField
    })
    picklistValuesForIncomeFrequency ({ error, data }) {
        if (data) {
            this.incomeFrequencies = data.values;
            this.incomeFrequencyValueToLabel = this.constructPickListValueLabelMapping(
                data.values
            );
            this.incomeFrequenciesFetched = true;
        } else if (error) {
            console.error(error);
        }
    }

    /**
     * @function : picklistValuesForBusinessType
     * @description	: Wire call to retrieve picklist values for IncomeTypeCode__c.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: businessTypeField
    })
    picklistValuesForBusinessType ({ error, data }) {
        if (data) {
            this.businessTypeValueToLabel = this.constructPickListValueLabelMapping(
                data.values
            );
            this.businessTypesFetched = true;
        } else if (error) {
            console.error(error);
        }
    }

    /**
     * @function : picklistValuesForIncomeType
     * @description	: Wire call to retrieve picklist values for IncomeTypeCode__c.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: incomeTypeField
    })
    picklistValuesForIncomeType ({ error, data }) {
        if (data) {
            this.incomeTypeValueToLabel = this.constructPickListValueLabelMapping(
                data.values
            );
            this.incomeTypesFetched = true;
        } else if (error) {
            console.error(error);
        }
    }

    /**
     * @function : picklistValuesForIncomeSubTypeCode
     * @description	: Wire call to retrieve picklist values for IncomeSubTypeCode__c.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: incomeSubTypeCodeField
    })
    picklistValuesForIncomeSubTypeCode ({ error, data }) {
        if (data) {
            this.incomeSubTypeValueToLabel = this.constructPickListValueLabelMapping(
                data.values
            );
            this.incomeSubTypesFetched = true;
        } else if (error) {
            console.error(error);
        }
    }

     /**
     * @function : picklistValuesForActivityType
     * @description	: Wire call to retrieve picklist values for ActivityType__c.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: activityTypeField
    })
    picklistValuesForActivityType ({ error, data }) {
        if (data) {
            this.activityTypeValueToLabel = this.constructPickListValueLabelMapping(
                data.values
            );
            this.activityTypesFetched = true;
        } else if (error) {
            console.error(error);
        }
    }

    /**
     * @function : fetchIncomeData
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     * @param {object} objData - Retrieved data.
     */
   /* @wire(fetchExistingIncomeDetails, {
        sspMemberId: "$sspMemberId",
        sspApplicationId: "$sspApplicationId",
        callingComponent: "sspChangeExistingIncome"
    })*/

    fetchIncomeData=() => {
        fetchExistingIncomeDetails({
            sspMemberId: this.sspMemberId,
            sspApplicationId: this.sspApplicationId,
            callingComponent: "sspChangeExistingIncome"
        }).then(objData=>{           
             this.retrievedData = objData;
                if (this.retrievedData) {
                    const parsedData = JSON.parse(this.retrievedData);

                    if (parsedData.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in retrieving data sspChangeExistingIncome" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else {
                        if ("incomeRecords" in parsedData) {
                            this.existingIncomeRecords =
                                parsedData.incomeRecords;
                        }
                        if ("timeTravelDate" in parsedData) {
                            this.timeTravelDate =
                                parsedData.timeTravelDate;
                        }
                        if ("applicationIndividual" in parsedData) {
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
                                this.noChangeIncomeLabel =
                                    this.memberName +
                                    this.customLabel.sspChangeExistingIncome2;
                                this.allowToSaveData = !utility.isArrayEmpty(appIndividual) ? !appIndividual.IsNoChangesToIncomes__c : false;
                                this.appIndividualRecordId = !utility.isArrayEmpty(appIndividual) ? appIndividual.Id : null;
                            }
                        }
                    }
                }
        })
        .catch(error => {
            console.error(
                "failed in fetchExistingIncomeDetails " +
                JSON.stringify(error)
            );
        });

    } 
    

    /**
     * @function : connectedCallback
     * @description	: Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            //to retrieve validation metadata records
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "ContractStartDate__c,SSP_Asset__c",
                "ContractEndDate__c,SSP_Asset__c",
                "IncomePayFrequency__c,SSP_Asset__c",
                "TotalGrossAmount__c,SSP_Asset__c",
                "IncomePayDetailHoursPerWeek__c,SSP_Asset__c",
                "ExpenseAmount__c,SSP_Asset__c",
                "Tips__c,SSP_Asset__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_EditExistingIncome"
            ); 
           //calling base cmp method
           Object.keys(this.customLabel).forEach(labelKey => {
            this.customLabel[labelKey] = formatLabels(
                this.customLabel[labelKey],
                [this.memberFullName]
            );
        });

        if (this.sspMemberId != null && this.sspMemberId != undefined && this.sspApplicationId != null && this.sspApplicationId != undefined) {
            //this.getApplicationIndividualDetails();
            this.fetchIncomeData();
        }
            this.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspChangeExistingIncome.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (value !== undefined && value !== "") {
            this.nextValue = value;
            this.saveData(); // use to check validations on component
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (value !== undefined && value !== "") {
            this.callSaveOnValidation();
        }
    }

    @api
    get MetadataList () {
        return this.MetaDataListParent; //add
    }
    set MetadataList (value) {
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
    }

    /**
     * @function : showNoChange
     * @description	: to handle visibility of no change checkbox.
     */
    get showNoChange () {
        return this.noChangeVisibility;
    }

    /**
     * @function : isVisible
     * @description	: Parameter to make sure that all the data is gather before loading child components.
     */
    get isVisible () {
        return (
            this.connectedCallBackExecuted &&
            this.incomeTypesFetched &&
            this.incomeSubTypesFetched &&
            this.activityTypesFetched &&
            this.incomeFrequenciesFetched &&
            this.validationMetadataLoaded &&
            this.businessTypesFetched
        );
    }

    /**
     * @function : showSpinner
     * @description	: Method to identify visibility of spinner.
     */
    get showSpinner () {
        return (
            this.connectedCallBackExecuted &&
            this.incomeTypesFetched &&
            this.incomeSubTypesFetched &&
            this.activityTypesFetched &&
            this.incomeFrequenciesFetched &&
            this.validationMetadataLoaded &&
            this.businessTypesFetched &&
            this.isDataProcessed
        );
    }

    get disableNoChange () {
        return !this.noChangeVisibility;
    }

    get disableDetailComponents () {
        return !this.allowToSaveData;
    }

    /**
     * @function : saveData
     * @description	: Method to perform required actions prior to save.
     */
    saveData () {
        try {
            this.customValidationError =
                this.noChangeVisibility && this.allowToSaveData ? "error" : "";
            this.isError =
                this.noChangeVisibility && this.allowToSaveData ? true : false;

            if(this.isError){
                if (this.template.querySelector(".ssp-change-income-form")) {
                    this.template.querySelector(".ssp-change-income-form").classList.add("ssp-checkbox-error");
                }
            }
            else{
                if (this.template.querySelector(".ssp-change-income-form")) {
                    this.template.querySelector(".ssp-change-income-form").classList.remove("ssp-checkbox-error");
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
                    ".editExistingIncome"
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
            console.error("failed in saveData " + JSON.stringify(error));
        }
    }

    /**
     * @function : callSaveOnValidation
     * @description	: method to handle save call from framework.
     */
    callSaveOnValidation () {
        try {
            this.handleSave();
        } catch (error) {
            console.error(
                "failed in callSaveOnValidation " + JSON.stringify(error)
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
        appIndividualRecord[APPLICATIONINDIVNOCHANGEINCOME_FIELD.fieldApiName] = !this.allowToSaveData;

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
            const editIncomeRowItems = this.template.querySelectorAll(
                ".editExistingIncome"
            );

            const updatedIncomeRecords = [];
            for (let i = 0; i < editIncomeRowItems.length; i++) {
                if (editIncomeRowItems[i].fetchToggleStatus()) {
                    updatedIncomeRecords.push(
                        editIncomeRowItems[i].triggerTwoWayBinding()
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
     * @param {object[]} incomeList - Income record list.
     */
    saveDataToServer (incomeList) {
        const mParam = {
            incomeJSON: JSON.stringify(incomeList)
        };
        updateExistingIncomeRecords(mParam)
            .then(result => {
                this.saveCompleted = true;
               // refreshApex(this.retrievedData);
                if (this.sspMemberId != null && this.sspMemberId != undefined && this.sspApplicationId != null && this.sspApplicationId != undefined) {
                    this.fetchIncomeData();
                }
                this.isDataProcessed = true;
            })
            .catch(error => {
                console.error("error occurred" + JSON.stringify(error));
            });
    }

    /**
     * @function : constructPickListValueLabelMapping
     * @description	: Method to construct picklist value/API to label mapping.
     * @param {object[]} values - Picklist values.
     */
    constructPickListValueLabelMapping (values) {
        const tmpMap = {};
        for (let i = 0; i < values.length; i++) {
            const tmpEntry = values[i];
            tmpMap[tmpEntry.value] = tmpEntry.label;
        }
        return tmpMap;
    }

    /**
     * @function : incomeNotChange
     * @description	: onchange income not changed to be added.
     * @param {object} event - JS event.
     */
    incomeNotChange (event) {
        if (event.target.value) {
            this.allowToSaveData = false;
        } else {
            this.allowToSaveData = true;
        }
        this.isError = false;
        if (this.template.querySelector(".ssp-change-income-form")) {
            this.template.querySelector(".ssp-change-income-form").classList.remove("ssp-checkbox-error");
        }
    }

    /**
     * @function : handleIncomeToggle
     * @description	: Method to handle toggle changes.
     */
    handleIncomeToggle () {
        const editIncomeRowItems = this.template.querySelectorAll(
            ".editExistingIncome"
        );
        let showNoChange = true;
        for (let i = 0; i < editIncomeRowItems.length; i++) {
            if (editIncomeRowItems[i].fetchToggleStatus()) {
                showNoChange = false;
                break;
            }
        }

        this.noChangeVisibility = showNoChange;
        this.allowToSaveData = true;
        this.isError = false;
        if (this.template.querySelector(".ssp-change-income-form")) {
            this.template.querySelector(".ssp-change-income-form").classList.remove("ssp-checkbox-error");
        }
    }

    /**
     * @function : renderedCallback
     * @description : Rendered on load of removal of existing income page.
     */
    renderedCallback () {
        try {
            const noChangeCheckboxValue = this.template.querySelector(".ssp-noChangeCmp");
            if (!utility.isUndefinedOrNull(noChangeCheckboxValue)){
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
                    this.isPageAccessible = !(securityMatrix.screenPermission === sspConstants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
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