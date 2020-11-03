/*
* classname     :  SSP_AddAuthRepController
* @description  :  Controller class for Add Auth Rep FLow (Class is refering to day 0 data, where we need to access and operate on day0 data which the member doesnt have access, hence is without sharing)
* @author       :  Shrikant Raut   
* @date         :  01/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public without sharing class SSP_AddAuthRepController {
    /*
* @author       Shrikant Raut 
* @date         01/20/2019 
* @methodname   fetchContactInformation
* @description  This methods is used to fetch  contact information
* @return       SSP_LightningResponse
**/
    @auraEnabled(cacheable=true) 
    public static SSP_LightningResponse fetchContactInformation(Id sspContactId, Id sspApplicationId, String callingComponent ){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> fieldSet = new Set<String>{'Id','IsManualAuthRep__c','DoesAuthRepHasOrg__c','FirstName','MiddleName','LastName','SuffixCode__c','Email','SSN__c','GenderCode__c','BirthDate','Phone','PrimaryPhoneExtension__c','PreferredLanguageCode__c','OrganizationName__c','OrgranizationIdentificationNumber__c'};
            List<Contact> contactList = new List<Contact>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();      
        List<AccountContactRelation> acrOrgList = new List<AccountContactRelation>();      
        SSP_Application__c sspApp;
        try{
            if(sspApplicationId != null ){
                SSP_LightningResponse objResponse = new SSP_LightningResponse();           
                objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(sspApplicationId);
                if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
                    response.put('hasNoAccess',true);
                    response.bIsSuccess = true;
                    return response;    
                }
            }
            if(sspApplicationId != null){
                sspApp = SSP_ApplicationSelector.queryApplicationDataById(sspApplicationId, new List<String>{'Account__c'});
                response.put('applicationAccount',sspApp.Account__c);   
            }
            if(sspContactId != null && sspApp != null){                
                
                Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1','Id'=> sspContactId};                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       fieldSet, 
                                                                       conditionMap);                    
                acrList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                          new Set<String>{'Id','contactId','RepresentativeRelationshipCode__c','toLabel(CountyCode__c)','Zipcode5__c','Zipcode4__c','AddressLine2__c','Street__c','City__c','toLabel(SSP_State__c)'}, 
                                                                          new Map<String, String>{'limit'=>'1','ContactId'=> sspContactId, 'AccountId' => sspApp.Account__c});  
                
                acrOrgList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                             new Set<String>{'Id','account.Name','account.DCdataId__c'}, 
                                                                             new Map<String, String>{'limit'=>'1000','contactId'=> sspContactId,'account.recordtype.developerName '=>'Resource_Engine'});
                
                if((!acrOrgList.isEmpty()) && acrOrgList[0].account != null && acrOrgList[0].account.DCdataId__c != null){
                    response.put('organizationName', acrOrgList[0].account.Name );
                    response.put('organizationId', acrOrgList[0].account.DCdataId__c);    
                }
                                                 
                response.put('contactRecord',(contactList != null && !contactList.isEmpty()) ? contactList[0] : null);
                response.put('accountContactRelationRecord',(acrList != null && !acrList.isEmpty()) ? acrList[0] : null);                                             
            }    
            response.put('relationshipCodes',SSP_Utility.getPickListValues('AccountContactRelation','RepresentativeRelationshipCode__c',null));                  
            response.bIsSuccess = true;
        }catch(Exception ex){                                
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AddAuthRepController', 'fetchContactInformation', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id);            
        }
        
        
        return response;
    }
    
    /*
* @author       Shrikant Raut
* @date         01/20/2019
* @methodname   upsertContactInformation and create ACR if required
* @description  This methods is used to insert/update contact record for AuthReps.
* @return       SSP_LightningResponse
**/
    @auraEnabled
    public static SSP_LightningResponse upsertContactInformation(String contactJSON, String relationJSON, String detailJSON ){                    
        SSP_LightningResponse response = new SSP_LightningResponse();
        Map<String, String> resultMap = new Map<String, String>();
        try{
            if(contactJSON != null && detailJSON != null){
                List<Contact> contactList = (List<Contact>)JSON.deserialize(contactJSON, List<Contact>.class);
                List<AccountContactRelation> acrList;
                if(relationJSON != null){
                    acrList = (List<AccountContactRelation>)JSON.deserialize(relationJSON, List<AccountContactRelation>.class);
                }
                
                Map<String, String> detailMap =  (Map<String, String>)JSON.deserialize(detailJSON, Map<String, String>.class);
                Id sspApplicationId = (detailMap != null && detailMap.containsKey('sspApplicationId')) ? detailMap.get('sspApplicationId') : null;
                Id sspApplicationAccount = (detailMap != null && detailMap.containsKey('sspApplicationAccount')) ? detailMap.get('sspApplicationAccount') : null;
                Boolean isSelectedViaSearch = (detailMap != null && detailMap.containsKey('isSelectedViaSearch')) ? (detailMap.get('isSelectedViaSearch').equalsIgnoreCase('true') ? true : false ) : false;
                Boolean isAddFlow =  (detailMap != null && detailMap.containsKey('flowName')) ? (detailMap.get('flowName').equalsIgnoreCase('addAuthRep') ? true : false ) : false;
                Boolean updateResult = true;
                if(sspApplicationAccount != null ){    
                    List<AccountContactRelation> lstCurrentUserACR =  new List<AccountContactRelation>();                   
                    if(sspApplicationAccount != null){
                        lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                            new Set<String>{'Id'}, 
                            new Map<String, String>{'ContactId'=> SSP_Utility.getCurrentUserDetails()[0].ContactId, 'AccountId'=>sspApplicationAccount});
                    }
                    if(lstCurrentUserACR.isEmpty()){
                        response.put('hasNoAccess',true);
                        response.bIsSuccess = true;
                        return response;    
                    }
                }
                
                //Update contact only if the authrep is not selected using search and an existing authrep is been edited (For Edit Flow)
                if(contactList != null && !contactList.isEmpty() && contactList[0] != null && contactList[0].Id != null && !isSelectedViaSearch && !isAddFlow){ 
                    ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
                   // validateAddress(contactList[0]);   
                    updateResult = ESAPI.accessController().updateAsUser(new Map<ID,Contact>(contactList), SSP_Utility.getFieldsNamesList (contactList)).wasSuccessful();    
                    response.bIsSuccess = true;
                    
                }
                
                //Upsert acr based on the action performed(authrep edited - update acr)               
                if(contactList != null && !contactList.isEmpty() && contactList[0].Id != null && updateResult && !isAddFlow && acrList != null){
                    acrList = upsertACR(acrList, sspApplicationAccount, null);
                    Boolean result = (acrList != null && !acrList.isEmpty());
                    response.bIsSuccess = result;
                    response.put(result ? 'SUCCESS' : 'ERROR', result ? acrList[0].id : 'ACR creation failed' );
                    response.put(result ? 'ACR' : 'ERROR', result ? acrList[0].id : 'ACR creation failed' );
                    response.put('contactId', contactList[0].Id);
                }
                
                //For manual data entry of a new authrep, insert contact and corresponding acr record                
                else if(contactList != null && !contactList.isEmpty() &&  contactList[0] != null && contactList[0].Id == null && acrList == null && isAddFlow){
                    resultMap = createNewAuthRep(contactList);                    
                    response.bIsSuccess = !(resultMap != null && resultMap.containsKey('ERROR'));
                }
                
                //else copy contact Id into response map
                else if(contactList != null && !contactList.isEmpty() && contactList[0].Id != null){
                    response.put('contactId', contactList[0].Id);
                }
                
                if(resultMap != null && !resultMap.isEmpty()){
                    for(String key : resultMap.keySet()){
                        response.put(key, resultMap.get(key));
                    }
                }
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AddAuthRepController', 'upsertContactInformation', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
    
    /*
    * @author       Shrikant Raut
    * @date         01/22/2019
    * @methodname   createNewAuthRep
    * @description  Method to contact for Authorized representative
    * @return       SSP_LightningResponse
    **/
    private static Map<String, String> createNewAuthRep(List<Contact> contactList){
        Map<String, String> resultMap = new Map<String, String>();                 
        contactList[0].recordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Non_Citizen');
        contactList[0].IsManualAuthRep__c = true;
        Map<String,object> mapRestResult =  createContact(contactList);            
        contactList = (List<Contact>)mapRestResult.get('lstContacts');         
        if(contactList != null && !contactList.isEmpty() && contactList[0].AccountId != null){                            
            resultMap.put('contactId', contactList[0].Id);
            resultMap.put('SUCCESS',JSON.serialize(new Map<String, String>{ 'contactId'=>contactList[0].Id}));             
        }else{
            resultMap.put('ERROR', 'Contact insertion failed');
        }
        return resultMap;
    }

    /*
    * @author       Shrikant Raut
    * @date         01/28/2019
    * @methodname   createACR
    * @description  Method to create account contact relation. 
    * @return       SSP_LightningResponse
    **/
    private static List<AccountContactRelation> upsertACR(List<AccountContactRelation> acrList, Id sspApplicationAccount, Id sspContactId){
        if(acrList != null && sspApplicationAccount !=null && acrList[0] != null && acrList[0].Id != null){      
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
            acrList = ESAPI.accessController().updateAsUser(new Map<ID,AccountContactRelation>(acrList), SSP_Utility.getFieldsNamesList (acrList)).wasSuccessful() ? acrList : null ;        
        }
        return acrList;
    }


    /*
    * @author       Shrikant Raut
    * @date         01/22/2019
    * @methodname   createNewAuthRep
    * @description  Method to create account using API
    * @return       SSP_LightningResponse
    **/
    private static Map<String,object> createContact(List<Contact> contactList){
        List<Account> lstAccountToInsert = new List<Account>();
        Account objAcc = new Account(); 
        objAcc.Name =  contactList[0].FirstName +' '+ contactList[0].LastName;
        lstAccountToInsert.add(objAcc);                
        Map<String,Object> accCreation = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccountToInsert, contactList, SSP_Utility.getCurrentUserDetails()[0].ContactId); //ForceReviewer Fix
        //List<LOG_LogMessage__c> physicalAddressLogs = validateAddress(contactList[0]);
        
        if(!contactList.isEmpty() && !accCreation.isEmpty()){
            
            
            List<Contact> sObjContactList = (List<Contact>)accCreation.get('lstContacts');   
            contactList[0].Id = sObjContactList[0].Id;
            //contactList[0].Id = (Id)accCreation.get('lstContacts').Id;
            if(!contactList.isEmpty()){
                
             	validateAddress(contactList[0]);   
            }            
        }
        return accCreation;
    }

            /*
    * @author       Shrikant Raut 
    * @date         01/20/2019 
    * @methodname   fetchContactInformation
    * @description  This methods is used to fetch  contact information
    * @return       SSP_LightningResponse
    **/
    @auraEnabled(cacheable=true) 
    public static SSP_LightningResponse fetchDetailsForConsent(Id sspAccountId, String callingComponent){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();        
        List<Contact> contactList = new List<Contact>();    
        List<SSP_ApplicationIndividual__c> memberList = new List<SSP_ApplicationIndividual__c>();    
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();                    
        try{
            memberList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                            new Set<String>{'SSP_Member__r.FirstName__c', 'SSP_Application__c', 'SSP_Member__r.MiddleInitial__c', 'SSP_Member__r.LastName__c', 'SSP_Member__r.SuffixCode__c'}, 
                                                            new Map<String, String>{'limit'=>'1','IsHeadOfHousehold__c'=> '#true#', 'SSP_Application__r.Account__c'=>sspAccountId});                                                     
            response.put('appIndividualRecord',(memberList != null && !memberList.isEmpty()) ? memberList[0] : null);   
            response.put('dateToday',SSP_Utility.today());                                                   
            response.put('suffixCodeValues',SSP_Utility.getPickListValues('AccountContactRelation','SuffixCode__c',null));                          
            response.bIsSuccess = true;
        }catch(Exception ex){                                       
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AddAuthRepController', 'fetchContactInformation', ex.getMessage() , true);                        
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }
    
    
    /*    
* @date         01/24/2020
* @methodname   checkForDupicateAuthRep
* @description  Method to create account using API
* @return       SSP_LightningResponse
**/
    @AuraEnabled
    public static SSP_LightningResponse checkForDupicateAuthRep(string sContactJSON){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{   
            Contact objContact = (Contact)JSON.deserialize(sContactJSON, Contact.class); 
            Set<String> fieldSet = new Set<String>{'Id','DoesAuthRepHasOrg__c','Name','FirstName','MiddleName','LastName','SuffixCode__c','Email','GenderCode__c','Phone','PrimaryPhoneExtension__c','PreferredLanguageCode__c','RepresentativeRelationshipCode__c','OrganizationName__c','OrgranizationIdentificationNumber__c'};
                List<Contact> contactList = new List<Contact>();  
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();  
            if(objContact != null ){
                Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1','FirstName'=> objContact.FirstName,'LastName' => objContact.LastName,'Email' => objContact.Email,'IsManualAuthRep__c'=>'false'};                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, 
                                                                       fieldSet, 
                                                                       conditionMap);     
                if(!contactList.isEmpty()){
                    acrList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                              new Set<String>{'Id','account.Name','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c'}, 
                                                                              new Map<String, String>{'limit'=>'1000','contactId'=> contactList[0].Id,'account.recordtype.name'=>'Organization'});
                }
                
                // if((!acrList.isEmpty()) && acrList[0].Roles.contains('Authorized Representative')){  
                if((!acrList.isEmpty()) && acrList[0].Roles != null && (acrList[0].Roles.contains(SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING) || acrList[0].Roles.contains( SSP_GlobalConstants.ORGANISATION_AUTH_REP) ||
                                                                        acrList[0].Roles.contains('Authorized Representative')  )) { 
                                                                            if(acrList[0].account.DCdataId__c != null){
                                                                                response.put('organizationName', acrList[0].account.Name );    
                                                                                response.put('organizationId',((!acrList.isEmpty()) && acrList[0].account.DCdataId__c != null) ? acrList[0].account.DCdataId__c : null);
                                                                            }
                                                                            response.put('organizationContactId',((!acrList.isEmpty()) && acrList[0].dcContactId__c != null) ? acrList[0].dcContactId__c : null);
                                                                            if(!contactList.isEmpty()){
                                                                            response.put('contactDuplicateRecord',contactList[0]); 
                                                                            }

                                                                            /** #390707 */
                                                                            if(acrList[0].Roles.contains( SSP_GlobalConstants.ORGANISATION_AUTH_REP)){
                                                                                response.put('isOrgAuthRep', 'Y' ); 
                                                                                if(((String.isNotBlank(contactList[0].DoesAuthRepHasOrg__c) && contactList[0].DoesAuthRepHasOrg__c != 'Y') || String.isBlank(contactList[0].DoesAuthRepHasOrg__c)) && acrList[0].account.DCdataId__c != null){
                                                                                    Contact conToUpdate = new Contact(Id = contactList[0].Id);
                                                                                    conToUpdate.DoesAuthRepHasOrg__c = 'Y';
                                                                                    conToUpdate.OrganizationName__c = acrList[0].account.Name;
                                                                                    conToUpdate.OrgranizationIdentificationNumber__c = String.valueOf(acrList[0].account.DCdataId__c);
                                                                                    ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);                    
                                                                                    ESAPI.accessController().updateAsUser(new Map<ID,Contact>(new List<Contact>{conToUpdate}), SSP_Utility.getFieldsNamesList (new List<Contact>{conToUpdate}));
                                                                                    
                                                                                }
                                                                            }                                                                            
                                                                            /** */
                                                                        }else {
                                                                            if(!contactList.isEmpty()){
                                                                            contactList[0].DoesAuthRepHasOrg__c = 'N'; 
                                                                        }
                                                                            response.put('contactDuplicateRecord',NULL); 
                                                                        }
                
                
                
            }
            
        }  catch(Exception ex) {
            response.put('EXCEPTION',ex.getStackTraceString());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AddAuthRepController', 'checkForDupicateAuthRep', ex.getMessage(), true);
        }
        return response;
    }
    
    public static void validateAddress(Contact objContact){
        List<LOG_LogMessage__c> logMessageList = new List<LOG_LogMessage__c>();
        SSP_AddressVerificationWSDLService.COT_USAC_County_op1 request = new SSP_AddressVerificationWSDLService.COT_USAC_County_op1();
        request.record_id = '';
        request.line1 = objContact.Street__c;
        request.line2 = objContact.AddressLine2__c;
        request.city = objContact.City__c;
        request.state = objContact.SSP_State__c; 
        request.zip = objContact.Zipcode5__c;
        
        List<Object> responseRecords = IntegrationFactory.invokeCallout('SSP_AddressVerification', new Map<String, Object>{'body' => JSON.serialize(request)});
        if(responseRecords != null && !responseRecords.isEmpty() && responseRecords[0] != null) {
            SSP_AddressResponseWrapper responseContainer = (SSP_AddressResponseWrapper)responseRecords[0];
            SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1 response = (SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1)responseContainer.responseDetail;            
            if(response != null) {   
                objContact.IsAddressValidated__c = true;             
                if(response.cot_mail_delivery_code == 'G') {
                    objContact.Street__c = response.cass_line1;
                    objContact.AddressLine2__c = response.cass_line2;
                    objContact.City__c = response.cass_city;
                    objContact.SSP_State__c = response.cass_state;
                    objContact.Zipcode4__c = response.cass_zip4;
                    objContact.Zipcode5__c = response.cass_zip5;
                    objContact.CountyCode__c = getCountyCode(response.usps_county_name);
                }
                else if(response.cot_mail_delivery_code == 'R') {
                    objContact.Street__c = response.cass_line1;
                    objContact.AddressLine2__c = response.cass_line2;
                    objContact.City__c = response.cass_city;
                    objContact.SSP_State__c = response.cass_state;
                    objContact.CountyCode__c = getCountyCode(response.usps_county_name);
                }
            }            
        }
        
        if(objContact.SSP_State__c == 'KY' && objContact.CountyCode__c == '200') {
            objContact.CountyCode__c = null;
		}
        if(objContact != null){            
            //ESAPI.accessController().updateAsUser(objContact, SSP_Utility.getFieldsNamesList(new List<Contact> {objContact}));
           // update objContact;
            
        }
        //return null;
    }
    
    public static String getCountyCode(String countyName) {
        countyName = countyName.toLowerCase();
        
        Map<String, String> values = SSP_Utility.getPickListValues('Contact', 'CountyCode__c', null);
        
        for(String countyCode: values.keySet()) {
            if(countyName == values.get(countyCode).toLowerCase()) {
                
                return countyCode;
            }
        }
        //return OUT OF COUNTY code, if not found
        return '200';
    }

}