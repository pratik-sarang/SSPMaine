/**
 * Component Name: sspHeader.
 * Author: Venkata.
 * Description: This a component shows header.
 * Date: 12/11/2019.
 */
import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspKynecter from "@salesforce/resourceUrl/SSP_KynectImages";

import { classNames, verticalNavigation } from "c/sspConstants";
import apConstants from "c/sspConstants";
import sspFind from "@salesforce/label/c.SSP_Benefind";
import sspDownArrow from "@salesforce/label/c.SSP_DownArrow";
import sspMailIcon from "@salesforce/label/c.SSP_MailIcon";
import sspProfileIcon from "@salesforce/label/c.SSP_ProfileIcon";
import sspDashboard from "@salesforce/label/c.SSP_Dashboard";
import sspPrograms from "@salesforce/label/c.SSP_Programs";
import sspAssistReps from "@salesforce/label/c.SSP_AssistersReps";
import sspRepsAssistersAgents from "@salesforce/label/c.SSP_RepsAssistersAgents";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sspHelpResources from "@salesforce/label/c.SSP_HelpResources";
import sspMyInfo from "@salesforce/label/c.SSP_MyInfo";
import sspSignOut from "@salesforce/label/c.SSP_SignOut";
import sspBackToAssistDashboard from "@salesforce/label/c.SSP_BackToAssisterDashboard";
import sspOverview from "@salesforce/label/c.SSP_Overview";
import sspBenefits from "@salesforce/label/c.SSP_Benefits";
import sspLanguagesText from "@salesforce/label/c.SSP_LanguagesText";
//Commented below by kyathi as part of Addendum
//import sspMedicaidPlans from "@salesforce/label/c.SSP_MedicaidPlans";
//import sspMedicaidPlansMCO from "@salesforce/label/c.SSP_MedicaidPlansMCO";
import sspDocuments from "@salesforce/label/c.SSP_Documents";
import sspClaimsAndPayments from "@salesforce/label/c.SSP_ClaimsAndPayments";
import sspHearings from "@salesforce/label/c.SSP_Hearings";
import sspClaimsPayments from "@salesforce/label/c.SSP_ClaimsPayments";
import sspOverviewName from "@salesforce/label/c.SSP_OverviewName";
import sspBenefitsName from "@salesforce/label/c.SSP_BenefitsName";
import sspDocumentsName from "@salesforce/label/c.SSP_DocumentsName";
import sspDocumentsAPIName from "@salesforce/label/c.SSP_DocumentsAPIName";

import sspHearingsName from "@salesforce/label/c.SSP_HearingsName";
import sspNavigation from "@salesforce/label/c.SSP_Navigation";
import sspLanguages from "@salesforce/label/c.SSP_Language";
import sspSignIn from "@salesforce/label/c.SSP_SignIn";
import sspMedicaidProgram from "@salesforce/label/c.SSP_MedicaidProgram";
import sspSNAPProgram from "@salesforce/label/c.SSP_SNAPProgram";
import sspKTAPProgram from "@salesforce/label/c.SSP_KTAPProgram";
import sspCCAProgram from "@salesforce/label/c.SSP_CCAProgram";
import sspKIHIPPProgram from "@salesforce/label/c.SSP_KIHIPPProgram";
import sspGetLoggedInUserInfo from "@salesforce/apex/SSP_HeaderCtrl.getLoggedInUserInfo";
import sspUpdateUserLanguage from "@salesforce/apex/SSP_HeaderCtrl.updateUserLanguage";
import returnToNonCitizenDashboard from "@salesforce/apex/SSP_HeaderCtrl.returnToNonCitizenDashboard"; //Added by Shrikant - CD2 4.2.1	Client View Banner
import CONTACT_FIRST_NAME from "@salesforce/schema/User.Contact.FirstName";
import CONTACT_NAME from "@salesforce/schema/User.Contact.Name";
import USER_ID from "@salesforce/user/Id";
import sspGetLoginURL from "@salesforce/apex/SSP_HeaderCtrl.fetchKogURL";
import getHOHFlag from "@salesforce/apex/SSP_HeaderCtrl.getHOHFlag";
import updateMemberTypeOnContact from "@salesforce/apex/SSP_HeaderCtrl.updateMemberTypeOnContact";
import triggerWaiverTokenGeneration from "@salesforce/apex/SSP_WaiverController.triggerWaiverTokenGeneration";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import sspUtility from "c/sspUtility";

import sspReturnToLastVisitedUserRoleDashboard from "@salesforce/label/c.SSP_ReturnToLastVisitedUserRoleDashboard";
import sspClientView from "@salesforce/label/c.SSP_Clientview";
import sspPersonalDashboard from "@salesforce/label/c.SSP_PersonalDashboard";
import sspExitClientDashboard from "@salesforce/label/c.SSP_ExitClientDashboard";
import sspExitClientViewMessage from "@salesforce/label/c.SSP_ExitClientViewMessage";
import sspYesExit from "@salesforce/label/c.SSP_YesExit";
import sspCancel from "@salesforce/label/c.sspCancel";
import sspExitPersonalDashboard from "@salesforce/label/c.SSP_ExitPersonalDashboard";
import sspExitPersonalDashboardMessage from "@salesforce/label/c.SSP_ExitPersonalDashboardMessage";
import sspAgencyManagement from "@salesforce/label/c.SSP_AgencyManagement";
import sspClientCaseNotes from "@salesforce/label/c.SSP_ClientCaseNotes";
import sspQualifiedPortal from "@salesforce/label/c.SSP_QualifiedPortal";
import { formatLabels } from "c/sspUtility";
import getUserDetails from "@salesforce/apex/SSP_Utility.getUserDetails";
import agentPortal from "@salesforce/label/c.SSP_Agent_Portal";
import waiverPortal from "@salesforce/label/c.SSP_WaiverPortal";
import sspConstants from "c/sspConstants";
import fetchMessageCenterData from "@salesforce/apex/SSP_DashboardController.fetchMessageCenterData"; //PERF Fix
const hamburgerLabel = "hamburger"; // Added as part of Defect - 383060

