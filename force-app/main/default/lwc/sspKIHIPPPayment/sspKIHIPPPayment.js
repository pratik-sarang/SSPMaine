/**
 * Component Name: SspKIHIPPPayment
 .* Author: Sharon Roja
.* Description: This component creates a screen for KI-HIPP Preferred Payment Method.
* Date: 03/07/2020.
*/
import { track, api, wire } from "lwc";
import sspPreferredPaymentQuestion from "@salesforce/label/c.SSP_PreferredPaymentQuestion";
import sspPreferredPaymentPolicyHolder from "@salesforce/label/c.SSP_PreferredPaymentPolicyHolder";
import sspPreferredPaymentAddress from "@salesforce/label/c.SSP_PreferredPaymentAddress";
import sspPreferredPaymentRouting from "@salesforce/label/c.SSP_PreferredPaymentRouting";
import sspPreferredPaymentAccount from "@salesforce/label/c.SSP_PreferredPaymentAccount";
import sspPreferredPaymentVerifyAccount from "@salesforce/label/c.SSp_PreferredPaymentVerifyAccount";
import sspPreferredPayment1Label from "@salesforce/label/c.SSP_PreferredPayment1";
import sspPreferredPayment2Label from "@salesforce/label/c.SSP_PreferredPayment2";
import sspKihippPreferredPayment from "@salesforce/label/c.SSP_KihippPreferredPayment";
import sspAddressLabel1Label from "@salesforce/label/c.SSP_AddressLabel1";
import sspAddressLabel2Label from "@salesforce/label/c.SSP_AddressLabel2";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspRoutingNumberMaxLimitErrorMessageLabel from "@salesforce/label/c.SSP_RoutingNumberMaxLimitErrorMessage";
import sspInvalidRoutingNumberErrorMessageLabel from "@salesforce/label/c.SSP_InvalidRoutingNumberErrorMessage";
import sspInvalidRoutingNumberLengthErrorMessageLabel from "@salesforce/label/c.SSP_InvalidRoutingNumberLengthErrorMessage";
import sspVerifyAccountErrorMessageLabel from "@salesforce/label/c.SSP_VerifyAccountErrorMessage";
import sspSummaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import sspPreferredPaymentLearnMoreModalAltText from "@salesforce/label/c.SSP_PreferredPaymentLearnMoreModalAltText";
import sspPreferredPaymentAlternateText from "@salesforce/label/c.SSP_PreferredPaymentAlternateText";
import sspResourceSelectionLearnMore from "@salesforce/label/c.SSP_LearnMoreLink";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import sspPreferredPaymentSelectQuestion from "@salesforce/label/c.SSP_PreferredPaymentSelectQuestion";
import sspDirectDepositCheckingAccountMessage from "@salesforce/label/c.SSP_DirectDepositCheckingAccountMessage";
import sspPreferredPaymentTitle from "@salesforce/label/c.SSP_PreferredPaymentTitle";
import sspConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspSave from "@salesforce/label/c.SSP_Save";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspSelect from "@salesforce/label/c.SSP_Select";
import sspSaveKIHIPP from "@salesforce/label/c.SSP_SaveKIHIPP";
import getKIHIPPreferredPaymentMethod from "@salesforce/apex/SSP_KIHIPPPayment.getKIHIPPreferredPaymentMethod";
import { CurrentPageReference } from "lightning/navigation";
import SSPMEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";
import SSPINSTITUTION_OBJECT from "@salesforce/schema/SSP_Institution__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import PREFEREEDISSUANCEMETHOD_FIELD from "@salesforce/schema/SSP_Member__c.PreferredIssuanceMethod__c";
import MAILINGSTATECODE_FIELD from "@salesforce/schema/SSP_Member__c.MailingStateCode__c";
import PHYSICALCOUNTRYCODE_FIELD from "@salesforce/schema/SSP_Member__c.PhysicalCountyCode__c";
import BANKSTATECODE_FIELD from "@salesforce/schema/SSP_Institution__c.StateCode__c";
import BANKCOUNTYCODE_FIELD from "@salesforce/schema/SSP_Institution__c.County__c";
import getBankDetails from "@salesforce/apex/SSP_KIHIPPPayment.getBankDetails";
import pushChangeDataToExternalSystem from "@salesforce/apex/SSP_KIHIPPPayment.pushChangeDataToExternalSystem";
import { formatLabels } from "c/sspUtility";
import PREFERRED_ISSUANCE_METHOD from "@salesforce/schema/SSP_Member__c.PreferredIssuanceMethod__c";
import ROUTING_NUMBER from "@salesforce/schema/SSP_Member__c.RoutingNumber__c";
import CHECKING_ACCOUNT_NUMBER from "@salesforce/schema/SSP_Member__c.CheckingAccountNumber__c";
import sspUtility from "c/sspUtility";

