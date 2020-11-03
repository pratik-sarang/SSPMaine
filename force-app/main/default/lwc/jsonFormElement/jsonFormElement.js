import { LightningElement, api, track } from "lwc";

export default class JsonFormElement extends LightningElement {
    @api
    name;

    @api
    formData;

    @api
    value;

    @api
    allFields;

    @api
    fieldLayout;

    @api
    picklistsRecordTypeId;

    @api
    customLabels;

    @api
    disableCond;

    @track
    fieldInfo;

    @track
    typ;

    @track
    temppicklistField;

    @track
    temppicklistOptions;

    connectedCallback (){
        this.fieldInfo = this.allFields[this.name];
        this.typ = this.fieldInfo.typ;
    }

    get isTextType () {
        return !(
            "checkbox-button" == this.typ ||
            "rich-text" == this.typ ||
            "picklist" == this.typ ||
            "object" == this.typ ||
            "toggle" == this.typ ||
            "button" == this.typ
        );
    }

    get isChkBxBtn () {
        return "checkbox-button" == this.typ;
    }

    get isRichText () {
        return "rich-text" == this.typ;
    }

    get isPicklist () {
        return "picklist" == this.typ;
    }

    get isToggle () {
        return "toggle" == this.typ;
    }

    get isButton () {
        return "button" == this.typ;
    }

    @api
    isValid () {
        let validationResult = true;
        try {
            if (this.template.querySelector("c-json-form-text")) {
                validationResult = this.template
                    .querySelector("c-json-form-text")
                    .isValid();
        }
        } catch (error) {
            console.error(
                "failed in isValid in jsonFormElement" + JSON.stringify(error)
            );
        }
        try {
            if (this.template.querySelector("c-json-form-toggle")) {
                validationResult = this.template
                    .querySelector("c-json-form-toggle")
                    .isValid();
        }
        } catch (error) {
            console.error(
                "failed in isValid in jsonFormElement" + JSON.stringify(error)
            );
        }
        return validationResult;
    }
}