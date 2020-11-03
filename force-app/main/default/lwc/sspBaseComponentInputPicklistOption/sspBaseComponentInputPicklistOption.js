import { LightningElement, track, api } from "lwc";

export default class SspBaseComponentInputPicklistOption extends LightningElement {
    @api selected;
    @track optionItem;
    @api oldValue = "";

    @api
    get optiondata () {
        return this.optionItem;
    }

    set optiondata (value) {
        this.optionItem = JSON.parse(JSON.stringify(value));
        if (this.selected === this.optionItem.value) {
            this.optionItem.optionSelected = true;
        } else {
            this.optionItem.optionSelected = false;
        }
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