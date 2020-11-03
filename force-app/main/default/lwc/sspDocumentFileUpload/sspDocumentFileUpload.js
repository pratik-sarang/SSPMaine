/* eslint-disable no-new */
/*
 * Component Name: SspDocumentFileUpload.
 * Author: Kyathi Kanumuri,Aniket Shinde
 * Description: This screen is used for Document File Upload.
 * Date: 4/22/2020.
 */
import { LightningElement, track, api } from "lwc";
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
import sspDownloadStatement from "@salesforce/label/c.SSP_DownloadStatement";
import sspWrittenStatementTemplate from "@salesforce/label/c.SSP_WrittenStatementTemplate";
import sspWrittenStatementTemplateTitle from "@salesforce/label/c.SSP_WrittenStatementTemplateTitle";
import sspAddAdditionalDocument from "@salesforce/label/c.SSP_AddAdditionalDocument";
import sspRemoveDocumentTitle from "@salesforce/label/c.SSP_RemoveDocumentTitle";
import sspRemoveDocumentModalHeader from "@salesforce/label/c.SSP_RemoveDocumentModalHeader";
import sspRemoveDocumentModalContent from "@salesforce/label/c.SSP_RemoveDocumentModalContent";
import deleteDocuments from "@salesforce/apex/SSP_DocumentCenterCtrl.deleteDocuments";
import saveChunk from "@salesforce/apex/SSP_DocumentCenterCtrl.saveChunk";
import writtenStatement from "@salesforce/resourceUrl/WrittenStatement";
import writtenStatementSpanish from "@salesforce/resourceUrl/DeclarationEscrita";
import sspPAFS76 from "@salesforce/resourceUrl/PAFS76";
import sspPAFS76SPA from "@salesforce/resourceUrl/PAFS76SPA";
import sspPAFS700 from "@salesforce/resourceUrl/PAFS700";
import sspPAFS700SPA from "@salesforce/resourceUrl/PAFS700SPA";
import sspPAFS702 from "@salesforce/resourceUrl/PAFS702";
import sspPAFS702SPA from "@salesforce/resourceUrl/PAFS702SPA";
import ImageCompressor from "@salesforce/resourceUrl/ImageCompressor";
import { loadScript } from "lightning/platformResourceLoader";
import validatorMsgFileSize from "@salesforce/label/c.SSP_FileSizeValidationMessage";
import errorUploadingMsg from "@salesforce/label/c.SSP_Error_Uploading";
import fileUploadedSuccessMsg from "@salesforce/label/c.SSP_FileUploaded";
import sspRemoveDocumentButtonTitle from "@salesforce/label/c.SSP_RemoveDocumentModalTitle";
import cancelButtonTitle from "@salesforce/label/c.SSP_CancelRemoveDocumentTitle";
import sspSelectDocumentTitle from "@salesforce/label/c.SSP_SelectDocumentTitle";
import sspSelectDocumentToUpload from "@salesforce/label/c.SSP_SelectDocumentToUpload";
import sspConstants from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import sspRequiredValidationMsg from "@salesforce/label/c.SSP_RequiredErrorMessage";
import { NavigationMixin } from "lightning/navigation";
import getConfigValues from "@salesforce/apex/SSP_DocumentCenterCtrl.getConfigValues";
import sspFileSizeError from "@salesforce/label/c.SSP_FileSizeError";
import sspFileTypeError from "@salesforce/label/c.SSP_FileTypeError";
import sspCollateralForm from "@salesforce/label/c.SSP_CollateralForm";
import sspPAFSFormTwo from "@salesforce/label/c.SSP_PAFSFormTwo";
import sspPAFSFormThree from "@salesforce/label/c.SSP_PAFSFormThree";
import sspPAFSFormOneLabelOne from "@salesforce/label/c.SSP_PAFSFormOneLabelOne";
import sspPAFSFormOneLabelTwo from "@salesforce/label/c.SSP_PAFSFormOneLabelTwo";
import sspPAFSFormTwoLabelOne from "@salesforce/label/c.SSP_PAFSFormTwoLabelOne";
import sspPAFSFormTwoLabelTwo from "@salesforce/label/c.SSP_PAFSFormTwoLabelTwo";
import sspFormThreeLabelOne from "@salesforce/label/c.SSP_FormThreeLabelOne";
import sspFormThreeLabelTwo from "@salesforce/label/c.SSP_FormThreeLabelTwo";
import sspHearingDocumentSelectName from "@salesforce/label/c.SSP_HearingDocumentSelectName";
import sspHearingDocumentSelectTitle from "@salesforce/label/c.SSP_HearingDocumentSelectTitle";
import sspHearingDocumentAddButton from "@salesforce/label/c.SSP_HearingDocumentAddButton";
import sspHearingDocumentAddTitle from "@salesforce/label/c.SSP_HearingDocumentAddTitle";
import getPickListValues from "@salesforce/apex/SSP_DocumentCenterCtrl.getPickListValues";
import sspHearingDocumentContentThree from "@salesforce/label/c.SSP_HearingDoucmentContentThree";
import sspHearingUploadHelp from "@salesforce/label/c.SSP_HearingUploadHelp";
import sspTemplateInstruction from "@salesforce/label/c.SSP_TemplateInstruction";
import sspUtility from "c/sspUtility";

