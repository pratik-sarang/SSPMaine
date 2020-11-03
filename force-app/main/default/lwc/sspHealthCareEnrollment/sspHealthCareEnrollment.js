/**
 * Component Name - sspHealthCareEnrollment.js.
 * Author         - Chaitanya Kanakia, Ashwin Kasture.
 * Description    - Use to get and show the Insurance Policy along with its Covered Individuals details.
 * Date       	  - 12/04/2019.
 */
import { track, api } from "lwc";
import sspHealthCareEnrollTitle from "@salesforce/label/c.SSP_HealthCareEnrollTitle";
import sspHealthCareEnrollDesc from "@salesforce/label/c.SSP_HealthCareEnrollDesc";
import sspRequired from "@salesforce/label/c.SSP_Required";
import sspHealthCareEnrollAddCover from "@salesforce/label/c.SSP_HealthCareEnrollAddCov";
import sspHealthCareEnrollAddCoverAlt from "@salesforce/label/c.SSP_HealthCareEnrollAddCovAlt";

import sspEditButtonAlt from "@salesforce/label/c.SSP_EditButtonAlt";
import sspStartButtonAlt from "@salesforce/label/c.SSP_StartButtonAlt";

import sspApplicationSummary from "@salesforce/label/c.SSP_ApplicationSummary";
import sspHealthCareEnrollPolicyId from "@salesforce/label/c.SSP_HealthCareEnrollPolicyId";

import sspHealthCareEnrollPolicyHolder from "@salesforce/label/c.SSP_HealthCareEnrollPolicyHolder";
import sspHealthCareEnrollCoveredInd from "@salesforce/label/c.SSP_HealthCareEnrollCoveredInd";
import sspHealthCareEnrollCoverage from "@salesforce/label/c.SSP_HealthCareEnrollCoverage";

import sspDeleteEnrollment from "@salesforce/label/c.SSP_DeleteEnrollment";
import sspDeleteIndividualEnrollment from "@salesforce/label/c.SSP_DeleteIndividualEnrollment";
import sspDeleteAccess from "@salesforce/label/c.SSP_DeleteAccess";
import sspDeleteIndividualAccess from "@salesforce/label/c.SSP_DeleteIndividualAccess";

import getHealthEnrollmentSummary from "@salesforce/apex/SSP_HealthEnrollmentSummaryCtrl.getHealthEnrollmentSummary";
import removeInsuranceCoverInd from "@salesforce/apex/SSP_HealthEnrollmentSummaryCtrl.removeInsuranceCovInd";
import removeInsurancePolicy from "@salesforce/apex/SSP_HealthEnrollmentSummaryCtrl.removeInsurancePolicy";
import updatePolicyDetails from "@salesforce/apex/SSP_HealthEnrollmentSummaryCtrl.updateTrackDeletion";
import storeHealthCoverageData from "@salesforce/apex/SSP_HealthCoverageSelectionCtrl.storeHealthCoverageData";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";

import sspHealthCareAccessDesc from "@salesforce/label/c.sspHealthCareAccessDesc";
import sspRemoveHealthCareModalHeader from "@salesforce/label/c.SSP_HealthCare_RemoveModal_Header";
import sspHeaderAccessHealthcareCoverageModal from "@salesforce/label/c.SSP_HeaderAccessHealthcareCoverageModal";

