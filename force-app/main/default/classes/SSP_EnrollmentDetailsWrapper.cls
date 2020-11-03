/*
* classname 	: SSP_EnrollmentDetailsWrapper
* @description 	: This class is use as a wrapper for Health selection information
* @author 		: Ashwin Kasture
* @date 		: 14/11/2019
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		14/11/2019		Initial Version
*/
public with sharing class SSP_EnrollmentDetailsWrapper {
    //Insurance Company variable
    @AuraEnabled public String sInsuranceCompanyId {get;set;}
    @AuraEnabled public String sInsuranceCompanyName {get;set;}
    @AuraEnabled public String sAddressLine1 {get;set;}
    @AuraEnabled public String sAddressLine2 {get;set;}
    @AuraEnabled public String sCity {get;set;}
    @AuraEnabled public String sCountryCode {get;set;}
    @AuraEnabled public String sCountyCode {get;set;}
    @AuraEnabled public String sStateCode {get;set;}
    @AuraEnabled public String sZipCode4 {get;set;}
    @AuraEnabled public String sZipCode5 {get;set;}
    @AuraEnabled public String sTimeTravelDate {get;set;}
    @AuraEnabled public Boolean bisHealthCareCoverageApproved {get;set;}
    @AuraEnabled public Boolean bisHealthCarePolicyHolderOutsideCase {get;set;}    

    //Insurance Policy Details variable
	@AuraEnabled public String sSourceHealthCareCoverage {get;set;}
	@AuraEnabled public String sInsurancePolicyId {get;set;}
    @AuraEnabled public String sInsurancePlanName {get;set;}
    @AuraEnabled public String sPlanPolicyId {get;set;}
    @AuraEnabled public String sPlanGroupId {get;set;}
    @AuraEnabled public String sHouseholdEnrolledPlan {get;set;}
    @AuraEnabled public Boolean bIsEnrolledInInsurance {get;set;}
    @AuraEnabled public Boolean bDoNotHaveAllInformation {get;set;}
    @AuraEnabled public Boolean isKIHIPPSourceOfCoverage {get;set;}
    @AuraEnabled public Map<String,String> mapEnrollmentTierLevel {get;set;}
    @AuraEnabled public Map<String,String> mapSuffixCode {get;set;}
	@AuraEnabled public List<SSP_SourcesOfCoverage__mdt> lstSourceOfCoverage {get;set;}

    //Covered Individual variables
    @AuraEnabled public List<SSP_CoveredIndCls> lstHOHMembers {get;set;}
    @AuraEnabled public SSP_CoveredIndCls objPolicyHolder {get;set;}
    @AuraEnabled public SSP_CoveredIndCls objOutsidePolicyHolder {get;set;}
    @AuraEnabled public String sPolicyHolderMemberIdDelete {get;set;}
    @AuraEnabled public List<SSP_CoveredIndCls> lstCoveredInd {get;set;}
    @AuraEnabled public List<String> lstCoveredIndDelete {get;set;}
    @AuraEnabled public List<SSP_CoveredIndCls> lstOutsideCoveredInd {get;set;}
    @AuraEnabled public List<String> lstOutsideCoveredIndDelete {get;set;}

    /*
    * classname     : SSP_CoveredIndCls
    * @description  : This inner class use to store the List of covered individual Data
    * @author       : Ashwin Kasture
    * @date         : 14/11/2019
    */
    public with sharing class SSP_CoveredIndCls {
        @AuraEnabled public String sMemberId {get;set;}
        @AuraEnabled public Boolean bIsExistingRecord {get;set;}
        @AuraEnabled public String sCoveredIndId {get;set;}
        @AuraEnabled public String sCoveredIndSuffix {get;set;}
    	@AuraEnabled public String sCoveredIndFirstName {get;set;}
        @AuraEnabled public String sCoveredIndMiddleInitial {get;set;}
    	@AuraEnabled public String sCoveredIndLastName {get;set;}
        @AuraEnabled public Boolean bIsEnrolled {get;set;}
        @AuraEnabled public Boolean bIsDefault {get; set;}
    }
}