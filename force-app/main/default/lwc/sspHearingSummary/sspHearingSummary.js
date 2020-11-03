import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import hearings from "@salesforce/label/c.SSP_Hearings";
import hearingSummaryNote from "@salesforce/label/c.SSP_HearingSummaryNote";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import learnMoreTitle from "@salesforce/label/c.SSP_HearingSummaryLearnMoreTitle";
import requestHearing from "@salesforce/label/c.SSP_RequestHearing";
import requestHearingTitle from "@salesforce/label/c.SSP_RequestHearingTitle";
import myRequests from "@salesforce/label/c.SSP_MyRequests";
import viewDetails from "@salesforce/label/c.sspViewDetails";
import viewDetailsTitle from "@salesforce/label/c.SSP_ViewDetailsTitle";
import hearingIDText from "@salesforce/label/c.SSP_HearingIDText";
import reasonText from "@salesforce/label/c.SSP_MedicalSupportEnforcementReasonText";
import submissionDate from "@salesforce/label/c.SSP_SubmissionDate";
import type from "@salesforce/label/c.SSP_Type";
import requestSent from "@salesforce/label/c.SSP_RequestSent";
import incompleteRequestText from "@salesforce/label/c.SSP_IncompleteRequestText";
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
import sspHearingSummaryLearnMorePhoneLink from "@salesforce/label/c.SSP_HearingSummaryLearnMorePhoneLink";
import sspHearingSummaryLearnMorePhone from "@salesforce/label/c.SSP_HearingSummaryLearnMorePhone";

import getHearingSummary from "@salesforce/apex/SSP_HearingSummaryController.getHearingSummary";
import getScreenPermission from "@salesforce/apex/SSP_HearingSummaryController.getScreenPermission";
import sspUtility from "c/sspUtility";
import nonCitizenId from "@salesforce/user/Id";
import sspConstants from "c/sspConstants";
// SSO Redirect
import validateSSORedirect from "@salesforce/apex/SSP_Utility.validateSSORedirect";

