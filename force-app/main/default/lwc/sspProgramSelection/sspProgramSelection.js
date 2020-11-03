/**
 * Component Name - sspProgramSelection.js.
 * Author         - Chaitanya Kanakia, Nupoor Nimbalkar.
 * Description    - The Program Selection page collects the household - level programs
 *                  for the application .These selections drive the application flow.
 * Date           - 11/12/2019.
 */
import { track, api } from "lwc";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspProgramSelectionTitle from "@salesforce/label/c.SSP_ProgramSelectionTitle";
import sspProgramSelectionDesc from "@salesforce/label/c.SSP_ProgramSelectionDesc";
import sspProgramSelectionNote from "@salesforce/label/c.SSP_ProgramSelectionNote";
import sspBenefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import sspAtLeastOneSelectorMessage from "@salesforce/label/c.SSP_ProgramSelErrMsg";
import sspSaveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import sspSaveAndExitAltText from "@salesforce/label/c.SSP_SaveAndExitAltText";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspNextAltText from "@salesforce/label/c.SSP_NextAltText";
import sspProgramSelectionLearnMoreAlt from "@salesforce/label/c.SSP_ProgramSelectionLearnMoreAlt";
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";
import updatePrograms from "@salesforce/apex/SSP_ProgramSelectionCtrl.updatePrograms";
import getPrograms from "@salesforce/apex/SSP_ProgramSelectionCtrl.getPrograms";
import { NavigationMixin } from "lightning/navigation";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import exitButton from "@salesforce/label/c.SSP_ExitButton";
import getHouseholdMembers from "@salesforce/apex/SSP_ProgramSelectionCtrl.getHouseholdMemebers";

export default class sspProgramSelection extends NavigationMixin(sspUtility) {
    @track selectedPrograms = "";
    @track applicationId;
    @track memberId;
    @track selectedProgramsArr = [];
    @track programOptions = [];
    @track isLearnMoreModal = false;
    @track showSpinner = false;
    @track modValue;
    @track saveExit = false;
    @track isError = false;
    @track reference = this;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track showExitButton = false;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	

    screenId = "SSP_APP_ProgramSelection";
    mode = sspConstants.applicationMode.INTAKE;
    label = {
        exitButton,
        sspLearnMoreLink,
        sspProgramSelectionTitle,
        sspProgramSelectionDesc,
        sspProgramSelectionNote,
        sspBenefitsApplication,
        sspSaveAndExit,
        sspBack,
        sspNext,
        sspProgramSelectionLearnMoreAlt,
        sspAtLeastOneSelectorMessage,
        toastErrorText,
        sspSaveAndExitAltText,
        sspBackAltText,
        sspNextAltText
    };

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
     * @function - connectedCallback.
     * @description - This method creates the field and object list to get metadata details
     *                from Entity Mapping as per screen name.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            this.showHelpContentData("SSP_APP_ProgramSelection");
            const sPageURL = decodeURIComponent(
                window.location.search.substring(1)
            );

