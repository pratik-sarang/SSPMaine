/*
* classname     : SSP_HealthEnrollmentWrapper
* @description  : This class is use to assign Healthcare Enrollment Details
* @author       : Ashwin Kasture
* @date         : 05/12/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        05/12/2019      Initial Version
*/
public class SSP_HealthEnrollmentWrapper {
    
    @AuraEnabled public String sInsurancePolicyId {get;set;}
    @AuraEnabled public Integer sPolicyDCId {get;set;}
	@AuraEnabled public String sPolicyNumber {get;set;}
    @AuraEnabled public String sPlanName {get;set;}
    @AuraEnabled public String sTypeOfCoverageCode {get;set;}
    @AuraEnabled public String sTypeOfCoverageCodeName {get;set;}
    @AuraEnabled public Boolean bIsWPRecord {get;set;}
    
    @AuraEnabled public String sPolicyHolderId {get;set;}
    @AuraEnabled public String sPolicyHolderFirstName {get;set;}
    @AuraEnabled public String sPolicyHolderLastName {get;set;}
	@AuraEnabled public Boolean bPolicyHolderIsHealthFacilityExist {get; set;}    
	@AuraEnabled public Boolean bHideRemoveIcon {get; set;}    
    @AuraEnabled public List<SSP_CoveredIndCls> lstCoverInd {get; set;}
    
    /*
    * classname     : SSP_CoveredIndCls
    * @description  : This inner class use to store the List of covered individual Data
    * @author       : Ashwin Kasture
    * @date         : 05/12/2019
    */
    public class SSP_CoveredIndCls {
        @AuraEnabled public String sCoveredIndId {get;set;}
        @AuraEnabled public String sCoveredIndDCId {get;set;}
    	@AuraEnabled public String sCoveredIndFirstName {get;set;}
    	@AuraEnabled public String sCoveredIndLastName {get;set;}
        @AuraEnabled public Boolean bIsWPIndividualRecord {get;set;}
        @AuraEnabled public Boolean bIsDefault {get; set;}
        @AuraEnabled public Boolean bIsCoveredHealthFacilityExist {get; set;}
        @AuraEnabled public List<SSP_HealthInsuranceFacilityType__c> lstHealthInsuranceFacilityType {get; set;}
    } 
    
    /*
    * classname     : SSP_TrackDeletionWrapper
    * @description  : This inner class use to store the Track Deletion Data
    * @author       : Sai Kiran
    * @date         : 01/16/2019
    */
    public class SSP_TrackDeletionWrapper {
        @AuraEnabled public Boolean bIsCoveredIndDeletion {get;set;}
        @AuraEnabled public String sApplicationId {get;set;}
        @AuraEnabled public String sSalesforceId {get;set;}
        @AuraEnabled public String sOtherReason {get;set;}
        @AuraEnabled public Integer sParentDCId {get;set;}
        @AuraEnabled public String sEndReason {get;set;}
        @AuraEnabled public String sMemberId {get;set;}
        @AuraEnabled public String sSource {get;set;}
    	@AuraEnabled public String sDCId {get;set;}
    	@AuraEnabled public Date dEndDate {get;set;}
    } 
}