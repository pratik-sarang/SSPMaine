/*
* classname 	: SSP_AccountContactService
* @description 	: Service to create account, contact and ACR
* @author 		: Abdulrehman Ansari
* @date 		: 29/7/2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Abdulrehman Ansari	29/7/2020		Initial Version
*/

public without sharing class SSP_AccountContactService {

    public static map<String,Object> createAccountContact( List<Account> lstAccounts, List<Contact> lstContacts, String sCurrentUserContactId) {          
        Map<String,Object> objectMap = new Map<String, Object>();
        SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = true;
        try{                
            Map<String,String> accountNameIdMap = new Map<String,String>(); 
            
            //get site default owner
            //Id siteId = Site.getSiteId();
            Site benefindSite = [SELECT Id,  GuestRecordDefaultOwnerId FROM Site WHERE UrlPathPrefix = :AppConfig__c.getInstance('BenefindPrefix').value__c];
            Id defaultOwnerId;
            if(benefindSite != null){
                defaultOwnerId = benefindSite.GuestRecordDefaultOwnerId;
            }
            
            //populate the account fields
            for(Account acc : lstAccounts){
                acc.Name = acc.Name + '_'+Integer.valueof((Math.random() * 100000));
                if(defaultOwnerId != null){
                   acc.ownerId = defaultOwnerId; 
                }
                else{
                    acc.ownerId = userInfo.getUserId();
                }
                //acc.ownerId = '005r0000003T8xE'; //Todo: update Owner
            }
            
            //insert accounts
            if(lstAccounts != null && !lstAccounts.isEmpty()){
           		insert lstAccounts;
            }
            
            
            for(Account accValue : lstAccounts){
                accountNameIdMap.put(accValue.Name, accValue.Id);
            }
            //sJSONResponse = JSON.serialize(lstAccounts);
            
            List<Contact> lstConsToInsert = new List<Contact>();

            List<AccountContactRelation> lstACRs = new List<AccountContactRelation>();
            for(Account objAcc : lstAccounts){
                
                if(sCurrentUserContactId != null){
                    AccountContactRelation acr = new AccountContactRelation(); 
                    acr.Accountid = objAcc.Id;
                    acr.Contactid = sCurrentUserContactId;
                    lstACRs.add(acr);
                }
                
                if(lstContacts != null && !lstContacts.isEmpty()){
                    
                    for(Contact objCon : lstContacts){  
                        if(!String.isNotBlank(objCon.AccountId) && (objCon.FirstName +' '+objCon.Lastname)  == objAcc.Name.split('_')[0] 
                           && accountNameIdMap.containsKey(objAcc.Name)){
                               //if((objCon.FirstName +' '+objCon.Lastname + '_'+objCon.Birthdate.toString()+System.today().toString())  == objAcc.Name){
                               objCon.AccountId = accountNameIdMap.get(objAcc.Name);//objAcc.id;
                               if(defaultOwnerId != null){
                                    objCon.ownerId = defaultOwnerId;
                               }
                               lstConsToInsert.add(objCon);
                               accountNameIdMap.remove(objAcc.Name);
                           }
                    }
                }
            }
            
            if(lstConsToInsert != null && !lstConsToInsert.isEmpty()){
                insert lstConsToInsert;
                //sJSONResponse += ' ;; ' + JSON.serialize(lstConsToInsert);
            }
            
            if(lstACRs != null && !lstACRs.isEmpty()){
                insert lstACRs;
            }
            
            //return the map of objects
            
            objectMap.put('lstAccounts',lstAccounts);
            objectMap.put('lstContacts',lstContacts);
            
            
            
        }
        catch(exception ex){      
            system.debug(ex);
            throw new CustomException(CustomException.EXCEPTION_TYP.DML, ex.getMessage()); 

        }
      	return objectMap;         
    } 
    
    
}