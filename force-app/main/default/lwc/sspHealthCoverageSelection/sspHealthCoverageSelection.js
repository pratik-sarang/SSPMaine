/**
 * Component Name - sspHealthCoverageSelection.js.
 * Author         - Chaitanya Kanakia, Ashwin Kasture.
 * Description    - This screen takes the input for Health selection gatepost questions.
 * Date       	  - 11/12/2019.
 */
import { api, track } from "lwc";
import sspHealthCoverSelectionTitle from "@salesforce/label/c.SSP_HealthCovSelectionTitle";
import sspHealthCoverSelectionDesc from "@salesforce/label/c.SSP_HealthCovSelectionDesc";
import sspHealthCoverSelectionEnrolled from "@salesforce/label/c.SSP_HealthCovSelectionEnrolled";
import sspHealthCoverSelectionEmployer from "@salesforce/label/c.SSP_HealthCovSelectionEmployer";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspHealthCoverSelectionLearnMoreContent from "@salesforce/label/c.SSP_HealthCovSelectionLearnMoreContent";
import sspHealthCoverSelectionLabel from "@salesforce/label/c.SSP_HealthCovSelectionLabel";
import sspHealthCoverSelectionLearnMoreModal from "@salesforce/label/c.SSP_HealthCovSelectionLearnMoreModal";

import getHealthCoverageData from "@salesforce/apex/SSP_HealthCoverageSelectionCtrl.getHealthCoverageData";
import storeHealthCoverageData from "@salesforce/apex/SSP_HealthCoverageSelectionCtrl.storeHealthCoverageData";
import sspBaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspConstants from "c/sspConstants";
import utility, { getYesNoOptions } from "c/sspUtility";

