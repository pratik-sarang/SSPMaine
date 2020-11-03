import sspPrescreeningTool from "@salesforce/label/c.sspPrescreeningTool";
import sspHhDetails from "@salesforce/label/c.sspHhDetails";
import sspCompleteHhQuestion from "@salesforce/label/c.sspCompleteHhQuestion";
import sspNoOfPeopleInHh from "@salesforce/label/c.sspNoOfPeopleInHh";
import sspIsAnyoneChild from "@salesforce/label/c.sspIsAnyoneChild";
import sspIsAnyonePregnant from "@salesforce/label/c.sspIsAnyonePregnant";
import sspIsAnyoneMigrant from "@salesforce/label/c.sspIsAnyoneMigrant";
import sspIsAnyoneBlind from "@salesforce/label/c.sspIsAnyoneBlind";
import sspAnySSIncome from "@salesforce/label/c.sspAnySSIncome";
import sspIsReceivingLTC from "@salesforce/label/c.sspIsReceivingLTC";
import sspIsReceivingMedicare from "@salesforce/label/c.sspIsReceivingMedicare";
import sspIRDetails from "@salesforce/label/c.sspIRDetails";
import sspCompleteIrQuestion from "@salesforce/label/c.sspCompleteIrQuestion";
import sspGrossIncome from "@salesforce/label/c.sspGrossIncome";
import sspCheckingSavingIncome from "@salesforce/label/c.sspCheckingSavingIncome";
import sspExpenseDetails from "@salesforce/label/c.sspExpenseDetails";
import sspCompleteExpenseQuestion from "@salesforce/label/c.sspCompleteExpenseQuestion";
import sspCombinedShelterExpense from "@salesforce/label/c.sspCombinedShelterExpense";
import sspAnyheatingOrCoolingExpense from "@salesforce/label/c.sspAnyheatingOrCoolingExpense";
import sspMonthlyChildCareExpense from "@salesforce/label/c.sspMonthlyChildCareExpense";
import sspChildSupportExpense from "@salesforce/label/c.sspChildSupportExpense";
import sspRequiredValidator from "@salesforce/label/c.SSP_RequiredErrorMessage";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspEnterValidInput from "@salesforce/label/c.sspEnterValidInput";
import sspisHhBilledMoreThanOneExpense from "@salesforce/label/c.sspisHhBilledMoreThanOneExpense";
import sspPreSTool from "@salesforce/label/c.sspPreSTool";
import sspPsBasicEligText from "@salesforce/label/c.sspPsBasicEligText";
import sspMedicaidTitle from "@salesforce/label/c.sspMedicaidTitle";
import sspSnapTitle from "@salesforce/label/c.sspSnapTitle";
import sspCcTitle from "@salesforce/label/c.sspCcTitle";
import sspKTAPTitle from "@salesforce/label/c.sspKTAPTitle";
import sspKTAPFormattedText from "@salesforce/label/c.sspKTAPFormattedText";
import sspSnapFormattedText from "@salesforce/label/c.sspSnapFormattedText";
import sspCcFormattedText from "@salesforce/label/c.sspCcFormattedText";
import sspMedicaidFormattedText from "@salesforce/label/c.sspMedicaidFormattedText";
import sspPrescreeningResults from "@salesforce/label/c.sspPrescreeningResults";
import sspLearnMore from "@salesforce/label/c.sspLearnMore";
import sspStartPsTool from "@salesforce/label/c.sspStartPsTool";
import sspExit from "@salesforce/label/c.sspExit";
import sspBenefitsProgram from "@salesforce/label/c.sspBenefitsProgram";
import sspBenefitsProgramContent from "@salesforce/label/c.sspBenefitsProgramContent";
import sspPotentiallyEligible from "@salesforce/label/c.sspPotentiallyEligible";
import sspNeedMoreInfo from "@salesforce/label/c.sspNeedMoreInfo";
import sspApplyForBenefits from "@salesforce/label/c.sspApplyForBenefits";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspSubmit from "@salesforce/label/c.sspSubmit";
import sspHomePageApplyBenefit from "@salesforce/label/c.sspHomePageApplyBenefit";
import sspPsPotentialEligText from "@salesforce/label/c.sspPsPotentialEligText";
import ssPsInfoCompletionNotice from "@salesforce/label/c.ssPsInfoCompletionNotice";
import sspPsResultsInfoText from "@salesforce/label/c.sspPsResultsInfoText";
import sspPsResultEnrollmentAccessInfo from "@salesforce/label/c.sspPsResultEnrollmentAccessInfo";
import sspPsResultsIneligibleProgHelpInfo from "@salesforce/label/c.sspPsResultsIneligibleProgHelpInfo";
import sspPsToolInputRangeFlowMsg from "@salesforce/label/c.sspPsToolInputRangeFlowMsg";
import sspStartPsToolTitle from "@salesforce/label/c.sspStartPsToolTitle";
import sspLearnMoreTitle from "@salesforce/label/c.sspLearnMoreTitle";
import sspStartPsToolExitTitle from "@salesforce/label/c.sspStartPsToolExitTitle";
import sspNextTitle from "@salesforce/label/c.sspNextTitle";
import sspBackTitle from "@salesforce/label/c.sspBackTitle";
import sspSubmitTitle from "@salesforce/label/c.sspSubmitTitle";
import sspExitDashboardTitle from "@salesforce/label/c.sspExitDashboardTitle";
import sspApplyBenefitsTitle from "@salesforce/label/c.sspApplyBenefitsTitle";
import sspHHGreaterThanOneValidation from "@salesforce/label/c.sspHHGreaterThanOneValidation";
import ssPsResultsInfoCompletionNotice from "@salesforce/label/c.ssPsResultsInfoCompletionNotice";
import sspPsBrowsePlans from "@salesforce/label/c.sspPsBrowsePlans";
import sspPsResultMedicaidBtnUrl from "@salesforce/label/c.sspPsResultMedicaidBtnUrl";
import sspHHRangeValidationMessage from "@salesforce/label/c.sspHHRangeValidationMessage";