export default class SspKIHIPPPayment extends NavigationMixin(sspUtility) {
@wire(CurrentPageReference)
currentPageReference;
@api IndividualIds;
@api caseNumber;
@api PolicyHolderId;
@api jsonpreferredPaymentMethod;
@track preferredPaymentOptions;
@track mailingStateCodeDate;
@track PhysicalCountryCode;
@track bankStateCode;
@track bankCountyCode;
@track MetaDataListParent = {};


@wire(getKIHIPPreferredPaymentMethod, { recordId: "$IndividualIds" })
contactIndividualIds;
@track selectedPreferredPaymentMethodLabels = "EFT";
@track value;
@track CheckingAccountNumber;
@track fullName;
@track FirstName;
@track RoutingNumber;
@track PaymentAddress;
@track isLoading = false;
@track isLearnMoreModal = false;
@track allowSave;
@track showToast = false;
@track trueValue = true;
@track showSpinner = false;
@track reference = this;
@track isDirectDeposit = true;
@track showBankDetails = true;
@track isCheck = true;
@track allowSaveValue;
@track spinnerOn = false;
@track modValue;
@track policyHolderName;
@track defaultRecordTypeIDmem;
@track defaultRecordTypeIDForSSPInstituation;
parameters = {};
@track checkSelected= false;
@track verifyAccountNumberValue;
@track MailingCountyCode;
@track MailingStateCode;
@track selectedMailingCountyCode;
@track selectedMailingStateCode;
@track MailingZipCode5;
@track bankAddressLine1;
@track bankCompleteAddress;
@track bankStateCodeFromData;
@track selectedBankStateCodeFromData;
@track bankCountyCodeFromData;
@track SelectedBankCountyCode;
@track bankZipCode;
@track bankName;
@track bankCity;
@track showErrorModal = false;
@track errorCode = "";

appFieldList = [
    PREFERRED_ISSUANCE_METHOD,
    ROUTING_NUMBER,
    CHECKING_ACCOUNT_NUMBER
];

label = {
    sspSaveKIHIPP,
    sspSave,
    sspCancel,
    sspSelect,
    sspPreferredPaymentQuestion,
    sspResourceSelectionLearnMore,
    sspPreferredPaymentPolicyHolder,
    sspPreferredPaymentRouting,
    sspPreferredPaymentAccount,
    sspPreferredPaymentVerifyAccount,
    sspPreferredPayment1Label,
    sspPreferredPayment2Label,
    sspAddressLabel1Label,
    sspAddressLabel2Label,
    sspRoutingNumberMaxLimitErrorMessageLabel,
    sspInvalidRoutingNumberErrorMessageLabel,
    sspInvalidRoutingNumberLengthErrorMessageLabel,
    sspVerifyAccountErrorMessageLabel,
    sspSummaryRecordValidator,
    sspPreferredPaymentSelectQuestion,
    sspPreferredPaymentAlternateText,
    sspLearnMoreModalContent,
    sspPreferredPaymentAddress,
    sspPreferredPaymentLearnMoreModalAltText,
    toastErrorText,
    sspDirectDepositCheckingAccountMessage,
    sspKihippPreferredPayment,
    sspPreferredPaymentTitle
};

maxLength = sspConstants.preferredPaymentConstants.maxLength;
minLength = sspConstants.preferredPaymentConstants.minLength;

/**
 * @function - get MetadataList.
 * @description - MetadataList getter method for framework.
 */
@api
get MetadataList () {
    
    return this.MetaDataListParent;
}

/**
 * @function - set MetadataList.
 * @description - Next Event setter method for framework.
 * @param {string} value - Setter for MetadataList framework property.
 */
set MetadataList (value) {
    try {
        if (value) {
            this.MetaDataListParent = value;
        }
    } catch (e) {
        console.error(
            "Error in set MetadataList of Short SNAP Contact page",
            e
        );
    }
}

/**
 * @function : Getter setter methods for modalContentValue.
 * @description : Getter setter methods for LearnMoreModal.
 */
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
 * @function : openLearnMoreModal
 * @description	: Method to open learn more modal.
 */
openLearnMoreModal = () => {
    try {
        this.isLearnMoreModal = true;
    } catch (error) {
        console.error(
            "Error in openLearnMoreModal:" + JSON.stringify(error.message)
        );
    }
};

/**
 * @function : closeLearnMoreModal
 * @description	: Method to close learn more modal.
 */
closeLearnMoreModal = () => {
    try {
        this.isLearnMoreModal = false;
    } catch (error) {
        console.error(
            "Error in closeLearnMoreModal:" + JSON.stringify(error.message)
        );
    }
};
/**
 * @function : objectInfo
 * @description	: Wire function to get SSP_Member Object.
 */

@wire(getObjectInfo, {
    objectApiName: SSPMEMBER_OBJECT
})
objectInfo ({data,error}){
    if(data){
        this.defaultRecordTypeIDmem = data.defaultRecordTypeId;
    } else if (error) {
        this.error = error;
    }
}
/**
 * @function :     getPicklistValues
 * @description	: Method to get Payment Options.
 */
@wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeIDmem",
    fieldApiName: PREFEREEDISSUANCEMETHOD_FIELD
})
getPaymentPicklistValues ({ error, data }) {
    if (data) {
        this.preferredPaymentOptions = data.values;
        this.getKIHIPPPreferredPaymentMethodDetails();
    } else if (error) {
        console.error("error: ", error);
        this.error = error;
    }
}
/**
 * @function :     getPicklistValues
 * @description	: Method to get Mailing state code picklist and convert as per value.
 */
@wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeIDmem",
    fieldApiName: MAILINGSTATECODE_FIELD
})
getMailingStateCodePicklistValues ({ error, data }) {
    if (data) {
        this.mailingStateCodeDate = data.values;
    } else if (error) {
        console.error("error: ", error);
        this.error = error;
    }
}

/**
 * @function :     getPicklistValues
 * @description	: Method to get Mailing Country code picklist and convert as per value.
 */
@wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeIDmem",
    fieldApiName: PHYSICALCOUNTRYCODE_FIELD
})
getPhysicalCountryCodePicklistValues ({ error, data }) {
    if (data) {
        this.PhysicalCountryCode = data.values;
    } else if (error) {
        console.error("error: ", error);
        this.error = error;
    }
}

@wire(getObjectInfo, {
    objectApiName: SSPINSTITUTION_OBJECT
})
objectInfoOfSSPINSTITUTION ({data,error}){
    if(data){                                   
        this.defaultRecordTypeIDForSSPInstituation = data.defaultRecordTypeId;
    } else if (error) {
        this.error = error;
    }
}
/**
 * @function :     getPicklistValues
 * @description	: Method to get Bank state code picklist and convert as per value.
 */
@wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeIDForSSPInstituation",
    fieldApiName: BANKSTATECODE_FIELD
})
getBankStateCode ({ error, data }) {
    if (data) {
        this.bankStateCode = data.values;
    } else if (error) {
        console.error("error: ", error);
        this.error = error;
    }
}

/**
 * @function :     getPicklistValues
 * @description	: Method to get Bank County code picklist and convert as per value.
 */
@wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeIDForSSPInstituation",
    fieldApiName: BANKCOUNTYCODE_FIELD
})
getBankCountyCode ({ error, data }) {
    if (data) {
        this.bankCountyCode = data.values;
    } else if (error) {
        console.error("error: ", error);
        this.error = error;
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
        console.error("Error Occurred::: ", JSON.stringify(error.message));
        return null;
    }
}
set allowSave (value) {
    try {
        if (!sspUtility.isUndefinedOrNull(value)) {
            this.allowSaveValue = value;
        }
    } catch (error) {
        console.error("Error Occurred::: ", JSON.stringify(error.message));
    }
}

