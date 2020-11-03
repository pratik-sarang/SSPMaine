/**
 * Component Name: SspAbsentParentSummary.
 * Author: Ajay Saini, Venkata.
 * Description: This screen takes absent parent information for an applicant.
 * Date: DEC-20-2019.
 */

import { track, api, wire } from "lwc";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import absentParentSummaryInfo from "@salesforce/label/c.SSP_AbsentParentSummaryInfo";
import learnMoreAltText from "@salesforce/label/c.SSP_LearnMoreHousehold";
import absentParentLabel from "@salesforce/label/c.SSP_Absent_Parent";
import startAltText from "@salesforce/label/c.SSP_AbsentParentStartTitle";
import editAltText from "@salesforce/label/c.SSP_AbsentParentEditTitle";
import deleteAltText from "@salesforce/label/c.SSP_AbsentParentDeleteTitle";
import deleteModalHeading from "@salesforce/label/c.SSP_AbsentParentDeleteModalHeading";
import toastErrorText from "@salesforce/label/c.SSP_SummaryRecordValidatorMessage";
import cancel from "@salesforce/label/c.SSP_Cancel";
import fatherLabel from "@salesforce/label/c.SSP_Father";
import motherLabel from "@salesforce/label/c.SSP_Mother";
import FIRST_NAME from "@salesforce/schema/SSP_Member__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/SSP_Member__c.LastName__c";
import { events } from "c/sspConstants";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sspConstants from "c/sspConstants"; 
import sspUtility from "c/sspUtility";
import SspBaseNavFlowPage from "c/sspBaseNavFlowPage";
import sspViewDetails from "@salesforce/label/c.SSP_ViewDetails"; //Added by Chirag
import sspView from "@salesforce/label/c.SSP_View";//Added by Chirag

import getNonCustodialParentRecords from "@salesforce/apex/SSP_AbsentParentController.getNonCustodialParentRecords";

const unicorn0 = /\{0\}/g;
const emptyRecords = [
    {
        key: 0,
        editable: false,
        title: absentParentLabel,
        buttonTitle: startAltText,
        viewButtonTitle: sspView
    },
    {
        key: 1,
        editable: false,
        title: absentParentLabel,
        buttonTitle: startAltText,
        viewButtonTitle: sspView
    }
];
const genderLabel = {
    M: fatherLabel,
    F: motherLabel
};
export default class SspAbsentParentSummary extends SspBaseNavFlowPage {
    @api applicationId;

    @track recordId;
    @track currentRecordId;
    @track showDetailScreen = false;
    @track showToast = false;
    @track showLearnMore = false;

    @track absentParentSummaryInfo;

    @track motherMissing = false;
    @track fatherMissing = false;
    @track parents = [];
    @track modValue;
    @track reference = this;

    @track isReadOnlyUser = false; //CD2 2.5 Security Role Matrix. Sharon
    @track disableAbsentParentDetails = true; //CD2 2.5 Security Role Matrix. Sharon
    @track canDeleteAbsentParent = true; //CD2 2.5 Security Role Matrix. Sharon
    @track isPageAccessible = false; //CD2 2.5 Security Role Matrix.
    @track showAccessDeniedComponent = false; //CD2 2.5 Security Role Matrix.

    label = {
        learnMoreLink,
        learnMoreAltText,
        absentParentLabel,
        absentParentSummaryInfo,
        startAltText,
        editAltText,
        deleteAltText,
        deleteModalHeading,
        cancel,
        toastErrorText,
        sspViewDetails
    };

    memberFieldList = [FIRST_NAME, LAST_NAME];

