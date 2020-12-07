/*
 * Component Name: SspAuthRepsAssistAndAgents.
 * Author: Kireeti Gora, Chirag.
 * Description: This file handles SspAuthRepsAssistAndAgents Screen.
 * Date: 02/01/2020.
 **/
import { track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspUtility from "c/sspUtility";
import USER_ID from "@salesforce/user/Id";
import PROFILE_NAME from "@salesforce/schema/User.Profile.Name";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getAgentDetail from "@salesforce/apex/SSP_RepsAssistersAgentsController.getRepsAssistersAgentsDetails";
import removeAgentDetails from "@salesforce/apex/SSP_RepsAssistersAgentsController.removeRepsAssistersAgentsDetails";
import sspAuthorizedRepresentative from "@salesforce/label/c.SSP_AuthorizedRepresentative";
import sspStart from "@salesforce/label/c.SSP_StartButton";
import sspContentOfAuthorizeRepresentativeScreen1 from "@salesforce/label/c.SSP_ContentOfAuthorizeRepresentativeScreen1";
import sspApplyForBenefits from "@salesforce/label/c.SSP_ApplyForBenefitsPoint";
import sspReportChangesInformation from "@salesforce/label/c.SSP_ReportChangesInformation";
import sspCertifyYourBenefitsApplication from "@salesforce/label/c.SSP_RecertifyYourBenefitsApplication";
import sspReceiveCopyOfNotices from "@salesforce/label/c.SSP_ReceiveCopyOfNotices";
import sspContentOfAuthorizeRepresentativeScreen2 from "@salesforce/label/c.SSP_ContentOfAuthorizeRepresentativeScreen2";
import sspAssist from "@salesforce/label/c.SSP_Assister";
import sspContentOfAuthorizeRepresentativeScreen3 from "@salesforce/label/c.SSP_ContentOfAuthorizeRepresentativeScreen3";
import sspContentOfAuthorizeRepresentativeScreen4 from "@salesforce/label/c.SSP_ContentOfAuthorizeRepresentativeScreen4";
import sspInsuranceAgent from "@salesforce/label/c.SSP_InsuranceAgent";
import sspApplyForMedicaid from "@salesforce/label/c.SSP_ApplyForMedicaid";
import sspApplyForMedicaidOrKIHIPP from "@salesforce/label/c.SSP_ApplyForMedicaidOrKIHIPP";
import sspCertifyYourMedicaidApplication from "@salesforce/label/c.SSP_RecertifyYourMedicaidApplication";
import sspRepsAssistsAgents from "@salesforce/label/c.SSP_RepsAssistersAgents";
import sspAddAuthorizedRepresentative from "@salesforce/label/c.SSP_AddAuthorizedRepresentative";
import sspFindAssist from "@salesforce/label/c.SSP_FindAssistor";
import sspFindInsuranceAgent from "@salesforce/label/c.SSP_FindInsuranceAgent";
import sspConfirmRemoval from "@salesforce/label/c.SSP_ConfirmRemoval";
import sspAreYouSureYouWantToRemove from "@salesforce/label/c.SSP_AreYouSureYouWantToRemove";
import sspFromYourCaseOnceRemoved from "@salesforce/label/c.SSP_FromYourCaseOnceRemovedTheIndividualWillNoLongerHaveAccess";
import sspRemove from "@salesforce/label/c.SSP_Remove";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspAddress from "@salesforce/label/c.SSP_Address";
import sspEditButton from "@salesforce/label/c.SSP_EditButton";
import sspCaseHashColon from "@salesforce/label/c.SSP_CaseHashcolon";
import sspCaseHash from "@salesforce/label/c.SSP_CaseHash";
import sspApplicationCaseHashColon from "@salesforce/label/c.SSP_ApplicationHashColon";
import sspApplicationHash from "@salesforce/label/c.SSP_ApplicationHash";
import sspPermissionDetails from "@salesforce/label/c.SSP_PermissionDetails";
import sspPhone from "@salesforce/label/c.SSP_Phone";
import sspContactInformation from "@salesforce/label/c.SSP_ContactInformation";
import sspOrganization from "@salesforce/label/c.SSP_Organization";
import sspInsuranceCompany from "@salesforce/label/c.SSP_InsuranceCompany";
import sspLanguageS from "@salesforce/label/c.SSP_LanguageS";
import sspAvailability from "@salesforce/label/c.SSP_Availability";
import sspAuthRepToast from "@salesforce/label/c.SSP_AuthRepToast";
import sspAssisterToast from "@salesforce/label/c.SSP_AssisterToast";
import sspAgentToast from "@salesforce/label/c.SSP_AgentToast";
import sspDay from "@salesforce/label/c.SSP_Day";
import sspTime from "@salesforce/label/c.SSP_Time";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspSaveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspAddAuthRepAlt from "@salesforce/label/c.SSP_AddAuthRepAlt";
import sspFindAnAssisterAlt from "@salesforce/label/c.SSP_FindAnAssisterAlt";
import sspFindInsuranceAgentAlt from "@salesforce/label/c.SSP_FindInsuranceAgentAlt";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspConstants from "c/sspConstants";
import changeSummary from "@salesforce/label/c.SSP_ChangeSummary";
import applicationSummary from "@salesforce/label/c.SSP_ApplicationSummary";
import clickToCall from "@salesforce/label/c.SSP_ClickToCall";
import authRepEmailTitle from "@salesforce/label/c.SSP_AuthRepEmailTitle";
import authRepAddressTitle from "@salesforce/label/c.SSP_AuthRepAddressTitle";
import sspAuthRepEditTitle from "@salesforce/label/c.SSP_AuthRepEditTitle";
import sspAuthRepRemoveTitle from "@salesforce/label/c.SSP_AuthRepRemoveTitle";
import sspAuthRepRemoveAssistTitle from "@salesforce/label/c.SSP_AuthRepRemoveAssistorTitle";
import sspAuthRepRemoveInsuranceTitle from "@salesforce/label/c.SSP_AuthRepRemoveInsuranceTitle";
import applicationSummaryAlt from "@salesforce/label/c.SSP_ApplicationSummaryAlt";
import getCaseOwnershipFlag from "@salesforce/apex/SSP_MyInformationController.getCaseOwnershipFlag";
import renewalSummary from "@salesforce/label/c.SSP_RenewalSummary";
import sspAddAuthRepDescriptionText from "@salesforce/label/c.SSP_AddAuthRepDescriptionText";
import sspStartBenefitsAppContactAssisterListFour from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListFour";
import sspStartBenefitsAppContactAssisterListFive from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListFive";
import sspStartBenefitsAppContactAssisterListSix from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListSix";

export default class SspAuthRepsAssistAndAgents extends NavigationMixin(
    sspUtility
) {
    titles = {
        [sspConstants.mode.addRemoveMember]: changeSummary,
        [sspConstants.applicationMode.RAC]: changeSummary,
        [sspConstants.applicationMode.INTAKE]: applicationSummary,
        [sspConstants.applicationMode.RENEWAL]: renewalSummary
    };

    customLabel = {
        sspExitButton,
        sspAddAuthRepAlt,
        sspFindAnAssisterAlt,
        sspFindInsuranceAgentAlt,
        sspAuthorizedRepresentative,
        sspContentOfAuthorizeRepresentativeScreen1,
        sspApplyForBenefits,
        sspReportChangesInformation,
        sspCertifyYourBenefitsApplication,
        sspReceiveCopyOfNotices,
        sspContentOfAuthorizeRepresentativeScreen2,
        sspAssist,
        sspContentOfAuthorizeRepresentativeScreen3,
        sspContentOfAuthorizeRepresentativeScreen4,
        sspInsuranceAgent,
        sspApplyForMedicaid,
        sspApplyForMedicaidOrKIHIPP,
        sspCertifyYourMedicaidApplication,
        sspRepsAssistsAgents,
        sspAddAuthorizedRepresentative,
        sspFindAssist,
        sspFindInsuranceAgent,
        sspConfirmRemoval,
        sspAreYouSureYouWantToRemove,
        sspFromYourCaseOnceRemoved,
        sspEditButton,
        sspRemove,
        sspCancel,
        sspEmail,
        sspAddress,
        sspCaseHashColon,
        sspCaseHash,
        sspPermissionDetails,
        sspPhone,
        sspContactInformation,
        sspOrganization,
        sspInsuranceCompany,
        sspLanguageS,
        sspAvailability,
        sspDay,
        sspTime,
        sspNext,
        sspBack,
        sspSaveAndExit,
        sspApplicationCaseHashColon,
        sspApplicationHash,
        sspAuthRepEditTitle,
        sspAuthRepRemoveTitle,
        sspAuthRepRemoveAssistTitle,
        sspAuthRepRemoveInsuranceTitle,
        sspStart,
        sspAddAuthRepDescriptionText,
        sspStartBenefitsAppContactAssisterListFour,
        sspStartBenefitsAppContactAssisterListFive,
        sspStartBenefitsAppContactAssisterListSix
    };

    @track showExit = false;
    @track sspContactId = "";
    @track sspApplicationId = "";
    @track applicationId = "";
    @track showAuthRepModification = false;
    @track showAllDetails = false;
    @track authRepsHomePage = true;
    @track sspConstants = sspConstants;
    @track authorizedRepresentativeRecords = [];
    @track assistRecords = [];
    @track insuranceAgentRecords = [];
    @track individualInsuranceRecord;
    @track hasMedicaid = false;
    @track showRemoveModal = false;
    @track removeModalContent;
    @track showInsuranceAgentCard = false;
    @track showAssistCard = false;
    @track hasRequiredPrograms = false;
    @track recordToRemove;
    @track dataToRefresh;
    @track error = false;
    @track isAuthRepAccessRequest = false;
    @track recordToRemoveRole;
    @track recordToRemoveApplicationId;
    @track isHeadOfHousehold = false;
    @track showSpinner = true;
    @track selectedType;
    @track showFind = false;
    @track flowName;
    @track isApplicationSummary = false;
    @track saveExit = false;
    @track reference = this;
    @track isAuthenticatedView = false;
    @track showNonAuthenticatedView = false;
    @track contactDataLoaded = false;
    @track connectedCallbackLoaded = false;
    @track toastMessage = "";
    @track showToast = false;
    @track showEdit = false;
    @track showAdd = false;
    @track showRemove = false;
    @track showRemoveAuthRep = false;
    @track mode;
    @track errorCode;
    @track showErrorModal =false;
    @track showWorkerPortalBanner = false;
    @track caseOwner;
    @track disableNext = false;
    @track individualId="";

    screenId = "REPS_Home";

    get summaryTitle () {
        return this.titles[this.mode];
    }

    get pageTitleAlt () {
        const searchMask = applicationSummary;
        const regEx = new RegExp(searchMask, "i");
        return applicationSummaryAlt.replace(regEx, this.titles[this.mode]);
    }


    /**
     * @function 		: getCaseOwnerInfo.
     * @description 	: Standard method for getting case owner info.
     * */
    @wire(getCaseOwnershipFlag)
    getCaseOwnerInfo ({ error, data }) {
        try{
            if (!sspUtility.isUndefinedOrNull(data)) {
                this.caseOwner = data;
                if (this.caseOwner.includes(sspConstants.headerConstants.CHANGE)) {
                    this.showWorkerPortalBanner = true;
                } else {
                    this.showWorkerPortalBanner = false;
                }
                
            } else if (error) {
                console.error(
                    "Error in wiredHOHFlag wire call" +
                        JSON.stringify(error.message)
                );
            }
        } catch (error) {
            console.error(
                "failed in getMyInformation in getCaseOwnerInfo" +
                JSON.stringify(error)
            );
        }
    }


    /**
     * @function connectedCallback
     * @description Fetch the applicationId from URL.
     * @author Ajay Saini
     */
    connectedCallback () {

        alert('inside connected callback');


        const url = new URL(window.location.href);
        this.applicationId = url.searchParams.get("applicationId");
        this.mode = url.searchParams.get("mode");
        if (
            this.mode && (this.mode !== sspConstants.applicationMode.INTAKE)
        ) {
            this.showExit = true;
        }
        if (!BaseNavFlowPage.isUndefinedOrNull(this.applicationId)) {
            this.isApplicationSummary = true;
        }
        this.connectedCallbackLoaded = true;
        if (USER_ID !== null && USER_ID !== undefined) {
            this.showSpinner = true;
            this.showNonAuthenticatedView = false;
            this.fetchDataOnLoad();
        } else if (USER_ID === null || USER_ID === undefined) {
            this.showAllDetails = false;
            this.showNonAuthenticatedView = true;
            this.showSpinner = false;
            this.isAuthenticatedView = false;
        }
    }
    // this.handleProfileView();

    handleProfileView () {
        if (this.contactDataLoaded && this.connectedCallbackLoaded) {
            if (USER_ID !== null && USER_ID !== undefined) {
                this.showSpinner = true;
                this.showNonAuthenticatedView = false;
                this.fetchDataOnLoad();
            } else if (USER_ID === null || USER_ID === undefined) {
                this.showAllDetails = false;
                this.showNonAuthenticatedView = true;
                this.showSpinner = false;
            }
        }
    }
    /**
     * @function 		: addAuthRep.
     * @description 	: method to handle Add Auth Rep Section .
     **/
    addAuthRep = () => {
        try {
            if (!BaseNavFlowPage.isUndefinedOrNull(this.applicationId)) {
                this.sspApplicationId = this.applicationId;
            } else {
                this.sspApplicationId = null;
            }
            this.sspContactId = null;
            this.showAllDetails = false;
            this.showAuthRepModification = true;
            this.isAuthRepAccessRequest = false;
            this.flowName = this.sspConstants.addAuthRepConstants.addAuthRep;
        } catch (error) {
            console.error(
                "failed in addAuthRep in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    };

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME]
    })
    getContactData ({ error, data }) {
        if (data) {
            this.dataToRefresh = data;
            this.contactName = getFieldValue(data, PROFILE_NAME);
            if (
                getFieldValue(data, PROFILE_NAME) !== null &&
                getFieldValue(data, PROFILE_NAME) !== undefined &&
                getFieldValue(data, PROFILE_NAME) === "RE Citizen Profile"
            ) {
                this.isAuthenticatedView = true;
                this.showNonAuthenticatedView = false;
            } else {
                this.isAuthenticatedView = false;
                this.showNonAuthenticatedView = true;
            }
        } else if (error) {
            this.showNonAuthenticatedView = true;
            this.error = error;
        }
        this.contactDataLoaded = true;
        //  this.handleProfileView ();
    }

    /**
     * @function 		: getAgentDetail.
     * @description 	: method to fetch  record details .
     * @returns {string}  : JSON of Object Record.
     * */
    fetchDataOnLoad () {
        getAgentDetail({
            sspApplicationId: this.applicationId,
            mode: this.mode
        }).then(result => {
            try {
                if (result) {
                    if (
                        "hasNoAccess" in result.mapResponse
                    ) {
                        this.handleNavigateSummary();

                    }
                    if (
                        "authorizedRepresentativeRecords" in result.mapResponse
                    ) {
                        this.authorizedRepresentativeRecords = JSON.parse(
                            result.mapResponse.authorizedRepresentativeRecords
                        );
                        this.authorizedRepresentativeRecords.forEach(record => {
                            this.formatDataForMasking(record);
                        });
                    }
                    if (
                        "disableNext" in result.mapResponse
                    ) {
                      this.disableNext = true;
                    }else {
                      this.disableNext =false;
                    }
                    if (
                        "IndividualId" in result.mapResponse
                    ) {
                        this.individualId =
                            result.mapResponse.IndividualId;
                       
                       
                    }
                    if ("insuranceAgentRecords" in result.mapResponse) {
                        this.showInsuranceAgentCard = true;
                        this.insuranceAgentRecords = JSON.parse(
                            result.mapResponse.insuranceAgentRecords
                        );
                        this.insuranceAgentRecords.forEach(record => {
                            this.formatDataForMasking(record);
                        });
                    }
                    if ("assistRecords" in result.mapResponse) {
                        this.showAssistCard = true;
                        this.assistRecords = JSON.parse(
                            result.mapResponse.assistRecords
                        );
                        this.assistRecords.forEach(record => {
                            this.formatDataForMasking(record);
                        });
                    }
                    if ("hasMedicaid" in result.mapResponse) {
                        this.hasMedicaid = true;
                    }
                    if ("hasRequiredPrograms" in result.mapResponse) {
                        this.hasRequiredPrograms = true;
                    }
                    if ("isHeadOfHousehold" in result.mapResponse) {
                        this.isHeadOfHousehold = true;
                    }
                    if ("showRemoveAuthRep" in result.mapResponse) {
                        this.showRemoveAuthRep = true;
                    }
                    if ("showRemove" in result.mapResponse) {
                        this.showRemove = true;
                    }
                    if ("showEdit" in result.mapResponse) {
                        this.showEdit = true;
                    }
                    if ("showAddButton" in result.mapResponse) {
                        this.showAdd = true;
                    }
                    if ("hasNoContext" in result.mapResponse) {
                        this.showNonAuthenticatedView = true;
                        this.isAuthenticatedView = false;
                        this.showAllDetails = false;
                    } else {
                        this.showAllDetails = true;
                        this.isAuthenticatedView = true;
                        this.showNonAuthenticatedView = false;
                    }

                    this.showSpinner = false;
                    if (this.toastMessage !== "") {
                        this.showToast = true;
                    }
                    
                    //this.showFind = false;
                } else if (result.error) {
                    console.error(result.error);
                }
            } catch (error) {
                console.error(
                    "failed in getRecordDetails in SspAuthRepsAssistAndAgents" +
                        JSON.stringify(error)
                );
            }
        });
    }
    handleHideToast () {
       

        this.toastMessage = "";
        this.showToast = false;
    }
    /**
     * @function 	: formatDataForMasking.
     * @description 	: Applies masking and other changes to record data.
     * @param {record} record - Record which needs to be masked.
     **/
    formatDataForMasking = record => {
        try {
            record.formattedEmail = `mailto:${record.contactEmail}`;
            record.formattedPhone = `tel:${record.contactPhone}`;
            record.emailTitle = `${authRepEmailTitle} ${record.contactEmail}`;
            record.AddressTitle = `${authRepAddressTitle} ${record.mailingAddress}`;
            if (
                record.contactPhone === undefined ||
                record.contactPhone === null
            ) {
                record.maskedPhone = "";
                return;
            }
            if (record.contactPhone.match(/^\d{3}-\d{3}-\d{4}$/)) {
                record.maskedPhone = record.contactPhone;
            } else {
                const formatted = record.contactPhone
                    .replace(/\D/g, "")
                    .match(/(\d{3})(\d{3})(\d{4})/);
                record.maskedPhone =
                    formatted[1] + "-" + formatted[2] + "-" + formatted[3];
            }
            record.PhoneTitle = `${clickToCall} ${record.maskedPhone}`;
        } catch (error) {
            console.error(
                "failed in formatDataForMasking in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: openRemoveModal.
     * @description 	: method to handle show/hide Pop Up .
     * @param {event} event - Gets current value.
     **/
    openRemoveModal = event => {
        try {
            const userName = event.target.dataset.name;
            this.recordToRemove = event.target.dataset.id;
            this.recordToRemoveRole = event.target.dataset.role;
            this.recordToRemoveApplicationId = event.target.dataset.appId;
            this.showRemoveModal = true;
            this.removeModalContent =
                this.customLabel.sspAreYouSureYouWantToRemove +
                " " +
                userName +
                " " +
                this.customLabel.sspFromYourCaseOnceRemoved;
        } catch (error) {
            console.error(
                "failed in openRemoveModal in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function 		: closeRemoveModal.
     * @description 	: method to handle show/hide Pop Up .
     **/
    closeRemoveModal = () => {
        try {
            this.showRemoveModal = false;
        } catch (error) {
            console.error(
                "failed in closeRemoveModal in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: removeRecord.
     * @description 	: method to remove records.
     **/
    removeRecord = () => {
        try {
            this.showSpinner = true;
            this.showRemoveModal = false;
            removeAgentDetails({
                relationId: this.recordToRemove,
                role: this.recordToRemoveRole,
                applicationId: this.recordToRemoveApplicationId
            })
                .then(result => {
                   
                    if(result.mapResponse.hasOwnProperty("isSuccess") && result.mapResponse.isSuccess){
                    this.showInsuranceAgentCard = false;
                    this.showAssistCard = false;
                    this.hasRequiredPrograms = false;
                    this.isHeadOfHousehold = false;
                    this.insuranceAgentRecords = [];
                    this.isAuthRepAccessRequest = false;
                    this.authorizedRepresentativeRecords = [];
                    this.assistRecords = [];
                    this.connectedCallback();
                    this.showAllDetails = true;
                    this.showAuthRepModification = false;
                    }else if (result.mapResponse.hasOwnProperty("ERROR")){
                        this.errorCode = result.mapResponse.ERROR;
                        this.showErrorModal = true;
                        this.showSpinner = false;
                    }else if (result.mapResponse.hasOwnProperty("isSuccess") && (!result.mapResponse.isSuccess)){
                        this.errorCode = "Exception";
                        this.showErrorModal = true;
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                });
        } catch (error) {
            console.error(
                "failed in removeRecord in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    };
    closeError = () =>{
        this.errorCode = "";
        this.showErrorModal = false;
    }
    /**
     * @function - handleClose.
     * @description - method to remove records.
     * @param {event} event - Gets current value.
     **/
    handleClose = event => {
        try {
            this.showSpinner = true;
            this.showInsuranceAgentCard = false;
            this.showAssistCard = false;
            this.hasRequiredPrograms = false;
            this.showRemoveModal = false;
            this.isHeadOfHousehold = false;
            this.isAuthRepAccessRequest = false;
            this.authorizedRepresentativeRecords =[];
            if (event !== null && event !== undefined && event.detail) {
                this.toastMessage = sspAuthRepToast;
            }
            this.showAuthRepModification = false;
            this.showFind = false;            
            this.connectedCallback();
        } catch (error) {
            console.error(
                "failed in removeRecord in sspAuthRepsAssistAndAgents.handleClose" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function 		: handleCancel.
     * @description 	: method to handle show/hide sections.
     **/
    handleCancel = () => {
        try {
            if (this.isAuthenticatedView) {
                this.showAllDetails = true;
            } else {
                this.showNonAuthenticatedView = true;
            }
            this.showAuthRepModification = false;
            this.isAuthRepAccessRequest = false;
            this.showFind = false;
        } catch (error) {
            console.error(
                "failed in removeRecord in sspAuthRepsAssistAndAgents.handleClose" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function editRecord
     * @description Method to handle click of edit button.
     * @param {object} event - Onchange JS event.
     **/
    editRecord = event => {
        try {
            this.sspApplicationId = event.target.dataset.appId;
            this.sspContactId = event.target.dataset.contactId;
            this.showAllDetails = false;
            this.showAuthRepModification = true;
            this.isAuthRepAccessRequest = false;
            this.flowName = this.sspConstants.addAuthRepConstants.updateAuthRep;
        } catch (error) {
            console.error(
                "failed in removeRecord in sspAuthRepsAssistAndAgents.editRecord" +
                    JSON.stringify(error)
            );
        }
    };

     /**
     * @function handleAuthRepAccessRequest
     * @description Method to handle click of start button for auth rep request.
     * @param {object} event - Onchange JS event.
     **/
    handleAuthRepAccessRequest = event => {
        try {
            this.sspApplicationId = event.target.dataset.appId;
            this.sspContactId = event.target.dataset.contactId;
            this.isAuthRepAccessRequest = true;
            this.showAllDetails = false;
            this.showAuthRepModification = true;
            this.flowName = this.sspConstants.addAuthRepConstants.addAuthRep;
        } catch (error) {
            console.error(
                "failed in removeRecord in sspAuthRepsAssistAndAgents.editRecord" +
                    JSON.stringify(error)
            );
        }
    };

    findAssisterOrAgent = event => {
        this.selectedType = event.target.dataset.type;
        this.showFind = true;
        this.showAllDetails = false;
        this.showNonAuthenticatedView = false;
        this.isAuthRepAccessRequest = false;
        window.scroll(0, 0);
    };

    completeFind = event => {
        this.showSpinner = true;
        this.showFind = false;
        this.showInsuranceAgentCard = false;
        this.showAssistCard = false;
        this.hasRequiredPrograms = false;
        this.showRemoveModal = false;
        this.isHeadOfHousehold = false;
        this.isAuthRepAccessRequest = false;              
        //  this.showAllDetails = false;
        this.showAuthRepModification = false;
        if (event.detail === sspConstants.agentModalConstants.assist) {
            this.toastMessage = sspAssisterToast;
        } else if (event.detail === sspConstants.contactRecordTypes.Agent) {
            this.toastMessage = sspAgentToast;
        }
        this.connectedCallback();
    };

    /**
     * @function : handleNavigateSummary.
     * @description : This method is used to navigate to Application Summary.
     */
    handleNavigateSummary () {
        try {
            this.navigateToAppSummary(this.screenId);
        } catch (error) {
            console.error("Error in navigateApplication", error);
        }
    }
    handleNextNavigateSummary () {
        try {
            if (
                !BaseNavFlowPage.isUndefinedOrNull(this.applicationId)
            ) {
                this.markScreenComplete(this.screenId);
            }
            this.navigateToAppSummary(this.screenId);
        } catch (error) {
            console.error("Error in navigateApplication", error);
        }
    }
   
    /**
     * @function : handleExitButton
     * @description : This method is used to take the user back to application summary screen.
     */
    handleExitButton () {
        try {
            this.saveExit = true;
        } catch (error) {
            console.error("Error in handleExitButton", error);
        }
    }

    /**
     * @function : handleOnlyExit
     * @description : This method is used to take the user back to dashboard.
     */
    handleOnlyExit () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "dashboard__c"
                }
            });
        } catch (error) {
            console.error("Error in handleExitButton", error);
        }
    }
    handleAssisterRequest () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "assister_access_request__c"
                },
                state: {
                    applicationId: this.applicationId,
                    individualId: this.individualId
                }
            });
        } catch (error) {
            console.error("Error in handleExitButton", error);
        }
    }
    /**
     * @function : closeExitModal.
     * @description : This method is used to close save and exit modal.
     */
    closeExitModal () {
        this.saveExit = false;
    }
}