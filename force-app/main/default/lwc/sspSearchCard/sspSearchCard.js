/***
 * Component Name: sspSearchCard.js.
 * Author: Chaitanya.
 * Description: This is component is used to search data.
 * Date:12/11/2019.
 */
import sspMiles from "@salesforce/label/c.sspMiles";

import { LightningElement, api } from "lwc";

export default class SspSearchCard extends LightningElement {
    @api sspSearchCardTitle;
    @api sspSearchCardDist;
    @api sspSearchCardCompany;
    @api sspSearchCardBtnVal;

    label = { sspMiles };
}
