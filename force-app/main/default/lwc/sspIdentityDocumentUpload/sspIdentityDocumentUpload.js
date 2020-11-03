/*
 * Component Name: sspIdentityDocumentUpload.
 * Author:  Nikhil Shinde, Prasanth.
 * Description: sspIdentityDocumentUpload
 * Date: 25-06-2020
 */

import { LightningElement, track, api } from "lwc";
import sspConstants from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";

import sspIdentityUploadHeader from "@salesforce/label/c.SSP_ApplicantVerificationIdentityUploadHeader";
import sspIAttest from "@salesforce/label/c.SSP_ApplicantVerificationIAttest";
import sspUploadDocumentButton from "@salesforce/label/c.SSP_ApplicantVerificationUploadDocumentButton";

//delete unwanted labels
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspUpload from "@salesforce/label/c.SSP_Upload";
import sspFormOfProof from "@salesforce/label/c.SSP_FormOfProof";
import sspAddDocumentTitle from "@salesforce/label/c.SSP_AddDocumentTitle";
import sspAddDocument from "@salesforce/label/c.SSP_AddDocument";
import sspAttachProofDocument from "@salesforce/label/c.SSP_AttachProofDocument";
import sspErrorUploading from "@salesforce/label/c.SSP_ErrorUploading";
import sspExceedsFileSize from "@salesforce/label/c.SSP_ExceedsFileSize";
import sspReceivedProof from "@salesforce/label/c.SSP_ReceivedProof";
import sspFormOfProofTitle from "@salesforce/label/c.SSP_FormOfProofTitle";
import sspFormOfProofHelpText from "@salesforce/label/c.SSP_FormOfProofHelpText";

import sspAddAdditionalDocument from "@salesforce/label/c.SSP_AddAdditionalDocument";
import sspRemoveDocumentTitle from "@salesforce/label/c.SSP_RemoveDocumentTitle";
import sspRemoveDocumentModalHeader from "@salesforce/label/c.SSP_RemoveDocumentModalHeader";
import sspRemoveDocumentModalContent from "@salesforce/label/c.SSP_RemoveDocumentModalContent";

import ImageCompressor from "@salesforce/resourceUrl/ImageCompressor";
import { loadScript } from "lightning/platformResourceLoader";
import validatorMsgFileSize from "@salesforce/label/c.SSP_FileSizeValidationMessage";
import errorUploadingMsg from "@salesforce/label/c.SSP_Error_Uploading";
import fileUploadedSuccessMsg from "@salesforce/label/c.SSP_FileUploaded";
import sspRemoveDocumentButtonTitle from "@salesforce/label/c.SSP_RemoveDocumentModalTitle";
import cancelButtonTitle from "@salesforce/label/c.SSP_CancelRemoveDocumentTitle";
import sspSelectDocumentTitle from "@salesforce/label/c.SSP_SelectDocumentTitle";
import sspSelectDocumentToUpload from "@salesforce/label/c.SSP_SelectDocumentToUpload";
import sspRequiredValidationMsg from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspFileSizeError from "@salesforce/label/c.SSP_FileSizeError";
import sspFileTypeError from "@salesforce/label/c.SSP_FileTypeError";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspNextButton from "@salesforce/label/c.SSP_NextButton";
import sspNextAltText from "@salesforce/label/c.SSP_NextAltText";
import sspUploadAlternateText from "@salesforce/label/c.SSP_ApplicantVerificationIdentityUploadAlternateText";
import sspFormOfProofAlternateText from "@salesforce/label/c.SSP_ApplicantVerificationFormOfProofAlternateText";
import sspBackTitle from "@salesforce/label/c.SSP_BackAltText";

// import saveData from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.saveData";
import deleteDocuments from "@salesforce/apex/SSP_DocumentCenterCtrl.deleteDocuments";
import saveChunk from "@salesforce/apex/SSP_DocumentCenterCtrl.saveChunk";
import getConfigValues from "@salesforce/apex/SSP_DocumentCenterCtrl.getConfigValues";
import getValuesFromPickList from "@salesforce/apex/SSP_IdentityVerificationUploadController.getValuesFromPickList";

//import wizardProcessUpload from "@salesforce/apex/SSP_DocumentCenterCtrl.wizardProcessUpload";
import wizardProcessUpload from "@salesforce/apex/SSP_DocumentCenterCtrl.identityWizardProcessUpload";
import updateApplicationStatusUnsubmitted from "@salesforce/apex/SSP_RIDPServices.updateApplicationStatusUnSubmitted";

