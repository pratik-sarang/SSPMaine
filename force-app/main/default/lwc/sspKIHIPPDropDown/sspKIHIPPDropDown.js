/**
 * Component Name :SspAccordionCard.
 * Description: Used to open the accordion when the user clicks on it.
 * Author: Chaitanya Kanakia.
 * Date: 11/12/2019.
 */

import { track, api } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspApprovedPremium from "@salesforce/label/c.sspApprovedPremium";
import sspElectiveAbortion from "@salesforce/label/c.sspElectiveAbortion";
import sspBenefitMonth from "@salesforce/label/c.sspBenefitMonth";
import sspReimbursementMonth from "@salesforce/label/c.sspReimbursementMonth";
import sspReasonColon from "@salesforce/label/c.sspReasonColon";
import sspTotalPremium from "@salesforce/label/c.sspTotalPremium";
import sspAdjustments from "@salesforce/label/c.sspAdjustments";
import sspAmount from "@salesforce/label/c.SSP_AmountWithoutDollar";
import sspDollarSign from "@salesforce/label/c.sspDollarSign";
import constants from "c/sspConstants";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

export default class SspAccordionCard extends BaseNavFlowPage {
    label = {
        sspApprovedPremium,
        sspElectiveAbortion,
        sspReasonColon,
        sspBenefitMonth,
        sspReimbursementMonth,
        sspTotalPremium,
        sspAdjustments,
        sspAmount,
        sspDollarSign
    };
    expandIconUrl = sspIcons + constants.url.expandIcon;
    collapseIconUrl = sspIcons + constants.url.collapseIcon;
    hasRendered = false;
    @track openTotalPremiumModal = false;
    @track openAdjustmentModal = false;
    @track reference = this;

    @api showBenefitMonth;
    @api showTotalPremium;
    @api showAdjustments;
    @api totalPremiumModalValues;
    @api adjustmentsModalValues;
    @track adjustmentLinkShow = true;

    adjustmentLink () {
        if (this.showAdjustments === null || this.showAdjustments === 0) {
            this.adjustmentLinkShow = false;
        } else {
            this.adjustmentLinkShow = true;
        }
    }
    connectedCallback () {
        const tempData = JSON.parse(JSON.stringify(this.totalPremiumModalValues));
        if (tempData){
            tempData.forEach((item)=>{
                if (!item.electiveAbortion){
                    item.showElectiveAbortion = false;
                }
                else{
                    item.showElectiveAbortion = true;
                }
            });
            this.totalPremiumModalValues = tempData;
        }
        this.adjustmentLink();
    }
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
            if (!this.hasRendered) {
                accordion.addEventListener("click", function () {
                    const panel = this.nextElementSibling;
                    if (panel.style.maxHeight) {
                        panel.style.maxHeight = null;
                        accordionIcon.src = expandUrl;
                        // this.adjustmentLink();
                    } else {
                        panel.style.maxHeight = panel.scrollHeight + "px";
                        accordionIcon.src = collapseUrl;
                    }
                });
            }
            this.hasRendered = true;
        } catch (error) {
            console.error("Error in  renderedCallback" + error);
        }
    }
    adjustmentsModal () {
        this.openAdjustmentModal = true;
    }
    totalPremiumModal () {
        this.openTotalPremiumModal = true;
    }
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        this.openTotalPremiumModal = false;
        this.openAdjustmentModal = false;
        this.fireEvent();
    }
}