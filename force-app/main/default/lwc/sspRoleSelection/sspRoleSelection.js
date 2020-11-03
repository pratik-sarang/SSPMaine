/**
 * Component Name: sspCareTakerServices.
 * Author: Shrikant Raut, Nikhil Shinde.
 * Description: Component for Role Selection on Non Citizen dashboard.
 * Date: 26/05/2020.
 */
import { track } from "lwc";
import resetDashboardRefreshFlag from "@salesforce/apex/SSP_RoleSelection.resetDashboardRefreshFlag";
import impersonateCitizenOnLoad from "@salesforce/apex/SSP_RoleSelection.impersonateCitizenOnLoad";
import triggerWaiverTokenGeneration from "@salesforce/apex/SSP_WaiverController.triggerWaiverTokenGeneration";
import invokeRoleFlow from "@salesforce/apex/SSP_RoleSelection.invokeFlowForPermissionSet";
import fetchUserDetails from "@salesforce/apex/SSP_RoleSelection.getRequiredDetails";
import sspWelcomeWithComma from "@salesforce/label/c.SSP_WelcomeWithComma";
import sspPersonalDashboard from "@salesforce/label/c.SSP_MultipleRolePersonalDashboard";
import sspMultipleRoleProfile from "@salesforce/label/c.SSP_MultipleRoleProfile";
import agentPortal from "@salesforce/label/c.SSP_Agent_Portal";
import waiverPortal from "@salesforce/label/c.SSP_WaiverPortal";
import sspUtility, { formatLabels } from "c/sspUtility";
import sspConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

export default class SspRoleSelection extends NavigationMixin(sspUtility) {
  @track individualIdForImpersonation; //dummy
  @track firstName = "";
  @track showCitizenDashboardLink = false;
  @track tokenId = "";
  @track waiverRoles = [
    "APPLICATION_INITIATOR",
    "APPLICATION_REVIEWER",
    "CASE_MANAGEMENT_ADMINISTRATOR_INTERNAL",
    "WAIVER_CAPACITY_REVIEWER",
    "CASE_MANAGER",
    "CASE_MANAGER_IN_TRAINING", //387455
    "CASE_SUPERVISOR",
    "CHFS_APPLICATION_INITIATOR",
    "LEVEL_OF_CARE_ASSESSOR",
    "LOC_REVIEWER",
    "POC_REVIEWER",
    "SERVICE_NEEDS_ASSESSOR",
    "INTERNAL_LOC_ASSESSOR",
    "WAIVER_DIRECT_SERVICE_PROVIDER",
    "WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR",
    "CAPACITY_MANAGEMENT_ADMINISTRATOR",
    "Case_Management_Administrator_Read_Only", //386177
    "PROD_Support_Read_Only", //386177
    "CHFS_Internal_Reviewer", //386177
    "CASE_MANAGER_IN_TRAINING"
  ];
  @track label = {
    sspPersonalDashboard,
    sspMultipleRoleProfile,
    sspWelcomeWithComma,
    agentPortal,
    waiverPortal,
  };
  @track selectedRoleLabel;
  @track isDataProcessed = false;
  @track roleOptions = [];
  @track sspMember;// Bug 389924

  selectedRole;
  program;
  /**
   * @function : connectedCallback
   * @description	: Called upon initial component load.
   */
  connectedCallback () {
    this.setUpData();
  }

