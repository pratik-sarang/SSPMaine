/***************************************************************************************************************************
*   Type         :   Wrapper Class
*   Name         :   SSP_MemberDisabilityWrapper
*   Created By   :   Sanchita Tibrewala
*   Created Date :   12/01/2019
*   Description  :   Wrapper for Relationship Information Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 12/01/2019     Initial Version
*****************************************************************************************************************************/
public class SSP_MemberDisabilityWrapper {
    
	@AuraEnabled public String Id {get;set;}    
	@AuraEnabled public String memberFullName {get;set;}
    @AuraEnabled public Integer age {get;set;}
    @AuraEnabled public String benefitTypeCode {get;set;}
    @AuraEnabled public String hasEndStageRenalDisease {get;set;}
    @AuraEnabled public String unableToBuyCookForSelf {get;set;}
    @AuraEnabled public String parentUnableToCareForChild {get;set;}
    @AuraEnabled public String disabilityPermanentTemporary {get;set;}
    @AuraEnabled public String genderCode {get;set;}
    @AuraEnabled public String programsApplied {get;set;}
    @AuraEnabled public Boolean isNonMagi {get;set;}
    @AuraEnabled public Boolean isDisabilityVerified {get;set;}
    @AuraEnabled public Boolean isBlindnessVerified {get;set;}
    
}