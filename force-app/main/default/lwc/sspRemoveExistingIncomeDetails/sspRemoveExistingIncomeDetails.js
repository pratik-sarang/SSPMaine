import { LightningElement, track, api, wire } from "lwc";
import employmentEndReason from "@salesforce/schema/SSP_Asset__c.EmploymentEndReason__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import sspEndDate from "@salesforce/label/c.SSP_EndDate";
import sspEndReason from "@salesforce/label/c.SSP_EndReason";
import sspConstants from "c/sspConstants";
import year from "@salesforce/label/c.SSP_YearFrequency";
import week from "@salesforce/label/c.SSP_Week";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import sspEndReasonAlt from "@salesforce/label/c.SSP_EndReasonAlt";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import hour from "@salesforce/label/c.SSP_Hour";
import hours from "@salesforce/label/c.SSP_Hours";
import sspCommaUnpaid from "@salesforce/label/c.SSP_CommaUnpaid";
import sspBiweekly from "@salesforce/label/c.SSP_Biweekly";
import sspWeekly from "@salesforce/label/c.SSP_Weekly";
import sspQuarterly from "@salesforce/label/c.SSP_Quarterly";
import sspMonthly from "@salesforce/label/c.SSP_Monthly";
import sspTwiceMonth from "@salesforce/label/c.SSP_Twice_a_month";
import sspYearly from "@salesforce/label/c.SSP_Yearly";
import sspDaily from "@salesforce/label/c.SSP_Daily";
import sspHourly from "@salesforce/label/c.SSP_Hourly";

const frequencyMap = {};
frequencyMap[sspMonthly] = month;
frequencyMap[sspBiweekly] = biWeek;
frequencyMap[sspQuarterly] = quarter;
frequencyMap[sspTwiceMonth] = twiceMonth;
frequencyMap[sspWeekly] = week;
frequencyMap[sspDaily] = dayFrequency;
frequencyMap[sspHourly] = hour;
frequencyMap[sspYearly] = year;
export default class sspRemoveExistingIncomeDetails extends LightningElement {
    @track sspConstants = sspConstants;
    @track value;
    @api incomeObj;
    @api disabled;
    @api appliedPrograms = [];
    @api metaDataListParent;
    @api timeTravelDate;
    @track showIncomeDetail;
    @track endReasonOptions = [];
    @track endReasonsFieldData = "slds-hide";
    @track showReason = true;
    @track lineOne;
    @track lineTwo;
    @track openModel = false;
    @track progressValue = false;
    @track checkboxValue = false;
    @track header;
    @track error;
    label = {
        sspEndReasonAlt,
        sspEndDate,
        sspEndReason
    };
    tmpIncomeRecord = {
        Id: "",
        checked: false
    };
    /**
     * Method 		: getObjectInfo.
     *
     * @description 	: This wire method is used to fetch Asset Object Info.
     * @author 		: Kireeti Gora.
     **/
    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;

