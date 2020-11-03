/**
 * Component Name: sspMoreHelpInfoModal.
 * Author: Mandi Fazeel Ahmed.
 * Description: Component to show the More Help & Information modal.
 * Date:  01/30/2020.
 */

import {track} from "lwc";
import utility from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";
import sspMoreHelpInfoModalDownloadPDF from "@salesforce/label/c.sspMoreHelpInfoModalDownloadPDF";

import nextStepHelpMoreOne from "@salesforce/label/c.SSP_NextStepHelpMoreOne";
import nextStepHelpMoreTwo from "@salesforce/label/c.SSP_NextStepHelpMoreTwo";
import nextStepHelpMoreThree from "@salesforce/label/c.SSP_NextStepHelpMoreThree";
import nextStepHelpMoreFour from "@salesforce/label/c.SSP_NextStepHelpMoreFour";
import nextStepHelpMoreFive from "@salesforce/label/c.SSP_NextStepHelpMoreFive";
import nextStepHelpMoreSix from "@salesforce/label/c.SSP_NextStepHelpMoreSix";
import nextStepHelpMoreSeven from "@salesforce/label/c.SSP_NextStepHelpMoreSeven";
export default class SspMoreHelpInfoModal extends NavigationMixin(utility) {
  customLabel = {
    sspMoreHelpInfoModalDownloadPDF
    };
    modalData = "";
  @track showSpinner = false;
  @track reference = this;

    

  /**
   * @function : connectedCallback
   * @description : This method is called when html is attached to the component.
   */
  connectedCallback () {
    try {
            this.modalData = `${nextStepHelpMoreOne} ${nextStepHelpMoreTwo} ${nextStepHelpMoreThree} ${nextStepHelpMoreFour} ${nextStepHelpMoreFive} ${nextStepHelpMoreSix} ${nextStepHelpMoreSeven}`;
    } catch (error) {
      console.error("Error calling Connected callback: ", error);
        }
    }
    renderedCallback () {
        try {
            const reference = this.template.querySelector(".ssp-helpContent");
            if (reference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                reference.innerHTML = this.modalData;
  }
        } catch (error) {
            console.error("Error calling  renderedCallback: ", error);
        }
    }
}