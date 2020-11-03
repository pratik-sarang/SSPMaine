/**
 * Component Name: sspChangePrimaryPhoneNumber.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: The component is to change Contact method of the user.
 * Date:  1/23/2020.
 */

import { api, track } from "lwc";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import fetchContactMethodDetails from "@salesforce/apex/SSP_MyInformationController.fetchContactMethodDetails";
import triggerMyInfoCallOut from "@salesforce/apex/SSP_MyInformationController.triggerMyInfoCallout";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspChangeContactMethod from "@salesforce/label/c.SSP_ChangeContactMethod";
import sspPreferredContactMethodS from "@salesforce/label/c.SSP_PreferredContactMethodS";
import sspSelectPreferredContactMethods from "@salesforce/label/c.SSP_SelectPreferredContactMethods";
import sspContentChangeContactMethod1 from "@salesforce/label/c.SSP_ContentChangeContactMethod1";
import sspClickReturnMyInformation from "@salesforce/label/c.SSP_ClickReturnMyInformation";
import { updateRecord } from "lightning/uiRecordApi";
import MEMBER_CONTACT_METHOD from "@salesforce/schema/SSP_Member__c.PreferredNotificationMethodCode__c";
import MEMBER_ID from "@salesforce/schema/SSP_Member__c.Id";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

export default class SspChangeContactMethod extends sspUtility {
    memberId;
    sspIndividualId;
    label = {
        sspSave,
        sspCancel,
        sspChangeContactMethod,
        sspPreferredContactMethodS,
        sspSelectPreferredContactMethods,
        sspContentChangeContactMethod1,
        sspClickReturnMyInformation,
        toastErrorText
    };
    availableContactMethods =
        sspConstants.myInformationConstants.availablePreferredContactMethods;

    @track showErrorModal = false;
    @track errorMsg = "";
    @track metaDataListParent;
    @track renderingAttributes = {
        validationMetadataRetrieved: false,
        connectedCallBackExecuted: false,
        requiredDataRetrieved: false,
        isDataProcessed: true
    };
    @track selectedPreferredContactMethod = "";
    @track preferredContactMethods = [];
    @track retrievedData;
    @track trueValue = true;
    @track hasSaveValidationError = false;
    @track reference = this;
    @api
    get sspMemberId () {
        return this.metaDataListParent;
    }

    /**
     * @function : fetchExpenseData
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     * @param {string} value - SF memberId.
     */
    set sspMemberId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.memberId = value;
                fetchContactMethodDetails({ sspMemberId: this.memberId }).then(
                    result => {
                        const parsedData = result.mapResponse;
                        if (
                            !sspUtility.isUndefinedOrNull(parsedData) &&
                            parsedData.hasOwnProperty("ERROR")
                        ) {
                            console.error(
                                "failed in sspChangeContactMethod.fetchContactMethodDetails" +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                            if (parsedData.hasOwnProperty("dataWrapper")) {
                                const contactMethodsRaw =
                                    parsedData.dataWrapper
                                        .availableContactMethods;
                                const preferredContactMethods = [];

                                Object.keys(contactMethodsRaw).forEach(key => {
                                    if (
                                        this.availableContactMethods.includes(
                                            key
                                        )
                                    ) {
                                        preferredContactMethods.push({
                                            value: key,
                                            label: contactMethodsRaw[key]
                                        });
                                    }
                                });

                                this.preferredContactMethods = preferredContactMethods;
                                this.selectedPreferredContactMethod =
                                    parsedData.dataWrapper.selectedContactMethod;
                                this.renderingAttributes.requiredDataRetrieved = true;
                            }
                            if (parsedData.hasOwnProperty("individualId")) {
                                this.sspIndividualId = parsedData.individualId;
                            }
                        }
                    }
                );
            }
        } catch (error) {
            console.error(
                "failed in sspChangeContactMethod.fetchContactMethodDetails " +
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
                "Error in sspChangeContactMethod.setMetadataList: " + error
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
                sspConstants.sspMemberFields
                    .PreferredNotificationMethodCode__c +
                    "," +
                    sspConstants.sspObjectAPI.SSP_Member__c
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "INFO_ChangeContactMethod"
            );
            this.renderingAttributes.connectedCallBackExecuted = true;
        } catch (error) {
            console.error(
                "failed in sspChangeContactMethod.connectedCallback " +
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
            renderPage = false;
            console.error(
                "Error in sspChangeContactMethod.isVisible: " +
                    JSON.stringify(error)
            );
        }
        return renderPage;
    }

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
                } else {
                    self.selectedPreferredContactMethod = entity.value;
                }
            });

            if (!isError) {
                const fields = {
                    [MEMBER_ID.fieldApiName]: this.memberId,
                    [MEMBER_CONTACT_METHOD.fieldApiName]:this.selectedPreferredContactMethod
                };
                const recordInput = { fields };
                this.updateDetails(recordInput);
            } else {
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(
                "Error in sspChangeContactMethod.initSave: " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : initSave.
     * @description	: Method to save the values entered/selected.
     * @param {object[]} listContactMethods - List of contact methods.
     */
    structureContactMethod = listContactMethods => {
        let structuredValue = "";
        try {
            if (!sspUtility.isUndefinedOrNull(listContactMethods)) {
                structuredValue = listContactMethods.join(";");
            }
        } catch (error) {
            console.error(
                "Error in sspChangeContactMethod.structureContactMethod: " +
                    JSON.stringify(error)
            );
        }
        return structuredValue;
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
                "Error in sspChangeContactMethod.updateDetails: " +
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
                                "failed in sspChangeContactMethod.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.ERROR)
                            );
                        } else if (parsedData.hasOwnProperty("SERVICE_ERROR")) {
                            this.showErrorModal = true;
                            this.errorMsg = result.mapResponse.SERVICE_ERROR;                            
                            console.error(
                                "SERVICE ERROR in sspChangeContactMethod.triggerMyInfoCallOut : " +
                                    JSON.stringify(parsedData.SERVICE_ERROR)
                            );
                        }
                    }
                }
            );
        } catch (error) {
            console.error(
                "failed in sspChangeContactMethod.triggerMyInfoCallOut " +
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
                "Error in sspChangeContactMethod.hideToast: " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : initCancel.
     * @description	: Method to close modal.
     */
    initCancel = () => {
        try {
            this.dispatchEvent(new CustomEvent("close"));
        } catch (error) {
            console.error(
                "Error in sspChangeContactMethod.initCancel: " +
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
    }
}