import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspCollateralContact from "@salesforce/label/c.SSP_CollateralContact";
import sspCollateralContactInfo from "@salesforce/label/c.SSP_CollateralContactInfo";
import sspContactName from "@salesforce/label/c.SSP_ContactName";
import apConstants from "c/sspConstants";
import sspContactPhoneNumber from "@salesforce/label/c.SSP_ContactPhoneNumber";
import sspRelationshipToYou from "@salesforce/label/c.SSP_RelationshipToYou";
import sspCollateralSubmit from "@salesforce/label/c.SSP_CollateralSubmit";
import sspCollateralForm from "@salesforce/label/c.SSP_CollateralForm";
import sspCollateralWhoLives from "@salesforce/label/c.SSP_CollateralWhoLives";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";	
import sspPAFS76 from "@salesforce/resourceUrl/PAFS76";
import sspPAFS76SPA from "@salesforce/resourceUrl/PAFS76SPA";
import sspUtility from "c/sspUtility";
import getCurrentLoggedInUserLang from "@salesforce/apex/SSP_CollateralContact.getCurrentLoggedInUserLang";
import fetchCollateralContactData from "@salesforce/apex/SSP_CollateralContact.fetchCollateralContactData";
import { updateRecord } from "lightning/uiRecordApi";

import CONTACT_NAME from "@salesforce/schema/SSP_Application__c.Contact_Name__c";
import CONTACT_PHONE from "@salesforce/schema/SSP_Application__c.Contact_Phone_Number__c";
import CONTACT_RELATIONSHIP from "@salesforce/schema/SSP_Application__c.Relationship_To_You__c";
import APPLICATION_ID from "@salesforce/schema/SSP_Application__c.Id";

