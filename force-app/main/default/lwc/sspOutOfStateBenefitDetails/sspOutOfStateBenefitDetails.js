/**
 * Component Name : sspOutOfStateBenefitDetails.
 * Author: Kyathi, Sai Kiran.
 * Description: This screen displays the details of Benefits Out of State Details.
 * Date: 11/12/2019.
 */

import { track, wire, api } from "lwc";

import sspEndDateValidatorMessage from "@salesforce/label/c.SSP_EndDateValidatorMessage";
import sspOutOfStateBenefitDetailHeading from "@salesforce/label/c.SSP_OutOfStateBenefitDetailHeading";
import sspCompleteBenefitDetailQuestions from "@salesforce/label/c.SSP_CompleteBenefitDetailQuestions";
import sspTypeOfBenefitProgramsLabel from "@salesforce/label/c.SSP_TypeofBenefitProgramsLabel";
import sspBenefitStartDate from "@salesforce/label/c.SSP_BenefitStartDate";
import sspBenefitEndDate from "@salesforce/label/c.SSP_BenefitEndDate";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspState from "@salesforce/label/c.SSP_State";
import sspCounty from "@salesforce/label/c.SSP_County";
import sspBenefitDetailSaveAltText from "@salesforce/label/c.SSP_BenefitDetailSaveAltText";
import sspBenefitDetailCancelAltText from "@salesforce/label/c.SSP_BenefitDetailCancelAltText";
import sspStateAltText from "@salesforce/label/c.SSP_StateAltText";
import sspSelectOption from "@salesforce/label/c.SSP_SelectOption";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSelectProgramError from "@salesforce/label/c.SSP_SelectProgramError";
import sspStartTypingPlaceholder from "@salesforce/label/c.SSP_StartTypingPlaceholder";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import SSPBENEFIT_OBJECT from "@salesforce/schema/SSP_Benefits__c";
import utility from "c/sspUtility";
import upsertAnotherStateBenefits from "@salesforce/apex/SSP_AnotherStateBenefitsCtrl.upsertAnotherStateBenefits";
import programConstant from "c/sspConstants";

export default class sspOutOfStateBenefitDetails extends utility {
    @api actionCheck;
    @api memberName;
    @api benefitObj = {};
    @api resourceRecordTypeId;
    @api timeTravelTodayDate;
    @track changedStateValue = "";
    @track isStatePopulated = false;
    @track showSpinner = false;
    @track trueValue = true;
    @track state;
    @track county;
    @track objValue;
    @track memberName;
    @track dateArray = [];
    @track allowSaveValue;
    @track eventStartDate;
    @track eventEndDate;
    @track benefitEndDate;
    @track benefitProgram;
    @track benefitStartDate;
    @track MetaDataListParent;
    @track selectedStateValue;
    @track lstState = [];
    @track lstCounty = [];
    @track lstPrograms = [];
    @track newObjBenefitData = [];
    @track hasSaveValidationError = false;
    @track toastErrorText;
    @track endDateValidation = "";
    @track customValidationError = "";
    @track programValidationError = "";
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isScreenNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    summaryTitle = "";
    label = {
        sspBenefitDetailSaveAltText,
        sspBenefitDetailCancelAltText,
        sspOutOfStateBenefitDetailHeading,
        sspCancel,
        sspSave,
        sspCompleteBenefitDetailQuestions,
        sspTypeOfBenefitProgramsLabel,
        sspBenefitStartDate,
        sspBenefitEndDate,
        sspState,
        sspCounty,
        sspStateAltText,
        sspSelectOption,
        toastErrorText,
        sspSelectProgramError,
        sspStartTypingPlaceholder,
        sspEndDateValidatorMessage
    };
    
    get screenRenderingStatus (){
        return this.isScreenNotAccessible;
    }

