/**
 * Component Name: sspFormerFosterCare.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description: This screen collects Information about Former Foster Care of member.
 * Date: 01/10/2020.
 */

import { api, track, wire} from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import FOSTER_STATE_CODE from "@salesforce/schema/SSP_Member__c.FosterStateCode__c";
import FOSTER_CARE_AGE from "@salesforce/schema/SSP_Member__c.AgeAtFosterCare__c";
import GENDER_CODE from "@salesforce/schema/SSP_Member__c.GenderCode__c";
import STATE_MEDICAID_PROGRAM_CODE from "@salesforce/schema/SSP_Member__c.IsStateMedicaidProgramCode__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import constants from "c/sspConstants";
import sspHe from "@salesforce/label/c.sspHe";
import sspShe from "@salesforce/label/c.sspShe";
import sspAnswerQuestionsFosterCare from "@salesforce/label/c.sspAnswerQuestionsFosterCare";
import sspWhatStateFosterCareSystem from "@salesforce/label/c.sspWhatStateFosterCareSystem";
import sspClickToSeeListOfStates from "@salesforce/label/c.sspClickToSeeListOfStates";
import ssHowOldWhenLeftFoster from "@salesforce/label/c.ssHowOldWhenLeftFoster";
import sspGettingHealthCareMedicaidProgram from "@salesforce/label/c.sspGettinHealthCareMedicaidProgram";
import sspStartTyping from "@salesforce/label/c.SSP_StartTyping";
import utility, { formatLabels, getYesNoOptions } from "c/sspUtility";

