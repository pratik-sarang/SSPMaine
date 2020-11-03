import { api, LightningElement } from "lwc";

export default class SspBaseMultipleLineRadio extends LightningElement {
    @api name = "";
    @api title = "";
    @api value;

    onRadioValueChange (event) {
        const radioVal = event.srcElement.value;
        const selectedEvent = new CustomEvent("change", {
            detail: radioVal
        });

        this.dispatchEvent(selectedEvent);
    }
}