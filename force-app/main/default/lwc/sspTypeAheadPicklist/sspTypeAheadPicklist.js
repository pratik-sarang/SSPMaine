import { LightningElement, api, track } from "lwc";
import apConstants from "c/sspConstants";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import sspRequiredValidationMsg from "@salesforce/label/c.SSP_RequiredErrorMessage";
export default class SspTypeAheadPicklist extends LightningElement {
    @api label = "Test";
    @api handleChange = false;
    @api className;
    @api title = "";
    @api disabled;
    @api placeholder;
    @api displayValues = [];
    @api keyword;
    @api displaySelectedValue;
    @api fieldName;
    @api entityName;
    @api doYouWantOnChangeEmptyValue = false;
    @api ErrorMessageList = [];
    @track metaListValues;
    @track _showOverlay = false;
    @api isHelpText = false;
    @api helpTextContent = "";
    @api isGenericUpload = false;
    @api hasTruncatedLabels = false;
    @track displayValue;
    @track isTabPressed=false;
    shouldDropdownClose = false;
    hasRendered = false;
    // Start - RAC POC Code
    @api oldValue = "";
    // End - RAC POC Code

    @api
    get listValues () {
        return this._listValues || [];
    }
    set listValues (value) {
        if (Array.isArray(value)) {
            this._listValues = value;
        }
        this.setDisplayValue(this._value);
    }

    @api
    get metaList () {
        return this.metaListValues;
    }
    set metaList (value) {
        if (value) {
            this.metaListValues = value;
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
            console.error("Error in sspTypeAheadPicklist.isDisabled", error);
        }

        return isDisabled;
    }

    @api
    get value () {
        return this.displayValue;
    }
    set value (_value) {
        this.ErrorMessageList = [];
        this.setDisplayValue(_value);
    }

    handleKeyDown = (event) =>{
        if (event.keyCode === 9){
            this.isTabPressed = true;
        }
        if (event.keyCode === 40 && event.target.nextSibling && event.target.nextSibling.children && event.target.nextSibling.children[0]) {
            this.isTabPressed = true;
            event.target.nextSibling.children[0].focus();
        }
    }

