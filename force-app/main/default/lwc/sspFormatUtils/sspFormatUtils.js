/* eslint-disable no-console */
import sspMonthJanuary from "@salesforce/label/c.SSP_January";
import sspMonthFebruary from "@salesforce/label/c.SSP_February";
import sspMonthMarch from "@salesforce/label/c.SSP_March";
import sspMonthApril from "@salesforce/label/c.SSP_April";
import sspMonthMay from "@salesforce/label/c.SSP_May";
import sspMonthJune from "@salesforce/label/c.SSP_June";
import sspMonthJuly from "@salesforce/label/c.SSP_July";
import sspMonthAugust from "@salesforce/label/c.SSP_August";
import sspMonthSeptember from "@salesforce/label/c.SSP_September";
import sspMonthOctober from "@salesforce/label/c.SSP_October";
import sspMonthNovember from "@salesforce/label/c.SSP_November";
import sspMonthDecember from "@salesforce/label/c.SSP_December";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";

const months = new Array();
months[0] = sspMonthJanuary;
months[1] = sspMonthFebruary;
months[2] = sspMonthMarch;
months[3] = sspMonthApril;
months[4] = sspMonthMay;
months[5] = sspMonthJune;
months[6] = sspMonthJuly;
months[7] = sspMonthAugust;
months[8] = sspMonthSeptember;
months[9] = sspMonthOctober;
months[10] = sspMonthNovember;
months[11] = sspMonthDecember;

const todayDate = new Date();

const formatLabels = (format, parameters) => {
    const args = Array.prototype.slice.call(parameters, 0);
    return format.replace(/{(\d+)}/g, function (match, number) {
        return typeof args[number] != "undefined" ? args[number] : match;
    });
};

const getPicklistSubTypeValues = (
    controllingFieldSelectedValue,
    dependentFieldData
) => {
    const key =
        dependentFieldData.controllerValues[controllingFieldSelectedValue];
    const subTypeOptions = dependentFieldData.values.filter(opt =>
        opt.validFor.includes(key)
    );
    return subTypeOptions;
};

const getCurrentMonthName = () => months[todayDate.getMonth()];

const getPreviousMonthName = () => {
    if (todayDate.getMonth() === 0) {
        return months[11];
    }
    return months[todayDate.getMonth() - 1];
};

const getNextMonthName = () => {
    if (todayDate.getMonth() === 11) {
        return months[0];
    }
    return months[todayDate.getMonth() + 1];
};

const getYesNoOptions = () => [
    {
        label: sspYes,
        value: "true"
    },
    { label: sspNo, value: "false" }
];

const getOtherValue = () => ({ label: "Other", value: "Other" });

export {
    formatLabels,
    getPicklistSubTypeValues,
    getCurrentMonthName,
    getPreviousMonthName,
    getNextMonthName,
    getYesNoOptions,
    getOtherValue
};