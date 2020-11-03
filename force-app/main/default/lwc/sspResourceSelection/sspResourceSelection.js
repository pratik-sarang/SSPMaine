/**
 * Component Name: sspPreferredPaymentMethod.
 * Author: Sharon Roja, Karthik Gulla.
 * Description: This component creates a screen for Resource Selection.
 * Date: 06/01/2020.
 */
import { api, track, wire } from "lwc";
import sspResourceSelectionQuestionComplete from "@salesforce/label/c.SSP_ResourceSelectionQuestionComplete";
import sspResourceSelectionLearnMore from "@salesforce/label/c.SSP_LearnMoreLink";
import sspResourceSelectionLearnMoreTitle from "@salesforce/label/c.SSP_ResourceSelectionLearnMoreTitle";
import sspResourceSelectionNote from "@salesforce/label/c.SSP_ResourceSelectionNote";
import sspResourceSelectionQuestionOne from "@salesforce/label/c.SSP_ResourceSelectionQuestionOne";
import sspResourceSelectionQuestionTwo from "@salesforce/label/c.SSP_ResourceSelectionQuestionTwo"; 
import sspResourceSelectionQuestionThree from "@salesforce/label/c.SSP_ResourceSelectionQuestionThree";
import sspResourceSelectionQuestionFour from "@salesforce/label/c.SSP_ResourceSelectionQuestionFour";
import sspResourceSelectionQuestionFive from "@salesforce/label/c.SSP_ResourceSelectionQuestionFive";
import sspResourceSelectionQuestionSix from "@salesforce/label/c.SSP_ResourceSelectionQuestionSix";
import sspResourceSelectionQuestionSeven from "@salesforce/label/c.SSP_ResourceSelectionQuestionSeven";
import sspResourceSelectionQuestionEight from "@salesforce/label/c.SSP_ResourceSelectionQuestionEight";
import sspSelectApplicableHouseholdMembers from "@salesforce/label/c.SSP_SelectApplicableHouseholdMembers";
import sspResourceSelectionAssetsExcessHelpText from "@salesforce/label/c.SSP_ResourceSelectionHelpTextOne";
import sspResourceSelectionFuneralContractHelpText from "@salesforce/label/c.SSP_ResourceSelectionHelpTextTwo";
import sspResourceSelectionRealEstateHelpText from "@salesforce/label/c.SSP_ResourceSelectionHelpTextThree";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import utility, { getYesNoOptions } from "c/sspUtility";
import apConstants from "c/sspConstants";
import getCurrentApplicationHouseholdMembers from "@salesforce/apex/SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers";
import updateResourcesSelection from "@salesforce/apex/SSP_ResourcesSelectionController.updateResourcesSelectionDetails";
import getResourcesSelectionDetails from "@salesforce/apex/SSP_ResourcesSelectionController.getResourcesSelectionDetails";
import getResourcesDetailsMappings from "@salesforce/apex/SSP_ResourcesService.getResourcesDetailsMappings";

//Toggle Fields import
import sspHouseholdMemberError from "@salesforce/label/c.SSP_HealthSelectionErrorMsg";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import hasAssetsInExcessField from "@salesforce/schema/SSP_Application__c.IsAssetsInExcess1MToggle__c";
import hasAccountsField from "@salesforce/schema/SSP_Member__c.HasOwnBankAccountToggle__c";
import hasInvestmentsField from "@salesforce/schema/SSP_Member__c.HasInvestmentsToggle__c";
import hasLiquidResourcesField from "@salesforce/schema/SSP_Member__c.HasCashReloadableMoneyCardToggle__c";
import hasVehicleField from "@salesforce/schema/SSP_Member__c.HasVehicleToggle__c";
import hasRealEstatePropertyField from "@salesforce/schema/SSP_Member__c.HasRealEstatePropertyToggle__c";
import hasLifeInsuranceField from "@salesforce/schema/SSP_Member__c.HasLifeInsuranceToggle__c";
import hasFuneralContractField from "@salesforce/schema/SSP_Member__c.HasPreArrangedFuneralContractToggle__c";
import APPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import MEMBER_OBJECT from "@salesforce/schema/SSP_Member__c";

