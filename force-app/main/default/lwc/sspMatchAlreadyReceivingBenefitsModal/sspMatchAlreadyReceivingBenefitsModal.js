import { LightningElement, api, track } from "lwc";
import sspAlreadyReceivingBenefits from "@salesforce/label/c.SSP_AlreadyReceivingBenefits";
import sspMciMatchModalInfo from "@salesforce/label/c.SSP_MciMatchModalInfo";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspExitApplication from "@salesforce/label/c.SSP_ExitApplication";
import { NavigationMixin } from "lightning/navigation";
import sspConstants from "c/sspConstants";
import utility from "c/sspUtility";

export default class SspMatchAlreadyReceivingBenefitsModal extends NavigationMixin(
    LightningElement
) {
    @api openModal = false;
    @api applicationId = "";
    @api memberIndividualId = "";
    @api finalProgramListSize = false;
    @track reference = this;
    customLabels = {
        sspAlreadyReceivingBenefits,
        sspMciMatchModalInfo,
        sspContinue,
        sspExitApplication
    };
    closeModal = () => {
        this.openModal = false;
    };
    onContinue = () => {        
        this.closeModal();        
        if (
            !utility.isUndefinedOrNull(this.finalProgramListSize) &&
            !this.finalProgramListSize
        ) {
           
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: sspConstants.url.home
                }
            });
        } else {
            this.dispatchEvent(
                new CustomEvent(sspConstants.events.memberAdded, {
                    detail: this.memberIndividualId
                })
            );            
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "programSelection__c"
                },
                state: {
                    applicationId: this.applicationId,
                    mode: "Intake"
                }
            });
        }
    };
    exitApplication = () => {
        this.closeModal();
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: sspConstants.url.home
            }
        });
    };
}