export default class SspHealthCoverageSelection extends sspBaseNavFlowPage {
    @api memberId;

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
                "Error in nextEvent of Health care Coverage Selection Page" +
                    error
            );
        }
    }
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
     * @function 	: allowSaveData.
     * @description : This attribute is part of validation framework which indicates data is valid or not.
     * */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.storeHealthCoverageMethod();
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
        this.MetaDataListParent = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
        if (Object.keys(value).length > 0) {
            this.constructRenderingMap(null, value);
        }
    }

    /**
     * @function 	: appId.
     * @description : This attribute is part of validation framework which gives the application ID.
     * */
    @api
    get appId () {
        return this.applicationId;
    }
    set appId (value) {
        this.applicationId = value;
        this.getHealthCoverageData();
    }

    @track applicationId;
    @track MetaDataListParent;
    @track objHealthSelectionInfo = {};
    @track sEnrolledInHealthCoverageValue = "";
    @track sNotEnrolledInHealthCoverageValue = "";
    @track sEnrolledInHealthCoverageErrorMsg = "";
    @track sNotEnrolledInHealthCoverageErrorMsg = "";
    @track isToShowEnrolledInHealthCoverage = false;
    @track isToShowNotEnrolledInHealthCoverage = false;
    @track isLearnMoreModal = false;
    @track showSpinner = false;
    @track optList = getYesNoOptions();
    @track modValue;
    @track reference = this;
    @track bIsEnrollmentApproved;
    @track bIsAccessApproved;
    @track isScreenNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false;
    label = {
        sspHealthCoverSelectionTitle,
        sspHealthCoverSelectionDesc,
        sspHealthCoverSelectionEnrolled,
        sspHealthCoverSelectionEmployer,
        sspLearnMoreLink,
        sspHealthCoverSelectionLearnMoreContent,
        sspHealthCoverSelectionLabel,
        sspHealthCoverSelectionLearnMoreModal
    };
    

    /**
     * @function - openLearnMoreModal().
     * @description - This method is used to display the modal when user clicks on learn more link.
     */
    openLearnMoreModal = () => {
        this.isLearnMoreModal = true;
    };

    /**
     * @function - closeLearnMoreModal()
     * @description - This method is used close Learn More Modal.
     */
    closeLearnMoreModal = () => {
        this.isLearnMoreModal = false;
    };

    /**
     * @function - saveData()
     * @description - This method use to send component element to base component.
     */
    saveData = () => {
        try {
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.templateInputsValue = templateAppInputs;
        } catch (error) {
            console.error(
                "Error occurred in saveData of Health Coverage Selection page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - connectedCallback()
     * @description - This method use to send Field/Object list to getMetadataDetails() method in Base component.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.showHelpContentData("SSP_APP_HealthCare_Select");
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.sspHealthCoverageSelection.sspApplicationObject
                    .enrolledInHealthCareCoverageFieldApi +
                    "," +
                    sspConstants.sspHealthCoverageSelection.sspApplicationObject
                        .objectApi,
                sspConstants.sspHealthCoverageSelection.sspApplicationObject
                    .notEnrolledInHealthCareCoverageFieldApi +
                    "," +
                    sspConstants.sspHealthCoverageSelection.sspApplicationObject
                        .objectApi
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                sspConstants.sspHealthCoverageSelection.screenId
            );            

            const healthCareHeader = new CustomEvent(
                sspConstants.events.updateHeader,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        header:
                            sspConstants.pageHeaders.healthCareSelectionHeader
                    }
                }
            );
            this.dispatchEvent(healthCareHeader);
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback of Health Coverage Selection page" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function - connectedCallback()
     * @description - This method use to send Field/Object list to getMetadataDetails() method in Base component.
     */
    renderedCallback () {
        const sectionReference = this.template.querySelector(".ssp-learnMore");
        if (sectionReference) {
            // eslint-disable-next-line @lwc/lwc/no-inner-html
            sectionReference.innerHTML = this.modValue.HelpModal__c;
        }
    }

    /**
     * @function - getHealthCoverageData()
     * @description - This method use to fetch and render the Health Coverage data.
     */
    getHealthCoverageData = () => {
        try {
            getHealthCoverageData({
                sApplicationId: this.applicationId,
                sMemberId: this.memberId
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.objHealthSelectionInfo =
                            result.mapResponse.healthCoverageData[0];

                        if (this.objHealthSelectionInfo !== undefined) {
              if (
                  result.mapResponse.enrollmentApproved !== undefined &&
                  result.mapResponse.enrollmentApproved !== ""
              ) {
                  this.bIsEnrollmentApproved =
                      result.mapResponse.enrollmentApproved;
              }
              if (
                  result.mapResponse.accessApproved !== undefined &&
                  result.mapResponse.accessApproved !== ""
              ) {
                  this.bIsAccessApproved = result.mapResponse.accessApproved;
              }
                            let lstPrograms = [];
                            if (
                                this.objHealthSelectionInfo.sProgramsApplied !==
                                    undefined &&
                                this.objHealthSelectionInfo.sProgramsApplied !==
                                    ""
                            ) {
                                lstPrograms = this.objHealthSelectionInfo.sProgramsApplied.split(
                                    ";"
                                );
                            }
                            if (
                                lstPrograms.indexOf(
                                    sspConstants.programValues.KP
                                ) !== -1 ||
                                lstPrograms.indexOf(
                                    sspConstants.programValues.MA
                                ) !== -1
                            ) {
                                this.isToShowEnrolledInHealthCoverage = true;
                            }
                            if (
                                lstPrograms.indexOf(
                                    sspConstants.programValues.KP
                                ) !== -1 ||
                                lstPrograms.indexOf(
                                    sspConstants.programValues.MA
                                ) !== -1
                            ) {
                                this.isToShowNotEnrolledInHealthCoverage = true;
                            }
                        }
                        this.showSpinner = false;
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in getHealthCoverageData of Health Coverage Selection page. " +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in getHealthCoverageData on health coverage page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - toggleCondition()
     * @description - This method use to set the Yes/No value to track variable on click of Yes/No button.
     * @param {*} event - Fired on selection of member.
     */
    toggleCondition = event => {
        try {
            const question = event.target.dataset.question;
            const dataValue = event.detail.value;
            // For 1st Enrolled Question
            if (
                question ===
                sspConstants.sspHealthCoverageSelection.sEnrolledQuestion
            ) {
                this.objHealthSelectionInfo.sEnrolledInHealthCareCoverage = dataValue;
            }
            // For 2nd Not Enrolled Question
            if (
                question ===
                sspConstants.sspHealthCoverageSelection.sNotEnrolledQuestion
            ) {
                this.objHealthSelectionInfo.sNotEnrolledInHealthCareCoverage = dataValue;
            }
        } catch (error) {
            console.error(
                "Error occurred in toggleCondition on health coverage page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - storeHealthCoverageMethod()
     * @description - This method use to store Health Coverage Selection data on Application Object.
     */
    storeHealthCoverageMethod = () => {
        try {
            storeHealthCoverageData({
                sMemberHealthCoverageData: JSON.stringify(
                    this.objHealthSelectionInfo
                )
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.saveCompleted = true;
                    } else if (result.bIsSuccess === false) {
                        console.error(
                            "Error occurred in handleConditions of health selection page. " +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in storeHealthCoverageData on health coverage page" +
                    JSON.stringify(error)
            );
        }
        
    };

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
    */
    constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isScreenNotAccessible = false;
                }
                else {
                    this.isScreenNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isScreenNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in highestEducation.constructRenderingMap", error
            );
        }
    }
}
