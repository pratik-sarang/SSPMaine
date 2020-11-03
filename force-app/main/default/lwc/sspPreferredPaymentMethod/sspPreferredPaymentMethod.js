/**
 * Component Name: sspPreferredPaymentMethod
 .* Author: Sharon Roja, Varun kochar
 .* Description: This component creates a screen for KI-HIPP Preferred Payment Method.
 * Date: 02/01/2020.
 */
import { track, wire, api } from "lwc";
import sspPreferredPaymentQuestion from "@salesforce/label/c.SSP_PreferredPaymentQuestion";
import sspPreferredPaymentPolicyHolder from "@salesforce/label/c.SSP_PreferredPaymentPolicyHolder";
import sspPreferredPaymentAddress from "@salesforce/label/c.SSP_PreferredPaymentAddress";
import sspPreferredPaymentRouting from "@salesforce/label/c.SSP_PreferredPaymentRouting";
import sspPreferredPaymentAccount from "@salesforce/label/c.SSP_PreferredPaymentAccount";
import sspPreferredPaymentVerifyAccount from "@salesforce/label/c.SSp_PreferredPaymentVerifyAccount";
import sspPreferredPayment1Label from "@salesforce/label/c.SSP_PreferredPayment1";
import sspPreferredPayment2Label from "@salesforce/label/c.SSP_PreferredPayment2";
import sspKihippPreferredPayment from "@salesforce/label/c.SSP_KihippPreferredPayment";
import sspAddressLabel1Label from "@salesforce/label/c.SSP_AddressLabel1";
import sspAddressLabel2Label from "@salesforce/label/c.SSP_AddressLabel2";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspRoutingNumberMaxLimitErrorMessageLabel from "@salesforce/label/c.SSP_RoutingNumberMaxLimitErrorMessage";
import sspInvalidRoutingNumberErrorMessageLabel from "@salesforce/label/c.SSP_InvalidRoutingNumberErrorMessage";
import sspInvalidRoutingNumberLengthErrorMessageLabel from "@salesforce/label/c.SSP_InvalidRoutingNumberLengthErrorMessage";
import sspVerifyAccountErrorMessageLabel from "@salesforce/label/c.SSP_VerifyAccountErrorMessage";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspPreferredPaymentLearnMoreModalAltText from "@salesforce/label/c.SSP_PreferredPaymentLearnMoreModalAltText";
import sspPreferredPaymentAlternateText from "@salesforce/label/c.SSP_PreferredPaymentAlternateText";
import sspResourceSelectionLearnMore from "@salesforce/label/c.SSP_LearnMoreLink";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import sspPreferredPaymentSelectQuestion from "@salesforce/label/c.SSP_PreferredPaymentSelectQuestion";
import sspDirectDepositCheckingAccountMessage from "@salesforce/label/c.SSP_DirectDepositCheckingAccountMessage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import sspConstants, { countyValues } from "c/sspConstants";
import SSPMEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import PREFEREEDISSUANCEMETHOD_FIELD from "@salesforce/schema/SSP_Member__c.PreferredIssuanceMethod__c";
import getKHIPPDetails from "@salesforce/apex/SSP_KHIPPPreferredPaymentMethod.getKHIPPDetails";
import saveKHIPPPreferredPayment from "@salesforce/apex/SSP_KHIPPPreferredPaymentMethod.saveKHIPPPreferredPayment";
import utility, { formatLabels } from "c/sspUtility";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import getBankDetails from "@salesforce/apex/SSP_KHIPPPreferredPaymentMethod.getBankDetails";