export default class SspFormerFosterCare extends BaseNavFlowPage {
    @api memberId;
    @track yesNoPicklist = getYesNoOptions();
    @track individualRecordTypeId;
    @track fosterStateCodePicklist;
    @track showSpinner = false;
    @track fosterStateCode;
    @track fosterStateCodeValue;
    @track fosterCareAge;
    @track stateMedicaidProgramCode;
    @track genderValue;
    @track metaDataListParent = {};
    @track memberFosterCareObject = {};
    @track saveMemberFosterCareObject = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track maxAge = constants.formerFosterCareAge;
    @track label = {
        sspWhatStateFosterCareSystem,
        sspAnswerQuestionsFosterCare,
        ssHowOldWhenLeftFoster,
        sspGettingHealthCareMedicaidProgram,
        sspClickToSeeListOfStates,
        sspStartTyping
    };
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    /**
    * @function - objectInfo.
    * @description - This method is used to get INDIVIDUAL record type for SSP Member.
    */
    @wire(getObjectInfo, { objectApiName: SSP_MEMBER })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const RecordTypesInfo = constants.sspMemberConstants.RecordTypesInfo;
                const individual = constants.sspMemberConstants.IndividualRecordTypeName;
                const recordTypeInformation = data[RecordTypesInfo];
                this.individualRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo => recordTypeInformation[recTypeInfo].name === individual
                );
            } else if (error) {
                console.error(
                    "Error occurred while fetching record type of Former Foster Care page" +
                    error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of Former Foster Care page" + error
            );
        }
    }

    /**
    * @function - getPicklistValues.
    * @description - This method is used to get values of Indian tribe code picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: FOSTER_STATE_CODE
    })
    fosterStateCodePickListValues ({ data, error }) {
        if (data) {
            this.fosterStateCodePicklist = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching picklist fosterStateCodePickListValues of Former Foster Care page ${JSON.stringify(error)}`
            );
        }
    }

    /**
     * @function - getRecord.
     * @description - Method from LWC framework to fetch records.
     */
    @wire(getRecord, {
        recordId: "$memberId",
        fields: [FOSTER_STATE_CODE, FOSTER_CARE_AGE, STATE_MEDICAID_PROGRAM_CODE, GENDER_CODE]
    })
    fetchRecords ({ data, error }) {
        if (data) {
            this.memberFosterCareObject = data;
            this.fosterStateCode = getFieldValue(
                this.memberFosterCareObject,
                FOSTER_STATE_CODE
            );
            this.fosterCareAge = getFieldValue(
                this.memberFosterCareObject,
                FOSTER_CARE_AGE
            );
            this.stateMedicaidProgramCode = getFieldValue(
                this.memberFosterCareObject,
                STATE_MEDICAID_PROGRAM_CODE
            );
            this.genderValue = getFieldValue(
                this.memberFosterCareObject,
                GENDER_CODE
            ) === constants.relationshipConstants.maleGenderCode ? sspHe : sspShe ;            

            this.label.ssHowOldWhenLeftFoster = formatLabels(
                this.label.ssHowOldWhenLeftFoster,
                [this.currentMemberNameValue, this.genderValue]
            );
            this.showSpinner = false;
        }
        if (error) {
            console.error(
                "Error in fetch records of Former Foster Care page",
                error
            );
        }
    }

    /**
    * @function - get MetadataList.
    * @description - MetadataList getter method for framework.
    */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
    * @function - set MetadataList.
    * @description - Next Event setter method for framework.
    * @param {string} value - Setter for MetadataList framework property.
    */
    set MetadataList (value) {
        try {
            if (value) {
                this.metaDataListParent = value;
                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                }
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of Former Foster Care page",
                e
            );
        }
    }

    /**
    * @function - get nextEvent.
    * @description - Next Event getter method for framework.
    */
    @api
    get nextEvent () {
        return this.nextValue;
    }

    /**
    * @function - set nextEvent.
    * @description - Next Event setter method for framework.
    * @param {string} value - Setter for Next Event framework property.
    */
    set nextEvent (value) {
        try {
            if (value) {
                this.nextValue = value;
                this.checkInputValidation();
            }
        } catch (e) {
            console.error(
                "Error in set nextEvent of Former Foster Care page",
                e
            );
        }
    }

    /**
    * @function - allowSaveData().
    * @description - This method validates the input data and then saves it.
    */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            if (value) {
                this.validationFlag = JSON.parse(value);
                this.saveFormerFosterCareMemberData(this.validationFlag);
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of Former Foster Care page",
                e
            );
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
                this.label.sspWhatStateFosterCareSystem = formatLabels(
                    this.label.sspWhatStateFosterCareSystem,
                    [this.currentMemberNameValue]
                );
                this.label.ssHowOldWhenLeftFoster = formatLabels(
                    this.label.ssHowOldWhenLeftFoster,
                    [this.currentMemberNameValue, this.genderValue]
                );
                this.label.sspGettingHealthCareMedicaidProgram = formatLabels(
                    this.label.sspGettingHealthCareMedicaidProgram,
                    [this.currentMemberNameValue]
                );
            }
        } catch (e) {
            console.error(
                "Error in set currentMemberName of Former Foster Care page",
                e
            );
        }
    }

    /**
     * @function : retMemberObjectExpr
     * @description : This method is used to check whether all the required parameters for
     *                displaying the page are set.
     */
    get retMemberObjectExpr () {
        return this.memberFosterCareObject &&
            this.currentMemberNameValue &&
            this.metaDataListParent ? true : false;
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get Metadata Details.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "FosterStateCode__c,SSP_Member__c",
                "AgeAtFosterCare__c,SSP_Member__c",
                "IsStateMedicaidProgramCode__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_FormerFoster"
            );
        } catch (e) {
            console.error(
                "Error in connectedCallback of Former Foster Care page",
                e
            );
        }
    }

    /**
     * @function : assignValues
     * @description : This method is used to fetch selected value for type ahead picklist.
     * @param {*} event - On change of value in Type ahead picklist.
     */
    assignValues = (event) => {
        try {
            this.fosterStateCodeValue = event.detail.selectedValue;
        } catch (e) {
            console.error(
                "Error in assignValues of Former Foster Care page",
                e
            );
        }
    }

    /**
     * @function : saveHomeAssistanceMemberData
     * @description : Uses method updateRecord from lwc framework to save data.
     * @param {*} memberData - Data entered on screen.
     */
    saveFormerFosterCareMemberData = (memberData) => {
        try {
            this.saveMemberFosterCareObject = {
                Id: this.memberId
            };
            this.saveMemberFosterCareObject[
                FOSTER_STATE_CODE.fieldApiName
            ] = this.fosterStateCodeValue;
            this.saveMemberFosterCareObject[
                FOSTER_CARE_AGE.fieldApiName
            ] = memberData[FOSTER_CARE_AGE.fieldApiName];
            this.saveMemberFosterCareObject[
                STATE_MEDICAID_PROGRAM_CODE.fieldApiName
            ] = memberData[STATE_MEDICAID_PROGRAM_CODE.fieldApiName];
            updateRecord({
                fields: this.saveMemberFosterCareObject
            })
                .then(() => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error(
                        "Error in saving Information of Former Foster Care page" +
                        JSON.stringify(error)
                    );
                });
        } catch (e) {
            console.error(
                "Error in saveFormerFosterCareMemberData of Former Foster Care page",
                e
            );
        }
    };

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            const fosterCareInfo = this.template.querySelectorAll(
                ".ssp-formerFosterCareDetails"
            );
            this.templateInputsValue = fosterCareInfo;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Former Foster Care page",
                e
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