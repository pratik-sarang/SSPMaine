/*
 * Component Name: SspMyInformationLandingPage.
 * Author: Kireeti Gora, Chirag. 
 * Description: This file handles My information Screen.
 * Date: 02/01/2020.
 **/
import { LightningElement, track, wire } from "lwc";
import getMyInformationDetails from "@salesforce/apex/SSP_MyInformationController.getMyInformationDetails";
import getCaseOwnershipFlag from "@salesforce/apex/SSP_MyInformationController.getCaseOwnershipFlag";
import sspMyInformation from "@salesforce/label/c.SSP_MyInformation";
import sspEditButton from "@salesforce/label/c.SSP_EditButton";
import sspContactInformation from "@salesforce/label/c.SSP_ContactInformation";
import sspCommunicationPreferences from "@salesforce/label/c.SSP_CommunicationPreferences";
import sspAdditionalPreferences from "@salesforce/label/c.SSP_AdditionalPreferences";
import sspName from "@salesforce/label/c.SSP_Name";
import sspEmail from "@salesforce/label/c.SSP_Email";
import sspPhoneNumber from "@salesforce/label/c.SSP_PhoneNumber";
import sspSecondaryPhoneNumber from "@salesforce/label/c.ssp_secondaryPhoneNumber";
import sspPhysicalAddress from "@salesforce/label/c.SSP_PhysicalAddress";
import sspMailingAddress from "@salesforce/label/c.SSP_MailingAddress";
import sspPreferredSpokenLanguage from "@salesforce/label/c.SSP_PreferredSpokenLanguage";
import sspPreferredWrittenLanguage from "@salesforce/label/c.SSP_PreferredWrittenLang";
import sspContactMethods from "@salesforce/label/c.SSP_ContactMethods";
import sspTaxFormPreferences from "@salesforce/label/c.SSP_TaxFormPreferences";
import sspLocalDCBSOffice from "@salesforce/label/c.SSP_LocalDCBSOffice";
import sspLandingPageNoticeText from "@salesforce/label/c.SSP_LandingPageNoticeText";
import sspClickEditEmailAddress from "@salesforce/label/c.SSP_ClickEditEmailAddress";
import sspClickEditPhoneNumber from "@salesforce/label/c.SSP_ClickEditPhoneNumber";
import sspClickEditSecondaryPhoneNumber from "@salesforce/label/c.SSP_ClickEditSecondaryPhoneNumber";
import sspClickEditPreferredWrittenLanguage from "@salesforce/label/c.SSP_ClickEditPreferredWrittenLanguage";
import sspClickEditPreferredSpokenLanguage from "@salesforce/label/c.SSP_ClickEditPreferredSpokenLanguage";
import sspClickChangeEditMethods from "@salesforce/label/c.SSP_ClickChangeEditMethods";
import sspNoticeText1 from "@salesforce/label/c.SSP_NoticeText1";
import sspNoticeText2 from "@salesforce/label/c.SSP_NoticeText2";
import sspNoticeCardPhoneNumber from "@salesforce/label/c.SSP_NoticeCardPhoneNumber";
import sspNoticeText3 from "@salesforce/label/c.SSP_NoticeText3";
import sspNoticeText4 from "@salesforce/label/c.SSP_NoticeText4";
import sspReportChangeDot from "@salesforce/label/c.SSP_ReportChangeDot";
import sspDot from "@salesforce/label/c.SSP_Dot";
import sspReportChange from "@salesforce/label/c.SSP_ReportChange";

import sspNoticeCardPhoneNumberLink from "@salesforce/label/c.SSP_NoticeCardPhoneNumberLink";
import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";
//const hamburgerLabel = "hamburger"; // Added as part of Defect - 383060

