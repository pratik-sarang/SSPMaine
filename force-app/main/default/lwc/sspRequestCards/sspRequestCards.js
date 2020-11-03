/***
 * Component Name:sspRequestCards.js.
 * Author: Nikhil Shinde, Prasanth
 * Description: Request a/an Medicaid/EBT card screen.
 * Date:10/07/2020.
 */

import { track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import sspMedicaidCardHeader from "@salesforce/label/c.SSP_RequestMedicaidCardHeader";
import sspMedicaidCardNote from "@salesforce/label/c.SSP_RequestMedicaidCardNote";
import sspMCOLearnMoreLink from "@salesforce/label/c.SSP_RequestMedicaidCardMCOLearnMoreLink";
import sspWhyReplace from "@salesforce/label/c.SSP_RequestMedicaidCardWhyReplace";
import sspWhoNeeds from "@salesforce/label/c.SSP_RequestMedicaidCardWhoNeeds";
import sspAdditionalInformation from "@salesforce/label/c.SSP_RequestMedicaidCardAdditionalInformation";
import sspWhereToSend from "@salesforce/label/c.SSP_RequestMedicaidCardWhereToSend";
import sspChooseDCBSNote from "@salesforce/label/c.SSP_RequestMedicaidCardChooseDCBSNote";
import sspSendToMailingAddress from "@salesforce/label/c.SSP_RequestMedicaidCardSendToMailingAddress";
import sspMailingAddress from "@salesforce/label/c.SSP_RequestMedicaidCardMailingAddress";
import sspRACLink from "@salesforce/label/c.SSP_RequestMedicaidCardRACLink";
import sspSendToDCBSOffice from "@salesforce/label/c.SSP_RequestMedicaidCardSendToDCBSOffice";
import sspPickUp from "@salesforce/label/c.SSP_RequestMedicaidCardPickUp";
import sspChangeLocation from "@salesforce/label/c.SSP_RequestMedicaidCardChangeLocation";
import sspBringValidID from "@salesforce/label/c.SSP_RequestMedicaidCardBringValidID";

import sspIUnderstand from "@salesforce/label/c.SSP_RequestMedicaidCardIUnderstand";
import sspMedicaidCardSuccessToast from "@salesforce/label/c.SSP_RequestMedicaidCardSuccessToast";
import sspSubmitRequest from "@salesforce/label/c.SSP_RequestMedicaidCardSubmitRequest";
import sspCancel from "@salesforce/label/c.SSP_RequestMedicaidCardCancel";
import sspWhoNeedsAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardWhoNeedsAlternateText";
import sspWhyReplaceAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardWhyReplaceAlternateText";
import sspRACLinkAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardRACLinkAlternateText";
import sspChangeLocationAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardChangeLocationAlternateText";
import sspIUnderstandAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardIUnderstandAlternateText";
import sspSubmitRequestAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardSubmitRequestAlternateText";
import sspCancelAlternateText from "@salesforce/label/c.SSP_RequestMedicaidCardCancelAlternateText";
import sspDCBSLink from "@salesforce/label/c.SSP_FooterDCBS_Link";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";

import sspMyMailingAddress from "@salesforce/label/c.SSP_RequestMedicaidCardMyMailingAddress";
import sspMCOLinkAlternate from "@salesforce/label/c.SSP_RequestMedicaidCardMCOLinkAlternate";
import sspDCBSOffice from "@salesforce/label/c.SSP_RequestMedicaidCardDCBSOffice";
import sspEBTCardHeader from "@salesforce/label/c.SSP_RequestEBTCardHeader";
import sspEBTCardSuccessToast from "@salesforce/label/c.SSP_RequestEBTCardSuccessToast";
import getMailingAddress from "@salesforce/apex/SSP_RequestAMedicaidCard.getMailingAddress";
import medicaidCardRequestCallOut from "@salesforce/apex/SSP_RequestAMedicaidCard.medicaidCardRequestCallOut";
import eBTCardRequestCallOut from "@salesforce/apex/SSP_RequestAMedicaidCard.ebtCardRequestCallOut";
import getReasonPickListValues from "@salesforce/apex/SSP_RequestAMedicaidCard.getReasonPickListValues";
import medicaidEBTData from "@salesforce/apex/SSP_RequestAMedicaidCard.medicaidEBTData";
import getDCBSAddress from "@salesforce/apex/SSP_RequestAMedicaidCard.getDCBSAddress";
import { formatLabels } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";
import getMemberTypeFlag from "@salesforce/apex/SSP_DashboardController.getMemberTypeFlag";

export default class SspRequestCards extends NavigationMixin(sspUtility) {
    @track label = {
        sspMedicaidCardHeader,
        sspMedicaidCardNote,
        sspMCOLearnMoreLink,
        sspWhyReplace,
        sspWhoNeeds,
        sspAdditionalInformation,
        sspWhereToSend,
        sspChooseDCBSNote,
        sspSendToMailingAddress,
        sspMailingAddress,
        sspRACLink,
        sspSendToDCBSOffice,
        sspPickUp,
        sspChangeLocation,
        sspBringValidID,
        sspIUnderstand,
        sspMedicaidCardSuccessToast,
        sspSubmitRequest,
        sspCancel,
        sspWhoNeedsAlternateText,
        sspWhyReplaceAlternateText,
        sspRACLinkAlternateText,
        sspChangeLocationAlternateText,
        sspIUnderstandAlternateText,
        sspSubmitRequestAlternateText,
        sspCancelAlternateText,
        sspMyMailingAddress,
        sspDCBSOffice,
        sspEBTCardHeader,
        sspEBTCardSuccessToast,
        sspDCBSLink,
        sspRequiredErrorMessage,
        sspMCOLinkAlternate
    };
    @track isMedicaidRequest = false;
    @track isEBTRequest = false;
    @track addressToggleOptions;
    @track myInfo;
    @track individualId;
    @track isMailingAddress = false;
    @track isDCBSOffice = false;
    @track showSpinner = false;
    @track whoNeedsPickListOptions = [];
    @track rMemberData = {};
    @track selectedMember = {};
    @track allMemberData = [];
    @track toastMessage = this.label.sspRequiredErrorMessage;
    @track showErrorToast = false;
    @track replaceReason = "";
    @track iUnderstand = false;
    @track requestedAddress = "";
    @track whoNeedsPickListValue = "";
    @track selectedAddressOption = "";
    @track reference = this;
    @track isMCOLearnMore = false;
    @track modValue;
    @track reasonPickListOptions = [];
    @track hasRequiredError = false;
    @track addressDCBSOffice = "";
    @track isAddressToggleDisabled = true;
    @track isOpenDCBSOverLay = false;
    @track caseNumberRAC = "";
    @track showRACPopUp = false;
    @track pageOrigin = "";
    @track isOfficeAddressAvailable = false;
    @track isFromBenefit = false;
    @track isReadOnlyUser = false;
    @track isScreenAccessible = false;
    @track isEditable = false;
    @track showAccessDeniedComponent = false;
    @track showWhoNeedsPicklist = true;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track isRacCase = false;

    @track mailingAddress = {
        mailingAddressLine1: "",
        mailingAddressCity: "",
        mailingAddressCountyCode: "",
        mailingAddressZipCodeFive: "",
        mailingAddressZipCodeFour: "",
        mailingAddressState: ""
    };

    @track officeAddress = {
        officeAddressLine1: "",
        officeAddressLine2: "",
        officeAddressCity: "",
        mailingAddressCountyCode: "",
        officeAddressZipCodeFive: "",
        officeAddressID: "",
        officeName: "",
        officeDCBSId: ""
    };

    @track requestCardSubmit = {
        memberName: "",
        memberIndividualId: "",
        memberCaseNumber: "",
        whyReplace: "",
        addInfo: "",
        addressToggle: "",
        iUnderstand: "",
        countyCode: "",
        isMailingAddress: "",
        isDCBS: "",
        officeId: "",
        recordId: ""
    };

    //Added by Shivam for Bug 386777
    @track ownershipFlag = "";
    @track isDAILCBWOwner = false;
    @track isTMember = false;

    /**
     * @function : getter and setters for modalContentValue
     * @description	: sets the learn more modal content.
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


    //Added by Shivam for Bug 386777
    get hideRACSpecialAccess () {
        return (this.isTMember || this.isDAILCBWOwner);
    }

    /**
     * @function : connectedCallback
     * @description	: This method is called on page load.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const url = new URL(window.location.href);
            if (url.searchParams.get("requestEBT")) {
                this.isEBTRequest = true;
                this.isMedicaidRequest = false;
                this.pageOrigin = "request-a-card?requestEBT=request";
            } else if (url.searchParams.get("requestMedicaid")) {
                this.isMedicaidRequest = true;
                this.isEBTRequest = false;
                this.pageOrigin = "request-a-card?requestMedicaid=request";
            }

            if (url.searchParams.get("fromBenefit")) {
                this.isFromBenefit = true;
            }
            this.getReasonPickListValuesHandler();
            this.getMedicaidEBTDataHandler();
            
            this.updateLabels();
            this.showHelpContentData("SSP_RequestMedicaidCard_MCO");
            const getAddressToggleOptions = () => [
                {
                    label: this.label.sspMyMailingAddress,
                    value: this.label.sspMyMailingAddress
                },
                {
                    label: this.label.sspDCBSOffice,
                    value: this.label.sspDCBSOffice
                }
            ];
            this.addressToggleOptions = getAddressToggleOptions();

            //Added by Shivam for Bug 386777
            getMemberTypeFlag().then(result => {
                if (!sspUtility.isUndefinedOrNull(result) && !sspUtility.isUndefinedOrNull(result.mapResponse) && !sspUtility.isUndefinedOrNull(result.mapResponse.memberType)) {
                    this.isTMember = (result.mapResponse.memberType).includes(sspConstants.headerConstants.TMEM);
                }
                if (!sspUtility.isUndefinedOrNull(result) && !sspUtility.isUndefinedOrNull(result.mapResponse) && !sspUtility.isUndefinedOrNull(result.mapResponse.ownerType)) {
                    this.ownershipFlag = result.mapResponse.ownerType;
                    if ((this.ownershipFlag.includes(sspConstants.headerConstants.DAIL) && this.selectedRole !== sspConstants.headerConstants.DAIL_Worker) || this.ownershipFlag.includes(sspConstants.headerConstants.CBW)) {
                        this.isDAILCBWOwner = true;
                    }
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(
                    "@@check getMemberTypeFlag in request EBT Card error" + JSON.stringify(error)
                );
            });

        } catch (error) {
            console.error("Error in connectedCallback =>", error);
        }
    }

    /**
     * @function : renderedCallback
     * @description	: Method called when DOM is loaded.
     */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMoreMCO"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in rendered call back =>", error);
        }
    }

    /**
     * @function : updateLabels
     * @description : This method is used to update the labels.
     */
    updateLabels = () => {
        try {
            if (this.isMedicaidRequest === true) {
                this.label.sspWhoNeeds = formatLabels(this.label.sspWhoNeeds, [
                    sspConstants.requestCards.medicaid
                ]);
                this.label.sspWhyReplace = formatLabels(
                    this.label.sspWhyReplace,
                    [sspConstants.requestCards.medicaid]
                );
                this.label.sspSubmitRequestAlternateText = formatLabels(
                    this.label.sspSubmitRequestAlternateText,
                    [sspConstants.requestCards.medicaid]
                );
                this.label.sspCancelAlternateText = formatLabels(
                    this.label.sspCancelAlternateText,
                    [sspConstants.requestCards.medicaid]
                );
                this.label.sspIUnderstand = formatLabels(
                    this.label.sspIUnderstand,
                    [
                        sspConstants.requestCards.medicaid,
                        "14",
                        sspConstants.requestCards.medicaid
                    ]
                );
                this.label.sspSendToMailingAddress = formatLabels(
                    this.label.sspSendToMailingAddress,
                    [sspConstants.requestCards.medicaid]
                );
                this.label.sspWhyReplaceAlternateText = formatLabels(
                    this.label.sspWhyReplaceAlternateText,
                    [sspConstants.requestCards.medicaid]
                );
            } else if (this.isMedicaidRequest === false) {
                this.label.sspWhoNeeds = formatLabels(this.label.sspWhoNeeds, [
                    sspConstants.requestCards.EBT
                ]);
                this.label.sspWhyReplace = formatLabels(
                    this.label.sspWhyReplace,
                    [sspConstants.requestCards.EBT]
                );
                this.label.sspSubmitRequestAlternateText = formatLabels(
                    this.label.sspSubmitRequestAlternateText,
                    [sspConstants.requestCards.EBT]
                );
                this.label.sspCancelAlternateText = formatLabels(
                    this.label.sspCancelAlternateText,
                    [sspConstants.requestCards.EBT]
                );
                this.label.sspIUnderstand = formatLabels(
                    this.label.sspIUnderstand,
                    [
                        sspConstants.requestCards.EBT,
                        "10",
                        sspConstants.requestCards.EBT
                    ]
                );
                this.label.sspSendToMailingAddress = formatLabels(
                    this.label.sspSendToMailingAddress,
                    [sspConstants.requestCards.EBT]
                );
                this.label.sspWhyReplaceAlternateText = formatLabels(
                    this.label.sspWhyReplaceAlternateText,
                    [sspConstants.requestCards.EBT]
                );
            }
        } catch (error) {
            console.error("Error in updateLabels =>", error);
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };

    /**
     * @function : getMyInformationHandler
     * @description : This method is used to get mailing address information on choosing a member.
     */
    getMyInformationHandler = () => {
        try {
            getMailingAddress({
                individualId: this.selectedMember.sIndividualId,
                caseNumber: this.selectedMember.sCaseNumber
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.isRacCase = result.mapResponse.isRacCase;
                    
                        this.myInfo = result.mapResponse;
                        const requestedAddressInfo = JSON.parse(
                            result.mapResponse.response
                        );
                        
                        let extractAddressInfo = requestedAddressInfo.payload;
                        if (
                            extractAddressInfo.hasOwnProperty("SSP_Member__c")
                        ) {
                            extractAddressInfo =
                                requestedAddressInfo.payload.SSP_Member__c;
                        }

                        if (
                            extractAddressInfo !== undefined &&
                            extractAddressInfo !== null &&
                            extractAddressInfo != ""
                        ) {
                            for (
                                let address = 0;
                                address < extractAddressInfo.length;
                                address++
                            ) {
                                //DCBS office info
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "PreferredDCBSOffice"
                                    )
                                ) {
                                    this.officeAddress.officeName =
                                        extractAddressInfo[
                                            address
                                        ].PreferredDCBSOffice;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "DCBS_OfficeId__c"
                                    )
                                ) {
                                    this.officeAddress.officeDCBSId =
                                        extractAddressInfo[
                                            address
                                        ].DCBS_OfficeId__c;
                                    this.getDCBSAddressHandler();
                                }

                                //Mailing Address Info
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingAddressLine1__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressLine1 =
                                        extractAddressInfo[
                                            address
                                        ].MailingAddressLine1__c;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingZipCode5__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressZipCodeFive =
                                        extractAddressInfo[
                                            address
                                        ].MailingZipCode5__c;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingCountyCode__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressCountyCode =
                                        extractAddressInfo[
                                            address
                                        ].MailingCountyCode__c;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingCity__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressCity =
                                        extractAddressInfo[
                                            address
                                        ].MailingCity__c;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingStateCode__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressState =
                                        extractAddressInfo[
                                            address
                                        ].MailingStateCode__c;
                                }
                                if (
                                    extractAddressInfo[address].hasOwnProperty(
                                        "MailingZipCode4__c"
                                    )
                                ) {
                                    this.mailingAddress.mailingAddressZipCodeFour =
                                        extractAddressInfo[
                                            address
                                        ].MailingZipCode4__c;
                                }
                            }
                            this.isAddressToggleDisabled = false;
                            if (this.isEBTRequest === true) {
                                this.isMailingAddress = true;
                            }
                        } else {
                            console.error(
                                "No Valid Data received =>",
                                JSON.stringify(requestedAddressInfo)
                            );
                        }

                        this.showSpinner = false;
                    } else {
                        //add modal
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    console.error(
                        "The error at getMyInformationHandler",
                        JSON.stringify(error)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error("Error in getMyInformationHandler =>", error);
            this.showSpinner = false;
        }
    };

    /**
     * @function : checkValidations
     * @description : This method is used to check the validations.
     */
    checkValidations = () => {
        try {
            const validation = this.template.querySelectorAll(
                ".ssp-requestCardInput"
            );
            if (validation !== null && validation !== undefined) {
                validation.forEach(field => {
                    if (
                        field.value === undefined ||
                        field.value === null ||
                        field.value === "" ||
                        field.value === false
                    ) {
                        this.hasRequiredError = true;
                        field.ErrorMessageList = [
                            this.label.sspRequiredErrorMessage
                        ];
                        this.showErrorToast = true;
                        this.showSpinner = false;
                    }
                });
            }
        } catch (error) {
            console.error("Error in checkValidations", error);
        }
    };

    handleAdditionalInfoChange = event => {
        try {
            this.addInfoText = event.target.value;
        } catch (error) {
            console.error("Error in handleAdditionalInfoChange =>", error);
        }
    };

    /**
     * @function : onChangeWhoNeedsPickList
     * @description : This method is used to get the value on pick list change.
     * @param {*} event - Js event.
     */
    onChangeWhoNeedsPickList = event => {
        try {
            this.showSpinner = true;
            this.isMailingAddress = false;
            this.isDCBSOffice = false;
            this.isAddressToggleDisabled = true;
            this.addInfoText = "";
            this.getReasonPickListValuesHandler();
            this.iUnderstand = null;
            this.selectedAddressOption = null;
            this.replaceReason = "";
            if (event.target.value !== "") {
                this.allMemberData.forEach(member => {
                    if (member.sIndividualId === event.target.value) {
                        this.selectedMember = member;
                        this.whoNeedsPickListValue = this.selectedMember.sIndividualId;
                        if (
                            this.whoNeedsPickListValue !== undefined &&
                            this.whoNeedsPickListValue !== null &&
                            this.whoNeedsPickListValue !== ""
                        ) {
                            event.target.ErrorMessageList = [];
                            this.hasRequiredError = false;
                        }
                        this.caseNumberRAC = JSON.stringify(
                            "[" + this.selectedMember.sCaseNumber + "]"
                        );
                        this.getMyInformationHandler();
                    }
                });
            } else if (event.target.value === "") {
                this.isMailingAddress = false;
                this.isDCBSOffice = false;
                this.isAddressToggleDisabled = true;
                this.addInfoText = "";
                this.getReasonPickListValuesHandler();
                this.showSpinner = false;
                this.iUnderstand = null;
                this.selectedAddressOption = null;
                this.replaceReason = "";
            }
            
        } catch (error) {
            console.error("Error in onChangeWhoNeedsPickList =>", error);
        }
    };

    /**
     * @function : onChangeWhyReplaceReason
     * @description : This method is used to get the value on pick list change.
     * @param {*} event - Js event.
     */
    onChangeWhyReplaceReason = event => {
        try {
            this.replaceReason = event.target.value;
            if (this.replaceReason !== "") {
                event.target.ErrorMessageList = [];
                this.hasRequiredError = false;
            }
        } catch (error) {
            console.error("Error in onChangeWhyReplaceReason =>", error);
        }
    };

    /**
     * @function : onChangeAddressToggle
     * @description : This method is used to get the value on toggle change.
     * @param {*} event - Js event.
     */
    onChangeAddressToggle = event => {
        try {
            this.selectedAddressOption = event.target.value;
            if (this.selectedAddressOption !== "") {
                event.target.ErrorMessageList = [];
                this.hasRequiredError = false;
            }
            if (this.selectedAddressOption === this.label.sspMyMailingAddress) {
                this.isMailingAddress = true;
                this.isDCBSOffice = false;
            } else if (
                this.selectedAddressOption === this.label.sspDCBSOffice
            ) {
                this.isMailingAddress = false;
                this.isDCBSOffice = true;
            }
        } catch (error) {
            console.error("Error in onChangeAddressToggle =>", error);
        }
    };

    /**
     * @function : handleCheckboxChange
     * @description : This method is used to get the value on checkbox change.
     * @param {*} event - Js event.
     */
    handleCheckboxChange = event => {
        try {
            this.iUnderstand = event.target.value;
            if (this.iUnderstand === true) {
                event.target.ErrorMessageList = [];
                this.hasRequiredError = false;
            }
        } catch (error) {
            console.error("Error in handleCheckboxChange =>", error);
        }
    };

    /**
     * @function : handleSubmitRequest
     * @description : This method is used to submit the request filled.
     */
    handleSubmitRequest = () => {
        try {
            this.showSpinner = true;
            this.checkValidations();
            if (this.hasRequiredError === false) {
                //Data filled
                this.requestCardSubmit.memberName = this.selectedMember.sIndividualName;
                this.requestCardSubmit.memberIndividualId = this.selectedMember.sIndividualId;
                this.requestCardSubmit.memberCaseNumber = this.selectedMember.sCaseNumber;
                this.requestCardSubmit.whyReplace = this.replaceReason;
                this.requestCardSubmit.addInfo = this.addInfoText;
                this.requestCardSubmit.iUnderstand = this.iUnderstand;
                this.requestCardSubmit.addressToggle = this.selectedAddressOption;
                if (this.isMailingAddress === true) {
                    this.requestCardSubmit.isMailingAddress = this.isMailingAddress;
                    this.requestCardSubmit.isDCBS = this.isDCBSOffice;
                } else if (this.isDCBSOffice === true) {
                    this.requestCardSubmit.isDCBS = this.isDCBSOffice;
                    this.requestCardSubmit.isMailingAddress = this.isMailingAddress;
                }
                this.requestCardSubmit.officeId = this.officeAddress.officeDCBSId;
                this.requestCardSubmit.recordId = this.officeAddress.officeAddressID;
                this.requestCardSubmit.countyCode = this.mailingAddress.mailingAddressCountyCode;
                if (this.isMedicaidRequest === true) {
                    this.medicaidCardRequestCallOutHandler();
                }

                if (this.isEBTRequest === true) {
                    this.eBTCardRequestCallOutHandler();
                }
            }
        } catch (error) {
            console.error("Error in handle Submit Request =>", error);
        }
    };

    /**
     * @function : medicaidCardRequestCallOutHandler
     * @description : This method is used to call out the medicaid request.
     */
    medicaidCardRequestCallOutHandler = () => {
        try {
            medicaidCardRequestCallOut({
                reqParameters: this.requestCardSubmit
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.navigateToDashboard();
                        this.showSpinner = false;
                    } else {
                        //add modal
                        this.showErrorModal = true;
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    console.error(
                        "@@medicaidCardRequestCallOut error" +
                            JSON.stringify(error)
                    );
                    this.showErrorModal = true;
                    this.showSpinner = false;
                });
        } catch (error) {
            this.showErrorModal = true;
            console.error("Error in medicaidCardRequestCallOut =>", error);
        }
    };

    /**
     * @function : eBTCardRequestCallOutHandler
     * @description : This method is used to call out the  EBT request.
     */
    eBTCardRequestCallOutHandler = () => {
        try {
            eBTCardRequestCallOut({
                reqParameters: this.requestCardSubmit
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.navigateToDashboard();
                        this.showSpinner = false;
                    } else {
                        this.showSpinner = false;
                        //add modal
                        this.showErrorModal = true;
                    }
                })
                .catch(error => {
                    this.showErrorModal = true;
                    console.error(
                        "@@eBTCardRequestCallOut error" + JSON.stringify(error)
                    );
                });
        } catch (error) {
            this.showErrorModal = true;
            console.error("Error in eBTCardRequestCallOutHandler =>", error);
        }
    };

    /**
     * @function : getReasonPickListValuesHandler
     * @description : This method is used to load picklist values.
     */
    getReasonPickListValuesHandler = () => {
        try {
            getReasonPickListValues()
                .then(result => {
                    if (result != null) {
                        const reasonList = [];
                        const retrievedOptions = result;
                        Object.keys(retrievedOptions).forEach(key => {
                            reasonList.push({
                                label: retrievedOptions[key],
                                value: key
                            });
                        });
                        this.reasonPickListOptions = reasonList;
                    }
                })
                .catch(error => {
                    console.error("@@error" + JSON.stringify(error));
                });
        } catch (error) {
            console.error("Error in getReasonPickListValuesHandler =>", error);
        }
    };

    /**
     * @function : openLearnMoreModal
     * @description : This method is used to open modal.
     * @param {*} event - Js event.
     */
    openLearnMoreModal = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.isMCOLearnMore = true;
            }
        } catch (error) {
            console.error("Error in openLearnMoreModal", error);
        }
    };

    /**
     * @function : closeLearnMoreModal
     * @description : This method is used to close modal.
     */
    closeLearnMoreModal = () => {
        try {
            this.isMCOLearnMore = false;
        } catch (error) {
            console.error("Error in closeLearnMoreModal");
        }
    };

    /**
     * @function : handleCancelRequest
     * @description : This method is used to go back to previous screen.
     */
    handleCancelRequest = () => {
        try {
            this.showSpinner = true;
            
            this.navigateToDashboardOnCancel();
        } catch (error) {
            console.error("Error in handleCancelRequest =>", error);
        }
    };

    /**
     * @function : navigateToDashboard
     * @description : This method is used to navigate to the requested screen.
     */
    navigateToDashboard = () => {
        try {
            //from benefit screen
            if (this.isFromBenefit === true) {
                if (this.isMedicaidRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url:
                                sspConstants.navigationUrl.benefitsPage +
                                "?requestMedicaidCard=success&individualId=" +
                                this.selectedMember.sIndividualId
                        }
                    });
                }
                if (this.isEBTRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url:
                                sspConstants.navigationUrl.benefitsPage +
                                "?requestEBTCard=success&individualId=" +
                                this.selectedMember.sIndividualId
                        }
                    });
                }
            }

            //from dashboard
            if (this.isFromBenefit === false) {
                if (this.isMedicaidRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: sspConstants.navigationUrl.dashBoard
                        },
                        state: {
                            requestMedicaidCard: "success",
                            individualId: this.selectedMember.sIndividualId
                        }
                    });
                }
                if (this.isEBTRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: sspConstants.navigationUrl.dashBoard
                        },
                        state: {
                            requestEBTCard: "success",
                            individualId: this.selectedMember.sIndividualId
                        }
                    });
                }
            }
        } catch (error) {
            console.error("Error in navigateToDashboard=>", error);
        }
    };

    navigateToDashboardOnCancel = () => {
        try {
            //from benefit screen
            if (this.isFromBenefit === true) {
                if (this.isMedicaidRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: sspConstants.navigationUrl.benefitsPage
                        }
                    });
                }
                if (this.isEBTRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: sspConstants.navigationUrl.benefitsPage
                        }
                    });
                }
            }

            //from dashboard
            if (this.isFromBenefit === false) {
                if (this.isMedicaidRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: sspConstants.navigationUrl.dashBoard
                        }
                    });
                }
                if (this.isEBTRequest === true) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: sspConstants.navigationUrl.dashBoard
                        }
                    });
                }
            }
        } catch (error) {
            console.error("Error in navigateToDashboardOnCancel=>", error);
        }
    };

    /**
     * @function : getMedicaidEBTDataHandler
     * @description : This method is used to get the Medicaid/ EBT data on load.
     */
    getMedicaidEBTDataHandler = () => {
        try {
            medicaidEBTData()
                .then(result => {
                    if (result.bIsSuccess) {
                        
                        let whoNeedsPickList = [];
                        if (this.isMedicaidRequest === true) {
                            const medicaidAccessibility =
                                result.mapResponse.mediCaidSecurityMatrix
                                    .screenPermission;
                            this.constructRenderingAttributes(
                                medicaidAccessibility
                            );
                            whoNeedsPickList = JSON.parse(
                                result.mapResponse.medicaidData
                            );
                        }
                        if (this.isEBTRequest === true) {
                            const ebtAccessibility =
                                result.mapResponse.ebtSecurityMatrix
                                    .screenPermission;
                            this.constructRenderingAttributes(
                                ebtAccessibility
                            );
                            whoNeedsPickList = JSON.parse(
                                result.mapResponse.ebtData
                            );
                        }
                        if (
                            whoNeedsPickList !== null &&
                            whoNeedsPickList !== undefined
                        ) {
                            if (whoNeedsPickList.length === 1) {
                                this.selectedMember.sIndividualId =
                                    whoNeedsPickList[0].IndividualId;
                                this.selectedMember.sCaseNumber =
                                    whoNeedsPickList[0].CaseNumber;
                                this.selectedMember.sIndividualName =
                                    whoNeedsPickList[0].IndividualName;
                                this.showWhoNeedsPicklist = false;
                                this.getMyInformationHandler();
                            } else {
                                const memberPickListValues = [];
                                for (
                                    let pickList = 0;
                                    pickList < whoNeedsPickList.length;
                                    pickList++
                                ) {
                                    memberPickListValues.push({
                                        label:
                                            whoNeedsPickList[pickList]
                                                .IndividualName,
                                        value:
                                            whoNeedsPickList[pickList]
                                                .IndividualId
                                    });
                                    this.rMemberData = {
                                        sIndividualName:
                                            whoNeedsPickList[pickList]
                                                .IndividualName,
                                        sIndividualId:
                                            whoNeedsPickList[pickList]
                                                .IndividualId,
                                        sCaseNumber:
                                            whoNeedsPickList[pickList]
                                                .CaseNumber
                                    };
                                    this.allMemberData.push(this.rMemberData);
                                }
                                this.whoNeedsPickListOptions = memberPickListValues;
                            }
                        }
                        this.showSpinner = false;
                    } else {
                        //add modal
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    console.error(
                        "@@check medicaidEBTData error" + JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in getMedicaid EBT Handler =>", error);
        }
    };

    /**
     * @function 		: openDCBSOverlay.
     * @description 	: Open find dcbs overlay.
     * @param {*} event - Js event.
     **/
    openDCBSOverlay = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.isOpenDCBSOverLay = true;
            }
        } catch (error) {
            console.error("Error in opening DCBS overlay");
        }
    };

    /**
     * @function : closeDCBSOverlay
     * @description : This used to close Modal.
     */
    closeDCBSOverlay = () => {
        try {
            this.isOpenDCBSOverLay = false;
        } catch (error) {
            console.error("Error in closeDCBSOverlay =>", error);
        }
    };

    /**
     * @function 		: selectedOfficeEvent.
     * @description 	: method to handle the Custom Event fired.
     * @param {*} event - Gets the changed office Address.
     **/
    selectedOfficeEvent = event => {
        try {
            const eventAddress = event.detail;
            if (eventAddress.hasOwnProperty("addressLine1")) {
                this.officeAddress.officeAddressLine1 =
                    eventAddress.addressLine1;
            }
            if (eventAddress.hasOwnProperty("addressLine2")) {
                this.officeAddress.officeAddressLine2 =
                    eventAddress.addressLine2;
            }
            if (eventAddress.hasOwnProperty("city")) {
                this.officeAddress.officeAddressCity = eventAddress.city;
            }
            if (eventAddress.hasOwnProperty("zipCode")) {
                this.officeAddress.officeAddressZipCodeFive =
                    eventAddress.zipCode;
            }

            this.officeAddress.officeAddressID = eventAddress.Id;
            this.officeAddress.officeName = eventAddress.name;
            this.addressDCBSOffice =
                this.officeAddress.officeAddressLine1 +
                " " +
                this.officeAddress.officeAddressCity +
                " " +
                this.officeAddress.officeAddressZipCodeFive;
            this.isOfficeAddressAvailable = true;
            this.isOpenDCBSOverLay = false;
        } catch (error) {
            console.error(
                "Error in dispatched event to catch changed DCBS office"
            );
        }
    };

    /**
     * @function 		: navigateToRAC.
     * @description 	: method to handle rac popUp.
     * @param {*} event - Js event.
     **/
    navigateToRAC = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showRACPopUp = true;
            }
        } catch (error) {
            console.error("Error in navigate to RAC =>", error);
        }
    };

    /**
     * @function 		: handleClose.
     * @description 	: method to handle rac popUp.
     **/
    handleClose () {
        try {
            this.showRACPopUp = false;
        } catch (error) {
            console.error(
                "failed in handleClose in sspBenefitsPage" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function 		: getDCBSAddressHandler.
     * @description 	: method to get DCBS address on load.
     **/
    getDCBSAddressHandler = () => {
        try {
            //this.officeAddress.officeDCBSId => pass it in the below apex call
            getDCBSAddress({ dcbsOfficeId: this.officeAddress.officeDCBSId })
                .then(result => {
                    if (result.bIsSuccess) {
                        const receivedAddress = JSON.parse(
                            result.mapResponse.response
                        );
                        
                        if (
                            receivedAddress !== null &&
                            receivedAddress !== undefined
                        ) {
                            this.officeAddress.officeAddressLine1 =
                                receivedAddress.PhysicalAddressLine1__c;
                            this.officeAddress.officeAddressCity =
                                receivedAddress.PhysicalCity__c;
                            this.officeAddress.officeAddressZipCodeFive =
                                receivedAddress.PhysicalZipCode5__c;
                            this.officeAddress.officeDCBSId =
                                receivedAddress.DCOfficeId__c;

                            //display dcbs address
                            this.addressDCBSOffice =
                                this.officeAddress.officeAddressLine1 +
                                " " +
                                this.officeAddress.officeAddressLine2 +
                                " " +
                                this.officeAddress.officeAddressCity +
                                " " +
                                this.officeAddress.officeAddressZipCodeFive;
                            this.isOfficeAddressAvailable = true;
                        }
                    }
                })
                .catch(error => {
                    console.error(
                        "@@DCBS address error" + JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in getDCBSAddressHandler =>", error);
        }
    };

    /**
     * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
     * @description : This method is used to construct rendering attributes.
     * @param {object} response - Backend response.
     */
    constructRenderingAttributes = response => {
        try {
            if (
                response != null &&
                response != undefined &&
                response.hasOwnProperty("screenPermission")
            ) {
                this.showSpinner = true;
                const securityMatrix = response;
                
                this.isReadOnlyUser =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.readOnly;
                this.isScreenAccessible =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.notAccessible
                        ? false
                        : true;

                this.isEditable =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.editable;

                if (!this.isEditable) {
                     this.showAccessDeniedComponent = true;
                }
            }
        } catch (error) {
            console.error(JSON.stringify(error.message));
        }
    };

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };
}
