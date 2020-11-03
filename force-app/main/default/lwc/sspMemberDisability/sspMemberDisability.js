/**
 * Name : SspMemberDisability.
 * Description : To add details about house hold members.
 * Author : Saurabh Rathi, Shivam Tiwari, Sanchita Tibrewala.
 * Date : 12/17/2019.
 **/
import { api, track, wire } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import { formatLabels, getYesNoOptions } from "c/sspUtility";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import BENEFIT_TYPE_CODE from "@salesforce/schema/SSP_Member__c.BenefitTypeCode__c";
import DISABILITY_PERMANENT_TEMPORARY from "@salesforce/schema/SSP_Member__c.DisabilityStatus__c";
import constants from "c/sspConstants";
import sspUtility from "c/sspUtility";
import fetchInformation from "@salesforce/apex/SSP_MemberDisabilityController.fetchDisabilityInformation";
import saveDisabilityInformation from "@salesforce/apex/SSP_MemberDisabilityController.saveDisabilityInformation";
import receivingBenefitsQuestion from "@salesforce/label/c.SSP_ReceivingBenefitsQuestion";
import disabilityScreenText from "@salesforce/label/c.SSP_DisabilityScreenText";
import permanentDisabilityQuestion from "@salesforce/label/c.SSP_PermanentDisabilityQuestion";
import renalDiseaseQuestion from "@salesforce/label/c.SSP_RenalDiseaseQuestion";
import cookHerselfQuestion from "@salesforce/label/c.SSP_CookHerselfQuestion";
import childCareQuestion from "@salesforce/label/c.SSP_ChildCareQuestion";
import himself from "@salesforce/label/c.SSP_Himself";
import her from "@salesforce/label/c.SSP_Her";
import herself from "@salesforce/label/c.SSP_Herself";
import him from "@salesforce/label/c.SSP_Him";
import blindness from "@salesforce/label/c.SSP_blindness";
import disability from "@salesforce/label/c.SSP_Disability"
import sspDisabilityInformationVerified from "@salesforce/label/c.sspDisabilityInformationVerified";
import sspPageInformationVerified from "@salesforce/label/c.SSP_PageInfoVerifiedHouseholdMember";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import { refreshApex } from "@salesforce/apex";

const unicorn0 = /\{0\}/g;

export default class SspMemberDisability extends BaseNavFlowPage {
                   @api memberId;
                   @api applicationId;
                   @api screenId =
                       constants.memberDisability.memberDisabilityScreenId;
                   @api individualRecordTypeId;
                   @track memberFullName = "";
                   @track benefitTypeValues;
                   @track disabilityPermanentTemporary;
                   @track memberDisabilityInformation = {};
                   @track appliedProgram;
                   @track MetaDataListParent;
                   @track permanentDisabilityQuestion = false;
                   @track wiredDataForRefresh;
                   @track fieldMeta;
                   @track memberDisabilityVerification = false;
                   @track pageName;                   
                   @track individualIdForPicklist; //CR Changes end -1189                   
                   @track buyCookDisabled = false; 
                   @track label = {
                       receivingBenefitsQuestion,
                       disabilityScreenText,
                       renalDiseaseQuestion,
                       cookHerselfQuestion,
                       childCareQuestion,
                       permanentDisabilityQuestion,
                       sspDisabilityInformationVerified,
                       sspPageInformationVerified,
                       startBenefitsAppCallNumber
                   };
                   @track isNotAccessible = true; //CD2 2.5 Security Role Matrix.
                   @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
                   callUsAt = `tel:${this.label.startBenefitsAppCallNumber}`;
                   toggleOptions = getYesNoOptions();

                   /**
                    * @function - retMemberDisabilityInformationExpr().
                    * @description - Getter method to check if member's disability details are retrieved from the system.
                    */
                   get retMemberDisabilityInformationExpr () {
                       try {
                           if (this.isNotAccessible) {//CD2 2.5 Security Role Matrix.
                               return false;
                           }
                           if (
                               this.memberDisabilityInformation !== undefined &&
                               this.memberDisabilityInformation !== null
                           ) {
                               return true;
                           }
                           return false;
                       } catch (e) {
                           console.error(
                               "Error in retMemberDisabilityInformationExpr of Member Disability page",
                               e
                           );
                       }
                       return false;
                   }

