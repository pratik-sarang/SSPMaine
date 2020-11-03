/**
 * Component Name: sspIncomeAndSubsidesSelection.
 * Author: Shrikant Raut, Venkata Ranga Babu.
 * Description: Component for Income & Subsides Selection Screen.
 * Date: 11/19/2019.
 */
import { api, track } from "lwc";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import fetchIncomeSubsidiesDetails from "@salesforce/apex/SSP_IncomeAndSubsidiesSelController.fetchIncomeSubsidiesDetails";
import updateRecords from "@salesforce/apex/SSP_IncomeAndSubsidiesSelController.updateRecords";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import sspIncomeSubsidiesSelectionErrorMsg from "@salesforce/label/c.SSP_IncomeSubsidiesSelErrMsg";
import isReceivingHousingAssistance from "@salesforce/label/c.SSP_DoesThisHouseholdReceiveHousingAssistance";
import hasEarnedIncomeFromEmployment from "@salesforce/label/c.SSP_DoesAnyoneHaveIncomeFromEmployer";
import hasSelfEmploymentIncome from "@salesforce/label/c.SSP_DoesAnyoneHaveSelfEmploymentIncome";
import hasUnearnedIncome from "@salesforce/label/c.SSP_DoesAnyoneReceiveIncomeFromSocialSecurity";
import hasReceivedBenefitsFromOtherState from "@salesforce/label/c.SSP_DoesAnyoneReceiveMedicaidSNATANFBenefits";
import hasUnpaidEmployment from "@salesforce/label/c.SSP_IsAnyoneAnUnpaidEmployee";
import hasDividendsRoyalties from "@salesforce/label/c.SSP_DoesAnyoneReceiveIncomeFromDividends";
import hasMaintenanceIncome from "@salesforce/label/c.SSP_DoesAnyoneReceiveSupportOrMaintenanceIncome";
import hasInsuranceSettlementBenefit from "@salesforce/label/c.SSP_DoesAnyoneReceiveIncomeFromInsuranceSettlement";
import hasServicesorPayments from "@salesforce/label/c.SSP_DoesAnyoneReceiveOtherTypeOfGoodServices";
import sspSelectApplicableHouseholdMembers from "@salesforce/label/c.SSP_SelectApplicableHouseholdMembers";
import sspCompleteTheQuestionsBelowAboutIncomeSubsidies from "@salesforce/label/c.SSP_CompleteTheQuestionsBelowAboutIncomeSubsidies";
import sspNoteIncomeAndSubsidies from "@salesforce/label/c.SSP_NoteIncomeAndSubsidies";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import sspLearnMoreAboutDifferentTypeOfIncomeAndSubsidies from "@salesforce/label/c.SSP_LearnMoreAboutDifferentTypeofIncomeAndSubsidies";
import sspUtility, { formatLabels, getCurrentMonthName, getNextMonthName } from "c/sspUtility";
import sspReceiveHousingAssistanceHelpText from "@salesforce/label/c.SSP_ReceiveHousingAssistanceHelpText";
import sspReceiveSupportOrMaintenanceIncomeHelpText from "@salesforce/label/c.SSP_ReceiveSupportOrMaintenanceIncomeHelpText";
import sspReceiveAnyOtherTypeOfGoodHelpText from "@salesforce/label/c.SSP_ReceiveAnyOtherTypeOfGoodHelpText";
import sspReceiveMedicaidSNAPOrTANFBenefitsHelpText from "@salesforce/label/c.SSP_ReceiveMedicaidSNAPOrTANFBenefitsHelpText";
import sspHaveSelfEmploymentIncomeHelpText from "@salesforce/label/c.SSP_HaveSelfEmploymentIncomeHelpText";
import sspReceiveIncomeFromSocialSecurityHelpText from "@salesforce/label/c.SSP_ReceiveIncomeFromSocialSecurityHelpText";
import sspReceiveInterestFromDividendsHelpText from "@salesforce/label/c.SSP_ReceiveInterestFromDividendsHelpText";
import sspReceivedPaymentFromAnInsurancePaymentHelpText from "@salesforce/label/c.SSP_ReceivedPaymentFromAnInsurancePaymentHelpText";
import sspConstants from "c/sspConstants";
import sspIncomeSubsidiesLearnContent from "@salesforce/label/c.SSP_IncomeSubsidiesLearnContent";
import sspIncomeSubsidiesLearnTitle from "@salesforce/label/c.SSP_IncomeSubsidiesLearnTitle"; 
const programs = {
    MA: sspConstants.programValues.MA,
    KT: sspConstants.programValues.KT,
    SN: sspConstants.programValues.SN,
    SS: sspConstants.programValues.SS,
    DS: sspConstants.programValues.DS,
    CC: sspConstants.programValues.CC,
    KP: sspConstants.programValues.KP
};
export default class sspIncomeAndSubsidiesSelection extends baseNavFlowPage {
    @api applicationId;
    @api pageAction;

