/**
 * Component Name: sspExpensesSelection.
 * Author: Yathansh Sharma.
 * Description: This screen takes the input for Expense Selection gatepost questions.
 * Date: 11/12/2019.
 */

import { track, api, wire } from "lwc";
import baseNavFlowPage from "c/sspBaseNavFlowPage";




import fetchMemberList from "@salesforce/apex/SSP_ExpenseController.fetchMemberList";
import { refreshApex } from "@salesforce/apex";
import createRecords from "@salesforce/apex/SSP_ExpenseController.createRecords";

import sspIncomeSubsidiesSelectionErrorMsg from "@salesforce/label/c.SSP_IncomeSubsidiesSelErrMsg";
import sspNoteIncomeAndSubsidies from "@salesforce/label/c.SSP_NoteIncomeAndSubsidies";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspExpensesSelection from "@salesforce/label/c.SSP_ExpensesSelection";
import sspLearnMoreExpensesSelection from "@salesforce/label/c.SSP_LearnMoreExpensesSelection";
import sspCompleteTheQuestionsBelowAboutExpenses from "@salesforce/label/c.SSP_CompleteTheQuestionsBelowAboutExpenses";
import sspLearnMoreAboutDifferentTypeOfExpenses from "@salesforce/label/c.SSP_LearnMoreAboutDifferentTypeofExpenses";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspDoesAnyoneHaveShelterExpenses from "@salesforce/label/c.SSP_DoesAnyoneHaveShelterExpenses";
import sspDoesThisHouseholdHaveUtilityExpenses from "@salesforce/label/c.SSP_DoesThisHouseholdHaveUtilityExpenses";
import sspDoesAnyoneHaveHigherEducationExpenses from "@salesforce/label/c.SSP_DoesAnyoneHaveHigherEducationExpenses";
import sspDoesAnyoneHaveTaxDeductibleExpenses from "@salesforce/label/c.SSP_DoesAnyoneHaveTaxDeductibleExpenses";
import sspDoesAnyoneNeedHelpPayingMedicalBills from "@salesforce/label/c.SSP_DoesAnyoneNeedHelpPayingMedicalBills";
import sspDoesAnyonePayAlimony from "@salesforce/label/c.SSP_DoesAnyonePayAlimony";
import sspDoesAnyoneHaveMedicarePartDPremium from "@salesforce/label/c.SSP_DoesAnyoneHaveMedicarePartDPremium";
import sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior from "@salesforce/label/c.SSP_DoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior";
import sspDoesAnyonePayChildSupport from "@salesforce/label/c.SSP_DoesAnyonePayChildSupport";
import sspDoesAnyonePayForChildCareOrOtherDependentCare from "@salesforce/label/c.SSP_DoesAnyonePayForChildCareOrOtherDependentCare";
import sspSelectApplicableHouseholdMembers from "@salesforce/label/c.SSP_SelectApplicableHouseholdMembers";

import sspNeedHelpPayingMedicalBillsHelpText from "@salesforce/label/c.SSP_NeedHelpPayingMedicalBillsHelpText";
import sspHaveShelterExpensesHelpText from "@salesforce/label/c.SSP_HaveShelterExpensesHelpText";
import sspHaveUtilityExpensesHelpText from "@salesforce/label/c.SSP_HaveUtilityExpensesHelpText";
import sspHaveHigherEducationExpensesHelpText from "@salesforce/label/c.SSP_HaveHigherEducationExpensesHelpText";
import sspHaveTaxDeductibleExpensesHelpText from "@salesforce/label/c.SSP_HaveTaxDeductibleExpensesHelpText";
import sspPayAlimonyHelpText from "@salesforce/label/c.SSP_PayAlimonyHelpText";
import sspHaveMedicarePartPremiumHelpText from "@salesforce/label/c.SSP_HaveMedicarePartPremiumHelpText";
import sspHaveMedicalExpensesForSomeOneWhoIsSeniorCitizenHelpText from "@salesforce/label/c.SSP_HaveMedicalExpensesForSomeOneWhoIsSeniorCitizenHelpText";
import sspExpensesSelectionLearnTitle from "@salesforce/label/c.SSP_ExpensesSelectionLearnTitle"; 
import sspPayForChildCareHelpText from "@salesforce/label/c.SSP_PayForChildCareHelpText";
import programConstant from "c/sspConstants";
import sspUtility from "c/sspUtility";

//const pageInfoEditValue = "edit";

