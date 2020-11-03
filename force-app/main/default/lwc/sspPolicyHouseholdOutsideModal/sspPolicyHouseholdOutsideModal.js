/**
 * Component Name: sspPolicyHouseholdOutsideModal
 .* Author: Sharon Roja
 .* Description: This component creates a modal for Policy Household Outside Modal.
 * Date: 19/12/2019.
 */
import { LightningElement, track, api } from "lwc";
import sspPolicyHolderOutsideHousehold from "@salesforce/label/c.SSP_PolicyHolderOutsideHousehold";
import sspPolicyHouseholdOutsideContentOne from "@salesforce/label/c.SSP_PolicyHouseholdOutsideContentOne";
import sspPolicyHouseholdOutsideContentTwo from "@salesforce/label/c.SSP_PolicyHouseholdOutsideContentTwo";
import sspPolicyHouseholdOutsideNext from "@salesforce/label/c.SSP_PolicyHouseholdOutsideNext";
import sspPolicyHouseholdOutsideCancel from "@salesforce/label/c.SSP_PolicyHouseholdOutsideCancel";

export default class SspPolicyHouseholdOutsideModal extends LightningElement {
  customLabel = {
    sspPolicyHolderOutsideHousehold,
    sspPolicyHouseholdOutsideContentOne,
    sspPolicyHouseholdOutsideContentTwo,
    sspPolicyHouseholdOutsideNext,
    sspPolicyHouseholdOutsideCancel
  };

  @track openModel = true;
  @track reference = this;
  @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.

  /*
   * @function : houseOutsideModal
   * @description : This method is used to open the policy household outside modal.
   */
  houseOutsideModal () {
    this.openModel = true;
  }
  /*
   * @function : closeHouseholdOutsidePolicyModel
   * @description : This method is used to close the policy household outside modal.
   */
  closeHouseholdOutsidePolicyModel () {
    const selectedEvent = new CustomEvent("close", {
      detail: true
    });
    this.dispatchEvent(selectedEvent);
  }
}
