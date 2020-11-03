/*
 * Component Name: SspDocumentCenterGenericUpload.
 * Author: Kyathi Kanumuri, Aniket.
 * Description: This is a container for Generic Upload Screen.
 * Date: 4/15/2020.
 * MODIFICATION LOG:
 * DEVELOPER             DATE            DESCRIPTION
 * ________________________________________________________________________________
 * Aniket                4/15/2020     Backend Integration.
 */
import { LightningElement, track, api } from "lwc";
import { events } from "c/sspConstants";
import sspUpload from "@salesforce/label/c.SSP_Upload";
import sspEnterDocumentInformation from "@salesforce/label/c.SSP_EnterDocumentInformation";
import sspCaseNumber from "@salesforce/label/c.SSP_CaseNumber";
import sspHouseholdMember from "@salesforce/label/c.SSP_HouseholdMember";
import sspTypeOfProof from "@salesforce/label/c.SSP_TypeOfProof";
import sspPolicyNumber from "@salesforce/label/c.SSP_PolicyNumber";
import sspFormOfProof from "@salesforce/label/c.SSP_FormOfProof";
import sspDescription from "@salesforce/label/c.SSP_Description";
import sspDownloadStatement from "@salesforce/label/c.SSP_DownloadStatement";
import sspExceedsFileSize from "@salesforce/label/c.SSP_ExceedsFileSize";
import sspAddDocument from "@salesforce/label/c.SSP_AddDocument";
import sspReceivedProof from "@salesforce/label/c.SSP_ReceivedProof";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspCaseNumberTitle from "@salesforce/label/c.SSP_CaseNumberTitle";
import sspHouseholdMemberTitle from "@salesforce/label/c.SSP_HouseholdMemberTitle";
import sspTypeOfProofTitle from "@salesforce/label/c.SSP_StartTypingTitle";
import sspFormOfProofTitle from "@salesforce/label/c.SSP_FormOfProofTitle";
import sspRemoveDocumentTitle from "@salesforce/label/c.SSP_RemoveDocumentTitle";
import sspAddDocumentTitle from "@salesforce/label/c.SSP_AddDocumentTitle";
import sspUploadDocuments from "@salesforce/label/c.SSP_UploadDocuments";
import sspCancelUploadTitle from "@salesforce/label/c.SSP_CancelUploadTitle";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import getTypeOfProofs from "@salesforce/apex/SSP_DocumentCenterCtrl.getTypeOfProofs";
import getFormOfProofs from "@salesforce/apex/SSP_DocumentCenterCtrl.getFormOfProofs";
import deleteDocuments from "@salesforce/apex/SSP_DocumentCenterCtrl.deleteDocuments";
import wizardProcessUpload from "@salesforce/apex/SSP_DocumentCenterCtrl.wizardProcessUpload";
import sspRequiredValidationMsg from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspStartTypingPlaceholder from "@salesforce/label/c.SSP_StartTypingPlaceholder";
import sspMedicalRecord from "@salesforce/label/c.sspMedicalRecord";

export default class SspDocumentCenterGenericUpload extends LightningElement {
    @api caseWrapper;
    @track hasSaveValidationError = false;
    @track selectedCaseNumber;
    @track caseOptions = [];
    @track isDisabledCaseSelect = true;
    @track selectedIndId;
    @track selectedIndName;
    @track indOptions = [];
    @track isDisabledIndSelect = true;
    @track descCaptured;
    @track typeOfProofOptions = [];
    @track selectedTypeOfProof;
    @track selectedTypeOfProofLabel;
    @track formOfProofOptions;
    @track uploadedDocumentList = [];
    @track selectedFormOfProof;
    @track isDisableFileUpload;
    @track policyNumberCaptured;
    @track isKHIPTypeOfProof = false;
    @track trueValue = true;
    @track previousSelectedValue;
    @track isEligibleForRenewal;
    @track taskCode = "";
    @track templateMap = "";
    selectedCaseDetails = "";

    label = {
        sspUpload,
        sspEnterDocumentInformation,
        sspCaseNumber,
        sspHouseholdMember,
        sspTypeOfProof,
        sspPolicyNumber,
        sspFormOfProof,
        sspDescription,
        sspDownloadStatement,
        sspExceedsFileSize,
        sspAddDocument,
        sspReceivedProof,
        sspCancel,
        sspCaseNumberTitle,
        sspHouseholdMemberTitle,
        sspTypeOfProofTitle,
        sspFormOfProofTitle,
        sspRemoveDocumentTitle,
        sspAddDocumentTitle,
        sspUploadDocuments,
        sspCancelUploadTitle,
        toastErrorText,
        sspSummaryRecordValidator,
        sspRequiredValidationMsg,
        sspStartTypingPlaceholder,
        sspMedicalRecord
    };

