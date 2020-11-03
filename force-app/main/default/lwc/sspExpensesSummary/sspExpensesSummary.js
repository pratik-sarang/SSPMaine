/**
 * Component Name: sspExpensesSummary.
 * Author: Shrikant Raut. Chirag Garg.
 * Description: Component for Expenses Summary screen.
 * Date: 11/25/2019.
 */
import { track, api } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import fetchExistingExpenseDetails from "@salesforce/apex/SSP_ExpenseController.fetchExistingExpenseDetailsImperative";
import sspConstants from "c/sspConstants";
import utility,{ formatLabels } from "c/sspUtility";
import sspExpenseSummaryContent1 from "@salesforce/label/c.SSP_ExpenseSummaryContent1";
import sspDeleteExpenseHeader from "@salesforce/label/c.SSP_DeleteExpenseHeader";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspExpenseSummaryTitle from "@salesforce/label/c.SSP_ExpenseSummaryTitle";
import sspAddExpense from "@salesforce/label/c.SSP_AddExpense";
import sspExpenseSummaryContent2 from "@salesforce/label/c.SSP_ExpenseSummaryContent2";
import sspExpenseSummaryContent3 from "@salesforce/label/c.SSP_ExpenseSummaryContent3";
import sspExpenseSummaryContent4 from "@salesforce/label/c.SSP_ExpenseSummaryContent4";
import sspExpenseSummaryContent5 from "@salesforce/label/c.SSP_ExpenseSummaryContent5";
import sspExpenseSummaryContent6 from "@salesforce/label/c.SSP_ExpenseSummaryContent6";
import sspExpenseSummaryContent7 from "@salesforce/label/c.SSP_ExpenseSummaryContent7";
import sspExpenseSummarySubText from "@salesforce/label/c.SSP_ExpenseSummarySubText";
import sspHigherEducation from "@salesforce/label/c.SSP_HigherEducation";
import sspChildSupport from "@salesforce/label/c.SSP_ChildSupport";
import sspDependentCare from "@salesforce/label/c.SSP_DependentCare";
import sspAlimony from "@salesforce/label/c.SSP_Alimony";
import summaryValidatorErrorMessage from "@salesforce/label/c.SSP_SummaryRecordValidatorMessage";
import sspAddExpenseRecord from "@salesforce/label/c.SSP_AddExpenseRecord";
import sspRemoveExpense from "@salesforce/label/c.SSP_RemoveExpense";
import sspForwardSlash from "@salesforce/label/c.SSP_forwardSlash";
import sspDollarSign from "@salesforce/label/c.SSP_DollarSign";
import sspEditButton from "@salesforce/label/c.SSP_EditButton";
import sspStartButton from "@salesforce/label/c.SSP_StartButton";
import sspView from "@salesforce/label/c.SSP_View";
import removeExpenseAlText from "@salesforce/label/c.SSP_RemoveExpenseAlText";
import year from "@salesforce/label/c.SSP_YearFrequency";
import week from "@salesforce/label/c.SSP_Week";
import month from "@salesforce/label/c.SSP_Month";
import quarter from "@salesforce/label/c.SSP_Quarter";
import twiceMonth from "@salesforce/label/c.SSP_TwiceMonth";
import biWeek from "@salesforce/label/c.SSP_BIWeek";
import dayFrequency from "@salesforce/label/c.SSP_DayFrequency";
import hour from "@salesforce/label/c.SSP_Hour";
import irregular from "@salesforce/label/c.SSP_Irregular";
import oneTimeLumpSum from "@salesforce/label/c.SSP_LumpSum";
import contractual from "@salesforce/label/c.SSP_Contractual";

const programs = {
    MA: sspConstants.programValues.MA,
    KT: sspConstants.programValues.KT,
    SN: sspConstants.programValues.SN,
    SS: sspConstants.programValues.SS,
    DS: sspConstants.programValues.DS,
    CC: sspConstants.programValues.CC,
    KP: sspConstants.programValues.KP
};
const frequencyMap = {
    MO: month,
    BW: biWeek,
    QU: quarter,
    SM: twiceMonth,
    WE: week,
    YR: year,
    DA: dayFrequency,
    HO: hour,
    IR : irregular,
    ON : oneTimeLumpSum,
    SP : contractual
};

/*
 * @description	: a constant wrapper to identify field visibility based on program, expense type and additional rendering conditions.
 */
