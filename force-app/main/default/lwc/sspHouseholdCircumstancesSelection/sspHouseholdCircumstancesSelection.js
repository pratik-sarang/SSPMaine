/**
 * Component Name: SspHouseholdCircumstancesSelection.
 * Author: Ajay Saini.
 * Description: Screen component for household circumstances questions.
 * Date: DEC-5-2019.
 */

import { track, api, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { refreshApex } from "@salesforce/apex";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import AGE from "@salesforce/schema/SSP_Member__c.Age__c";
import SSN_VERIFIED from "@salesforce/schema/SSP_Member__c.SSNVerified__c";
import HAS_CONVICTED_CRIME from "@salesforce/schema/SSP_Application__c.HasConvictedCrimeToggle__c";
import IS_MIGRANT_OR_SEASONAL_FARMWORKER from "@salesforce/schema/SSP_Member__c.IsMigrantOrSeasonalFarmWorkerToggle__c";
import RECEIVE_SSI_BENEFITS from "@salesforce/schema/SSP_Member__c.ReceivesSSIBenefitsToggle__c";
import IS_CURRENTLY_ENROLLED_IN_SCHOOL from "@salesforce/schema/SSP_Member__c.IsCurrentlyEnrolledInSchoolToggle__c";
import RECEIVE_ENTITLED_INCOME from "@salesforce/schema/SSP_Member__c.ReceivesEntitledIncomeToggle__c";
import IN_FOSTER_CARE from "@salesforce/schema/SSP_Member__c.IsFosterCareToggle__c";

import {
    programValues,
    events,
    applicationMode,
    householdCircumstancesConstants,
    toggleFieldValue,
    permission
} from "c/sspConstants";

import fetchApplicationMembers from "@salesforce/apex/SSP_HouseholdCircumstancesController.fetchApplicationMembers";
import deleteMemberData from "@salesforce/apex/SSP_HouseholdCircumstancesController.deleteMemberData";
import otherScenariosBenefitsQuestions from "@salesforce/label/c.SSP_OtherScenariosBenefitsQuestions";
import circumstanceSelectionNote from "@salesforce/label/c.ssp_HouseholdCircumstanceSelectionNote";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspHouseholdLearnMoreTitle from "@salesforce/label/c.SSP_HouseholdLearnMoreTitle";
import convictedForCrime from "@salesforce/label/c.SSP_ConvictedForCrime";
import migrantOrSeasonalFarmWorker from "@salesforce/label/c.SSP_MigrantOrSeasonalFarmworker";
import notReceivingSSIBenefits from "@salesforce/label/c.SSP_NotRecievingSsiBenefits";
import notReceivingEntitledIncome from "@salesforce/label/c.SSP_NotRecievingEntitledIncome";
import enrolledInSchool from "@salesforce/label/c.SSP_EnrolledInSchool";
import anyoneInFosterCare from "@salesforce/label/c.SSP_AnyoneInFosterCare";
import convictedForCrimeHelpText from "@salesforce/label/c.SSP_ConvictedForCrimeHelpText";
import migrantOrSeasonalFarmWorkerHelpText from "@salesforce/label/c.SSP_MigrantOrSeasonalFarmworkerHelpText";
import notReceivingSsiBenefitsHelpText from "@salesforce/label/c.SSP_NotRecievingSsiBenefitsHelpText";
import sspHouseholdSelectionLearnTitle from "@salesforce/label/c.SSP_HouseholdSelectionLearnTitle"; 
import sspHouseholdSelectionLearnContent from "@salesforce/label/c.SSP_HouseholdSelectionLearnContent"; 

const INTAKE = applicationMode.INTAKE;
const RENEWAL = applicationMode.RENEWAL;
const RAC = applicationMode.RAC;
export default class SspHouseholdCircumstancesSelection extends BaseNavFlowPage {
    @api applicationId;
    @api mode;
    @track members = [];
    @track application;
    @track showLearnMore = false;
    @track reference = this;
    @track showSpinner = false;
    @track questions = [];
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track currentMemberData = [];
    @track rawQuestions = [
        {
            field: HAS_CONVICTED_CRIME,
            label: convictedForCrime,
            mode: [INTAKE, RENEWAL],
            helpTextContent: convictedForCrimeHelpText,
            applicablePrograms: [programValues.KT, programValues.SN]
        },
        {
            field: IS_MIGRANT_OR_SEASONAL_FARMWORKER,
            label: migrantOrSeasonalFarmWorker,
            mode: [INTAKE, RENEWAL],
            helpTextContent: migrantOrSeasonalFarmWorkerHelpText,
            applicablePrograms: [programValues.SN]
        },
        {
            field: RECEIVE_SSI_BENEFITS,
            label: notReceivingSSIBenefits,
            mode: [INTAKE, RENEWAL, RAC],
            helpTextContent: notReceivingSsiBenefitsHelpText,
            applicablePrograms: [programValues.NONMAGI, programValues.SS]
        },
        {
            field: RECEIVE_ENTITLED_INCOME,
            label: notReceivingEntitledIncome,
            mode: [INTAKE, RENEWAL],
            applicablePrograms: [programValues.MA, programValues.KT]
        },
        {
            field: IS_CURRENTLY_ENROLLED_IN_SCHOOL,
            label: enrolledInSchool,
            applicablePrograms: [
                programValues.MA,
                programValues.SN,
                programValues.KT,
                programValues.CC
            ],
            mode: [INTAKE, RENEWAL],
            ...householdCircumstancesConstants.enrolledInSchool
        },
        {
            field: IN_FOSTER_CARE,
            label: anyoneInFosterCare,
            mode: [INTAKE, RENEWAL],
            applicablePrograms: [programValues.MA],
            ...householdCircumstancesConstants.inFosterCare
        }
    ];

    label = {
        otherScenariosBenefitsQuestions,
        circumstanceSelectionNote,
        learnMoreLink,
        sspHouseholdLearnMoreTitle,
        sspHouseholdSelectionLearnTitle, 
        sspHouseholdSelectionLearnContent 
    };

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value) {
                this.showSpinner = true;
                this.nextValue = value;
                if (!this.isReadOnlyUser) { //2.5 Security Role Matrix and Program Access.
                    this.validateData();
                }
                else {
                    this.templateInputsValue = [];
                }
            }
        } catch (error) {
            console.error("Error in set nextEvent:", error);
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;
            this.saveData();
        } catch (error) {
            console.error("Error in set allowSaveData:", error);
        }
    }

    @wire(getRecord, {
        recordId: "$applicationId",
        fields: "$applicationFields"
    })
    wiredFetchApplication (value) {
        try {
            this.applicationWire = value;
            const { error, data } = this.applicationWire;
            if (data) {
                const application = {
                    Id: data.id
                };
                Object.keys(data.fields).forEach(field => {
                    application[field] = data.fields[field].value;
                });
                this.application = application;
            } else if (error) {
                console.error(error);
            }
        } catch (error) {
            console.error("Error in wiredFetchApplication:", error);
        }
    }

    @wire(fetchApplicationMembers, {
        applicationId: "$applicationId",
        memberFields: "$memberFields",
        applicationMode: "$mode"
    })
    wiredFetchApplicationMembers (value) {
        try {
            this.membersWire = value;
            const { error, data } = this.membersWire;
            if (data) {
                const response = JSON.parse(JSON.stringify(data));
                if (response && response.mapResponse) {
                    /**2.5 Security Role Matrix and Program Access. */
                    this.isReadOnlyUser = (response.mapResponse.screenPermission != null && response.mapResponse.screenPermission != undefined && response.mapResponse.screenPermission == permission.readOnly);
                    this.isScreenAccessible = (response.mapResponse.screenPermission != null && response.mapResponse.screenPermission != undefined && response.mapResponse.screenPermission == permission.notAccessible) ? false : true;
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                    /** */
                    this.memberProgramsMap =
                        response.mapResponse.memberProgramsMap;
                    this.members = response.mapResponse.members || [];
                    this.currentMemberData =   this.members;
                    const questions = this.rawQuestions.map(question => {
                        question.applicableMembers = this.members;
                        return question;
                    });
                    //filter out not applicable questions and member
                    this.filterQuestionsAndMembers(questions);
                } else if (error) {
                    console.error(error);
                }
            } else if (error) {
                console.error(error);
            }
        } catch (error) {
            console.error("Error in wiredFetchApplicationMembers:", error);
        }
    }

    get memberFields () {
        return [AGE, SSN_VERIFIED]
            .concat(this.rawQuestions.map(question => question.field))
            .filter(field => field.objectApiName.includes("Member"))
            .map(field => field.fieldApiName);
    }

    get applicationFields () {
        return this.rawQuestions
            .map(question => question.field)
            .filter(field => field.objectApiName.includes("Application"));
    }

    /**
     * @function renderedCallback
     * @description Sets a flag to avoid calling querySelector before rendering.
     */
    renderedCallback () {
        this.rendered = true;
    }

    /**
     * @function validateData
     * @description This method runs validation on each question.
     */
    validateData = () => {
        try {
            const allQuestionsValid = Array.from(
                this.template.querySelectorAll(
                    "c-ssp-household-information-question"
                )
            )
                .map(element => element.isAnswered())
                .every(item => item);
            if (!allQuestionsValid) {
                this.showSpinner = false;
                const showToastEvent = new CustomEvent(events.toastEvent, {
                    bubbles: true,
                    composed: true
                });
                this.dispatchEvent(showToastEvent);
            } else {
                this.templateInputsValue = [];
            }
            return allQuestionsValid;
        } catch (error) {
            console.error("Error in validateData", error);
        }
        return false;
    };

    /**
     * @function saveData
     * @description Saves the required responses after validating.
     */
    saveData = () => {
        try {
            if (!this.rendered) {
                return;
            }
            const questionElements = this.template.querySelectorAll(
                "c-ssp-household-information-question"
            );
            const memberUpdates = [];
            const applicationUpdates = {};
            const deleteRecords = [];
            const revRules = [];
            const revRulesFoster = [];
            const revRulesEnroll = [];
            const revRulesSSI = [];
            const revRulesEntitle = [];
            for (const questionEl of questionElements) {
                const fieldApiName = questionEl.field.fieldApiName;
                const objectApiName = questionEl.field.objectApiName;
                if (objectApiName.includes("Member")) {
                    for (const member of questionEl.members) {
                        memberUpdates.push({
                            Id: member.Id,
                            [fieldApiName]: member[fieldApiName]
                        });
                        if (fieldApiName === "ReceivesEntitledIncomeToggle__c" && member[fieldApiName] === "N"){
                            deleteRecords.push(member.Id);
                        }
                    }
                } else {
                    Object.assign(applicationUpdates, questionEl.application);
                }
            }
            if (Array.isArray(this.hiddenQuestions)) {
                for (const question of this.hiddenQuestions) {
                    const fieldApiName = question.field.fieldApiName;
                    const objectApiName = question.field.objectApiName;
                    if (objectApiName.includes("Member")) {
                        for (const member of this.members) {
                            memberUpdates.push({
                                Id: member.Id,
                                [fieldApiName]: toggleFieldValue.null
                            });
                        }
                    } else {
                        Object.assign(applicationUpdates, {
                            [fieldApiName]: toggleFieldValue.null
                        });
                    }
                }
            }
            deleteMemberData({
                sMemberIds: deleteRecords,
                sApplicationId: this.applicationId
            })
                .then(result=> {

                })
                .catch( error => {
                    console.error("Error in saveData", error);
                });
            const recordsToUpdate = {};
            for (const update of memberUpdates) {
                if (update.Id in recordsToUpdate) {
                    Object.assign(recordsToUpdate[update.Id], update);
                } else {
                    recordsToUpdate[update.Id] = update;
                }
            }
            if (this.application && this.application.Id) {
                applicationUpdates.Id = this.application.Id;
                recordsToUpdate[this.application.Id] = applicationUpdates;
            }            
            Object.values(recordsToUpdate).forEach(record =>{
                let valueChanged =false ; 
                if(record.IsFosterCareToggle__c){
                    valueChanged = this.isValueChanged (record.Id ,"IsFosterCareToggle__c", record.IsFosterCareToggle__c);
                    if(valueChanged && record.IsFosterCareToggle__c==="Y"){
                        revRulesFoster.push(record.Id);
                    }
                }
                 if(record.IsCurrentlyEnrolledInSchoolToggle__c){
                    valueChanged = this.isValueChanged (record.Id ,"IsCurrentlyEnrolledInSchoolToggle__c", record.IsCurrentlyEnrolledInSchoolToggle__c);
                    if(valueChanged && record.IsCurrentlyEnrolledInSchoolToggle__c ==="Y"){
                        revRulesEnroll.push(record.Id);
                    }
                 }

                 if(record.ReceivesSSIBenefitsToggle__c){
                    valueChanged = this.isValueChanged (record.Id ,"ReceivesSSIBenefitsToggle__c", record.ReceivesSSIBenefitsToggle__c);
                    if(valueChanged && record.ReceivesSSIBenefitsToggle__c ==="Y"){
                        revRulesSSI.push(record.Id);
                    }
                 }
                 if(record.ReceivesEntitledIncomeToggle__c){
                    valueChanged = this.isValueChanged (record.Id ,"ReceivesEntitledIncomeToggle__c", record.ReceivesEntitledIncomeToggle__c);
                    if(valueChanged && record.ReceivesEntitledIncomeToggle__c ==="Y"){
                        revRulesEntitle.push(record.Id);
                    }
                    
                 }
            });
            if (revRulesFoster.length > 0) {
                revRules.push("FosterCareScreen," + true + "," + revRulesFoster);
            }
            if (revRulesEnroll.length > 0) {
                revRules.push("EnrolledInSchool," + true + "," + revRulesEnroll);
            }
            if (revRulesSSI.length > 0) {
                revRules.push("SSIBenefits," + true + "," + revRulesSSI);
            }
            if (revRulesEntitle.length > 0) {
                revRules.push("ReceivesEntitledIncome," + true + "," + revRulesEntitle);
            }
            
            this.reviewRequiredList = revRules; 

            Promise.all(
                Object.values(recordsToUpdate).map(record =>
                    updateRecord({ fields: record })
                )
            ).then(() => {                
                this.saveCompleted = true;
                this.showSpinner = false;
                return Promise.all([
                    refreshApex(this.membersWire),
                    refreshApex(this.applicationWire)
                ]);
            });
        } catch (error) {
            console.error("Error in saveData", error);
        }
    };


    isValueChanged (id , fieldName , valueNew){
        try {
            for (const data of this.currentMemberData) {
                if (data.Id === id) {
                    if (data[fieldName] !== valueNew) {
                        return true;
                    }
                }
            }
            return false;
        }
        catch (error) {
            console.error("Error in isValueChanged", error);
        }
        return false;
     }

    /**
     * @function filterQuestionsAndMembers
     * @description Filters out questions and members which are not applicable for the application.
     * @param {object} rawQuestions - List questions.
     */
    filterQuestionsAndMembers = rawQuestions => {
        try {
            const effectiveMode =
                (this.mode === "addRemoveMember"
                    ? applicationMode.INTAKE
                    : this.mode) || applicationMode.INTAKE;
            const questions = JSON.parse(
                JSON.stringify(rawQuestions)
            ).filter(question => question.mode.includes(effectiveMode));
            //filter out not-applicable members
            for (const question of questions) {
                question.applicableMembers = question.applicableMembers.filter(
                    member => {
                        const programsApplied = this.memberProgramsMap[
                            member.Id
                        ].split(";");
                        const applicablePrograms = question.applicablePrograms;
                        const notApplicableAgeRanges =
                            question.notApplicableAgeRanges;

                        let eligiblePrograms = programsApplied.filter(
                            program => applicablePrograms.indexOf(program) >= 0
                        );
                        if (member.Age__c && notApplicableAgeRanges) {
                            eligiblePrograms = eligiblePrograms.filter(
                                program =>
                                    !this.ageRangeTest(
                                        member.Age__c,
                                        notApplicableAgeRanges[program]
                                    )
                            );
                        }
                        return eligiblePrograms.length > 0;
                    }
                );
            }
            //required logic for enrolled in school question/not-required question
            for (const question of questions) {
                if (question.notRequiredAgeRanges) {
                    question.required = question.applicableMembers.some(
                        member => {
                            const programsApplied = this.memberProgramsMap[
                                member.Id
                            ].split(";");
                            if (member.Age__c) {
                                return programsApplied.some(
                                    program =>
                                        !this.ageRangeTest(
                                            member.Age__c,
                                            question.notRequiredAgeRanges[
                                                program
                                            ]
                                        )
                                );
                            }
                            return true;
                        }
                    );
                } else {
                    question.required = true;
                }
            }
            this.questions = questions.filter(
                question => question.applicableMembers.length > 0
            );
            this.hiddenQuestions = questions.filter(
                question =>
                    Array.isArray(question.applicableMembers) &&
                    question.applicableMembers.length === 0
            );
        } catch (e) {
            console.error("Error in filter", e);
        }
    };

    /**
     * @function filterQuestionsAndMembers
     * @description Filters out questions and members which are not applicable for
     *                the application.
     * @param {integer} age - Age of the person.
     * @param {integer[][]} ranges - List of age ranges.
     */
    ageRangeTest = (age, ranges) => {
        try {
            if (!ranges) {
                return false;
            }
            return ranges.some(range => {
                const [min, max] = range;
                return (
                    min !== undefined &&
                    min <= age &&
                    (max === undefined || age <= max)
                );
            });
        } catch (error) {
            console.error("Error in ageRangeTest:", error);
        }
    };

    /**
     * @function learnMoreModal
     * @description This method is used to show learn more modal.
     */
    learnMoreModal = () => {
        try {
            this.showLearnMore = true;
            return false;
        } catch (error) {
            console.error("Error in learnMoreModal", error);
        }
    };
    /**
     * @function closeLearnMoreModal
     * @description This method is used to close learn more modal.
     */
    closeLearnMoreModal = () => {
        try {
            this.showLearnMore = false;
        } catch (error) {
            console.error("Error in closeLearnMoreModal", error);
        }
    };
}
