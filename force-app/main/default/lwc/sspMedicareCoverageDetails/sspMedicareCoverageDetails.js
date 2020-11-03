/*
 * Component Name: sspMedicareCoverageDetails
 * Author: Kyathi,Varun
 * Description: This screen shows the medicare coverage details
 * Date: 1/14/2020.
 */
import { track, api, wire} from "lwc";
import sspCoverageDetailHeading from "@salesforce/label/c.SSP_CoverageDetailHeading";
import sspMedicareType from "@salesforce/label/c.SSP_MedicareType";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import MEDICARETYPE_FIELD from "@salesforce/schema/SSP_Benefits__c.MedicareTypeCode__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import BENEFIT_OBJECT from "@salesforce/schema/SSP_Benefits__c";
import sspStartDate from "@salesforce/label/c.SSP_StartDate";
import sspEndDate from "@salesforce/label/c.SSP_EndDate";
import sspMedicareNumber from "@salesforce/label/c.SSP_MedicareNumber";
import sspMedicareCheckboxLabel from "@salesforce/label/c.SSP_MedicareCheckboxLabel";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCompleteMedicareQuestions from "@salesforce/label/c.SSP_CompleteMedicareQuestions";
import sspCancelCoverageButtonTitle from "@salesforce/label/c.SSP_CancelCoverageButtonTitle";
import sspSaveCoverageButtonTitle from "@salesforce/label/c.SSP_SaveCoverageButtonTitle";
import sspMedicareCoverageCheckboxTitle from "@salesforce/label/c.SSP_MedicareCoverageCheckboxTitle";
import sspOverlappingMedicareCoverageValidator from "@salesforce/label/c.SSP_OverlappingMedicareCoverageErrorMessage";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import programConstant from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import getMedicalCoverageDetail from "@salesforce/apex/SSP_MedicareCoverageDetails.getMedicalCoverageDetail";
import saveMedicalCoverageDetail from "@salesforce/apex/SSP_MedicareCoverageDetails.saveMedicalCoverageDetail";
import utility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspExpenseDetailsEndDateError from "@salesforce/label/c.SSP_ExpenseDetailsEndDateError";
import sspMedicareNumberValidator from "@salesforce/label/c.SSP_MedicareNumberValidator";
import sspEndDateStartDateErrorMessage from "@salesforce/label/c.SSP_EndDateStartDateErrorMessage";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspMedicareCoverageDetails extends utility {
    @api sspBenefitId;
    @api applicationId;
    @api memberId;
    @api timeTravelTodayDate;
    @track medicareTypeOptions = [];
    summaryTitle = "";

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSave () {
        return this.allowSaveData;
    }
    set allowSave (value) {
        if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
            this.allowSaveData = value;
        }
    }
      /**
* Method 		: getObjectInfo.
* 
* @description 	: Standard Method for getting object information.
* @author 		: Kireeti Gora
 
* */