                   get isBlindnessScreen () {
                       return this.screenId ===
                           constants.memberDisability.memberBlindnessScreenId
                           ? true
                           : false;
                   }

                   /**
                    * @function - benefitTypeCodeValue().
                    * @description - Getter method for benefit type codes.
                    */
                   get benefitTypeCodeValue () {
                       return (
                           this.memberDisabilityInformation.benefitTypeCode ||
                           []
                       );
                   }
                   set benefitTypeCodeValue (value) {
                       try {
                           this.memberDisabilityInformation.benefitTypeCode = value;
                       } catch (error) {
                           console.error(
                               "Error in benefitTypeCodeValue of Member Disability page",
                               error
                           );
                       }
                   }

                   /**
                    * @function - showReceivingBenefitsQuestion().
                    * @description - Getter method for ReceivingBenefitsQuestion field question.
                    */
                   get showReceivingBenefitsQuestion () {
                       const eligibleProgram =
                           constants.memberDisability
                               .showReceivingBenefitsProgram;
                       return this.checkQuestionEligibility(eligibleProgram);
                   }

                   /**
                    * @function - showRenalDiseaseQuestion().
                    * @description - Getter method for RenalDiseaseQuestion field question.
                    */
                   get showRenalDiseaseQuestion () {
                       const eligibleProgram =
                           constants.memberDisability.showRenalDiseaseProgram;
                       return this.checkQuestionEligibility(eligibleProgram);
                   }

                   /**
                    * @function - showChildCareQuestion().
                    * @description - Getter method for ChildCareQuestion field question.
                    */
                   get showChildCareQuestion () {
                       const eligibleProgram =
                           constants.fieldApiIncomeDetails.showChildCareRecords;
                       return this.checkQuestionEligibility(eligibleProgram);
                   }

                   /**
                    * @function - showPermanentDisabilityQuestion().
                    * @description - Getter and setter methods for PermanentDisabilityQuestion field question.
                    */
                   get showPermanentDisabilityQuestion () {
                       const eligibleProgram =
                           constants.fieldApiIncomeDetails.showChildCareRecords;
                       return (
                           this.permanentDisabilityQuestion &&
                           this.checkQuestionEligibility(eligibleProgram)
                       );
                   }
                   set showPermanentDisabilityQuestion (value) {
                       try {
                           this.permanentDisabilityQuestion = value;
                       } catch (error) {
                           console.error(
                               "Error in showPermanentDisabilityQuestion of Member Disability page",
                               error
                           );
                       }
                   }
                    @api
                    get pageToLoad () {
                        return this.pageName;
                    }
                    set pageToLoad (value) {
                        if (value) {
                        this.pageName = value;

                        }
                    }

                   /**
                    * @function - showCookHerselfQuestion().
                    * @description - Getter method for CookHerselfQuestion field question.
                    */
                   get showCookHerselfQuestion () {
                       const eligible = this.checkQuestionEligibility(
                           constants.sspExpenseFields.showSnapRecords
                       );
                       return eligible &&
                           this.memberDisabilityInformation.age >= 60
                           ? true
                           : false;
                   }

                   /**
                    * @function - MetadataList().
                    * @description - MetadataList getter method for framework.
                    *
                    */
                   @api
                   get MetadataList () {
                       return this.MetaDataListParent;
                   }
                   /**
                    * @function - MetadataList().
                    * @description - Next Event setter method for framework.
                    * @param {string} value - Setter for MetadataList framework property.
                    */
                   set MetadataList (value) {
                       try {
                           if (value) {
                               this.MetaDataListParent = value;
                               //CD2 2.5	Security Role Matrix and Program Access.                
                               if (Object.keys(value).length > 0) {
                                   this.constructRenderingMap(null, value);
                               }
                           }
                       } catch (error) {
                           console.error("Error in nextEvent", error);
                       }
                   }

