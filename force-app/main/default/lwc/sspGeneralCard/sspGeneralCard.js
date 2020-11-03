/***
 * Component Name:sspGeneralCard.js.
 * Author:Chaitanya.
 * Description: This is a generic component called General Card.
 * Date:12/11/2019.
 */
import { LightningElement, api } from "lwc";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";

export default class SspGeneralCard extends LightningElement {
    @api sspGeneralTitleVal;
    @api sspGeneralContentVal;
    @api sspGeneralUrlVal;

    label = {
        sspLearnMoreLink
    };
}
