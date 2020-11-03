/**
 * Component Name: sspConvictionPage.
 * Author: Samridh Manucha, Siddarth PV.
 * Description: This screen takes conviction information for an applicant.
 * Date: JAN-09-2020.
 */

import { api, wire, track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import {
    permission,
    toggleFieldValue,
    memberConviction
} from "c/sspConstants";

import fetchConvictionInformation from "@salesforce/apex/SSP_MemberConvictionController.fetchConvictionInformation";

import sspAnswerQuestionsConviction from "@salesforce/label/c.sspAnswerQuestionsConviction";
import sspAnyoneFleeingFelon from "@salesforce/label/c.sspAnyoneFleeingFelon";
import sspConvictedDrugFelony from "@salesforce/label/c.sspConvictedDrugFelony";
import sspIndividualChemicallyDependent from "@salesforce/label/c.sspIndividualChemicallyDependent";
import sspChemicalDependencyTreatment from "@salesforce/label/c.sspChemicalDependencytTreatment";
import sspConvictedGivingWrongInformation from "@salesforce/label/c.sspConvictedGivingWrongInformation";
import sspConvictedBuyingSellingTrading from "@salesforce/label/c.sspConvictedBuyingSellingTrading";
import sspCompleteSameContactInfo from "@salesforce/label/c.SSP_CompleteSameContactInfo";
import sspTradingSNAPBenefitsFirearms from "@salesforce/label/c.sspTradingSNAPBenefitsFirearms";
import sspTradingSNAPBenefitsDrugs from "@salesforce/label/c.sspTradingSNAPBEnefitsDrugs";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";
import sspFleeingFelonHelpText from "@salesforce/label/c.sspFleeingFelonHelpText";

import sspUtility, { getYesNoOptions, formatLabels } from "c/sspUtility";

import IS_FLEEING_FELON from "@salesforce/schema/SSP_Application__c.IsFleeingFelonToggle__c";
import IS_CONVICTED_DRUG_FELONY from "@salesforce/schema/SSP_Application__c.IsConvictedOfDrugFelonyToggle__c";
import IS_COVICTED_CHEMICAL_DEP from "@salesforce/schema/SSP_Application__c.IsConvictedChemicallyDependentToggle__c";
import IS_PARTICIPATING_COMPLETED_TREATMENT from "@salesforce/schema/SSP_Application__c.IsParticipatingCompltdTreatmentToggle__c";
import GIVEN_WRONG_INFO from "@salesforce/schema/SSP_Application__c.HasGivenWrongInformationToggle__c";
import CONVICTED_BUYING_SELLING from "@salesforce/schema/SSP_Application__c.HasConvictedOfBuyingSellingToggle__c";
import CONVICTED_TRADING_DRUGS from "@salesforce/schema/SSP_Application__c.HasConvictedOfTradingDrugsToggle__c";
import CONVICTED_TRADING_FIREARM from "@salesforce/schema/SSP_Application__c.HasConvictedOfTradingFirearm__c";
import CONVICTION_VERIFICATION from "@salesforce/schema/SSP_Application__c.ConvictionVerification__c";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspConvictionPage extends BaseNavFlowPage {
    @api memberId;
    @api applicationId;
    @api isTrueChemicalDependencyTreatment = false;
    @api isTrueIndividualChemicallyDependent = false;
    @track appliedProgram = [];
    @track fleeingFelon;
    @track convictedDrugFelony;
    @track convictedChemicalDept;
    @track participatingOrCompletedTreat;
    @track givenWrongInfo;
    @track convictedBuyingSelling;
    @track convictedTradingDrugs;
    @track convictedTradingFirearm;
    @track convictionVerification = false;
    @track wiredRecordForRefresh;
    @track metaListValues;
    @track answerValue;
    @track showSpinner = false;
    @track yesNoOptions = getYesNoOptions();
    @track isHelpText = false;
    @track pageName;
    @track label = {
        sspAnswerQuestionsConviction,
        sspAnyoneFleeingFelon,
        sspConvictedDrugFelony,
        sspIndividualChemicallyDependent,
        sspChemicalDependencyTreatment,
        sspConvictedGivingWrongInformation,
        sspConvictedBuyingSellingTrading,
        sspCompleteSameContactInfo,
        sspTradingSNAPBenefitsFirearms,
        sspTradingSNAPBenefitsDrugs,
        sspPageInformationVerified,
        sspFleeingFelonHelpText,
        startBenefitsAppCallNumber
    };
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
    updateRecord = {};

    fieldList = [
        IS_FLEEING_FELON,
        IS_CONVICTED_DRUG_FELONY,
        IS_COVICTED_CHEMICAL_DEP,
        IS_PARTICIPATING_COMPLETED_TREATMENT,
        GIVEN_WRONG_INFO,
        CONVICTED_BUYING_SELLING,
        CONVICTED_TRADING_FIREARM,
        CONVICTED_TRADING_DRUGS,
        CONVICTION_VERIFICATION
    ];

    @api
    get pageToLoad () {
        return this.pageName;
    }
    set pageToLoad (value) {
        if (value) {
            this.pageName = value;
        }
    }

    @api
    get MetadataList () {
        return this.metaListValues;
    }
    set MetadataList (value) {
        if (value) {
            this.metaListValues = value;
            //CD2 2.5	Security Role Matrix and Program Access.                
            if (Object.keys(value).length > 0) {
                this.constructRenderingMap(null, value);
            }
        }
    }

    /**
     * @function - memberProgramValues().
     * @description - This method is used to call apex method to get program details of member.
     * @param {JSON} value - Result of "fetchInformation" method call.
     */
    @wire(fetchConvictionInformation, {
        memberId: "$memberId",
        applicationId: "$applicationId"
    })
    memberConvictionValues (value) {
        try {
            if (
                value.data &&
                value.data.mapResponse &&
                value.data.mapResponse.programsApplied
            ) {
                const [program] = value.data.mapResponse.programsApplied;
                if (program) {
                    this.appliedProgram = program.split(";");
                }
            }
        } catch (error) {
            console.error(
                "Error in wire call fetchConvictionInformation:",
                error
            );
        }
    }

    @wire(getRecord, {
        recordId: "$applicationId",
        fields: "$fieldList"
    })
    wiredGetRecord (response) {
        try {
            this.wiredRecordForRefresh = response;
            if (response.data) {
                this.fleeingFelon = getFieldValue(
                    response.data,
                    IS_FLEEING_FELON
                );
                this.convictedDrugFelony = getFieldValue(
                    response.data,
                    IS_CONVICTED_DRUG_FELONY
                );
                if (this.convictedDrugFelony === toggleFieldValue.yes) {
                    this.isTrueIndividualChemicallyDependent = true;
                } else {
                    this.isTrueIndividualChemicallyDependent = false;
                }
                this.convictedChemicalDept = getFieldValue(
                    response.data,
                    IS_COVICTED_CHEMICAL_DEP
                );
                if (this.convictedChemicalDept === toggleFieldValue.yes) {
                    this.isTrueChemicalDependencyTreatment = true;
                } else {
                    this.isTrueChemicalDependencyTreatment = false;
                }
                this.participatingOrCompletedTreat = getFieldValue(
                    response.data,
                    IS_PARTICIPATING_COMPLETED_TREATMENT
                );
                this.givenWrongInfo = getFieldValue(
                    response.data,
                    GIVEN_WRONG_INFO
                );
                this.convictedBuyingSelling = getFieldValue(
                    response.data,
                    CONVICTED_BUYING_SELLING
                );
                this.convictedTradingFirearm = getFieldValue(
                    response.data,
                    CONVICTED_TRADING_FIREARM
                );
                this.convictedTradingDrugs = getFieldValue(
                    response.data,
                    CONVICTED_TRADING_DRUGS
                );
                this.convictionVerification = getFieldValue(
                    response.data,
                    CONVICTION_VERIFICATION
                );
            } else if (response.error) {
                console.error(JSON.parse(JSON.stringify(response.error)));
            }
            this.showSpinner = false;
        } catch (error) {
            console.error("Error in wire call getRecord:", error);
        }
    }

    /**
     * @function handleInputChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of newRecord.
     */
    handleInputChange = event => {
        const fieldName = event.target.fieldName;
        this.updateRecord[fieldName] = event.target.value;
    };

    /**
     * @function handleConvictedDrugFelonyChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of updateRecord.
     */
    handleConvictedDrugFelonyChange = event => {
        this.updateRecord[IS_CONVICTED_DRUG_FELONY.fieldApiName] =
            event.target.value;
        if (event.target.value === toggleFieldValue.yes) {
            this.isTrueIndividualChemicallyDependent = true;
        } else {
            this.isTrueIndividualChemicallyDependent = false;
            this.isTrueChemicalDependencyTreatment = false;
            this.convictedChemicalDept = null;
            this.participatingOrCompletedTreat = null;
        }
    };

    /**
     * @function handleConvictedDependentChange
     * @param {object} event - Event object to capture input value.
     * @description Sets attribute of updateRecord.
     */
    handleConvictedDependentChange = event => {
        this.updateRecord[IS_COVICTED_CHEMICAL_DEP.fieldApiName] =
            event.target.value;
        if (event.target.value === toggleFieldValue.yes) {
            this.isTrueChemicalDependencyTreatment = true;
        } else {
            this.isTrueChemicalDependencyTreatment = false;
            this.participatingOrCompletedTreat = null;
        }
    };

    /**
     * @function checkQuestionEligibility
     * @description : checks the questions visibility based on the program.
     * @param {object} eligibleProgram - This parameter provides the updated value.
     */
    checkQuestionEligibility (eligibleProgram) {
        try {
            if (this.appliedProgram) {
                return this.appliedProgram.some(function (item) {
                    return eligibleProgram.includes(item);
                });
            }
            return false;
        } catch (error) {
            console.error("Error in checkQuestionEligibility:", error);
        }
    }

    /**
     * @function - showMultipleProgramQuestion().
     * @description - Getter method for multiple program question.
     */
    get showMultipleProgramQuestion () {
        const eligibleProgram = memberConviction.showMultipleProgram;
        const eligibleValue = this.checkQuestionEligibility(eligibleProgram);
        return eligibleValue;
    }

    /**
     * @function - showSingleProgramQuestion().
     * @description - Getter method for single program question.
     */
    get showSingleProgramQuestion () {
        const eligibleProgram = memberConviction.showSingleProgram;
        const eligibleValue = this.checkQuestionEligibility(eligibleProgram);
        return eligibleValue;
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (!BaseNavFlowPage.isUndefinedOrNull(value)) {
                this.nextValue = value;
                this.checkInputValidation();
            }
        } catch (e) {
            console.error("Error in set nextEvent of Conviction page", e);
        }
    }

    /**
     * @function connectedCallback
     * @description Fetch metadata for validations.
     */
    connectedCallback () {
        try {
            this.showSpinner = false;
            this.isHelpText = true;
            this.label.sspPageInformationVerified = formatLabels(
                this.label.sspPageInformationVerified,
                [this.pageName]
            );
            const fieldList = this.fieldList.map(field =>
                [field.fieldApiName, field.objectApiName].join(",")
            );
            this.getMetadataDetails(
                fieldList,
                null,
                "SSP_APP_Details_Conviction"
            );
        } catch (error) {
            console.error("Error in connectedCallback:", error);
        }
    }

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            const convictionInfo = this.template.querySelectorAll(
                ".convictionDetails"
            );
            this.templateInputsValue = Array.from(convictionInfo);
        } catch (e) {
            console.error(
                "Error in checkInputValidation of Conviction page",
                e
            );
        }
    };

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;
            if (!BaseNavFlowPage.isUndefinedOrNull(value)) {
                this.saveConvictionData();
            }
        } catch (e) {
            console.error("Error in set allowSaveData of Conviction page", e);
        }
    }

    /**
     * @function :  saveConvictionData
     * @description : This method is used to save Conviction information.
     */
    saveConvictionData = () => {
        try {
            if (this.applicationId) {
                this.updateRecord.Id = this.applicationId;
                updateRecord({ fields: this.updateRecord }).then(
                    () => refreshApex(this.wiredRecordForRefresh),
                    error => console.error("Error in saving: ", error)
                );
            }
            this.saveCompleted = true;
        } catch (e) {
            console.error("Error in saveConvictionData of Conviction page", e);
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
            if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const { securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                    this.isNotAccessible = securityMatrix.screenPermission === permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
            }
        } catch (error) {
            console.error(
                              "Error in highestEducation.constructRenderingMap", error
                        );
        }
    }
}
