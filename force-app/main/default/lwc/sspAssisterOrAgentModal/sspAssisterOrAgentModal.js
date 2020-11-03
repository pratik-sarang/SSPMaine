/**
 * Component Name: sspAssisterOrAgentModal.
 * Author: Yathansh Sharma, Venkata.
 * Description: This modal is used to display the information of the selected assister/agent and 
 *              attach them to the application's account by AccountContactRelationship.
 * Date: 1/29/2019.
 */
import { LightningElement, api, wire, track } from "lwc";

import fetchApplicationList from "@salesforce/apex/SSP_ApplicationController.fetchApplicationList";
import upsertAgentAssister from "@salesforce/apex/SSP_AgentAssistorController.upsertAgentAssister";

import fetchContactInformation from "@salesforce/apex/SSP_AgentAssistorController.fetchContactInformation";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage"; //#387346
import sspAssist from "@salesforce/label/c.SSP_Assister";
import sspOfficeAddress from "@salesforce/label/c.SSP_OfficeAddress";
import sspContactMethod from "@salesforce/label/c.SSP_ContactMethod";
import sspOrganization from "@salesforce/label/c.SSP_Organization";
import sspSelectOrganization from "@salesforce/label/c.SSP_SelectOrganization";
import sspViewOrganization from "@salesforce/label/c.SSP_ViewOrganization";
import sspAvailability from "@salesforce/label/c.SSP_Availability";
import sspLanguagesText from "@salesforce/label/c.SSP_LanguagesText";
import sspYouSelectedPrivateAssist from "@salesforce/label/c.SSP_YouSelectedPrivateAssister";
import sspYouShouldOnlySelectThisAssist from "@salesforce/label/c.SSP_YouShouldOnlySelectThisAssister";
import sspCall from "@salesforce/label/c.SSP_Call";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspSelectAssist from "@salesforce/label/c.SSP_SelectAssistor";
import sspWhichCaseWouldYouLikeToAddThisAssistTo from "@salesforce/label/c.SSP_WhichCaseWouldYouLikeToAddThisAssisterTo";
import sspWhichCaseWouldYouLikeToAddThisAgentTo from "@salesforce/label/c.SSP_WhichCaseWouldYouLikeToAddThisAgentTo";
import sspAgent from "@salesforce/label/c.SSP_Agent";
import sspApplication from "@salesforce/label/c.SSP_Application";
import sspSelectAgent from "@salesforce/label/c.SSP_SelectAgent";
import sspClickHereToSeeCaseOptions from "@salesforce/label/c.SSP_ClickHereToSeeCaseOptions";
import sspAddThisIndividualToYourCase from "@salesforce/label/c.SSP_AddThisIndividualToYourCase";
import sspClickToCall from "@salesforce/label/c.SSP_ClickToCall";
import sspClickToOpenDeviceEmailApp from "@salesforce/label/c.SSP_ClickToOpenDeviceEmailApp";
import sspClickToOpenDeviceMapAppWithAddress from "@salesforce/label/c.SSP_ClickToOpenDeviceMapAppWithAddress";
import sspConstants from "c/sspConstants";
import sspCase from "@salesforce/label/c.SSP_CaseHashcolon";

export default class sspAssisterOrAgentModal extends LightningElement {
    @api contactId;
    @api memberId;
    @api roleType;
    @api buttonLabel;
    @api buttonTitle;
    @api isInsuranceAgentModal = false;
    @api applicationId;
    @api accountName = "";
    @api accountDataId ="";
    @api accountContactId ="";
    @api accountPhone="";
    @api accountEmail="";
    @api accountAddressLine1="";
    @api accountAddressLine2="";
    @api isOrganization=false;
    @api organizationName="";
    @track contactData;
    @track showSelect = false;;
    @track selectedCaseId;
    @track defaultCaseId;
    @track caseListOptions = [];
    @track availabilityList = [];
    @track languages = "";
    @track isOfficeAddress = false;
    @track phoneTitle = "";
    @track emailTitle = "";
    @track addressTitle = "";
    @track mapsLink = "";
    @track mapsBaseLink = sspConstants.navigationUrl.mapUrl;
    @track CountyCode = "";
    @track showErrorModal = false;
    @track showSpinner = false;
    @track errorCode = "";
    @track reference = this;
    @track recordType = "";

