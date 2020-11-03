/*
 * Component Name: sspOutOfStateBenefitsSummary
 * Author: Kyathi, Sai Kiran
 * Description: This screen shows the summary of Benefits Out of State Details.
 * Date: 11/12/2019.
 */
import { track, api } from "lwc";
import sspConstants from "c/sspConstants";
import sspAddStateBenefitButton from "@salesforce/label/c.SSP_AddStateBenefitBtn";
import sspOutOfStateBenefitsSummaryText from "@salesforce/label/c.SSP_OutOfStateBenefitsSummaryText";
import sspStart from "@salesforce/label/c.SSP_StartButton";
import sspEdit from "@salesforce/label/c.SSP_EditButton";
import sspRemoveModalHeading from "@salesforce/label/c.SSP_RemoveBenefitModalHeading";
import sspOutOfStateBenefits from "@salesforce/label/c.SSP_OutOfStateBenefits";
import sspBenefitSummary from "@salesforce/apex/SSP_AnotherStateBenefitsCtrl.fetchAnotherStateBenefits";
import deleteBenefitData from "@salesforce/apex/SSP_AnotherStateBenefitsCtrl.removeBenefitData";
import updateMemberData from "@salesforce/apex/SSP_AnotherStateBenefitsCtrl.updateMemberData";
import utility, {
    formatLabels,
    getCurrentMonthName,
    getNextMonthName
} from "c/sspUtility";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import programConstant from "c/sspConstants";
import sspBenefitsEditButtonTitle from "@salesforce/label/c.SSP_BenefitsEditButtonTitle";
import sspBenefitsViewButtonTitle from "@salesforce/label/c.SSP_BenefitsViewButtonTitle";
import sspAddBenefitButtonAltText from "@salesforce/label/c.SSP_AddBenefitButtonAltText";
import sspBenefitsRemoveButtonTitle from "@salesforce/label/c.SSP_BenefitsRemoveButtonTitle";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidatorMessage";
import sspDeleteBenefitsAnotherState from "@salesforce/label/c.sspDeleteBenefitsAnotherState";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

