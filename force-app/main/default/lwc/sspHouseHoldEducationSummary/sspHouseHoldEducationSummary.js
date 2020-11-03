/**
 * Name : SspHouseHoldEducationSummary.
 * Description : To show and add education details about house hold members.
 * Author : Ajay Saini.
 * Date : 11/12/2019.
 **/
import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import {
    getRecord,
    deleteRecord,
    getFieldDisplayValue,
    getFieldValue,
    updateRecord
} from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { highestEducationDetail, events } from "c/sspConstants";

import currentEducation from "@salesforce/label/c.SSP_CurrentEducation";
import educationSummaryText from "@salesforce/label/c.SSP_EducationSummaryText";
import highestLevelEducationCompleted from "@salesforce/label/c.SSP_HighestLevelEducationCompleted";
import highestLevelEducation from "@salesforce/label/c.SSP_HighestLevelEducation";
import addCurrentEducation from "@salesforce/label/c.SSP_AddCurrentEducation";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import addEducationButtonTitleText from "@salesforce/label/c.SSP_AddEducationButtonTitleText";
import learnMoreEducationTitleText from "@salesforce/label/c.SSP_LearnMoreEducationTitleText";
import highestEducationStartTitle from "@salesforce/label/c.SSP_StartHighestEducationTitle";
import highestEducationEditTitle from "@salesforce/label/c.SSP_HightestEducationTileTitle";
import currentEducationEditTitle from "@salesforce/label/c.SSP_EditCurrentEducationAltText";
import educationDeleteTitle from "@salesforce/label/c.SSP_EducationDeleteTitle";
import highestEducationDeleteModalHeading from "@salesforce/label/c.SSP_HighestEducationDeleteModalHeading";
import currentEducationDeleteModalHeading from "@salesforce/label/c.SSP_CurrentEducationDeleteModalHeading";
import toastErrorText from "@salesforce/label/c.SSP_SummaryRecordValidatorMessage";
import cancel from "@salesforce/label/c.SSP_Cancel";
import sspViewDetails from "@salesforce/label/c.SSP_ViewDetails"; //Added by Chirag

import isTeenParent from "@salesforce/apex/SSP_EducationController.isTeenParent";
import fetchEducationDetail from "@salesforce/apex/SSP_EducationController.fetchEducationDetail";
import showHideRemoveIcon from "@salesforce/apex/SSP_EducationController.showHideRemoveIcon";
import getTimeTravelDate from "@salesforce/apex/SSP_Utility.today";

import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import AGE from "@salesforce/schema/SSP_Member__c.Age__c";
import HIGHEST_EDUCATION_LEVEL from "@salesforce/schema/SSP_Member__c.HighestEducationLevelCode__c";
import HIGHEST_EDUCATION_DATE from "@salesforce/schema/SSP_Member__c.HighestEducationGraduatedDate__c";
import IS_ENROLLED_IN_SCHOOL from "@salesforce/schema/SSP_Member__c.IsCurrentlyEnrolledInSchoolToggle__c";
import ATTENDANCEID_FIELD from "@salesforce/schema/SSP_Attendance__c.Id";
import ATTENDANCEISDELETED_FIELD from "@salesforce/schema/SSP_Attendance__c.IsDeleted__c";
//Added by Sharon as part of Security Matrix
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";

const unicorn0 = /\{0\}/g;
export default class SspHouseHoldEducationSummary extends BaseNavFlowPage {
    memberFields = [
        FIRST_NAME,
        LAST_NAME,
        AGE,
        HIGHEST_EDUCATION_LEVEL,
        HIGHEST_EDUCATION_DATE,
        IS_ENROLLED_IN_SCHOOL
    ];
    @api applicationId;
    @api memberId;
    @api showSpinner;
    @api mode;

    @track showHighestEducationScreen = false;
    @track showCurrentEducationScreen = false;
    @track showCurrentEducationStartTile = false;
    @track showCurrentEducationSection = false;
    @track isEnrolledInSchool = false;
    @track currentAttendanceRecordId;
    @track programsApplied = [];
    @track attendanceRecords = [];
    @track member;
    @track today = new Date();

    @track showLearnMore = false;
    @track showToast = false;

    @track highestEducationCardTitle;
    @track highestEducationCardSubtitle;
    @track modValue;
    @track reference=this;

