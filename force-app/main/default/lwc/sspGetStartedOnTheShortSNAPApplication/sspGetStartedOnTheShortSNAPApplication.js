/**
 * Component Name: sspGetStartedBenefitsApplication.
 * Author: Chirag ,Sharon, Shivam.
 * Description: This component creates a screen for Get Started on the Benefits Application.
 * Date: 07/04/2020.
 */
import { track } from "lwc";
import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspUtility from "c/sspUtility";
import pageUrl from "@salesforce/resourceUrl/captchaDemo";
import sspSNAPGetStartedHeading from "@salesforce/label/c.SSP_SNAPGetStartedHeading";
import sspSNAPGetStartedCompleteHeading from "@salesforce/label/c.SSP_SNAPGetStartedCompleteHeading";
import sspSNAPGetStartedCompleteContent from "@salesforce/label/c.SSP_SNAPGetStartedCompleteContent";
import sspSNAPGetStartedScheduleInterview from "@salesforce/label/c.SSP_SNAPGetStartedScheduleInterview";
import sspStartSNAPGetStartedScheduleContent from "@salesforce/label/c.SSP_SNAPGetStartedScheduleContent";
import sspSNAPGetStartedPrepareHeading from "@salesforce/label/c.SSP_SNAPGetStartedPrepareHeading";
import sspSNAPGetStartedPrepareContent from "@salesforce/label/c.SSP_SNAPGetStartedPrepareContent";
import sspSNAPGetStartedWarning from "@salesforce/label/c.SSP_SNAPGetStartedWarning";
import sspSNAPGetStartedStartButton from "@salesforce/label/c.SSP_SNAPGetStartedStartButton";
import sspSNAPGetStartedStartAlt from "@salesforce/label/c.SSP_SNAPGetStartedStartAlt";
import sspSNAPGetStartedExitAlt from "@salesforce/label/c.SSP_SNAPGetStartedExitAlt";
import sspSNAPGetStartedExitButton from "@salesforce/label/c.SSP_SNAPGetStartedExitButton";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import { url } from "c/sspConstants";
import sspIconsCd2 from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspSignaturePageTermOne from "@salesforce/label/c.SSP_SignaturePageTermOne";
import sspSignaturePageTermTwo from "@salesforce/label/c.SSP_SignaturePageTermTwo";
import sspSignaturePageTermThree from "@salesforce/label/c.SSP_SignaturePageTermThree";

export default class SspGetStartedOnTheShortSNAPApplication extends NavigationMixin(
    sspUtility
) {
    @track vFPage = pageUrl;
    @track isButtonDisabled = true;

    bottomBannerSectionImage =
        sspIcons + constants.url.renewalApplicationBackgroundImage;

    bluePolygon = sspIconsCd2 + url.bluePolygon;
    purplePolygon = sspIconsCd2 + url.purplePolygon;
    yellowPolygon = sspIconsCd2 + url.yellowPolygon;

    label = {
        sspSNAPGetStartedHeading,
        sspSNAPGetStartedCompleteHeading,
        sspSNAPGetStartedCompleteContent,
        sspSNAPGetStartedScheduleInterview,
        sspStartSNAPGetStartedScheduleContent,
        sspSNAPGetStartedPrepareHeading,
        sspSNAPGetStartedPrepareContent,
        sspSNAPGetStartedWarning,
        sspSNAPGetStartedStartButton,
        sspSNAPGetStartedStartAlt,
        sspSNAPGetStartedExitAlt,
        sspSNAPGetStartedExitButton,
        sspSignaturePageTermOne,
        sspSignaturePageTermTwo,
        sspSignaturePageTermThree
    };
    desktopBackgroundImg = sspIcons + url.desktopBackgroundImage;

    connectedCallback () {
        try {
            if (window.addEventListener) {
                window.addEventListener("message", this.handleCallback.bind(this));
            } else {
                window.attachEvent("onmessage", this.listenMessage);
            }
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    handleCallback = evt => {
        try {
            const frameReference = this.template.querySelector(".ssp-getBenefitCaptcha");
            if (evt.data === constants.shortSNAPFlowConstants.Unlock) {
                this.isButtonDisabled = false;
                frameReference.style.zIndex = 0;
            } else if (evt.data === constants.shortSNAPFlowConstants.Expired) {
                this.isButtonDisabled = true;
                frameReference.style.zIndex = 9;
            } else if (evt.data === constants.shortSNAPFlowConstants.Loaded) {
                //Nothing to handle
            }
        } catch (error) {
            console.error("Error in handleCallback:", error);
        }
    };

    HandleGetStarted = () => {
        try {
            // Navigate to a Get Started Page URL
            this[NavigationMixin.Navigate](
                {
                    type: "standard__webPage",
                    attributes: {
                        url: constants.shortSNAPFlowConstants.nextPageURL
                    }
                },
                true
            );
        } catch (error) {
            console.error("Error in HandleGetStarted:", error);
        }
    };

    handleExit = () => {
        try {
            // Navigate to a Program Selection Page URL
            this[NavigationMixin.Navigate](
                {
                    type: "standard__webPage",
                    attributes: {
                        url:
                            constants.shortSNAPFlowConstants.programSelectionPageURL
                    }
                },
                true
            );
        } catch (error) {
            console.error("Error in handleExit:", error);
        }
    };
}