/**
 * Component Name: sspVerticalMenuList.
 * Author: Venkata.
 * Description: This a component which shows a vertical menu.
 * Date: 12/11/2019.
 */
import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import sspOverview from "@salesforce/label/c.SSP_Overview";
import sspBenefits from "@salesforce/label/c.SSP_Benefits";
import sspDocuments from "@salesforce/label/c.SSP_Documents";
import sspClaimsAndPayments from "@salesforce/label/c.SSP_ClaimsAndPayments";
import sspHearings from "@salesforce/label/c.SSP_Hearings";
import sspClaimsPayments from "@salesforce/label/c.SSP_ClaimsPayments";
import sspOverviewName from "@salesforce/label/c.SSP_OverviewName";
import sspDocumentsName from "@salesforce/label/c.SSP_DocumentsName";
import sspHearingsName from "@salesforce/label/c.SSP_HearingsName";
import sspNavigation from "@salesforce/label/c.SSP_Navigation";
import sspAgencyManagement from "@salesforce/label/c.SSP_AgencyManagement";
import sspClientCaseNotes from "@salesforce/label/c.SSP_ClientCaseNotes";
import constants from "c/sspConstants";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import getUserDetails from "@salesforce/apex/SSP_HeaderCtrl.getVerticalMenuDetails";
import getHOHFlag from "@salesforce/apex/SSP_HeaderCtrl.getHOHFlag";
import sspUtility from "c/sspUtility";

