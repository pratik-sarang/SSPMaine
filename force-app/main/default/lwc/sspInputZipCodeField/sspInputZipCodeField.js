/*
 * Component name  : sspBaseComponentInputText
 * @description    : Generic component for Input text box.
 */
import { LightningElement, track, api } from "lwc";
import { fetchedListData, events } from "c/sspConstants";
import nameSsnNotMatch from "@salesforce/label/c.SSP_NameSsnNotMatch";
import sspSSNFourValidation from "@salesforce/label/c.SSP_SearchSSNFourValidationMessage";
import sspEnterValidZipCode from "@salesforce/label/c.SSP_EnterValidZipCode";

import sspUtility from "c/sspUtility";

export default class SspBaseComponentInputText extends LightningElement {
    @api recordId;
    @api label = "Name";
    @api entityName;
    @api fieldName;
    @api value = "";
    @api required;
    @api title = "";
    @api pattern = "";
    @api className = "";
    @api ErrorMessageList = [];
    @api maxLength;
    @api minLength;
    @api disabled;
    @api handleChange = false;
    @api placeholder;
    @api isHelpText = false;
    @api helpTextContent = "";
    @api inputType = "text";
    @api oldValue = "";
    @api matchValue;
    @api ssnFour = false;
    @api isAssisterOrAuth = false;
    @track hasError;
    @track ErrorMsgList = [];
    @track metaListValues;
    @api zipCodeInputField = false;
    @track pattern;
    hasRendered = false;
    
    labels={
        sspEnterValidZipCode
    }