    connectedCallback () {
        emptyRecords[0].viewButtonTitle = sspViewDetails.replace(unicorn0, absentParentLabel);
        emptyRecords[1].viewButtonTitle = sspViewDetails.replace(unicorn0, absentParentLabel);
        this.showHelpContentData("SSP_APP_Details_AbsentParentSummary");
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

    /**
     * @function - renderedCallback
     * @description - This method is used to called whenever there is track variable changing.
     */

    renderedCallback () {
        try {
            const sectionReference = this.template.querySelector(
                ".ssp-learnMore"
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
     * @function - get memberId.
     * @description - This method is used to get memberId value.
     */
    @api
    get memberId () {
        return this._memberId;
    }

    /**
     * @function - set memberId.
     * @description - This method is used to set memberId value.
     * @param {*} value - Member Id.
     */
    set memberId (value) {
        try {
            if (value) {
                this._memberId = value;
                this.fetchNonCustodialParentRecords();
            }
        } catch (e) {
            console.error(
                "Error in set memberId of Primary Applicant Contact page",
                e
            );
        }
    }

    @api
    get nextEvent () {
        return this.nextValue;
    }
    set nextEvent (value) {
        if (value) {
            this.nextValue = value;
            this.raiseErrorToast();
        }
    }

    @api
    get allowSaveData () {
        return this.validationFlag;
    }
    set allowSaveData (value) {
        this.validationFlag = value;
        this.saveCompleted = true;
    }

    @wire(getRecord, {
        recordId: "$memberId",
        fields: "$memberFieldList"
    })
    wiredGetMember (value) {
        this.wiredMember = value;
        const { data, error } = value;
        if (data) {
            this.member = data;
            const name = [
                getFieldValue(this.member, FIRST_NAME),
                getFieldValue(this.member, LAST_NAME)
            ]
                .filter(item => !!item)
                .join(" ");
            this.absentParentSummaryInfo = absentParentSummaryInfo.replace(
                unicorn0,
                name
            );
        } else if (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    }

    /*@wire(getNonCustodialParentRecords, {
        memberId: "$memberId"
    })
    wiredGetRecords (value) {
        this.wiredRecords = value;
        const { error, data } = value;
        if (data && data.mapResponse) {
  
            this.constructRenderingAttributes(data.mapResponse); //2.5	Security Role Matrix and Program Access. 
            this.setRecords(data);
        } else if (error) {
            console.error(
                "Error in wiredGetRecords:",
                JSON.parse(JSON.stringify(error))
            );
        }
    }*/

    fetchNonCustodialParentRecords (){
        try{
            return getNonCustodialParentRecords({
                memberId: this.memberId,
                sApplicationId: this.applicationId
            }).then(data => {
                if (data && data.mapResponse) {
                    this.constructRenderingAttributes(data.mapResponse); //2.5	Security Role Matrix and Program Access. 
                    this.setRecords(data);
                } else {
                    console.error(
                        "Error in data getRelatives:",
                        JSON.parse(JSON.stringify(data))
                    );
                }
            });
        }catch (e) {
            console.error(
                "Error in fetchNonCustodialParentRecords",
                e
            );
        }
    }

    get showMe () {
        return this.showDetailScreen === false;
    }
    /**
     * @function setRecords
     * @param {object} data - Object having data received from server.
     * @description - Sets required attributes as per data received.
     */
    setRecords = data => {
        try {
            this.motherMissing = data.mapResponse.motherMissing;
            this.fatherMissing = data.mapResponse.fatherMissing;
            if (!Array.isArray(data.mapResponse.parents)) {
                return;
            }
            const parents = data.mapResponse.parents.map(parent => {
                const title = genderLabel[parent.GenderCode__c];
                const subtitle =
                    [parent.FirstName__c, parent.MiddleInitial__c , parent.LastName__c , parent.SuffixCode__c]
                        .filter(item => !!item)
                        .join(" ") || absentParentLabel;
                const buttonTitle = editAltText.replace(unicorn0, subtitle);
                const viewButtonTitle = sspViewDetails.replace(unicorn0, subtitle);
                return {
                    key: parent.Id,
                    Id: parent.Id,
                    editable: true,
                    title,
                    subtitle,
                    buttonTitle,
                    viewButtonTitle
                };
            });
            const tileCount = !!this.motherMissing + !!this.fatherMissing;
            this.parents = Object.assign([], emptyRecords, parents).slice(
                0,
                tileCount
            );
        } catch (error) {
            console.error("Error in setRecords:", error);
        }
    };

    /**
     * @function handleAbsentParentEdit
     * @param {object} event - Event object to capture record id.
     * @description - Handles click of 'Edit' button on the tile.
     */
    handleAbsentParentEdit = event => {
        try {
            this.currentRecordId = event.detail;
            this.showDetailScreen = true;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showDetailScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAbsentMotherEdit:", error);
        }
    };

    /**
     * @function handleAbsentParentSave
     * @param {object} event - Event object.
     * @description - Handles click of 'Start' button on the tile.
     */
    handleAbsentParentSave = async event => {
        try {
            event.stopImmediatePropagation();
            const revRules = [];
            const listMemberId = [];
            listMemberId.push(this.memberId);
            const newDetailAdded = event.detail.newDetail;
            if (newDetailAdded) {
                revRules.push(
                    "newAbsentParent," + newDetailAdded + "," + listMemberId
                );
            }
            this.reviewRequiredList = revRules;
            this.showDetailScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showDetailScreen
                }
            });
            await this.fetchNonCustodialParentRecords();
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAbsentParentSave:", error);
        }
    };

    /**
     * @function handleAbsentParentCancel
     * @param {object} event - Event object.
     * @description - Handles click of 'Cancel' button on the tile.
     */
    handleAbsentParentCancel = event => {
        try {
            event.stopImmediatePropagation();
            this.showDetailScreen = false;
            const hideFrameworkEvent = new CustomEvent(events.hideSection, {
                bubbles: true,
                composed: true,
                detail: {
                    hideSectionFlag: this.showDetailScreen
                }
            });
            this.dispatchEvent(hideFrameworkEvent);
        } catch (error) {
            console.error("Error in handleAbsentParentCancel:", error);
        }
    };

    /**
     * @function raiseErrorToast
     * @description - Raises error toast if required.
     */
    raiseErrorToast = () => {
        try {
            const anyStart = this.parents.some(parent => !parent.editable);
            if (anyStart) {
                const showToastEvent = new CustomEvent("showcustomtoast", {
                    bubbles: true,
                    composed: true
                });
                this.dispatchEvent(showToastEvent);
                this.templateInputsValue = "invalid";
            } else {
                this.templateInputsValue = "valid";
            }
        } catch (error) {
            console.error("Error in raiseErrorToast:", error);
        }
    };

    /**
     * @function handleHideToast
     * @description - Hides the error toast.
     */
    handleHideToast = () => {
        this.showToast = false;
    };

    /**
     * @function openLearnMoreModal
     * @description - Opens up the learn more modal.
     */
    openLearnMoreModal = () => {
        this.showLearnMore = true;
    };

    /**
     * @function closeLearnMoreModal
     * @description - Closes the learn more modal.
     */
    closeLearnMoreModal = () => {
        this.showLearnMore = false;
    };
    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
   constructRenderingAttributes = response => {
    try {
        if (
            response != null &&
            response != undefined &&
            response.hasOwnProperty("securityMatrixSummary") &&
            response.hasOwnProperty("securityMatrixDetails")
        ) {
            const {
                securityMatrixSummary,
                securityMatrixDetails
            } = response;
            /**CD2 2.5	Security Role Matrix Sharon. */
            this.disableAbsentParentDetails =
            !sspUtility.isUndefinedOrNull(securityMatrixDetails) &&
            !sspUtility.isUndefinedOrNull(
                securityMatrixDetails.screenPermission
            ) &&
            securityMatrixDetails.screenPermission ===
                sspConstants.permission.notAccessible
                ? true
                : false;
            this.isReadOnlyUser =
                !sspUtility.isUndefinedOrNull(securityMatrixDetails) &&
                !sspUtility.isUndefinedOrNull(
                    securityMatrixDetails.screenPermission
                ) &&
                securityMatrixDetails.screenPermission ===
                    sspConstants.permission.readOnly;
        this.canDeleteAbsentParent =
            !sspUtility.isUndefinedOrNull(securityMatrixDetails) &&
            !sspUtility.isUndefinedOrNull(securityMatrixDetails.canDelete) &&
            !securityMatrixDetails.canDelete ? false : true;

        if (!securityMatrixSummary || !securityMatrixSummary.hasOwnProperty("screenPermission") || !securityMatrixSummary.screenPermission) {
            this.isPageAccessible = true;
        }
        else {
            this.isPageAccessible = !(securityMatrixSummary.screenPermission === sspConstants.permission.notAccessible);
        }
        if (!this.isPageAccessible) {
            this.showAccessDeniedComponent = true;
        } else {
            this.showAccessDeniedComponent = false;
        }
        /** */
        }
    }
    catch (error) {
        console.error(
            JSON.stringify(error.message)
        );
    }
    };
}