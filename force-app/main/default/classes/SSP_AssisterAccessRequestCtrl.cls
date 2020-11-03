/*
* classname 	: SSP_AssisterAccessRequestCtrl
* @description 	: This class is use to Search and Request Access for Assister representative.
* @author 		: Rahul Kumar
* @date 		: 17th June 2020
* MODIFICATION LOG
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Rahul Kumar 		17th June 2020	Initial Version
*/

public without sharing class SSP_AssisterAccessRequestCtrl {

        /*
    * classname 	: SSPDCResponseWrapper
    * @description 	: This class is use set the SSPDC response data into wrapper variables to send it to UI.
    * @author 		: Rahul Kumar
    * @date 		: 17th June 2020
    */
    public class ReverseSSPDCResponseWrapper {
        @AuraEnabled public List<AuthRepAndAssiterClientInfoWrapper> AuthrepandAssiterClientInfo {get;set;}
    	@AuraEnabled public List<CaseInfoWrapper> CaseInfo {get;set;}
    }
    
    /*
    * classname 	: CaseInfoWrapper
    * @description 	: This class is use set the Case Info SSPDC response data into wrapper variables to send it to UI.
    * @author 		: Rahul Kumar
    * @date 		: 17th June 2020
    */
    public class CaseInfoWrapper {
       	@AuraEnabled public String CaseNumber {get;set;}
        @AuraEnabled public String ProgramCode {get;set;}
        @AuraEnabled public String LastUpdatedDate {get;set;}
        @AuraEnabled public String ApplicationNumber {get;set;}
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String PrimaryPhoneTypeCode {get;set;}
        @AuraEnabled public String PrimaryPhoneNumber {get;set;}
        @AuraEnabled public String PrimaryPhoneExetnsion {get;set;}
        @AuraEnabled public String SecondaryPhoneTypeCode {get;set;}
        @AuraEnabled public String SecondaryPhoneNumber {get;set;}
        @AuraEnabled public String SecondaryPhoneExtension {get;set;}
        @AuraEnabled public String PreferredWrittenLanguageCode {get;set;}
        @AuraEnabled public String PreferredSpokenLanguageCode {get;set;}
        @AuraEnabled public String PreferredNotificationMethodCode {get;set;}
    }
    
     /*
    * classname 	: AuthRepAndAssiterClientInfoWrapper
    * @description 	: This class is use set the Auth Rep/ Assister SSPDC response data into wrapper variables to send it to UI.
    * @author 		: Rahul Kumar
    * @date 		: 17th June 2020
    */
    public class AuthRepAndAssiterClientInfoWrapper {
        @AuraEnabled public String UserId  {get;set;}
        @AuraEnabled public String RepresentativeRelationshipCode  {get;set;}
        @AuraEnabled public String ProgramsApplied  {get;set;}
        @AuraEnabled public String CaseNumber  {get;set;}
        @AuraEnabled public String PermissionLevelMedicaid  {get;set;}
        @AuraEnabled public String PermissionLevelSNAP  {get;set;}
        @AuraEnabled public String PermissionLevelStateSupp  {get;set;}
        @AuraEnabled public String PermissionLevelKIHIPP  {get;set;}
        @AuraEnabled public String PermissionLevelCCAP {get;set;}
        @AuraEnabled public String PermissionLevelKTAP {get;set;}
    }
	
}