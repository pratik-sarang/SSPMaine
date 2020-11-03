import {  track, LightningElement } from "lwc";
import invokeWaiverCallOut from "@salesforce/apex/SSP_WaiverController.triggerWaiverScreening";
import getScreeningData from "@salesforce/apex/SSP_WaiverController.getWaiverScreeningDetails";
import checkIfIndividualApplicableForWaiver from "@salesforce/apex/SSP_WaiverController.checkIfIndividualApplicableForWaiver";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspWaiverQuestionsHeading from "@salesforce/label/c.SSP_WaiverQuestionsHeading";
import sspWaiverQuestionsContent from "@salesforce/label/c.SSP_WaiverQuestionsContent";
import sspWaiverQuestionOne from "@salesforce/label/c.SSP_WaiverQuestionOne";
import sspWaiverQuestionTwo from "@salesforce/label/c.SSP_WaiverQuestionTwo";
import sspWaiverQuestionThree from "@salesforce/label/c.SSP_WaiverQuestionThree";
import sspWaiverQuestionFour from "@salesforce/label/c.SSP_WaiverQuestionFour";
import sspWaiverQuestionFive from "@salesforce/label/c.SSP_WaiverQuestionFive";
import sspWaiverQuestionsApply from "@salesforce/label/c.SSP_WaiverQuestionsApply";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspWaiverQuestionsNextTitle from "@salesforce/label/c.SSP_WaiverQuestionsNextTitle";
import sspWaiverQuestionsCancelTitle from "@salesforce/label/c.SSP_WaiverQuestionsCancelTitle";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspWaiverQuestionsLearnTitle from "@salesforce/label/c.SSP_WaiverQuestionsLearnTitle";
import sspWaiverLearnMoreContent from "@salesforce/label/c.SSP_WaiverLearnMoreContent";
import sspLearnMoreContentTwo from "@salesforce/label/c.SSP_LearnMoreContentTwo";
import sspWaiverLearnHeading from "@salesforce/label/c.SSP_WaiverLearnHeading";
import SSPRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import constants from "c/sspConstants";
import sspUtility,{ formatLabels } from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";

export default class SspWaiverScreeningQuestions extends NavigationMixin(LightningElement) {
    label = {
        sspYes,
        sspNo,
        sspWaiverQuestionsHeading,
        sspWaiverQuestionsContent,
        sspWaiverQuestionOne,
        sspWaiverQuestionTwo,
        sspWaiverQuestionThree,
        sspWaiverQuestionFour,
        sspWaiverQuestionFive,
        sspCancel,
        sspNext,
        sspWaiverQuestionsApply,
        sspWaiverQuestionsNextTitle,
        sspWaiverQuestionsCancelTitle,
        sspLearnMoreLink,
        sspWaiverQuestionsLearnTitle,
        sspWaiverLearnMoreContent,
        sspLearnMoreContentTwo,
        sspWaiverLearnHeading,
        toastErrorText
    }
    @track responseOptions = [
        { label: this.label.sspYes, value: "Y" },
        { label: this.label.sspNo, value: "N" }
    ];
    @track isLearnMoreModal = false;
    @track reference = this;
    @track individualId = "";
    @track memberName = "";
    @track contactName = "";
    @track contactGender = "";
    @track caseNumber = "";
    @track showSpinner = true;
    @track showReceivingServicesError =false;
    @track showHasBrainInjuryError= false;
    @track showOnVentilatorError= false;
    @track showRequireAssistanceError= false;
    @track showHasDisabilityError= false;
    @track errorMessage=SSPRequiredErrorMessage;
    @track showErrorToast= false;
    @track showScreen= false;
    @track showAccessDenied= false;
    @track allAnsweredNo= false;
    @track disabled= false;
    @track showErrorModal= false;
    @track showResults= false;
    @track heOrSheLabel= "he";
    @track hisOrHerLabel= "his";
    @track errorCode= "";
    @track saveRecord = { 
        Id:"",
        [constants.waiverFields.IndividualId]:"",
        [constants.waiverFields.HasBrainInjury]: "",
        [constants.waiverFields.IsVentilatorDependent]: "",
        [constants.waiverFields.RequireAssistance]: "",
        [constants.waiverFields.HasDevelopmentalDisability]: "",
        [constants.waiverFields.WillContinueServices]: "",
        [constants.waiverFields.GenderCode__c]: "",
        [constants.waiverFields.WaiverScreeningId]: "",
        "IndividualName":"IndividualName"};


    get questionThreeLabel () {
        return formatLabels(
            this.label.sspWaiverQuestionThree,[this.contactName,this.hisOrHerLabel]
        );
    }

