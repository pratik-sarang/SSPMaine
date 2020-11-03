/**
 * Component Name: sspMessageCenterTableNotices.
 * Author: Chirag, Aniket.
 * Description: To Show Notices table in message center.
 * Date: 7/1/2020.
 */
import { LightningElement, api, track } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspMessageCenterNoMatchFound from "@salesforce/label/c.SSP_MessageCenterNoMatchFound";
import sspConstants from "c/sspConstants";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
const sPDFValue = "pdf";

export default class SspMessageCenterTableNotices extends LightningElement {
    iconUrl = sspIcons + "/sspIcons/ic_sort@2x.png";
    
    @api tableColumns;
    @api messageTableData;
    @api isSearch = false;
    @api noSearchFound = false;
    
    @track noticeID; 
    @track showSpinner = false;
    
    customLabel = {
        sspMessageCenterNoMatchFound
    };

    /**
     * @function : downloadTheFile
     * @description : Used to download file.
     *  @param {object} event - Js event.
     */
    downloadTheFile = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
                if (event.currentTarget.dataset.id) {
                        this.noticeID = event.currentTarget.dataset.id;
                        this.dispatchEvent(
                            new CustomEvent("noticeread", {
                                detail: this.noticeID
                            })
                    );
                }
                this.showSpinner = true;
                const documentData = {};
                const documentName = "notice";
                const extension = "pdf";
                const documentMetadataId = event.target.dataset.metadataId;
                documentData.documentMetaDataId = documentMetadataId
                    ? documentMetadataId
                    : "";
                
                downloadDocumentMethod({
                    sDocumentData: JSON.stringify(documentData)
                })
                    .then(result => {
                        if (result.bIsSuccess === true) {
                            let base64Data = "";
                            base64Data = result.mapResponse.docBase64Data;

                            //const pageUrl = result.mapResponse.pageUrl;
                            const pageUrl =
                                sspConstants.documentCenterHome
                                    .downloadDocumentUrl;

                            if (
                                base64Data &&
                                base64Data !== "ERROR Empty Response"
                            ) {
                                // Start - Download Document Code
                                const userAgentString = navigator.userAgent;
                                const browserIsEdge =
                                    window.navigator.userAgent.indexOf(
                                        "Edge"
                                    ) !== -1;
                                const browserIsSafari =
                                    userAgentString.indexOf("Safari") > -1;
                                const browserIExplorer =
                                    window.navigator &&
                                    window.navigator.msSaveOrOpenBlob
                                        ? true
                                        : false;
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
                                    link.download = documentName;
                                    link.href = fileURL;
                                    link.style.display = "none";
                                    link.target = "_blank";
                                    if(!browserIOS){
                                        link.click();
                                    }
                                }
                                // End - Download Document Code
                                // Start - Open in new Tab and Preview the Document
                                let previewUrl = "";
                                previewUrl =
                                    pageUrl +
                                    "?dmsId=" +
                                    documentMetadataId +
                                    "&fileExtension=" +
                                    extension;
                                window.open(previewUrl, "_blank");
                                // End - Open in new Tab and Preview the Document
                            } else {
                                console.error(
                                    "Error occurred in downloadTheFile of downloadTheFile " +
                                        JSON.stringify(result)
                                );
                                this.showErrorModal = true;
                            }
                            this.showSpinner = false;
                        } else {
                            console.error(
                                "Error occurred in downloadTheFile of downloadTheFile " +
                                    result.mapResponse.ERROR
                            );
                            this.showErrorModal = true;
                            this.showSpinner = false;
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        console.error(
                            "Error in downloadTheFile of downloadTheFile" +
                                JSON.stringify(error.message)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "Error in downloadTheFile of downloadTheFile" +
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
}