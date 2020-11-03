/**
 * Component Name : sspExpeditedSnapBenefits.
 * Description : The Expedite SNAP Benefits screen asks for information to determine if the user qualifies for expedited SNAP.
 * Author : Karthik,Velu & Sai Kiran.
 * Date : 01/16/2020.
 **/
import { track, api } from "lwc";
import apConstants from "c/sspConstants";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import sspNo from "@salesforce/label/c.SSP_No";
import sspYes from "@salesforce/label/c.SSP_Yes";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspLearnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import sspFarmWorker from "@salesforce/label/c.SSP_ExpeditedSnapFarmWorkerQuestion";
import sspGrossIncome from "@salesforce/label/c.SSP_ExpeditedSnapGrossIncomeQuestion";
import sspTheQuestionsBelow from "@salesforce/label/c.SSP_ExpeditedSnapTheQuestionsBelow";
import sspLearnMoreAlternate from "@salesforce/label/c.SSP_ExpeditedSnapLearnMoreAlternate";
import sspLiquidResources from "@salesforce/label/c.SSP_ExpeditedSnapLiquidResourcesQuestion";
import sspShelterExpenses from "@salesforce/label/c.SSP_ExpeditedSnapShelterExpensesQuestion";
import sspExpediteSnapBenefit from "@salesforce/label/c.SSP_ExpediteSnapBenefit";
import utility, { getYesNoOptions } from "c/sspUtility";
import updateApplication from "@salesforce/apex/SSP_ExpeditedSnapBenefitCtrl.updateApplication";
import fetchApplication from "@salesforce/apex/SSP_ExpeditedSnapBenefitCtrl.fetchApplicationData";
import sspLearnMoreModalContent from "@salesforce/label/c.SSP_LearnMoreModalContent";
import sspShelterExpensesHelpContent from "@salesforce/label/c.SSP_ExpeditedSnapShelterExpensesHelpContent";

