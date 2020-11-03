/*
 * Component Name: sspMedicalEnforcement.
 * Author: Kireeti Gora, Karthik.
 * Description: This screen handle Medical Enforcement Screen.
 * Date: 12/19/2019.
 **/

import { api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import sspTheCabinetText from "@salesforce/label/c.SSP_CabinetForHealthandFamilyServices";
import sspTheCabinetTextKt from "@salesforce/label/c.SSP_CabinetForHealthandFamilyServicesKt";
import sspDoesAgree from "@salesforce/label/c.SSP_DoesApplicantAgreeToCooperate";
import sspDoesAgreeKt from "@salesforce/label/c.SSP_DoesApplicantAgreeToCooperateKt";
import sspReasonAlternate from "@salesforce/label/c.SSP_MedicalSupportReasonAlternate";
import sspChildSupportEnforcementText from "@salesforce/label/c.SSP_ChildSupportEnforcementText";
import sspReasonText from "@salesforce/label/c.SSP_MedicalSupportEnforcementReasonText";
import sspAdditionalInformationText from "@salesforce/label/c.SSP_MedicalSupportEnforcementAdditionalInformationText";
import sspYes from "@salesforce/label/c.SSP_Yes";
import sspNo from "@salesforce/label/c.SSP_No";
import goodCauseCode from "@salesforce/schema/SSP_NoncustodialRelationship__c.GoodCauseCode__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import NON_CUSTODIAL_PARENT_OBJECT from "@salesforce/schema/SSP_NoncustodialRelationship__c";
import getEnforcementDetails from "@salesforce/apex/SSP_MedicalEnforcementController.getMedicalEnforcementDetailsWithId";
import updateEnforcementDetails from "@salesforce/apex/SSP_MedicalEnforcementController.updateNonCustodRecords";
import sspConstants from "c/sspConstants";
import utility,{ formatLabels } from "c/sspUtility";
/* eslint-disable no-console */
/* eslint-disable no-alert */

export default class SspMedicalSupportEnforcement extends baseNavFlowPage {
  @api sspMemberId;
  @api sspApplicationId;
  @api memberName = "";
  @track appliedPrograms = [];
  @track lstPrograms = [];
  @track headOfHouseHoldName = "";
  @track sspTheCabinetText1;
  @track sspTheCabinetText2;
  @track doesAgreeQuestion1;
  @track doesAgreeQuestion2;
  @track showMedicalComments = false;
  @track resultToRefresh;
  @track objResult = {};
  @track
  MetaDataListParent;
  @track sspConstants = sspConstants;
  @track actionValue;
  @track field1;

  @track objValue;
  @track nextValue;
  @track error;
  @track result;
  @track validationFlag;
  @track objParent = {};

  @track goodCauseCodeOptions;
  @track isVisible = false;
  @track showSpinner = false;
  @track applicationPrograms;
  label = {
    sspChildSupportEnforcementText,
    sspReasonAlternate,
    sspReasonText,
    sspAdditionalInformationText,
    sspYes,
    sspNo
  };
  @track responseOptions = [
    {
      label: this.label.sspYes,
      value: this.sspConstants.toggleFieldValue.yes
    },
    {
      label: this.label.sspNo,
      value: this.sspConstants.toggleFieldValue.no
    }
  ];

  @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

  /**
   * @function : nextEvent.
   * @description : The getter/setter is fired on next by frameWork.
   */

  @api
  get nextEvent () {
    return this.nextValue;
  }
  set nextEvent (value) {
    if (value !== undefined && value !== "") {
      this.nextValue = value;
      this.saveData();
    }
  }
  /**
   * @function : MetadataList.
   * @description : The getter/setter is used to fetch metadata list from framework.
   */
  @api
  get MetadataList () {
    return this.MetaDataListParent;
  }
  set MetadataList (value) {
    this.MetaDataListParent = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
      if (Object.keys(value).length > 0){
          this.constructRenderingMap(null, value); 
      }
  }

  /**
   * @function : CallSaveOnValidation.
   * @description : This Method is called when there are no validations from framework.
   */

  @api
  CallSaveOnValidation () {
    try {
      this.handleSave();
    } catch (error) {
      console.error("failed in CallSaveOnValidation " + JSON.stringify(error));
    }
  }

  /**
   * @function : allowSaveData.
   * @description : This attribute holds the boolean indication the data is valid or not.
   */

  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    this.validationFlag = value;
    if (value !== undefined) {
      this.CallSaveOnValidation();
    }
  }
  /**
   * @function : actionReceived
   * @description :this attribute is part of framework.
   */

  @api
  get actionReceived () {
    return this.actionValue;
  }
  set actionReceived (value) {
    this.actionValue = value;
    if (value !== undefined && value !== "") {
      const btnClick = value.split(",")[1];
      const loadValue = value.split(",")[2];
      if (btnClick === "next" && loadValue) {
        this.saveData();
      } else {
        this.onRecordSaveSuccess(this.sspApplicationId);
      }
    }
  }

  /**
   * @function : getObjectInfo
   * @description :this standard method is used to fetch object Information.
   */

  @wire(getObjectInfo, {
    objectApiName: NON_CUSTODIAL_PARENT_OBJECT
  })
  objectInfo;

  /** 
* @function 		: picklistValuesForGoodCauseCodeOptions.    
* @description 	: This method is used to fetch picklist details of goodCauseCodeOptions.
 
* */
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: goodCauseCode
  })
  picklistValuesForGoodCauseCode ({ error, data }) {
    try {
      if (data) {
        this.goodCauseCodeOptions = data.values;
      } else if (error) {
        this.error = error;
      }
    } catch (error) {
      console.error(
        "failed in picklistValuesForGoodCauseCode in Medical Enforcement Page" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function : handleSave
   * @description : This Method calls server to save data.
   */
  handleSave () {
    try {
      if (
        this.objParent.HasChildSupportToggle__c !== undefined &&
        this.objParent.HasChildSupportToggle__c !== "" &&
        this.objParent.HasChildSupportToggle__c !== null
      ) {
        this.objParent[
          this.sspConstants.sspExpenseFields.SSP_Member__c
        ] = this.sspMemberId;
        if (
          this.objParent.HasChildSupportToggle__c ===
          this.sspConstants.toggleFieldValue.yes
        ) {
          // eslint-disable-next-line camelcase
          this.objParent.GoodCauseCode__c = null;
          // eslint-disable-next-line camelcase
          this.objParent.MedicalSupportComments__c = null;
        }
        
        updateEnforcementDetails({
          nonCustodialJSON: JSON.stringify(this.objParent)
        })
          .then(result => {
            this.result = result;
            refreshApex(this.resultToRefresh);
            this.saveCompleted = true;
          })
          .catch(error => {
            this.error = error;
          });
      }
    } catch (error) {
      console.error(
        "failed in handleSave in Medical Enforcement Page" +
          JSON.stringify(error)
      );
    }
  }
  /**
   * @function : connectedCallback
   * @description : This is called on do do init to fetch metadata record details.
   */

  connectedCallback () {
    try {
      
      this.showSpinner = true;
      const fieldEntityNameList = [];
      fieldEntityNameList.push(
        "HasChildSupportToggle__c,SSP_NoncustodialRelationship__c",
        "GoodCauseCode__c,SSP_NoncustodialRelationship__c",
        "MedicalSupportComments__c,SSP_NoncustodialRelationship__c"
      );
      this.getMetadataDetails(
        fieldEntityNameList,
        null,
        "SSP_APP_Details_MedicalSupport"
      );
    } catch (error) {
      console.error(
        "failed in connectedCallback in Medical Enforcement Page",
        JSON.stringify(error)
      );
      
    }
  }
  /**
* @function 		: getEnforcementDetails.
* @description 	: method to fetch required data for screen.
* @param    {string,string}    : - SspMemberId and sspApplicationId.
 
* */

  @wire(getEnforcementDetails, {
    sspApplicationId: "$sspApplicationId",
    sspMemberId: "$sspMemberId"
  })
  getEnforcementRecord (result) {
    
    try {
      if (result.data) {
        
        this.resultToRefresh = result;
        

        if ("nonCustodialRelationshipRecord" in result.data.mapResponse) {
          this.objResult = JSON.parse(
            result.data.mapResponse.nonCustodialRelationshipRecord
          );
          
          this.field1 = this.objResult.HasChildSupportToggle__c;
          
        }
        

        if (this.objResult.Id) {
          if (
            this.objResult.HasChildSupportToggle__c ===
            this.sspConstants.toggleFieldValue.no
          ) {
            this.showMedicalComments = true;
          }
        }
        if ("headOfHousehold" in result.data.mapResponse) {
          const memberHousehold = result.data.mapResponse.headOfHousehold;
          const appHousehold = memberHousehold[0];
          
          if (
            appHousehold !== null &&
            appHousehold !== undefined &&
            appHousehold.Name !== null &&
            appHousehold.Name !== undefined
          ) {
            this.headOfHouseHoldName =
              appHousehold.SSP_Member__r.FirstName__c +
              " " +
              appHousehold.SSP_Member__r.LastName__c;
            const applicationPrograms =
              appHousehold.SSP_Application__r.ProgramsApplied__c;
            this.applicationPrograms = applicationPrograms.split(";").length;
          }
        }
        if ("applicationIndividualPrograms" in result.data.mapResponse) {
          const memberPrograms =
            result.data.mapResponse.applicationIndividualPrograms;
          const appIndividual = memberPrograms[0];
          if (
            appIndividual !== null &&
            appIndividual !== undefined &&
            appIndividual.ProgramsApplied__c !== null &&
            appIndividual.ProgramsApplied__c !== undefined
          ) {
            const programList = appIndividual.ProgramsApplied__c.split(";");
            this.lstPrograms = programList;
            this.appliedPrograms = programList;
            
          }
          /*if (
                        appIndividual !== null &&
                        appIndividual !== undefined &&
                        appIndividual.MedicaidType__c !== null &&
                        appIndividual.MedicaidType__c !==
                        undefined
                    ) {
                        this.appliedPrograms.push(
                            appIndividual.MedicaidType__c
                        );
                    }*/
        }
        this.sspTheCabinetText1 = formatLabels(sspTheCabinetText, [
          this.memberName
        ]);
        this.sspTheCabinetText2 = formatLabels(sspTheCabinetTextKt, [
          this.memberName
        ]);
        this.doesAgreeQuestion1 = formatLabels(sspDoesAgree, [
          this.headOfHouseHoldName
        ]);
        this.doesAgreeQuestion2 = formatLabels(sspDoesAgreeKt, [
          this.headOfHouseHoldName
        ]);
        this.isVisible = true;
      } else if (result.error) {
        this.error = result.error;
        this.objResult = undefined;
      }
    } catch (error) {
      
      console.error(
        "failed in getEnforcementDetails in Medical Enforcement Page",
        JSON.stringify(error)
      );
    }
    this.showSpinner = false;
  }
  /**
* @function 		: saveData.
* @description 	: this method is called to check validations on click of next.   
 
* */
  saveData () {
    try {
      
      const inputComponents = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );

      for (let i = 0; i < inputComponents.length; i++) {
        const tmpCmp = inputComponents[i];
        this.objParent[tmpCmp.fieldName] = tmpCmp.value;
      }
      if (this.objResult.Id !== undefined || this.objResult.Id !== null) {
        this.objParent.Id = this.objResult.Id;
      }

      this.templateInputsValue = inputComponents;      
    } catch (error) {
      console.error(
        "failed in saveData in Medical Enforcement Page" + JSON.stringify(error)
      );
    }
  }

  /**
   * @function 	: showMedicaidRecords.
   * @description 	: returns boolean based on applied programs .
   * */

  get showMedicaidRecords () {
    let result;
    if (this.appliedPrograms.includes("MA") && this.applicationPrograms === 1) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  /**
   * @function 	: showFieldsMAKT.
   * @description 	: returns boolean based on applied programs .
   * */
  get showFieldsMAKT (){
    return (this.appliedPrograms.includes("MA") || this.appliedPrograms.includes("KT"));
  }

  /**
   * @function 	: showMedicaidRecords.
   * @description 	: returns boolean based on applied programs .
   * */

  /*get showMedicaidOrKtRecords () {
        if (
            ((this.appliedPrograms.includes(
                "MA"
            )  ||
            this.appliedPrograms.includes(
                this.sspConstants.programValues.KT
                )) && this.appliedPrograms.length > 1)
        ) {                       
            return true;
        } else {
            return false;
        }
    }*/
  get showMedicaidKTapRecords () {
    let result = false;
    if (
      (this.appliedPrograms.includes("MA") && this.applicationPrograms > 1) ||
      (this.appliedPrograms.includes("KT") && this.applicationPrograms > 0)
    ) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }
  /**
   * @function 	: showMedicaidKtRecords.
   * @description 	: returns boolean based on applied programs. (KTAP, MEDICAID).
   * */
  get showMedicaidKtRecords () {
    if (
      this.appliedPrograms.includes(this.sspConstants.medicaidTypes.MAGI) ||
      this.appliedPrograms.includes(this.sspConstants.medicaidTypes.NonMAGI)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @function 		: manageMedicalComments.
   * @description 	: this method handles show/hide of section based on the Medical Support question.
   * @param {event} event - Gets current value.
   * */
  manageMedicalComments (event) {
    try {
      const response = event.detail.value;
      if (response === this.sspConstants.toggleFieldValue.no) {
        this.showMedicalComments = true;
      } else {
        this.showMedicalComments = false;
      }
    } catch (error) {
      console.error(
        "failed in manageMedicalComments in Medical Enforcement Page" +
          JSON.stringify(error)
      );
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
              const {securityMatrix } = this.constructVisibilityMatrix((!utility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
              if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                  this.isPageAccessible = true;
              }
              else {
                  this.isPageAccessible = !(securityMatrix.screenPermission === sspConstants.permission.notAccessible);
              }
              this.isReadOnlyUser = securityMatrix.screenPermission === sspConstants.permission.readOnly;
              if (!this.isPageAccessible) {
                  this.showAccessDeniedComponent = true;
              } else {
                  this.showAccessDeniedComponent = false;
              }
          }
      } catch (error) {
          console.error(
              "Error in highestEducation.constructRenderingMap", error
          );
      }
  }
}