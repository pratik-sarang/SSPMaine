/**
 * Component Name: sspInHomeAssistance.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description: This screen collects Information about the type of in-home assistance being received.
 * Date: 01/22/2020.
 */

import { track, api, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import IN_HOME_CARE_TYPE from "@salesforce/schema/SSP_Member__c.InHomeCareType__c";
import constants from "c/sspConstants";
import sspTypeOfInHomeAssistance from "@salesforce/label/c.sspTypeOfInHomeAssistance";
import sspAltTypesOfInHomeAssistance from "@salesforce/label/c.sspAltTypesOfInHomeAssistance";
import sspSelectAnOption from "@salesforce/label/c.sspSelectAnOption";
import { formatLabels } from "c/sspUtility";

export default class SspInHomeAssistance extends BaseNavFlowPage {
    @api memberId;
    @track currentMemberNameValue;
    @track label = {
        sspTypeOfInHomeAssistance,
        sspAltTypesOfInHomeAssistance,
        sspSelectAnOption
    };
    @track individualRecordTypeId;
    @track currentMemberNameValue;
    @track inHomeCareType;
    @track MetaDataListParent = {};
    @track memberHomeAssistanceObject = {};
    @track saveMemberHomeAssistanceObject = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track homeAssistanceValue;
    @track showSpinner = false;

    /**
     * @function - objectInfo.
     * @description - This method is used to get INDIVIDUAL record type for SSP Member.
     */
    @wire(getObjectInfo, { objectApiName: SSP_MEMBER })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const RecordTypesInfo =
                    constants.sspMemberConstants.RecordTypesInfo;
                const individual =
                    constants.sspMemberConstants.IndividualRecordTypeName;
                const recordTypeInformation = data[RecordTypesInfo];
                this.individualRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name === individual
                );
            } else if (error) {
                console.error(
                    "Error occurred while fetching record type of In-home assistance page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of In-home assistance page" +
                    error
            );
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to get values of In home care type picklist.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: IN_HOME_CARE_TYPE
    })
    inHomeCareTypePickListValues ({ data, error }) {
        if (data) {
            this.inHomeCareType = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching picklist inHomeCareTypeListValues of In-home assistance page ${error}`
            );
        }
    }

    /**
     * @function - getRecord.
     * @description - Method from LWC framework to fetch records.
     */
    @wire(getRecord, {
        recordId: "$memberId",
        fields: IN_HOME_CARE_TYPE
    })
    fetchRecords ({ data, error }) {
        if (data) {
            this.memberHomeAssistanceObject = data;
            this.homeAssistanceValue = getFieldValue(
                this.memberHomeAssistanceObject,
                IN_HOME_CARE_TYPE
            );
            this.showSpinner = false;
        }
        if (error) {
            console.error(
                "Error in fetch records of In-home assistance page",
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
        return this.MetaDataListParent;
    }

    /**
     * @function - set MetadataList.
     * @description - Setter for MetadataList framework property.
     * @param {string} value - Metadata value.
     */
    set MetadataList (value) {
        try {
            if (value) {
                this.MetaDataListParent = value;
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of In-home assistance page",
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
                "Error in set nextEvent of In-home assistance page",
                e
            );
        }
    }

    /**
     * @function - allowSaveData.
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
                this.saveHomeAssistanceMemberData(this.validationFlag);
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of In-home assistance page",
                e
            );
        }
    }

    /**
     * @function - get currentMemberName.
     * @description - This method is used to get current member name.
     *
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
                this.label.sspTypeOfInHomeAssistance = formatLabels(
                    this.label.sspTypeOfInHomeAssistance,
                    [this.currentMemberNameValue]
                );
            }
        } catch (e) {
            console.error(
                "Error in set currentMemberName of In-home assistance page",
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
        try {
            if (
                this.memberHomeAssistanceObject && this.currentMemberNameValue && this.MetaDataListParent
            ) {
                return true;
            }
        } catch (e) {
            console.error(
                "Error in retMemberObjectExpr of In-home assistance page",
                e
            );
        }
        return false;
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get Metadata Details.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push("InHomeCareType__c,SSP_Member__c");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_InHomeAssistance"
            );
        } catch (e) {
            console.error(
                "Error in connectedCallback of In-home assistance page",
                e
            );
        }
    }

    /**
     * @function : saveHomeAssistanceMemberData
     * @description : Uses method updateRecord from lwc framework to save data.
     * @param {*} memberData - Data entered on screen.
     */
    saveHomeAssistanceMemberData = (memberData) => {
        try {
            this.saveMemberHomeAssistanceObject = {
                Id: this.memberId
            };
            this.saveMemberHomeAssistanceObject[
                IN_HOME_CARE_TYPE.fieldApiName
            ] = memberData[IN_HOME_CARE_TYPE.fieldApiName];
            updateRecord({
                fields: this.saveMemberHomeAssistanceObject
            })
                .then(() => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error(
                        "Error in saving Information of In-home assistance page" +
                            JSON.stringify(error)
                    );
                });
        } catch (e) {
            console.error(
                "Error in checkInputValidation of In-home assistance page",
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
            const homeAssistanceInfo = this.template.querySelectorAll(
                ".ssp-inHomeAssistanceDetails"
            );
            this.templateInputsValue = homeAssistanceInfo;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of In-home assistance page",
                e
            );
        }
    };
}