    @track educationSummaryLabel = educationSummaryText;
    @track highestEducationEditTitle;
    @track hideHighestEducationTile = false;
    @track highestEducationRequired=false;
    @track isDataLoaded = false;

    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix. Sharon
    @track disableHighestEducationDetails = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track canDeleteHighestEducation = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track canDeleteCurrentEducation = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track disableCurrentEducationDetails = true; //CD2 2.5 Security Role Matrix and Highest Education. Sharon
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track isHighestDetailScreenReadOnly = false; //CD2 2.5 Security Role Matrix.
    @track isCurrentDetailScreenReadOnly = false; //CD2 2.5 Security Role Matrix.
    @track revRuleFired;
    @track viewButtonAltText1;
    displayAttendanceEdit = true;
    //Labels
    label = {
        currentEducation,
        highestLevelEducationCompleted,
        highestLevelEducation,
        addCurrentEducation,
        learnMoreLink,
        educationSummaryText,
        addEducationButtonTitleText,
        learnMoreEducationTitleText,
        highestEducationStartTitle,
        highestEducationEditTitle,
        currentEducationEditTitle,
        educationDeleteTitle,
        cancel,
        toastErrorText,
        highestEducationDeleteModalHeading,
        currentEducationDeleteModalHeading,
        sspViewDetails
    };

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (value) {
            this.nextValue = value;
            this.raiseErrorToast();
            this.reviewRequiredList = this.revRuleFired;
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

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
    }

