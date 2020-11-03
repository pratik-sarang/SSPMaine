/*
 * Component Name: sspTMemberModal.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description:
 * Date: 31/01/2020
 */
import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspNoFurtherQuestions from "@salesforce/label/c.sspNoFurtherQuestions";
import sspNext from "@salesforce/label/c.SSP_Next";

export default class SspTMemberModal extends BaseNavFlowPage {
    @api popupContent;
    @track reference = this;
    @track label = {
        sspNoFurtherQuestions,
        sspNext
    };

    /**
     * @function : openModal
     * @description : This used to open Modal.
     */
    openModal = () => {
        this.openModel = true;
    };
    
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp = () => {
        this.openModel = false;
        this.fireEvent();
    };
    saveAndExitModal = () =>{
         this.openModal = false;
         this.openModal = "";
         this.saveCompleted = true;
    }
}