const visibilityMapping = {
    [sspConstants.sspAssetFields.BooksAmount__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ],
            alternativeField: [
                sspConstants.sspAssetFields.TuitionAmount__c,
                sspConstants.sspAssetFields.MiscellaneousAmount__c,
                sspConstants.sspAssetFields.FeesAmount__c
            ]
        }
    ],

    [sspConstants.sspAssetFields.ChildName__c]: [
        {
            programs: [programs.SN, programs.KT, programs.MA, programs.CC],
            expenseTypes: [sspConstants.expenseTypeCodes.CAE],
            medicaidType: [sspConstants.medicaidTypes.NonMAGI]
        },
        {
            programs: [programs.SN, programs.KT],
            expenseTypes: [sspConstants.expenseTypeCodes.DCE],
            alternativeField: [
                sspConstants.sspAssetFields.DependentIndividual__c
            ]
        }
    ],

    [sspConstants.sspAssetFields.DependentCareProvider__c]: [
        {
            programs: [programs.SN, programs.KT],
            expenseTypes: [sspConstants.expenseTypeCodes.DCE],
            alternativeField: [
                sspConstants.sspAssetFields.ProviderName__c,
                sspConstants.sspAssetFields.ChildName__c
            ]
        }
    ],

    [sspConstants.sspAssetFields.DependentIndividual__c]: [
        {
            programs: [programs.SN, programs.KT],
            expenseTypes: [sspConstants.expenseTypeCodes.DCE],
            alternativeField: [sspConstants.sspAssetFields.ChildName__c]
        }
    ],

   /* [sspConstants.sspAssetFields.EndDate__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ]
        }
    ],*/

    [sspConstants.sspAssetFields.ExpenseAmount__c]: [
        {
            programs: [programs.MA, programs.SN, programs.KT, programs.CC],
            expenseTypes: [
                sspConstants.expenseTypeCodes.AL,
                sspConstants.expenseTypeCodes.CAE,
                sspConstants.expenseTypeCodes.DCE,
                sspConstants.expenseTypeCodes.ME,
                sspConstants.expenseTypeCodes.SE,
                sspConstants.expenseTypeCodes.DE,
                sspConstants.expenseTypeCodes.UE
            ],
            medicaidType: [
                sspConstants.medicaidTypes.MAGI,
                sspConstants.medicaidTypes.NonMAGI
            ]
        }
    ],

    [sspConstants.sspAssetFields.ExpenseFrequencyCode__c]: [
        {
            programs: [programs.MA, programs.SN, programs.KT, programs.CC],
            expenseTypes: [
                sspConstants.expenseTypeCodes.AL,
                sspConstants.expenseTypeCodes.CAE,
                sspConstants.expenseTypeCodes.DCE,
                sspConstants.expenseTypeCodes.ME,
                sspConstants.expenseTypeCodes.SE,
                sspConstants.expenseTypeCodes.DE,
                sspConstants.expenseTypeCodes.UE
            ],
            medicaidType: [
                sspConstants.medicaidTypes.MAGI,
                sspConstants.medicaidTypes.NonMAGI
            ]
        }
    ],

    [sspConstants.sspAssetFields.ExpenseSubType__c]: [
        {
            programs: [programs.MA],
            expenseTypes: [sspConstants.expenseTypeCodes.DE],
            medicaidType: [sspConstants.medicaidTypes.MAGI]
        },
        {
            programs: [programs.MA, programs.SN],
            expenseTypes: [
                sspConstants.expenseTypeCodes.ME,
                sspConstants.expenseTypeCodes.SE,
                sspConstants.expenseTypeCodes.UE
            ],
            medicaidType: [sspConstants.medicaidTypes.NonMAGI]
        }
    ],

    [sspConstants.sspAssetFields.ExpenseTypeCode__c]: [
        {
            programs: [programs.MA, programs.SN, programs.KT, programs.CC],
            medicaidType: [
                sspConstants.medicaidTypes.MAGI,
                sspConstants.medicaidTypes.NonMAGI
            ]
        }
    ],

    [sspConstants.sspAssetFields.FeesAmount__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ],
            alternativeField: [
                sspConstants.sspAssetFields.TuitionAmount__c,
                sspConstants.sspAssetFields.MiscellaneousAmount__c,
                sspConstants.sspAssetFields.BooksAmount__c
            ]
        }
    ],

    [sspConstants.sspAssetFields.IsNonHouseHoldMemberPayingExpenseToggle__c]: [
        {
            programs: [programs.MA, programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.SE],
            medicaidType: [sspConstants.medicaidTypes.NonMAGI]
        }
    ],

    [sspConstants.sspAssetFields.ReceiveInHouseAssistance__c]: [
        {
            programs: [programs.MA, programs.SN],
            medicaidType: [sspConstants.medicaidTypes.NonMAGI],
            otherFields: [
                {
                    [sspConstants.sspAssetFields
                        .IsNonHouseHoldMemberPayingExpenseToggle__c]:
                        sspConstants.sspObjectAPI.SSP_Asset__c
                }
            ]
        }
    ],

    [sspConstants.sspAssetFields.MiscellaneousAmount__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ],
            alternativeField: [
                sspConstants.sspAssetFields.TuitionAmount__c,
                sspConstants.sspAssetFields.FeesAmount__c,
                sspConstants.sspAssetFields.BooksAmount__c
            ]
        }
    ],

    [sspConstants.sspAssetFields.StartDate__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ]
        }
    ],

    [sspConstants.sspAssetFields.TuitionAmount__c]: [
        {
            programs: [programs.SN],
            expenseTypes: [sspConstants.expenseTypeCodes.EE],
            otherFields: [
                {
                    [sspConstants.sspMemberFields
                        .IsParticipatingInWorkStudyProgram__c]:
                        sspConstants.sspObjectAPI.SSP_Member__c
                }
            ],
            alternativeField: [
                sspConstants.sspAssetFields.MiscellaneousAmount__c,
                sspConstants.sspAssetFields.FeesAmount__c,
                sspConstants.sspAssetFields.BooksAmount__c
            ]
        }
    ]
};