    handleBlur = () => {
        if(this.shouldDropdownClose){
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
              this.showOverlay = false;
              this.template
                .querySelector(".ssp-lookup-option-container")
                .classList.remove("ssp-show");
              this.template
                .querySelector(".ssp-addClass")
                .classList.remove("ssp-look-up-container");
            }, 500);
        }
        this.shouldDropdownClose = true;
    }

    searchValues (event) {
        this.displayValue = event.target.value;
        this.displaySelectedValue = "";
        const keyword = event.target.value;
       /* if (keyword) {
            this.checkValues(keyword);
            this._showOverlay = true;
        } else {
            this.displayValues = [];
            this._showOverlay = false;
        }*/
        this.checkValues(keyword);
        this._showOverlay = true;
        this.handleValidations(event);
        const changeEvent = new CustomEvent(
            apConstants.events.changeTypeAheadPicklistValue,
            {
                detail: {
                    selectedValue: keyword
                }
            }
        );
        this.dispatchEvent(changeEvent);

        //Start - To Identify TypeAhead picklist got Empty
        if (this.doYouWantOnChangeEmptyValue && event.target.value === "") {
            const displayEvent = new CustomEvent(
                apConstants.events.selectedVal,
                {
                    detail: {
                        selectedValue: this.displaySelectedValue,
                        selectedDisplayValue: event.currentTarget.dataset.label
                    }
                }
            );
            this.dispatchEvent(displayEvent);
        }
        //End - To Identify TypeAhead picklist got Empty
    }

    checkValues (keyword) {
        const errorMessageList = [];
        const listToSearch = this.listValues;
        const displayList = [];
        if (this.hasTruncatedLabels) {
            listToSearch.forEach(function (item) {
                const itemLabel = item.label;
                const itemVal = item.value;
                const itemTitle = item.title ? item.title : "";
                if (itemTitle.toLowerCase().includes(keyword.toLowerCase())) {
                    displayList.push({
                        label: itemLabel,
                        value: itemVal,
                        title: itemTitle
                    });
                }
            });
        }
        else {
            listToSearch.forEach(function (item) {
                const itemLabel = item.label;
                const itemVal = item.value;
                const itemTitle = item.title ? item.title : "";
                if (itemLabel.toLowerCase().includes(keyword.toLowerCase())) {
                    displayList.push({
                        label: itemLabel,
                        value: itemVal,
                        title: itemTitle
                    });
                }
            });
        }
        this.displayValues = displayList;
        this.template
            .querySelector(".ssp-addClass")
            .classList.add("ssp-look-up-container");
        this.template
            .querySelector(".ssp-lookup-option-container")
            .classList.add("ssp-show");
        if (displayList.length == 0) {
            errorMessageList.push(sspNoResultsFound);
        }
        this.ErrorMessageList = errorMessageList.filter(
            (a, b) => errorMessageList.indexOf(a) === b
        );
    }

    handleInputFocusOrBlur (event) {
        this.handleValidations(event);
        if (!this.isTabPressed){
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showOverlay = false;
            this.template
                .querySelector(".ssp-lookup-option-container")
                .classList.remove("ssp-show");
            this.template
                .querySelector(".ssp-addClass")
                .classList.remove("ssp-look-up-container");
        }, 500);
        }
        this.isTabPressed=false;
        this.shouldDropdownClose = true;
    }

    get showOverlay () {
        return !!this._showOverlay;
    }

    set showOverlay (value) {
        this._showOverlay = !!value;
    }

    selectedValue (event) {
        try {
            if (event.keyCode === 13 || event.type == "click") {
                this.shouldDropdownClose = false;
                this.displaySelectedValue = event.currentTarget.dataset.id;
                    this.displayValue = event.currentTarget.dataset.label;
                this._value = event.currentTarget.dataset.id;
                this.displayValues = [];
                const displayEvent = new CustomEvent(
                    apConstants.events.selectedVal,
                    {
                        detail: {
                            selectedValue: this.displaySelectedValue,
                            selectedDisplayValue:
                                event.currentTarget.dataset.label
                        }
                    }
                );
                this.template
                    .querySelector(".ssp-lookup-option-container")
                    .classList.remove("ssp-show");
                this.template
                    .querySelector(".ssp-addClass")
                    .classList.remove("ssp-look-up-container");
                this.ErrorMessageList = [];
                this.dispatchEvent(displayEvent);                
            } else if (event.keyCode === 40) {
                this.shouldDropdownClose = false;
                event.target.nextSibling.focus();
            } else if (event.keyCode === 38) {
                this.shouldDropdownClose = false;
                event.target.previousSibling.focus();
            } else if (event.keyCode === 9) {
                this.shouldDropdownClose = false;
            } 
        } catch (e) {
            console.error("error in selection", e);
        }
    }

    handleValidations (event) {
        let inputVal;
        try {
            if (event) {
                this._value = event.target.value;
                inputVal = event.target.value;
            } else {
                inputVal = this._value;
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
                        this.handleRequiredValidation(inputVal, errorMessageList, msg);
                    }
                }
            }
            if (this.isGenericUpload) {
                this.handleRequiredValidation(
                    inputVal,
                    errorMessageList,
                    sspRequiredValidationMsg
                );
            }
            if (this.handleChange) {
                const selectedEvent = new CustomEvent(apConstants.handleChange, {
                    detail: this._value
                });
                this.dispatchEvent(selectedEvent);
            }
            if (this.ErrorMessageList.length) {
                event.target.classList.add("ssp-input-error");
            } else {
                event.target.classList.remove("ssp-input-error");
            }
        } catch (ex) {
            console.error("Exception Occurred " + JSON.stringify(ex));
        }
    }

    @api
    ErrorMessages () {
        this.handleValidations(event);
        const errorList = this.ErrorMessageList;
        if (this.ErrorMessageList.length) {
            this.template
                .querySelector(".ssp-typeAheadMainContainer lightning-input")
                .classList.add("ssp-input-error");
        } else {
            this.template
                .querySelector(".ssp-typeAheadMainContainer lightning-input")
                .classList.remove("ssp-input-error");
        }
        return errorList;
    }

    handleRequiredValidation (inputValue, errorMessageList, msg) {
        const requiredValue = true;
        const inputVal =
            inputValue !== undefined || inputValue !== "" ? inputValue : this._value;
        try {
            if (
                requiredValue &&
                (inputVal === "" || inputVal === undefined || inputVal === null)
            ) {
                if (errorMessageList.indexOf(msg) === -1) {
                    errorMessageList.push(msg);
                }
            } else if (
                requiredValue &&
                (this.displaySelectedValue === "" ||
                    this.displaySelectedValue === undefined ||
                    this.displaySelectedValue === null)
            ) {
                errorMessageList.push(sspNoResultsFound);
            } else {
                if (errorMessageList.indexOf(msg) > -1) {
                    errorMessageList.splice(errorMessageList.indexOf(msg), 1);
                }
            }
            this.ErrorMessageList = errorMessageList.filter(
                (a, b) => errorMessageList.indexOf(a) === b
            );
        } catch (ex) {
            console.error(ex);
        }
    }

    @api
    assignSelectedValues () {
        return this.displaySelectedValue;
    }

    setDisplayValue (value) {
        if (value === null || value === undefined) {
            this._value = value;
            this.displayValue = value;
        }
        const dataset = this.listValues || [];
        if (this.displaySelectedValue === undefined) {
            this.displaySelectedValue = dataset.find(currentElement => {
                if (currentElement.label === value || currentElement.value === value) {
                    return currentElement.value;
                }
            });
        }
        const [byValue] = dataset.filter(item => item.value === value);
        const [byLabel] = dataset.filter(item => item.label === value);
        if (byValue) {
            this._value = byValue.value;
            this.displayValue = byValue.label;
        } else if (byLabel) {
            this._value = byLabel.value;
            this.displayValue = byLabel.label;
        } else {
            this._value = value;
            this.displayValue = value;
        }
    }

    /*
     * @function : renderedCallback()
     * @description : This method is called when component gets rendered.
     */
    // Start - RAC POC Code
    renderedCallback () {
        this.oldValue = this.setOldValue(this.displayValue, this.oldValue);
        if (this.hasRendered) {
            if (this.ErrorMessageList.length) {
                this.template
                    .querySelector(".ssp-typeAheadMainContainer lightning-input")
                    .classList.add("ssp-input-error");
            } else {
                this.template
                    .querySelector(".ssp-typeAheadMainContainer lightning-input")
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
        let oldValueReference = oldValue;
        if (newValue !== undefined && oldValueReference === "") {
            oldValueReference = newValue;
        }
        else if(oldValueReference === ""){
            oldValueReference = "null";
        }
        return oldValueReference;
    };
    // End - RAC POC Code
}