/**
 * @function : connectedCallback
 * @description	: Method to load payment information.
 */
connectedCallback () {
    try {
        
        this.showHelpContentData("SSP_APP_HealthCare_PreferredPayment");
        this.parameters = this.getQueryParameters();
        this.policyHolderName = decodeURIComponent(this.parameters.policyHolderName);
        this.spinnerOn = true;
        const fieldList = this.appFieldList.map(
            item => item.fieldApiName + "," + item.objectApiName
        );
        this.getMetadataDetails(fieldList, null, "SSP_APP_Healthcare_PreferredPayment");
        this.spinnerOn = false;
    } catch (error) {
        console.error("error in connectedCallback " , error);
        this.spinnerOn = false;
    }
}

getKIHIPPPreferredPaymentMethodDetails = () => {
    try{
        this.spinnerOn = true;
        getKIHIPPreferredPaymentMethod({
            IndividualIds: this.parameters.IndividualIds
        })
        .then(result => {
            //Added for Defect#- 391377
            if (!sspUtility.isUndefinedOrNull(result)) {
                this.responseBody = result;
                this.bindData(JSON.parse(result));
            }
            this.spinnerOn = false;
        })
        .catch(error => {
            console.error("error in getKIHIPPPreferredPaymentMethodDetails: ", error);
            this.spinnerOn = false;
        });
    } catch (error) {
        console.error("error in getKIHIPPPreferredPaymentMethodDetails " , error);
        this.spinnerOn = false;
    }
}

getQueryParameters () {

    let params = {};
    const search = location.search.substring(1);

    if (search) {
        params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"').replace("+"," ") + '"}', (key, value) => {
            return key === "" ? value : decodeURIComponent(value)
        });
    }
    return params;
}

getBankDetailsForApex () {
    try {
        this.spinnerOn = true;
        getBankDetails({
            routingNumber : this.RoutingNumber
        })
        .then(result => {
            if(result!=null){
                    this.responseBody=result;
                this.bankDetailBindData(JSON.parse(JSON.stringify(result)));  
            }
        this.spinnerOn = false;
        })
        .catch(error => {
            console.error("error: ", error);
        }); 
    } catch (error) {
        console.error("error in connectedCallback " + error);
    }
}

handleValidateRoutingNumber (event) {
    this.RoutingNumber = event.target.value;
    this.checkRoutingNumberLength();
}
handleAccountNumber (event) {
    this.CheckingAccountNumber = event.target.value;
}

handleOnChangePreferredPaymentMethod (event) {
    this.selectedPreferredPaymentMethodLabels = event.target.value;

    if (this.selectedPreferredPaymentMethodLabels === "CH" || this.selectedPreferredPaymentMethodLabels === "Check") {
            this.checkSelected = true;
    } else if (this.selectedPreferredPaymentMethodLabels === "EFT" || this/this.selectedPreferredPaymentMethodLabels === "Direct Deposit to Checking Account"){
            this.checkSelected = false;
    } 
}

verifyAccountValidation (event){
    this.verifyAccountNumberValue = event.target.value;
    this.checkSSNMatch();
}

/**
* @function - renderedCallback
* @description - This method is used to called whenever there is track variable changing.

*/
renderedCallback () {
    try {
        const sectionReference = this.template.querySelector(
            ".ssp-learnMore"
        );
        if (sectionReference) {
            sectionReference.innerText = this.modValue.HelpModal__c;
        }
    } catch (error) {
        console.error("Error in renderedCallback", error);
    }
}
handleCancelButton = () => {
    this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
            name: "Benefits_Page__c"
        }
    });
};

checkRoutingNumberLength = () => {
    try {
        const ssnMatchElement1 = this.template.querySelector(
            ".ssp-preferredRoutingNumber"
        );
        let errorList = JSON.parse(
            JSON.stringify(ssnMatchElement1.ErrorMessageList)
        );
        
        const message = "Routing number must be of 9 digit";
        if (!sspUtility.isUndefinedOrNull(ssnMatchElement1)) {
            if(this.RoutingNumber.length !== 9 ) {
                if (!errorList.includes(message)) {
                    errorList.push(message);
                }
            } else {
                if (errorList) {
                    errorList = errorList.filter(item => item !== message);
                }
            }
            ssnMatchElement1.ErrorMessageList = errorList;
        }
    } catch (error) {
        console.error("Error in handleSSNMatch:", error);
    }
};

