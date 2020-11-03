/*
 * Component Name: JsonEligResultCard
 * Author: Narapa 
 * Description: Component to generate the results to the programs within jsonFormRichText
 * Date: 05/27/2020.
 */
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class JsonEligResultCard extends NavigationMixin(
    LightningElement
) {
    @api title;
    @api pgmInfo;
    @api eligResult;
    @api 
    customLabels;
    @api hasButton;
    @track eligMsg;
    @track resultCss;
    @api btnLabel;
    @api variant;
    @api btnTitle;
    @api gotoPageType;
    @api gotoUrl;

    connectedCallback (){
        if (this.eligResult) {
            let msg;
            //Based on the eligResult attribute setting the value from the customLabels
            switch (this.eligResult) {
                case "Eligible":
                    msg = "sspPotentiallyEligible";
                    break;
    
                case "NeedMoreInfo":
                    msg = "sspNeedMoreInfo";
                    break;
            
                default:
                    break;
            }
            this.eligMsg = this.customLabels[msg];
        }   
    }

    get btnClass () {
        let btnStyle = "ssp-button_brand";
        if (this.variant === "neutral") {
            btnStyle = "ssp-button_neutral";
        }
        return btnStyle;
    }

    handleResultCardBtnClick () {
        if (this.gotoPageType === "standard__webPage") {
            // Navigate to a URL
            this[NavigationMixin.Navigate](
                {
                    type: this.gotoPageType,
                    attributes: {
                        url: this.gotoUrl
                    }
                },
                true // Replaces the current page in your browser history with the URL
            );
        }
    }
}