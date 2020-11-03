/**
 * Component Name: sspSNAPNextStep.
 * Author: Sharon.
 * Description: This screen is developed for SNAP Next Step.
 * Date: 16/04/2020.
 */

import {track, api} from "lwc";
import downloadCopy from "@salesforce/apex/SSP_DownloadSNAPCopyController.downloadCopy";
import sspSNAPNextStepsHeading from "@salesforce/label/c.SSP_SNAPNextStepsHeading";
import sspSNAPNextStepsApplication from "@salesforce/label/c.SSP_SNAPNextStepsApplication";
import sspSNAPNextStepsPara from "@salesforce/label/c.SSP_SNAPNextStepsPara";
import sspSNAPNextStepsDownloadButton from "@salesforce/label/c.SSP_SNAPNextStepsDownloadButton";
import sspSNAPNextStepsDownloadTitle from "@salesforce/label/c.SSP_SNAPNextStepsDownloadTitle";
import sspSNAPNextInterviewHeading from "@salesforce/label/c.SSP_SNAPNextInterviewHeading";
import sspSNAPNextCompleteContent from "@salesforce/label/c.SSP_SNAPNextCompleteContent";
import sspSNAPNextPhoneHeading from "@salesforce/label/c.SSP_SNAPNextPhoneHeading";
import sspSNAPNextPhoneContent from "@salesforce/label/c.SSP_SNAPNextPhoneContent";
import sspSNAPNextVisitHeading from "@salesforce/label/c.SSP_SNAPNextVisitHeading";
import sspSNAPNextVisitContent from "@salesforce/label/c.SSP_SNAPNextVisitContent";
import sspSNAPNextVisitButton from "@salesforce/label/c.SSP_SNAPNextVisitButton";
import sspSNAPNextDocumentHeading from "@salesforce/label/c.SSP_SNAPNextDocumentHeading";
import sspSNAPNextDocumentContent from "@salesforce/label/c.SSP_SNAPNextDocumentContent";
import sspSNAPNextIdentificationHeading from "@salesforce/label/c.SSP_SNAPNextIdentificationHeading";
import sspSNAPNextIdentificationOne from "@salesforce/label/c.SSP_SNAPNextIdentificationOne";
import sspSNAPNextIdentificationTwo from "@salesforce/label/c.SSP_SNAPNextIdentificationTwo";
import sspSNAPNextIdentificationThree from "@salesforce/label/c.SSP_SNAPNextIdentificationThree";
import sspSNAPNextSecurityHeading from "@salesforce/label/c.SSP_SNAPNextSecurityHeading";
import sspSNAPNextCitizenship from "@salesforce/label/c.SSP_SNAPNextCitizenship";
import sspSNAPNextResidencyHeading from "@salesforce/label/c.SSP_SNAPNextResidencyHeading";
import sspSNAPNextExpensesHeading from "@salesforce/label/c.SSP_SNAPNextExpensesHeading";
import sspSNAPNextAssetsHeading from "@salesforce/label/c.SSP_SNAPNextAssetsHeading";
import sspSNAPNextResourcesHeading from "@salesforce/label/c.SSP_SNAPNextResourcesHeading";
import sspSNAPNextOtherHeading from "@salesforce/label/c.SSP_SNAPNextOtherHeading";
import sspSNAPNextIncomeHeading from "@salesforce/label/c.SSP_SNAPNextIncomeHeading";
import sspProgramPageButton from "@salesforce/label/c.SSP_ProgramPageButton";
import sspSNAPNextStepCallText from "@salesforce/label/c.SSP_SNAPNextStepCallText";
import sspSNAPNextStepCallNumber from "@salesforce/label/c.SSP_SNAPNextStepCallNumber";
import sspSNAPNextStepCallAlternate from "@salesforce/label/c.SSP_SNAPNextStepCallAlternate";
import sspProgramPageButtonAlternate from "@salesforce/label/c.SSP_ProgramPageButtonAlternate";
import sspSNAPNextToast from "@salesforce/label/c.SSP_SNAPNextToast";
import sspShortSNAPApplication from "@salesforce/label/c.SSP_ShortSNAPApplication";
import sspFooterDCBSLink from "@salesforce/label/c.SSP_FooterDCBS_Link";
import sspNextStepProof1 from "@salesforce/label/c.SSP_NextStepProof1";
import sspNextStepProof2 from "@salesforce/label/c.SSP_NextStepProof2";
import sspNextStepProof3 from "@salesforce/label/c.SSP_NextStepProof3";
import sspNextStepProof4 from "@salesforce/label/c.SSP_NextStepProof4";
import sspNextStepProof5 from "@salesforce/label/c.SSP_NextStepProof5";
import sspNextStepProof6 from "@salesforce/label/c.SSP_NextStepProof6";
import sspNextStepProof7 from "@salesforce/label/c.SSP_NextStepProof7";
import sspNextStepProof8 from "@salesforce/label/c.SSP_NextStepProof8";
import sspNextStepProof9 from "@salesforce/label/c.SSP_NextStepProof9";
import sspNextStepProof10 from "@salesforce/label/c.SSP_NextStepProof10";
import sspNextStepProof11 from "@salesforce/label/c.SSP_NextStepProof11";
import sspNextStepProof12 from "@salesforce/label/c.SSP_NextStepProof12";
import sspNextStepProof13 from "@salesforce/label/c.SSP_NextStepProof13";
import sspNextStepProof14 from "@salesforce/label/c.SSP_NextStepProof14";
import sspNextStepProof15 from "@salesforce/label/c.SSP_NextStepProof15";
import sspNextStepProof16 from "@salesforce/label/c.SSP_NextStepProof16";
import sspNextStepProof17 from "@salesforce/label/c.SSP_NextStepProof17";
import sspNextStepProof18 from "@salesforce/label/c.SSP_NextStepProof18";
import sspNextStepProof19 from "@salesforce/label/c.SSP_NextStepProof19";
import sspNextStepProof20 from "@salesforce/label/c.SSP_NextStepProof20";
import constants from "c/sspConstants";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import { NavigationMixin } from "lightning/navigation";
import sspUtility, { formatLabels } from "c/sspUtility";