checkSSNMatch = () => {
    try {
        const ssnMatchElement = this.template.querySelector(
            ".ssp-verifyAccountNumber"
        );
        let errorList = JSON.parse(
            JSON.stringify(ssnMatchElement.ErrorMessageList)
        );
        
        const message = "Enter the same Account number";
        if (!sspUtility.isUndefinedOrNull(ssnMatchElement)) {
            if(this.verifyAccountNumberValue !== this.CheckingAccountNumber) {
                if (!errorList.includes(message)) {
                    errorList.push(message);
                }
            } else {
                if (errorList) {
                    errorList = errorList.filter(item => item !== message);
                }
            }
            ssnMatchElement.ErrorMessageList = errorList;
        }
    } catch (error) {
        console.error("Error in handleSSNMatch:", error);
    }
};

checkSelectedPaymentMethodRequest = () => {
    try{
        if (this.selectedPreferredPaymentMethodLabels === "CH" || this.selectedPreferredPaymentMethodLabels === "Check"){
            this.RoutingNumber=" ";
            this.CheckingAccountNumber=" ";
            this.bankName=" ";
            this.bankZipCode=" ";
            this.selectedBankStateCodeFromData=" ";
            this.bankCity= " ";
            this.bankCompleteAddress= " ";
        } 

    } catch (error) {
        console.error("Error in checkSelectedPaymentMethodRequest:", error);
    }
}

handleSaveButton = () => {

    this.showToast = false;
    let allowNavigation = true;
    const elem = this.template.querySelectorAll(".ssp-applicationInputs");
    this.checkValidations(elem);
    this.checkSSNMatch();
    for (const element of elem) {
        if ( element.ErrorMessageList && element.ErrorMessageList.length) {
                        allowNavigation= false;
                        this.showToast = true;
                    }
    }
    this.checkSelectedPaymentMethodRequest();
    
        if(allowNavigation === true){
        pushChangeDataToExternalSystem({caseNumber:this.parameters.caseNumber,PolicyHolderId:this.parameters.PolicyHolderId,accountNumber:this.CheckingAccountNumber,IssuanceMethodCode:this.selectedPreferredPaymentMethodLabels,RoutingNumber:this.RoutingNumber,
            BankName:this.bankName,BankZipCode:this.bankZipCode,BankStateCode:this.selectedBankStateCodeFromData,BankCity:this.bankCity,bankAddress:this.bankCompleteAddress})
        .then(data=>{
            this.spinnerOn =true;
            this.showErrorModal = false;

            if(JSON.parse(data).Status === true || (JSON.parse(data).Status === true && JSON.parse(data).Error.ErrorDescription === "Same data submitted")){

                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Benefits_Page__c"
                    }
                });
                this.spinnerOn=false;
            } else {
                this.showErrorModal = true;
                console.error("error: ", data);
            }
            this.spinnerOn=false;
        }).catch(error=>{
            console.error("error: ", error);
        });
        }  
};

closeError = () => {
    this.showErrorModal = false;
}

