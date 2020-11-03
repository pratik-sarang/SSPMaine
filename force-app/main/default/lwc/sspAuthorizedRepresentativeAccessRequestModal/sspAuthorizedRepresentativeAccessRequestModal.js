/**
 * Component Name: sspAuthorizedRepresentativeAccessRequestModal.
 * Author: Sharon.
 * Description: This component creates a modal for Authorized Representative Access Request.
 * Date: 05/15/2020.
 */
import { track, api, wire } from "lwc";
import sspAuthRepAccessModalHeading from "@salesforce/label/c.SSP_AuthRepAccessModalHeading";
import sspAuthRepAccessModalContentOne from "@salesforce/label/c.SSP_AuthRepAccessModalContentOne";
import sspAuthRepAccessPermissionHeading from "@salesforce/label/c.SSP_AuthRepAccessPermissionHeading";
import sspAuthRepAccessModalContentTwo from "@salesforce/label/c.SSP_AuthRepAccessModalContentTwo";
import sspAuthRepAccessModalContentThree from "@salesforce/label/c.SSP_AuthRepAccessModalContentThree";
import sspAuthRepAccessModalContentFour from "@salesforce/label/c.SSP_AuthRepAccessModalContentFour";
import sspAuthRepAccessModalAcceptButton from "@salesforce/label/c.SSP_AuthRepAccessModalAcceptButton";
import sspAuthRepAccessModalRejectButton from "@salesforce/label/c.SSP_AuthRepAccessModalRejectButton";
import ApplicationEsignFirstName from "@salesforce/schema/SSP_Application__c.ApplicationEsignFirstName__c";
import ApplicationEsignLastName from "@salesforce/schema/SSP_Application__c.ApplicationEsignLastName__c";

import ApplicationEsignSuffixCode from "@salesforce/schema/SSP_Application__c.ApplicationEsignSuffixCode__c";
import ApplicationEsignMiddleInitial from "@salesforce/schema/SSP_Application__c.ApplicationEsignMiddleInitial__c";
import sspSnapContactFirstName from "@salesforce/label/c.SSP_SnapContactFirstName";
import sspSnapContactMiddleInitial from "@salesforce/label/c.sspSnapContactMiddleInitial";
import sspSnapContactLastName from "@salesforce/label/c.SSP_SnapContactLastName";
import sspSuffixLabel from "@salesforce/label/c.SSP_SignaturePageSuffixLabel";
import sspDateLabel from "@salesforce/label/c.SSP_SignaturePageDateLabel";
import noMiddleNameText from "@salesforce/label/c.SSP_NoMiddleNameText";
import constant from "c/sspConstants";
import sspRejectAccessRequestTitle from "@salesforce/label/c.SSP_RejectAccessRequestTitle";
import sspAcceptAccessRequestTitle from "@salesforce/label/c.SSP_AcceptAccessRequestTitle";
import SSPAPPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import utility,{ formatLabels } from "c/sspUtility";
import sspSignaturePage from "@salesforce/label/c.sspSignaturePage";
import showClientProgramPermission from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.showClientProgramPermission";
import updateAccountContactRelation from "@salesforce/apex/SSP_AssisAuthRepConsentNotSignedService.updateAccountContactRelation";
const FIELDS = [
    ApplicationEsignLastName,
    ApplicationEsignFirstName,
    ApplicationEsignSuffixCode,
    ApplicationEsignMiddleInitial
];
const sMALabel = "MEDICAID";
const sSNLabel = "SNAP";
const sKTLabel = "KTAP";
const sCCLabel = "CCAP";
const sSSLabel = "SS";
const sKPLabel = "KHIPP";
const sEnglist = "en_US"; //Tracker Defect-56
export default class SspAuthorizedRepresentativeAccessRequestModal extends utility {
    @api notificationId = ""; 
    @track resultValueVariable;
    @track openModel = true;
    @track trueValue = true;
    @track disabled = true;
    @track reference = this;
    @track MetaDataListParent;
    @track appId;
    @track resourceRecordTypeId;
    @track isDisableMIField = false;
    @track programPermissionList = [];
    @track timeTravelDate = "";
    @track suffixLabelValue = {};
    @track showSpinner = true;
    @track suffixValues =[];
    @track showData = false;
    @track fieldsVariable =FIELDS;
    primaryApplicant = {};
    @track notificationBody=""; //Tracker Defect-56
    label = {
        sspRejectAccessRequestTitle,
        sspAcceptAccessRequestTitle,
        noMiddleNameText,
        sspAuthRepAccessModalHeading,
        sspAuthRepAccessModalContentOne,
        sspAuthRepAccessPermissionHeading,
        sspAuthRepAccessModalContentTwo,
        sspAuthRepAccessModalContentThree,
        sspAuthRepAccessModalContentFour,
        sspAuthRepAccessModalAcceptButton,
        sspAuthRepAccessModalRejectButton,
        sspSnapContactFirstName,
        sspSnapContactMiddleInitial,
        sspSnapContactLastName,
        sspSuffixLabel,
        sspDateLabel,
        sspRequiredErrorMessage
    };

