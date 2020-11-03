/*
 * Component Name: sspHomePage.
 * Author: Fazeel.
 * Description: This screen is for Home page.
 * Date: 24/02/2020.
 */
import { LightningElement, track, wire } from "lwc";
import fetchCommunityURL from "@salesforce/apex/SSP_HomePageController.fetchCommunityURL";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspHomePageWelcome from "@salesforce/label/c.sspHomePageWelcome";
import sspLMSVideoUrl from "@salesforce/label/c.SSP_LmsVideoUrl";
import sspHomePageWelcomeContent from "@salesforce/label/c.sspHomePageWelcomeContent";
import sspHomePageCheckEligibility from "@salesforce/label/c.sspHomePageCheckEligibility";
import sspHomePageApplyBenefit from "@salesforce/label/c.sspHomePageApplyBenefit";
import sspHomePageSignUp from "@salesforce/label/c.sspHomePageSignUp";
import sspHomePageNoAccount from "@salesforce/label/c.sspHomePageNoAccount";
import sspHomePageApplyBenefitsOnBehalf from "@salesforce/label/c.sspHomePageApplyBenefitsOnBehalf";
import sspHomePageProgram from "@salesforce/label/c.sspHomePageProgram";
import sspHomePageProgramContent from "@salesforce/label/c.sspHomePageProgramContent";
import sspHomePageFoodAssistance from "@salesforce/label/c.sspHomePageFoodAssistance";
import sspHomePageFoodAssistanceContent1 from "@salesforce/label/c.sspHomePageFoodAssistanceContent1";
import sspHomePageFoodAssistanceContent2 from "@salesforce/label/c.sspHomePageFoodAssistanceContent2";
import sspHomePageLearnMore from "@salesforce/label/c.sspHomePageLearnMore";
import sspHomePageFinancialAssist from "@salesforce/label/c.sspHomePageFinancialAssist";
import sspHomePageFinancialAssistContent1 from "@salesforce/label/c.sspHomePageFinancialAssistContent1";
import sspHomePageFinancialAssistContent2 from "@salesforce/label/c.sspHomePageFinancialAssistContent2";
import sspHomePageHealthAssist from "@salesforce/label/c.sspHomePageHealthAssist";
import sspHomePageHealthAssistContent1 from "@salesforce/label/c.sspHomePageHealthAssistContent1";
import sspHomePageHealthAssistContent2 from "@salesforce/label/c.sspHomePageHealthAssistContent2";
import sspHomePagePremiumAssist from "@salesforce/label/c.sspHomePagePremiumAssist";
import sspHomePagePremiumAssistContent1 from "@salesforce/label/c.sspHomePagePremiumAssistContent1";
import sspHomePagePremiumAssistContent2 from "@salesforce/label/c.sspHomePagePremiumAssistContent2";
import sspHomePageChildAssist from "@salesforce/label/c.sspHomePageChildAssist";
import sspHomePageChildAssistContent1 from "@salesforce/label/c.sspHomePageChildAssistContent1";
import sspHomePageChildAssistContent2 from "@salesforce/label/c.sspHomePageChildAssistContent2";
import sspHomePageLocalResource from "@salesforce/label/c.sspHomePageLocalResource";
import sspHomePageLocalResourceContent from "@salesforce/label/c.sspHomePageLocalResourceContent";
import sspHomePageGoToBack from "@salesforce/label/c.sspHomePageGotoBackyard";
import sspHomePageNeedHelp from "@salesforce/label/c.sspHomePageNeedHelp";
import sspHomePageNeedHelpContent from "@salesforce/label/c.sspHomePageNeedHelpContent";
import sspHomePageMeetInsuranceAgent from "@salesforce/label/c.sspHomePageMeetInsuranceAgent";
import sspHomePageMeetInsuranceAgentContent from "@salesforce/label/c.sspHomePageMeetInsuranceAgentContent";
import sspHomePageMeetInsuranceAgentButton from "@salesforce/label/c.sspHomePageMeetInsuranceAgentButton";
import sspHomePageMeetDCBSRep from "@salesforce/label/c.sspHomePageMeetDCBSRep";
import sspHomePageMeetDCBSRepContent from "@salesforce/label/c.sspHomePageMeetDCBSRepContent";
import sspHomePageMeetDCBSRepContent1 from "@salesforce/label/c.sspHomePageMeetDCBSRepContent1";
import sspHomePageMeetDCBSRepContent2 from "@salesforce/label/c.sspHomePageMeetDCBSRepContent2";
import sspHomePageMeetDCBSRepContent3 from "@salesforce/label/c.sspHomePageMeetDCBSRepContent3";
import sspHomePageMeetDCBSRepButton from "@salesforce/label/c.sspHomePageMeetDCBSRepButton";
import sspHomePageMeetDCBSOffice from "@salesforce/label/c.sspHomePageMeetDCBSOffice";
import sspHomePageMeetDCBSOfficeContent from "@salesforce/label/c.sspHomePageMeetDCBSOfficeContent";
import sspHomePageMeetDCBSOfficeContent1 from "@salesforce/label/c.sspHomePageMeetDCBSOfficeContent1";
import sspHomePageMeetDCBSOfficeContent2 from "@salesforce/label/c.sspHomePageMeetDCBSOfficeContent2";
import sspHomePageMeetDCBSOfficeContent3 from "@salesforce/label/c.sspHomePageMeetDCBSOfficeContent3";
import sspHomePageMeetDCBSOfficeButton from "@salesforce/label/c.sspHomePageMeetDCBSOfficeButton";
import sspHomePageReprint1095B from "@salesforce/label/c.sspHomePageReprint1095B";
import sspHomePageReprint1095BContent from "@salesforce/label/c.sspHomePageReprint1095BContent";
import sspHomePageReprint1095BButton from "@salesforce/label/c.sspHomePageReprint1095BButton";
import sspHomePageBrowserText from "@salesforce/label/c.SSP_HomePageBrowserText";
import sspHomePageApplyForBenefitsSubText from "@salesforce/label/c.SSP_HomePageApplyForBenefitsSubText";
import sspHomePagePrescreeningSubText from "@salesforce/label/c.SSP_HomePagePrescreeningSubText";
import ssp1095BLink from "@salesforce/label/c.SSP_1095BLink";

