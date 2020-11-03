/**
 * Component Name: sspMCOSelection.
 * Author: Fazeel Ahmed/Vishakha Verma/Sanchita Tibrewala.
 * Description: This component for selecting MCO.
 * Date: 05 August 2020.
 */

import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { track, api } from "lwc";
import { formatLabels } from "c/sspUtility";
import sspMCOPreferredPlan from "@salesforce/label/c.SSP_MCOPreferredPlan";
import sspBrowsePlan from "@salesforce/label/c.SSP_BrowsePlan";
import sspMCOPara from "@salesforce/label/c.SSP_MCOPara";
import sspMCOParaTwo from "@salesforce/label/c.SSP_MCOParaTwo";
import sspMCOHere from "@salesforce/label/c.SSP_MCOHere";
import sspOldMCOPara from "@salesforce/label/c.SSP_OldMCOPara";
import sspNewMCOPara from "@salesforce/label/c.SSP_NewMCOPara";
import sspMCOHereTitle from "@salesforce/label/c.SSP_MCOHereTitle";
import getPlanDetails from "@salesforce/apex/SSP_PreferredMCOSelectionController.getMCODetails";
import savePlanDetails from "@salesforce/apex/SSP_PreferredMCOSelectionController.saveMCODetails";
import utility from "c/sspUtility";
import sspConstants from "c/sspConstants"
import sspPDFAsset from "@salesforce/resourceUrl/SSP_Assert";

export default class SspMCOSelection extends BaseNavFlowPage {
    @track showSpinner = false;
    @track preferredPlanFormattedLabel;
    @track oldMCOParaFormatted;
    @track newMCOParaFormatted;
    @track showOldMCOPara = false;
    @track showNewMCOPara = false;
    @track planOptions;
    @track memberIdValue;
    @track metaDataListParent = {};
    @track nextValue = {};
    @track validationFlag = {};
    @track memberObject = {};
    @track planDetails = {};
    @api currentMemberName;
    @track oldMCOName = "";
    @track newMCOName = "";
    @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
    @track selectedPlan="";
    @track oldMCOPlanList=[];
    @track newMCOPlanList=[];
    label = {
        sspBrowsePlan,
        sspMCOPara,
        sspMCOParaTwo,
        sspMCOHere,
        sspMCOHereTitle
    };
    sspComparisonChart = `${sspPDFAsset}${sspConstants.url.comparisonChart}`;

    /**
    * @function - get MetadataList.
    * @description - MetadataList getter method for framework.
    */
   @api
   get MetadataList () {
       return this.metaDataListParent;
   }

   /**
   * @function - set MetadataList.
   * @description - Next Event setter method for framework.
   * @param {string} value - Setter for MetadataList framework property.
   */
   set MetadataList (value) {
       try {
           if (value) {
               this.metaDataListParent = value;
               //CD2 2.5	Security Role Matrix and Program Access.                
                if (Object.keys(value).length > 0) {
                    this.constructRenderingMap(null, value);
                }
               }
       } catch (e) {
           console.error(
               "Error in set MetadataList of MCO Selection page",
               e
           );
       }
   }

   /**
   * @function - get memberId.
   * @description - This method is used to get memberId value.
   */
   @api
   get memberId () {
       return this.memberIdValue;
   }

   /**
   * @function - set memberId.
   * @description - This method is used to set memberId value.
   * @param {*} value - Member Id.
   */
   set memberId (value) {
       try {
           if (value) {
               this.memberIdValue = value;

               this.getPlanFunction(value);
           }
       } catch (e) {
           console.error(
               "Error in set memberId of MCO Selection page",
               e
           );
       }
   }

    /**
    * @function - get nextEvent.
    * @description - Next Event getter method for framework.
    */
    @api
    get nextEvent () {
        return this.nextValue;
    }

    /**
    * @function - set nextEvent.
    * @description - Next Event setter method for framework.
    * @param {string} value - Setter for Next Event framework property.
    */
    set nextEvent (value) {
        try {
            if (value) {
                this.nextValue = value;
                this.checkInputValidation();
            }
        } catch (e) {
            console.error(
                "Error in set nextEvent of MCO Selection page",
                e
            );
        }
    }

