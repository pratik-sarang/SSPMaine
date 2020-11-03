import { LightningElement,track,api } from "lwc";
import sspAssisterAccessRequestModal from "@salesforce/label/c.SSP_AssisterAccessRequestModal";
import sspWantsToBeAssister from "@salesforce/label/c.SSP_WantsToBeAssister";
import sspAssisterAccessModalLineTwo from "@salesforce/label/c.SSP_AssisterAccessModalLineTwo";
import sspAssisterAccessModalLineThree from "@salesforce/label/c.SSP_AssisterAccessModalLineThree";
import sspAssisterAccessModalLineFour from "@salesforce/label/c.SSP_AssisterAccessModalLineFour";
import sspAssisterAccessModalLineFive from "@salesforce/label/c.SSP_AssisterAccessModalLineFive";
import sspAppendixBUrl from "@salesforce/label/c.SSP_AppendixBForm";
import sspAppendixBLabel from "@salesforce/label/c.SSP_AppendixBLabel";
import sspAuthRepAccessModalAcceptButton from "@salesforce/label/c.SSP_AuthRepAccessModalAcceptButton";
import sspAuthRepAccessModalRejectButton from "@salesforce/label/c.SSP_AuthRepAccessModalRejectButton";
import sspConstants from "c/sspConstants";
import  { formatLabels } from "c/sspUtility";
import sspRejectAccessRequestTitle from "@salesforce/label/c.SSP_RejectAccessRequestTitle";
import sspAcceptAccessRequestTitle from "@salesforce/label/c.SSP_AcceptAccessRequestTitle";
import updateAccountContactRelation from "@salesforce/apex/SSP_AssisAuthRepConsentNotSignedService.updateAccountContactRelation"
import fetchAcrResponse from "@salesforce/apex/SSP_AssisterRequestAccessService.fetchAcrResponse"


export default class SspAssisterAccessRequestModal extends LightningElement {
    @api 
    get notificationId (){
        return this.messageId;
        
    }
    
    set notificationId (value){
        this.messageId= value;
        this.fetchAssisterDetails();
    }
    @track messageId;
    @track openModel = true;
    @track trueValue = true;
    @track disabled = true;
    @track modalButtonClicked = false;//added for 388765. to identify whether any of the modal buttons clicked.
    @track reference = this;
    @api applicationId;
    @track appId;
    @track assisterName;
    @track permissionKIHIPP;
    @track permissionMedicaid;
    @track sspWantsToBeAssisterText;
    @track permission;
    @track showSpinner =true;
    @track dataLoaded = false; 
    @track entered = false;
    label = {
        sspAssisterAccessRequestModal,
        sspWantsToBeAssister,
        sspAssisterAccessModalLineTwo,
        sspAssisterAccessModalLineThree,
        sspAssisterAccessModalLineFour,
        sspAssisterAccessModalLineFive,
        sspAppendixBLabel,
        sspAppendixBUrl,
        sspAuthRepAccessModalAcceptButton,
        sspAuthRepAccessModalRejectButton,
        sspRejectAccessRequestTitle,
        sspAcceptAccessRequestTitle
    };

    /**
     * @function : closeApplicationStatementModal
     * @description : This method is used to close the Modal.
     */
    closeApplicationStatementModal = () => {
        try {
            this.openModel = false;
            const hideAccessModal = new CustomEvent(
                sspConstants.events.hideAccessRequestModal
            );
            this.dispatchEvent(hideAccessModal);
        } catch (error) {
            console.error(
                "Error occurred in closeApplicationStatementModal" +
                    error
            );
        }
    };

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable the Buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            if(this.modalButtonClicked === false) {//Condition added for 388765, enable the button only for first time not after selecting the modal buttons.
                this.disabled = false;
            }
        } catch (error) {
            console.error(
                "Error occurred in enableModalButtons" +
                    error
            );
        }
    };


    /**
     * @function : handleOnClick.
     * @description : To handle accept or reject of Assister.
     * @param {object} event - Js event.
     */
    handleOnClick (event) {
        this.disabled = true;//added for 388765, disable the modal button to prevent multiple clicks.
        this.modalButtonClicked = true;//added for 388765, set this flag to indicate any of the modal buttons is clicked.
        this.openModel = false;
        this.showSpinner = true;
        const buttonAction = event.target.name;
        if(buttonAction==="Accept"){
            this.consentCitizen = true;
            updateAccountContactRelation({
                snotificationId: this.messageId,
                citizenConsent: this.consentCitizen
            })
            .then(result => {
                this.error = undefined;
                this.openModel = false;
                this.openModel = "";
                const hideAccessModal = new CustomEvent(
                    sspConstants.events.hideAccessRequestModal
                );
                this.dispatchEvent(hideAccessModal);
                    this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                    this.showSpinner = false;
            });
        }else if(buttonAction === "Reject"){
            this.consentCitizen = false;
            updateAccountContactRelation({
                snotificationId: this.messageId,
                citizenConsent: this.consentCitizen
            })
            .then(result => {
                this.error = undefined;
                this.openModel = false;
                this.openModel = "";
                const hideAccessModal = new CustomEvent(
                    sspConstants.events.hideAccessRequestModal
                );
                this.dispatchEvent(hideAccessModal);
                    this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                    this.showSpinner = false;
            });
            
        }
       // this.updateAccountContactRelations();
    }

    updateAccountContactRelations (){
        updateAccountContactRelation({snotificationId : this.applicationId , citizenConsent : this.consentCitizen})
        .then(result =>{
            console.error("response--> "+result);
        })
        .catch(error =>{

        })
    }

    fetchAssisterDetails (){
        fetchAcrResponse({
            snotifiId: this.messageId
        })
        .then(result => {
            this.assisterName = result.AssisterName;
            if(result.PermissionLevelKIHIPP !== undefined){
                this.permission = result.PermissionLevelKIHIPP;
            }
            if(result.PermissionLevelMedicaid !== undefined){
             if( this.permission !=="" && this.permission !==undefined){
                this.permission = this.permission +"," +result.PermissionLevelMedicaid;
             }else{
                this.permission = result.PermissionLevelMedicaid;
             }   
            
            }
            this.error = undefined;

            this.sspWantsToBeAssisterText = formatLabels(
                this.label.sspWantsToBeAssister,
                [this.assisterName,this.permission]
            );
            this.showSpinner =false;
            this.dataLoaded = true;
        })
        .catch(error => {
            this.error = error;
            this.showSpinner =false;
        });
    }
   renderedCallback (){
       if(!this.entered) {
           if (this.template.querySelector(".ssp-authModalContent")) {
               this.template
                   .querySelector(".ssp-AssisterAccessRequestModal")
                   .lessContentEnableButtons();
               this.entered = true;
           }
       }
       
    }
}