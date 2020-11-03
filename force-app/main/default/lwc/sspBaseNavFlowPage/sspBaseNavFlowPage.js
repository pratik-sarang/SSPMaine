/*
 * Component name  : sspBaseNavFlowPage
 * @description    : Base component to show the page name, handle validations.
 */
import { track, api } from "lwc";
import getValidationMessages from "@salesforce/apex/GenericValidationController.getMetadataList";
import BaseComponent from "c/sspBaseComponent";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import updateReviewRequiredFlow from "@salesforce/apex/NavFlowManager.updateReviewRequiredFlow";
//import checkSections from "@salesforce/apex/SectionRenderCheck.sectionChecker";
import reviewRequiredRules from "@salesforce/apex/SSP_RulesEngine.getRRTriggerRules";
import helpContentUtility from "@salesforce/apex/NavFlowController.fetchHelpContent";

export default class SspBaseNavFlowPage extends BaseComponent {
                   @track pageToLoad = {};
                   @track pageDisplayName = "";
                   @track navAction = "";
                   @api MetadataList = [];
                    @api entityMappingWrapper; //CD2 2.5 Security Role Matrix and Program Access.
                   @track action = "";
                   @track isCalledFromBrowser = {};
                   @api allowSaveData;
                   @track memberId;
                   @track currentFlowName;
                   @api inputTempValue;
                   @api renderSections;
                   @api screenDirtyCheck = "test1";
                   @api updCallDriver;
                   @api noError;
                   @api saveCompletedValue;
                   @api modalContentValue;
                   @track reviewRequiredListValue = [];
                   self = this;
                   reviewRequiredListValueVar = [];
                   /**
                    * @function : templateInputsValue
                    * @description :This method is used to handle input values.
                    */
                   @api
                   get templateInputsValue () {
                       return this.inputTempValue;
                   }
                   set templateInputsValue (value) {
                       try {
                           if (value) {
                               this.inputTempValue = value;
                               const inputTempValue = new CustomEvent("inputtempval", {
                                       bubbles: true,
                                       composed: true,
                                       detail: {
                                           tempInput: value
                                       }
                                   });
                               this.dispatchEvent(inputTempValue);
                               this.templateInputsValue = null;
                           }
                       } catch (error) {
                           console.error("Error in templateInputsValue", error);
                       }
                   }

                   /**
                    * @function : saveCompleted
                    * @description :This method is used to handle save complete.
                    */
                   @api
                   get saveCompleted () {
                       return this.saveCompletedValue;
                   }
                   set saveCompleted (value) {
                       try {
                           this.saveCompletedValue = value;
                           if (value === true) {
                               const doneSaving = new CustomEvent("donesaving", {
                                       bubbles: true,
                                       composed: true,
                                       detail: {
                                           doneSaving: true
                                       }
                                   });
                               this.dispatchEvent(doneSaving);
                           }
                       } catch (error) {
                           console.error("Error in saveCompleted", error);
                       }
                   }

                    /**
                    * @function constructVisibilityMatrix
                    * @description To construct visibility matrix - CD2 2.5 Security Role Matrix and Program Access.
                    * @param {object} appProgramList - List of application level program codes.
                    * @author Shrikant Raut
                    */
                    @api
                    constructVisibilityMatrix = (appProgramList) => {
                        const { applicableProgramSet, metadataList: entityMap, renderingMap, securityMatrix } = this.entityMappingWrapper;                        
                        const applicablePrograms = (applicableProgramSet != null && applicableProgramSet != undefined) ? applicableProgramSet.filter(program => (appProgramList != null && appProgramList != undefined && appProgramList.includes(program))) : [];
                        Object.keys(entityMap).forEach(key => {
                            const fieldAPI = key.split(",")[0];
                            const fieldPrograms = renderingMap[fieldAPI].programs;
                            renderingMap[fieldAPI].renderElement = (fieldPrograms && fieldPrograms.some(program => applicablePrograms.includes(program)));
                        });
                        return { renderingMap, securityMatrix };
                    }

                   /**
                    * @function : connectedCallback
                    * @description :This method is used to call when the LWC DOM loads.
                    */
                   connectedCallback () {
                       try {
                           this.updCallDriver = false;
                           this.self = this;
                       } catch (error) {
                           console.error("Error in connectedCallback", error);
                       }
                   }

