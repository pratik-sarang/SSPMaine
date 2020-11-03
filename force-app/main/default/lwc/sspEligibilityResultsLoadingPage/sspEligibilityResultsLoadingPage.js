/*
 * Component Name: sspEligibilityResultsLoadingPage
 * Author: Kyathi
 * Description: This screen shows eligibility results loading page.
 * Date: 2/2/2020.
 */
import { track, LightningElement } from "lwc";
import gearIcon from "@salesforce/resourceUrl/gear";
import successTick from "@salesforce/resourceUrl/successTick";
import sspBackgroundImage from "@salesforce/label/c.SSP_BackgroundImage";
import sspLoadingTextLine1 from "@salesforce/label/c.SSP_EligibilityResultsLoadingText";
import sspLoadingTextLine2 from "@salesforce/label/c.SSP_EligibilityResultsLoadingText2";
import sspLoadingTextLine3 from "@salesforce/label/c.SSP_EligibilityResultsLoadingText3";
import sspLoadingTextLine4 from "@salesforce/label/c.SSP_EligibilityResultsLoadingText4";
import constant from "c/sspConstants";
import utility from "c/sspUtility";
import { NavigationMixin } from "lightning/navigation";
import fetchApplicationStatus from "@salesforce/apex/SSP_SignaturePageCtrl.fetchApplicationStatus";
import fetchCustomSettings from "@salesforce/apex/SSP_SignaturePageCtrl.fetchCustomSettings";

import eligibilityLoadingPageResource from "@salesforce/resourceUrl/SSP_KynectImages8";
import eligibilityLoadingImage from "@salesforce/resourceUrl/SSP_KynectImages7";
import sspProcessingApplication from "@salesforce/label/c.SSP_ProcessingApplication";
import sspValidatingData from "@salesforce/label/c.SSP_ValidatingData";
import sspSavingData from "@salesforce/label/c.SSP_SavingData";
import sspDeterminingBenefits from "@salesforce/label/c.SSP_DeterminingBenefits";
import sspRetrievingResults from "@salesforce/label/c.SSP_RetrievingResults";

export default class SspEligibilityResultsLoadingPage extends NavigationMixin(LightningElement) {
    @track applicationId;
    @track sMode;
    @track loopCheck = false;
    @track showSpinner = false;
    @track showErrorModal = false;
    @track errorMsg;
    @track countTime = 0;
    @track timeInterval;
    @track timePeriod;
    @track isNotAccessible =true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track gearSrc = gearIcon;
    @track successTickSrc = successTick;
    @track loaderObject = [
        {
            isGearVisible:true,
            isTickVisible:false,
            isMessageVisible:true,
            message:sspProcessingApplication,
            id:"M1"
        },{
            isGearVisible: false,
            isTickVisible: false,
            isMessageVisible: false,
            message: sspValidatingData,
            id: "M2"
        },{
            isGearVisible: false,
            isTickVisible: false,
            isMessageVisible: false,
            message: sspSavingData,
            id: "M3"
        },{
            isGearVisible: false,
            isTickVisible: false,
            isMessageVisible: false,
            message: sspDeterminingBenefits,
            id: "M4"
        },{
            isGearVisible: false,
            isTickVisible: false,
            isMessageVisible: false,
            message: sspRetrievingResults,
            id: "M5"
        }
    ];
    timerIndex=0;
    timeIntervalMethod;
    backgroundImg =
        eligibilityLoadingImage + constant.url.eligibilityLoadBackGroundMobile;
    desktopBackgroundImg =
        eligibilityLoadingImage + constant.url.eligibilityLoadBackGroundDesktop;
    loadingSpinner =
        eligibilityLoadingPageResource + constant.url.eligibilityLogoLoader;
    label = {
        sspBackgroundImage,
        sspLoadingTextLine1,
        sspLoadingTextLine2,
        sspLoadingTextLine3,
        sspLoadingTextLine4
    };

    connectedCallback (){
        const sPageURL = decodeURIComponent(
            window.location.search.substring(1)
        );
        const sURLVariables = sPageURL.split("&");
        let applicationId = null;
        let mode = null;
        if (sURLVariables != null) {
            for (let i = 0; i < sURLVariables.length; i++) {
                const sParam = sURLVariables[i].split("=");
                if (sParam[0] === "applicationId") {
                    applicationId =
                        sParam[1] === undefined ? "Not�found" : sParam[1];
                }
                if (sParam[0] === "mode") {
                    mode =
                        sParam[1] === undefined ? null : sParam[1];
                }
            }
        }
        this.sMode = mode;
        this.applicationId = applicationId;
        this.fetchCustomSettingsData();
        this.startTimerLogic();
    }

