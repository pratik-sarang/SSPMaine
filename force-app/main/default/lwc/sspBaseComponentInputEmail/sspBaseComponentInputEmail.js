/*
 * Component name  : sspBaseComponentInputEmail
 * @description    : Generic component for Input Email.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";

export default class baseComponentInputEmail extends LightningElement {
    @api recordId;
    @api label;
    @api entityName;
    @api fieldName;
    @api value;
    @api required = false;
    @api title = "";
    @api handleChange = false;
    @api disabled;
    @api placeholder;
    @api ErrorMessageList = [];
    @track pattern;
    @track metaListValues;
    @track hasError;
    @track ErrorMsgList = [];
    // Start - RAC POC Code
    @api oldValue = "";
    // End - RAC POC Code
    hasRendered=false;

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
            if (metaList != null && this.metaList != undefined &&
                this.fieldName != null && this.fieldName != undefined &&
                this.entityName != null && this.entityName != undefined &&
                metaList[this.fieldName + "," + this.entityName] != null && metaList[this.fieldName + "," + this.entityName] != undefined) {
                const fieldDisability = metaList[this.fieldName + "," + this.entityName].isDisabled;
                isDisabled = (fieldDisability != null && fieldDisability != undefined) ? (isDisabled || fieldDisability) : isDisabled;
            }
        } catch (error) {
            console.error("Error in sspBaseComponentInputEmail.isDisabled", error);
        }

        return isDisabled;
    }

    /*
     * @function : handleValidations
     * @description : This method is used to handle the date validations.
     * @param {event}
     */
    handleValidations = event => {
        try {
            const valueReceived = event.target.value;
            const errorMessageList = JSON.parse(
                JSON.stringify(this.ErrorMessageList)
            );
            this.value = event.target.value;
            const inputText = valueReceived;
            if (
                this.metaListValues !== null &&
                this.metaListValues !== undefined
            ) {
                const fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];

                if (fetchedList !== null && fetchedList.Input_Required__c) {
                    const msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList !== null && fetchedList.emailValidator__c) {
                    const msg = fetchedList.emailValidator_Msg__c;
                    this.emailValidator(
                        inputText,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList !== null && fetchedList.Specify_Pattern__c) {
                    const msg = fetchedList.Specify_Pattern_Msg__c;
                    this.PatternValidator(
                        inputText,
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
        } catch (error) {
            console.error("Error in handleValidations", error);
        }
    };

    /*
     * @function ErrorMessages
     * @description : This method is used to check for the error message list.
     */
    @api
    ErrorMessages () {
        try {
            let msg;
            const valueReceived = this.value;
            const inputVal = valueReceived;
            let fetchedList;
            const errorMessageList = JSON.parse(
                JSON.stringify(this.ErrorMessageList)
            );
            if (
                this.metaListValues !== undefined &&
                this.fieldName !== undefined &&
                this.entityName !== undefined
            ) {
                fetchedList = this.metaListValues[
                    this.fieldName + "," + this.entityName
                ];
            }
            if (fetchedList !== null && fetchedList !== undefined) {
                if (fetchedList.Input_Required__c) {
                    msg = fetchedList.Input_Required_Msg__c;
                    this.handleRequiredValidation(
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.emailValidator__c) {
                    msg = fetchedList.emailValidator_Msg__c;
                    this.emailValidator(
                        inputVal,
                        valueReceived,
                        errorMessageList,
                        msg
                    );
                }
                if (fetchedList.Specify_Pattern__c) {
                    msg = fetchedList.Specify_Pattern_Msg__c;
                    this.PatternValidator(
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
     * @function : emailValidator
     * @description : This method is used to handle the email validation.
     * @param    {inputTextParam, valueReceived, errorMessageList, msg}
     */
    emailValidator = (inputTextParam, valueReceived, errorMessageList, msg) => {
        try {
            const regexExpr = new RegExp("^($|[a-zA-Z0-9_\\.\\+-]+@[a-zA-Z0-9-]+\\.(com|org|net))$", "i");
            const regexResult = regexExpr.test(inputTextParam);
            const inputText =
                inputTextParam !== null &&
                inputTextParam !== undefined &&
                inputTextParam !== ""
                    ? inputTextParam
                    : valueReceived;

            if (
                regexResult.toString() === "false" &&
                inputText !== "" &&
                inputText !== null &&
                inputText !== undefined
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
            console.error("Error in emailValidator", error);
        }
    };

    /*
     * @function : handleRequiredValidation
     * @description : This method is used to handle the required validation.
     * @param    {valueReceived, errorMessageList, msg}
     */
    handleRequiredValidation = (valueReceived, errorMessageList, msg) => {
        try {
            this.required = true;
            if (
                this.required &&
                (valueReceived === "" ||
                    valueReceived === null ||
                    valueReceived === undefined)
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
     * @function : PatternValidator
     * @description : This method is used to handle the email patterns validation.
     * @param    {inputVal, valueReceived, errorMessageList, msg}
     */
    PatternValidator = (inputVal, valueReceived, errorMessageList, msg) => {
        try {
            const inputText = inputVal != null ? inputVal : valueReceived;
            const ReceivedPattern = this.pattern;

            const regexExpr = new RegExp(ReceivedPattern);
            const regexResult = regexExpr.test(inputText);

            if (
                regexResult.toString() === "false" &&
                (inputText !== "" || inputText !== null)
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
            console.error("Error in PatternValidator", error);
        }
    };

    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    // Start - RAC POC Code
    renderedCallback () {
        this.oldValue = this.setOldValue(this.value, this.oldValue);

        //Added by nikhil as part of  CD2 Development
      if (this.hasRendered) {
        if (this.ErrorMessageList.length) {
          this.template.querySelector(".ssp-genericInput lightning-input").classList.add("ssp-input-error");
        }
        else {
          this.template.querySelector(".ssp-genericInput lightning-input").classList.remove("ssp-input-error");
        }
      }
      this.hasRendered=true; 
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
    // End - RAC POC Code
}