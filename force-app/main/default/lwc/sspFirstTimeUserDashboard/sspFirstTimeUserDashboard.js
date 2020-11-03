/**
 * Component Name: sspFirstTimeUserDashboard.
 * Author: Yathansh Sharma.
 * Description: This screen will give access to first time user to view their information about different programs offered, as well as an action to apply for benefits.
 * Date: 09/01/2020.
 */
 
import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import fetchRequiredData from "@salesforce/apex/SSP_DashboardController.fetchRequiredData"; //CD2 - 6.1
import sspMyInformation from "@salesforce/label/c.SSP_MyInformation";
import sspYouCanCheckYourEligibility from "@salesforce/label/c.SSP_YouCanCheckYourEligibilityApplyForBenefitsForTheFollowing";
import sspApplyForBenefits from "@salesforce/label/c.sspApplyForBenefits";
import sspGetBenefitsForMedicalExpensesFoodFinancesAndChildCare from "@salesforce/label/c.SSP_GetBenefitsForMedicalExpensesFoodFinancesAndChildCare";
import sspSeeIfIMayBeEligible from "@salesforce/label/c.SSP_SeeIfIMayBeEligible";
import sspUseTheScreeningTool from "@salesforce/label/c.SSP_HomePagePrescreeningSubText";
import sspStartCheckingEligibility from "@salesforce/label/c.SSP_StartCheckingEligibility";
import sspWelcome from "@salesforce/label/c.SSP_Welcome";
import sspCardImages from "@salesforce/resourceUrl/SSP_KynectImages7";
import sspUtility from "c/sspUtility";
import sspFoodAssistance from "@salesforce/label/c.SSP_FoodAssistance";
import sspSupplementalNutritionAssistanceProgramSNAP from "@salesforce/label/c.SSP_SupplementalNutritionAssistanceProgramSNAP";
import sspSNAPAllowsParticipantsToBuyHealthyFoodOptions from "@salesforce/label/c.SSP_SNAPAllowsParticipantsToBuyHealthyFoodOptions";

import sspFinancialAssistance from "@salesforce/label/c.SSP_FinancialAssistance";
import sspKentuckyTransitionalAssistanceProgramKTAP from "@salesforce/label/c.SSP_KentuckyTransitionalAssistanceProgramKTAP";
import sspKTAPHelpsFamiliesWithChildrenPayForBasicHouseholdExpenses from "@salesforce/label/c.SSP_KTAPHelpsFamiliesWithChildrenPayForBasicHouseholdExpenses";

import sspHealthAssistance from "@salesforce/label/c.sspHomePageHealthAssist";
import sspMedicaidKentuckyChildrenHealthInsuranceProgramKCHIP from "@salesforce/label/c.sspHomePageHealthAssistContent1";
import sspTheseProgramsHelpCoverMedicalAndPreventativeHealthCareCosts from "@salesforce/label/c.SSP_TheseProgramsHelpCoverMedicalAndPreventativeHealthcareCosts";

import sspPremiumAssistance from "@salesforce/label/c.SSP_PremiumAssistance";
import sspKentuckyIntegratedHealthInsurancePremiumPaymentProgramKIHIPP from "@salesforce/label/c.SSP_KentuckyIntegratedHealthInsurancePremiumPaymentProgramKIHIPP";
import sspKIHIPPIsMedicalProgramItHelpsPayForEmployerSponsoredInsuranceESI from "@salesforce/label/c.SSP_KIHIPPIsMedicalProgramItHelpsPayForEmployerSponsoredInsuranceESI";

import sspChildCareAssistance from "@salesforce/label/c.SSP_ChildCareAssistance";
import sspChildCareAssistanceProgram from "@salesforce/label/c.SSP_ChildCareAssistanceProgram";
import sspTheChildCareAssistanceProgramHelpsWorkingFamiliesPayForChildCare from "@salesforce/label/c.SSP_TheChildCareAssistanceProgramHelpsWorkingFamiliesPayForChildCare";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";

import sspStateSupplementation from "@salesforce/label/c.SSP_StateSupplementation";
import sspStateSupplementationProgram from "@salesforce/label/c.SSP_StateSupplementationProgram";
import sspStateSupplementationDescription from "@salesforce/label/c.SSP_StateSupplementationDescription";
import sspConstants from "c/sspConstants";
export default class SspFirstTimeUserDashboard extends NavigationMixin(LightningElement) {
    customLabels = {
        sspMyInformation,
        sspYouCanCheckYourEligibility,
        sspApplyForBenefits,
        sspGetBenefitsForMedicalExpensesFoodFinancesAndChildCare,
        sspSeeIfIMayBeEligible,
        sspUseTheScreeningTool,
        sspStartCheckingEligibility,
        sspWelcome,
        sspFoodAssistance,
        sspSupplementalNutritionAssistanceProgramSNAP,
        sspSNAPAllowsParticipantsToBuyHealthyFoodOptions,
        sspFinancialAssistance,
        sspKentuckyTransitionalAssistanceProgramKTAP,
        sspKTAPHelpsFamiliesWithChildrenPayForBasicHouseholdExpenses,
        sspHealthAssistance,
        sspMedicaidKentuckyChildrenHealthInsuranceProgramKCHIP,
        sspTheseProgramsHelpCoverMedicalAndPreventativeHealthCareCosts,
        sspPremiumAssistance,
        sspKentuckyIntegratedHealthInsurancePremiumPaymentProgramKIHIPP,
        sspKIHIPPIsMedicalProgramItHelpsPayForEmployerSponsoredInsuranceESI,
        sspChildCareAssistance,
        sspChildCareAssistanceProgram,
        sspTheChildCareAssistanceProgramHelpsWorkingFamiliesPayForChildCare,
        sspLearnMoreLink,
        sspStateSupplementation,
        sspStateSupplementationProgram,
        sspStateSupplementationDescription
    };
    backgroundImg = sspCardImages + "/Dashboard.png";
    backgroundImgMobile = sspCardImages + "/DashboardMobile.jpg";

