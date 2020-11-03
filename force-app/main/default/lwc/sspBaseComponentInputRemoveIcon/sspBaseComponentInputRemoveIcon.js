import { LightningElement, track, api } from "lwc";
import { sspAssetFields } from "c/sspConstants";
export default class SspBaseComponentInputRemoveIcon extends LightningElement {
    @api recordId;
    @api label = "Name";
    @api handleChange = false;
    //Testing: Added Start
    @api entityName; //= 'IndividualDetails';
    @api fieldName; //= 'FirstName';
    //Testing: Added End
    @api value = "";
    @api required;
    @api title = "";
    @api pattern = "";
    @api className = "";
    @track hasError;
    @api ErrorMessageList = [];
    @api maxLength;
    @api minLength;
    @api disabled;
    @track ErrorMsgList = [];
    @track metaListValues;
    @api placeholder;
    @api showRemoveIcon = false;
    @api oldValue = "";

    get retExp () {
        return this.required ? "*" : "";
    }

    @api
    get metaList () {
        return this.metaListValues;
    }
    set metaList (value) {
        this.metaListValues = value;
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
            console.error("Error in SspBaseComponentInputRemoveIcon.isDisabled", error);
        }

        return isDisabled;
    }
    
    removeCurrentField (event) {
        const hideCard = this.template.querySelector(".ssp-genericInput");
        hideCard.classList.add("slds-hide");
        const actionObj = event.srcElement.dataId;
        const selectedEvent = new CustomEvent("remove", {
            detail: actionObj
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    //handleValidations() {
    handleValidations (event) {
        this.value = event.target.value;
        const valueReceived = this.value; //event.detail.value;
        const inputVal = event.target.value; //valueReceived;
        const errorMessageList = this.ErrorMessageList;
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

        if (fetchedList !== null && fetchedList !== "undefined") {
            if (fetchedList.IllegalCharactersValidator__c) {
                const msg = fetchedList.IllegalCharactersValidator_Msg__c;
                this.ValidateIllegalCharacters(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.SSNValidator__c) {
                const msg = fetchedList.SSNValidator_Msg__c;
                this.handleSSNValidation(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.Input_Required__c) {
                const msg = fetchedList.Input_Required_Msg__c;
                this.handleRequiredValidation(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.Specify_Pattern__c) {
                const msg = fetchedList.Specify_Pattern_Msg__c;
                // this.pattern = "^(my)";
                this.validatePattern(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList[sspAssetFields.validateMaxLength]) {
                const msg =
                    fetchedList[sspAssetFields.validateMaxLengthMessage];
                this.validateMaxLength(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList[sspAssetFields.validateMinLength]) {
                const msg =
                    fetchedList[sspAssetFields.validateMinLengthMessage];
                this.validateMinLength(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
        }
        if (this.handleChange) {
            const selectedEvent = new CustomEvent(sspAssetFields.handleChange, {
                detail: this.value
            });
            this.dispatchEvent(selectedEvent);
        }
        if (this.ErrorMessageList.length) {
            event.target.classList.add("ssp-input-error");
        } else {
            event.target.classList.remove("ssp-input-error");
        }
    }

    @api
    ErrorMessages () {
        const valueReceived = this.value;
        const inputVal = valueReceived;
        const errorMessageList = this.ErrorMessageList;
        const fetchedList =
            this.metaListValues !== null
                ? this.metaListValues[this.fieldName + "," + this.entityName]
                : null; //this.MetaList[0].metadataList[this.fieldName + ',' + this.entityName];

        if (fetchedList != null && fetchedList !== "undefined") {
            if (fetchedList.IllegalCharactersValidator__c) {
                const msg = fetchedList.IllegalCharactersValidator_Msg__c;
                this.ValidateIllegalCharacters(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.SSNValidator__c) {
                const msg = fetchedList.SSNValidator_Msg__c;
                this.handleSSNValidation(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.Input_Required__c) {
                const msg = fetchedList.Input_Required_Msg__c;
                this.handleRequiredValidation(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList.Specify_Pattern__c) {
                const msg = fetchedList.Specify_Pattern_Msg__c;
                this.validatePattern(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList[sspAssetFields.validateMaxLength]) {
                const msg =
                    fetchedList[sspAssetFields.validateMaxLengthMessage];
                this.validateMaxLength(
                    inputVal,
                    valueReceived,
                    errorMessageList,
                    msg
                );
            }
            if (fetchedList[sspAssetFields.validateMinLength]) {
                const msg =
                    fetchedList[sspAssetFields.validateMinLengthMessage];
                this.validateMinLength(
                    inputVal,
                    valueReceived,
                    errorMessageList,
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
    }

    @api
    ValidateIllegalCharacters (inputVal, valueReceived, errorMessageList, msg) {
        //var inputVal = inputVal != null ? inputVal : valueReceived;
        const regexExpr = new RegExp(
            "^(?!.*\\s{2})([a-zA-Z]+(([,.'-][a-zA-Z ])?( )?[a-zA-Z]*)*)$"
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
    }

    @api
    handleSSNValidation (inputVal, valueReceived, errorMessageList, msg) {
        //var inputVal = inputVal != null ? inputVal : valueReceived;
        const regexExpr = new RegExp(
            "^(?!(000|666|111-11-1111|222-22-2222|333-33-3333|444-44-4444|555-55-5555|666-66-666|777-77-7777|888-88-8888))([0-8]\\d{2})(-?)(?!00)\\d{2}(-?)(?!0000)\\d{4}$"
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
    }

    @api
    handleRequiredValidation (inputVal, valueReceived, errorMessageList, msg) {
        const requiredValue = true;

        const inputValue =
            inputVal != null
                ? inputVal
                : valueReceived != null
                ? valueReceived
                : "";

        if (requiredValue && (inputValue === "" || inputValue === undefined)) {
            if (errorMessageList.indexOf(msg) === -1) {
                errorMessageList.push(msg);
            }
        } else {
            if (errorMessageList.indexOf(msg) > -1) {
                errorMessageList.splice(errorMessageList.indexOf(msg), 1);
            }
        }
        this.ErrorMessageList = errorMessageList;
    }

    @api
    validatePattern (inputText, valueReceived, errorMessageList, msg) {
        //var inputText = inputText != null ? inputText : valueReceived;
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
    }

    @api
    validateMaxLength (inputValue, valueReceived, errorMessageList, msg) {
        const inputVal =
            inputValue !== null && inputValue !== undefined
                ? inputValue
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
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
        }
        this.ErrorMessageList = errorMessageList;
    }

    @api
    validateMinLength (inputValue, valueReceived, errorMessageList, msg) {
        const inputVal =
            inputValue !== null && inputValue !== undefined
                ? inputValue
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
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
        }
        this.ErrorMessageList = errorMessageList;
    }
    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);
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