    customLabel = {
        sspAssist,
        sspOfficeAddress,
        sspContactMethod,
        sspAvailability,
        sspLanguagesText,
        sspYouSelectedPrivateAssist,
        sspYouShouldOnlySelectThisAssist,
        sspCall,
        sspEmail,
        sspSelectAssist,
        sspWhichCaseWouldYouLikeToAddThisAssistTo,
        sspWhichCaseWouldYouLikeToAddThisAgentTo,
        sspAgent,
        sspApplication,
        sspSelectAgent,
        sspClickHereToSeeCaseOptions,
        sspAddThisIndividualToYourCase,
        sspClickToCall,
        sspClickToOpenDeviceEmailApp,
        sspClickToOpenDeviceMapAppWithAddress
    }

    /**
     * @function : contactDataSetter.
     * @description : Method to get the information of the Agent, Assister.
     * @param {sspContactId, callingComponent} - - : Id of the Assister, Agent.
     */
    @wire(fetchContactInformation, { sspContactId: "$contactId", callingComponent: sspConstants.agentModalConstants.sspAssistOrAgentModal })
    contactDataSetter ({ error, data }) {
        if (data) {
            if(data !== undefined &&  data !== null && data.mapResponse.hasOwnProperty("contactRecord")){
            
            const contact = JSON.stringify(data.mapResponse.contactRecord)
            this.contactData = JSON.parse(contact);
          
            this.availabilityList = [];
            if (this.contactData.HoursAvailableCode__c !== undefined) {
                const availabilityListCodes = this.contactData.HoursAvailableCode__c.split(";");
                for (let i = 0; i < availabilityListCodes.length; i++) {
                    this.availabilityList.push(data.mapResponse.HoursTypes[availabilityListCodes[i]]);
                }
            }
                if (this.roleType === "Agent") {
                    this.languages =
                        data.mapResponse.LanguageTypes[
                            this.contactData.SpokenLanguageCode__c
                        ];
                } else {
                    this.languages =
                        data.mapResponse.LanguageTypes[
                            this.contactData.PreferredLanguageCode__c
                        ];
                }
            
            if (this.contactData.MailingStreet || this.contactData.MailingCity || this.contactData.MailingPostalCode || this.contactData.MailingState) {
                this.isOfficeAddress = true;
            }
            this.contactData.MailingStreet = (this.contactData.MailingStreet !== undefined) ? this.contactData.MailingStreet : "";
            this.contactData.MailingCity = (this.contactData.MailingCity !== undefined) ? this.contactData.MailingCity : "";
            this.CountyCode = (this.contactData.CountyCode__c !== undefined) ? this.contactData.CountyCode__c : "";
            this.contactData.MailingState = (this.contactData.MailingState !== undefined) ? this.contactData.MailingState : "";
            this.contactData.MailingPostalCode = (this.contactData.MailingPostalCode !== null && this.contactData.MailingPostalCode !== undefined) ? this.contactData.MailingPostalCode : "";
            let address = "";
            if(this.isOrganization){
             address = this.accountAddressLine1 + " "+ this.accountAddressLine2;
            }else{
             address = this.contactData.MailingStreet + " " + this.contactData.MailingCity + " " + this.CountyCode + " " + this.contactData.MailingState + " " + this.contactData.MailingPostalCode;
            }
            this.addressTitle = this.customLabel.sspClickToOpenDeviceMapAppWithAddress + " " + address;
            this.mapsLink = this.mapsBaseLink + address;
            
            
            this.emailTitle = this.customLabel.sspClickToOpenDeviceEmailApp + this.contactData.Email;
        }
        } else if(error) { //Defect-392986 Added else if(error) to avoid unnecessary error in console
            console.error(error);
        }
      
    }

