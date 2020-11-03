/**
 * Component Name: sspPrimaryApplicantContactPage.
 * Author: Sanchita Tibrewala, P V Siddarth.
 * Description: This screen takes Contact Information for Primary Applicant.
 * Date: 11/15/2019.
 */

import { track, api, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getYesNoOptions, getPhoneTypeOptions } from "c/sspUtility";
import sspUtility from "c/sspUtility"; //CD2 2.5 Security Role Matrix and Program Access.
import SPOKEN_LANGUAGE_CODE from "@salesforce/schema/SSP_Member__c.PreferredSpokenLanguageCode__c";
import WRITTEN_LANGUAGE_CODE from "@salesforce/schema/SSP_Member__c.PreferredWrittenLanguageCode__c";
import NOTIFICATION_METHOD_CODE from "@salesforce/schema/SSP_Member__c.PreferredNotificationMethodCode__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import saveInformation from "@salesforce/apex/SSP_ContactInformationController.saveSspMemberContactInformation";
import fetchInformation from "@salesforce/apex/SSP_ContactInformationController.fetchBasicSspMemberInformation";
import constants from "c/sspConstants";
import sspCompleteTheQuestions from "@salesforce/label/c.SSP_CompleteTheQuestions";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspPrimaryPhoneNumber from "@salesforce/label/c.SSP_PrimaryPhoneNumber";
import sspExtOptional from "@salesforce/label/c.sspExt";
import sspPrimaryPhoneType from "@salesforce/label/c.SSP_PrimaryPhoneType";
import sspPhoneNumber from "@salesforce/label/c.SSP_PhoneNumber";
import sspPreferredContactMethod from "@salesforce/label/c.SSP_PrefrdContactMethod";
import sspPreferredSpokenLanguage from "@salesforce/label/c.SSP_PreferredSpokenLanguage";
import sspPreferredWrittenLang from "@salesforce/label/c.SSP_PreferredWrittenLang";
import sspCanWeSendTextMessages from "@salesforce/label/c.SSP_CanWeSendTextMessages";
import sspSecondaryPhoneNumber from "@salesforce/label/c.ssp_secondaryPhoneNumber";
import sspPlaceholderPhoneNumber from "@salesforce/label/c.sspPlaceholderPhoneNumber";
import sspAltTextPreferredSpokenLanguage from "@salesforce/label/c.sspAltTextPreffereSpokenLang";
import sspAltTextPreferredWrittenLanguage from "@salesforce/label/c.sspAltTextPrefferedWrittenLang";
import sspEnterSecondaryPhoneNumber from "@salesforce/label/c.sspEnterSecondaryPhNumber";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspTextMessageError from "@salesforce/label/c.SSP_TextMessageError";

//for defect 391731
import sspEmailSMSContactInfo from "@salesforce/label/c.ssp_email_sms_contact_info";

