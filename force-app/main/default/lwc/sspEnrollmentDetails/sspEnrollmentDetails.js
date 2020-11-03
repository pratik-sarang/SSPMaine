/**
 * Component Name - sspEnrollmentDetails.js.
 * Author         - Chaitanya Kanakia, Ashwin Kasture.
 * Description    - Used to display Enrollment Details of Individuals.
 * Date       	  - 20/12/2019.
 */
import { track, api } from "lwc";
import utility, { formatLabels } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import sspEnrollmentDetailsTitle from "@salesforce/label/c.SSP_EnrollmentDetailsTitle";
import sspAccessDetailsSave from "@salesforce/label/c.SSP_AccessDetailsSave";
import sspAccessDetailsCancel from "@salesforce/label/c.SSP_AccessDetailsCancel";
import sspIndividualEnrollDesc from "@salesforce/label/c.SSP_IndividualEnrollDesc";
import sspAccessDetailsTitle from "@salesforce/label/c.SSP_AccessDetailsTitle";
import sspEnrollmentDetailsDesc from "@salesforce/label/c.SSP_EnrollmentDetailsDesc";
import sspEnrollmentDetailsSource from "@salesforce/label/c.SSP_EnrollmentDetailsSource";
import sspEnrollmentDetails from "@salesforce/label/c.SSP_EnrollmentDetails";
import sspEnrollmentDetailsCompanyName from "@salesforce/label/c.SSP_EnrollmentDetailsCompanyName";
import sspEnrollmentDetailsPlans from "@salesforce/label/c.SSP_EnrollmentDetailsPlans";
import sspEnrollmentDetailsPlansName from "@salesforce/label/c.SSP_EnrollmentDetailsPlansName";
import sspEnrollmentDetailsPolicyId from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyId";
import sspEnrollmentDetailsGroupId from "@salesforce/label/c.SSP_EnrollmentDetailsGroupId";
import sspEnrollmentDetailsPlanStart from "@salesforce/label/c.SSP_EnrollmentDetailsPlanStart";
import sspEnrollmentDetailsMemberEnrolled from "@salesforce/label/c.SSP_EnrollmentDetailsMemberEnrolled";
import sspEnrollmentDetailsMemberDetails from "@salesforce/label/c.SSP_EnrollmentDetailsMemberDetails";
import sspEnrollmentDetailsPolicyHolder from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyHolder";
import sspEnrollmentDetailsPolicyMembers from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyMembers";
import sspEnrollmentDetailsAddMember from "@salesforce/label/c.SSP_EnrollmentDetailsAddMember";
import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";

import sspAddress from "@salesforce/label/c.SSP_Address";
import sspAddressLineTwo from "@salesforce/label/c.SSP_AddressLine2";

import sspEnrollmentDetailsNoMiddleName from "@salesforce/label/c.SSP_EnrollmentDetailsNoMiddleName";
import sspEnrollmentDetailsWhoIsEnrolled from "@salesforce/label/c.SSP_EnrollmentDetailsWhoIsEnrolled";
import sspEnrollmentDetailsInsufficientInfo from "@salesforce/label/c.SSP_EnrollmentDetailsInsufficientInfo";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspMiddleInitial from "@salesforce/label/c.SSP_MiddleInitial";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspSuffix from "@salesforce/label/c.SSP_Suffix";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspEnrollmentPhone from "@salesforce/label/c.sspEnrollmentPhone";

import sspEnrollmentDetailsSourceAlt from "@salesforce/label/c.SSP_EnrollmentDetailsSourceAlt";
import sspEnrollmentDetailsMemberEnrolledAlt from "@salesforce/label/c.SSP_EnrollmentDetailsMemberEnrolledAlt";
import sspEnrollmentDetailsPolicyMembersAlt from "@salesforce/label/c.SSP_EnrollmentDetailsPolicyMembersAlt";
import sspEnrollmentDetailsInsufficientInfoAlt from "@salesforce/label/c.SSP_EnrollmentDetailsInsufficientInfoAlt";
import sspEnrollmentDetailsSaveAlt from "@salesforce/label/c.SSP_EnrollmentDetailsSaveAlt";
import sspEnrollmentDetailsCancelAlt from "@salesforce/label/c.SSP_EnrollmentDetailsCancelAlt";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspCoveredIndividualErrorMsg from "@salesforce/label/c.SSP_CoveredIndividualErrorMsg";
import sspAtleastOneHouseholdErrorMsg from "@salesforce/label/c.SSP_HealthSelectionErrorMsg";
import sspSomeoneOutsideHousehold from "@salesforce/label/c.SSP_SomeoneOutsideHousehold";
//Access Details Labels
import sspAccessDetailsWhoHasAccess from "@salesforce/label/c.sspAccessDetailsWhohasAccess";
import sspAccessDetailsPolicyMembersAlt from "@salesforce/label/c.sspAccessDetailsPolicyMembersAlt";
import sspAccessDetailsAddMember from "@salesforce/label/c.sspAccessDetailsAddMember";
import sspAccessDetailsContent from "@salesforce/label/c.SSP_AccessDetailsContent";

import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import sspHealthCareApprovedMsg from "@salesforce/label/c.sspHealthCareApprovedMsg";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import COUNTRY from "@salesforce/label/c.Country";
import ZIP from "@salesforce/label/c.Zip";

import PHYSICAL_ADDRESS_LINE1 from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalAddressLine1__c";
import PHYSICAL_ADDRESS_LINE2 from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalAddressLine2__c";
import PHYSICAL_ADDRESS_CITY from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalCity__c";
import PHYSICAL_ADDRESS_COUNTRY from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalCountryCode__c";
import PHYSICAL_ADDRESS_COUNTY from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalCountyCode__c";
import PHYSICAL_ADDRESS_STATE from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalStateCode__c";
import PHYSICAL_ADDRESS_ZIP4 from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalZipCode4__c";
import PHYSICAL_ADDRESS_ZIP5 from "@salesforce/schema/SSP_InsurancePolicy__c.PhysicalZipCode5__c";

import getEnrollmentDetails from "@salesforce/apex/SSP_EnrollmentDetailsCtrl.getEnrollmentDetails";
import storeEnrollmentDetailsData from "@salesforce/apex/SSP_EnrollmentDetailsCtrl.storeEnrollmentDetailsData";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

const outsideHOHLabel = sspSomeoneOutsideHousehold;
const outsideHOHValue = "outside";
const whoIsEnrolledInPlanLabel = "whoIsEnrolledInPlan";
const sKIHIPPProgramValue = "KP";
const policyIdMaxLengthValue = "18";
const middleInitialMaxLengthValue = "1";
const enrollmentDetailScreenId = "SSP_APP_HealthCare_EnrollDetails";
const accessDetailScreenId = "SSP_APP_HealthCare_AccessDetails";

