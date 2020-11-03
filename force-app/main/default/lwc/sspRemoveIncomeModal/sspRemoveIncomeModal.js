/**
 * Component Name: sspRemoveIncomeModal.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component for Remove income modal.
 * Date: 11/19/2019.
 */
import { LightningElement, track, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import sspRemoveIncomeModalContent1 from "@salesforce/label/c.SSP_RemoveIncomeModalContent1";
import sspRemoveIncomeModalContent2 from "@salesforce/label/c.SSP_RemoveIncomeModalContent2";
import sspRemoveIncomeModalContent3 from "@salesforce/label/c.SSP_RemoveIncomeModalContent3";
import sspRemoveIncomeModalContent4 from "@salesforce/label/c.SSP_RemoveIncomeModalContent4";
import sspRemoveIncome from "@salesforce/label/c.SSP_RemoveIncome";
import sspRemoveIncomeQuestionMark from "@salesforce/label/c.SSP_RemoveIncomeQuestionMark";
import sspDelete from "@salesforce/label/c.SSP_Delete";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspJobIncomeFrom from "@salesforce/label/c.SSP_JobIncomeFrom";
import sspCommaUnpaid from "@salesforce/label/c.SSP_CommaUnpaid";
import sspForwardSlash from "@salesforce/label/c.SSP_forwardSlash";
import sspDollarSign from "@salesforce/label/c.SSP_DollarSign";
import sspJobIncomeFromEmployerAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_JobIncomeFromEmployer";
import sspSelfEmploymentIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_SelfEmploymentIncome";
import sspUnpaidIncomeAPI from "@salesforce/label/c.SSP_IncomeTypeAPI_UnpaidIncome";

import sspConstants from "c/sspConstants";
import year from "@salesforce/label/c.SSP_YearFrequency";
import week from "@salesforce/label/c.SSP_Week";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import hour from "@salesforce/label/c.SSP_Hour";
import hours from "@salesforce/label/c.SSP_Hours";//Added this as part of defect 368480
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

const FIELDS = [
    "SSP_Asset__c.TotalGrossAmount__c",
    "SSP_Asset__c.SSP_Member__r.FirstName__c",
    "SSP_Asset__c.SSP_Member__r.LastName__c",
    "SSP_Asset__c.IncomeTypeCode__c",
    "SSP_Asset__c.RecordType.Name",
    "SSP_Asset__c.RecordType.DeveloperName",
    "SSP_Asset__c.IncomePayFrequency__c",
    "SSP_Asset__c.EmployerName__c",
    "SSP_Asset__c.BusinessTypeCode__c",
  "SSP_Asset__c.IncomePayDetailHoursPerWeek__c",
  "SSP_Asset__c.ActivityType__c",
  "SSP_Asset__c.IncomeSubtypeCode__c"
];
export default class sspRemoveIncomeModal extends LightningElement {
    label = {
        sspRemoveIncomeModalContent1,
        sspRemoveIncomeModalContent2,
        sspRemoveIncomeModalContent3,
        sspRemoveIncomeModalContent4,
        sspRemoveIncome,
        sspRemoveIncomeQuestionMark,
        sspDelete,
        sspCancel
    };
    @api incomeId;
    incomeRecord;
    @track contentSlot1 = "";
    @api openModel = false;
    @track memberName;
    @api progressValue;
    @track lineOne;
    @track lineTwo;
    @track reference;
    /*
     * @function : fetchIncomeData
     * @description	: Method to fetch required income data
     */
    @wire(getRecord, { recordId: "$incomeId", fields: FIELDS })
    fetchIncomeData ({ error, data }) {
        try {
            if (data) {
                this.incomeRecord = data;
        const income = this.incomeRecord.fields.TotalGrossAmount__c.value;
        this.memberName =
          this.incomeRecord.fields.SSP_Member__r.value.fields.FirstName__c.value +" " + this.incomeRecord.fields.SSP_Member__r.value.fields.LastName__c.value;
                const incomeType = this.incomeRecord.fields.IncomeTypeCode__c
                    .displayValue;
       const incomeSubtype = this.incomeRecord.fields.IncomeSubtypeCode__c.displayValue;
        const incomeTypeCode = this.incomeRecord.fields.IncomeTypeCode__c.value;
        const incomePayFrequency = null != frequencyMap[ this.incomeRecord.fields.IncomePayFrequency__c.displayValue ] && frequencyMap[this.incomeRecord.fields.IncomePayFrequency__c.displayValue] !== undefined ? sspForwardSlash + frequencyMap[this.incomeRecord.fields.IncomePayFrequency__c.displayValue ] : "";
       const businessType = this.incomeRecord.fields.BusinessTypeCode__c
          .displayValue;
        const employerName = this.incomeRecord.fields.EmployerName__c.value;
                const hoursPerWeek = this.incomeRecord.fields
                    .IncomePayDetailHoursPerWeek__c.value;

        this.lineOne = incomeSubtype!=null && incomeSubtype!==undefined ? incomeSubtype :incomeType;
        this.lineTwo = sspDollarSign + income + incomePayFrequency;
                if (incomeTypeCode === sspJobIncomeFromEmployerAPI) {
                    this.lineOne = sspJobIncomeFrom + " " + employerName;
                } else if (incomeTypeCode === sspSelfEmploymentIncomeAPI) {
                    this.lineOne = businessType;
                } else if (incomeTypeCode === sspUnpaidIncomeAPI) {
          this.lineOne = this.incomeRecord.fields.ActivityType__c.displayValue;
          this.lineTwo = hoursPerWeek +" "+ hours +"/"+ week + sspCommaUnpaid;
                }
            } else {
                console.error(error);
            }
        } catch (error) {
            console.error(
                "failed in sspRemoveIncomeModal.fetchIncomeData " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : removeIncome
     * @description	: Method to handle click of remove income button
     */
    removeIncome () {
        try {
            this.openModel = false;
            this.progressValue = true;
            const selectedEvent = new CustomEvent(
                sspConstants.events.progressValueChange,
                {
                    detail: this.progressValue
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "failed in sspRemoveIncomeModal.removeIncome " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : closeModal
     * @description	: Method to close modal on click of close button
     */
    closeModal () {
        try {
            this.openModel = false;
            this.openModel = "";
            this.progressValue = false;
            const selectedEvent = new CustomEvent(
                sspConstants.events.progressValueChange,
                {
                    detail: this.progressValue
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "failed in sspRemoveIncomeModal.closeModal " +
                JSON.stringify(error)
            );
        }
    }
}