export default class SspHeader extends NavigationMixin(LightningElement) {
  @wire(CurrentPageReference) pageRef;
  @track userRole ; //#
  @track kogRegistrationURL = "";
  @track kogLoginURL = "";
  @track chosenLanguage;
  @track programsOptions = [
    { label: sspMedicaidProgram, value: "MA" },
    { label: sspSNAPProgram, value: "SN" },
    { label: sspKTAPProgram, value: "KT" },
    { label: sspCCAProgram, value: "CC" },
    { label: sspKIHIPPProgram, value: "KP" }
  ];
  @track languageOptions;
  @track showMyInfo = false; //#390435
  @track hasRendered = false;
  @track loggedInUserLanguage;
  @track selectedLanguage;
  @track showInterpreterModal = false;
  @track contactName = "";
  @track loginContactName = ""; //Added as part of Defect - 383060
  @track contactFirstName = "";
  @track loginContactFirstName = ""; //Added as part of Defect - 383060
  @track isUserLoggedIn = false;
  @track showRepsLink = false;
  @track logoutUrl = apConstants.url.logoutUrl;
  isAssister = false;
  @track isNonPrimary = false; //for non primary Applicant
  @track memberType;
  @track isClientViewBanner = false;
  @track clientFullName = "";
  @track lastVisitedUserRole = "";
  @track isNonCitizenClientView = false;
  @track isClientViewModal = false;
  @track isPersonalViewModal = false;
  @track reference = this;
  @track navigationSecurityMatrix;
  @track isInsuranceAgent = false;
  @track hideMessageCenter = false;
    @track showQualifiedPortalLink = false;
    @track qualifiedURL = "";
  @track renderingMap = {
    siteLogo: {
      id: "CLIENT_SITE_NAV_1",
      altId: "NON_CITIZEN_SITE_NAV_1",
      isAccessible: true
    },
    dashboardLink: {
      id: "CLIENT_SITE_NAV_2",
      altId: "NON_CITIZEN_SITE_NAV_2",
      isAccessible: true
    },
    programsLink: {
      id: "CLIENT_SITE_NAV_3",
      altId: "NON_CITIZEN_SITE_NAV_3",
      isAccessible: true
    },
    helpResourceLink: {
      id: "CLIENT_SITE_NAV_4",
      altId: "NON_CITIZEN_SITE_NAV_4",
      isAccessible: true
    },
    messageCenterLink: {
      id: "CLIENT_SITE_NAV_5",
      altId: "NON_CITIZEN_SITE_NAV_5",
      isAccessible: true
    },
    repsAssisterLink: {
      id: "CLIENT_SITE_NAV_6",
      altId: "NON_CITIZEN_SITE_NAV_6",
      isAccessible: true
    },
    clientCaseNotes: {
      id: "CLIENT_NAV_1",
      isAccessible: true
    },
    overview: {
      id: "CLIENT_NAV_2",
      altId: "NON_CITIZEN_NAV_2",
      isAccessible: true
    },
    benefits: {
      id: "CLIENT_NAV_3",
      isAccessible: true
    },
    documents: {
      id: "CLIENT_NAV_5",
      isAccessible: true
    },
    claimsAndPayments: {
      id: "CLIENT_NAV_6",
      isAccessible: true
    },
    hearings: {
      id: "CLIENT_NAV_7",
      isAccessible: true
    }
  };
  fetchMsgCenterData = true; //PERF Fix
  showSpinner = false; //PERF Fix
  profileIcon = sspIcons + apConstants.url.profileIcon;
  headerLogo = sspKynecter +apConstants.url.headerLogo;
  programPageApi = "Program_Page__c";
  customLabels = {
    sspFind,
    sspDownArrow,
    sspMailIcon,
    sspProfileIcon,
    sspDashboard,
    sspPrograms,
    sspAssistReps,
    sspHelpResources,
    sspMyInfo,
    sspSignOut,
    sspBackToAssistDashboard,
    sspNavigation,
    sspLanguages,
    sspRepsAssistersAgents,
    sspLanguagesText,
    sspSignIn,
    sspReturnToLastVisitedUserRoleDashboard,
    sspClientView,
    sspPersonalDashboard,
    sspExitClientDashboard,
    sspExitClientViewMessage,
    sspYesExit,
    sspCancel,
    sspExitPersonalDashboard,
    sspExitPersonalDashboardMessage,
    sspAgencyManagement,
    sspClientCaseNotes,
    agentPortal,
        waiverPortal,
        sspQualifiedPortal
  };
  @track dashboardOptions = [
    {
      name: sspOverviewName,
      label: sspOverview,
      apiName: "Home",
      id: "CLIENT_NAV_2"
    },
    {
      name: sspBenefitsName,
      label: sspBenefits,
      id: "CLIENT_NAV_3",
      apiName: "Benefits_Page__c"
    },
    {
      name: sspDocumentsName,
      label: sspDocuments,
      apiName: sspDocumentsAPIName,
      id: "CLIENT_NAV_5"
    },
    {
      name: sspClaimsPayments,
      label: sspClaimsAndPayments,
      id: "CLIENT_NAV_6",
      apiName: "claims__c"
    },
    { 
      name: sspHearingsName, 
      label: sspHearings, 
      id: "CLIENT_NAV_7", 
      apiName: "Hearings__c"
    }
  ];
  @track dashboardOptions = this.dashboardOptions.map((option, index) => ({
    option: option.label,
    name: option.name,
    apiName: option.apiName,
    index: index + 1,
    id: option.id
  }));
  programsOptions = this.programsOptions.map((option, index) => ({
    option: option,
    index: index + 1
  }));