export default class SspMyInformationLandingPage extends LightningElement {
    @track objMember;
    @track hasActiveApplication = false;
    @track showAllDetails = false;
    @track showEmail = false;
    @track showWritten = false;
    @track showChangePrimaryPhone = false;
    @track showChangeSecondaryPhone = false;
    @track showChangePreferredSpokenLanguage = false;
    @track showChangeContactMethod = false;
    @track objInformationToRefresh;
    @track Office;
    @track caseOwner;
    @track showSpinner = true;
    @track showWorkerPortalBanner = false; 
    @track isReadOnlyUser = false; //2.5 Security Role Matrix and Program Access.
    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.	
    @track hasActiveCase = false;
    @track showRACFlag = false;
    @track disableEdit = true;//387805
    customLabel = {
        sspMyInformation,
        sspEditButton,
        sspContactInformation,
        sspCommunicationPreferences,
        sspAdditionalPreferences,
        sspName,
        sspEmail,
        sspPhoneNumber,
        sspSecondaryPhoneNumber,
        sspPhysicalAddress,
        sspMailingAddress,
        sspPreferredSpokenLanguage,
        sspPreferredWrittenLanguage,
        sspContactMethods,
        sspTaxFormPreferences,
        sspLocalDCBSOffice,
        sspLandingPageNoticeText,
        sspClickEditEmailAddress,
        sspClickEditPhoneNumber,
        sspClickEditSecondaryPhoneNumber,
        sspClickEditPreferredWrittenLanguage,
        sspClickEditPreferredSpokenLanguage,
        sspClickChangeEditMethods,
        sspNoticeText1,
        sspNoticeText2,
        sspNoticeCardPhoneNumber,
        sspNoticeText3,
        sspNoticeText4,
        sspReportChangeDot,
        sspDot,
        sspReportChange,
        sspNoticeCardPhoneNumberLink
    };
    /*@wire(CurrentPageReference)
    wiredPageRef (value){
      if (!value) {
        return;
      }
        
      if( this.hasActiveCase === false){
          this.hasActiveCase = value.attributes.hasActiveCase;
          const racButtonLabel = value.attributes.racButtonLabel;
            if(racButtonLabel === sspReportAChange){
                this.showRACFlag = true;
            }
            else{
                this.showRACFlag = false;
            }
      }          
    }*/
    //2.5 Security Role Matrix and Program Access.
    get showContent (){
        return this.showAllDetails && this.isScreenAccessible;
    }

    //2.5 Security Role Matrix and Program Access.
    get showEditOptions (){
        return this.hasActiveApplication && !this.isReadOnlyUser;
    }