const programs = {
    MA: programConstant.programValues.MA,
    KT: programConstant.programValues.KT,
    SN: programConstant.programValues.SN,
    SS: programConstant.programValues.SS,
    DS: programConstant.programValues.DS,
    CC: programConstant.programValues.CC,
    KP: programConstant.programValues.KP
};

const sspYesOption = "yes";
const sspNoOption = "no";

export default class SspExpensesSelection extends baseNavFlowPage {
    @api memberId;
    @api sspApplicationId;

    @api
    get mode () {
        return this.modeValue;
    }
    set mode (value) {
        if (value !== undefined && value !== null) {
            this.modeValue = value;
        }
    }

    @track questionWrapperList = [];
    @track isLearnMoreModal = false;
    @track contactId;
    @track reference = this;
    @track showSpinner = false;
    setResult;

    modeValue = "";
    membersDataToCommit = {};
    oldValueMap = {};
    memberIdList = [];
    disabilityMatrix = {};

    customLabel = {
        sspNoteIncomeAndSubsidies,
        sspLearnMoreLink,
        sspYes,
        sspNo,
        sspDoesAnyoneHaveShelterExpenses,
        sspDoesThisHouseholdHaveUtilityExpenses,
        sspDoesAnyoneHaveHigherEducationExpenses,
        sspDoesAnyoneHaveTaxDeductibleExpenses,
        sspDoesAnyoneNeedHelpPayingMedicalBills,
        sspDoesAnyonePayAlimony,
        sspDoesAnyoneHaveMedicarePartDPremium,
        sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior,
        sspDoesAnyonePayChildSupport,
        sspDoesAnyonePayForChildCareOrOtherDependentCare,
        sspSelectApplicableHouseholdMembers,
        sspCompleteTheQuestionsBelowAboutExpenses,
        sspLearnMoreAboutDifferentTypeOfExpenses,
        sspExpensesSelection,
        sspLearnMoreExpensesSelection,
        sspNeedHelpPayingMedicalBillsHelpText,
        sspHaveShelterExpensesHelpText,
        sspHaveUtilityExpensesHelpText,
        sspHaveHigherEducationExpensesHelpText,
        sspHaveTaxDeductibleExpensesHelpText,
        sspPayAlimonyHelpText,
        sspHaveMedicarePartPremiumHelpText,
        sspHaveMedicalExpensesForSomeOneWhoIsSeniorCitizenHelpText,
        sspPayForChildCareHelpText,
        sspExpensesSelectionLearnTitle 
    };
    @track responseOptions = [
        { label: this.customLabel.sspYes, value: "yes" },
        { label: this.customLabel.sspNo, value: "no" }
    ];
    questionLabels = {
        sspDoesAnyoneNeedHelpPayingMedicalBills: "HasMedicalBillsToggle__c",
        sspDoesAnyoneHaveShelterExpenses: "HasShelterExpenseToggle__c",
        sspDoesThisHouseholdHaveUtilityExpenses: "HasUtilityExpenseToggle__c",
        sspDoesAnyoneHaveHigherEducationExpenses:
            "HaveHigherEducationExpenseToggle__c",
        sspDoesAnyoneHaveTaxDeductibleExpenses:
            "HasTaxDeductionsExpenseToggle__c",
        sspDoesAnyonePayAlimony: "HasAlimonyExpenseToggle__c",
        sspDoesAnyoneHaveMedicarePartDPremium:
            "HasMedicalExpensePartDToggle__c",
        sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior:
            "HasDisabledExpensesToggle__c",
        sspDoesAnyonePayChildSupport: "HasHouseholdPaidChildSupportToggle__c",
        sspDoesAnyonePayForChildCareOrOtherDependentCare:
            "HasDependentCareExpenseToggle__c"
    };
    helpTextLabels = {
        sspDoesAnyoneHaveShelterExpenses: sspHaveShelterExpensesHelpText,
        sspDoesThisHouseholdHaveUtilityExpenses: sspHaveUtilityExpensesHelpText,
        sspDoesAnyoneHaveHigherEducationExpenses: sspHaveHigherEducationExpensesHelpText,
        sspDoesAnyoneHaveTaxDeductibleExpenses: sspHaveTaxDeductibleExpensesHelpText,
        sspDoesAnyoneNeedHelpPayingMedicalBills: sspNeedHelpPayingMedicalBillsHelpText,
        sspDoesAnyonePayAlimony: sspPayAlimonyHelpText,
        sspDoesAnyoneHaveMedicarePartDPremium: sspHaveMedicarePartPremiumHelpText,
        sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior: sspHaveMedicalExpensesForSomeOneWhoIsSeniorCitizenHelpText,
        sspDoesAnyonePayForChildCareOrOtherDependentCare: sspPayForChildCareHelpText
    };
    questionBelongToMagiGroup = {
        sspDoesAnyoneHaveShelterExpenses: programConstant.medicaidTypes.NonMAGI,
        sspDoesThisHouseholdHaveUtilityExpenses: programConstant.medicaidTypes.NonMAGI,
        sspDoesAnyoneHaveMedicarePartDPremium:
            programConstant.medicaidTypes.NonMAGI,
        sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior:
            programConstant.medicaidTypes.NonMAGI,
        sspDoesAnyonePayChildSupport: programConstant.medicaidTypes.NonMAGI
    };
    //Removing MAGI check for tax question as per defect #364631 >> sspDoesAnyoneHaveTaxDeductibleExpenses:    programConstant.medicaidTypes.MAGI,

