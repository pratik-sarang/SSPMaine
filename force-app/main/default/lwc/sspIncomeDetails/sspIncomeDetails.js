import { api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import utility from "c/sspUtility";
import getIncomeDetails from "@salesforce/apex/SSP_IncomeController.getIncomeDetailsWithId";
import setIncomeDetails from "@salesforce/apex/SSP_IncomeController.setIncomeDetails";
import getDuplicateEmployerIncomeDetails from "@salesforce/apex/SSP_IncomeController.getDuplicateEmployerIncomeDetails";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import INCOMETYPE_FIELD from "@salesforce/schema/SSP_Asset__c.IncomeTypeCode__c";
import INCOMESUBTYPE_FIELD from "@salesforce/schema/SSP_Asset__c.IncomeSubtypeCode__c";
import UNPAIDTYPE_FIELD from "@salesforce/schema/SSP_Asset__c.ActivityType__c";
import BUSINESSTYPE_FIELD from "@salesforce/schema/SSP_Asset__c.BusinessTypeCode__c";
import INCOMEFREQUENCY_FIELD from "@salesforce/schema/SSP_Asset__c.IncomePayFrequency__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import sspIncomeDetailsLabel from "@salesforce/label/c.SSP_IncomeDetails";
import sspCompleteRequiredQuestions from "@salesforce/label/c.SSP_CompleteRequiredQuestions";
import sspCompleteTheQuestionsBelowAboutIncome from "@salesforce/label/c.SSP_CompleteTheQuestionsBelowAboutIncome";
import sspTypeOfIncome from "@salesforce/label/c.SSP_TypeOfIncome";
import sspEmployerIdentificationNumber from "@salesforce/label/c.SSP_EmployerIdentificationNumber";
import sspJobIncomeFrom from "@salesforce/label/c.SSP_JobIncome";
import sspEmployerName from "@salesforce/label/c.SSP_EmployerName";
import sspEmployerAddress from "@salesforce/label/c.SSP_EmployerAddress";
import sspOptional from "@salesforce/label/c.SSP_Optional";
import sspAddressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import sspPhoneNumber from "@salesforce/label/c.SSP_PhoneNumber";
import sspExt from "@salesforce/label/c.SSP_Ext";
import sspIncomeFrequency from "@salesforce/label/c.SSP_IncomeFrequency";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspTypeOfDividends from "@salesforce/label/c.SSP_TypeOfDividends";
import sspUnpaidEmploymentType from "@salesforce/label/c.SSP_UnpaidEmploymentType";
import sspBusinessType from "@salesforce/label/c.SSP_BusinessType";
import sspEmploymentStartDate from "@salesforce/label/c.SSP_EmploymentStartDate";
import sspEmploymentEndDate from "@salesforce/label/c.SSP_EmploymentEndDate";
import sspHoursWorkedPerWeek from "@salesforce/label/c.SSP_HoursWorkedPerWeek";
import sspWorkDescription from "@salesforce/label/c.SSP_WorkDescription";
import sspDoes from "@salesforce/label/c.SSP_Does";
import sspStillHaveThisSourceOfIncome from "@salesforce/label/c.SSP_StillHaveThisSourceOfIncome";
import sspIsThisEmploymentRequiredToGetASchoolDegree from "@salesforce/label/c.SSP_IsThisEmploymentRequiredToGetASchoolDegree";
import sspIsThisEmploymentRequiredToGetAnUnemploymentBenefit from "@salesforce/label/c.SSP_IsThisEmploymentRequiredToGetAnUnemploymentBenefit";
import sspIs from "@salesforce/label/c.SSP_Is";
import sspStillEmployed from "@salesforce/label/c.SSP_StillEmployed";
import sspEndDate from "@salesforce/label/c.SSP_EndDate";
import sspWeeklyIncomeBeforeTaxes from "@salesforce/label/c.SSP_WeeklyIncomeBeforeTaxes";
import sspMonthlyIncomeBeforeTaxes from "@salesforce/label/c.SSP_MonthlyincomeBeforeTaxes";
import sspMonthlyExpensesRelated from "@salesforce/label/c.SSP_MonthlyExpensesRelated";
import sspStillReceiveThisSourceOfIncome from "@salesforce/label/c.SSP_StillReceiveThisSourceOfIncome";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspDivorceAgreementDate from "@salesforce/label/c.SSP_DivorceAgreementDate";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspBiweeklyIncomeBeforeTaxes from "@salesforce/label/c.SSP_BiweeklyIncomeBeforeTaxes";
import sspBiweeklyIncomeFromTips from "@salesforce/label/c.SSP_BiweeklyIncomeFromTips";
import sspIncomeBeforeTaxes from "@salesforce/label/c.SSP_IncomeBeforeTaxes";
import sspIncomeFromTipsBeforeTaxes from "@salesforce/label/c.SSP_IncomeFromTipsBeforeTaxes";
import sspExpensesRelatedTo from "@salesforce/label/c.SSP_ExpensesRelatedTo";
import sspBiweekly from "@salesforce/label/c.SSP_Biweekly";
import sspWeekly from "@salesforce/label/c.SSP_Weekly";
import sspQuarterly from "@salesforce/label/c.SSP_Quarterly";
import sspMonthly from "@salesforce/label/c.SSP_Monthly";
import sspTwiceMonth from "@salesforce/label/c.SSP_Twice_a_month";
import sspYearly from "@salesforce/label/c.SSP_Yearly";
import sspDaily from "@salesforce/label/c.SSP_Daily";
import sspHourly from "@salesforce/label/c.SSP_Hourly";
import sspTypeOfOtherUnearnedIncome from "@salesforce/label/c.SSP_TypeOfOtherUnearnedIncome";
import sspTypeOfSocialSecurityRetirementOrPensionIncome from "@salesforce/label/c.SSP_TypeOfSocialSecurityRetirementOrPensionIncome";
import sspTypeOfEntitledBenefitsIncome from "@salesforce/label/c.SSP_TypeOfEntitledBenefitsIncome";
import sspTypeOfSupportMaintenanceIncome from "@salesforce/label/c.SSP_TypeOfSupportMaintenanceIncome";
import sspContinueAddIncomeModalContent1 from "@salesforce/label/c.SSP_ContinueAddIncomeModalContent1";
import sspContinueAddIncomeModalContent2 from "@salesforce/label/c.SSP_ContinueAddIncomeModalContent2";
import sspContinueAddIncomeModalContent3 from "@salesforce/label/c.SSP_ContinueAddIncomeModalContent3";
import sspContinueAddIncome from "@salesforce/label/c.SSP_ContinueAddIncome";
import sspContinueAddIncomeQuestionMark from "@salesforce/label/c.SSP_ContinueAddIncomeQuestionMark";
import sspDiscardNewRecord from "@salesforce/label/c.SSP_DiscardNewRecord";
import sspDelete from "@salesforce/label/c.SSP_Delete";
import sspDot from "@salesforce/label/c.SSP_Dot";
import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import sspConstants from "c/sspConstants";
import ADDRESS_LINE1 from "@salesforce/schema/SSP_Asset__c.AddressLine1__c";
import ADDRESS_LINE2 from "@salesforce/schema/SSP_Asset__c.AddressLine2__c";
import ADDRESS_CITY from "@salesforce/schema/SSP_Asset__c.City__c";
import ADDRESS_COUNTY from "@salesforce/schema/SSP_Asset__c.CountyCode__c";
import ADDRESS_STATE from "@salesforce/schema/SSP_Asset__c.StateCode__c";
import ADDRESS_COUNTRY from "@salesforce/schema/SSP_Asset__c.CountryCode__c";
import ADDRESS_ZIP4 from "@salesforce/schema/SSP_Asset__c.ZipCode4__c";
import ADDRESS_ZIP5 from "@salesforce/schema/SSP_Asset__c.ZipCode5__c";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import ZIP from "@salesforce/label/c.Zip";
import COUNTRY from "@salesforce/label/c.Country";
import sspClickHereToSeeTypesOfIncome from "@salesforce/label/c.SSP_ClickHereToSeeTypesOfIncome";
import sspClickHereToSeeBusinessTypes from "@salesforce/label/c.SSP_ClickHereToSeeBusinessTypes";
import sspClickHereToSeeUnemploymentTypes from "@salesforce/label/c.SSP_ClickHereToSeeUnemploymentTypes";
import sspStartTypingOrClickHereToSeeDividendsInterestRoyaltiesTypes from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeeDividendsInterestRoyaltiesTypes";
import sspStartTypingOrClickHereToSeeSupportMaintenanceIncomeTypes from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeeSupportMaintenanceIncomeTypes";
import sspStartTypingOrClickHereToSeeEntitledBenefitsIncomeTypes from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeeEntitledBenefitsIncomeTypes";
import sspStartTypingOrClickHereToSeeSocialSecurityRetirementPensionTypes from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeeSocialSecurityRetirementPensionTypes";
import sspStartTypingOrClickHereToSeeOtherUnearnedIncomeTypes from "@salesforce/label/c.SSP_StartTypingOrClickHereToSeeOtherUnearnedIncomeTypes";
import sspClickHereToSeeIncomeFrequencyOptions from "@salesforce/label/c.SSP_ClickHereToSeeIncomeFrequencyOptions";
import sspSaveThisIncomeEntryAndGoBackToTheIncomeSummary from "@salesforce/label/c.SSP_SaveThisIncomeEntryAndGoBackToTheIncomeSummary";
import sspCancelThisIncomeEntryAndGoBackToTheIncomeSummary from "@salesforce/label/c.SSP_CancelThisIncomeEntryAndGoBackToTheIncomeSummary";
import sspEmployerIdentificationNumberHelpText from "@salesforce/label/c.SSP_EmployerIdentificationNumberHelpText";
import sspExpensesRelatedToThisSelfEmploymentIncomeHelpText from "@salesforce/label/c.SSP_ExpensesRelatedToThisSelfEmploymentIncomeHelpText";
import sspIncomeFromTipsBeforeTaxesHelpText from "@salesforce/label/c.SSP_IncomeFromTipsBeforeTaxesHelpText";
import sspTypeOfDividendsHelpText from "@salesforce/label/c.SSP_TypeOfDividendsHelpText";
import sspTypeOfIncomeHelpText from "@salesforce/label/c.SSP_TypeOfIncomeHelpText";
import sspContractual from "@salesforce/label/c.SSP_Contractual";
import sspOneTime from "@salesforce/label/c.SSP_LumpSum";
import sspContractStartDate from "@salesforce/label/c.SSP_ContractStartDate";
import sspContractEndDate from "@salesforce/label/c.SSP_ContractEndDate";
import year from "@salesforce/label/c.SSP_YearFrequency";
import week from "@salesforce/label/c.SSP_Week";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import hour from "@salesforce/label/c.SSP_Hour";

const frequencyMap = {
    MO: month,
    BW: biWeek,
    QU: quarter,
    SM: twiceMonth,
    WE: week,
    YR: year,
    DA: dayFrequency,
    HO: hour,
    SP: sspContractual,
    ON: sspOneTime
};
const PA_FIELD_MAP = {
    /*addressLine1: {
        ADDRESS_LINE1,
        label: sspEmployerAddress,
        fieldApiName: sspConstants.assetAddressFields.AddressLine1__c,
        objectApiName: sspConstants.sspObjectAPI.SSP_Asset__c
    },
    addressLine2: {
        ADDRESS_LINE2,
        label: sspAddressLine2,
        fieldApiName: sspConstants.assetAddressFields.AddressLine2__c,
        objectApiName: sspConstants.sspObjectAPI.SSP_Asset__c
    },
    city: {
        ADDRESS_CITY,
        label: CITY
    },

    county: {
        ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ADDRESS_STATE,
        label: STATE
    },
    zipCode4: {
        ADDRESS_ZIP4,
        label: ZIP
    },
    zipCode5: {
        ADDRESS_ZIP5,
        label: ZIP
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: sspConstants.addressLabels.Zip
    }*/
    addressLine1: {
        ...ADDRESS_LINE1,
        label: sspEmployerAddress
    },
    addressLine2: {
        ...ADDRESS_LINE2,
        label: sspAddressLine2
    },
    city: {
        ...ADDRESS_CITY,
        label: CITY

    },
    county: {
        ...ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode4: {
        ...ADDRESS_ZIP4,
        label: ZIP
    },
    postalCode: {
        ...ADDRESS_ZIP5,
        label: ZIP
    }
};

export default class sspIncomeDetails extends utility {
    @track sspConstants = sspConstants;
    @api sId = "";
    @api modeIncome = "";
    @api incomeName;
    @api memberName = "";
    @api sspMemberId = "";
    @api sspApplicationId = "";
    @track objIncome = {};
    @track error;
    @track result;
    @track options;
    @track typeOfIncomeOptions;
    @track typeOfDividendOptions;
    @track isAlimonyOrSpousal = false;
    @track unpaidEmploymentOptions;
    @track businessTypeOptions;
    @track incomeFrequencyOptions;
    @track incomeFrequencyOptionsWithOutHourly;
    @track incomeFrequencyOptionsAll;
    @track incomeFrequencyOptionsFiltered;
    @track showSpinner;
    @track incomeSubTypeFieldData;
    @track frequencyType;
    @track incomeSubOptionsLoaded;
    @track disabled;
    @track showDuplicatePopUp;
    @track retrievedExistingIncome;
    @track appliedPrograms = [];
    @track showAddressFields = false;
    @track fieldMap = PA_FIELD_MAP;
    @track addressRecord;
    @track reference = this;
    @track showHourlyField = false;
    @track showContractFields = false;
    hideComponents = true;
    label = {
        sspContinueAddIncomeModalContent1,
        sspContinueAddIncomeModalContent2,
        sspContinueAddIncomeModalContent3,
        sspContinueAddIncome,
        sspContinueAddIncomeQuestionMark,
        sspDiscardNewRecord,
        sspDelete,
        sspDot
    };
    summaryTitle = "";
    @track openModel = false;

    @track objIncomeToRefresh;
    @track isHelpText = true;
    customLabel = {
        sspIncomeDetailsLabel,
        sspCompleteRequiredQuestions,
        sspDivorceAgreementDate,
        sspTypeOfIncome,
        sspEmployerIdentificationNumber,
        sspEmployerName,
        sspEmployerAddress: sspEmployerAddress,
        sspOptional,
        sspAddressLine2: sspAddressLine2,
        sspPhoneNumber: sspPhoneNumber,
        sspExt: sspExt,
        sspIncomeFrequency,
        sspTypeOfDividends,
        sspUnpaidEmploymentType,
        sspBusinessType,
        sspEmploymentStartDate,
        sspEmploymentEndDate,
        sspHoursWorkedPerWeek,
        sspWorkDescription,
        sspDoes,
        sspStillHaveThisSourceOfIncome,
        sspIsThisEmploymentRequiredToGetASchoolDegree,
        sspIsThisEmploymentRequiredToGetAnUnemploymentBenefit,
        sspIs,
        sspStillEmployed,
        sspEndDate,
        sspWeeklyIncomeBeforeTaxes,
        sspMonthlyIncomeBeforeTaxes,
        sspMonthlyExpensesRelated,
        sspStillReceiveThisSourceOfIncome,
        sspCancel,
        sspSave,
        sspBiweeklyIncomeBeforeTaxes,
        sspBiweeklyIncomeFromTips,
        sspIncomeBeforeTaxes,
        sspIncomeFromTipsBeforeTaxes,
        sspExpensesRelatedTo,
        sspBiweekly,
        sspWeekly,
        sspQuarterly,
        sspMonthly,
        sspTwiceMonth,
        sspYearly,
        sspYes,
        sspNo,
        sspTypeOfOtherUnearnedIncome,
        sspTypeOfSocialSecurityRetirementOrPensionIncome,
        sspTypeOfEntitledBenefitsIncome,
        sspTypeOfSupportMaintenanceIncome,
        sspBenefitsApplication,
        sspCompleteTheQuestionsBelowAboutIncome,
        sspClickHereToSeeTypesOfIncome,
        sspClickHereToSeeBusinessTypes,
        sspClickHereToSeeUnemploymentTypes,
        sspStartTypingOrClickHereToSeeDividendsInterestRoyaltiesTypes,
        sspStartTypingOrClickHereToSeeSupportMaintenanceIncomeTypes,
        sspStartTypingOrClickHereToSeeEntitledBenefitsIncomeTypes,
        sspStartTypingOrClickHereToSeeSocialSecurityRetirementPensionTypes,
        sspStartTypingOrClickHereToSeeOtherUnearnedIncomeTypes,
        sspClickHereToSeeIncomeFrequencyOptions,
        sspSaveThisIncomeEntryAndGoBackToTheIncomeSummary,
        sspCancelThisIncomeEntryAndGoBackToTheIncomeSummary,
        sspEmployerIdentificationNumberHelpText,
        sspExpensesRelatedToThisSelfEmploymentIncomeHelpText,
        sspIncomeFromTipsBeforeTaxesHelpText,
        sspTypeOfDividendsHelpText,
        sspTypeOfIncomeHelpText,
        toastErrorText,
        sspJobIncomeFrom,
        sspDaily,
        sspHourly,
        sspContractual,
        sspOneTime,
        sspContractStartDate,
        sspContractEndDate
    };
    @track MetaDataListParent;
    @track allowSaveValue;
    @track objValue;
    @track sIncomeType;
    @track objIncomeValue;
    @track showErrorToast = false;
    @track contractStartDate;
    @track responseOptions = [
        { label: this.customLabel.sspYes, value: "Y" },
        { label: this.customLabel.sspNo, value: "N" }
    ];

    haveSourceOfIncome;
    stillEmployed;
    stillReceiveIncome;
    allowToSaveOnSave = true;
    employerIdentificationNumber;

    @track visibilityState = {
        isDividends: false,
        isUnpaid: false,
        isSelfEmploymentIncome: false,
        isJobIncomeFromEmployer: false,
        isSupportAndMaintenance: false,
        isEntitledBenefits: false,
        isSocialSecurity: false,
        isOtherUnearnedIncome: false
    };
    @track incomeFreqVisibilityState = false;
    @track incomeFreqLabel = "";
    @track incomeFromTipsLabel = "";
    @track expenseRelatedLabel = "";

    @track enableEndDate = false;
    @track sourceOfIncome;
    @track jobIncome = "";
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    /**
     * Method 		: MetadataList.
     *
     * @description 	: The method fetches metadata for validation from framework.
     * @author 		: Kireeti Gora
     **/

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value !== undefined && value !== null) {
            this.MetaDataListParent = value;

            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0){
                this.constructRenderingMap(null, value); 
            }
        }
    }
    /**
     * Method 		: retExp1.
     *
     * @description 	: this method is used as part of screen driver framework.
     * @author 		: DeveloperName
     * @param <ParameterName> - <ParameterDescription>.
     * @returns <Describe return value>.
     * */

    get retExp1 () {
        return this.applicationObj != null;
    }

    /**
* Method 		: getObjectInfo.
* 
* @description 	: Standard Method for getting object information.
* @author 		: Kireeti Gora
 
* */

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;
    /**
     * Method 		: picklistValues.
     *
     * @description 	: Standard method for getting picklist values(for income type field).
     * @author 		: Kireeti Gora
     * @param     <ParameterName> - RecordTypeId and Field Api Nam.
     * @returns       :List of picklist values.
     * */

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: INCOMETYPE_FIELD
    })
    picklistValues ({ error, data }) {
        if (data) {
            this.typeOfIncomeOptions = data.values;
            this.filterIncomeOptions();
        } else if (error) {
            this.error = error;
        }
    }

    /**
     * Method 		: getIncomeSubPicklistValues.
     *
     * @description 	: Standard method for getting picklist values(for income sub type field).
     * @author 		: Kireeti Gora
     * @param  {string}   <ParameterName> - RecordTypeId and Field Api Nam.
     * @returns   {void}    :List of picklist values.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: INCOMESUBTYPE_FIELD
    })
    getIncomeSubPicklistValues ({ error, data }) {
        if (data) {
            this.incomeSubTypeFieldData = data;

            this.manageIncomeSubType();
        } else if (error) {
            this.error = error;
        }
    }

    /**
     * Method 		: picklistValuesForUnpaidType.
     *
     * @description 	: Standard method for getting picklist values(for Unpaid Type field).
     * @author 		: Kireeti Gora
     * @param      <ParameterName>  - RecordTypeId and Field Api Name.
     * @returns       :List of picklist values.
     * */

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: UNPAIDTYPE_FIELD
    })
    picklistValuesForUnpaidType ({ error, data }) {
        if (data) {
            this.unpaidEmploymentOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }
    /**
     * Method 		: picklistValuesForBusinessType.
     *
     * @description 	: Standard method for getting picklist values(for Business Type field).
     * @author 		: Kireeti Gora
     * @param   {string}   <ParameterName>  - RecordTypeId and Field Api Name.
     * @returns {void}      :List of picklist values.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: BUSINESSTYPE_FIELD
    })
    picklistValuesForBusinessType ({ error, data }) {
        if (data) {
            this.businessTypeOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }
    /**
     * Method 		: picklistValuesForIncomeFrequency.
     *
     * @description 	: Standard method for getting picklist values(for Income Frequency field).
     * @author 		: Kireeti Gora
     * @param     <ParameterName>   - RecordTypeId and Field Api Name.
     * @returns       :List of picklist values.
     * */

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: INCOMEFREQUENCY_FIELD
    })
    picklistValuesForIncomeFrequency ({ error, data }) {
        if (data) {
            this.incomeFrequencyOptionsAll = data.values;
            this.incomeFrequencyOptionsWithOutHourly = this.incomeFrequencyOptionsAll.filter(
                opt =>  opt.value !== "HO"
            );
            this.incomeFrequencyOptions =  this.incomeFrequencyOptionsAll.filter(
                opt =>  opt.value !== "HO" && opt.value !== "SP" && opt.value !== "ON"
            );
            this.incomeFrequencyOptionsFiltered = this.incomeFrequencyOptions;
            this.filterFrequencyOptions();
        } else if (error) {
            this.error = error;
        }
    }
    /**
     * Method 		: getIncomeRecord.
     *
     * @description 	: Method to fetch existing income record details With Id.
     * @author 		: Kireeti Gora
     * @param    sId - SID.
     * @returns       : JSON of Income Object Record.
     * */

    @wire(getIncomeDetails, {
        sId: "$sId",
        sspApplicationId: "$sspApplicationId",
        sspMemberId: "$sspMemberId"
    })
    getIncomeRecord (result) {
        this.objIncomeToRefresh = result;
        if (result.data) {
            this.timeTravelDate = result.data.mapResponse.timeTravelDate;
            if ("incomeRecord" in result.data.mapResponse) {
                this.objIncome = JSON.parse(
                    result.data.mapResponse.incomeRecord
                );
                this.setAddressLineStructure();
                if (
                    this.objIncome[
                        this.sspConstants.fieldApiIncomeDetails
                            .IncomeSubTypeCode__c
                    ] === this.sspConstants.fieldApiIncomeDetails.Alimony
                ) {
                    this.isAlimonyOrSpousal = true;
                }
            }
            if ("applicationIndividualPrograms" in result.data.mapResponse) {
                const memberPrograms =
                    result.data.mapResponse.applicationIndividualPrograms;
                const appIndividual = memberPrograms[0];
                if (
                    appIndividual !== null &&
                    appIndividual !== undefined &&
                    appIndividual.ProgramsApplied__c !== null &&
                    appIndividual.ProgramsApplied__c !== undefined
                ) {
                    const programList = appIndividual.ProgramsApplied__c.split(
                        ";"
                    );
                    this.appliedPrograms = programList;
                }
                if (
                    appIndividual !== null &&
                    appIndividual !== undefined &&
                    appIndividual.MedicaidType__c !== null &&
                    appIndividual.MedicaidType__c !== undefined
                ) {
                    this.appliedPrograms.push(appIndividual.MedicaidType__c);
                }
            }

            const incomeTypeValue = this.objIncome.IncomeTypeCode__c;
            const incomeFreq = this.objIncome.IncomePayFrequency__c;
            const endDate = this.objIncome.EndDate__c;
            if (this.modeIncome === "Edit") {
                if (endDate) {
                    this.enableEndDate = true;
                    this.sourceOfIncome = "N";
                } else {
                    this.enableEndDate = false;
                    this.sourceOfIncome = "Y";
                }
            }
            //temporary assignment as toggle is not working properly with boolean values

            if (
                this.objIncome.IsSchoolDegreeRequiredToggle__c !== "Y" &&
                this.objIncome.IsSchoolDegreeRequiredToggle__c !== "N"
            ) {
                this.objIncome[
                    this.sspConstants.fieldApiIncomeDetails.IsSchoolDegreeRequiredToggle__c
                ] = null;
            }
            if (
                this.objIncome[
                    this.sspConstants.fieldApiIncomeDetails
                        .IsUnemployedBenefitsRequiredToggle__c
                ] !== "Y" &&
                this.objIncome[
                    this.sspConstants.fieldApiIncomeDetails
                        .IsUnemployedBenefitsRequiredToggle__c
                ] !== "N"
            ) {
                this.objIncome[
                    this.sspConstants.fieldApiIncomeDetails.IsUnemployedBenefitsRequiredToggle__c
                ] = null;
            }

            if (incomeTypeValue === "DIR") {
                this.visibilityState.isDividends = true;
            } else if (incomeTypeValue === "UI") {
                this.visibilityState.isUnpaid = true;
            } else if (incomeTypeValue === "EA") {
                this.visibilityState.isJobIncomeFromEmployer = true;
            } else if (incomeTypeValue === "SE") {
                this.visibilityState.isSelfEmploymentIncome = true;
            } else if (incomeTypeValue === "SRP") {
                this.visibilityState.isSocialSecurity = true;
            } else if (incomeTypeValue === "SM") {
                this.visibilityState.isSupportAndMaintenance = true;
            } else if (incomeTypeValue === "IS") {
                this.visibilityState.isEntitledBenefits = true;
            } else if (incomeTypeValue === "OUI") {
                this.visibilityState.isOtherUnearnedIncome = true;
            }
           
         
            if (incomeFreq) {    
                this.getIncomeFreqLabel(incomeFreq);
                this.incomeFreqVisibilityState = true;            
                if(incomeFreq === "HO" || this.showChildCareRecords){
                    this.showHourlyField =true;
                    }
                    if(incomeFreq === "SP"){                       
                        this.showContractFields = true;
                       this.contractStartDate = this.objIncome.ContractStartDate__c;
                        }
                        
            }
        } else if (result.error) {
            this.error = result.error;
            this.objIncome = undefined;
        }
        this.filterIncomeOptions();
        this.filterFrequencyOptions();
        this.showSpinner = false;
    }
    filterIncomeOptions () {
        if (
            this.typeOfIncomeOptions !== undefined &&
            this.typeOfIncomeOptions !== null &&
            this.appliedPrograms !== null &&
            this.appliedPrograms !== undefined &&
            this.appliedPrograms.length > 0 &&
            !this.showChildCareRecords
        ) {
            this.typeOfIncomeOptions = this.typeOfIncomeOptions.filter(
                opt => opt.value !== "UI"
            );
        }
    }

    handleContractStartDate (event) {
      this.contractStartDate  = event.detail.value;

    }

    filterFrequencyOptions () {
        if (           
            this.objIncome !== undefined &&
            this.objIncome !== null &&
            this.objIncome.IncomeTypeCode__c !== undefined &&
            this.objIncome.IncomeTypeCode__c !== null &&
            this.incomeFrequencyOptions !== null &&
            this.incomeFrequencyOptions !== undefined &&
            this.incomeFrequencyOptions.length > 0 
        ) {
            const incomeTypeValue = this.objIncome.IncomeTypeCode__c;
            if ( incomeTypeValue === "SE" || incomeTypeValue === "EA") {
                this.incomeFrequencyOptions = this.incomeFrequencyOptionsAll;
             }else if ( incomeTypeValue === "OUI") {
                 this.incomeFrequencyOptions =this.incomeFrequencyOptionsWithOutHourly;
             }else{
                 this.incomeFrequencyOptions = this.incomeFrequencyOptionsFiltered;
             }
        }
    }
    /**
     * Method 		: saveIncomeDetails.
     *
     * @description 	: This method is used to save income details.
     * @author 		: Kireeti Gora
     * @param       <param-name> - JSON of Income Object that needs to be saved.
     * @returns       : Boolean Indicating Success or failue.
     * */

    saveIncomeDetails () {
        this.showSpinner = true;
        if (this.allowToSaveOnSave) {
            this.allowToSaveOnSave = false;
            let objValueWithId = JSON.parse(this.objValue);

            if (this.sId !== null && this.sId !== "") {
                objValueWithId.Id = this.sId;
            }
            if (this.sspMemberId) {
                objValueWithId[
                    this.sspConstants.fieldApiIncomeDetails.SSP_Member__c
                ] = this.sspMemberId;
            } else {
                objValueWithId[
                    this.sspConstants.fieldApiIncomeDetails.SSP_Member__c
                ] = this.objIncome[
                    this.sspConstants.fieldApiIncomeDetails.SSP_Member__c
                ];
            }
            objValueWithId = this.bindAddressFields(objValueWithId);
            this.objValue = JSON.stringify(objValueWithId);
            const objIncomeToSave = this.objValue;
            setIncomeDetails({
                sIncomeJSON: objIncomeToSave
            })
                .then(result => {
                    refreshApex(this.objIncomeToRefresh);
                    this.showDuplicatePopUp = false;
                    const selectedEvent = new CustomEvent(
                        this.sspConstants.fieldApiIncomeDetails.incomeSuccess,
                        {
                            detail: result
                        }
                    );
                    this.showSpinner = false;
                    this.dispatchEvent(selectedEvent);
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                });
        }
    }
    /**
* Method 		: allowSave.
* 
* @description 	: This attribute is part of validation framework which indicates data is valid or not.
* @author 		: Kireeti Gora
 
* */

    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
            //set the toast component
        }
    }

    /**
* Method 		: objWrap.
* 
* @description 	: this attribute contains validated data which is used to save.
* @author 		: Kireeti Gora
 
* */

    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        if (value !== undefined) {
            this.objValue = value;
        }
    }

    /**
     * Method 		: connectedCallback.
     *
     * @description 	: this method is used to fetch required metadata for validation framework.
     * @author 		: Kireeti Gora
     * */

    connectedCallback () {       
        this.summaryTitle = document.title;
        document.title = "Income Details";      
        this.showSpinner = true;
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            "TotalGrossAmount__c,SSP_Asset__c",
            "ContractStartDate__c,SSP_Asset__c",
            "ContractEndDate__c,SSP_Asset__c",
            "EmployerName__c,SSP_Asset__c",
            "DivorceDate__c,SSP_Asset__c",
            "IncomeTypeCode__c,SSP_Asset__c",
            this.sspConstants.fieldApiIncomeDetails.IncomeSubType_Asset,
            "EndDate__c,SSP_Asset__c",
            "IncomePayFrequency__c,SSP_Asset__c",
            "Tips__c,SSP_Asset__c",
            "ExpenseAmount__c,SSP_Asset__c",
            "ActivityStartDate__c,SSP_Asset__c",
            "ActivityType__c,SSP_Asset__c",
            "IncomePayDetailHoursPerWeek__c,SSP_Asset__c",
            "BusinessTypeCode__c,SSP_Asset__c",
            "BusinessTitle__c,SSP_Asset__c",
            "EIN__c,SSP_Asset__c",
            "AddressLine2__c,SSP_Asset__c",
            "PrimaryPhoneNumber__c,SSP_Asset__c",
            "IsSchoolDegreeRequiredToggle__c,SSP_Member__c",
            this.sspConstants.fieldApiIncomeDetails
                .IsUnemployedBenefitsRequired_Member,
            "PrimaryPhoneExtension__c,SSP_Asset__c",
            "AddressLine1__c,SSP_Asset__c",
            "City__c,SSP_Asset__c",
            "StateCode__c,SSP_Asset__c",
            "CountyCode__c,SSP_Asset__c",
            "ZipCode5__c,SSP_Asset__c"
        );
        this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "SSP_APP_Details_IncomeDetails"
        );
        this.haveSourceOfIncome =
            this.customLabel.sspDoes +
            " " +
            this.memberName +
            " " +
            this.customLabel.sspStillHaveThisSourceOfIncome;
        this.stillEmployed =
            this.customLabel.sspIs +
            " " +
            this.memberName +
            " " +
            this.customLabel.sspStillEmployed;
        this.stillReceiveIncome =
            this.customLabel.sspDoes +
            " " +
            this.memberName +
            " " +
            this.customLabel.sspStillReceiveThisSourceOfIncome;
        this.employerIdentificationNumber = this.customLabel.sspEmployerIdentificationNumber;
    }
    /**
* Method 		: manageIncomeSubType.
* 
* @description 	: The method is used to manage and filter values of dependent picklist (income subType).
* @author 		: Kireeti Gora
 
* */

    manageIncomeSubType () {
        if (this.incomeName && this.incomeSubTypeFieldData) {
            const key = this.incomeSubTypeFieldData.controllerValues[
                this.incomeName
            ];
            this.typeOfDividendOptions = this.incomeSubTypeFieldData.values.filter(
                opt => opt.validFor.includes(key)
            );

            if (this.typeOfDividendOptions) {
                this.incomeSubOptionsLoaded = true;
            }
        }
        if (this.modeIncome === "Edit" || this.modeIncome === "Start") {
            this.disabled = true;
        }
    }

    /**
* Method 		: manageIncomeType.
* 
* @description 	: The method is used to manage and filter values of dependent picklist on change of income type field.
* @author 		: Kireeti Gora
 
* */

    manageIncomeType (event) {
        const key = this.incomeSubTypeFieldData.controllerValues[event.detail];
        this.typeOfDividendOptions = this.incomeSubTypeFieldData.values.filter(
            opt => opt.validFor.includes(key)
        );

        const incomeTypeValue = event.detail;
        if ( incomeTypeValue === "SE" || incomeTypeValue === "EA") {
            this.incomeFrequencyOptions = this.incomeFrequencyOptionsAll;
         }else if ( incomeTypeValue === "OUI") {
             this.incomeFrequencyOptions =this.incomeFrequencyOptionsWithOutHourly;
         }else{
            this.incomeFrequencyOptions = this.incomeFrequencyOptionsFiltered;
        }
        if (incomeTypeValue === "DIR") {
            this.visibilityState.isDividends = true;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "UI") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = true;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "EA") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = true;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "SE") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = true;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "OUI") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = true;
        } else if (incomeTypeValue === "SRP") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = true;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "SM") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = true;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else if (incomeTypeValue === "IS") {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = true;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        } else {
            this.visibilityState.isDividends = false;
            this.visibilityState.isUnpaid = false;
            this.visibilityState.isSelfEmploymentIncome = false;
            this.visibilityState.isJobIncomeFromEmployer = false;
            this.visibilityState.isSupportAndMaintenance = false;
            this.visibilityState.isEntitledBenefits = false;
            this.visibilityState.isSocialSecurity = false;
            this.visibilityState.isOtherUnearnedIncome = false;
        }

        if (!this.modeIncome && this.hideComponents) {
            this.incomeFreqVisibilityState = false;
            this.enableEndDate = false;
        }
        this.hideComponents = true;
        this.isAlimonyOrSpousal = false;
    }

    /**
* Method 		: manageIncomeFrequency.
* 
* @description 	: The method is used to manage show hide income sections based on frequency.
* @author 		: Kireeti Gora
 
* */

    manageIncomeFrequency (event) {
        this.frequencyType = event.target.value;
        this.incomeFreqVisibilityState = true;
        if(this.frequencyType === "HO" || this.showChildCareRecords){
        this.showHourlyField =true;
        }else{
            this.showHourlyField =false;   
        }
        if(this.frequencyType === "SP"){
            this.showContractFields = true;
            }else{
                this.showContractFields = false;  
            }
        this.incomeFreqVisibilityState = true;
        this.getIncomeFreqLabel(event.target.value);
    }
    getIncomeFreqLabel = freqType => {
        if (freqType === "BW") {
            this.incomeFreqLabel =
                this.customLabel.sspBiweekly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspBiweekly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspBiweekly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
            // this.frequencyType = this.customLabel.sspBiweeklyIncomeBeforeTaxes;
        } else if (freqType === "QU") {
            this.incomeFreqLabel =
                this.customLabel.sspQuarterly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspQuarterly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspQuarterly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "MO") {
            this.incomeFreqLabel =
                this.customLabel.sspMonthly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspMonthly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspMonthly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "SM") {
            this.incomeFreqLabel =
                this.customLabel.sspTwiceMonth +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspTwiceMonth +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspTwiceMonth +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "WE") {
            this.incomeFreqLabel =
                this.customLabel.sspWeekly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspWeekly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspWeekly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "YR") {
            this.incomeFreqLabel =
                this.customLabel.sspYearly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspYearly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspYearly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "DA") {
            this.incomeFreqLabel =
                this.customLabel.sspDaily +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspDaily +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspDaily +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "HO") {
            this.incomeFreqLabel =
                this.customLabel.sspHourly +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
                this.customLabel.sspHourly +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
                this.customLabel.sspHourly +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "SP") {
            this.incomeFreqLabel =
            this.customLabel.sspContractual +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
            this.customLabel.sspContractual +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
            this.customLabel.sspContractual+
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else if (freqType === "ON") {
            this.incomeFreqLabel =
            this.customLabel.sspOneTime +
                " " +
                this.customLabel.sspIncomeBeforeTaxes;
            this.incomeFromTipsLabel =
            this.customLabel.sspOneTime +
                " " +
                this.customLabel.sspIncomeFromTipsBeforeTaxes;
            this.expenseRelatedLabel =
            this.customLabel.sspOneTime +
                " " +
                this.customLabel.sspExpensesRelatedTo;
        } else {
            this.incomeFreqVisibilityState = false;
        }
    };

    /**
* Method 		: manageQuestions.
* 
* @description 	: The method is used to manage show hide endDate field based on source of income field.
* @author 		: Kireeti Gora
 
* */

    manageQuestions (event) {
        const response = event.detail.value;
        if (response === "N") {
            this.enableEndDate = true;
        } else {
            this.enableEndDate = false;
        }
    }

    /**
* Method 		: handleCancel.
* 
* @description 	: The method is used to cancel income details and go to income summary .
* @author 		: Kireeti Gora
 
* */

    handleCancel () {
        const selectedEvent = new CustomEvent(
            this.sspConstants.fieldApiIncomeDetails.incomeSuccess
        );

        this.dispatchEvent(selectedEvent);
    }

    /**
* Method 		: checkDuplicateIncome.
* 
* @description 	: This method is used to check duplicate income and show warning to user.
* @author 		: Kireeti Gora
 
* */

    checkDuplicateIncome () {
        if(this.isReadOnlyUser) {  // CD2 2.5 Security Role Matrix and Program Access.
            this.handleCancel();
        } else {
        let elem;
        try {
            elem = this.template.querySelectorAll(".ssp-applicationInputs");
            this.hideComponents = false;
            this.checkValidations(elem);
        } catch (error) {
            this.error = error;
        }

        if (this.allowSave && elem.length > 1) {
            const objIncomeToCheck = JSON.parse(this.objValue);
            objIncomeToCheck[
                this.sspConstants.fieldApiIncomeDetails.SSP_Member__c
            ] = this.sspMemberId;
            this.objValue = JSON.stringify(objIncomeToCheck);
            if (
                this.modeIncome !== "Edit" &&
                objIncomeToCheck.IncomeTypeCode__c === "EA"
            ) {
                getDuplicateEmployerIncomeDetails({
                    sIncomeJSON: this.objValue
                })
                    .then(result => {
                        const sObjAsset = result;
                        if (sObjAsset) {
                            this.retrievedExistingIncome = JSON.parse(
                                sObjAsset
                            );
                            this.jobIncome =
                                sspJobIncomeFrom +
                                " " +
                                this.retrievedExistingIncome.EmployerName__c;
                            this.showDuplicatePopUp = true;
                            this.openModel = true;
                                this.retrievedExistingIncome["IncomePayFrequency__c"] = frequencyMap[this.retrievedExistingIncome.IncomePayFrequency__c]
                            //this.sId = this.retrievedExistingIncome.Id;
                        } else {
                            this.saveIncomeDetails();
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });
            } else {
                this.saveIncomeDetails();
            }
        } else {
            this.showErrorToast = true;
        }
    }
}

    /**
* Method 		: onCloseModal.
* 
* @description 	: This method handled close pop up.
* @author 		: Kireeti Gora
 
* */

    onCloseModal () {
        this.showDuplicatePopUp = false;
        this.openModel = false;
    }
    /**
     * Method 		: continueToAddIncome.
     *
     * @description 	: this method allows user to save new record if there is duplicate record.
     * @author 		: kireeti Gora
     **/

    continueToAddIncome () {
        this.saveIncomeDetails();
    }
    /**
     * @function 	: checkForAppliedProgram.
     * @description 	: Method to identify if programs opted by individual member match with the once applicable for input field visibility.
     * */

    checkForAppliedProgram (appliedPrograms, fieldSpecificProgramList) {
        let result = false;
        try {
            for (let i = 0; i < appliedPrograms.length; i++) {
                const tmpProgram = appliedPrograms[i];
                if (fieldSpecificProgramList.includes(tmpProgram)) {
                    result = true;
                    break;
                }
            }
        } catch (error) {
            console.error(
                "failed in checkForAppliedProgram " + JSON.stringify(error)
            );
        }
        return result;
    }
    /**
     * @function 	: showChildCareRecords.
     * @description 	: returns boolean based on applied programs.
     * */

    get showChildCareRecords () {
        const programList = this.sspConstants.fieldApiIncomeDetails
            .showChildCareRecords;
        return this.checkForAppliedProgram(this.appliedPrograms, programList);
    }
    /**
     * @function 	: showMagiRecords.
     * @description 	: returns boolean based on applied programs.
     * */
    get showMagiRecords () {
        const programList = this.sspConstants.fieldApiIncomeDetails
            .showMagiRecords;
        return this.checkForAppliedProgram(this.appliedPrograms, programList);
    }
    /**
     * @function 	: showMedicaidRecords.
     * @description 	: returns boolean based on applied programs.
     * */
    get showMedicaidRecords () {
        const programList = this.sspConstants.fieldApiIncomeDetails
            .showMedicaidRecords;
        return this.checkForAppliedProgram(this.appliedPrograms, programList);
    }
    /**
     * @function 	: showProgramRecords.
     * @description 	: returns boolean based on applied programs.
     * */
    get showProgramRecords () {
        const programList = this.sspConstants.fieldApiIncomeDetails
            .showProgramRecords;
        return this.checkForAppliedProgram(this.appliedPrograms, programList);
    }
    /**
     * @function 		: manageDivorceDate.
     * @description 	: this method Validates Divorce Date Validation.
     * @param {event} event - Gets current value.
     * */
    manageDivorceDate (event) {
        try {
            if (
                event.detail === this.sspConstants.fieldApiIncomeDetails.Alimony
            ) {
                this.isAlimonyOrSpousal = true;
            } else {
                this.isAlimonyOrSpousal = false;
            }
        } catch (error) {
            console.error(
                "failed in manageDivorceDate " + JSON.stringify(error)
            );
        }
    }
    /**
     * @function - setAddressLineStructure.
     * @description - Use to set the Address Line Structure on Page Load.
     */
    setAddressLineStructure () {
        try {
            //Start - Address Line Structure
            const addressRecord = {};
            addressRecord.apiName = sspConstants.sspObjectAPI.SSP_Asset__c;
            addressRecord.childRelationships = {};
            addressRecord.id = this.objIncome.Id;

            const sFields = {};

            const addressLine1 = {};
            addressLine1.displayValue = null;
            addressLine1.value =
                this.objIncome[
                    sspConstants.assetAddressFields.AddressLine1__c
                ] || null;
            sFields[
                sspConstants.assetAddressFields.AddressLine1__c
            ] = addressLine1;

            const addressLine2 = {};
            addressLine2.displayValue = null;
            addressLine2.value =
                this.objIncome[
                    sspConstants.assetAddressFields.AddressLine2__c
                ] || null;
            sFields[
                sspConstants.assetAddressFields.AddressLine2__c
            ] = addressLine2;

            const city = {};
            city.displayValue = null;
            city.value =
                this.objIncome[sspConstants.assetAddressFields.City__c] || null;
            sFields[sspConstants.assetAddressFields.City__c] = city;

            const countyCode = {};
            countyCode.displayValue = null;
            countyCode.value =
                this.objIncome[sspConstants.assetAddressFields.CountyCode__c] ||
                null;

            sFields[sspConstants.assetAddressFields.CountyCode__c] = countyCode;

            const stateCode = {};
            stateCode.displayValue = null;
            stateCode.value =
                this.objIncome[sspConstants.assetAddressFields.StateCode__c] ||
                null;

            sFields[sspConstants.assetAddressFields.StateCode__c] = stateCode;

            const countryCode = {};
            countryCode.displayValue = null;
            countryCode.value =
                this.objIncome["CountryCode__c"] ||
                null;
            sFields["CountryCode__c"] = countryCode;

            const zipCode4 = {};
            zipCode4.displayValue = null;
            zipCode4.value =
                this.objIncome[sspConstants.assetAddressFields.zipCode4] ||
                null;
            sFields[sspConstants.assetAddressFields.zipCode4] = zipCode4;

            const zipCode5 = {};
            zipCode5.displayValue = null;
            zipCode5.value =
                this.objIncome[sspConstants.assetAddressFields.zipCode5] ||
                null;
            sFields[sspConstants.assetAddressFields.zipCode5] = zipCode5;

            addressRecord.fields = sFields;
            this.addressRecord = JSON.parse(JSON.stringify(addressRecord));

            //End - Address Line Structure
        } catch (error) {
            console.error(
                "Error in sspIncomeDetails.setAddressLineStructure" +
                    JSON.stringify(error.message)
            );
        }
    }
    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on contact record.
     * @param {object} asset - Contact record.
     */
    bindAddressFields (asset) {
        try {
            const addressLineClass = this.template.querySelector(
                ".addressLineClass"
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;            
                asset[
                    sspConstants.assetAddressFields.AddressLine1__c
                ] = !utility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                asset[
                    sspConstants.assetAddressFields.AddressLine2__c
                ] = !utility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                asset[
                    sspConstants.assetAddressFields.City__c
                ] = !utility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                //this.contact.sCountryCode = physicalAddress.country;
                asset[
                    sspConstants.assetAddressFields.CountyCode__c
                ] = !utility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                asset[
                    sspConstants.assetAddressFields.StateCode__c
                ] = !utility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                asset["CountryCode__c"] = !utility.isUndefinedOrNull(
                    physicalAddress.country
                )
                    ? physicalAddress.country
                    : null;
                const zipCode = physicalAddress.postalCode;              
                if (!utility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        asset[
                            sspConstants.assetAddressFields.zipCode4
                        ] = zipCode;
                        //asset[sspConstants.assetAddressFields.zipCode4] = "";
                    } else {
                        asset[
                            sspConstants.assetAddressFields.zipCode5
                        ] = zipCode;
                        //asset[sspConstants.assetAddressFields.zipCode5] = "";
                    }
                }
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeDetails.bindAddressFields " +
                    JSON.stringify(error)
            );
        }
        return asset;
    }
    /*
     * @function    : hideToast
     * @description : Method to hide Toast
     */
    hideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error(
                "failed in sspIncomeDetails.hideToast " + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : disconnectedCallback
     * @description : This method is used to scroll to the top.
     */
    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
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
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === sspConstants.permission.notAccessible);
                }
                if (!this.isPageAccessible) {
                    this.showAccessDeniedComponent = true;
                } else {
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