import sspCreatingCommunitySupport from "@salesforce/label/c.sspCreatingCommunitySupport";
import sspKynectResourcesHelpDIsCover from "@salesforce/label/c.sspKynectResourcesHelpDIscover";
import sspAdvancedPremiumTaxCredit from "@salesforce/label/c.sspAdvancedPremiumTaxCredit";
import sspFindOutCoverageYouQualify from "@salesforce/label/c.sspFindOutCoverageYouQualify";
import sspHomePageFood from "@salesforce/label/c.sspHomePageFood";
import sspHomePageHousing from "@salesforce/label/c.sspHomePageHousing";
import sspHomePageJobs from "@salesforce/label/c.sspHomePageJobs";
import sspHomePageAndMore from "@salesforce/label/c.sspHomePageAndMore";
import sspHealthBenefitExchange from "@salesforce/label/c.sspHealthBenefitExchange";
import sspVisitKynectResources from "@salesforce/label/c.sspVisitKynectResources";
import sspGoToKynectResources from "@salesforce/label/c.sspGoToKynectResources";

import sspLowCostHealthInsure from "@salesforce/label/c.sspLowCostHealthInsure";

import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspGetLoginURL from "@salesforce/apex/SSP_HeaderCtrl.fetchKogURL";



import sspHomePageBannerTextOne from "@salesforce/label/c.SSP_HomePageBannerTextOne";
import sspHomePageBannerTextTwo from "@salesforce/label/c.SSP_HomePageBannerTextTwo";
import sspHomePageBannerButtonText from "@salesforce/label/c.SSP_HomePageBannerButtonText";
import kynectBannerLogo from "@salesforce/resourceUrl/sspHomePageKynectBannerLogo";
import sspKynectLandingPageURL from "@salesforce/label/c.SSP_KynectLandingPageURL";

export default class SspHomePage extends NavigationMixin(LightningElement) {
    topBannerSectionImage = sspIcons + constants.homePageConstants.topBannerSec;
    bottomBannerSectionImage =
        sspIcons + constants.homePageConstants.bottomBannerSec;
    topBannerSectionImageMobile =
        sspIcons + constants.homePageConstants.mobileSection;

    @track bannerKynectLogo = kynectBannerLogo + constants.url.sspHomePageBannerKynectLogo;