    /**
     * @function : closeApplicationStatementModal
     * @description : This method is used to close the Modal.
     */
    closeApplicationStatementModal = () => {
        try {
            this.openModel = false;
            const hideAccessModal = new CustomEvent(
                constant.events.hideAccessRequestModal
            );
            this.dispatchEvent(hideAccessModal);
        } catch (error) {
            console.error(
                "Error occurred in Application Statement of Understanding Modal" +
                    error
            );
        }
    };

    /**
     * @function : enableModalButtons
     * @description : This method is used to enable the Buttons in the Modal.
     */
    enableModalButtons = () => {
        try {
            this.disabled = false;
        } catch (error) {
            console.error(
                "Error occurred in Application Statement of Understanding Modal" +
                    error
            );
        }
    };
    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.MetaDataListParent = value;
            }
        } catch (error) {
            console.error(
                "Error while fetching metadata values in Signature Page" + error
            );
        }
    }

    /**
     * @function : connectedCallback.
     * @description : This function is fetch the MetaData values on Load.
     */
    connectedCallback () {
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            "ApplicationEsignFirstName__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignLastName__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignMiddleInitial__c,SSP_Application__c"
        );
        fieldEntityNameList.push(
            "ApplicationEsignSuffixCode__c,SSP_Application__c"
        );

        this.getMetadataDetails(fieldEntityNameList, null, "SSP_APP_Signature");
        const signatureHeader = new CustomEvent(
            constant.events.updateSignatureHeader,
            {
                bubbles: true,
                composed: true,
                detail: {
                    header: sspSignaturePage
                }
            }
        );
        this.dispatchEvent(signatureHeader);

        //Load Meta data
        const paramData = {};
        paramData.notificationId = this.notificationId;
        showClientProgramPermission({
            sNotificationDetails: JSON.stringify(paramData)
        })
            .then(result => {
                if (result.bIsSuccess) {
                    const notificationDetails = result.mapResponse.showProgramPermission.notificationDetails; //Tracker Defect-56
                    const loginUserLanguage = result.mapResponse.showProgramPermission.loginUserLanguage; //Tracker Defect-56
                    const accountContactList = result.mapResponse.showProgramPermission.accountContactList;
                    const applicationIndividualList = result.mapResponse.showProgramPermission.applicationIndividuals;
                    const permissionPicklistValues = result.mapResponse.showProgramPermission.permissionPicklistValues;
                    this.timeTravelDate = result.mapResponse.showProgramPermission.timeTravelDate;
                    this.suffixLabelValue =  result.mapResponse.showProgramPermission.suffixLabelValue;
                   
                    for (const [key, value] of Object.entries(this.suffixLabelValue)) {
                        this.suffixValues.push({ "label": value, "value": key});
                    }

                    const programPermissionList = [];
                    if (accountContactList && accountContactList.length > 0) {
                        accountContactList.forEach(element => {
                        if (!utility.isUndefinedOrNull(element.RequestAccessPermission__c) && element.RequestAccessPermission__c !== "") { //Tracker Defect-56
                            const objPermission = JSON.parse(element.RequestAccessPermission__c);
                            if (objPermission.PermissionLevel_Medicaid__c) {
                                const programPermission = {};
                                programPermission.program = sMALabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_Medicaid__c];
                                programPermissionList.push(programPermission);
                            }
                            if (objPermission.PermissionLevel_SNAP__c) {
                                const programPermission = {};
                                programPermission.program = sSNLabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_SNAP__c];
                                programPermissionList.push(programPermission);
                            }
                            if (objPermission.PermissionLevel_StateSupp__c) {
                                const programPermission = {};
                                programPermission.program = sSSLabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_StateSupp__c];
                                programPermissionList.push(programPermission);
                            }
                            if (objPermission.PermissionLevel_KIHIPP__c) {
                                const programPermission = {};
                                programPermission.program = sKPLabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_KIHIPP__c];
                                programPermissionList.push(programPermission);
                            }
                            if (objPermission.PermissionLevel_KTAP__c) {
                                const programPermission = {};
                                programPermission.program = sKTLabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_KTAP__c];
                                programPermissionList.push(programPermission);
                            }
                            if (objPermission.PermissionLevel_CCAP__c) {
                                const programPermission = {};
                                programPermission.program = sCCLabel;
                                programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_CCAP__c];
                                programPermissionList.push(programPermission);
                            }
                        } //Tracker Defect-56
                        });
                    }
                    this.programPermissionList = programPermissionList;
                    //Start - Added as part of Tracker Defect-56
                    if (notificationDetails && notificationDetails.length > 0) {
                        const programPermissionList = [];
                            notificationDetails.forEach(element => {
                            if (!utility.isUndefinedOrNull(element.RequestAccessPermission__c) && element.RequestAccessPermission__c !== "") {
                                const objPermission = JSON.parse(element.RequestAccessPermission__c);
                                if (objPermission.PermissionLevel_Medicaid__c) {
                                    const programPermission = {};
                                    programPermission.program = sMALabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_Medicaid__c];
                                    programPermissionList.push(programPermission);
                                }
                                if (objPermission.PermissionLevel_SNAP__c) {
                                    const programPermission = {};
                                    programPermission.program = sSNLabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_SNAP__c];
                                    programPermissionList.push(programPermission);
                                }
                                if (objPermission.PermissionLevel_StateSupp__c) {
                                    const programPermission = {};
                                    programPermission.program = sSSLabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_StateSupp__c];
                                    programPermissionList.push(programPermission);
                                }
                                if (objPermission.PermissionLevel_KIHIPP__c) {
                                    const programPermission = {};
                                    programPermission.program = sKPLabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_KIHIPP__c];
                                    programPermissionList.push(programPermission);
                                }
                                if (objPermission.PermissionLevel_KTAP__c) {
                                    const programPermission = {};
                                    programPermission.program = sKTLabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_KTAP__c];
                                    programPermissionList.push(programPermission);
                                }
                                if (objPermission.PermissionLevel_CCAP__c) {
                                    const programPermission = {};
                                    programPermission.program = sCCLabel;
                                    programPermission.permission = permissionPicklistValues[objPermission.PermissionLevel_CCAP__c];
                                    programPermissionList.push(programPermission);
                                }
                            }
                        });
                        this.programPermissionList = programPermissionList;
                        this.notificationBody = loginUserLanguage === sEnglist ?
                            notificationDetails[0].Notification_Body__c : notificationDetails[0].Notification_Body_Es__c;
                    }
                    //End - Added as part of Tracker Defect-56
                    //To get the Primary Applicant
                    if (applicationIndividualList && applicationIndividualList.length > 0) {
                        applicationIndividualList.forEach(element => { 
                            //if (element.IsHeadOfHousehold__c) {
                                //Fix for 382061-MY_INFORMATION
                                this.primaryApplicant.suffix = element.SuffixCode__c? element.SuffixCode__c:"";
                                this.primaryApplicant.firstName = element.FirstName__c?element.FirstName__c:"";
                                this.primaryApplicant.middleInitial = element.MiddleInitial__c?element.MiddleInitial__c:"";
                                this.primaryApplicant.lastName = element.LastName__c?element.LastName__c:"";
                            //}
                        });
                    }
                    this.showSpinner = false;
                    this.showData = true;
                } else if (!result.bIsSuccess) {
                    console.error(
                        "Error occurred in showClientProgramPermission of sspAuthorizedRepresentativeAccessRequestModal page" +
                            result.mapResponse.ERROR
                    );
                    this.showSpinner = false;
                    this.showData = true;
                }
            })
            .catch(()=>{
                this.showSpinner = false;
                this.showData = true;
            });
    }

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.templateInputsValue = elem;
        } catch (error) {
            console.error(
                "Error in getRequiredInputElements of Expedite Benefits Page" +
                    error
            );
        }
    };
    /**
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSPAPPLICATION_OBJECT,
        recordTypeId: "$resourceRecordTypeId"
    })
    picklistOptions ({ error, data }) {
        try {
            if (data) {
                this.suffixCode =
                    data.picklistFieldValues.ApplicationEsignSuffixCode__c.values;
            } else if (error) {
                console.error(
                    "### Error while trying to fetch picklist values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "### Error while trying to fetch picklist values ###" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: toggleMiCheckbox.
     * @description 	: This method is used to toggle Middle Initial checkbox change.
     * */
    toggleMiCheckbox = () => {
        try {
            this.template.querySelector(".ssp-middleInitialField").value = "";
            this.isDisableMIField = !this.isDisableMIField;
            if (this.isDisableMIField) {
                const line1 = this.template.querySelector(
                    ".ssp-middleInitialField"
                );
                line1.ErrorMessageList = [];
                this.template
                    .querySelector(".ssp-middleInitialField")
                    .classList.remove("ssp-applicationInputs");
            } else {
                this.template.querySelector(
                    ".ssp-middleInitialField"
                ).classList.add("ssp-applicationInputs");
            }
        } catch (error) {
            console.error("Error in toggle Middle Initial Checkbox");
        }
    };
    handleAccept = () => {
        try {
            let errorsPresent = false;
            const applicationInputs = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            applicationInputs.forEach(element => {
                const errorList = element.ErrorMessages();
                if (errorList.length) {
                    errorsPresent = true;
                }
            });
            if (!errorsPresent) {
                this.openModel = false;
                this.openModel = "";
                const hideAccessModal = new CustomEvent(
                    constant.events.hideAccessRequestModal
                );
                
                //Start - Accept Consent
                this.showSpinner = true;
                updateAccountContactRelation({
                    snotificationId: this.notificationId,
                    citizenConsent : true
                })
                    .then(result => {
                        this.dispatchEvent(hideAccessModal);
                        this.showSpinner = false;
                    })
                    .catch({});
                //End - Accept Consent
            }
        } catch (error) {
            console.error("Error in handleAccept");
        }
    };
    handleReject = () => {
        try {
            this.openModel = false;
            this.openModel = "";
            //Start - Reject Consent Method
            updateAccountContactRelation({
                snotificationId: this.notificationId,
                citizenConsent : false
            })
                .then(result => {
                    this.resultValueVariable = result;
                    //Start - Added here as part of Defect - 386166
                    const hideAccessModal = new CustomEvent(
                        constant.events.hideAccessRequestModal
                    );
                    this.dispatchEvent(hideAccessModal);
                    //End - Added here as part of Defect - 386166
                })
                .catch({});
            //End - Reject Consent Method
        } catch (error) {
            console.error("Error in handleReject");
        }
    };
}