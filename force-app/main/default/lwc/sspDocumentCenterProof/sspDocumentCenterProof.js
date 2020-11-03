/*
 * Component Name: SspDocumentCenterProof.
 * Author: Kyathi Kanumuri,Aniket
 * Description: This screen is container for Document Center Proof Screen.
 * Date: 4/12/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspProof from "@salesforce/label/c.SSP_Proof";
import sspProofRequests from "@salesforce/label/c.SSP_ProofRequests";
import sspProofType from "@salesforce/label/c.SSP_ProofType";
import sspProofForms from "@salesforce/label/c.SSP_ProofForms";
import sspAcceptedProof from "@salesforce/label/c.SSP_AcceptedProof";
import sspHaveProofQuestion from "@salesforce/label/c.SSP_HaveProofQuestion";
import sspHaveProofQuestion2 from "@salesforce/label/c.SSP_HaveProofQuestion2";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspIncomeVerification from "@salesforce/label/c.SSP_IncomeVerification";
import sspDocumentExamples from "@salesforce/label/c.SSP_DocumentExamples";
import { getYesNoOptions, formatLabels } from "c/sspUtility";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspConstants,{ events } from "c/sspConstants";
import sspRequired from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspViewProofTitle from "@salesforce/label/c.SSP_ViewProofTitle";
import sspExitDocumentWizard from "@salesforce/label/c.SSP_ExitDocumentWizard";
import sspGoToNextScreen from "@salesforce/label/c.SSP_GoToNextScreen";
import sspCollateralForm from "@salesforce/label/c.SSP_CollateralForm";
import sspPAFSFormTwo from "@salesforce/label/c.SSP_PAFSFormTwo";
import sspPAFSFormThree from "@salesforce/label/c.SSP_PAFSFormThree";
import sspPAFSFormOneLabelOne from "@salesforce/label/c.SSP_PAFSFormOneLabelOne";
import sspPAFSFormOneLabelTwo from "@salesforce/label/c.SSP_PAFSFormOneLabelTwo";
import sspPAFSFormTwoLabelOne from "@salesforce/label/c.SSP_PAFSFormTwoLabelOne";
import sspPAFSFormTwoLabelTwo from "@salesforce/label/c.SSP_PAFSFormTwoLabelTwo";
import sspFormThreeLabelOne from "@salesforce/label/c.SSP_FormThreeLabelOne";
import sspFormThreeLabelTwo from "@salesforce/label/c.SSP_FormThreeLabelTwo";
import getFormOfProofsWizard from "@salesforce/apex/SSP_DocumentCenterCtrl.getFormOfProofsWizard";
import getCurrentLoggedInUserLang from "@salesforce/apex/SSP_CollateralContact.getCurrentLoggedInUserLang";

import sspPAFS76 from "@salesforce/resourceUrl/PAFS76";
import sspPAFS76SPA from "@salesforce/resourceUrl/PAFS76SPA";
import sspPAFS700 from "@salesforce/resourceUrl/PAFS700";
import sspPAFS700SPA from "@salesforce/resourceUrl/PAFS700SPA";
import sspPAFS702 from "@salesforce/resourceUrl/PAFS702";
import sspPAFS702SPA from "@salesforce/resourceUrl/PAFS702SPA";

export default class SspDocumentCenterProof extends LightningElement {
    @api currentRFI;
    @api totalRFICount;
    @api currentRFIIndex;
    @track yesNoOptions = getYesNoOptions();
    @track showVerificationPopup = false;
    @track reference = this;
    @track listOfRFI;
    @track selectedNav;
    @track openExitWizardModel = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track proofOptions = [];
    @track recommendedProofOptions = [];
    @track showSpinner = false;
    @track sspHaveProofQuestion;
    @track sspProofType;
    @track sspProofRequests;
    @track nextButtonDisabled = true;
    @track isToShowRecommendedProofBlock = false;
    @track isViewAcceptedLink = true;
    @track isPAFS76 = false;
    @track isPAFS700 = false;
    @track isPAFS702 = false;
    @track language = "en_US";
    @track showTargetAnchorTag = false;
    @track PAFS76DocUrl = sspPAFS76;
    @track PAFS700DocUrl = sspPAFS700;
    @track PAFS702DocUrl = sspPAFS702;
    label = {
        sspCollateralForm,
        sspPAFSFormTwo,
        sspPAFSFormThree,
        sspPAFSFormOneLabelOne,
        sspPAFSFormOneLabelTwo,
        sspPAFSFormTwoLabelOne,
        sspPAFSFormTwoLabelTwo,
        sspFormThreeLabelOne,
        sspFormThreeLabelTwo,
        sspProof,
        sspProofRequests,
        sspProofType,
        sspProofForms,
        sspAcceptedProof,
        sspHaveProofQuestion,
        sspExitButton,
        sspNext,
        sspIncomeVerification,
        sspDocumentExamples,
        sspSummaryRecordValidator,
        sspViewProofTitle,
        sspExitDocumentWizard,
        sspGoToNextScreen,
        sspHaveProofQuestion2
    };

    /**
    * @function : openPDF
    * @description : Download and open document in new tab.
    * @param {object} event - Js event.
   */
    openPDF = (event) => {
        const formName = event.target.getAttribute("data-form");
        const downloadElement = document.createElement("a");
        downloadElement.setAttribute("download", "download");
        if (formName === "PAFS76") {
            if (this.language === "en_US") {
                window.open(sspPAFS76, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76;
            }
            else {
                window.open(sspPAFS76SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS76SPA;
            }
            downloadElement.download = "PAFS76.pdf";
        }
        if (formName === "PAFS700") {
            if (this.language === "en_US") {
                window.open(sspPAFS700, "_blank");
                downloadElement.href = window.location.origin + sspPAFS700;
            }
            else {
                window.open(sspPAFS700SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS700SPA;
            }
            downloadElement.download = "PAFS700.pdf";
        }
        if (formName === "PAFS702") {
            if (this.language === "en_US") {
                window.open(sspPAFS702, "_blank");
                downloadElement.href = window.location.origin + sspPAFS702;
            }
            else {
                window.open(sspPAFS702SPA, "_blank");
                downloadElement.href = window.location.origin + sspPAFS702SPA;
            }
            downloadElement.download = "PAFS702.pdf";
        }
        downloadElement.click();
    }

    /**
     * @function : connectedCallback
     * @description : Used to set variables on page load.
     */
    connectedCallback () {
        getCurrentLoggedInUserLang()
            .then(result => {
                this.language=result;
                if (this.language !== "en_US") {
                    this.PAFS76DocUrl = sspPAFS76SPA;
                    this.PAFS700DocUrl = sspPAFS700SPA;
                    this.PAFS702DocUrl = sspPAFS702SPA;
                }
            })
            .catch(error => {
                this.error = error;
                console.error("Error"  + JSON.stringify(error));
            });
        try {
            const browserIExplorer = window.navigator && window.navigator.msSaveOrOpenBlob ? true : false;
            const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
            if (browserIExplorer || browserIOS) {
                this.showTargetAnchorTag = true;
            }
            this.showSpinner = true;
            this.initProofScreen();
            this.loadProofOptions();
        } catch (error) {
            console.error(
                "Error in connectedCallback of SspDocumentCenterProof" +
                    JSON.stringify(error.message)
            );
        }
    }
    /*
     * @function : applyChanges
     * @description	: getter to apply changes with Proof Data
     */
    @api
    applyChanges () {
        try {
            this.showSpinner = true;
            this.initProofScreen();
            this.loadProofOptions();
        } catch (error) {
            console.error(
                "Error in applyChanges of SspDocumentCenterProof" +
                    JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : initProofScreen
     * @description	: Init Proof Data
     */
    initProofScreen () {
        try {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            this.sspProofRequests = formatLabels(this.label.sspProofRequests, [
                this.showCurrentRFICount,
                this.totalRFICount
            ]);
            this.sspProofType = formatLabels(this.label.sspProofType, [
                this.currentRFI.name,
                this.currentRFI.RFI
            ]);
            if (
                this.currentRFI.recordIdentifier &&
                this.currentRFI.recordIdentifier !== this.currentRFI.name
            ) {
                this.sspHaveProofQuestion = formatLabels(
                    this.label.sspHaveProofQuestion,
                    [
                        this.currentRFI.name,
                        this.currentRFI.RFI,
                        this.currentRFI.recordIdentifier
                    ]
                );
            }
            else {
                this.sspHaveProofQuestion = formatLabels(
                    this.label.sspHaveProofQuestion2,
                    [
                        this.currentRFI.name,
                        this.currentRFI.RFI
                    ]
                );
            }
           
        } catch (error) {
            console.error(
                "Error on initProofScreen" +
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
                        if (response.mapResponse.verificationDocumentsPopupPermission === sspConstants.permission.notAccessible) {
                            this.isViewAcceptedLink = false;
                        } else {
                            this.isViewAcceptedLink = true;
                        }
                        this.proofOptions = response.mapResponse.formOfProofs;
                        this.recommendedProofOptions =
                            response.mapResponse.formOfProofsRecommended;
                        if (this.currentRFI.RFICode == "V562" || this.currentRFI.RFICode == "V581" || this.currentRFI.RFICode == "V548"){
                            this.recommendedProofOptions.forEach((item) => {
                                if (this.currentRFI.RFICode == "V562" && item.value === "PF"){
                                    this.isPAFS76 = true;
                                    this.isPAFS700 = false;
                                    this.isPAFS702 = false;
                                }
                                if (this.currentRFI.RFICode == "V581" && item.value === "PA700") {
                                    this.isPAFS700 = true;
                                    this.isPAFS76 = false;
                                    this.isPAFS702 = false;
                                }
                                if (this.currentRFI.RFICode == "V548" && item.value === "PA702") {
                                    this.isPAFS702 = true;
                                    this.isPAFS76 = false;
                                    this.isPAFS700 = false;
                                }
                            });
                        } else {
                            
                            this.isPAFS76 = false;
                            this.isPAFS700 = false;
                            this.isPAFS702 = false;
                        }
                        if (this.isPAFS76) {
                            this.recommendedProofOptions = this.recommendedProofOptions.filter(
                                opt => opt.value !== "PF"
                            );
                        }
                        if (this.isPAFS700) {
                            this.recommendedProofOptions = this.recommendedProofOptions.filter(
                                opt => opt.value !== "PA700"
                            );
                        }
                        if (this.isPAFS702) {
                            this.recommendedProofOptions = this.recommendedProofOptions.filter(
                                opt => opt.value !== "PA702"
                            );
                        }

                        // Sorted all Type Of Proof List by its label in Ascending order in Popup.
                        if (this.proofOptions.length > 0) {
                            this.proofOptions.sort(function (a, b) {
                                if (a.label > b.label) {
                                    return 1;
                                }
                                if (b.label > a.label) {
                                    return -1;
                                }
                                return 0;
                            });
                        }
                        // Sorted Recommended Type Of Proof List by its label in Ascending order in recommended block.
                        if (this.recommendedProofOptions.length > 0) {
                            this.recommendedProofOptions.sort(function (a, b) {
                                if (a.label > b.label) {
                                    return 1;
                                }
                                if (b.label > a.label) {
                                    return -1;
                                }
                                return 0;
                            });
                        }
                        //Condition to render "Recommended forms of proof" block
                        if (this.recommendedProofOptions.length > 0) {
                            this.isToShowRecommendedProofBlock = true;
                        } else {
                            this.isToShowRecommendedProofBlock = false;
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
                "Error on loadProofOptions" +
                    JSON.stringify(error.message)
            );
            this.showSpinner = false;
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
            console.error(
                "Error on hideToast of SspDocumentCenterProof" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : displayVerificationPopup
     * @description : Used to open Proofs Modal.
     *  @param {object} event - Js event.
     */
    displayVerificationPopup = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showVerificationPopup = true;
            }
        } catch (error) {
            console.error(
                "Error in displayVerificationPopup" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : closeVerificationPopup
     * @description : Used to close Proofs Modal.
     */
    closeVerificationPopup = () => {
        try {
            this.showVerificationPopup = false;
            this.showVerificationPopup = "";
        } catch (error) {
            console.error(
                "Error in closeVerificationPopup" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : showCurrentRFICount
     * @description : getter method to get RFI count.
     */
    get showCurrentRFICount () {
        try {
            return this.currentRFIIndex + 1;
        } catch (error) {
            console.error(
                "Error in showCurrentRFICount" + JSON.stringify(error.message)
            );
            return false;
        }
    }
    /**
     * @function : handleYesNoChange
     * @description : method to handle toggle field changes.
     */
    handleYesNoChange = () => {
        try {
            this.validateYesNoSelection(false);
            this.nextButtonDisabled = false;
        } catch (error) {
            console.error(
                "Error in handleYesNoChange" + JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : navigateNextScreen
     * @description : method to navigate to next screen.
     */
    navigateNextScreen = () => {
        this.showSpinner = true;
        try {
            if (this.validateYesNoSelection(true)) {
                if (this.selectedNav === "Y") {
                    this.clearData();
                    const event = new CustomEvent(events.showUpload, {
                        detail: "Show Upload"
                    });
                    this.dispatchEvent(event);
                    this.nextButtonDisabled = true;
                } else if (this.selectedNav === "N") {
                    this.clearData();
                    
                    const event = new CustomEvent(events.showNextRFI, {
                        detail: "Show Next RFI"
                    });
                    this.dispatchEvent(event);
                    this.nextButtonDisabled = true;
                }
                this.showSpinner = false;
            } else {
                this.showSpinner = false;
            }
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "Error in navigateNextScreen" + JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : clearData
     * @description : method to clear data.
     */
    clearData = () => {
        try {
            this.selectedNav = null;
            const yesNoInput = this.template.querySelector(".ssp-inputYesNo");
            yesNoInput.value = this.selectedNav;
        } catch (error) {
            console.error(
                "Error in navigateNextScreen" + JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : validateYesNoSelection
     * @description : validations for toggle options.
     * @param {flag} showValidationToast - ShowValidationToast.
     */
    validateYesNoSelection = showValidationToast => {
        try {
            let allowSaveData;
            const requiredInputYesNoMsg = sspRequired;
            const yesNoInput = this.template.querySelector(".ssp-inputYesNo");
            this.selectedNav = yesNoInput.value;
            const messageList = yesNoInput.ErrorMessageList;

            const indexOfMessage = messageList.indexOf(requiredInputYesNoMsg);
            // invalid data
            if (this.selectedNav === null || this.selectedNav === "" || this.selectedNav.length === 0) {
                if (indexOfMessage === -1) {
                    messageList.push(requiredInputYesNoMsg);
                    yesNoInput.ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
                if (showValidationToast) {
                    this.hasSaveValidationError = true;
                }
                allowSaveData = false;
            }
            // valid data
            else {
                if (indexOfMessage >= 0) {
                    messageList.splice(indexOfMessage, 1);
                    yesNoInput.ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
                allowSaveData = true;
            }
            return allowSaveData;
        } catch (error) {
            console.error(
                "Error in validateYesNoSelection" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    };
    /**
     * @function : handleExit
     * @description :method to exit from wizard.
     */
    handleExit = () => {
        try {
            this.openExitWizardModel = true;
        } catch (error) {
            console.error(
                "Error in handleExit" + JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : closeExitWizardModel
     * @description :method to close Exit Wizard model.
     */
    closeExitWizardModel = () => {
        try {
            this.openExitWizardModel = false;
            this.openExitWizardModel = "";
        } catch (error) {
            console.error(
                "Error in closeExitWizardModel" + JSON.stringify(error.message)
            );
        }
    };
}