const labelPrescreening = {
   sspPrescreeningTool,
   sspHhDetails,
   sspCompleteHhQuestion,
   sspNoOfPeopleInHh,
   sspIsAnyoneChild,
   sspIsAnyonePregnant,
   sspIsAnyoneMigrant,
   sspIsAnyoneBlind,
   sspAnySSIncome,
   sspIsReceivingLTC,
   sspIsReceivingMedicare,
   sspIRDetails,
   sspCompleteIrQuestion,
   sspGrossIncome,
   sspCheckingSavingIncome,
   sspExpenseDetails,
   sspCompleteExpenseQuestion,
   sspCombinedShelterExpense,
   sspAnyheatingOrCoolingExpense,
   sspMonthlyChildCareExpense,
   sspChildSupportExpense,
   sspRequiredValidator,
   toastErrorText,
   sspEnterValidInput,
   sspisHhBilledMoreThanOneExpense,
   sspPreSTool,
   sspMedicaidTitle,
   sspSnapTitle,
   sspCcTitle,
   sspKTAPTitle,
   sspKTAPFormattedText,
   sspSnapFormattedText,
   sspCcFormattedText,
   sspMedicaidFormattedText,
   sspPrescreeningResults,
   sspLearnMore,
   sspStartPsTool,
   sspExit,
   sspBenefitsProgram,
   sspBenefitsProgramContent,
   sspPotentiallyEligible,
   sspNeedMoreInfo,
   sspApplyForBenefits,
   sspBack,
   sspNext,
   sspSubmit,
   sspHomePageApplyBenefit,
   sspPsBasicEligText,
   sspPsPotentialEligText,
   ssPsInfoCompletionNotice,
   sspPsResultsInfoText,
   sspPsResultEnrollmentAccessInfo,
   sspPsResultsIneligibleProgHelpInfo,
    sspPsToolInputRangeFlowMsg,
    sspStartPsToolTitle,
    sspLearnMoreTitle,
    sspStartPsToolExitTitle,
    sspNextTitle,
    sspBackTitle,
    sspSubmitTitle,
    sspExitDashboardTitle,
    sspApplyBenefitsTitle,
    sspHHGreaterThanOneValidation,
    ssPsResultsInfoCompletionNotice,
    sspPsBrowsePlans,
    sspPsResultMedicaidBtnUrl,
    sspHHRangeValidationMessage
};

export { labelPrescreening };
