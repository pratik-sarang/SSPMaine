/**
 * Component Name: sspChangePrimaryPhoneNumber.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: Component for change primary phone number and related data.
 * Date:  1/7/2019.
 */
import { track, api, wire } from "lwc";

import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspCanWeSendTextMessages from "@salesforce/label/c.SSP_CanWeSendTextMessages";
import sspChangePhoneNumber from "@salesforce/label/c.SSP_ChangePhoneNumber";
import sspPhoneNumber from "@salesforce/label/c.SSP_PhoneNumber";
import sspExt from "@salesforce/label/c.SSP_Ext";
import sspPhoneType from "@salesforce/label/c.SSP_PhoneType";

import triggerMyInfoCallOut from "@salesforce/apex/SSP_MyInformationController.triggerMyInfoCallout";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";

import SSP_MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import MEMBER_PRIMARY_PHONE from "@salesforce/schema/SSP_Member__c.PrimaryPhoneNumber__c";
import MEMBER_PRIMARY_EXTENSION from "@salesforce/schema/SSP_Member__c.PrimaryPhoneExtension__c";
import MEMBER_PRIMARY_PHONE_TYPE from "@salesforce/schema/SSP_Member__c.PrimaryPhoneTypeCode__c";
import MEMBER_INDIVIDUAL_ID from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import MEMBER_TEXT_PREFERRED from "@salesforce/schema/SSP_Member__c.IsPrimaryTextPreferred__c";
import ID_FIELD from "@salesforce/schema/SSP_Member__c.Id";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

export default class SspChangePrimaryPhoneNumber extends sspUtility {
    @api sspMemberId;

    sspIndividualId;
    label = {
        sspSave,
        sspCancel,
        sspCanWeSendTextMessages,
        sspChangePhoneNumber,
        sspPhoneNumber,
        sspExt,
        sspPhoneType,
        toastErrorText,
        sspMaxLength: sspConstants.validationEntities.phoneExtensionMaxLength
    };
    availablePhoneTypes =
        sspConstants.myInformationConstants.availablePhoneTypes;

    @track showErrorModal = false;
    @track errorMsg = "";
    @track renderingAttributes = {
        connectedCallBackExecuted: false,
        phoneTypesRetrieved: false,
        textPreferredValuesRetrieved: false,
        validationMetadataRetrieved: false,
        memberDataRetrieved: false,
        isDataProcessed: true
    };
    @track trueValue = true;
    @track hasSaveValidationError = false;
    @track metaDataListParent;
    @track toggleOptions;
    @track toggleOptionsPhone;
    @track phoneTypeCodes = [];
    @track textPreferredValues = [];
    @track saveValidator = false;
    @track member = {
        [sspConstants.sspMemberFields.PrimaryPhoneNumber__c]: "",
        [sspConstants.sspMemberFields.PrimaryPhoneExtension__c]: "",
        [sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c]: "",
        [sspConstants.sspMemberFields.IsPrimaryTextPreferred__c]: ""
    };
    @track isReadOnly = {
        [sspConstants.sspMemberFields.PrimaryPhoneNumber__c]: false,
        [sspConstants.sspMemberFields.PrimaryPhoneExtension__c]: false,
        [sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c]: false,
        [sspConstants.sspMemberFields.IsPrimaryTextPreferred__c]: false
    };
    @track reference = this;

