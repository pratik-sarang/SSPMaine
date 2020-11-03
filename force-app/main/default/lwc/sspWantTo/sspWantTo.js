/*
 * Component Name: sspWantTo.
 * Author: Nikhil Shinde.
 * Description: This component provides search fields, search results and export to excel functionality.
 * Date: 26-05-2020
 */

import { LightningElement, track, api } from "lwc";
import sspConstants from "c/sspConstants";

import sspIWantTo from "@salesforce/label/c.SSP_IWantTo";
import sspCheckForEligibilityDescription from "@salesforce/label/c.SSP_CheckForPotentialEligibility";
import sspDownloadUserManualDescription from "@salesforce/label/c.SSP_DownloadUserManual";
import sspRequestAccessToCaseDescription from "@salesforce/label/c.SSP_RequestAccessToCase";
import sspStartShortSNAPDescription from "@salesforce/label/c.SSP_StartShortSNAP";
import sspVisitAgentPortalDescription from "@salesforce/label/c.SSP_VisitAgentPortal";
import sspAgentPortal from "@salesforce/label/c.SSP_AgentPortal";
import sspDownloadUserManual from "@salesforce/label/c.SSP_DownloadQualifiedEntityUserManual";
import sspPreScreeningTool from "@salesforce/label/c.SSP_PrescreeningTool";
import sspStartShortSNAP from "@salesforce/label/c.SSP_StartShortSNAPApplication";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import sspAgentPortalURL from "@salesforce/label/c.SSP_AgentPortalURL";
import sspUserManualDownloadLink from "@salesforce/label/c.SSP_UserManualURL";

import sspRequestAccessAlternateText from "@salesforce/label/c.SSP_WantToRequestAcessAlternateText";
import sspPreScreeningAlternateText from "@salesforce/label/c.SSP_WantToPrescreeningAlternateText";
import sspSNAPAlternateText from "@salesforce/label/c.SSP_WantToSNAPAlternateText";
import sspAgentPortalAlternateText from "@salesforce/label/c.SSP_WantToAgentPortalAlternateText";
import sspDownloadManualAlternateText from "@salesforce/label/c.SSP_WantToDownloadManualAlternateText";
import { NavigationMixin } from "lightning/navigation";

export default class SspWantTo extends NavigationMixin(LightningElement) {
    @api linkRoleVisibility;
    @api showRequestAccess = false;
    @track isAuthRep = false;
    @track showSpinner = false;
    @track requestAccessURL = sspConstants.navigationUrl.assisterAccessRequest;
    //@track requestAccessURL ="/benefind/s/assister-access-request";
    @track customLabels = {
        sspIWantTo,
        sspCheckForEligibilityDescription,
        sspDownloadUserManualDescription,
        sspRequestAccessToCaseDescription,
        sspStartShortSNAPDescription,
        sspVisitAgentPortalDescription,
        sspAgentPortal,
        sspDownloadUserManual,
        sspPreScreeningTool,
        sspStartShortSNAP,
        sspRequestAccess,
        sspAgentPortalURL,
        sspUserManualDownloadLink,
        sspRequestAccessAlternateText,
        sspPreScreeningAlternateText,
        sspSNAPAlternateText,
        sspAgentPortalAlternateText,
        sspDownloadManualAlternateText
    };
    authorizedRepresentativeURL = sspConstants.url.authReps;
    shortSnapURL = sspConstants.url.shortSnapGetStartedUrl;
    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    @api
    get isAuthRepRole () {
        try{
            return this.isAuthRep;
        }catch (error) {
            console.error(
               "error in isAuthRepRole"+error
            );
            return null;
        }
    }
    set isAuthRepRole (value) {
        try{
            if(value){
                this.requestAccessURL =  sspConstants.navigationUrl.authRepsAccessRequest;
                //this.requestAccessURL = "/benefind/s/auth-rep-access-request";
            }
        }catch (error) {
            console.error(
                "error in isAuthRepRole"
            );
        }
    }
    /**
     * @function : navigateToAccessRequest
     *  * @description : This method used to navigate to different pages.
     */
    navigateToAccessRequest () {
        try {
            const self = this;
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url:
                    self.requestAccessURL
                }
            });
        } catch (error) {
            console.error("Error in navigationFunction", error);
        }
    }
    navigateToPreScreeningToolPage () {
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.prescreeening
                },
                state: {
                    retPage: "dashboard__c"
                }
            });
        }
    }
}