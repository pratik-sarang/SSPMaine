/**
 * Component Name: SspAbsentParentDetails.
 * Author: Ajay Saini, Venkata.
 * Description: This screen takes absent parent information for an applicant.
 * Date: DEC-20-2019.
 */

import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { events } from "c/sspConstants";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { formatLabels } from "c/sspUtility";
import fetchNonCustodialParents from "@salesforce/apex/SSP_AbsentParentController.fetchNonCustodialParents";
import linkParentRecord from "@salesforce/apex/SSP_AbsentParentController.linkParentRecord";
import updateParentRecord from "@salesforce/apex/SSP_AbsentParentController.updateParentRecord";

import sspUtility from "c/sspUtility"; /* CD2	Security Role Matrix Sharon */
import constants from "c/sspConstants"; /* CD2	Security Role Matrix Sharon */

import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspSuffix from "@salesforce/label/c.SSP_Suffix";
import sspMiOptional from "@salesforce/label/c.SSP_MI";
import sspGender from "@salesforce/label/c.SSP_Gender";
import sspAddAbsentParent from "@salesforce/label/c.SSP_AddAbsentParent";
import sspCompleteTheQuestionsAboutTheOutsideParent from "@salesforce/label/c.SSP_CompleteTheQuestionsAboutTheOutsideParent";
import sspWhoIsTheAbsentParent from "@salesforce/label/c.SSP_WhoIsTheAbsentParent";
import sspIDoNotHaveTheParentsInformationAtThisTime from "@salesforce/label/c.SSP_IDontHaveTheParentsInformationAtThisTime";
import sspDateOfBirthOptional from "@salesforce/label/c.SSP_Dateofbirth";
import sspSocialSecurityNumberOptional from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspSomeoneElseLabel from "@salesforce/label/c.SSP_SomeoneElse";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspCancelTitle from "@salesforce/label/c.SSP_AbsentParentCancelTitle";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspSaveTitle from "@salesforce/label/c.SSP_AbsentParentSaveTitle";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import suffixTitle from "@salesforce/label/c.SSP_SuffixTitle";
import genderTitle from "@salesforce/label/c.SSP_GenderTitle";
import informationNotAvailable from "@salesforce/label/c.SSP_NoAbsentParentInfo";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";