export default class SspDocumentFileUpload extends NavigationMixin(
    LightningElement
) {
    @api hearingId;
    @api isHearing = false;
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
    @api templateMap;
    @api hearingRequestNumber;
    @track restrictAddDocument = true;
    @track fileName = "";
    @track filesUploaded;
    @track fileName;
    @track showError = false;
    @track uploadedDocumentList = [];
    @track showSpinner = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track fileUploadDisabled = false;
    @track toastCondition = "positive"; // For Error Toast ,change this to negative
    @track showSpinner;
    @track showDetailsSpinner;
    @track selectedProofName;
    @track sspSelectDocumentToUploadTitle;
    @track errorFileUploadErrorAtField;
    @track showUploadError = false;
    @track toastAdditionalInfo = "";
    @track showFileNotUploadedError = false;
    @track showFileNotUploadedTileHiddenError = false;
    @track showFormOfProofError = false;
    @track showTargetAnchorTag = false;
    @track PAFS76DocUrl = sspPAFS76;
    @track PAFS700DocUrl = sspPAFS700;
    @track PAFS702DocUrl = sspPAFS702;
    @track hearingPickListValues = [];
    @track selectedHearingDocumentType;
    @track selectedHearingDocumentLabel;
    @track isDisableHearingUploadInput = false;
    @track templateInstruction = "This must come from Custom Label";
    @track templateExampleLabel;
    @track templateExampleValue;
    @track templateExampleUrl;
    //default if custom setting absent
    convertSize = sspConstants.sspDocUpload.convertSize;
    quality = sspConstants.sspDocUpload.quality;
    benefindLabel = ""; //Added for Tracker Defect-76
    label = {
        sspFormThreeLabelOne,
        sspFormThreeLabelTwo,
        sspPAFSFormTwoLabelOne,
        sspPAFSFormTwoLabelTwo,
        sspPAFSFormOneLabelTwo,
        sspPAFSFormOneLabelOne,
        sspPAFSFormThree,
        sspPAFSFormTwo,
        sspCollateralForm,
        sspRemoveDocumentModalHeader,
        sspRemoveDocumentModalContent,
        sspDownloadStatement,
        sspWrittenStatementTemplate,
        sspWrittenStatementTemplateTitle,
        sspAddAdditionalDocument,
        sspRemoveDocumentTitle,
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
        validatorMsgFileSize,
        errorUploadingMsg,
        fileUploadedSuccessMsg,
        sspRequiredValidationMsg,
        sspRemoveDocumentButtonTitle,
        cancelButtonTitle,
        sspSelectDocumentTitle,
        sspSelectDocumentToUpload,
        sspFileSizeError,
        sspFileTypeError,
        sspHearingDocumentSelectName,
        sspHearingDocumentSelectTitle,
        sspHearingDocumentAddButton,
        sspHearingDocumentAddTitle,
        sspHearingDocumentContentThree,
        sspHearingUploadHelp,
        sspTemplateInstruction
    };
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
     * @function : calculateDisableHearingFileInput.
     * @description : input disable.
     */
    calculateDisableHearingFileInput = () => {
        try {
            return !this.selectedHearingDocumentType;
        } catch (error) {
            console.error(
                "Error in calculateDisableHearingFileInput" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    };

    /**
     * @function : disableHearingDocumentUpload.
     * @description : Getter setters for disabling hearing document upload.
     */
    get disableHearingDocumentUpload () {
        try {
            return this.calculateDisableHearingFileInput ();
        } catch (error) {
            console.error(
                "Error in disableHearingDocumentUpload" + JSON.stringify(error.message)
            );
            return false;
        }
    }

    /**
     * @function : statusClassHearingDocumentUpload.
     * @description : Getter setters for Status class name.
     */
    get statusClassHearingDocumentUpload () {
        const doDisable = this.calculateDisableHearingFileInput();
        try {
            return doDisable
                ? "ssp-hearingUploadInput ssp-fileUploadDisabled"
                : "ssp-hearingUploadInput ssp-fileUploadEnabled";
        } catch (error) {
            console.error(
                "Error in statusClassHearingDocumentUpload" +
                    JSON.stringify(error.message)
            );
            return "ssp-hearingUploadInput";
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

    get isPAFS76 () {
        try {
            if (
                this.selectedTypeOfProof &&
                this.selectedTypeOfProof === "V562" &&
                this.selectedFormOfProof &&
                this.selectedFormOfProof === "PF"
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error in isPAFS76" + JSON.stringify(error.message));
            return false;
        }
    }

    get isPAFS700 () {
        try {
            if (
                this.selectedTypeOfProof &&
                this.selectedTypeOfProof === "V581" && 
                this.selectedFormOfProof &&
                this.selectedFormOfProof === "PA700"
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error in isPAFS700" + JSON.stringify(error.message));
            return false;
        }
    }

    get isPAFS702 () {
        try {
            if (
                this.selectedTypeOfProof &&
                this.selectedTypeOfProof === "V548" &&
                this.selectedFormOfProof &&
                this.selectedFormOfProof === "PA702"
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error in isPAFS702" + JSON.stringify(error.message));
            return false;
        }
    }

    get isShowTemplate () {
        try {
            if (
                this.templateExampleLabel 
            ) {
                return true;
            }
            return false;
        } catch (error) {
            console.error(
                "Error in isShowTemplate" +
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
            this.getPickListValuesHandler();
            const browserIExplorer =
                window.navigator && window.navigator.msSaveOrOpenBlob
                    ? true
                    : false;
            const browserIOS =
                /iPad|iPhone|iPod/.test(navigator.userAgent) &&
                !window.MSStream;
            if (browserIExplorer || browserIOS) {
                this.showTargetAnchorTag = true;
            }
            this.showDetailsSpinner = true;
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
                        if (this.language !== "en_US") {
                            this.PAFS76DocUrl = sspPAFS76SPA;
                            this.PAFS700DocUrl = sspPAFS700SPA;
                            this.PAFS702DocUrl = sspPAFS702SPA;
                        }
                        //Start - Added for Tracker Defect-76
                        if (response.mapResponse.benefind) {
                            this.benefindLabel = response.mapResponse.benefind;
                        }
                        //End - Added for Tracker Defect-76
                    } else {
                        console.error(JSON.stringify("error in loadScript"));
                        this.showDetailsSpinner = false;
                    }
                })
                .catch(function (error) {
                    console.error(error);
                    this.showDetailsSpinner = false;
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
                    JSON.stringify(this.formOfProofOptions)
                );
                const result = selectedPicklistValues.find(
                    obj => obj.value === this.selectedFormOfProof
                );
                this.selectedProofName = result.title;
            }

            if (this.templateMap[this.selectedFormOfProof]) {
                const templateExample = this.templateMap[this.selectedFormOfProof];
                this.templateExampleLabel = templateExample.label;
                this.templateExampleValue = templateExample.value;
                this.templateExampleUrl = templateExample.resourceUrl;
            }
            else {
                this.templateExampleLabel = "";
                this.templateExampleValue = "";
                this.templateExampleUrl = "";
            }
            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedFormOfProof,
                "ssp-formOfProofInput"
            );
            const evt = new CustomEvent(sspConstants.events.formProofChange, {
                detail: this.selectedFormOfProof
            });
            this.dispatchEvent(evt);
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
                        /*eslint no-new: "error"*/
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
                    // Fix for 388760 - start
                    else{
                        console.error(
                            "Error in uploadInChunk" + JSON.stringify(response)
                        );
                        this.showDetailsSpinner = false;
                    }
                    // Fix for 388760 - end
                })
                .catch(function (error) {
                    console.error(error);
                    // Fix for 388760
                    this.showDetailsSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error in uploadInChunk" + JSON.stringify(error.message)
            );
            // Fix for 388760
            this.showDetailsSpinner = false;
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
            uploadedFileDetails.hearingRequestNumber = this.hearingRequestNumber;
            uploadedFileDetails.hearingDocumentType = this.selectedHearingDocumentType;
            uploadedFileDetails.hearingDocumentDescription = this.selectedHearingDocumentLabel;
            uploadedFileDetails.hearingId = this.hearingId;
            this.uploadedDocumentList.push(uploadedFileDetails);

            //success toast message
            if (!this.isHearing) {
                this.sspReceivedProofText = formatLabels(
                    this.label.sspReceivedProof,
                    [this.selectedIndName, this.selectedFormOfProofName]
                );
            }
            if (this.isHearing) {
                this.sspReceivedProofText = formatLabels(
                    this.label.sspReceivedProof,
                    [this.selectedIndName, this.selectedHearingDocumentLabel]
                );
            }

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

            // File uploaded toast.
            this.showDetailsSpinner = false;
        } catch (error) {
            console.error(
                "Error in postUploadProcessing" + JSON.stringify(error.message)
            );
        }
    }
    /*
     * @function : applyChanges
     * @description	:apply changes
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
    @api
    validateFormProofField () {
        this.validateInputRequired(
            this.label.sspRequiredValidationMsg,
            this.selectedFormOfProof,
            "ssp-formOfProofInput"
        );
        if (this.uploadedDocumentList && this.uploadedDocumentList.length > 0) {
            this.showFileNotUploadedError = false;
        } else {
            if(this.handleGeneric === "true"){
                this.showFileNotUploadedError = true;
            }
            if (!this.restrictAddDocument) {
                this.showFileNotUploadedTileHiddenError = true;
            } else {
                this.showFileNotUploadedTileHiddenError = false;
            }
        }
    }
    /*
     * @function : validateHearingDocumentTypeField
     * @description	:To validate Hearing Document Field
     */
    @api
    validateHearingDocumentTypeField () {
        this.validateInputRequired (
            this.label.sspRequiredValidationMsg,
            this.selectedHearingDocumentType,
            "ssp-formOfProofInput"
        );
        if (this.uploadedDocumentList && this.uploadedDocumentList.length > 0) {
            this.showFileNotUploadedError = false;
        } else {
            this.showFileNotUploadedError = true;
            if (!this.restrictAddDocument) {
                this.showFileNotUploadedTileHiddenError = true;
            } else {
                this.showFileNotUploadedTileHiddenError = false;
            }
        }
    }
    /**
    * @function - renderedCallback
    * @description - This method is used to called whenever there is track variable changing.

    */
   renderedCallback () {
       if(this.showFormOfProofError){
        this.validateInputRequired(
            this.label.sspRequiredValidationMsg,
            this.selectedFormOfProof,
            "ssp-formOfProofInput"
        );
        this.showFormOfProofError = false;
       }
   }
    /*
     * @function : enableSectionDocUpload
     * @description	:Function to enable Document Upload
     */
    enableSectionDocUpload () {
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
    }

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
                        this.showDetailsSpinner = false;
                        if(this.handleGeneric === "true"){
                            if (this.uploadedDocumentList && this.uploadedDocumentList.length > 0) {
                                this.restrictAddDocument = false;
                            }
                            else if(!this.restrictAddDocument){
                                this.selectedFormOfProof = "";
                                this.restrictAddDocument = true;
                            }
                        }
                    } else {
                        this.showDetailsSpinner = false;
                    }
                })
                .catch(function (error) {
                    console.error(error);
                    this.showDetailsSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error in enableSectionDocUpload" +
                    JSON.stringify(error.message)
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
     * @function : openPDF
     * @description : Download and open document in new tab.
     * @param {object} event - Js event.
     */
    openPDF = event => {
        const formName = event.target.getAttribute("data-form");
        const downloadElement = document.createElement("a");
        downloadElement.setAttribute("download", "download");
        if (formName === "PAFS76") {
            if (this.language === "en_US") {
                window.open(sspPAFS76, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76;
            } else {
                window.open(sspPAFS76SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76SPA;
            }
            downloadElement.download = "PAFS76.pdf";
        }
        if (formName === "PAFS700") {
            if (this.language === "en_US") {
                window.open(sspPAFS700, "_blank");
                downloadElement.href = window.location.origin + sspPAFS700;
            } else {
                window.open(sspPAFS700SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS700SPA;
            }
            downloadElement.download = "PAFS700.pdf";
        }
        if (formName === "PAFS702") {
            if (this.language === "en_US") {
                window.open(sspPAFS702, "_blank");
                downloadElement.href = window.location.origin + sspPAFS702;
            } else {
                window.open(sspPAFS702SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS702SPA;
            }
            downloadElement.download = "PAFS702.pdf";
        }
        downloadElement.click();
    };


    /**
     * @function : openTemplateDocument
     * @description : Download and open document in new tab.
     */
    openTemplateDocument () {
        let urlToOpen;
        const downloadElement = document.createElement("a");
        downloadElement.setAttribute("download", "download");
            if (this.language === "en_US") {
            //Start- Added only benefindLabel condition for Tracker Defect-76
            if (this.benefindLabel !== "") {
                urlToOpen = "/"+this.benefindLabel+"/resource/" + this.templateExampleUrl.replace("/","/en/");
            } else {
                urlToOpen = "/resource/" + this.templateExampleUrl.replace("/","/en/");
            }
            //End- Added only benefindLabel condition for Tracker Defect-76
                window.open(urlToOpen, "_blank");
            downloadElement.href = window.location.origin + urlToOpen;
            } else {
            //Start- Added only benefindLabel condition for Tracker Defect-76
            if (this.benefindLabel !== "") { 
                urlToOpen = "/"+this.benefindLabel+"/resource/" + this.templateExampleUrl.replace("/","/es/");
            } else {
                urlToOpen = "/resource/" + this.templateExampleUrl.replace("/","/es/");
            }
            //End- Added only benefindLabel condition for Tracker Defect-76
                window.open(urlToOpen, "_blank");
                downloadElement.href = window.location.origin + urlToOpen;
            }
            downloadElement.download = this.templateExampleValue+".pdf";
        downloadElement.click();
    }

    /**
     * @function : openWrittenStatement
     * @description : Download and open document in new tab.
     * @param {object} event - Js event.
     */
    openWrittenStatement = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                const pageUrl =
                    sspConstants.documentCenterHome.downloadDocumentUrl;

                const previewUrl = pageUrl + "?contentDoc=WrittenStatement";

                window.open(previewUrl, "_blank");
                // For other browsers Download Document
                const downloadElement = document.createElement("a");
                if (this.language === sspConstants.sspDocUpload.language){
                    downloadElement.href =
                        window.location.origin + writtenStatement;
                }
                else{
                    downloadElement.href =
                        window.location.origin + writtenStatementSpanish;
                }
                downloadElement.setAttribute("download", "download");
                downloadElement.download = "WrittenStatement.pdf";
                const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
                if(!browserIOS){
                    downloadElement.click();
                }
            }
        } catch (error) {
            console.error(
                "Error in openWrittenStatement" + JSON.stringify(error.message)
            );
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
                fileBlob = new Blob([byteArray], { type: "application/pdf" });
            } else if (
                extension === sspConstants.sspDocUpload.formatJPG ||
                extension === sspConstants.sspDocUpload.formatJPEG
            ) {
                fileBlob = new Blob([byteArray], { type: "image/jpeg" });
            } else if (
                extension === sspConstants.sspDocUpload.formatTIF ||
                extension === "tiff"
            ) {
                fileBlob = new Blob([byteArray], { type: "image/tiff" });
            } else if (extension === "png") {
                fileBlob = new Blob([byteArray], { type: "image/png" });
            }
            return fileBlob;
        } catch (error) {
            console.error(
                "Error in base64ToBlob" + JSON.stringify(error.message)
            );
            return null;
        }
    }
    getPickListValuesHandler () {
        getPickListValues({
            objectName: "DocumentDetail__c",
            fieldName: "Hearing_Document_Type__c",
            firstValue: null
        })
            .then(result => {
                if (result.bIsSuccess) {
                    const pickListData = result.mapResponse;
                    if (pickListData.hasOwnProperty("options")) {
                        const hodList = [];
                        const retrievedHOD = pickListData.options;
                        Object.keys(retrievedHOD).forEach(key => {
                            hodList.push({
                                label: retrievedHOD[key],
                                value: key
                            });
                        });

                        this.hearingPickListValues = hodList;
                        if (
                            sspUtility.isUndefinedOrNull(this.selectedIndName)
                        ) {
                            this.selectedIndName =
                                result.mapResponse.loginUserName;
                        }
                    }
                }
            })
            .catch(error => {
                console.error(
                    "Error in getPickListValuesHandler" + JSON.stringify(error.message)
                );
            });
    }

    /*
     * @function : onChangeFormOfProof
     * @description	: Method on change form of proof
     * @param {event} evt - Gets current value.
     */
    onChangeHearingDocumentType = event => {
        try {
            this.selectedHearingDocumentType = event.target.value;
            this.isDisableHearingUploadInput = true;
            if (event.target.value !== "") {
                const selectedPicklistValues = JSON.parse(
                    JSON.stringify(this.hearingPickListValues)
                );
                const result = selectedPicklistValues.find(
                    obj => obj.value === this.selectedHearingDocumentType
                );
                this.selectedHearingDocumentLabel = result.label;
            }

            this.validateInputRequired(
                this.label.sspRequiredValidationMsg,
                this.selectedHearingDocumentType,
                "ssp-formOfProofInput"
            );
            const evt = new CustomEvent(
                sspConstants.events.hearingDocumentType,
                {
                    detail: this.selectedHearingDocumentType
                }
            );
            this.dispatchEvent(evt);
        } catch (error) {
            console.error(
                "Error in onChangeTypeOfProof" + JSON.stringify(error.message)
            );
        }
    };
}