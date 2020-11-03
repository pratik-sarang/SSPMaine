import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspOpenOverlay from "@salesforce/label/c.sspOpenOverlay";

export default class SspFindDCBSOverlay extends BaseNavFlowPage {
    @api openModel = false;
    @track reference = this;
    label = { sspOpenOverlay };

    /**
     * @function : openModal
     * @description : This used to open Modal.
     */
    openModal () {
        this.openModel = true;
    }
    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }
}
