/***
 * Component Name:sspFooter.js.
 * Author: Venkata.
 * Description: This is the footer that is shown at the bottom of the screen.
 * Date:12/11/2019.
 */
import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspAgencyLogo from "@salesforce/resourceUrl/agency_logo_small";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspHelpResources from "@salesforce/label/c.SSP_HelpResources";
import sspFooterFAQ from "@salesforce/label/c.SSP_FooterFAQs";
import sspDCBSOffice from "@salesforce/label/c.sspDcbsOffice";
import sspDCBSLink from "@salesforce/label/c.SSP_FooterDCBS_Link";
import sspFooterCHFS from "@salesforce/label/c.SSP_FooterCHFS";
import sspFooterContactUs from "@salesforce/label/c.SSP_FooterContactUs";
import sspBENEFIND from "@salesforce/label/c.SSP_Benefind";
import sspFooterContactNumber from "@salesforce/label/c.SSP_FooterBenefindContactNumber";
import sspFooterTechnicalAssistance from "@salesforce/label/c.SSP_FooterTechnicalAssistanceText";
import sspFooterTechnicalAssistanceNumber from "@salesforce/label/c.SSP_FooterTechnicalAssistanceNumber";
import sspFooterCHFSListensLink from "@salesforce/label/c.SSP_FooterCHFSListensLink";
import sspFooterReportFraud from "@salesforce/label/c.SSP_FooterReportFraud";
import sspFooterPrivacyPolicyAndTermsOfUse from "@salesforce/label/c.SSP_FooterPrivacyPolicyAndTermsOfUse";
import sspFooterCopyright from "@salesforce/label/c.SSP_FooterCopyright";
import sspFooterTelephoneHREF from "@salesforce/label/c.SSP_FooterTelephoneHREF";
import sspFooterMailToHREF from "@salesforce/label/c.SSP_FooterMailToHREF";
import sspFooterHaveAComplaint from "@salesforce/label/c.SSP_FooterHaveAComplaint";
import sspFooterCHFSHomePageLink from "@salesforce/label/c.SSP_FooterCHFS_HomePageLink";
import sspFooterPrivacyPolicyLink from "@salesforce/label/c.SSP_FooterPrivacyPolicyLink";

import sspFooterFAQAlternateText from "@salesforce/label/c.SSP_FooterFAQAlternateText";
import sspFooterDCBSAlternateText from "@salesforce/label/c.SSP_FooterDCBS_AlternateText";
import sspFooterCHFSAlternateText from "@salesforce/label/c.SSP_FooterCHFS_AlternateText";
import sspFooterPhoneAlternateText from "@salesforce/label/c.SSP_FooterPhoneAlternateText";
import sspFooterCHFSLinkAlternateText from "@salesforce/label/c.SSP_FooterCHFS_LinkAlternateText";
import sspFooterReportFraudAlternateText from "@salesforce/label/c.SSP_FooterReportFraudAlternateText";
import sspFooterPrivacyPolicyAndTermOfUseAlternateText from "@salesforce/label/c.SSP_FooterPrivacyPolicyAndTermofUseAlternateText";
import sspFooterBrowserText from "@salesforce/label/c.SSP_FooterBrowserText";
import sspPrintableForms from "@salesforce/label/c.SSP_PrintableForms";
import sspPrintableFormAlt from "@salesforce/label/c.SSP_PrintableFormAlt";
import sspConstants from "c/sspConstants";


import sspFooterExpandedKynect from "@salesforce/label/c.SSP_FooterExpandedKynect";
import sspFooterGoToKynect from "@salesforce/label/c.SSP_FooterGoToKynect";
import sspFooterKynectLink from "@salesforce/label/c.SSP_FooterKynectLink";
import sspFooterGoToKynectTextTwo from "@salesforce/label/c.SSP_FooterGoToKynectTextTwo";
import sspFooterConnect from "@salesforce/label/c.SSP_FooterConnect";
import sspKynectLandingPageURL from "@salesforce/label/c.SSP_KynectLandingPageURL";


import sspFooterSocialMediaIcons from "@salesforce/resourceUrl/sspFooterSocialMediaIcons";

