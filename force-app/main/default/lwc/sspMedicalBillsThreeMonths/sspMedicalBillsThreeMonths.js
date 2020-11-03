/**
 * Component Name: sspMedicalBillsThreeMonths.
 * Author: Sharon Roja,Naveena Malapati.
 * Description: This component for Medical Bills for Last Three Months.
 * Date: 08/02/2020.
 */
import { track, api, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import sspMedicalExpensesPara from "@salesforce/label/c.SSP_MedilcalExpensesPara";
import sspMedicalExpensesListOne from "@salesforce/label/c.SSP_MedicalExpensesListOne";
import sspMedicalExpensesListThree from "@salesforce/label/c.SSP_MedicalExpensesListThree";
import sspMedicalExpensesListTwo from "@salesforce/label/c.SSP_MedicalExpensesListTwo";
import sspMedicalExpensesListFour from "@salesforce/label/c.SSP_MedicalExpensesListFour";
import sspMedicalExpensesListFive from "@salesforce/label/c.SSP_MedicalExpensesListFive";
import sspMedicalExpensesListSix from "@salesforce/label/c.SSP_MedicalExpensesListSix";
import sspMedicalExpensesListSeven from "@salesforce/label/c.SSP_MedicalExpensesListSeven";
import sspMedicalExpensesQuestion from "@salesforce/label/c.SSP_MedicalExpensesQuestion";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import firstName from "@salesforce/schema/SSP_Member__c.FirstName__c";
import lastName from "@salesforce/schema/SSP_Member__c.LastName__c";
import isCoverageMonth1 from "@salesforce/schema/SSP_Member__c.IsCoverageMonth1__c";
import isCoverageMonth2 from "@salesforce/schema/SSP_Member__c.IsCoverageMonth2__c";
import isCoverageMonth3 from "@salesforce/schema/SSP_Member__c.IsCoverageMonth3__c";
import birthDate1 from "@salesforce/schema/SSP_Member__c.BirthDate__c";
import fetchApplicationDate from "@salesforce/apex/SSP_MedicalBillsFor3MonthsController.fetchApplicationDate";
import utility from "c/sspUtility";
import sspConstants from "c/sspConstants"
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
const FIELDS = [
    firstName,
    lastName,
    isCoverageMonth1,
    isCoverageMonth2,
    isCoverageMonth3,
    birthDate1
];

export default class SspMedicalBillsThreeMonths extends BaseNavFlowPage {
    @api memberId;
    @api applicationId;
    @track member;
    @track metaData;
    @track showToast = false;
    @track trueValue = true;
    @track showSpinner = false;
    @track hasError = false;
    label = {
        sspMedicalExpensesPara,
        sspMedicalExpensesListOne,
        sspMedicalExpensesListTwo,
        sspMedicalExpensesListThree,
        sspMedicalExpensesListFour,
        sspMedicalExpensesListFive,
        sspMedicalExpensesListSix,
        sspMedicalExpensesListSeven,
        sspMedicalExpensesQuestion,
        sspRequiredErrorMessage,
        toastErrorText
    };

    @track optList = [];
    @track selectedMonths;
    @track getCheckboxValues;   
    @track checkboxValues=[]; 
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track memberIdValue;
    handleFlag = false;
    month1;
    month2;
    month3;
    booleanMonth1;
    booleanMonth2;
    booleanMonth3;
    getMonth1;
    getMonth2;
    getMonth3;
    birthDate;
    age;
    retrieveDataFlag=false;

    /**
     * @function : Getter setters for member Id.
     * @description : Getter setters for member Id.
     */
    get memberId () {
        try{
            return this.memberIdValue;
        }catch (error) {
            console.error(
                "### Error occurred during member id in Medical Expenses (last 3 months) ###" +JSON.stringify(error.message));
            return null;
        }
    }
    set memberId (value) {
        try{
            this.memberIdValue = value;
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.getApplication();
            }
        }catch (error) {
            console.error("### Error occurred during member id in Medical Expenses (last 3 months) ###" + JSON.stringify(error.message));
        }
    }

    /**
     * @function 	: nextEvent.
     * @description : This attribute is used to go to next queued screen.
     * */
    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                this.validateRequiredCheckboxGroup();
                if(this.hasError){
                    const showToastEvent = new CustomEvent("showcustomtoast", {
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(showToastEvent);
                    this.templateInputsValue = "invalid";
                }
                else{
                    this.validateData();
                }
            }
        } catch (error) {
            console.error(
                "Error in set nextEvent of sspMedicalBillsThreeMonths page",
                error
            );
        }
    }

    /**
     * @function : allowSaveData
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.handleSave(value);
        }
    }

    /**
     * @function 	: MetadataList.
     * @description : This function is part of validation framework which is used to get the metaData values.
     * */
    @api
    get MetadataList () {
        return this.metaData;
    }
    set MetadataList (value) {
        this.metaData = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
        if (Object.keys(value).length > 0) {
            this.constructRenderingMap(null, value);
        }
    }

    /**
     * @function - getRecord().
     * @description - This is a wire function to get INDIVIDUAL record for SSP Member.
     * @param {response} response - Response Data.
     */
    @wire(getRecord, {
        recordId: "$memberId",
        fields: FIELDS
    })
    getMember (response) {
        try {
            const data = response.data;
            const error = response.error;
            if (data) {
                this.member = data;
                this.birthDate = getFieldValue(this.member, birthDate1);
                this.updateLabel();
                if (getFieldValue(this.member, isCoverageMonth1) === true) {
                    this.getMonth1 = sspConstants.monthsValues[0];
                    this.retrieveDataFlag = true;
                }
                if (getFieldValue(this.member, isCoverageMonth2) === true) {
                    this.getMonth2 = sspConstants.monthsValues[1];
                    this.retrieveDataFlag = true;
                }
                if (getFieldValue(this.member, isCoverageMonth3) === true) {
                    this.getMonth3 = sspConstants.monthsValues[2];
                    this.retrieveDataFlag = true;
                }
                if (this && this.checkboxValues){
                    this.checkboxValues = [
                        this.getMonth1,
                        this.getMonth2,
                        this.getMonth3
                    ];
                }
            } else if (error) {
                console.error("Error in getMember:", error);
            }
        } catch (error) {
            console.error("Error in getMember:", error);
        }
    }

    /**
     * @function - fetchApplicationDate().
     * @description - This is a wire function to display CheckBoxes labels based on ApplicationReceivedDate.
     */
    getApplication () {
        this.showSpinner = true;
        try {
            fetchApplicationDate({
                sApplicationID: this.applicationId,
                sMemberID : this.memberId
            })
                .then(response => {
                    if (
                        !utility.isUndefinedOrNull(response) &&
                        !utility.isEmpty(response)
                    ) {
                        this.month1 =
                            sspConstants.months[response.mapResponse.Month1];
                        this.month2 =
                            sspConstants.months[response.mapResponse.Month2];
                        this.month3 =
                            sspConstants.months[response.mapResponse.Month3];
                        if (
                            !utility.isUndefinedOrNull(
                                response.mapResponse.ageInMonths
                            ) &&
                            !utility.isEmpty(
                                response.mapResponse.ageInMonths
                            ) &&
                            response.mapResponse.ageInMonths < 3
                        ) {
                            const age = response.mapResponse.ageInMonths;
                            if (age === 0) {
                                this.optList = [];
                            }
                            if (age === 1) {
                                this.optList = [
                                    {
                                        label: this.month3,
                                        value: sspConstants.monthsValues[2]
                                    }
                                ];
                            }
                            if (age === 2) {
                                this.optList = [
                                    {
                                        label: this.month2,
                                        value: sspConstants.monthsValues[1]
                                    },
                                    {
                                        label: this.month3,
                                        value: sspConstants.monthsValues[2]
                                    }
                                ];
                            }
                        } else {
                            this.optList = [
                                {
                                    label: this.month1,
                                    value: sspConstants.monthsValues[0]
                                },
                                {
                                    label: this.month2,
                                    value: sspConstants.monthsValues[1]
                                },
                                {
                                    label: this.month3,
                                    value: sspConstants.monthsValues[2]
                                }
                            ];
                        }
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error("error", JSON.stringify(error));
                });
        } catch (error) {
            console.error("Error in getApplication:", error);
            this.showSpinner = false;
        }
    }

    /**
     * @function : connectedCallback.
     * @description : Fire an event from connectedCallback to have field and Object Details.
     */
    connectedCallback () {
        try {
            const fields = FIELDS.map(
                field => field.fieldApiName + "," + field.objectApiName
            );
            this.getMetadataDetails(
                fields,
                null,
                "SSP_APP_Details_MedicalExpensesLast3Months"
            );
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    /**
     * @function : validateData.
     * @description : Fire an event from validateData.
     */
    validateData = () => {
        try {
            const inputElements = this.template.querySelectorAll(
                ".ssp-medicalBillsCheckboxGroup"
            );
            this.templateInputsValue = inputElements;
        } catch (error) {
            console.error("Error in validateData:", error);
        }
    };

    /**
     * @function : name
     * @description : Getter setter methods for name.
     */
    get name () {
        try {
            const firstName1 = getFieldValue(this.member, firstName);

            const lastName1 = getFieldValue(this.member, lastName);

            return firstName1 + " " + lastName1;
        } catch (error) {
            console.error("Error in getter name:", error);
            return utility.isUndefinedOrNull(
                getFieldValue(this.member, firstName)
            );
        }
    }

    /**
     * @function - updateLabel().
     * @description - This method is used to update label with Applicant Name.
     */
    updateLabel = () => {
        try {
            const label = JSON.parse(JSON.stringify(this.label));
            label.sspMedicalExpensesQuestion = label.sspMedicalExpensesQuestion.replace(
                /\{0\}/,
                this.name
            );

            this.label = label;
        } catch (error) {
            console.error("Error in updating labels:", error);
        }
    };

    /**
     * @function - handleAssistanceWithMedicalBills().
     * @description - This is a handler for CheckBoxes.
     * @param {event} event - This Contains the checkboxes which are selectedMonths.
     */
    handleAssistanceWithMedicalBills = (event) => {
        try {
            this.handleFlag=true;
            if (event.detail.value != null) {
                this.value = event.detail.value;
                this.selectedMonths = this.value.join(",");
                if (
                    !utility.isUndefinedOrNull(this.selectedMonths) &&
                    !utility.isEmpty(this.selectedMonths)
                ) {
                    if (this.selectedMonths.indexOf(sspConstants.monthsValues[0]) !== -1) {
                        this.booleanMonth1 = true;
                    } else {
                        this.booleanMonth1 = false;
                    }
                    if (this.selectedMonths.indexOf(sspConstants.monthsValues[1]) !== -1) {
                        this.booleanMonth2 = true;
                    } else {
                        this.booleanMonth2 = false;
                    }
                    if (this.selectedMonths.indexOf(sspConstants.monthsValues[2]) !== -1) {
                        this.booleanMonth3 = true;
                    } else {
                        this.booleanMonth3 = false;
                    }
                }
            }
            this.validateRequiredCheckboxGroup();
        } catch (error) {
            console.error("Error in handleAssistanceWithMedicalBills:", error);
        }
    };

    /**
     * @function - functionGetAge().
     * @description - This is function is used to calculate age from BirthDate__c.
     * @param {object} birthDate - Data from BirthDate__c field from SSP_Member__C.
     */
    functionGetAge = (birthDate) => {
        try {
            const daysInMonth = 30.436875;
            const dob = new Date(birthDate);
            const today = new Date();
            const yearOfToday = today.getFullYear();
            const yearDob = dob.getFullYear();
            let years = yearOfToday - yearDob; 
            dob.setFullYear(yearOfToday);
            const todayTime = today.getTime();
            let dobTime = dob.getTime();
            if (todayTime < dobTime) {
                --years;
                dob.setFullYear(yearOfToday - 1);
                dobTime = dob.getTime();
            }
            let days = (todayTime - dobTime) / 86400000;
            const monthsDec = days / daysInMonth;
            const months = ((years * 12) + today.getMonth()-dob.getMonth()); 
            days = Math.floor(daysInMonth * (monthsDec - months));
            this.age = [years, months, days];
        } catch (error) {
            console.error("Error in functionGetAge:", error);
        }
    }

    /**
     * @function - handleSave().
     * @description - This method is used to update record.
     */
    handleSave = () => {
        this.showSpinner = true;
        try {
            if(this.handleFlag===true){
            const fields = {};
            fields[isCoverageMonth1.fieldApiName] = this.booleanMonth1;
            fields[isCoverageMonth2.fieldApiName] = this.booleanMonth2;
            fields[isCoverageMonth3.fieldApiName] = this.booleanMonth3;

            const record = {
                recordId: this.memberId,
                fields: fields
            };

            updateRecord(record)
                .then(() => {
                    this.saveCompleted = true;
                    this.showSpinner = false;                    
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error("error", error);
                });
            }
            this.showSpinner = false; 
            this.saveCompleted = true;
        } catch (error) {
            this.showSpinner = false;
            console.error("Error in handleSave:", error);
        }
    
    };

    /**
     * @function - validateNewDates().
     * @description - This method is used to validate newEmergencyBeginDate doesn't overlap with oldEmergencyEndDate.
     */
    validateRequiredCheckboxGroup = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-medicalBillsCheckboxGroup"
            );
            contactInfo.forEach((contact, index) => {
                if (contact.getAttribute("data-id") === "checkbox") {
                    const messageList = contactInfo[index].ErrorMessageList;

                    const indexOfMessage = messageList.indexOf(
                        this.label.sspRequiredErrorMessage
                    );
                    if (
                        indexOfMessage === -1 &&
                        ((this.handleFlag === true &&
                            utility.isUndefinedOrNull(this.selectedMonths)) ||
                            utility.isEmpty(this.selectedMonths) ||
                            (this.handleFlag === false &&
                                this.retrieveDataFlag === false))
                    ) {
                        messageList.push(this.label.sspRequiredErrorMessage);
                        this.hasError = true;
                    } else if (
                        indexOfMessage >= 0 &&
                        (!utility.isUndefinedOrNull(this.selectedMonths) &&
                            !utility.isEmpty(this.selectedMonths))
                    ) {
                        messageList.splice(indexOfMessage, 1);
                        this.hasError = false;
                    }
                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );           
                }
            });
        } catch (error) {
            console.error("Error in validateRequiredCheckboxGroup:", error);
        }
    };

    /**
     * @function handleHideToast
     * @description Raises error toast if required.
     */
    handleHideToast = () => {
        try {
            this.showToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
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
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                    this.isNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                              "Error in constructRenderingMap", error
                        );
        }
    }
}