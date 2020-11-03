/**
 * Component Name: SspProgramLinkDownload.
 * Author: Kyathi.
 * Description: The component is to open pdf in new tab.
 * Date: 7/3/2020.
 */

import { track, LightningElement } from "lwc";
import downloadWrittenStatement from "@salesforce/apex/SSP_Utility.downloadWrittenStatement";
import sspConstants from "c/sspConstants";
import sspAssert from "@salesforce/resourceUrl/SSP_Assert";
export default class SspProgramLinkDownload extends LightningElement {
    @track pdfUrl;
    @track imgUrl;
    @track pdfJSViewer;
    @track showPdfPage = false;
    @track checkRendered = false;
    @track base64;
    @track showSpinner = false;
    healthCoverKIHip = `${sspAssert}${sspConstants.url.healthCoverKIHip}`;
    /**
     * @function : connectedCallback.
     * @description : Method to track url change.
     */
    connectedCallback () {
        this.showSpinner = true;
        const urlString = window.location.href;
        const url = new URL(urlString);
        const contentDocId = url.searchParams.get("contentDoc");
        downloadWrittenStatement({
            staticResourceName: contentDocId + ".pdf"
        })
            .then(result => {
                if (result.bIsSuccess === true) {
                    this.showSpinner = false;
                    const fileBase64 = result.mapResponse.resourceBody;

                    const pdfJsFrame = this.template.querySelector(
                        '[data-id="pdfFrame"]'
                    );
                    pdfJsFrame.contentWindow.postMessage(fileBase64, "*");
                    this.showSpinner = false;
                } else {
                    console.error(
                        "Error occurred in downloadWrittenStatement " +
                            result.mapResponse.ERROR
                    );
                    this.showSpinner = false;
                }
            })
            .catch(() => {
                this.showSpinner = false;
            });
    }
    /**
     * @function : base64ToBlob.
     * @description : Method to convert base64 to blob.
     * @param {string} base64String - String.
     * @param {string} extension - Extension.
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
