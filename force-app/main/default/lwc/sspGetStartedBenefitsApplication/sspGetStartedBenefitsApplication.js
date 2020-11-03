/**
 * Component Name: sspGetStartedBenefitsApplication.
 * Author: Sharon.
 * Description: This component creates a screen for Get Started on the Benefits Application.
 * Date: 23/02/2020.
 */
import { track, api} from "lwc";
import checkExistingApplication from "@salesforce/apex/SSP_DashboardController.checkHasExistingApplication";
import getMemberTypeFlag from "@salesforce/apex/SSP_DashboardController.getMemberTypeFlag";
import getOnlyDependentFlag from "@salesforce/apex/SSP_DashboardController.getOnlyDependentFlag";
import decryptionInfo from "@salesforce/apex/SSP_RoleSelection.decrypt";
import sspGetStartedBenefitsApplicationHeading from "@salesforce/label/c.SSP_GetStartedBenefitsApplicationHeading";
import sspLMSVideoUrl from "@salesforce/label/c.SSP_GetStartedLMSVideo";
import sspStartBenefitsAppYouApply from "@salesforce/label/c.SSP_StartBenefitsAppYouApply";
import sspStartBenefitsAppHealthAssistanceTitle from "@salesforce/label/c.SSP_StartBenefitsAppHealthAssistanceTitle";
import sspStartBenefitsAppHealthAssistanceText from "@salesforce/label/c.SSP_StartBenefitsAppHealthAssistanceText";
import sspStartBenefitsAppHealthInsuranceTitle from "@salesforce/label/c.SSP_StartBenefitsAppHealthInsuranceTitle";
import sspStartBenefitsAppHealthInsuranceText from "@salesforce/label/c.SSP_StartBenefitsAppHealthInsuranceText";
import sspStartBenefitsAppFoodAssistanceTitle from "@salesforce/label/c.SSP_StartBenefitsAppFoodAssistanceTitle";
import sspStartBenefitsAppFoodAssistanceText from "@salesforce/label/c.SSP_StartBenefitsAppFoodAssistanceText";
import sspStartBenefitsAppFinanceAssistanceTitle from "@salesforce/label/c.SSP_StartBenefitsAppFinanceAssistanceTitle";
import sspStartBenefitsAppFinanceAssistanceText from "@salesforce/label/c.SSP_StartBenefitsAppFinanceAssistanceText";
import sspStartBenefitsAppChildAssistanceTitle from "@salesforce/label/c.SSP_StartBenefitsAppChildAssistanceTitle";
import sspStartBenefitsAppChildAssistanceText from "@salesforce/label/c.SSP_StartBenefitsAppChildAssistanceText";
import sspStartBenefitsAppBeforePartOne from "@salesforce/label/c.SSP_StartBenefitsAppBeforePartOne";
import sspStartBenefitsAppBeforePartTwo from "@salesforce/label/c.SSP_StartBenefitsAppBeforePartTwo";
import sspStartBenefitsAppKnowVideo from "@salesforce/label/c.SSP_StartBenefitsAppKnowVideo";
import sspStartBenefitsAppGatherTitle from "@salesforce/label/c.SSP_StartBenefitsAppGatherTitle";
import sspStartBenefitsAppGatherTextOne from "@salesforce/label/c.SSP_StartBenefitsAppGatherTextOne";
import sspStartBenefitsAppGatherTextTwo from "@salesforce/label/c.SSP_StartBenefitsAppGatherTextTwo";
import sspStartBenefitsAppGatherTextThree from "@salesforce/label/c.SSP_StartBenefitsAppGatherTextThree";
import sspStartBenefitsAppGatherTextFour from "@salesforce/label/c.SSP_StartBenefitsAppGatherTextFour";
import sspStartBenefitsAppFillTitle from "@salesforce/label/c.SSP_StartBenefitsAppFillTitle";
import sspStartBenefitsAppFillTextOne from "@salesforce/label/c.SSP_StartBenefitsAppFillTextOne";
import sspStartBenefitsAppFillTextTwo from "@salesforce/label/c.SSP_StartBenefitsAppFillTextTwo";
import sspStartBenefitsAppGetResultTitle from "@salesforce/label/c.SSP_StartBenefitsAppGetResultTitle";
import sspStartBenefitsAppGetResultTextOne from "@salesforce/label/c.SSP_StartBenefitsAppGetResultTextOne";
import sspStartBenefitsAppGetResultTextTwo from "@salesforce/label/c.SSP_StartBenefitsAppGetResultTextTwo";
import sspStartBenefitsAppNeedHelpTitle from "@salesforce/label/c.SSP_StartBenefitsAppNeedHelpTitle";
import sspStartBenefitsAppNeedHelpText from "@salesforce/label/c.SSP_StartBenefitsAppNeedHelpText";
import sspStartBenefitsAppContactAssisterTitle from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterTitle";
import sspStartBenefitsAppContactAssisterText from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterText";
import sspStartBenefitsAppContactAssisterListOne from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListOne";
import sspStartBenefitsAppContactAssisterListTwo from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListTwo";
import sspStartBenefitsAppContactAssisterListThree from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListThree";
import sspStartBenefitsAppContactAssisterListFour from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListFour";
import sspStartBenefitsAppContactAssisterListFive from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListFive";
import sspStartBenefitsAppContactAssisterListSix from "@salesforce/label/c.SSP_StartBenefitsAppContactAssisterListSix";
import sspStartBenefitsAppCallTitle from "@salesforce/label/c.SSP_StartBenefitsAppCallTitle";
import sspStartBenefitsAppCallText from "@salesforce/label/c.SSP_StartBenefitsAppCallText";
import sspStartBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";
import sspResourceSelectionLearnMore from "@salesforce/label/c.SSP_LearnMoreLink";
import sspStartBenefitsAppAlternateText from "@salesforce/label/c.SSP_StartBenefitsAppAlternateText";
import sspStartBenefitsAssisterAlternateText from "@salesforce/label/c.SSP_StartBenefitsAssisterAlternateText";
import sspStartBenefitsAppHealthAssistanceKIHIP from "@salesforce/label/c.SSP_StartBenefitsAppHealthAssistanceKIHIP";
import sspStartBenefitsAppCallAlternateText from "@salesforce/label/c.SSP_StartBenefitsAppCallAlternateText";
import sspStartBenefitsButtonAlternate from "@salesforce/label/c.SSP_StartBenefitsButtonAlternate";
import sspStartBenefitsButton from "@salesforce/label/c.SSP_StartBenefitsButton";
import sspStartBenefitsExit from "@salesforce/label/c.SSP_StartBenefitsExit";
import sspStartBenefitsExitAlternate from "@salesforce/label/c.SSP_StartBenefitsExitAlternate";
import sspStartBenefitsAppCloseParenthesis from "@salesforce/label/c.SSP_StartBenefitsAppCloseParenthesis";
import sspStartBenefitsAppKCHIP from "@salesforce/label/c.SSP_StartBenefitsAppKCHIP";
import sspStartBenefitsAppSNAP from "@salesforce/label/c.SSP_StartBenefitsAppSNAP";
import sspStartBenefitsAppKTAP from "@salesforce/label/c.SSP_StartBenefitsAppKTAP";
import sspStartBenefitsAppCCAP from "@salesforce/label/c.SSP_StartBenefitsAppCCAP";
import sspStateSupplementation from "@salesforce/label/c.SSP_StateSupplementation";
import sspGetBenefitsLearnMoreHeading from "@salesforce/label/c.SSP_GetStartBenefitLearnMoreHeading";
import sspGetStartedBenefitsContent1 from "@salesforce/label/c.SSP_GetStartedBenefitsContent1";
import sspPresumptiveEligibility from "@salesforce/label/c.SSP_PresumptiveEligibility";
import sspCancerTreatmentProgram from "@salesforce/label/c.SSP_CancerTreatmentProgram";
import sspSearchPatient from "@salesforce/label/c.SSP_SearchPatient";
import sspSelectCompletedPlan from "@salesforce/label/c.SSP_SelectCompletedPlan";
import sspFillPatientsDetails from "@salesforce/label/c.SSP_FillPatientsDetails";
import sspPrintCard from "@salesforce/label/c.SSP_PrintCard";
import sspIcons from "@salesforce/resourceUrl/SSP_ProgramPageResources";
import sspIcon from "@salesforce/resourceUrl/SSP_Icons";
import constants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";
import sspUtility from "c/sspUtility";
import updateRoleAndPermissionForWaiver from "@salesforce/apex/SSP_NonCitizenDashboardService.updateRoleAndPermissionForWaiver";
import invokeFlowForPermissionSet from "@salesforce/apex/SSP_RoleSelection.invokeFlowForPermissionSet";
import redirectToIndividualDashboard from "@salesforce/apex/SSP_NonCitizenDashboardService.redirectToIndividualDashboard";
import sspGetStartedBannerText from "@salesforce/label/c.SSP_GetStartedBannerText";