    /*
     * @function    : getIsDisableFileUpload
     * @description : getter method for isDisableFileUpload
     */
    get isDisabledUploadNext () {
        try {
            if (
                this.uploadedDocumentList &&
                this.uploadedDocumentList.length > 0
            ) {
                return false;
            }
            return true;
        } catch (error) {
            console.error(
                "Error in isDisabledUploadNext" + JSON.stringify(error.message)
            );
            return false;
        }
    }

    /*
     * @function : getSelectListLabel
     * @description	: Method to hide Toast
     */
    getSelectListLabel = (options, valueMatchParam, showTitle) => {
        try {
            let valueMatch = valueMatchParam;
            let label;
            options.forEach(curOpt => {
                if (Number.isInteger(curOpt.value)) {
                    valueMatch = parseInt(valueMatch, 0);
                }
                if (curOpt.value === valueMatch) {
                    if (showTitle) {
                        label = curOpt.title;
                    } else {
                        label = curOpt.label;
                    }
                }
            });
            return label;
        } catch (error) {
            console.error(
                "Error in getSelectListLabel" + JSON.stringify(error.message)
            );
            return null;
        }
    };

    /*
     * @function    : redirectDocCenterHome
     * @description : Method to Redirect back to Document Center Home
     */
    redirectDocCenterHome = () => {
        try {
            const event = new CustomEvent(events.showDocumentCenterHome, {
                bubbles: true,
                composed: true,
                detail: "Show Home"
            });
            this.dispatchEvent(event);
        } catch (error) {
            console.error(
                "Error in redirectDocCenterHome" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error("Error in hideToast" + JSON.stringify(error.message));
        }
    };

    /*
     * @function : connectedCallback
     * @description	: on component load
     */
    connectedCallback () {
        try {
           
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            this.init();
        } catch (error) {
            console.error(
                "Error in connectedCallback" + JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : init
     * @description	: load data
     */
    init = () => {
        try {
            this.showDetailsSpinner = true;
            this.clearData();
            this.setCaseOptions();
            this.setTypeOfProofOptions();
        } catch (error) {
            console.error("Error in init" + JSON.stringify(error.message));
        }
    };

    /*
     * @function : setCaseOptions
     * @description	: set case options
     */
    setCaseOptions = () => {
        try {
            if (this.caseWrapper) {
                this.caseWrapper.forEach(caseItem => {
                    const caseOpt = {};
                    caseOpt.label = caseItem.caseNumber;
                    caseOpt.value = caseItem.caseNumber;
                    this.caseOptions.push(caseOpt);
                });
            }
            if (this.caseOptions.length > 1) {
                this.isDisabledCaseSelect = false;
            } else if (this.caseOptions.length === 1) {
                //if only single value - disabled & set default select
                this.isDisabledCaseSelect = true;
                this.selectedCaseNumber = this.caseOptions[0].value;
                this.setIndOptions();
            } else {
                this.isDisabledCaseSelect = true;
            }
        } catch (error) {
            console.error(
                "Error in setCaseOptions" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : setTypeOfProofOptions
     * @description	: get options for type of proofs
     */
    setTypeOfProofOptions = () => {
        try {
            getTypeOfProofs({})
                .then(response => {
                    if (response.bIsSuccess) {
                        this.typeOfProofOptions =
                            response.mapResponse.typeOfProofs;
                        this.typeOfProofOptions.filter(item => {
                            item.title = item.label;
                            if (item.label.length > 35) {
                                item.label =
                                    item.label.substring(0, 35) + "...";
                            }
                            return item;
                        });
                    }
                    //console.debug("updated values are " + this.typeOfProofOptions);
                    this.showDetailsSpinner = false;
                })
                .catch(function (error) {
                    console.error(error);
                    this.showDetailsSpinner = false;
                });
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error("Error in init" + JSON.stringify(error.message));
        }
    };

    /*
     * @function : clearData
     * @description	: reset data
     */
    clearData = () => {
        try {
            // case
            this.clearCaseInput();
            // ind
            this.clearIndInputData();
            // policy
            this.isKHIPTypeOfProof = false;
            // description input
            this.descCaptured = "";
            //type of proofs
            this.typeOfProofOptions = [];
            this.selectedTypeOfProof = "";
            //form of proofs
            this.formOfProofOptions = [];
            this.taskCode = "";
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error("Error in clearData" + JSON.stringify(error.message));
        }
    };

    /*
     * @function : clearCaseInput
     * @description	: reset data case
     */
    clearCaseInput = () => {
        try {
            this.selectedCaseNumber = "";
            this.caseOptions = [];
            this.isDisabledCaseSelect = true;
            this.selectedCaseDetails = "";
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error(
                "Error in clearCaseInput" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : clearIndInputData
     * @description	: reset data members
     */
    clearIndInputData = () => {
        try {
            this.selectedIndId = "";
            this.indOptions = [];
            this.isDisabledIndSelect = true;
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error(
                "Error in clearIndInputData" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : caseOnChange
     * @description	: Method on change case no.
     * @param {event} evt - Gets current value.
     */
    caseOnChange = evt => {
        try {
            this.clearIndInputData();
            this.selectedCaseNumber = evt.target.value;
            if (
                this.validateInputRequired(
                    this.label.sspRequiredValidationMsg,
                    this.selectedCaseNumber,
                    "ssp-caseInput"
                )
            ) {
                this.setIndOptions();
                this.showDetailsSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in caseOnChange" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };

    /*
     * @function : setIndOptions
     * @description	: set case options
     */
    setIndOptions = () => {
        try {
            // case
            this.selectedIndId = "";
            this.indOptions = [];
            this.isDisabledIndSelect = true;
            this.caseWrapper.forEach(caseItem => {
                if (
                    caseItem.caseNumber === parseInt(this.selectedCaseNumber, 0)
                ) {
                    this.selectedCaseDetails = caseItem;
                    this.indOptions = caseItem.indLst;
                }
            });
            if (this.indOptions && this.indOptions.length > 1) {
                this.isDisabledIndSelect = false;
            } else if (this.indOptions.length === 1) {
                this.selectedIndId = this.indOptions[0].value;
                this.isEligibleForRenewal = this.indOptions[0].isEligibleForRenewal;
                //this.renderPolicyInput();
                this.selectedIndName = this.getSelectListLabel(
                    this.indOptions,
                    this.selectedIndId,
                    false
                );
            }
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error(
                "Error in setIndOptions" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     * @param {event} evt - Gets current value.
     */
    indOnChange = evt => {
        try {
            this.selectedIndId = evt.target.value;
            const indMatch = this.indOptions.find(
                o => o.value === parseInt(this.selectedIndId, 0)
            );
            if (indMatch) {
                this.isEligibleForRenewal = indMatch.isEligibleForRenewal;
            }
            this.selectedIndName = this.getSelectListLabel(
                this.indOptions,
                this.selectedIndId,
                false
            );
            if (
                this.validateInputRequired(
                    this.label.sspRequiredValidationMsg,
                    this.selectedIndId,
                    "ssp-indInput"
                )
            ) {
                //this.renderPolicyInput();
                this.showDetailsSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in indOnChange" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };

    /*
     * @function : isRenderPolicyInput
     * @description	: show/hide policy input
     */
    get isRenderPolicyInput () {
        try {
            let isRender = false;
            //console.debug(' -*- this.isKHIPMember() '+this.isKHIPMember());
            //console.debug(' -*- this.isKHIPTypeOfProof '+this.isKHIPTypeOfProof);
            if (this.isKHIPMember() && this.isKHIPTypeOfProof) {
                isRender = true;
            } else {
                isRender = false;
            }
            //console.debug(' -*- isRender '+isRender);
            return isRender;
        } catch (error) {
            console.error(
                "Error in isRenderPolicyInput" + JSON.stringify(error.message)
            );
            return false;
        }
    }

    /*
     * @function : isSuitableProgramForPolicy
     * @description	: is K-HIPP program associated with member
     */
    isKHIPMember = () => {
        let isSuitable = false;
        try {
            if (
                this.selectedCaseDetails !== null &&
                this.selectedCaseDetails !== "" &&
                this.selectedCaseDetails.indLst &&
                this.selectedCaseDetails.indLst !== ""
            ) {
                this.selectedCaseDetails.indLst.forEach(indItem => {
                    if (
                        indItem.value === this.selectedIndId &&
                        indItem.programs !== null &&
                        indItem.programs !== "" &&
                        indItem.programs
                            .toUpperCase()
                            .split(";")
                            .includes("KP")
                    ) {
                        isSuitable = true;
                    }
                });
            }
            isSuitable = true;
        } catch (error) {
            console.error(
                "Error in isKHIPMember" + JSON.stringify(error.message)
            );
        }
        return isSuitable;
    };

    /*
     * @function : onDescChange
     * @description	: On change Description
     * @param {event} evt - Gets current value.
     */

    onDescChange = evt => {
        try {
            this.descCaptured = evt.target.value;
            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.descCaptured,
                "ssp-descInput"
            );
        } catch (error) {
            console.error(
                "Error in onDescChange" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : onChangePolicyNumber
     * @description	: On change Policy number
     * @param {event} evt - Gets current value.
     */

    onChangePolicyNumber = evt => {
        try {
            this.policyNumberCaptured = evt.target.value;
        } catch (error) {
            console.error(
                "Error in onDescChange" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : onChangeTypeOfProof
     * @description	: Method on change type of proof
     * @param {event} evt - Gets current value.
     */
    onChangeTypeOfProof = evt => {
        try {
            this.formOfProofOptions = [];
            /*this.selectedTypeOfProof = evt.target.value;*/
            this.selectedTypeOfProof = evt.detail.selectedValue;
            if (evt.target.value !== this.previousSelectedValue) {
                this.showDetailsSpinner = true;
                /*this.previousSelectedValue = evt.target.value;*/
                this.previousSelectedValue = evt.detail.selectedValue;
            }
            this.selectedTypeOfProofLabel = this.getSelectListLabel(
                this.typeOfProofOptions,
                this.selectedTypeOfProof,
                true
            );
            this.template
                .querySelector("c-ssp-type-ahead-picklist")
                .ErrorMessages();
            if (
                this.selectedTypeOfProof !== "" &&
                this.selectedTypeOfProof !== null &&
                this.selectedTypeOfProof !== undefined
            ) {
                this.setFormProofOptions();
                this.selectedFormOfProof = "";
            } else {
                this.showDetailsSpinner = false;
                this.isKHIPTypeOfProof = false;
                this.taskCode = "";
            }
        } catch (error) {
            console.error(
                "Error in onChangeTypeOfProof" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };

    /*
     * @function : setFormProofOptions
     * @description	: get options for form of proofs
     */
    setFormProofOptions = () => {
        try {
            getFormOfProofs({
                typeOfProofCode: this.selectedTypeOfProof
            })
                .then(response => {
                    //console.debug('-X- response is : '+JSON.stringify(response));
                    if (response.bIsSuccess) {
                        this.formOfProofOptions =
                            response.mapResponse.formOfProofs;
                        this.formOfProofOptions.filter(item => {
                            item.title = item.label;
                            if (item.label.length > 35) {
                                item.label =
                                    item.label.substring(0, 35) + "...";
                            }
                            return item;
                        });

                        this.formOfProofOptions.forEach(item => {
                            if (item.value === "ME") {
                                item.label = sspMedicalRecord;
                            }
                        });

                        /*N start */
                        this.templateMap = response.mapResponse.templateMap;
                        this.template
                            .querySelector(".ssp-completeQuestions")
                            .click();
                        if (response.mapResponse.isKHIPTypeOfProof) {
                            this.isKHIPTypeOfProof = true;
                        } else {
                            this.isKHIPTypeOfProof = false;
                        }
                        if (
                            response.mapResponse.taskCode &&
                            response.mapResponse.taskCode !== ""
                        ) {
                            this.taskCode = response.mapResponse.taskCode;
                        } else {
                            this.taskCode = "";
                        }
                        this.showDetailsSpinner = false;
                    } else {
                        this.showDetailsSpinner = false;
                        this.isKHIPTypeOfProof = false;
                        this.taskCode = "";
                    }
                })
                .catch(function (error) {
                    console.error(error);
                    this.showDetailsSpinner = false;
                });
        } catch (error) {
            console.error("Error in init" + JSON.stringify(error.message));
            this.showDetailsSpinner = false;
        }
    };
    /*
     * @function : formOfProofOnChange
     * @description	: uploaded single file
     */
    formOfProofOnChange = evt => {
        try {
            // validate if files are here;
            this.showDetailsSpinner = true;
            this.selectedFormOfProof = evt.detail;
            this.showDetailsSpinner = false;
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : singleFileUploaded
     * @description	: uploaded single file
     */
    singleFileUploaded = evt => {
        try {
            // validate if files are here
            
            this.uploadedDocumentList = evt.detail;
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : uploadDocuments
     * @description	: Upload selected documents
     */
    uploadDocuments = () => {
        try {
            this.showDetailsSpinner = true;
                const isValidInputs = this.runValidateForAllInputs();
                if (!isValidInputs) {
                    this.hasSaveValidationError = true;
                    this.showDetailsSpinner = false;
                } else {
                    this.hasSaveValidationError = false;
                    const docToBeUploaded = [];
                    for (let i = 0; i < this.uploadedDocumentList.length; i++) {
                        docToBeUploaded.push(
                            this.uploadedDocumentList[i].fileId
                        );
                    }
                  
                    wizardProcessUpload({
                        docWrapLst: this.uploadedDocumentList,
                        contentVersionLst: docToBeUploaded
                    })
                        .then(response => {
                            if (response.bIsSuccess) {
                                this.redirectDocCenterHome();
                            } else {
                                console.error(JSON.stringify(response));
                            }
                            this.showDetailsSpinner = false;
                        })
                        .catch(function (error) {
                            console.error(error);
                            this.showDetailsSpinner = false;
                        });
                }
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };
    handleResetFormOfProof = () => {
        this.selectedFormOfProof = "";
    }
    /*
     * @function : runValidateForAllInputs
     * @description	: Verify whether required inputs are present
     * @param {event} evt - Gets current value
     */
    runValidateForAllInputs = () => {
        try {
            this.template
                .querySelector("c-ssp-type-ahead-picklist")
                .ErrorMessages();
            // Show required message for missing fields
            const isValidCaseSelect = this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedCaseNumber,
                "ssp-caseInput"
            );
            const isValidIndSelect = this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedIndId,
                "ssp-indInput"
            );
            const isValidDesc = this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.descCaptured,
                "ssp-descInput"
            );
            if(!isValidDesc) {
                this.template.querySelector(".ssp-descInput").ErrorMessages();
            }
            const isValidTypeProof = this.template.querySelector(
                ".ssp-typeOfProofInput"
            ).ErrorMessageList.length
                ? false
                : true;
            this.template
                .querySelector("c-ssp-document-file-upload")
                .validateFormProofField();
            if (
                isValidCaseSelect &&
                isValidIndSelect &&
                isValidDesc &&
                isValidTypeProof &&
                this.selectedFormOfProof &&  this.uploadedDocumentList &&
                this.uploadedDocumentList.length > 0
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
            return null;
        }
    };

    /**
     * @function : validateInputRequired
     * @description : validations for toggle options.
     * @param {string} msg - Msg.
     * @param {string} inputVal - InputVal.
     * @param {string} inputClass - InputClass.
     */
    validateInputRequired = (msg, inputVal, inputClass) => {
        try {
            let isValidData;
            const inputElement = this.template.querySelector("." + inputClass);
            let messageList = inputElement.ErrorMessageList;
            if (!messageList) {
                messageList = [];
            }
            const indexOfMessage = messageList.indexOf(msg);
            if (
                inputVal === null ||
                inputVal === undefined ||
                (typeof inputVal === "string"
                    ? inputVal.trim() === ""
                    : inputVal === "")
            ) {
                if (indexOfMessage === -1) {
                    messageList.push(msg);
                    inputElement.ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
                isValidData = false;
            }
            // valid data
            else {
                if (indexOfMessage >= 0) {
                    messageList.splice(indexOfMessage, 1);
                    inputElement.ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
                isValidData = true;
            }
            return isValidData;
        } catch (error) {
            console.error(
                "Error in validateInputRequired" + JSON.stringify(error.message)
            );
            return false;
        }
    };

    /**
     * @function : cancelAndNavigate
     * @description : navigate to dashboard.
     */

    cancelAndNavigate () {
        try {
            this.showDetailsSpinner = true;
            const docToBeDeleted = [];
            for (let i = 0; i < this.uploadedDocumentList.length; i++) {
                docToBeDeleted.push(this.uploadedDocumentList[i].fileId);
            }
            if (docToBeDeleted && docToBeDeleted.length > 0) {
                deleteDocuments({
                    contentVersionLst: docToBeDeleted
                })
                    .then(response => {
                        if (response.bIsSuccess) {
                            this.redirectDocCenterHome();
                            this.showDetailsSpinner = false;
                        }
                        this.showDetailsSpinner = false;
                    })
                    .catch(function (error) {
                        console.error(error);
                    });
            } else {
                this.redirectDocCenterHome();
                this.showDetailsSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    }
}