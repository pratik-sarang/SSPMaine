/*
 * Component Name: sspTaxFilingDetails
 * Author: Kyathi Kanumuri, Karthik Gulla
 * Description: This Screen is used for tax filing details.
 * Date: 02/21/2020.
 */
import { api, track, wire } from "lwc";
import SSPMEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import utility, { getYesNoOptions, formatLabels} from "c/sspUtility";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import apConstants from "c/sspConstants";
import taxFilerStatusField from "@salesforce/schema/SSP_Member__c.TaxFilerStatusCurrentYear__c";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import getCurrentApplicationHouseholdMembers from "@salesforce/apex/SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers";
import getTaxFilingDetails from "@salesforce/apex/SSP_TaxFilingDetailsController.getTaxFilingDetailsForMember";
import checkTMemberCall from "@salesforce/apex/SSP_TaxFilingDetailsController.checkToInvokeTMemberCall";
import updateTaxFilingDetails from "@salesforce/apex/SSP_TaxFilingDetailsController.updateTaxFilingDetails";
import sspMarkedClaimantWarning from "@salesforce/label/c.SSP_MarkedClaimantWarning";
import sspDependentTaxFilingValidator from "@salesforce/label/c.SSP_DependentTaxFilingValidator";
import sspClaimantTaxFilingValidator from "@salesforce/label/c.SSP_ClaimantTaxFilingValidator";
import sspTaxFilingSingleWarning from "@salesforce/label/c.SSP_TaxFilingSingleWarning";
import sspTaxFilingMarriedWarning from "@salesforce/label/c.SSP_TaxFilingMarriedWarning";
import sspTaxFilingParentSiblingWarning from "@salesforce/label/c.SSP_TaxFilingParentSiblingWarning";
import sspTaxFilingWarningModalHeading from "@salesforce/label/c.SSP_TaxFilingWarningModalHeading";
import sspTaxFilingWarningButton from "@salesforce/label/c.SSP_TaxFilingWarningButton";
import sspTaxFilingDetailsTaxThisYear from "@salesforce/label/c.SSP_TaxFilingDetailsTaxThisYear";
import sspTaxFilingDetailsDependentOf from "@salesforce/label/c.SSP_TaxFilingDetailsDependentOf";
import sspTaxFilingDetailsClaimingDependent from "@salesforce/label/c.SSP_TaxFilingDetailsClaimingDependent";
import sspTaxFilingDetailsWhichMemberAsDependent from "@salesforce/label/c.SSP_TaxFilingDetailsWhichMemberAsDependent";
import sspTaxFilingDetailsParentOrSibling from "@salesforce/label/c.SSP_TaxFilingDetailsParentOrSibling";
import sspTaxFilingDetailsSameNextYear from "@salesforce/label/c.SSP_TaxFilingDetailsSameNextYear";
import sspTaxFilingDetailsTaxFilingNextYear from "@salesforce/label/c.SSP_TaxFilingDetailsTaxFilingNextYear";
import sspTaxFilingDetailsClaimingDependentNextYear from "@salesforce/label/c.SSP_TaxFilingDetailsClaimingDependentNextYear";
import sspRequiredMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspWarningModalHeading from "@salesforce/label/c.SSP_TaxFilingWarningModalHeading";
import sspWillNotAskQuestionsForRestOfTheApplication from "@salesforce/label/c.sspWillNotAskQuestionsForRestOfTheApplication";
import sspTaxFilingStatusHelpTextCurrent from "@salesforce/label/c.SSP_TaxFilingStatusCurrentYear_HelpText";
import sspTaxFilingStatusHelpTextNext from "@salesforce/label/c.SSP_TaxFilingStatusNextYear_HelpText";
export default class SspTaxFilingDetails extends BaseNavFlowPage {
    @api applicationId;
    @api memberId;
    @api memberName;
    @api modeValue;
    @track reference = this;
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track dataFetchComplete = false;
    /**
    * @function : Getter method to check if basic data available to perform tax filing.
    * @description : Getter method to check if basic data available to perform tax filing.
    */
    get performTaxFilingDataInitiate () {
      try{
        if (!utility.isUndefinedOrNull(this.taxFilingStatusOptions) && !utility.isUndefinedOrNull(this.memberId) && !this.dataFetchComplete){
            return this.householdMemberDetails();
        } else {
            return this.dataFetchComplete;
        }
      } catch (error) {
        console.error("Error occurred in sspTaxFilingDetails.performTaxFilingDataInitiate" + JSON.stringify(error.message));
        return this.dataFetchComplete;
      }
    }

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        try {
            return this.memberIdValue;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getMemberId + JSON.stringify(error.message));
            return null;
        }
    }
    set memberId (value) {
        try {
            this.memberIdValue = value;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.setMemberId + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getAllowSaveData + JSON.stringify(error.message));
            return null;
        }
    }
    set allowSaveData (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.allowSaveValue = value;
                this.showSpinner = true;
                const taxFilingData = this.template.querySelectorAll(
                    ".ssp-taxFilingDetailInputs"
                );
                const taxFilingSelectedValues = {};
                taxFilingData.forEach(filingData => {
                    taxFilingSelectedValues[filingData.getAttribute("data-id")] = filingData.value;
                });
                taxFilingSelectedValues.memberId = this.memberId;
                taxFilingSelectedValues.applicationId = this.applicationId;

                this.hasClaimantWarningErrors = false;
                this.hasDependentsChangeErrors = false;

                if ((!utility.isUndefinedOrNull(taxFilingSelectedValues["TaxFilerStatusCurrentYear__c"])
                    && apConstants.taxFilingConstants.filingStatus.dependentInHousehold === taxFilingSelectedValues["TaxFilerStatusCurrentYear__c"])
                    || (!utility.isUndefinedOrNull(taxFilingSelectedValues["TaxFilerStatusNextYear__c"])
                        && apConstants.taxFilingConstants.filingStatus.dependentInHousehold === taxFilingSelectedValues["TaxFilerStatusNextYear__c"]
                    && (this.taxFilingDetails.isInOpenEnrollmentPeriod && this.taxFilingDetails.showNextYearTaxFilingDetailsSection))) {
                    this.checkMarkedClaimantWarning(taxFilingSelectedValues["TaxFilerStatusCurrentYear__c"], apConstants.taxFilingConstants.currentYearType);
                }
                
                if (!this.hasClaimantWarningErrors
                    && (!utility.isUndefinedOrNull(taxFilingSelectedValues["TaxFilerStatusCurrentYear__c"])
                        && apConstants.taxFilingConstants.cDependentsStatusList.indexOf(taxFilingSelectedValues["TaxFilerStatusCurrentYear__c"]) > -1)
                    || (!utility.isUndefinedOrNull(taxFilingSelectedValues["TaxFilerStatusNextYear__c"])
                        && apConstants.taxFilingConstants.cDependentsStatusList.indexOf(taxFilingSelectedValues["TaxFilerStatusNextYear__c"]) > -1
                    && (this.taxFilingDetails.isInOpenEnrollmentPeriod && this.taxFilingDetails.showNextYearTaxFilingDetailsSection))) {
                    this.handleTaxFilingDependentsChange(taxFilingSelectedValues);
                }
                if (!this.hasClaimantWarningErrors && !this.hasDependentsChangeErrors){
                    this.saveTaxFilingData();
                }
                this.showSpinner = false;
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.setAllowSaveData + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        try {
            return this.MetaDataListParent;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getMetadataList + JSON.stringify(error.message));
            return null;
        }
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.MetaDataListParent = value;
                this.hasMetadataListValues = true;

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                }
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.setMetadataList + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for next event.
     * @description : Getter setter methods for next event.
     */
    @api
    get nextEvent () {
        try {
            return this.nextValue;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getNextEvent + JSON.stringify(error.message));
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.getRequiredInputElements();
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.setNextEvent + JSON.stringify(error.message));
        }
    }

    label = {
        sspRequiredMessage,
        sspTaxFilingSingleWarning,
        sspTaxFilingMarriedWarning, 
        sspTaxFilingParentSiblingWarning,
        sspTaxFilingWarningModalHeading,
        sspTaxFilingWarningButton,
        toastErrorText,
        sspTaxFilingStatusHelpTextCurrent,
        sspTaxFilingStatusHelpTextNext
    };

    @track taxFilingDetailsTaxThisYearLabel;
    @track taxFilingDetailsDependentOfLabel;
    @track taxFilingDetailsClaimingDependentLabel;
    @track taxFilingDetailsWhichMemberAsDependentLabel;
    @track taxFilingDetailsParentOrSiblingLabel;
    @track taxFilingDetailsSameNextYearLabel;
    @track taxFilingDetailsTaxFilingNextYearLabel;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track individualRecordTypeId;
    @track taxFilingStatusOptions;
    @track taxFilingStatusOptionsCurrentYear;
    @track householdMembers = [];
    @track householdMembersCurrentYear = [];
    @track householdMembersNextYear = [];
    @track yesNoOptions = getYesNoOptions();
    @track hasMetadataListValues = false;
    @track showTCDCYRequiredError = false;
    @track showTCDNYRequiredError = false;
    @track showTaxFilingDetailsSameNextYearRequiredError = false;
    @track currentMemberRelationships = [];
    @track dependentTaxFilingValidatorCurrentErrorMessagesList = [];
    @track dependentTaxFilingValidatorNextErrorMessagesList = [];
    @track taxFilingMembersData = {};
    @track showClaimantDependentError = false;
    @track claimantDependentValidationMessage = "";
    @track hasSpouseInHousehold = false;
    @track openModel = false;
    @track warningModalHeading = this.label.sspTaxFilingWarningModalHeading;
    @track warningModalContent;
    @track warningModalButton = this.label.sspTaxFilingWarningButton;
    @track currentMemberTaxFilingData = {};
    @track taxFilingDetailsSameNextYear = "";
    @track showTMemberModal = false;
    @track tMemberPopupContent = "";
    @track hasClaimantWarningErrors = false;
    @track hasDependentsChangeErrors = false;
    @track statusWarningCount = {
        current : {
            FJ : 0,
            FS : 0,
            SI : 0,
            DN : 0,
            MCW: 0,
            MCWD: 0
        },
        next : {
            FJ : 0,
            FS : 0,
            SI : 0,
            DN : 0,
            MCW: 0,
            MCWD: 0
        }
    }
    @track taxFilingDetails = {
        claimingDependentStatusList: apConstants.taxFilingConstants.cDependentsStatusList,
        spouseTaxFilingStatusList: apConstants.taxFilingConstants.sTaxFilingStatusList,
        dependentTaxFilingStatusList: apConstants.taxFilingConstants.dStatusList,
        isInOpenEnrollmentPeriod: false,
        showNextYearTaxFilingDetailsSection: false,
        showDependentsSection: {
            currentYear: false,
            nextYear: false
        },
        showParentOrSiblingSection: {
            currentYear: false,
            nextYear: false
        },
        showClaimingDependentsSection: {
            currentYear: false,
            nextYear: false
        },
        showDependentsOfSection: {
            currentYear: false,
            nextYear: false
        }
    };
    @track isDependentTaxFiler = false;

    //2.5	Security Role Matrix and Program Access.
    get showContents () {
        return this.hasMetadataListValues && this.isScreenAccessible;
    }

    /**
     * @function : connectedCallback
     * @description : Rendered on load of tax filing details page.
     */
    connectedCallback () {
        try {
            this.taxFilingDetailsTaxThisYearLabel = formatLabels(
                sspTaxFilingDetailsTaxThisYear,
                [this.memberName]
            );
            this.taxFilingDetailsDependentOfLabel = formatLabels(
                sspTaxFilingDetailsDependentOf,
                [this.memberName]
            );
            this.taxFilingDetailsClaimingDependentLabel = formatLabels(
                sspTaxFilingDetailsClaimingDependent,
                [this.memberName]
            );
            this.taxFilingDetailsWhichMemberAsDependentLabel = formatLabels(
                sspTaxFilingDetailsWhichMemberAsDependent,
                [this.memberName]
            );
            this.taxFilingDetailsParentOrSiblingLabel = formatLabels(
                sspTaxFilingDetailsParentOrSibling,
                [this.memberName]
            );
            this.taxFilingDetailsSameNextYearLabel = formatLabels(
                sspTaxFilingDetailsSameNextYear,
                [this.memberName]
            );

            this.taxFilingDetailsClaimingDependentNextYearLabel = formatLabels(
                sspTaxFilingDetailsClaimingDependentNextYear,
                [this.memberName]
            );

            const taxFilingDetailsFieldEntityNameList = apConstants.taxFilingDetailsFieldEntityNameList;
            this.getMetadataDetails(
                taxFilingDetailsFieldEntityNameList,
                null,
                apConstants.taxFilingConstants.taxFilingPage
            );
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.connectedCallback, JSON.parse(JSON.stringify(error)));
            this.showSpinner = false;
        }
    }

    /**
     * @function : Wire property to get SSP_Member object Info
     * @description : Wire property to get SSP_Member object Info.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getObjectInfo, { objectApiName: SSPMEMBER_OBJECT })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                this.hasSaveValidationError = false;
                const recordTypeInformation = data[apConstants.resourceDetailConstants.resourceRecordTypes];
                this.individualRecordTypeId = Object.keys(recordTypeInformation
                ).find(recTypeInfo => recordTypeInformation[recTypeInfo].name === apConstants.taxFilingConstants.individualRecordTypeName);
            } else if (error) {
                console.error(apConstants.taxFilingConstants.taxFilingError.getObjectInfoWiredMethod + JSON.stringify(error.message));
                this.hasSaveValidationError = true;
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getObjectInfoWiredMethod + JSON.stringify(error.message));
            this.hasSaveValidationError = true;
            this.showSpinner = false;
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
            console.error(apConstants.taxFilingConstants.taxFilingError.hideToast + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Wire property to get picklist values
     * @description : Wire property to get picklist values.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: taxFilerStatusField
    })
    picklistTypeOptions ({ error, data }) {
        try {
            if (data) {
                this.taxFilingStatusOptions = data.values;
            } else if (error) {
                console.error(apConstants.taxFilingConstants.taxFilingError.getPicklistValues + JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getPicklistValues + JSON.stringify(error.message));
        }
    }

    /**
     * @function : method to get Current Application household members
     * @description : method to get Current Application household members.
     */
     householdMemberDetails = async () => {
        try {
            await getCurrentApplicationHouseholdMembers({
                sApplicationId: this.applicationId,
                sMemberId: this.memberId,
                sMembersType: apConstants.resourceDetailConstants.others
            })
            .then(data => {
                const hMembers = JSON.parse(data.mapResponse.householdMembers);
                const hMembersArray = new Array();
                hMembers.forEach(hMember => {
                    hMembersArray.push({
                        label: hMember[apConstants.resourceDetailConstants.resourceHouseholdName],
                        value: hMember[apConstants.resourceDetailConstants.resourceMemberId]
                    });
                });
                this.householdMembers = hMembersArray;
                this.householdMembersCurrentYear = hMembersArray;
                this.householdMembersNextYear = hMembersArray;
                return this.getTaxFilingDetails();
            })
            .catch(error => {
                console.error(apConstants.taxFilingConstants.taxFilingError.getCurrentApplicationHouseholdMembers +JSON.stringify(error.message));
            });
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getCurrentApplicationHouseholdMembers +JSON.stringify(error.message));
        }
    }

    /*
     * @function : getTaxFilingDetails
     * @description : This method used to get existing resources.
     */
    getTaxFilingDetails = async () => {
        try {
            const mapResInputs = {};
            mapResInputs.memberId = this.memberId;
            mapResInputs.applicationId = this.applicationId;

            /* @mapResInputs {map} value The input value with member Id details.
             * @returns { String JSON } Returns a string JSON with existing resource details.
             */
            await getTaxFilingDetails({
                mapInputs: mapResInputs
            })
                .then(result => {
                    this.showSpinner = true;
                    const taxFilingInformation = JSON.parse(
                        result.mapResponse.taxFilingDetails
                    );
                    this.taxFilingDetailsTaxFilingNextYearLabel = formatLabels(
                        sspTaxFilingDetailsTaxFilingNextYear,
                        [
                            this.memberName,
                            taxFilingInformation.CurrentEnrollmentYear
                        ]
                    );
                    this.taxFilingDetails.isInOpenEnrollmentPeriod =
                        taxFilingInformation.IsInOpenEnrollment;
                    this.currentMemberRelationships = JSON.parse(result.mapResponse.relationships);
                    this.taxFilingMembersData = JSON.parse(result.mapResponse.taxFilingMembers);
                    let currentMemberSpouseId;
                    this.currentMemberRelationships.forEach(memberRelationship => {
                        if (memberRelationship[apConstants.taxFilingConstants.sRelationshipType] === apConstants.taxFilingConstants.spouseRelationship){
                            this.hasSpouseInHousehold = true;
                            currentMemberSpouseId = memberRelationship[apConstants.taxFilingConstants.sRelatedMemberId];
                        }
                    });

                    if (!utility.isUndefinedOrNull(this.taxFilingMembersData)) {
                        this.householdClaimingMembersCurrentYear = this.householdMembersCurrentYear
                            .filter(hMember => this.taxFilingMembersData[hMember.value])
                            .filter(hMember => (
                                ((apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0
                                    && ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1
                                        && (currentMemberSpouseId !== hMember.value || utility.isUndefinedOrNull(currentMemberSpouseId))))
                                || (this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                                    && this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === this.memberId)
                                || ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1
                                    && this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === currentMemberSpouseId
                                    && currentMemberSpouseId !== hMember.value)
                                || (utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                                    && currentMemberSpouseId !== hMember.value)
                                || (!utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                                && currentMemberSpouseId !== hMember.value
                                && (apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0
                                && (apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0)
                            )
                            );

                        this.householdClaimantMembersCurrentYear = this.householdMembersCurrentYear
                            .filter(hMember => this.taxFilingMembersData[hMember.value])
                            .filter(hMember => (
                                ((apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0
                                    && ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1
                                        && (currentMemberSpouseId !== hMember.value || utility.isUndefinedOrNull(currentMemberSpouseId))))
                                || (this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                                    && this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === hMember.value)
                                || (utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                                    && currentMemberSpouseId !== hMember.value)
                                || (!utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) 
                                    && currentMemberSpouseId !== hMember.value
                                    && (apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0
                                    && (apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) < 0)
                            )
                            );

                        this.householdClaimingMembersNextYear = this.householdMembersNextYear
                            .filter(hMember => this.taxFilingMembersData[hMember.value])
                            .filter(hMember => (
                                ((apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0
                                    && ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) > -1
                                        && (currentMemberSpouseId !== hMember.value || utility.isUndefinedOrNull(currentMemberSpouseId))))
                                || (this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                                    && this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === this.memberId)
                                || ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) > -1
                                    && this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === currentMemberSpouseId
                                    && currentMemberSpouseId !== hMember.value)
                                || (utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                                    && currentMemberSpouseId !== hMember.value)
                                || (!utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                                && currentMemberSpouseId !== hMember.value
                                && (apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0
                                && (apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0)
                            )
                            );

                        this.householdClaimantMembersNextYear = this.householdMembersNextYear
                            .filter(hMember => this.taxFilingMembersData[hMember.value])
                            .filter(hMember => (
                                ((apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0
                                    && ((apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) > -1
                                        && (currentMemberSpouseId !== hMember.value || utility.isUndefinedOrNull(currentMemberSpouseId))))
                                || (this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilingStatusNextYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                                    && this.taxFilingMembersData[this.memberId][apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === hMember.value)
                                || (utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                                    && currentMemberSpouseId !== hMember.value)
                                || (!utility.isUndefinedOrNull(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                                    && currentMemberSpouseId !== hMember.value
                                    && (apConstants.taxFilingConstants.dStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0
                                    && (apConstants.taxFilingConstants.mStatusList).indexOf(this.taxFilingMembersData[hMember.value][apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) < 0)
                            )
                            );
                    }

                    const currentHouseholdTaxClaimedData = Object.values(this.taxFilingMembersData);
                    const taxFilerCurrentMembersArray = [];
                    const taxFilerNextMembersArray = [];
                    currentHouseholdTaxClaimedData.forEach(currentTaxFilingData=> {
                        const taxFilerMemberCurrentYear = currentTaxFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear];
                        const taxFilerMemberNextYear = currentTaxFilingData[apConstants.taxFilingConstants.sTaxFilerMemberNextYear];
                        const householdMemberId = this.memberId;

                        if (!utility.isUndefinedOrNull(taxFilerMemberCurrentYear)
                            && householdMemberId === taxFilerMemberCurrentYear) {
                            taxFilerCurrentMembersArray.push(currentTaxFilingData[apConstants.taxFilingConstants.sMemberId]);
                        } 
                        if (!utility.isUndefinedOrNull(taxFilerMemberNextYear)
                            && householdMemberId === taxFilerMemberNextYear) {
                            taxFilerNextMembersArray.push(currentTaxFilingData[apConstants.taxFilingConstants.sMemberId]);
                        }
                    });

                    const cHouseholdTaxClaimedData = currentHouseholdTaxClaimedData.filter(
                        tFilingData => tFilingData[apConstants.taxFilingConstants.sMemberId] == this.memberId
                    );

                    this.currentMemberTaxFilingData = cHouseholdTaxClaimedData[0];  
                    this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersCurrent] = taxFilerCurrentMembersArray;
                    this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersNext] = taxFilerNextMembersArray;
                    this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilingDetailsClaimingDependentCurrentYear] = (!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersCurrent]) && !utility.isArrayEmpty(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersCurrent])) ? apConstants.toggleFieldValue.yes : ((!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) ? apConstants.toggleFieldValue.no : this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingClaimingCurrent]));
                    this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilingDetailsClaimingDependentNextYear] = (!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersNext]) && !utility.isArrayEmpty(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilerMembersNext])) ? apConstants.toggleFieldValue.yes : ((!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) ? apConstants.toggleFieldValue.no : this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingClaimingNext]));
                    if (!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                        && this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold){
                        this.isDependentTaxFiler = true;
                    }
                    if (!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                        && !utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                        && this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) {
                        this.taxFilingDetailsSameNextYear = apConstants.toggleFieldValue.yes;
                    } else if (this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] !== null
                        && this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear] !== null
                        && this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] !== this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) {
                        this.taxFilingDetailsSameNextYear = apConstants.toggleFieldValue.no;
                    } else {
                        this.taxFilingDetailsSameNextYear = "";
                    }
                    this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilingDetailsSameNextYear] = this.taxFilingDetailsSameNextYear;
                    this.handleTaxFilingNextYearChange(null);
                    if(!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                        && (apConstants.taxFilingConstants.mStatusList.indexOf(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1)
                        || this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.single){
                        this.statusWarningCount[apConstants.taxFilingConstants.currentYearType][this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]] = 1;
                    }

                    if (!utility.isUndefinedOrNull(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                        && (apConstants.taxFilingConstants.mStatusList.indexOf(this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) > -1)
                        || this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear] === apConstants.taxFilingConstants.filingStatus.single) {
                        this.statusWarningCount[apConstants.taxFilingConstants.nextYearType][this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]] = 1;
                    }
                    
                    this.handleTaxFilingStatusChange(null, apConstants.taxFilingConstants.currentYearType);
                    this.handleTaxFilingStatusChange(null, apConstants.taxFilingConstants.nextYearType);
                    this.handleTaxFilingClaimingDependentChange(null, apConstants.taxFilingConstants.currentYearType);
                    this.handleTaxFilingClaimingDependentChange(null, apConstants.taxFilingConstants.nextYearType);
                    
                    if(this.hasSpouseInHousehold){
                        this.taxFilingStatusOptionsCurrentYear = this.taxFilingStatusOptions.filter(
                            taxFilingStatus => this.taxFilingDetails.spouseTaxFilingStatusList.indexOf(taxFilingStatus.value) > -1
                        );
                    } else {
                        this.taxFilingStatusOptionsCurrentYear = this.taxFilingStatusOptions;
                    }
                    if (!this.hasSpouseInHousehold && this.householdClaimantMembersCurrentYear.length === 0) {
                        this.taxFilingStatusOptionsCurrentYear = this.taxFilingStatusOptions.filter(
                            taxFilingStatus => taxFilingStatus.value !== apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                        );
                    }
                    if (!this.hasSpouseInHousehold && this.householdClaimantMembersNextYear.length === 0) {
                        this.taxFilingStatusOptionsNextYear = this.taxFilingStatusOptions.filter(
                            taxFilingStatus => taxFilingStatus.value !== apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                        );
                    }

                    this.showSpinner = false;
                    this.dataFetchComplete = true;
                    return true;
                })
                .catch(error => {
                    console.error(apConstants.taxFilingConstants.taxFilingError.getTaxFilingDetails + JSON.stringify(error.message));
                    this.showSpinner = false;
                    this.dataFetchComplete = true;
                    return true;
                });
        } catch (error) {
            console.error(apConstants.removeExistResourceConstants.resourceRemovalError.getTaxFilingDetails + JSON.stringify(error.message));
            this.showSpinner = false;
            this.dataFetchComplete = true;
            return true;
        }
    }

    /**
     * @function : handleTaxFilingNextYearChange
     * @description : Functionality to handle when tax filing question is changed.
     * @param {event} event - Event Details.
     */
    handleTaxFilingNextYearChange = event => {
        try {
            let taxFilingSameNextYear;
            if (!utility.isUndefinedOrNull(event)) {
                taxFilingSameNextYear = event.detail.value;
            } else {
                taxFilingSameNextYear = this.currentMemberTaxFilingData.taxFilingDetailsSameNextYear;
            }
            
            if (taxFilingSameNextYear === apConstants.toggleFieldValue.no) {
                this.taxFilingDetails.showNextYearTaxFilingDetailsSection = true;
                this.taxFilingDetails.showDependentsOfSection.nextYear = false;
                this.taxFilingDetails.showParentOrSiblingSection.nextYear = false;
                this.taxFilingDetails.showClaimingDependentsSection.nextYear = false;
            } else if (
                taxFilingSameNextYear === apConstants.toggleFieldValue.yes
            ) {
                this.taxFilingDetails.showNextYearTaxFilingDetailsSection = false;
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleTaxFilingNextYearChange + JSON.stringify(error.message));
        }
    };

    /**
    * @function : handleParentOrSiblingChange
    * @description : Functionality to handle when parent or sibling question is changed.
    * @param {event} event - Event Details.
    */
    handleParentOrSiblingChange = (event) => {
        try {
            const yearType = event.target.dataset.year;
            if (event.detail.value === apConstants.toggleFieldValue.yes
                && this.taxFilingMembersData[this.memberId].iMemberAge > 19
                && this.statusWarningCount[yearType][apConstants.taxFilingConstants.filingStatus.dependentOutHousehold] === 0
            ) {
                this.openModel = true;
                this.warningModalContent = this.label.sspTaxFilingParentSiblingWarning;
                this.statusWarningCount[yearType][apConstants.taxFilingConstants.filingStatus.dependentOutHousehold] = 1;
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleParentOrSiblingChange + JSON.stringify(error.message));
        }
    }

    /**
     * @function : handleTaxFilingClaimingDependentChange
     * @description : Functionality to tax filing claiming dependent is changed.
     * @param {event} event - Event Details.
     * @param {year} year - Current year or next year.
     */
    handleTaxFilingClaimingDependentChange = (event,year) => {
        try {
            let claimingDependentsCurrentYear;
            let claimingDependentsNextYear;
            let yearType;
            if (!utility.isUndefinedOrNull(event)) {
                yearType = event.target.dataset.year;
                claimingDependentsCurrentYear = event.detail.value;
                claimingDependentsNextYear = event.detail.value;
            } else {
                yearType = year;
                claimingDependentsCurrentYear = this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilingDetailsClaimingDependentCurrentYear];
                claimingDependentsNextYear = this.currentMemberTaxFilingData[apConstants.taxFilingConstants.taxFilingDetailsClaimingDependentNextYear];
            }
            
            if (yearType === apConstants.taxFilingConstants.currentYearType) {
                if (claimingDependentsCurrentYear === apConstants.toggleFieldValue.yes){
                    this.taxFilingDetails.showDependentsSection.currentYear = true;
                } else if (claimingDependentsCurrentYear === apConstants.toggleFieldValue.no) {
                    this.taxFilingDetails.showDependentsSection.currentYear = false;
                    this.dependentTaxFilingValidatorCurrentErrorMessagesList = [];
                }
            } else if (yearType === apConstants.taxFilingConstants.nextYearType) {
                if (claimingDependentsNextYear === apConstants.toggleFieldValue.yes) {
                    this.taxFilingDetails.showDependentsSection.nextYear = true;
                } else if (claimingDependentsNextYear === apConstants.toggleFieldValue.no) {
                    this.taxFilingDetails.showDependentsSection.nextYear = false;
                    this.dependentTaxFilingValidatorNextErrorMessagesList = [];
                }
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleTaxFilingClaimingDependentChange + JSON.stringify(error.message));
        }
    };

    /**
     * @function : handleDependentOfChange
     * @description : Functionality to tax filing claiming dependent is changed.
     * @param {event} event - Event Details.
     */
    handleDependentOfChange = event => {
        try {
            const memberSelected = event.detail.value;
            const taxFilingDetailsData = this.taxFilingMembersData;

            Object.keys(taxFilingDetailsData).forEach( (key) => {
                if(String(key) === String(memberSelected)){
                    const currentFilingData = taxFilingDetailsData[memberSelected];
                    if (this.taxFilingDetails.dependentTaxFilingStatusList.indexOf(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1){
                        const memberLabel = formatLabels(
                            sspClaimantTaxFilingValidator,
                            [currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYearName]]
                        );
                        this.showClaimantDependentError = true; 
                        this.claimantDependentValidationMessage = memberLabel;
                    }
                } 
            });
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleDependentOfChange + JSON.stringify(error.message));
        }
    };

    /**
     * @function : handleDependentsChange
     * @description : Functionality to tax filing claiming dependent is changed.
     * @param {event} event - Event Details.
     */
    handleDependentsChange = event => {
        try {
            const memberSelected = event.detail.value;
            const taxFilingDetailsData = this.taxFilingMembersData;

            Object.keys(taxFilingDetailsData).forEach((key) => {
                if (String(key) === String(memberSelected)) {
                    const currentFilingData = taxFilingDetailsData[memberSelected];
                    if (this.taxFilingDetails.dependentTaxFilingStatusList.indexOf(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1) {
                        const memberLabel = formatLabels(
                            sspClaimantTaxFilingValidator,
                            [currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYearName]]
                        );
                        this.showClaimantDependentError = true;
                        this.claimantDependentValidationMessage = memberLabel;
                    }
                }
            });
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleDependentsChange + JSON.stringify(error.message));
        }
    };

    /**
     * @function : handleTaxFilingDependentsChange
     * @description : Functionality to tax filing claiming dependent is changed.
     * @param {tSelectedValues} tSelectedValues - Tax Filing selected Details.
     */
    handleTaxFilingDependentsChange = (tSelectedValues) => {
        try {
            this.hasDependentsChangeErrors = false;
            const memberSelectedCurrentArray = !utility.isUndefinedOrNull(tSelectedValues.TaxFilerMemberCurrent__c) ? tSelectedValues.TaxFilerMemberCurrent__c : [];
            const memberSelectedNextArray = !utility.isUndefinedOrNull(tSelectedValues.TaxFilerMemberNext__c) ? tSelectedValues.TaxFilerMemberNext__c : [];
            const taxFilingDetailsData = this.taxFilingMembersData;
            this.dependentTaxFilingValidatorCurrentErrorMessagesList =[];
            let hasDTFErrorCurrent = false;
            memberSelectedCurrentArray.forEach(memberSelected => {
                const currentFilingData = taxFilingDetailsData[memberSelected];
                if (!hasDTFErrorCurrent 
                    && !utility.isUndefinedOrNull(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear])
                    && apConstants.taxFilingConstants.cDependentsStatusList.indexOf(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear]) > -1) {
                    const memberLabel = formatLabels(
                        sspDependentTaxFilingValidator,
                        [currentFilingData[apConstants.taxFilingConstants.sMemberName]]
                    );
                    this.dependentTaxFilingValidatorCurrentErrorMessagesList.push(memberLabel);
                    hasDTFErrorCurrent = true;
                } 
            });

            this.dependentTaxFilingValidatorNextErrorMessagesList = [];
            let hasDTFErrorNext = false;
            memberSelectedNextArray.forEach(memberSelected => {
                const currentFilingData = taxFilingDetailsData[memberSelected];
                if (!hasDTFErrorNext
                    && !utility.isUndefinedOrNull(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear])
                    && apConstants.taxFilingConstants.cDependentsStatusList.indexOf(currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear]) > -1) {
                    const memberLabel = formatLabels(
                        sspDependentTaxFilingValidator,
                        [currentFilingData[apConstants.taxFilingConstants.sMemberName]]
                    );
                    this.dependentTaxFilingValidatorNextErrorMessagesList.push(memberLabel);
                    hasDTFErrorNext = true;
                } 
            });

            if (this.dependentTaxFilingValidatorCurrentErrorMessagesList.length > 0 
                || this.dependentTaxFilingValidatorNextErrorMessagesList > 0){
                this.hasDependentsChangeErrors = true;
            }

            const mCurrentArray = [];
            this.householdClaimingMembersCurrentYear.forEach(hMember =>{
                if (memberSelectedCurrentArray.length> 0 && memberSelectedCurrentArray.indexOf(hMember.value) < 0){
                    mCurrentArray.push(hMember.value);
                }
            });

            this.householdClaimantMembersCurrentYear.forEach(hMember => {
                if (memberSelectedCurrentArray.length > 0 && memberSelectedCurrentArray.indexOf(hMember.value) < 0) {
                    mCurrentArray.push(hMember.value);
                }
            });

            const mNextArray = [];
            this.householdClaimingMembersNextYear.forEach(hMember => {
                if (memberSelectedNextArray.length> 0 && memberSelectedNextArray.indexOf(hMember.value) < 0) {
                    mNextArray.push(hMember.value);
                }
            });

            this.householdClaimantMembersNextYear.forEach(hMember => {
                if (memberSelectedNextArray.length > 0 && memberSelectedNextArray.indexOf(hMember.value) < 0) {
                    mNextArray.push(hMember.value);
                }
            });
            let markedClaimantCurrent = false;
            
            mCurrentArray.forEach(mCurrentMember => {
                const currentFilingData = taxFilingDetailsData[mCurrentMember];
                if (!markedClaimantCurrent
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === this.memberId
                    && this.statusWarningCount[apConstants.taxFilingConstants.currentYearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarningDependent] === 0){
                    this.openModel = true;
                    this.warningModalContent = formatLabels(
                        sspMarkedClaimantWarning,
                        [currentFilingData[apConstants.taxFilingConstants.sMemberName]]);
                    markedClaimantCurrent = true;
                    this.hasDependentsChangeErrors = true;
                    this.statusWarningCount[apConstants.taxFilingConstants.currentYearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarningDependent] = 1;
                }
            });

            let markedClaimantNext = false;
            mNextArray.forEach(mNextMember => {
                const currentFilingData = taxFilingDetailsData[mNextMember];
                if (!markedClaimantNext
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === this.memberId
                    && this.statusWarningCount[apConstants.taxFilingConstants.nextYearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarningDependent] === 0) {
                    this.openModel = true;
                    this.warningModalContent = formatLabels(
                        sspMarkedClaimantWarning,
                        [currentFilingData[apConstants.taxFilingConstants.sMemberName]]);
                    markedClaimantNext = true;
                    this.hasDependentsChangeErrors = true;
                    this.statusWarningCount[apConstants.taxFilingConstants.nextYearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarningDependent] = 1;
                }
            });

            //Review Required Logic
            const [currentYearReviewRequired] = mCurrentArray
                .map(member => taxFilingDetailsData[member])
                .filter(currentFilingData => 
                    currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === this.memberId);
            const [nextYearReviewRequired] = mCurrentArray
                .map(member => taxFilingDetailsData[member])
                .filter(currentFilingData => 
                    currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === this.memberId);
            const membersToBeReviewed = [];
            if(currentYearReviewRequired) {
                membersToBeReviewed.push(currentYearReviewRequired.strMemberId);
            }
            if(nextYearReviewRequired) {
                membersToBeReviewed.push(nextYearReviewRequired.strMemberId);
            }
            if(taxFilingDetailsData) {
                const existingDependents = Object.values(taxFilingDetailsData)
                    .filter(currentFilingData => currentFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear] === apConstants.taxFilingConstants.filingStatus.dependentInHousehold
                    && currentFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === this.memberId)
                    .map(data => data.strMemberId);
                membersToBeReviewed.push(...existingDependents.filter(member => !memberSelectedCurrentArray.includes(member)));
            }
            
            if(membersToBeReviewed.length > 0) {
                this.reviewRequiredList = [
                    [
                        "Dependant_Of_Change",
                        true,
                        ...Array.from(new Set(membersToBeReviewed))
                    ].join(",")
                ];
            }
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.handleTaxFilingDependentsChange + JSON.stringify(error.message));
        }
    };

    /**
     * @function : handleTaxFilingStatusChange
     * @description : Functionality to check when tax filing status is changed.
     * @param {event} event - Event Details.
     * @param {year} year - Current or next year ?
     */
    handleTaxFilingStatusChange = (event, year) => {
        try {
            let taxFilingStatusCurrentYear;
            let taxFilingStatusNextYear;
            let yearType;
            if(!utility.isUndefinedOrNull(event)){
                taxFilingStatusCurrentYear = event.detail.value;
                taxFilingStatusNextYear = event.detail.value;
                yearType = event.target.dataset.year;
            } else {
                taxFilingStatusCurrentYear = this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusCurrentYear];
                yearType = year;
                taxFilingStatusNextYear = this.currentMemberTaxFilingData[apConstants.taxFilingConstants.sTaxFilingStatusNextYear];
            }

            if (yearType === apConstants.taxFilingConstants.currentYearType){
                if (taxFilingStatusCurrentYear === apConstants.taxFilingConstants.filingStatus.dependentInHousehold){
                    this.taxFilingDetails.showDependentsOfSection.currentYear = (this.householdClaimantMembersCurrentYear.length > 0)? true : false;
                    this.taxFilingDetails.showClaimingDependentsSection.currentYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.currentYear = false;
                } else if (taxFilingStatusCurrentYear === apConstants.taxFilingConstants.filingStatus.dependentOutHousehold){
                    this.taxFilingDetails.showDependentsOfSection.currentYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.currentYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.currentYear = true;
                } else if (this.taxFilingDetails.claimingDependentStatusList.indexOf(taxFilingStatusCurrentYear) > -1) {
                    this.taxFilingDetails.showDependentsOfSection.currentYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.currentYear = (this.householdClaimingMembersCurrentYear.length > 0) ? true : false;
                    this.taxFilingDetails.showParentOrSiblingSection.currentYear = false;
                } else {
                    this.taxFilingDetails.showDependentsOfSection.currentYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.currentYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.currentYear = false;
                    this.taxFilingDetails.showDependentsSection.currentYear = false;
                }
                this.showTaxFilingWarnings(taxFilingStatusCurrentYear, apConstants.taxFilingConstants.currentYearType);
            } else if (yearType === apConstants.taxFilingConstants.nextYearType){
                if (taxFilingStatusNextYear === apConstants.taxFilingConstants.filingStatus.dependentOutHousehold) {
                    this.taxFilingDetails.showDependentsOfSection.nextYear = (this.householdClaimingMembersNextYear.length > 0) ? true : false;
                    this.taxFilingDetails.showClaimingDependentsSection.nextYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.nextYear = false;
                } else if (taxFilingStatusNextYear === apConstants.taxFilingConstants.filingStatus.dependentOutHousehold) {
                    this.taxFilingDetails.showDependentsOfSection.nextYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.nextYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.nextYear = true;
                } else if (this.taxFilingDetails.claimingDependentStatusList.indexOf(taxFilingStatusNextYear) > -1) {
                    this.taxFilingDetails.showDependentsOfSection.nextYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.nextYear = (this.householdClaimantMembersNextYear.length > 0) ? true : false;
                    this.taxFilingDetails.showParentOrSiblingSection.nextYear = false;
                } else {
                    this.taxFilingDetails.showDependentsOfSection.nextYear = false;
                    this.taxFilingDetails.showClaimingDependentsSection.nextYear = false;
                    this.taxFilingDetails.showParentOrSiblingSection.nextYear = false;
                    this.taxFilingDetails.showDependentsSection.nextYear = false;
                }
                this.showTaxFilingWarnings(taxFilingStatusNextYear, apConstants.taxFilingConstants.nextYearType);
            }
        } catch (error) {
            console.error(
                apConstants.taxFilingConstants.taxFilingError
                    .handleTaxFilingStatusChange + JSON.stringify(error.message)
            );
        }
    };

    /**
    * @function : showTaxFilingWarnings
    * @description : Functionality to show tax filing warnings in a pop up.
    * @param {taxFilingStatus} taxFilingStatus - Status of tax filing.
    * @param {yearType} yearType - Year Type.
    */
    showTaxFilingWarnings = (taxFilingStatus, yearType) => {
        try{
            this.warningModalHeading = sspWarningModalHeading;
            if (apConstants.taxFilingConstants.mStatusList.indexOf(taxFilingStatus) > -1 
                && !this.hasSpouseInHousehold
                && this.statusWarningCount[yearType][taxFilingStatus] === 0){
                this.openModel = true;
                this.warningModalContent = this.label.sspTaxFilingMarriedWarning;
            } else if (taxFilingStatus === apConstants.taxFilingConstants.filingStatus.single
                && this.statusWarningCount[yearType][taxFilingStatus] === 0) {
                this.openModel = true;
                this.warningModalContent = this.label.sspTaxFilingSingleWarning;
            }

            if (!utility.isUndefinedOrNull(taxFilingStatus)
                && yearType === apConstants.taxFilingConstants.currentYearType
                && (apConstants.taxFilingConstants.mStatusList.indexOf(taxFilingStatus) > -1)
                || taxFilingStatus === apConstants.taxFilingConstants.filingStatus.single) {
                this.statusWarningCount[apConstants.taxFilingConstants.currentYearType][taxFilingStatus] = 1;
            }

            if (!utility.isUndefinedOrNull(taxFilingStatus)
                && yearType === apConstants.taxFilingConstants.nextYearType
                && (apConstants.taxFilingConstants.mStatusList.indexOf(taxFilingStatus) > -1)
                || taxFilingStatus === apConstants.taxFilingConstants.filingStatus.single) {
                this.statusWarningCount[apConstants.taxFilingConstants.nextYearType][taxFilingStatus] = 1;
            }

            this.checkMarkedClaimantWarning(taxFilingStatus, yearType);
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.showTaxFilingWarnings + JSON.stringify(error.message));
        }
    }

    /**
    * @function : checkMarkedClaimantWarning
    * @description : Functionality to check marked claimant warning.
    * @param {taxFilingStatus} taxFilingStatus - Status of tax filing.
    * @param {yearType} yearType - Year Type.
    */
    checkMarkedClaimantWarning = (taxFilingStatus, yearType) => {
        try{
            this.hasClaimantWarningErrors = false;
            const validDependentStatusList = apConstants.taxFilingConstants.cDependentsStatusList;

            const currentHouseholdTaxClaimedData = Object.values(this.taxFilingMembersData);
            let cHouseholdTaxClaimedData = [];
            if(yearType === apConstants.taxFilingConstants.currentYearType){
                cHouseholdTaxClaimedData = currentHouseholdTaxClaimedData.filter(
                    tFilingData => tFilingData[apConstants.taxFilingConstants.sTaxFilerMemberCurrentYear] === this.memberId
                );
            } else if(yearType === apConstants.taxFilingConstants.nextYearType){
                cHouseholdTaxClaimedData = currentHouseholdTaxClaimedData.filter(
                    tFilingData => tFilingData[apConstants.taxFilingConstants.sTaxFilerMemberNextYear] === this.memberId
                );
            }

            if (!utility.isUndefinedOrNull(taxFilingStatus)
                && !utility.isEmpty(taxFilingStatus)
                && !utility.isUndefinedOrNull(cHouseholdTaxClaimedData)
                && !utility.isArrayEmpty(cHouseholdTaxClaimedData)
                && validDependentStatusList.indexOf(taxFilingStatus) < 0
                && this.statusWarningCount[yearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarning] === 0) {
                let otherIndividualNames = "";
                cHouseholdTaxClaimedData.forEach(cHouseholdTCData => {
                    otherIndividualNames = otherIndividualNames + cHouseholdTCData[apConstants.taxFilingConstants.sMemberName] + ",";
                });
                otherIndividualNames = otherIndividualNames.substring(0, otherIndividualNames.length - 1);
                this.openModel = true;
                this.warningModalContent = formatLabels(
                    sspMarkedClaimantWarning,
                    [otherIndividualNames]);
                this.hasClaimantWarningErrors = true;
                this.statusWarningCount[yearType][apConstants.taxFilingConstants.filingStatus.markedClaimantWarning] = 1;
            }
        } catch(error){
            console.error(apConstants.taxFilingConstants.taxFilingError.checkMarkedClaimantWarning + JSON.stringify(error.message));
        }
    }

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            const taxFilingDetailItems = this.template.querySelectorAll(
                ".ssp-taxFilingDetailInputs"
            );

            this.templateInputsValue = taxFilingDetailItems;
            this.calculateReviewRequiredRules(taxFilingDetailItems);
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.getRequiredInputElements + JSON.stringify(error.message));
        }
    }

    /*
     * @function : calculateReviewRequiredRules
     * @description : This method is used to calculate review required rules for tax filing.
     * @param {tFilingDetails} tFilingDetails - tax filing details.
     */                             
    calculateReviewRequiredRules = (tFilingDetails) => {
        try{
            this.showSpinner = true;
            const revRules = [];
            const listMemberId = this.currentMemberTaxFilingData.taxFilerMembersCurrent;
            let reviewRequiredMembers = [];
            let addRuleNoDependent = false;
            tFilingDetails.forEach(key => {
                if(!utility.isUndefinedOrNull(key.fieldName)
                    && (key.fieldName === apConstants.taxFilingConstants.taxFilerMemberCurrent || key.fieldName === apConstants.taxFilingConstants.taxFilerMemberNext)
                    && !utility.isUndefinedOrNull(key.oldValue)
                    && !utility.isEmpty(key.oldValue)
                    && key.oldValue != key.value
                    && (key.oldValue.length > 0 && key.value.length > 0)){
                    //split and compare values and add to review required rules
                    const oldValuesArray = String(key.oldValue).split(",");
                    const newValuesArray = String(key.value).split(",");
                    if (!utility.isArrayEmpty(oldValuesArray) && oldValuesArray.length > 0){
                        reviewRequiredMembers = oldValuesArray.filter(
                            oldValue => newValuesArray.indexOf(oldValue) < 0
                        );
                    }
                }

                if(!utility.isUndefinedOrNull(key.fieldName)
                && key.fieldName === "TaxFilingClaimingCurrent__c"
                && !utility.isUndefinedOrNull(key.oldValue)
                && !utility.isEmpty(key.oldValue)
                && !utility.isUndefinedOrNull(key.value)
                && !utility.isEmpty(key.value)
                && key.oldValue === apConstants.toggleFieldValue.yes
                && key.value === apConstants.toggleFieldValue.no){
                    addRuleNoDependent = true;
                }
            })

            if (reviewRequiredMembers.length > 0
                && !utility.isUndefinedOrNull(reviewRequiredMembers) 
                && !utility.isEmpty(reviewRequiredMembers)
                && !utility.isArrayEmpty(reviewRequiredMembers)){
                reviewRequiredMembers.forEach(rRequiredMember => {
                    revRules.push(
                        apConstants.taxFilingConstants.taxFilingDependentsChange +
                        true +
                        "," +
                        rRequiredMember
                    );
                });
            } else {
                    revRules.push(
                        apConstants.taxFilingConstants.taxFilingDependentsChange +
                        false +
                        "," +
                        "null"
                    );
            }

            if(addRuleNoDependent){
                revRules.push("taxFilingNoDependent,"+true+","+listMemberId.join(","));
            }
            this.reviewRequiredList = revRules;
            this.showSpinner = false;
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.calculateReviewRequiredRules + JSON.stringify(error.message));
            this.showSpinner = false;
        }
    }

    /**
     * @function : closeWarningModal
     * @description : Used to close resource pop up modal.
     */
    closeWarningModal = () => {
        try{
            this.openModel = false;
            this.openModel = "";
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.closeWarningModal + JSON.stringify(error.message));
        }
    };

    /* @function : saveTaxFilingData
     * @description: Method to save tax filing data.
     */
    saveTaxFilingData = () => {
        try {
            const taxFilingData = this.template.querySelectorAll(
                ".ssp-taxFilingDetailInputs"
            );
            const taxFilingSelectedValues = {};
            taxFilingData.forEach(filingData => {
                taxFilingSelectedValues[filingData.getAttribute("data-id")] = filingData.value;
                if (filingData.getAttribute("data-id") === "TaxFilerStatusCurrentYear__c" && filingData.oldValue != filingData.value) {
                    taxFilingSelectedValues["previousTaxFilingStatus"] = filingData.oldValue;
                }
            });
            taxFilingSelectedValues.memberId = this.memberId;
            taxFilingSelectedValues.applicationId = this.applicationId;
            taxFilingSelectedValues["TaxFilingSameNextYear__c"] = taxFilingSelectedValues.taxFilingDetailsSameNextYear;
            taxFilingSelectedValues["TaxFilingClaimingCurrent__c"] = taxFilingSelectedValues.taxFilingDetailsClaimingDependentCurrentYear;
            taxFilingSelectedValues["TaxFilingClaimingNext__c"] = taxFilingSelectedValues.taxFilingDetailsClaimingDependentNextYear;
            if (taxFilingSelectedValues["TaxFilingClaimingCurrent__c"] === apConstants.toggleFieldValue.no){
                taxFilingSelectedValues["TaxFilerMemberCurrent__c"] = null;
            }

            if (taxFilingSelectedValues["TaxFilingClaimingNext__c"] === apConstants.toggleFieldValue.no) {
                taxFilingSelectedValues["TaxFilingClaimingNext__c"] = null;
            }
            this.showSpinner = true;
            /* @sUpdatedValues {String} array converted to string with updated values.
             * @returns {Boolean} Returns a response with true or false.
            */
            updateTaxFilingDetails({
                sUpdatedValues: JSON.stringify(taxFilingSelectedValues)
            })
            .then(result => {
                this.showSpinner = false;
                const mapResInputs = {};
                mapResInputs.memberId = this.memberId;
                mapResInputs.applicationId = this.applicationId;
                mapResInputs.mode = this.modeValue;
                this.showSpinner = true;
                checkTMemberCall({
                    mapInputs: mapResInputs
                })
                .then(interfaceCallResult => {
                    this.showSpinner = false;
                    if (interfaceCallResult.bIsSuccess
                        && (interfaceCallResult.mapResponse.TMembers && 
                            interfaceCallResult.mapResponse.TMembers !== "NoTMembers"
                        && interfaceCallResult.mapResponse.TMembers !== "TMemberNotTriggered")) {
                        this.tMemberPopupContent = formatLabels(
                            sspWillNotAskQuestionsForRestOfTheApplication,
                            [interfaceCallResult.mapResponse.TMembers]
                        );
                        this.showTMemberModal = true;
                        this.saveCompleted = false;
                    } else {
                        this.showTMemberModal = false;
                        this.saveCompleted = true;
                    }
                    this.showSpinner = false;
                })
            })    
            .catch(error => {
                console.error(apConstants.taxFilingConstants.taxFilingError.saveTaxFilingData + error);
                this.showSpinner = false;
            });
        } catch (error) {
            console.error(apConstants.taxFilingConstants.taxFilingError.saveTaxFilingData + JSON.stringify(error.message));
            this.saveCompleted = false;
        }
    };

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try {
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isScreenAccessible = (!utility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == apConstants.permission.notAccessible) ? false : true;                
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