export default class SspIdentityDocumentUpload extends NavigationMixin(
    LightningElement
) {
    @api selectedCaseNumber;
    @api selectedIndId;
    @api descCaptured;
    @api selectedTypeOfProof;
    @api formOfProofOptions;
    @api handleGeneric;
    @api selectedFormOfProof;
    @api policyNoCaptured;
    @api selectedFormOfProofName;
    @api selectedIndName;
    @api currentRFIIdentifier;
    @api isEligibleForRenewal;
    @api taskCode;
    @api language;
    @api sDueDate;

    @track label = {
        sspIdentityUploadHeader,
        sspIAttest,
        sspUploadDocumentButton,
        toastErrorText,
        sspSummaryRecordValidator,
        sspUpload,
        sspFormOfProof,
        sspAddDocumentTitle,
        sspAddDocument,
        sspAttachProofDocument,
        sspErrorUploading,
        sspExceedsFileSize,
        sspReceivedProof,
        sspFormOfProofTitle,
        sspFormOfProofHelpText,
        sspAddAdditionalDocument,
        sspRemoveDocumentTitle,
        sspRemoveDocumentModalHeader,
        sspRemoveDocumentModalContent,
        validatorMsgFileSize,
        errorUploadingMsg,
        fileUploadedSuccessMsg,
        sspRemoveDocumentButtonTitle,
        cancelButtonTitle,
        sspSelectDocumentTitle,
        sspSelectDocumentToUpload,
        sspFileSizeError,
        sspFileTypeError,
        sspRequiredValidationMsg,
        sspExitButton,
        sspNextButton,
        sspNextAltText,
        sspUploadAlternateText,
        sspFormOfProofAlternateText,
        sspBackTitle
    };
    @track showSpinner = false;
    @track restrictAddDocument = true;
    @track fileName = "";
    @track filesUploaded;
    @track fileName;
    @track showError = false;
    @track uploadedDocumentList = [];
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track fileUploadDisabled = false;
    @track toastCondition = "positive"; // For Error Toast ,change this to negative
    @track showDetailsSpinner;
    @track selectedProofName;
    @track sspSelectDocumentToUploadTitle;
    @track errorFileUploadErrorAtField;
    @track showUploadError = false;
    @track toastAdditionalInfo = "";
    @track showFileNotUploadedError = false;
    @track showFileNotUploadedTileHiddenError = false;
    @track showFormOfProofError = false;
    @track identityFormOfProofOptions = [];
    @track objectInfo;
    @track parameters;
    @track jsonData;
    @track uploadSuccessFull = false;
    @track isAttest = false;
    @track individualId;
    @track appId;
    @track memberIndividualId;
    @track programRemoved = false;
    @track finalProgramListSize = false;
    //default if custom setting absent
    convertSize = sspConstants.sspDocUpload.convertSize;
    quality = sspConstants.sspDocUpload.quality;

    /**
     * @function : calculateDisable.
     * @description : input disable.
     */
    calculateDisableFileInp = () => {
        try {
            let doDisable;
            if (this.handleGeneric === "true") {
                if (
                    this.selectedCaseNumber &&
                    this.selectedIndId &&
                    this.descCaptured &&
                    this.selectedTypeOfProof &&
                    this.selectedFormOfProof
                ) {
                    doDisable = false;
                } else {
                    doDisable = true;
                }
                this.sspSelectDocumentToUploadTitle = this.label.sspSelectDocumentToUpload;
            } else {
                this.sspSelectDocumentToUploadTitle = this.label.sspAddAdditionalDocument;
                if (this.selectedFormOfProof) {
                    doDisable = false;
                } else {
                    doDisable = true;
                }
            }
            return doDisable;
        } catch (error) {
            console.error(
                "Error in calculateDisableFileInp" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    };

    /**
     * @function : statusClassUploadInput.
     * @description : Getter setters for input disable.
     */
    get isDisableUploadInput () {
        try {
            return this.calculateDisableFileInp();
        } catch (error) {
            console.error(
                "Error in isDisableUploadInput" + JSON.stringify(error.message)
            );
            return false;
        }
    }

    /**
     * @function : statusClassUploadInput.
     * @description : Getter setters for Status class name.
     */
    get statusClassUploadInput () {
        const doDisable = this.calculateDisableFileInp();
        try {
            return doDisable
                ? "ssp-fileUploadDisabled"
                : "ssp-fileUploadEnabled";
        } catch (error) {
            console.error(
                "Error in statusClass of SspDocumentFileUpload" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    }

    /**
     * @function : statusClassUploadInput.
     * @description : Getter setters for Status class name.
     */
    get isWrittenStatementSelected () {
        try {
            if (
                this.selectedFormOfProof &&
                this.selectedFormOfProof === "WTNS"
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error(
                "Error in isWrittenStatementSelected" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    }

    /**
     * @function : showUploadedDocList.
     * @description : Getter setters for list of uploaded documents.
     */
    get showUploadedDocList () {
        try {
            let doShow = false;
            if (this.uploadedDocumentList.length > 0) {
                doShow = true;
            }
            return doShow;
        } catch (error) {
            console.error(
                "Error in showUploadedDocList" + JSON.stringify(error.message)
            );
            return false;
        }
    }

    /*
     * @function : connectedCallback
     * @description	: on load of comp
     */
    connectedCallback () {
        try {
            this.parameters = this.getQueryParameters();
            this.showDetailsSpinner = true;
            this.handleGeneric = false;
            this.appId = this.parameters.applicationId;
            this.memberIndividualId = this.parameters.memberId;
     
            loadScript(this, ImageCompressor)
                .then(() => {
                    //script loaded
                })
                .catch(error => {
                    console.error(
                        "Error in loadScript Compressor" +
                            JSON.stringify(error.message)
                    );
                });
            getConfigValues({})
                .then(response => {
                    if (response.bIsSuccess) {
                        this.showDetailsSpinner = false;
                        if (response.mapResponse.quality) {
                            this.quality = parseFloat(
                                response.mapResponse.quality
                            );
                        }
                        if (response.mapResponse.convertSize) {
                            this.convertSize = parseInt(
                                response.mapResponse.convertSize,
                                0
                            );
                        }
                        this.language = response.mapResponse.language;
                    } else {
                        console.error(JSON.stringify("error in loadScript"));
                        this.showDetailsSpinner = false;
                    }
                })
                .catch(function (error) {
                    console.error(error);
                    this.showDetailsSpinner = false;
                });
            getValuesFromPickList({
                objectName: "DocumentDetail__c",
                fieldName: "Identity_Form_of_Proof__c",
                memberId: this.memberIndividualId
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        const pickListData = result.mapResponse;
                        if (pickListData.hasOwnProperty("FormOfProofOptions")) {
                            const fopList = [];
                            const retrievedFOP =
                                pickListData.FormOfProofOptions;
                            Object.keys(retrievedFOP).forEach(key => {
                                fopList.push({
                                    label: retrievedFOP[key],
                                    value: key
                                });
                            });
                            this.identityFormOfProofOptions = fopList;
                        }
                        
                        if (pickListData.hasOwnProperty("memberName")) {
                            this.selectedIndName = pickListData.memberName;
                        }
                    }
                })
                .catch(error => {
                    console.error(
                        "@@Error in getValuesFromPickList =>" +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error(
                "Error in connectedCallback" + JSON.stringify(error.message)
            );
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
                "Error in hideToast of SspDocumentFileUpload" +
                    JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : onChangeFormOfProof
     * @description	: Method on change form of proof
     * @param {event} evt - Gets current value.
     */
    onChangeFormOfProof = event => {
        try {
            this.selectedFormOfProof = event.target.value;
            if (event.target.value !== "") {
                const selectedPicklistValues = JSON.parse(
                    JSON.stringify(this.identityFormOfProofOptions)
                );
                const result = selectedPicklistValues.find(
                    obj => obj.value === this.selectedFormOfProof
                );
                this.selectedProofName = result.label;
            }

            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedFormOfProof,
                "ssp-formOfProofInput"
            );
            // const evt = new CustomEvent(sspConstants.events.formProofChange, {
            //     detail: this.selectedFormOfProof
            // });
            // this.dispatchEvent(evt);
        } catch (error) {
            console.error(
                "Error in onChangeTypeOfProof" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : onFileChange
     * @description	:Event handler for File change
     *  @param {object} event - Js event.
     */
    onFileChange = event => {
        try {
            this.showDetailsSpinner = true;
            if (event.target.files.length > 0) {
                this.showError = false;
                this.fileName = event.target.files[0].name;
                const parts = this.fileName.split(".");
                // image - compress & upload
                if (
                    sspConstants.sspDocUpload.supportedSet1.includes(
                        parts[parts.length - 1].toUpperCase()
                    )
                ) {
                    //pre compression validations for image
                    const validationRes = this.validateFile(
                        parts[parts.length - 1].toUpperCase(),
                        event.target.files[0].size,
                        true
                    );
                    if (validationRes.isValid) {
                        //proceed with upload
                        const options = {
                            minWidth: 0,
                            minHeight: 0,
                            quality: this.quality,
                            convertSize: this.convertSize,
                            success: result => {
                                this.filesUploaded = result;
                                if (
                                    (parts[parts.length - 1] === "png" || parts[parts.length - 1] === "PNG") &&
                                    // eslint-disable-next-line spellcheck/spell-checker
                                    (this.filesUploaded.name.includes("jpg") || this.filesUploaded.name.includes("JPG"))
                                ) {
                                    this.filesUploaded.name = this.filesUploaded.name.replace(
                                        // eslint-disable-next-line spellcheck/spell-checker
                                        "jpg",
                                        "png"
                                    );
                                }
                                this.stageUploadFile();
                            },
                            error: err => {
                                console.error("Error: ", err);
                            }
                        };
                        // eslint-disable-next-line no-undef
                        new Compressor(event.target.files[0], options);
                    } else {
                        //Show Validation Message
                        this.displayFileValidations(
                            validationRes,
                            parts[parts.length - 1]
                        );
                    }
                } else {
                    this.filesUploaded = event.target.files[0];
                    this.stageUploadFile();
                }
            } else {
                this.showDetailsSpinner = false;
                this.showError = true;
            }
        } catch (error) {
            this.showDetailsSpinner = false;
            console.error("Error in handleFilesChange function", error);
        }
    };

    /**
     * @function : validateFile
     * @description : validations on uploaded files.
     * @param {string} fileExt - Js fileExt.
     * @param {size} fileSize - Js fileSize.
     * @param {boolean} isPreCompressionValidate - Is validation called before compression.
     */

    validateFile = (fileExt, fileSize, isPreCompressionValidate) => {
        try {
            const validationRes = {};
            let imageMaxSize;
            validationRes.isValid = true;
            if (isPreCompressionValidate) {
                imageMaxSize = sspConstants.sspDocUpload.preMaxSizeSet1;
            } else {
                imageMaxSize = sspConstants.sspDocUpload.maxSizeSet1;
            }

            //type check
            if (
                !sspConstants.sspDocUpload.allSupportedFiles.includes(fileExt)
            ) {
                validationRes.isValid = false;
                validationRes.msg = this.label.sspErrorUploading;
                validationRes.fileType = fileExt;
            }
            // size check
            else if (
                (sspConstants.sspDocUpload.supportedSet1.includes(fileExt) &&
                    fileSize > imageMaxSize) ||
                (sspConstants.sspDocUpload.supportedSet2.includes(fileExt) &&
                    fileSize > sspConstants.sspDocUpload.maxSizeSet2)
            ) {
                validationRes.isValid = false;
                validationRes.msg = this.label.sspExceedsFileSize;
            }
            return validationRes;
        } catch (error) {
            console.error(
                "Error in validateFile" + JSON.stringify(error.message)
            );
            return false;
        }
    };

    /**
     * @function : displayFileValidations
     * @description : display validation messages.
     *  @param {object} validationRes - Obj.
     *  @param {string} extension - Extension.
     */
    displayFileValidations = (validationRes, extension) => {
        try {
            if (validationRes.msg === this.label.sspErrorUploading) {
                this.showDetailsSpinner = false;
                this.toastErrorText = this.label.sspErrorUploading;
                this.toastAdditionalInfo = "";
                this.toastCondition = "negative";
                this.hasSaveValidationError = true;
                this.errorFileUploadErrorAtField = this.label.sspFileTypeError;
                this.showUploadError = true;
            }
            if (validationRes.msg === this.label.sspExceedsFileSize) {
                this.showDetailsSpinner = false;
                this.toastAdditionalInfo = this.label.sspExceedsFileSize;
                this.toastErrorText = this.label.sspErrorUploading;
                this.toastCondition = "negative";
                this.hasSaveValidationError = true;
                if (
                    sspConstants.sspDocUpload.supportedSet1.includes(
                        extension.toUpperCase()
                    )
                ) {
                    this.errorFileUploadErrorAtField = formatLabels(
                        this.label.sspFileSizeError,
                        ["5"]
                    );
                } else {
                    this.errorFileUploadErrorAtField = formatLabels(
                        this.label.sspFileSizeError,
                        ["2"]
                    );
                }
                this.showUploadError = true;
            }
        } catch (error) {
            console.error(
                "Error in displayFileValidations" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    };

    /*
     * @function : stageUploadFile
     * @description	:parse and validate upload file
     */
    stageUploadFile = () => {
        try {
            const parts = this.fileName.split(".");
            const extension = parts[parts.length - 1];
            //validations
            const validationRes = this.validateFile(
                extension.toUpperCase(),
                this.filesUploaded.size,
                false
            );
            if (validationRes.isValid) {
                this.showUploadError = false;
                this.showFileNotUploadedError = false;
                this.errorFileUploadErrorAtField = null;
                //upload
                this.uploadFile();
            } else {
                //Show Validation Message
                this.displayFileValidations(validationRes, extension);
            }
        } catch (error) {
            this.showDetailsSpinner = false;
        }
    };

    /*
     * @function : uploadFile
     * @description	:chunking on Save
     */
    uploadFile = () => {
        try {
            if (this.filesUploaded) {
                this.showError = false;
                const file = this.filesUploaded;
                const fileType = file.name.substr(
                    file.name.lastIndexOf(".") + 1
                );
                const fileName = file.name;
                const fileReader = new FileReader();
                fileReader.onloadend = () => {
                    this.fileContents = fileReader.result;
                    const base64 = "base64,";
                    const content =
                        this.fileContents.indexOf(base64) + base64.length;
                    this.fileContents = this.fileContents.substring(content);
                    const startPosition = 0;
                    // calculate the end size or endPosition using Math.min() function which is return the min. value
                    const endPosition = Math.min(
                        this.fileContents.length,
                        startPosition + sspConstants.sspDocUpload.chunkSize
                    );
                    // start with the initial chunk, and set the attachId(last parameter)is null in begin
                    this.uploadInChunk(
                        file,
                        this.fileContents,
                        startPosition,
                        endPosition,
                        fileName,
                        fileType,
                        ""
                    );
                };
                fileReader.readAsDataURL(file);
            } else {
                this.showError = true;
            }
        } catch (error) {
            console.error("Error in uploadFile", error);
        }
    };

    /*
     * @function : uploadInChunk
     * @description	:Event handler for File upload in Chunk.Upload in chunk
     */
    uploadInChunk (
        file,
        fileContents,
        startPositionParam,
        endPositionParam,
        fileName,
        fileType,
        fileId
    ) {
        try {
            let startPosition = startPositionParam;
            let endPosition = endPositionParam;
            const getChunk = fileContents.substring(startPosition, endPosition);
            saveChunk({
                parentId: "",
                strFileName: fileName,
                strBase64Data: encodeURIComponent(getChunk),
                strContentType: fileType,
                strFileId: fileId,
                strDocType: ""
            })
                .then(response => {
                    if (response.bIsSuccess) {
                        const returnedFileId = response.mapResponse.fileId;
                        const contentDocumentId =
                            response.mapResponse.contentDocId;
                        startPosition = endPosition;
                        endPosition = Math.min(
                            fileContents.length,
                            startPosition + sspConstants.sspDocUpload.chunkSize
                        );
                        if (startPosition < endPosition) {
                            this.uploadInChunk(
                                file,
                                fileContents,
                                startPosition,
                                endPosition,
                                fileName,
                                fileType,
                                returnedFileId
                            );
                        } else {
                            this.postUploadProcessing(
                                returnedFileId,
                                fileName,
                                fileType,
                                contentDocumentId
                            );
                        }
                    }
                })
                .catch(function (error) {
                    console.error(error);
                });
        } catch (error) {
            console.error(
                "Error in uploadInChunk" + JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : postUploadProcessing
     * @description	:Function for processing files post upload
     */
    postUploadProcessing (fileId, fileName, fileType, contentDocumentId) {
        try {
            const uploadedFileDetails = {};
            // mapping
            if (this.handleGeneric === "true") {
                uploadedFileDetails.description = this.descCaptured;
                uploadedFileDetails.policyNumber = this.policyNoCaptured;
            } else {
                uploadedFileDetails.rfiIdentifier = this.currentRFIIdentifier;
            }
            uploadedFileDetails.fileId = fileId;
            uploadedFileDetails.contentDocumentId = contentDocumentId;
            uploadedFileDetails.fileName = fileName;
            uploadedFileDetails.fileType = fileType;
            uploadedFileDetails.caseNumber = this.selectedCaseNumber;
            uploadedFileDetails.individualId = this.selectedIndId;
            // Type of proof code
            uploadedFileDetails.proofCode = this.selectedTypeOfProof;
            // Type of proof name
            uploadedFileDetails.proof = this.selectedFormOfProofName;
            // Form of proof code
            uploadedFileDetails.formOfProof = this.selectedFormOfProof;
            // Form of proof name
            uploadedFileDetails.proofName = this.selectedProofName;
            uploadedFileDetails.selectDocumentTitle = formatLabels(
                this.label.sspSelectDocumentTitle,
                [fileName]
            );
            uploadedFileDetails.isEligibleForRenewal = this.isEligibleForRenewal;
            uploadedFileDetails.taskCode = this.taskCode;
            uploadedFileDetails.sDueDate = this.sDueDate;
            this.uploadedDocumentList.push(uploadedFileDetails);

            //success toast message
            this.sspReceivedProofText = formatLabels(
                this.label.sspReceivedProof,
                [this.selectedIndName, this.selectedFormOfProof]
            );

            this.toastCondition = "positive";
            this.toastErrorText = this.sspReceivedProofText;
            this.toastAdditionalInfo = "";
            this.hasSaveValidationError = true;
            //reset
            this.fileName = "";
            this.filesUploaded = "";
            //allow new doc
            this.restrictAddDocument = false;
            const evt = new CustomEvent(sspConstants.events.singleFileUpload, {
                detail: this.uploadedDocumentList
            });
            this.dispatchEvent(evt);

      // 390440
      this.showFileNotUploadedTileHiddenError = false;

            // File uploaded toast.
            this.showDetailsSpinner = false;
        } catch (error) {
            console.error(
                "Error in postUploadProcessing" + JSON.stringify(error.message)
            );
        }
    }
    /**
     * @function : applyChanges
     * @description	:apply changes.
     */
    @api
    applyChanges () {
        this.formOfProofOptions = JSON.parse(
            JSON.stringify(this.formOfProofOptions)
        );
    }

    /*
     * @function : validateFormProofField
     * @description	:To validate Form Proof Field
     */
    validateFormProofField () {
        try {
            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedFormOfProof,
                "ssp-formOfProofInput"
            );
            if (
                this.uploadedDocumentList &&
                this.uploadedDocumentList.length > 0
            ) {
                this.showFileNotUploadedError = false;
            } else {
                if (this.handleGeneric === "true") {
                    this.showFileNotUploadedError = true;
                }
                if (!this.restrictAddDocument) {
                    this.showFileNotUploadedTileHiddenError = true;
                } else {
                    this.showFileNotUploadedTileHiddenError = false;
                }
                if (this.uploadSuccessFull === false) {
                    this.showFileNotUploadedTileHiddenError = true;
                }
            }
        } catch (error) {
            console.error("Error in validateFormProofField");
        }
    }
    /**
     * @function - renderedCallback
     * @description - This method is used to called whenever there is track variable changing.
     */
    renderedCallback () {
        if (this.showFormOfProofError) {
            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedFormOfProof,
                "ssp-formOfProofInput"
            );
            this.showFormOfProofError = false;
        }
    }

    /**
     * @function : handleExitButton
     * @description : This method is used for exit function.
     ** @param {*} event -  This parameter provides the updated value.
     */
    handleCheckboxChange = event => {
        try {
            this.isAttest = event.target.value;
            const validateCheckBox = this.template.querySelector(
                ".ssp-identityCheckBox"
            );
            if (this.isAttest === false) {
                validateCheckBox.ErrorMessageList = [
                    this.label.sspRequiredValidationMsg
                ];
            } else {
                validateCheckBox.ErrorMessageList = [];
            }
        } catch (error) {
            console.error("Error in handleCheckboxChange =>", error);
        }
    };

    /*
     * @function : enableSectionDocUpload
     * @description	:Function to enable Document Upload
     */
    enableSectionDocUpload = () => {
        try {
            this.showFileNotUploadedTileHiddenError = false;
            const resetEvent = new CustomEvent(
                sspConstants.events.resetFormOfProof,
                {
                    detail: {
                        formOfProofValue: this.selectedFormOfProof
                    }
                }
            );
            this.dispatchEvent(resetEvent);
            this.calculateDisableFileInp();
            this.restrictAddDocument = true;
        } catch (error) {
            console.error(
                "Error in enableSectionDocUpload" +
                    JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : deleteTheFile
     * @description	:Function to delete the file
     */
    deleteTheFile = event => {
        try {
            this.showDetailsSpinner = true;
            const targetDelId = event.target.dataset.itemId;
            deleteDocuments({
                contentVersionLst: [targetDelId]
            })
                .then(response => {
                    if (response.bIsSuccess) {
                        let index;
                        for (
                            let i = 0;
                            i < this.uploadedDocumentList.length;
                            i++
                        ) {
                            if (
                                this.uploadedDocumentList[i].fileId ===
                                targetDelId
                            ) {
                                index = i;
                            }
                        }
                        this.uploadedDocumentList.splice(index, 1);
                        const evt = new CustomEvent(
                            sspConstants.events.singleFileUpload,
                            {
                                detail: this.uploadedDocumentList
                            }
                        );
                        this.dispatchEvent(evt);
                        this.enableSectionDocUpload();
                        this.showDetailsSpinner = false;
                        this.uploadSuccessFull = false; //#385758
                        if (this.handleGeneric === "true") {
                            if (
                                this.uploadedDocumentList &&
                                this.uploadedDocumentList.length > 0
                            ) {
                                this.restrictAddDocument = false;
                            } else if (!this.restrictAddDocument) {
                                this.selectedFormOfProof = "";
                                this.restrictAddDocument = true;
                            }
                        }
                    } else {
                        this.showDetailsSpinner = false;
                    }
                })
                .catch(function (error) {
                    console.error("Error in deleteTheFile =>", error);
                    this.showDetailsSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error in deleteDocuments" + JSON.stringify(error.message)
            );
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
            // invalid data
            if (
                inputVal === null ||
                inputVal === "" ||
                inputVal === undefined
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
     * @function : openFile
     * @description : open document in new tab.
     * @param {event} event - Gets current value.
     */
    openFile = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                const documentData = {};
                const documentName = event.target.dataset.documentName;
                this.documentNameTemp = documentName;
                const extension = event.target.dataset.extension;
                this.extensionTemp = extension;
                const contentDocumentId = event.target.dataset.contentId;
                documentData.contentDocumentId = contentDocumentId
                    ? contentDocumentId
                    : "";

                const pageUrl =
                    sspConstants.documentCenterHome.downloadDocumentUrl;

                const previewUrl =
                    pageUrl +
                    "?contentDocId=" +
                    contentDocumentId +
                    "&fileExtension=" +
                    extension;

                window.open(previewUrl, "_blank");
            }
        } catch (error) {
            console.error("Error in openFile" + JSON.stringify(error.message));
        }
    };

    /**
     * @function : base64ToBlob
     * @description : Convert to Blob.
     * @param {string} base64String - Js base64String.
     *  @param {string} extension - Js extension.
     */
    base64ToBlob (base64String, extension) {
        try {
            let fileBlob;
            const byteCharacters = atob(base64String);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);

            if (extension === "pdf") {
                fileBlob = new Blob([byteArray], {
                    type: "application/pdf"
                });
            } else if (
                extension === sspConstants.sspDocUpload.formatJPG ||
                extension === sspConstants.sspDocUpload.formatJPEG
            ) {
                fileBlob = new Blob([byteArray], {
                    type: "image/jpeg"
                });
            } else if (
                extension === sspConstants.sspDocUpload.formatTIF ||
                extension === "tiff"
            ) {
                fileBlob = new Blob([byteArray], {
                    type: "image/tiff"
                });
            } else if (extension === "png") {
                fileBlob = new Blob([byteArray], {
                    type: "image/png"
                });
            }
            return fileBlob;
        } catch (error) {
            console.error(
                "Error in base64ToBlob" + JSON.stringify(error.message)
            );
            return null;
        }
    }

    /**
     * @function : handleUpload
     * @description	:To handle the upload function.
     */
    handleUpload = () => {
        try {
            this.showDetailsSpinner = true;
            if (
                this.uploadedDocumentList &&
                this.uploadedDocumentList.length > 0
            ) {
                const isValidInputs = this.runValidateForAllInputs();
                if (!isValidInputs) {
                    this.hasSaveValidationError = true;
                    this.toastCondition = "negative";
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
                                this.uploadSuccessFull = true;
                                this.showFileNotUploadedTileHiddenError = false; //#385758
                            } else {
                                console.error(
                                    "Error occured in file upload " +
                                        JSON.stringify(response)
                                );
                            }
                            this.showDetailsSpinner = false;
                        })
                        .catch(function (error) {
                            console.error(
                                "Error in wizardProcessUpload =>",
                                error
                            );
                            this.showDetailsSpinner = false;
                            this.uploadSuccessFull = false;
                        });
                }
            } else {
                console.error(" No files uploaded");
                this.showDetailsSpinner = false;
                this.uploadSuccessFull = false;
            }
        } catch (error) {
            this.uploadSuccessFull = false;
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : runValidateForAllInputs
     * @description	: Verify whether required inputs are present.
     */
    runValidateForAllInputs = () => {
        try {
            if (this.selectedFormOfProof) {
                return true;
            }
            return false;
        } catch (error) {
            console.error(
                "Error in runValidateForAllInputs" +
                    JSON.stringify(error.message)
            );
            return null;
        }
    };

    /**
     * @function : getQueryParameters
     * @description	:To get the URL parameters.
     */
    getQueryParameters () {
        try {
            let params = {};
            const search = location.search.substring(1);

            if (search) {
                params = JSON.parse(
                    '{"' +
                        search.replace(/&/g, '","').replace(/=/g, '":"') +
                        '"}',
                    (key, value) =>
                        key === "" ? value : decodeURIComponent(value)
                );
            }

            return params;
        } catch (error) {
            console.error("Error in getQueryParameters =>", error);
        }
    }


    

    /**
     * @function : handleNext
     * @description	: This method is used for the next function.
     */
    handleNext = () => {
        try {
            const validateCheckBox = this.template.querySelector(
                ".ssp-identityCheckBox"
            );
            if (this.isAttest === false) {
                validateCheckBox.ErrorMessageList = [
                    this.label.sspRequiredValidationMsg
                ];
            } else {
                validateCheckBox.ErrorMessageList = [];
            }
            this.validateFormProofField();
            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedFormOfProof,
                "ssp-formOfProofInput"
      );
      // 390440
            if (this.uploadSuccessFull && this.isAttest) {
                this.showDetailsSpinner = true;
                this.updateApplicationStatusUnsubmittedHandler();
            } else {
                this.toastErrorText = this.label.sspRequiredValidationMsg;
                this.toastCondition = "negative";
                this.hasSaveValidationError = true;
            }
        } catch (error) {
      console.error("Error in handleNext =>", error);
    }
  };


  /**
   * @function : checkUploadAtNext
   * @description	: This method is used for the next function. 390440.
   */
  checkUploadAtNext = () => {
    try {
      if (this.uploadSuccessFull){
        this.handleNext();
      }
      else{
        this.showDetailsSpinner = true;
        if (this.uploadedDocumentList && this.uploadedDocumentList.length > 0) {
          const isValidInputs = this.runValidateForAllInputs();
          if (!isValidInputs) {
            this.hasSaveValidationError = true;
            this.toastCondition = "negative";
            this.showDetailsSpinner = false;
            this.handleNext();
          } else {
            this.hasSaveValidationError = false;
            const docToBeUploaded = [];
            for (let i = 0; i < this.uploadedDocumentList.length; i++) {
              docToBeUploaded.push(this.uploadedDocumentList[i].fileId);
            }
            wizardProcessUpload({
              docWrapLst: this.uploadedDocumentList,
              contentVersionLst: docToBeUploaded
            })
              .then(response => {
                if (response.bIsSuccess) {
                  this.uploadSuccessFull = true;
                  this.showFileNotUploadedTileHiddenError = false;
                  this.handleNext();
                } else {
                  console.error(
                    "Error occured in file upload " + JSON.stringify(response)
                  );
                  this.showDetailsSpinner = false;
                }
              })
              .catch(function (error) {
                console.error("Error in wizardProcessUpload =>", error);
                this.showDetailsSpinner = false;
                this.uploadSuccessFull = false;
              });
          }
        } else {
          console.error(" No files uploaded");
          this.showDetailsSpinner = false;
          this.uploadSuccessFull = false;
          this.handleNext();
        }
      }
    } catch (error) {
      console.error("Error in checkUploadAtNext =>", error);
    }
    };

    /**
     * @function : handleExitButton
     * @description	: This method is used for the exit function.
     */
    handleExitButton = () => {
        try {
            this.showDetailsSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Household_Summary__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    mode: this.parameters.mode,
                    identityDocUpload: "exit"
                }
            });
        } catch (error) {
            console.error("Error in handleExitButton =>", error);
        }
    };

    /**
     * @function : navigateToHHSummary
     * @description	: This method is used to navigate to house hold summary screen.
     */
    navigateToHHSummary () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Household_Summary__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    mode: this.parameters.mode,
                    identityDocUpload: "success",
                    individualId: this.individualId
                }
            });
        } catch (error) {
            console.error("Error in navigateToHHSummary =>", error);
        }
    }
    navigateToRepresentative (){
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "authRepsAssisters__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    mode: "Intake"
                }
            });
        } catch (error) {
            console.error("Error in navigateToRepresentative", error);
        }
    }
    navigateToNextPageUpdate = (navigateToRepsHome, isPartialMatch, isAccessAvailable) => {
        if (navigateToRepsHome) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "assister_access_request__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    individualId: this.individualId                    
                }
            });
        }
        else {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "reps_asisters_agents_next_steps__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    noCaseMatch: isAccessAvailable,
                    authRequestPartialMatch: isPartialMatch
                }
            });
        }
    }
    
    updateApplicationStatusUnsubmittedHandler () {
        updateApplicationStatusUnsubmitted({
            applicationId: this.parameters.applicationId,
            memberId: this.parameters.memberId,
            sPage: "documentUpload"
        })
            .then(result => {
                if (!result.bIsSuccess) {
                    console.error(
                        "updateApplicationStatusUnsubmitted Failure" +
                            JSON.stringify(result)
                    );
                } 
                this.navigateToHHSummary(); //Added as part of Defect - 381803
            })
            .catch(error => {
                console.error(
                    "updateApplicationStatusUnsubmitted Failed" +
                        JSON.stringify(error)
                );
            });
    }
}