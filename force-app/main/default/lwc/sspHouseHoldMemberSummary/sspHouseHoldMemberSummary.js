/**
 * Name : SspHouseHoldMemberSummary.
 * Description : Brief Description about Lightning Web Component.
 * Author : Saurabh Rathi.
 * Date : 11/12/2019.
 * MODIFICATION LOG:.
 * DEVELOPER DATE DESCRIPTION.
 * DeveloperName   MM/DD/YYYY   A Brief Description about the Change.
 **/
import { api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspCardImages from "@salesforce/resourceUrl/SSP_Icons";
import sspCardBackgroundImage from "@salesforce/resourceUrl/sspCardImages";

import startButton from "@salesforce/label/c.SSP_StartButton";
import editButton from "@salesforce/label/c.SSP_EditButton";
import NextButton from "@salesforce/label/c.SSP_NextButton";
import applicationSummary from "@salesforce/label/c.SSP_ApplicationSummary";
import householdMembers from "@salesforce/label/c.SSP_HouseholdMembers";
import addHouseholdMedicaidText from "@salesforce/label/c.SSP_AddHouseholdMedicaidText";
import headOfHousehold from "@salesforce/label/c.SSP_HeadOfHousehold";
import yearsOld from "@salesforce/label/c.SSP_YearsOld";
import addMember from "@salesforce/label/c.SSP_AddMember";
import deceased from "@salesforce/label/c.SSP_Deceased";
import backButton from "@salesforce/label/c.SSP_BackButton";
import saveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import explicitText from "@salesforce/label/c.SSP_ExplicitText";
import reviewRequired from "@salesforce/label/c.SSP_ReviewRequired";
import reviewRequiredText from "@salesforce/label/c.SSP_ReviewRequiredText";
import progressIcon from "@salesforce/label/c.SSP_ProgressIcon";
import deleteText from "@salesforce/label/c.SSP_Delete";
import removeMemberText from "@salesforce/label/c.SSP_RemoveMemberText";
import removeMember from "@salesforce/label/c.SSP_RemoveMember";
import cancel from "@salesforce/label/c.SSP_Cancel";
import programNotSelected from "@salesforce/label/c.SSP_ProgramNotSelected";
import remove from "@salesforce/label/c.SSP_Remove";
import chooseMember from "@salesforce/label/c.SSP_ChooseMember";
import reviewProgramNoteLineOne from "@salesforce/label/c.SSP_ReviewProgramNoteLineOne";
import reviewProgramNoteLineTwo from "@salesforce/label/c.SSP_ReviewProgramNoteLineTwo";
import reviewProgramNoteLineThree from "@salesforce/label/c.SSP_ReviewProgramNoteLineThree";
import addMemberTitleText from "@salesforce/label/c.SSP_AddMemberTitleText";
import entering from "@salesforce/label/c.SSP_Entering";
import summaryRecordValidator from "@salesforce/label/c.SSP_SummaryRecordValidator";
import viewApplicationSummary from "@salesforce/label/c.SSP_ViewApplicationSummary";
import addMemberLearnMoreTitleText from "@salesforce/label/c.SSP_AddMemberLearnMoreTitleText";
import removeAlt from "@salesforce/label/c.SSP_RemoveAlt";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import exitButton from "@salesforce/label/c.SSP_ExitButton";
import sspBackAltText from "@salesforce/label/c.SSP_BackAltText";
import sspNextAltText from "@salesforce/label/c.SSP_NextAltText";
import sspSaveAndExitAltText from "@salesforce/label/c.SSP_SaveAndExitAltText";
import householdMembersSummary from "@salesforce/label/c.SSP_HouseholdMembersSummary";


import sspPollingInterval from "@salesforce/label/c.SSP_IsDataProcessedPollingInterval"; //Added by Shrikant
import getHouseHoldDetails from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.getHouseholdDetails";
import deleteMember from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.deleteMember";
import fetchTransactionStatus from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.isDataProcessed"; //Added by Shrikant - CD2
import addIndividualIdToCache from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.storeHOHIndvIdToCache"; //Added by Shrikant - CD2
import fetchApplicationPrograms from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.fetchApplicationPrograms";
import removeUnassignedProgramsOnAPP from "@salesforce/apex/SSP_HouseholdMembersSummaryCtrl.removeUnassignedProgramsOnAPP";

import apConstants, { applicationMode } from "c/sspConstants";

import utility, { formatLabels } from "c/sspUtility";
import changeSummary from "@salesforce/label/c.SSP_ChangeSummary";
import applicationSummaryAlt from "@salesforce/label/c.SSP_ApplicationSummaryAlt";
import sspAddAllMembersOfYourHousehold from "@salesforce/label/c.SSP_AddAllMembersOfYourHousehold";
import ID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import RACRULE_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsRACSNAPMealsRuleTriggered__c";
import { updateRecord } from "lightning/uiRecordApi";

import renewalSummary from "@salesforce/label/c.SSP_RenewalSummary";
import sspStartButtonAlt from "@salesforce/label/c.SSP_StartButtonAlt";
import sspHeadOfHousehold from "@salesforce/label/c.SSP_HeadOfHousehold";
import sspView from "@salesforce/label/c.SSP_View"; //Added by Chirag
import sspYouHaveChangedInfo from "@salesforce/label/c.SSP_YouHaveChangedInfo";

const suffixArray = {
  JR: "JR.",
  SR: "SR.",
  TW: "II",
  TH: "III",
  FO: "IV",
  FV: "V",
  SI: "VI",
  SE: "VII"
};

export default class SspHouseHoldMemberSummary extends NavigationMixin(
  utility
) {
  titles = {
    [apConstants.mode.addRemoveMember]: changeSummary,
    [applicationMode.RAC]: changeSummary,
    [applicationMode.INTAKE]: applicationSummary,
    [applicationMode.RENEWAL]: renewalSummary
  };
  progressNotStartedIcon;
  checkedIconUrl = sspCardImages + apConstants.url.progressChecked;
  uncheckedIconUrl = sspCardImages + apConstants.url.progressNotStartedIcon;

  backgroundUrl = sspCardBackgroundImage + apConstants.url.backgroundImage;

  reviewRequiredText =
    reviewRequired + this.headOfHouseholdName + reviewRequiredText;
  screenId = "SSP_APP_HHMembersSummary";

  //Labels
  label = {
    startButton,
    editButton,
    NextButton,
    applicationSummary,
    householdMembers,
    addHouseholdMedicaidText,
    headOfHousehold,
    yearsOld,
    addMember,
    deceased,
    backButton,
    saveAndExit,
    learnMoreLink,
    explicitText,
    progressIcon,
    deleteText,
    removeMemberText,
    removeMember,
    cancel,
    programNotSelected,
    addMemberTitleText,
    addMemberLearnMoreTitleText,
    viewApplicationSummary,
    summaryRecordValidator,
    benefitsApplication,
    exitButton,
    changeSummary,
    applicationSummaryAlt,
    sspNextAltText,
    sspSaveAndExitAltText,
    sspBackAltText,
    sspAddAllMembersOfYourHousehold,
    sspStartButtonAlt,
    sspHeadOfHousehold,
    sspView
  };
  learnModal = householdMembersSummary;
  isNonCitizenVerificationFlag = true; // Added as part of Defect - 378463

  //api variables
  @api isReviewRequired = false;

  //track variables
  @track showErrorModal = false; //Added by Shrikant CD2
  @track errorMsg; //Added by Shrikant CD2
  @track userDetails = {}; //Added by Shrikant, to get profile and role of loggedIn user - CD2
  @track appIdValue;
  @track headDetailsComplete = false;
  @track appPrograms;
  @track editMemberData = false;
  @track memberData = [];
  @track storeMemberData = [];
  @track headOfHouseholdData = {};
  @track toBeEditData = null;
  @track closeHouseHoldSummary = false;
  @track houseHoldResult;
  @track showRemoveMemberModal = false;
  @track headOfHouseholdName;
  @track isProgramInValid = false;
  @track removeProgramText;
  @track chooseMemberText;
  @track showLearnMore = false;
  @track showErrorToast = false;
  @track saveExit = false;
  @track reviewProgramNote;
  @track bShowMedicaidText_ = false;
  @track UNAssignedPrograms;
  @track householdLevelPrograms;
  @track applicationBlocked;
  @track showBlockModal;
  @track showSpinner = false;
  @track householdDataLoaded = false;
  @track addRemoveMember = false;
  @track reportChangeMode = false;
  @track reference = this;
  @track applicationPrograms;
  @track applicationProgramCodes;
  @track medicaidType;
  // @track ScreenStatusObject = {};
  @track modValue;
  @track showHOHStart = false;
  @track mapforhpinatinality;
  @track mapforasnatinality;
  @track isAddAllMembers = false;
  @track showExitButton = false;
  
  @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix and Program Access.
  @track disableMemberDetailsOption = true; //CD2 2.5 Security Role Matrix and Program Access.
  @track canDeleteMembers = true; //CD2 2.5 Security Role Matrix and Program Access.
  @track isDetailsReadOnly = false; //CD2 2.5 Security Role Matrix and Program Access.
  @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
  @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	
  @track isToDisableAddMember = false; // Added as part of Defect - 378463
  @track isStartEditClick = false; // Added as part of Defect - 380582
  @track showBanner;
  @track bannerText ;
  @track showReviewRequiredBanner= false;
  @track reviewRequiredOnLoad=false;
  @api
  get sAppId () {
    return this.appIdValue;
  }
  set sAppId (value) {
    if (value) {
      this.appIdValue = value;
      this.fetchTransactionStatusFromServer({
        applicationId: value,
        mode: this.mode
      }); //Added by Shrikant - CD2
    }
  }

  get isHeadDetailsComplete () {
    if ((this.disableMemberDetailsOption || this.isDetailsReadOnly) && (utility.isUndefinedOrNull(this.memberData) || this.memberData.length <= 1)) {
        return false;
    }
    return this.headDetailsComplete;
}

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

  //2.5 Security Role Matrix and Program Access.
  get showContents () {
    return this.isScreenAccessible || (!this.isScreenAccessible && !this.addRemoveMember);
  }

  //2.5 Security Role Matrix and Program Access.
  get disableAddMember () {
    return this.disableMemberDetailsOption || this.isDetailsReadOnly;
  }

  //2.5 Security Role Matrix and Program Access.
  get showAccessDeniedForAddRemoveMember () {
    return this.showAccessDeniedComponent && this.addRemoveMember;
  }

  //2.5 Security Role Matrix and Program Access.
  get showAccessDenied () {
    return this.showAccessDeniedComponent && !this.addRemoveMember;
  }

  //#379955
  get saveAndExitLabel () {
    return this.isReadOnlyUser ? exitButton : saveAndExit;
  }

  /**
   * @function : wiredPrograms
   * @description : This method is used to fetch programs and medicaid type.
   */
  @wire(fetchApplicationPrograms, { applicationId: "$appIdValue" })
  wiredPrograms ({ error, data }) {
    try {
      if (data) {
        if (data.mapResponse && data.bIsSuccess) {
          this.applicationPrograms = data.mapResponse.programs;
          this.medicaidType = data.mapResponse.medicaidType;

          /**CD2 2.5	Security Role Matrix and Program Access. */
          const appPrograms = !utility.isUndefinedOrNull(data.mapResponse.programs) && data.mapResponse.programs != "" ? (data.mapResponse.programs).split(";") : [];
          const { applicablePrograms, securityMatrixSummary,securityMatrixDetails: securityMatrixDetail, securityMatrixRACHHComposition} = data.mapResponse;

          if (this.addRemoveMember) {
            this.isScreenAccessible = (!utility.isUndefinedOrNull(securityMatrixRACHHComposition) && securityMatrixRACHHComposition.screenPermission == apConstants.permission.notAccessible) ? false : true;
            this.showAccessDeniedComponent = !this.isScreenAccessible;
          }

          if ((this.addRemoveMember && this.isScreenAccessible) || !this.addRemoveMember) {
            this.applicationPrograms = appPrograms.filter(program => (applicablePrograms != null && applicablePrograms != undefined && applicablePrograms.includes(program)));
            this.disableMemberDetailsOption = (!utility.isUndefinedOrNull(securityMatrixDetail) && !utility.isUndefinedOrNull(securityMatrixDetail.screenPermission) && securityMatrixDetail.screenPermission === apConstants.permission.notAccessible) ? true : false;
            this.isReadOnlyUser = (!utility.isUndefinedOrNull(securityMatrixSummary) && !utility.isUndefinedOrNull(securityMatrixSummary.screenPermission) && securityMatrixSummary.screenPermission === apConstants.permission.readOnly);
            this.isDetailsReadOnly = (!utility.isUndefinedOrNull(securityMatrixDetail) && !utility.isUndefinedOrNull(securityMatrixDetail.screenPermission) && securityMatrixDetail.screenPermission === apConstants.permission.readOnly) ? true : false;// || securityMatrixDetail.screenPermission === apConstants.permission.readOnly
            this.canDeleteMembers = (!utility.isUndefinedOrNull(securityMatrixSummary) && !utility.isUndefinedOrNull(securityMatrixSummary.canDelete) && !securityMatrixSummary.canDelete) ? false : true;
            this.isScreenAccessible = (!utility.isUndefinedOrNull(securityMatrixSummary) && securityMatrixSummary.screenPermission == apConstants.permission.notAccessible) ? false : true;
            this.showAccessDeniedComponent = !this.isScreenAccessible;
          }
        }
      } else if (error) {
        console.error("Error in wirePrograms", error);
      }
    } catch (error) {
      console.error("Error in wirePrograms-- catch", error);
    }
  }

  /**
   * @function : showHOHAge
   * @description : To determine whether to show HOH age. Added by Shrikant - CD2 .
   */
  get showHOHAge () {
    return (
      !utility.isUndefinedOrNull(this.headOfHouseholdData) &&
      ((!utility.isUndefinedOrNull(
        this.headOfHouseholdData.sFirstName
      ) &&
        this.headOfHouseholdData.sFirstName != "") ||
        (!utility.isUndefinedOrNull(
          this.headOfHouseholdData.sMiddleName
        ) &&
          this.headOfHouseholdData.sMiddleName != "") ||
        (!utility.isUndefinedOrNull(
          this.headOfHouseholdData.sLastName
        ) &&
          this.headOfHouseholdData.sLastName != ""))
    );
  }

  /**
   * @function : fetchTransactionStatusFromServer
   * @description	: Fetch if data related to current screen is loaded to SF objects. Added by Shrikant - CD2 .
   * @param {object} functionArguments - Parameters to Apex method.
   */
  fetchTransactionStatusFromServer (functionArguments) {
    try {
      fetchTransactionStatus(functionArguments)
        .then(response => {
          const result = response.mapResponse;
          if (result.hasOwnProperty("ERROR")) {
            console.error(
              "Error in SspHouseHoldMemberSummary.fetchTransactionStatusFromServer" +
              result.ERROR
            );
          } else if (result.hasOwnProperty("status")) {
            const status = result.status;
            if (
              (status === "NULL" && this.mode === apConstants.applicationMode.INTAKE)||
              status === apConstants.pollingStatus_RAC.success
            ) {
              this.showSpinner = false;
              this.getDetails();
            } else if (
              status === apConstants.pollingStatus_RAC.failure
            ) {
              const message = result.message;
              this.showErrorModal = true;
              this.errorMsg = message;
              this.showSpinner = false;
            } else if (
              status === apConstants.pollingStatus_RAC.pending || status === "NULL"
            ) {
              const pollingInterval = parseInt(
                sspPollingInterval
              );
              // eslint-disable-next-line @lwc/lwc/no-async-operation
              setTimeout(() => {
                this.fetchTransactionStatusFromServer(
                  functionArguments
                );
              }, pollingInterval);
            }
          }
        })
        .catch(error => {
          console.error(
            "failed in SspHouseHoldMemberSummary.fetchTransactionStatusFromServer " +
            error
          );
        });
    } catch (error) {
      console.error(
        "Error in SspHouseHoldMemberSummary.fetchApplicationDetailsFromServer" +
        error
      );
    }
  }

  /**
   * @function : checkReviewRequiredOnNewMember
   * @description : Functionality to perform when save/cancel is clicked.
   * @param {responseResults} responseResults - Response result.
   */
  checkReviewRequiredOnNewMember = responseResults => {
    const householdMembersResponse = responseResults;
    let headOfHouseholdDetails;
    let householdMemberDetails;
    if (
      householdMembersResponse.mapResponse != null &&
      householdMembersResponse.mapResponse.headOfHousehold != null &&
      householdMembersResponse.mapResponse.Result != null
    ) {
      headOfHouseholdDetails = JSON.parse(
        householdMembersResponse.mapResponse.headOfHousehold
      );
      householdMemberDetails = JSON.parse(
        householdMembersResponse.mapResponse.Result
      );
      const revRules = [];
      let hasNewMember = false;
      let householdSummaryAlreadyCompleted = false;
      let newMemberAppIndividualId;
      householdMemberDetails.forEach(hMemberResponse => {
        if (
          hMemberResponse.MemberStatus != null &&
          hMemberResponse.MemberStatus === "New" &&
          !hasNewMember &&
          !hMemberResponse.bIsRACMealsRuleTriggered
        ) {
          const applicationSectionStatus = JSON.parse(
            hMemberResponse.appSectionStatus
          );
          hasNewMember = true;
          let key = this.mode;
          if (this.reportChangeMode) {
            key = "ModifyExistingData";
          } else if (this.addRemoveMember) {
            key = "AddRemoveMember";
          }
          newMemberAppIndividualId = hMemberResponse.sAppIndividualId;
          householdSummaryAlreadyCompleted =
            applicationSectionStatus != null &&
              applicationSectionStatus[key] &&
              applicationSectionStatus[key]
                .SSP_APP_HHMembersSummary != null
              ? true
              : false;
        }
      });
      if (householdMembersResponse.mapResponse.sAPPProgramsCodes &&
        householdMembersResponse.mapResponse.sAPPProgramsCodes.includes("SN") &&
        ((householdSummaryAlreadyCompleted && hasNewMember) ||
          (this.addRemoveMember && hasNewMember))
      ) {
        revRules.push(
          "snapHouseholdMealsRule," +
          true +
          "," +
          headOfHouseholdDetails.sRecordId
        );

        const fields = {};
        fields[ID_FIELD.fieldApiName] = newMemberAppIndividualId;
        fields[RACRULE_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        updateRecord(recordInput)
          .then(() => true)
          .catch(error => {
            console.error(error);
          });
      }
      if (
        headOfHouseholdDetails.everyoneInHouseholdHaveSameAddress ===
        true
      ) {
        const newMembers = householdMemberDetails.filter(
          member => member.MemberStatus === "New"
        );
        for (const member of newMembers) {
          if (
            !(
              member.physicalAddressLine1 ||
              member.mailingAddressLine1
            )
          ) {
            revRules.push(
              [
                // eslint-disable-next-line spellcheck/spell-checker
                "HOHaddressOnNewMember",
                true,
                headOfHouseholdDetails.sRecordId
              ].join(",")
            );
          }
        }
      }
      this.reviewRequiredList = revRules;
      this.validateReviewRequiredRules(
        this.sAppId,
        headOfHouseholdDetails.sRecordId,
        ["SSP_APP_HHMemberDetails"],
        this.reviewRequiredList,
        this.mode
      );
    }
  };

  /**
   * @function : connectedCallback
   * @description : This method is called when html is attached to the component.
   */
  async connectedCallback () {
    try {
      this.showSpinner = true;
      const sPageURL = decodeURIComponent(
        window.location.search.substring(1)
      );
      const sURLVariables = sPageURL.split("&");
      let applicationId = null;
      if (sURLVariables != null) {
        let isIdVerified = false;
        for (let i = 0; i < sURLVariables.length; i++) {
          const sParam = sURLVariables[i].split("=");
          if (sParam[0] === "applicationId") {
            applicationId =
              sParam[1] === undefined ? "Not found" : sParam[1];
          }
          if (sParam[0] === "mode") {
            this.mode = sParam[1];
          }
          if (
            sParam[0] === "mode" &&
            sParam[1] === apConstants.mode.addRemoveMember
          ) {
            this.addRemoveMember = true;
            this.mode = sParam[1];
          } else if (
            sParam[0] === "mode" &&
            sParam[1] === applicationMode.RAC
          ) {
            this.reportChangeMode = true;
            this.mode = sParam[1];
          }
          if (sParam[0] === "RIDP") {
            isIdVerified = true;
                        this.sAppId = applicationId;
                        this.getDetails();
                        
                    }
                     if (sParam[0] === "identityDocUpload") {
            isIdVerified = true;
                         this.sAppId = applicationId;
                         this.getDetails();
                     }       
          if (sParam[0] === "mode" && sParam[1] !== "Intake") {
            this.showExitButton = true;
          }          
        }
      }
      this.sAppId = applicationId;
      this.showHelpContentData("SSP_APP_HouseholdMemberSummary");
      const fields = {
        Id: applicationId
      };
      if (this.addRemoveMember) {
        fields[apConstants.householdSummary.ChangeSummaryMode] = "AddRemoveMember";
        await updateRecord({ fields });
      }
      else if (this.reportChangeMode) {
        fields[apConstants.householdSummary.ChangeSummaryMode] = "ModifyExistingData";
        await updateRecord({ fields });
      }
    } catch (error) {
      console.error("Error in connectedCallback", error);
    }
  }

  /**
   * @function : headMemberDataAdd
   * @description : This method is used to edit details of head of house hold.
   */
  headMemberDataAdd () {
    try {
      this.toBeEditData = this.headOfHouseholdData;
      this.toBeEditData.addRemoveMember = this.addRemoveMember;
      this.editMemberData = true;
      this.isStartEditClick = true; // Added as part of Defect - 380582
    } catch (error) {
      console.error("Error in headMemberDataAdd", error);
    }
  }

  //Start - Added as part of Defect - 380582
   /**
   * @function : headMemberDataAddedMethod
   * @description : This method is used to edit details of head of house hold.
   */
  headMemberDataAddedMethod () {
    try {
      this.toBeEditData = this.headOfHouseholdData;
      this.toBeEditData.addRemoveMember = this.addRemoveMember;
      this.editMemberData = true;
    } catch (error) {
      console.error("Error in headMemberDataAddedMethod", error);
    }
  }
  //End - Added as part of Defect - 380582

  /**
   * @function : memberDataEdit
   * @description : This method is used to edit details of members of house hold.
   * @param {*} event -  This parameter provides the updated value.
   */
  memberDataEdit (event) {
    try {
      const memberToEdit = this.memberData.filter(
        item => item.sRecordId === event.detail.sRecordId
      );

      this.toBeEditData = memberToEdit.length > 0 ? memberToEdit[0] : null;
      this.toBeEditData.addRemoveMember =
        this.addRemoveMember && this.toBeEditData.MemberStatus === null;
      this.editMemberData = true;
    } catch (error) {
      console.error("Error in memberDataEdit", error);
    }
  }

  /**
   * @function : addMember
   * @description : This method is used to add new member details.
   */
  addMember () {
    try {
      this.toBeEditData = null;
      this.editMemberData = true;
      this.showReviewRequiredBanner= false;
      this.showBanner= false;
    } catch (error) {
      console.error("Error in addMember", error);
    }
  }

  /**
   * @function : handleCancelAddMember
   * @description : This method is used to cancel the adding of new member and show summary screen again.
   */
  handleCancelAddMember () {
    try {
      this.editMemberData = false;
      if(this.reviewRequiredOnLoad){
        this.showBanner = true;
        this.showReviewRequiredBanner=true;
      }
    } catch (error) {
      console.error("Error in handleCancelAddMember", error);
    }
  }

  /**
   * @function : handleMemberAdded
   * @description : This method is called out after adding the new member and show summary screen again.
   * @param {*} event -  This parameter provides the updated value.
   */
  handleMemberAdded (event) {
    try {
      this.showSpinner = true;
      this.fetchTransactionStatusFromServer({
        applicationId: this.sAppId,
        mode: this.mode
      }); //Added by Shrikant - CD2
      this.editMemberData = false;
      const individualId = event.detail;

      // to change Start Button to Edit once successful Save from Member Details.
      if (this.memberData) {
        this.memberData = this.memberData.map(item => {
          if (item.sMCIIndividualId === individualId) {
            item.showEdit = true;
          }

          return item;
        });
      }
    } catch (error) {
      console.error("Error in handleMemberAdded", error);
    }
  }

  /**
   * @function : pageTitle
   * @description : This getter is used to dynamically add label to screen based on mode.
   */
  get pageTitle () {
    return this.titles[this.mode];
  }

  get pageTitleAlt () {
    const searchMask = applicationSummary;
    const regEx = new RegExp(searchMask, "i");
    return applicationSummaryAlt.replace(regEx, this.titles[this.mode]);
  }

  get withoutRemoveButtonCheck () {
    return this.memberData.bSSNVerified;
  }
  set programNote (value) {
    this.showProgramNote = value;
  }

  getDetails () {
    try {
      //alert('inside getDetais');
      this.showSpinner = true;
      this.applicationReady().then(resp => {
        //alert('inside this.applicationReady callout');
        const data = resp;
        const error = resp.error;
        this.showSpinner = false;
        //alert('data = '+JSON.stringify(data));
        if (data) {
          this.houseHoldResult = data;
          this.householdDataLoaded = true;

          alert('before json parse of this.houseHoldResult.mapResponse '+JSON.stringify(this.houseHoldResult.mapResponse) );
          alert('before json parse of this.houseHoldResult.mapResponse.headOfHousehold '+this.houseHoldResult.mapResponse.headOfHousehold );
          this.headOfHouseholdData = JSON.parse(
            this.houseHoldResult.mapResponse.headOfHousehold
          );      
          alert('after');  
          const url = new URL(window.location.href);
          if (this.mode === apConstants.applicationMode.RENEWAL) {
            this.headOfHouseholdData.isHOHDetailsCompleted = true;
            this.headOfHouseholdData.showEdit = true;
          }
          this.headOfHouseholdData.viewButtonAltText = `${this.label.sspView} ${this.headOfHouseholdData.buttonAltTExt}`;
          this.headOfHouseholdData.buttonAltTExt = this
            .headOfHouseholdData.isHOHDetailsCompleted
            ? `${this.label.editButton} ${this.headOfHouseholdData.buttonAltTExt}`
            : ( this.headOfHouseholdData.buttonAltTExt !== "details for null null" ? `${this.label.startButton} ${entering} ${this.headOfHouseholdData.buttonAltTExt}` :
              `${formatLabels(sspStartButtonAlt, [sspHeadOfHousehold])}`);

          this.memberData = JSON.parse(this.houseHoldResult.mapResponse.Result);
          if (this.memberData) {
              this.storeMemberData = this.memberData;
          }

          //Added by Shrikant, to get profile and role of loggedIn user - CD2
          this.userDetails = this.houseHoldResult.mapResponse.userDetails;

          this.headOfHouseholdData.sSufficeLabel = this.headOfHouseholdData
            .sSufficeCode
            ? suffixArray[this.headOfHouseholdData.sSufficeCode]
            : "";
          if (null !== this.headOfHouseholdData.sHOHMCIId) {
            this.userDetails.sHOHId = this.headOfHouseholdData.sHOHMCIId;
          }

          if (null !== this.headOfHouseholdData.sApplicationNumber) {
            this.userDetails.sApplicationNumber = this.headOfHouseholdData.sApplicationNumber;
          }
          if (null !== this.headOfHouseholdData.sCaseNumber) {
            this.userDetails.caseNumber = this.headOfHouseholdData.sCaseNumber;
          }

          if (this.headOfHouseholdData.showEdit) {
            this.headDetailsComplete = true;
          }
          if (this.memberData) {
            this.memberData = this.memberData.map(item => {
              if (this.mode === apConstants.applicationMode.RENEWAL) {
                item.showEdit = true;
                item.isFullMatch = false;
              }
              item.viewButtonAltText = `${this.label.sspView} ${item.buttonAltTExt}`
              item.buttonAltTExt = item.showEdit
                ? `${this.label.editButton} ${item.buttonAltTExt}`
                : `${this.label.startButton} ${entering} ${item.buttonAltTExt}`;
              item.removeAltText = formatLabels(removeAlt, [
                `${item.sFirstName} ${item.sLastName}`
              ]);
              item.sSufficeLabel = item.sSufficeCode
                ? suffixArray[item.sSufficeCode]
                : "";
              if (this.addRemoveMember) {
                item.isFullMatch = false;
              }
              return item;
            });
          }


          if (this.houseHoldResult.mapResponse.mapforasnatinality != null) {


            this.mapforasnatinality = this.houseHoldResult.mapResponse.mapforasnatinality;
          }



          if (this.houseHoldResult.mapResponse.mapforhpinatinality != null) {
            this.mapforhpinatinality = this.houseHoldResult.mapResponse.mapforhpinatinality;
          }

          this.UNAssignedPrograms = JSON.parse(
            // eslint-disable-next-line spellcheck/spell-checker
            this.houseHoldResult.mapResponse.unassignedprograms
          );
          this.appPrograms = this.houseHoldResult.mapResponse.sAPPPrograms;
          if (this.appPrograms === "") {
            this[NavigationMixin.Navigate]({
              type: "comm__namedPage",
              attributes: {
                name: apConstants.navigationUrl.programSelection
              },
              state: {
                applicationId: this.sAppId,
                mode: this.mode
              }
            });
          }
          // if (this.appPrograms.includes("Medicaid")) {
          //     this.bShowMedicaidText_ = true;
          // }

          this.error = undefined;
          if (url.searchParams.get("RIDP") &&
            (this.headOfHouseholdData.matchType === undefined || this.headOfHouseholdData.matchType === null)) {
            this.headMemberDataAddedMethod(); // Added as part of Defect - 380582
            this.editMemberData = true;
          }
          if (url.searchParams.get("identityDocUpload") &&
            (this.headOfHouseholdData.matchType === undefined || this.headOfHouseholdData.matchType === null)) {
            this.headMemberDataAddedMethod(); // Added as part of Defect - 380582
            this.editMemberData = true;
          }
          //Start - Added as part of Defect - 378463
          if (this.mode === apConstants.applicationMode.INTAKE) {
              this.checkNonCitizenVerificationFlag();
          }
          //End - Added as part of Defect - 378463
        } else if (error) {
          this.error = error;
          this.headOfHouseholdData = undefined;
          this.memberData = undefined;
        }
      });
    } catch (error) {
      alert('inside catch block');
      console.error("Error in getDetails", error);
    }
  }

  applicationReady = () => new Promise(this.pollApplication);
  pollApplication = (resolve, reject) => {
    alert('inside pollApplication ');
    alert('this.sAppId = '+ this.sAppId);
    alert('this.addRemoveMember='+this.addRemoveMember);
    alert('this.reportChangeMode='+this.reportChangeMode);
    alert('this.mode='+this.mode);
    getHouseHoldDetails({
      sApplicationId: this.sAppId,
      sMode: this.addRemoveMember || this.reportChangeMode,
      mode: this.mode //#385177 fix.
    }).then(response => {
      if (response.bIsSuccess) {
        this.checkReviewRequiredOnNewMember(response);
        const householdMemberDetails = JSON.parse(
          response.mapResponse.Result
        );
        if(householdMemberDetails){
          const applicationSectionStatus = JSON.parse(
            householdMemberDetails[0].appSectionStatus
          );
          this.showReviewRequiredBanner =
          applicationSectionStatus != null &&
            applicationSectionStatus[this.mode] &&
            applicationSectionStatus[this.mode].SSP_APP_HHMembersSummary != null &&  applicationSectionStatus[this.mode].SSP_APP_HHMembersSummary===apConstants.reviewRequiredStatus
            ? true
            : false;
            
            if(this.showReviewRequiredBanner){
              this.reviewRequiredOnLoad= true;
              this.showBanner = true;
              this.bannerText = sspYouHaveChangedInfo;
            }
        }

        if (response.mapResponse && response.mapResponse.applicationComplete) {
          resolve(response);
          this.applicationProgramCodes = response.mapResponse.sAPPProgramsCodes;
          if (
            ["KT", "SN", "KP", "SS", "CC"].some(item =>
              this.applicationProgramCodes.includes(item)
            ) &&
            !this.applicationProgramCodes.includes("MA")
          ) {
            this.isAddAllMembers = true;
          }

          if ((
            ["KT", "SN", "KP", "SS", "CC"].some(item =>
              this.applicationProgramCodes.includes(item)
            ) &&
            this.applicationProgramCodes.includes("MA"))
            || this.applicationProgramCodes.includes("MA")
          ) {
            this.bShowMedicaidText_ = true;
          }
        } else {
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => this.pollApplication(resolve, reject), 1000);
        }
        return;
      }
      reject(response);
    });
  };

  /**
   * @function : handleSaveExitButton
   * @description : This method is used to take the user back to application summary screen.
   */
  handleSaveExitButton () {
    try {
      //#379955
      if (!this.isReadOnlyUser) {
        this.saveExit = true;
      }
      else {
        this[NavigationMixin.Navigate]({
          type: "comm__namedPage",
          attributes: {
            name: apConstants.eligibilityStatus.dashboardUrl
          }
        });
      }
    } catch (error) {
      console.error("Error in handleSaveExitButton", error);
    }
  }

  /**
   * @function : handleExitButton
   * @description : This method is used to take the user back to dashboard.
   */
  handleExitButton () {
    try {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: apConstants.eligibilityStatus.dashboardUrl
        }
      });
    } catch (error) {
      console.error("Error in handleExitButton", error);
    }
  }

  /**
   * @function : handleBackButton
   * @description : This method is used to take the user back to application summary screen.
   */
  handleBackButton () {
    try {
      if (this.addRemoveMember || this.reportChangeMode) {
        this.navigateToAppSummary(
          this.screenId,
          this.sAppId,
          applicationMode.RAC
        );
      } else {
        this.navigateToAppSummary(this.screenId, this.sAppId, this.mode);
      }
    } catch (error) {
      console.error("Error in handleBackButton", error);
    }
  }

  handleNext = () => {
    //Added by Shrikant - CD2
    try {
      if (!utility.isUndefinedOrNull(this.userDetails) && this.userDetails.profileName === apConstants.profileNames.nonCitizen && this.appIdValue != null && this.appIdValue != undefined) {
        addIndividualIdToCache({ applicationId: this.appIdValue }).then(result => {
            this.handleNextButton();
          })
          .catch(error => {
            console.error(
              "failed in SspHouseHoldMemberSummary.handleNext " +
              JSON.stringify(error)
            );
          });
      } 
      else {
        this.handleNextButton();
      }
    } catch (error) {
      this.handleNextButton();
    }
  };

  /**
   * @function : handleNextButton
   * @description : This method is used to take the user back to next screen and do the validation.
   */
  handleNextButton () {
    try {
      /**CD2 2.5 Security Role Matrix and Program Access. - In case of readOnly user. */
      if (this.isReadOnlyUser) {
        this.markScreenCompleteOnNext();
      }
      /** */
      else {
        const memberDetailsComplete = this.memberData.some(
          item => item.showEdit !== true
        );
        if (!this.headDetailsComplete || memberDetailsComplete) {
          this.showErrorToast = true;
        } else {
          let notLinkedProgram = "";
          if (this.UNAssignedPrograms.length > 0) {
            notLinkedProgram = this.UNAssignedPrograms.join(",");
            this.removeProgramText = `${remove} ${notLinkedProgram}`;
            this.chooseMemberText = `${chooseMember} ${notLinkedProgram}`;
            this.reviewProgramNote = `${reviewProgramNoteLineOne} ${notLinkedProgram} ${reviewProgramNoteLineTwo} ${notLinkedProgram} ${reviewProgramNoteLineThree}`;
            this.isProgramInValid = true;
          } else if (this.applicationBlocked) {
            this.showBlockModal = true;
          } else {
            if (this.isNonCitizenVerificationFlag) { // Added this condition as a part of Defect - 378463
              this.markScreenComplete(this.screenId).then(() => { });
            } // Added this condition as a part of Defect - 378463
            if (this.addRemoveMember || this.reportChangeMode) { 
              return this.navigateToAppSummary(
                this.screenId,
                this.sAppId,
                applicationMode.RAC
              );
            }
            else {
                return this.navigateToAppSummary(
                  this.screenId,
                  this.sAppId,
                  this.mode
                );
            }
          }
          if ((this.addRemoveMember || this.reportChangeMode) && !this.isProgramInValid) {
              this.markScreenCompleteOnNext();
          }
        }
      }
    } catch (error) {
      console.error("Error in handleNextButton", error);
    }
  }

  /**
   * @function : markScreenComplete
   * @description : This method is used to mark current screen complete.
   */
  markScreenCompleteOnNext = () => {
    this.markScreenComplete(this.screenId).then(() =>
      this.navigateToAppSummary(
        this.screenId,
        this.sAppId,
        this.mode
      )
    );
  }

  /**
   * @function : handleCross
   * @description : This method is used to remove the member.
   */
  handleCross () {
    try {
      this.showRemoveMemberModal = !this.showRemoveMemberModal;
    } catch (error) {
      console.error("Error in handleCross", error);
    }
  }

  /**
   * @function : removeMember
   * @description : This method is used to call the closeModal function.
   */
  removeMember () {
    try {
      this.closeModal();
    } catch (error) {
      console.error("Error in removeMember", error);
    }
  }

  /**
   * @function : removeMember
   * @description : This method is used to call the closeModal function.
   * @param {*} event -  This parameter provides the updated value.
   */
  remove (event) {
    try {
      const sMemberId = event.detail.sRecordId;
      const sApplicationIndividualId = event.detail.sAppIndividualId;
      this.showSpinner = true;

      deleteMember({
        sMemberId: sMemberId,
        sApplicationIndividualId: sApplicationIndividualId,
        sMode: this.mode
      })
        .then(result => {
          if (result.bIsSuccess) {
            this.reviewRequiredLogic(sMemberId);
          }
        })
        .catch(error => {
          console.error("Error in remove", error);
        });
    } catch (error) {
      console.error("Error in remove", error);
    }
    this.showSpinner = false;
  }

  /**
   * @function : reviewRequiredLogic
   * @description : To make tax filing and absent parent screen review required.
   * @param {*} sMemberId - : Give member id.
   */
  reviewRequiredLogic = sMemberId => {
    try {
      const revRules = [];
      //Start - Tax filing Review Required Logic
      if (!Array.isArray(this.storeMemberData)) {
        return;
      }
      const jointFilers = this.storeMemberData
        .filter(member =>
          [member.sTaxFilerMemberCurrent, member.sTaxFilerMemberNext].includes(
            "FJ"
          )
        )
        .map(member => member.sRecordId);
      if (jointFilers.includes(sMemberId)) {
        const filteredList = jointFilers.filter(m => m !== sMemberId);
        if (filteredList.length > 0) {
          revRules.push("removeMemberTaxFiling," + true + "," + filteredList);
        }
      }
      //End - Tax filing Review Required Logic
      const membersIdList = this.memberData.map(member => member.sRecordId);
      const isNonMagiBeforeDelete = this.memberData.some(member => member.isDisabled || member.isBlind || parseInt(member.sAge) >= 65);
      const isNonMagiAfterDelete = this.memberData.some(member => member.sRecordId !== sMemberId && (member.isDisabled || member.isBlind || parseInt(member.sAge) >= 65));
      if(isNonMagiBeforeDelete && !isNonMagiAfterDelete) {
        revRules.push([
          "Non_MAGI2MAGI",
          true,
          ...membersIdList
        ].join(",")
        );
        revRules.push([
          "MAGI2Non_MAGI",
          false,
          ...membersIdList
        ].join(",")
        );
      }
      this.validateReviewRequiredRules(
        this.appIdValue,
        sMemberId,
        ["Remove_Member_Tax_Filing", "SSP_APP_HHMemberDetails"],
        revRules,
        this.mode
      );
      this.getDetails();
    } catch (error) {
      console.error(
        "Error in reviewRequiredLogic of SspHouseHoldMemberSummary page",
        error.message
      );
    }
  };

  /**
   * @function : closeModal
   * @description : This method is used to close the modal.
   */
  closeModal () {
    try {
      this.showRemoveMemberModal = false;
    } catch (error) {
      console.error("Error in closeModal", error);
    }
  }

  /**
   * @function : handleChooseMember
   * @description : This method is used to close the modal and map the map the member to program.
   */
  handleChooseMember () {
    try {
      this.isProgramInValid = false;
    } catch (error) {
      console.error("Error in handleChooseMember", error);
    }
  }

  /**
   * @function : handleRemoveProgram
   * @description : This method is used to remove the unassigned program.
   */
  handleRemoveProgram () {
    try {
      this.isProgramInValid = false;

      removeUnassignedProgramsOnAPP({
        sApplicationId: this.sAppId,
        sUnassignedProgramsJson: JSON.stringify(this.UNAssignedPrograms)
      })
        .then(result => {
          if (result.bIsSuccess) {
            this.getDetails();
            this.UNAssignedPrograms = [];
          }
        })
        .catch(error => {
          console.error("Error in handleRemoveProgram", error);
        });
    } catch (error) {
      console.error("Error in handleRemoveProgram", error);
    }
  }

  /**
   * @function : learnMoreModal
   * @description : This method is used to show learn more modal.
   */
  learnMoreModal () {
    try {
      this.showLearnMore = true;
    } catch (error) {
      console.error("Error in learnMoreModal", error);
    }
    return false;
  }
  /**
   * @function : showLearnMore
   * @description : This method is used to close learn more modal.
   */
  closeLearnMoreModal () {
    try {
      this.showLearnMore = false;
    } catch (error) {
      console.error("Error in closeLearnMoreModal", error);
    }
  }

  /**
   * @function : handleHideToast
   * @description : This method is used to get notified when toast hides.
   */
  handleHideToast () {
    try {
      this.showErrorToast = false;
    } catch (error) {
      console.error("Error in handleHideToast", error);
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
   * @function : renderedCallback.
   * @description : This method is used to navigate to Application Summary.
   */
  renderedCallback () {
    try {
      const templateId = this.template.querySelector(".learnMoreContent");
      if (templateId) {
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        templateId.innerHTML = this.modValue.HelpModal__c;
      }
    } catch (error) {
      console.error("Error in renderedCallback", error);
    }
  }

  /**
   * @function : closeError.
   * @description	: Method to close error modal. Added by Shrikant CD2 .
   */
  closeError = () => {
    try {
      this.showErrorModal = false;
      this.showSpinner = true;
    } catch (error) {
      console.error(
        "Error in closeError:" + JSON.stringify(error.message)
      );
    }
  };
  
  // Start - Added as part of Defect - 378463
  /**
   * @function : checkNonCitizenVerificationFlag.
   * @description	: This method is use to check NonCitizenVerification flage.
   */
  checkNonCitizenVerificationFlag = () => {
    if (this.houseHoldResult.mapResponse.headOfHousehold
      && this.houseHoldResult.mapResponse.userDetails) {
      const headOfHouseholdData = JSON.parse(this.houseHoldResult.mapResponse.headOfHousehold);
      const userDetailsData = this.houseHoldResult.mapResponse.userDetails;
      if ( headOfHouseholdData.bisHOH === true
        && !headOfHouseholdData.nonCitizenVerificationFlag
        && userDetailsData.profileName === apConstants.profileNames.nonCitizen
        && userDetailsData.showCitizenDashboard === "false" //383998
        && userDetailsData.userRole !== apConstants.userRole.Mail_Center_Worker
        && userDetailsData.userRole !== apConstants.userRole.Mail_Center_Supervisor
        && !apConstants.identityUploadFlagFalseRoles.includes(userDetailsData.userRole)  // 397543, Remove Identity Document Upload for MWMA Users
        && !this.isReadOnlyUser
      ) {
        this.isToDisableAddMember = true;
        this.isNonCitizenVerificationFlag = false;
        this.headDetailsComplete = false;
      } else {
        this.isToDisableAddMember = false;
        this.isNonCitizenVerificationFlag = true;
      }
    }
  }
  // End - Added as part of Defect - 378463
}