                   /**
                    * @function - nextEvent().
                    * @description - Next Event getter method for framework.
                    */
                   @api
                   get nextEvent () {
                       return this.nextValue;
                   }
                   /**
                    * @function - nextEvent().
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
                           console.error("Error in nextEvent", e);
                       }
                   }

                   /**
                    * @function - allowSaveData().
                    * @description - This method validates the input data and then saves it.
                    */
                   @api
                   get allowSaveData () {
                       return this.allowSaveValue;
                   }
                   set allowSaveData (value) {
                       try {
                           if (value) {
                               this.allowSaveValue = this.createWrapperObject(
                                   value
                               );
                               this.saveMemberDisabilityData(
                                   this.allowSaveValue
                               );
                           }
                       } catch (error) {
                           console.error("Error in allowSaveData", error);
                       }
                   }

                   /**
                    * @function - objectInfo.
                    * @description - This method is used to get INDIVIDUAL record type for SSP Member.
                    *
                    */
                   @wire(getObjectInfo, { objectApiName: SSP_MEMBER })
                   objectInfo ({ error, data }) {
                       try {
                           if (data) {
                               const RecordTypesInfo =
                                   constants.sspMemberConstants.RecordTypesInfo;
                               const individual =
                                   constants.sspMemberConstants
                                       .IndividualRecordTypeName;
                               const recordTypeInformation =
                                   data[RecordTypesInfo];
                               this.individualRecordTypeId = Object.keys(
                                   recordTypeInformation
                               ).find(
                                   recTypeInfo =>
                                       recordTypeInformation[recTypeInfo]
                                           .name === individual
                               );
                           } else if (error) {
                               console.error(
                                   "Error occurred while fetching record type in Not a US citizen screen" +
                                       error
                               );
                           }
                       } catch (error) {
                           console.error(
                               "Error occurred while fetching record type in Not a US citizen screen" +
                                   error
                           );
                       }
                   }

                   /**
                    * @function - benefitTypePickListValues().
                    * @description - This method is used to get picklist values for benefit types field.
                    *
                    */
                   @wire(getPicklistValues, {
                       recordTypeId: "$individualIdForPicklist", //CR Changes end -1189
                       fieldApiName: BENEFIT_TYPE_CODE
                   })
                   benefitTypePickListValues ({ data, error }) {
                       try {
                           if (data) {
                               this.benefitTypeValues = data.values;
                               this.filterPicklistValue(); //CR Changes end -1189
                           }
                           if (error) {
                               console.error(
                                   `Error Occurred while fetching benefitTypePickListValues picklist of Member Disability page ${error}` +
                                       JSON.stringify(error)
                               );
                           }
                       } catch (error) {
                           console.error(
                               "Error in wire call benefitTypePickListValues:",
                               error
                           );
                       }
                   }

                   /**
                    * @function - disabilityPermanentTemporaryPickListValues().
                    * @description - This method is used to get picklist values for Disability type field.
                    *
                    */
                   @wire(getPicklistValues, {
                       recordTypeId: "$individualRecordTypeId",
                       fieldApiName: DISABILITY_PERMANENT_TEMPORARY
                   })
                   disabilityPermanentTemporaryPickListValues ({ data, error }) {
                       try {
                           if (data) {
                               this.disabilityPermanentTemporary = data.values;
                           }
                           if (error) {
                               console.error(
                                   `Error Occurred while fetching benefitTypePickListValues picklist of Member Disability page ${error}` +
                                       JSON.stringify(error)
                               );
                           }
                       } catch (error) {
                           console.error(
                               "Error in wire call disabilityPermanentTemporaryPickListValues:",
                               error
                           );
                       }
                   }

