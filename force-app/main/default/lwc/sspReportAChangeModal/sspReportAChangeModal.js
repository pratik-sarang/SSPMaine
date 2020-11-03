/**
 * Component Name: sspReportAChangeModal.
 * Author: Yathansh Sharma, Soumyashree Jena.
 * Description: This modal is used to select a case and report a change.
 * Date: 17/12/2019.
 */
import { wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import getProgramFromCache from "@salesforce/apex/SSP_ApplicationController.getProgramFromCache";
import sspReportAChangeTitle from "@salesforce/label/c.SSP_ReportAChange";
import sspSelectPendingCaseNumber from "@salesforce/label/c.SSP_SelectPendingCaseNumber";
import sspTypeOfChangeYouWantToReport from "@salesforce/label/c.SSP_TypeOfChangeYouWantToReport";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspConstants from "c/sspConstants";
import insertCaseApplicationAndAccount from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.insertCaseApplicationAndAccount";
import invokeReverseSSPAddRemoveMemberHelper from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.invokeReverseSSPAddRemoveMemberHelper";
import triggerDashboardServiceCallOut from "@salesforce/apex/SSP_DashboardController.triggerDashboardServiceCallOut";
import updateIndividualId from "@salesforce/apex/SSP_ReportChangeSelectionCtrl.updateIndividualId";
import apConstants from "c/sspConstants";
import { refreshApex } from "@salesforce/apex";
import driverNavigationDetails from "@salesforce/apex/SSP_DashboardController.driverNavigationDetails";
import sspUtility from "c/sspUtility";
export default class sspReportAChangeModal extends NavigationMixin(
    BaseNavFlowPage
) {
    @api applicationList;
    @api origin;

    @track showApplicationTypeError = false;
    @track showApplicationError = false;
    @track openModal = true;
    @track applicationListNew = [];
    @track showSpinner = false;
    @track displayList = [];
    @track changeTypeOptions = sspConstants.reportAChangeTypeOptions;


    @track changeType = "";
    @track reference = this;
    @track responseDataStore;
    @track showCaseDetails = false;
    @track showAnotherUserInProgress = false;

    selectedApplication = "";
    customLabel = {
        sspReportAChangeTitle,
        sspSelectPendingCaseNumber,
        sspTypeOfChangeYouWantToReport,
        sspContinue,
        sspCancel,
        sspRequiredErrorMessage
    };
    applicationId;

    /**
     * @function : connectedCallback.
     * @description : connected callback function.
     */
    connectedCallback () {
        this.showSpinner = true;
        if(this.applicationList) {
            this.handleWireMethod();
        }
        else {
            triggerDashboardServiceCallOut().then(this.handleDashboardServiceCallOutResponse.bind(this));
        }
    }
    /**
     * @function : generateApplicantList.
     * @description : Method to get the list of applications.
     * @param {object} response - : Application List.
     */
    @wire(getProgramFromCache)
    generateApplicantList (response) {
        try {
            this.generateApplicantListWire = response;
            const { error, data } = response;
            if (data) {
                if (data.mapResponse.cacheResponse !== undefined) {
                    const responseData = JSON.parse(
                        data.mapResponse.cacheResponse
                    );
                    this.responseDataStore = responseData;
                    this.handleWireMethod();
                }
            } else if(error) {
                console.error(error);
            }
        } catch (err) {
            console.error(err);
        }
    }

    handleWireMethod () {
        
        if (
            this.applicationList !== null &&
            this.applicationList !== undefined &&
            this.responseDataStore !== null &&
            this.responseDataStore !== undefined
        ) {
            //this.applicationListNew = JSON.parse(this.applicationList);
            const displayItems = [];
            Object.keys(this.responseDataStore).forEach(key => {
                if (this.applicationList.includes(key)) {
                    const wrapperData = {
                        Id: key,
                        Name: key
                    };
                    wrapperData.programList = [];
                    wrapperData.memberList = [];
                    this.responseDataStore[key].forEach(element => {
                        if (
                            !wrapperData.programList.includes(
                                element.ProgramCode
                            )
                        ) {
                            wrapperData.programList.push(element.ProgramCode);
                        }
                        if (
                            !wrapperData.memberList.includes(
                                element.IndividualName
                            )
                        ) {
                            wrapperData.memberList.push(element.IndividualName);
                        }
                    });
                    wrapperData.programs = wrapperData.programList.join(",");
                    wrapperData.members = wrapperData.memberList.join(",");
                    displayItems.push(wrapperData);
                }
            });
            this.displayList = displayItems;
            if (displayItems.length > 1) {
                this.showCaseDetails = true;
            } else {
                this.selectedApplication =
                    displayItems.length === 1 ? displayItems[0].Id : "";
            }

            if(displayItems.length > 0) {
                this.showSpinner = false;
            }
        }
    }

    /**
     * @function handleDashboardServiceCallOutResponse
     * @description Method to handle the change of Application option.
     * @param {object} response - SSP_LightningResponse object.
     */
    handleDashboardServiceCallOutResponse (response) {
        try {    
            if(response && response.mapResponse && response.mapResponse.hasActiveCase) {
                this.applicationList = response.mapResponse.hasActiveCase;
                const refreshPromise = refreshApex(this.generateApplicantListWire);
                if(refreshPromise) {
                    refreshPromise.then(this.handleWireMethod.bind(this));
                }
            }
        }
        catch(error) {
            console.error("Error in handleDashboardServiceCallOutResponse", error);
        }
    }

    /**
     * @function : handleApplicationChange.
     * @description : Method to handle the change of Application option.
     * @param {event} event - : Application option change event.
     */
    handleApplicationChange (event) {
        try {
            this.selectedApplication = event.detail;
        } catch (err) {
            console.error(err);
        }
    }

    /**
     * @function : handleApplicationTypeChange.
     * @description : Method to handle the type of change.
     * @param {event} event - : Change in type event.
     */
    handleApplicationTypeChange (event) {
        try {
            this.changeType = event.target.value;
        } catch (err) {
            console.error(err);
        }
    }

    /**
     * @function : initSave.
     * @description : Method to save the input and process change request.
     */
    initSave () {
        this.showSpinner = true;
        this.showApplicationTypeError = false;
        this.showApplicationError = false;
        if (this.changeType === undefined || this.changeType === "") {
            this.showApplicationTypeError = true;
        }
        if (
            this.selectedApplication === undefined ||
            this.selectedApplication === ""
        ) {
            this.showApplicationError = true;
        }
        if (this.showApplicationError || this.showApplicationTypeError) {
            this.showSpinner = false;
            return;
        }
        try {
            driverNavigationDetails({
                caseNumber: this.selectedApplication
            })
                .then(result => {
                   
                    const response = result.mapResponse;
                    if (response.bIsSuccess === true) {
                        //test data
                        //response.loggedInUserName='test@test.com';
                        //response.availablePrograms.push('MA');
                        let noModal = true;
                        let timeLock = 30;
                        if (!sspUtility.isUndefinedOrNull(response.timeLock)) {
                            timeLock = parseInt(response.timeLock);
                        }
                        if (
                            response.applicationChangedBy !== undefined &&
                            response.loggedInUserName !=
                                response.applicationChangedBy &&
                            !sspUtility.isUndefinedOrNull(
                                response.minutesGap
                            ) &&
                            response.minutesGap <= timeLock
                        ) {
                            this.openModal = false;
                            this.showAnotherUserInProgress = true;
                            noModal = false;
                            this.showSpinner = false;
                        }
                        if (noModal) {
                            this.insertCaseApplicationAndAccountHelper(
                                this.selectedApplication
                            );
                        } else {
                            this.showSpinner = false;
                        }
                    } else {
                        this.showSpinner = false;
                        console.error(
                            "Error in resumeApplication" +
                                JSON.stringify(result)
                        );
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error(
                        "Error in resumeApplication" +
                            JSON.stringify(error.message)
                    );
                });
        } catch (err) {
            console.error(err);
            this.showSpinner = false;
        }
    }

    /**
     * @function : progressValueUpdated
     * @description :  Driver navigation - Process progress behavior.
     *  @param {object} event - Js event.
     */
    progressValueUpdated = event => {
        try {
            this.showAnotherUserInProgress = false;
            const progress = event.detail;
            if (!progress) {
                this.closeModal();
            }
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in progressValueUpdated" + JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - navigateToHomePage
     * @description - Method is used to navigate to home page.
     */
    navigateToHomePage = () => {
        try {
            if (sspUtility.isUndefinedOrNull(this.origin)) {
              this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: apConstants.url.home
                }
            });
          }
          else {
              this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: this.origin
                }
            });
          }
           
        } catch (error) {
            console.error(
                "failed in handleNavigation in header" + JSON.stringify(error)
            );
        }
    };

    closeModal () {
        this.openModal = false;
        this.dispatchEvent(
            new CustomEvent(sspConstants.addAuthRepConstants.close)
        );
        this.navigateToHomePage();
    }

    insertCaseApplicationAndAccountHelper = caseNumber => {
        try {
            //Added by kyathi as part of CD1 Defect
            this.showSpinner = true;
            if (caseNumber) {
                updateIndividualId({
                    caseNumber: caseNumber,
                    individualId: ""
                }).then(result => {
                insertCaseApplicationAndAccount({
                    caseNumber: caseNumber
                })
                    .then(response => {
                        this.applicationId = response.mapResponse.applicationId;
                        if (this.changeType === "add-remove") {
                            this.invokeReverseSSPAddRemoveMemberHelper(
                                this.applicationId,
                                this.selectedApplication
                            );
                        } else {
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName: "report-change-selection"
                                },
                                state: {
                                    memberId: this.memberId,
                                    changeType: this.changeType,
                                    selectedApplication: this
                                        .selectedApplication,
                                    applicationId: this.applicationId,
                                    mode: "RAC"
                                }
                            });
                        }
                    })
                })
                    .catch(error => {
                        console.error(
                            "error in apex call response- insertCaseApplicationAndAccount. Message-",
                            JSON.stringify(error)
                        );
                        this.showSpinner = false;
                    });
            }
        } catch (error) {
            console.error(
                "### Error occurred in - insertCaseApplicationAndAccountHelper ###" +
                    JSON.stringify(error)
            );
        }
    };

    invokeReverseSSPAddRemoveMemberHelper = (applicationId, caseNumber) => {
        try {
            //Added by kyathi as part of CD1 Defect
            // this.openModal = false;
            if (caseNumber && applicationId) {
                invokeReverseSSPAddRemoveMemberHelper({
                    applicationId: applicationId,
                    caseNumber: caseNumber
                })
                    .then(() => {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "household-summary"
                            },
                            state: {
                                applicationId: this.applicationId,
                                mode: "addRemoveMember"
                            }
                        });
                    })
                    .catch(error => {
                        console.error(
                            "error in apex call response- invokeQualifiedCallOutHelper. Message-",
                            JSON.stringify(error)
                        );
                    });
            }
            else {
                this.dispatchEvent(
                    new CustomEvent(sspConstants.addAuthRepConstants.close)
                );
            }
        } catch (error) {
            console.error(
                "### Error occurred in sspReportChangeModal - invokeQualifiedCallOutHelper ###" +
                    JSON.stringify(error)
            );
        }
    };

    get disableAction () {
        return this.displayList.length === 0;
    }
}