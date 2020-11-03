/*
* classname 	: SSP_AccountCreationService
* @description 	: Rest service to create account as guest user
* @author 		: Nupoor Nimbalkar
* @date 		: 13/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar		13/11/2019		Initial Version
* Shikha Khanuja        4/11/2020       Updated Account Name with random number and its association to contact
*/

@RestResource(urlMapping='/CreateAccount/*')
global without sharing class SSP_AccountCreationService {
    public static final String CITIZEN_ACCOUNT_RECORD_TYPE = 'Citizen';
    public static final String CITIZEN_ROLE = 'Citizen';

    @HttpPost
    global static String doPost(String dataString, String signatureString, String accountsJSON, String contactsJSON, String sCurrentUserContactId) {          
        Blob data = Blob.valueof(dataString);
        Blob signature = EncodingUtil.base64Decode(signatureString);
        Boolean verified;
        String sJSONResponse;
        SSP_InterfaceConstants.ESCAPE_ACCOUNT_CREATION_FROM_TRIGGER = true;
        //List<Account> response = new List<Account>();
       // Map<String,Object> response = new Map<String,Object>();
        
        //check if signature and data input are valid
        if(data != null && signature != null){
           verified  = Crypto.verify('RSA', data, signature, AppConfig__c.getInstance('SSPCertificate').Value__c);
        }
        
        if(verified){ 
            try{                
                List<Account> lstAccounts = (List<Account>)JSON.deserialize(accountsJSON, List<Account>.class); 
                Map<String,String> accountNameIdMap = new Map<String,String>();
                //String CitizenRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CITIZEN_ACCOUNT_RECORD_TYPE).getRecordTypeId();
                for(Account acc : lstAccounts){
                    /*if(acc.RecordTypeId != null && acc.RecordTypeId == CitizenRecordTypeId) {
                        acc.Applicable_Roles__c = CITIZEN_ROLE;
                    }*/
                    acc.Name = acc.Name + '_'+Integer.valueof((Math.random() * 100000));                                         
                }
             
                insert lstAccounts;
                for(Account accValue : lstAccounts){
                    accountNameIdMap.put(accValue.Name, accValue.Id);
                }
                sJSONResponse = JSON.serialize(lstAccounts);
                
                List<Contact> lstConsToInsert;
                List<Contact> lstContacts;
                if(contactsJSON != null && String.isNotBlank(contactsJSON)){
                        lstConsToInsert = new List<Contact>();
                        lstContacts = (List<Contact>)JSON.deserialize(contactsJSON, List<Contact>.class);
                }

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
                                lstConsToInsert.add(objCon);
                                accountNameIdMap.remove(objAcc.Name);
                            }
                        }
                    }
                }
                
                if(lstConsToInsert != null && !lstConsToInsert.isEmpty()){
                    insert lstConsToInsert;
                    sJSONResponse += ' ;; ' + JSON.serialize(lstConsToInsert);
                }
                
                if(lstACRs != null && !lstACRs.isEmpty()){
                    insert lstACRs;
                }
                   
               	
               
            }
            catch(exception ex){                  
                //LOG_LogMessageUtility.logMessage(ex, 'SSP_AccountCreationService', 'doPost', ex.getMessage() , true);                
                
                
            }
        }
      
		return sJSONResponse;	         
    } 
    
    
}