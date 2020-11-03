/*
 * Component Name: sspMedicareCoverageSummary
 * Author: Kyathi,Varun
 * Description: The Medicare Coverage summary screen displays the coverage details as tiles.
 * Date: 1/14/2020.
 */
import { track, api } from "lwc";
import sspMedicareCoverageSummaryText from "@salesforce/label/c.SSP_MedicareCoverageSummaryText";
import sspAddCoverageButton from "@salesforce/label/c.SSP_AddCoverageButton";
import sspAddCoverageButtonAltText from "@salesforce/label/c.SSP_AddCoverageButtonAltText";
import sspMedicareCoverageLabel from "@salesforce/label/c.SSP_MedicareCoverageLabel";
import sspEditCoverageButtonAltText from "@salesforce/label/c.SSP_EditCoverageButtonAltText";
import sspRemoveCoverageAltText from "@salesforce/label/c.SSP_RemoveCoverageAltText";
import sspStartCoverageButtonTitle from "@salesforce/label/c.SSP_StartCoverageButtonTitle";
import sspRemoveModalHeading from "@salesforce/label/c.SSP_RemoveCoverageModalHeading";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspStartDate from "@salesforce/label/c.SSP_StartDate";
import utility, { formatLabels } from "c/sspUtility";
import getMedicalCoverageSummary from "@salesforce/apex/SSP_MedicareCoverageSummary.getMedicalCoverageSummary";
import removeBenefit from "@salesforce/apex/SSP_MedicareCoverageSummary.removeBenefit";
import apConstants from "c/sspConstants";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspConstants from "c/sspConstants";
export default class SspMedicareCoverageSummary extends BaseNavFlowPage {
    @track currentMemberNameValue;
    @api memberName;
    @api applicationId;
    @api memberId;
    /**
     * @function : Getter setters for next event.
     * @description : Getter setters for next event.
     */
    @api
    get nextEvent () {
        try {
            return this.nextValue;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.hasEmptyTiles = false;
                let isToSaveData = true;
                if (
                    this.medicareCoverageSummaryWrapper !== undefined &&
                    this.medicareCoverageSummaryWrapper.length > 0
                ) {
                    this.medicareCoverageSummaryWrapper.forEach(wrapper => {
                        if (!wrapper.displayEdit) {
                            isToSaveData = false;
                        }
                    });
                }
                if (isToSaveData) {
                    this.nextValue = value;
                    this.saveData();
                } else {
                    this.hasSaveValidationError = true;
                }
            }
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }
    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }
    /**
     * @function : Getter setters for save data.
     * @description : Getter setters for save data.
     */
    @api
    get allowSaveData () {
        try {
            return this.validationFlag;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
            return null;
        }
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;
            if (value) {             
                this.saveData();
            }
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }
    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value) {
            this.MetaDataListParent = value;
        }
    }
     /**
    * @function - get currentMemberName.
    * @description - This method is used to get current member name.
    */
   @api
   get currentMemberName () {
       return this.currentMemberNameValue;
   }

   /**
   * @function - set currentMemberName.
   * @description - This method is used to set current member name.
   * @param {*} value - Full name of current member name.
   */
   set currentMemberName (value) {
       try {
           if (value) {
               this.currentMemberNameValue = value;
               this.label.sspMedicareCoverageSummaryText = formatLabels(
                sspMedicareCoverageSummaryText,
                [this.currentMemberNameValue]
            );
           }
        }
        catch (e) {
            console.error(
                "Error in set currentMemberName of Medicare Coverage page",
                e
            );
        }
    }
    @track mapOfIdAndBenefit = new Map();
    @track validationFlag;
    @track showSpinner = false;
    @track trueValue = true;
    @track falseValue = false;
    @track disableAddButton = false;
    @track showMedicareDetails = false;
    @track medicareCoverageSummaryWrapper;
    @track sspBenefitId;
    @track hasSaveValidationError = false;
    @track appId;
    @track memberIdValue;
    @track allowSaveData;
    @track MetaDataListParent;
    @track hasEmptyTiles = false;
    @track hasPendingMedicareCoverage = false;
    @track pageName;
    @track isReadOnlyUser = false;  //CD2 2.5 Security Role Matrix.
    @track isReadOnlyDetails = false;   //CD2 2.5 Security Role Matrix.
    @track canDeleteMedicareCoverage = true; //CD2 2.5 Security Role Matrix.
    @track disableMedicareCoverageDetails = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspMedicareCoverageSummaryText,
        sspAddCoverageButton,
        sspAddCoverageButtonAltText,
        sspMedicareCoverageLabel,
        sspEditCoverageButtonAltText,
        sspRemoveCoverageAltText,
        sspStartCoverageButtonTitle,
        sspRemoveModalHeading,
        sspStartDate,
        sspSummaryRecordValidator,
        toastErrorText
    };

    get isDisableAddButton () { //CD2 2.5 Security Role Matrix.
        return this.disableAddButton || this.isReadOnlyUser;
    }

    get isAddButton () {    //CD2 2.5 Security Role Matrix.
        if (this.isReadOnlyDetails || this.disableMedicareCoverageDetails) {
            return false;
        }
        return true;
    }

    /**
     * @function : Getter setters for application Id.
     * @description : Getter setters for application Id.
     */
    get applicationId () {
        try {
            return this.appId;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
            return null;
        }
    }
    set applicationId (value) {
        try {
            this.appId = value;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        try {
            return this.memberIdValue;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
            return null;
        }
    }
    set memberId (value) {
        try {
            this.memberIdValue = value;
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.getCoverageDetails();
            }
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : saveData.
     * @description : method to save data.
     */
    saveData = () => {
        try {
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-coverageSummaryInputs"
            );
            this.templateInputsValue = templateAppInputs;
            this.saveCompleted = true;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage
            );
        }
    };

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleAddCoverageAction
     * @description : This method is used to handle Add Coverage button Action.
     */

    handleAddCoverageAction = () => {
        try {
            this.showMedicareDetails = true;
            this.sspBenefitId = undefined;
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
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage
            );
        }
    };
    /**
     * @function : handleStartAction
     * @description : This method is called on click of start button.
     */

    handleStartAction = event => {
        try {
            this.showMedicareDetails = true;
            this.sspBenefitId = event.detail.Id;
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
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage
            );
        }
    };
    /**
     * @function : hideCoverageDetails
     * @description : This method is called on dispatch of event from details page .
     */

    hideCoverageDetails = () => {
        try {
            this.showMedicareDetails = false;
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
            this.getCoverageDetails();
            window.scroll({
                top: 0,
                left: 0,
                behavior: "smooth"
            });
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage
            );
        }
    };

    /*
     * @function : getCoverageDetails
     * @description	: Function to fetch member details.
     * @param  {countOfBenefit}
     */
    getCoverageDetails = countOfBenefit => {
        try {
            this.showSpinner = true;
            getMedicalCoverageSummary({
                memberId: this.memberId
            })
                .then(result => {

                    this.constructRenderingAttributes(result.mapResponse); //2.5 Security Role Matrix and Program Access.

                    this.medicareCoverageSummaryWrapper = JSON.parse(
                        JSON.stringify(result.mapResponse.wrapper)
                    );
                    this.memberName = this.medicareCoverageSummaryWrapper[0].memberName;

                    this.medicareCoverageSummaryWrapper.forEach(wrapper => {
                        if(wrapper.benefit!==null ){
                        if (wrapper.benefit.BeginDate__c) {
                            wrapper.formattedBeginDate = wrapper.benefit[
                                "BeginDate__c"
                            ].replace(/(\d{4})-(\d{1,2})-(\d{1,2})/, function (
                                match,
                                y,
                                m,
                                d
                            ) {
                                return m + "/" + d + "/" + y;
                            });
                        }
                        wrapper.hideRemoveIcon =
                            !utility.isUndefinedOrNull(wrapper.benefit.Id) &&
                        (!utility.isUndefinedOrNull(wrapper.benefit.SSP_Member__r) && wrapper.benefit.SSP_Member__r.TBQIndividualVerificationCode__c) &&
                            !utility.isUndefinedOrNull(wrapper.benefit.DCId__c)
                                ? true
                                : false;
                             
                        this.mapOfIdAndBenefit.set(wrapper.benefit.Id, wrapper);
                        }
                    });
                    this.label.sspMedicareCoverageSummaryText = formatLabels(
                        sspMedicareCoverageSummaryText,
                        [this.memberName]
                    );
                    this.hasEmptyTiles = false;
                    this.showSpinner = false;
                    this.disableAddButton = this.medicareCoverageSummaryWrapper.length === 1
                                            && !(this.medicareCoverageSummaryWrapper[0].displayEdit);
                    if (countOfBenefit === 1) {
                        this.medicareCoverageSummaryWrapper = undefined;
                        this.disableAddButton = false;
                    }
                })
                .catch(error => {
                    console.error(
                        sspConstants.sspBenefitFields
                            .MedicareCoverageSummaryErrorMessage +
                            JSON.stringify(error)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
            this.showSpinner = false;
        }
    };
    /*
     * @function : handleRemoveAction
     * @description	: Method to remove SSP Benefit
     * @param  {event}
     */
    handleRemoveAction = event => {
        try {
            const removedBenefit = event.detail.Id;
            this.showSpinner = true;
            if (!utility.isUndefinedOrNull(removedBenefit)) {
                const countOfBenefit = this.medicareCoverageSummaryWrapper
                    .length;
                removeBenefit({
                    wrapper: JSON.stringify(
                        this.mapOfIdAndBenefit.get(removedBenefit)
                    ),
                    memberId:this.memberId,
                    applicationId : this.applicationId
                })
                    .then(result => {
                        this.getCoverageDetails(countOfBenefit);
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        console.error(
                            sspConstants.sspBenefitFields
                                .MedicareCoverageSummaryErrorMessage +
                                JSON.stringify(error)
                        );
                    });
            } else {
                this.medicareCoverageSummaryWrapper = undefined;
                this.disableAddButton = false;
            }
            this.showSpinner = false;
        } catch (error) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
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
        if (response != null && response != undefined && response.hasOwnProperty("securityMatrixSummary") && response.hasOwnProperty("securityMatrixDetails")) {
            const { securityMatrixSummary, securityMatrixDetails } = response;
            //code here
            this.isReadOnlyUser =
            !utility.isUndefinedOrNull(securityMatrixSummary) &&
            !utility.isUndefinedOrNull(securityMatrixSummary.screenPermission) &&
            securityMatrixSummary.screenPermission === apConstants.permission.readOnly;
    
            this.canDeleteMedicareCoverage =
            !utility.isUndefinedOrNull(securityMatrixSummary) &&
            !utility.isUndefinedOrNull(securityMatrixSummary.canDelete) &&
            !securityMatrixSummary.canDelete ? false : true;
    
            this.disableMedicareCoverageDetails =
            !utility.isUndefinedOrNull(securityMatrixDetails) &&
            !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
            securityMatrixDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

            this.isReadOnlyDetails =
            !utility.isUndefinedOrNull(securityMatrixDetails) &&
            !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
            securityMatrixDetails.screenPermission === apConstants.permission.readOnly;

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
        }
    }
    catch (error) {
        console.error(
            JSON.stringify(error.message)
        );
    }
};
}