/**
 * Component Name: ssRemoveCoverageModal.
 * Author: Sharon, Velpula.
 * Description: This component creates a modal for Remove Coverage Modal.
 * Date: 19/12/2019.
 */

import { wire, track, api } from "lwc";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspCancelButtonTitle from "@salesforce/label/c.SSP_CancelButtonTitle";
import sspRemoveButtonTitle from "@salesforce/label/c.SSP_RemoveButtonTitle";
import sspRemoveCoverageTitle from "@salesforce/label/c.SSP_RemoveCoverageTitle";
import sspRemoveCoverageButton from "@salesforce/label/c.SSP_RemoveCoverageButton";
import sspRemoveCoverageCancel from "@salesforce/label/c.SSP_RemoveCoverageCancel";
import sspRemoveCoverageEndDate from "@salesforce/label/c.SSP_RemoveCoverageEndDate";
import sspRemoveCoverageIndHeader from "@salesforce/label/c.SSP_RemoveCoverageContextOne";
import sspRemoveCoverageReasonLabel from "@salesforce/label/c.SSP_RemoveCoverageReasonLabel";
import sspRemoveCoverageIndHeaderPart from "@salesforce/label/c.SSP_RemoveCoverageContextPart";
import sspRemoveCoveragePolicyHeader from "@salesforce/label/c.SSP_RemoveCoverageContextTwo";
import sspRemoveCoveragePleaseExplain from "@salesforce/label/c.SSP_RemoveCoveragePleaseExplain";
import sspRemoveCoverageReasonAlternateText from "@salesforce/label/c.SSP_RemoveCoverageReasonAlternateText";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import SSP_HEALTHINSURANCEFACILITYTYPE_OBJECT from "@salesforce/schema/SSP_HealthInsuranceFacilityType__c";
import constants from "c/sspConstants";
import utility, { formatLabels } from "c/sspUtility";

