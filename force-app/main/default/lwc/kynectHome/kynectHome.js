/*
 * Component Name: KynectHome.
 * Author: Narapa
 * Description: Component for HomePage of Kynect Community           
 * Date: 09/02/2020.
 * Task : 390945
 */
import { LightningElement, track } from "lwc";
import kynectHomePageAssets from "@salesforce/resourceUrl/kynectHomePageAssets";
import rightArrow from "@salesforce/resourceUrl/rightArrow";
import kynectLMSVideoUrl from "@salesforce/label/c.kynectLMSVideoUrl";
import kynectLearnAboutResourcesAndBenefits from "@salesforce/label/c.kynectLearnAboutResourcesAndBenefits";
import kynectWayToKynect from "@salesforce/label/c.kynectWayToKynect";
import kynectGoodNewsKynectIsBack from "@salesforce/label/c.kynectGoodNewsKynectIsBack";
import kynectHealthCoverage from "@salesforce/label/c.kynectHealthCoverage";
import kynectBenefits from "@salesforce/label/c.kynectBenefits";
import kynectResources from "@salesforce/label/c.kynectResources";
import kynectGotAnswers from "@salesforce/label/c.kynectGotAnswers";
import kynectGotQuestions from "@salesforce/label/c.kynectGotQuestions";
import kynectOurFriendlyHelpfulKynectors from "@salesforce/label/c.kynectOurFriendlyHelpfulKynectors";
import kynectQuestionsPhoneNo from "@salesforce/label/c.kynectQuestionsPhNo";
import kynectHealthCoverageUrl from "@salesforce/label/c.kynectHealthCoverageUrl";
import kynectBenefitsUrl from "@salesforce/label/c.kynectBenefitsUrl";
import kynectResourcesUrl from "@salesforce/label/c.kynectResourcesUrl";
import kynectGetCovered from "@salesforce/label/c.kynectGetCovered";
import kynectGetMore from "@salesforce/label/c.kynectGetMore";
import kynectGetBenefits from "@salesforce/label/c.kynectGetBenefits";
import kynectGetHelp from "@salesforce/label/c.kynectGetHelp";
import kynectGetCoveredAlt from "@salesforce/label/c.kynectGetCoveredAlt";
import kynectGetMoreAlt from "@salesforce/label/c.kynectGetMoreAlt";
import kynectGetHelpAlt from "@salesforce/label/c.kynectGetHelpAlt";
import sspFooterTelephoneHREF from "@salesforce/label/c.SSP_FooterTelephoneHREF";
import kynectHealthCoverageContent from "@salesforce/label/c.kynectHealthCoverageContent";
import kynectBenefitsContent from "@salesforce/label/c.kynectBenefitsContent";
import kynectResourcesCardContent from "@salesforce/label/c.kynectResourcesCardContent";
import kynectIsBack from "@salesforce/label/c.kynectIsBack";
import kynectBroughtBackup from "@salesforce/label/c.kynectBroughtBackup";
import kynectHomeBannerMsg1Text from "@salesforce/label/c.kynectHomeBannerMsg1Text";
import kynectHomeBannerMsg1Link from "@salesforce/label/c.kynectHomeBannerMsg1Link";
import kynectHomeBannerMsg1LinkTitle from "@salesforce/label/c.kynectHomeBannerMsg1LinkTitle";
import kynectBaloonMedicaidChildrenCoverage from "@salesforce/label/c.kynectBaloonMedicaidChildrenCoverage";
import kynectBaloonPremiumAssistance from "@salesforce/label/c.kynectBaloonPremiumAssistance";
import kynectBaloonQualifiedHealthPlans from "@salesforce/label/c.kynectBaloonQualifiedHealthPlans";
import kynectBaloonFindKynectors from "@salesforce/label/c.kynectBaloonFindKynectors";
import kynectBaloonCOVID19TimeLimitedCoverage from "@salesforce/label/c.kynectBaloonCOVID19TimeLimitedCoverage";
import kynectBaloonMedicaidChildrenCoverageLink from "@salesforce/label/c.kynectBaloonMedicaidChildrenCoverageLink";
import kynectBaloonPremiumAssistanceLink from "@salesforce/label/c.kynectBaloonPremiumAssistanceLink";
import kynectBaloonQualifiedHealthPlansLink from "@salesforce/label/c.kynectBaloonQualifiedHealthPlansLink";
import kynectBaloonCOVID19TimeLimitedCoverageLink from "@salesforce/label/c.kynectBaloonCOVID19TimeLimitedCoverageLink";
import kynectBaloonFindKynectorsLink from "@salesforce/label/c.kynectBaloonFindKynectorsLink";



