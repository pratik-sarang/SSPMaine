/*
 * Component Name: sspRelationshipsPage.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description: The screen is used specify the most representative relationship between the current individual and every other member of the household.
 * Date: 17/12/2019
 */
import { track, api, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import RELATIONSHIP_TYPE from "@salesforce/schema/SSP_Relationship__c.RelationshipType__c";
import SSP_RELATIONSHIP from "@salesforce/schema/SSP_Relationship__c";
import sspRelationshipWith from "@salesforce/label/c.sspRelationshipWith";
import sspActingAsGuardian from "@salesforce/label/c.sspActingAsGuardian";
import sspActingAsCaretaker from "@salesforce/label/c.sspActingAsCaretaker";
import getRelatives from "@salesforce/apex/SSP_RelationshipInformationController.getRelatives";
import saveRelatives from "@salesforce/apex/SSP_RelationshipInformationController.saveRelatives";
import sspPrimaryApplicantIsNonPrimary from "@salesforce/label/c.sspPrimaryApplicantIsNonPrimarys";
import sspIntendToPursueCustody from "@salesforce/label/c.sspIntendToPursueCustody";
import sspErrorCannotBeYoungerThanTen from "@salesforce/label/c.sspErrorCannotBeYoungerThanTen";
import sspErrorCannotBeYoungerThanTwenty from "@salesforce/label/c.sspErrorCannotBeYoungerThanTwenty";
import sspErrorCannotBeYoungerThanSonDaughter from "@salesforce/label/c.sspErrorCannotBeYoungerThanSonDaughter";
import sspErrorMinorCannotBeParent from "@salesforce/label/c.sspErrorMinorCannotBeParent";
import sspErrorCannotBeOlderThanFatherMother from "@salesforce/label/c.sspErrorCannotBeOlderThanFatherMother";
import sspAltSeeRelationshipTypes from "@salesforce/label/c.sspAltSeeRelationshipTypes";
import sspStartTyping from "@salesforce/label/c.SSP_StartTyping";
import { formatLabels, getYesNoOptions } from "c/sspUtility";
import sspUtility from "c/sspUtility"; //2.5 Security Role Matrix and Program Access.
import constants from "c/sspConstants";
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

export default class sspRelationshipsPage extends BaseNavFlowPage {
    @api memberId;
    @api applicationId;
    @api mode;
    @api showSpinner = false;
    @api modeValue;
    @track label = {
        sspRelationshipWith,
        sspActingAsGuardian,
        sspActingAsCaretaker,
        sspPrimaryApplicantIsNonPrimary,
        sspIntendToPursueCustody,
        sspAltSeeRelationshipTypes,
        sspErrorCannotBeYoungerThanTen,
        sspErrorCannotBeYoungerThanTwenty,
        sspErrorCannotBeYoungerThanSonDaughter,
        sspErrorMinorCannotBeParent,
        sspErrorCannotBeOlderThanFatherMother,
        sspStartTyping
    };
    @track optList = getYesNoOptions();
    @track memberIdValue;
    @track applicationIdValue;
    @track relationshipTypeSelectedValue = {};
    @track relationshipPicklistValue = {};
    @track relativesList = [];
    @track currentUser = "";
    @track saveRelativeList = [];
    @track childCodeList = constants.relationshipConstants.childCodeList;
    @track retrieveData;
    @track toSaveRelationshipList;
    @track finalRelationshipValuesList = [];
    @track relationshipRecordTypeId;
    @track MetaDataListParent = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
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
    * @description - Next Event setter method for framework.
    * @param {string} value - Setter for MetadataList framework property.
    */
    set MetadataList (value) {
        try {
            if (value) {
                this.MetaDataListParent = value;

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                }
            }
        } catch (e) {
            console.error("Error in set MetadataList of Relationship page", e);
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
                this.relationshipValidator(true);
                this.checkInputValidation();
            }
        } catch (e) {
            console.error("Error in set nextEvent of Relationship page", e);
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
                this.validationFlag = value;
                this.reviewRequiredLogic();
                this.saveRelationshipWrapper();
            }
        } catch (e) {
            console.error("Error in set allowSaveData of Relationship page", e);
        }
    }

    /**
     * @function : returnRelativesListExpression
     * @description : This method is used to check whether all the required parameters for
     *                displaying the page are set.
     */
    get returnRelativesListExpression () {
        return Array.isArray(this.relativesList) && this.relativesList.length > 0;
    }

    /**
    * @function - objectInfo.
    * @description - This method is used to get RELATIONSHIP record type for SSP Member.
    */
    @wire(getObjectInfo, { objectApiName: SSP_RELATIONSHIP })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const RecordTypesInfo =
                    constants.sspMemberConstants.RecordTypesInfo;
                const relationship =
                    constants.relationshipConstants.relationshipRecordTypeName;
                const recordTypeInformation = data[RecordTypesInfo];
                this.relationshipRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name === relationship
                );
            } else if (error) {
                console.error(
                    "Error occurred while fetching record type of Relationship page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of Relationship page" +
                    error
            );
        }
    }

    /**
    * @function - getPicklistValues.
    * @description - This method is used to get values of relationship type picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: "$relationshipRecordTypeId",
        fieldApiName: RELATIONSHIP_TYPE
    })
    relationshipTypePickListValues ({ data, error }) {
        if (data) {
            this.relationshipTypeValues = data.values;
            this.updateRelativesValues();
        }
        if (error) {
            console.error(
                `Error Occurred while fetching relationshipTypePickListValues picklist of Relationship page ${error}` +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function - relativesValues.
     * @description - This method is used to call apex method to get relationship details of member.
     */
    relativesValues () {
        try {
            getRelatives({
                memberId: this.memberId,
                applicationId: this.applicationId
            })
            .then((data) => {
                if (data && data.mapResponse) {
                    const tmpResult = JSON.stringify(
                        data.mapResponse.relativesWrapperList
                    );
                    this.relationshipPicklistValue = data.mapResponse.relationshipTypeCodeValues;
                    this.relativesList = JSON.parse(tmpResult);
                    this.updateRelativesValues();
                }
                else {
                    console.error("Error in data getRelatives:", JSON.parse(JSON.stringify(data)));
                }
            });
        } catch (error) {
            console.error(
                "Error in fetching Information of Relationship page" +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get Metadata Details.
     */
    connectedCallback () {
        try {
            this.retrieveData = true;
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "RelationshipType__c,SSP_Relationship__c",
                "IsCareTakerToggle__c,SSP_Relationship__c",
                "IsActingParentToggle__c,SSP_Relationship__c",
                "IntendToPursueLegalCustodyToggle__c,SSP_Relationship__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_RTF_Relationships"
            );
            //Fetch relative values
            this.relativesValues();
        } catch (e) {
            console.error("Error in connectedCallback of Relationship page", e);
        }
    }

    /**
     * @function : assignValues
     * @description : This method is used to fetch selected value for type ahead picklist and also check relationship validation.
     * @param {*} event - On change of value in Type ahead picklist.
     */
    assignValues = (event) => {
        try {
            const relationshipValues = {};
            relationshipValues.relValue = event.detail.selectedValue;
            relationshipValues.key = event.target.dataset.key;
            this.relationshipTypeSelectedValue[relationshipValues.key] =
                relationshipValues.relValue;

            const relationshipList = this.relativesList;
            const otherRelationship =
                constants.relationshipConstants.otherRelationship;
            relationshipList.forEach(function (inputRelation) {
                if (inputRelation.memberId === relationshipValues.key) {
                    if (
                        inputRelation.showQuestionCareTaker &&
                        otherRelationship.includes(relationshipValues.relValue)
                    ) {
                        inputRelation.showQuestionPursueLegalCustody = true;
                    } else {
                        inputRelation.showQuestionPursueLegalCustody = false;
                    }
                }
            });
            this.relativesList = relationshipList;
            this.relationshipValidator(false);
        } catch (e) {
            console.error("Error in assignValues of Relationship page", e);
        }
    }

    /**
     * @function : relationshipValidator
     * @description : This method updates the retrieved relationship wrapper.
     * @param {*} isToastMessage - Whether to show toast message or not.
     */
    relationshipValidator = (isToastMessage) => {
        try {
            const relationshipList = this.relativesList;
            const relationshipTypeSelectedValueList = this
                    .relationshipTypeSelectedValue;
            const relationshipPicklistValue = this.relationshipPicklistValue;
            const ageLessThanTen =
                constants.relationshipConstants.ageLessThanTen;
            const ageLessThanTwenty =
                constants.relationshipConstants.ageLessThanTwenty;
            const individualAgeLessThanRelated =
                constants.relationshipConstants.individualAgeLessThanRelated;
            const individualIsMinor =
                constants.relationshipConstants.individualIsMinor;
            const individualAgeGreaterThanRelated =
                constants.relationshipConstants.individualAgeGreaterThanRelated;
            let displayToast = false;
            relationshipList.forEach(function (inputRelation) {
                let relationshipTypeCode;
                if (relationshipTypeSelectedValueList[inputRelation.memberId] !== null &&
                    relationshipTypeSelectedValueList[inputRelation.memberId] !== undefined ) {
                    relationshipTypeCode = relationshipTypeSelectedValueList[inputRelation.memberId];
                }
                else {
                    relationshipTypeCode = relationshipPicklistValue[inputRelation.relationshipType];
                }
                const otherAge = inputRelation.otherUserAge;
                const currentIndAge = inputRelation.currentUserAge;
                if (
                    currentIndAge <= 10 &&
                    ageLessThanTen.includes(relationshipTypeCode)
                ) {
                    inputRelation.ageLessThanTenShowError = true;
                } else {
                    inputRelation.ageLessThanTenShowError = false;
                }
                if (
                    currentIndAge <= 20 &&
                    ageLessThanTwenty.includes(relationshipTypeCode)
                ) {
                    inputRelation.ageLessThanTwentyShowError = true;
                } else {
                    inputRelation.ageLessThanTwentyShowError = false;
                }
                if (
                    currentIndAge <= otherAge &&
                    individualAgeLessThanRelated.includes(
                        relationshipTypeCode
                    )
                ) {
                    inputRelation.individualAgeLessThanRelatedShowError = true;
                } else {
                    inputRelation.individualAgeLessThanRelatedShowError = false;
                }
                if (
                    currentIndAge <= 18 &&
                    otherAge >= 18 &&
                    individualIsMinor.includes(relationshipTypeCode)
                ) {
                    inputRelation.individualIsMinorShowError = true;
                } else {
                    inputRelation.individualIsMinorShowError = false;
                }
                if (
                    currentIndAge >= otherAge &&
                    individualAgeGreaterThanRelated.includes(
                        relationshipTypeCode
                    )
                ) {
                    inputRelation.individualAgeGreaterThanRelatedShowError = true;
                } else {
                    inputRelation.individualAgeGreaterThanRelatedShowError = false;
                }
                if(inputRelation.individualAgeGreaterThanRelatedShowError ||
                    inputRelation.individualIsMinorShowError ||
                    inputRelation.individualAgeLessThanRelatedShowError ||
                    inputRelation.ageLessThanTwentyShowError ||
                    inputRelation.ageLessThanTenShowError){
                        displayToast = true;
                    }
            });
            this.relativesList = relationshipList;
            if(isToastMessage && displayToast){
                const showToastEvent = new CustomEvent(constants.events.toastEvent, {
                    bubbles: true,
                    composed: true
                });
                this.dispatchEvent(showToastEvent);
            }
        } catch (e) {
            console.error("Error in relationshipValidator of Relationship page", e);
        }
    }

    /**
     * @function : updateRelativesValues
     * @description : This method updates the retrieved relationship wrapper.
     */
    updateRelativesValues = () => {
        try {
            if(Array.isArray(this.relativesList) && this.relativesList.length > 0 &&
                Array.isArray(this.relationshipTypeValues) && this.relationshipTypeValues.length > 0){
                const relationList = this.relativesList;
                const relationshipTypeValues = this
                    .relationshipTypeValues;
                const finalRelationshipValuesList = [];
                const relationshipValues =  relationList[0].genderBasedRelationshipValues;
                relationshipTypeValues.forEach(function (
                    relationshipValue
                ) {
                    if (
                        relationshipValues.includes(
                            relationshipValue.value
                        )
                    ) {
                        finalRelationshipValuesList.push(
                            relationshipValue
                        );
                    }
                });
                this.finalRelationshipValuesList = finalRelationshipValuesList;

                const actingGuardian = this.label
                    .sspActingAsGuardian;
                const relationshipWithLabel = this.label
                    .sspRelationshipWith;
                const actingCaretaker = this.label
                    .sspActingAsCaretaker;
                const pursueCustody = this.label
                    .sspIntendToPursueCustody;
                const relationshipTypeLabel = this.label
                    .sspPrimaryApplicantIsNonPrimary;
                relationList.forEach(function (item) {
                    const sOtherMiddleName = (item.otherUserMiddleName !== undefined && item.otherUserMiddleName !== null) ? (item.otherUserMiddleName + " " ): "";
                    const sOtherSuffix =
                        item.otherUserSuffix !== undefined &&
                        item.otherUserSuffix !== null
                            ? " " + suffixArray[item.otherUserSuffix]
                            : "";
                    const sCurrentMiddleName = (item.currentUserMiddleName !== undefined && item.currentUserMiddleName !== null) ? (item.currentUserMiddleName + " ") : "";
                    const sCurrentSuffix =
                        item.currentUserSuffix !== undefined &&
                        item.currentUserSuffix !== null
                            ? " " + suffixArray[item.currentUserSuffix]
                            : "";
                    item.isActingParentLabel = formatLabels(
                        actingGuardian,
                        [
                            item.currentUserFirstName +
                            " " +
                            sCurrentMiddleName +
                            item.currentUserLastName +
                            sCurrentSuffix,
                            item.otherUserFirstName +
                            " " +
                            sOtherMiddleName +
                            item.otherUserLastName +
                            sOtherSuffix
                        ]
                    );
                    item.relationshipTypeLabel = formatLabels(
                        relationshipTypeLabel,
                        [
                            item.currentUserFirstName +
                            " " +
                            sCurrentMiddleName +
                            item.currentUserLastName +
                            sCurrentSuffix,
                            item.otherUserFirstName +
                            " " +
                            sOtherMiddleName +
                            item.otherUserLastName +
                            sOtherSuffix
                        ]
                    );
                    item.isCareTakerLabel = formatLabels(
                        actingCaretaker,
                        [
                            item.currentUserFirstName +
                            " " +
                            sCurrentMiddleName +
                            item.currentUserLastName +
                            sCurrentSuffix,
                            item.otherUserFirstName +
                            " " +
                            sOtherMiddleName +
                            item.otherUserLastName +
                            sOtherSuffix
                        ]
                    );
                    item.intendToPursueLegalCustodyLabel = formatLabels(
                        pursueCustody,
                        [
                            item.currentUserFirstName +
                            " " +
                            sCurrentMiddleName +
                            item.currentUserLastName +
                            sCurrentSuffix,
                            item.otherUserFirstName +
                            " " +
                            sOtherMiddleName +
                            item.otherUserLastName +
                            sOtherSuffix
                        ]
                    );
                    item.relationshipWithLabel = formatLabels(
                        relationshipWithLabel,
                        [
                            item.otherUserFirstName +
                            " " +
                            sOtherMiddleName +
                            item.otherUserLastName +
                            sOtherSuffix
                        ]
                    );
                });
                this.relativesList = relationList;
                this.showSpinner = false;
            }
            else if(Array.isArray(this.relativesList) && Array.isArray(this.relationshipTypeValues)){
                this.showSpinner = false;
            }
        } catch (e) {
            console.error(
                "Error in updateRelativesValues of Relationship page",
                e
            );
        }
    }

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            const relationshipInfo = this.template.querySelectorAll(
                ".ssp-relationshipDetails"
            );
            this.templateInputsValue = relationshipInfo;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Relationship page",
                e
            );
        }
    }

    /**
     * @function : saveRelationshipWrapper
     * @description : This functions is used to save relationship data.
     */
    saveRelationshipWrapper = () => {
        try {
            this.showSpinner = true;
            const relWrap = this.template.querySelectorAll(
                ".ssp-relationshipDetails"
            );
            const stringRelationshipList = JSON.stringify(this.relativesList);
            const retrieveRelationshipList = JSON.parse(stringRelationshipList);
            const saveDataArr = [];
            retrieveRelationshipList.forEach(function (errorFlag) {
                if (
                    !errorFlag.individualAgeGreaterThanRelatedShowError &&
                    !errorFlag.individualAgeLessThanRelatedShowError &&
                    !errorFlag.ageLessThanTenShowError &&
                    !errorFlag.ageLessThanTwentyShowError &&
                    !errorFlag.individualAgeLessThanRelatedStepShowError &&
                    !errorFlag.individualIsMinorShowError
                ) {
                    saveDataArr.push(true);
                } else {
                    saveDataArr.push(false);
                }
            });
            if (!saveDataArr.includes(false)) {
                const relationshipTypeSelectedValueList = this
                    .relationshipTypeSelectedValue;
                retrieveRelationshipList.forEach(function (relative) {
                    relWrap.forEach(function (inputElement) {
                        if (
                            relative.memberId ===
                            inputElement.getAttribute("data-key")
                        ) {
                            if (
                                inputElement.getAttribute("data-id") ===
                                "relationshipType"
                            ) {
                                if (
                                    relationshipTypeSelectedValueList[
                                        relative.memberId
                                    ] !== null &&
                                    relationshipTypeSelectedValueList[
                                        relative.memberId
                                    ] !== undefined
                                ) {
                                    relative.relationshipType =
                                        relationshipTypeSelectedValueList[
                                            relative.memberId
                                        ];
                                }
                            } else if (
                                inputElement.getAttribute("data-id") ===
                                "isActingParent"
                            ) {
                                relative.isActingParent = inputElement.value;
                            } else if (
                                inputElement.getAttribute("data-id") ===
                                "isCareTaker"
                            ) {
                                relative.isCareTaker = inputElement.value;
                            } else if (
                                inputElement.getAttribute("data-id") ===
                                "intendToPursueLegalCustody"
                            ) {
                                relative.intendToPursueLegalCustody =
                                    inputElement.value;
                            }
                        }
                    });
                });
                this.toSaveRelationshipList = JSON.stringify(
                    retrieveRelationshipList
                );
                saveRelatives({
                    memberId: this.memberId,
                    applicationId: this.applicationId,
                    relList: this.toSaveRelationshipList,
                    mode : this.modeValue
                }).then(result => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error("Error in saveRelationshipWrapper of Relationship page" + JSON.stringify(error.message));
                    this.showSpinner = false;
                });
            }
        } catch (e) {
            console.error("Error in saveRelationshipWrapper of Relationship page",e);
            this.showSpinner = false;
        }
    }

    /**
     * @function : reviewRequiredLogic
     * @description : To make tax filing and absent parent screen review required.
     */
    reviewRequiredLogic = () => {
        try {
            const revRules = [];
            const listMemberId = [];
            listMemberId.push(this.memberId);
            let newParentCount = 0 ;
            let oldParentCount = 0 ;
            let addRule = false;
            let spouseId;
            const self = this;
            const relationInfo = this.template.querySelectorAll(
                ".ssp-relationshipDetails"
            );
            relationInfo.forEach(function (key){
                if(key.fieldName === constants.relationshipConstants.relationshipType){
                    if(key.oldValue !== undefined && key.oldValue !== "" && key.oldValue !== null &&
                       key.value !== undefined && key.value !== "" && key.value !== null &&
                     ((key.oldValue !== constants.relationshipConstants.spouseLabel &&
                       key.value === constants.relationshipConstants.spouseLabel) ||
                      (key.oldValue === constants.relationshipConstants.spouseLabel &&
                       key.value !== constants.relationshipConstants.spouseLabel))){
                        addRule = true;
                        spouseId = key.dataset.key;                        
                        if(listMemberId.indexOf(spouseId) === -1){
                            listMemberId.push(spouseId);
                        }                        
                    }
                    if (self.childCodeList.includes(key.oldValue)){
                        oldParentCount = oldParentCount + 1 ;
                    }
                    if (self.childCodeList.includes(key.value)) {
                        newParentCount = newParentCount + 1;
                    }
                }
            });

            if(addRule){
                //listMemberId.push(spouseId);
                revRules.push("Relationship,"+true+","+listMemberId.join(","));
            }
            this.reviewRequiredList = revRules;
        } catch (e) {
            console.error(
                "Error in reviewRequiredLogic of Relationship page",
                e
            );
        }
    }

    /**
    * @function : constructRenderingMap
    * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
    * @param {string} appPrograms - Application level programs.
    * @param {string} metaValue - Entity mapping data.
    */
    constructRenderingMap = (appPrograms, metaValue) => {
        try {
            if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {
                const { securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == constants.permission.notAccessible) ? false : true;                
            }
            else {
                this.isScreenAccessible = true
            }
        } catch (e) {
            console.error(
                "Error in sspRelationshipsPage.constructRenderingMap",
                e
            );
        }
    }
}
