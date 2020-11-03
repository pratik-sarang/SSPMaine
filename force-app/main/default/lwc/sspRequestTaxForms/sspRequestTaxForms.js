import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getScreenData from "@salesforce/apex/SSP_RequestTaxFormController.getScreenData";
import taxFormCorrespondenceService from "@salesforce/apex/SSP_RequestTaxFormController.taxFormCorrespondenceService";
import getMyInformationDetails from "@salesforce/apex/SSP_MyInformationController.getMyInformationDetails";
import fireMyInfoCallout from "@salesforce/apex/SSP_RequestTaxFormController.fireMyInfoCallout";
import requestTaxForms from "@salesforce/label/c.SSP_RequestTaxForms";
import sspSubmit from "@salesforce/label/c.sspSubmit";
import sspCancel from "@salesforce/label/c.sspCancel";
import emailAddress from "@salesforce/label/c.SSP_Email";
import sspMail from "@salesforce/label/c.SSP_Mail";
import mailingAddress from "@salesforce/label/c.SSP_Mailing_Address";
import reportAChange from "@salesforce/label/c.SSP_ReportAChange";
import year from "@salesforce/label/c.SSPYear";
import sspFormType from "@salesforce/label/c.SSP_FormType";
import plans from "@salesforce/label/c.SSP_Plans";
import mailingOptionsLabel from "@salesforce/label/c.SSP_InformationSentBy";
import requestTaxFormsInfo from "@salesforce/label/c.SSP_RequestTaxFormsInfo";
import formBButton from "@salesforce/label/c.SSP_GotoFormBPortal";
import clickToGoToTheFormBPortal from "@salesforce/label/c.SSP_ClickToGoToTheFormBPortal";
import sspOKButton from "@salesforce/label/c.SSP_OkButton";
import requestEnRoute from "@salesforce/label/c.SSP_RequestEnRoute";
import contactDCBS from "@salesforce/label/c.SSP_ContactDCBS";
import reportChangeRelatedToMailingAddress from "@salesforce/label/c.SSP_ReportChangeRelatedToYourMailingAddress";
import clickToSubmitFormARequest from "@salesforce/label/c.SSP_ClickToSubmitFormARequest";
import clickToGoBackToTheDashboard from "@salesforce/label/c.SSP_ClickToGoBackToTheDashboard";
import ssp1095AForm from "@salesforce/label/c.SSP_1095AForm";
import noPlanForTheYear from "@salesforce/label/c.SSP_NpPlanForTheYear";
import sspPolicy from "@salesforce/label/c.SSP_Policy";
import sspContinueButton from "@salesforce/label/c.SSP_ContinueButton";
import sspErrorStatus from "@salesforce/label/c.SSP_ErrorStatus";
import constants from "c/sspConstants";
import { updateRecord } from "lightning/uiRecordApi";
import MEMBER_EMAIL from "@salesforce/schema/SSP_Member__c.Email__c";
import NOTIFICATION_METHOD from "@salesforce/schema/SSP_Member__c.PreferredNotificationMethodForTaxCode__c";
import ID_FIELD from "@salesforce/schema/SSP_Member__c.Id";

export default class SspRequestTaxForms extends NavigationMixin(LightningElement) {
    formTypeOptions = ["1095-A", "1095-B"].map(item => ({label: item, value: item}));
    mailingOptions = [{
        label: emailAddress,
        value: "EE"
    }, {
        label: sspMail,
        value: "P"
    }];

    label = {
        formType: sspFormType,
        year,
        plans,
        mailingOptionsLabel,
        emailAddress,
        mailingAddress,
        reportAChange,
        requestTaxFormsInfo,
        formBButton,
        cancel: sspCancel,
        submit: sspSubmit,
        sspOKButton,
        requestEnRoute,
        contactDCBS,
        requestTaxForms,
        clickToGoToTheFormBPortal,
        reportChangeRelatedToMailingAddress,
        clickToSubmitFormARequest,
        clickToGoBackToTheDashboard,
        ssp1095AForm,
        sspMail,
        noPlanForTheYear,
        sspPolicy,
        sspContinueButton,
        sspErrorStatus
    }