    @wire(getTimeTravelDate)
    wiredGetToday (response) {
        const { data, error } = response;
        this.wiredTime = response;
        if (data) {
            this.today = new Date(data);
        } else if (error) {
            console.error("Error in wire wiredGetToday:", error);
        }
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: "$memberFields"
    })
    wiredGetMember (value) {
        try {
            this.wiredMember = value;
            const { error, data } = this.wiredMember;
            if (data) {
                this.member = data;
                const name = [
                    getFieldValue(this.member, FIRST_NAME),
                    getFieldValue(this.member, LAST_NAME)
                ]
                    .filter(item => !!item)
                    .join(" ");
                this.individualName = name;
                this.educationSummaryLabel = educationSummaryText.replace(
                    unicorn0,
                    name
                );
                this.highestEducationCardTitle =
                    getFieldDisplayValue(
                        this.member,
                        HIGHEST_EDUCATION_LEVEL
                    ) || this.label.highestLevelEducation;
                this.highestEducationCardSubtitle = getFieldDisplayValue(
                    this.member,
                    HIGHEST_EDUCATION_DATE
                );
                this.highestEducationEditTitle = this.label.highestEducationEditTitle.replace(
                    unicorn0,
                    this.highestEducationCardTitle
                );
                this.viewButtonAltText1 = this.label.sspViewDetails.replace(
                    unicorn0,
                    this.highestEducationCardTitle
                );
                const schoolEnrolled = getFieldValue(this.member, IS_ENROLLED_IN_SCHOOL);
                if(schoolEnrolled === "Y"){
                    this.isEnrolledInSchool = true;
                }
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
            this.showSpinner = false;
        } catch (error) {
            console.error("Error in wiredGetMember:", error);
        }
    }

    @wire(fetchEducationDetail, {
        memberId: "$memberId",
        applicationId: "$applicationId"
    })
    getEducationData (value) {
        try {
            this.wiredAttendanceRecords = value;
            const { error, data } = value;
            if (data) {
                const response = JSON.parse(JSON.stringify(data));
                if (response && response.mapResponse) {
                    this.programsApplied =
                        response.mapResponse.programsApplied || [];
                    this.updateCurrentEducationData(
                        response.mapResponse.attendanceRecords
                    );
                    this.evaluateIfHighestEducationDetailRequired();

                    /** CD2.5	Security Role Matrix Sharon. */
                    const { securityMatrixSummary, securityMatrixHighestDetails, securityMatrixCurrentDetails: securityMatrixCurrentDetail} = data.mapResponse;
                    /**CD2 2.5	Security Role Matrix Sharon. */
                    this.disableHighestEducationDetails =
                        !sspUtility.isUndefinedOrNull(securityMatrixHighestDetails) &&
                        !sspUtility.isUndefinedOrNull(
                            securityMatrixHighestDetails.screenPermission
                        ) &&
                        securityMatrixHighestDetails.screenPermission ===
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

                    this.isHighestDetailScreenReadOnly = !sspUtility.isUndefinedOrNull(securityMatrixHighestDetails) &&
                        !sspUtility.isUndefinedOrNull(
                            securityMatrixHighestDetails.screenPermission
                        ) &&
                        securityMatrixHighestDetails.screenPermission ===
                        sspConstants.permission.readOnly;

                    

                    this.isCurrentDetailScreenReadOnly = !sspUtility.isUndefinedOrNull(securityMatrixCurrentDetail) &&
                        !sspUtility.isUndefinedOrNull(
                            securityMatrixCurrentDetail.screenPermission
                        ) &&
                        securityMatrixCurrentDetail.screenPermission ===
                        sspConstants.permission.readOnly;
                    

                    this.canDeleteHighestEducation =
                        !sspUtility.isUndefinedOrNull(securityMatrixHighestDetails) &&
                        !sspUtility.isUndefinedOrNull(
                            securityMatrixHighestDetails.canDelete
                        ) &&
                            !securityMatrixHighestDetails.canDelete ? false : true;
                    /** */
                    this.disableCurrentEducationDetails =
                        !sspUtility.isUndefinedOrNull(securityMatrixCurrentDetail) &&
                        !sspUtility.isUndefinedOrNull(
                            securityMatrixCurrentDetail.screenPermission
                        ) &&
                        securityMatrixCurrentDetail.screenPermission ===
                            sspConstants.permission.notAccessible
                            ? true
                            : false;
                    this.canDeleteCurrentEducation =
                    !sspUtility.isUndefinedOrNull(securityMatrixCurrentDetail) &&
                    !sspUtility.isUndefinedOrNull(securityMatrixCurrentDetail.canDelete) &&
                    !securityMatrixCurrentDetail.canDelete ? false : true;

                    if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
                        this.isPageAccessible = true;
                    }
                    else {
                        this.isPageAccessible = !(securityMatrixSummary.screenPermission === sspConstants.permission.notAccessible);
                    }
                    if (!this.isPageAccessible) {
                        this.showAccessDeniedComponent = true;
                    } else {
                        this.showAccessDeniedComponent = false;
                    }
                    /** CD@ security Matrix end here Sharon. */  
                    this.dataFetched = true;
                }
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
            this.showSpinner = false;
        } catch (error) {
            console.error("Error in getEducationData", error);
        }
    }

    get isHighestEducationDataPresent () {
        return !!getFieldValue(this.member, HIGHEST_EDUCATION_LEVEL);
    }

    get isCurrentEducationDataPresent () {
        return !this.showCurrentEducationStartTile;
    }
    get hideHighestEducationDelete () {       
          return this.highestEducationRequired;
    }

    get showSummaryScreen () {
        return (
            this.showCurrentEducationScreen === false &&
            this.showHighestEducationScreen === false
        );
    }

    get highestEducationTileTitle () {
        if (this.isHighestEducationDataPresent) {
            return this.highestEducationEditTitle;
        }
        return this.label.highestEducationStartTitle;
    }
    get currentEducationTileTitle () {
        return "Current Education Details";
    }

    get currentEducationViewButtonTitle () {
        return this.label.sspViewDetails.replace(unicorn0, this.label.currentEducation);
    }

    get showCurrentEducationStartTileGetter (){ 
        this.showCurrentEducationStartTile = false;
        if((sspUtility.isUndefinedOrNull(this.attendanceRecords) || this.attendanceRecords.length===0) && this.isEnrolledInSchool){
            this.showCurrentEducationStartTile = true;
            return true;
        }
        if(this.mode==="RAC" && (sspUtility.isUndefinedOrNull(this.attendanceRecords) || this.attendanceRecords.length===0)){
            this.showCurrentEducationStartTile = false;
            return false;
        }
        return false;
    }


    /**
     * @function updateCurrentEducationData
     * @description Sets the required attributes from attendance records.
     * @param {object[]} records - List of attendance records.
     */
    updateCurrentEducationData (records) {
        try {
            const attendanceRecords = records || [];
            this.attendanceRecords = attendanceRecords.map(record => {
                const title =
                    sspUtility.isUndefinedOrNull(record.InstitutionSchoolName__c || record.InstitutionSchoolTypeCode__c) ? record.School_Name__c : record.InstitutionSchoolName__c ||
                    record.InstitutionSchoolTypeCode__c ||
                    this.label.currentEducation ||
                    this.label.currentEducation;
                const deleteAltText = this.label.educationDeleteTitle.replace(
                    unicorn0,
                    title
                );
                let buttonAltText = this.label.currentEducationEditTitle.replace(
                    unicorn0,
                    title
                );
                const viewButtonAltText = this.label.sspViewDetails.replace(unicorn0,
                    title);
                if (record.InstitutionSchoolName__c) {
                    buttonAltText = this.label.currentEducationEditTitle.replace(
                        unicorn0,
                        title
                    );
                }
                this.showCurrentEducationStartTile = false;
                return Object.assign(
                    {
                        title: title,
                        subtitle: record.EnrollmentTypeCode__c,
                        deleteAltText: deleteAltText,
                        buttonAltText: buttonAltText,
                        viewButtonAltText: viewButtonAltText
                    },
                    record
                );
            });
            if((sspUtility.isUndefinedOrNull(this.attendanceRecords) || this.attendanceRecords.length===0) && this.isEnrolledInSchool){
                this.showCurrentEducationStartTile = true;
            }
            if(this.mode==="RAC" && (sspUtility.isUndefinedOrNull(this.attendanceRecords) || this.attendanceRecords.length===0)){
                this.showCurrentEducationStartTile = false;
            }
        } catch (error) {
            console.error("Error in updateCurrentEducationData", error);
        }
    }

    /**
     * @function handleAttendanceAdd
     * @description Opens up current education screen to create new record.
     */
    handleAttendanceAdd () {
        try {
            this.currentAttendanceRecordId = null;
            this.showCurrentEducationScreen = true;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showCurrentEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAttendanceAdd", error);
        }
    }

    /**
     * @function handleAttendanceEdit
     * @description Opens up current education screen for editing.
     * @param {object} event - This parameter provides the updated value.
     */
    handleAttendanceEdit (event) {
        try {
            this.currentAttendanceRecordId = event.detail;
            this.showCurrentEducationScreen = true;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showCurrentEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAttendanceEdit", error);
        }
    }

    /**
     * @function handleAttendanceDelete
     * @description Deletes the attendance record.
     * @param {object} event - Event object.
     */
    handleAttendanceDelete (event) {
        try {
            const recordId = event.detail;
            const recordDCId = event.target.dataset.record;
            if (recordId && sspUtility.isUndefinedOrNull(recordDCId)) {
                this.showSpinner = true;
                deleteRecord(recordId).then(() =>
                    refreshApex(this.wiredAttendanceRecords)
                )
                .then(() => (this.showSpinner = false));
            } else if (recordId && !sspUtility.isUndefinedOrNull(recordDCId)){
                this.showSpinner = true;
                const currentEducationRecord = {};
                currentEducationRecord[ATTENDANCEID_FIELD.fieldApiName] = recordId;
                currentEducationRecord[ATTENDANCEISDELETED_FIELD.fieldApiName] = true;

                const recordInput = {};
                recordInput.fields = currentEducationRecord;
                updateRecord(recordInput).then(() =>
                    refreshApex(this.wiredAttendanceRecords)
                )
                .then(() => (this.showSpinner = false));
            }
        } catch (error) {
            console.error("Error in handleAttendanceDelete", error);
        }
    }

    /**
     * @function handleAttendanceSave
     * @description Handles the save operation. Closes the detail screen and
     * refreshes the record list.
     * @param {object} event - Event object.
     */
    handleAttendanceSave (event) {
        try {
            event.stopImmediatePropagation();
            this.showCurrentEducationScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showCurrentEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
            this.showSpinner = true;
            refreshApex(this.wiredAttendanceRecords)
            .then(() => (this.showSpinner = false));
        } catch (error) {
            console.error("Error in handleAttendanceSave", error);
        }
    }

    /**
     * @function handleAttendanceCancel
     * @description Closes the current education detail screen.
     */
    handleAttendanceCancel () {
        try {
            this.showCurrentEducationScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showCurrentEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAttendanceCancel", error);
        }
    }

    /**
     * @function handleHighestEducationEdit
     * @description Opens up highest education screen for editing.
     */
    handleHighestEducationEdit () {
        try {
            this.showHighestEducationScreen = true;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showHighestEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleHighestEducationEdit", error);
        }
    }

    /**
     * @function handleHighestEducationDelete
     * @description Clears highest education data present on member.
     */
    handleHighestEducationDelete () {
        try {
            const fields = {
                Id: this.memberId,
                [HIGHEST_EDUCATION_DATE.fieldApiName]: null,
                [HIGHEST_EDUCATION_LEVEL.fieldApiName]: null
            };
            this.showSpinner = true;
            updateRecord({ fields })
            .then(() => refreshApex(this.wiredMember))
            .then(() => {
                this.showSpinner = false;
                this.hideHighestEducationTile = true;
            });
        } catch (error) {
            console.error("Error in handleHighestEducationDelete", error);
        }
    }

    /**
     * @function handleHighestEducationSave
     * @description Closes the highest education detail screen and refreshes the data.
     * @param {object} event - Event object.
     */
    handleHighestEducationSave (event) {
        try {
            event.stopImmediatePropagation();
            this.showHighestEducationScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showHighestEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
            refreshApex(this.wiredMember)
            .then(() => (this.showSpinner = false));
        } catch (error) {
            console.error("Error in handleHighestEducationSave", error);
        }
    }

    /**
     * @function handleHighestEducationCancel
     * @description Closes the highest education screen.
     */
    handleHighestEducationCancel () {
        try {
            this.showHighestEducationScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showHighestEducationScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleHighestEducationCancel", error);
        }
    }

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
     * @function evaluateIfHighestEducationDetailRequired
     * @description Checks if highest education detail is required.
     */
    evaluateIfHighestEducationDetailRequired () {
        try {
            const programsApplied = this.programsApplied || [];
            const age = getFieldValue(this.member, AGE);
            const ranges =
                highestEducationDetail.requiredAgeRange.educationLevel;
            this.highestEducationRequired = programsApplied.some(program =>
                this.ageRangeTest(age, ranges[program])
            );
        } catch (error) {
            console.error(
                "Error in evaluateIfHighestEducationDetailRequired",
                error
            );
        }
    }

    /**
     * @function showHideRemoveIconOnHighestEducation
     * @description Checks if highest education detail is required.
     */
    showHideRemoveIconOnHighestEducation () {
        let bShowRemove = false;
        try{
            showHideRemoveIcon({
                applicationId : this.applicationId,
                memberId : this.memberId
            })
                .then(result => {                    
                    if (result.bIsSuccess === true){
                        bShowRemove = result.mapResponse.bShowRemoveIcon;
                        this.highestEducationRequired = !bShowRemove;
                        this.isDataLoaded = true;
                    }
                })
                .catch(error => {
                    console.error(
                        "Error in Education Summary" +
                        JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in Education Summary:", error);
        }        
    }

    /**
     * @function ageRangeTest
     * @description Checks if the given falls in any of the given age ranges.
     * @param {number} age - Age of the person.
     * @param {number[][]} ranges - Array containing valid age ranges.
     */
    ageRangeTest (age, ranges) {
        try {
            if (age === undefined || age === null || !ranges) {
                return false;
            }
            return ranges.some(range => {
                const [min, max] = range;
                return (
                    min !== undefined &&
                    min <= age &&
                    (max === undefined || age <= max)
                );
            });
        } catch (error) {
            console.error("Error in ageRangeTest:", error);
        }
    }

    /**
     * @function raiseErrorToast
     * @description Raises error toast if required.
     */
    raiseErrorToast () {
        try {
            if (!this.dataFetched) {
                return;
            }
            if (
                (!this.hideHighestEducationTile
                &&
                    !this.isHighestEducationDataPresent) || (!this.isCurrentEducationDataPresent)
            ) {
                const showToastEvent = new CustomEvent("showcustomtoast", {
                    bubbles: true,
                    composed: true
                });
                this.dispatchEvent(showToastEvent);
                this.templateInputsValue = "invalid";
                this.saveCompleted = false;
            } else {
                this.templateInputsValue = "valid";
                this.saveCompleted = true;
            }
        } catch (error) {
            console.error("Error in raiseErrorToast", error);
        }
    }

    /**
     * @function handleHideToast
     * @description Raises error toast if required.
     */
    handleHideToast () {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    }

    /**
     * @function connectedCallback
     * @description Fetch metadata for validations.
     */
    async connectedCallback () {
        try {
            refreshApex(this.wiredTime);
            this.showHideRemoveIconOnHighestEducation();
            this.showHelpContentData("SSP_APP_Details_EducationSummary");
            this.isTeenParent = await isTeenParent({
                applicationId: this.applicationId,
                memberId: this.memberId
            });
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    handleReviewRequiredRules (event){
        this.revRuleFired = event.detail.revRules;
    }
}
