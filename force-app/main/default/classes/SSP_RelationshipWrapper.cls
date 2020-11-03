/***************************************************************************************************************************
*   Type         :   Wrapper Class
*   Name         :   SSP_RelationshipWrapper
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
public with sharing class SSP_RelationshipWrapper {
	    
    @AuraEnabled public String memberId {get;set;}
    @AuraEnabled public String currentUserFirstName {get;set;}
    @AuraEnabled public String currentUserLastName {get;set;}
    @AuraEnabled public String currentUserMiddleName {get;set;}
    @AuraEnabled public String currentUserSuffix {get;set;}
    @AuraEnabled public Integer currentUserAge {get;set;}
    @AuraEnabled public String otherUserFirstName {get;set;}
    @AuraEnabled public String otherUserLastName {get;set;}
    @AuraEnabled public String otherUserMiddleName {get;set;}
    @AuraEnabled public String otherUserSuffix {get;set;}
    @AuraEnabled public Integer otherUserAge {get;set;}
    @AuraEnabled public String relationshipType {get;set;}
    @AuraEnabled public String isActingParent {get;set;}
    @AuraEnabled public String isCareTaker {get;set;}
    @AuraEnabled public String intendToPursueLegalCustody {get;set;}
    @AuraEnabled public Boolean showQuestionActingParent{get;set;}
    @AuraEnabled public Boolean showQuestionCareTaker{get;set;}
    @AuraEnabled public Boolean showQuestionPursueLegalCustody{get;set;}
    @AuraEnabled public String relationshipWithLabel{get;set;}
    @AuraEnabled public String relationshipTypeLabel{get;set;}
    @AuraEnabled public String isActingParentLabel{get;set;}
    @AuraEnabled public String isCareTakerLabel{get;set;}
    @AuraEnabled public String intendToPursueLegalCustodyLabel{get;set;}
    @AuraEnabled public Boolean ageLessThanTenShowError {get;set;}
    @AuraEnabled public Boolean ageLessThanTwentyShowError {get;set;}
    @AuraEnabled public Boolean individualAgeLessThanRelatedShowError {get;set;}
    @AuraEnabled public Boolean individualIsMinorShowError {get;set;}
    @AuraEnabled public Boolean individualAgeGreaterThanRelatedShowError {get;set;}
    @AuraEnabled public Boolean individualAgeLessThanRelatedStepShowError  {get;set;}
    @AuraEnabled public List<String> genderBasedRelationshipValues  {get;set;}
}