export default class SspGetStartedBenefitsApplication extends NavigationMixin(
    sspUtility
) {
    @track isLearnMoreModal = false;
    @track showWhoAllApplyModal = false;
    @track modValue;
    @track reference = this;
    @track hasExistingApplication = true;
    @track isStateSupplementation = false;
    @track showStartButton = true;
  @track notDependent = true;
  @track showMWMABanner = false; //Added for defect# 397691.
    //Added by Shrikant - 4.1.2 Multiple Roles - CD2
    @track roleProgramAccess = {
        [constants.programs.MEDICAID]: {renderElement :true, sequence: 1 },
        [constants.programs.KHIPP]: { renderElement: true, sequence: 2 },
        [constants.programs.SNAP]: { renderElement: true, sequence: 3 },
        [constants.programs.KTAP]: { renderElement: true, sequence: 4 },
        [constants.programs.CCAP]: { renderElement: true, sequence: 5 },
        [constants.programs.SS]: { renderElement: false, sequence: 6 },
        [constants.programs.PE]: { renderElement: false, sequence: 7 },
        [constants.programs.BCCTP]: { renderElement: false, sequence: 8 }
    };
    @track showSpinner = true;

  @track isToShowIfAlreadyAssociatedText = false;
  @track allProgramExceptPAAndBCCPT = false;
  @track isToShowContactAssister = false;
  @track hasPAOrBCCPTProgram = false;
  @track isToShowNeedHelpBlock = false;
  @track tokenId;

    icFileIcon = sspIcons + constants.url.fileIcon;
    icPencilIcon = sspIcons + constants.url.pencilIcon;
    icLaptopIcon = sspIcons + constants.url.laptopIcon;
    bottomBannerSectionImage = sspIcon + constants.url.bannerBackgroundImage;
    individualId; //Added by Shrikant.
    label = {
        sspLMSVideoUrl,
        sspGetStartedBenefitsApplicationHeading,
        sspStartBenefitsAppYouApply,
        sspStartBenefitsAppHealthAssistanceTitle,
        sspStartBenefitsAppHealthAssistanceText,
        sspStartBenefitsAppHealthInsuranceTitle,
        sspStartBenefitsAppHealthInsuranceText,
        sspStartBenefitsAppFoodAssistanceTitle,
        sspStartBenefitsAppFoodAssistanceText,
        sspStartBenefitsAppFinanceAssistanceTitle,
        sspStartBenefitsAppFinanceAssistanceText,
        sspStartBenefitsAppChildAssistanceTitle,
        sspStartBenefitsAppChildAssistanceText,
        sspStartBenefitsAppKnowVideo,
        sspStartBenefitsAppBeforePartOne,
        sspStartBenefitsAppBeforePartTwo,
        sspStartBenefitsAppGatherTitle,
        sspStartBenefitsAppGatherTextOne,
        sspStartBenefitsAppGatherTextTwo,
        sspStartBenefitsAppGatherTextThree,
        sspStartBenefitsAppGatherTextFour,
        sspStartBenefitsAppFillTitle,
        sspStartBenefitsAppFillTextOne,
        sspStartBenefitsAppFillTextTwo,
        sspStartBenefitsAppGetResultTitle,
        sspStartBenefitsAppGetResultTextOne,
        sspStartBenefitsAppGetResultTextTwo,
        sspStartBenefitsAppNeedHelpTitle,
        sspStartBenefitsAppNeedHelpText,
        sspStartBenefitsAppContactAssisterTitle,
        sspStartBenefitsAppContactAssisterText,
        sspStartBenefitsAppContactAssisterListOne,
        sspStartBenefitsAppContactAssisterListTwo,
        sspStartBenefitsAppContactAssisterListThree,
    sspStartBenefitsAppContactAssisterListFour,
    sspStartBenefitsAppContactAssisterListFive,
    sspStartBenefitsAppContactAssisterListSix,
        sspStartBenefitsAppCallTitle,
        sspStartBenefitsAppCallText,
        sspStartBenefitsAppCallNumber,
        sspResourceSelectionLearnMore,
        sspStartBenefitsAppAlternateText,
        sspStartBenefitsAssisterAlternateText,
        sspStartBenefitsAppCallAlternateText,
        sspStartBenefitsButtonAlternate,
        sspStartBenefitsButton,
        sspStartBenefitsExit,
        sspStartBenefitsExitAlternate,
        sspStartBenefitsAppHealthAssistanceKIHIP,
        sspStartBenefitsAppCloseParenthesis,
        sspStartBenefitsAppKCHIP,
        sspStartBenefitsAppSNAP,
        sspStartBenefitsAppKTAP,
        sspStartBenefitsAppCCAP,
        sspStateSupplementation,
        sspGetBenefitsLearnMoreHeading,
        sspGetStartedBenefitsContent1,
        sspPresumptiveEligibility,
        sspCancerTreatmentProgram,
        sspSearchPatient,
        sspSelectCompletedPlan,
        sspFillPatientsDetails,
    sspPrintCard,
    sspGetStartedBannerText
    };
    /**
     * @function : getter and setters for modalContentValue
     * @description	: sets the learn more modal content.
     */
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
     * @function : connectedCallback
     * @description	: Set data on load.
     */
    connectedCallback () {
        try {
            //Added by Keshav to handle Agent Portal redirection
            const url = new URL(window.location.href);
            if (url.searchParams.get("requestInfo")) {
              const encryptedTextInfo = decodeURIComponent(
                url.searchParams.get("requestInfo")
              )
              decryptionInfo({
                encryptedText: encryptedTextInfo
              })
                .then(result => {
                })
                .catch({});
      } else if (url.searchParams.get("Token")) {
        this.tokenId = decodeURIComponent(url.searchParams.get("Token"));
        if (!sspUtility.isUndefinedOrNull(this.tokenId)) {
          
          updateRoleAndPermissionForWaiver({
            tokenId: this.tokenId
          })
            .then(result => {
              
              invokeFlowForPermissionSet({
                roleName: result
              }).then(resultSet => {
                window.location.replace(
                  location.protocol + "//" + location.host + location.pathname
                );
              });
              
              this.showSpinner = false;
            })
            .catch({});
        }
      }
      //Added by Shivam- To hide Start button for Special Access Scenario
            this.getApplicationDetails();
            this.checkAccess();
      this.setOnlyDependentFlag();
            this.showHelpContentData("SSP_APP_GetStartedBenefitsApplication");
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
  }
  /**
   * @function : redirectToIndividualDashboard
   * @description : used to get logged in user data Non Citizen.
   **/
  redirectToIndividualDashboard = () => {
    try {
      redirectToIndividualDashboard({
        tokenId: this.tokenId
      })
        .then(() => {
         
          this.showSpinner = false;
        })
        .catch({});
    } catch (error) {
      console.error("Error in redirectToIndividualDashboard", error);
    }
    return null;
  };
  /**
   * @function : programWrapperList
   * @description	: Method to get program Wrapper List.
   */
  get programWrapperList () {
    try {
      const programDetailList = [];
      Object.keys(this.roleProgramAccess).forEach(programCode => {
        programDetailList.push(this.roleProgramAccess[programCode]);
      });
      return programDetailList;
    } catch (error) {
      console.error("Error in programWrapperList", error);
    }
    return null;
  }

    /**
     * @function : checkAccess
     * @description	: Method to get Member Type and case Owner flags.
     */
    checkAccess = () => {
        try {
            getMemberTypeFlag().then(result => {
                if (result && result.mapResponse) {
                    const selectedRole = result.mapResponse.selectedRole; //#371950
          //Next if Block - Added for defect# 397691.
          if (constants.waiverRoles.includes(selectedRole)) {
            this.showMWMABanner = true;
          }
                    if (!sspUtility.isUndefinedOrNull(result.mapResponse.memberType)) {
                        if (result.mapResponse.memberType.includes(constants.headerConstants.TMEM)) {
                            this.showStartButton = false;
                        }
                        else {
                            this.showStartButton = true;
                        }
                    }
                    if (!sspUtility.isUndefinedOrNull(result.mapResponse.ownerType)) {
                        if ((result.mapResponse.ownerType.includes(constants.headerConstants.DAIL) && selectedRole != constants.headerConstants.DAIL_WORKER_API) || result.mapResponse.ownerType.includes(constants.headerConstants.CBW)) { //#371950
                            this.showStartButton = false;
                        }
                        else {
                            this.showStartButton = true;
                        }
                    }
                }
            })
        } catch (error) {
            console.error("failed in getRecordDetails in SspAuthRepsAssistAndAgents" + JSON.stringify(error));
        }
    }

     /**
     * @function : getApplicationDetails
     * @description	: Method to get Application Details.
     */
    getApplicationDetails () {
        try {
            checkExistingApplication().then(result => { 
                if (result) {
                    if (!result.mapResponse.hasOwnProperty("hasExpiringApplications")
                    ) {
                        this.hasExistingApplication = false;
                    }

                    /**Shrikant - Added as a part of CD 2 implementation- Multiple Roles - 4.1.2.*/
                    if (result.mapResponse.hasOwnProperty("availableProgramsSet") && result.mapResponse.hasOwnProperty("userDetails")
                    ) {
                        const userProfile = result.mapResponse.userDetails.profileName;
                        const availableProgramsSet = result.mapResponse.availableProgramsSet;
                        const roleProgramAccess = this.roleProgramAccess;
                        if (!sspUtility.isUndefinedOrNull(availableProgramsSet) && !sspUtility.isUndefinedOrNull(userProfile) && userProfile === constants.profileNames.nonCitizen){
                        let sequence = 1;
                            Object.keys(roleProgramAccess).forEach(programCode => {
                                if (availableProgramsSet.includes(programCode)){
                                    roleProgramAccess[programCode].renderElement = true;
                                    roleProgramAccess[programCode].sequence = sequence;
                                    sequence++;
                                }
                                else{
                                    roleProgramAccess[programCode].renderElement = false;
                                }
                                
                            });
                            // If (MA/SNAP/KTAP/KHIPP/CCAP/SS) program then show
                            if (availableProgramsSet.includes(constants.programs.MEDICAID) || availableProgramsSet.includes(constants.programs.SNAP) || 
                                availableProgramsSet.includes(constants.programs.KTAP) || availableProgramsSet.includes(constants.programs.KHIPP) ||
                                availableProgramsSet.includes(constants.programs.CCAP) || availableProgramsSet.includes(constants.programs.SS)) {
                                this.allProgramExceptPAAndBCCPT = true;
                                this.isToShowIfAlreadyAssociatedText = true;
                            }
                            // If has only (PE & BCCTP) program then show
                            if (availableProgramsSet.includes(constants.programs.PE) || availableProgramsSet.includes(constants.programs.BCCTP)) {
                                this.hasPAOrBCCPTProgram = true;
                            }
                            // If MA (MAGI/Non-MAGI) program then hide Contact Assister box.
                            if (availableProgramsSet.includes(constants.programs.MEDICAID)) {
                                this.isToShowContactAssister = true;
                            }
                            //To show the Need Help Block because of grey background
                            if (this.allProgramExceptPAAndBCCPT || this.isToShowContactAssister) {
                                this.isToShowNeedHelpBlock = true;
                            }
                        } else if (!sspUtility.isUndefinedOrNull(userProfile) && userProfile === constants.profileNames.citizen) {
                            this.allProgramExceptPAAndBCCPT = true;
                            this.isToShowContactAssister = true;
                            this.isToShowNeedHelpBlock = true;
                            this.isToShowIfAlreadyAssociatedText = false;
                        }
                        
                        this.roleProgramAccess = roleProgramAccess;
                    }
                    /** */

                    this.showSpinner = false;

                } 
            });
        } catch (error) {
            console.error(
                "failed in getRecordDetails in SspAuthRepsAssistAndAgents" +
                JSON.stringify(error)
            );
        }
    }
/**
   * @function : setOnlyDependentFlag
   * @description	: This methods is used to check whether Apply for Benefits button is to be showed for Dependent or not.
   */
  setOnlyDependentFlag = () => {
    try {
      getOnlyDependentFlag()
      .then(result => {
        if (result && result.mapResponse) {
          this.notDependent = !result.mapResponse.onlyDependent;
        }
      })
      .catch(error => {
        console.error(
            "Error in getOnlyDependentFlag in GetStartedBenefits" +
                JSON.stringify(error)
        );
    });
    } catch (error) {
      console.error(
        "failed in setOnlyDependentFlag in GetStartedBenefits" +
          JSON.stringify(error)
      );
    }
  };
        
    /**
     * @function : renderedCallback
     * @description	: Method called when DOM is loaded.
     */
    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
            );
            if (sectionReference) {
                // eslint-disable-next-line @lwc/lwc/no-inner-html
                sectionReference.innerHTML = this.modValue.HelpModal__c;

                /**Shrikant - Added as a part of CD 2 implementation- Multiple Roles - 4.1.2.*/
                const roleProgramAccess = this.roleProgramAccess;
                Object.keys(roleProgramAccess).forEach(programCode => {
                    const programContent = this.template.querySelector(
                    ".ssp-"+programCode);

                    if (!sspUtility.isUndefinedOrNull(roleProgramAccess) && !roleProgramAccess[programCode].renderElement) {
                        programContent.style.display = "none";
                    }

                });
                /**Shrikant - Added as a part of CD 2 implementation - 6.2 .*/
                // const ssProgramContent = this.template.querySelector(
                //     ".ssp-stateSupplementation"
                // );

                // if (!this.isStateSupplementation){
                //     ssProgramContent.style.display = "none";
                // }
                /** */
            }

        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function : openLearnMoreModal
     * @description	: Method to open learn more modal.
     */
    openLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = true;
        } catch (error) {
            console.error("Error in learn more modal", error);
        }
    };

    /**
     * @function : closeLearnMoreModal
     * @description	: Method to close learn more modal.
     */
    closeLearnMoreModal = () => {
        try {
            this.isLearnMoreModal = false;
        } catch (error) {
            console.error("Error in learn more modal", error);
        }
    };

    /**
     * @function : openWhoAllApplyModal
     * @description	: Method to open for who all apply modal.
     */

    openWhoAllApplyModal = () => {
        try {
            this.showWhoAllApplyModal = true;
        } catch (error) {
            console.error("Error in Modal For Who All Apply", error);
        }
    };

    /**
     * @function : closeWhoAllApplyModal
     * @description	: Method to close for who all apply modal.
     */
    closeWhoAllApplyModal = () => {
        try {
            this.showWhoAllApplyModal = false;
        } catch (error) {
            console.error("Error in Modal For Who All Apply", error);
        }
    };

    /**
     * @function : exitBenefitStartPage
     * @description	: Method to exit from get started on the benefits application page to home.
     */
    exitBenefitStartPage = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: constants.navigationUrl.dashBoard
                }
            });
        } catch (error) {
            console.error("Error in Modal For Who All Apply", error);
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
                    name: constants.navigationUrl.repsAssisters
                }
            });
        } catch (error) {
            console.error("Error in Modal For Who All Apply", error);
        }
    };
}