export default class KynectHome extends LightningElement {

    customLabels = {
        kynectBaloonMedicaidChildrenCoverage,
        kynectBaloonPremiumAssistance,
        kynectBaloonQualifiedHealthPlans,
        kynectBaloonFindKynectors,
        kynectBaloonCOVID19TimeLimitedCoverage,
        kynectBaloonMedicaidChildrenCoverageLink,
        kynectBaloonPremiumAssistanceLink,
        kynectBaloonQualifiedHealthPlansLink,
        kynectBaloonCOVID19TimeLimitedCoverageLink,
        kynectBaloonFindKynectorsLink,
        kynectLMSVideoUrl,
        kynectLearnAboutResourcesAndBenefits,
        kynectWayToKynect,
        kynectGoodNewsKynectIsBack,
        kynectHealthCoverage,
        kynectBenefits,
        kynectResources,
        kynectGotAnswers,
        kynectGotQuestions,
        kynectOurFriendlyHelpfulKynectors,
        kynectQuestionsPhoneNo,
        kynectHealthCoverageUrl,
        kynectBenefitsUrl,
        kynectResourcesUrl,
        kynectGetCovered,
        kynectGetMore,
        kynectGetHelp,
        kynectGetCoveredAlt,
        kynectGetMoreAlt,
        kynectGetHelpAlt,
        sspFooterTelephoneHREF,
        kynectHealthCoverageContent,
        kynectBenefitsContent,
        kynectResourcesCardContent,
        kynectGetBenefits,
        kynectIsBack,
        kynectBroughtBackup,
        kynectHomeBannerMsg1Text,
        kynectHomeBannerMsg1Link,
        kynectHomeBannerMsg1LinkTitle
    }

    get showNotificationBanner () {
        if (this.customLabels.kynectHomeBannerMsg1Text !== "N/A" && this.customLabels.kynectHomeBannerMsg1LinkTitle !== "N/A") {
           return true
        }
        return false;
   }

   benefitsArrowHover = () => {
       this.template.querySelector(".benefits-arrow").src = rightArrow;
   }

   resourceArrowHover = () =>{
       this.template.querySelector(".resource-arrow").src = rightArrow;
   }

   benefitsArrowHoverOut = () =>{
       this.template.querySelector(".benefits-arrow").src = this.arrow;
   }

   resourceArrowHoverOut = () =>{
       this.template.querySelector(".resource-arrow").src = this.arrow;
   }

    @track
    bannerOne = kynectHomePageAssets + "/banner1_mobile.png";

    @track
    blueBalloon = kynectHomePageAssets + "/baloon_blue.png";

    @track
    purpleBalloon = kynectHomePageAssets + "/baloon_purple.png";

    @track
    greenBalloon = kynectHomePageAssets + "/baloon_green.png";

    @track
    arrow = kynectHomePageAssets + "/rightArrow.png";
    
    @track peopleImage = kynectHomePageAssets + "/banner2.png";
    
    @track kynectContactNumber =
        this.customLabels.sspFooterTelephoneHREF + this.customLabels.kynectQuestionsPhoneNo;
    
   
}