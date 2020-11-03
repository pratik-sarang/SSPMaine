/*
 * Component Name: JsonSchemaPage
 * Author: Narapa 
 * Description: This component acts as a junction between the jsonFlowContainer and jsonFieldContainer
 * Date: 05/25/2020.
 */
import { LightningElement, api, track } from "lwc";

export default class JsonSchemaPage extends LightningElement {
    @api
    navFlowPageConfig;

    @api
    objectSchema;

    @api
    objectData;

    @api
    layoutSchema;

    @api
    renderingCond;

    @api
    disableCond;

    @api
    customLabels;

    @api
    allFields;

    @track
    isInit;

    connectedCallback (){
        if (null != this.navFlowPageConfig) {
            this.isInit = true;
        }
    }

    @api
    isValid () {
        const validationResult = [];
        try {
            if (this.template.querySelectorAll("c-json-field-container")) {
                const container = this.template.querySelectorAll(
                    "c-json-field-container"
                );
                container.forEach(function (item) {
                    validationResult.push(item.isValid());
                });
            }
        } catch (error) {
            console.error(
                "failed in isValid in jsonSchemaPage" + JSON.stringify(error)
            );
        }
        return validationResult;
    }
}