                   /**
                    * @function - memberDisabilityValues().
                    * @description - This method is used to call apex method to get disability details of member.
                    * @param {JSON} value - Result of "fetchInformation" method call.
                    */
                   @wire(fetchInformation, {
                       memberId: "$memberId",
                       applicationId: "$applicationId",
                       isBlindnessScreen: "$isBlindnessScreen"
                   })
                   memberDisabilityValues (value) {
                       this.wiredDataForRefresh = value;
                       const { data, error } = value;
                       try {
                           if (data) {
                               this.memberDisabilityInformation = Object.assign(
                                   this.memberDisabilityInformation,
                                   data.mapResponse.memberWrapper
                               );
                               this.memberFullName = this.memberDisabilityInformation.memberFullName;
                               if (!sspUtility.isUndefinedOrNull(this.memberDisabilityInformation.programsApplied)) {
                                    this.appliedProgram = this.memberDisabilityInformation.programsApplied.split(
                                        ";"
                                    );
                               }

                               this.updateLabel();
                               if (this.isBlindnessScreen) {
                                   this.updateBlindnessLabels();
                                   this.memberDisabilityVerification = this.memberDisabilityInformation.isBlindnessVerified;
                               }
                               else if (!this.isBlindnessScreen) {
                                    this.memberDisabilityVerification = this.memberDisabilityInformation.isDisabilityVerified;
                    this.buyCookDisabled= this.memberDisabilityInformation.isDisabilityVerified && (this.memberDisabilityInformation.unableToBuyCookForSelf == constants.toggleFieldValue.yes || this.memberDisabilityInformation.unableToBuyCookForSelf == constants.toggleFieldValue.no)
                               }
                               this.showPermanentDisabilityQuestion =
                                   this.memberDisabilityInformation
                                       .parentUnableToCareForChild ===
                                   constants.toggleFieldValue.yes;
                                   this.individualIdForPicklist = this.individualRecordTypeId; //CR Changes end -1189

                           }
                           if (error) {
                               console.error(
                                   `Error Occurred while fetching member disability data in Member Disability page ${error.message}`
                               );
                           }
                       } catch (error) {
                           console.error(
                               "Error in wire call fetchInformation:",
                               error
                           );
                       }
                   }

                   /**
                    * @function : connectedCallback
                    * @description : This method is called when html is attached to the component.
                    */
                   connectedCallback () {
                       try {
                           this.label.sspPageInformationVerified = formatLabels(
                               this.label.sspPageInformationVerified,
                               [this.pageName]
                           );
                           this.fieldMeta = this.isBlindnessScreen
                               ? constants.blindnessMeta
                               : constants.disabilityMeta;
                           this.fieldMapping();
                           if (this.isBlindnessScreen) {
                               this.blindnessLabelUpdate();
                           }
                       } catch (error) {
                           console.error("Error in connectedCallback", error);
                       }
                   }

                   /**
                    * @function : updateBlindnessLabels
                    * @description : Updating the labels for blindness screen.
                    */
                   updateBlindnessLabels = () => {
                       try {
                           this.label.permanentDisabilityQuestion = this.label.permanentDisabilityQuestion.replace(
                               unicorn0,
                               this.memberFullName
                           );
                           this.label.permanentDisabilityQuestion = this.label.permanentDisabilityQuestion.replace(
                               disability.toLowerCase(),
                               blindness.toLowerCase()
                           );
                           this.label.sspDisabilityInformationVerified = this.label.sspDisabilityInformationVerified.replace(
                                disability,
                                blindness
                            );
                           this.label.childCareQuestion = this.label.childCareQuestion.replace(
                               unicorn0,
                               this.memberFullName
                           );
                           this.label.childCareQuestion = this.label.childCareQuestion.replace(
                               disability.toLowerCase(),
                               blindness.toLowerCase()
                           );
                       } catch (error) {
                           console.error(
                               "Error in updateBlindnessLabels",
                               error
                           );
                       }
                   };

                   /**
                    * @function : saveMemberDisabilityData
                    * @description : This method is used to save disability information.
                    * @param {string} disabilityDetails - Disability information.
                    */
                   saveMemberDisabilityData = disabilityDetails => {
                       try {
                           saveDisabilityInformation({
                               memberId: this.memberId,
                               memberDisabilityInfo: disabilityDetails,
                               isBlindnessScreen: this.isBlindnessScreen
                           }).then(() => {
                               this.saveCompleted = true;
                               return refreshApex(this.wiredDataForRefresh);
                           });
                       } catch (e) {
                           console.error(
                               "Error in saveMemberDisabilityData of Member Disability page",
                               e
                           );
                       }
                   };