bindData (result) {

    //Added for Defect#- 391377
    this.label.sspPreferredPaymentSelectQuestion = formatLabels(
        this.label.sspPreferredPaymentSelectQuestion,
        [this.policyHolderName]
    );
    this.label.sspPreferredPaymentAddress  = formatLabels(
        this.label.sspPreferredPaymentAddress,
        [this.policyHolderName]
    );

    // Outer most IF block - Added for Defect#- 391377
    if (!sspUtility.isUndefinedOrNull(result.KIHIPPPreferredPaymentPayload) &&
        !sspUtility.isUndefinedOrNull(result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment) &&
        (result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment).length > 0
    ) {

        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .CheckingAccountNumber != undefined
        ) {
            this.CheckingAccountNumber =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].CheckingAccountNumber;
            this.verifyAccountNumberValue =  result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].CheckingAccountNumber;
        }
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .FirstName != undefined &&
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .LastName != undefined
        ) {
            this.fullName =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                    .FirstName +
                " " +
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                    .LastName;
        }

        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .RoutingNumber != undefined
        ) {
            this.RoutingNumber =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].RoutingNumber;
                this.getBankDetailsForApex();
        }
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingCountyCode != undefined
        ) {
            this.MailingCountyCode =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].MailingCountyCode;
        }
        for (const element of this.PhysicalCountryCode) {
            if (element.value === this.MailingCountyCode) {
                this.selectedMailingCountyCode = element.label;
            }
        }
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingStateCode != undefined
        ) {
            this.MailingStateCode =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].MailingStateCode;
        }

        for (const element of this.mailingStateCodeDate) {
            if (element.value === this.MailingStateCode) {
                this.selectedMailingStateCode = element.label;
            }
        }
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingZipCode5 != undefined
        ) {
            this.MailingZipCode5 =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].MailingZipCode5;
        }
    
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingAddressLine1 != undefined ||
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingAddressLine2 != undefined ||
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .MailingCity != undefined
        ) {
            this.PaymentAddress =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                    .MailingAddressLine1 +
                " " +
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                    .MailingAddressLine2 +
                " " +
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                    .MailingCity;
        }

        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .FirstName != undefined
        ) {
            this.FirstName =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].FirstName;
        }
        if (
            result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0]
                .PreferredIssuanceMethod != undefined
        ) {
            this.jsonpreferredPaymentMethod =
                result.KIHIPPPreferredPaymentPayload.KIHIPPPreferredPayment[0].PreferredIssuanceMethod;
        } else {
            this.jsonpreferredPaymentMethod = "EFT";
        }
        for (const element of this.preferredPaymentOptions) {
            if (element.value === this.jsonpreferredPaymentMethod) {
                this.selectedPreferredPaymentMethodLabels = element.value;
                if (this.selectedPreferredPaymentMethodLabels === "CH" || this.selectedPreferredPaymentMethodLabels === "Check") {
                    this.checkSelected = true;
                } else if (this.selectedPreferredPaymentMethodLabels === "EFT" || this.selectedPreferredPaymentMethodLabels === "Direct Deposit to Checking Account"){
                    this.checkSelected = false;
                } 
            }
        }
    }
}

bankDetailBindData (result){
    if(result.mapResponse.bankDetails.AddressLine1__c != undefined && result.mapResponse.bankDetails.AddressLine2__c != undefined){
        this.bankCompleteAddress = result.mapResponse.bankDetails.AddressLine1__c +" "+result.mapResponse.bankDetails.AddressLine2__c;
    } 
    else if (result.mapResponse.bankDetails.AddressLine1__c != undefined && result.mapResponse.bankDetails.AddressLine2__c == undefined){
        this.bankCompleteAddress = result.mapResponse.bankDetails.AddressLine1__c;
    } else if (result.mapResponse.bankDetails.AddressLine2__c != undefined && result.mapResponse.bankDetails.AddressLine1__c == undefined){
        this.bankCompleteAddress = result.mapResponse.bankDetails.AddressLine2__c;
    }

    if(result.mapResponse.bankDetails.City__c != undefined){
        this.bankCity= result.mapResponse.bankDetails.City__c;
    }
    if(result.mapResponse.bankDetails.Name__c != undefined){
        this.bankName = result.mapResponse.bankDetails.Name__c;
    }

    if(result.mapResponse.bankDetails.ZipCode__c != undefined){
        this.bankZipCode = result.mapResponse.bankDetails.ZipCode__c;
    }
    
    if(result.mapResponse.bankDetails.StateCode__c != undefined){
        this.bankStateCodeFromData = result.mapResponse.bankDetails.StateCode__c;
    }
    for (const element of this.bankStateCode) {
        if (element.value === this.bankStateCodeFromData) {
            this.selectedBankStateCodeFromData = element.label;
        }
    }
    if(result.mapResponse.bankDetails.County__c != undefined){
        this.bankCountyCodeFromData = result.mapResponse.bankDetails.County__c;
    }
    for (const element of this.bankCountyCode) {
        if (element.value === this.bankCountyCodeFromData) {
            this.SelectedBankCountyCode = element.label;
        }
    }
}
}