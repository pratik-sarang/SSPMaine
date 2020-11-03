import { track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import requestHearing from "@salesforce/label/c.SSP_RequestHearing";
import programAppealingFor from "@salesforce/label/c.SSP_ProgramAppealingFor";
import programOptionsTitle from "@salesforce/label/c.SSP_ProgramOptionsTitle";
import reasonForAppeal from "@salesforce/label/c.SSP_ReasonForAppeal";
import appealReasonsTitle from "@salesforce/label/c.SSP_AppealReasonsTitle";
import chooseOneMissing from "@salesforce/label/c.SSP_ChooseOneMissing";
import healthImmediateDanger from "@salesforce/label/c.SSP_HealthImmediateDanger";
import commentsText from "@salesforce/label/c.SSP_CommentsText";
import requireAccommodation from "@salesforce/label/c.SSP_RequireAccommodation";
import hearingAccommodation from "@salesforce/label/c.SSP_HearingAccommodation";
import specialAccommodationList from "@salesforce/label/c.SSP_SpecialAccommodationList";
import referencingSpecificNotice from "@salesforce/label/c.SSP_ReferencingSpecificNotice";
import adverseActionNote from "@salesforce/label/c.SSP_AdverseActionNote";
import relatedNoticeTitle from "@salesforce/label/c.SSP_RelatedNoticeTitle";
import changeText from "@salesforce/label/c.SSP_ChangeText";
import changeDocument from "@salesforce/label/c.SSP_ChangeDocument";
import appealWithIndividual from "@salesforce/label/c.SSP_AppealWithIndividual";
import individualOptionsTitle from "@salesforce/label/c.SSP_IndividualOptionsTitle";
import addressRepresentativeNote from "@salesforce/label/c.SSP_AddressRepresentativeNote";
import contactInfoRepresentative from "@salesforce/label/c.SSP_ContactInfoRepresentative";
import firstName from "@salesforce/label/c.SSP_FirstName";
import lastName from "@salesforce/label/c.SSP_LastName";
import organizationName from "@salesforce/label/c.SSP_OrganizationName";
import cancelButton from "@salesforce/label/c.SSP_Cancel";
import requestHearingCancelTitle from "@salesforce/label/c.SSP_RequestHearingCancelTitle";
import submitAppealText from "@salesforce/label/c.SSP_SubmitAppealText";
import submitAppealTitle from "@salesforce/label/c.SSP_SubmitAppealTitle";
import phoneNumber from "@salesforce/label/c.SSP_MyInformationPhoneNumber";
import email from "@salesforce/label/c.SSP_Email";
import noticeNegativeAction from "@salesforce/label/c.SSP_NoticeNegativeAction";
import noticeNegativeActionNote from "@salesforce/label/c.SSP_NoticeNegativeActionNote";
import documents from "@salesforce/label/c.SSP_Documents";
import continueText from "@salesforce/label/c.SSP_Continue";
import cancel from "@salesforce/label/c.SSP_Cancel";
import closePopUpTitle from "@salesforce/label/c.SSP_ClosePopUpTitle";
import finalDocumentSelection from "@salesforce/label/c.SSP_FinalDocumentSelection";
import viewDocument from "@salesforce/label/c.SSP_ViewDocument";
import address from "@salesforce/label/c.SSP_Address";
import addressLine2 from "@salesforce/label/c.SSP_AddressLine2";
import CITY from "@salesforce/label/c.City";
import COUNTY from "@salesforce/label/c.County";
import STATE from "@salesforce/label/c.State";
import ZIP from "@salesforce/label/c.Zip";
import COUNTRY from "@salesforce/label/c.Country";
import received from "@salesforce/label/c.SSP_Received";
import selectOfficialNotice from "@salesforce/label/c.SSP_SelectOfficialNotice";
import continueBenefitsRepayText from "@salesforce/label/c.SSP_ContinueBenefitsRepayQuestion";
import notInterestedHearing from "@salesforce/label/c.SSP_NotInterestedHearing";
import enterSomeOneNew from "@salesforce/label/c.SSP_EnterSomeOneNew";
import cases from "@salesforce/label/c.SSP_Cases";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";

import MAILING_ADDRESS_LINE1 from "@salesforce/schema/SSP_Member__c.MailingAddressLine1__c";
import MAILING_ADDRESS_LINE2 from "@salesforce/schema/SSP_Member__c.MailingAddressLine2__c";
import MAILING_ADDRESS_CITY from "@salesforce/schema/SSP_Member__c.MailingCity__c";
import MAILING_ADDRESS_COUNTY from "@salesforce/schema/SSP_Member__c.MailingCountyCode__c";
import MAILING_ADDRESS_STATE from "@salesforce/schema/SSP_Member__c.MailingStateCode__c";
import MAILING_ADDRESS_COUNTRY from "@salesforce/schema/SSP_Member__c.MailingCountryCode__c";
import MAILING_ADDRESS_ZIP4 from "@salesforce/schema/SSP_Member__c.MailingZipCode4__c";
import MAILING_ADDRESS_ZIP5 from "@salesforce/schema/SSP_Member__c.MailingZipCode5__c";
import getRequestHearingPicklist from "@salesforce/apex/SSP_HearingSummaryController.getRequestHearingPicklist";
import getNegativeNoticeForHearing from "@salesforce/apex/SSP_HearingSummaryController.getNegativeNoticeForHearing";
import sendHearingRequest from "@salesforce/apex/SSP_HearingSummaryController.sendHearingRequest";
import sspUtility, { getYesNoOptions } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import downloadDocumentMethod from "@salesforce/apex/SSP_DocumentCenterCtrl.downloadDocumentMethod";
import getScreenPermission from "@salesforce/apex/SSP_HearingSummaryController.getScreenPermission";
import nonCitizenId from "@salesforce/user/Id";

const sPDFValue = "pdf";

const PA_FIELD_MAP = {
    addressLine1: {
        ...MAILING_ADDRESS_LINE1,
        label: address
    },
    addressLine2: {
        ...MAILING_ADDRESS_LINE2,
        label: addressLine2
    },
    city: {
        ...MAILING_ADDRESS_CITY,
        label: CITY
    },
    county: {
        ...MAILING_ADDRESS_COUNTY,
        label: COUNTY
    },
    state: {
        ...MAILING_ADDRESS_STATE,
        label: STATE
    },
    country: {
        ...MAILING_ADDRESS_COUNTRY,
        label: COUNTRY
    },
    postalCode4: {
        ...MAILING_ADDRESS_ZIP4,
        label: ZIP
    },
    postalCode: {
        ...MAILING_ADDRESS_ZIP5,
        label: ZIP
    }
};

const authArray = [
    {
        label: enterSomeOneNew,
        value: enterSomeOneNew,
        role: null,
        AddressLine2: null,
        CaseNumber: null,
        City: null,
        CountyCode: null,
        RepId: null,
        RepresentativeEmail: null,
        RepresentativeFirstName: null,
        RepresentativeLastName: null,
        RepresentativeOrganisationName: null,
        RepresentativePhoneNo: null,
        Role: null,
        StateCode: null,
        Street: null,
        ZipCode4: null,
        ZipCode5: null
    },
    {
        label: notInterestedHearing,
        value: notInterestedHearing,
        role: null,
        AddressLine2: null,
        CaseNumber: null,
        City: null,
        CountyCode: null,
        RepId: null,
        RepresentativeEmail: null,
        RepresentativeFirstName: null,
        RepresentativeLastName: null,
        RepresentativeOrganisationName: null,
        RepresentativePhoneNo: null,
        Role: null,
        StateCode: null,
        Street: null,
        ZipCode4: null,
        ZipCode5: null
    }
];

export default class SspRequestHearing extends NavigationMixin(sspUtility) {
    toggleButtonOptions = getYesNoOptions();
    canDeleteMembers = true;
    selectNotice;
    exitModal = true;
    responseObject;

    label = {
        requestHearing,
        programAppealingFor,
        programOptionsTitle,
        reasonForAppeal,
        appealReasonsTitle,
        chooseOneMissing,
        healthImmediateDanger,
        commentsText,
        requireAccommodation,
        hearingAccommodation,
        specialAccommodationList,
        referencingSpecificNotice,
        adverseActionNote,
        relatedNoticeTitle,
        changeText,
        changeDocument,
        appealWithIndividual,
        individualOptionsTitle,
        addressRepresentativeNote,
        contactInfoRepresentative,
        firstName,
        lastName,
        organizationName,
        cancelButton,
        requestHearingCancelTitle,
        submitAppealText,
        submitAppealTitle,
        phoneNumber,
        email,
        noticeNegativeAction,
        noticeNegativeActionNote,
        documents,
        continueText,
        cancel,
        closePopUpTitle,
        finalDocumentSelection,
        viewDocument,
        received,
        selectOfficialNotice,
        continueBenefitsRepayText,
        cases,
        notInterestedHearing,
        enterSomeOneNew,
        toastErrorText
    };

    @track programPicklist = [];
    @track reasonPicklist;
    @track accommodationPicklist = [];
    @track casePicklist = [];
    @track caseAuthRepMap = [];
    @track someOneOther = false;
    @track metaDataListParent;
    @track allowSaveValue;
    @track objValue;
    @track reference = this;
    @track showNoticeModal = false;
    @track selectedNotice;
    @track fieldMap = PA_FIELD_MAP;
    @track caseAuthRepList;
    @track specialAccommodationCheck = false;
    @track selectedCase;
    @track showSpinner = true;
    @track repsValues = null;
    @track noticeData = [];
    @track showErrorModal = false;
    @track errorMsg = "";
    @track addressRecord;
    @track showErrorToast = false;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track userId = nonCitizenId;
    @track showCaseNumberPicklist = true;

    @api individualAddress;
    @track languageES = false;

    @api
    get allowSave () {
        return this.allowSaveValue;
    }
    set allowSave (value) {
        if (value !== undefined) {
            this.allowSaveValue = value;
        }
    }

    @api
    get objWrap () {
        return this.objValue;
    }
    set objWrap (value) {
        try {
            if (value) {
                if (value.includes("FirstName")) {
                    this.repsValues = JSON.parse(value);
                } else {
                    this.wrapperValues = JSON.parse(value);
                }
            }
        } catch (error) {
            console.error("error in objWrap", error);
        }
    }

    /**
     * @function : MetadataList
     * @description	: To get MetadataList.
     */
    @api
    get MetadataList () {
        return this.metaDataListParent;
    }
    set MetadataList (value) {
        this.metaDataListParent = value;
    }

    /**
     * @function - connectedCallback
     * @description - Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            const url = new URL(window.location.href);

            if (
                !sspUtility.isUndefinedOrNull(
                    url.searchParams.get("language")
                ) &&
                url.searchParams.get("language") == "es_US"
            ) {
                this.languageES = true;
            }
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "MailingAddressLine1__c,SSP_Member__c",
                "MailingAddressLine2__c,SSP_Member__c",
                "GenderCode__c,SSP_Member__c",
                "HasHouseholdPaidChildSupportToggle__c,SSP_Member__c",
                "Email__c,SSP_Member__c",
                "FirstName__c,SSP_Member__c",
                "HasRealEstatePropertyToggle__c,SSP_Member__c",
                "LastName__c,SSP_Member__c",
                "HasShelterExpenseToggle__c,SSP_Member__c",
                "PrimaryPhoneNumber__c,SSP_Member__c",
                "MatchType__c,SSP_Member__c"
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_Request_Hearing"
            );
            this.getScreenPermission();
            getRequestHearingPicklist()
                .then(result => {
                    this.responseObject = result.mapResponse;
                    this.programPicklist = this.picklistDataFormat(
                        result.mapResponse.hearingProgramMap
                    );
                    this.accommodationPicklist = this.picklistDataFormat(
                        result.mapResponse.hearingAccommodationMap
                    );
                    if(result.mapResponse.individualCaseMap){
                        this.casePicklist = this.picklistDataFormat(
                            result.mapResponse.individualCaseMap
                        );
                    }
                    if(this.casePicklist && this.casePicklist.length === 1){
                        this.handleCaseChange();
                        this.showCaseNumberPicklist = false;
                    }
                    this.caseAuthRepMap = result.mapResponse.caseAuthRepMap;
                  
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(
                        "Error in getting Hearing  Details" +
                            JSON.stringify(error)
                    );
                });
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    }
    /**
     * @function - getScreenPermission
     * @description - Use to search Screen Permission.
     */
    getScreenPermission = () => {
        try {
            getScreenPermission({
                screenId: "SSP_APP_HearingRequest",
                userId: this.userId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.screenAccessDetails
                        )
                    ) {
                        this.constructRenderingAttributes(result.mapResponse);

                        this.showAccessDeniedComponent = !this
                            .isScreenAccessible;
                    } else {
                        console.error(
                            "Error in loading Results" + JSON.stringify(result)
                        );
                    }
                })
                .catch(error => {
                    console.error("Error in getting data", error);
                });
        } catch (error) {
            console.error(
                "Error occurred in getScreenPermission of sspHearingSummary page" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
     * @description : This method is used to construct rendering attributes.
     * @param {object} response - Backend response.
     */
    constructRenderingAttributes = response => {
        try {
            if (
                response != null &&
                response != undefined &&
                response.hasOwnProperty("screenAccessDetails")
            ) {
                //  const { screenPermission: securityMatrix } = response;
                const securityMatrix = response.screenAccessDetails;

                this.isReadOnlyUser =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ===
                        sspConstants.permission.readOnly;
                this.isReadOnlyUser =
                    this.isReadOnlyUser && response.readOnlyUser;
                this.isScreenAccessible =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ===
                        sspConstants.permission.notAccessible
                        ? false
                        : true;
            }
        } catch (error) {
            console.error(JSON.stringify(error.message));
        }
    };

    /**
     * @function - picklistDataFormat
     * @description - Formats the data of picklist value.
     * @param {*} data -
     */
    picklistDataFormat (data) {
        try {
            const objectArray = Object.entries(data);
            const arrayData = [];
            objectArray.forEach(([key, value]) => {
                const objectData = {};
                objectData.label = value;
                objectData.value = key;
                arrayData.push(objectData);
            });
            return arrayData;
        } catch (error) {
            console.error("Error in picklistDataFormat", error);
        }
    }

    /**
     * @function : handleCancel
     * @description : This method is used to fire cancel event for adding member details.
     */
    handleCancel () {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.eligibilityStatus.dashboardUrl
                }
            });
        } catch (error) {
            console.error("Error in handleCancel", error);
        }
    }

    /**
     * @function : handleSubmitHearing
     * @description : This method is used to save the collected data.
     */
    handleSubmitHearing () {
        try {
            const elem = this.template.querySelectorAll(
                ".ssp-applicationInput"
            );
            this.checkValidations(elem);
            let authElem = Array.from(
                this.template.querySelectorAll(".ssp-applicationInputs")
            );
            const addressElement1 = this.template.querySelector(
                ".addressLineClass"
            );
            if (addressElement1) {
                addressElement1.ErrorMessages();
                authElem = authElem.concat(
                    Array.from(addressElement1.inputElements)
                );
            }
            this.checkValidations(authElem);
            if (this.allowSaveValue && this.wrapperValues) {
                this.showSpinner = true;
                this.wrapperValues.DMSDocumentId = this.selectedNotice
                    ? this.selectedNotice.dmsDocumentId__c
                    : null;
                this.wrapperValues.DCCaseNumber = this.casePicklist.length === 1 
                    ?parseInt(this.selectedCase)
                    :parseInt(this.wrapperValues.DCCaseNumber);
                this.wrapperValues.DCContactId = parseInt(
                    this.wrapperValues.DCContactId
                );
                this.repsValues = this.bindAddressFields(this.repsValues);
             
                sendHearingRequest({
                    newHearingData: JSON.stringify(this.wrapperValues),
                    representativeData: this.repsValues
                        ? JSON.stringify(this.repsValues)
                        : null,
                    addressData: JSON.stringify(this.individualAddress)
                })
                    .then(result => {
                        if (result.mapResponse.isSuccess) {
                            if (!result.mapResponse.status) {
                                this.errorMsg = result.mapResponse.Error;
                                this.showErrorModal = true;
                            } else {
                               
                                const requestId = new CustomEvent(
                                    sspConstants.hearing.saveRequestHearing,
                                    {
                                        detail: {
                                            hearingId:
                                                result.mapResponse.hearingId,
                                            requestId:
                                                result.mapResponse
                                                    .hearingRequestId
                                        }
                                    }
                                );

                                this.dispatchEvent(requestId);
                            }
                        } else {
                            this.errorMsg = "";
                            this.showErrorModal = true;
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.error(
                            "Error in getting Hearing Summary Details" +
                                JSON.stringify(error)
                        );
                    });
            } else {
                this.showErrorToast = true;
            }
        } catch (error) {
            console.error("Error in handleSubmitHearing", error);
        }
    }

    /**
     * @function : handleCancelNoticeModal
     * @description : This method is used to close the notice modal.
     */
    handleCancelNoticeModal () {
        try {
            this.showNoticeModal = false;
        } catch (error) {
            console.error("Error in handleCancelNoticeModal", error);
        }
    }

    /**
     * @function : handleContinueNoticeModal
     * @description : This method is used to close the notice modal.
     */
    handleContinueNoticeModal () {
        try {
            this.selectedNotice = this.selectNotice;
            if (this.selectedNotice || this.noticeData.length === 0) {
                this.showNoticeModal = false;
            }
        } catch (error) {
            console.error("Error in handleContinueNoticeModal", error);
        }
    }

    /**
     * @function : handleOfficialNotice
     * @description : This method is used to show the notice modal.
     */
    handleOfficialNotice () {
        try {
            if (this.noticeData.length === 0) {
                this.showSpinner = true;
                this.getNegativeNoticeForHearing();
            } else {
                this.showNoticeModal = true;
            }
        } catch (error) {
            console.error("Error in handleOfficialNotice", error);
        }
    }

    /**
     * @function : handleNoticeChange
     * @description : This method is used to get the selected the notice.
     * @param {*}event - Gives the data of current instance.
     */
    handleNoticeChange (event) {
        try {
            this.selectNotice = this.noticeData.filter(
                item => event.target.value === item.Id
            )[0];
        } catch (error) {
            console.error("Error in handleNoticeChange", error);
        }
    }

    /**
     * @function : removeNotice
     * @description : This method is used to the notice.
     */
    removeNotice () {
        try {
            this.selectedNotice = null;
        } catch (error) {
            console.error("Error in removeNotice", error);
        }
    }

    /**
     * @function : bindAddressFields
     * @description	: Method to bind value to address fields on contact record.
     * @param {object} asset - Contact record.
     */
    bindAddressFields (asset) {
        try {
            const addressLineClass = this.template.querySelector(
                ".addressLineClass"
            );
            if (addressLineClass) {
                let physicalAddress = {};
                physicalAddress = addressLineClass.value;
                asset[
                    sspConstants.assetAddressFields.AddressLine1__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine1)
                    ? physicalAddress.addressLine1
                    : null;
                asset[
                    sspConstants.assetAddressFields.AddressLine2__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.addressLine2)
                    ? physicalAddress.addressLine2
                    : null;
                asset[
                    sspConstants.assetAddressFields.City__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.city)
                    ? physicalAddress.city
                    : null;
                asset[
                    sspConstants.assetAddressFields.CountyCode__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.county)
                    ? physicalAddress.county
                    : null;
                asset[
                    sspConstants.assetAddressFields.StateCode__c
                ] = !sspUtility.isUndefinedOrNull(physicalAddress.state)
                    ? physicalAddress.state
                    : null;
                asset["CountryCode__c"] = !sspUtility.isUndefinedOrNull(
                    physicalAddress.country
                )
                    ? physicalAddress.country
                    : null;
                const zipCode = physicalAddress.postalCode;
                if (!sspUtility.isUndefinedOrNull(zipCode)) {
                    if (zipCode.length === 4) {
                        asset[
                            sspConstants.assetAddressFields.zipCode4
                        ] = zipCode;
                    } else {
                        asset[
                            sspConstants.assetAddressFields.zipCode5
                        ] = zipCode;
                    }
                }
            }
        } catch (error) {
            console.error(
                "failed in sspIncomeDetails.bindAddressFields " +
                    JSON.stringify(error)
            );
        }
        return asset;
    }

    /**
     * @function : handleCaseChange
     * @description : This method is used to the notice.
     * @param {*} event -  This parameter provides the updated value.
     */
    handleCaseChange (event) {
        try {
            this.caseAuthRepList = [];
            this.selectedCase = event?event.target.value:this.casePicklist[0].value;
            const caseAuthRepMap = this.caseAuthRepMap[this.selectedCase ];
           
            if (caseAuthRepMap) {
                this.caseAuthRepList = caseAuthRepMap.map(item => {
                    const buildObject = item;

                    buildObject.label = buildObject.label
                        ? buildObject.label
                        : [
                              item.RepresentativeFirstName,
                              item.RepresentativeLastName
                          ].join(" ");

                    buildObject.value = buildObject.value
                        ? buildObject.value
                        : item.RepId;
                    buildObject.role = item.Role;
                    return buildObject;
                });
            }
            this.caseAuthRepList = this.caseAuthRepList.concat(authArray);
        } catch (error) {
            console.error("Error in handleCaseChange", error);
        }
    }

    /**
     * @function : handleProgramChange
     * @description : This method is used to the notice.
     * @param {*} event -  This parameter provides the updated value.
     */
    handleProgramChange (event) {
        try {
            const reasonPicklist = this.responseObject
                .programToHearingReasonMap[event.target.value];
            this.reasonPicklist = this.picklistDataFormat(reasonPicklist);
        } catch (error) {
            console.error("Error in handleProgramChange", error);
        }
    }

    /**
     * @function : handleAuthChange
     * @description : This method is used to the notice.
     * @param {*} event -  This parameter provides the updated value.
     */
    handleAuthChange (event) {
        try {
            this.someOneOther = false;
            this.selectedAuth = this.caseAuthRepList.filter(item => {
                const currentValue = item.value;

                return event.target.value === currentValue.toString();
            })[0];
            if (
                this.selectedAuth &&
                this.selectedAuth.value !== notInterestedHearing
            ) {
                this.someOneOther = true;
            } else {
                this.someOneOther = false;
            }
            this.repsValues = null;
            this.setAddressLineStructure();
        } catch (error) {
            console.error("Error in handleAuthChange", error);
        }
    }

    /**
     * @function : handleAccommodationToggle
     * @description : This method is used to the notice.
     * @param {*} event -  This parameter provides the updated value.
     */
    handleAccommodationToggle (event) {
        try {
            this.specialAccommodationCheck =
                event.detail.value === sspConstants.toggleFieldValue.yes
                    ? true
                    : false;
        } catch (error) {
            console.error("Error in handleAccommodationToggle", error);
        }
    }
    /**
     * @function - getNegativeNoticeForHearing
     * @description - Use to search Data.
     */
    getNegativeNoticeForHearing = () => {
        try {
            getNegativeNoticeForHearing({
                caseId: this.selectedCase
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !sspUtility.isUndefined(
                            result.mapResponse.negativeDocumentsList
                        )
                    ) {
                        this.showSpinner = false;
                        this.noticeData =
                            result.mapResponse.negativeDocumentsList;

                        this.noticeData = this.noticeData.map(currentItem => {
                            currentItem["CreatedDate"] = this.formatDate(
                                currentItem.MessageCreateDate__c
                            );
                            currentItem.MessageCreateDate__c = this.formatDate(
                                currentItem.MessageCreateDate__c
                            );
                            return currentItem;
                        });
                        this.showNoticeModal = true;
                    } else {
                        console.error(
                            "Error in loading Results" + JSON.stringify(result)
                        );
                    }
                })
                .catch(error => {
                    console.error("Error in getting data", error);
                });
        } catch (error) {
            console.error(
                "Error occurred in getNegativeNoticeForHearing of sspRequestHearing page" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : downloadTheFile
     * @description : Used to download file.
     *  @param {object} event - Js event.
     */
    downloadTheFile = event => {
        try {
            if (event.keyCode === 13 || event.type === "click") {
                this.showSpinner = true;
                const documentData = {};
                const documentName = "notice";
                const extension = "pdf";
                const documentMetadataId = event.target.dataset.metadataId;
                documentData.documentMetaDataId = documentMetadataId
                    ? documentMetadataId
                    : "";

                downloadDocumentMethod({
                    sDocumentData: JSON.stringify(documentData)
                })
                    .then(result => {
                        if (result.bIsSuccess === true) {
                            let base64Data = "";
                            base64Data = result.mapResponse.docBase64Data;
                            const pageUrl =
                                sspConstants.documentCenterHome
                                    .downloadDocumentUrl;

                            if (
                                base64Data &&
                                base64Data !== "ERROR Empty Response"
                            ) {
                                // Start - Download Document Code
                                const userAgentString = navigator.userAgent;
                                const browserIsEdge =
                                    window.navigator.userAgent.indexOf(
                                        "Edge"
                                    ) !== -1;
                                const browserIsSafari =
                                    userAgentString.indexOf("Safari") > -1;
                                const browserIExplorer =
                                    window.navigator &&
                                    window.navigator.msSaveOrOpenBlob
                                        ? true
                                        : false;
                                this.browserIExplorerTemp = browserIExplorer;
                                let fileURL;
                                let fileBlob;
                                //For IE11
                                if (
                                    window.navigator &&
                                    window.navigator.msSaveOrOpenBlob
                                ) {
                                    fileBlob = this.base64ToBlob(
                                        base64Data,
                                        extension
                                    );
                                    window.navigator.msSaveOrOpenBlob(
                                        fileBlob,
                                        documentName
                                    );
                                } else {
                                    if (browserIsEdge || browserIsSafari) {
                                        // Edge Browser or Mozilla Browser or Safari
                                        fileBlob = this.base64ToBlob(
                                            base64Data,
                                            extension
                                        );
                                        fileURL = URL.createObjectURL(fileBlob);
                                    } else {
                                        // Chrome & Firefox
                                        if (extension === sPDFValue) {
                                            fileURL =
                                                "data:application/" +
                                                extension +
                                                ";base64," +
                                                base64Data; // PDF
                                        } else {
                                            fileURL =
                                                "data:image/" +
                                                extension +
                                                ";base64," +
                                                base64Data; // JPEG,PNG,TIFF
                                        }
                                    }
                                    const link = document.createElement("a");
                                    link.download = documentName;
                                    link.href = fileURL;
                                    link.style.display = "none";
                                    link.target = "_blank";
                                    link.click();
                                }
                                // End - Download Document Code
                                // Start - Open in new Tab and Preview the Document
                                let previewUrl = "";
                                previewUrl =
                                    pageUrl +
                                    sspConstants.hearing.DMSID +
                                    documentMetadataId +
                                    "&fileExtension=" +
                                    extension;
                                window.open(previewUrl, "_blank");
                                // End - Open in new Tab and Preview the Document
                            } else {
                                console.error(
                                    "Error occurred in downloadTheFile of downloadTheFile " +
                                        JSON.stringify(result)
                                );
                                this.showErrorModal = true;
                            }
                            this.showSpinner = false;
                        } else {
                            console.error(
                                "Error occurred in downloadTheFile of downloadTheFile " +
                                    result.mapResponse.ERROR
                            );
                            this.showErrorModal = true;
                            this.showSpinner = false;
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        console.error(
                            "Error in downloadTheFile of downloadTheFile" +
                                JSON.stringify(error.message)
                        );
                    });
            }
        } catch (error) {
            console.error(
                "Error in downloadTheFile of downloadTheFile" +
                    JSON.stringify(error.message)
            );
            this.showSpinner = false;
        }
    };

    base64ToBlob (base64String, extension) {
        try {
            let fileBlob;
            const byteCharacters = atob(base64String);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }

            const byteArray = new Uint8Array(byteNumbers);

            if (extension === "pdf") {
                fileBlob = new Blob([byteArray], {
                    type: "application/pdf"
                });
            } else if (
                extension === sspConstants.sspDocUpload.formatJPG ||
                extension === sspConstants.sspDocUpload.formatJPEG
            ) {
                fileBlob = new Blob([byteArray], {
                    type: "image/jpeg"
                });
            } else if (
                extension === sspConstants.sspDocUpload.formatTIF ||
                extension === "tiff"
            ) {
                fileBlob = new Blob([byteArray], {
                    type: "image/tiff"
                });
            } else if (extension === "png") {
                fileBlob = new Blob([byteArray], {
                    type: "image/png"
                });
            }
            return fileBlob;
        } catch (error) {
            console.error(
                "Error in base64ToBlob" + JSON.stringify(error.message)
            );
            return null;
        }
    }

    /**
     * @function - setAddressLineStructure.
     * @description - Use to set the Address Line Structure on Page Load.
     */
    setAddressLineStructure () {
        try {
            //Start - Address Line Structure
            const addressRecord = {};

            const sFields = {};

            const addressLine1 = {};
            addressLine1.displayValue = null;
            addressLine1.value = this.selectedAuth["Street"] || null;
            sFields[sspConstants.hearing.AddressLine1__c] = addressLine1;

            const addressLineTwo = {};
            addressLineTwo.displayValue = null;
            addressLineTwo.value = this.selectedAuth["AddressLine2"] || null;
            sFields[sspConstants.hearing.AddressLine2__c] = addressLineTwo;

            const city = {};
            city.displayValue = null;
            city.value = this.selectedAuth["City"] || null;
            sFields[sspConstants.hearing.City__c] = city;

            const countyCode = {};
            countyCode.displayValue = null;
            countyCode.value = this.selectedAuth["CountyCode"] || null;

            sFields[sspConstants.hearing.CountyCode__c] = countyCode;

            const stateCode = {};
            stateCode.displayValue = null;
            stateCode.value = this.selectedAuth["StateCode"] || null;

            sFields[sspConstants.hearing.StateCode__c] = stateCode;

            const countryCode = {};
            countryCode.displayValue = null;
            countryCode.value = this.selectedAuth["CountryCode__c"] || null;
            sFields[sspConstants.hearing.CountryCode__c] = countryCode;

            const zipCode4 = {};
            zipCode4.displayValue = null;
            zipCode4.value = this.selectedAuth["ZipCode4"] || null;
            sFields[sspConstants.hearing.zipCode4] = zipCode4;

            const zipCode5 = {};
            zipCode5.displayValue = null;
            zipCode5.value = this.selectedAuth["ZipCode5"] || null;
            sFields[sspConstants.hearing.zipCode5] = zipCode5;

            addressRecord.fields = sFields;
            this.addressRecord = JSON.parse(JSON.stringify(addressRecord));

            //End - Address Line Structure
        } catch (error) {
            console.error(
                "Error in setAddressLineStructure" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : formatDate
     * @description : This method is used to format the date.
     * @param {*}inputDate - Passes the date to be formatted.
     */
    formatDate (inputDate) {
        try {
            const date = new Date(inputDate);
            if (!isNaN(date.getTime())) {
                const day = date.getUTCDate().toString();
                const month = (date.getUTCMonth() + 1).toString();

                return (
                    (month[1] ? month : "0" + month[0]) +
                    "/" +
                    (day[1] ? day : "0" + day[0]) +
                    "/" +
                    date.getUTCFullYear()
                );
            }
        } catch (error) {
            console.error("Error in formatDate", error);
        }
    }

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast () {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    }
}
