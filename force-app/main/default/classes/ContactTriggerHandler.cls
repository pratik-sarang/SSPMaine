/**
* Class Name    : ContactTriggerHandler
* Owner         : DELOITTE
* Created Date  : 06/10/2019
* Description   : Helper class for ContactTrigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/10/2019  Srikanth       Initial Version
*  01/07/2020  Pankaj         Added duplicate check as part of defect#341025
********************************************************************
* 	
**/
public with sharing class ContactTriggerHandler extends TriggerHandler {
    public ContactTriggerHandler() {
        this.setMaxLoopCount(5);//recursive handling
    } 
    
    
    public void createCitizenAccount(){
        if(SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER) {
            return;
        }
        List<Contact> needAccounts = new List<Contact>();
        try{
            
            //RecordType contactRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
            Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');

            for(Contact objectContact: (List<Contact>)trigger.new){
                if(objectContact.FirstName == null || objectContact.FirstName == '' ){
                    objectContact.addError(SSP_GlobalConstants.FIRST_NAME_IS_MANDATORY);
                }
                if (objectContact.RecordTypeId == contactRecordTypeId || SSP_InterfaceConstants.ALLOW_ACCOUNT_CREATION_FROM_TRIGGER) {
                    needAccounts.add(objectContact);
                }
            }
            if (needAccounts.size() > 0) {
                List<User> userList = RE_SharingByPassCtrl.getUserList(RE_GlobalConstants.strSystemAutoProcessProfile);
                List<Account> newAccounts = new List<Account>();
                Map<String,Contact> contactsByNameKeys = new Map<String,Contact>();
                //RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Account');
                Id accountRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Citizen');

                for (Contact c : needAccounts) {
                    String accountName = c.firstname + ' ' + c.lastname;
                    contactsByNameKeys.put(accountName,c);
                    // RE Security Changes -- Payal Dubela
                    Account a = new Account(name=accountName,RecordTypeId=accountRecordTypeId,HasOptedOutOfAccount__c=false,Applicable_Roles__c=RE_GlobalConstants.strCitizenAppRole);
                    if(userList!=null && !userList.isEmpty() && a.ownerId==null){
                        a.ownerId=userList[0].Id;
                    }
                    newAccounts.add(a);
                }
                if(!newAccounts.isEmpty()){
                    //insert newAccounts;
                    RE_DataAccessChecker.insertObjects(Account.sObjectType, newAccounts);
                }
                for (Account a : newAccounts) {
                    if (contactsByNameKeys.containsKey(a.Name)) {
                        contactsByNameKeys.get(a.Name).accountId = a.Id;
                        if(userList!=null && !userList.isEmpty()){
                         contactsByNameKeys.get(a.Name).ownerId=userList[0].Id;
                    }
                }
            }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, SSP_GlobalConstants.CONTACT_TRIGGER_HANDLER, SSP_GlobalConstants.CREATE_CITIZEN_ACCOUNT, e.getMessage(), true);
        }  
    }
    /*public void communityPartnerCallOut(){
        Set<ID> contactIDs = new Set<ID>();
        if (Schema.sObjectType.Contact.fields.Phone.isAccessible() && Schema.sObjectType.Contact.fields.PermissionsLevel__c.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()
            && Schema.sObjectType.Contact.fields.ID.isAccessible()){
               // RE Security Changes -- Payal Dubela ---Start
                for(Contact objContact : RE_SharingByPassCtrl.getContacts(Trigger.New)){
                    if(objContact.Account.Applicable_Roles__c!=null && (objContact.Account.Applicable_Roles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN)||
                      objContact.Account.Applicable_Roles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_STAFF))){
                        contactIDs.add(objContact.ID);
                    }
                }
                // RE Security Changes -- Payal Dubela ---END
                if(contactIDs.size() > 0){
                    Database.executeBatch(new CPUserCreationBatch(contactIDs), 200);
                }
                
            }
    }*/
    
    /*public void checkDuplicateEntry(){
        List<Contact> lstContacts=(List<Contact>)trigger.new;
        List<String> lstEmails = new List<String>();
        // RE Security Changes -- Payal Dubela ---Start
        ID nonCitizenRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RE_GlobalConstants.strNonCitizenContactDevName).getRecordTypeId();
        for(Contact sContact:RE_SharingByPassCtrl.getContacts(Trigger.New)){
            // consider only for cp user
           if(sContact.recordTypeId == nonCitizenRectypeId && 
                sContact.Account.Applicable_Roles__c!=null && 
                (sContact.Account.Applicable_Roles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN)||
                sContact.Account.Applicable_Roles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_STAFF))){
            lstEmails.add(sContact.email);
        }
        }
        // RE Security Changes -- Payal Dubela ---END
        if(!lstEmails.isEmpty()){
            Map<String, Integer> mapContactEmailDuplicate = GeneralUtility.checkDuplicateUser(lstEmails);
            for(Contact objCon:lstContacts){
                if(mapContactEmailDuplicate!=null && mapContactEmailDuplicate.get(objCon.Email) > 1){
                    objCon.addError(System.Label.contactmatchfounderror);
                }
            }
        }
    }*/
}