    tempUsername = ", ";
    @api memberName;

    /**CD2 - 6.1 .*/
    @track programAccess = {
        [sspConstants.programValues.SS] : false
    };
    /** */
    @track welcomeNote = this.customLabels.sspWelcome + this.tempUsername;
    @track programsOffered = [
        {
            typeOfAssistance: this.customLabels.sspFoodAssistance,
            programName: this.customLabels.sspSupplementalNutritionAssistanceProgramSNAP,
            programDescription:
                this.customLabels.sspSNAPAllowsParticipantsToBuyHealthyFoodOptions
        },
        {
            typeOfAssistance: this.customLabels.sspFinancialAssistance,
            programName: this.customLabels.sspKentuckyTransitionalAssistanceProgramKTAP,
            programDescription:
                this.customLabels.sspKTAPHelpsFamiliesWithChildrenPayForBasicHouseholdExpenses
        },
        {
            typeOfAssistance: this.customLabels.sspHealthAssistance,
            programName:
                this.customLabels.sspMedicaidKentuckyChildrenHealthInsuranceProgramKCHIP,
            programDescription:
                this.customLabels.sspTheseProgramsHelpCoverMedicalAndPreventativeHealthCareCosts
        },
        {
            typeOfAssistance: this.customLabels.sspPremiumAssistance,
            programName:
                this.customLabels.sspKentuckyIntegratedHealthInsurancePremiumPaymentProgramKIHIPP,
            programDescription:
                this.customLabels.sspKIHIPPIsMedicalProgramItHelpsPayForEmployerSponsoredInsuranceESI
        },
        {
            typeOfAssistance: this.customLabels.sspChildCareAssistance,
            programName: this.customLabels.sspChildCareAssistanceProgram,
            programDescription:
                this.customLabels.sspTheChildCareAssistanceProgramHelpsWorkingFamiliesPayForChildCare
        }
    ];

    connectedCallback () {
        this.fetchDataFromServer();
    }

    applyForBenefits = () => {
        this[NavigationMixin.Navigate]({
            type: sspConstants.communityPageNames.community,
            attributes: {
                name: sspConstants.communityPageNames.getStartedBenefits
            }
        });
    }

    checkEligibility = () => {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: "member-details"
            },
            state: {
                memberId: "test"
            }
        });
    }

    navigateMyInformation = () => {
        this[NavigationMixin.Navigate]({
            type: sspConstants.communityPageNames.community,
            attributes: {
                name: sspConstants.communityPageNames.myInformationApi
            }
        });
    }

    /**
    * @function : fetchDataFromServer.
    * @description	: Method to fetch required details(program access) CD2 - 6.1. 
    */
    fetchDataFromServer = () => {
        try {
            fetchRequiredData({})
                .then(result => {
                    const parsedData = result.mapResponse;
                    if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in retrieving data sspFirstTimeUserDashboard  " +
                            JSON.stringify(parsedData.ERROR)
                        );
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {                            
                        if (parsedData.hasOwnProperty("accessiblePrograms")) {
                            const accessiblePrograms = parsedData.accessiblePrograms;
                            const self = this;
                            Object.keys(this.programAccess).forEach(key => {
                                if (!sspUtility.isUndefinedOrNull(accessiblePrograms) && accessiblePrograms.includes(key)){
                                    self.programAccess[key] = true
                                } 
                            });
                        }
                        if (this.programAccess[sspConstants.programValues.SS]) {
                            const ssObj = {
                                typeOfAssistance: this.customLabels.sspStateSupplementation,
                                programName:
                                    this.customLabels.sspStateSupplementationProgram,
                                programDescription:
                                    this.customLabels.sspStateSupplementationDescription
                            };
                            this.programsOffered.push(ssObj);
                        }
                    }
                    //this.renderingAttributes.requiredDataRetrieved = true;

                })
                .catch(error => {
                    console.error(
                        "failed in sspFirstTimeUserDashboard.fetchDataFromServer " +
                        JSON.stringify(error)
                    );
                });
            
        } catch (error) {
            console.error(
                "failed in sspFirstTimeUserDashboard.fetchDataFromServer " +
                JSON.stringify(error)
            );
        }
    };


    /**
   * @function : redirectToPreScreeningTool.
   * @description : redirect User to PreScreening Tool.
   */

  redirectToPreScreeningTool (){
    {
    this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
        attributes: {
            name: sspConstants.communityPageNames.prescreeening
          },
          state: {
                    retPage: "dashboard__c"
          }
    });
}
}
}