    /**
     * @function : GenerateApplicantList.
     * @description : Method to get the list of applications to which the Agent, Assister can be added.
     * @param {string} callingComponent - : Id of the current logged in member.
     */
    @wire(fetchApplicationList, { callingComponent: "sspAssisterOrAgentModal", sspApplicationId: "$applicationId", roleType: "$roleType" }) //Defect-392986 Added roleType param
    generateApplicantList ({ error, data }) {
        try {
            if (data) {              
                this.displayList = [];
                if(data.mapResponse.hasOwnProperty("showAddButton") &&
               data.mapResponse.hasOwnProperty("responseData"))
             {
                for (let i = 0; i < data.mapResponse.responseData.length; i++) {
                    if(data.mapResponse.responseData[i].DCCaseNumber__c !== undefined
                        && data.mapResponse.responseData[i].DCCaseNumber__c !== null){
                    this.caseListOptions.push({
                        value: data.mapResponse.responseData[i].Id,
                        label: data.mapResponse.responseData[i].DCCaseNumber__c,
                    
                    });
                }else{
                    this.caseListOptions.push({
                        value: data.mapResponse.responseData[i].Id,
                        label: data.mapResponse.responseData[i].Name,
                    
                    }); 
                }
                }
                if (this.caseListOptions.length === 1) {
                    this.selectedCaseId = this.caseListOptions[0].value;
                    if(data.mapResponse.responseData[0].DCCaseNumber__c !== undefined
                        && data.mapResponse.responseData[0].DCCaseNumber__c !== null){
                        this.recordType = sspCase;
                    }else{
                        this.recordType = sspApplication;
                    }
                }
                if (this.caseListOptions.length > 0) {
                    this.showSelect = true;
                }
            }

                if (data.mapResponse.hasOwnProperty("defaultCase") && data.mapResponse.defaultCase && data.mapResponse.defaultCase != "") {
                    this.selectedCaseId = data.mapResponse.defaultCase;
                    this.defaultCaseId = this.selectedCaseId;
                    
                }
           
            } else if(error) { //Defect-392986 Added else if(error) to avoid unnecessary error in console
                console.error(error);
            }
        } catch (err) {
            console.error(err);
        }
    }
    connectedCallback () {
        let phoneNumber;
            if (this.accountPhone=== undefined || this.accountPhone=== null || this.accountPhone ==="") {
                phoneNumber = "";
            }
            else if ((this.accountPhone.match(/^\d{3}-\d{3}-\d{4}$/))) {
                phoneNumber = this.accountPhone;
            }
            else {
                const formatted = this.accountPhone.replace(/\D/g, "").match(/(\d{3})(\d{3})(\d{4})/);
                phoneNumber = (formatted[1] + "-" + formatted[2] + "-" + formatted[3]);
            }
            if(this.isOrganization){
                this.buttonLabel = sspViewOrganization;
            }
            this.phoneTitle = this.customLabel.sspClickToCall + phoneNumber;
           
    }
    /**
     * @function : contactHasData.
     * @description : Method to return if the data has been queried for the contact.
     */
    get contactHasData () {
        return this.contactData !== undefined;
    }

    /**
     * @function : showApplicationList.
     * @description : Method to check if the application list has more than 1 records.
     */
    get showApplicationList () {
        return (this.caseListOptions.length > 1 && (this.applicationId === null || this.applicationId === undefined || this.applicationId === ""));
    }

    /**
     * @function : showSingleApplication.
     * @description : Method to check if the application list has exactly 1 record.
     */
    get showSingleApplication () {
        return (this.caseListOptions.length === 1 && (this.applicationId === null || this.applicationId === undefined || this.applicationId === ""));
    }

    /**
     * @function : ApplicationName.
     * @description : Method to get the application name to html, if application list has exactly 1 record.
     */
    get ApplicationName () {
        return this.caseListOptions[0].label;
    }

    /**
     * @function : showIsPrivate.
     * @description : Method to check if the Assister is Private.
     */
    get showIsPrivate () {
        return (this.roleType === sspConstants.agentModalConstants.assist && this.contactData[sspConstants.agentModalConstants.inHousePrivateAssist] === true);
    }

    /**
     * @function : showAvailability.
     * @description : Method to check if the queried contact record is Assister.
     */
    get showAvailability () {
        return this.roleType === sspConstants.contactRecordTypes.Agent;
    }

    /**
     * @function : buttonLabelText.
     * @description : Method to get button label on html.
     */
    get buttonLabelText () {
        return this.isOrganization?sspSelectOrganization:(this.roleType === sspConstants.contactRecordTypes.Agent) ? this.customLabel.sspSelectAgent : this.customLabel.sspSelectAssist;
    }

