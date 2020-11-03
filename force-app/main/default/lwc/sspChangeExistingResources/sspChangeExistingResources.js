/**
 * Component Name: sspChangeExistingResources.
 * Author: Kyathi Kanumuri, Karthik Gulla.
 * Description: This screen is used for change data of Existing Resource.
 * Date: 01/06/2020.
 */
import { track, api } from "lwc";
import sspResourceNotChangedLabel from "@salesforce/label/c.SSP_ResourceNotChangedLabel";
import sspChangeResourceQuestionLabel from "@salesforce/label/c.SSP_ChangeResourceQuestionLabel";
import sspLifeInsuranceFaceValue from "@salesforce/label/c.SSP_LifeInsuranceFaceValue";
import sspLifeInsuranceSurrenderValue from "@salesforce/label/c.SSP_LifeInsuranceSurrenderValue";
import sspLoanAmountOwned from "@salesforce/label/c.SSP_LoanAmountOwned";
import sspPropertyFairMarketValue from "@salesforce/label/c.SSP_PropertyFairMarketValue";
import sspContractCost from "@salesforce/label/c.SSP_ContractCost";
import sspVehicleCurrentValue from "@salesforce/label/c.SSP_VehicleCurrentValue";
import sspVehicleAmountOwned from "@salesforce/label/c.SSP_VehicleAmountOwned";
import sspCurrencyValue from "@salesforce/label/c.SSP_CurrencyValue";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { formatLabels } from "c/sspUtility";
import apConstants from "c/sspConstants";
import getExistResources from "@salesforce/apex/SSP_ExistResourcesController.getExistingResourcesForChangeOrRemoval";
import sspSelectResourceErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import utility from "c/sspUtility";
import updateExistingResources from "@salesforce/apex/SSP_ExistResourcesController.updateExistingResources";
import getApplicationIndividualRecord from "@salesforce/apex/SSP_ResourcesService.getApplicationIndividualForMember";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVNOCHANGERESOURCE_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsNoChangesToResources__c";

export default class sspChangeExistingResources extends BaseNavFlowPage {
    @api memberId;
    @api memberName;
    @api applicationId;

    @track trueValue = true;
    @track falseValue = false;
    @track existResources = [];
    @track hasSaveValidationError = false;
    @track sspChangeResourceQuestionLabelText;
    @track sspResourceNotChangedLabel;
    @track noResourceSelected = false;
    @track showSpinner = false;
    @track noChangeToResource = false;
    @track appIndividualRecordId;
    @track applicationPrograms = [];

    //Custom Labels
    label = {
        sspCurrencyValue,
        sspLifeInsuranceFaceValue,
        sspLifeInsuranceSurrenderValue,
        sspLoanAmountOwned,
        sspPropertyFairMarketValue,
        sspContractCost,
        sspVehicleAmountOwned,
        sspVehicleCurrentValue,
        sspSelectResourceErrorMessage,
        toastErrorText
    };

    get changeResourceQuestionLabel () {
        return formatLabels(sspChangeResourceQuestionLabel, [this.memberName]);
    }

