/**
 * Component Name: sspBaseComponentInputPicklist.
 * Description: This component is used to render drop down.
 */
import { LightningElement, api, track } from "lwc";
import { events, classNames } from "c/sspConstants";
import sspSelect from "@salesforce/label/c.SSP_Select";
import sspUtility from "c/sspUtility";

export default class sspBaseComponentInputPicklist extends LightningElement {
    select = sspSelect;
    @track selectedValueDisplay;
    @track metaListValues;
    @track optionsValue = [];
    @track ErrorMsgList = [];
    @api name = "";
    @api label = "";
    @api title = "";
    @api required;
    @api className = "";
    @api value = "";
    @api option;
    @api fieldName;
    @api entityName;
    @api ErrorMessageList = [];
    @api disabled;
    @api placeholder = [];
    @api matchValue;
    @api isHelpText = false;
    @api helpTextContent;
    @api oldValue = "";
    hasRendered = false;
    @api
    get metaList () {
        return this.metaListValues;
    }
    set metaList (value) {
        if (value) {
            this.metaListValues = value;
            this.getMetadataRecord();
        }
    }

    get isDisabled () {
        let isDisabled = this.disabled;
        try {
            const metaList = this.metaListValues;
            if (metaList != null && this.metaList != undefined &&
                this.fieldName != null && this.fieldName != undefined &&
                this.entityName != null && this.entityName != undefined &&
                metaList[this.fieldName + "," + this.entityName] != null && metaList[this.fieldName + "," + this.entityName] != undefined) {
                const fieldDisability = metaList[this.fieldName + "," + this.entityName].isDisabled;
                isDisabled = (fieldDisability != null && fieldDisability != undefined) ? (isDisabled || fieldDisability) : isDisabled;
            }
        } catch (error) {
            console.error("Error in sspBaseComponentInputPicklist.isDisabled", error);
        }

        return isDisabled;
    }
    
