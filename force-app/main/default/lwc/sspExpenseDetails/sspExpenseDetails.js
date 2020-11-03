/*
 * Component Name: sspExpenseDetails.
 * Author: Kireeti Gora, Soumyashree Jena.
 * Description: This screen handle Expense details Module.
 * Date: 11/12/2019.
 **/
import { api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import utility from "c/sspUtility";
import getExpenseDetails from "@salesforce/apex/SSP_ExpenseController.getExpenseDetailsWithId";
import updateExistingExpenseDetails from "@salesforce/apex/SSP_ExpenseController.setExpenseDetails";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import EXPENSETYPE_FIELD from "@salesforce/schema/SSP_Asset__c.ExpenseTypeCode__c";
import EXPENSESUBTYPE_FIELD from "@salesforce/schema/SSP_Asset__c.ExpenseSubType__c";
import EXPENSEFREQUENCYCODE_FIELD from "@salesforce/schema/SSP_Asset__c.ExpenseFrequencyCode__c";
import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import sspExpenseDetailsHeader from "@salesforce/label/c.SSP_ExpenseDetailsHeader";
import sspExpenseCompleteDetails from "@salesforce/label/c.SSP_ExpenseCompleteDetails";
import sspTypeOfExpense from "@salesforce/label/c.SSP_TypeOfExpense";
import sspEnterShelterExpensesInfo from "@salesforce/label/c.SSP_EnterShelterExpensesInfo";
import sspTypeOfShelterExpense from "@salesforce/label/c.SSP_TypeOfShelterExpense";
import sspExpenseFrequency from "@salesforce/label/c.SSP_ExpenseFrequency";
import sspAmount from "@salesforce/label/c.SSP_AmountWithoutDollar";
import sspIsMoneyPaidDirectlyToLandlord from "@salesforce/label/c.SSP_IsThisMoneyPaidDirectlyToLanlord";
import sspSomeoneOutsideOfHouseholdPayingExpense from "@salesforce/label/c.SSP_SomeoneOutsideOfHouseholdPayingExpense";
import sspAnyoneInHouseholdReceiveHousingAssistance from "@salesforce/label/c.SSP_AnyoneInHouseholdReceiveHousingAssistance";
import sspTypeOfUtilityExpense from "@salesforce/label/c.SSP_TypeOfUtilityExpense";
import sspStartDate from "@salesforce/label/c.SSP_StartDate";
import sspEndDate from "@salesforce/label/c.SSP_EndDate";
import sspEndDateError from "@salesforce/label/c.SSP_ExpenseDetailsEndDateError";
import sspTuitionAmount from "@salesforce/label/c.SSP_TuitionAmount";
import sspBooksAmount from "@salesforce/label/c.SSP_BooksAmount";
import sspFeesAmount from "@salesforce/label/c.SSP_FeesAmount";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspMiscellaneousAmount from "@salesforce/label/c.SSP_MiscellaneousAmount";
import sspTypeOfMedicalExpense from "@salesforce/label/c.SSP_TypeOfMedicalExpense";
import sspNameOfChild from "@salesforce/label/c.SSP_NameOfChild";
import sspDependentCareProvider from "@salesforce/label/c.SSP_DependentCareProvider";
import sspCareProviderName from "@salesforce/label/c.SSP_CareProviderName";
import sspDependentCareFor from "@salesforce/label/c.SSP_DependentCareFor";
import sspNameOfIndividual from "@salesforce/label/c.SSP_NameOfIndividual";
import sspTypeOfTaxDeduction from "@salesforce/label/c.SSP_TypeOfTaxDeduction";
import sspTypeOfTaxDeductionAlt from "@salesforce/label/c.SSP_TypeOfTaxDeductionAlt";
import sspDivorceAgreementDate from "@salesforce/label/c.SSP_DivorceAgreementDate";
import sspEducationExpenses from "@salesforce/label/c.SSP_EducationExpenses";
import sspEducationDetailsRequiredInfo from "@salesforce/label/c.SSP_ExpenseDetailsRequiredInfo";
import sspIndividualOutsideOfHousehold from "@salesforce/label/c.SSP_IndividualOutsideOfHousehold";
import sspDependentCareProviderError from "@salesforce/label/c.SSP_DependentCareProviderError";
import sspToastErrorMessage from "@salesforce/label/c.SSP_ExpenseDetailsErrorToastMessage";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSave from "@salesforce/label/c.SSP_Save";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import sspConstants from "c/sspConstants";

import sspExpenseTypeAlt from "@salesforce/label/c.SSP_ExpenseTypeAlt";
import sspExpenseFrequencyAlt from "@salesforce/label/c.SSP_ExpenseFrequencyAlt";
import sspExpenseTypeShelterAlt from "@salesforce/label/c.SSP_ExpenseTypeShelterAlt";
import sspExpenseTypeUtilityAlt from "@salesforce/label/c.SSP_ExpenseTypeUtilityAlt";
import sspExpenseTypeMedicalAlt from "@salesforce/label/c.SSP_ExpenseMedicalTypeAlt";
import educationAmountErrorMessage from "@salesforce/label/c.SSP_ExpenseDetailsErrorToastMessage";
import sspCancelAlt from "@salesforce/label/c.sspCancelExpenseBtnAlt";
import sspSaveAlt from "@salesforce/label/c.sspExpenseSaveBtnAlt";

export default class SspExpenseDetails extends utility {
    @api sId = "";
    @api mode = "";
    @api expenseName = "";
    @api sspMemberId = "";
    @api sspApplicationId = "";
    @api memberName = "";
    outsideHouseholdPayingExpense;
    @track objExpense = {};
    @track expenseTypeOptions;
    @track showErrorToast = false;
    @track expenseSubTypeOptions;
    @track showSpinner;
    @track expenseSubTypeFieldDate;
    @track expenseFrequencyCodeOptions;
    @track userName;
    @track error;
    @track isDependentCareProviderOther;
    @track objExpenseToRefresh;
    @track isIndividualInWorkStudyProgram = true;
    @track isDependentCareProviderOther = false;
    @track isDependentCareForOther = false;
    @track isAlimonyOrSpousal = false;
    hideComponents = true;
    @track expenseFreqVisibilityState = false;
    @track dependentCareProvider;
    @track dependentIndividual;
    @track isValidEndDate = true;
    @track isMoneyOutside = false;
    @track sspConstants = sspConstants;
    @track isValidProvider = false;
    @track appliedPrograms = [];
    @track expenseSubTypeForTypeAhead = [];
    @track timeTravelDate;
    @track toastExpErrorText;
    @track expenseFrequencyOptionsTillWeekly;
    @track expenseFrequencyOptionsWithOutLumpSum;
    @track expenseFrequencyOptionsTillHourly;
    @track expenseFrequencyOptionsWithoutHourly;
    @track visibilityState = {
        isShelter: false,
        isUtility: false,
        isHigherEducation: false,
        isMedical: false,
        isChildSupport: false,
        isDependentCare: false,
        isTaxDeduction: false,
        isAlimony: false
    };
    customLabel = {
        sspTypeOfTaxDeductionAlt,
        sspEducationDetailsRequiredInfo,
        sspEducationExpenses,
        sspDivorceAgreementDate,
        sspTypeOfTaxDeduction,
        sspNameOfIndividual,
        sspDependentCareFor,
        sspCareProviderName,
        sspDependentCareProvider,
        sspNameOfChild,
        sspTypeOfMedicalExpense,
        sspMiscellaneousAmount,
        sspFeesAmount,
        sspBooksAmount,
        sspTuitionAmount,
        sspEndDateError,
        sspEndDate,
        sspStartDate,
        sspTypeOfUtilityExpense,
        sspAnyoneInHouseholdReceiveHousingAssistance,
        sspIsMoneyPaidDirectlyToLandlord,
        sspAmount,
        sspExpenseFrequency,
        sspTypeOfShelterExpense,
        sspEnterShelterExpensesInfo,
        sspTypeOfExpense,
        sspExpenseCompleteDetails,
        sspExpenseDetailsHeader,
        sspBenefitsApplication,
        sspYes,
        sspNo,
        sspCancel,
        sspSave,
        sspToastErrorMessage,
        sspDependentCareProviderError,
        toastErrorText,
        sspExpenseTypeMedicalAlt,
        sspExpenseTypeAlt,
        sspExpenseFrequencyAlt,
        sspExpenseTypeShelterAlt,
        sspExpenseTypeUtilityAlt,
        sspCancelAlt,
        sspSaveAlt
    };
    summaryTitle = "";
    @track responseOptions = [
        { label: this.customLabel.sspYes, value: "Y" },
        { label: this.customLabel.sspNo, value: "N" }
    ];
    @track memberOptionList = [];
    @track dependentMemberOptionList = [];
    @track MetaDataListParent;
    @track allowSaveValue;
    @track objValue;
    @track receiveInHouseAssistance;
    @track isMoneyPaidToOutside;
    @track IsNonHouseHoldMemberPayingExpense;
    @track disabled;
    @track divorceDate;
    @track showErrorMessageEducation = false;
    @track errorMsgEducationAmount = educationAmountErrorMessage;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    /**
     * @function : MetadataList
     * @description : The method fetches metadata for validation from framework.
     */

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value !== undefined && value !== null) {
            this.MetaDataListParent = value;

            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0){
                this.constructRenderingMap(null, value); 
            }
        }
    }
    /**
     * @function : getObjectInfo
     * @description : Standard method for fetching object Information.
     */

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;
    /**
     * @function : objWrap
     * @description :this attribute contains validated data which is used to save.
     */

    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        if (value !== undefined) {
            this.objValue = value;
        }
    }
    /**
     * @function 		: retExp1.
     * @description 	: this method is used as part of screen driver framework.
     * */

    get retExp1 () {
        return this.applicationObj != null;
    }

    /**
     * @function 		: picklistValues.
     * @description 	: Standard method for getting picklist values(for expense type field).
     * @param    {String,String}: - RecordTypeId and Field Api Name.
     * @returns   {String,String}   : - RecordTypeId and Field Api Name.
     * @returns     {string[]}     :List of picklist values.
     * */

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: EXPENSETYPE_FIELD
    })
    picklistValues ({ error, data }) {
        if (data) {
            this.expenseTypeOptions = data.values;
            this.filterExpenseTypeOptions ();
        } else if (error) {
            this.error = error;
        }
    }
    /**
     * @function 		: getExpenseSubPicklistValues.
     * @description 	: Standard method for getting picklist values(for expense sub type field).
     * @param     {String,String}   : - RecordTypeId and Field Api Name.
     * @returns     {string[]}   :List of picklist values.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: EXPENSESUBTYPE_FIELD
    })
    getExpenseSubPicklistValues ({ error, data }) {
        if (data) {
            this.expenseSubTypeFieldDate = data;

            this.manageExpenseSubType();
        } else if (error) {
            this.error = error;
        }
    }
    /**
     * @function 		: picklistValuesForUnpaidType.
     * @description 	:Standard method for getting picklist values(for Unpaid Type field).
     * @param     {String,String}   : - RecordTypeId and Field Api Name.
     * @returns     {string[]}   :List of picklist values.
     * */

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: EXPENSEFREQUENCYCODE_FIELD
    })
    picklistValuesForUnpaidType ({ error, data }) {
        if (data) {
            this.expenseFrequencyCodeOptions = data.values;
            this.expenseFrequencyOptionsTillHourly = this.expenseFrequencyCodeOptions.filter(
                opt => (opt.value !== "DA"  && opt.value !== "IR"  && opt.value !== "ON" && opt.value !== "SP")
            );
            this.expenseFrequencyOptionsWithoutHourly = this.expenseFrequencyCodeOptions.filter(
                opt => opt.value !== "HO"
            );
            this.expenseFrequencyOptionsTillWeekly = this.expenseFrequencyCodeOptions.filter(
                opt =>  ( opt.value !== "DA" && opt.value !== "HO" && opt.value !== "IR"  && opt.value !== "ON" && opt.value !== "SP")
            );
            this.expenseFrequencyOptionsWithOutLumpSum = this.expenseFrequencyCodeOptions.filter(
                opt =>  (opt.value !== "HO" && opt.value !== "DA"  && opt.value !== "IR"  && opt.value !== "SP")
            );

          this.filterFrequencyOptions();
        } else if (error) {
            this.error = error;
        }
    }
    filterFrequencyOptions ( data) {
        if (           
            (this.objExpense !== undefined &&
            this.objExpense !== null &&
            this.objExpense.ExpenseTypeCode__c !== undefined &&
            this.objExpense.ExpenseTypeCode__c !== null &&
            this.expenseFrequencyCodeOptions !== null &&
            this.expenseFrequencyCodeOptions !== undefined &&
            this.expenseFrequencyCodeOptions.length > 0 ) || data!==null
        ) {
            let expenseTypeValue ;
            if(this.objExpense!=null && this.objExpense.ExpenseTypeCode__c!==undefined){
                expenseTypeValue= this.objExpense.ExpenseTypeCode__c;
            }
            else {
                expenseTypeValue = data;
            }
            //tax, child care and dependent care
            if ( expenseTypeValue === "DE" ||  expenseTypeValue === "CAE" || expenseTypeValue === "DCE") {
                this.expenseFrequencyCodeOptions = this.expenseFrequencyOptionsTillHourly;
             }
             else if( expenseTypeValue === "ME" ){
                this.expenseFrequencyCodeOptions = this.expenseFrequencyOptionsWithOutLumpSum;
             }
             else if(expenseTypeValue==="AL"){
                this.expenseFrequencyCodeOptions = this.expenseFrequencyOptionsWithoutHourly
             }
             else{
                 this.expenseFrequencyCodeOptions = this.expenseFrequencyCodeOptions;
             }
        }
    }
    /**
     * @function 		: manageExpenseSubType.
     * @description 	: This method handles hide/show section of the sections based on Expense Type.
     * */
    manageExpenseSubType () {
        try {
            if (
                this.expenseName &&
                this.expenseSubTypeFieldDate
            ) {
                const key = this.expenseSubTypeFieldDate
                    .controllerValues[this.expenseName];
                this.expenseSubTypeOptions = this.expenseSubTypeFieldDate.values.filter(
                    opt => opt.validFor.includes(key)
                );
            }
        } catch (error) {
            console.error(
                "failed in manageExpenseSubType " +
                JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: getExpenseRecord.
     * @description 	: method to fetch existing Expense record details With Id.
     * @param    {string,string}    : - SId and sspApplicationId.
     * @returns {string}  : JSON of Expense Object Record.
     * */

    @wire(getExpenseDetails, {
        sId: "$sId",
        sspApplicationId: "$sspApplicationId",
        sspMemberId: "$sspMemberId",
        expenseName: "$expenseName"
    })
    getExpenseRecord (result) {
        try {
            if (result.data) {
                this.objExpenseToRefresh = result;
                this.timeTravelDate = result.data.mapResponse.timeTravelDate;
                if ("expenseRecord" in result.data.mapResponse) {
                    this.objExpense =
                        JSON.parse(result.data.mapResponse.expenseRecord);
                }

                if (
                    "applicationIndividual" in
                    result.data.mapResponse
                ) {
                    const memberList =
                        result.data.mapResponse
                            .applicationIndividual;

                    for (let i = 0; i < memberList.length; i++) {
                        if (memberList[i]) {
                            this.memberOptionList.push({
                                label: memberList[i].SSP_Member__r.FirstName__c +" "+  memberList[i].SSP_Member__r.LastName__c,
                                value: memberList[i].SSP_Member__c
                            });
                        }
                    }
                    for (let i = 0; i < memberList.length; i++) {
                        if (
                            memberList[i].SSP_Member__c !==
                            this.sspMemberId
                        ) {
                            this.dependentMemberOptionList.push({
                                label: memberList[i].SSP_Member__r.FirstName__c +" "+  memberList[i].SSP_Member__r.LastName__c,
                                value: memberList[i].SSP_Member__c
                            });
                        }
                    }
                    if (
                        "applicationIndividualPrograms" in
                        result.data.mapResponse
                    ) {
                        const memberPrograms =
                            result.data.mapResponse
                                .applicationIndividualPrograms;
                        const appIndividual = memberPrograms[0];
                        if (
                            appIndividual !== null &&
                            appIndividual !== undefined &&
                            appIndividual.ProgramsApplied__c !==
                            null &&
                            appIndividual.ProgramsApplied__c !==
                            undefined
                        ) {
                            const programList = appIndividual.ProgramsApplied__c.split(
                                ";"
                            );
                            this.appliedPrograms = programList;
                        }
                        if (
                            appIndividual !== null &&
                            appIndividual !== undefined &&
                            appIndividual.MedicaidType__c !==
                            null &&
                            appIndividual.MedicaidType__c !==
                            undefined
                        ) {
                            this.appliedPrograms.push(
                                appIndividual.MedicaidType__c
                            );
                        }
                    }
                   
                    this.memberOptionList.push({
                        label: sspIndividualOutsideOfHousehold,
                        value: this.sspConstants.sspExpenseFields
                            .outside
                    });
                    this.dependentMemberOptionList.push({
                        label: sspIndividualOutsideOfHousehold,
                        value: this.sspConstants.sspExpenseFields
                            .outside
                    });
                }

                const expenseTypeValue = this.objExpense
                    .ExpenseTypeCode__c;

                if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields.isShelter
                ) {
                    this.visibilityState.isShelter = true;
                    if (
                        this.objExpense
                            .ReceiveInHouseAssistance__c !==
                        "Y" &&
                        this.objExpense
                            .ReceiveInHouseAssistance__c !== "N"
                    ) {
                        this.objExpense[this.sspConstants.sspMemberFields.ReceiveInHouseAssistance__c] = null;

                    }
                    if (
                        this.objExpense
                            .IsNonHouseHoldMemberPayingExpenseToggle__c !==
                        "Y" &&
                        this.objExpense
                            .IsNonHouseHoldMemberPayingExpenseToggle__c !==
                        "N"
                    ) {
                        this.objExpense[
                            this.sspConstants.sspMemberFields.IsNonHouseHoldMemberPayingExpenseToggle__c
                        ] = null;
                    }

                    if (
                        this.objExpense
                            .IsMoneyPaidToOutsideToggle__c !==
                        "Y" &&
                        this.objExpense
                            .IsMoneyPaidToOutsideToggle__c !==
                        "N"
                    ) {
                        this.objExpense[
                            this.sspConstants.sspMemberFields.IsMoneyPaidToOutsideToggle__c
                        ] = null;
                    }


                    if (
                        this.objExpense
                            .IsNonHouseHoldMemberPayingExpenseToggle__c === "Y"
                    ) {

                        this.isMoneyOutside = true;
                    }

                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields.isUtility
                ) {
                    this.visibilityState.isUtility = true;
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields
                        .isHigherEducation
                ) {
                    this.visibilityState.isHigherEducation = true;
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields.isMedical
                ) {
                    this.visibilityState.isMedical = true;
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields
                        .isChildSupport
                ) {
                    this.visibilityState.isChildSupport = true;
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields
                        .isDependentCare
                ) {
                    if (this.objExpense.ProviderName__c) {
                        this.dependentCareProvider = this.sspConstants.sspExpenseFields.outside;
                        this.isDependentCareProviderOther = true;
                    } else {
                        this.dependentCareProvider = this.objExpense.DependentCareProvider__c;
                    }
                    if (this.objExpense.ChildName__c) {
                        this.dependentIndividual = this.sspConstants.sspExpenseFields.outside;
                        this.isDependentCareForOther = true;
                    } else {
                        this.dependentIndividual = this.objExpense.DependentIndividual__c;
                    }
                    this.visibilityState.isDependentCare = true;
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields
                        .isTaxDeduction
                ) {
                    this.visibilityState.isTaxDeduction = true;
                    if (
                        this.objExpense.ExpenseSubType__c ===
                        this.sspConstants.sspExpenseFields
                            .Alimony
                    ) {

                        this.isAlimonyOrSpousal = true;

                    }
                } else if (
                    expenseTypeValue ===
                    this.sspConstants.sspExpenseFields.isAlimony
                ) {
                    this.visibilityState.isAlimony = true;
                }
                if (this.sId) {
                    this.disabled = true;
                }

                if (
                    "isParticipatingInWorkStudyProgram" in
                    result.data.mapResponse
                ) {
                    if (
                        result.data.mapResponse.isParticipatingInWorkStudyProgram
                    ) {
                        this.isIndividualInWorkStudyProgram = true;
                    } else {
                        this.isIndividualInWorkStudyProgram = false;
                    }
                }
               this.filterExpenseTypeOptions ();
               this.filterFrequencyOptions(this.objExpense);
                this.showSpinner = false;
            } else if (result.error) {
                this.error = result.error;
                this.objExpense = undefined;
            }
        } catch (error) {
            console.error(
                "failed in getExpenseRecord " +
                JSON.stringify(error)
            );
        }
    }
    
    filterExpenseTypeOptions () {
        if(this.expenseTypeOptions !== undefined
        && this.expenseTypeOptions !== null && this.appliedPrograms !== null && 
        this.appliedPrograms !== undefined && this.appliedPrograms.length > 0 && (!(this.showSnapRecords && this.isIndividualInWorkStudyProgram))){
            this.expenseTypeOptions = this.expenseTypeOptions.filter(
                opt => opt.value !==  this.sspConstants.sspExpenseFields
                .isHigherEducation
            );
        }

       // Added as a part of 368189 
        if(this.expenseTypeOptions !== undefined
            && this.expenseTypeOptions !== null && this.appliedPrograms !== null && 
            this.appliedPrograms !== undefined && this.appliedPrograms.length > 0 )
            {
                // if SN or KT then show Dependent care 
                if(!this.showSnapKtRecords ){
                this.expenseTypeOptions = this.expenseTypeOptions.filter(
                    opt => opt.value !==  this.sspConstants.sspExpenseFields
                    .isDependentCare
                );
            }
             // if SN or NonMagi then show Utility, Shelter , Medical  
            if(!this.showNonMagiSnapRecords){
                this.expenseTypeOptions = this.expenseTypeOptions.filter(
                    opt => (opt.value !==  this.sspConstants.sspExpenseFields
                    .isUtility && opt.value !==  this.sspConstants.sspExpenseFields
                    .isShelter && opt.value !==  this.sspConstants.sspExpenseFields
                    .isMedical)
                );
            } 
            // if MAGI then show Tax deduction 
            if(!this.showMagiRecords) {
                this.expenseTypeOptions = this.expenseTypeOptions.filter(
                    opt => opt.value !==  this.sspConstants.sspExpenseFields
                    .isTaxDeduction 
                );
            }

            // if SN, KT , Non-MAGI and CC then show Child Support
            if(!this.showNonMagiSnapKtRecords){
                this.expenseTypeOptions = this.expenseTypeOptions.filter(
                    opt => opt.value !==  this.sspConstants.sspExpenseFields
                    .isChildSupport
                );
            }

            // if KT then show Alimony 
            if(!this.showKtRecords){
                this.expenseTypeOptions = this.expenseTypeOptions.filter(
                    opt => opt.value !==  this.sspConstants.sspExpenseFields
                    .isAlimony
                );
            }
            
        }

    }

    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
            //set the toast component
        }
    }
    /**
* @function 		: connectedCallback.
* @description 	: this method is used to fetch required metadata for validation framework.

* */

    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Expense Details";
            this.outsideHouseholdPayingExpense =
                sspSomeoneOutsideOfHouseholdPayingExpense +
                " " +
                this.memberName +
                "?";
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "ExpenseAmount__c,SSP_Asset__c",
                "TuitionAmount__c,SSP_Asset__c",
                "BooksAmount__c,SSP_Asset__c",
                "FeesAmount__c,SSP_Asset__c",
                "MiscellaneousAmount__c,SSP_Asset__c",
                "ExpenseTypeCode__c,SSP_Asset__c",
                "ExpenseFrequencyCode__c,SSP_Asset__c",
                "ExpenseSubType__c,SSP_Asset__c",
                "StartDate__c,SSP_Asset__c",
                "EndDate__c,SSP_Asset__c",
                "ChildName__c,SSP_Asset__c",
                "DependentCareProvider__c,SSP_Asset__c",
                "DependentIndividual__c,SSP_Asset__c",
                "DivorceDate__c,SSP_Asset__c",
                "IsMoneyPaidToOutsideToggle__c,SSP_Asset__c",
                "ReceiveInHouseAssistance__c,SSP_Asset__c",
                "ProviderName__c,SSP_Asset__c",
                "IsNonHouseHoldMemberPayingExpenseToggle__c,SSP_Asset__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_ExpenseDetails"
            );
        } catch (error) {
            console.error(
                "failed in connectedCallback " +
                JSON.stringify(error)
            );
        }
    }

    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }

/**
* @function 		: manageExpenseType.
* @description 	: The method is used to manage and filter values of dependent picklist on change of income type field.

* */

    manageExpenseType (event) {
        try {
            const key = this.expenseSubTypeFieldDate
                .controllerValues[event.detail];
            this.expenseSubTypeOptions = this.expenseSubTypeFieldDate.values.filter(
                opt => opt.validFor.includes(key)
            );

            const expenseTypeValue = event.detail;
            if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isShelter
            ) {
                this.visibilityState.isShelter = true;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isUtility
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = true;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields
                    .isHigherEducation
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = true;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isMedical
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = true;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isChildSupport
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = true;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields
                    .isDependentCare
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = true;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isTaxDeduction
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = true;
                this.visibilityState.isAlimony = false;
            } else if (
                expenseTypeValue ===
                this.sspConstants.sspExpenseFields.isAlimony
            ) {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = true;
            } else {
                this.visibilityState.isShelter = false;
                this.visibilityState.isUtility = false;
                this.visibilityState.isHigherEducation = false;
                this.visibilityState.isMedical = false;
                this.visibilityState.isChildSupport = false;
                this.visibilityState.isDependentCare = false;
                this.visibilityState.isTaxDeduction = false;
                this.visibilityState.isAlimony = false;
            }
            if (
                expenseTypeValue !==
                this.sspConstants.sspExpenseFields.isTaxDeduction
            ) {
                this.isAlimonyOrSpousal = false;
            }
            this.filterFrequencyOptions(expenseTypeValue);
        } catch (error) {
            console.error(
                "failed in manageExpenseType " +
                JSON.stringify(error)
            );
        }
    }

    assignValues (event) {
        try {
            this.expenseSubTypeForTypeAhead =
                event.detail.selectedValue;
            if (
                event.detail.selectedValue ===
                this.sspConstants.sspExpenseFields
                    .ExpenseSubTypeAlimony
            ) {
                this.isAlimonyOrSpousal = true;
            } else {
                this.isAlimonyOrSpousal = false;
            }
        } catch (e) {
            console.error(
                "Error in assignValues of Primary Applicant Contact page",
                e
            );
        }
    }

    /**
* @function 		: saveExpenseData.
* @description 	: this method is used to save Expense Details.

* */
    saveExpenseData () {
        try {
            if(this.isReadOnlyUser) {  // CD2 2.5 Security Role Matrix and Program Access.
                this.handleCancel();
            } else {
            try {
                this.hideComponents = false;
                const elem = this.template.querySelectorAll(
                    ".ssp-application-inputs"
                );
                this.checkValidations(elem);
                this.checkEndDateValidation();
                this.checkEducationAmount();             
            } catch (error) {
                this.error = error;
            }

            if (
                this.allowSave &&
                this.isValidEndDate &&
                this.checkEducationAmount() &&
                this.handleSameDependentProviderValidation()
            ) {
                this.showSpinner = true;
                const tempObjValue = JSON.parse(this.objValue);
                tempObjValue[
                    this.sspConstants.sspExpenseFields.SSP_Member__c
                ] = this.sspMemberId;

                if (this.sId) {
                    tempObjValue.Id = this.sId;
                }
                if (
                    tempObjValue.ExpenseTypeCode__c ===
                    this.sspConstants.sspExpenseFields
                        .isDependentCare
                ) {
                    if (
                        tempObjValue.DependentIndividual__c ===
                        this.sspConstants.sspExpenseFields
                            .outside
                    ) {
                        tempObjValue[
                            this.sspConstants.sspExpenseFields.DependentIndividual__c
                        ] = null;
                    }
                    if (
                        tempObjValue.DependentCareProvider__c ===
                        this.sspConstants.sspExpenseFields
                            .outside
                    ) {
                        tempObjValue[
                            this.sspConstants.sspExpenseFields.DependentCareProvider__c
                        ] = null;
                    }
                }
                if (
                    tempObjValue.ExpenseTypeCode__c ===
                    this.sspConstants.sspExpenseFields
                        .isMedical ||
                    tempObjValue.ExpenseTypeCode__c ===
                    this.sspConstants.sspExpenseFields
                        .isTaxDeduction
                ) {
                    if (this.expenseSubTypeForTypeAhead.length > 0) {
                        tempObjValue[
                            this.sspConstants.sspExpenseFields.ExpenseSubType__c
                        ] = this.expenseSubTypeForTypeAhead;
                    } else {
                        delete tempObjValue[
                            this.sspConstants.sspExpenseFields
                                .ExpenseSubType__c
                        ];
                    }
                }
                if (
                    tempObjValue.ExpenseTypeCode__c ===
                    this.sspConstants.sspExpenseFields
                        .isShelter
                ) {
                    if (
                        tempObjValue.IsNonHouseHoldMemberPayingExpenseToggle__c !==
                        "Y"
                    ) {
                        tempObjValue[
                            this.sspConstants.sspMemberFields.IsMoneyPaidToOutsideToggle__c
                        ] = null;
                    }
                }
                this.objValue = JSON.stringify(tempObjValue);


                updateExistingExpenseDetails({
                    sIncomeJSON: this.objValue,
                    sspApplicationId: this.sspApplicationId

                })
                    .then(result => {
                        refreshApex(this.objExpenseToRefresh);
                        this.showSpinner = false;
                        const selectedEvent = new CustomEvent(
                            "close",
                            {
                                detail: result
                            }
                        );

                        this.dispatchEvent(selectedEvent);
                    })
                    .catch(error => {
                        this.error = error;
                    });
            } else {
                this.showErrorToast = true;
                this.toastExpErrorText = (this.allowSave && !this.checkEducationAmount()) ? sspToastErrorMessage : toastErrorText;
            }
        }

        } catch (error) {
            console.error(
                "failed in saveExpenseData " +
                JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleMember.
     * @description 	: this method is used to hide/show fields based on member selected.
     * @param {event} event - Gets current value.
     * */
    handleMember (event) {
        try {
            if (
                event.detail ===
                this.sspConstants.sspExpenseFields.outside
            ) {
                this.isDependentCareProviderOther = true;
            } else {
                this.isDependentCareProviderOther = false;
            }
        } catch (error) {
            console.error(
                "failed in handleMember " + JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleDependentCare.
     * @description 	: this method is used to hide/show fields based on member selected.
     * @param {event} event - Gets current value.
     * */
    handleDependentCare (event) {
        try {
            if (
                event.detail ===
                this.sspConstants.sspExpenseFields.outside
            ) {
                this.isDependentCareForOther = true;
            } else {
                this.isDependentCareForOther = false;
            }
        } catch (error) {
            console.error(
                "failed in handleDependentCare " +
                JSON.stringify(error)
            );
        }
    }
    /**
* @function 		: handleSameDependentProviderValidation.
* @description 	: this method is handle handleSameDependentProviderValidation.
 
* */
    handleSameDependentProviderValidation () {
        let validProvider;
        try {

            this.callValidation();
            if (this.objValue) {
                const objExpenseToCheck = JSON.parse(
                    this.objValue
                );
                if (
                    objExpenseToCheck.ExpenseTypeCode__c ===
                    this.sspConstants.sspExpenseFields
                        .isDependentCare &&
                    objExpenseToCheck[
                    this.sspConstants.sspExpenseFields
                        .DependentCareProvider__c
                    ] ===
                    objExpenseToCheck[
                    this.sspConstants.sspExpenseFields
                        .DependentIndividual__c
                    ] &&  objExpenseToCheck[
                        this.sspConstants.sspExpenseFields
                            .ChildName__c]
                            ===
                            objExpenseToCheck[
                                this.sspConstants.sspExpenseFields
                                    .ProviderName__c]
                    
                ) {
                    this.isValidProvider = true;
                    validProvider = false;
                } else {
                    this.isValidProvider = false;
                    validProvider = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in handleSameDependentProviderValidation " +
                JSON.stringify(error)
            );
        }
        return validProvider;
    }
    /**
     * @function 		: callValidation.
     * @description 	: method to fetch validations.
     * */
    callValidation () {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-application-inputs"
            );
            this.checkValidations(elem);
        } catch (error) {
            this.error = error;
        }
    }
    /**
* @function 		: checkEndDateValidation.
* @description 	: this method Validates EndDate Validation.

* */
    checkEndDateValidation () {
        try {
            this.callValidation();
            if (this.objValue) {
                const objExpenseToCheck = JSON.parse(
                    this.objValue
                );
                if (
                    objExpenseToCheck.StartDate__c >
                    objExpenseToCheck.EndDate__c
                ) {
                    this.isValidEndDate = false;
                } else {
                    this.isValidEndDate = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in checkEndDateValidation " +
                JSON.stringify(error)
            );
        }
    }
    /**
* @function 		: checkEducationAmount.
* @description 	: this method Validates Education Amount Validation.

* */
    checkEducationAmount () {
        let isChecked;
        try {
            this.callValidation();
            if (
                this.objValue &&
                this.objValue.includes("Amount")
            ) {
                const objExpenseToCheck = JSON.parse(
                    this.objValue
                );
                if (
                    objExpenseToCheck.TuitionAmount__c !==
                    null ||
                    objExpenseToCheck.MiscellaneousAmount__c !==
                    null ||
                    objExpenseToCheck.BooksAmount__c !== null ||
                    objExpenseToCheck.FeesAmount__c !== null
                ) {
                    isChecked = true;
                    this.showErrorMessageEducation =false;
                } else {
                    isChecked = false;
                    this.showErrorMessageEducation =true;
                    
                }
                
             const elems = this.template.querySelectorAll(".ssp-amount-inputs");
                if(this.showErrorMessageEducation){                
                    for (let index=0 ; index < elems.length; index++) {
                        elems[index].ErrorMessageList= [this.errorMsgEducationAmount];
                    }
                } 
                else{
                    for (let index=0 ; index < elems.length; index++) {
                        elems[index].ErrorMessageList= [];
                    }
                }
            }
        } catch (error) {
            console.error(
                "failed in checkEducationAmount " +
                JSON.stringify(error)
            );
        }
        return isChecked;
    }
    /**
     * @function 		: manageDivorceDate.
     * @description 	: this method Validates Divorce Date Validation.
     * @param {event} event - Gets current value.
     * */
    manageDivorceDate (event) {
        try {
            if (
                event.detail ===
                this.sspConstants.sspExpenseFields
                    .ExpenseSubTypeAlimony
            ) {
                this.isAlimonyOrSpousal = true;
            } else {
                this.isAlimonyOrSpousal = false;
            }
        } catch (error) {
            console.error(
                "failed in manageDivorceDate " +
                JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: manageMoneyPaidOutside.
     * @description 	: this method handles show/hide of section based on the Is
     * someone outside of the household paying this expense field.
     * @param {event} event - Gets current value.
     * */
    manageMoneyPaidOutside (event) {
        try {
            const response = event.detail.value;
            if (
                response === this.sspConstants.toggleFieldValue.yes
            ) {
                this.isMoneyOutside = true;
            } else {
                this.isMoneyOutside = false;
            }
        } catch (error) {
            console.error(
                "failed in manageMoneyPaidOutside " +
                JSON.stringify(error)
            );
        }
    }
    /**
     * @function 	: handleCancel.
     * @description 	: The method is used to cancel income details and go to income summary .
     * */

    handleCancel () {
        try {
            const selectedEvent = new CustomEvent("close");

            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "failed in handleCancel " + JSON.stringify(error)
            );
        }
    }
    /**
     * @function 	: checkForAppliedProgram.
     * @description 	: Method to identify if programs opted by individual member match with the once applicable for input field visibility.
     * */

    checkForAppliedProgram (
        appliedPrograms,
        fieldSpecificProgramList
    ) {
        let result = false;
        try {

            for (let i = 0; i < appliedPrograms.length; i++) {
                const tmpProgram = appliedPrograms[i];
                if (
                    fieldSpecificProgramList.includes(tmpProgram)
                ) {
                    result = true;
                    break;
                }
            }

        } catch (error) {
            console.error(
                "failed in checkForAppliedProgram " +
                JSON.stringify(error)
            );
        }
        return result;
    }
    /**
     * @function 	: showSnapRecords.
     * @description 	: returns boolean based on applied programs (SNAP).
     * */

    get showSnapRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showSnapRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showSnapKtRecords.
     * @description 	: returns boolean based on applied programs. (SNAP, KTAP).
     * */
    get showSnapKtRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showSnapKtRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showNonMagiSnapKtRecords.
     * @description 	: returns boolean based on applied programs. (Non-Magi, SNAP, KTAP).
     * */
    get showNonMagiSnapKtRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showNonMagiSnapKtRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showNonMagiSnapRecords.
     * @description 	: returns boolean based on applied programs. (Non-Magi, SNAP).
     * */
    get showNonMagiSnapRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showNonMagiSnapRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showMedicaidSnapKtRecords.
     * @description 	: returns boolean based on applied programs. (Magi, Non-Magi, SNAP, KTAP).
     * */
    get showMedicaidSnapKtRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showMedicaidSnapKtRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showMagiRecords.
     * @description 	: returns boolean based on applied programs. (Magi).
     * */
    get showMagiRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showMagiRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
    /**
     * @function 	: showKtRecords.
     * @description 	: returns boolean based on applied programs. (Magi).
     * */
    get showKtRecords () {
        const programList = this.sspConstants.sspExpenseFields
            .showKtRecords;
        return this.checkForAppliedProgram(
            this.appliedPrograms,
            programList
        );
    }
     /*
     * @function    : hideToast
     * @description : Method to hide Toast
     */
    hideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error(
                "failed in sspIncomeDetails.hideToast " +
                JSON.stringify(error)
            );
        }
    };
    manageAmountChange (event){
        const response = event.detail.value;
        if(response){
            const elems = this.template.querySelectorAll(".ssp-amount-inputs");                
                    for (let index=0 ; index < elems.length; index++) {
                        elems[index].ErrorMessageList= [];
                        elems[index].ErrorMessages();
                    }
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