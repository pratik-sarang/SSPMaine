/*
 * Component Name: sspOtherResourcesSelection
 * Author: Karthik Velu, Karthik Gulla
 * Description: This Screen is used for Other Resource Selection questions.
 * Date: 01/13/2020.
 */
import { api, track, wire } from "lwc";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspResourceSelectionQuestionComplete from "@salesforce/label/c.SSP_ResourceSelectionQuestionComplete";
import sspLearnMoreAlternate from "@salesforce/label/c.SSP_OtherResourcesSelectionLearnMoreAlternate";
import sspResourceSelectionNote from "@salesforce/label/c.SSP_ResourceSelectionNote";
import sspTrustFundQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionTrustFund";
import sspAnnuityQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionAnAnnuity";
import sspLifeEstateQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionLifeEstate";
import sspLandContractQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionLandContract";
import sspPartnershipPolicyQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionPartnershipPolicy";
import sspSettlementContractQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionSettlementContract";
import sspBurialFundQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionBurialFund";
import sspBurialPlotQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionBurialPlot";
import sspCareAgreementQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionCareAgreement";
import sspReverseMortgageQuestion from "@salesforce/label/c.SSP_OtherResourcesSelectionReverseMortgage";
import sspTrustFundHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionTrustFundHelpContent";
import sspLifeEstateHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionLifeEstateHelpContent";
import sspLandContractHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionLandContractHelpContent";
import sspPartnershipPolicyHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionPartnershipPolicyHelpContent";
import sspSettlementContractHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionSettlementContractHelpContent";
import sspBurialFundHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionBurialFundHelpContent";
import sspCareAgreementHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionCareAgreementHelpContent";
import sspAnAnnuityHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionAnAnnuityHelpContent";
import sspBurialPlotHelpContent from "@salesforce/label/c.SSP_OtherResourcesSelectionBurialPlotHelpContent";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import utility, { getYesNoOptions } from "c/sspUtility";
import apConstants from "c/sspConstants";
import { getRecord } from "lightning/uiRecordApi";
import getOtherResourceSelectionDetails from "@salesforce/apex/SSP_ResourcesSelectionController.getOtherResourceSelectionDetails";

//Toggle Fields import
import hasTrustField from "@salesforce/schema/SSP_Application__c.HasSpecialNeedTrustToggle__c";
import hasAnnuityField from "@salesforce/schema/SSP_Application__c.HasAnnuityToggle__c";
import hasLifeEstateField from "@salesforce/schema/SSP_Application__c.HasLifeEstateToggle__c";
import hasPromissoryContractField from "@salesforce/schema/SSP_Application__c.HasPromissoryNoteOrLandContractToggle__c";
import hasLTCAgreementField from "@salesforce/schema/SSP_Application__c.HasPartnershipQualifiedLTCPolicyToggle__c";
import hasLifeSettlementContractField from "@salesforce/schema/SSP_Application__c.HasLifeSettlementContractToggle__c";
import hasBurialFundsField from "@salesforce/schema/SSP_Application__c.HasBurialFundToggle__c";
import hasBurialPlotsField from "@salesforce/schema/SSP_Application__c.HasBurialPlotsToggle__c";
import hasLifeTimeCareAgreementField from "@salesforce/schema/SSP_Application__c.HasLTCAgreementToggle__c";
import hasOtherResourceField from "@salesforce/schema/SSP_Application__c.HasOtherResourceToggle__c";
import hasProgramsApplied from "@salesforce/schema/SSP_Application__c.ProgramsApplied__c";
import APPLICATION_OBJECT from "@salesforce/schema/SSP_Application__c";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONID_FIELD from "@salesforce/schema/SSP_Application__c.Id";

const APPLICATION_FIELDS = [
    hasTrustField,
    hasAnnuityField,
    hasLifeEstateField,
    hasPromissoryContractField,
    hasLTCAgreementField,
    hasLifeSettlementContractField,
    hasBurialFundsField,
    hasLifeTimeCareAgreementField,
    hasOtherResourceField,
    hasProgramsApplied,
    hasBurialPlotsField
];
export default class SspOtherResourcesSelection extends BaseNavFlowPage {
    @api applicationId;

