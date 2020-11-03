/*
 * Component Name: sspResourceSummary.
 * Author: Kyathi Kanumuri, Karthik Gulla.
 * Description: This screen is used for Resources Summary.
 * Date: 12/05/2019.
 */
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspAddResourceButton from "@salesforce/label/c.SSP_AddResourceButton";
import sspRequireResourceDetailsInfo from "@salesforce/label/c.SSP_RequireResourceDetailsInfo";
import sspNoResourceDetailsRequiredText from "@salesforce/label/c.SSP_NoResourceDetailsRequiredText";
import sspExistingResourceRecordsTextLabel from "@salesforce/label/c.SSP_ExistingResourceRecordsText1";
import sspExistingResourceRecordsText2 from "@salesforce/label/c.SSP_ExistingResourceRecordsText2";
import sspAddResourceModalContent from "@salesforce/label/c.SSP_AddResourceModalContent";
import sspAddResourceModalContent2 from "@salesforce/label/c.SSP_AddResourceModalContent2";
import sspAddResourceModalContent3 from "@salesforce/label/c.SSP_AddResourceModalContent3";
import sspStart from "@salesforce/label/c.SSP_StartButton";
import sspEdit from "@salesforce/label/c.SSP_EditButton";
import sspNextButton from "@salesforce/label/c.SSP_NextButton";
import sspAddResourceModalHeading from "@salesforce/label/c.SSP_AddResourceModalHeading";
import sspRemoveModalHeading from "@salesforce/label/c.SSP_RemoveResourceModalHeading";
import sspRemoveResourceModal from "@salesforce/label/c.SSP_RemoveResourceModal";
import getResourcesSummary from "@salesforce/apex/SSP_ResourcesController.getDetailsForResourcesSummary";
import removeResources from "@salesforce/apex/SSP_ResourcesController.removeResources";
import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import utility, { formatLabels } from "c/sspUtility";
import apConstants from "c/sspConstants";
import sspResourceEditButtonTitle from "@salesforce/label/c.SSP_ResourceEditButtonTitle";
import sspResourceViewButtonTitle from "@salesforce/label/c.SSP_ResourceViewButtonTitle";
import sspLearnMoreAltText from "@salesforce/label/c.SSP_LearnMoreAltText";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import sspAddResourceButtonAltText from "@salesforce/label/c.SSP_AddResourceButtonAltText";
import sspResourceRemoveAltText from "@salesforce/label/c.SSP_ResourceRemoveAltText";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspResourceCoOwner from "@salesforce/label/c.SSP_ExistingResourceDetails_CoOwner";
import sspGoToResourceSummary from "@salesforce/label/c.SSP_GoToResourceSummary";
import sspDeleteResourceTitle from "@salesforce/label/c.SSP_DeleteResourceTitle";
import sspCancelGoToResourceSummary from "@salesforce/label/c.SSP_CancelGoToResourceSummary";
//Added by Sharon as part of Security Matrix
import sspConstants from "c/sspConstants"; 
import sspUtility from "c/sspUtility";

export default class sspResourceSummary extends BaseNavFlowPage {
    @api applicationId;
    @api memberId;
    @api memberName;
    @api headOfHousehold;
    @api flowStatus;
    @track reference = this;
    @track trueValue = true;
    @track falseValue = false;
    @track openModel = false;
    @track openLearnMoreModel = false;
    @track showResourceDetails = false;
    @track hasResourceRequiredDetails = false;
    @track hasResNRDetails = false;
    @track hasResExDetails = false;
    @track hasPendingResources = false;
    @track MedicaidNonMAGI = false;
    @track showSpinner = false;
    @track applicablePrograms = [];
    @track nextValue;
    @track timeTravelDate;

    @track existResources = [];
    @track resNotRequiredResources = [];
    @track resRequiredResources = [];
    @track resourceDetails = {};
    @track pendingResourcesCount = 0;
    @track appId;
    @track memberIdValue;
    @track sspExistingResourceRecordsText1;
    @track resourceTypes = [];
    @track hasSaveValidationError = false;
    @track hasEmptyTiles = false;
    @track modValue;