    @track yearOptions = [];

    @track selectedMailingOption;

    @track modalOpen = false;
    @track showCorrespondenceErrorModal = false;
    @track correspondenceErrors = [];
    @track showRACModal = false;
    @track noAccess = false;
    @track showSpinner = false;
    @track showErrorModal = false;
    @track disableFormTypeToggle = false;
    @track isEmailValid = false;
    @track isRACEnabled = false;
    @track dataLoading = false;
    @track currentFormTypeSelected;
    @track mailingAddress;
    @track currentYearSelected;
    @track validationConfig = {};
    @track memberDetail = {};
    @track selectedPlans = {}
    @track reference = this;

    get formASelected () {
        //return !this.currentFormTypeSelected || this.currentFormTypeSelected === "1095-A";
        return this.currentFormTypeSelected === "1095-A";
    }

    get formBSelected () {
        return this.currentFormTypeSelected === "1095-B";
    }

    get showEmailAddress () {
        return this.selectedMailingOption === "EE";
    }

    get showMailingAddress () {
        return this.selectedMailingOption === "P";
    }

    get planOptions () {
        const options = this.allPlanOptions || [];
        return options.filter(plan => plan.Year === this.currentYearSelected);
    }

    get hasPlans () {
        return this.planOptions.length > 0;
    }

    get submitButtonDisabled () {
        return !(
            this.currentYearSelected && 
            Object.values(this.selectedPlans).some(e => e) &&
            (this.showMailingAddress || this.showEmailAddress && this.isEmailValid));
    }

    /**
     * @function connectedCallback
     * @description Executes the data fetching call.
     */
    async connectedCallback () {
        try {
            this.showSpinner = true;
            this.dataLoading = true;
            await this.fetchScreenData();
            this.dataLoading = false;
            this.showSpinner = false;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in connectedCallback", error);
        }
    }
    
    /**
     * @function fetchScreenData
     * @description Combined promise of all data fetching promises.
     */
    fetchScreenData = () => 
        Promise.all([
            getScreenData().then(this.handleTaxFormsResponse),
            getMyInformationDetails({ pageParam: "" }).then(this.handleMyInfoResponse)
        ]);
    
    /**
     * @function handleTaxFormsResponse
     * @description Sets properties based on the data received.
     * @param {object} response - Object having list if enrollments.
     */
    handleTaxFormsResponse = (response) => {
        try {
            if(!(response.bIsSuccess && response.mapResponse)) {
                throw response;
            }
            this.noAccess = response.mapResponse.isNotAccessible;
            if(this.noAccess) {
                return;
            }
            if(response.mapResponse.is1095BAccessible === true) {
                this.form1095BPortal = response.mapResponse.portal1095BEndpoint;
                this.form1095BToken = response.mapResponse.portal1095BToken;
                //this.currentFormTypeSelected = "1095-B"; defect #35
            }
            if(response.mapResponse.is1095AAccessible === true) {
                const payload = response.mapResponse.response && response.mapResponse.response.taxForms1095AInfoPayload || {};
                this.yearOptions = payload.ReqTaxFormsYears && payload.ReqTaxFormsYears.map(item => ({label: item.Year, value: item.Year})) || [];
                this.allPlanOptions = payload.ReqTaxFormsEnrollmentDetail || [];
                //this.currentFormTypeSelected = "1095-A";
            }

            if(!(response.mapResponse.is1095BAccessible && response.mapResponse.is1095AAccessible)) {
                this.disableFormTypeToggle = true;
                if(response.mapResponse.is1095BAccessible === true) {
                    this.currentFormTypeSelected = "1095-B";
                }
                else if(response.mapResponse.is1095AAccessible === true) {
                    this.currentFormTypeSelected = "1095-A";
                }
            }

            if(response.mapResponse.validationConfig) {
                this.validationConfig = response.mapResponse.validationConfig.metadataList;
            }
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleTaxFormsResponse", error);
        }
    }

