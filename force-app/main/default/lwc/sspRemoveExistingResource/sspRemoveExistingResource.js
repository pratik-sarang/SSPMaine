/**
 * Component Name: sspResourceDetails.
 * Author: Kyathi Kanumuri, Karthik Gulla.
 * Description: This screen is used for Removal of Existing Resource.
 * Date: 12/23/2019.
 */
import { api, track, wire } from "lwc";
import sspResourceEndDate from "@salesforce/label/c.SSP_EndDate";
import sspEndReason from "@salesforce/label/c.SSP_EndReason";
import sspEndReasonAlternate from "@salesforce/label/c.SSP_EndReasonAlternateText";
import sspNoResourcesQuestionLabel from "@salesforce/label/c.SSP_NoResourcesQuestionLabel";
import sspOwnsResourceText from "@salesforce/label/c.SSP_OwnsResourceText";
import sspSelectOption from "@salesforce/label/c.SSP_SelectOption";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import getExistResources from "@salesforce/apex/SSP_ExistResourcesController.getExistingResourcesForChangeOrRemoval";
import apConstants from "c/sspConstants";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import SSPASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import utility,{ formatLabels, getPicklistSubTypeValues } from "c/sspUtility";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import RESOURCEID_FIELD from "@salesforce/schema/SSP_Asset__c.Id";
import RESOURCEENDDATE_FIELD from "@salesforce/schema/SSP_Asset__c.EndDate__c";
import RESOURCEENDREASON_FIELD from "@salesforce/schema/SSP_Asset__c.ResourceEndReason__c";
import RESOURCEISDELETED_FIELD from "@salesforce/schema/SSP_Asset__c.IsDeleted__c";
import sspSelectResourceErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import updateExistingResources from "@salesforce/apex/SSP_ExistResourcesController.updateExistingResources";
import getApplicationIndividualRecord from "@salesforce/apex/SSP_ResourcesService.getApplicationIndividualForMember";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVOWNSRESOURCE_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsMemberStillOwnsResources__c";

