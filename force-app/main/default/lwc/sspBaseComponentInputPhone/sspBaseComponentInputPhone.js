/*
 * Component name  : sspBaseComponentInputPhone
 * @description    : Generic component for Input Phone.
 */
import { LightningElement, track, api } from "lwc";
import { fetchedListData, events } from "c/sspConstants";
import sspCaseApplicationMessage from "@salesforce/label/c.SSP_SearchCaseApplicationValidationMessage";

export default class baseComponentInputPhone extends LightningElement {
    @api recordId;
    @api label = "";
    @api title = "";
    @api required;
    @api className = "";

    @api entityName;
    @api fieldName;
    @api maxLength;
    @api minLength;
    @api handleChange = false;
    @api ErrorMessageList = [];
    @api disabled;
    @api placeholder;
    @track ErrorMsgList = [];
    @track metaListValues;
    @track pattern = "";
    @track hasError;
    @track customMessage;
    @track name = "";
    @api oldValue = "";
    @api caseApplicationField = false;
    @track _value = "";
    hasRendered = false;
    @api
    get value () {
        return this._value
            ? !this.caseApplicationField
                ? this._value.replace(/(\d{3})(\d{3})(\d{4})/, "$1-$2-$3")
                : this._value
            : this._value;
    }
    set value (value) {
        if (value) {
            const phone = value.length > 11 ? value.replace(/[^\d]/g, "") : value;
            this._value = !this.caseApplicationField
                ? phone
                    .replace(/^(\d{3})-(\d{3})$/, "$1-$2-")
                    .replace(/^(\d{3})$/, "$1-")
                : phone;
        } else {
            this._value = value;
        }
    }

    @api
    get customErrorMessageList () {
        return this.customMessage;
    }
    set customErrorMessageList (value) {
        try {
            this.customMessage = value;
            if (value) {
                const self = this;
                value.forEach(function (key) {
                    if (
                        self.ErrorMessageList &&
                        self.ErrorMessageList.length > 0 &&
                        self.ErrorMessageList.indexOf(key) === -1
                    ) {
                        self.ErrorMessageList = JSON.parse(
                            JSON.stringify(self.ErrorMessageList)
                        ).push(key);
                    } else {
                        self.ErrorMessageList = [key];
                    }
                });
            }
        } catch (error) {
            console.error("Error in customErrorMessageList", error);
        }
    }

    @api
    get metaList () {
        return this.metaListValues;
    }
    set metaList (value) {
        try {
            this.metaListValues = value;
            if (value !== undefined) {
                this.getMetadataRecord();
            }
        } catch (error) {
            console.error("Error in metaList", error);
        }
    }

    get isDisabled () {
        let isDisabled = this.disabled;
        try {
            const metaList = this.metaListValues;
            if (
                metaList != null &&
                this.metaList != undefined &&
                this.fieldName != null &&
                this.fieldName != undefined &&
                this.entityName != null &&
                this.entityName != undefined &&
                metaList[this.fieldName + "," + this.entityName] != null &&
                metaList[this.fieldName + "," + this.entityName] != undefined
            ) {
                const fieldDisability =
                    metaList[this.fieldName + "," + this.entityName].isDisabled;
                isDisabled =
                    fieldDisability != null && fieldDisability != undefined
                        ? isDisabled || fieldDisability
                        : isDisabled;
            }
        } catch (error) {
            console.error("Error in sspBaseComponentInputCheckbox.isDisabled", error);
        }

        return isDisabled;
    }

    get errorMsg () {
        return this.ErrorMessageList.length > 0;
    }

