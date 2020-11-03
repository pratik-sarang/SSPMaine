import { track, api ,LightningElement} from "lwc";
import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import getBenefits from "@salesforce/apex/SSP_DiscontinueBenefitsController.getActiveBenefitsDetails";
import discontinueBenefits from "@salesforce/apex/SSP_DiscontinueBenefitsController.triggerDiscontinueBenefitsCallout";
import sspDiscontinueBenefits from "@salesforce/label/c.sspDiscontinueBenefits";
import sspCaseHash from "@salesforce/label/c.SSP_CaseHash";
import sspNoLongerProvideAssistance from "@salesforce/label/c.sspNoLongerProvideAssistance";
import sspSelectProgramToDiscontinue from "@salesforce/label/c.sspSelectProgramToDiscontinue";
import sspReasonForDiscontinuation from "@salesforce/label/c.sspReasonForDiscontinuation";
import sspDiscontinuanceOption from "@salesforce/label/c.sspDiscontinuanceOption";
import memberErrorMessage from "@salesforce/label/c.SSP_IncomeSubsidiesSelErrMsg";
import sspDiscontinueSelectedBenefits from "@salesforce/label/c.sspDiscontinueSelectedBenefits";
import sspDiscontinueBenefits2 from "@salesforce/label/c.sspDiscontinueBenefits2";
import sspKentuckyNoLongerProvideBenefits from "@salesforce/label/c.sspKentuckyNoLongerProvideBenefits";
import sspAreYouSureDiscontinueBenefits from "@salesforce/label/c.sspAreYouSureDiscontinueBenefits";
import sspYesDiscontinueBenefits from "@salesforce/label/c.sspYesDiscontinueBenefits";
import sspAltYesDiscontinueBenefits from "@salesforce/label/c.sspAltYesDiscontinueBenefits";
import sspNoCancel from "@salesforce/label/c.sspNoCancel";
import sspAltNoCancel from "@salesforce/label/c.sspAltNoCancel";
import sspCancel from "@salesforce/label/c.sspCancel";
import sspGoBackToDashboard from "@salesforce/label/c.sspGoBackToDashboard";
import sspUtility from "c/sspUtility";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import SSPRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import ADDRESS_LINE1 from "@salesforce/schema/Contact.Street__c";
import ADDRESS_LINE2 from "@salesforce/schema/Contact.AddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/Contact.City__c";
import ADDRESS_COUNTY from "@salesforce/schema/Contact.CountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/Contact.SSP_State__c";
import ADDRESS_ZIP4 from "@salesforce/schema/Contact.Zipcode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/Contact.Zipcode5__c";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2"

const PA_FIELD_MAP = {
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspAddress,
        fieldApiName: constants.contactFields.Street__c,
        objectApiName: constants.sspObjectAPI.Contact
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspAddressLine2,
        fieldApiName: constants.contactFields.AddressLine2__c,
        objectApiName: constants.sspObjectAPI.Contact
    },
    city: {
        ...ADDRESS_CITY,
        label: constants.addressLabels.City
    },
    county: {
        ...ADDRESS_COUNTY,
        label: constants.addressLabels.County
    },
    state: {
        ...ADDRESS_STATE,
        label: constants.addressLabels.State
    },
    zipCode4: {
        ...ADDRESS_ZIP4,
        label: constants.addressLabels.Zip
    },
    zipCode5: {
        ...ADDRESS_ZIP5,
        label: constants.addressLabels.Zip
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: constants.addressLabels.Zip
    }
};
export default class SspDiscontinueBenefits extends NavigationMixin(LightningElement) {
    
