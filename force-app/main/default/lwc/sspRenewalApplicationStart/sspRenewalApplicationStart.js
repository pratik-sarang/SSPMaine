/**
 * Component Name: sspRenewalApplicationStart.
 * Author: Yathansh Sharma, Chirag Garg.
 * Description: This screen the screen user will see before he starts the benefits renewal flow.
 * Date: 2/5/2020.
 */
import {  track } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_ProgramPageResources";
import sspIcon from "@salesforce/resourceUrl/SSP_Icons";

import getRenewalWrapperData from "@salesforce/apex/SSP_ApplicationController.getRenewalWrapperData";
import handleMedicaidRenewal from "@salesforce/apex/SSP_ApplicationController.handleMedicaidRenewal";

import constants from "c/sspConstants";
import sspUtility from "c/sspUtility"; 
 
import sspOneDot from "@salesforce/label/c.SSP_OneDot";
import sspTwoDot from "@salesforce/label/c.SSP_TwoDot";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspGetStartedOnRenewal from "@salesforce/label/c.SSP_GetStartedOnRenewal";
import sspCaseHash from "@salesforce/label/c.SSP_RenewalPageCase";
import sspCurrentBenefitEndDate from "@salesforce/label/c.SSP_CurrentBenefitEndDate";
import sspContentOfRenewalApplicationStart1 from "@salesforce/label/c.SSP_ContentOfRenewalApplicationStart1";
import sspContentOfRenewalApplicationStart2 from "@salesforce/label/c.SSP_ContentOfRenewalApplicationStart2";
import sspContentOfRenewalApplicationStart3 from "@salesforce/label/c.SSP_ContentOfRenwalApplicationStart3";
import sspContentOfRenewalApplicationStart4 from "@salesforce/label/c.SSP_ContentOfRenewalApplicationStart4";
import sspContentOfRenewalApplicationStart5 from "@salesforce/label/c.SSP_ContentOfRenewalApplicationStart5";
import sspGatherImportantDocuments from "@salesforce/label/c.SSP_GatherImportantDocuments";
import sspSocialSecurityNumber from "@salesforce/label/c.SSP_SocialSecurityNumber";
import sspIncomeInformation from "@salesforce/label/c.SSP_IncomeInformation";
import sspExpenseInformation from "@salesforce/label/c.SSP_ExpenseInformation";
import sspTaxReturns from "@salesforce/label/c.SSP_TaxReturns";
import sspThreeDot from "@salesforce/label/c.SSP_ThreeDot";
import sspFourDot from "@salesforce/label/c.SSP_FourDot";
import sspFillOutTheApplication from "@salesforce/label/c.SSP_FillOutTheApplication";
import sspProvideHouseholdInformation from "@salesforce/label/c.SSP_ProvideHouseholdInformation";
import sspProvideIndividualMemberInformation from "@salesforce/label/c.SSP_ProvideIndividualMemberInformation";
import sspGetResultsNextSteps from "@salesforce/label/c.SSP_GetResultsNextSteps";
import sspSetUpInterviews from "@salesforce/label/c.SSP_SetUpInterviews";
import sspSendAdditionalDocumentation from "@salesforce/label/c.SSP_SendAdditionalDocumentation";
import sspStartBenefitsAppNeedHelpTitle from "@salesforce/label/c.SSP_StartBenefitsAppNeedHelpTitle";
import sspStartBenefitsAppNeedHelpText from "@salesforce/label/c.SSP_StartBenefitsAppNeedHelpText";
import sspStartBenefitsAppContactAssisterTitle from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterTitle";
import sspStartBenefitsAppContactAssisterText from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterText";
import sspStartBenefitsAppContactAssisterListOne from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListOne";
import sspStartBenefitsAppContactAssisterListTwo from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListTwo";
import sspStartBenefitsAppContactAssisterListThree from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListThree";
import sspStartBenefitsAppCallTitle from "@salesforce/label/c.SSP_StartBenefitsAppCallTitle";
import sspStartBenefitsAppCallText from "@salesforce/label/c.SSP_StartBenefitsAppCallText";
import sspStartBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import sspStartBenefitsAppAlternateText from "@salesforce/label/c.SSP_StartBenefitsAppAlternateText";
import sspStartBenefitsAssisterAlternateText from "@salesforce/label/c.SSP_StartBenefitsAssisterAlternateText";
import sspStartBenefitsAppHealthAssistanceKIHIP from "@salesforce/label/c.SSP_StartBenefitsAppHealthAssistanceKIHIP";
import sspStartBenefitsAppCallAlternateText from "@salesforce/label/c.SSP_StartBenefitsAppCallAlternateText";
import sspStartBenefitsButtonAlternate from "@salesforce/label/c.SSP_StartBenefitsButtonAlternate";
import sspPencilIcon from "@salesforce/label/c.SSP_PencilIcon";
import sspFileIcon from "@salesforce/label/c.SSP_FileIcon";
import sspLaptopIcon from "@salesforce/label/c.SSP_LaptopIcon";
import sspContinue from "@salesforce/label/c.SSP_Continue";
import sspBack from "@salesforce/label/c.SSP_RenewalPageBackButton";
import sspRenewalDueDate from "@salesforce/label/c.SSP_RenewalDueDate";
import authorizedRepresentative from "@salesforce/label/c.SSP_AuthorizedRepresentative";
import assister from "@salesforce/label/c.SSP_Assister";

