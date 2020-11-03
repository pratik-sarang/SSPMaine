/*
 * Component Name: SspDocumentCenterDocUpload.
 * Author: Aniket Shinde,Kyathi
 * Description: This screen is used for Document Wizard Upload File.
 * Date: 4/10/2020.
 */
import { LightningElement, api, track } from "lwc";
import deleteDocuments from "@salesforce/apex/SSP_DocumentCenterCtrl.deleteDocuments";
import wizardProcessUpload from "@salesforce/apex/SSP_DocumentCenterCtrl.wizardProcessUpload";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspUpload from "@salesforce/label/c.SSP_Upload";
import sspUploadAndContinue from "@salesforce/label/c.SSP_UploadAndContinue";
import sspSkip from "@salesforce/label/c.SSP_Skip";
import getFormOfProofsWizard from "@salesforce/apex/SSP_DocumentCenterCtrl.getFormOfProofsWizard";
import sspConstants from "c/sspConstants";
import sspSkipUploadTitle from "@salesforce/label/c.SSP_SkipUploadTitle";
import sspUploadContinueTitle from "@salesforce/label/c.SSP_UploadContinueTitle";
import sspProofType from "@salesforce/label/c.SSP_ProofType";
import { formatLabels } from "c/sspUtility";

export default class SspDocumentCenterDocUpload extends LightningElement {
    @api currentRFI;
    @track showDetailsSpinner = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track toastCondition = "positive"; // For Error Toast ,change this to negative
    @track selectedFormOfProof;
    @track uploadedDocumentList = [];
    @track formOfProofOptions = [];
    @track selectedTypeOfProofLabel;
    @track selectedIndName;
    @track selectedFormOfProofName;
    @track currentRFIIdentifier;
    @track selectedCaseNumber;
    @track updatedOptions;
    @track sspUploadType;
    @track taskCode;
    @track sDueDate;
    @track templateMap = "";
    
    label = {
        toastErrorText,
        sspSummaryRecordValidator,
        sspUpload,
        sspUploadAndContinue,
        sspSkip,
        sspSkipUploadTitle,
        sspUploadContinueTitle,
        sspProofType
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
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in hideToast of SspDocumentCenterDocUpload" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : connectedCallback
     * @description : Used to set variables on page load.
     */
    connectedCallback () {
        try {
            this.selectedIndName = this.currentRFI.name;
            this.selectedFormOfProofName = this.currentRFI.RFI;
            this.currentRFIIdentifier = this.currentRFI.RFIIdentifier;
            this.selectedTypeOfProof = this.currentRFI.RFICode;
            this.selectedIndId = this.currentRFI.individualId;
            this.selectedCaseNumber = this.currentRFI.CaseNo;
            this.sspUploadType = formatLabels(this.label.sspProofType, [
                this.selectedIndName,
                this.selectedFormOfProofName
            ]);
            this.sDueDate = this.currentRFI.sDueDate;
            this.loadProofOptions();
        } catch (error) {
            console.error(
                "Error in connectedCallback of sspDocumentCenterDocUpload" +
                    JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : hideToast
     * @description	: Load options
     */
    loadProofOptions = () => {
        try {
            getFormOfProofsWizard({
                typeOfProofCode: this.currentRFI.RFICode
            })
                .then(response => {
                    if (response.bIsSuccess) {
                        this.formOfProofOptions =
                            response.mapResponse.formOfProofs;
                        const updatedOptions = this.formOfProofOptions.filter(
                            item => {
                                item.title = item.label;
                                if (item.label.length > 35) {
                                    item.label =
                                        item.label.substring(0, 35) + "...";
                                }
                                return item;
                            }
                        );
                        this.templateMap = response.mapResponse.templateMap;
                        this.updatedOptions = updatedOptions;
                        if (
                            response.mapResponse.taskCode &&
                            response.mapResponse.taskCode !== ""
                        ) {
                            this.taskCode = response.mapResponse.taskCode;
                        } else {
                            this.taskCode = "";
                        }
                    }
                    this.showSpinner = false;
                })
                .catch(function (error) {
                    console.error(error);
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error on loadProofOptions of sspDocumentCenterDocUpload" +
                    JSON.stringify(error.message)
            );
            this.showSpinner = false;
        }
    };

    /*
     * @function : formOfProofOnChange
     * @description	: uploaded single file
     */
    formOfProofOnChange = evt => {
        try {
            this.selectedFormOfProof = evt.detail;
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : singleFileUploaded
     * @description	: uploaded single file
     * @param {event} evt - Gets current value
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
     * @function : handleUploadAndContinue
     * @description	: Upload selected documents
     */
    handleUploadAndContinue () {
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
                               
                                const evt = new CustomEvent(
                                    sspConstants.events.fileUploadForRFI,
                                    {
                                        detail: this.uploadedDocumentList,
                                        composed: true,
                                        bubbles: true
                                    }
                                );
                                this.dispatchEvent(evt);
                                this.navigateNextScreen();
                            } else {
                                console.error(
                                    "Error occured in file upload " +
                                        JSON.stringify(response)
                                );
                            }
                            this.showDetailsSpinner = false;
                        })
                        .catch(function (error) {
                            console.error(error);
                            this.showDetailsSpinner = false;
                        });
                }
            } else {
                console.error(" No files uploaded");
                this.showDetailsSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in uploadDocuments" + JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : skipAndNavigate
     * @description	: Redirect to next screen
     */
    skipAndNavigate () {
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
                            this.navigateNextScreen();
                            this.showDetailsSpinner = false;
                        } else {
                            console.error(
                                "Error occured in file upload " +
                                    JSON.stringify(response)
                            );
                        }
                        this.showDetailsSpinner = false;
                    })
                    .catch(function (error) {
                        console.error(error);
                    });
            } else {
                this.navigateNextScreen();
                this.showDetailsSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in skipAndNavigate" + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    }

    /*
     * @function : navigateNextScreen
     * @description	: Redirect to next screen
     */
    navigateNextScreen () {
        try {
            const event = new CustomEvent(sspConstants.events.showNextRFI, {
                detail: "Show Next RFI"
            });
            this.dispatchEvent(event);
        } catch (error) {
            console.error("Error in navigateNextScreen " + error);
        }
    }

    /*
     * @function : runValidateForAllInputs
     * @description	: Verify whether required inputs are present
     * @param {event} evt - Gets current value
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
}