/**
 * Component Name: sspDeclarationOfAnnuitiesModal.
 * Author: Karthik Velu, Sai Kiran.
 * Description: This component opens the Declaration Of Annuities Modal.
 * Date: 2/5/2020.
 */
import { track, api, wire } from "lwc";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspAgreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningAgree";
import sspDisagreeButton from "@salesforce/label/c.SSP_MedicaidPenaltyWarningDisagree";
import sspAnnuitiesModalHeader from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalHeader";
import sspTheDeficitReduction from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalTheDeficitReduction";
import sspPurchasedOn from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalAnnuitiesPurchasedOn";
import sspDMSWillOnly from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalDMSWillOnly";
import sspFailureToComply from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalFailureToComply";
import sspHaveDisclosed from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalHaveDisclosed";
import sspHaveAgreed from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalHaveAgreed";
import sspAmSigningThis from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalAmSigningThis";
import sspAgreeAlternate from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalAgreeAlternate";
import sspDisagreeAlternate from "@salesforce/label/c.SSP_DeclarationOfAnnuitiesModalDisagreeAlternate";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import utility, { getYesNoOptions } from "c/sspUtility";
import constants from "c/sspConstants";
import { getRecord } from "lightning/uiRecordApi";

import DeclrtnfAnnuitiesAcceptanceCode from "@salesforce/schema/SSP_Application__c.DeclrtnfAnnuitiesAcceptanceCode__c";
import IsDMSAnnuitiesBeneficiary from "@salesforce/schema/SSP_Application__c.IsDMSAnnuitiesBeneficiary__c";
const FIELDS = [ DeclrtnfAnnuitiesAcceptanceCode,IsDMSAnnuitiesBeneficiary];

export default class SspDeclarationOfAnnuitiesModal extends utility {
    @api isSelectedValue = false;
    @api applicationId;
    @api toggleDisabled = false;