export default class SspFooter extends NavigationMixin(LightningElement) {
    @track agencyLogo = sspAgencyLogo;
    agencyLogo = sspIcons + "/sspIcons/agency_logo_small.png";
    @track footerFaceBookIcon = sspFooterSocialMediaIcons + sspConstants.url.sspFooterFaceBookIcon;
    @track footerTwitterIcon = sspFooterSocialMediaIcons + sspConstants.url.sspFooterTwitterIcon;
    sspFooterFaceBookURL = sspConstants.url.socialMediaFaceBookURL;
    sspFooterTwitterURL = sspConstants.url.socialMediaTwitterURL;
    faceBookIconAltText = sspFooterGoToKynect + " " + this.sspFooterFaceBookURL;
    twitterIconAltText = sspFooterGoToKynect + " " + this.sspFooterTwitterURL;
    sspFooterKynectPageURLAltText = sspFooterGoToKynect + " " + sspFooterKynectLink;
    label = {
        sspPrintableFormAlt,
        sspFooterBrowserText,
        sspHelpResources,
        sspFooterFAQ,
        sspDCBSOffice,
        sspDCBSLink,
        sspFooterCHFS,
        sspFooterContactUs,
        sspBENEFIND,
        sspFooterContactNumber,
        sspFooterTechnicalAssistance,
        sspFooterTechnicalAssistanceNumber,
        sspFooterCHFSListensLink,
        sspFooterReportFraud,
        sspFooterPrivacyPolicyAndTermsOfUse,
        sspFooterCopyright,
        sspFooterTelephoneHREF,
        sspFooterMailToHREF,
        sspFooterHaveAComplaint,
        sspFooterCHFSHomePageLink,
        sspFooterPrivacyPolicyLink,
        sspFooterFAQAlternateText,
        sspFooterDCBSAlternateText,
        sspFooterCHFSAlternateText,
        sspFooterPhoneAlternateText,
        sspFooterCHFSLinkAlternateText,
        sspFooterReportFraudAlternateText,
        sspFooterPrivacyPolicyAndTermOfUseAlternateText,
        sspPrintableForms,
        sspFooterExpandedKynect,
        sspFooterGoToKynect,
        sspFooterKynectLink,
        sspFooterGoToKynectTextTwo,
        sspFooterConnect,
        sspKynectLandingPageURL
    };

    @track sspContactNumber =
        this.label.sspFooterTelephoneHREF + this.label.sspFooterContactNumber;
    @track sspTechnicalAssistanceNumber =
        this.label.sspFooterTelephoneHREF +
        this.label.sspFooterTechnicalAssistanceNumber;
    @track sspCHFSListens =
      this.label.sspFooterMailToHREF + this.label.sspFooterCHFSListensLink;
  
  @track currentYear = "";

    /**
     * @function : connectedCallback
     * @description	: This Method runs every time footer is called.
     */
    connectedCallback () {
        try {
            const date = new Date();
            this.currentYear = date.getFullYear();
        } catch (error) {
            console.error("Error in connectedCallback =>", error);
        }
    }
      /**
     * @function 		: reportFraud.
     * @description 	: method to navigate to Report Fraud.
     * @param {*} event - Js event.
     **/
    reportFraud = event => {
        try {
            const url = window.location.pathname.split("/s/")[1];
            if (event.keyCode === 13 || event.type === "click") {
                if(url==="report-fraud"){
                    window.location.reload();
                }
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: sspConstants.communityPageNames.reportFraudApi
                    },
                    state: {
                        pageOrigin: url
                    }
                });
            }
            
        } catch (error) {
            console.error(error);
        }
    };

   /**
     * @function - navigateToHelpFAQ.
     * @description - Method to navigate Help and FAQ landing Page - Added by Narapa.
     */
   navigateToHelpFAQ () {
    {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: sspConstants.communityPageNames.helpFAQ
            }
        });
    }
   }
    
    /**
     * @function - navigateToContactPage.
     * @description - Method to navigate to Contact Us Landing Page - Added by Narapa.
     */
    navigateToContactUsPage () {
    {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: sspConstants.communityPageNames.helpArticles
            },
            state: { 
                helpCategory: "Contact us"
            }
        });
    }
  }
        /**
         * @function - navigateToPrintableFormsPage.
         * @description - Method to navigate to Contact Us Landing Page - Added by Narapa.
         */
        navigateToPrintableFormsPage () {
            {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: sspConstants.communityPageNames.helpArticles
                    },
                    state: { 
                        helpCategory: "BA_Printable Forms"
                    }
                });
            }
            }
}
