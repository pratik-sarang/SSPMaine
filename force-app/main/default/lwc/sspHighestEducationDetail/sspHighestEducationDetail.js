/**
 * Component Name: SspHighestEducationDetail.
 * Author: Ajay Saini.
 * Description: Screen component for highest education detail screen.
 * Date: DEC-10-2019.
 */

import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { refreshApex } from "@salesforce/apex";
import sspUtility from "c/sspUtility"; /* CD2	Security Role Matrix Sharon */
import constants from "c/sspConstants"; /* CD2	Security Role Matrix Sharon */
import {
    getRecord,
    updateRecord,
    getFieldValue,
    getFieldDisplayValue
} from "lightning/uiRecordApi";

import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";

import {
    events,
    genericIds,
    orderedEducationLevel,
    highestEducationDetail
} from "c/sspConstants";

import saveButtonLabel from "@salesforce/label/c.SSP_Save";
import cancelButtonLabel from "@salesforce/label/c.SSP_Cancel";
import saveButtonAltText from "@salesforce/label/c.SSP_HighestEdcationSaveAltText";
import cancelButtonAltText from "@salesforce/label/c.SSP_HighestEducationCancelAltText";
import completeTheQuestionsLabel from "@salesforce/label/c.SSP_CompleteTheQuestionHighestEducation";
import highestEducationDetailHeader from "@salesforce/label/c.SSP_HighestEducationDetail";
import graduationDateLabel from "@salesforce/label/c.SSP_GraduationDate";
import highestEducationLevelLabel from "@salesforce/label/c.SSP_HighestEducationLevel";
import educationLevelAltText from "@salesforce/label/c.SSP_HighestEducationLevelAltText";
import educationLevelPlaceholder from "@salesforce/label/c.SSP_StartTyping";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import MIDDLE_INITIAL from "@salesforce/schema/SSP_Member__c.MiddleInitial__c";
import SUFFIX from "@salesforce/schema/SSP_Member__c.SuffixCode__c";
import AGE from "@salesforce/schema/SSP_Member__c.Age__c";
import EDUCATION_LEVEL from "@salesforce/schema/SSP_Member__c.HighestEducationLevelCode__c";
import GRADUATION_DATE from "@salesforce/schema/SSP_Member__c.HighestEducationGraduatedDate__c";

const unicorn0 = /\{0\}/g;
const suffixArray = {
    JR: "JR.",
    SR: "SR.",
    TW: "II",
    TH: "III",
    FO: "IV",
    FV: "V",
    SI: "VI",
    SE: "VII"
};
export default class SspHighestEducationDetail extends BaseNavFlowPage {
    @api today;
    @api memberId;
    @api programsApplied = [];

    @track individualName;
    @track individualFullName;
    @track graduationDate;
    @track educationLevel;
    @track educationLevelPicklist = [];
    @track showGraduationDate = false;
    @track metaList;
    @track showToast = false;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    @track items = {
        educationLevel: {
            ...EDUCATION_LEVEL,
            label: highestEducationLevelLabel,
            title: educationLevelAltText,
            placeholder: educationLevelPlaceholder
        },
        graduationDate: {
            ...GRADUATION_DATE,
            label: graduationDateLabel
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
            highestEducationDetail: highestEducationDetailHeader,
            completeTheQuestions: completeTheQuestionsLabel
        }
    };

    label = {
        toastErrorText
    };

