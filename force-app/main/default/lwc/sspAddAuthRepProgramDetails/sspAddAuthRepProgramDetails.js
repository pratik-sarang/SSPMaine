/*
 * Component Name: SspAddAuthRepProgramDetails.
 * Author: Kireeti Gora, Venkata.
 * Description: This screen handle Add Auth Rep Permissions Module.
 * Date: 02/01/2020.
 **/
import {  api ,track} from "lwc";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspUtility from "c/sspUtility";
export default class SspAddAuthRepProgramDetails extends sspUtility {
    @api checkboxLabel;
    @api programCheckbox = false;
    @api radioOptions = [];
    @api Id;
    @api fieldName;
    @api accountId;
    @api objACR = {};
    @api programName = {};
    @api selectedPermission;
    @track showError = false;
    @track metaDataListParent;
    customLabel = {
      sspRequiredErrorMessage
    }
   
     /**
     * @function 		: toggleProgramCheckbox.
     * @description 	: this method is handle checkbox change.
     * */  
    toggleProgramCheckbox = () => {
      try{
        this.programCheckbox = !this.programCheckbox;
        if(!this.programCheckbox){
          this.selectedPermission = null;
        }
        } catch (error) {
       console.error(
           "failed in handlePicklistChangeDetails in toggleProgramCheckbox" +
               JSON.stringify(error)
       );
        }
    }
     /**
     * @function 		: handleValidations.
     * @description 	: this method is used to check validations from parent component.
     * */ 
      @api
    handleValidations  ()  {     
      let hasError = false;     
      try{       
        if (this.programCheckbox && this.selectedPermission === null){
          this.showError = true;
          hasError = true;
        }
      
        } catch (error) {
       console.error(
           "failed in handleValidations in toggleProgramCheckbox" +
               JSON.stringify(error)
       );
        }
        return hasError;
    }
     /**
     * @function 		: resetComponent.
     * @description 	: this method is used to reset component from parent component.
     * */ 
     @api
    resetComponent ()  {
      try{
        if(this.programCheckbox){
        this.programCheckbox = false;
        this.selectedPermission = null;
      }
         } catch (error) {
       console.error(
           "failed in handleValidations in toggleProgramCheckbox" +
               JSON.stringify(error)
       );
        }
    }
 /**
     * @function 		: handleChange.
     * @description 	: this method is used to set permission value on change.
     * @param {event} event - Gets current value.
     * */ 
    handleChange = (event) => {
      try{
      this.selectedPermission = event.detail.value;
      this.showError = false
       } catch (error) {
       console.error(
           "failed in handleChange in toggleProgramCheckbox" +
               JSON.stringify(error)
       );
        }
    }
      /**
     * @function 		: connectedCallback.
     * @description 	: this method is used set attributes on load.
     * */ 
     connectedCallback (){
       try{        
        const fieldEntityNameList = [];
        fieldEntityNameList.push(
          "IsManualAuthRep__c,Contact");
          this.getMetadataDetails(
            fieldEntityNameList,
            null,
            "REPS_AddAuthorizedRepresentative1"
        );
        if(!this.programCheckbox){
    this.programCheckbox = false;
        }
        if(this.selectedPermission === null || this.selectedPermission ===""){
    this.selectedPermission = null;
        }
     } catch (error) {
       console.error(
           "failed in connectedCallback in toggleProgramCheckbox" +
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
              
            }
        } catch (error) {
            console.error(
                "Error in sspAddAuthRep.setMetadataList: " +
                    JSON.stringify(error)
            );
        }
    }
   
}