    label = {
        sspLowCostHealthInsure,
        sspGoToKynectResources,
        sspVisitKynectResources,
        sspHealthBenefitExchange,
        sspHomePageAndMore,
        sspHomePageJobs,
        sspHomePageHousing,
        sspHomePageFood,
        sspFindOutCoverageYouQualify,
        sspAdvancedPremiumTaxCredit,
        sspKynectResourcesHelpDIsCover,
        sspCreatingCommunitySupport,
        sspHomePageBrowserText,
        sspLMSVideoUrl,
        sspHomePageWelcome,
        sspHomePageWelcomeContent,
        sspHomePageCheckEligibility,
        sspHomePageApplyBenefit,
        sspHomePageSignUp,
        sspHomePageNoAccount,
        sspHomePageApplyBenefitsOnBehalf,
        sspHomePageProgram,
        sspHomePageProgramContent,
        sspHomePageFoodAssistance,
        sspHomePageFoodAssistanceContent1,
        sspHomePageFoodAssistanceContent2,
        sspHomePageLearnMore,
        sspHomePageFinancialAssist,
        sspHomePageFinancialAssistContent1,
        sspHomePageFinancialAssistContent2,
        sspHomePageHealthAssist,
        sspHomePageHealthAssistContent1,
        sspHomePageHealthAssistContent2,
        sspHomePagePremiumAssist,
        sspHomePagePremiumAssistContent1,
        sspHomePagePremiumAssistContent2,
        sspHomePageChildAssist,
        sspHomePageChildAssistContent1,
        sspHomePageChildAssistContent2,
        sspHomePageLocalResource,
        sspHomePageLocalResourceContent,
        sspHomePageGoToBack,
        sspHomePageNeedHelp,
        sspHomePageNeedHelpContent,
        sspHomePageMeetInsuranceAgent,
        sspHomePageMeetInsuranceAgentContent,
        sspHomePageMeetInsuranceAgentButton,
        sspHomePageMeetDCBSRep,
        sspHomePageMeetDCBSRepContent,
        sspHomePageMeetDCBSRepContent1,
        sspHomePageMeetDCBSRepContent2,
        sspHomePageMeetDCBSRepContent3,
        sspHomePageMeetDCBSRepButton,
        sspHomePageMeetDCBSOffice,
        sspHomePageMeetDCBSOfficeContent,
        sspHomePageMeetDCBSOfficeContent1,
        sspHomePageMeetDCBSOfficeContent2,
        sspHomePageMeetDCBSOfficeContent3,
        sspHomePageMeetDCBSOfficeButton,
        sspHomePageReprint1095B,
        sspHomePageReprint1095BContent,
        sspHomePageReprint1095BButton,
        sspHomePageApplyForBenefitsSubText,
        sspHomePagePrescreeningSubText,
        ssp1095BLink,
        sspHomePageBannerTextOne,
        sspHomePageBannerTextTwo,
        sspHomePageBannerButtonText,
        sspKynectLandingPageURL
    };

  @track phoneNumberDCBS = `tel:` + this.label.sspHomePageMeetDCBSRepButton;
  @track communityURL;
  @track selectedRole;
  @track isBannerTextVisible = false;
  @track prescreeningCardText = this.label.sspHomePagePrescreeningSubText;
  @track applyForBenefitsCardText = this.label.sspHomePageApplyForBenefitsSubText;
   @track backYardURL;
    @track hasRendered = false;

    get jawsStatus () {
        return this.hasRendered;
    }
  /**
   * @function : connectedCallback.
   * @description : Method to check the browser.
   */
  connectedCallback () {
    try {
      this.isBannerTextVisible = navigator.userAgent.indexOf("MSIE ") > -1 || navigator.userAgent.indexOf("Trident/") > -1;
    }
    catch(error){
      console.error(
        "Error in connectedCallback in home page" +
        JSON.stringify(error.message)
      );
    }
  }

  @wire(fetchCommunityURL)
  communityURLValue (value) {
    try {
      if (
        value.data &&
        value.data.mapResponse &&
        value.data.mapResponse.communityURL
      ) {
        this.communityURL = value.data.mapResponse.communityURL;
        this.hasRendered = true;
      }
    } catch (error) {
      console.error("Error in wire call fetchCommunityURL:", error);
    }
  }

  /**
   *
   * @function - redirectToFindAgent()
   * @description - method to redirect to Find Agent page.
   * @param {object} event - Js event.
   */
  redirectToFindAgent = event => {
    try {
     // window.open(constants.homePageConstants.agentURL, "_blank");
     const selectedPage = event.currentTarget.getAttribute("data-page");
     this[NavigationMixin.Navigate]({
         type: "comm__namedPage",
         attributes: {
             name: selectedPage
         }
     });
    } catch (error) {
      console.error("Error redirecting to Find Agent Screen", error);
    }
  };

  /**
   *
   * @function - redirectTo1095Portal()
   * @description - method to redirect to 1095B Portal.
   */
  redirectTo1095Portal = () => {
    try {
      window.open(this.label.ssp1095BLink, "_blank");
    } catch (error) {
      console.error("Error Redirecting to 1095B Portal", error);
    }
  };

  /**
   *
   * @function - callDCBSOfficeTelephone()
   * @description - method to call DCBS office telephone number.
   */
  callDCBSOfficeTelephone = () => {
    try {
      const phoneNumberHiddenLink = this.template.querySelector(
        ".ssp-phone_number"
      );
      phoneNumberHiddenLink.click();
    } catch (error) {
      console.error("Error Calling DCBS Office Telephone", error);
    }
  };

  /**
   *
   * @function - redirectToApplyBenefit
   * @description - method to redirect Apply for benefits screen.
   */

  redirectToApplyBenefit = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",

