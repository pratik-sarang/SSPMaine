import { track, LightningElement } from "lwc";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import downloadWrittenStatement from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadWrittenStatement";
import sspConstants from "c/sspConstants";

export default class SspDocumentView extends LightningElement {
    @track pdfUrl;
    @track imgUrl;
    @track pdfJSViewer;
    @track showPdfPage = false;
    @track checkRendered = false;
    @track base64;
    @track showSpinner = false;

    connectedCallback () {
        this.showSpinner = true;
        //Get the content document id or DMS id
        let dmsId, contentDocId, fileExtension, isWrittenStatement;
        if (typeof URL === "function") {
            const urlString = window.location.href;
            const url = new URL(urlString);
            dmsId = url.searchParams.get("dmsId");
            contentDocId = url.searchParams.get("contentDocId");
            fileExtension = url.searchParams.get("fileExtension");
            isWrittenStatement =
                url.searchParams.get("contentDoc") === "WrittenStatement"
                    ? true
                    : false;
        } else {
            const url = location.search.substring(1);
            let arr = [];
            arr = url.split("&");
            if (arr[0].split("=")[0] === "contentDocId") {
                contentDocId = arr[0].split("=")[1];
            }
            if (arr[0].split("=")[0] === "dmsId") {
                dmsId = arr[0].split("=")[1];
            }
            if (arr[1].split("=")[0] === "fileExtension") {
                fileExtension = arr[1].split("=")[1];
            }
            if (arr[0].split("=")[0] === "contentDoc") {
                isWrittenStatement = true;
            } else {
                isWrittenStatement = false;
            }
        }

        //Set the document ids
        const documentData = {};
        documentData.documentMetaDataId = dmsId ? dmsId : "";
        documentData.contentDocumentId = contentDocId ? contentDocId : "";

        //Get the base64 data for other documents
        if (!isWrittenStatement) {
            downloadDocumentMethod({
                sDocumentData: JSON.stringify(documentData)
            })
                .then(result => {
                    if (result.bIsSuccess === true) {
                        let base64String = "";
                        const contentDocBase64Data =
                            result.mapResponse.contentDocBase64Data;
                        const docBase64Data = result.mapResponse.docBase64Data;

                        base64String = docBase64Data
                            ? docBase64Data
                            : contentDocBase64Data;
                        this.base64 = base64String;

                        const byteCharacters = atob(base64String);
                        const byteNumbers = new Array(byteCharacters.length);
                        for (let i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }

                        let mimeType;
                        if (fileExtension === "pdf") {
                            this.showPdfPage = true;
                            mimeType = "application/pdf";
                        } else if (
                            fileExtension === sspConstants.sspDocUpload.formatJPG ||
                            fileExtension === sspConstants.sspDocUpload.formatJPEG
                        ) {
                            mimeType = "image/jpeg";
                        } else if (
                            fileExtension ===  sspConstants.sspDocUpload.formatTIF ||
                            fileExtension === "tiff"
                        ) {
                            mimeType = "image/tiff";
                        } else if (fileExtension === "png") {
                            mimeType = "image/png";
                        }

                        if (mimeType === "application/pdf") {
                            const pdfJsFrame = this.template.querySelector(
                                '[data-id="pdfFrame"]'
                            );
                            pdfJsFrame.contentWindow.postMessage(
                                base64String,
                                "*"
                            );
                            this.template
                                .querySelector(".ssp-downloadDocumentFrame")
                                .classList.remove("slds-hide");
                            this.showSpinner = false;
                           
                        } else {
                            this.imgUrl =
                                "data:" + mimeType + ";base64," + base64String;
                            this.showSpinner = false;
                        }
                    }
                })
                .catch({});
        } else {
            downloadWrittenStatement({})
                .then(result => {
                    if (result.bIsSuccess === true) {
                        const fileBase64 = result.mapResponse.resourceBody;

                        const pdfJsFrame = this.template.querySelector(
                            '[data-id="pdfFrame"]'
                        );
                        pdfJsFrame.contentWindow.postMessage(fileBase64, "*");
                        this.template
                            .querySelector(".ssp-downloadDocumentFrame")
                            .classList.remove("slds-hide");
                        this.showSpinner = false;
                    } else {
                        console.error(
                            "Error occurred in openWrittenStatement of SspDocumentCenterHome " +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        }
    }

    
}