    /**
     * @function 		: getCaseOwnerInfo.
     * @description 	: Standard method for getting case owner info.
     * */
    @wire(getCaseOwnershipFlag)
    getCaseOwnerInfo ({ error, data }) {
        try {
            if (!sspUtility.isUndefinedOrNull(data)) {
                this.caseOwner = data;
                if (
                    this.caseOwner.includes(sspConstants.headerConstants.CHANGE)
                ) {
                    this.showWorkerPortalBanner = true;
                } else {
                    this.showWorkerPortalBanner = false;
                }
            } else if (error) {
                console.error(
                    "Error in wiredHOHFlag wire call" +
                        JSON.stringify(error.message)
                );
            }
        } catch (error) {
            console.error(
                "failed in getMyInformation in getCaseOwnerInfo" +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function 		: handleClose.
     * @description 	: Method to handle show/close of Pop up.
     * */

    handleClose = () => {
        try {
            this.showEmail = false;
            this.showWritten = false;
            this.showChangePrimaryPhone = false;
            this.showChangeSecondaryPhone = false;
            this.showChangePreferredSpokenLanguage = false;
            this.showChangeContactMethod = false;
            this.showSpinner = true;
            this.connectedCallback();
        } catch (error) {
            console.error(
                "failed in handleClose in SspMyInformationLandingPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: connectedCallback.
     * @description 	: method to set spinner .
     **/
    connectedCallback () {
        try {
            //Start - Added as part of Defect - 383060
            let pageParam = "";
            const url = new URL(window.location.href);
            pageParam = url.searchParams.get("from")
                ? url.searchParams.get("from")
                : "";
            //End - Added as part of Defect - 383060
            getMyInformationDetails({ pageParam: pageParam }).then(result => {
                if (result) {
                    /**2.5	Security Role Matrix and Program Access.*/
                    this.constructRenderingAttributes(result.mapResponse);
                    this.showAccessDeniedComponent = !this.isScreenAccessible;
                    /** */

                    this.objInformationToRefresh = result;
                    if ("memberDetail" in result.mapResponse) {
                        this.objMember = JSON.parse(
                            result.mapResponse.memberDetail
                        );                        
                        if (!sspUtility.isUndefinedOrNull(this.objMember.PrimaryPhoneNumber__c) && !this.objMember.PrimaryPhoneNumber__c.includes("-")) {
                            // eslint-disable-next-line camelcase
                            this.objMember.PrimaryPhoneNumber__c = this.objMember.PrimaryPhoneNumber__c.replace(/(\d{3})(\d{3})(\d{4})/, "$1-$2-$3");
                        }

                        if (!sspUtility.isUndefinedOrNull(this.objMember.SecondaryPhoneNumber__c) && !this.objMember.SecondaryPhoneNumber__c.includes("-")) {
                            // eslint-disable-next-line camelcase
                            this.objMember.SecondaryPhoneNumber__c = this.objMember.SecondaryPhoneNumber__c.replace(/(\d{3})(\d{3})(\d{4})/, "$1-$2-$3");
                        }
                    }
                    if ("physicalAddress" in result.mapResponse) {
                        this.objMember.physicalAddress =
                            result.mapResponse.physicalAddress;
                    }
                    if ("mailingAddress" in result.mapResponse) {
                        this.objMember.mailingAddress =
                            result.mapResponse.mailingAddress;
                    }
                    if ("activeApplication" in result.mapResponse) {
                        this.hasActiveApplication = true;
                    }
                    if ("office" in result.mapResponse) {
                        this.hasActiveApplication = true;
                        this.office = result.mapResponse.office;
                    }
                    if("showRAC" in result.mapResponse){                        
                        this.showRACFlag = result.mapResponse.showRAC;
                    }
                    // 387805 start 
                    if("disableEdit" in result.mapResponse){
                        this.disableEdit = false;
                    }
                    // 387805 end
                    this.showAllDetails = true;
                    this.showSpinner = false;
                }
            });
        } catch (error) {
            console.error(
                "failed in connectedCallback in SspAuthRepsAssistAndAgents" +
                    JSON.stringify(error)
            );
        }
    }
    /**
     * @function 		: handleEmailChange.
     * @description 	: Method to handle show/close of Email Pop up.
     * */
    handleEmailChange = () => {
        try {
            this.showEmail = true;
        } catch (error) {
            console.error(
                "failed in handleEmailChange in SspMyInformationLandingPage" +
                    JSON.stringify(error)
            );
        }
    };
    /**
     * @function 		: handleWrittenChange.
     * @description 	: Method to handle show/close of handleWrittenChange Pop up.
     * */
    handleWrittenChange = () => {
        try {
            this.showWritten = true;
        } catch (error) {
            console.error(
                "failed in handleWrittenChange in SspMyInformationLandingPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handlePrimaryPhoneChange.
     * @description 	: Method to handle show/close of change primary phone pop up.
     * */
    handlePrimaryPhoneChange = () => {
        try {
            this.showChangePrimaryPhone = true;
        } catch (error) {
            console.error(
                "failed in handlePrimaryPhoneChange in SspMyInformationLandingPage.showChangePrimaryPhone" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleSecondaryPhoneChange.
     * @description 	: Method to handle show/close of change secondary phone pop up.
     * */
    handleSecondaryPhoneChange = () => {
        try {
            this.showChangeSecondaryPhone = true;
        } catch (error) {
            console.error(
                "failed in handlePrimaryPhoneChange in SspMyInformationLandingPage.showChangeSecondaryPhone" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleSpokenLanguage.
     * @description 	: Method to handle show/close of change preferred spoken language.
     * */
    handleSpokenLanguage = () => {
        try {
            this.showChangePreferredSpokenLanguage = true;
        } catch (error) {
            console.error(
                "failed in handlePrimaryPhoneChange in SspMyInformationLandingPage" +
                    JSON.stringify(error)
            );
        }
    };

    /**
     * @function 		: handleContactMethodChange.
     * @description 	    : Method to handle show/close of change contact method.
     * */
    handleContactMethodChange = () => {
        try {
            this.showChangeContactMethod = true;
        } catch (error) {
            console.error(
                "failed in handleContactMethodChange in SspMyInformationLandingPage" +
                    JSON.stringify(error)
            );
        }
    };
    
    /**
    * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
    * @description : This method is used to construct rendering attributes.
    * @param {object} response - Backend response.
    */
    constructRenderingAttributes = response => {
        try {
            if (response != null && response != undefined && response.hasOwnProperty("screenPermission")) {
                const { screenPermission : securityMatrix } = response;                
                this.isReadOnlyUser = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == sspConstants.permission.readOnly);
                this.isScreenAccessible = (!sspUtility.isUndefinedOrNull(securityMatrix) && securityMatrix.screenPermission == sspConstants.permission.notAccessible) ? false : true;                                
            }
            else{
                this.isScreenAccessible = true;
            }
        }
        catch (error) {
            console.error(
                JSON.stringify(error.message)
            );
        }
    };

}