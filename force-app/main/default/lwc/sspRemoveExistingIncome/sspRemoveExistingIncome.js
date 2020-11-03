import { api, track, wire } from "lwc";
import utility,{ formatLabels } from "c/sspUtility";
import baseNavFlowPage from "c/sspBaseNavFlowPage";
import sspRemoveIncomeSourceLabel from "@salesforce/label/c.ssp_Remove_income_source_label";
import sspHas from "@salesforce/label/c.SSP_Has";
import sspHasStoppedReceiving from "@salesforce/label/c.SSP_HasStoppedRecieving";
import sspRemoveIncomeContent from "@salesforce/label/c.SSP_RemoveIncomeContent";
import fetchExistingIncomeDetails from "@salesforce/apex/SSP_IncomeController.fetchExistingIncomeDetailsImperative";
import updateExistingIncomeDetails from "@salesforce/apex/SSP_IncomeController.updateExistingIncomeRecords";
import employmentEndReason from "@salesforce/schema/SSP_Asset__c.EmploymentEndReason__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from "@salesforce/schema/SSP_Asset__c";
import toastErrorText from "@salesforce/label/c.SSP_ToastErrorText";
import sspSelectResourceErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import getApplicationIndividualRecord from "@salesforce/apex/SSP_ResourcesService.getApplicationIndividualForMember";
import { updateRecord } from "lightning/uiRecordApi";
import APPLICATIONINDIVID_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.Id";
import APPLICATIONINDIVOWNSINCOME_FIELD from "@salesforce/schema/SSP_ApplicationIndividual__c.IsMemberStillOwnsIncomes__c";
import sspConstants from "c/sspConstants";

export default class sspRemoveExistingIncome extends baseNavFlowPage {
    @track existingIncomes = []; //list of existing income records
    @api sspMemberId = "";
    @api sspApplicationId = "";
    @track appliedPrograms = [];
    @api memberName = "";
    @api memberFullName;
    @track incomeNotChangedValue;
    @track endReasons = [];
    @track endReasonValueToLabel = {};
    @track MetaDataListParent;
    @track actionValue;
    @track nextValue;
    @track error;
    @track result;
    @track resultForRefresh;
    @track validationFlag;
    @track showCheckBox = true;
    @track disabled = false;
    @track noIncomeSelected = false;
    @track recordDisabled = false;
    @track checkboxValue = false;
    @track hasSaveValidationError = false;
    @track trueValue = true;
    @track showSpinner = false;
    @track timeTravelDate;
    @track stillOwnsIncome = false;
    @track appIndividualRecordId;
    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix.
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    get stoppedReceivingText () {
        return formatLabels(sspHasStoppedReceiving, [this.memberFullName]);
    }

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