    oldValueMap = {};
    memberToProgramMapping = {};
    activeProgramList = []; //question Ids added if its edit flow and field value is true/member is selected
    nonAttendedQuestionList = []; //question Ids added if field is attended and answer is N
    membersDataToCommit = {};
    dataSaved = false;
    appLevelProgramList = [];
    modeValue = "";
    //add entry here if field belongs to object other than SSP_Member__c
    extraFields = {
        [sspConstants.sspMemberFields.IsReceivingHousingAssistance__c]:
            "SSP_Application__c"
    };
    detailWrapper = {
        isVisible: false,
        memberList: [],
        questionLabel: "",
        sfFieldAPI: "",
        errorMessage: "",
        responseValue: false
    };

    questionIdToProgramMapping = {
        isReceivingHousingAssistance: [programs.CC],
        hasEarnedIncomeFromEmployment: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasSelfEmploymentIncome: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasUnearnedIncome: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasDividendsRoyalties: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasMaintenanceIncome: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasInsuranceSettlementBenefit: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasServicesorPayments: [
            programs.MA,
            programs.SN,
            programs.KT,
            programs.CC,
            programs.SS
        ],
        hasUnpaidEmployment: [programs.CC],
        hasReceivedBenefitsFromOtherState: [
            programs.MA,
            programs.SN,
            programs.KT
        ]
    };

    disabilityMatrix = {};

    helpTextLabels = {
        isReceivingHousingAssistance: sspReceiveHousingAssistanceHelpText,
        hasSelfEmploymentIncome: sspHaveSelfEmploymentIncomeHelpText,
        hasUnearnedIncome: sspReceiveIncomeFromSocialSecurityHelpText,
        hasDividendsRoyalties: sspReceiveInterestFromDividendsHelpText,
        hasMaintenanceIncome: sspReceiveSupportOrMaintenanceIncomeHelpText,
        hasInsuranceSettlementBenefit: sspReceivedPaymentFromAnInsurancePaymentHelpText,
        hasServicesorPayments: sspReceiveAnyOtherTypeOfGoodHelpText,
        hasReceivedBenefitsFromOtherState: sspReceiveMedicaidSNAPOrTANFBenefitsHelpText
    };

    customLabel = {
        sspYes,
        sspNo,
        isReceivingHousingAssistance,
        hasEarnedIncomeFromEmployment,
        hasSelfEmploymentIncome,
        hasUnearnedIncome,
        hasReceivedBenefitsFromOtherState,
        hasUnpaidEmployment,
        hasDividendsRoyalties,
        hasMaintenanceIncome,
        hasInsuranceSettlementBenefit,
        hasServicesorPayments,
        sspSelectApplicableHouseholdMembers,
        sspCompleteTheQuestionsBelowAboutIncomeSubsidies,
        sspNoteIncomeAndSubsidies,
        sspLearnMoreLink,
        sspLearnMoreModalContent,
        sspLearnMoreAboutDifferentTypeOfIncomeAndSubsidies,
        sspReceiveHousingAssistanceHelpText,
        sspReceiveSupportOrMaintenanceIncomeHelpText,
        sspReceiveAnyOtherTypeOfGoodHelpText,
        sspReceiveMedicaidSNAPOrTANFBenefitsHelpText,
        sspHaveSelfEmploymentIncomeHelpText,
        sspReceiveIncomeFromSocialSecurityHelpText,
        sspReceiveInterestFromDividendsHelpText,
        sspReceivedPaymentFromAnInsurancePaymentHelpText,
        sspIncomeSubsidiesLearnContent, 
        sspIncomeSubsidiesLearnTitle 
    };

    @track timeTravelCurrentMonth;
    @track actionValue;
    @track nextValue;
    @track validationFlag;
    @track MetaDataListParent;

    //memberLists for questions
    @track showSpinner = true;
    @track isReceivingHousingAssistanceMemberList = [];
    @track hasEarnedIncomeFromEmploymentMemberList = [];
    @track hasSelfEmploymentIncomeMemberList = [];
    @track hasUnearnedIncomeMemberList = [];
    @track hasDividendsRoyaltiesMemberList = [];
    @track hasMaintenanceIncomeMemberList = [];
    @track hasInsuranceSettlementBenefitMemberList = [];
    @track hasServicesorPaymentsMemberList = [];
    @track hasUnpaidEmploymentMemberList = [];
    @track hasReceivedBenefitsFromOtherStateMemberList = [];
    @track isLearnMoreModal = false;
    @track detailQuestionWrapperList = [];
    @track memberList = [];
    @track responseOptions = [
        { label: sspYes, value: "yes" },
        { label: sspNo, value: "no" }
    ];
    @track reference = this;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	

