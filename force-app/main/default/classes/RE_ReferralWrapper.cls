/**************************************************************************************************
* Class Name    : RE_ReferralWrapper 
* Owner         : Prashant
* Created Date  : 05/08/2019
* Description   : User wrapper to wrap Referral object values
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/

public with sharing class RE_ReferralWrapper {
    @AuraEnabled  public String Id {get; set;}
	@AuraEnabled  public String Name {get; set;}
    @AuraEnabled  public Decimal Rating {get; set;}
    @AuraEnabled  public String OutcomeReason {get; set;}
    @AuraEnabled  public String Outcome {get; set;}
    @AuraEnabled  public String AdditionalComments {get; set;}
    @AuraEnabled  public Decimal DaysSinceOpened {get; set;}
    @AuraEnabled  public String Contacts {get; set;}
    @AuraEnabled  public String ContactId {get; set;}
    @AuraEnabled  public String CreatedBy {get; set;}
    @AuraEnabled  public Datetime DateOfReferral {get; set;}
    @AuraEnabled  public String OwnerId {get; set;}
    @AuraEnabled  public String ReferredAccountID {get; set;}
    @AuraEnabled  public String ReferredOrgID {get; set;}
    @AuraEnabled  public String ReferringUserEmail {get; set;}
    @AuraEnabled  public String ReferringUserPhone {get; set;}
    @AuraEnabled  public String Status {get; set;} 
    @AuraEnabled  public String ResourceName {get; set;}
    @AuraEnabled  public Boolean OptOutInfoSharing {get; set;}
    @AuraEnabled  public List<Object> lstUsers {get; set;}
    @AuraEnabled  public String sContactAccId {get; set;}
    @AuraEnabled  public String sContactEmail {get; set;}
    @AuraEnabled  public String sContactPreferredCommMethod {get; set;}
    @AuraEnabled  public String sQueueName {get; set;}
    @AuraEnabled  public String sQueueId {get; set;}
    @AuraEnabled  public String ContactFirstName {get; set;}
    @AuraEnabled  public boolean isChangedStatus {get; set;}
    @AuraEnabled  public String sClosedByUser {get; set;}
   
}