export default class sspBenefitsFromAnotherStateSummary extends BaseNavFlowPage {
    @api memberName;
    @api flowName;
    @track showSpinner = false;
    @track hasSaveValidationError = false;
    @track appId;
    @track nextValue;
    @track actionCheck;
    @track isCountyValue;
    @track objBenefitData;
    @track memberIdValue;
    @track timeTravelTodayDate;
    @track timeTravelCurrentMonth;
    @track sspOutOfStateBenefitsSummaryText;
    @track trueValue = true;
    @track falseValue = false;
    @track showBenefitDetails = false;
    @track disableAddButton = false;
    @track isDeleteSuccess = false;
    @track updateHasBenefitCheckOnMember = false;
    @track sspBenefits = [];
    @track isReadOnlyUser = false;  //CD2 2.5 Security Role Matrix.
    @track canDeleteStateBenefit = true; //CD2 2.5 Security Role Matrix.
    @track disableStateBenefitDetails = false; //CD2 2.5 Security Role Matrix.
    @track isScreenNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspBenefitsViewButtonTitle,
        sspSummaryRecordValidator,
        toastErrorText,
        sspAddBenefitButtonAltText,
        sspBenefitsEditButtonTitle,
        sspAddStateBenefitButton,
        sspStart,
        sspEdit,
        sspRemoveModalHeading,
        sspOutOfStateBenefits,
        sspBenefitsRemoveButtonTitle,
        sspDeleteBenefitsAnotherState
    };

    get screenRenderingStatus () {
        if(this.isScreenNotAccessible){
            return true;
        }
        return this.showBenefitDetails; 
    }

    get buttonRenderingStatus () {
        return !(this.isReadOnlyUser || this.disableStateBenefitDetails);
    }

    get getDisableStatus () {
        return this.disableAddButton;
    }

    /**
     * @function 	: memberId.
     * @description : This attribute is part of validation framework which gives the Member ID.
     * */
    @api
    get memberId () {
        return this.memberIdValue;
    }
    set memberId (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.memberIdValue = value;
            this.fetchBenefitsData(this.memberIdValue);
        }
    }

    /**
     * @function 	: nextEvent.
     * @description : This attribute is part of validation framework which is used to navigate to next Screen.
     * */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.saveData(); // use to check validations on component
            }
        } catch (error) {
            console.error(
                "Error in nextEvent of Another State Benefits Summary:" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function 	: allowSaveData.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.validationFlag = value;
            this.saveCompleted = true;
        }
    }

    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.MetaDataListParent = value;
        }
    }

    /**
     * @function 	: applicationId.
     * @description : This attribute is part of validation framework which gives the application ID.
     * */
    @api
    get applicationId () {
        return this.appId;
    }
    set applicationId (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.appId = value;
        }
    }
    /**
     * @function : connectedCallback
     * @description : This method is fetch the benefit records on Load.
     */

    connectedCallback () {
        try {
            this.disableAddButton = true;
        } catch (error) {
            console.error(
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
        }
    }
    /**
     * @function : fetchBenefitsData
     * @description : Function used to fetch to Benefit Records.
     * @param   {memberId} memberId - Member ID.
     */

    fetchBenefitsData (memberId) {
        try {
            this.showSpinner = true;
            sspBenefitSummary({
                sMemberId: memberId
            })
                .then(result => {

                    this.constructRenderingAttributes(result.mapResponse); //2.5Security Role Matrix and Program Access. 
                    const objBenefit = result.mapResponse.lstBenefitsWrapper;
                    if (objBenefit.length === 0) {
                        this.disableAddButton = true;
                    } else {
                        this.disableAddButton = false;
                    }
                    this.sspBenefits = objBenefit;
                    this.timeTravelTodayDate =
                        result.mapResponse.timeTravelTodayDate;
                    this.timeTravelCurrentMonth =
                        result.mapResponse.timeTravelCurrentMonth;
                    if (this.timeTravelCurrentMonth) {
                        this.sspOutOfStateBenefitsSummaryText = formatLabels(
                            sspOutOfStateBenefitsSummaryText,
                            [
                                this.memberName,
                                getCurrentMonthName(this.timeTravelCurrentMonth - 1),
                                getNextMonthName(this.timeTravelCurrentMonth - 1)
                            ]
                        );
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error("### Error in Benefit Summary ---->" + error);
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }
    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                programConstant.sspBenefitFields
                    .MedicareCoverageSummaryErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleClick
     * @description : Function used to navigate to Benefit Details Page when user Click on 'Add Benefit' button.
     */
    handleClick () {
        try {
            this.showBenefitDetails = true;
            const objBenefitData = {};
            this.actionCheck = false;
            this.objBenefitData = objBenefitData;
            this.objBenefitData.sMemberId = this.memberIdValue;
            this.objBenefitData.bSnapCheck = false;
            this.objBenefitData.bTanfCheck = false;
            this.objBenefitData.bMedicaidCheck = false;
            const hideFrameworkEvent = new CustomEvent(
                programConstant.events.hideSection,
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
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
        }
    }
    /**
     * @function : handleStartAction
     * @description : On click on the start/edit buttons, this navigates to the details page.
     * @param {event} event - Event Details.
     */
    handleStartAction (event) {
        try {
            this.showBenefitDetails = true;
            const objBenefitData = {};
            if (event.detail !== null) {
                this.actionCheck = true;
                objBenefitData.dBenefitSNAPEndDate =
                    event.detail.dBenefitSNAPEndDate;
                objBenefitData.dBenefitSNAPStartDate =
                    event.detail.dBenefitSNAPStartDate;
                objBenefitData.dBenefitTANFEndDate =
                    event.detail.dBenefitTANFEndDate;
                objBenefitData.dBenefitTANFStartDate =
                    event.detail.dBenefitTANFStartDate;
                objBenefitData.dBenefitMEDICADEEndDate =
                    event.detail.dBenefitMEDICADEEndDate;
                objBenefitData.dBenefitMEDICADEStartDate =
                    event.detail.dBenefitMEDICADEStartDate;
                objBenefitData.sBenefitCounty = event.detail.sBenefitCounty;
                objBenefitData.sBenefitProgram = event.detail.sBenefitProgram;
                objBenefitData.sMemberId = event.detail.sMemberId;
                objBenefitData.sBenefitSNAPId = event.detail.sBenefitSNAPId;
                objBenefitData.sBenefitTANFId = event.detail.sBenefitTANFId;
                objBenefitData.sBenefitMEDICAIDId =
                    event.detail.sBenefitMEDICAIDId;
                objBenefitData.sBenefitState = event.detail.sBenefitState;
                objBenefitData.sBenefitUniqueKey =
                    event.detail.sBenefitUniqueKey;
                objBenefitData.sBenefitStateLabel =
                    event.detail.sBenefitStateLabel;
                this.objBenefitData = objBenefitData;
                this.objBenefitData.bSnapCheck = JSON.stringify(
                    event.detail.sBenefitProgram
                ).includes(programConstant.programValues.SN);
                this.objBenefitData.bTanfCheck = JSON.stringify(
                    event.detail.sBenefitProgram
                ).includes(programConstant.programValues.TN);
                this.objBenefitData.bMedicaidCheck = JSON.stringify(
                    event.detail.sBenefitProgram
                ).includes(programConstant.programValues.MA);
            } else {
                this.actionCheck = false;
                this.objBenefitData = objBenefitData;
                this.objBenefitData.sMemberId = this.memberIdValue;
                this.objBenefitData.bSnapCheck = false;
                this.objBenefitData.bTanfCheck = false;
                this.objBenefitData.bMedicaidCheck = false;
            }
            const hideFrameworkEvent = new CustomEvent(
                programConstant.events.hideSection,
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
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
        }
    }
    /**
     * @function : handleRemoveAction
     * @description : Opens pop-up to delete Records.
     * @param {event} event - Event Details.
     */
    handleRemoveAction (event) {
        try {
            this.showSpinner = true;
            event.currentTarget.classList.add("slds-hide");
            if (event.detail === null) {
                this.disableAddButton = false;
                this.updateHasBenefitCheckOnMember = true;
            }
            if (event.detail !== null) {
                this.objBenefitData = event.detail;
                deleteBenefitData({
                    sBenefitIds: JSON.stringify(
                        this.objBenefitData.sBenefitIds
                    ),
                    sMemberId: this.memberIdValue
                })
                    .then(result => {
                        this.isDeleteSuccess = result.bIsSuccess;
                        const updatedList =
                            result.mapResponse.updatedListBenefits;
                        if (updatedList.length > 0) {
                            this.updateHasBenefitCheckOnMember = true;
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.error(
                            "### Error While Deleting Data ###" + error
                        );
                        this.showSpinner = false;
                    });
            }
            if (this.updateHasBenefitCheckOnMember) {
                this.showSpinner = false;
                this.updateMemberData(this.memberIdValue);
            }
        } catch (error) {
            console.error(
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }
    /**
     * @function 	: saveData.
     * @description : This function is part of validation framework which indicates data is valid or not.
     * */
    saveData () {
        if (this.disableAddButton) {
            this.hasSaveValidationError = true;
        } else {
            this.templateInputsValue = this.template.querySelectorAll(
                ".ssp-benefitsSummaryInputs"
            );
        }
    }
    /**
     * @function 	: updateMemberData.
     * @description : This function is used to Update the field on Member Object.
     * @param  {string} sMemberId - Member id parameter.
     * */
    updateMemberData (sMemberId) {
        updateMemberData({ sMemberId: sMemberId })
            .then(result => {})
            .catch(error => {
                console.error(
                    "### Error While updating Member Data ###" + error
                );
            });
    }
    /**
     * @function : hideBenefitDetails
     * @description : function used to Hide Benefit details page.
     */
    hideBenefitDetails () {
        try {
            this.showBenefitDetails = false;
            this.fetchBenefitsData(this.memberIdValue);
            const hideFrameworkEvent = new CustomEvent(
                programConstant.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: false
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error(
                "Error occurred in Benefit Summary page" + JSON.stringify(error)
            );
        }
    }

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
                if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
                    this.isScreenNotAccessible = false;
                }
                else {
                    this.isScreenNotAccessible = securityMatrixSummary.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isScreenNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                this.isReadOnlyUser =
                    !utility.isUndefinedOrNull(securityMatrixDetails) &&
                !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
                securityMatrixDetails.screenPermission === sspConstants.permission.readOnly;

                this.canDeleteStateBenefit  =
                    !utility.isUndefinedOrNull(securityMatrixSummary) &&
                !utility.isUndefinedOrNull(securityMatrixSummary.canDelete) &&
                !securityMatrixSummary.canDelete ? false:true;

                this.disableStateBenefitDetails  =
                    !utility.isUndefinedOrNull(securityMatrixDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
                        securityMatrixDetails.screenPermission === sspConstants.permission.notAccessible ? true : false;
            }
        }
        catch (error) {
            console.error(
                JSON.stringify(error.message)
            );
        }
    };
}