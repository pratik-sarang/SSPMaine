/**
 * Component Name: sspAddAuthRepConsent.
 * Author: Shrikant Raut, Chirag Garg.
 * Description: The component is to take consent for adding auth rep.
 * Date:  1/23/2020.
 */
import { api, track, wire } from "lwc";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
import { refreshApex } from "@salesforce/apex";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import fetchDetailsForConsent from "@salesforce/apex/SSP_AddAuthRepController.fetchDetailsForConsent";
import setPermissionDetail from "@salesforce/apex/SSP_RepsAssistersAgentsController.updateACRRecords";
import upsertContactInformation from "@salesforce/apex/SSP_AddAuthRepController.upsertContactInformation";

import sspAuthorizedRepresentativeConsent from "@salesforce/label/c.SSP_AuthorizedRepresentativeConsent";
import sspContentAuthorizeRepresentativeConsent1 from "@salesforce/label/c.SSP_ContentAuthorizeRepresentativeConsent1";
import sspTermsOfAgreement from "@salesforce/label/c.SSP_TermsOfAgreement";
import sspContentAuthorizedRepresentativeConsent2 from "@salesforce/label/c.SSP_ContentAuthorizedRepresentativeConsent2";
import sspContentAuthorizedRepresentativeConsent3 from "@salesforce/label/c.SSP_ContentAuthorizedRepresentativeConsent3";
import sspContentAuthorizedRepresentativeConsent4 from "@salesforce/label/c.SSP_ContentAuthorizedRepresentativeConsent4";
import sspFirstName from "@salesforce/label/c.SSP_FirstName";
import sspLastName from "@salesforce/label/c.SSP_LastName";
import sspCancel from "@salesforce/label/c.SSP_Cancel";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspOneDot from "@salesforce/label/c.SSP_OneDot";
import sspTwoDot from "@salesforce/label/c.SSP_TwoDot";
import sspMI from "@salesforce/label/c.SSP_MI";
import sspSuffix2 from "@salesforce/label/c.SSP_Suffix2";
import sspDate from "@salesforce/label/c.SSP_Date";
import sspSubmitAuthorizedRepresentative from "@salesforce/label/c.SSP_SubmitAuthorizedRepresentative";
import sspSubmitAuthorizedRepresentativeInformation from "@salesforce/label/c.SSP_SubmitAuthorizedRepresentativeInformation";
import sspReturnPreviousScreen from "@salesforce/label/c.SSP_ReturnPreviousScreen";
import sspCancelEnteringDetailsAuthorizedRepresentative from "@salesforce/label/c.SSP_CancelEnteringDetailsAuthorizedRepresentative";
import sspSuffixOptionsTitleText from "@salesforce/label/c.SSP_SuffixOptionsTitleText";

export default class SspAddAuthRepConsent extends sspUtility {
  @api accountRelation;
  @api permissionParam;
  @track isEdit = false;
  @track showErrorModal = false;
  @track errorCode = "";
  sspAccountId;
  sspApplicationId;
  customLabel = {
    toastErrorText,
    sspAuthorizedRepresentativeConsent,
    sspContentAuthorizeRepresentativeConsent1,
    sspTermsOfAgreement,
    sspContentAuthorizedRepresentativeConsent2,
    sspContentAuthorizedRepresentativeConsent3,
    sspContentAuthorizedRepresentativeConsent4,
    sspFirstName,
    sspLastName,
    sspCancel,
    sspBack,
    sspOneDot,
    sspTwoDot,
    sspMI,
    sspSuffix2,
    sspDate,
    sspSubmitAuthorizedRepresentative,
    sspSubmitAuthorizedRepresentativeInformation,
    sspReturnPreviousScreen,
    sspCancelEnteringDetailsAuthorizedRepresentative,
    sspSuffixOptionsTitleText,
    sspMiddleInitialMaxLength:
      sspConstants.validationEntities.sspMiddleInitialMaxLength
  };