    /**
     * @function 	: MetadataList.
     * @description : This attribute is part of validation framework which used get the .
     * */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.MetaDataListParent = value;
                //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                }
            }
        } catch (error) {
            console.error(
                "### Error in function MetadataList ###" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }
    /**
     * @function 	: allowSave.
     * @description : This attribute is part of validation framework which Valid data to Save.
     * */
    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.allowSaveValue = value;
            }
        } catch (error) {
            console.error(
                "### Error in function allowSave ###" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }
    /**
     * @function 	: objWrap.
     * @description 	: this attribute contains validated data which is used to save.
     * */
    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.objValue = value;
            }
        } catch (error) {
            console.error(
                "### Error in function objWrap ###" + JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function 	: objectInfo.
     * @description 	: this is used to get the RecordType of the Object.
     * */
    @wire(getObjectInfo, { objectApiName: SSPBENEFIT_OBJECT })
    objectInfo ({ data, error }) {
        try {
            if (data) {
                const recordTypeInformation =
                    data[
                        programConstant.resourceDetailConstants
                            .resourceRecordTypes
                    ];
                this.resourceRecordTypeId = Object.keys(
                    recordTypeInformation
                ).find(
                    recTypeInfo =>
                        recordTypeInformation[recTypeInfo].name ===
                        programConstant.recordTypeNames.SSPBenefitRecordType
                );
            } else if (error) {
                console.error(
                    "### Error while trying to fetch Record Type values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "### Error while trying to fetch Record Type values ###" +
                    JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }

    /**
     * @function 	: picklistOptions.
     * @description 	: this is used to get the Picklist Values of the Object.
     * */
    @wire(getPicklistValuesByRecordType, {
        objectApiName: SSPBENEFIT_OBJECT,
        recordTypeId: "$resourceRecordTypeId"
    })
    picklistOptions ({ error, data }) {
        try {
            if (data) {
                const programOptions =
                    data.picklistFieldValues.BenefitPrograms__c.values;
                for (let i = 0; i < programOptions.length; i = i + 1) {
                    if (
                        programOptions[i].value ===
                            programConstant.programValues.MA ||
                        programOptions[i].value ===
                            programConstant.programValues.TN ||
                        programOptions[i].value ===
                            programConstant.programValues.SN
                    ) {
                        this.lstPrograms.push({
                            label: programOptions[i].label,
                            value: programOptions[i].value,
                            checked: false,
                            startDate: "",
                            endDate: ""
                        });
                    }
                }
                if (this.actionCheck) {
                    for (let i = 0; i < this.lstPrograms.length; i = i + 1) {
                        if (
                            this.lstPrograms[i].value.includes(
                                programConstant.programValues.MA
                            ) &&
                            this.benefitObj.sBenefitProgram.includes(
                                this.lstPrograms[i].value
                            )
                        ) {
                            this.lstPrograms[i].checked = true;
                            this.lstPrograms[
                                i
                            ].startDate = this.benefitObj.dBenefitMEDICADEStartDate;
                            this.lstPrograms[
                                i
                            ].endDate = this.benefitObj.dBenefitMEDICADEEndDate;
                        } else if (
                            this.lstPrograms[i].value.includes(
                                programConstant.programValues.TN
                            ) &&
                            this.benefitObj.sBenefitProgram.includes(
                                this.lstPrograms[i].value
                            )
                        ) {
                            this.lstPrograms[i].checked = true;
                            this.lstPrograms[
                                i
                            ].startDate = this.benefitObj.dBenefitTANFStartDate;
                            this.lstPrograms[
                                i
                            ].endDate = this.benefitObj.dBenefitTANFEndDate;
                        } else if (
                            this.lstPrograms[i].value.includes(
                                programConstant.programValues.SN
                            ) &&
                            this.benefitObj.sBenefitProgram.includes(
                                this.lstPrograms[i].value
                            )
                        ) {
                            this.lstPrograms[i].checked = true;
                            this.lstPrograms[
                                i
                            ].startDate = this.benefitObj.dBenefitSNAPStartDate;
                            this.lstPrograms[
                                i
                            ].endDate = this.benefitObj.dBenefitSNAPEndDate;
                        }
                    }
                }
                this.lstState = data.picklistFieldValues.State__c.values;
            } else if (error) {
                console.error(
                    "### Error while trying to fetch picklist values ###" +
                        error
                );
            }
        } catch (error) {
            console.error(
                "### Error while trying to fetch picklist values ###" +
                    JSON.stringify(error)
            );
            this.showSpinner = false;
        }
    }
    /**
     * @function : connectedCallback
     * @description : This method is used to Picklist Metadata Values.
     */

    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Benefits from Another State Details";
            if (this.benefitObj.sBenefitStateLabel) {
                this.isStatePopulated = true;
            }
            this.showSpinner = true;
            const fieldEntityNameList = [];
            fieldEntityNameList.push("BeginDate__c,SSP_Benefits__c");
            fieldEntityNameList.push("State__c,SSP_Benefits__c");
            fieldEntityNameList.push("BenefitInfoCounty__c,SSP_Benefits__c");
            fieldEntityNameList.push("EndDate__c,SSP_Benefits__c");
            fieldEntityNameList.push("BenefitPrograms__c,SSP_Benefits__c");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_BenefitsFromAnotherStateDetails"
            );
            this.toastErrorText = this.label.toastErrorText;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error occurred in Benefit Details page" + JSON.stringify(error)
            );
            this.showSpinner = false;
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
     * @function    : showHideFields
     * @description : This function is used to SHOW/HIDE the date fields based on check box.
     * @param {event} event - Event.
     */
    showHideFields = event => {
        try {
            const val = event.srcElement.checked;
            const parentCheckboxes = this.lstPrograms;
            const elem = this.template.querySelectorAll(".ssp-checkboxInputs");
            this.checkValidations(elem);
            let i;
            for (i = 0; i < parentCheckboxes.length; i++) {
                if (parentCheckboxes[i].value === event.srcElement.value) {
                    parentCheckboxes[i].checked = val;
                }
            }
            this.lstPrograms = parentCheckboxes;
            if (
                this.lstPrograms[0].checked === true ||
                this.lstPrograms[1].checked === true ||
                this.lstPrograms[2].checked === true
            ) {
                 this.hasSaveValidationError = false;
                 this.customValidationError = "";
            }
        } catch (error) {
            console.error(
                "Error occurred Program section in Benefit Summary page " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function    : saveBenefitDetails
     * @description : This function is used to Save the Benefit Records.
     */
    saveBenefitDetails = () => {
        try {
          if (this.isReadOnlyUser) { // CD2 2.5 Security Role Matrix and Program Access.
              this.cancelBenefitDetails();
          }
          else{
            this.showSpinner = true;
            this.hasSaveValidationError = false;
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            if (
                this.lstPrograms[0].checked === false &&
                this.lstPrograms[1].checked === false &&
                this.lstPrograms[2].checked === false
            ) {
                this.hasSaveValidationError = true;
                this.customValidationError = this.label.sspSelectProgramError;
            }
            this.checkValidations(elem);
            let JSONValue = [];
            if (this.objValue !== undefined && this.endDateValidation === "") {
                JSONValue = this.objValue.split("EndDate");

                if (
                    this.lstPrograms[0].checked ||
                    this.lstPrograms[1].checked ||
                    this.lstPrograms[2].checked
                ) {
                    if (JSONValue.length > 1) {
                        const finalObjBenefitData = {};
                        finalObjBenefitData.sBenefitIds = "";
                        const lstPrograms = [];
                        for (let i = JSONValue.length - 1; i > 0; i = i - 1) {
                            const objProgramList = {};
                            const j = 1;
                            objProgramList.dBenefitEndDate = JSON.parse(
                                JSONValue[i].split(":")[j].split(",")[0]
                            );
                            objProgramList.dBenefitStartDate = JSON.parse(
                                JSONValue[i].split(":")[j + 1].split(",")[0]
                            );
                            objProgramList.sBenefitProgram = JSON.parse(
                                JSONValue[i].split(":")[j + 2].split(",")[0]
                            );
                            if (
                                JSON.parse(
                                    JSONValue[i].split(":")[j + 2].split(",")[0]
                                ) === programConstant.programValues.MA
                            ) {
                                objProgramList.sBenefitId = this.benefitObj.sBenefitMEDICAIDId;
                            } else if (
                                JSON.parse(
                                    JSONValue[i].split(":")[j + 2].split(",")[0]
                                ) === programConstant.programValues.TN
                            ) {
                                objProgramList.sBenefitId = this.benefitObj.sBenefitTANFId;
                            } else if (
                                JSON.parse(
                                    JSONValue[i].split(":")[j + 2].split(",")[0]
                                ) === programConstant.programValues.SN
                            ) {
                                objProgramList.sBenefitId = this.benefitObj.sBenefitSNAPId;
                            }
                            lstPrograms.push(objProgramList);
                        }
                        if (this.selectedStateValue === undefined) {
                            this.selectedStateValue = this.benefitObj.sBenefitState;
                        }
                        if (
                            this.selectedStateValue === undefined ||
                            lstPrograms.length === 0
                        ) {
                            this.hasSaveValidationError = true;
                            this.toastErrorText = this.label.toastErrorText;
                        } else {
                            const a = 4;
                            let x;

                            if (this.actionCheck) {
                                for (
                                    let index = 0;
                                    index < this.lstPrograms.length;
                                    index = index + 1
                                ) {
                                    if (
                                        this.lstPrograms[index].checked ===
                                            false &&
                                        this.lstPrograms[index].value ===
                                            programConstant.programValues.MA
                                    ) {
                                        finalObjBenefitData.sBenefitIds =
                                            finalObjBenefitData.sBenefitIds +
                                            "," +
                                            this.benefitObj.sBenefitMEDICAIDId;
                                    } else if (
                                        this.lstPrograms[index].checked ===
                                            false &&
                                        this.lstPrograms[index].value ===
                                            programConstant.programValues.TN
                                    ) {
                                        finalObjBenefitData.sBenefitIds =
                                            finalObjBenefitData.sBenefitIds +
                                            "," +
                                            this.benefitObj.sBenefitTANFId;
                                    } else if (
                                        this.lstPrograms[index].checked ===
                                            false &&
                                        this.lstPrograms[index].value ===
                                            programConstant.programValues.SN
                                    ) {
                                        finalObjBenefitData.sBenefitIds =
                                            finalObjBenefitData.sBenefitIds +
                                            "," +
                                            this.benefitObj.sBenefitSNAPId;
                                    }
                                }
                                if (
                                    !utility.isUndefinedOrNull(
                                        finalObjBenefitData.sBenefitIds
                                    ) &&
                                    !utility.isEmpty(
                                        finalObjBenefitData.sBenefitIds
                                    )
                                ) {
                                    if (
                                        finalObjBenefitData.sBenefitIds.charAt(
                                            0
                                        ) === ","
                                    ) {
                                        finalObjBenefitData.sBenefitIds = finalObjBenefitData.sBenefitIds.slice(
                                            1
                                        );
                                    }
                                }
                                finalObjBenefitData.sBenefitId = this.benefitObj.sBenefitId;
                                finalObjBenefitData.sBenefitUniqueKey = this.benefitObj.sBenefitUniqueKey;
                            } else {
                                finalObjBenefitData.sBenefitId = null;
                            }
                            finalObjBenefitData.sMemberId = this.benefitObj.sMemberId;
                            finalObjBenefitData.bSnapCheck = this.benefitObj.bSnapCheck;
                            finalObjBenefitData.bTanfCheck = this.benefitObj.bTanfCheck;
                            finalObjBenefitData.bMedicaidCheck = this.benefitObj.bMedicaidCheck;
                            const val = JSONValue.length - 1;
                            const splitValue = JSONValue[val].split(":");
                            if (
                                JSON.parse(splitValue[a - 1].split(",")[0]) ===
                                programConstant.programValues.TN
                            ) {
                                x = 5;
                            } else if (
                                JSON.parse(splitValue[a - 1].split(",")[0]) ===
                                programConstant.programValues.MA
                            ) {
                                x = 4;
                            } else if (
                                JSON.parse(splitValue[a - 1].split(",")[0]) ===
                                programConstant.programValues.SN
                            ) {
                                x = 5;
                            }
                            finalObjBenefitData.sBenefitCounty = JSON.parse(
                                JSONValue[val].split(":")[x].split(",")[0]
                            );
                            if (
                                this.selectedStateValue === null ||
                                this.selectedStateValue === undefined
                            ) {
                                finalObjBenefitData.sBenefitState = this.benefitObj.sBenefitState;
                            } else {
                                finalObjBenefitData.sBenefitState = this.selectedStateValue;
                            }

                            finalObjBenefitData.lstBenefitProgramList = lstPrograms;
                            finalObjBenefitData.bIsInsert = this.actionCheck;
                            upsertAnotherStateBenefits({
                                sBenefitsWrapper: JSON.stringify(
                                    finalObjBenefitData
                                )
                            })
                                .then(result => {
                                    const mapResponse = result.mapResponse;
                                    if (mapResponse.bShowValidationMessage) {
                                        this.hasSaveValidationError = true;
                                        this.programValidationError =
                                            mapResponse.ValidationMessage;
                                    } else {
                                        const buttonActionEvt = new CustomEvent(
                                            programConstant.events.benefitDetailButtonAction,
                                            {
                                                detail: {
                                                    action: "save"
                                                }
                                            }
                                        );
                                        this.dispatchEvent(buttonActionEvt);
                                    }
                                    this.showSpinner = false;
                                })
                                .catch(error => {
                                    console.error(
                                        "### Error While Saving the Record" +
                                            error
                                    );
                                    this.hasSaveValidationError = true;
                                    this.toastErrorText = error.message;
                                    this.showSpinner = false;
                                });
                        }
                    } else {
                        this.hasSaveValidationError = true;
                        this.toastErrorText = this.label.toastErrorText;
                    }
                } else {
                    this.hasSaveValidationError = true;
                    this.customValidationError = this.label.sspSelectProgramError;
                }
            } else {
                this.hasSaveValidationError = true;
            }
            this.showSpinner = false;
         }
        } catch (error) {
            console.error(
                "Error occurred while saving Benefit details" +
                    JSON.stringify(error)
            );
            this.hasSaveValidationError = true;
            this.toastErrorText = error.message;
            this.showSpinner = false;
        }
    };

    /**
     * @function : cancelBenefitDetails
     * @description : This method is used to navigate back to the summary screen when clicks on Cancel.
     */
    cancelBenefitDetails = () => {
        try {
            const buttonActionEvt = new CustomEvent(
                programConstant.events.benefitDetailButtonAction,
                {
                    detail: { action: "cancel" }
                }
            );
            this.dispatchEvent(buttonActionEvt);
        } catch (error) {
            console.error(
                "Error occurred in Benefit Details page" + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : assignValues
     * @description : This method is used to fetch selected value for type ahead picklist.
     * @param {*} event - On change of value in Type ahead picklist.
     */
    assignValues = event => {
        try {
            this.selectedStateValue = event.detail.selectedValue;
            this.isStatePopulated = true;
        } catch (e) {
            console.error("Error in assignValues of Benefits Page", e);
        }
    };

    /**
     * @function : populateStateValue
     * @description : This method is called on change of state for type ahead picklist.
     * @param {*} event - On change of value in Type ahead picklist.
     */
    populateStateValue = event => {
        try {
            this.isStatePopulated = false;
            this.changedStateValue = event.detail.selectedValue;
        } catch (e) {
            console.error("Error in populateStateValue of Benefits Page", e);
        }
    };

    compareDate = event => {
        if (this.actionCheck) {
            if (
                this.benefitObj.sBenefitProgram.includes(
                    programConstant.programValues.MA
                )
            ) {
                this.dateArray[0] = {
                    StartDate: this.benefitObj.dBenefitMEDICADEStartDate,
                    EndDate: this.benefitObj.dBenefitMEDICADEEndDate
                };
            }
            if (
                this.benefitObj.sBenefitProgram.includes(
                    programConstant.programValues.TN
                )
            ) {
                this.dateArray[1] = {
                    StartDate: this.benefitObj.dBenefitTANFStartDate,
                    EndDate: this.benefitObj.dBenefitTANFEndDate
                };
            }
            if (
                this.benefitObj.sBenefitProgram.includes(
                    programConstant.programValues.SN
                )
            ) {
                this.dateArray[2] = {
                    StartDate: this.benefitObj.dBenefitSNAPStartDate,
                    EndDate: this.benefitObj.dBenefitSNAPEndDate
                };
            }
        }
        if (!utility.isUndefinedOrNull(event) && !utility.isEmpty(event)) {
            const index = event.target.getAttribute("data-index");
            if (
                event.target.name === "BeginDate" ||
                event.target.name === "StartDate"
            ) {
                this.eventStartDate = event.target.value;
                if (this.dateArray[index] && this.dateArray[index].StartDate) {
                    this.dateArray[index].StartDate = this.eventStartDate;
                } else {
                    this.dateArray[index] = {
                        StartDate: this.eventStartDate,
                        EndDate:
                            this.dateArray[index] &&
                            this.dateArray[index].EndDate
                                ? this.dateArray[index].EndDate
                                : ""
                    };
                }
                if (
                    !utility.isUndefinedOrNull(this.dateArray[index].EndDate) &&
                    !utility.isEmpty(this.dateArray[index].EndDate)
                ) {
                    if (
                        this.dateArray[index].StartDate >
                        this.dateArray[index].EndDate
                    ) {
                        event.target.nextSibling.childNodes[1].classList.remove(
                            "slds-hide"
                        );
                        this.endDateValidation = this.label.sspEndDateValidatorMessage;
                    } else {
                        event.target.nextSibling.childNodes[1].classList.add(
                            "slds-hide"
                        );
                        this.endDateValidation = "";
                    }
                }
            }
            if (event.target.name === "EndDate") {
                this.eventEndDate = event.target.value;
                if (this.dateArray[index] && this.dateArray[index].EndDate) {
                    this.dateArray[index].EndDate = this.eventEndDate;
                } else {
                    this.dateArray[index] = {
                        StartDate:
                            this.dateArray[index] &&
                            this.dateArray[index].StartDate
                                ? this.dateArray[index].StartDate
                                : "",
                        EndDate: this.eventEndDate
                    };
                }
                if (
                    !utility.isUndefinedOrNull(
                        this.dateArray[index].StartDate
                    ) &&
                    !utility.isEmpty(this.dateArray[index].StartDate)
                ) {
                    if (
                        this.dateArray[index].EndDate <
                        this.dateArray[index].StartDate
                    ) {
                        event.target.nextSibling.classList.remove("slds-hide");
                        this.endDateValidation = this.label.sspEndDateValidatorMessage;
                    } else {
                        event.target.nextSibling.classList.add("slds-hide");
                        this.endDateValidation = "";
                    }
                }
            }
        }
    };
     /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in hideToast of Benefit Details page" +
                    JSON.stringify(error.message)
            );
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
                const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isScreenNotAccessible = false;
                }
                else {
                    this.isScreenNotAccessible = securityMatrix.screenPermission === programConstant.permission.notAccessible;
                }
                if (this.isScreenNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === programConstant.permission.readOnly;
            }
        } catch (error) {
            console.error(
                "Error in highestEducation.constructRenderingMap", error
            );
        }
    }
}