    @api
    get MetadataList () {
        return this.MetaDataListParent; //add
    }
    set MetadataList (value) {
        this.MetaDataListParent = value;
        //CD2 2.5	Security Role Matrix and Program Access.                
        if (Object.keys(value).length > 0){
            this.constructRenderingMap(null, value); 
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        if (value !== undefined && value !== "") {
            this.CallSaveOnValidation(value);
        }
    }

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
                //this.onRecordSaveSuccess(this.applicationId);
            }
        }
    }

    get isRecordDisabled () {   //CD2 2.5 Security Role Matrix.
        return this.recordDisabled || this.isReadOnlyUser;
    }
    get isLastCheckboxDisabled () { //CD2 2.5 Security Role Matrix.
        return this.disabled || this.isReadOnlyUser;
    }

    /**
     * Method 		: saveData.
     *
     * @description : The method is used to save the details.
     * @author 		:Kireeti Gora.
     **/
    saveData () {
        const combinedInputComponents = [];
        //fetch input components from child components
        const removeIncomeRowItems = this.template.querySelectorAll(
            ".removeExistingIncome"
        );
        for (let i = 0; i < removeIncomeRowItems.length; i++) {
            const childInputComponents = removeIncomeRowItems[
                i
            ].fetchInputComponents();
            if (childInputComponents.length > 0) {
                for (let j = 0; j < childInputComponents.length; j++) {
                    combinedInputComponents.push(childInputComponents[j]);
                }
            }
        }

        const noRemoveIncomeRowItems = this.template.querySelectorAll(".removeIncome");
        noRemoveIncomeRowItems.forEach(noRemoveIncomeItem => {
            combinedInputComponents.push(noRemoveIncomeItem);
        });

        if (this.showCheckBox && !this.checkboxValue) {
            this.noIncomeSelected = true;
            const showToastEvent = new CustomEvent("showcustomtoast", {
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(showToastEvent);
            if (this.template.querySelector(".ssp-remove-income-form")) {
                this.template.querySelector(".ssp-remove-income-form").classList.add("ssp-checkbox-error");
            }
        } else {
            this.noIncomeSelected = false;
            this.hasSaveValidationError = false;
            if (this.template.querySelector(".ssp-remove-income-form")) {
                this.template.querySelector(".ssp-remove-income-form").classList.remove("ssp-checkbox-error");
            }
        }
        if (this.showCheckBox !== true || (this.showCheckBox === true && this.checkboxValue !== false)) {
            this.templateInputsValue = combinedInputComponents; //setting base cmp attribute
        }
        else {
            this.templateInputsValue = "invalid";
        }
    }
    /**
     *
     *@Function-CallSaveOnValidation.
     *@Description-This is Framework Method Which is called on clearing all validations.
     *@Author-Kireeti Gora.
     *@Param-allowSave.
     **/

    @api
    CallSaveOnValidation () {
        if (this.showCheckBox !== true || (this.showCheckBox === true && this.checkboxValue !== false)) {
            this.handleSave();
        }
    }

    label = {
        sspRemoveIncomeSourceLabel,
        sspHas,
        sspRemoveIncomeContent,
        toastErrorText,
        sspSelectResourceErrorMessage
    };
    incomeNotChangedLabel = this.memberName + " " + sspRemoveIncomeContent;

    /**
* Method 		: connectedCallback.
    *
* @description 	: This is called on do do init to fetch metadata record details.
* @author Kireeti Gora.

**/
    connectedCallback () {
        this.showSpinner = true;
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
            "EndDate__c,SSP_Asset__c",
            "EmploymentEndReason__c,SSP_Asset__c"
        );
        this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "SSP_APP_Details_RemoveExistingIncome"
        );
        this.incomeNotChangedLabel =
    this.incomeNotChangedLabel = this.memberName + " " + sspRemoveIncomeContent;
    if(this.sspMemberId!=null && this.sspMemberId!=undefined && this.sspApplicationId!=null && this.sspApplicationId!=undefined){
        this.fetchIncomeData();
      }
  }

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;

    /*
     *@Function-fetchExistingIncomeDetails.
     *@Description-This wire method is used to fetch existing income records.
     *@Author-Kireeti Gora.
     *@param    {string,string}    : - SspMemberId and sspApplicationId.
     */
 /* @wire(fetchExistingIncomeDetails, {
    sspMemberId: "$sspMemberId",
    sspApplicationId: "$sspApplicationId",
    callingComponent: "sspRemoveExistingIncome"
  })*/
  fetchIncomeData =()=>{
   fetchExistingIncomeDetails({
    sspMemberId: this.sspMemberId,
    sspApplicationId: this.sspApplicationId,
    callingComponent: "sspRemoveExistingIncome"
   }).then(result=>{
        this.resultForRefresh = result;
        const parsedData = JSON.parse(result);
        if ("incomeRecords" in parsedData) {
          this.existingIncomes = parsedData.incomeRecords;
        }
        this.timeTravelDate = parsedData.timeTravelDate;
        if ("applicationIndividual" in parsedData) {
          const memberPrograms = parsedData.applicationIndividual;
          const appIndividual = memberPrograms[0];
          if (
            appIndividual !== null &&
            appIndividual !== undefined &&
            appIndividual.ProgramsApplied__c !== null &&
            appIndividual.ProgramsApplied__c !== undefined
          ) {
            const programList = appIndividual.ProgramsApplied__c.split(";");
            this.appliedPrograms = programList;
              this.checkboxValue = !utility.isArrayEmpty(appIndividual) ? appIndividual.IsMemberStillOwnsIncomes__c : false;
              this.appIndividualRecordId = !utility.isArrayEmpty(appIndividual) ? appIndividual.Id : null;
          }
          if (
            appIndividual !== null &&
            appIndividual !== undefined &&
            appIndividual.MedicaidType__c !== null &&
            appIndividual.MedicaidType__c !== undefined
          ) {
            this.appliedPrograms.push(appIndividual.MedicaidType__c);
          }
        }
        this.showSpinner = false;
      

   })
  .catch(error => {
    console.error(
        "Error in Remove Existing Expense" +
            JSON.stringify(error)
    );
    });
  }
    /**
     * Method 		: picklistValuesForIncomeEndReason.
     *
     * @description 	: This method is used to fetch picklist details of employment endReason.
     * @author 		: Kireeti Gora.
     * */
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: employmentEndReason
    })
    picklistValuesForIncomeEndReason ({ error, data }) {
        if (data) {
            this.endReasons = data.values;
        } else if (error) {
            this.error = error;
        }
    }
    /**
* Method 		: handleSave.
    *
* @description 	: This method is called on save ,it fetches information from child components and sends to
                other method to save in database.
* @author 		: Kireeti Gora.
* */
    handleSave () {
        const removeIncomeRowItems = this.template.querySelectorAll(
            ".removeExistingIncome"
        );

        const updatedIncomeRecords = [];
        for (let i = 0; i < removeIncomeRowItems.length; i++) {
            if (removeIncomeRowItems[i].triggerTwoWayBinding()) {
                updatedIncomeRecords.push(
                    removeIncomeRowItems[i].triggerTwoWayBinding()
                );
            }
        }

        if (updatedIncomeRecords.length !== 0) {
            this.saveDataToServer(updatedIncomeRecords);
        } else {
            const appIndividualRecord = {};
            appIndividualRecord[APPLICATIONINDIVID_FIELD.fieldApiName] = this.appIndividualRecordId;
            appIndividualRecord[APPLICATIONINDIVOWNSINCOME_FIELD.fieldApiName] = this.checkboxValue;

            const recordInput = {};
            recordInput.fields = appIndividualRecord;
            updateRecord(recordInput)
                .then(() => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    this.error = error;
                })
        }
    }

    /*
     *@Function-saveDataToServer.
     *@Description-This method is used to save existing income records.
     *@Author-Kireeti Gora.
     * @param {string} [incomeList] - List of Income Records to Save.
     **/
    saveDataToServer (incomeList) {
        const mParam = {
            incomeJSON: JSON.stringify(incomeList)
        };
        if (incomeList.length > 0) {
            const appIndividualRecord = {};
            appIndividualRecord[APPLICATIONINDIVID_FIELD.fieldApiName] = this.appIndividualRecordId;
            appIndividualRecord[APPLICATIONINDIVOWNSINCOME_FIELD.fieldApiName] = this.checkboxValue;

            const recordInput = {};
            recordInput.fields = appIndividualRecord;

            updateExistingIncomeDetails(mParam)
                .then(result => {
                    this.result = result;
                    if(this.sspMemberId!=null && this.sspMemberId!=undefined && this.sspApplicationId!=null && this.sspApplicationId!=undefined){
                      this.fetchIncomeData();
                    }
          
                    updateRecord(recordInput)
                        .then(() => {
                            this.saveCompleted = true;
                        })
                        .catch(error => {
                            this.error = error;
                        })
                })
                .catch(error => {
                    this.error = error;
                });
        }
    }
    /**
* Method 		: handleCheckboxChange.
    *
* @description 	:this method is used to handle show/hide checkbox. 
* @author 		: Kireeti Gora.

* */
    handleCheckboxChange () {
        const removeIncomeRowItems = this.template.querySelectorAll(
            ".removeExistingIncome"
        );

        const updatedIncomeRecords = [];
        for (let i = 0; i < removeIncomeRowItems.length; i++) {
            if (removeIncomeRowItems[i].triggerTwoWayBinding()) {
                updatedIncomeRecords.push(
                    removeIncomeRowItems[i].triggerTwoWayBinding()
                );
            }
        }

        if (updatedIncomeRecords.length > 0) {
            this.incomeNotChangedValue = false;
            this.showCheckBox = false;
            this.disabled = true;
            this.noIncomeSelected = false;
            this.checkboxValue = false;
            if (this.template.querySelector(".ssp-remove-income-form")) {
                this.template.querySelector(".ssp-remove-income-form").classList.remove("ssp-checkbox-error");
            }
        } else {
            this.showCheckBox = true;
            this.disabled = false;
            this.checkboxValue = true;
        }
    }
    handleCheckBoxValue () {
        const ownsCheckboxValue = this.template.querySelector(".removeIncome");

        this.checkboxValue = ownsCheckboxValue.isChecked;
        if (this.checkboxValue) {
            this.recordDisabled = true;
            this.noIncomeSelected = false;
            if (this.template.querySelector(".ssp-remove-income-form")) {
                this.template.querySelector(".ssp-remove-income-form").classList.remove("ssp-checkbox-error");
            }
        } else {
            this.recordDisabled = false;
        }
    }
    /*
     * @function : hideToast
     * @description	: Method to hide Toast
     */
    hideToast () {
        this.hasSaveValidationError = false;
    }

    /*
    * @function : getApplicationIndividualDetails
    * @description : This method used to get existing application individual details.
    */
    getApplicationIndividualDetails = () => {
        try {
            this.showSpinner = true;
            /* @sApplicationId {applicationId} applicationId.
             * @sMemberId {memberId} memberId.
             * @returns { String JSON } Returns a string JSON with existing applicationIndividual details.
             */
            getApplicationIndividualRecord({
                sApplicationId: this.sspApplicationId,
                sMemberId: this.sspMemberId
            })
                .then(result => {
                    this.checkboxValue = !utility.isArrayEmpty(result) ? result[0].IsMemberStillOwnsIncomes__c : false;
                    this.appIndividualRecordId = !utility.isArrayEmpty(result) ? result[0].Id : null;
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.error = error;
                    this.showSpinner = false;
                });
        } catch (error) {
            this.error = error;
            this.showSpinner = false;
        }
    }

    /**
     * @function : renderedCallback
     * @description : Rendered on load of removal of existing income page.
     */
    renderedCallback () {
        try {
            const noChangeCheckboxValue = this.template.querySelector(".removeIncome");
            if (!utility.isUndefinedOrNull(noChangeCheckboxValue)) {
                noChangeCheckboxValue.isChecked = this.checkboxValue;
            }
            if (this.checkboxValue) {
                this.recordDisabled = true;
                this.noIncomeSelected = false;

            } else {
                this.recordDisabled = false;
            }
        } catch (error) {
            console.error("Error occurred in rendered Callback" + JSON.stringify(error.message));
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