  get showOneOption () {
    return this.roleOptions && this.roleOptions.length === 1 ? true : false;
  }
  /**
   * @function : handleChange
   * @description	: To handle in role selection.
   * @param  {boolean} isCitizen - True/false.
   */
  handleChange = (isCitizen) => {
    try {
      invokeRoleFlow({ roleName: this.selectedRole, isRedirectedForImpersonation: false }).then(result => {
        const parsedData = result.mapResponse;
        if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
          console.error("Error in handleChange " + JSON.stringify(parsedData.ERROR));
        } else if (result.bIsSuccess && !sspUtility.isUndefinedOrNull(parsedData)) {
          if (isCitizen) {
            this[NavigationMixin.Navigate]({
              type: "comm__namedPage",
              attributes: {
                pageName: sspConstants.navigationUrl.citizenDashboard,
              },
            });
          }

          if (this.selectedRole == "Insurance_Agent") {
            window.open(this.label.agentPortal, "_top");
          } else if (this.waiverRoles.includes(this.selectedRole)) {
            window.open(this.label.waiverPortal, "_top");
          } else {
            location.reload();
          }
                    //commented for defect 391367
                   // this.isDataProcessed = true; 
        }
      });
    } catch (error) {
      console.error("failed in sspRoleSelection.handleChange" + JSON.stringify(error));
    }
  };

  /**
   * @function : setUpData
   * @description	: To handle set up role options and related data.
   */
  setUpData = () => {
    try {
      const url = new URL(window.location.href);
      let encryptedTextInfo = "";
      if (!sspUtility.isUndefinedOrNull(url) && url.searchParams.get("requestInfo")) {
        encryptedTextInfo = decodeURIComponent(url.searchParams.get("requestInfo"));
      }
      this.tokenId = decodeURIComponent(url.searchParams.get("Token"));
      this.sspMember = url.searchParams.get("redirectFromMember");// Bug 389924
      fetchUserDetails({
        encryptedText: encryptedTextInfo,
        token: this.tokenId,
      }).then((result) => {
        const parsedData = result.mapResponse;
        if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
          console.error("Error in retrieving data sspRoleSelection.setUpData  " + JSON.stringify(parsedData.ERROR));
        } else if (result.bIsSuccess && !sspUtility.isUndefinedOrNull(parsedData)) {
          if (parsedData.hasOwnProperty("conWrap") && !sspUtility.isUndefinedOrNull(parsedData.conWrap)) {
            const selectedRole = parsedData.detailsWrap && parsedData.detailsWrap.selectedRole;
            invokeRoleFlow({
                roleName: selectedRole,
                isRedirectedForImpersonation: false
            })
                .then(
                    () => impersonateCitizenOnLoad({
                        contactJson: parsedData.conWrap
                    })
                )
                .then(() => {
                    window.location.replace(
                        location.protocol +
                            "//" +
                            location.host +
                            location.pathname
                    );
                })
          }
          if (parsedData.hasOwnProperty("detailsWrap") && !sspUtility.isUndefinedOrNull(parsedData.detailsWrap)) {
            const detailsWrapper = parsedData.detailsWrap;
            this.roleOptions = !sspUtility.isUndefinedOrNull(detailsWrapper.applicableRoles) ? detailsWrapper.applicableRoles : [];
            this.selectedRole = !sspUtility.isUndefinedOrNull(detailsWrapper.selectedRole) ? detailsWrapper.selectedRole : null;
            if (detailsWrapper.reloadPage) {
              location.reload();
            }
            this.showCitizenDashboardLink = detailsWrapper.showCitizenDashboardLink;
            this.firstName = detailsWrapper.userFirstName;
            this.label.sspWelcomeWithComma = formatLabels(this.label.sspWelcomeWithComma, [this.firstName]);

            if (this.selectedRole == "Insurance_Agent" && !detailsWrapper.showCitizenDashboard && (sspUtility.isUndefinedOrNull(encryptedTextInfo) || encryptedTextInfo === "")) {
              window.open(this.label.agentPortal, "_top");
            } else if (
              this.waiverRoles.includes(this.selectedRole) &&
              !detailsWrapper.showCitizenDashboard &&
              (sspUtility.isUndefinedOrNull(this.tokenId) || this.tokenId === "null" || this.tokenId === "") &&
              (sspUtility.isUndefinedOrNull(this.sspMember) || this.sspMember === "" || this.sspMember === "null")
            ) {// Bug 389924
              triggerWaiverTokenGeneration({
                targetWidget: "DSH_001",
              }).then((resultToken) => {
                const parsedDataToken = resultToken.mapResponse;
                let waiverURL = "";
                if (!sspUtility.isUndefinedOrNull(parsedDataToken)) {
                  if (parsedDataToken.hasOwnProperty("tokenId")) {
                    waiverURL = parsedDataToken.tokenId;
                    if (waiverURL !== undefined && waiverURL !== null && waiverURL !== "") {
                      window.location.href = waiverURL;
                    }
                  }
                }
              });
            } else if (!sspUtility.isUndefinedOrNull(this.sspMember)) {// Bug 389924
              window.location.replace(location.protocol + "//" + location.host + location.pathname);
            } else {
              this.loadProfileDropDown();
              const roleSelectionEvent = new CustomEvent(sspConstants.events.roleSelection);
              this.dispatchEvent(roleSelectionEvent);
            }
          }
        }
      });
    } catch (error) {
      console.error("failed in sspRoleSelection.setUpData " + JSON.stringify(error));
    }
  };

  /**
   * @function - loadProfileDropDown.
   * @description - Method to load the drop down.
   */
  loadProfileDropDown = () => {
    try {
      const roleOptions = this.roleOptions;
      const filteredOptions = [];
      const selectedRoleValue = this.selectedRole;
      const reference = this;
      if (!sspUtility.isUndefinedOrNull(selectedRoleValue) && !sspUtility.isUndefinedOrNull(roleOptions)) {
        roleOptions.forEach(function (role) {
          if (!sspUtility.isUndefinedOrNull(role) && !sspUtility.isUndefinedOrNull(role.value) && role.value === selectedRoleValue) {
            reference.selectedRoleLabel = role.label;
          }

          const wrap = {
            value: role.value,
            label: role.label,
          };

          filteredOptions.push(wrap);
        });

        this.roleOptions = filteredOptions;
      }
      this.isDataProcessed = true;
    } catch (error) {
      console.error("failed in sspRoleSelection.loadProfileDropDown " + JSON.stringify(error));
    }
  };

  /**
   * @function - toggleDropDown.
   * @description - Method to show/hide the drop down.
   * @param {event} event - Gets current value from role drop down.
   */
  toggleDropDown = (event) => {
    try {
      if (event.keyCode === 13 || event.type === "click") {
        const dropDownIcon = this.template.querySelector(".ssp-profileMenuDropDownIcon");
        this.template.querySelector(".ssp-profileMenuDropDownContent").classList.toggle("ssp-expandDropDown");
        dropDownIcon.classList.toggle("ssp-collapseDropDown");
      }
    } catch (error) {
      console.error("failed in sspRoleSelection.toggleDropDown " + JSON.stringify(error));
    }
  };

  /**
   * @function - closeDropDown.
   * @description - Method to hide the drop down.
   */
  closeDropDown = () => {
    try {
      const dropDownIcon = this.template.querySelector(".ssp-profileMenuDropDownIcon");
      this.template.querySelector(".ssp-profileMenuDropDownContent").classList.remove("ssp-expandDropDown");
      dropDownIcon.classList.remove("ssp-collapseDropDown");
    } catch (error) {
      console.error("failed in sspRoleSelection.closeDropDown " + JSON.stringify(error));
    }
  };

  /**
   * @function - handleSelectedRole.
   * @description - Method to select value from drop down.
   * @param {event} event - Gets current value from role drop down.
   */
  handleSelectedRole = (event) => {
    try {
            if (event.keyCode === 13 || event.type === "mousedown") {
        this.isDataProcessed = false;
        event.preventDefault();
        this.selectedRole = event.target.dataset.id.split("-")[0];
        this.selectedRoleLabel = event.target.dataset.label;
        this.toggleDropDown();
        this.handleChange(false);
      }
    } catch (error) {
      console.error("failed in sspRoleSelection.handleSelectedRole " + JSON.stringify(error));
    }
  };

  /**
   * @function - navigateToCitizenDashboard.
   * @description - Method to navigate to citizen dashboard.
   */
  navigateToCitizenDashboard = () => {
    try {
      this.isDataProcessed = false;

      resetDashboardRefreshFlag({}).then((result) => {
        const parsedData = result.mapResponse;
        if (!sspUtility.isUndefinedOrNull(parsedData) && parsedData.hasOwnProperty("ERROR")) {
          console.error("Error in sspRoleSelection.navigateToCitizenDashboard " + JSON.stringify(parsedData.ERROR));
        } else if (result.bIsSuccess) {
          this.selectedRole = "Citizen_Individual";
          this.handleChange(true);
        }
      });
    } catch (error) {
      console.error("failed in sspRoleSelection.navigateToCitizenDashboard " + JSON.stringify(error));
    }
  };
}
