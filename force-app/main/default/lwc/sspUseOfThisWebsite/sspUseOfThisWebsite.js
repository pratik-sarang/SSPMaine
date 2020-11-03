import { LightningElement, track, api } from "lwc";
import sspPrivacyPolicyLink from "@salesforce/label/c.SSP_PrivacyPolicyLink";
import sspYesAccept from "@salesforce/label/c.sspYesAccept";
import sspFonts from "@salesforce/resourceUrl/SSP_FONTSNEW";
import sspNoReject from "@salesforce/label/c.sspNoReject";
import { loadStyle } from "lightning/platformResourceLoader";

import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from "lightning/flowSupport";
import sspUtility from "c/sspUtility";

export default class SspUseOfThisWebsite extends LightningElement {
    @api userAgreementHeader;
    @api userAgreementText;
    @api availableActions = [];
    @api forceLogout = false;
    @api initiateLogout;

    @track openModal = false;
    @track splitTextList = [];

    labels = {
        sspPrivacyPolicyLink,
        sspYesAccept,
        sspNoReject
    };

    loadExternalStyles () {
        Promise.all([loadStyle(this, sspFonts + "/SSP_FONTS.css")]);
    }
    connectedCallback () {


        if (!sspUtility.isUndefinedOrNull(this.userAgreementText)) {
            this.splitTextList = this.userAgreementText.split("<br>");
          
        }
        this.loadExternalStyles();
    }
    openOverlay () {
        this.openModal = true;
    }
    handleProp () {
        this.openModal = false;
    }

    handleAcceptClick = () => {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === "NEXT")) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    };

    handleRejectClick = () => {
        try {
            //notify the flow of the change in variable
            this.forceLogout = true;
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                "forceLogout",
                this.forceLogout
            );
            this.dispatchEvent(attributeChangeEvent);

        
            // check if NEXT is allowed on this screen
            if (this.availableActions.find(action => action === "NEXT")) {
                // navigate to the next screen
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }

        } catch (error) {
            console.error("Error occurred::: ", error);
        }
    };
}