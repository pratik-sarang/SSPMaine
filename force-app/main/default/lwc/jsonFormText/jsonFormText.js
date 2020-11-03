/*
 * Component Name: JsonFormText
 * Author: Narapa 
 * Description: Component to generate the field element of the type lightning-input
 * Date: 05/27/2020.
 */
import { JsonFormField } from "c/jsonFormField";
import { api } from "lwc";

export default class JsonFormText extends JsonFormField {
	
	connectedCallback () {
        this.parentConnectedCallback();
    }

    /**
     * @function : handleChange
     * @description : Method to generate an event when the option is chosen by the user.
 * This event will be handled in the jsonFlowContainer.
 * @param {event} event - JS event.
     */
    handleChange (event) {
        event.preventDefault();
        const dtl = new Object();
        dtl.name = event.target.name;
        dtl.value = event.target.value;
        const changeEvent = new CustomEvent("fieldchange", {
            detail: dtl,
            bubbles: true
        });
        this.dispatchEvent(changeEvent);
    }

    @api
    isValid () {
        try {
            let validationResult = true;
            const input = this.template.querySelector("lightning-input");
            if (input) {
                validationResult = input.checkValidity();
                if (!validationResult) {
                    input.reportValidity();
                }
            }
            return validationResult;
        } catch (error) {console.error(
            "failed in isValid in jsonFormText" + JSON.stringify(error)
        );}
    }

    /**
     * @function : formatterClass
     * @description : Method to set the width of the lightning-input.
     */
    get fieldClass () {
        let cls = "dd-form-field dd-form-text ";
        if (this.fieldLayout.fieldCol) {
            cls +=
                " slds-medium-size_" +
                this.fieldLayout.fieldCol +
                " slds-large-size--" +
                this.fieldLayout.fieldCol +
                " ";
        }
        return cls;
    }

    /**
     * @function : formatterClass
     * @description : Method to set the text field with an icon like '$' to indicate user that a currency must
     *                be entered or just a number or text must be entered.
     */
    get formatterClass () {
        let formatClass = "slds-form-element__control";
        if (undefined != this.formatter && this.formatter === "currency") {
            formatClass = "ssp-inputText ssp-inputIconContainer";
        }
        return formatClass;
    }
}
