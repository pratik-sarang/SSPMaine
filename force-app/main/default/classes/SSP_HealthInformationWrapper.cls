/*
* classname 		: SSP_HealthInformationWrapper
* @description 		: This class is use to set the Health information wrapper data
* @author 			: Ashwin Kasture
* @date 			: 14/11/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		14/11/2019		Initial Version
*/
public with sharing class SSP_HealthInformationWrapper { 
    @AuraEnabled public String sApplId {get;set;}
    @AuraEnabled public String sMemberId {get;set;}
    @AuraEnabled public String sMemberName {get;set;}
    @AuraEnabled public String sProgramsApplied {get;set;}
    @AuraEnabled public String sMedicaidType {get;set;}
    @AuraEnabled public String sIsUSCitizen {get;set;}
    @AuraEnabled public String sGenderCode {get;set;}
    @AuraEnabled public Integer iMemberAge {get;set;}
    @AuraEnabled public String sHasEmergencyMedicalCondition {get;set;}
    @AuraEnabled public String sIsDisabled {get;set;}
    @AuraEnabled public String sIsBlind {get;set;}
    @AuraEnabled public String sIsRecoveryFromIllnessOrInjury {get;set;}
    @AuraEnabled public String sHasPendingAccidentSettlement {get;set;}
    @AuraEnabled public String sIsReceivingMedicareBenefit {get;set;}
    @AuraEnabled public String sIsPregnantInLastThreeMonths {get;set;}
    @AuraEnabled public String sIsRequestingOrReceivingCIS {get;set;}
    @AuraEnabled public String sIsReceivingCaretakerServices {get;set;}
    @AuraEnabled public Boolean isDisabilityVerified {get;set;}
    @AuraEnabled public Boolean isBlindnessVerified {get;set;}
    @AuraEnabled public Boolean isMedicareVerified {get;set;}
    @AuraEnabled public Boolean isOngoingEmergencyMedicalCondition {get;set;}
    @AuraEnabled public String sRACSelectedOptions {get;set;} //#385049
    public class SSP_ApplicationData{
        @AuraEnabled public String sHasPendingAccidentSettlement {get;set;}
    }
}