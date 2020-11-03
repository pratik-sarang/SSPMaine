/*
 * Component Name: SspAuthRepNextStepUpdates.
 * Author: Kyathi Kanumuri .
 * Description:  To Show Next step for Reps Assisters.
 * Date: 6/10/20209.
 */
import { LightningElement, track, api } from "lwc";
import sspNoAppPermissionText1 from "@salesforce/label/c.SSP_NoAppPermissionText1";
import sspNoAppPermissionText2 from "@salesforce/label/c.SSP_NoAppPermissionText2";
import sspNoAppPermissionText3 from "@salesforce/label/c.SSP_NoAppPermissionText3";
import sspNoCasePermissionText1 from "@salesforce/label/c.SSP_NoCasePermissionText1";
import sspNoCasePermissionText2 from "@salesforce/label/c.SSP_NoCasePermissionText2";
import sspNoCaseAccessText1 from "@salesforce/label/c.SSP_NoCaseAccessText1";
import sspNoCaseAccessText2 from "@salesforce/label/c.SSP_NoCaseAccessText2";
import sspNoCaseAccessText3 from "@salesforce/label/c.SSP_NoCaseAccessText3";
import sspMapAddress from "@salesforce/label/c.SSP_MapAddress";
import sspMapLink from "@salesforce/label/c.SSP_MapLink";
import sspNoCaseAccessText4 from "@salesforce/label/c.SSP_NoCaseAccessText4";
import sspNoCaseAccessText5 from "@salesforce/label/c.SSP_NoCaseAccessText5";
import sspNoCaseAccessText6 from "@salesforce/label/c.SSP_NoCaseAccessText6";
import sspNoCaseAccessText7 from "@salesforce/label/c.SSP_NoCaseAccessText7";
import sspNoCaseAccessText8 from "@salesforce/label/c.SSP_NoCaseAccessText8";
import sspNoCaseAccessText9 from "@salesforce/label/c.SSP_NoCaseAccessText9";
import sspNoCaseAccessText10 from "@salesforce/label/c.SSP_NoCaseAccessText10";
import sspIndividualKnownText1 from "@salesforce/label/c.SSP_IndividualKnownText1";
import sspAuthRequestReceivedText1 from "@salesforce/label/c.SSP_AuthRequestReceivedText1";
import sspAuthRequestReceivedText2 from "@salesforce/label/c.SSP_AuthRequestReceivedText2";
import sspAuthRequestReceivedText3 from "@salesforce/label/c.SSP_AuthRequestReceivedText3";
import sspIndividualNotKnownText1 from "@salesforce/label/c.SSP_IndividualNotKnownText1";
import sspAuthAlreadyHasAccess from "@salesforce/label/c.SSP_AuthAlreadyHasAccess";
import sspAlreadyRequestedAccessText1 from "@salesforce/label/c.SSP_AlreadyRequestedAccessText1";
import sspAlreadyRequestedAccessText2 from "@salesforce/label/c.SSP_AlreadyRequestedAccessText2";
import sspAuthRequestNotProcessedText1 from "@salesforce/label/c.SSP_AuthRequestNotProcessedText1";
import sspAuthRequestNotProcessedText2 from "@salesforce/label/c.SSP_AuthRequestNotProcessedText2";
import sspReturnToDCBS from "@salesforce/label/c.SSP_ReturnToDCBS";
import sspContactRegardingAuthApplication from "@salesforce/label/c.SSP_ContactRegardingAuthApplication";
import sspAlternativelyCallDCBS from "@salesforce/label/c.SSP_AlternativelyCallDCBS";
import sspAuthNotGivenAccessText1 from "@salesforce/label/c.SSP_AuthNotGivenAccessText1";
import sspAuthNotGivenAccessText2 from "@salesforce/label/c.SSP_AuthNotGivenAccessText2";
import sspAuthMayNotCompleteApplicationText1 from "@salesforce/label/c.SSP_AuthMayNotCompleteApplicationText1";
import sspAuthMayNotCompleteApplicationText2 from "@salesforce/label/c.SSP_AuthMayNotCompleteApplicationText2";
import nextStep from "@salesforce/label/c.SSP_NextStep";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import goDashboard from "@salesforce/label/c.SSP_GoDashboard";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import { NavigationMixin } from "lightning/navigation";
import { url,navigationUrl } from "c/sspConstants";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";
import sspMAPLinkTitle from "@salesforce/label/c.SSP_MAPLinkTitle";
import sspFullConsentGiven from "@salesforce/label/c.SSP_FullConsentGiven";
import getCurrentLoggedInUserLang from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.getCurrentLoggedInUserLang";
import updateApplicationBlocked from "@salesforce/apex/SSP_AssisterRequestAccessCtrl.updateApplicationBlocked";
import sspUtility from "c/sspUtility";

