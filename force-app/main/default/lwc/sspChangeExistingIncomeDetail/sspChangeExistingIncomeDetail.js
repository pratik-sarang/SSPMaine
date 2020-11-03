/**
 * Component Name: sspChangeIncomeDetail.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component to handle individual record/entry for change existing income screen.
 * Date: 11/12/2019.
 */
import { LightningElement, api, track } from "lwc";
import sspJobIncomeFromEmployerAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_JobIncomeFromEmployer";
import sspSelfEmploymentIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_SelfEmploymentIncome";
import sspDividendsInterestsRoyaltiesAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_DividendsInterestsRoyalties";
import sspSupportMaintenanceIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_SupportMaintenanceIncome";
import sspInsuranceSettlementsBenefitsAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_InsuranceSettlementsBenefits";
import sspSocialSecurityRetirementPensionAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_SocialSecurityRetirementPension";
import sspOtherUnearnedIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_OtherUnearnedIncome";
import sspUnpaidIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_UnpaidIncome";

import sspIncomeBeforeTaxes from "@salesforce/label/c.SSP_IncomeBeforeTaxes";
import sspIncomeFromTipsBeforeTaxes from "@salesforce/label/c.SSP_IncomeFromTipsBeforeTaxes";
import sspExpensesRelatedTo from "@salesforce/label/c.SSP_ExpensesRelatedTo";
import sspHoursWorkedPerWeek from "@salesforce/label/c.SSP_HoursWorkedPerWeek";
import sspIncomeFrequency from "@salesforce/label/c.SSP_IncomeFrequency";
import sspIncomeFrequencyAlternateText from "@salesforce/label/c.SSP_IncomeFrequencyAlternateText";

import sspCommaUnpaid from "@salesforce/label/c.SSP_CommaUnpaid";
import sspForwardSlash from "@salesforce/label/c.SSP_forwardSlash";
import sspDollarSign from "@salesforce/label/c.SSP_DollarSign";
import sspConstants from "c/sspConstants";
import hour from "@salesforce/label/c.SSP_Hour";
import week from "@salesforce/label/c.SSP_Week";
import sspContractStartDate from "@salesforce/label/c.SSP_ContractStartDate";
import sspContractEndDate from "@salesforce/label/c.SSP_ContractEndDate";
import year from "@salesforce/label/c.SSP_YearFrequency";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import sspContractual from "@salesforce/label/c.SSP_Contractual";
import sspOneTime from "@salesforce/label/c.SSP_LumpSum"
import utility from "c/sspUtility";

const programs = {
    MA: sspConstants.programValues.MA,
    KT: sspConstants.programValues.KT,
    SN: sspConstants.programValues.SN,
    SS: sspConstants.programValues.SS,
    DS: sspConstants.programValues.DS,
    CC: sspConstants.programValues.CC,
    KP: sspConstants.programValues.KP
};
const frequencyMap = {
    MO: month,
    BW: biWeek,
    QU: quarter,
    SM: twiceMonth,
    WE: week,
    YR: year,
    DA: dayFrequency,
    HO: hour,
    SP: sspContractual,
    ON: sspOneTime
};
export default class sspChangeExistingIncomeDetail extends LightningElement {
    @api incomeFrequencyValueToLabel = {};
    @api incomeTypeValueToLabel = {};
    @api businessTypeValueToLabel = {};
    @api incomeSubTypeValueToLabel = {};
    @api activityTypeValueToLabel = {};
    @api appliedProgramList = [];
    @api metaDataListParent;
    @api disabled;
    @api incomeObj = {
        Id: "",
        [sspConstants.sspAssetFields.IncomePayFrequency__c]: "",
        [sspConstants.sspAssetFields.TotalGrossAmount__c]: "",
        [sspConstants.sspAssetFields.Tips__c]: "",
        [sspConstants.sspAssetFields.IncomePayDetailHoursPerWeek__c]: "",
        [sspConstants.sspAssetFields.ExpenseAmount__c]: "",
        [sspConstants.sspAssetFields.IncomeSubTypeCode__c]: "",
        [sspConstants.sspAssetFields.ActivityType__c]: ""
    };

    customLabel = {
        sspIncomeBeforeTaxes,
        sspIncomeFromTipsBeforeTaxes,
        sspHoursWorkedPerWeek,
        sspIncomeFrequency,
        sspExpensesRelatedTo,
        sspIncomeFrequencyAlternateText,
        sspContractStartDate,
        sspContractEndDate
    };
    tmpIncomeRecord = {
        Id: "",
        [sspConstants.sspAssetFields.IncomePayFrequency__c]: "",
        [sspConstants.sspAssetFields.TotalGrossAmount__c]: "",
        [sspConstants.sspAssetFields.Tips__c]: "",
        [sspConstants.sspAssetFields.IncomePayDetailHoursPerWeek__c]: "",
        [sspConstants.sspAssetFields.ExpenseAmount__c]: ""
    };