    get questionFiveLabel () {
        return formatLabels(
            this.label.sspWaiverQuestionFive, [this.contactName,this.heOrSheLabel, this.hisOrHerLabel]
        );
    }

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     */
    openLearnMoreModal () {
        try {
            this.isLearnMoreModal = true;
        } catch (error) {
            console.error("error");
        }
    }
      /**
     * @function 		: handleHideToast.
     * @description 	: this method is handle toast.    
     * */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal () {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error("error");
        }
    }
     /**
     * @function : closeError
     * @description	: Method to close error modal.
     */
    closeError = () =>{
        try {
        this.errorCode = "";
        this.showErrorModal = false;
        }catch (error) {
            console.error("error");
        }
    }
    /**
     * @function : handleNext
     * @description	: Method to Handle next button event.
     */
    handleNext (){     
        try{
        if(this.saveRecord.HasBrainInjury === "" 
        || sspUtility.isUndefinedOrNull(this.saveRecord.HasBrainInjury)){
            this.showHasBrainInjuryError =true;
        }else{
            this.showHasBrainInjuryError =false;  
        }
        if(this.saveRecord.IsVentilatorDependent=== ""
        || sspUtility.isUndefinedOrNull(this.saveRecord.IsVentilatorDependent)){
            this.showOnVentilatorError =true;
        }else{
            this.showOnVentilatorError =false;  
        }
        if(this.saveRecord.RequireAssistance === ""
        || sspUtility.isUndefinedOrNull(this.saveRecord.RequireAssistance)){
            this.showRequireAssistanceError =true;
        }else{
            this.showRequireAssistanceError =false;  
        }
        if(this.saveRecord.HasDevelopmentalDisability === ""
        || sspUtility.isUndefinedOrNull(this.saveRecord.HasDevelopmentalDisability)){
            this.showHasDisabilityError =true;
        }else{
            this.showHasDisabilityError =false;  
        }
        if(this.saveRecord.WillContinueServices === ""
        || sspUtility.isUndefinedOrNull(this.saveRecord.WillContinueServices)){
            this.showReceivingServicesError =true;
        }else{
            this.showReceivingServicesError =false;  
        }
        if(this.showHasBrainInjuryError || this.showHasDisabilityError || this.showOnVentilatorError
            || this.showReceivingServicesError || this.showRequireAssistanceError){
                this.showErrorToast = true;
            }else{
                this.showSpinner = true;
                if(this.saveRecord.HasBrainInjury === "N" && this.saveRecord.HasDevelopmentalDisability === "N" && this.saveRecord.IsVentilatorDependent === "N" &&
                this.saveRecord.WillContinueServices === "N" && this.saveRecord.RequireAssistance=== "N" ){
                        this.allAnsweredNo = true;
                     }
                this.showErrorToast =false;   
                delete  this.saveRecord.Name;   
                this.saveRecord.IndividualId = this.individualId;                          
                invokeWaiverCallOut({
                    contactJSON: JSON.stringify(this.saveRecord)                   
                }).then(result => {                   
                    const parsedData = result.mapResponse;  
                   
                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty("ERROR")
                    ) {
                        this.errorCode = parsedData.ERROR;
                        this.showErrorModal = true;                       
                       
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                       
                        this.showResults = true;
                        this.showScreen =false;
                    }
                    this.showSpinner = false;
                });
            }
        }catch (error) {
            console.error("error");
        }
    }
      /**
     * @function : handleBrainInjury
     * @description	: Method to Handle toggle response.
     * @param {*} event - On click of toggle.
     */
    handleBrainInjury (event) {
        try{
        const value = event.detail.value;
        this.saveRecord[constants.waiverFields.HasBrainInjury] = value;
        this.showHasBrainInjuryError = false;
    }catch (error) {
        console.error("error");
    }
    }
    /**
     * @function : handleOnVentilator
     * @description	: Method to Handle toggle response.
     * @param {*} event - On click of toggle.
     */
    handleOnVentilator (event) {
        try{
        const value = event.detail.value;
        this.saveRecord[constants.waiverFields.IsVentilatorDependent] = value;
        this.showOnVentilatorError =false;
    }catch (error) {
        console.error("error");
    }
    }
    /**
     * @function : handleRequireAssistance
     * @description	: Method to Handle toggle response.
     * @param {*} event - On click of toggle.
     */
    handleRequireAssistance (event) {
        try{
        const value = event.detail.value;
        this.saveRecord[constants.waiverFields.RequireAssistance] = value;
        this.showRequireAssistanceError = false;
    }catch (error) {
        console.error("error");
    }
    }
    /**
     * @function : handleHasDisability
     * @description	: Method to Handle toggle response.
     * @param {*} event - On click of toggle.
     */
    handleHasDisability (event) {
        try{
        const value = event.detail.value;
        this.saveRecord[constants.waiverFields.HasDevelopmentalDisability] = value;
        this.showHasDisabilityError = false;
    }catch (error) {
        console.error("error");
    }
    }
    /**
     * @function : handleReceivingServices
     * @description	: Method to Handle toggle response.
     * @param {*} event - On click of toggle.
     */
    handleReceivingServices (event) {
        try{
        const value = event.detail.value;
        this.saveRecord[constants.waiverFields.WillContinueServices] = value;
        this.showReceivingServicesError = false;
    }catch (error) {
        console.error("error");
    }
    }
   /**
     * @function 		: connectedCallback.
     * @description 	: this method is get waiver questions details.    
     * */