    /**
     * @function : emailHref.
     * @description : Method to get the href for the email field.
     */
    get emailHref () {
        return `mailto:${this.contactData.Email}`;
    }

    /**
     * @function : phoneHref.
     * @description : Method to get the href for the phone field.
     */
    get phoneHref () {
        return `tel:${this.contactData.Phone}`;
    }

    /**
     * @function : phoneMasked.
     * @description : Method to get masked value for the phone number.
     */
    get phoneMasked () {
        if (this.accountPhone === undefined || this.accountPhone === null || this.accountPhone === "") {
            return "";
        }
        if ((this.accountPhone.match(/^\d{3}-\d{3}-\d{4}$/))) {
            return this.accountPhone;
        }
        const formatted = this.accountPhone.replace(/\D/g, "").match(/(\d{3})(\d{3})(\d{4})/);
        return (formatted[1] + "-" + formatted[2] + "-" + formatted[3]);
    }

    /**
     * @function : headerVal.
     * @description : Method to get the header text for the modal.
     */
    get headerVal () {
        return (this.isOrganization ? sspOrganization:(this.roleType === sspConstants.contactRecordTypes.Agent) ? this.customLabel.sspAgent : this.customLabel.sspAssist);
    }

    /**
     * @function : handleCaseChange.
     * @description : method to capture the value of the selected case from the drop-down.
     * @param {event} event - : information of the event that just happened.
     */
    handleCaseChange = (event) => {
        this.selectedCaseId = event.target.value;

       // #387346 start
        const errorMessageList = [];
        if (!event.target.value) {
            errorMessageList.push(sspRequiredErrorMessage);
        }

        const element = this.template.querySelectorAll(".ssp-caseList");
        if (element && element[0]) {
            element[0].ErrorMessageList = errorMessageList;
        }
        //end
    }

    /**
     * @function : initSelectAssist.
     * @description : method to assign the selected agent or assister to the case.
     */
    initSelectAssist = () => {       
        if((this.applicationId !== undefined && this.applicationId !== null && this.applicationId !== "") || 
            (this.selectedCaseId !== undefined && this.selectedCaseId !== null && this.selectedCaseId !== "")){
                this.showSpinner = true;
            upsertAgentAssister({
                applicationId: (this.applicationId !== undefined && this.applicationId !== null && this.applicationId !== "") ? this.applicationId : this.selectedCaseId,
                contactId: this.contactId,
                roleType: this.roleType,
                accountDataId:this.accountDataId,
                accountContactId:this.accountContactId,
                isOrganization: this.isOrganization
            }).then(response => {
            /*  if (response.mapResponse.hasOwnProperty("success") && !response.mapResponse.success) {
                    console.error(response.mapResponse.error);
                } else {*/
                    
                    this.showSpinner = false;
                    if (response.mapResponse.hasOwnProperty("noChange")) {
                        this.dispatchEvent(
                            new CustomEvent("cancel", { bubbles: true, composed: true })
                        );
                    } else if(response.mapResponse.hasOwnProperty("success")){
                        this.dispatchEvent(
                            new CustomEvent("success", { detail: this.roleType,bubbles: true, composed: true })
                        );
                    }else if(response.mapResponse.hasOwnProperty("ERROR")){                   
                        this.errorCode = response.mapResponse.ERROR;
                    this.showErrorModal = true;
                }
                this.isInsuranceAgentModal = false;
                //}
            }).catch((error) => {
                console.error(error);
            });
        }
        // #387346 start
        else {
            const errorMessageList = [sspRequiredErrorMessage];
            const element = this.template.querySelectorAll(".ssp-caseList");
            if (element && element[0]) {
                element[0].ErrorMessageList = errorMessageList;
            }
        }
        //end
    }

    /**
     * @function : openModal.
     * @description : method to open the modal.
     */
    openModal = () => {
        this.isInsuranceAgentModal = true;
    }

    /**
     * @function : closeModal.
     * @description : method to close the modal.
     */
    closeModal = () => {
        this.isInsuranceAgentModal = false;
        this.selectedCaseId = this.defaultCaseId;
    }

    closeError = () => {
        this.showErrorModal = false;
    }
}