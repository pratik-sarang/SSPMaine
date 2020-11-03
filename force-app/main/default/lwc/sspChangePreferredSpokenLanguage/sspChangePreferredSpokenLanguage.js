/**
 * Component Name: sspChangePreferredSpokenLanguage.
 * Author: Soumyashree Jena, Shrikant Raut.
 * Description: Component for change preferred spoken language.
 * Date:  1/6/2019.
 */
import { track, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import triggerMyInfoCallOut from "@salesforce/apex/SSP_MyInformationController.triggerMyInfoCallout";

import SSP_MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import MEMBER_INDIVIDUAL_ID from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import MEMBER_SPOKEN_LANGUAGE from "@salesforce/schema/SSP_Member__c.PreferredSpokenLanguageCode__c";
import ID_FIELD from "@salesforce/schema/SSP_Member__c.Id";

import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspChangePreferredSpokenLanguage from "@salesforce/label/c.SSP_ChangePreferredSpokenLanguage";
import sspPreferredSpokenLanguage from "@salesforce/label/c.SSP_PreferredSpokenLanguage";

import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";

export default class SspChangePreferredSpokenLanguage extends sspUtility {
    @api sspMemberId;

    sspIndividualId;
    languageLabelToValueMapping = {};
    label = {
        sspChangePreferredSpokenLanguage,
        toastErrorText,
        sspPreferredSpokenLanguage,
        sspSave,
        sspCancel
    };

    @track showErrorModal = false;
    @track errorMsg = "";
    @track metaDataListParent;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track objectInfo;
    @track typeOfSpokenLanguageOpts = [];
    @track memberSpokenLanguageCode = "";
    @track renderingAttributes = {
        connectedCallBackExecuted: false,
        spokenLanguagesRetrieved: false,
        memberDataRetrieved: false,
        validationMetadataRetrieved: false,
        isDataProcessed: true
    };
    @track reference = this;
    /**
     * @function : memberDataSetter
     * @description	: Method to set member data.
     * @param {string} fields - Language api values.
     */
    @wire(getRecord, {
        recordId: "$sspMemberId",
        fields: [MEMBER_SPOKEN_LANGUAGE, MEMBER_INDIVIDUAL_ID]
    })
    memberDataSetter ({ error, data }) {
        try {
            if (data) {
                this.memberSpokenLanguageCode = getFieldValue(
                    data,
                    MEMBER_SPOKEN_LANGUAGE
                );

                this.sspIndividualId = getFieldValue(
                    data,
                    MEMBER_INDIVIDUAL_ID
                );

                this.memberSpokenLanguage =
                    data.fields[
                        sspConstants.sspMemberFields.PreferredSpokenLanguageCode__c
                    ].displayValue;
                this.renderingAttributes.memberDataRetrieved = true;
            } else if (error) {
                console.error(
                    "Error in sspChangePreferredSpokenLanguage.memberDataSetter : " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.memberDataSetter : " +
                    JSON.stringify(err)
            );
        }
    }

    @wire(getObjectInfo, { objectApiName: SSP_MEMBER_OBJECT })
    objectInfo;

    /**
     * @function : TypePicklistValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Language api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: MEMBER_SPOKEN_LANGUAGE
    })
    fetchSpokenLanguageList ({ error, data }) {
        try {
            if (data) {
                const values = data.values;
                const labelToValueMapping = {};
                this.typeOfSpokenLanguageOpts = values;
                this.renderingAttributes.spokenLanguagesRetrieved = true;
                if (!sspUtility.isUndefinedOrNull(values)) {
                    values.forEach(function (entry) {
                        labelToValueMapping[entry.label] = entry.value;
                    });
                }
                this.labelToValueMapping = labelToValueMapping;
            } else if (error) {
                this.typeOfSpokenLanguageOpts = [];
                console.error(
                    "Error in sspChangePreferredSpokenLanguage.fetchSpokenLanguageList : " +
                        JSON.stringify(error)
                );
            }
        } catch (error) {
            this.typeOfSpokenLanguageOpts = [];
            console.error(
                "Error in sspChangePreferredSpokenLanguage.fetchSpokenLanguageList : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : connectedCallback
     * @description	: Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            //to retrieve validation metadata records
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.sspMemberFields.PreferredSpokenLanguageCode__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "INFO_ChangePreferredSpokenLanguage"
            );
            this.renderingAttributes.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspChangePreferredSpokenLanguage.connectedCallback : " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
     * @function : MetadataList
     * @description	: Set property to assign entity mapping values to metaDataListParent.
     * @param {object} value - SF entity mapping values.
     */
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
                this.renderingAttributes.validationMetadataRetrieved = true;
            }
        } catch (error) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.setMetadataList : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : isVisible
     * @description	: Get property to identify if component is ready to render UI elements.
     */
    get isVisible () {
        let renderPage = true;
        try {
            const renderingAttributes = this.renderingAttributes;
            Object.keys(renderingAttributes).forEach(attribute => {
                renderPage = renderPage && renderingAttributes[attribute];
            });
        } catch (error) {
            console.error(
                "failed in sspChangePreferredSpokenLanguage.isVisible : " +
                    JSON.stringify(error)
            );
        }
        return renderPage;
    }

    /**
     * @function : initCancel.
     * @description	: Method to close modal.
     */
    initCancel = () => {
        try {
            this.dispatchEvent(new CustomEvent("close"));
        } catch (error) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.initCancel : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.hideToast : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : initSave.
     * @description	: Method to save the values entered/selected.
     */
    initSave = () => {
        try {
            let isError = false;
            const self = this;
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );

            templateAppInputs.forEach(function (entity) {
                const errorMessage = entity.ErrorMessages();
                if (
                    !sspUtility.isUndefinedOrNull(errorMessage) &&
                    errorMessage.length !== 0
                ) {
                    isError = true;
                } else if (
                    entity.fieldName ===
                    sspConstants.sspMemberFields.PreferredSpokenLanguageCode__c
                ) {
                    self.memberSpokenLanguageCode =
                        self.labelToValueMapping[entity.value];
                    if (
                        sspUtility.isUndefinedOrNull(
                            self.memberSpokenLanguageCode
                        )
                    ) {
                        isError = true;
                    }
                }
            });

            if (!isError) {
                const fields = {
                    [ID_FIELD.fieldApiName]: this.sspMemberId,
                    [MEMBER_SPOKEN_LANGUAGE.fieldApiName]: this
                        .memberSpokenLanguageCode
                };
                const recordInput = { fields };
                this.updateDetails(recordInput);
            } else {
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.initSave : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : updateDetails
     * @description	: Method to update data to server.
     * @param {object{}} data - Data to be updated.
     */
    updateDetails = data => {
        try {
            this.renderingAttributes.isDataProcessed = false;
            updateRecord(data)
                .then(result => {
                    this.triggerMyInfoCallOut();
                })
                .catch(error => {
                    console.error(error);
                });
        } catch (error) {
            console.error(
                "Error in sspChangePreferredSpokenLanguage.updateDetails : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : triggerMyInfoCallOut
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     */
    triggerMyInfoCallOut = () => {
        try {
            triggerMyInfoCallOut({ individualId: this.sspIndividualId }).then(
                result => {
                    const parsedData = result.mapResponse;
                    if (
                        !sspUtility.isUndefinedOrNull(result) &&
                        result.bIsSuccess
                    ) {
                        this.dispatchEvent(new CustomEvent("close"));
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        this.renderingAttributes.isDataProcessed = true;
                        if (parsedData.hasOwnProperty("ERROR")) {
                            console.error(
                                "failed in sspChangePreferredSpokenLanguage.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (parsedData.hasOwnProperty("SERVICE_ERROR")) {
                            this.showErrorModal = true;
                            this.errorMsg = result.mapResponse.SERVICE_ERROR;                            
                            console.error(
                                "SERVICE ERROR in sspChangePreferredSpokenLanguage.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.SERVICE_ERROR)
                            );
                        }
                    }
                }
            );
        } catch (error) {
            console.error(
                "failed in sspChangePreferredSpokenLanguage.triggerMyInfoCallOut : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
    * @function : closeError.
    * @description	: Method to close error modal.
    */
    closeError = () => {
        this.showErrorModal = false;
        this.renderingAttributes.isDataProcessed = true;
    };
}