    ageRelatedQuestions = {
        sspDoesAnyoneHaveShelterExpenses: true,
        sspDoesThisHouseholdHaveUtilityExpenses: true,
        sspDoesAnyoneHaveHigherEducationExpenses: true,
        sspDoesAnyoneHaveTaxDeductibleExpenses: true
    };

    questionIdToProgramMapping = {
        sspDoesAnyoneHaveShelterExpenses: [programs.SN, programs.MA],
        sspDoesThisHouseholdHaveUtilityExpenses: [programs.SN, programs.MA],
        sspDoesAnyoneHaveHigherEducationExpenses: [programs.SN],
        sspDoesAnyoneHaveTaxDeductibleExpenses: [programs.MA],
        sspDoesAnyoneNeedHelpPayingMedicalBills: [programs.MA],
        sspDoesAnyonePayAlimony: [programs.KT],
        sspDoesAnyoneHaveMedicarePartDPremium: [programs.MA, programs.SN],
        sspDoesAnyoneHaveMedicalExpensesForSomeoneWhoIsSenior: [
            programs.MA,
            programs.SN
        ],
        sspDoesAnyonePayChildSupport: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC
        ],
        sspDoesAnyonePayForChildCareOrOtherDependentCare: [
            programs.SN,
            programs.KT
        ]
    };

    @track tempMemberList = [];
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	
    connectedCallback () {
        //construction of fieldEntityNameList to retrieve validation related metadata
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            "HasMedicalBillsToggle__c,SSP_Member__c",
            "HasDisabledExpensesToggle__c,SSP_Member__c",
            "HaveHigherEducationExpenseToggle__c,SSP_Member__c",
            "HasTaxDeductionsExpenseToggle__c,SSP_Member__c",
            "HasUtilityExpenseToggle__c,SSP_Member__c",
            "HasShelterExpenseToggle__c,SSP_Member__c",
            "HasAlimonyExpenseToggle__c,SSP_Member__c",
            "HasMedicalExpensePartDToggle__c,SSP_Member__c",
            "HasHouseholdPaidChildSupportToggle__c,SSP_Member__c",
            "HasDependentCareExpenseToggle__c,SSP_Member__c"
        );
        this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "SSP_APP_Select_Expenses"
        ); //calling base cmp method
    }

    /**
     * Framework related variables.
     */
    @track actionValue;
    @track nextValue;
    @track validationFlag;
    @track MetaDataListParent;
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                value !== null &&
                value !== undefined &&
                Object.keys(value).length > 0
            ) {
                this.MetaDataListParent = value;
                this.validationMetadataLoaded = true;
            }
        } catch (err) {
            console.error(err);
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value !== undefined && value !== "") {
                this.nextValue = value;
                this.saveData(); // use to check validations on component
                this.reviewRequiredLogic ();
            }
        } catch (err) {
            console.error(err);
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;
            if (value !== undefined && value !== "") {
                this.CallSaveOnValidation();
            }
        } catch (err) {
            console.error(err);
        }
    }

    @api
    CallSaveOnValidation () {
        this.handleSave();
    }

    @api pageAction;

    @track hasMedicalBillsMemberList = [];
    @track hasDisabledExpensesMemberList = [];
    @track haveHigherEducationExpenseMemberList = [];
    @track hasTaxDeductionsExpenseMemberList = [];
    @track hasUtilityExpenseMemberList = [];
    @track hasShelterExpenseMemberList = [];
    @track hasHouseholdPaidAlimonyMemberList = [];
    @track hasMedicalExpensePartDMemberList = [];
    @track hasHouseholdPaidChildSupportMemberList = [];
    @track hasDependentCareExpenseMemberList = [];

    /*
     * @function : saveData
     * @description : This method is used to select the values for each expense selection question.
     * @param
     */

    saveData () {
        //adding all input elements to base list for validation check
        const combinedInputComponents = [];
        this.validateMemberSelection();
        //fetch input components from current component
        const templateAppInputs = this.template.querySelectorAll(
            ".applicationInputs"
        );
        for (let i = 0; i < templateAppInputs.length; i++) {
            combinedInputComponents.push(templateAppInputs[i]);
        }

        this.templateInputsValue = combinedInputComponents; //setting base cmp attribute
    }

    

    /*
     * @function : questionWrapperSetter
     * @description : This method is used to fetch data from object and create a wrapper to display no screen.
     * @param {error, data}
     */
    // eslint-disable-next-line constructor-super
    @wire(fetchMemberList, {
        sspApplicationId: "$sspApplicationId",
        sMode: "$modeValue"
    })
    questionWrapperSetter (result) {
        /** CD2 2.5 Security Role Matrix and Program Access. */
        const parsedData = !sspUtility.isUndefinedOrNull(result.data) ? result.data.mapResponse : null;
        this.isReadOnlyUser = (!sspUtility.isUndefinedOrNull(parsedData) && !sspUtility.isUndefinedOrNull(parsedData.screenPermission) && parsedData.screenPermission == programConstant.permission.readOnly);
        this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.screenPermission != null && parsedData.screenPermission != undefined && parsedData.screenPermission == programConstant.permission.notAccessible) ? false : true; //CD2 2.5 Security Role Matrix and Program Access.
        this.showAccessDeniedComponent = !this.isScreenAccessible;
        /** */
        this.setResult = result;
        this.questionWrapperList = [];
        Object.keys(this.questionLabels).forEach(questionId => {
            const fieldAPI = this.questionLabels[questionId];
            const objAPI = "SSP_Member__c";
            let isResponseYes = null;
            let isDisableQuestion = null;
            const memberData = [];
            this.tempMemberList = [];
            if (result.data) {
                for (let i = 0; i < result.data.mapResponse.memberList.length; i++) {
                    if (
                        this.memberIdList.indexOf(
                            result.data.mapResponse.memberList[i].Id
                        ) === -1
                    ) {
                        this.memberIdList.push(
                            result.data.mapResponse.memberList[i].Id
                        );
                    }
                    let programsApplied = [];
                    if (
                        result.data.mapResponse.memberList[i]
                            .SSP_ApplicationIndividuals__r !== undefined &&
                            result.data.mapResponse.memberList[i]
                            .SSP_ApplicationIndividuals__r[0]
                            .ProgramsApplied__c !== undefined
                    ) {
                        programsApplied = result.data.mapResponse.memberList[
                            i
                        ].SSP_ApplicationIndividuals__r[0].ProgramsApplied__c.split(
                            ";"
                        );
                    }
                    const commonProgram = this.questionIdToProgramMapping[
                        questionId
                    ].filter(function (n) {
                        return programsApplied.indexOf(n) !== -1;
                    });
                    if (result.data.mapResponse.hasOwnProperty("memberDisabilityMatrix")){
                        this.disabilityMatrix = result.data.mapResponse.memberDisabilityMatrix;
                    }
                    if (commonProgram.length > 0) {
                        if(null!==result.data.mapResponse.memberList[i].Id && result.data.mapResponse.memberList[i].Id!==undefined){
                        const wrapperToPush = {
                            memberId: result.data.mapResponse.memberList[i].Id,
                            name:
                            result.data.mapResponse.memberList[i].FirstName__c +
                                " " +
                                result.data.mapResponse.memberList[i].LastName__c,
                            age: result.data.mapResponse.memberList[i].Age__c,
                            isChecked: false,
                            errorMsg: "",
                            className: "applicationInputs",
                            questionId: questionId,
                            fieldAPI: fieldAPI,
                            isDisabled:
                                this.isReadOnlyUser ||
                                (!sspUtility.isUndefinedOrNull(
                                    this.disabilityMatrix[
                                    result.data.mapResponse.memberList[
                                        i
                                    ].Id
                                    ]
                                ) &&
                                    this.disabilityMatrix[
                                        result.data.mapResponse.memberList[i].Id
                                    ].includes(fieldAPI))
                        };

                        const obj = result.data.mapResponse.memberList[i];
                        wrapperToPush.isChecked =obj[fieldAPI] === "Y" ? true : false;
                        isDisableQuestion = 
                            this.isReadOnlyUser || wrapperToPush.isDisabled === true ||
                            isDisableQuestion
                                ? true
                                : null;  
                        isResponseYes =
                            wrapperToPush.isChecked || isResponseYes
                                ? true
                                : obj[fieldAPI] === "N" ||
                                    isResponseYes === false
                                    ? false
                                    : null;
                     if(null!=result.data.mapResponse.removeMemberForShelterUtility 
                        && null!=result.data.mapResponse.removeMemberForShelterUtility[result.data.mapResponse.memberList[i].Id]
                        && result.data.mapResponse.removeMemberForShelterUtility[result.data.mapResponse.memberList[i].Id].includes(fieldAPI) )
                        { memberData.push("");//this member will not be displayed to shelter and utility question
                        }                       
                    else if (
                            commonProgram.length === 1 &&
                            commonProgram.includes(programs.MA) &&
                            this.questionBelongToMagiGroup[questionId] ===
                            result.data.mapResponse.memberList[i]
                                .SSP_ApplicationIndividuals__r[0]
                                .MedicaidType__c
                        ) {
                            this.tempMemberList.push(wrapperToPush);
                        } else if (
                            commonProgram.length > 1 ||
                            (commonProgram.length === 1 &&
                                !commonProgram.includes(programs.MA)) ||
                            (commonProgram.includes(programs.MA) &&
                                !this.questionBelongToMagiGroup[questionId])
                        ) {
                            this.tempMemberList.push(wrapperToPush);
                        }
                        this.constructOldValueMap(
                            wrapperToPush.memberId,
                            fieldAPI,
                            obj[fieldAPI]
                        );
                        }
                    }
                }
            } else {
                console.error(result.error);
            }
            const wrapperObj = {
                isVisible: true,
                memberList: this.tempMemberList,
                questionLabel: this.customLabel[questionId],
                questionId: questionId,
                fieldAPI: fieldAPI,
                objAPI: objAPI,
                errorMsg: "",
                responseValue: "",
                showMembers: false,
                metaValues: this.MetaDataListParent,
                isHelpText: this.helpTextLabels[questionId] ? true : false,
                helpTextContent: this.helpTextLabels[questionId]
                    ? this.helpTextLabels[questionId]
                    : ""
            };
            wrapperObj.isBasicCriteriaFulfilled = this.validateBasicCriteria(
                wrapperObj
            );
            if (isResponseYes) {
                wrapperObj.responseValue = sspYesOption;
                wrapperObj.showMembers = true;
            } else if (isResponseYes === false) {
                wrapperObj.responseValue = sspNoOption;
            }
            if(isDisableQuestion){
                wrapperObj.isDisabled=true; 
            }


            const greaterAgeMembers = this.tempMemberList.filter(
                obj => obj.age > 13
            );
            if (
                this.tempMemberList.length > 0 &&
                (!this.ageRelatedQuestions[questionId] ||
                    greaterAgeMembers.length > 0)
            ) {
                wrapperObj.isMemberField = true;
                this.questionWrapperList.push(wrapperObj);
            } else {
                wrapperObj.isMemberField = false;
                wrapperObj.isVisible = false;
            }
        });
    }

    determineQuestionDisability = (memberWrapperList, isMemberField, fieldAPI) => {        
        const disabilityMatrix = this.disabilityMatrix;
        let isDisabled = false;
        if (isMemberField && !sspUtility.isUndefinedOrNull(disabilityMatrix)){
            isDisabled = memberWrapperList.some(wrapper => !sspUtility.isUndefinedOrNull(wrapper.Id) && 
                                                            disabilityMatrix.hasOwnProperty(wrapper.Id) && 
                                                            (disabilityMatrix[wrapper.Id].includes(fieldAPI) && 
                                                            wrapper.isChecked)) ||  
                memberWrapperList.every(wrapper => !sspUtility.isUndefinedOrNull(wrapper.Id) &&
                    disabilityMatrix.hasOwnProperty(wrapper.Id) &&
                    (disabilityMatrix[wrapper.Id].includes(fieldAPI)));  

        }
        return isDisabled;
    };
    /**
     * @function : constructOldValueMap
     * @description	: Method to construct oldValue Map for member fieldAPI values.
     * @param {string} memberId - SF member id.
     * @param {string} fieldAPI - SF field api.
     * @param {string} value - Field value.
     */
    constructOldValueMap (memberId, fieldAPI, value) {
        try {
            const oldValueMap = this.oldValueMap;

            const tmpMap =
                oldValueMap[memberId] !== null &&
                    oldValueMap[memberId] !== undefined
                    ? oldValueMap[memberId]
                    : {};
            tmpMap[fieldAPI] = value;

            oldValueMap[memberId] = tmpMap;
            this.oldValueMap = oldValueMap;
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.constructOldValueMap " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : openLearnMoreModal
     * @description : This method is used to open the learn more modal.
     */
    openLearnMoreModal () {
        this.isLearnMoreModal = true;
    }

    /*
     * @function : questionWrapperSetter
     * @description : This method is used to close the learn more modal.
     */
    closeLearnMoreModal () {
        this.isLearnMoreModal = false;
    }

    /*
     * @function : manageQuestions
     * @description : This method will be executed when a change in the option of any question will occur.
     * @param event
     */
    manageQuestions (event) {
        const qIndex = event.target.getAttribute("data-qIndex");
        const index = parseInt(qIndex, 10);
        const tmpWrapperList = this.questionWrapperList;

        //if yes, set showMembers to true in order to show list of applicable members
        if (event.target.value.toLowerCase() === sspYesOption) {
            tmpWrapperList[index].responseValue = sspYesOption;
            tmpWrapperList[index].showMembers = tmpWrapperList[index]
                .isMemberField
                ? true
                : false;
            tmpWrapperList[index].errorMsg = "";
            //if yes, validate if one of applicable members is selected
            tmpWrapperList[
                index
            ].isBasicCriteriaFulfilled = this.validateBasicCriteria(
                tmpWrapperList[index]
            );
        } else {
            tmpWrapperList[index].responseValue = sspNoOption;
            tmpWrapperList[index].showMembers = false;
            //if no, set isBasicCriteriaFulfilled to true, as no members are to be selected in this case
            tmpWrapperList[index].isBasicCriteriaFulfilled = true;
            if (tmpWrapperList[index].isMemberField) {
                for (
                    let i = 0;
                    i < tmpWrapperList[index].memberList.length;
                    i++
                ) {
                    tmpWrapperList[index].memberList[i].isChecked = false;
                    this.constructDataToSave(
                        tmpWrapperList[index].memberList[i],
                        false
                    );
                }
            }
        }

        this.questionWrapperList = tmpWrapperList;

        //if field related to the question triggering the method is not related to SSP_Member__c, capture the related-selected details for saving
        if (!tmpWrapperList[index].isMemberField) {
            this.constructDataToSave(
                tmpWrapperList[index],
                event.target.value.toLowerCase() === sspYesOption ? true : false
            );
        }
    }

    /*
     * @function : constructDataToSave
     * @description : This method is used construct individual wrapper which will be passed to apex as a list to save.
     * @param targetMember
     * @param value
     */
    constructDataToSave (targetMember, value) {
        const membersDataToCommit = this.membersDataToCommit;
        const tmpMap =
            membersDataToCommit[targetMember.memberId] !== null &&
                membersDataToCommit[targetMember.memberId] !== undefined
                ? membersDataToCommit[targetMember.memberId]
                : {};
        tmpMap[targetMember.fieldAPI] = value;

        membersDataToCommit[targetMember.memberId] = tmpMap;
        this.membersDataToCommit = membersDataToCommit;
    }

    /*
     * @function : validateBasicCriteria
     * @description : This method is used to validate the true condition of a question before saving.
     * @param detailWrapper
     */
    validateBasicCriteria (detailWrapper) {
        let result = detailWrapper.isMemberField ? false : true;

        for (let i = 0; i < detailWrapper.memberList.length; i++) {
            if (detailWrapper.memberList[i].isChecked) {
                result = true;
                break;
            }
        }
        return result;
    }

    /*
     * @function : validateMemberSelection
     * @description : This method is used to validate at least one member is selected for a question with yes value.
     */
    validateMemberSelection () {
        const tmpWrapperList = this.questionWrapperList;
        for (let i = 0; i < tmpWrapperList.length; i++) {
            if (!tmpWrapperList[i].isBasicCriteriaFulfilled) {
                for (let j = 0; j < tmpWrapperList[i].memberList.length; j++) {
                    tmpWrapperList[i].memberList[
                        j
                    ].errorMsg = sspIncomeSubsidiesSelectionErrorMsg;
                }
                if (
                    tmpWrapperList[i].responseValue === sspYesOption ||
                    tmpWrapperList[i].responseValue === sspYesOption
                ) {
                    tmpWrapperList[
                        i
                    ].errorMsg = sspIncomeSubsidiesSelectionErrorMsg;
                }
            }
        }
        this.questionWrapperList = tmpWrapperList;
    }

    /*
     * @function : handleConditions
     * @description : Method to handle onchange event of member checkbox.
     * @param event
     */
    handleConditions (event) {
        let questionIndex = event.target.getAttribute("data-qIndex");
        let memberIndex = event.target.getAttribute("data-mIndex");
        questionIndex = parseInt(questionIndex, 10);
        memberIndex = parseInt(memberIndex, 10);
        const tmpWrapperList = this.questionWrapperList;
        const targetQuestion = tmpWrapperList[questionIndex];
        const targetMember = targetQuestion.memberList[memberIndex];
        //if member is checked, mark corresponding isChecked wrapper attribute to true
        if (event.target.value) {
            tmpWrapperList[questionIndex].memberList[
                memberIndex
            ].isChecked = true;
            //removing error message for all the members under that particular question
          tmpWrapperList[questionIndex].errorMsg = "";
            for (
                let i = 0;
                i < tmpWrapperList[questionIndex].memberList.length;
                i++
            ) {
                tmpWrapperList[questionIndex].memberList[i].errorMsg = "";
            }
        } else {
            //set isChecked to false if the member is deselected
            tmpWrapperList[questionIndex].memberList[
                memberIndex
            ].isChecked = false;
        }

        //based on the selection of member, determine if the selection criteria for that particular question is satisfied or not
        tmpWrapperList[
            questionIndex
        ].isBasicCriteriaFulfilled = this.validateBasicCriteria(
            tmpWrapperList[questionIndex]
        );
          if (!tmpWrapperList[questionIndex].isBasicCriteriaFulfilled){
            tmpWrapperList[questionIndex].errorMsg = sspIncomeSubsidiesSelectionErrorMsg;
        }

        this.constructDataToSave(targetMember, event.target.value);
    }

    /*
     * @function : identifyPositiveChangedValue
     * @description : Identify fields where value changed from false to true.
     * @param oldValueMap
     * @param recordId
     * @param fieldAPI
     * @param newValue
     */
    identifyPositiveChangedValue (oldValueMap, recordId, fieldAPI, newValue) {
        let result = false;
        if (
            oldValueMap !== null &&
            oldValueMap !== undefined &&
            oldValueMap[recordId] !== null &&
            oldValueMap[recordId] !== undefined            
        ) {

            const oldValue = oldValueMap[recordId][fieldAPI];
            if (
                (oldValue === null ||
                    oldValue === undefined ||
                    (oldValue !== null &&
                        oldValue !== undefined &&
                        oldValue.toLowerCase() !== "y")) &&
                newValue
            ) {
                result = true;
            }
            return result;
        }
        return result;
    }

    /*
     * @function : identifyNegativeChangedValue
     * @description : Identify fields where value changed from true to false.
     * @param oldValueMap
     * @param recordId
     * @param fieldAPI
     * @param newValue
     */
    identifyNegativeChangedValue (oldValueMap, recordId, fieldAPI, newValue) {
        let result = false;
        if (
            oldValueMap !== null &&
            oldValueMap !== undefined &&
            oldValueMap[recordId] !== null &&
            oldValueMap[recordId] !== undefined &&
            oldValueMap[recordId][fieldAPI] !== null &&
            oldValueMap[recordId][fieldAPI] !== undefined
        ) {
            const oldValue =
                oldValueMap[recordId][fieldAPI] === "Y" ? true : false;
            if (oldValue && !newValue) {
                result = true;
            }
        }else if( oldValueMap !== null &&
            oldValueMap !== undefined &&
            oldValueMap[recordId] !== null &&
            oldValueMap[recordId] !== undefined &&
            (oldValueMap[recordId][fieldAPI] === null ||
            oldValueMap[recordId][fieldAPI] === undefined) && 
        !newValue){
            result = true;
        }
        return result;
    }

    /**
     * @function : handleSave
     * @description : Method to construct records in the format expected by APEX.
     */
    handleSave () {
        this.showSpinner = true;
        const oldValueMap = this.oldValueMap;
        const changedValueMap = {};
        const changedValueMapNegative = {};
        const detailMap = {};
        const memberList = [];
        Object.keys(this.membersDataToCommit).forEach(key => {
            const entry = this.membersDataToCommit[key];
            const tmpList = key.split("##");
            const objWrapper = {};
            const tmpFieldList = [];
            const tmpFieldListNegative = [];
            changedValueMap[tmpList[0]] = [];
            changedValueMapNegative[tmpList[0]] = [];
            if (tmpList !== null && tmpList !== undefined) {
                objWrapper.Id = tmpList[0];
                Object.keys(entry).forEach(fieldAPI => {
                    objWrapper[fieldAPI] = entry[fieldAPI];
                    if (
                        this.identifyPositiveChangedValue(
                            oldValueMap,
                            tmpList[0],
                            fieldAPI,
                            entry[fieldAPI]
                        )
                    ) {
                        tmpFieldList.push(fieldAPI);
                    }

                    if (
                        this.identifyNegativeChangedValue(
                            oldValueMap,
                            tmpList[0],
                            fieldAPI,
                            entry[fieldAPI]
                        )
                    ) {
                        tmpFieldListNegative.push(fieldAPI);
                    }
                });
            }

            memberList.push(objWrapper);
            changedValueMap[tmpList[0]] = tmpFieldList;
            changedValueMapNegative[tmpList[0]] = tmpFieldListNegative;
        });

        if (memberList.length > 0) {
            detailMap.sspMembers = JSON.stringify(memberList);
        }

        this.saveDataToServer(
            detailMap,
            changedValueMap,
            changedValueMapNegative
        );
    }

    /*
     * @function : saveDataToServer
     * @description : Method to send data to server.
     * @param detailMap
     * @param changedValueMap
     * @param changedValueMapNegative
     */
    saveDataToServer (detailMap, changedValueMap, changedValueMapNegative) {
        this.showSpinner = true;
        let isChangedValueMapValid = false;
        let isChangedValueMapNegativeValid = false;
        const mParam = {
            dataJSON: JSON.stringify(detailMap),
            changedFieldsMap: {}
        };

        Object.keys(changedValueMap).forEach(sfId => {
            if (changedValueMap[sfId].length > 0) {
                isChangedValueMapValid = true;
            }
        });

        Object.keys(changedValueMapNegative).forEach(sfId => {
            if (changedValueMapNegative[sfId].length > 0) {
                isChangedValueMapNegativeValid = true;
            }
        });

        if (isChangedValueMapValid) {
            mParam.changedFieldsMap.falseToTrue = JSON.stringify(
                changedValueMap
            );
        }
        if (isChangedValueMapNegativeValid) {
            mParam.changedFieldsMap.trueToFalse = JSON.stringify(
                changedValueMapNegative
            );
        }
        mParam.sspApplicationId = this.sspApplicationId;
        //server call
        createRecords(mParam)
            .then(result => {
                /*if (this.mode !== "RAC") {
                    this.memberIdList.forEach(memberIdSingle => {
                        this.validateReviewRequiredRules(
                            this.sspApplicationId,
                            memberIdSingle,
                            ["SSP_APP_Select_Expenses"]
                        );
                    });
                }*/
                refreshApex(this.setResult);
                this.saveCompleted = true;
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
    }
    reviewRequiredLogic (){        
        const expenseQuestionList = this.template.querySelectorAll(".questionClass");        
        let addRule;
        const revRules = [];
        const self = this;
        expenseQuestionList.forEach( function (key){            
            if(key.oldValue !== key.value){
                if(key.value === sspNoOption){
                    addRule = true;
                }
                else{
                    addRule = false;
                }
            }
        });
        const expenseMembersList = this.template.querySelectorAll(".memberClass");
        const expMemberRRList = [];
        const expMemberRRNoList = [];               
        expenseMembersList.forEach(function (key){
            if(key.oldValue !== key.value){
                if(key.value === true){
                    if(!expMemberRRList.includes(key.getAttribute("data-member"))){
                        expMemberRRList.push(key.getAttribute("data-member"));
                    }                    
                }
                else{
                    if(!expMemberRRNoList.includes(key.getAttribute("data-member"))){
                        expMemberRRNoList.push(key.getAttribute("data-member"));
                    }
                }
            }             
            if(key.disabled === true && self.modeValue === "RAC"){
                if(!expMemberRRList.includes(key.getAttribute("data-member"))){
                    expMemberRRList.push(key.getAttribute("data-member"));
                } 
            }           
        });        
        if(expMemberRRList.length > 0){
            revRules.push(programConstant.reviewRequiredRules.expenseRule+","+true+","+expMemberRRList);
        }
        const updatedExpenseNoList = [];
        expMemberRRNoList.forEach(function (item){
            if(!expMemberRRList.includes(item)){
                updatedExpenseNoList.push(item);
            }
        });
        if(updatedExpenseNoList.length > 0){
            revRules.push(programConstant.reviewRequiredRules.expenseRule+","+false+","+updatedExpenseNoList);
        }        
        if(addRule){
            revRules.push(programConstant.reviewRequiredRules.expenseRule+","+false+","+this.memberIdList);
        }    
        this.reviewRequiredList = revRules;    
    }    
}