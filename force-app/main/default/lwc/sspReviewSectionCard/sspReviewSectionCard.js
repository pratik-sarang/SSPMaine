/***
 * Component Name: sspReviewSectionCard.js.
 * Author: Saurabh.
 * Description: This is component show review items to the user.
 * Date: 12/11/2019.
 */
import { LightningElement, api } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

export default class SspReviewSectionCard extends LightningElement {
    @api buttonValue;
    iconUrl = sspIcons + apConstants.url.needsReviewIcon;
}
