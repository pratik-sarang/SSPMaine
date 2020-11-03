/**
 * Component Name: sspChangeMemberWrittenLanguage.
 * Author: Yathansh Sharma, Soumyashree Jena.
 * Description: Component to change the Preferred Written Language.
 * Date: 12/24/2019.
 */
import { api, wire, track } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";

import triggerMyInformationCallOut from "@salesforce/apex/SSP_MyInformationController.triggerMyInfoCallout"

import SSP_MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import MEMBER_WRITTEN_LANGUAGE from "@salesforce/schema/SSP_Member__c.PreferredWrittenLanguageCode__c";
import ID_FIELD from "@salesforce/schema/SSP_Member__c.Id";
import MEMBER_INDIVIDUAL_ID from "@salesforce/schema/SSP_Member__c.IndividualId__c";

import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspPreferredWrittenLanguage from "@salesforce/label/c.SSP_PreferredWrittenLang";
import sspChangePreferredWrittenLanguage from "@salesforce/label/c.SSP_ChangePreferredWrittenLanguage";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";

export default class sspChangeMemberWrittenLanguage extends sspUtility {
    @api memberId;

    @track memberLanguage = "";
    @track individualId = "";
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track typeOfLanguageOptions = [];
    @track objectInfo;
    @track showErrorModal = false;
    @track errorMsg = "";

    label = {
        toastErrorText,
        sspChangePreferredWrittenLanguage,
        sspPreferredWrittenLanguage,
        sspSave,
        sspCancel
    };
    @track saveInitiated = false;
    @track MetaDataListParent;
    @track showSpinner = true;
    @track reference = this;
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (value !== null && value !== undefined) {
                this.MetaDataListParent = value;
                this.showMetaData = true;
            }
        } catch (error) {
            console.error(
                "Error in set MetadataList: " + JSON.stringify(error)
            );
        }
    }

    /*
     * @function : connectedCallback
     * @description	: Connected callback to be called during init.
     */
    connectedCallback () {
        try {
            //construction of fieldEntityNameList to retrieve validation related metadata
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                `${sspConstants.sspMemberFields.PreferredWrittenLanguageCode__c},${sspConstants.sspObjectAPI.SSP_Member__c}`
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "INFO_ChangePreferredWrittenLanguage"
            ); //calling base cmp method
        } catch (err) {
            console.error("Change Member Email (connectedCallback): " + err);
        }
    }

    /*
     * @function : memberLanguageSetter
     * @description	: Method to set the selected language.
     * @param {string} fields : Language api values.
     */
    @wire(getRecord, {
        recordId: "$memberId",
        fields: [MEMBER_WRITTEN_LANGUAGE, MEMBER_INDIVIDUAL_ID]
    })
    memberLanguageSetter (respData) {
        if (respData.data) {
            this.memberLanguage = getFieldValue(respData.data, MEMBER_WRITTEN_LANGUAGE);
            this.individualId = getFieldValue(respData.data, MEMBER_INDIVIDUAL_ID);
            if (this.memberLanguage === null) {
                this.memberLanguage = "";
            }
            if(!this.saveInitiated){
                this.showSpinner = false;
                }
        } else {
            console.error(respData.error);
        }
    }

    @wire(getObjectInfo, { objectApiName: SSP_MEMBER_OBJECT })
    objectInfo;

    /*
     * @function : TypePicklistValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName : Language api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: MEMBER_WRITTEN_LANGUAGE
    })
    TypePicklistValues ({ error, data }) {
        try {
            if (data) {
                this.typeOfLanguageOptions = data.values;
            } else {
                this.typeOfLanguageOptions = [];
                console.error(error);
            }
        } catch (err) {
            this.typeOfLanguageOptions = [];
            console.error(
                "Error in TypePicklistValues: " + JSON.stringify(err)
            );
        }
    }

    /*
     * @function : handleLanguageChange.
     * @description	: Method to handle language change.
     * @param {event} event: Picklist value change event.
     */
    handleLanguageChange (event) {
        try {
            this.memberLanguage = event.target.value;
        } catch (error) {
            console.error(
                "Error in handleLanguageChange: " + JSON.stringify(error)
            );
        }
    }

    /*
     * @function : initSave.
     * @description	: Method to save the value entered in existing record.
     */
    initSave () {
        try {
            this.saveInitiated = true;
            let noError = true;
            const templateAppInputs = this.template.querySelectorAll(
                ".applicationInput"
            );
            for (let i = 0; i < templateAppInputs.length; i++) {
                if (templateAppInputs[i].ErrorMessages().length !== 0) {
                    noError = false;
                }
            }

            if (noError) {
                this.showSpinner = true;
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.memberId;
                fields[
                    MEMBER_WRITTEN_LANGUAGE.fieldApiName
                ] = this.memberLanguage;

                const recordInput = { fields };

                updateRecord(recordInput)
                    .then(() => {
                        triggerMyInformationCallOut({
                            individualId: this.individualId
                        }).then(result => {
                            if (result.bIsSuccess) {
                                this.dispatchEvent(new CustomEvent("close"));
                            } else {
                                this.showErrorModal = true;
                                this.showSpinner = false;
                                this.errorMsg = result.mapResponse.SERVICE_ERROR;
                                console.error(result.mapResponse.SERVICE_ERROR);
                            }
                        }).catch(error => {
                            console.error(error);
                        })

                    })
                    .catch(error => {
                        console.error(error);
                    });
            } else {
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error("Error in initSave: " + JSON.stringify(error));
        }
    }

    /*
     * @function : initCancel.
     * @description	: Method to close modal.
     */
    initCancel () {
        try {
            this.dispatchEvent(new CustomEvent("close"));
        } catch (error) {
            console.error("Error in initCancel: " + JSON.stringify(error));
        }
    }

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast () {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error("Error in hideToast: " + JSON.stringify(error));
        }
    }
}