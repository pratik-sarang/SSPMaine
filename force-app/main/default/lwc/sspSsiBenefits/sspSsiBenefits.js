/**
 * Component Name : SspSsiBenefits.
 * Description : This Screen displays the SSI Benefit of a Member.
 * Author : Karthik,Velu & Sai Kiran.
 * Date : 01/08/2020.
 **/
import { track, api, wire } from "lwc";
import sspWhenDid from "@salesforce/label/c.SSP_SsiBenefitsWhenDid";
import sspDeniedDate from "@salesforce/label/c.SSP_SsiBenefitsDeniedDate";
import sspReasonDenied from "@salesforce/label/c.SSP_SsiBenefitsReasonDenied";
import sspApplicationStatus from "@salesforce/label/c.SSP_SsiBenefitsApplicationStatus";
import utility, { formatLabels } from "c/sspUtility";
import benefitConstants from "c/sspConstants";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import SSP_BENEFITS_OBJECT from "@salesforce/schema/SSP_Benefits__c";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import sBenefit from "@salesforce/apex/SSP_SSIBenefitCtrl.fetchSSIBenefits";
import updateBenefit from "@salesforce/apex/SSP_SSIBenefitCtrl.updateSSIBenefits";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

export default class SspSsiBenefits extends BaseNavFlowPage {
    @api memberName;
    @api benefitsRecordTypeID;
    @track appId;
    @track objValue;
    @track sspWhenDid;
    @track nextValue;
    @track dateCheck = false;
    @track memberIdValue;
    @track statusOptions;
    @track validationFlag;
    @track allowSaveValue;
    @track MetaDataListParent;
    @track sBenefitRecord = {};
    @track denialStatusOptions;
    @track applicationStatusOptions;
    @track showDeniedSection = false;
    @track hasSaveValidationError = false;
    @track toastErrorText;
    @track validationCheck = false;
    @track trueValue = true;
    @track showSpinner = false;
    @track hasMetadataListValues = false;
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspApplicationStatus,
        sspReasonDenied,
        sspDeniedDate,
        toastErrorText
    };

    get pageRenderingStatus () {
        if (this.isNotAccessible){
            return false;
        }
        return this.hasMetadataListValues;
    }

    /**
     * @function 	: memberId.
     * @description : This attribute is part of validation framework which gives the Member ID.
     * */
    @api
    get memberId () {
        return this.memberIdValue;
    }
    set memberId (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.memberIdValue = value;
            this.fetchBenefitsData(this.memberIdValue);
        }
    }

    /**
     * @function 	: nextEvent.
     * @description : This attribute is part of validation framework which is used to navigate to next Screen.
     * */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.saveData(); // use to check validations on component
            }
        } catch (error) {
            console.error(
                "Error in nextEvent of SSI Benefits Page" +
                    error
            );
        }
    }

    /**
     * @function 	: allowSaveData.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (this.validationFlag) {
            this.objValue = value;
            this.handleSaveEvent();
        }
    }
    /**
     * @function 	: handleSaveEvent.
     * @description : This is used to save Data in the Backend.
     * */
    handleSaveEvent () {
        try {
            this.showSpinner = true;
            const objBenefit = {};
            const jsonObjBenefit = JSON.parse(this.objValue);
            objBenefit.sApplicationStatus = jsonObjBenefit.sApplicationStatus;
            objBenefit.dBenefitApplicationDate =
                jsonObjBenefit.dBenefitApplicationDate;
            if (
                jsonObjBenefit.sApplicationStatus ===
                benefitConstants.benefitVariables.denialReasonValue
            ) {
                objBenefit.dBenefitDenialDate =
                    jsonObjBenefit.dBenefitDenialDate;
                objBenefit.sBenefitDenialReason =
                    jsonObjBenefit.sBenefitDenialReason;
            }
            objBenefit.sMemberId = this.memberIdValue;
            if (
                this.sBenefitRecord !== undefined ||
                this.sBenefitRecord !== null ||
                this.sBenefitRecord !== ""
            ) {
                objBenefit.sBenefitId = this.sBenefitRecord.sBenefitId;
            }
            updateBenefit({
                jsonObjBenefit: JSON.stringify(objBenefit)
            })
                .then(() => {
                    this.showSpinner = false;
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error(
                        "Error in SSI Benefit Page while Updating the SSP_Benefit Record" +
                            error
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error("Error occurred in handleSaveEvent" + error);
            this.showSpinner = false;
        }
    }
    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (!utility.isUndefinedOrNull(value)) {
            this.MetaDataListParent = value;
            this.hasMetadataListValues = true;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
            }
        }
    }

    /**
     * @function 	: applicationId.
     * @description : This attribute is part of validation framework which gives the application ID.
     * */
    @api
    get applicationId () {
        return this.appId;
    }
    set applicationId (value) {
        this.appId = value;
    }

    /**
     * @function 	: allowSave.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (!utility.isUndefinedOrNull(value)) {
            this.allowSaveValue = value;
        }
    }

    /**
     * @function 	: objWrap.
     * @description 	: this attribute contains validated data which is used to save.
     * */
    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        if (!utility.isUndefinedOrNull(value)) {
            this.objValue = value;
        }
    }

    /**
     * @function 	: Wire Function - getObjectInfo.
     * @description 	: this property is used to get the Record Type of Obj.
     * */
    @wire(getObjectInfo, {
        objectApiName: SSP_BENEFITS_OBJECT
    })
    objectInfo ({ data }) {
        try {
            if (data) {
                const recordTypeInformation =
                    data[
                        benefitConstants.resourceDetailConstants
                            .resourceRecordTypes
                    ];
                this.benefitsRecordTypeID = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name ===
                        benefitConstants.sspBenefitsFields.BenefitRecordType
                );
            }
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page while fetching record type of object" +
                    error
            );
        }
    }

    /**
     * @function 	: Wire Function - getPicklistValuesByRecordType.
     * @description 	: this property is used to get the Picklist of Obj.
     * */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSP_BENEFITS_OBJECT,
        recordTypeId: "$benefitsRecordTypeID"
    })
    picklistOptions ({ error, data }) {
        try {
            if (data) {
                this.applicationStatusOptions =
                    data.picklistFieldValues[
                        benefitConstants.sspBenefitsFields.StatusOfApplication__c
                    ].values;
                this.denialStatusOptions =
                    data.picklistFieldValues.BenefitDenialReason__c.values;
            } else if (error) {
                console.error(
                    "Error while trying to fetch picklist values on SSP_Benefit Object" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page while fetching picklist values" +
                    error
            );
        }
    }

    /**
     * @function : connectedCallback.
     * @description : This method is fetch the MetaData values on Load.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                benefitConstants.benefitVariables.BenefitFieldEntityNameList
            );
            fieldEntityNameList.push(
                "BenefitApplicationDate__c,SSP_Benefits__c"
            );
            fieldEntityNameList.push("BenefitDenialDate__c,SSP_Benefits__c");
            fieldEntityNameList.push("BenefitDenialReason__c,SSP_Benefits__c");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_SSIBenefits"
            );
            this.sspWhenDid = formatLabels(sspWhenDid, [this.memberName]);
            this.toastErrorText = this.label.toastErrorText;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page while fetching the Benefit Records & MetaData" +
                    error
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function 	: saveData.
     * @description : This function is part of validation framework which indicates data is valid or not and Used to Update SSI Benefits.
     * */
    saveData () {
        try {
            if (this.validationCheck) {
                const elem = this.template.querySelectorAll(
                    ".ssp-applicationInputs"
                );
                this.templateInputsValue = elem;
            } else {
                this.templateInputsValue = this.template.querySelectorAll(
                    ".ssp-benefitsSummaryInputs"
                );
            }
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page while updating record" +
                    error
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function : fetchBenefitsData.
     * @description : Function used to fetch to Benefit Records.
     * @param {string} memberId - Member id.
     */
    fetchBenefitsData (memberId) {
        try {
            this.showSpinner = true;
            sBenefit({
                sMemberId: memberId
            })
                .then(result => {
                    const objBenefit = result.mapResponse.sBenefitRecords;
                    this.sBenefitRecord = objBenefit;
                    this.validationCheck = true;
                    if (
                        objBenefit.sApplicationStatus ===
                        benefitConstants.benefitVariables.denialReasonValue
                    ) {
                        this.showDeniedSection = true;
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        "Error in SSI Benefit Page while Fetching the SSP_Benefit Record" +
                            error
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page" + 
                    error
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function : appStatusChange.
     * @description : This function will be called when user changes the Application Status.
     * @param {event} event - Event Details.
     */
    appStatusChange (event) {
        try {
            if (
                event.detail.value ===
                benefitConstants.benefitVariables.denialReasonValue
            ) {
                this.showDeniedSection = true;
            } else {
                this.showDeniedSection = false;
            }
        } catch (error) {
            console.error(
                "Error occurred in SSI Benefits page while changing the Application Status" +
                    error
            );
        }
    }

    /**
     * @function : hideToast.
     * @description	: Method to hide Toast.
     */
    hideToast () {
        this.hasSaveValidationError = false;
    }

        /**
    * @function : constructRenderingMap
    * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
    * @param {string} appPrograms - Application level programs.
    * @param {string} metaValue - Entity mapping data.
    */
     constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                    this.isNotAccessible = securityMatrix.screenPermission === benefitConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
            }
        } catch (error) {
            console.error(
                              "Error in constructRenderingMap", error
                        );
        }
    }
}