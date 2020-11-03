/**
 * Component Name - sspIndividualEnrollment.js.
 * Author         - Chaitanya Kanakia, Varun Kochar.
 * Description    - Used to display Enrollment Details of Individuals.
 * Date       	  - 20/12/2019.
 */
import { track, api, wire } from "lwc";
import sspConstants from "c/sspConstants";
import sspEnterIncomeNoticeMessage from "@salesforce/label/c.SSP_EnterIncomeNoticeMessage";
import sspIndividualAccessSave from "@salesforce/label/c.SSP_IndividualAccessSave";
import sspIndividualAccessCancel from "@salesforce/label/c.SSP_IndividualAccessCancel";
import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import sspEnrollmentDetailsTitle from "@salesforce/label/c.SSP_EnrollmentDetailsTitle";
import sspIndividualEnrollDesc from "@salesforce/label/c.SSP_IndividualEnrollDesc";
import sspIndividualEnrollEmployerName from "@salesforce/label/c.SSP_IndividualEnrollEmployerName";
import sspIndividualEnrollOtherEmployer from "@salesforce/label/c.SSP_IndividualEnrollOtherEmployer";
import sspIndividualEnrollNameOfEmployer from "@salesforce/label/c.SSP_IndividualEnrollNameOfEmployer";
import sspIndividualEnrollTobacco from "@salesforce/label/c.SSP_IndividualEnrollTobacco";
import sspIndividualEnrollMemberDetails from "@salesforce/label/c.SSP_IndividualEnrollMemberDetails";
import sspIndividualEnrollHaveMedicaid from "@salesforce/label/c.SSP_IndividualEnrollHaveMedicaid";
import sspIndividualEnrollMedicaidId from "@salesforce/label/c.SSP_IndividualEnrollMedicaidId";
import sspIndividualEnrollRelationship from "@salesforce/label/c.SSP_IndividualEnrollRelationship";
import sspIndividualEnrollRelation from "@salesforce/label/c.SSP_IndividualEnrollRelation";
import sspIndividualEnrollRelationAlt from "@salesforce/label/c.SSP_IndividualEnrollRelationAlt";
import sspIndividualEnrollPolicyDetail from "@salesforce/label/c.SSP_IndividualEnrollPolicyDetail";
import sspIndividualEnrollTypeOfCoverage from "@salesforce/label/c.SSP_IndividualEnrollTypeOfCoverage";
import sspIndividualEnrollCoverageStart from "@salesforce/label/c.SSP_IndividualEnrollCoverageStart";
import sspIndividualEnrollCoverageEnd from "@salesforce/label/c.SSP_IndividualEnrollCoverageEnd";
import sspIndividualEnrollRemovalReason from "@salesforce/label/c.SSP_IndividualEnrollRemovalReason";
import sspIndividualEnrollPleaseExplain from "@salesforce/label/c.SSP_IndividualEnrollPleaseExplain";
import sspIndividualEnrollRemovalReasonAlt from "@salesforce/label/c.SSP_IndividualEnrollRemovalReasonAlt";
import sspHealthCareApprovedMsg from "@salesforce/label/c.sspHealthCareApprovedMsg";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspIndividualEnrollSaveAlt from "@salesforce/label/c.SSP_IndividualEnrollSaveAlt";
import sspIndividualEnrollCancelAlt from "@salesforce/label/c.SSP_IndividualEnrollCancelAlt";
import sspGender from "@salesforce/label/c.SSP_Gender";
import sspDateOfBirth from "@salesforce/label/c.SSP_Dateofbirth";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspSocialSecurityNumber from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspSelectAtLeastOnePolicy from "@salesforce/label/c.SSP_SelectAtleastOnePolicy";
import sspProvideInfo from "@salesforce/label/c.SSP_ProvideInfo";
import sspUpToTenChars from "@salesforce/label/c.SSP_UptoTenChars";
import sspEnterEmployerName from "@salesforce/label/c.SSP_EnterEmpName";
import sspAccessDetailsTitle from "@salesforce/label/c.SSP_AccessDetailsTitle";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import fetchMemberDetails from "@salesforce/apex/SSP_IndividualEnrollmentDetails.fetchMemberDetails";
import saveIndividualDetails from "@salesforce/apex/SSP_IndividualEnrollmentDetails.saveIndividualDetails";
import RELATIONSHIPCODE_FIELD from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.RelationshipCode__c";
import GENDER_FIELD from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.Gender__c";
import ENDREASON_FIELD from "@salesforce/schema/SSP_HealthInsuranceFacilityType__c.EndReason__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import INSURANCECOVEREDINDIVIDUAL_OBJECT from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c";
import HEALTHINSURANCEFACILITYTYPE_OBJECT from "@salesforce/schema/SSP_HealthInsuranceFacilityType__c";
import { formatLabels } from "c/sspUtility";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtAddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtAddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtCity__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtStateCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtZipCode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtZipCode5__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtCountryCode__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_InsuranceCoveredIndiv__c.ExtCountyCode__c";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import COUNTRY from "@salesforce/label/c.Country";
import ZIP from "@salesforce/label/c.Zip_Code";
import { getRecord } from "lightning/uiRecordApi";
import utility from "c/sspUtility";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import sspEnrollmentPhone from "@salesforce/label/c.sspEnrollmentPhone";
const yesLabel = sspYes;
const yesValue = sspConstants.sspIndividualEnrollmentFields.yesValue;
const noLabel = sspNo;
const noValue = sspConstants.sspIndividualEnrollmentFields.noValue;
const mapOfFacilityAndPolicyWrapper = new Map();
const memberFields = [
    PHYSICAL_ADDRESS_LINE1,
    PHYSICAL_ADDRESS_LINE2,
    PHYSICAL_ADDRESS_CITY,
    PHYSICAL_ADDRESS_STATE,
    PHYSICAL_ADDRESS_ZIP4,
    PHYSICAL_ADDRESS_ZIP5
];
const MA_FIELD_MAP = {
    addressLine1: {
        ...PHYSICAL_ADDRESS_LINE1,
        label: sspConstants.sspIndividualEnrollmentFields.Address
    },
    addressLine2: {
        ...PHYSICAL_ADDRESS_LINE2,
        label: sspConstants.sspIndividualEnrollmentFields.AddressLine2
    },
    city: {
        ...PHYSICAL_ADDRESS_CITY,
        label: CITY
    },
    country: {
        ...PHYSICAL_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    county: {
        ...PHYSICAL_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...PHYSICAL_ADDRESS_STATE,
        label: STATE
    },
    postalCode4: {
        ...PHYSICAL_ADDRESS_ZIP4,
        label: ZIP
    },
    postalCode: {
        ...PHYSICAL_ADDRESS_ZIP5,
        label: ZIP
    }
};

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
export default class SspIndividualEnrollment extends utility {
    @api memberName;
    @api memberFullName;
    @api memberLastName;
    @api policyList;
    @api isEnrolledInInsurance;
    @api mode;
    @api optList = [
        {
            label: yesLabel,
            value: yesValue
        },
        {
            label: noLabel,
            value: noValue
        }
    ];
    @api sspCoveredIndividualId;
    summaryTitle = "";
    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSave () {
        return this.allowSaveData;
    }
    set allowSave (value) {
        this.showSpinner = true;
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.allowSaveData = value;
        }
    }
    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value) {
            this.MetaDataListParent = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
            }
        }
    }

    @track cancelButtonAlt;
    @track saveButtonAlt;
    @track addressRecord;
    @track isMemberPolicyHolder = true;
    @track doesMemberHaveEmploymentRecords = true;
    @track memberIsOutsideOfHouseHold = false;
    @track existingPolicy = true;
    @track memberIsPolicyHolder = true;
    @track memberHasMedicaid;
    @track explainReasonOfRemoval = false;
    @track showSpinner = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track sspUsesTobacco;
    @track medicaidUser;
    @track individualMemberDetails;
    @track policyHolder;
    @track individualMemberDetailsWrapper;
    @track bUsesTobacco;
    @track bHaveMedicaid;
    @track isComponentLoaded = false;
    @track relationshipOptions;
    @track genderOptions;
    @track reasonForRemovalOptions;
    @track selectedEmployer;
    @track showOther = false;
    @track allowSaveData;
    @track MetaDataListParent;
    @track showEnrolledInInsurance;
    @track selectAtLeastOnePolicy;
    @track sspSSNOrMedicaidValidatorMessage;
    @track maxStringLengthValidator;
    @track sspEmployerNameIsRequired;
    @track hideAdditionalSection;
    @track newCoveredIndividual = true;
    @track isHealthCarePolicyApprove = false;
    @track employerList = [
        {
            id: "",
            label: sspConstants.sspIndividualEnrollmentFields.Other,
            value: sspConstants.sspIndividualEnrollmentFields.Other
        }
    ];
    @track enrollmentVerification = false;
    @track disableEmployerList;
    @track disableEmployerName;
    @track disableSocialSecurityNumber;
    @track disableGender;
    @track disableDateOfBirth;
    @track disableMedicaidToggle;
    @track disableMedicaidNumber;
    @track disableTobaccoToggle = false;
    @track disableRelationship;
    @track disableStartDate;
    @track disableEndDate;
    @track disableEndReason;
    @track disableOtherReason;
    @track disabledAddress;
    @track skipDisable;
    @track isExtPolicyHolder = false; //369047 changes
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isScreenNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    hasRendered=false;
    label = {
        sspBenefitsApplication,
        sspEnrollmentDetailsTitle,
        sspIndividualEnrollDesc,
        sspIndividualEnrollEmployerName,
        sspIndividualEnrollOtherEmployer,
        sspIndividualEnrollNameOfEmployer,
        sspIndividualEnrollTobacco,
        sspIndividualEnrollMemberDetails,
        sspIndividualEnrollHaveMedicaid,
        sspIndividualEnrollMedicaidId,
        sspIndividualEnrollRelationship,
        sspIndividualEnrollRelation,
        sspIndividualEnrollRelationAlt,
        sspIndividualEnrollPolicyDetail,
        sspIndividualEnrollTypeOfCoverage,
        sspIndividualEnrollCoverageStart,
        sspIndividualEnrollCoverageEnd,
        sspIndividualEnrollRemovalReason,
        sspIndividualEnrollPleaseExplain,
        sspIndividualEnrollRemovalReasonAlt,
        sspGender,
        sspDateOfBirth,
        sspAddressLine2,
        sspAddress,
        sspSocialSecurityNumber,
        sspSave,
        sspIndividualEnrollSaveAlt,
        sspCancel,
        sspIndividualEnrollCancelAlt,
        sspSelectAtLeastOnePolicy,
        sspProvideInfo,
        sspUpToTenChars,
        sspEnterEmployerName,
        toastErrorText,
        sspEnterIncomeNoticeMessage,
        sspAccessDetailsTitle,
        sspPageInformationVerified,
        sspHealthCareApprovedMsg,
        startBenefitsAppCallNumber,
        sspEnrollmentPhone
    };
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
    callUsAtApproved = `tel:${this.label.sspEnrollmentPhone}`;

    get screenRenderingStatus () {
        return this.isComponentLoaded && !this.isScreenNotAccessible;
    }

    get employerListDisabilityStatus () {
        return this.disableEmployerList || this.isReadOnlyUser;
    }

    get tobaccoDisabilityStatus () {
        return this.disableTobaccoToggle || this.isReadOnlyUser;
    }

    /*
     * @function : wiredGetMember
     * @description : This method used to get Address information
     */
    fieldMap = MA_FIELD_MAP;
    @wire(getRecord, {
        recordId: "$sspCoveredIndividualId",
        fields: memberFields
    })
    wiredGetMember (value) {
        this.wiredMember = value;
        const { error, data } = value;
        try {
            if (data) {
                this.individual = JSON.parse(JSON.stringify(data));
                this.addressRecord = this.individual;
                //this.addressRecord = JSON.parse(JSON.stringify(data));
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (e) {
            console.error(e);
        }
    }
    @wire(getObjectInfo, {
        objectApiName: INSURANCECOVEREDINDIVIDUAL_OBJECT
    })
    objectInfo;

    @wire(getObjectInfo, {
        objectApiName: HEALTHINSURANCEFACILITYTYPE_OBJECT
    })
    healthInsuranceObjectInfo;
    /*
     * @function : picklistValues
     * @description : This method used to get Relationship values
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: RELATIONSHIPCODE_FIELD
    })
    picklistValues ({ error, data }) {
        if (data) {
            //this.relationshipOptions = data.values;
            this.relationshipOptions = data.values.filter(item => item.value !== "1");
        } else if (error) {
            this.error = error;
        }
    }
    /*
     * @function : genderPicklistValues
     * @description : This method used to get Gender values
     */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: GENDER_FIELD
    })
    genderPicklistValues ({ error, data }) {
        if (data) {
            this.genderOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }
    /*
     * @function : reasonForRemovalPicklistValues
     * @description : This method used to get reason for removal values
     */
    @wire(getPicklistValues, {
        recordTypeId: "$healthInsuranceObjectInfo.data.defaultRecordTypeId",
        fieldApiName: ENDREASON_FIELD
    })
    reasonForRemovalPicklistValues ({ error, data }) {
        if (data) {
            this.reasonForRemovalOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }

    renderedCallback () {
        if (this.MetaDataListParent && !this.hasRendered){
            this.hasRendered=true;
            if (this.disableRelationship && this.MetaDataListParent && (!this.individualMemberDetails.hasOwnProperty("RelationshipCode__c") || !this.individualMemberDetails.RelationshipCode__c)) {
                this.MetaDataListParent["RelationshipCode__c,SSP_InsuranceCoveredIndiv__c"][sspConstants.currentEducationDetail.inputRequiredField] = false;
            }
            for (let i = 0; i < this.policyList.length; i++) {
                this.policyList[i].metaList = JSON.parse(JSON.stringify(this.MetaDataListParent));
                this.policyList[i].index=i;
                this.policyList[i].endReason="";
                this.policyList[i].endDate="";
                this.policyList[i].endDateRequired=false;
                this.policyList[i].endReasonRequired=false;
                this.policyList[i].endDateReference=null;
                this.policyList[i].endReasonReference = null;
                if (this.isReadOnlyUser) { //CD2 2.5 Security Role Matrix.
                    this.policyList[i].disablePolicySelection = true;
                }
            }
        }
    }
    
    /**
     * @function : connectedCallback.
     * @description : Fire an event from connectedCallback to load Individual Details.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            if (
                this.isEnrolledInInsurance ===
                sspConstants.sspIndividualEnrollmentFields.true
            ) {
                this.showEnrolledInInsurance = true;
                this.hideAdditionalSection = false;
                document.title = "Enrollment Details";
            } else {
                this.showEnrolledInInsurance = false;
                this.hideAdditionalSection = true;
                document.title = "Access Details";
            }
            if (this.showEnrolledInInsurance === true) {
                this.saveButtonAlt = this.label.sspIndividualEnrollSaveAlt;
                this.cancelButtonAlt = this.label.sspIndividualEnrollCancelAlt;
                this.label.sspPageInformationVerified = formatLabels(
                    this.label.sspPageInformationVerified,
                    [this.label.sspEnrollmentDetailsTitle]
                );
            } else {
                this.saveButtonAlt = sspIndividualAccessSave;
                this.cancelButtonAlt = sspIndividualAccessCancel;
                this.label.sspPageInformationVerified = formatLabels(
                    this.label.sspPageInformationVerified,
                    [this.label.sspAccessDetailsTitle]
                );
            }
            this.sspSSNOrMedicaidValidatorMessage = this.label.sspProvideInfo;
            this.maxStringLengthValidator = this.label.sspUpToTenChars;
            this.sspEmployerNameIsRequired = this.label.sspEnterEmployerName;
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "EmployerName__c,SSP_InsurancePolicy__c",
                "CoverageStartDate__c,SSP_HealthInsuranceFacilityType__c",
                "Gender__c," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual,
                sspConstants.sspIndividualEnrollmentFields.DateOfBirth +
                    "," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual,
                "RelationshipCode__c," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual,
                "CoverageEndDate__c,SSP_HealthInsuranceFacilityType__c",
                "FacilityType__c,SSP_HealthInsuranceFacilityType__c",
                "EndReason__c,SSP_HealthInsuranceFacilityType__c",
                "ExtAddressLine2__c,sspConstants.sspIndividualEnrollmentFields.SSP_InsuranceCoveredIndividual",
                "ExtPolicyHolderSsn__c," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual,
                "SSN__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual,
                "OtherReason__c,SSP_HealthInsuranceFacilityType__c",
                "MedicaidId__c," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual,
                "HasMedicaidToggle__c," +
                    sspConstants.sspIndividualEnrollmentFields
                        .SSP_InsuranceCoveredIndividual ,
                "ExtAddressLine1__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual ,
                "ExtCity__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual ,
                "ExtCountyCode__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual ,
                "ExtStateCode__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual ,
                "ExtZipCode5__c," +
                sspConstants.sspIndividualEnrollmentFields
                    .SSP_InsuranceCoveredIndividual
            );
            if (!this.showEnrolledInInsurance) { //CD2 2.5 Security Role Matrix and Program Access.
                fieldEntityNameList.push("SSP_APP_Healthcare_IndivAccessDetails,ScreenName");
            }
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                sspConstants.sspIndividualEnrollmentFields
                    .SSPAPPHealthCareIndividualEnrollDetails
            );

            fetchMemberDetails({
                insuranceCoveredIndividualId: this.sspCoveredIndividualId
            })
                .then(result => {
                    this.memberIsPolicyHolder = false;
                    this.showSpinner = false;
                    this.individualMemberDetailsWrapper = JSON.parse(
                        JSON.stringify(result.mapResponse.wrapper)
                    );
                    this.skipDisable =
                        this.individualMemberDetailsWrapper
                            .isExternalMemberCoveredIndividual &&
                        (utility.isUndefinedOrNull(
                            this.individualMemberDetailsWrapper
                                .coveredIndividual.DCInsuranceCoveredIndivId__c
                        ) ||
                            utility.isEmpty(
                                this.individualMemberDetailsWrapper
                                    .coveredIndividual
                                    .DCInsuranceCoveredIndivId__c
                            ))
                            ? true
                            : false;
                    const middleName = (this.individualMemberDetailsWrapper.middleName !== null && this.individualMemberDetailsWrapper.middleName !== undefined) ? (this.individualMemberDetailsWrapper.middleName+" ") : "";
                    const suffix = (this.individualMemberDetailsWrapper.suffix !== null && this.individualMemberDetailsWrapper.suffix !== undefined) ? (" "+suffixArray[this.individualMemberDetailsWrapper.suffix]) : "";
                    this.memberFullName = this.individualMemberDetailsWrapper.firstName +
                        " " +
                        middleName +
                        this.individualMemberDetailsWrapper.lastName+
                        suffix;

                    this.memberName =
                        this.individualMemberDetailsWrapper.firstName +
                        " " +
                        this.individualMemberDetailsWrapper.lastName;
                    this.memberLastName =
                        this.individualMemberDetailsWrapper
                            .firstNamePolicyHolder +
                        " " +
                        this.individualMemberDetailsWrapper
                            .lastNamePolicyHolder;
                    this.policyList = undefined;
                    this.policyList = this.individualMemberDetailsWrapper.policyListWrapperList;
                    this.individualMemberDetails = undefined;
                    this.individualMemberDetails = this.individualMemberDetailsWrapper.coveredIndividual; //result.coveredIndividual;
                    if (
                        !utility.isUndefinedOrNull(
                            this.individualMemberDetails
                        ) &&
                        !utility.isEmpty(this.individualMemberDetails) &&
                        !utility.isUndefinedOrNull(
                            this.individualMemberDetails.RecordType
                                .DeveloperName
                        ) &&
                        !utility.isEmpty(
                            this.individualMemberDetails.RecordType
                                .DeveloperName
                        ) &&
                        this.individualMemberDetails.RecordType
                            .DeveloperName === "InsuranceExternalPolicyHolder"
                    ) {
                        this.isExtPolicyHolder = true;
                    }
                    //Added as part of defect 369988
                    //added by Sai Kiran
                    if (
                        !utility.isUndefinedOrNull(
                            this.individualMemberDetails
                        ) &&
                        !utility.isEmpty(this.individualMemberDetails) &&
                        !utility.isUndefinedOrNull(
                            this.individualMemberDetails.SSP_InsurancePolicy__r
                                .EmployerName__c
                        ) &&
                        !utility.isEmpty(
                            this.individualMemberDetails.SSP_InsurancePolicy__r
                                .EmployerName__c
                        ) &&
                        (utility.isUndefinedOrNull(
                            this.individualMemberDetails.employerList
                        ) ||
                            utility.isEmpty(
                                this.individualMemberDetails.employerList
                            ))
                    ) {
                        this.showOther = true;
                        this.selectedEmployer =
                            sspConstants.sspIndividualEnrollmentFields.Other;
                    }
                    //End  - defect 369988
                    const disableEverything =
                        (this.individualMemberDetailsWrapper
                            .isPolicyHolderExternal &&
                            this.individualMemberDetails.SSP_InsurancePolicy__r[
                                sspConstants.sspIndividualEnrollmentFields
                                    .IsHealthCareCoveredPolicyHolderOutSideCase
                            ]) ||
                        this.individualMemberDetails.SSP_InsurancePolicy__r[
                            sspConstants.sspIndividualEnrollmentFields
                                .IsHealthCareCoveredPolicyHolderOutSideCase
                        ]
                            ? true
                            : false;
                    this.isMemberPolicyHolder =
                        result.mapResponse.wrapper.coveredIndividual.IsPolicyHolder__c;
                    this.policyHolder = this.individualMemberDetailsWrapper.policyHolder;
                    this.individualMemberDetailsWrapper.employerList.forEach(
                        employer => {
                            if (
                                employer.EmployerName__c ===
                                this.individualMemberDetails
                                    .SSP_InsurancePolicy__r.EmployerName__c
                            ) {
                                this.selectedEmployer = this.individualMemberDetails.SSP_InsurancePolicy__r.EmployerName__c;
                                this.showOther = false;
                            }
                            this.employerList.unshift({
                                id: employer.Id ? employer.Id : "",
                                label: employer.EmployerName__c,
                                value: employer.EmployerName__c
                            });
                        }
                    );
                    if (
                        (!utility.isUndefinedOrNull(
                            this.individualMemberDetails[
                                sspConstants.sspIndividualEnrollmentFields
                                    .IsTobaccoConsumer
                            ]
                        ) &&
                            !utility.isEmpty(
                                this.individualMemberDetails[
                                    sspConstants.sspIndividualEnrollmentFields
                                        .IsTobaccoConsumer
                                ]
                            ) &&
                            !this.showEnrolledInInsurance &&
                            this.mode !== "Intake") ||
                        disableEverything
                    ) {
                        this.disableTobaccoToggle = true;
                    } else {
                        this.disableTobaccoToggle = false;
                    }
                        //Below Condition is Modified as part of Defect 368193
                        //Modified By Sai Kiran
                    if (
                        !utility.isUndefinedOrNull(
                            this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields
                                .IsTobaccoConsumer
                            ]
                        ) &&
                        !utility.isEmpty(
                            this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields
                                .IsTobaccoConsumer
                            ]
                        )
                    ) {
                        this.bUsesTobacco =
                            this.individualMemberDetails[
                                sspConstants.sspIndividualEnrollmentFields
                                    .IsTobaccoConsumer
                            ] == sspConstants.sspIndividualEnrollmentFields.Y
                                ? yesValue
                                : noValue;
                    } else {
                        this.bUsesTobacco = yesValue;
                    }
                    if (
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                            sspConstants.sspIndividualEnrollmentFields.Y ||
                        (!utility.isUndefinedOrNull(
                            this.individualMemberDetails.MedicaidId__c
                        ) &&
                            !utility.isEmpty(
                                this.individualMemberDetails.MedicaidId__c
                            ))
                    ) {
                        this.bHaveMedicaid = yesValue;
                    } else if (
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                        sspConstants.sspIndividualEnrollmentFields.N
                    ) {
                        this.bHaveMedicaid = noValue;
                    }
                    this.memberHasMedicaid =
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                            sspConstants.sspIndividualEnrollmentFields.Y ||
                        (!utility.isUndefinedOrNull(
                            this.individualMemberDetails.MedicaidId__c
                        ) &&
                            !utility.isEmpty(
                                this.individualMemberDetails.MedicaidId__c
                            ))
                            ? true
                            : false;
                    this.sspUsesTobacco = formatLabels(
                        sspIndividualEnrollTobacco,
                        [this.memberName]
                    );
                    this.sspWhatIsTheRelation = formatLabels(
                        sspIndividualEnrollRelation,
                        [this.memberName, this.memberLastName]
                    );
                    this.policyList.forEach(policyObj => {
                        mapOfFacilityAndPolicyWrapper.set(
                            policyObj.policy.FacilityType__c,
                            policyObj
                        );
                        if (
                            (this.individualMemberDetails.SSP_InsurancePolicy__r
                                .IsHealthCareCoverageApproved__c &&
                                !utility.isUndefinedOrNull(
                                    policyObj.policy.Id
                                ) &&
                                !this.skipDisable) ||
                            disableEverything
                        ) {
                            policyObj.disableStartDate = true;
                            policyObj.disablePolicySelection = true;
                        } else {
                            policyObj.disablePolicySelection =
                                policyObj.existingPolicy;
                        }
                        if (
                            this.newCoveredIndividual &&
                            !utility.isUndefinedOrNull(policyObj.policy.Id)
                        ) {
                            this.newCoveredIndividual = false;
                        }
                    });
                    this.memberIsPolicyHolder = true;
                    if (
                        this.individualMemberDetailsWrapper
                            .isExternalMemberCoveredIndividual
                    ) {
                        this.memberIsPolicyHolder = false;
                    }
                    if (
                        this.individualMemberDetailsWrapper
                            .isExternalMemberPolicyHolder
                    ) {
                        this.doesMemberHaveEmploymentRecords = false;
                    }

                    if (
                        this.individualMemberDetailsWrapper
                            .isExternalMemberPolicyHolder ||
                        this.individualMemberDetailsWrapper
                            .isExternalMemberCoveredIndividual
                    ) {
                        this.memberIsOutsideOfHouseHold = true;
                    }
                    this.medicaidUser = formatLabels(
                        sspIndividualEnrollHaveMedicaid,
                        [this.memberName]
                    );

                    if (
                        (this.individualMemberDetails.SSP_InsurancePolicy__r
                            .IsHealthCareCoverageApproved__c &&
                            (!utility.isUndefinedOrNull(
                                this.individualMemberDetailsWrapper
                                    .coveredIndividual
                                    .DCInsuranceCoveredIndivId__c
                            ) &&
                                !utility.isEmpty(
                                    this.individualMemberDetailsWrapper
                                        .coveredIndividual
                                        .DCInsuranceCoveredIndivId__c
                                )) &&
                            !this.skipDisable) ||
                        disableEverything
                    ) {
                        this.enrollmentVerification = true;
                        this.isHealthCarePolicyApprove = true;
                        this.disableEmployerList = true;
                        this.disableEmployerName = true;
                        this.disableSocialSecurityNumber = true;
                        this.disableGender = true;
                        this.disableDateOfBirth = true;
                        this.disableMedicaidToggle = true;
                        this.disableMedicaidNumber = true;
                        this.disableRelationship = true;
                        this.disableEndDate = true;
                        this.disableEndReason = true;
                        this.disableOtherReason = true;
                        this.disabledAddress = true;
                        /*if (
                            !this.showEnrolledInInsurance ||
                            disableEverything
                        ) {
                            this.disableTobaccoToggle = true;
                        }*/
                    }
                    this.isComponentLoaded = true;
                })
                .catch(error => {
                    console.error(
                        sspConstants.sspIndividualEnrollmentFields
                            .IndividualEnrollmentDetailsErrorMessage +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }

        /**
     * @function : disconnectedCallback
     * @description : This method is used to scroll to the top.
     */
    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }
    
    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error)
            );
        }
    };
    /*
     * @function : showMedicaidField
     * @description	: Method to assign Medicaid value.
     * @param  {event}
     */
    showMedicaidField = event => {
        try {
            if (
                event.target.value ===
                sspConstants.sspIndividualEnrollmentFields.yesValue
            ) {
                this.memberHasMedicaid = true;
            } else {
                this.memberHasMedicaid = false;
            }
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : save
     * @description	: Method to save covered individual.
     */
    save = () => {
        this.showSpinner = true;
        try {
          if (this.isReadOnlyUser) { //2.5Security Role Matrix and Program Access.
              this.cancelIndividualEnrollmentDetails();
          }
          else{
            const addressElement = this.template.querySelector(
                ".addressLineClass"
            );
            let bAddressValidation = true;
            if (addressElement) {
                const errors = addressElement.ErrorMessages();

                if(errors.length > 0){
                    bAddressValidation = false;
                }
            }
            const inputElement = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            const applicationInputElement = this.template.querySelectorAll(
                ".ssp-applicationInputElement"
            );
            if(this.memberHasMedicaid){
                this.checkValidations(applicationInputElement);
            }
            else {
                this.checkValidations(inputElement);
            }
            
            const bStandardValidation = this.allowSaveData;
                let bCustomValidationSSN;
                if (!this.disableSocialSecurityNumber) {
                    bCustomValidationSSN = this.customValidationSSN();
                } else {
                    bCustomValidationSSN = true;
                }
                let bCustomValidation = this.customValidation();
                let bCustomValidationMemberIDLength = this.customValidationMemberIDLength();
                let bCustomValidationEmployerName = this.customValidationEmployerName();
                const bSelectHealthCareCoverageValidation = this.selectHealthCareCoverageValidation();
               
                //If Medicaid field is selected as YES then set all these value to true to bypass 
                //validation since these fields will be not present in screen.
                if (this.memberHasMedicaid) {
                    bCustomValidation = true;
                    bCustomValidationMemberIDLength = true;
                    bCustomValidationEmployerName = true;
                    bAddressValidation = true;
                    bCustomValidationSSN = true;
                }

                if (
                    bAddressValidation &&
                    bStandardValidation &&
                    bCustomValidation &&
                    bCustomValidationSSN &&
                    bCustomValidationMemberIDLength &&
                    bCustomValidationEmployerName &&
                    bSelectHealthCareCoverageValidation
                ) {
                    this.allowSaveData = true;
                } else {
                    this.allowSaveData = false;
                }
                if (
                    this.individualMemberDetailsWrapper
                        .isExternalMemberPolicyHolder
                ) {
                    const addressElement1 = this.template.querySelector(
                        sspConstants.sspIndividualEnrollmentFields.sspAddress
                    );
                    if (addressElement1.value) {
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtAddressLine1
                        ] = addressElement1.value.addressLine1;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtAddressLine2
                        ] = addressElement1.value.addressLine2;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtCity
                        ] = addressElement1.value.city;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtStateCode
                        ] = addressElement1.value.state;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtZipCode5
                        ] = addressElement1.value.postalCode;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtCountyCode
                        ] = addressElement1.value.county;
                        this.individualMemberDetails[
                            sspConstants.sspIndividualEnrollmentFields.ExtCountryCode
                        ] = addressElement1.value.country;
                    }
                }
                this.individualMemberDetails[
                    sspConstants.sspIndividualEnrollmentFields.IsTobaccoConsumer
                ] =
                    this.bUsesTobacco === yesValue
                        ? sspConstants.sspIndividualEnrollmentFields.Y
                        : sspConstants.sspIndividualEnrollmentFields.N;
                if (
                    !utility.isUndefinedOrNull(this.allowSaveData) &&
                    this.allowSaveData
                ) {
                    saveIndividualDetails({
                        wrapper: JSON.stringify(
                            this.individualMemberDetailsWrapper
                        )
                    })
                        .then(result => {
                            this.showSpinner = false;
                            this.cancelIndividualEnrollmentDetails();
                        })
                        .catch(error => {
                            this.showSpinner = false;
                        });
                } else {
                    this.showSpinner = false;
                    this.hasSaveValidationError = true;
                }
            }
        } catch (error) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : manageRelationship
     * @description	: Method to assign Relationship value.
     * @param  {event}
     */
    manageRelationship = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.RelationshipCode
            ] = event.target.value;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : selectedPolicy
     * @description	: Method to assign selected policy value.
     * @param  {event}
     */
    selectedPolicy = event => {
        try {
            const selectedPolicy = event.target.title;
            mapOfFacilityAndPolicyWrapper.get(selectedPolicy).selected =
                event.detail.checked;
            this.selectHealthCareCoverageValidation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleUsesTobacco
     * @description	: Method to assign Tobacco value.
     * @param  {event}
     */
    handleUsesTobacco = event => {
        try {
            this.bUsesTobacco = event.target.value;
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.IsTobaccoConsumer
            ] =
                this.bUsesTobacco === yesValue
                    ? sspConstants.sspIndividualEnrollmentFields.Y
                    : sspConstants.sspIndividualEnrollmentFields.N;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleCoverageStartDate
     * @description	: Method to assign Coverage Start Date value.
     * @param  {event}
     */
    handleCoverageStartDate = event => {
        try {
            const selectedPolicy = event.target.title;
            mapOfFacilityAndPolicyWrapper.get(selectedPolicy).policy[
                sspConstants.sspIndividualEnrollmentFields.CoverageStartDate
            ] = event.target.value;
            event.stopPropagation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleEmployer
     * @description	: Method to assign Employer value.
     * @param  {event}
     */
    handleEmployer = event => {
        try {
            if (
                event.detail.value !==
                sspConstants.sspIndividualEnrollmentFields.Other
            ) {
                this.showOther = false;
                this.individualMemberDetails.SSP_InsurancePolicy__r[
                    sspConstants.sspIndividualEnrollmentFields.EmployerName
                ] = event.detail.value;
            } else {
                this.showOther = true;
                this.individualMemberDetails.SSP_InsurancePolicy__r[
                    sspConstants.sspIndividualEnrollmentFields.EmployerName
                ] = undefined;
            }
            event.stopPropagation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleIndividualEnrollRemovalReason
     * @description	: Method to assign Removal reason value.
     * @param  {event}
     */
    handleIndividualEnrollRemovalReason = event => {
        try {
            const index = parseInt(event.target.getAttribute("data-index"));
            const metaList = JSON.parse(JSON.stringify(this.policyList[index].metaList));
            const elements = this.template.querySelectorAll(".ssp-end-date");
            for (let i = 0; i < elements.length; i++) {
                this.policyList[i].endDateReference = elements[i];
            }
            if (
                event.target.value ===
                sspConstants.sspIndividualEnrollmentFields.OT
            ) {
                this.explainReasonOfRemoval = true;
            } else {
                this.explainReasonOfRemoval = false;
            }
            this.policyList[index].endReason = event.target.value;
            this.policyList[index].endReasonReference = event.target;
            if (event.target.value){
                this.policyList[index].endDateRequired = true;
                metaList["CoverageEndDate__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = true;
            }
            else{
                if (this.policyList[index].endDate){
                    this.policyList[index].endReasonRequired = true;
                    metaList["EndReason__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = true;
                }
                else{
                    if (event.target.ErrorMessageList.length){
                        event.target.ErrorMessageList = [];
                    }
                    if (this.policyList[index].endDateReference && this.policyList[index].endDateReference.ErrorMessageList.length){
                        this.policyList[index].endDateReference.ErrorMessageList = [];
                    }
                    this.policyList[index].endDateRequired = false;
                    this.policyList[index].endReasonRequired = false;
                    metaList["CoverageEndDate__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = false;
                    metaList["EndReason__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = false;
                }
            }
            this.policyList[index].metaList = JSON.parse(JSON.stringify(metaList));
            const selectedPolicy = event.target.title;
            mapOfFacilityAndPolicyWrapper.get(selectedPolicy).policy[
                sspConstants.sspIndividualEnrollmentFields.EndReason
            ] = event.target.value;
            event.stopPropagation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleIndividualEnrollCoverageEndDate
     * @description	: Method to assign Coverage End Date value.
     * @param  {event}
     */
    handleIndividualEnrollCoverageEndDate = event => {
        try {
            const index = parseInt(event.target.getAttribute("data-index"));
            const metaList = JSON.parse(JSON.stringify(this.policyList[index].metaList));
            this.policyList[index].endDate = event.target.value;
            this.policyList[index].endDateReference = event.target;
            const elements = this.template.querySelectorAll(".ssp-end-reason");
            for (let i = 0; i < elements.length; i++) {
                this.policyList[i].endReasonReference = elements[i];
            }
            if (event.target.value){
                this.policyList[index].endReasonRequired = true; 
                metaList["EndReason__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = true;
            }
            else{
                if (this.policyList[index].endReason){
                    this.policyList[index].endDateRequired = true;
                    metaList["CoverageEndDate__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = true;
                }
                else{
                    if (event.target.ErrorMessageList.length) {
                        event.target.ErrorMessageList = [];
                    }
                    if (this.policyList[index].endReasonReference && this.policyList[index].endReasonReference.ErrorMessageList.length){
                        this.policyList[index].endReasonReference.ErrorMessageList = [];
                    }
                    this.policyList[index].endDateRequired = false;
                    this.policyList[index].endReasonRequired = false;
                    metaList["CoverageEndDate__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = false;
                    metaList["EndReason__c,SSP_HealthInsuranceFacilityType__c"][sspConstants.currentEducationDetail.inputRequiredField] = false;
                }
            }
            this.policyList[index].metaList = JSON.parse(JSON.stringify(metaList));
            const selectedPolicy = event.target.title;
            mapOfFacilityAndPolicyWrapper.get(selectedPolicy).policy[
                sspConstants.sspIndividualEnrollmentFields.CoverageEndDate
            ] = event.target.value;
            event.stopPropagation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleIndividualEnrollPleaseExplain
     * @description	: Method to assign Please Explain value.
     * @param  {event}
     */
    handleIndividualEnrollPleaseExplain = event => {
        try {
            const selectedPolicy = event.target.title;
            mapOfFacilityAndPolicyWrapper.get(selectedPolicy).policy[
                sspConstants.sspIndividualEnrollmentFields.OtherReason
            ] = event.target.value;
            event.stopPropagation();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleAddressLine1
     * @description	: Method to assign Address Line 1 value.
     * @param  {event}
     */
    handleAddressLine1 = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.ExtAddressLine1
            ] = event.target.value;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleAddressLine2
     * @description	: Method to assign Address Line 2 value.
     * @param  {event}
     */
    handleAddressLine2 = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.ExtAddressLine2
            ] = event.target.value;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleSocialSecurityNumber
     * @description	: Method to assign SSN value.
     * @param  {event}
     */
    handleSocialSecurityNumber = event => {
        try {
            if (this.individualMemberDetails.IsPolicyHolder__c) {
                this.individualMemberDetails[
                    sspConstants.sspIndividualEnrollmentFields.ExtPolicyHolderSsn
                ] = event.target.value;
            } else {
                this.individualMemberDetails["SSN__c"] = event.target.value;
            }
            this.customValidationSSN();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleGender
     * @description	: Method to assign Gender value.
     * @param  {event}
     */
    handleGender = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.Gender
            ] = event.target.value;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleDateOfBirth
     * @description	: Method to assign Date Of Birth value.
     * @param  {event}
     */
    handleDateOfBirth = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.DateOfBirth
            ] = event.target.value;
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleHaveMedicaid
     * @description	: Method to assign Medicaid value.
     * @param  {event}
     */
    handleHaveMedicaid = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.HasMedicaid
            ] =
                event.detail.value ===
                sspConstants.sspIndividualEnrollmentFields.yesValue
                    ? sspConstants.sspIndividualEnrollmentFields.Y
                    : sspConstants.sspIndividualEnrollmentFields.N;
            this.showMedicaidField(event);
            if(event.detail.value === sspConstants.sspIndividualEnrollmentFields.noValue){
                this.customValidationSSN();
            }
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleMedicaid
     * @description	: Method to assign Medicaid value.
     * @param  {event}
     */
    handleMedicaid = event => {
        try {
            this.individualMemberDetails[
                sspConstants.sspIndividualEnrollmentFields.MedicaidId
            ] = event.target.value;
            this.customValidation();
            this.customValidationMemberIDLength();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleOtherEmployer
     * @description	: Method to assign Other Employer value.
     * @param  {event}
     */
    handleOtherEmployer = event => {
        try {
            if (
                this.selectedEmployer !==
                sspConstants.sspIndividualEnrollmentFields.Other
            ) {
                this.individualMemberDetails.SSP_InsurancePolicy__r[
                    sspConstants.sspIndividualEnrollmentFields.EmployerName
                ] = undefined;
            }
            if (
                this.selectedEmployer ===
                    sspConstants.sspIndividualEnrollmentFields.Other &&
                !this.doesMemberHaveEmploymentRecords
            ) {
                this.individualMemberDetails.SSP_InsurancePolicy__r[
                    sspConstants.sspIndividualEnrollmentFields.EmployerName
                ] = event.detail.value;
            } else {
                this.individualMemberDetails.SSP_InsurancePolicy__r[
                    sspConstants.sspIndividualEnrollmentFields.EmployerName
                ] = event.detail.value;
            }
            this.customValidationEmployerName();
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function - selectHealthCareCoverageValidation.
     * @description - Use to set the healthCare coverage Individual custom validation message.
     */
    selectHealthCareCoverageValidation = () => {
        try {
            let counter = 0;
            this.policyList.forEach(policy => {
                if (policy.selected) {
                    this.allowSaveData = true;
                    this.selectAtLeastOnePolicy = undefined;
                    return false;
                } else {
                    counter++;
                    if (counter === this.policyList.length && this.individualMemberDetails.RecordType.DeveloperName !== "InsuranceExternalPolicyHolder") {
                        this.allowSaveData = false;
                        this.selectAtLeastOnePolicy = this.label.sspSelectAtLeastOnePolicy;
                    }
                }
            });
        } catch (e) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };

    /**
     * @function : customValidation
     * @description : This method is used to make SSN and Medicaid conditionally required.
     */
    customValidation = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            contactInfo.forEach((con, index) => {
                if (
                    con.getAttribute("data-id") === "MedicaidId__c" ||
                    con.getAttribute("data-id") === "ExtPolicyHolderSsn__c"
                ) {
                    const messageList = contactInfo[index].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        this.sspSSNOrMedicaidValidatorMessage
                    );

                    if (
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                        sspConstants.sspIndividualEnrollmentFields.Y
                    ) {
                        if (
                            indexOfMessage === -1 &&
                            ((utility.isUndefinedOrNull(
                                this.individualMemberDetails.MedicaidId__c
                            ) ||
                                utility.isEmpty(
                                    this.individualMemberDetails.MedicaidId__c
                                )) &&
                                (utility.isUndefinedOrNull(
                                    this.individualMemberDetails
                                        .ExtPolicyHolderSsn__c
                                ) ||
                                    utility.isEmpty(
                                        this.individualMemberDetails
                                            .ExtPolicyHolderSsn__c
                                    )))
                        ) {
                            messageList.push(
                                this.sspSSNOrMedicaidValidatorMessage
                            );
                            this.allowSaveData = false;
                        } else if (
                            indexOfMessage >= 0 &&
                            ((!utility.isUndefinedOrNull(
                                this.individualMemberDetails.MedicaidId__c
                            ) &&
                                !utility.isEmpty(
                                    this.individualMemberDetails.MedicaidId__c
                                )) ||
                                (!utility.isUndefinedOrNull(
                                    this.individualMemberDetails
                                        .ExtPolicyHolderSsn__c
                                ) ||
                                    !utility.isEmpty(
                                        this.individualMemberDetails
                                            .ExtPolicyHolderSsn__c
                                    )))
                        ) {
                            messageList.splice(indexOfMessage, 1);
                            this.allowSaveData = true;
                        }
                    }
                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
            });
        } catch (e) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /**
     * @function : customValidationSSN
     * @description : This method is used to make SSN and Medicaid conditionally required.
     */
    customValidationSSN = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-ssnField"
            );
            contactInfo.forEach((con, index) => {
                if (con.getAttribute("data-id") === "ExtPolicyHolderSsn__c" || con.getAttribute("data-id") === "SSN__c") {
                    const messageList = contactInfo[index].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        this.sspSSNOrMedicaidValidatorMessage
                    );
                    if (
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                            sspConstants.sspIndividualEnrollmentFields.N ||
                        this.individualMemberDetailsWrapper
                            .isExternalMemberPolicyHolder ||
                        this.individualMemberDetails.RecordType.DeveloperName === "InsuranceExternalCoveredIndividual"
                    ) {
                        if (
                            indexOfMessage === -1 &&
                            ((utility.isUndefinedOrNull(
                                this.individualMemberDetails
                                    .ExtPolicyHolderSsn__c
                            ) ||
                                utility.isEmpty(
                                    this.individualMemberDetails
                                        .ExtPolicyHolderSsn__c
                                )) &&
                                (utility.isUndefinedOrNull(
                                    this.individualMemberDetails.SSN__c
                                ) ||
                                    utility.isEmpty(
                                        this.individualMemberDetails.SSN__c
                                    )))
                        ) {
                            messageList.push(
                                this.sspSSNOrMedicaidValidatorMessage
                            );
                            this.allowSaveData = false;
                        } else if (
                            (indexOfMessage >= 0 &&
                                ((!utility.isUndefinedOrNull(
                                    this.individualMemberDetails
                                        .ExtPolicyHolderSsn__c
                                ) &&
                                    !utility.isEmpty(
                                        this.individualMemberDetails
                                            .ExtPolicyHolderSsn__c
                                    )) ||
                            (!utility.isUndefinedOrNull(
                                this.individualMemberDetails.SSN__c
                            ) &&
                                !utility.isEmpty(
                                    this.individualMemberDetails.SSN__c
                                ))))
                        ) {
                            messageList.splice(indexOfMessage, 1);
                            this.allowSaveData = true;
                        }
                    }
                    if(this.memberHasMedicaid){
                        messageList.splice(indexOfMessage, 1);
                    }
                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
            });
        } catch (e) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /**
     * @function : customValidationMemberIDLength
     * @description : This method is used to make Medicaid length to be entered as 10.
     */
    customValidationMemberIDLength = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            contactInfo.forEach((con, index) => {
                if (con.getAttribute("data-id") === "MedicaidId__c") {
                    const messageList = contactInfo[index].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        this.maxStringLengthValidator
                    );

                    if (
                        this.individualMemberDetails.HasMedicaidToggle__c ==
                        sspConstants.sspIndividualEnrollmentFields.Y
                    ) {
                        if (
                            indexOfMessage === -1 &&
                            (!utility.isUndefinedOrNull(
                                this.individualMemberDetails.MedicaidId__c
                            ) &&
                                !utility.isEmpty(
                                    this.individualMemberDetails.MedicaidId__c
                                )) &&
                            this.individualMemberDetails.MedicaidId__c.length >
                                10
                        ) {
                            messageList.push(this.maxStringLengthValidator);
                            this.allowSaveData = false;
                        } else if (
                            indexOfMessage >= 0 &&
                            !utility.isUndefinedOrNull(
                                this.individualMemberDetails.MedicaidId__c
                            ) &&
                            this.individualMemberDetails.MedicaidId__c.length <=
                                10
                        ) {
                            messageList.splice(indexOfMessage, 1);
                            this.allowSaveData = true;
                        }
                    } else {
                        messageList.splice(indexOfMessage, 1);
                        this.allowSaveData = true;
                    }
                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
            });
        } catch (e) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /**
     * @function : customValidationEmployerName
     * @description : This method is used to make Employer Name mandatory.
     */
    customValidationEmployerName = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-inputElement"
            );
            contactInfo.forEach((con, index) => {
                if (con.getAttribute("data-id") === "EmployerName__c") {
                    const messageList = contactInfo[index].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        this.sspEmployerNameIsRequired
                    );
                    if (
                        indexOfMessage === -1 &&
                        (utility.isUndefinedOrNull(
                            this.individualMemberDetails.SSP_InsurancePolicy__r
                                .EmployerName__c
                        ) ||
                            utility.isEmpty(
                                this.individualMemberDetails
                                    .SSP_InsurancePolicy__r.EmployerName__c
                            )) &&
                        this.individualMemberDetails.SSP_InsurancePolicy__r[
                            sspConstants.sspIndividualEnrollmentFields
                                .IsKHIPPSourceOfCoverage
                        ]
                    ) {
                        messageList.push(this.sspEmployerNameIsRequired);
                        this.allowSaveData = false;
                    } else if (indexOfMessage >= 0) {
                        messageList.splice(indexOfMessage, 1);
                        this.allowSaveData = true;
                    } else {
                        this.allowSaveData = true;
                    }

                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
            });
        } catch (e) {
            this.showSpinner = false;
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /**
     * @function - cancelEnrollmentDetails.
     * @description - Method is used for Cancel button which redirect to Enrollment Summary Page.
     */
    cancelIndividualEnrollmentDetails = () => {
        try {
            const showIndividualEnrollmentDetails = false;
            const selectedEvent = new CustomEvent(
                sspConstants.sspIndividualEnrollmentFields.hideIndividualEnrollmentDetails,
                {
                    detail: showIndividualEnrollmentDetails
                }
            );
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                sspConstants.sspIndividualEnrollmentFields
                    .IndividualEnrollmentDetailsErrorMessage +
                    JSON.stringify(error.message)
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
                this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isScreenNotAccessible = false;
                }
                else {
                    this.isScreenNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isScreenNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
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