export default class SspRemoveCoverageModal extends utility {
    @api policyId;
    @api memberId;
    @api policyData;
    @api applicationId;
    @api coveredIndData;
    @api isCoveredIndDeletion;
    @api openModelForExist = false;
    @api healthInsuranceFacilityTypeRecordTypeId;
    @track objValue;
    @track toastErrorText;
    @track allowSaveValue;
    @track endReasonValues;
    @track MetaDataListParent;
    @track removeCoverageHeadingOne;
    @track removeCoverageHeadingTwo;
    @track showSpinner = false;
    @track hasSaveValidationError = false;
    @track otherOptionDisplayInput = false;
    @track showCoverageModal = false;
    @track showCoverageSpinner = false;
    @track reference = this;
    label = {
        toastErrorText,
        sspCancelButtonTitle,
        sspRemoveButtonTitle,
        sspRemoveCoverageTitle,
        sspRemoveCoverageButton,
        sspRemoveCoverageCancel,
        sspRemoveCoverageEndDate,
        sspRemoveCoverageIndHeader,
        sspRemoveCoverageReasonLabel,
        sspRemoveCoveragePolicyHeader,
        sspRemoveCoveragePleaseExplain,
        sspRemoveCoverageIndHeaderPart,
        sspRemoveCoverageReasonAlternateText
    };

    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        this.MetaDataListParent = value;
    }

    /**
     * @function 	: allowSave.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSave () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error("Error occurred in remove coverage modal" + error);
            return null;
        }
    }
    set allowSave (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.allowSaveValue = value;
            }
        } catch (error) {
            console.error("Error occurred in remove coverage modal" + error);
            return null;
        }
    }

    /**
     * @function 	: objWrap.
     * @description 	: this attribute contains validated data which is used to save.
     * */
    @api
    get objWrap () {
        try {
            return this.objValue;
        } catch (error) {
            console.error("Error occurred in remove coverage modal" + error);
            return null;
        }
    }
    set objWrap (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error("Error occurred in remove coverage modal" + error);
            return null;
        }
    }

    /**
     * @function 	: Wire Function - getObjectInfo.
     * @description 	: this property is used to get the Record Type of Obj.
     * */
    @wire(getObjectInfo, {
        objectApiName: SSP_HEALTHINSURANCEFACILITYTYPE_OBJECT
    })
    objectInfo ({ data }) {
        try {
            if (data) {
                const recordTypeInformation =
                    data[constants.resourceDetailConstants.resourceRecordTypes];
                this.healthInsuranceFacilityTypeRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name ===
                        constants.removeCoverageConstants.RecordTypeName
                );
            }
        } catch (error) {
            console.error(
                "Error occurred in Remove Coverage page while fetching record type of object" +
                    error
            );
        }
    }

    /**
     * @function 	: Wire Function - getPicklistValuesByRecordType.
     * @description 	: this property is used to get the Picklist of Obj.
     * */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSP_HEALTHINSURANCEFACILITYTYPE_OBJECT,
        recordTypeId: "$healthInsuranceFacilityTypeRecordTypeId"
    })
    picklistOptions ({ error, data }) {
        try {
            if (data) {
                let endValues = data.picklistFieldValues.EndReason__c.values;
                endValues = endValues.slice();
                if (
                    this.policyData.sTypeOfCoverageCodeName !==
                    constants.removeCoverageConstants.COBRA
                ) {
                    for (let index = 0; index < endValues.length; index += 1) {
                        if (
                            endValues[index].value ===
                            constants.removeCoverageConstants.COBRA
                        ) {
                            endValues.splice(index, 1);
                            break;
                        }
                    }
                }
                this.endReasonValues = endValues;
                this.showSpinner = false;
                this.showCoverageSpinner = false;
                this.showCoverageModal = true;
            } else if (error) {
                console.error(
                    "### Error while trying to fetch picklist values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred in Remove Coverage Modal page while fetching picklist values" +
                    error
            );
        }
    }

    /**
     * @function : connectedCallback.
     * @description : This method is used to get the Meta Data values on Load.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            let facilityTypes = "";
            const fieldEntityNameList = [];
            fieldEntityNameList.push("EndReason__c,SSP_TrackDeletion__c");
            fieldEntityNameList.push("EndDate__c,SSP_TrackDeletion__c");
            fieldEntityNameList.push("OtherReason__c,SSP_TrackDeletion__c");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_RemoveCoverageModal"
            );
            if (this.isCoveredIndDeletion) {
                if (
                    !utility.isUndefinedOrNull(
                        this.coveredIndData.lstHealthInsuranceFacilityType
                    )
                ) {
                    const lstHealthInsFType = this.coveredIndData
                        .lstHealthInsuranceFacilityType;
                    lstHealthInsFType.forEach(element => {
                        facilityTypes =
                            facilityTypes + ", " + element.FacilityType__c;
                    });
                    facilityTypes = facilityTypes.replace(",", ""); // Remove the first one
                }
                this.removeCoverageHeadingOne = formatLabels(
                    sspRemoveCoverageIndHeader,
                    [
                        this.coveredIndData.sCoveredIndFirstName +
                            " " +
                            this.coveredIndData.sCoveredIndLastName,
                        facilityTypes
                    ]
                );
                this.removeCoverageHeadingTwo = formatLabels(
                    sspRemoveCoverageIndHeaderPart,
                    [
                        this.coveredIndData.sCoveredIndFirstName +
                            " " +
                            this.coveredIndData.sCoveredIndLastName
                    ]
                );
            } else {
                this.removeCoverageHeading = sspRemoveCoveragePolicyHeader;
            }
            // this.showSpinner = false;
            this.showCoverageSpinner = true;
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "Error occurred while fetching metaData the in Remove Coverage Modal " +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : removeCoverageModal
     * @description : This method is used to open the remove coverage modal.
     */
    removeCoverageModal () {
        try {
            this.openModelForExist = true;
            // this.showCoverageSpinner = true;
            // ("In removeCoverageModal() function[1]");
        } catch (error) {
            console.error(
                "Error occurred while opening the Remove Coverage Modal" + error
            );
        }
    }

    /**
     * @function : closeRemoveCoverageModal
     * @description : This method is used to close the remove coverage modal.
     */
    closeRemoveCoverageModal () {
        try {
            this.openModelForExist = false;
            const removeCoverage = new CustomEvent(
                constants.removeCoverageConstants.EventName,
                {
                    detail: ""
                }
            );
            this.dispatchEvent(removeCoverage);
        } catch (error) {
            console.error(
                "Error occurred while closing the Remove Coverage Modal" + error
            );
        }
    }

    /**
     * @function : changeCoverageReason
     * @description : This method is used to display text box if Other option is selected.
     * @param {event} event - Event Details.
     */
    changeCoverageReason (event) {
        try {
            if (
                event.target.value === constants.removeCoverageConstants.Other
            ) {
                this.otherOptionDisplayInput = true;
            } else {
                this.otherOptionDisplayInput = false;
            }
        } catch (error) {
            console.error(
                "Error occurred while changing the option in the Remove Coverage Modal" +
                    error
            );
        }
    }

    /**
     * @function : removePolicyCoverage
     * @description : This method is used to update Insurance Policy and Covered Individual .
     */
    removePolicyCoverage () {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.checkValidations(elem);
            this.showSpinner = true;
            if (!utility.isUndefinedOrNull(this.objValue)) {
                this.openModelForExist = false;
                const userInput = JSON.parse(this.objValue);
                const trackDeletionWrapper = {};
                trackDeletionWrapper.sApplicationId = this.applicationId;
                trackDeletionWrapper.sMemberId = this.memberId;
                trackDeletionWrapper.sEndReason = userInput.sEndReason;
                trackDeletionWrapper.dEndDate = userInput.dEndDate;
                trackDeletionWrapper.sSource =
                    constants.removeCoverageConstants.ScreenName;
                trackDeletionWrapper.bIsCoveredIndDeletion = this.isCoveredIndDeletion;
                trackDeletionWrapper.sOtherReason =
                    userInput.sEndReason ===
                    constants.removeCoverageConstants.Other
                        ? userInput.sOtherReason
                        : null;
                if (this.isCoveredIndDeletion) {
                    trackDeletionWrapper.sSalesforceId = this.coveredIndData.sCoveredIndId;
                    trackDeletionWrapper.sDCId = (this.coveredIndData.sCoveredIndDCId).replace(/,/g,"");
                    trackDeletionWrapper.sParentDCId = this.policyData.sPolicyDCId;
                } else {
                    trackDeletionWrapper.sSalesforceId = this.policyData.sInsurancePolicyId;
                    trackDeletionWrapper.sDCId = this.policyData.sPolicyDCId;
                    trackDeletionWrapper.sParentDCId = null;
                }
                this.showSpinner = false;
                const hideFrameworkEvent = new CustomEvent(
                    constants.events.hideSection,
                    {
                        bubbles: true,
                        composed: true,
                        detail: {
                            objTrackDeletion: trackDeletionWrapper
                        }
                    }
                );
                this.dispatchEvent(hideFrameworkEvent);
            } else {
                this.showSpinner = false;
                this.hasSaveValidationError = true;
                this.toastErrorText = this.label.toastErrorText;
            }
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "Error occurred while removing the Data in Remove Coverage Modal " +
                    JSON.stringify(error.message)
            );
        }
    }
}