export default class SspExpensesSummary extends baseNavFlowPage {
    @api sspApplicationId;
    @api sspMemberId;
    @api appliedPrograms = [];
    @api flowStatus;
    expenseFrequencyValueToLabel = {};
    expenseTypeValueToLabel = {};
    expenseSubTypeValueToLabel = {};
    selectedPosition = -1;
    medicaidType;
    customLabel = {
        sspView,
        sspExpenseSummaryTitle,
        sspExpenseSummarySubText,
        sspExpenseSummaryContent1,
        sspLearnMoreLink,
        sspAddExpense,
        sspExpenseSummaryContent2,
        sspExpenseSummaryContent3,
        sspExpenseSummaryContent4,
        sspAddExpenseRecord,
        sspExpenseSummaryContent5,
        sspExpenseSummaryContent6,
        sspExpenseSummaryContent7,
        sspRemoveExpense,
        sspEditButton,
        sspStartButton,
        summaryValidatorErrorMessage,
      removeExpenseAlText
    };

    @track isExistingSection = false;
    @track actionValue;
    @track nextValue;
    @track validationFlag;
    @track MetaDataListParent;
    @track allowToAddExpense = true;
    @track trueValue = true;
    @track falseValue = false;
    @track showExpenseDetails = false;
    @track retrievedData;
    @track reportedExpenses = [];
    @track nonReportedExpenses = [];
    @track requiredDataFetched = false;
    @track expenseIdToBeUpdated;
    @track operationMode;
    @track expenseName;
    @track todayDate;
    @api memberName;
    @api memberFirstName;
    @track hasSaveValidationError = false;
    @track isVisible = false;
    @track openLearnMoreModel = false;
    @track modValue;
    @track reference = this;
    @track showAddExpenseModal = false;
    @track isReadOnlyUser = false;  //CD2 2.5 Security Role Matrix.
    @track isReadOnlyDetails = false;  //CD2 2.5 Security Role Matrix.
    @track canDeleteExpense = true; //CD2 2.5 Security Role Matrix.
    @track disableExpenseDetails = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value !== undefined) {
                this.nextValue = value;
                this.saveData();
            }
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.nextEvent " +
                    JSON.stringify(error)
            );
        }
    }

    get isAllowToAddExpense () {
        if (this.isReadOnlyDetails || this.disableExpenseDetails) {
            return false;
        }
        return this.allowToAddExpense;
    }

    get isAllowToAddExpenseDefault () {
        if (this.isReadOnlyDetails || this.disableExpenseDetails) {
            return true;
        }
        return this.allowToAddExpense;
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (value) {
            this.saveCompleted = true;
        }
    }

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (
                value != null &&
                value !== undefined &&
                Object.keys(value).length > 0
            ) {
                this.MetaDataListParent = value;
                this.validationMetadataLoaded = true;
            }
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.MetadataList " +
                    JSON.stringify(error)
            );
        }
    }
    @api
    get modalContentValue () {
        return this.modValue;
    }
    set modalContentValue (value) {
        if (value) {
            const helpContent = value.mapResponse.helpContent;
            this.modValue = helpContent[0];
        }
    }

    /*
     * @function : connectedCallback
     * @description	: Triggered fetch expense details.
     */
    connectedCallback () {
        this.showAddExpenseModal = utility.isUndefinedOrNull(this.flowStatus) ? true : (this.flowStatus.charAt(0) === "R") ? true : false; 
        this.customLabel.sspExpenseSummarySubText = formatLabels(
            this.customLabel.sspExpenseSummarySubText,
            [this.memberFirstName, this.memberFirstName]
        );
        this.fetchExpenseData();
        this.showHelpContentData("SSP_APP_Details_Expense");
    }
    /**
     * @function - renderedCallback
     * @description - This method is used to called whenever there is track variable changing.
     */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMoreModal"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function : fetchExpenseData
     * @description	: Wire call to retrieve existing income related records for particular individual/member.
     */
    fetchExpenseData = () => {
        try {
            this.isVisible = false;
            this.nonReportedExpenses = [];
            this.reportedExpenses = [];
            this.appliedPrograms = [];
            this.medicaidType = null;
            let decimalValue;
            let frequency ="";
            let amount;
            let existingDecimalValue;
            let existingFrequency;
            let existingAmount;
            fetchExistingExpenseDetails({
                sspMemberId: this.sspMemberId,
                sspApplicationId: this.sspApplicationId,
                callingComponent: "sspExpensesSummary"
            })
                .then(result => {
                    const parsedData = result.mapResponse;
                    if (parsedData.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in retrieving data sspExpensesSummary" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else {
                        let isParticipatingInWorkStudyProgram = false;
                        this.constructRenderingAttributes(parsedData); //2.5 Security Role Matrix and Program Access.

                        if (
                            parsedData.hasOwnProperty(
                                "isParticipatingInWorkStudyProgram"
                            )
                        ) {
                            isParticipatingInWorkStudyProgram =
                                parsedData.isParticipatingInWorkStudyProgram;
                        }
                        if (parsedData.hasOwnProperty("timeTravelDate")) {
                            this.todayDate =
                                parsedData.timeTravelDate;
                        }

                        if (parsedData.hasOwnProperty("expenseFrequencies")) {
                            this.expenseFrequencyValueToLabel =
                                parsedData.expenseFrequencies;
                        }

                        if (parsedData.hasOwnProperty("expenseTypes")) {
                            this.expenseTypeValueToLabel =
                                parsedData.expenseTypes;
                        }

                        if (parsedData.hasOwnProperty("expenseSubTypes")) {
                            this.expenseSubTypeValueToLabel =
                                parsedData.expenseSubTypes;
                        }

                        if (
                            parsedData.hasOwnProperty("applicationIndividual")
                        ) {
                            const appIndividual =
                                parsedData.applicationIndividual[0];
                            if (
                                appIndividual != null &&
                                appIndividual !== undefined &&
                                appIndividual.ProgramsApplied__c != null
                            ) {
                                const programList = appIndividual.ProgramsApplied__c.split(
                                    ";"
                                );
                                this.appliedPrograms = programList;
                                this.medicaidType =
                                    appIndividual.MedicaidType__c;
                            }
                        }

                        if (parsedData.hasOwnProperty("expenseRecords")) {
                            const expenseRecords = parsedData["expenseRecords"];
                            let position = 0;
                            for (let i = 0; i < expenseRecords.length; i++) {
                                const expenseRecord = this.identifyHeaders(
                                    expenseRecords[i]
                                );
                                if (
                                    expenseRecord !== null &&
                                    expenseRecord !== undefined
                                ) {
                                    if (
                                        expenseRecord.IsExistingData__c
                                    ) {
                                        this.reportedExpenses.push(
                                            expenseRecord
                                        );
                                    } 
                                    else if (
                                        !expenseRecord.IsExistingData__c
                                    ) {
                                        expenseRecord.position = position++;
                                        
                                        expenseRecord[
                                            sspConstants.sspObjectAPI
                                                .SSP_Member__r +
                                                "." +
                                                sspConstants.sspMemberFields
                                                    .IsParticipatingInWorkStudyProgram__c
                                        ] = isParticipatingInWorkStudyProgram; 
                                        expenseRecord.showStart = !this.showEdit(
                                            expenseRecord
                                        );
                                        expenseRecord.key =
                                            expenseRecord.Id + position;
                                       
                                        if((expenseRecord.ExpenseTypeCode__c === sspConstants.expenseTypeCodes.EE && isParticipatingInWorkStudyProgram)
                                         || expenseRecord.ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE){                                            
                                            this.nonReportedExpenses.push(expenseRecord);
                                        }
                                        /*else if(expenseRecord.ExpenseTypeCode__c !== 'EE'){
                                            this.nonReportedExpenses.push(expenseRecord);
                                        }*/
                                        /*this.nonReportedExpenses.push(
                                            expenseRecord
                                        );*/
                                    }
                                }
                            }
                        }
                        this.allowToAddExpense = this.allowToProceed();
                        this.requiredDataFetched = true;
                        this.nonReportedExpenses.forEach(particularExpense => {
                            particularExpense.removeModalHeading = formatLabels(
                                sspDeleteExpenseHeader,
                                [particularExpense.lineOne]
                            );
                             amount = particularExpense.ExpenseAmount__c !== undefined && particularExpense.ExpenseAmount__c!=null ? 
                                        particularExpense.ExpenseAmount__c.toFixed(2).toString() : null;
                            if(particularExpense.ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE){
                                if (particularExpense.lineTwo!==undefined && particularExpense.lineTwo.indexOf("/") > -1 && particularExpense.ExpenseFrequencyCode__c!=="SP") {
                                    frequency = sspForwardSlash + particularExpense.lineTwo.split("/")[1];
                                }
                                else  if( particularExpense.lineTwo!==undefined && particularExpense.lineTwo.indexOf("/") > -1 && particularExpense.ExpenseFrequencyCode__c==="SP"){
                                    frequency =  sspForwardSlash + particularExpense.lineTwo.split("/")[1] + "/" +particularExpense.lineTwo.split("/")[2] ;
                                }
                            if (amount && amount!=null && amount!==undefined  && amount.indexOf(".") > -1) {
                                decimalValue = amount.split(".")[1];
                               particularExpense.lineTwo = "$" + parseInt(amount.split(".")[0], 10).toLocaleString() + "." + decimalValue + frequency;
                            }
                            else if (amount && amount!=null && amount!==undefined) {
                                particularExpense.lineTwo = "$" + parseInt(amount, 10).toLocaleString() + ".00" + frequency;
                            }
                           }
                        });
                        this.reportedExpenses.forEach(particularExpense => {
                             existingAmount = particularExpense.ExpenseAmount__c !== undefined &&  particularExpense.ExpenseAmount__c != null ? particularExpense.ExpenseAmount__c.toFixed(2).toString() : null;
                             existingFrequency="";
                            if(particularExpense.ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE){
                                if (particularExpense.lineTwo!==undefined && particularExpense.lineTwo.indexOf("/") > -1 && particularExpense.ExpenseFrequencyCode__c!=="SP") {
                                    existingFrequency ="/" + particularExpense.lineTwo.split("/")[1];
                                }
                                else  if(particularExpense.lineTwo!==undefined && particularExpense.lineTwo.indexOf("/") > -1 && particularExpense.ExpenseFrequencyCode__c==="SP"){
                                    existingFrequency = "/"+ particularExpense.lineTwo.split("/")[1] + "/" +particularExpense.lineTwo.split("/")[2] ;
                                }
                            if (existingAmount && existingAmount!=null && existingAmount!==undefined && existingAmount.indexOf(".") > -1) {
                                existingDecimalValue = existingAmount.split(".")[1];
                                particularExpense.lineTwo = "$" + parseInt(existingAmount.split(".")[0], 10).toLocaleString() + "." + existingDecimalValue +  existingFrequency;
                            }
                            else if (existingAmount && existingAmount!=null && existingAmount!==undefined ) {                              
                                particularExpense.lineTwo = "$" + parseInt(existingAmount, 10).toLocaleString() + ".00" + existingFrequency;
                                }
                            }
                        });
                    }
                    this.isVisible = true;
                    if (this.reportedExpenses && this.reportedExpenses.length) {
                        this.isExistingSection = true;
                    }
                })
                .catch(error => {
                    console.error(
                        "failed in sspExpensesSummary.fetchExpenseData " +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.fetchExpenseData " +
                    JSON.stringify(error)
            );
        }
    };

   

    /**
     * @function : saveData
     * @description	: Trigger on click of framework's next.
     */
    saveData () {
        if (this.allowToProceed()) {            
            const templateAppInputs = this.template.querySelectorAll(
                ".ssp-expenseSummaryInputs"
            );
            this.templateInputsValue = templateAppInputs;
        } else {
            this.hasSaveValidationError = true;
        }
    }

    /**
     * @function : identifyHeaders
     * @description	: Method to construct expense headers based on expense type.
     * @param {object} expenseRecord - Expense record.
     */
    identifyHeaders (expenseRecord) {
        const expRecord = {};
        if (expenseRecord != null && expenseRecord !== undefined) {
            Object.keys(expenseRecord).forEach(fieldAPI => {
                expRecord[fieldAPI] = expenseRecord[fieldAPI];
            });
            let expense = expenseRecord.ExpenseTypeCode__c !== sspConstants.expenseTypeCodes.EE ?
                      expenseRecord.ExpenseAmount__c :
                      [expenseRecord.TuitionAmount__c,
                       expenseRecord.BooksAmount__c,
                       expenseRecord.FeesAmount__c,
                       expenseRecord.MiscellaneousAmount__c].reduce(function (total, number) {
                        if(number !== undefined && number !== null && number !== ""){
                            return total + number;
                            }
                            return total;
                      }, null);                      
            if(expense!=null && expense!==undefined ){
                expense =  sspDollarSign+ expense.toFixed(2);
            }                             
            
            const expenseTypeCode = expenseRecord.ExpenseTypeCode__c;
            const expenseType =
                this.expenseTypeValueToLabel !== null &&
                this.expenseTypeValueToLabel !== undefined &&
                this.expenseTypeValueToLabel.hasOwnProperty(
                    expenseRecord.ExpenseTypeCode__c
                )
                    ? this.expenseTypeValueToLabel[
                          expenseRecord.ExpenseTypeCode__c
                      ]
                    : ""; //this.expenseRecord.fields.RecordType.value.fields.DeveloperName.value;//
            const expenseSubType =
                    this.expenseSubTypeValueToLabel !== null &&
                    this.expenseSubTypeValueToLabel !== undefined &&
                    this.expenseSubTypeValueToLabel.hasOwnProperty(
                        expenseRecord.ExpenseSubType__c
                    )
                        ? this.expenseSubTypeValueToLabel[
                              expenseRecord.ExpenseSubType__c
                          ]
                        : "blank";
            const expensePayFrequency =
                this.expenseFrequencyValueToLabel !== null &&
                this.expenseFrequencyValueToLabel !== undefined &&
                this.expenseFrequencyValueToLabel.hasOwnProperty(
                    expenseRecord.ExpenseFrequencyCode__c
                )
                    ? sspForwardSlash + frequencyMap[
                          expenseRecord.ExpenseFrequencyCode__c
                      ]
                    : "";
            if(expenseTypeCode === sspConstants.expenseTypeCodes.EE){
                expRecord.lineOne = sspHigherEducation;
            }
            else if(expenseTypeCode === sspConstants.expenseTypeCodes.CAE){
                expRecord.lineOne = sspChildSupport;
            }
            else if(expenseTypeCode === sspConstants.expenseTypeCodes.DCE){
                expRecord.lineOne = sspDependentCare;
            }
            else if(expenseTypeCode === sspConstants.expenseTypeCodes.AL){
                expRecord.lineOne = sspAlimony;
            }
            else if(expenseSubType !== "blank"){
                expRecord.lineOne = expenseSubType;
            }
            else{
                expRecord.lineOne = expenseType;
            }

            if(expense != null && expense!==undefined){
                expRecord.lineTwo =
                    expenseTypeCode !== sspConstants.expenseTypeCodes.EE
                        ? expense +
                        expensePayFrequency
                        :expense;                        
            }
            
        }
        return expRecord;
    }

    /**
     * @function : isFieldAttended
     * @description	: Method to check if the value is valid.
     * @param {object} value - Field value.
     */
    isFieldAttended (value) {
        let result = false;
        if (value !== null && value !== undefined) {
            result = true;
        }
        return result;
    }

    /**
     * @function : showEdit
     * @description	: Method to identify if edit button should be visible for that particular expense record.
     * @param  {object} expenseRecord - Expense Record.
     */
    showEdit (expenseRecord) {
        const selectedMedicaidType = this.medicaidType;
        const appliesProgramList = this.appliedPrograms;
        const self = this;
        let completionResult = true;
        if (appliesProgramList != null && appliesProgramList !== undefined) {
            Object.keys(visibilityMapping).forEach(fieldAPI => {
                let fieldLevelResult = true;
                let evaluateNextEntry =
                    visibilityMapping[fieldAPI] !== null &&
                    visibilityMapping[fieldAPI] !== undefined &&
                    visibilityMapping[fieldAPI].length > 1
                        ? true
                        : false;
                let alternativeFieldsList = [];
                visibilityMapping[fieldAPI].forEach(function (entry, index) {
                    alternativeFieldsList = [];
                    fieldLevelResult = true;
                    if (evaluateNextEntry || index === 0) {
                        const fieldSpecificProgramList = entry.programs;
                        const fieldSpecificExpenseTypes = entry.expenseTypes;
                        const medicaidTypes = entry.medicaidType;
                        const otherFields = entry.otherFields;
                        alternativeFieldsList = entry.alternativeField;
                        let result = false;
                        let otherResults = true;
                        result =
                            self.performProgramCheck(
                                appliesProgramList,
                                fieldSpecificProgramList,
                                medicaidTypes,
                                selectedMedicaidType
                            ) &&
                            self.performExpenseTypeCheck(
                                [expenseRecord.ExpenseTypeCode__c],
                                fieldSpecificExpenseTypes
                            );

                        if (otherFields != null && otherFields !== undefined) {
                            otherFields.forEach(function (fieldDetails) {
                                Object.keys(fieldDetails).forEach(
                                    otherFieldAPI => {
                                        if (
                                            fieldDetails[otherFieldAPI] ===
                                            sspConstants.sspObjectAPI
                                                .SSP_Member__c
                                        ) {
                                            const fAPI =
                                                "SSP_Member__r." +
                                                otherFieldAPI;
                                            const value = expenseRecord[fAPI];
                                            if (
                                                value === undefined ||
                                                value === null ||
                                                (value !== undefined &&
                                                    value !== null &&
                                                    ((typeof value ===
                                                        "boolean" &&
                                                        !value) ||
                                                        (typeof value !==
                                                            "boolean" &&
                                                            value !== "Y")))
                                            ) {
                                                otherResults = false;
                                            }
                                        } else if (
                                            fieldDetails[otherFieldAPI] ===
                                            sspConstants.sspObjectAPI
                                                .SSP_Asset__c
                                        ) {
                                            const value =
                                                expenseRecord[otherFieldAPI];
                                            if (
                                                value === undefined ||
                                                value === null ||
                                                (value !== undefined &&
                                                    value !== null &&
                                                    ((typeof value ===
                                                        "boolean" &&
                                                        !value) ||
                                                        (typeof value !==
                                                            "boolean" &&
                                                            value !== "Y")))
                                            ) {
                                                otherResults = false;
                                            }
                                        }
                                    }
                                );
                            });
                        }

                        result = result && otherResults;
                        fieldLevelResult = fieldLevelResult && result;
                        evaluateNextEntry = evaluateNextEntry && !result;
                    }
                });
                completionResult = fieldLevelResult
                    ? self.checkFieldValues(
                          self.getValue(expenseRecord, fieldAPI),
                          alternativeFieldsList,
                          expenseRecord,
                          self
                      ) && completionResult
                    : completionResult;
            });
        }
        return completionResult;
    }

    /**
     * @function : getValue
     * @description	: Method to fetch field value from record.
     * @param  {object} record - SF record.
     * @param {string} fApi - SF field api.
     */
    getValue (record, fApi) {
        let value;
        const apiList = fApi.split(".");
        if (apiList !== null && apiList !== undefined) {
            if (apiList.length === 1) {
                value = record[apiList[0]];
            } else if (apiList.length === 2) {
                value = record[apiList[0]][apiList[1]];
            }
        }
        return value;
    }

    /**
     * @function : checkFieldValues
     * @description	: Method to check/verify field values.
     * @param  {object} fieldValue - Field value.
     * @param {object[]} alternativeFields - List of alternative fields.
     * @param {object} expenseRecord - Expense record.
     * @param {object} self - Current context.
     */
    checkFieldValues (fieldValue, alternativeFields, expenseRecord, self) {
        let result = false;
        if (self.isFieldAttended(fieldValue)) {
            result = true;
        } else if (
            alternativeFields !== null &&
            alternativeFields !== undefined
        ) {
            alternativeFields.forEach(function (fieldAPI) {
                if (self.isFieldAttended(expenseRecord[fieldAPI])) {
                    result = true;
                }
            });
        }
        return result;
    }

    /**
     * @function : performProgramCheck
     * @description	: Method to perform program level check.
     * @param {object[]} appliedList - List of applied programs.
     * @param {object[]} validList - List of valid programs.
     * @param {object[]} medicaidTypes - List of program medicaid types.
     * @param {string} mType - Medicaid type.
     */
    performProgramCheck (appliedList, validList, medicaidTypes, mType) {
        let result = false;
        if (validList !== null && validList !== undefined) {
            //appliedList.forEach(function (entity, index) {
            appliedList.forEach(function (entity) {
                if (validList.includes(entity)) {
                    if (
                        (entity === programs.MA &&
                            medicaidTypes.includes(mType)) ||
                        entity !== programs.MA
                    ) {
                        result = true;
                    }
                }
            });
        } else {
            result = true;
        }
        return result;
    }

    /**
     * @function : performExpenseTypeCheck
     * @description	: Method to perform expense type check.
     * @param {object[]} appliedList - List of applied entries.
     * @param  {object[]} validList - List of valid entries.
     */
    performExpenseTypeCheck (appliedList, validList) {
        let result = false;
        if (validList != null && validList !== undefined) {
            //appliedList.forEach(function (entity, index) {
            appliedList.forEach(function (entity) {
                if (validList.includes(entity)) {
                    result = true;
                }
            });
        } else {
            result = true;
        }
        return result;
    }

    /**
     * @function : handleRemoveAction
     * @description	: This method is called when the onDelete event is fired from the cards.
     * @param {object} event - JS event.
     */
    handleRemoveAction (event) {
        try {
            this.isVisible = false;
            deleteRecord(event.target.dataset.itemId)
                .then(() => {
                    this.reportedExpenses = [];
                    this.nonReportedExpenses = [];
                    this.fetchExpenseData();
                })
                .catch(error => {
                    console.error(
                        "failed in sspExpensesSummary.handleRemoveAction " +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.handleRemoveAction " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : initStartFlow
     * @description	: This method is called when start or edit buttons are clicked.
     * @param  {object} event - JS event.
     */
    initStartFlow (event) {
        try {
            if (event.detail === undefined || event.detail === "") {
                return;
            }
            this.selectedPosition = event.target.dataset.position;
            this.showExpenseDetails = true;
            const hideFrameworkEvent = new CustomEvent(
                sspConstants.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: true
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
            this.expenseIdToBeUpdated = event.detail.Id;
            this.operationMode = event.target.dataset.mode;
            this.expenseName = event.detail.ExpenseTypeCode__c;
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.initStartFlow " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : completeAddingExpense
     * @description	: This method is called when on complete event fires from income details.
     */
    completeAddingExpense () {
        try {
            this.fetchExpenseData();
            this.showExpenseDetails = false;
            const hideFrameworkEvent = new CustomEvent(
                sspConstants.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: false
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
            this.expenseIdToBeUpdated = "";
            this.operationMode = "";
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.completeAddingExpense " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : addExpenseFlow
     * @description	: This method is called when the add income button is clicked.
     */
    addExpenseFlow () {
        try {
            this.showExpenseDetails = true;
            const hideFrameworkEvent = new CustomEvent(
                sspConstants.events.hideSection,
                {
                    bubbles: true,
                    composed: true,
                    detail: {
                        hideSectionFlag: true
                    }
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
            this.expenseIdToBeUpdated = "";
            this.operationMode = "";
            this.expenseName = "";
        } catch (error) {
            console.error(
                "failed in sspExpensesSummary.addExpenseFlow " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : allowToProceed
     * @description	: Method to identify if all the expenses filling is completed.
     */
    allowToProceed () {
        const nonReportedExpenses = this.nonReportedExpenses;
        let result = true;
        nonReportedExpenses.forEach(function (expense) {
            if (
                expense !== null &&
                expense !== undefined &&
                expense.showStart
            ) {
                result = false;
            }
        });
        return result;
    }

    /**
     * @function : displayLearnMoreModelMethod
     * @description : Used to open learn more modal.
     * @param {object} event - Js event.
     */
    displayLearnMoreModelMethod (event) {
        if (event.keyCode === 13 || event.type === "click") {
            this.openLearnMoreModel = true;
        }
    }

    /**
     * @function : hideLearnMoreModelMethod
     * @description : Used to hide learn more modal.
     */
    hideLearnMoreModelMethod () {
        this.openLearnMoreModel = false;
        this.openLearnMoreModel = "";
    }

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast () {
        this.hasSaveValidationError = false;
    }
    
    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
   constructRenderingAttributes = response => {
    try {
        if (response != null && response != undefined && response.hasOwnProperty("securityMatrixSummary") && response.hasOwnProperty("securityMatrixDetails")) {
            const { securityMatrixSummary, securityMatrixDetails } = response;
            //code here
            this.isReadOnlyUser =
            !utility.isUndefinedOrNull(securityMatrixSummary) &&
            !utility.isUndefinedOrNull(securityMatrixSummary.screenPermission) &&
            securityMatrixSummary.screenPermission === sspConstants.permission.readOnly;

            this.canDeleteExpense =
            !utility.isUndefinedOrNull(securityMatrixSummary) &&
            !utility.isUndefinedOrNull(securityMatrixSummary.canDelete) &&
            !securityMatrixSummary.canDelete ? false : true;

            this.disableExpenseDetails =
            !utility.isUndefinedOrNull(securityMatrixDetails) &&
            !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
            securityMatrixDetails.screenPermission === sspConstants.permission.notAccessible ? true : false;

            this.isReadOnlyDetails =
            !utility.isUndefinedOrNull(securityMatrixDetails) &&
            !utility.isUndefinedOrNull(securityMatrixDetails.screenPermission) &&
            securityMatrixDetails.screenPermission === sspConstants.permission.readOnly;

            if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
                this.isPageAccessible = true;
            }
            else {
                this.isPageAccessible = !(securityMatrixSummary.screenPermission === sspConstants.permission.notAccessible);
            }
            if (!this.isPageAccessible) {
                this.showAccessDeniedComponent = true;
            } else {
                this.showAccessDeniedComponent = false;
            }
        }
    }
    catch (error) {
        console.error(
            JSON.stringify(error.message)
        );
    }
};
}