    /**
     * @function handleMyInfoResponse
     * @description Sets properties based on the data received.
     * @param {object} response - Object having email, address and preferred notification method.
     */
    handleMyInfoResponse = (response) => {
        try {
            if(response.bIsSuccess === false || !response.mapResponse) {
                throw response;
            }
            if(response.mapResponse.individualId) {
                this.individualId = response.mapResponse.individualId;
            }
            if(response.mapResponse.memberRecord) {
                this.memberDetail = response.mapResponse.memberRecord;
                this.currentEmail = this.memberDetail.Email__c;
                this.selectedMailingOption = this.memberDetail.PreferredNotificationMethodForTaxCode__c;
                if(this.memberDetail.Email__c) {
                    this.isEmailValid = true;
                }
                else {
                    this.isEmailValid = false;
                }
            }
            this.isRACEnabled = response.mapResponse.showRAC;
            this.mailingAddress = response.mapResponse.mailingAddress;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleMyInfoResponse", error);
        }
    }

    /**
     * @function handleFormTypeChange
     * @description Show/hides the content based on form-type selected.
     * @param {object} event - Event object.
     */
    handleFormTypeChange = (event) => {
        try {
            this.currentFormTypeSelected = event.detail.value;
            if(this.currentFormTypeSelected === "1095-B") {
                this.currentYearSelected = null;
                this.selectedPlans = {};
            }
            else {
                this.currentEmail = this.memberDetail.Email__c;
                this.selectedMailingOption = this.memberDetail.PreferredNotificationMethodForTaxCode__c;
                if(this.memberDetail.Email__c) {
                    this.isEmailValid = true;
                }
            }
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleFormTypeChange", error);
        }
    }

    /**
     * @function handleYearChange
     * @description Filters plan list based on year selected.
     * @param {object} event - Event object.
     */
    handleYearChange = (event) => {
        try {
            this.currentYearSelected = event.detail.value;
            this.selectedPlans = {};
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleYearChange", error);
        }
    }

    /**
     * @function handlePlanSelection
     * @description Adds the selected to a list, which is later used for calling correspondence service.
     * @param {object} event - Event object.
     */
    handlePlanSelection = (event) => {
        try {
            const planId = event.target.dataset.planId;
            const selectedPlansClone = JSON.parse(JSON.stringify(this.selectedPlans));
            selectedPlansClone[planId] = event.target.value;
            this.selectedPlans = selectedPlansClone;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handlePlanSelection", error);
        }
    }

    /**
     * @function handleMailingOptionChange
     * @description Show/Hides email OR address based on selection made.
     * @param {object} event - Event object.
     */
    handleMailingOptionChange = (event) => {
        try {
            this.selectedMailingOption = event.target.value;
            if(this.selectedMailingOption === "EE") {
                this.isEmailValid = !!this.memberDetail.Email__c;
                this.currentEmail = this.memberDetail.Email__c;
            }
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleMailingOptionChange", error);
        }
    }

    /**
     * @function handleEmailChange
     * @description Sets the current email in a property and checks for errors.
     * @param {object} event - Event object.
     */
    handleEmailChange = (event) => {
        try {
            this.currentEmail = event.detail.value;
            const emailElement = this.template.querySelector("c-ssp-base-component-input-email");
            this.isEmailValid = emailElement.ErrorMessages().length === 0;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleEmailChange", error);
        }
    }

    /**
     * @function launchFormBPortal
     * @description Builds complete URL from base URL and token received in response.
     */
    launchFormBPortal = () => {
        try {
            const portalUrl = new URL(this.form1095BPortal);
            portalUrl.searchParams.append("LookUpToken", "NULL");
            portalUrl.searchParams.append("Source", "SSP");
            portalUrl.searchParams.append("EncryptedData", this.form1095BToken);
            window.open(portalUrl.href);
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in launchFormBPortal", error);
        }
    }