import { NavigationMixin } from "lightning/navigation";

export default class SspRenewalApplicationStart extends NavigationMixin(
  sspUtility
) {
  icFileIcon = sspIcons + constants.url.fileIcon;
  icPencilIcon = sspIcons + constants.url.pencilIcon;
  icLaptopIcon = sspIcons + constants.url.laptopIcon;
  icDesktopBackground =
    sspIcon + constants.url.renewalApplicationBackgroundImage;
  label = {
    sspExitButton,
    sspOneDot,
    sspTwoDot,
    sspGetStartedOnRenewal,
    sspCaseHash,
    sspCurrentBenefitEndDate,
    sspContentOfRenewalApplicationStart1,
    sspContentOfRenewalApplicationStart2,
    sspContentOfRenewalApplicationStart3,
    sspGatherImportantDocuments,
    sspSocialSecurityNumber,
    sspIncomeInformation,
    sspExpenseInformation,
    sspTaxReturns,
    sspThreeDot,
    sspFourDot,
    sspFillOutTheApplication,
    sspProvideHouseholdInformation,
    sspProvideIndividualMemberInformation,
    sspGetResultsNextSteps,
    sspSetUpInterviews,
    sspSendAdditionalDocumentation,
    sspStartBenefitsAppNeedHelpTitle,
    sspStartBenefitsAppNeedHelpText,
    sspStartBenefitsAppContactAssisterTitle,
    sspStartBenefitsAppContactAssisterText,
    sspStartBenefitsAppContactAssisterListOne,
    sspStartBenefitsAppContactAssisterListTwo,
    sspStartBenefitsAppContactAssisterListThree,
    sspStartBenefitsAppCallTitle,
    sspStartBenefitsAppCallText,
    sspStartBenefitsAppCallNumber,
    sspStartBenefitsAppAlternateText,
    sspStartBenefitsAssisterAlternateText,
    sspStartBenefitsAppHealthAssistanceKIHIP,
    sspStartBenefitsAppCallAlternateText,
    sspStartBenefitsButtonAlternate,
    sspPencilIcon,
    sspFileIcon,
    sspLaptopIcon,
    sspContentOfRenewalApplicationStart4,
    sspContentOfRenewalApplicationStart5,
    sspContinue,
        sspBack,
        authorizedRepresentative,
        assister
  };
  @track programs = "";
  @track dateString = "";
  @track authRepsList = [];
  @track assister = {};
  @track applicationNumber = "";
  @track applicationId = "";
  @track showSpinner = true;
  @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
  @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
  /**
   * @function : connectedCallback
   * @description	: Method to get the application Id from the URL parameters.
   */
  connectedCallback () {
    try {
      this.applicationId = new URL(window.location.href).searchParams.get(
        "applicationId"
      );
      getRenewalWrapperData()
      .then(result => {
        if (result) {  
          /**2.5 Security Role Matrix and Program Access. */
          if (!sspUtility.isUndefinedOrNull(result) && !sspUtility.isUndefinedOrNull(result.mapResponse) && !sspUtility.isUndefinedOrNull(result.mapResponse.isNotAccessible) && result.mapResponse.isNotAccessible) {
            this.isScreenAccessible = false;
            this.showAccessDeniedComponent = true;
            this.showSpinner = false;
          }
          /** */
          else {//2.5 Security Role Matrix and Program Access.
            this.isScreenAccessible = true;
            const responseData = JSON.parse(result.mapResponse.responseData);
            this.programs = responseData.programList;
            this.dateString = responseData.applicationDate;
            this.applicationNumber = responseData.applicationNumber;
            this.showSpinner = false;
          }//2.5 Security Role Matrix and Program Access.
        } 


      });
    } catch (error) {
      console.error(error);
    }
  }

  

  get noticeCardText () {
    return `${sspRenewalDueDate} <span class="ssp-fontFamily_popinBold"> ${this.dateString} </span>`;
  }

  /**
   * @function : maskAuthRepData
   * @param {object} inputData -Input list of record to apply masking to.
   * @description	: This method calls the masking methods.
   */
  maskAuthRepData = inputData => {
    try {
      if (!this.isUndefinedOrNull(inputData)) {
        return;
      }
      if (Array.isArray(inputData)) {
        const maskedResponse = [];
        inputData.forEach(record => {
          maskedResponse.push(this.applyMasking(record));
        });
        return maskedResponse;
      } else {
        return this.applyMasking(inputData);
      }
    } catch (error) {
      console.error(error);
    }
  };

  /**
   * @function : applyMasking
   * @param {object} record -Input data to apply masking on.
   * @description	: This method applies basic masking to the data before displaying on screen.
   */
  applyMasking = record => {
    try {
      if (!this.isUndefinedOrNull(record.Contact.Phone)) {
        if (record.Contact.Phone.match(/^\d{3}-\d{3}-\d{4}$/)) {
          record.Contact.maskedPhone = record.Contact.Phone;
        } else {
          const formatted = record.Contact.Phone.replace(/\D/g, "").match(
            /(\d{3})(\d{3})(\d{4})/
          );
          record.Contact.maskedPhone = `${formatted[1]}-${formatted[2]}-${
            formatted[3]
          }`;
        }
      }
      record.Contact.phoneHref = `tel:${record.Contact.Phone}`;
      record.Contact.maskedEmail = `mailto:${record.Contact.Email}`;
      return record;
    } catch (error) {
      console.error(error);
      return record;
    }
  };

  /**
   * @function : exitBenefitStartPage
   * @description	: Method to exit from get started on the benefits application page and Navigates to the Reps, Assisters, & Agents screen.
   */
  connectAssister = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          pageName: constants.communityPageNames.authRepsAssisters
        }
      });
    } catch (error) {
      console.error(error);
    }
  };

  handleBack = () => {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          pageName: "dashboard"
        }
      });
    } catch (error) {
      console.error(error);
    }
  };

  initSave = () => {
    this.showSpinner = true;
    handleMedicaidRenewal({ caseNo: this.applicationNumber })
      .then(result => {
        const parsedData = result.mapResponse;
        if (
          !sspUtility.isUndefinedOrNull(parsedData) &&
          parsedData.hasOwnProperty("ERROR")
        ) {
          console.error(
            "failed in updating programs" + JSON.stringify(parsedData.ERROR)
          );
        } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
          if (parsedData.applicationList) {
            const [application] = JSON.parse(parsedData.applicationList);
            this.navigateToAppSummary(
              null,
              application.Id,
              constants.applicationMode.RENEWAL
            );

            this.showSpinner = false;
          }
        }
      })
      .catch(error => {
        console.error(error);
      });
  };
}