export default class sspPrimaryApplicantContactPage extends BaseNavFlowPage {
    @api applicationId;
    @api flownName;
    @api memberIdValue;
    @api currentMemberName;
    @track showSpinner;
    @track memberObject = {};
    @track showTextMsg = false;
    @track metaDataListParent;
    @track allowSaveValue;
    @track objValue;
    @track phoneTypeCode = getPhoneTypeOptions();
    @track primaryTextPreferred = getYesNoOptions();
    @track dropDownSuffix;
    @track spokenLanguageList;
    @track writtenLanguageList;
    @track notificationMethodList;
    @track notificationMethodListWithoutText;
    @track notificationMethodListWithText;
    @track spokenLangSelectedValue;
    @track secondaryPhoneMandate;
    @track individualRecordTypeId; 
    @track trueValue = true;
    @track isVisible = false;
    @track canText = "";
    @track preferredNotificationMethod = "";
    @track showNotificationError= false;
    @track errorMessage= sspTextMessageError;
    @track showErrorToast= false;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	
    label = {
        sspCompleteTheQuestions,
        sspEmail,
        sspPrimaryPhoneNumber,
        sspExtOptional,
        sspPrimaryPhoneType,
        sspPhoneNumber,
        sspPreferredContactMethod,
        sspPreferredSpokenLanguage,
        sspPreferredWrittenLang,
        sspCanWeSendTextMessages,
        sspSecondaryPhoneNumber,
        sspPlaceholderPhoneNumber,
        sspAltTextPreferredWrittenLanguage,
        sspAltTextPreferredSpokenLanguage,
        toastErrorText
    };
    phoneMaxLength = 12;
    extMaxLength = 4;

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
                    "Error occurred while fetching record type of Primary Applicant Contact page" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type of Primary Applicant Contact page" +
                    error
            );
        }
    }
  /**
     * @function 		: handleHideToast.
     * @description 	: this method is handle toast.
    
     * */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAddAuthRepProgram" +
                    JSON.stringify(error)
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
                `Error Occurred while fetching notificationMethodCodePickListValues picklist of Primary Applicant Contact page ${error}`
            );
        }
    }

    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch Spoken Language Code pickList values for SSP Member.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: SPOKEN_LANGUAGE_CODE
    })
    spokenLanguageCodePickListValues ({ data, error }) {
        if (data) {
            this.spokenLanguageList = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching spokenLanguageCodePickListValues picklist of Primary Applicant Contact page ${error}`
            );
        }
    }
    handleTextMessageChange (event) {       
        if(event && event.target && event.target.value){
            this.canText = event.target.value;
        }
        if(event && event.target && event.target.value &&  this.preferredNotificationMethod === "ES" && event.target.value === "N" && this.showTextMsg){
            this.showNotificationError = true;
          } else{
              this.showNotificationError = false;
              this.showErrorToast =false;
          }
    }

    handleCommunicationPreference (event){      
      this.preferredNotificationMethod = event.target.value;
        if(event && event.target && event.target.value && event.target.value === "ES" && this.canText === "N" && this.showTextMsg){
          this.showNotificationError = true;
        } else{
            this.showNotificationError = false;
            this.showErrorToast =false;
        }
    }
    /**
     * @function - getPicklistValues.
     * @description - This method is used to fetch Written Language Code pickList values for SSP Member.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: WRITTEN_LANGUAGE_CODE
    })
    writtenLanguageCodePickListValues ({ data, error }) {
        if (data) {
            this.writtenLanguageList = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching writtenLanguageCodePickListValues picklist of Primary Applicant Contact page ${error}`
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
                const metadata = value;
                const emailMetadata =
                    metadata[constants.contactDetailsConstants.emailMetadataEntry];
                    // defect 391731 
                  const phoneNumberMetadata = metadata[constants.contactDetailsConstants.primaryPhoneNumberMetadata];
                    const phoneTypeMetadataEntry = metadata[constants.contactDetailsConstants.phoneTypeMetadataEntry];
                if(emailMetadata){
                    emailMetadata[
                        constants.contactDetailsConstants.inputRequired
                    ] = false;
                   metadata[
                        constants.contactDetailsConstants.emailMetadataEntry
                    ] = emailMetadata;
                }
                // defect 391731
                if(phoneNumberMetadata){
                    phoneNumberMetadata[
                        constants.contactDetailsConstants.inputRequired
                    ] = false;
                   metadata[
                        constants.contactDetailsConstants.primaryPhoneNumberMetadata
                    ] = phoneNumberMetadata;
                }
                if(phoneTypeMetadataEntry){
                    phoneTypeMetadataEntry[
                        constants.contactDetailsConstants.inputRequired
                    ] = false;
                   metadata[
                        constants.contactDetailsConstants.phoneTypeMetadataEntry
                    ] = phoneTypeMetadataEntry;
                }
                this.metaDataListParent = metadata;

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                }
            }
        } catch (e) {
            console.error(
                "Error in set MetadataList of Primary Applicant Contact page",
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
                this.fetchInformationFunction(this.memberIdValue);
            }
        } catch (e) {
            console.error(
                "Error in set memberId of Primary Applicant Contact page",
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
                if(this.showNotificationError === false){
                    this.checkInputValidation();
                } else {
                    this.showErrorToast =true;
                }
            }
        } catch (e) {
            console.error(
                "Error in set nextEvent of Primary Applicant Contact page",
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
                this.saveContactData(value);
             
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of Primary Applicant Contact page",
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
            if (this.memberObject && this.metaDataListParent) {
                return true;
            }
        } catch (e) {
            console.error(
                "Error in retMemberObjectExpr of Primary Applicant Contact page",
                e
            );
        }
        return false;
    }

    /**
     * @function : preferredNotificationMethodCodeValue
     * @description : This method is used to return an empty array if the value is null.
     */
    get preferredNotificationMethodCodeValue () {
        return this.memberObject.PreferredNotificationMethodCode__c || "ES";
    }

    //2.5	Security Role Matrix and Program Access.
    get showContents (){
        return this.isVisible && this.isScreenAccessible;
    }

    /**
     * @function : connectedCallback
     * @description : This method is used to get Metadata Details.
     */
    connectedCallback () {
        try {
          //  this.showTextMsg = false;
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "Email__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Member__c",
                "PrimaryPhoneExtension__c,SSP_Member__c",
                "SecondaryPhoneNumber__c,SSP_Member__c",
                "SecondaryPhoneExtension__c,SSP_Member__c",
                "PrimaryPhoneTypeCode__c,SSP_Member__c",
                "PreferredSpokenLanguageCode__c,SSP_Member__c",
                "PreferredWrittenLanguageCode__c,SSP_Member__c",
                "IsPrimaryTextPreferred__c,SSP_Member__c",
                "PreferredNotificationMethodCode__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Primary_Contact"
            );
        } catch (e) {
            console.error(
                "Error in connectedCallback of Primary Applicant Contact page",
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
    saveContactData = contactDetails => {
        try {
         
            this.showSpinner = true;
            const contactMap = JSON.parse(contactDetails);
            if (this.spokenLangSelectedValue) {
                contactMap[
                    "PreferredSpokenLanguageCode__c"
                ] = this.spokenLangSelectedValue;
            }
            const contactObj = JSON.stringify(contactMap);
            saveInformation({
                memberId: this.memberIdValue,
                memberContactInfo: contactObj
            }).then(result => {               
               // this.showSpinner = false;
                this.saveCompleted = true;

            });
           
        } catch (e) {
            console.error(
                "Error in saveContactData of Primary Applicant Contact page",
                e
            );
        }
    };

    /**
     * @function : fetchInformationFunction
     * @description : This method is used to fetch contact information from org.
     * @param {string} value - Member Id.
     */
    fetchInformationFunction = value => {
        fetchInformation({ 
            memberId: value
        })
            .then(result => {
                this.memberObject = result.mapResponse.record;
               
                if(this.memberObject !==null && this.memberObject !== undefined &&
                    this.memberObject.IsPrimaryTextPreferred__c !== undefined &&  this.memberObject.IsPrimaryTextPreferred__c !== null){
                        this.canText =  this.memberObject.IsPrimaryTextPreferred__c;
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
                            this.showTextMsg = false;
                        }    
                /**Added by Shrikant - to enable email field when current user is a non citizen user - CD2. */
                if (result.mapResponse !== null && result.mapResponse !== undefined && result.mapResponse.hasOwnProperty("userDetails") && result.mapResponse.userDetails.profileName === constants.profileNames.nonCitizen) {
                    this.trueValue = false;
                }
                
                this.showSpinner = false;
                this.isVisible = true;
            })
            .catch(error => {
                console.error(
                    "Error in fetching Information of Primary Applicant Contact page" +
                        JSON.stringify(error)
                );
            });
    };

    /**
     * @function : customValidation
     * @description : This method is used to make secondary phone number conditionally required.
     */
    customValidation = () => {
        try {
            let valid = true;
            const contactInfo = this.template.querySelectorAll(
                ".contactDetails"
            );
            contactInfo.forEach((con, index) => {
                if (
                    con.getAttribute("data-id") === "SecondaryPhoneExtension__c"
                ) {
                    const messageList = contactInfo[index - 1].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        sspEnterSecondaryPhoneNumber
                    );
                    if (con.value && !contactInfo[index - 1].value) {
                        if (indexOfMessage === -1) {
                            messageList.push(sspEnterSecondaryPhoneNumber);
                        }
                    } else if (indexOfMessage >= 0) {
                        messageList.splice(indexOfMessage, 1);
                    }
                    contactInfo[index - 1].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                    valid = !messageList.includes(sspEnterSecondaryPhoneNumber);
                }
            });
            return valid;
        } catch (e) {
            console.error(
                "Error in custom validation of Primary Applicant Contact page",
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
            const isValid = this.customValidation();
            const contactInfo = this.template.querySelectorAll(
                ".contactDetails"
            );
            if(isValid) {
                this.templateInputsValue = Array.from(contactInfo);
            }
            else {
                this.templateInputsValue = "invalid";
            }
            this.emailPhoneRequired();
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Primary Applicant Contact page",
                e
            );
        }
    };

    /**Email/Phone required validation for primary contact. */
    emailPhoneRequired = () => {
        try{
            const validationEmail = this.template.querySelector(".emailValidation");
            const validationPhone = this.template.querySelector(".PhoneValidation");
            const validationPhoneType = this.template.querySelector(".phoneType");
            const validSecondaryPhone = this.template.querySelector(".secondaryPhone");
            const notificationCode = this.template.querySelector(".notificationCode");
            const metadataNew = this.metaDataListParent;
            const emailMetadata =
            metadataNew[constants.contactDetailsConstants.emailMetadataEntry];
            const secPhoneNumberMetadata = metadataNew[constants.contactDetailsConstants.phoneNumberMetadata];
           const phoneNumberMetadata = metadataNew[constants.contactDetailsConstants.primaryPhoneNumberMetadata];
            const phoneTypeMetadataEntry = metadataNew[constants.contactDetailsConstants.phoneTypeMetadataEntry];
            const notificationMethod = metadataNew[constants.contactDetailsConstants.notificationMethod];
            
            if(validationPhone.value!==null && validationPhone.value!==undefined && validationPhone.value!==""
             ){
            phoneTypeMetadataEntry[constants.contactDetailsConstants.inputRequired] = true;
            phoneTypeMetadataEntry[
                constants.contactDetailsConstants.inputRequiredMsg
            ] = constants.contactDetailsConstants.inputRequiredMsgString;
            metadataNew[
                constants.contactDetailsConstants.phoneTypeMetadataEntry
            ] = phoneTypeMetadataEntry;
        }else{
            phoneTypeMetadataEntry[
                constants.contactDetailsConstants.inputRequired
            ] = false;
            metadataNew[
                constants.contactDetailsConstants.phoneTypeMetadataEntry
            ] = phoneTypeMetadataEntry;
            validationPhoneType.ErrorMessageList = [];
        }
            if(this.preferredNotificationMethod === "EE"){
                    
                    emailMetadata[
                        constants.contactDetailsConstants.inputRequired
                    ] = true;
                    emailMetadata[
                        constants.contactDetailsConstants.inputRequiredMsg
                    ] = constants.contactDetailsConstants.inputRequiredMsgString;

                    phoneNumberMetadata[
                        constants.contactDetailsConstants.inputRequired
                    ] = false;
                    metadataNew[
                        constants.contactDetailsConstants.emailMetadataEntry
                    ] = emailMetadata;
                    metadataNew[
                        constants.contactDetailsConstants.primaryPhoneNumberMetadata
                    ] = phoneNumberMetadata;

                    secPhoneNumberMetadata[
                        constants.contactDetailsConstants.inputRequired
                    ] = false;
                    metadataNew[
                        constants.contactDetailsConstants.phoneNumberMetadata
                    ] = secPhoneNumberMetadata;

                    
                    if(validationEmail.value===null || validationEmail.value==="" || validationEmail.value===undefined){
                    notificationMethod[constants.contactDetailsConstants.inputRequired] = true;
                    metadataNew[
                        constants.contactDetailsConstants.notificationMethod
                    ] = notificationMethod;
                    notificationCode.ErrorMessageList=[sspEmailSMSContactInfo];
                }else{
                    notificationMethod[constants.contactDetailsConstants.inputRequired] = false;
                    metadataNew[
                        constants.contactDetailsConstants.notificationMethod
                    ] = notificationMethod;
                    notificationCode.ErrorMessageList = [];
                }
                    validationPhone.ErrorMessageList = [];
                    validationPhoneType.ErrorMessageList = [];
                    validSecondaryPhone.ErrorMessageList=[];

                  

            }else if(this.preferredNotificationMethod === "ES"){
                
                emailMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = true;
                emailMetadata[
                    constants.contactDetailsConstants.inputRequiredMsg
                ] = constants.contactDetailsConstants.inputRequiredMsgString;
                metadataNew[
                    constants.contactDetailsConstants.emailMetadataEntry
                ] = emailMetadata;

                phoneNumberMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = true;
                phoneNumberMetadata[
                    constants.contactDetailsConstants.inputRequiredMsg
                ] = constants.contactDetailsConstants.inputRequiredMsgString;
                metadataNew[
                    constants.contactDetailsConstants.primaryPhoneNumberMetadata
                ] = phoneNumberMetadata;
                if(validationPhone.value===null || validationPhone.value===undefined || validationPhone.value===""){
                    notificationMethod[constants.contactDetailsConstants.inputRequired] = true;
                    metadataNew[
                        constants.contactDetailsConstants.notificationMethod
                    ] = notificationMethod;
                    notificationCode.ErrorMessageList=[sspEmailSMSContactInfo];
                }else{
                    notificationMethod[constants.contactDetailsConstants.inputRequired] = false;
                    metadataNew[
                        constants.contactDetailsConstants.notificationMethod
                    ] = notificationMethod;
                    notificationCode.ErrorMessageList = [];
                }

            }else if(this.preferredNotificationMethod === "P"){
                emailMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = false;
                phoneNumberMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = false;
                metadataNew[
                    constants.contactDetailsConstants.emailMetadataEntry
                ] = emailMetadata;
                metadataNew[
                    constants.contactDetailsConstants.primaryPhoneNumberMetadata
                ] = phoneNumberMetadata;
                secPhoneNumberMetadata[
                    constants.contactDetailsConstants.inputRequired
                ] = false;
                metadataNew[
                    constants.contactDetailsConstants.phoneNumberMetadata
                ] = secPhoneNumberMetadata;
                notificationMethod[constants.contactDetailsConstants.inputRequired] = false;
                metadataNew[
                    constants.contactDetailsConstants.notificationMethod
                ] = notificationMethod;
                validationEmail.ErrorMessageList = [];
                validationPhone.ErrorMessageList = [];
                validSecondaryPhone.ErrorMessageList=[];
                notificationCode.ErrorMessageList=[];

            }
                this.metaDataListParent = metadataNew;
        }
        catch(e){
            console.error("Error in emailPhoneRequired of Primary Applicant Contact page",
            e);
        }
    };

    /**
     * @function : showSendTextMsg
     * @description : This event conditionally displays primary text message preferrred component.
     * @param {*} event - On click of phone type code.
     */
    showSendTextMsg = event => {
        try {
            if (event.detail.value === constants.contactDetailsConstants.cell) {
                this.notificationMethodList = this.notificationMethodListWithText;
                this.showTextMsg = true;
                const primaryExtensionField = this.template.querySelector(
                    ".primaryExtension"
                );
                primaryExtensionField.ErrorMessageList = [];
                this.memberObject[
                    constants.sspMemberFields.PrimaryPhoneExtension__c
                ] = null;
                if(this.canText ==="N" && this.preferredNotificationMethod === "ES"){
                    this.showNotificationError =true;
                }else{
                    this.showNotificationError =false;
                this.showErrorToast =false;  
                }
                if(this.preferredNotificationMethod === ""){
                    this.preferredNotificationMethod = "ES";
                }
            } else {
                if(this.preferredNotificationMethod === "ES"){
                    this.preferredNotificationMethod = "";
                }
                this.notificationMethodList = this.notificationMethodListWithoutText;
                this.showTextMsg = false;
                this.showNotificationError =false;
                this.showErrorToast =false;
            }
        } catch (e) {
            console.error(
                "Error in showSendTextMsg of Primary Applicant Contact page",
                e
            );
        }
    };

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

    /**
     * @function : assignValues
     * @description : This method is used to fetch selected value for type ahead picklist.
     * @param {*} event - On change of value in Type ahead picklist.
     */
    assignValues = event => {
        try {
            this.spokenLangSelectedValue = event.detail.selectedValue;
        } catch (e) {
            console.error(
                "Error in assignValues of Primary Applicant Contact page",
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
            if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const {securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == constants.permission.notAccessible) ? false : true;                
            }
            else{
                this.isScreenAccessible = true
            }
        } catch (e) {
            console.error(
                "Error in sspPrimaryApplicantContactPage.constructRenderingMap",
                e
            );
        }
    }
}