export default class SspCollateralContact extends BaseNavFlowPage  {
    @api memberId;
    @api applicationId;
    @api individualRecordTypeId;
    @track contactName;
    @track contactPhone;
    @track relationshipToYou;
    @track contactNameError = null;
    @track contactPhoneError = null;
    @track relationshipError = null;
    @track metaDataList = {};
    @track language ; //Need to fetch from backend
    @track showTargetAnchorTag = false;
    @track PAFS76DocUrl = sspPAFS76;
    @track showSpinner = false;
    @track showToast = false;
    label={
        sspRequiredErrorMessage,
        sspCollateralWhoLives,
        sspCollateralForm,
        sspCollateralSubmit,
        sspCollateralContact,
        sspCollateralContactInfo,
        sspContactName,
        sspContactPhoneNumber,
        sspRelationshipToYou,
        toastErrorText
    };
    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }
      /**
     * @function - nextEvent().
     * @description - Next Event getter method for framework.
     */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    /**
     * @function - nextEvent().
     * @description - Next Event setter method for framework.
     * @param {string} value - Setter for Next Event framework property.
     */
    set nextEvent (value) {
        try {
            if (!sspUtility.isUndefinedOrNull(value)) {
                this.nextValue = value;           
                this.handleNextClick();
                this.templateInputsValue = this.template.querySelectorAll(".ssp-applicationInputs");
            }
        } catch (e) {
            console.error("Error in set nextEvent of Not US Citizen page", e);
        }
    }

    /**
     * @function - MetadataList().
     * @description - MetadataList getter method for framework.
     *
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    /**
     * @function - MetadataList().
     * @description - Next Event setter method for framework.
     * @param {string} value - Setter for MetadataList framework property.
     */
    set MetadataList (value) {
        try {
            if (!sspUtility.isUndefinedOrNull(value)) {
                this.MetaDataListParent = value;
                //CD2 2.5	Security Role Matrix and Program Access.
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                }
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of Not US Citizen page",
                e
            );
        }
    }

    /**
     * @function - allowSaveData().
     * @description - This method validates the input data and then saves it.
     *
     */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        //this.validationFlag = value;
        try {
            //this.showSpinner = true;
            this.validationFlag = value;
            if (	
                value &&	
                (!this.contactNameError &&	
                    !this.contactPhoneError &&	
                    !this.relationshipError)	
            ) {	
                this.saveCompleted = true;	
                //this.handleSave();	
            } else {	
                this.showSpinner = false;	
            }
        } catch (e) {
            this.showSpinner = false;
            console.error(
                "Error in set allowSaveData of Not US Citizen page",
                e
            );
        }
    }
    /**	
     * @function handleHideToast	
     * @description This method is used to get notified when toast hides.	
     */	
    handleHideToast = () => {	
        this.showToast = false;	
    };
    get contactNameHighlighter () {
        return this.contactNameError ? "ssp-input-error ssp-applicationInputs" :"ssp-applicationInputs";
    }

    get contactPhoneHighlighter () {
        return this.contactPhoneError ? "ssp-input-error ssp-applicationInputs" : "ssp-applicationInputs";
    }

    get contactRelationHighlighter () {
        return this.relationshipError ? "ssp-input-error ssp-applicationInputs" : "ssp-applicationInputs";
    }

   /**
   * @function : openPDF
   * @description : Download and open document in new tab.
   */
    openPDF = () => {
        try{
            const downloadElement = document.createElement("a");
            downloadElement.setAttribute("download", "download");
            if (this.language === "en_US") {
                window.open(sspPAFS76, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76;
            }
            else {
                window.open(sspPAFS76SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76SPA;
            }
            downloadElement.download = "PAFS76.pdf";
            downloadElement.click();
        }
        catch(error){
            console.error("Failed in openPDF", error);
        }
    }

    /**
    * @function handleContactName
    * @description : Handles change in contact name.
    * @param {object} event - Fired on change.
    */
    handleContactName = (event) => {
        try{
            if (event){
                this.contactName = event.detail;
            }
            if (this.contactPhone || this.relationshipToYou){
                //Conditionally required logic for contact name
                if (!this.contactName){
                    this.contactNameError = sspRequiredErrorMessage
                }
                else{
                    this.contactNameError=null;
                }
            }
            else{
                this.contactNameError = null;
            }
            if (!this.contactPhone && !this.relationshipToYou && !this.contactName){
                this.contactNameError = null;
                this.contactPhoneError = null;
                this.relationshipError = null;
            }
        }
        catch(error){
            console.error(
                "Error in handleContactName:",
                error
            );
        }
    }

    /**
    * @function handleContactPhone
    * @description : Handles change in contact phone number.
    * @param {object} event - Fired on change.
    */
    handleContactPhone = (event) => {
        try{
            if (event) {
                this.contactPhone = event.detail;
            }
            if (this.contactName || this.relationshipToYou){
                //Conditionally required logic for contact phone
                if(!this.contactPhone){
                    this.contactPhoneError = sspRequiredErrorMessage;
                }
                else{
                    this.contactPhoneError = null;
                }
            }
            else{
                this.contactPhoneError = null;
            }
            if (!this.contactPhone && !this.relationshipToYou && !this.contactName) {
                this.contactNameError = null;
                this.contactPhoneError = null;
                this.relationshipError = null;
            }
        }
        catch(error){
            console.error(
                "Error in handleContactPhone:",
                error
            );
        }
    }

    /**
    * @function handleRelation
    * @description : Handles change in relation.
    * @param {object} event - Fired on change.
    */
    handleRelation = (event) =>{
        try{
            if (event) {
                this.relationshipToYou = event.detail;
            }
            if (this.contactName || this.contactPhone ){
                //Conditionally required logic for contact relation
                if(!this.relationshipToYou){
                    this.relationshipError = sspRequiredErrorMessage;
                }
                else{
                    this.relationshipError = null;
                }
            }
            else{
                this.relationshipError = null;
            }
            if (!this.contactPhone && !this.relationshipToYou && !this.contactName) {
                this.contactNameError = null;
                this.contactPhoneError = null;
                this.relationshipError = null;
            }
        }
        catch (error) {
            console.error(
                "Error in handleRelation:",
                error
            );
        }
    }

    /**
    * @function handleNextClick
    * @description : Called on click of next button.
    */
    handleNextClick = () =>{
        try{
            this.showSpinner=true;
            this.handleRelation(null);
            this.handleContactPhone(null);
            this.handleContactName(null);
            if (!this.contactNameError && !this.contactPhoneError && !this.relationshipError) {
                //Can proceed for next screen
                this.updateAccountRecord();
            }else{	
                if (!this.showToast) {	
                    this.showToast = true;	
                }	
            }
        }
        catch (error) {
            console.error(
                "Error in handleNextClick:",
                error
            );
        }
    }

       /**
     * @function - connectedCallback.
     * @description - This method is called on component initialization.
     */
    connectedCallback () {
        try{
            this.showSpinner=true;
            const browserIExplorer = window.navigator && window.navigator.msSaveOrOpenBlob ? true : false;
            const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
            if (browserIExplorer || browserIOS) {
                this.showTargetAnchorTag = true;
            }
            getCurrentLoggedInUserLang()
                .then(result => {
                    this.language = result;
                    if (this.language !== "en_US") {
                        this.PAFS76DocUrl = sspPAFS76SPA;
                    }
                    //this.accounts = result;
                })
                .catch(error => {
                    this.error = error;
                    console.error("Error" + JSON.stringify(error));
                });

                const collateralContactSnap = new CustomEvent(
                    apConstants.events.updateCollateralHeader,
                    {
                      bubbles: true,
                      composed: true,
                      detail: {
                        header: sspCollateralContact
                      }
                    }
                  );
                  this.dispatchEvent(collateralContactSnap);

                fetchCollateralContactData({sApplicationId:this.applicationId})
                .then(result => {
                    this.contactName = result[0].Contact_Name__c;
                    this.relationshipToYou= result[0].Relationship_To_You__c;
                    this.contactPhone=result[0].Contact_Phone_Number__c;
                    this.showSpinner=false;
                })
                .catch(error => {
                    this.error = error;
                    console.error("Error" + JSON.stringify(error));
                });

        }
        catch(error){
            this.showSpinner=false;
            console.error("Failed in connectedCallback", error);
        }
    }
    
    //Update Collateral contact record on SSP_Application object 
    updateAccountRecord (){
        
        const fields = {};
        fields[APPLICATION_ID.fieldApiName] =  this.applicationId;
        fields[CONTACT_NAME.fieldApiName] = this.contactName;
        fields[CONTACT_PHONE.fieldApiName] = this.contactPhone;
        fields[CONTACT_RELATIONSHIP.fieldApiName] = this.relationshipToYou;
        
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(()=> {                
                //this.showSpinner=false;
                //this.saveCompleted = true;
            })
            .catch(error => {
                this.saveCompleted = false;
               console.error("Error in collateral contact "+JSON.stringify(error));
            });
    }

    //fetch Collateral contact record
    
}