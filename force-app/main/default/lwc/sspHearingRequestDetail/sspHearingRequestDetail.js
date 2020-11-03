/**
 * Component Name: sspHearingRequestDetail.
 * Author: Sharon.
 * Description: This component creates a screen for Hearing Request Detail.
 * Date: 09/07/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspHearingsRequestBack from "@salesforce/label/c.SSP_HearingsRequestBack";
import sspHearingRequestHeading from "@salesforce/label/c.SSP_HearingRequestHeading";
import sspHearingsRequestBackAltText from "@salesforce/label/c.SSP_HearingsRequestBackAltText";
import sspHearingRequestCaseNumber from "@salesforce/label/c.SSP_HearingRequestCaseNumber";
import sspHearingRequestCaseName from "@salesforce/label/c.SSP_HearingRequestCaseName";
import sspHearingRequestType from "@salesforce/label/c.SSP_HearingRequestType";
import sspHearingRequestCaseRequester from "@salesforce/label/c.SSP_HearingRequestCaseRequester";
import sspHearingRequestSubmission from "@salesforce/label/c.SSP_HearingRequestSubmissson";
import sspHearingRequestReason from "@salesforce/label/c.SSP_HearingRequestReason";
import sspHearingRequestProgramTitle from "@salesforce/label/c.SSP_HearingRequestProgramTitle";
import sspHearingRequestOfficer from "@salesforce/label/c.SSP_HearingRequestOfficer";
import sspHearingRequestWithdraw from "@salesforce/label/c.SSP_HearingRequestWithdraw";
import sspHearingRequestWithdrawAlt from "@salesforce/label/c.SSP_HearingRequestWithdrawAlt";
import sspHearingRequestHistory from "@salesforce/label/c.SSP_HearingRequestHistory";
import sspHearingRequestDate from "@salesforce/label/c.SSP_HearingRequestDate";
import sspHearingRequestAction from "@salesforce/label/c.SSP_HearingRequestAction";
import sspHearingRequestActionBy from "@salesforce/label/c.SSP_HearingRequestActionBy";
import sspHearingRequestAppointment from "@salesforce/label/c.SSP_HearingRequestAppointment";
import sspHearingRequestConference from "@salesforce/label/c.SSP_HearingRequestConference";
import sspHearingRequestParticipant from "@salesforce/label/c.SSP_HearingRequestParticipant";
import sspHearingRequestLocation from "@salesforce/label/c.SSP_HearingRequestLocation";
import sspHearingRequestMeeting from "@salesforce/label/c.SSP_HearingRequestMeeting";
import sspHearingRequestTime from "@salesforce/label/c.SSP_HearingRequestTime";
import sspHearingRequestHearAppointment from "@salesforce/label/c.SSP_HearingRequestHearAppointment";
import sspHearingRequestParties from "@salesforce/label/c.SSP_HearingRequestParties";
import sspHearingRequestContactName from "@salesforce/label/c.SSP_HearingRequestContactName";
import sspHearingRequestPhoneNumber from "@salesforce/label/c.SSP_HearingRequestPhoneNumber";
import sspHearingRequestCompanyName from "@salesforce/label/c.SSP_HearingRequestCompanyName";
import sspHearingRequestRole from "@salesforce/label/c.SSP_HearingRequestRole";
import sspHearingRequestEmail from "@salesforce/label/c.SSP_HearingRequestEmail";
import sspHearingRequestUploadTitle from "@salesforce/label/c.SSP_HearingRequestUploadTitle";
import sspHearingRequestDocumentType from "@salesforce/label/c.SSP_HearingRequestDocumentType";
import sspHearingRequestUploadDate from "@salesforce/label/c.SSP_HearingRequestUploadDate";
import sspHearingRequestUploadBy from "@salesforce/label/c.SSP_HearingRequestUploadBy";
import sspHearingRequestUploadNew from "@salesforce/label/c.SSP_HearingRequestUploadNew";
import sspHearingRequestUploadNewTitle from "@salesforce/label/c.SSP_HearingRequestUploadNewTitle";
import sspHearingRequestAdverse from "@salesforce/label/c.SSP_HearingRequestAdverse";
import sspHearingRequestAdverseDocument from "@salesforce/label/c.SSP_HearingRequestAdverseDocument";
import sspHearingRequestSendDate from "@salesforce/label/c.SSP_HearingRequestSendDate";
import incompleteRequestText from "@salesforce/label/c.SSP_IncompleteRequestText";
import pendingInformalReviewText from "@salesforce/label/c.SSP_PendingInformalReviewText";
import pendingAssignmentText from "@salesforce/label/c.SSP_PendingAssignmentText";
import pendingSchedulingText from "@salesforce/label/c.SSP_PendingSchedulingText";
import awaitingHearingConferenceText from "@salesforce/label/c.SSP_AwaitingHearingConferenceText";
import awaitingHearingText from "@salesforce/label/c.SSP_AwaitingHearingText";
import awaitingRecommendedOrderText from "@salesforce/label/c.SSP_AwaitingRecommendedOrderText";
import exceptionsPeriodText from "@salesforce/label/c.SSP_ExceptionsPeriodText";
import pendingFinalOrderText from "@salesforce/label/c.SSP_PendingFinalOrderText";
import awaitingBoardReviewText from "@salesforce/label/c.SSP_AwaitingBoardReviewText";
import appealedHigherCourtText from "@salesforce/label/c.SSP_AppealedHigherCourtText";
import finalOrderIssuedText from "@salesforce/label/c.SSP_FinalOrderIssuedText";
import requestWithdrawnText from "@salesforce/label/c.SSP_RequestWithdrawnText";
import caseAbeyanceText from "@salesforce/label/c.SSP_CaseAbeyanceText";
import settledText from "@salesforce/label/c.SSP_SettledText";
import dismissed from "@salesforce/label/c.SSP_Dismissed";
import viewDocument from "@salesforce/label/c.SSP_ViewDocument";
import sspDocumentUploadProcessing from "@salesforce/label/c.SSP_DocumentUploadProcessing";

import showHearingSummaryDetail from "@salesforce/apex/SSP_HearingSummaryController.showHearingSummaryDetail";
import sspUtility, { formatLabels } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import withdrawHearingRequest from "@salesforce/apex/SSP_HearingSummaryController.withdrawHearingRequest";
import getScreenPermission from "@salesforce/apex/SSP_HearingSummaryController.getScreenPermission";
import nonCitizenId from "@salesforce/user/Id";
const sPDFValue = "pdf";

const hearingStatusMap = {
    IN: incompleteRequestText,
    IR: pendingInformalReviewText,
    HO: pendingAssignmentText,
    SCH: pendingSchedulingText,
    PHC: awaitingHearingConferenceText,
    HR: awaitingHearingText,
    RO: awaitingRecommendedOrderText,
    EX: exceptionsPeriodText,
    PENFO: pendingFinalOrderText,
    SEC: awaitingBoardReviewText,
    HC: appealedHigherCourtText,
    FOISS: finalOrderIssuedText,
    WI: requestWithdrawnText,
    ABY: caseAbeyanceText,
    SET: settledText,
    DIS: dismissed
};

export default class SspHearingRequestDetail extends LightningElement {
    @api selectedDetail;
    @api requestId;
    @track hearingWithdrawn = false;
    @track showGreenDisc = false;
    @track showRedDisc = false;
    @track showOrangeDisc = true;
    @track hearingId;
    @track hearingSummary = {};
    @track prehearingAppointmentList = {};
    @track hearingHistoryList = {};
    @track hearingAppointmentList = {};
    @track partiesInvolvedList = {};
    @track documentsUploadList = {};
    @track NegativeActionDocumentsList = {};
    @track historyListLength = false;
    @track prehearingAppointmentListLength = false;
    @track hearingAppointmentListLength = false;
    @track partiesInvolvedListLength = false;
    @track documentsUploadListLength = false;
    @track NegativeActionDocumentsListLength = false;
    @track withdrawHearingStatus = false;
    @track showSpinner = true;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track userId = nonCitizenId;
	@track showDocumentProcessingModal = false; //Flag to show if the document is processing

    label = {
        sspHearingsRequestBack,
        sspHearingRequestHeading,
        sspHearingsRequestBackAltText,
        sspHearingRequestCaseNumber,
        sspHearingRequestCaseName,
        sspHearingRequestType,
        sspHearingRequestCaseRequester,
        sspHearingRequestSubmission,
        sspHearingRequestReason,
        sspHearingRequestProgramTitle,
        sspHearingRequestOfficer,
        sspHearingRequestWithdraw,
        sspHearingRequestWithdrawAlt,
        sspHearingRequestHistory,
        sspHearingRequestDate,
        sspHearingRequestAction,
        sspHearingRequestActionBy,
        sspHearingRequestAppointment,
        sspHearingRequestConference,
        sspHearingRequestParticipant,
        sspHearingRequestLocation,
        sspHearingRequestMeeting,
        sspHearingRequestTime,
        sspHearingRequestHearAppointment,
        sspHearingRequestParties,
        sspHearingRequestContactName,
        sspHearingRequestPhoneNumber,
        sspHearingRequestCompanyName,
        sspHearingRequestRole,
        sspHearingRequestEmail,
        sspHearingRequestUploadTitle,
        sspHearingRequestDocumentType,
        sspHearingRequestUploadDate,
        sspHearingRequestUploadBy,
        sspHearingRequestUploadNew,
        sspHearingRequestUploadNewTitle,
        sspHearingRequestAdverse,
        sspHearingRequestAdverseDocument,
        sspHearingRequestSendDate,
        viewDocument,
		sspDocumentUploadProcessing
    };

    /**
     * @function - connectedCallback.
     * @description - This method creates the field and object list to get metadata details from Entity Mapping as per screen name.
     */
    connectedCallback () {
        try {
            this.getScreenPermission();
            this.showHearingSummaryDetail();
            this.label.sspHearingRequestHeading = formatLabels(
                this.label.sspHearingRequestHeading,
                [this.selectedDetail]
            );
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback of program Selection page" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function - getNegativeNoticeForHearing
     * @description - Use to search Data.
     */
    getScreenPermission = () => {
        try {
            getScreenPermission({
                screenId: "SSP_APP_HearingRequestDetails",
                userId: this.userId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.screenAccessDetails
                        )
                    ) {
                        this.constructRenderingAttributes(result.mapResponse);
                        this.showAccessDeniedComponent = !this
                            .isScreenAccessible;
                    } else {
                        console.error(
                            "Error in loading Results" + JSON.stringify(result)
                        );
                    }
                })
                .catch(error => {
                    console.error("Error in getting data", error);
                });
        } catch (error) {
            console.error(
                "Error occurred in getScreenPermission of sspHearingSummary page" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
     * @description : This method is used to construct rendering attributes.
     * @param {object} response - Backend response.
     */
    constructRenderingAttributes = response => {
        try {
            if (
                response != null &&
                response != undefined &&
                response.hasOwnProperty("screenAccessDetails")
            ) {
                //const { screenPermission: securityMatrix } = response;
                const securityMatrix = response.screenAccessDetails;
                this.isReadOnlyUser =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ===
                        sspConstants.permission.readOnly;
                this.isReadOnlyUser =
                    this.isReadOnlyUser && response.readOnlyUser;
                this.isScreenAccessible =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ===
                        sspConstants.permission.notAccessible
                        ? false
                        : true;
            }
        } catch (error) {
            console.error(JSON.stringify(error.message));
        }
    };

    /**
     * @function - fetchPrograms.
     * @description - This method fetches the available programs.
     */
    withdrawHearingRequest = () => {
        try {
            withdrawHearingRequest({
                hearingId: this.requestId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.withdrawHearingStatus
                        )
                    ) {
                      
                        if (result.mapResponse.status) {
                            this.withdrawHearingStatus =
                                result.mapResponse.withdrawHearingStatus;
                            this.backToHearings(result.mapResponse.bIsSuccess);
                        } else {
                            this.errorMsg = result.mapResponse.error;
                            this.showErrorModal = true;
                        }
                    } else {
                        console.error(
                            "Error in loading Results" + JSON.stringify(result)
                        );
                    }
                })
                .catch(error => {
                    console.error("Error Response -" + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error occurred in fetchPrograms of program selection page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - showHearingSummaryDetail.
     * @description - This method show Hearing Summary.
     */
    showHearingSummaryDetail = () => {
        try {
            showHearingSummaryDetail({
                hearingId: this.requestId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.hearingSummaryViewDetailWrapper
                        )
                    ) {
                        if (result.mapResponse.status) {
                            this.hearingSummary =
                                result.mapResponse.hearingSummaryViewDetailWrapper;
                            this.hearingSummary.hearingStatus =
                                hearingStatusMap[
                                    this.hearingSummary.hearingStatus
                                ];
                            this.hearingWithdrawn =
                                result.mapResponse.hearingWithdrawn;
                            this.prehearingAppointmentList = this.hearingSummary.prehearingAppointmentList;
                            this.hearingHistoryList = this.hearingSummary.hearingHistoryList;
                            this.hearingAppointmentList = this.hearingSummary.hearingAppointmentList;
                            this.partiesInvolvedList = this.hearingSummary.partiesInvolvedList;
                            this.documentsUploadList = this.hearingSummary.documentsUploadList;
                            this.NegativeActionDocumentsList = this.hearingSummary.NegativeActionDocumentsList;
                            this.historyListLength =
                                this.hearingHistoryList.length > 0
                                    ? true
                                    : false;
                            this.prehearingAppointmentListLength =
                                this.prehearingAppointmentList.length > 0
                                    ? true
                                    : false;
                            this.hearingAppointmentListLength =
                                this.hearingAppointmentList.length > 0
                                    ? true
                                    : false;
                            this.partiesInvolvedListLength =
                                this.partiesInvolvedList.length > 0
                                    ? true
                                    : false;
                            this.documentsUploadListLength =
                                this.documentsUploadList.length > 0
                                    ? true
                                    : false;
                            this.NegativeActionDocumentsListLength =
                                this.NegativeActionDocumentsList.length > 0
                                    ? true
                                    : false;
                            this.hearingHistoryList = this.hearingHistoryList.map(
                                item => {
                                    item.hearingHistoryDate = this.formatDate(
                                        item.hearingHistoryDate
                                    );
                                    return item;
                                }
                            );
                            this.NegativeActionDocumentsList = this.NegativeActionDocumentsList.map(
                                item => {
                                    item.negativeSentDate = this.formatDate(
                                        item.negativeSentDate
                                    );
                                    return item;
                                }
                            );
                            this.documentsUploadList = this.documentsUploadList.map(
                                item => {
                                    item.dateOfUpload = this.formatDate(
                                        item.dateOfUpload
                                    );
                                    return item;
                                }
                            );
                        } else {
                            this.errorMsg =
                                result.mapResponse.responseDescription;
                            this.showErrorModal = true;
                        }
                    } else {
                        console.error(
                            "Error in loading Results" + JSON.stringify(result)
                        );
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error("Error Response -" + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error occurred in fetchPrograms of program selection page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - uploadDocuments.
     * @description - This method is used to navigate to Upload Screen.
     */
    uploadDocuments = () => {
        try {
            const currentStatus = true;
            const backToHearing = new CustomEvent(
                sspConstants.hearing.uploadFromRequestDetails,
                {
                    detail: currentStatus
                }
            );

            this.dispatchEvent(backToHearing);
        } catch (error) {
            console.error("Error in redirectPreviousScreen", error);
        }
    };

    /**
     * @function : backToHearingSummary
     * @description : This method is used to save the collected data.
     *  @param {object} withdrawStatus - Status Value.
     */
    backToHearings = withdrawStatus => {
        try {
            const currentStatus =
                withdrawStatus === true ? withdrawStatus : null;
            const backToHearing = new CustomEvent(
                sspConstants.hearing.goBackHearing,
                {
                    detail: currentStatus
                }
            );

            this.dispatchEvent(backToHearing);
        } catch (error) {
            console.error("Error in backToHearingSummary", error);
        }
    };

    /**
     * @function : downloadHearingDocuments
     * @description : Used to download file.
     *  @param {object} event - Js event.
     */
    downloadHearingDocuments = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                 const documentData = {};
                 let documentName = event.target.dataset.documentName;
                 const negativeDocName = event.target.dataset.negativeDocumentName;
                 if(negativeDocName){
                    documentName = negativeDocName + ".pdf";
                 }
                 const extension = event.target.dataset.extension;
                 const contentDocumentId = event.target.dataset.contentId;
                 documentData.contentDocumentId = contentDocumentId
                     ? contentDocumentId
                     : "";                
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
                                        sspConstants.hearing.DMSID +
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

    /**
     * @function : base64ToBlob
     * @description : Used to open pdf version of application.
     * @param  {object} base64String - Base 64 format data.
     * @param  {object} extension - Extension of the file.
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
     * @function : formatDate
     * @description : This method is used to format the date.
     * @param {*}inputDate - Passes the date to be formatted.
     */
    formatDate (inputDate) {
        try {
            const date = new Date(inputDate);
            if (!isNaN(date.getTime())) {
                const day = date.getDate().toString();
                const month = (date.getMonth() + 1).toString();
                // Months use 0 index.

                return (
                    (month[1] ? month : "0" + month[0]) +
                    "/" +
                    (day[1] ? day : "0" + day[0]) +
                    "/" +
                    date.getFullYear()
                );
            }
        } catch (error) {
            console.error("Error in formatDate", error);
        }
    }

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };
}