const PA_FIELD_MAP = {
    addressLine1: {
        ...PHYSICAL_ADDRESS_LINE1,
        label: sspAddress
    },
    addressLine2: {
        ...PHYSICAL_ADDRESS_LINE2,
        label: sspAddressLineTwo
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
export default class SspEnrollmentDetails extends utility {
    @api applicationId = "";
    @api insurancePolicyId = "";
    @api isEnrolled;
    @api mode;
    @track elementTemporary;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isScreenNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    get screenRenderingStatus () {
        return this.isScreenNotAccessible;
    }

    get getDisableStatus () {
        return this.disableHasMiddleInitial || this.isReadOnlyUser; //CD2 2.5 Security Role Matrix.
    }

    get addressDisableStatus () {
        return this.disableAddress || this.isReadOnlyUser; //CD2 2.5 Security Role Matrix.
    }

    /**
     * @function : Getter setter methods for isEnrolledInInsurance.
     * @description : Getter setter methods for isEnrolledInInsurance.
     */
    @api
    get isEnrolledInInsurance () {
        return this.isEnrolled;
    }
    set isEnrolledInInsurance (value) {
        if (value === "true") {
            this.isEnrolled = true;
        } else {
            this.isEnrolled = false;
        }
    }

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSave () {
        return this.allowSaveData;
    }
    set allowSave (value) {
        if (value !== undefined && value !== "") {
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
        if (value !== undefined && value !== null) {
            this.MetaDataListParent = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
            }

            if (value.mapOfPicklistOptions === undefined) {
                // Added the below code to bypass the MiddleInitials Validations.
                const middleNameInput = this.template.querySelectorAll(
                    ".ssp-enrollmentDetailMiddleInitial"
                );
                if (
                    middleNameInput.length > 0 &&
                    this.hasMiddleInitial === true
                ) {
                    middleNameInput[0].disabled = true;
                    this.MetaDataListParent[
                        middleNameInput[0].fieldName +
                            "," +
                            middleNameInput[0].entityName
                    ][
                        sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                    ] = false;
                    this.checkValidations(middleNameInput);
                } else if (
                    middleNameInput.length > 0 &&
                    this.hasMiddleInitial === false
                ) {
                    middleNameInput[0].disabled = false;
                    this.MetaDataListParent[
                        middleNameInput[0].fieldName +
                            "," +
                            middleNameInput[0].entityName
                    ][
                        sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                    ] = true;
                }
            }
        }
    }
    @track cancelButtonAlt;
    @track saveButtonAlt;
    @track fieldMap = PA_FIELD_MAP;
    @track policyIdMaxLength = policyIdMaxLengthValue;
    @track middleInitialMaxLength = middleInitialMaxLengthValue;
    @track addressRecord;
    @track objEnrollmentDetailsData = {};
    @track sourceOfCoverage = "";
    @track sourceOfCoverageList = [];
    @track hasKIHIPPProgram = false;
    @track enrollmentTierOptionList = [];
    @track suffixCodeList = [];
    @track policyHolderOptionList = [];
    @track policyHolderValue = "";
    @track lstWhoIsEnrolledInPlan = [];
    @track selectedEnrollPlanList = [];
    @track lstOutsideCoveredInd = [];
    @track showPolicyHolderBlock = false;
    @track showCoveredIndividualBlock = false;
    @track allowSaveData;
    @track MetaDataListParent;
    @track metaDataListParentCopy;
    @track whoIsEnrollInPlanErrorMsg;
    @track showEnrollmentDetails = true;
    @track currentPolicyHolderId = "";
    @track currentCoveredIndividualList = [];
    @track currentOutsideCoveredIndividualList = [];
    @track showPolicyHolderModal = false;
    @track callSaveEnrollment = false;
    @track hasMiddleInitial = false;
    @track showSpinner = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track disableSourceOfCoverage;
    @track disableCompanyName;
    @track disableAddress;
    @track disablePlanName;
    @track disablePolicyId;
    @track disableGroupId;
    @track disablePlanStartDate;
    @track disableEnrollmentTierOptionList;
    @track disablePolicyHolderOptionList;
    @track disableFirstName;
    @track disableMiddleName;
    @track disableHasMiddleInitial;
    @track disableLastName;
    @track disableSuffix;
    @track hasSourceOfCoverage = false;
    //@track disableDoNotHaveAllInformation;
    @track pageName;
    @track enrollmentVerification = false;
    @track oldPolicyAndCoveredIndividualValue;
    @track oldListWhoIsEnrolledInPlan = [];
    @track isToShowAtleastOneMemberErrorMsg = false;
    @track isHealthCarePolicyApprove = false;
    @track isSpanishFlag;
    label = {
        sspIndividualEnrollDesc,
        sspEnrollmentDetailsTitle,
        sspAccessDetailsTitle,
        sspEnrollmentDetailsDesc,
        sspEnrollmentDetailsSource,
        sspEnrollmentDetails,
        sspEnrollmentDetailsCompanyName,
        sspEnrollmentDetailsPlansName,
        sspEnrollmentDetailsPlans,
        sspEnrollmentDetailsPolicyId,
        sspEnrollmentDetailsGroupId,
        sspEnrollmentDetailsPlanStart,
        sspEnrollmentDetailsMemberEnrolled,
        sspEnrollmentDetailsMemberDetails,
        sspEnrollmentDetailsPolicyHolder,
        sspEnrollmentDetailsPolicyMembers,
        sspEnrollmentDetailsAddMember,
        sspBenefitsApplication,
        sspAddress,
        sspAddressLineTwo,
        sspEnrollmentDetailsNoMiddleName,
        sspEnrollmentDetailsWhoIsEnrolled,
        sspEnrollmentDetailsInsufficientInfo,
        sspFirstName,
        sspMiddleInitial,
        sspLastName,
        sspSuffix,
        sspSave,
        sspCancel,
        sspEnrollmentDetailsSourceAlt,
        sspEnrollmentDetailsMemberEnrolledAlt,
        sspEnrollmentDetailsPolicyMembersAlt,
        sspEnrollmentDetailsInsufficientInfoAlt,
        sspEnrollmentDetailsSaveAlt,
        sspEnrollmentDetailsCancelAlt,
        toastErrorText,
        sspAccessDetailsWhoHasAccess,
        sspAccessDetailsPolicyMembersAlt,
        sspAccessDetailsAddMember,
        sspPageInformationVerified,
        sspCoveredIndividualErrorMsg,
        sspAtleastOneHouseholdErrorMsg,
        sspHealthCareApprovedMsg,
        sspAccessDetailsContent,
        sspEnrollmentPhone,
        startBenefitsAppCallNumber
    };
    validationFieldVsMsg = [];
    summaryTitle = "";
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
    callUsAtApproved = `tel:${this.label.sspEnrollmentPhone}`;

    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }

    /**
     * @function - connectedCallback.
     * @description - Get all the Enrollment Details on page load.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            this.showSpinner = true;
            if (this.isEnrolled === true) {
                this.saveButtonAlt = this.label.sspEnrollmentDetailsSaveAlt;
                this.cancelButtonAlt = this.label.sspEnrollmentDetailsCancelAlt;
                this.label.sspPageInformationVerified = formatLabels(
                    this.label.sspPageInformationVerified,
                    [this.label.sspEnrollmentDetailsTitle]
                );
                document.title = "Enrollment Details";
            } else {
                this.saveButtonAlt = sspAccessDetailsSave;
                this.cancelButtonAlt = sspAccessDetailsCancel;
                this.label.sspPageInformationVerified = formatLabels(
                    this.label.sspPageInformationVerified,
                    [this.label.sspAccessDetailsTitle]
                );
                document.title = "Access Details";
            }
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .typeOfCoverageFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .insuranceCompanyNameFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .insurancePolicyNumberFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .insuranceGroupNumberFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .policyBeginDateFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .planNameFieldName +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .enrollmentTierLevelFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .physicalAddressLine1FieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .physicalAddressLine2FieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .objectApi,
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalCity__c +
                "," +
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .objectApi,
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalCountyCode__c +
                "," +
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .objectApi,
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalStateCode__c +
                "," +
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .objectApi,
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalZipCode5__c +
                "," +
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                    .objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .insuranceInternalPolicyHolderFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .suffixCodeFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .extPolicyHolderFirstNameFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .extPolicyHolderMiddleInitialFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .extPolicyHolderLastNameFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .firstNameFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi,
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .lastNameFieldApi +
                    "," +
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi
            );
            let screenId = enrollmentDetailScreenId;
            if(this.isEnrolled)
              {  screenId = enrollmentDetailScreenId;}
            else
            { screenId = accessDetailScreenId; }

            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                screenId
            );
            getEnrollmentDetails({
                sApplicationId: this.applicationId,
                sInsurancePolicyId: this.insurancePolicyId,
                bIsEnrolledInInsurance: this.isEnrolledInInsurance
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.objEnrollmentDetailsData = JSON.parse(
                            JSON.stringify(
                                result.mapResponse.enrollmentDetailsData
                            )
                        );
                        this.isSpanishFlag = result.mapResponse.isSpanishFlag;
                        const IsHealthCareCoverageApproved = this
                            .objEnrollmentDetailsData
                            .bisHealthCareCoverageApproved;
                        this.isHealthCarePolicyApprove = this
                        .objEnrollmentDetailsData
                        .bisHealthCareCoverageApproved;
                        const disableEverything = this.objEnrollmentDetailsData
                            .bisHealthCarePolicyHolderOutsideCase;
                        //To set Source Of Coverage Type Ahead Picklist
                        this.setSourceOfCoverageTypeAheadList();

                        //To set Address Line Structure
                        this.setAddressLineStructure();

                        //To set Enrollment Tier List Option List
                        this.setEnrollmentTierList(result);

                        //To set SuffixCode Option List
                        this.setSuffixCodeOptionList(result);

                        const coveredIndList =
                            result.mapResponse.enrollmentDetailsData
                                .lstCoveredInd;
                        const memberIdList = [];
                        const memberIdListToBeDisable = {};
                        if (
                            coveredIndList !== undefined &&
                            coveredIndList.length > 0
                        ) {
                            coveredIndList.forEach(element => {
                                memberIdList.push(element.sMemberId);
                                memberIdListToBeDisable[element.sMemberId] = element.bIsExistingRecord;
                                this.currentCoveredIndividualList.push(
                                    element.sMemberId
                                );
                            });
                        }
                        const allHOHMembers =
                            result.mapResponse.enrollmentDetailsData
                                .lstHOHMembers;
                        if (
                            allHOHMembers !== undefined &&
                            allHOHMembers.length > 0
                        ) {
                            allHOHMembers.forEach(memberElement => {
                               

                                // Below code to fill the Policy Holder List.
                                // 1. Get Id of Policy Holder from the Response.
                                // 2. Check Policy Holder Id against HOH List.
                                // 3. if Policy Holder Id exists, then mark true, else mark it as false.
                                let policyHolderId = "";
                                if (
                                    result.mapResponse.enrollmentDetailsData
                                        .objPolicyHolder !== undefined
                                ) {
                                    policyHolderId =
                                        result.mapResponse.enrollmentDetailsData
                                            .objPolicyHolder.sMemberId;
                                }

                                this.policyHolderOptionList.push({
                                    label:
                                        memberElement.sCoveredIndFirstName +
                                        " " +
                                        memberElement.sCoveredIndLastName,
                                    value: memberElement.sMemberId
                                });

                                // To set the Radio button to true for Policy Holder
                                if (
                                    memberElement.sMemberId === policyHolderId
                                ) {
                                    this.policyHolderValue =
                                        memberElement.sMemberId;
                                }

                                // Below code to fill the Covered Individual List.
                                // 1. Get all the covered Individual Id in List
                                // 2. Check covered individual Id list against HOH List.
                                // 3. if covered individual Id exists, then mark true, else mark it as false.
                                if (
                                    memberIdList.indexOf(
                                        memberElement.sMemberId
                                    ) !== -1
                                ) {
                                    const disableField =
                                        (IsHealthCareCoverageApproved &&
                                            memberIdListToBeDisable[
                                                memberElement.sMemberId
                                            ]) ||
                                        disableEverything
                                            ? true
                                            : false;
                                    //if exists then set to true
                                    this.lstWhoIsEnrolledInPlan.push({
                                        label:
                                            memberElement.sCoveredIndFirstName +
                                            " " +
                                            memberElement.sCoveredIndLastName,
                                        value: memberElement.sMemberId,
                                        checked: true,
                                        disable: disableField
                                    });
                                    this.selectedEnrollPlanList.push(
                                        memberElement.sMemberId
                                    );
                                } else {
                                    //if not exists then set to false
                                    this.lstWhoIsEnrolledInPlan.push({
                                        label:
                                            memberElement.sCoveredIndFirstName +
                                            " " +
                                            memberElement.sCoveredIndLastName,
                                        value: memberElement.sMemberId,
                                        checked: false,
                                        disable: disableEverything
                                    });
                                }
                            });
                        }
                        //Added to disable Covered Individual if policy holder is also selected as currentOutsideCoveredIndividualList
                        this.oldListWhoIsEnrolledInPlan = JSON.parse(JSON.stringify(this.lstWhoIsEnrolledInPlan));
                        this.updateEnrolledInPlanOptions(this.policyHolderValue);
                        
                        // To set the last radio button as "Someone out side house hold" for Policy Holder
                        this.policyHolderOptionList.push({
                            label: outsideHOHLabel,
                            value: outsideHOHValue
                        });

                        if (
                            this.objEnrollmentDetailsData.objPolicyHolder !==
                                undefined &&
                            Object.keys(
                                this.objEnrollmentDetailsData.objPolicyHolder
                            ).length !== 0
                        ) {
                            this.currentPolicyHolderId = this.objEnrollmentDetailsData.objPolicyHolder.sCoveredIndId;
                        } else if (
                            this.objEnrollmentDetailsData
                                .objOutsidePolicyHolder !== undefined &&
                            Object.keys(
                                this.objEnrollmentDetailsData
                                    .objOutsidePolicyHolder
                            ).length !== 0
                        ) {
                            this.policyHolderValue = outsideHOHValue;
                            this.showPolicyHolderBlock = true;
                            this.currentPolicyHolderId = this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndId;
                            this.hasMiddleInitials();
                        }

                        // To set the last checkbox to True/False for "Someone outside house hold" Covered Individual
                        this.setSomeoneOutsideCheckboxValue();

                        // Added below condition because objOutsidePolicyHolder was getting undefined on Input text value attribute.
                        if (
                            this.objEnrollmentDetailsData
                                .objOutsidePolicyHolder === undefined
                        ) {
                            this.objEnrollmentDetailsData.objOutsidePolicyHolder = {};
                        }

                        // Format the Date for Time Travel setting
                        this.objEnrollmentDetailsData.sTimeTravelDate = this.setTimeTravelDate(
                            this.objEnrollmentDetailsData.sTimeTravelDate
                        );

                        this.showSpinner = false;

                        //Below condition is used to disable fields for approved records
                        if (IsHealthCareCoverageApproved || disableEverything) {
                            this.disableSourceOfCoverage = true;
                            this.disableCompanyName = true;
                            this.disableAddress = true;
                            this.disablePlanName = true;
                            this.disablePolicyId = true;
                            this.enrollmentVerification = true;
                            if (disableEverything) {
                                this.disablePlanStartDate = true;
                            }
                            if (
                                !this.isEnrolledInInsurance ||
                                disableEverything
                            ) {
                                this.disableEnrollmentTierOptionList = true;
                                this.disableGroupId = true;
                            }
                            this.disablePolicyHolderOptionList = true;
                            this.disableFirstName = true;
                            this.disableMiddleName = true;
                            this.disableHasMiddleInitial = true;
                            this.disableLastName = true;
                            this.disableSuffix = true;
                            //this.disableDoNotHaveAllInformation = true;
                        }
                    } else if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in connectedCallback of Enrollment Detail page" +
                                result.mapResponse.ERROR
                        );
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback of Enrollment Detail page" +
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
                "Error in hideToast on sspEnrollmentDetails screen" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function - storeEnrollmentDetails
     * @description - Method use to store the Enrollment Details.
     */
    storeEnrollmentDetails = () => {
        try {
          if (this.isReadOnlyUser) { // CD2 2.5 Security Role Matrix and Program Access.
              if (this.showPolicyHolderBlock && this.hasKIHIPPProgram) {
                  this.showPolicyHolderModal = true;
              }
              else{
                  this.cancelEnrollmentDetails();
              }
            } else {
                const middleNameInput = this.template.querySelector(
                    ".ssp-enrollmentDetailMiddleInitial"
                );

              if (middleNameInput !== null && middleNameInput !== undefined  &&
                    this.disableMiddleName === true &&
                    middleNameInput.classList.contains("inputElement") &&
                    !middleNameInput.value
                ) {
                    middleNameInput.classList.remove("inputElement");
              } else if (middleNameInput !== null && middleNameInput !== undefined &&
                    this.disableMiddleName === false &&
                    !middleNameInput.classList.contains("inputElement") &&
                    middleNameInput.value
                ) {
                    middleNameInput.classList.add("inputElement");
                }
                this.objEnrollmentDetailsData.lstOutsideCoveredInd = [];
                const inputElement = this.template.querySelectorAll(
                    ".inputElement"
                );

            const addressElement = this.template.querySelector(
                ".addressLineClass"
            );
            let bAddressValidation = false;
            if (addressElement) {
                const errors = addressElement.ErrorMessages();

                if (errors.length > 0) {
                    bAddressValidation = true;
                }
            }
            this.checkValidations(inputElement);
            this.selectCoveredIndValidation();
            this.checkAtleastOneHouseholdMember(); // Added this method to fire Atleast one household member validation message.
              if (this.allowSaveData !== undefined && this.allowSaveData && !bAddressValidation && !this.isToShowAtleastOneMemberErrorMsg) {
                if (this.showPolicyHolderBlock && this.hasKIHIPPProgram) {
                    this.showPolicyHolderModal = true;
                } else {
                    this.showSpinner = true;
                    this.assignInsurancePolicyDetailsData(inputElement);
                }
            } else if (
                this.allowSaveData !== undefined &&
                  (!this.allowSaveData || this.isToShowAtleastOneMemberErrorMsg || bAddressValidation)
            ) {
                this.hasSaveValidationError = true;
                this.showSpinner = false;
            }
            //Added to handle review required logic for screen
            if(this.allowSaveData){
                if (this.mode !== sspConstants.applicationMode.RENEWAL) {
                const revRules = [];
                const listMemberId = [];
                const memberId =
                    this.objEnrollmentDetailsData.objPolicyHolder !==
                        undefined &&
                    this.objEnrollmentDetailsData.objPolicyHolder.sMemberId !==
                        undefined &&
                    this.objEnrollmentDetailsData.objPolicyHolder.sMemberId !==
                        ""
                        ? this.objEnrollmentDetailsData.objPolicyHolder
                              .sMemberId
                        : "null";
                listMemberId.push(memberId);
                const isKIHIPPCoverage = this.objEnrollmentDetailsData.isKIHIPPSourceOfCoverage;
                inputElement.forEach(function (key) {
                    if (key.fieldName === "IsPolicyHolder__c" && isKIHIPPCoverage) {
                        if (key.oldValue !== key.value) {
                            revRules.push(
                                sspConstants.sspEnrollmentDetails
                                    .policyHolderChangeRule +
                                    "," +
                                    true +
                                    "," +
                                    "null"
                            );
                        } else {
                            revRules.push(
                                sspConstants.sspEnrollmentDetails
                                    .policyHolderChangeRule +
                                    "," +
                                    false +
                                    "," +
                                    "null"
                            );
                        }
                    }
                });
                const selectedEvent = new CustomEvent(
                    sspConstants.sspEnrollmentDetails.ruleChange,
                    {
                        detail: revRules
                    }
                );
                this.dispatchEvent(selectedEvent);
                }
            }
        } 
      }catch (error) {
            console.error(
                "Error occurred in storeEnrollmentDetailsData of Enrollment Detail page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleChange.
     * @description - TO select the Policy Holder and Covered Individuals.
     * @param {*} event - Fired on selection of Policy Holder and Covered Individuals.
     */
    handleChange = event => {
        try {
            //Start - Policy Holder Radio Button Condition
            if (
                event.target.fieldName ===
                sspConstants.sspEnrollmentDetails.sspInsuranceCoveredIndividual
                    .insuranceInternalPolicyHolderFieldApi
            ) {
                if (
                    this.objEnrollmentDetailsData.objPolicyHolder !==
                        undefined &&
                    event.detail.value !== outsideHOHValue
                ) {
                    const existingPolicyHolderId = this.objEnrollmentDetailsData
                        .objPolicyHolder.sMemberId;
                    if (existingPolicyHolderId !== event.detail.value) {
                        const member = {};
                        member.sMemberId = event.detail.value;
                        this.objEnrollmentDetailsData.objPolicyHolder = member;
                    }
                } else if (event.detail.value !== outsideHOHValue) {
                    const member = {};
                    member.sMemberId = event.detail.value;
                    this.objEnrollmentDetailsData.objPolicyHolder = member;
                }
                this.toggleAdditionalFieldsRadio(event);
            }
            const chType = event.target.dataset.id;
            if (chType === "IsPolicyHolder__c"){
                this.updateEnrolledInPlanOptions(event.detail.value);
            }
            //End - Policy Holder Radio Button Condition
            //Start - Covered Individual Checkbox Condition
            if (
                event.target.entityName ===
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.objectApi &&
                event.target.value === true &&
                event.target.dataset.whoEnrolled === whoIsEnrolledInPlanLabel
            ) {
                if (
                    this.objEnrollmentDetailsData.lstCoveredInd !== undefined &&
                    this.objEnrollmentDetailsData.lstCoveredInd.length > 0 &&
                    event.target.inputValue !== outsideHOHValue
                ) {
                    this.objEnrollmentDetailsData.lstCoveredInd.forEach(
                        element => {
                            if (
                                this.selectedEnrollPlanList.indexOf(
                                    event.target.inputValue
                                ) === -1 // Not exists
                            ) {
                                this.selectedEnrollPlanList.push(
                                    event.target.inputValue
                                );
                            }
                            this.elementTemporary = element;
                        }
                    );
                } else if (event.target.inputValue !== outsideHOHValue) {
                    this.selectedEnrollPlanList.push(event.target.inputValue);
                }
                this.addCoveredIndividualMember();
                this.toggleAdditionalFieldsCheck(event);
                this.selectCoveredIndValidation();
            } else if (
                // exists block
                event.target.value === false &&
                this.selectedEnrollPlanList.indexOf(event.target.inputValue) !==
                    -1 &&
                event.target.dataset.whoEnrolled === whoIsEnrolledInPlanLabel
            ) {
                this.selectedEnrollPlanList.splice(
                    this.selectedEnrollPlanList.indexOf(
                        event.target.inputValue
                    ),
                    1
                );
                this.addCoveredIndividualMember();
                this.selectCoveredIndValidation();
            } else {
                this.toggleAdditionalFieldsCheck(event);
                //this.selectCoveredIndValidation();
            }
            //End - Covered Individual Checkbox Condition

            //Start - Do not have all Information Checkbox
            /*if (
                event.target.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .doNotHaveAllInformationFieldApi &&
                event.target.value === true
            ) {
                this.objEnrollmentDetailsData.bDoNotHaveAllInformation = true;
                this.whoIsEnrollInPlanErrorMsg = "";
                this.byPassValidations();
            } else if (
                event.target.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .doNotHaveAllInformationFieldApi &&
                event.target.value === false
            ) {
                this.objEnrollmentDetailsData.bDoNotHaveAllInformation = false;
                this.whoIsEnrollInPlanErrorMsg = "";
                Object.keys(this.MetaDataListParent).forEach(element => {
                    if (this.validationFieldVsMsg.indexOf(element) !== -1) {
                        // Exist block
                        this.MetaDataListParent[element][
                            sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                        ] = true;
                    }
                });
            }*/
            //End - Do not have all Information Checkbox
        } catch (error) {
            console.error(
                "Error occurred in handleChange of Enrollment Detail page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - addCoveredIndividualMember.
     * @description - Adds the Covered Individuals data and assigned to wrapper.
     */
    addCoveredIndividualMember = () => {
        try {
            if (this.selectedEnrollPlanList.length > 0) {
                this.objEnrollmentDetailsData.lstCoveredInd = [];
                this.selectedEnrollPlanList.forEach(memberData => {
                    const member = {};
                    member.sMemberId = memberData;
                    this.objEnrollmentDetailsData.lstCoveredInd.push(member);
                });
            }
        } catch (error) {
            console.error(
                "Error in addCoveredIndividualMember of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - toggleAdditionalFieldsRadio.
     * @description - Shows the Policy Holder block.
     * @param {*} e - Fired on selection of Outside Policy Holder.
     */
    toggleAdditionalFieldsRadio = e => {
        try {
            const radioBtnValue = e.detail.value;
            if (radioBtnValue === outsideHOHValue) {
                this.showPolicyHolderBlock = true;
            } else {
                this.showPolicyHolderBlock = false;
                this.checkAtleastOneHouseholdMember(); // To remove Atleast one household member validation msg when it is Internal Member.
            }
        } catch (error) {
            console.error(
                "Error in toggleAdditionalFieldsRadio of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - toggleAdditionalFieldsCheck.
     * @description - Shows the Covered Individuals block.
     * @param {*} event - Fired on selection of Outside Covered Individuals.
     */
    toggleAdditionalFieldsCheck = event => {
        try {
            if (
                event.target.value === true &&
                event.target.inputValue === outsideHOHValue
            ) {
                this.showCoveredIndividualBlock = true;
                this.incrementMembersToAdd(event);
            } else if (
                event.target.value === false &&
                event.target.inputValue === outsideHOHValue
            ) {
                this.showCoveredIndividualBlock = false;
            }
        } catch (error) {
            console.error(
                "Error in toggleAdditionalFieldsCheck of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - disableMiddleNameInput.
     * @description - Disabled the Middle Initial fields on UI.
     * @param {object{}} event - Contains event element values.
     */
    disableMiddleNameInput = event => {
        try {
            const middleNameInput = this.template.querySelectorAll(
                ".ssp-enrollmentDetailMiddleInitial"
            );
            if (event.target.value === true) {
                middleNameInput[0].disabled = true;
                middleNameInput[0].value = "";
                middleNameInput[0].classList.remove("inputElement");
                this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndMiddleInitial = "";
                //Below condition is use to bypass the Middle initial required validation.
                //if (!this.objEnrollmentDetailsData.bDoNotHaveAllInformation) {
                this.MetaDataListParent[
                    middleNameInput[0].fieldName +
                        "," +
                        middleNameInput[0].entityName
                ][
                    sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                ] = false;
                this.checkValidations(middleNameInput);
                //}
            } else {
                middleNameInput[0].disabled = false;
                this.disableMiddleName = false;
                //Below condition is use to add the Middle initial required validation.
                //if (!this.objEnrollmentDetailsData.bDoNotHaveAllInformation) {
                middleNameInput[0].classList.add("inputElement");
                this.MetaDataListParent[
                    middleNameInput[0].fieldName +
                        "," +
                        middleNameInput[0].entityName
                ][
                    sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                ] = true;
                //}
            }
        } catch (error) {
            console.error(
                "Error in disableMiddleNameInput of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - assignValues.
     * @description - Set the Source of Coverage Value to Type ahead Picklist field on UI.
     * @param {*} event - Fired on selection of Source of Coverage Type ahead Picklist.
     */
    assignValues = event => {
        try {
            //Start - To show subsequent Field if Source Of Coverage is Populated with Value
            if (
                event.detail.selectedValue !== undefined &&
                event.detail.selectedValue !== ""
            ) {
                this.hasSourceOfCoverage = true;
            } else {
                this.hasSourceOfCoverage = false;
            }
            //End - To show subsequent Field if Source Of Coverage is Populated with Value

            this.objEnrollmentDetailsData.sSourceHealthCareCoverage =
                event.detail.selectedValue;

            this.objEnrollmentDetailsData.lstSourceOfCoverage.forEach(
                element => {
                    if (element.DeveloperName === event.detail.selectedValue) {
                        this.checkProgram(element);
                    }
                }
            );
            //To Add/Remove the Someone Outside my Household from the List
            if (this.hasKIHIPPProgram) {
                //To add Outside Household to List
                this.setSomeoneOutsideCheckboxValue();
            } else if (!this.hasKIHIPPProgram) {
                this.showCoveredIndividualBlock = false;
                //To Remove Outside Household from List
                if (this.lstWhoIsEnrolledInPlan.length > 0) {
                    for (
                        let index = 0;
                        index < this.lstWhoIsEnrolledInPlan.length;
                        index++
                    ) {
                        const memberElement = this.lstWhoIsEnrolledInPlan[
                            index
                        ];
                        if (memberElement.value === outsideHOHValue) {
                            this.lstWhoIsEnrolledInPlan.splice(index, 1);
                            break;
                        }
                    }
                }
            }
        } catch (error) {
            console.error(
                "Error in assignValues of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - setSourceOfCoverageTypeAheadList.
     * @description - Set the Value to Type Ahead Picklist on Page Load.
     */
    setSourceOfCoverageTypeAheadList = () => {
        try {
            //To set Source Of Coverage Type Ahead Picklist
            if (
                this.objEnrollmentDetailsData.lstSourceOfCoverage !==
                    undefined &&
                this.objEnrollmentDetailsData.lstSourceOfCoverage.length > 0
            ) {
                this.objEnrollmentDetailsData.lstSourceOfCoverage.forEach(
                    element => {
                        this.sourceOfCoverageList.push({
                            label: this.isSpanishFlag === true?  element.SourceOfCoverageSpanish__c : element.SourceOfCoverageValue__c,
                            value: element.DeveloperName
                        });
                        if (
                            this.objEnrollmentDetailsData
                                .sSourceHealthCareCoverage !== "" &&
                            this.objEnrollmentDetailsData
                                .sSourceHealthCareCoverage ===
                                element.DeveloperName
                        ) {
                            this.sourceOfCoverage =
                                element.SourceOfCoverageValue__c;
                            this.checkProgram(element);
                        }
                    }
                );
                //To show subsequent Field if Source Of Coverage is Populated
                if (this.sourceOfCoverage !== "") {
                    this.hasSourceOfCoverage = true;
                } else {
                    this.hasSourceOfCoverage = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in setSourceOfCoverageTypeAheadList of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - checkProgram.
     * @description - Use to show/hide KIHIPP program related blocks.
     * @param {object{}} element - Contains the Program Applied.
     */
    checkProgram = element => {
        try {
            if (element.Programs_Applied__c !== "") {
                const programApplied = element.Programs_Applied__c.split(",");
                if (programApplied.indexOf(sKIHIPPProgramValue) !== -1) {
                    // KI-HIPP Program exists
                    this.hasKIHIPPProgram = true;
                } else {
                    this.hasKIHIPPProgram = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in checkProgram of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - setAddressLineStructure.
     * @description - Use to set the Address Line Structure on Page Load.
     */
    setAddressLineStructure = () => {
        try {
            //Start - Address Line Structure
            const addressRecord = {};
            addressRecord.apiName =
                sspConstants.sspEnrollmentDetails.sspInsurancePolicy.objectApi;
            addressRecord.childRelationships = {};
            addressRecord.id = this.objEnrollmentDetailsData.sInsurancePolicyId;

            const sFields = {};

            const physicalAddressLine1 = {};
            physicalAddressLine1.displayValue = null;
            physicalAddressLine1.value =
                this.objEnrollmentDetailsData.sAddressLine1 || null;
            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalAddressLine1__c
            ] = physicalAddressLine1;

            const physicalAddressLine2 = {};
            physicalAddressLine2.displayValue = null;
            physicalAddressLine2.value =
                this.objEnrollmentDetailsData.sAddressLine2 || null;
            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalAddressLine2__c
            ] = physicalAddressLine2;

            const physicalCity = {};
            physicalCity.displayValue = null;
            physicalCity.value = this.objEnrollmentDetailsData.sCity || null;
            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalCity__c
            ] = physicalCity;

            const physicalCountryCode = {};
            physicalCountryCode.displayValue = null;
            physicalCountryCode.value =
                this.objEnrollmentDetailsData.sCountryCode || null;

            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalCountryCode__c
            ] = physicalCountryCode;

            const physicalCountyCode = {};
            physicalCountyCode.displayValue = null;
            physicalCountyCode.value =
                this.objEnrollmentDetailsData.sCountyCode || null;

            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalCountyCode__c
            ] = physicalCountyCode;

            const physicalStateCode = {};
            physicalStateCode.displayValue = null;
            physicalStateCode.value =
                this.objEnrollmentDetailsData.sStateCode || null;

            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalStateCode__c
            ] = physicalStateCode;

            const physicalZipCode4 = {};
            physicalZipCode4.displayValue = null;
            physicalZipCode4.value =
                this.objEnrollmentDetailsData.sZipCode4 || null;
            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalZipCode4__c
            ] = physicalZipCode4;

            const physicalZipCode5 = {};
            physicalZipCode5.displayValue = null;
            physicalZipCode5.value =
                this.objEnrollmentDetailsData.sZipCode5 || null;
            sFields[
                sspConstants.sspEnrollmentDetails.addressFields.PhysicalZipCode5__c
            ] = physicalZipCode5;

            addressRecord.fields = sFields;
            this.addressRecord = JSON.parse(JSON.stringify(addressRecord));
            //End - Address Line Structure
        } catch (error) {
            console.error(
                "Error in setAddressLineStructure of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - setEnrollmentTierList.
     * @description - Use to set the Enrollment Tier List.
     * @param  {object{}} result - Contains Wrapper data.
     */
    setEnrollmentTierList = result => {
        try {
            const mapEnrollmentTierLevel =
                result.mapResponse.enrollmentDetailsData.mapEnrollmentTierLevel;
            Object.keys(mapEnrollmentTierLevel).forEach(element => {
                this.enrollmentTierOptionList.push({
                    label: mapEnrollmentTierLevel[element],
                    value: element
                });
            });
        } catch (error) {
            console.error(
                "Error in setEnrollmentTierList of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - setSuffixCodeOptionList.
     * @description - Use to set the SuffixCode List.
     * @param  {object{}} result - Contains Wrapper data.
     */
    setSuffixCodeOptionList = result => {
        try {
            //SuffixCode Option List
            const mapSuffixCode =
                result.mapResponse.enrollmentDetailsData.mapSuffixCode;
            Object.keys(mapSuffixCode).forEach(element => {
                this.suffixCodeList.push({
                    label: mapSuffixCode[element],
                    value: element
                });
            });
        } catch (error) {
            console.error(
                "Error in setSuffixCodeOptionList of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - selectCoveredIndValidation.
     * @description - Use to set the Covered Individual custom validation message.
     */
    selectCoveredIndValidation = () => {
        try {
            let isAtLeastOneEnrolled=false;
            if (
                this.selectedEnrollPlanList.length <= 0 &&
                !this.showCoveredIndividualBlock //&&
                //!this.objEnrollmentDetailsData.bDoNotHaveAllInformation
            ) {
                for (let i=0;i<this.lstWhoIsEnrolledInPlan.length;i++){
                    if (this.lstWhoIsEnrolledInPlan[i].disable){
                        isAtLeastOneEnrolled = true;
                        break;
                    }
                }
                if (isAtLeastOneEnrolled){
                    this.whoIsEnrollInPlanErrorMsg = "";
                    if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                        this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.remove("ssp-checkbox-error");
                    } 
                }
                else{
                    this.whoIsEnrollInPlanErrorMsg = this.label.sspCoveredIndividualErrorMsg;
                    this.isToShowAtleastOneMemberErrorMsg = false;
                    this.allowSaveData = false;
                    if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                        this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.add("ssp-checkbox-error");
                    }
                }
            } else {
                this.whoIsEnrollInPlanErrorMsg = "";
                this.isToShowAtleastOneMemberErrorMsg = false;
                if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                    this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.remove("ssp-checkbox-error");
                }
            }
        } catch (error) {
            console.error(
                "Error in selectCoveredIndValidation of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - cancelEnrollmentDetails.
     * @description - Method is used for Cancel button which redirect to Enrollment Summary Page.
     */
    cancelEnrollmentDetails = () => {
        try {
            this.showEnrollmentDetails = false;
            const selectedEvent = new CustomEvent("summary", {
                detail: this.showEnrollmentDetails
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error in cancelEnrollmentDetails of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - addPolicyHoldetToDelete.
     * @description - Method use to send previous Policy Holder to delete.
     */
    addPolicyHolderToDelete = () => {
        try {
            // When user selects -> internal policy holder from previous selection -> outside policy holder.
            if (
                !this.showPolicyHolderBlock &&
                this.objEnrollmentDetailsData.objOutsidePolicyHolder
                    .sCoveredIndId !== undefined
            ) {
                this.objEnrollmentDetailsData.sPolicyHolderMemberIdDelete = this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndId;
                this.objEnrollmentDetailsData.objOutsidePolicyHolder = {};
            }
            // To satisfy the below condition, when user selects -> outside policy holder from  the previous selection -> internal policy holder
            if (
                this.showPolicyHolderBlock &&
                this.objEnrollmentDetailsData.objPolicyHolder !== undefined &&
                this.objEnrollmentDetailsData.objPolicyHolder.sMemberId !==
                    undefined
            ) {
                this.objEnrollmentDetailsData.objPolicyHolder.sMemberId = "";
            }
            // When user select only -> internal policy holder from previous selection -> internal policy holder
            if (
                this.objEnrollmentDetailsData.objPolicyHolder !== undefined &&
                Object.keys(this.objEnrollmentDetailsData.objPolicyHolder)
                    .length !== 0 &&
                this.policyHolderValue !==
                    this.objEnrollmentDetailsData.objPolicyHolder.sMemberId &&
                this.policyHolderValue !== outsideHOHValue
            ) {
                this.objEnrollmentDetailsData.sPolicyHolderMemberIdDelete = this.currentPolicyHolderId;
            }
            // when outside policy holder exists then we empty the internal policy holder block
            if (
                this.objEnrollmentDetailsData.objPolicyHolder !== undefined &&
                this.objEnrollmentDetailsData.objPolicyHolder.sMemberId === ""
            ) {
                this.objEnrollmentDetailsData.objPolicyHolder = {};
            }
        } catch (error) {
            console.error(
                "Error in addPolicyHolderToDelete of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - addCoveredIndividualToDelete.
     * @description - Method use to send previous Covered Individual to delete.
     */
    addCoveredIndividualToDelete = () => {
        try {
            this.objEnrollmentDetailsData.lstOutsideCoveredIndDelete = [];
            this.objEnrollmentDetailsData.lstCoveredIndDelete = [];
            // Remove the selected internal covered individual from the List to delete
            if (
                this.objEnrollmentDetailsData.lstCoveredInd !== undefined &&
                this.objEnrollmentDetailsData.lstCoveredInd.length > 0
            ) {
                for (
                    let index = 0;
                    index < this.objEnrollmentDetailsData.lstCoveredInd.length;
                    index++
                ) {
                    const element = this.objEnrollmentDetailsData.lstCoveredInd[
                        index
                    ];
                    if (
                        this.currentCoveredIndividualList.indexOf(
                            element.sMemberId
                        ) !== -1
                    ) {
                        //exists
                        this.currentCoveredIndividualList.splice(
                            this.currentCoveredIndividualList.indexOf(
                                element.sMemberId
                            ),
                            1
                        );
                        this.objEnrollmentDetailsData.lstCoveredInd.splice(
                            index,
                            1
                        );
                        index--;
                    }
                }
            }
            // Remove the selected external covered individual from the List to delete
            if (
                this.objEnrollmentDetailsData.lstOutsideCoveredInd !==
                    undefined &&
                this.objEnrollmentDetailsData.lstOutsideCoveredInd.length > 0
            ) {
                for (
                    let index = 0;
                    index <
                    this.objEnrollmentDetailsData.lstOutsideCoveredInd.length;
                    index++
                ) {
                    const element = this.objEnrollmentDetailsData
                        .lstOutsideCoveredInd[index];
                    if (
                        this.currentOutsideCoveredIndividualList.indexOf(
                            element.sCoveredIndId
                        ) !== -1
                    ) {
                        //exists
                        this.currentOutsideCoveredIndividualList.splice(
                            this.currentOutsideCoveredIndividualList.indexOf(
                                element.sCoveredIndId
                            ),
                            1
                        );
                        this.objEnrollmentDetailsData.lstOutsideCoveredInd.splice(
                            index,
                            1
                        );
                        index--;
                    }
                }
            }
            this.objEnrollmentDetailsData.lstCoveredIndDelete = this.currentCoveredIndividualList;
            this.objEnrollmentDetailsData.lstOutsideCoveredIndDelete = this.currentOutsideCoveredIndividualList;
        } catch (error) {
            console.error(
                "Error in addCoveredIndividualToDelete of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - hidePolicyHolderModal.
     * @description - Method use to hide policy holder Modal.
     */
    hidePolicyHolderModal = () => {
        try {
            this.showPolicyHolderModal = false;
            const inputElement = this.template.querySelectorAll(
                ".inputElement"
            );
            if (this.isReadOnlyUser) {
                this.cancelEnrollmentDetails();
            }
            else{
                this.assignInsurancePolicyDetailsData(inputElement);
            }
        } catch (error) {
            console.error(
                "Error in hidePolicyHolderModal of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - hasMiddleInitial.
     * @description - Method use to check whether middle initial exists or not to set the Middle Initials checkbox to true.
     */
    hasMiddleInitials = () => {
        try {
            if (
                this.objEnrollmentDetailsData.objOutsidePolicyHolder
                    .sCoveredIndMiddleInitial === undefined ||
                this.objEnrollmentDetailsData.objOutsidePolicyHolder
                    .sCoveredIndMiddleInitial === ""
            ) {
                this.hasMiddleInitial = true;
                this.disableMiddleName = true;
            }
        } catch (error) {
            console.error(
                "Error in hasMiddleInitials of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - assignInsurancePolicyWrapperData.
     * @description - Method use to assign the Insurance Policy Wrapper Data.
     * @param {object{}} inputElement - Contains element of fields.
     */
    assignInsurancePolicyWrapperData = inputElement => {
        let externalCoveredInd;
        try {
            inputElement.forEach(element => {
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .insuranceCompanyNameFieldApi
                ) {
                    this.objEnrollmentDetailsData.sInsuranceCompanyName =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .physicalAddressLine1FieldApi
                ) {
                    this.objEnrollmentDetailsData.sAddressLine1 = element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .physicalAddressLine2FieldApi
                ) {
                    this.objEnrollmentDetailsData.sAddressLine2 = element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .planNameFieldName
                ) {
                    this.objEnrollmentDetailsData.sInsurancePlanName =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .insurancePolicyNumberFieldApi
                ) {
                    this.objEnrollmentDetailsData.sPlanPolicyId = element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .insuranceGroupNumberFieldApi
                ) {
                    this.objEnrollmentDetailsData.sPlanGroupId = element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .policyBeginDateFieldApi
                ) {
                    this.objEnrollmentDetailsData.sPlanStartDate =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails.sspInsurancePolicy
                        .enrollmentTierLevelFieldApi
                ) {
                    this.objEnrollmentDetailsData.sHouseholdEnrolledPlan =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual.suffixCodeFieldApi
                ) {
                    this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndSuffix =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual
                        .extPolicyHolderFirstNameFieldApi
                ) {
                    this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndFirstName =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual
                        .extPolicyHolderMiddleInitialFieldApi
                ) {
                    this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndMiddleInitial =
                        element.value;
                }
                if (
                    element.fieldName ===
                    sspConstants.sspEnrollmentDetails
                        .sspInsuranceCoveredIndividual
                        .extPolicyHolderLastNameFieldApi
                ) {
                    this.objEnrollmentDetailsData.objOutsidePolicyHolder.sCoveredIndLastName =
                        element.value;
                }
                if (
                    element.fieldName ===
                        sspConstants.sspEnrollmentDetails
                            .sspInsuranceCoveredIndividual.firstNameFieldApi &&
                    element.value !== ""
                ) {
                    externalCoveredInd = {};
                    externalCoveredInd.sCoveredIndFirstName = element.value;
                    externalCoveredInd.sCoveredIndId =
                        element.dataset.coveredIndId;
                }
                if (
                    element.fieldName ===
                        sspConstants.sspEnrollmentDetails
                            .sspInsuranceCoveredIndividual.lastNameFieldApi &&
                    element.value !== ""
                ) {
                    externalCoveredInd.sCoveredIndLastName = element.value;
                    externalCoveredInd.sCoveredIndId =
                        element.dataset.coveredIndId;
                    this.objEnrollmentDetailsData.lstOutsideCoveredInd.push(
                        externalCoveredInd
                    );
                }
            });
            this.objEnrollmentDetailsData.isKIHIPPSourceOfCoverage = this.hasKIHIPPProgram;
        } catch (error) {
            console.error(
                "Error in assignInsurancePolicyWrapperData of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - assignAddressLineData.
     * @description - Method to store the Address Line values in Wrapper Variables.
     */
    assignAddressLineData = () => {
        try {
            const addressLineClass = this.template.querySelector(
                ".addressLineClass"
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                this.objEnrollmentDetailsData.sAddressLine1 =
                    physicalAddress.addressLine1;
                this.objEnrollmentDetailsData.sAddressLine2 =
                    physicalAddress.addressLine2;
                this.objEnrollmentDetailsData.sCity = physicalAddress.city;
                this.objEnrollmentDetailsData.sCountryCode =
                    physicalAddress.country;
                this.objEnrollmentDetailsData.sCountyCode =
                    physicalAddress.county;
                this.objEnrollmentDetailsData.sStateCode =
                    physicalAddress.state;
                this.objEnrollmentDetailsData.sZipCode5 =
                    physicalAddress.postalCode;
            }
        } catch (error) {
            console.error(
                "Error in assignAddressLineData of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function - assignIsEnrolledInInsuranceData.
     * @description - Method to store isEnrolledInInsurance wrapper data for Enrollment/Access Data.
     */
    assignIsEnrolledInInsuranceData = () => {
        try {
            //Set the Enrollment/Access details screen flag
            if (this.isEnrolledInInsurance) {
                //SetEnrollment Detail data
                this.objEnrollmentDetailsData.bIsEnrolledInInsurance = true;
            } else if (!this.isEnrolledInInsurance) {
                //Access Detail data
                this.objEnrollmentDetailsData.bIsEnrolledInInsurance = false;
            }
        } catch (error) {
            console.error(
                "Error in assignIsEnrolledInInsuranceData of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function - storeEnrollmentDetailsDataToServer.
     * @description - Method to store Wrapper data to Server.
     */
    storeEnrollmentDetailsDataToServer = () => {
        try {
            storeEnrollmentDetailsData({
                sEnrollmentDetailResponse: JSON.stringify(
                    this.objEnrollmentDetailsData
                )
            })
                .then(result => {
                    if (!result.bIsSuccess) {
                        console.error(
                            "Error occurred in storeEnrollmentDetailsData of Enrollment Detail page. " +
                                result.mapResponse.ERROR
                        );
                    } else {
                        this.cancelEnrollmentDetails();
                    }
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error in storeEnrollmentDetailsDataToServer of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - assignInsurancePolicyDetailsData.
     * @description - Method use to assign the Insurance Policy Detail Data.
     * @param { object{ } } inputElement - Contains element of fields.
     */
    assignInsurancePolicyDetailsData = inputElement => {
        try {
            this.whoIsEnrollInPlanErrorMsg = "";
            if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.remove("ssp-checkbox-error");
            }
            this.assignInsurancePolicyWrapperData(inputElement);
            this.assignAddressLineData();
            this.addPolicyHolderToDelete();
            if (this.selectedEnrollPlanList.length <= 0) {
                this.objEnrollmentDetailsData.lstCoveredInd = [];
            }
            this.addCoveredIndividualToDelete();
            this.assignIsEnrolledInInsuranceData();
            this.objEnrollmentDetailsData.lstSourceOfCoverage = [];
            this.objEnrollmentDetailsData.mapEnrollmentTierLevel = {};
            this.objEnrollmentDetailsData.mapSuffixCode = {};
            this.objEnrollmentDetailsData.lstHOHMembers = [];
            this.storeEnrollmentDetailsDataToServer();
        } catch (error) {
            console.error(
                "Error in assignInsurancePolicyDetailsData of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - incrementMembersToAdd.
     * @description - Add Member block on click of add members.
     * @param {*} event - Fired on click of add members.
     */
    incrementMembersToAdd = event => {
        try {
            const IsHealthCareCoverageApproved = this.objEnrollmentDetailsData
                .bisHealthCareCoverageApproved;
            const disableEverything = this.objEnrollmentDetailsData
                .bisHealthCarePolicyHolderOutsideCase;
            const skipMemberAdding =
                disableEverything ||
                (IsHealthCareCoverageApproved && !this.isEnrolled)
                    ? true
                    : false;
            if (
                event.target.getAttribute("data-href")  ||
                (this.lstOutsideCoveredInd.length <= 0 && !skipMemberAdding)
            ) {
                const lengthMembersToAdd = {
                    sCoveredIndId: "",
                    sCoveredIndFirstName: "",
                    sCoveredIndLastName: ""
                };
                this.lstOutsideCoveredInd.push(lengthMembersToAdd);
            }
        } catch (error) {
            console.error(
                "Error occurred in incrementMembersToAdd of Enrollment Detail page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - byPassValidations.
     * @description - Method use to bypass the validation.
     */
    /*byPassValidations = () => {
        if (
            this.MetaDataListParent !== undefined &&
            Object.keys(this.MetaDataListParent).length > 0
        ) {
            Object.keys(this.MetaDataListParent).forEach(element => {
                if (
                    this.MetaDataListParent[element][
                        sspConstants.sspEnrollmentDetails.entityMappingMetaData
                            .Input_Required__c
                    ] === true
                ) {
                    this.validationFieldVsMsg.push(element);
                    this.MetaDataListParent[element][
                        sspConstants.sspEnrollmentDetails.entityMappingMetaData.Input_Required__c
                    ] = false;
                }
            });
            const inputElement = this.template.querySelectorAll(
                ".inputElement"
            );
            this.checkValidations(inputElement);
        }
    };*/

    /**
     * @function - setTimeTravelDate.
     * @description - Method use to format the Apex Time Travel Data into JS new Date().
     * @param {string} timeTravelDate - Contains the actual date.
     */
    setTimeTravelDate = timeTravelDate => {
        let dateTimeList;
        let sDate;
        let sDateSplit;
        let sHours = "";
        let sMinutes = "";
        let sSeconds = "";
        if (timeTravelDate !== undefined && timeTravelDate !== "") {
            dateTimeList = timeTravelDate.split(" ");
            sDate = dateTimeList[0];
            sDateSplit = sDate.split("-");
            if (dateTimeList[1] !== undefined) {
                const sTime = dateTimeList[1];
                const sTimeSplit = sTime.split(":");
                sHours = sTimeSplit[0] !== undefined ? sTimeSplit[0] : "";
                sMinutes = sTimeSplit[1] !== undefined ? sTimeSplit[1] : "";
                sSeconds = sTimeSplit[2] !== undefined ? sTimeSplit[2] : "";
            }
        }
        return new Date(
            sDateSplit[0],
            sDateSplit[1],
            sDateSplit[2],
            sHours,
            sMinutes,
            sSeconds
        );
    };

    /**
     * @function - setSomeoneOutsideCheckboxValue.
     * @description - Method use to set the last checkbox True/False of Someone outside Household.
     */
    setSomeoneOutsideCheckboxValue = () => {
        const IsHealthCareCoverageApproved = this.objEnrollmentDetailsData
            .bisHealthCareCoverageApproved;
        const disableEverything = this.objEnrollmentDetailsData
            .bisHealthCarePolicyHolderOutsideCase;
        const disableWhoIsEnrolledInPlanForAccessDetails =
            (IsHealthCareCoverageApproved && !this.isEnrolledInInsurance) ||
            disableEverything
                ? true
                : false;
        if (
            this.objEnrollmentDetailsData.lstOutsideCoveredInd !== undefined &&
            this.objEnrollmentDetailsData.lstOutsideCoveredInd.length > 0 &&
            this.hasKIHIPPProgram
        ) {
            this.showCoveredIndividualBlock = true;
            this.objEnrollmentDetailsData.lstOutsideCoveredInd.forEach(
                element => {
                    if (
                        !this.currentOutsideCoveredIndividualList.includes(
                            element.sCoveredIndId
                        )
                    ) {
                        this.currentOutsideCoveredIndividualList.push(
                            element.sCoveredIndId
                        );
                    }
                    if (
                        element.bIsDefault !== undefined &&
                        element.bIsDefault
                    ) {
                        this.showCoveredIndividualBlock = false;
                    }
                    if (
                        element.sCoveredIndId !== null &&
                        element.sCoveredIndId !== undefined &&
                        ((element.sCoveredIndFirstName !== null &&
                            element.sCoveredIndFirstName !== undefined) ||
                            (element.sCoveredIndLastName !== null &&
                                element.sCoveredIndLastName !== undefined)) &&
                        (IsHealthCareCoverageApproved || disableEverything)
                    ) {
                        element.disableField = true;
                    }
                }
            );
            if (this.showCoveredIndividualBlock) {
                this.lstWhoIsEnrolledInPlan.push({
                    label: outsideHOHLabel,
                    value: outsideHOHValue,
                    checked: true,
                    disable: disableWhoIsEnrolledInPlanForAccessDetails
                });
                this.lstOutsideCoveredInd = this.objEnrollmentDetailsData.lstOutsideCoveredInd;
            } else {
                this.lstWhoIsEnrolledInPlan.push({
                    label: outsideHOHLabel,
                    value: outsideHOHValue,
                    checked: false,
                    disable: disableWhoIsEnrolledInPlanForAccessDetails
                });
            }
            this.whoIsEnrollInPlanErrorMsg = "";
            if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.remove("ssp-checkbox-error");
            }
        } else if (this.hasKIHIPPProgram || this.isEnrolled === false) {
            // Added below loop to avoid duplicate Someone outside household member. used for loop because break cannot use in forEach.
            let isSomeoneOutsideExist = false;
            for (
                let index = 0;
                index < this.lstWhoIsEnrolledInPlan.length;
                index++
            ) {
                const element = this.lstWhoIsEnrolledInPlan[index];
                if (element.value === outsideHOHValue) {
                    isSomeoneOutsideExist = true;
                    break;
                }
            }
            if (!isSomeoneOutsideExist) {
                this.lstWhoIsEnrolledInPlan.push({
                    label: outsideHOHLabel,
                    value: outsideHOHValue,
                    checked: false,
                    disable: disableWhoIsEnrolledInPlanForAccessDetails
                });
            }
            this.showCoveredIndividualBlock = false;
        }
    };

    /**
     * @function - setScreenFieldValueData()
     * @description - This method use to set the screen level field Value data.
     * @param {object[]} componentElement - Contains all components available on screen.
     * @param {string} screenName - Contain the Screen Name.
     */
    setScreenFieldValueData = (componentElement, screenName) => {
        const updatedScreenFieldValue = {};
        const fieldValueList = {};
        try {
            for (let index = 0; index < componentElement.length; index++) {
                const element = componentElement[index];
                
                fieldValueList[element.entityName + "," + element.fieldName] =
                    element.value !== undefined ? element.value : "";
            }
            if (Object.keys(fieldValueList).length > 0) {
                updatedScreenFieldValue[screenName] = fieldValueList;
            }
            
        } catch (error) {
            console.error(
                "Error occurred in setScreenFieldValueData on health coverage page" +
                    JSON.stringify(error)
            );
        }
        return updatedScreenFieldValue;
    };

    /**
     * @function - sendScreenFieldValueData()
     * @description - Method is used for send the screen Field Value data.
     * @param {object{}} screenFieldData - Contains screen field value data.
     */
    sendScreenFieldValueData = screenFieldData => {
        try {
            const selectedEvent = new CustomEvent("screen", {
                detail: screenFieldData
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(
                "Error in sendScreenFieldValueData of Enrollment Details page" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
    * @function - updateEnrolledInPlanOptions()
    * @description - Method to update Enrolled in plan question options.
    * @param {policyHolderSelected} policyHolderSelected - Policy Holder Selected value.
    */
    updateEnrolledInPlanOptions = (policyHolderSelected) => {
        try {
            let newPolicyHolderSelected;
            this.lstWhoIsEnrolledInPlan.forEach(enrolledInPlan =>{
                if (enrolledInPlan.value === policyHolderSelected && policyHolderSelected !== "outside"){
                    enrolledInPlan.disable = true;
                    enrolledInPlan.checked = true;
                    newPolicyHolderSelected = policyHolderSelected;
                    if (this.whoIsEnrollInPlanErrorMsg){
                        this.whoIsEnrollInPlanErrorMsg="";
                        if (this.template.querySelector(".ssp-enrollmentDetailsCheckGroup")) {
                            this.template.querySelector(".ssp-enrollmentDetailsCheckGroup").classList.remove("ssp-checkbox-error");
                        }
                    }
                    if (!utility.isUndefinedOrNull(this.objEnrollmentDetailsData.lstCoveredInd)){
                        this.objEnrollmentDetailsData.lstCoveredInd = this.objEnrollmentDetailsData.lstCoveredInd.filter(function (coveredIndividual) {
                            return coveredIndividual.sMemberId !== enrolledInPlan.value;
                        });
                    }
                }

                if ((!utility.isUndefinedOrNull(this.oldPolicyAndCoveredIndividualValue)
                    && !utility.isEmpty(this.oldPolicyAndCoveredIndividualValue)
                    && this.oldPolicyAndCoveredIndividualValue != policyHolderSelected
                    && enrolledInPlan.value === this.oldPolicyAndCoveredIndividualValue) || (enrolledInPlan.value === this.oldPolicyAndCoveredIndividualValue && policyHolderSelected === "outside")) {
                    enrolledInPlan.disable = false;
                    enrolledInPlan.checked = this.selectedEnrollPlanList.indexOf(enrolledInPlan.value) > -1;
                }
            });
            this.oldPolicyAndCoveredIndividualValue = newPolicyHolderSelected !== "outside" ? newPolicyHolderSelected : null;
        } catch (error) {
            console.error(
                "Error in updateEnrolledInPlanOptions of Enrollment Details page" +
                JSON.stringify(error.message)
            );
        }
    };
    
    /**
    * @function - checkAtleastOneHouseholdMember()
    * @description - Method to check atleast one Household Member is selected from Policy Holder or Covered Individuals.
    */
    checkAtleastOneHouseholdMember = () => {
        try {
            let isInternalPolicyHolder = false;
            let isInternalCoveredIndividual = false;
            if (!this.showPolicyHolderBlock) {
                isInternalPolicyHolder = true;
            }
            if (this.selectedEnrollPlanList && this.selectedEnrollPlanList.length > 0) {
                isInternalCoveredIndividual = true;
            }
            // if Both Internal Policy Holder and Covered Individual not exists
            if (!isInternalPolicyHolder && !isInternalCoveredIndividual && this.whoIsEnrollInPlanErrorMsg === "") {
                this.isToShowAtleastOneMemberErrorMsg = true;
                // Add CSS validation
                if (
                    this.template.querySelector(
                        ".ssp-enrollmentDetailsCheckGroup"
                    )
                ) {
                    this.template
                        .querySelector(".ssp-enrollmentDetailsCheckGroup")
                        .classList.add("ssp-checkbox-error");
                }
            } else if(this.whoIsEnrollInPlanErrorMsg === "") {
                this.isToShowAtleastOneMemberErrorMsg = false;
                // Remove CSS validation
                if (
                    this.template.querySelector(
                        ".ssp-enrollmentDetailsCheckGroup"
                    )
                ) {
                    this.template
                        .querySelector(".ssp-enrollmentDetailsCheckGroup")
                        .classList.remove("ssp-checkbox-error");
                }
            }
        } catch (error) {
            console.error(
                "Error in checkAtleastOneHouseholdMember of Enrollment Details page" +
                    JSON.stringify(error.message)
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
                this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
                if(this.isReadOnlyUser){
                    for(let i=0; i<this.lstWhoIsEnrolledInPlan.length; i++){
                        this.lstWhoIsEnrolledInPlan[i].disable=true;
                    }
                }
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
