/*
 * Component Name: KynecthealthCoverage.
 * Author: Narapa
 * Description: This will be the component which redirects to external Health Coverage           
 * Date: 09/14/2020.
 */
import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import kynectHealthCoverageRedirectUrl from "@salesforce/label/c.kynectHealthCoverageRedirectUrl";

export default class KynecthealthCoverage extends NavigationMixin(LightningElement) {

    @track showSpinner = true;

    customLabels = {
        kynectHealthCoverageRedirectUrl
    }

    connectedCallback () { 
     window.location.replace(this.customLabels.kynectHealthCoverageRedirectUrl);
    }
}