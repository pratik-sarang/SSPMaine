/**************************************************************************************************
* Class Name    : RE_ResourceWrapper 
* Owner         : Sai Velpula
* Created Date  : 05/02/2019
* Description   : Resource controller wrapper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public class RE_ResourceWrapper {
    
    @AuraEnabled  public String Id;
    @AuraEnabled  public String AccountId;
    @AuraEnabled  public String Name;
    @AuraEnabled  public String ResourceName;
    @AuraEnabled  public String SDOHCategory;
    @AuraEnabled  public String Category;
    @AuraEnabled  public String AccountName;
    @AuraEnabled  public String TaxonomyId;
    @AuraEnabled  public String TaxonomyName;
    @AuraEnabled  public String GeographyServed;
    @AuraEnabled  public Boolean checkToDisableButton;
    @AuraEnabled  public List<Location__c> wrapLocations;
    @AuraEnabled  public List<LocationResource__c> resourceLocations;

    public class Location{
        @AuraEnabled  public String Id;
        @AuraEnabled  public String Name;
        
        public Location(String Id, String Name){
            this.Id = Id;
            This.Name = Name;
        }
        
    }
    
    public RE_ResourceWrapper(Resource__c objResource, List<Location__c> locList, List<LocationResource__c> resouceLocList, Boolean checkToDisableButton, Account objAccount, RE_Resource_Taxonomy__c resTaxonomy) {
        if(objResource != null){
        this.Id = objResource.Id;
        this.Name = objResource.Name;
        this.ResourceName = objResource.Name;
        this.SDOHCategory = objREsource.SdohDomain__c;
        if(resTaxonomy != null){
            this.TaxonomyId = resTaxonomy.Taxonomy__c;
            this.TaxonomyName = resTaxonomy.Taxonomy__r.Name;
        }
        }else if(objAccount != null){
            this.AccountId = objAccount.Id;
            this.AccountName = objAccount.Name;
        }        
        this.wrapLocations = locList;
        this.resourceLocations = resouceLocList;
        this.checkToDisableButton = checkToDisableButton;
        
    }
       
}