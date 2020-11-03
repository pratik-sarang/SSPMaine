/**
 * Component Name: sspMemberLivingArrangement.
 * Author: Samridh Manucha , Saurabh Rathi.
 * Description: This screen takes living arrangement information for an applicant.
 * Date: JAN-22-2020.
 */

import { api, track, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import  utility,{ formatLabels, getYesNoOptions } from "c/sspUtility";
import IN_HOSPITALIZATION_START_DATE from "@salesforce/schema/SSP_Member__c.HospitalizationStartDate__c";
import IN_HOSPITALIZATION_END_DATE from "@salesforce/schema/SSP_Member__c.HospitalizationEndDate__c";
import IN_HOME_CARE_TYPE from "@salesforce/schema/SSP_Member__c.InHomeCareType__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import constants from "c/sspConstants";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import sspLoadingIcon from "@salesforce/resourceUrl/sspLoadingIcon";
import fetchAccountInformation from "@salesforce/apex/SSP_LivingArrangementController.fetchAccountInformation";
import fetchInstitutionInformation from "@salesforce/apex/SSP_LivingArrangementController.fetchInstitutionInformation";
import fetchRole from "@salesforce/apex/SSP_LivingArrangementController.fetchRoleType";
import getTimeTravelDate from "@salesforce/apex/SSP_Utility.today";
import completeRequiredQuestions from "@salesforce/label/c.SSP_CompleteRequiredQuestions";
import currentLivingSituation from "@salesforce/label/c.SSP_CurrentLivingSituation";
import dailyMeals from "@salesforce/label/c.SSP_DailyMeals";
import prisonStartDate from "@salesforce/label/c.SSP_PrisonStartDate";
import decisionOnCharges from "@salesforce/label/c.SSP_DecisionOnCharges";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import expectedReturnDate from "@salesforce/label/c.SSP_ExpectedReturnDate";
import organizationProviderName from "@salesforce/label/c.SSP_OrganizationProviderName";
import livingSituationTitle from "@salesforce/label/c.SSP_LivingSituationTitle";
import chooseOneMissing from "@salesforce/label/c.SSP_ChooseOneMissing";
import organizationSearchTitle from "@salesforce/label/c.SSP_OrganizationSearchTitle";
import selectButtonText from "@salesforce/label/c.SSP_SelectButtonText";
import selectButtonTitle from "@salesforce/label/c.SSP_SelectButtonTitle";
import cancelButtonText from "@salesforce/label/c.SSP_CancelButtonText";
import cancelSearchText from "@salesforce/label/c.SSP_CancelSearchText";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import currentSituationHelpText from "@salesforce/label/c.SSP_CurrentSituationHelpText";
import organizationSearchProvider from "@salesforce/label/c.SSP_OrganizationSearchProvider";
import CURRENT_LIVING_SITUATION from "@salesforce/schema/SSP_Member__c.LaTypeCode__c";
import DAILY_MEALS from "@salesforce/schema/SSP_Member__c.HasRecievedHalfMealsFrmInstToggle__c";
import WAITING_FOR_DECISION from "@salesforce/schema/SSP_Member__c.IsWaitingForDecisionToggle__c";
import INCARCERATION_BEGIN_DATE from "@salesforce/schema/SSP_Member__c.IncarcerationBeginDate__c";
import DCID_LIVING_ARRANGEMENT from "@salesforce/schema/SSP_Member__c.DCMemberLivingArrangementId__c";
import MEMBER_INDIVIDUALID from "@salesforce/schema/SSP_Member__c.IndividualId__c";
import DC_CASENUMBER from "@salesforce/schema/SSP_Application__c.DCCaseNumber__c";
import EXPECTED_RETURN_DATE from "@salesforce/schema/SSP_Member__c.ExpectedReturnDate__c";
import ORGANIZATION_NAME from "@salesforce/schema/SSP_Member__c.OrganizationName__c";
import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import UTILITY_EXPENSE from "@salesforce/schema/SSP_Member__c.HasUtilityExpenseToggle__c";
import SHELTER_EXPENSE from "@salesforce/schema/SSP_Member__c.HasShelterExpenseToggle__c";
import PROVIDER_ID from "@salesforce/schema/SSP_Member__c.ProviderId__c";
import PROVIDER_NAME from "@salesforce/schema/SSP_Member__c.ProviderName__c";
import sspTypeOfInHomeAssistance from "@salesforce/label/c.sspTypeOfInHomeAssistance";
import sspAltTypesOfInHomeAssistance from "@salesforce/label/c.sspAltTypesOfInHomeAssistance";
import sspSelectAnOption from "@salesforce/label/c.sspSelectAnOption";
import sspHospitalizationDetails from "@salesforce/label/c.sspHospitalizationDetails";
import sspHospitalizationStartDate from "@salesforce/label/c.sspHospitalizationStartDate";
import sspHospitalizationEndDate from "@salesforce/label/c.sspHospitalizationEndDate";
import getExpenseDetails from "@salesforce/apex/SSP_ApplicantAddressController.getExpenseDetails";
import checkOverlappingDate from "@salesforce/apex/SSP_MemberService.checkOverlappingDate";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspLivingArrangementOverlappingDateValidator from "@salesforce/label/c.SSP_AlreadyHaveLivingArrangement";

export default class SspMemberLivingArrangement extends BaseNavFlowPage {
    @api memberId;
    @api applicationId;
    @api mode;
    @api individualRecordTypeId;
    @api organizationRecordTypeId;
    @track currentSituationValues;
    @track currentLivingSituation;
    @track wiredRecordForRefresh;
    @track wiredAppRecord;
    @track showHospitalizationDates = false;
    @track showReturnDate;
    @track showDailyMeals;
    @track showIncarceration;
    @track showOrganization;
    @track shelterExpense;
    @track utilityExpense;
    @track providerId;
    @track providerName;
    @track firstName = "";
    @track toggleOptions = getYesNoOptions();
    @track showOrganizationModal = false;
    @track showAddressModal = false;
    @track showAddressListing = false;
    @track requiredReturn = false;
    @track organizationName = "";
    @track inputValue = "";
    @track laTypeCode = "";
    @track organizations = [];
    @track showSpinner = false;
    @track showPageSpinner = false;
    @track fieldName;
    @track institution = "";
    @track timeTravelDate;
    @track MetaDataListParent;
    @track hospitalizationStartDate;
    @track hospitalizationEndDate;
    @track inHomeCareType;
    @track showInHome = false;
    @track assetList;
    @track sOverlappingDateErrorMsg = "";
    @track trueValue = true;
    @track label = {
        toastErrorText,
        sspNoResultsFound,
        sspCancel,
        completeRequiredQuestions,
        currentLivingSituation,
        dailyMeals,
        prisonStartDate,
        decisionOnCharges,
        expectedReturnDate,
        organizationProviderName,
        livingSituationTitle,
        chooseOneMissing,
        organizationSearchProvider,
        organizationSearchTitle,
        selectButtonText,
        selectButtonTitle,
        cancelButtonText,
        cancelSearchText,
        currentSituationHelpText,
        sspTypeOfInHomeAssistance,
        sspAltTypesOfInHomeAssistance,
        sspSelectAnOption,
        sspHospitalizationDetails,
        sspHospitalizationStartDate,
        sspHospitalizationEndDate,
        sspLivingArrangementOverlappingDateValidator
    };
    @track updateRecord = {};
    @track reference = this;
    @track homeAssistanceValue;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track hasSaveValidationError = false;
    loadingSpinner = sspLoadingIcon + constants.url.spinner;
    helpIconFlag = true;
    fieldList = [
        CURRENT_LIVING_SITUATION,
        DAILY_MEALS,
        WAITING_FOR_DECISION,
        INCARCERATION_BEGIN_DATE,
        EXPECTED_RETURN_DATE,
        ORGANIZATION_NAME,
        UTILITY_EXPENSE,
        SHELTER_EXPENSE,
        PROVIDER_NAME,
        PROVIDER_ID,
        FIRST_NAME,
        IN_HOME_CARE_TYPE,
        IN_HOSPITALIZATION_START_DATE,
        IN_HOSPITALIZATION_END_DATE,
        DCID_LIVING_ARRANGEMENT,
        MEMBER_INDIVIDUALID
    ];

    applicationFieldList = [
        DC_CASENUMBER
    ];

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in hideToast on Living arrangement screen" + JSON.stringify(error)
            );
        }
    };

    /**
     * @function - objectInfo.
     * @description - This method is used to get INDIVIDUAL record type for SSP Member.
     *
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
                    "Error occurred while fetching record type in living arrangement screen" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "Error occurred while fetching record type in living arrangement screen" +
                    error
            );
        }
    }
    /**
     * @function - getPicklistValues.
     * @description - This method is used to get values of In home care type picklist.
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: IN_HOME_CARE_TYPE
    })
    inHomeCareTypePickListValues ({ data, error }) {
        if (data) {
            this.inHomeCareType = data.values;
        }
        if (error) {
            console.error(
                `Error Occurred while fetching picklist inHomeCareTypeListValues of In-home assistance page ${error}`
            );
        }
    }
    /**
     * @function - currentSituationPickListValues().
     * @description - This method is used to get picklist values for current living situation type field.
     *
     */
    @wire(getPicklistValues, {
        recordTypeId: "$individualRecordTypeId",
        fieldApiName: CURRENT_LIVING_SITUATION
    })
    currentSituationPickListValues ({ data, error }) {
        try {
            if (data) {
                this.currentSituationValues = data.values;
                this.conditionalCheck();
            }
            if (error) {
                console.error(
                    `Error Occurred while fetching currentSituationPickListValues picklist of Member Living Arrangements page ${error}` +
                        JSON.stringify(error)
                );
            }
        } catch (error) {
            console.error(
                "Error in wire call currentSituationPickListValues:",
                error
            );
        }
    }

    @wire(getTimeTravelDate)
    getTodayDate ({ error, data }) {
        try {
            if (data) {
                this.timeTravelDate = data;
            } else if (error) {
                console.error(JSON.parse(JSON.stringify(error)));
            }
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    @wire(getRecord, {
        recordId: "$applicationId",
        fields: "$applicationFieldList"
    })
    wiredGetApplicationRecord (response) {
        try {
            this.wiredAppRecord = response;
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: "$fieldList"
    })
    wiredGetRecord (response) {
        try {
            this.wiredRecordForRefresh = response;
            if (response.data) {
                this.firstName = getFieldValue(response.data, FIRST_NAME);
                this.currentLivingSituation = getFieldValue(
                    response.data,
                    CURRENT_LIVING_SITUATION
                );
                if(this.currentLivingSituation !== undefined && this.currentLivingSituation !== null &&
                    this.currentLivingSituation === "IH"){
                        this.showInHome = true;
                    }
                this.homeAssistanceValue = getFieldValue(
                    response.data,
                    IN_HOME_CARE_TYPE
                );
                this.hospitalizationStartDate = getFieldValue(
                    response.data,
                    IN_HOSPITALIZATION_START_DATE
                );
                this.hospitalizationEndDate = getFieldValue(
                    response.data,
                    IN_HOSPITALIZATION_END_DATE
                );
                this.providerName = getFieldValue(response.data, PROVIDER_NAME);
                this.institution = this.providerName;
                if (this.providerName == null) {
                    this.organizationName = getFieldValue(
                        response.data,
                        ORGANIZATION_NAME
                    );
                }
                this.shelterExpense = getFieldValue(
                    response.data,
                    SHELTER_EXPENSE
                );
                this.providerId = getFieldValue(response.data, PROVIDER_ID);
                this.utilityExpense = getFieldValue(
                    response.data,
                    UTILITY_EXPENSE
                );
                this.updateRecord[DAILY_MEALS.fieldApiName] = getFieldValue(
                    response.data,
                    DAILY_MEALS
                );
                this.updateRecord[
                    WAITING_FOR_DECISION.fieldApiName
                ] = getFieldValue(response.data, WAITING_FOR_DECISION);

                this.updateRecord[
                    INCARCERATION_BEGIN_DATE.fieldApiName
                ] = getFieldValue(response.data, INCARCERATION_BEGIN_DATE);
                this.updateRecord[
                    EXPECTED_RETURN_DATE.fieldApiName
                ] = getFieldValue(response.data, EXPECTED_RETURN_DATE);
                this.updateLabel();
                this.conditionalCheck();
            } else if (response.error) {
                console.error("Error in wiredGetRecord", response.error);
            }
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    @wire(fetchInstitutionInformation, {
        institutionId: "$organizationName"
    })
    wiredGetRecordInstitution (value) {
        try {
            if (
                value.data &&
                value.data.mapResponse &&
                value.data.mapResponse.instituteName
            ) {
                this.institution = value.data.mapResponse.instituteName;
            }
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    @wire(fetchRole)
    wiredGetRole (value) {
        try {
            if (
                value.data &&
                value.data.mapResponse &&
                value.data.mapResponse.ShowHospitalizationDates
            ) {
                this.showHospitalizationDates = true;
            }
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    @wire(getExpenseDetails, {
        memberId: "$memberId"
    })
    wiredExpenseRecords (value) {
        const { error, data } = value;
        try {
            if (data) {               
                const expenseData = data.mapResponse.assetsList;                
                this.assetList = expenseData;
            }
        } catch (e) {
            console.error(error);
        }
    }

    /*
     * @function - memberAccountValues().
     * @description - This method is used to call apex method to get account details.
     * @param {JSON} value - Result of "fetchAccountInformation" method call.
     */
    fetchOrganizationData (inputValue, laTypeCode) {
        fetchAccountInformation({
            institutionName: inputValue,
            livingArrangement: laTypeCode
        })
            .then(value => {
                if (
                    value &&
                    value.mapResponse &&
                    value.mapResponse.organizationName
                ) {
                    this.showAddressListing =
                        value.mapResponse.organizationName.length > 0
                            ? true
                            : false;
                    this.organizations = value.mapResponse.organizationName;
                } else {
                    this.showAddressListing = false;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(
                    "Error in wire call fetchAccountInformation:",
                    error
                );
            });
    }

    /*memberAccountValues (value) {
        try {
            
        } catch (error) {
            console.error("Error in wire call fetchAccountInformation:", error);
        }
    }*/

    /**
     * @function handleInputChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleInputChange (event) {
        try {
            const fieldName = event.target.fieldName;
            this.updateRecord[fieldName] = event.target.value;
            if(event.target.value === "IH"){
            this.showInHome = true;
            }else{
                this.showInHome = false;   
            }
            if (fieldName === CURRENT_LIVING_SITUATION.fieldApiName) {
                this.currentLivingSituation = event.target.value;               
                this.updateRecord[DAILY_MEALS.fieldApiName] = "";
                this.updateRecord[INCARCERATION_BEGIN_DATE.fieldApiName] = "";
                this.updateRecord[EXPECTED_RETURN_DATE.fieldApiName] = "";
                this.updateRecord[ORGANIZATION_NAME.fieldApiName] = "";
                this.institution = "";
                if (this.currentLivingSituation) {this.conditionalCheck();}
            }
            this.sOverlappingDateErrorMsg = "";
            const incBeginDateInput = this.template.querySelector(".ssp-incBeginDate");
            incBeginDateInput.classList.remove("has-overlapping-error");
        } catch (error) {
            console.error(
                "Error in handleInputChange of Living Arrangement page",
                error
            );
        }
    }
    /**
     * @function handleInputChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleInHomeInputChange (event) {
        try {
            const fieldName = event.target.fieldName;
            this.updateRecord[fieldName] = event.target.value;
            if (fieldName === IN_HOME_CARE_TYPE.fieldApiName) {
                this.homeAssistanceValue = event.target.value;
            }
        } catch (error) {
            console.error(
                "Error in handleInputChange of Living Arrangement page",
                error
            );
        }
    }
    /**
     * @function handleStartDateChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleStartDateChange (event) {
        try {
            const fieldName = event.target.fieldName;
            this.updateRecord[fieldName] = event.target.value;
            if (fieldName === IN_HOSPITALIZATION_START_DATE.fieldApiName) {
                this.hospitalizationStartDate = event.target.value;
            }
        } catch (error) {
            console.error(
                "Error in handleInputChange of Living Arrangement page",
                error
            );
        }
    }
    /**
     * @function handleEndDateChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleEndDateChange (event) {
        try {
            const fieldName = event.target.fieldName;
            this.updateRecord[fieldName] = event.target.value;
            if (fieldName === IN_HOSPITALIZATION_END_DATE.fieldApiName) {
                this.hospitalizationEndDate = event.target.value;
            }
        } catch (error) {
            console.error(
                "Error in handleInputChange of Living Arrangement page",
                error
            );
        }
    }

    /**
     * @function closeModal
     * @description Hide the modal.
     */
    closeModal = () => {
        this.showOrganizationModal = false;
    };

    /**
     * @function conditionalCheck
     * @description Checks the condition based on the response of living situation dropdown.
     */
    conditionalCheck () {
        try {        
            if (this.currentLivingSituation && constants.livingArrangement) {
                this.showDailyMeals = constants.livingArrangement.dailyMealCondition.includes(
                    this.currentLivingSituation
                );
                this.showIncarceration = constants.livingArrangement.incarcerationCondition.includes(
                    this.currentLivingSituation
                );
                this.showOrganization = constants.livingArrangement.organizationCondition.includes(
                    this.currentLivingSituation
                );
                this.showReturnDate = constants.livingArrangement.returnCondition.includes(
                    this.currentLivingSituation
                );
                this.requiredReturn = constants.livingArrangement.returnRequiredCondition.includes(
                    this.currentLivingSituation
                );
                const element = this.template.querySelector(
                    ".ssp-returnDateElement"
                );
                const entityMappingClone = JSON.parse(
                    JSON.stringify(this.MetaDataListParent || {})
                );
                if (
                    element &&
                    entityMappingClone["ExpectedReturnDate__c,SSP_Member__c"]
                ) {
                    const entity =
                        entityMappingClone[
                            "ExpectedReturnDate__c,SSP_Member__c"
                        ];
                    if (entity) {
                        entity[
                            "Input_Required__c"
                        ] = constants.livingArrangement.organizationRequiredCondition.includes(
                            this.currentLivingSituation
                        );
                    }
                    this.MetaDataListParent = entityMappingClone;
                    element.ErrorMessageList = [];
                }
            }
        } catch (error) {
            console.error(
                "Error in conditionalCheck of Living Arrangement page",
                error
            );
        }
    }

    /**
     * @function - renderedCallback.
     * @description : This method is called after html is rendered.
     */
    renderedCallback () {
        const returnDateReference = this.template.querySelector(
            ".ssp-returnDateElement"
        );
        if (returnDateReference && (this.requiredReturn || returnDateReference.value )) {
            returnDateReference.classList.add("ssp-applicationInputs");
        }
    }

    /**
     * @function - MetadataList().
     * @description - MetadataList getter method for framework.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    /**
     * @function - MetadataList().
     * @description - Next Event setter method for framework.
     * @param {string} value - Setter for MetadataList framework property.
     */
    set MetadataList (value) {
        if (value) {
            this.MetaDataListParent = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0){
                this.constructRenderingMap(null, value); 
            }
        }
    }

    /**
     * @function - nextEvent().
     * @description - Next Event getter method for framework.
     */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    /**
     * @function - nextEvent().
     * @description - Next Event setter method for framework.
     * @param {string} value - Setter for Next Event framework property.
     */
    set nextEvent (value) {
        try {
            if (!BaseNavFlowPage.isUndefinedOrNull(value) && value !== "") {
                this.nextValue = value;
                this.checkInputValidation();
            }
        } catch (e) {
            console.error("Error in nextEvent", e);
        }
    }

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            const livingArrangementInfo = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            this.templateInputsValue = Array.from(livingArrangementInfo);
            const revRules = [];
            const listMemberId = [];
            listMemberId.push(this.memberId);
            const self = this;
            let hasUtilityExpense =
                this.utilityExpense === constants.toggleFieldValue.yes;          
            let hasShelterExpense =
                this.shelterExpense === constants.toggleFieldValue.yes;           
            let existingData;
            const expenseData = this.assetList;
            expenseData.forEach(function (item) {
                           
                if (item.IsExistingData__c) {
                    existingData = true;
                }
                if(item.ExpenseTypeCode__c === "UE"){
                    hasUtilityExpense = true;
                }
                if(item.ExpenseTypeCode__c === "SE"){
                    hasShelterExpense = true;
                }
            });
         
           
            livingArrangementInfo.forEach(function (key) {
                if (key.fieldName === "LaTypeCode__c") {
                    
                    if (
                        key.oldValue &&
                        key.value &&
                        key.oldValue !== key.value
                    ) {
                                             
                        if (hasUtilityExpense || hasShelterExpense) {                            
                            revRules.push(
                                "hasExpensesRule," + true + "," + listMemberId
                            );                            
                            if (existingData) {
                                revRules.push(
                                    "hasExistingExpensesRule," +
                                        true +
                                        "," +
                                        listMemberId
                                );
                            }   
                          
                        }                        
                        if (!hasUtilityExpense || !hasShelterExpense) {
                            //constants.applicationMode.RAC
                           
                            if(self.mode === "RAC"){
                                revRules.push("noExpensesRuleRAC,"+true+","+listMemberId);
                            }
                            else{
                                revRules.push("noExpensesRule,"+true+",null");
                            }                                                            
                        }
                        
                    }
                }
            });
            
            this.reviewRequiredList = revRules;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Living Arrangement page",
                e
            );
        }
    };

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
            this.validationFlag = value;
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value) && this.showIncarceration) {
                this.getOverlappingServiceData(value);
            }else if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.saveLivingArrangementData();
            }
        } catch (e) {
            console.error("Error in set allowSaveData of Living Arrangement page",e);
        }
    }

    /**
     * @function :  saveLivingArrangementData
     * @description : This method is used to save Living Arrangement information.
     */
    saveLivingArrangementData = () => {
        try {
            if (this.memberId) {
                this.updateRecord.Id = this.memberId;
                updateRecord({ fields: this.updateRecord }).then(
                    () => {
                        this.showSpinner = false;
                        this.saveCompleted = true;
                    },
                    error => console.error("Error in saving: ", error)
                );
            }
        } catch (e) {
            console.error(
                "Error in saveLivingArrangementData of Living Arrangement page",
                e
            );
        }
    };

    /**
     * @function : connectedCallback
     * @description : This method is called when html is attached to the component.
     */
    connectedCallback () {
        try {
            const fieldList = this.fieldList.map(field =>
                [field.fieldApiName, field.objectApiName].join(",")
            );            
            this.getMetadataDetails(
                fieldList,
                null,
                "SSP_APP_Details_LivingArrangement"
            );
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    /**
     * @function : updateLabel
     * @description : This method is used for updating  the data in the label.
     */
    updateLabel () {
        try {
            this.label.currentLivingSituation = formatLabels(
                this.label.currentLivingSituation,
                [this.firstName]
            );
            this.label.dailyMeals = formatLabels(this.label.dailyMeals, [
                this.firstName
            ]);
            this.label.decisionOnCharges = formatLabels(
                this.label.decisionOnCharges,
                [this.firstName]
            );
            this.label.sspTypeOfInHomeAssistance = formatLabels(
                this.label.sspTypeOfInHomeAssistance,
                [this.firstName]
            );
        } catch (error) {
            console.error(
                "Error in set updateLabel of Living Arrangement page",
                error
            );
        }
    }

    /**
     * @function : organizationModal
     * @description : This method is used for updating  the data in the label.
     */
    organizationModal () {
        try {
            this.showOrganizationModal = true;
            this.inputValue = "";
        } catch (error) {
            console.error(
                "Error in set organizationModal of Living Arrangement page",
                error
            );
        }
    }

    /**
     * @function : selectAddressButtonFunction
     * @description : This method is used for selecting the address and closing the modal.
     * @param {*} event - This event provides access to element.
     */
    selectAddressButtonFunction (event) {
        try {
            const addressId = event.target.closest(".ssp-organizationListCard")
                .dataset.id;
            const selectedOrganization = this.organizations.filter(
                value => value.organizationId === addressId
            )[0];
            this.showAddressListing = false;
            this.showOrganizationModal = false;
            if(selectedOrganization.isService){
                this.updateRecord[PROVIDER_ID.fieldApiName] = parseInt(selectedOrganization.organizationId);
                this.updateRecord[PROVIDER_NAME.fieldApiName] = selectedOrganization.organizationName;
                this.updateRecord[ORGANIZATION_NAME.fieldApiName] = null;
            }
            else{
                this.updateRecord[ORGANIZATION_NAME.fieldApiName] = addressId;                
                this.updateRecord[PROVIDER_NAME.fieldApiName] = "";
                this.updateRecord[PROVIDER_ID.fieldApiName] = "";
            }
            this.institution = selectedOrganization.organizationName;            
            this.template.querySelector(
                ".ssp-organizationInput"
            ).value = this.institution;
            this.template
                .querySelector(".ssp-organizationInput")
                .ErrorMessages();

            this.render();
        } catch (error) {
            console.error(
                "Error in set selectAddressButtonFunction of Living Arrangement page",
                error
            );
        }
    }

    /**
     * @function : handleCloseAddressModal
     * @description : This method is used to close the modal.
     */
    handleCloseAddressModal () {
        this.showOrganizationModal = false;
        this.showAddressListing = false;
    }

    /**
     * @function : handleSearchInput
     * @description : This method is used to select a div.
     *   @param {*} event - This event returns particular class.
     */
    handleSearchInput (event) {
        try {
            const isEnterKey = event.keyCode === 13;
            const inputValue = this.template.querySelector(".ssp-searchBox")
                .value;
            const laTypeCode = this.template.querySelector(".ssp-laTypeCode")
                .value;
            if (
                this.inputValue !== inputValue.trim() &&
                (isEnterKey ||
                    event.target.classList.contains("ssp-searchIcon"))
            ) {
                this.inputValue = inputValue;
                this.laTypeCode = laTypeCode;
                this.showSpinner = true;
                this.fetchOrganizationData (this.inputValue, this.laTypeCode);
            }
        } catch (error) {
            console.error(
                "Error in set handleSearchInput of Living Arrangement page",
                error
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
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === constants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
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

    /**
   * @function - getOverlappingServiceData.
   * @description - This method is used to check the Overlapping dates for Living Arrangement of type Incarcerated.
   * @param {object} valueData - Value data.
   */
    getOverlappingServiceData = (valueData) => {
        this.showPageSpinner = true;
        try {
            const currentMemberData = this.wiredRecordForRefresh;
            const currentAppData = this.wiredAppRecord;
            const incBeginDateInput = this.template.querySelector(".ssp-incBeginDate");
            if (!utility.isUndefinedOrNull(currentMemberData) && !utility.isUndefinedOrNull(currentAppData)){
                const dcId = getFieldValue(currentMemberData.data, DCID_LIVING_ARRANGEMENT);
                const individualId = getFieldValue(currentMemberData.data, MEMBER_INDIVIDUALID);
                const identifier = "LivingArrangement";
                const startDate = this.updateRecord[INCARCERATION_BEGIN_DATE.fieldApiName];
                const caseNumber = getFieldValue(currentAppData.data, DC_CASENUMBER);
                const requestData = this.createOverlappingRequestData(dcId, identifier, startDate, null, individualId, this.applicationId, caseNumber);
                checkOverlappingDate({
                    sOverlappingRequest: JSON.stringify(requestData)
                })
                    .then(result => {
                        this.showPageSpinner = true;
                        if (result.bIsSuccess) {
                            const overlappingData = JSON.parse(result.mapResponse.overlappingDatesResponse)[0];
                            if (overlappingData !== undefined &&
                                overlappingData.IsDateOverLapping !== undefined &&
                                overlappingData.IsDateOverLapping) {
                                // eslint-disable-next-line no-shadow
                                this.sOverlappingDateErrorMsg = this.label.sspLivingArrangementOverlappingDateValidator.replace(
                                    "{0}",
                                    this.getFormattedDate(startDate)
                                );
                                incBeginDateInput.classList.add("has-overlapping-error");
                                this.hasSaveValidationError = true;
                                this.showPageSpinner = false;
                            } else if (valueData !== undefined && valueData !== "" || !overlappingData.IsDateOverLapping) {
                                this.sOverlappingDateErrorMsg = "";
                                incBeginDateInput.classList.remove("has-overlapping-error");
                                this.saveLivingArrangementData();
                            }
                        } else if (result.bIsSuccess === false) {
                            console.error("Error occurred in getOverlappingServiceData of health condition page. " + result.mapResponse.ERROR);
                        }
                    })
                    .catch({});
            }
        } catch (error) {
            console.error("Error occurred in getOverlappingServiceData of health condition page" + JSON.stringify(error.message));
        }
    }

    /**
   * @function - createOverlappingRequestData().
   * @description - This method is used to set Overlapping request.
   * @param {*} dcId - Contains Dc Id.
   * @param {*} identifier - Contains identifier.
   * @param {*} startDate - Contains startDate.
   * @param {*} endDate - Contains endDate.
   * @param {*} individualId - Contains individualId.
   * @param {*} applicationId - Contains applicationId.
   * @param {*} caseNumber - Contains caseNumber.
   */
    createOverlappingRequestData (dcId, identifier, startDate, endDate, individualId, applicationId, caseNumber) {
        const requestData = {};
        try {
            requestData.dcId = dcId !== null && dcId !== undefined && dcId !== "" ? dcId : 0;
            requestData.identifier = identifier !== null && identifier !== undefined ? identifier : "";
            requestData.startDate = startDate !== null && startDate !== undefined ? startDate : "";
            requestData.endDate = endDate !== null && endDate !== undefined ? endDate : "";
            requestData.individualId = (individualId !== null && individualId !== undefined && individualId !== "") ? individualId : 0;
            requestData.applicationId = applicationId;
            requestData.caseNumber = caseNumber;
        } catch (error) {
            console.error("Error occurred in createOverlappingRequestData of Living Arrangement page" +JSON.stringify(error));
        }
        return requestData;
    }

    /**
    * @function - getFormattedDate().
    * @description - This method is used to set Overlapping request.
    * @param {givenDate} givenDate - Date.
    */
    getFormattedDate = (givenDate) => {
        try{
            const newDate = new Date(givenDate);
            const year = newDate.getFullYear();

            let month = (1 + newDate.getMonth()).toString();
            month = month.length > 1 ? month : "0" + month;

            let day = newDate.getDate().toString();
            day = day.length > 1 ? day : "0" + day;
            
            return month + "-" + day + "-" + year;
        } catch (error) {
            console.error("Error occurred in getFormattedDate of Living Arrangement page" + JSON.stringify(error));
        }
    }
}