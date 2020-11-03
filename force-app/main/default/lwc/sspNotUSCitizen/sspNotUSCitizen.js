/**
 * Component Name: sspNotUSCitizen.
 * Author: Mandi Fazeel Ahmed and Shivam Tiwari.
 * Description: Component for showing the Not US citizen screen.
 * Date:  01/06/2020.
 */

import { track, wire, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspNotUSCitizenTopParagraph from "@salesforce/label/c.sspNotUSCitizenTopParagraph";
import sspNotUSCitizenAlienSponsor from "@salesforce/label/c.sspNotUSCitizenAlienSponsor";
import sspNotUSCitizenImmigrationStatus from "@salesforce/label/c.sspNotUSCitizenImmigrationStatus";
import sspNotUSCitizenServedMilitary from "@salesforce/label/c.sspNotUSCitizenServedMilitary";
import sspNotUSCitizenLivedInUSSince from "@salesforce/label/c.sspNotUSCitizenLivedInUSSince";
import sspNotUSCitizenAlienType from "@salesforce/label/c.sspNotUSCitizenAlienType";
import sspNotUSCitizenPlaceHolder from "@salesforce/label/c.sspNotUSCitizenPlaceHolder";
import sspNotUSCitizenAlienTypeTitle from "@salesforce/label/c.sspNotUSCitizenAlienTypeTitle";
import sspNotUSCitizenImmigrationDocType from "@salesforce/label/c.sspNotUSCitizenImmigrationDocType";
import sspNotUSCitizenImmigrationDocTypeTitle from "@salesforce/label/c.sspNotUSCitizenImmigrationDocTypeTitle";
import sspNotUSCitizenSEVISId from "@salesforce/label/c.sspNotUSCitizenSEVISId";
import sspNotUSCitizenCardNumber from "@salesforce/label/c.sspNotUSCitizenCardNumber";
import sspNotUSCitizenAlienNumber from "@salesforce/label/c.sspNotUSCitizenAlienNumber";
import sspNotUSCitizenCitizenshipNumber from "@salesforce/label/c.sspNotUSCitizenCitizenshipNumber";
import sspNotUSCitizenCountryIssuance from "@salesforce/label/c.sspNotUSCitizenCountryIssuance";
import sspNotUSCitizenCountryIssuanceTitle from "@salesforce/label/c.sspNotUSCitizenCountryIssuanceTitle";
import sspNotUSCitizenDocumentExpirationDate from "@salesforce/label/c.sspNotUSCitizenDocumentExpirationDate";
import sspNotUSCitizenDescriptionOfDoc from "@salesforce/label/c.sspNotUSCitizenDescriptionOfDoc";
import sspNotUSCitizen194Number from "@salesforce/label/c.sspNotUSCitizen194Number";
import sspNotUSCitizenNaturalizationNumber from "@salesforce/label/c.sspNotUSCitizenNaturalizationNumber";
import sspNotUSCitizenPassportNumber from "@salesforce/label/c.sspNotUSCitizenPassportNumber";
import sspNotUSCitizenCheckBoxText from "@salesforce/label/c.sspNotUSCitizenCheckBoxText";
import sspNotUSCitizenCheckBoxTextTitle from "@salesforce/label/c.sspNotUSCitizenCheckBoxTextTitle";
import sspNotUSCitizenCheckBoxParagraph from "@salesforce/label/c.sspNotUSCitizenCheckBoxParagraph";
import sspNotUSCitizenInfoVerified from "@salesforce/label/c.sspNotUSCitizenInfoVerified";
import sspNotUSCitizenAlienTypeHelpText from "@salesforce/label/c.sspNotUSCitizenAlienTypeHelpText";	
import sspNotUSCitizenImmigrationDocTypeHelpText from "@salesforce/label/c.sspNotUSCitizenImmigrationDocTypeHelpText";
import sspPageInformationVerified from "@salesforce/label/c.sspPageInformationVerified";

import sspNotUSCitizenFirstName from "@salesforce/label/c.sspNotUSCitizenFirstName";
import sspNotUSCitizenMI from "@salesforce/label/c.sspNotUSCitizenMI";
import sspNotUSCitizenLastName from "@salesforce/label/c.sspNotUSCitizenLastName";
import sspNotUSCitizenSuffix from "@salesforce/label/c.sspNotUSCitizenSuffix";
import sspNotUSCitizenSuffixTitle from "@salesforce/label/c.sspNotUSCitizenSuffixTitle";
import sspNotUSCitizenDOB from "@salesforce/label/c.sspNotUSCitizenDOB";

import constants from "c/sspConstants";
import { getYesNoOptions, formatLabels } from "c/sspUtility";
import sspUtility from "c/sspUtility";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import {
  getRecord,
  getFieldValue,
  updateRecord,
  getFieldDisplayValue
} from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import getProgramsApplied from "@salesforce/apex/SSP_NotUSCitizenController.getProgramsApplied";
import makeVLPCall from "@salesforce/apex/SSP_NotUSCitizenController.prepareRequest";
import getTimeTravelDate from "@salesforce/apex/SSP_Utility.today";
import handleAlienSponsor from "@salesforce/apex/SSP_NotUSCitizenController.handleAlienSponsor";
import HAS_ALIEN_SPONSOR from "@salesforce/schema/SSP_Member__c.HasAlienSponsorToggle__c";
import SERVED_IN_US_MILITARY from "@salesforce/schema/SSP_Member__c.IsNonUSCitizenMilitaryMemberToggle__c";
import HAS_LEGAL_IMMIGRATION_STATUS from "@salesforce/schema/SSP_Member__c.HasLegalImmigrationStatusToggle__c";
import HAS_LIVED_IN_US from "@salesforce/schema/SSP_Member__c.HasLivedInUsToggle__c";
import ALIEN_TYPE_CODE from "@salesforce/schema/SSP_Member__c.AlienTypeCode__c";
import IMMIGRATION_DOCUMENT_TYPE_CODE from "@salesforce/schema/SSP_Member__c.ImmigrationDocumentTypeCode__c";
import SEVIS_ID from "@salesforce/schema/SSP_Member__c.SevisId__c";
import RECEIPT_NUMBER from "@salesforce/schema/SSP_Member__c.ReceiptNumber__c";
import ALIEN_NUMBER from "@salesforce/schema/SSP_Member__c.AlienNumber__c";
import CITIZENSHIP_NUMBER from "@salesforce/schema/SSP_Member__c.CitizenshipNumber__c";
import ISSUANCE_COUNTRY_CODE from "@salesforce/schema/SSP_Member__c.CountryOfIssuanceCode__c";
import DOCUMENT_EXPIRY_DATE from "@salesforce/schema/SSP_Member__c.DocumentExpiryDate__c";
import DOCUMENT_DESCRIPTION from "@salesforce/schema/SSP_Member__c.DocumentOtherDescription__c";
import I94_NUMBER from "@salesforce/schema/SSP_Member__c.I94Number__c";
import NATURALIZATION_NUMBER from "@salesforce/schema/SSP_Member__c.NaturalizationNumber__c";
import PASSPORT_NUMBER from "@salesforce/schema/SSP_Member__c.PassportNumber__c";
import IMMIGRATION_DETAILS_MATCH from "@salesforce/schema/SSP_Member__c.IsImmigrationDetailsMatch__c"; //Have to confirm
import IMMIGRATION_FIRST_NAME from "@salesforce/schema/SSP_Member__c.ImmigrationFirstName__c";
import IMMIGRATION_MIDDLE_NAME from "@salesforce/schema/SSP_Member__c.ImmigrationMiddleName__c";
import IMMIGRATION_LAST_NAME from "@salesforce/schema/SSP_Member__c.ImmigrationLastName__c";
import IMMIGRATION_SUFFIX from "@salesforce/schema/SSP_Member__c.ImmigrationSuffix__c";
import IMMIGRATION_DATE_OF_BIRTH from "@salesforce/schema/SSP_Member__c.ImmigrationDateOfBirth__c";
import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import SSP_MEMBER from "@salesforce/schema/SSP_Member__c";
import IS_CITIZEN_VALIDATED from "@salesforce/schema/SSP_Member__c.IsVerifiedLawfulPresence__c";
import startBenefitsAppCallNumber from "@salesforce/label/c.SSP_StartBenefitsAppCallNumber";

export default class SspNotUSCitizen extends BaseNavFlowPage {

  @api memberId;
  @api applicationId;
  @api individualRecordTypeId;

  @track responseOptions = getYesNoOptions();
  @track memberFullName = FIRST_NAME + " " + LAST_NAME;
  @track memberInformation = {};
  @track updatedMember = {};
  @track programsApplied;
  @track showAlienSponsorDependentFields = false;
  @track showSEVISId = false;
  @track showCardNumber = false;
  @track showCitizenshipNumber = false;
  @track showAlienNumber = false;
  @track showCountryOfIssuance = false;
  @track showDocumentExpiryDate = false;
  @track showDocumentDescription = false;
  @track showI94Number = false;
  @track showNeutralizationNumber = false;
  @track showPassportNumber = false;
  @track showIsMatchCheckboxDependentFields = false;
  @track showISMatchCheckbox = false;

  @track alienTypeCodePicklistOptions;
  @track immigrationDocTypeCodePicklistOptions;
  @track issuanceCountryCodePicklistOptions;
  @track immigrationSuffixPicklistOptions;
  @track MetaDataListParent;
  @track wiredRecordForRefresh;
  @track immigrationDocumentTypeValue;
  @track isCitizenVerified = false;
  @track timeTravelDate;
  @track pageName;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
  @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
  @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.
  @track isLegalMigrant = true; // for defect fix 377111

  //Maximum Length Properties for all the text fields.
  SEVISIdMaxLength = 10;
  AlienNumberMaxLength = 9;
  I94MaxLength = 11;
  MIMaxLength = 1;
  CardNumberMaxLength = 13;
  maxLengthDoc = 12;
  minLengthDoc = 6;

  memberFieldList = [
    FIRST_NAME,
    LAST_NAME,
    HAS_ALIEN_SPONSOR,
    SERVED_IN_US_MILITARY,
    IMMIGRATION_DATE_OF_BIRTH,
    IMMIGRATION_SUFFIX,
    IMMIGRATION_LAST_NAME,
    IMMIGRATION_MIDDLE_NAME,
    IMMIGRATION_FIRST_NAME,
    HAS_LEGAL_IMMIGRATION_STATUS,
    IMMIGRATION_DETAILS_MATCH,
    PASSPORT_NUMBER,
    NATURALIZATION_NUMBER,
    I94_NUMBER,
    DOCUMENT_DESCRIPTION,
    DOCUMENT_EXPIRY_DATE,
    ISSUANCE_COUNTRY_CODE,
    CITIZENSHIP_NUMBER,
    HAS_LIVED_IN_US,
    ALIEN_TYPE_CODE,
    IMMIGRATION_DOCUMENT_TYPE_CODE,
    SEVIS_ID,
    RECEIPT_NUMBER,
    ALIEN_NUMBER,
    IS_CITIZEN_VALIDATED
  ];

  customLabel = {
    sspPageInformationVerified,
    sspNotUSCitizenTopParagraph,
    sspNotUSCitizenAlienSponsor,
    sspNotUSCitizenImmigrationStatus,
    sspNotUSCitizenServedMilitary,
    sspNotUSCitizenLivedInUSSince,
    sspNotUSCitizenAlienType,
    sspNotUSCitizenPlaceHolder,
    sspNotUSCitizenAlienTypeTitle,
    sspNotUSCitizenImmigrationDocType,
    sspNotUSCitizenImmigrationDocTypeTitle,
    sspNotUSCitizenSEVISId,
    sspNotUSCitizenCardNumber,
    sspNotUSCitizenAlienNumber,
    sspNotUSCitizenCitizenshipNumber,
    sspNotUSCitizenCountryIssuance,
    sspNotUSCitizenCountryIssuanceTitle,
    sspNotUSCitizenDocumentExpirationDate,
    sspNotUSCitizenDescriptionOfDoc,
    sspNotUSCitizen194Number,
    sspNotUSCitizenNaturalizationNumber,
    sspNotUSCitizenPassportNumber,
    sspNotUSCitizenCheckBoxText,
    sspNotUSCitizenCheckBoxTextTitle,
    sspNotUSCitizenCheckBoxParagraph,
    sspNotUSCitizenFirstName,
    sspNotUSCitizenMI,
    sspNotUSCitizenLastName,
    sspNotUSCitizenSuffix,
    sspNotUSCitizenSuffixTitle,
    sspNotUSCitizenDOB,    
    sspNotUSCitizenInfoVerified,
    sspNotUSCitizenAlienTypeHelpText,	
    sspNotUSCitizenImmigrationDocTypeHelpText,
    startBenefitsAppCallNumber
  };

  callUsAt = `tel:${this.customLabel.startBenefitsAppCallNumber}`;
  get showHasAlienSponsorField () {
    const eligibleProgram = constants.notUSCitizen.alienSponsorPrograms;
    const returnValue = this.checkEligibility(eligibleProgram)
    return returnValue;
  }

  get showHasLegalStatusField () {
    const eligibleProgram = constants.notUSCitizen.legalStatusProgram;
    const returnValue = this.checkEligibility(eligibleProgram)
    return returnValue;
  }

  get showHasServedMilitaryField () {
    const eligibleProgram = constants.notUSCitizen.servedInMilitaryProgram;
    const returnValue = this.checkEligibility(eligibleProgram)
    return returnValue;
  }

  /**
   * @function - objectInfo.
   * @description - This method is used to get Record Id of Individual Record Type.
   */
  @wire(getObjectInfo, { objectApiName: SSP_MEMBER })
  objectInfo ({ error, data }) {
    try {
      if (data) {
        const RecordTypesInfo = constants.sspMemberConstants.RecordTypesInfo;
        const individual =
          constants.sspMemberConstants.IndividualRecordTypeName;
        const recordTypeInformation = data[RecordTypesInfo];
        this.individualRecordTypeId = Object.keys(recordTypeInformation).find(
          recTypeInfo => recordTypeInformation[recTypeInfo].name === individual
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
   * @function - fetchAlienTypeCodePicklistOptions.
   * @description - This method is used to picklist Options for Alien Type field.
   */
  @wire(getPicklistValues, {
    recordTypeId: "$individualRecordTypeId",
    fieldApiName: ALIEN_TYPE_CODE
  })
  fetchAlienTypeCodePicklistOptions ({ error, data }) {
    try {
      if (data) {
        this.alienTypeCodePicklistOptions = data.values;
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in getPicklistValues: ", error);
    }
  }

  /**
   * @function - fetchAlienTypeCodePicklistOptions.
   * @description - This method is used to picklist Options for Immigration Document Type field.
   */
  @wire(getPicklistValues, {
    recordTypeId: "$individualRecordTypeId",
    fieldApiName: IMMIGRATION_DOCUMENT_TYPE_CODE
  })
  fetchImmigrationTypeCodePicklistOptions ({ error, data }) {
    try {
      if (data) {
        this.immigrationDocTypeCodePicklistOptions = data.values;
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in getPicklistValues: ", error);
    }
  }

  /**
   * @function - fetchAlienTypeCodePicklistOptions.
   * @description - This method is used to picklist Options for Issuance Country field.
   */
  @wire(getPicklistValues, {
    recordTypeId: "$individualRecordTypeId",
    fieldApiName: ISSUANCE_COUNTRY_CODE
  })
  fetchIssuanceCountryCodePicklistOptions ({ error, data }) {
    try {
      if (data) {
        this.issuanceCountryCodePicklistOptions = data.values;
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in getPicklistValues: ", error);
    }
  }

  /**
   * @function - fetchAlienTypeCodePicklistOptions.
   * @description - This method is used to picklist Options for Immigration Suffix field.
   */
  @wire(getPicklistValues, {
    recordTypeId: "$individualRecordTypeId",
    fieldApiName: IMMIGRATION_SUFFIX
  })
  fetchImmigrationSuffixPicklistOptions ({ error, data }) {
    try {
      if (data) {
        this.immigrationSuffixPicklistOptions = data.values;
      } else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
      }
    } catch (error) {
      console.error("Error in getPicklistValues: ", error);
    }
  }

  /**
   * @function - fetchAlienTypeCodePicklistOptions.
   * @description - This method is used to get data from Salesforce based on Member and Application Ids.
   * @param {JSON} value - Result of "getRecord" method call.
   */
  @wire(getRecord, {
    recordId: "$memberId",
    fields: "$memberFieldList"
  })
  wiredGetMember (value) {
    this.wiredRecordForRefresh = value;
    const { data, error } = value;
    try {
      if (data) {
        this.getMemberData(data);
        this.updateLabels();        
        this.showSpinner = false;
      }
      else if (error) {
        console.error(
          `Error Occurred while fetching wiredGetMember of Not a US Citizen page ${error}`
        );
      }
    } catch (error) {
      console.error("Error in wire call wiredGetMember:", error);
    }
  }


  /**
   * @function - memberDisabilityValues().
   * @description - This method is used to call apex method to get disability details of member.
   * @param {JSON} value - Result of "fetchInformation" method call.
   */
  @wire(getProgramsApplied, {
    memberId: "$memberId",
    applicationId: "$applicationId"
  })
  wiredProgramsApplied (value) {
    try {
      const { data, error } = value;
        if (data) {
          const programsString =  data.mapResponse.programsApplied;
          if (!sspUtility.isUndefinedOrNull(programsString)) {
            this.programsApplied = programsString.split( ";" );
          }
        }
        else if (error) {
          console.error(
            `Error Occurred while fetching wiredProgramsApplied of Not a US Citizen page ${error}`
          );
        }
    }
    catch (error) {
      console.error("Error in wire call wiredProgramsApplied:", error);
    }
  }


  /**
  * @function - todayDate().
  * @description - This method is used to get today's date through utility class.
  */
  @wire(getTimeTravelDate)
    getTodayDate ({ error, data }) {
      if (data) {
          this.timeTravelDate = data;
      }
      else if (error) {
        console.error(JSON.parse(JSON.stringify(error)));
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
      if (!sspUtility.isUndefinedOrNull(value)) {
        this.nextValue = value;
        this.checkInputValidation();
      }
    } catch (e) {
      console.error("Error in set nextEvent of Not US Citizen page", e);
    }
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
      if (!sspUtility.isUndefinedOrNull(value)) {
        this.MetaDataListParent = value;
          //CD2 2.5	Security Role Matrix and Program Access.                
        if (Object.keys(value).length > 0){
            this.constructRenderingMap(null, value); 
        }
      }
    } catch (e) {
      console.error("Error in set MetadataList of Not US Citizen page", e);
    }
  }

  /**
   * @function - allowSaveData().
   * @description - This method validates the input data and then saves it.
   *
   */
  @api
  get allowSaveData () {
    return this.validationFlag;
  }
  set allowSaveData (value) {
    try {
      this.validationFlag = value;
      if (value) {
        this.handleSave();
      }
    } catch (e) {
      console.error("Error in set allowSaveData of Not US Citizen page", e);
    }
  }
  
  /**
   * @function - connectedCallback.
   * @description - This method is called on component initialization.
   */
  connectedCallback () {
    try {

      this.customLabel.sspPageInformationVerified = formatLabels(
        this.customLabel.sspPageInformationVerified,
        [this.pageName]
      );


      this.showSpinner = true;
      const fieldList = this.memberFieldList.map(
        item => item.fieldApiName + "," + item.objectApiName
      );
      this.getMetadataDetails(fieldList, null, "SSP_APP_Details_NotUSCitizen");
    } catch (error) {
      console.error("Error in connectedCallBack:", error);
    }
  }

  /**
   * @function - getMemberData().
   * @description - Helper method to map data received from database.
   * @param {object} data - Data received from salesforce.
   */
  getMemberData = (data) => {
    try {
      this.memberFullName = [
        getFieldValue(data, FIRST_NAME),
        getFieldValue(data, LAST_NAME)
      ]
        .filter(item => !!item)
        .join(" ");
      this.memberInformation.memberFirstName = getFieldValue(data, FIRST_NAME);
      this.memberInformation.memberLastName = getFieldValue(data, LAST_NAME);
      this.memberInformation.servedInUSMilitary = getFieldValue(
        data,
        SERVED_IN_US_MILITARY
      );
      this.memberInformation.immigrationDateOfBirth = getFieldValue(
        data,
        IMMIGRATION_DATE_OF_BIRTH
      );
      this.memberInformation.immigrationSuffix = getFieldValue(
        data,
        IMMIGRATION_SUFFIX
      );
      this.memberInformation.immigrationFirstName = getFieldValue(
        data,
        IMMIGRATION_FIRST_NAME
      );
      this.memberInformation.immigrationMiddleName = getFieldValue(
        data,
        IMMIGRATION_MIDDLE_NAME
      );
      this.memberInformation.immigrationLastName = getFieldValue(
        data,
        IMMIGRATION_LAST_NAME
      );
      this.memberInformation.hasLegalImmigrationStatus = getFieldValue(
        data,
        HAS_LEGAL_IMMIGRATION_STATUS
      );
      this.memberInformation.immigrationDetailsMatch = getFieldValue(
        data,
        IMMIGRATION_DETAILS_MATCH
      );
      this.memberInformation.passportNumber = getFieldValue(
        data,
        PASSPORT_NUMBER
      );
      this.memberInformation.naturalizationNumber = getFieldValue(
        data,
        NATURALIZATION_NUMBER
      );
      this.memberInformation.i94Number = getFieldValue(data, I94_NUMBER);
      this.memberInformation.documentDescription = getFieldValue(
        data,
        DOCUMENT_DESCRIPTION
      );
      this.memberInformation.documentExpiryDate = getFieldValue(
        data,
        DOCUMENT_EXPIRY_DATE
      );
      this.memberInformation.issuanceCountryCode = getFieldDisplayValue(
        data,
        ISSUANCE_COUNTRY_CODE
      );
      this.memberInformation.citizenshipNumber = getFieldValue(
        data,
        CITIZENSHIP_NUMBER
      );
      this.memberInformation.hasLivedInUS = getFieldValue(
        data,
        HAS_LIVED_IN_US
      );
      this.memberInformation.alienTypeCode = getFieldDisplayValue(
        data,
        ALIEN_TYPE_CODE
      );
      this.memberInformation.immigrationDocumentTypeCode = getFieldDisplayValue(
        data,
        IMMIGRATION_DOCUMENT_TYPE_CODE
      );
      this.memberInformation.SEVISId = getFieldValue(data, SEVIS_ID);
      this.memberInformation.receiptNumber = getFieldValue(
        data,
        RECEIPT_NUMBER
      );
      this.memberInformation.alienNumber = getFieldValue(data, ALIEN_NUMBER);
      this.memberInformation.hasAlienSponsor = getFieldValue(
        data,
        HAS_ALIEN_SPONSOR
      );
      this.isCitizenVerified = false; //getFieldValue(data, IS_CITIZEN_VALIDATED); as part of 363209

      this.showAlienSponsorDependentFields =
        this.memberInformation.hasLegalImmigrationStatus ===
        constants.notUSCitizen.picklistOptions.Y;
      this.showISMatchCheckbox =
        this.memberInformation.hasLegalImmigrationStatus ===
        constants.notUSCitizen.picklistOptions.Y;

      this.showIsMatchCheckboxDependentFields =
        this.memberInformation.immigrationDetailsMatch === true;

      this.immigrationDocumentTypeValue = getFieldValue(
        data,
        IMMIGRATION_DOCUMENT_TYPE_CODE
      );

      this.conditionallyShowHideImmigrationDocumentTypeDependentFields(
        this.immigrationDocumentTypeValue
      );
      this.conditionallyShowHideHasAlienSponsorDependentFields(
        this.memberInformation.hasLegalImmigrationStatus
      );
      //for defect 377111
      if(this.memberInformation.hasLegalImmigrationStatus ===
        constants.notUSCitizen.picklistOptions.N){
            this.isLegalMigrant = false;
        }
    } catch (error) {
      console.error("Error occurred while getting member data", error);
    }
  }

  /**
   * @function - conditionallyShowHideHasAlienSponsorDependentFields().
   * @description - Helper method to map conditionally Show/Hide Has Alien Sponsor Dependent Fields.
   * @param {string} hasLegalImmigrationStatus - Value of Has Alien Sponsor Field.
   */
  conditionallyShowHideHasAlienSponsorDependentFields = (hasLegalImmigrationStatus) => {
    try {
      if (hasLegalImmigrationStatus === constants.notUSCitizen.picklistOptions.N) {
        this.showIsMatchCheckboxDependentFields = false;
        this.memberInformation.immigrationDetailsMatch = false;
      }
      if (sspUtility.isUndefinedOrNull(hasLegalImmigrationStatus)) {
        this.showIsMatchCheckboxDependentFields = false;
        this.memberInformation.immigrationDetailsMatch = false;
        this.showISMatchCheckbox = false;
      }
    } catch (error) {
      console.error("Error occurred in conditionallyShowHideHasAlienSponsorDependentFields", error);
    }
  }

  /**
   * @function - conditionallyShowHideImmigrationDocumentTypeDependentFields().
   * @description - Helper method to conditionally Show/Hide Immigration Document Type Dependent Fields.
   * @param {string} immigrationDocTypeValue - Value of Has Immigration Document Type field.
   */
  conditionallyShowHideImmigrationDocumentTypeDependentFields = ( immigrationDocTypeValue ) => {
    try{
      const constantsPicklistOption =
        constants.notUSCitizen.immigrationDocumentTypeOptions;
      if (
        immigrationDocTypeValue === constantsPicklistOption.DS2 ||
        immigrationDocTypeValue === constantsPicklistOption.I20
      ) {
        this.showSEVISId = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.AR ||
        immigrationDocTypeValue === constantsPicklistOption.I76
      ) {
        this.showCardNumber = true;
      }
      if (immigrationDocTypeValue === constantsPicklistOption.CZ) {
        this.showCitizenshipNumber = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.I9F ||
        immigrationDocTypeValue === constantsPicklistOption.FP ||
        immigrationDocTypeValue === constantsPicklistOption.MRV
      ) {
        this.showCountryOfIssuance = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.I9F ||
        immigrationDocTypeValue === constantsPicklistOption.FP ||
        immigrationDocTypeValue === constantsPicklistOption.I76
      ) {
        this.showDocumentExpiryDate = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.I9 ||
                immigrationDocTypeValue === constantsPicklistOption.I9F ||
                immigrationDocTypeValue === constantsPicklistOption.FP
      ) {
        this.showI94Number = true;
      }
      if (immigrationDocTypeValue === constantsPicklistOption.NT) {
        this.showNeutralizationNumber = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.FP ||
        immigrationDocTypeValue === constantsPicklistOption.I9F ||
        immigrationDocTypeValue === constantsPicklistOption.MRV
      ) {
        this.showPassportNumber = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.CHE ||
        immigrationDocTypeValue === constantsPicklistOption.DHS ||
        immigrationDocTypeValue === constantsPicklistOption.HHS ||
        immigrationDocTypeValue === constantsPicklistOption.I79 ||
        immigrationDocTypeValue === constantsPicklistOption.OREL ||
        immigrationDocTypeValue === constantsPicklistOption.ORR ||
        immigrationDocTypeValue === constantsPicklistOption.OT ||
        immigrationDocTypeValue === constantsPicklistOption.RAS ||
        immigrationDocTypeValue === constantsPicklistOption.WR ||
        immigrationDocTypeValue === constantsPicklistOption.INA1 ||
        immigrationDocTypeValue === constantsPicklistOption.INA3 ||
        immigrationDocTypeValue === constantsPicklistOption.AI ||
        immigrationDocTypeValue === constantsPicklistOption.NA //|| immigrationDocTypeValue === "" -- "Conversion" option missing from options in SF
      ) {
        this.showDocumentDescription = true;
      }
      if (
        immigrationDocTypeValue === constantsPicklistOption.AI ||
        immigrationDocTypeValue === constantsPicklistOption.AR ||
        immigrationDocTypeValue === constantsPicklistOption.CHE ||
        immigrationDocTypeValue === constantsPicklistOption.CZ ||
        immigrationDocTypeValue === constantsPicklistOption.DHS ||
        immigrationDocTypeValue === constantsPicklistOption.HHS ||
        immigrationDocTypeValue === constantsPicklistOption.I3 ||
        immigrationDocTypeValue === constantsPicklistOption.I5 ||
        immigrationDocTypeValue === constantsPicklistOption.I57 ||
        immigrationDocTypeValue === constantsPicklistOption.I76 ||
        immigrationDocTypeValue === constantsPicklistOption.I79 ||
        immigrationDocTypeValue === constantsPicklistOption.MRV ||
        immigrationDocTypeValue === constantsPicklistOption.NT ||
        immigrationDocTypeValue === constantsPicklistOption.OREL ||
        immigrationDocTypeValue === constantsPicklistOption.ORR ||
        immigrationDocTypeValue === constantsPicklistOption.OT ||
        immigrationDocTypeValue === constantsPicklistOption.RAS ||
        immigrationDocTypeValue === constantsPicklistOption.WR ||
        immigrationDocTypeValue === constantsPicklistOption.INA1 ||
        immigrationDocTypeValue === constantsPicklistOption.INA3 ||
        immigrationDocTypeValue === constantsPicklistOption.NA //|| immigrationDocTypeValue === "" -- "Conversion" option missing from options in SF
      ) {
        this.showAlienNumber = true;
      }
    }
    catch (error) {
      console.error("Error in conditionallyShowHideImmigrationDocumentTypeDependentFields: ", error);
    }
  }

  /**
   * @function - handleSave().
   * @description - Helper method to save data to database.
   */
  handleSave = () => {
    try {
      const updatedMember = this.updatedMember;
            const dataPassedToService = {};
      const inputElements = Array.from(
        this.template.querySelectorAll(".ssp-applicationInputs")
      );
      for (const element of inputElements) {
        let value = element.value;
                if (
                    element.tagName.includes(constants.notUSCitizen.TYPEAHEAD)
                ) {
          value = element.displaySelectedValue;
        }

        updatedMember[element.fieldName] = value;
      }
            for (const element of inputElements) {
                let value = element.value;
                if (
                    element.tagName.includes(constants.notUSCitizen.TYPEAHEAD)
                ) {
                    if (element.displaySelectedValue.value) {
                        value = element.displaySelectedValue.value;
                    } else {
                        value = element.displaySelectedValue;
                    }
                }
                dataPassedToService[element.dataset.id] = value;
            }
      this.makeAlienSponsorDependentFieldsBlank(updatedMember);
      this.makeHiddenTextFieldValuesBlank(updatedMember);
      this.makeImmigrationMatchCheckboxDependentFieldsBlank(updatedMember);
      //This method calls to VLP service if Medicaid is applied for.
       // for defect 377111
      if (this.programsApplied.includes(constants.notUSCitizen.medicaid) && this.isLegalMigrant) {
                this.makeVLPCallHelper(JSON.stringify(dataPassedToService));
      }

      if (this.memberId) {
        updatedMember.Id = this.memberId;
        updateRecord({ fields: updatedMember }).then( () => {
          //Added for Alien Sponsor Track Deletion changes
          handleAlienSponsor({
          applicationId: this.applicationId, 
          memberId: this.memberId
          })
          .then(() => {
          //Do nothing.
          })
          .catch((error) => {
            console.error("Error in getting response from handleAlienSponsor:", JSON.stringify(error));
          });
          //Track Deletion changes end
          refreshApex(this.wiredRecordForRefresh)
        })
        .catch(error => {
        console.error("Error in handleSave: ", error);
        });
    }
      this.saveCompleted = true;
    } catch (error) {
      console.error("Error in handleSave: ", error);
    }
  }

  /**
   * @function - updateLabels().
   * @description - Helper method to update labels.
   */
  updateLabels = () => {
    try {
      const memberFullName = this.memberFullName;
      if (memberFullName) {
          this.customLabel.sspNotUSCitizenAlienSponsor = formatLabels(
            this.customLabel.sspNotUSCitizenAlienSponsor,
            [memberFullName]
          );
          this.customLabel.sspNotUSCitizenImmigrationStatus = formatLabels(
            this.customLabel.sspNotUSCitizenImmigrationStatus,
            [memberFullName]
          );
          this.customLabel.sspNotUSCitizenServedMilitary = formatLabels(
            this.customLabel.sspNotUSCitizenServedMilitary,
            [memberFullName]
          );
          this.customLabel.sspNotUSCitizenLivedInUSSince = formatLabels(
            this.customLabel.sspNotUSCitizenLivedInUSSince,
            [memberFullName]
          );
      }
    } catch (error) {
      console.error("Error in updateLabels: ", error);
    }
    
  }

  /**
   * @function - makeAlienSponsorDependentFieldsBlank().
   * @description - Helper method to make hidden fields blank.
   * @param {object} updatedMember - Updated member record.
   */
  makeAlienSponsorDependentFieldsBlank = (updatedMember) => {
    try {
      const inputElementAlienSponsor = this.template.querySelector(
        ".ssp-hasLegalStatusInput"
      );
      if (inputElementAlienSponsor) {
        if (
          inputElementAlienSponsor.value ===
          constants.notUSCitizen.picklistOptions.N
        ) {
          updatedMember[HAS_LIVED_IN_US.fieldApiName] = null;
          updatedMember[ALIEN_TYPE_CODE.fieldApiName] = null;
          updatedMember[IMMIGRATION_DOCUMENT_TYPE_CODE.fieldApiName] = null;

          updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
          updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
          updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
          updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
          updatedMember[I94_NUMBER.fieldApiName] = null;
          updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
          updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
          updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
          updatedMember[ALIEN_NUMBER.fieldApiName] = null;
          updatedMember[SEVIS_ID.fieldApiName] = null;
          updatedMember[IMMIGRATION_DETAILS_MATCH.fieldApiName] = false;
        }
      }
    } catch (error) {
      console.error("Error in makeAlienSponsorDependentFieldsBlank", error);
    }
  }

  /**
   * @function - makeImmigrationMatchCheckboxDependentFieldsBlank().
   * @description - Helper method to make hidden fields blank.
   * @param {object} updatedMember - Updated member record.
   */
  makeImmigrationMatchCheckboxDependentFieldsBlank = (updatedMember) => {
    try {
      const inputElementAlienSponsor = this.template.querySelector(
        ".ssp-hasLegalStatusInput"
      );
      if (inputElementAlienSponsor) {
        if (inputElementAlienSponsor.value === constants.notUSCitizen.picklistOptions.N || 
          this.memberInformation.immigrationDetailsMatch === false) {
          updatedMember[IMMIGRATION_FIRST_NAME.fieldApiName] = null;
          updatedMember[IMMIGRATION_LAST_NAME.fieldApiName] = null;
          updatedMember[IMMIGRATION_MIDDLE_NAME.fieldApiName] = null;
          updatedMember[IMMIGRATION_SUFFIX.fieldApiName] = null;
          updatedMember[IMMIGRATION_DATE_OF_BIRTH.fieldApiName] = null;
        }
      }
    } catch (error) {
      console.error(
        "Error in makeImmigrationMatchCheckboxDependentFieldsBlank",
        error
      );
    }
  }

  /**
   * @function - makeHiddenTextFieldValuesBlank().
   * @description - Helper method to make hidden fields blank.
   * @param {object} updatedMember - Updated member record.
   */
  makeHiddenTextFieldValuesBlank = (updatedMember) => {
    try{
    const inputElementsDocType = this.template.querySelector(
      ".ssp-immigrationDocumentTypeInput"
    );
    const constantsPicklistOption =
      constants.notUSCitizen.immigrationDocumentTypeOptions;
    if (inputElementsDocType) {
      const selectedValue = inputElementsDocType.displaySelectedValue;

      if (
        selectedValue === constantsPicklistOption.DS2 ||
        selectedValue === constantsPicklistOption.I20
      ) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[ALIEN_NUMBER.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.AR) {
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.I76) {
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.CZ) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.I9F) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[ALIEN_NUMBER.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.FP) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[ALIEN_NUMBER.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.MRV) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.I9) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[ALIEN_NUMBER.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (selectedValue === constantsPicklistOption.NT) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (
        selectedValue === constantsPicklistOption.CHE ||
        selectedValue === constantsPicklistOption.HHS ||
        selectedValue === constantsPicklistOption.OREL ||
        selectedValue === constantsPicklistOption.OT ||
        selectedValue === constantsPicklistOption.WR ||
        selectedValue === constantsPicklistOption.INA3 ||
        selectedValue === constantsPicklistOption.NA ||
        selectedValue === constantsPicklistOption.AI ||
        selectedValue === constantsPicklistOption.INA1 ||
        selectedValue === constantsPicklistOption.RAS ||
        selectedValue === constantsPicklistOption.ORR ||
        selectedValue === constantsPicklistOption.I79 ||
        selectedValue === constantsPicklistOption.DHS
      ) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      } else if (
        selectedValue === constantsPicklistOption.I3 ||
        selectedValue === constantsPicklistOption.I57 ||
        selectedValue === constantsPicklistOption.I5
      ) {
        updatedMember[RECEIPT_NUMBER.fieldApiName] = null;
        updatedMember[CITIZENSHIP_NUMBER.fieldApiName] = null;
        updatedMember[ISSUANCE_COUNTRY_CODE.fieldApiName] = null;
        updatedMember[DOCUMENT_EXPIRY_DATE.fieldApiName] = null;
        updatedMember[I94_NUMBER.fieldApiName] = null;
        updatedMember[NATURALIZATION_NUMBER.fieldApiName] = null;
        updatedMember[PASSPORT_NUMBER.fieldApiName] = null;
        updatedMember[DOCUMENT_DESCRIPTION.fieldApiName] = null;
        updatedMember[SEVIS_ID.fieldApiName] = null;
      }
    }
  }catch (error) {
    console.error("Error in makeHiddenTextFieldValuesBlank", error);
  }
  }

  /**
   * @function - handleImmigrationStatusQuestionChange().
   * @description - Helper method to handle Alien Sponsor field change.
   * @param {string} event - Event.
   */
  handleImmigrationStatusQuestionChange = (event) => {
    try {
      const eventValue = event.target.value;
      this.showAlienSponsorDependentFields =
        eventValue === constants.notUSCitizen.picklistOptions.Y;
      this.showISMatchCheckbox =
        eventValue === constants.notUSCitizen.picklistOptions.Y;

      if (eventValue === constants.notUSCitizen.picklistOptions.N) {
        this.isLegalMigrant = false;
        this.showIsMatchCheckboxDependentFields = false;
        this.showISMatchCheckbox = false;
        this.showSEVISId = false;
        this.showCardNumber = false;
        this.showCitizenshipNumber = false;
        this.showCountryOfIssuance = false;
        this.showDocumentExpiryDate = false;
        this.showDocumentDescription = false;
        this.showI94Number = false;
        this.showNeutralizationNumber = false;
        this.showPassportNumber = false;
        this.showAlienNumber = false;
        this.memberInformation.immigrationDocumentTypeCode = null;
        this.memberInformation.immigrationDetailsMatch = false;
      }
    } catch (error) {
      console.error("Error in handleImmigrationStatusQuestionChange", error);
    }
  }

  /**
   * @function - handleImmigrationDocumentTypeChange().
   * @description - Helper method to handle Immigration Document Type field change.
   * @param {string} event - Event.
   */
  handleImmigrationDocumentTypeChange = (event) => {
    try {
      this.showSEVISId = false;
      this.showCardNumber = false;
      this.showCitizenshipNumber = false;
      this.showCountryOfIssuance = false;
      this.showDocumentExpiryDate = false;
      this.showDocumentDescription = false;
      this.showI94Number = false;
      this.showNeutralizationNumber = false;
      this.showPassportNumber = false;
      this.showAlienNumber = false;

      const selectedValue = event.detail.selectedValue;
      this.conditionallyShowHideImmigrationDocumentTypeDependentFields(
        selectedValue
      );
    } catch (error) {
      console.error("Error in handleImmigrationDocumentTypeChange", error);
    }
  }

  /**
   * @function - handleIsImmigrationDetailsMatchChange().
   * @description - Helper method to handle Is Immigration Details Match field change.
   * @param {string} event - Event.
   */
  handleIsImmigrationDetailsMatchChange = (event) => {
    try {
      this.memberInformation.immigrationDetailsMatch = event.target.value;
      this.showIsMatchCheckboxDependentFields = event.target.value;
    } catch (error) {
      console.error("Error in handleIsImmigrationDetailsMatchChange", error);
    }
  }

  /**
   * @function - checkInputValidation().
   * @description - this method is used to validate the inputs made by user.
   */
  checkInputValidation = () => {
    try {
      const inputElements = this.template.querySelectorAll(
        ".ssp-applicationInputs"
      );
      if( this.isCitizenVerified ) {
        this.saveCompleted = true;
        return;
      }
      this.templateInputsValue = Array.from(inputElements);
    } catch (error) {
      console.error("Error in checkInputValidation: ", error);
    }
  }

  /**
     * @function checkEligibility()
     * @description : checks the questions visibility based on the program.
     * @param {object} eligibleProgram - This parameter provides the updated value.
     */
    checkEligibility = (eligibleProgram) => {
      try {
          if (this.programsApplied) {
              return this.programsApplied.some(function (item) {
                  return eligibleProgram.includes(item);
              });
          }
          return false;
      } catch (error) {
          console.error("Error in checkEligibility:", error);
      }
  }

  makeVLPCallHelper = (jsonData) => {
    try {
      makeVLPCall({
        jsonMemberData: jsonData,
                applicationId: this.applicationId,
                sMemberId: this.memberId
    })
    .then(() => {
        //Do nothing.
    })
    .catch((error) => {
      console.error("Error in getting response from makeVLPCall:", JSON.stringify(error));
    });
    }  catch (error) {
      console.error("Error in makeVLPCallHelper:", JSON.stringify(error));
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
          if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {            
              const {securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
              if (!securityMatrix || !securityMatrix.hasOwnProperty("screenPermission") || !securityMatrix.screenPermission) {
                  this.isPageAccessible = true;
              }
              else {
                  this.isPageAccessible = !(securityMatrix.screenPermission === constants.permission.notAccessible);
              }
              this.isReadOnlyUser = securityMatrix.screenPermission === constants.permission.readOnly;
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