import { LightningElement, track, api } from "lwc";
import sspWaiverResultsHeading from "@salesforce/label/c.SSP_WaiverResultsHeading";
import sspWaiverQuestionsApply from "@salesforce/label/c.SSP_WaiverQuestionsApply";
import { NavigationMixin } from "lightning/navigation";
import sspWaiverResultsContent from "@salesforce/label/c.SSP_WaiverResultsContent";
import sspWaiverResultsPhone from "@salesforce/label/c.sspWaiverResultsPhone";
import sspWaiverResultsContent2 from "@salesforce/label/c.SSP_WaiverResultsContent2";

import sspWaiverResultButton from "@salesforce/label/c.SSP_WaiverResultButton";
import sspWaiverResultButtonTitle from "@salesforce/label/c.SSP_WaiverResultButtonTitle";
import sspWaiverResultConditionHeading from "@salesforce/label/c.SSP_WaiverResultConditionHeading";
import sspWaiverResultConditionContent from "@salesforce/label/c.SSP_WaiverResultConditionContent";
import sspWaiverResultContinueButton from "@salesforce/label/c.SSP_WaiverResultContinueButton";
import sspWaiverResultExitButton from "@salesforce/label/c.SSP_WaiverResultExitButton";
import sspWaiverResultContinueTitle from "@salesforce/label/c.SSP_WaiverResultContinueTitle";
import sspWaiverResultExitTitle from "@salesforce/label/c.SSP_WaiverResultExitTitle";
import triggerWaiverTokenGeneration from "@salesforce/apex/SSP_WaiverController.triggerWaiverTokenGeneration";
import sspUtility,{ formatLabels } from "c/sspUtility";

export default class SspWaiverScreeningResults extends NavigationMixin(LightningElement) {
    label= {
        sspWaiverQuestionsApply,
        sspWaiverResultsHeading,
        sspWaiverResultsContent,
        sspWaiverResultButton,
        sspWaiverResultButtonTitle,
        sspWaiverResultConditionHeading,
        sspWaiverResultConditionContent,
        sspWaiverResultContinueButton,
        sspWaiverResultExitButton,
        sspWaiverResultContinueTitle,
        sspWaiverResultExitTitle,
        sspWaiverResultsContent2,
        sspWaiverResultsPhone
    };
    @track doesNotMeetRequirement = false;
    @track meetRequirement = false;
    @api allAnsweredNo=false;
    @api caseNumber="1234";
    @api individualId="";      
    @api contactName = "Test first"; 
    @track showSpinner =false;

    @track phoneNumber = "tel:" + sspWaiverResultsPhone;

    /**
     * @function 		: connectedCallback.
     * @description 	: this method is handle labels.    
     * */
    connectedCallback () {
       
        if(this.allAnsweredNo === true){
            this.doesNotMeetRequirement = true;
        }else{
            this.meetRequirement = true;
        }
        Object.keys(this.label).forEach(labelKey => {
            this.label[labelKey] = formatLabels(
                this.label[labelKey],
                [this.contactName]
            );
        });
    }
     /**
     * @function - handleNavigation
     * @description - Method is used to navigate to other pages.
     * @param {*}event - Fired on selection of option.
     */
    handleNavigation = event => {
        try {
            const selectedPage = event.currentTarget.getAttribute("data-page");
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: selectedPage
                }
            });
            this.closeSideNav();
        } catch (error) {
            console.error(
                "failed in handleNavigation in header" + JSON.stringify(error)
            );
        }
    };
    handleContinueWaiver (){
        this.showSpinner = true;
        let waiverURL;
        triggerWaiverTokenGeneration({
            caseNumber: this.caseNumber,
            IndividualId: this.individualId,
            Name: this.contactName,
            targetWidget: "APP_004"     //Added by Shivam for 12.4.2 related changes.
        }).then(result => {                   
            const parsedData = result.mapResponse;  
           
            if (
                !sspUtility.isUndefinedOrNull(parsedData) &&
                parsedData.hasOwnProperty("ERROR")
            ) {
                this.errorCode = parsedData.ERROR;
                this.showErrorModal = true;                       
               
            } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                if (parsedData.hasOwnProperty("tokenId" )) {
                    waiverURL = parsedData.tokenId;
                }
                
          
            if(waiverURL !== undefined && waiverURL !== null && waiverURL !== ""){
                  //  window.open(waiverURL);
                    window.open(waiverURL,"_self"); //for defect 393009
            }
            this.showSpinner = false;
        }
            
        });
    }
    
}