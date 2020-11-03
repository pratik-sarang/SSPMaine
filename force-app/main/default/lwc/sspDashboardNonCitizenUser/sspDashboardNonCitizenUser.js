import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspConstants from "c/sspConstants";
import sspOverviewIcons from "@salesforce/resourceUrl/sspOverviewIcons";
import sspApplyForBenefitsDashboard from "@salesforce/label/c.SSP_ApplyForBenefitsDashboard";
import sspStartBenefitApplication from "@salesforce/label/c.SSP_StartBenefitApplication";
import sspIWantTo from "@salesforce/label/c.SSP_IWantTo";
import sspCheckForEligibilityDescription from "@salesforce/label/c.SSP_CheckForPotentialEligibility";
import sspDownloadUserManualDescription from "@salesforce/label/c.SSP_DownloadUserManual";
import sspRequestAccessToCaseDescription from "@salesforce/label/c.SSP_RequestAccessToCase";
import sspStartShortSNAPDescription from "@salesforce/label/c.SSP_StartShortSNAP";
import sspVisitAgentPortalDescription from "@salesforce/label/c.SSP_VisitAgentPortal";
import sspAgentPortal from "@salesforce/label/c.SSP_AgentPortal";
import sspDownloadUserManual from "@salesforce/label/c.SSP_DownloadQualifiedEntityUserManual";
import sspPreScreeningTool from "@salesforce/label/c.SSP_PrescreeningTool";
import sspStartShortSNAP from "@salesforce/label/c.SSP_StartShortSNAP";
import sspRequestAccess from "@salesforce/label/c.SSP_RequestAccess";
import sspAgentPortalURL from "@salesforce/label/c.SSP_AgentPortalURL";
import sspUserManualDownloadLink from "@salesforce/label/c.SSP_UserManualURL";
import sspBackgroundImage from "@salesforce/label/c.SSP_BackgroundImage";

import nonCitizenId from "@salesforce/user/Id";
import getNonCitizenUserInfo from "@salesforce/apex/SSP_NonCitizenDashboardController.getNonCitizenUserInfo";
import getWantToDashboardLinkVisibility from "@salesforce/apex/SSP_NonCitizenDashboardService.getWantToDashboardLinkVisibility";

import resetCache from "@salesforce/apex/SSP_NonCitizenDashboardController.resetCache";
import utility from "c/sspUtility";
import sspCardImages from "@salesforce/resourceUrl/sspCardImages";
import sspUtility from "c/sspUtility";