export default class SspSNAPNextStep extends NavigationMixin(sspUtility) {
    @track downloadedCopy;
    @track onSuccessNext;
    @api applicationNumber;     // App Number for testing - 400141289
    @track spinnerOn = false;
    onSuccessNext = true;

    desktopBackgroundImg = sspIcons + constants.url.desktopBackgroundImage;
    label = {
        sspSNAPNextStepsHeading,
        sspSNAPNextStepsApplication,
        sspSNAPNextStepsPara,
        sspSNAPNextStepsDownloadButton,
        sspSNAPNextStepsDownloadTitle,
        sspSNAPNextInterviewHeading,
        sspSNAPNextCompleteContent,
        sspSNAPNextPhoneHeading,
        sspSNAPNextPhoneContent,
        sspSNAPNextVisitHeading,
        sspSNAPNextVisitContent,
        sspSNAPNextVisitButton,
        sspSNAPNextDocumentHeading,
        sspSNAPNextDocumentContent,
        sspSNAPNextIdentificationHeading,
        sspSNAPNextIdentificationOne,
        sspSNAPNextIdentificationTwo,
        sspSNAPNextIdentificationThree,
        sspSNAPNextSecurityHeading,
        sspSNAPNextCitizenship,
        sspSNAPNextIncomeHeading,
        sspSNAPNextResidencyHeading,
        sspSNAPNextExpensesHeading,
        sspSNAPNextAssetsHeading,
        sspSNAPNextResourcesHeading,
        sspSNAPNextOtherHeading,
        sspProgramPageButton,
        sspProgramPageButtonAlternate,
        sspSNAPNextStepCallText,
        sspSNAPNextStepCallNumber,
        sspSNAPNextStepCallAlternate,
        sspSNAPNextToast,
        sspShortSNAPApplication,
        sspFooterDCBSLink,
        sspNextStepProof1,
        sspNextStepProof2,
        sspNextStepProof3,
        sspNextStepProof4,
        sspNextStepProof5,
        sspNextStepProof6,
        sspNextStepProof7,
        sspNextStepProof8,
        sspNextStepProof9,
        sspNextStepProof10,
        sspNextStepProof11,
        sspNextStepProof12,
        sspNextStepProof13,
        sspNextStepProof14,
        sspNextStepProof15,
        sspNextStepProof16,
        sspNextStepProof17,
        sspNextStepProof18,
        sspNextStepProof19,
        sspNextStepProof20
    };

