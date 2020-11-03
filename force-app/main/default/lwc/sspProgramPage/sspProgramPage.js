/**
 * Component Name: sspProgramPage.
 * Author: P V Siddarth.
 * Description: The component shows 6 different program pages.
 * Date: 02/10/2019.
 */

import { track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import downloadCCProviderList from "@salesforce/apex/SSP_ChildCareProviderSearchController.downloadCCProviderList";

import sspStateProgram from "@salesforce/label/c.sspStateProgram";
import sspSupplementalNutritionAssistanceProgramSNAP from "@salesforce/label/c.SSP_SupplementalNutritionAssistanceProgramSNAP";
import sspApplyForBenefits from "@salesforce/label/c.sspApplyForBenefits";
import sspPreScreeningTool from "@salesforce/label/c.sspPrescreeningTool";
import sspHomePageCheckEligibility from "@salesforce/label/c.sspHomePageCheckEligibility";
import sspSnapOverviewApplicants from "@salesforce/label/c.sspSnapOverviewApplicants";
import sspSNAPHelpsPeople from "@salesforce/label/c.sspSNAPHelpsPeople";
import sspBasicQualifications from "@salesforce/label/c.sspBasicQualifications";
import sspHouseHoldMeetingBasicIncome from "@salesforce/label/c.sspHouseHoldMeetingBasicIncome";
import sspCitizenship from "@salesforce/label/c.sspCitizenship";
import sspOnlyUSCitizensMeetRequirements from "@salesforce/label/c.sspOnlyUSCitizensMeetRequirements";
import sspWorkRegistration from "@salesforce/label/c.sspWorkRegistration";
import sspHouseHoldMembersMustParticipate from "@salesforce/label/c.sspHouseHoldMembersMustParticipate";
import sspSomeExceptionsMayApply from "@salesforce/label/c.sspSomeExceptionsMayApply";
import sspResources from "@salesforce/label/c.sspResources";
import sspHouseHoldMayHaveNoMoreThan from "@salesforce/label/c.sspHouseHoldMayHaveNoMoreThan";
import sspWhatIsExpeditedSnap from "@salesforce/label/c.sspWhatIsExpeditedSnap";
import sspYouMayQualifySNAP from "@salesforce/label/c.sspYouMayQualifySNAP";
import sspHowToApplySNAP from "@salesforce/label/c.sspHowToApplySNAP";
import sspSNAPApplicationAssistance from "@salesforce/label/c.sspSNAPApplicationAssistance";
import sspShouldYouNeedAssistance from "@salesforce/label/c.sspShouldYouNeedAssistance";
import sspSNAPApplicantLegalRights from "@salesforce/label/c.sspSNAPApplicantLegalRIghts";
import sspAsSNAPApplicant from "@salesforce/label/c.sspAsSNAPApplicant";

import sspIncome from "@salesforce/label/c.sspIncome";
import sspAdditionalInformation from "@salesforce/label/c.sspAdditionalInformation";
import sspForMoreInfoContactDCBS from "@salesforce/label/c.sspForMoreInfoContactDCBS";
import sspApplyOnline from "@salesforce/label/c.sspApplyOnline";
import sspApplyInPerson from "@salesforce/label/c.sspApplyInPerson";
import sspSubmitA from "@salesforce/label/c.sspSubmitA";
import sspLanguageGrid1 from "@salesforce/label/c.sspLanguageGrid1";
import sspLanguageGrid2 from "@salesforce/label/c.sspLanguageGrid2";
import sspLanguageGrid3 from "@salesforce/label/c.sspLanguageGrid3";
import sspHowToApplySNAPSteps1 from "@salesforce/label/c.sspHowToApplySNAPSteps1";
import sspHowToApplySNAPSteps2 from "@salesforce/label/c.sspHowToApplySNAPSteps2";

import sspMedicaid from "@salesforce/label/c.sspMedicaid";
import sspKentuckyTransitionalAssistanceProgram from "@salesforce/label/c.sspKentuckyTransitionalAssistanceProgram";
import sspChildCareAssistanceProgramCCAP from "@salesforce/label/c.sspChildCareAssistanceProgramCCAP";
import sspKentuckyIntegratedHealthInsurancePremiumPaymentKIHIPP from "@salesforce/label/c.sspKentuckyIntegratedHealth_InsurancePremiumPaymentKIHIPP";

import sspOverviewMedicaid from "@salesforce/label/c.sspOverviewMedicaid";
import sspQualificationsMedicaidDescription from "@salesforce/label/c.sspQualificationsMedicaidDescription";
import sspQualificationsMedicaid from "@salesforce/label/c.sspQualificationsMedicaid";
import sspOverviewMedicaidDescription from "@salesforce/label/c.sspOverviewMedicaidDescription";
import sspOverviewKTAP from "@salesforce/label/c.sspOverviewKTAP";
import sspOverviewKTAPDescription from "@salesforce/label/c.sspOverviewKTAPDescription";
import sspQualificationsKTAP from "@salesforce/label/c.sspQualificationsKTAP";
import sspQualificationsKTAPDescription from "@salesforce/label/c.sspQualificationsKTAPDescription";
import sspOverviewCCAP from "@salesforce/label/c.sspOverviewCCAP";
import sspOverviewCCAPDescription from "@salesforce/label/c.sspOverviewCCAPDescription";
import sspQualificationsCCAPDescription from "@salesforce/label/c.sspQualificationsCCAPDescription";
import sspQualificationsCCAPDescription2 from "@salesforce/label/c.sspQualificationsCCAPDescription2";
import sspOverviewKIHIPP from "@salesforce/label/c.sspOverviewKIHIPP";
import sspOverviewKIHIPPDescription from "@salesforce/label/c.sspOverviewKIHIPPDescription";
import sspQualificationsKIHIPPDescription from "@salesforce/label/c.sspQualificationsKIHIPPDescription";
import sspAdditionalInformationMedicaid from "@salesforce/label/c.sspAdditionalInformationMedicaid";
import sspWaysToApplyMedicaid from "@salesforce/label/c.sspWaysToApplyMedicaid";
import sspWaysToApplyMedicaidDescription from "@salesforce/label/c.sspWaysToApplyMedicaidDescription";
import sspMedicaidApplicationAssistance from "@salesforce/label/c.sspMedicaidApplicationAssistance";
import sspMedicaidApplicationAssistanceDescription from "@salesforce/label/c.sspMedicaidApplicationAssistanceDescription";
import sspQuestionsAboutMedicaid from "@salesforce/label/c.sspQuestionsAboutMedicaid";
import sspWaysToApplyKTAP from "@salesforce/label/c.sspWaysToApplyKTAP";
import sspWaysToApplyKTAPHeading from "@salesforce/label/c.sspWaysToApplyKTAPHeading";
import sspKTAPPolicy from "@salesforce/label/c.sspKTAPPolicy";
import sspKTAPPolicyDescription from "@salesforce/label/c.sspKTAPPolicyDescription";
import sspWaysToApplyCCAP from "@salesforce/label/c.sspWaysToApplyCCAP";
import sspWaysToApplyCCAPDescription2 from "@salesforce/label/c.sspWaysToApplyCCAPDescription2";
import sspWaysToApplyCCAPDescription3 from "@salesforce/label/c.sspWaysToApplyCCAPDescription3";
import sspWaysToApplyCCAPDescriptionBeta from "@salesforce/label/c.sspWaysToApplyCCAPDescriptionBeta";
import sspWaysToApplyCCAPDescription from "@salesforce/label/c.sspWaysToApplyCCAPDescription";
import sspHouseholdSizeDeterminesIncome from "@salesforce/label/c.sspHouseholdSizeDeterminesIncome";
import sspHouseHoldGrossIncomeLess from "@salesforce/label/c.sspHouseHoldGrossIncomeLess";
import sspWaysToApplyKIHIPP from "@salesforce/label/c.sspWaysToApplyKIHIPP";
import sspWaysToApplyKIHIPPDescription from "@salesforce/label/c.sspWaysToApplyKIHIPPDescription";
import sspKIHIPPEligibilityDocuments from "@salesforce/label/c.sspKIHIPPEligibilityDocuments";
import sspKIHIPPEligibilityDocumentsDescription from "@salesforce/label/c.sspKIHIPPEligibilityDocumentsDescription";
import sspWhereToSendDocuments from "@salesforce/label/c.sspWhereToSendDocuments";
import sspPaymentsKIHIPP from "@salesforce/label/c.sspPaymentsKIHIPP";
import sspKIHIPPPaymentsDescription from "@salesforce/label/c.sspKiHIPPPaymentsDescription";
import sspKIHIPPUploadTheDoc from "@salesforce/label/c.sspKIHIPPUploadTheDoc";
import sspKIHIPPEmailTHeDoc from "@salesforce/label/c.sspKIHIPPEmailTHeDoc";
import sspKIHIPPMailTheDoc from "@salesforce/label/c.sspKIHIPPMailTheDoc";
import sspWaysToApplyMedicaidDescriptionTwo from "@salesforce/label/c.sspWaysToApplyMedicaidDescriptionTwo";
import sspKIHIPPPaymentsDescriptionTwo from "@salesforce/label/c.sspKiHIPPPaymentsDescriptionTwo";
import sspKiHIPPPaymentsDescriptionThree from "@salesforce/label/c.sspKiHIPPPaymentsDescriptionThree";
import sspKihipp63Form from "@salesforce/label/c.sspKihipp63Form";

import sspWaysToApplyKTAP2 from "@salesforce/label/c.sspWaysToApplyKTAP2";
import sspQualificationsMedicaidDescriptionHeader from "@salesforce/label/c.sspQualificationsMedicaidDescriptionHeader";
import { NavigationMixin } from "lightning/navigation";
import programPageMobile from "@salesforce/resourceUrl/programPageMobile";
import constants from "c/sspConstants";
import sspIcons from "@salesforce/resourceUrl/SSP_ProgramPageResources";
import { formatLabels } from "c/sspUtility";
import sspAssert from "@salesforce/resourceUrl/SSP_Assert";
import sspSnapAssert from "@salesforce/resourceUrl/sspSnapAsserts";
import sspWaysToApplyKIHIPPDescription1 from "@salesforce/label/c.sspWaysToApplyKIHIPPDescription1";
import sspHealthCoverageForm from "@salesforce/label/c.SSP_HealthCoverageForm";
import sspChildCareProviderHeader from "@salesforce/label/c.sspChildCareProviderHeader";
import sspChildCareSummary from "@salesforce/label/c.sspChildCareSumamary";
import sspSearchChildCareProviders from "@salesforce/label/c.SSP_SearchChildCareProviders";
import sspChildCareAware from "@salesforce/label/c.sspChildCareAware";
import sspChildCareAware2 from "@salesforce/label/c.sspChildCareAware2";
import sspChildCareResource from "@salesforce/label/c.sspChildCareResource";
import sspChildcareDownload from "@salesforce/label/c.sspChildcareDownload";
import sspChildCareReport from "@salesforce/label/c.sspChildCareReport";

import sspHealthBenefitExchange from "@salesforce/label/c.sspHealthBenefitExchange";
import sspLowCostHealth from "@salesforce/label/c.sspLowCostHealth";
import sspFindOutCoverageYouQualify from "@salesforce/label/c.sspFindOutCoverageYouQualify";
import sspMedicaidAndKCHIP from "@salesforce/label/c.SSP_MedicaidAndKCHIP";
import sspOverviewMedicaidAndKCHIP from "@salesforce/label/c.SSP_OverviewMedicaidAndKCHIP";
import sspQualificationsMedicaidAndKCHIP from "@salesforce/label/c.SSP_QualificationsMedicaidAndKCHIP";
import sspAdditionalInformationMedicaidAndKCHIPP from "@salesforce/label/c.SSP_AdditionalInformationMedicaidAndKCHIPP";
import sspWaysToApplyMedicaidAndKCHIPP from "@salesforce/label/c.SSP_WaysToApplyMedicaidAndKCHIPP";
import sspTimeLimitedMedicaidHeader from "@salesforce/label/c.SSP_TimeLimitedMedicaidHeader";
import sspTimeLimitedMedicaidContent from "@salesforce/label/c.SSP_TimeLimitedMedicaidContent";
import sspApplyForTimeLimitedCoverage from "@salesforce/label/c.SSP_ApplyForTimeLimitedCoverage";
import sspApplyForTimeLimitedCoverageLink from "@salesforce/label/c.SSP_ApplyForTimeLimitedCoverageLink";

export default class SspProgramPage extends NavigationMixin(BaseNavFlowPage) {
    @track showTargetAnchorTag = false;
	@track languageSpanish = false;
    @track backgroundClass = "ssp-imgContainer ssp-bottomMargin";
    @track label = {
        sspFindOutCoverageYouQualify,
        sspLowCostHealth,
        sspHealthBenefitExchange,
        sspHealthCoverageForm,
        sspWaysToApplyKIHIPPDescription1,
        sspStateProgram,
        sspSupplementalNutritionAssistanceProgramSNAP,
        sspApplyForBenefits,
        sspPreScreeningTool,
        sspHomePageCheckEligibility,
        sspSnapOverviewApplicants,
        sspSNAPHelpsPeople,
        sspBasicQualifications,
        sspHouseHoldMeetingBasicIncome,
        sspCitizenship,
        sspOnlyUSCitizensMeetRequirements,
        sspWorkRegistration,
        sspHouseHoldMembersMustParticipate,
        sspSomeExceptionsMayApply,
        sspResources,
        sspHouseHoldMayHaveNoMoreThan,
        sspHouseholdSizeDeterminesIncome,
        sspHouseHoldGrossIncomeLess,
        sspIncome,
        sspWhatIsExpeditedSnap,
        sspYouMayQualifySNAP,
        sspHowToApplySNAP,
        sspSNAPApplicationAssistance,
        sspShouldYouNeedAssistance,
        sspSNAPApplicantLegalRights,
        sspAsSNAPApplicant,
        sspAdditionalInformation,
        sspForMoreInfoContactDCBS,
        sspApplyOnline,
        sspApplyInPerson,
        sspSubmitA,
        sspOverviewMedicaidDescription,
        sspKentuckyTransitionalAssistanceProgram,
        sspMedicaid,
        sspKentuckyIntegratedHealthInsurancePremiumPaymentKIHIPP,
        sspChildCareAssistanceProgramCCAP,
        sspLanguageGrid1,
        sspLanguageGrid2,
        sspLanguageGrid3,
        sspHowToApplySNAPSteps1,
        sspHowToApplySNAPSteps2,
        sspOverviewMedicaid,
        sspQualificationsMedicaid,
        sspQualificationsMedicaidDescription,
        sspOverviewKTAP,
        sspOverviewKTAPDescription,
        sspQualificationsKTAP,
        sspQualificationsKTAPDescription,
        sspOverviewCCAP,
        sspOverviewCCAPDescription,
        sspQualificationsCCAPDescription,
        sspQualificationsCCAPDescription2,
        sspOverviewKIHIPP,
        sspOverviewKIHIPPDescription,
        sspQualificationsKIHIPPDescription,
        sspAdditionalInformationMedicaid,
        sspWaysToApplyMedicaid,
        sspWaysToApplyMedicaidDescription,
        sspMedicaidApplicationAssistance,
        sspMedicaidApplicationAssistanceDescription,
        sspQuestionsAboutMedicaid,
        sspWaysToApplyKTAP,
        sspWaysToApplyKTAPHeading,
        sspKTAPPolicy,
        sspKTAPPolicyDescription,
        sspWaysToApplyCCAP,
        sspWaysToApplyCCAPDescription,
        sspWaysToApplyCCAPDescription2,
        sspWaysToApplyCCAPDescription3,
        sspWaysToApplyCCAPDescriptionBeta,
        sspWaysToApplyKIHIPP,
        sspWaysToApplyKIHIPPDescription,
        sspKIHIPPEligibilityDocuments,
        sspKIHIPPEligibilityDocumentsDescription,
        sspWhereToSendDocuments,
        sspPaymentsKIHIPP,
        sspKIHIPPPaymentsDescription,
        sspKIHIPPUploadTheDoc,
        sspKIHIPPEmailTHeDoc,
        sspKIHIPPMailTheDoc,
        sspQualificationsMedicaidDescriptionHeader,
        sspWaysToApplyKTAP2,
        sspWaysToApplyMedicaidDescriptionTwo,
        sspChildCareProviderHeader,
        sspChildCareSummary,
        sspSearchChildCareProviders,
        sspChildCareAware,
        sspChildCareAware2,
        sspChildCareResource,
        sspChildcareDownload,
        sspChildCareReport,
        sspKiHIPPPaymentsDescriptionThree,
    		sspKihipp63Form,
    		sspMedicaidAndKCHIP,
    		sspOverviewMedicaidAndKCHIP,
    		sspQualificationsMedicaidAndKCHIP,
    		sspAdditionalInformationMedicaidAndKCHIPP,
    		sspWaysToApplyMedicaidAndKCHIPP,
    		sspTimeLimitedMedicaidHeader,
    		sspTimeLimitedMedicaidContent,
    		sspApplyForTimeLimitedCoverage,
    		sspApplyForTimeLimitedCoverageLink
  };
  @track sspQualificationsCCAPDescriptionFull =
    sspQualificationsCCAPDescription + sspQualificationsCCAPDescription2;
  @track sspWaysToApplyCCAPDescriptionFull =
    sspWaysToApplyCCAPDescription + sspWaysToApplyCCAPDescriptionBeta;
  @track sspQualificationsMedicaidDescriptionFull =
    sspQualificationsMedicaidDescriptionHeader +
    sspQualificationsMedicaidDescription;
  @track sspWaysToApplyKIHIPPDescriptionFull =
        sspWaysToApplyKIHIPPDescription;
  @track sspWaysToApplyKTAPFull = sspWaysToApplyKTAP + sspWaysToApplyKTAP2;
  @track SNAPApplicationIsTrue = false;
  @track MEDICAIDApplicationIsTrue = false;
  @track KTAPApplicationIsTrue = false;
  @track CCAPApplicationIsTrue = false;
  @track KIHIPPApplicationIsTrue = false;
  @track programReceived;
  @track _changeTrack;
    @track sspKIHIPPPaymentsDescriptionFull =
        sspKIHIPPPaymentsDescriptionTwo + sspKiHIPPPaymentsDescriptionThree;

  icFileIcon = sspIcons + constants.url.fileIcon;
  icPencilIcon = sspIcons + constants.url.pencilIcon;
  icLaptopIcon = sspIcons + constants.url.laptopIcon;
  icIncomeIcon = sspIcons + constants.url.incomeIcon;
  icEmailIcon = programPageMobile + constants.url.emailIcon;
  icMailIcon = programPageMobile + constants.url.mailIcon;
  icUploadIcon = programPageMobile + constants.url.uploadIcon;
    medicaidFamily = `${sspAssert}${constants.url.medicaidFamily}`;
    medicaidPerson = `${sspAssert}${constants.url.medicaidPerson}`;
    childCareEnglish = `${sspAssert}${constants.url.childCareEnglish}`;
    childCareSpanish = `${sspAssert}${constants.url.childCareSpanish}`;
    healthCoverKIHip = `${sspAssert}${constants.url.healthCoverKIHip}`;
    healthCoverKIHipSpanish = `${sspAssert}${constants.url.healthCoverKIHipSpanish}`;
    healthCoverKIHipInstruction = `${sspAssert}${constants.url.healthCoverKIHipInstruction}`;
    healthCoverAuthorization = `${sspAssert}${constants.url.healthCoverAuthorization}`;
    healthCoverAuthorizationSpanish = `${sspAssert}${constants.url.healthCoverAuthorizationSpanish}`;
    snapAppArabic = `${sspSnapAssert}${constants.url.snapAppArabic}`;
    snapAppBosnian = `${sspSnapAssert}${constants.url.snapAppBosnian}`;
    snapAppChinese = `${sspSnapAssert}${constants.url.snapAppChinese}`;
    snapAppEnglish = `${sspSnapAssert}${constants.url.snapAppEnglish}`;
    snapAppFrench = `${sspSnapAssert}${constants.url.snapAppFrench}`;
    snapAppRussian = `${sspSnapAssert}${constants.url.snapAppRussian}`;
    snapAppSomali = `${sspSnapAssert}${constants.url.snapAppSomali}`;
    snapAppSpanish = `${sspSnapAssert}${constants.url.snapAppSpanish}`;
    snapAppVietnamese = `${sspSnapAssert}${constants.url.snapAppVietnamese}`;
  /**
   * @function : connectedCallback.
   * @description : Method to track url change.
   */
  connectedCallback () {
    try {
      const reference = this;
            const browserIExplorer = window.navigator && window.navigator.msSaveOrOpenBlob ? true : false;
            const browserIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
            if(browserIExplorer || browserIOS){
                this.showTargetAnchorTag = true;
            }
            if (location.href.includes("language=es_US")) {
               
				this.languageSpanish = true;
            } else {
              
				this.languageSpanish = false;
            }
            /*  history.pushState = (f =>
                function pushState() {
                    f.apply(this, arguments);
                    reference.programChange();
                })(history.pushState); */
            this.label.sspWaysToApplyMedicaidDescriptionTwo = formatLabels(
                this.label.sspWaysToApplyMedicaidDescriptionTwo,
                [this.medicaidFamily, this.medicaidPerson]
            );
            this.label.sspWaysToApplyCCAPDescriptionBeta = formatLabels(
                this.label.sspWaysToApplyCCAPDescriptionBeta,
                [this.childCareEnglish, this.childCareSpanish]
            );
            this.sspWaysToApplyKIHIPPDescriptionFull = formatLabels(
                this.sspWaysToApplyKIHIPPDescriptionFull,
                [this.healthCoverKIHip]
            );
            this.label.sspKIHIPPPaymentsDescription = formatLabels(
                this.label.sspKIHIPPPaymentsDescription,
                [this.healthCoverAuthorization]
            );
            this.label.sspLanguageGrid1 = formatLabels(
                this.label.sspLanguageGrid1,
                [this.snapAppEnglish, this.snapAppSpanish, this.snapAppArabic, this.snapAppBosnian]
            );
            this.label.sspLanguageGrid2 = formatLabels(
                this.label.sspLanguageGrid2,
                [this.snapAppChinese, this.snapAppFrench, this.snapAppRussian, this.snapAppSomali]
            );
            this.label.sspLanguageGrid3 = formatLabels(
                this.label.sspLanguageGrid3,
                [this.snapAppVietnamese]
            );
      reference.programChange();
    } catch (error) {
      console.error("Error in  connectedCallback", error);
    }
  }

  redirectToApplyBenefit = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",

        attributes: {
          name: constants.homePageConstants.applyBenefitPageName
        }
      });
    } catch (error) {
      console.error("Error calling redirectToApplyBenefit: ", error);
    }
  };
  /**
   * @function : programChange.
   * @description : Method to change program as per the updated url.
   */
  programChange () {
    try {
      let program = null;
      const sPageURL = decodeURIComponent(window.location.search.substring(1));
      const sURLVariables = sPageURL.split("&");

      if (sURLVariables != null) {
        for (let i = 0; i < sURLVariables.length; i++) {
          const sParam = sURLVariables[i].split("=");

          if (sParam[0] === "program") {
            program = sParam[0 + 1] === undefined ? "Not found" : sParam[0 + 1];

            break;
          }
        }
      }
      this.programReceived = program;

      this.SNAPApplicationIsTrue = false;
      this.MEDICAIDApplicationIsTrue = false;
      this.KTAPApplicationIsTrue = false;
      this.CCAPApplicationIsTrue = false;
      this.KIHIPPApplicationIsTrue = false;

      if (this.programReceived === constants.programValues.SN) {
        this.SNAPApplicationIsTrue = true;
                this.backgroundClass = `${this.backgroundClass} ssp-imgContainerSnap`;
      } else if (this.programReceived === constants.programValues.MA) {
        this.MEDICAIDApplicationIsTrue = true;
                this.backgroundClass = `${this.backgroundClass} ssp-imgContainerMedicaid`;
      } else if (this.programReceived === constants.programValues.KT) {
        this.KTAPApplicationIsTrue = true;
				this.backgroundClass = `${this.backgroundClass} ssp-imgContainerKTAP`;
      } else if (this.programReceived === constants.programValues.CC) {
        this.CCAPApplicationIsTrue = true;
                this.backgroundClass = `${this.backgroundClass} ssp-imgContainerCCAP`;
      } else if (this.programReceived === constants.programValues.KP) {
        this.KIHIPPApplicationIsTrue = true;
                this.backgroundClass = `${this.backgroundClass} ssp-imgContainerKIHIPP`;
      }
    } catch (error) {
      console.error("Error in  programChange" + error);
    }
  }
    /**
     */
    navigateHealthBenefits () {
        window.open(constants.url.healthBenefitExchange, "_blank");
    }
    /**
     * @function : redirectToPreScreeningTool.
     * @description : redirect User to PreScreening Tool.
     */

    redirectToPreScreeningTool () {
    {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: constants.communityPageNames.prescreeening
        },
        state: {
                    retPage: "Program_Page__c",
                    programType:this.programReceived
        }
      });
    }
  }
    /**
     * @function 		: openHealthCoverageForm.
     * @description 	: method for download the pdf.
     * @param {e} event - Event checks which file to download.
     **/
    openHealthCoverageForm = event => {
        try {
            const documentName = event.target.dataset.documentName;
            this.documentNameTemp = documentName;
            if (event.keyCode === 13 || event.type === "click") {
                const pageUrl = "program-form-download";
                const previewUrl = pageUrl + "?contentDoc=KIHIPPHealthCover";
                // For other browsers Download Document
                const isSafari =
                    navigator.userAgent.indexOf("Safari") != -1 &&
                    navigator.userAgent.indexOf("Chrome") == -1;
                const isMobile = navigator.userAgent.match(
                    /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
                );
                if (isSafari || !isMobile) {
                    window.open(this.healthCoverKIHip, "_blank");
                } else {
                    window.open(previewUrl, "_blank");
                }

                const downloadElement = document.createElement("a");
                downloadElement.href =
                    window.location.origin + this.healthCoverKIHip;
                downloadElement.setAttribute("download", "download");
                downloadElement.download = "KIHIPPHealthCoverSpanish.pdf";
                downloadElement.click();
            }
        } catch (error) {
            console.error(
                "Error in openHealthCoverageForm" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function 		: openHealthCoverageFormSpanish.
     * @description 	: method for download the pdf.
     * @param {e} event - Event checks which file to download.
     **/
    openHealthCoverageFormSpanish = event => {
        try {
            const documentName = event.target.dataset.documentName;
            this.documentNameTemp = documentName;
            if (event.keyCode === 13 || event.type === "click") {
                const pageUrl = "program-form-download";
                const previewUrl =
                    pageUrl + "?contentDoc=KIHIPPHealthCoverSpanish";
                // For other browsers Download Document
                const isSafari =
                    navigator.userAgent.indexOf("Safari") != -1 &&
                    navigator.userAgent.indexOf("Chrome") == -1;
                const isMobile = navigator.userAgent.match(
                    /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
                );
                if (isSafari || !isMobile) {
                    window.open(this.healthCoverKIHipSpanish, "_blank");
                } else {
                    window.open(previewUrl, "_blank");
                }

                const downloadElement = document.createElement("a");
                downloadElement.href =
                    window.location.origin + this.healthCoverKIHipSpanish;
                downloadElement.setAttribute("download", "download");
                downloadElement.download = "KIHIPPHealthCover.pdf";

                downloadElement.click();
            }
        } catch (error) {
            console.error(
                "Error in openHealthCoverageFormSpanish" +
                    JSON.stringify(error.message)
            );
        }
    };
    /**
     * @function 		: openDirectDepositForm.
     * @description 	: method for download the pdf.
     * @param {e} event - Event checks which file to download.
     **/
    openDirectDepositForm = event => {
        if (event.keyCode === 13 || event.type === "click") {
            const pageUrl = "program-form-download";
            const previewUrl =
                pageUrl + "?contentDoc=KHIPPDirectDepositAuthorizationForm";
            // For other browsers Download Document
            const isSafari =
                navigator.userAgent.indexOf("Safari") != -1 &&
                navigator.userAgent.indexOf("Chrome") == -1;
            const isMobile = navigator.userAgent.match(
                /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
            );
            if (isSafari || !isMobile) {
                window.open(this.healthCoverAuthorization, "_blank");
            } else {
                window.open(previewUrl, "_blank");
            }

            const downloadElement = document.createElement("a");
            downloadElement.href =
                window.location.origin + this.healthCoverAuthorization;
            downloadElement.setAttribute("download", "download");
            downloadElement.download =
                "KHIPPDirectDepositAuthorizationForm.pdf";
            downloadElement.click();
        }
    };
    /**
     * @function 		: openDirectDepositFormSpanish.
     * @description 	: method for download the pdf.
     * @param {e} event - Event checks which file to download.
     **/
    openDirectDepositFormSpanish = event => {
        if (event.keyCode === 13 || event.type === "click") {
            const pageUrl = "program-form-download";
            const previewUrl =
                pageUrl +
                "?contentDoc=KHIPPDirectDepositAuthorizationFormSpanish";
            // For other browsers Download Document
            const isSafari =
                navigator.userAgent.indexOf("Safari") != -1 &&
                navigator.userAgent.indexOf("Chrome") == -1;
            const isMobile = navigator.userAgent.match(
                /(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i
            );
            if (isSafari || !isMobile) {
                window.open(this.healthCoverAuthorizationSpanish, "_blank");
            } else {
                window.open(previewUrl, "_blank");
            }

            const downloadElement = document.createElement("a");
            downloadElement.href =
                window.location.origin + this.healthCoverAuthorizationSpanish;
            downloadElement.setAttribute("download", "download");
            downloadElement.download =
                "KHIPPDirectDepositAuthorizationFormSpanish.pdf";
            downloadElement.click();
        }
    };

    /**
     * @function 		: handleChildCareSearch.
     * @description 	: method for handleChildCareSearch.
     **/
    handleChildCareSearch = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    pageName: "child-care-provider"
                },
                state: {
                    origin: "program-page"
                }
            });
        } catch (error) {
            console.error(
                "failed in handleChildCareSearch in sspProgramPage" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleChildCareSearch.
     * @description 	: method for handleChildCareSearch.
     **/
    handleDownloadCCProvider = () => {
        downloadCCProviderList().then(providerList =>{
            
            if (providerList === null|| providerList ===""){
                return;
            }
            try{
                let response = [{}];
                response = JSON.parse(providerList);
                const actualDataReceived = [];
                response.forEach(provider => {
                    const objProvider = {};
                    objProvider.LocationCountyDescription = provider.LocationCountyDescription;
                    objProvider.ProviderCLRNumber = provider.ProviderCLRNumber;
                    objProvider.ProviderName = provider.ProviderName;
                    objProvider.LocationAddress = provider.LocationAddress;
                    objProvider.PhoneNumber = provider.PhoneNumber;
                    objProvider.MailingAddress = provider.MailingAddress;
                    objProvider.ExpiryDate = provider.ExpiryDate;
                    objProvider.capacity = provider.capacity;
                    objProvider.AgeRangeSupported = provider.AgeRangeSupported;
                    objProvider.Transportation = provider.Transportation;
                    objProvider.NonTraditional = provider.NonTraditional;
                    objProvider.StarsRatingText = provider.StarsRatingText;
                    objProvider.ProviderType = provider.ProviderType;
                    objProvider.IsActiveCCAPChildren = provider.IsActiveCCAPChildren;
                    objProvider.IsServingSpecialNeeds = provider.IsServingSpecialNeeds;
                      actualDataReceived.push(objProvider);
                });
				this.JSONToCSVConverter(actualDataReceived, "Provider Details", true);
            } catch (ex) {
                console.error(ex);
            }
            
        });
    }
  
     /**
	   * @function 		: JSONToCSVConverter.
     * @description 	: method for converting the provider list JSON data to Excel.
     **/
  
	JSONToCSVConverter (JSONData, ReportTitle, ShowLabel) {
    
        const JSONExcelColumnMap = new Map([
			["LocationCountyDescription", "County"],
			["ProviderCLRNumber", "CLR#"],
			["ProviderName", "Name"],
			["LocationAddress", "Location Address"],
			["PhoneNumber", "Phone"],
			["MailingAddress", "Mailing Address"],
			["ExpiryDate", "Expiration Date"],
			["capacity", "Capacity"],
			["AgeRangeSupported", "Age Range Of Service"],
			["Transportation", "Transportation Service"],
			["NonTraditional", "Non Traditional"],
			["StarsRatingText", "Stars Rating"],
			["ProviderType", "Provider Type"],
			["IsActiveCCAPChildren", "Active CCAP Children"],
			["IsServingSpecialNeeds", "Serves Children with Special Needs"],
		]);
         
           const arrData =
               typeof JSONData != "object" ? JSON.parse(JSONData) : JSONData;
           let today = new Date();
           const dd = String(today.getDate()).padStart(2, "0");
           const mm = String(today.getMonth() + 1).padStart(2, "0");
           const yyyy = today.getFullYear();
   
           today = mm + "/" + dd + "/" + yyyy;
           let CSV = "";
           CSV += this.label.sspChildCareReport + today + "\r\n\n";
   
           if (ShowLabel) {
               let row = "";
           
               for (const key in arrData[0]) {
                   row += JSONExcelColumnMap.get(key) + ",";
               }
   
               row = row.slice(0, -1);
               CSV += row + "\r\n";
           }
           for (let i = 0; i < arrData.length; i++) {
               let row = "";
               for (const index in arrData[i]) {
                   row += '"' + arrData[i][index] + '",';
               }
               row.slice(0, row.length - 1);
               CSV += row + "\r\n";
           }
   
           if (CSV == "") {
               return;
           }
           const fileName = "ProviderResults";
           const uri = "data:text/csv/;charset=utf-8," + escape(CSV);
           const link = document.createElement("a");
           link.href = uri;
           link.style = "visibility:hidden";
           link.download = fileName + ".csv";
           document.body.appendChild(link);
           link.click();
           document.body.removeChild(link);
       }
	/**
	 * @function 		: navigateTimeLimitedCoverage.
	 * @description 	: method for navigate to Time Limited Coverage.
	 **/
	navigateTimeLimitedCoverage = () => {
		window.open(this.label.sspApplyForTimeLimitedCoverageLink,"_blank");
	}
}
