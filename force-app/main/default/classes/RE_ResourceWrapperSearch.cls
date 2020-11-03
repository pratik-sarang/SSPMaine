/**************************************************************************************************
* Class Name    : RE_ResourceWrapperSearch 
* Owner         : Payal Dubela
* Created Date  : 10/04/2019
* Description   : Resource controller wrapper for Basic search
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*   Created to reduce parameter in wrapper for search functionality
**/
public class RE_ResourceWrapperSearch {
    
   @AuraEnabled  public String accountId;
    @AuraEnabled  public String accountName;
    @AuraEnabled  public Boolean accountIsClaimed;
    @AuraEnabled  public String accountStatus;
    @AuraEnabled  public Account account;
    @AuraEnabled  public String resourceId;
    @AuraEnabled  public String resourceName;
    @AuraEnabled  public String resourceDescription;
    //@AuraEnabled  public String eligibility;
    @AuraEnabled  public String whatToBring;
    @AuraEnabled  public String Fees;
    @AuraEnabled  public String url;
    @AuraEnabled  public String userLatLong;
    @AuraEnabled  public Boolean bHasReferral;
    @AuraEnabled  public String referralId;
    @AuraEnabled  public String specialInstructions;    
    @AuraEnabled public Decimal resourceMiles;
    @AuraEnabled public String resoucrePOCPhone {get; set;}
    @AuraEnabled public String resourcePOCEmail{get; set;} 
    @AuraEnabled public Boolean bIsFav;
    @AuraEnabled public List<Domain> lstDomains;
    @AuraEnabled  public List<Location> lstResourceLocations;
    @AuraEnabled public Resource__c objResource; 
    @AuraEnabled public Boolean isDisabled = false; 
    
    public class Account{
        @AuraEnabled  public String accId;
        @AuraEnabled  public String accName;
        @AuraEnabled  public String accAddress1;
        @AuraEnabled  public String accAddress2;
        @AuraEnabled  public String accCity;
        @AuraEnabled  public String accState;
        @AuraEnabled  public String accZip;
    }
    public class Domain{
        @AuraEnabled  public String domainName;
        @AuraEnabled  public String domainValue;
        @AuraEnabled  public String domainImage;
    }
    
    public class Location{
        @AuraEnabled public String id;
        @AuraEnabled public String locResourceId;
        @AuraEnabled public String name;
        @AuraEnabled public String pointOfContactPhone;
        @AuraEnabled public String pointOfContactEmail;
        @AuraEnabled public String locationAddress1;
        @AuraEnabled public String locationAddress2;
        @AuraEnabled public String locationCity;
        @AuraEnabled public String locationState;
        @AuraEnabled public String locationCounty;
        @AuraEnabled public String locationZip;
		@AuraEnabled public String locationZipExt;
        @AuraEnabled public String specialInstructions; 
        @AuraEnabled public String locationLatLong {get;set;}
        @AuraEnabled public String locationOperatingHours;
        @AuraEnabled public String locationIsClosedDay{get;set;}
        @AuraEnabled public List<String> lstClosedDays{get;set;}   
        @AuraEnabled public String Notes;   //Nandita: Added parameter to implement hours of operation process flow  
    }     

}