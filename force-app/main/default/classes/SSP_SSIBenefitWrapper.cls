/*
* classname 		: SSP_SSIBenefitWrapper
* @description 		: This is the Wrapper class for SSP_SSIBenefitCtrl class.
* @author 			: Sai Kiran
* @date 			: 01/10/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SSIBenefitWrapper {
        @AuraEnabled public String sBenefitId {get;set;}
        @AuraEnabled public String sMemberId {get;set;}
        @AuraEnabled public String sApplicationStatus {get;set;}
        @AuraEnabled public String sBenefitDenialReason {get;set;}
        @AuraEnabled public Date dBenefitApplicationDate {get;set;}
        @AuraEnabled public Date dBenefitDenialDate {get;set;}
}