    get resourceNotChangedLabel () {
        return formatLabels(sspResourceNotChangedLabel, [this.memberName]);
    }

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        return this.allowSaveValue;
    }
    set allowSaveData (value) {
        if (!utility.isUndefinedOrNull(value)
            && !utility.isEmpty(value)) {
            this.allowSaveValue = value;
            this.saveChangeResourcesData();
        }
    }

    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (!utility.isUndefinedOrNull(value)) {
            this.MetaDataListParent = value;
        }
    }

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        return this.memberIdValue;
    }
    set memberId (value) {
        this.memberIdValue = value;
        if (!utility.isUndefinedOrNull(value)
            && !utility.isEmpty(value)
        ) {
            this.getApplicationIndividualDetails();
        }
    }

    /**
     * @function : Getter setter methods for next event.
     * @description : Getter setter methods for next event.
     */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value)
                && !utility.isEmpty(value)) {
                this.nextValue = value;
                const checkboxValueList = this.template.querySelectorAll(
                    ".ssp-changeResourceCheckbox"
                );

                const ownsCheckboxValue = this.template.querySelectorAll(
                    ".ssp-ownsResourceCheckbox"
                );
                
                //Check if at least one check box is selected else throw validation
                let atLeastOneChecked = false;
                checkboxValueList.forEach(cValueList => {
                    if (cValueList.isChecked) {
                        atLeastOneChecked = true;
                    }
                });

                if (ownsCheckboxValue[0].isChecked || atLeastOneChecked) {
                    this.hasSaveValidationError = false;
                    this.noResourceSelected = false;
                    if (this.template.querySelector(".ssp-changeResource_container")) {
                        this.template.querySelector(".ssp-changeResource_container").classList.remove("ssp-checkbox-error");
                    }
                } else {
                    this.noResourceSelected = true;
                    if (this.template.querySelector(".ssp-changeResource_container")) {
                        this.template.querySelector(".ssp-changeResource_container").classList.add("ssp-checkbox-error");
                    }
                }

                if (!this.noResourceSelected) {
                    //Get all the input elements for Selected records and add it base component for validations
                    this.getRequiredInputElements();
                }
                else {
                    const showToastEvent = new CustomEvent("showcustomtoast", {
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(showToastEvent);
                    this.templateInputsValue = "invalid";
                }
            }
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
        }
    }
    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        this.hasSaveValidationError = false;
    }

    /* @function : handleCheckboxAction
     * @description: Method to handle checkbox action
     * @param {event} event - Event Details.
     */
    handleCheckboxAction =(event)=> {
        try {
            this.resourceDetails = event.detail;
            const checkboxValueList = this.template.querySelectorAll(
                ".ssp-changeResourceCheckbox"
            );

            const ownsCheckboxValue = this.template.querySelectorAll(
                ".ssp-ownsResourceCheckbox"
            );
            
            let disableOwnsResourceCheckbox = false;
            //Check if at least one resource is checked and disabled the owns resource checkbox
            checkboxValueList.forEach(cValueList => {
                if (cValueList.isChecked) {
                    disableOwnsResourceCheckbox = true;
                    this.noResourceSelected = false;
                    if (this.template.querySelector(".ssp-changeResource_container")) {
                        this.template.querySelector(".ssp-changeResource_container").classList.remove("ssp-checkbox-error");
                    }
                } else {
                    ownsCheckboxValue[0].disabled = false;
                }
            });

            if (disableOwnsResourceCheckbox){
                ownsCheckboxValue[0].disabled = true;
            }
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
        }
    }

    /* @function : handleOwnResourcesAction
     * @description: Method to handle checkbox action when ownsResource is changed.
     */
    handleOwnResourcesAction =() =>{
        try {
            const checkboxValueList = this.template.querySelectorAll(
                ".ssp-changeResourceCheckbox"
            );

            const ownsCheckboxValue = this.template.querySelectorAll(
                ".ssp-ownsResourceCheckbox"
            );

            //check if owns resource checkbox is checked and disabled the resources to be selected
            checkboxValueList.forEach(cValueList => {
                cValueList.disabled = ownsCheckboxValue[0].isChecked;
            });
            this.noChangeToResource = ownsCheckboxValue[0].isChecked;
            this.noResourceSelected = false;
            if (this.template.querySelector(".ssp-changeResource_container")) {
                this.template.querySelector(".ssp-changeResource_container").classList.remove("ssp-checkbox-error");
            }
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
        }
    }
    
    /**
     * @function : renderedCallback
     * @description : Rendered on load of removal of existing resource page.
     */
    renderedCallback () {
        try {
            //this.handleOwnResourcesAction();
            const checkboxValueList = this.template.querySelectorAll(".ssp-changeResourceCheckbox");
            const ownsCheckboxValue = this.template.querySelectorAll(".ssp-ownsResourceCheckbox");
            if (!utility.isUndefinedOrNull(ownsCheckboxValue[0])){
                ownsCheckboxValue[0].isChecked = this.noChangeToResource;
                checkboxValueList.forEach(cValue => {
                    cValue.disabled = ownsCheckboxValue[0].isChecked;
                });
            }
        } catch (error) {
            console.error(apConstants.changeExistResourceConstants.resourceChangeError.connectedCallback + JSON.stringify(error.message));
        }
    }

    /**
     * @function : connectedCallback
     * @description : connected call back method used to set on load values.
     */
    connectedCallback (){
        try{
            const changeResourcesFieldEntityNameList =
                apConstants.changeResourcesFieldEntityNameList;
            this.getMetadataDetails(
                changeResourcesFieldEntityNameList,
                null,
                apConstants.resourceDetailConstants.resourceDetailPage
            );
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                error
            );
        }
    }

    /*
     * @function : getExistingResources
     * @description : This method used to get existing resources.
     */
    getExistingResources= ()=> {
        try {
            this.showSpinner = true;
            const mapResInputs = {};
            mapResInputs.memberId = this.memberId;
            /* @mapInputs {map} value The input value with member Id details.
             * @returns { String JSON } Returns a string JSON with existing resource details.
             */
            getExistResources({
                mapInputs: mapResInputs,
                lstAppPrograms: this.applicationPrograms
            })
                .then(result => {
                    this.existResources = JSON.parse(
                        result.mapResponse.ExistingResources
                    );

                    this.existResources.forEach(exResource => {
                        exResource.isResourceAccountInvestmentLiquid =
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.account ||
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.investment ||
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.otherLiquidResource
                                ? true
                                : false;
                        exResource.isResourceLifeInsurance =
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.lifeInsurance
                                ? true
                                : false;
                        exResource.isResourceRealEstate =
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.realEstateProperty
                                ? true
                                : false;
                        exResource.isResourceFuneralContract =
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.funeralContract
                                ? true
                                : false;
                        exResource.isResourceVehicle =
                            exResource[
                                apConstants.resourceSummary.resourceType
                            ] === apConstants.resourceTypes.vehicle
                                ? true
                                : false;
                        exResource.showLoanAmountOwed =
                            exResource.isResourceRealEstate ||
                            exResource.isResourceLifeInsurance
                                ? true
                                : false;
                    });
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        apConstants.changeExistResourceConstants
                            .resourceChangeError + error
                    );
                     this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
        }
    }

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements= ()=> {
        try {
            const changeExistingResourcesItems = this.template.querySelectorAll(
                ".ssp-changeExistingResourceInputs"
            );
            const noChangeExistingResourcesItems = this.template.querySelectorAll(
                ".ssp-ownsResourceCheckbox"
            );

            const changeResourceItemsArray = new Array();
            changeExistingResourcesItems.forEach(changeResourceItem => {
                changeResourceItemsArray.push(changeResourceItem);
            });
            noChangeExistingResourcesItems.forEach(noChangeResourceItem => {
                changeResourceItemsArray.push(noChangeResourceItem);
            });
            this.templateInputsValue = changeResourceItemsArray;
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
        }
    }

    /* @function : saveRemovalResourcesData
     * @description: Method to save removal of resources data.
     */
    saveChangeResourcesData =()=> {
        try {
            const memberSelectedValues = this.template.querySelectorAll(
                ".ssp-changeExistingResourceInputs"
            );

            const memberUpdatedValues = [];

            memberSelectedValues.forEach(memberSelected => {
                const dataRecordId = memberSelected.getAttribute(
                    "data-record"
                );
                const dataId = memberSelected.getAttribute(
                    "data-id"
                );
                const existSelectedRecord = memberUpdatedValues.filter(
                    resourceRecord => resourceRecord.Id === dataRecordId
                );

                //Check user selected values and form an array to update values
                if (!utility.isUndefinedOrNull(existSelectedRecord[0]) && 
                    !utility.isEmpty(existSelectedRecord[0])
                ) {
                    existSelectedRecord[0][dataId] =
                        String(memberSelected.value);
                } else {
                    const selectedRecord = new Object();
                    selectedRecord[dataId] = String(
                        memberSelected.value
                    );
                    selectedRecord[
                        apConstants.changeExistResourceConstants.recordId
                    ] = dataRecordId;
                    memberUpdatedValues.push(selectedRecord);
                }
            });

            /* @sUpdatedValues {String} array converted to string with updated values.
             * @returns {Boolean} Returns a response with true or false.
            */
            updateExistingResources({
                sUpdatedValues: JSON.stringify(memberUpdatedValues)
            })
            .then(result=> {
                const appIndividualRecord = {};
                appIndividualRecord[APPLICATIONINDIVID_FIELD.fieldApiName] = this.appIndividualRecordId;
                appIndividualRecord[APPLICATIONINDIVNOCHANGERESOURCE_FIELD.fieldApiName] = !utility.isUndefinedOrNull(this.noChangeToResource) ? this.noChangeToResource : false;

                const recordInput = {};
                recordInput.fields = appIndividualRecord;

                //lwc standard updateRecord call to update application individual record
                updateRecord(recordInput)
                .then(() => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error(apConstants.changeExistResourceConstants.resourceChangeError + JSON.stringify(error.message));
                })
            })
            .catch(error => {
                    console.error(
                        apConstants.changeExistResourceConstants
                            .resourceChangeError + error
                    );
                });
        } catch (error) {
            console.error(
                apConstants.changeExistResourceConstants.resourceChangeError +
                    error
            );
            this.saveCompleted = false;
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
                sApplicationId: this.applicationId,
                sMemberId: this.memberId
            })
                .then(result => {
                    this.noChangeToResource = !utility.isArrayEmpty(result) ? result[0].IsNoChangesToResources__c : false;
                    this.appIndividualRecordId = !utility.isArrayEmpty(result) ? result[0].Id : null;
                    //Added to Filter Resources based on Programs
                    this.applicationPrograms = (!utility.isArrayEmpty(result) && !utility.isUndefinedOrNull(result[0].ProgramsApplied__c)) ? result[0].ProgramsApplied__c.split(";") : [];
                    if (!utility.isUndefinedOrNull(this.applicationPrograms)
                        && this.applicationPrograms.includes(apConstants.programValues.MA)
                        && !utility.isUndefinedOrNull(result[0].MedicaidType__c)) {
                        this.applicationPrograms.push(result[0].MedicaidType__c); 
                    }
                    this.getExistingResources();
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
}