    @api
    get mode () {
        return this.modeValue;
    }
    set mode (value) {
        if (value !== undefined && value !== "") {
            this.modeValue = value;
        }
    }
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (value !== undefined && value !== "") {
            this.nextValue = value;
            this.saveData(); // use to check validations on component
        }
    }

    @api
    get actionReceived () {
        return this.actionValue;
    }
    set actionReceived (value) {
        this.actionValue = value;
        if (value !== undefined && value !== "") {
            const btnClick = value.split(",")[1];
            const loadValue = value.split(",")[2];
            if (btnClick === "next" && loadValue) {
                this.saveData();
            } else {
                this.onRecordSaveSuccess(this.applicationId);
            }
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (value !== undefined && value !== "") {
            this.CallSaveOnValidation();
        }
    }

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
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.MetadataList " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : saveData
     * @description	: Method triggered on next from framework component
     */
    saveData () {
        try { 
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
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.saveData " +
                JSON.stringify(error)
            );
        }
    }

    @api
    CallSaveOnValidation () {
        try {
            this.handleSave();
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.CallSaveOnValidation " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : connectedCallback
     * @description	: Triggered to set field API's related to validation framework
     */
    connectedCallback () {
        //construction of fieldEntityNameList to retrieve validation related metadata
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "HasDividendsRoyaltiesToggle__c,SSP_Member__c",
                "HasEarnedIncomeFromEmploymentToggle__c,SSP_Member__c",
                "HasInsuranceSettlementBenefitToggle__c,SSP_Member__c",
                "HasMaintenanceIncomeToggle__c,SSP_Member__c",
                "HasReceivedBenefitsFromOtherStateToggle__c,SSP_Member__c",
                "HasSelfEmploymentIncomeToggle__c,SSP_Member__c",
                "HasServicesorPaymentsToggle__c,SSP_Member__c",
                "HasUnearnedIncomeToggle__c,SSP_Member__c",
                "HasUnpaidEmploymentToggle__c,SSP_Member__c",
                "IsReceivingHousingAssistanceToggle__c,SSP_Application__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Select_Income"
            ); //calling base cmp method
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.connectedCallback " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     * @param {object} event - Onclick JS event.
     */
    openLearnMoreModal (event) {
        if (event.keyCode === 13 || event.type === "click") {
            this.isLearnMoreModal = true;
        }
    }

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal () {
        this.isLearnMoreModal = false;
    }

    /**
     * @function : manageQuestions
     * @description	: Method to handle onchange event of question toggle button.
     * @param {object} event - JS event.
     */
    manageQuestions (event) {
        try {
            const qIndex = event.target.dataset.qIndex;
            const index = parseInt(qIndex, 10);
            const tmpWrapperList = this.detailQuestionWrapperList;

            //if yes, set showMembers to true in order to show list of applicable members
            if (event.target.value.toLowerCase() === "yes") {
                tmpWrapperList[index].responseValue = "yes";
                tmpWrapperList[index].showMembers = tmpWrapperList[index]
                    .isMemberField
                    ? true
                    : false;
                tmpWrapperList[index].errorMsg = "";

                //For already selected members mark the changed maps
                for (
                    let i = 0;
                    i < tmpWrapperList[index].memberList.length;
                    i++
                ) {
                    if (tmpWrapperList[index].memberList[i].isChecked) {
                        this.constructDataToSave(
                            tmpWrapperList[index].memberList[i],
                            "Y"
                        );
                    }
                }

                //if yes, validate if one of applicable members is selected
                tmpWrapperList[
                    index
                ].isBasicCriteriaFulfilled = this.validateBasicCriteria(
                    tmpWrapperList[index]
                );
                tmpWrapperList[index].className = tmpWrapperList[index].className.replace(/ssp-checkbox-error/g, "");
            } else {
                tmpWrapperList[index].responseValue = "no";
                tmpWrapperList[index].showMembers = false;
                //if no, set isBasicCriteriaFulfilled to true, as no members are to be selected in this case
                tmpWrapperList[index].isBasicCriteriaFulfilled = true;
                tmpWrapperList[index].className = tmpWrapperList[index].className.replace(/ssp-checkbox-error/g, "");
                if (tmpWrapperList[index].isMemberField) {
                    for (
                        let i = 0;
                        i < tmpWrapperList[index].memberList.length;
                        i++
                    ) {
                        // tmpWrapperList[index].memberList[i].isChecked = false;
                        this.constructDataToSave(
                            tmpWrapperList[index].memberList[i],
                            "N"
                        );
                    }
                }
            }

            this.detailQuestionWrapperList = tmpWrapperList;

            //if field related to the question triggering the method is not related to SSP_Member__c, capture the related-selected details for saving
            if (!tmpWrapperList[index].isMemberField) {
                this.constructDataToSave(
                    tmpWrapperList[index],
                    event.target.value.toLowerCase() === "yes" ? "Y" : "N"
                );
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.manageQuestions " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : validateBasicCriteria
     * @description	: Method to validate if all the appropriate selections are made.
     * @param {object} detailWrapper - Detailed wrapper.
     */
    validateBasicCriteria (detailWrapper) {
        let result = detailWrapper.isMemberField ? false : true;
        try {
            for (let i = 0; i < detailWrapper.memberList.length; i++) {
                if (detailWrapper.memberList[i].isChecked) {
                    result = true;
                    break;
                }
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.validateBasicCriteria " +
                JSON.stringify(error)
            );
        }
        return result;
    }

    @api
    get sspApplicationId () {
        return this.applicationId;
    }

    /**
     * @function : sspApplicationId
     * @description	: Fetch required data in setting valid sspApplicationId.
     * @param  {string} value - Application id.
     */
    set sspApplicationId (value) {
        try {
            if (value !== null && value !== undefined) {
                fetchIncomeSubsidiesDetails({
                    sspApplicationId: value,
                    sMode: this.modeValue
                })
                    .then(result => {
                        const parsedData = result.mapResponse; 
                        const memberToProgramMapping = {};
                        const tmpMemberList = [];

                        if (parsedData.hasOwnProperty("ERROR")) {
                            console.error(
                                "Error in retrieving data sspIncomeAndSubsidiesSelection  " +
                                JSON.stringify(parsedData.ERROR)
                            );
                        } else {
                            if (parsedData.hasOwnProperty("memberDisabilityMatrix")) {
                                this.disabilityMatrix = parsedData.memberDisabilityMatrix;
                            }

                            /**2.5 Security Role Matrix and Program Access. */                            
                            this.isReadOnlyUser = (!sspUtility.isUndefinedOrNull(parsedData.screenPermission) && parsedData.screenPermission == sspConstants.permission.readOnly);
                            this.isScreenAccessible = (parsedData.screenPermission != null && parsedData.screenPermission != undefined && parsedData.screenPermission == sspConstants.permission.notAccessible) ? false : true;
                            this.showAccessDeniedComponent = !this.isScreenAccessible;                            
                            /** */

                            if ("applicationIndividuals" in parsedData) {
                                const appIndividuals =
                                    parsedData.applicationIndividuals;
                                for (
                                    let i = 0;
                                    i < appIndividuals.length;
                                    i++
                                ) {
                                    const appIndividual = appIndividuals[i];
                                    if (
                                        appIndividual !== null &&
                                        appIndividual !== undefined &&
                                        appIndividual.ProgramsApplied__c !==
                                        null
                                    ) {
                                        tmpMemberList.push(appIndividuals[i]);
                                        const programList =
                                            appIndividual.ProgramsApplied__c !==
                                                null &&
                                                appIndividual.ProgramsApplied__c !==
                                                undefined
                                                ? appIndividual.ProgramsApplied__c.split(
                                                    ";"
                                                )
                                                : [];
                                        memberToProgramMapping[
                                            appIndividual.SSP_Member__r.Id
                                        ] = programList;
                                    }
                                }

                                if (
                                    appIndividuals !== null &&
                                    appIndividuals !== undefined &&
                                    appIndividuals.length > 0
                                ) {
                                    const appIndividual = appIndividuals[0];
                                    this.appLevelProgramList =
                                        appIndividual.SSP_Application__r
                                            .ProgramsApplied__c !== null &&
                                            appIndividual.SSP_Application__r
                                                .ProgramsApplied__c !== undefined
                                            ? appIndividual.SSP_Application__r.ProgramsApplied__c.split(
                                                ";"
                                            )
                                            : [];
                                }
                                this.memberToProgramMapping = memberToProgramMapping;
                                this.memberList = tmpMemberList;
                                if (parsedData.hasOwnProperty("timeTravelCurrentMonth")) {
                                    this.timeTravelCurrentMonth =
                                        parsedData.timeTravelCurrentMonth;
                                    this.constructDateBasedQuestion();
                                }
                                this.triggerMemberBifurcation();
                            }
                            this.showSpinner = false;
                        }
                    })
                    .catch(error => {
                        console.error(
                            "failed in sspIncomeAndSubsidiesSelection.sspApplicationId " +
                            JSON.stringify(error)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.sspApplicationId " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : bifurcateQuestions.
     * @description	: Method to identify boolean value corresponding to the selected answer.
     * @param  {object{}} value - String value.
     */
    getToggleValue (value) {
        let result = false;
        try {
            result = value.toLowerCase() === "y";
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.getToggleValue " +
                JSON.stringify(error)
            );
        }
        return result;
    }

    /**
     * @function : bifurcateQuestions.
     * @description	: Method to bifurcate questions as attended or not.
     * @param  {object{}} selectedAnswer - Answer selected for corresponding question id.
     * @param {object} questionId - Corresponding question Id.
     * @param {boolean} isChecked - True if the field is positively attended.
     */
    bifurcateQuestions (selectedAnswer, questionId, isChecked) {
        try {
            if (isChecked && !this.activeProgramList.includes(questionId)) {
                this.activeProgramList.push(questionId);
                this.nonAttendedQuestionList = this.nonAttendedQuestionList.filter(
                    value => value !== questionId
                );
            } else if (
                selectedAnswer !== null &&
                selectedAnswer !== undefined &&
                selectedAnswer.toLowerCase() === "n" &&
                !this.nonAttendedQuestionList.includes(questionId) &&
                !this.activeProgramList.includes(questionId)
            ) {
                this.nonAttendedQuestionList.push(questionId);
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.bifurcateQuestions " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : triggerMemberBifurcation
     * @description	: Method to identify questions for each member based on programs that they opted for
     */
    triggerMemberBifurcation () {
        try {
            const tmpWrapperList = [];
            const tmpMapping = {};
            const tmpMemberList = this.memberList;
            const self = this;
            //Iterating over list of questions to identify if member being iterated is applicable for that question
            //if applicable add that member to corresponding list
            Object.keys(this.questionIdToProgramMapping).forEach(questionId => {
                let addToList = false;
                const questionListName = questionId + "MemberList"; //constructing name for corresponding question's member List
                const questionProgramList = this.questionIdToProgramMapping[
                    questionId
                ];
                tmpMapping[questionId] =
                    tmpMapping[questionId] !== null &&
                        tmpMapping[questionId] !== undefined
                        ? tmpMapping[questionId]
                        : [];

                let fieldAPI = questionId;
                fieldAPI =
                    fieldAPI[0].toUpperCase() + fieldAPI.slice(1) + "Toggle__c"; //adjust the questionId to SF field API format

                const isMemberField = this.extraFields.hasOwnProperty(fieldAPI)
                    ? false
                    : true; //true if the constructed field API belongs to SSP_Member__c

                const objAPI = !isMemberField
                    ? this.extraFields[fieldAPI]
                    : "SSP_Member__c";

                if (isMemberField) {
                    //Iterating over list of members
                    //for (let i = 0; i < tmpMemberList.length; i++) {
                    tmpMemberList.forEach(function (memberEntry) {
                        const tmpMember = memberEntry.SSP_Member__r;
                        if (tmpMember !== null && tmpMember !== undefined) {
                            const individualProgramList =
                                self.memberToProgramMapping !== null &&
                                    self.memberToProgramMapping !== undefined
                                    ? self.memberToProgramMapping[tmpMember.Id]
                                    : [];

                            //check if current question's program list contains the program that current member has applied for
                            if (
                                individualProgramList.some(item =>
                                    questionProgramList.includes(item)
                                ) &&
                                !tmpMapping[questionId].includes(tmpMember.Id)
                            ) {
                                addToList = true;

                                //if question iterated is for object other than SSP_Member__c, set isChecked to true
                                //else set isChecked to whatever value (true/false) the respective field value evaluates to
                                const selectedAnswer =
                                    tmpMember[fieldAPI] !== null &&
                                        tmpMember[fieldAPI] !== undefined
                                        ? tmpMember[fieldAPI]
                                        : null;

                                const isChecked =
                                    selectedAnswer !== null &&
                                        selectedAnswer !== undefined
                                        ? self.getToggleValue(selectedAnswer)
                                        : false;

                                //construct and add a wrapper to particular question's member list
                                //wrapper contains details of each individual member required by used input base components
                                self[questionListName].push({
                                    Id: tmpMember.Id, //Id to identify the member
                                    name: tmpMember.FirstName__c + " " + tmpMember.LastName__c, //mapped to label attribute of base component
                                    isChecked: isChecked, //mapped to value attribute of base component
                                    fieldAPI: fieldAPI,
                                    objAPI: objAPI,
                                    className:
                                    questionId + ", applicationInputs",
                                    errorMsg: "",
                                    isDisabled: this.isReadOnlyUser || (!sspUtility.isUndefinedOrNull(self.disabilityMatrix[tmpMember.Id]) && self.disabilityMatrix[tmpMember.Id].includes(fieldAPI))
                                });

                                //if the value of field current question relates to is true i.e. isChecked = true, then add the questionId to activeProgramList
                                //this means that the details/selections for this particular question are valid
                                self.bifurcateQuestions(
                                    selectedAnswer,
                                    questionId,
                                    isChecked
                                );

                                tmpMapping[questionId].push(tmpMember.Id);

                                self.constructOldValueMap(
                                    tmpMember.Id,
                                    fieldAPI,
                                    tmpMember[fieldAPI],
                                    isMemberField
                                );
                            }
                        }
                    }, this); //2.5 Security Role Matrix and Program Access
                }

                //check if current question's program list contains the program that current member has applied for
                else if (
                    this.appLevelProgramList.some(item =>
                        questionProgramList.includes(item)
                    )
                ) {
                    addToList = true;
                    const selectedAnswer =
                        tmpMemberList[0].SSP_Application__r[fieldAPI] !==
                            null &&
                            tmpMemberList[0].SSP_Application__r[fieldAPI] !==
                            undefined
                            ? tmpMemberList[0].SSP_Application__r[fieldAPI]
                            : null;

                    const isChecked =
                        selectedAnswer !== null && selectedAnswer !== undefined
                            ? this.getToggleValue(selectedAnswer)
                            : false;

                    this.bifurcateQuestions(
                        selectedAnswer,
                        questionId,
                        isChecked
                    );
                }

                if (addToList) {
                    tmpWrapperList.push(
                        this.constructWrapper(questionId, {
                            fieldAPI: fieldAPI,
                            objAPI: objAPI,
                            isMemberField: isMemberField,
                            memberListName: questionListName
                        })
                    );
                }
            });
            this.detailQuestionWrapperList = tmpWrapperList;
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.triggerMemberBifurcation " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : constructWrapper
     * @description	: Method to construct list of wrapper to be iterated for displaying questions
     */
    constructWrapper (questionId, detailWrap) {
        let tmpWrapper;
        try {
            //check if there exists a list with the name constructed in above step/line
            if (
                (detailWrap.isMemberField &&
                    this[detailWrap.memberListName] !== null &&
                    this[detailWrap.memberListName] !== undefined &&
                    this[detailWrap.memberListName].length > 0) ||
                !detailWrap.isMemberField
            ) {
                const id = !detailWrap.isMemberField
                    ? this.memberList[0].SSP_Application__r.Id
                    : null;

                //construct final detail wrapper with all the details of question and related members
                tmpWrapper = {
                    isVisible:
                        detailWrap.isMemberField &&
                            this[detailWrap.memberListName].length > 0
                            ? true
                            : detailWrap.isMemberField
                                ? false
                                : true, //decides whether to display the question on UI
                    questionId: questionId, //unique questionId, same as that of SF field API the question belongs to(excluding '__c')
                    memberList: detailWrap.isMemberField
                        ? this[detailWrap.memberListName]
                        : [], //list of members applicable for this question
                    //question label to be displayed on UI
                    questionLabel:
                        this.customLabel[questionId] !== null &&
                            this.customLabel[questionId] !== undefined
                            ? this.customLabel[questionId]
                            : "",
                    responseValue: this.activeProgramList.includes(questionId)
                        ? "yes"
                        : this.nonAttendedQuestionList.includes(questionId)
                            ? "no"
                            : "", //decides whether to show yes/no selected or keep both the options deselected
                    showMembers:
                        detailWrap.isMemberField &&
                            this.activeProgramList.includes(questionId)
                            ? true
                            : false, //decides whether to show list of applicable members onLoad
                    className: detailWrap.isMemberField
                        ? "member"
                        : "application",
                    objAPI: detailWrap.objAPI, //SF object API
                    fieldAPI: detailWrap.fieldAPI, //SF field API
                    isMemberField: detailWrap.isMemberField, //whether the field belongs to SSP_Member__c
                    isBasicCriteriaFulfilled: this.activeProgramList.includes(
                        questionId
                    )
                        ? true
                        : false, //are the details/selections for the /related to the question valid
                    errorMsg: sspIncomeSubsidiesSelectionErrorMsg, //error msg to be displayed if on selection of yes, no member is selected
                    Id: id, //SF record Id
                    isHelpText: this.helpTextLabels[questionId] ? true : false,
                    helpTextContent: this.helpTextLabels[questionId] ? this.helpTextLabels[questionId] : "",
                    isDisabled: this.isReadOnlyUser || this.determineQuestionDisability(detailWrap.isMemberField ? this[detailWrap.memberListName] : [], detailWrap.isMemberField, detailWrap.fieldAPI)
                };
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.constructWrapper " +
                JSON.stringify(error)
            );
        }
        return tmpWrapper;
    }

    determineQuestionDisability = (memberWrapperList, isMemberField, fieldAPI) => {
        const disabilityMatrix = this.disabilityMatrix;
        let isDisabled = false;
        if (isMemberField && !sspUtility.isUndefinedOrNull(disabilityMatrix)) {
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
     * @function : handleConditions
     * @description	: Method to handle onchange event of member checkbox.
     * @param {object} event - JS event.
     */
    handleConditions (event) {
        try {
            let questionIndex = event.target.dataset.qIndex;
            let memberIndex = event.target.dataset.mIndex;
            questionIndex = parseInt(questionIndex, 10);
            memberIndex = parseInt(memberIndex, 10);
            const tmpWrapperList = this.detailQuestionWrapperList;
            const targetQuestion = tmpWrapperList[questionIndex];
            const targetMember = targetQuestion.memberList[memberIndex];
            //if member is checked, mark corresponding isChecked wrapper attribute to true
            if (event.target.value) {
                tmpWrapperList[questionIndex].memberList[
                    memberIndex
                ].isChecked = true;
                //removing error message for all the members under that particular question
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
                tmpWrapperList[questionIndex].className += " ssp-checkbox-error";
            }
            else{
                tmpWrapperList[questionIndex].className = tmpWrapperList[questionIndex].className.replace(/ssp-checkbox-error/g, "");
            }
            this.constructDataToSave(
                targetMember,
                event.target.value ? "Y" : "N"
            );
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.handleConditions " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : constructDataToSave
     * @description	: Method to construct mapping of SF record Id, field API and Object API for saving/updating the records to server.
     * @param {object} targetMember - Target member wrapper.
     * @param {string} value - Field value.
     */
    constructDataToSave (targetMember, value) {
        //format =>
        //<SFRecordId>##<SFObjectAPIName> => Map<SFFieldAPI, correspondingValue>
        try {
            const membersDataToCommit = this.membersDataToCommit;

            const tmpMap =
                membersDataToCommit[
                    targetMember.Id + "##" + targetMember.objAPI
                ] !== null &&
                    membersDataToCommit[
                    targetMember.Id + "##" + targetMember.objAPI
                    ] !== undefined
                    ? membersDataToCommit[
                    targetMember.Id + "##" + targetMember.objAPI
                    ]
                    : {};
            tmpMap[targetMember.fieldAPI] = value;

            membersDataToCommit[
                targetMember.Id + "##" + targetMember.objAPI
            ] = tmpMap;
            this.membersDataToCommit = membersDataToCommit;
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.constructDataToSave " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : constructOldValueMap
     * @description	: Method to construct oldValue Map for member fieldAPI values.
     * @param {string} memberId - SF member id.
     * @param {string} fieldAPI - SF field api.
     * @param {string} value - Field value.
     * @param {boolean} isMemberField - True if the field is member field.
     */
    constructOldValueMap (memberId, fieldAPI, value, isMemberField) {
        try {
            if (isMemberField) {
                const oldValueMap = this.oldValueMap;

                const tmpMap =
                    oldValueMap[memberId] !== null &&
                        oldValueMap[memberId] !== undefined
                        ? oldValueMap[memberId]
                        : {};
                tmpMap[fieldAPI] = value;

                oldValueMap[memberId] = tmpMap;
                this.oldValueMap = oldValueMap;
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.constructOldValueMap " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : identifyPositiveChangedValue
     * @description	: Identify fields where value changed from false to true.
     * @param {Object{}} oldValueMap - Mappings for old values.
     * @param {Id} recordId - SF record id.
     * @param {string} fieldAPI - SF field API.
     * @param {string} newValue - New field value.
     */
    identifyPositiveChangedValue (oldValueMap, recordId, fieldAPI, newValue) {
        let result = false;
        try {
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
                    newValue.toLowerCase() === "y"
                ) {
                    result = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.identifyPositiveChangedValue " +
                JSON.stringify(error)
            );
        }
        return result;
    }

    /**
     * @function : identifyNegativeChangedValue
     * @description	: Identify fields where value changed from true to false.
     * @param {object{}} oldValueMap - Mappings for old values.
     * @param {Id} recordId - SF record id.
     * @param {string} fieldAPI - SF field API.
     * @param {string} newValue - New field value.
     */
    identifyNegativeChangedValue (oldValueMap, recordId, fieldAPI, newValue) {
        let result = false;
        try {
            if (
                oldValueMap !== null &&
                oldValueMap !== undefined &&
                oldValueMap[recordId] !== null &&
                oldValueMap[recordId] !== undefined &&
                oldValueMap[recordId][fieldAPI] !== null &&
                oldValueMap[recordId][fieldAPI] !== undefined
            ) {
                const oldValue = oldValueMap[recordId][fieldAPI];
                if (
                    oldValue.toLowerCase() === "y" &&
                    newValue.toLowerCase() === "n"
                ) {
                    result = true;
                }
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.identifyNegativeChangedValue " +
                JSON.stringify(error)
            );
        }
        return result;
    }

    /*
     * @function : validateMemberSelection
     * @description	: Method for validation of option(yes/no) and corresponding member selection
     */
    validateMemberSelection () {
        try {
            const tmpWrapperList = this.detailQuestionWrapperList;
            for (let i = 0; i < tmpWrapperList.length; i++) {
                if (!tmpWrapperList[i].isBasicCriteriaFulfilled) {
                    for (
                        let j = 0;
                        j < tmpWrapperList[i].memberList.length;
                        j++
                    ) {
                        tmpWrapperList[i].memberList[
                            j
                        ].errorMsg = sspIncomeSubsidiesSelectionErrorMsg;
                    }
                    if (
                        tmpWrapperList[i].responseValue === "yes" ||
                        tmpWrapperList[i].responseValue === "no"
                    ) {
                        tmpWrapperList[
                            i
                        ].errorMsg = sspIncomeSubsidiesSelectionErrorMsg;
                        tmpWrapperList[i].className += " ssp-checkbox-error";
                    }
                }
                else{
                    tmpWrapperList[i].className = tmpWrapperList[i].className.replace(/ssp-checkbox-error/g, "");
                }
            }

            this.detailQuestionWrapperList = tmpWrapperList;
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.validateMemberSelection " +
                JSON.stringify(error)
            );
        }
    }

    /*
     * @function : disconnectedCallback
     * @description	: Resetting wrapper on disconnected callback
     */
    disconnectedCallback () {
        this.detailQuestionWrapperList = [];
    }

    /*
     * @function : handleSave
     * @description	: Method to construct records in the format expected by APEX
     */
    handleSave () {
        try {
            this.showSpinner = true;
            const oldValueMap = this.oldValueMap;
            const changedValueMap = {};
            const changedValueMapNegative = {};
            const detailMap = {};
            const memberList = [];
            const applicationList = [];
           
            Object.keys(this.membersDataToCommit).forEach(key => {
                const entry = this.membersDataToCommit[key];
                const tmpList = key.split("##");
                let objWrapper = {};
                const objectAPI = tmpList[1];
                const tmpFieldList = [];
                const tmpFieldListNegative = [];
                changedValueMap[tmpList[0]] = [];
                changedValueMapNegative[tmpList[0]] = [];
                if (tmpList !== null && tmpList !== undefined) {
                    objWrapper.Id = tmpList[0];
                    Object.keys(entry).forEach(fieldAPI => {
                        objWrapper[fieldAPI] = entry[fieldAPI];
                        if (objectAPI === "SSP_Member__c") {
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
                        }
                    });
                }

                if (objectAPI === "SSP_Member__c") {
                    objWrapper = this.matchFieldsForMemberData(
                        oldValueMap,
                        objWrapper
                    );
                    memberList.push(objWrapper);
                    changedValueMap[tmpList[0]] = tmpFieldList;
                    changedValueMapNegative[tmpList[0]] = tmpFieldListNegative;
                } else if (objectAPI === "SSP_Application__c") {
                    applicationList.push(objWrapper);
                }
            });

            if (memberList.length > 0) {
                detailMap[
                    sspConstants.sspObjectAPI.SSP_Member__c
                ] = JSON.stringify(memberList);
            }

            if (applicationList.length > 0) {
                detailMap[
                    sspConstants.sspObjectAPI.SSP_Application__c
                ] = JSON.stringify(applicationList);
            }

            this.saveDataToServer(
                detailMap,
                changedValueMap,
                changedValueMapNegative
            );
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.handleSave " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : saveDataToServer
     * @description	: Method to send data to server.
     * @param  {object{}} detailMap - Details to be saved.
     * @param {object{}} changedValueMap - Mappings of changed entries.
     * @param {object{}} changedValueMapNegative - Mappings of negatively changed entries.
     */
    saveDataToServer (detailMap, changedValueMap, changedValueMapNegative) {
        try {
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

            //server call
            updateRecords(mParam)
                .then(result => {
                    if (result) {
                        const parsedData = result.mapResponse;
                        if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
                            console.error(
                                "Error in retrieving data sspIncomeAndSubsidiesSelection  " +
                                JSON.stringify(parsedData.ERROR)
                            );
                            this.showSpinner = false;
                        } else if (!sspUtility.isUndefinedOrNull(result) && result.bIsSuccess && !sspUtility.isUndefinedOrNull(parsedData)) {
                            if ("reviewRequiredParams" in parsedData) {
                                this.reviewRequiredList = parsedData.reviewRequiredParams;
                                this.dataSaved = true;
                                this.saveCompleted = true;
                            }
                        }
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error(
                        "error occurred sspIncomeAndSubsidiesSelection.saveDataToServer" +
                        JSON.stringify(error)
                    );
                });
        } catch (error) {
            this.showSpinner = false;
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.saveDataToServer " +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : matchFieldsForMemberData.
     * @description	: Method to match fields in all the records in list/wrapper.
     * @param  {object{}} oldValueMap - Mappings for old values.
     * @param {object} objWrapper - Object wrapper.
     */
    matchFieldsForMemberData (oldValueMap, objWrapper) {
        try {
            if (
                objWrapper !== null &&
                objWrapper !== undefined &&
                objWrapper.Id !== null &&
                objWrapper.Id !== undefined &&
                oldValueMap[objWrapper.Id] !== null &&
                oldValueMap[objWrapper.Id] !== undefined
            ) {
                const oldValueDetails = oldValueMap[objWrapper.Id];
                Object.keys(oldValueDetails).forEach(fieldAPI => {
                    if (!objWrapper.hasOwnProperty(fieldAPI)) {
                        objWrapper[fieldAPI] = oldValueDetails[fieldAPI];
                    }
                });
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeAndSubsidiesSelection.matchFieldsForMemberData " +
                JSON.stringify(error)
            );
        }
        return objWrapper;
    }

    /**
     * @function : constructDateBasedQuestion.
     * @description	: Method to create/alter date based question dynamically.
     */
    constructDateBasedQuestion () {
        if (this.timeTravelCurrentMonth) {
            this.customLabel.hasReceivedBenefitsFromOtherState = formatLabels(
                hasReceivedBenefitsFromOtherState,
                [
                    getCurrentMonthName(this.timeTravelCurrentMonth - 1),
                    getNextMonthName(this.timeTravelCurrentMonth - 1)
                ]
            );
        }
    }
}