export default class SspPreferredPaymentMethod extends BaseNavFlowPage {
    @api memberName;
    @api memberId;
    @track applicationId;
    @track preferredPaymentOptions;
    @track mapOfIdAndPreferredPaymentMethodWrapper = new Map();
    @track isDirectDepositTrue = false;
    @track isComponentLoaded = false;
    @track memberFullName;
    @track preferredPaymentMethodWrapper;
    @track MetaDataListParent;
    @track validationFlag;
    @track labelPreferredPayment1 = sspPreferredPayment1Label;
    @track labelPreferredPayment2 = sspPreferredPayment2Label;
    @track addressLabel1 = sspAddressLabel1Label;
    @track addressLabel2 = sspAddressLabel2Label;
    @track
    sspRoutingNumberMaxLimitErrorMessage = sspRoutingNumberMaxLimitErrorMessageLabel;
    @track
    sspInvalidRoutingNumberErrorMessage = sspInvalidRoutingNumberErrorMessageLabel;
    @track
    sspInvalidRoutingNumberLengthErrorMessage = sspInvalidRoutingNumberLengthErrorMessageLabel;
    @track
    sspVerifyAccountErrorMessage = sspVerifyAccountErrorMessageLabel;
    @track isLearnMoreModal = false;
    @track allowSaveData;
    @track showToast = false;
    @track trueValue = true;
    @track showSpinner = false;
    @track reference = this;
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspPreferredPaymentQuestion,
        sspResourceSelectionLearnMore,
        sspPreferredPaymentPolicyHolder,
        sspPreferredPaymentRouting,
        sspPreferredPaymentAccount,
        sspPreferredPaymentVerifyAccount,
        sspPreferredPayment1Label,
        sspPreferredPayment2Label,
        sspAddressLabel1Label,
        sspAddressLabel2Label,
        sspRoutingNumberMaxLimitErrorMessageLabel,
        sspInvalidRoutingNumberErrorMessageLabel,
        sspInvalidRoutingNumberLengthErrorMessageLabel,
        sspVerifyAccountErrorMessageLabel,
        sspSummaryRecordValidator,
        sspPreferredPaymentSelectQuestion,
        sspPreferredPaymentAlternateText,
        sspLearnMoreModalContent,
        sspPreferredPaymentAddress,
        sspPreferredPaymentLearnMoreModalAltText,
        toastErrorText,
        sspDirectDepositCheckingAccountMessage
    };

    maxLength = sspConstants.preferredPaymentConstants.maxLength;
    minLength = sspConstants.preferredPaymentConstants.minLength;

    get screenRenderingStatus () {
        return this.isComponentLoaded && !this.isNotAccessible;
    }

    /**
     * @function : Getter setter methods for modalContentValue.
     * @description : Getter setter methods for LearnMoreModal.
     */
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
        }
    }

    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for appID.
     */
    @api
    get appId () {
        return this.applicationId;
    }
    set appId (value) {
        this.applicationId = value;
        this.getKHIPPPreferredPaymentDetails();
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
        if (value) {
            this.MetaDataListParent = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
            }
        }
    }

    /**
     * @function : Getter setters for next event.
     * @description : Getter setters for next event.
     */
    @api
    get nextEvent () {
        try {
            return this.nextValue;
        } catch (error) {
            console.error(
                "Error in get of nextEvent:" + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.save();
            }
        } catch (error) {
            console.error(
                "Error in set of nextEvent:" + JSON.stringify(error.message)
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

    /**
     * @function : objectInfo
     * @description	: Wire function to get SSP_Member Object.
     */
    @wire(getObjectInfo, {
        objectApiName: SSPMEMBER_OBJECT
    })
    objectInfo;

    /**
     * @function :     getPicklistValues
     * @description	: Method to get Payment Options.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: PREFEREEDISSUANCEMETHOD_FIELD
    })
    getPaymentPicklistValues ({ error, data }) {
        if (data) {
            this.preferredPaymentOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }

    /**
     * @function : connectedCallback
     * @description	: Method to load payment information.
     */
    connectedCallback () {
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "PreferredIssuanceMethod__c,SSP_Member__c",
                "RoutingNumber__c,SSP_Member__c",
                "CheckingAccountNumber__c,SSP_Member__c"
            );
            this.showHelpContentData("SSP_APP_HealthCare_PreferredPayment");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                sspConstants.preferredPaymentFields
                    .SSPAPPHealthCarePreferredPayment
            );
            const healthCareHeader = new CustomEvent(
                sspConstants.events.updateHeader,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        header: sspKihippPreferredPayment
                    }
                }
            );
            this.dispatchEvent(healthCareHeader);
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    }
    /**
    * @function - renderedCallback
    * @description - This method is used to called whenever there is track variable changing.

    */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
            );
            if (sectionReference) {
                sectionReference.innerText = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function : getKHIPPPreferredPaymentDetails.
     * @description	: Method to get preferred payment details for policy holders in application.
     */
    getKHIPPPreferredPaymentDetails = () => {
        try {
            this.showSpinner = true;
            getKHIPPDetails({
                applicationId: this.applicationId
            })
                .then(result => {
                    this.preferredPaymentMethodWrapper = JSON.parse(
                        JSON.stringify(result.mapResponse.wrapper)
                    );
                    this.isComponentLoaded = true;
                    this.preferredPaymentMethodWrapper.forEach(wrapper => {
                        //Added as part of defect 364937 by Abhishek, CD1 change
                        if (!wrapper.member.hasOwnProperty("PreferredIssuanceMethod__c")){
                            wrapper.member["PreferredIssuanceMethod__c"] = "EFT";
                            wrapper.isDirectDeposit=true;
                        }
                        wrapper.preferredPaymentMethodLabel = formatLabels(
                            sspPreferredPaymentSelectQuestion,
                            [wrapper.member.FirstName__c]
                        );
                        wrapper.preferredPaymentAddress = formatLabels(
                            sspPreferredPaymentAddress,
                            [wrapper.member.FirstName__c]
                        );
                        const middleName = (wrapper.member.MiddleInitial__c !== null && wrapper.member.MiddleInitial__c !== undefined) ? (wrapper.member.MiddleInitial__c +" ") : "";
                        const suffix = (wrapper.member.SuffixCode__c !== null && wrapper.member.SuffixCode__c !== undefined) ? (" "+wrapper.member.SuffixCode__c) : "";
                        wrapper.memberFullName =
                            wrapper.member.FirstName__c +
                            " " +
                            middleName +
                            wrapper.member.LastName__c +
                            suffix;
                        wrapper.formattedAddress = [
                            wrapper.member.MailingAddressLine1__c,
                            wrapper.member.MailingAddressLine2__c,
                            wrapper.member.MailingCity__c,
                            wrapper.member.MailingCountyCode__c,
                            wrapper.member.MailingStateCode__c,
                            wrapper.member.MailingCountryCode__c,
                            wrapper.member.MailingZipCode5__c
                        ]
                            .filter(
                                item =>
                                    !!item &&
                                    item !== countyValues.OUT_OF_STATE.label
                            )
                            .join(", ")
                            .replace(/,[\s,]*,/g, ", ")
                            .replace(/(^[,\s]+)|([,\s]+$)/g, "");
                        this.mapOfIdAndPreferredPaymentMethodWrapper.set(
                            wrapper.member.Id,
                            wrapper
                        );
                    });
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        sspConstants.preferredPaymentFields
                            .preferredPaymentScreenError + JSON.stringify(error)
                    );
                    this.showSpinner = false;
                });
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function - changePreferredPaymentMethod
     * @description	- Method to handle Payment Method.
     * @param {*} event - Determine type of payment method and show bank/check details.
     */
    changePreferredPaymentMethod = event => {
        try {
            const selectedMember = event.target.dataset.member;
            if (
                event.target.value === sspConstants.preferredPaymentFields.EFT
            ) {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isDirectDeposit = true;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isCheck = false;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).member[sspConstants.sspMemberFields.PreferredIssuanceMethod] =
                    sspConstants.preferredPaymentFields.EFT;
            } else if (
                event.target.value === sspConstants.preferredPaymentFields.CH
            ) {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isDirectDeposit = false;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isCheck = true;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).member[sspConstants.sspMemberFields.PreferredIssuanceMethod] =
                    sspConstants.preferredPaymentFields.CH;
            } else {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isDirectDeposit = false;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).isCheck = false;
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function - handleAccountNumber
     * @description	- Method to handle Account Number.
     * @param {*} event - Validate account number.
     */
    handleAccountNumber = event => {
        try {
            const selectedMember = event.target.dataset.member;
            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                selectedMember
            ).member[sspConstants.sspMemberFields.CheckingAccountNumber] =
                event.target.value;
            if (
                !utility.isUndefinedOrNull(event.target.value) &&
                !utility.isEmpty(event.target.value)
            ) {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).disableVerifyAccountNumber = false;
            } else {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).disableVerifyAccountNumber = true;
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function : save
     * @description	: Method to save Preferred Payment Method.
     */
    save = () => {
        try {
            this.showToast = false;
            this.preferredPaymentMethodWrapper.forEach(wrapper => {
                if (
                    wrapper.member.PreferredIssuanceMethod__c ===
                    sspConstants.preferredPaymentFields.EFT
                ) {
                    if (
                        wrapper.showRoutingNumberErrorMessage ||
                        wrapper.showDefaultRoutingNumberErrorMessage
                    ) {
                        this.allowSaveData = false;
                        this.showToast = true;
                    }

                    if (
                        wrapper.member.CheckingAccountNumber__c !==
                        wrapper.verifyAccountNumber
                    ) {
                        wrapper.verifyAccountErrorMessage = this.sspVerifyAccountErrorMessage;
                        wrapper.showVerifyAccountErrorMessage = true;
                        this.allowSaveData = false;
                        this.showToast = true;
                    }
                    if (
                        !utility.isUndefinedOrNull(
                            wrapper.member.RoutingNumber__c
                        ) &&
                        !utility.isEmpty(wrapper.member.RoutingNumber__c) &&
                        !wrapper.showBankDetails
                    ) {
                        this.allowSaveData = false;
                        this.showToast = true;
                    }
                }
            });

            const inputElement = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.templateInputsValue = inputElement;

            if (this.allowSaveData !== undefined && this.allowSaveData) {
                this.trueValue = false;
                this.savePreferredMethod();
                this.validationFlag = false;
            } else {
                this.validationFlag = true;
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function : savePreferredMethod
     * @description	: Method to call save function.
     */
    savePreferredMethod = () => {
        try {
            this.showSpinner = true;
            saveKHIPPPreferredPayment({
                wrapper: JSON.stringify(this.preferredPaymentMethodWrapper)
            })
                .then(result => {
                    this.showSpinner = false;
                    this.saveCompleted = true;
                })
                .catch(error => {});
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function - handleVerifyRoutingNumber
     * @description	- Method to verify Routing Number.
     * @param  {*} event - To verify bank details on insert of routing number.
     */
    handleVerifyRoutingNumber = event => {
        try {
            this.handleValidateRoutingNumber(event);
            const selectedMember = event.target.dataset.member;
            const routingNumber = event.target.value;
            if ( routingNumber !== null && routingNumber !== "" && routingNumber !== undefined
                && !this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showRoutingNumberErrorMessage
            ) {
                this.showSpinner = true;
                getBankDetails({
                    routingNumber: routingNumber
                })
                    .then(result => {
                        if (result !== null) {
                            const bankDetails = JSON.parse(
                                JSON.stringify(result.mapResponse.bankDetails)
                            );
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).member[
                                sspConstants.preferredPaymentFields.FederalReserve
                            ] = bankDetails.Id;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).showBankDetails = true;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).isDirectDeposit = true;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).isCheck = false;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).bankName = bankDetails.Name__c;
                            const formattedAddress = [
                                bankDetails.AddressLine1__c,
                                bankDetails.AddressLine2__c,
                                bankDetails.City__c,
                                bankDetails.County__c,
                                bankDetails.StateCode__c,
                                bankDetails.Country__c,
                                bankDetails.ZipCode__c
                            ]
                                .filter(
                                    item =>
                                        !!item &&
                                        item !== countyValues.OUT_OF_STATE.label
                                )
                                .join(", ")
                                .replace(/,[\s,]*,/g, ", ")
                                .replace(/(^[,\s]+)|([,\s]+$)/g, "");
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).bankAddress = formattedAddress;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).routingNumberErrorMessage = "";
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).showRoutingNumberErrorMessage = false;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).showDefaultRoutingNumberErrorMessage = false;
                        } else {
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).member[
                                sspConstants.preferredPaymentFields.FederalReserve
                            ] = null;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).validRoutingNumberCount =
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).validRoutingNumberCount + 1;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).routingNumberErrorMessage = this.sspRoutingNumberMaxLimitErrorMessage;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).showRoutingNumberErrorMessage = true;
                            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                selectedMember
                            ).showBankDetails = false;
                            if (
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).validRoutingNumberCount > 3
                            ) {
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).member[
                                    sspConstants.sspMemberFields.PreferredIssuanceMethod
                                ] = sspConstants.preferredPaymentFields.CH;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).showBankDetails = false;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).isDirectDeposit = false;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).isCheck = true;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).disablePreferredMethodOfPayment = true;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).routingNumberErrorMessage = this.sspInvalidRoutingNumberErrorMessage;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).showRoutingNumberErrorMessage = false;
                                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                                    selectedMember
                                ).showDefaultRoutingNumberErrorMessage = true;
                            }
                        }
                        this.showSpinner = false;
                    })

                    .catch(error => {
                        console.error(
                            sspConstants.preferredPaymentFields
                                .preferredPaymentScreenError +
                                JSON.stringify(error)
                        );
                        this.showSpinner = false;
                    });
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function - handleValidateRoutingNumber
     * @description	- Method to validate Routing Number.
     * @param  {*} event - To validate routing number.
     */
    handleValidateRoutingNumber = event => {
        try {
            const selectedMember = event.target.dataset.member;
            const routingNumber = event.target.value;
            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                selectedMember
            ).member[
                sspConstants.sspMemberFields.RoutingNumber
            ] = routingNumber;
            const regexExpr = new RegExp("^[0-9]{9}$");
            const regexResult = regexExpr.test(routingNumber);
            if (!regexResult) {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).routingNumberErrorMessage = this.sspInvalidRoutingNumberLengthErrorMessage;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showRoutingNumberErrorMessage = false;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showBankDetails = false;
            } else {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).routingNumberErrorMessage = "";
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showRoutingNumberErrorMessage = false;
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function - verifyAccountValidation
     * @description	- Validation to match Account number.
     * @param {*} event - - To validate account number.
     */
    verifyAccountValidation = event => {
        try {
            const selectedMember = event.target.dataset.member;
            const verifyAccountNumber = event.target.value;
            this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                selectedMember
            ).verifyAccountNumber = verifyAccountNumber;

            if (
                verifyAccountNumber !==
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(selectedMember)
                    .member[sspConstants.sspMemberFields.CheckingAccountNumber]
            ) {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).verifyAccountErrorMessage = this.sspVerifyAccountErrorMessage;
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showVerifyAccountErrorMessage = true;
                this.allowSaveData = false;
            } else {
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).verifyAccountErrorMessage = "";
                this.mapOfIdAndPreferredPaymentMethodWrapper.get(
                    selectedMember
                ).showVerifyAccountErrorMessage = false;
                this.allowSaveData = true;
            }
        } catch (e) {
            console.error(
                sspConstants.preferredPaymentFields.preferredPaymentScreenError,
                e
            );
        }
    };

    /**
     * @function handleHideToast
     * @description Raises error toast if required.
     */
    handleHideToast = () => {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     */
    openLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = true;
        } catch (error) {
            console.error(
                "Error in openLearnMoreModal:" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error(
                "Error in closeLearnMoreModal:" + JSON.stringify(error.message)
            );
        }
    };

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
                    this.isNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                              "Error in constructRenderingMap", error
                        );
        }
    }
}