                   /**
                    * @function : blindnessLabelUpdate
                    * @description : Updating the labels for blindness screen.
                    */
                   blindnessLabelUpdate = () => {
                       try {
                           this.label.disabilityScreenText = this.label.disabilityScreenText.replace(
                               disability.toLowerCase(),
                               blindness.toLowerCase()
                           );
                       } catch (error) {
                           console.error(
                               "Error in blindnessLabelUpdate",
                               error
                           );
                       }
                   };

                   /**
                    * @function : checkInputValidation
                    * @description : Framework method to check input validation.
                    */
                   checkInputValidation = () => {
                       try {
                           const disabilityInfo = Array.from(
                               this.template.querySelectorAll(
                                   ".ssp-applicationInputs"
                               )
                           );
                           this.templateInputsValue = disabilityInfo;
                           disabilityInfo
                               .map(element => element.ErrorMessages())
                               .reduce(
                                   (total, value) =>
                                       total || (value && value.length > 0),
                                   false
                               );

                           Array.from(
                               this.template.querySelectorAll(
                                   ".ssp-applicationInputs"
                               )
                           );
                       } catch (e) {
                           console.error(
                               "Error in checkInputValidation of Member Disability page",
                               e
                           );
                       }
                   };

                   /**
                    * @function : fieldMapping
                    * @description : This method is used for mapping the field.
                    */
                   fieldMapping = () => {
                       try {
                           const fieldEntityNameList = Object.values(
                               this.fieldMeta
                           ).map(
                               value =>
                                   `${value},${constants.sspObjectAPI.SSP_Member__c}`
                           );
                           this.getMetadataDetails(
                               fieldEntityNameList,
                               null,
                               this.screenId
                           );
                       } catch (error) {
                           console.error("Error in fieldMapping", error);
                       }
                   };

                   /**
                    * @function : updateLabel
                    * @description : This method is used for updating  the data in the label.
                    */
                   updateLabel = () => {
                       try {
                           this.label.receivingBenefitsQuestion = formatLabels(
                               this.label.receivingBenefitsQuestion,
                               [this.memberFullName]
                           );
                           this.label.renalDiseaseQuestion = formatLabels(
                               this.label.renalDiseaseQuestion,
                               [this.memberFullName]
                           );

                           this.label.cookHerselfQuestion = formatLabels(
                               this.label.cookHerselfQuestion,
                               [this.memberFullName]
                           );
                           this.label.childCareQuestion = formatLabels(
                               this.label.childCareQuestion,
                               [this.memberFullName]
                           );
                           this.label.permanentDisabilityQuestion = formatLabels(
                               this.label.permanentDisabilityQuestion,
                               [this.memberFullName]
                           );
                           if (
                               this.memberDisabilityInformation.genderCode !==
                               constants.femaleGenderCode
                           ) {
                               this.label.cookHerselfQuestion = this.label.cookHerselfQuestion.replace(
                                   herself,
                                   himself
                               );
                               this.label.childCareQuestion = this.label.childCareQuestion.replace(
                                   her,
                                   him
                               );
                           }
                       } catch (error) {
                           console.error("Error in updateLabel", error);
                       }
                   };

                   /**
                    * @function handleChildCareQuestion
                    * @description : Handles change in child care question.
                    * @param {object} event - This parameter provides the updated value.
                    */
                   handleChildCareQuestion = event => {
                       try {
                           this.childCareValue = event.detail.value;
                           const value =
                               event.detail.value ===
                               constants.toggleFieldValue.yes;
                           this.showPermanentDisabilityQuestion = value;
                       } catch (error) {
                           console.error(
                               "Error in handleChildCareQuestion:",
                               error
                           );
                       }
                   };

                   /**
                    * @function : createWrapperObject
                    * @description : This method is used to create the updated wrapper object for data saving.
                    * @param {*} value -  This parameter provides the updated values for wrapper.
                    */
                   createWrapperObject = value => {
                       try {
                           const objWrapValue = JSON.parse(value);
                           return JSON.stringify(objWrapValue);
                       } catch (error) {
                           console.error(
                               "Error in createWrapperObject:",
                               error
                           );
                       }
                   };

