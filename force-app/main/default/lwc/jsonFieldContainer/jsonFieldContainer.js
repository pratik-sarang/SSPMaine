/*
 * Component Name: JsonFieldContainer
 * Author: Narapa 
 * Description: Place holder Component for all the fields coming from the layout schema from the parent component jsonSchemaPage
 * Date: 05/26/2020.
 */
import { LightningElement, api } from "lwc";

export default class JsonFieldContainer extends LightningElement {
    @api
    objectData;

    @api
    field;

    @api
    allFields;

    @api
    customLabels;

    @api
    renderingCond;

    @api
    disableCond;

    renderedCallback (){
        // Edge browser is not supporting display:contents hence added this workaround to set the host's width
        try {
            if (
                /Edge/.test(navigator.userAgent) ||
                /Edg/.test(navigator.userAgent)
            ) {
                const container = this.template.querySelector(
                    "div.dd-field-container"
                );
                let classes = "";
                container.classList.forEach(function (cls) {
                    if (
                        cls.includes("slds-size") ||
                        cls.includes("slds-medium-size_") ||
                        cls.includes("slds-large-size_")
                    ) {
                        classes += " " + cls;
                    }
                });
                container.parentNode.host.className = classes;
            }
        } catch (e) {
            // continue
            console.error(
                "failed in renderedCallback in jsonFieldContainer" + JSON.stringify(e)
            );
        }
    }

    //getter property to calculate if the field must be shown on the field container
    //or it must be skipped
    get isShown () {
        //this.renderingCond[this.field.name] will be undefined if a field is not dependent on any other field
        //If a field is dependent then we need to show the field based on the dependent field value
        //Dependent field name and whether it should be shown, is coming from the renderingCond Map from Parent Component
        return undefined != this.renderingCond &&
            undefined != this.renderingCond[this.field.name]
            ? this.renderingCond[this.field.name]
            : true;
    }

    //getter property to get the column width of each field being displayed on the page
    get colClass () {
        let cls =
            "dd-field-container slds-m-vertical_medium slds-col slds-size_1-of-1 ";
        if (this.field.gridCol) {
            //If there is a gridCol property set for field in the JSON schema
            cls +=
                " slds-medium-size_" +
                this.field.gridCol +
                " slds-large-size_" +
                this.field.gridCol +
                " ";
        }

        if (this.isEmptyField()) {
            cls += " slds-show_medium ";
        }
        if (this.field.gridOrderS) {
            //If there is gridOrderS attribute helps in rearranging the fields on small devices (Mobile)
            cls += "slds-order_" + this.field.gridOrderS;
        }
        if (this.field.gridOrderM) {
            //If there is gridOrderM attribute helps in rearranging the fields on medium and Desktop Devices
            cls +=
                " slds-medium-order_" +
                this.field.gridOrderM +
                " slds-large-order_" +
                this.field.gridOrderM +
                " ";
        }
        return cls;
    }

    get isEmptyCol () {
        return this.isEmptyField();
    }

    /*
     * @function : isEmptyField
     * @description : Method to calculate if the field is empty,
     *                Field is introduced in schema just to create a space on page Layout.
     */
    isEmptyField () {
        return this.field.name == undefined || this.field.name == "";
    }

    @api
    isValid () {
        let validationResult = true;
        try {
            if (this.template.querySelector("c-json-form-element")) {
                validationResult = this.template
                    .querySelector("c-json-form-element")
                    .isValid();
        }
        } catch (error) {
            console.error(
                "failed in isValid in jsonFieldContainer" + JSON.stringify(error)
            );
        }
        return validationResult;
    }
}