export default class LWCModalBoxDemo extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;

    @track selectedRole;
    
    @track showOptions = false;
    shouldRender = true;
    @track renderingMap = {
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
    //Removed below by kyathi as part of addendum
    //{ name: sspMedicaidPlans, label: sspMedicaidPlansMCO },
    @track menuOptions = [
        { name: sspOverviewName, label: sspOverview, id: "CLIENT_NAV_2" },
        { name: "benefits-page", label: sspBenefits, id: "CLIENT_NAV_3" },
        { name: sspDocumentsName, label: sspDocuments, id: "CLIENT_NAV_5"},
        { name: sspClaimsPayments, label: sspClaimsAndPayments, id: "CLIENT_NAV_6" },
        { name: sspHearingsName, label: sspHearings, id: "CLIENT_NAV_7" }
    ];

    customLabels = {
        sspNavigation
    };

    /**
     * @function - connectedCallback
     * @description - Method is used to get url parameters on load.
     */
    connectedCallback () {
        try {

            // Defect # 391364
            getHOHFlag ()
                .then ( response => {
                    if (!sspUtility.isUndefinedOrNull(response) && !sspUtility.isUndefinedOrNull(response.mapResponse) && !sspUtility.isUndefinedOrNull(response.mapResponse.memberType)) {
                        const isHOHUser = response.mapResponse.memberType.includes(constants.headerConstants.HOH) ? true : false;
                        const isNotTMemberUser = response.mapResponse.memberType.includes(constants.headerConstants.TMEM) ? false : true;
                        this.setISHOHFlagValue(isHOHUser);
                        this.setTeamMemberFlag(isNotTMemberUser);
                    }
                })
                .catch(error => {
                    console.error(error);
                });

            //Code to listen to pub-sub event to get isHeadOfHouseHold flag.
            registerListener(constants.headerConstants.HOHFlagEvent, this.setISHOHFlagValue, this);
            registerListener(constants.headerConstants.TeamMemberFlagEvent, this.setTeamMemberFlag, this);

            if(!this.selectedName) {
            const pathName = constants.verticalNavigation.pathName;
            const url = document.location[pathName];
            if (url.split("/s/")[1] === "") {
                this.shouldRender = false;
                this.selectedName = sspOverviewName;
            } else {
                this.shouldRender = false;
                this.selectedName = url.split("/s/")[1];
            }
        }

            getUserDetails ()
                .then(response => {
                    if (!sspUtility.isUndefinedOrNull(response)) {
                        const result = response.mapResponse.userDetails;
                        const securityMatrixNavigation  = response.mapResponse.securityMatrixNavigation.fieldPermissions;
                        
                        this.selectedRole = result.userRole;
                        const profileName = result.profileName;
                        const showCitizenDashboard = result.showCitizenDashboard;
                        this.claimsSSORedirectOn = response.mapResponse.claimsSSORedirectOn === true;
                        
                        if (profileName === constants.profileNames.nonCitizen && showCitizenDashboard === "false") {
                            for (const elementName of Object.keys(this.renderingMap)) {
                                if (this.renderingMap[elementName].id !== "CLIENT_NAV_2") {
                                    this.menuOptions = this.deleteMenu(this.renderingMap[elementName].id,this.menuOptions);
                                }
                            }
                            if (this.selectedRole === "Agency_Admin") {
                                this.menuOptions.push({
                                    name: "agency-management",
                                    label: sspAgencyManagement,
                                    id: "CLIENT_NAV_8"
                                });
                            }
                        } else {
                            if ((this.selectedRole === "Agency_Admin" ||
                                this.selectedRole === "Assister" ||
                                this.selectedRole === "DCBS_View_Only" ||
                                this.selectedRole === "DCBS_Central_Office_View_and_Edit") && 
                                (profileName === constants.profileNames.nonCitizen && showCitizenDashboard === "true")) {
                                    this.menuOptions.push({
                                        name: "client-case-notes",
                                        label: sspClientCaseNotes,
                                        id: "CLIENT_NAV_1"
                                    });
                                }
                            const isCitizenUser = (result.profileName === constants.profileNames.nonCitizen && result.showCitizenDashboard) || result.profileName !== constants.profileNames.nonCitizen;                            
                            const navigationIds = !sspUtility.isUndefinedOrNull(securityMatrixNavigation) ? Object.keys(securityMatrixNavigation) : null;
                            for (const elementName of Object.keys(this.renderingMap)) {
                                let elementId;
                                if ((typeof (isCitizenUser) === "string" && isCitizenUser === "true") || (typeof (isCitizenUser) != "string" && isCitizenUser)) {
                                    elementId = this.renderingMap[elementName].id;

                                }
                                else {
                                    elementId = this.renderingMap[elementName].altId;
                                }
                                if (!sspUtility.isUndefinedOrNull(elementId) && !sspUtility.isUndefinedOrNull(navigationIds) && navigationIds.indexOf(elementId) > -1 && securityMatrixNavigation[elementId] === "NotAccessible") {
                                    this.menuOptions = this.deleteMenu(this.renderingMap[elementName].id, this.menuOptions);
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
                "failed in connectedCallback in verticalNavigation" +
                    JSON.stringify(error)
            );
        }
    }

    deleteMenu = (id, arr) => {
        for (let i = 0; i < arr.length; i++) {
            if (arr[i].id === id) {
                arr.splice(i, 1);
            }
        }
        return arr;
    }

    /**
     * @function - disconnectedCallback
     * @description - Method is used to disconnect all events.
     */
    disconnectedCallback () {
        unregisterAllListeners(this);
    }

    /**
     * @function - setISHOHFlagValue
     * @description - Method is used to get HOH flag.
     * @param {boolean} flagValue - HOH flag value.
     */
    setISHOHFlagValue = flagValue => {
        try {
            this.showOptions = flagValue;
            let tList;
            if (!this.showOptions) {
                tList = this.menuOptions.filter(
                    element => element.name !== sspDocumentsName
                );
                this.menuOptions = tList;
            }
        } catch (error) {
            console.error(
                "Error in setISHOHFlagValue in header" +
                    JSON.stringify(error.message)
            );
        }
    };

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
                tList = this.menuOptions.filter(
                    element => element.name !== sspClaimsPayments && element.name !== sspDocumentsName
                );
                this.menuOptions = tList;
            }
        } catch (error) {
            console.error(
                "Error in setTeamMemberFlag in header" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function - handleSelect
     * @description - Method is used to navigate to other pages.
     * @param {*}event - Fired on selection of navigation option.
     */
    handleSelect = event => {
        try {
            const selectedPage = event.detail.name;
            const isOnClaimsPage = window.location.pathname.endsWith(sspClaimsPayments);
            if(selectedPage === sspClaimsPayments && isOnClaimsPage && this.claimsSSORedirectOn === true) {
                window.location.reload();
                return;
            }
            if (this.shouldRender) {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: selectedPage
                    }
                });
            }
            this.shouldRender = true;
        }
        catch (error) {
            console.error("failed in handleSelect in verticalNavigation" + JSON.stringify(error));
        }
    }
}