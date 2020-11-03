/**
 * Component Name: SspExplicitNoticeCard.
 * Author: Nupoor.
 * Description: This a component which shows a warning to the user.
 * Date: 11/11/2019.
 */
import {
    LightningElement
} from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

export default class SspExplicitNoticeCard extends LightningElement {
    needReviewIcon =
        sspIcons + apConstants.url.needsReviewIcon;
}