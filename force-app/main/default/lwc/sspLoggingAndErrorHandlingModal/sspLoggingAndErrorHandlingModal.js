import sspConstants from "c/sspConstants";
import { LightningElement, api, track } from "lwc";
import sspErrorStatus from "@salesforce/label/c.SSP_ErrorStatus";
import sspCustomerServiceAvailable from "@salesforce/label/c.SSP_CustomerServiceAvailable";
import sspMondayFridayTime from "@salesforce/label/c.SSP_MondayFridayTime";
import sspSaturdayHoursVary from "@salesforce/label/c.SSP_SaturdayHoursVary";
import sspSorryForInconvenience from "@salesforce/label/c.SSP_SorryFoInconvenience";
import sspContactCustomerServiceReference from "@salesforce/label/c.SSP_ContactCustomerServiceReference";
import sspContinueButton from "@salesforce/label/c.SSP_ContinueButton";
import sspDot from "@salesforce/label/c.SSP_Dot";
import sspLoggingAndErrorContent1 from "@salesforce/label/c.SSP_LoggingAndErrorContent1";
import sorryForInconvenience from "@salesforce/label/c.SSP_SorryFoInconvenience";

const unicorn0 = /\{0\}/g;
export default class SspLoggingAndErrorHandlingModal extends LightningElement {
    @api errorId;
    @track openModal = true;
    @api progressValue;
    @track number = sspConstants.loggingAndErrorHandlingConstants.contactNumber;
    @track numberHref = `tel:${this.number}`;
    @track reference = this;

    label = {
        sspErrorStatus,
        sspCustomerServiceAvailable,
        sspMondayFridayTime,
        sspSaturdayHoursVary,
        sspSorryForInconvenience,
        sspContinueButton,
        sspLoggingAndErrorContent1,
        sspDot,
        sorryForInconvenience
    };
    @track customLabel = {
        sspContactCustomerServiceReference
    };

    get contactCustomerService () {
        return sspContactCustomerServiceReference.replace(
            unicorn0,
            this.errorId
        );
    }

    closeModal = event => {
        this.openModal = false;
        this.progressValue = false;
        const selectedEvent = new CustomEvent(
            sspConstants.events.progressValueChange,
            {
                detail: this.progressValue,
                rootEvent: event
            }
        );
        this.dispatchEvent(selectedEvent);
    };
}