    /**
     * @function : startTimerLogic.
     * @description : Function used to show gear & tick icon after specific time interval.
    */
    startTimerLogic = () =>{
        try{
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.timeIntervalMethod = setInterval(() => {
                if (this.timerIndex<=3){
                    this.loaderObject[this.timerIndex].isGearVisible = false;
                    this.loaderObject[this.timerIndex].isTickVisible = true;
                    this.loaderObject[this.timerIndex + 1].isGearVisible = true;
                    this.loaderObject[this.timerIndex + 1].isMessageVisible = true;
                }
                else{
                    clearInterval(this.timeIntervalMethod);
                    return;
                }
                this.timerIndex += 1;
            }, 10000);
        }
        catch(error){
            console.error("Error in startTimerLogic");
        }
    }

    /**
     * @function : fetchCustomSettingsData.
     * @description : Function used to fetch the Custom Settings Data.
     */
    fetchCustomSettingsData = () => {
        let result;
        fetchCustomSettings({})
            .then(response => {
                result = response.mapResponse;
                if (response && response.mapResponse){
                    const { securityMatrixEligibilityResultsLoading } = response.mapResponse;
                    if (!securityMatrixEligibilityResultsLoading || !securityMatrixEligibilityResultsLoading.hasOwnProperty("screenPermission") || !securityMatrixEligibilityResultsLoading.screenPermission) {
                        this.isNotAccessible = false;
                    }
                    else {
                        this.isNotAccessible = securityMatrixEligibilityResultsLoading.screenPermission === constant.permission.notAccessible;
                    }
                    if (this.isNotAccessible) {
                        this.showAccessDeniedComponent = true;
                    }
                }
                else{
                    this.isNotAccessible = false;
                }
                this.timePeriod = result.timePeriod;
                this.timeInterval = result.timeInterval;
                if (!utility.isUndefinedOrNull(this.timeInterval) && !utility.isEmpty(this.timeInterval) && !utility.isUndefinedOrNull(this.timePeriod) && !utility.isEmpty(this.timePeriod)) {
        this.fetchAppStatus(this.applicationId);
    }
            })
            .catch(error => {
                this.isNotAccessible = false;
                console.error(
                    "Error Message " +
                    JSON.stringify(error)
                );
            });
        return result;
    }
    /**
* @function : fetchApplicationStatus.
* @description : Function used to fetch the Application DC Case Number.
* @param {appId} appID - Application ID.
*/
    fetchAppStatus = appID => {
        const setTimeInterval = ((this.timePeriod/(this.timeInterval/1000)));
        this.countTime = this.countTime + 1;
        fetchApplicationStatus({
            sApplicationId: appID
        })
            .then(response => {
                const result = response.mapResponse;
                if (result.hasOwnProperty("ERROR")) {
                    console.error(
                        "Error in fetchApplicationStatus.fetchStatus" +
                        result.ERROR
                    );
                } else if (result.hasOwnProperty("status")) {
                    const status = result.status;
                    if (status === constant.pollingStatus_RAC.success) {

                    if (
                            result.SSPDCMessage === "F" ||
                            result.SSPDCMessage === "P" ||
                            result.SSPDCMessage === "HBE3000" ||
                            result.SSPDCMessage === "HBE1000" ||
                            result.SSPDCMessage === "HBE9000" 
                        ) {
                              clearInterval(this.timeIntervalMethod);
                              for (
                                  let i = 0;
                                  i < this.loaderObject.length;
                                  i++
                              ) {
                                  this.loaderObject[i].isGearVisible = false;
                                  this.loaderObject[i].isMessageVisible = true;
                                  this.loaderObject[i].isTickVisible = true;
                              }
                              // eslint-disable-next-line @lwc/lwc/no-async-operation
                              setTimeout(() => {
                                  this[NavigationMixin.Navigate]({
                                      type: "comm__namedPage",
                                      attributes: {
                                          name: "Eligibility_Results__c"
                                      },
                                      state: {
                                          applicationId: this.applicationId
                                      }
                                  });
                              }, 200);
                          } /*else if (result.SSPDCMessage === "HBE9000"){
                            this.errorMsg = result.CHFSError;
                            this.showErrorModal = true;
                        }*/
                        this.showSpinner = false;
                    } else {
                        if (this.countTime < setTimeInterval){
                        // eslint-disable-next-line @lwc/lwc/no-async-operation
                        setTimeout(() => {
                                this.fetchAppStatus(this.applicationId
                            );
                            }, this.timeInterval);
                        }else{
                            this[NavigationMixin.Navigate]({
                                type: "comm__namedPage",
                                attributes: {
                                    name: "Eligibility_Results__c"
                                },
                                state: {
                                    applicationId: this.applicationId
                                }
                            });
                        }
                    }
                }
            })
            .catch(error => {
                console.error(
                    "Error Message " +
                    JSON.stringify(error)
                );
            });

    }

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
            this.showSpinner = false;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Sign_and_Submit__c"
                },
                state: {
                    applicationId: this.applicationId,
                    mode: this.sMode
                }
            });
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    }
}