    /*
     * @function : handleValidations
     * @description : This method is used to handle the picklist validations.
     * @param    {event}
     */
    handleValidations = (event, nextEventClick) => {
        try {
            let inputVal;
            if (event) {
                this.value = event.srcElement.value;
                this.selectedValue = event.srcElement.value;
                inputVal = event.srcElement.value;
            } else {
                inputVal = this.value;
                this.selectedValue = this.value;
            }

            const errorMessageList = this.ErrorMessageList;
            if (
                this.metaListValues !== undefined &&
                this.fieldName !== undefined &&
                this.entityName !== undefined
            ) {
                const fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];
                if (fetchedList !== null && fetchedList !== undefined) {
                    if (fetchedList.Input_Required__c) {
                        const msg = fetchedList.Input_Required_Msg__c;
                        this.handleRequiredValidation(
                            inputVal,
                            errorMessageList,
                            msg
                        );
                    }
                    if (fetchedList.SignatureMatchValidator__c) {
                        const msg = fetchedList.SignatureMatchValidator_Msg__c;
                        this.validateSignatureMatch(
                            inputVal,
                            errorMessageList,
                            msg
                        );
                    }
                }
            }
            if (!nextEventClick) {
                const selectedEvent = new CustomEvent(
                    events.handlePicklistChange,
                    {
                        detail: this.value
                    }
                );
                if (event && event.type && event.type !== "blur") {
                    this.dispatchEvent(selectedEvent);
                }
                
            }
            if (this.ErrorMessageList.length) {
                this.template.querySelector(".genericInput select").classList.add("ssp-input-error");
            }
            else {
                this.template.querySelector(".genericInput select").classList.remove("ssp-input-error");
            }
        } catch (error) {
            console.error(
                "failed in sspBaseComponentInputPicklist.handleValidations " +
                    JSON.stringify(error)
            );
        }
    };
    /*
     * @function : handleRequiredValidation
     * @description : This method is used to handle the required validation.
     * @param    {inputValue, errorMessageList, msg}
     */
    handleRequiredValidation = (inputValue, errorMessageList, msg) => {
        try {
            const requiredValue = true;
            const inputVal =
                inputValue !== undefined || inputValue !== ""
                    ? inputValue
                    : this.value;
            if (
                requiredValue &&
                (inputVal === "" || inputVal === undefined || inputVal === null)
            ) {
                if (errorMessageList.indexOf(msg) === -1) {
                    errorMessageList.push(msg);
                }
            } else {
                if (errorMessageList.indexOf(msg) > -1) {
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (error) {
            console.error(
                "failed in sspBaseComponentInputPicklist.handleRequiredValidation " +
                    JSON.stringify(error)
            );
        }
    };

    /*
     * @function : ErrorMessages
     * @description : This method is used to handle the error messages.
     */
    @api
    ErrorMessages () {
        const event = null;
        try {
            this.handleValidations(event, true);
            const errorList = this.ErrorMessageList;
            if (this.ErrorMessageList.length) {
                this.template.querySelector(".genericInput select").classList.add("ssp-input-error");
            }
            else {
                this.template.querySelector(".genericInput select").classList.remove("ssp-input-error");
            }
            return errorList;
        } catch (error) {
            console.error(
                "failed in sspBaseComponentInputPicklist.ErrorMessages " +
                    JSON.stringify(error)
            );
            return null;
        }
    }

    /*
     * @function : getMetadataRecord
     * @description : This method is used to render the picklist options.
     */
    getMetadataRecord = () => {
        try {
            if (this.option !== undefined) {
                const picklistOptions = this.option;

                const picklistLabelValue = [];

                picklistOptions.forEach(opt => {
                    if (opt.label !== undefined) {
                        picklistLabelValue.push({
                            label: opt.label,
                            value: opt.value
                        });
                        this.optionsValue.push(opt.value);
                    }
                });
                this.option = picklistLabelValue;
            }
        } catch (error) {
            console.error(
                "failed in sspBaseComponentInputPicklist.getMetadataRecord " +
                    JSON.stringify(error)
            );
        }
    };
    @api
    get selectedValue () {
        return this.selectedValueDisplay;
    }
    set selectedValue (value) {
        if (value) {
            this.selectedValueDisplay = value;
        }
    }
    renderedCallback () {
        try {
            this.oldValue = this.setOldValue(this.value, this.oldValue);
            const pickListDropDown = this.template.querySelector(
                classNames.sspPicklistDropDown
            );

            if (
                this.value !== undefined &&
                this.value !== null &&
                this.optionsValue !== null &&
                this.optionsValue !== undefined
            ) {
                pickListDropDown.value = this.value;
            }
            // Start - RAC POC Code
            this.oldValue = this.setOldValue(this.value, this.oldValue);
            // End - RAC POC Code
            if (this.hasRendered) {
                if (this.ErrorMessageList.length) {
                    this.template.querySelector(".genericInput select").classList.add("ssp-input-error");
                }
                else {
                    this.template.querySelector(".genericInput select").classList.remove("ssp-input-error");
                }
            }
            this.hasRendered = true;
        } catch (error) {
            console.error("Error in render call back", error);
        }
    }

    /*
     * @function : validateSignatureMatch
     * @description : This method is used to handle the signature match validation.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateSignatureMatch = (inputValParam, errorMessageList, msg) => {
        try {
            const errorList = [...errorMessageList];
            const inputVal =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : "";
            const matchValue = this.matchValue;
             if (this.matchValue == undefined && inputVal.length > 0) {
                 this.hasError = true;
                 if (errorList.indexOf(msg) === -1) {
                    errorList.push(msg);
                 }
             }
            else if (
                (inputVal.length === 0 ||
                    inputVal.toLowerCase() === matchValue.toLowerCase()) &&
                    errorList.includes(msg)
            ) {
                errorList.splice(errorList.indexOf(msg), 1);
            } else if (
                inputVal.length > 0 &&
                inputVal.toLowerCase() != matchValue.toLowerCase()
            ) {
                this.hasError = true;
                if (errorList.indexOf(msg) === -1) {
                    errorList.push(msg);
                }
            }
            if ((sspUtility.isUndefinedOrNull(inputVal) || sspUtility.isEmpty(inputVal)) && !sspUtility.isUndefinedOrNull(matchValue) && !(sspUtility.isEmpty(matchValue))) {
                this.hasError = true;
                if (errorList.indexOf(msg) === -1) {
                    errorList.push(msg);
                }
            }

            this.ErrorMessageList = errorList;
        } catch (error) {
            console.error("Error in validateSignatureMatch", error);
        }
    };

    /*
     * @function : setOldValue()
     * @description : This method is use to set the old value.
     * @param {String} newValue - New value.
     * @param {String} oldValue - Old value.
     */
    setOldValue = (newValue, oldValue) => {
        let oldValueReceived = oldValue;
        if (newValue !== undefined && oldValue === "") {
            oldValueReceived = newValue;
        }
        return oldValueReceived;
    };
}