    /**
     * @function : Getter setter methods for allowSave.
     * @description : Getter setter methods for allowSave.
     */
    @api
    get allowSaveData () {
        try {
            return this.allowSaveValue;
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.getAllowSaveData +
                JSON.stringify(error.message)
            );
            return null;
        }
    }
    set allowSaveData (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.allowSaveValue = value;
                this.saveOtherResourceSelectionData();
            }
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.setAllowSaveData +
                JSON.stringify(error.message)
            );
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
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.getMetadataList +
                JSON.stringify(error.message)
            );
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
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.setMetadataList +
                JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : Getter setter methods for next event.
     * @description : Getter setter methods for next event.
     */
    @api
    get nextEvent () {
        try {
            return this.nextValue;
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.getNextEvent +
                JSON.stringify(error.message)
            );
            return null;
        }
    }
    set nextEvent (value) {
        try {
            if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
                this.nextValue = value;
                //Get all the input elements for Selected records and add it base component for validations
                this.getRequiredInputElements();
            }
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.setNextEvent +
                JSON.stringify(error.message)
            );
        }
    }

    @track otherResourceSelectionQuestionsList = [];
    @track yesNoOptions = getYesNoOptions();
    @track showSpinner = false;
    @track hasMetadataListValues = false;
    @track questionMappings = {};
    @track openLearnMoreModel = false;
    @track fieldProgramMappings = {};
    @track hasMedicaidNonMagi;
    @track reference = this;
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    label = {
        sspLearnMoreLink,
        sspLearnMoreAlternate,
        sspResourceSelectionQuestionComplete,
        sspResourceSelectionNote,
        sspTrustFundQuestion,
        sspAnnuityQuestion,
        sspLifeEstateQuestion,
        sspLandContractQuestion,
        sspPartnershipPolicyQuestion,
        sspSettlementContractQuestion,
        sspBurialFundQuestion,
        sspBurialPlotQuestion,
        sspCareAgreementQuestion,
        sspReverseMortgageQuestion,
        sspTrustFundHelpContent,
        sspLifeEstateHelpContent,
        sspLandContractHelpContent,
        sspPartnershipPolicyHelpContent,
        sspSettlementContractHelpContent,
        sspBurialFundHelpContent,
        sspCareAgreementHelpContent,
        sspAnAnnuityHelpContent,
        sspBurialPlotHelpContent,
        sspLearnMoreModalContent
    };

    /**
     * @function : connectedCallback
     * @description : connected call back method used to set on load values.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const otherResourcesSelectionFieldEntityNameList =
                apConstants.otherResourcesSelectionFieldEntityNameList;

            this.getMetadataDetails(
                otherResourcesSelectionFieldEntityNameList,
                null,
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionPage
            );
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.connectedCallback +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : applicationRecord
     * @description : Wired Function to get other resource selection details.
     */
    @wire(getRecord, {
        recordId: "$applicationId",
        fields: APPLICATION_FIELDS
    })
    applicationRecord ({ error, data }) {
        if (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.wireApplicationRecord +
                    JSON.stringify(error.message)
            );
        } else if (data) {
            this.getFieldProgramMappingsForResources(data);
        }
    }

    /*
     * @function : buildOtherResourceSelectionQuestions
     * @description : This method used to build other Resource Selection Questions based on Programs selected on an Application.
     */
    buildOtherResourceSelectionQuestions = oResourceSelectionData => {
        try {
            Object.keys(this.questionMappings).forEach(questionId => {
                const otherResourceSelectionData =
                    oResourceSelectionData.fields[questionId];
                const questionWrapper = {};
                questionWrapper[
                    apConstants.resourceSelectionConstants.sQuestionId
                ] = questionId;
                questionWrapper[
                    apConstants.resourceSelectionConstants.sQuestionLabel
                ] = this.questionMappings[questionId].label;
                const appProgramsArray = oResourceSelectionData.fields[
                    hasProgramsApplied.fieldApiName
                ].value.split(";");
                if (this.hasMedicaidNonMagi) {
                    appProgramsArray.push(apConstants.medicaidTypes.NonMAGI);
                }
                questionWrapper[
                    apConstants.resourceSelectionConstants.sShowQuestion
                ] = this.checkIfProgramApplicableForApplication(
                    appProgramsArray,
                    this.questionMappings[questionId].applicablePrograms
                );
                questionWrapper[
                    apConstants.resourceSelectionConstants.sObjectAPI
                ] = this.questionMappings[questionId].ObjectAPI;
                questionWrapper[
                    apConstants.resourceSelectionConstants.sFieldAPI
                ] = this.questionMappings[questionId].FieldAPI;
                questionWrapper[
                    apConstants.resourceSelectionConstants.sQuestionValue
                ] = otherResourceSelectionData.value;
                questionWrapper[
                    apConstants.resourceSelectionConstants.sShowHelp
                ] = this.questionMappings[questionId].showHelp;
                questionWrapper[
                    apConstants.resourceSelectionConstants.sHelpContent
                ] = this.questionMappings[questionId].helpContent;

                this.otherResourceSelectionQuestionsList.push(questionWrapper);
            });
            this.showSpinner = false;
        } catch (error) {
            this.showSpinner = false;
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError
                    .buildOtherResourceSelectionQuestions +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : getFieldProgramMappingsForResources
     * @description : Functionality to get Field program mappings for resources.
     * @param {applicationRecordData} applicationRecordData - Application record details.
     */
    getFieldProgramMappingsForResources = applicationRecordData => {
        try {
            /* @sKey {String} Key with resource type field.
             * @bDetailsRequired {Boolean} Boolean value with details required
             * @returns { String JSON } Returns a string JSON with resource mappings.
             */
            getOtherResourceSelectionDetails({
                sApplicationId: this.applicationId
            })
                .then(result => {
                    /**2.5 Security Role Matrix and Program Access. */
                    this.isReadOnlyUser = (result.mapResponse.screenPermission != null && result.mapResponse.screenPermission != undefined && result.mapResponse.screenPermission == apConstants.permission.readOnly);
                    this.isScreenAccessible = (result.mapResponse.screenPermission != null && result.mapResponse.screenPermission != undefined && result.mapResponse.screenPermission == apConstants.permission.notAccessible) ? false : true;
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                    /** */
                    const resourceMappings = JSON.parse(
                        JSON.stringify(result.mapResponse.resourceFieldMappings)
                    );
                    this.hasMedicaidNonMagi =
                        result.mapResponse.MedicaidNonMagi;

                    Object.keys(resourceMappings).forEach(resourceMapping => {
                        const resourceMappingObject = {};
                        resourceMappingObject.applicablePrograms =
                            resourceMappings[
                                resourceMapping
                            ].ApplicablePrograms__c;
                        this.fieldProgramMappings[
                            resourceMapping
                        ] = resourceMappingObject;
                    });

                    this.questionMappings[hasTrustField.fieldApiName] = {
                        label: this.label.sspTrustFundQuestion,
                        FieldAPI: hasTrustField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasTrustField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspTrustFundHelpContent
                    };
                    this.questionMappings[hasAnnuityField.fieldApiName] = {
                        label: this.label.sspAnnuityQuestion,
                        FieldAPI: hasAnnuityField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasAnnuityField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspAnAnnuityHelpContent
                    };
                    this.questionMappings[hasLifeEstateField.fieldApiName] = {
                        label: this.label.sspLifeEstateQuestion,
                        FieldAPI: hasLifeEstateField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLifeEstateField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspLifeEstateHelpContent
                    };
                    this.questionMappings[
                        hasPromissoryContractField.fieldApiName
                    ] = {
                        label: this.label.sspLandContractQuestion,
                        FieldAPI: hasPromissoryContractField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasPromissoryContractField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspLandContractHelpContent
                    };
                    this.questionMappings[hasLTCAgreementField.fieldApiName] = {
                        label: this.label.sspPartnershipPolicyQuestion,
                        FieldAPI: hasLTCAgreementField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLTCAgreementField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspPartnershipPolicyHelpContent
                    };
                    this.questionMappings[
                        hasLifeSettlementContractField.fieldApiName
                    ] = {
                        label: this.label.sspSettlementContractQuestion,
                        FieldAPI: hasLifeSettlementContractField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLifeSettlementContractField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspSettlementContractHelpContent
                    };
                    this.questionMappings[hasBurialFundsField.fieldApiName] = {
                        label: this.label.sspBurialFundQuestion,
                        FieldAPI: hasBurialFundsField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasBurialFundsField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspBurialFundHelpContent
                    };
                    this.questionMappings[hasBurialPlotsField.fieldApiName] = {
                        label: this.label.sspBurialPlotQuestion,
                        FieldAPI: hasBurialPlotsField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasBurialPlotsField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspBurialPlotHelpContent
                    };
                    this.questionMappings[
                        hasLifeTimeCareAgreementField.fieldApiName
                    ] = {
                        label: this.label.sspCareAgreementQuestion,
                        FieldAPI: hasLifeTimeCareAgreementField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasLifeTimeCareAgreementField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: true,
                        helpContent: this.label.sspCareAgreementHelpContent
                    };
                    this.questionMappings[
                        hasOtherResourceField.fieldApiName
                    ] = {
                        label: this.label.sspReverseMortgageQuestion,
                        FieldAPI: hasOtherResourceField.fieldApiName,
                        ObjectAPI: APPLICATION_OBJECT.objectApiName,
                        applicablePrograms: this.fieldProgramMappings[
                            hasOtherResourceField.fieldApiName
                        ].applicablePrograms.split(","),
                        showHelp: false,
                        helpContent: ""
                    };
                    this.buildOtherResourceSelectionQuestions(
                        applicationRecordData
                    );
                })
                .catch(error => {
                    console.error(
                        apConstants.resourceSelectionConstants
                            .otherResourceSelectionError
                            .getFieldProgramMappingsForResources +
                            JSON.stringify(error.message)
                    );
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError
                    .getFieldProgramMappingsForResources +
                    JSON.stringify(error.message)
            );
        }
    };

    /*
     * @function : checkIfProgramApplicableForApplication
     * @description : This method used to check whether a particular program is applicable.
     */
    checkIfProgramApplicableForApplication = (
        appProgramList,
        programMappingList
    ) => {
        try {
            let hasProgram = false;
            if (!utility.isArrayEmpty(appProgramList)) {
              appProgramList.forEach(item => {
                  if (!utility.isArrayEmpty(programMappingList) && programMappingList.indexOf(item) > -1) {
                      hasProgram = true;
                  }
              });
            }
            return hasProgram;
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError
                    .checkIfProgramApplicableForApplication +
                    JSON.stringify(error.message)
            );
            return false;
        }
    };

    /*
     * @function : getRequiredInputElements
     * @description : This method get the input elements required for validation.
     */
    getRequiredInputElements = () => {
        try {
            const otherResourceSelectionItems = this.template.querySelectorAll(
                ".ssp-resourceSelectionInputs"
            );

            const otherResourceSelectionItemsArray = new Array();

            otherResourceSelectionItems.forEach(otherResourceSelectionItem => {
                otherResourceSelectionItemsArray.push(
                    otherResourceSelectionItem
                );
            });

            this.templateInputsValue = otherResourceSelectionItemsArray;
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.getRequiredInputElements +
                    JSON.stringify(error.message)
            );
        }
    };

    /* @function : saveOtherResourceSelectionData
     * @description: Method to save other resource selection data.
     */
    saveOtherResourceSelectionData = () => {
        try {
            const selectedRecord = {};
            this.otherResourceSelectionQuestionsList.forEach(
                questionSelected => {
                    selectedRecord[questionSelected.fieldAPI] =
                        questionSelected.questionValue;
                }
            );
            selectedRecord[
                APPLICATIONID_FIELD.fieldApiName
            ] = this.applicationId;

            const recordInput = {};
            recordInput.fields = selectedRecord;

            //lwc standard updateRecord call to update other resource selection details
            updateRecord(recordInput)
            .then(() => { 
                this.saveCompleted = true;
            })
            .catch(error => {
                console.error(
                    apConstants.resourceSelectionConstants
                        .otherResourceSelectionError.updateRecord +
                        JSON.stringify(error.message)
                );
            });
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError
                    .saveOtherResourceSelectionData +
                    JSON.stringify(error.message)
            );
            this.saveCompleted = false;
        }
    };

    /*
     * @function : handleQuestionsChange
     * @description : This method used to handle change of other resource selection questions.
     */
    handleQuestionsChange = event => {
        try {
            const resourceSelectionAnswer = event.detail.value;
            const resourceQuestionSelected = event.target.dataset.record;
            const resourceSelectionRecord = this.otherResourceSelectionQuestionsList.find(
                resSelectionRecord =>
                    resSelectionRecord.questionId === resourceQuestionSelected
            );
            resourceSelectionRecord[
                apConstants.resourceSelectionConstants.sQuestionValue
            ] = resourceSelectionAnswer;
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.handleQuestionsChange +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : displayLearnMoreModelMethod
     * @description : Used to open learn more modal.
     * @param {object} event - Js event.
     */
    displayLearnMoreModelMethod = event => {
        try {
            if (
                event.keyCode === apConstants.learnMoreModal.enterKeyCode ||
                event.type === apConstants.learnMoreModal.clickLearn
            ) {
                this.openLearnMoreModel = true;
            }
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.openLearnMoreModal +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : hideLearnMoreModelMethod
     * @description : Used to hide learn more modal.
     */
    hideLearnMoreModelMethod = () => {
        try {
            this.openLearnMoreModel = false;
            this.openLearnMoreModel = "";
        } catch (error) {
            console.error(
                apConstants.resourceSelectionConstants
                    .otherResourceSelectionError.closeLearnMoreModal +
                    JSON.stringify(error.message)
            );
        }
    };
}