    @track suffixOptions;
    @track metaDataListParent;
    @track actContactRelationObj = {
        [sspConstants.accountContactRelationFields.FirstName__c]: "",
        [sspConstants.accountContactRelationFields.MiddleName__c]: "",
        [sspConstants.accountContactRelationFields.LastName__c]: "",
        [sspConstants.accountContactRelationFields.SuffixCode__c]: "",
        [sspConstants.accountContactRelationFields.ConsentDate__c]: ""
    };
    @track headOfHousehold = {
        FirstName: "",
        LastName: "",
        MI: "",
        SuffixCode: ""
    };
    @track trueValue = true;
    @track retrievedData;
    @track recordTypeId;
    @track showSpinner = true;
    @track isVisible = false;
    @track renderingAttributes = {
        requiredInformationFetched: false,
        suffixValuesRetrieved: false,
        connectedCallBackExecuted: false,
        validationMetadataRetrieved: false
    };
    @track hasSaveValidationError = false;

    /**
     * @function : fetchContactInformation
     * @description	: Wire call to retrieve contact details from server.
     * @param {object} objData - Retrieved data.
     */
    @wire(fetchDetailsForConsent, {
        sspAccountId: "$sspAccountId",
        callingComponent: "sspAddAuthRepConsent"
    })
    fetchDetailsForConsent (objData) {
        try {
            if (!sspUtility.isUndefinedOrNull(objData.data)) {
                this.retrievedData = objData;
                if (this.retrievedData.data) {
                    const parsedData = this.retrievedData.data.mapResponse;

                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty(
                            sspConstants.addAuthRepConstants.ERROR
                        )
                    ) {
                        console.error(
                            "Error in retrieving data sspChangeExistingIncome" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        let valueLabelMapping;
                        if (
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants.dateToday
                            )
                        ) {
                            const dateToday = parsedData.dateToday;
                            const date =
                                dateToday.split("-")[0] +
                                "-" +
                                dateToday.split("-")[1] +
                                "-" +
                                dateToday.split("-")[2];

                            this.actContactRelationObj[
                                sspConstants.accountContactRelationFields.ConsentDate__c
                            ] = date;
                        }
                        if (
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants
                                    .suffixCodeValues
                            )
                        ) {
                            const suffixOptions = [];
                            valueLabelMapping = parsedData.suffixCodeValues;
                            Object.keys(valueLabelMapping).forEach(value => {
                                suffixOptions.push({
                                    value: value,
                                    label: parsedData.suffixCodeValues[value]
                                });
                            });

                            this.suffixOptions = suffixOptions;
                            this.renderingAttributes.suffixValuesRetrieved = true;
                        }
                        if (
                            parsedData.hasOwnProperty(
                                sspConstants.addAuthRepConstants
                                    .appIndividualRecord
                            )
                        ) {
                            const appIndividualRecord =
                                parsedData.appIndividualRecord;
                            const headOfHousehold = {
                                FirstName: !sspUtility.isUndefinedOrNull(
                                    appIndividualRecord.SSP_Member__r
                                        .FirstName__c
                                )
                                    ? appIndividualRecord.SSP_Member__r
                                          .FirstName__c
                                    : "",
                                LastName: !sspUtility.isUndefinedOrNull(
                                    appIndividualRecord.SSP_Member__r
                                        .LastName__c
                                )
                                    ? appIndividualRecord.SSP_Member__r
                                          .LastName__c
                                    : "",
                                MI: !sspUtility.isUndefinedOrNull(
                                    appIndividualRecord.SSP_Member__r
                                        .MiddleInitial__c
                                )
                                    ? appIndividualRecord.SSP_Member__r
                                          .MiddleInitial__c
                                    : "",
                                SuffixCode: !sspUtility.isUndefinedOrNull(
                                    appIndividualRecord.SSP_Member__r
                                        .SuffixCode__c
                                )
                                    ? appIndividualRecord.SSP_Member__r
                                          .SuffixCode__c
                                    : ""
                            };
                            this.sspApplicationId =
                                appIndividualRecord.SSP_Application__c;
                            this.headOfHousehold = headOfHousehold;
                        }
                    }
                }
                this.renderingAttributes.requiredInformationFetched = true;
                this.setVisibility();
            } else if (!sspUtility.isUndefinedOrNull(objData.error)) {
                console.error(
                    "Error in retrieving data sspAddAuthRepConsent.fetchDetailsForConsent" +
                        JSON.stringify(objData.error)
                );
            }
        } catch (error) {
            console.error(
                "failed in sspAddAuthRepConsent.fetchDetailsForConsent " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : connectedCallback
     * @description	: Connected callback - to retrieve values related to validation framework.
     */
    connectedCallback () {
        try {
            const fieldEntityNameList = [];
            fieldEntityNameList.push(
                sspConstants.accountContactRelationFields.FirstName__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.accountContactRelationFields.MiddleName__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.accountContactRelationFields.LastName__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.accountContactRelationFields.SuffixCode__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation,
                sspConstants.accountContactRelationFields.ConsentDate__c +
                    "," +
                    sspConstants.sspObjectAPI.AccountContactRelation
            );
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                sspConstants.addAuthRepConstants.REPS_AuthorizedRepConsent
            );
            this.renderingAttributes.connectedCallBackExecuted = true;
            if (!sspUtility.isUndefinedOrNull(this.accountRelation)) {
                this.sspAccountId = JSON.parse(
                    this.accountRelation
                ).accountId.trim();
            }
            this.setVisibility();
        } catch (error) {
            console.error(
                "failed in sspAddAuthRepConsent.connectedCallback " +
                    JSON.stringify(error)
            );
        }
    }

    @api
    get MetadataList () {
        return this.metaDataListParent;
    }

    /**
     * @function : MetadataList
     * @description	: Set property to assign entity mapping values to metaDataListParent.
     * @param {object} value - SF entity mapping values.
     */
    set MetadataList (value) {
        try {
            if (
                !sspUtility.isUndefinedOrNull(value) &&
                Object.keys(value).length > 0
            ) {
                this.metaDataListParent = value;
                this.renderingAttributes.validationMetadataRetrieved = true;
                this.setVisibility();
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRepConsent.setMetadataList: " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function : isVisible
     * @description	: Get property to identify if component is ready to render UI elements.
     */
    setVisibility = () => {
        let renderPage = true;
        try {
            const renderingAttributes = this.renderingAttributes;
            Object.keys(renderingAttributes).forEach(attribute => {
                renderPage = renderPage && renderingAttributes[attribute];
            });
        } catch (error) {
            renderPage = false;
            console.error(
                "Error in sspAddAuthRepConsent.hideToast: " +
                    JSON.stringify(error)
            );
        }
        this.isVisible = renderPage;
        this.showSpinner = !this.isVisible;
    };

    /**
     * @function : initSave.
     * @description	: Method to save the values entered/selected.
     */
    initSave = () => {
        try {
            let isError = false;
            let actContactRelationObj = {};
            const templateAppInputs = this.template.querySelectorAll(
                sspConstants.classNames.sspApplicationInputs
            );

            this.showSpinner = true;
            actContactRelationObj = this.actContactRelationObj;

            templateAppInputs.forEach(function (entity) {
                const errorMessage = entity.ErrorMessages();

                if (
                    !sspUtility.isUndefinedOrNull(errorMessage) &&
                    errorMessage.length !== 0
                ) {
                    isError = true;
                } else if (!sspUtility.isUndefinedOrNull(entity.fieldName)) {
                    actContactRelationObj[entity.fieldName] = entity.value;
                }
            });

      if (actContactRelationObj !== null && !isError) {
                this.actContactRelationObj = actContactRelationObj;
                this.updateDataToServer(this.actContactRelationObj);
            } else {
                this.hasSaveValidationError = true;
                this.showSpinner = false;
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRepConsent.initSave: " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : updateDataToServer
     * @description	: Server call with updated records to save them to SF database.
     * @param {object[]} consentInfo - AccountContactRelation record list.
     */
    updateDataToServer = consentInfo => {
        try {
            const accountRelation = JSON.parse(this.accountRelation);
            if (!sspUtility.isUndefinedOrNull(consentInfo)) {
                Object.keys(consentInfo).forEach(key => {
                    accountRelation[key] = consentInfo[key];
                });
            }
            if (!sspUtility.isUndefinedOrNull(this.permissionParam)) {
                upsertContactInformation(this.permissionParam).then(result => {
                    if (!sspUtility.isUndefinedOrNull(result)) {
                        const response = result.mapResponse;
                        if (
                            !sspUtility.isUndefinedOrNull(response) &&
                            (response.hasOwnProperty(
                                sspConstants.addAuthRepConstants.ERROR
                            ) ||
                                response.hasOwnProperty(
                                    sspConstants.addAuthRepConstants.EXCEPTION
                                ))
                        ) {
                            console.error(
                                "Failed in sspAddAuthRepConsent.saveDataToServer " +
                                    (response.hasOwnProperty(
                                        sspConstants.addAuthRepConstants.ERROR
                                    )
                                        ? JSON.stringify(response.ERROR)
                                        : JSON.stringify(response.EXCEPTION))
                            );
                        } else {
                            //If ACR already exists(update case) remove accountId and contactId key from ACR object
                            if (
                                !sspUtility.isUndefinedOrNull(
                                    accountRelation
                                ) &&
                                !sspUtility.isUndefinedOrNull(
                                    accountRelation.Id
                                )
                            ) {
                                this.isEdit = true;
                                if (
                                    accountRelation.hasOwnProperty(
                                        sspConstants.addAuthRepConstants
                                            .accountId
                                    )
                                ) {
                                    delete accountRelation[
                                        sspConstants.addAuthRepConstants
                                            .accountId
                                    ];
                                }
                                if (
                                    accountRelation.hasOwnProperty(
                                        sspConstants.addAuthRepConstants
                                            .contactId
                                    )
                                ) {
                                    delete accountRelation[
                                        sspConstants.addAuthRepConstants
                                            .contactId
                                    ];
                                }
                            } else {
                                accountRelation.contactId =
                                    response[
                                        sspConstants.addAuthRepConstants.contactId
                                    ];
                            }

              setPermissionDetail({
                relationJSON: JSON.stringify(accountRelation),
                sspApplicationId: this.sspApplicationId
              })
                .then(errorCode => {
                  if( errorCode !== undefined  && errorCode !== null && errorCode !== "" ){
                    this.showErrorModal = true;
                    this.errorCode = errorCode;
                    this.showSpinner = false;
                  }else{
                  refreshApex(this.retrievedData);
                  this.saveCompleted = true;
                  if(this.isEdit){
                  const hideFrameworkEvent = new CustomEvent(
                    sspConstants.events.save,
                    {
                        detail: false,
                        bubbles: true,
                        composed: true
                    }
                );
                this.dispatchEvent(hideFrameworkEvent);
                  }else{
                    const hideFrameworkEvent = new CustomEvent(
                      sspConstants.events.save,
                      {
                          detail: true,
                          bubbles: true,
                          composed: true
                      }
                  );
                  this.dispatchEvent(hideFrameworkEvent); 
                  }
                }
                  //this.dispatchEvent(new CustomEvent(sspConstants.addAuthRepConstants.close));
                })
                .catch(error => {
                  this.error = error;
                });
            }
          }
        });
      }
    } catch (error) {
      console.error(
        "failed in sspAddAuthRepConsent.updateDataToServer " +
          JSON.stringify(error)
      );
    }
  };
  closeError = () => {
    this.showErrorModal = false;
    this.errorCode = "";
    
  }
  /**
   * @function : hideToast
   * @description	: Method to hide Toast.
   */
  hideToast = () => {
    try {
      this.hasSaveValidationError = false;
    } catch (error) {
      console.error(
        "Error in sspAddAuthRepConsent.hideToast: " + JSON.stringify(error)
      );
    }
  };

    /**
     * @function : handleBack
     * @description	: Method to handle onclick event of Back button.
     */
    handleBack = () => {
        try {
            const hideFrameworkEvent = new CustomEvent(
                sspConstants.events.back
            );
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error(
                "Error in sspAddAuthRepConsent.handleBack: " +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function : handleCancel
     * @description	: Method to handle onclick event of Cancel button.
     */
    handleCancel = () => {
        try {
            const hideFrameworkEvent = new CustomEvent(
                sspConstants.events.cancel,
                {
                    bubbles: true,
                    composed: true
                }
            );
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error(
                "Error in sspAddAuthRepConsent.handleCancel: " +
                    JSON.stringify(error)
            );
        }
    };
}