                   /**
                    * @function : checkValidations
                    * @description :This method is used to call when the LWC DOM loads.
                    * @param {inputValue} inputValue - Input value pass as argument.
                    */
                   @api
                   checkValidations (inputValue) {
                       try {
                           let AllowSave = true;
                           let errList = [];
                           const allowSaveArr = [];
                           for (let i = 0; i < inputValue.length; i++) {
                               if (
                                   inputValue[i].entityName !== null &&
                                   inputValue[i].fieldName !== null &&
                                   inputValue[i].entityName !== undefined
                               ) {
                                   errList = inputValue[i].ErrorMessages();
                                   if (errList != null && errList.length > 0) {
                                       AllowSave = false;
                                   } else {
                                       AllowSave = true;
                                   }
                                   allowSaveArr.push(AllowSave);
                               }
                           }

                           if (allowSaveArr.includes(false)) {
                               this.noError = false;
                           } else {
                               this.noError = true;
                           }
                       } catch (error) {
                           console.error("Error in checkValidations", error);
                       }
                   }

                   /**
                    * @function : getMetadataDetails
                    * @description :This method is used to handle meta data details.
                    * @param {object} fieldEntityNameList - Field entity name list.
                    * @param {object} inputValue - Input value.
                    * @param {string} screenNameValue - Screen name.
                    */
                   @api
                   getMetadataDetails (fieldEntityNameList, inputValue, screenNameValue) {
                       try {
                           let fieldEntityConcat = [];
                           if (inputValue !== null && this.inputValue !== "") {
                               for (let i = 0; i < inputValue.length; i++) {
                                   fieldEntityConcat.push(
                                       inputValue[i].fieldName + "," + inputValue[i].entityName
                                   );
                               }
                           } else {
                               fieldEntityConcat = fieldEntityNameList;
                           }
                           getValidationMessages({
                               FieldEntityConcatList: fieldEntityConcat,
                               screenName: screenNameValue
                           })
                               .then(result => {
                                   
                                    /**CD2 2.5 Security Role Matrix and Program Access. */
                                   const metadataMap = {};
                                   if(result != null && result != undefined){
                                       this.entityMappingWrapper = result; 
                                       const { metadataList: entityMap, securityMatrix: { screenPermission } } = result;
                                       if (entityMap != null && entityMap != undefined){
                                           Object.keys(entityMap).forEach(key => {
                                               const metadata = entityMap[key];
                                               metadata.isDisabled = screenPermission != null && screenPermission != undefined && screenPermission == "ReadOnly";
                                               metadataMap[key] = metadata;                                               
                                           });
                                       }

                                   }
                                                                      
                                   this.MetadataList = metadataMap != null && metadataMap != undefined && Object.keys(metadataMap).length > 0 ? metadataMap : result.metadataList;                                   
                                   
                               })
                               .catch(error => {
                                   console.error(
                                       "Error in getValidationMessages",
                                       error
                                   );
                               });
                       } catch (error) {
                           console.error("Error in getMetadataDetails", error);
                       }
                   }

                   /**
                    * @function : showToastMessage
                    * @description :This method is used to show toast message.
                    * @param {string} title - Title of toast.
                    * @param {string} message - Message to show in toast.
                    * @param {string} mode - Type of toast.
                    */
                   showToastMessage = (title, message, mode) => {
                       try {
                           const event = new ShowToastEvent({
                               title: title,
                               message: message,
                               mode: mode,
                               variant: "error"
                           });
                           this.dispatchEvent(event);
                       } catch (error) {
                           console.error("Error in showToastMessage", error);
                       }
                   };

                   /**
                    * @function : executePageActionJS
                    * @description :This method is used to execute the save.
                    */
                   @api
                   executePageActionJS () {
                       try {
                           this.onRecordSaveSuccessHelper();
                       } catch (error) {
                           console.error("Error in executePageActionJS", error);
                       }
                   }