export default class SspResourceSelection extends BaseNavFlowPage {
    @api applicationId;
    @api memberName;
    @api pageAction;
    @api headOfHousehold;
    @api mode;
    @track resourceSelectionQuestionsList = [];
    @track householdMembers = [];
    @track yesNoOptions = getYesNoOptions();
    @track showSpinner = false;
    @track resourceSelectionQuestions = [];
    @track hasMetadataListValues = false;
    @track questionMappings = {};
    @track isLearnMoreModal = false;
    @track fieldProgramMappings = {};
    @track reference = this;
    @track trueValue = true;
    @track memberResourcesCount;
    @track memberIdList;
    @track resourceAllMembersTemp;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	
    label = {
        sspResourceSelectionQuestionComplete,
        sspResourceSelectionLearnMore,
        sspResourceSelectionLearnMoreTitle,
        sspResourceSelectionNote,
        sspResourceSelectionQuestionOne,
        sspResourceSelectionQuestionTwo,
        sspResourceSelectionQuestionThree,
        sspResourceSelectionQuestionFour,
        sspResourceSelectionQuestionFive,
        sspResourceSelectionQuestionSix,
        sspResourceSelectionQuestionSeven,
        sspResourceSelectionQuestionEight,
        sspSelectApplicableHouseholdMembers,
        sspLearnMoreModalContent,
        sspResourceSelectionAssetsExcessHelpText,
        sspResourceSelectionRealEstateHelpText,
        sspResourceSelectionFuneralContractHelpText,
        toastErrorText
    };

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getAllowSaveData + JSON.stringify(error.message));
            return null;
        }
    }
    set allowSaveData (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.allowSaveValue = value;
                if (!this.haveError){
                    this.saveResourceSelectionData();
                }
            }
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.setAllowSaveData + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for MetadataList.
     * @description : Getter setter methods for MetadataList.
     */
    @api
    get MetadataList () {
        try {
            return this.MetaDataListParent;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getMetadataList + JSON.stringify(error.message));
            return null;
        }
    }
    set MetadataList (value) {
        try {
            if (!utility.isUndefinedOrNull(value)) {
                this.MetaDataListParent = value;
                this.hasMetadataListValues = true;
            }
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.setMetadataList + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Getter setter methods for next event.
     * @description : Getter setter methods for next event.
     */
    @api
    get nextEvent () {
        try {
            return this._nextValue;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getNextEvent + JSON.stringify(error.message));
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this._nextValue = value;
                //Get all the input elements for Selected records and add it base component for validations
                this.getRequiredInputElements();
                this.reviewRequiredLogic ();
            }
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants.resourceSelectionError
                    .setNextEvent + JSON.stringify(error.message)
            );
        }
    }

    /*
    * @function : hideToast
    * @description	: Method to hide Toast
    */
    hideToast () {
        try {
            this.hasSaveValidationError = false;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.hideToast + JSON.stringify(error.message));
        }
    }

    /**
     * @function : connectedCallback
     * @description : connected call back method used to set on load values.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const resSelectionFieldEntityNameList =
                apConstants.resourceSelectionFieldEntityNameList;

            this.getMetadataDetails(
                resSelectionFieldEntityNameList,
                null,
                apConstants.resourceSelectionConstants.resourceSelectionPage
            );
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.connectedCallback + JSON.stringify(error.message));
        }
    }

    /**
     * @function : Wire property to get Current Application household members
     * @description : Wire property to get Current Application household members.
     * @param {sApplicationId, sMemberId, sMembersType}
     * sApplicationId - Application id,
     * sMemberId - Application id,
     * sMembersType - members type.
     */
    @wire(getCurrentApplicationHouseholdMembers, {
        sApplicationId: "$applicationId",
        sMemberId: "",
        sMembersType: apConstants.resourceSelectionConstants.sAll
    })
    householdMemberDetails ({ error, data }) {
        try {
            if (data) {
                this.showSpinner = true;
                /**2.5 Security Role Matrix and Program Access. */
                this.isReadOnlyUser = (data.mapResponse.screenPermission != null && data.mapResponse.screenPermission != undefined && data.mapResponse.screenPermission == apConstants.permission.readOnly);
                this.isScreenAccessible = (data.mapResponse.screenPermission != null && data.mapResponse.screenPermission != undefined && data.mapResponse.screenPermission == apConstants.permission.notAccessible) ? false : true; 
                this.showAccessDeniedComponent = !this.isScreenAccessible;
                /** */
                const hMembers = JSON.parse(data.mapResponse.householdMembers);
                //Shikha: added
                const memberList = [];
                hMembers.forEach(function (key){
                    memberList.push(key.strMemberId);
                });
                this.memberIdList = memberList;
                //Shikha:ended
                let hMembersArray = new Array();
                for (let index = 0; index < hMembers.length; index++) {
                    const hMembersValue = hMembers[index];
                    hMembersArray.push({
                        label: hMembersValue[apConstants.resourceDetailConstants.resourceHouseholdName],
                        value: hMembersValue[apConstants.resourceDetailConstants.resourceMemberId],
                        programs: hMembersValue[apConstants.resourceSelectionConstants.sAppliedPrograms] != null
                                ? hMembersValue[apConstants.resourceSelectionConstants.sAppliedPrograms].split(";")
                                : [],
                        memberStatus: hMembersValue[apConstants.resourceSelectionConstants.sMemberStatus],
                        isTMember: hMembersValue[apConstants.resourceSelectionConstants.sIsTMember],
                        isChecked: false,
                        isDisabled: this.isReadOnlyUser //2.5 Security Role Matrix and Program Access.
                    });
                }

                hMembersArray = hMembersArray.filter(hMember => hMember.isTMember == false);

                if (!utility.isUndefinedOrNull(this.mode) && this.mode === apConstants.mode.addRemoveMember) {
                    hMembersArray = hMembersArray.filter(
                        hMember => hMember.memberStatus == apConstants.resourceSelectionConstants.sNewStatus
                    );
                }

                this.householdMembers = hMembersArray;
                this.getResourceSelectionData();
            } else if (error) {
                this.showSpinner = false;
                console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getCurrentApplicationHouseholdMembers + JSON.stringify(error.message));
            }
        } catch (error) {
            this.showSpinner = false;
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getCurrentApplicationHouseholdMembers + JSON.stringify(error.message));
        }
    }

    /*
     * @function : buildResourceSelectionQuestions
     * @description : This method used to build Resource Selection Questions based on Programs selected for a member.
     */
    buildResourceSelectionQuestions = rSelectionData => {
        try {
            Object.keys(this.questionMappings).forEach(questionId => {
                const rsSelectionData = rSelectionData[questionId];
                if (!utility.isUndefinedOrNull(rsSelectionData)) {
                    const questionWrapper = {};
                    questionWrapper[apConstants.resourceSelectionConstants.sQuestionId] = questionId;
                    questionWrapper[apConstants.resourceSelectionConstants.sQuestionLabel] = this.questionMappings[questionId].label;
                    questionWrapper[apConstants.resourceSelectionConstants.sApplicableMembers] = [];
                    questionWrapper[apConstants.resourceSelectionConstants.sShowQuestion] = false;
                    questionWrapper[apConstants.resourceSelectionConstants.sObjectAPI] = this.questionMappings[questionId].ObjectAPI;
                    questionWrapper[apConstants.resourceSelectionConstants.sFieldAPI] = this.questionMappings[questionId].FieldAPI;
                    questionWrapper[apConstants.resourceSelectionConstants.sQuestionValue] = rsSelectionData[apConstants.resourceSelectionConstants.stringQuestionValue];
                    questionWrapper[apConstants.resourceSelectionConstants.sSelectedRecords] = String(rsSelectionData[apConstants.resourceSelectionConstants.sObjectRecords]);
                    questionWrapper[apConstants.resourceSelectionConstants.sShowMembersList] = 
                        questionWrapper[apConstants.resourceSelectionConstants.sQuestionValue] === apConstants.toggleFieldValue.yes &&
                        questionWrapper[apConstants.resourceSelectionConstants.sObjectAPI] === apConstants.sspObjectAPI.SSP_Member__c
                            ? true
                            : false;
                    questionWrapper[apConstants.resourceSelectionConstants.sShowHelp] = this.questionMappings[questionId].showHelp;
                    questionWrapper[apConstants.resourceSelectionConstants.sHelpContent] = this.questionMappings[questionId].helpContent;
                    questionWrapper.isDisabled = this.isReadOnlyUser; //2.5 Security Role Matrix and Program Access.
                    this.householdMembers.forEach(householdMember => {

                        if (!utility.isArrayEmpty(householdMember.programs) &&
                            !utility.isArrayEmpty(this.questionMappings[questionId].applicablePrograms) &&
                            questionWrapper[apConstants.resourceSelectionConstants.sObjectAPI] === MEMBER_OBJECT.objectApiName
                        ) {
                            const isProgramApplicable = this.checkIfProgramApplicableForMember(
                                householdMember.programs,
                                this.questionMappings[questionId].applicablePrograms
                            );
                            if (isProgramApplicable) {
                                questionWrapper[apConstants.resourceSelectionConstants.sShowQuestion] = true;
                                const currentHouseholdMember = Object.assign({}, householdMember);
                                if (rsSelectionData[apConstants.resourceSelectionConstants.sObjectRecords].split(",").indexOf(householdMember.value) > -1){
                                    currentHouseholdMember.isChecked = true;
                                }
                                if(!utility.isUndefinedOrNull(this.memberResourcesCount[householdMember.value])
                                    && !utility.isUndefinedOrNull(this.memberResourcesCount[householdMember.value][questionId])
                                    && this.memberResourcesCount[householdMember.value][questionId] > 0
                                    ) {
                                    currentHouseholdMember.isDisabled = true;
                                    questionWrapper.isDisabled = true;
                                }
                                questionWrapper[apConstants.resourceSelectionConstants.sApplicableMembers].push(currentHouseholdMember);
                            }
                        }
                    });

                    if (questionWrapper[
                            apConstants.resourceSelectionConstants.sObjectAPI
                        ] === APPLICATION_OBJECT.objectApiName &&
                        this.checkIfProgramApplicableForMember(String(rsSelectionData[apConstants.resourceSelectionConstants.sAppliedPrograms]).split(";"),
                            this.questionMappings[questionId].applicablePrograms
                        )
                    ) {
                        questionWrapper[apConstants.resourceSelectionConstants.sShowQuestion] = true;
                    }
                    this.resourceSelectionQuestionsList.push(questionWrapper);
                }
            }, this); //2.5 Security Role Matrix and Program Access.
            this.showSpinner = false;
        } catch (error) {
            this.showSpinner = false;
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.buildResourceSelectionQuestions + JSON.stringify(error.message));
        }
    };

    /*
     * @function : handleQuestionsChange
     * @description : This method used to handle change of resource selection questions.
     */
    handleQuestionsChange = event => {
        try {
            const resourceSelectionAnswer = event.detail.value;
            const resourceQuestionSelected = event.target.dataset.record;
            const resourceSelectionRecord = this.resourceSelectionQuestionsList.find(
                resSelectionRecord => resSelectionRecord.questionId === resourceQuestionSelected
            );
            if (resourceSelectionAnswer === apConstants.toggleFieldValue.yes && this.questionMappings[resourceQuestionSelected].showMembers) {
                resourceSelectionRecord[apConstants.resourceSelectionConstants.sShowMembersList] = true;
            } else if (resourceSelectionAnswer === apConstants.toggleFieldValue.yes && !this.questionMappings[resourceQuestionSelected].showMembers) {
                resourceSelectionRecord[apConstants.resourceSelectionConstants.sShowMembersList] = false;
                resourceSelectionRecord[apConstants.resourceSelectionConstants.sSelectedRecords] = String(this.applicationId);
            } else if (resourceSelectionAnswer === apConstants.toggleFieldValue.no) {
                resourceSelectionRecord[apConstants.resourceSelectionConstants.sShowMembersList] = false;
            }
            resourceSelectionRecord[apConstants.resourceSelectionConstants.sQuestionValue] = resourceSelectionAnswer;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.handleQuestionsChange + JSON.stringify(error.message));
        }
    }

    /**
     * @function : getFieldProgramMappingsForResources
     * @description : Functionality to get field program mappings for resources.
     * @param {resourceSelectionData} resourceSelectionData - Resource Selection data.
     */
    getFieldProgramMappingsForResources = (resourceSelectionData) => {
        try {
            /* @sKey {String} Key with resource type field.
             * @returns { String JSON } Returns a string JSON with resource mappings.
             */
            getResourcesDetailsMappings({
                sKey: apConstants.resourceSelectionConstants.sObjectField
            })
                .then(result => {
                    const resourceMappings = JSON.parse(JSON.stringify(result));
                    Object.keys(resourceMappings).forEach(resourceMapping => {
                        const resourceMappingObject = {};
                        resourceMappingObject.applicablePrograms =
                            resourceMappings[
                                resourceMapping
                            ].ApplicablePrograms__c;
                        resourceMappingObject.detailsRequired =
                            resourceMappings[
                                resourceMapping
                            ].DetailsRequired__c;
                        this.fieldProgramMappings[
                            resourceMapping
                        ] = resourceMappingObject;
                    });
                    this.questionMappings[
                        hasAssetsInExcessField.fieldApiName
                    ] = {
                        label: this.label.sspResourceSelectionQuestionOne,
                        FieldAPI: hasAssetsInExcessField.fieldApiName,
                        showMembers: false,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: [apConstants.programValues.CC],
                        showHelp: true,
                        helpContent: this.label.sspResourceSelectionAssetsExcessHelpText
                    };
                    this.questionMappings[hasAccountsField.fieldApiName] = {
                        label: this.label.sspResourceSelectionQuestionTwo,
                        FieldAPI: hasAccountsField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasAccountsField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false, 
                        helpContent: ""
                    };
                    this.questionMappings[hasInvestmentsField.fieldApiName] = {
                        label: this.label.sspResourceSelectionQuestionThree,
                        FieldAPI: hasInvestmentsField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasInvestmentsField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false,
                        helpContent: ""
                    };
                    this.questionMappings[
                        hasLiquidResourcesField.fieldApiName
                    ] = {
                        label: this.label.sspResourceSelectionQuestionFour,
                        FieldAPI: hasLiquidResourcesField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLiquidResourcesField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false,
                        helpContent: ""
                    };
                    this.questionMappings[hasVehicleField.fieldApiName] = {
                        label: this.label.sspResourceSelectionQuestionFive,
                        FieldAPI: hasVehicleField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasVehicleField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false,
                        helpContent: ""
                    };
                    this.questionMappings[
                        hasRealEstatePropertyField.fieldApiName
                    ] = {
                        label: this.label.sspResourceSelectionQuestionSix,
                        FieldAPI: hasRealEstatePropertyField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasRealEstatePropertyField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspResourceSelectionRealEstateHelpText
                    };
                    this.questionMappings[
                        hasLifeInsuranceField.fieldApiName
                    ] = {
                        label: this.label.sspResourceSelectionQuestionSeven,
                        FieldAPI: hasLifeInsuranceField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLifeInsuranceField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false,
                        helpContent: ""
                    };
                    this.questionMappings[
                        hasFuneralContractField.fieldApiName
                    ] = {
                        label: this.label.sspResourceSelectionQuestionEight,
                        FieldAPI: hasFuneralContractField.fieldApiName,
                        showMembers: true,
                        ObjectAPI: MEMBER_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasFuneralContractField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspResourceSelectionFuneralContractHelpText
                    };
                    this.buildResourceSelectionQuestions(resourceSelectionData);
                })
                .catch(error => {
                    console.error(
                        apConstants.resourceSelectionConstants.resourceSelectionError
                            .getFieldProgramMappingsForResources +
                            JSON.stringify(error.message)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants.resourceSelectionError.getFieldProgramMappingsForResources + JSON.stringify(error.message)
            );
        }
    }

    /*
     * @function : handleMembersChange
     * @description : This method used to handle change of members on resource selection questions.
     */
    handleMembersChange = (event) => {
        try {
            const resourceQuestionSelected = event.target.dataset.record;
            const resourceSelectionRecord = this.resourceSelectionQuestionsList.find(
                resSelectionRecord =>
                    resSelectionRecord.questionId === resourceQuestionSelected
            );

            if (this.questionMappings[resourceQuestionSelected].showMembers) {
                const selectedMembersSummary = (!utility.isUndefinedOrNull(resourceSelectionRecord[apConstants.resourceSelectionConstants.sSelectedRecords]) && !utility.isEmpty(resourceSelectionRecord[apConstants.resourceSelectionConstants.sSelectedRecords])) ? resourceSelectionRecord[apConstants.resourceSelectionConstants.sSelectedRecords].split(",") : [];
                if (event.target.value){
                    selectedMembersSummary.push(event.target.inputValue);
                    resourceSelectionRecord.showErrorMessage = false;
                } else {
                    const index = selectedMembersSummary.indexOf(event.target.inputValue);
                    if (index > -1) {
                        selectedMembersSummary.splice(index, 1);
                    }
                }
                resourceSelectionRecord[apConstants.resourceSelectionConstants.sSelectedRecords] = selectedMembersSummary.toString();
            }
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants.resourceSelectionError
                    .handleMembersChange + JSON.stringify(error.message)
            );
        }
    }

    /*
    * @function : checkIfProgramApplicableForMember
    * @description : This method used to check whether a particular program is applicable.
    */
    checkIfProgramApplicableForMember = (memberProgramList, programMappingList) => {
        try {
            let hasProgram = false;
            if (!utility.isArrayEmpty(memberProgramList)) {
                memberProgramList.forEach(item => {
                    if (!utility.isArrayEmpty(programMappingList) && programMappingList.indexOf(item) > -1) {
                        hasProgram = true;
                    }
                });
            }
            return hasProgram;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.checkIfProgramApplicableForMember + JSON.stringify(error.message));
            return false;
        }
    }

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            this.resourceSelectionQuestionsList.forEach(questionSelected => {
                const selectedRecord = {};
                selectedRecord[apConstants.resourceSelectionConstants.stringObject] = questionSelected.objectAPI;
                selectedRecord[apConstants.resourceSelectionConstants.sObjectRecords] =
                    questionSelected.questionValue == apConstants.toggleFieldValue.yes
                        ? String(questionSelected.selectedRecords)
                        : questionSelected.objectAPI == apConstants.sspObjectAPI.SSP_Member__c
                            ? String(this.getCurrentHouseholdMemberIds(questionSelected[apConstants.resourceSelectionConstants.sApplicableMembers]))
                            : String(this.applicationId);
                selectedRecord[apConstants.resourceSelectionConstants.stringQuestionValue] = questionSelected.questionValue;

                if (selectedRecord[apConstants.resourceSelectionConstants.stringQuestionValue] === apConstants.toggleFieldValue.yes && utility.isEmpty(selectedRecord[apConstants.resourceSelectionConstants.sObjectRecords])){
                    questionSelected.showErrorMessage = true;
                    questionSelected.errorMessage = sspHouseholdMemberError;
                    const showToastEvent = new CustomEvent("showcustomtoast");
                    this.dispatchEvent(showToastEvent);
                    this.templateInputsValue = "invalid";
                    this.haveError = true;
                }
                else {
                    const resourceSelectionItems = this.template.querySelectorAll(".ssp-resourceSelectionInputs");
                    this.templateInputsValue = Array.from(resourceSelectionItems);
                    this.haveError = false;
                }
            });
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getRequiredInputElements + JSON.stringify(error.message));
        }
    }

    /* @function : saveResourceSelectionData
     * @description: Method to save resource selection data.
     */
    saveResourceSelectionData = () => {
        try {
            const toBeUpdatedValues = [];
            this.resourceSelectionQuestionsList.forEach(questionSelected => {
                const selectedRecord = {};
                selectedRecord[apConstants.resourceSelectionConstants.stringObject] = questionSelected.objectAPI;
                selectedRecord[apConstants.resourceSelectionConstants.sObjectRecords] =
                    questionSelected.questionValue == apConstants.toggleFieldValue.yes
                        ? String(questionSelected.selectedRecords)
                        : questionSelected.objectAPI == apConstants.sspObjectAPI.SSP_Member__c
                        ? String(this.getCurrentHouseholdMemberIds(questionSelected[apConstants.resourceSelectionConstants.sApplicableMembers]))
                        : String(this.applicationId);
                selectedRecord[apConstants.resourceSelectionConstants.stringQuestionValue] = questionSelected.questionValue;
                selectedRecord[apConstants.resourceSelectionConstants.stringField] = questionSelected.fieldAPI;
                toBeUpdatedValues.push(selectedRecord);
            });

            /* @sUpdatedValues {String} array converted to string with updated values.
             * @returns {Boolean} Returns a response with true or false.
            */
            updateResourcesSelection({
                sUpdatedValues: JSON.stringify(toBeUpdatedValues),
                sApplicationId: this.applicationId
            })
            .then(result =>{
                this.saveCompleted = true;
            })
            .catch(error => {
                console.error(
                    apConstants.resourceSelectionConstants
                        .resourceSelectionError.updateResourcesSelection +
                        JSON.stringify(error.message)
                );
            });
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.saveResourceSelectionData + JSON.stringify(error.message));
            this.saveCompleted = false;
        }
    }

    /**
     * @function : getResourceSelectionData
     * @description : Function to get resource selection details.
     */
    getResourceSelectionData = () => {
        try {
            /* @mapInputs {map} value The input value with member Id, application Id details.
             * @sMode {string} value current application mode.
             * @returns { String JSON } Returns a string JSON with existing resource selection details.
             */
            const mapResInputs = {};
            mapResInputs.applicationId = this.applicationId;
            getResourcesSelectionDetails({
                mapInputs: mapResInputs,
                sMode: this.mode
            })
                .then(result => {
                    const resSelectionData = JSON.parse(
                        result.mapResponse.resourceSelectionDetails
                    );
                    this.memberResourcesCount = JSON.parse(result.mapResponse.mapMembersResourceCount);
                    this.getFieldProgramMappingsForResources(resSelectionData);
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getResourceSelectionData + JSON.stringify(error.message));
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getResourceSelectionData + JSON.stringify(error.message));
        }
    }

    /**
    * @function : getCurrentHouseholdMemberIds
    * @description : Function to get current household members salesforce records ids.
    * @param {applicableMemberDetails} applicableMemberDetails - ApplicableMemberDetails array,.
    */
    getCurrentHouseholdMemberIds = (applicableMemberDetails) => {
        try {
            let memberRecordIds = "";
            applicableMemberDetails.forEach(
                memberRecord => {
                    memberRecordIds = memberRecordIds != "" ? memberRecordIds + "," + memberRecord.value : memberRecord.value;
                }
            );
            return memberRecordIds;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.getCurrentHouseholdMemberIds + JSON.stringify(error.message));
        }
    }

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     */
    openLearnMoreModal () {
        try {
            this.isLearnMoreModal = true;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.openLearnMoreModal + JSON.stringify(error.message));
        }
    }

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal () {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error(apConstants.resourceSelectionConstants.resourceSelectionError.closeLearnMoreModal + JSON.stringify(error.message));
        }
    }

    reviewRequiredLogic (){
        const resourceQuestionsList = this.template.querySelectorAll(".ssp-resourceSelectionInputs");
        let addRule;
        const self = this;
        const revRules = [];
        resourceQuestionsList.forEach( function (key){
            if(key.oldValue !== key.value){
                if(key.value === "N"){
                    addRule = true;
                }
                else{
                    addRule = false;
                }
            }
        });
        const resourceMembersList = this.template.querySelectorAll(".ssp-resourceSelectionMembers");
        const resourceMemberRRList = [];
        const resourceMemberRRNoList = [];
        const resourceAllMembers = [];
        this.resourceAllMembersTemp = resourceAllMembers;
        resourceMembersList.forEach (function (key){
            if(key.oldValue !== key.value){
                if(key.value === true){
                    if(!resourceMemberRRList.includes(key.inputValue)){
                        resourceMemberRRList.push(key.inputValue);
                    }                    
                }
                else{
                    if(!resourceMemberRRNoList.includes(key.inputValue)){
                        resourceMemberRRNoList.push(key.inputValue);
                    }
                }
            }            
            if(key.disabled === true && self.mode === "RAC"){
                if(!resourceMemberRRList.includes(key.inputValue)){
                    resourceMemberRRList.push(key.inputValue);
                }
            }             
        });
        if(resourceMemberRRList.length > 0){
            revRules.push(apConstants.reviewRequiredRules.resourceSelection+","+true+","+resourceMemberRRList);
        }
        const updatedResourceNoList = [];
        resourceMemberRRNoList.forEach(function (item){
            if(!resourceMemberRRList.includes(item)){
                updatedResourceNoList.push(item);
            }
        });
        if(updatedResourceNoList.length > 0){
            revRules.push(apConstants.reviewRequiredRules.resourceSelection+","+false+","+updatedResourceNoList);
        }
        if (addRule && resourceMemberRRList.length == 0) {
            revRules.push(apConstants.reviewRequiredRules.resourceSelection+","+false+","+this.memberIdList);
        }
        
        this.reviewRequiredList = revRules;
        
    }
}