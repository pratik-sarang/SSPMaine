/**
 * Component Name: sspResourceDetails.
 * Author: Kyathi Kanumuri, Karthik Gulla.
 * Description: This screen is used for Resource Details.
 * Date: 12/05/2019.
 */
import { track, wire, api } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import SSPASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import utility, {
    formatLabels,
    getPicklistSubTypeValues,
    getYesNoOptions,
    getOtherAccountValue
} from "c/sspUtility";
import getCurrentApplicationHouseholdMembers from "@salesforce/apex/SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers";
import saveResourceDetails from "@salesforce/apex/SSP_ResourceDetailsController.saveResourceDetails";
import getInsurancePolicyDetailsForAsset from "@salesforce/apex/SSP_ResourceDetailsController.getInsurancePolicyDetailsForAsset";
//Custom Labels
import sspCompleteRequiredQuestions from "@salesforce/label/c.SSP_CompleteDetailsResource";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspResourceDetailHeading from "@salesforce/label/c.SSP_ResourceDetailHeading";
import sspAddAnotherOwnerLink from "@salesforce/label/c.SSP_AddAnotherOwnerLink";
import sspNoResourceDetailsRequiredText from "@salesforce/label/c.SSP_NoAdditionalResourceDetailsText";
import sspResDetailConsent from "@salesforce/label/c.SSP_ResourceDetailConsent";
import sspResSelectOtherLabel from "@salesforce/label/c.SSP_ResourceSelectOtherLabel";
import sspResSelectOtherAccountLabel from "@salesforce/label/c.SSP_ResourceSelectAccountOtherLabel";
import sspTypeOfResource from "@salesforce/label/c.SSP_TypeOfResource";
import sspTypeOfAccount from "@salesforce/label/c.SSP_TypeOfAccount";
import sspTypeOfInvestment from "@salesforce/label/c.SSP_TypeOfInvestment";
import sspTypeOfOtherLiquidResource from "@salesforce/label/c.SSP_TypeOfOtherLiquidResource";
import sspTypeOfRealEstate from "@salesforce/label/c.SSP_TypeOfRealEstate";
import sspIsHomeSteadProperty from "@salesforce/label/c.SSP_IsHomeSteadProperty";
import sspIsIncomeProducing from "@salesforce/label/c.SSP_IsIncomeProducing";
import sspIsIncomeSelfSupport from "@salesforce/label/c.SSP_IsIncomeSelfSupport";
import sspRealEstateAddress from "@salesforce/label/c.SSP_RealEstateAddress";
import sspPropertyFairMarketValue from "@salesforce/label/c.SSP_PropertyFairMarketValue";
import sspInsuranceCompanyName from "@salesforce/label/c.SSP_InsuranceCompanyName";
import sspPolicyNumber from "@salesforce/label/c.SSP_PolicyNumber";
import sspPolicyStartDate from "@salesforce/label/c.SSP_PolicyStartDate";
import sspTypeOfInsurance from "@salesforce/label/c.SSP_TypeOfInsurance";
import sspLifeInsuranceFaceValue from "@salesforce/label/c.SSP_LifeInsuranceFaceValue";
import sspLifeInsuranceSurrenderValue from "@salesforce/label/c.SSP_LifeInsuranceSurrenderValue";
import sspInsuranceCompanyAddress from "@salesforce/label/c.SSP_InsuranceCompanyAddress";
import sspPhoneNumber from "@salesforce/label/c.SSP_PhoneNumber";
import sspLoanAmountOwned from "@salesforce/label/c.SSP_LoanAmountOwned";
import sspIsInsuranceForBurial from "@salesforce/label/c.SSP_IsInsuranceForBurial";
import sspIsInsuranceForFuneral from "@salesforce/label/c.SSP_IsInsuranceForFuneral";
import sspFuneralNameLocation from "@salesforce/label/c.SSP_FuneralNameLocation";
import sspContractCost from "@salesforce/label/c.SSP_ContractCost";
import sspIsFuneralFunded from "@salesforce/label/c.SSP_IsFuneralFunded";
import sspDidSignListOfGoods from "@salesforce/label/c.SSP_DidSignListOfGoods";
import sspInsurancePolicy from "@salesforce/label/c.SSP_InsurancePolicy";
import sspIsAssignedToFuneralHome from "@salesforce/label/c.SSP_IsAssignedToFuneralHome";
import sspVehicleCategory from "@salesforce/label/c.SSP_VehicleCategory";
import sspTypeOfVehicle from "@salesforce/label/c.SSP_TypeOfVehicle";
import sspVehicleAmountOwned from "@salesforce/label/c.SSP_VehicleAmountOwned";
import sspMake from "@salesforce/label/c.SSP_Make";
import sspModel from "@salesforce/label/c.SSP_Model";
import sspYear from "@salesforce/label/c.SSP_Year";
import sspCurrencyValue from "@salesforce/label/c.SSP_CurrencyValue";
import sspPrimaryVehicleUse from "@salesforce/label/c.SSP_PrimayVehicleUse";
import sspWhenGotVehicle from "@salesforce/label/c.SSP_WhenGotVehicle";
import sspVehicleCurrentValue from "@salesforce/label/c.SSP_VehicleCurrentValue";
import sspAbleToRideVehicle from "@salesforce/label/c.SSP_AbleToRideVehicle";
import sspHaveAccessToVehicle from "@salesforce/label/c.SSP_HaveAccessToVehicle";
import sspWhyNoVehicleAccess from "@salesforce/label/c.SSP_WhyNoVehicleAccess";
import sspHasAnotherOwner from "@salesforce/label/c.SSP_HasAnotherOwner";
import sspWhoIsAnotherOwner from "@salesforce/label/c.SSP_WhoIsAnotherOwner";
import sspWhoHasNameOnAccount from "@salesforce/label/c.SSP_WhoHasNameOnAccount";
import sspPrimaryVehicleUser from "@salesforce/label/c.SSP_PrimaryVehicleUser";
import sspInformationNotAvailable from "@salesforce/label/c.SSP_InformationNotAvailable";
import sspOtherOwnerName from "@salesforce/label/c.SSP_OtherOwnerName";
import apConstants from "c/sspConstants";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import sspResourceTypeAltText from "@salesforce/label/c.SSP_ResourceTypeAltText";
import sspAccountTypeAltText from "@salesforce/label/c.SSP_AccountTypeAltText";
import sspInvestmentTypeAltText from "@salesforce/label/c.SSP_InvestmentTypeAltText";
import sspLiquidTypeAltText from "@salesforce/label/c.SSP_LiquidTypeAltText";
import sspPropertyTypeAltText from "@salesforce/label/c.SSP_PropertyTypeAltText";
import sspInsuranceTypeAltText from "@salesforce/label/c.SSP_InsuranceTypeAltText";
import sspFundingOptionsAltText from "@salesforce/label/c.SSP_FundingOptionsAltText";
import sspInsuranceOptionsAltText from "@salesforce/label/c.SSP_InsuranceOptionsAltText";
import sspVehicleOptionsAltText from "@salesforce/label/c.SSP_VehicleOptionsAltText";
import sspVehiclePrimaryUseAltText from "@salesforce/label/c.SSP_VehiclePrimaryUseAltText";
import sspVehicleLackAltText from "@salesforce/label/c.SSP_VehicleLackAltText";
import sspAddAnotherOwnerAltText from "@salesforce/label/c.SSP_AddAnotherOwnerAltText";
import sspVehicleUserAltText from "@salesforce/label/c.SSP_VehicleUserAltText";
import sspSelectResourceAltText from "@salesforce/label/c.SSP_SelectResourceAltText";
import sspSaveResourceAltText from "@salesforce/label/c.SSP_SaveResourceAltText";
import sspCancelResourceAltText from "@salesforce/label/c.SSP_CancelResourceAltText";
import sspIncomeProducingProperty from "@salesforce/label/c.SSP_Resource_IncomeProducingProperty";
import sspIncomeEssentialToSupport from "@salesforce/label/c.SSP_Resource_IncomeEssentialToSupport";
import sspPolicyBeenAssigned from "@salesforce/label/c.SSP_Resource_PolicyAssignedtoFuneralContract";
import sspResourceOtherOwnerLabel from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspResourceDuplicateOwnerError from "@salesforce/label/c.SSP_ResourceDuplicateOwnerError";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspHomesteadHelpText from "@salesforce/label/c.SSP_Resource_Homestead_Helptext";
import sspResourceTypeHelpText from "@salesforce/label/c.SSP_ResourceType_HelpText";
import sspResourceDetailsRemoveIconAlternate from "@salesforce/label/c.SSP_ResourceDetailsRemoveIconAlternate";
import getResourcesDetailsMappings from "@salesforce/apex/SSP_ResourcesService.getResourcesDetailsMappings";

