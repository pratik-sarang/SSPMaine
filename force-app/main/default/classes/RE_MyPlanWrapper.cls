/**************************************************************************************************
* Class Name    : RE_MyPlanWrapper 
* Owner         : Deloitte Consulting
* Created Date  : 07/04/2019
* Description   : MyPlan Wrapper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*	9/06/2019	Pankaj			MyPlan wrapper
**/
public class RE_MyPlanWrapper {
    @AuraEnabled public Boolean bIsFav{get; set;}
    @AuraEnabled public Double dMiles {get; set;}
    @AuraEnabled public String sNotesRecords {get; set;}
    @AuraEnabled public String sLocResourceId{get; set;}
    @AuraEnabled public String sOperatingHoursData {get;set;}
    @AuraEnabled public Contact con{get;set;}
    @AuraEnabled public Account acc{get;set;}   
    @AuraEnabled public Referral referral{get;set;}
    @AuraEnabled public Resource resource{get;set;}
    @AuraEnabled public Location location{get;set;} 
    @AuraEnabled public List<RE_NotesCtrl.NotesWrapper> lstNotes{get; set;}
    @AuraEnabled public RE_NotesCtrl.NotesWrapper firstContentNote{get; set;}
    @AuraEnabled public String sOperatingHoursToday {get; set;}
    @AuraEnabled public String sLocationResourceNotes {get; set;}  //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
    public class Contact{
        @AuraEnabled public String sContactZipCode {get;set;}
        @AuraEnabled public String sResidentId{get;set;}
    }
    public class Referral{
        @AuraEnabled public ID referralId {get; set;}
        @AuraEnabled public Boolean bIsRated {get; set;}
        @AuraEnabled public String sReferralStatus {get; set;}
        @AuraEnabled public String sReferralOrgId {get; set;}
        @AuraEnabled public String sReferralLatLong {get; set;}
        @AuraEnabled public String sReferralCreatedByName {get; set;}
        @AuraEnabled public String sReferralCreatedByAccountName {get; set;}
        @AuraEnabled public DateTime dCreatedDate{get; set;}
        @AuraEnabled public String sDayOpened {get; set;}
    }
    public class Resource{
        @AuraEnabled public ID resourceId {get; set;}
        @AuraEnabled public String intFees {get; set;}
        @AuraEnabled public String resourceOrgName {get; set;}
        @AuraEnabled public String sResourceName {get; set;}
        @AuraEnabled public String sResourceDescription {get; set;}
        @AuraEnabled public String sResourceElegibility {get; set;}
        @AuraEnabled public String sNextStep {get; set;}
        @AuraEnabled public String sSDOHCategory {get; set;}
        @AuraEnabled public String sWhatToBring {get; set;}
        @AuraEnabled public boolean isDisabled = false;
    }
    public class Location{
        @AuraEnabled public String sPOCPhone {get; set;}
        @AuraEnabled public String sWebsite {get; set;}
        @AuraEnabled public String sPOCEmail {get; set;}
        @AuraEnabled public String sLocationId{get; set;}
        @AuraEnabled public String sLocationAddress1{get; set;}
        @AuraEnabled public String sLocationAddress2 {get; set;}
        @AuraEnabled public String sLocationCity {get; set;}
        @AuraEnabled public String sLocationState {get; set;}
        @AuraEnabled public String sLocationCountry {get; set;}
        @AuraEnabled public String sLocationZip {get; set;}
        @AuraEnabled public String sLocationZipExt {get; set;}
        @AuraEnabled public String sLocationWebsite {get; set;}
        @AuraEnabled public String sLocation {get; set;}
        @AuraEnabled public String sSpcialLocationInstructions {get; set;}
        @AuraEnabled public String sOperatingHoursToday {get; set;}
        // added by Pankaj [02/12/2019]
        @AuraEnabled public String locationIsClosedDay{get;set;}
        @AuraEnabled public List<String> lstClosedDays{get;set;} 
    }
    public class Account{
        @AuraEnabled public Boolean bOrgIsClaimed {get; set;}
        @AuraEnabled public String sReferralOrgUrl {get; set;}
        @AuraEnabled public String sReferralOrgName {get; set;}
        @AuraEnabled public String sReferralOrgAddress1 {get; set;}
        @AuraEnabled public String sReferralOrgAddress2 {get; set;}
        @AuraEnabled public String sReferralOrgCity {get; set;}
        @AuraEnabled public String sReferralOrgState {get; set;}
        @AuraEnabled public String sReferralOrgZip {get; set;}
        @AuraEnabled public String sReferralOrgZipExt {get; set;}
        @AuraEnabled public String sReferralDescription {get; set;}
    }    
    public class EmailWrapper{      
        @AuraEnabled public String sResourceName {get; set;}  
        @AuraEnabled public ID resourceId {get; set;}
        @AuraEnabled public String sReferralOrgUrl {get; set;}
        @AuraEnabled public String sReferralOrgName {get; set;}
        @AuraEnabled public String sLocationAddress1{get; set;}
        @AuraEnabled public String sLocationAddress2 {get; set;}
        @AuraEnabled public String sLocationCity {get; set;}
        @AuraEnabled public String sLocationState {get; set;}
        @AuraEnabled public String sLocationCountry {get; set;}
        @AuraEnabled public String sLocationZip {get; set;}
        @AuraEnabled public String sLocationZipExt {get; set;}
        @AuraEnabled public String sReferralDescription {get; set;}
        @AuraEnabled public String sPOCEmail {get; set;}
        @AuraEnabled public String sPOCPhone {get; set;}
        @AuraEnabled public Double dMiles {get; set;}
        @AuraEnabled public String sOperatingHoursToday {get; set;}
        @AuraEnabled public String sOperatingHoursData {get;set;}
    }
}