    /*
     * @function : handleValidations
     * @description : This method is used to handle the date validations.
     * @param {event}
     */
    handleValidations = event => {
        try {
            let msg;
            this.value = event.target.value;
            const valueReceived = this.value;
            const errorMessageList = JSON.parse(
                JSON.stringify(this.ErrorMessageList || [])
            );
            let fetchedList;
            const inputVal = event.target.value;
            if (
                this.metaListValues !== undefined &&
                this.fieldName !== undefined &&
                this.entityName !== undefined
            ) {
                fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];
            }
            /*Added by kyathi as a part of defect*/
            if (this.caseApplicationField) {
                msg = sspCaseApplicationMessage;
                this.handleCaseApplicationValidation(
                    inputVal,
                    valueReceived,
                    this.ErrorMessageList,
                    msg
                );
            }

            if (fetchedList !== null && fetchedList !== undefined) {
                if (fetchedList.Input_Required__c) {
                    msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.Input_Numeric__c) {
                    msg = fetchedList.Input_Numeric_Msg__c;
                    this.numericValidator(inputVal, valueReceived, errorMessageList, msg);
                }
                if (fetchedList.Validate_AreaCode__c) {
                    msg = fetchedList.Validate_AreaCode_Msg__c;
                    this.phoneNumberAreaCodeValidator(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.Validate_Phone_Pattern__c) {
                    msg = fetchedList.Validate_Phone_Pattern_Msg__c;
                    this.phoneValidator(inputVal, valueReceived, errorMessageList, msg);
                }
                if (fetchedList.Specify_Pattern__c) {
                    msg = fetchedList.Specify_Pattern_Msg__c;
                    this.validatePhonePattern(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MaxLength__c]) {
                    msg = fetchedList[fetchedListData.Validate_MaxLength_Msg__c];
                    this.maxLength = 10;
                    this.validateMaxLength(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MinLength__c]) {
                    msg = fetchedList[fetchedListData.Validate_MinLength_Msg__c];
                    this.minLength = 5;
                    this.validateMinLength(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
            }
            if (this.handleChange) {
                const selectedEvent = new CustomEvent(events.handleChange, {
                    detail: this.value
                });
                this.dispatchEvent(selectedEvent);
            }
            if (this.ErrorMessageList.length) {
                event.target.classList.add("ssp-input-error");
            } else {
                event.target.classList.remove("ssp-input-error");
            }
        } catch (e) {
            console.error("Error in handleValidations", e);
        }
    };

    /*
     * @function : maskPhoneNumber
     * @description : This method is used to mask the phone number to the respective pattern.
     * @param {event}
     */
    maskPhoneNumber = (event) => {
        try {
            if (event.keyCode === 8) {
                return;
            }
            event.target.value = !this.caseApplicationField
                ? event.target.value
                    .replace(/^(\d{3})-(\d{3})$/, "$1-$2-")
                    .replace(/^(\d{3})$/, "$1-")
                : event.target.value;
        } catch (error) {
            console.error("Error masking phone number: ", error);
        }
    };

    /**
     * @function : restrictNonNumeric
     * @description : This method is used to non numeric values.
     * @param {*} event - Gives the typed data.
     */
    restrictNonNumeric (event) {
        try {
            if (event.keyCode < 48 || event.keyCode > 57) {
                event.preventDefault();
            }
        } catch (error) {
            console.error("Error in restrictNonNumeric: ", error);
        }
    }
    /*
     * @function : ErrorMessages
     * @description : This method is used to check for the error message list.
     */
    @api
    ErrorMessages () {
        try {
            let msg;
            const valueReceived = this.value;
            const inputVal = valueReceived;
            const errorMessageList = JSON.parse(
                JSON.stringify(this.ErrorMessageList || [])
            );
            const fetchedList = this.metaListValues[
                this.fieldName + "," + this.entityName
            ];

            if (fetchedList !== null && fetchedList !== "undefined") {
                if (fetchedList.Input_Required__c) {
                    msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.Input_Numeric__c) {
                    msg = fetchedList.Input_Numeric_Msg__c;
                    this.numericValidator(inputVal, valueReceived, errorMessageList, msg);
                }
                if (fetchedList.Validate_AreaCode__c) {
                    msg = fetchedList.Validate_AreaCode_Msg__c;
                    this.phoneNumberAreaCodeValidator(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.Validate_Phone_Pattern__c) {
                    msg = fetchedList.Validate_Phone_Pattern_Msg__c;
                    this.phoneValidator(inputVal, valueReceived, errorMessageList, msg);
                }
                if (fetchedList.Specify_Pattern__c) {
                    msg = fetchedList.Specify_Pattern_Msg__c;
                    this.validatePhonePattern(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MaxLength__c]) {
                    msg = fetchedList[fetchedListData.Validate_MaxLength_Msg__c];
                    this.validateMaxLength(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MinLength__c]) {
                    msg = fetchedList[fetchedListData.Validate_MinLength_Msg__c];
                    this.validateMinLength(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
            }
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.add("ssp-input-error");
            }
            return this.ErrorMessageList;
        } catch (error) {
            console.error("Error in ErrorMessages", error);
            return null;
        }
    }

    /*
     * @function : getMetadataRecord
     * @description : This method is used to check for the required property.
     */
    getMetadataRecord = () => {
        try {
            const metadataList = this.metaListValues;
            if (
                (this.fieldName !== undefined && this.entityNam !== undefined) ||
                this.metadataList
            ) {
                if (
                    metadataList[this.fieldName + "," + this.entityName].Input_Required__c
                ) {
                    this.required = true;
                }
            }
        } catch (error) {
            console.error("Error in getMetadataRecord", error);
        }
    };

    /*
     * @function : numericValidator
     * @description : This method is used to check if the value entered is numeric or not.
     * @param    {inputTextParam, valueReceived, errorMessageList, msg}
     */
    numericValidator = (inputTextParam, valueReceived, errorMessageList, msg) => {
        try {
            const inputText = inputTextParam != null ? inputTextParam : valueReceived;

            const regexExpr = new RegExp(
                "^-?(?:\\d+|\\d{1,3}(?:,\\d{3})+)(?:.\\d+)?$"
            );
            const regexResult = regexExpr.test(inputText);
            if (regexResult.toString() === "false" && !(this.inputText === "")) {
                this.hasError = true;
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
            console.error("Error in numericValidator", error);
        }
    };

    /*
     * @function : phoneNumberAreaCodeValidator
     * @description : This method is used to validate the area code.
     * @param    {inputTextParam, valueReceived, errorMessageList, msg}
     */
    phoneNumberAreaCodeValidator = (
        inputTextParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputText = inputTextParam != null ? inputTextParam : valueReceived;

            const regexExpr = new RegExp("^(?!0+)\\d{1,6}$");
            const regexResult = regexExpr.test(inputText);
            if (regexResult.toString() === "false" && !(this.inputText === "")) {
                this.hasError = true;
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
            console.error("Error in phoneNumberAreaCodeValidator", error);
        }
    };

    /*
     * @function : phoneValidator
     * @description : This method is used to validate the phone number.
     * @param    {inputTextParam, valueReceived, errorMessageList, msg}
     */
    phoneValidator = (inputTextParam, valueReceived, errorMessageList, msg) => {
        try {
            const patternRegEx = /^(?!((\+1-)?((\(?)222(\)?)(\s?)(-?)222(-?)2222|(\(?)333(\)?)(\s?)(-?)333(-?)3333|(\(?)444(\)?)(\s?)(-?)444(-?)4444|(\(?)555(\)?)(\s?)(-?)555(-?)5555|(\(?)666(\)?)(\s?)(-?)666(-?)6666|(\(?)777(\)?)(\s?)(-?)777(-?)7777|(\(?)888(\)?)(\s?)(-?)888(-?)8888|(\(?)999(\)?)(\s?)(-?)999(-?)9999)))(((\+1-)?(\(?)[2-9]\d{2}(\)?)(\s?))(-?)(([2-9][02-9][0-9])|([2-9][1][02-9]))(-?)(\d{4}))$/gm;
            const inputText = inputTextParam != null ? inputTextParam : valueReceived;
            const regexExpr = new RegExp("^\\d{3}-\\d{3}-\\d{4}$");
            const regexResult = regexExpr.test(inputText);
            const patternValid = patternRegEx.test(inputText);
            if (
                (regexResult.toString() === "false" ||
                    patternValid.toString() === "false") &&
                inputText
            ) {
                this.hasError = true;
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
            console.error("Error in phoneValidator", error);
        }
    };

    /*
     * @function : validatePhonePattern
     * @description : This method is used to validate the pattern phone number.
     * @param    {inputTextParam, valueReceived, errorMessageList, msg}
     */
    validatePhonePattern = (
        inputTextParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputText = inputTextParam != null ? inputTextParam : valueReceived;
            const receivedPattern = this.pattern;
            const regexExpr = new RegExp(receivedPattern);
            const regexResult = regexExpr.test(inputText);
            if (regexResult.toString() === "false" && !(inputText === "")) {
                this.hasError = true;
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
            console.error("Error in validatePhonePattern", error);
        }
    };

    /*
     * @function : handleRequiredValidation
     * @description : This method is used to handle the required validation.
     * @param    {inputText, valueReceived, errorMessageList, msg}
     */
    handleRequiredValidation = (
        inputText,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            this.required = true;
            if (
                this.required &&
                (this.inputText === "" ||
                    this.inputText === undefined ||
                    this.inputText === null) &&
                (valueReceived === "" ||
                    valueReceived === undefined ||
                    valueReceived === null)
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
            console.error("Error in handleRequiredValidation", error);
        }
    };

    /*
     * @function : validateMaxLength
     * @description : This method is used to handle the max length validation.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateMaxLength = (inputValParam, valueReceived, errorMessageList, msg) => {
        try {
            const inputVal = inputValParam != null ? inputValParam : valueReceived;

            const inputValLength = inputVal.length;

            if (inputValLength != null && this.maxLength != null) {
                if (inputValLength > this.maxLength) {
                    this.hasError = true;
                    if (errorMessageList.indexOf(msg) === -1) {
                        errorMessageList.push(msg);
                    }
                } else {
                    if (errorMessageList.indexOf(msg) > -1) {
                        errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                    }
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (error) {
            console.error("Error in validateMaxLength", error);
        }
    };

    /*
     * @function : validateMinLength
     * @description : This method is used to handle the max length validation.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateMinLength = (inputValParam, valueReceived, errorMessageList, msg) => {
        try {
            const inputVal = inputValParam != null ? inputValParam : valueReceived;
            const minLength = this.minLength;
            const inputValLength = inputVal.length;

            if (inputValLength !== null && minLength !== null) {
                if (inputValLength < minLength) {
                    this.hasError = true;
                    if (errorMessageList.indexOf(msg) === -1) {
                        errorMessageList.push(msg);
                    }
                } else {
                    if (errorMessageList.indexOf(msg) > -1) {
                        errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                    }
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (error) {
            console.error("Error in validateMinLength", error);
        }
    };
    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */

    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);

        //Added by nikhil as part of  CD2 Development
        if (this.hasRendered) {
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.add("ssp-input-error");
            } else {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.remove("ssp-input-error");
            }
        }
        this.hasRendered = true;
    }

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
    /*
	 * @function : handleCaseApplicationValidation
	 * @description : This method is used to check if the case or application number is 10 digit.
	 * @param    {inputVal, valueReceived, errorMessageList, msg}
	 */
    handleCaseApplicationValidation = (
        inputVal,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const errorMessageLists = [].concat(errorMessageList);
            const inputValue =
                inputVal != null
                    ? inputVal
                    : valueReceived != null
                        ? valueReceived
                        : "";

            if (inputValue != null) {
                const checkForNumber = /^[0-9]+$/;
                if (inputValue.length !== 9 && inputValue.match(checkForNumber)) {
                    this.hasError = true;
                    if (errorMessageLists.indexOf(msg) === -1) {
                        errorMessageLists.push(msg);
                    }
                } else {
                    if (errorMessageLists.indexOf(msg) > -1) {
                        errorMessageLists.splice(errorMessageLists.indexOf(msg), 1);
                    }
                }
            }
            this.ErrorMessageList = errorMessageLists;
        } catch (error) {
            console.error("Error in handleCaseApplicationValidation", error);
        }
    };
}