    memberFieldList = [
        FIRST_NAME,
        LAST_NAME,
        MIDDLE_INITIAL,
        SUFFIX,
        AGE,
        EDUCATION_LEVEL,
        GRADUATION_DATE
    ];
    summaryTitle = "";

    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
    */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Highest Level of Education Details";
        } catch (error) {
            console.error("error in connectedCallback", error);
        }
    }
    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }

    @wire(getObjectInfo, {
        objectApiName: EDUCATION_LEVEL
    })
    fetchObjectInfo ({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error("Error in fetching object info: ", error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: genericIds.AttendanceRecordType,
        fieldApiName: EDUCATION_LEVEL
    })
    fetchInstituteTypePicklistValues ({ error, data }) {
        if (data) {
            this.educationLevelPicklist = data.values;
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
            this.updatedMember = {
                Id: this.memberId
            };
            this.metadataFieldList = this.memberFieldList.map(
                item => item.fieldApiName + "," + item.objectApiName
            );
            this.getMetadataDetails(
                this.metadataFieldList,
                null,
                "SSP_APP_Details_HighestEducationDetails"
            );
            this.updateLabelsAndValues();
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @api
    get MetadataList () {
        return this.metaList;
    }
    set MetadataList (value) {
        try {
            if (value && !Array.isArray(value)) {
                this.metaList = this.resetMetadata(value);

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                }
            }
        } catch (error) {
            console.error("Error in setting MetadataList:", error);
        }
    }

    /**
     * @function updateLabelsAndValues
     * @description Updates the values and labels.
     */
    updateLabelsAndValues () {
        try {
            const record = this.member;
            if (record) {
                this.individualFullName = [
                    getFieldValue(record, FIRST_NAME),
                    getFieldValue(record, MIDDLE_INITIAL),
                    getFieldValue(record, LAST_NAME),
                    getFieldValue(record, SUFFIX) ? suffixArray[getFieldValue(record, SUFFIX)] : ""
                ]
                    .filter(item => !!item)
                    .join(" ");
                this.individualName = [
                    getFieldValue(record, FIRST_NAME),
                    getFieldValue(record, LAST_NAME)
                ]
                    .filter(item => !!item)
                    .join(" ");
                this.graduationDate = getFieldValue(record, GRADUATION_DATE);
                this.educationLevel = getFieldDisplayValue(
                    record,
                    EDUCATION_LEVEL
                );
                const educationLevel = getFieldValue(record, EDUCATION_LEVEL);
                const level = orderedEducationLevel.indexOf(educationLevel);
                this.showGraduationDate =
                    level >= highestEducationDetail.highSchoolIndex;
                const items = JSON.parse(JSON.stringify(this.items));
                items.educationLevel.label = items.educationLevel.label.replace(
                    unicorn0,
                    this.individualName
                );
                this.items = items;
            }
        } catch (error) {
            console.error("Error in updateLabelsAndValues:", error);
        }
    }

    /**
     * @function handleEducationLevelChange
     * @description Handles change in education level.
     * @param {object} event - Event object.
     */
    handleEducationLevelChange (event) {
        try {
            const value = event.detail.selectedValue;
            this.updatedMember[EDUCATION_LEVEL.fieldApiName] = value;
            const level = orderedEducationLevel.indexOf(value);
            this.showGraduationDate =
                level >= highestEducationDetail.highSchoolIndex;
            if (!this.showGraduationDate) {
                this.updatedMember[GRADUATION_DATE.fieldApiName] = null;
            }
        } catch (error) {
            console.error("Error in handleEducationLevelChange", error);
        }
    }

    /**
     * @function handleGraduationDateChange
     * @description Handles change graduation date.
     * @param {object} event - Event object.
     */
    handleGraduationDateChange (event) {
        try {
            const value = event.target.value;
            this.updatedMember[GRADUATION_DATE.fieldApiName] = value;
        } catch (error) {
            console.error("Error in handleGraduationDateChange", error);
        }
    }

    /**
     * @function handleHideToast
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
     * @function handleSave
     * @description Saves the data on click of save button.
     * @param {object} event - Event object.
     */
    handleSave (event) {
        try {
            /* CD2	Security Role Matrix Sharon */
            if(this.isReadOnlyUser) {
                const saveEventReadOnly = new CustomEvent(events.saveDetail);
                this.dispatchEvent(saveEventReadOnly);
            }
            /* CD2	Security Role Matrix Sharon */

            else { /* CD2.5	Security Role Matrix Sharon */
            event.preventDefault();
            event.stopImmediatePropagation();
            const hasError = Array.from(
                this.template.querySelectorAll(".input")
            )
                .map(element => element.ErrorMessages())
                .some(
                    errorList =>
                        Array.isArray(errorList) && errorList.length > 0
                );

            if (hasError) {
                if (!this.showToast) {
                    this.showToast = true;
                }
                return;
            }
            const saveEvent = new CustomEvent(events.saveDetail);
            if (Object.keys(this.updatedMember).length > 1) {
                updateRecord({ fields: this.updatedMember })
                    .then(
                        () => refreshApex(this.wiredMember),
                        error =>
                            console.error(JSON.parse(JSON.stringify(error)))
                    )
                    .then(() => this.dispatchEvent(saveEvent));
            } else {
                this.dispatchEvent(saveEvent);
            }
        }
        } catch (error) {
            console.error("Error in handleSave:", error);
        }
    }

    /**
     * @function handleSave
     * @description Handles 'Cancel' button click.
     * @param {object} event - Event object.
     */
    handleCancel (event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        const cancelEvent = new CustomEvent(events.cancelDetail);
        this.dispatchEvent(cancelEvent);
    }

    /**
     * @function ageRangeTest
     * @description Checks if the age falls in any of the given age ranges.
     * @param {integer} age - Age of the person.
     * @param {number[][]} ranges - Array of age ranges.
     */
    ageRangeTest (age, ranges) {
        try {
            if (age === undefined || age === null || !Array.isArray(ranges)) {
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
     * @function resetMetadata
     * @description Resets the metadata dynamically as per the applied programs and age.
     * @param {integer} metadataList - Age of the person.
     */
    resetMetadata (metadataList) {
        //Alter the metadata for conditional validations based on programsApplied
        const programsApplied = this.programsApplied || [];
        if (metadataList && this.metadataFieldList) {
            const age = getFieldValue(this.member, AGE);
            for (const field of this.metadataFieldList) {
                if (!metadataList[field]) {
                    continue;
                }
                const isRequired = programsApplied.some(program =>
                    this.ageRangeTest(
                        age,
                        highestEducationDetail.requiredAgeRange[program]
                    )
                );
                metadataList[field][
                    highestEducationDetail.inputRequiredField
                ] = isRequired;
            }

            Object.keys(this.items || {}).forEach(itemKey => {
                const fieldApiName = this.items[itemKey].fieldApiName;
                const objectApiName = this.items[itemKey].objectApiName;
                if (fieldApiName && objectApiName) {
                    const metadataKey = fieldApiName + "," + objectApiName;
                    const ranges =
                        highestEducationDetail.requiredAgeRange[itemKey];
                    if (metadataList[metadataKey] && ranges) {
                        const isRequired = programsApplied.some(program =>
                            this.ageRangeTest(age, ranges[program])
                        );
                        metadataList[metadataKey][
                            highestEducationDetail.inputRequiredField
                        ] = isRequired;
                    }
                }
            });
        }
        return metadataList;
    }
    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     * Sharon.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const {securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
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
                "Error in highestEducation.constructRenderingMap", error
            );
        }
    }
}