        attributes: {
          name: constants.homePageConstants.applyBenefitPageName
        }
      });
    } catch (error) {
      console.error("Error calling redirectToApplyBenefit: ", error);
    }
  };

  /**
   *
   * @function - redirectToSNAP
   * @description - method to redirect SNAP/Food Assistance.
   */

  redirectToSNAP = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.homePageConstants.programPage
        },
        state: {
          program: constants.homePageConstants.snapSection
        }
      });
    } catch (error) {
      console.error("Error calling redirectToSNAP: ", error);
    }
  };

  /**
   *
   * @function - redirectToKTAP
   * @description - method to redirect KTAP/Financial Assistance.
   */

  redirectToKTAP = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.homePageConstants.programPage
        },
        state: {
          program: constants.homePageConstants.KTAPSection
        }
      });
    } catch (error) {
      console.error("Error calling redirectToKTAP: ", error);
    }
  };

  /**
   *
   * @function - redirectToMedicaid
   * @description - method to redirect Health Assistance/Medicaid.
   */

  redirectToMedicaid = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.homePageConstants.programPage
        },
        state: {
          program: constants.homePageConstants.medicaidSection
        }
      });
    } catch (error) {
      console.error("Error calling redirectToMedicaid: ", error);
    }
  };

  /**
   *
   * @function - redirectToKHIPP
   * @description - method to redirect KHIPP/Premium Assistance.
   */

  redirectToKHIPP = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.homePageConstants.programPage
        },
        state: {
          program: constants.homePageConstants.KHIPPSection
        }
      });
    } catch (error) {
      console.error("Error calling redirectToKHIPP: ", error);
    }
  };

  /**
   *
   * @function - redirectToChildAssistance
   * @description - method to redirect Child Assistance.
   */

  redirectToChildAssistance = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.homePageConstants.programPage
        },
        state: {
          program: constants.homePageConstants.childCareSection
        }
      });
    } catch (error) {
      console.error("Error calling redirectToChildAssistance: ", error);
    }
  };

  /**
   *
   * @function - redirectToDCBS
   * @description - method to redirect DCBS Office.
   */

  redirectToDCBS = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "google_map__c"
        }
      });
    } catch (error) {
      console.error("Error calling redirectToDCBS: ", error);
    }
  };

   /**
     * @function - navigateToCitizenLoginPage
     * @description - Method is used to navigate to citizen KOG Login page.
     * @param {e} e - Gets current value.
     * @author : Kommana Lova Durga Prasad
     */
    navigateToCitizenLoginPage = (e) => {
      try {
        e.preventDefault();
        this.selectedRole = "Citizen";
          sspGetLoginURL({
            selectedRole : this.selectedRole
          })
              .then(result => {
                  if("KogRegistrationURL" in result.mapResponse){
                  window.open(result.mapResponse.KogRegistrationURL,"_self");
                  }
              })
              .catch(error => {
                  console.error(
                      "failed in renderedCallback in header" +
                          JSON.stringify(error)
                  );
              });
      } catch (error) {
          console.error(
              "failed in handleNavigation in header" + JSON.stringify(error)
          );
      }
  };

   /**
     * @function - navigateToIARLoginPage
     * @description - Method is used to navigate to Individual Authorized Representative KOG Login page.
     * @author : Kommana Lova Durga Prasad
     */
    navigateToIARLoginPage = () => {
      try {
        this.selectedRole = "INDIVIDUAL AUTHORIZED REPRESENTATIVE";
          sspGetLoginURL({
            selectedRole : this.selectedRole
          })
              .then(result => {
                if("KogRegistrationURL" in result.mapResponse){
                  window.open(result.mapResponse.KogRegistrationURL,"_self");
                  }
              })
              .catch(error => {
                  console.error(
                      "failed in renderedCallback in header" +
                          JSON.stringify(error)
                  );
              });
      } catch (error) {
          console.error(
              "failed in handleNavigation in header" + JSON.stringify(error)
          );
      }
  };
  
  /**
     * @function - navigateToPsToolPage
     * @description - Method is used to navigate to Prescreening Tool Page.
     * @author : Narapa 
     */

  navigateToPsToolPage () {
    {
      this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
        attributes: {
          name: constants.communityPageNames.prescreeening
        },
        state: {
                    retPage: "Home"
        }
      });
    }
  }
    /**
     * @function - navigateHealthBenefits
     * @description - Method is used to navigate to Health Benefit Exchange Website.
     */
    navigateHealthBenefits () {
        window.open(constants.url.healthBenefitExchange, "_blank");
    }
  
  /*for defect fix 380499 by Gunjyot Walia, changed by Nikhil for 396947*/
  handleBackyardNavigation (){
    
        window.open(this.label.sspKynectLandingPageURL,"_blank");
}

}