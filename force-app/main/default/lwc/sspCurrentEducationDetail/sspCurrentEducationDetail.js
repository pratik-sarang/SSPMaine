/**
 * Name : SspCurrentEducationDetail.
 * Description : To add education details about house hold members.
 * Author : Ajay Saini.
 * Date : 11/12/2019.
 **/
import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import {
    getRecord,
    createRecord,
    updateRecord,
    getFieldValue,
    getFieldDisplayValue
} from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

import {
    orderInstitutionLevel,
    currentEducationDetail,
    events,
    programValues,
    toggleFieldValue
} from "c/sspConstants";

import { getYesNoOptions } from "c/sspUtility";
import saveButtonLabel from "@salesforce/label/c.SSP_Save";
import cancelButtonLabel from "@salesforce/label/c.SSP_Cancel";
import saveButtonAltText from "@salesforce/label/c.SSP_SaveEducationDetailAltText";
import cancelButtonAltText from "@salesforce/label/c.SSP_CancelEducationDetailAltText";

import instituteTypeLabel from "@salesforce/label/c.SSP_InstituteType";
import instituteNameLabel from "@salesforce/label/c.SSP_InstituteName";
import graduationDateLabel from "@salesforce/label/c.SSP_ExpectedGraduationDate";
import enrollmentTypeLabel from "@salesforce/label/c.SSP_IsFullTimeStudent";
import participateInWorkStudyProgramLabel from "@salesforce/label/c.SSP_ParticipateInWorkStudyProgram";
import assignedInstituteThroughProgramLabel from "@salesforce/label/c.SSP_AssignedInstituteThroughProgram";
import programCodeLabel from "@salesforce/label/c.SSP_WhichProgram";
import currentEducationDetailLabel from "@salesforce/label/c.SSP_CurrentEducationDetail";
import completeTheQuestionsLabel from "@salesforce/label/c.SSP_CompleteTheQuestionHighestEducation";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

import instituteTypeAltText from "@salesforce/label/c.SSP_InstituteTypeAltText";
import instituteNameAltText from "@salesforce/label/c.SSP_InstituteNameAltText";
import enrollmentTypeAltText from "@salesforce/label/c.SSP_IsFullTimeStudentAltText";
import assignedInstituteThroughProgramAltText from "@salesforce/label/c.SSP_AssignedInstituteThroughProgramAltText";

import instituteTypePlaceholder from "@salesforce/label/c.SSP_StartTyping";
import instituteNamePlaceholder from "@salesforce/label/c.SSP_StartTyping";
import graduationDatePlaceholder from "@salesforce/label/c.SSP_MMDDYYYY";

import ATTENDANCE_OBJECT from "@salesforce/schema/SSP_Attendance__c";
import MEMBER_ID from "@salesforce/schema/SSP_Attendance__c.SSP_Member__c";
import RECORD_ID from "@salesforce/schema/SSP_Attendance__c.Id";
import INSTITUTE_TYPE from "@salesforce/schema/SSP_Attendance__c.InstitutionSchoolTypeCode__c";
import GRADUATION_DATE from "@salesforce/schema/SSP_Attendance__c.ExpectedGraduationDate__c";
import INSTITUTE_NAME from "@salesforce/schema/SSP_Attendance__c.InstitutionSchoolName__c";
import INSTITUTESCHOOL_NAME from "@salesforce/schema/SSP_Attendance__c.School_Name__c";
import ENROLLMENT_TYPE from "@salesforce/schema/SSP_Attendance__c.EnrollmentTypeCode__c";
import PARTICIPATE_IN_WORK_STUDY_PROGRAM from "@salesforce/schema/SSP_Attendance__c.IsParticipatingInWorkStudyProgramToggle__c";
import ASSIGNED_INSTITUTE_THROUGH_PROGRAM from "@salesforce/schema/SSP_Attendance__c.IsAssignedToInstitutionProgramToggle__c";
import PROGRAM_CODE from "@salesforce/schema/SSP_Attendance__c.PlacedThroughProgramCode__c";
import SSP_APPLICATION from "@salesforce/schema/SSP_Attendance__c.SSP_Application__c";
import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import AGE from "@salesforce/schema/SSP_Member__c.Age__c";
import HAVE_SPECIAL_NEED from "@salesforce/schema/SSP_Member__c.SpecialNeedIndicatorToggle__c";

