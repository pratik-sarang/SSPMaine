import { LightningElement, track } from "lwc";
import sspAddingExpensePopUpHeader from "@salesforce/label/c.SSP_AddingExpensePopUpHeader";
import sspAddingExpensePopUpContent from "@salesforce/label/c.SSP_AddingExpensePopUpContent";
import sspNext from "@salesforce/label/c.SSP_NextButton";

export default class sspAddingExpense extends LightningElement {
    @track openModal = true;
    customLabel = {
        sspAddingExpensePopUpContent,
        sspAddingExpensePopUpHeader,
        sspNext
    }
    @track reference = this;
    closeModal () {
        this.openModal = false;
    }
}