import { formatLabels, getYesNoOptions } from "c/sspUtility";
import utility from "c/sspUtility";
import apConstants from "c/sspConstants";
import sspBaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspViewDetails from "@salesforce/label/c.SSP_ViewDetails";
const noValue = getYesNoOptions()[1].value;
export default class SspHealthCareEnrollment extends sspBaseNavFlowPage {
    @api isEnrolledInInsurance;
    @api mode;
    
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
        }
    }

    /**
     * @function : nextEvent.
     * @description : Getter setter methods for nextEvent.
     */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (
            value !== undefined &&
            value !== "" &&
            ((this.healthEnrollmentSummaryList !== undefined &&
                this.healthEnrollmentSummaryList.length > 0 &&
                this.isCoveredHealthFacilityExistList.length > 0 &&
                this.isCoveredHealthFacilityExistList.filter(function (item) {
                    return item === true;
                }).length === this.isCoveredHealthFacilityExistList.length) ||
                this.defaultTitleRemove)
        ) {
            this.nextValue = value;
            this.saveData();
        } else if (value !== undefined && value !== "") {
            const showToastEvent = new CustomEvent("showcustomtoast", {
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(showToastEvent);
            this.templateInputsValue = "invalid";
        }
    }

    /**
     * @function : allowSaveData.
     * @description : Getter setter methods for allowSaveData.
     */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
    }

    /**
     * @function : appId.
     * @description : Getter setter methods for appId.
     */
    @api
    get appId () {
        return this.applicationId;
    }
    set appId (value) {
        try {
            this.showSpinner = true;
            this.applicationId = value;
            this.getPolicyData(this.applicationId);
        } catch (error) {
            console.error(
                "Error occurred in appId of Enrollment in HealthCare Coverage Summary page" +
                    JSON.stringify(error)
            );
        }
    }

    @track memberIdValue;
    @track enrolledSource = true;
    @track healthEnrollmentSummaryList = [];
    @track applicationId = "";
    @track insurancePolicyId = "";
    @track openModelForExist = false;
    @track showEnrollmentDetails = false;
    @track showIndividualEnrollment = false;
    @track showHealthCareEnrollment = true;
    @track isCoveredIndDeletion = true;
    @track isPolicyDeletion = false;
    @track sspCoveredIndividualId;
    @track showToast = false;
    @track hideToast;
    @track sPolicyHolderFullName;
    @track sCoveredIndFullName;
    @track editButtonAlt;
    @track startButtonAlt;
    @track showSpinner = false;
    @track defaultAltTextForStart = "";
    @track defaultAltTextForView = "";
    @track isEnrolled = false;    
    @track removeModalPolicyHeader = "";
    @track removeModalIndividualHeader = "";
    @track isReadOnlyUserEnrollment = false;  //CD2 2.5 Security Role Matrix.
    @track isReadOnlyEnrollment = false; //CD2 2.5 Security Role Matrix.
    @track canDeleteEnrollment = false; //CD2 2.5 Security Role Matrix.
    @track canDeleteIndividualEnrollment = true; //CD2 2.5 Security Role Matrix.
    @track disableEnrollment = false; //CD2 2.5 Security Role Matrix.
    @track disableIndividualEnrollment = false; //CD2 2.5 Security Role Matrix.
    @track canDelete = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track isReadOnlyIndividualEnrollment = false; //CD2 2.5 Security Role Matrix.

    isCoveredHealthFacilityExistList = [];
    @track label = {
        sspHealthCareEnrollTitle,
        sspHealthCareEnrollDesc,
        sspHealthCareEnrollPolicyId,
        sspRequired,
        sspHealthCareEnrollAddCover,
        sspApplicationSummary,
        sspHealthCareEnrollPolicyHolder,
        sspHealthCareEnrollCoveredInd,
        sspHealthCareEnrollCoverage,
        sspDeleteEnrollment,
        sspDeleteIndividualEnrollment,
        sspDeleteAccess,
        sspDeleteIndividualAccess,
        sspHealthCareEnrollAddCoverAlt,
        sspEditButtonAlt,
        sspStartButtonAlt,
        sspSummaryRecordValidator,
        sspHealthCareAccessDesc,
        sspRemoveHealthCareModalHeader,
        sspHeaderAccessHealthcareCoverageModal
    };
    defaultTitleRemove = false;

    get screenRenderingStatus () {
        return this.showHealthCareEnrollment && !this.isNotAccessible;
    }

    get enrollmentCanDelete () {
        return !this.canDelete;
    }

    get addButtonRenderingStatus () {
        return this.isReadOnlyEnrollment || this.disableEnrollment;
    }

    /**
     * @function : connectedCallback.
     * @description : Fire an event from connectedCallback to update the header in flow.
     */
    connectedCallback () {
        let headerValue;
        this.editButtonAlt = formatLabels(sspEditButtonAlt, [
            this.sPolicyHolderFullName
        ]);
        this.startButtonAlt = formatLabels(sspStartButtonAlt, [
            this.sPolicyHolderFullName
        ]);
        if (this.isEnrolledInInsurance === "true") {
            headerValue = apConstants.pageHeaders.enrollmentHealthCoverage;
            this.isEnrolled = true;
            this.removeModalPolicyHeader = this.label.sspDeleteEnrollment;
            this.removeModalIndividualHeader = this.label.sspDeleteIndividualEnrollment;
        } else {
            headerValue = apConstants.pageHeaders.accessToHealthCoverage;
            this.isEnrolled = false;
            this.removeModalPolicyHeader = formatLabels(this.label.sspHeaderAccessHealthcareCoverageModal, [
                headerValue
            ]);
            this.removeModalIndividualHeader = this.label.sspDeleteIndividualAccess;
        }
        this.label.sspHeaderAccessHealthcareCoverageModal = formatLabels(this.label.sspHeaderAccessHealthcareCoverageModal, [
            headerValue
        ]);
        const healthCareHeader = new CustomEvent(
            apConstants.events.updateHeader,
            {
                bubbles: true,
                composed: true,
                detail: {
                    header: headerValue
                }
            }
        );
        this.dispatchEvent(healthCareHeader);
    }

    /**
     * @function : saveData.
     * @description : Gets the elements by class and allow to save.
     */
    saveData = () => {
        const templateAppInputs = this.template.querySelectorAll(
            ".ssp-healthCareEnrollPolicyCont"
        );
        this.templateInputsValue = templateAppInputs;
        this.saveCompleted = true;
    };

    /**
     * @function : showHealthCareEnrollmentScreen.
     * @description : Hide the HealthCare Summary Screen.
     */
    showHealthCareEnrollmentScreen = () => {
        if (
            this.showEnrollmentDetailScreen === true ||
            this.showIndividualEnrollment === true
        ) {
            this.showHealthCareEnrollment = false;
        } else {
            this.showHealthCareEnrollment = true;
        }
    };

    /**
     * @function : getPolicyData.
     * @description : Get the Enrollment Summary Value from Server.
     * @param {string} sApplicationId - Contains Application Id.
     */
    getPolicyData = sApplicationId => {
        try {
            getHealthEnrollmentSummary({
                sApplicationId: sApplicationId,
                bIsEnrolledInInsurance: this.isEnrolledInInsurance
            })
                .then(result => {
                    if (result.bIsSuccess) {

                        this.constructRenderingAttributes(result.mapResponse); //2.5 Security Role Matrix and Program Access.

                        this.healthEnrollmentSummaryList =
                            result.mapResponse.healthEnrollmentSummaryList
                                .length > 0
                                ? JSON.parse(
                                      JSON.stringify(
                                          result.mapResponse
                                              .healthEnrollmentSummaryList
                                      )
                                  )
                                : undefined;

                        this.assignDefaultPlanTitle();
                        this.showSpinner = false;
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in handleConditions of Enrollment in HealthCare Coverage Summary page" +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "error occurred in fetching PolicyData on page health care enrollment" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : updatePolicyData.
     * @description : Updates the Policy Details.
     * @param {object{}} event - Gives the current element value.
     */
    updatePolicyData = event => {
        try {
            this.showSpinner = true;
            updatePolicyDetails({
                sTrackDeletionWrapperData: JSON.stringify(
                    event.detail.objTrackDeletion
                )
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.getPolicyData(this.applicationId);
                        this.showSpinner = false;
                    } else {
                        console.error(
                            "error occurred in updatePolicyData on page health care enrollment"
                        );
                        this.showSpinner = false;
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "error occurred in updatePolicyData on page health care enrollment" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function - removeInsurancePolicy.
     * @description - This method use to remove the Insurance policy.
     * @param {*} event - Fired on selection of member.
     */
    removeInsurancePolicy = event => {
        this.showSpinner = true;
        try {
            const policyId = event.detail.sInsurancePolicyId;
            if (policyId !== undefined && policyId !== "") {
                removeInsurancePolicy({
                    sInsurancePolicyId: policyId,
                    sAppId : this.applicationId
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                            const removePolicyResponse =
                                result.mapResponse.removeInsurancePolicy;
                            const insurancePolicyId =
                                removePolicyResponse.insurancePolicyId;
                            for (
                                let index = 0;
                                index < this.healthEnrollmentSummaryList.length;
                                index++
                            ) {
                                if (
                                    insurancePolicyId ===
                                    this.healthEnrollmentSummaryList[index]
                                        .sInsurancePolicyId
                                ) {
                                    this.healthEnrollmentSummaryList.splice(
                                        index,
                                        1
                                    );
                                    break;
                                }
                            }
                            if (this.healthEnrollmentSummaryList <= 0) {
                                this.defaultTitleRemove = true;
                                const objHealthSelectionInfo = {};
                                objHealthSelectionInfo.sApplId = this.applicationId;
                                objHealthSelectionInfo.sEnrolledInHealthCareCoverage = this.isEnrolledInInsurance === "true" ? noValue : null;
                                objHealthSelectionInfo.sNotEnrolledInHealthCareCoverage = this.isEnrolledInInsurance === "false" ? noValue : null;
                                objHealthSelectionInfo.sMedicaidType = null;
                                objHealthSelectionInfo.sMemberId = null;
                                objHealthSelectionInfo.sProgramsApplied = null;
                                this.storeHealthCoverageMethod(
                                    objHealthSelectionInfo
                                );
                            } else {
                                
                                this.assignDefaultPlanTitle();
                            }
                        } else if (!result.bIsSuccess) {
                            console.error(
                                "Error occurred in removeInsurancePolicy of Enrollment in HealthCare Coverage Summary page " +
                                    result.mapResponse.ERROR
                            );
                        }
                    })
                    .catch({});
            }
        } catch (error) {
            console.error(
                "error occurred in removeInsurancePolicy on page health care enrollment" +
                    JSON.stringify(error)
            );
        }
        this.showSpinner = false;
    };

    /**
     * @function - removeInsuranceCoverInd.
     * @description - This method use to remove the Insurance Covered Individual.
     * @param {*} event - Fired on selection of member.
     */
    removeInsuranceCoverInd = event => {
        this.showSpinner = true;
        try {
            const coveredIndId = event.detail;
            removeInsuranceCoverInd({
                sInsuranceCoverIndId: coveredIndId,
                sAppId: this.applicationId
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        const policyMemberId =
                            result.mapResponse.removeInsuranceCoverInd
                                .insurancePolicyId;
                        const coveredIndividualId =
                            result.mapResponse.removeInsuranceCoverInd
                                .coveredIndividual;

                        this.healthEnrollmentSummaryList.forEach(element => {
                            if (policyMemberId === element.sInsurancePolicyId) {
                                for (
                                    let index = 0;
                                    index < element.lstCoverInd.length;
                                    index++
                                ) {
                                    const coverIndividual =
                                        element.lstCoverInd[index];
                                    if (
                                        coverIndividual.sCoveredIndId ===
                                        coveredIndividualId
                                    ) {
                                        element.lstCoverInd.splice(index, 1);
                                        break;
                                    }
                                }
                            }
                        });
                        this.assignDefaultPlanTitle();
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in removeInsuranceCoverInd of Enrollment in HealthCare Coverage Summary page. " +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in removeInsuranceCoverInd of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error)
            );
        }
        this.showSpinner = false;
    };

    /**
     * @function - showEnrollmentDetailScreen.
     * @description - This method use to show enrollment detail screen.
     */
    showEnrollmentDetailScreen = () => {
        try {
            this.showEnrollmentDetails = true;

            this.showHealthCareEnrollment = false;

            this.insurancePolicyId = "";

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
                "Error occurred in showEnrollmentDetailScreen of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - hideEnrollmentDetailsScreen.
     * @description - This method use to hide enrollment detail screen.
     */
    hideEnrollmentDetailsScreen = () => {
        try {
            this.showEnrollmentDetails = false;
            this.showHealthCareEnrollment = true;
            this.insurancePolicyId = "";

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
        } catch (error) {
            console.error(
                "Error occurred in hideEnrollmentDetailsScreen of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - showIndividualEnrollmentScreen.
     * @description - This method use to show Individual enrollment detail screen.
     */
    showIndividualEnrollmentScreen = () => {
        try {
            this.showIndividualEnrollment = true;
            this.showHealthCareEnrollment = false;
            this.showEnrollmentDetails = false;

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
                "Error occurred in showIndividualEnrollmentScreen of sspHealthCareEnrollment screen" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - showEnrollmentSummaryScreen.
     * @description - Handles Event fired from sspEnrollmentDetails component.
     */

    showEnrollmentSummaryScreen = () => {
        try {
            this.getPolicyData(this.applicationId);
            this.showHealthCareEnrollment = true;
            this.showIndividualEnrollment = false;
            this.showEnrollmentDetails = false;

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
        } catch (error) {
            console.error(
                "Error occurred in showEnrollmentSummary of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - buttonClick.
     * @description - Handles button click of Insurance Policy Title.
     * @param {object{}} event - Gives the event parameter value.
     */
    buttonClick = event => {
        try {
            this.showEnrollmentDetailScreen();
            if (
                event.detail !== null &&
                event.detail.sInsurancePolicyId !== undefined
            ) {
                this.insurancePolicyId = event.detail.sInsurancePolicyId;
            }
        } catch (error) {
            console.error(
                "Error occurred in buttonClick of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleClick.
     * @description - Handles click of Policy Holder Title.
     * @param {object{}} event - Contains the event parameter.
     */
    handleClick = event => {
        try {
            this.sspCoveredIndividualId = event.detail;
            this.showIndividualEnrollmentScreen();
        } catch (error) {
            console.error(
                "Error occurred in buttonClick of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - assignDefaultPlanTitle.
     * @description - Use to set the Default Title when no Plan name exists for Insurance policy.
     *              - To remove the lstCoverInd list when we get Default data.
     */
    assignDefaultPlanTitle = () => {
        try {
            this.isCoveredHealthFacilityExistList = [];
            if (
                this.healthEnrollmentSummaryList !== undefined &&
                this.healthEnrollmentSummaryList.length > 0
            ) {
                this.healthEnrollmentSummaryList.forEach(element => {
                    // In below condition we set the Default title if Policy name is empty
                    if (
                        element.sPlanName === undefined ||
                        element.sPlanName === ""
                    ) {
                        element.sPlanName = this.label.sspHealthCareEnrollCoverage;
                    }

                    // Below condition, use to set the Start/Edit button Alt Text for Policy Holder.
                    if (element.bPolicyHolderIsHealthFacilityExist) {
                        element.sPolicyHolderFullName = formatLabels(
                            sspEditButtonAlt,
                            [
                                element.sPolicyHolderFirstName +
                                    " " +
                                    element.sPolicyHolderLastName
                            ]
                        );
                        element.viewButtonAlt = formatLabels(
                            sspViewDetails,
                            [
                                element.sPolicyHolderFirstName +
                                " " +
                                element.sPolicyHolderLastName
                            ]
                        );
                        this.isCoveredHealthFacilityExistList.push(
                            element.bPolicyHolderIsHealthFacilityExist
                        );
                    } else if (
                        element.sPolicyHolderFirstName !== undefined &&
                        element.sPolicyHolderFirstName !== ""
                    ) {
                        element.sPolicyHolderFullName = formatLabels(
                            sspStartButtonAlt,
                            [
                                element.sPolicyHolderFirstName +
                                    " " +
                                    element.sPolicyHolderLastName
                            ]
                        );
                        element.viewButtonAlt = formatLabels(
                            sspViewDetails,
                            [
                                element.sPolicyHolderFirstName +
                                    " " +
                                    element.sPolicyHolderLastName
                            ]
                        );
                        this.isCoveredHealthFacilityExistList.push(
                            element.bPolicyHolderIsHealthFacilityExist
                        );
                    }

                    if (
                        element.lstCoverInd !== undefined &&
                        element.lstCoverInd.length > 0
                    ) {
                        for (
                            let index = 0;
                            index < element.lstCoverInd.length;
                            index++
                        ) {
                            const coverIndElement = element.lstCoverInd[index];
                            // In below condition we remove the IsDefault record from the Wrapper List
                            if (
                                coverIndElement.bIsDefault !== undefined &&
                                coverIndElement.bIsDefault
                            ) {
                                element.lstCoverInd.splice(index, 1);
                                index--;
                            } else {
                                // Below condition, use to set the Start/Edit button Alt Text for Covered Individual.
                                coverIndElement.sCoveredIndFullName = coverIndElement.bIsCoveredHealthFacilityExist
                                    ? formatLabels(sspEditButtonAlt, [
                                          coverIndElement.sCoveredIndFirstName +
                                              " " +
                                              coverIndElement.sCoveredIndLastName
                                      ])
                                    : formatLabels(sspStartButtonAlt, [
                                          coverIndElement.sCoveredIndFirstName +
                                              " " +
                                              coverIndElement.sCoveredIndLastName
                                      ]);
                                coverIndElement.viewButtonAltText = formatLabels(sspViewDetails, [
                                    coverIndElement.sCoveredIndFirstName +
                                    " " +
                                    coverIndElement.sCoveredIndLastName
                                ]);
                                // Alternate Text for remove icon for covered Individual
                                coverIndElement.removeAltCoverIndText =
                                    coverIndElement.sCoveredIndFirstName +
                                    " " +
                                    coverIndElement.sCoveredIndLastName;

                                this.isCoveredHealthFacilityExistList.push(
                                    coverIndElement.bIsCoveredHealthFacilityExist
                                );
                            }
                        }
                    }
                    // Condition to add true in "isCoveredHealthFacilityExistList" list so to redirect screen to next screen.
                    if (
                        element.sPolicyHolderId === "" ||
                        element.sPolicyHolderId === undefined ||
                        element.lstCoverInd === undefined ||
                        element.lstCoverInd.length <= 0
                    ) {
                        this.isCoveredHealthFacilityExistList.push(true);
                    }
                    // In this block we Check the Progress Of Summary Screen Completed Records.
                    if (
                        this.isCoveredHealthFacilityExistList.length > 0 &&
                        this.isCoveredHealthFacilityExistList.includes(false)
                    ) {
                        element.progressChecked = false;
                    } else {
                        element.progressChecked = true;
                    }
                });
            }
            // Below condition, use to set the Start button Alt Text for Default title.
            this.defaultAltTextForStart = formatLabels(sspStartButtonAlt, [
                this.label.sspHealthCareEnrollCoverage
            ]);
            this.defaultAltTextForView = formatLabels(sspViewDetails, [
                this.label.sspHealthCareEnrollCoverage
            ]);
        } catch (error) {
            console.error(
                "Error occurred in assignDefaultPlanTitle of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - removeCoverageModal.
     * @description - Use to Open popup modal.
     */
    removeCoverageModal = () => {
        try {
            this.openModelForExist = true;
        } catch (error) {
            console.error(
                "Error occurred in removeCoverageModal of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleHideIndividualEnrollmentDetails.
     * @description - Use to hide Individual Enrollment screen.
     */
    handleHideIndividualEnrollmentDetails = () => {
        try {
            this.showIndividualEnrollment = false;
            this.getPolicyData(this.applicationId);
            this.showHealthCareEnrollment = true;

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
        } catch (error) {
            console.error(
                "Error occurred in handleHideIndividualEnrollmentDetails of Enrollment in HealthCare Coverage Summary" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function handleHideToast
     * @description Raises error toast if required.
     */
    handleHideToast = () => {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };
    /**
     * @function hideDefaultTitle
     * @description : Method hide the default tiles.
     */
    hideDefaultTitle = () => {
        try {
            const objHealthSelectionInfo = {};
            objHealthSelectionInfo.sApplId = this.applicationId;
            objHealthSelectionInfo.sEnrolledInHealthCareCoverage =
                this.isEnrolledInInsurance === "true"
                    ? noValue
                    : null;
            objHealthSelectionInfo.sNotEnrolledInHealthCareCoverage =
                this.isEnrolledInInsurance === "false"
                    ? noValue
                    : null;
            objHealthSelectionInfo.sMedicaidType = null;
            objHealthSelectionInfo.sMemberId = null;
            objHealthSelectionInfo.sProgramsApplied = null;
            this.storeHealthCoverageMethod(
                objHealthSelectionInfo
            );
            const defaultTile = this.template.querySelector(".ssp-defaultTile");
            defaultTile.classList.add("slds-hide");
            const defaultBtn = this.template.querySelector(
                ".ssp-defaultAddCoverageBtn"
            );
            defaultBtn.disabled = false;
            this.defaultTitleRemove = true;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };
	
   /**
   * @function - reviewRequiredAction.
   * @description - Method to handle review required screen.
   * @param {*} event - Fired on change of policy holder.
   */
    reviewRequiredAction = event => {
        this.reviewRequiredList = event.detail;
    };
    
    /**
     * @function - storeHealthCoverageMethod()
     * @description - This method use to store Health Coverage Selection data on Application Object.
     * @param {object} objHealthSelectionInfo - Health Selection Object.
     */
    storeHealthCoverageMethod = (objHealthSelectionInfo) => {
        try {
            storeHealthCoverageData({
                sMemberHealthCoverageData: JSON.stringify(
                    objHealthSelectionInfo
                )
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        //this.saveCompleted = true;
                    } else if (result.bIsSuccess === false) {
                        console.error(
                            "Error occurred in storeHealthCoverageData in HealthCare Coverage Summary page" +
                            result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in storeHealthCoverageData in HealthCare Coverage Summary page" +
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
            if (response != null && response != undefined) {
                //For Enrollment Summary & Details
                if (this.isEnrolledInInsurance === "true" && response.hasOwnProperty("securityMatrixEnrollmentSummary") && response.hasOwnProperty("securityMatrixEnrollmentDetails") && response.hasOwnProperty("securityMatrixEnrollmentDetails")){
                    const { securityMatrixEnrollmentSummary, securityMatrixEnrollmentDetails, securityMatrixEnrollmentIndividualDetails } = response;
                    //code here
                    if (!securityMatrixEnrollmentSummary || !securityMatrixEnrollmentSummary.hasOwnProperty("screenPermission") || !securityMatrixEnrollmentSummary.screenPermission) {
                        this.isNotAccessible = false;
                    }
                    else {
                        this.isNotAccessible = securityMatrixEnrollmentSummary.screenPermission === apConstants.permission.notAccessible;
                    }
                    if (this.isNotAccessible) {
                        this.showAccessDeniedComponent = true;
                    }
                    else {
                        this.showAccessDeniedComponent = false;
                    }

                    this.isReadOnlyUserEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentSummary) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentSummary.screenPermission) &&
                        securityMatrixEnrollmentSummary.screenPermission === apConstants.permission.readOnly;

                    this.isReadOnlyEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails.screenPermission) &&
                        securityMatrixEnrollmentDetails.screenPermission === apConstants.permission.readOnly;

                    this.isReadOnlyIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails.screenPermission) &&
                        securityMatrixEnrollmentIndividualDetails.screenPermission === apConstants.permission.readOnly;

                    this.canDeleteEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails.canDelete) &&
                        securityMatrixEnrollmentDetails.canDelete;

                    this.canDeleteIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails.canDelete) &&
                        securityMatrixEnrollmentIndividualDetails.canDelete;

                    this.disableEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentDetails.screenPermission) &&
                        securityMatrixEnrollmentDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

                    this.disableIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentIndividualDetails.screenPermission) &&
                        securityMatrixEnrollmentIndividualDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

                    this.canDeleteEnrollment = !this.canDeleteEnrollment;

                    this.canDelete = !utility.isUndefinedOrNull(securityMatrixEnrollmentSummary) && 
                        !utility.isUndefinedOrNull(securityMatrixEnrollmentSummary.canDelete) &&
                        !securityMatrixEnrollmentSummary.canDelete?false:true;
                }
                //For Access Summary & Details
                else if (response.hasOwnProperty("securityMatrixAccessSummary") && response.hasOwnProperty("securityMatrixAccessDetails") && response.hasOwnProperty("securityMatrixAccessIndividualDetails")){
                    const { securityMatrixAccessSummary, securityMatrixAccessDetails, securityMatrixAccessIndividualDetails } = response;
                    //code here

                    if (!securityMatrixAccessSummary || !securityMatrixAccessSummary.hasOwnProperty("screenPermission") || !securityMatrixAccessSummary.screenPermission) {
                        this.isNotAccessible = false;
                    }
                    else {
                        this.isNotAccessible = securityMatrixAccessSummary.screenPermission === apConstants.permission.notAccessible;
                    }
                    if (this.isNotAccessible) {
                        this.showAccessDeniedComponent = true;
                    }
                    else{
                        this.showAccessDeniedComponent = false;
                    }

                    this.isReadOnlyUserEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessSummary) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixAccessSummary.screenPermission) &&
                        securityMatrixAccessSummary.screenPermission === apConstants.permission.readOnly;

                    this.isReadOnlyEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixAccessDetails.screenPermission) &&
                        securityMatrixAccessDetails.screenPermission === apConstants.permission.readOnly;

                    this.isReadOnlyIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails.screenPermission) &&
                        securityMatrixAccessIndividualDetails.screenPermission === apConstants.permission.readOnly;

                    this.canDeleteEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessDetails) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixAccessDetails.canDelete) &&
                        securityMatrixAccessDetails.canDelete;

                    this.canDeleteEnrollment = !this.canDeleteEnrollment; 

                    this.canDeleteIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails) && //Not using this attribute
                        !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails.canDelete) &&
                        securityMatrixAccessIndividualDetails.canDelete;
                    
                    this.disableEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixAccessDetails.screenPermission) &&
                        securityMatrixAccessDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

                    this.disableIndividualEnrollment = !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails) &&
                        !utility.isUndefinedOrNull(securityMatrixAccessIndividualDetails.screenPermission) &&
                        securityMatrixAccessIndividualDetails.screenPermission === apConstants.permission.notAccessible ? true : false;

                    this.canDelete = !utility.isUndefinedOrNull(securityMatrixAccessSummary) &&
                        !utility.isUndefinedOrNull(securityMatrixAccessSummary.canDelete) &&
                        !securityMatrixAccessSummary.canDelete?false:true;

                    
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