    /*
     * @function : metaList
     * @description : This method is used to handle meta list values.
     * @param {value}
     */
    @api
    get metaList () {
        return this.metaListValues;
    }
    set metaList (value) {
        try {
            this.metaListValues = value;
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
            console.error(
                "Error in sspBaseComponentInputText.isDisabled",
                error
            );
        }

        return isDisabled;
    }
    /*
     * @function : handleValidations
     * @description : This method is used to handle the validations.
     * @param {event}
     */
    handleValidations = event => {
        try {
            let inputValue = event.target.value;
            const lastChar = inputValue.slice(-1);
            if (lastChar===" " || isNaN(lastChar)) {
                inputValue = inputValue.slice(0, -1);
                event.target.value = inputValue;
            }
            this.value = event.target.value;
            const valueReceived = this.value;
            const inputVal = event.target.value;
            this.ErrorMessageList =
                this.ErrorMessageList.length === 0 ? [] : this.ErrorMessageList;
            let fetchedList;
            if (
                this.metaListValues !== undefined &&
                this.fieldName !== undefined &&
                this.entityName !== undefined
            ) {
                fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];
            }

            if (this.ssnFour) {
                const msg = sspSSNFourValidation;
                this.handleSSNFourValidation(
                    inputVal,
                    valueReceived,
                    this.ErrorMessageList,
                    msg
                );
            }

            if (fetchedList !== null && fetchedList !== undefined) {
                if (fetchedList.IllegalCharactersValidator__c) {
                    const msg = fetchedList.IllegalCharactersValidator_Msg__c;
                    this.ValidateIllegalCharacters(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.Input_Required__c && !this.isAssisterOrAuth) {
                    const msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                } else {
                    this.removeMsgFromErrorMessageList(
                        fetchedList.Input_Required_Msg__c
                    );
                }
                if (fetchedList.Specify_Pattern__c) {
                    const msg = fetchedList.Specify_Pattern_Msg__c;
                    this.validatePattern(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }

                if (fetchedList.Validate_AlphaNumeric__c) {
                    const msg = fetchedList.Validate_AlphaNumeric_Msg__c;
                    this.validateAlphaNumeric(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MaxLength__c]) {
                    let msg =
                        fetchedList[fetchedListData.Validate_MaxLength_Msg__c];
                    msg = msg.replace("{x}", this.maxLength);
                    this.validateMaxLength(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MinLength__c]) {
                    const msg =
                        fetchedList[fetchedListData.Validate_MinLength_Msg__c];
                    this.validateMinLength(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.Allow_Numeric__c) {
                    const msg = fetchedList.Allow_Numeric_Msg__c;
                    this.allowOnlyNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.I94Validator__c) {
                    const msg = fetchedList.I94Validator_Msg__c;
                    this.validateI94Number(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.NoZeroSpecialCharValidator__c) {
                    const msg = fetchedList.NoZeroSpecialCharValidator_Msg__c;
                    this.validateAllZeroSpecialCharacter(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.ImmigrationNumberValidator__c) {
                    const msg = fetchedList.ImmigrationNumberValidator_Msg__c;
                    this.validateImmigrationNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.PassportNumberValidator__c) {
                    const msg = fetchedList.PassportNumberValidator_Msg__c;
                    this.validatePassportNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.SignatureMatchValidator__c) {
                    const msg = fetchedList.SignatureMatchValidator_Msg__c;
                    this.validateSignatureMatch(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.SSNValidator__c) {
                    const msg = fetchedList.SSNValidator_Msg__c;
                    this.handleSSNValidation(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
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
            if (event.type === "blur") {
                const selectedEvent = new CustomEvent(events.handleBlur, {
                    detail: this.value
                });
                this.dispatchEvent(selectedEvent);
            }
            if (this.ErrorMessageList.length) {
                event.target.classList.add("ssp-input-error");
            } else {
                event.target.classList.remove("ssp-input-error");
            }
        } catch (error) {
            console.error("Error in handleValidations", error);
        }
    };

    /*
     * @function : ErrorMessages
     * @description : This method is used to check for the error message list.
     */
    @api
    ErrorMessages () {
        try {
            const valueReceived = this.value;
            const inputVal = valueReceived;
            this.ErrorMessageList =
                this.ErrorMessageList.length === 0 ? [] : this.ErrorMessageList;
            const fetchedList =
                this.metaListValues !== null &&
                this.metaListValues !== undefined
                    ? this.metaListValues[
                          this.fieldName + "," + this.entityName
                      ]
                    : null;

            if (fetchedList !== null && fetchedList !== undefined) {
                if (fetchedList.IllegalCharactersValidator__c) {
                    const msg = fetchedList.IllegalCharactersValidator_Msg__c;
                    this.ValidateIllegalCharacters(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.Validate_AlphaNumeric__c) {
                    const msg = fetchedList.Validate_AlphaNumeric_Msg__c;
                    this.validateAlphaNumeric(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.SSNValidator__c) {
                    const msg = fetchedList.SSNValidator_Msg__c;
                    this.handleSSNValidation(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.Input_Required__c && !this.isAssisterOrAuth) {
                    const msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                } else {
                    this.removeMsgFromErrorMessageList(
                        fetchedList.Input_Required_Msg__c
                    );
                }
                if (fetchedList.Specify_Pattern__c) {
                    const msg = fetchedList.Specify_Pattern_Msg__c;
                    this.validatePattern(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MaxLength__c]) {
                    let msg =
                        fetchedList[fetchedListData.Validate_MaxLength_Msg__c];
                    msg = msg.replace("{x}", this.maxLength);
                    this.validateMaxLength(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList[fetchedListData.Validate_MinLength__c]) {
                    const msg =
                        fetchedList[fetchedListData.Validate_MinLength_Msg__c];
                    this.validateMinLength(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.I94Validator__c) {
                    const msg = fetchedList.I94Validator_Msg__c;
                    this.validateI94Number(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.NoZeroSpecialCharValidator__c) {
                    const msg = fetchedList.NoZeroSpecialCharValidator_Msg__c;
                    this.validateAllZeroSpecialCharacter(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.ImmigrationNumberValidator__c) {
                    const msg = fetchedList.ImmigrationNumberValidator_Msg__c;
                    this.validateImmigrationNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.PassportNumberValidator__c) {
                    const msg = fetchedList.PassportNumberValidator_Msg__c;
                    this.validatePassportNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
                if (fetchedList.Allow_Numeric__c) {
                    const msg = fetchedList.Allow_Numeric_Msg__c;
                    this.allowOnlyNumber(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }

                if (fetchedList.SignatureMatchValidator__c) {
                    const msg = fetchedList.SignatureMatchValidator_Msg__c;
                    this.validateSignatureMatch(
                        inputVal,
                        valueReceived,
                        this.ErrorMessageList,
                        msg
                    );
                }
            }

            const errorList = this.ErrorMessageList;
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-genericInput lightning-input")
                    .classList.add("ssp-input-error");
            }
            return errorList;
        } catch (error) {
            console.error("Error in ErrorMessages", error);
            return null;
        }
    }

    /*
     * @function : ValidateIllegalCharacters
     * @description : This method is used to check if the value entered is not carrying illegal characters.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    ValidateIllegalCharacters = (
        inputVal,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const regexExpr = new RegExp(
                "^(?!.*\\s{2})([a-zA-Z]+(([,.'-])?( )?[a-zA-Z]*)*)$"
            );
            const regexResult = regexExpr.test(inputVal);
            if (regexResult.toString() === "false" && !(inputVal === "")) {
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
            console.error("Error in ValidateIllegalCharacters", error);
        }
    };

    /*
     * @function : validateAlphaNumeric
     * @description : This method is used to check if the value entered contains only letters and numbers.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    validateAlphaNumeric = (inputVal, valueReceived, errorMessageList, msg) => {
        try {
            const regexExpr = new RegExp("^[a-zA-Z0-9]*$");
            const regexResult = regexExpr.test(inputVal);
            if (regexResult.toString() === "false" && !(inputVal === "")) {
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
            console.error("Error in ValidateIllegalCharacters", error);
        }
    };

    /*
     * @function : handleSSNValidation
     * @description : This method is used to validate the ssn.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    handleSSNValidation = (inputVal, valueReceived, errorMessageList, msg) => {
        try {
            let currentErrorList = [];
            if (errorMessageList !== null && errorMessageList !== undefined) {
                currentErrorList = Array.from(errorMessageList);
            }
            const regexExpr = new RegExp(
                // "^(?!(000|666|111-11-1111|222-22-2222|333-33-3333|444-44-4444|555-55-5555|666-66-666|777-77-7777|888-88-8888))([0-8]\\d{2})(-?)(?!00)\\d{2}(-?)(?!0000)\\d{4}$"
                "^(?!(000000000|9))([0-9]){9}$"
            );
            const regexResult = regexExpr.test(inputVal);
            if (
                inputVal !== null &&
                inputVal !== undefined &&
                inputVal !== "" &&
                regexResult.toString() === "false"
            ) {
                this.hasError = true;
                if (currentErrorList.indexOf(msg) === -1) {
                    currentErrorList.push(msg);
                }
            } else {
                if (currentErrorList.indexOf(msg) > -1) {
                    currentErrorList.splice(currentErrorList.indexOf(msg), 1);
                }
            }
            this.ErrorMessageList = currentErrorList;
        } catch (error) {
            console.error("Error in handleSSNValidation", error);
        }
    };

    /*
     * @function : handleSSNFourValidation
     * @description : This method is used to validate the ssn.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    handleSSNFourValidation = (
        inputVal,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const regexExpr = new RegExp("^(?!(0000|4))([0-9]){4}$");
            const inputValue =
                inputVal != null
                    ? inputVal
                    : valueReceived != null
                    ? valueReceived
                    : "";
            if (
                inputValue !== null &&
                inputValue !== "" &&
                !inputValue.match(regexExpr)
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
            console.error("Error in handleSSNFourValidation", error);
        }
    };

    /*
     * @function : handleRequiredValidation
     * @description : This method is used to handle the required validation.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    handleRequiredValidation = (
        inputVal,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const requiredValue = true;
            let currentErrorList = [];
            if (errorMessageList !== null && errorMessageList !== undefined) {
                currentErrorList = Array.from(errorMessageList);
            }
            const inputValue =
                inputVal != null
                    ? inputVal
                    : valueReceived != null
                    ? valueReceived
                    : "";

            if (
                requiredValue &&
                (inputValue === "" ||
                    inputValue === undefined ||
                    inputValue === null)
            ) {
                if (currentErrorList.indexOf(msg) === -1) {
                    currentErrorList.push(msg);
                }
            } else {
                if (errorMessageList.indexOf(msg) > -1) {
                    currentErrorList.splice(currentErrorList.indexOf(msg), 1);
                }
            }
            if (inputValue && currentErrorList.includes(nameSsnNotMatch)) {
                currentErrorList = currentErrorList.filter(
                    item => item !== nameSsnNotMatch
                );
            }
            this.ErrorMessageList = currentErrorList;
        } catch (error) {
            console.error("Error in handleRequiredValidation", error);
        }
    };

    /*
     * @function : validatePattern
     * @description : This method is used to validate the pattern of text entered.
     * @param : {inputText, valueReceived, errorMessageList, msg}
     */
    validatePattern = (inputText, valueReceived, errorMessageList, msg) => {
        try {
            if (!(msg && this.pattern)) {
                return;
            }
            const messageIndex = errorMessageList.indexOf(msg);
            const value = inputText && inputText.trim();
            if (value === undefined || value === "") {
                if (messageIndex > -1) {
                    errorMessageList.splice(messageIndex, 1);
                }
                this.ErrorMessageList = errorMessageList;
                return;
            }

            const regexExpr = new RegExp(this.pattern);
            if (!regexExpr.test(value)) {
                this.hasError = true;
                if (messageIndex === -1) {
                    errorMessageList.push(msg);
                }
            } else {
                if (messageIndex > -1) {
                    errorMessageList.splice(messageIndex, 1);
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (error) {
            console.error("Error in validatePattern", error);
        }
    };

    /*
     * @function : validateMaxLength
     * @description : This method is used to handle the max length validation.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateMaxLength = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputVal =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const maxLength = this.maxLength;
            const inputValLength = inputVal.length;

            if (inputValLength != null && maxLength != null) {
                if (inputValLength > maxLength) {
                    this.hasError = true;
                    if (errorMessageList.indexOf(msg) === -1) {
                        errorMessageList.push(msg);
                    }
                } else {
                    if (errorMessageList.indexOf(msg) > -1) {
                        errorMessageList.splice(
                            errorMessageList.indexOf(msg),
                            1
                        );
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
    validateMinLength = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputVal =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const minLength = this.minLength;
            const inputValLength = inputVal.length;

            if (inputValLength != null && minLength != null) {
                if (inputValLength < minLength) {
                    this.hasError = true;
                    if (errorMessageList.indexOf(msg) === -1) {
                        errorMessageList.push(msg);
                    }
                } else {
                    if (errorMessageList.indexOf(msg) > -1) {
                        errorMessageList.splice(
                            errorMessageList.indexOf(msg),
                            1
                        );
                    }
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (error) {
            console.error("Error in validateMinLength", error);
        }
    };

    /*
     * @function : validateSignatureMatch
     * @description : This method is used to handle the signature match validation.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateSignatureMatch = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const errorList = [...errorMessageList];
            const inputVal =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const matchValue =
                this.matchValue !== null && this.matchValue !== undefined
                    ? this.matchValue
                    : "";

            if (
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
            if (
                (sspUtility.isUndefinedOrNull(inputVal) ||
                    sspUtility.isEmpty(inputVal)) &&
                !sspUtility.isUndefinedOrNull(matchValue) &&
                !sspUtility.isEmpty(matchValue)
            ) {
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
     * @function : allowOnlyNumber
     * @description : This method is used to validate only numbers are entered.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    allowOnlyNumber = (inputValParam, valueReceived, errorMessageList, msg) => {
        try {
            const inputVal =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const regexExpr = new RegExp("^[0-9]*$");
            const regexResult = regexExpr.test(inputVal);
            if (
                regexResult.toString() === "false" &&
                !(inputVal === "") &&
                inputVal !== undefined &&
                inputVal !== null
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
            console.error("Error in allowOnlyNumber", error);
        }
    };

    /*
     * @function : validateI94Number
     * @description : This method is used to validate I94 number.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateI94Number = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const numberToValidate =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const tenthPlaceLetterPattern = /^[0-9]{9}[a-zA-Z]{1}[0-9]{1}$/;
            const allZeroPattern = /^[0]*$/;
            const noSpecialCharacter = /^[A-Za-z0-9]+$/;
            const maxLengthValue = this.maxLength;
            let inputValid = true;
            if (numberToValidate) {
                inputValid =
                    noSpecialCharacter.test(numberToValidate) &&
                    !allZeroPattern.test(numberToValidate);
                if (inputValid && numberToValidate.length <= maxLengthValue) {
                    inputValid = tenthPlaceLetterPattern.test(numberToValidate);
                }
                if (numberToValidate.length === maxLengthValue) {
                    const replaceCharPattern = /[a-zA-Z]/gi;
                    const replacedInput = numberToValidate.replace(
                        replaceCharPattern,
                        ""
                    );
                    inputValid =
                        noSpecialCharacter.test(replacedInput) &&
                        !allZeroPattern.test(replacedInput) &&
                        tenthPlaceLetterPattern.test(numberToValidate);
                }
            }
            if (!inputValid) {
                if (errorMessageList.indexOf(msg) === -1) {
                    errorMessageList.push(msg);
                }
            } else {
                if (errorMessageList.indexOf(msg) > -1) {
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
            this.ErrorMessageList = errorMessageList;
        } catch (Error) {
            console.error("Error in validateI94Number", Error);
        }
    };

    /*
     * @function : validateAllZeroSpecialCharacter
     * @description : This method is used to validate special character.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateAllZeroSpecialCharacter = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputToValidate =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const allZeroPattern = /^[0]*$/;
            const noSpecialCharacter = /^[A-Za-z0-9]+$/;
            let inputValid = true;
            if (inputToValidate) {
                inputValid = noSpecialCharacter.test(inputToValidate);
                if (inputValid) {
                    inputValid = !allZeroPattern.test(inputToValidate);
                }
            }
            if (!inputValid) {
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
            console.error("Error in validateAllZeroSpecialCharacter", error);
        }
    };

    /*
     * @function : validateImmigrationNumber
     * @description : This method is used to validate Immigration number.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validateImmigrationNumber = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputToValidate =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const pattern = /\b[a-zA-Z]{3}[0-9]{10}\b/;
            let isValid = true;
            if (inputToValidate) {
                isValid = pattern.test(inputToValidate);
            }
            if (!isValid) {
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
            console.error("Error in validateImmigrationNumber " + error);
        }
    };

    /*
     * @function : validatePassportNumber
     * @description : This method is used to validate passport number.
     * @param    {inputValParam, valueReceived, errorMessageList, msg}
     */
    validatePassportNumber = (
        inputValParam,
        valueReceived,
        errorMessageList,
        msg
    ) => {
        try {
            const inputToValidate =
                inputValParam !== null && inputValParam !== undefined
                    ? inputValParam
                    : valueReceived != null
                    ? valueReceived
                    : "";
            const allZeroPattern = /^[0]*$/;
            const noSpecialCharacter = /^[A-Za-z0-9]+$/;
            let inputValid = true;
            if (inputToValidate) {
                inputValid =
                    noSpecialCharacter.test(inputToValidate) &&
                    inputToValidate.length >= this.minLength &&
                    inputToValidate.length <= this.maxLength;
                if (inputValid) {
                    inputValid = !allZeroPattern.test(inputToValidate);
                }
            }
            if (!inputValid) {
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
            console.error("Error in validatePassportNumber", error);
        }
    };

    /*
     * @function - removeMsgFromErrorMessageList
     * @description - This method is used to remove the error message from ErrorMessageList if condition not satisfied.
     * @param {string} message - Contains the error message.
     */
    removeMsgFromErrorMessageList = message => {
        try {
            if (
                this.ErrorMessageList.length > 0 &&
                this.ErrorMessageList.indexOf(message) !== -1
            ) {
                //Exists Block
                this.ErrorMessageList.splice(
                    this.ErrorMessageList.indexOf(message),
                    1
                );
            }
        } catch (error) {
            console.error(
                "Error in removeMsgFromErrorMessageList method: ",
                error
            );
        }
    };

    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
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
            //  if(this.zipCodeInputField) {
            //   this.pattern="[0-9]+"
            //   }
            //   else {
            //     this.pattern="*";

            //   }
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
}
