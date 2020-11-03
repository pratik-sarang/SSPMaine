/**
 * Component Name: sspWorkerPortalBanner.
 * Author: Chirag.
 * Description: This a component show notice for case holder.
 * Date: 05/21/2020.
 */

import { LightningElement } from "lwc";
import sspWorkerPortalBannerContent from "@salesforce/label/c.SSP_WorkerPortalBannerContent";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspWorkerPortalBanner extends LightningElement {
    label = {
        sspWorkerPortalBannerContent,
        startBenefitsAppCallNumber
    };
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
}
