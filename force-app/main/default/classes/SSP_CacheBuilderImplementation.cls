/*
* classname     :  SSP_CacheBuilderImplementation
* @description  :  Class for adding selected role and imperosnated individual id to session cache
* @author       :  Anuja Ingole   
* @date         :  4/28/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_CacheBuilderImplementation implements Cache.CacheBuilder {
    public String doLoad(String key) {
        String value = '';
        User u;
        //Irondome IsAccessible Fix
        if(User.getSObjectType().getDescribe().isAccessible()){
         u = (User)[SELECT Id, ImpersonatedIndividualId__c, SelectedRole__c,profile.name,contact.IndividualId__c, contact.MemberType__c  FROM User WHERE id = :UserInfo.getUserId()];
        }
        
        Contact individualContact;
        if(key.equalsIgnoreCase(SSP_GlobalConstants.INDIVIDUAL_ID) && u != null){
           value = u.ImpersonatedIndividualId__c!= null ? u.ImpersonatedIndividualId__c:(U.contact.IndividualId__c !=null && (u.profile.name.equalsIgnoreCase(SSP_GlobalConstants.RE_CITIZEN_PROFILE) || u.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE))) ? U.contact.IndividualId__c : '';
        }else if(key.equalsIgnoreCase(SSP_GlobalConstants.SELECTED_ROLE) && u != null){
           value = u.SelectedRole__c!= null ? u.SelectedRole__c : SSP_GlobalConstants.CITIZEN_ROLE;
        }else if(key.equalsIgnoreCase('isHeadOfHousehold') && u != null){
           value = u.Contact.MemberType__c != null ? (u.Contact.MemberType__c == 'DEP' ? 'true' : 'false' ) : 'false';
        }else if(SSP_GlobalConstants.ALL_AVAILABLE_PROGRAMS != null && SSP_GlobalConstants.ALL_AVAILABLE_PROGRAMS.contains(key)){
           value = String.valueOf(FeatureManagement.checkPermission(key));
        }
        else if(key.equalsIgnoreCase('showKIHIPPSummary')){
         individualContact = SSP_DashboardService.getIndividualContact(null);
         value = String.valueOf(individualContact.CacheKIHIPPSummary__c);
        }
        return value;
    }
}