    @track headerOne;
    @track headerTwo;
    @track containerClass = "slds-hide";
    @track totalGrossAmountLabel;
    @track tipsPerFrequencyLabel;
    @track expensesAmountLabel;
    @track header;
    @track toggleIncomeRecord = false;
    @track incomeFrequencyOptions = [];   
    @track showContractFields = false;
    @track contractStartDate;
    @track showHoursField = false;
    @api timeTravelDate;
    /**
     * @function : connectedCallback
     * @description	: Connected callback to identify headers for income tile.
     */
    connectedCallback () {
        try {
            this.identifyHeaders(this.incomeObj);
            let incomeTypeResult = false;
            let incomeTypeFrequency = false;
            const programList = [programs.CC];
            if (
                this.incomeObj != null &&
                (this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI ||
                    this.incomeObj.IncomeTypeCode__c ===
                        sspSelfEmploymentIncomeAPI ||
                    this.incomeObj.IncomeTypeCode__c === sspUnpaidIncomeAPI)
            ) {
                incomeTypeResult = true;
            }
            if (
                this.incomeObj != null && this.incomeObj.IncomePayFrequency__c === "HO")
                {
                    incomeTypeFrequency = true;
            }
           
              this.showHoursField =   incomeTypeResult &&
                (incomeTypeFrequency || this.checkForAppliedProgram(this.appliedProgramList, programList));
        
            if(this.incomeObj !== null && this.incomeObj !== undefined && this.incomeObj.IncomePayFrequency__c !== undefined && this.incomeObj.IncomePayFrequency__c !== null && (this.incomeObj.IncomePayFrequency__c === "SP" || this.incomeObj.IncomePayFrequency__c === "ON" )){
                  this.showContractFields = true;
                  }else{
                     this.showContractFields = false;  
                  }      
        } catch (error) {
            console.error(
                "failed in sspChangeExistingIncomeDetail.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : incomeFrequencies
     * @description	: Method to set income frequencies.
     * @param {object} value - Income frequency values.
     */
    set incomeFrequencies (value) {
        let incomeFrequencyOptions = [];
        if (value != null && value != undefined &&  this.incomeObj != null ) {
            incomeFrequencyOptions = value;
        }
        
        this.incomeFrequencyOptions = incomeFrequencyOptions;
    }

    @api
    get incomeFrequencies () {
        let incomeFrequencyOptions = [];
        if (this.incomeFrequencyOptions != null && this.incomeFrequencyOptions != undefined &&  this.incomeObj != null && this.incomeObj !== undefined &&
            this.incomeObj.IncomeTypeCode__c !== null && this.incomeObj.IncomeTypeCode__c !== undefined) {         
           const value = this.incomeFrequencyOptions;
            if((this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    "SE" 
              )){
                incomeFrequencyOptions = value;
                }else if(  this.incomeObj.IncomeTypeCode__c === sspOtherUnearnedIncomeAPI){
                    incomeFrequencyOptions = value.filter(
                        opt =>  opt.value !== "HO"
                    );
                }else{
                    incomeFrequencyOptions=  value.filter(
                        opt =>  opt.value !== "HO" && opt.value !== "SP" && opt.value !== "ON"
                    );

                }   
              
          
        }
        this.incomeFrequencyOptions = incomeFrequencyOptions;
        return this.incomeFrequencyOptions;
    }

    get containerClassName () {
        return this.containerClass;
    }

    /**
     * @function : inputClassName
     * @description	: Construct dynamic class name for base input elements.
     */
    get inputClassName () {
        let className = "incomeInputs";
        if (this.incomeObj !== null) {
            className = this.incomeObj.Id + "incomeInputs";
        }
        return className;
    }

    /**
     * @function : showIncomePayFrequency
     * @description	: Method/Parameter to identify visibility of IncomePayFrequency input component.
     */
    get showIncomePayFrequency () {
        let incomeTypeResult = false;
        const programList = [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ];
        if (
            this.incomeObj != null &&
            (this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSelfEmploymentIncomeAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspDividendsInterestsRoyaltiesAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSupportMaintenanceIncomeAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspInsuranceSettlementsBenefitsAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSocialSecurityRetirementPensionAPI ||
                this.incomeObj.IncomeTypeCode__c === sspOtherUnearnedIncomeAPI)
        ) {
            incomeTypeResult = true;
        }

        return (
            incomeTypeResult &&
            this.checkForAppliedProgram(this.appliedProgramList, programList)
        );
    }

    /**
     * @function : showTotalGrossAmount
     * @description	: Method/Parameter to identify visibility of TotalGrossAmount input component.
     */
    get showTotalGrossAmount () {
        let incomeTypeResult = false;
        const programList = [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ];
        if (
            this.incomeObj != null &&
            (this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSelfEmploymentIncomeAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspDividendsInterestsRoyaltiesAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSupportMaintenanceIncomeAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspInsuranceSettlementsBenefitsAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSocialSecurityRetirementPensionAPI ||
                this.incomeObj.IncomeTypeCode__c === sspOtherUnearnedIncomeAPI)
        ) {
            incomeTypeResult = true;
        }
        return (
            incomeTypeResult &&
            this.checkForAppliedProgram(this.appliedProgramList, programList)
        );
    }

    /**
     * @function : showTipsPerFrequency
     * @description	: Method/Parameter to identify visibility of TipsPerFrequency input component.
     */
    get showTipsPerFrequency () {
        let incomeTypeResult = false;
        const programList = [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ];
        if (
            this.incomeObj != null &&
            this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI
        ) {
            incomeTypeResult = true;
        }
        return (
            incomeTypeResult &&
            this.checkForAppliedProgram(this.appliedProgramList, programList)
        );
    }

    /**
     * @function : showIncomePayDetailHoursPerWeek
     * @description	: Method/Parameter to identify visibility of IncomePayDetailHoursPerWeek input component.
     */

    get showIncomePayDetailHoursPerWeek () {
        let incomeTypeResult = false;
        let incomeTypeFrequency = false;
        const programList = [programs.CC];
        if (
            this.incomeObj != null &&
            (this.incomeObj.IncomeTypeCode__c === sspJobIncomeFromEmployerAPI ||
                this.incomeObj.IncomeTypeCode__c ===
                    sspSelfEmploymentIncomeAPI ||
                this.incomeObj.IncomeTypeCode__c === sspUnpaidIncomeAPI)
        ) {
            incomeTypeResult = true;
        }
        if (
            this.incomeObj != null && this.incomeObj.IncomePayFrequency__c === "HO")
            {
                incomeTypeFrequency = true;
        }
       
        return (
            incomeTypeResult &&
            (incomeTypeFrequency || this.checkForAppliedProgram(this.appliedProgramList, programList))
        );
    }

    /**
     * @function : showExpensesAmount
     * @description	: Method/Parameter to identify visibility of ExpensesAmount input component.
     */
    get showExpensesAmount () {
        let incomeTypeResult = false;
        const programList = [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ];
        if (
            this.incomeObj != null &&
            this.incomeObj.IncomeTypeCode__c === sspSelfEmploymentIncomeAPI
        ) {
            incomeTypeResult = true;
        }
        return (
            incomeTypeResult &&
            this.checkForAppliedProgram(this.appliedProgramList, programList)
        );
    }

    /**
     * @function : triggerTwoWayBinding
     * @description	: Method to construct a fieldApi and value pair with the updated values.
     */
    @api
    triggerTwoWayBinding () {
        const incomeObj = this.tmpIncomeRecord;
        incomeObj.Id = this.incomeObj.Id;

        const inputComponents = this.template.querySelectorAll(
            "." + this.inputClassName
        );

        for (let i = 0; i < inputComponents.length; i++) {
            const tmpCmp = inputComponents[i];
            incomeObj[tmpCmp.fieldName] = tmpCmp.value;
        }
        Object.keys(incomeObj).forEach(function (key) {
            if (incomeObj[key] === null ||
                incomeObj[key] === undefined ||
                incomeObj[key] === ""){
                delete incomeObj[key];
            }
        });
        return incomeObj;
    }

    
    handleContractStartDate (event) {
        this.contractStartDate  = event.detail.value;
  
      }

      setHourField (value) {
        this.showHoursField  = value;
  
      }

    /**
     * @function : fetchInputComponents
     * @description	: Method to fetch all input components - to be used by parent component.
     */
    @api
    fetchInputComponents () {
        return this.template.querySelectorAll("." + this.inputClassName);
    }

    /**
     * @function : checkForAppliedProgram
     * @description	: Method to identify if programs opted by individual member match with the once applicable for input field visibility.
     * @param {object[]} appliedProgramList - List of applied programs.
     * @param {object[]} fieldSpecificProgramList - List of programs required by particular field to render.
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
     * @function : toggleIncomeRecordFunction
     * @description	: Method to handle show & hide for input fields specific to particular income tile.
     */
    toggleIncomeRecordFunction () {
        if (this.toggleIncomeRecord) {
            this.toggleIncomeRecord = false;
            this.containerClass = "slds-hide";
        } else {
            this.toggleIncomeRecord = true;
            this.containerClass = "slds-show";
            //Added as part of Defect #: 373729
            if (!utility.isUndefinedOrNull(this.incomeObj.IncomeTypeCode__c) && this.incomeObj.IncomeTypeCode__c === sspUnpaidIncomeAPI) {
                this.showHoursField = true;
            }
        }
        const incomePayFrequency = this.incomeFrequencyValueToLabel[
            this.incomeObj.IncomePayFrequency__c
        ];
        this.totalGrossAmountLabel =
            incomePayFrequency + " " + this.customLabel.sspIncomeBeforeTaxes;
        this.tipsPerFrequencyLabel =
            incomePayFrequency +
            " " +
            this.customLabel.sspIncomeFromTipsBeforeTaxes;
        this.expensesAmountLabel =
            incomePayFrequency + " " + this.customLabel.sspExpensesRelatedTo;

        const toggleEvent = new CustomEvent("toggle", {
            detail: this.toggleIncomeRecord
        });
        this.dispatchEvent(toggleEvent);
    }

    /**
     * @function : setLabel
     * @description	: Method to handle change in labels of input fields on change in pay frequency.
     * @param {object} event - Frequency on change event.
     */
    setLabel (event) {
        const value = event.target.value;       
        const programList = [programs.CC];
        if (
            (value !== null &&  value === "HO") 
            || this.checkForAppliedProgram(this.appliedProgramList, programList))
            {
                this.showHoursField = true;
        }else{
            this.showHoursField = false;
        }
         if(value !== null && (value === "SP" || value === "ON") ){
            this.showContractFields = true;
            }else{
                this.showContractFields = false;  
            }    
        const incomePayFrequency = this.incomeFrequencyValueToLabel[value];
        if (incomePayFrequency !== null && incomePayFrequency !== undefined) {
            this.totalGrossAmountLabel =
                incomePayFrequency +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.tipsPerFrequencyLabel =
                incomePayFrequency +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expensesAmountLabel =
                incomePayFrequency +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        }
    }

    /**
     * @function : identifyHeaders
     * @description	: Method to construct header details for a particular income tile.
     * @param {object} incomeRecord - SF income record.
     */

    identifyHeaders (incomeRecord) {
        if (incomeRecord != null && incomeRecord != undefined) {
            const income = null!=incomeRecord.TotalGrossAmount__c && incomeRecord.TotalGrossAmount__c!==undefined ? sspDollarSign +  incomeRecord.TotalGrossAmount__c.toFixed(2)  :"";
            const incomeTypeCode = incomeRecord.IncomeTypeCode__c;
            const incomeType = this.incomeTypeValueToLabel[
                incomeRecord.IncomeTypeCode__c
            ];
            // const incomePayFrequency =  null!= this.incomeFrequencyValueToLabel[incomeRecord.IncomePayFrequency__c] && this.incomeFrequencyValueToLabel[incomeRecord.IncomePayFrequency__c]!==undefined ? sspForwardSlash +this.incomeFrequencyValueToLabel[incomeRecord.IncomePayFrequency__c]:"";
            const incomePayFrequency = null!=frequencyMap[incomeRecord.IncomePayFrequency__c] && frequencyMap[incomeRecord.IncomePayFrequency__c]!==undefined ? sspForwardSlash + frequencyMap[incomeRecord.IncomePayFrequency__c]:"";
            const businessType = this.businessTypeValueToLabel[
                incomeRecord.BusinessTypeCode__c
            ];
            const activityType = incomeRecord.ActivityType__c;//this.activityTypeValueToLabel[incomeRecord.ActivityType__c];
            const incomeSubTypeValue = incomeRecord[sspConstants.sspAssetFields.IncomeSubTypeCode__c];
            const incomeSubType = this.incomeSubTypeValueToLabel[incomeSubTypeValue];
            const employerName = incomeRecord.EmployerName__c;
            const hoursPerWeek = null!= incomeRecord.IncomePayDetailHoursPerWeek__c && incomeRecord.IncomePayDetailHoursPerWeek__c!==undefined ? incomeRecord.IncomePayDetailHoursPerWeek__c + hour + "/" + week + sspCommaUnpaid: "";

            this.headerOne = incomeType;
            this.headerTwo =
                 income + incomePayFrequency;
            if (incomeTypeCode === sspJobIncomeFromEmployerAPI) {
                this.headerOne = employerName;
            } else if (incomeTypeCode === sspSelfEmploymentIncomeAPI) {
                this.headerOne = businessType;
            } else if (incomeTypeCode === sspUnpaidIncomeAPI) {
                if(activityType !== undefined){
                    this.headerOne = activityType;
                }
                this.headerTwo = hoursPerWeek  ;
            }else if(incomeSubType !== undefined){
                this.headerOne = incomeSubType;
            }
            this.header = this.headerOne + " " + this.headerTwo;
        }
    }

    /**
     * @function : fetchToggleStatus
     * @description	: method to return toggle status of the income tile.
     */
    @api
    fetchToggleStatus () {
        return this.toggleIncomeRecord;
    }
}