    /**
     * @function handleSubmit
     * @description Makes required server calls.
     */
    handleSubmit = async () => {
        try {
            this.showSpinner = true;
            if(this.showEmailAddress && this.memberDetail.Id && 
                (this.currentEmail !== this.memberDetail.Email__c ||
                this.selectedMailingOption !== this.memberDetail.PreferredTaxNotificationMethodCode__c)) {
                const fields = {
                    [ID_FIELD.fieldApiName]: this.memberDetail.Id
                }
                if(this.showEmailAddress && this.currentEmail !== this.memberDetail.Email__c) {
                    fields[MEMBER_EMAIL.fieldApiName] = this.currentEmail;
                }
                if(this.selectedMailingOption !== this.memberDetail.PreferredTaxNotificationMethodCode__c) {
                    fields[NOTIFICATION_METHOD.fieldApiName] = this.selectedMailingOption;
                }
                await updateRecord({ fields });
                if(this.individualId) {
                    const myInfoResponse = await fireMyInfoCallout({
                        individualId: this.individualId
                    });
                    if(myInfoResponse.mapResponse.myInfoResponse.status !== true) {
                        throw myInfoResponse;
                    }
                }
            }
            const selectedPlanList = Object.keys(this.selectedPlans)
                .filter(planId => this.selectedPlans[planId])
            const responseList = await Promise.all(
                selectedPlanList.map(
                    planId => taxFormCorrespondenceService({
                        enrollmentId: planId,
                        year: this.currentYearSelected
                    })
                )
            );
            if(responseList.some(response => response.bIsSuccess === false)) {
                throw responseList;
            }
            if(responseList.some(({ mapResponse }) => mapResponse.response.SaveResultResponse.some(result => result.IsSuccess === "false"))) {
                const errors = responseList.map(({ mapResponse }, index) => ({
                    plan: selectedPlanList[index],
                    errors: mapResponse.response.SaveResultResponse
                        .filter(result => result.IsSuccess === "false")
                        .reduce((Messages, result)  => Messages.concat(result.Messages), [])
                }));
                this.correspondenceErrors = errors;
                this.showCorrespondenceErrorModal = true;
            }
            else {
                this.modalOpen = true;
            }
            this.showSpinner = false;
        }
        catch(error) {
            this.showSpinner = false;
            this.showErrorModal = true;
            console.error("Error in handleSubmit", error);
        }
    }

    /**
     * @function handleCancel
     * @description Take user to home page on click of cancel.
     */
    handleCancel = async () => {
        try {
            this.showSpinner = true;
            await this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: constants.url.home
                }
            });
            this.showSpinner = false;
        }
        catch(error) {
            this.showSpinner = false;
            this.showErrorModal = true;
            console.error("Error in handleCancel", error);
        }
    }

    /**
     * @function handleModalClose
     * @description Set flag to indicate modal is closed.
     */
    handleModalClose = () => {
        try {
            this.modalOpen = false;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleModalClose", error);
        }
    }

    /**
     * @function handleReportAChangeClick
     * @description Opens up RAC modal.
     */
    handleReportAChangeClick = () => {
        try {
            this.showRACModal = true;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleReportAChangeClick", error);
        }
    }

    /**
     * @function handleRACModalClose
     * @description Set flag to indicate modal is closed.
     */
    handleRACModalClose = () => {
        try {
            this.showRACModal = false;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in handleReportAChangeClick", error);
        }
    }

    /**
     * @function sendResponse
     * @description Close 1095A modal.
     */
    sendResponse = () => {
        try {
            this.modalOpen = false;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in sendResponse", error);
        }
    }

    /**
     * @function closeErrorModal
     * @description Close error modal.
     */
    closeErrorModal = () => {
        try {
            this.showErrorModal = false;
        }
        catch(error) {
            console.error("Error in closeErrorModal", error);
        }
    }

    /**
     * @function closeCorrespondenceErrorModal
     * @description Close error modal.
     */
    closeCorrespondenceErrorModal = () => {
        try {
            this.showCorrespondenceErrorModal = false;
            this.correspondenceErrors = [];
        }
        catch(error) {
            console.error("Error in closeCorrespondenceErrorModal", error);
        }
    }
}