export default class sspRemoveExistingResource extends BaseNavFlowPage {
    @api applicationId;
    @api memberId;
    @api memberName;
    @api resourceRecordTypeId;

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        try{
            return this.allowSaveValue;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getAllowSaveData + JSON.stringify(error.message));
            return null;
        }
    }
    set allowSaveData (value) {
        try{
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.allowSaveValue = value;
                this.saveRemovalResourcesData();
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.setAllowSaveData + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        try{
            return this.MetaDataListParent;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getMetadataList + JSON.stringify(error.message));
            return null;
        }
    }
    set MetadataList (value) {
        try{
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.MetaDataListParent = value;
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.setMetadataList + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        try{
            return this.memberIdValue;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getMemberId + JSON.stringify(error.message));
            return null;
        }
    }
    set memberId (value) {
        try{
            this.memberIdValue = value;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.setMemberId + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for next event.
     * @description : Getter setter methods for next event.
     */
    @api
    get nextEvent () {
        try{
            return this.nextValue;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getNextEvent + JSON.stringify(error.message));
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                const checkboxValueList = this.template.querySelectorAll(".ssp-removeResourceCheckbox");
                const ownsCheckboxValue = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");
                let atLeastOneChecked = false;

                checkboxValueList.forEach(cValue => {
                    if (cValue.isChecked) {
                        atLeastOneChecked = true;
                    }
                });
                if (ownsCheckboxValue[0].isChecked || atLeastOneChecked) {
                    this.hasSaveValidationError = false;
                    this.noResourceSelected = false;
                    if (this.template.querySelector(".ssp-removeResource_container")){
                        this.template.querySelector(".ssp-removeResource_container").classList.remove("ssp-checkbox-error");
                    }
                } else {
                    const showToastEvent = new CustomEvent("showcustomtoast", {
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(showToastEvent);
                    this.noResourceSelected = true;
                    if (this.template.querySelector(".ssp-removeResource_container")) {
                        this.template.querySelector(".ssp-removeResource_container").classList.add("ssp-checkbox-error");
                    }
                }
                if(!this.noResourceSelected) {
                    this.getRequiredInputElements();
                }
                else {
                    this.templateInputsValue = "invalid";
                }
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.setNextEvent + JSON.stringify(error.message));
        }
    }

    @track sspNoResourcesQuestionLabelText;
    @track sspOwnsResourceText;
    @track existResources = [];
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track resourceDetails;
    @track noResourceSelected = false;
    @track showSpinner = false;
    @track allResourceEndReasonOptions;
    @track stillOwnsResource = false;
    @track appIndividualRecordId;
    @track timeTravelDate;
    @track applicationPrograms = [];

    label = {
        sspResourceEndDate,
        sspEndReason,
        sspEndReasonAlternate,
        sspNoResourcesQuestionLabel,
        sspSelectOption,
        toastErrorText,
        sspSelectResourceErrorMessage
    };
    
    /**
     * @function : Wire property to get SSP_Asset object Info
     * @description : Wire property to get SSP_Asset object Info.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getObjectInfo, { objectApiName: SSPASSET_OBJECT })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                this.hasSaveValidationError = false;
                const recordTypeInformation = data[apConstants.resourceDetailConstants.resourceRecordTypes];
                this.resourceRecordTypeId = Object.keys(recordTypeInformation).find(
                    recTypeInfo => recordTypeInformation[recTypeInfo].name === apConstants.resourceDetailConstants.resourceRecordTypeName
                );
            } else if (error) {
                console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getObjectInfoWiredMethod + JSON.stringify(error.message));
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getObjectInfoWiredMethod + JSON.stringify(error.message));
            this.hasSaveValidationError = true;
        }
    }

    /**
     * @function : Wire property to get picklist values
     * @description : Wire property to get picklist values.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$resourceRecordTypeId",
        fieldApiName: RESOURCEENDREASON_FIELD
    })
    picklistTypeOptions ({ error, data }) {
        try {
            if (data) {
                this.allResourceEndReasonOptions = data;
                this.getApplicationIndividualDetails();
            } else if (error) {
                console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getPicklistValues + JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getPicklistValues + JSON.stringify(error.message));
        }
    }

    /**
     * @function : renderedCallback
     * @description : Rendered on load of removal of existing resource page.
     */
    renderedCallback () {
        try{
            //this.handleOwnResourcesAction();
            const checkboxValueList = this.template.querySelectorAll(".ssp-removeResourceCheckbox");
            const ownsCheckboxValue = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");

            if (!utility.isUndefinedOrNull(ownsCheckboxValue[0])){
                ownsCheckboxValue[0].isChecked = this.stillOwnsResource;
                checkboxValueList.forEach(cValue => {
                    cValue.disabled = ownsCheckboxValue[0].isChecked;
                });
            }
        } catch(error){
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.connectedCallback + JSON.stringify(error.message));
        }
    }

    /**
     * @function : connectedCallback
     * @description : Rendered on load of removal of existing resource page.
     */
    connectedCallback () {
        try {
            this.sspNoResourcesQuestionLabelText = formatLabels(sspNoResourcesQuestionLabel,[this.memberName]);
            this.sspOwnsResourceText = formatLabels(sspOwnsResourceText, [this.memberName]);

            const removeExistResourcesFieldEntityNameList = apConstants.removeResourcesFieldEntityNameList;
            this.getMetadataDetails(
                removeExistResourcesFieldEntityNameList,
                null,
                apConstants.removeExistResourceConstants.removeExistResourcePage
            );
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.connectedCallback + JSON.stringify(error.message));
        }
    }

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast () {
        try{
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.hideToast + JSON.stringify(error.message));
        }
    }

    /* @function : handleCheckboxAction
     * @description: Method to handle checkbox action
     * @param {event} event - Event Details.
     */
    handleCheckboxAction = (event) => {
        try {
            this.resourceDetails = event.detail;
            const checkboxValueList = this.template.querySelectorAll(".ssp-removeResourceCheckbox");
            const ownsCheckboxValue = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");
            let disableOwnsResourceCheckbox = false;
            
            //Check if at least one resource is checked and disabled the owns resource checkbox
            checkboxValueList.forEach(cValueList => {
                if (cValueList.isChecked) {
                    disableOwnsResourceCheckbox = true;
                    this.noResourceSelected = false;
                    if (this.template.querySelector(".ssp-removeResource_container")) {
                        this.template.querySelector(".ssp-removeResource_container").classList.remove("ssp-checkbox-error");
                    }
                } else {
                    ownsCheckboxValue[0].disabled = false;
                }
            });

            if (disableOwnsResourceCheckbox) {
                ownsCheckboxValue[0].disabled = true;
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.handleCheckboxAction + JSON.stringify(error.message));
        }
    }

    /* @function : handleOwnResourcesAction
     * @description: Method to handle checkbox action when ownsResource is changed.
     */
    handleOwnResourcesAction = () => {
        try {
            const checkboxValueList = this.template.querySelectorAll(".ssp-removeResourceCheckbox");
            const ownsCheckboxValue = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");

            checkboxValueList.forEach(cValue => {
                cValue.disabled = ownsCheckboxValue[0].isChecked;
            });
            
            this.stillOwnsResource = ownsCheckboxValue[0].isChecked;
            this.noResourceSelected = false;
            if (this.template.querySelector(".ssp-removeResource_container")) {
                this.template.querySelector(".ssp-removeResource_container").classList.remove("ssp-checkbox-error");
            }
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.handleOwnResourcesAction + JSON.stringify(error.message));
        }
    }

    /* @function : saveRemovalResourcesData
     * @description: Method to save removal of resources data.
     */
    saveRemovalResourcesData = () => {
        try {
            const checkboxValueList = this.template.querySelectorAll(".ssp-removeResourceCheckbox");
            const endDateValues = this.template.querySelectorAll(".ssp-removeExResourceEndDate");
            const endReasonValues = this.template.querySelectorAll(".ssp-removeExResourceEndReason");
            const endDateSelectedValues = {};
            const endReasonSelectedValues = {};

            endDateValues.forEach(endDateValue => {
                const dataRecordId = endDateValue.getAttribute("data-record");
                endDateSelectedValues[dataRecordId] = endDateValue.value;
            });

            endReasonValues.forEach(endReasonValue => {
                const dataRecordId = endReasonValue.getAttribute("data-record");
                endReasonSelectedValues[dataRecordId] = endReasonValue.value;
            });

            const deletedResourceValues = [];
            checkboxValueList.forEach(cValue => {
                const currentCheckboxResource = cValue.objectData;
                const currentRecordId = currentCheckboxResource[apConstants.resourceSummary.resourceId];

                //Check user selected values and form an array to update values
                const selectedRecord = {};
                if (cValue.isChecked){
                    if (endDateSelectedValues[currentRecordId] != undefined
                        && endReasonSelectedValues[currentRecordId] != undefined
                        && !currentCheckboxResource.bHideAdditionalDetails) {
                        selectedRecord[RESOURCEENDDATE_FIELD.fieldApiName] = endDateSelectedValues[currentRecordId];
                        selectedRecord[RESOURCEENDREASON_FIELD.fieldApiName] =
                            endReasonSelectedValues[currentRecordId];
                    } 
                    selectedRecord[RESOURCEID_FIELD.fieldApiName] = currentRecordId;
                    selectedRecord[RESOURCEISDELETED_FIELD.fieldApiName] = true;
                    deletedResourceValues.push(selectedRecord);
                }
            });

            /* @sUpdatedValues {String} array converted to string with updated values.
             * @returns {Boolean} Returns a response with true or false.
            */
            updateExistingResources({
                sUpdatedValues: JSON.stringify(deletedResourceValues),
                sMemberId: this.memberId
            })
            .then(result => {
                const appIndividualRecord = {};
                appIndividualRecord[APPLICATIONINDIVID_FIELD.fieldApiName] = this.appIndividualRecordId;
                appIndividualRecord[APPLICATIONINDIVOWNSRESOURCE_FIELD.fieldApiName] = !utility.isUndefinedOrNull(this.stillOwnsResource) ? this.stillOwnsResource : false;
 
                const recordInput = {};
                recordInput.fields = appIndividualRecord;

                //lwc standard updateRecord call to update application individual record
                updateRecord(recordInput)
                .then(() => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error(apConstants.resourceSelectionConstants.resourceRemovalError.saveRemovalResourcesData + JSON.stringify(error.message));
                })
            })
            .catch(error => {
                console.error(apConstants.removeExistResourceConstants.resourceRemovalError.saveRemovalResourcesData + error);
            });
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.saveRemovalResourcesData + JSON.stringify(error.message));
            this.saveCompleted = false;
        }
    }

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            const removeResourceEndDateItems = this.template.querySelectorAll(".ssp-removeExResourceEndDate");
            const removeResourceEndReasonItems = this.template.querySelectorAll(".ssp-removeExResourceEndReason");
            const noRemoveResourcesItems = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");
            const removeResourceItemsArray = new Array();

            removeResourceEndDateItems.forEach(resourceEndDateItem => {
                removeResourceItemsArray.push(resourceEndDateItem);
            });

            removeResourceEndReasonItems.forEach(resourceEndReasonItem => {
                removeResourceItemsArray.push(resourceEndReasonItem);
            });

            noRemoveResourcesItems.forEach(noRemoveResourceItem => {
                removeResourceItemsArray.push(noRemoveResourceItem);
            });
            this.templateInputsValue = removeResourceItemsArray;
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getRequiredInputElements + JSON.stringify(error.message));
        }
    }
    
    /*
     * @function : getExistingResources
     * @description : This method used to get existing resources.
     */
    getExistingResources = () => {
        try {
            this.showSpinner = true;
            const mapResInputs = {};
            mapResInputs.memberId = this.memberId;
           /* @mapResInputs {map} value The input value with member Id details.
            * @returns { String JSON } Returns a string JSON with existing resource details.
            */
            getExistResources({
                mapInputs: mapResInputs,
                lstAppPrograms: this.applicationPrograms
            })
            .then(result => {
                this.existResources = JSON.parse(result.mapResponse.ExistingResources);
                this.existResources.forEach(existResource => {
                    existResource.resourceEndReasonOptions = getPicklistSubTypeValues(
                        existResource[apConstants.resourceSummary.resourceType],
                        this.allResourceEndReasonOptions
                    );
                });
                this.timeTravelDate = result.mapResponse.timeTravelDate;
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getExistingResources + JSON.stringify(error.message));
                this.showSpinner = false;
            });
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getExistingResources + JSON.stringify(error.message));
            this.showSpinner = false;
        }
    }

    /*
    * @function : getApplicationIndividualDetails
    * @description : This method used to get existing application individual details.
    */
    getApplicationIndividualDetails = () => {
        try {
            this.showSpinner = true;
            /* @sApplicationId {applicationId} applicationId.
             * @sMemberId {memberId} memberId.
             * @returns { String JSON } Returns a string JSON with existing applicationIndividual details.
             */
            getApplicationIndividualRecord({
                sApplicationId : this.applicationId,
                sMemberId : this.memberId
            })
            .then(result => {
                this.stillOwnsResource = !utility.isArrayEmpty(result) ? result[0].IsMemberStillOwnsResources__c : false;
                this.appIndividualRecordId = !utility.isArrayEmpty(result) ? result[0].Id : null;
                //Added to Filter Resources based on Programs
                this.applicationPrograms = (!utility.isArrayEmpty(result) && !utility.isUndefinedOrNull(result[0].ProgramsApplied__c)) ? result[0].ProgramsApplied__c.split(";") : [];

                if (!utility.isUndefinedOrNull(this.applicationPrograms)
                    && this.applicationPrograms.includes(apConstants.programValues.MA)
                    && !utility.isUndefinedOrNull(result[0].MedicaidType__c)) {
                    this.applicationPrograms.push(result[0].MedicaidType__c);
                }
                this.showSpinner = false;
                this.getExistingResources();
            })
            .catch(error => {
                console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getExistingResources + JSON.stringify(error.message));
                this.showSpinner = false;
            });
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getExistingResources + JSON.stringify(error.message));
            this.showSpinner = false;
        }
    }
}