import MEMBER_FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import MEMBER_LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import FIRST_NAME from "@salesforce/schema/SSP_NonCustodialParent__c.FirstName__c";
import SSP_MEMBER from "@salesforce/schema/SSP_NonCustodialParent__c.SSP_Member__c";
import LAST_NAME from "@salesforce/schema/SSP_NonCustodialParent__c.LastName__c";
import GENDER from "@salesforce/schema/SSP_NonCustodialParent__c.GenderCode__c";
import SSN from "@salesforce/schema/SSP_NonCustodialParent__c.SSN__c";
import DOB from "@salesforce/schema/SSP_NonCustodialParent__c.DateOfBirth__c";
import MI from "@salesforce/schema/SSP_NonCustodialParent__c.MiddleInitial__c";
import SUFFIX from "@salesforce/schema/SSP_NonCustodialParent__c.SuffixCode__c";
import PARENT_UNKNOWN from "@salesforce/schema/SSP_NonCustodialParent__c.IsParentUnknown__c";
import NON_CUSTODIAL_PARENT from "@salesforce/schema/SSP_NonCustodialParent__c";
import ABSENT_PARENT_VERIFICATION_CODE from "@salesforce/schema/SSP_NonCustodialParent__c.AbsentParentVerificationCode__c";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspAbsentParentDetails extends BaseNavFlowPage {
    @api memberId;
    @api recordId;
    @api applicationId;

    @api gender;

    @track defaultRecordTypeId;
    @track firstName;
    @track lastName;
    @track suffix;
    @track socialSecurityNumber;
    @track dateOfBirth;
    @track middleInitials;
    @track parentUnknown;

    @track showToast = false;
    @track isParentUnknown;
    @track selectedParent;
    @track individualName;
    @track genderCodePicklist = [];
    @track suffixCodePicklist = [];
    @track absentParentPicklist;
    @track absentParentVerification = false;
    @track metaList;
    @track showForm;
    @track pageName;
    @track whoIsAbsentParentExists = false;
    @track whoIsAbsentParentExistsDisabled = false;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    nonCustodialParentsData;
    summaryTitle = "";

    newRecord = {};
    customLabel = {
        sspCancel,
        sspSave,
        sspCancelTitle,
        sspSaveTitle,
        sspFirstName,
        sspLastName,
        sspSuffix,
        sspMiOptional,
        sspGender,
        sspAddAbsentParent,
        toastErrorText,
        sspSomeoneElseLabel,
        sspWhoIsTheAbsentParent,
        sspDateOfBirthOptional,
        sspSocialSecurityNumberOptional,
        sspCompleteTheQuestionsAboutTheOutsideParent,
        sspIDoNotHaveTheParentsInformationAtThisTime,
        suffixTitle,
        genderTitle,
        informationNotAvailable,
        sspPageInformationVerified,
        startBenefitsAppCallNumber
    };

    fieldList = [
        FIRST_NAME,
        LAST_NAME,
        GENDER,
        SSN,
        DOB,
        MI,
        SUFFIX,
        PARENT_UNKNOWN,
        ABSENT_PARENT_VERIFICATION_CODE,
        SSP_MEMBER
    ];
    callUsAt = `tel:${this.customLabel.startBenefitsAppCallNumber}`;

    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }

    @api
    get MetadataList () {
        return this.metaList;
    }
    set MetadataList (value) {
        if (value) {
            this.metaList = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0){
                this.constructRenderingMap(null, value); 
            }
        }
    }

    get absentParentExistsDisabled () {   //CD2 2.5 Security Role Matrix.
        return this.whoIsAbsentParentExistsDisabled || this.isReadOnlyUser;
    }

    wiredFetchNonCustodialParents (data) {
        try {
            if (data && data.mapResponse) {
                if (!Array.isArray(data.mapResponse.records)) {
                    return;
                }
                this.nonCustodialParentsData = data;
                const records = data.mapResponse.records;
                const parentOptions = records.map(record => ({
                    label: [record.FirstName__c, record.LastName__c]
                        .filter(item => !!item)
                        .join(" "),
                    value: record.Id
                }));
                if (parentOptions.length > 0) {
                    parentOptions.push({
                        label: sspSomeoneElseLabel,
                        value: sspSomeoneElseLabel
                    });
                    this.absentParentPicklist = parentOptions;
                } else {
                    this.showForm = true;
                }
                // To set the Who is Absent Parent picklist value
                if (records !== undefined && records.length > 0) {
                    for (let index = 0; index < records.length; index++) {
                        const element = records[index];
                        if (element.Id === this.recordId) {
                            this.selectedParent = element.Id;
                            break;
                        }
                    }
                }
                //To disabled fields
                if (
                    this.selectedParent !== undefined &&
                    this.selectedParent !== "" &&
                    this.selectedParent !== sspSomeoneElseLabel
                ) {
                    this.whoIsAbsentParentExists = true;
                    this.whoIsAbsentParentExistsDisabled = true;
                    this.showForm = true;
                }
            } else if (data && data.mapResponse && data.mapResponse.ERROR) {
                console.error(
                    JSON.parse(JSON.stringify(data.mapResponse.ERROR))
                );
            }
        } catch (error) {
            console.error("Error in wiredFetchNonCustodialParents:", error);
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: "$fieldList"
    })
    wiredGetRecord (response) {
        this.wiredRecord = response;
        if (response.data) {
            this.record = response.data;
            this.firstName = getFieldValue(this.record, FIRST_NAME);
            this.lastName = getFieldValue(this.record, LAST_NAME);
            this.middleInitials = getFieldValue(this.record, MI);
            this.dateOfBirth = getFieldValue(this.record, DOB);
            this.gender = getFieldValue(this.record, GENDER);
            this.suffix = getFieldValue(this.record, SUFFIX);
            this.socialSecurityNumber = getFieldValue(this.record, SSN);
            this.isParentUnknown = getFieldValue(this.record, PARENT_UNKNOWN);
            this.absentParentVerification = getFieldValue(
                this.record,
                ABSENT_PARENT_VERIFICATION_CODE
            );
            this.whoIsAbsentParentExistsDisabled = this.absentParentVerification;
            this.showForm = true;
        } else if (response.error) {
            console.error(JSON.parse(JSON.stringify(response.error)));
        }
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: [MEMBER_FIRST_NAME, MEMBER_LAST_NAME]
    })
    wiredGetMember ({ data, error }) {
        if (data) {
            this.individualName = [
                getFieldValue(data, MEMBER_FIRST_NAME),
                getFieldValue(data, MEMBER_LAST_NAME)
            ]
                .filter(item => !!item)
                .join(" ");
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getObjectInfo, {
        objectApiName: NON_CUSTODIAL_PARENT
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
        fieldApiName: GENDER
    })
    fetchGenderTypePicklistValues ({ error, data }) {
        if (data) {
            this.genderCodePicklist = data.values;
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$defaultRecordTypeId",
        fieldApiName: SUFFIX
    })
    fetchSuffixTypePicklistValues ({ error, data }) {
        if (data) {
            this.suffixCodePicklist = data.values;
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    /**
     * @function connectedCallback
     * @description Fetch metadata for validations.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Absent Parent Details";
            this.customLabel.sspPageInformationVerified = formatLabels(
                this.customLabel.sspPageInformationVerified,
                [this.customLabel.sspAddAbsentParent]
            );

            const fieldList = this.fieldList.map(
                field => field.fieldApiName + "," + field.objectApiName
            );
            this.getMetadataDetails(
                fieldList,
                null,
                "SSP_APP_Details_AbsentParentDetails"
            );
            fetchNonCustodialParents({
                memberId: this.memberId,
                applicationId: this.applicationId
            }).then(this.wiredFetchNonCustodialParents.bind(this));
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

        /**
     * @function : disconnectedCallback
     * @description : This method is used to scroll to the top.
     */
    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }
    
    /**
     * @function handleCancel
     * @description Handles 'Cancel' button click.
     * @param {object} event - Event object.
     */
    handleCancel = event => {
        event.preventDefault();
        event.stopImmediatePropagation();
        const cancelEvent = new CustomEvent(events.cancelDetail);
        this.dispatchEvent(cancelEvent);
    };

    /**
     * @function handleAbsentParentChange
     * @param {object} event - Event object to capture checkbox value.
     * @description Disables the inputs.
     */
    handleAbsentParentChange = event => {
        try {
            this.selectedParent = event.target.value;
            this.showForm = this.selectedParent !== "";
            if(this.selectedParent === "") {
                this.whoIsAbsentParentExistsDisabled = false;
            }
            else if (this.selectedParent === sspSomeoneElseLabel) {
                this.whoIsAbsentParentExists = false;
                this.whoIsAbsentParentExistsDisabled = false;
                this.firstName = null;
                this.lastName = null;
                this.middleInitials = null;
                this.socialSecurityNumber = null;
                this.dateOfBirth = null;
                this.parentUnknown = null;
                this.suffix = "";
                this.gender = "";
            } else {
                let isFound = false;
                const nonCustodialParentList = this.nonCustodialParentsData
                    .mapResponse.records;
                if (nonCustodialParentList.length > 0) {
                    for (
                        let index = 0;
                        index < nonCustodialParentList.length;
                        index++
                    ) {
                        const element = nonCustodialParentList[index];
                        if (element.Id === this.selectedParent) {
                            this.firstName =
                                element.FirstName__c !== undefined
                                    ? element.FirstName__c
                                    : null;
                            this.lastName =
                                element.LastName__c !== undefined
                                    ? element.LastName__c
                                    : null;
                            this.middleInitials =
                                element.MiddleInitial__c !== undefined
                                    ? element.MiddleInitial__c
                                    : null;
                            this.dateOfBirth =
                                element.DateOfBirth__c !== undefined
                                    ? element.DateOfBirth__c
                                    : null;
                            this.gender =
                                element.GenderCode__c !== undefined
                                    ? element.GenderCode__c
                                    : null;
                            this.suffix =
                                element.SuffixCode__c !== undefined
                                    ? element.SuffixCode__c
                                    : null;
                            this.socialSecurityNumber =
                                element.SSN__c !== undefined
                                    ? element.SSN__c
                                    : null;
                            this.isParentUnknown =
                                element.IsParentUnknown__c !== undefined
                                    ? element.IsParentUnknown__c
                                    : null;
                            isFound = true;
                            break;
                        }
                    }
                }
                //To disabled fields
                if (isFound) {
                    this.whoIsAbsentParentExists = true;
                    this.whoIsAbsentParentExistsDisabled = true;
                    //Bypass the validation Error
                    if (this.isDisabled) {
                        for (const element of this.template.querySelectorAll(
                            ".ssp-input"
                        )) {
                            element.ErrorMessageList = [];
                        }
                    }
                }
            }
        } catch (error) {
            console.error("Error in handleAbsentParentChange:", error);
        }
    };

    /**
     * @function handleInputChange
     * @param {object} event - Event object to capture input (text/date/number) value.
     * @description Sets attribute of newRecord.
     */
    handleInputChange = event => {
        if (this.template.querySelector(".ssp-dob-input")) {
            this.template
                .querySelector(".ssp-dob-input")
                .classList.remove("ssp-dob-disabled");
        }
        const fieldName = event.target.fieldName;
        this.newRecord[fieldName] = event.target.value;
    };

    /**
     * @function handlePicklistChange
     * @param {object} event - Event object to capture input (picklist) value.
     * @description Sets attribute of newRecord.
     */
    handlePicklistChange = event => {
        const fieldName = event.target.fieldName;
        this.newRecord[fieldName] = event.detail;
    };

    /**
     * @function handleParentUnknownChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleParentUnknownChange = event => {
        try {
            this.isParentUnknown = event.target.value;
            if (this.isDisabled) {
                for (const element of this.template.querySelectorAll(
                    ".ssp-input"
                )) {
                    element.ErrorMessageList = [];
                }
            }
            if (this.template.querySelector(".ssp-dob-input")) {
                this.template
                    .querySelector(".ssp-dob-input")
                    .classList.add("ssp-dob-disabled");
            }
        } catch (error) {
            console.error("Error in handleParentUnknownChange:", error);
        }
    };

    /**
     * @function handleSave
     * @description Handles data save operations.
     * @param {object} event - Event object.
     */
    handleSave = event => {
        try {
             /* CD2	Security Role Matrix Sharon */
             if (this.isReadOnlyUser) {
                 const cancelEvent = new CustomEvent(events.cancelDetail);
                 this.dispatchEvent(cancelEvent);
            }
            else {
            event.preventDefault();
            event.stopImmediatePropagation();
            const inputElements = Array.from(
                this.template.querySelectorAll(".ssp-input")
            );
            if (!this.isParentUnknown) {
                const hasError = inputElements
                    .map(element => element.ErrorMessages())
                    .reduce(
                        (total, value) => total || (value && value.length > 0),
                        false
                    );
                if (hasError) {
                    if (!this.showToast) {
                        this.showToast = true;
                    }
                    return;
                }
            }
            if (
                this.selectedParent &&
                this.selectedParent !== sspSomeoneElseLabel
            ) {
                linkParentRecord({
                    recordId: this.selectedParent,
                    existingRecordId: this.recordId,
                    memberId: this.memberId,
                    isParentUnknown: !!this.isParentUnknown
                }).then(response => {
                    const saveEvent = new CustomEvent(events.saveDetail, {
                        detail: {
                            newDetail:
                                !!response &&
                                response.mapResponse &&
                                response.mapResponse.newDetail
                        }
                    });
                    this.dispatchEvent(saveEvent);
                });
            } else {
                //create/update record
                if (this.selectedParent !== sspSomeoneElseLabel) {
                    this.newRecord.Id = this.recordId;
                }
                this.newRecord[PARENT_UNKNOWN.fieldApiName] = !!this
                    .isParentUnknown;
                updateParentRecord({
                    memberId: this.memberId,
                    parentRecord: this.newRecord,
                    recordId: this.recordId
                })
                    .then(response => {
                        const saveEvent = new CustomEvent(events.saveDetail, {
                            detail: {
                                newDetail:
                                    !!response &&
                                    response.mapResponse &&
                                    response.mapResponse.newDetail
                            }
                        });
                        refreshApex(this.wiredRecord);
                        return this.dispatchEvent(saveEvent);
                    })
                    .catch(error =>
                        console.error(
                            "Error in record update:",
                            JSON.parse(JSON.stringify(error))
                        )
                    );
            }
        }
        } catch (error) {
            console.error("Error in handleSave:", error);
        }
    };

    /**
     * @function handleHideToast
     * @description This method is used to get notified when toast hides.
     */
    handleHideToast = () => {
        this.showToast = false;
    };

    get isDisabled () {
        return (
            this.absentParentVerification ||
            this.isParentUnknown ||
            this.whoIsAbsentParentExists ||
            (getFieldValue(this.record, SSP_MEMBER) !== undefined && getFieldValue(this.record, SSP_MEMBER) !== null && this.memberId !== getFieldValue(this.record, SSP_MEMBER))
        );
    }
    
    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix.
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
                this.isReadOnlyUser =
                    securityMatrix.screenPermission ===
                    constants.permission.readOnly;
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
                "Error in absentParentDetail.constructRenderingMap",
                error
            );
        }
    };
}