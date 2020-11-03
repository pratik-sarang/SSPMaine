/**
 * Component Name: sspChangeMemberEmail.
 * Author: Yathansh Sharma, Soumyashree Jena.
 * Description: Component to change the Email.
 * Date: 12/24/2019.
 */
import { api, wire, track } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";

import triggerMyInformationCallOut from "@salesforce/apex/SSP_MyInformationController.triggerMyInfoCallout"

import MEMBER_EMAIL from "@salesforce/schema/SSP_Member__c.Email__c";
import MEMBER_INDIVIDUAL_ID from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import ID_FIELD from "@salesforce/schema/SSP_Member__c.Id";
import sspChangeEmailAddress from "@salesforce/label/c.SSP_ChangeEmailAddress";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";

import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

export default class sspChangeMemberEmail extends sspUtility {
    @api memberId;

    @track memberEmail = "";
    @track individualId = "";
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track showErrorModal = false;
    @track errorMsg = "";
    @track saveInitiated = false;
    label = {
        toastErrorText,
        sspChangeEmailAddress,
        sspEmail,
        sspSave,
        sspCancel
    };

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
                "failed in set MetadataList " + JSON.stringify(error)
            );
        }
    }

    /*
     * @function : connectedCallback.
     * @description	: Connected callback to be called during init.
     */
    connectedCallback () {
        try {
            //construction of fieldEntityNameList to retrieve validation related metadata          
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                `${sspConstants.sspMemberFields.Email__c},${sspConstants.sspObjectAPI.SSP_Member__c}`
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "INFO_ChangeEmailAddress"
            ); //calling base cmp method
        } catch (err) {
            console.error("Change Member Email (connectedCallback): " + err);
        }
    }

    /*
     * @function : memberEmailSetter.
     * @description	: Method to set the email entered.
     * @param {string} fields : Email address.
     */
    @wire(getRecord, {
        recordId: "$memberId",
        fields: [MEMBER_EMAIL, MEMBER_INDIVIDUAL_ID]
    })
    memberEmailSetter ({ error, data }) {
        if (data) {
            this.memberEmail = getFieldValue(data, MEMBER_EMAIL);
            this.individualId = getFieldValue(data, MEMBER_INDIVIDUAL_ID);
            if(!this.saveInitiated){
            this.showSpinner = false;
            }
        } else {
            console.error(error);
        }
    }

    /*
     * @function : handleEmailChange.
     * @description	: Method to handle email change event.
     * @param {event} event : Email address change event.
     */
    handleEmailChange (event) {
        try {
            this.memberEmail = event.target.value;
        } catch (error) {
            console.error(
                "Error in handleEmailChange: " + JSON.stringify(error)
            );
        }
    }

    /*
     * @function : initSave.
     * @description	: Method to save email address in existing record.
     */
    initSave () {
        try {
            this.saveInitiated = true;
            let noError = true;
            const self = this;
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-applicationInput"
            );
            for (let i = 0; i < templateAppInputs.length; i++) {
                if (templateAppInputs[i].ErrorMessages().length !== 0) {
                    noError = false;
                }
            }

            templateAppInputs.forEach(function (entity) {
                const errorMessage = entity.ErrorMessages();
                if (
                    !sspUtility.isUndefinedOrNull(errorMessage) &&
                    errorMessage.length !== 0
                ) {
                    noError = false;
                } else if (entity.fieldName === "Email__c"){
                    self.memberEmail = entity.value;
                }
            });

            if (noError) {

                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.memberId;
                fields[MEMBER_EMAIL.fieldApiName] = this.memberEmail;

                const recordInput = { fields };
                this.showSpinner = true;
                updateRecord(recordInput)
                    .then(() => {
                        triggerMyInformationCallOut({
                            individualId: this.individualId
                        }).then(result => {
                            if (result.bIsSuccess) {
                                this.dispatchEvent(new CustomEvent("close"));
                            } else {
                                this.showErrorModal = true;                                
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
            console.error(
                "Error in initSave method : " + JSON.stringify(error)
            );
        }
    }

    closeError () {
        this.showErrorModal = false;
    }

    /*
     * @function : initCancel.
     * @description	: Method to close the modal.
     */
    initCancel () {
        try {
            this.dispatchEvent(new CustomEvent("close"));
        } catch (error) {
            console.error(
                "Error in initCancel method : " + JSON.stringify(error)
            );
        }
    }

    /*
     * @function : hideToast.
     * @description	: Method to hide Toast.
     */
    hideToast () {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error("Error in hideToast: " + JSON.stringify(error));
        }
    }
}