    @track hasMetadataListValues = false;
    @track openModel = true;
    @track trueValue;
    @track disabled = true;
    @track toastErrorText;
    @track applicationWrap = {};
    @track isFieldValuesLoaded = false;
    @track hasSaveValidationError = false;
    @track responseOptions = getYesNoOptions();
    @track reference = this;
    @track entered = false;
    @api isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspAnnuitiesModalHeader,
        sspTheDeficitReduction,
        sspPurchasedOn,
        sspDMSWillOnly,
        sspFailureToComply,
        sspHaveDisclosed,
        sspHaveAgreed,
        sspAmSigningThis,
        sspAgreeAlternate,
        sspDisagreeAlternate,
        sspAgreeButton,
        sspDisagreeButton,
        toastErrorText
    };
    customLabel = {
        sspYes,
        sspNo
    };

    get buttonDisability () {
        return this.disabled || this.isReadOnlyUser;
    }

    get toggleDisability () {
        return this.toggleDisabled || this.isReadOnlyUser;
    }

    @api
    get scrollFunction () {
        return this.trueValue;
    }
    set scrollFunction (value) {
        if (!value) {
            this.trueValue = false;
        } else {
            this.trueValue = true;
        }
    }
    /**
     * @function 	: MetadataList.
     * @description : This attribute is part of validation framework which used get the .
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.MetaDataListParent = value;
                this.hasMetadataListValues = true;
            }
        } catch (error) {
            console.error(
                "### Error in function MetadataList ###" + JSON.stringify(error)
            );
            this.showSpinner = false;
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
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error(
                "### Error in function objWrap ###" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function 	: getApplication.
     * @description 	: this attribute used to fetch the Application Data.
     * @param {response} response - Response Data (Application Data).
     * */
    @wire(getRecord, {
        recordId: "$applicationId",
        fields: FIELDS
    })
    getApplication (response) {
        try {
            const data = response.data;
            const error = response.error;
            if (data) {
                this.applicationWrap = data;
                this.isFieldValuesLoaded = true;
            } else if (error) {
                console.error("Error in getApplication:", error);
            }
        } catch (error) {
            console.error("Error occurred in connectedCallback" + error);
        }
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get the Meta Data values on Load.
     */
    connectedCallback () {
        try {
            if (this.isSelectedValue === true) {
                this.disabled = false;
            }
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "DeclrtnfAnnuitiesAcceptanceCode__c,SSP_Application__c"
            );
            fieldEntityNameList.push(
                "IsDMSAnnuitiesBeneficiary__c,SSP_Application__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Agree_DeclarationAnnuities"
            );
        } catch (error) {
            console.error("Error occurred in connectedCallback" + error);
        }
    }
    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                constants.resourceSummary.resourceSummaryError.hideToast +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : closeAnnuitiesModal
     * @description : This method is used to close the Modal.
     */
    closeAnnuitiesModal = () => {
        try {
            const selectedEvent = new CustomEvent(
                constants.signaturePage.Close,
                {
                    detail: true
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error("Error occurred in closeAnnuitiesModal" + error);
        }
    };

    /**
     * @function : handleOnClick
     * @description : This method is used to agree/disagree and close the Modal.
     * @param {event} event - Event.
     */
    handleOnClick = event => {
        const eventName = event.target.name;
        try {
            let fieldValue;
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.checkValidations(elem);
            if (
                !utility.isUndefinedOrNull(this.objValue) &&
                !utility.isEmpty(this.objValue)
            ) {
                const objWrap = JSON.parse(this.objValue);
                if (
                    (objWrap.IsAnnutiesDeclarationCode ===
                        constants.toggleFieldValue.yes ||
                        objWrap.IsAnnutiesDeclarationCode ===
                            constants.toggleFieldValue.no) &&
                    (objWrap.IsDMSAnnuitiesBeneficiary ===
                        constants.toggleFieldValue.yes ||
                        objWrap.IsDMSAnnuitiesBeneficiary ===
                            constants.toggleFieldValue.no)
                ) {

                    if (eventName === constants.signaturePage.Agree) {
                        fieldValue = constants.toggleFieldValue.yes;
                    } else {
                        fieldValue = constants.toggleFieldValue.no;
                    }
                    const selectedEvent = new CustomEvent(
                        constants.signaturePage.Close,
                        {
                            detail: {
                                sFieldValue: fieldValue,
                                sFieldName: "IsAgreeingToMA34Declaration__c",
                                IsDMSAnnuitiesBeneficiary:
                                    objWrap.IsDMSAnnuitiesBeneficiary,
                                IsAnnutiesDeclarationCode:
                                    objWrap.IsAnnutiesDeclarationCode,
                                sPageNameDirty:
                                    "SSP_APP_Agree_DeclarationAnnuities" //adding new param for dirty check
                            }
                        }
                    );
                    this.dispatchEvent(selectedEvent);
                } else {
                    this.hasSaveValidationError = true;
                    this.toastErrorText = this.label.toastErrorText;
                }
            }
            else {
                this.hasSaveValidationError = true;
                this.toastErrorText = this.label.toastErrorText;
            }
        } catch (error) {
            console.error("Error occurred in agreeAnnuitiesModal" + error);
        }
    };

    /**
     * @function : enableModalButtons.
     * @description : This method is used to enable the buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error("Error occurred in agreeAnnuitiesModal" + error);
        }
    };

    /**
     * @function : renderedCallback.
     * @description : This method is used to execute after html rendering.
     */
    renderedCallback () {
        try {
            if (!this.entered) {
                if (this.template.querySelector(".ssp-mainContent")) {
                    this.template
                        .querySelector(".ssp-DeclarationOfAnnuitiesModal")
                        .lessContentEnableButtons();
                    this.entered = true;
                }
            }
        } catch (error) {
            console.error("Error occurred in renderedCallback" + error);
        }
    }
}