export default class SspDashboardNonCitizenUser extends NavigationMixin(
    LightningElement
) {
    @track benefitButtonLabel = sspApplyForBenefitsDashboard;
    @track citizenConnect = sspOverviewIcons + sspConstants.url.citizenConnect;
    @track access = false;
    @track userId = nonCitizenId;
    @track nonCitizenUserData = {};
    @track searchResultData = {};
    @track roleVisibility = false;
    @track userRole;
    @track clientCount;
    @track showSearchResult = true;
    @track isRoleChosen = false;
    @track linkRoleVisibility = {};
    @track showRequestAccessLink = false;
    @track isAuthRep = false;
    @track isFirstCall = true; //Non citizen dashboard load time fix
    @track showSpinner = false; // Added as part of Defect - 381407
    @track showErrorModal = false;
    @track errorCode; 
    @track dataToExportForMyInformation;
    /**2.5 Security Role Matrix and Program Access. */
    @track renderingMap = {
        addBenefitsLink: {
            id: "NON_CITIZEN_DB_1",
            isAccessible: false
        },
        showID: {
            id: "NON_CIITIZEN_MY_INFO_1",
            isAccessible: false
        },
        showOrganization: {
            id: "NON_CIITIZEN_MY_INFO_2",
            isAccessible: false
        },
        showCoverageArea: {
            id: "NON_CIITIZEN_MY_INFO_3",
            isAccessible: false
        },
        showPublicPrivate: {
            id: "NON_CIITIZEN_MY_INFO_5",
            isAccessible: false
        },
        showClients: {
            id: "NON_CIITIZEN_MY_INFO_4",
            isAccessible: false
        },
        showContactInformation: {
            id: "NON_CIITIZEN_MY_INFO_6",
            isAccessible: false
        },
        showOrganizationName: {
            id: "NON_CIITIZEN_MY_INFO_7",
            isAccessible: false
        }
    };
    customLabels = {
        sspIWantTo,
        sspCheckForEligibilityDescription,
        sspDownloadUserManualDescription,
        sspRequestAccessToCaseDescription,
        sspStartShortSNAPDescription,
        sspVisitAgentPortalDescription,
        sspAgentPortal,
        sspDownloadUserManual,
        sspPreScreeningTool,
        sspStartShortSNAP,
        sspRequestAccess,
        sspAgentPortalURL,
        sspUserManualDownloadLink,
        sspStartBenefitApplication,
        sspBackgroundImage
    };
    authorizedRepresentativeURL = sspConstants.url.authReps;
    shortSnapURL = sspConstants.url.shortSnapGetStartedUrl;
    backgroundImg = sspCardImages + sspConstants.url.backgroundImage;
  closeError = () => {
        this.errorCode = "";
        this.showErrorModal = false;
  }; 
    /**
     * @function 		: navigateToBenefitsScreen.
     * @description 	: method to navigate to benefits Page.
     **/
    navigateToBenefitsScreen = () => {
        try {
            resetCache()
                .then()
                .catch(error => {
                    console.error(
                        "Error in resetCache:" +
                        JSON.stringify(error)
                    );
                });
            this[NavigationMixin.Navigate]({
                type: sspConstants.communityPageNames.community,
                attributes: {
                    name: sspConstants.communityPageNames.getStartedBenefits
                }
            });
        } catch (error) {
            console.error(
                "failed in navigateToBenefitsScreen in sspDashboardExistingUser" +
                JSON.stringify(error)
            );
        }
    };

    /* Added as part of Defect - 381407  
     * Changed the connectedCallback() to initComponent() because, 
     * Citizen role was getting passed for Assister after he comes from his personal dashboard.
     */
    /**
     * @function : initComponent
     * @description : Method gets non citizen user info on load.
     **/
    initComponent = () => {
        try {
            if (this.userId) {
                //Non citizen dashboard load time fix
                this.getNonCitizenUserInfo(false);
                this.getWantToDashboardLinkVisibility();
            }
        } catch (error) {
            console.error("Error in initComponent");
        }

    }

  /**
   * @function : triggerGetInfo
   * @description : Method triggers non citizen get information call.
   **/
  triggerGetInfo = () => {
    try {
      
      //console.log("*$* --- just reached triggerGetInfo ");
      if(this.isFirstCall){
        //console.log("*$* --- triggerGetInfo moving ahead with getNonCitizenUserInfo");
        this.showSpinner = true;
        this.getNonCitizenUserInfo(true);
      }
      this.isFirstCall=false;
    } catch (error) {
      console.error("Error in triggerGetInfo");
    }
  };


    /**
     * @function : getNonCitizenUserInfo
     * @description : used to get logged in user data Non Citizen.
     **/
    getNonCitizenUserInfo (doMakeCall) {
        try {
            getNonCitizenUserInfo({
                userId: this.userId,
                isCall: doMakeCall //Non citizen dashboard load time fix
            })
                .then(result => {

                    /**2.5 Security Role Matrix and Program Access. */
                    if (
                        result.mapResponse.bIsSuccess &&
                        !utility.isUndefinedOrNull(
                            result.mapResponse.securityMatrixDetails
                        )
                    ) {
                        const { securityMatrixDetails } = result.mapResponse;
                        const renderingMap = this.renderingMap;
                        const fieldPermissions = !sspUtility.isUndefinedOrNull(securityMatrixDetails) ? securityMatrixDetails.fieldPermissions : null;
                        Object.keys(renderingMap).forEach(
                            mapKey => {
                                const key = renderingMap[mapKey].id;
                                this.renderingMap[mapKey].isAccessible = (!sspUtility.isUndefinedOrNull(fieldPermissions) && !sspUtility.isUndefinedOrNull(fieldPermissions[key]) && fieldPermissions[key] === sspConstants.permission.notAccessible) ? false : true;
                            }, this);
                    }
                    
                    /** */
          if (
              result.mapResponse.bIsSuccess &&
              !utility.isUndefinedOrNull(result.mapResponse.ackStatusCode)
          ) {
              this.errorCode = result.mapResponse.ackStatusCode;
              this.showErrorModal = true;
          } 
          if (
            result.mapResponse.bIsSuccess &&
            !utility.isUndefinedOrNull(result.mapResponse.csrListDataToExport)
        ){
          this.dataToExportForMyInformation=result.mapResponse.csrListDataToExport;         
        }
                    if (
                        result.mapResponse.bIsSuccess &&
                        !utility.isUndefinedOrNull(
                            result.mapResponse.nonCitizenInfo
                        )
                    ) {
                        this.nonCitizenUserData =
                            result.mapResponse.nonCitizenInfo;
                        this.clientCount = result.mapResponse.searchResultCount;
                       
                        this.access =
                            result.mapResponse.nonCitizenInfo.accessPublicPrivate;
                        if (this.access === true) {
                            this.isPrivate = true;
                        } else {
                            this.isPublic = true;
                        }
                        this.userRole =
                            result.mapResponse.nonCitizenInfo.userRole;
                        if (this.userRole === "Assister") {
                            this.roleVisibility = true;
                        }
                        //Added by Kyathi as part of 5.8 CD2
                        if (
                            this.userRole === "Assister" ||
                            this.userRole === "Organization_Auth_Rep" ||
                            this.userRole === "Individual_Auth_Rep" ||
                            this.userRole === "Agency_Admin"
                        ) {
                            this.showRequestAccessLink = true;
                        }
                        if (
                            this.userRole === "Organization_Auth_Rep" ||
                            this.userRole === "Individual_Auth_Rep"
                        ) {
                            this.isAuthRep = true;
                        }
                    } else if (!result.mapResponse.bIsSuccess) {
                        console.error(
                            "Error in retrieving data SspMyInformationCard  " +
                            JSON.stringify(this.nonCitizenUserData.ERROR)
                        );
                        this.showRequestAccessLink = true;
                    }
                    this.isRoleChosen = true; // Added as part of Defect - 381407
                    this.showSpinner = false; // Added as part of Defect - 381407
                })
                .catch({});
        } catch (error) {
            console.error(
                "Error occurred in getNonCitizenUserInfo of My Information page" +
                JSON.stringify(error)
            );
            //Non citizen dashboard load time fix
            this.showSpinner = false;
        }
    }
    /**
     * @function : getWantToDashboardLinkVisibility
     * @description : used to get logged in user data Non Citizen.
     **/
    getWantToDashboardLinkVisibility () {
        try {
            getWantToDashboardLinkVisibility({
                userId: this.userId
            })
                .then(result => {
                    if (
                        result.mapResponse.bIsSuccess &&
                        !utility.isUndefinedOrNull(
                            result.mapResponse.linkRoleVisibility
                        )
                    ) {
                        this.linkRoleVisibility =
                            result.mapResponse.linkRoleVisibility;
                    } else if (!result.mapResponse.bIsSuccess) {
                        console.error(
                            "Error in retrieving data Want to Dashboard  " +
                            JSON.stringify(this.linkRoleVisibility.ERROR)
                        );
                    }
                    this.showSpinner = false; 
                })
                .catch({});
        } catch (error) {
            this.showSpinner = false; 
            console.error(
                "Error occurred in retrieving data Want to Dashboard" +
                JSON.stringify(error)
            );
        }
    }

    /**
     * @function : handleRoleSelection
     * @description : Method to check if role was chosen.
     **/
    handleRoleSelection = () => {
        this.showSpinner = true; // Added as part of Defect - 381407
        this.initComponent(); // Added as part of Defect - 381407
        this.isFirstCall = true; //Non citizen dashboard load time fix
    };
}