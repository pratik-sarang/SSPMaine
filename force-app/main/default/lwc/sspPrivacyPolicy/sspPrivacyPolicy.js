/**
 * Name : SspPrivacyPolicy.
 * Description : Brief Description about Lightning Web Component.
 * Author : Saurabh Rathi.
 * Date : 16/02/2020.
 * MODIFICATION LOG:.
 * DEVELOPER DATE DESCRIPTION.
 * DeveloperName   MM/DD/YYYY   A Brief Description about the Change.
 **/
import { track, api } from "lwc";
import utility from "c/sspUtility";

import copyRightAgent from "@salesforce/label/c.SSP_CopyRightAgent";
import privacyPolicyHeading from "@salesforce/label/c.SSP_PrivacyPolicyHeading";
import WebsiteLinkText from "@salesforce/label/c.SSP_KentuckyWebsiteText";
import copyrightInquiriesText from "@salesforce/label/c.SSP_CopyrightInquiriesText";
import emailText from "@salesforce/label/c.SSP_EmailText";


export default class SspPrivacyPolicy extends utility {
    WebsiteLink = "https://kentucky.gov/Pages/home.aspx";
    emailLink = `mailto:${copyRightAgent}`;
    label = {
        privacyPolicyHeading,
        WebsiteLinkText,
        copyRightAgent,
        copyrightInquiriesText,
        emailText
    };
    
    @track sectionObject = [];

    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            this.sectionObject = value.mapResponse.helpContent;
            this.sectionObject = this.sectionObject
                .map(item => {
                item.idHash = `#${item.Id}`;
                   
                return item;
                })
                .sort((a, b) => a.Order__c - b.Order__c);
        }
    }

    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
     */
    connectedCallback () {
        try {
            this.showHelpContentData("Privacy Policy");
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }

    /**
     * @function : renderedCallback
     * @description : This method is called when html is attached to the component.
     */
    renderedCallback () {
        try {
            const sectionReference = Array.from(
                this.template.querySelectorAll(".ssp-policySection p")
            );
            if (sectionReference) {
                sectionReference.forEach((currentSection, index) => {
                    // eslint-disable-next-line @lwc/lwc/no-inner-html
                    currentSection.innerHTML = this.sectionObject[
                        index
                    ].HelpModal__c;
                });
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function : ScrollFunction
     * @description : This method is used to scroll to the top.
     */
    ScrollFunction () {
        try {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            console.error("Error in ScrollFunction", error);
        }
    }
}