const hearingStatusMap = {
    IN: incompleteRequestText,
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

export default class SspHearingSummary extends BaseNavFlowPage {
    label = {
        hearings,
        hearingSummaryNote,
        learnMoreLink,
        learnMoreTitle,
        requestHearing,
        requestHearingTitle,
        myRequests,
        viewDetails,
        viewDetailsTitle,
        hearingIDText,
        reasonText,
        submissionDate,
        requestSent,
        sspHearingSummaryLearnMorePhoneLink,
        sspHearingSummaryLearnMorePhone

    };
    hearingId = null;

    @track showLearnMore = false;
    @track showSummaryInner = false;
    @track modValue;
    @track reference = this;
    @track hearingSummary = [];
    @track individualAddress = [];
    @track showRequestHearing = false;
    @track showNextSteps = false;
    @track showHearingSummary = true;
    @track userId = nonCitizenId;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track showSpinner = false;
    @track selectedDetailId;
    @track showRequestDetails = false;
    @track showToast = false;
    @track uploadHearingDocuments = false;
    @track showMyRequest = false;
    @track uploadBackToSummary = false;
    @track requestId;
    @track showErrorModal = false;
    @track errorMsg = "";
    // SSO Redirect URL
    @track ssoEndpoint= null;
    @track ssoEncryptedToken= null;
    @track showRequestHearingButton = false;
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
        }
    }

    /**
     * @function - renderedCallback
     * @description - This method is used to called whenever there is track variable changing.
     */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
            );

            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function - connectedCallback
     * @description - Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            this.showSummaryInner=true;
            this.showSpinner = true;
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            const url = new URL(window.location.href);
            this.hearingIdUrl = url.searchParams.get("hearingId");
            if (!sspUtility.isUndefinedOrNull(this.hearingIdUrl)) {
                this.selectedDetailId = this.hearingIdUrl.split("-")[0];
                this.requestId = this.hearingIdUrl.split("-")[1];
                this.uploadBackToSummary = true;
                this.showHearingSummary = false;
                this.uploadHearingDocuments = true;
                this.showSpinner = false;
            } else {
                this.showHelpContentData("Hearing Summary");
                this.getScreenPermission();
                this.getScreenPermissionHearingRequest();
                validateSSORedirect({ sOperationName: "HEARING" })
                .then(result => {
                    if (result.bIsSuccess && !sspUtility.isUndefined(result.mapResponse.endPoint) && !sspUtility.isUndefined(result.mapResponse.encryptedToken)) {
                        this.ssoEndpoint = result.mapResponse.endPoint;
                        this.ssoEncryptedToken = result.mapResponse.encryptedToken;
                        this.showSpinner = false;
                    } else {
                        this.getHearingSummary();
                    }
                })
                .catch(error => {
                    console.error("Error in SSO Data", error);
                });
            } 
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }
    /**
     * @function - getNegativeNoticeForHearing
     * @description - Use to search Data.
     */
    getScreenPermission = () => {
        try {
            getScreenPermission({
                screenId: "SSP_APP_HearingSummary",
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
    getScreenPermissionHearingRequest = () => {
        try {
            getScreenPermission({
                screenId: "SSP_APP_HearingRequest",
                userId: this.userId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.screenAccessDetails
                        )
                    ) {
                        try {
                            const response = result.mapResponse;
                            if (
                                response != null &&
                                response != undefined &&
                                response.hasOwnProperty("screenAccessDetails")
                            ) {
                                //  const { screenPermission: securityMatrix } = response;
                                const securityMatrix = response.screenAccessDetails;
                                const isRequestHearingScreenAccessible =
                                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                                    securityMatrix.screenPermission ===
                                        sspConstants.permission.notAccessible
                                        ? false
                                        : true;

                                this.showRequestHearingButton = isRequestHearingScreenAccessible;
                            }
                            
                        } catch (error) {
                            console.error(JSON.stringify(error.message));
                        }
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
                //  const { screenPermission: securityMatrix } = response;
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
     * @function learnMoreModal
     * @description This method is used to show learn more modal.
     */
    learnMoreModal () {
        try {
            this.showLearnMore = true;
            return false;
        } catch (error) {
            console.error("Error in learnMoreModal", error);
        }
        return null;
    }
    /**
     * @function closeLearnMoreModal
     * @description This method is used to close learn more modal.
     */
    closeLearnMoreModal () {
        try {
            this.showLearnMore = false;
        } catch (error) {
            console.error("Error in closeLearnMoreModal", error);
        }
    }

    /**
     * @function handleRequestHearing
     * @description This method is used to show/hide request hearing page.
     */
    handleRequestHearing () {
        try {
            if(!sspUtility.isUndefinedOrNull(this.ssoEndpoint) && !sspUtility.isUndefinedOrNull(this.ssoEncryptedToken)) {
                const portalUrl = new URL(this.ssoEndpoint);
                portalUrl.searchParams.append("EncryptedData",this.ssoEncryptedToken);
                window.open(portalUrl.href);
            } else {
                this.showRequestHearing = !this.showRequestHearing;
                this.showHearingSummary = !this.showHearingSummary;
                document.body.scrollTop = 0;
                document.documentElement.scrollTop = 0;
                this.getHearingSummary();
            }

        } catch (error) {
            console.error("Error in closeLearnMoreModal", error);
        }
    }

    /**
     * @function handleSaveHearingRequest
     * @description This method is used to show/hide request hearing page.
     * @param {*}event - Gives the data of current instance.
     */
    handleSaveHearingRequest (event) {
        try {
            this.selectedDetailId = event.detail.hearingId;
            this.requestId = event.detail.requestId;
            this.showRequestHearing = !this.showRequestHearing;
            this.showNextSteps = !this.showNextSteps;
            getHearingSummary()
                .then(result => {
                    this.hearingSummary = result.mapResponse.hearingSummaryList
                        ? JSON.parse(result.mapResponse.hearingSummaryList)
                        : [];
                    this.showMyRequest =
                        this.hearingSummary.length > 0 ? true : false;
                    this.hearingSummary = this.hearingSummary.map(
                        currentItem => {
                            currentItem.hearingStatusText =
                                hearingStatusMap[currentItem.HearingStatus];
                            currentItem.HearingReasonText = reasonText;
                            if (!currentItem.HearingReason) {
                                currentItem.HearingReasonText = type;
                                currentItem.HearingReason =
                                    currentItem.HearingType;
                            } 
                            return currentItem;
                        }
                    );

                    this.individualAddress = result.mapResponse
                        .individualAddress
                        ? JSON.parse(result.mapResponse.individualAddress)
                        : [];

                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        "Error in getting Hearing Summary Details" +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in handleSaveHearingRequest", error);
        }
    }

    /**
     * @function backToSummary
     * @description This method is used to show hearing summary page.
     */
    backToSummary () {
        try {
            this.showHearingSummary = !this.showHearingSummary;
            this.showNextSteps = !this.showNextSteps;
        } catch (error) {
            console.error("Error in backToSummary", error);
        }
    }

    /**
     * @function navigateToHearingDetails
     * @description This method is used to navigate to hearing details.
     * @param {*}event - Gives the data of current instance.
     */
    navigateToHearingDetails = event => {
        try {
            this.showHearingSummary = false;
            this.showRequestDetails = true;
            this.selectedDetailId = event.currentTarget.dataset.id;
            this.requestId = event.currentTarget.dataset.request;
        } catch (error) {
            console.error("Error in navigateToHearingDetails", error);
        }
    };

    /**
     * @function navigateToUpload
     * @description This method is used to navigate to Upload Screen from Next Steps Screen.
     */
    navigateToUpload = () => {
        try {
            this.showNextSteps = false;
            this.uploadHearingDocuments = true;
        } catch (error) {
            console.error("Error in navigateToUpload", error);
        }
    };

    /**
     * @function backToHearing
     * @description This method is used to show hearing summary page.
     * @param {*} event - Gives the data of current instance.
     */
    backToHearing = event => {
        try {
            this.showHearingSummary = true;
            this.showRequestDetails = false;
            if (event.detail) {
                this.showToast = true;
            }
        } catch (error) {
            console.error("Error in backToHearing", error);
        }
    };

    /**
     * @function backToNextSteps
     * @description This method is used to navigate from Upload Screen to Hearing Next Steps Screen.
     */
    backToNextSteps = () => {
        try {
            this.showNextSteps = true;
            this.uploadHearingDocuments = false;
        } catch (error) {
            console.error("Error in backToNextSteps", error);
        }
    };

    /**
     * @function requestDetailsFromUpload
     * @description This method is used to navigate from Upload Screen to Hearing Request Details Screen.
     */
    requestDetailsFromUpload = () => {
        try {
            this.showRequestDetails = true;
            this.uploadHearingDocuments = false;
        } catch (error) {
            console.error("Error in requestDetailsFromUpload", error);
        }
    };

    /**
     * @function uploadFromHearingDetails
     * @description This method is used to navigate from Hearing Request Details to Upload Screen.
     * @param {*} event - Gives the data of current instance.
     */
    uploadFromHearingDetails = event => {
        try {
            if (event.detail === true) {
                this.uploadBackToSummary = true;
            }
            this.showRequestDetails = false;
            this.uploadHearingDocuments = true;
        } catch (error) {
            console.error("Error in uploadFromHearingDetails", error);
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast () {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
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
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    getHearingSummary () {
        try {
            getHearingSummary()
                .then(result => {
                    if (result.mapResponse.status) {
                        this.hearingSummary = result.mapResponse
                            .hearingSummaryList
                            ? JSON.parse(result.mapResponse.hearingSummaryList)
                            : [];
                        this.showMyRequest =
                            this.hearingSummary.length > 0 ? true : false;
                        this.hearingSummary = this.hearingSummary.map(
                            currentItem => {
                                currentItem.hearingStatusText =
                                    hearingStatusMap[currentItem.HearingStatus];
                                currentItem.HearingReasonText = reasonText;
                                if (!currentItem.HearingReason) {
                                    currentItem.HearingReasonText = type;
                                    currentItem.HearingReason =
                                        currentItem.HearingType;
                                }
                                return currentItem;
                            }
                        );

                        this.individualAddress = result.mapResponse
                            .individualAddress
                            ? JSON.parse(result.mapResponse.individualAddress)
                            : [];
                        this.showSpinner = false;
                    } else {
                        this.errorMsg = result.mapResponse.responseDescription;
                        this.showErrorModal = true;
                    }
                })
                .catch(error => {
                    console.error(
                        "Error in getting Hearing Summary Details" +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in getHearingSummary" + JSON.stringify(error));
        }
    }
}
