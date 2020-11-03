/**
 * Component Name: sspHouseHoldMeals.
 * Author: Suyash ,P V.
 * Description: This screen contains a question to collect which members buy and cook meals with the head of household.
 * Date: 14/12/2019.
 */

import { track, api } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspUtility from "c/sspUtility"; //CD2 2.5 Security Role Matrix and Program Access.
import sspCompleteQuestionsHouseholdMeals from "@salesforce/label/c.sspCompleteQuesHouseholdMeals";
import sspMemberWhoBuysAndCooks from "@salesforce/label/c.sspMemberWhoBuysAndCooks";
import sspConstants from "c/sspConstants";
import fetchHouseholdData from "@salesforce/apex/SSP_HouseHoldMeals.fetchHouseHoldData";
import saveInformation from "@salesforce/apex/SSP_HouseHoldMeals.saveData";

export default class sspHouseHoldMeals extends BaseNavFlowPage {
    label = {
        sspCompleteQuestionsHouseholdMeals,
        sspMemberWhoBuysAndCooks
    };

    @track memberData = [];
    @track HOH;
    @track sLabel;
    @track bCheck = false;
    @track sAppId;
    @track showSpinner=false;
    @api modeValue;
    @api checkBoxGroupValues = [];
    @track entityMetadataLoaded = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	

    @api optList = [];
    
    @api
    get applicationId () {
        return this.sAppId;
    }
    set applicationId (value) {
        try {
            if (value) {
                this.sAppId = value;
               // this.callFetchHouseholdData();
            }
        } catch (Error) {
            console.error(
                "Error in fetching house hold data " + JSON.stringify(Error)
            );
        }
    }

    //CD2 2.5 Security Role Matrix and Program Access.
    get showContents (){
        return this.bCheck && this.entityMetadataLoaded && this.isScreenAccessible;
    }

    /**
     * @function : callFetchHouseholdData.
     * @description : Method is used to get the Household Data on the load of component.
     */

    callFetchHouseholdData () {
        fetchHouseholdData({
            sApplicationId: this.sAppId, 
            mode: this.modeValue
        })
            .then(result => {
                this.memberData = JSON.parse(result.mapResponse.Result);
                this.HOH = JSON.parse(result.mapResponse.headOfHousehold);
                this.sLabel = result.mapResponse.sLabel;
                const mode = this.modeValue;
                for (let i = 0; i < this.memberData.length; i += 1) {
                    if (!this.memberData[i].bHOH) {
                        if(mode !== sspConstants.mode.addRemoveMember){
                            this.optList.push({
                                label: this.memberData[i].sMemberName,
                                value: this.memberData[i].sMemberId
                            });              
                        }    
                        else {
                            
                            if(this.memberData[i].sMemberStatus === sspConstants.resourceSelectionConstants.sNewStatus){                          
                                this.optList.push({
                                    label: this.memberData[i].sMemberName,
                                    value: this.memberData[i].sMemberId
                                });
                            }
                        }      
                        this.bCheck = true;
                    } else {
                        this.HOHName = this.memberData[i].sMemberName;
                    }
                    if (this.memberData[i].bCanBuyCookWithHOH){
                        this.checkBoxGroupValues.push(
                            this.memberData[i].sMemberId
                        );   
                    }
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(
                    "Error in fetching Household Information" +
                        JSON.stringify(error)
                );
            });
    }

    @api
    get MetadataList () {
        return this.MetaDataListParent;
    }
    set MetadataList (value) {
        try {
            if (value !== undefined && value !== null) {
                //CD2 2.5	Security Role Matrix and Program Access.   
                if (Object.keys(value).length > 0) {             
                    this.constructRenderingMap(null, value);
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                }
                
                this.MetaDataListParent = value;
                this.entityMetadataLoaded = true; //CD2 2.5 Security Role Matrix and Program Access.
            }
        } catch (e) {
            console.error("error in set MetadataList", e);
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        try {
            if (value !== undefined && value !== "") {
                this.nextValue = value;

                this.checkInputValidation();
            }
        } catch (e) {
            console.error("error in set nextEvent", e);
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        try {
            this.validationFlag = value;

            if (value !== undefined && value !== "") {
                this.saveHHData(value);
            }
        } catch (e) {
            console.error("error in set allowSaveData", e);
        }
    }

    /**
     * @function : saveHHData.
     * @description : Call is made to Save data of Dependent Member.
     * @param {JSON} memberDetails - Member Data.
     */
    @api
    saveHHData (memberDetails) {
        try {
            const memberMap = JSON.parse(memberDetails);

            saveInformation({
                sMemberIds: memberMap.selectedMembers,
                sAppId: this.sAppId,
                mode:this.modeValue
            })
                .then(result => {
                    this.saveCompleted = true;
                })
                .catch(error => {
                    console.error("Error in handleSave", error);
                });
        } catch (e) {
            console.error("error in saveContactData", e);
        }
    }

    get retExp () {
        return this.sAppId !== null;
    }

    /**
     * @function : connectedCallback
     * @description : Used to get the Metadata List which will have all the fields error Messages.
     */
    connectedCallback () {
        try {
            this.showTextMsg = false;
            const fieldEntityNameList = [];
            this.showSpinner=true;
            fieldEntityNameList.push("CanBuyCookWithHOH__c,SSP_Member__c");
            this.getMetadataDetails(
                fieldEntityNameList,
                null,
                "SSP_APP_RTF_Household Meals"
            );
            this.callFetchHouseholdData();
        } catch (e) {
            this.showSpinner = false;
            console.error("error in connectedCallback", e);
        }
    }

    /**
     * @function : checkInputValidation
     * @description : To check input validations.
     */
    checkInputValidation () {
        try {
            const memberInfo = this.template.querySelectorAll(".memberDetails");
            this.templateInputsValue = memberInfo;
        } catch (e) {
            console.error("checkInputValidation", e);
        }
    }

    /**
     * @function : constructRenderingMap
     * @description : This method is used to identify screen and field permissions. CD2 2.5 Security Role Matrix and Program Access.
     * @param {string} appPrograms - Application level programs.
     * @param {string} metaValue - Entity mapping data.
     */
    constructRenderingMap = (appPrograms, metaValue) => {
        try {
            if (!sspUtility.isUndefinedOrNull(metaValue) && Object.keys(metaValue).length > 0) {
                const { securityMatrix } = this.constructVisibilityMatrix((!sspUtility.isUndefinedOrNull(appPrograms) && appPrograms != "") ? appPrograms : []);
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == sspConstants.permission.notAccessible) ? false : true;                
            }
            else {
                this.isScreenAccessible = true
            }            
        } catch (e) {
            console.error(
                "Error in sspHouseholdMeals.constructRenderingMap",
                e
            );
        }
    }
}