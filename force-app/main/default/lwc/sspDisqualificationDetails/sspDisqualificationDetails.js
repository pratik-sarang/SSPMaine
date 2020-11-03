/*
 * Component Name: SspDisqualificationDetails.
 * Author: Anuja Ingole
 * Description: This is use for Disqualification Details screen under benefits.
 * Date: 6/1/2020.
 */
import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspDisqualificationBack from "@salesforce/label/c.SSP_DisqualificationBack";
import sspDisqualificationBackTitle from "@salesforce/label/c.SSP_DisqualificationBackTitle";
import sspDisqualificationHeading from "@salesforce/label/c.SSP_DisqualificationHeading";
import sspDisqualificationContent from "@salesforce/label/c.SSP_DisqualificationContent";
import sspDisqualificationProgramsName from "@salesforce/label/c.SSP_DisqualificationProgramsName";
import sspDisqualificationSuspensionName from "@salesforce/label/c.SSP_DisqualificationSuspensionName";
import sspDisqualificationStartDate from "@salesforce/label/c.SSP_DisqualificationStartDate";
import sspDisqualificationEndDate from "@salesforce/label/c.SSP_DisqualificationEndDate";
import sspDisqualificationView from "@salesforce/label/c.SSP_DisqualificationView";
import sspDisqualificationViewTitle from "@salesforce/label/c.SSP_DisqualificationViewTitle";
import fetchDisqualificationData from "@salesforce/apex/SSP_DisqualificationDetailsController.fetchDisqualificationData";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";

export default class SspDisqualificationDetails extends NavigationMixin(LightningElement) {
    label = {
        sspDisqualificationBack,
        sspDisqualificationHeading,
        sspDisqualificationBackTitle,
        sspDisqualificationContent,
        sspDisqualificationProgramsName,
        sspDisqualificationSuspensionName,
        sspDisqualificationStartDate,
        sspDisqualificationEndDate,
        sspDisqualificationView,
        sspDisqualificationViewTitle
    };

    @track resultObj;
    @track mapData = [];
    @track showSpinner = false;
    @track showScreen= false;
    @track showAccessDenied= false;
    @track individualId;
    @track contentDocBase64DataTemp;
    
    
    connectedCallback () {
        try {
            this.showSpinner = true;
            const url = new URL(window.location.href);
            this.individualId = url.searchParams.get("individualId");
            fetchDisqualificationData({
                individualId: this.individualId //"890010780"
            })
            .then(result => {
                const parsedData = result.mapResponse;  
                if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
                    console.error("failed in loading dashboard" +JSON.stringify(parsedData.ERROR));
                } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    if (parsedData.hasOwnProperty("resultString" )) {
                        this.resultObj = JSON.parse(parsedData.resultString);
                    }
                }
                if (parsedData.hasOwnProperty("showScreen") && parsedData.showScreen) {
                    this.showScreen = true;
                }else{
                    this.showAccessDenied = true;
                }
                Object.keys(this.resultObj).forEach((key) => {
                    this.mapData.push({value:this.resultObj[key], key:key}); //Here we are creating the array to show on UI.
                });
                this.showSpinner = false;
            })
            .catch(error => {
                console.error("Error : " +JSON.stringify(error));
            });
          } catch (error) {
            console.error("Error in connectedCallBack:"+JSON.stringify(error) );
          }
    
    }

    
    /**
     * @function : downloadTheFile
     * @description : Used to download file.
     *  @param {object} event - Js event.
     */
    downloadTheFile = event => {
        const sPDFValue = "pdf";
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                const documentData = {};
                const documentMetadataId = event.target.dataset.metadataId;
                const extension = "pdf";
                const documentName = "Notice";
                documentData.documentMetaDataId = documentMetadataId
                    ? documentMetadataId
                    : "";
                const contentDocumentId= "";
                documentData.contentDocumentId = "";
                downloadDocumentMethod({
                    sDocumentData: JSON.stringify(documentData)
                })
                    .then(result => {
                        if (result.bIsSuccess === true) {
                            let base64Data = "";
                            
                            const docBase64Data =
                                result.mapResponse.docBase64Data;
                            //const pageUrl = result.mapResponse.pageUrl;
                            const pageUrl =
                                sspConstants.documentCenterHome
                                    .downloadDocumentUrl;

                            base64Data = docBase64Data;
                                
                                
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
                                    link.click();
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
                            } else {
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
   * @function - backToBenefits.
   * @description - Method to navigate to benefits screen.
   * @param  {object} event - Fired on key down or click of the link.
   */
  backToBenefits = (event) =>{
    try{
        if (event.type === "click" || (event.type === "keydown" && event.keyCode === 13)){
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Benefits_Page__c"
                }
            });
        } 
    }
    catch(error){
        console.error("Error occurred in backToBenefits",error);
    }
}
}