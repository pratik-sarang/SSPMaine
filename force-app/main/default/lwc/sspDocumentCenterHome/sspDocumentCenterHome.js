/*
 * Component Name: SspDocumentCenterHome.
 * Author: Kyathi Kanumuri,Aniket,Ashwin
 * Description: This screen is used for Document center Home.
 * Date: 4/7/2020.
 */
import { LightningElement, track } from "lwc";
import sspConstants from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import sspDocuments from "@salesforce/label/c.SSP_Documents";
import { NavigationMixin } from "lightning/navigation";
import sspDocumentCenterHomeContent1 from "@salesforce/label/c.SSP_DocumentCenterHomeContent1";
import sspDocumentCenterHomeContent2 from "@salesforce/label/c.SSP_DocumentCenterHomeContent2";
import sspDocumentCenterUploadText from "@salesforce/label/c.SSP_DocumentCenterUploadText";
import sspDocumentCenterUploadText2 from "@salesforce/label/c.SSP_DocumentCenterUploadText2";
import sspDocumentCenterHomeNoticeText from "@salesforce/label/c.SSP_DocumentCenterHomeNoticeText";
import sspDocumentReadyToUpload from "@salesforce/label/c.SSP_DocumentReadyToUpload";
import sspDocumentUploadRequested from "@salesforce/label/c.SSP_DocumentUploadRequested";
import sspDocumentNoRequestText from "@salesforce/label/c.SSP_DocumentNoRequestText";
import sspUploadDocuments from "@salesforce/label/c.SSP_UploadDocumentCenterDocuments";
import sspDocumentWizardLabel from "@salesforce/label/c.SSP_DocumentWizardLabel";
import sspDocumentsNeeded from "@salesforce/label/c.SSP_DocumentsNeeded";
import sspRecentlySubmitted from "@salesforce/label/c.SSP_RecentlySubmitted";
import sspDueDate from "@salesforce/label/c.SSP_DueDate";
import sspPreferredDueDate from "@salesforce/label/c.SSP_PreferredDueDate";
import sspSubmittedDate from "@salesforce/label/c.SSP_SubmittedDate";
import sspPendingReview from "@salesforce/label/c.SSP_PendingReview";
import sspNotSubmitted from "@salesforce/label/c.SSP_NotSubmitted";
import initDocumentCenter from "@salesforce/apex/SSP_DocumentCenterCtrl.initDocumentCenter";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import sspRecentlySubmittedHeaderText1 from "@salesforce/label/c.SSP_RecentlySubmittedHeaderText1";
import sspRecentlySubmittedHeaderText2 from "@salesforce/label/c.SSP_RecentlySubmittedHeaderText2";
import sspDocumentWizardTitle from "@salesforce/label/c.SSP_DocumentWizardTitle";
import sspUploadDocumentsTitle from "@salesforce/label/c.SSP_UploadDocumentsTitle";
import sspDownloadFileTitle from "@salesforce/label/c.SSP_DownloadFileTitle";
import sspRejected from "@salesforce/label/c.SSP_Rejected";
import sspAccepted from "@salesforce/label/c.SSP_Accepted";
const sKIHIPPEligibility = "KHIPP_ENRL";
const sKIHIPPPremiumPayment = "KHIPP_MON_VER";
const sKIHIPPValue = "KI-HIPP";
const sPDFValue = "pdf";