                   /**
                    * @function handleChildCareQuestion
                    * @description : checks the questions visibility based on the program.
                    * @param {object} eligibleProgram - This parameter provides the updated value.
                    */
                   checkQuestionEligibility = eligibleProgram => {
                       try {
                           if (this.appliedProgram) {
                               return this.appliedProgram.some(function (item) {
                                   return eligibleProgram.includes(item);
                               });
                           }
                       } catch (error) {
                           console.error(
                               "Error in checkQuestionEligibility:",
                               error
                           );
                       }
                   };

                   /**
                    * @function handleReceivingBenefitsQuestion
                    * @description : checks the questions visibility based on the program.
                    * @param {object} event - This parameter provides the updated value.
                    */
                   handleReceivingBenefitsQuestion = event => {
                       try {
                           this.benefits = event.detail.value;
                           this.memberDisabilityInformation.benefitTypeCode =
                               event.detail.value;
                       } catch (error) {
                           console.error(
                               "Error in handleReceivingBenefitsQuestion:",
                               error
                           );
                       }
                   };

                    /**
                   * @function : constructRenderingMap
                   * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
                   * @param {string} appPrograms - Application level programs.
                   * @param {string} metaValue - Entity mapping data.
                   */
                   constructRenderingMap = (appPrograms, metaValue) => {
                      try{
                          if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
                              const { securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                              if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission){
                                  this.isNotAccessible = false
                              }
                              else{
                                  this.isNotAccessible = securityMatrix.screenPermission === constants.permission.notAccessible;
                              }
                              if (this.isNotAccessible) {
                                  this.showAccessDeniedComponent = true;
                              }
                          }
                      } catch (error) {
                        console.error(
                              "Error in highestEducation.constructRenderingMap", error
                        );
                      }
                    }

                    
                    filterPicklistValue (){
                     
                        //CR Changes -1189
                        if(!sspUtility.isUndefinedOrNull(this.benefitTypeValues) && !sspUtility.isUndefinedOrNull(this.memberDisabilityInformation) && !sspUtility.isUndefinedOrNull(this.memberDisabilityInformation.programsApplied)){
                          
                         if(this.screenId===constants.memberDisability.memberDisabilityScreenId){
                             if(this.memberDisabilityInformation.programsApplied){
                                 if(this.memberDisabilityInformation.programsApplied.includes(constants.programs.MEDICAID) || this.memberDisabilityInformation.programsApplied.includes(constants.programs.SS)||this.memberDisabilityInformation.programsApplied.includes(constants.programs.DSNAP) || this.memberDisabilityInformation.programsApplied.includes(constants.programs.CCAP) || this.memberDisabilityInformation.programsApplied.includes(constants.programs.KHIPP)){
                        if (
                            !this.memberDisabilityInformation.programsApplied.includes(
                                constants.programs.SNAP
                            ) &&
                            !this.memberDisabilityInformation.programsApplied.includes(
                                constants.programs.KTAP
                            )
                        ) {
                                     let tempArr =[];
                                         tempArr =  this.benefitTypeValues.filter(
                                          opt => opt.value !==  constants.pensionBasedDisability
                                      );
                                      this.benefitTypeValues=tempArr;
                                    }
                                 }
                             }else{
                                 let tempArr =[];
                                 tempArr =  this.benefitTypeValues.filter(
                                  opt => opt.value !== constants.pensionBasedDisability
                              );
                              this.benefitTypeValues=tempArr; 
                             }
                             
                            }
                            else if(this.screenId===constants.memberDisability.memberBlindnessScreenId){
                                 let tempArr =[];
                                     tempArr =  this.benefitTypeValues.filter(
                                      opt => opt.value !==  constants.pensionBasedDisability
                                  );
                                  this.benefitTypeValues=tempArr;
                             }
                          
                          //CR Changes end -1189
                        }
                        
         }
               }