            const sURLVariables = sPageURL.split("&");
            if (sURLVariables != null && sURLVariables != "") {
                for (let i = 0; i < sURLVariables.length; i++) {
                    const sParam = sURLVariables[i].split("=");
                    if (sParam[0] === "applicationId") {
                        this.applicationId =
                            sParam[1] === undefined ? "Not found" : sParam[1];
                    }
                    if (sParam[0] === "memberId") {
                        this.memberId =
                            sParam[1] === undefined ? "Not found" : sParam[1];
                    }
                    if (sParam[0] === "mode") {
                        this.mode =
                            sParam[1] === undefined ? "Not found" : sParam[1];
                    }
                }
            }
            if(this.mode && this.mode !=="Intake"){
                this.showExitButton=true;
            }
            this.fetchPrograms();
        } catch (error) {
            console.error(
                "Error occurred in connectedCallback of program Selection page" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : onExit
     * @description : This method is used to navigate to dashboard in RAC/Renewal/Add or remove flow.
     */
    onExit = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.navigationUrl.existingDashboard
                },
                state: {}
            });
        } catch (error) {
            console.error("Error occurred in continueEarly" + error);
        }
    };

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
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function - handleValues.
     * @description - This method creates the field and object list to get metadata details
     *                from Entity Mapping as per screen name.
     * @param {*} event - Fired on selection of program.
     */
    handleValues (event) {
        try {
            if (event.target.value) {
                this.selectedProgramsArr.push(event.target.inputValue);
            } else if (
                this.selectedProgramsArr.includes(event.target.inputValue) &&
                event.target.value === false
            ) {
                const index = this.selectedProgramsArr.indexOf(
                    event.target.inputValue
                );
                if (index > -1) {
                    this.selectedProgramsArr.splice(index, 1);
                }
            }

            if (this.selectedProgramsArr !== null && this.selectedProgramsArr !== undefined && this.selectedProgramsArr != "" && this.selectedProgramsArr.length > 0) {
                this.isError = false;
                if (this.template.querySelector(".ssp-programSelectionContainer")) {
                    this.template.querySelector(".ssp-programSelectionContainer").classList.remove("ssp-checkbox-error");
                }
            } else {
                this.isError = true;
                if (this.template.querySelector(".ssp-programSelectionContainer")) {
                    this.template.querySelector(".ssp-programSelectionContainer").classList.add("ssp-checkbox-error");
                }
            }
        } catch (error) {
            console.error(
                "Error occurred in handleValues of program selection page" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function : handleBackButton
     * @description : This method is used to take the user back to Get started screen.
     */
    handleBackButton () {
        try {
            if (
                !sspUtility.isUndefinedOrNull(this.applicationId) &&
                !sspUtility.isEmpty(this.applicationId)
            ) {
                if ((!sspUtility.isUndefinedOrNull(this.mode) && this.mode === sspConstants.applicationMode.RENEWAL)) {
                    this.navigateToAppSummary(null, this.applicationId, sspConstants.applicationMode.RENEWAL);
                }
                else {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Application_Summary__c"
                        },
                        state: {
                            applicationId: this.applicationId
                        }
                    });
                }
            } else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "getStartedBenefits__c"
                    },
                    state: {}
                });
            }
        } catch (error) {
            console.error("Error in handleBackButton", error);
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
     * @function : closeExitModal.
     * @description : This method is used to close save and exit modal.
     */
    closeExitModal () {
        this.saveExit = false;
    }

    /**
     * @function - fetchPrograms.
     * @description - This method fetches the available programs.
     */
    fetchPrograms () {
        try {
            getPrograms({
                sMemberId: this.memberId,
                sApplicationId: this.applicationId,
                mode: this.mode
            })
                .then(result => {
                    const availableProgramOptions = result.mapResponse.programs;
                    if (
                        !sspUtility.isUndefinedOrNull(availableProgramOptions)
                    ) {
                        const programOptions = [];
                        const self = this;
                        /**2.5 Security Role Matrix and Program Access. */
                        this.constructRenderingAttributes(result.mapResponse);                          
                        this.showAccessDeniedComponent = !this.isScreenAccessible;
                        /** */

                        availableProgramOptions.forEach(function (program) {
                            if (program.isSelected) {
                                self.selectedProgramsArr.push(
                                    program.programValue
                                );
                                self.originalSelectedPrograms = JSON.parse(JSON.stringify(self.selectedProgramsArr));
                            }
                            if (!sspUtility.isUndefinedOrNull(self.mode) && self.mode === sspConstants.applicationMode.RENEWAL) {
                                if (program.programValue === sspConstants.programs.MEDICAID) {
                                    program.isSelected = true;
                                }
                                program.isDisabled = true;
                            }

                            program.isDisabled = this.isReadOnlyUser ? true : program.isDisabled; //2.5	Security Role Matrix and Program Access.
                            programOptions.push(program);
                        }, this);
                        this.programOptions = programOptions;
                        this.error = undefined;
                        this.showSpinner = false;
                    }
                     if ((!sspUtility.isUndefinedOrNull(result.mapResponse) && sspUtility.isUndefinedOrNull(this.applicationId))) {                       
                        if (result.mapResponse.hasOwnProperty("applicationId")) {
                            this.applicationId = result.mapResponse.applicationId;
                        }
                    }
                })
                .catch(error => {
                    console.error("Error Response -" + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error occurred in fetchPrograms of program selection page" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function savePrograms.
     * @description This method saves the selected programs.
     */
    savePrograms () {
        try {
            if (
                (!sspUtility.isUndefinedOrNull(this.mode) &&
                this.mode === sspConstants.applicationMode.RENEWAL) || (this.isReadOnlyUser)
            ) {
                this.markScreenComplete(this.screenId).then(() =>
                    this.navigateToAppSummary(
                        null,
                        this.applicationId,
                        (this.mode === sspConstants.applicationMode.RENEWAL) ? sspConstants.applicationMode.RENEWAL : sspConstants.applicationMode.INTAKE 
                    )
                );
            } else {
                this.selectedPrograms = "";
                for (let i = 0; i < this.selectedProgramsArr.length; i++) {
                    if (this.selectedPrograms != "") {
                        this.selectedPrograms =
                            this.selectedPrograms +
                            "," +
                            this.selectedProgramsArr[i];
                    } else {
                        this.selectedPrograms = this.selectedProgramsArr[i];
                    }
                }
                if(this.selectedPrograms !== null && this.selectedPrograms !== undefined && this.selectedPrograms != ""){
                    this.showSpinner = true;
                    this.updatePrograms()
                        .then(() =>{ 
                            if(this.applicationId){
                            this.markScreenComplete(this.screenId,this.applicationId);
                            }else{
                            this.markScreenComplete(this.screenId);  
                            }
                        
                        })
                        .then(() => {
                            if(this.applicationId){
                            this.navigateToAppSummary(this.screenId,this.applicationId,this.mode);
                            }else{
                            this.navigateToAppSummary(this.screenId);    
                            }
                        })
                        .then(() => {
                            this.showSpinner = false;
                        });
                } 
                else{
                    this.isError = true;
                    this.hasSaveValidationError = true;
                    if (this.template.querySelector(".ssp-programSelectionContainer")) {
                        this.template.querySelector(".ssp-programSelectionContainer").classList.add("ssp-checkbox-error");
                    }
                }
            }
        } catch (error) {
            console.error(
                "error occurred in savePrograms of program selection page" +
                    JSON.stringify(error)
            );
        }
    }

    triggerReviewRequired = async () => {
        try {
            const response = await getHouseholdMembers({
                applicationId: this.applicationId
            });
            if (!(response.mapResponse && response.mapResponse.members)) {
                return;
            }
            const oldPrograms = JSON.parse(
                JSON.stringify(this.originalSelectedPrograms || [])
            );
            const newPrograms = JSON.parse(
                JSON.stringify(this.selectedProgramsArr || [])
            );
            const addedPrograms = newPrograms.filter(
                program => !oldPrograms.includes(program)
            );
            const removedPrograms = oldPrograms.filter(
                program => !newPrograms.includes(program)
            );
            const memberIds = response.mapResponse.members;
            const [hohMemberId] = memberIds;
            memberIds.push("null");
            const positiveRules = addedPrograms.map(program =>
                ["ProgramChange_" + program, true, ...memberIds].join(",")
            );
            const negativeRules = removedPrograms.map(program =>
                ["ProgramChange_" + program, false, ...memberIds].join(",")
            );
            await this.validateReviewRequiredRules(
                this.applicationId,
                hohMemberId,
                "SSP_ProgramSelection",
                [...positiveRules, ...negativeRules],
                this.mode
            );
            if (addedPrograms.length > 0) {
                await sspUtility.markScreenReviewRequired(
                    this.applicationId,
                    "SSP_APP_HHMembersSummary;REPS_Home"
                );
            }
        } catch (error) {
            console.error("Error in triggerReviewRequired", error);
        }
    };

    /**
     * @function updatePrograms.
     * @description - This method updates/creates the application with selected programs if the user changes them after selecting them once.
     */
    updatePrograms = () => {
        const detailMap = {};
        detailMap.mode = this.mode;
        detailMap.applicationId = this.applicationId;
        return updatePrograms({
            detailMap: detailMap,
            selectedPrograms: this.selectedPrograms
        })
            .then(async result => {
                const parsedData = result.mapResponse;
                if (
                    !sspUtility.isUndefinedOrNull(parsedData) &&
                    parsedData.hasOwnProperty("ERROR")
                ) {
                    console.error(
                        "failed in updating programs" +
                            JSON.stringify(parsedData.ERROR)
                    );
                } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                    if (parsedData.applicationList) {
                        const [application] = JSON.parse(
                            parsedData.applicationList
                        );
                        this.applicationId = application.Id;
                        this.sourceApplicationId = application.Id;
                    }
                }
                await this.triggerReviewRequired();
                this.error = undefined;
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(
                    "Error Response:",
                    JSON.parse(JSON.stringify(error))
                );
            });
    };

    /**
     * @function - openLearnMoreModal
     * @description - This method is used open Learn More Modal.
     */
    openLearnMoreModal () {
        this.isLearnMoreModal = true;
    }

    /**
     * @function - closeLearnMoreModal
     * @description - This method is used close Learn More Modal.
     */
    closeLearnMoreModal () {
        this.isLearnMoreModal = false;
    }

    /**
     * @function : hideToast
     * @description	: Method to hide Toast.
     */
    hideToast = ()  => {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(
                "Error in sspProgramSelection.hideToast : " +
                    JSON.stringify(error)
            );
        }
    }

    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
    constructRenderingAttributes = response => {
        try {
            if (response != null && response != undefined && response.hasOwnProperty("screenPermission")) {
                const { screenPermission: securityMatrix } = response;
                this.isReadOnlyUser = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == sspConstants.permission.readOnly);
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == sspConstants.permission.notAccessible) ? false : true;                
            }
        }
        catch (error) {
            console.error(
                JSON.stringify(error.message)
            );
        }
    };
}
