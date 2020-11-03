/**************************************************************************************************
* Class Name    : RE_ResourceWrapper 
* Owner         : Sai Velpula
* Created Date  : 06/11/2019
* Description   : Resource controller wrapper
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public class RE_ContactWrapper {
    
    @AuraEnabled  public String Id;
    @AuraEnabled  public String FirstName;
    @AuraEnabled  public String LastName;
    @AuraEnabled  public String Email;
    @AuraEnabled  public String Phone;
    @AuraEnabled  public Date BirthDate;
    @AuraEnabled  public String Individualid;
    @AuraEnabled  public String CaseNumber;
    @AuraEnabled  public String SSN;
    
    
    
    public RE_ContactWrapper(Consent__c objConsent){
        this.Id=objConsent.Client__r.Id;
        this.FirstName = objConsent.Client__r.FirstName;
        this.LastName = objConsent.Client__r.LastName;
        this.Email = objConsent.Client__r.Email;
        this.Phone = objConsent.Client__r.Phone;
        this.birthDate = objConsent.Client__r.BirthDate;
        
    }

}