                   /**
                    * @function : validateReviewRequiredRules
                    * @description :This method is used to handle validation.
                    * @param {*} appId -  Gives application id.
                    * @param {*} memberId - Member Id.
                    * @param {*} selectedScreens - Gives the selected screen.
                    * @param {*} sMode - Gives the Mode.
                    */
                    validateReviewRequiredRules (appId, memberId, selectedScreens, sMode) {
                       try {                           
                           reviewRequiredRules({
                               applicationId: appId,
                               memberId: memberId,
                               selectedScreens: selectedScreens,
                               reviewRequiredList: self.reviewRequiredListValueVar,
                               mode : sMode
                           })
                               .then(result => {
                                   this.updCallDriver = true;
                                   self.reviewRequiredListValueVar = [];
                               })
                               .catch(error => {
                                   this.updCallDriver = false;
                                   console.error(
                                       "error " + JSON.stringify(error)
                                   );
                               });
                       } catch (error) {
                           console.error("Error in RR");
                       }

                       /*try {
      const screenValues = [];
      if (inputValue.length > 0) {
        for (let i = 0; i < inputValue.length; i++) {
          if (
            inputValue[i].entityName !== undefined &&
            inputValue[i].entityName !== ""
          ) {
            screenValues.push(
              "{" +
                inputValue[i].entityName +
                "," +
                inputValue[i].fieldName +
                "," +
                inputValue[i].value +
                "}"
            );
          }
        }
      } else {
        this.updCallDriver = true;
      }
      if (
        screenValues !== undefined &&
        screenValues !== "" &&
        screenValues.length > 0
      ) {
        this.updCallDriver = true;
      } else {
        this.updCallDriver = true;
      }
    } catch (error) {
      console.error("Error in validateReviewRequiredRules", error);
    }*/
                   }

                   @api
                   get reviewRequiredList () {
                       return this.reviewRequiredListValue;
                   }
                   set reviewRequiredList (value) {
                       if (value) {
                           this.reviewRequiredListValue = value;
                           self.reviewRequiredListValueVar = value;
                       }
                   }

                   /**
                    * @function : updateIntakeFlowStatus
                    * @description :This method is used to update the intake flow status.
                    * @param {string} applicationId - Application ID.
                    * @param {string} memberId - Member ID.
                    * @param {string} affectedScreens - Screen name.
                    */
                    /*updateIntakeFlowStatus = (applicationId, memberId, affectedScreens) => {
                       try {
                           updateReviewRequiredFlow({
                               applicationId: applicationId,
                               memberId: memberId,
                               affectedScreens: affectedScreens
                           })
                               .then(result => {
                                   this.updCallDriver = true;
                               })
                               .catch(error => {
                                   console.error(
                                       "Error in updateIntakeFlowStatus Promise",
                                       error
                                   );
                               });
                       } catch (error) {
                           console.error(
                               "Error in updateIntakeFlowStatus",
                               error
                           );
                       }
                   };*/

                   /**
                    * @function : renderSectionPage
                    * @description :This method is used to render section page.
                    * @param {string} pageName - Page name.
                    * @param {string} memberId - Member ID.
                    */
                   /*@api
  renderSectionPage (pageName, memberId) {
    try {
      checkSections({
        pageInfoName: pageName,
        memberId: memberId
      })
        .then(result => {
          this.renderSections = result;
        })
        .catch(error => {
          console.error("error in render section " + error);
        });
    } catch (error) {
      console.error("Error in renderSectionPage", error);
    }
  }
 */
                   static isUndefinedOrNull (obj) {
                       return obj === undefined || obj === null;
                   }
                   @api
                   showHelpContentData (screenNameValue) {
                       try {
                           let customLanguage;
                           const currentURL = window.location.href;
                           if (
                               currentURL.indexOf("en_US") === -1 &&
                               currentURL.indexOf("es_US") === -1
                           ) {
                               customLanguage = "en_US";
                           } else if (currentURL.indexOf("en_US") !== -1) {
                               customLanguage = "en_US";
                           } else if (currentURL.indexOf("es_US") !== -1) {
                               customLanguage = "es_US";
                           }

                           helpContentUtility({
                               screenName: screenNameValue,
                               language: customLanguage
                           })
                               .then(response => {
                                   this.modalContentValue = response;
                               })
                               .catch(error => {
                                   this.modalContentValue = "";
                                   console.error("error " + error);
                               });
                       } catch (error) {
                           console.error(
                               "Error calling showHelpContentData method: ",
                               error
                           );
                       }
                   }
               }

const showHelpContent = screenNameValue => helpContentUtility({
    screenName: screenNameValue,
    language: navigator.language
  })
    .then(response => response)
    .catch(error => {
      console.error("error " + error);
      return null;
    });

export { showHelpContent };