connectedCallback (){
    try{    
        const url = new URL(window.location.href);
        this.individualId = url.searchParams.get("individualId");
        this.caseNumber =url.searchParams.get("caseNumber");
        if (url.searchParams.get("individualName")) {
            this.memberName = decodeURIComponent(
                url.searchParams.get("individualName")
            );
        }

        checkIfIndividualApplicableForWaiver({
            sIndividualId: this.individualId,
            sCaseNumber: this.caseNumber
        })
            .then(result => {
                const parsedData = result.mapResponse;
                if (
                    !sspUtility.isUndefinedOrNull(parsedData) &&
                    parsedData.hasOwnProperty("hasAccess") &&
                    !parsedData.hasAccess
                ) {
                    this.showAccessDenied = true;
                    this.showSpinner = false;
                } else {
                    this.getWaiverScreeningData();
                }
            })
            .catch(error => {
                console.error(
                    "error in check individual for waiver ",
                    JSON.stringify(error)
                );
            });
    }catch (error) {
        console.error("error in check individual for waiver ",
                    JSON.stringify(error));
    }
}

    getWaiverScreeningData = () => {
        try {
            if (
                !sspUtility.isUndefinedOrNull(this.individualId) &&
                this.individualId !== ""
            ) {
                getScreeningData({
                    individualId: this.individualId
                }).then(result => {
                    const parsedData = result.mapResponse;
                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty("ERROR")
                    ) {
                        console.error(
                            "failed in loading dashboard" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        if (parsedData.hasOwnProperty("contactGender")) {
                            this.contactGender = parsedData.contactGender;
                        }
                        if (parsedData.hasOwnProperty("contactRecord")) {
                            this.saveRecord = JSON.parse(
                                parsedData.contactRecord
                            );
                            this.contactName = this.saveRecord.IndividualName;
                        }
                        if (
                            !sspUtility.isUndefinedOrNull(this.saveRecord) &&
                            !sspUtility.isUndefinedOrNull(
                                this.saveRecord.GenderCode__c
                            )
                        ) {
                            if (this.contactGender === "M") {
                                this.heOrSheLabel = "he";
                                this.hisOrHerLabel = "his";
                            } else if (this.contactGender === "F") {
                                this.heOrSheLabel = "she";
                                this.hisOrHerLabel = "her";
                            }
                        }

                        if (
                            parsedData.hasOwnProperty("showScreen") &&
                            parsedData.showScreen
                        ) {
                            this.showScreen = true;
                        } else {
                            this.showAccessDenied = true;
                        }
                        if (parsedData.hasOwnProperty("disabled")) {
                            this.disabled = true;
                        }
                        if (
                            sspUtility.isUndefinedOrNull(this.contactName) ||
                            sspUtility.isEmpty(this.contactName)
                        ) {
                            this.contactName = this.memberName;
                        }
                        Object.keys(this.label).forEach(labelKey => {
                            this.label[labelKey] = formatLabels(
                                this.label[labelKey],
                                [this.contactName],
                                [this.contactName]
                            );
                        });
                    }
                    this.showSpinner = false;
                });
            } else {
                this.showSpinner = false;
            }
        } catch (error) {
            this.showSpinner = false;
            console.error("getWaiverScreeningData" + JSON.stringify(error));
        }
    }

    /**
     * @function - handleExit
     * @description - Method is used to navigate to other pages.
     */
    handleExit = () => {
        this.showSpinner = true;
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Benefits_Page__c"
                }
            });
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "failed in handleExit in screening" + JSON.stringify(error)
            );
        }
    };

}
