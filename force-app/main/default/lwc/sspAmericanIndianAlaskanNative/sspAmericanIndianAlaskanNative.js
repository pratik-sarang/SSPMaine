/**
 * Component Name: sspAmericanIndianAlaskanNative.
 * Author: Sanchita Tibrewala, Priyanka Gound.
 * Description: This screen collects Information about American Indian and Alaskan Native.
 * Date: 01/10/2020.
 */

import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import INDIAN_TRIBE_CODE from "@salesforce/schema/SSP_Member__c.IndianTribeCode__c";
import INDIAN_TRIBE_STATE from "@salesforce/schema/SSP_Member__c.IndianTribeState__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import constants from "c/sspConstants";
import saveInformation from "@salesforce/apex/SSP_AmericanIndianInformationController.saveAmericanIndianMemberInformation";
import fetchInformation from "@salesforce/apex/SSP_AmericanIndianInformationController.fetchAmericanIndianMemberInformation";
import sspCompleteQuestionsAboutAmericanIndian from "@salesforce/label/c.sspCompleteQuesAboutAmericanIndian";
import sspMemberOfRecognizeTribe from "@salesforce/label/c.sspMemberOfRecongnizesTribe";
import sspTribe from "@salesforce/label/c.sspTribe";
import sspTribePrimarilyLocated from "@salesforce/label/c.sspTribePrimarilyLocated";
import sspHasIndividualReceivedService from "@salesforce/label/c.sspHasIndividualReceivedService";
import sspIsIndividualEligibleReceiveService from "@salesforce/label/c.sspIsIndividualEligibleReceiveService";
import sspStartTyping from "@salesforce/label/c.SSP_StartTyping";
import sspIndianHealthService from "@salesforce/label/c.sspIndianHealthService";
import sspTribalHealthProgram from "@salesforce/label/c.sspTribalHealthProgram";
import sspUrbanIndianHealthProgram from "@salesforce/label/c.sspUrbanIndianHealthProgram";
import sspStartTypingTribeOptions from "@salesforce/label/c.sspStartTypingTribeOptions";
import sspStateOptions from "@salesforce/label/c.sspStateOptions";
import utility,{ formatLabels, getYesNoOptions } from "c/sspUtility";