export default class SspAuthRepNextStepUpdates extends  NavigationMixin(LightningElement) {
    @api authFullMatchNoProgramAccess = false;
    @api authFullMatchSentNotification = false;
    @api clientNoCommunicationPref = false;
    @api anyProgramNoCommunicationPref = false;
    @api authRequestNonMedicaidAccess = false;
    @api authRequestPartialMatch = false;
    @api authNoMatchSentNotification = false;
    @api noCaseMatch = false;
    @api authAssisterHaveAccess =false;
    @api accessPendingRequest = false;
    @api medicaidProgramRequestNoMatchOrInactive = false;
    @api anyProgramRequestNoMatchOrInactive = false;
    @api nonMedicaidRequestNoMatchOrInactive = false;
    @api clientRejectedApplication = false;
    @api consentNotFullyGiven = false;
    @api consentFullyGiven = false;
    @track trueValue = true;
    @track showSpinner = false;
    @track userLanguage;
    @track error;
    @track mapURLLink = sspMapAddress;
    @track applicationId;
    label = {
        sspFullConsentGiven,
        sspMAPLinkTitle,
        sspRequestAccess,
        goDashboard,
        nextStep,
        benefitsApplication,
        sspNoAppPermissionText1,
        sspNoAppPermissionText2,
        sspNoAppPermissionText3,
        sspNoCasePermissionText1,
        sspNoCasePermissionText2,
        sspNoCaseAccessText1,
        sspNoCaseAccessText2,
        sspNoCaseAccessText3,
        sspMapAddress,
        sspMapLink,
        sspNoCaseAccessText4,
        sspNoCaseAccessText5,
        sspNoCaseAccessText6,
        sspNoCaseAccessText7,
        sspNoCaseAccessText8,
        sspNoCaseAccessText9,
        sspNoCaseAccessText10,
        sspIndividualKnownText1,
        sspAuthRequestReceivedText1,
        sspAuthRequestReceivedText2,
        sspAuthRequestReceivedText3,
        sspIndividualNotKnownText1,
        sspAuthAlreadyHasAccess,
        sspAlreadyRequestedAccessText1,
        sspAlreadyRequestedAccessText2,
        sspAuthRequestNotProcessedText1,
        sspAuthRequestNotProcessedText2,
        sspReturnToDCBS,
        sspContactRegardingAuthApplication,
        sspAlternativelyCallDCBS,
        sspAuthNotGivenAccessText1,
        sspAuthNotGivenAccessText2,
        sspAuthMayNotCompleteApplicationText1,
        sspAuthMayNotCompleteApplicationText2
    };
    backgroundImg = sspIcons + url.mobileBackgroundImage;
    desktopBackgroundImg = sspIcons + url.desktopBackgroundImage;
    /**
     * @function : navigateToDashboard
     *  * @description : This method used to navigate to different pages.
     */
    navigateToDashboard () {
        try {
            this.showSpinner = true;
            if(!sspUtility.isUndefinedOrNull(this.applicationId)){
                updateApplicationBlocked({
                    applicationId: this.applicationId
                })
                    .then(result => {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url:
                    apConstants.url.home
                }
            });
                    })
                    .catch({
                    }); 
            }  
            else{
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url:
                            apConstants.url.home
                    }
                });
            }
        } catch (error) {
            console.error("Error in navigationFunction", error);
        }
    }
    /**
     * @function : connectedCallback.
     * @description : This method used to get the current logged in user language.
     */
    connectedCallback (){
        const sPageURL = decodeURIComponent(
            window.location.search.substring(1)
        );
        const sURLVariables = sPageURL.split("&");
        if (sURLVariables != null && sURLVariables != "") {
            for (let i = 0; i < sURLVariables.length; i++) {
                const sParam = sURLVariables[i].split("=");
                if (sParam[0] === "applicationId") {
                    this.applicationId =
                        sParam[1] === undefined ? "Not found" : sParam[1];                    
                }
                if (sParam[0] === "noCaseMatch") {
                    this.authFullMatchNoProgramAccess = sParam[1];                    
                }
                if (sParam[0] === "authRequestPartialMatch") {
                    if(sParam[1] === "true"){
                        this.authRequestPartialMatch = sParam[1];
                        this.authFullMatchNoProgramAccess = false;
                    }
                }  
            }
        }
        getCurrentLoggedInUserLang({})
        .then(result => {
            this.userLanguage=result;
            if(this.userLanguage === "es_US"){
                this.mapURLLink = navigationUrl.assisterMapLinkSpanish;
            }
            //Start-Added as part of Defect-391591
            if (this.noCaseMatch) {
                this.updateApplicationBlockedMethod();
            }
            //End-Added as part of Defect-391591
        })
        .catch(error => {
            this.error = error;
            console.error("error in" + " " + JSON.stringify(this.error));
        });
    }

    //Start-Added as part of Defect-391591
    /**
     * @function : updateApplicationBlockedMethod.
     * @description : This method used to set Application status as Blocked.
     */
    updateApplicationBlockedMethod = () => {
        if(!sspUtility.isUndefinedOrNull(this.applicationId)) {
            updateApplicationBlocked({
                applicationId: this.applicationId
            }).then(result => {
                if(!result.bIsSuccess) {
                    console.error("Error occurred in updateApplicationBlockedMethod of Next Step Update page" +result.mapResponse.ERROR);
            }
        })
        .catch({});
        }
    }
    //End-Added as part of Defect-391591
}