  get dashboardLinkRendering () {
    return (
      this.isUserLoggedIn &&
      this.renderingMap.dashboardLink.isAccessible &&
      !this.isInsuranceAgent
    );
  }

  get repsAssisterLinkRendering () {
    return this.renderingMap.repsAssisterLink.isAccessible && this.showRepsLink;
  }

  /**
   * @function : wiredHOHFlag.
   * @description : Method to load isHeadOfHousehold flag value.
   */
  @wire(getHOHFlag)
  wiredHOHFlag ({ error, data }) {
    try {
      if (
        !sspUtility.isUndefinedOrNull(data) &&
        !sspUtility.isUndefinedOrNull(data.mapResponse)
      ) {
        const result = data.mapResponse;
        if (!sspUtility.isUndefinedOrNull(result.memberType)) {
          this.memberType = result.memberType;
          if (
            this.memberType.includes(apConstants.headerConstants.DEP) &&
            !this.memberType.includes(apConstants.headerConstants.HOH)
          ) {
            this.isNonPrimary = false;
          } else {
            this.isNonPrimary = true;
          }
        } else {
          this.isNonPrimary = true;
        }
        if (!sspUtility.isUndefinedOrNull(result.memberType)) {
          const member = result.memberType;
          let optionsList;
          if (member.includes(apConstants.headerConstants.TMEM)) {
            optionsList = this.dashboardOptions.filter(
              element =>
                element.name !== sspClaimsPayments &&
                element.name !== sspDocumentsName
            );
            this.dashboardOptions = optionsList;
          }
        }
      } else if (error) {
        console.error(
          "Error in wiredHOHFlag wire call" + JSON.stringify(error.message)
        );
      }
    } catch (error) {
      console.error(
        "Error in wiredHOHFlag in header" + JSON.stringify(error.message)
      );
    }
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [CONTACT_NAME, CONTACT_FIRST_NAME]
  })
  getContactData ({ error, data }) {
    if (data) {
      this.contactName = getFieldValue(data, CONTACT_NAME);
      this.loginContactName = this.contactName; //Added as part of Defect - 383060
      if (
        getFieldValue(data, CONTACT_FIRST_NAME) !== null &&
        getFieldValue(data, CONTACT_FIRST_NAME) !== undefined
      ) {
        this.contactFirstName = getFieldValue(data, CONTACT_FIRST_NAME);
        this.loginContactFirstName = this.contactFirstName; //Added as part of Defect - 383060
      } else {
        this.contactFirstName = getFieldValue(data, CONTACT_NAME);
        this.loginContactFirstName = this.contactFirstName; //Added as part of Defect - 383060
      }
    } else if (error) {
      this.error = error;
    }
  }
  /**
   * @function : connectedCallback.
   * @description : Method to load language picklist.
   */
  connectedCallback () {
    try {
      registerListener("contactNameEvent", this.setContactName, this);

      this.isUserLoggedIn = USER_ID ? true : false;
      const sspLanguagesList = this.customLabels.sspLanguages.split(";");
      const optionsArray = [];
      if (!this.isUserLoggedIn) {
        this.showRepsLink = true;
      }
      sspGetLoggedInUserInfo()
        .then(result => {
          if (result && result.mapResponse) {

            //PERF Fix - call fetchMessageCenterData only when non citizen is trying to access message center without impersonation
            const profileName  =  result.mapResponse.userDetails ? result.mapResponse.userDetails.userProfile : null;
            this.fetchMsgCenterData =
                (profileName &&
                profileName == apConstants.profileNames.nonCitizen &&
                result.mapResponse.userDetails &&
                !result.mapResponse.userDetails.showCitizenDashboard)
                    ? true
                    : false;

            this.determineMyInfoVisibility(result.mapResponse); //#390435
			this.userRole = result.mapResponse.userRole; //#392529
            /* CD2 2.5 Security Role Matrix. */
            if (result.mapResponse.hasOwnProperty("securityMatrixNavigation")) {
              const currentUrl = window.location.href;
              /* Redirecting QE Role users */
              if (
                result.mapResponse.userDetails &&
                result.mapResponse.userDetails.isQeRedirect &&
                result.mapResponse.userDetails.isQeRedirect === true &&
                result.mapResponse.userDetails.endPoint && 
                result.mapResponse.userDetails.encryptedToken &&
                currentUrl.toLocaleLowerCase().indexOf("prescreening") === -1 &&
                currentUrl.toLocaleLowerCase().indexOf("find-dcbs-office") === -1
              ) {
                const portalUrl = new URL(result.mapResponse.userDetails.endPoint);
                portalUrl.searchParams.append("EncryptedData",result.mapResponse.userDetails.encryptedToken);
                window.open(portalUrl.href, "_top");
              }
              
              const securityMatrixNavigation =
                result.mapResponse.securityMatrixNavigation.fieldPermissions;
              const ids = !sspUtility.isUndefinedOrNull(
                securityMatrixNavigation
              )
                ? Object.keys(securityMatrixNavigation)
                : null;
              const securityUserDetails = result.mapResponse.userDetails;
              let isCitizenUser = null;
              if(securityUserDetails  && securityUserDetails.userProfile) {
              isCitizenUser =
                    (securityUserDetails.userProfile ===
                    apConstants.profileNames.nonCitizen &&
                    securityUserDetails.showCitizenDashboard) ||
                    securityUserDetails.userProfile !==
                    apConstants.profileNames.nonCitizen;
                this.isInsuranceAgent =
                  securityUserDetails.selectedRole === "Insurance_Agent";
              }
              this.hideMessageCenter =
                !sspUtility.isUndefinedOrNull(
                  result.mapResponse.hideMessageCenter
                ) && result.mapResponse.hideMessageCenter === true
                  ? true
                  : false;
              if (this.isUserLoggedIn && !this.hideMessageCenter) {
                this.hideMessageCenter = true;
              } else {
                this.hideMessageCenter = false;
              }
              for (const elementName of Object.keys(this.renderingMap)) {
                const elementId = isCitizenUser
                  ? this.renderingMap[elementName].id
                  : this.renderingMap[elementName].altId;
                if (
                  !sspUtility.isUndefinedOrNull(elementId) &&
                  !sspUtility.isUndefinedOrNull(ids) &&
                  ids.indexOf(elementId) > -1 &&
                  securityMatrixNavigation[elementId] === "NotAccessible"
                ) {
                  this.renderingMap[elementName].isAccessible = false;
                } else {
                  this.renderingMap[elementName].isAccessible = true;
                }
              }
            }
            if (
              result.mapResponse.hasOwnProperty("securityMatrixNavigation") &&
              result.mapResponse.securityMatrixNavigation
            ) {
              this.navigationSecurityMatrix =
                result.mapResponse.securityMatrixNavigation.fieldPermissions;
            }
            /* CD2 2.5 Security Role Matrix. */
          }
          this.loggedInUserLanguage = result
            ? JSON.parse(JSON.stringify(result.mapResponse.wrapper))
            : "";
          if (
            this.isUserLoggedIn &&
            result.mapResponse.hasOwnProperty("showRepsLink")
          ) {
            this.showRepsLink = true;
          }
          for (let i = 0; i < sspLanguagesList.length; i++) {
            const split = sspLanguagesList[i].split("-");
            optionsArray.push({
              name: split[0],
              value: split[1]
            });
            if (this.loggedInUserLanguage === split[1]) {
              this.chosenLanguage = split[0];
            }
          }
          this.languageOptions = optionsArray;
          /**Added by Shrikant -  CD2 4.2.1	Client View Banner. */
          if (
            !sspUtility.isUndefinedOrNull(result) &&
            !sspUtility.isUndefinedOrNull(result.mapResponse) &&
            !sspUtility.isUndefinedOrNull(result.mapResponse.userDetails)
          ) {
            const userDetails = result.mapResponse.userDetails;
            if (
              userDetails.userProfile === apConstants.profileNames.nonCitizen &&
              userDetails.showCitizenDashboard
            ) {
              let clientFullName = "";
              this.isClientViewBanner = true;
              this.isNonCitizenClientView =
                userDetails.selectedRole === "Citizen_Individual"
                  ? false
                  : true; //in case of impersonation

              //#376149
              let suffix;
              let firstName;
              let middleName;
              let lastName;
              if (this.isNonCitizenClientView) {
                const clientContact = userDetails.citizenContact;
                suffix = !sspUtility.isUndefinedOrNull(
                  clientContact.SuffixCode__c
                )
                  ? clientContact.SuffixCode__c
                  : "";
                firstName = !sspUtility.isUndefinedOrNull(
                  clientContact.FirstName
                )
                  ? clientContact.FirstName
                  : "";
                middleName = !sspUtility.isUndefinedOrNull(
                  clientContact.MiddleName
                )
                  ? clientContact.MiddleName
                  : "";
                lastName = !sspUtility.isUndefinedOrNull(clientContact.LastName)
                  ? clientContact.LastName
                  : "";
              } else {
                suffix = !sspUtility.isUndefinedOrNull(userDetails.userSuffix)
                  ? userDetails.userSuffix
                  : "";
                firstName = !sspUtility.isUndefinedOrNull(
                  userDetails.userFirstName
                )
                  ? userDetails.userFirstName
                  : "";
                middleName = !sspUtility.isUndefinedOrNull(
                  userDetails.userMiddleInitial
                )
                  ? userDetails.userMiddleInitial
                  : "";
                lastName = !sspUtility.isUndefinedOrNull(
                  userDetails.userLastName
                )
                  ? userDetails.userLastName
                  : "";
              }

              clientFullName =
                firstName +
                (firstName != "" ? " " : "") +
                middleName +
                (middleName != "" ? " " : "") +
                lastName +
                (lastName != "" ? " " : "") +
                suffix;
              this.clientFullName = clientFullName; //#376149

              this.lastVisitedUserRole =
                userDetails.rolesMap[userDetails.lastVisitedNonCitizenRole];
              this.customLabels.sspExitClientViewMessage = formatLabels(
                this.customLabels.sspExitClientViewMessage,
                [this.lastVisitedUserRole]
              );
              this.customLabels.sspExitPersonalDashboardMessage = formatLabels(
                this.customLabels.sspExitPersonalDashboardMessage,
                [this.lastVisitedUserRole]
              );
              this.customLabels.sspReturnToLastVisitedUserRoleDashboard = formatLabels(
                this.customLabels.sspReturnToLastVisitedUserRoleDashboard,
                [this.lastVisitedUserRole]
              );
              const headerReference = this.template.querySelector(
                ".ssp-header"
              );
              headerReference.style.marginTop = "30px";
              this.template.querySelector(
                ".ssp-hamburger-header"
              ).style.marginTop = "30px";
            } else {
              this.isClientViewBanner = false;
              const headerReference = this.template.querySelector(
                ".ssp-header"
              );
              headerReference.style.marginTop = "0px";
              this.template.querySelector(
                ".ssp-hamburger-header"
              ).style.marginTop = "0px";
            }
            if(!userDetails.showCitizenDashboard){
              this.showQualifiedPortalLink = !sspUtility.isUndefinedOrNull(
                userDetails.showQeHospitalRole
              )
                ? userDetails.showQeHospitalRole
                : false;
            }
              this.qualifiedURL = (!sspUtility.isUndefinedOrNull(userDetails.endPoint)) 
              ? userDetails.endPoint+"?EncryptedData="+userDetails.encryptedToken
              : "";
          }
          /** */
          //Code to listen to pub-sub event to get isHeadOfHouseHold flag.
          registerListener(
            apConstants.headerConstants.isNewUserDashboard,
            this.handleNewUserEvent,
            this
          );
          registerListener(
            apConstants.headerConstants.TeamMemberFlagEvent,
            this.setTeamMemberFlag,
            this
          );

          //Logic to remove Documents option if Dependent user Logs in.
          /*let optionsList;
                    if (!this.isNonPrimary) {
                        optionsList = this.dashboardOptions.filter(
                            element => element.name !== sspDocumentsName
                        );
                        this.dashboardOptions = optionsList;
                    }*/
        })
        .catch(error => {
          console.error(
            "failed in renderedCallback in header" + JSON.stringify(error)
          );
        });

      getUserDetails()
        .then(result => {
          if (!sspUtility.isUndefinedOrNull(result)) {
            const selectedRole = result.userRole;
            const profileName = result.profileName;
            const showCitizenDashboard = result.showCitizenDashboard;

            if (
              profileName === sspConstants.profileNames.nonCitizen &&
              showCitizenDashboard === "false"
            ) {
              //Start - Added as part of Defect - 380077
              for (const elementName of Object.keys(this.renderingMap)) {
                //Condition to keep only Overview Menu and delete rest of them
                if (this.renderingMap[elementName].id !== "CLIENT_NAV_2") {
                  this.dashboardOptions = this.deleteMenu(
                    this.renderingMap[elementName].id,
                    this.dashboardOptions
                  );
                }
              }
              //End - Added as part of Defect - 380077
              if (selectedRole === "Agency_Admin") {
                this.dashboardOptions.push({
                  option: sspAgencyManagement,
                  name: "agency-management",
                  apiName: "agency_management__c",
                  index: this.dashboardOptions + 1,
                  id: "CLIENT_NAV_9"
                });
              }
            } else {
              if (
                (selectedRole === "Agency_Admin" ||
                  selectedRole === "Assister" ||
                  selectedRole === "DCBS_View_Only" ||
                  selectedRole === "DCBS_Central_Office_View_and_Edit") &&
                (profileName === sspConstants.profileNames.nonCitizen &&
                  showCitizenDashboard === "true")
              ) {
                this.dashboardOptions.push({
                  option: sspClientCaseNotes,
                  name: "client-case-notes",
                  apiName: "Client_Case_Notes__c",
                  index: this.dashboardOptions + 1,
                  id: "CLIENT_NAV_1"
                });
              }
              const navigationIds = !sspUtility.isUndefinedOrNull(
                this.navigationSecurityMatrix
              )
                ? Object.keys(this.navigationSecurityMatrix)
                : null;
              for (const elementName of Object.keys(this.renderingMap)) {
                if (
                  !sspUtility.isUndefinedOrNull(navigationIds) &&
                  navigationIds.indexOf(this.renderingMap[elementName].id) >
                    -1 &&
                  this.navigationSecurityMatrix[
                    this.renderingMap[elementName].id
                  ] === "NotAccessible"
                ) {
                  this.dashboardOptions = this.deleteMenu(
                    this.renderingMap[elementName].id,
                    this.dashboardOptions
                  );
                }
              }
            }
          }
        })
        .catch(error => {
          console.error(error);
        });
    } catch (error) {
      console.error(
        "Error in createLanguageArray in header" + JSON.stringify(error.message)
      );
    }
  }

  //#390435
  determineMyInfoVisibility = (data) => {
    this.showMyInfo = (data && data.hasOwnProperty("securityMatrixMyInformation") && data.securityMatrixMyInformation.screenPermission && data.securityMatrixMyInformation.screenPermission === "NotAccessible") ? false : true;    
  };

  //#390435
  get showMyInfoNonPrimary (){
    return this.isNonPrimary && this.showMyInfo;
  }

  deleteMenu = (id, arr) => {
    for (let i = 0; i < arr.length; i++) {
      if (arr[i].id === id) {
        arr.splice(i, 1);
      }
    }
    return arr;
  };

  /**
   * @function : disconnectedCallback.
   * @description : Method to destroy all active events.
   */
  disconnectedCallback () {
    unregisterAllListeners(this);
  }

  /**
   * @function - setTeamMemberFlag
   * @description - Method is used to get TeamMember flag.
   * @param {boolean} flagValue - TeamMember flag value.
   */
  setTeamMemberFlag = flagValue => {
    try {
      this.showOptions = flagValue;
      let tList;
      if (!this.showOptions) {
        tList = this.dashboardOptions.filter(
          element =>
            element.name !== sspClaimsPayments &&
            element.name !== sspDocumentsName
        );
        this.dashboardOptions = tList;
      }
    } catch (error) {
      console.error(
        "Error in setISHOHFlagValue in header" + JSON.stringify(error.message)
      );
    }
  };

  /**
   * @function : handleNewUserEvent.
   * @description : Method to handle event.
   * @param {boolean} flags - Holds event parameter.
   */
  handleNewUserEvent = flags => {
    try {
      if (flags) {
        if (
          !sspUtility.isUndefinedOrNull(flags.isFirstTimeUser) &&
          !sspUtility.isUndefinedOrNull(flags.isHeadOfHousehold) &&
          !flags.isHeadOfHousehold &&
          !flags.isFirstTimeUser
        ) {
          this.isNonPrimary = false;
        } else {
          this.isNonPrimary = true;
        }
        let optionsList;
        if (
          !this.isNonPrimary ||
          (!sspUtility.isUndefinedOrNull(flags.isFirstTimeUser) &&
            flags.isFirstTimeUser)
        ) {
          optionsList = this.dashboardOptions.filter(
            element => element.name !== sspDocumentsName
          );
          this.dashboardOptions = optionsList;
        }
      } else {
        this.isNonPrimary = true;
      }
    } catch (error) {
      console.error(
        "Error in handleNewUserEvent in header" + JSON.stringify(error.message)
      );
    }
  };

  /**
   * @function : setISHOHFlagValue.
   * @description : Method to destroy all active events.
   * @param {boolean} flagValue - Holds event parameter.
   */
  setISHOHFlagValue = flagValue => {
    try {
      this.isNonPrimary = flagValue;
      updateMemberTypeOnContact({
        isHeadOfHousehold: this.isNonPrimary
      })
        .then(() => {
          let optionsList;
          if (!this.isNonPrimary) {
            optionsList = this.dashboardOptions.filter(
              element => element.name !== sspDocumentsName
            );
            this.dashboardOptions = optionsList;
          }
        })
        .catch(error => {
          this.message =
            "Error received: message " + JSON.stringify(error.message);
        });
    } catch (error) {
      console.error(
        "Error in setISHOHFlagValue in header" + JSON.stringify(error.message)
      );
    }
  };

  setContactName = flagValue => {
    try {
      this.contactName = flagValue;
      this.contactFirstName = flagValue ? flagValue.split(" ")[0] : "";
    } catch (error) {
      console.error(
        "Error in setISHOHFlagValue in header" + JSON.stringify(error.message)
      );
    }
  };

  /**
   * @function - renderedCallback
   * @description - Method is used to get url parameters once the DOM is loaded.
   */
  renderedCallback () {
    try {
      if (!this.hasRendered) {
        const pathName = verticalNavigation.pathName;
        const url = document.location[pathName];
        let activeItem = url.split("/s/")[1];
        if (activeItem === "") {
          activeItem = sspOverviewName;
          this.template
            .querySelectorAll(`.${activeItem}`)[0]
            .classList.add(classNames.sspActiveItem);
        } else if (
          activeItem &&
          this.template.querySelectorAll(`.${activeItem}`) &&
          this.template.querySelectorAll(`.${activeItem}`).length
        ) {
          this.template
            .querySelectorAll(`.${activeItem}`)[0]
            .classList.add(classNames.sspActiveItem);
        }
        this.hasRendered = true;
      }
    } catch (error) {
      console.error(
        "failed in renderedCallback in header" + JSON.stringify(error)
      );
    }
  }

  /**
   * @function - handleNavigation
   * @description - Method is used to navigate to other pages.
   * @param {*}event - Fired on selection of option.
   */
  handleNavigation = event => {
    try {
      const selectedPage = event.currentTarget.getAttribute("data-page");
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: selectedPage
        },
        state: {
          from: hamburgerLabel // Added as part of Defect - 383060
        }
      });
      this.closeSideNav();
    } catch (error) {
      console.error(
        "failed in handleNavigation in header" + JSON.stringify(error)
      );
    }
  };

  /**
   * @function - navigateToHomePage
   * @description - Method is used to navigate to home page.
   */
  navigateToHomePage = () => {
    try {
      /** #392529. */
      const benefitsUsers = [sspConstants.userRole.DJJ, sspConstants.userRole.EBI, sspConstants.userRole.DOE];
      if (this.renderingMap.dashboardLink.isAccessible) { 
      /** */
        window.open(apConstants.url.home, "_self");
        this.closeSideNav();
      /** #392529. */
      }
      else if (this.userRole && benefitsUsers.includes(this.userRole)){
        window.location.href = "../s/" + sspConstants.navigationUrl.benefitsPageName;
      }
      /** */
    } catch (error) {
      console.error(
        "failed in handleNavigation in header" + JSON.stringify(error)
      );
    }
  };

  /**
   * @function - navigateToLoginPage
   * @description - Method is used to navigate to login page.
   */
  navigateToLoginPage = () => {
    try {
      sspGetLoginURL()
        .then(result => {
          if ("KogLoginURL" in result.mapResponse) {
            this.kogLoginURL = result.mapResponse.KogLoginURL;
            window.open(result.mapResponse.KogLoginURL, "_self");
          }
        })
        .catch(error => {
          console.error(
            "failed in renderedCallback in header" + JSON.stringify(error)
          );
        });

      this.closeSideNav();
    } catch (error) {
      console.error(
        "failed in handleNavigation in header" + JSON.stringify(error)
      );
    }
  };

  /**
   * @function - navigation
   * @description - Method is used to navigate to other pages.
   * @param {*}event - Fired on selection of option.
   */
  programNavigation (event) {
    try {
      const programCode =
        event.currentTarget.getAttribute("data-program") || "MA";
      window.location.href = "../s/program-page?program="+programCode;
      window["$A"].get("e.force:refreshView").fire();
      this.closeSideNav();
    } catch (error) {
      console.error("failed in navigation in header" + JSON.stringify(error));
    }
  }

  /**
   * @function - languageChange
   * @description - Method is used to select the language from the drop down.
   * @param {*}event - Fired on selection of option.
   */
  languageChange = event => {
    try {
      this.showInterpreterModal = false;
      if (
        event.keyCode === apConstants.learnMoreModal.enterKeyCode ||
        event.type === apConstants.learnMoreModal.clickLearn
      ) {
        this.selectedLanguage = event.target.dataset.value;
        if (this.selectedLanguage !== this.loggedInUserLanguage) {
          if (
            this.selectedLanguage === "en_US" ||
            this.selectedLanguage === "es_US"
          ) {
            sspUpdateUserLanguage({
              selectedLanguage: this.selectedLanguage
            })
              .then(result => {
                this.reloadPage();
              })
              .catch(error => {
                console.error(
                  "failed in renderedCallback in header" + JSON.stringify(error)
                );
              });
          } else {
            this.showInterpreterModal = true;
          }
        }
        this.closeSideNav();
      }
    } catch (error) {
      console.error(
        "failed in languageChange in header" + JSON.stringify(error)
      );
    }
  };

  /**
   * @function - openSideNav
   * @description - Method is used to open the hamburger.
   */
  openSideNav = () => {
    try {
      const sideNav = this.template.querySelector(classNames.sspSideNav);
      sideNav.style.width = "100%";
    } catch (error) {
      console.error("failed in openSideNav in header" + JSON.stringify(error));
    }
  };

  /**
   * @function - closeSideNav
   * @description - Method is used to close the hamburger.
   */
  closeSideNav = () => {
    try {
      const sideNav = this.template.querySelector(classNames.sspSideNav);
      const dropDownContainer = this.template.querySelectorAll(
        classNames.sspDropDownContainer
      );
      const dropDownButtons = this.template.querySelectorAll(
        classNames.sspDropDownBtn
      );
      for (const container of dropDownContainer) {
        container.style.display = "none";
      }
      for (const dropDownBtn of dropDownButtons) {
        dropDownBtn.children[0].iconName = classNames.utilityChevronDown;
        dropDownBtn.classList.remove(classNames.sspDashboardOptionBorder);
      }
      sideNav.style.width = "0";
    } catch (error) {
      console.error("failed in closeSideNav in header" + JSON.stringify(error));
    }
  };

  /**
   * @function - togglePrograms
   * @description - Method is used to select the program from the drop down.
   * @param {*}event - Fired on selection of option.
   */
  togglePrograms = event => {
    try {
      const dropDownContent = event.target.nextElementSibling
        ? event.target.nextElementSibling
        : event.target.parentElement.nextElementSibling;

      if (dropDownContent.style.display === "block") {
        dropDownContent.style.display = "none";
        if (event.target.children[0]) {
          event.target.children[0].iconName = classNames.utilityChevronDown;
          event.target.classList.remove(classNames.sspDashboardOptionBorder);
        } else {
          event.target.iconName = classNames.utilityChevronDown;
          event.target.parentElement.classList.remove(
            classNames.sspDashboardOptionBorder
          );
        }
      } else {
        const dropDownContainer = this.template.querySelectorAll(
          classNames.sspDropDownContainer
        );
        const dropDownButtons = this.template.querySelectorAll(
          classNames.sspDropDownBtn
        );
        for (const container of dropDownContainer) {
          container.style.display = "none";
        }
        for (const dropDownBtn of dropDownButtons) {
          dropDownBtn.children[0].iconName = classNames.utilityChevronDown;
          dropDownBtn.classList.remove(classNames.sspDashboardOptionBorder);
        }

        dropDownContent.style.display = "block";
        if (event.target.children[0]) {
          event.target.children[0].iconName = classNames.utilityChevronUp;
          event.target.classList.add(classNames.sspDashboardOptionBorder);
        } else {
          event.target.iconName = classNames.utilityChevronUp;
          event.target.parentElement.classList.add(
            classNames.sspDashboardOptionBorder
          );
        }
      }
    } catch (error) {
      console.error(
        "failed in togglePrograms in header" + JSON.stringify(error)
      );
    }
  };

  /**
   * @function : reloadPage.
   * @description : Method to reload page.
   */
  reloadPage = () => {
    try {
      if (location.href.includes("language=en_US")) {
        location.href = location.href.replace(
          "language=en_US",
          "language=" + this.selectedLanguage
        );
      } else if (location.href.includes("language=es_US")) {
        location.href = location.href.replace(
          "language=es_US",
          "language=" + this.selectedLanguage
        );
      } else if (location.href.slice(-1) === "/") {
        location.href = location.href.concat(
          "?language=" + this.selectedLanguage
        );
      } else if (location.href.includes("/#-1")) {
        location.href = location.href.replace(
          "#-1",
          "?language=" + this.selectedLanguage
        );
      } else if (location.href.includes("#-1")) {
        if (location.href.includes("?")) {
          location.href = location.href.replace(
            "#-1",
            "&language=" + this.selectedLanguage
          );
        } else {
          location.href = location.href.replace(
            "#-1",
            "?language=" + this.selectedLanguage
          );
        }
      } else if (location.href.includes("?")) {
        if (location.href.slice(-1) === "?") {
          location.href = location.href.concat(
            "language=" + this.selectedLanguage
          );
        } else {
          location.href = location.href.concat(
            "&language=" + this.selectedLanguage
          );
        }
      } else if (!location.href.includes("?")) {
        location.href = location.href.concat(
          "?language=" + this.selectedLanguage
        );
      } else {
        location.href = location.href.concat(
          "&language=" + this.selectedLanguage
        );
      }
    } catch (error) {
      console.error(
        "Error in reloadPage in header" + JSON.stringify(error.message)
      );
    }
  };

  closeInterpreterModal () {
    try {
      this.showInterpreterModal = false;
    } catch (error) {
      console.error(
        "Error in closeInterpreterModal in header" +
          JSON.stringify(error.message)
      );
    }
  }
  openClientViewModal = (event) => {
    if (
      event.type === "click" ||
      (event.type === "keydown" && (event.keyCode === 13 || event.keyCode === 32 ))
    ) {
      this.isClientViewModal = true;
    }
  };
  closeClientViewModal = () => {
    this.isClientViewModal = false;
  };
  openPersonalViewModal = (event) => {
    if (
      event.type === "click" ||
      (event.type === "keydown" && (event.keyCode === 13 || event.keyCode === 32))
    ) {
       this.isPersonalViewModal = true;
    }
  };
  closePersonalViewModal = () => {
    this.isPersonalViewModal = false;
  };

  //PERF Fix
  navigateToMessageCenter = () => {
    try {
        this.showSpinner = true;
        if (this.fetchMsgCenterData){
          fetchMessageCenterData().then(result => {
            this.triggerMessageCenterNavigation();
          });
        }
        else{
          this.triggerMessageCenterNavigation();
        }   
    } catch (error) {
        this.showSpinner = false;
        console.error(
            "failed in navigateToMessageCenter in sspHeader" +
                JSON.stringify(error)
        );
    }
    
    
  };

  //PERF Fix
  triggerMessageCenterNavigation = () => {
    this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
            name: "Message_Center__c"
        }
    });
    this.closeSideNav();
    this.showSpinner = false;
  }


  /**
   * @function - returnToNonCitizenDashboard.
   * @description - Method to navigate to non citizen dashboard - Added by Shrikant - CD2 4.2.1	- Client View Banner.
   */
  returnToNonCitizenDashboard = () => {
    try {
      returnToNonCitizenDashboard({}).then(result => {
        const parsedData = result;
        if (
          !sspUtility.isUndefinedOrNull(parsedData) &&
          parsedData.hasOwnProperty("ERROR")
        ) {
          console.error(
            "Error in retrieving data sspRoleSelection.setUpData  " +
              JSON.stringify(parsedData.ERROR)
          );
        } else if (result.bIsSuccess) {
          this.isClientViewModal = false;
          this.isPersonalViewModal = false;
          if (
            !sspUtility.isUndefinedOrNull(
              result.mapResponse.redirectToAgentPortal
            )
          ) {
            if (result.mapResponse.redirectToAgentPortal) {
              window.location.href = this.customLabels.agentPortal;
                        }
                    } else if (
                        !sspUtility.isUndefinedOrNull(
                            result.mapResponse.redirectToWaiverPortal
                        )
                    ) {
                        
                        if (result.mapResponse.redirectToWaiverPortal) {
                            triggerWaiverTokenGeneration({
                              targetWidget: "DSH_001",
                              roleName: result.mapResponse.userRole
                            }).then(resultToken => {
                                const parsedDataToken = resultToken.mapResponse;
                                let waiverURL = "";
                                
                                if (!sspUtility.isUndefinedOrNull(parsedDataToken)) {
                                    if (parsedDataToken.hasOwnProperty("tokenId")) {
                                        waiverURL = parsedDataToken.tokenId;
                                        if (
                                            waiverURL !== undefined &&
                                            waiverURL !== null &&
                                            waiverURL !== ""
                                        ) {
                                            
                                            window.location.href = waiverURL;
                                        }
                                    }
                                }
                            });
            }
          } else {
            window.location.href = "../s/dashboard";
          }
        }
      });
    } catch (error) {
      console.error(
        "failed in sspHeader.returnToNonCitizenDashboard " +
          JSON.stringify(error)
      );
    }
  };

  /**
   * @function - navigateToHelpFAQ.
   * @description - Method to navigate Help and FAQ landing Page - Added by Narapa.
   */
  navigateToHelpFAQ () {
    {
      window.location.href= "../s/help-categories";
    }
  }
    /**
     * @function - navigateToQualifiedPortal
     * @description - Method to navigate to Qualified Entity Portal.
     */
    navigateToQualifiedPortal = () => {
        try {
            window.open(this.qualifiedURL, "_blank");
            this.closeSideNav();
        } catch (error) {
            console.error("Error in opening URL of Qualified Entity Portal " + error);
        }
    }
}
