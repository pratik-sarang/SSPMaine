/**
 * Component Name :SspAccordionCard.
 * Description: Used to open the accordion when the user clicks on it.
 * Author: Chaitanya Kanakia.
 * Date: 11/12/2019.
 */

import { LightningElement } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import constants from "c/sspConstants";

export default class SspAccordionCard extends LightningElement {
    expandIconUrl = sspIcons + constants.url.expandIcon;
    collapseIconUrl = sspIcons + constants.url.collapseIcon;

    /**
     * @function - renderedCallback
     * @description - This method is used to show the accordion block.
     */
    renderedCallback () {
        try {
            const accordion = this.template.querySelector(
                ".ssp-accordionButton"
            );
            const accordionIcon = this.template.querySelector(
                ".ssp-accordionIcon"
            );
            const collapseUrl = this.collapseIconUrl;
            const expandUrl = this.expandIconUrl;

            accordion.addEventListener("click", function () {
                const panel = this.nextElementSibling;
                if (panel.style.maxHeight) {
                    panel.style.display = "none";
                    panel.style.maxHeight = null;
                    accordionIcon.src = expandUrl;
                } else {
                    panel.style.display = "block";
                    panel.style.maxHeight = panel.scrollHeight + "px";
                    accordionIcon.src = collapseUrl;
                }
            });
        } catch (error) {
            console.error("Error in  renderedCallback" + error);
        }
    }
}
