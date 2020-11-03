/*
* classname 		: SSP_AnotherStateBenefitsWrapper
* @description 		: This wrapper class is used for Benefits from another state summary and details screen.
* @author 			: Nupoor Nimbalkar
* @date 			: 11/27/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar 		11/27/2019		Initial Version
* Sai Kiran				12/09/2019		Modified
*/
public with sharing class SSP_AnotherStateBenefitsWrapper {    
    
    public class SSP_BenefitProgramList{
        @AuraEnabled public String sBenefitId {get;set;}
        @AuraEnabled public String sBenefitProgram {get;set;}
        @AuraEnabled public Date dBenefitStartDate {get;set;}
        @AuraEnabled public Date dBenefitEndDate {get;set;}
    }
    
    public class SSP_BenefitDataList{
        // Variable used to Store the Benefit ID's which is used at the time of Deletion
        @AuraEnabled public String sBenefitIds {get;set;}
        @AuraEnabled public String sMemberId {get;set;}
        @AuraEnabled public String sBenefitState {get;set;}
        @AuraEnabled public String sBenefitCounty {get;set;}
        @AuraEnabled public String sBenefitUniqueKey {get;set;}
        @AuraEnabled public Boolean bIsInsert {get;set;}
        @AuraEnabled public Boolean bSnapCheck {get;set;}
        @AuraEnabled public Boolean bTanfCheck {get;set;}
        @AuraEnabled public Boolean bMedicaidCheck {get;set;}
        @AuraEnabled public List<SSP_BenefitProgramList>  lstBenefitProgramList{get;set;}
    }
    
    //Below Wrapper Class is used to Store the SSP_Benefits__c Records while Fetching
    //which are to be shown in Benefit Summary Page
    public class SSP_BenefitRecords {
        // Variable used to Store the Benefit ID's which is used at the time of Deletion
        @AuraEnabled public String sBenefitIds {get;set;}
        //Collecting the ID's as Individual which is used for Updating the Respective Records
        @AuraEnabled public String sBenefitSNAPId {get;set;}
        @AuraEnabled public String sBenefitTANFId {get;set;}
        @AuraEnabled public String sBenefitMEDICAIDId {get;set;}
        @AuraEnabled public String sMemberId {get;set;}
        @AuraEnabled public String sBenefitState {get;set;}
        @AuraEnabled public String sBenefitStateLabel {get;set;}
        @AuraEnabled public String sBenefitCounty {get;set;}
        @AuraEnabled public String sBenefitProgram {get;set;}
        @AuraEnabled public String sBenefitProgramLabel {get;set;}
        @AuraEnabled public String sBenefitUniqueKey {get;set;}
        @AuraEnabled public Boolean bIsCounty {get;set;}
        //To Store the Program Dates individually
        @AuraEnabled public Date dBenefitSNAPStartDate {get;set;}
        @AuraEnabled public Date dBenefitSNAPEndDate {get;set;}
        @AuraEnabled public Date dBenefitTANFStartDate {get;set;}
        @AuraEnabled public Date dBenefitTANFEndDate {get;set;}
        @AuraEnabled public Date dBenefitMEDICADEStartDate {get;set;}
        @AuraEnabled public Date dBenefitMEDICADEEndDate {get;set;}
        
    }
}