    /**
    * @function - allowSaveData.
    * @description - This method validates the input data and then saves it.
    */
    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            if (value) {
                this.validationFlag = value;
                this.savePlanData(value);
            }
        } catch (e) {
            console.error(
                "Error in set allowSaveData of MCO Selection page",
                e
            );
        }
    }

    /**
     * @function : checkInputValidation
     * @description : Framework method to check input validation.
     */
    checkInputValidation = () => {
        try {
            const planDetails = this.template.querySelectorAll(
                ".preferredDetails"
            );
            this.templateInputsValue = planDetails;
        } catch (e) {
            console.error(
                "Error in checkInputValidation of MCO Selection page",
                e
            );
        }
    }

    /**
     * @function : savePlanData
     * @description : This method is used to save plan information.
     * @param {string} planInfo - Plan information.
     */
    savePlanData = (planInfo) => {
        try {
            this.showSpinner = true;
            const planInfoObject = JSON.parse(planInfo);
            const selectedPlan = planInfoObject[sspConstants.preferredMcoSelectionConstants.preferredName];
            planInfoObject[sspConstants.preferredMcoSelectionConstants.preferredId] = this.planDetails[selectedPlan];
            savePlanDetails({
                memberId: this.memberIdValue,
                memberPlanInfo: JSON.stringify(planInfoObject)
            }).then(() => {
                this.saveCompleted = true;
            })
            .catch(error => {
                this.saveCompleted = false;
                console.error(
                    "Error in getting Plan details" +
                        JSON.stringify(error)
                );
            });
            
        } catch (e) {
            this.showSpinner = false;
            console.error(
                "Error in savePlanData of MCO Selection page",
                e
            );
        }
    }
    
    /**
     * @function : connectedCallback
     * @description : get called on load of page.
     */
    connectedCallback () {
        try
        {
            this.showSpinner = true;
            this.preferredPlanFormattedLabel = formatLabels(
                sspMCOPreferredPlan,
                [this.currentMemberName]
            );

            this.oldMCOParaFormatted = formatLabels(
                sspOldMCOPara,
                [this.oldMCOName]
            );

            this.newMCOParaFormatted = formatLabels(
                sspNewMCOPara,
                [this.newMCOName]
            );   

            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                "PreferredMCOName__c,SSP_Member__c",
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_Details_MCOSelection"
            );
        } catch (error) {
            console.error("Error in Connected Call back of MCO Selection page"+ error);
        }
        
    }

    /**
     * @function : getPlanFunction
     * @description : This method is used to get plan Details from org.
     * @param {string} value - Member Id.
     */
    getPlanFunction = (value) => {
        getPlanDetails({
            memberId: value
        })
        .then(result => {
            this.planDetails = result.mapResponse.planDetails;
            this.planOptions = this.picklistDataFormat(result.mapResponse.planDetails);
            this.memberObject = result.mapResponse.memberObject;
            this.oldMCOPlanList = result.mapResponse.oldMCOPlans || [];
            this.newMCOPlanList = result.mapResponse.newMCOPlans || [];
            this.selectedPlan = this.memberObject.PreferredMCOName__c;
            this.checkMCOPlanStatus(this.selectedPlan);
            this.showSpinner = false;           
        })
        .catch(error => {
            console.error(
                "Error in getting Plan details" +
                    JSON.stringify(error)
            );
        });
    }

    /**
     * @function : checkMCOPlanStatus
     * @description : This method is used to check plan status yet to expire/renew.
     * @param {string} planName - Plan Name.
     */
    checkMCOPlanStatus (planName) {
        try {
            this.showOldMCOPara = false;
            this.showNewMCOPara = false;
            if(!utility.isUndefinedOrNull(this.oldMCOPlanList) && 
                Array.isArray(this.oldMCOPlanList) && 
                this.oldMCOPlanList.length && 
                this.oldMCOPlanList.includes(planName)) {

                this.showOldMCOPara = true;
                this.oldMCOParaFormatted = formatLabels(
                    sspOldMCOPara,
                    [planName]
                );
                window.scrollTo({ top: 0, left: 0, behavior: "smooth"});
			} else if (!utility.isUndefinedOrNull(this.newMCOPlanList) && 
                        Array.isArray(this.newMCOPlanList) && 
                        this.newMCOPlanList.length && 
                        this.newMCOPlanList.includes(planName)) {

				this.showNewMCOPara = true;
				this.newMCOParaFormatted = formatLabels(
                    sspNewMCOPara,
                    [planName]
                );
                window.scrollTo({ top: 0, left: 0, behavior: "smooth"});
			}
        } catch (error) {
            console.error("Error in checkMCOPlanStatus of MCO Selection page", error);
        }
    }

/**
 * @function - handleValueChange
 * @description - Update value if event is changed.
 * @param {*} event - JSON response.
 */
    handleValueChange (event) {
        this.selectedPlan = event.detail;
        this.checkMCOPlanStatus(this.selectedPlan);

    }
    /**
     * @function - picklistDataFormat
     * @description - Formats the data of picklist value.
     * @param {*} data - JSON response.
     */
    picklistDataFormat (data) {
        try {
            const objectArray = Object.entries(data);
            const arrayData = [];
            objectArray.forEach(([key]) => {
                const objectData = {};
                objectData.label = key;
                objectData.value = key;
                arrayData.push(objectData);
            });
            return arrayData;
        } catch (error) {
            console.error("Error in picklistDataFormat of MCO Selection page", error);
        }
    }

    /**
    * @function : constructRenderingMap
    * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
    * @param {string} appPrograms - Application level programs.
    * @param {string} metaValue - Entity mapping data.
    */
    constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms !== "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                    this.isNotAccessible = securityMatrix.screenPermission === sspConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                else{
                    this.showAccessDeniedComponent = false;
                }
            }
        } catch (error) {
            console.error(
                            "Error in constructRenderingMap", error
                        );
        }
    }
}