export default class SspExpeditedSnapBenefits extends baseNavFlowPage {
  /**
   * @function 	: applicationId.
   * @description : This attribute is part of validation framework which gives the Application ID.
   * */
  @api
  get applicationId () {
    return this.appId;
  }
  set applicationId (value) {
    try {
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.appId = value;
        this.fetchAppData(this.appId);
      }
    } catch (error) {
      console.error(
        "Error while fetching Application ID in Expedite Benefits Page" + error
      );
    }
  }

  /**
   * @function 	: MetadataList.
   * @description : This function is part of validation framework which is used to get the metaData values.
   * */
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  set MetadataList (value) {
    try {
      this.MetaDataListParent = value;
      //CD2 2.5	Security Role Matrix and Program Access.                
      if (Object.keys(value).length > 0) {
        this.constructRenderingMap(null, value);
      }
    } catch (error) {
      console.error(
        "Error while fetching metadata values in Expedite Benefits Page" + error
      );
    }
  }

  /**
   * @function 	: allowSave.
   * @description : This attribute is part of validation framework which indicates data is valid or not.
   * */
  @api
  get allowSaveData () {
    return this.allowSaveValue;
  }
  set allowSaveData (value) {
    try {
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.showSpinner = true;
        this.allowSaveValue = value;
        this.saveData();
      }
    } catch (error) {
      this.showSpinner = false;
      console.error("Error in allowSave of Expedite Benefits Page" + error);
    }
  }

  /**
   * @function 	: nextEvent.
   * @description : This attribute is part of validation framework which is used to navigate to next Screen.
   * */
  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    try {
     
      if (!utility.isUndefinedOrNull(value) && !utility.isEmpty(value)) {
        this.nextValue = value;
        this.getRequiredInputElements(); // use to check validations on component
      }
    } catch (error) {
      this.showSpinner = false;
      console.error("Error in nextEvent of Expedite Benefits Page" + error);
    }
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

  @track modValue;
  @track appId;
  @track objValue;
  @track nextValue;
  @track allowSaveValue;
  @track applicationWrap = {};
  @track MetaDataListParent;
  @track hasSaveValidationError = false;
  @track responseOptions = getYesNoOptions();
  @track toastErrorText;
  @track trueValue = true;
  @track showSpinner = false;
  @track openLearnMoreModel = false;
  @track reference = this;
  @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
   

  label = {
    sspLearnMoreLink,
    sspLearnMoreAlternate,
    sspTheQuestionsBelow,
    sspLiquidResources,
    sspGrossIncome,
    sspFarmWorker,
    sspShelterExpenses,
    toastErrorText,
    sspLearnMoreModalContent,
    sspShelterExpensesHelpContent
  };

  customLabel = {
    sspYes,
    sspNo
  };

  /**
   * @function : connectedCallback.
   * @description : This function is fetch the MetaData values on Load.
   */
  connectedCallback () {
    try {
      this.showHelpContentData("SSP_APP_ExpeditedSNAP");
      this.showSpinner = true;
      const fieldEntityNameList = [];
      fieldEntityNameList.push(
        "HouseholdTotalMonthlyGrossIncAmount__c,SSP_Application__c"
      );
      fieldEntityNameList.push(
        "HouseholdTotalMonthlyCashSavingAmount__c,SSP_Application__c"
      );
      fieldEntityNameList.push(
        "HasShelterExpExceedIncomeResourcesToggle__c,SSP_Application__c"
      );
      fieldEntityNameList.push(
        "IsDestituteFarmOrMigrantHouseholdToggle__c,SSP_Application__c"
      );
      this.getMetadataDetails(
        fieldEntityNameList,
        null,
        "SSP_APP_ExpeditedSNAP"
      );
      this.showSpinner = false;
      const expediteSnap = new CustomEvent(
        apConstants.events.updateExpediteHeader,
        {
          bubbles: true,
          composed: true,
          detail: {
            header: sspExpediteSnapBenefit
          }
        }
      );
      this.dispatchEvent(expediteSnap);
    } catch (error) {
      console.error(
        "Error occurred in Expedite Benefits page while fetching the MetaData" +
          error
      );
    }
  }
  /**
   * @function - renderedCallback
   * @description - This method is used to called whenever there is track variable changing.
   */
  renderedCallback () {
    try {
      const sectionReference = this.template.querySelector(
        ".ssp-learnMoreLink"
      );

      if (sectionReference) {
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        sectionReference.innerHTML = this.modValue.HelpModal__c;
      }
    } catch (error) {
      console.error("Error in renderedCallback", error);
    }
  }

  /**
   * @function : fetchAppData.
   * @description : Function used to fetch to Application Record data related to Expedite SNAP Benefits.
   * @param {string} appId - Application id.
   */
  fetchAppData = appId => {
    try {
      this.showSpinner = true;
      fetchApplication({
        sApplicationID: appId
      })
        .then(result => {
          const objAppData = result.mapResponse.objApplicationWrap;
          this.applicationWrap = objAppData;
          this.showSpinner = false;
        })
        .catch(error => {
          console.error(
            "Error in Expedite Benefit Page while Fetching the Application Record" +
              error
          );
          this.showSpinner = false;
        });
    } catch (error) {
      console.error(
        "Error occurred in Expedite Benefits page while fetching the Application Record " +
          error
      );
      this.showSpinner = false;
    }
  };

  /*
   * @function : getRequiredInputElements
   * @description : This method get the input elements required for validation.
   */
  getRequiredInputElements = () => {
    try {
      const elem = this.template.querySelectorAll(".ssp-applicationInputs");
      this.templateInputsValue = elem;
    } catch (error) {
      this.showSpinner=false;
      console.error(
        "Error in getRequiredInputElements of Expedite Benefits Page" + error
      );
    }
  };

  /**
   * @function 	: saveData.
   * @description : This function is used to update the Application Data with the User Provided values.
   * */
  saveData = () => {
    try {
      const objApplication = {};
      if (!utility.isUndefinedOrNull(this.allowSaveValue)) {
        const jsonObjApp = JSON.parse(this.allowSaveValue);
        objApplication.sApplicationId = this.appId;
        objApplication.sCashSavingAmount = jsonObjApp.sCashSavingAmount;
        objApplication.sGrossIncAmount = jsonObjApp.sGrossIncAmount;
        objApplication.bDestituteFarmOrMigrantHouseholdToggle =
          jsonObjApp.sIsDestituteFarmOrMigrantHouseholdToggle;
        objApplication.bShelterExpExceedIncomeResourcesToggle =
          jsonObjApp.sHasShelterExpExceedingIncAndResources;

        updateApplication({
          sApplicationWrapper: JSON.stringify(objApplication)
        })
          .then(() => {
            this.saveCompleted = true;
          })
          .catch(error => {
            console.error(
              "Error in Expedited SNAP Benefit Page while updating the Application Record" +
                error
            );
            this.showSpinner = false;
          });
      }
    } catch (error) {
      console.error("Error in saveData of Expedite Benefits Page" + error);
      this.showSpinner = false;
    }
  };

  /**
   * @function : displayLearnMoreModelMethod
   * @description : Used to open learn more modal.
   * @param {object} event - Js event.
   */
  displayLearnMoreModelMethod = event => {
    if (
      event.keyCode === apConstants.learnMoreModal.enterKeyCode ||
      event.type === apConstants.learnMoreModal.clickLearn
    ) {
      this.openLearnMoreModel = true;
    }
  };

  /**
   * @function : hideLearnMoreModelMethod
   * @description : Used to hide learn more modal.
   */
  hideLearnMoreModelMethod = () => {
    this.openLearnMoreModel = false;
    this.openLearnMoreModel = "";
  };

    /**
    * @function : constructRenderingMap
    * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
    * @param {string} appPrograms - Application level programs.
    * @param {string} metaValue - Entity mapping data.
    */
     constructRenderingMap = (appPrograms, metaValue) => {
        try{
            if (!utility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                const { securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                    this.isNotAccessible = false;
                }
                else{
                  this.isNotAccessible = securityMatrix.screenPermission === apConstants.permission.notAccessible;
                }
                if (this.isNotAccessible) {
                    this.showAccessDeniedComponent = true;
                }
                if (securityMatrix && securityMatrix.hasOwnProperty("screenPermission") && securityMatrix.screenPermission) {
                  this.isReadOnlyUser = securityMatrix.screenPermission === apConstants.permission.readOnly;
                }
            }
        } catch (error) {
            this.isNotAccessible = false;
            console.error(
                              "Error in constructRenderingMap", error
                        );
        }
    }
}