    /**
     * @function : memberDataSetter
     * @description	: Method to set member data.
     * @param {string} fields - Language api values.
     */
    @wire(getRecord, {
        recordId: "$sspMemberId",
        fields: [
            MEMBER_PRIMARY_PHONE,
            MEMBER_PRIMARY_EXTENSION,
            MEMBER_PRIMARY_PHONE_TYPE,
            MEMBER_TEXT_PREFERRED,
            MEMBER_INDIVIDUAL_ID
        ]
    })
    memberDataSetter ({ error, data }) {
        try {
            if (data) {
                this.member[
                    sspConstants.sspMemberFields.PrimaryPhoneNumber__c
                ] = getFieldValue(data, MEMBER_PRIMARY_PHONE);
                this.member[
                    sspConstants.sspMemberFields.PrimaryPhoneExtension__c
                ] = getFieldValue(data, MEMBER_PRIMARY_EXTENSION);
                this.member[
                    sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c
                ] = getFieldValue(data, MEMBER_PRIMARY_PHONE_TYPE);
                this.member[
                    sspConstants.sspMemberFields.IsPrimaryTextPreferred__c
                ] = getFieldValue(data, MEMBER_TEXT_PREFERRED);

                this.sspIndividualId = getFieldValue(
                    data,
                    MEMBER_INDIVIDUAL_ID
                );

                this.manageExtensionAccess({
                    phoneType: this.member[
                        sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c
                    ]
                });
                this.renderingAttributes.memberDataRetrieved = true;
            } else if (error) {
                console.error(
                    "Error in sspChangePrimaryPhoneNumber.memberDataSetter : " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.memberDataSetter : " +
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
        fieldApiName: MEMBER_TEXT_PREFERRED
    })
    getTextPreferredValues ({ error, data }) {
        try {
            if (data) {
                const values = data.values;
                this.textPreferredValues = values.filter(
                    type =>
                        type.value === sspConstants.toggleFieldValue.yes ||
                        type.value === sspConstants.toggleFieldValue.no
                );
                this.renderingAttributes.textPreferredValuesRetrieved = true;
            } else if (error) {
                console.error(
                    "Error in sspChangePrimaryPhoneNumber.getTextPreferredValues : " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.getTextPreferredValues : " +
                    JSON.stringify(err)
            );
        }
    }

    /**
     * @function : TypePicklistValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Language api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: MEMBER_PRIMARY_PHONE_TYPE
    })
    getPrimaryPhoneTypes ({ error, data }) {
        try {
            if (data) {
                const values = data.values;
                this.phoneTypeCodes = values.filter(type =>
                    this.availablePhoneTypes.includes(type.value)
                );

                this.renderingAttributes.phoneTypesRetrieved = true;
            } else if (error) {
                console.error(
                    "Error in sspChangePrimaryPhoneNumber.getPrimaryPhoneTypes : " +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.getPrimaryPhoneTypes : " +
                    JSON.stringify(err)
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
                sspConstants.sspMemberFields.PrimaryPhoneNumber__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c,
                sspConstants.sspMemberFields.PrimaryPhoneExtension__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c,
                sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c,
                sspConstants.sspMemberFields.IsPrimaryTextPreferred__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "INFO_ChangePrimaryPhoneNumber"
            );
            this.renderingAttributes.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspChangePrimaryPhoneNumber.connectedCallback : " +
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
                "Error in sspChangePrimaryPhoneNumber.hideToast : " +
                    JSON.stringify(error)
            );
        }
        return renderPage;
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
                "Error in sspChangePrimaryPhoneNumber.setMetadataList : " +
                    error
            );
        }
    }

    /**
     * @function : initSave.
     * @description	: Method to save the values entered/selected.
     */
    initSave () {
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
                } else {
                    self.member[entity.fieldName] = entity.value;
                }
            });

            if (!isError) {
                const fields = {
                    [ID_FIELD.fieldApiName]: this.sspMemberId,
                    [MEMBER_PRIMARY_PHONE.fieldApiName]: this.member[
                        sspConstants.sspMemberFields.PrimaryPhoneNumber__c
                    ],
                    [MEMBER_PRIMARY_EXTENSION.fieldApiName]: this.member[
                        sspConstants.sspMemberFields.PrimaryPhoneExtension__c
                    ],
                    [MEMBER_PRIMARY_PHONE_TYPE.fieldApiName]: this.member[
                        sspConstants.sspMemberFields.PrimaryPhoneTypeCode__c
                    ],
                    [MEMBER_TEXT_PREFERRED.fieldApiName]: this.member[
                        sspConstants.sspMemberFields.IsPrimaryTextPreferred__c
                    ]
                };
                const recordInput = { fields };
                this.updateDetails(recordInput);
            } else {
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.initSave : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : updateDetails
     * @description	: Method to update data to server.
     * @param {object{}} data - Data to be updated.
     */
    updateDetails (data) {
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
                "Error in sspChangePrimaryPhoneNumber.updateDetails : " +
                    JSON.stringify(error)
            );
        }
    }

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
                                "failed in sspChangePrimaryPhoneNumber.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (parsedData.hasOwnProperty("SERVICE_ERROR")) {
                            this.showErrorModal = true;
                            this.errorMsg = result.mapResponse.SERVICE_ERROR;                            
                            console.error(
                                "SERVICE ERROR in sspChangePrimaryPhoneNumber.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.SERVICE_ERROR)
                            );
                        }
                    }
                }
            );
        } catch (error) {
            console.error(
                "failed in sspChangePrimaryPhoneNumber.triggerMyInfoCallOut : " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast () {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.hideToast : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : managePhoneType
     * @description	: Method to handle onchange event of phone type field.
     * @param {object} event - On change event handler.
     */
    managePhoneType (event) {
        try {
            this.manageExtensionAccess({ phoneType: event.target.value });
        } catch (error) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.managePhoneType : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : manageExtensionAccess
     * @description	: Method to identify/manage access(edit/readOnly) for extension field.
     * @param {object{}} valueMap - Details Map.
     */
    manageExtensionAccess (valueMap) {
        const phoneType = valueMap.phoneType;
        if (
            !sspUtility.isUndefinedOrNull(phoneType) &&
            phoneType === sspConstants.picklistValues.Cell
        ) {
            this.isReadOnly[
                sspConstants.sspMemberFields.PrimaryPhoneExtension__c
            ] = true;
            this.member[sspConstants.sspMemberFields.PrimaryPhoneExtension__c] =
                "";
            const sspExtensionCmp = this.template.querySelectorAll(
                ".ssp-extension-input"
            );
            if (!sspUtility.isUndefinedOrNull(sspExtensionCmp) && !sspUtility.isUndefinedOrNull(sspExtensionCmp[0])){
                sspExtensionCmp[0].value = "";
                sspExtensionCmp[0].ErrorMessages();
            }

        } else {
            this.isReadOnly[
                sspConstants.sspMemberFields.PrimaryPhoneExtension__c
            ] = false;
        }
    }

    /**
     * @function : initCancel.
     * @description	: Method to close modal.
     */
    initCancel () {
        try {
            this.dispatchEvent(new CustomEvent("close"));
        } catch (error) {
            console.error(
                "Error in sspChangePrimaryPhoneNumber.initCancel: " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        this.showErrorModal = false;
        this.renderingAttributes.isDataProcessed = true;
    }
}