export default class SspDocumentCenterHome extends NavigationMixin(
    LightningElement
) {
    @track showSpinner = false;
    @track openModel = false;
    @track pending = false;
    @track RFIWrapper = false;
    @track showHome = true;
    @track showDocWizard = false;
    @track showGenericDocUpload = false;
    @track caseWrapper;
    @track rfiInformationList = [];
    @track documentMetaDataList = [];
    @track documentNeededCount = 0;
    @track recentlySubmittedCount = 0;
    @track showUploadNav = true;
    @track browserIExplorer;
    @track uploadedFilesTemp;
    label = {
        sspDocuments,
        sspDocumentCenterHomeContent1,
        sspDocumentCenterHomeContent2,
        sspDocumentCenterUploadText,
        sspDocumentCenterUploadText2,
        sspDocumentCenterHomeNoticeText,
        sspDocumentReadyToUpload,
        sspDocumentUploadRequested,
        sspDocumentNoRequestText,
        sspUploadDocuments,
        sspDocumentWizardLabel,
        sspDocumentsNeeded,
        sspRecentlySubmitted,
        sspDueDate,
        sspPreferredDueDate,
        sspSubmittedDate,
        sspPendingReview,
        sspNotSubmitted,
        sspRecentlySubmittedHeaderText1,
        sspRecentlySubmittedHeaderText2,
        sspDocumentWizardTitle,
        sspUploadDocumentsTitle,
        sspRejected,
        sspAccepted,
        sspDownloadFileTitle
    };

    /**
     * @function : downloadTheFile
     * @description : Used to download file.
     *  @param {object} event - Js event.
     */
    downloadTheFile = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                const documentData = {};
                const documentName = event.target.dataset.documentName;
                const extension = event.target.dataset.extension;
                const documentMetadataId = event.target.dataset.metadataId;
                const contentDocumentId = event.target.dataset.contentId;
                documentData.documentMetaDataId = documentMetadataId
                    ? documentMetadataId
                    : "";
                documentData.contentDocumentId = contentDocumentId
                    ? contentDocumentId
                    : "";
                downloadDocumentMethod({
                    sDocumentData: JSON.stringify(documentData)
                })
                    .then(result => {
                        if (result.bIsSuccess === true) {
                            let base64Data = "";
                            const contentDocBase64Data =
                                result.mapResponse.contentDocBase64Data;
                            const docBase64Data =
                                result.mapResponse.docBase64Data;
                            //const pageUrl = result.mapResponse.pageUrl;
                            const pageUrl =
                                sspConstants.documentCenterHome
                                    .downloadDocumentUrl;

                            base64Data = docBase64Data
                                ? docBase64Data
                                : contentDocBase64Data;
                            
                            if(base64Data && base64Data !== "ERROR Empty Response"){
                                // Start - Download Document Code
                                const userAgentString = navigator.userAgent;
                                const browserIsEdge =
                                    window.navigator.userAgent.indexOf("Edge") !==
                                    -1;
                                const browserIsSafari =
                                    userAgentString.indexOf("Safari") > -1;
                                const browserIExplorer =
                                    window.navigator &&
                                    window.navigator.msSaveOrOpenBlob
                                        ? true
                                        : false;
                                const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
                                this.browserIExplorerTemp = browserIExplorer;
                                let fileURL;
                                let fileBlob;
                                //For IE11
                                if (
                                    window.navigator &&
                                    window.navigator.msSaveOrOpenBlob
                                ) {
                                    fileBlob = this.base64ToBlob(
                                        base64Data,
                                        extension
                                    );
                                    window.navigator.msSaveOrOpenBlob(
                                        fileBlob,
                                        documentName
                                    );
                                } else {
                                    if (browserIsEdge || browserIsSafari) {
                                        // Edge Browser or Mozilla Browser or Safari
                                        fileBlob = this.base64ToBlob(
                                            base64Data,
                                            extension
                                        );
                                        fileURL = URL.createObjectURL(fileBlob);
                                    } else {
                                        // Chrome & Firefox
                                        if (extension === sPDFValue) {
                                            fileURL =
                                                "data:application/" +
                                                extension +
                                                ";base64," +
                                                base64Data; // PDF
                                        } else {
                                            fileURL =
                                                "data:image/" +
                                                extension +
                                                ";base64," +
                                                base64Data; // JPEG,PNG,TIFF
                                        }
                                    }
                                    const link = document.createElement("a");
                                    if(!browserIOS){
                                        link.download = documentName;
                                        link.href = fileURL;
                                        link.style.display = "none";
                                        link.target = "_blank";
                                        link.click();
                                    }
                                }
                                // End - Download Document Code
                                // Start - Open in new Tab and Preview the Document
                                let previewUrl = "";
                                if (documentMetadataId) {
                                    previewUrl =
                                        pageUrl +
                                        "?dmsId=" +
                                        documentMetadataId +
                                        "&fileExtension=" +
                                        extension;
                                } else if (contentDocumentId) {
                                    previewUrl =
                                        pageUrl +
                                        "?contentDocId=" +
                                        contentDocumentId +
                                        "&fileExtension=" +
                                        extension;
                                }
                                window.open(previewUrl, "_blank");
                                // End - Open in new Tab and Preview the Document
                            }
                            else{
                                console.error(
                                    "Error occurred in downloadTheFile of SspDocumentCenterHome " +
                                        JSON.stringify(result)
                                );
                            }
                            this.showSpinner = false;
                        } else {
                            console.error(
                                "Error occurred in downloadTheFile of SspDocumentCenterHome " +
                                    result.mapResponse.ERROR
                            );
                            this.showSpinner = false;
                        }
                    })
                    .catch({});
            }
        } catch (error) {
            console.error(
                "Error in downloadTheFile of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
            this.showSpinner = false;
        }
    };

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
    /**
     * @function : handleUploadFinished
     * @description : Used to get uploaded files.
     *  @param {object} event - Js event.
     */
    handleUploadFinished = event => {
        try {
            const uploadedFiles = event.getParam("files");
            this.uploadedFilesTemp = uploadedFiles;
        } catch (error) {
            console.error(
                "Error in handleUploadFinished of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
    };
    

    /**
     * @function : isNonEmptyRFIInformationList
     * @description : Check if non empty rfi list .
     */
    get isNonEmptyRFIInformationList () {
        try {
            let returnVal=false;
            if(this.rfiInformationList.length > 0)
                 {returnVal = true;}
            return returnVal;
        } catch (error) {
            console.error(
                "Error in isNonEmptyRFIInformationList of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
            return false;
        }
    }

    /**
     * @function : connectedCallback
     * @description : Called on page load to fetch the response.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.showHome = true;
            this.initDocCenterHome();
        } catch (error) {
            console.error(
                "Error in navigateToDocumentWizard of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : initDocCenterHome
     * @description : initialize data for document center home.
     */
    initDocCenterHome = () => {
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
        this.rfiInformationList = [];
        this.documentMetaDataList = [];
        initDocumentCenter()
            .then(response => {
                if (response.bIsSuccess && response.mapResponse) {
                    if (response.mapResponse.HasUserVisitedDocumentCenter) {
                        this.openModel = false;
                    } else {
                        this.openModel = true;
                    }

                    // Role access based rendering
                    if (
                        response.mapResponse.userDocCenterAccess ===
                        sspConstants.documentCenterHome.editable
                    ) {
                        this.showHome = true;
                        this.showUploadNav = true;
                    } else if (
                        response.mapResponse.userDocCenterAccess ===
                        sspConstants.documentCenterHome.readOnly
                    ) {
                        this.showHome = true;
                        this.showUploadNav = false;
                    } else {
                        this.showHome = false;
                        this.showUploadNav = false;
                        console.error(
                            "Role does not have access to document center."
                        );
                    }

                    this.RFIWrapper = response.mapResponse.RFIWrapper;
                    //this.caseWrapper = response.mapResponse.CaseWrapper;
                    const rfiInformationPayload =
                        response.mapResponse.rfiInformationPayload;
                    let rfiInformation = {};
                    let documentMetaData = {};
                    let documentDetailList = [];
                    let typeOfProofMetaDataList = [];
                    if (rfiInformationPayload) {
                        //wrapper for generic upload
                        this.caseWrapper =
                            rfiInformationPayload.caseInformationList;
                        rfiInformation = rfiInformationPayload.rfiInformation;
                        documentMetaData =
                            rfiInformationPayload.documentMetaData;
                        documentDetailList =
                            rfiInformationPayload.documentDetailList;
                        typeOfProofMetaDataList =
                            rfiInformationPayload.typeOfProofMetaDataList;
                    }

                    // Create RFI Info wrapper list. Split by Ind Id and Name bind the RFI info List
                    if (rfiInformation) {
                        for (const [key, value] of Object.entries(
                            rfiInformation
                        )) {
                            const individual = {};
                            individual.iIndividualId = key.split(",")[0];
                            individual.sIndividualName = key.split(",")[1];
                            individual.individualData = value;
                            this.rfiInformationList.push(individual);
                            //Set the count of Documents Needed
                            this.documentNeededCount += value.length;
                        }
                    }
                    //Format and set the count of Documents Needed Label
                    this.label.sspDocumentsNeeded = formatLabels(
                        this.label.sspDocumentsNeeded,
                        [this.documentNeededCount]
                    );
                    // Create Document Metadata wrapper list. Split by Ind Id and Name bind the Doc metadata info List
                    if (documentMetaData) {
                        for (const [key, value] of Object.entries(
                            documentMetaData
                        )) {
                            const individual = {};
                            individual.iIndividualId = key.split(",")[0];
                            individual.sIndividualName = key.split(",")[1];
                            individual.individualData = value;
                            this.documentMetaDataList.push(individual);
                            //Set the count of Recently Submitted Documents
                            this.recentlySubmittedCount += value.length;
                        }
                    }
                    //Format and set the count of Recently Submitted Documents
                    this.label.sspRecentlySubmitted = formatLabels(
                        this.label.sspRecentlySubmitted,
                        [this.recentlySubmittedCount]
                    );
                    // Create Map of UniqueIdentifier with Document
                    const mapUniqueVsDocument = new Map();
                    if (documentDetailList) {
                        documentDetailList.forEach(element => {
                            if (
                                element.UniqueIdentifier__c !== undefined &&
                                element.UniqueIdentifier__c !== ""
                            ) {
                                if (
                                    mapUniqueVsDocument.has(
                                        element.UniqueIdentifier__c
                                    )
                                ) {
                                    const documentList = mapUniqueVsDocument.get(
                                        element.UniqueIdentifier__c
                                    );
                                    documentList.push(element);
                                    mapUniqueVsDocument.set(
                                        element.UniqueIdentifier__c,
                                        documentList
                                    );
                                } else {
                                    const documentList = [];
                                    documentList.push(element);
                                    mapUniqueVsDocument.set(
                                        element.UniqueIdentifier__c,
                                        documentList
                                    );
                                }
                            }
                        });
                    }

                    // Create Map of TypeOfProof and List of DocumentType
                    const mapTypeOfProofVsDocType = new Map();
                    if (typeOfProofMetaDataList) {
                        typeOfProofMetaDataList.forEach(element => {
                            if (
                                mapTypeOfProofVsDocType.has(
                                    element.TypeOfProof__c
                                )
                            ) {
                                const documentList = mapTypeOfProofVsDocType.get(
                                    element.TypeOfProof__c
                                );
                                documentList.push(element);
                                mapTypeOfProofVsDocType.set(
                                    element.TypeOfProof__c,
                                    documentList
                                );
                            } else {
                                const documentList = [];
                                documentList.push(element);
                                mapTypeOfProofVsDocType.set(
                                    element.TypeOfProof__c,
                                    documentList
                                );
                            }
                        });
                    }

                    // Iterate through rfiInformationList.
                    if (this.rfiInformationList.length > 0) {
                        this.rfiInformationList.forEach(element => {
                            if (element.individualData.length > 0) {
                                for (
                                    let index = 0;
                                    index < element.individualData.length;
                                    index++
                                ) {
                                    const data = element.individualData[index];
                                    // Here we set "KI-HIPP eligibility" documents to display "Preferred Due Date" Label.
                                    if (
                                        data.sTypeOfProofRefCode ===
                                        sKIHIPPEligibility
                                    ) {
                                        data.isKIHIPPEligibility = true;
                                        data.sDueDate = this.setDates(
                                            data.sDueDate,
                                            30
                                        );
                                    } else {
                                        data.isKIHIPPEligibility = false;
                                    }
                                    // Here we set "KI-HIPP premium payment" documents to display "Due Date" Label.
                                    if (
                                        data.sTypeOfProofRefCode ===
                                        sKIHIPPPremiumPayment
                                    ) {
                                        data.isKIHIPPPremiumPayment = true;
                                        data.sDueDate = this.lastDateOfMonth(
                                            data.sDueDate
                                        );
                                    } else {
                                        data.isKIHIPPPremiumPayment = false;
                                    }
                                    // Here we set "RFI" documents to display "Due Date" Label.
                                    data.isRFIDocument =
                                        data.isKIHIPPEligibility === true ||
                                        data.isKIHIPPPremiumPayment === true
                                            ? false
                                            : true;
                                    // Format the date to mm/dd/yyyy
                                    data.sDueDate = this.formatDate(
                                        data.sDueDate
                                    );
                                    // Find Document exists in salesforce from 'mapUniqueVsDocument' and bind List of Documents(containing Id,Name,Extension etc) in rfiInformationList.
                                    
                                    if (
                                        data.sUniqueIdentifier !== undefined &&
                                        data.sUniqueIdentifier !== "" &&
                                        mapUniqueVsDocument.has(
                                            data.sUniqueIdentifier
                                        )
                                    ) {
                                        data.isUniqueIdentifierExists = true;
                                        const newDocumentList = [];
                                        const documentList = mapUniqueVsDocument.get(
                                            data.sUniqueIdentifier
                                        );
                                        for (
                                            let currentIndex = 0;
                                            currentIndex < documentList.length;
                                            currentIndex++
                                        ) {
                                            const documentData =
                                                documentList[currentIndex];
                                            const newDocumentData = {};
                                            
                                            newDocumentData.sId =
                                                documentData.Id;
                                            newDocumentData.sDocumentName =
                                                documentData.Name;
                                            newDocumentData.sExtension =
                                                documentData.Extension__c;
                                            newDocumentData.sSubmittedDate =
                                                documentData.ReceivedDate__c;
                                            newDocumentData.sContentDocumentId =
                                                documentData.ContentDocumentId__c;
                                            newDocumentData.sMimeType =
                                                documentData.MimeType__c;
                                            newDocumentData.sDocumentMetadataId =
                                                documentData.DocumentMetadataId__c;
                                            //Set the Formatted the Download link
                                            newDocumentData.sFormattedLink = formatLabels(
                                                this.label.sspDownloadFileTitle,
                                                [documentData.Name]
                                            );
                                            newDocumentList.push(
                                                newDocumentData
                                            );
                                        }
                                        data.documentList = newDocumentList;
                                        data.sSubmittedDate =
                                            documentList[0].ReceivedDate__c;
                                        if (data.sSubmittedDate) {
                                            
                                            data.sSubmittedDate = this.formatDate(
                                                data.sSubmittedDate.split(
                                                    "T"
                                                )[0]
                                            );
                                            
                                        }
                                    } else {
                                        data.isUniqueIdentifierExists = false;
                                    }

                                    // Find KIHIPP TypeOfProof from 'mapTypeOfProofVsDocType' and set KI-HIPP prefix
                                    if (
                                        data.sTypeOfProofRefCode !==
                                            undefined &&
                                        data.sTypeOfProofRefCode !== "" &&
                                        mapTypeOfProofVsDocType.has(
                                            data.sTypeOfProofRefCode
                                        )
                                    ) {
                                        // Check K_Hipp_Proof__c = true & TypeOfProof is not starting KI-HIPP then add KI_HIPP prefix.
                                        if (
                                            mapTypeOfProofVsDocType.get(
                                                data.sTypeOfProofRefCode
                                            )[0].K_Hipp_Proof__c &&
                                            !data.sTypeOfProof.startsWith(
                                                sKIHIPPValue
                                            )
                                        ) {
                                            data.sTypeOfProof =
                                                sKIHIPPValue +
                                                " " +
                                                data.sTypeOfProof;
                                        }
                                    }
                                }
                            }
                        });
                    }

                    // Iterate through documentMetaDataList.
                    if (this.documentMetaDataList.length > 0) {
                        this.documentMetaDataList.forEach(element => {
                            if (element.individualData.length > 0) {
                                for (
                                    let index = 0;
                                    index < element.individualData.length;
                                    index++
                                ) {
                                    const data = element.individualData[index];
                                    // Format the date to mm/dd/yyyy
                                    data.sSubmittedDate = this.formatDate(
                                        data.sSubmittedDate
                                    );
                                    //Set the Formatted the Download link
                                    data.sFormattedLink = formatLabels(
                                        this.label.sspDownloadFileTitle,
                                        [data.sDocumentName]
                                    );
                                }
                            }
                        });
                    }
                    
                }
                this.showSpinner = false;
            })
            .catch(function (error) {
                console.error(
                    "Error in initDocCenterHome of SspDocumentCenterHome," +
                        error.message
                );
            });
    };

    /**
     * @function : navigateToDocumentWizard
     * @description : Set variables to navigate to Wizard .
     */
    navigateToDocumentWizard = () => {
        try {
            this.showHome = false;
            this.showDocWizard = true;
            this.showGenericDocUpload = false;
        } catch (error) {
            console.error(
                "Error in navigateToDocumentWizard of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : navigateToUploadPage
     * @description : Set variables to navigate to Upload screen .
     */
    navigateToUploadPage = () => {
        try {
            this.showHome = false;
            this.showDocWizard = false;
            this.showGenericDocUpload = true;
        } catch (error) {
            console.error(
                "Error in navigateToUploadPage of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : renderDocCenterHome
     * @description : Set variables to navigate to Home .
     */
    renderDocCenterHome = () => {
        try {
            this.showSpinner = true;
            this.showHome = true;
            this.showDocWizard = false;
            this.showGenericDocUpload = false;
            this.initDocCenterHome();
        } catch (error) {
            console.error(
                "Error in navigateToUploadPage of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : formatDate
     * @description : Method use to format date into mm/dd/yyyy.
     * @param {string} dateParameter - Contains the date parameter.
     */
    formatDate = dateParameter => {
        let dateParam = dateParameter;
        try {
            if (dateParam) {
                const dateList = dateParam.split("-");
                dateParam = dateList[1] + "/" + dateList[2] + "/" + dateList[0];
            }
        } catch (error) {
            console.error(
                "Error in formatDate of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
        return dateParam;
    };

    /**
     * @function : lastDateOfMonth
     * @description : Method use to set last date of Month.
     * @param {string} dateParameter - Contains the date parameter.
     */
    lastDateOfMonth = dateParameter => {
        let dateParam = dateParameter;
        try {
            if (dateParam) {
                const d = new Date(dateParam);
                const lastDay = new Date(d.getFullYear(), d.getMonth() + 1, 0);
                dateParam =
                    lastDay.getFullYear() +
                    "-" +
                    (lastDay.getMonth() + 1) +
                    "-" +
                    lastDay.getDate();
            }
        } catch (error) {
            console.error(
                "Error in lastDateOfMonth of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
        return dateParam;
    };

    /**
     * @function : setDates
     * @description : Method use to add number of Days to Date.
     * @param {string} dateParameter - Contains the date parameter.
     * @param {number} number - Contains the number parameter.
     */
    setDates = (dateParameter, number) => {
        let dateParam = dateParameter;
        try {
            if (dateParam) {
                const d = new Date(dateParam);
                d.setDate(d.getDate() + number);
                dateParam =
                    d.getFullYear() +
                    "-" +
                    (d.getMonth() + 1) +
                    "-" +
                    d.getDate();
            }
        } catch (error) {
            console.error(
                "Error in setDates of SspDocumentCenterHome" +
                    JSON.stringify(error.message)
            );
        }
        return dateParam;
    };
}
