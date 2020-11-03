/**
 *
 * @author         - Chaitanya Kanakia
 * @description    - Used to open the accordion when the user clicks on it. Component Name - sspAccordionCard.
 * Date       	  - 11/12/2019.
 */
import { LightningElement, api } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";

export default class SspAccordionCard extends LightningElement {
    expandIconUrl = sspIcons + "/sspIcons/ic_expand@3x.png";
    collapseIconUrl = sspIcons + "/sspIcons/ic_collapse@3x.png";
    hasRendered = false;
    accordionClass = "ssp-accordion";

    @api
    accordionAdditionalClass;
    @api isExpanded = false;
    isAccordionClicked = false;

    /**
     * @function - connectedCallback
     * @description - This method is called on load.
     */
    connectedCallback () {
        //setting any additional styles to accordion being passed from parent component
        if (this.accordionAdditionalClass) {
            this.accordionClass = this.accordionClass + " " + this.accordionAdditionalClass;
        }
    }
    
    /**
     * @function - renderedCallback
     * @description - This method is used to show the accordion block.
     */
    renderedCallback () {
        const accordion = this.template.querySelector(".ssp-accordionButton");
        const accordionIcon = this.template.querySelector(".ssp-accordionIcon");
        const collapseUrl = this.collapseIconUrl;
        const expandUrl = this.expandIconUrl;
        if (!this.hasRendered) {
            accordion.addEventListener("click", function (event) {
                const panel = this.nextElementSibling;
                if (panel.style.maxHeight) {
                    panel.style.display = "none";
                    panel.style.maxHeight = null;
                    accordionIcon.src = expandUrl;
                    event.target.setAttribute("aria-expanded", false);
                    panel.setAttribute("aria-hidden", true);
                } else {
                    panel.style.display = "block";
                    panel.style.maxHeight = panel.scrollHeight + "px";
                    accordionIcon.src = collapseUrl;
                    event.target.setAttribute("aria-expanded", true);
                    panel.setAttribute("aria-hidden", false);
                }
            });
            if (this.isExpanded && accordion && !this.isAccordionClicked) {
                    accordion.click();
                    this.isAccordionClicked = true;
            }
        }
        this.hasRendered = true;
    }

    /**
     * @function - expandAccordion
     * @description - public method to be called from Expand All Button on the Help and FAQ pages.
     */
    @api
    expandAccordion () {
        const accordion = this.template.querySelector(".ssp-accordionButton");
        const accordionIcon = this.template.querySelector(".ssp-accordionIcon");
        const collapseUrl = this.collapseIconUrl;
        const panel = accordion.nextElementSibling;
        panel.style.display = "block";
        panel.style.maxHeight = panel.scrollHeight + "px";
        accordionIcon.src = collapseUrl;
        accordion.setAttribute("aria-expanded", true);
        panel.setAttribute("aria-hidden", false);    
    }

    /**
     * @function - collapseAccordion
     * @description - public method to be called from Collapse All Button on the Help and FAQ pages.
     */
    @api
    collapseAccordion () { 
        const accordion = this.template.querySelector(".ssp-accordionButton");
        const accordionIcon = this.template.querySelector(".ssp-accordionIcon");
        const expandUrl = this.expandIconUrl;
        const panel = accordion.nextElementSibling;
        panel.style.display = "none";
        panel.style.maxHeight = null;
        accordionIcon.src = expandUrl;
        accordion.setAttribute("aria-expanded", false);
        panel.setAttribute("aria-hidden", true);

    }
}