    /**
     * @function - connectedCallback.
     * @description - This method is called on component initialization.
     */
    connectedCallback () {
        try {
            this.label.sspSNAPNextStepsApplication = formatLabels(
                this.label.sspSNAPNextStepsApplication,
                [this.applicationNumber]
            );
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }

    /**
     * @function : goToProgramPage
     * @description	: Method to exit from SNAP Next Steps page and SNAP Program Page.
     */
    goToProgramPage = () => {
        try {
            this[NavigationMixin.Navigate]({
              type: "comm__namedPage",
              attributes: {
                name: constants.homePageConstants.programPage
              },
              state: {
                program: constants.homePageConstants.snapSection
              }
            });
          } catch (error) {
            console.error("Error calling redirectToSNAP: ", error);
          }
    };

    
    /**
     * @function : downloadDoc
     * @description	: Method to Download a copy of SNAP Application.
     */
    downloadDoc = () => {
        try{
            this.spinnerOn = true;
            downloadCopy({ applicationNumber: this.applicationNumber })
                .then(result => {
                    this.downloadedCopy = result;
                    const userAgentString = navigator.userAgent;
                    const browserIsEdge = window.navigator.userAgent.indexOf("Edge") != -1;
                    const browserIsChrome = userAgentString.indexOf("Chrome") > -1;
                    const browserIsSafari = userAgentString.indexOf("Safari") > -1 && !browserIsChrome;
                    const browserIsFirefox = userAgentString.indexOf("Firefox") > -1;
                    let fileAsBlob;
                    let fileURL;
                    if (window.navigator && window.navigator.msSaveOrOpenBlob) {
                        //IE11
                        fileAsBlob = new Blob([atob(this.downloadedCopy.binaryData)]);
                        navigator.msSaveOrOpenBlob(fileAsBlob, this.downloadedCopy.fileName);
                    } else {
                        if (browserIsEdge || browserIsFirefox) {
                            // Edge Browser or Mozilla Browser
                            fileAsBlob = new Blob([atob(this.downloadedCopy.binaryData)]);
                            fileURL = URL.createObjectURL(fileAsBlob);
                        } else if (browserIsSafari) {
                            //Safari Browser
                            fileAsBlob = new Blob([atob(this.downloadedCopy.binaryData)], {type: "application/pdf"});
                            fileURL = URL.createObjectURL(fileAsBlob);
                        } else {
                            //Chrome
                            fileURL = "data:pdf;base64," + this.downloadedCopy.binaryData;
                        }
                        const downloadElement = document.createElement("a");
                        downloadElement.href = fileURL;
                        downloadElement.target = "_self";
                        downloadElement.download = this.downloadedCopy.fileName;
                        document.body.appendChild(downloadElement);
                        downloadElement.click();
                    }
                    this.spinnerOn = false;
                })
                .catch(error => {
                    console.error("Error in downloading the file", error);
                });
        } catch (error) {
            console.error("Error calling downloadDoc: ", error);
        }
    }
}