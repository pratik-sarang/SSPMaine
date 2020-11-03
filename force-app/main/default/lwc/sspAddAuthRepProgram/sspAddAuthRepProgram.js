/*
 * Component Name: SspAddAuthRepProgram.
 * Author: Kireeti Gora, Venkata.
 * Description: This screen handle Add Auth Rep Permissions Module.
 * Date: 02/01/2020.
 **/
import { track, wire, api } from "lwc";
import sspRepsAssistAgents from "@salesforce/label/c.SSP_RepsAssistersAgents";
import sspAddAuthorizedRepresentative from "@salesforce/label/c.SSP_AddAuthReps";
import sspPleaseIndicateTheProgramsAndLevelOfAccess from "@salesforce/label/c.SSP_PleaseIndicateTheProgramsAndLevelOfAccessYouWouldLikeToGrantYourAuthRep";
import sspWhichCaseWouldYouLikeToAdd from "@salesforce/label/c.SSP_WhichCaseWouldYouLikeToAddThisAuthorizedRepresentativeTo";
import sspWhichProgramDoYouWant from "@salesforce/label/c.SSPWhichProgramDoYouWantThisAuthorizedRepresentativeToHaveAccessTo";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspSaveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspPleaseSelectAtLeastOneProgram from "@salesforce/label/c.SSP_PleaseSelectAtLeastOneProgram";
import sspReturnPreviousScreen from "@salesforce/label/c.SSP_ReturnPreviousScreen";
import sspClickHereToSeeYourCases from "@salesforce/label/c.SSP_ClickHereToSeeYourCases";
import sspContinueToNextScreenToEnterFurtherDetails from "@salesforce/label/c.SSP_ContinueToNextScreenToEnterFurtherDetails";
import sspCancelEnteringDetailsAuthorizedRepresentative from "@salesforce/label/c.SSP_CancelEnteringDetailsAuthorizedRepresentative";
import sspContentAuthorizeRepresentativeConsent from "@salesforce/label/c.SSP_ContentAuthorizeRepresentativeConsent1";
import getPermissionDetail from "@salesforce/apex/SSP_RepsAssistersAgentsController.getProgramCaseDetails";
import requestAccess from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.requestAccess";
import { refreshApex } from "@salesforce/apex";
import sspUtility from "c/sspUtility";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspConstants from "c/sspConstants";
import ADDRESS_LINE1 from "@salesforce/schema/AccountContactRelation.Street__c";
import ADDRESS_LINE2 from "@salesforce/schema/AccountContactRelation.AddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/AccountContactRelation.City__c";
import ADDRESS_COUNTY from "@salesforce/schema/AccountContactRelation.CountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/AccountContactRelation.SSP_State__c";
import ADDRESS_ZIP4 from "@salesforce/schema/AccountContactRelation.Zipcode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/AccountContactRelation.Zipcode5__c";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import sspPersonRelation from "@salesforce/label/c.SSP_AddAuthRepPersonRelation";
import sspClickHereToSeeOptionsForRelationships from "@salesforce/label/c.SSP_ClickHereToSeeOptionsForRelationships";
//Start - Added as a part of CD2 R3 Section 5.8.1.1
const PA_FIELD_MAP = {
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspAddress,
        fieldApiName: sspConstants.contactFields.Street__c,
        objectApiName: sspConstants.sspObjectAPI.AccountContactRelation
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspAddressLine2,
        fieldApiName: sspConstants.contactFields.AddressLine2__c,
        objectApiName: sspConstants.sspObjectAPI.AccountContactRelation
    },
    city: {
        ...ADDRESS_CITY,
        label: sspConstants.addressLabels.City
    },
    county: {
        ...ADDRESS_COUNTY,
        label: sspConstants.addressLabels.County
    },
    state: {
        ...ADDRESS_STATE,
        label: sspConstants.addressLabels.State
    },
    zipCode4: {
        ...ADDRESS_ZIP4,
        label: sspConstants.addressLabels.Zip
    },
    zipCode5: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    }
};
//End - Added as a part of CD2 R3 Section 5.8.1.1
export default class SspAddAuthRepProgram extends sspUtility {
    @api relationId = "";
    @api editPermissions = false;
    @api applicationId="" ;
    @api applicationRecordId="" ;
    @api authRepRequest = false ;
    @api contactId = "";
    @api contactInformation = {}; //Added as a part of CD2 R3 Section 5.8.1.1
    @api permissionParam;
    @api relationRecord;
    @api detailRecord;
    @track showSpinner = true;
    @track caseOptions;
    @track programs;
    @track dataToRefresh;
    @track selectedCaseNumber;
    @track programsMap;
    @track showPrograms;
    @track saveRecord = {};
    @track accountId;
    @track error;
    @track result;
    @track allowSave;
    @track showErrorToast = false;
    @track showError = false;
    @track showCaseError = false;
    @track sspConstants = sspConstants;
    @track showConsent = false;
    @track strAccountRelation = false;
    @track showPermissionClass;
    @track showPicklist = false;
    @track addressRecord; //Added as a part of CD2 R3 Section 5.8.1.1
    @track fieldMap = PA_FIELD_MAP; //Added as a part of CD2 R3 Section 5.8.1.1
    @track representativeRelationshipCodes; //Added as a part of CD2 R3 Section 5.8.1.1
    @track isSelectedViaSearch = false; //Added as a part of CD2 R3 Section 5.8.1.1
    @track metaDataListParent; //Added as a part of CD2 R3 Section 5.8.1.1
    @track relationshipCode = ""; //Added as a part of CD2 R3 Section 5.8.1.1
    @track disableAddress = false; //Added as a part of CD2 R3 Section 5.8.1.1
    @track applicationDetail = {};
    @track authRepDetails = {};
    @track mapProgramVsPermission=[{}];
    customLabel = {
        sspPersonRelation,
        sspClickHereToSeeOptionsForRelationships,
        sspRepsAssistAgents,
        sspAddAuthorizedRepresentative,
        sspPleaseIndicateTheProgramsAndLevelOfAccess,
        sspWhichCaseWouldYouLikeToAdd,
        sspWhichProgramDoYouWant,
        toastErrorText,
        sspCancel,
        sspSave,
        sspRequiredErrorMessage,
        sspPleaseSelectAtLeastOneProgram,
        sspNext,
        sspBack,
        sspSaveAndExit,
        sspReturnPreviousScreen,
        sspClickHereToSeeYourCases,
        sspContinueToNextScreenToEnterFurtherDetails,
        sspCancelEnteringDetailsAuthorizedRepresentative,
        sspContentAuthorizeRepresentativeConsent,
        sspRequestAccess
    };
     /**
     * @function 		: MetadataList.
     * @description 	: getter and setter for MetadataList .
     * */
    //Start - Added as a part of CD2 R3 Section 5.8.1.1
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setMetadataList: " +
                    JSON.stringify(error)
            );
        }
    }
    //End - Added as a part of CD2 R3 Section 5.8.1.1

    /**
     * @function 		: getRecordDetails.
     * @description 	: method to fetch  record details .
     * @returns {string}  : JSON of Object Record.
     * */

    @wire(getPermissionDetail,{relationId : "$relationId",sspApplicationId : "$applicationRecordId"})
    getRecordDetails (result) {
       try {
          
            this.dataToRefresh = result;
            if (result.data) {
                if ("casePrograms" in result.data.mapResponse) {
                    this.programsMap = JSON.parse(
                        result.data.mapResponse.casePrograms
                    );
                    if (this.editPermissions && !sspUtility.isUndefinedOrNull(this.applicationId)) {
                        this.programs = this.programsMap[this.applicationId];
                        this.showPrograms = true;
                    }
                }
                if ("lstCaseOptions" in result.data.mapResponse) {
                    this.caseOptions = result.data.mapResponse.lstCaseOptions;
                    if(this.caseOptions.length > 1){
                        this.showPicklist = true;                      
                    }else if(this.caseOptions.length === 1){
                        this.accountId = this.caseOptions[0].value;
                        this.programs = this.programsMap[this.accountId];
                        this.showPrograms = true;
                    }
                }
                if (("applicationData" in result.data.mapResponse)) {
                    this.applicationDetail = JSON.parse(result.data.mapResponse.applicationData);
                  
                }
                if ("authRepDetails" in result.data.mapResponse) {
                    this.authRepDetails = JSON.parse(result.data.mapResponse.authRepDetails);                    
                }
                if ("existingPermissionsForAuthRepRole" in result.data.mapResponse) {
                    this.mapProgramVsPermission = JSON.parse(result.data.mapResponse.existingPermissionsForAuthRepRole);
                   
                }
                
                refreshApex(this.dataToRefresh).then(() => {
                    this.showSpinner = false;
                });
            } else if (result.error) {
                console.error(result.error);
            }
        } catch (error) {
            console.error(
                "failed in getRecordDetails in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		:     handlePicklistChange (event){
     * @description 	: this method is used to hide/show programs based on Case.
     * @param {event} event - Gets current value.
     * */
    handlePicklistChange = (event) => {
        try {
             const programPermissionItems = this.template.querySelectorAll(
                 this.sspConstants.classNames.sspApplicationInputs
             );
             for (let i = 0; i < programPermissionItems.length; i++) {
                 programPermissionItems[i].resetComponent();
             }
            const value = event.detail;
            this.accountId = value;
            if (value) {
                this.programs = this.programsMap[value];
                this.showPrograms = true;
                this.showCaseError = false;
            } else {
                this.accountId = null;
                this.showCaseError = true;
                this.showError = false;
                this.showPrograms = false;
            }
         
         } catch (error) {
            console.error(
                "failed in handlePicklistChange in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: saveDetails.
     * @description 	: this method is handle validations and update data.
     * */

    saveDetails = () => {
        try {            
            if ((this.relationId !== null && this.relationId !== undefined && this.relationId !== "")) {
                this.saveRecord.Id = this.relationId;
            }
                if ((this.accountId === null || this.accountId === undefined) && !this.editPermissions) {
                    this.showCaseError = true;
                } else {
                    this.saveRecord = this.bindAddressFields(this.saveRecord);
                    const addressElement = this.template.querySelector(sspConstants.classNames.addressLineClass).ErrorMessages();
                   
                   
                    const programPermissionItems = this.template.querySelectorAll(
                        this.sspConstants.classNames.sspApplicationInputs
                    );
                    if(!this.editPermissions){
                    this.saveRecord.accountId = this.accountId;   
                    this.saveRecord.contactId = this.contactId; 
                    this.saveRecord[
                        sspConstants.accountContactRelationFields
                            .RepresentativeRelationshipCode__c
                    ] = this.relationshipCode;               
                    }
                   
                  
                    let hasError = false;
                    let isChecked = false;
                    if(addressElement.length >0){
                        hasError = true;
                    }
                    for (let i = 0; i < programPermissionItems.length; i++) {
                        if (!hasError) {
                            hasError = programPermissionItems[
                                i
                            ].handleValidations();
                        } else {
                            programPermissionItems[i].handleValidations();
                        }
                        if (!isChecked) {
                            isChecked =
                                programPermissionItems[i].programCheckbox;
                        }
                        if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.MA &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.MA
                            ] = programPermissionItems[i].selectedPermission;
                        }else if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.MA 
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.MA
                            ] = null;
                        }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.SN &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.SN
                            ] = programPermissionItems[i].selectedPermission;
                        }else if( programPermissionItems[i].programName ===
                            this.sspConstants.programValues.SN ){
                                this.saveRecord[
                                    this.sspConstants.ACRFieldAPINames.SN
                                ] = null;
                        }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.CC &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.CC
                            ] = programPermissionItems[i].selectedPermission;
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.CC){
                                this.saveRecord[
                                    this.sspConstants.ACRFieldAPINames.CC
                                ] = null; 
                            }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KT &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.KT
                            ] = programPermissionItems[i].selectedPermission;
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.KT){
                                this.saveRecord[
                                    this.sspConstants.ACRFieldAPINames.KT
                                ] = null; 
                            }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KP &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.KP
                            ] = programPermissionItems[i].selectedPermission;
                        } else if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KP){
                                    this.saveRecord[
                                        this.sspConstants.ACRFieldAPINames.KP
                                    ] = null;    
                                }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.SS &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            this.saveRecord[
                                this.sspConstants.ACRFieldAPINames.SS
                            ] = programPermissionItems[i].selectedPermission;
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.SS){
                                this.saveRecord[
                                    this.sspConstants.ACRFieldAPINames.SS
                                ] = null; 
                            }
                    }
                    let isProgramPermissionSelected = false;
                    if (!isChecked) {
                        this.showErrorToast = true;
                        this.showError = true;
                    } else if (!hasError) {
                        this.allowSave = true;
                        isProgramPermissionSelected = true;
                    } else {
                        this.showErrorToast = true;
                    }
                    
                    //Start - Added as a part of CD2 R3 Section 5.8.1.1
                    //Added Required validation for Relationship & Address field.
                    const inputElement = this.template.querySelectorAll(".ssp-inputElement"); 
                    this.checkValidations(inputElement);
                    //End - Added as a part of CD2 R3 Section 5.8.1.1
                    
                    if (isProgramPermissionSelected && this.allowSave) {
                        //Start - Added as a part of CD2 R3 Section 5.8.1.1
                        //To store RepresentativeRelationshipCode__c value.
                        if (inputElement && inputElement.length > 0) {
                            for (let index = 0; index < inputElement.length; index++) {
                                const element = inputElement[index];
                                if (element.fieldName === sspConstants.accountContactRelationFields.RepresentativeRelationshipCode__c) {
                                    this.saveRecord[sspConstants.accountContactRelationFields.RepresentativeRelationshipCode__c] = element.value;
                                    break;
                                }
                            }
                        }
                        //To store Address & Address Line 2 value.
                        if (!this.isSelectedViaSearch) {
                            let contact = {};                            
                            const contactList = [];
                            let detailMap = {};
                            contact = JSON.parse(
                                this.permissionParam.contactJSON
                            )[0];
                            //updateContact = this.bindAddressFields(contact);
                            contactList.push(contact);
                            detailMap = JSON.parse(
                                this.permissionParam.detailJSON
                            );
                            const mParam = {
                                contactJSON: JSON.stringify(contactList),
                                relationJSON: null,
                                detailJSON: JSON.stringify(detailMap)
                            };
                            this.permissionParam = mParam;
                        }
                        //End - Added as a part of CD2 R3 Section 5.8.1.1.
                        if ( !sspUtility.isUndefinedOrNull(this.saveRecord.accountId)){
                            this.saveRecord.accountId = this.accountId;  
                             }else{
                                this.saveRecord.accountId = this.applicationId;
                             } 
                             /* Commented - As a part of CD2 R3 Section 5.8.1.1
                             if ( !sspUtility.isUndefinedOrNull(this.relationshipCode)){
                             this.saveRecord[
                                sspConstants.accountContactRelationFields
                                    .RepresentativeRelationshipCode__c
                            ] =this.relationshipCode;
                            }                            
                            */
                        this.strAccountRelation = JSON.stringify(this.saveRecord);
                   
                     this.showConsent = true;                    
                     this.showPermissionClass = "slds-hide";
                     
                    }
                }
         } catch (error) {
            console.error(
                "failed in saveDetails in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }

     /**
     * @function 		: handleAuthRepRequest.
     * @description 	: this method is handle validations and update data.
     * */

    handleAuthRepRequest = () => {
        try { 
            if ((this.relationId !== null && this.relationId !== undefined && this.relationId !== "")) {
                this.saveRecord.Id = this.relationId;
            }
                if ((this.accountId === null || this.accountId === undefined) && !this.editPermissions) {
                    this.showCaseError = true;
                } else {                   
                    const accountContactRelation ={};
                    const addressDetails ={};
                    const programPermission ={};
                    const applicationResponse ={};
                    const loginUserDetails ={};                    
                    let sourceIndividualId ="";
                    let hasPermissionsChanged=false;
                    let caseNumber ="";
                    let applicationNumber ="";                    
                    const contact ={};
                    this.bindAddressFields(addressDetails);
                    const addressElement = this.template.querySelector(sspConstants.classNames.addressLineClass).ErrorMessages();
                   
                  
                    const programPermissionItems = this.template.querySelectorAll(
                        this.sspConstants.classNames.sspApplicationInputs
                    );
                    if(!this.editPermissions){                 
                   this.saveRecord ={}; 
                    this.saveRecord[
                        sspConstants.accountContactRelationFields
                            .RepresentativeRelationshipCode__c
                    ] = this.relationshipCode;               
                    }
                   
                  
                    let hasError = false;
                    let isChecked = false;
                    if(addressElement.length >0){
                        hasError = true;
                    }
                   
                    for (let i = 0; i < programPermissionItems.length; i++) {
                        if (!hasError) {
                            hasError = programPermissionItems[
                                i
                            ].handleValidations();
                        } else {
                            programPermissionItems[i].handleValidations();
                        }
                        if (!isChecked) {
                            isChecked =
                                programPermissionItems[i].programCheckbox;
                        }
                        if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.MA &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.MA
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.MA] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.MA] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.MA] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        }else if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.MA 
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.MA
                            ] = null;
                        }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.SN &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.SN
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.SN] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.SN] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.SN] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        }else if( programPermissionItems[i].programName ===
                            this.sspConstants.programValues.SN ){
                                programPermission[
                                    this.sspConstants.ACRFieldAPINames.SN
                                ] = null;
                        }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.CC &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.CC
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.CC] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.CC] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.CC] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.CC){
                                programPermission[
                                    this.sspConstants.ACRFieldAPINames.CC
                                ] = null; 
                            }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KT &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.KT
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.KT] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.KT] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.KT] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.KT){
                                programPermission[
                                    this.sspConstants.ACRFieldAPINames.KT
                                ] = null; 
                            }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KP &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.KP
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.KP] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.KP] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.KP] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        } else if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.KP){
                                    programPermission[
                                        this.sspConstants.ACRFieldAPINames.KP
                                    ] = null;    
                                }
                         if (
                            programPermissionItems[i].programName ===
                                this.sspConstants.programValues.SS &&
                            programPermissionItems[i].programCheckbox
                        ) {
                            programPermission[
                                this.sspConstants.ACRFieldAPINames.SS
                            ] = programPermissionItems[i].selectedPermission;
                            if(this.mapProgramVsPermission[this.sspConstants.programValues.SS] !== undefined && this.mapProgramVsPermission[this.sspConstants.programValues.SS] !== null &&
                                this.mapProgramVsPermission[this.sspConstants.programValues.SS] !== programPermissionItems[i].selectedPermission){
                                     hasPermissionsChanged=true;

                                }
                        }else if(programPermissionItems[i].programName ===
                            this.sspConstants.programValues.SS){
                                programPermission[
                                    this.sspConstants.ACRFieldAPINames.SS
                                ] = null; 
                            }
                    }
                    let isProgramPermissionSelected = false;
                    if (!isChecked) {
                        this.showErrorToast = true;
                        this.showError = true;
                    } else if (!hasError) {
                        this.allowSave = true;
                        isProgramPermissionSelected = true;
                    } else {
                        this.showErrorToast = true;
                    }
                    
                    //Start - Added as a part of CD2 R3 Section 5.8.1.1
                    //Added Required validation for Relationship & Address field.
                    const inputElement = this.template.querySelectorAll(".ssp-inputElement"); 
                    this.checkValidations(inputElement);
                    //End - Added as a part of CD2 R3 Section 5.8.1.1
                    
                    if (isProgramPermissionSelected && this.allowSave) {
                        //Start - Added as a part of CD2 R3 Section 5.8.1.1
                        //To store RepresentativeRelationshipCode__c value.
                        if (inputElement && inputElement.length > 0) {
                            for (let index = 0; index < inputElement.length; index++) {
                                const element = inputElement[index];
                                if (element.fieldName === sspConstants.accountContactRelationFields.RepresentativeRelationshipCode__c) {
                                    this.relationshipCode = element.value;
                                    break;
                                }
                            }
                        }
                        if((!sspUtility.isUndefinedOrNull(this.applicationDetail))
                        && (!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Application__r))
                        && (!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r))){
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Application__r.Name)){
                                applicationResponse.ApplicationNumber =this.applicationDetail.SSP_Application__r.Name;
                                applicationNumber=this.applicationDetail.SSP_Application__r.Name;
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Application__r.DCCaseNumber__c)){                                
                                caseNumber=this.applicationDetail.SSP_Application__r.DCCaseNumber__c.toString();
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Application__r.ProgramsApplied__c)){
                                applicationResponse.ProgramCode =this.applicationDetail.SSP_Application__r.ProgramsApplied__c;
                            }else{
                                applicationResponse.ProgramCode ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Application__r.LastModifiedDate)){
                                applicationResponse.LastUpdatedDate =this.applicationDetail.SSP_Application__r.LastModifiedDate;
                            }else{
                                applicationResponse.LastUpdatedDate ="";
                            }
                            if((!sspUtility.isUndefinedOrNull(this.authRepDetails)) &&  (!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact) && 
                            (!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact[sspConstants.contactFields.DCDataId__c])))){
                                applicationResponse.UserId =this.authRepDetails.Contact[sspConstants.contactFields.DCDataId__c];
                            }else{
                                applicationResponse.UserId ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.FirstName__c)){
                                applicationResponse.FirstName =this.applicationDetail.SSP_Member__r.FirstName__c;
                            }else{
                                applicationResponse.FirstName ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.LastName__c)){
                                applicationResponse.LastName =this.applicationDetail.SSP_Member__r.LastName__c;
                            }else{
                                applicationResponse.LastName ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.Email__c)){
                                applicationResponse.Email =this.applicationDetail.SSP_Member__r.Email__c;
                            }else{
                                applicationResponse.Email ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.PreferredNotificationMethodCode__c)){
                                applicationResponse.PreferredNotificationMethodCode =this.applicationDetail.SSP_Member__r.PreferredNotificationMethodCode__c;
                            }else{
                                applicationResponse.PreferredNotificationMethodCode ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.PreferredWrittenLanguageCode__c)){
                                applicationResponse.PreferredWrittenLanguageCode =this.applicationDetail.SSP_Member__r.PreferredWrittenLanguageCode__c;
                            }else{
                                applicationResponse.PreferredWrittenLanguageCode ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.PrimaryPhoneNumber__c)){
                                applicationResponse.PrimaryPhoneNumber =this.applicationDetail.SSP_Member__r.PrimaryPhoneNumber__c;
                            }else{
                                applicationResponse.PrimaryPhoneNumber ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.applicationDetail.SSP_Member__r.IndividualId__c)){
                                sourceIndividualId =this.applicationDetail.SSP_Member__r.IndividualId__c;
                            }else{
                                sourceIndividualId ="";
                            }

                        }
                        if((!sspUtility.isUndefinedOrNull(this.authRepDetails))
                        && (!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact))
                        ){
                            if(!sspUtility.isUndefinedOrNull(this.authRepDetails.Id)){
                               loginUserDetails.Id=this.authRepDetails.Id
                            }else{
                                loginUserDetails.Id ="";
                            }
                            if(!sspUtility.isUndefinedOrNull(this.authRepDetails.ContactId)){
                                loginUserDetails.ContactId=this.authRepDetails.ContactId;                               
                             }else{
                                 loginUserDetails.ContactId ="";
                                 
                             }
                             if(!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact.FirstName)){
                                contact.FirstName=this.authRepDetails.Contact.FirstName;
                             }else{
                                contact.FirstName ="";
                             }
                             if(!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact.LastName)){
                                contact.LastName=this.authRepDetails.Contact.LastName;
                             }else{
                                contact.LastName ="";
                             }
                             if(!sspUtility.isUndefinedOrNull(this.authRepDetails.Contact.DCDataId__c)){
                                contact[sspConstants.contactFields.DCDataId__c]=this.authRepDetails.Contact[sspConstants.contactFields.DCDataId__c];
                             }else{
                                contact[sspConstants.contactFields.DCDataId__c] ="";
                             }
                             if(!sspUtility.isUndefinedOrNull(this.authRepDetails.ContactId)){                              
                                contact.Id= this.authRepDetails.ContactId;
                             }else{                               
                                 contact.Id= this.authRepDetails.ContactId;
                             }
                             loginUserDetails.Contact= contact;
                        }

                        accountContactRelation[
                            sspConstants.accountContactRelationFields
                                .RepresentativeRelationshipCode__c
                        ] = this.relationshipCode;
                        accountContactRelation.programPermission = programPermission;
                        accountContactRelation.addressDetails = addressDetails;
                        const mParam = {
                            "accountContactRelation": accountContactRelation,                           
                            "sourceIndividualId" : sourceIndividualId,
                            "caseNumber" : caseNumber,
                            "applicationNumber" : applicationNumber,
                            "loginUserDetails" : [loginUserDetails],                            
                            "reverseSSPDCResponse": {},
                            "applicationResponse":[applicationResponse]
                        };
                        this.permissionParam = mParam;
                       
                       
                        
                     if(this.authRepRequest && hasPermissionsChanged){
                         this.showSpinner = true;
                        requestAccess({
                            sRequestAccessDetails: JSON.stringify(this.permissionParam)                   
                        }).then(result => {                   
                            const parsedData = result.mapResponse;  
                           
                            if (
                                !sspUtility.isUndefinedOrNull(parsedData) &&
                                parsedData.hasOwnProperty("ERROR")
                            ) {
                                this.errorCode = parsedData.ERROR;
                                this.showErrorModal = true;                       
                               
                            } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                                if (
                                    (!sspUtility.isUndefinedOrNull(parsedData)) &&
                                    parsedData.hasOwnProperty("requestAccessData")
                                ) {   
                                this.dispatchEvent(new CustomEvent(sspConstants.events.save));
                                this.showSpinner = false;

                                }
                            }
                           
                        });
                     }else {
                        this.dispatchEvent(new CustomEvent(sspConstants.events.save));
                        this.showSpinner = false;
                     }
                    }
                }
         } catch (error) {            
            console.error(
                "failed in saveDetails in SspAddAuthRepProgram" +
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
    connectedCallback (){
        if(this.editPermissions && sspUtility.isUndefinedOrNull(this.programs) && !sspUtility.isUndefinedOrNull(this.programsMap)){
            this.programs = this.programsMap[this.applicationId];
            this.showPrograms = true;
           
        }
        if(sspUtility.isUndefinedOrNull(this.relationId)){
            this.relationId = "";
        }
        //Start - Added as a part of CD2 R3 Section 5.8.1.1.
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            sspConstants.contactFields.Street__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.City__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.CountyCode__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.SSP_State__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.ZipCode5__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.ZipCode4__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.contactFields.AddressLine2__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation,
            sspConstants.accountContactRelationFields
                .RepresentativeRelationshipCode__c +
                "," +
                sspConstants.sspObjectAPI.AccountContactRelation
        );
        this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "REPS_AddAuthorizedRepresentative1"
        );

        //To set the Relationship picklist field option
        if (this.contactInformation && this.contactInformation.relationshipCodes) {
            const relationshipCodes = [];
            const valueLabelMapping = this.contactInformation.relationshipCodes;
            Object.keys(valueLabelMapping).forEach(value => {
                relationshipCodes.push({
                    value: value,
                    label: valueLabelMapping[value]
                });
            });
            this.representativeRelationshipCodes = relationshipCodes;
        }
        
        //To prepopulate the Relationship field value
        if (
            this.contactInformation &&
            this.contactInformation.accountContactRelationRecord &&
            this.contactInformation.accountContactRelationRecord
                .RepresentativeRelationshipCode__c
        ) {
            this.relationshipCode = this.contactInformation.accountContactRelationRecord.RepresentativeRelationshipCode__c;
        }
      
        //To set isSelectedViaSearch flag
        if (this.permissionParam && this.permissionParam.detailJSON) {
            const detailJSON = JSON.parse(this.permissionParam.detailJSON);
            this.isSelectedViaSearch = detailJSON.isSelectedViaSearch;
        }
        //To prepopulate the Address Line structure
        if (this.permissionParam && this.permissionParam.contactJSON) {
          //  let contact = {};
          
          //  contact = JSON.parse(this.permissionParam.contactJSON)[0];
                
            this.setAddressLineStructure(this.contactInformation.accountContactRelationRecord);
        }
        //End - Added as a part of CD2 R3 Section 5.8.1.1.
    }
    /**
     * @function 		: handleHideError.
     * @description 	: this method is handle validation errors.
    
     * */
    handleHideError = () => {
        try {
            const programPermissionItems = this.template.querySelectorAll(
                this.sspConstants.classNames.sspApplicationInputs
            );
            let hasError = true;
            for (let i = 0; i < programPermissionItems.length; i++) {
                if (programPermissionItems[i].programCheckbox) {
                    hasError = false;
                }
            }
            this.showError = hasError;
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleCancel.
     * @description 	: this method is handle show/hide sections.
    
     * */
    handleCancel = () => {
        try {
          this.dispatchEvent(new CustomEvent(sspConstants.addAuthRepConstants.close));
        } catch (error) {
            console.error(
                "failed in handleCancel in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }


    /**
     * @function 		: handleBack.
     * @description 	: this method is handle show/hide sections.
    
     * */
    handleBack  = () => {
        try {
          this.dispatchEvent(new CustomEvent(sspConstants.events.cancel));
        } catch (error) {
            console.error(
                "failed in handleBack in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleConsentBack.
     * @description 	: this method is handle show/hide sections.
    
     * */
    handleConsentBack = () => {
        try{
        this.showConsent = false;
        this.showPermissionClass = "slds-show";             
        this.selectedCaseNumber = this.accountId
        this.allowSave = false;       
        this.saveRecord ={}; 
          } 
          catch (error) {
            console.error(
                "failed in handleConsentBack in SspAddAuthRepProgram" +
                    JSON.stringify(error)
            );
        }
    }

    //Start - Added as a part of CD2 R3 Section 5.8.1.1.
    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on contact record.
     * @param {object} contact - Contact record.
     */
    bindAddressFields = contact => {
        try {
            const addressLineClass = this.template.querySelector(
                sspConstants.classNames.addressLineClass
            );
           
      
            if (this.addressRecord === undefined || (this.addressRecord !== undefined && this.addressRecord.fields.SSP_State__c.value === undefined || this.addressRecord.fields.SSP_State__c.value === null) || (!this.editPermissions) ||
            (this.editPermissions && addressLineClass && addressLineClass.hasChanged)) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                contact[
                    sspConstants.contactFields.Street__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                contact[
                    sspConstants.contactFields.AddressLine2__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                contact[
                    sspConstants.contactFields.City__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                contact[
                    sspConstants.contactFields.CountyCode__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                contact[
                    sspConstants.contactFields.SSP_State__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                const zipCode = physicalAddress.postalCode;
                if (!sspUtility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        contact[
                            sspConstants.contactFields.ZipCode4__c
                        ] = zipCode;
                        contact[sspConstants.contactFields.ZipCode5__c] = "";
                    } else {
                        contact[
                            sspConstants.contactFields.ZipCode5__c
                        ] = zipCode;
                        contact[sspConstants.contactFields.ZipCode4__c] = "";
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

    /**
     * @function - setAddressLineStructure.
     * @description - Use to set the Address Line Structure on Page Load.
     * @param {contact} contact - Contact.
     */
    setAddressLineStructure = (contact) => {
        try {
          
            const addressRecord = {};
            addressRecord.apiName = sspConstants.sspObjectAPI.AccountContactRelation;
            addressRecord.childRelationships = {};
            //addressRecord.id = contact.Id;

            const sFields = {};

            const addressLine1 = {};
            addressLine1.displayValue = null;
            addressLine1.value = contact[sspConstants.contactFields.Street__c] || null;
            sFields[sspConstants.contactFields.Street__c] = addressLine1;

            const addressLine2 = {};
            addressLine2.displayValue = null;
            addressLine2.value = contact[sspConstants.contactFields.AddressLine2__c] || null;
            sFields[sspConstants.contactFields.AddressLine2__c] = addressLine2;

            const city = {};
            city.displayValue = null;
            city.value = contact[sspConstants.contactFields.City__c] || null;
            sFields[sspConstants.contactFields.City__c] = city;

            const countyCode = {};
            countyCode.displayValue = null;
            countyCode.value = contact[sspConstants.contactFields.CountyCode__c] || null;

            sFields[sspConstants.contactFields.CountyCode__c] = countyCode;

            const stateCode = {};
            stateCode.displayValue = null;
            stateCode.value = contact[sspConstants.contactFields.SSP_State__c] || null;

            sFields[sspConstants.contactFields.SSP_State__c] = stateCode;

            const zipCode4 = {};
            zipCode4.displayValue = null;
            zipCode4.value = contact[sspConstants.contactFields.ZipCode4__c] || null;
            sFields[sspConstants.contactFields.ZipCode4__c] = zipCode4;

            const zipCode5 = {};
            zipCode5.displayValue = null;
            zipCode5.value = contact[sspConstants.contactFields.ZipCode5__c] || null;
            sFields[sspConstants.contactFields.ZipCode5__c] = zipCode5;

            addressRecord.fields = sFields; 
           
            if( (sFields[sspConstants.contactFields.Street__c].value !== null || sFields[sspConstants.contactFields.AddressLine2__c].value !== null || 
                sFields[sspConstants.contactFields.City__c].value !== null || sFields[sspConstants.contactFields.CountyCode__c].value !== null || 
                sFields[sspConstants.contactFields.SSP_State__c].value !== null || sFields[sspConstants.contactFields.ZipCode4__c].value !== null ||
                sFields[sspConstants.contactFields.ZipCode5__c].value !== null) &&  this.isSelectedViaSearch){
                this.disableAddress = true;
            }
          
            this.addressRecord = JSON.parse(JSON.stringify(addressRecord));            
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setAddressLineStructure" +
                    JSON.stringify(error.message)
            );
        }
    };
    //End - Added as a part of CD2 R3 Section 5.8.1.1.
}
