import { LightningElement, api, track } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import { NavigationMixin } from "lightning/navigation";
import apConstants from "c/sspConstants";
import sspMessageCenterAnnouncement from "@salesforce/label/c.SSP_MessageCenterAnnouncement";
import sspMessageCenterToDo from "@salesforce/label/c.SSP_MessageCenterToDo";
import sspMessageCenterDateMessageReceived from "@salesforce/label/c.SSP_MessageCenterDateMessageReceived";
import sspNoticeCardPhoneNumberLink from "@salesforce/label/c.SSP_NoticeCardPhoneNumberLink";
import sspMessageCenterNoMatchFound from "@salesforce/label/c.SSP_MessageCenterNoMatchFound";

export default class SspMessageCenterTable extends NavigationMixin(
    LightningElement
) {
    iconUrl = sspIcons + "/sspIcons/ic_sort@2x.png";
    trashIcon = sspIcons + apConstants.url.removeIcon;

    @api tableColumns;
    @api msgTableData;
    @api noSearchFound = false;
    @api searchValue = "";

    @track sortDirection = "desc";

    @track authorizedRepresentativeAccessRequest = false;
    @track AssisterAccessRequest = false;
    @track showDeletePopUp = false;
    @track showSpinner = false;
    @track applicationId;
    @track authAssisterNotificationId;
    customLabel = {
        sspMessageCenterAnnouncement,
        sspMessageCenterToDo,
        sspMessageCenterDateMessageReceived,
        sspNoticeCardPhoneNumberLink,
        sspMessageCenterNoMatchFound

    };

    /**
     * @function : Getter setters for application Id.
     * @description : Getter setters for application Id.
     */
    @api
    get messageTableData () {
        try{
            return this.msgTableData;
        } catch (error) {
            console.error(
               error
            );
            return null;
        }
    }
    set messageTableData (value) {
        try{
            this.msgTableData = value;
        } catch (error) {
            console.error(
                error
            );
        }
    } 

/**
* @function : handleClick.
* @description : handle button click of Todo .
* @param {*} event - This event returns particular class.
*/

    handleClick (event) {
       try {this.showSpinner=true;
        const buttonAction = event.target.name;
        const buttonId = event.target.value;
        this.buttonIds = buttonId;
        this.authAssisterNotificationId = buttonId;
        this.dispatchEvent(new CustomEvent("message",{
            detail: buttonId
        })
        );
        for (this.i = 0; this.i < this.msgTableData.length; this.i++) {
            if (this.msgTableData[this.i].sfdcId === buttonId) {
                this.applicationId = this.msgTableData[this.i].linkedId;
            }
        }
        if (
            buttonAction ===
            "opens Authorized Representative Access Request modal"
        ) {
            this.showSpinner = false;
            this.authorizedRepresentativeAccessRequest = true;
        } else if (buttonAction === "opens Assister Access Request modal") {
            this.showSpinner = false;
            this.AssisterAccessRequest = true;            
        } else if (
            buttonAction === "navigate user to Find a DCBS Office page"
        ) { 
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: apConstants.navigationUrl.findDCBSOffice
                }
            });
        } else if (buttonAction === "navigate user to Document Center") {

            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "documents__c"
                }
            });
           
         } else if (
            buttonAction === "navigate user to Renewal of Benefits screen"
        ){
            this[NavigationMixin.Navigate]({
                type: apConstants.communityPageNames.community,
                attributes: {
                    name: apConstants.communityPageNames.renewals
                },
                state: {
                    mode: "Renewal"
                }
            });
        } else if (buttonAction === "navigate user to Claim Payments screen") {
            
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "claims__c"
                }
            }); 
        } else if (buttonAction === "navigate user to Application Summary") {

            


            this[NavigationMixin.Navigate]({
                type: apConstants.communityPageNames.community,
                attributes: {
                    name: apConstants.communityPageNames.applicationSummaryApi
                },
                state: {
                    applicationId: this.applicationId,
                    mode: "intake"
                }
            });
        } else if (
            buttonAction ===
            "navigate user to Message Center with Notice tab selected"
        ) {
            this.showSpinner = false;
            this.dispatchEvent(new CustomEvent("notices"));
        } else if (
            buttonAction ===
            "navigate user to the assisted individual's Client View Dashboard"
        ) {
            // need implementation
            /* this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: apConstants.navigationUrl.findDCBSOffice
                }
            }); */
        } else if (
            buttonAction ===
            "navigate user to Renewal of assisted individual's Benefits screen"
        ) {
            this[NavigationMixin.Navigate]({
                type: apConstants.communityPageNames.community,
                attributes: {
                    name: apConstants.communityPageNames.renewals
                },
                state: {
                    mode: "Renewal"
                }
            });
        } else if (buttonAction === "navigate user to Hearing Summary") {                     
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Hearings__c"
                },
                state: {
                    hearingId: this.applicationId
                }
            }); 
        }
        else if (buttonAction ==="call") {
            this.showSpinner = false;
            this.template.querySelector(".ssp-callPhone").click();
        }}
       catch (error) {
           console.error(
               "Error in handleClick of sspMessageCenterTable" +
               JSON.stringify(error.message)
           );
       }
    }
