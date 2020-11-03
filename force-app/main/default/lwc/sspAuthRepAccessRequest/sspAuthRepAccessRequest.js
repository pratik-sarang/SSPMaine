/**
 * Component Name   : sspAuthRepAccessRequest.
 * Author           : Kyathi & Ashwin.
 * Description      : This screen is used for Auth Rep Access Request.
 * Date             : 5/20/2020.
 */
import { api, wire, track } from "lwc";
import sspUtility, { formatLabels } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import sspRepsAssistAgentsTitle from "@salesforce/label/c.SSP_Reps_Assisters_Agents_Title";
import sspAddAuthReps from "@salesforce/label/c.SSP_AuthRepAccessModalHeading";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspMiOptional from "@salesforce/label/c.SSP_MI";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspSuffix from "@salesforce/label/c.SSP_Suffix";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspSearchAuthRep from "@salesforce/label/c.SSP_SearchButtonText";
import sspSSN from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspGender from "@salesforce/label/c.SSP_Gender";
import sspDateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import sspSuffixTitle from "@salesforce/label/c.SSP_SuffixTitle";
import sspGenderTitle from "@salesforce/label/c.SSP_GenderTitle";
//import sspAddAuthRepsInfo1 from "@salesforce/label/c.SSP_AddAuthRepsInfo1";
import sspAddAuthRepsInfo2 from "@salesforce/label/c.SSP_AuthRepEnterDetails";
import sspSearchBasedOnTheEnteredCriteria from "@salesforce/label/c.SSP_SearchBasedOnTheEnteredCriteria";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
//import ACCOUNTCONTACT_OBJECT from "@salesforce/schema/AccountContactRelation";
import CONTACT_SUFFIX from "@salesforce/schema/Contact.SuffixCode__c";
import CONTACT_GENDER from "@salesforce/schema/Contact.GenderCode__c";
import ADDRESS_LINE1 from "@salesforce/schema/AccountContactRelation.Street__c";
import ADDRESS_LINE2 from "@salesforce/schema/AccountContactRelation.AddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/AccountContactRelation.City__c";
import ADDRESS_COUNTY from "@salesforce/schema/AccountContactRelation.CountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/AccountContactRelation.SSP_State__c";
import ADDRESS_ZIP4 from "@salesforce/schema/AccountContactRelation.Zipcode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/AccountContactRelation.Zipcode5__c";
//import RELATIONSHIP_CODE from "@salesforce/schema/AccountContactRelation.RepresentativeRelationshipCode__c";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import sspAuthRepRelationship from "@salesforce/label/c.SSP_AuthRepRelationship";
import sspSearchApplicationNumber from "@salesforce/label/c.SSP_SearchApplicationNumber";
import sspSearchCaseNumber from "@salesforce/label/c.SSP_SearchCaseNumber";
import sspClickHereToSeeOptionsForRelationships from "@salesforce/label/c.SSP_ClickHereToSeeOptionsForRelationships";
import sspIndicateAccessLevel from "@salesforce/label/c.SSP_IndicateAccessLevel";
//import sspAuthRepCaseAccess from "@salesforce/label/c.SSP_AuthRepCaseAccess";
//import sspClickHereToSeeYourCases from "@salesforce/label/c.SSP_ClickHereToSeeYourCases";
import sspWhichProgramDoYouWant from "@salesforce/label/c.SSPWhichProgramDoYouWantThisAuthorizedRepresentativeToHaveAccessTo";
import sspContinueToNextScreenToEnterFurtherDetails from "@salesforce/label/c.SSP_ContinueToNextScreenToEnterFurtherDetails";
import sspReturnPreviousScreen from "@salesforce/label/c.SSP_ReturnPreviousScreen";
import sspCancelEnteringDetailsAuthorizedRepresentative from "@salesforce/label/c.SSP_CancelEnteringDetailsAuthorizedRepresentative";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import searchClientMCIService from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.searchClientMCIService";
import loadAuthRepDetails from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.loadAuthRepDetails";
import requestAccess from "@salesforce/apex/SSP_AuthRepAccessRequestCtrl.requestAccess";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspPleaseSelectAtLeastOneProgram from "@salesforce/label/c.SSP_PleaseSelectAtLeastOneProgram";
import { NavigationMixin } from "lightning/navigation";
const ST = "ST";
const NT = "NT";
const SE = "SE";
const CA = "CA";
const CC = "CC";
const PY = "PY";
const ET = "ET";
const PA_FIELD_MAP = {
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspAddress,
        fieldApiName: sspConstants.contactFields.Street__c,
        objectApiName: sspConstants.sspObjectAPI.AccountContactRelation
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspAddressLine2,
        fieldApiName: sspConstants.contactFields.AddressLine2__c,
        objectApiName: sspConstants.sspObjectAPI.AccountContactRelation
    },
    city: {
        ...ADDRESS_CITY,
        label: sspConstants.addressLabels.City
    },
    county: {
        ...ADDRESS_COUNTY,
        label: sspConstants.addressLabels.County
    },
    state: {
        ...ADDRESS_STATE,
        label: sspConstants.addressLabels.State
    },
    zipCode4: {
        ...ADDRESS_ZIP4,
        label: sspConstants.addressLabels.Zip
    },
    zipCode5: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    }
};
export default class SspAuthRepAccessRequest extends NavigationMixin(
    sspUtility
) {
    @track disabledRequestAccess = true;
    @track trueValue = true;
    @track showSpinner = false;
    @track suffixOptions;
    @track genderOptions;
    @track representativeRelationshipCodes;
    @track fieldMap = PA_FIELD_MAP;
    //@track programs;
    @track isAppNumberDisabled = false;
    @track isCaseNumberDisabled = false;
    @track metaDataListParent;
    @track recordTypeId;
    @track isFullMatch = false;
    @track isPartialMatch = false;
    @track isNoMatch = false;
    @track isToShow = false;
    @track inputTypePassword;
    @track programPermissionList = [];
    @track showErrorToast = false;
    @track showError = false;
    @track showErrorModal = false;
    @track showNextStepScreen = false;
    @track sspAuthRepRelationshipText;
    @track addressRecord;
    @track disableAddress = false;
    @track applicationNo = ""; //#382177
    //Next Step Update Flag
    authFullMatchSentNotification = false;
    clientNoCommunicationPref = false;
    anyProgramNoCommunicationPref = false;
    authRequestNonMedicaidAccess = false;
    authRequestPartialMatch = false;
    authNoMatchSentNotification = false;
    authAssisterHaveAccess = false;
    accessPendingRequest = false;
    noCaseMatch = false;
    
    sourceIndividualId = "";
    reverseSSPDCResponse = {};
    applicationResponseList = [];
    existingAccountContactList = [];
    loginUserDetails = {};
    dcDataId = "";
    caseNumber = "";
    applicationNumber = "";
    selectedRadio = null;
    permissionPicklistValues = {};
    programPicklistValues = {};
    entered = false;
    label = {
        toastErrorText,
        sspPleaseSelectAtLeastOneProgram,
        sspCancel,
        sspReturnPreviousScreen,
        sspCancelEnteringDetailsAuthorizedRepresentative,
        sspContinueToNextScreenToEnterFurtherDetails,
        sspSearchApplicationNumber,
        sspSearchCaseNumber,
        sspBack,
        sspRequestAccess,
        sspAddress,
        sspAddressLine2,
        sspSuffixTitle,
        sspGenderTitle,
        sspRepsAssistAgentsTitle,
        sspAddAuthReps,
        //sspAddAuthRepsInfo1,
        sspAddAuthRepsInfo2,
        sspFirstName,
        sspMiOptional,
        sspLastName,
        sspSuffix,
        sspEmail,
        sspSearchAuthRep,
        sspSSN,
        sspGender,
        sspDateOfBirth,
        sspSearchBasedOnTheEnteredCriteria,
        sspAuthRepRelationship,
        sspClickHereToSeeOptionsForRelationships,
        sspIndicateAccessLevel,
        //sspAuthRepCaseAccess,
        //sspClickHereToSeeYourCases,
        sspWhichProgramDoYouWant,
        sspMiddleInitialMaxLength:
            sspConstants.validationEntities.sspMiddleInitialMaxLength
    };
    /**
     * @function : MetadataList
     * @description	:Getter setter for MetadataList.
     */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
            }
        } catch (error) {
            console.error(
                "Error occured in MetadataList getter setter in sspAuthRepAccessRequest screen " +
                    JSON.stringify(error.message)
            );
        }
    }
    /**
     * @function : renderedCallback
     * @description	: This method set the masking on input.
     */
    renderedCallback () {
        try {
            if (this.entered === false) {
                this.entered = true;
                //Add the below code for masking
                const agent = window.navigator.userAgent;
                const browserIE = /MSIE|Trident/.test(agent);
                if (browserIE) {
                    this.inputTypePassword = sspConstants.inputTypes.password;
                } else {
                    this.inputTypePassword = "text";
                }
            }
        } catch (error) {
            console.error("Error in renderedCallback" + JSON.stringify(error));
        }
    }


    /**
     * @function : getObjectData
     * @description	: Wire call to retrieve contact metadata.
     * @param {object} objData - Retrieved data.
     */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    getObjectData ({ data }) {
        try {
            if (data) {
                const recordTypeInfo =
                    data[sspConstants.sspMemberConstants.RecordTypesInfo];
                this.recordTypeId = Object.keys(recordTypeInfo).find(
                    recordTypeId =>
                        recordTypeInfo[recordTypeId].name ===
                        sspConstants.contactRecordTypes.Auth_Rep
                );
            }
        } catch (error) {
            console.error(
                "Error in retrieving data sspAddAuthRep.getObjectData" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : fetchSuffixValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Suffix api name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_SUFFIX
    })
    fetchSuffixValues ({ error, data }) {
        try {
            if (data) {
                this.suffixOptions = data.values;
            } else if (error) {
                console.error(
                    "Error occured in fetchSuffixValues in sspAuthRepAccessRequest screen" +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error occured in fetchSuffixValues in sspAuthRepAccessRequest screen" +
                    JSON.stringify(err.message)
            );
        }
    }

    /**
     * @function : fetchGenderValues.
     * @description	: Method to get picklist values.
     * @param {string} fieldApiName - Gender api value.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CONTACT_GENDER
    })
    fetchGenderValues ({ error, data }) {
        try {
            if (data) {
                this.genderOptions = data.values;
            } else if (error) {
                console.error(
                    "Error occured in fetchGenderValues in sspAuthRepAccessRequest screen" +
                        JSON.stringify(error)
                );
            }
        } catch (err) {
            console.error(
                "Error occured in fetchGenderValues in sspAuthRepAccessRequest screen" +
                    JSON.stringify(err.message)
            );
        }
    }

    
    /**
     * @function : connectedCallback
     * @description	: Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            /** #382177 fix.*/
            const sPageURL = decodeURIComponent(
                window.location.search.substring(1)
            );
            const sURLVariables = sPageURL.split("&");

            if (sURLVariables != null && sURLVariables != "") {
                for (let i = 0; i < sURLVariables.length; i++) {
                    const sParam = sURLVariables[i].split("=");
                    if (sParam[0] === "applicationNumber") {
                        this.applicationNo =
                            sParam[1] === undefined ? "" : sParam[1];
                        this.isCaseNumberDisabled = true;
                        this.isAppNumberDisabled = false;
                    }
                }
            }
            /** */
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.contactFields.FirstName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.MiddleName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.LastName +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.SuffixCode__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.SSN__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.GenderCode__c +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.BirthDate +
                    "," +
                    sspConstants.sspObjectAPI.Contact,
                sspConstants.contactFields.Street__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.City__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.CountyCode__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.SSP_State__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.ZipCode5__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.ZipCode4__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.contactFields.AddressLine2__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.accountContactRelationFields
                    .RepresentativeRelationshipCode__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "REPS_AddAuthorizedRepresentative1"
            );

            //Load Meta data
            loadAuthRepDetails({})
                .then(result => {
                    if (result.bIsSuccess) {

                        //To set the Relationship picklist field option
                        const valueLabelMapping =
                            result.mapResponse.authRepDetails
                                .relationshipPicklistValues;
                        if (valueLabelMapping) {
                            const relationshipCodesList = [];
                            Object.keys(valueLabelMapping).forEach(value => {
                                relationshipCodesList.push({
                                    value: value,
                                    label: valueLabelMapping[value]
                                });
                            });
                            this.representativeRelationshipCodes = relationshipCodesList;
                        }

                        //Get the Program picklist field option
                        this.programPicklistValues =
                            result.mapResponse.authRepDetails.programPicklistValues;

                        //Get the Permission picklist field option
                        this.permissionPicklistValues =
                            result.mapResponse.authRepDetails.permissionPicklistValues;

                        //Get the Program & Permission mapping from Meta data records
                        const programPermissionMappingList =
                            result.mapResponse.authRepDetails
                                .programPermissionMapping;

                        //To set the Program & Permission field option
                        programPermissionMappingList.forEach(element => {
                            this.setProgramPermissionWrapperData(element);
                        });
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in loadAuthRepDetails of sspAuthRepAccessRequest page" +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occured in loadAuthRepDetails method in sspAuthRepAccessRequest" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : setProgramPermissionWrapperData
     * @description	: Use to bind the Program with its permissions on screen.
     * @param  {object} element - Contains the data of SSP_ProgramPermissionMappings meta data records.
     */
    setProgramPermissionWrapperData = element => {
        try {
            const programPermission = {};
            const permissionList = [];
            const permissionPicklistValues = this.permissionPicklistValues;
            const programPicklistValues = this.programPicklistValues;

            programPermission.selected = false;
            programPermission.programName =
                programPicklistValues[element.Program__c];
            programPermission.programId = element.Program__c;

            //Apply, Report Changes, ReCertify
            if (element.ApplyReportChangeRecertify__c) {
                permissionList.push({
                    value: ST,
                    label: permissionPicklistValues[ST]
                });
            }
            //Apply, Report Changes, ReCertify, and receive copy of Notices
            if (element.ApplyReportChangeRecertifyCopyNotice__c) {
                permissionList.push({
                    value: NT,
                    label: permissionPicklistValues[NT]
                });
            }
            //Apply, Report Changes, ReCertify, and use EBT Card
            if (element.ApplyReportChangeRecertifyEBTCard__c) {
                permissionList.push({
                    value: SE,
                    label: permissionPicklistValues[SE]
                });
            }
            //Apply, Report Changes, ReCertify, and receive checks made out to client
            if (element.ApplyReportChangeRecertifyChecksToClient__c) {
                permissionList.push({
                    value: CC,
                    label: permissionPicklistValues[CC]
                });
            }
            //Use EBT Card
            if (element.UseEBTCard__c) {
                permissionList.push({
                    value: ET,
                    label: permissionPicklistValues[ET]
                });
            }
            //Apply, Report Changes, ReCertify, and receive checks
            if (element.ApplyReportChangeRecertifyReceiveChecks__c) {
                permissionList.push({
                    value: CA,
                    label: permissionPicklistValues[CA]
                });
            }
            //Statutory Benefit Payee
            if (element.StatutoryBenefitPayee__c) {
                permissionList.push({
                    value: PY,
                    label: permissionPicklistValues[PY]
                });
            }
            programPermission.permissionLevel = permissionList;
            programPermission.permission = "";
            this.programPermissionList.push(programPermission);
        } catch (error) {
            console.error(error);
        }
    };

    /**
     * @function : handleRadioClick
     * @description	: To handle radio button changes.
     * @param  {object} event - Contains the current event object.
     */
    handleRadioClick = event => {
        try {
            if (this.selectedRadio !== event.target.value) {
                // Checking for value change
                this.selectedRadio = event.target.value;
                if (
                    this.selectedRadio ===
                    sspConstants.agencyManagement.applicationNumber
                ) {
                    this.isCaseNumberDisabled = true;
                    this.isAppNumberDisabled = false;
                } else {
                    this.isAppNumberDisabled = true;
                    this.isCaseNumberDisabled = false;
                }
            }
        } catch (error) {
            console.error(error);
        }
    };
    /**
     * @function : handleCaseNumberChange
     * @description	: To handle Case Number change.
     * @param  {object} event - .
     */
    handleCaseNumberChange = event => {
        try {
            const caseNumber = event.detail.value;
            this.caseNumber = caseNumber;
            if (caseNumber !== "" && caseNumber !== null) {
                const radioRef = this.template.querySelectorAll(
                    sspConstants.agencyManagement.sspMultiLineRadioInput
                );
                radioRef.forEach(element => {
                    if (
                        element.value ===
                            sspConstants.agencyManagement.caseNumber &&
                        !element.checked
                    ) {
                        element.checked = true;
                        element.click();
                    }
                });
                this.isAppNumberDisabled = true;
            }
        } catch (error) {
            console.error(error);
        }
    };

    /**
     * @function : searchIndividualClick
     * @description	: To Search Individual based on entered criteria.
     */
    searchIndividualClick = () => {
        try {
            this.showSpinner = true;
            const sClientData = {};
            this.isToShow = false;
            this.isFullMatch = false;
            this.isPartialMatch = false;
            this.isNoMatch = false;
            const inputElement = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            this.checkValidations(inputElement);
            if (this.allowSave) {
                this.showErrorToast = false;
                inputElement.forEach(element => {
                    if (element.fieldName === "FirstName") {
                        sClientData.firstName = element.value;
                    }
                    if (element.fieldName === "LastName") {
                        sClientData.lastName = element.value;
                    }
                    if (element.fieldName === "MiddleName") {
                        sClientData.middleName = element.value;
                    }
                    if (element.fieldName === "SuffixCode__c") {
                        sClientData.suffix = element.value;
                    }
                    if (element.fieldName === "GenderCode__c") {
                        sClientData.gender = element.value;
                    }
                    if (element.fieldName === sspConstants.contactFields.BirthDate) {
                        sClientData.birthDate = element.value;
                    }
                    if (element.fieldName === "SSN__c") {
                        sClientData.ssn = element.value;
                    }
                    if (
                        !this.isCaseNumberDisabled &&
                        element.fieldName === "caseNumber"
                    ) {
                        sClientData.caseNumber = element.value;
                    }
                    if (
                        !this.isAppNumberDisabled &&
                        element.fieldName === "applicationNumber"
                    ) {
                        sClientData.applicationNumber = element.value;
                    }
                });
                this.sspAuthRepRelationshipText = formatLabels(
                    this.label.sspAuthRepRelationship,
                    [sClientData.firstName + " " + sClientData.lastName]
                );
                searchClientMCIService({
                    sClientDetails: JSON.stringify(sClientData)
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                           
                            //MCI Response Data
                            if (result.mapResponse.searchClientResponse) {
                                const searchClientResponse =
                                    result.mapResponse.searchClientResponse;
                                const mciDetails =
                                    searchClientResponse.mciDetails;
                                if (mciDetails) {
                                    this.isFullMatch = mciDetails.bIsFullMatch;
                                    this.isToShow = this.isFullMatch;
                                    this.isPartialMatch =
                                        mciDetails.bIsPartialMatch;
                                    this.isNoMatch = mciDetails.bIsNoMatch;
                                }
                                this.caseNumber =
                                    searchClientResponse.caseNumber;
                                this.applicationNumber =
                                    searchClientResponse.applicationNumber;
                                if(this.applicationNumber === ""){
                                    this.disableAddress = false;
                                    this.addressRecord = "";
                                }
                                this.loginUserDetails =
                                    searchClientResponse.loginUserDetails;
                                this.sourceIndividualId = searchClientResponse.sourceIndividualId.join(
                                    ";"
                                );
                               
                                if ("dcDataId" in searchClientResponse) {
                                    this.dcDataId = searchClientResponse.dcDataId;
                                }else{
                                this.dcDataId = JSON.stringify(
                                    this.loginUserDetails[0].Contact.DCDataId__c
                                );
                                }
                               
                            }
                            //Requests access to an existing case and there is a partial match.
                            if (this.isPartialMatch) {
                                this.disabledRequestAccess = true;
                                this.authRequestPartialMatch = true;
                                this.showNextStepScreen = true;
                            }
                            //Req access to an existing case for a client and there is no match (or a full match where the case was inactive)
                            else if (this.isNoMatch) {
                                this.disabledRequestAccess = true;
                                this.noCaseMatch = true;
                                this.showNextStepScreen = true;
                              
                            } else if (this.isFullMatch) {
                                this.disabledRequestAccess = false;
                                //RSSP_DC Response Data
                                if (
                                    result.mapResponse.reverseSSPDCResponse &&
                                    result.mapResponse.reverseSSPDCResponse
                                        .reverseSSPDCDetails &&
                                    Object.keys(result.mapResponse.reverseSSPDCResponse
                                        .reverseSSPDCDetails).length > 0 //Tracker Defect-56
                                ) {
                                    this.reverseSSPDCResponse =
                                        Object.keys(
                                            result.mapResponse
                                                .reverseSSPDCResponse
                                                .reverseSSPDCDetails
                                        ).length > 0
                                            ? result.mapResponse
                                                  .reverseSSPDCResponse
                                                  .reverseSSPDCDetails
                                            : null;

                                    //Start - Added by kyathi for Pre populate & disable Address
                                    const authorizeInfoList = this
                                        .reverseSSPDCResponse
                                        .AuthrepandAssiterClientInfo;
                                    const loginUserDetails =
                                        result.mapResponse.searchClientResponse
                                            .loginUserDetails;
                                    let authInfoMatchFound = false;
                                    if (
                                        !sspUtility.isUndefinedOrNull(
                                            this.caseNumber
                                        )
                                    ) {
                                        authorizeInfoList.forEach(
                                            authInfoItem => {
                                                if (
                                                    this.caseNumber ===
                                                        authInfoItem.CaseNumber &&
                                                    loginUserDetails[0].Contact
                                                        .DCDataId__c ===
                                                        parseInt(
                                                            authInfoItem.UserId
                                                        )
                                                ) {
                                                    authInfoMatchFound = true;
                                                    this.setAddressField(
                                                        authInfoItem
                                                    );
                                                    return;
                                                }
                                            }
                                        );
                                        if (!authInfoMatchFound) {
                                            this.disableAddress = false;
                                            this.addressRecord = "";
                                        }
                                    }
                                    //End - Added by kyathi for Pre populate & disable Address
                                }
                                //Start - Application Response Data
                                else if (
                                    result.mapResponse.applicationResponse &&
                                    result.mapResponse.applicationResponse
                                        .length > 0
                                ) {
                                    this.existingAccountContactList =
                                        result.mapResponse.existingACRResponse;
                                    const applicationInfoList =
                                        result.mapResponse.applicationResponse;
                                    applicationInfoList.forEach(element => {
                                        if (element.IsHeadOfHousehold__c) {
                                            const application = {};
                                            application.ApplicationNumber = element
                                                .SSP_Application__r.Name
                                                ? element.SSP_Application__r
                                                      .Name
                                                : "";
                                            application.ProgramCode = element
                                                .SSP_Application__r
                                                .ProgramsApplied__c
                                                ? element.SSP_Application__r
                                                      .ProgramsApplied__c
                                                : "";
                                            application.LastUpdatedDate = element
                                                .SSP_Application__r
                                                .LastModifiedDate
                                                ? element.SSP_Application__r
                                                      .LastModifiedDate
                                                : "";
                                            application.UserId = element
                                                .SSP_Member__r.Contact__r
                                                .DCDataId__c
                                                ? element.SSP_Member__r
                                                      .Contact__r.DCDataId__c
                                                : "";
                                            application.FirstName = element
                                                .SSP_Member__r.Contact__r
                                                .FirstName
                                                ? element.SSP_Member__r
                                                      .Contact__r.FirstName
                                                : "";
                                            application.LastName = element
                                                .SSP_Member__r.Contact__r
                                                .LastName
                                                ? element.SSP_Member__r
                                                      .Contact__r.LastName
                                                : "";
                                            application.Email = element
                                                .SSP_Member__r.Email__c
                                                ? element.SSP_Member__r.Email__c
                                                : "";
                                            application.PreferredNotificationMethodCode = element
                                                .SSP_Member__r
                                                .PreferredNotificationMethodCode__c
                                                ? element.SSP_Member__r
                                                      .PreferredNotificationMethodCode__c
                                                : "";
                                            application.PreferredWrittenLanguageCode = element
                                                .SSP_Member__r
                                                .PreferredWrittenLanguageCode__c
                                                ? element.SSP_Member__r
                                                      .PreferredWrittenLanguageCode__c
                                                : "";
                                            application.PrimaryPhoneNumber = element
                                                .SSP_Member__r
                                                .PrimaryPhoneNumber__c
                                                ? element.SSP_Member__r
                                                      .PrimaryPhoneNumber__c
                                                : "";
                                            this.applicationResponseList.push(
                                                application
                                            );
                                        }
                                    });
                                    if (
                                        this.existingAccountContactList[0]
                                            .Street__c &&
                                        this.existingAccountContactList[0]
                                            .City__c &&
                                        this.existingAccountContactList[0]
                                            .SSP_State__c &&
                                        (this.existingAccountContactList[0]
                                            .Zipcode4__c ||
                                            this.existingAccountContactList[0]
                                                .Zipcode5__c)
                                    ) {
                                        this.setAddressField(
                                            this.existingAccountContactList[0]
                                        );
                                    }
                                } else {
                                    this.disabledRequestAccess = true;
                                    this.noCaseMatch = true;
                                    this.showNextStepScreen = true;
                                   
                                }
                                //End - Application Response Data
                            }
                            this.showSpinner = false;
                            this.showErrorModal = false;
                        } else if (!result.bIsSuccess) {
                            console.error(
                                "Error occurred in searchIndividualClick of sspAuthRepAccessRequest page" +
                                    result.mapResponse.ERROR
                            );
                            this.showErrorModal = true;
                            this.disabledRequestAccess = true;
                            this.showSpinner = false;
                        }
                    })
                    .catch(err => {
                        this.showSpinner = false;
                    });
            } else {
                this.showSpinner = false;
                this.disabledRequestAccess = true;
                this.showErrorToast = true;
            }
        } catch (error) {
            console.error(
                "Error occurred in searchIndividualClick of sspAuthRepAccessRequest page" +
                    JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    };

    /**
     * @function : requestAccessClick
     * @description	: To Request Access for client case/Application And Update the Address & Relationship data.
     */
    requestAccessClick = () => {
        try {
            this.showSpinner = true;
            const inputElement = this.template.querySelectorAll(
                ".ssp-applicationInputElement"
            );
            this.checkValidations(inputElement);
            //Added by kyathi
            const programPermissionItems = this.template.querySelectorAll(
                ".ssp-programApplicationInputs"
            );
            let hasError = false;
            let isChecked = false;
            for (let i = 0; i < programPermissionItems.length; i++) {
                if (!hasError) {
                    hasError = programPermissionItems[i].handleValidations();
                } else {
                    programPermissionItems[i].handleValidations();
                }
                if (!isChecked) {
                    isChecked = programPermissionItems[i].programCheckbox;
                }
            }

            if (!isChecked) {
                this.showError = true;
            }
            if (!isChecked || hasError) {
                this.showErrorToast = true;
            } else {
                this.showErrorToast = false;
            }
            let addressError = [];
            if (!this.disableAddress) {
                addressError = this.template
                    .querySelector(".addressLineClass")
                    .ErrorMessages();
            }
            if (addressError.length) {
                this.showErrorToast = true;
            }
            //Added till here
            if (!this.showErrorToast && this.allowSave) {
                const saveRecord = {};
                const accountContact = {};
                let programPermission = {}; //Change variable from const to let Tracker Defect-56
                inputElement.forEach(element => {
                    if (
                        element.fieldName ===
                        "RepresentativeRelationshipCode__c"
                    ) {
                        accountContact[sspConstants.accountContactRelationFields.RepresentativeRelationshipCode__c] =
                            element.value;
                    }
                });
                programPermissionItems.forEach(element => {
                    if (
                        element.programName === sspConstants.programValues.MA &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.MA] =
                            element.selectedPermission;
                    }
                    if (
                        element.programName === sspConstants.programValues.SN &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.SN] =
                            element.selectedPermission;
                    }
                    if (
                        element.programName === sspConstants.programValues.SS &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.SS] =
                            element.selectedPermission;
                    }
                    if (
                        element.programName === sspConstants.programValues.KP &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.KP] =
                            element.selectedPermission;
                    }
                    if (
                        element.programName === sspConstants.programValues.KT &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.KT] =
                            element.selectedPermission;
                    }
                    if (
                        element.programName === sspConstants.programValues.CC &&
                        element.programCheckbox
                    ) {
                        programPermission[sspConstants.ACRFieldAPINames.CC] =
                            element.selectedPermission;
                    }
                });
                accountContact.programPermission = programPermission;
                let contact = {};
                contact = this.bindAddressFields(contact);
                accountContact.addressDetails = contact;
                saveRecord.accountContactRelation = accountContact;
                saveRecord.sourceIndividualId = this.sourceIndividualId;
                saveRecord.caseNumber = this.caseNumber;
                saveRecord.applicationNumber = this.applicationNumber;
                saveRecord.loginUserDetails = this.loginUserDetails;
                saveRecord.reverseSSPDCResponse = this.reverseSSPDCResponse;
                saveRecord.applicationResponse = this.applicationResponseList;
                requestAccess({
                    sRequestAccessDetails: JSON.stringify(saveRecord)
                })
                    .then(result => {
                        if (result.bIsSuccess) {
                            
                            if (this.isFullMatch) {
                                //Start - Tracker Defect-56
                                const requestAccessData = result.mapResponse.requestAccessData;
                                if(requestAccessData && requestAccessData.sProgramsPermission) {
                                    let sProgramsPermission = JSON.parse(requestAccessData.sProgramsPermission);
                                    if(sProgramsPermission && Object.keys(sProgramsPermission).length > 0) {
                                        programPermission = sProgramsPermission;
                                    }
                                }
                                //End - Tracker Defect-56
                                if (
                                    this.reverseSSPDCResponse &&
                                    this.applicationNumber === ""
                                ) {
                                    const caseInfoList = this
                                        .reverseSSPDCResponse.CaseInfo;
                                    const authorizeInfoList = this
                                        .reverseSSPDCResponse
                                        .AuthrepandAssiterClientInfo;
                                        if(programPermission.PermissionLevel_Medicaid__c){
                                    programPermission[sspConstants.ACRFieldAPINames.MA] = programPermission.PermissionLevel_Medicaid__c;
                                }
                                if(programPermission.PermissionLevel_SNAP__c){
                                    programPermission[sspConstants.ACRFieldAPINames.SN] = programPermission.PermissionLevel_SNAP__c;
                                      
                                    }
                                    if(programPermission.PermissionLevel_StateSupp__c){
                                    programPermission[sspConstants.ACRFieldAPINames.SS] = programPermission.PermissionLevel_StateSupp__c;
                                       
                                    }
                                    if(programPermission.PermissionLevel_KIHIPP__c){
                                    programPermission[sspConstants.ACRFieldAPINames.KP] = programPermission.PermissionLevel_KIHIPP__c;
                                        
                                    }
                                    if(programPermission.PermissionLevel_KTAP__c){
                                    programPermission[sspConstants.ACRFieldAPINames.KT] = programPermission.PermissionLevel_KTAP__c;
                                       
                                    }
                                    if(programPermission.PermissionLevel_CCAP__c){
                                    programPermission[sspConstants.ACRFieldAPINames.CC] = programPermission.PermissionLevel_CCAP__c;
                                       
                                    }
                                    if (
                                        caseInfoList &&
                                        caseInfoList.length > 0
                                    ) {
                                        const checkPermissionList = []; //Added as part of Tracker Defect-56
                                        caseInfoList.forEach(element => {
                                            //Req access to an existing case for a client and they already have the access being requested.
                                            if (
                                                authorizeInfoList &&
                                                authorizeInfoList.length > 0
                                            ) {
                                                authorizeInfoList.forEach(
                                                    authorize => {
                                                        //Start - Added as part of Tracker Defect-56
                                                        if (authorize && element &&
                                                            authorize.UserId === JSON.stringify(this.dcDataId) &&
                                                            authorize.CaseNumber === element.CaseNumber) {
                                                            if (programPermission.PermissionLevel_Medicaid__c) {
                                                                const isMedicaid = programPermission.PermissionLevel_Medicaid__c ===
                                                                    authorize.PermissionLevelMedicaid;
                                                                checkPermissionList.push(isMedicaid);
                                                            }
                                                            if (programPermission.PermissionLevel_SNAP__c) {
                                                                const isSNAP = programPermission.PermissionLevel_SNAP__c ===
                                                                    authorize.PermissionLevelSNAP;
                                                                checkPermissionList.push(isSNAP);
                                                            }
                                                            if (programPermission.PermissionLevel_StateSupp__c) {
                                                                const isSS = programPermission.PermissionLevel_StateSupp__c ===
                                                                    authorize.PermissionLevelStateSupp;
                                                                checkPermissionList.push(isSS);
                                                            }
                                                            if (programPermission.PermissionLevel_KIHIPP__c) {
                                                                const isKHIPP = programPermission.PermissionLevel_KIHIPP__c ===
                                                                    authorize.PermissionLevelKIHIPP;
                                                                checkPermissionList.push(isKHIPP);
                                                            }
                                                            if (programPermission.PermissionLevel_KTAP__c) {
                                                                const isKTAP = programPermission.PermissionLevel_KTAP__c ===
                                                                    authorize.PermissionLevelKTAP;
                                                                checkPermissionList.push(isKTAP);
                                                            }
                                                            if (programPermission.PermissionLevel_CCAP__c) {
                                                                const isCCAP = programPermission.PermissionLevel_CCAP__c ===
                                                                    authorize.PermissionLevelCCAP;
                                                                checkPermissionList.push(isCCAP);
                                                            }

                                                            if (checkPermissionList.length > 0 && !checkPermissionList.includes(false)) {
                                                                this.authAssisterHaveAccess = true;
                                                                this.showNextStepScreen = true;
                                                            }
                                                        }
                                                        //End - Added as part of Tracker Defect-56
                                                    }
                                                );
                                            }
                                        });
                                        if (!this.showNextStepScreen && //Added for Tracker Defect-56
                                            !this.authAssisterHaveAccess) {
                                            // Start - Req access to an existing case for a client and they already have the same pending request. Client has not yet responded to the request.
                                            const oldAccountContactList =
                                                result.mapResponse
                                                    .requestAccessData.oldARC;
                                            const checkPermissionList = [];
                                            if (
                                                oldAccountContactList &&
                                                oldAccountContactList.length > 0
                                            ) {
                                                oldAccountContactList.forEach(
                                                    element => {
                                                        if (!sspUtility.isUndefinedOrNull(element.RequestAccessPermission__c)){
                                                        const oldRequest = JSON.parse(
                                                            element.RequestAccessPermission__c
                                                        );
                                                        if (
                                                            programPermission.PermissionLevel_Medicaid__c
                                                        ) {
                                                            const isMedicaid =
                                                                programPermission.PermissionLevel_Medicaid__c ===
                                                                oldRequest.PermissionLevel_Medicaid__c;
                                                            checkPermissionList.push(
                                                                isMedicaid
                                                            );
                                                        }
                                                        if (
                                                            programPermission.PermissionLevel_SNAP__c
                                                        ) {
                                                            const isSNAP =
                                                                programPermission.PermissionLevel_SNAP__c ===
                                                                oldRequest.PermissionLevel_SNAP__c;
                                                            checkPermissionList.push(
                                                                isSNAP
                                                            );
                                                        }
                                                        if (
                                                            programPermission.PermissionLevel_StateSupp__c
                                                        ) {
                                                            const isSS =
                                                                programPermission.PermissionLevel_StateSupp__c ===
                                                                oldRequest.PermissionLevel_StateSupp__c;
                                                            checkPermissionList.push(
                                                                isSS
                                                            );
                                                        }
                                                        if (
                                                            programPermission.PermissionLevel_KIHIPP__c
                                                        ) {
                                                            const isKHIPP =
                                                                programPermission.PermissionLevel_KIHIPP__c ===
                                                                oldRequest.PermissionLevel_KIHIPP__c;
                                                            checkPermissionList.push(
                                                                isKHIPP
                                                            );
                                                        }
                                                        if (
                                                            programPermission.PermissionLevel_KTAP__c
                                                        ) {
                                                            const isKTAP =
                                                                programPermission.PermissionLevel_KTAP__c ===
                                                                oldRequest.PermissionLevel_KTAP__c;
                                                            checkPermissionList.push(
                                                                isKTAP
                                                            );
                                                        }
                                                        if (
                                                            programPermission.PermissionLevel_CCAP__c
                                                        ) {
                                                            const isCCAP =
                                                                programPermission.PermissionLevel_CCAP__c ===
                                                                oldRequest.PermissionLevel_CCAP__c;
                                                            checkPermissionList.push(
                                                                isCCAP
                                                            );
                                                        }
                                                    }
                                                    }
                                                );

                                                if (
                                                    checkPermissionList.length >
                                                        0 &&
                                                    !checkPermissionList.includes(
                                                        false
                                                    )
                                                ) {
                                                    this.accessPendingRequest = true;
                                                    this.showNextStepScreen = true;
                                                }
                                            }
                                            //End
                                        }
                                        if (!this.showNextStepScreen && //Added for Tracker Defect-56
                                            !this.accessPendingRequest) {
                                            caseInfoList.forEach(element => {
                                                //Req Access for a client and there is a full match. Client has been sent an electronic notification.
                                                if (
                                                    element.PreferredNotificationMethodCode ===
                                                        "ES" ||
                                                    element.PreferredNotificationMethodCode ===
                                                        "EE"
                                                ) {
                                                    this.authFullMatchSentNotification = true;
                                                    this.showNextStepScreen = true;
                                                }
                                                //Req Access to MA only for a client and there is a full match. Client's communication preferences do not include electronic communication.
                                                if (
                                                    element.PreferredNotificationMethodCode !==
                                                        "ES" &&
                                                    element.PreferredNotificationMethodCode !==
                                                        "EE" &&
                                                    programPermission.PermissionLevel_Medicaid__c !==
                                                        undefined &&
                                                    programPermission.PermissionLevel_SNAP__c ===
                                                        undefined &&
                                                    programPermission.PermissionLevel_StateSupp__c ===
                                                        undefined &&
                                                    programPermission.PermissionLevel_KIHIPP__c ===
                                                        undefined &&
                                                    programPermission.PermissionLevel_KTAP__c ===
                                                        undefined &&
                                                    programPermission.PermissionLevel_CCAP__c ===
                                                        undefined
                                                ) {
                                                    this.clientNoCommunicationPref = true;
                                                    this.showNextStepScreen = true;
                                                }
                                                //Req Access to MA and any other program and there is a full match. Client's communication preferences do not include electronic communication.
                                                if (
                                                    element.PreferredNotificationMethodCode !==
                                                        "ES" &&
                                                    element.PreferredNotificationMethodCode !==
                                                        "EE" &&
                                                    programPermission.PermissionLevel_Medicaid__c !==
                                                        undefined &&
                                                    (programPermission.PermissionLevel_SNAP__c !==
                                                        undefined ||
                                                        programPermission.PermissionLevel_StateSupp__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_KIHIPP__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_KTAP__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_CCAP__c !==
                                                            undefined)
                                                ) {
                                                    this.anyProgramNoCommunicationPref = true;
                                                    this.showNextStepScreen = true; //Added for Tracker Defect-56
                                                }
                                                //Req Access to non-MA programs and there is a full match. Client's communication preferences do not include electronic communication.
                                                if (
                                                    element.PreferredNotificationMethodCode !==
                                                        "ES" &&
                                                    element.PreferredNotificationMethodCode !==
                                                        "EE" &&
                                                    programPermission.PermissionLevel_Medicaid__c ===
                                                        undefined &&
                                                    (programPermission.PermissionLevel_SNAP__c !==
                                                        undefined ||
                                                        programPermission.PermissionLevel_StateSupp__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_KIHIPP__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_KTAP__c !==
                                                            undefined ||
                                                        programPermission.PermissionLevel_CCAP__c !==
                                                            undefined)
                                                ) {
                                                    this.authRequestNonMedicaidAccess = true;
                                                    this.showNextStepScreen = true;
                                                }
                                            });
                                        }
                                    }
                                } else if (
                                    this.applicationResponseList &&
                                    this.applicationResponseList.length > 0 &&
                                    this.applicationNumber !== ""
                                ) {
                                    const accountContactObject = this
                                        .existingAccountContactList[0];
                                    
                                    //Req access to an existing case for a client and they already have the access being requested.
                                    //Start - Added as part of Tracker Defect-56
                                    if (accountContactObject) {
                                        const checkPermissionList = [];
                                        if (programPermission.PermissionLevel_Medicaid__c) {
                                            const isMedicaid = programPermission.PermissionLevel_Medicaid__c ===
                                                accountContactObject.PermissionLevel_Medicaid__c;
                                            checkPermissionList.push(isMedicaid);
                                        }
                                        if (programPermission.PermissionLevel_SNAP__c) {
                                            const isSNAP = programPermission.PermissionLevel_SNAP__c ===
                                                accountContactObject.PermissionLevel_SNAP__c;
                                            checkPermissionList.push(isSNAP);
                                        }
                                        if (programPermission.PermissionLevel_StateSupp__c) {
                                            const isSS = programPermission.PermissionLevel_StateSupp__c ===
                                                accountContactObject.PermissionLevel_StateSupp__c;
                                            checkPermissionList.push(isSS);
                                        }
                                        if (programPermission.PermissionLevel_KIHIPP__c) {
                                            const isKHIPP = programPermission.PermissionLevel_KIHIPP__c ===
                                                accountContactObject.PermissionLevel_KIHIPP__c;
                                            checkPermissionList.push(isKHIPP);
                                        }
                                        if (programPermission.PermissionLevel_KTAP__c) {
                                            const isKTAP = programPermission.PermissionLevel_KTAP__c ===
                                                accountContactObject.PermissionLevel_KTAP__c;
                                            checkPermissionList.push(isKTAP);
                                        }
                                        if (programPermission.PermissionLevel_CCAP__c) {
                                            const isCCAP = programPermission.PermissionLevel_CCAP__c ===
                                                accountContactObject.PermissionLevel_CCAP__c;
                                            checkPermissionList.push(isCCAP);
                                        }

                                        if (checkPermissionList.length > 0 && !checkPermissionList.includes(false)) {
                                            this.authAssisterHaveAccess = true;
                                            this.showNextStepScreen = true;
                                        }
                                    }
                                    //End - Added as part of Tracker Defect-56

                                    if (
                                        !this.showNextStepScreen && //Added for Tracker Defect-56
                                        !this.authAssisterHaveAccess &&
                                        accountContactObject !== undefined
                                    ) {
                                        // Start - Req access to an existing case for a client and they already have the same pending request. Client has not yet responded to the request.
                                        const checkPermissionList = [];
                                        if (!sspUtility.isUndefinedOrNull(accountContactObject.RequestAccessPermission__c)) { //Tracker Defect-56
                                        const pendingPermission = JSON.parse(
                                            accountContactObject.RequestAccessPermission__c
                                        );
                                        if (
                                            programPermission.PermissionLevel_Medicaid__c
                                        ) {
                                            const isMedicaid =
                                                programPermission.PermissionLevel_Medicaid__c ===
                                                pendingPermission.PermissionLevel_Medicaid__c;
                                            checkPermissionList.push(
                                                isMedicaid
                                            );
                                        }
                                        if (
                                            programPermission.PermissionLevel_SNAP__c
                                        ) {
                                            const isSNAP =
                                                programPermission.PermissionLevel_SNAP__c ===
                                                pendingPermission.PermissionLevel_SNAP__c;
                                            checkPermissionList.push(isSNAP);
                                        }
                                        if (
                                            programPermission.PermissionLevel_StateSupp__c
                                        ) {
                                            const isSS =
                                                programPermission.PermissionLevel_StateSupp__c ===
                                                pendingPermission.PermissionLevel_StateSupp__c;
                                            checkPermissionList.push(isSS);
                                        }
                                        if (
                                            programPermission.PermissionLevel_KIHIPP__c
                                        ) {
                                            const isKHIPP =
                                                programPermission.PermissionLevel_KIHIPP__c ===
                                                pendingPermission.PermissionLevel_KIHIPP__c;
                                            checkPermissionList.push(isKHIPP);
                                        }
                                        if (
                                            programPermission.PermissionLevel_KTAP__c
                                        ) {
                                            const isKTAP =
                                                programPermission.PermissionLevel_KTAP__c ===
                                                pendingPermission.PermissionLevel_KTAP__c;
                                            checkPermissionList.push(isKTAP);
                                        }
                                        if (
                                            programPermission.PermissionLevel_CCAP__c
                                        ) {
                                            const isCCAP =
                                                programPermission.PermissionLevel_CCAP__c ===
                                                pendingPermission.PermissionLevel_CCAP__c;
                                            checkPermissionList.push(isCCAP);
                                        }
                                        } //Tracker Defect-56
                                        if (
                                            checkPermissionList.length > 0 &&
                                            !checkPermissionList.includes(false)
                                        ) {
                                            this.accessPendingRequest = true;
                                            this.showNextStepScreen = true;
                                        }
                                    }
                                    if (!this.showNextStepScreen && //Added for Tracker Defect-56
                                        !this.accessPendingRequest) {
                                        const application = this
                                            .applicationResponseList[0];
                                        //Req Access for a client and there is a full match. Client has been sent an electronic notification.
                                        if (
                                            application.PreferredNotificationMethodCode ===
                                                "ES" ||
                                            application.PreferredNotificationMethodCode ===
                                                "EE"
                                        ) {
                                            this.authFullMatchSentNotification = true;
                                            this.showNextStepScreen = true;
                                        }
                                        //Req Access to MA only for a client and there is a full match. Client's communication preferences do not include electronic communication.
                                        if (
                                            application.PreferredNotificationMethodCode !==
                                                "ES" &&
                                            application.PreferredNotificationMethodCode !==
                                                "EE" &&
                                            programPermission.PermissionLevel_Medicaid__c !==
                                                undefined &&
                                            programPermission.PermissionLevel_SNAP__c ===
                                                undefined &&
                                            programPermission.PermissionLevel_StateSupp__c ===
                                                undefined &&
                                            programPermission.PermissionLevel_KIHIPP__c ===
                                                undefined &&
                                            programPermission.PermissionLevel_KTAP__c ===
                                                undefined &&
                                            programPermission.PermissionLevel_CCAP__c ===
                                                undefined
                                        ) {
                                            this.clientNoCommunicationPref = true;
                                            this.showNextStepScreen = true;
                                        }
                                        //Req Access to MA and any other program and there is a full match. Client's communication preferences do not include electronic communication.
                                        if (
                                            application.PreferredNotificationMethodCode !==
                                                "ES" &&
                                            application.PreferredNotificationMethodCode !==
                                                "EE" &&
                                            programPermission.PermissionLevel_Medicaid__c !==
                                                undefined &&
                                            (programPermission.PermissionLevel_SNAP__c !==
                                                undefined ||
                                                programPermission.PermissionLevel_StateSupp__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_KIHIPP__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_KTAP__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_CCAP__c !==
                                                    undefined)
                                        ) {
                                            this.anyProgramNoCommunicationPref = true;
                                            this.showNextStepScreen = true;
                                        }
                                        //Req Access to non-MA programs and there is a full match. Client's communication preferences do not include electronic communication.
                                        if (
                                            application.PreferredNotificationMethodCode !==
                                                "ES" &&
                                            application.PreferredNotificationMethodCode !==
                                                "EE" &&
                                            programPermission.PermissionLevel_Medicaid__c ===
                                                undefined &&
                                            (programPermission.PermissionLevel_SNAP__c !==
                                                undefined ||
                                                programPermission.PermissionLevel_StateSupp__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_KIHIPP__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_KTAP__c !==
                                                    undefined ||
                                                programPermission.PermissionLevel_CCAP__c !==
                                                    undefined)
                                        ) {
                                            this.authRequestNonMedicaidAccess = true;
                                            this.showNextStepScreen = true;
                                        }
                                    }
                                }
                            }

                            this.showSpinner = false;  
                          this.showNextStepScreen = true;
                        } else if (!result.bIsSuccess) {
                            this.showSpinner = false;
                            console.error(
                                "Error occurred in requestAccessClick of sspAuthRepAccessRequest page" +
                                    result.mapResponse.ERROR
                            );
                            this.showNextStepScreen = true;
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                    });
            }
            //Start - Tracker Defect-56
            else {
                this.showSpinner = false;
            }
            //End - Added for Tracker Defect-56
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "Error occurred in  of requestAccessClick page" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on contact record.
     * @param {object} contact - Contact record.
     */
    bindAddressFields = contact => {
        try {
            const addressLineClass = this.template.querySelector(
                sspConstants.classNames.addressLineClass
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                contact[
                    sspConstants.contactFields.Street__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                contact[
                    sspConstants.contactFields.AddressLine2__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                contact[
                    sspConstants.contactFields.City__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                contact[
                    sspConstants.contactFields.CountyCode__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                contact[
                    sspConstants.contactFields.SSP_State__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                const zipCode = physicalAddress.postalCode;
                if (!sspUtility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        contact[
                            sspConstants.contactFields.ZipCode4__c
                        ] = zipCode;
                        contact[sspConstants.contactFields.ZipCode5__c] = "";
                    } else {
                        contact[
                            sspConstants.contactFields.ZipCode5__c
                        ] = zipCode;
                        contact[sspConstants.contactFields.ZipCode4__c] = "";
                    }
                }
            }
        } catch (error) {
            console.error(
                "Error occurred in bindAddressFields of sspAuthRepAccessRequest page" +
                    JSON.stringify(error.message)
            );
        }
        return contact;
    };
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
    };
    /**
     * @function 		: handleHideError.
     * @description 	: this method is handle validation errors.
    
     * */
    handleHideError = () => {
        try {
            const programPermissionItems = this.template.querySelectorAll(
                ".ssp-programApplicationInputs"
            );
            let hasError = true;
            for (let i = 0; i < programPermissionItems.length; i++) {
                if (programPermissionItems[i].programCheckbox) {
                    hasError = false;
                }
            }
            this.showError = hasError;
        } catch (error) {
            console.error("failed in handleHideError" + JSON.stringify(error));
        }
    };
    /**
     * @function : closeError
     * @description : Method used to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
        } catch (error) {
            console.error("failed in closeError" + JSON.stringify(error));
        }
    };
    /**
     * @function : handleAppNumberChange
     * @description	: To handle Application Number change.
     * @param  {object} event - .
     */
    handleAppNumberChange = event => {
        try {
            const appNumber = event.detail.value;
            this.applicationNumber = appNumber;
            if (appNumber !== "" && appNumber !== null) {
                const radioRef = this.template.querySelectorAll(
                    sspConstants.agencyManagement.sspMultiLineRadioInput
                );
                radioRef.forEach(element => {
                    if (
                        element.value ===
                            sspConstants.agencyManagement.applicationNumber &&
                        !element.checked
                    ) {
                        element.checked = true;
                        element.click();
                    }
                });
                this.isCaseNumberDisabled = true;
            }
        } catch (error) {
            console.error(error);
        }
    };
    /**
     * @function : backJs
     * @description	: To handle dashboard redirect.
     */
    backJs = () => {
        try {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: sspConstants.url.home
                }
            });
        } catch (error) {
            console.error(error);
        }
    };
    setAddressField = authInfoItem => {
        const addressRecord = {};
        const sFields = {};
        const addressLine1 = {};
        addressLine1.displayValue = null;
        addressLine1.value =
            authInfoItem.Street || authInfoItem.Street__c || null;
        sFields[sspConstants.contactFields.Street__c] = addressLine1;

        const addressLine2 = {};
        addressLine2.displayValue = null;
        addressLine2.value =
            authInfoItem.AddressLine2 || authInfoItem.AddressLine2__c || null;
        sFields[sspConstants.contactFields.AddressLine2__c] = addressLine2;

        const countyCode = {};
        countyCode.displayValue = null;
        countyCode.value =
            authInfoItem.CountyCode || authInfoItem.CountyCode__c || null;

        sFields[sspConstants.contactFields.CountyCode__c] = countyCode;

        const stateCode = {};
        stateCode.displayValue = null;
        stateCode.value =
            authInfoItem.SSP_State || authInfoItem.SSP_State__c || null;

        sFields[sspConstants.contactFields.SSP_State__c] = stateCode;

        const zipCode4 = {};
        zipCode4.displayValue = null;
        zipCode4.value =
            authInfoItem.Zipcode4 || authInfoItem.Zipcode4__c || null;
        sFields[sspConstants.contactFields.ZipCode4__c] = zipCode4;

        const zipCode5 = {};
        zipCode5.displayValue = null;
        zipCode5.value =
            authInfoItem.Zipcode5 || authInfoItem.Zipcode5__c || null;
        sFields[sspConstants.contactFields.ZipCode5__c] = zipCode5;

        addressRecord.fields = sFields;
        this.addressRecord = JSON.parse(JSON.stringify(addressRecord));
        this.disableAddress = true;
    };
}