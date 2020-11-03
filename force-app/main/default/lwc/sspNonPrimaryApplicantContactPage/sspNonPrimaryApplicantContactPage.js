/**
 * Component Name: sspPrimaryApplicantContactPage.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description: This screen takes Contact Information for Non-Primary Applicant.
 * Date: 11/22/2019.
 */

import { api, track, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import NOTIFICATION_METHOD_CODE from "@salesforce/schema/SSP_Member__c.PreferredNotificationMethodCode__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import constants from "c/sspConstants";
import saveInformation from "@salesforce/apex/SSP_ContactInformationController.saveSspMemberContactInformation";
import fetchHeadOfHouseholdInformation from "@salesforce/apex/SSP_ContactInformationController.fetchHohContactInformation";
import fetchInformation from "@salesforce/apex/SSP_ContactInformationController.fetchBasicNonPrimaryMemberInformation";
import fetchHeadOfHouseholdName from "@salesforce/apex/SSP_ContactInformationController.fetchHohName";
import sspCompleteSameContactInfo from "@salesforce/label/c.SSP_CompleteSameContactInfo";
import sspPreferredContactMethod from "@salesforce/label/c.SSP_PrefrdContactMethod";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspExtOptional from "@salesforce/label/c.sspExt";
import sspPrimaryPhoneType from "@salesforce/label/c.SSP_PrimaryPhoneType";
import sspPhoneNumber from "@salesforce/label/c.SSP_PrimaryPhoneNumber";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspAltTextCheckboxNonPrimaryContact from "@salesforce/label/c.sspAltTextCheckboxNonPrimaryContact";
import { formatLabels, getPhoneTypeOptions } from "c/sspUtility";
import sspUtility from "c/sspUtility"; //CD2 2.5 Security Role Matrix and Program Access.

export default class sspNonPrimaryApplicantContactPage extends BaseNavFlowPage {
    phoneMaxLength = 12;
    extMaxLength = 4;
    @api flownName;
    @api showSpinner = false;
    @track memberIdValue;
    @track label = {
        sspCompleteSameContactInfo,
        sspEmail,
        sspExtOptional,
        sspPrimaryPhoneType,
        sspPhoneNumber,
        sspPreferredContactMethod,
        sspPlaceholderPhoneNumber,
        sspAltTextCheckboxNonPrimaryContact
    };
    @track isVisible = false;
    @track applicationIdValue;
    @track memberObject = {};
    @track headObject = {};
    @track headOfHouseholdName = {};
    @track metaDataListParent = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track objValue;
    @track allowSaveValue;
    @track phoneTypeCode = getPhoneTypeOptions ();
    @track showTextMsg;
    @track disableFields;
    @track memberFullName = "";
    @track notificationMethodList;
    @track currentMemberNameValue;
    @track individualRecordTypeId;
    @track notificationMethodListWithoutText;
    @track notificationMethodListWithText;
    @track preferredNotificationMethod = "";
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
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
                    "Error occurred while fetching record type of Non-Primary Applicant Contact page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of Non-Primary Applicant Contact page" +
                    error
            );
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch Notification Method Code pickList values for SSP Member.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: NOTIFICATION_METHOD_CODE
    })
    notificationMethodCodePickListValues ({ data, error }) {
        if (data) {
            this.notificationMethodListWithText = data.values;
            this.notificationMethodListWithoutText = this.notificationMethodListWithText.filter(
                opt =>  opt.value !== "ES"
            );
            this.notificationMethodList = this.notificationMethodListWithoutText;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching notificationMethodCodePickListValues picklist of Non-Primary Applicant Contact page ${error}`
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
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                }
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of Non-Primary Applicant Contact page",
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
                "Error in set memberId of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    @api
    get applicationId () {
        return this.applicationIdValue;
    }
    set applicationId (value) {
        try {
            if (value) {
                this.applicationIdValue = value;
                this.fetchHeadOfHouseholdNameFunction(value);
                this.fetchHeadOfHouseholdInformationFunction(value);
            }
        } catch (e) {
            console.error(
                "Error in set applicationId of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    @api
    get currentMemberName () {
        return this.currentMemberNameValue;
    }
    set currentMemberName (value) {
        try {
            if (value) {
                this.currentMemberNameValue = value;
                this.label.sspAltTextCheckboxNonPrimaryContact = formatLabels(
                    this.label.sspAltTextCheckboxNonPrimaryContact,
                    [this.currentMemberNameValue]
                );
            }
        } catch (e) {
            console.error(
                "Error in set currentMemberName of Non-Primary Applicant Contact page",
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
                "Error in set nextEvent of Non-Primary Applicant Contact page",
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
                this.validationFlag = value;
                this.saveContactData(value);
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    /**
    * @function - sameAsHeadOfHouseholdTitle.
    * @description - This method adds member full name in the alternate text label.
    */
    @api
    get sameAsHeadOfHouseholdTitle () {
        return (
            this.label.sspAltTextCheckboxNonPrimaryContact +
            " " +
            this.memberFullName
        );
    }

    //2.5	Security Role Matrix and Program Access.
    get showContents () {
        return this.isVisible && this.isScreenAccessible;
    }
    
    /**
     * @function : retMemberObjectExpr
     * @description : This method is used to check whether all the required parameters for
     *                displaying the page are set.
     */
    get retMemberObjectExpr () {
        try {
            if (
                this.memberObject &&
                this.headOfHouseholdName &&
                this.metaDataListParent 
            ) {
                return true;
            }
        } catch (e) {
            console.error(
                "Error in retMemberObjectExpr of Non-Primary Applicant Contact page",
                e
            );
        }
        return false;
    }

    /**
     * @function : getRetExp2
     * @description : This method is used to check whether all the required parameters for
     *                displaying the div.
     */
    get getRetExp2 () {
        return (
            this.currentMemberNameValue && this.memberFullName
        );
    }

    /**
     * @function : preferredNotificationMethodCodeValue
     * @description : This method is used to return an empty array if the value is null.
     */
    get preferredNotificationMethodCodeValue () {
        return this.memberObject.PreferredNotificationMethodCode__c || "ES";
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get Metadata Details.
     */
    connectedCallback () {
        try {
            this.disableFields = false;
            this.showTextMsg = false;
            const fieldEntityNameList = [];
            this.showSpinner = true;
            fieldEntityNameList.push(
                "SameContactInfoAsHOH__c,SSP_Member__c",
                "Email__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Member__c",
                "PrimaryPhoneExtension__c,SSP_Member__c",
                "SecondaryPhoneNumber__c,SSP_Member__c",
                //"PrimaryPhoneTypeCode__c,SSP_Member__c",
                "PreferredNotificationMethodCode__c,SSP_Member__c",
                "SSP_APP_NonPrimary_Contact,ScreenName" //CD2 2.5 Security Role Matrix and Program Access.
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Primary_Contact"
            );
        } catch (e) {
            console.error(
                "Error in connectedCallback of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    /**
     * @function : saveContactData
     * @description : This method is used to save contact information.
     * @param {string} contactDetails - Contact information.
     */
    @api
    saveContactData = (contactDetails) => {
        try {
            this.showSpinner = true;
            saveInformation({
                memberId: this.memberIdValue,
                memberContactInfo: contactDetails
            }).then(result => {
               // this.showSpinner = false;
                this.saveCompleted = true;

            });
            
        } catch (e) {
            console.error(
                "Error in saveContactData of Non-Primary Applicant Contact page",
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
        fetchInformation({
            memberId: value
        })
            .then(result => {
                this.memberObject = JSON.parse(
                    JSON.stringify(result.mapResponse.record)
                );
                if (
                    this.memberObject[
                        constants.sspMemberFields.SameContactInfoAsHead__c
                    ] == true
                ) {
                    this.disableFields = true;
                    this.showTextMsg = true;
                } else {
                    this.disableFields = false;
                }
                if(this.memberObject !==null && this.memberObject !== undefined &&
                    this.memberObject.PreferredNotificationMethodCode__c !== undefined &&  this.memberObject.PreferredNotificationMethodCode__c !== null){
                        this.preferredNotificationMethod =  this.memberObject.PreferredNotificationMethodCode__c;
                    }
                if (
                    this.memberObject.PrimaryPhoneTypeCode__c ===
                    constants.contactDetailsConstants.cell
                ) {
                    this.notificationMethodList = this.notificationMethodListWithText;
                    this.showTextMsg = true;
                    if(  this.preferredNotificationMethod === null ||  this.preferredNotificationMethod === "" ){
                        this.preferredNotificationMethod = "ES";  
                    }
                } else {
                    this.notificationMethodList = this.notificationMethodListWithoutText;
                }    
                this.showSpinner = false;
                this.isVisible = true;
            })
            .catch(error => {
                console.error(
                    "Error in fetching Information of Non-Primary Applicant Contact page" +
                        JSON.stringify(error)
                );
            });
    }
    handleCommunicationPreference (event){      
        this.preferredNotificationMethod = event.target.value;
    }
    /**
     * @function : fetchHeadOfHouseholdNameFunction
     * @description : This method is used to fetch head of household's name.
     * @param {string} value - Application Id.
     */
    fetchHeadOfHouseholdNameFunction = (value) => {
        fetchHeadOfHouseholdName({
            applicationId: value
        })
            .then(result => {
                this.headOfHouseholdName = result.mapResponse.record;
                this.memberFullName =
                    this.headOfHouseholdName.FirstName__c +
                    " " +
                    this.headOfHouseholdName.LastName__c;
                this.label.sspCompleteSameContactInfo = formatLabels(
                    this.label.sspCompleteSameContactInfo,
                    [this.currentMemberNameValue, this.memberFullName]
                );
            })
            .catch(error => {
                console.error(
                    "Error in fetching Information for Name of Non-Primary Applicant Contact page" +
                        JSON.stringify(error)
                );
            });
    }

    /**
     * @function : fetchHeadOfHouseholdInformationFunction
     * @description : This method is used to fetch head of household's information.
     * @param {string} value - Application Id.
     */
    fetchHeadOfHouseholdInformationFunction = (value) => {
        fetchHeadOfHouseholdInformation({
            applicationId: value
        })
            .then(result => {

                const tmpResult = JSON.stringify(
                    result.mapResponse.record
                );
                this.headObject = JSON.parse(tmpResult);
                this.headObject[
                    constants.sspMemberFields.SameContactInfoAsHead__c
                ] = true;
            })
            .catch(error => {
                console.error(
                    "Error in fetching HOH Information for Name of Non-Primary Applicant Contact page" +
                        JSON.stringify(error)
                );
            });
    }

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            this.emailRequired();
            this.phoneTypeRequired();
            const contactInfo = this.template.querySelectorAll(
                ".contactDetails"
            );
            this.templateInputsValue = contactInfo;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    /**
     * @function : showSendTextMsg
     * @description : This event fetches the contact information of head of household.
     * @param {*} event - On click of same as primary checkbox.
     */
    sameAsPrimary = (event) => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".contactDetails"
            );
            contactInfo.forEach(function (contactField) {
                contactField.ErrorMessageList = [];
            });
            if (event.detail.checked === true) {
                this.disableFields = true;
                this.showTextMsg = true;
                this.memberObject = Object.assign(this.memberObject, this.headObject);
                if(this.headObject[constants.sspMemberFields.PrimaryPhoneExtension__c] === undefined || 
                    this.headObject[constants.sspMemberFields.PrimaryPhoneExtension__c] === null ||
                    this.headObject[constants.sspMemberFields.PrimaryPhoneExtension__c] === "" ){
                    this.memberObject[constants.sspMemberFields.PrimaryPhoneExtension__c] = null;
                }
                if(this.memberObject !==null && this.memberObject !== undefined &&
                    this.memberObject.PreferredNotificationMethodCode__c !== undefined &&  this.memberObject.PreferredNotificationMethodCode__c !== null){
                        this.preferredNotificationMethod =  this.memberObject.PreferredNotificationMethodCode__c;
                    }
            } else {
                this.memberObject[constants.sspMemberFields.Email__c] = null;
                this.memberObject[
                    constants.sspMemberFields.PrimaryPhoneNumber__c
                ] = null;
                this.memberObject[
                    constants.sspMemberFields.PrimaryPhoneExtension__c
                ] = null;
                this.memberObject[
                    constants.sspMemberFields.PrimaryPhoneTypeCode__c
                ] = null;
                this.memberObject[
                    constants.sspMemberFields.PreferredNotificationMethodCode__c
                ] = null;

                this.disableFields = false;
                if (
                    this.memberObject[
                        constants.sspMemberFields.PrimaryPhoneTypeCode__c
                    ] !== constants.contactDetailsConstants.cell
                ) {
                    this.showTextMsg = false;
                }
            }
        } catch (e) {
            console.error(
                "Error in sameAsPrimary of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    /**
     * @function : showSendTextMsg
     * @description : This event conditionally displays primary text message preferrred component.
     * @param {*} event - On click of phone type code.
     */
    showSendTextMsg = (event) => {
        try {
            if (event.detail.value === constants.contactDetailsConstants.cell) {
                this.showTextMsg = true;
                const primaryExtensionField = this.template.querySelector(
                    ".primaryExtension"
                );
                primaryExtensionField.ErrorMessageList = [];
                this.memberObject[
                    constants.sspMemberFields.PrimaryPhoneExtension__c
                ] = null;
                if(this.preferredNotificationMethod === ""){
                    this.preferredNotificationMethod = "ES";
                }
                this.notificationMethodList = this.notificationMethodListWithText;
            } else {
                if(this.preferredNotificationMethod === "ES"){
                    this.preferredNotificationMethod = "";
                }
                this.notificationMethodList = this.notificationMethodListWithoutText;
                this.showTextMsg = false;
            }
        } catch (e) {
            console.error(
                "Error in showSendTextMsg of Non-Primary Applicant Contact page",
                e
            );
        }
    }

        /**
     * @function : updateMemberObject
     * @description : This event updates memberObject variable.
     * @param {*} event - On change of any screen values.
     */
    updateMemberObject (event) {
        try {
            const newValue = event.target.value;
            const dataId = event.target.dataset.id;
            const memberObject = Object.assign({}, this.memberObject);
            memberObject[dataId] = newValue;
            this.memberObject = memberObject;
        } catch (e) {
            console.error(
                "Error in updateMemberObject of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    phoneTypeRequired = () => {
        try {
            const metadata = this.metaDataListParent;

            //PhoneTypeCheck for Primary Phone
            const primaryPhoneType = this.template.querySelector(".phoneType");
            const primaryPhoneNumber = this.template.querySelector(
                ".primaryPhoneNumber"
            );
//for defect 391731 
            const phoneTypeMetadata = [constants.contactDetailsConstants.phoneTypeMetadataEntry];
        const phoneNumberMetadata = [constants.contactDetailsConstants.phoneNumberMetadata];
            primaryPhoneType.ErrorMessageList = [];
        primaryPhoneNumber.ErrorMessageList = [];
        if(primaryPhoneNumber.value!==null && primaryPhoneNumber.value!==undefined && primaryPhoneNumber.value!==""){
                phoneTypeMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = true;
                phoneTypeMetadata[
                    constants.contactDetailsConstants.inputRequiredMsg
                ] = constants.contactDetailsConstants.inputRequiredMsgString;
            }
         if(this.preferredNotificationMethod === "ES" /*&& (primaryPhoneNumber.value ===null || primaryPhoneNumber.value ===undefined || primaryPhoneNumber.value ==='')*/){
            phoneNumberMetadata[
                constants.contactDetailsConstants.inputRequired
            ] = true;
            phoneNumberMetadata[
                constants.contactDetailsConstants.inputRequiredMsg
            ] = constants.contactDetailsConstants.inputRequiredMsgString;

            phoneTypeMetadata[
                constants.contactDetailsConstants.inputRequired
            ] = true;
            phoneTypeMetadata[
                constants.contactDetailsConstants.inputRequiredMsg
            ] = constants.contactDetailsConstants.inputRequiredMsgString;
        }
            metadata[
                constants.contactDetailsConstants.phoneTypeMetadataEntry
            ] = phoneTypeMetadata;
            metadata[
                constants.contactDetailsConstants.phoneNumberMetadata
            ] = phoneNumberMetadata;
            this.metaDataListParent = metadata;
           
            primaryPhoneType.ErrorMessages();
            primaryPhoneNumber.ErrorMessages();
        }
        catch (e) {
            console.error(
                "Error in phoneTypeRequired of Non-Primary Applicant Contact page",
                e
            );
        }
    }

    /**
     * @function : emailRequired
     * @description : This method is used to make email conditionally required.
     */
    emailRequired = () => {
        try {
            const email = this.template.querySelector(".email");
            const notificationMethod = this.template.querySelector(
                ".notificationMethod"
            );
            const metadata = this.metaDataListParent;
            const emailMetadata =
                metadata[constants.contactDetailsConstants.emailMetadataEntry];
            email.ErrorMessageList = [];
            if (
                (notificationMethod.value ===
                    constants.contactDetailsConstants.emailOnlyValue ||
                    notificationMethod.value ===
                        constants.contactDetailsConstants
                            .emailAndMessageValue) &&
                    !email.value
            ) {
                emailMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = true;
                emailMetadata[
                    constants.contactDetailsConstants.inputRequiredMsg
                ] = constants.contactDetailsConstants.inputRequiredMsgString;
            } else {
                emailMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = false;
            }
            metadata[
                constants.contactDetailsConstants.emailMetadataEntry
            ] = emailMetadata;
            this.metaDataListParent = metadata;
            email.ErrorMessages();
        } catch (e) {
            console.error(
                "Error in emailRequired of Non-Primary Applicant Contact page",
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
                this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == constants.permission.notAccessible) ? false : true;                
            }
        } catch (e) {
            console.error(
                "Error in sspPrimaryApplicantContactPage.constructRenderingMap",
                e
            );
        }
    }
}