/**
 * @function : handleThrashClick.
 * @description : handle trash icon click .
 * @param {*} event - This event returns particular class.
 */
    handleThrashClick = (event) => {
        try{const buttonId = event.currentTarget.dataset.id;
        this.buttonIds = buttonId;
        for (this.i = 0; this.i < this.msgTableData.length; this.i++) {
            if (this.msgTableData[this.i].sfdcId === buttonId) {
                this.applicationId = this.msgTableData[this.i].linkedId;
            }
        }
        this.dispatchEvent(new CustomEvent("message"));
        this.showDeletePopUp = true;}
        catch (error) {
            console.error(
                "Error in handleTrashClick of sspMessageCenterTable" +
                JSON.stringify(error.message)
            );
        }
    };

/**
* @function 		: handleDeleteSuccess.
* @description 	: handle success event of Delete Application Modal.
**/
    handleDeleteSuccess = () => {
        try{this.dispatchEvent(new CustomEvent("update"));
        this.showDeletePopUp = false;}
        catch (error) {
            console.error(
                "Error in handleDeleteSuccess of sspMessageCenterTable" +
                JSON.stringify(error.message)
            );
        }
    };

/**
 * @function 		: hideDeleteCancel.
 * @description 	: hide Delete Application Modal.
 **/
    handleDeleteCancel = () => {
        try{this.showDeletePopUp = false;}
        catch (error) {
            console.error(
                "Error in handleDeleteCancel of sspMessageCenterTable" +
                JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function 		: hideAuthConsentModal.
     * @description 	: hide Auth Rep Consent Modal.
     **/
    hideAuthConsentModal = () => {
        try {
            this.dispatchEvent(new CustomEvent("update"));
            this.authorizedRepresentativeAccessRequest = false;
        } catch (error) {
            console.error(
                "failed in hideAuthConsentModal in sspMessageCenterTable" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: hideAssisterRequestModal.
     * @description 	: hide Assister Request Consent Modal.
     **/
    hideAssisterConsentModal = () => {
        try {
            this.dispatchEvent(new CustomEvent("update"));
            this.AssisterAccessRequest = false;
        } catch (error) {
            console.error(
                "failed in hideAuthConsentModal in sspMessageCenterTable" +
                    JSON.stringify(error)
            );
        }
    };

/**
 * @function : sortByKey.
 * @description : handle the Sort of Message .
 * @param {*} event - This event returns particular class.
 */
    sortByKey (event) {
        
        try {event.preventDefault();
        const order = this.sortDirection;
        if (order === "asc") {
            this.dispatchEvent(new CustomEvent("sort", {
                detail: order
            })
            );
            this.sortDirection = "desc";
        }
        if (order === "desc") {
            this.dispatchEvent(new CustomEvent("sort", {
                detail: order
            })
            );
            this.sortDirection = "asc";
            }
        } catch (error) {
            console.error(
                "Error in sortByKey of sspMessageCenterTable" +
                JSON.stringify(error.message)
            );
        }
    }
    
}