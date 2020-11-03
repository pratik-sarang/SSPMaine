/**
 * Component Name: sspHearingUploadDocument.
 * Author: Sharon.
 * Description: This screen is used for Upload Hearing Documents.
 * Date: 07/13/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspHearingDocumentTitle from "@salesforce/label/c.SSP_HearingDocumentTitle";
import sspHearingDocumentContentOne from "@salesforce/label/c.SSP_HearingDoucmentContentOne";
import sspHearingDocumentContentTwo from "@salesforce/label/c.SSP_HearingDoucmentContentTwo";
import sspHearingDocumentRequest from "@salesforce/label/c.SSP_HearingDocumentRequest";
import sspHearingDocumentSelectName from "@salesforce/label/c.SSP_HearingDocumentSelectName";
import sspHearingDocumentSelectTitle from "@salesforce/label/c.SSP_HearingDocumentSelectTitle";
import sspHearingDocumentContentThree from "@salesforce/label/c.SSP_HearingDoucmentContentThree";
import sspHearingDocumentAddButton from "@salesforce/label/c.SSP_HearingDocumentAddButton";
import sspHearingDocumentAddTitle from "@salesforce/label/c.SSP_HearingDocumentAddTitle";
import sspHearingDocumentButtonText from "@salesforce/label/c.SSP_HearingDocumentButtonText";
import sspHearingDocumentCancel from "@salesforce/label/c.SSP_HearingDocumentCancel";
import sspHearingDocumentCancelTitle from "@salesforce/label/c.SSP_HearingDocumentCancelTitle";
import wizardProcessUpload from "@salesforce/apex/SSP_DocumentCenterCtrl.hearingWizardProcessUpload";
import sspRequiredValidationMsg from "@salesforce/label/c.SSP_RequiredErrorMessage";
import deleteDocuments from "@salesforce/apex/SSP_DocumentCenterCtrl.deleteDocuments";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import getScreenPermission from "@salesforce/apex/SSP_HearingSummaryController.getScreenPermission";
import nonCitizenId from "@salesforce/user/Id";

export default class SspHearingUploadDocument extends LightningElement {
    @track trueValue = true;
    @api selectedDetail;
    @api uploadBackToSummary;
    @api requestId;
    @track hearingId;
    @track userId = nonCitizenId;
    @track showDetailsSpinner = true;
    @track uploadedDocumentList = [];
    @track hearingDocumentType;
    @track hasSaveValidationError = false;
    @track hearingRequestId;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    label = {
        sspHearingDocumentTitle,
        sspHearingDocumentContentOne,
        sspHearingDocumentContentTwo,
        sspHearingDocumentRequest,
        sspHearingDocumentSelectName,
        sspHearingDocumentSelectTitle,
        sspHearingDocumentContentThree,
        sspHearingDocumentAddButton,
        sspHearingDocumentAddTitle,
        sspHearingDocumentButtonText,
        sspHearingDocumentCancel,
        sspHearingDocumentCancelTitle,
        sspRequiredValidationMsg,
        toastErrorText
    };

    /**
     * @function - connectedCallback.
     * @description - This method creates the field and object list to get metadata details from Entity Mapping as per screen name.
     */
    connectedCallback () {
        try {
            const url = new URL(window.location.href);
            this.hearingId = url.searchParams.get("hearingId");
            if (!sspUtility.isUndefinedOrNull(this.hearingId)) {
                this.selectedDetail = this.hearingId.split("-")[0];
                this.hearingRequestId = this.hearingId.split("-")[1];
            } else {
                this.hearingRequestId = this.requestId;
            }
            this.getScreenPermission();
        } catch (error) {
            console.error("Error in connectedCallback");
        }
    }
    /**
     * @function - getNegativeNoticeForHearing
     * @description - Use to search Data.
     */
    getScreenPermission = () => {
        try {
            getScreenPermission({
                screenId: "SSP_APP_HearingDocuments",
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
                this.isReadOnlyUser = this.isReadOnlyUser && response.readOnlyUser;
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
                    * @function : uploadedFileHandler
                    * @description	: Verify whether required inputs are present.
                    * @param {event} event - Gets current value.
                    */
                   uploadedFileHandler = event => {
                       try {
                           this.uploadedDocumentList = event.detail;
                       } catch (error) {
                           console.error("Error in uploadedFileHandler");
                       }
                   };

                   /**
                    * @function : handleUpload
                    * @description	: Verify whether required inputs are present.
                    */
                   handleUpload = () => {
                       try {
                           this.showDetailsSpinner = true;
                           const isValidInputs = this.runValidateForAllInputs();
                           if (!isValidInputs) {
                               this.hasSaveValidationError = true;
                               this.showDetailsSpinner = false;
                           } else {
                               this.hasSaveValidationError = false;
                               const docToBeUploaded = [];
                               for (
                                   let i = 0;
                                   i < this.uploadedDocumentList.length;
                                   i++
                               ) {
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
                                           this.redirectRequestDetails();
                                       } else {
                                           console.error(
                                               "Error occur in file upload " +
                                                   JSON.stringify(response)
                                           );
                                       }
                                   })
                                   .catch(function (error) {
                                       console.error(
                                           "Error in wizardProcessUpload =>",
                                           error
                                       );
                                   });
                           }
                       } catch (error) {
                           // this.uploadSuccessFull = false;
                           console.error(
                               "Error in uploadDocuments" +
                                   JSON.stringify(error.message)
                           );
                       }
                   };

                   /**
                    * @function : runValidateForAllInputs
                    * @description	: Verify whether required inputs are present.
                    */
                   runValidateForAllInputs = () => {
                       try {
                           this.template
                               .querySelector("c-ssp-document-file-upload")
                               .validateHearingDocumentTypeField();
                           if (
                               // isValidIndSelect &&
                               // isValidDesc &&
                               this.hearingDocumentType &&
                               this.uploadedDocumentList &&
                               this.uploadedDocumentList.length > 0
                           ) {
                               return true;
                           }
                           return false;
                       } catch (error) {
                           console.error(
                               "Error in uploadDocuments" +
                                   JSON.stringify(error.message)
                           );
                           return null;
                       }
                   };

                   /**
                    * @function : selectHearingDocumentTypeHandler
                    * @description	: Verify whether required inputs are present.
                    * @param {event} event - Gets current value.
                    */
                   selectHearingDocumentTypeHandler = event => {
                       this.hearingDocumentType = event.detail;
                   };

                   /**
                    * @function : hideToast
                    * @description	: Method to hide Toast.
                    */
                   hideToast = () => {
                       try {
                           this.hasSaveValidationError = false;
                       } catch (error) {
                           console.error(
                               "Error in hideToast" +
                                   JSON.stringify(error.message)
                           );
                       }
                   };

                   /**
                    * @function : cancelAndNavigate
                    * @description : navigate to dashboard.
                    */
                   cancelUpload = () => {
                       try {
                           this.showDetailsSpinner = true;
                           const docToBeDeleted = [];
                           for (
                               let i = 0;
                               i < this.uploadedDocumentList.length;
                               i++
                           ) {
                               docToBeDeleted.push(
                                   this.uploadedDocumentList[i].fileId
                               );
                           }
                           if (docToBeDeleted && docToBeDeleted.length > 0) {
                               deleteDocuments({
                                   contentVersionLst: docToBeDeleted
                               })
                                   .then(response => {
                                       if (response.bIsSuccess) {
                                           this.redirectPreviousScreen();
                                           this.showDetailsSpinner = false;
                                       }
                                       this.showDetailsSpinner = false;
                                   })
                                   .catch(function (error) {
                                       console.error(error);
                                   });
                           } else {
                               this.redirectPreviousScreen();
                               this.showDetailsSpinner = false;
                           }
                       } catch (error) {
                           console.error(
                               "Error in cancelUpload" +
                                   JSON.stringify(error.message)
                           );
                           this.showDetailsSpinner = false;
                       }
                   };

                   /**
                    * @function : redirectPreviousScreen
                    * @description : navigate to previous screen.
                    */
                   redirectPreviousScreen = () => {
                       try {
                           const currentEvent = this.uploadBackToSummary
                               ? sspConstants.hearing.goBackRequestDetails
                               : sspConstants.hearing.goBackNextSteps;
                           this.dispatchEvent(new CustomEvent(currentEvent));
                       } catch (error) {
                           console.error(
                               "Error in redirectPreviousScreen",
                               error
                           );
                       }
                   };

                   /**
                    * @function : redirectRequestDetails
                    * @description : navigate to previous screen.
                    */
                   redirectRequestDetails = () => {
                       try {
                           this.dispatchEvent(
                               new CustomEvent(
                                   sspConstants.hearing.goBackRequestDetails
                               )
                           );
                       } catch (error) {
                           console.error(
                               "Error in redirectRequestDetails",
                               error
                           );
                       }
                   };
               }