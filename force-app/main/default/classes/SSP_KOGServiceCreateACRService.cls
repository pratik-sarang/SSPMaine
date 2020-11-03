global class SSP_KOGServiceCreateACRService {
	
	global class SSP_KOGServiceCreateACRRequest {
		webservice List<Account> accounts;
		webservice List<Contact> contacts;
		webservice List<AccountContactRelation> accountContactRelations;
	}

	global class SSP_KOGServiceCreateACRResponse {
		webservice Boolean success;
		webservice String errorMessage;
	}
    webservice static SSP_KOGServiceCreateACRResponse deleteACRFromContactIds(List<string> contactIds) {
        SSP_KOGServiceCreateACRResponse response = new SSP_KOGServiceCreateACRResponse();
        System.debug('Test Ids'+contactIds);
        if(contactIds != null && !contactIds.isEmpty()) {
            List<AccountContactRelation> acrsToDelete = [Select id from AccountContactRelation where Contact.AgentId__c IN: contactIds AND DCContactId__c != null];
            if(!acrsToDelete.IsEmpty() && acrsToDelete.size() >= contactIds.size()) {
                delete acrsToDelete;
                response.success = true;
            } else {
                response.success = false;
                response.errorMessage = 'No ACR found for the Contact Ids';
            }           
            
        } else {
            response.success = false;
            response.errorMessage = 'No Contact Id received';
        }

        return response;
    }

	webservice static SSP_KOGServiceCreateACRResponse createACRRecord(SSP_KOGServiceCreateACRRequest request) {
		SSP_KOGServiceCreateACRResponse response = new SSP_KOGServiceCreateACRResponse();
        System.debug('request : '+JSON.serializePretty(request));
        try {
            if(request == null) {
                response.success = false;
                response.errorMessage = 'Received an Invalid Resquest';
            }
            List<Contact> newContacts = request.contacts;
            List<AccountContactRelation> newACRs = request.accountContactRelations;
            List<Account> newAccounts = request.accounts;
            
            if(newAccounts != null && !newAccounts.isEmpty()) {
                upsert newAccounts OrganizationUniqueId__c;
            }
            SSP_InterfaceConstants.ALLOW_ACCOUNT_CREATION_FROM_TRIGGER=true;
            if(newContacts != null && !newContacts.isEmpty()){
                list<contact> contactKOGRec= new list<contact>();
                list<contact> contactAgentRec= new list<contact>();
                for(contact c:newContacts){
                    if(c.KOGSourceId__c!=null){
                        contactKOGRec.add(c);
                    }else{
                        contactAgentRec.add(c);
                    }
                }
                if(contactKOGRec.size()>0){
                	upsert contactKOGRec KOGSourceId__c;
                }
                if(contactAgentRec.size()>0){
                	upsert contactAgentRec Agentid__c;
                }
            }
            system.debug('53>>>>>>>>>>>>>>>');
            List<AccountContactRelation> acrsToUpsert = new List<AccountContactRelation>();
            List<AccountContactRelation> acrsToDelete = new List<AccountContactRelation>();
            if(newACRs != null && !newACRs.isEmpty()) {
                system.debug('57>>>>>>>>>>>>>>>');
                for(Integer i = 0; i < newACRs.size(); i++) {
                    AccountContactRelation acr = newACRs[i];
                    system.debug('60>>>>>>>>>>>>>>>'+acr.IsDeleted__c);
                    if(acr.IsDeleted__c) {
                        acrsToDelete.add(acr);
                    } else {
                        acrsToUpsert.add(acr);
                    }
                }
            }
            if(acrsToUpsert!= null && !acrsToUpsert.IsEmpty()){
                upsert acrsToUpsert DCACRId__c;
            }            
            if(acrsToDelete!= null && !acrsToDelete.IsEmpty()){
                set<string> uniqueACRID= new set<string>();
                for(AccountContactRelation ACR:acrsToDelete){
                    uniqueACRID.add(ACR.DCACRId__c);
                }
                delete [select id from AccountContactRelation where DCACRId__c IN:uniqueACRID];
            }
            
            response.success = true;
        } catch (Exception ex) {
            response.success = false;
            response.errorMessage = ex.getMessage();
            System.debug('Error : '+ex.getMessage());
            System.debug('Error at : '+ex.getStackTraceString());
        }
		
        
        return response;
	}

    public class SSP_KOGServiceCreateACRServiceException extends Exception {

    }
}