import fetchSchoolRecords from "@salesforce/apex/SSP_EducationController.fetchSchoolRecords";

import sspUtility from "c/sspUtility"; /* CD2	Security Role Matrix Sharon */
import constants from "c/sspConstants"; /* CD2	Security Role Matrix Sharon */

const unicorn0 = /\{0\}/g;
export default class SspCurrentEducationDetail extends BaseNavFlowPage {
    @api recordId;
    @api memberId;
    @api applicationId;
    @api isTeenParent;
    @api today;
    @api programsApplied = [];
    @track instituteTypePicklist = [];
    @track instituteNamePicklist = [];
    @track programCodePicklist = [];
    @track enrollmentTypePicklist = [];
    @track metaList;

    @track instituteName;
    @track instituteType;
    @track enrollmentType;
    @track graduationDate;
    @track instituteTypeDisplayValue;
    @track participatingInWorkStudyProgramToggleValue;
    @track assignedInstituteThroughProgramToggleValue;

    @track programCode;
    @track isBelowHighSchool;
    @track showToast = false;

    @track individualName;
    @track defaultRecordTypeId;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track sspApplicationIdTemp;
    @track showSpinner = false;

    toggleOptions = getYesNoOptions();

    memberFieldList = [
        FIRST_NAME,
        LAST_NAME,
        AGE,
        HAVE_SPECIAL_NEED
    ];

    recordFieldList = [
        RECORD_ID,
        MEMBER_ID,
        INSTITUTE_NAME,
        INSTITUTESCHOOL_NAME,
        INSTITUTE_TYPE,
        GRADUATION_DATE,
        ENROLLMENT_TYPE,
        PROGRAM_CODE,
        PARTICIPATE_IN_WORK_STUDY_PROGRAM,
        ASSIGNED_INSTITUTE_THROUGH_PROGRAM
    ];
    summaryTitle="";

    items = {
        instituteType: {
            ...INSTITUTE_TYPE,
            placeholder: instituteTypePlaceholder,
            title: instituteTypeAltText,
            label: instituteTypeLabel
        },
        graduationDate: {
            ...GRADUATION_DATE,
            placeholder: graduationDatePlaceholder,
            label: graduationDateLabel
        },
        instituteName: {
            ...INSTITUTE_NAME,
            placeholder: instituteNamePlaceholder,
            title: instituteNameAltText,
            label: instituteNameLabel
        },
        enrollmentType: {
            ...ENROLLMENT_TYPE,
            title: enrollmentTypeAltText,
            label: enrollmentTypeLabel
        },
        participatingInWorkStudyProgram: {
            ...PARTICIPATE_IN_WORK_STUDY_PROGRAM,
            label: participateInWorkStudyProgramLabel
        },
        assignedInstituteThroughProgram: {
            ...ASSIGNED_INSTITUTE_THROUGH_PROGRAM,
            title: assignedInstituteThroughProgramAltText,
            label: assignedInstituteThroughProgramLabel
        },
        programCode: {
            ...PROGRAM_CODE,
            label: programCodeLabel
        },
        saveButton: {
            label: saveButtonLabel,
            title: saveButtonAltText
        },
        cancelButton: {
            label: cancelButtonLabel,
            title: cancelButtonAltText
        },
        heading: {
            currentEducationDetailLabel,
            completeTheQuestionsLabel
        },
        label: {
            toastErrorText
        }
    };

    @api
    get MetadataList () {
        return this.baseMetaList;
    }
    set MetadataList (value) {
        if (value && !Array.isArray(value)) {
            this.baseMetaList = value;
            this.resetRequiredRules();
        }
    }