export default class SspAmericanIndianAlaskanNative extends BaseNavFlowPage {
    @track showSpinner = false;
    @track isTrueMemberOfRecognizeTribe = false;
    @track isTrueHasIndividualReceivedService = false;
    @track indTribeCode;
    @track indTribeState;
    @track currentMemberNameValue;
    @track tribe;
    @track tribeState;
    @track individualRecordTypeId;
    @track yesNoPicklist = getYesNoOptions();
    @track MetaDataListParent = {};
    @track memberTribeObject = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    label = {
        sspCompleteQuestionsAboutAmericanIndian,
        sspMemberOfRecognizeTribe,
        sspTribe,
        sspTribePrimarilyLocated,
        sspHasIndividualReceivedService,
        sspIsIndividualEligibleReceiveService,
        sspStartTyping,
        sspIndianHealthService,
        sspTribalHealthProgram,
        sspUrbanIndianHealthProgram,
        sspStateOptions,
        sspStartTypingTribeOptions
    };

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
                    "Error occurred while fetching record type of American Indian Alaskan Native page" +
                    error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of American Indian Alaskan Native page" + error
            );
        }
    }

    /**
    * @function - getPicklistValues.
    * @description - This method is used to get values of Indian tribe code picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: INDIAN_TRIBE_CODE
    })
    indTribeCodePickListValues ({ data, error }) {
        if (data) {
            this.indTribeCode = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching picklist indTribeCodePickListValues of American Indian Alaskan Native page ${error}`
            );
        }
    }

    /**
    * @function - getPicklistValues.
    * @description - This method is used to get values of Indian tribe state picklist.
    */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: INDIAN_TRIBE_STATE
    })
    indTribeStatePickListValues ({ data, error }) {
        if (data) {
            this.indTribeState = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching picklist indTribeStatePickListValues of American Indian Alaskan Native page ${error}`
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
    * @description - Next Event setter method for framework.
    * @param {string} value - Setter for MetadataList framework property.
    */
    set MetadataList (value) {
        try {
            if (value) {
                this.MetaDataListParent = value;
                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                }
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of American Indian Alaskan Native page",
                e
            );
        }
    }

    /**
    * @function - get memberId.
    * @description - This method is used to get memberId value.
    */
    @api
    get memberId () {
        return this.memberIdValue;
    }

    /**
    * @function - set memberId.
    * @description - This method is used to set memberId value.
    * @param {*} value - Member Id.
    */
    set memberId (value) {
        try {
            if (value) {
                this.memberIdValue = value;
                this.fetchInformationFunction(value);
            }
        } catch (e) {
            console.error(
                "Error in set memberId of American Indian Alaskan Native page",
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
                "Error in set nextEvent of American Indian Alaskan Native page",
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
                this.validationFlag = value;
                this.saveAmericanIndianData(value);
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of American Indian Alaskan Native page",
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
                this.label.sspMemberOfRecognizeTribe = formatLabels(
                    this.label.sspMemberOfRecognizeTribe,
                    [this.currentMemberNameValue]
                );
                this.label.sspHasIndividualReceivedService = formatLabels(
                    this.label.sspHasIndividualReceivedService,
                    [this.currentMemberNameValue]
                );
                this.label.sspIsIndividualEligibleReceiveService = formatLabels(
                    this.label.sspIsIndividualEligibleReceiveService,
                    [this.currentMemberNameValue]
                );
            }
        } catch (e) {
            console.error(
                "Error in set currentMemberName of American Indian Alaskan Native page",
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
                this.memberTribeObject && this.currentMemberNameValue && this.MetaDataListParent
            ) {
                return true;
            }
        } catch (e) {
            console.error(
                "Error in retMemberObjectExpr of American Indian Alaskan Native page",
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
            this.isTrueMemberOfRecognizeTribe = false;
            this.isTrueHasIndividualReceivedService = false;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "IsFederalRecognizedIndianTribeToggle__c,SSP_Member__c",
                "IndianTribeCode__c,SSP_Member__c",
                "IndianTribeState__c,SSP_Member__c",
                "IsEligibleForIHFlagToggle__c,SSP_Member__c",
                "IsEligibleForIndianHealthServicesToggle__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_AmIndianAKNative"
            );
        } catch (e) {
            console.error(
                "Error in connectedCallback of American Indian Alaskan Native page",
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
            const dataId = event.target.dataset.id;
            if (dataId === constants.sspMemberFields.IndianTribeCode__c) {
                this.tribe = event.detail.selectedValue;
            }
            else if (dataId === constants.sspMemberFields.IndianTribeState__c) {
                this.tribeState = event.detail.selectedValue;
            }
        } catch (e) {
            console.error(
                "Error in assignValues of American Indian Alaskan Native page",
                e
            );
        }
    }

    /**
     * @function : toggleMemberOfRecognizeTribe
     * @description : This method is used to show and hide type ahead picklist.
     * @param {*} event - On change of toggle.
     */
    toggleMemberOfRecognizeTribe = (event) => {
        try {
            if (event.target.value === constants.toggleFieldValue.yes) {
                this.isTrueMemberOfRecognizeTribe = true;
            } else {
                this.isTrueMemberOfRecognizeTribe = false;
            }
        } catch (e) {
            console.error(
                "Error in toggleMemberOfRecognizeTribe of American Indian Alaskan Native page",
                e
            );
        }

    }

    /**
     * @function : toggleHasIndividualReceivedService
     * @description : This method is used to show and hide type ahead picklist.
     * @param {*} event - On change of toggle.
     */
    toggleHasIndividualReceivedService = (event) => {
        try {
            if (event.target.value === constants.toggleFieldValue.no) {
                this.isTrueHasIndividualReceivedService = true;
            } else {
                this.isTrueHasIndividualReceivedService = false;
            }
        }
        catch (e) {
            console.error(
                "Error in toggleHasIndividualReceivedService of American Indian Alaskan Native page",
                e
            );
        }
    }

    /**
     * @function : saveAmericanIndianData
     * @description : This method is used to save American Indian information.
     * @param {string} amIndianDetails - American Indian information.
     */
    saveAmericanIndianData = (amIndianDetails) => {
        try {
            const amIndianDetailsObject = JSON.parse(amIndianDetails);
            amIndianDetailsObject[constants.sspMemberFields.IndianTribeCode__c] = this.tribe;
            amIndianDetailsObject[constants.sspMemberFields.IndianTribeState__c] = this.tribeState;
            const memberDetails = JSON.stringify(amIndianDetailsObject);
            saveInformation({
                memberId: this.memberIdValue,
                memberAmericanIndianInfo: memberDetails
            });
            this.saveCompleted = true;
        } catch (e) {
            console.error(
                "Error in saveAmericanIndianData of American Indian Alaskan Native page",
                e
            );
        }
    }

    /**
     * @function : fetchInformationFunction
     * @description : This method is used to fetch contact information from org.
     * @param {string} value - Member Id.
     */
    fetchInformationFunction = (value) => {
        try {
            fetchInformation({
                memberId: value
            })
                .then(result => {
                    this.memberTribeObject = Object.assign(
                        this.memberTribeObject,
                        result.mapResponse.record
                    );
                    if (
                        this.memberTribeObject[constants.sspMemberFields.IsFederalRecognizedIndianTribeToggle__c] ===
                        constants.toggleFieldValue.yes
                    ) {
                        this.isTrueMemberOfRecognizeTribe = true;
                    }
                    if (this.memberTribeObject[constants.sspMemberFields.IsEligibleForIHFlagToggle__c] === constants.toggleFieldValue.no) {
                        this.isTrueHasIndividualReceivedService = true;
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        "Error in fetching Information of American Indian Alaskan Native page" +
                        JSON.stringify(error)
                    );
                });
        }
        catch (e) {
            console.error(
                "Error in fetchInformationFunction of American Indian Alaskan Native page",
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
            const tribeInfo = this.template.querySelectorAll(
                ".ssp-amIndianDetails"
            );
            this.templateInputsValue = tribeInfo;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of American Indian Alaskan Native page",
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
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === constants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
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