export default class sspResourceDetails extends utility {
    @api applicationId;
    @api memberId;
    @api memberName;
    @api details = {};
    @api resourceRecordTypeId;
    @api resourcesNotRequired;
    @api headOfHousehold;
    @api medicaidNonMagi;
    @api memberPrograms;
    @api timeTravelDate;

    // @track properties
    @track enteredHandleResourceTypeChange = false;
    @track trueValue = true;
    @track MetaDataListParent;
    @track allowSaveValue;
    @track objValue;
    @track picklistValues;
    @track objResource = {};
    @track isLastOtherOwner = true;
    @track resourceTypeOptions = [];
    @track resourceSubTypeOptions = [];
    @track yesNoOptions = getYesNoOptions();
    @track funeralContractFundedOptions = [];
    @track householdMembers = [];
    @track primaryUserOptions = [];
    @track insuranceAssets = [];
    @track vehiclePrimaryUseOptions = [];
    @track vehicleNoAccessOptions = [];
    @track showNoAccessReason = false;
    @track sspResSelect = "";
    @track additionalOwners;
    @track hasAnotherOwner = false;
    @track hasOtherOwner = false;
    @track showEmptyOwner = false;
    @track isIncomeProducingProperty = false;
    @track showDetailsSpinner = true;
    @track showSpinner = false;
    @track resourceDetails = {
        isResourceNotRequired: false,
        isResourceVehicle: false,
        isResourceInsurance: false,
        isResourceFuneralContract: false,
        isResourceRealEstate: false,
        showAnotherOwnerSection: false,
        showResourceValueSection: false,
        showConsentSection: false,
        showResourceSubTypeSection: false,
        showInsurancePolicySection: false,
        sspResourceConsentLabel: "",
        sspResourceSubTypeLabel: "",
        hasNoInformation: false,
        resourceTypeDisabled: true,
        sspResourceSubTypeAltText: "",
        showCashSurrenderValue: false,
        showDesignatedForBurial: false
    };
    @track sspDidSignListOfGoodsLabel;
    @track sspAbleToRideVehicleLabel;
    @track sspPrimaryVehicleUseLabel;
    @track sspWhenGotVehicleLabel;
    @track sspWhyNoVehicleAccessLabel;
    @track sspHaveAccessToVehicleLabel;
    @track hasSaveValidationError = false;
    @track showOtherOwnerError = false;
    @track showEmptyOwnerError = false;
    @track showEmptyOwnerLabel = "";
    @track hasMetadataListValues = false;
    @track fieldProgramMappings = {};
    @track showSaveEmptyOwnerError = false;
    @track showSaveEmptyOwnerErrorLabel = "";
    @track currentActionTemp;
    @track timeTravelDate;
    @track notEnoughInformationFields = [
        apConstants.resourceDetailConstants.resourceMemberId,
        apConstants.resourceDetailConstants.resourceApplicationId,
        apConstants.resourceDetailConstants.resourceNotEnoughInformation,
        apConstants.resourceDetailConstants.resourceTypeField,
        apConstants.resourceSummary.resourceId
    ];
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    customLabel = {
        sspCompleteRequiredQuestions,
        sspCancel,
        sspSave,
        sspResourceDetailHeading,
        sspAddAnotherOwnerLink,
        sspNoResourceDetailsRequiredText,
        sspTypeOfResource,
        sspTypeOfAccount,
        sspTypeOfInvestment,
        sspTypeOfOtherLiquidResource,
        sspTypeOfRealEstate,
        sspIsHomeSteadProperty,
        sspIsIncomeProducing,
        sspIsIncomeSelfSupport,
        sspRealEstateAddress,
        sspPropertyFairMarketValue,
        sspInsuranceCompanyName,
        sspPolicyNumber,
        sspPolicyStartDate,
        sspTypeOfInsurance,
        sspLifeInsuranceFaceValue,
        sspLifeInsuranceSurrenderValue,
        sspInsuranceCompanyAddress,
        sspPhoneNumber,
        sspLoanAmountOwned,
        sspIsInsuranceForBurial,
        sspIsInsuranceForFuneral,
        sspFuneralNameLocation,
        sspContractCost,
        sspIsFuneralFunded,
        sspDidSignListOfGoods,
        sspInsurancePolicy,
        sspIsAssignedToFuneralHome,
        sspVehicleCategory,
        sspTypeOfVehicle,
        sspPrimaryVehicleUser,
        sspMake,
        sspModel,
        sspYear,
        sspVehicleCurrentValue,
        sspHaveAccessToVehicle,
        sspHasAnotherOwner,
        sspWhoIsAnotherOwner,
        sspWhoHasNameOnAccount,
        sspInformationNotAvailable,
        sspVehicleAmountOwned,
        sspCurrencyValue,
        sspOtherOwnerName,
        sspResourceTypeAltText,
        sspAccountTypeAltText,
        sspInvestmentTypeAltText,
        sspLiquidTypeAltText,
        sspPropertyTypeAltText,
        sspInsuranceTypeAltText,
        sspFundingOptionsAltText,
        sspInsuranceOptionsAltText,
        sspVehicleOptionsAltText,
        sspVehiclePrimaryUseAltText,
        sspVehicleLackAltText,
        sspAddAnotherOwnerAltText,
        sspVehicleUserAltText,
        sspSelectResourceAltText,
        sspSaveResourceAltText,
        sspCancelResourceAltText,
        toastErrorText,
        sspIncomeProducingProperty,
        sspIncomeEssentialToSupport,
        sspPolicyBeenAssigned,
        sspResourceTypeHelpText,
        sspHomesteadHelpText,
        sspResourceDetailsRemoveIconAlternate
    };
    summaryTitle = "";
    //Identifiers used to bypass start date validation for Life Insurance Resource
    futureDateFieldAPI = "Is_Date_Future__c";
    requiredFieldAPI = "Input_Required__c";
    assetStartDateMetadataKey = "StartDate__c,SSP_Asset__c";

