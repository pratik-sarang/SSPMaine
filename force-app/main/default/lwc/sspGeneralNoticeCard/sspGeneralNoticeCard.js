/***
 * Component Name:sspGeneralNoticeCard.js.
 * Author:Chaitanya.
 * Description: This is a generic card called the Generic Notice Card.
 * Date:12/11/2019.
 */
import { LightningElement, api, track } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

export default class SspGeneralNoticeCard extends LightningElement {
    infoIconUrl = sspIcons + apConstants.url.infoIcon;
    needsReviewIconUrl = sspIcons + apConstants.url.needsReviewIcon;
    @api noticeText = "";
    @api noticeType = "";
    @track isWarning = false;
    @track isExplicit = false;

    /**
     * @function - renderedCallback
     * @description -Method is called when the entire UI is done rendering.
     */
    renderedCallback () {
        const Elem = this.template.querySelector(".ssp-noticeCard");
        let classesToAdd;
        if (this.noticeType === "warning") {
            this.isWarning = true;
            classesToAdd = ["ssp-warningNoticeCard", "ssp-bg_whiteBeta"];
        } else if (this.noticeType === "explicit") {
            this.isExplicit = true;
            classesToAdd = ["ssp-explicitNoticeCard", "ssp-bg_redGamma"];
        } else {
            classesToAdd = ["ssp-generalNoticeCard"];
        }
        Elem.classList.add(...classesToAdd);
    }
}
