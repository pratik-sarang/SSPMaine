/***
 * Component Name: sspReviewVariationCard.js.
 * Author: Saurabh.
 * Description: This is component show review items to the user.
 * Date: 12/11/2019.
 */
import { LightningElement, api } from "lwc";

import sspToastVariationIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "@salesforce/resourceUrl/SSP_Icons";

export default class SspReviewVariationCard extends LightningElement {
    @api buttonValue;
    @api cardData;
    iconUrl = sspToastVariationIcons + apConstants.url.needsReviewIcon;
    nextIconUrl = sspToastVariationIcons + apConstants.url.nextIcon;
}
