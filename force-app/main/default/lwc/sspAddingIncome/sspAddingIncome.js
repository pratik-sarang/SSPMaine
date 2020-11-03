import { LightningElement, track } from "lwc";
import sspAddingIncomePopUpHeader from "@salesforce/label/c.SSP_AddingIncomePopUpHeader";
import sspAddingIncomePopUpContent from "@salesforce/label/c.SSP_AddingIncomePopUpContent";
import sspNext from "@salesforce/label/c.SSP_NextButton";
import sspGoToIncomeSummary from "@salesforce/label/c.SSP_GoToIncomeSummary";
export default class sspAddingIncome extends LightningElement {
    @track openModal = true;
    customLabel = {
        sspAddingIncomePopUpContent,
        sspAddingIncomePopUpHeader,
        sspNext,
        sspGoToIncomeSummary
    }
    @track reference = this;
    closeModal () {
        this.openModal = false;
    }
}