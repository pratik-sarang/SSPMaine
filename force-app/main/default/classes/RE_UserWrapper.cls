/**************************************************************************************************
* Class Name    : RE_UserWrapper 
* Owner         : Pankaj
* Created Date  : 05/08/2019
* Description   : User wrapper to wrap User object values
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public class RE_UserWrapper {
    @AuraEnabled  public String Id {get; set;}
    @AuraEnabled  public String FirstName {get; set;}
    @AuraEnabled  public String LastName {get; set;}
    @AuraEnabled  public String PrimaryLocation {get; set;}
    @AuraEnabled  public String Status {get; set;}
    @AuraEnabled  public String TrainingLevel {get; set;}
    @AuraEnabled  public String PermissionsLevel {get; set;}
    @AuraEnabled  public String Phone {get; set;}
    @AuraEnabled  public String Email {get; set;}
    @AuraEnabled  public Boolean bIsAdmin {get; set;}
    @AuraEnabled  public Boolean bIsClaim =false;
    @AuraEnabled  public String AccountId {get; set;}
    @AuraEnabled  public List<Object> lstLocations {get; set;}
    @AuraEnabled  public Object userdata {get; set;}
    @AuraEnabled  public Boolean isClaimFlow =false;
    @AuraEnabled  public String PrimaryLocationName {get; set;}
    @AuraEnabled  public Boolean isUserActive =true;
    @AuraEnabled  public Boolean isStatusChanged {get; set;}//Created this so that in case of status inactive data update validate role service is not called multiple times
    @AuraEnabled  public Boolean isLoggedInUser =false;

    public RE_UserWrapper(Contact obj){
        this.Id=obj.Id;
        this.FirstName=obj.FirstName;
        this.LastName=obj.LastName;
        this.PrimaryLocation=obj.PrimaryLocation__c;
        this.Status=obj.Status__c;
        this.TrainingLevel=obj.TrainingLevel__c;
        this.PermissionsLevel=obj.PermissionsLevel__c;
        this.Phone=obj.Phone;
        this.PrimaryLocationName=obj.PrimaryLocation__r.Name;
    }
    public RE_UserWrapper(){

    }
}