    labels = {
        sspDiscontinueBenefits,
        sspCaseHash,
        sspNoLongerProvideAssistance,
        sspSelectProgramToDiscontinue,
        sspReasonForDiscontinuation,
        sspDiscontinuanceOption,
        sspDiscontinueSelectedBenefits,
        sspDiscontinueBenefits2,
        sspKentuckyNoLongerProvideBenefits,
        sspAreYouSureDiscontinueBenefits,
        sspYesDiscontinueBenefits,
        sspAltYesDiscontinueBenefits,
        sspNoCancel,
        sspAltNoCancel,
        sspCancel,
        sspGoBackToDashboard,
        toastErrorText
    };
    @track errorMessage=SSPRequiredErrorMessage;
    @track showErrorToast= false;
    @track showScreen= false;
    @track showAccessDenied= false;
    @track fieldMap = PA_FIELD_MAP;
    @track addressObject = {};
    @track optList = [
        {
            label: "Client Request",
            value: "CR"
        },
        {
            label: "Moved Out of State",
            value: "MO"
        }
    ];
    @api openModel = false;
    @track reference = this;
    @track caseNumber ="";
    @track programs=[{}];
    @track lstPrograms=[];
    @track objErrors=[];
    @track selectedPrograms=[{program:"",
                                individualId:""}];
    @track showSpinner = true;
    @track showAddress = false;
    @track reasonForDisContinue = false;
    @track checkProgramValidation = false;
    @track hasSnapProgram = false;
    @track errorMessage=SSPRequiredErrorMessage;
    @track showRequiredError = false;
    @track snapIndividuals = [];
   
    
    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on contact record.
     * @param {object} contact - Contact record.
     */
    bindAddressFields = contact => {
        try {
            const addressLineClass = this.template.querySelector(
                constants.classNames.addressLineClass
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                contact[
                    "AddressLine1"
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                contact[
                    "AddressLine2"
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                contact[
                    "City"
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                contact[
                    "CountyCode"
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                contact[
                    "StateCode"
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                const zipCode = physicalAddress.postalCode;
                if (!sspUtility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        contact[
                        "ZipCode4"
                        ] = zipCode;
                       
                    } else {
                        contact[
                            "ZipCode5"
                        ] = zipCode;
                        
                    }
                }
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRep.bindAddressFields " +
                    JSON.stringify(error)
            );
        }
        return contact;
    };
    handleReason (event){
        this.reasonForDisContinue  = event.detail;
        if(this.reasonForDisContinue === "MO"){
            this.showAddress = true;
        }else{
            this.showAddress = false;
        }


    }
    handleCheckbox (){
        const IndividualItems = this.template.querySelectorAll(
            ".ssp-checkBoxGroup"
         );
         this.lstPrograms =[];
         for (let i = 0; i < IndividualItems.length; i++) {
            
             if(IndividualItems[i].value){                
                 this.showRequiredError =false;
                
             }
         }
        
    }
    openModal () {
        this.checkProgramValidation= false;
        this.hasSnapProgram = false;
        this.addressObject = {};        
        const programPermissionItems = this.template.querySelectorAll(
            constants.classNames.sspApplicationInputs
        );
        this.objErrors = [];
        const IndividualItems = this.template.querySelectorAll(
           ".ssp-checkBoxGroup"
        );
        this.lstPrograms =[];
        for (let i = 0; i < IndividualItems.length; i++) {           
            if(IndividualItems[i].value){
                this.checkProgramValidation =true;
                this.lstPrograms.push(IndividualItems[i].name);
                const programValue = IndividualItems[i].id.split("-");              
                if(programValue[0] ==="SN"){
                    this.hasSnapProgram = true;
                }
            }
            
            

        }
        if(this.checkProgramValidation){
            this.showRequiredError = false;
        this.selectedPrograms = [];
        for (let i = 0; i < programPermissionItems.length; i++) {
            programPermissionItems[i].handleRequiredValidation (programPermissionItems[i].value,[],memberErrorMessage);
            if(programPermissionItems[i].ErrorMessageList !== undefined && programPermissionItems[i].ErrorMessageList !== null 
                && programPermissionItems[i].ErrorMessageList.length > 0){
            this.objErrors.push(programPermissionItems[i].ErrorMessageList);
                }
        }   
       
        if(this.objErrors.length  === 0){
        for (let i = 0; i < programPermissionItems.length; i++) {           
            const objProgram={};
            if(programPermissionItems[i].value !== undefined && programPermissionItems[i].value !== null 
                && programPermissionItems[i].value !== ""){
            objProgram.program = programPermissionItems[i].name;
            objProgram.individualId = programPermissionItems[i].value;
            this.selectedPrograms.push(objProgram);
                }
        }   
        if(this.hasSnapProgram === true){
            const objProgram={};
            
            objProgram.program ="SN";
            objProgram.individualId = this.snapIndividuals;
            this.selectedPrograms.push(objProgram);
                    }
            
        
        this.addressObject.benefitIndividuals = this.selectedPrograms;
        this.addressObject.reason = this.reasonForDisContinue;
        this.addressObject.caseNumber = this.caseNumber;
        if(this.reasonForDisContinue ==="MO"){
        this.addressObject = this.bindAddressFields (this.addressObject);
        }       
       
        this.openModel = true;
    }
       
    }else{
        this.showErrorToast= true;
        this.showRequiredError = true;
    }
       
       
    }
     /**
     * @function 		: handleHideToast.
     * @description 	: this method is handle toast.    
     * */
    saveAndExitModal = () => {
        try {
            this.openModel =false;
            this.fireEvent();
            this.showErrorToast = false;
            this.showSpinner = true;         
            discontinueBenefits({
                benefitJSON: JSON.stringify(this.addressObject)                   
            }).then(result => {                   
                const parsedData = result.mapResponse;  
               
                if (
                    !sspUtility.isUndefinedOrNull(parsedData) &&
                    parsedData.hasOwnProperty("ERROR")
                ) {
                    this.errorCode = parsedData.ERROR;
                    this.showErrorModal = true;                       
                   
                } else if (!sspUtility.isUndefinedOrNull(parsedData)) {                 
                   this.handleNavigation();
                }
                  
               
                this.showSpinner = false;
                
            });
        
   
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
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
     * @function : closeError
     * @description	: Method to close error modal.
     */
    closeError () {
        try {
        this.errorCode = "";
        this.showErrorModal = false;
        
        }catch (error) {
            console.error("error");
        }
    }
    /**
     * @function : handleProp
     * @description : This method is used to close modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }
    /**
     * @function : cancelModal
     * @description : This method is used to close Modal.
     */
    cancelModal () {
        this.openModel = false;
        this.fireEvent();
    }
    /**
     * @function : fireEvent
     * @description : This method is used to pass value to parent component to close the modal.
     */
    fireEvent () {
        const closeEvt = new CustomEvent(constants.events.closeModal);
        this.dispatchEvent(closeEvt);
    }

     /**
     * @function 		: connectedCallback.
     * @description 	: this method is get waiver questions details.    
     * */
connectedCallback (){
    try{
    const url = new URL(window.location.href);
  this.caseNumber = url.searchParams.get("caseId");
    if((!sspUtility.isUndefinedOrNull(this.caseNumber)) && this.caseNumber !== ""){
        getBenefits({
            caseId: this.caseNumber                 
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
            if (parsedData.hasOwnProperty("Benefits" )) {
                this.programs = JSON.parse(parsedData.Benefits);
            }
            if (parsedData.hasOwnProperty("snapIndividuals")) {
                this.snapIndividuals = JSON.parse(parsedData.snapIndividuals);
            }         
         
            if (
                parsedData.hasOwnProperty(
                    "showScreen"
                ) && parsedData.showScreen
            ) {
                this.showScreen = true;
            }else{
                this.showAccessDenied = true;
            }         
           
        }
        this.showSpinner = false;
     

    });
}else{
    this.showSpinner = false;
}
}catch (error) {
    console.error("error");
}
}
   /**
     * @function - handleNavigation
     * @description - Method is used to navigate to other pages.
    
     */
    handleNavigation = () => {
        try {
            const selectedPage = "Benefits_Page__c";
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: selectedPage
                }
            });
           
        } catch (error) {
            console.error(
                "failed in handleNavigation in header" + JSON.stringify(error)
            );
        }
    };
}