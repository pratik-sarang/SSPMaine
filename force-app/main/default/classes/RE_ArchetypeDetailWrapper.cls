/**************************************************************************************************
* Class Name    : RE_ArchetypeDetailWrapper 
* Owner         : Ashwin Kasture
* Created Date  : 07/04/2019
* Description   : Archetype Wrapper Details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public with sharing class RE_ArchetypeDetailWrapper
{
    @AuraEnabled public String strArchetypeId {get;set;}
    @AuraEnabled public String strArchetypeTitle {get; set;}
    @AuraEnabled public String strZipcode {get; set;}
    @AuraEnabled public String strUserLatLong {get;set;}
    @AuraEnabled public Integer resourceCount {get; set;}
    @AuraEnabled public List<CategoryBlockCls> lstCategoryBlock {get; set;}
    @AuraEnabled public Boolean bIsGuestUser {get;set;}
    @AuraEnabled public Boolean bIsResidentUser {get;set;}
    @AuraEnabled public Boolean bIsCPUserProfile {get;set;}
    @AuraEnabled public Boolean bIsAgencyUserProfile {get;set;} //RE_Release 1.1 - Agency User Capture- Mohan

    public class CategoryBlockCls
    {
        @AuraEnabled public String strDomain{get; set;}     
        @AuraEnabled public String strDomainCategory{get; set;} 
        @AuraEnabled public String strDomainImage{get;set;}
        @AuraEnabled public List<GoalBlockCls> lstGoalBlock{get; set;}
    }
    
    public class GoalBlockCls
    {   
        @AuraEnabled public String goalId{get; set;}
        @AuraEnabled public String goal{get; set;}
        @AuraEnabled public String goalDescription{get; set;}
        @AuraEnabled public String goalDomain{get;set;}
        @AuraEnabled public String strUserZipcodeLatLong {get;set;}
        @AuraEnabled public List<ResourceTileBlockCls> lstResourceTile{get; set;}
        @AuraEnabled public Integer resourceListSize{get; set;}
    }
    
    public class ResourceTileBlockCls implements Comparable
    {
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public String accountProviderName{get; set;}
        @AuraEnabled public String accountStatus{get;set;}
        @AuraEnabled public Boolean accountIsClaimed{get;set;}        
        
        @AuraEnabled public String resourceId{get;set;}
        @AuraEnabled public String resourceName{get; set;}
        @AuraEnabled public Decimal resourceMiles{get; set;}
        @AuraEnabled public String resourceDescription{get; set;}
        @AuraEnabled public String resoucrePOCPhone {get; set;}
        @AuraEnabled public String resourcePOCEmail{get; set;}
        @AuraEnabled public String resourceSdohCategory{get; set;}
        
        @AuraEnabled public String locationId{get;set;}
        @AuraEnabled public String locationName{get;set;}
        @AuraEnabled public String locationPhone{get; set;}
        @AuraEnabled public String locationEmail{get; set;}
        @AuraEnabled public String locationAddress1{get; set;}
        @AuraEnabled public String locationAddress2{get; set;}
        @AuraEnabled public String locationAddressFinal{get;set;}
        @AuraEnabled public String locationCity{get; set;}
        @AuraEnabled public String locationState{get; set;}
        @AuraEnabled public String locationZipcode{get; set;}
        @AuraEnabled public String locationZipcodeExt{get; set;}
        @AuraEnabled public String locationHours{get; set;}
        @AuraEnabled public String locationWebsite{get; set;}
        @AuraEnabled public String accountWebsite{get; set;}
        @AuraEnabled public String locationLatLong {get;set;}
        @AuraEnabled public String locationOperatingHours {get;set;}
        @AuraEnabled public String locationIsClosedDay{get;set;}
        @AuraEnabled public String referralId{get;set;}
        @AuraEnabled public String locationResourceId{get;set;}
        @AuraEnabled public String favoriteId{get;set;}
        @AuraEnabled public Referral__c objReferral;
        @AuraEnabled public Boolean isConnectButtonDisabled;
        @AuraEnabled public String setBulkReferalStatus{get;set;}
        @AuraEnabled public Boolean bisCheckboxCheck = false; 
        @AuraEnabled public String locResTimeNotes;
        
        @AuraEnabled public String sArchetypeid{get;set;}
        @AuraEnabled public Boolean isDisabled = false; 
        
        public Integer compareTo(Object compareTo) {
            ResourceTileBlockCls compareToEmp = (ResourceTileBlockCls)compareTo;
            if (resourceMiles == compareToEmp.resourceMiles){
                return 0;
            }
            if (resourceMiles == null || resourceMiles > compareToEmp.resourceMiles){
                return 1;
            }            
            return -1;
        }
    }
    public class ResTaxoMilesCls implements Comparable
    {
        @AuraEnabled public RE_Resource_Taxonomy__c objResourceTaxonomy {get;set;}
        @AuraEnabled public LocationResource__c objLocationResource {get;set;}
        
        @AuraEnabled public Decimal resourceMiles {get; set;}
        public Integer compareTo(Object compareTo) {
            ResTaxoMilesCls compareToEmp = (ResTaxoMilesCls)compareTo;
            if (resourceMiles == compareToEmp.resourceMiles){
                return 0;
            }
            if (resourceMiles == null || resourceMiles > compareToEmp.resourceMiles){
                return 1;
            }            
            return -1;
        }
    }
}