    @track isTrashIconVisible = true;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix. Sharon
    @track isReadOnlyDetails = false;  //CD2 2.5 Security Role Matrix.
    @track disableResourceDetails = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track canDeleteResource = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    label = {
        sspResourceViewButtonTitle,
        sspDeleteResourceTitle,
        sspCancelGoToResourceSummary,
        sspGoToResourceSummary,
        sspAddResourceModalContent2,
        sspAddResourceModalContent3,
        sspSummaryRecordValidator,
        toastErrorText,
        sspLearnMoreModalContent,
        sspResourceEditButtonTitle,
        sspLearnMoreLink,
        sspAddResourceButton,
        sspRequireResourceDetailsInfo,
        sspNoResourceDetailsRequiredText,
        sspExistingResourceRecordsText2,
        sspAddResourceModalContent,
        sspStart,
        sspEdit,
        sspNextButton,
        sspRemoveModalHeading,
        sspAddResourceModalHeading,
        sspLearnMoreAltText,
        sspAddResourceButtonAltText,
        sspResourceRemoveAltText,
        sspResourceCoOwner
    };
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
     * @function : Getter setters for application Id.
     * @description : Getter setters for application Id.
     */
    get applicationId () {
        try{
            return this.appId;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getApplicationId + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set applicationId (value) {
        try{
            this.appId = value;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.setApplicationId + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        try{
            return this.memberIdValue;
        }catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getMemberId + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set memberId (value) {
        try{
            this.memberIdValue = value;
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.getResourceDetails();
            }
        }catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.setMemberId + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setters for next event.
     * @description : Getter setters for next event.
     */
    @api
    get nextEvent () {
        try{
            return this.nextValue;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getNextEvent + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set nextEvent (value) {
        try{
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.hasSaveValidationError = this.hasPendingResources ? true : false;
                this.hasEmptyTiles = this.hasPendingResources ? true : false;
                if(!this.hasEmptyTiles){
                  this.saveData();
                }
            }
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.setNextEvent + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setters for save data.
     * @description : Getter setters for save data.
     */
    @api
    get allowSaveData () {
        try{ 
            return this.validationFlag;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getAllowSaveData + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set allowSaveData (value) {
        try{
            this.validationFlag = value;
            if (value) {
                this.saveCompleted = true;
            }
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.setAllowSaveData + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setters for metadata list.
     * @description : Getter setters for metadata list.
     */
    @api
    get MetadataList () {
        try{
            return this.MetaDataListParent;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getMetadataList + JSON.stringify(error.message)
            );
            return null;
        }
    }
    set MetadataList (value) {
        try{
            this.MetaDataListParent = value;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.setMetadataList + JSON.stringify(error.message)
            );
        }
    }
    /** Security Matrix Sharon. */
    get isDisableResourceDetails () {   //CD2 2.5 Security Role Matrix.
        return this.hasPendingResources || this.isReadOnlyUser;
    }

    get isAddResource () {
        if (this.isReadOnlyDetails || this.disableResourceDetails) {
            return false;
        }
        return true;
    }

    /**
     * @function : Getter setters for save.
     * @description : Getter setters for save.
     */
    saveData = () => {
        try {
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-resourceSummaryInputs"
            );
            this.templateInputsValue = templateAppInputs;
            this.saveCompleted = true;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.saveData + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : closeAddResourceModel
     * @description : Used to close resource pop up modal.
     */
    closeAddResourceModel = () => {
        try{
            this.openModel = false;
            this.openModel = "";
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.closeAddResourceModel + JSON.stringify(error.message)
            );
        }
    };

    connectedCallback () {
        try {
            this.openModel = utility.isUndefinedOrNull(this.flowStatus) ? true : (this.flowStatus.charAt(0) === "R") ? true : false; 
            this.showHelpContentData("SSP_APP_Details_ResourceSummary");
        } catch (error) {
            console.error("Error in connectedCallback", error);
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

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try{
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.hideToast + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : displayLearnMoreModelMethod
     * @description : Used to open learn more modal.
     *  @param {object} event - Js event.
     */
    displayLearnMoreModelMethod = (event) => {
        try{
            if (event.keyCode === 13 || event.type == "click") {
                this.openLearnMoreModel = true;
            }
        } catch(error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.displayLearnMoreModelMethod + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : hideLearnMoreModelMethod
     * @description : Used to hide learn more modal.
     */
    hideLearnMoreModelMethod = () => {
        try{
            this.openLearnMoreModel = false;
            this.openLearnMoreModel = "";
        } catch(error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.hideLearnMoreModelMethod + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleRemoveAction
     * @description : Used to remove resources.
     * @param {event} event - Event details.
     */
    handleRemoveAction = (event) => {
        try {
            this.showSpinner = true;
            const removeResDetails = JSON.parse(JSON.stringify(event.detail));
            const mapResInputs = {};
            mapResInputs[apConstants.resourceSummary.resourceId] =
                removeResDetails[apConstants.resourceSummary.resourceId] != null
                    ? removeResDetails[apConstants.resourceSummary.resourceId]
                    : removeResDetails[
                          apConstants.resourceSummary.resourceTempId
                      ];
            mapResInputs.memberId = this.memberId;
            mapResInputs.applicationId = this.applicationId;
            mapResInputs[apConstants.resourceSummary.resourceType] =
                removeResDetails[apConstants.resourceSummary.resourceType];
            /* @mapResInputs {map} value The input value with member Id, application Id, remove resource details.
             */
            removeResources({
                mapInputs: mapResInputs
            })
                .then(result => {
                    this.resourceTypes = [];
                    this.resRequiredResources = [];
                    this.resNotRequiredResources = [];
                    this.getResourceDetails();
                })
                .catch(error => {
                    console.error(
                        apConstants.resourceSummary.resourceSummaryError.handleRemoveAction + JSON.stringify(error.message)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.handleRemoveAction + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : openResourceDetails
     * @description : Used to show resources details.
     * @param {event} event - Event Details.
     */
    openResourceDetails = (event) => {
        try {
            const buttonAction = event.srcElement.name;
            if (buttonAction == apConstants.resourceSummary.addResource) {
                this.resourceDetails = {};
                this.resourceDetails[apConstants.resourceSummary.resourceType] =
                    "";
            } else {
                this.resourceDetails = event.detail;
            }

            this.showResourceDetails = true;
            const hideFrameworkEvent = new CustomEvent(
                apConstants.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: true
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.openResourceDetails + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : hideResourceDetails
     * @description : Used to hide resources details.
     */
    hideResourceDetails = () => {
        try {
            this.resourceTypes = [];
            this.resRequiredResources = [];
            this.resNotRequiredResources = [];
            this.getResourceDetails();
            const hideFrameworkEvent = new CustomEvent(
                apConstants.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: false
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
            this.showResourceDetails = false;
            window.scroll({
                top: 0,
                left: 0,
                behavior: "smooth"
            });
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.hideResourceDetails + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : getResourceDetails
     * @description : This method is used to get resource details.
     */
    getResourceDetails = () => {
        try {
            let costValue = "";
            let lineTwoValue="";
            let decimalValue="";
            let exCostValue="";
            let exLineTwoValue="";
            let exDecimalValue="";
            this.showSpinner = true;
            const mapResInputs = {};
            mapResInputs.memberId = this.memberId;
            mapResInputs.applicationId = this.applicationId;
            /* @mapResInputs {map} value The input value with member Id, application Id details.
             * @returns { String JSON } Returns a string JSON with resource summary and details.
             */
            getResourcesSummary({
                mapInputs: mapResInputs
            })
                .then(result => {
                    if (!utility.isUndefinedOrNull(result.mapResponse)) {
                        this.constructRenderingAttributes(result.mapResponse); //2.5 Security Role Matrix and Program Access. 
                        this.applicablePrograms = !utility.isUndefinedOrNull(result.mapResponse.ProgramsApplied) ? result.mapResponse.ProgramsApplied.split(";") : "";
                        this.timeTravelDate = result.mapResponse.timeTravelDate;
                        this.existResources = JSON.parse(
                            result.mapResponse.ExistingResources
                        );
                        if (this.existResources.length>0){
                            this.existResources.forEach(exRequiredResource => {
                                exLineTwoValue = exRequiredResource.strResTileLineTwoValue;
                                if (exLineTwoValue.indexOf("$") > -1 && exRequiredResource[apConstants.resourceSummary.resourceType] !== apConstants.resourceTypes.funeralContract) {
                                    exCostValue = "";
                                    exDecimalValue="";
                                    exDecimalValue = exLineTwoValue.indexOf(".") > -1 ? "." + exLineTwoValue.split(".")[1] : "";
                                    exCostValue = exLineTwoValue.split("$")[1];
                                    exCostValue = parseInt(exCostValue);
                                    exRequiredResource.strResTileLineTwoValue = "$" + exCostValue.toLocaleString() + exDecimalValue;
                                }
                            });
                        }
                        this.sspExistingResourceRecordsText1 = formatLabels(
                            sspExistingResourceRecordsTextLabel,
                            [this.memberName]
                        );
                        this.sspRequireResourceDetailsInfo = formatLabels(
                            sspRequireResourceDetailsInfo,
                            [this.memberName]
                        );
                        this.resNotRequiredResources = JSON.parse(
                            result.mapResponse.ResNotRequiringDetails
                        );

                    this.resNotRequiredResources.forEach(
                        notRequiredResource => {
                            this.resourceTypes.push(
                                notRequiredResource[
                                    apConstants.resourceSummary.resourceType
                                ]
                            );
                        }
                    );

                    this.resRequiredResources = JSON.parse(
                        result.mapResponse.ResRequiringDetails
                    );
                    }
                    this.hasResExDetails =
                        this.existResources.length > 0 ? true : false;
                    this.hasResNRDetails =
                        this.resNotRequiredResources.length > 0 ? true : false;
                    this.pendingResourcesCount = 0;

                    if (this.resRequiredResources.length > 0) {
                        this.hasPendingResources = true;
                        this.hasResourceRequiredDetails = true;
                        this.resRequiredResources.forEach(requiredResource => {
                            requiredResource.removeModalHeader = formatLabels(
                                sspRemoveResourceModal,
                                [requiredResource.strResTileLineOneValue]
                            );
                            lineTwoValue = requiredResource.strResTileLineTwoValue;
                            if (lineTwoValue.indexOf("$") > -1 && requiredResource[apConstants.resourceSummary.resourceType] !== apConstants.resourceTypes.funeralContract){
                                costValue="";
                                decimalValue = lineTwoValue.indexOf(".") > -1 ? "."+lineTwoValue.split(".")[1]:"";
                                costValue = lineTwoValue.split("$")[1];
                                costValue = parseInt(costValue);
                                requiredResource.strResTileLineTwoValue = "$" + costValue.toLocaleString() + decimalValue;
                            }
                            if (!requiredResource.isResourceEditable) {
                                this.pendingResourcesCount++;
                            }
                        });
                    } else {
                        this.hasPendingResources = false;
                        this.hasEmptyTiles = false;
                    }

                    this.hasPendingResources =
                        this.pendingResourcesCount === 0 ? false : true;
                    this.MedicaidNonMAGI = JSON.parse(
                        result.mapResponse.AdditionalDetails
                    ).MedicaidNonMagi;
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        apConstants.resourceSummary.resourceSummaryError.getResourceDetails + JSON.stringify(error.message)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                apConstants.resourceSummary.resourceSummaryError.getResourceDetails + JSON.stringify(error.message)
            );
        }
    };
    
    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
   constructRenderingAttributes  =response => {
    try {
        if (
            response != null &&
            response != undefined &&
            response.hasOwnProperty("securityMatrixSummary") &&
            response.hasOwnProperty("securityMatrixDetails")
        ) {
            const {
                securityMatrixSummary,
                securityMatrixDetails
            } = response;
            
            //code here
            /**CD2 2.5	Security Role Matrix Sharon. */
            this.disableResourceDetails =
                !sspUtility.isUndefinedOrNull(securityMatrixDetails) &&
            !sspUtility.isUndefinedOrNull(
                securityMatrixDetails.screenPermission
            ) &&
                securityMatrixDetails.screenPermission ===
                sspConstants.permission.notAccessible
                ? true
                : false;
        this.isReadOnlyUser =
            !sspUtility.isUndefinedOrNull(securityMatrixSummary) &&
            !sspUtility.isUndefinedOrNull(
                securityMatrixSummary.screenPermission
            ) &&
            securityMatrixSummary.screenPermission ===
                sspConstants.permission.readOnly;
        this.canDeleteResource =
            !sspUtility.isUndefinedOrNull(securityMatrixDetails) &&
            !sspUtility.isUndefinedOrNull(securityMatrixDetails.canDelete) &&
            !securityMatrixDetails.canDelete ? false : true;

        this.isReadOnlyDetails =
            !utility.isUndefinedOrNull(securityMatrixDetails) &&
            !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
            securityMatrixDetails.screenPermission === sspConstants.permission.readOnly;
        
        if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
            this.isPageAccessible = true;
        }
        else {
            this.isPageAccessible = !(securityMatrixSummary.screenPermission === apConstants.permission.notAccessible);
        }
        if (!this.isPageAccessible) {
            this.showAccessDeniedComponent = true;
        } else {
            this.showAccessDeniedComponent = false;
        }
        /** */
        }
        else{
            this.isPageAccessible = true;
        }
    } catch (error) {
        console.error(JSON.stringify(error.message));
    }
};
}