    /*
     * @function    : hideToast
     * @description : Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(apConstants.resourceSummary.resourceSummaryError.hideToast + JSON.stringify(error.message));
        }
    };

    /**
     * @function : Wire property to get SSP_Asset object Info
     * @description : Wire property to get SSP_Asset object Info.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo ({ error, data }) {
        try {
            if (data) {
                const recordTypeInformation = data[apConstants.resourceDetailConstants.resourceRecordTypes];
                this.resourceRecordTypeId = Object.keys(recordTypeInformation).find(
                    recTypeInfo => recordTypeInformation[recTypeInfo].name === apConstants.resourceDetailConstants.resourceRecordTypeName
                );
            } else if (error) {
                console.error(apConstants.resourceDetailConstants.resourceDetailsError.getObjectInfo +JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getObjectInfo + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Wire property to get Current Application household members
     * @description : Wire property to get Current Application household members.
     * @param {sApplicationId} sApplicationId - Application id.
     */
    @wire(getCurrentApplicationHouseholdMembers, {
        sApplicationId: "$applicationId",
        sMemberId: "$memberId",
        sMembersType: apConstants.resourceDetailConstants.others
    })
    householdMemberDetails ({ error, data }) {
        try {
            if (data) {
                const hMembers = JSON.parse(data.mapResponse.householdMembers);
                let hMembersArray = new Array();
                hMembers.forEach(hMember => {
                    hMembersArray.push({
                        label: hMember[apConstants.resourceDetailConstants.resourceHouseholdName],
                        value: hMember[apConstants.resourceDetailConstants.resourceMemberId],
                        isTMember: hMember[apConstants.resourceSelectionConstants.sIsTMember]
                    });
                });

                hMembersArray = hMembersArray.filter(
                    hMember => hMember.isTMember == false
                );
                
                hMembersArray.push(getOtherAccountValue());
                this.householdMembers = hMembersArray;

                if (!utility.isUndefinedOrNull(this.details[apConstants.resourceSummary.resourceType])
                    && this.details[apConstants.resourceSummary.resourceType] === apConstants.resourceTypes.vehicle) {
                    if (this.householdMembers.length > 0
                        && !utility.isUndefinedOrNull(this.details[apConstants.resourceDetailConstants.resourceOtherOwners])) {
                        const otherOwners = this.details[apConstants.resourceDetailConstants.resourceOtherOwners].split(",");
                        otherOwners.forEach(otherOwner => {
                            if (otherOwner !== apConstants.resourceDetailConstants.otherValue) {
                                const currentHouseholdMember = this.householdMembers.filter(
                                    member => otherOwner === member.value
                                );
                                if (!utility.isUndefinedOrNull(currentHouseholdMember[0])) {
                                    currentHouseholdMember[0].ownerType = "other";
                                    this.primaryUserOptions.push(currentHouseholdMember[0]);
                                }
                            }
                        });
                    }
                }
            } else if (error) {
                console.error(apConstants.resourceDetailConstants.resourceDetailsError.getCurrentApplicationHouseholdMembers +JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getCurrentApplicationHouseholdMembers + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Wire property to get Current Members Insurance policies, if any
     * @description : Wire property to get Current Members Insurance policies, if any.
     * @param {sMemberId} sMemberId - Member id.
     */
    @wire(getInsurancePolicyDetailsForAsset, {
        sMemberId: "$memberId"
    })
    insurancePolicyDetails ({ error, data }) {
        try {
            if (data) {
                const iAssetPolicies = JSON.parse(data.mapResponse.insuranceAssets);
                if (iAssetPolicies.length > 0) {
                    const iAssetPoliciesArray = new Array();
                    iAssetPolicies.forEach(iPolicy => {
                        iAssetPoliciesArray.push({
                            label: iPolicy[apConstants.resourceDetailConstants.resourceInsurancePolicyNumber],
                            value: iPolicy[apConstants.resourceDetailConstants.resourceInsuranceAssetId]
                        });
                    });
                    this.insuranceAssets = iAssetPoliciesArray;
                    if (apConstants.resourceTypes.funeralFundLIValue.indexOf(this.details[apConstants.resourceDetailConstants.resourceFuneralFundOption]) > -1) {
                        this.resourceDetails.showInsurancePolicySection = true;
                    }
                } else {
                    this.showInsurancePolicySection = false;
                }
            } else if (error) {
                console.error(apConstants.resourceDetailConstants.resourceDetailsError.getInsurancePolicyDetailsForAsset + JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getInsurancePolicyDetailsForAsset + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSave () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getAllowSave + JSON.stringify(error.message));
            return null;
        }
    }
    set allowSave (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.allowSaveValue = value;
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.setAllowSave + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for objWrap.
     * @description : Getter setter methods for objWrap.
     */
    @api
    get objWrap () {
        try {
            return this.objValue;
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getObjWrap + JSON.stringify(error.message));
            return null;
        }
    }
    set objWrap (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.setObjWrap + JSON.stringify(error.message));
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
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getMetadataList + JSON.stringify(error.message));
            return null;
        }
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.MetaDataListParent = value;
                this.hasMetadataListValues = true;
                const that = this;
                Object.keys(that.MetaDataListParent).forEach(function (key) {
                    if (!utility.isUndefinedOrNull(that.details[apConstants.resourceSummary.resourceType])
                        && that.details[apConstants.resourceSummary.resourceType] === apConstants.resourceTypes.lifeInsurance
                        && key === that.assetStartDateMetadataKey) {
                        that.MetaDataListParent[key][that.futureDateFieldAPI] = false;
                    }

                    if (!utility.isUndefinedOrNull(that.details[apConstants.resourceSummary.resourceType])
                        && that.details[apConstants.resourceSummary.resourceType] === apConstants.resourceTypes.vehicle
                        && key === that.assetStartDateMetadataKey) {
                        that.MetaDataListParent[key][that.requiredFieldAPI] = false;
                    }
                });

                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0){
                    this.constructRenderingMap(null, value); 
                }
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.setMetadataList + JSON.stringify(error.message));
            this.showDetailsSpinner = false;
        }
    }

    /**
     * @function : Wire property to get picklist values
     * @description : Wire property to get picklist values.
     * @param {objectApiName} objectApiName - Object API Name.
     */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSPASSET_OBJECT,
        recordTypeId: "$resourceRecordTypeId"
    })
    picklistResourceTypeOptions ({ error, data }) {
        try {
            if (data) {
                this.picklistValues = data;
                this.resourceTypeOptions = this.picklistValues.picklistFieldValues.ResourceTypeCode__c.values;
                this.vehicleCategoryOptions = this.picklistValues.picklistFieldValues.VehicleCategoryCode__c.values;
                this.vehiclePrimaryUseOptions = this.picklistValues.picklistFieldValues.VehicleUseReason__c.values;
                this.vehicleNoAccessOptions = this.picklistValues.picklistFieldValues.NoAccessReason__c.values;
                this.funeralContractFundedOptions = this.picklistValues.picklistFieldValues.FuneralFundCode__c.values;
                if (!utility.isUndefinedOrNull(this.details)) {
                    this.resourceSubTypeOptions = getPicklistSubTypeValues(
                        this.details[apConstants.resourceSummary.resourceType],
                        this.picklistValues.picklistFieldValues.ResourceSubTypeCode__c
                    );
                }
                this.processOnResourceDetailLoad();
            } else if (error) {
                console.error(apConstants.resourceDetailConstants.resourceDetailsError.getPicklistValuesByRecordType + JSON.stringify(error.message));
            }
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.getPicklistValuesByRecordType + JSON.stringify(error.message));
        }
    }

    /**
     * @function : handleButtonClick
     * @description : Functionality to perform when save/cancel is clicked.
     * @param {event} event - Event Details.
     */
    handleButtonClick = (event) => {
        try {
            const buttonAction = event.srcElement.name;
            if (buttonAction === apConstants.events.save) {
                if(this.isReadOnlyUser) {  // CD2 2.5 Security Role Matrix and Program Access.
                    const buttonActionEvt = new CustomEvent(
                        apConstants.events.detailButtonAction,
                        { detail: { action: apConstants.events.cancel } }
                    );
                    this.dispatchEvent(buttonActionEvt);
                } else {
                    const elem = this.template.querySelectorAll(
                        ".ssp-applicationInputs"
                    );
                    this.twoWayBinding(elem);
                    const userEnteredData = JSON.parse(this.objValue);
                    if (utility.isUndefinedOrNull(userEnteredData[apConstants.resourceDetailConstants.resourceNotEnoughInformation]) 
                        || userEnteredData[apConstants.resourceDetailConstants.resourceNotEnoughInformation] === "false"){
                        this.checkValidations(elem);
                    } else {
                        this.allowSave = true;
                        this.hasSaveValidationError = false;
                        this.showSaveEmptyOwnerError = false;
                        this.showEmptyOwnerError = false; 
                    }
    
                    if (this.allowSave){
                        this.resourceDetails.resourceTypeDisabled = this.resourceDetails.resourceTypeDisabled ? true : false;
                        const resToBeSaved = JSON.parse(JSON.stringify(this.details));
                        if (!this.objValue) {
                            this.hasSaveValidationError = true;
                            this.showSpinner = false;
                        }
                        const resourceToBeSavedJson = JSON.parse(this.objValue);
                        if (!utility.isUndefinedOrNull(this.additionalOwners)) {
                            this.additionalOwners.splice(0, this.additionalOwners.length);
                        }
    
                        const newAdditionalOwners = [];
                        Object.keys(resourceToBeSavedJson).forEach(function (key) {
                            if ((!isNaN(key) || key === apConstants.resourceDetailConstants.resourceLastAdditionalOwner)) {
                                newAdditionalOwners.push({
                                    value: resourceToBeSavedJson[key] 
                                });
                            }
                        });
                        this.additionalOwners = new Array();
                        this.additionalOwners = JSON.parse(JSON.stringify(newAdditionalOwners));
                        resourceToBeSavedJson[apConstants.resourceSummary.resourceTempId] = resToBeSaved[apConstants.resourceSummary.resourceTempId];
                        resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceMemberId] = this.memberId;
                        resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceApplicationId] = this.applicationId;
                        resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceAdditionalOwners] = this.additionalOwners;
                        if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceFieldIncomeProducingProperty] === apConstants.resourceDetailConstants.falseValue) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceFieldIncomeEssentialToSupport] = apConstants.resourceDetailConstants.falseValue;
                        }
    
                        if (apConstants.resourceTypes.funeralFundLIValue.indexOf(resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceFuneralFundCode]) === -1) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceInsuranceAssetId] = "";
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourcePolicyForFuneral] = apConstants.resourceDetailConstants.falseValue;
                        }
    
                        if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceTypeField] === apConstants.resourceTypes.lifeInsurance &&
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceSubTypeField] !== apConstants.resourceTypes.wholeLifeInsurance &&
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceSubTypeField] !== apConstants.resourceTypes.modifiedTermLifeInsurance) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceCashSurrenderValue] = null;
                        }
    
                        if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceTypeField] === apConstants.resourceTypes.lifeInsurance &&
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceSubTypeField] === apConstants.resourceTypes.burialLifeInsurance) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourcePolicyForBurial] = apConstants.resourceDetailConstants.falseValue;
                        }
    
                        if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceTypeField] === apConstants.resourceTypes.vehicle &&
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceVehicleAccessField] === apConstants.resourceDetailConstants.trueValue) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceNoAccessReasonField] = null;
                        }
                    
                        resourceToBeSavedJson[apConstants.resourceSummary.resourceId] = resToBeSaved[apConstants.resourceSummary.resourceId];
                        if (!utility.isUndefinedOrNull(resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceOtherOwners]) && resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceOtherOwners].indexOf(",") == 0) {
                            resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceOtherOwners] = resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceOtherOwners].substring(1, resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceOtherOwners].length);
                        } 
                        this.showEmptyOwner = false;
                        //Remove all Other owner Array Elements from JSON
                        Object.keys(resourceToBeSavedJson).forEach(function (key) {
                            if (!isNaN(key)) {
                                delete resourceToBeSavedJson[key];
                            }
                        });
                        if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceNotEnoughInformation] === "false") {
                            this.resourceDetails.hasNoInformation = false;
                        } else if (resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceNotEnoughInformation] === "true") {
                            this.resourceDetails.hasNoInformation = true;
                        } else {
                            this.resourceDetails.hasNoInformation = null;
                        }
                        /* @sUserInputs {String JSON} The input value with resource details to be saved.
                        */
                        let hasDuplicateOwners;
                        if ((!utility.isUndefinedOrNull(this.resourceDetails.hasNoInformation) && !this.resourceDetails.hasNoInformation)
                            || utility.isUndefinedOrNull(this.resourceDetails.hasNoInformation)){
                            hasDuplicateOwners = this.checkIfArrayHasDuplicates(resourceToBeSavedJson[apConstants.resourceDetailConstants.resourceAdditionalOwners]);
                        } else {
                            hasDuplicateOwners = false;
                        }
                        const that = this;
                        //Remove all data to be saved if Not Enough Information is checked
                        Object.keys(resourceToBeSavedJson).forEach(function (key) {
                            if (that.resourceDetails.hasNoInformation && that.notEnoughInformationFields.indexOf(key) < 0) {
                                delete resourceToBeSavedJson[key];
                            }
                        });
                        if (!hasDuplicateOwners){
                            this.showSpinner = true;
                            saveResourceDetails({
                                sUserInputs: JSON.stringify(resourceToBeSavedJson)
                            })
                            .then(result => {
                                const buttonActionEvt = new CustomEvent(
                                    apConstants.events.detailButtonAction,
                                    {
                                        detail: {
                                            action: apConstants.events.save,
                                            resSavedDetails: result
                                        }
                                    }
                                );
                                this.dispatchEvent(buttonActionEvt);
                            })
                            .catch(error => {
                                console.error(
                                    apConstants.resourceDetailConstants
                                        .resourceDetailsError.saveResourceDetails + JSON.stringify(error.message)
                                );
                                this.hasSaveValidationError = true;
                                this.toastErrorText = error;
                                this.showSpinner = false;
                            });
                        } else {
                            this.showSaveEmptyOwnerError = true;
                        }
                    } else {
                        this.hasSaveValidationError = true;
                        this.showSpinner = false;
                    }
                }
            } else if (buttonAction === apConstants.events.cancel) {
                const buttonActionEvt = new CustomEvent(
                    apConstants.events.detailButtonAction,
                    { detail: { action: apConstants.events.cancel } }
                );
                this.dispatchEvent(buttonActionEvt);
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleButtonClick + JSON.stringify(error.message)
            );
            this.showSpinner = true;
        }
    };
    /**
     * @function : renderedCallback
     * @description :This function is called after each render.
     */
    renderedCallback () {
        try {
            if (this.hasMetadataListValues) {
                this.showDetailsSpinner = false;
            }
            if (this.showSaveEmptyOwnerError || this.showEmptyOwnerError) {
                if (!utility.isUndefinedOrNull(this.template.querySelector(".ssp-other-owner-error"))) {
                    this.template.querySelector(".ssp-other-owner-error").classList.add("ssp-input-error");
                }
                const otherOwnerClassList = this.template.querySelectorAll(".ssp-other-owner-error-group");
                otherOwnerClassList.forEach(otherOwnerClass => {
                    otherOwnerClass.classList.add("ssp-input-error");
                });
            } else {
                if (!utility.isUndefinedOrNull(this.template.querySelector(".ssp-other-owner-error"))) {
                    this.template.querySelector(".ssp-other-owner-error").classList.remove("ssp-input-error");
                }
                const otherOwnerClassList = this.template.querySelectorAll(".ssp-other-owner-error-group");
                otherOwnerClassList.forEach(otherOwnerClass => {
                    otherOwnerClass.classList.remove("ssp-input-error");
                });
            }

            if (this.primaryUserOptions.length > 0){
                this.primaryUserOptions.sort(function (a, b) {
                    if (a.value < b.value) {
                        return -1;
                    }
                });
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.renderedCallback + JSON.stringify(error.message)
            );
        }
    }
    /**
     * @function : connectedCallback
     * @description : Rendered on load of Resource details.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Resource Details";
            const fieldEntityNameList =
                apConstants.resourcesFieldEntityNameList;
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                apConstants.resourceDetailConstants.resourceDetailPage
            );
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.connectedCallback + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    }

    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }

    /**
     * @function : getFieldProgramMappingsForResources
     * @description : Functionality to get field program mappings for resources.
     */
    getFieldProgramMappingsForResources = () => {
        try {
            /* @sKey {String} Key with resource type field.
            * @returns { String JSON } Returns a string JSON with resource mappings.
            */
            this.showDetailsSpinner = true;
            getResourcesDetailsMappings({
                sKey: apConstants.resourceDetailConstants.resourceType
            })
            .then(result => {
                const resourceMappings = JSON.parse(JSON.stringify(result));
                Object.keys(resourceMappings).forEach(resourceMapping => {
                    const resourceMappingObject = {};
                    resourceMappingObject.applicablePrograms = resourceMappings[resourceMapping].ApplicablePrograms__c;
                    resourceMappingObject.detailsRequired = resourceMappings[resourceMapping].DetailsRequired__c;
                    this.fieldProgramMappings[resourceMapping] = resourceMappingObject;
                });

                if (!utility.isUndefinedOrNull(this.resourceDetails.resourceTypeDisabled)
                    && !this.resourceDetails.resourceTypeDisabled
                    && !utility.isUndefinedOrNull(this.fieldProgramMappings)) {
                    const filteredResourceTypes = [];
                    this.resourceTypeOptions.forEach(resourceTypeOption => {
                        if (!utility.isUndefinedOrNull(this.fieldProgramMappings[resourceTypeOption.value])
                            && !utility.isUndefinedOrNull(this.memberPrograms)
                            && !utility.isUndefinedOrNull(this.fieldProgramMappings[resourceTypeOption.value].applicablePrograms)
                            && (this.fieldProgramMappings[resourceTypeOption.value].detailsRequired
                                || (!this.fieldProgramMappings[resourceTypeOption.value].detailsRequired
                                    && -1 === this.resourcesNotRequired.indexOf(resourceTypeOption.value)
                                    && this.headOfHousehold && this.medicaidNonMagi))
                            && this.checkIfProgramApplicableForMember(String(this.memberPrograms).split(","), this.fieldProgramMappings[resourceTypeOption.value].applicablePrograms.split(","))
                        ) {
                            filteredResourceTypes.push(resourceTypeOption);
                        }
                    });
                    this.resourceTypeOptions = filteredResourceTypes; 
                } 
                this.showDetailsSpinner = true;
            })
            .catch(error => {
                console.error(
                    apConstants.resourceDetailConstants.resourceDetailsError.getFieldProgramMappingsForResources + JSON.stringify(error.message)
                );
                this.showDetailsSpinner = false;
            });
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.getFieldProgramMappingsForResources + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : handleResourceTypeChange
     * @description : Functionality to perform when resource type is changed.
     * @param {event} event - Event Details.
     */
    handleResourceTypeChange = (event) => {
        try {
            this.showDetailsSpinner = true;
            const rDetails = JSON.parse(JSON.stringify(this.details));
            rDetails[apConstants.resourceSummary.resourceType] = event.detail;
            rDetails[
                apConstants.resourceDetailConstants.resourceTypeLabel
            ] = this.getResourceTypeLabel(
                this.resourceTypeOptions,
                rDetails[apConstants.resourceSummary.resourceType]
            );
            rDetails[apConstants.resourceDetailConstants.resourceOtherOwners] =
                "[]";
            rDetails[
                apConstants.resourceDetailConstants.resourceAdditionalOwners
            ] = "[]";
            rDetails[
                apConstants.resourceDetailConstants.resourceAccessToVehicle
            ] = apConstants.toggleFieldValue.yes;

            if (this.template.querySelector(".ssp-not-enough-info")) {
                this.template.querySelector(".ssp-not-enough-info").value = false;
            }

            this.details = rDetails;
           
            this.enteredHandleResourceTypeChange = true;
            this.processOnResourceDetailLoad();
            this.resourceDetails.resourceTypeDisabled = this.resourceDetails.resourceTypeDisabled ? true : false;
            this.showDetailsSpinner = false;
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleResourceTypeChange + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };

    /**
     * @function : processOnResourceDetailLoad
     * @description : Functionality to handle when resource details are loaded.
     */
    processOnResourceDetailLoad = () => {
        try {
            this.resourceDetails = {
                isResourceNotRequired: false,
                isResourceVehicle: false,
                isResourceInsurance: false,
                isResourceFuneralContract: false,
                isResourceRealEstate: false,
                showAnotherOwnerSection: false,
                showResourceValueSection: false,
                showConsentSection: false,
                showResourceSubTypeSection: false,
                sspResourceConsentLabel: "",
                sspResourceSubTypeLabel: "",
                hasNoInformation: false,
                resourceTypeDisabled: true,
                sspResourceSubTypeAltText: ""
            };

            if (
                !utility.isUndefinedOrNull(this.details) &&
                !utility.isEmpty(this.details)
            ) {
                this.showEmptyOwner = false;
                this.resourceDetails.sspResourceConsentLabel = formatLabels(
                    sspResDetailConsent,
                    [
                        this.memberName,
                        this.details[
                            apConstants.resourceDetailConstants
                                .resourceTypeLabel
                        ]
                    ]
                );
                if (
                    this.details[
                        apConstants.resourceDetailConstants.resourceAnotherOwner
                    ] === apConstants.toggleFieldValue.yes
                ) {
                    this.hasAnotherOwner = true;
                }
                if (this.details.bNoInformation) {
                    this.resourceDetails.hasNoInformation = true;
                }
                if (
                    this.hasAnotherOwner &&
                    this.details[
                        apConstants.resourceDetailConstants.resourceOtherOwners
                    ].indexOf(apConstants.resourceDetailConstants.otherValue) >
                        -1
                ) {
                    this.hasOtherOwner = true;
                    this.additionalOwners = JSON.parse(
                        this.details[
                            apConstants.resourceDetailConstants
                                .resourceAdditionalOwners
                        ]
                    );
                    if (this.additionalOwners.length > 0) {
                        this.isLastOtherOwner = false;
                    }
                }
                if (
                    !utility.isUndefinedOrNull(this.details.bDetailsRequired) &&
                    !this.details.bDetailsRequired
                ) {
                    this.resourceDetails.isResourceNotRequired = true;
                }
                if (
                    apConstants.resourceNotRequired.indexOf(
                        this.details[apConstants.resourceSummary.resourceType]
                    ) > -1
                ) {
                    this.resourceDetails.isResourceNotRequired = true;
                }
                if (
                    utility.isEmpty(
                        this.details[apConstants.resourceSummary.resourceType]
                    )
                ) {
                    this.resourceDetails.resourceTypeDisabled = false;
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.account
                ) {
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.resourceDetails.showResourceValueSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfAccount;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspAccountTypeAltText;
                    this.resourceDetails.showResourceSubTypeSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherAccountLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.vehicle
                ) {
                    this.setPrimaryUserOptionsCurrentMember();
                    if (!utility.isUndefinedOrNull(this.additionalOwners) && this.additionalOwners.length > 0) {
                        this.addPrimaryUsersFromAdditionalOwners();
                    }
                    this.resourceDetails.isResourceVehicle = true;
                    this.resourceDetails.showConsentSection = true;
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfVehicle;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspVehicleOptionsAltText;
                    this.sspResSelect = formatLabels(sspResSelectOtherLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                    this.resourceDetails.showResourceSubTypeSection = true;
                    if (
                        this.details[
                            apConstants.resourceDetailConstants
                                .resourceAccessToVehicle
                        ] === apConstants.resourceDetailConstants.falseValue
                    ) {
                        this.showNoAccessReason = true;
                    }
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.lifeInsurance
                ) {
                    this.resourceDetails.isResourceInsurance = true;
                    this.resourceDetails.showConsentSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfInsurance;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspInsuranceTypeAltText;
                    this.resourceDetails.showResourceSubTypeSection = true;
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                    this.handleLifeInsuranceSubTypeChange(
                        this.details[
                            apConstants.resourceDetailConstants.resourceSubType
                        ]
                    );
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.funeralContract
                ) {
                    this.resourceDetails.isResourceFuneralContract = true;
                    this.resourceDetails.showConsentSection = true;
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.realEstateProperty
                ) {
                    this.resourceDetails.isResourceRealEstate = true;
                    this.resourceDetails.showConsentSection = true;
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfRealEstate;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspPropertyTypeAltText;
                    this.resourceDetails.showResourceSubTypeSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                    if (
                        this.details[
                            apConstants.resourceDetailConstants
                                .resourceIncomeProducingProperty
                        ] === apConstants.resourceDetailConstants.trueValue
                    ) {
                        this.isIncomeProducingProperty = true;
                    }
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.investment
                ) {
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.resourceDetails.showResourceValueSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfInvestment;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspInvestmentTypeAltText;
                    this.resourceDetails.showResourceSubTypeSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherAccountLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                }
                if (
                    this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.otherLiquidResource
                ) {
                    this.resourceDetails.showAnotherOwnerSection = true;
                    this.resourceDetails.showResourceValueSection = true;
                    this.resourceDetails.sspResourceSubTypeLabel = this.customLabel.sspTypeOfOtherLiquidResource;
                    this.resourceDetails.sspResourceSubTypeAltText = this.customLabel.sspLiquidTypeAltText;
                    this.resourceDetails.showResourceSubTypeSection = true;
                    this.sspResSelect = formatLabels(sspResSelectOtherAccountLabel, [
                        this.details[
                        apConstants.resourceDetailConstants.resourceTypeLabel
                        ]
                    ]);
                }
                if (!utility.isUndefinedOrNull(this.picklistValues)) {
                    this.resourceSubTypeOptions = getPicklistSubTypeValues(
                        this.details[apConstants.resourceSummary.resourceType],
                        this.picklistValues.picklistFieldValues
                            .ResourceSubTypeCode__c
                    );
                }
                if (
                    this.details.isResourceEditable &&
                    !this.details.bNoInformation
                ) {
                    this.resourceDetails.hasNoInformation = false;
                }
            } else {
                this.resourceDetails.resourceTypeDisabled = false;
            }
            if (this.enteredHandleResourceTypeChange){
                 this.resourceDetails.resourceTypeDisabled = false;
            }
            this.sspDidSignListOfGoodsLabel = formatLabels(
                sspDidSignListOfGoods,
                [this.memberName]
            );
            this.sspAbleToRideVehicleLabel = formatLabels(
                sspAbleToRideVehicle,
                [this.memberName]
            );
            this.sspPrimaryVehicleUseLabel = formatLabels(
                sspPrimaryVehicleUse,
                [this.memberName]
            );
            this.sspWhyNoVehicleAccessLabel = formatLabels(
                sspWhyNoVehicleAccess,
                [this.memberName]
            );
            this.sspWhenGotVehicleLabel = formatLabels(sspWhenGotVehicle, [
                this.memberName
            ]);
            this.sspHaveAccessToVehicleLabel = formatLabels(
                sspHaveAccessToVehicle,
                [this.memberName]
            );
            this.getFieldProgramMappingsForResources();
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.processOnResourceDetailLoad + JSON.stringify(error.message)
            );
            this.showDetailsSpinner = false;
        }
    };

    /**
     * @function : handleOwnerToggle
     * @description : Functionality to handle when owner is yes/no.
     * @param {event} event - Event Details.
     */
    handleOwnerToggle = (event) => {
        try {
            const isAnotherOwner = event.detail.value;
            if (isAnotherOwner === apConstants.toggleFieldValue.yes) {
                this.hasAnotherOwner = true;
            } else if (isAnotherOwner === apConstants.toggleFieldValue.no) {
                this.hasAnotherOwner = false;
                this.hasOtherOwner = false;
                this.additionalOwners = [];
                this.showEmptyOwner = false;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleOwnerToggle + JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : handleVehicleAccessChange.
     * @description : Functionality to handle when vehicle access is changed.
     * @param {event} event - Event Details.
     */
    handleVehicleAccessChange = (event) => {
        try {
            const hasAccessToVehicle = event.detail.value;
            if (hasAccessToVehicle === apConstants.toggleFieldValue.yes) {
                this.showNoAccessReason = false;
            } else if (hasAccessToVehicle === apConstants.toggleFieldValue.no) {
                this.showNoAccessReason = true;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleVehicleAccessChange + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleOwnerChange
     * @description : Functionality to handle when new owner is added.
     * @param {event} event - Event Details.
     */
    handleOwnerChange = (event) => {
        try {
            if (
                event.detail.value.includes(
                    apConstants.resourceDetailConstants.otherValue
                )
            ) {
                this.hasOtherOwner = true;
                if (
                    this.additionalOwners === undefined ||
                    this.additionalOwners.length === 0
                ) {
                    this.additionalOwners = new Array();
                    this.showEmptyOwner = true;
                    this.showEmptyOwnerError = false;
                }
            } else {
                this.hasOtherOwner = false;
                this.additionalOwners = [];
            }
            if (
                this.details[apConstants.resourceSummary.resourceType] ==
                apConstants.resourceTypes.vehicle
            ){
                this.removeOtherOwnersFromPrimaryUsers("other");
                this.addNewOtherOwnersToPrimaryUsers();
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleOwnerChange + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : validateOtherOwnerErrors
     * @description : Functionality to perform validations on other owners.
     * @param {currentAction} currentAction - Current Action Details.
     */
    validateOtherOwnerErrors = (currentAction) => {
        try{
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.twoWayBinding(elem);

            elem.forEach(inputElement => {
                if (
                    (utility.isUndefinedOrNull(inputElement.value) ||
                        utility.isEmpty(inputElement.value)) &&
                    inputElement.getAttribute("data-id") ===
                    apConstants.resourceDetailConstants
                        .resourceLastAdditionalOwner
                ) {
                    this.showSaveEmptyOwnerError = false;
                    this.showSaveEmptyOwnerErrorLabel = "";
                    this.showEmptyOwnerError = true;
                    this.showEmptyOwnerLabel = sspResourceOtherOwnerLabel;
                    this.showEmptyOwner = true;
                    this.allowSave = false;
                }
                
                if (
                    !utility.isUndefinedOrNull(inputElement.value) &&
                    !utility.isEmpty(inputElement.value) &&
                    inputElement.getAttribute("data-id") ===
                    apConstants.resourceDetailConstants
                        .resourceLastAdditionalOwner
                ) { 
                    const existingValue = this.additionalOwners.find(
                        otherValue => otherValue.value.toLowerCase().trim() === inputElement.value.toLowerCase().trim()
                    );
                    if (
                        !utility.isUndefinedOrNull(existingValue) &&
                        !utility.isEmpty(existingValue)
                    ) { 
                        this.showEmptyOwnerError = true;
                        this.showEmptyOwnerLabel = sspResourceDuplicateOwnerError;
                        this.showEmptyOwner = true;
                        this.allowSave = false;
                        this.showSaveEmptyOwnerError = false;
                        this.showSaveEmptyOwnerErrorLabel = "";
                    } else if ((utility.isUndefinedOrNull(existingValue) ||
                        utility.isEmpty(existingValue)) && currentAction === "add") {
                        const adOwnerValue = {};
                        adOwnerValue.value = inputElement.value;
                        this.additionalOwners.push(adOwnerValue);
                        inputElement.value = "";
                        this.showEmptyOwnerError = false;
                        this.showEmptyOwnerLabel = "";
                    } else if ((utility.isUndefinedOrNull(existingValue) ||
                        utility.isEmpty(existingValue)) && currentAction === "remove") {
                        this.showEmptyOwnerError = false;
                        this.showEmptyOwnerLabel = "";
                    }
                }
            });
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.validateOtherOwnerErrors + JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : addAnotherOwner
     * @description : Functionality to perform when new owner is added.
     */
    addAnotherOwner = () => {
        try {        
            this.showDetailsSpinner = true;
            if (this.additionalOwners.length > 0) {
                this.isLastOtherOwner = false;
            } else {
                this.isLastOtherOwner = true;
            }
            this.showDetailsSpinner = false;
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.twoWayBinding(elem);
            const resourceData = JSON.parse(this.objValue);
            const tempAdditionalOwners = [];
            Object.keys(resourceData).forEach(function (key) {
                if (!isNaN(key)) {
                    tempAdditionalOwners.push({
                        value: resourceData[key]
                    });
                }
            });
            const hasDuplicateOwners = this.checkIfArrayHasDuplicates(tempAdditionalOwners);
            if (!hasDuplicateOwners){
                this.additionalOwners.splice(0, this.additionalOwners.length);
                this.additionalOwners = new Array();
                this.additionalOwners = tempAdditionalOwners;
                this.validateOtherOwnerErrors("add");
                this.showEmptyOwner = true;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.addAnotherOwner + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : removeCurrentOwner
     * @description : Functionality to perform when current owner is removed.
     * @param {event} event - Event Details.
     */
    removeCurrentOwner = (event) => {
        try {
            if (!utility.isUndefinedOrNull(event.srcElement.name)) {
                this.showSaveEmptyOwnerError = false;
                this.showSaveEmptyOwnerErrorLabel = "";
                this.additionalOwners.splice(event.srcElement.name, 1);
                this.validateOtherOwnerErrors("remove");
            } else {
                this.showEmptyOwner = false;
                this.showEmptyOwnerError = false;
            }

            if (this.additionalOwners.length === 0 && !this.showEmptyOwner) {
                this.hasOtherOwner = false;
                let otherOwners = this.template.querySelector(".ssp-otherOwnersGroup").value;
                if (typeof(otherOwners) === "string") {
                    otherOwners = otherOwners.split(",");
                }
                if (otherOwners.indexOf("Other") > -1){
                    otherOwners.splice(otherOwners.indexOf("Other"), 1);
                    if (this.template.querySelector(".ssp-primaryUser")){
                        this.template.querySelector(".ssp-primaryUser").value = null;
                    }
                    this.template.querySelector(".ssp-otherOwnersGroup").value = otherOwners;
                }
            }
            this.handleAdditionalOwnerOnBlur();
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.removeCurrentOwner + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleConsentChange
     * @description : Functionality to perform when consent is changed.
     * @param {event} event - Event Details.
     */
    handleConsentChange = (event) => {
        try {
            const isConsentChanged = event.target.value;
            if (isConsentChanged) {
                this.resourceDetails.hasNoInformation = true;
            } else {
                this.resourceDetails.hasNoInformation = false;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleConsentChange + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : getResourceTypeLabel
     * @description : get a Resource Type Label based on ResourceType Selected.
     * @param {resourceTypes} resourceTypes - Resource Types with values and properties.
     * @param {resourceType} resourceType - ResourceType Selected.
     */
    getResourceTypeLabel = (resourceTypes, resourceType) => {
        try {
            let resourceLabelFound = false;
            let resourceTypeLabel = "";
            resourceTypes.forEach(currentResourceType => {
                if (currentResourceType.value === resourceType) {
                    resourceLabelFound = true;
                    resourceTypeLabel = currentResourceType.label;
                }
            });

            if (resourceLabelFound) {
                return resourceTypeLabel;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.getResourceTypeLabel + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleIncomeProducingPropertyToggle
     * @description : Functionality to handle when income producing property is changed.
     * @param {event} event - Event Details.
     */
    handleIncomeProducingPropertyToggle = (event) => {
        try {
            const isIncomeProducingProperty = event.detail.value;
            if (
                isIncomeProducingProperty === apConstants.toggleFieldValue.yes
            ) {
                this.isIncomeProducingProperty = true;
            } else if (
                isIncomeProducingProperty === apConstants.toggleFieldValue.no
            ) {
                this.isIncomeProducingProperty = false;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleIncomeProducingPropertyToggle + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleChangeFundOption
     * @description : Functionality to handle when funeral fund option is changed.
     * @param {event} event - Event Details.
     */
    handleChangeFundOption = (event) => {
        try {
            const funeralFundOption = event.detail;
            if (
                apConstants.resourceTypes.funeralFundLIValue.indexOf(funeralFundOption) > -1
                && this.insuranceAssets.length > 0
            ) {
                this.resourceDetails.showInsurancePolicySection = true;
            } else {
                this.resourceDetails.showInsurancePolicySection = false;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleChangeFundOption + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleResourceSubTypeChange
     * @description : Functionality to perform when resource type is changed.
     * @param {event} event - Event Details.
     */
    handleResourceSubTypeChange = (event) => {
        try {
            this.handleLifeInsuranceSubTypeChange(event.detail);
            //Added for CR changes - Rahul
            this.selectedOption = event.target.value;
            if(this.selectedOption === apConstants.typeOfAccount){
                this.resourceDetails.showAnotherOwnerSection= false;
            }else{
                this.resourceDetails.showAnotherOwnerSection= true;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleResourceSubTypeChange + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleLifeInsuranceSubTypeChange
     * @description : Functionality to perform when life insurance resource sub type is changed.
     * @param {lifeInsuranceSubTypeValue} lifeInsuranceSubTypeValue - LifeInsuranceSubTypeValue.
     */
    handleLifeInsuranceSubTypeChange = (lifeInsuranceSubTypeValue) => {
        try {
            if (
                this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.lifeInsurance &&
                (lifeInsuranceSubTypeValue ===
                    apConstants.resourceTypes.wholeLifeInsurance ||
                    lifeInsuranceSubTypeValue ===
                        apConstants.resourceTypes.modifiedTermLifeInsurance)
            ) {
                this.resourceDetails.showCashSurrenderValue = true;
            } else {
                this.resourceDetails.showCashSurrenderValue = false;
            }

            if (
                this.details[apConstants.resourceSummary.resourceType] ===
                    apConstants.resourceTypes.lifeInsurance &&
                lifeInsuranceSubTypeValue !==
                    apConstants.resourceTypes.burialLifeInsurance
            ) {
                this.resourceDetails.showDesignatedForBurial = true;
            } else {
                this.resourceDetails.showDesignatedForBurial = false;
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleLifeInsuranceSubTypeChange + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : setPrimaryUserOptions
     * @description : Functionality to set primary user options when resource is vehicle.
     */
    setPrimaryUserOptionsCurrentMember = () => {
        try {
            const primaryUserValue = {};
            primaryUserValue.value = this.memberId;
            primaryUserValue.label = this.memberName;
            primaryUserValue.ownerType = "primary";
            this.primaryUserOptions.push(primaryUserValue);
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.setPrimaryUserOptions + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : removeOtherOwnersFromPrimaryUsers
     * @description : Functionality to remove existing other owners from primary user options.
     * @param {removeOwnerType} removeOwnerType - Remove owner type value.
     */
    removeOtherOwnersFromPrimaryUsers = (removeOwnerType) => {
        try {
            const onlyPrimaryUsers = this.primaryUserOptions.filter(
                user => user.ownerType === removeOwnerType
            );
            
            const newPrimaryUsers = this.primaryUserOptions.filter(
                primaryUserOption =>
                    !onlyPrimaryUsers.filter(
                        onlyPrimaryUser =>
                            onlyPrimaryUser.ownerType ===
                            primaryUserOption.ownerType
                    ).length
            );
            this.primaryUserOptions = newPrimaryUsers;
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.removeOtherOwnersFromPrimaryUsers + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : addNewOtherOwnersToPrimaryUsers
     * @description : Functionality to add new other owners to primary user options.
     */
    addNewOtherOwnersToPrimaryUsers = () => {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.twoWayBinding(elem);
            let otherOwnersArray;
            elem.forEach(inputElement => {
                if (
                    !utility.isUndefinedOrNull(inputElement.value) &&
                    !utility.isEmpty(inputElement.value) &&
                    inputElement.getAttribute("data-id") ===
                        apConstants.resourceDetailConstants.resourceOtherOwners
                ) {
                    otherOwnersArray = JSON.parse(
                        JSON.stringify(inputElement.value).split(",")
                    );
                }
            });

            otherOwnersArray.forEach(otherOwner => {
                const currentHouseholdMember = this.householdMembers.filter(
                    member => otherOwner === member.value
                );
                if (
                    !utility.isUndefinedOrNull(currentHouseholdMember[0]) &&
                    otherOwner !== "Other"
                ) {
                    currentHouseholdMember[0].ownerType = "other";
                    this.primaryUserOptions.push(currentHouseholdMember[0]);
                }
            });
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.addNewOtherOwnersToPrimaryUsers + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleAdditionalOwnerOnBlur
     * @description : Functionality to read additional owners.
     */
    handleAdditionalOwnerOnBlur = () => {
        try {
            if (
                this.details[apConstants.resourceSummary.resourceType] ==
                apConstants.resourceTypes.vehicle
            ) {
                this.removeOtherOwnersFromPrimaryUsers("additional");
                this.addPrimaryUsersFromAdditionalOwners();
                const elem = this.template.querySelectorAll(
                    ".ssp-applicationInputs"
                );
                this.twoWayBinding(elem);
                elem.forEach(inputElement => {
                    if (!utility.isUndefinedOrNull(inputElement.value) &&
                        !utility.isEmpty(inputElement.value) &&
                        this.showEmptyOwner &&
                        inputElement.getAttribute("data-id") ===
                            apConstants.resourceDetailConstants
                                .resourceLastAdditionalOwner
                    ) {
                        const additionalPrimaryUserValue = {};
                        additionalPrimaryUserValue.value = inputElement.value.toUpperCase();
                        additionalPrimaryUserValue.label = inputElement.value.toUpperCase();
                        additionalPrimaryUserValue.ownerType = "additional";
                        this.primaryUserOptions.push(
                            additionalPrimaryUserValue
                        );
                    }
                });
            }
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.handleAdditionalOwnerOnBlur + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : addPrimaryUsersFromAdditionalOwners
     * @description : Functionality to add additional owners to primary users.
     */
    addPrimaryUsersFromAdditionalOwners = () => {
        try {
            this.additionalOwners.forEach(currentAdditionalOwner => {
                const additionalPrimaryUserValue = {};
                additionalPrimaryUserValue.value = currentAdditionalOwner.value.toUpperCase();
                additionalPrimaryUserValue.label = currentAdditionalOwner.value.toUpperCase();
                additionalPrimaryUserValue.ownerType = "additional";
                this.primaryUserOptions.push(additionalPrimaryUserValue);
            });
        } catch (error) {
            console.error(
                apConstants.resourceDetailConstants.resourceDetailsError.addPrimaryUsersFromAdditionalOwners + JSON.stringify(error.message)
            );
        }
    };

    /*
    * @function : checkIfProgramApplicableForMember
    * @description : This method used to check whether a particular program is applicable.
    */
    checkIfProgramApplicableForMember = (memberProgramList, programMappingList) => {
        try {
            let hasProgram = false;
            if (!utility.isArrayEmpty(memberProgramList) && !utility.isArrayEmpty(programMappingList)){
                memberProgramList.forEach(item => {
                    if (!utility.isArrayEmpty(programMappingList) && programMappingList.indexOf(item) > -1) {
                        hasProgram = true;
                    }
                });
            }
            return hasProgram;
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.checkIfProgramApplicableForMember + JSON.stringify(error.message));
            return false;
        }
    }

    /*
    * @function : checkIfArrayHasDuplicates
    * @description : This method used to check whether the array has duplicate objects.
    */
    checkIfArrayHasDuplicates = (objArray) => {
        try {
            const valuesArr = objArray.map(function (item) { 
                if(item.value){
                    return item.value.trim().toLowerCase();
                } else {
                    return item.value;
                }
            });
            const isDuplicate = valuesArr.some(function (item, index) {
                if(item){
                    return valuesArr.indexOf(item.trim().toLowerCase()) != index
                } else {
                    return false;
                }
            });
            let hasEmptyOwners = false;
            if (valuesArr.indexOf(null) > -1) {
                hasEmptyOwners = true;
            }
            this.allowSave = (isDuplicate || hasEmptyOwners) ? false : true;
            this.hasSaveValidationError = !this.allowSave;
            this.showSaveEmptyOwnerError = (isDuplicate || hasEmptyOwners)? true : false;
            if(this.showSaveEmptyOwnerError) {
                this.showEmptyOwnerError = false;
                this.showEmptyOwnerLabel = "";
            }
            this.showSaveEmptyOwnerErrorLabel = (isDuplicate || hasEmptyOwners) ? (isDuplicate ? sspResourceDuplicateOwnerError : sspResourceOtherOwnerLabel) : "";
            return (isDuplicate || hasEmptyOwners);
        } catch (error) {
            console.error(apConstants.resourceDetailConstants.resourceDetailsError.checkIfArrayHasDuplicates + JSON.stringify(error.message));
            return true;
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
                    this.isPageAccessible = !(securityMatrix.screenPermission === apConstants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === apConstants.permission.readOnly;
                if (!this.isPageAccessible) {
                    this.showAccessDeniedComponent = true;
                } else {
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                "Error in sspResourceDetails.constructRenderingMap", error
            );
        }
    }
}