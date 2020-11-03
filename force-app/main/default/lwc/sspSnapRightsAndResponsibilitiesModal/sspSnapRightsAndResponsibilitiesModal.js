/**
 * Component Name: sspSnapRightsAndResponsibilitiesModal.
 * Author: Karthik Velu, Sai Kiran.
 * Description: This component opens the SNAP Rights and Responsibilities Modal.
 * Date: 2/3/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspSnapRightsAndResponsibilities from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesTitle";
import sspPenaltyWarning from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesPenaltyWarning";
import sspAnyoneInYour from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesAnyoneInYour";
import sspFollowTheseRules from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesFollowTheseRules";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspAgreeButtonAlternate from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesAgreeAlternate";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspDisagreeButtonAlternate from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesDisagreeAlternate";
import sspGiveFalseInformation from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesGiveFalseInformation";
import sspNotTradeSell from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesNotTradeSell";
import sspToBuyIneligibleItems from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesToBuyIneligibleItems";
import sspUseSomeoneElse from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesUseSomeoneElse";
import sspForSomeoneOutside from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesForSomeoneOutside";
import sspSnapEligibleFood from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesSnapEligibleFood";
import sspSellFoodPurchased from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesSellFoodPurchased";
import sspCooperateWithQuality from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesCooperateWithQuality";
import sspIfYouBreak from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesIfYouBreak";
import sspHouseholdsFoundGuilty from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesHouseholdsFoundGuilty";
import sspRecipientsFoundGuilty from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesRecipientsFoundGuilty";
import sspYouWillNotGetSnapBenefits from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesYouWillNotGetSnapBenefits";
import sspFleeingFelon from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesFleeingFelon";
import sspWhatWeDo from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesWhatWeDo";
import sspIfAnyInformation from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesIfAnyInformation";
import sspPrivacyAct from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesPrivacyAct";
import sspTheCollectionOfThis from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesTheCollectionOfThis";
import sspDisclosedToOther from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesDisclosedToOther";
import sspIfSnapClaimArises from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesIfSnapClaimArises";
import sspProvidingTheRequested from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesProvidingTheRequested";
import sspWeCheckWhatYou from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesWeCheckWhatYou";
import sspWeUseComputer from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesWeUseComputer";
import sspThingsWeMightCheck from "@salesforce/label/c.SSP_SnapRightsAndResponsibilitiesThingsWeMightCheck";
import constants from "c/sspConstants";
export default class SspSnapRightsAndResponsibilitiesModal extends LightningElement {
    @api isSelectedValue = false;
    @track openModel = true;
    @track trueValue;
    @track disabled = true;
    @track reference = this;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspSnapRightsAndResponsibilities,
        sspPenaltyWarning,
        sspAnyoneInYour,
        sspFollowTheseRules,
        sspGiveFalseInformation,
        sspNotTradeSell,
        sspToBuyIneligibleItems,
        sspUseSomeoneElse,
        sspForSomeoneOutside,
        sspSnapEligibleFood,
        sspSellFoodPurchased,
        sspCooperateWithQuality,
        sspIfYouBreak,
        sspHouseholdsFoundGuilty,
        sspRecipientsFoundGuilty,
        sspYouWillNotGetSnapBenefits,
        sspFleeingFelon,
        sspWhatWeDo,
        sspIfAnyInformation,
        sspPrivacyAct,
        sspTheCollectionOfThis,
        sspDisclosedToOther,
        sspIfSnapClaimArises,
        sspProvidingTheRequested,
        sspWeCheckWhatYou,
        sspWeUseComputer,
        sspThingsWeMightCheck,
        sspAgreeButton,
        sspAgreeButtonAlternate,
        sspDisagreeButton,
        sspDisagreeButtonAlternate
    };

    get buttonDisability () {
        return this.disabled || this.isReadOnlyUser;
    }

    @api
    get scrollFunction () {
        return this.trueValue;
    }
    set scrollFunction (value) {
        if (!value) {
            this.trueValue = false;
        } else {
            this.trueValue = true;
        }
    }
    /**
     * @function : connectedCallback
     * @description : This method is used to get the api values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }
        } catch (error) {
            console.error("Error occurred in connectedCallback" + error);
        }
    }

    /**
     * @function : closeSnapRightsModal.
     * @description : This method is used to close the Modal.
     */
    closeSnapRightsModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in closeSnapRightsModal" + error);
        }
    };
    /**
     * @function : handleOnClick.
     * @description : This method is used to agree/disAgree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = event => {
        try {
            const eventName = event.target.name;
            let fieldValue;
            if (eventName === constants.signaturePage.Agree) {
                fieldValue = constants.toggleFieldValue.yes;
            } else {
                fieldValue = constants.toggleFieldValue.no;
            }
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: {
                        sFieldValue: fieldValue,
                        sFieldName: "IsAgreeingToSNAPRightsConsent__c"
                    }
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error occurred in agreeSnapRightsModalModal" + error
            );
        }
    };

    /**
     * @function : enableModalButtons.
     * @description : This method is used to enable the buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error("Error occurred in enableModalButtons" + error);
        }
    };
}