    @wire(getObjectInfo, {
        objectApiName: ATTENDANCE_OBJECT
    })
    fetchObjectInfo ({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error("Error in fetching object info: ", error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$defaultRecordTypeId",
        fieldApiName: INSTITUTE_TYPE
    })
    fetchInstituteTypePicklistValues ({ error, data }) {
        if (data) {
            this.instituteTypePicklist = data.values;
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$defaultRecordTypeId",
        fieldApiName: ENROLLMENT_TYPE
    })
    fetchEnrollmentTypePicklistValues ({ error, data }) {
        if (data) {
            this.enrollmentTypePicklist = data.values;
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$defaultRecordTypeId",
        fieldApiName: PROGRAM_CODE
    })
    fetchProgramCodePicklistValues ({ error, data }) {
        if (data) {
            this.programCodePicklist = data.values;
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(fetchSchoolRecords)
    fetchInstituteNamePicklistValues ({ data, error }) {
        if (data && data.mapResponse && data.mapResponse.schools) {
            this.instituteNamePicklist = data.mapResponse.schools.map(item => ({
                label: item.Name__c,
                value: item.Id
            }));
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: "$recordFieldList"
    })
    wiredGetRecord (value) {
        this.wiredRecord = value;
        const { data, error } = value;
        if (data) {
            this.record = data;
            this.updateRecordValues();
            this.resetRequiredRules();
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: "$memberFieldList"
    })
    wiredGetMember (value) {
        this.wiredMember = value;
        const { data, error } = value;
        if (data) {
            this.member = data;
            this.updateMemberValues();
            this.updateLabels();
            this.resetRequiredRules();
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    /**
     * @function connectedCallback
     * @description Retrieves the metadata for validations.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Current Education Details";
            const fieldList = Object.values(this.items)
                .filter(item => item.fieldApiName && item.objectApiName)
                .map(item => item.fieldApiName + "," + item.objectApiName);
            this.getMetadataDetails(
                fieldList,
                null,
                "SSP_APP_Details_CurrentEducationDetails"
            );
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }
    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }

    /**
     * @function setFieldsRequired
     * @description Alters the metadataList to set the fields as required
     *                  on the basis of programs applied and member's age.
     * @param {object} originalValue - Value of the new validation metadata.
     * @param {object} ranges - Dictionary containing age ranges.
     */
    setFieldsRequired (originalValue, ranges) {
        try {
            if (!originalValue) {
                return originalValue;
            }
            const value = JSON.parse(JSON.stringify(originalValue));
            const programsApplied = this.programsApplied || [];
            const age = getFieldValue(this.member, AGE);
            Object.keys(this.items || {}).forEach(itemKey => {
                const fieldApiName = this.items[itemKey].fieldApiName;
                const objectApiName = this.items[itemKey].objectApiName;
                if (fieldApiName && objectApiName) {
                    const metadataKey = fieldApiName + "," + objectApiName;
                    if (value[metadataKey] && ranges[itemKey]) {
                        value[metadataKey][
                            currentEducationDetail.inputRequiredField
                        ] = programsApplied.some(program =>
                            this.ageRangeTest(age, ranges[itemKey][program])
                        );
                    }
                }
            });
            return value;
        } catch (error) {
            console.error("Error in setFieldsRequired:", error);
        }
    }

    /**
     * @function resetRequiredRules
     * @description Re-evaluates the metadata for validations.
     */
    resetRequiredRules () {
        try {
            if (!this.baseMetaList) {
                return;
            }
            let metaList = this.setFieldsRequired(
                this.baseMetaList,
                currentEducationDetail.requiredAgeRanges
            );
            if (this.isBelowHighSchool) {
                metaList = this.setFieldsRequired(
                    metaList,
                    currentEducationDetail.requiredIfAgeRanges
                );
            }
            const programsApplied = this.programsApplied || [];
            const appliedForCC = programsApplied.includes(programValues.CC);
            if (appliedForCC && this.isTeenParent) {
                const enrollmentTypeKey =
                    this.items.enrollmentType.fieldApiName +
                    "," +
                    this.items.enrollmentType.objectApiName;
                metaList[enrollmentTypeKey][
                    currentEducationDetail.inputRequiredField
                ] = true;
            }

            this.metaList = metaList;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(this.metaList).length > 0){
                this.constructRenderingMap(null, this.metaList); 
            }
        } catch (error) {
            console.error("Error in resetRequiredRules:", error);
        }
    }

    /**
     * @function updateRecordValues
     * @description : Sets the required variables from the attendance record variables.
     */
    updateRecordValues () {
        try {
            const record = this.record;
            if (record) {
                this.instituteType = getFieldDisplayValue(
                    record,
                    INSTITUTE_TYPE
                );
                this.instituteName = !sspUtility.isUndefinedOrNull(getFieldValue(record, INSTITUTE_NAME)) ? getFieldValue(record, INSTITUTE_NAME) : getFieldValue(record, INSTITUTESCHOOL_NAME);
                this.enrollmentType = getFieldValue(record, ENROLLMENT_TYPE);
                this.graduationDate = getFieldValue(record, GRADUATION_DATE);
                this.participatingInWorkStudyProgramToggleValue = getFieldValue(
                    record,
                    PARTICIPATE_IN_WORK_STUDY_PROGRAM
                );
                this.assignedInstituteThroughProgramToggleValue = getFieldValue(
                    record,
                    ASSIGNED_INSTITUTE_THROUGH_PROGRAM
                );
                this.programCode = getFieldValue(record, PROGRAM_CODE);
                const level = orderInstitutionLevel.indexOf(
                    getFieldValue(record, INSTITUTE_TYPE)
                );
                this.isBelowHighSchool =
                    0 <= level &&
                    level <= currentEducationDetail.highSchoolInstitutionIndex;
            }
        } catch (error) {
            console.error("Error in updateRecordValues:", error);
        }
    }

    /**
     * @function updateMemberValues
     * @description Sets the required variables from the member record variables.
     */
    updateMemberValues () {
        try {
            const member = this.member;
            if (member) {
                this.individualName = [
                    getFieldValue(member, FIRST_NAME),
                    getFieldValue(member, LAST_NAME)
                ]
                    .filter(item => !!item)
                    .join(" ");
                this.haveSpecialNeeds = getFieldValue(
                    member,
                    HAVE_SPECIAL_NEED
                ) === "Y";
                if(this.haveSpecialNeeds) {
                    const programsApplied = JSON.parse(JSON.stringify(this.programsApplied || []));
                    const indexOfCC = programsApplied.indexOf(programValues.CC);
                    if(indexOfCC >= 0) {
                        programsApplied[indexOfCC] = "SP";
                        this.programsApplied = programsApplied;
                    }
                }
            }
        } catch (error) {
            console.error("Error in updateMemberValues:", error);
        }
    }

    /**
     * @function updateLabels
     * @description This method is used to update the labels.
     */
    updateLabels () {
        try {
            const name = this.individualName;
            if (name) {
                const items = JSON.parse(JSON.stringify(this.items));
                if (items.enrollmentType) {
                    items.enrollmentType.label = items.enrollmentType.label.replace(
                        unicorn0,
                        name
                    );
                }
                if (items.participatingInWorkStudyProgram) {
                    items.participatingInWorkStudyProgram.label = items.participatingInWorkStudyProgram.label.replace(
                        unicorn0,
                        name
                    );
                }
                if (items.assignedInstituteThroughProgram) {
                    items.assignedInstituteThroughProgram.label = items.assignedInstituteThroughProgram.label.replace(
                        unicorn0,
                        name
                    );
                }
                this.items = items;
            }
        } catch (error) {
            console.error("Error in updateLabels:", error);
        }
    }

    /**
     * @function handleInstituteTypeChange
     * @description Handles change in institute type and trigger change in items' visibility.
     * @param {object} event - This parameter provides the updated value.
     */
    handleInstituteTypeChange (event) {
        try {
            const value = event.detail.selectedValue;
            const level = orderInstitutionLevel.indexOf(value);
            this.isBelowHighSchool =
                -1 <= level && level <= currentEducationDetail.highSchoolInstitutionIndex;
            this.resetRequiredRules();
        } catch (error) {
            console.error("Error in handleInstituteTypeChange:", error);
        }
    }

    /**
     * @function handleParticipatingInWorkStudyProgramChange
     * @description Handles change in participatingInWorkStudyProgram.
     * @param {object} event - This parameter provides the updated value.
     */
    handleParticipatingInWorkStudyProgramChange (event) {
        try {
            this.participatingInWorkStudyProgramToggleValue =
                event.detail.value;
            if (!this.participatingInWorkStudyProgram) {
                this.assignedInstituteThroughProgramToggleValue =
                    toggleFieldValue.null;
                this.programCode = null;
            }
        } catch (error) {
            console.error(
                "Error in handleParticipatingInWorkStudyProgramChange:",
                error
            );
        }
    }

    /**
     * @function handleAssignedInstituteThroughProgramChange
     * @description Handles change in assignedInstituteThroughProgram.
     * @param {object} event - This parameter provides the updated value.
     */
    handleAssignedInstituteThroughProgramChange (event) {
        try {
            this.assignedInstituteThroughProgramToggleValue =
                event.detail.value;
            if (!this.assignedInstituteThroughProgram) {
                this.programCode = null;
            }
        } catch (error) {
            console.error(
                "Error in handleAssignedInstituteThroughProgramChange:",
                error
            );
        }
    }

    /**
     * @function handleSave
     * @description Handles data save operation.
     * @param {object} event - Event Object.
     */
    handleSave (event) {
        try {
            this.showSpinner = true;
            /* CD2	Security Role Matrix Sharon */
            if (this.isReadOnlyUser) {
                const saveEventReadOnly = new CustomEvent(events.saveDetail);
                this.dispatchEvent(saveEventReadOnly);
            }
            /* CD2	Security Role Matrix Sharon */
            else {
            event.preventDefault();
            event.stopImmediatePropagation();
            const inputElements = Array.from(
                this.template.querySelectorAll(".ssp-input")
            );
            const hasError = inputElements
                .map(element => element.ErrorMessages())
                .some(
                    errorList =>
                        Array.isArray(errorList) && errorList.length > 0
                );
            if (hasError) {
                this.showSpinner = false;
                if (!this.showToast) {
                    this.showToast = true;
                }
                return;
            }
            const updatedRecord = {
                [INSTITUTE_TYPE.fieldApiName]: null,
                [INSTITUTE_NAME.fieldApiName]: null,
                [GRADUATION_DATE.fieldApiName]: null,
                [ENROLLMENT_TYPE.fieldApiName]: null,
                [PROGRAM_CODE.fieldApiName]: null,
                [PARTICIPATE_IN_WORK_STUDY_PROGRAM.fieldApiName]:
                    toggleFieldValue.null,
                [ASSIGNED_INSTITUTE_THROUGH_PROGRAM.fieldApiName]:
                    toggleFieldValue.null,
                [SSP_APPLICATION.fieldApiName]: this.applicationId
            };
            for (const element of inputElements) {
                let value = element.value;
                if (
                    element.tagName.includes(currentEducationDetail.TYPEAHEAD)
                ) {
                    value = element.displaySelectedValue;
                }
                updatedRecord[element.fieldName] = value;
            }
            const saveEvent = new CustomEvent(events.saveDetail);

            // Review required for expense summary
                let programCheck;
                const revRules = [];                
                inputElements.forEach(key => {                                     
                    if(key.fieldName === "PlacedThroughProgramCode__c"){
                        const programValue = key.value;                        
                        if(programValue === "WIA" || programValue === "TAA"){
                            programCheck = true;
                        }
                        else{
                            programCheck = false;
                        }
                    }                    
                });
                const self = this;
                inputElements.forEach(function (key){
                    if (
                        key.fieldName ===
                        "IsParticipatingInWorkStudyProgramToggle__c"  
                    ) {                       
                        if ((key.oldValue !== key.value) &&
                            key.oldValue !== "Y"  && key.value === "Y" || programCheck === true 
                        ) {                            
                            revRules.push(
                                "work_study_change_true," +
                                    true +
                                    "," +
                                    self.memberId
                            );
                        }
                        else{                            
                            revRules.push(
                                "work_study_change_true," +
                                    false +
                                    "," +
                                    self.memberId
                                );
                            }                          
                    }
                });
                const sspApplicationId = new URL(
                    window.location.href
                ).searchParams.get("applicationId");
                //this.reviewRequiredList = revRules;
                this.sspApplicationIdTemp = sspApplicationId;

            if (this.recordId) {
                updatedRecord.Id = this.recordId;
                if (!sspUtility.isUndefinedOrNull(updatedRecord[INSTITUTE_NAME.fieldApiName])) {
                    const currentRecordInstituteName = updatedRecord[INSTITUTE_NAME.fieldApiName];
                    const hasSchoolId = typeof (currentRecordInstituteName) === "object" && currentRecordInstituteName.hasOwnProperty("value");
                    updatedRecord[INSTITUTE_NAME.fieldApiName] = hasSchoolId ? currentRecordInstituteName.value : currentRecordInstituteName;
                
                    const schoolRecord = this.instituteNamePicklist.find(
                        schoolValue => schoolValue.value === updatedRecord[INSTITUTE_NAME.fieldApiName]
                    );
                    updatedRecord[INSTITUTESCHOOL_NAME.fieldApiName] = !sspUtility.isUndefinedOrNull(schoolRecord) ? schoolRecord.label : "";
                } else {
                    updatedRecord[INSTITUTESCHOOL_NAME.fieldApiName] = this.instituteName;
                }
                updateRecord({
                    fields: updatedRecord
                })
                    .then(() => {
                        /*this.validateReviewRequiredRules(
                            sspApplicationId,
                            this.memberId,
                            ["SSP_APP_Details_CurrentEducationDetails"]
                        );*/
                        this.fireReviewRequiredEvent (revRules);
                        this.dispatchEvent(saveEvent);
                    })
                    .catch(error => {
                        console.error(JSON.parse(JSON.stringify(error)))
                        this.showSpinner = false;
                    });
            } else {
                updatedRecord[MEMBER_ID.fieldApiName] = this.memberId;
                createRecord({
                    apiName: ATTENDANCE_OBJECT.objectApiName,
                    fields: updatedRecord
                })
                    .then(() => {
                        /*this.validateReviewRequiredRules(
                            sspApplicationId,
                            this.memberId,
                            ["SSP_APP_Details_CurrentEducationDetails"]
                        );*/
                        this.fireReviewRequiredEvent (revRules);
                        this.dispatchEvent(saveEvent);
                    })
                    .catch(error => {
                        console.error(JSON.parse(JSON.stringify(error)))
                        this.showSpinner = false;
                    });
                }
            }            
        } catch (error) {
            console.error("Error in save", error);
            this.showSpinner = false;
        }
    }

    /**
 * @function fireReviewRequiredEvent
 * @description This method is used to fire review required from save function.
 * @param {string} reviewRules - Review rules.
 */
    fireReviewRequiredEvent (reviewRules) {
        const reviewRequiredRule = new CustomEvent(events.reviewWorkStudyProg, {
            detail: {
                revRules: reviewRules
            }
        });
        this.dispatchEvent(reviewRequiredRule);
    }

    /**
     * @function handleHideToast
     * @description This method is used to get notified when toast hides.
     */
    handleHideToast () {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    }

    /**
     * @function handleCancel
     * @description Closes the detail screen.
     * @param {object} event - Event Object.
     */
    handleCancel (event) {
        event.preventDefault();
        // event.stopImmediatePropagation();
        const cancelEvent = new CustomEvent(events.cancelDetail);
        this.dispatchEvent(cancelEvent);
    }

    /**
     * @function ageRangeTest
     * @description Checks if the given falls in any of the given age ranges.
     * @param {number} age - Age of the person.
     * @param {number[][]} ranges  - Array containing valid age ranges.
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
     * @function getItemVisibility
     * @description Checks if any item based in the age range dictionary should be visible or not.
     * @param {object} ageRanges - Dictionary of age ranges mapped against eligible programs.
     */
    getItemVisibility (ageRanges) {
        try {
            const age = getFieldValue(this.member, AGE);
            const programsApplied = this.programsApplied || [];
            return programsApplied.some(program =>
                this.ageRangeTest(age, ageRanges && ageRanges[program])
            );
        } catch (error) {
            console.error("Error in ageRangeTest:", error);
        }
    }

    get showInstituteType () {
        const visibility = this.getItemVisibility(
            currentEducationDetail.showAgeRanges.instituteType
        );
        const programsApplied = this.programsApplied || [];
        const finalVisibility =
            visibility ||
            (programsApplied.includes(programValues.CC) && this.haveSpecialNeeds);
        return finalVisibility;
    }

    get showGraduationDate () {
        const visible = this.getItemVisibility(
            currentEducationDetail.showAgeRanges.graduationDate
        );
        const conditionallyVisible = this.getItemVisibility(
            currentEducationDetail.showIfAgeRanges.graduationDate
        );
        const finalVisibility =
            visible || (conditionallyVisible && this.isBelowHighSchool);
        return finalVisibility;
    }

    get showInstituteName () {
        const visible = this.getItemVisibility(
            currentEducationDetail.showAgeRanges.instituteName
        );
        const conditionallyVisible = this.getItemVisibility(
            currentEducationDetail.showIfAgeRanges.instituteName
        );
        const finalVisibility =
            visible || (conditionallyVisible && this.isBelowHighSchool);
        return finalVisibility;
    }

    get showEnrollmentType () {
        const visible = this.getItemVisibility(
            currentEducationDetail.showAgeRanges.enrollmentType
        );
        const conditionallyVisible = this.getItemVisibility(
            currentEducationDetail.showIfAgeRanges.enrollmentType
        );
        const finalVisibility =
            visible || (conditionallyVisible && this.isBelowHighSchool);
        return finalVisibility;
    }

    get showParticipatingInWorkStudyProgram () {
        const visible = this.getItemVisibility(
            currentEducationDetail.showAgeRanges.participatingInWorkStudyProgram
        );
        const conditionallyVisible = this.getItemVisibility(
            currentEducationDetail.showIfAgeRanges
                .participatingInWorkStudyProgram
        );
        const finalVisibility =
            visible || (conditionallyVisible && this.isBelowHighSchool);
        return finalVisibility;
    }

    get showAssignedInstituteThroughProgram () {
        const programsApplied = this.programsApplied || [];
        const finalVisibility =
         ( ( this.showParticipatingInWorkStudyProgram &&
            this.participatingInWorkStudyProgram ) || (programsApplied.includes("KT") && getFieldValue(this.member, AGE)>15 && getFieldValue(this.member, AGE)<19 ))
        return finalVisibility;
    }

    get showProgramCodePicklist () {
        const finalVisibility =
            this.showAssignedInstituteThroughProgram &&
            this.assignedInstituteThroughProgram;
        return finalVisibility;
    }

    get participatingInWorkStudyProgram () {
        return (
            this.participatingInWorkStudyProgramToggleValue ===
            toggleFieldValue.yes
        );
    }

    get assignedInstituteThroughProgram () {
        return (
            this.assignedInstituteThroughProgramToggleValue ===
            toggleFieldValue.yes
        );
    }
    renderedCallback () {
        if(this.metaList && !this.metaList["ExpectedGraduationDate__c,SSP_Attendance__c"][
           "Input_Required__c"]
        ){
            const dateInputReference  = this.template.querySelector(".ssp-date-reference");
            if(dateInputReference){
            dateInputReference.ErrorMessages();
            }
        }
    }

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     * Sharon.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try {
            if (
                !sspUtility.isUndefinedOrNull(metaValue) &&
                Object.keys(metaValue).length > 0
            ) {
                const { securityMatrix } = this.constructVisibilityMatrix(
                    !sspUtility.isUndefinedOrNull(appPrograms) &&
                        appPrograms != ""
                        ? appPrograms
                        : []
                );
                //const { renderingMap, securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isReadOnlyUser =
                    securityMatrix.screenPermission ===
                    constants.permission.readOnly;
                //this.renderingMap = renderingMap;
                //this.showSpinner = false;
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === constants.permission.notAccessible);
                }
                if (!this.isPageAccessible) {
                    this.showAccessDeniedComponent = true;
                } else {
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in highestEducation.constructRenderingMap",
                error
            );
        }
    };
}