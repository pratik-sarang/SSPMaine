/**
 * Component Name: sspWarningNoticeCard.
 * Author: Chaitanya.
 * Description: This a component which shows a warning to the user.
 * Date: 12/11/2019.
 */

import { LightningElement } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

export default class SspWarningNoticeCard extends LightningElement {
    icInfoUrl = sspIcons + apConstants.url.infoIcon;
}