    /**
   * Method 		:   picklistValuesForIncomeEndReason({ error, data }) {.

   * @description 	: This wire method is used to picklist values of Employment End Reason.
   * @author 		: Kireeti Gora   
   * */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: employmentEndReason
    })
    picklistValuesForIncomeEndReason ({ error, data }) {
        if (data) {
            const value = data;

            if (value !== null && value !== undefined && this.incomeObj) {
                const key =
                    value.controllerValues[this.incomeObj.IncomeTypeCode__c];
                this.endReasonOptions = value.values.filter(opt =>
                    opt.validFor.includes(key)
                );
            }
        } else if (error) {
            this.error = error;
        }
    }
    /**
   * Method 		: connectedCallback.
     *
   * @description 	: This method is used to set all details required on load.
   * @author 		: Kireeti Gora
   
   * */
    connectedCallback () {
        this.showIncomeDetail = false;
        const grossAmount = this.incomeObj.TotalGrossAmount__c != null && this.incomeObj.TotalGrossAmount__c !== undefined ? "$" + this.incomeObj.TotalGrossAmount__c.toFixed(2) : "";
        const frequency = frequencyMap[this.incomeObj.IncomePayFrequency__c] != null && frequencyMap[this.incomeObj.IncomePayFrequency__c] != undefined ? "/" + frequencyMap[this.incomeObj.IncomePayFrequency__c] : "";
    this.lineTwo =grossAmount + frequency;     
      
        if (this.incomeObj.IncomeTypeCode__c === "UI") {
          this.showReason = false;
            this.lineOne = null != this.incomeObj.ActivityType__c && this.incomeObj.ActivityType__c != undefined ? this.incomeObj.ActivityType__c : "";
            this.lineTwo = null != this.incomeObj.IncomePayDetailHoursPerWeek__c && this.incomeObj.IncomePayDetailHoursPerWeek__c !== undefined ? this.incomeObj.IncomePayDetailHoursPerWeek__c +" "+ hours + "/" + week + sspCommaUnpaid : "";
        } else if (this.incomeObj.IncomeTypeCode__c === "SE") {
          this.lineOne = this.incomeObj.BusinessTypeCode__c;
        } else if (this.incomeObj.IncomeTypeCode__c === "EA") {
          this.lineOne = this.incomeObj.EmployerName__c;
        } else {
          if (this.incomeObj[this.sspConstants.fieldApiIncomeDetails.IncomeSubTypeCode__c] !== undefined) {
            this.lineOne = this.incomeObj[this.sspConstants.fieldApiIncomeDetails.IncomeSubTypeCode__c];
          }
        }
        this.header = this.lineOne + " " + this.lineTwo;
    }
    /**
   * Method 		: fetchInputComponents.
     *
   * @description 	: This method is used to set fetch elements of this component to parent component.
   * @author 		: Kireeti Gora
   
   * */
    @api
    fetchInputComponents () {
        return this.template.querySelectorAll("." + this.inputClassName);
    }
    set endReasons (value) {
        this.endReasonOptions = this.endReasonOptions;
    }

    @api
    get endReasons () {
        return this.endReasonOptions;
    }
    /**
   * Method 		: inputClassName.
     *
   * @description 	: Construct dynamic class name for base input elements.
   * @author 		: Chirag.
   
   * */
    /**Construct dynamic class name for base input elements. */
    get inputClassName () {
        let className = "removeIncome";
        if (this.incomeObj !== null) {
            className = this.incomeObj.Id + "removeIncome";
        }
        return className;
    }
    /**
   * Method 		: toggleModal.
     *
   * @description 	: This method is used to handle popup show/hide and set values accordingly.
   * @author 		: Chirag
   
   * */
    toggleModal () {
        const ownsCheckboxValue = this.template.querySelector(
            ".sspRemoveIncomeDetail"
        );

        this.checkboxValue = ownsCheckboxValue.isChecked;
        if (this.checkboxValue === false) {
            this.showIncomeDetail = false;

        } else if (this.checkboxValue === true) {
            this.openModel = true;
            this.showIncomeDetail = true;
        }
        const selectedEvent = new CustomEvent("change");

        this.dispatchEvent(selectedEvent);

    }
    /**
   * Method 		: manageEndReasonOptions.
     *
   * @description 	: This method is used to manage end reason picklist values based on income Type.
   * @author 		: Kireeti Gora
   
   * */
    manageEndReasonOptions () {
        if (this.incomeObj.IncomeTypeCode__c && this.endReasonOptions) {
            const key = this.endReasonOptions.controllerValues[
                this.incomeObj.IncomeTypeCode__c
            ];
            this.endReasonOptions = this.incomeSubTypeFieldData.values.filter(
                opt => opt.validFor.includes(key)
            );
            if (this.typeOfDividendOptions) {
                this.incomeSubOptionsLoaded = true;
            }
        }
    }
    /**
     * 
   * Method 		: triggerTwoWayBinding.
     *
   * @description 	: This method is used to create triggerTwoWayBinding between parent and child component.
   * @author 		: Kireeti Gora
   
   * */
    @api
    triggerTwoWayBinding () {
        const incomeObj = this.tmpIncomeRecord;
        if (this.incomeObj) {
            incomeObj.Id = this.incomeObj.Id;
            incomeObj[this.sspConstants.sspAssetFields.isDeleted] = true;
        }
        const inputComponents = this.template.querySelectorAll(
            "." + this.inputClassName
        );

        for (let i = 0; i < inputComponents.length; i++) {
            const tmpCmp = inputComponents[i];
            incomeObj[tmpCmp.fieldName] = tmpCmp.value;
        }
        const ownsCheckboxValue = this.template.querySelector(
            ".sspRemoveIncomeDetail"
        );

        this.checkboxValue = ownsCheckboxValue.isChecked;
        incomeObj.checked = this.checkboxValue;

        if (incomeObj.checked) {
            return incomeObj;
        }
        return null;
    }

    /**
     *
     *@Function-handleProgressValueChange.
     *@Description-This method is used to handle popup/modal functionality.
     *@Author-Kireeti Gora.
     */

    handleProgressValueChange (event) {
        this.progressValue = event.detail;
        this.openModel = false;
        this.toggleIncomeRecordFunction();
    }
    /**
     *
     *@Function-toggleIncomeRecordFunction.
     *@Description-This method is used to handle popup/modal functionality.
     *@Author-Chirag.
     */

    toggleIncomeRecordFunction () {

        if (this.progressValue === false) {
            this.showIncomeDetail = true;
            this.checkboxValue = false;
            this.template.querySelector(".sspRemoveIncomeDetail").handleModalShowHideFields();
        } else {


            this.checkboxValue = false;
            this.showIncomeDetail = false;

        }
        //
        const selectedEvent = new CustomEvent("cancel");

        this.dispatchEvent(selectedEvent);
    }
    get checkForAppliedProgram () {
        const appliedPrograms = this.appliedPrograms;
        const fieldSpecificProgramList = [
            "MAGI",
            "Non-MAGI",
            "SN",
            "KT",
            "CC",
            "SS",
            "MA"
        ];
        let result = false;
        try {
            for (let i = 0; i < appliedPrograms.length; i++) {
                const tmpProgram = appliedPrograms[i];
                if (fieldSpecificProgramList.includes(tmpProgram)) {
                    result = true;
                    break;
                }
            }

            return result;
        } catch (error) {
            console.error(
                "failed in checkForAppliedProgram " + JSON.stringify(error)
            );
            return result;
        }
    }
}