@wire(getObjectInfo, { objectApiName: BENEFIT_OBJECT })
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
    fieldApiName: MEDICARETYPE_FIELD
})
picklistValues ({ error, data }) {
    if (data) {
        this.medicareTypeOptions= data.values;      
    } else if (error) {
        this.error = error;
    }
}
    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        if (value) {
            this.MetaDataListParent = value;

            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0){
                this.constructRenderingMap(null, value); 
            }
        }
    }

    
    @track medicareType;
    @track medicareCoverageDetail;
    @track medicareCoverageDetailWrapper;
    @track isComponentLoaded = false;
    @track memberName;
    @track allowSaveData;
    @track MetaDataListParent;
    @track
    sspEndDateStartDateValidator = sspExpenseDetailsEndDateError;
    @track
    sspMedicareNumberValidator = sspMedicareNumberValidator;
    @track appId;
    @track memberIdValue;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track
    sspEndDateStartDateValidator = sspEndDateStartDateErrorMessage;
    @track disableMedicareType;
    @track disableStartDate;
    @track disableEndDate;
    @track disableMedicareNumber;
    @track disableHasMedicareCoverageButNoInfo;
    @track pageName;

    @track storeMedicareType;
    @track storeStartDate;
    @track storeEndDate;
    @track storeMedicareNumber;

    @track medicareVerification = false;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    label = {
        sspMedicareCoverageCheckboxTitle,
        sspCancelCoverageButtonTitle,
        sspSaveCoverageButtonTitle,
        sspCoverageDetailHeading,
        sspMedicareType,
        sspStartDate,
        sspEndDate,
        sspMedicareNumber,
        sspMedicareCheckboxLabel,
        sspCancel,
        sspSave,
        sspCompleteMedicareQuestions,
        sspOverlappingMedicareCoverageValidator,
        toastErrorText,
        sspPageInformationVerified,
        startBenefitsAppCallNumber
    };
    
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;

    get isDisableHasMedicareCoverageButNoInfo () {  //CD2 2.5 Security Role Matrix.
        return this.disableHasMedicareCoverageButNoInfo || this.isReadOnlyUser;
    }

    /**
     * @function : cancelMedicareDetails
     * @description : This method is used to navigate back to the summary screen when clicks on Cancel.
     */

    cancelMedicareDetails = () => {
        try {
            const buttonActionEvt = new CustomEvent(
                programConstant.events.medicareDetailButtonAction,
                {
                    detail: { action: "cancel" }
                }
            );
            this.dispatchEvent(buttonActionEvt);
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };

    /**
     * @function : Getter setter methods for pageToLoad.
     * @description : Getter setter methods for pageToLoad.
     */
    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }
    /**
     * @function : connectedCallback.
     * @description : Fire an event from connectedCallback to load SSP Benefit Details.
     */
    connectedCallback () {
        try {
            this.summaryTitle = document.title;
            document.title = "Medicare Coverage Details";
            this.showSpinner = true;
            this.label.sspPageInformationVerified = formatLabels(
                this.label.sspPageInformationVerified,
                [this.pageName]
            );
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "MedicareTypeCode__c,SSP_Benefits__c",
                "BeginDate__c,SSP_Benefits__c",
                "EndDate__c,SSP_Benefits__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_MedicareCoverageDetails"
            );
            getMedicalCoverageDetail({
                benefitId: this.sspBenefitId,
                memberId: this.memberId
            })
                .then(result => {
                    this.medicareCoverageDetailWrapper = JSON.parse(
                        JSON.stringify(result.mapResponse.wrapper)
                    );
                    this.timeTravelTodayDate =
                        result.mapResponse.timeTravelTodayDate;
                    this.medicareCoverageDetail = this.medicareCoverageDetailWrapper.benefit;
                    this.memberName = this.medicareCoverageDetailWrapper.memberName;
                    if (
                        this.medicareCoverageDetail &&
                        this.medicareCoverageDetail.MedicareTypeCode__c
                    ) {
                        this.medicareType =
                        this.medicareCoverageDetail.MedicareTypeCode__c;
                        
                    }
                    this.label.sspMedicareCheckboxLabel = formatLabels(
                        sspMedicareCheckboxLabel,
                        [this.memberName]
                    );
                    if (
                        this.medicareCoverageDetail
                            .HasMedicareCoverageButNoInfo__c
                    ) {
                        this.disableMedicareType = true;
                        this.disableStartDate = true;
                        this.disableEndDate = true;
                        this.disableMedicareNumber = true;
                    } else {
                        this.disableMedicareType = false;
                        this.disableStartDate = false;
                        this.disableEndDate = false;
                        this.disableMedicareNumber = false;
                    }
                    if (
                        !utility.isUndefinedOrNull(
                            this.medicareCoverageDetail.Id
                        ) &&
                        this.medicareCoverageDetail.SSP_Member__r
                            .TBQIndividualVerificationCode__c &&
                        !utility.isUndefinedOrNull(
                            this.medicareCoverageDetail.DCId__c
                        )
                    ) {
                        this.disableMedicareType = true;
                        this.disableStartDate = true;
                        this.disableEndDate = true;
                        this.disableMedicareNumber = true;
                        this.disableHasMedicareCoverageButNoInfo = true;
                        this.medicareVerification = true;
                    }
                    this.isComponentLoaded = true;
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        sspConstants.sspBenefitFields
                            .MedicareCoverageDetailsErrorMessage +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    }

    disconnectedCallback () {
        try {
            document.title = this.summaryTitle;
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }

    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast = () => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function : saveMedicareDetails
     * @description : This method is used to saveMedicareDetails.
     */
    saveMedicareDetails = () => {
        try {
            if(this.isReadOnlyUser) {  // CD2 2.5 Security Role Matrix and Program Access.
                this.cancelMedicareDetails();
            } else {
            this.hasSaveValidationError = false;
            const inputElement = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            if (!this.medicareCoverageDetail.HasMedicareCoverageButNoInfo__c) {
                this.checkValidations(inputElement);
                const bCheckValidations = this.allowSaveData;
                const bMedicareNumberValidator = this.medicareNumberValidator();
                const bOverlappingMedicareCoverageValidator = this.overlappingMedicareCoverageValidator();
                const bEndDateStartDateValidator = this.endDateStartDateValidator();
                if (
                    bCheckValidations &&
                    bMedicareNumberValidator &&
                    bOverlappingMedicareCoverageValidator &&
                    bEndDateStartDateValidator
                ) {
                    this.allowSaveData = true;
                } else {
                    this.allowSaveData = false;
                }
            } else {
                this.allowSaveData = true;
            }
            if (
                !utility.isUndefinedOrNull(this.allowSaveData) &&
                this.allowSaveData
            ) {
                const url = new URL(document.location.href);
                const sspMemberId = url.searchParams.get("memberId");
                saveMedicalCoverageDetail({
                    benefit: this.medicareCoverageDetail,
                    memberId: sspMemberId
                })
                    .then(result => {
                        this.cancelMedicareDetails();
                    })
                    .catch(error => {
                        console.error(
                            sspConstants.sspBenefitFields
                                .MedicareCoverageDetailsErrorMessage +
                                JSON.stringify(error)
                        );
                    });
            } else {
                this.hasSaveValidationError = true;
            }
        }
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage +
                    JSON.stringify(error.message)
            );
        }
    };
    /*
     * @function : handleStartDate
     * @description	: Method to assign start date value.
     * @param  {event}
     */
    handleStartDate = event => {
        try {
            this.medicareCoverageDetail[
                sspConstants.sspBenefitFields.BeginDate
            ] = event.target.value;
            this.overlappingMedicareCoverageValidator();
            this.endDateStartDateValidator();
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };
    /*
     * @function : handleEndDate
     * @description	: Method to assign end date value.
     * @param  {event}
     */
    handleEndDate = event => {
        try {
            this.medicareCoverageDetail[sspConstants.sspBenefitFields.EndDate] =
                event.target.value;
            this.overlappingMedicareCoverageValidator();
            this.endDateStartDateValidator();
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };
    /*
     * @function : handleMedicareNumber
     * @description	: Method to assign Medicare Number value.
     * @param  {event}
     */
    handleMedicareNumber = event => {
        try {
            this.medicareCoverageDetail[
                sspConstants.sspBenefitFields.MedicareNumber
            ] = event.target.value;
            this.medicareNumberValidator();
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };
    /*
     * @function : handleMedicareCoverageInfo
     * @description	: Method to assign HasMedicareCoverageButNoInfo value.
     * @param  {event}
     */
    handleMedicareCoverageInfo = event => {
        try {
            this.medicareCoverageDetail[
                sspConstants.sspBenefitFields.HasMedicareCoverageButNoInfo
            ] = event.target.value;
            if (!utility.isUndefinedOrNull(this.medicareCoverageDetail["BeginDate__c"]) && !utility.isEmpty(this.medicareCoverageDetail["BeginDate__c"])) {
                this.storeStartDate = this.medicareCoverageDetail["BeginDate__c"];
            }
            if (!utility.isUndefinedOrNull(this.medicareCoverageDetail["EndDate__c"]) && !utility.isEmpty(this.medicareCoverageDetail["EndDate__c"])) {
                this.storeEndDate = this.medicareCoverageDetail["EndDate__c"];
            }
            if (!utility.isUndefinedOrNull(this.medicareCoverageDetail["MedicareNumber__c"]) && !utility.isEmpty(this.medicareCoverageDetail["MedicareNumber__c"])) {
                this.storeMedicareNumber = this.medicareCoverageDetail["MedicareNumber__c"];
            }
            if (!utility.isUndefinedOrNull(this.medicareType) && !utility.isEmpty(this.medicareType)) {
                this.storeMedicareType = this.medicareType;
            }
            if (event.target.value) {
                // this.template.querySelector("ssp-applicationInputs").ErrorMessageList = [];
                const templateRef = this.template.querySelectorAll(".ssp-applicationInputs");
                templateRef.forEach(element => {
                    element.ErrorMessageList = [];
                });
                this.medicareCoverageDetail["BeginDate__c"] = null;
                this.medicareCoverageDetail["EndDate__c"] = null;
                this.medicareCoverageDetail["MedicareNumber__c"] = null;
                this.medicareType = null;
                this.disableMedicareType = true;
                this.disableStartDate = true;
                this.disableEndDate = true;
                this.disableMedicareNumber = true;
            } else {
                if (
                    utility.isUndefinedOrNull(this.medicareCoverageDetail) &&
                    utility.isEmpty(this.medicareCoverageDetail)
                ) {
                    this.medicareCoverageDetail[
                        "BeginDate__c"
                    ] = this.storeStartDate;
                    this.medicareCoverageDetail[
                        "EndDate__c"
                    ] = this.storeEndDate;
                    this.medicareCoverageDetail[
                        "MedicareNumber__c"
                    ] = this.storeMedicareNumber;
                    this.medicareType = this.storeMedicareType;
                }
                this.disableMedicareType = false;
                this.disableStartDate = false;
                this.disableEndDate = false;
                this.disableMedicareNumber = false;
            }
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };
    /*
     * @function : handleMedicareType
     * @description	: Method to assign Medicare Type value.
     * @param  {event}
     */
    handleMedicareType = event => {
        try {
            const medicareType = event.target.value;
            this.medicareCoverageDetail[
                sspConstants.sspBenefitFields.MedicareTypeCode
            ] = medicareType;
          
        } catch (error) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage + JSON.stringify(error)
            );
        }
    };
    /*
     * @function : medicareNumberValidator
     * @description	: Method to validate Medicare number.
     */
    medicareNumberValidator = () => {
        try {
            const medicareNumber = this.medicareCoverageDetail
                .MedicareNumber__c;
            if (!utility.isUndefinedOrNull(medicareNumber)) {
                const contactInfo = this.template.querySelectorAll(
                    ".ssp-applicationInputs"
                );
                contactInfo.forEach((inputElement, index) => {
                    if (
                        inputElement.getAttribute("data-id") ===
                        sspConstants.sspBenefitFields.MedicareNumber
                    ) {
                        const messageList = contactInfo[index].ErrorMessageList;
                        const indexOfMessage = messageList.indexOf(
                            this.sspMedicareNumberValidator
                        );

                        const alphabets = medicareNumber.replace(
                            new RegExp("[0-9]", "g"),
                            ""
                        );
                        const digit = medicareNumber.replace(
                            new RegExp("[a-zA-z]", "g"),
                            ""
                        );
                        const regexResult =
                            alphabets.length === 1 && digit.length === 9 && new RegExp("^[a-zA-Z0-9]*$", "g").test(medicareNumber)
                                ? true
                                : false;
                        if (
                            indexOfMessage === -1 &&
                            !utility.isUndefinedOrNull(
                                this.medicareCoverageDetail.MedicareNumber__c
                            ) &&
                            !utility.isEmpty(
                                this.medicareCoverageDetail.MedicareNumber__c
                            ) &&
                            regexResult.toString() === "false"
                        ) {
                            messageList.push(this.sspMedicareNumberValidator);
                            this.allowSaveData = false;
                        } else if (
                            indexOfMessage >= 0 &&
                            (regexResult.toString() === "true" ||
                                utility.isEmpty(medicareNumber))
                        ) {
                            messageList.splice(indexOfMessage, 1);
                            this.allowSaveData = true;
                        }

                        contactInfo[index].ErrorMessageList = JSON.parse(
                            JSON.stringify(messageList)
                        );
                    }
                });
            } else {
                this.allowSaveData = true;
            }
        } catch (e) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /*
     * @function : overlappingMedicareCoverageValidator
     * @description	: Method to validate overlapping start date and end date.
     */
    overlappingMedicareCoverageValidator = () => {
        try {
            let overlappingDate = false;
            let overlappedRecord = "";
            const beginDate = Date.parse(
                this.medicareCoverageDetail.BeginDate__c
            );
            const beginDateFormatted = new Date(
                new Date(beginDate).toDateString()
            ).getTime();
            const endDate = Date.parse(this.medicareCoverageDetail.EndDate__c);
            const endDateFormatted = new Date(
                new Date(endDate).toDateString()
            ).getTime();

            this.medicareCoverageDetailWrapper.benefitList.forEach(benefit => {
                const compareStartDate = benefit.BeginDate__c;
                let medicaidType = false;
                const compareStartDateFormatted = new Date(
                    new Date(compareStartDate).toDateString()
                ).getTime();
                const compareEndDate = benefit.EndDate__c;
                const compareEndDateFormatted = new Date(
                    new Date(compareEndDate).toDateString()
                ).getTime();
                if(((this.medicareCoverageDetail.MedicareTypeCode__c === sspConstants.sspBenefitFields.PA || this.medicareCoverageDetail.MedicareTypeCode__c === sspConstants.sspBenefitFields.MD
                ) && (benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.PA || benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.MD
                )) || (  this.medicareCoverageDetail.MedicareTypeCode__c === sspConstants.sspBenefitFields.PB &&
                    benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.PB)){
                        medicaidType = true;
                }
               
                let medicareTypeLabel = "";
               
                if(benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.PA ){
                    medicareTypeLabel =this.medicareTypeOptions.filter(
                        opt =>  opt.value === sspConstants.sspBenefitFields.PA
                    )[0].label;
                }
                if(benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.MD ){
                    medicareTypeLabel = this.medicareTypeOptions.filter(
                        opt =>  opt.value === sspConstants.sspBenefitFields.MD
                    )[0].label;
                }
                if(benefit.MedicareTypeCode__c === sspConstants.sspBenefitFields.PB ){
                    medicareTypeLabel = this.medicareTypeOptions.filter(
                        opt =>  opt.value === sspConstants.sspBenefitFields.PB
                    )[0].label;
                }
                if (
                    beginDateFormatted >= compareStartDateFormatted &&
                    beginDateFormatted <= compareEndDateFormatted &&
                    medicaidType &&
                    this.medicareCoverageDetail.Id !== benefit.Id
                ) {
                    overlappingDate = true;
                    overlappedRecord = medicareTypeLabel;
                    return false;
                } else if (
                    endDateFormatted >= compareStartDateFormatted &&
                    endDateFormatted <= compareEndDateFormatted &&
                    medicaidType &&
                    this.medicareCoverageDetail.Id !== benefit.Id
                ) {
                    overlappingDate = true;
                    overlappedRecord = medicareTypeLabel;

                    return false;
                } else if (
                    compareStartDateFormatted >= beginDateFormatted &&
                    compareStartDateFormatted <= endDateFormatted &&
                    medicaidType &&
                    this.medicareCoverageDetail.Id !== benefit.Id
                ) {
                    overlappingDate = true;
                    overlappedRecord = medicareTypeLabel;

                    return false;
                } else if (
                    compareEndDateFormatted >= beginDateFormatted &&
                    compareEndDateFormatted <= endDateFormatted &&
                    medicaidType &&
                    this.medicareCoverageDetail.Id !== benefit.Id
                ) {
                    overlappingDate = true;
                    overlappedRecord = medicareTypeLabel;

                    return false;
                } else if (isNaN(compareEndDateFormatted)
                    && medicaidType
                    && (isNaN(endDateFormatted) 
                    || (!isNaN(endDateFormatted) && endDateFormatted >= compareStartDateFormatted))) {
                    overlappingDate = true;
                    overlappedRecord = medicareTypeLabel;

                    return false;
                }
            });
        
            if (
                !utility.isUndefinedOrNull(overlappedRecord) &&
                !utility.isEmpty(overlappedRecord)
            ) {
                this.label.sspOverlappingMedicareCoverageValidator = formatLabels(
                    sspOverlappingMedicareCoverageValidator,
                    [overlappedRecord]
                );
            }
            const contactInfo = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            contactInfo.forEach((inputElement, index) => {
                if (
                    inputElement.getAttribute("data-id") ===
                        sspConstants.sspBenefitFields.BeginDate ||
                    inputElement.getAttribute("data-id") ===
                        sspConstants.sspBenefitFields.EndDate
                ) {
                    const messageList = contactInfo[index].ErrorMessageList;
                    const indexOfMessage = messageList.indexOf(
                        this.label.sspOverlappingMedicareCoverageValidator
                    );
                    if (indexOfMessage === -1 && overlappingDate === true) {
                        messageList.push(
                            this.label.sspOverlappingMedicareCoverageValidator
                        );
                        this.allowSaveData = false;
                    } else if (
                        indexOfMessage >= 0 &&
                        overlappingDate === false
                    ) {
                        messageList.splice(indexOfMessage, 1);
                        this.allowSaveData = true;
                    }
                    if (overlappedRecord === "") {
                        messageList.forEach((message, i) => {
                            if (
                                message.includes(
                                    sspConstants.sspBenefitFields.Medicare
                                )
                            ) {
                                messageList.splice(i, 1);
                            }
                        });
                        this.allowSaveData = true;
                    }

                    contactInfo[index].ErrorMessageList = JSON.parse(
                        JSON.stringify(messageList)
                    );
                }
            });
        } catch (e) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
    };
    /*
     * @function : endDateStartDateValidator
     * @description	: Method to validate start date is less than end date.
     */
    endDateStartDateValidator = () => {
        try {
            const contactInfo = this.template.querySelectorAll(
                ".ssp-applicationInputs"
            );
            if (
                !utility.isUndefinedOrNull(
                    this.medicareCoverageDetail.EndDate__c
                ) &&
                !utility.isEmpty(this.medicareCoverageDetail.EndDate__c) &&
                !utility.isUndefinedOrNull(
                    this.medicareCoverageDetail.BeginDate__c
                ) &&
                !utility.isEmpty(this.medicareCoverageDetail.BeginDate__c)
            ) {
               
                contactInfo.forEach((inputElement, index) => {
                    if (
                        inputElement.getAttribute("data-id") ===
                        sspConstants.sspBenefitFields.EndDate
                    ) {
                        const messageList = contactInfo[index].ErrorMessageList;
                        const indexOfMessage = messageList.indexOf(
                            this.sspEndDateStartDateValidator
                        );

                        const startDate = new Date(
                            new Date(
                                this.medicareCoverageDetail.BeginDate__c
                            ).toDateString()
                        ).getTime();

                        const endDate = new Date(
                            new Date(
                                this.medicareCoverageDetail.EndDate__c
                            ).toDateString()
                        ).getTime();
                        if (indexOfMessage === -1 && startDate >= endDate) {
                            messageList.push(this.sspEndDateStartDateValidator);
                            this.allowSaveData = false;
                        } else if (indexOfMessage >= 0 && startDate < endDate) {
                            messageList.splice(indexOfMessage, 1);
                            this.allowSaveData = true;
                        }
                        contactInfo[index].ErrorMessageList = JSON.parse(
                            JSON.stringify(messageList)
                        );
                    }
                });
            } else {
                contactInfo.forEach((inputElement, index) => {
                    if (
                        inputElement.getAttribute("data-id") ===
                        sspConstants.sspBenefitFields.EndDate
                    ) {
                        const messageList = contactInfo[index].ErrorMessageList;
                        const indexOfMessage = messageList.indexOf(
                            this.sspEndDateStartDateValidator
                        );

                        if (indexOfMessage > -1) {
                            messageList.splice(indexOfMessage, 1);
                        }
                        contactInfo[index].ErrorMessageList = JSON.parse(
                            JSON.stringify(messageList)
                        );
                    }
                });
                this.allowSaveData = true;
            }
        } catch (e) {
            console.error(
                sspConstants.sspBenefitFields
                    .MedicareCoverageDetailsErrorMessage,
                e
            );
        }
        return this.allowSaveData;
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
                    this.isPageAccessible = true;
                }
                else {
                    this.isPageAccessible = !(securityMatrix.screenPermission === sspConstants.permission.notAccessible);
                }
                this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
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